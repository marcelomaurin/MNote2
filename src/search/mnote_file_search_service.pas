unit mnote_file_search_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_service_base, mnote_search_types;

type
  TMNoteFileSearchProgressEvent = procedure(Sender: TObject;
    AFilesScanned, AMatchesFound: Integer; const AFileName: string) of object;
  TMNoteFileSearchCompletedEvent = procedure(Sender: TObject;
    ACancelled: Boolean) of object;

  TMNoteFileSearchService = class;

  { TMNoteFileSearchWorker }

  TMNoteFileSearchWorker = class(TThread)
  private
    FService: TMNoteFileSearchService;
    FFolder: string;
    FQuery: string;
    FOptions: TMNoteSearchOptions;
    FResults: TMNoteSearchResults;
  protected
    procedure Execute; override;
    procedure NotifyCompleted;
  public
    constructor Create(AService: TMNoteFileSearchService;
      const AFolder, AQuery: string; const AOptions: TMNoteSearchOptions;
      AResults: TMNoteSearchResults);
  end;

  { TMNoteFileSearchService }

  TMNoteFileSearchService = class(TMNoteServiceBase)
  private
    FMaxFileSize: Int64;
    FFollowSymbolicLinks: Boolean;
    FCancelled: Boolean;
    FFilesScanned: Integer;
    FMatchesFound: Integer;
    FWorker: TMNoteFileSearchWorker;
    FOnProgress: TMNoteFileSearchProgressEvent;
    FOnCompleted: TMNoteFileSearchCompletedEvent;
    function GlobMatches(const AText, APattern: string): Boolean;
    function MatchesPatterns(const ARelativePath, APatterns: string;
      ADefaultWhenEmpty: Boolean): Boolean;
    function IsExcluded(const ARelativePath, APatterns: string): Boolean;
    function IsKnownBinaryExtension(const AFileName: string): Boolean;
    function IsBinaryFile(const AFileName: string): Boolean;
    procedure SearchDirectory(const ARoot, ADirectory, AQuery: string;
      const AOptions: TMNoteSearchOptions; AResults: TMNoteSearchResults);
    procedure SearchFile(const AFileName, AQuery: string;
      const AOptions: TMNoteSearchOptions; AResults: TMNoteSearchResults);
    function SearchFolderInternal(const AFolder, AQuery: string;
      const AOptions: TMNoteSearchOptions;
      AResults: TMNoteSearchResults): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function SearchFolder(const AFolder, AQuery: string;
      const AOptions: TMNoteSearchOptions;
      AResults: TMNoteSearchResults): Boolean;
    function StartSearch(const AFolder, AQuery: string;
      const AOptions: TMNoteSearchOptions;
      AResults: TMNoteSearchResults): Boolean;
    procedure Cancel;
    procedure WaitFor;
    function IsRunning: Boolean;
    property MaxFileSize: Int64 read FMaxFileSize write FMaxFileSize;
    property FollowSymbolicLinks: Boolean read FFollowSymbolicLinks
      write FFollowSymbolicLinks;
    property FilesScanned: Integer read FFilesScanned;
    property MatchesFound: Integer read FMatchesFound;
    property OnProgress: TMNoteFileSearchProgressEvent read FOnProgress
      write FOnProgress;
    property OnCompleted: TMNoteFileSearchCompletedEvent read FOnCompleted
      write FOnCompleted;
  end;

implementation

uses
  mnote_text_search_service;

constructor TMNoteFileSearchWorker.Create(AService: TMNoteFileSearchService;
  const AFolder, AQuery: string; const AOptions: TMNoteSearchOptions;
  AResults: TMNoteSearchResults);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FService := AService;
  FFolder := AFolder;
  FQuery := AQuery;
  FOptions := AOptions;
  FResults := AResults;
end;

procedure TMNoteFileSearchWorker.Execute;
begin
  FService.SearchFolderInternal(FFolder, FQuery, FOptions, FResults);
  if Assigned(FService.FOnCompleted) then
    Synchronize(@NotifyCompleted);
end;

procedure TMNoteFileSearchWorker.NotifyCompleted;
begin
  if Assigned(FService.FOnCompleted) then
    FService.FOnCompleted(FService, FService.FCancelled);
end;

constructor TMNoteFileSearchService.Create;
begin
  inherited Create;
  FMaxFileSize := 10 * 1024 * 1024;
end;

destructor TMNoteFileSearchService.Destroy;
begin
  Cancel;
  WaitFor;
  inherited Destroy;
end;

function TMNoteFileSearchService.GlobMatches(const AText,
  APattern: string): Boolean;
