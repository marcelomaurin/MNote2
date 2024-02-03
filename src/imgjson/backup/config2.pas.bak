unit config2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn;

type

  { Tfrmconfig2 }

  Tfrmconfig2 = class(TForm)
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
  frmconfig2: Tfrmconfig2;

implementation

{$R *.lfm}

{ Tfrmconfig }

procedure Tfrmconfig2.FormCreate(Sender: TObject);
begin
  flgsalvar := false;
end;

procedure Tfrmconfig2.btSalvarClick(Sender: TObject);
begin
  flgsalvar := true;
  close
end;

end.

