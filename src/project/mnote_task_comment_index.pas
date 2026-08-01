unit mnote_task_comment_index;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, StrUtils, Contnrs;

type
  TMNoteTaskComment = class
  public
    Token: string;
    Description: string;
    FileName: string;
    Line: Integer;
  end;

  TMNoteTaskCommentIndex = class
  private
    FItems: TObjectList;
    FTokens: TStringList;
    function GetCount: Integer;
    function GetItem(AIndex: Integer): TMNoteTaskComment;
    procedure ScanFolder(const AFolder: string);
    procedure ScanFile(const AFileName: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Scan(const ARoot: string);
    property Tokens: TStringList read FTokens;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TMNoteTaskComment read GetItem; default;
  end;

implementation

constructor TMNoteTaskCommentIndex.Create;
begin
  inherited Create;
  FItems := TObjectList.Create(True);
  FTokens := TStringList.Create;
  FTokens.CaseSensitive := False;
  FTokens.AddStrings(['TODO', 'FIXME', 'HACK', 'NOTE']);
end;

destructor TMNoteTaskCommentIndex.Destroy;
begin
  FTokens.Free;
  FItems.Free;
  inherited Destroy;
end;

function TMNoteTaskCommentIndex.GetCount: Integer;
begin Result := FItems.Count; end;
function TMNoteTaskCommentIndex.GetItem(AIndex: Integer): TMNoteTaskComment;
begin Result := TMNoteTaskComment(FItems[AIndex]); end;

procedure TMNoteTaskCommentIndex.Scan(const ARoot: string);
begin
  FItems.Clear;
  if DirectoryExists(ARoot) then ScanFolder(ExpandFileName(ARoot));
end;

function IsSourceFile(const AFileName: string): Boolean;
const
  Extensions = '.pas;.pp;.lpr;.inc;.py;.js;.ts;.sql;.html;.css;.md;.txt;.sh;.ps1;.json;.xml;.yml;.yaml;';
begin
  Result := Pos(LowerCase(ExtractFileExt(AFileName)) + ';', Extensions) > 0;
end;

procedure TMNoteTaskCommentIndex.ScanFolder(const AFolder: string);
var
  Search: TSearchRec;
  FullName: string;
begin
  if FindFirst(IncludeTrailingPathDelimiter(AFolder) + '*', faAnyFile,
    Search) <> 0 then Exit;
  try
    repeat
      if (Search.Name = '.') or (Search.Name = '..') then Continue;
      FullName := IncludeTrailingPathDelimiter(AFolder) + Search.Name;
      if (Search.Attr and faDirectory) <> 0 then
      begin
        if SameText(Search.Name, '.git') or SameText(Search.Name, '.mnote') or
          SameText(Search.Name, 'backup') or SameText(Search.Name, 'lib') then Continue;
        ScanFolder(FullName);
      end
      else if IsSourceFile(FullName) and (Search.Size <= 2 * 1024 * 1024) then
        ScanFile(FullName);
    until FindNext(Search) <> 0;
  finally
    FindClose(Search);
  end;
end;

procedure TMNoteTaskCommentIndex.ScanFile(const AFileName: string);
var
  Lines: TStringList;
  I, TokenIndex, P: Integer;
  Entry: TMNoteTaskComment;
  UpperLine, Marker: string;
begin
  Lines := TStringList.Create;
  try
    try Lines.LoadFromFile(AFileName); except Exit; end;
    if Pos(#0, Lines.Text) > 0 then Exit;
    for I := 0 to Lines.Count - 1 do
    begin
      UpperLine := UpperCase(Lines[I]);
      for TokenIndex := 0 to FTokens.Count - 1 do
      begin
        Marker := UpperCase(FTokens[TokenIndex]);
        P := Pos(Marker, UpperLine);
        if (P > 0) and ((P = 1) or not (UpperLine[P - 1] in ['A'..'Z', '0'..'9', '_'])) and
          ((P + Length(Marker) > Length(UpperLine)) or
           not (UpperLine[P + Length(Marker)] in ['A'..'Z', '0'..'9', '_'])) then
        begin
          Entry := TMNoteTaskComment.Create;
          Entry.Token := FTokens[TokenIndex];
          Entry.Description := Trim(Copy(Lines[I], P + Length(Marker), MaxInt));
          while (Entry.Description <> '') and
            (Entry.Description[1] in [':', '-', ' ']) do Delete(Entry.Description, 1, 1);
          Entry.FileName := AFileName;
          Entry.Line := I + 1;
          FItems.Add(Entry);
          Break;
        end;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

end.
