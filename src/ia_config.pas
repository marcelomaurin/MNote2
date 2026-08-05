unit ia_config;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls, ComCtrls, Dialogs,
  setmain, mnote_ai_service, mnote_ai_types;

type
  { TfrmIAConfig }

  TfrmIAConfig = class(TForm)
  private
    FPages: TPageControl;
    FLblProvider: TLabel;
    FMainProvider: TComboBox;
    FLblModel: TLabel;
    FMainModel: TComboBox;
    FLblCustomModel: TLabel;
    FMainCustomModel: TEdit;
    FLblLocalIP: TLabel;
    FMainEndpoint: TEdit;
    FLblToken: TLabel;
    FMainToken: TEdit;

    FProvider: array[TMNoteAIRole] of TComboBox;
    FModel: array[TMNoteAIRole] of TComboBox;
    FCustomModel: array[TMNoteAIRole] of TEdit;
    FEndpoint: array[TMNoteAIRole] of TEdit;
    FInputBudget: array[TMNoteAIRole] of TEdit;
    FOutputBudget: array[TMNoteAIRole] of TEdit;
    FContextWindow: array[TMNoteAIRole] of TEdit;
    FTemperature: array[TMNoteAIRole] of TEdit;
    FEnabled: array[TMNoteAIRole] of TCheckBox;
    FPrompt: array[TMNoteAIRole] of TMemo;
    FStatus: TLabel;

    procedure AddMainPage;
    procedure AddRolePage(ARole: TMNoteAIRole);
    procedure MainProviderChange(Sender: TObject);
    procedure RoleProviderChange(Sender: TObject);
    procedure ApplyMainClick(Sender: TObject);
    function StoreMain(out AError: string): Boolean;
    function StoreProfiles(out AError: string): Boolean;
    procedure SaveClick(Sender: TObject);
    procedure TestClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  IA, mnote_visual_identity;

function AddLabel(AOwner: TComponent; AParent: TWinControl;
  const ACaption: string; ALeft, ATop: Integer): TLabel;
begin
  Result := TLabel.Create(AOwner);
  Result.Parent := AParent;
  Result.Caption := ACaption;
  Result.Left := ALeft;
  Result.Top := ATop;
end;

procedure AddProviders(ACombo: TComboBox);
begin
  ACombo.Items.Clear;
  ACombo.Items.Add('OpenAI');
  ACombo.Items.Add('OpenRouter');
  ACombo.Items.Add('Cerebras');
  ACombo.Items.Add('Local (Ollama)');
  ACombo.Items.Add('Google Gemini');
  ACombo.Items.Add('Anthropic Claude');
end;

procedure PopulateSuggestedModels(AProviderIdx: Integer; AModelCombo: TComboBox);
begin
  AModelCombo.Items.Clear;
  case AProviderIdx of
    0: // OpenAI
      begin
        AModelCombo.Items.Add('gpt-4o');
        AModelCombo.Items.Add('gpt-4o-mini');
        AModelCombo.Items.Add('o3-mini');
        AModelCombo.Items.Add('gpt-4-turbo');
      end;
    1: // OpenRouter
      begin
        AModelCombo.Items.Add('meta-llama/llama-3-8b-instruct:free');
        AModelCombo.Items.Add('google/gemma-2-9b-it:free');
        AModelCombo.Items.Add('deepseek/deepseek-r1:free');
      end;
    2: // Cerebras
      begin
        AModelCombo.Items.Add('qwen-3-235b');
        AModelCombo.Items.Add('llama3.1-8b');
        AModelCombo.Items.Add('llama-3.3-70b');
      end;
    3: // Local (Ollama)
      begin
        AModelCombo.Items.Add('llama3.2:3b');
        AModelCombo.Items.Add('qwen2.5:1.5b');
        AModelCombo.Items.Add('deepseek-r1:1.5b');
        AModelCombo.Items.Add('deepseek-r1:8b');
      end;
    4: // Google Gemini
      begin
        AModelCombo.Items.Add('gemini-2.5-flash');
        AModelCombo.Items.Add('gemini-2.5-pro');
        AModelCombo.Items.Add('gemini-2.0-flash');
        AModelCombo.Items.Add('gemini-1.5-flash');
      end;
    5: // Anthropic Claude
      begin
        AModelCombo.Items.Add('claude-3-5-sonnet-20241022');
        AModelCombo.Items.Add('claude-3-5-haiku-20241022');
      end;
  end;
end;

