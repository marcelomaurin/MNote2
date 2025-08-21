unit uProjetoDB;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, sqlite_db;

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

    procedure EnsureDirsForFile(const AFile: string);
    procedure EnsureSchema; // usa somente chamadas de FDb
    procedure LoadMetaFromDB;
    procedure SaveMetaToDB;
    procedure CheckOpen;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure NovoProjeto(const ANome, ADBPath, ADescricao, AAlvoPath: string);
    procedure CarregarProjeto(const ADBPath: string);
    procedure SalvarProjeto;
    procedure FecharProjeto;

    // Propriedades
    property Nome: string read FNome write FNome;
    property DBPath: string read FDBPath;
    property Descricao: string read FDescricao write FDescricao;
    property AlvoPath: string read FAlvoPath write FAlvoPath;

    // Estado e acesso a DB (somente leitura)
    property IsOpen: Boolean read FIsOpen;
    property Db: TSQLiteDb read FDb;
  end;

implementation

{ TProjetoDB }

constructor TProjetoDB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDb := TSQLiteDb.Create(Self);
  FIsOpen := False;
end;

destructor TProjetoDB.Destroy;
begin
  FecharProjeto;
  inherited Destroy;
end;

procedure TProjetoDB.EnsureDirsForFile(const AFile: string);
var
  Dir: string;
begin
  Dir := ExtractFilePath(AFile);
  if (Dir <> '') and (not DirectoryExists(Dir)) then
    if not ForceDirectories(Dir) then
      raise Exception.CreateFmt('Não foi possível criar a pasta: %s', [Dir]);
end;

procedure TProjetoDB.CheckOpen;
begin
  if not FIsOpen then
    raise Exception.Create('Projeto não está aberto.');
end;

procedure TProjetoDB.EnsureSchema;
begin
  // Toda I/O passa pela FDb
  FDb.ExecSQL(
    'CREATE TABLE IF NOT EXISTS projeto_meta ('+
    '  id INTEGER PRIMARY KEY CHECK (id = 1), '+
    '  nome TEXT NOT NULL, '+
    '  descricao TEXT, '+
    '  alvo_path TEXT, '+
    '  versao_schema INTEGER NOT NULL DEFAULT 1, '+
    '  criado_em TEXT NOT NULL, '+
    '  atualizado_em TEXT NOT NULL '+
    ');'
  );

  FDb.ExecSQL(
    'INSERT INTO projeto_meta (id, nome, descricao, alvo_path, versao_schema, criado_em, atualizado_em) '+
    'SELECT 1, "Novo Projeto", "", "", 1, datetime("now"), datetime("now") '+
    'WHERE NOT EXISTS (SELECT 1 FROM projeto_meta WHERE id=1);'
  );

  FDb.Commit;
end;

procedure TProjetoDB.LoadMetaFromDB;
var
  Row: TStrings;
begin
  if not FDb.QueryRow('SELECT nome, descricao, alvo_path FROM projeto_meta WHERE id=1', [], [], Row) then
    raise Exception.Create('projeto_meta vazio. Banco inconsistente.');
  try
    FNome      := Row.Values['nome'];
    FDescricao := Row.Values['descricao'];
    FAlvoPath  := Row.Values['alvo_path'];
  finally
    Row.Free;
  end;
end;

procedure TProjetoDB.SaveMetaToDB;
begin
  FDb.ExecSQLParams(
    'UPDATE projeto_meta SET '+
    '  nome=:nome, descricao=:desc, alvo_path=:alvo, atualizado_em=datetime("now") '+
    'WHERE id=1',
    ['nome','desc','alvo'],
    [FNome, FDescricao, FAlvoPath]
  );
  FDb.Commit;
end;

procedure TProjetoDB.NovoProjeto(const ANome, ADBPath, ADescricao, AAlvoPath: string);
begin
  FecharProjeto;

  if Trim(ADBPath) = '' then
    raise Exception.Create('Informe um caminho de arquivo SQLite válido.');

  EnsureDirsForFile(ADBPath);

  FDb.Open(ADBPath);
  FDb.ApplyPragmas;
  EnsureSchema;

  FDBPath    := ADBPath;
  FNome      := ANome;
  FDescricao := ADescricao;
  FAlvoPath  := AAlvoPath;

  SaveMetaToDB;
  FIsOpen := True;
end;

procedure TProjetoDB.CarregarProjeto(const ADBPath: string);
begin
  FecharProjeto;

  if (Trim(ADBPath) = '') or (not FileExists(ADBPath)) then
    raise Exception.CreateFmt('Arquivo SQLite não encontrado: %s', [ADBPath]);

  FDb.Open(ADBPath);
  FDb.ApplyPragmas;
  EnsureSchema;   // caso seja um banco antigo
  LoadMetaFromDB;

  FDBPath := ADBPath;
  FIsOpen := True;
end;

procedure TProjetoDB.SalvarProjeto;
begin
  CheckOpen;
  SaveMetaToDB;
end;

procedure TProjetoDB.FecharProjeto;
begin
  if not FIsOpen then Exit;
  try
    FDb.Commit;
  except
    // ignora
  end;
  FDb.Close;
  FIsOpen := False;
end;

end.

