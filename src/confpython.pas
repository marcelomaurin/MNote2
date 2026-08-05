unit confpython;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  setmain, mnote_python_service, pythonconnector;

type

  { TfrmconfPython }

  TfrmconfPython = class(TForm)
    btSave: TButton;
    btCancel: TButton;
    Label6: TLabel;
    edDLLPATH: TFileNameEdit;
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
  frmconfPython: TfrmconfPython;

implementation

{$R *.lfm}

{ TfrmconfPython }

procedure TfrmconfPython.btSaveClick(Sender: TObject);
begin
  FSetMain.DLLPath := edDLLPATH.Text;
  FSetMain.UsePythonConnector := chkUsePythonConnector.Checked;
  FSetMain.PythonExecutionMode := cbPythonExecutionMode.ItemIndex;

  FSetMain.SalvaContexto(False);
  Close;
end;

procedure TfrmconfPython.FormCreate(Sender: TObject);
begin
  edDLLPATH.Text := FSetMain.DLLPath;
  chkUsePythonConnector.Checked := FSetMain.UsePythonConnector;
  cbPythonExecutionMode.ItemIndex := FSetMain.PythonExecutionMode;
end;

procedure TfrmconfPython.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmconfPython.btTestarPythonClick(Sender: TObject);
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
