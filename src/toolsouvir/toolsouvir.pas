unit ToolsOuvir;

{$mode ObjFPC}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  AdvLed, mnote_voice_command, mnote_voice_input_service, setmain;

type
  TConversationalVoiceCommandEvent = procedure(Sender: TObject;
    const ACommand: string) of object;

  { TfrmToolsOuvir }

  TfrmToolsOuvir = class(TForm)
    AdvLed1: TAdvLed;
    btConfig: TButton;
    btEnviarIA: TButton;
    btFechar: TButton;
    btOuvir: TButton;
    btParar: TButton;
    edComando: TEdit;
    edEngine: TEdit;
    edWakeWord: TEdit;
    lbComando: TLabel;
    lbEngine: TLabel;
    lbOuvido: TLabel;
    lbStatus: TLabel;
    lbWakeWord: TLabel;
    meOuvido: TMemo;
    Shape1: TShape;
    procedure btConfigClick(Sender: TObject);
    procedure btEnviarIAClick(Sender: TObject);
    procedure btFecharClick(Sender: TObject);
    procedure btOuvirClick(Sender: TObject);
    procedure btPararClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FWakeWord: string;
    FLastTranscript: string;
    FOnCommand: TConversationalVoiceCommandEvent;
    FVoiceService: TMNoteVoiceInputService;
    FIsListening: Boolean;
    procedure SetStatus(AState: Boolean; const AMsg: string);
    procedure ProcessTranscript(const AText: string);
    procedure VoiceText(Sender: TObject; const AText: string);
    procedure VoiceError(Sender: TObject; const AError: string);
    procedure RefreshConfiguration;
  public
    frase: string;
    procedure Conectar();
    procedure Disconectar();
    property WakeWord: string read FWakeWord write FWakeWord;
    property LastTranscript: string read FLastTranscript;
    property OnCommand: TConversationalVoiceCommandEvent read FOnCommand
      write FOnCommand;
    property IsListening: Boolean read FIsListening;
  end;

var
  frmToolsOuvir: TfrmToolsOuvir;

implementation

{$R *.lfm}

uses
  voice_recognition_config;

{ TfrmToolsOuvir }

procedure TfrmToolsOuvir.FormCreate(Sender: TObject);
begin
  FWakeWord := FSetMain.VoiceWakeWord;
  if Trim(FWakeWord) = '' then FWakeWord := 'OK MNote';
  RefreshConfiguration;
  SetStatus(False, 'Pronto para ouvir (ChatGPT / TAISpeechRecognizer)');
end;

procedure TfrmToolsOuvir.FormDestroy(Sender: TObject);
begin
  Disconectar();
  if FVoiceService <> nil then
  begin
    FreeAndNil(FVoiceService);
  end;
end;

procedure TfrmToolsOuvir.RefreshConfiguration;
begin
  if (FSetMain <> nil) and (Trim(FSetMain.VoiceWakeWord) <> '') then
    FWakeWord := FSetMain.VoiceWakeWord;
  if Trim(FWakeWord) = '' then FWakeWord := 'OK MNote';
  if edWakeWord <> nil then edWakeWord.Text := FWakeWord;
  if edEngine <> nil then
  begin
    if (FSetMain <> nil) and (FSetMain.WhisperCliPath <> '') then
      edEngine.Text := 'Whisper: ' + ExtractFileName(FSetMain.WhisperCliPath)
    else
      edEngine.Text := 'ChatGPT / Whisper CLI';
  end;
end;

procedure TfrmToolsOuvir.SetStatus(AState: Boolean; const AMsg: string);
begin
  if lbStatus <> nil then lbStatus.Caption := AMsg;
  if AdvLed1 <> nil then
  begin
    if AState then
    begin
      AdvLed1.State := lsOn;
      AdvLed1.Blink := True;
    end
    else
    begin
      AdvLed1.Blink := False;
      AdvLed1.State := lsOff;
    end;
  end;
  if Shape1 <> nil then
  begin
    if AState then
      Shape1.Brush.Color := clGreen
    else
      Shape1.Brush.Color := RGBToColor(160, 40, 40);
  end;
  if btOuvir <> nil then btOuvir.Enabled := not AState;
  if btParar <> nil then btParar.Enabled := AState;
