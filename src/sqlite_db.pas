unit sqlite_db;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, sqlite3conn, Variants;

type
  { TSQLiteDb }
  TSQLiteDb = class(TComponent)
  private
    FConn: TSQLite3Connection;
    FTrans: TSQLTransaction;
    FOpen: Boolean;
    procedure CheckOpen;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Ciclo de vida da conexão
    procedure Open(const AFilePath: string);
    procedure Close;

    // Transação
    procedure BeginTx;
    procedure Commit;
    procedure Rollback;

    // Ajustes recomendados
    procedure ApplyPragmas;

    // Execuções simples
    procedure ExecSQL(const SQL: string);
    procedure ExecSQLParams(const SQL: string; const ParamNames: array of string; const ParamValues: array of Variant);

    // Consultas utilitárias
    function QueryScalar(const SQL: string; const ParamNames: array of string; const ParamValues: array of Variant): string;
    function QueryRow(const SQL: string; const ParamNames: array of string; const ParamValues: array of Variant; out Row: TStrings): Boolean;

    // Acesso se precisar integrar algo externo
    property Connection: TSQLite3Connection read FConn;
    property Transaction: TSQLTransaction read FTrans;
    property IsOpen: Boolean read FOpen;
  end;

implementation

{ TSQLiteDb }

constructor TSQLiteDb.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FConn := TSQLite3Connection.Create(nil);
  FTrans := TSQLTransaction.Create(nil);
  FConn.Transaction := FTrans;
  FOpen := False;
end;

destructor TSQLiteDb.Destroy;
begin
  Close;
  FTrans.Free;
  FConn.Free;
  inherited Destroy;
end;

procedure TSQLiteDb.CheckOpen;
begin
  if not FOpen then
    raise Exception.Create('SQLiteDb: conexão não está aberta.');
end;

procedure TSQLiteDb.Open(const AFilePath: string);
begin
  if FOpen then
    Close;
  if Trim(AFilePath) = '' then
    raise Exception.Create('SQLiteDb: caminho do arquivo inválido.');

  FConn.DatabaseName := AFilePath;
  FConn.Connected := True;
  FTrans.Active := True;
  FOpen := True;
end;

procedure TSQLiteDb.Close;
begin
  if not FOpen then Exit;
  try
    if FTrans.Active then
      FTrans.Commit;
  except
    // ignora commit final
  end;
  FTrans.Active := False;
  FConn.Connected := False;
  FOpen := False;
end;

procedure TSQLiteDb.BeginTx;
begin
  CheckOpen;
  if not FTrans.Active then
    FTrans.Active := True;
end;

procedure TSQLiteDb.Commit;
begin
  CheckOpen;
  if FTrans.Active then
    FTrans.Commit;
end;

procedure TSQLiteDb.Rollback;
begin
  CheckOpen;
  if FTrans.Active then
    FTrans.Rollback;
end;

procedure TSQLiteDb.ApplyPragmas;
begin
  CheckOpen;
  ExecSQL('PRAGMA foreign_keys = ON;');
  ExecSQL('PRAGMA journal_mode = WAL;');
  ExecSQL('PRAGMA synchronous = NORMAL;');
  Commit;
end;

procedure TSQLiteDb.ExecSQL(const SQL: string);
var
  Q: TSQLQuery;
begin
  CheckOpen;
  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := FConn;
    Q.Transaction := FTrans;
    Q.SQL.Text := SQL;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TSQLiteDb.ExecSQLParams(const SQL: string; const ParamNames: array of string; const ParamValues: array of Variant);
var
  Q: TSQLQuery;
  i: Integer;
begin
  CheckOpen;
  if Length(ParamNames) <> Length(ParamValues) then
    raise Exception.Create('SQLiteDb: ParamNames e ParamValues com comprimentos diferentes.');

  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := FConn;
    Q.Transaction := FTrans;
    Q.SQL.Text := SQL;
    for i := 0 to High(ParamNames) do
      Q.ParamByName(ParamNames[i]).Value := ParamValues[i];
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TSQLiteDb.QueryScalar(const SQL: string; const ParamNames: array of string; const ParamValues: array of Variant): string;
var
  Q: TSQLQuery;
  i: Integer;
begin
  CheckOpen;
  Result := '';
  if Length(ParamNames) <> Length(ParamValues) then
    raise Exception.Create('SQLiteDb: ParamNames e ParamValues com comprimentos diferentes.');

  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := FConn;
    Q.Transaction := FTrans;
    Q.SQL.Text := SQL;
    for i := 0 to High(ParamNames) do
      Q.ParamByName(ParamNames[i]).Value := ParamValues[i];

    Q.Open;
    try
      if not Q.EOF then
        Result := Q.Fields[0].AsString;
    finally
      Q.Close;
    end;
  finally
    Q.Free;
  end;
end;

function TSQLiteDb.QueryRow(const SQL: string; const ParamNames: array of string; const ParamValues: array of Variant; out Row: TStrings): Boolean;
var
  Q: TSQLQuery;
  i: Integer;
begin
  CheckOpen;
  Result := False;
  FreeAndNil(Row);
  Row := TStringList.Create;

  if Length(ParamNames) <> Length(ParamValues) then
    raise Exception.Create('SQLiteDb: ParamNames e ParamValues com comprimentos diferentes.');

  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := FConn;
    Q.Transaction := FTrans;
    Q.SQL.Text := SQL;
    for i := 0 to High(ParamNames) do
      Q.ParamByName(ParamNames[i]).Value := ParamValues[i];

    Q.Open;
    try
      if not Q.EOF then
      begin
        for i := 0 to Q.Fields.Count - 1 do
          Row.Values[Q.Fields[i].FieldName] := Q.Fields[i].AsString;
        Result := True;
      end;
    finally
      Q.Close;
    end;
  finally
    Q.Free;
  end;
end;

end.

