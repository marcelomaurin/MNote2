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
  private

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
    if(frmhint= nil) then      https://download.oracle.com/otn/nt/oracle18c/180000/OracleXE184_Win64.zip?AuthParam=1779390223_a92a4442592215863bcecd6d942b01c0
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

  if(edHostNamePost.Text<>'') then
  begin
    dmbase.RegistraParam('HOSTNAME',edHostNamePost.Text);
    if(cbDataBase.ItemIndex=1) then
    begin
       FSetMain.HostnamePost:=edHostNamePost.Text;
    end;
  end;
  if(edSchemaPost.Text<>'') then
  begin
    dmbase.RegistraParam('SCHEMA',edSchemaPost.Text);
    if(cbDataBase.ItemIndex=1) then
    begin
        FSetMain.SchemaPost:=edSchemaPost.Text;
    end;
  end;
  if(edBancoPost.Text<>'') then
  begin
    dmbase.RegistraParam('DATABASE',edBancoPost.Text);
    if(cbDataBase.ItemIndex=1) then
    begin
      FSetMain.BancoPOST:= edBancoPost.Text;
    end;
  end;
  if(edusuarioPost.Text<>'') then
  begin
    dmbase.RegistraParam('USER',edusuarioPost.Text);
    if(cbDataBase.ItemIndex=1) then
    begin
      FSetMain.UsernamePost:= edusuarioPost.Text;
    end;
  end;
  if(edPasswrdPost.Text<>'') then
  begin
    dmbase.RegistraParam('PASSWORD',edPasswrdPost.Text);
    if(cbDataBase.ItemIndex=1) then
    begin
      FSetMain.PasswordPost:= edPasswrdPost.Text;
    end;
  end;
  if(deTarget.Text<>'') then
  begin
    dmbase.RegistraParam('DEFAULTFOLDER',deTarget.Text);
    if(cbDataBase.ItemIndex=1) then
    begin
      FSetMain.Defaultfolder:= deTarget.text;
    end;
  end;

  FSetMain.Project:=  IncludeTrailingPathDelimiter(deTarget.Text) + edproject.Text + '.db'; ;
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
    if (cbDataBase.ItemIndex=1) then
    begin
        edHostNamePost.text := FSetMain.HostnamePost;
        edSchemaPost.text := FSetMain.SchemaPost;
        edBancoPost.text := FSetMain.BancoPOST;
        edusuarioPost.text :=  FSetMain.UsernamePost;
        edPasswrdPost.text := FSetMain.PasswordPost;
    end;
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

function TfrmNewProject.ValidaConexao(): boolean;
var
  dbType: Integer;
begin
  if (dmBase = nil) then
    dmBase := TdmBase.Create(Self);

  // 0 = MySQL, 1 = Postgres (defaulta para 1 se inválido)
  dbType := cbDataBase.ItemIndex;
  if (dbType <> 0) and (dbType <> 1) then
    dbType := 1;

  // 1) grava os parâmetros (os não vazios) + DATABASETYPE sempre
  try
    if Trim(edHostNamePost.Text) <> ''  then
    begin
         dmBase.RegistraParam('HOSTNAME', edHostNamePost.Text);
         //fsetmain.HostnamePost:= edHostNamePost.Text;
    end;
    if Trim(edSchemaPost.Text)   <> ''  then
    begin
      dmBase.RegistraParam('SCHEMA', edSchemaPost.Text);
      //FSetMain.SchemaPost:= edSchemaPost.Text;
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