end;

procedure TfrmToolsOuvir.ProcessTranscript(const AText: string);
var
  Info, CommandText: string;
begin
  Info := Trim(AText);
  if Info = '' then Exit;

  frase := Info;
  FLastTranscript := Info;
  if meOuvido <> nil then
  begin
    meOuvido.Lines.Add('[' + FormatDateTime('hh:nn:ss', Now) + '] ' + Info);
  end;

  if TMNoteVoiceCommand.TryParse(Info, FWakeWord, CommandText) then
  begin
    if edComando <> nil then edComando.Text := CommandText;
    SetStatus(True, 'Comando detectado: "' + CommandText + '"');
    if Assigned(FOnCommand) then
      FOnCommand(Self, CommandText);
  end
  else
  begin
    SetStatus(True, 'Texto ouvido: "' + Info + '"');
  end;
end;

procedure TfrmToolsOuvir.VoiceText(Sender: TObject; const AText: string);
begin
  ProcessTranscript(AText);
end;

procedure TfrmToolsOuvir.VoiceError(Sender: TObject; const AError: string);
begin
  SetStatus(False, 'Erro: ' + AError);
  if Trim(AError) <> '' then
    ShowMessage('Reconhecimento de voz: ' + AError);
end;

procedure TfrmToolsOuvir.Conectar();
var
  Reason: string;
begin
  RefreshConfiguration;
  if FVoiceService = nil then
  begin
    FVoiceService := TMNoteVoiceInputService.Create(Self);
    FVoiceService.OnText := @VoiceText;
    FVoiceService.OnError := @VoiceError;
  end;

  if not FVoiceService.Available(Reason) then
  begin
    SetStatus(False, 'Whisper não configurado: ' + Reason);
    if MessageDlg('Configurar Reconhecimento de Voz',
      'O executável ou modelo do Whisper (ChatGPT) ainda não foi localizado.' + LineEnding + LineEnding +
      Reason + LineEnding + LineEnding +
      'Deseja abrir as configurações de reconhecimento de voz agora?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      btConfigClick(Self);
    end;
    Exit;
  end;

  if FVoiceService.StartListening then
  begin
    FIsListening := True;
    SetStatus(True, 'Ouvindo microfone... Fale com a palavra de ativação: ' + FWakeWord);
  end
  else
  begin
    FIsListening := False;
    SetStatus(False, 'Falha ao iniciar escuta: ' + FVoiceService.LastError);
    ShowMessage('Erro no microfone: ' + FVoiceService.LastError);
  end;
end;

procedure TfrmToolsOuvir.Disconectar();
begin
  try
    if (FVoiceService <> nil) and FIsListening then
    begin
      FVoiceService.StopListening;
    end;
  finally
    FIsListening := False;
    SetStatus(False, 'Reconhecimento pausado/parado.');
  end;
end;

procedure TfrmToolsOuvir.btOuvirClick(Sender: TObject);
begin
  Conectar();
end;

procedure TfrmToolsOuvir.btPararClick(Sender: TObject);
begin
  Disconectar();
end;

procedure TfrmToolsOuvir.btEnviarIAClick(Sender: TObject);
var
  Cmd: string;
begin
  Cmd := Trim(edComando.Text);
  if (Cmd = '') and (meOuvido <> nil) and (meOuvido.Lines.Count > 0) then
    Cmd := Trim(meOuvido.Lines[meOuvido.Lines.Count - 1]);
  if Cmd = '' then
  begin
    ShowMessage('Nenhum texto ou comando reconhecido para executar.');
    Exit;
  end;
  if Assigned(FOnCommand) then
    FOnCommand(Self, Cmd);
end;

procedure TfrmToolsOuvir.btConfigClick(Sender: TObject);
var
  Frm: TfrmVoiceRecognitionConfig;
begin
  Frm := TfrmVoiceRecognitionConfig.Create(Self);
  try
    Frm.ShowModal;
    RefreshConfiguration;
  finally
    Frm.Free;
  end;
end;

procedure TfrmToolsOuvir.btFecharClick(Sender: TObject);
begin
  Close;
end;

end.
