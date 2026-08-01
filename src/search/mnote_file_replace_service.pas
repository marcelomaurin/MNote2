unit mnote_file_replace_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs, mnote_service_base, mnote_search_types;

type
  { TMNoteFileReplaceChange }

  TMNoteFileReplaceChange = class
  private
    FFileName: string;
    FEnabled: Boolean;
    FMatchCount: Integer;
    FOriginalHash: string;
  public
    constructor Create(const AFileName: string; AMatchCount: Integer;
      const AOriginalHash: string);
    property FileName: string read FFileName;
    property Enabled: Boolean read FEnabled write FEnabled;
    property MatchCount: Integer read FMatchCount;
    property OriginalHash: string read FOriginalHash;
  end;

  { TMNoteFileReplacePreview }

  TMNoteFileReplacePreview = class
  private
    FChanges: TObjectList;
    FQuery: string;
    FReplacement: string;
    FOptions: TMNoteSearchOptions;
    function GetCount: Integer;
    function GetChange(AIndex: Integer): TMNoteFileReplaceChange;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    property Query: string read FQuery;
    property Replacement: string read FReplacement;
    property Options: TMNoteSearchOptions read FOptions;
    property Count: Integer read GetCount;
    property Changes[AIndex: Integer]: TMNoteFileReplaceChange
      read GetChange; default;
  end;

  TMNoteBeforeApplyFileEvent = function(Sender: TObject;
    const AFileName: string; AFileIndex: Integer): Boolean of object;

  { TMNoteFileReplaceService }

  TMNoteFileReplaceService = class(TMNoteServiceBase)
  private
    FOnBeforeApplyFile: TMNoteBeforeApplyFileEvent;
    function ReadFileText(const AFileName: string; out AText: string): Boolean;
    function WriteFileText(const AFileName, AText: string): Boolean;
    function ContentHash(const AText: string): string;
    function UniqueSiblingName(const AFileName, ASuffix: string): string;
    function AtomicReplaceFile(const AFileName, ANewText: string;
      out ABackupName: string): Boolean;
  public
    function BuildPreview(const AQuery, AReplacement: string;
      const AOptions: TMNoteSearchOptions; AResults: TMNoteSearchResults;
      APreview: TMNoteFileReplacePreview): Boolean;
    function ApplyPreview(APreview: TMNoteFileReplacePreview;
      out AFilesChanged, AReplacements: Integer): Boolean;
    property OnBeforeApplyFile: TMNoteBeforeApplyFileEvent
      read FOnBeforeApplyFile write FOnBeforeApplyFile;
  end;

implementation

uses
  mnote_text_search_service;

type
  TAppliedFile = record
    FileName: string;
    BackupName: string;
  end;
  TAppliedFiles = array of TAppliedFile;

constructor TMNoteFileReplaceChange.Create(const AFileName: string;
  AMatchCount: Integer; const AOriginalHash: string);
begin
  inherited Create;
  FFileName := AFileName;
  FMatchCount := AMatchCount;
  FOriginalHash := AOriginalHash;
  FEnabled := True;
end;

constructor TMNoteFileReplacePreview.Create;
begin
  inherited Create;
  FChanges := TObjectList.Create(True);
end;

destructor TMNoteFileReplacePreview.Destroy;
begin
  FChanges.Free;
  inherited Destroy;
end;

function TMNoteFileReplacePreview.GetCount: Integer;
begin
  Result := FChanges.Count;
end;

function TMNoteFileReplacePreview.GetChange(
  AIndex: Integer): TMNoteFileReplaceChange;
begin
  Result := TMNoteFileReplaceChange(FChanges[AIndex]);
end;

procedure TMNoteFileReplacePreview.Clear;
begin
  FChanges.Clear;
  FQuery := '';
  FReplacement := '';
end;

function TMNoteFileReplaceService.ReadFileText(const AFileName: string;
  out AText: string): Boolean;
var
  Stream: TFileStream;
begin
  Result := False;
  AText := '';
  try
    Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
    try
      SetLength(AText, Stream.Size);
      if Stream.Size > 0 then
        Stream.ReadBuffer(AText[1], Stream.Size);
    finally
      Stream.Free;
    end;
    Result := True;
  except
    on E: Exception do
      SetError(Format('Falha ao ler %s: %s', [AFileName, E.Message]));
  end;
end;

function TMNoteFileReplaceService.WriteFileText(const AFileName,
  AText: string): Boolean;
var
  Stream: TFileStream;
begin
  Result := False;
  try
    Stream := TFileStream.Create(AFileName, fmCreate);
    try
      if AText <> '' then
        Stream.WriteBuffer(AText[1], Length(AText));
    finally
      Stream.Free;
    end;
    Result := True;
  except
    on E: Exception do
      SetError(Format('Falha ao escrever %s: %s', [AFileName, E.Message]));
  end;
end;

function TMNoteFileReplaceService.ContentHash(const AText: string): string;
var
  Hash: QWord;
  I: Integer;
begin
  Hash := QWord($CBF29CE484222325);
  for I := 1 to Length(AText) do
  begin
    Hash := Hash xor Byte(AText[I]);
    Hash := Hash * QWord($100000001B3);
  end;
  Result := IntToHex(Hash, 16);
end;

function TMNoteFileReplaceService.UniqueSiblingName(const AFileName,
  ASuffix: string): string;
var
  Attempt: Integer;
