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
    function ValidateControls(out AError: string): Boolean;
  public
  end;

var
  frmconfig: Tfrmconfig;

implementation

{$R *.lfm}

{ Tfrmconfig }

function Tfrmconfig.ValidateControls(out AError: string): Boolean;
begin
  AError := '';
  if ckToolsOuvir.Checked and (Trim(edIPOuvir.Text) = '') then
  begin
    AError := 'Informe o IP do reconhecimento de voz ou desative a opção.';
    Exit(False);
  end;
  Result := True;
end;

procedure Tfrmconfig.btSaveClick(Sender: TObject);
var
  ErrorText: string;
begin
  if not ValidateControls(ErrorText) then
  begin
    MessageDlg('Configuração', ErrorText, mtWarning, [mbOK], 0);
    Exit;
  end;

  FSetMain.Compile := Trim(edCompile.Text);
  FSetMain.Install := Trim(edInstall.Text);
  FSetMain.CleanScript := Trim(edClean.Text);
  FSetMain.RunScript := Trim(edRun.Text);
  FSetMain.DebugScript := Trim(edDebug.Text);
  FSetMain.DLLMYPath := Trim(edDLLMYPATH.Text);
  FSetMain.DLLPOSTPath := Trim(edDLLPOSTPATH.Text);
  FSetMain.DLLMSSQLPath := Trim(edDLLMSSQLPATH.Text);
  FSetMain.DLLOraclePath := Trim(edDLLOraclePATH.Text);
  FSetMain.ToolsOuvir := ckToolsOuvir.Checked;
  FSetMain.IPOUVIR := Trim(edIPOUVIR.Text);
  FSetMain.SalvaContexto(False);
  ModalResult := mrOK;
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
  ModalResult := mrCancel;
  Close;
end;

end.
