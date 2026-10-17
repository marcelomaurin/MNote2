unit config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ComCtrls, setmain, mnote_voice_input_service;

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
    edWhisperCLI: TFileNameEdit;
    edWhisperModel: TFileNameEdit;
    edWhisperLanguage: TEdit;
    edWhisperThreads: TEdit;
    ckWhisperGPU: TCheckBox;
    edWakeWord: TEdit;
    btTestWhisper: TButton;
    lblWhisperResult: TLabel;
    procedure btTestWhisperClick(Sender: TObject);
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
var Threads: Integer;
begin
  AError := '';
  if ckToolsOuvir.Checked then
  begin
    if not FileExists(Trim(edWhisperCLI.Text)) then
    begin
      AError := 'Selecione um executável Whisper existente.';
      Exit(False);
    end;
    if not FileExists(Trim(edWhisperModel.Text)) then
    begin
      AError := 'Selecione um modelo Whisper existente.';
      Exit(False);
    end;
  end;
  if (not TryStrToInt(Trim(edWhisperThreads.Text), Threads)) or
    (Threads < 0) or (Threads > 128) then
  begin
    AError := 'Threads deve estar entre 0 e 128 (0 = automático).';
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
  FSetMain.WhisperCLI := Trim(edWhisperCLI.Text);
  FSetMain.WhisperModel := Trim(edWhisperModel.Text);
  FSetMain.WhisperLanguage := Trim(edWhisperLanguage.Text);
  FSetMain.WhisperThreads := StrToIntDef(Trim(edWhisperThreads.Text), 0);
  FSetMain.WhisperGPU := ckWhisperGPU.Checked;
  FSetMain.VoiceWakeWord := Trim(edWakeWord.Text);
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
  edWhisperCLI.Text := FSetMain.WhisperCLI;
  edWhisperModel.Text := FSetMain.WhisperModel;
  edWhisperLanguage.Text := FSetMain.WhisperLanguage;
  edWhisperThreads.Text := IntToStr(FSetMain.WhisperThreads);
  ckWhisperGPU.Checked := FSetMain.WhisperGPU;
  edWakeWord.Text := FSetMain.VoiceWakeWord;
end;

procedure Tfrmconfig.btTestWhisperClick(Sender: TObject);
var
  Service: TMNoteVoiceInputService;
  Reason: string;
  OldCLI, OldModel, OldLang, OldWake: string;
  OldThreads: Integer;
  OldGPU: Boolean;
begin
  OldCLI := FSetMain.WhisperCLI;
  OldModel := FSetMain.WhisperModel;
  OldLang := FSetMain.WhisperLanguage;
  OldWake := FSetMain.VoiceWakeWord;
  OldThreads := FSetMain.WhisperThreads;
  OldGPU := FSetMain.WhisperGPU;
  try
    FSetMain.WhisperCLI := Trim(edWhisperCLI.Text);
    FSetMain.WhisperModel := Trim(edWhisperModel.Text);
    FSetMain.WhisperLanguage := Trim(edWhisperLanguage.Text);
    FSetMain.WhisperThreads := StrToIntDef(Trim(edWhisperThreads.Text),0);
    FSetMain.WhisperGPU := ckWhisperGPU.Checked;
    Service := TMNoteVoiceInputService.Create(Self);
    try
      if Service.Available(Reason) then
        lblWhisperResult.Caption := 'Whisper: executável e modelo válidos.'
      else
        lblWhisperResult.Caption := 'Whisper: ' + Reason;
    finally
      Service.Free;
    end;
  finally
    FSetMain.WhisperCLI := OldCLI;
    FSetMain.WhisperModel := OldModel;
    FSetMain.WhisperLanguage := OldLang;
    FSetMain.VoiceWakeWord := OldWake;
    FSetMain.WhisperThreads := OldThreads;
    FSetMain.WhisperGPU := OldGPU;
  end;
end;

procedure Tfrmconfig.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

end.
