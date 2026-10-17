unit mnote_llm_training_form;
{$mode objfpc}{$H+}
interface
uses Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, EditBtn,
  Process, fpjson;
type
  TLLMTrainingForm = class(TForm)
  private
    FModel: TDirectoryEdit;
    FDataset: TFileNameEdit;
    FOutput: TDirectoryEdit;
    FPython: TFileNameEdit;
    FMode: TComboBox;
    FEpochs: TEdit;
    FBatch: TEdit;
    FLength: TEdit;
    FLog: TMemo;
    FRun: TButton;
    FValidate: TButton;
    FCancel: TButton;
    FTimer: TTimer;
    FProcess: TProcess;
    FConfigPath: string;
    procedure RunClick(Sender: TObject);
    procedure ValidateClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure PollProcess(Sender: TObject);
    procedure Launch(ADryRun: Boolean);
    function WriteConfig: Boolean;
    procedure SetBusy(ABusy: Boolean);
    procedure DrainOutput;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

function NewLabel(AOwner: TComponent; AParent: TWinControl;
  const CaptionText: string; Y: Integer): TLabel;
begin
  Result := TLabel.Create(AOwner);
  Result.Parent := AParent;
  Result.SetBounds(16, Y, 300, 18);
  Result.Caption := CaptionText;
end;

constructor TLLMTrainingForm.Create(AOwner: TComponent);
var B: TButton;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'MNote2 - Treinamento LLM (LoRA / QLoRA)';
  SetBounds(0, 0, 730, 690);
  Position := poScreenCenter;
  NewLabel(Self, Self, 'Executável Python do ambiente de treinamento', 12);
  FPython := TFileNameEdit.Create(Self);
  FPython.Parent := Self;
  FPython.SetBounds(16, 32, 685, 26);
  {$IFDEF WINDOWS}
  FPython.Text := 'python.exe';
  {$ELSE}
  FPython.Text := '/usr/bin/python3';
  {$ENDIF}
  NewLabel(Self, Self, 'Pasta do modelo Transformers local', 65);
  FModel := TDirectoryEdit.Create(Self);
  FModel.Parent := Self;
  FModel.SetBounds(16, 85, 685, 26);
  NewLabel(Self, Self, 'Dataset JSONL (uma chave text por linha)', 118);
  FDataset := TFileNameEdit.Create(Self);
  FDataset.Parent := Self;
  FDataset.SetBounds(16, 138, 685, 26);
  NewLabel(Self, Self, 'Pasta de saída do adaptador', 171);
  FOutput := TDirectoryEdit.Create(Self);
  FOutput.Parent := Self;
  FOutput.SetBounds(16, 191, 685, 26);
  NewLabel(Self, Self, 'Modalidade', 227);
  FMode := TComboBox.Create(Self);
  FMode.Parent := Self;
  FMode.Style := csDropDownList;
  FMode.Items.Add('LoRA');
  FMode.Items.Add('QLoRA (CUDA)');
  FMode.ItemIndex := 0;
  FMode.SetBounds(16, 247, 160, 26);
  NewLabel(Self, Self, 'Épocas', 282);
  FEpochs := TEdit.Create(Self);
  FEpochs.Parent := Self;
  FEpochs.Text := '1';
  FEpochs.SetBounds(16, 302, 100, 26);
  NewLabel(Self, Self, 'Batch size', 337);
  FBatch := TEdit.Create(Self);
  FBatch.Parent := Self;
  FBatch.Text := '1';
  FBatch.SetBounds(16, 357, 100, 26);
  NewLabel(Self, Self, 'Máximo de tokens', 392);
  FLength := TEdit.Create(Self);
  FLength.Parent := Self;
  FLength.Text := '512';
  FLength.SetBounds(16, 412, 100, 26);
  FValidate := TButton.Create(Self);
  FValidate.Parent := Self;
  FValidate.Caption := 'Validar configuração';
  FValidate.SetBounds(16, 449, 165, 30);
  FValidate.OnClick := @ValidateClick;
  FRun := TButton.Create(Self);
  FRun.Parent := Self;
  FRun.Caption := 'Iniciar treinamento';
  FRun.SetBounds(194, 449, 160, 30);
  FRun.OnClick := @RunClick;
  FCancel := TButton.Create(Self);
  FCancel.Parent := Self;
  FCancel.Caption := 'Interromper';
  FCancel.SetBounds(366, 449, 145, 30);
  FCancel.OnClick := @CancelClick;
  FCancel.Enabled := False;
  FLog := TMemo.Create(Self);
  FLog.Parent := Self;
  FLog.ScrollBars := ssAutoBoth;
  FLog.ReadOnly := True;
  FLog.SetBounds(16, 494, 685, 150);
  FLog.Lines.Add('Use primeiro Validar configuração. Modelos locais HuggingFace; GGUF não é suportado.');
  FTimer := TTimer.Create(Self);
  FTimer.Interval := 150;
  FTimer.Enabled := False;
  FTimer.OnTimer := @PollProcess;
  FProcess := TProcess.Create(Self);
  FConfigPath := IncludeTrailingPathDelimiter(GetAppConfigDir(False)) +
    'llm_training.json';
