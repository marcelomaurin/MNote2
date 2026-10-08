unit mnote_db_diagram_reader;
{$mode objfpc}{$H+}{$codepage utf8}
interface
uses Classes, SysUtils, ZConnection, ZDataset, ZDbcIntfs,
  mnote_db_diagram_model;
type
  EDiagramCancelled = class(Exception);
  TDiagramProgressEvent = procedure(const Stage: string; Position, Total: Integer;
    var Cancelled: Boolean) of object;
function DiagramConnectionContext(C: TZConnection; const ASchema: string): TDiagramContext;
function ReadDatabaseDiagram(C: TZConnection; const Context: TDiagramContext;
  AProgress: TDiagramProgressEvent = nil): TDiagramModel;
implementation
procedure ReportDiagramProgress(AProgress: TDiagramProgressEvent; const Stage: string; Position, Total: Integer);
var Cancelled: Boolean;
begin
  if not Assigned(AProgress) then Exit;
  Cancelled := False; AProgress(Stage, Position, Total, Cancelled);
  if Cancelled then raise EDiagramCancelled.Create('Leitura cancelada.');
end;
function DiagramConnectionContext(C: TZConnection; const ASchema: string): TDiagramContext;
begin
  Result.Profile := C.Name; Result.Protocol := C.Protocol;
  Result.Host := C.HostName; Result.Port := C.Port;
  Result.DatabaseName := C.Database; Result.SchemaName := ASchema;
  Result.UserName := C.User;
end;
procedure ReadSQLite(C: TZConnection; M: TDiagramModel; AProgress: TDiagramProgressEvent);
var Q: TZQuery; I, J, N: Integer; T, Target: TDiagramTable;
  Col: TDiagramColumn; R: TDiagramRelation; P: TDiagramPair;
begin
  Q := TZQuery.Create(nil);
  try
    Q.Connection := C;
    Q.SQL.Text := 'SELECT name FROM main.sqlite_master WHERE type=''table'' '+
      'AND name NOT LIKE ''sqlite_%'' ORDER BY name'; Q.Open;
    while not Q.EOF do begin
      ReportDiagramProgress(AProgress, 'Listando tabelas', 0, 0);
      T := TDiagramTable.Create; T.Name := Q.Fields[0].AsString;
      T.SchemaName := 'main'; M.Tables.Add(T); Q.Next;
    end;
    Q.Close;
    for I := 0 to M.Tables.Count - 1 do begin
      T := TDiagramTable(M.Tables[I]);
      ReportDiagramProgress(AProgress, T.Caption, I, M.Tables.Count);
      Q.SQL.Text := 'PRAGMA main.table_info(' + QuotedStr(T.Name) + ')'; Q.Open;
      while not Q.EOF do begin
        ReportDiagramProgress(AProgress, T.Caption, I, M.Tables.Count);
        Col := TDiagramColumn.Create; Col.Name := Q.FieldByName('name').AsString;
        Col.DataType := Q.FieldByName('type').AsString;
        Col.Nullable := Q.FieldByName('notnull').AsInteger = 0;
        Col.PrimaryPosition := Q.FieldByName('pk').AsInteger;
        T.Columns.Add(Col); Q.Next;
      end;
      Q.Close;
      Q.SQL.Text := 'PRAGMA main.foreign_key_list(' + QuotedStr(T.Name) + ')'; Q.Open;
      while not Q.EOF do begin
        ReportDiagramProgress(AProgress, T.Caption, I, M.Tables.Count);
        R := M.Relation('fk_' + Q.FieldByName('id').AsString, T.Key,
          DiagramObjectKey('', 'main', Q.FieldByName('table').AsString));
        R.AddPair(Q.FieldByName('from').AsString, Q.FieldByName('to').AsString,
          Q.FieldByName('seq').AsInteger + 1);
        N := T.ColumnIndex(Q.FieldByName('from').AsString);
        if N >= 0 then TDiagramColumn(T.Columns[N]).ForeignKey := True;
        Q.Next;
      end;
      Q.Close;
    end;
    for I := 0 to M.Relations.Count - 1 do begin
      R := TDiagramRelation(M.Relations[I]); Target := M.FindTable(R.TargetKey);
      if Target = nil then
        for N := 0 to M.Tables.Count - 1 do
          if SameText(TDiagramTable(M.Tables[N]).Key, R.TargetKey) then begin
            Target := TDiagramTable(M.Tables[N]); R.TargetKey := Target.Key; Break;
          end;
      if Target = nil then Continue;
      for J := 0 to R.Pairs.Count - 1 do begin
        P := TDiagramPair(R.Pairs[J]);
        if P.TargetColumn <> '' then begin
          for N := 0 to Target.Columns.Count - 1 do
            if SameText(TDiagramColumn(Target.Columns[N]).Name, P.TargetColumn) then
              P.TargetColumn := TDiagramColumn(Target.Columns[N]).Name;
          Continue;
        end;
        for N := 0 to Target.Columns.Count - 1 do
          if TDiagramColumn(Target.Columns[N]).PrimaryPosition = P.Position then
            P.TargetColumn := TDiagramColumn(Target.Columns[N]).Name;
      end;
    end;
  finally Q.Free; end;
end;
procedure ReadZeos(C: TZConnection; M: TDiagramModel; AProgress: TDiagramProgressEvent);
var Meta: IZDatabaseMetadata; Rows: IZResultSet; T: TDiagramTable;
  Col: TDiagramColumn; R: TDiagramRelation;
  I, N: Integer; Catalog, Schema, Protocol, FKName: string;
