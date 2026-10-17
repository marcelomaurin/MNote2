unit voice_recognition_config;

{ objfpc}{+}
{ utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Dialogs,
  setmain, mnote_voice_input_service;

type
  { TfrmVoiceRecognitionConfig }

  TfrmVoiceRecognitionConfig = class(TForm)
  private
    FEnabled: TCheckBox;
    FWakeWord: TEdit;
    FWhisperCli: TEdit;
    FWhisperModel: TEdit;
    FLanguage: TComboBox;
    FThreads: TComboBox;
    FUseGPU: TCheckBox;
    FStatus: TLabel;
    procedure BrowseCliClick(Sender: TObject);
    procedure BrowseModelClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure TestClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    function StoreControls(out AError: string): Boolean;
    procedure SyncEnvironmentVariables;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  { WINDOWS} Windows, {}
  mnote_visual_identity;

procedure AddConfigLabel(AOwner: TComponent; AParent: TWinControl;
  const ACaption: string; ALeft, ATop: Integer);
var
  Lbl: TLabel;
begin
  Lbl := TLabel.Create(AOwner);
  Lbl.Parent := AParent;
  Lbl.Caption := ACaption;
  Lbl.Left := ALeft;
  Lbl.Top := ATop;
end;

constructor TfrmVoiceRecognitionConfig.Create(AOwner: TComponent);
var
  Content, Buttons, Actions: TPanel;
  Btn: TButton;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Voice Recognition';
  Position := poScreenCenter;
  Width := 620;
  Height := 480;
  Constraints.MinWidth := 580;
  Constraints.MinHeight := 460;

  Content := TPanel.Create(Self);
  Content.Parent := Self;
  Content.Align := alClient;
  Content.BevelOuter := bvNone;

  // Ativar reconhecimento
  FEnabled := TCheckBox.Create(Self);
  FEnabled.Parent := Content;
  FEnabled.Caption := 'Ativar reconhecimento de voz continuo (escuta ativa)';
  FEnabled.SetBounds(24, 20, 480, 24);
  FEnabled.Checked := FSetMain.ToolsOuvir;

  // Wake Word
  AddConfigLabel(Self, Content, 'Palavra de ativacao (Wake Word)', 24, 56);
  FWakeWord := TEdit.Create(Self);
  FWakeWord.Parent := Content;
  FWakeWord.SetBounds(24, 76, 260, 26);
  FWakeWord.Text := FSetMain.VoiceWakeWord;
  if Trim(FWakeWord.Text) = '' then
    FWakeWord.Text := 'OK MNote';

  // Idioma
  AddConfigLabel(Self, Content, 'Idioma do reconhecimento', 310, 56);
  FLanguage := TComboBox.Create(Self);
  FLanguage.Parent := Content;
  FLanguage.Style := csDropDownList;
  FLanguage.Items.Add('pt (Portugues)');
  FLanguage.Items.Add('en (Ingles)');
  FLanguage.Items.Add('es (Espanhol)');
  FLanguage.Items.Add('fr (Frances)');
  FLanguage.Items.Add('de (Alemao)');
  FLanguage.Items.Add('auto (Deteccao automatica)');
  FLanguage.SetBounds(310, 76, 260, 26);

  case LowerCase(FSetMain.WhisperLanguage) of
    'pt': FLanguage.ItemIndex := 0;
    'en': FLanguage.ItemIndex := 1;
    'es': FLanguage.ItemIndex := 2;
    'fr': FLanguage.ItemIndex := 3;
    'de': FLanguage.ItemIndex := 4;
    'auto': FLanguage.ItemIndex := 5;
    else FLanguage.ItemIndex := 0;
  end;

  // Executavel whisper-cli
  AddConfigLabel(Self, Content, 'Executavel whisper-cli', 24, 116);
  FWhisperCli := TEdit.Create(Self);
  FWhisperCli.Parent := Content;
  FWhisperCli.SetBounds(24, 136, 455, 26);
  FWhisperCli.Text := FSetMain.WhisperCliPath;
  if (FWhisperCli.Text = '') and (Trim(SysUtils.GetEnvironmentVariable('WHISPER_CLI')) <> '') then
    FWhisperCli.Text := Trim(SysUtils.GetEnvironmentVariable('WHISPER_CLI'));

  Btn := TButton.Create(Self);
  Btn.Parent := Content;
  Btn.Caption := 'Buscar...';
  Btn.SetBounds(488, 135, 82, 28);
  Btn.OnClick := @BrowseCliClick;

  // Modelo Whisper
  AddConfigLabel(Self, Content, 'Arquivo do modelo Whisper (.bin)', 24, 176);
  FWhisperModel := TEdit.Create(Self);
  FWhisperModel.Parent := Content;
  FWhisperModel.SetBounds(24, 196, 455, 26);
  FWhisperModel.Text := FSetMain.WhisperModelPath;
  if (FWhisperModel.Text = '') and (Trim(SysUtils.GetEnvironmentVariable('WHISPER_MODEL')) <> '') then
    FWhisperModel.Text := Trim(SysUtils.GetEnvironmentVariable('WHISPER_MODEL'));

  Btn := TButton.Create(Self);
  Btn.Parent := Content;
  Btn.Caption := 'Buscar...';
  Btn.SetBounds(488, 195, 82, 28);
  Btn.OnClick := @BrowseModelClick;

  // Threads
  AddConfigLabel(Self, Content, 'Threads de processamento', 24, 238);
  FThreads := TComboBox.Create(Self);
  FThreads.Parent := Content;
  FThreads.Style := csDropDownList;
  FThreads.Items.Add('0 (Automatico / padrao)');
  FThreads.Items.Add('1 thread');
  FThreads.Items.Add('2 threads');
  FThreads.Items.Add('4 threads');
  FThreads.Items.Add('8 threads');
  FThreads.Items.Add('16 threads');
  FThreads.SetBounds(24, 258, 260, 26);

  case FSetMain.WhisperThreads of
    1: FThreads.ItemIndex := 1;
    2: FThreads.ItemIndex := 2;
    4: FThreads.ItemIndex := 3;
    8: FThreads.ItemIndex := 4;
    16: FThreads.ItemIndex := 5;
    else FThreads.ItemIndex := 0;
  end;

  // GPU
  FUseGPU := TCheckBox.Create(Self);
  FUseGPU.Parent := Content;
  FUseGPU.Caption := 'Usar aceleracao por GPU';
  FUseGPU.SetBounds(310, 260, 260, 24);
  FUseGPU.Checked := FSetMain.WhisperGPU;

  // Painel de botoes e status
  Buttons := TPanel.Create(Self);
  Buttons.Parent := Self;
  Buttons.Align := alBottom;
  Buttons.Height := 52;
  Buttons.BevelOuter := bvNone;

  FStatus := TLabel.Create(Self);
  FStatus.Parent := Buttons;
  FStatus.SetBounds(16, 18, 270, 18);
  FStatus.Caption := 'Configuracao baseada em TAISpeechRecognizer.';

  Actions := TPanel.Create(Self);
  Actions.Parent := Buttons;
  Actions.Align := alRight;
  Actions.Width := 290;
  Actions.BevelOuter := bvNone;

  Btn := TButton.Create(Self);
  Btn.Parent := Actions;
  Btn.Caption := 'Validar';
  Btn.SetBounds(10, 10, 85, 30);
  Btn.OnClick := @TestClick;

  Btn := TButton.Create(Self);
  Btn.Parent := Actions;
  Btn.Caption := 'Salvar';
  Btn.SetBounds(102, 10, 85, 30);
  Btn.OnClick := @SaveClick;

  Btn := TButton.Create(Self);
  Btn.Parent := Actions;
  Btn.Caption := 'Fechar';
  Btn.SetBounds(194, 10, 85, 30);
  Btn.OnClick := @CloseClick;

  MNoteApplyVisualIdentity(Self);
end;

procedure TfrmVoiceRecognitionConfig.BrowseCliClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Title := 'Selecionar executavel whisper-cli';
    Dlg.Filter := 'Executaveis (*.exe;*)|*.exe;*|Todos os arquivos (*.*)|*.*';
    if FWhisperCli.Text <> '' then
      Dlg.FileName := FWhisperCli.Text;
    if Dlg.Execute then
      FWhisperCli.Text := Dlg.FileName;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmVoiceRecognitionConfig.BrowseModelClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Title := 'Selecionar Modelo Whisper';
    Dlg.Filter := 'Modelos Whisper (*.bin)|*.bin|Todos os arquivos (*.*)|*.*';
    if FWhisperModel.Text <> '' then
      Dlg.FileName := FWhisperModel.Text;
    if Dlg.Execute then
      FWhisperModel.Text := Dlg.FileName;
  finally
    Dlg.Free;
  end;
end;

function TfrmVoiceRecognitionConfig.StoreControls(out AError: string): Boolean;
var
  Lang: string;
  Th: Integer;
begin
  AError := '';
  FSetMain.ToolsOuvir := FEnabled.Checked;
  FSetMain.VoiceWakeWord := Trim(FWakeWord.Text);
  if FSetMain.VoiceWakeWord = '' then
    FSetMain.VoiceWakeWord := 'OK MNote';

  FSetMain.WhisperCliPath := Trim(FWhisperCli.Text);
  FSetMain.WhisperModelPath := Trim(FWhisperModel.Text);

  case FLanguage.ItemIndex of
    0: Lang := 'pt';
    1: Lang := 'en';
    2: Lang := 'es';
    3: Lang := 'fr';
    4: Lang := 'de';
    5: Lang := 'auto';
    else Lang := 'pt';
  end;
  FSetMain.WhisperLanguage := Lang;

  case FThreads.ItemIndex of
    1: Th := 1;
    2: Th := 2;
    3: Th := 4;
    4: Th := 8;
    5: Th := 16;
    else Th := 0;
  end;
  FSetMain.WhisperThreads := Th;

  FSetMain.WhisperGPU := FUseGPU.Checked;
  SyncEnvironmentVariables;
  Result := True;
end;

procedure TfrmVoiceRecognitionConfig.SyncEnvironmentVariables;
begin
  { WINDOWS}
  if FSetMain.WhisperCliPath <> '' then
    Windows.SetEnvironmentVariable(PChar('WHISPER_CLI'), PChar(FSetMain.WhisperCliPath));
  if FSetMain.WhisperModelPath <> '' then
    Windows.SetEnvironmentVariable(PChar('WHISPER_MODEL'), PChar(FSetMain.WhisperModelPath));
  if FSetMain.WhisperLanguage <> '' then
    Windows.SetEnvironmentVariable(PChar('WHISPER_LANGUAGE'), PChar(FSetMain.WhisperLanguage));
  Windows.SetEnvironmentVariable(PChar('WHISPER_THREADS'), PChar(IntToStr(FSetMain.WhisperThreads)));
  if FSetMain.WhisperGPU then
    Windows.SetEnvironmentVariable(PChar('WHISPER_GPU'), PChar('1'))
  else
    Windows.SetEnvironmentVariable(PChar('WHISPER_GPU'), PChar('0'));
  {}
end;

procedure TfrmVoiceRecognitionConfig.SaveClick(Sender: TObject);
var
  ErrorText: string;
begin
  if not StoreControls(ErrorText) then
  begin
    ShowMessage(ErrorText);
    Exit;
  end;
  FSetMain.SalvaContexto(False);
  FStatus.Caption := 'Configuracoes de Voice Recognition salvas.';
  ShowMessage('Configuracao de reconhecimento de voz salva com sucesso!');
end;

procedure TfrmVoiceRecognitionConfig.TestClick(Sender: TObject);
var
  CliPath, ModelPath, Reason: string;
  Service: TMNoteVoiceInputService;
begin
  CliPath := Trim(FWhisperCli.Text);
  ModelPath := Trim(FWhisperModel.Text);

  if CliPath = '' then
  begin
    FStatus.Caption := 'whisper-cli nao informado.';
    ShowMessage('Informe o caminho do executavel whisper-cli.');
    Exit;
  end;
  if not FileExists(CliPath) then
  begin
    FStatus.Caption := 'whisper-cli nao encontrado.';
    ShowMessage('Executavel nao encontrado em:' + LineEnding + CliPath);
    Exit;
  end;

  if ModelPath = '' then
  begin
    FStatus.Caption := 'Modelo Whisper nao informado.';
    ShowMessage('Informe o caminho do arquivo de modelo Whisper (.bin).');
    Exit;
  end;
  if not FileExists(ModelPath) then
  begin
    FStatus.Caption := 'Modelo Whisper nao encontrado.';
    ShowMessage('Arquivo de modelo nao encontrado em:' + LineEnding + ModelPath);
    Exit;
  end;

  StoreControls(Reason);
  Service := TMNoteVoiceInputService.Create(nil);
  try
    Service.Engine.ExecutablePath := CliPath;
    Service.Engine.ModelPath := ModelPath;
    Service.Recognizer.ModelPath := ModelPath;
    Service.Recognizer.Language := FSetMain.WhisperLanguage;
    Service.Recognizer.Threads := FSetMain.WhisperThreads;
    Service.Recognizer.UseGPU := FSetMain.WhisperGPU;
    Service.Engine.Threads := FSetMain.WhisperThreads;
    Service.Engine.UseGPU := FSetMain.WhisperGPU;

    if Service.Available(Reason) then
    begin
      FStatus.Caption := 'Reconhecimento Whisper validado e pronto.';
      ShowMessage('Sucesso! O executavel whisper-cli e o modelo Whisper foram validados com sucesso.');
    end
    else
    begin
      FStatus.Caption := 'Falha na validacao: ' + Reason;
      ShowMessage('Nao foi possivel inicializar o servico: ' + LineEnding + Reason);
    end;
  finally
    Service.Free;
  end;
end;

procedure TfrmVoiceRecognitionConfig.CloseClick(Sender: TObject);
begin
  Close;
end;

end.

