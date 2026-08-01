unit antigravity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LazUTF8, fpjson, jsonparser,
  fphttpclient, opensslsockets, funcoes, setmain;

const
  ANTIGRAVITY_LIB_VERSION = '1.0';

type
  TVersionAntigravity = (
    VAT_GEMINI_1_5_FLASH,
    VAT_GEMINI_1_5_PRO,
    VAT_GEMINI_2_0_FLASH,
    VAT_GEMINI_2_0_PRO,
    VAT_GEMINI_2_5_FLASH,
    VAT_GEMINI_3_5_FLASH,
    VAT_CUSTOM
  );

  { TAntigravity }

  TAntigravity = class(TComponent)
  private
    FToken           : WideString;
    FQuestion        : WideString;
    FResponse        : WideString;
    FDev             : WideString;
    FTipoChat        : TVersionAntigravity;
    FParams          : TStrings;
    FCustomModel     : WideString;
    FLastJSON        : WideString;

    function RequestJson(const LURL, ASK: WideString): WideString;
    function PegaMensagem(const JSON: WideString): WideString;
    function GetEndpoint: WideString;
    function GetModelName: WideString;
    procedure AddHeaders(AHTTP: TFPHttpClient);
  public

    property TOKEN: WideString read FToken write FToken;
    property Question: WideString read FQuestion;
    property Response: WideString read FResponse write FResponse;
    property Dev: WideString read FDev write FDev;
    property TipoChat: TVersionAntigravity read FTipoChat write FTipoChat;
    property CustomModel: WideString read FCustomModel write FCustomModel;

    property LastJSON: WideString read FLastJSON;

    function SendQuestion(ASK: WideString): Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function TipoModelo: WideString;
    function ProviderName: WideString;
    function VersaoBiblioteca: WideString;
  end;

implementation

{ TAntigravity }

function TAntigravity.GetModelName: WideString;
var
  Model: WideString;
begin
  Model := Trim(FCustomModel);
  if (Model = '') or (LowerCase(Model) = 'gemini-1.5') then
  begin
    case FTipoChat of
      VAT_GEMINI_1_5_FLASH: Result := 'gemini-1.5-flash';
      VAT_GEMINI_1_5_PRO:   Result := 'gemini-1.5-pro';
      VAT_GEMINI_2_0_FLASH: Result := 'gemini-2.0-flash';
      VAT_GEMINI_2_0_PRO:   Result := 'gemini-2.0-pro-exp-02-05';
      VAT_GEMINI_2_5_FLASH: Result := 'gemini-2.5-flash';
      VAT_GEMINI_3_5_FLASH: Result := 'gemini-3.5-flash';
      VAT_CUSTOM:           Result := 'gemini-1.5-flash';
    else
      Result := 'gemini-1.5-flash';
    end;
  end
  else
    Result := Model;
end;

function TAntigravity.GetEndpoint: WideString;
begin
  Result := 'https://generativelanguage.googleapis.com/v1beta/models/' + GetModelName + ':generateContent?key=' + FToken;
end;

procedure TAntigravity.AddHeaders(AHTTP: TFPHttpClient);
begin
  if AHTTP = nil then
    Exit;

  AHTTP.AddHeader('Content-Type', 'application/json');
  AHTTP.AddHeader('Accept', 'application/json');
end;

function TAntigravity.PegaMensagem(const JSON: WideString): WideString;
var
  CleanJSON: WideString;
  Data: TJSONData;
  JsonObject, ContentObject: TJSONObject;
  CandidatesArray, PartsArray: TJSONArray;
  PartObject: TJSONObject;
  ContentData: TJSONData;
  Parser: TJSONParser;