constructor TfrmIAConfig.Create(AOwner: TComponent);
var
  Role: TMNoteAIRole;
  Buttons, Actions: TPanel;
  ButtonControl: TButton;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Configuração das IAs';
  Position := poScreenCenter;
  Width := 760;
  Height := 640;
  Constraints.MinWidth := 700;
  Constraints.MinHeight := 560;

  MNoteAI.EnsureProfileDefaults;

  FPages := TPageControl.Create(Self);
  FPages.Parent := Self;
  FPages.Align := alClient;
  AddMainPage;
  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do AddRolePage(Role);

  Buttons := TPanel.Create(Self);
  Buttons.Parent := Self;
  Buttons.Align := alBottom;
  Buttons.Height := 46;
  Buttons.BevelOuter := bvNone;

  FStatus := TLabel.Create(Self);
  FStatus.Parent := Buttons;
  FStatus.SetBounds(10, 15, 360, 18);
  FStatus.Caption := 'Selecione a IA principal ou configure cada perfil.';

  Actions := TPanel.Create(Self);
  Actions.Parent := Buttons;
  Actions.Align := alRight;
  Actions.Width := 300;
  Actions.BevelOuter := bvNone;

  ButtonControl := TButton.Create(Self);
  ButtonControl.Parent := Actions;
  ButtonControl.Caption := 'Testar perfil';
  ButtonControl.SetBounds(0, 9, 100, 28);
  ButtonControl.OnClick := @TestClick;

  ButtonControl := TButton.Create(Self);
  ButtonControl.Parent := Actions;
  ButtonControl.Caption := 'Salvar';
  ButtonControl.SetBounds(106, 9, 82, 28);
  ButtonControl.OnClick := @SaveClick;

  ButtonControl := TButton.Create(Self);
  ButtonControl.Parent := Actions;
  ButtonControl.Caption := 'Cancelar';
  ButtonControl.SetBounds(194, 9, 88, 28);
  ButtonControl.OnClick := @CancelClick;
  MNoteApplyVisualIdentity(Self);
end;

procedure TfrmIAConfig.AddMainPage;
var
  Page: TTabSheet;
  Info: TLabel;
  ButtonControl: TButton;
begin
  Page := TTabSheet.Create(Self);
  Page.PageControl := FPages;
  Page.Caption := 'IA principal';

  FLblProvider := AddLabel(Self, Page, 'Provedor IA:', 24, 20);
  FLblProvider.Font.Style := [fsBold];

  FMainProvider := TComboBox.Create(Self);
  FMainProvider.Parent := Page;
  FMainProvider.Style := csDropDownList;
  AddProviders(FMainProvider);
  FMainProvider.SetBounds(24, 40, 180, 27);
  if (FSetMain.Provider >= 0) and (FSetMain.Provider < FMainProvider.Items.Count) then
    FMainProvider.ItemIndex := FSetMain.Provider
  else
    FMainProvider.ItemIndex := 0;
  FMainProvider.OnChange := @MainProviderChange;

  FLblModel := AddLabel(Self, Page, 'Modelo Sugerido:', 220, 20);
  FLblModel.Font.Style := [fsBold];

  FMainModel := TComboBox.Create(Self);
  FMainModel.Parent := Page;
  FMainModel.Style := csDropDown; // Permite escolha e digitação
  FMainModel.SetBounds(220, 40, 230, 27);

  FLblCustomModel := AddLabel(Self, Page, 'Modelo Customizado:', 465, 20);
  FLblCustomModel.Font.Style := [fsBold];

  FMainCustomModel := TEdit.Create(Self);
  FMainCustomModel.Parent := Page;
  FMainCustomModel.SetBounds(465, 40, 230, 27);

  FLblLocalIP := AddLabel(Self, Page, 'URL Local / IP:', 24, 85);
  FLblLocalIP.Font.Style := [fsBold];

  FMainEndpoint := TEdit.Create(Self);
  FMainEndpoint.Parent := Page;
  FMainEndpoint.SetBounds(24, 105, 671, 27);
  FMainEndpoint.Text := FSetMain.IPLocalIA;

  FLblToken := AddLabel(Self, Page, 'Chave API / Token:', 24, 150);
  FLblToken.Font.Style := [fsBold];

  FMainToken := TEdit.Create(Self);
  FMainToken.Parent := Page;
  FMainToken.SetBounds(24, 170, 671, 27);
  FMainToken.PasswordChar := '*';
  FMainToken.Text := FSetMain.CHATGPT;

  Info := TLabel.Create(Self);
  Info.Parent := Page;
  Info.AutoSize := False;
  Info.WordWrap := True;
  Info.SetBounds(24, 225, 671, 60);
  Info.Caption := 'A IA principal atende o chat comum. As outras abas são ' +
    'perfis especializados e podem usar provedores, modelos e endpoints ' +
    'diferentes no mesmo MNote2.';

  ButtonControl := TButton.Create(Self);
  ButtonControl.Parent := Page;
  ButtonControl.Caption := 'Aplicar principal a todos os perfis';
  ButtonControl.SetBounds(24, 295, 250, 30);
  ButtonControl.OnClick := @ApplyMainClick;

  Info := TLabel.Create(Self);
  Info.Parent := Page;
  Info.AutoSize := False;
  Info.WordWrap := True;
  Info.SetBounds(24, 340, 671, 48);
  Info.Caption := 'Use o botão acima para começar com uma única IA. Depois, ' +
    'altere individualmente somente os perfis que devem usar outra IA.';

  MainProviderChange(nil);
