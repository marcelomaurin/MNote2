unit mnote_process_service;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, Pipes, SyncObjs;

type
  TMNoteProcessOutputEvent = procedure(Sender: TObject; const AText: string;
    AIsStdErr: Boolean) of object;

  { TMNoteProcessService }

  TMNoteProcessService = class
  private
    FLock: TCriticalSection;
    FProcess: TProcess;
    FRunning: Boolean;
    FCancelRequested: Boolean;
    FTimedOut: Boolean;
    FWasCancelled: Boolean;
    FExitCode: Integer;
    FStdOut: string;
    FStdErr: string;
    FLastError: string;
    FOnOutput: TMNoteProcessOutputEvent;
    class var FExecutionCount: Integer;
    procedure ReadPipe(APipe: TInputPipeStream; AIsStdErr: Boolean);
    procedure StopProcess;
  public
    constructor Create;
    destructor Destroy; override;
    function Execute(const AExecutable: string; AArguments: TStrings;
      const AWorkingDirectory: string; ATimeoutMS: Cardinal): Boolean;
    procedure Cancel;
    class function ExecutionCount: Integer; static;
    property Running: Boolean read FRunning;
    property TimedOut: Boolean read FTimedOut;
    property WasCancelled: Boolean read FWasCancelled;
    property ExitCode: Integer read FExitCode;
    property StdOut: string read FStdOut;
    property StdErr: string read FStdErr;
    property LastError: string read FLastError;
    property OnOutput: TMNoteProcessOutputEvent read FOnOutput write FOnOutput;
  end;

implementation

constructor TMNoteProcessService.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
end;

destructor TMNoteProcessService.Destroy;
begin
  Cancel;
  FLock.Free;
  inherited Destroy;
end;

procedure TMNoteProcessService.ReadPipe(APipe: TInputPipeStream;
  AIsStdErr: Boolean);
var
  Buffer: array[0..4095] of Byte;
  Available, ReadCount: LongInt;
  Chunk: string;
begin
  if APipe = nil then Exit;
  repeat
    Available := APipe.NumBytesAvailable;
    if Available <= 0 then Exit;
    if Available > SizeOf(Buffer) then Available := SizeOf(Buffer);
    ReadCount := APipe.Read(Buffer, Available);
    if ReadCount <= 0 then Exit;
    SetLength(Chunk, ReadCount);
    Move(Buffer[0], Chunk[1], ReadCount);
    if AIsStdErr then
      FStdErr := FStdErr + Chunk
    else
      FStdOut := FStdOut + Chunk;
    if Assigned(FOnOutput) then FOnOutput(Self, Chunk, AIsStdErr);
  until ReadCount = 0;
end;

procedure TMNoteProcessService.StopProcess;
begin
  FLock.Acquire;
  try
    if (FProcess <> nil) and FProcess.Running then
      FProcess.Terminate(1);
  finally
    FLock.Release;
  end;
end;

function TMNoteProcessService.Execute(const AExecutable: string;
  AArguments: TStrings; const AWorkingDirectory: string;
  ATimeoutMS: Cardinal): Boolean;
var
  StartedAt: QWord;
  I: Integer;
  ProcessInstance: TProcess;
begin
  Result := False;
  Inc(FExecutionCount);
  if FRunning then
  begin
    FLastError := 'Já existe um processo em execução.';
    Exit;
  end;
  FLastError := '';
  FStdOut := '';
  FStdErr := '';
  FExitCode := -1;
  FTimedOut := False;
  FWasCancelled := False;
  FCancelRequested := False;
  if Trim(AExecutable) = '' then
  begin
    FLastError := 'Executável não informado.';
    Exit;
  end;

  ProcessInstance := TProcess.Create(nil);
  FLock.Acquire;
  try
    FProcess := ProcessInstance;
    FRunning := True;
  finally
    FLock.Release;
  end;
  try
    try
      ProcessInstance.Executable := AExecutable;
    if AWorkingDirectory <> '' then
      ProcessInstance.CurrentDirectory := AWorkingDirectory;
    ProcessInstance.Options := [poUsePipes, poNoConsole];
    for I := 0 to AArguments.Count - 1 do
      ProcessInstance.Parameters.Add(AArguments[I]);
    ProcessInstance.Execute;
    StartedAt := GetTickCount64;
    while ProcessInstance.Running do
    begin
      ReadPipe(ProcessInstance.Output, False);
      ReadPipe(ProcessInstance.Stderr, True);
      if FCancelRequested then
      begin
        FWasCancelled := True;
        StopProcess;
      end
      else if (ATimeoutMS > 0) and
        (GetTickCount64 - StartedAt >= ATimeoutMS) then
      begin
        FTimedOut := True;
        StopProcess;
      end;
      Sleep(5);
    end;
    ReadPipe(ProcessInstance.Output, False);
    ReadPipe(ProcessInstance.Stderr, True);
    FExitCode := ProcessInstance.ExitStatus;
    if FTimedOut then
      FLastError := 'Tempo limite de execução excedido.'
    else if FWasCancelled then
      FLastError := 'Execução cancelada.'
    else if FExitCode <> 0 then
      FLastError := Format('O processo terminou com código %d.', [FExitCode]);
    Result := (FExitCode = 0) and (not FTimedOut) and (not FWasCancelled);
  except
    on E: Exception do
    begin
      FLastError := E.Message;
      try
        if ProcessInstance.Running then ProcessInstance.Terminate(1);
      except
        { Preserve the original execution/callback error. }
      end;
      try
        while ProcessInstance.Running do Sleep(1);
      except
        { The process may already have been released by the OS. }
      end;
    end;
    end;
  finally
    FLock.Acquire;
    try
      FProcess := nil;
      FRunning := False;
    finally
      FLock.Release;
    end;
    ProcessInstance.Free;
  end;
end;

class function TMNoteProcessService.ExecutionCount: Integer;
begin
  Result := FExecutionCount;
end;

procedure TMNoteProcessService.Cancel;
begin
  FCancelRequested := True;
  StopProcess;
end;

end.