end;

destructor TLLMTrainingForm.Destroy;
begin
  if FProcess.Running then
  begin
    FProcess.Terminate(1);
    FProcess.WaitOnExit;
  end;
  inherited Destroy;
end;

function TLLMTrainingForm.WriteConfig: Boolean;
var O: TJSONObject; E, B, L: Integer; S: TStringList;
begin
  Result := False;
  if (Trim(FModel.Text) = '') or (Trim(FDataset.Text) = '') or
     (Trim(FOutput.Text) = '') then
  begin
    FLog.Lines.Add('Informe modelo, dataset e saída.');
    Exit;
  end;
  if (not TryStrToInt(FEpochs.Text, E)) or (E < 1) or (E > 100) or
     (not TryStrToInt(FBatch.Text, B)) or (B < 1) or (B > 64) or
     (not TryStrToInt(FLength.Text, L)) or (L < 32) or (L > 8192) then
  begin
    FLog.Lines.Add('Épocas (1..100), batch (1..64) e tokens (32..8192) inválidos.');
    Exit;
  end;
  O := TJSONObject.Create;
  try
    O.Add('model_path', Trim(FModel.Text));
    O.Add('dataset_path', Trim(FDataset.Text));
    O.Add('output_dir', Trim(FOutput.Text));
    if FMode.ItemIndex = 1 then O.Add('mode', 'qlora')
    else O.Add('mode', 'lora');
    O.Add('epochs', E);
    O.Add('batch_size', B);
    O.Add('max_length', L);
    O.Add('gradient_accumulation', 4);
    O.Add('lora_r', 8);
    O.Add('lora_alpha', 16);
    ForceDirectories(ExtractFileDir(FConfigPath));
    S := TStringList.Create;
    try
      S.Text := O.FormatJSON;
      S.SaveToFile(FConfigPath);
    finally
      S.Free;
    end;
  finally
    O.Free;
  end;
  Result := True;
end;

procedure TLLMTrainingForm.SetBusy(ABusy: Boolean);
begin
  FRun.Enabled := not ABusy;
  FValidate.Enabled := not ABusy;
  FCancel.Enabled := ABusy;
end;

procedure TLLMTrainingForm.Launch(ADryRun: Boolean);
var Script: string;
begin
  if FProcess.Running then Exit;
  if not WriteConfig then Exit;
  Script := ExpandFileName(ExtractFilePath(Application.ExeName) +
    'tools' + DirectorySeparator + 'llm_training' + DirectorySeparator +
    'train_lora.py');
  if not FileExists(Script) then
  begin
    FLog.Lines.Add('Script não encontrado: ' + Script);
    FLog.Lines.Add('Instale tools/llm_training junto ao executável.');
    Exit;
  end;
  FProcess.Executable := Trim(FPython.Text);
  FProcess.Parameters.Clear;
  FProcess.Parameters.Add(Script);
  FProcess.Parameters.Add('--config');
  FProcess.Parameters.Add(FConfigPath);
  if ADryRun then FProcess.Parameters.Add('--dry-run');
  FProcess.Options := [poUsePipes, poStderrToOutPut, poNoConsole];
  try
    FProcess.Execute;
    SetBusy(True);
    FTimer.Enabled := True;
    FLog.Lines.Add('Processo iniciado.');
  except
    on Ex: Exception do FLog.Lines.Add('Falha ao iniciar: ' + Ex.Message);
  end;
end;

procedure TLLMTrainingForm.RunClick(Sender: TObject);
begin
  Launch(False);
end;

procedure TLLMTrainingForm.ValidateClick(Sender: TObject);
begin
  Launch(True);
end;

procedure TLLMTrainingForm.CancelClick(Sender: TObject);
begin
  if FProcess.Running then
  begin
    FLog.Lines.Add('Interrompendo processo...');
    FProcess.Terminate(1);
  end;
end;

procedure TLLMTrainingForm.DrainOutput;
var Buffer: array[0..4095] of Byte; Count: LongInt; S: AnsiString;
begin
  while FProcess.Output.NumBytesAvailable > 0 do
  begin
    Count := FProcess.Output.Read(Buffer, SizeOf(Buffer));
    if Count <= 0 then Break;
    SetString(S, PAnsiChar(@Buffer[0]), Count);
    FLog.Lines.Text := FLog.Lines.Text + String(S);
  end;
end;

procedure TLLMTrainingForm.PollProcess(Sender: TObject);
begin
  DrainOutput;
  if not FProcess.Running then
  begin
    DrainOutput;
    FTimer.Enabled := False;
    FLog.Lines.Add('Processo encerrado. Código: ' + IntToStr(FProcess.ExitStatus));
    FProcess.CloseInput;
    SetBusy(False);
  end;
end;
end.
