unit mnote_neural_api_bootstrap;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TMNoteNeuralApiStatus = (nasInstalled, nasInstallerReady, nasDownloaded,
    nasUnavailable, nasError);

  TMNoteNeuralApiCompletedEvent = procedure(Sender: TObject;
    AStatus: TMNoteNeuralApiStatus; const AInstallerFile, AError: string)
    of object;

  TMNoteNeuralApiBootstrap = class;

  { TMNoteNeuralApiBootstrapThread }

  TMNoteNeuralApiBootstrapThread = class(TThread)
  private
    FOwnerService: TMNoteNeuralApiBootstrap;
    FStatus: TMNoteNeuralApiStatus;
    FInstallerFile: string;
    FError: string;
    procedure DeliverComplete;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwnerService: TMNoteNeuralApiBootstrap);
  end;

  { TMNoteNeuralApiBootstrap }

  TMNoteNeuralApiBootstrap = class
  private
    FThread: TMNoteNeuralApiBootstrapThread;
    FOnCompleted: TMNoteNeuralApiCompletedEvent;
    FExecutableFile: string;
    FDownloadFolder: string;
    function FetchText(const AURL: string): string;
    function DownloadFile(const AURL, AFileName: string): Boolean;
    procedure ThreadComplete(AStatus: TMNoteNeuralApiStatus;
      const AInstallerFile, AError: string);
    procedure ReleaseFinishedThread;
  public
    constructor Create(const AExecutableFile: string = '');
    destructor Destroy; override;
    function Start: Boolean;
    procedure Cancel;
    function Running: Boolean;
    function CheckAndDownload(out AStatus: TMNoteNeuralApiStatus;
      out AInstallerFile, AError: string): Boolean;
    function InstalledFolder: string;
    function DownloadFolder: string;
    class function IsInstalledAt(const AExecutableFile: string): Boolean;
      static;
    class function SelectLatestInstaller(const AContentsJSON: string;
      out AName, ADownloadURL, AGitSHA: string; out ASize: Int64): Boolean;
      static;
    class function VerifyGitBlob(const AFileName, AExpectedSHA: string;
      AExpectedSize: Int64): Boolean; static;
    property OnCompleted: TMNoteNeuralApiCompletedEvent read FOnCompleted
      write FOnCompleted;
  end;

implementation

uses
  fpjson, jsonparser, fphttpclient, sha1, opensslsockets, mnote_ssl_loader;

const
  CNeuralApiContentsURL =
    'https://api.github.com/repos/marcelomaurin/neural-api/contents/bin';
  CNeuralApiRawPrefix =
    'https://raw.githubusercontent.com/marcelomaurin/neural-api/';

type
  TInt64Array = array of Int64;

function IsInstallerName(const AName: string): Boolean;
var
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(AName));
  Result := (Ext = '.exe') or (Ext = '.msi');
end;

function InstallerNameScore(const AName: string): Integer;
var
  LowerName: string;
begin
  LowerName := LowerCase(AName);
  Result := 0;
  if Pos('install', LowerName) > 0 then Inc(Result, 2);
  if Pos('setup', LowerName) > 0 then Inc(Result, 2);
  if Pos('neural', LowerName) > 0 then Inc(Result);
end;

function ExtractNumbers(const AText: string): TInt64Array;
var
  I, StartAt, Count: Integer;
  NumberText: string;
  NumberValue: Int64;
begin
  Result := nil;
  SetLength(Result, 0);
  I := 1;
  while I <= Length(AText) do
  begin
    if not (AText[I] in ['0'..'9']) then
    begin
      Inc(I);
      Continue;
    end;
    StartAt := I;
    while (I <= Length(AText)) and (AText[I] in ['0'..'9']) do Inc(I);
    NumberText := Copy(AText, StartAt, I - StartAt);
    if not TryStrToInt64(NumberText, NumberValue) then NumberValue := 0;
    Count := Length(Result);
    SetLength(Result, Count + 1);
    Result[Count] := NumberValue;
  end;
