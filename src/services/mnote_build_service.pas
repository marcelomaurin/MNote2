unit mnote_build_service;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, mnote_process_service;

type
  TMNoteBuildOutputEvent = procedure(Sender: TObject; const AText: string;
    AIsStdErr: Boolean) of object;
  TMNoteBuildCompletedEvent = procedure(Sender: TObject; ASuccess: Boolean;
    AExitCode: Integer; const AOutput, AError: string) of object;

  TMNoteBuildService = class;

  { TMNoteBuildThread }

  TMNoteBuildThread = class(TThread)
  private
    FOwnerService: TMNoteBuildService;
    FProcess: TMNoteProcessService;
    FExecutable: string;
    FArguments: TStringList;
    FWorkingDirectory: string;
    FTimeoutMS: Cardinal;
    FChunk: string;
    FChunkIsStdErr: Boolean;
    FSuccess: Boolean;
    FOutput: string;
    FError: string;
    FExitCode: Integer;
    procedure ProcessOutput(Sender: TObject; const AText: string;
      AIsStdErr: Boolean);
    procedure DeliverOutput;
    procedure DeliverComplete;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwnerService: TMNoteBuildService;
      const AExecutable: string; AArguments: TStrings;
      const AWorkingDirectory: string; ATimeoutMS: Cardinal);
    destructor Destroy; override;
    procedure CancelExecution;
  end;

  { TMNoteBuildService }

  TMNoteBuildService = class
  private
    FThread: TMNoteBuildThread;
    FOnOutput: TMNoteBuildOutputEvent;
    FOnCompleted: TMNoteBuildCompletedEvent;
    function FindProjectFile(const ARoot: string): string;
    function LoadConfiguredProfile(const ARoot: string; ARebuild: Boolean;
      out AExecutable, AWorkingDirectory: string;
      AArguments: TStrings): Boolean;
    procedure ThreadOutput(const AText: string; AIsStdErr: Boolean);
    procedure ThreadComplete(ASuccess: Boolean; AExitCode: Integer;
      const AOutput, AError: string);
    procedure ReleaseFinishedThread;
  public
    destructor Destroy; override;
    function Prepare(const ARoot: string; ARebuild: Boolean;
      out AExecutable, AWorkingDirectory: string; AArguments: TStrings;
      out AError: string): Boolean;
    function Start(const ARoot: string; ARebuild: Boolean;
      out AError: string): Boolean;
    procedure Cancel;
    function Running: Boolean;
    property OnOutput: TMNoteBuildOutputEvent read FOnOutput write FOnOutput;
    property OnCompleted: TMNoteBuildCompletedEvent read FOnCompleted
      write FOnCompleted;
  end;

implementation

constructor TMNoteBuildThread.Create(AOwnerService: TMNoteBuildService;
  const AExecutable: string; AArguments: TStrings;
  const AWorkingDirectory: string; ATimeoutMS: Cardinal);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FOwnerService := AOwnerService;
  FExecutable := AExecutable;
  FArguments := TStringList.Create;
  FArguments.Assign(AArguments);
  FWorkingDirectory := AWorkingDirectory;
  FTimeoutMS := ATimeoutMS;
  FProcess := TMNoteProcessService.Create;
  FProcess.OnOutput := @ProcessOutput;
end;

destructor TMNoteBuildThread.Destroy;
begin
  FProcess.OnOutput := nil;
  FProcess.Free;
  FArguments.Free;
  inherited Destroy;
end;

procedure TMNoteBuildThread.ProcessOutput(Sender: TObject;
  const AText: string; AIsStdErr: Boolean);
begin
  FChunk := AText;
  FChunkIsStdErr := AIsStdErr;
  Synchronize(@DeliverOutput);
end;

procedure TMNoteBuildThread.DeliverOutput;
begin
  if FOwnerService <> nil then
    FOwnerService.ThreadOutput(FChunk, FChunkIsStdErr);
end;

