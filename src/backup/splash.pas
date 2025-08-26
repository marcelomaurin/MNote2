unit splash;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TfrmSplash }

  TfrmSplash = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    lbversao: TLabel;
  private

  public

  end;

var
  frmSplash: TfrmSplash;

implementation

{$R *.lfm}

end.

