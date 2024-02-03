unit sobre;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, uPoweredby;

type

  { TfrmSobre }

  TfrmSobre = class(TForm)
    Image1: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lbversao: TLabel;
    Poweredby1: TPoweredby;
    ToggleBox1: TToggleBox;
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label4DblClick(Sender: TObject);
    procedure ToggleBox1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmSobre: TfrmSobre;

implementation

{$R *.lfm}

{ TfrmSobre }

procedure TfrmSobre.FormCreate(Sender: TObject);
begin

end;

procedure TfrmSobre.Image1Click(Sender: TObject);
begin
  Poweredby1.ShowPoweredByForm;
end;

procedure TfrmSobre.Image1DblClick(Sender: TObject);
begin


end;

procedure TfrmSobre.Label4Click(Sender: TObject);
begin

end;

procedure TfrmSobre.Label4DblClick(Sender: TObject);
begin

end;

procedure TfrmSobre.ToggleBox1Change(Sender: TObject);
begin
  close();
end;

end.

