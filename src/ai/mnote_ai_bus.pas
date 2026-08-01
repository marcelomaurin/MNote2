unit mnote_ai_bus;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs, mnote_ai_types;

type
  { TMNoteAIBusMessage }

  TMNoteAIBusMessage = class
  public
    Origin: TMNoteAIRole;
    Destination: TMNoteAIRole;
    Question: string;
    MinimalContext: string;
    Confidence: Double;
    ParentOrder: Integer;
    Depth: Integer;
    Quota: Integer;
    RoutePath: string;
    Answer: string;
    Status: string;
  end;

  { TMNoteAIBus }

  TMNoteAIBus = class(TObjectList)
  private
    FMaxDepth: Integer;
    FMaxQuota: Integer;
    function GetMessage(AIndex: Integer): TMNoteAIBusMessage;
    function RoleInPath(ARole: TMNoteAIRole; const APath: string): Boolean;
  public
    constructor Create;
    function IsAllowed(AOrigin, ADestination: TMNoteAIRole;
      ADepth, AQuota: Integer; const ARoutePath: string;
      out AReason: string): Boolean;
    function Ask(AOrigin, ADestination: TMNoteAIRole; const AQuestion,
      AMinimalContext: string; AConfidence: Double; AParentOrder,
      ADepth, AQuota: Integer; const ARoutePath: string;
      out AReason: string): TMNoteAIBusMessage;
    procedure Answer(AMessage: TMNoteAIBusMessage; const AText: string);
    property Messages[AIndex: Integer]: TMNoteAIBusMessage read GetMessage;
    property MaxDepth: Integer read FMaxDepth write FMaxDepth;
    property MaxQuota: Integer read FMaxQuota write FMaxQuota;
  end;

implementation

constructor TMNoteAIBus.Create;
begin
  inherited Create(True);
  FMaxDepth := 3;
  FMaxQuota := 8;
end;

function TMNoteAIBus.GetMessage(AIndex: Integer): TMNoteAIBusMessage;
begin
  Result := TMNoteAIBusMessage(inherited Items[AIndex]);
end;

function TMNoteAIBus.RoleInPath(ARole: TMNoteAIRole;
  const APath: string): Boolean;
var
  Parts: TStringList;
begin
  Parts := TStringList.Create;
  try
    Parts.Delimiter := '>';
    Parts.StrictDelimiter := True;
    Parts.DelimitedText := APath;
    Result := Parts.IndexOf(MNoteAIRoleID(ARole)) >= 0;
  finally
    Parts.Free;
  end;
end;

function TMNoteAIBus.IsAllowed(AOrigin, ADestination: TMNoteAIRole;
  ADepth, AQuota: Integer; const ARoutePath: string;
  out AReason: string): Boolean;
begin
  AReason := '';
  if ADepth > FMaxDepth then AReason := 'profundidade_excedida'
  else if AQuota > FMaxQuota then AReason := 'cota_excedida'
  else if RoleInPath(ADestination, ARoutePath) then AReason := 'ciclo_detectado'
  else if (AOrigin = airTriage) or (AOrigin = airArbiter) then
    AReason := 'origem_sem_permissao_para_delegar'
  else if (ADestination = airRecovery) or (ADestination = airArbiter) then
    AReason := 'destino_reservado_ao_router'
  else
    case AOrigin of
      airLightWork:
        if not (ADestination in [airDatabase]) then AReason := 'relacao_negada';
      airDatabase:
        if not (ADestination in [airLightWork]) then AReason := 'relacao_negada';
      airManagement:
        if not (ADestination in [airTriage, airLightWork, airDatabase]) then
          AReason := 'relacao_negada';
      airRecovery: AReason := 'recuperacao_nao_delega';
    end;
  Result := AReason = '';
end;

function TMNoteAIBus.Ask(AOrigin, ADestination: TMNoteAIRole;
  const AQuestion, AMinimalContext: string; AConfidence: Double;
  AParentOrder, ADepth, AQuota: Integer; const ARoutePath: string;
  out AReason: string): TMNoteAIBusMessage;
begin
  Result := nil;
  if not IsAllowed(AOrigin, ADestination, ADepth, AQuota, ARoutePath,
    AReason) then Exit;
  Result := TMNoteAIBusMessage.Create;
  Result.Origin := AOrigin;
  Result.Destination := ADestination;
  Result.Question := AQuestion;
  Result.MinimalContext := AMinimalContext;
  Result.Confidence := AConfidence;
  Result.ParentOrder := AParentOrder;
  Result.Depth := ADepth;
  Result.Quota := AQuota;
  if ARoutePath = '' then Result.RoutePath := MNoteAIRoleID(AOrigin)
  else Result.RoutePath := ARoutePath;
  Result.RoutePath := Result.RoutePath + '>' + MNoteAIRoleID(ADestination);
  Result.Status := 'queued';
  Add(Result);
end;

procedure TMNoteAIBus.Answer(AMessage: TMNoteAIBusMessage;
  const AText: string);
begin
  if AMessage = nil then Exit;
  AMessage.Answer := AText;
  AMessage.Status := 'answered';
end;

end.