begin
  Meta := C.DbcConnection.GetMetadata;
  Meta.ClearCache;
  Protocol := LowerCase(C.Protocol); Catalog := ''; Schema := M.Context.SchemaName;
  if (Pos('mysql', Protocol) > 0) or (Pos('mariadb', Protocol) > 0) or
    (Pos('mssql', Protocol) > 0) then Catalog := C.Database;
  if (Pos('oracle', Protocol) > 0) and (Schema = '') then Schema := C.User;
  Rows := Meta.GetTables(Catalog, Schema, '%', ['TABLE']);
  while Rows.Next do begin
    ReportDiagramProgress(AProgress, 'Listando tabelas', 0, 0);
    if (Schema <> '') and (Rows.GetStringByName('TABLE_SCHEM') <> Schema) then Continue;
    T := TDiagramTable.Create;
    T.Catalog := Rows.GetStringByName('TABLE_CAT');
    T.SchemaName := Rows.GetStringByName('TABLE_SCHEM');
    T.Name := Rows.GetStringByName('TABLE_NAME'); M.Tables.Add(T);
  end;
  Rows.Close; Rows := nil;
  for I := 0 to M.Tables.Count - 1 do begin
    T := TDiagramTable(M.Tables[I]);
    ReportDiagramProgress(AProgress, T.Caption, I, M.Tables.Count);
    Rows := Meta.GetColumns(T.Catalog, T.SchemaName, T.Name, '%');
    while Rows.Next do begin
      ReportDiagramProgress(AProgress, T.Caption, I, M.Tables.Count);
      // Metadata parameters are patterns: names containing '_' must not mix tables.
      if (Rows.GetStringByName('TABLE_NAME') <> T.Name) or
        (Rows.GetStringByName('TABLE_SCHEM') <> T.SchemaName) or
        (Rows.GetStringByName('TABLE_CAT') <> T.Catalog) then Continue;
      Col := TDiagramColumn.Create;
      Col.Name := Rows.GetStringByName('COLUMN_NAME');
      Col.DataType := Rows.GetStringByName('TYPE_NAME');
      Col.Nullable := Rows.GetIntByName('NULLABLE') <> 0;
      T.Columns.Add(Col);
    end;
    Rows.Close;
    Rows := Meta.GetPrimaryKeys(T.Catalog, T.SchemaName, T.Name);
    while Rows.Next do begin
      ReportDiagramProgress(AProgress, T.Caption, I, M.Tables.Count);
      N := T.ColumnIndex(Rows.GetStringByName('COLUMN_NAME'));
      if N >= 0 then TDiagramColumn(T.Columns[N]).PrimaryPosition := Rows.GetIntByName('KEY_SEQ');
    end;
    Rows.Close;
    Rows := Meta.GetImportedKeys(T.Catalog, T.SchemaName, T.Name);
    while Rows.Next do begin
      ReportDiagramProgress(AProgress, T.Caption, I, M.Tables.Count);
      FKName := Rows.GetStringByName('FK_NAME');
      if FKName = '' then begin
        M.Warnings.Add(T.Caption + ': FK sem identificador; ligação omitida para evitar agrupamento incorreto.');
        Continue;
      end;
      R := M.Relation(FKName, T.Key, DiagramObjectKey(
        Rows.GetStringByName('PKTABLE_CAT'), Rows.GetStringByName('PKTABLE_SCHEM'),
        Rows.GetStringByName('PKTABLE_NAME')));
      R.AddPair(Rows.GetStringByName('FKCOLUMN_NAME'),
        Rows.GetStringByName('PKCOLUMN_NAME'), Rows.GetIntByName('KEY_SEQ'));
      N := T.ColumnIndex(Rows.GetStringByName('FKCOLUMN_NAME'));
      if N >= 0 then TDiagramColumn(T.Columns[N]).ForeignKey := True;
    end;
    Rows.Close; Rows := nil;
  end;
end;
function ReadDatabaseDiagram(C: TZConnection; const Context: TDiagramContext;
  AProgress: TDiagramProgressEvent): TDiagramModel;
var I: Integer; R: TDiagramRelation;
begin
  if (C = nil) or not C.Connected then
    raise Exception.Create('Conecte o banco desta pasta antes de abrir o diagrama.');
  if DiagramContextKey(DiagramConnectionContext(C, Context.SchemaName)) <> DiagramContextKey(Context) then
    raise Exception.Create('A conexão mudou. Abra o diagrama novamente pela pasta do banco.');
  ReportDiagramProgress(AProgress, 'Listando tabelas', 0, 0);
  Result := TDiagramModel.Create;
  try
    Result.Context := Context;
    if Pos('sqlite', LowerCase(C.Protocol)) > 0 then ReadSQLite(C, Result, AProgress)
    else ReadZeos(C, Result, AProgress);
    for I := 0 to Result.Relations.Count - 1 do begin
      R := TDiagramRelation(Result.Relations[I]);
      if Result.FindTable(R.TargetKey) = nil then
        Result.Warnings.Add(R.Name + ': tabela de destino fora do escopo; ligação não desenhada.');
    end;
    ReportDiagramProgress(AProgress, 'Organizando diagrama', Result.Tables.Count, Result.Tables.Count);
    Result.Arrange;
  except Result.Free; raise; end;
end;
end.
