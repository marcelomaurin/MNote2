unit mnote_completion_provider;

{$mode objfpc}{$H+}

interface

uses
  mnote_completion_types;

type
  IMNoteCompletionProvider = interface
    ['{B79E8D10-DFE4-49E1-A7AF-4FC548172783}']
    function Supports(AContext: TMNoteCompletionContext): Boolean;
    procedure Collect(AContext: TMNoteCompletionContext;
      AItems: TMNoteCompletionItems);
    function ResolveDocumentation(AItem: TMNoteCompletionItem): string;
  end;

implementation

end.
