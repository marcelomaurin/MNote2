unit frmhint;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TfrmHint }

  TfrmHint = class(TForm)
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  private

  public
    procedure MessageHint(info: string);

  end;


implementation

{$R *.lfm}

procedure TfrmHint.Timer1Timer(Sender: TObject);
begin

end;

procedure TfrmHint.MessageHint(info: string);
var
  x , y : integer;
begin
     PopupNotifier1.Title:='Atenção!';
     PopupNotifier1.Text:=info;
     y := Screen.Height;
     x := screen.Width;
     PopupNotifier1.ShowAtPos(x,y);
     PopupNotifier1.Show;
     //sleep(2000);
     Timer1.Enabled:=true;
end;


end.

