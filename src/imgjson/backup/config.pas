unit config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn;

type

  { Tfrmconfig }

  Tfrmconfig = class(TForm)
    btSalvar: TButton;
    btCancel: TButton;
    edFileDLL: TDirectoryEdit;
    Label1: TLabel;
    procedure btSalvarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    flgsalvar : boolean;
  end;

var
  frmconfig: Tfrmconfig;

implementation

{$R *.lfm}

{ Tfrmconfig }

procedure Tfrmconfig.FormCreate(Sender: TObject);
begin
  flgsalvar := false;
end;

procedure Tfrmconfig.btSalvarClick(Sender: TObject);
begin
  flgsalvar := true;
  close
end;

end.

