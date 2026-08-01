unit ia_config;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, ComCtrls, Dialogs,
  setmain, mnote_ai_service, mnote_ai_types;

type
  { TfrmIAConfig }

  TfrmIAConfig = class(TForm)
  private
    FPages: TPageControl;
    FMainProvider: TComboBox;
    FMainModel: TComboBox;
    FMainEndpoint: TEdit;
    FMainToken: TEdit;
    FProvider: array[TMNoteAIRole] of TComboBox;
    FModel: array[TMNoteAIRole] of TEdit;
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

procedure AddProviders(ACombo: TComboBox; AIncludeClaude: Boolean);
begin
  ACombo.Items.AddStrings(['OpenAI', 'OpenRouter', 'Cerebras', 'Local',
    'Gemini']);
  if AIncludeClaude then ACombo.Items.Add('Claude');
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

  AddLabel(Self, Page, 'Provider', 24, 24);
  FMainProvider := TComboBox.Create(Self);
  FMainProvider.Parent := Page;
  FMainProvider.Style := csDropDownList;
  AddProviders(FMainProvider, False);
  FMainProvider.SetBounds(24, 44, 210, 27);
  if (FSetMain.Provider >= 0) and
    (FSetMain.Provider < FMainProvider.Items.Count) then
    FMainProvider.ItemIndex := FSetMain.Provider
  else
    FMainProvider.ItemIndex := 0;
  FMainProvider.OnChange := @MainProviderChange;

  AddLabel(Self, Page, 'Modelo', 256, 24);
  FMainModel := TComboBox.Create(Self);
  FMainModel.Parent := Page;
  FMainModel.SetBounds(256, 44, 300, 27);

  AddLabel(Self, Page, 'Endpoint da IA local', 24, 96);
  FMainEndpoint := TEdit.Create(Self);
  FMainEndpoint.Parent := Page;
  FMainEndpoint.SetBounds(24, 116, 532, 27);
  FMainEndpoint.Text := FSetMain.IPLocalIA;

  AddLabel(Self, Page, 'Token da API (não é necessário para IA local)', 24, 168);
  FMainToken := TEdit.Create(Self);
  FMainToken.Parent := Page;
  FMainToken.SetBounds(24, 188, 532, 27);
  FMainToken.PasswordChar := '*';
  FMainToken.Text := FSetMain.CHATGPT;

  Info := TLabel.Create(Self);
  Info.Parent := Page;
  Info.AutoSize := False;
  Info.WordWrap := True;
  Info.SetBounds(24, 242, 650, 62);
  Info.Caption := 'A IA principal atende o chat comum. As outras abas são ' +
    'perfis especializados e podem usar providers, modelos e endpoints ' +
    'diferentes no mesmo MNote2.';

  ButtonControl := TButton.Create(Self);
  ButtonControl.Parent := Page;
  ButtonControl.Caption := 'Aplicar principal a todos os perfis';
  ButtonControl.SetBounds(24, 320, 240, 30);
  ButtonControl.OnClick := @ApplyMainClick;

  Info := TLabel.Create(Self);
  Info.Parent := Page;
  Info.AutoSize := False;
  Info.WordWrap := True;
  Info.SetBounds(24, 366, 650, 48);
  Info.Caption := 'Use o botão acima para começar com uma única IA. Depois, ' +
    'altere individualmente somente os perfis que devem usar outra IA.';

  MainProviderChange(nil);
end;

procedure TfrmIAConfig.MainProviderChange(Sender: TObject);
begin
  FMainModel.Items.Clear;
  case FMainProvider.ItemIndex of
    0: FMainModel.Items.AddStrings(['gpt-4o-mini', 'gpt-4o', 'gpt-4-turbo',
      'gpt-4', 'gpt-3.5-turbo', 'o1-mini']);
    1: FMainModel.Items.AddStrings(['google/gemma-2-9b-it:free',
      'meta-llama/llama-3-8b-instruct:free',
      'mistralai/mistral-7b-instruct:free',
      'microsoft/phi-3-medium-128k-instruct:free',
      'deepseek/deepseek-chat']);
    2: FMainModel.Items.AddStrings(['llama3.1-8b', 'llama3.1-70b',
      'llama-3.3-70b']);
    3: FMainModel.Items.AddStrings(['llama3.2:3b', 'mistral', 'gemma2',
      'deepseek-r1:1.5b', 'deepseek-r1:8b', 'qwen2.5:14b']);
    4: FMainModel.Items.AddStrings(['gemini-1.5-flash', 'gemini-1.5-pro',
      'gemini-2.0-flash', 'gemini-2.5-flash', 'gemini-3.5-flash']);
  end;
  case FMainProvider.ItemIndex of
    0: FMainModel.Text := FSetMain.ModelOpenAI;
    1: FMainModel.Text := FSetMain.ModelOpenRouter;
    2: FMainModel.Text := FSetMain.ModelCerebras;
    3: FMainModel.Text := FSetMain.ModelLocal;
    4: FMainModel.Text := FSetMain.ModelGemini;
  else
    FMainModel.Text := '';
  end;
end;

procedure TfrmIAConfig.AddRolePage(ARole: TMNoteAIRole);
var
  Page: TTabSheet;
  Config: TMNoteAIProfileConfig;
