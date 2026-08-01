unit mnote_ai_router;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, md5, mnote_ai_types,
  mnote_token_estimator;

type
  TMNoteAIRoute = record
    Role: TMNoteAIRole;
    Reason: string;
    SplitRequired: Boolean;
    Escalated: Boolean;
  end;

  { TMNoteAIRouter }

  TMNoteAIRouter = class
  private
    FFingerprints: TStringList;
    FCallCount: Integer;
    FEstimatedTokens: Integer;
    FStartedAt: QWord;
    FMaxCalls: Integer;
    FMaxEstimatedTokens: Integer;
    FMaxDurationMS: Cardinal;
    FArbitrationUsed: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginSession;
    function Route(AKind: TMNoteAIRequestKind; AEstimatedTokens,
      ATriageBudget: Integer): TMNoteAIRoute;
    function SplitTriage(const AText: string; ABudget: Integer;
      AEstimator: TMNoteTokenEstimator; AParts: TStrings;
      out AIndivisibleOverflow: Boolean): Boolean;
    class function ClassifyError(const AError: string;
      AContractInvalid, ALowConfidence: Boolean): TMNoteAIErrorClass; static;
    class function TaskFingerprint(const AInput: string): string; static;
    class function StepFingerprint(ARole: TMNoteAIRole;
      const AInput: string; AErrorClass: TMNoteAIErrorClass): string; static;
    function RegisterFingerprint(const AFingerprint: string): Boolean;
    function CanCall(AEstimatedTokens: Integer; out AReason: string): Boolean;
    function MayRetry(AErrorClass: TMNoteAIErrorClass;
      AAttempts: Integer): Boolean;
    function ValidateArbitration(const AJSON: string;
      out AVerdict, AReason: string): Boolean;
    property CallCount: Integer read FCallCount;
    property EstimatedTokens: Integer read FEstimatedTokens;
    property ArbitrationUsed: Boolean read FArbitrationUsed;
    property MaxCalls: Integer read FMaxCalls write FMaxCalls;
    property MaxEstimatedTokens: Integer read FMaxEstimatedTokens
      write FMaxEstimatedTokens;
    property MaxDurationMS: Cardinal read FMaxDurationMS write FMaxDurationMS;
  end;

implementation

constructor TMNoteAIRouter.Create;
begin
  inherited Create;
  FFingerprints := TStringList.Create;
  FFingerprints.Sorted := True;
  FFingerprints.Duplicates := dupIgnore;
  FMaxCalls := 12;
  FMaxEstimatedTokens := 20000;
  FMaxDurationMS := 5 * 60 * 1000;
  BeginSession;
end;

destructor TMNoteAIRouter.Destroy;
begin
  FFingerprints.Free;
  inherited Destroy;
end;

procedure TMNoteAIRouter.BeginSession;
begin
  FFingerprints.Clear;
  FCallCount := 0;
  FEstimatedTokens := 0;
  FArbitrationUsed := False;
  FStartedAt := GetTickCount64;
end;

function TMNoteAIRouter.Route(AKind: TMNoteAIRequestKind; AEstimatedTokens,
  ATriageBudget: Integer): TMNoteAIRoute;
begin
  Result.SplitRequired := False;
  Result.Escalated := False;
  case AKind of
    aikClassify, aikExtract:
      begin
        Result.Role := airTriage;
        Result.Reason := 'Classificação e extração pertencem à Triagem.';
        Result.SplitRequired := (ATriageBudget > 0) and
          (AEstimatedTokens > ATriageBudget);
      end;
    aikDatabase:
      begin Result.Role := airDatabase;
        Result.Reason := 'Pedido explicitamente relacionado a banco.'; end;
    aikPlanning:
      begin Result.Role := airManagement;
        Result.Reason := 'Planejamento autônomo pertence à Gestão.'; end;
    aikArbitrate:
      begin Result.Role := airArbiter;
        Result.Reason := 'Arbitragem é interna e só ocorre após ciclo lógico.'; end;
    aikConversation:
      begin Result.Role := airTriage;
        Result.Reason := 'Conversa passa primeiro por Triagem antes da resposta.';
        Result.SplitRequired := (ATriageBudget > 0) and
          (AEstimatedTokens > ATriageBudget); end;
  else
    begin Result.Role := airLightWork;
      Result.Reason := 'Trabalho pequeno segue para Trabalho Leve.'; end;
  end;
end;

function TMNoteAIRouter.SplitTriage(const AText: string; ABudget: Integer;
  AEstimator: TMNoteTokenEstimator; AParts: TStrings;
  out AIndivisibleOverflow: Boolean): Boolean;
var
  Lines: TStringList;
  Current, Candidate: string;
  I: Integer;
  Estimate: TMNoteTokenEstimate;
