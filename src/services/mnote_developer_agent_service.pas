unit mnote_developer_agent_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_chatgpt_agent_service;

type
  TMNoteDeveloperAgentService = class
  private
    FAgent: TMNoteChatGPTAgentService;
    FWorkspaceRoot: string;
    FProjectFile: string;
    FLastPlan: string;
    FLastError: string;
    function FindLazarusProject(const ARoot: string): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ConfigureWorkspace(const ARoot: string);
    function PrepareInstruction(const AInstruction: string): Boolean;
    function ExecutePreparedPlan: Boolean;
    property WorkspaceRoot: string read FWorkspaceRoot;
    property ProjectFile: string read FProjectFile;
    property LastPlan: string read FLastPlan;
    property LastError: string read FLastError;
    property Agent: TMNoteChatGPTAgentService read FAgent;
  end;

procedure InitializeMNoteDeveloperAgent;
procedure FinalizeMNoteDeveloperAgent;
function MNoteDeveloperAgent: TMNoteDeveloperAgentService;

implementation

uses
  mnote_ai_service;

var
  GDeveloperAgent: TMNoteDeveloperAgentService = nil;

constructor TMNoteDeveloperAgentService.Create;
begin
  inherited Create;
  FAgent := TMNoteChatGPTAgentService.Create(MNoteAI.DefaultClient,
    MNoteAI.DefaultClient);
  ConfigureWorkspace(GetCurrentDir);
end;

destructor TMNoteDeveloperAgentService.Destroy;
begin
  FAgent.Free;
  inherited Destroy;
end;

function TMNoteDeveloperAgentService.FindLazarusProject(
  const ARoot: string): string;
var
  SR: TSearchRec;
  Root: string;
begin
  Result := '';
  Root := IncludeTrailingPathDelimiter(ARoot);
  if FindFirst(Root + '*.lpi', faAnyFile and not faDirectory, SR) = 0 then
  try
    Result := SR.Name;
  finally
    FindClose(SR);
  end;
end;

procedure TMNoteDeveloperAgentService.ConfigureWorkspace(const ARoot: string);
var
  Root: string;
begin
  Root := Trim(ARoot);
  if Root = '' then Root := GetCurrentDir;
  Root := ExcludeTrailingPathDelimiter(ExpandFileName(Root));
  FWorkspaceRoot := Root;
  FProjectFile := FindLazarusProject(Root);
  FAgent.ConfigureDeveloperWorkspace(FWorkspaceRoot, FProjectFile,
    'lazbuild', '-B', '', '');
end;

function TMNoteDeveloperAgentService.PrepareInstruction(
  const AInstruction: string): Boolean;
begin
  FLastError := '';
  FLastPlan := '';
  if Trim(AInstruction) = '' then
  begin
    FLastError := 'Informe a orientação para correção.';
    Exit(False);
  end;
  FAgent.Executor.ForcarSimulacaoGlobal := True;
  Result := FAgent.Run(AInstruction);
  if not Result then
  begin
    FLastError := FAgent.LastError;
    Exit;
  end;
  FLastPlan := FAgent.LastPreparedPlan;
  Result := Trim(FLastPlan) <> '';
  if not Result then
    FLastError := 'A IA não produziu um plano de ações executável.';
end;

function TMNoteDeveloperAgentService.ExecutePreparedPlan: Boolean;
begin
  FLastError := '';
  if Trim(FLastPlan) = '' then
  begin
    FLastError := 'Nenhum plano preparado para executar.';
    Exit(False);
  end;
  FAgent.Executor.ForcarSimulacaoGlobal := False;
  Result := FAgent.ExecutePreparedPlan(FLastPlan);
  if not Result then FLastError := FAgent.LastError;
end;

procedure InitializeMNoteDeveloperAgent;
begin
  if GDeveloperAgent = nil then
    GDeveloperAgent := TMNoteDeveloperAgentService.Create;
end;

procedure FinalizeMNoteDeveloperAgent;
begin
  FreeAndNil(GDeveloperAgent);
end;

function MNoteDeveloperAgent: TMNoteDeveloperAgentService;
begin
  if GDeveloperAgent = nil then InitializeMNoteDeveloperAgent;
  Result := GDeveloperAgent;
end;

finalization
  FinalizeMNoteDeveloperAgent;

end.
