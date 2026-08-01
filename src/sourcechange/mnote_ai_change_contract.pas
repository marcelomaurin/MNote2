unit mnote_ai_change_contract;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, mnote_source_change_types,
  mnote_source_change_manager;

type
  TMNoteAIContractErrorClass = (aceNone, aceInvalidContract, aceSafety,
    aceHash, aceInfrastructure);

  TMNoteAIChangeContract = class
  public
    class function Parse(const AJSON: string; AManager: TAISourceChangeManager;
      out AChangeSet: TAISourceChangeSet; out AError: string): Boolean; static;
    class function MayRetry(AErrorClass: TMNoteAIContractErrorClass;
      AAttempt: Integer): Boolean; static;
  end;

implementation

function HasOnlyKeys(AObject: TJSONObject; const AAllowed: array of string;
  out AUnknown: string): Boolean;
var
  I, J: Integer;
  Found: Boolean;
begin
  Result := False;
  for I := 0 to AObject.Count - 1 do
  begin
    Found := False;
    for J := Low(AAllowed) to High(AAllowed) do
      if SameText(AObject.Names[I], AAllowed[J]) then begin Found := True; Break; end;
    if not Found then begin AUnknown := AObject.Names[I]; Exit; end;
  end;
  Result := True;
end;

class function TMNoteAIChangeContract.Parse(const AJSON: string;
  AManager: TAISourceChangeManager; out AChangeSet: TAISourceChangeSet;
  out AError: string): Boolean;
var
  Data: TJSONData;
  Root, Operation: TJSONObject;
  Operations: TJSONArray;
  Candidate: TAISourceChangeSet;
  I: Integer;
  Kind, FileName, Unknown: string;
begin
  Result := False;
  AChangeSet := nil;
  AError := '';
  Data := nil;
  Candidate := nil;
  try
    try
    if Trim(AJSON) <> AJSON then
    begin AError := 'A resposta deve conter somente JSON, sem texto externo.'; Exit; end;
    Data := GetJSON(AJSON);
    if not (Data is TJSONObject) then
    begin AError := 'A raiz deve ser um objeto JSON.'; Exit; end;
    Root := TJSONObject(Data);
    if not HasOnlyKeys(Root, ['task_id', 'request', 'model', 'changes'], Unknown) then
    begin AError := 'Campo raiz desconhecido: ' + Unknown; Exit; end;
    if not (Root.Find('changes') is TJSONArray) then
    begin AError := 'Campo obrigatório changes ausente.'; Exit; end;
    Operations := Root.Arrays['changes'];
    if Operations.Count = 0 then
    begin AError := 'O contrato não contém operações.'; Exit; end;
    Candidate := TAISourceChangeSet.Create;
    Candidate.TaskID := Root.Get('task_id', '');
    Candidate.RequestText := Root.Get('request', '');
    Candidate.ModelName := Root.Get('model', '');
    Candidate.Origin := 'AI';
    for I := 0 to Operations.Count - 1 do
    begin
      if not (Operations.Items[I] is TJSONObject) then
      begin AError := 'Operação ' + IntToStr(I + 1) + ' não é objeto.'; Exit; end;
      Operation := Operations.Objects[I];
      if not HasOnlyKeys(Operation, ['kind', 'file', 'expected_text',
        'new_text', 'expected_count', 'start_line', 'end_line', 'content'],
        Unknown) then
      begin AError := 'Campo crítico desconhecido na operação: ' + Unknown; Exit; end;
      Kind := Operation.Get('kind', '');
      FileName := Operation.Get('file', '');
      if (Kind = '') or (FileName = '') then
      begin AError := 'Operação sem kind ou file.'; Exit; end;
      if SameText(Kind, 'exact_replace') then
      begin
        if (Operation.IndexOfName('expected_text') < 0) or
          (Operation.IndexOfName('new_text') < 0) or
          (Operation.Get('expected_count', 0) < 1) then
        begin AError := 'exact_replace exige expected_text, new_text e expected_count.'; Exit; end;
        if AManager.ProposeExactReplace(Candidate, FileName,
          Operation.Get('expected_text', ''), Operation.Get('new_text', ''),
          Operation.Get('expected_count', 0)) = nil then
        begin AError := AManager.LastError; Exit; end;
      end
      else if SameText(Kind, 'line_range') then
      begin
        if (Operation.IndexOfName('expected_text') < 0) or
          (Operation.IndexOfName('new_text') < 0) then
        begin AError := 'line_range exige texto esperado e novo.'; Exit; end;
        if AManager.ProposeLineRange(Candidate, FileName,
          Operation.Get('start_line', 0), Operation.Get('end_line', 0),
          Operation.Get('expected_text', ''), Operation.Get('new_text', '')) = nil then
        begin AError := AManager.LastError; Exit; end;
      end
      else if SameText(Kind, 'new_file') then
      begin
        if Operation.IndexOfName('content') < 0 then
        begin AError := 'new_file exige content.'; Exit; end;
        if AManager.ProposeNewFile(Candidate, FileName,
          Operation.Get('content', '')) = nil then
        begin AError := AManager.LastError; Exit; end;
      end
      else begin AError := 'Tipo de operação não registrado: ' + Kind; Exit; end;
    end;
    AChangeSet := Candidate;
    Candidate := nil;
    Result := True;
    except
      on E: Exception do AError := 'JSON inválido: ' + E.Message;
    end;
  finally
    Candidate.Free;
    Data.Free;
  end;
end;

class function TMNoteAIChangeContract.MayRetry(
  AErrorClass: TMNoteAIContractErrorClass; AAttempt: Integer): Boolean;
begin
  Result := (AErrorClass = aceInvalidContract) and (AAttempt = 0);
end;

end.
