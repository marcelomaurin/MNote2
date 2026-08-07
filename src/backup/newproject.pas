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
  public
     function ValidaConexao(): boolean;
  end;

var
  frmNewProject: TfrmNewProject;

implementation

{$R *.lfm}

{ TfrmNewProject }

uses mquery2;

procedure TfrmNewProject.Button1Click(Sender: TObject);
var
  original, destino, biblioteca, basePath: string;
begin
  // validações mínimas
  if Trim(deTarget.Text) = '' then
  begin
    if(frmhint= nil) then
    begin
      frmhint := TfrmHint.create(self);
    end;
    MessageHint('Selecione a pasta de destino.');
    Exit;
  end;
  if Trim(edproject.Text) = '' then
  begin
    if(frmhint= nil) then
    begin
      frmhint := TfrmHint.create(self);
    end;
    MessageHint('Informe o nome do projeto.');
    Exit;
  end;

  basePath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

  {$IFDEF WINDOWS}
  original   := basePath + 'db\projeto_padrao.db';
  destino    := IncludeTrailingPathDelimiter(deTarget.Text) + edproject.Text + '.db';
  if (Pos('\src', basePath) > 0) then
    biblioteca := basePath + '..\libs\sqlite\win32\sqlite3.dll'
  else
    biblioteca := basePath + 'libs\sqlite\win32\sqlite3.dll';
  {$ENDIF}

  {$IFDEF LINUX}
  original   := basePath + 'db/projeto_padrao.db';
  destino    := IncludeTrailingPathDelimiter(deTarget.Text) + edproject.Text + '.db';
  biblioteca := basePath + 'libs/linux64/libsqlite3.so';
  {$ENDIF}

  if not FileExists(original) then
  begin
    if(frmhint= nil) then
    begin
      frmhint := TfrmHint.create(self);
    end;
    MessageHint('Arquivo de base não encontrado: ' + original);
    Exit;
  end;

  if not DirectoryExists(ExtractFileDir(destino)) then
    ForceDirectories(ExtractFileDir(destino));

  try
    CopiarArquivo(original, destino);
  except
    on E: Exception do
    begin
      if(frmhint= nil) then
      begin
        frmhint := TfrmHint.create(self);
      end;
      MessageHint('Falha ao copiar o arquivo: ' + E.Message);
      Exit;
    end;
  end;

  if dmBase = nil then
    dmBase := TdmBase.Create(Self);

  if dmBase.ConectaSQLite(destino, biblioteca) then
  begin
    dmBase.SalvarDadosMaster(edproject.Text, edPropose.Text, destino, cbDataBase.ItemIndex);
    PageControl1.ActivePage := tsSpec;
  end
  else
    if(frmhint= nil) then
    begin
      frmhint := TfrmHint.create(self);
    end;
    MessageHint('Não foi possível conectar ao SQLite.');
end;

