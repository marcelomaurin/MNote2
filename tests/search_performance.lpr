program search_performance;

{$mode objfpc}{$H+}
{$codepage utf8}

uses
  Classes, SysUtils, mnote_search_types, mnote_file_search_service;

procedure WriteText(const AFileName, AText: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFileName, fmCreate);
  try
    if AText <> '' then Stream.WriteBuffer(AText[1], Length(AText));
  finally
    Stream.Free;
  end;
end;

var
  Root, FileName: string;
  I: Integer;
  LargeFile: TFileStream;
  Line: string;
  StartedAt: QWord;
  Service: TMNoteFileSearchService;
  Results: TMNoteSearchResults;
  Options: TMNoteSearchOptions;
begin
  Root := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'search_performance_fixture';
  ForceDirectories(Root);
  try
    for I := 1 to 500 do
      WriteText(IncludeTrailingPathDelimiter(Root) +
        Format('small-%.4d.txt', [I]),
        'arquivo pequeno '#13#10'needle ' + IntToStr(I) + #13#10'fim');
    FileName := IncludeTrailingPathDelimiter(Root) + 'large.txt';
    LargeFile := TFileStream.Create(FileName, fmCreate);
    try
      Line := 'linha grande com needle e conteúdo UTF-8 ação café'#10;
      for I := 1 to 50000 do
        LargeFile.WriteBuffer(Line[1], Length(Line));
    finally
      LargeFile.Free;
    end;

    Service := TMNoteFileSearchService.Create;
    Results := TMNoteSearchResults.Create;
    try
      Options := DefaultSearchOptions;
      Options.IncludePatterns := '*.txt';
      Options.ExcludePatterns := '';
      StartedAt := GetTickCount64;
      if not Service.SearchFolder(Root, 'needle', Options, Results) then
        raise Exception.Create(Service.LastError);
      Writeln('files_scanned=', Service.FilesScanned);
      Writeln('matches=', Results.Count);
      Writeln('search_elapsed_ms=', GetTickCount64 - StartedAt);

      StartedAt := GetTickCount64;
      if not Service.StartSearch(Root, 'needle', Options, Results) then
        raise Exception.Create(Service.LastError);
      Service.Cancel;
      Service.WaitFor;
      Writeln('cancel_elapsed_ms=', GetTickCount64 - StartedAt);
      Writeln('cancel_supported=true');
    finally
      Results.Free;
      Service.Free;
    end;
  finally
    for I := 1 to 500 do
      DeleteFile(IncludeTrailingPathDelimiter(Root) +
        Format('small-%.4d.txt', [I]));
    DeleteFile(IncludeTrailingPathDelimiter(Root) + 'large.txt');
    RemoveDir(Root);
  end;
end.
