unit mnote_search_types;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs;

type
  TMNoteSearchScope = (ssCurrentDocument, ssSelection, ssOpenDocuments,
    ssProject, ssFolder);

  TMNoteSearchOptions = record
    Scope: TMNoteSearchScope;
    MatchCase: Boolean;
    WholeWord: Boolean;
    RegularExpression: Boolean;
    WrapAround: Boolean;
    IncludePatterns: string;
    ExcludePatterns: string;
    WordCharacters: string;
  end;

  { TMNoteSearchResult }

  TMNoteSearchResult = class
  private
    FFileName: string;
    FLine: Integer;
    FColumn: Integer;
    FLength: Integer;
    FPreview: string;
    FMatchedText: string;
    FAbsoluteIndex: Int64;
  public
    constructor Create(const AFileName: string; ALine, AColumn,
      ALength: Integer; const APreview, AMatchedText: string;
      AAbsoluteIndex: Int64 = -1);
    property FileName: string read FFileName;
    property Line: Integer read FLine;
    property Column: Integer read FColumn;
    property Length: Integer read FLength;
    property Preview: string read FPreview;
    property MatchedText: string read FMatchedText;
    property AbsoluteIndex: Int64 read FAbsoluteIndex;
  end;

  { TMNoteSearchResults }

  TMNoteSearchResults = class
  private
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItem(AIndex: Integer): TMNoteSearchResult;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(AResult: TMNoteSearchResult): Integer;
    procedure Clear;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TMNoteSearchResult read GetItem; default;
  end;

  { TMNoteSearchDocument }

  TMNoteSearchDocument = class
  private
    FFileName: string;
    FText: string;
  public
    constructor Create(const AFileName, AText: string);
    property FileName: string read FFileName;
    property Text: string read FText;
  end;

  { TMNoteSearchDocuments }

  TMNoteSearchDocuments = class
  private
    FItems: TObjectList;
    function GetCount: Integer;
    function GetItem(AIndex: Integer): TMNoteSearchDocument;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(ADocument: TMNoteSearchDocument): Integer;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TMNoteSearchDocument read GetItem; default;
  end;

function DefaultSearchOptions: TMNoteSearchOptions;

implementation

function DefaultSearchOptions: TMNoteSearchOptions;
begin
  Result.Scope := ssCurrentDocument;
  Result.MatchCase := False;
  Result.WholeWord := False;
  Result.RegularExpression := False;
  Result.WrapAround := True;
  Result.IncludePatterns := '*.*';
  Result.ExcludePatterns := '!lib/**;!backup/**;!.git/**';
  Result.WordCharacters := '_';
end;

constructor TMNoteSearchResult.Create(const AFileName: string; ALine,
  AColumn, ALength: Integer; const APreview, AMatchedText: string;
  AAbsoluteIndex: Int64);
begin
  inherited Create;
  FFileName := AFileName;
  FLine := ALine;
  FColumn := AColumn;
  FLength := ALength;
  FPreview := APreview;
  FMatchedText := AMatchedText;
  FAbsoluteIndex := AAbsoluteIndex;
end;

constructor TMNoteSearchResults.Create;
begin
  inherited Create;
  FItems := TObjectList.Create(True);
end;

destructor TMNoteSearchResults.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMNoteSearchResults.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TMNoteSearchResults.GetItem(AIndex: Integer): TMNoteSearchResult;
begin
  Result := TMNoteSearchResult(FItems[AIndex]);
end;

function TMNoteSearchResults.Add(AResult: TMNoteSearchResult): Integer;
begin
  if AResult = nil then
    raise Exception.Create('O resultado de pesquisa não pode ser nulo.');
  Result := FItems.Add(AResult);
end;

procedure TMNoteSearchResults.Clear;
begin
  FItems.Clear;
end;

constructor TMNoteSearchDocument.Create(const AFileName, AText: string);
begin
  inherited Create;
  FFileName := AFileName;
  FText := AText;
end;

constructor TMNoteSearchDocuments.Create;
begin
  inherited Create;
  FItems := TObjectList.Create(True);
end;

destructor TMNoteSearchDocuments.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMNoteSearchDocuments.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TMNoteSearchDocuments.GetItem(AIndex: Integer): TMNoteSearchDocument;
begin
  Result := TMNoteSearchDocument(FItems[AIndex]);
end;

function TMNoteSearchDocuments.Add(ADocument: TMNoteSearchDocument): Integer;
begin
  if ADocument = nil then
    raise Exception.Create('O documento de pesquisa não pode ser nulo.');
  Result := FItems.Add(ADocument);
end;

end.
