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

    procedure CheckDmBaseConnected;
    function ReadParamValue(const AKey: string): string;
    procedure LoadMetaFromProjetoDB; // tenta ler projeto_meta; se falhar, usa params
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Lê "database" da tabela params (RegistraParam) e abre o SQLite apontado, carregando os campos
    procedure CarregarProjeto;

    // Fecha o SQLite aberto (se houver)
    procedure FecharProjeto;

    // Somente leitura
    property IsOpen: Boolean read FIsOpen;
    property Db: TSQLiteDb read FDb;

    // Metadados do projeto (carregados do banco alvo)
    property Nome: string read FNome;
    property DBPath: string read FDBPath;
    property Descricao: string read FDescricao;
    property AlvoPath: string read FAlvoPath;
  end;

implementation

uses
  ZDataset, // TZQuery
  // Ajuste o nome da unit que declara TdmBase/dmBase se for diferente de "base"
  base;

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
end;

destructor TProjetoDB.Destroy;
begin
  FecharProjeto;
  inherited Destroy;
end;

procedure TProjetoDB.CheckDmBaseConnected;
begin
  if (dmBase = nil) or (dmBase.zconlocal = nil) or (not dmBase.zconlocal.Connected) then
    raise Exception.Create('Conexão principal (dmBase.zconlocal) não está conectada.');
end;

function TProjetoDB.ReadParamValue(const AKey: string): string;
var
  Q: TZQuery;
begin
  Result := '';
  CheckDmBaseConnected;
  Q := TZQuery.Create(Self);
  try
    Q.Connection := dmBase.zconlocal;
    Q.SQL.Text :=
      'SELECT valor FROM params '+
      'WHERE chave = :chave COLLATE NOCASE '+
      'LIMIT 1';
    Q.ParamByName('chave').AsString := AKey;
    Q.Open;
    if not Q.EOF then
      Result := Q.Fields[0].AsString;
  finally
    Q.Free;
  end;
end;

procedure TProjetoDB.LoadMetaFromProjetoDB;
var
  Row: TStrings;
  ok: Boolean;
begin
  // Tenta ler da tabela projeto_meta (id=1)
  ok := FDb.QueryRow(
    'SELECT nome, descricao, alvo_path FROM projeto_meta WHERE id=1',
    [], [], Row
  );

  if ok then
  begin
    try
      FNome      := Row.Values['nome'];
      FDescricao := Row.Values['descricao'];
      FAlvoPath  := Row.Values['alvo_path'];
      Exit;
    finally
      Row.Free;
    end;
  end;

  // Fallback: usa params da conexão principal (caso projeto_meta não exista)
  FNome      := ReadParamValue('PROJETO');
  FDescricao := ReadParamValue('PROPOSITO');
  FAlvoPath  := ReadParamValue('TARGET');
end;

procedure TProjetoDB.CarregarProjeto;
var
  dbFromParams: string;
begin
  // 1) Descobre o caminho do banco a partir de params.database
  dbFromParams := ReadParamValue('database');
  if Trim(dbFromParams) = '' then
    raise Exception.Create('Parâmetro "database" não encontrado na tabela params.');

  if not FileExists(dbFromParams) then
    raise Exception.CreateFmt('Arquivo SQLite não encontrado: %s', [dbFromParams]);

  // 2) Abre o SQLite alvo
  FecharProjeto; // caso já tenha algo aberto
  FDb.Open(dbFromParams);
  // Se sua classe sqlite_db tiver ApplyPragmas, você pode chamar aqui; mantive enxuto
  FDBPath := dbFromParams;
  FIsOpen := True;

  // 3) Lê metadados (projeto_meta) ou faz fallback via params
  LoadMetaFromProjetoDB;
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

