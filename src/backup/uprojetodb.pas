unit uProjetoDB;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, sqlite_db, base, hint, funcoes, setmain ;

type
  { TProjetoDB }
  TProjetoDB = class(TComponent)
  private
    FNome: string;
    FDBPath: string;
    FDescricao: string;
    FAlvoPath: string;

    FDb: TSQLiteDb;
    FIsOpen: Boolean;

    function TableExists(const ATable: string): Boolean;
    procedure LoadMetaFromProjetoMeta; // lê projeto_meta se existir
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Abre o banco informado (ex.: 'C:\meusprojetos\meubanco.db')
    procedure CarregarProjeto(const ADBPath: string; dll : string);

    // Fecha o banco (se aberto)
    procedure FecharProjeto;

    // Somente leitura
    property IsOpen: Boolean read FIsOpen;
    property Db: TSQLiteDb read FDb;

    // Metadados (se carregados de projeto_meta)
    property Nome: string read FNome;
    property DBPath: string read FDBPath;
    property Descricao: string read FDescricao;
    property AlvoPath: string read FAlvoPath;
  end;

  var
    ProjetoDB : TProjetoDB;

implementation

{ TProjetoDB }

constructor TProjetoDB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDb := TSQLiteDb.Create(Self);
  FIsOpen := False;
  FNome := '';
  FDescricao := '';
  FAlvoPath := '';
  FDBPath := '';
  if (dmBase = nil) then
    dmBase := TdmBase.Create(Self);
end;

destructor TProjetoDB.Destroy;
begin
  FecharProjeto;
  inherited Destroy;
end;

function TProjetoDB.TableExists(const ATable: string): Boolean;
var
  Row: TStrings;
begin
  Result := False;
  if not FIsOpen then Exit;
  if FDb.QueryRow(
       'SELECT name FROM sqlite_master WHERE type = ''table'' AND name = :n LIMIT 1',
       ['n'], [ATable], Row) then
  begin
    Row.Free;
    Result := True;
  end;
end;

procedure TProjetoDB.LoadMetaFromProjetoMeta;

  // --- helpers locais ---
  function TableExistsLocal(const ATable: string): Boolean;
  var
    Row: TStrings;
  begin
    Result := False;
    if not FIsOpen then Exit;
    if FDb.QueryRow(
         'SELECT name FROM sqlite_master '+
         'WHERE type = ''table'' AND name = :n LIMIT 1',
         ['n'], [ATable], Row) then
    begin
      Row.Free;
      Result := True;
    end;
  end;



var
  Row: TStrings;
  ok: Boolean;
  v: string;

begin
  FIsOpen:= dmBase.zconlocal.Connected;
  if not FIsOpen then
    raise Exception.Create('Projeto não está aberto.');



  // 2) params (se existir): preenche o FSetMain.* conforme suas chaves
  if TableExistsLocal('params') then
  begin
    v := dmbase.GetParam('HOSTNAME');
    if v <> '' then FSetMain.HostnamePost := v;

    v := dmbase.GetParam('SCHEMA');
    if v <> '' then FSetMain.SchemaPost := v;

    v := dmbase.GetParam('DATABASE');
    if v <> '' then FSetMain.BancoPOST := v;

    v := dmbase.GetParam('USER');
    if v <> '' then FSetMain.UsernamePost := v;

    v := dmbase.GetParam('PASSWORD');
    if v <> '' then FSetMain.PasswordPost := v;

    v := dmbase.GetParam('DEFAULTFOLDER');
    if v <> '' then FSetMain.Defaultfolder := v;

    // (opcional) project: se existir na tabela usa; senão, usa o próprio DB aberto
    v := dmbase.GetParam('PROJECT');
    if v <> '' then
      FSetMain.Project := v
    else if FDBPath <> '' then
      FSetMain.Project := FDBPath;
  end;
end;

procedure TProjetoDB.CarregarProjeto(const ADBPath: string; dll : string);
var
  original, destino, biblioteca, basePath: string;
begin
  if dmbase.ConectaSQLite(ADBPath,dll )then
  begin
    // tenta ler metadados
    LoadMetaFromProjetoMeta;
  end;

end;

procedure TProjetoDB.FecharProjeto;
begin
  if not FIsOpen then Exit;
  try
    FDb.Close;
  finally
    FIsOpen := False;
  end;
end;

end.

