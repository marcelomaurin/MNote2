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
    function ValidateControls(out AError: string): Boolean;
  public

  end;

var
  frmconfPython: TfrmconfPython;

implementation

{$R *.lfm}

{ TfrmconfPython }

function TfrmconfPython.ValidateControls(out AError: string): Boolean;
begin
  AError := '';
  if (cbPythonExecutionMode.ItemIndex < 0) or
     (cbPythonExecutionMode.ItemIndex > 1) then
  begin
    AError := 'Selecione o modo de execução do Python.';
    Exit(False);
  end;

  if chkUsePythonConnector.Checked and (Trim(edDLLPATH.Text) = '') then
  begin
    AError := 'Informe a DLL do Python ou o executável python/python3.';
    Exit(False);
  end;

  Result := True;
end;

procedure TfrmconfPython.btSaveClick(Sender: TObject);
var
  ErrorText: string;
begin
  if not ValidateControls(ErrorText) then
  begin
    MessageDlg('Python', ErrorText, mtWarning, [mbOK], 0);
    Exit;
  end;

  FSetMain.DLLPath := Trim(edDLLPATH.Text);
  FSetMain.UsePythonConnector := chkUsePythonConnector.Checked;
  FSetMain.PythonExecutionMode := cbPythonExecutionMode.ItemIndex;
  FSetMain.SalvaContexto(False);
  ModalResult := mrOK;
  Close;
end;

procedure TfrmconfPython.FormCreate(Sender: TObject);
begin
  edDLLPATH.Text := FSetMain.DLLPath;
  chkUsePythonConnector.Checked := FSetMain.UsePythonConnector;
  if (FSetMain.PythonExecutionMode >= 0) and
     (FSetMain.PythonExecutionMode <= 1) then
    cbPythonExecutionMode.ItemIndex := FSetMain.PythonExecutionMode
  else
    cbPythonExecutionMode.ItemIndex := 0;
end;

procedure TfrmconfPython.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmconfPython.btTestarPythonClick(Sender: TObject);
var
  Py: TMNotePythonService;
  Report: TStringList;
  Code, ErrorText: string;
begin
  if not ValidateControls(ErrorText) then
  begin
    MessageDlg('Python', ErrorText, mtWarning, [mbOK], 0);
    Exit;
  end;

  Py := TMNotePythonService.Create(Self);
  Report := TStringList.Create;
  try
    if cbPythonExecutionMode.ItemIndex = 0 then
      Py.Python.ExecutionMode := pemDLL
    else
      Py.Python.ExecutionMode := pemProcess;

    { O teste deve usar imediatamente o valor digitado na tela, mesmo antes
      de o usuário pressionar Salvar. }
    Py.Python.DLLPath := Trim(edDLLPATH.Text);

    Code := 'import sys' + LineEnding +
      'print("Versao Python:", sys.version)' + LineEnding +
      'print("Executavel:", sys.executable)';
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
