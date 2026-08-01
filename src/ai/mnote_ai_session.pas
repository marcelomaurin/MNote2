unit mnote_ai_session;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs, fpjson, jsonparser, mnote_ai_types;

type
  { TMNoteAISessionStep }

  TMNoteAISessionStep = class
  public
    Order: Integer;
    ParentOrder: Integer;
    Role: TMNoteAIRole;
    Kind: string;
    Status: string;
    EstimatedInput: Integer;
    EstimatedOutput: Integer;
    Budget: Integer;
    LatencyMS: QWord;
    Attempt: Integer;
    ErrorText: string;
    InputSummary: string;
    OutputSummary: string;
    Fingerprint: string;
    function ToJSON: TJSONObject;
  end;

  TMNoteAISessionChangedEvent = procedure(Sender: TObject) of object;

  { TMNoteAISession }

  TMNoteAISession = class(TObjectList)
  private
    FSessionID: string;
    FStartedAt: TDateTime;
    FOnChanged: TMNoteAISessionChangedEvent;
    function GetStep(AIndex: Integer): TMNoteAISessionStep;
    class function Redact(const AText: string): string; static;
  public
    constructor Create;
    function AddStep(ARole: TMNoteAIRole; const AKind: string;
      AParentOrder, AEstimatedInput, AEstimatedOutput, ABudget,
      AAttempt: Integer; const AInputSummary, AFingerprint: string):
      TMNoteAISessionStep;
    procedure FinishStep(AStep: TMNoteAISessionStep; const AStatus,
      AOutputSummary, AError: string; ALatencyMS: QWord);
    function AsJSON: string;
    function LoadJSON(const AJSON: string): Boolean;
    procedure SaveToFile(const AFileName: string);
    procedure LoadFromFile(const AFileName: string);
    property SessionID: string read FSessionID;
    property StartedAt: TDateTime read FStartedAt;
    property Steps[AIndex: Integer]: TMNoteAISessionStep read GetStep; default;
    property OnChanged: TMNoteAISessionChangedEvent read FOnChanged
      write FOnChanged;
  end;

implementation

function TMNoteAISessionStep.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.Add('order', Order);
  Result.Add('parent_order', ParentOrder);
  Result.Add('role', MNoteAIRoleID(Role));
  Result.Add('kind', Kind);
  Result.Add('status', Status);
  Result.Add('estimated_input', EstimatedInput);
  Result.Add('estimated_output', EstimatedOutput);
  Result.Add('budget', Budget);
  Result.Add('latency_ms', Int64(LatencyMS));
  Result.Add('attempt', Attempt);
  Result.Add('error', ErrorText);
  Result.Add('input_summary', InputSummary);
  Result.Add('output_summary', OutputSummary);
  Result.Add('fingerprint', Fingerprint);
end;

constructor TMNoteAISession.Create;
begin
  inherited Create(True);
  FStartedAt := Now;
  FSessionID := FormatDateTime('yyyymmddhhnnsszzz', FStartedAt) + '-' +
    IntToHex(Random(MaxInt), 8);
end;

function TMNoteAISession.GetStep(AIndex: Integer): TMNoteAISessionStep;
begin
  Result := TMNoteAISessionStep(inherited Items[AIndex]);
end;

class function TMNoteAISession.Redact(const AText: string): string;
var
  Lower: string;
  AtPos, EndPos: Integer;
