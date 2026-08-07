unit mnote_diagnostics;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs, RegExpr, SyncObjs;

type
  TMNoteDiagnosticSeverity = (mdsError, mdsWarning, mdsMessage);

  { TMNoteDiagnostic }

  TMNoteDiagnostic = class
  public
    FileName: string;
    Line: Integer;
    Column: Integer;
    Severity: TMNoteDiagnosticSeverity;
    Code: string;
    MessageText: string;
    Origin: string;
  end;

  { TMNoteDiagnostics }

  TMNoteDiagnostics = class(TObjectList)
  private
    function GetItem(AIndex: Integer): TMNoteDiagnostic;
  public
    constructor Create;
    function AddDiagnostic(const AFileName: string; ALine, AColumn: Integer;
      ASeverity: TMNoteDiagnosticSeverity; const ACode, AMessage,
      AOrigin: string): TMNoteDiagnostic;
    property Items[AIndex: Integer]: TMNoteDiagnostic read GetItem; default;
  end;

  { TMNoteDiagnosticParser }

  TMNoteDiagnosticParser = class
  private
    class function SeverityFromText(const AText: string):
      TMNoteDiagnosticSeverity; static;
    class function ExtractCode(var AMessage: string): string; static;
    class function ParseFPCLine(const AText, AOrigin: string;
      ADiagnostics: TMNoteDiagnostics): Boolean; static;
    class function ParseColonLine(const AText, AOrigin: string;
      ADiagnostics: TMNoteDiagnostics): Boolean; static;
  public
    class procedure Parse(const AOutput, AOrigin: string;
      ADiagnostics: TMNoteDiagnostics); static;
    class function SeverityName(ASeverity: TMNoteDiagnosticSeverity): string;
      static;
  end;

procedure MNoteRememberBuildDiagnostics(ADiagnostics: TMNoteDiagnostics);
procedure MNoteSnapshotBuildDiagnostics(ADiagnostics: TMNoteDiagnostics;
  out AHasPreviousBuild: Boolean);
procedure MNoteClearBuildDiagnostics;

implementation

var
  GLastBuildDiagnostics: TMNoteDiagnostics;
  GDiagnosticsLock: TCriticalSection;
  GHasPreviousBuild: Boolean;

procedure CopyDiagnostic(ASource: TMNoteDiagnostic;
  ADestination: TMNoteDiagnostics);
begin
  if (ASource = nil) or (ADestination = nil) then Exit;
  ADestination.AddDiagnostic(ASource.FileName, ASource.Line, ASource.Column,
    ASource.Severity, ASource.Code, ASource.MessageText, ASource.Origin);
end;

procedure MNoteRememberBuildDiagnostics(ADiagnostics: TMNoteDiagnostics);
var
  I: Integer;
begin
  GDiagnosticsLock.Acquire;
  try
    GLastBuildDiagnostics.Clear;
    if ADiagnostics <> nil then
      for I := 0 to ADiagnostics.Count - 1 do
        CopyDiagnostic(ADiagnostics[I], GLastBuildDiagnostics);
    GHasPreviousBuild := True;
  finally
    GDiagnosticsLock.Release;
  end;
end;

procedure MNoteSnapshotBuildDiagnostics(ADiagnostics: TMNoteDiagnostics;
  out AHasPreviousBuild: Boolean);
var
  I: Integer;
begin
  AHasPreviousBuild := False;
  if ADiagnostics = nil then Exit;
  GDiagnosticsLock.Acquire;
  try
    ADiagnostics.Clear;
    for I := 0 to GLastBuildDiagnostics.Count - 1 do
      CopyDiagnostic(GLastBuildDiagnostics[I], ADiagnostics);
    AHasPreviousBuild := GHasPreviousBuild;
  finally
    GDiagnosticsLock.Release;
  end;
end;

procedure MNoteClearBuildDiagnostics;
begin
  GDiagnosticsLock.Acquire;
  try
    GLastBuildDiagnostics.Clear;
    GHasPreviousBuild := False;
  finally
    GDiagnosticsLock.Release;
  end;
end;

constructor TMNoteDiagnostics.Create;
begin
  inherited Create(True);
end;

function TMNoteDiagnostics.GetItem(AIndex: Integer): TMNoteDiagnostic;
begin
  Result := TMNoteDiagnostic(inherited Items[AIndex]);
end;

function TMNoteDiagnostics.AddDiagnostic(const AFileName: string; ALine,
  AColumn: Integer; ASeverity: TMNoteDiagnosticSeverity; const ACode,
  AMessage, AOrigin: string): TMNoteDiagnostic;
