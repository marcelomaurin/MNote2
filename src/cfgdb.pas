unit cfgdb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, setbanco;

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

  public
    Save : boolean;
    constructor create(Sender: TObject; LSetBanco : TSetBanco);
    property SetBanco : TSetBanco read FSetBanco write SetSetBanco;

  end;



implementation

{$R *.lfm}

{ Tfrmcfgdb }

uses mquery;

procedure Tfrmcfgdb.SetSetBanco(value : TSetBanco);
begin
  FSetBanco := value;
end;

constructor Tfrmcfgdb.create(Sender: TObject; LSetBanco: TSetBanco);
begin

  FSetBanco  := LSetBanco;
end;

procedure Tfrmcfgdb.btsaveClick(Sender: TObject);
begin
  Save := true;
  close;
end;

procedure Tfrmcfgdb.btcancelClick(Sender: TObject);
begin
  close;
end;

procedure Tfrmcfgdb.cbdbtypeChange(Sender: TObject);
begin
  if cbdbtype.ItemIndex=0 then
  begin
    edPort.Text:='3306';
  end;
end;

procedure Tfrmcfgdb.FormCreate(Sender: TObject);
begin

end;

procedure Tfrmcfgdb.FormShow(Sender: TObject);
begin
    Save := false;
    if (FSetBanco <> nil) then
    begin
        cbdbtype.ItemIndex := integer(FSetBanco.TipoBanco);
        edHostname.Text:= FSetBanco.HostName ;
        edPort.Text:= FSetBanco.Port;
        edUsername.text := FSetBanco.User;
        edPassword.text := FSetBanco.Password;
        edDatabase.Text:= FSetBanco.Databasename;
    end
    else
    begin
      cbdbtype.ItemIndex := 0;
      edHostname.Text:= 'hostname' ;
      edPort.Text:= '3306';
      edUsername.text := 'USER';
      edPassword.text := '';
      edDatabase.Text:= 'mysql';
    end;



end;


end.