begin
  Attempt := 0;
  repeat
    Result := AFileName + ASuffix + IntToHex(GetTickCount64, 12) + '-' +
      IntToStr(Attempt);
    Inc(Attempt);
  until not FileExists(Result);
end;

function TMNoteFileReplaceService.AtomicReplaceFile(const AFileName,
  ANewText: string; out ABackupName: string): Boolean;
var
  TemporaryName: string;
begin
  Result := False;
  ABackupName := '';
  TemporaryName := UniqueSiblingName(AFileName, '.mnote-tmp-');
  if not WriteFileText(TemporaryName, ANewText) then Exit;
  ABackupName := UniqueSiblingName(AFileName, '.mnote-backup-');
  if not RenameFile(AFileName, ABackupName) then
  begin
    DeleteFile(TemporaryName);
    SetError('Não foi possível criar o backup de ' + AFileName);
    ABackupName := '';
    Exit;
  end;
  if not RenameFile(TemporaryName, AFileName) then
  begin
    RenameFile(ABackupName, AFileName);
    DeleteFile(TemporaryName);
    SetError('Não foi possível concluir a gravação atômica de ' + AFileName);
    ABackupName := '';
    Exit;
  end;
  Result := True;
end;

function TMNoteFileReplaceService.BuildPreview(const AQuery,
  AReplacement: string; const AOptions: TMNoteSearchOptions;
  AResults: TMNoteSearchResults;
  APreview: TMNoteFileReplacePreview): Boolean;
var
  FileNames: TStringList;
  I, Existing: Integer;
  Text: string;
begin
  ClearError;
  Result := False;
  if (AResults = nil) or (APreview = nil) then
  begin
    SetError('Resultados e preview são obrigatórios.');
    Exit;
  end;
  APreview.Clear;
  APreview.FQuery := AQuery;
  APreview.FReplacement := AReplacement;
  APreview.FOptions := AOptions;
  FileNames := TStringList.Create;
  try
    FileNames.Sorted := True;
    FileNames.Duplicates := dupIgnore;
    for I := 0 to AResults.Count - 1 do
    begin
      Existing := FileNames.IndexOf(AResults[I].FileName);
      if Existing < 0 then
        FileNames.AddObject(AResults[I].FileName, TObject(PtrInt(1)))
      else
        FileNames.Objects[Existing] := TObject(
          PtrInt(FileNames.Objects[Existing]) + 1);
    end;
    for I := 0 to FileNames.Count - 1 do
    begin
      if not ReadFileText(FileNames[I], Text) then Exit;
      APreview.FChanges.Add(TMNoteFileReplaceChange.Create(FileNames[I],
        PtrInt(FileNames.Objects[I]), ContentHash(Text)));
    end;
    Result := True;
  finally
    FileNames.Free;
  end;
end;

function TMNoteFileReplaceService.ApplyPreview(
  APreview: TMNoteFileReplacePreview; out AFilesChanged,
  AReplacements: Integer): Boolean;
var
  Applied: TAppliedFiles;
  I, ReplaceCount: Integer;
  Change: TMNoteFileReplaceChange;
  OriginalText, NewText, BackupName: string;
  TextService: TMNoteTextSearchService;

  procedure Rollback;
  var
    RollbackIndex: Integer;
  begin
    for RollbackIndex := High(Applied) downto 0 do
    begin
      if FileExists(Applied[RollbackIndex].FileName) then
        DeleteFile(Applied[RollbackIndex].FileName);
      RenameFile(Applied[RollbackIndex].BackupName,
        Applied[RollbackIndex].FileName);
    end;
  end;

begin
  ClearError;
  Result := False;
  AFilesChanged := 0;
  AReplacements := 0;
  SetLength(Applied, 0);
  if APreview = nil then
  begin
    SetError('O preview de substituição não foi informado.');
    Exit;
  end;
  TextService := TMNoteTextSearchService.Create;
  try
    for I := 0 to APreview.Count - 1 do
    begin
      Change := APreview[I];
      if not Change.Enabled then Continue;
      if Assigned(FOnBeforeApplyFile) and
        (not FOnBeforeApplyFile(Self, Change.FileName, I)) then
      begin
        SetError('Aplicação cancelada antes de alterar ' + Change.FileName);
        Rollback;
        Exit;
      end;
      if not ReadFileText(Change.FileName, OriginalText) then
      begin
        Rollback;
        Exit;
      end;
      if ContentHash(OriginalText) <> Change.OriginalHash then
      begin
        SetError('O arquivo mudou após o preview: ' + Change.FileName);
        Rollback;
        Exit;
      end;
      if not TextService.ReplaceText(OriginalText, APreview.Query,
        APreview.Replacement, APreview.Options, NewText, ReplaceCount) then
      begin
        SetError(TextService.LastError);
        Rollback;
        Exit;
      end;
      if ReplaceCount = 0 then Continue;
      if not AtomicReplaceFile(Change.FileName, NewText, BackupName) then
      begin
        Rollback;
        Exit;
      end;
      SetLength(Applied, Length(Applied) + 1);
      Applied[High(Applied)].FileName := Change.FileName;
      Applied[High(Applied)].BackupName := BackupName;
      Inc(AFilesChanged);
      Inc(AReplacements, ReplaceCount);
    end;
    for I := 0 to High(Applied) do
      DeleteFile(Applied[I].BackupName);
    Result := True;
  finally
    TextService.Free;
  end;
end;

end.
