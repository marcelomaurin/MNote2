unit mnote_token_usage;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

type
  TMNoteTokenUsage = class
  public
    class function ExtractPromptTokens(const AJSON: string;
      out ATokens: Integer; out AUsageField: string): Boolean; static;
  end;

implementation

uses
  SysUtils, fpjson, jsonparser;

function JSONIntegerAt(AData: TJSONData; const APath: string;
  out AValue: Integer): Boolean;
var
  Item: TJSONData;
begin
  Result := False;
  if AData = nil then Exit;
  Item := AData.FindPath(APath);
  if Item = nil then Exit;
  try
    AValue := Item.AsInteger;
    Result := AValue > 0;
  except
    Result := False;
  end;
end;

class function TMNoteTokenUsage.ExtractPromptTokens(const AJSON: string;
  out ATokens: Integer; out AUsageField: string): Boolean;
const
  Fields: array[0..3] of string = ('usage.prompt_tokens',
    'usageMetadata.promptTokenCount', 'usage.input_tokens',
    'prompt_eval_count');
var
  Data: TJSONData;
  I: Integer;
begin
  Result := False;
  ATokens := 0;
  AUsageField := '';
  if Trim(AJSON) = '' then Exit;
  Data := nil;
  try
    try
      Data := GetJSON(AJSON);
      for I := Low(Fields) to High(Fields) do
        if JSONIntegerAt(Data, Fields[I], ATokens) then
        begin
          AUsageField := Fields[I];
          Exit(True);
        end;
    except
      Result := False;
    end;
  finally
    Data.Free;
  end;
end;

end.