procedure TMNoteBuildThread.DeliverComplete;
begin
  if FOwnerService <> nil then
    FOwnerService.ThreadComplete(FSuccess, FExitCode, FOutput, FError);
end;

procedure TMNoteBuildThread.Execute;
begin
  FSuccess := FProcess.Execute(FExecutable, FArguments,
    FWorkingDirectory, FTimeoutMS);
  FExitCode := FProcess.ExitCode;
  FOutput := FProcess.StdOut + FProcess.StdErr;
  FError := FProcess.LastError;
  Synchronize(@DeliverComplete);
end;

procedure TMNoteBuildThread.CancelExecution;
begin
  FProcess.Cancel;
end;

destructor TMNoteBuildService.Destroy;
begin
  Cancel;
  if FThread <> nil then
  begin
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
  inherited Destroy;
end;

procedure TMNoteBuildService.ReleaseFinishedThread;
begin
  if (FThread <> nil) and FThread.Finished then
  begin
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
end;

function TMNoteBuildService.FindProjectFile(const ARoot: string): string;
var
  Search: TSearchRec;
  Folder: string;
begin
  Result := '';
  Folder := IncludeTrailingPathDelimiter(ExpandFileName(ARoot));
  if FindFirst(Folder + '*.lpi', faAnyFile and not faDirectory, Search) = 0 then
  try
    Result := Folder + Search.Name;
    Exit;
  finally
    FindClose(Search);
  end;
  Folder := IncludeTrailingPathDelimiter(Folder + 'src');
  if FindFirst(Folder + '*.lpi', faAnyFile and not faDirectory, Search) = 0 then
  try
    Result := Folder + Search.Name;
  finally
    FindClose(Search);
  end;
end;

function JSONString(AObject: TJSONObject; const AName,
  ADefault: string): string;
var
  Data: TJSONData;
begin
  Result := ADefault;
  if AObject = nil then Exit;
  Data := AObject.Find(AName);
  if (Data <> nil) and (Data.JSONType = jtString) then Result := Data.AsString;
end;

function TMNoteBuildService.LoadConfiguredProfile(const ARoot: string;
  ARebuild: Boolean; out AExecutable, AWorkingDirectory: string;
  AArguments: TStrings): Boolean;
var
  ConfigFile, ConfigText, ProfileName, ArgumentName, Value: string;
  Stream: TStringList;
  Data: TJSONData;
  RootObject, Profiles, Profile: TJSONObject;
  ArgumentData: TJSONData;
  ArgumentArray: TJSONArray;
  I: Integer;
begin
  Result := False;
  ConfigFile := IncludeTrailingPathDelimiter(ARoot) + '.mnote' + PathDelim +
    'build.json';
  if not FileExists(ConfigFile) then Exit;
  Stream := TStringList.Create;
  Data := nil;
  try
    Stream.LoadFromFile(ConfigFile);
    ConfigText := Stream.Text;
    Data := GetJSON(ConfigText);
    if not (Data is TJSONObject) then Exit;
    RootObject := TJSONObject(Data);
    ProfileName := JSONString(RootObject, 'active', 'default');
    if not (RootObject.Find('profiles') is TJSONObject) then Exit;
    Profiles := TJSONObject(RootObject.Find('profiles'));
    if not (Profiles.Find(ProfileName) is TJSONObject) then Exit;
    Profile := TJSONObject(Profiles.Find(ProfileName));
    AExecutable := JSONString(Profile, 'executable', '');
    AWorkingDirectory := JSONString(Profile, 'working_directory', '.');
    if AWorkingDirectory = '.' then AWorkingDirectory := ARoot
    else if ExtractFileDrive(AWorkingDirectory) = '' then
      AWorkingDirectory := ExpandFileName(IncludeTrailingPathDelimiter(ARoot) +
        AWorkingDirectory);
    if (ExtractFileDrive(AExecutable) = '') and
      FileExists(IncludeTrailingPathDelimiter(ARoot) + AExecutable) then
      AExecutable := ExpandFileName(IncludeTrailingPathDelimiter(ARoot) +
        AExecutable);
    if ARebuild then ArgumentName := 'rebuild_arguments'
    else ArgumentName := 'build_arguments';
    ArgumentData := Profile.Find(ArgumentName);
    if not (ArgumentData is TJSONArray) then Exit;
    ArgumentArray := TJSONArray(ArgumentData);
    AArguments.Clear;
    for I := 0 to ArgumentArray.Count - 1 do
    begin
      Value := ArgumentArray.Strings[I];
      Value := StringReplace(Value, '${projectRoot}', ARoot, [rfReplaceAll]);
      AArguments.Add(Value);
    end;
    Result := AExecutable <> '';
  finally
    Data.Free;
    Stream.Free;
  end;
