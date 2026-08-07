unit mnote_ai_profile;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, SyncObjs, chatgpt, aibase,
  aiagent_memorymap, mnote_ai_types, setmain;

type
  { TMNoteAIProfile }

  TMNoteAIProfile = class
  private
    FConfig: TMNoteAIProfileConfig;
    FClient: TCHATGPT;
    FMemoryMap: TAIAgentMemoryMap;
    FLock: TCriticalSection;
    FState: string;
    FLastReason: string;
  public
    constructor Create(ARole: TMNoteAIRole);
    destructor Destroy; override;
    procedure ApplyConfig;
    function Execute(const AQuestion, ADeveloperMessage: string;
      out AResponse, AError: string): Boolean;
    procedure Cancel;
    property Config: TMNoteAIProfileConfig read FConfig;
    property Client: TCHATGPT read FClient;
    property MemoryMap: TAIAgentMemoryMap read FMemoryMap;
    property State: string read FState;
    property LastReason: string read FLastReason write FLastReason;
  end;

  { TMNoteAIProfiles }

  TMNoteAIProfiles = class
  private
    FItems: array[TMNoteAIRole] of TMNoteAIProfile;
    FTimeoutMS: Integer;
    FMaxCalls: Integer;
    FMaxEstimatedTokens: Integer;
    FMaxToolRounds: Integer;
    function ContainsSensitiveConfiguration(const AText: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function Profile(ARole: TMNoteAIRole): TMNoteAIProfile;
    function SaveToFile(const AFileName: string; out AError: string): Boolean;
    function LoadFromFile(const AFileName: string; out AError: string): Boolean;
    procedure CancelAll;
    property TimeoutMS: Integer read FTimeoutMS write FTimeoutMS;
    property MaxCalls: Integer read FMaxCalls write FMaxCalls;
    property MaxEstimatedTokens: Integer read FMaxEstimatedTokens
      write FMaxEstimatedTokens;
    property MaxToolRounds: Integer read FMaxToolRounds write FMaxToolRounds;
  end;

implementation

constructor TMNoteAIProfile.Create(ARole: TMNoteAIRole);
begin
  inherited Create;
  FConfig := TMNoteAIProfileConfig.Create(ARole);
  FClient := TCHATGPT.Create(nil);
  FMemoryMap := TAIAgentMemoryMap.Create(nil);
  FMemoryMap.FlowName := 'MNote2/' + MNoteAIRoleName(ARole);
  FMemoryMap.StoreFullPrompt := False;
  FMemoryMap.StoreFullResponse := False;
  FMemoryMap.RedactSensitiveData := True;
  FMemoryMap.DetectInformationLoss := True;
  FLock := TCriticalSection.Create;
  FState := 'idle';
  FLastReason := 'Perfil criado pelo TMNoteAIService.';
end;

destructor TMNoteAIProfile.Destroy;
begin
  Cancel;
  FLock.Free;
  FMemoryMap.Free;
  FClient.Free;
  FConfig.Free;
  inherited Destroy;
end;

procedure TMNoteAIProfile.ApplyConfig;
begin
  if (FConfig.Provider >= Ord(Low(TAIProvider))) and
    (FConfig.Provider <= Ord(High(TAIProvider))) then
    FClient.Provider := TAIProvider(FConfig.Provider);
  if FConfig.ModelName <> '' then FClient.CustomModel := FConfig.ModelName;
  if FConfig.Endpoint <> '' then FClient.LocalIP := FConfig.Endpoint;
  FClient.TOKEN := FSetMain.CHATGPT;
  FClient.MaxTokens := FConfig.OutputBudget;
  FClient.Temperature := FConfig.Temperature;
end;

function TMNoteAIProfile.Execute(const AQuestion, ADeveloperMessage: string;
  out AResponse, AError: string): Boolean;
begin
  AResponse := '';
  AError := '';
  if not FConfig.Enabled then
  begin
    AError := 'O perfil ' + MNoteAIRoleName(FConfig.Role) + ' está desabilitado.';
    FLastReason := AError;
    Exit(False);
  end;
  FLock.Acquire;
  try
    FState := 'sending';
    ApplyConfig;
    FClient.Dev := ADeveloperMessage;
    Result := FClient.SendQuestion(AQuestion);
    AResponse := FClient.Response;
    if not Result then
    begin
      AError := FClient.LastError;
      if AError = '' then AError := 'O provider não retornou uma resposta válida.';
      FState := 'failed';
    end
    else
      FState := 'completed';
  finally
    FLock.Release;
  end;
end;

procedure TMNoteAIProfile.Cancel;
begin
  FClient.Cancel;
  FState := 'canceled';
end;

constructor TMNoteAIProfiles.Create;
var
  Role: TMNoteAIRole;
begin
  inherited Create;
  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
    FItems[Role] := TMNoteAIProfile.Create(Role);
  FTimeoutMS := 300000;
  FMaxCalls := 16;
  FMaxEstimatedTokens := 80000;
  FMaxToolRounds := 8;
end;

destructor TMNoteAIProfiles.Destroy;
var
  Role: TMNoteAIRole;
begin
  CancelAll;
  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
    FItems[Role].Free;
  inherited Destroy;
end;

function TMNoteAIProfiles.Profile(ARole: TMNoteAIRole): TMNoteAIProfile;
begin
  Result := FItems[ARole];
end;

function TMNoteAIProfiles.ContainsSensitiveConfiguration(
  const AText: string): Boolean;
var
  Value: string;
begin
  Value := LowerCase(AText);
  Result := (Pos('"token"', Value) > 0) or
    (Pos('"password"', Value) > 0) or (Pos('"api_key"', Value) > 0) or
    (Pos('token=', Value) > 0) or (Pos('password=', Value) > 0) or
    (Pos('api_key=', Value) > 0);
end;

function TMNoteAIProfiles.SaveToFile(const AFileName: string;
  out AError: string): Boolean;
var
  Root, ProfilesObject: TJSONObject;
  Role: TMNoteAIRole;
  Lines: TStringList;
  JSONText, TempFile: string;
begin
  Result := False;
  AError := '';
  Root := TJSONObject.Create;
  Lines := TStringList.Create;
  try
    Root.Add('schema_version', 1);
    Root.Add('timeout_ms', FTimeoutMS);
    Root.Add('max_calls', FMaxCalls);
    Root.Add('max_estimated_tokens', FMaxEstimatedTokens);
    Root.Add('max_tool_rounds', FMaxToolRounds);
    ProfilesObject := TJSONObject.Create;
    Root.Add('profiles', ProfilesObject);
    for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
      ProfilesObject.Add(MNoteAIRoleID(Role), FItems[Role].Config.ToJSON);
    JSONText := Root.FormatJSON;
    if ContainsSensitiveConfiguration(JSONText) then
    begin
      AError := 'A configuração contém um segredo e não será salva.';
      Exit;
    end;
    ForceDirectories(ExtractFilePath(AFileName));
    TempFile := AFileName + '.tmp';
    Lines.Text := JSONText;
    Lines.SaveToFile(TempFile);
    if FileExists(AFileName) and (not DeleteFile(AFileName)) then
    begin AError := 'Não foi possível substituir a configuração.'; Exit; end;
    if not RenameFile(TempFile, AFileName) then
    begin AError := 'Não foi possível concluir a gravação da configuração.'; Exit; end;
    Result := True;
  except
    on E: Exception do AError := E.Message;
  end;
  Lines.Free;
  Root.Free;
end;

function TMNoteAIProfiles.LoadFromFile(const AFileName: string;
  out AError: string): Boolean;
var
  Lines: TStringList;
  Data: TJSONData;
  Root, ProfilesObject: TJSONObject;
  Role: TMNoteAIRole;
  ConfigError: string;
begin
  Result := False;
  AError := '';
  if not FileExists(AFileName) then Exit(True);
  Lines := TStringList.Create;
  Data := nil;
  try
    Lines.LoadFromFile(AFileName);
    if ContainsSensitiveConfiguration(Lines.Text) then
    begin AError := 'Configuração rejeitada porque contém segredo.'; Exit; end;
    Data := GetJSON(Lines.Text);
    if not (Data is TJSONObject) then
    begin AError := 'Objeto JSON esperado.'; Exit; end;
    Root := TJSONObject(Data);
    if not (Root.Find('profiles') is TJSONObject) then
    begin AError := 'Objeto profiles ausente.'; Exit; end;
    ProfilesObject := TJSONObject(Root.Find('profiles'));
    if Root.Find('timeout_ms') <> nil then FTimeoutMS := Root.Integers['timeout_ms'];
    if Root.Find('max_calls') <> nil then FMaxCalls := Root.Integers['max_calls'];
    if Root.Find('max_estimated_tokens') <> nil then
      FMaxEstimatedTokens := Root.Integers['max_estimated_tokens'];
    if Root.Find('max_tool_rounds') <> nil then
      FMaxToolRounds := Root.Integers['max_tool_rounds'];
    if FMaxToolRounds < 1 then FMaxToolRounds := 1;
    if FMaxToolRounds > 32 then FMaxToolRounds := 32;
    for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
    begin
      if not (ProfilesObject.Find(MNoteAIRoleID(Role)) is TJSONObject) then
      begin AError := 'Perfil ausente: ' + MNoteAIRoleName(Role); Exit; end;
      FItems[Role].Config.FromJSON(
        TJSONObject(ProfilesObject.Find(MNoteAIRoleID(Role))));
      if not FItems[Role].Config.Validate(ConfigError) then
      begin AError := MNoteAIRoleName(Role) + ': ' + ConfigError; Exit; end;
    end;
    Result := True;
  except
    on E: Exception do AError := E.Message;
  end;
  Data.Free;
  Lines.Free;
end;

procedure TMNoteAIProfiles.CancelAll;
var
  Role: TMNoteAIRole;
begin
  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
    FItems[Role].Cancel;
end;

end.
