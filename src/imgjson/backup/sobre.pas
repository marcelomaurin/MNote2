unit sobre;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btClose: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    lbversion: TLabel;
    procedure btCloseClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btCloseClick(Sender: TObject);
begin
  close;
end;

end.

