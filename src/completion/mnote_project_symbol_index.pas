unit mnote_project_symbol_index;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs, mnote_completion_types,
  mnote_completion_provider;

type
  { TMNoteIndexedFile }

  TMNoteIndexedFile = class
  public
    FileName: string;
    Hash: QWord;
    FileDate: Int64;
    Symbols: TMNoteCompletionItems;
    constructor Create;
    destructor Destroy; override;
  end;

  { TMNoteProjectSymbolIndex }

  TMNoteProjectSymbolIndex = class(TInterfacedObject,
    IMNoteCompletionProvider)
  private
    FFiles: TObjectList;
    FIndexedCount: Integer;
    FReusedCount: Integer;
    function BufferHash(const AText: string): QWord;
    function FindFile(const AFileName: string): TMNoteIndexedFile;
    procedure CollectFiles(const ARoot: string; AFiles: TStrings);
    function IsSupportedFile(const AFileName: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function IndexFolder(const ARoot: string): Boolean;
    function IndexFile(const AFileName: string): Boolean;
    function SaveCache(const ACacheFile: string): Boolean;
    function LoadCache(const ACacheFile: string): Boolean;
    function FindDefinition(const AName: string): TMNoteCompletionItem;
    procedure ListSymbols(AItems: TMNoteCompletionItems; AMaxItems: Integer);
    function Supports(AContext: TMNoteCompletionContext): Boolean;
    procedure Collect(AContext: TMNoteCompletionContext;
      AItems: TMNoteCompletionItems);
    function ResolveDocumentation(AItem: TMNoteCompletionItem): string;
    property IndexedCount: Integer read FIndexedCount;
    property ReusedCount: Integer read FReusedCount;
  end;

function MNoteProjectSymbols: TMNoteProjectSymbolIndex;

implementation

uses
  mnote_pascal_symbol_parser;

var
  GProjectSymbols: TMNoteProjectSymbolIndex;
  GProjectSymbolsReference: IMNoteCompletionProvider;

function EscapeField(const AValue: string): string;
begin
  Result := StringReplace(AValue, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, #9, '\t', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
end;

function UnescapeField(const AValue: string): string;
var
  I: Integer;
begin
  Result := '';
  I := 1;
  while I <= Length(AValue) do
  begin
    if (AValue[I] = '\') and (I < Length(AValue)) then
    begin
      Inc(I);
      case AValue[I] of
        't': Result := Result + #9;
        'r': Result := Result + #13;
        'n': Result := Result + #10;
        '\': Result := Result + '\';
        else Result := Result + AValue[I];
      end;
    end
    else Result := Result + AValue[I];
    Inc(I);
  end;
end;

constructor TMNoteIndexedFile.Create;
begin
  inherited Create;
  Symbols := TMNoteCompletionItems.Create;
end;

destructor TMNoteIndexedFile.Destroy;
begin
  Symbols.Free;
  inherited Destroy;
end;

constructor TMNoteProjectSymbolIndex.Create;
begin
  inherited Create;
  FFiles := TObjectList.Create(True);
end;

destructor TMNoteProjectSymbolIndex.Destroy;
begin
  FFiles.Free;
  inherited Destroy;
end;

procedure TMNoteProjectSymbolIndex.Clear;
begin
  FFiles.Clear;
  FIndexedCount := 0;
  FReusedCount := 0;
end;

function TMNoteProjectSymbolIndex.BufferHash(const AText: string): QWord;
var
  I: Integer;
begin
  Result := QWord($CBF29CE484222325);
  for I := 1 to Length(AText) do
  begin
    Result := Result xor Byte(AText[I]);
    Result := Result * QWord($100000001B3);
  end;
end;

function TMNoteProjectSymbolIndex.FindFile(
  const AFileName: string): TMNoteIndexedFile;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FFiles.Count - 1 do
    if SameFileName(TMNoteIndexedFile(FFiles[I]).FileName,
      ExpandFileName(AFileName)) then Exit(TMNoteIndexedFile(FFiles[I]));
end;

function TMNoteProjectSymbolIndex.IsSupportedFile(
  const AFileName: string): Boolean;
var
  Extension: string;
begin
  Extension := LowerCase(ExtractFileExt(AFileName));
  Result := (Extension = '.pas') or (Extension = '.pp') or
    (Extension = '.lpr') or (Extension = '.inc');
end;

procedure TMNoteProjectSymbolIndex.CollectFiles(const ARoot: string;
  AFiles: TStrings);
var
  SearchRecord: TSearchRec;
  CurrentPath: string;
begin
  if FindFirst(IncludeTrailingPathDelimiter(ARoot) + '*', faAnyFile,
    SearchRecord) <> 0 then Exit;
  try
    repeat
      if (SearchRecord.Name = '.') or (SearchRecord.Name = '..') then Continue;
      CurrentPath := IncludeTrailingPathDelimiter(ARoot) + SearchRecord.Name;
      if (SearchRecord.Attr and faDirectory) <> 0 then
      begin
        if not SameText(SearchRecord.Name, '.git') and
          not SameText(SearchRecord.Name, 'lib') and
          not SameText(SearchRecord.Name, 'backup') and
          not SameText(SearchRecord.Name, '.mnote') then
          CollectFiles(CurrentPath, AFiles);
      end
      else if IsSupportedFile(CurrentPath) then
        AFiles.Add(ExpandFileName(CurrentPath));
    until FindNext(SearchRecord) <> 0;
  finally
    FindClose(SearchRecord);
  end;
end;

function TMNoteProjectSymbolIndex.IndexFile(const AFileName: string): Boolean;
var
  Content: TStringList;
  NewHash: QWord;
  Entry: TMNoteIndexedFile;
  Parser: TMNotePascalSymbolParser;
begin
  Result := False;
  if not FileExists(AFileName) or not IsSupportedFile(AFileName) then Exit;
  Content := TStringList.Create;
  try
    Content.LoadFromFile(AFileName);
    NewHash := BufferHash(Content.Text);
    Entry := FindFile(AFileName);
    if (Entry <> nil) and (Entry.Hash = NewHash) then
    begin
      Inc(FReusedCount);
      Exit(True);
    end;
    if Entry = nil then
    begin
      Entry := TMNoteIndexedFile.Create;
      Entry.FileName := ExpandFileName(AFileName);
      FFiles.Add(Entry);
    end;
    Entry.Symbols.Clear;
    Parser := TMNotePascalSymbolParser.Create;
    try
      Parser.Parse(Content.Text, Entry.FileName, 'projeto', Entry.Symbols);
    finally
      Parser.Free;
    end;
    Entry.Hash := NewHash;
    Entry.FileDate := FileAge(AFileName);
    Inc(FIndexedCount);
    Result := True;
  finally
    Content.Free;
  end;
end;

function TMNoteProjectSymbolIndex.IndexFolder(const ARoot: string): Boolean;
var
  Files: TStringList;
  I: Integer;
begin
  Result := DirectoryExists(ARoot);
  if not Result then Exit;
  FIndexedCount := 0;
  FReusedCount := 0;
  Files := TStringList.Create;
  try
    CollectFiles(ExpandFileName(ARoot), Files);
    Files.Sort;
    for I := 0 to Files.Count - 1 do
      if not IndexFile(Files[I]) then Result := False;
  finally
    Files.Free;
  end;
end;

function TMNoteProjectSymbolIndex.SaveCache(const ACacheFile: string): Boolean;
var
  Output: TStringList;
  Entry: TMNoteIndexedFile;
  Symbol: TMNoteCompletionItem;
  I, J: Integer;
begin
  Result := False;
  if ExtractFileDir(ACacheFile) <> '' then
    ForceDirectories(ExtractFileDir(ACacheFile));
  Output := TStringList.Create;
  try
    Output.Add('MNOTE_SYMBOL_CACHE'#9'1');
    for I := 0 to FFiles.Count - 1 do
    begin
      Entry := TMNoteIndexedFile(FFiles[I]);
      Output.Add('F'#9+EscapeField(Entry.FileName)+#9+
        UIntToStr(Entry.Hash)+#9+IntToStr(Entry.FileDate));
      for J := 0 to Entry.Symbols.Count - 1 do
      begin
        Symbol := Entry.Symbols[J];
        Output.Add('S'#9+EscapeField(Entry.FileName)+#9+
          IntToStr(Ord(Symbol.Kind))+#9+IntToStr(Symbol.Line)+#9+
          EscapeField(Symbol.Text)+#9+EscapeField(Symbol.Signature));
      end;
    end;
    Output.SaveToFile(ACacheFile);
    Result := True;
  finally
    Output.Free;
  end;
end;

function TMNoteProjectSymbolIndex.LoadCache(const ACacheFile: string): Boolean;
var
  Input, Fields: TStringList;
  I: Integer;
  Entry: TMNoteIndexedFile;
  Item: TMNoteCompletionItem;
begin
  Result := False;
  if not FileExists(ACacheFile) then Exit;
  Input := TStringList.Create;
  Fields := TStringList.Create;
  try
    Input.LoadFromFile(ACacheFile);
    if (Input.Count = 0) or (Input[0] <> 'MNOTE_SYMBOL_CACHE'#9'1') then Exit;
    Clear;
    Fields.StrictDelimiter := True;
    Fields.Delimiter := #9;
    for I := 1 to Input.Count - 1 do
    begin
      Fields.DelimitedText := Input[I];
      if (Fields.Count >= 4) and (Fields[0] = 'F') then
      begin
        Entry := TMNoteIndexedFile.Create;
        Entry.FileName := UnescapeField(Fields[1]);
        Entry.Hash := StrToQWordDef(Fields[2], 0);
        Entry.FileDate := StrToInt64Def(Fields[3], 0);
        FFiles.Add(Entry);
      end
      else if (Fields.Count >= 6) and (Fields[0] = 'S') then
      begin
        Entry := FindFile(UnescapeField(Fields[1]));
        if Entry = nil then Continue;
        Item := TMNoteCompletionItem.Create(UnescapeField(Fields[4]),
          TMNoteCompletionKind(StrToIntDef(Fields[2], 0)), 'projeto', 20);
        Item.Line := StrToIntDef(Fields[3], -1);
        Item.FileName := Entry.FileName;
        Item.Signature := UnescapeField(Fields[5]);
        Entry.Symbols.Add(Item);
      end;
    end;
    Result := True;
  finally
    Fields.Free;
    Input.Free;
  end;
end;

function TMNoteProjectSymbolIndex.FindDefinition(
  const AName: string): TMNoteCompletionItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FFiles.Count - 1 do
  begin
    Result := TMNoteIndexedFile(FFiles[I]).Symbols.FindByInsertText(AName);
    if Result <> nil then Exit;
  end;
end;

procedure TMNoteProjectSymbolIndex.ListSymbols(AItems: TMNoteCompletionItems;
  AMaxItems: Integer);
var
  I, J: Integer;
begin
  if AItems = nil then Exit;
  if AMaxItems < 1 then AMaxItems := 100;
  for I := 0 to FFiles.Count - 1 do
    for J := 0 to TMNoteIndexedFile(FFiles[I]).Symbols.Count - 1 do
    begin
      AItems.Add(TMNoteIndexedFile(FFiles[I]).Symbols[J].Clone);
      if AItems.Count >= AMaxItems then Exit;
    end;
end;

function TMNoteProjectSymbolIndex.Supports(
  AContext: TMNoteCompletionContext): Boolean;
begin
  Result := (AContext <> nil) and SameText(AContext.LanguageID, 'pascal');
end;

procedure TMNoteProjectSymbolIndex.Collect(AContext: TMNoteCompletionContext;
  AItems: TMNoteCompletionItems);
var
  I, J: Integer;
begin
  for I := 0 to FFiles.Count - 1 do
    for J := 0 to TMNoteIndexedFile(FFiles[I]).Symbols.Count - 1 do
      AItems.Add(TMNoteIndexedFile(FFiles[I]).Symbols[J].Clone);
end;

function TMNoteProjectSymbolIndex.ResolveDocumentation(
  AItem: TMNoteCompletionItem): string;
begin
  if AItem = nil then Exit('');
  Result := AItem.Signature;
end;

function MNoteProjectSymbols: TMNoteProjectSymbolIndex;
begin
  if GProjectSymbols = nil then
  begin
    GProjectSymbols := TMNoteProjectSymbolIndex.Create;
    GProjectSymbolsReference := GProjectSymbols;
  end;
  Result := GProjectSymbols;
end;

finalization
  GProjectSymbols := nil;
  GProjectSymbolsReference := nil;

end.
