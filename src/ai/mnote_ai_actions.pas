unit mnote_ai_actions;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs, fpjson, jsonparser, mnote_ai_types,
  mnote_process_service, aiagentsafety;

type
  TMNoteAIActionEffect = (aaeReadOnly, aaeBuildArtifact, aaeSourceWrite,
    aaeExternalWrite);

  { TMNoteAIActionDescriptor }

  TMNoteAIActionDescriptor = class
  private
    FParameters: TStringList;
  public
    Name: string;
    Effect: TMNoteAIActionEffect;
    MaxOutputChars: Integer;
    RequiresConfirmation: Boolean;
    constructor Create(const AName: string; AEffect: TMNoteAIActionEffect;
      AMaxOutputChars: Integer; ARequiresConfirmation: Boolean);
    destructor Destroy; override;
    procedure AddParameter(const AName: string);
    function AcceptsParameter(const AName: string): Boolean;
    property Parameters: TStringList read FParameters;
  end;

  TMNoteAIActionConfirmEvent = function(Sender: TObject;
    ADescriptor: TMNoteAIActionDescriptor; AParameters: TJSONObject;
    out AReason: string): Boolean of object;
  TMNoteAIDictionaryEvent = function(Sender: TObject; out AJSON,
    AError: string): Boolean of object;
  TMNoteAIActionLogEvent = procedure(Sender: TObject;
    const ALogJSON: string) of object;

  { TMNoteAIActionExecutor }

  TMNoteAIActionExecutor = class
  private
    FRootPath: string;
    FActions: TObjectList;
    FProcess: TMNoteProcessService;
    FSafety: TAIAgentSafety;
    FOnConfirm: TMNoteAIActionConfirmEvent;
    FOnGetDictionary: TMNoteAIDictionaryEvent;
    FOnLog: TMNoteAIActionLogEvent;
    FLastErrorIsContract: Boolean;
    function FindAction(const AName: string): TMNoteAIActionDescriptor;
    function ParseRequest(const AJSON: string;
      out ADescriptor: TMNoteAIActionDescriptor;
      out AParameters: TJSONObject; out AData: TJSONData;
      out AError: string): Boolean;
    function RoleMayExecute(ARole: TMNoteAIRole;
      ADescriptor: TMNoteAIActionDescriptor): Boolean;
    function ResolveProjectFile(const AValue: string; out AFileName,
      AError: string): Boolean;
    function ExecuteReadFile(AParameters: TJSONObject; out AData: TJSONData;
      out ATruncated: Boolean; out AError: string): Boolean;
    function ExecuteFileOutline(AParameters: TJSONObject; out AData: TJSONData;
      out ATruncated: Boolean; out AError: string): Boolean;
    function ExecuteSearchProject(AParameters: TJSONObject;
      out AData: TJSONData; out ATruncated: Boolean;
      out AError: string): Boolean;
    function ExecuteListSymbols(AParameters: TJSONObject;
      out AData: TJSONData; out ATruncated: Boolean;
      out AError: string): Boolean;
    function ExecuteFindDefinition(AParameters: TJSONObject;
      out AData: TJSONData; out ATruncated: Boolean;
      out AError: string): Boolean;
    function ExecuteDependencyGraph(AParameters: TJSONObject;
      out AData: TJSONData; out ATruncated: Boolean;
      out AError: string): Boolean;
    function ExecuteBuildDiagnostics(AParameters: TJSONObject;
      out AData: TJSONData; out ATruncated: Boolean;
      out AError: string): Boolean;
    function ExecuteListProjectFiles(AParameters: TJSONObject;
      out AData: TJSONData; out ATruncated: Boolean;
      out AError: string): Boolean;
    function ExecuteGitLog(AParameters: TJSONObject; out AData: TJSONData;
      out ATruncated: Boolean; out AError: string): Boolean;
    function ExecuteGitDiff(AParameters: TJSONObject; out AData: TJSONData;
      out ATruncated: Boolean; out AError: string): Boolean;
    function ExecuteDictionary(out AData: TJSONData;
      out ATruncated: Boolean; out AError: string): Boolean;
    function ExecuteCompile(AParameters: TJSONObject; out AData: TJSONData;
      out ATruncated: Boolean; out AError: string): Boolean;
    function LimitText(const AText: string; AMax: Integer;
      out ATruncated: Boolean): string;
    function ResultJSON(const AAction: string; ASuccess,
      ATruncated: Boolean; AData: TJSONData; const AError: string): string;
    procedure LogResult(const AAction: string; ARole: TMNoteAIRole;
      ASuccess, ATruncated: Boolean; const AError: string);
    procedure RegisterActions;
  public
    constructor Create(const ARootPath: string);
    destructor Destroy; override;
    function DescribeActions(AReadOnlyOnly: Boolean = False): string;
    function ActionIsReadOnly(const AName: string): Boolean;
    function ValidateRequestContract(const ARequestJSON: string;
      out AActionName, AError: string): Boolean;
    function ExecuteRequest(const ARequestJSON: string; ARole: TMNoteAIRole;
      out AResultJSON, AError: string): Boolean;
    procedure Cancel;
    property RootPath: string read FRootPath;
    property Safety: TAIAgentSafety read FSafety;
    property OnConfirm: TMNoteAIActionConfirmEvent read FOnConfirm
      write FOnConfirm;
    property OnGetDictionary: TMNoteAIDictionaryEvent read FOnGetDictionary
      write FOnGetDictionary;
    property OnLog: TMNoteAIActionLogEvent read FOnLog write FOnLog;
    property LastErrorIsContract: Boolean read FLastErrorIsContract;
  end;

function MNoteAIActionEffectName(AEffect: TMNoteAIActionEffect): string;

implementation

uses
  StrUtils, mnote_search_types, mnote_file_search_service,
  mnote_completion_types, mnote_pascal_symbol_parser, mnote_project_symbol_index,
  mnote_dependency_graph_service, aidependencygraph,
  mnote_git_read_service, mnote_build_service, mnote_diagnostics;

function MNoteAIActionEffectName(AEffect: TMNoteAIActionEffect): string;
begin
  case AEffect of
    aaeBuildArtifact: Result := 'build_artifact';
    aaeSourceWrite: Result := 'source_write';
    aaeExternalWrite: Result := 'external_write';
  else
    Result := 'read_only';
  end;
end;

function JSONString(AObject: TJSONObject; const AName,
  ADefault: string): string;
var
  Value: TJSONData;
begin
  Result := ADefault;
  if AObject = nil then Exit;
  Value := AObject.Find(AName);
  if (Value <> nil) and (Value.JSONType = jtString) then Result := Value.AsString;
end;

function JSONInteger(AObject: TJSONObject; const AName: string;
  ADefault: Integer): Integer;
var
  Value: TJSONData;
begin
  Result := ADefault;
  if AObject = nil then Exit;
  Value := AObject.Find(AName);
  if (Value <> nil) and (Value.JSONType = jtNumber) then Result := Value.AsInteger;
end;

function JSONBoolean(AObject: TJSONObject; const AName: string;
  ADefault: Boolean): Boolean;
var
  Value: TJSONData;
begin
  Result := ADefault;
  if AObject = nil then Exit;
  Value := AObject.Find(AName);
  if (Value <> nil) and (Value.JSONType = jtBoolean) then Result := Value.AsBoolean;
end;

function IsAllowedExtension(const AFileName: string): Boolean;
var
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(AFileName));
  Result := (Ext = '.pas') or (Ext = '.pp') or (Ext = '.inc') or (Ext = '.lpr') or
    (Ext = '.lpi') or (Ext = '.lpk') or (Ext = '.json') or (Ext = '.md') or
    (Ext = '.txt') or (Ext = '.sql') or (Ext = '.py') or (Ext = '.c') or
    (Ext = '.h') or (Ext = '.cpp') or (Ext = '.ini') or (Ext = '.cfg') or
    (Ext = '.xml') or (Ext = '.yml') or (Ext = '.yaml') or (Ext = '.sh');
end;

function IsSensitivePath(const AFileName: string): Boolean;
var
  Value, BaseName, Extension: string;