var
  TextValue, PatternValue: string;

  function MatchFrom(ATextIndex, APatternIndex: Integer): Boolean;
  var
    NextIndex: Integer;
    IsDoubleStar: Boolean;
  begin
    while APatternIndex <= Length(PatternValue) do
    begin
      if PatternValue[APatternIndex] = '*' then
      begin
        IsDoubleStar := (APatternIndex < Length(PatternValue)) and
          (PatternValue[APatternIndex + 1] = '*');
        if IsDoubleStar then Inc(APatternIndex);
        Inc(APatternIndex);
        if APatternIndex > Length(PatternValue) then
        begin
          if IsDoubleStar then Exit(True);
          Exit(Pos('/', Copy(TextValue, ATextIndex, MaxInt)) = 0);
        end;
        NextIndex := ATextIndex;
        while NextIndex <= Length(TextValue) + 1 do
        begin
          if MatchFrom(NextIndex, APatternIndex) then Exit(True);
          if (not IsDoubleStar) and (NextIndex <= Length(TextValue)) and
            (TextValue[NextIndex] = '/') then Break;
          Inc(NextIndex);
        end;
        Exit(False);
      end;
      if ATextIndex > Length(TextValue) then Exit(False);
      if PatternValue[APatternIndex] = '?' then
      begin
        if TextValue[ATextIndex] = '/' then Exit(False);
      end
      else if PatternValue[APatternIndex] <> TextValue[ATextIndex] then
        Exit(False);
      Inc(ATextIndex);
      Inc(APatternIndex);
    end;
    Result := ATextIndex > Length(TextValue);
  end;

