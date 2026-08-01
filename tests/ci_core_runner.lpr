program ci_core_runner;

{$mode objfpc}{$H+}
{$codepage utf8}

uses
  SysUtils, mnote_search_types, mnote_text_search_service,
  mnote_token_estimator, mnote_token_usage, mnote_voice_command,
  mnote_unified_diff;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

var
  Search: TMNoteTextSearchService;
  Results: TMNoteSearchResults;
  Options: TMNoteSearchOptions;
  Estimator: TMNoteTokenEstimator;
  Estimate: TMNoteTokenEstimate;
  Tokens: Integer;
  UsageField, CommandText, Diff, Rebuilt, ErrorText: string;
  Fallback: Boolean;
  Hunks: array of Boolean;
begin
  try
    Search := TMNoteTextSearchService.Create;
    Results := TMNoteSearchResults.Create;
    try
      Options := DefaultSearchOptions;
      Check(Search.SearchText('início'#10'café fim', 'CAFÉ', 'utf8.txt',
        Options, Results), Search.LastError);
      Check((Results.Count = 1) and (Results[0].Line = 2) and
        (Results[0].Column = 1), 'posição UTF-8 incorreta');
    finally
      Results.Free;
      Search.Free;
    end;
    Estimator := TMNoteTokenEstimator.Create;
    try
      Estimate := Estimator.EstimateLanguage('texto UTF-8 em português',
        'portuguese', 100);
      Check((Estimate.EstimatedTokens > 0) and
        (Estimate.TotalWithMargin > Estimate.EstimatedTokens),
        'estimativa ou margem inválida');
    finally
      Estimator.Free;
    end;
    Check(TMNoteTokenUsage.ExtractPromptTokens(
      '{"usageMetadata":{"promptTokenCount":19}}', Tokens,
      UsageField) and (Tokens = 19), 'usage real não foi interpretado');
    Check(TMNoteVoiceCommand.TryParse('OK MNote abra o projeto', 'OK MNote',
      CommandText) and (CommandText = 'abra o projeto'),
      'wake word não foi respeitada');
    Diff := TMNoteUnifiedDiff.Generate(
      'a'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10'j'#10'o'#10,
      'A'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10'j'#10'O'#10,
      'fixture.pas', Fallback);
    Check(TMNoteUnifiedDiff.HunkCount(Diff) = 2,
      'diff não separou alterações distantes');
    SetLength(Hunks, 2);
    Hunks[0] := True;
    Hunks[1] := False;
    Diff := TMNoteUnifiedDiff.SelectHunks(Diff, Hunks);
    Check(TMNoteUnifiedDiff.Apply(
      'a'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10'j'#10'o'#10,
      Diff, Rebuilt, ErrorText) and
      (Rebuilt =
        'A'#10'b'#10'c'#10'd'#10'e'#10'f'#10'g'#10'h'#10'i'#10'j'#10'o'#10),
      'aplicação parcial do diff falhou: ' + ErrorText);
    WriteLn('OK: núcleo portátil compilado e validado em ',
      {$I %FPCTARGETCPU%}, '-', {$I %FPCTARGETOS%});
    Halt(0);
  except
    on E: Exception do
    begin
      WriteLn(StdErr, 'FALHA: ', E.Message);
      Halt(1);
    end;
  end;
end.