begin
  Result := Copy(AText, 1, 500);
  Lower := LowerCase(Result);
  for AtPos := 1 to Length(Lower) do
    if (Copy(Lower, AtPos, 6) = 'token=') or
      (Copy(Lower, AtPos, 9) = 'password=') or
      (Copy(Lower, AtPos, 8) = 'api_key=') then
    begin
      EndPos := AtPos;
      while (EndPos <= Length(Result)) and
        not (Result[EndPos] in [#9, #10, #13, ' ', ';', '&']) do Inc(EndPos);
      System.Delete(Result, AtPos, EndPos - AtPos);
      System.Insert('[redigido]', Result, AtPos);
      Lower := LowerCase(Result);
    end;
end;

function TMNoteAISession.AddStep(ARole: TMNoteAIRole; const AKind: string;
  AParentOrder, AEstimatedInput, AEstimatedOutput, ABudget, AAttempt: Integer;
  const AInputSummary, AFingerprint: string): TMNoteAISessionStep;
begin
  Result := TMNoteAISessionStep.Create;
  Result.Order := Count + 1;
  Result.ParentOrder := AParentOrder;
  Result.Role := ARole;
  Result.Kind := AKind;
  Result.Status := 'running';
  Result.EstimatedInput := AEstimatedInput;
  Result.EstimatedOutput := AEstimatedOutput;
  Result.Budget := ABudget;
  Result.Attempt := AAttempt;
  Result.InputSummary := Redact(AInputSummary);
  Result.Fingerprint := AFingerprint;
  Add(Result);
  if Assigned(FOnChanged) then FOnChanged(Self);
end;

procedure TMNoteAISession.FinishStep(AStep: TMNoteAISessionStep;
  const AStatus, AOutputSummary, AError: string; ALatencyMS: QWord);
begin
  if AStep = nil then Exit;
  AStep.Status := AStatus;
  AStep.OutputSummary := Redact(AOutputSummary);
  AStep.ErrorText := Redact(AError);
  AStep.LatencyMS := ALatencyMS;
  if Assigned(FOnChanged) then FOnChanged(Self);
end;

function TMNoteAISession.AsJSON: string;
var
  Root: TJSONObject;
  ArrayData: TJSONArray;
  I: Integer;
begin
  Root := TJSONObject.Create;
  try
    Root.Add('schema_version', 1);
    Root.Add('session_id', FSessionID);
    Root.Add('started_at', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', FStartedAt));
    ArrayData := TJSONArray.Create;
    Root.Add('steps', ArrayData);
    for I := 0 to Count - 1 do ArrayData.Add(Steps[I].ToJSON);
    Result := Root.FormatJSON;
  finally
    Root.Free;
  end;
end;

function JSONInt(AObject: TJSONObject; const AName: string): Integer;
begin
  if AObject.Find(AName) <> nil then Result := AObject.Integers[AName]
  else Result := 0;
end;

function JSONStr(AObject: TJSONObject; const AName: string): string;
begin
  if AObject.Find(AName) <> nil then Result := AObject.Strings[AName]
  else Result := '';
end;

function TMNoteAISession.LoadJSON(const AJSON: string): Boolean;
var
  Data: TJSONData;
  Root, ItemObject: TJSONObject;
  ArrayData: TJSONArray;
  I: Integer;
  Item: TMNoteAISessionStep;
  ParsedRole: TMNoteAIRole;
begin
  Result := False;
  Data := nil;
  try
    Data := GetJSON(AJSON);
    if not (Data is TJSONObject) then Exit;
    Root := TJSONObject(Data);
    if not (Root.Find('steps') is TJSONArray) then Exit;
    FSessionID := JSONStr(Root, 'session_id');
    ArrayData := TJSONArray(Root.Find('steps'));
    Clear;
    for I := 0 to ArrayData.Count - 1 do
    begin
      if not (ArrayData.Items[I] is TJSONObject) then Exit;
      ItemObject := TJSONObject(ArrayData.Items[I]);
      if not MNoteAIRoleFromID(JSONStr(ItemObject, 'role'), ParsedRole) then Exit;
      Item := TMNoteAISessionStep.Create;
      Item.Order := JSONInt(ItemObject, 'order');
      Item.ParentOrder := JSONInt(ItemObject, 'parent_order');
      Item.Role := ParsedRole;
      Item.Kind := JSONStr(ItemObject, 'kind');
      Item.Status := JSONStr(ItemObject, 'status');
      Item.EstimatedInput := JSONInt(ItemObject, 'estimated_input');
      Item.EstimatedOutput := JSONInt(ItemObject, 'estimated_output');
      Item.Budget := JSONInt(ItemObject, 'budget');
      Item.LatencyMS := QWord(JSONInt(ItemObject, 'latency_ms'));
      Item.Attempt := JSONInt(ItemObject, 'attempt');
      Item.ErrorText := Redact(JSONStr(ItemObject, 'error'));
      Item.InputSummary := Redact(JSONStr(ItemObject, 'input_summary'));
      Item.OutputSummary := Redact(JSONStr(ItemObject, 'output_summary'));
      Item.Fingerprint := JSONStr(ItemObject, 'fingerprint');
      Add(Item);
    end;
    Result := True;
  except
    Result := False;
  end;
  Data.Free;
  if Result and Assigned(FOnChanged) then FOnChanged(Self);
end;

procedure TMNoteAISession.SaveToFile(const AFileName: string);
var
  Lines: TStringList;
begin
  ForceDirectories(ExtractFilePath(AFileName));
  Lines := TStringList.Create;
  try
    Lines.Text := AsJSON;
    Lines.SaveToFile(AFileName);
  finally
    Lines.Free;
  end;
end;

procedure TMNoteAISession.LoadFromFile(const AFileName: string);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFileName);
    if not LoadJSON(Lines.Text) then
      raise Exception.Create('Sessão de IA inválida.');
  finally
    Lines.Free;
  end;
end;

end.
