unit base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, DB, DateUtils,LazFileUtils ;

type

  { TdmBase }

  TdmBase = class(TDataModule)
    DataSource1: TDataSource;
    qryauxlocal: TZQuery;
    zconlocal: TZConnection;
    zqryaux: TZQuery;
    zqryaux1: TZQuery;
    zqryaux2: TZQuery;
  private
     function FileMTimeUTC_OrNow(const FullPath: string): Int64;
     function NormExt(const FN: string): string;
  public
    procedure Connect( Username : string; Password : string; hostname: string; Database: string);
    procedure loadlib(path : string);
    procedure Close();
    function ConectaSQLite(const ArquivoDB: string; biblioteca : string): Boolean;
    function SalvarDadosMaster(projeto : string; Proposito: string; target: string; database: integer): boolean;
    procedure RegistraParam(Chave: string; Valor :string);
    procedure RegistraRefTabelaFS(const IdFS: Integer; const Database, Tabela, Tipo, Contexto: string);

    procedure UpsertFile(const ParentId: Integer; const FileName, FullPath: string);
    function EnsureDirUnderParent(const ParentId: Integer; const DirName: string; MTime: Int64): Integer;
    function EnsureRootId: Integer;
    function GetParam(const AKey: string): string;
    procedure DeleteFS();
    procedure DeleteTabelas();
    procedure RegistraTabela(tabela, database, script: string);
    function Buscafs_IDpeloDiretorio(const Caminho: string): Integer;
    function Buscafs_IDpeloNome( iddir : integer; Nome: string): Integer;
    procedure AtualizarResumo(id : integer; Resumo: string);
    function EnsureTabela(const ADatabase, ATabela, AScriptIfNew: string): Integer;
    procedure VinculaFsATabela(const AFsId, ATabelaId: Integer);


  end;

var
  dmBase: TdmBase;

implementation

{$R *.lfm}

{ TdmBase }

uses setmain, mquery2;

function TdmBase.EnsureTabela(const ADatabase, ATabela, AScriptIfNew: string): Integer;
var
  scr: string;
begin
  Result := 0;
  if (zconlocal = nil) or (not zconlocal.Connected) or (Trim(ATabela)='') then Exit;

  // tenta pegar id existente
  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text :=
    'SELECT id FROM tabelas WHERE "database" = :db AND tabela = :tb LIMIT 1';
  qryauxlocal.ParamByName('db').AsString := ADatabase;
  qryauxlocal.ParamByName('tb').AsString := ATabela;
  qryauxlocal.Open;
  try
    if not qryauxlocal.EOF then
    begin
      Result := qryauxlocal.FieldByName('id').AsInteger;
      Exit;
    end;
  finally
    qryauxlocal.Close;
  end;

  // não existe → inserir (script é NOT NULL, garante algo)
  scr := Trim(AScriptIfNew);
  if scr = '' then
    scr := '/* DDL não disponível no momento */';

  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text :=
    'INSERT INTO tabelas ("database", tabela, script, criado_em, atualizado_em) '+
    'VALUES (:db, :tb, :sc, datetime(''now''), datetime(''now''))';
  qryauxlocal.ParamByName('db').AsString := ADatabase;
  qryauxlocal.ParamByName('tb').AsString := ATabela;
  qryauxlocal.ParamByName('sc').AsString := scr;
  qryauxlocal.ExecSQL;

  // retorna id
  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text :=
    'SELECT id FROM tabelas WHERE "database" = :db AND tabela = :tb LIMIT 1';
  qryauxlocal.ParamByName('db').AsString := ADatabase;
  qryauxlocal.ParamByName('tb').AsString := ATabela;
  qryauxlocal.Open;
  try
    if not qryauxlocal.EOF then
      Result := qryauxlocal.FieldByName('id').AsInteger;
  finally
    qryauxlocal.Close;
  end;
end;