end;

procedure TfrmIAConfig.MainProviderChange(Sender: TObject);
var
  CurrentModel: string;
  Idx: Integer;
begin
  PopulateSuggestedModels(FMainProvider.ItemIndex, FMainModel);

  case FMainProvider.ItemIndex of
    0: CurrentModel := FSetMain.ModelOpenAI;
    1: CurrentModel := FSetMain.ModelOpenRouter;
    2: CurrentModel := FSetMain.ModelCerebras;
    3: CurrentModel := FSetMain.ModelLocal;
    4: CurrentModel := FSetMain.ModelGemini;
    5: CurrentModel := FSetMain.ModelClaude;
  else
    CurrentModel := '';
  end;

  FLblToken.Enabled := (FMainProvider.ItemIndex in [0, 1, 2, 4, 5]);
  FMainToken.Enabled := FLblToken.Enabled;
  FLblLocalIP.Enabled := (FMainProvider.ItemIndex = 3);
  FMainEndpoint.Enabled := FLblLocalIP.Enabled;

  Idx := FMainModel.Items.IndexOf(CurrentModel);
  if Idx >= 0 then
  begin
    FMainModel.ItemIndex := Idx;
    FMainCustomModel.Text := '';
  end
  else
  begin
    FMainModel.Text := CurrentModel;
    FMainCustomModel.Text := CurrentModel;
  end;
end;

procedure TfrmIAConfig.AddRolePage(ARole: TMNoteAIRole);
var
  Page: TTabSheet;
  Config: TMNoteAIProfileConfig;
  Lbl: TLabel;
  Idx: Integer;
