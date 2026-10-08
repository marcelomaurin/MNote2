unit mnote_db_diagram_model;
{$mode objfpc}{$H+}{$codepage utf8}
interface
uses Classes, SysUtils, Contnrs, md5;
type
  TDiagramContext = record
    Profile, Protocol, Host, DatabaseName, SchemaName, UserName: string;
    Port: Integer;
  end;
  TDiagramColumn = class
    Name, DataType: string;
    Nullable, ForeignKey: Boolean;
    PrimaryPosition: Integer;
  end;
  TDiagramTable = class
    Catalog, SchemaName, Name: string;
    Columns: TObjectList;
    X, Y: Integer;
    constructor Create;
    destructor Destroy; override;
    function Key: string;
    function Caption: string;
    function ColumnIndex(const AName: string): Integer;
  end;
  TDiagramPair = class
    SourceColumn, TargetColumn: string;
    Position: Integer;
  end;
  TDiagramRelation = class
    Name, SourceKey, TargetKey: string;
    Pairs: TObjectList;
    constructor Create;
    destructor Destroy; override;
    procedure AddPair(const ASource, ATarget: string; APosition: Integer);
  end;
  TDiagramModel = class
    Context: TDiagramContext;
    Tables, Relations: TObjectList;
    Warnings: TStringList;
    FilterText, FocusKey: string;
    constructor Create;
    destructor Destroy; override;
    function FindTable(const AKey: string): TDiagramTable;
    function Relation(const AName, ASource, ATarget: string): TDiagramRelation;
    procedure Arrange;
    procedure FocusTable(const AName: string);
    function MatchesView(T: TDiagramTable): Boolean;
    procedure PreserveView(Old: TDiagramModel);
  end;
function DiagramObjectKey(const ACatalog, ASchema, AName: string): string;
function DiagramContextKey(const AContext: TDiagramContext): string;
implementation
function Part(const S: string): string;
begin Result := IntToStr(Length(S)) + ':' + S; end;
function DiagramObjectKey(const ACatalog, ASchema, AName: string): string;
begin Result := Part(ACatalog) + Part(ASchema) + Part(AName); end;
function DiagramContextKey(const AContext: TDiagramContext): string;
var D: string;
begin
  D := AContext.DatabaseName;
  if Pos('sqlite', LowerCase(AContext.Protocol)) > 0 then
    if (D <> '') and (D <> ':memory:') then D := ExpandFileName(D);
  Result := MD5Print(MD5String(Part(AContext.Profile) +
    Part(LowerCase(AContext.Protocol)) + Part(LowerCase(AContext.Host)) +
    Part(IntToStr(AContext.Port)) + Part(D) + Part(AContext.SchemaName) +
    Part(AContext.UserName)));
end;
constructor TDiagramTable.Create;
begin inherited Create; Columns := TObjectList.Create(True); end;
destructor TDiagramTable.Destroy;
begin Columns.Free; inherited Destroy; end;
function TDiagramTable.Key: string;
begin Result := DiagramObjectKey(Catalog, SchemaName, Name); end;
function TDiagramTable.Caption: string;
begin
  Result := Name;
  if SchemaName <> '' then Result := SchemaName + '.' + Result;
end;
function TDiagramTable.ColumnIndex(const AName: string): Integer;
var I: Integer;
begin
  for I := 0 to Columns.Count - 1 do
    if TDiagramColumn(Columns[I]).Name = AName then Exit(I);
  Result := -1;
end;
constructor TDiagramRelation.Create;
begin inherited Create; Pairs := TObjectList.Create(True); end;
destructor TDiagramRelation.Destroy;
begin Pairs.Free; inherited Destroy; end;
procedure TDiagramRelation.AddPair(const ASource, ATarget: string; APosition: Integer);
var P: TDiagramPair; I: Integer;
begin
  P := TDiagramPair.Create; P.SourceColumn := ASource;
  P.TargetColumn := ATarget; P.Position := APosition;
  I := 0;
  while (I < Pairs.Count) and (TDiagramPair(Pairs[I]).Position < APosition) do Inc(I);
  Pairs.Insert(I, P);
end;
constructor TDiagramModel.Create;
begin
  inherited Create; Tables := TObjectList.Create(True);
  Relations := TObjectList.Create(True); Warnings := TStringList.Create;
end;
destructor TDiagramModel.Destroy;
begin Warnings.Free; Relations.Free; Tables.Free; inherited Destroy; end;
function TDiagramModel.FindTable(const AKey: string): TDiagramTable;
var I: Integer;
begin
  for I := 0 to Tables.Count - 1 do
    if TDiagramTable(Tables[I]).Key = AKey then Exit(TDiagramTable(Tables[I]));
  Result := nil;
