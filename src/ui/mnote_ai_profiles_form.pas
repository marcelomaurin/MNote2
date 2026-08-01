unit mnote_ai_profiles_form;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, ComCtrls, Dialogs,
  mnote_ai_service, mnote_ai_types;

type
  { TMNoteAIProfilesForm }

  TMNoteAIProfilesForm = class(TForm)
  private
    FPages: TPageControl;
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
    procedure AddRolePage(ARole: TMNoteAIRole);
    function StoreControls(out AError: string): Boolean;
    procedure SaveClick(Sender: TObject);
    procedure TestClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

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

constructor TMNoteAIProfilesForm.Create(AOwner: TComponent);
var
  Role: TMNoteAIRole;
  Buttons: TPanel;
  ButtonControl: TButton;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Perfis multi-IA';
  Position := poScreenCenter;
  Width := 700;
  Height := 590;
  FPages := TPageControl.Create(Self);
  FPages.Parent := Self;
  FPages.Align := alClient;
  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do AddRolePage(Role);

  Buttons := TPanel.Create(Self);
  Buttons.Parent := Self;
  Buttons.Align := alBottom;
  Buttons.Height := 42;
  FStatus := TLabel.Create(Self);
  FStatus.Parent := Buttons;
  FStatus.SetBounds(8, 13, 360, 18);
  FStatus.Caption := 'Tokens continuam no mecanismo seguro do MNote2.';
  ButtonControl := TButton.Create(Self);
  ButtonControl.Parent := Buttons;
  ButtonControl.Caption := 'Testar perfil';
  ButtonControl.SetBounds(390, 8, 92, 27);
  ButtonControl.OnClick := @TestClick;
  ButtonControl := TButton.Create(Self);
  ButtonControl.Parent := Buttons;
  ButtonControl.Caption := 'Salvar';
  ButtonControl.SetBounds(488, 8, 82, 27);
  ButtonControl.OnClick := @SaveClick;
  ButtonControl := TButton.Create(Self);
  ButtonControl.Parent := Buttons;
  ButtonControl.Caption := 'Fechar';
  ButtonControl.SetBounds(576, 8, 82, 27);
  ButtonControl.OnClick := @CloseClick;
end;

procedure TMNoteAIProfilesForm.AddRolePage(ARole: TMNoteAIRole);
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
  FProvider[ARole].Items.AddStrings(['OpenAI', 'OpenRouter', 'Cerebras',
    'Local', 'Gemini', 'Claude']);
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
  FEndpoint[ARole].SetBounds(445, 38, 210, 25);
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
  FPrompt[ARole].SetBounds(16, 170, 639, 300);
  FPrompt[ARole].Anchors := [akLeft, akTop, akRight, akBottom];
  FPrompt[ARole].ScrollBars := ssVertical;
  FPrompt[ARole].Text := Config.SystemPrompt;
end;

function TMNoteAIProfilesForm.StoreControls(out AError: string): Boolean;
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

procedure TMNoteAIProfilesForm.SaveClick(Sender: TObject);
var
  ErrorText: string;
begin
  if not StoreControls(ErrorText) then
  begin ShowMessage(ErrorText); Exit; end;
  if not MNoteAI.SaveProfiles(ErrorText) then
  begin ShowMessage(ErrorText); Exit; end;
  FStatus.Caption := 'Configuração salva sem tokens ou senhas.';
end;

procedure TMNoteAIProfilesForm.TestClick(Sender: TObject);
var
  ErrorText: string;
  Role: TMNoteAIRole;
begin
  if not StoreControls(ErrorText) then
  begin ShowMessage(ErrorText); Exit; end;
  Role := TMNoteAIRole(FPages.ActivePageIndex);
  if not MNoteAI.SendProfileTestAsync(Role) then
  begin ShowMessage(MNoteAI.LastError); Exit; end;
  FStatus.Caption := 'Teste real iniciado; acompanhe AI e AI Monitor.';
end;

procedure TMNoteAIProfilesForm.CloseClick(Sender: TObject);
begin
  Close;
end;

end.
