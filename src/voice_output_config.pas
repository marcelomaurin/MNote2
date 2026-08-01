unit voice_output_config;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, ComCtrls, Dialogs,
  setmain, mnote_voice_output_service;

type
  { TfrmVoiceOutputConfig }

  TfrmVoiceOutputConfig = class(TForm)
  private
    FEnabled: TCheckBox;
    FEngine: TComboBox;
    FVoice: TComboBox;
    FVolume: TTrackBar;
    FRate: TTrackBar;
    FAsync: TCheckBox;
    FVolumeValue: TLabel;
    FRateValue: TLabel;
    FTestText: TMemo;
    FStatus: TLabel;
    procedure EngineChange(Sender: TObject);
    procedure SliderChange(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure TestClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    function StoreControls(out AError: string): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  mnote_visual_identity;

procedure AddLabel(AOwner: TComponent; AParent: TWinControl;
  const ACaption: string; ALeft, ATop: Integer);
var
  LabelControl: TLabel;
begin
  LabelControl := TLabel.Create(AOwner);
  LabelControl.Parent := AParent;
  LabelControl.Caption := ACaption;
  LabelControl.Left := ALeft;
  LabelControl.Top := ATop;
end;

constructor TfrmVoiceOutputConfig.Create(AOwner: TComponent);
var
  Content, Buttons, Actions: TPanel;
  ButtonControl: TButton;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Voice Output';
  Position := poScreenCenter;
  Width := 620;
  Height := 540;
  Constraints.MinWidth := 560;
  Constraints.MinHeight := 500;

  Content := TPanel.Create(Self);
  Content.Parent := Self;
  Content.Align := alClient;
  Content.BevelOuter := bvNone;

  FEnabled := TCheckBox.Create(Self);
  FEnabled.Parent := Content;
  FEnabled.Caption := 'Sintetizar respostas recebidas por comando de voz';
  FEnabled.SetBounds(24, 22, 430, 24);
  FEnabled.Checked := FSetMain.VoiceOutputEnabled;

  AddLabel(Self, Content, 'Sintetizador', 24, 62);
  FEngine := TComboBox.Create(Self);
  FEngine.Parent := Content;
  FEngine.Style := csDropDownList;
  FEngine.Items.Add('Padrão do sistema');
  FEngine.Items.Add('SAPI (Windows)');
  FEngine.Items.Add('eSpeak');
  FEngine.SetBounds(24, 82, 220, 27);
  if (FSetMain.VoiceOutputEngine >= 0) and
    (FSetMain.VoiceOutputEngine < FEngine.Items.Count) then
    FEngine.ItemIndex := FSetMain.VoiceOutputEngine
  else
    FEngine.ItemIndex := 0;
  FEngine.OnChange := @EngineChange;

  AddLabel(Self, Content, 'Voz instalada', 272, 62);
  FVoice := TComboBox.Create(Self);
  FVoice.Parent := Content;
  FVoice.SetBounds(272, 82, 300, 27);

  AddLabel(Self, Content, 'Volume', 24, 132);
  FVolume := TTrackBar.Create(Self);
  FVolume.Parent := Content;
  FVolume.Min := 0;
  FVolume.Max := 100;
  FVolume.Frequency := 10;
  FVolume.Position := FSetMain.VoiceOutputVolume;
  FVolume.SetBounds(24, 152, 430, 42);
  FVolume.OnChange := @SliderChange;
  FVolumeValue := TLabel.Create(Self);
  FVolumeValue.Parent := Content;
  FVolumeValue.SetBounds(474, 160, 80, 18);

  AddLabel(Self, Content, 'Velocidade (-10 a 10)', 24, 204);
  FRate := TTrackBar.Create(Self);
  FRate.Parent := Content;
  FRate.Min := -10;
  FRate.Max := 10;
  FRate.Frequency := 1;
  FRate.Position := FSetMain.VoiceOutputRate;
  FRate.SetBounds(24, 224, 430, 42);
  FRate.OnChange := @SliderChange;
  FRateValue := TLabel.Create(Self);
  FRateValue.Parent := Content;
  FRateValue.SetBounds(474, 232, 80, 18);

  FAsync := TCheckBox.Create(Self);
  FAsync.Parent := Content;
  FAsync.Caption := 'Reprodução assíncrona (não bloquear a interface)';
  FAsync.SetBounds(24, 282, 390, 24);
  FAsync.Checked := FSetMain.VoiceOutputAsync;

  AddLabel(Self, Content, 'Texto para teste real', 24, 322);
  FTestText := TMemo.Create(Self);
  FTestText.Parent := Content;
  FTestText.SetBounds(24, 342, 548, 82);
  FTestText.Anchors := [akLeft, akTop, akRight, akBottom];
  FTestText.ScrollBars := ssVertical;
  FTestText.Text := 'Olá! Esta é a saída de voz do MNote2.';

  Buttons := TPanel.Create(Self);
  Buttons.Parent := Self;
  Buttons.Align := alBottom;
  Buttons.Height := 48;
  Buttons.BevelOuter := bvNone;
  FStatus := TLabel.Create(Self);
  FStatus.Parent := Buttons;
  FStatus.SetBounds(10, 16, 300, 18);
  FStatus.Caption := 'Configuração baseada em TAIVoiceSynthesizer.';

  Actions := TPanel.Create(Self);
  Actions.Parent := Buttons;
  Actions.Align := alRight;
  Actions.Width := 280;
  Actions.BevelOuter := bvNone;

  ButtonControl := TButton.Create(Self);
  ButtonControl.Parent := Actions;
  ButtonControl.Caption := 'Testar voz';
  ButtonControl.SetBounds(0, 10, 88, 28);
  ButtonControl.OnClick := @TestClick;

  ButtonControl := TButton.Create(Self);
  ButtonControl.Parent := Actions;
  ButtonControl.Caption := 'Salvar';
  ButtonControl.SetBounds(94, 10, 80, 28);
  ButtonControl.OnClick := @SaveClick;

  ButtonControl := TButton.Create(Self);
  ButtonControl.Parent := Actions;
  ButtonControl.Caption := 'Fechar';
  ButtonControl.SetBounds(180, 10, 80, 28);
  ButtonControl.OnClick := @CloseClick;

  SliderChange(nil);
  EngineChange(nil);
  MNoteApplyVisualIdentity(Self);
end;

procedure TfrmVoiceOutputConfig.EngineChange(Sender: TObject);
var
  SelectedVoice, ErrorText: string;
begin
  SelectedVoice := FSetMain.VoiceOutputName;
  FVoice.Items.BeginUpdate;
  try
    if not MNoteVoiceOutput.GetAvailableVoices(FEngine.ItemIndex,
      FVoice.Items) then
    begin
      ErrorText := MNoteVoiceOutput.LastError;
      FStatus.Caption := ErrorText;
    end
    else
      FStatus.Caption := Format('%d voz(es) encontrada(s).',
        [FVoice.Items.Count]);
  finally
    FVoice.Items.EndUpdate;
  end;
  if SelectedVoice <> '' then FVoice.Text := SelectedVoice
  else if FVoice.Items.Count > 0 then FVoice.ItemIndex := 0
  else FVoice.Text := '';
end;

procedure TfrmVoiceOutputConfig.SliderChange(Sender: TObject);
begin
  FVolumeValue.Caption := IntToStr(FVolume.Position) + '%';
  FRateValue.Caption := IntToStr(FRate.Position);
end;

function TfrmVoiceOutputConfig.StoreControls(out AError: string): Boolean;
begin
  AError := '';
  if FEngine.ItemIndex < 0 then
  begin
    AError := 'Selecione o sintetizador.';
    Exit(False);
  end;
  FSetMain.VoiceOutputEnabled := FEnabled.Checked;
  FSetMain.VoiceOutputEngine := FEngine.ItemIndex;
  FSetMain.VoiceOutputName := Trim(FVoice.Text);
  FSetMain.VoiceOutputVolume := FVolume.Position;
  FSetMain.VoiceOutputRate := FRate.Position;
  FSetMain.VoiceOutputAsync := FAsync.Checked;
  MNoteVoiceOutput.ApplyConfiguration;
  Result := True;
end;

procedure TfrmVoiceOutputConfig.SaveClick(Sender: TObject);
var
  ErrorText: string;
begin
  if not StoreControls(ErrorText) then
  begin
    ShowMessage(ErrorText);
    Exit;
  end;
  FSetMain.SalvaContexto(False);
  FStatus.Caption := 'Configuração de Voice Output salva.';
end;

procedure TfrmVoiceOutputConfig.TestClick(Sender: TObject);
var
  ErrorText: string;
begin
  if not StoreControls(ErrorText) then
  begin
    ShowMessage(ErrorText);
    Exit;
  end;
  if Trim(FTestText.Text) = '' then
  begin
    ShowMessage('Informe um texto para o teste de voz.');
    Exit;
  end;
  if not MNoteVoiceOutput.Speak(FTestText.Text, True) then
  begin
    FStatus.Caption := MNoteVoiceOutput.LastError;
    ShowMessage('Não foi possível sintetizar a voz: ' +
      MNoteVoiceOutput.LastError);
    Exit;
  end;
  FStatus.Caption := 'Texto enviado ao sintetizador com sucesso.';
end;

procedure TfrmVoiceOutputConfig.CloseClick(Sender: TObject);
begin
  Close;
end;

end.
