unit Novo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  Buttons;

type

  { TfrmNovo }

  TfrmNovo = class(TForm)
    btCancel: TButton;
    btSalvar: TButton;
    cbDataBaseType: TComboBox;
    DirectoryEdit1: TDirectoryEdit;
    edHostname: TEdit;
    edHostname1: TEdit;
    edProjectName: TEdit;
    edStringConnection: TEdit;
    edUsername: TEdit;
    edPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    SpeedButton1: TSpeedButton;

    procedure btCancelClick(Sender: TObject);
    procedure btSalvarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private


  public
    flgSalvar : boolean;

  end;

var
  frmNovo: TfrmNovo;

implementation

{$R *.lfm}

{ TfrmNovo }

procedure TfrmNovo.FormCreate(Sender: TObject);
begin
  flgSalvar:= false;
end;

procedure TfrmNovo.btSalvarClick(Sender: TObject);
begin
  flgSalvar:= true;
  close;
end;

procedure TfrmNovo.btCancelClick(Sender: TObject);
begin
  close;
end;

end.

