unit newproject;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, ComCtrls, base, funcoes, hint, setmain;

type

  { TfrmNewProject }

  TfrmNewProject = class(TForm)
    Button1: TButton;
    Button2: TButton;
    btProcess: TButton;
    cbDataBase: TComboBox;
    deTarget: TDirectoryEdit;
    edBancoPost: TEdit;
    edHostNamePost: TEdit;
    edPasswrdPost: TEdit;
    edproject: TEdit;
    edSchemaPost: TEdit;
    edusuarioPost: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    edPropose: TMemo;
    mespec: TMemo;
    PageControl1: TPageControl;
    tsProject: TTabSheet;
    tsSpec: TTabSheet;
    tsDatabase: TTabSheet;
    procedure btProcessClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    procedure AjustaCamposBanco;
    function ValidateProjectPage(out AError: string): Boolean;
    function ValidateDatabasePage(out AError: string): Boolean;
  public
    function ValidaConexao(): boolean;
  end;

var
  frmNewProject: TfrmNewProject;

implementation

{$R *.lfm}

uses mquery2;

function TfrmNewProject.ValidateProjectPage(out AError: string): Boolean;
begin
  AError := '';
  if Trim(deTarget.Text) = '' then
  begin
    AError := 'Selecione a pasta de destino.';
    Exit(False);
  end;
  if Trim(edproject.Text) = '' then
  begin
    AError := 'Informe o nome do projeto.';
    Exit(False);
  end;
  if not DirectoryExists(deTarget.Text) then
  begin
    if not ForceDirectories(deTarget.Text) then
    begin
      AError := 'Não foi possível criar a pasta de destino.';
      Exit(False);
    end;
  end;
  Result := True;
end;

function TfrmNewProject.ValidateDatabasePage(out AError: string): Boolean;
begin
  AError := '';
  if (cbDataBase.ItemIndex < 0) or (cbDataBase.ItemIndex > 4) then
  begin
    AError := 'Selecione o tipo de banco de dados.';
    Exit(False);
  end;

  if cbDataBase.ItemIndex = 2 then
  begin
    if Trim(edBancoPost.Text) = '' then
    begin
      AError := 'Informe o arquivo SQLite.';
      Exit(False);
    end;
  end
  else
  begin
    if Trim(edHostNamePost.Text) = '' then
    begin
      AError := 'Informe o hostname do banco.';
      Exit(False);
    end;
    if Trim(edBancoPost.Text) = '' then
    begin
      AError := 'Informe o banco de dados.';
      Exit(False);
    end;
  end;
  Result := True;
end;

procedure TfrmNewProject.Button1Click(Sender: TObject);
var
  original, destino, biblioteca, basePath, ErrorText: string;
begin
  if not ValidateProjectPage(ErrorText) then
  begin
    MessageHint(ErrorText);
    Exit;
  end;

  basePath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

  {$IFDEF WINDOWS}
  original := basePath + 'db\projeto_padrao.db';
  destino := IncludeTrailingPathDelimiter(deTarget.Text) + edproject.Text + '.db';
  if Pos('\src', LowerCase(basePath)) > 0 then
    biblioteca := ExpandFileName(basePath + '..\libs\sqlite\win32\sqlite3.dll')
  else
    biblioteca := basePath + 'libs\sqlite\win32\sqlite3.dll';
  {$ENDIF}

  {$IFDEF LINUX}
  original := basePath + 'db/projeto_padrao.db';
  destino := IncludeTrailingPathDelimiter(deTarget.Text) + edproject.Text + '.db';
  biblioteca := basePath + 'libs/linux64/libsqlite3.so';
  {$ENDIF}

  if not FileExists(original) then
  begin
    MessageHint('Arquivo de base não encontrado: ' + original);
    Exit;
  end;

  try
    CopiarArquivo(original, destino);
  except
    on E: Exception do
    begin
      MessageHint('Falha ao copiar o arquivo: ' + E.Message);
      Exit;
    end;
  end;

  if dmBase = nil then
    dmBase := TdmBase.Create(Self);

  if dmBase.ConectaSQLite(destino, biblioteca) then
  begin
    dmBase.SalvarDadosMaster(edproject.Text, edPropose.Text, destino,
      cbDataBase.ItemIndex);
    FSetMain.Project := destino;
    FSetMain.Defaultfolder := deTarget.Text;
    PageControl1.ActivePage := tsSpec;
  end
  else
  begin
    MessageHint('Não foi possível conectar ao SQLite.');
    Exit;
  end;
end;

procedure TfrmNewProject.btProcessClick(Sender: TObject);
var
  ErrorText: string;