end;

function CompareVersions(const ALeft, ARight: string): Integer;
var
  LeftNumbers, RightNumbers: TInt64Array;
  I, MaxCount: Integer;
  LeftValue, RightValue: Int64;
begin
  Result := 0;
  LeftNumbers := ExtractNumbers(ALeft);
  RightNumbers := ExtractNumbers(ARight);
  MaxCount := Length(LeftNumbers);
  if Length(RightNumbers) > MaxCount then MaxCount := Length(RightNumbers);
  for I := 0 to MaxCount - 1 do
  begin
    if I < Length(LeftNumbers) then LeftValue := LeftNumbers[I]
    else LeftValue := 0;
    if I < Length(RightNumbers) then RightValue := RightNumbers[I]
    else RightValue := 0;
    if LeftValue > RightValue then Exit(1);
    if LeftValue < RightValue then Exit(-1);
  end;
end;

function IsTrustedDownloadURL(const AURL: string): Boolean;
begin
  Result := Pos(LowerCase(CNeuralApiRawPrefix), LowerCase(AURL)) = 1;
end;

constructor TMNoteNeuralApiBootstrapThread.Create(
  AOwnerService: TMNoteNeuralApiBootstrap);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FOwnerService := AOwnerService;
  FStatus := nasError;
end;

procedure TMNoteNeuralApiBootstrapThread.Execute;
begin
  if Terminated or (FOwnerService = nil) then Exit;
  FOwnerService.CheckAndDownload(FStatus, FInstallerFile, FError);
  if not Terminated then Synchronize(@DeliverComplete);
end;

procedure TMNoteNeuralApiBootstrapThread.DeliverComplete;
begin
  if FOwnerService <> nil then
    FOwnerService.ThreadComplete(FStatus, FInstallerFile, FError);
end;

constructor TMNoteNeuralApiBootstrap.Create(const AExecutableFile: string);
begin
  inherited Create;
  if Trim(AExecutableFile) <> '' then
    FExecutableFile := ExpandFileName(AExecutableFile)
  else
    FExecutableFile := ExpandFileName(ParamStr(0));
  FDownloadFolder := IncludeTrailingPathDelimiter(GetAppConfigDir(False)) +
    'downloads';
end;

destructor TMNoteNeuralApiBootstrap.Destroy;
begin
  FOnCompleted := nil;
  Cancel;
  if FThread <> nil then
  begin
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
  inherited Destroy;
end;

procedure TMNoteNeuralApiBootstrap.ReleaseFinishedThread;
begin
  if (FThread <> nil) and FThread.Finished then
  begin
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
end;

function TMNoteNeuralApiBootstrap.Start: Boolean;
begin
  ReleaseFinishedThread;
  Result := FThread = nil;
  if not Result then Exit;
  FThread := TMNoteNeuralApiBootstrapThread.Create(Self);
  FThread.Start;
end;

procedure TMNoteNeuralApiBootstrap.Cancel;
begin
  if FThread <> nil then FThread.Terminate;
end;

function TMNoteNeuralApiBootstrap.Running: Boolean;
begin
  ReleaseFinishedThread;
  Result := FThread <> nil;
end;

function TMNoteNeuralApiBootstrap.InstalledFolder: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(FExecutableFile)) +
    'neural-api';
end;

function TMNoteNeuralApiBootstrap.DownloadFolder: string;
begin
  Result := FDownloadFolder;
end;

class function TMNoteNeuralApiBootstrap.IsInstalledAt(
  const AExecutableFile: string): Boolean;
var
  Folder: string;
begin
  Folder := IncludeTrailingPathDelimiter(ExtractFilePath(
    ExpandFileName(AExecutableFile))) + 'neural-api';
  Result := DirectoryExists(Folder);
end;

