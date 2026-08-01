unit config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ComCtrls, IPEdit, setmain, mnote_python_service, pythonconnector;

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
    edDLLPATH: TFileNameEdit;
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
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbIP1: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    tsToolsOuvir: TTabSheet;
    chkUsePythonConnector: TCheckBox;
    cbPythonExecutionMode: TComboBox;
    btTestarPython: TButton;
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btTestarPythonClick(Sender: TObject);
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
  FSetMain.DLLPath := edDLLPATH.Text;
  FSetMain.DLLMYPath := edDLLMYPATH.Text;
  FSetMain.DLLPOSTPath := edDLLPOSTPATH.Text;
  FSetMain.DLLMSSQLPath := edDLLMSSQLPATH.Text;
  FSetMain.DLLOraclePath := edDLLOraclePATH.Text;
  FSetMain.ToolsOuvir := ckToolsOuvir.Checked;
  FSetMain.IPOUVIR := edIPOUVIR.Text;
  FSetMain.UsePythonConnector := chkUsePythonConnector.Checked;
  FSetMain.PythonExecutionMode := cbPythonExecutionMode.ItemIndex;

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
  edDLLPATH.Text := FSetMain.DLLPath;
  edDLLMyPATH.Text := FSetMain.DLLMyPath;
  edDLLPostPATH.Text := FSetMain.DLLPostPath;
  edDLLMSSQLPATH.Text := FSetMain.DLLMSSQLPath;
  edDLLOraclePATH.Text := FSetMain.DLLOraclePath;
  ckToolsOuvir.Checked := FSetMain.ToolsOuvir;
  edIPOUVIR.Text := FSetMain.IPOUVIR;
  chkUsePythonConnector.Checked := FSetMain.UsePythonConnector;
  cbPythonExecutionMode.ItemIndex := FSetMain.PythonExecutionMode;

end;

procedure Tfrmconfig.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure Tfrmconfig.btTestarPythonClick(Sender: TObject);
var
  Py: TMNotePythonService;
  Report: TStringList;
  Code: string;
begin
  Py := TMNotePythonService.Create(Self);
  Report := TStringList.Create;
  try
    if cbPythonExecutionMode.ItemIndex = 0 then
      Py.Python.ExecutionMode := pemDLL
    else
      Py.Python.ExecutionMode := pemProcess;

    Code := 'import sys' + LineEnding + 'print("Versao Python:", sys.version)';
    if Py.ExecuteCode(Code) then
      ShowMessage('Sucesso!' + LineEnding + Py.LastOutput)
    else
    begin
      Py.GetDiagnosticReport(Report);
      ShowMessage('Erro: ' + Py.LastError + LineEnding + LineEnding + Report.Text);
    end;
  finally
    Report.Free;
    Py.Free;
  end;
end;

end.
