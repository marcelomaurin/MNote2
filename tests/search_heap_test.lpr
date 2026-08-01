program search_heap_test;

{$mode objfpc}{$H+}
{$codepage utf8}

uses
  SysUtils, mnote_search_types, mnote_text_search_service;

var
  Iteration: Integer;
  Service: TMNoteTextSearchService;
  Results: TMNoteSearchResults;
  Options: TMNoteSearchOptions;
begin
  Options := DefaultSearchOptions;
  for Iteration := 1 to 1000 do
  begin
    Service := TMNoteTextSearchService.Create;
    Results := TMNoteSearchResults.Create;
    try
      if not Service.SearchText('ação alpha'#13#10'id id_usuario',
        'alpha', 'heap.txt', Options, Results) then
        raise Exception.Create(Service.LastError);
      Results.Clear;
    finally
      Results.Free;
      Service.Free;
    end;
  end;
  Writeln('OK: 1000 ciclos de busca, navegação lógica e limpeza');
end.
