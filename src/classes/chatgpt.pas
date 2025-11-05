unit chatgpt;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LazUTF8, fpjson, jsonparser,
  fphttpclient, opensslsockets, funcoes;

{ TCHATGPT }

type
  TVersionChat = (VCT_GPT35TURBO, VCT_GPT40, VCT_GPT40_TURBO,
                  VCT_GPT4o, VCT_GPTo3_mini, VCT_GPT41,
                  VCT_GPT41_MINI, VCT_GPT5);

  // Class to connect with ChatGPT
  TCHATGPT = class(TComponent)
  private
    FToken     : WideString;
    FQuestion  : WideString;
    FResponse  : WideString;
    FDev       : WideString;
    FTipoChat  : TVersionChat;
    FParams    : TStrings;

    function RequestJson(LURL: WideString; token: WideString; ASK: WideString): WideString;
    function PegaMensagem(const JSON: WideString): WideString;

  public
    property TOKEN: WideString read FToken write FToken;
    property Question: WideString read FQuestion;
    property Response: WideString read FResponse write FResponse;
    property TipoChat: TVersionChat read FTipoChat;
    property Dev: WideString read FDev write FDev;

    function SendQuestion(ASK: WideString): Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function TipoModelo: WideString;
  end;

implementation

function JsonEscape(const S: WideString): WideString;
var
  R: WideString;
begin
  R := StringReplace(S, '\', '\\', [rfReplaceAll]);
  R := StringReplace(R, '"', '\"', [rfReplaceAll]);
  R := StringReplace(R, #13#10, '\n', [rfReplaceAll]);
  R := StringReplace(R, #10, '\n', [rfReplaceAll]);
  R := StringReplace(R, #13, '\n', [rfReplaceAll]);
  Result := R;
end;

function TCHATGPT.PegaMensagem(const JSON: WideString): WideString;
var
  CleanJSON: WideString;
  Data: TJSONData;
  JsonObject, MessageObject: TJSONObject;
  ChoicesArray: TJSONArray;
  ContentData: TJSONData;
  Parser: TJSONParser;
begin
  CleanJSON := StringReplace(JSON, '#$0A', '', [rfReplaceAll]);
  Result := '';
  Parser := TJSONParser.Create(CleanJSON);
  try
    Data := Parser.Parse;
    if Data.JSONType = jtObject then
    begin
      JsonObject := TJSONObject(Data);
      if JsonObject.Find('choices', ChoicesArray) then
      begin
        if (ChoicesArray <> nil) and (ChoicesArray.Count > 0) then
        begin
          if ChoicesArray.Items[0].JSONType = jtObject then
          begin
            MessageObject := ChoicesArray.Objects[0].FindPath('message') as TJSONObject;
            if MessageObject <> nil then
            begin
              ContentData := MessageObject.Find('content');
              if (ContentData <> nil) and (ContentData.JSONType = jtString) then
                Result := ContentData.AsString;
            end;
          end;
        end;
      end;
    end;
  finally
    Parser.Free;
  end;
end;

function TCHATGPT.RequestJson(LURL: WideString; token: WideString; ASK: WideString): WideString;
var
  ClienteHTTP: TFPHttpClient;
  BodyStream: TStringStream;
  tipo: WideString;
  root, mSys, mUser: TJSONObject;
  msgs: TJSONArray;
  payload: WideString;
begin
  case FTipoChat of
    VCT_GPT35TURBO: tipo := 'gpt-3.5-turbo';
    VCT_GPT40: tipo := 'gpt-4';
    VCT_GPT40_TURBO: tipo := 'gpt-4-turbo-preview';
    VCT_GPT4o: tipo := 'gpt-4o';
    VCT_GPTo3_mini: tipo := 'gpt-o3-mini';
    VCT_GPT41: tipo := 'gpt-4.1';
    VCT_GPT41_MINI: tipo := 'gpt-4.1-mini';
    VCT_GPT5: tipo := 'gpt-5';
  else
    tipo := 'gpt-4.1-mini';
  end;

  root := TJSONObject.Create;
  try
    root.Add('model', tipo);
    msgs := TJSONArray.Create;
    root.Add('messages', msgs);

    mSys := TJSONObject.Create;
    mSys.Add('role', 'system');
    mSys.Add('content', FDev);
    msgs.Add(mSys);

    mUser := TJSONObject.Create;
    mUser.Add('role', 'user');
    mUser.Add('content', ASK);
    msgs.Add(mUser);

    payload := root.AsJSON;
  finally
    root.Free;
  end;

  ClienteHTTP := TFPHttpClient.Create(nil);
  BodyStream := TStringStream.Create(payload, TEncoding.UTF8);
  try
    ClienteHTTP.AddHeader('Content-Type', 'application/json');
    ClienteHTTP.AddHeader('Accept', 'application/json');
    ClienteHTTP.AddHeader('Authorization', 'Bearer ' + token);
    ClienteHTTP.AllowRedirect := True;
    ClienteHTTP.KeepConnection := True;
    ClienteHTTP.IOTimeout := 60000;
    ClienteHTTP.ConnectTimeout := 60000;
    ClienteHTTP.RequestBody := BodyStream;

    try
      Result := ClienteHTTP.Post(LURL);
    except
      on E: Exception do
        Result := Format('{"error":{"message":"%s"}}',
                  [StringReplace(E.Message, '"', '\"', [rfReplaceAll])]);
    end;
  finally
    BodyStream.Free;
    ClienteHTTP.Free;
  end;
end;

function TCHATGPT.SendQuestion(ASK: WideString): Boolean;
var
  LURL, AUX: WideString;
begin
  Result := False;
  LURL := 'https://api.openai.com/v1/chat/completions';
  AUX := RequestJson(LURL, FToken, ASK);

  if Pos('"error"', AUX) > 0 then
  begin
    FResponse := AUX;
    Exit(False);
  end;

  try
    FResponse := PegaMensagem(AUX);
    Result := (Trim(FResponse) <> '');
    if not Result then
      FResponse := AUX;
  except
    FResponse := AUX;
    Result := False;
  end;
end;

constructor TCHATGPT.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTipoChat := VCT_GPT41_MINI;
  FDev := 'Você é um assistente.';
  FParams := TStringList.Create;
end;

destructor TCHATGPT.Destroy;
begin
  FParams.Free;
  inherited;
end;

function TCHATGPT.TipoModelo: WideString;
begin
  case FTipoChat of
    VCT_GPT35TURBO: Result := '"gpt-3.5-turbo"';
    VCT_GPT40: Result := '"gpt-4"';
    VCT_GPT40_TURBO: Result := '"gpt-4-turbo-preview"';
    VCT_GPT4o: Result := '"gpt-4o"';
    VCT_GPTo3_mini: Result := '"gpt-o3-mini"';
    VCT_GPT41: Result := '"gpt-4.1"';
    VCT_GPT41_MINI: Result := '"gpt-4.1-mini"';
    VCT_GPT5: Result := '"gpt-5"';
  else
    Result := '"gpt-4.1-mini"';
  end;
end;

end.