end;
function TDiagramModel.Relation(const AName, ASource, ATarget: string): TDiagramRelation;
var I: Integer;
begin
  for I := 0 to Relations.Count - 1 do begin
    Result := TDiagramRelation(Relations[I]);
    if (Result.Name = AName) and (Result.SourceKey = ASource) and
      (Result.TargetKey = ATarget) then Exit;
  end;
  Result := TDiagramRelation.Create; Result.Name := AName;
  Result.SourceKey := ASource; Result.TargetKey := ATarget; Relations.Add(Result);
end;
procedure TDiagramModel.FocusTable(const AName: string);
var I, Count: Integer; T: TDiagramTable; NewKey: string;
begin
  if AName = '' then begin FocusKey := ''; Exit; end;
  Count := 0; NewKey := '';
  for I := 0 to Tables.Count - 1 do begin
    T := TDiagramTable(Tables[I]);
    if (T.Key = AName) or (T.Caption = AName) or (T.Name = AName) then begin
      NewKey := T.Key; Inc(Count);
    end;
  end;
  if Count <> 1 then raise Exception.Create('Tabela ausente ou ambígua no diagrama: ' + AName);
  FocusKey := NewKey; FilterText := '';
end;
function TDiagramModel.MatchesView(T: TDiagramTable): Boolean;
var I: Integer; R: TDiagramRelation;
begin
  Result := False;
  if (FilterText <> '') and (Pos(LowerCase(FilterText), LowerCase(T.Caption)) = 0) then Exit;
  if (FocusKey = '') or (T.Key = FocusKey) then Exit(True);
  for I := 0 to Relations.Count - 1 do begin
    R := TDiagramRelation(Relations[I]);
    if ((R.SourceKey = FocusKey) and (R.TargetKey = T.Key)) or
      ((R.TargetKey = FocusKey) and (R.SourceKey = T.Key)) then Exit(True);
  end;
end;
procedure TDiagramModel.PreserveView(Old: TDiagramModel);
var I, NextY: Integer; T, Previous: TDiagramTable;
begin
  if Old = nil then Exit;
  NextY := 30;
  for I := 0 to Old.Tables.Count - 1 do begin
    Previous := TDiagramTable(Old.Tables[I]);
    if Previous.Y + 100 + Previous.Columns.Count * 20 > NextY then
      NextY := Previous.Y + 100 + Previous.Columns.Count * 20;
  end;
  FilterText := Old.FilterText;
  if FindTable(Old.FocusKey) <> nil then FocusKey := Old.FocusKey;
  for I := 0 to Tables.Count - 1 do begin
    T := TDiagramTable(Tables[I]); Previous := Old.FindTable(T.Key);
    if Previous <> nil then begin T.X := Previous.X; T.Y := Previous.Y; end
    else begin T.X := 30; T.Y := NextY; Inc(NextY, 100 + T.Columns.Count * 20); end;
  end;
end;
procedure TDiagramModel.Arrange;
var I, J, Index, RowY, RowHeight, ColumnsPerRow: Integer;
  T, Neighbour: TDiagramTable; R: TDiagramRelation; Ordered: TList; Seen: TStringList;
  procedure Add(Table: TDiagramTable);
  begin
    if (Table = nil) or (Seen.IndexOf(Table.Key) >= 0) then Exit;
    Seen.Add(Table.Key); Ordered.Add(Table);
  end;
begin
  Ordered := TList.Create; Seen := TStringList.Create;
  try
    Seen.Sorted := True; Seen.CaseSensitive := True;
    for I := 0 to Tables.Count - 1 do begin
      Index := Ordered.Count; Add(TDiagramTable(Tables[I]));
      while Index < Ordered.Count do begin
        T := TDiagramTable(Ordered[Index]);
        for J := 0 to Relations.Count - 1 do begin
          R := TDiagramRelation(Relations[J]); Neighbour := nil;
          if R.SourceKey = T.Key then Neighbour := FindTable(R.TargetKey)
          else if R.TargetKey = T.Key then Neighbour := FindTable(R.SourceKey);
          Add(Neighbour);
        end;
        Inc(Index);
      end;
    end;
    ColumnsPerRow := 3;
    if Tables.Count > 30 then ColumnsPerRow := 6;
    RowY := 30; RowHeight := 0;
    for I := 0 to Ordered.Count - 1 do begin
      if (I > 0) and (I mod ColumnsPerRow = 0) then begin
        Inc(RowY, RowHeight + 70); RowHeight := 0;
      end;
      T := TDiagramTable(Ordered[I]); T.X := 30 + (I mod ColumnsPerRow) * 340; T.Y := RowY;
      if 34 + T.Columns.Count * 20 > RowHeight then RowHeight := 34 + T.Columns.Count * 20;
    end;
  finally Seen.Free; Ordered.Free; end;
end;
end.
