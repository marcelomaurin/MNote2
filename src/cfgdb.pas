unit cfgdb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, setbanco,
  setlstbnc, typedb;

type

  { Tfrmcfgdb }

  Tfrmcfgdb = class(TForm)
    btsave: TButton;
    btcancel: TButton;
    cbdbtype: TComboBox;
    edHostname: TEdit;
    edPort: TEdit;
    edUsername: TEdit;
    edPassword: TEdit;
    edDatabase: TEdit;

    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;

    procedure btsaveClick(Sender: TObject);
    procedure btcancelClick(Sender: TObject);
    procedure cbdbtypeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FSetBanco : TSetBanco;
    procedure SetSetBanco(value : TSetBanco);
    function ValidateControls(out AError: string): Boolean;
    procedure ApplyDefaultPort;
  public
    Save : boolean;

    property SetBanco : TSetBanco read FSetBanco write SetSetBanco;
  end;

implementation

{$R *.lfm}

{ Tfrmcfgdb }

procedure Tfrmcfgdb.SetSetBanco(value : TSetBanco);
begin
  FSetBanco := value;
end;

procedure Tfrmcfgdb.ApplyDefaultPort;
begin
  case cbdbtype.ItemIndex of
    Ord(DBMysql):    if Trim(edPort.Text) = '' then edPort.Text := '3306';
    Ord(DBPostgres): if Trim(edPort.Text) = '' then edPort.Text := '5432';
    Ord(DBMSSQL):    if Trim(edPort.Text) = '' then edPort.Text := '1433';
    Ord(DBOracle):   if Trim(edPort.Text) = '' then edPort.Text := '1521';
  end;
end;

function Tfrmcfgdb.ValidateControls(out AError: string): Boolean;
var
  PortNumber: Integer;
begin
  AError := '';
  Result := False;

  if (cbdbtype.ItemIndex < Ord(Low(TypeDatabase))) or
     (cbdbtype.ItemIndex > Ord(High(TypeDatabase))) then
  begin
    AError := 'Selecione um tipo de banco válido.';
    Exit;
  end;

  if Trim(edHostname.Text) = '' then
  begin
    AError := 'Informe o hostname do banco.';
    Exit;
  end;

  if Trim(edDatabase.Text) = '' then
  begin
    AError := 'Informe o nome do banco de dados.';
    Exit;
  end;

  if not TryStrToInt(Trim(edPort.Text), PortNumber) or
     (PortNumber < 1) or (PortNumber > 65535) then
  begin
    AError := 'Informe uma porta válida entre 1 e 65535.';
    Exit;
  end;

  Result := True;
end;

procedure Tfrmcfgdb.btsaveClick(Sender: TObject);
var
  ErrorText: string;
begin
  Save := False;
  if FSetBanco = nil then
  begin
    MessageDlg('Configuração de banco',
      'Nenhuma configuração de banco foi associada a esta tela.',
      mtError, [mbOK], 0);
    Exit;
  end;

  ApplyDefaultPort;
  if not ValidateControls(ErrorText) then
  begin
    MessageDlg('Configuração de banco', ErrorText, mtWarning, [mbOK], 0);
    Exit;
  end;

  FSetBanco.TipoBanco := TypeDatabase(cbdbtype.ItemIndex);
  FSetBanco.HostName := Trim(edHostname.Text);
  FSetBanco.Port := Trim(edPort.Text);
  FSetBanco.User := Trim(edUsername.Text);
  FSetBanco.Password := edPassword.Text;
  FSetBanco.Databasename := Trim(edDatabase.Text);
  FSetBanco.SalvaContexto(False);

  Save := True;
  ModalResult := mrOK;
  Close;
end;

procedure Tfrmcfgdb.btcancelClick(Sender: TObject);
begin
  Save := False;
  ModalResult := mrCancel;
  Close;
end;

procedure Tfrmcfgdb.cbdbtypeChange(Sender: TObject);
begin
  edPort.Text := '';
  ApplyDefaultPort;
end;

procedure Tfrmcfgdb.FormCreate(Sender: TObject);
begin
  Save := False;
end;

procedure Tfrmcfgdb.FormShow(Sender: TObject);
begin
  Save := False;
  if FSetBanco <> nil then
  begin
    cbdbtype.ItemIndex := Ord(FSetBanco.TipoBanco);
    edHostname.Text := FSetBanco.HostName;
    edPort.Text := FSetBanco.Port;
    edUsername.Text := FSetBanco.User;
    edPassword.Text := FSetBanco.Password;
    edDatabase.Text := FSetBanco.Databasename;
    ApplyDefaultPort;
  end
  else
  begin
    cbdbtype.ItemIndex := Ord(DBMysql);
    edHostname.Text := '127.0.0.1';
    edPort.Text := '3306';
    edUsername.Text := '';
    edPassword.Text := '';
    edDatabase.Text := '';
  end;
end;

end.