procedure TfrmNewProject.btProcessClick(Sender: TObject);
begin
  if (dmbase=nil) then
  begin
      dmbase := TdmBase.create(self);
  end;

  // Registrar parâmetros genéricos
  if(edHostNamePost.Text<>'') then dmbase.RegistraParam('HOSTNAME',edHostNamePost.Text);
  if(edSchemaPost.Text<>'') then dmbase.RegistraParam('SCHEMA',edSchemaPost.Text);
  if(edBancoPost.Text<>'') then dmbase.RegistraParam('DATABASE',edBancoPost.Text);
  if(edusuarioPost.Text<>'') then dmbase.RegistraParam('USER',edusuarioPost.Text);
  if(edPasswrdPost.Text<>'') then dmbase.RegistraParam('PASSWORD',edPasswrdPost.Text);
  if(deTarget.Text<>'') then dmbase.RegistraParam('DEFAULTFOLDER',deTarget.Text);

  // Salvar no setup correspondente do banco
  case cbDataBase.ItemIndex of
    0: // MySQL
    begin
      FSetMain.HostnameMy := edHostNamePost.Text;
      FSetMain.BancoMy    := edBancoPost.Text;
      FSetMain.UsernameMy := edusuarioPost.Text;
      FSetMain.PasswordMy := edPasswrdPost.Text;
    end;
    1: // Postgres
    begin
      FSetMain.HostnamePost := edHostNamePost.Text;
      FSetMain.SchemaPost   := edSchemaPost.Text;
      FSetMain.BancoPOST    := edBancoPost.Text;
      FSetMain.UsernamePost := edusuarioPost.Text;
      FSetMain.PasswordPost := edPasswrdPost.Text;
    end;
    2: // SQLite
    begin
      FSetMain.BancoSQLite  := edBancoPost.Text;
    end;
    3: // SQL Server (MSSQL)
    begin
      FSetMain.HostnameMSSQL := edHostNamePost.Text;
      FSetMain.SchemaMSSQL   := edSchemaPost.Text;
      FSetMain.BancoMSSQL    := edBancoPost.Text;
      FSetMain.UsernameMSSQL := edusuarioPost.Text;
      FSetMain.PasswordMSSQL := edPasswrdPost.Text;
    end;
    4: // Oracle
    begin
      FSetMain.HostnameOracle := edHostNamePost.Text;
      FSetMain.SchemaOracle   := edSchemaPost.Text;
      FSetMain.BancoOracle    := edBancoPost.Text;
      FSetMain.UsernameOracle := edusuarioPost.Text;
      FSetMain.PasswordOracle := edPasswrdPost.Text;
    end;
  end;

  FSetMain.Defaultfolder := deTarget.Text;
  FSetMain.Project:= IncludeTrailingPathDelimiter(deTarget.Text) + edproject.Text + '.db';

  if( frmmquery2 = nil) then
  begin
      frmmquery2 := Tfrmmquery2.CREATE(self);
  end;
  if (frmmquery2.ValidaConexao(cbDataBase.ItemIndex)) then
  begin
     FSetMain.SalvaContexto(false);
     close;
  end
  else
  begin
    if(frmhint= nil) then
    begin
      frmhint := TfrmHint.create(self);
    end;
    MessageHint('Conexão inválida');
  end;
end;