begin
  if not ValidateProjectPage(ErrorText) then
  begin
    MessageHint(ErrorText);
    Exit;
  end;
  if not ValidateDatabasePage(ErrorText) then
  begin
    MessageHint(ErrorText);
    Exit;
  end;

  if dmBase = nil then
    dmBase := TdmBase.Create(Self);

  if Trim(edHostNamePost.Text) <> '' then dmBase.RegistraParam('HOSTNAME', Trim(edHostNamePost.Text));
  if Trim(edSchemaPost.Text) <> '' then dmBase.RegistraParam('SCHEMA', Trim(edSchemaPost.Text));
  if Trim(edBancoPost.Text) <> '' then dmBase.RegistraParam('DATABASE', Trim(edBancoPost.Text));
  if Trim(edusuarioPost.Text) <> '' then dmBase.RegistraParam('USER', Trim(edusuarioPost.Text));
  if edPasswrdPost.Text <> '' then dmBase.RegistraParam('PASSWORD', edPasswrdPost.Text);
  dmBase.RegistraParam('DEFAULTFOLDER', Trim(deTarget.Text));
  dmBase.RegistraParam('DATABASETYPE', IntToStr(cbDataBase.ItemIndex));

  case cbDataBase.ItemIndex of
    0:
      begin
        FSetMain.HostnameMy := Trim(edHostNamePost.Text);
        FSetMain.BancoMy := Trim(edBancoPost.Text);
        FSetMain.UsernameMy := Trim(edusuarioPost.Text);
        FSetMain.PasswordMy := edPasswrdPost.Text;
      end;
    1:
      begin
        FSetMain.HostnamePost := Trim(edHostNamePost.Text);
        FSetMain.SchemaPost := Trim(edSchemaPost.Text);
        FSetMain.BancoPOST := Trim(edBancoPost.Text);
        FSetMain.UsernamePost := Trim(edusuarioPost.Text);
        FSetMain.PasswordPost := edPasswrdPost.Text;
      end;
    2:
      FSetMain.BancoSQLite := Trim(edBancoPost.Text);
    3:
      begin
        FSetMain.HostnameMSSQL := Trim(edHostNamePost.Text);
        FSetMain.SchemaMSSQL := Trim(edSchemaPost.Text);
        FSetMain.BancoMSSQL := Trim(edBancoPost.Text);
        FSetMain.UsernameMSSQL := Trim(edusuarioPost.Text);
        FSetMain.PasswordMSSQL := edPasswrdPost.Text;
      end;
    4:
      begin
        FSetMain.HostnameOracle := Trim(edHostNamePost.Text);
        FSetMain.SchemaOracle := Trim(edSchemaPost.Text);
        FSetMain.BancoOracle := Trim(edBancoPost.Text);
        FSetMain.UsernameOracle := Trim(edusuarioPost.Text);
        FSetMain.PasswordOracle := edPasswrdPost.Text;
      end;
  end;

  FSetMain.Defaultfolder := Trim(deTarget.Text);
  FSetMain.Project := IncludeTrailingPathDelimiter(deTarget.Text) +
    edproject.Text + '.db';

  if frmmquery2 = nil then
    frmmquery2 := Tfrmmquery2.Create(Self);

  if frmmquery2.ValidaConexao(cbDataBase.ItemIndex) then
  begin
    FSetMain.SalvaContexto(False);
    ModalResult := mrOK;
    Close;
  end
  else
    MessageHint('Conexão inválida. Verifique os parâmetros do banco.');
end;

procedure TfrmNewProject.Button2Click(Sender: TObject);
begin
  if Trim(mespec.Text) = '' then
  begin
    MessageHint('Informe a especificação do projeto.');
    Exit;
  end;

  if dmBase = nil then
    dmBase := TdmBase.Create(Self);
  dmBase.RegistraParam('SPEC', mespec.Text);
  PageControl1.ActivePage := tsDatabase;

  case cbDataBase.ItemIndex of
    0:
      begin
        edHostNamePost.Text := FSetMain.HostnameMy;
        edSchemaPost.Text := '';
        edBancoPost.Text := FSetMain.BancoMy;
        edusuarioPost.Text := FSetMain.UsernameMy;
        edPasswrdPost.Text := FSetMain.PasswordMy;
      end;
    1:
      begin
        edHostNamePost.Text := FSetMain.HostnamePost;
        edSchemaPost.Text := FSetMain.SchemaPost;
        edBancoPost.Text := FSetMain.BancoPOST;
        edusuarioPost.Text := FSetMain.UsernamePost;
        edPasswrdPost.Text := FSetMain.PasswordPost;
      end;
    2:
      begin
        edHostNamePost.Text := '';
        edSchemaPost.Text := '';
        edBancoPost.Text := FSetMain.BancoSQLite;
        edusuarioPost.Text := '';
        edPasswrdPost.Text := '';
      end;
    3:
      begin
        edHostNamePost.Text := FSetMain.HostnameMSSQL;
        edSchemaPost.Text := FSetMain.SchemaMSSQL;
        edBancoPost.Text := FSetMain.BancoMSSQL;
        edusuarioPost.Text := FSetMain.UsernameMSSQL;
        edPasswrdPost.Text := FSetMain.PasswordMSSQL;
      end;
    4:
      begin
        edHostNamePost.Text := FSetMain.HostnameOracle;
        edSchemaPost.Text := FSetMain.SchemaOracle;
        edBancoPost.Text := FSetMain.BancoOracle;
        edusuarioPost.Text := FSetMain.UsernameOracle;
        edPasswrdPost.Text := FSetMain.PasswordOracle;
      end;
  end;
  AjustaCamposBanco;