begin
  Result := False;
  AIndivisibleOverflow := False;
  AParts.Clear;
  if (AEstimator = nil) or (ABudget < 1) then Exit;
  Lines := TStringList.Create;
  try
    Lines.Text := StringReplace(AText, #13#10, #10, [rfReplaceAll]);
    Current := '';
    for I := 0 to Lines.Count - 1 do
    begin
      if Current = '' then Candidate := Lines[I]
      else Candidate := Current + LineEnding + Lines[I];
      Estimate := AEstimator.Estimate(Candidate, ABudget);
      if Estimate.TotalWithMargin <= ABudget then
        Current := Candidate
      else
      begin
        if Current <> '' then
        begin
          AParts.Add(Current);
          Current := Lines[I];
        end
        else
        begin
          AIndivisibleOverflow := True;
          AParts.Add(Lines[I]);
          Current := '';
        end;
      end;
    end;
    if Current <> '' then AParts.Add(Current);
    Result := AParts.Count > 0;
  finally
    Lines.Free;
  end;
end;

class function TMNoteAIRouter.ClassifyError(const AError: string;
  AContractInvalid, ALowConfidence: Boolean): TMNoteAIErrorClass;
var
  Text: string;
begin
  if AContractInvalid then Exit(aieInvalidContract);
  if ALowConfidence then Exit(aieLowConfidence);
  Text := LowerCase(AError);
  if Text = '' then Exit(aieNone);
  if (Pos('401', Text) > 0) or (Pos('403', Text) > 0) or
    (Pos('auth', Text) > 0) or (Pos('token', Text) > 0) or
    (Pos('api key', Text) > 0) or (Pos('model not found', Text) > 0) or
    (Pos('modelo inexistente', Text) > 0) or
    (Pos('configura', Text) > 0) then Exit(aiePermanent);
  if (Pos('429', Text) > 0) or (Pos('timeout', Text) > 0) or
    (Pos('timed out', Text) > 0) or (Pos('500', Text) > 0) or
    (Pos('502', Text) > 0) or (Pos('503', Text) > 0) or
    (Pos('504', Text) > 0) then Exit(aieTransient);
  Result := aiePermanent;
end;

class function TMNoteAIRouter.TaskFingerprint(const AInput: string): string;
begin
  Result := MD5Print(MD5String(LowerCase(Trim(AInput))));
end;

class function TMNoteAIRouter.StepFingerprint(ARole: TMNoteAIRole;
  const AInput: string; AErrorClass: TMNoteAIErrorClass): string;
begin
  Result := MD5Print(MD5String(MNoteAIRoleID(ARole) + '|' +
    LowerCase(Trim(AInput)) + '|' + MNoteAIErrorClassName(AErrorClass)));
end;

function TMNoteAIRouter.RegisterFingerprint(const AFingerprint: string): Boolean;
begin
  Result := FFingerprints.IndexOf(AFingerprint) < 0;
  if Result then FFingerprints.Add(AFingerprint);
end;

function TMNoteAIRouter.CanCall(AEstimatedTokens: Integer;
  out AReason: string): Boolean;
begin
  AReason := '';
  if FCallCount >= FMaxCalls then AReason := 'limite_de_chamadas'
  else if FEstimatedTokens + AEstimatedTokens > FMaxEstimatedTokens then
    AReason := 'limite_de_tokens_estimados'
  else if GetTickCount64 - FStartedAt > FMaxDurationMS then
    AReason := 'limite_de_duracao';
  Result := AReason = '';
  if Result then
  begin
    Inc(FCallCount);
    Inc(FEstimatedTokens, AEstimatedTokens);
  end;
end;

function TMNoteAIRouter.MayRetry(AErrorClass: TMNoteAIErrorClass;
  AAttempts: Integer): Boolean;
begin
  case AErrorClass of
    aieTransient: Result := AAttempts < 2;
    aieInvalidContract: Result := AAttempts < 1;
    aieLowConfidence: Result := AAttempts < 1;
  else
    Result := False;
  end;
end;

function TMNoteAIRouter.ValidateArbitration(const AJSON: string;
  out AVerdict, AReason: string): Boolean;
var
  Data: TJSONData;
  Root: TJSONObject;
begin
  Result := False;
  AVerdict := '';
  AReason := '';
  if FArbitrationUsed then
  begin
    AReason := 'A sessão já utilizou sua única arbitragem.';
    Exit;
  end;
  if Trim(AJSON) = '' then begin AReason := 'JSON vazio.'; Exit; end;
  if not (Trim(AJSON)[1] in ['{']) then
  begin AReason := 'A arbitragem deve conter somente JSON puro.'; Exit; end;
  Data := nil;
  try
    Data := GetJSON(AJSON);
    if not (Data is TJSONObject) then begin AReason := 'Objeto JSON esperado.'; Exit; end;
    Root := TJSONObject(Data);
    if Root.Count <> 1 then begin AReason := 'A arbitragem exige um único veredito.'; Exit; end;
    AVerdict := Root.Names[0];
    if (AVerdict <> 'executavel') and (AVerdict <> 'faltam_informacoes') and
      (AVerdict <> 'abortar') then
    begin AReason := 'Veredito desconhecido.'; Exit; end;
    if Root.Items[0].JSONType = jtNull then
    begin AReason := 'O veredito precisa explicar a decisão.'; Exit; end;
    FArbitrationUsed := True;
    Result := True;
  except
    on E: Exception do AReason := E.Message;
  end;
  Data.Free;
end;

end.