begin
  Config := MNoteAI.Profiles.Profile(ARole).Config;
  Page := TTabSheet.Create(Self);
  Page.PageControl := FPages;
  Page.Caption := MNoteAIRoleName(ARole);

  AddLabel(Self, Page, 'Provider', 16, 18);
  FProvider[ARole] := TComboBox.Create(Self);
  FProvider[ARole].Parent := Page;
  FProvider[ARole].Style := csDropDownList;
  AddProviders(FProvider[ARole], True);
  FProvider[ARole].SetBounds(16, 38, 180, 25);
  FProvider[ARole].ItemIndex := Config.Provider;

  AddLabel(Self, Page, 'Modelo', 215, 18);
  FModel[ARole] := TEdit.Create(Self);
  FModel[ARole].Parent := Page;
  FModel[ARole].SetBounds(215, 38, 210, 25);
  FModel[ARole].Text := Config.ModelName;

  AddLabel(Self, Page, 'Endpoint (opcional)', 445, 18);
  FEndpoint[ARole] := TEdit.Create(Self);
  FEndpoint[ARole].Parent := Page;
  FEndpoint[ARole].SetBounds(445, 38, 260, 25);
  FEndpoint[ARole].Text := Config.Endpoint;

  AddLabel(Self, Page, 'Entrada', 16, 82);
  FInputBudget[ARole] := TEdit.Create(Self);
  FInputBudget[ARole].Parent := Page;
  FInputBudget[ARole].SetBounds(16, 102, 90, 25);
  FInputBudget[ARole].Text := IntToStr(Config.InputBudget);

  AddLabel(Self, Page, 'Saída', 125, 82);
  FOutputBudget[ARole] := TEdit.Create(Self);
  FOutputBudget[ARole].Parent := Page;
  FOutputBudget[ARole].SetBounds(125, 102, 90, 25);
  FOutputBudget[ARole].Text := IntToStr(Config.OutputBudget);

  AddLabel(Self, Page, 'Janela (0 = desconhecida)', 235, 82);
  FContextWindow[ARole] := TEdit.Create(Self);
  FContextWindow[ARole].Parent := Page;
  FContextWindow[ARole].SetBounds(235, 102, 120, 25);
  FContextWindow[ARole].Text := IntToStr(Config.ContextWindow);

  AddLabel(Self, Page, 'Temperatura', 375, 82);
  FTemperature[ARole] := TEdit.Create(Self);
  FTemperature[ARole].Parent := Page;
  FTemperature[ARole].SetBounds(375, 102, 90, 25);
  FTemperature[ARole].Text := FloatToStr(Config.Temperature);

  FEnabled[ARole] := TCheckBox.Create(Self);
  FEnabled[ARole].Parent := Page;
  FEnabled[ARole].Caption := 'Perfil habilitado';
  FEnabled[ARole].SetBounds(490, 100, 150, 25);
  FEnabled[ARole].Checked := Config.Enabled;

  AddLabel(Self, Page, 'Prompt de sistema (não armazene segredos)', 16, 148);
  FPrompt[ARole] := TMemo.Create(Self);
  FPrompt[ARole].Parent := Page;
  FPrompt[ARole].SetBounds(16, 170, 689, 340);
  FPrompt[ARole].Anchors := [akLeft, akTop, akRight, akBottom];
  FPrompt[ARole].ScrollBars := ssVertical;
  FPrompt[ARole].Text := Config.SystemPrompt;
end;

procedure TfrmIAConfig.ApplyMainClick(Sender: TObject);
var
  Role: TMNoteAIRole;
begin
  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
  begin
    FProvider[Role].ItemIndex := FMainProvider.ItemIndex;
    FModel[Role].Text := Trim(FMainModel.Text);
    FEndpoint[Role].Text := Trim(FMainEndpoint.Text);
  end;
  FStatus.Caption := 'IA principal aplicada aos controles de todos os perfis.';
end;

function TfrmIAConfig.StoreMain(out AError: string): Boolean;
begin
  AError := '';
  if FMainProvider.ItemIndex < 0 then
  begin
    AError := 'Selecione o provider da IA principal.';
    Exit(False);
  end;
  if Trim(FMainModel.Text) = '' then
  begin
    AError := 'Informe o modelo da IA principal.';
    Exit(False);
  end;
  if (FMainProvider.ItemIndex = 3) and
    (Trim(FMainEndpoint.Text) = '') then
  begin
    AError := 'Informe o endpoint da IA local.';
    Exit(False);
  end;

  FSetMain.Provider := FMainProvider.ItemIndex;
  FSetMain.CHATGPT := FMainToken.Text;
  FSetMain.IPLocalIA := Trim(FMainEndpoint.Text);
  case FSetMain.Provider of
    0: FSetMain.ModelOpenAI := Trim(FMainModel.Text);
    1: FSetMain.ModelOpenRouter := Trim(FMainModel.Text);
    2: FSetMain.ModelCerebras := Trim(FMainModel.Text);
    3: FSetMain.ModelLocal := Trim(FMainModel.Text);
    4: FSetMain.ModelGemini := Trim(FMainModel.Text);
  end;
  Result := True;
end;

function TfrmIAConfig.StoreProfiles(out AError: string): Boolean;
var
  Role: TMNoteAIRole;
  Config: TMNoteAIProfileConfig;
begin
  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
  begin
    Config := MNoteAI.Profiles.Profile(Role).Config;
    Config.Provider := FProvider[Role].ItemIndex;
    Config.ModelName := Trim(FModel[Role].Text);
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
