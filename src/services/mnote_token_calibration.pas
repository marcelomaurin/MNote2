unit mnote_token_calibration;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

type
  TMNoteTokenCalibration = class
  public
    class function ExtractPromptTokens(const AJSON: string;
      out ATokens: Integer; out AUsageField: string): Boolean; static;
    class function Run(const AReportFile: string; AValidationCalls: Integer;
      out ASummary: string): Boolean; static;
  end;

implementation

uses
  Classes, SysUtils, Math, LazUTF8, chatgpt, setmain,
  mnote_chatgpt_config, mnote_token_estimator, mnote_token_usage;

class function TMNoteTokenCalibration.ExtractPromptTokens(
  const AJSON: string; out ATokens: Integer; out AUsageField: string): Boolean;
begin
  Result := TMNoteTokenUsage.ExtractPromptTokens(AJSON, ATokens,
    AUsageField);
end;

function BuildCalibrationPrompt(AIndex: Integer; ACode: Boolean;
  ARepetitions: Integer): string;
var
  I: Integer;
begin
  if ACode then
  begin
    Result := Format('Amostra Pascal %d. Leia o trecho e responda somente OK.' +
      LineEnding, [AIndex]);
    for I := 1 to ARepetitions do
      Result := Result + Format('procedure Calibrar%d_%d; begin ' +
        'WriteLn(''MNote2 valida tokens UTF-8''); end;' + LineEnding,
        [AIndex, I]);
  end
  else
  begin
    Result := Format('Amostra em português %d. Leia o contexto e responda ' +
      'somente OK.' + LineEnding, [AIndex]);
    for I := 1 to ARepetitions do
      Result := Result + Format('O editor mantém acentuação, pesquisa, ' +
        'tarefas e confirmação segura; sentença %d.' + LineEnding, [I]);
  end;
end;

function PerformMeasuredCall(AChat: TCHATGPT; const APrompt, ALanguage: string;
  AEstimator: TMNoteTokenEstimator; out AEstimate: TMNoteTokenEstimate;
  out AActual, ALatencyMS: Integer; out AUsageField, AError: string): Boolean;
var
  StartedAt: QWord;
  InputText: string;
begin
  Result := False;
  AError := '';
  AActual := 0;
  AUsageField := '';
  InputText := string(AChat.Dev) + LineEnding + APrompt;
  AEstimate := AEstimator.EstimateLanguage(InputText, ALanguage, 0);
  StartedAt := GetTickCount64;
  if not AChat.SendQuestion(APrompt) then
  begin
    ALatencyMS := Integer(GetTickCount64 - StartedAt);
    AError := AChat.LastError;
    if AError = '' then AError := 'Provider não retornou resposta utilizável.';
    Exit;
  end;
  ALatencyMS := Integer(GetTickCount64 - StartedAt);
  if not TMNoteTokenCalibration.ExtractPromptTokens(string(AChat.LastJSON),
    AActual, AUsageField) then
  begin
    AError := 'A resposta real não expôs contagem de tokens de entrada.';
    Exit;
  end;
  Result := True;
end;

function PercentValue(ANumerator, ADenominator: Double): Double;
begin
  if ADenominator = 0 then Exit(0);
  Result := (ANumerator / ADenominator) * 100.0;
end;

class function TMNoteTokenCalibration.Run(const AReportFile: string;
  AValidationCalls: Integer; out ASummary: string): Boolean;
const
  WarmupCalls = 10;
  DeveloperInstruction = 'Responda somente OK. Não repita nem explique o texto.';
var
  Chat: TCHATGPT;
  Estimator: TMNoteTokenEstimator;
  Report: TStringList;
  OwnSettings, IsCode, CallOK: Boolean;
  I, Actual, LatencyMS, Covered, CompletedValidations: Integer;
  Prompt, LanguageName, UsageField, ErrorText, ProviderName, ModelName: string;
  EstimateValue: TMNoteTokenEstimate;
  Ratio, MinPortugueseRatio, MinCodeRatio, MeanAbsError,
    WorstUnderestimation, Underestimation: Double;
  InitialPortuguese, InitialCode: Double;
