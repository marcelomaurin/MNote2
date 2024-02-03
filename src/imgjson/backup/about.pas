unit about;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    btClose: TButton;
    Image1: TImage;
    Label1: TLabel;
    lbVersao: TLabel;
    Label3: TLabel;
    procedure btCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.btCloseClick(Sender: TObject);
begin
  Close();
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin

end;

end.

