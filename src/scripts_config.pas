unit scripts_config;

{ objfpc}{+}
{ utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Dialogs,
  setmain;

type
  { TfrmScriptsConfig }

  TfrmScriptsConfig = class(TForm)
  private
    FInstall: TEdit;
    FClean: TEdit;
    FRun: TEdit;
    FDebug: TEdit;
    FCompile: TEdit;
    FStatus: TLabel;
    procedure BrowseInstallClick(Sender: TObject);
    procedure BrowseCleanClick(Sender: TObject);
    procedure BrowseRunClick(Sender: TObject);
    procedure BrowseDebugClick(Sender: TObject);
    procedure BrowseCompileClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    function StoreControls(out AError: string): Boolean;
    procedure BrowseScript(AEdit: TEdit; const ATitle: string);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  mnote_visual_identity;

procedure AddScriptLabel(AOwner: TComponent; AParent: TWinControl;
  const ACaption: string; ALeft, ATop: Integer);
var
  Lbl: TLabel;
begin
  Lbl := TLabel.Create(AOwner);
  Lbl.Parent := AParent;
  Lbl.Caption := ACaption;
  Lbl.Left := ALeft;
  Lbl.Top := ATop;
end;

constructor TfrmScriptsConfig.Create(AOwner: TComponent);
var
  Content, Buttons, Actions: TPanel;
  Btn: TButton;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Scripts';
  Position := poScreenCenter;
  Width := 600;
  Height := 440;
  Constraints.MinWidth := 560;
  Constraints.MinHeight := 400;

  Content := TPanel.Create(Self);
  Content.Parent := Self;
  Content.Align := alClient;
  Content.BevelOuter := bvNone;

  // Install
  AddScriptLabel(Self, Content, 'Install Script:', 24, 18);
  FInstall := TEdit.Create(Self);
  FInstall.Parent := Content;
  FInstall.SetBounds(24, 38, 455, 26);
  FInstall.Text := FSetMain.Install;
  FInstall.TextHint := 'Caminho do script de instalacao';

  Btn := TButton.Create(Self);
  Btn.Parent := Content;
  Btn.Caption := 'Buscar...';
  Btn.SetBounds(488, 37, 82, 28);
  Btn.OnClick := @BrowseInstallClick;

  // Clean
  AddScriptLabel(Self, Content, 'Clean Script:', 24, 76);
  FClean := TEdit.Create(Self);
  FClean.Parent := Content;
  FClean.SetBounds(24, 96, 455, 26);
  FClean.Text := FSetMain.CleanScript;
  FClean.TextHint := 'Caminho do script de limpeza';

  Btn := TButton.Create(Self);
  Btn.Parent := Content;
  Btn.Caption := 'Buscar...';
  Btn.SetBounds(488, 95, 82, 28);
  Btn.OnClick := @BrowseCleanClick;

  // Run
  AddScriptLabel(Self, Content, 'Run Script:', 24, 134);
  FRun := TEdit.Create(Self);
  FRun.Parent := Content;
  FRun.SetBounds(24, 154, 455, 26);
  FRun.Text := FSetMain.RunScript;
  FRun.TextHint := 'Caminho do script de execucao (run)';

  Btn := TButton.Create(Self);
  Btn.Parent := Content;
  Btn.Caption := 'Buscar...';
  Btn.SetBounds(488, 153, 82, 28);
  Btn.OnClick := @BrowseRunClick;

  // Debug
  AddScriptLabel(Self, Content, 'Debug Script:', 24, 192);
  FDebug := TEdit.Create(Self);
  FDebug.Parent := Content;
  FDebug.SetBounds(24, 212, 455, 26);
  FDebug.Text := FSetMain.DebugScript;
  FDebug.TextHint := 'Caminho do script de depuracao (debug)';

  Btn := TButton.Create(Self);
  Btn.Parent := Content;
  Btn.Caption := 'Buscar...';
  Btn.SetBounds(488, 211, 82, 28);
  Btn.OnClick := @BrowseDebugClick;

  // Compile
  AddScriptLabel(Self, Content, 'Compile Script:', 24, 250);
  FCompile := TEdit.Create(Self);
  FCompile.Parent := Content;
  FCompile.SetBounds(24, 270, 455, 26);
  FCompile.Text := FSetMain.Compile;
  FCompile.TextHint := 'Caminho do script de compilacao (build)';

  Btn := TButton.Create(Self);
  Btn.Parent := Content;
  Btn.Caption := 'Buscar...';
  Btn.SetBounds(488, 269, 82, 28);
  Btn.OnClick := @BrowseCompileClick;

  // Bottom buttons
  Buttons := TPanel.Create(Self);
  Buttons.Parent := Self;
  Buttons.Align := alBottom;
  Buttons.Height := 52;
  Buttons.BevelOuter := bvNone;

  FStatus := TLabel.Create(Self);
  FStatus.Parent := Buttons;
  FStatus.SetBounds(16, 18, 340, 18);
  FStatus.Caption := 'Configuracao de scripts do projeto.';

  Actions := TPanel.Create(Self);
  Actions.Parent := Buttons;
  Actions.Align := alRight;
  Actions.Width := 195;
  Actions.BevelOuter := bvNone;

  Btn := TButton.Create(Self);
  Btn.Parent := Actions;
  Btn.Caption := 'Salvar';
  Btn.SetBounds(10, 10, 85, 30);
  Btn.OnClick := @SaveClick;

  Btn := TButton.Create(Self);
  Btn.Parent := Actions;
  Btn.Caption := 'Fechar';
  Btn.SetBounds(102, 10, 85, 30);
  Btn.OnClick := @CloseClick;

  MNoteApplyVisualIdentity(Self);
end;

procedure TfrmScriptsConfig.BrowseScript(AEdit: TEdit; const ATitle: string);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Title := ATitle;
    Dlg.Filter := 'Scripts (*.sh;*.bat;*.cmd;*.py;*.ps1)|*.sh;*.bat;*.cmd;*.py;*.ps1|Todos os arquivos (*.*)|*.*';
    if Trim(AEdit.Text) <> '' then
      Dlg.FileName := Trim(AEdit.Text);
    if Dlg.Execute then
      AEdit.Text := Dlg.FileName;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmScriptsConfig.BrowseInstallClick(Sender: TObject);
begin
  BrowseScript(FInstall, 'Selecionar Script de Instalacao');
end;

procedure TfrmScriptsConfig.BrowseCleanClick(Sender: TObject);
begin
  BrowseScript(FClean, 'Selecionar Script de Limpeza');
end;

procedure TfrmScriptsConfig.BrowseRunClick(Sender: TObject);
begin
  BrowseScript(FRun, 'Selecionar Script de Execucao');
end;

procedure TfrmScriptsConfig.BrowseDebugClick(Sender: TObject);
begin
  BrowseScript(FDebug, 'Selecionar Script de Debug');
end;

procedure TfrmScriptsConfig.BrowseCompileClick(Sender: TObject);
begin
  BrowseScript(FCompile, 'Selecionar Script de Compilacao');
end;

function TfrmScriptsConfig.StoreControls(out AError: string): Boolean;
begin
  AError := '';
  FSetMain.Install := Trim(FInstall.Text);
  FSetMain.CleanScript := Trim(FClean.Text);
  FSetMain.RunScript := Trim(FRun.Text);
  FSetMain.DebugScript := Trim(FDebug.Text);
  FSetMain.Compile := Trim(FCompile.Text);
  Result := True;
end;

procedure TfrmScriptsConfig.SaveClick(Sender: TObject);
var
  Err: string;
begin
  if not StoreControls(Err) then
  begin
    ShowMessage(Err);
    Exit;
  end;
  FSetMain.SalvaContexto(False);
  FStatus.Caption := 'Scripts salvos com sucesso.';
  ShowMessage('Configuracao de scripts salva com sucesso!');
end;

procedure TfrmScriptsConfig.CloseClick(Sender: TObject);
begin
  Close;
end;

end.
