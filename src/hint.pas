unit hint;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  PopupNotifier;

type

  { TfrmHint }

  TfrmHint = class(TForm)
    PopupNotifier1: TPopupNotifier;
    Timer1: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    x , y : integer;
    function getTimer : cardinal;
    procedure setTimer(AValue: cardinal);
  public
    procedure MessageHint(info: string);

    property Time: cardinal read getTimer write setTimer;

  end;


implementation

{$R *.lfm}
uses main;

procedure TfrmHint.Timer1Timer(Sender: TObject);
begin
  hide();


  free;

end;

procedure TfrmHint.FormCreate(Sender: TObject);
begin
     PopupNotifier1.Title:='Atenção!';

     y := Screen.Height;
     x := screen.Width;
     Timer1.Enabled:=false;
end;

procedure TfrmHint.FormShow(Sender: TObject);
begin


end;

function TfrmHint.getTimer: cardinal;
begin
  result := Timer1.interval;
end;

procedure TfrmHint.setTimer(AValue: cardinal);
begin
    Timer1.Interval:=avalue;
end;

procedure TfrmHint.MessageHint(info: string);

begin
     PopupNotifier1.Text:=info;
     PopupNotifier1.ShowAtPos(x,y);
     PopupNotifier1.Show;
     //sleep(2000);
     Timer1.Enabled:=true;
end;


end.