begin
  Config := MNoteAI.Profiles.Profile(ARole).Config;
  Page := TTabSheet.Create(Self);
  Page.PageControl := FPages;
  Page.Caption := MNoteAIRoleName(ARole);

  Lbl := AddLabel(Self, Page, 'Provedor IA:', 16, 18);
  Lbl.Font.Style := [fsBold];

  FProvider[ARole] := TComboBox.Create(Self);
  FProvider[ARole].Parent := Page;
  FProvider[ARole].Style := csDropDownList;
  FProvider[ARole].Tag := Ord(ARole);
  AddProviders(FProvider[ARole]);
  FProvider[ARole].SetBounds(16, 38, 180, 25);
  if (Config.Provider >= 0) and (Config.Provider < FProvider[ARole].Items.Count) then
    FProvider[ARole].ItemIndex := Config.Provider
  else
    FProvider[ARole].ItemIndex := 0;

  Lbl := AddLabel(Self, Page, 'Modelo Sugerido:', 215, 18);
  Lbl.Font.Style := [fsBold];

  FModel[ARole] := TComboBox.Create(Self);
  FModel[ARole].Parent := Page;
  FModel[ARole].Style := csDropDown; // Permite escolha e digitação
  FModel[ARole].SetBounds(215, 38, 210, 25);

  Lbl := AddLabel(Self, Page, 'Modelo Customizado:', 445, 18);
  Lbl.Font.Style := [fsBold];

  FCustomModel[ARole] := TEdit.Create(Self);
  FCustomModel[ARole].Parent := Page;
  FCustomModel[ARole].SetBounds(445, 38, 260, 25);

  Lbl := AddLabel(Self, Page, 'URL Local / IP:', 16, 75);
  Lbl.Font.Style := [fsBold];

  FEndpoint[ARole] := TEdit.Create(Self);
  FEndpoint[ARole].Parent := Page;
  FEndpoint[ARole].SetBounds(16, 95, 689, 25);
  FEndpoint[ARole].Text := Config.Endpoint;

  AddLabel(Self, Page, 'Entrada', 16, 135);
  FInputBudget[ARole] := TEdit.Create(Self);
  FInputBudget[ARole].Parent := Page;
  FInputBudget[ARole].SetBounds(16, 155, 90, 25);
  FInputBudget[ARole].Text := IntToStr(Config.InputBudget);

  AddLabel(Self, Page, 'Saída', 125, 135);
  FOutputBudget[ARole] := TEdit.Create(Self);
  FOutputBudget[ARole].Parent := Page;
  FOutputBudget[ARole].SetBounds(125, 155, 90, 25);
  FOutputBudget[ARole].Text := IntToStr(Config.OutputBudget);

  AddLabel(Self, Page, 'Janela (0 = desconhecida)', 235, 135);
  FContextWindow[ARole] := TEdit.Create(Self);
  FContextWindow[ARole].Parent := Page;
  FContextWindow[ARole].SetBounds(235, 155, 120, 25);
  FContextWindow[ARole].Text := IntToStr(Config.ContextWindow);

  AddLabel(Self, Page, 'Temperatura', 375, 135);
  FTemperature[ARole] := TEdit.Create(Self);
  FTemperature[ARole].Parent := Page;
  FTemperature[ARole].SetBounds(375, 155, 90, 25);
  FTemperature[ARole].Text := FloatToStr(Config.Temperature);

  FEnabled[ARole] := TCheckBox.Create(Self);
  FEnabled[ARole].Parent := Page;
  FEnabled[ARole].Caption := 'Perfil habilitado';
  FEnabled[ARole].SetBounds(490, 153, 150, 25);
  FEnabled[ARole].Checked := Config.Enabled;

  AddLabel(Self, Page, 'Prompt de sistema (não armazene segredos)', 16, 195);
  FPrompt[ARole] := TMemo.Create(Self);
  FPrompt[ARole].Parent := Page;
  FPrompt[ARole].SetBounds(16, 215, 689, 290);
  FPrompt[ARole].Anchors := [akLeft, akTop, akRight, akBottom];
  FPrompt[ARole].ScrollBars := ssVertical;
  FPrompt[ARole].Text := Config.SystemPrompt;

  FProvider[ARole].OnChange := @RoleProviderChange;
  RoleProviderChange(FProvider[ARole]);

  Idx := FModel[ARole].Items.IndexOf(Config.ModelName);
  if Idx >= 0 then
  begin
    FModel[ARole].ItemIndex := Idx;
    FCustomModel[ARole].Text := '';
  end
  else
  begin
    FModel[ARole].Text := Config.ModelName;
    FCustomModel[ARole].Text := Config.ModelName;
  end;
end;

procedure TfrmIAConfig.RoleProviderChange(Sender: TObject);
var
  Role: TMNoteAIRole;
  Combo: TComboBox;
  Idx: Integer;
  CurrentModel: string;
begin
  Combo := TComboBox(Sender);
  if Combo = nil then Exit;
  Role := TMNoteAIRole(Combo.Tag);

  PopulateSuggestedModels(FProvider[Role].ItemIndex, FModel[Role]);

  FEndpoint[Role].Enabled := (FProvider[Role].ItemIndex = 3);

  CurrentModel := FModel[Role].Text;
  Idx := FModel[Role].Items.IndexOf(CurrentModel);
  if Idx >= 0 then
    FModel[Role].ItemIndex := Idx
  else
    FModel[Role].Text := CurrentModel;
end;

procedure TfrmIAConfig.ApplyMainClick(Sender: TObject);
var
  Role: TMNoteAIRole;
  SelectedModel: string;
begin
  if Trim(FMainCustomModel.Text) <> '' then
    SelectedModel := Trim(FMainCustomModel.Text)
  else
    SelectedModel := Trim(FMainModel.Text);

  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
  begin
    FProvider[Role].ItemIndex := FMainProvider.ItemIndex;
    RoleProviderChange(FProvider[Role]);
    FModel[Role].Text := SelectedModel;
    FCustomModel[Role].Text := FMainCustomModel.Text;
    FEndpoint[Role].Text := Trim(FMainEndpoint.Text);
  end;
  FStatus.Caption := 'IA principal aplicada aos controles de todos os perfis.';
end;

function TfrmIAConfig.StoreMain(out AError: string): Boolean;
var
  SelectedModel: string;