begin
  Result := False;
  ASummary := '';
  if AValidationCalls < 20 then AValidationCalls := 20;
  Chat := nil;
  Estimator := TMNoteTokenEstimator.Create;
  Report := TStringList.Create;
  OwnSettings := False;
  try
    if FSetMain = nil then
    begin
      FSetMain := TSetMain.Create;
      OwnSettings := True;
    end;
    Chat := TCHATGPT.Create(nil);
    ConfiguraChatGPTPorSetMain(Chat);
    Chat.Dev := DeveloperInstruction;
    Chat.MaxTokens := 8;
    Chat.Temperature := 0.0;
    ProviderName := string(Chat.ProviderName);
    ModelName := string(Chat.CustomModel);
    if ModelName = '' then ModelName := string(Chat.TipoModelo);
    ForceDirectories(ExtractFileDir(AReportFile));
    Report.Add('# Calibração real do estimador de tokens');
    Report.Add('');
    Report.Add('- Data: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    Report.Add('- Provider: ' + ProviderName);
    Report.Add('- Modelo efetivamente chamado: `' + ModelName + '`');
    Report.Add('- Aquecimento independente: ' + IntToStr(WarmupCalls) +
      ' chamadas reais');
    Report.Add('- Validação: ' + IntToStr(AValidationCalls) +
      ' chamadas reais');
    Report.Add('- Margem conservadora: ' + IntToStr(Estimator.SafetyPercent) +
      '% sobre a estimativa');
    Report.Add('- Privacidade: chave, prompts, respostas e JSON bruto não são ' +
      'gravados neste relatório.');
    Report.Add('');
    if (Chat.Provider <> AIP_LOCAL) and (Trim(string(Chat.TOKEN)) = '') then
    begin
      Report.Add('## Resultado');
      Report.Add('');
      Report.Add('Calibração interrompida: não há credencial configurada para ' +
        'o provider ativo. Nenhuma chamada foi simulada.');
      Report.SaveToFile(AReportFile);
      ASummary := 'Calibração não executada: credencial ausente.';
      Exit;
    end;

    InitialPortuguese := Estimator.PortugueseCharactersPerToken;
    InitialCode := Estimator.CodeCharactersPerToken;
    MinPortugueseRatio := 1.0E100;
    MinCodeRatio := 1.0E100;
    Report.Add('## Aquecimento');
    Report.Add('');
    for I := 1 to WarmupCalls do
    begin
      IsCode := (I mod 2) = 0;
      if IsCode then LanguageName := 'code' else LanguageName := 'portuguese';
      Prompt := BuildCalibrationPrompt(I, IsCode, 2 + (I mod 5));
      CallOK := PerformMeasuredCall(Chat, Prompt, LanguageName, Estimator,
        EstimateValue, Actual, LatencyMS, UsageField, ErrorText);
      if not CallOK then
      begin
        Report.Add(Format('- Chamada %d interrompida: %s', [I, ErrorText]));
        Report.Add('');
        Report.Add('Calibração encerrada sem fabricar `usage`.');
        Report.SaveToFile(AReportFile);
        ASummary := 'Calibração interrompida no aquecimento: ' + ErrorText;
        Exit;
      end;
      Ratio := EstimateValue.UTF8Characters / Actual;
      if IsCode then
      begin
        if Ratio < MinCodeRatio then MinCodeRatio := Ratio;
      end
      else if Ratio < MinPortugueseRatio then MinPortugueseRatio := Ratio;
      Report.Add(Format('- %d: %s, %d caracteres, %d tokens, %d ms, `%s`',
        [I, LanguageName, EstimateValue.UTF8Characters, Actual, LatencyMS,
        UsageField]));
    end;
    Estimator.SetLanguageCoefficient('portuguese', MinPortugueseRatio);
    Estimator.SetLanguageCoefficient('code', MinCodeRatio);

    Report.Add('');
    Report.Add('## Validação após aquecimento');
    Report.Add('');
    Report.Add('| # | Perfil | Caracteres | Estimativa | Com margem | Real | ' +
      'Erro absoluto | Latência ms |');
    Report.Add('|---:|---|---:|---:|---:|---:|---:|---:|');
    MeanAbsError := 0;
    WorstUnderestimation := 0;
    Covered := 0;
    CompletedValidations := 0;
    for I := 1 to AValidationCalls do
    begin
      IsCode := (I mod 2) = 0;
      if IsCode then LanguageName := 'code' else LanguageName := 'portuguese';
      Prompt := BuildCalibrationPrompt(WarmupCalls + I, IsCode,
        4 + (I mod 7));
      CallOK := PerformMeasuredCall(Chat, Prompt, LanguageName, Estimator,
        EstimateValue, Actual, LatencyMS, UsageField, ErrorText);
      if not CallOK then
      begin
        Report.Add('');
        Report.Add(Format('Validação interrompida na chamada %d: %s',
          [I, ErrorText]));
        Break;
      end;
      Inc(CompletedValidations);
      MeanAbsError := MeanAbsError +
        Abs(PercentValue(EstimateValue.EstimatedTokens - Actual, Actual));
      Underestimation := PercentValue(Actual -
        EstimateValue.EstimatedTokens, Actual);
      if Underestimation < 0 then Underestimation := 0;
      if Underestimation > WorstUnderestimation then
        WorstUnderestimation := Underestimation;
      if EstimateValue.TotalWithMargin >= Actual then Inc(Covered);
      Report.Add(Format('| %d | %s | %d | %d | %d | %d | %.2f%% | %d |',
        [I, LanguageName, EstimateValue.UTF8Characters,
        EstimateValue.EstimatedTokens, EstimateValue.TotalWithMargin, Actual,
        Abs(PercentValue(EstimateValue.EstimatedTokens - Actual, Actual)),
        LatencyMS]));
    end;

    Report.Add('');
    Report.Add('## Coeficientes e aceite');
    Report.Add('');
    Report.Add(Format('- Português: inicial %.4f; calibrado %.4f ' +
      'caracteres/token.', [InitialPortuguese,
      Estimator.PortugueseCharactersPerToken]));
    Report.Add(Format('- Código Pascal: inicial %.4f; calibrado %.4f ' +
      'caracteres/token.', [InitialCode, Estimator.CodeCharactersPerToken]));
    if CompletedValidations > 0 then
      MeanAbsError := MeanAbsError / CompletedValidations;
    Report.Add(Format('- Erro percentual absoluto médio: %.2f%%.',
      [MeanAbsError]));
    Report.Add(Format('- Pior subestimação antes da margem: %.2f%%.',
      [WorstUnderestimation]));
    Report.Add(Format('- Cobertura da margem conservadora: %d/%d.',
      [Covered, CompletedValidations]));
    Report.Add('');
    Result := (CompletedValidations = AValidationCalls) and
      (Covered = AValidationCalls);
    if Result then
      Report.Add('**ACEITE: aprovado.** Todas as chamadas de validação ficaram ' +
        'dentro do total estimado com margem.')
    else if CompletedValidations < AValidationCalls then
      Report.Add('**ACEITE: inconclusivo.** O provider não forneceu `usage` ' +
        'suficiente; não houve preenchimento artificial.')
    else
      Report.Add('**ACEITE: reprovado.** A margem conservadora deve ser ' +
        'aumentada antes da entrega.');
    Report.SaveToFile(AReportFile);
    ASummary := Format('%s/%s: %d chamadas validadas; cobertura %d/%d; ' +
      'erro médio %.2f%%; pior subestimação %.2f%%.',
      [ProviderName, ModelName, CompletedValidations, Covered,
      CompletedValidations, MeanAbsError, WorstUnderestimation]);
  finally
    Chat.Free;
    Report.Free;
    Estimator.Free;
    if OwnSettings then FreeAndNil(FSetMain);
  end;
end;

end.
