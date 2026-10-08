unit mnote_db_diagram_job;
{$mode objfpc}{$H+}{$codepage utf8}
interface
uses Classes, SysUtils, SyncObjs, ZConnection, mnote_db_diagram_model,
  mnote_db_diagram_reader;
type
  TDiagramJobStatus = record
    Done, Cancelled: Boolean;
    Position, Total: Integer;
    Stage, ErrorText: string;
  end;
  IDiagramJob = interface
    ['{0803D15D-3E33-4FDE-A576-ACF938CA3B64}']
    procedure Cancel;
    function Status: TDiagramJobStatus;
    function TakeModel: TDiagramModel;
    procedure Report(const Stage: string; Position, Total: Integer; var Cancelled: Boolean);
    procedure Complete(Model: TDiagramModel; const ErrorText: string);
  end;
function StartDiagramJob(Source: TZConnection; const Context: TDiagramContext): IDiagramJob;
implementation
type
  TDiagramJob = class(TInterfacedObject, IDiagramJob)
  private
    FLock: TCriticalSection;
    FStatus: TDiagramJobStatus;
    FModel: TDiagramModel;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Cancel;
    function Status: TDiagramJobStatus;
    function TakeModel: TDiagramModel;
    procedure Report(const Stage: string; Position, Total: Integer; var Cancelled: Boolean);
    procedure Complete(Model: TDiagramModel; const ErrorText: string);
  end;
  TDiagramWorker = class(TThread)
  private
    FJob: IDiagramJob;
    FContext: TDiagramContext;
    FPassword, FLibrary, FProperties, FCatalog, FCodePage: string;
    procedure Progress(const Stage: string; Position, Total: Integer; var Cancelled: Boolean);
  protected
    procedure Execute; override;
  public
    constructor Create(Source: TZConnection; const Context: TDiagramContext; const Job: IDiagramJob);
  end;
constructor TDiagramJob.Create;
begin inherited Create; FLock := TCriticalSection.Create; end;
destructor TDiagramJob.Destroy;
begin FModel.Free; FLock.Free; inherited Destroy; end;
procedure TDiagramJob.Cancel;
begin
  FLock.Acquire;
  try FStatus.Cancelled := True; finally FLock.Release; end;
end;
function TDiagramJob.Status: TDiagramJobStatus;
begin
  FLock.Acquire;
  try Result := FStatus; finally FLock.Release; end;
end;
function TDiagramJob.TakeModel: TDiagramModel;
begin
  Result := nil; FLock.Acquire;
  try
    if FStatus.Done and not FStatus.Cancelled then begin Result := FModel; FModel := nil; end;
  finally FLock.Release; end;
end;
procedure TDiagramJob.Report(const Stage: string; Position, Total: Integer; var Cancelled: Boolean);
begin
  FLock.Acquire;
  try
    FStatus.Stage := Stage; FStatus.Position := Position; FStatus.Total := Total;
    Cancelled := FStatus.Cancelled;
  finally FLock.Release; end;
end;
procedure TDiagramJob.Complete(Model: TDiagramModel; const ErrorText: string);
begin
  FLock.Acquire;
  try
    FModel := Model; FStatus.ErrorText := ErrorText; FStatus.Done := True;
    if FStatus.Cancelled then FreeAndNil(FModel);
  finally FLock.Release; end;
end;
constructor TDiagramWorker.Create(Source: TZConnection; const Context: TDiagramContext; const Job: IDiagramJob);
begin
  inherited Create(True); FreeOnTerminate := True;
  FJob := Job; FContext := Context;
  // Capture only values on the UI thread. The worker never touches Source or UI.
  FPassword := Source.Password; FLibrary := Source.LibraryLocation;
  FProperties := Source.Properties.Text; FCatalog := Source.Catalog;
  FCodePage := Source.ClientCodepage;
end;
procedure TDiagramWorker.Progress(const Stage: string; Position, Total: Integer; var Cancelled: Boolean);
begin FJob.Report(Stage, Position, Total, Cancelled); end;
procedure TDiagramWorker.Execute;
var Connection: TZConnection; Model: TDiagramModel; ErrorText: string; Cancelled: Boolean;
begin
  Connection := nil; Model := nil; ErrorText := '';
  try
    try
      Cancelled := False; Progress('Conectando para ler metadados...', 0, 0, Cancelled);
      if Cancelled then raise EDiagramCancelled.Create('Cancelado');
      Connection := TZConnection.Create(nil);
      Connection.Name := FContext.Profile; Connection.Protocol := FContext.Protocol;
      Connection.HostName := FContext.Host; Connection.Port := FContext.Port;
      Connection.Database := FContext.DatabaseName; Connection.User := FContext.UserName;
      Connection.Password := FPassword; Connection.LibraryLocation := FLibrary;
      Connection.Properties.Text := FProperties; Connection.Catalog := FCatalog;
      Connection.ClientCodepage := FCodePage;
      Connection.LoginPrompt := False; Connection.ReadOnly := True;
      Connection.Connect;
      Model := ReadDatabaseDiagram(Connection, FContext, @Progress);
    except
      on E: EDiagramCancelled do FJob.Cancel;
      on E: Exception do ErrorText := E.Message;
    end;
  finally
    // No thread synchronization callbacks: closing a form never waits for a driver.
    try Connection.Free; except on E: Exception do if ErrorText = '' then ErrorText := E.Message; end;
    if FPassword <> '' then ErrorText := StringReplace(ErrorText, FPassword, '[redacted]', [rfReplaceAll]);
    FPassword := ''; FProperties := '';
    FJob.Complete(Model, ErrorText);
  end;
end;
function StartDiagramJob(Source: TZConnection; const Context: TDiagramContext): IDiagramJob;
var Worker: TDiagramWorker;
begin
  if (Source = nil) or not Source.Connected then
    raise Exception.Create('Conecte o banco desta pasta antes de atualizar.');
  if DiagramContextKey(DiagramConnectionContext(Source, Context.SchemaName)) <> DiagramContextKey(Context) then
    raise Exception.Create('A conexão mudou. Reabra o diagrama pela pasta correta.');
  if Pos('sqlite', LowerCase(Context.Protocol)) > 0 then begin
    if (Context.DatabaseName = '') or (Context.DatabaseName = ':memory:') or
      (Pos('mode=memory', LowerCase(Context.DatabaseName)) > 0) then
      raise Exception.Create('O diagrama em segundo plano requer um arquivo SQLite persistido; não abre uma cópia vazia do banco em memória.');
    if not FileExists(Context.DatabaseName) then
      raise Exception.Create('Arquivo SQLite não encontrado.');
  end;
  Result := TDiagramJob.Create;
  Worker := TDiagramWorker.Create(Source, Context, Result);
  Worker.Start;
end;
end.