begin
  AError := '';
  if FMainProvider.ItemIndex < 0 then
  begin
    AError := 'Selecione o provedor da IA principal.';
    Exit(False);
  end;

  if Trim(FMainCustomModel.Text) <> '' then
    SelectedModel := Trim(FMainCustomModel.Text)
  else
    SelectedModel := Trim(FMainModel.Text);

  if SelectedModel = '' then
  begin
    AError := 'Informe ou selecione o modelo da IA principal.';
    Exit(False);
  end;

  if (FMainProvider.ItemIndex = 3) and (Trim(FMainEndpoint.Text) = '') then
  begin
    AError := 'Por favor, informe a URL Local / IP para o Ollama.';
    Exit(False);
  end;

  if (FMainProvider.ItemIndex in [0, 1, 2, 4, 5]) and (Trim(FMainToken.Text) = '') then
  begin
    AError := 'Por favor, informe a Chave API / Token para o provedor selecionado.';
    Exit(False);
  end;

  FSetMain.Provider := FMainProvider.ItemIndex;
  FSetMain.CHATGPT := FMainToken.Text;
  FSetMain.IPLocalIA := Trim(FMainEndpoint.Text);
  case FSetMain.Provider of
    0: FSetMain.ModelOpenAI := SelectedModel;
    1: FSetMain.ModelOpenRouter := SelectedModel;
    2: FSetMain.ModelCerebras := SelectedModel;
    3: FSetMain.ModelLocal := SelectedModel;
    4: FSetMain.ModelGemini := SelectedModel;
    5: FSetMain.ModelClaude := SelectedModel;
  end;
  Result := True;
end;

function TfrmIAConfig.StoreProfiles(out AError: string): Boolean;
var
  Role: TMNoteAIRole;
  Config: TMNoteAIProfileConfig;
  SelectedModel: string;
begin
  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
  begin
    Config := MNoteAI.Profiles.Profile(Role).Config;
    Config.Provider := FProvider[Role].ItemIndex;

    if Trim(FCustomModel[Role].Text) <> '' then
      SelectedModel := Trim(FCustomModel[Role].Text)
    else
      SelectedModel := Trim(FModel[Role].Text);

    Config.ModelName := SelectedModel;
    Config.Endpoint := Trim(FEndpoint[Role].Text);
    Config.InputBudget := StrToIntDef(FInputBudget[Role].Text, 0);
    Config.OutputBudget := StrToIntDef(FOutputBudget[Role].Text, 0);
    Config.ContextWindow := StrToIntDef(FContextWindow[Role].Text, 0);
    Config.Temperature := StrToFloatDef(FTemperature[Role].Text, -1);
    Config.Enabled := FEnabled[Role].Checked;
    Config.SystemPrompt := FPrompt[Role].Text;
    if not Config.Validate(AError) then
    begin
      AError := MNoteAIRoleName(Role) + ': ' + AError;
      Exit(False);
    end;
  end;
  Result := True;
end;

procedure TfrmIAConfig.SaveClick(Sender: TObject);
var
  ErrorText: string;
begin
  if not StoreMain(ErrorText) then
  begin
    ShowMessage(ErrorText);
    Exit;
  end;
  if not StoreProfiles(ErrorText) then
  begin
    ShowMessage(ErrorText);
    Exit;
  end;
  FSetMain.SalvaContexto(False);
  if not MNoteAI.SaveProfiles(ErrorText) then
  begin
    ShowMessage(ErrorText);
    Exit;
  end;
  if Assigned(frmIA) then frmIA.CarregarConfiguracoes;
  FStatus.Caption := 'Configuração principal e perfis salvos.';
end;

procedure TfrmIAConfig.TestClick(Sender: TObject);
var
  ErrorText: string;
  Role: TMNoteAIRole;
begin
  if FPages.ActivePageIndex = 0 then
  begin
    ShowMessage('Selecione uma aba de perfil para executar o teste real.');
    Exit;
  end;
  if not StoreMain(ErrorText) then
  begin
    ShowMessage(ErrorText);
    Exit;
  end;
  if not StoreProfiles(ErrorText) then
  begin
    ShowMessage(ErrorText);
    Exit;
  end;
  Role := TMNoteAIRole(FPages.ActivePageIndex - 1);
  if not MNoteAI.SendProfileTestAsync(Role) then
  begin
    ShowMessage(MNoteAI.LastError);
    Exit;
  end;
  FStatus.Caption := 'Teste real iniciado; acompanhe IA e AI Monitor.';
end;

procedure TfrmIAConfig.CancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

end.