class function TMNoteNeuralApiBootstrap.SelectLatestInstaller(
  const AContentsJSON: string; out AName, ADownloadURL, AGitSHA: string;
  out ASize: Int64): Boolean;
var
  Data: TJSONData;
  Items: TJSONArray;
  Item: TJSONObject;
  I, BestScore, Score, VersionCompare: Integer;
  Name, URL, GitSHA, ItemType: string;
  Size: Int64;
begin
  Result := False;
  AName := '';
  ADownloadURL := '';
  AGitSHA := '';
  ASize := 0;
  BestScore := -1;
  Data := GetJSON(AContentsJSON);
  try
    if Data.JSONType <> jtArray then Exit;
    Items := TJSONArray(Data);
    for I := 0 to Items.Count - 1 do
    begin
      if Items.Items[I].JSONType <> jtObject then Continue;
      Item := TJSONObject(Items.Items[I]);
      Name := ExtractFileName(Item.Get('name', ''));
      URL := Item.Get('download_url', '');
      GitSHA := LowerCase(Item.Get('sha', ''));
      ItemType := LowerCase(Item.Get('type', ''));
      Size := Item.Get('size', Int64(0));
      if (ItemType <> 'file') or (Name = '') or not IsInstallerName(Name) or
        (Size <= 0) or (Length(GitSHA) <> 40) or
        not IsTrustedDownloadURL(URL) then Continue;
      Score := InstallerNameScore(Name);
      VersionCompare := CompareVersions(Name, AName);
      if (not Result) or (Score > BestScore) or
        ((Score = BestScore) and (VersionCompare > 0)) or
        ((Score = BestScore) and (VersionCompare = 0) and
          (CompareText(Name, AName) > 0)) then
      begin
        Result := True;
        BestScore := Score;
        AName := Name;
        ADownloadURL := URL;
        AGitSHA := GitSHA;
        ASize := Size;
      end;
    end;
  finally
    Data.Free;
  end;
end;

function TMNoteNeuralApiBootstrap.FetchText(const AURL: string): string;
var
  Client: TFPHTTPClient;
  SSLErr: string;
begin
  if not InitializeMNoteSSL(SSLErr) then
    raise Exception.Create('Falha ao inicializar OpenSSL para requisição HTTPS: ' + SSLErr);

  Client := TFPHTTPClient.Create(nil);
  try
    Client.AllowRedirect := True;
    Client.ConnectTimeout := 10000;
    Client.IOTimeout := 30000;
    Client.AddHeader('User-Agent', 'MNote2-neural-api-bootstrap');
    Client.AddHeader('Accept', 'application/vnd.github+json');
    Result := Client.Get(AURL);
  finally
    Client.Free;
  end;
end;

function TMNoteNeuralApiBootstrap.DownloadFile(const AURL,
  AFileName: string): Boolean;
var
  Client: TFPHTTPClient;
  OutputFile: TFileStream;
  SSLErr: string;
begin
  Result := False;
  if not InitializeMNoteSSL(SSLErr) then
    raise Exception.Create('Falha ao inicializar OpenSSL para download HTTPS: ' + SSLErr);

  Client := TFPHTTPClient.Create(nil);
  try
    Client.AllowRedirect := True;
    Client.ConnectTimeout := 10000;
    Client.IOTimeout := 60000;
    Client.AddHeader('User-Agent', 'MNote2-neural-api-bootstrap');
    OutputFile := TFileStream.Create(AFileName, fmCreate);
    try
      Client.Get(AURL, OutputFile);
      Result := (Client.ResponseStatusCode >= 200) and
        (Client.ResponseStatusCode < 300);
    finally
      OutputFile.Free;
    end;
  finally
    Client.Free;
  end;
end;

class function TMNoteNeuralApiBootstrap.VerifyGitBlob(const AFileName,
  AExpectedSHA: string; AExpectedSize: Int64): Boolean;
const
  CBufferSize = 65536;
