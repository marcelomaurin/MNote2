unit mnote_terminal_panel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, StdCtrls, mnote_process_service;

type
  TMNoteTerminalPanel = class;

  { TMNoteTerminalThread }

  TMNoteTerminalThread = class(TThread)
  private
    FOwnerPanel: TMNoteTerminalPanel;
    FService: TMNoteProcessService;
    FCommand: string;
    FWorkingDirectory: string;
    FChunk: string;
    FChunkIsStdErr: Boolean;
    FSuccess: Boolean;
    FError: string;
    procedure ProcessOutput(Sender: TObject; const AText: string;
      AIsStdErr: Boolean);
    procedure DeliverOutput;
    procedure DeliverComplete;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwnerPanel: TMNoteTerminalPanel; const ACommand,
      AWorkingDirectory: string);
    destructor Destroy; override;
    procedure CancelExecution;
  end;

  { TMNoteTerminalPanel }

  TMNoteTerminalPanel = class(TComponent)
  private
    FThread: TMNoteTerminalThread;
    FCommandEdit: TEdit;
    FRunButton: TButton;
    FStopButton: TButton;
    FOutput: TMemo;
    FWorkingDirectory: string;
    procedure RunClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure CommandKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AppendOutput(const AText: string; AIsStdErr: Boolean);
    procedure ExecutionCompleted(ASuccess: Boolean; const AError: string);
    procedure ReleaseFinishedThread;
  public
    destructor Destroy; override;
    procedure Initialize(AParent: TWinControl; const AWorkingDirectory: string);
    procedure SetWorkingDirectory(const AWorkingDirectory: string);
    procedure ExecuteCommand(const ACommand: string);
    procedure Cancel;
  end;

implementation

uses
  LCLType;

constructor TMNoteTerminalThread.Create(AOwnerPanel: TMNoteTerminalPanel;
  const ACommand, AWorkingDirectory: string);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FOwnerPanel := AOwnerPanel;
  FCommand := ACommand;
  FWorkingDirectory := AWorkingDirectory;
  FService := TMNoteProcessService.Create;
  FService.OnOutput := @ProcessOutput;
end;

destructor TMNoteTerminalThread.Destroy;
begin
  FService.OnOutput := nil;
  FService.Free;
  inherited Destroy;
end;

procedure TMNoteTerminalThread.ProcessOutput(Sender: TObject;
  const AText: string; AIsStdErr: Boolean);
begin
  FChunk := AText;
  FChunkIsStdErr := AIsStdErr;
  Synchronize(@DeliverOutput);
end;

procedure TMNoteTerminalThread.DeliverOutput;
begin
  if FOwnerPanel <> nil then
    FOwnerPanel.AppendOutput(FChunk, FChunkIsStdErr);
end;

procedure TMNoteTerminalThread.DeliverComplete;
begin
  if FOwnerPanel <> nil then
    FOwnerPanel.ExecutionCompleted(FSuccess, FError);
end;

procedure TMNoteTerminalThread.Execute;
var
  Arguments: TStringList;
  ExecutableName: string;
begin
  Arguments := TStringList.Create;
  try
    {$IFDEF WINDOWS}
    ExecutableName := GetEnvironmentVariable('COMSPEC');
    if ExecutableName = '' then ExecutableName := 'cmd.exe';
    Arguments.Add('/D');
    Arguments.Add('/S');
    Arguments.Add('/C');
    Arguments.Add(FCommand);
    {$ELSE}
    ExecutableName := '/bin/sh';
    Arguments.Add('-c');
    Arguments.Add(FCommand);
    {$ENDIF}
    FSuccess := FService.Execute(ExecutableName, Arguments,
      FWorkingDirectory, 0);
    FError := FService.LastError;
  finally
    Arguments.Free;
  end;
  Synchronize(@DeliverComplete);
end;

procedure TMNoteTerminalThread.CancelExecution;
begin
  FService.Cancel;
end;

destructor TMNoteTerminalPanel.Destroy;
begin
  Cancel;
  if FThread <> nil then
  begin
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
  inherited Destroy;
end;

procedure TMNoteTerminalPanel.Initialize(AParent: TWinControl;
  const AWorkingDirectory: string);
