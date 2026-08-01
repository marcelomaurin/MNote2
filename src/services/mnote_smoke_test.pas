unit mnote_smoke_test;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

function RunMNoteSmokeTest(out AReport: string): Boolean;

implementation

uses
  Classes, SysUtils, mnote_search_types, mnote_text_search_service,
  mnote_project_service, mnote_ai_profile, mnote_ai_profile_defaults,
  mnote_ai_types, chatgpt, aivoicesynthesizer, setmain,
  mnote_visual_identity;

function SaveText(const AFileName, AText: string): Boolean;
var
  Stream: TFileStream;
begin
  Result := False;
  Stream := TFileStream.Create(AFileName, fmCreate);
  try
    if AText <> '' then Stream.WriteBuffer(AText[1], Length(AText));
    Result := True;
  finally
    Stream.Free;
  end;
end;

function LoadText(const AFileName: string): string;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, Stream.Size);
    if Stream.Size > 0 then Stream.ReadBuffer(Result[1], Stream.Size);
  finally
    Stream.Free;
  end;
end;

procedure RemoveSmokeTree(const AFolder, AAllowedPrefix: string);
var
  Search: TSearchRec;
  Name: string;
begin
  if Pos(LowerCase(IncludeTrailingPathDelimiter(ExpandFileName(AAllowedPrefix))),
    LowerCase(IncludeTrailingPathDelimiter(ExpandFileName(AFolder)))) <> 1 then Exit;
  if FindFirst(IncludeTrailingPathDelimiter(AFolder) + '*', faAnyFile,
    Search) = 0 then
  try
    repeat
      if (Search.Name = '.') or (Search.Name = '..') then Continue;
      Name := IncludeTrailingPathDelimiter(AFolder) + Search.Name;
      if (Search.Attr and faDirectory) <> 0 then RemoveSmokeTree(Name, AAllowedPrefix)
      else DeleteFile(Name);
    until FindNext(Search) <> 0;
  finally
    FindClose(Search);
  end;
  RemoveDir(AFolder);
end;

function RunMNoteSmokeTest(out AReport: string): Boolean;
var
  Root, DocumentName, ProjectName, OriginalText, ReplacedText: string;
  Options: TMNoteSearchOptions;
  Results: TMNoteSearchResults;
  Search: TMNoteTextSearchService;
  Project, Loaded: TMNoteProjectService;
  Profiles: TMNoteAIProfiles;
  VoiceSynthesizer: TAIVoiceSynthesizer;
  VoiceSettings: TSetMain;
  Voices: TStringList;
  Role: TMNoteAIRole;
  ReplaceCount: Integer;
begin
  Result := False;
  AReport := '';
  Randomize;
  Root := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'mnote2-smoke-' + FormatDateTime('yyyymmddhhnnsszzz', Now) + '-' +
    IntToStr(Random(100000));
  DocumentName := IncludeTrailingPathDelimiter(Root) + 'documento.txt';
  ProjectName := IncludeTrailingPathDelimiter(Root) + 'Smoke.mnoteproj.json';
  ForceDirectories(Root);
  Search := TMNoteTextSearchService.Create;
  Results := TMNoteSearchResults.Create;
  Project := TMNoteProjectService.Create;
  Loaded := TMNoteProjectService.Create;
  Profiles := TMNoteAIProfiles.Create;
  VoiceSynthesizer := TAIVoiceSynthesizer.Create(nil);
  VoiceSettings := TSetMain.Create;
  Voices := TStringList.Create;
  try
    OriginalText := 'Olá MNote2' + LineEnding + 'buscar e substituir' + LineEnding;
    if not SaveText(DocumentName, OriginalText) then
      raise Exception.Create('não foi possível salvar o documento');
    OriginalText := LoadText(DocumentName);
    Options := DefaultSearchOptions;
    Options.MatchCase := True;
    if not Search.SearchText(OriginalText, 'MNote2', DocumentName, Options,
      Results) or (Results.Count <> 1) then
      raise Exception.Create('a busca não encontrou o documento salvo');
    if not Search.ReplaceText(OriginalText, 'substituir', 'validar', Options,
      ReplacedText, ReplaceCount) or (ReplaceCount <> 1) then
      raise Exception.Create('a substituição não produziu uma ocorrência');
    if not SaveText(DocumentName, ReplacedText) or
      (Pos('buscar e validar', LoadText(DocumentName)) = 0) then
      raise Exception.Create('o documento substituído não foi reaberto corretamente');
    Project.NewProject('Smoke', Root);
    Project.Project.Description := 'Projeto temporário do smoke test';
    Project.Tasks.AddTask('Validar abertura', 'fixture real', 'normal',
      'QA', '', 1);
    if not Project.SaveAs(ProjectName) then
      raise Exception.Create('falha ao salvar projeto: ' + Project.LastError);
    if not Loaded.Load(ProjectName) or (Loaded.Project.Name <> 'Smoke') or
      (Loaded.Tasks.Count <> 1) then
      raise Exception.Create('falha ao reabrir o projeto salvo');
    ApplyMainAIToProfiles(Profiles, 3, 'modelo-local-smoke',
      'http://127.0.0.1:8095');
    for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
    begin
      Profiles.Profile(Role).ApplyConfig;
      if (Profiles.Profile(Role).Config.Provider <> 3) or
        (Profiles.Profile(Role).Client.Provider <> AIP_LOCAL) or
        (Profiles.Profile(Role).Config.ModelName <> 'modelo-local-smoke') or
        (Profiles.Profile(Role).Config.Endpoint <> 'http://127.0.0.1:8095') or
        (Profiles.Profile(Role).Client.TOKEN <> '') then
        raise Exception.Create('perfil multi-IA não herdou a IA local sem token');
    end;
    if (VoiceSettings.VoiceOutputEngine < 0) or
      (VoiceSettings.VoiceOutputEngine > 2) or
      (VoiceSettings.VoiceOutputVolume < 0) or
      (VoiceSettings.VoiceOutputVolume > 100) or
      (VoiceSettings.VoiceOutputRate < -10) or
      (VoiceSettings.VoiceOutputRate > 10) then
      raise Exception.Create('parâmetros persistidos de Voice Output inválidos');
    {$IFDEF WINDOWS}
    VoiceSynthesizer.Engine := seSAPI;
    {$ELSE}
    VoiceSynthesizer.Engine := seEspeak;
    {$ENDIF}
    VoiceSynthesizer.GetAvailableVoices(Voices);
    if VoiceSynthesizer.LastError <> '' then
      raise Exception.Create('sintetizador de voz indisponível: ' +
        VoiceSynthesizer.LastError);
    if (MNoteIconForCaption('AI Monitor') <> MNOTE_ICON_MONITOR) or
      (MNoteIconForCaption('Voice Output') <> MNOTE_ICON_VOICE) or
      (MNoteIconForCaption('Salvar') <> MNOTE_ICON_SAVE) or
      (MNoteIconForCaption('Diagnostico Python') = MNOTE_ICON_AI) then
      raise Exception.Create('mapeamento da identidade visual inconsistente');
    AReport := 'OK: criar, salvar, abrir, buscar, substituir, projeto, ' +
      'perfis de IA local sem token, Voice Output, identidade visual e fechar';
    Result := True;
  except
    on E: Exception do AReport := 'FALHA: ' + E.Message;
  end;
  Loaded.Free;
  Voices.Free;
  VoiceSettings.Free;
  VoiceSynthesizer.Free;
  Profiles.Free;
  Project.Free;
  Results.Free;
  Search.Free;
  RemoveSmokeTree(Root, GetTempDir(False));
end;

end.