procedure TdmBase.VinculaFsATabela(const AFsId, ATabelaId: Integer);
begin
  if (zconlocal = nil) or (not zconlocal.Connected) then Exit;
  if (AFsId <= 0) or (ATabelaId <= 0) then Exit;

  // INSERT OR IGNORE para respeitar UNIQUE(fs_id, tabela_id)
  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text :=
    'INSERT OR IGNORE INTO fs_tabelas (fs_id, tabela_id, criado_em, atualizado_em) '+
    'VALUES (:fs, :tb, datetime(''now''), datetime(''now''))';
  qryauxlocal.ParamByName('fs').AsInteger := AFsId;
  qryauxlocal.ParamByName('tb').AsInteger := ATabelaId;
  qryauxlocal.ExecSQL;

  // Sempre atualiza o atualizado_em
  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text :=
    'UPDATE fs_tabelas SET atualizado_em = datetime(''now'') '+
    'WHERE fs_id = :fs AND tabela_id = :tb';
  qryauxlocal.ParamByName('fs').AsInteger := AFsId;
  qryauxlocal.ParamByName('tb').AsInteger := ATabelaId;
  qryauxlocal.ExecSQL;
end;


procedure EnsureRefTableExists;
begin
  with dmBase.qryauxlocal do
  begin
    Close;
    SQL.Clear;
    // Tabela simples para vincular um arquivo (fs) às tabelas referenciadas
    SQL.Text :=
      'CREATE TABLE IF NOT EXISTS fs_ref_tabela ('+
      '  id INTEGER PRIMARY KEY AUTOINCREMENT,'+
      '  id_fs INTEGER NOT NULL,'+
      '  "database" TEXT,'+
      '  tabela TEXT NOT NULL,'+
      '  tipo TEXT,'+                 // CREATE/ALTER/SELECT/INSERT/UPDATE/DELETE/UNKNOWN
      '  contexto TEXT,'+             // trecho breve/linhas do código em que apareceu
      '  criado_em DATETIME DEFAULT (datetime(''now''))'+
      ');';
    ExecSQL;
  end;
end;

procedure TdmBase.RegistraRefTabelaFS(const IdFS: Integer; const Database, Tabela, Tipo, Contexto: string);
begin
  if (zconlocal = nil) or (not zconlocal.Connected) or (IdFS <= 0) or (Trim(Tabela) = '') then Exit;

  EnsureRefTableExists;

  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text :=
    'INSERT INTO fs_ref_tabela (id_fs, "database", tabela, tipo, contexto) '+
    'VALUES (:fs, :db, :tb, :tp, :cx)';
  qryauxlocal.ParamByName('fs').AsInteger := IdFS;
  if Trim(Database) = '' then qryauxlocal.ParamByName('db').Clear
                         else qryauxlocal.ParamByName('db').AsString := Database;
  qryauxlocal.ParamByName('tb').AsString  := Tabela;
  if Trim(Tipo) = '' then qryauxlocal.ParamByName('tp').Clear
                     else qryauxlocal.ParamByName('tp').AsString := Tipo;
  if Trim(Contexto) = '' then qryauxlocal.ParamByName('cx').Clear
                         else qryauxlocal.ParamByName('cx').AsString := Contexto;
  qryauxlocal.ExecSQL;
end;


procedure TdmBase.Connect(Username: string; Password: string; hostname: string;
  Database: string);
begin

  zconlocal.Disconnect;
  zconlocal.User:=  Username;
  zconlocal.Password:= Password;
  zconlocal.HostName:= hostname;
  zconlocal.Database:= Database;
  zconlocal.Connect;

end;

function TdmBase.GetParam(const AKey: string): string;
begin
  Result := '';
  if (zconlocal = nil) or (not zconlocal.Connected) then Exit;

  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text :=
    'SELECT valor FROM params '+
    'WHERE chave = :ch COLLATE NOCASE '+
    'LIMIT 1';
  qryauxlocal.ParamByName('ch').AsString := AKey;
  qryauxlocal.Open;
  try
    if not qryauxlocal.EOF then
      Result := qryauxlocal.FieldByName('valor').AsString;
  finally
    qryauxlocal.Close;
  end;
end;

