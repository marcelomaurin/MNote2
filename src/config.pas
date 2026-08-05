unit config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ComCtrls, IPEdit, setmain;

type

  { Tfrmconfig }

  Tfrmconfig = class(TForm)
    btSave: TButton;
    btCancel: TButton;
    ckToolsOuvir: TCheckBox;
    edClean: TFileNameEdit;
    edDebug: TFileNameEdit;
    edCompile: TFileNameEdit;
    edDLLPostPATH: TFileNameEdit;
    edDLLMyPATH: TFileNameEdit;
    edDLLMSSQLPATH: TFileNameEdit;
    edDLLOraclePATH: TFileNameEdit;
    edInstall: TFileNameEdit;
    edIPOuvir: TIPEdit;
    edRun: TFileNameEdit;
    Label1: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbIP1: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet4: TTabSheet;
    tsToolsOuvir: TTabSheet;
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmconfig: Tfrmconfig;

implementation

{$R *.lfm}

{ Tfrmconfig }

procedure Tfrmconfig.btSaveClick(Sender: TObject);
begin
  FSetMain.Compile := edCompile.Text;
  FSetMain.Install := edInstall.Text;
  FSetMain.CleanScript := edClean.Text;
  FSetMain.RunScript := edRun.Text;
  FSetMain.DebugScript := edDebug.Text;
  FSetMain.DLLMYPath := edDLLMYPATH.Text;
  FSetMain.DLLPOSTPath := edDLLPOSTPATH.Text;
  FSetMain.DLLMSSQLPath := edDLLMSSQLPATH.Text;
  FSetMain.DLLOraclePath := edDLLOraclePATH.Text;
  FSetMain.ToolsOuvir := ckToolsOuvir.Checked;
  FSetMain.IPOUVIR := edIPOUVIR.Text;

  FSetMain.SalvaContexto(False);
  Close;
end;

procedure Tfrmconfig.FormCreate(Sender: TObject);
begin
  edCompile.Text := FSetMain.Compile;
  edInstall.Text := FSetMain.Install;
  edClean.Text := FSetMain.CleanScript;
  edRun.Text := FSetMain.RunScript;
  edDebug.Text := FSetMain.DebugScript;
  edDLLMyPATH.Text := FSetMain.DLLMyPath;
  edDLLPostPATH.Text := FSetMain.DLLPostPath;
  edDLLMSSQLPATH.Text := FSetMain.DLLMSSQLPath;
  edDLLOraclePATH.Text := FSetMain.DLLOraclePath;
  ckToolsOuvir.Checked := FSetMain.ToolsOuvir;
  edIPOUVIR.Text := FSetMain.IPOUVIR;
end;

procedure Tfrmconfig.btCancelClick(Sender: TObject);
begin
  Close;
end;

end.