end;

procedure TfrmNewProject.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = tsDatabase then
    AjustaCamposBanco;
end;

procedure TfrmNewProject.AjustaCamposBanco;
var
  dbType: Integer;
begin
  dbType := cbDataBase.ItemIndex;
  Label6.Visible := True;
  edHostNamePost.Visible := True;
  Label10.Visible := True;
  edSchemaPost.Visible := True;
  Label7.Visible := True;
  edBancoPost.Visible := True;
  Label8.Visible := True;
  edusuarioPost.Visible := True;
  Label9.Visible := True;
  edPasswrdPost.Visible := True;

  case dbType of
    0:
      begin
        Label6.Caption := 'Hostname (ou Host:Porta):';
        Label6.Top := 16; edHostNamePost.Top := 32;
        Label10.Visible := False; edSchemaPost.Visible := False;
        Label7.Caption := 'Banco de Dados (Database):';
        Label7.Top := 71; edBancoPost.Top := 87;
        Label8.Caption := 'Usuário:'; Label8.Top := 126; edusuarioPost.Top := 142;
        Label9.Caption := 'Senha:'; Label9.Top := 181; edPasswrdPost.Top := 197;
      end;
    1:
      begin
        Label6.Caption := 'Hostname (ou Host:Porta):';
        Label6.Top := 16; edHostNamePost.Top := 32;
        Label10.Caption := 'Schema (Esquema):';
        Label10.Top := 71; edSchemaPost.Top := 87;
        Label7.Caption := 'Banco de Dados (Database):';
        Label7.Top := 126; edBancoPost.Top := 142;
        Label8.Caption := 'Usuário:'; Label8.Top := 181; edusuarioPost.Top := 197;
        Label9.Caption := 'Senha:'; Label9.Top := 236; edPasswrdPost.Top := 252;
      end;
    2:
      begin
        Label6.Visible := False; edHostNamePost.Visible := False;
        Label10.Visible := False; edSchemaPost.Visible := False;
        Label7.Caption := 'Arquivo de Banco de Dados SQLite (.db):';
        Label7.Top := 16; edBancoPost.Top := 32;
        Label8.Visible := False; edusuarioPost.Visible := False;
        Label9.Visible := False; edPasswrdPost.Visible := False;
      end;
    3:
      begin
        Label6.Caption := 'Hostname (Instância / Host:Porta):';
        Label6.Top := 16; edHostNamePost.Top := 32;
        Label10.Caption := 'Schema (Esquema):';
        Label10.Top := 71; edSchemaPost.Top := 87;
        Label7.Caption := 'Banco de Dados (Database):';
        Label7.Top := 126; edBancoPost.Top := 142;
        Label8.Caption := 'Usuário:'; Label8.Top := 181; edusuarioPost.Top := 197;
        Label9.Caption := 'Senha:'; Label9.Top := 236; edPasswrdPost.Top := 252;
      end;
    4:
      begin
        Label6.Caption := 'Hostname ou TNS (Host:Porta):';
        Label6.Top := 16; edHostNamePost.Top := 32;
        Label10.Caption := 'Schema (Esquema Opcional):';
        Label10.Top := 71; edSchemaPost.Top := 87;
        Label7.Caption := 'Service Name ou SID (Serviço):';
        Label7.Top := 126; edBancoPost.Top := 142;
        Label8.Caption := 'Usuário (User):'; Label8.Top := 181; edusuarioPost.Top := 197;
        Label9.Caption := 'Senha (Password):'; Label9.Top := 236; edPasswrdPost.Top := 252;
      end;
  end;
end;

function TfrmNewProject.ValidaConexao(): boolean;
var
  dbType: Integer;
begin
  if dmBase = nil then
    dmBase := TdmBase.Create(Self);

  dbType := cbDataBase.ItemIndex;
  if (dbType < 0) or (dbType > 4) then
    dbType := 1;

  try
    if Trim(edHostNamePost.Text) <> '' then dmBase.RegistraParam('HOSTNAME', Trim(edHostNamePost.Text));
    if Trim(edSchemaPost.Text) <> '' then dmBase.RegistraParam('SCHEMA', Trim(edSchemaPost.Text));
    if Trim(edBancoPost.Text) <> '' then dmBase.RegistraParam('DATABASE', Trim(edBancoPost.Text));
    if Trim(edusuarioPost.Text) <> '' then dmBase.RegistraParam('USER', Trim(edusuarioPost.Text));
    if edPasswrdPost.Text <> '' then dmBase.RegistraParam('PASSWORD', edPasswrdPost.Text);
    dmBase.RegistraParam('DATABASETYPE', IntToStr(dbType));
  except
    Exit(False);
  end;

  if frmmquery2 = nil then
    frmmquery2 := Tfrmmquery2.Create(Self);
  Result := frmmquery2.ValidaConexao(dbType);
end;

end.
