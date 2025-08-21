unit config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ComCtrls, setmain;

type

  { Tfrmconfig }

  Tfrmconfig = class(TForm)
    btSave: TButton;
    btCancel: TButton;
    ckToolsFalar: TCheckBox;
    edCHATGPT: TFileNameEdit;
    edClean: TFileNameEdit;
    edDebug: TFileNameEdit;
    edCompile: TFileNameEdit;
    edDLLPostPATH: TFileNameEdit;
    edDLLPATH: TFileNameEdit;
    edDLLMyPATH: TFileNameEdit;
    edInstall: TFileNameEdit;
    edRun: TFileNameEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    tsFalar: TTabSheet;
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
  FSetMain.Compile := edCompile.text;
  FSetMain.Install := edInstall.text;
  FSetMain.CleanScript:= edClean.text;
  FSetMain.RunScript:=edRun.text;
  FSetMain.DebugScript:=edDebug.text;
  FSetMain.DLLPath:= edDLLPATH.text;
  FSetMain.DLLMYPath:= edDLLMYPATH.text;
  FSetMain.DLLPOSTPath:= edDLLPOSTPATH.text;
  FSetMain.CHATGPT:= edCHATGPT.text;
  FSetMain.ToolsFalar:=ckToolsFalar.Checked;
  FSetMain.SalvaContexto(false);
  close;
end;

procedure Tfrmconfig.FormCreate(Sender: TObject);
begin
  edcompile.text := FSetMain.Compile;
  edinstall.text := FSetMain.Install;
  edclean.text := FSetMain.CleanScript;
  edRun.text := FSetMain.RunScript;
  edDebug.text := FSetMain.DebugScript;
  edCHATGPT.Text := FSetMain.CHATGPT;
  edDLLPATH.text := FSetMain.DLLPath;
  edDLLMyPATH.text := FSetMain.DLLMyPath;
  edDLLPostPATH.text := FSetMain.DLLPostPath;
  ckToolsFalar.Checked:= FSetMain.ToolsFalar;
end;

procedure Tfrmconfig.btCancelClick(Sender: TObject);
begin
  close;
end;

end.

