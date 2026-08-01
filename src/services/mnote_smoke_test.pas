unit mnote_smoke_test;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

function RunMNoteSmokeTest(out AReport: string): Boolean;

implementation

uses
  Classes, SysUtils, mnote_search_types, mnote_text_search_service,
  mnote_project_service;

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
    AReport := 'OK: criar, salvar, abrir, buscar, substituir, projeto e fechar';
    Result := True;
  except
    on E: Exception do AReport := 'FALHA: ' + E.Message;
  end;
  Loaded.Free;
  Project.Free;
  Results.Free;
  Search.Free;
  RemoveSmokeTree(Root, GetTempDir(False));
end;

end.
