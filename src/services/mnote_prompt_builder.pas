unit mnote_prompt_builder;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

type
  TMNotePromptBuilder = class
  public
    class function Build(const ARole, AObjective, ARestrictions,
      AContext, AOutputContract: string): string; static;
  end;

implementation

uses
  SysUtils;

class function TMNotePromptBuilder.Build(const ARole, AObjective,
  ARestrictions, AContext, AOutputContract: string): string;
begin
  Result := '[PAPEL]'#10 + Trim(ARole) + #10#10 +
    '[OBJETIVO]'#10 + Trim(AObjective) + #10#10 +
    '[RESTRIÇÕES]'#10 + Trim(ARestrictions) + #10#10 +
    '[CONTEXTO]'#10 + Trim(AContext) + #10#10 +
    '[CONTRATO DE SAÍDA]'#10 + Trim(AOutputContract);
end;

end.
