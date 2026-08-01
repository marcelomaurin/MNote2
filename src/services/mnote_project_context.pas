unit mnote_project_context;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, StrUtils, mnote_service_base, mnote_project_service;

type
  TMNoteProjectKind = (mpkNone, mpkFolder, mpkMNote, mpkLazarus,
    mpkLegacyDatabase);

  { TMNoteProjectContext }

  TMNoteProjectContext = class(TMNoteServiceBase)
  private
    FRootPath: string;
    FProjectFile: string;
    FDisplayName: string;
    FKind: TMNoteProjectKind;
    FIsOpen: Boolean;
    function FindFirstFile(const ARoot, AMask: string): string;
    function ReadMNoteName(const AFileName: string): string;
    function ValidateName(const AName: string): Boolean;
  public
    procedure Close;
    function Open(const APath: string): Boolean;
    function CreateNew(const ALocation, AName, ADescription: string;
      ACreateProjectFolder: Boolean): Boolean;
    function PreferredPath: string;
    property RootPath: string read FRootPath;
    property ProjectFile: string read FProjectFile;
    property DisplayName: string read FDisplayName;
    property Kind: TMNoteProjectKind read FKind;
    property IsOpen: Boolean read FIsOpen;
  end;

function MNoteProjectKindName(AKind: TMNoteProjectKind): string;

implementation

function MNoteProjectKindName(AKind: TMNoteProjectKind): string;
const
  Names: array[TMNoteProjectKind] of string = ('Nenhum', 'Pasta', 'MNote2',
    'Lazarus', 'Projeto legado');
begin
  Result := Names[AKind];
end;

procedure TMNoteProjectContext.Close;
begin
  ClearError;
  FRootPath := '';
  FProjectFile := '';
  FDisplayName := '';
  FKind := mpkNone;
  FIsOpen := False;
end;

function TMNoteProjectContext.FindFirstFile(const ARoot,
  AMask: string): string;
var
  Search: TSearchRec;
begin
  Result := '';
  if FindFirst(IncludeTrailingPathDelimiter(ARoot) + AMask, faAnyFile,
    Search) <> 0 then Exit;
  try
    repeat
      if (Search.Attr and faDirectory = 0) then
        Exit(IncludeTrailingPathDelimiter(ARoot) + Search.Name);
    until FindNext(Search) <> 0;
  finally
    FindClose(Search);
  end;
end;

function TMNoteProjectContext.ReadMNoteName(const AFileName: string): string;
var
  Service: TMNoteProjectService;
begin
  Result := '';
  Service := TMNoteProjectService.Create;
  try
    if Service.Load(AFileName) then Result := Trim(Service.Project.Name);
  finally
    Service.Free;
  end;
end;

function TMNoteProjectContext.ValidateName(const AName: string): Boolean;
const
  InvalidChars = '\/:*?"<>|';
var
  I: Integer;
begin
  Result := False;
  if Trim(AName) = '' then
  begin
    SetError('Informe o nome do projeto.');
    Exit;
  end;
  for I := 1 to Length(InvalidChars) do
    if Pos(Copy(InvalidChars, I, 1), AName) > 0 then
    begin
      SetError('O nome do projeto contém um caractere inválido.');
      Exit;
    end;
  Result := True;
end;

function TMNoteProjectContext.Open(const APath: string): Boolean;
var
  Candidate, Root, Extension, NewProjectFile, NewDisplayName: string;
  NewKind: TMNoteProjectKind;
begin
  Result := False;
  ClearError;
  NewProjectFile := '';
  NewDisplayName := '';
  NewKind := mpkNone;
  Candidate := ExpandFileName(Trim(APath));
  if DirectoryExists(Candidate) then
  begin
    Root := ExcludeTrailingPathDelimiter(Candidate);
    NewProjectFile := FindFirstFile(Root, '*.mnoteproj.json');
    if NewProjectFile <> '' then NewKind := mpkMNote
    else
    begin
      NewProjectFile := FindFirstFile(Root, '*.lpi');
      if NewProjectFile <> '' then NewKind := mpkLazarus
      else
      begin
        NewProjectFile := FindFirstFile(Root, '*.db');
        if NewProjectFile <> '' then NewKind := mpkLegacyDatabase
        else NewKind := mpkFolder;
      end;
    end;
  end
  else if FileExists(Candidate) then
  begin
    Root := ExcludeTrailingPathDelimiter(ExtractFileDir(Candidate));
    NewProjectFile := Candidate;
    Extension := LowerCase(ExtractFileExt(Candidate));
    if AnsiEndsText('.mnoteproj.json', Candidate) then NewKind := mpkMNote
    else if (Extension = '.lpi') or (Extension = '.lpr') then
      NewKind := mpkLazarus
    else if Extension = '.db' then NewKind := mpkLegacyDatabase
    else NewKind := mpkFolder;
  end
  else
  begin
    SetError('O projeto ou a pasta não existe: ' + APath);
    Exit;
  end;

  Root := ExpandFileName(Root);
  if NewKind = mpkMNote then
  begin
    NewDisplayName := ReadMNoteName(NewProjectFile);
    if NewDisplayName = '' then
    begin
      SetError('O descritor de projeto é inválido ou não possui nome.');
      Exit;
    end;
  end;
  if NewDisplayName = '' then
  begin
    if NewProjectFile <> '' then
      NewDisplayName := ChangeFileExt(ExtractFileName(NewProjectFile), '')
    else
      NewDisplayName := ExtractFileName(Root);
    if AnsiEndsText('.mnoteproj', LowerCase(NewDisplayName)) then
      NewDisplayName := ChangeFileExt(NewDisplayName, '');
  end;
  FRootPath := Root;
  FProjectFile := NewProjectFile;
  FDisplayName := NewDisplayName;
  FKind := NewKind;
  FIsOpen := True;
  Result := True;
end;

function TMNoteProjectContext.CreateNew(const ALocation, AName,
  ADescription: string; ACreateProjectFolder: Boolean): Boolean;
var
  Root, NewProjectFile: string;
  Service: TMNoteProjectService;
begin
  Result := False;
  ClearError;
  if not ValidateName(AName) then Exit;
  if not DirectoryExists(ALocation) then
  begin
    SetError('A pasta de localização não existe.');
    Exit;
  end;
  Root := ExpandFileName(ALocation);
  if ACreateProjectFolder then
    Root := IncludeTrailingPathDelimiter(Root) + Trim(AName);
  if not ForceDirectories(Root) then
  begin
    SetError('Não foi possível criar a pasta do projeto.');
    Exit;
  end;
  NewProjectFile := IncludeTrailingPathDelimiter(Root) + Trim(AName) +
    '.mnoteproj.json';
  if FileExists(NewProjectFile) then
  begin
    SetError('Já existe um projeto com esse nome na pasta selecionada.');
    Exit;
  end;
  Service := TMNoteProjectService.Create;
  try
    Service.NewProject(Trim(AName), Root);
    Service.Project.Description := Trim(ADescription);
    if not Service.SaveAs(NewProjectFile) then
    begin
      SetError(Service.LastError);
      Exit;
    end;
  finally
    Service.Free;
  end;
  Result := Open(NewProjectFile);
end;

function TMNoteProjectContext.PreferredPath: string;
begin
  if FProjectFile <> '' then Result := FProjectFile else Result := FRootPath;
end;

end.