begin
  Value := LowerCase(StringReplace(AFileName, '\', '/', [rfReplaceAll]));
  BaseName := LowerCase(ExtractFileName(AFileName));
  Extension := LowerCase(ExtractFileExt(AFileName));
  Result := (Pos('/.git/', '/' + Value + '/') > 0) or
    (BaseName = '.env') or AnsiStartsStr('.env.', BaseName) or
    (Pos('credential', BaseName) > 0) or (Pos('secret', BaseName) > 0) or
    (BaseName = 'id_rsa') or (BaseName = 'id_ed25519') or
    (Extension = '.key') or (Extension = '.pfx') or
    (Extension = '.p12') or (Extension = '.pem');
end;

function HasSymbolicPathPart(const ARoot, AFileName: string): Boolean;
var
  RelativeName, CurrentName: string;
  Parts: TStringList;
  I, Attributes: Integer;
begin
  Result := False;
  RelativeName := Copy(AFileName,
    Length(IncludeTrailingPathDelimiter(ARoot)) + 1, MaxInt);
  RelativeName := StringReplace(RelativeName, '\', '/', [rfReplaceAll]);
  Parts := TStringList.Create;
  try
    Parts.StrictDelimiter := True;
    Parts.Delimiter := '/';
    Parts.DelimitedText := RelativeName;
    CurrentName := ExcludeTrailingPathDelimiter(ARoot);
    for I := 0 to Parts.Count - 1 do
    begin
      if Parts[I] = '' then Continue;
      CurrentName := IncludeTrailingPathDelimiter(CurrentName) + Parts[I];
      Attributes := FileGetAttr(CurrentName);
      {$IF declared(faSymLink)}
      if (Attributes <> -1) and ((Attributes and faSymLink) <> 0) then
        Exit(True);
      {$ENDIF}
    end;
  finally
    Parts.Free;
  end;
end;

function ExistingFileSize(const AFileName: string): Int64;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    Result := Stream.Size;
  finally
    Stream.Free;
  end;
end;

function LoadFileBytes(const AFileName: string): string;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    if Stream.Size > MaxInt then
      raise Exception.Create('O arquivo é grande demais para leitura.');
    SetLength(Result, Stream.Size);
    if Stream.Size > 0 then Stream.ReadBuffer(Result[1], Stream.Size);
  finally
    Stream.Free;
  end;
end;

function RawLineCount(const AText: string): Integer;
var
  I: Integer;
begin
  if AText = '' then Exit(0);
  Result := 0;
  for I := 1 to Length(AText) do
    if AText[I] = #10 then Inc(Result);
  if AText[Length(AText)] <> #10 then Inc(Result);
end;

function RawLineStart(const AText: string; ALine: Integer): Integer;
var
  I, CurrentLine: Integer;
begin
  if ALine <= 1 then Exit(1);
  CurrentLine := 1;
  for I := 1 to Length(AText) do
    if AText[I] = #10 then
    begin
      Inc(CurrentLine);
      if CurrentLine = ALine then Exit(I + 1);
    end;
  Result := Length(AText) + 1;
end;

function RawLineEnd(const AText: string; ALine: Integer): Integer;
var
  I, CurrentLine: Integer;
begin
  CurrentLine := 1;
  for I := 1 to Length(AText) do
    if AText[I] = #10 then
    begin
      if CurrentLine = ALine then Exit(I);
      Inc(CurrentLine);
    end;
  Result := Length(AText);
end;

function RawLineAt(const AText: string; APosition: Integer): Integer;
var
  I, LastPosition: Integer;
begin
  if AText = '' then Exit(0);
  LastPosition := APosition;
  if LastPosition < 1 then LastPosition := 1;
  if LastPosition > Length(AText) then LastPosition := Length(AText);
  Result := 1;
  for I := 1 to LastPosition - 1 do
    if AText[I] = #10 then Inc(Result);
end;

constructor TMNoteAIActionDescriptor.Create(const AName: string;
  AEffect: TMNoteAIActionEffect; AMaxOutputChars: Integer;
  ARequiresConfirmation: Boolean);
begin
  inherited Create;
  Name := AName;
  Effect := AEffect;
  MaxOutputChars := AMaxOutputChars;
  RequiresConfirmation := ARequiresConfirmation;
  FParameters := TStringList.Create;
  FParameters.CaseSensitive := False;
  FParameters.Sorted := True;
  FParameters.Duplicates := dupIgnore;
end;

destructor TMNoteAIActionDescriptor.Destroy;
begin
  FParameters.Free;
  inherited Destroy;
end;

procedure TMNoteAIActionDescriptor.AddParameter(const AName: string);
begin
  FParameters.Add(AName);
end;

function TMNoteAIActionDescriptor.AcceptsParameter(
  const AName: string): Boolean;
begin
  Result := FParameters.IndexOf(AName) >= 0;
end;

constructor TMNoteAIActionExecutor.Create(const ARootPath: string);
begin
  inherited Create;
  FRootPath := ExcludeTrailingPathDelimiter(ExpandFileName(ARootPath));
  FActions := TObjectList.Create(True);
  FProcess := TMNoteProcessService.Create;
  FSafety := TAIAgentSafety.Create(nil);
  FSafety.Enabled := True;
  FSafety.SimulationMode := False;
  FSafety.ReadOnlyMode := True;
  FSafety.RequireConfirmation := False;
  FSafety.SafeBasePath := FRootPath;
  RegisterActions;
end;

destructor TMNoteAIActionExecutor.Destroy;
begin
  FSafety.Free;
  FProcess.Free;
  FActions.Free;
  inherited Destroy;
end;

procedure TMNoteAIActionExecutor.RegisterActions;
var
  Action: TMNoteAIActionDescriptor;
  I: Integer;
begin
  Action := TMNoteAIActionDescriptor.Create('ReadFile', aaeReadOnly,
    20000, False);
  Action.AddParameter('path');
  Action.AddParameter('max_chars');
  Action.AddParameter('start_line');
  Action.AddParameter('end_line');
  Action.AddParameter('offset_chars');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('FileOutline', aaeReadOnly,
    16000, False);
  Action.AddParameter('path');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('SearchProject', aaeReadOnly,
    16000, False);
  Action.AddParameter('query');
  Action.AddParameter('include');
  Action.AddParameter('exclude');
  Action.AddParameter('regex');
  Action.AddParameter('match_case');
  Action.AddParameter('whole_word');
  Action.AddParameter('max_results');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('ListSymbols', aaeReadOnly,
    16000, False);
  Action.AddParameter('max_results');
  Action.AddParameter('name_contains');
  Action.AddParameter('kind');
  Action.AddParameter('path_contains');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('FindDefinition', aaeReadOnly,
    16000, False);
  Action.AddParameter('name');
  Action.AddParameter('max_results');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('DependencyGraph', aaeReadOnly,
    20000, False);
  Action.AddParameter('unit_name');
  Action.AddParameter('direction');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('BuildDiagnostics', aaeReadOnly,
    20000, False);
  Action.AddParameter('severity');
  Action.AddParameter('path_contains');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('ListProjectFiles', aaeReadOnly,
    20000, False);
  Action.AddParameter('include');
  Action.AddParameter('exclude');
  Action.AddParameter('max_results');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('GitLog', aaeReadOnly,
    12000, False);
  Action.AddParameter('count');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('GitDiff', aaeReadOnly,
    24000, False);
  Action.AddParameter('commit');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('DBDictionary', aaeReadOnly,
    24000, False);
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('Compile', aaeBuildArtifact,
    30000, True);
  Action.AddParameter('rebuild');
  FActions.Add(Action);

  FSafety.AllowedActions.Clear;
  for I := 0 to FActions.Count - 1 do
    FSafety.AllowedActions.Add(TMNoteAIActionDescriptor(FActions[I]).Name);
end;

function TMNoteAIActionExecutor.FindAction(
  const AName: string): TMNoteAIActionDescriptor;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FActions.Count - 1 do
    if SameText(TMNoteAIActionDescriptor(FActions[I]).Name, AName) then
      Exit(TMNoteAIActionDescriptor(FActions[I]));
end;

function TMNoteAIActionExecutor.ParseRequest(const AJSON: string;
  out ADescriptor: TMNoteAIActionDescriptor; out AParameters: TJSONObject;
  out AData: TJSONData; out AError: string): Boolean;
var
  Root: TJSONObject;
  Value: TJSONData;
  I: Integer;
begin
  Result := False;
  ADescriptor := nil;
  AParameters := nil;
  AData := nil;
  AError := '';
  if (Trim(AJSON) = '') or (Trim(AJSON)[1] <> '{') or
    (Trim(AJSON)[Length(Trim(AJSON))] <> '}') then
  begin
    AError := 'A solicitação deve conter somente um objeto JSON.';
    Exit;
  end;
  try
    AData := GetJSON(AJSON);
  except
    on E: Exception do
    begin
      AError := 'JSON de ação inválido: ' + E.Message;
      Exit;
    end;
  end;
  if not (AData is TJSONObject) then
  begin
    AError := 'A raiz da ação deve ser um objeto JSON.';
    FreeAndNil(AData);
    Exit;
  end;
  Root := TJSONObject(AData);
  for I := 0 to Root.Count - 1 do
    if (Root.Names[I] <> 'action') and (Root.Names[I] <> 'parameters') then
    begin
      AError := 'Campo desconhecido na ação: ' + Root.Names[I];
      FreeAndNil(AData);
      Exit;
    end;
  Value := Root.Find('action');
  if (Value = nil) or (Value.JSONType <> jtString) then
  begin
    AError := 'O campo action é obrigatório e deve ser texto.';
    FreeAndNil(AData);
    Exit;
  end;
  ADescriptor := FindAction(Value.AsString);
  if ADescriptor = nil then
  begin
    AError := 'Ação não autorizada: ' + Value.AsString;
    FreeAndNil(AData);
    Exit;
  end;
  Value := Root.Find('parameters');
  if (Value = nil) or not (Value is TJSONObject) then
  begin
    AError := 'O campo parameters é obrigatório e deve ser um objeto.';
    FreeAndNil(AData);
    Exit;
  end;
  AParameters := TJSONObject(Value);
  for I := 0 to AParameters.Count - 1 do
    if not ADescriptor.AcceptsParameter(AParameters.Names[I]) then
    begin
      AError := 'Parâmetro não declarado para ' + ADescriptor.Name + ': ' +
        AParameters.Names[I];
      AParameters := nil;
      FreeAndNil(AData);
      Exit;
    end;
  Result := True;
end;

function TMNoteAIActionExecutor.RoleMayExecute(ARole: TMNoteAIRole;
  ADescriptor: TMNoteAIActionDescriptor): Boolean;
begin
  Result := (ADescriptor <> nil) and
    not (ARole in [airTriage, airArbiter]);
  if Result and SameText(ADescriptor.Name, 'DBDictionary') then
    Result := ARole in [airLightWork, airRecovery, airDatabase, airManagement];
  if Result and SameText(ADescriptor.Name, 'Compile') then
    Result := ARole in [airLightWork, airRecovery, airManagement];
end;

function TMNoteAIActionExecutor.ResolveProjectFile(const AValue: string;
  out AFileName, AError: string): Boolean;
var
  RootWithDelimiter, Candidate: string;
begin
  Result := False;
  AFileName := '';
  AError := '';
  if Trim(AValue) = '' then
  begin
    AError := 'O caminho do arquivo é obrigatório.';
    Exit;
  end;
  RootWithDelimiter := IncludeTrailingPathDelimiter(FRootPath);
  if ExtractFileDrive(AValue) <> '' then Candidate := ExpandFileName(AValue)
  else Candidate := ExpandFileName(RootWithDelimiter + AValue);
  {$IFDEF WINDOWS}
  if not SameText(Copy(IncludeTrailingPathDelimiter(Candidate), 1,
    Length(RootWithDelimiter)), RootWithDelimiter) then
  {$ELSE}
  if Copy(IncludeTrailingPathDelimiter(Candidate), 1,
    Length(RootWithDelimiter)) <> RootWithDelimiter then
  {$ENDIF}
  begin
    AError := 'O caminho informado está fora da raiz do projeto.';
    Exit;
  end;
  if not FileExists(Candidate) then
  begin
    AError := 'Arquivo inexistente: ' + Candidate;
    Exit;
  end;
  if not FSafety.ValidateFilePath(Candidate, AError) then
  begin
    AError := 'Agent Safety: ' + AError;
    Exit;
  end;
  if HasSymbolicPathPart(FRootPath, Candidate) then
  begin
    AError := 'Links simbólicos não são permitidos em ações da IA.';
    Exit;
  end;
  if IsSensitivePath(Candidate) then
  begin
    AError := 'A leitura de arquivos sensíveis não é permitida.';
    Exit;
  end;
  if not IsAllowedExtension(Candidate) then
  begin
    AError := 'Extensão não suportada para leitura pela IA: ' +
      ExtractFileExt(Candidate);
    Exit;
  end;
  AFileName := Candidate;
  Result := True;
end;

function TMNoteAIActionExecutor.LimitText(const AText: string; AMax: Integer;
  out ATruncated: Boolean): string;
const
  TruncationMarker = #10'[saída truncada pelo limite da ferramenta]';
begin
  if AMax < Length(TruncationMarker) + 1 then AMax := 1024;
  ATruncated := Length(AText) > AMax;
  if ATruncated then
    Result := Copy(AText, 1, AMax - Length(TruncationMarker)) +
      TruncationMarker
  else
    Result := AText;
end;

function TMNoteAIActionExecutor.ExecuteReadFile(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  FileName, RawContent, SliceContent: string;
  MaxChars, ReqStartLine, ReqEndLine, OffsetChars: Integer;
  TotalChars, TotalLines: Integer;
  StartCharIdx, EndCharIdx: Integer;
  ActualStartLine, ActualEndLine: Integer;
  NextOffset: Integer;
  IsEOF, HasStartLine, HasEndLine, HasOffset: Boolean;
  OutputObject: TJSONObject;
begin
  AData := nil;
  ATruncated := False;
  if not ResolveProjectFile(JSONString(AParameters, 'path', ''), FileName,
    AError) then Exit(False);
  if ExistingFileSize(FileName) > 2 * 1024 * 1024 then
  begin
    AError := 'O arquivo excede o limite de leitura de 2 MB.';
    Exit(False);
  end;

  MaxChars := JSONInteger(AParameters, 'max_chars', 20000);
  if MaxChars < 256 then MaxChars := 256;
  if MaxChars > 20000 then MaxChars := 20000;

  HasStartLine := AParameters.Find('start_line') <> nil;
  HasEndLine := AParameters.Find('end_line') <> nil;
  HasOffset := AParameters.Find('offset_chars') <> nil;
  ReqStartLine := JSONInteger(AParameters, 'start_line', 1);
  ReqEndLine := JSONInteger(AParameters, 'end_line', 0);
  OffsetChars := JSONInteger(AParameters, 'offset_chars', 0);
  RawContent := LoadFileBytes(FileName);
  TotalChars := Length(RawContent);
  TotalLines := RawLineCount(RawContent);

  if (OffsetChars < 0) or (OffsetChars > TotalChars) then
  begin
    AError := Format('offset_chars deve estar entre 0 e %d.', [TotalChars]);
    Exit(False);
  end;
  if HasStartLine and ((ReqStartLine < 1) or (ReqStartLine > TotalLines)) then
  begin
    AError := Format('start_line deve estar entre 1 e %d.', [TotalLines]);
    Exit(False);
  end;
  if HasEndLine and ((ReqEndLine < 1) or (ReqEndLine > TotalLines)) then
  begin
    AError := Format('end_line deve estar entre 1 e %d.', [TotalLines]);
    Exit(False);
  end;
  if HasEndLine and (ReqEndLine < ReqStartLine) then
  begin
    AError := 'end_line não pode ser menor que start_line.';
    Exit(False);
  end;

  if TotalLines = 0 then
  begin
    StartCharIdx := 1;
    EndCharIdx := 0;
  end
  else
  begin
    StartCharIdx := RawLineStart(RawContent, ReqStartLine);
    if HasOffset and (OffsetChars + 1 > StartCharIdx) then
      StartCharIdx := OffsetChars + 1;
    if HasEndLine then EndCharIdx := RawLineEnd(RawContent, ReqEndLine)
    else EndCharIdx := TotalChars;
  end;

  if StartCharIdx > EndCharIdx then SliceContent := ''
  else
  begin
    if EndCharIdx - StartCharIdx + 1 > MaxChars then
      EndCharIdx := StartCharIdx + MaxChars - 1;
    SliceContent := Copy(RawContent, StartCharIdx, EndCharIdx - StartCharIdx + 1);
  end;

  NextOffset := StartCharIdx - 1 + Length(SliceContent);
  if HasEndLine then IsEOF := NextOffset >= RawLineEnd(RawContent, ReqEndLine)
  else IsEOF := NextOffset >= TotalChars;
  ATruncated := not IsEOF;
  ActualStartLine := RawLineAt(RawContent, StartCharIdx);
  if SliceContent = '' then ActualEndLine := ActualStartLine
  else ActualEndLine := RawLineAt(RawContent, NextOffset);

  OutputObject := TJSONObject.Create;
  OutputObject.Add('path', ExtractRelativePath(
    IncludeTrailingPathDelimiter(FRootPath), FileName));
  OutputObject.Add('content', SliceContent);
  OutputObject.Add('total_chars', TotalChars);
  OutputObject.Add('total_lines', TotalLines);
  OutputObject.Add('start_line', ActualStartLine);
  OutputObject.Add('end_line', ActualEndLine);
  OutputObject.Add('next_offset', NextOffset);
  OutputObject.Add('eof', IsEOF);
  OutputObject.Add('truncated', ATruncated);
  AData := OutputObject;
  Result := True;
end;

function TMNoteAIActionExecutor.ExecuteFileOutline(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  FileName, Ext, TargetUnitName: string;
  Lines: TStringList;
  TotalLines, I, InterfaceLine, ImplementationLine: Integer;
  Parser: TMNotePascalSymbolParser;
  Items: TMNoteCompletionItems;
  OutputObject, SectionsObject, SymObj: TJSONObject;
  SymbolsArray: TJSONArray;
begin
  AData := nil;
  ATruncated := False;
  if not ResolveProjectFile(JSONString(AParameters, 'path', ''), FileName,
    AError) then Exit(False);
  if ExistingFileSize(FileName) > 2 * 1024 * 1024 then
  begin
    AError := 'O arquivo excede o limite de leitura de 2 MB.';
    Exit(False);
  end;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FileName);
    TotalLines := Lines.Count;
    TargetUnitName := ChangeFileExt(ExtractFileName(FileName), '');
    InterfaceLine := 0;
    ImplementationLine := 0;

    for I := 0 to TotalLines - 1 do
    begin
      if (InterfaceLine = 0) and SameText(Trim(Lines[I]), 'interface') then
        InterfaceLine := I + 1;
      if (ImplementationLine = 0) and SameText(Trim(Lines[I]), 'implementation') then
        ImplementationLine := I + 1;
    end;

    SymbolsArray := TJSONArray.Create;
    Ext := LowerCase(ExtractFileExt(FileName));
    if (Ext = '.pas') or (Ext = '.pp') or (Ext = '.inc') or (Ext = '.lpr') then
    begin
      Parser := TMNotePascalSymbolParser.Create;
      Items := TMNoteCompletionItems.Create;
      try
        Parser.Parse(Lines.Text, FileName, 'FileOutline', Items);
        for I := 0 to Items.Count - 1 do
        begin
          SymObj := TJSONObject.Create;
          SymObj.Add('name', Items[I].Text);
          SymObj.Add('kind', CompletionKindName(Items[I].Kind));
          SymObj.Add('signature', Items[I].Signature);
          SymObj.Add('line', Items[I].Line);
          if Length(SymbolsArray.AsJSON) + Length(SymObj.AsJSON) + 512 > 16000 then
          begin
            SymObj.Free;
            ATruncated := True;
            Break;
          end;
          SymbolsArray.Add(SymObj);
        end;
      finally
        Items.Free;
        Parser.Free;
      end;
    end;

    SectionsObject := TJSONObject.Create;
    SectionsObject.Add('interface_line', InterfaceLine);
    SectionsObject.Add('implementation_line', ImplementationLine);

    OutputObject := TJSONObject.Create;
    OutputObject.Add('unit_name', TargetUnitName);
    OutputObject.Add('path', ExtractRelativePath(
      IncludeTrailingPathDelimiter(FRootPath), FileName));
    OutputObject.Add('total_lines', TotalLines);
    OutputObject.Add('sections', SectionsObject);
    OutputObject.Add('symbols', SymbolsArray);

    AData := OutputObject;
    Result := True;
  finally
    Lines.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteSearchProject(
  AParameters: TJSONObject; out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  SearchService: TMNoteFileSearchService;
  Results: TMNoteSearchResults;
  Options: TMNoteSearchOptions;
  OutputArray: TJSONArray;
  Item: TJSONObject;
  Query: string;
  I, Maximum: Integer;
begin
  Result := False;
  AData := nil;
  ATruncated := False;
  Query := JSONString(AParameters, 'query', '');
  if Query = '' then
  begin
    AError := 'O texto de busca é obrigatório.';
    Exit;
  end;
  Options := DefaultSearchOptions;
  Options.Scope := ssProject;
  Options.IncludePatterns := JSONString(AParameters, 'include', '*.*');
  Options.ExcludePatterns := JSONString(AParameters, 'exclude',
    '!.git/**;!lib/**;!backup/**;!.mnote/**');
  Options.RegularExpression := JSONBoolean(AParameters, 'regex', False);
  Options.MatchCase := JSONBoolean(AParameters, 'match_case', False);
  Options.WholeWord := JSONBoolean(AParameters, 'whole_word', False);
  Maximum := JSONInteger(AParameters, 'max_results', 100);
  if Maximum < 1 then Maximum := 1;
  if Maximum > 200 then Maximum := 200;
  SearchService := TMNoteFileSearchService.Create;
  Results := TMNoteSearchResults.Create;
  OutputArray := TJSONArray.Create;
  try
    if not SearchService.SearchFolder(FRootPath, Query, Options, Results) then
    begin
      AError := SearchService.LastError;
      Exit;
    end;
    ATruncated := Results.Count > Maximum;
    for I := 0 to Results.Count - 1 do
    begin
      if I >= Maximum then Break;
      Item := TJSONObject.Create;
      Item.Add('path', ExtractRelativePath(IncludeTrailingPathDelimiter(
        FRootPath), Results[I].FileName));
      Item.Add('line', Results[I].Line);
      Item.Add('column', Results[I].Column);
      Item.Add('preview', Results[I].Preview);
      OutputArray.Add(Item);
    end;
    AData := OutputArray;
    OutputArray := nil;
    Result := True;
  finally
    OutputArray.Free;
    Results.Free;
    SearchService.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteListSymbols(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  Symbols: TMNoteCompletionItems;
  OutputObject: TJSONObject;
  SymbolsArray, FailedPathsArray: TJSONArray;
  ItemObj: TJSONObject;
  I, Maximum, MatchCount: Integer;
  NameFilter, KindFilter, PathFilter: string;
  SymName, SymKind, SymPath: string;
  IndexedCount, FailedCount: Integer;
begin
  Result := False;
  AData := nil;
  ATruncated := False;

  Maximum := JSONInteger(AParameters, 'max_results', 200);
  if Maximum < 1 then Maximum := 1;
  if Maximum > 500 then Maximum := 500;

  NameFilter := LowerCase(JSONString(AParameters, 'name_contains', ''));
  KindFilter := LowerCase(JSONString(AParameters, 'kind', ''));
  PathFilter := LowerCase(StringReplace(JSONString(AParameters, 'path_contains', ''), '\', '/', [rfReplaceAll]));

  if not MNoteProjectSymbols.IndexFolder(FRootPath) then
  begin
    AError := 'Não foi possível indexar nenhum arquivo de símbolos do projeto.';
    Exit(False);
  end;
  IndexedCount := MNoteProjectSymbols.IndexedCount + MNoteProjectSymbols.ReusedCount;
  FailedCount := MNoteProjectSymbols.FailedFiles.Count;
  if IndexedCount = 0 then
  begin
    AError := 'Não foi possível indexar nenhum arquivo de símbolos do projeto.';
    Exit(False);
  end;

  Symbols := TMNoteCompletionItems.Create;
  SymbolsArray := TJSONArray.Create;
  FailedPathsArray := TJSONArray.Create;
  try
    for I := 0 to MNoteProjectSymbols.FailedFiles.Count - 1 do
      FailedPathsArray.Add(StringReplace(ExtractRelativePath(
        IncludeTrailingPathDelimiter(FRootPath),
        MNoteProjectSymbols.FailedFiles[I]), '\', '/', [rfReplaceAll]));

    MNoteProjectSymbols.ListSymbols(Symbols, MaxInt);
    MatchCount := 0;

    for I := 0 to Symbols.Count - 1 do
    begin
      SymName := Symbols[I].Text;
      SymKind := CompletionKindName(Symbols[I].Kind);
      SymPath := StringReplace(ExtractRelativePath(IncludeTrailingPathDelimiter(FRootPath), Symbols[I].FileName), '\', '/', [rfReplaceAll]);

      if (NameFilter <> '') and (Pos(NameFilter, LowerCase(SymName)) = 0) then Continue;
      if (KindFilter <> '') and not SameText(KindFilter, SymKind) then Continue;
      if (PathFilter <> '') and (Pos(PathFilter, LowerCase(SymPath)) = 0) then Continue;

      Inc(MatchCount);
      if MatchCount <= Maximum then
      begin
        ItemObj := TJSONObject.Create;
        ItemObj.Add('name', SymName);
        ItemObj.Add('kind', SymKind);
        ItemObj.Add('signature', Symbols[I].Signature);
        ItemObj.Add('path', SymPath);
        ItemObj.Add('line', Symbols[I].Line);
        SymbolsArray.Add(ItemObj);
      end;
    end;

    ATruncated := (MatchCount > Maximum);

    OutputObject := TJSONObject.Create;
    OutputObject.Add('indexed_files', IndexedCount);
    OutputObject.Add('failed_files', FailedCount);
    OutputObject.Add('failed_paths', FailedPathsArray);
    FailedPathsArray := nil;
    OutputObject.Add('total_matches', MatchCount);
    OutputObject.Add('symbols', SymbolsArray);
    SymbolsArray := nil;

    AData := OutputObject;
    Result := True;
  finally
    FailedPathsArray.Free;
    SymbolsArray.Free;
    Symbols.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteFindDefinition(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  TargetName: string;
  Maximum, I, J, MatchCount: Integer;
  Symbols: TMNoteCompletionItems;
  AllHomonyms: TStringList;
  HomonymsArray, OutputArray: TJSONArray;
  ItemObj, OutputObj: TJSONObject;
  SymPath, HomonymStr: string;
begin
  AData := nil;
  ATruncated := False;

  TargetName := JSONString(AParameters, 'name', '');
  if Trim(TargetName) = '' then
  begin
    AError := 'O nome do símbolo é obrigatório.';
    Exit(False);
  end;

  Maximum := JSONInteger(AParameters, 'max_results', 50);
  if Maximum < 1 then Maximum := 1;
  if Maximum > 500 then Maximum := 500;

  if not MNoteProjectSymbols.IndexFolder(FRootPath) then
  begin
    AError := 'Não foi possível indexar nenhum arquivo de símbolos do projeto.';
    Exit(False);
  end;

  Symbols := TMNoteCompletionItems.Create;
  AllHomonyms := TStringList.Create;
  OutputArray := TJSONArray.Create;
  try
    MNoteProjectSymbols.ListSymbols(Symbols, MaxInt);
    MatchCount := 0;

    for I := 0 to Symbols.Count - 1 do
    begin
      if SameText(Symbols[I].Text, TargetName) then
      begin
        SymPath := StringReplace(ExtractRelativePath(IncludeTrailingPathDelimiter(FRootPath), Symbols[I].FileName), '\', '/', [rfReplaceAll]);
        HomonymStr := SymPath + ':' + IntToStr(Symbols[I].Line) + ' (' + Symbols[I].Signature + ')';
        AllHomonyms.Add(HomonymStr);
      end;
    end;

    for I := 0 to Symbols.Count - 1 do
    begin
      if SameText(Symbols[I].Text, TargetName) then
      begin
        Inc(MatchCount);
        if MatchCount <= Maximum then
        begin
          SymPath := StringReplace(ExtractRelativePath(IncludeTrailingPathDelimiter(FRootPath), Symbols[I].FileName), '\', '/', [rfReplaceAll]);
          ItemObj := TJSONObject.Create;
          ItemObj.Add('name', Symbols[I].Text);
          ItemObj.Add('path', SymPath);
          ItemObj.Add('line', Symbols[I].Line);
          ItemObj.Add('kind', CompletionKindName(Symbols[I].Kind));
          ItemObj.Add('signature', Symbols[I].Signature);

          HomonymsArray := TJSONArray.Create;
          for J := 0 to AllHomonyms.Count - 1 do
            HomonymsArray.Add(AllHomonyms[J]);
          ItemObj.Add('all_homonyms', HomonymsArray);

          OutputArray.Add(ItemObj);
        end;
      end;
    end;

    ATruncated := (MatchCount > Maximum);

    OutputObj := TJSONObject.Create;
    OutputObj.Add('name', TargetName);
    OutputObj.Add('total_matches', MatchCount);
    OutputObj.Add('symbols', OutputArray);

    AData := OutputObj;
    Result := True;
  finally
    AllHomonyms.Free;
    Symbols.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteDependencyGraph(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  Service: TMNoteDependencyGraphService;
  UnitNameFilter, DirectionFilter: string;
  OutputObj: TJSONObject;
  EdgesArray, HighestDegreeArray: TJSONArray;
  EdgeObj, UnitObj: TJSONObject;
  I, MaxIndex, MaxDegree: Integer;
  FromNode, ToNode: TAIDependencyNode;
  IncludeEdge: Boolean;
  UnitDegrees: TStringList;
  Deg: Integer;

  procedure CountDegree(AEdge: TAIDependencyEdge);
  var
    LocalFrom, LocalTo: TAIDependencyNode;
  begin
    if (AEdge = nil) or not SameText(AEdge.EdgeType, AIDG_EDGE_USES_UNIT) then
      Exit;
    LocalFrom := Service.Graph.FindNode(AEdge.FromId);
    LocalTo := Service.Graph.FindNode(AEdge.ToId);
    if (LocalFrom <> nil) and SameText(LocalFrom.NodeType, AIDG_NODE_UNIT) then
    begin
      Deg := StrToIntDef(UnitDegrees.Values[LocalFrom.Name], 0);
      UnitDegrees.Values[LocalFrom.Name] := IntToStr(Deg + 1);
    end;
    if (LocalTo <> nil) and SameText(LocalTo.NodeType, AIDG_NODE_UNIT) then
    begin
      Deg := StrToIntDef(UnitDegrees.Values[LocalTo.Name], 0);
      UnitDegrees.Values[LocalTo.Name] := IntToStr(Deg + 1);
    end;
  end;

  procedure AddFilteredEdge(AEdge: TAIDependencyEdge;
    const AOrigin: string);
  begin
    if ATruncated or (AEdge = nil) or
      not SameText(AEdge.EdgeType, AIDG_EDGE_USES_UNIT) then Exit;
    FromNode := Service.Graph.FindNode(AEdge.FromId);
    ToNode := Service.Graph.FindNode(AEdge.ToId);
    if (FromNode = nil) or (ToNode = nil) then Exit;

    IncludeEdge := False;
    if ((DirectionFilter = 'uses') or (DirectionFilter = 'both')) and
      SameText(FromNode.Name, UnitNameFilter) then IncludeEdge := True;
    if ((DirectionFilter = 'used_by') or (DirectionFilter = 'both')) and
      SameText(ToNode.Name, UnitNameFilter) then IncludeEdge := True;
    if not IncludeEdge then Exit;

    EdgeObj := TJSONObject.Create;
    EdgeObj.Add('from', FromNode.Name);
    EdgeObj.Add('to', ToNode.Name);
    EdgeObj.Add('edge_type', AEdge.EdgeType);
    EdgeObj.Add('origin', AOrigin);
    if AOrigin = 'inferred' then
    begin
      EdgeObj.Add('confidence', AEdge.Confidence);
      EdgeObj.Add('source', AEdge.Source);
    end
    else
    begin
      EdgeObj.Add('source_file', AEdge.Evidence.SourceFile);
      EdgeObj.Add('source_line', AEdge.Evidence.Line);
    end;
    if Length(OutputObj.AsJSON) + Length(EdgeObj.AsJSON) + 128 > 20000 then
    begin
      EdgeObj.Free;
      ATruncated := True;
      Exit;
    end;
    EdgesArray.Add(EdgeObj);
  end;
begin
  AData := nil;
  ATruncated := False;

  UnitNameFilter := JSONString(AParameters, 'unit_name', '');
  DirectionFilter := LowerCase(JSONString(AParameters, 'direction', 'both'));
  if (DirectionFilter <> 'uses') and (DirectionFilter <> 'used_by') and
    (DirectionFilter <> 'both') then
  begin
    AError := 'direction deve ser uses, used_by ou both.';
    Exit(False);
  end;

  Service := TMNoteDependencyGraphService.Create;
  try
    if not Service.Build(FRootPath) then
    begin
      AError := 'Não foi possível construir o grafo de dependências: ' +
        Service.LastError;
      Exit(False);
    end;

    OutputObj := TJSONObject.Create;

    if Trim(UnitNameFilter) = '' then
    begin
      OutputObj.Add('total_nodes', Service.Graph.Nodes.Count);
      OutputObj.Add('total_edges', Service.Graph.Edges.Count +
        Service.Graph.InferredEdges.Count);
      OutputObj.Add('factual_edges_count', Service.Graph.Edges.Count);
      OutputObj.Add('inferred_edges_count', Service.Graph.InferredEdges.Count);

      UnitDegrees := TStringList.Create;
      try
        for I := 0 to Service.Graph.Edges.Count - 1 do
          CountDegree(Service.Graph.Edges[I]);
        for I := 0 to Service.Graph.InferredEdges.Count - 1 do
          CountDegree(Service.Graph.InferredEdges[I]);

        HighestDegreeArray := TJSONArray.Create;
        while (UnitDegrees.Count > 0) and (HighestDegreeArray.Count < 10) do
        begin
          MaxIndex := 0;
          MaxDegree := StrToIntDef(UnitDegrees.ValueFromIndex[0], 0);
          for I := 1 to UnitDegrees.Count - 1 do
            if StrToIntDef(UnitDegrees.ValueFromIndex[I], 0) > MaxDegree then
            begin
              MaxIndex := I;
              MaxDegree := StrToIntDef(UnitDegrees.ValueFromIndex[I], 0);
            end;
          UnitObj := TJSONObject.Create;
          UnitObj.Add('unit', UnitDegrees.Names[MaxIndex]);
          UnitObj.Add('degree', MaxDegree);
          HighestDegreeArray.Add(UnitObj);
          UnitDegrees.Delete(MaxIndex);
        end;
        OutputObj.Add('highest_degree_units', HighestDegreeArray);
      finally
        UnitDegrees.Free;
      end;
    end
    else
    begin
      OutputObj.Add('unit_name', UnitNameFilter);
      OutputObj.Add('direction', DirectionFilter);
      EdgesArray := TJSONArray.Create;
      OutputObj.Add('edges', EdgesArray);
      for I := 0 to Service.Graph.Edges.Count - 1 do
        AddFilteredEdge(Service.Graph.Edges[I], 'factual');
      for I := 0 to Service.Graph.InferredEdges.Count - 1 do
        AddFilteredEdge(Service.Graph.InferredEdges[I], 'inferred');
    end;

    AData := OutputObj;
    Result := True;
  finally
    Service.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteBuildDiagnostics(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  SevFilter, PathFilter: string;
  Diagnostics: TMNoteDiagnostics;
  OutputObj: TJSONObject;
  DiagArray: TJSONArray;
  DiagObj: TJSONObject;
  I, MatchCount: Integer;
  SevStr, DiagPath: string;
  IncludeDiag, HasPreviousBuild: Boolean;
begin
  AData := nil;
  ATruncated := False;

  SevFilter := LowerCase(JSONString(AParameters, 'severity', 'all'));
  if (SevFilter <> 'all') and (SevFilter <> 'error') and
    (SevFilter <> 'warning') and (SevFilter <> 'message') then
  begin
    AError := 'severity deve ser all, error, warning ou message.';
    Exit(False);
  end;
  PathFilter := LowerCase(StringReplace(JSONString(AParameters, 'path_contains', ''), '\', '/', [rfReplaceAll]));

  Diagnostics := TMNoteDiagnostics.Create;
  OutputObj := TJSONObject.Create;
  DiagArray := TJSONArray.Create;
  try
    MNoteSnapshotBuildDiagnostics(Diagnostics, HasPreviousBuild);

    MatchCount := 0;
    for I := 0 to Diagnostics.Count - 1 do
    begin
      SevStr := TMNoteDiagnosticParser.SeverityName(Diagnostics[I].Severity);
      DiagPath := StringReplace(Diagnostics[I].FileName, '\', '/', [rfReplaceAll]);

      IncludeDiag := True;
      if (SevFilter <> 'all') and not SameText(SevFilter, SevStr) then IncludeDiag := False;
      if (PathFilter <> '') and (Pos(PathFilter, LowerCase(DiagPath)) = 0) then IncludeDiag := False;

      if IncludeDiag then
      begin
        Inc(MatchCount);
        DiagObj := TJSONObject.Create;
        DiagObj.Add('path', Diagnostics[I].FileName);
        DiagObj.Add('line', Diagnostics[I].Line);
        DiagObj.Add('column', Diagnostics[I].Column);
        DiagObj.Add('severity', SevStr);
        DiagObj.Add('code', Diagnostics[I].Code);
        DiagObj.Add('message', Diagnostics[I].MessageText);
        if Length(DiagArray.AsJSON) + Length(DiagObj.AsJSON) + 512 > 20000 then
        begin
          DiagObj.Free;
          ATruncated := True;
          Continue;
        end;
        DiagArray.Add(DiagObj);
      end;
    end;

    OutputObj.Add('has_previous_build', HasPreviousBuild);
    OutputObj.Add('total_diagnostics', Diagnostics.Count);
    OutputObj.Add('matched_diagnostics', MatchCount);
    OutputObj.Add('diagnostics', DiagArray);

    AData := OutputObj;
    Result := True;
  finally
    Diagnostics.Free;
  end;
end;

function MaskMatches(const AFileName, AMasks: string): Boolean;
var
  Values: TStringList;
  I: Integer;
  Mask, NameValue, MaskValue: string;
begin
  if Trim(AMasks) = '' then Exit(True);
  Result := False;
  Values := TStringList.Create;
  try
    Values.StrictDelimiter := True;
    Values.Delimiter := ';';
    Values.DelimitedText := AMasks;
    NameValue := LowerCase(StringReplace(AFileName, '\', '/', [rfReplaceAll]));
    for I := 0 to Values.Count - 1 do
    begin
      Mask := Trim(Values[I]);
      if Mask = '' then Continue;
      MaskValue := LowerCase(StringReplace(Mask, '\', '/', [rfReplaceAll]));
      if (MaskValue = '*') or (MaskValue = '*.*') or
        ((Length(MaskValue) > 1) and (MaskValue[1] = '*') and
         AnsiEndsStr(Copy(MaskValue, 2, MaxInt), NameValue)) or
        SameText(ExtractFileName(NameValue), MaskValue) then Exit(True);
    end;
  finally
    Values.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteListProjectFiles(
  AParameters: TJSONObject; out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  IncludeMask, ExcludeMask, RootPrefix: string;
  Maximum, Added: Integer;
  Files: TJSONArray;
  Output: TJSONObject;
  procedure Scan(const AFolder: string);
  var
    Search: TSearchRec;
    FullName, RelativeName: string;
  begin
    if ATruncated then Exit;
    if FindFirst(IncludeTrailingPathDelimiter(AFolder) + '*', faAnyFile,
      Search) <> 0 then Exit;
    try
      repeat
        if (Search.Name = '.') or (Search.Name = '..') then Continue;
        FullName := IncludeTrailingPathDelimiter(AFolder) + Search.Name;
        RelativeName := Copy(FullName, Length(RootPrefix) + 1, MaxInt);
        RelativeName := StringReplace(RelativeName, '\', '/', [rfReplaceAll]);
        if (Search.Attr and faDirectory) <> 0 then
        begin
          if SameText(Search.Name, '.git') or SameText(Search.Name, '.mnote') or
            SameText(Search.Name, 'lib') or SameText(Search.Name, 'backup') or
            SameText(Search.Name, 'bin') or
            ((Trim(ExcludeMask) <> '') and
             MaskMatches(RelativeName + '/', ExcludeMask)) then Continue;
          {$IF declared(faSymLink)}
          if (Search.Attr and faSymLink) <> 0 then Continue;
          {$ENDIF}
          Scan(FullName);
        end
        else if MaskMatches(RelativeName, IncludeMask) and
          ((Trim(ExcludeMask) = '') or
           (not MaskMatches(RelativeName, ExcludeMask))) and
          (not IsSensitivePath(RelativeName)) then
        begin
          if (Added >= Maximum) or (Length(Output.AsJSON) >= 19500) then
          begin
            ATruncated := True;
            Exit;
          end;
          Files.Add(TJSONObject.Create(['path', RelativeName,
            'extension', LowerCase(ExtractFileExt(RelativeName)),
            'size', Search.Size]));
          Inc(Added);
        end;
      until FindNext(Search) <> 0;
    finally
      FindClose(Search);
    end;
  end;
begin
  Result := False;
  AData := nil;
  AError := '';
  ATruncated := False;
  IncludeMask := JSONString(AParameters, 'include', '*');
  ExcludeMask := JSONString(AParameters, 'exclude', '');
  if (Pos('..', IncludeMask) > 0) or (Pos(':', IncludeMask) > 0) or
    (Pos('..', ExcludeMask) > 0) or (Pos(':', ExcludeMask) > 0) then
  begin
    AError := 'Máscara de arquivo insegura.';
    Exit;
  end;
  Maximum := JSONInteger(AParameters, 'max_results', 500);
  if Maximum < 1 then Maximum := 1;
  if Maximum > 500 then Maximum := 500;
  if not DirectoryExists(FRootPath) then
  begin
    AError := 'A raiz do projeto não existe.';
    Exit;
  end;
  RootPrefix := IncludeTrailingPathDelimiter(ExpandFileName(FRootPath));
  Output := TJSONObject.Create;
  Files := TJSONArray.Create;
  Output.Add('root', FRootPath);
  Output.Add('files', Files);
  Added := 0;
  try
    Scan(FRootPath);
    Output.Add('count', Added);
    Output.Add('truncated', ATruncated);
    AData := Output;
    Output := nil;
    Result := True;
  finally
    Output.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteGitLog(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  Service: TMNoteGitReadService;
  Output: string;
  Count: Integer;
begin
  AData := nil;
  ATruncated := False;
  Count := JSONInteger(AParameters, 'count', 20);
  Service := TMNoteGitReadService.Create;
  try
    if not Service.ShortLog(FRootPath, Count, Output) then
    begin
      AError := Service.LastError;
      Exit(False);
    end;
    AData := TJSONString.Create(LimitText(Output, 12000, ATruncated));
    Result := True;
  finally
    Service.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteGitDiff(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  Service: TMNoteGitReadService;
  Output: string;
begin
  AData := nil;
  ATruncated := False;
  Service := TMNoteGitReadService.Create;
  try
    if not Service.CommitDiff(FRootPath,
      JSONString(AParameters, 'commit', ''), Output) then
    begin
      AError := Service.LastError;
      Exit(False);
    end;
    AData := TJSONString.Create(LimitText(Output, 24000, ATruncated));
    Result := True;
  finally
    Service.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteDictionary(out AData: TJSONData;
  out ATruncated: Boolean; out AError: string): Boolean;
var
  DictionaryJSON: string;
  SourceData: TJSONData;
  SourceObject, OutputObject: TJSONObject;
  SourceTables, OutputTables: TJSONArray;
  I, OmittedTables: Integer;
begin
  Result := False;
  AData := nil;
  ATruncated := False;
  SourceData := nil;
  OutputObject := nil;
  if not Assigned(FOnGetDictionary) then
  begin
    AError := 'Nenhum dicionário de banco foi gerado nesta sessão.';
    Exit;
  end;
  if not FOnGetDictionary(Self, DictionaryJSON, AError) then Exit;
  if Trim(DictionaryJSON) = '' then
  begin
    AError := 'O cache do dicionário de banco está vazio.';
    Exit;
  end;
  try
    try
      SourceData := GetJSON(DictionaryJSON);
      if not (SourceData is TJSONObject) then
      begin
        AError := 'O cache do dicionário não contém um objeto JSON.';
        Exit;
      end;
      SourceObject := TJSONObject(SourceData);
      if not (SourceObject.Find('tables') is TJSONArray) then
      begin
        AError := 'O cache do dicionário não contém a lista de tabelas.';
        Exit;
      end;
      SourceTables := SourceObject.Arrays['tables'];
      OutputObject := TJSONObject.Create;
      OutputObject.Add('engine', JSONString(SourceObject, 'engine', ''));
      OutputObject.Add('schema', JSONString(SourceObject, 'schema', ''));
      OutputObject.Add('database', JSONString(SourceObject, 'database', ''));
      OutputTables := TJSONArray.Create;
      OutputObject.Add('tables', OutputTables);
      OmittedTables := 0;
      for I := 0 to SourceTables.Count - 1 do
        if Length(OutputObject.AsJSON) + Length(SourceTables.Items[I].AsJSON) +
          256 <= 24000 then
          OutputTables.Add(SourceTables.Items[I].Clone)
        else
          Inc(OmittedTables);
      OutputObject.Add('omitted_tables', OmittedTables);
      OutputObject.Add('truncated_by_table', OmittedTables > 0);
      ATruncated := OmittedTables > 0;
      AData := OutputObject;
      OutputObject := nil;
    except
      on E: Exception do
        AError := 'O cache do dicionário não contém JSON válido: ' + E.Message;
    end;
  finally
    OutputObject.Free;
    SourceData.Free;
  end;
  if AData = nil then Exit;
  Result := True;
end;

function TMNoteAIActionExecutor.ExecuteCompile(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  Build: TMNoteBuildService;
  Arguments: TStringList;
  ExecutableName, WorkingDirectory, Output, LimitedOutput: string;
  Diagnostics: TMNoteDiagnostics;
  OutputObject, DiagnosticObject: TJSONObject;
  DiagnosticArray: TJSONArray;
  I, DiagnosticCount, TotalErrors: Integer;
  FirstErrorMsg: string;
begin
  Result := False;
  AData := nil;
  ATruncated := False;
  Build := TMNoteBuildService.Create;
  Arguments := TStringList.Create;
  Diagnostics := TMNoteDiagnostics.Create;
  try
    if not Build.Prepare(FRootPath,
      JSONBoolean(AParameters, 'rebuild', False), ExecutableName,
      WorkingDirectory, Arguments, AError) then Exit;
    if not FProcess.Execute(ExecutableName, Arguments, WorkingDirectory,
      10 * 60 * 1000) then AError := FProcess.LastError;
    Output := FProcess.StdOut + FProcess.StdErr;
    LimitedOutput := LimitText(Output, 30000, ATruncated);
    TMNoteDiagnosticParser.Parse(Output, 'AI Compile', Diagnostics);
    OutputObject := TJSONObject.Create;
    OutputObject.Add('exit_code', FProcess.ExitCode);
    OutputObject.Add('timed_out', FProcess.TimedOut);
    OutputObject.Add('cancelled', FProcess.WasCancelled);
    OutputObject.Add('output', LimitedOutput);
    DiagnosticArray := TJSONArray.Create;
    DiagnosticCount := Diagnostics.Count;
    if DiagnosticCount > 200 then
    begin
      DiagnosticCount := 200;
      ATruncated := True;
    end;

    FirstErrorMsg := '';
    TotalErrors := 0;
    for I := 0 to Diagnostics.Count - 1 do
    begin
      if Diagnostics[I].Severity = mdsError then
      begin
        Inc(TotalErrors);
        if FirstErrorMsg = '' then FirstErrorMsg := Diagnostics[I].MessageText;
      end;
      if I < DiagnosticCount then
      begin
        DiagnosticObject := TJSONObject.Create;
        DiagnosticObject.Add('path', Diagnostics[I].FileName);
        DiagnosticObject.Add('line', Diagnostics[I].Line);
        DiagnosticObject.Add('column', Diagnostics[I].Column);
        DiagnosticObject.Add('severity',
          TMNoteDiagnosticParser.SeverityName(Diagnostics[I].Severity));
        DiagnosticObject.Add('code', Diagnostics[I].Code);
        DiagnosticObject.Add('message', Diagnostics[I].MessageText);
        DiagnosticArray.Add(DiagnosticObject);
      end;
    end;

    if FirstErrorMsg = '' then FirstErrorMsg := FProcess.LastError;
    if FirstErrorMsg = '' then FirstErrorMsg := 'ExitCode ' + IntToStr(FProcess.ExitCode);

    OutputObject.Add('ok', FProcess.ExitCode = 0);
    OutputObject.Add('first_error', FirstErrorMsg);
    OutputObject.Add('total_errors', TotalErrors);
    OutputObject.Add('diagnostics', DiagnosticArray);
    MNoteRememberBuildDiagnostics(Diagnostics);
    AData := OutputObject;
    Result := (FProcess.ExitCode = 0);
    if Result then AError := ''
    else AError := 'Compilação com falhas. Primeiro erro: ' + FirstErrorMsg;
  finally
    Diagnostics.Free;
    Arguments.Free;
    Build.Free;
  end;
end;

function TMNoteAIActionExecutor.ResultJSON(const AAction: string; ASuccess,
  ATruncated: Boolean; AData: TJSONData; const AError: string): string;
var
  Output: TJSONObject;
begin
  Output := TJSONObject.Create;
  try
    Output.Add('ok', ASuccess);
    Output.Add('action', AAction);
    Output.Add('simulated', False);
    Output.Add('truncated', ATruncated);
    if AData <> nil then Output.Add('data', AData)
    else Output.Add('data', TJSONNull.Create);
    if AError <> '' then Output.Add('error', AError);
    Result := Output.AsJSON;
  finally
    Output.Free;
  end;
end;

procedure TMNoteAIActionExecutor.LogResult(const AAction: string;
  ARole: TMNoteAIRole; ASuccess, ATruncated: Boolean; const AError: string);
var
  LogObject: TJSONObject;
begin
  if not Assigned(FOnLog) then Exit;
  LogObject := TJSONObject.Create;
  try
    LogObject.Add('action', AAction);
    LogObject.Add('role', MNoteAIRoleID(ARole));
    LogObject.Add('ok', ASuccess);
    LogObject.Add('truncated', ATruncated);
    if AError <> '' then LogObject.Add('error', AError);
    FOnLog(Self, LogObject.AsJSON);
  finally
    LogObject.Free;
  end;
end;

function TMNoteAIActionExecutor.DescribeActions(
  AReadOnlyOnly: Boolean): string;
var
  Output: TJSONArray;
  ActionObject: TJSONObject;
  ParameterArray: TJSONArray;
  Descriptor: TMNoteAIActionDescriptor;
  I, J: Integer;
begin
  Output := TJSONArray.Create;
  try
    for I := 0 to FActions.Count - 1 do
    begin
      Descriptor := TMNoteAIActionDescriptor(FActions[I]);
      if AReadOnlyOnly and (Descriptor.Effect <> aaeReadOnly) then Continue;
      ActionObject := TJSONObject.Create;
      ActionObject.Add('name', Descriptor.Name);
      ActionObject.Add('effect', MNoteAIActionEffectName(Descriptor.Effect));
      ActionObject.Add('requires_confirmation',
        Descriptor.RequiresConfirmation);
      ActionObject.Add('max_output_chars', Descriptor.MaxOutputChars);
      ParameterArray := TJSONArray.Create;
      for J := 0 to Descriptor.Parameters.Count - 1 do
        ParameterArray.Add(Descriptor.Parameters[J]);
      ActionObject.Add('parameters', ParameterArray);
      Output.Add(ActionObject);
    end;
    Result := Output.AsJSON;
  finally
    Output.Free;
  end;
end;

function TMNoteAIActionExecutor.ActionIsReadOnly(
  const AName: string): Boolean;
var
  Descriptor: TMNoteAIActionDescriptor;
begin
  Descriptor := FindAction(AName);
  Result := (Descriptor <> nil) and (Descriptor.Effect = aaeReadOnly);
end;

function TMNoteAIActionExecutor.ValidateRequestContract(
  const ARequestJSON: string; out AActionName, AError: string): Boolean;
var
  Descriptor: TMNoteAIActionDescriptor;
  Parameters: TJSONObject;
  Data: TJSONData;
begin
  AActionName := '';
  Data := nil;
  Result := ParseRequest(ARequestJSON, Descriptor, Parameters, Data, AError);
  if Result then AActionName := Descriptor.Name;
  Data.Free;
end;

function TMNoteAIActionExecutor.ExecuteRequest(const ARequestJSON: string;
  ARole: TMNoteAIRole; out AResultJSON, AError: string): Boolean;
var
  Descriptor: TMNoteAIActionDescriptor;
  Parameters: TJSONObject;
  RequestData, ResultData: TJSONData;
  Truncated: Boolean;
  ConfirmationReason: string;
  SafetyParams: TStringList;
  I: Integer;
  PName, PVal: string;
begin
  Result := False;
  FLastErrorIsContract := False;
  Truncated := False;
  AResultJSON := '';
  AError := '';
  ResultData := nil;
  if not ParseRequest(ARequestJSON, Descriptor, Parameters, RequestData,
    AError) then
  begin
    FLastErrorIsContract := True;
    AResultJSON := ResultJSON('', False, False, nil, AError);
    Exit;
  end;
  try
    SafetyParams := TStringList.Create;
    try
      if Parameters <> nil then
        for I := 0 to Parameters.Count - 1 do
        begin
          PName := Parameters.Names[I];
          PVal := Parameters.Items[I].AsString;
          if (SameText(PName, 'path') or SameText(PName, 'file')) and (Trim(PVal) <> '') then
          begin
            if ExtractFileDrive(PVal) <> '' then PVal := ExpandFileName(PVal)
            else PVal := ExpandFileName(IncludeTrailingPathDelimiter(FRootPath) + PVal);
          end;
          SafetyParams.Add(PName + '=' + PVal);
        end;

      if not RoleMayExecute(ARole, Descriptor) then
        AError := 'O papel ' + MNoteAIRoleName(ARole) +
          ' não tem permissão para executar ' + Descriptor.Name + '.'
      else if not FSafety.ValidateAction(Descriptor.Name, SafetyParams, AError) then
        AError := 'Agent Safety: ' + AError
      else if Descriptor.Effect in [aaeSourceWrite, aaeExternalWrite] then
        AError := 'Alterações de fonte e efeitos externos só podem passar pela revisão de Changes.'
      else if Descriptor.RequiresConfirmation and
        ((not Assigned(FOnConfirm)) or
         (not FOnConfirm(Self, Descriptor, Parameters, ConfirmationReason))) then
      begin
        if ConfirmationReason = '' then
          ConfirmationReason := 'A execução não foi confirmada pelo usuário.';
        AError := ConfirmationReason;
      end;
    finally
      SafetyParams.Free;
    end;

    if AError = '' then
    begin
      if SameText(Descriptor.Name, 'ReadFile') then
        Result := ExecuteReadFile(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'FileOutline') then
        Result := ExecuteFileOutline(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'SearchProject') then
        Result := ExecuteSearchProject(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'ListSymbols') then
        Result := ExecuteListSymbols(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'FindDefinition') then
        Result := ExecuteFindDefinition(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'DependencyGraph') then
        Result := ExecuteDependencyGraph(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'BuildDiagnostics') then
        Result := ExecuteBuildDiagnostics(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'ListProjectFiles') then
        Result := ExecuteListProjectFiles(Parameters, ResultData, Truncated,
          AError)
      else if SameText(Descriptor.Name, 'GitLog') then
        Result := ExecuteGitLog(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'GitDiff') then
        Result := ExecuteGitDiff(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'DBDictionary') then
        Result := ExecuteDictionary(ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'Compile') then
        Result := ExecuteCompile(Parameters, ResultData, Truncated, AError);
    end;
    AResultJSON := ResultJSON(Descriptor.Name, Result, Truncated,
      ResultData, AError);
    ResultData := nil;
    LogResult(Descriptor.Name, ARole, Result, Truncated, AError);
  finally
    ResultData.Free;
    RequestData.Free;
  end;
end;

procedure TMNoteAIActionExecutor.Cancel;
begin
  FProcess.Cancel;
end;

end.
