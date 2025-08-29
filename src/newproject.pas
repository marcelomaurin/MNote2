unit newproject;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, ComCtrls, base, funcoes, hint;

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

procedure TfrmNewProject.Button1Click(Sender: TObject);
var
  original, destino, biblioteca, basePath: string;
begin
  // validações mínimas
  if Trim(deTarget.Text) = '' then
  begin
    frmHint.MessageHint('Selecione a pasta de destino.');
    Exit;
  end;
  if Trim(edproject.Text) = '' then
  begin
    frmHint.MessageHint('Informe o nome do projeto.');
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
    frmHint.MessageHint('Arquivo de base não encontrado: ' + original);
    Exit;
  end;

  if not DirectoryExists(ExtractFileDir(destino)) then
    ForceDirectories(ExtractFileDir(destino));

  try
    CopiarArquivo(original, destino);
  except
    on E: Exception do
    begin
      frmHint.MessageHint('Falha ao copiar o arquivo: ' + E.Message);
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
    frmHint.MessageHint('Não foi possível conectar ao SQLite.');
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

  end;
  if(edSchemaPost.Text<>'') then
  begin
    dmbase.RegistraParam('SCHEMA',edSchemaPost.Text);
  end;
  if(edBancoPost.Text<>'') then
  begin
    dmbase.RegistraParam('DATABASE',edBancoPost.Text);
  end;
  if(edusuarioPost.Text<>'') then
  begin
    dmbase.RegistraParam('USER',edusuarioPost.Text);
  end;
  if(edPasswrdPost.Text<>'') then
  begin
    dmbase.RegistraParam('PASSWORD',edPasswrdPost.Text);
  end;
  if (ValidaConexao()) then
  begin
     close;
  end
  else
  begin
    frmHint.MessageHint('Conexão inválida');
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
  end
  else
  begin
    frmHint.MessageHint('Spec not found');
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

  Result := dmBase.ValidaConexao(
    edHostNamePost.Text,  // Host
    edSchemaPost.Text,    // Schema (PG opcional)
    edBancoPost.Text,     // Database
    edusuarioPost.Text,   // User
    edPasswrdPost.Text,   // Password
    dbType                // 0=mysql, 1=postgres
  );
end;

end.