procedure TdmBase.DeleteFS();
begin
  qryauxlocal.close;
  qryauxlocal.sql.text := 'delete from fs ';
  qryauxlocal.ExecSQL;

end;

procedure TdmBase.DeleteTabelas();
begin
  qryauxlocal.close;
  qryauxlocal.sql.text := 'delete from tabelas ';
  qryauxlocal.ExecSQL;
end;

procedure TdmBase.RegistraTabela(tabela, database, script: string);
begin
  if (zconlocal = nil) or (not zconlocal.Connected) then Exit;

  // Tenta atualizar (caso já exista o par database+tabela)
  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text :=
    'UPDATE tabelas '+
    '   SET script = :scr, atualizado_em = datetime(''now'') '+
    ' WHERE "database" = :db AND tabela = :tab';
  qryauxlocal.ParamByName('scr').AsString := script;
  qryauxlocal.ParamByName('db').AsString  := database;
  qryauxlocal.ParamByName('tab').AsString := tabela;
  qryauxlocal.ExecSQL;

  // Se não atualizou nada, insere
  if qryauxlocal.RowsAffected = 0 then
  begin
    qryauxlocal.Close;
    qryauxlocal.SQL.Clear;
    qryauxlocal.SQL.Text :=
      'INSERT INTO tabelas ("database", tabela, script, criado_em, atualizado_em) '+
      'VALUES (:db, :tab, :scr, datetime(''now''), datetime(''now''))';
    qryauxlocal.ParamByName('db').AsString  := database;
    qryauxlocal.ParamByName('tab').AsString := tabela;
    qryauxlocal.ParamByName('scr').AsString := script;
    qryauxlocal.ExecSQL;
  end;
end;



procedure TdmBase.loadlib(path: string);
begin
  //zcon.LibraryLocation :=path;
end;

procedure TdmBase.Close;
begin
  //zcon.Disconnect;
end;

function TdmBase.ConectaSQLite(const ArquivoDB: string; biblioteca : string): Boolean;
begin
  Result := False;
  try
    if zconlocal.Connected then
      zconlocal.Disconnect;

    zconlocal.Protocol := 'sqlite';
    zconlocal.Database := ArquivoDB;
    zconlocal.User := '';  // SQLite não usa usuário normalmente
    zconlocal.Password := '';
    {$IFDEF WINDOWS}
     zconlocal.LibraryLocation:= biblioteca ;
    {$ENDIF}
    {$IFDEF LINUX}
    zconlocal.LibraryLocation:= ExtractFilePath(ApplicationName)+'libs/sqlite/lin32/sqlite3.so' ;
    {$ENDIF}

    zconlocal.Connect;
    Result := zconlocal.Connected;
  except
    Result := False; // Se der erro, retorna False
  end;
end;

function TdmBase.SalvarDadosMaster(projeto : string; Proposito: string; target: string; database: integer): boolean;
begin
  RegistraParam('PROJETO',projeto);
  RegistraParam('PROPOSITO',proposito);
  RegistraParam('TARGET',target);
  RegistraParam('DATABASETYPE',inttostr(database));
end;

procedure TdmBase.RegistraParam(Chave: string; Valor: string);
var
  Existe: Boolean;
begin
  // Verifica se a chave já existe
  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text := 'select 1 from params where chave = :chave limit 1';
  qryauxlocal.ParamByName('chave').AsString := Chave;
  qryauxlocal.Open;
  Existe := not qryauxlocal.IsEmpty;
  qryauxlocal.Close;

  // Atualiza se existir, senão insere
  qryauxlocal.SQL.Clear;
  if Existe then
    qryauxlocal.SQL.Text := 'update params set valor = :valor where chave = :chave'
  else
    qryauxlocal.SQL.Text := 'insert into params (chave, valor) values (:chave, :valor)';

  qryauxlocal.ParamByName('chave').AsString := Chave;
  qryauxlocal.ParamByName('valor').AsString := Valor;
  qryauxlocal.ExecSQL;
end;


