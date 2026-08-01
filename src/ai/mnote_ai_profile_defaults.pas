unit mnote_ai_profile_defaults;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  mnote_ai_profile;

procedure ApplyMainAIToProfiles(AProfiles: TMNoteAIProfiles;
  AProvider: Integer; const AModelName, AEndpoint: string);

implementation

uses
  mnote_ai_types;

procedure ApplyMainAIToProfiles(AProfiles: TMNoteAIProfiles;
  AProvider: Integer; const AModelName, AEndpoint: string);
var
  Role: TMNoteAIRole;
  Config: TMNoteAIProfileConfig;
begin
  if AProfiles = nil then Exit;
  for Role := Low(TMNoteAIRole) to High(TMNoteAIRole) do
  begin
    Config := AProfiles.Profile(Role).Config;
    Config.Provider := AProvider;
    Config.ModelName := AModelName;
    Config.Endpoint := AEndpoint;
  end;
end;

end.