var
  Context: TSHA1Context;
  Digest: TSHA1Digest;
  InputFile: TFileStream;
  Header: RawByteString;
  Buffer: array[0..CBufferSize - 1] of Byte;
  ReadCount: LongInt;
begin
  Result := False;
  if not FileExists(AFileName) then Exit;
  InputFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    if (AExpectedSize >= 0) and (InputFile.Size <> AExpectedSize) then Exit;
    Header := 'blob ' + IntToStr(InputFile.Size) + #0;
    SHA1Init(Context);
    if Length(Header) > 0 then SHA1Update(Context, Header[1], Length(Header));
    repeat
      ReadCount := InputFile.Read(Buffer, SizeOf(Buffer));
      if ReadCount > 0 then SHA1Update(Context, Buffer[0], ReadCount);
    until ReadCount = 0;
    SHA1Final(Context, Digest);
    Result := SameText(SHA1Print(Digest), AExpectedSHA);
  finally
    InputFile.Free;
  end;
end;

function TMNoteNeuralApiBootstrap.CheckAndDownload(
  out AStatus: TMNoteNeuralApiStatus; out AInstallerFile,
  AError: string): Boolean;
var
  Contents, InstallerName, DownloadURL, GitSHA, PartialFile: string;
  ExpectedSize: Int64;
begin
  Result := False;
  AStatus := nasError;
  AInstallerFile := '';
  AError := '';
  if IsInstalledAt(FExecutableFile) then
  begin
    AStatus := nasInstalled;
    Exit(True);
  end;
  try
    try
      Contents := FetchText(CNeuralApiContentsURL);
    except
      on E: Exception do
      begin
        if Pos('404', E.Message) > 0 then
        begin
          AStatus := nasUnavailable;
          AError := 'A pasta bin ainda não foi publicada no repositório neural-api.';
          Exit(False);
        end;
        raise;
      end;
    end;
    if not SelectLatestInstaller(Contents, InstallerName, DownloadURL,
      GitSHA, ExpectedSize) then
    begin
      AStatus := nasUnavailable;
      AError := 'Nenhum instalador foi publicado na pasta bin do neural-api.';
      Exit(False);
    end;
    if not ForceDirectories(FDownloadFolder) then
      raise Exception.Create('Não foi possível criar a pasta de downloads.');
    AInstallerFile := IncludeTrailingPathDelimiter(FDownloadFolder) +
      ExtractFileName(InstallerName);
    if VerifyGitBlob(AInstallerFile, GitSHA, ExpectedSize) then
    begin
      AStatus := nasInstallerReady;
      Exit(True);
    end;
    PartialFile := AInstallerFile + '.part';
    if FileExists(PartialFile) and not DeleteFile(PartialFile) then
      raise Exception.Create('Não foi possível substituir o download parcial.');
    if not DownloadFile(DownloadURL, PartialFile) then
      raise Exception.Create('O GitHub não concluiu o download do instalador.');
    if not VerifyGitBlob(PartialFile, GitSHA, ExpectedSize) then
      raise Exception.Create('O instalador baixado não passou na validação de integridade.');
    if FileExists(AInstallerFile) and not DeleteFile(AInstallerFile) then
      raise Exception.Create('Não foi possível atualizar o instalador local.');
    if not RenameFile(PartialFile, AInstallerFile) then
      raise Exception.Create('Não foi possível concluir o arquivo do instalador.');
    AStatus := nasDownloaded;
    Result := True;
  except
    on E: Exception do
    begin
      AStatus := nasError;
      AError := E.Message;
    end;
  end;
end;

procedure TMNoteNeuralApiBootstrap.ThreadComplete(
  AStatus: TMNoteNeuralApiStatus; const AInstallerFile, AError: string);
begin
  if Assigned(FOnCompleted) then
    FOnCompleted(Self, AStatus, AInstallerFile, AError);
end;

end.