// garante a raiz "/" (diretório, id_pai NULL) e retorna seu id
function TdmBase.EnsureRootId: Integer;

begin
  Result := 0;
  qryauxlocal := qryauxlocal;
  try
    //Q.Connection := dmBase.zconlocal;

    // tenta achar
    qryauxlocal.SQL.Text := 'SELECT id FROM fs WHERE id_pai IS NULL';

    qryauxlocal.Open;
    if not qryauxlocal.EOF then
    begin
      Result := qryauxlocal.Fields[0].AsInteger;
      Exit;
    end;
    qryauxlocal.Close;

    // insere
    qryauxlocal.SQL.Text :=
      'INSERT INTO fs (nome, diretorio, id_pai, tamanho, ext, mtime_utc) '+
      'VALUES (''/'', 1, NULL, NULL, NULL, strftime(''%s'',''now''));';
    qryauxlocal.ExecSQL;

    // retorna id
    qryauxlocal.SQL.Text := 'SELECT id FROM fs WHERE nome = ''/'' AND diretorio=1 AND id_pai IS NULL';
    qryauxlocal.Open;
    if not qryauxlocal.EOF then
      Result := qryauxlocal.Fields[0].AsInteger;
  finally

  end;
end;

// retorna id do diretório (cria se não existir) sob um pai
function TdmBase.EnsureDirUnderParent(const ParentId: Integer; const DirName: string; MTime: Int64): Integer;

begin
  Result := 0;

  try


    // procura
    qryauxlocal.SQL.Text := 'SELECT id FROM fs WHERE id_pai=:p AND nome=:n AND diretorio=1';
    qryauxlocal.ParamByName('p').AsInteger := ParentId;
    qryauxlocal.ParamByName('n').AsString  := DirName;
    qryauxlocal.Open;
    if not qryauxlocal.EOF then
    begin
      Result := qryauxlocal.Fields[0].AsInteger;
      qryauxlocal.Close;

      // atualiza mtime (opcional)
      qryauxlocal.SQL.Text := 'UPDATE fs SET mtime_utc=:m WHERE id=:id';
      qryauxlocal.ParamByName('m').AsLargeInt := MTime;
      qryauxlocal.ParamByName('id').AsInteger := Result;
      qryauxlocal.ExecSQL;
      Exit;
    end;
    qryauxlocal.Close;

    // cria
    qryauxlocal.SQL.Text :=
      'INSERT INTO fs (nome, diretorio, id_pai, tamanho, ext, mtime_utc) '+
      'VALUES (:n, 1, :p, NULL, NULL, :m)';
    qryauxlocal.ParamByName('n').AsString    := DirName;
    qryauxlocal.ParamByName('p').AsInteger   := ParentId;
    qryauxlocal.ParamByName('m').AsLargeInt  := MTime;
    qryauxlocal.ExecSQL;

    // lê id
    qryauxlocal.SQL.Text := 'SELECT id FROM fs WHERE id_pai=:p AND nome=:n AND diretorio=1';
    qryauxlocal.ParamByName('p').AsInteger := ParentId;
    qryauxlocal.ParamByName('n').AsString  := DirName;
    qryauxlocal.Open;
    if not qryauxlocal.EOF then
      Result := qryauxlocal.Fields[0].AsInteger;
  finally
  end;
end;


// converte data de modificação para epoch (segundos)
 function TdmBase.FileMTimeUTC_OrNow(const FullPath: string): Int64;
 var
   dt: TDateTime;
 begin
   // FileAge retorna localtime; usamos DateUtils para converter
   if FileAge(FullPath, dt) then
     Result := DateTimeToUnix(dt)
   else
     Result := DateTimeToUnix(Now);
 end;


// normaliza extensão ('' -> NULL; sempre minúscula e com ponto)
function TdmBase.NormExt(const FN: string): string;
var e: string;
begin
  e := LowerCase(ExtractFileExt(FN));
  if e = '' then Exit('');
  if e[1] <> '.' then Exit('.' + e);
  Result := e;
end;