begin
  TextValue := StringReplace(AText, '\', '/', [rfReplaceAll]);
  PatternValue := StringReplace(APattern, '\', '/', [rfReplaceAll]);
  {$IFDEF MSWINDOWS}
  TextValue := LowerCase(TextValue);
  PatternValue := LowerCase(PatternValue);
  {$ENDIF}
  Result := MatchFrom(1, 1);
end;

function TMNoteFileSearchService.MatchesPatterns(const ARelativePath,
  APatterns: string; ADefaultWhenEmpty: Boolean): Boolean;
var
  Patterns: TStringList;
  I: Integer;
  PatternText: string;
begin
  Result := ADefaultWhenEmpty;
  Patterns := TStringList.Create;
  try
    Patterns.StrictDelimiter := True;
    Patterns.Delimiter := ';';
    Patterns.DelimitedText := APatterns;
    for I := 0 to Patterns.Count - 1 do
    begin
      PatternText := Trim(Patterns[I]);
      if PatternText = '' then Continue;
      if PatternText[1] = '!' then Delete(PatternText, 1, 1);
      if Pos('/', StringReplace(PatternText, '\', '/', [rfReplaceAll])) = 0 then
      begin
        if GlobMatches(ExtractFileName(ARelativePath), PatternText) then
          Exit(True);
      end
      else if GlobMatches(ARelativePath, PatternText) then
        Exit(True);
    end;
    if Patterns.Count > 0 then Result := False;
  finally
    Patterns.Free;
  end;
end;

function TMNoteFileSearchService.IsExcluded(const ARelativePath,
  APatterns: string): Boolean;
begin
  Result := MatchesPatterns(ARelativePath, APatterns, False);
end;

function TMNoteFileSearchService.IsKnownBinaryExtension(
  const AFileName: string): Boolean;
const
  BinaryExtensions =
    '.exe;.dll;.so;.dylib;.ppu;.o;.obj;.a;.lib;.png;.jpg;.jpeg;.gif;.bmp;' +
    '.ico;.pdf;.zip;.7z;.rar;.gz;.mp3;.wav;.mp4;.avi;.mov;.db;.sqlite';
begin
  Result := Pos(';' + LowerCase(ExtractFileExt(AFileName)) + ';',
    ';' + BinaryExtensions + ';') > 0;
end;

function TMNoteFileSearchService.IsBinaryFile(const AFileName: string): Boolean;
var
  Stream: TFileStream;
  Buffer: array[0..8191] of Byte;
  ReadCount, I: Integer;
begin
  Result := IsKnownBinaryExtension(AFileName);
  if Result then Exit;
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    ReadCount := Stream.Read(Buffer, SizeOf(Buffer));
    for I := 0 to ReadCount - 1 do
      if Buffer[I] = 0 then Exit(True);
  finally
    Stream.Free;
  end;
  Result := False;
end;

procedure TMNoteFileSearchService.SearchFile(const AFileName,
  AQuery: string; const AOptions: TMNoteSearchOptions;
  AResults: TMNoteSearchResults);
var
  SourceFile: TextFile;
  LineText: string;
  LineNumber, I: Integer;
  PreviousFileMode: Byte;
  LineResults: TMNoteSearchResults;
  TextSearch: TMNoteTextSearchService;
  SearchResult: TMNoteSearchResult;
begin
  if FCancelled or IsBinaryFile(AFileName) then Exit;
  LineResults := TMNoteSearchResults.Create;
  TextSearch := TMNoteTextSearchService.Create;
  try
    AssignFile(SourceFile, AFileName);
    PreviousFileMode := FileMode;
    FileMode := 0;
    try
      Reset(SourceFile);
    finally
      FileMode := PreviousFileMode;
    end;
    try
      LineNumber := 0;
      while (not EOF(SourceFile)) and (not FCancelled) do
      begin
        ReadLn(SourceFile, LineText);
        Inc(LineNumber);
        if not TextSearch.SearchText(LineText, AQuery, AFileName,
          AOptions, LineResults) then
        begin
          SetError(TextSearch.LastError);
          FCancelled := True;
          Break;
        end;
        for I := 0 to LineResults.Count - 1 do
        begin
          SearchResult := LineResults[I];
          AResults.Add(TMNoteSearchResult.Create(AFileName, LineNumber,
            SearchResult.Column, SearchResult.Length, SearchResult.Preview,
            SearchResult.MatchedText, -1));
          Inc(FMatchesFound);
        end;
      end;
    finally
      CloseFile(SourceFile);
    end;
  finally
    TextSearch.Free;
    LineResults.Free;
  end;
end;

procedure TMNoteFileSearchService.SearchDirectory(const ARoot, ADirectory,
  AQuery: string; const AOptions: TMNoteSearchOptions;
  AResults: TMNoteSearchResults);
var
  SearchData: TSearchRec;
  FullName, RelativeName: string;
  Attributes: LongInt;
begin
  if FCancelled then Exit;
  if FindFirst(IncludeTrailingPathDelimiter(ADirectory) + '*', faAnyFile,
    SearchData) <> 0 then Exit;
  try
    repeat
      if FCancelled then Break;
      if (SearchData.Name = '.') or (SearchData.Name = '..') then Continue;
      FullName := IncludeTrailingPathDelimiter(ADirectory) + SearchData.Name;
      RelativeName := Copy(FullName,
        Length(IncludeTrailingPathDelimiter(ARoot)) + 1, MaxInt);
      RelativeName := StringReplace(RelativeName, '\', '/', [rfReplaceAll]);
      Attributes := SearchData.Attr;
      if (Attributes and faDirectory) <> 0 then
      begin
        if IsExcluded(RelativeName + '/', AOptions.ExcludePatterns) then
          Continue;
        {$IF declared(faSymLink)}
        if ((Attributes and faSymLink) <> 0) and
          (not FFollowSymbolicLinks) then Continue;
        {$ENDIF}
        SearchDirectory(ARoot, FullName, AQuery, AOptions, AResults);
      end
      else
      begin
        if IsExcluded(RelativeName, AOptions.ExcludePatterns) or
          (not MatchesPatterns(RelativeName, AOptions.IncludePatterns,
            True)) or (SearchData.Size > FMaxFileSize) then Continue;
        try
          SearchFile(FullName, AQuery, AOptions, AResults);
        except
          on E: Exception do
            SetError(Format('Falha ao pesquisar %s: %s',
              [FullName, E.Message]));
        end;
        Inc(FFilesScanned);
        if Assigned(FOnProgress) then
          FOnProgress(Self, FFilesScanned, FMatchesFound, FullName);
      end;
    until FindNext(SearchData) <> 0;
  finally
    FindClose(SearchData);
  end;
end;

function TMNoteFileSearchService.SearchFolderInternal(const AFolder,
  AQuery: string; const AOptions: TMNoteSearchOptions;
  AResults: TMNoteSearchResults): Boolean;
var
  Root: string;
begin
  ClearError;
  Result := False;
  if AResults = nil then
  begin
    SetError('A coleção de resultados não foi informada.');
    Exit;
  end;
  AResults.Clear;
  Root := ExpandFileName(AFolder);
  if not DirectoryExists(Root) then
  begin
    SetError('Pasta de pesquisa inexistente: ' + Root);
    Exit;
  end;
  if AQuery = '' then
  begin
    SetError('O texto de pesquisa não pode ser vazio.');
    Exit;
  end;
  FFilesScanned := 0;
  FMatchesFound := 0;
  SearchDirectory(Root, Root, AQuery, AOptions, AResults);
  Result := (LastError = '') and (not FCancelled);
end;

function TMNoteFileSearchService.SearchFolder(const AFolder,
  AQuery: string; const AOptions: TMNoteSearchOptions;
  AResults: TMNoteSearchResults): Boolean;
begin
  if IsRunning then
  begin
    SetError('Já existe uma pesquisa em arquivos em andamento.');
    Exit(False);
  end;
  FCancelled := False;
  Result := SearchFolderInternal(AFolder, AQuery, AOptions, AResults);
end;

function TMNoteFileSearchService.StartSearch(const AFolder,
  AQuery: string; const AOptions: TMNoteSearchOptions;
  AResults: TMNoteSearchResults): Boolean;
begin
  if IsRunning then
  begin
    SetError('Já existe uma pesquisa em arquivos em andamento.');
    Exit(False);
  end;
  WaitFor;
  FCancelled := False;
  FWorker := TMNoteFileSearchWorker.Create(Self, AFolder, AQuery,
    AOptions, AResults);
  FWorker.Start;
  Result := True;
end;

procedure TMNoteFileSearchService.Cancel;
begin
  FCancelled := True;
  if FWorker <> nil then
    FWorker.Terminate;
end;

procedure TMNoteFileSearchService.WaitFor;
begin
  if FWorker = nil then Exit;
  FWorker.WaitFor;
  FreeAndNil(FWorker);
end;

function TMNoteFileSearchService.IsRunning: Boolean;
begin
  Result := (FWorker <> nil) and (not FWorker.Finished);
end;

end.
