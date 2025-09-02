unit chatgpt;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LazUTF8, fpjson, jsonparser,
  fphttpclient, opensslsockets, funcoes;

{ TCHATGPT }

 type TVersionChat = (VCT_GPT35TURBO, VCT_GPT40,VCT_GPT40_TURBO, VCT_GPT4o, VCT_GPTo3_mini, VCT_GPT41,VCT_GPT41_MINI, VCT_GPT5 );

 //Class to do connect with chatgpt
 type  TCHATGPT = class(TComponent)
  private
    FToken : String; //private variable to use chatgp
    FQuestion : String;
    FResponse : String;
    FDev : String;
    FTipoChat : TVersionChat;
    FParams: TStrings;

    function RequestJson(LURL : String; token : string ; ASK : string) : String;
    function PegaMensagem(const JSON: string): string;

  public
    property TOKEN : String read FToken write FToken; //property to access chatgpt
    property Question : String read FQuestion;
    property Response : String read FResponse write FResponse;
    property TipoChat : TVersionChat read FTipoChat;
    property Dev : String read FDev write FDev;
    function SendQuestion( ASK : String) : boolean;

    constructor create(AOwner: TComponent); override;
    destructor Destroy;
    function TipoModelo: string;

end;

implementation

{ TCHATGPT }

function JsonEscape(const S: string): string;
var
  R: string;
begin
  R := StringReplace(S, '\', '\\', [rfReplaceAll]);
  R := StringReplace(R,   '"', '\"', [rfReplaceAll]);
  R := StringReplace(R, #13#10, '\n', [rfReplaceAll]);
  R := StringReplace(R, #10,    '\n', [rfReplaceAll]);
  R := StringReplace(R, #13,    '\n', [rfReplaceAll]);
  Result := R;
end;



function TCHATGPT.PegaMensagem(const JSON: string): string;
var
  CleanJSON: string;
  Data: TJSONData;
  JsonObject, MessageObject: TJSONObject;
  ChoicesArray: TJSONArray;
  ContentData: TJSONData;
  Parser: TJSONParser;
begin
  // Remove caracteres de controle do JSON
  CleanJSON := StringReplace(JSON, '#$0A', '', [rfReplaceAll]);

  // Inicializa o resultado
  Result := '';

  // Cria um objeto TJSONParser a partir da string JSON limpa
  Parser := TJSONParser.Create(CleanJSON);

  try
    // Faz o parsing do JSON
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
              // Verifica se 'content' existe e é do tipo correto
              ContentData := MessageObject.Find('content');
              if (ContentData <> nil) and (ContentData.JSONType = jtString) then
              begin
                Result := ContentData.AsString;
              end;
            end;
          end;
        end;
      end;
    end;
  finally
    Parser.Free;
  end;
end;


function TCHATGPT.RequestJson(LURL: String; token: string; ASK: string): String;
var
  ClienteHTTP : TFPHttpClient;
  BodyStream  : TStringStream;
  tipo        : string;
  root, mSys, mUser: TJSONObject;
  msgs: TJSONArray;
  payload: string;
begin
  // Seleção do modelo
  case FTipoChat of
    VCT_GPT35TURBO : tipo := 'gpt-3.5-turbo';
    VCT_GPT40      : tipo := 'gpt-4';
    VCT_GPT40_TURBO: tipo := 'gpt-4-turbo-preview';
    VCT_GPT4o      : tipo := 'gpt-4o';
    VCT_GPTo3_mini : tipo := 'gpt-o3-mini';
    VCT_GPT41      : tipo := 'gpt-4.1';
    VCT_GPT41_MINI : tipo := 'gpt-4.1-mini';
    VCT_GPT5       : tipo := 'gpt-5';
  else
    tipo := 'gpt-4.1-mini';
  end;

  // Monta JSON com fpjson (sem escapar manualmente)
  root := TJSONObject.Create;
  try
    root.Add('model', tipo);

    msgs := TJSONArray.Create;
    root.Add('messages', msgs);

    mSys := TJSONObject.Create;
    mSys.Add('role', 'system');    // ✔ role suportada
    mSys.Add('content', FDev);
    msgs.Add(mSys);

    mUser := TJSONObject.Create;
    mUser.Add('role', 'user');
    mUser.Add('content', ASK);     // ✔ sem JsonEscape
    msgs.Add(mUser);

    payload := root.AsJSON;
  finally
    root.Free; // payload já é uma cópia
  end;

  ClienteHTTP := TFPHttpClient.Create(nil);
  BodyStream  := TStringStream.Create(payload, TEncoding.UTF8);
  try
    ClienteHTTP.AddHeader('Content-Type', 'application/json');
    ClienteHTTP.AddHeader('Accept', 'application/json');
    ClienteHTTP.AddHeader('Authorization', 'Bearer ' + token);
    ClienteHTTP.AllowRedirect   := True;
    ClienteHTTP.KeepConnection  := True;
    ClienteHTTP.IOTimeout       := 30000;
    ClienteHTTP.ConnectTimeout  := 15000;
    ClienteHTTP.RequestBody     := BodyStream;

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


(*
function TCHATGPT.SendQuestion(ASK: String): boolean;
var
  LURL : String;
  JSON : String;
  AUX : String;
  resposta : boolean;
begin
     resposta := false;

     LURL := 'https://api.openai.com/v1/chat/completions';
     //JSON := EncodeURLElement('{"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "'+ASK+'"}]}');

     AUX := RequestJson(LURL, FToken, EncodeURLElement(retiraCRLF(ASK)));
     try
       FResponse := PegaMensagem(AUX);
     except
       FResponse := AUX
     end;

     //FResponse := RequestJson2(LURL, FToken, JSON);
     result := resposta;
end;
*)

function TCHATGPT.SendQuestion(ASK: String): boolean;
var
  LURL, AUX: String;
begin
  Result := False;
  LURL := 'https://api.openai.com/v1/chat/completions';

  // ❌ NÃO use JsonEscape aqui — RequestJson já monta JSON correto
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




//Class Constructor
constructor TCHATGPT.create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  //FTipoChat:= VCT_GPT35TURBO;
  FTipoChat:= VCT_GPT41_MINI;
  FDEV := 'Voce é um assistente.';
  //HTTPSend.Sock.SSL.SSLType := LT_TLSv1;
  //Self.IsUTF8 := False;
  FParams := TStringList.Create;
end;

destructor TCHATGPT.Destroy;
begin
    FParams.Free;
  inherited;
end;

function TCHATGPT.TipoModelo: string;
begin
  case FTipoChat of
    VCT_GPT35TURBO:   Result := '"gpt-3.5-turbo"';
    VCT_GPT40:        Result := '"gpt-4"';
    VCT_GPT40_TURBO:  Result := '"gpt-4-turbo-preview"';
    VCT_GPT4o:        Result := '"gpt-4o"';
    VCT_GPTo3_mini:   Result := '"gpt-o3-mini"';
    VCT_GPT41:        Result := '"gpt-4.1"';
    VCT_GPT41_MINI:   Result := '"gpt-4.1-mini"';
    VCT_GPT5:         Result := '"gpt-5"';
  else
    Result := '"gpt-4.1-mini"';
  end;
end;


end.

