unit newproject;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, ComCtrls;

type

  { TfrmNewProject }

  TfrmNewProject = class(TForm)
    Button1: TButton;
    Button2: TButton;
    btProcess: TButton;
    cbDataBase: TComboBox;
    deTarget: TDirectoryEdit;
    edproject: TEdit;
    edPropose: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    mespec: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
  private

  public

  end;

var
  frmNewProject: TfrmNewProject;

implementation

{$R *.lfm}

end.

