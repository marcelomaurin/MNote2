unit mnote_git_read_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Process, Pipes, mnote_service_base;

type
  TMNoteGitState = record
    Available: Boolean;
    Root: string;
    Branch: string;
    Head: string;
    Status: string;
    ErrorMessage: string;
  end;

  TMNoteGitReadService = class(TMNoteServiceBase)
  private
    function ExecuteGit(const AWorkingPath: string;
      const AArguments: array of string; out AOutput: string): Boolean;
  public
    function Inspect(const AWorkingPath: string; out AState: TMNoteGitState): Boolean;
    function ShortLog(const AWorkingPath: string; ACount: Integer;
      out ALog: string): Boolean;
    function CommitDiff(const AWorkingPath, ACommit: string;
      out ADiff: string): Boolean;
  end;

implementation

function IsCommitNameSafe(const AValue: string): Boolean;
var
  I: Integer;
begin
  Result := (Length(AValue) >= 7) and (Length(AValue) <= 40);
  if not Result then Exit;
  for I := 1 to Length(AValue) do
    if not (AValue[I] in ['0'..'9', 'a'..'f', 'A'..'F']) then Exit(False);
end;

function ReadAvailable(AStream: TInputPipeStream): string;
var
  Buffer: array[0..4095] of Byte;
  ReadCount: LongInt;
begin
  Result := '';
  while AStream.NumBytesAvailable > 0 do
  begin
    ReadCount := AStream.Read(Buffer, SizeOf(Buffer));
    if ReadCount <= 0 then Break;
    SetLength(Result, Length(Result) + ReadCount);
    Move(Buffer[0], Result[Length(Result) - ReadCount + 1], ReadCount);
  end;
end;

function TMNoteGitReadService.ExecuteGit(const AWorkingPath: string;
  const AArguments: array of string; out AOutput: string): Boolean;
var
  GitProcess: TProcess;
  I: Integer;
  ErrorOutput: string;
begin
  Result := False;
  AOutput := '';
  ErrorOutput := '';
  ClearError;
  GitProcess := TProcess.Create(nil);
  try
    GitProcess.Executable := 'git.exe';
    GitProcess.Parameters.Add('-C');
    GitProcess.Parameters.Add(ExpandFileName(AWorkingPath));
    for I := Low(AArguments) to High(AArguments) do
      GitProcess.Parameters.Add(AArguments[I]);
    GitProcess.Options := [poUsePipes, poNoConsole];
    try
      GitProcess.Execute;
      repeat
        AOutput := AOutput + ReadAvailable(GitProcess.Output);
        ErrorOutput := ErrorOutput + ReadAvailable(GitProcess.Stderr);
        if GitProcess.Running then Sleep(1);
      until not GitProcess.Running;
      AOutput := AOutput + ReadAvailable(GitProcess.Output);
      ErrorOutput := ErrorOutput + ReadAvailable(GitProcess.Stderr);
      Result := GitProcess.ExitStatus = 0;
      if not Result then SetError(Trim(ErrorOutput));
    except
      on E: Exception do SetError(E.Message);
    end;
  finally
    GitProcess.Free;
  end;
end;

function TMNoteGitReadService.Inspect(const AWorkingPath: string;
  out AState: TMNoteGitState): Boolean;
var
  Output: string;
begin
  AState.Available := False;
  AState.Root := '';
  AState.Branch := '';
  AState.Head := '';
  AState.Status := '';
  AState.ErrorMessage := '';
  if not ExecuteGit(AWorkingPath, ['rev-parse', '--show-toplevel'], Output) then
  begin
    AState.ErrorMessage := LastError;
    Exit(False);
  end;
  AState.Root := Trim(Output);
  if not ExecuteGit(AWorkingPath, ['branch', '--show-current'], Output) then Exit(False);
  AState.Branch := Trim(Output);
  if not ExecuteGit(AWorkingPath, ['rev-parse', 'HEAD'], Output) then Exit(False);
  AState.Head := Trim(Output);
  if not ExecuteGit(AWorkingPath, ['status', '--short'], Output) then Exit(False);
  AState.Status := Output;
  AState.Available := True;
  Result := True;
end;

function TMNoteGitReadService.ShortLog(const AWorkingPath: string;
  ACount: Integer; out ALog: string): Boolean;
begin
  if ACount < 1 then ACount := 10;
  if ACount > 100 then ACount := 100;
  Result := ExecuteGit(AWorkingPath, ['log', '--oneline', '--decorate',
    '-n', IntToStr(ACount)], ALog);
end;

function TMNoteGitReadService.CommitDiff(const AWorkingPath, ACommit: string;
  out ADiff: string): Boolean;
begin
  ClearError;
  if not IsCommitNameSafe(Trim(ACommit)) then
  begin
    SetError('O identificador do commit deve conter de 7 a 40 caracteres hexadecimais.');
    Exit(False);
  end;
  Result := ExecuteGit(AWorkingPath, ['show', '--format=fuller',
    '--no-ext-diff', Trim(ACommit), '--'], ADiff);
end;

end.
