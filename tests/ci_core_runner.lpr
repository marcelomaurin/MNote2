program ci_core_runner;

{$mode objfpc}{$H+}
{$codepage utf8}

uses
  SysUtils, mnote_search_types, mnote_text_search_service,
  mnote_token_estimator, mnote_token_usage, mnote_voice_command,
  mnote_unified_diff, mnote_completion_types, mnote_pascal_semantic_resolver,
  mnote_editor_theme, mnote_secret_store;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

procedure CheckSecretStore;
const
  Names: array[0..3] of string = ('CHATGPT', 'PASSWORDMY', 'PASSWORDPOST',
    'PASSWORDORACLE');
var
  Values: array[0..3] of string;
  Stored: string;
  I: Integer;
begin
  Values[0] := 'sk-teste-123';
  Values[1] := 'S3nh@-de-teste çãé';
  Values[2] := StringOfChar('x', 4096);
  Values[3] := '';
  for I := Low(Names) to High(Names) do
  begin
    Stored := ProtectSecret(Names[I], Values[I]);
    Check(UnprotectSecret(Names[I], Stored) = Values[I],
      'Segredo não sobreviveu à ida e volta: ' + Names[I]);
    if Values[I] = '' then
      Check(Stored = '', 'Segredo vazio deve continuar vazio')
    else
    begin
      {$IFDEF WINDOWS}
      Check(IsProtectedSecret(Stored),
        'Segredo não foi protegido: ' + Names[I] + ' ' + SecretStoreLastError);
      {$ENDIF}
      if IsProtectedSecret(Stored) then
        Check(Pos(Values[I], Stored) = 0,
          'Valor protegido contém o segredo em texto: ' + Names[I]);
    end;
  end;
  Check(UnprotectSecret('PASSWORDMY', 'senha:antiga') = 'senha:antiga',
    'Valor antigo em texto puro deve ser devolvido intacto');
  Check(not IsProtectedSecret('senha:antiga'),
    'Texto puro foi classificado como protegido');
  Check(UnprotectSecret('CHATGPT', 'dpapi:@@invalido@@') = '',
    'Valor protegido inválido deve devolver vazio');
  {$IFDEF WINDOWS}
  Stored := ProtectSecret('PASSWORDMY', 'troca-de-campo');
  Check(UnprotectSecret('CHATGPT', Stored) = '',
    'Segredo de um campo não pode abrir em outro');
  {$ENDIF}
end;

procedure CheckSemanticCompletion;
var
  Context: TMNoteCompletionContext;
  Items: TMNoteCompletionItems;
begin
  Context := TMNoteCompletionContext.Create;
  Items := TMNoteCompletionItems.Create;
  try
    Context.LanguageID := 'pascal';
    Context.FileName := 'semantic_fixture.pas';
    Context.TextBeforeCursor := 'Cliente.';
    Context.DocumentText :=
      'type' + LineEnding +
      '  TPessoa = class' + LineEnding +
      '  public' + LineEnding +
      '    procedure Salvar;' + LineEnding +
      '  end;' + LineEnding +
      '  TCliente = class(TPessoa)' + LineEnding +
      '  public' + LineEnding +
      '    function Nome: string;' + LineEnding +
      '    property Codigo: Integer read FCodigo;' + LineEnding +
      '  end;' + LineEnding +
      'var Cliente, Outro: TCliente;' + LineEnding;
    Check(TMNotePascalSemanticResolver.CollectQualifiedMembers(Context, Items),
      'resolver semântico não coletou membros');
    Check(Items.FindByInsertText('Nome') <> nil,
      'membro da classe não foi resolvido');
    Check(Items.FindByInsertText('Codigo') <> nil,
      'property não foi resolvida');
    Check(Items.FindByInsertText('Salvar') <> nil,
      'membro herdado não foi resolvido');
  finally
    Items.Free;
    Context.Free;
  end;
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
  ThemeService: TMNoteEditorThemeService;
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
    CheckSemanticCompletion;
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
        ThemeService := TMNoteEditorThemeService.Create;
    try
      ThemeService.LoadBuiltInTheme('Dark');
      Check(ThemeService.Current.Name = 'Dark', 'LoadBuiltInTheme Dark falhou');
      ThemeService.LoadBuiltInTheme('Blue');
      Check(ThemeService.Current.Name = 'Blue', 'LoadBuiltInTheme Blue falhou');
      ThemeService.LoadBuiltInTheme('Light');
      Check(ThemeService.Current.Name = 'Light', 'LoadBuiltInTheme Light falhou');
      Check(ThemeService.LoadTheme('Dark', '') and (ThemeService.Current.Name = 'Dark'),
        'LoadTheme Dark com arquivo vazio falhou');
      Check(ThemeService.LoadTheme('Blue', 'arquivo_inexistente.json') and (ThemeService.Current.Name = 'Blue'),
        'LoadTheme Blue com arquivo inexistente deveria usar fallback built-in');
      Check(ThemeService.LoadTheme('Light', '') and (ThemeService.Current.Name = 'Light'),
        'LoadTheme Light falhou');
    finally
      ThemeService.Free;
    end;
    CheckSecretStore;
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