begin
  Result := TMNoteDiagnostic.Create;
  Result.FileName := AFileName;
  Result.Line := ALine;
  Result.Column := AColumn;
  Result.Severity := ASeverity;
  Result.Code := ACode;
  Result.MessageText := AMessage;
  Result.Origin := AOrigin;
  Add(Result);
end;

class function TMNoteDiagnosticParser.SeverityFromText(const AText: string):
  TMNoteDiagnosticSeverity;
var
  Value: string;
begin
  Value := LowerCase(Trim(AText));
  if (Value = 'error') or (Value = 'fatal') or (Value = 'fatal error') then
    Result := mdsError
  else if Value = 'warning' then
    Result := mdsWarning
  else
    Result := mdsMessage;
end;

class function TMNoteDiagnosticParser.ExtractCode(var AMessage: string): string;
var
  CloseAt: Integer;
begin
  Result := '';
  AMessage := Trim(AMessage);
  if (AMessage = '') or (AMessage[1] <> '(') then Exit;
  CloseAt := Pos(')', AMessage);
  if CloseAt <= 2 then Exit;
  Result := Copy(AMessage, 2, CloseAt - 2);
  AMessage := Trim(Copy(AMessage, CloseAt + 1, MaxInt));
end;

class function TMNoteDiagnosticParser.ParseFPCLine(const AText,
  AOrigin: string; ADiagnostics: TMNoteDiagnostics): Boolean;
var
  Expression: TRegExpr;
  MessageText, Code: string;
begin
  Result := False;
  Expression := TRegExpr.Create;
  try
    Expression.Expression :=
      '^(.+)\(([0-9]+)(,([0-9]+))?\)[ \t]+' +
      '(Fatal|Error|Warning|Note|Hint|Message):[ \t]*(.*)$';
    if not Expression.Exec(AText) then Exit;
    MessageText := Expression.Match[6];
    Code := ExtractCode(MessageText);
    ADiagnostics.AddDiagnostic(Expression.Match[1],
      StrToIntDef(Expression.Match[2], 0),
      StrToIntDef(Expression.Match[4], 0),
      SeverityFromText(Expression.Match[5]), Code, MessageText, AOrigin);
    Result := True;
  finally
    Expression.Free;
  end;
end;

class function TMNoteDiagnosticParser.ParseColonLine(const AText,
  AOrigin: string; ADiagnostics: TMNoteDiagnostics): Boolean;
var
  Expression: TRegExpr;
  MessageText, Code: string;
begin
  Result := False;
  Expression := TRegExpr.Create;
  try
    Expression.Expression :=
      '^(.+):([0-9]+):([0-9]+):[ \t]*' +
      '(fatal error|error|warning|note|hint|message):[ \t]*(.*)$';
    Expression.ModifierI := True;
    if not Expression.Exec(AText) then Exit;
    MessageText := Expression.Match[5];
    Code := ExtractCode(MessageText);
    ADiagnostics.AddDiagnostic(Expression.Match[1],
      StrToIntDef(Expression.Match[2], 0),
      StrToIntDef(Expression.Match[3], 0),
      SeverityFromText(Expression.Match[4]), Code, MessageText, AOrigin);
    Result := True;
  finally
    Expression.Free;
  end;
end;

class procedure TMNoteDiagnosticParser.Parse(const AOutput, AOrigin: string;
  ADiagnostics: TMNoteDiagnostics);
var
  Lines: TStringList;
  I: Integer;
begin
  if ADiagnostics = nil then Exit;
  Lines := TStringList.Create;
  try
    Lines.Text := StringReplace(AOutput, #13#10, #10, [rfReplaceAll]);
    for I := 0 to Lines.Count - 1 do
      if not ParseFPCLine(TrimRight(Lines[I]), AOrigin, ADiagnostics) then
        ParseColonLine(TrimRight(Lines[I]), AOrigin, ADiagnostics);
  finally
    Lines.Free;
  end;
end;

class function TMNoteDiagnosticParser.SeverityName(
  ASeverity: TMNoteDiagnosticSeverity): string;
begin
  case ASeverity of
    mdsError: Result := 'Error';
    mdsWarning: Result := 'Warning';
  else
    Result := 'Message';
  end;
end;

initialization
  GLastBuildDiagnostics := TMNoteDiagnostics.Create;
  GDiagnosticsLock := TCriticalSection.Create;

finalization
  GDiagnosticsLock.Free;
  GLastBuildDiagnostics.Free;

end.
