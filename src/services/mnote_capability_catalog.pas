unit mnote_capability_catalog;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs;

type
  TMNoteCapabilityState = (mcsIntegrated, mcsAvailable, mcsOptional,
    mcsExperimental, mcsUnavailable, mcsNotApplicable);

  TMNoteCapability = class
  public
    Category: string;
    Name: string;
    PackageName: string;
    State: TMNoteCapabilityState;
    Dependency: string;
    Evidence: string;
  end;

  { TMNoteCapabilityCatalog }

  TMNoteCapabilityCatalog = class
  private
    FItems: TObjectList;
    procedure Add(const ACategory, AName, APackage: string;
      AState: TMNoteCapabilityState; const ADependency, AEvidence: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Refresh(AVoiceEnabled: Boolean);
    function AsText: string;
    property Items: TObjectList read FItems;
  end;

function MNoteCapabilityStateName(AState: TMNoteCapabilityState): string;

implementation

function MNoteCapabilityStateName(AState: TMNoteCapabilityState): string;
begin
  case AState of
    mcsIntegrated: Result := 'Integrado';
    mcsAvailable: Result := 'Disponível';
    mcsOptional: Result := 'Opcional';
    mcsExperimental: Result := 'Experimental';
    mcsUnavailable: Result := 'Indisponível';
    mcsNotApplicable: Result := 'Não aplicável';
  end;
end;

constructor TMNoteCapabilityCatalog.Create;
begin
  inherited Create;
  FItems := TObjectList.Create(True);
end;

destructor TMNoteCapabilityCatalog.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TMNoteCapabilityCatalog.Add(const ACategory, AName,
  APackage: string; AState: TMNoteCapabilityState;
  const ADependency, AEvidence: string);
var
  Item: TMNoteCapability;
begin
  Item := TMNoteCapability.Create;
  Item.Category := ACategory;
  Item.Name := AName;
  Item.PackageName := APackage;
  Item.State := AState;
  Item.Dependency := ADependency;
  Item.Evidence := AEvidence;
  FItems.Add(Item);
end;

procedure TMNoteCapabilityCatalog.Refresh(AVoiceEnabled: Boolean);
begin
  FItems.Clear;
  Add('Core', 'Chat e provedores', 'openai_core', mcsIntegrated, '',
    'TMNoteAIService e painel AI');
  Add('Agentes', 'Memória, triagem, decisão e ações', 'openai_agentcore',
    mcsIntegrated, '', 'Router, monitor, barramento e executor central');
  Add('Agentes', 'Agent Safety', 'openai_agentcore', mcsIntegrated, '',
    'Allowlist, raiz segura, efeitos e confirmação no executor');
  Add('Projeto', 'Projeto e tarefas', 'openai_project_core', mcsIntegrated,
    '', 'Painel Tasks e arquivo .mnoteproj.json');
  Add('Arquivos', 'Disk Tree Scanner', 'openai_files', mcsIntegrated, '',
    'Painel Files; ativação persistida na configuração');
  Add('Arquivos', 'Document Files Manager', 'openai_files', mcsIntegrated,
    '', 'Inventário explícito em .mnote/documentation');
  Add('Saída', 'Output Docs TXT/PDF', 'openai_output', mcsIntegrated, '',
    'Exportação de relatórios pelo painel Tasks/Components Lab');
  Add('Saída', 'Word/Excel', 'openai_output', mcsExperimental,
    'Formatos simplificados do componente',
    'Não oferecidos como documentos Office completos');
  Add('Grafo', 'Dependency Graph', 'openai_graphcore', mcsIntegrated, '',
    'Grafo factual/inferido no Components Lab');
  Add('Agentes', 'TAIPipeline', 'openai_agent', mcsOptional,
    'GLScene, ML, Input e Output',
    'Não carregado nem usado pela malha multi-IA');
  Add('Web', 'Chromium/CEF', 'openai_input', mcsUnavailable,
    'CEF4Delphi + runtime CEF', 'Núcleo funciona sem CEF');
  if AVoiceEnabled then
    Add('Voz', 'Ditado e leitura de resposta', 'MNote2/SAPI', mcsIntegrated,
      'Serviço de voz configurado', 'Wake word e resposta conforme modalidade')
  else
    Add('Voz', 'Ditado e leitura de resposta', 'MNote2/SAPI', mcsAvailable,
      'Ativar ToolsOuvir/ToolsFalar', 'Recurso totalmente desativável');
  Add('Lab', 'ML, Vision, Image, Simulation, Industrial e Graphic',
    'openai_*', mcsOptional, 'Pacotes e runtimes específicos',
    'Não carregados durante a inicialização');
  Add('Rede', 'Web server, sockets, e-mail, serial e USB', 'openai_input',
    mcsOptional, 'Drivers e configuração explícita',
    'Somente catálogo; nenhuma ação externa habilitada');
  Add('Rede', 'MQTT e Modbus', 'openai_industrial', mcsOptional,
    'Broker ou hardware real', 'Somente catálogo; escrita bloqueada');
end;

function TMNoteCapabilityCatalog.AsText: string;
var
  Lines: TStringList;
  I: Integer;
  Item: TMNoteCapability;
begin
  Lines := TStringList.Create;
  try
    Lines.Add('Catálogo de capacidades do MNote2');
    Lines.Add('');
    for I := 0 to FItems.Count - 1 do
    begin
      Item := TMNoteCapability(FItems[I]);
      Lines.Add(Format('[%s] %s — %s', [MNoteCapabilityStateName(Item.State),
        Item.Category, Item.Name]));
      Lines.Add('Pacote: ' + Item.PackageName);
      if Item.Dependency <> '' then Lines.Add('Dependência: ' + Item.Dependency);
      Lines.Add('Evidência: ' + Item.Evidence);
      Lines.Add('');
    end;
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

end.