var
  Toolbar: TPanel;
begin
  if DirectoryExists(AWorkingDirectory) then
    FWorkingDirectory := ExpandFileName(AWorkingDirectory)
  else FWorkingDirectory := '';
  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := AParent;
  Toolbar.Align := alTop;
  Toolbar.BevelOuter := bvNone;
  Toolbar.Height := 32;

  FRunButton := TButton.Create(Self);
  FRunButton.Parent := Toolbar;
  FRunButton.Caption := 'Executar';
  FRunButton.SetBounds(8, 4, 72, 24);
  FRunButton.OnClick := @RunClick;
  FRunButton.Enabled := FWorkingDirectory <> '';
  FStopButton := TButton.Create(Self);
  FStopButton.Parent := Toolbar;
  FStopButton.Caption := 'Parar';
  FStopButton.SetBounds(84, 4, 64, 24);
  FStopButton.Enabled := False;
  FStopButton.OnClick := @StopClick;
  FCommandEdit := TEdit.Create(Self);
  FCommandEdit.Parent := Toolbar;
  FCommandEdit.Anchors := [akLeft, akTop, akRight];
  FCommandEdit.SetBounds(154, 5, Toolbar.ClientWidth - 162, 23);
  FCommandEdit.OnKeyDown := @CommandKeyDown;

  FOutput := TMemo.Create(Self);
  FOutput.Parent := AParent;
  FOutput.Align := alClient;
  FOutput.ReadOnly := True;
  FOutput.ScrollBars := ssAutoBoth;
  FOutput.WordWrap := False;
  if FWorkingDirectory <> '' then
    FOutput.Lines.Add('Diretório: ' + FWorkingDirectory)
  else FOutput.Lines.Add('Nenhum projeto aberto.');
end;

procedure TMNoteTerminalPanel.SetWorkingDirectory(
  const AWorkingDirectory: string);
begin
  if DirectoryExists(AWorkingDirectory) then
    FWorkingDirectory := ExpandFileName(AWorkingDirectory)
  else FWorkingDirectory := '';
  if FRunButton <> nil then FRunButton.Enabled := FWorkingDirectory <> '';
  if FOutput <> nil then
  begin
    if FWorkingDirectory = '' then FOutput.Lines.Add('Projeto fechado.')
    else FOutput.Lines.Add('Diretório alterado para: ' + FWorkingDirectory);
  end;
end;

procedure TMNoteTerminalPanel.ReleaseFinishedThread;
begin
  if (FThread <> nil) and FThread.Finished then
  begin
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
end;

procedure TMNoteTerminalPanel.ExecuteCommand(const ACommand: string);
begin
  ReleaseFinishedThread;
  if (FThread <> nil) or (Trim(ACommand) = '') then Exit;
  FOutput.Lines.Add('> ' + ACommand);
  FRunButton.Enabled := False;
  FStopButton.Enabled := True;
  FThread := TMNoteTerminalThread.Create(Self, ACommand, FWorkingDirectory);
  FThread.Start;
end;

procedure TMNoteTerminalPanel.RunClick(Sender: TObject);
begin
  ExecuteCommand(FCommandEdit.Text);
end;

procedure TMNoteTerminalPanel.StopClick(Sender: TObject);
begin
  Cancel;
end;

procedure TMNoteTerminalPanel.CommandKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    ExecuteCommand(FCommandEdit.Text);
    Key := 0;
  end;
end;

procedure TMNoteTerminalPanel.AppendOutput(const AText: string;
  AIsStdErr: Boolean);
begin
  FOutput.SelStart := Length(FOutput.Text);
  if AIsStdErr then
    FOutput.SelText := '[erro] ' + AText
  else
    FOutput.SelText := AText;
end;

procedure TMNoteTerminalPanel.ExecutionCompleted(ASuccess: Boolean;
  const AError: string);
begin
  if (not ASuccess) and (AError <> '') then
    FOutput.Lines.Add(AError);
  FOutput.Lines.Add('[processo concluído]');
  FRunButton.Enabled := True;
  FStopButton.Enabled := False;
end;

procedure TMNoteTerminalPanel.Cancel;
begin
  if FThread <> nil then FThread.CancelExecution;
end;

end.
