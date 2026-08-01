unit config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ComCtrls, IPEdit, setmain, mnote_python_service, pythonconnector,
  mnote_ai_service;

type

  { Tfrmconfig }

  Tfrmconfig = class(TForm)
    btSave: TButton;
    btCancel: TButton;
    ckToolsFalar: TCheckBox;
    ckToolsOuvir: TCheckBox;
    cbTipoIA: TComboBox;
    cbModeloIA: TComboBox;
    LabelModeloIA: TLabel;
    edCHATGPT: TFileNameEdit;
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
    edIPLocalIA: TEdit;
    edRun: TFileNameEdit;
    edIPFALAR: TIPEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    lbVersao: TLabel;
    lbIP: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbIP1: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    tsToolsOuvir: TTabSheet;
    tsFalar: TTabSheet;
    chkUsePythonConnector: TCheckBox;
    cbPythonExecutionMode: TComboBox;
    btTestarPython: TButton;
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure cbTipoIAChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btTestarPythonClick(Sender: TObject);
  private

  public

  end;

var
  frmconfig: Tfrmconfig;

implementation

{$R *.lfm}

uses
  IA;

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
  FSetMain.CHATGPT := edCHATGPT.Text;
  FSetMain.ToolsFalar := ckToolsFalar.Checked;
  FSetMain.ToolsOuvir := ckToolsOuvir.Checked;
  FSetMain.IPFALAR := edIPFALAR.Text;
  FSetMain.IPOUVIR := edIPOUVIR.Text;
  FSetMain.UsePythonConnector := chkUsePythonConnector.Checked;
  FSetMain.PythonExecutionMode := cbPythonExecutionMode.ItemIndex;

  // Servidor da IA local / llama.cpp
  FSetMain.IPLocalIA := edIPLocalIA.Text;

  // Provider IA:
  // 0 = OpenAI
  // 1 = OpenRouter
  // 2 = Cerebras
  // 3 = Local / llama.cpp
  // 4 = Gemini
  if cbTipoIA.ItemIndex < 0 then
    FSetMain.Provider := 0
  else
    FSetMain.Provider := cbTipoIA.ItemIndex;

  case FSetMain.Provider of
    0: FSetMain.ModelOpenAI := cbModeloIA.Text;
    1: FSetMain.ModelOpenRouter := cbModeloIA.Text;
    2: FSetMain.ModelCerebras := cbModeloIA.Text;
    3: FSetMain.ModelLocal := cbModeloIA.Text;
    4: FSetMain.ModelGemini := cbModeloIA.Text;
  end;

  FSetMain.SalvaContexto(False);
  
  if Assigned(frmIA) then
    frmIA.CarregarConfiguracoes;
    
  Close;
end;

procedure Tfrmconfig.cbTipoIAChange(Sender: TObject);
begin
  cbModeloIA.Items.Clear;
  case cbTipoIA.ItemIndex of
    0: // OpenAI
      begin
        cbModeloIA.Items.Add('gpt-4o-mini');
        cbModeloIA.Items.Add('gpt-4o');
        cbModeloIA.Items.Add('gpt-4-turbo');
        cbModeloIA.Items.Add('gpt-4');
        cbModeloIA.Items.Add('gpt-3.5-turbo');
        cbModeloIA.Items.Add('o1-mini');
        cbModeloIA.Text := FSetMain.ModelOpenAI;
      end;
    1: // OpenRouter
      begin
        cbModeloIA.Items.Add('google/gemma-2-9b-it:free');
        cbModeloIA.Items.Add('meta-llama/llama-3-8b-instruct:free');
        cbModeloIA.Items.Add('mistralai/mistral-7b-instruct:free');
        cbModeloIA.Items.Add('microsoft/phi-3-medium-128k-instruct:free');
        cbModeloIA.Items.Add('deepseek/deepseek-chat');
        cbModeloIA.Text := FSetMain.ModelOpenRouter;
      end;
    2: // Cerebras
      begin
        cbModeloIA.Items.Add('llama3.1-8b');
        cbModeloIA.Items.Add('llama3.1-70b');
        cbModeloIA.Items.Add('llama-3.3-70b');
        cbModeloIA.Text := FSetMain.ModelCerebras;
      end;
    3: // Local
      begin
        cbModeloIA.Items.Add('llama3.2:3b');
        cbModeloIA.Items.Add('mistral');
        cbModeloIA.Items.Add('gemma2');
        cbModeloIA.Items.Add('deepseek-r1:1.5b');
        cbModeloIA.Items.Add('deepseek-r1:8b');
        cbModeloIA.Items.Add('qwen2.5:14b');
        cbModeloIA.Text := FSetMain.ModelLocal;
      end;
    4: // Gemini
      begin
        cbModeloIA.Items.Add('gemini-1.5-flash');
        cbModeloIA.Items.Add('gemini-1.5-pro');
        cbModeloIA.Items.Add('gemini-2.0-flash');
        cbModeloIA.Items.Add('gemini-2.5-flash');
        cbModeloIA.Items.Add('gemini-3.5-flash');
        cbModeloIA.Text := FSetMain.ModelGemini;
      end;
  else
    cbModeloIA.Text := '';
  end;
end;

procedure Tfrmconfig.FormCreate(Sender: TObject);
begin
  edCompile.Text := FSetMain.Compile;
  edInstall.Text := FSetMain.Install;
  edClean.Text := FSetMain.CleanScript;
  edRun.Text := FSetMain.RunScript;
  edDebug.Text := FSetMain.DebugScript;
  edCHATGPT.Text := FSetMain.CHATGPT;
  edDLLPATH.Text := FSetMain.DLLPath;
  edDLLMyPATH.Text := FSetMain.DLLMyPath;
  edDLLPostPATH.Text := FSetMain.DLLPostPath;
  edDLLMSSQLPATH.Text := FSetMain.DLLMSSQLPath;
  edDLLOraclePATH.Text := FSetMain.DLLOraclePath;
  ckToolsFalar.Checked := FSetMain.ToolsFalar;
  ckToolsOuvir.Checked := FSetMain.ToolsOuvir;
  edIPFALAR.Text := FSetMain.IPFALAR;
  edIPOUVIR.Text := FSetMain.IPOUVIR;
  edIPLocalIA.Text := FSetMain.IPLocalIA;
  chkUsePythonConnector.Checked := FSetMain.UsePythonConnector;
  cbPythonExecutionMode.ItemIndex := FSetMain.PythonExecutionMode;

  cbTipoIA.Items.Clear;
  cbTipoIA.Items.Add('OpenAI');      // 0
  cbTipoIA.Items.Add('OpenRouter');  // 1
  cbTipoIA.Items.Add('Cerebras');    // 2
  cbTipoIA.Items.Add('Local');       // 3 - llama.cpp
  cbTipoIA.Items.Add('Gemini');      // 4

  if (FSetMain.Provider >= 0) and (FSetMain.Provider < cbTipoIA.Items.Count) then
    cbTipoIA.ItemIndex := FSetMain.Provider
  else
    cbTipoIA.ItemIndex := 0;

  lbVersao.Caption := 'Versão da biblioteca: ' + MNoteAI.LibraryVersion;

  // Carrega e preenche o combo box de modelos inicialmente
  cbTipoIAChange(nil);
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