// upsert de arquivo (não precisamos do id)
procedure TdmBase.UpsertFile(const ParentId: Integer; const FileName, FullPath: string);
var Q: TZQuery;
    mtime: Int64;
    e: string;
    sz: Int64;
    SR: TSearchRec;
begin
  mtime := FileMTimeUTC_OrNow(FullPath);
  e     := NormExt(FileName);

  // tamanho com FindFirst (mais rápido que abrir o arquivo)
  sz := 0;
  if FindFirst(FullPath, faAnyFile, SR) = 0 then
  begin
    sz := SR.Size;
    FindClose(SR);
  end;

  Q := TZQuery.Create(Self);
  try
    Q.Connection := dmBase.zconlocal;

    // UPDATE primeiro
    Q.SQL.Text := 'UPDATE fs SET tamanho=:t, ext=:e, mtime_utc=:m '+
                  'WHERE id_pai=:p AND nome=:n AND diretorio=0';
    Q.ParamByName('t').AsLargeInt  := sz;
    if e = '' then Q.ParamByName('e').Clear else Q.ParamByName('e').AsString := e;
    Q.ParamByName('m').AsLargeInt  := mtime;
    Q.ParamByName('p').AsInteger   := ParentId;
    Q.ParamByName('n').AsString    := FileName;
    Q.ExecSQL;

    if Q.RowsAffected = 0 then
    begin
      // INSERT se não existia
      Q.SQL.Text :=
        'INSERT INTO fs (nome, diretorio, id_pai, tamanho, ext, mtime_utc) '+
        'VALUES (:n, 0, :p, :t, :e, :m)';
      Q.ParamByName('n').AsString    := FileName;
      Q.ParamByName('p').AsInteger   := ParentId;
      Q.ParamByName('t').AsLargeInt  := sz;
      if e = '' then Q.ParamByName('e').Clear else Q.ParamByName('e').AsString := e;
      Q.ParamByName('m').AsLargeInt  := mtime;
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;


function TdmBase.Buscafs_IDpeloDiretorio(const Caminho: string): Integer;
begin
  Result := 0;
  if (zconlocal = nil) or (not zconlocal.Connected) or (Trim(Caminho) = '') then Exit;

  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text :=
    'SELECT id '+
    '  FROM fs '+
    ' WHERE nome = :n  and diretorio = 1 '+
    ' ORDER BY diretorio ASC, id DESC ' + // prefere arquivo (0) antes de diretório (1)
    ' LIMIT 1';
  qryauxlocal.ParamByName('n').AsString := caminho;
  qryauxlocal.Open;
  try
    if not qryauxlocal.EOF then
      Result := qryauxlocal.FieldByName('id').AsInteger;
  finally
    qryauxlocal.Close;
  end;
end;

function TdmBase.Buscafs_IDpeloNome( iddir : integer; Nome: string): Integer;
begin
  Result := 0;
  if (zconlocal = nil) or (not zconlocal.Connected) or (Trim(Nome) = '') then Exit;

  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text :=
    'SELECT id '+
    '  FROM fs '+
    ' WHERE nome = :n  and id_pai = :m '+
    ' LIMIT 1';
  qryauxlocal.ParamByName('n').AsString := Nome;
  qryauxlocal.ParamByName('m').Asinteger := iddir;
  qryauxlocal.Open;
  try
    if not qryauxlocal.EOF then
      Result := qryauxlocal.FieldByName('id').AsInteger;
  finally
    qryauxlocal.Close;
  end;
end;

procedure TdmBase.AtualizarResumo(id: integer; Resumo: string);
begin
  if (zconlocal = nil) or (not zconlocal.Connected) then Exit;

  qryauxlocal.Close;
  qryauxlocal.SQL.Clear;
  qryauxlocal.SQL.Text :=
    'UPDATE fs '+
    '   SET resumo = :res '+
    ' WHERE id = :id';
  qryauxlocal.ParamByName('res').AsString := Resumo;
  qryauxlocal.ParamByName('id').AsInteger := id;
  qryauxlocal.ExecSQL;
end;



end.