end;

function TMNoteBuildService.Prepare(const ARoot: string; ARebuild: Boolean;
  out AExecutable, AWorkingDirectory: string; AArguments: TStrings;
  out AError: string): Boolean;
var
  ProjectFile: string;
begin
  Result := False;
  AError := '';
  AExecutable := '';
  AWorkingDirectory := '';
  AArguments.Clear;
  if not DirectoryExists(ARoot) then
  begin
    AError := 'A pasta do projeto não existe.';
    Exit;
  end;
  try
    if LoadConfiguredProfile(ExpandFileName(ARoot), ARebuild, AExecutable,
      AWorkingDirectory, AArguments) then Exit(True);
  except
    on E: Exception do
    begin
      AError := 'Perfil de build inválido: ' + E.Message;
      Exit;
    end;
  end;
  ProjectFile := FindProjectFile(ARoot);
  if ProjectFile = '' then
  begin
    AError := 'Nenhum projeto Lazarus (.lpi) ou perfil .mnote/build.json foi encontrado.';
    Exit;
  end;
  {$IFDEF WINDOWS}
  if FileExists('C:\lazarus\lazbuild.exe') then
    AExecutable := 'C:\lazarus\lazbuild.exe'
  else
    AExecutable := 'lazbuild.exe';
  {$ELSE}
  AExecutable := 'lazbuild';
  {$ENDIF}
  AWorkingDirectory := ExtractFilePath(ProjectFile);
  AArguments.Add('--build-mode=Default');
  if ARebuild then AArguments.Add('--build-all');
  AArguments.Add(ProjectFile);
  Result := True;
end;

function TMNoteBuildService.Start(const ARoot: string; ARebuild: Boolean;
  out AError: string): Boolean;
var
  ExecutableName, WorkingDirectory: string;
  Arguments: TStringList;
begin
  ReleaseFinishedThread;
  if Running then
  begin
    AError := 'Já existe um build em execução.';
    Exit(False);
  end;
  Arguments := TStringList.Create;
  try
    if not Prepare(ARoot, ARebuild, ExecutableName, WorkingDirectory,
      Arguments, AError) then Exit(False);
    FThread := TMNoteBuildThread.Create(Self, ExecutableName, Arguments,
      WorkingDirectory, 10 * 60 * 1000);
    FThread.Start;
    Result := True;
  finally
    Arguments.Free;
  end;
end;

procedure TMNoteBuildService.Cancel;
begin
  if FThread <> nil then FThread.CancelExecution;
end;

function TMNoteBuildService.Running: Boolean;
begin
  Result := (FThread <> nil) and (not FThread.Finished);
end;

procedure TMNoteBuildService.ThreadOutput(const AText: string;
  AIsStdErr: Boolean);
begin
  if Assigned(FOnOutput) then FOnOutput(Self, AText, AIsStdErr);
end;

procedure TMNoteBuildService.ThreadComplete(ASuccess: Boolean;
  AExitCode: Integer; const AOutput, AError: string);
begin
  if Assigned(FOnCompleted) then
    FOnCompleted(Self, ASuccess, AExitCode, AOutput, AError);
end;

end.
