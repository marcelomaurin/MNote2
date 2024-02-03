unit trainning;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  StdCtrls;

type

  { TfrmTrainning }

  TfrmTrainning = class(TForm)
    ComboBox1: TComboBox;
    Image1: TImage;
    Label1: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    tsDados: TTabSheet;
  private

  public

  end;

var
  frmTrainning: TfrmTrainning;

implementation

{$R *.lfm}

end.