begin
  CleanJSON := StringReplace(JSON, '#$0A', '', [rfReplaceAll]);
  Result := '';

  Parser := TJSONParser.Create(CleanJSON);
  try
    Data := Parser.Parse;
    try
      if Data.JSONType = jtObject then
      begin
        JsonObject := TJSONObject(Data);

        if JsonObject.Find('candidates', CandidatesArray) then
        begin
          if (CandidatesArray <> nil) and (CandidatesArray.Count > 0) then
          begin
            if CandidatesArray.Items[0].JSONType = jtObject then
            begin
              ContentObject := CandidatesArray.Objects[0].FindPath('content') as TJSONObject;
              if ContentObject <> nil then
              begin
                if ContentObject.Find('parts', PartsArray) then
                begin
                  if (PartsArray <> nil) and (PartsArray.Count > 0) then
                  begin
                    if PartsArray.Items[0].JSONType = jtObject then
                    begin
                      PartObject := PartsArray.Objects[0];
                      ContentData := PartObject.Find('text');
                      if (ContentData <> nil) and (ContentData.JSONType = jtString) then
                        Result := ContentData.AsString;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    finally
      Data.Free;
    end;
  finally
    Parser.Free;
  end;
end;

function TAntigravity.RequestJson(const LURL, ASK: WideString): WideString;
var
  ClienteHTTP: TFPHttpClient;
  BodyStream: TStringStream;
  root, contentsObj, userPart: TJSONObject;
  contentsArray, userPartsArray: TJSONArray;
  generationConfig: TJSONObject;
  payload: UTF8String;
  FullPrompt: WideString;
begin
  root := TJSONObject.Create;
  try
    // Contents (User Input)
    contentsArray := TJSONArray.Create;
    contentsObj := TJSONObject.Create;
    contentsObj.Add('role', 'user');

    userPartsArray := TJSONArray.Create;
    userPart := TJSONObject.Create;

    // Prepend the persona instructions directly to the prompt.
    // This is 100% compatible with all Gemini REST versions (v1 & v1beta) and keys.
    if Trim(FDev) <> '' then
      FullPrompt := '[System Instruction: ' + FDev + ']' + LineEnding + LineEnding + ASK
    else
      FullPrompt := ASK;

    userPart.Add('text', FullPrompt);
    userPartsArray.Add(userPart);

    contentsObj.Add('parts', userPartsArray);
    contentsArray.Add(contentsObj);
    root.Add('contents', contentsArray);

    // Generation Config
    generationConfig := TJSONObject.Create;
    generationConfig.Add('temperature', 0.7);
    generationConfig.Add('maxOutputTokens', 1024);
    root.Add('generationConfig', generationConfig);

    payload := UTF8Encode(root.AsJSON);
  finally
    root.Free;
  end;

  ClienteHTTP := TFPHttpClient.Create(nil);
  BodyStream := TStringStream.Create(payload);
  try
    AddHeaders(ClienteHTTP);

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

function TAntigravity.SendQuestion(ASK: WideString): Boolean;
var
  LURL, AUX: WideString;
begin
  Result := False;
  FQuestion := ASK;

  try
    LURL := GetEndpoint;
  except
    on E: Exception do
    begin
      FResponse := Format('{"error":{"message":"%s"}}',
        [StringReplace(E.Message, '"', '\"', [rfReplaceAll])]);
      FLastJSON := FResponse;
      Exit(False);
    end;
  end;

  AUX := RequestJson(LURL, ASK);
  FLastJSON := AUX;

  if Pos('"error"', LowerCase(AUX)) > 0 then
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

constructor TAntigravity.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTipoChat := VAT_GEMINI_1_5_FLASH;
  FDev := 'Você é um assistente.';
  FParams := TStringList.Create;
  FCustomModel := '';
  FLastJSON := '';
end;

destructor TAntigravity.Destroy;
begin
  FParams.Free;
  inherited;
end;

function TAntigravity.TipoModelo: WideString;
begin
  Result := '"' + GetModelName + '"';
end;

function TAntigravity.ProviderName: WideString;
begin
  Result := 'Antigravity (Gemini)';
end;

function TAntigravity.VersaoBiblioteca: WideString;
begin
  Result := ANTIGRAVITY_LIB_VERSION;
end;

end.
