unit config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ComCtrls, IPEdit, setmain, chatgpt;

type

  { Tfrmconfig }

  Tfrmconfig = class(TForm)
    btSave: TButton;
    btCancel: TButton;
    ckToolsFalar: TCheckBox;
    ckToolsOuvir: TCheckBox;
    cbTipoIA: TComboBox;
    edCHATGPT: TFileNameEdit;
    edClean: TFileNameEdit;
    edDebug: TFileNameEdit;
    edCompile: TFileNameEdit;
    edDLLPostPATH: TFileNameEdit;
    edDLLPATH: TFileNameEdit;
    edDLLMyPATH: TFileNameEdit;
    edInstall: TFileNameEdit;
    edIPOuvir: TIPEdit;
    edIPLocalIA: TEdit;
    edRun: TFileNameEdit;
    edIPFALAR: TIPEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
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
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure cbTipoIAChange(Sender: TObject);
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
  FSetMain.DLLPath := edDLLPATH.Text;
  FSetMain.DLLMYPath := edDLLMYPATH.Text;
  FSetMain.DLLPOSTPath := edDLLPOSTPATH.Text;
  FSetMain.CHATGPT := edCHATGPT.Text;
  FSetMain.ToolsFalar := ckToolsFalar.Checked;
  FSetMain.ToolsOuvir := ckToolsOuvir.Checked;
  FSetMain.IPFALAR := edIPFALAR.Text;
  FSetMain.IPOUVIR := edIPOUVIR.Text;

  // Servidor da IA local / llama.cpp
  FSetMain.IPLocalIA := edIPLocalIA.Text;

  // Provider IA:
  // 0 = OpenAI
  // 1 = OpenRouter
  // 2 = Cerebras
  // 3 = Local / llama.cpp
  if cbTipoIA.ItemIndex < 0 then
    FSetMain.Provider := 0
  else
    FSetMain.Provider := cbTipoIA.ItemIndex;

  FSetMain.SalvaContexto(False);
  Close;
end;

procedure Tfrmconfig.cbTipoIAChange(Sender: TObject);
begin
  // Por enquanto não precisa fazer nada.
  // Depois podemos usar para habilitar/desabilitar campos conforme o provedor.
end;

procedure Tfrmconfig.FormCreate(Sender: TObject);
var
  Chat: TCHATGPT;
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
  ckToolsFalar.Checked := FSetMain.ToolsFalar;
  ckToolsOuvir.Checked := FSetMain.ToolsOuvir;
  edIPFALAR.Text := FSetMain.IPFALAR;
  edIPOUVIR.Text := FSetMain.IPOUVIR;
  edIPLocalIA.Text := FSetMain.IPLocalIA;

  cbTipoIA.Items.Clear;
  cbTipoIA.Items.Add('OpenAI');      // 0
  cbTipoIA.Items.Add('OpenRouter');  // 1
  cbTipoIA.Items.Add('Cerebras');    // 2
  cbTipoIA.Items.Add('Local');       // 3 - llama.cpp

  if (FSetMain.Provider >= 0) and (FSetMain.Provider < cbTipoIA.Items.Count) then
    cbTipoIA.ItemIndex := FSetMain.Provider
  else
    cbTipoIA.ItemIndex := 0;

  Chat := TCHATGPT.Create(nil);
  try
    lbVersao.Caption := 'Versão da biblioteca: ' + Chat.VersaoBiblioteca;
  finally
    Chat.Free;
  end;
end;

procedure Tfrmconfig.btCancelClick(Sender: TObject);
begin
  Close;
end;

end.
