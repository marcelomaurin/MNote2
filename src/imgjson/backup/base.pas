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

    procedure UpsertFile(const ParentId: Integer; const FileName, FullPath: string);
    function EnsureDirUnderParent(const ParentId: Integer; const DirName: string; MTime: Int64): Integer;
    function EnsureRootId: Integer;
    function GetParam(const AKey: string): string;
    procedure DeleteFS();

  end;

var
  dmBase: TdmBase;

implementation

{$R *.lfm}

{ TdmBase }

uses setmain, mquery2;

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
  zconlocal.close;
  zconlocal.sql.text := 'delete from fs ';
  zconlocal.execute;

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


end.