procedure TfrmNewProject.Button2Click(Sender: TObject);
begin
  if(mespec.text <> '') then
  begin
    if (dmbase=nil) then
    begin
      dmbase := TdmBase.create(self);
    end;
    dmbase.RegistraParam('SPEC',mespec.Text);
    PageControl1.ActivePage := tsDatabase;
    case cbDataBase.ItemIndex of
      0: // MySQL
      begin
        edHostNamePost.text := FSetMain.HostnameMy;
        edSchemaPost.text   := '';
        edBancoPost.text    := FSetMain.BancoMy;
        edusuarioPost.text  := FSetMain.UsernameMy;
        edPasswrdPost.text  := FSetMain.PasswordMy;
      end;
      1: // Postgres
      begin
        edHostNamePost.text := FSetMain.HostnamePost;
        edSchemaPost.text   := FSetMain.SchemaPost;
        edBancoPost.text    := FSetMain.BancoPOST;
        edusuarioPost.text  := FSetMain.UsernamePost;
        edPasswrdPost.text  := FSetMain.PasswordPost;
      end;
      2: // SQLite
      begin
        edHostNamePost.text := '';
        edSchemaPost.text   := '';
        edBancoPost.text    := FSetMain.BancoSQLite;
        edusuarioPost.text  := '';
        edPasswrdPost.text  := '';
      end;
      3: // SQL Server / MSSQL
      begin
        edHostNamePost.text := FSetMain.HostnameMSSQL;
        edSchemaPost.text   := FSetMain.SchemaMSSQL;
        edBancoPost.text    := FSetMain.BancoMSSQL;
        edusuarioPost.text  := FSetMain.UsernameMSSQL;
        edPasswrdPost.text  := FSetMain.PasswordMSSQL;
      end;
      4: // Oracle
      begin
        edHostNamePost.text := FSetMain.HostnameOracle;
        edSchemaPost.text   := FSetMain.SchemaOracle;
        edBancoPost.text    := FSetMain.BancoOracle;
        edusuarioPost.text  := FSetMain.UsernameOracle;
        edPasswrdPost.text  := FSetMain.PasswordOracle;
      end;
    end;
    AjustaCamposBanco;
  end
  else
  begin
    if(frmhint= nil) then
    begin
      frmhint := TfrmHint.create(self);
    end;
    MessageHint('Spec not found');
  end;
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

  // Primeiro, resetar visibilidade de tudo para True
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
    0: // MySQL
    begin
      Label6.Caption := 'Hostname (ou Host:Porta):';
      Label6.Top := 16;
      edHostNamePost.Top := 32;

      Label10.Visible := False;
      edSchemaPost.Visible := False;

      Label7.Caption := 'Banco de Dados (Database):';
      Label7.Top := 71;
      edBancoPost.Top := 87;

      Label8.Caption := 'Usuário:';
      Label8.Top := 126;
      edusuarioPost.Top := 142;

      Label9.Caption := 'Senha:';
      Label9.Top := 181;
      edPasswrdPost.Top := 197;
    end;

    1: // Postgres
    begin
      Label6.Caption := 'Hostname (ou Host:Porta):';
      Label6.Top := 16;
      edHostNamePost.Top := 32;

      Label10.Caption := 'Schema (Esquema):';
      Label10.Top := 71;
      edSchemaPost.Top := 87;

      Label7.Caption := 'Banco de Dados (Database):';
      Label7.Top := 126;
      edBancoPost.Top := 142;

      Label8.Caption := 'Usuário:';
      Label8.Top := 181;
      edusuarioPost.Top := 197;

      Label9.Caption := 'Senha:';
      Label9.Top := 236;
      edPasswrdPost.Top := 252;
    end;

    2: // SQLite
    begin
      Label6.Visible := False;
      edHostNamePost.Visible := False;

      Label10.Visible := False;
      edSchemaPost.Visible := False;

      Label7.Caption := 'Arquivo de Banco de Dados SQLite (.db):';
      Label7.Top := 16;
      edBancoPost.Top := 32;

      Label8.Visible := False;
      edusuarioPost.Visible := False;

      Label9.Visible := False;
      edPasswrdPost.Visible := False;
    end;

    3: // SQL Server (MSSQL)
    begin
      Label6.Caption := 'Hostname (Instância / Host:Porta):';
      Label6.Top := 16;
      edHostNamePost.Top := 32;

      Label10.Caption := 'Schema (Esquema):';
      Label10.Top := 71;
      edSchemaPost.Top := 87;

      Label7.Caption := 'Banco de Dados (Database):';
      Label7.Top := 126;
      edBancoPost.Top := 142;

      Label8.Caption := 'Usuário:';
      Label8.Top := 181;
      edusuarioPost.Top := 197;

      Label9.Caption := 'Senha:';
      Label9.Top := 236;
      edPasswrdPost.Top := 252;
    end;

    4: // Oracle
    begin
      Label6.Caption := 'Hostname ou TNS (Host:Porta):';
      Label6.Top := 16;
      edHostNamePost.Top := 32;

      Label10.Caption := 'Schema (Esquema Opcional):';
      Label10.Top := 71;
      edSchemaPost.Top := 87;

      Label7.Caption := 'Service Name ou SID (Serviço):';
      Label7.Top := 126;
      edBancoPost.Top := 142;

      Label8.Caption := 'Usuário (User):';
      Label8.Top := 181;
      edusuarioPost.Top := 197;

      Label9.Caption := 'Senha (Password):';
      Label9.Top := 236;
      edPasswrdPost.Top := 252;
    end;
  end;
end;

function TfrmNewProject.ValidaConexao(): boolean;
var
  dbType: Integer;
begin
  if (dmBase = nil) then
    dmBase := TdmBase.Create(Self);

  // 0 = MySQL, 1 = Postgres, 2 = SQLite, 3 = MSSQL, 4 = Oracle
  dbType := cbDataBase.ItemIndex;
  if (dbType < 0) or (dbType > 4) then
    dbType := 1;

  // 1) grava os parâmetros (os não vazios) + DATABASETYPE sempre
  try
    if Trim(edHostNamePost.Text) <> ''  then
    begin
         dmBase.RegistraParam('HOSTNAME', edHostNamePost.Text);
    end;
    if Trim(edSchemaPost.Text)   <> ''  then
    begin
      dmBase.RegistraParam('SCHEMA', edSchemaPost.Text);
    end;
    if Trim(edBancoPost.Text) <> ''  then dmBase.RegistraParam('DATABASE', edBancoPost.Text);
    if Trim(edusuarioPost.Text) <> ''  then dmBase.RegistraParam('USER', edusuarioPost.Text);
    if Trim(edPasswrdPost.Text) <> ''  then dmBase.RegistraParam('PASSWORD', edPasswrdPost.Text);
    dmBase.RegistraParam('DATABASETYPE', IntToStr(cbDataBase.ItemIndex));
  except
    Exit(False);
  end;

  if(frmmquery2=nil) then
  begin
    frmmquery2 := Tfrmmquery2.create(self);
  end;

  Result := frmmquery2.ValidaConexao( dbType   );
end;

end.

