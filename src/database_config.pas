unit database_config;

{ objfpc}{+}
{ utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Dialogs,
  setmain;

type
  { TfrmDatabaseConfig }

  TfrmDatabaseConfig = class(TForm)
  private
    FDLLMySql: TEdit;
    FDLLPostgreSql: TEdit;
    FDLLMSSql: TEdit;
    FDLLOracle: TEdit;
    FStatus: TLabel;
    procedure BrowseMySqlClick(Sender: TObject);
    procedure BrowsePostgreSqlClick(Sender: TObject);
    procedure BrowseMSSqlClick(Sender: TObject);
    procedure BrowseOracleClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    function StoreControls(out AError: string): Boolean;
    procedure BrowseLibrary(AEdit: TEdit; const ATitle: string);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  mnote_visual_identity;

procedure AddDBLabel(AOwner: TComponent; AParent: TWinControl;
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

constructor TfrmDatabaseConfig.Create(AOwner: TComponent);
var
  Content, Buttons, Actions: TPanel;
  Btn: TButton;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Database';
  Position := poScreenCenter;
  Width := 600;
  Height := 390;
  Constraints.MinWidth := 560;
  Constraints.MinHeight := 350;

  Content := TPanel.Create(Self);
  Content.Parent := Self;
  Content.Align := alClient;
  Content.BevelOuter := bvNone;

  // MySQL
  AddDBLabel(Self, Content, 'DLL/SO MySQL:', 24, 18);
  FDLLMySql := TEdit.Create(Self);
  FDLLMySql.Parent := Content;
  FDLLMySql.SetBounds(24, 38, 455, 26);
  FDLLMySql.Text := FSetMain.DLLMyPath;
  FDLLMySql.TextHint := 'Caminho para libmysql.dll ou libmysqlclient.so';

  Btn := TButton.Create(Self);
  Btn.Parent := Content;
  Btn.Caption := 'Buscar...';
  Btn.SetBounds(488, 37, 82, 28);
  Btn.OnClick := @BrowseMySqlClick;

  // PostgreSQL
  AddDBLabel(Self, Content, 'DLL/SO PostgreSQL:', 24, 76);
  FDLLPostgreSql := TEdit.Create(Self);
  FDLLPostgreSql.Parent := Content;
  FDLLPostgreSql.SetBounds(24, 96, 455, 26);
  FDLLPostgreSql.Text := FSetMain.DLLPostPath;
  FDLLPostgreSql.TextHint := 'Caminho para libpq.dll ou libpq.so';

  Btn := TButton.Create(Self);
  Btn.Parent := Content;
  Btn.Caption := 'Buscar...';
  Btn.SetBounds(488, 95, 82, 28);
  Btn.OnClick := @BrowsePostgreSqlClick;

  // MSSQL
  AddDBLabel(Self, Content, 'DLL/SO MSSQL:', 24, 134);
  FDLLMSSql := TEdit.Create(Self);
  FDLLMSSql.Parent := Content;
  FDLLMSSql.SetBounds(24, 154, 455, 26);
  FDLLMSSql.Text := FSetMain.DLLMSSQLPath;
  FDLLMSSql.TextHint := 'Caminho para biblioteca MSSQL / DBLIB';

  Btn := TButton.Create(Self);
  Btn.Parent := Content;
  Btn.Caption := 'Buscar...';
  Btn.SetBounds(488, 153, 82, 28);
  Btn.OnClick := @BrowseMSSqlClick;

  // Oracle
  AddDBLabel(Self, Content, 'DLL/SO Oracle:', 24, 192);
  FDLLOracle := TEdit.Create(Self);
  FDLLOracle.Parent := Content;
  FDLLOracle.SetBounds(24, 212, 455, 26);
  FDLLOracle.Text := FSetMain.DLLOraclePath;
  FDLLOracle.TextHint := 'Caminho para oci.dll ou libclntsh.so';

  Btn := TButton.Create(Self);
  Btn.Parent := Content;
  Btn.Caption := 'Buscar...';
  Btn.SetBounds(488, 211, 82, 28);
  Btn.OnClick := @BrowseOracleClick;

  // Bottom buttons
  Buttons := TPanel.Create(Self);
  Buttons.Parent := Self;
  Buttons.Align := alBottom;
  Buttons.Height := 52;
  Buttons.BevelOuter := bvNone;

  FStatus := TLabel.Create(Self);
  FStatus.Parent := Buttons;
  FStatus.SetBounds(16, 18, 340, 18);
  FStatus.Caption := 'Configuracao de bibliotecas nativas de banco de dados.';

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

procedure TfrmDatabaseConfig.BrowseLibrary(AEdit: TEdit; const ATitle: string);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Title := ATitle;
    Dlg.Filter := 'Bibliotecas dinamicas (*.dll;*.so;*.dylib)|*.dll;*.so;*.dylib|Todos os arquivos (*.*)|*.*';
    if Trim(AEdit.Text) <> '' then
      Dlg.FileName := Trim(AEdit.Text);
    if Dlg.Execute then
      AEdit.Text := Dlg.FileName;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmDatabaseConfig.BrowseMySqlClick(Sender: TObject);
begin
  BrowseLibrary(FDLLMySql, 'Selecionar biblioteca MySQL');
end;

procedure TfrmDatabaseConfig.BrowsePostgreSqlClick(Sender: TObject);
begin
  BrowseLibrary(FDLLPostgreSql, 'Selecionar biblioteca PostgreSQL');
end;

procedure TfrmDatabaseConfig.BrowseMSSqlClick(Sender: TObject);
begin
  BrowseLibrary(FDLLMSSql, 'Selecionar biblioteca MSSQL');
end;

procedure TfrmDatabaseConfig.BrowseOracleClick(Sender: TObject);
begin
  BrowseLibrary(FDLLOracle, 'Selecionar biblioteca Oracle');
end;

function TfrmDatabaseConfig.StoreControls(out AError: string): Boolean;
begin
  AError := '';
  FSetMain.DLLMyPath := Trim(FDLLMySql.Text);
  FSetMain.DLLPostPath := Trim(FDLLPostgreSql.Text);
  FSetMain.DLLMSSQLPath := Trim(FDLLMSSql.Text);
  FSetMain.DLLOraclePath := Trim(FDLLOracle.Text);
  Result := True;
end;

procedure TfrmDatabaseConfig.SaveClick(Sender: TObject);
var
  Err: string;
begin
  if not StoreControls(Err) then
  begin
    ShowMessage(Err);
    Exit;
  end;
  FSetMain.SalvaContexto(False);
  FStatus.Caption := 'Bibliotecas de banco salvas com sucesso.';
  ShowMessage('Configuracao de banco de dados salva com sucesso!');
end;

procedure TfrmDatabaseConfig.CloseClick(Sender: TObject);
begin
  Close;
end;

end.
