unit mquery_sqlassist;

{ Logica do autocompletar e da execucao de consultas do MQuery.
  Nao depende de componentes visuais: pode ser testada isoladamente.

  - TMQueryCatalog: tabelas e colunas conhecidas de um banco.
  - ParseTableAliases: descobre "apelido -> tabela" a partir do texto SQL.
  - DetectCompletionContext: decide se o cursor espera tabela, coluna ou
    qualquer termo.
  - BuildCompletionItems: monta a lista de sugestoes ja filtrada.
  - SplitSQLStatements / StatementReturnsRows: divisao e classificacao dos
    comandos executados pela aba de consultas. }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils;

type
  TMQueryCompletionContext = (mccGeneral, mccTable, mccColumn);

  { TMQueryCatalog }

  TMQueryCatalog = class(TComponent)
  private
    FTables: TStringList;    // nome da tabela -> TStringList de colunas (Objects)
    FKeywords: TStringList;
    procedure LoadDefaultKeywords;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    function AddTable(const AName: string): TStringList;
    procedure AddColumn(const ATable, AColumn: string);
    function FindTable(const AName: string): TStringList;
    function TableCount: Integer;
    function TableName(AIndex: Integer): string;
    function TableColumns(AIndex: Integer): TStringList;
    property Keywords: TStringList read FKeywords;
  end;

function StripIdentQuotes(const S: string): string;
function LastIdentPart(const S: string): string;
function IsSQLReservedWord(const S: string): Boolean;
procedure TokenizeSQL(const ASQL: string; ATokens: TStrings);
procedure ParseTableAliases(const ASQL: string; AAliases: TStrings);
function DetectCompletionContext(const ATextBeforeCaret: string;
  out AQualifier, APrefix: string): TMQueryCompletionContext;
procedure BuildCompletionItems(ACatalog: TMQueryCatalog; const ASQL,
  ATextBeforeCaret, ACurrentToken: string; AItems: TStrings);
procedure SplitSQLStatements(const ASQL: string; AList: TStrings);
function StatementReturnsRows(const ASQL: string): Boolean;

implementation

const
  IdentChars = ['A'..'Z', 'a'..'z', '0'..'9', '_', '$', '#', #128..#255];

  { Palavras que encerram uma referencia de tabela (nao podem ser apelido). }
  StopWords: array[0..39] of string = (
    'WHERE', 'JOIN', 'INNER', 'LEFT', 'RIGHT', 'FULL', 'CROSS', 'OUTER',
    'NATURAL', 'ON', 'USING', 'GROUP', 'ORDER', 'HAVING', 'LIMIT', 'OFFSET',
    'FETCH', 'UNION', 'EXCEPT', 'INTERSECT', 'MINUS', 'SET', 'VALUES',
    'SELECT', 'FROM', 'WINDOW', 'RETURNING', 'WITH', 'AS', 'FOR', 'INTO',
    'UPDATE', 'DELETE', 'INSERT', 'TOP', 'APPLY', 'PIVOT', 'UNPIVOT',
    'LATERAL', 'STRAIGHT_JOIN');

  { Palavras apos as quais o cursor espera um nome de tabela. }
  TableWords: array[0..5] of string = (
    'FROM', 'JOIN', 'INTO', 'UPDATE', 'TABLE', 'STRAIGHT_JOIN');

  { Palavras que abrem uma clausula; usadas para saber se uma virgula
    continua uma lista de tabelas (FROM a, b) ou de colunas. }
  ClauseWords: array[0..14] of string = (
    'SELECT', 'FROM', 'WHERE', 'JOIN', 'ON', 'SET', 'GROUP', 'ORDER',
    'HAVING', 'INTO', 'UPDATE', 'VALUES', 'BY', 'USING', 'RETURNING');

function InArray(const S: string; const A: array of string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(A) to High(A) do
    if SameText(S, A[I]) then
      Exit(True);
end;

function IsSQLReservedWord(const S: string): Boolean;
begin
  Result := InArray(S, StopWords);
end;

function StripIdentQuotes(const S: string): string;
var
  I: Integer;
  C: Char;
begin
  Result := '';
  for I := 1 to Length(S) do
  begin
    C := S[I];
    if not (C in ['"', '`', '[', ']']) then
      Result := Result + C;
  end;
  Result := Trim(Result);
end;

function LastIdentPart(const S: string): string;
var
  P: Integer;
begin
  Result := StripIdentQuotes(S);
  P := RPos('.', Result);
  if P > 0 then
    Result := Copy(Result, P + 1, MaxInt);
end;

{ ---------------------------------------------------------------------------
  Tokenizador simples: identificadores (com ponto e aspas de identificador
  colados), numeros e simbolos. Literais de texto e comentarios sao
  descartados. }
procedure TokenizeSQL(const ASQL: string; ATokens: TStrings);
var
  I, N, Start: Integer;
  C, Q: Char;
begin
  ATokens.Clear;
  N := Length(ASQL);
  I := 1;
  while I <= N do
  begin
    C := ASQL[I];

    if C in [#0..' '] then
    begin
      Inc(I);
      Continue;
    end;

    // comentario de linha
    if (C = '-') and (I < N) and (ASQL[I + 1] = '-') then
    begin
      while (I <= N) and not (ASQL[I] in [#10, #13]) do Inc(I);
      Continue;
    end;

    // comentario de bloco
    if (C = '/') and (I < N) and (ASQL[I + 1] = '*') then
    begin
      Inc(I, 2);
      while (I < N) and not ((ASQL[I] = '*') and (ASQL[I + 1] = '/')) do Inc(I);
      Inc(I, 2);
      Continue;
    end;

    // literal de texto: vira um marcador neutro
    if C = '''' then
    begin
      Inc(I);
      while I <= N do
      begin
        if ASQL[I] = '''' then
        begin
          if (I < N) and (ASQL[I + 1] = '''') then
            Inc(I, 2)
          else
            Break;
        end
        else
          Inc(I);
      end;
      Inc(I);
      ATokens.Add('''''');
      Continue;
    end;

    // identificador, possivelmente qualificado: a.b, "a"."b", [a].[b], `a`.`b`
    if (C in IdentChars) or (C in ['"', '`', '[']) then
    begin
      Start := I;
      while I <= N do
      begin
        C := ASQL[I];
        if C in IdentChars then
          Inc(I)
        else if C = '.' then
          Inc(I)
        else if C in ['"', '`', '['] then
        begin
          if C = '[' then Q := ']' else Q := C;
          Inc(I);
          while (I <= N) and (ASQL[I] <> Q) do Inc(I);
          if I <= N then Inc(I);
        end
        else
          Break;
      end;
      ATokens.Add(Copy(ASQL, Start, I - Start));
      Continue;
    end;

    ATokens.Add(C);
    Inc(I);
  end;
end;

{ ---------------------------------------------------------------------------
  Le as referencias de tabela de FROM/JOIN/UPDATE/INTO e grava em AAliases
  no formato "apelido=tabela". O proprio nome curto da tabela tambem e
  registrado como apelido (Person.Person -> "Person=Person.Person"). }
procedure ParseTableAliases(const ASQL: string; AAliases: TStrings);
var
  T: TStringList;
  I: Integer;
  Tok, Tabela, Apelido: string;

  procedure Registra(const AApelido, ATabela: string);
  var
    A: string;
  begin
    A := StripIdentQuotes(AApelido);
    if (A = '') or (ATabela = '') then Exit;
    if AAliases.IndexOfName(A) < 0 then
      AAliases.Add(A + '=' + ATabela);
  end;

  function LeReferencia(var AIdx: Integer): Boolean;
  begin
    Result := False;
    if AIdx >= T.Count then Exit;
    Tok := T[AIdx];
    if (Tok = '(') or (Tok = '''''') or IsSQLReservedWord(Tok) then Exit;
    if not ((Tok[1] in IdentChars) or (Tok[1] in ['"', '`', '['])) then Exit;

    Tabela := StripIdentQuotes(Tok);
    Inc(AIdx);
    Apelido := '';
    if (AIdx < T.Count) and SameText(T[AIdx], 'AS') then
      Inc(AIdx);
    if (AIdx < T.Count) then
    begin
      Tok := T[AIdx];
      if ((Tok[1] in IdentChars) or (Tok[1] in ['"', '`', '['])) and
         (Pos('.', Tok) = 0) and not IsSQLReservedWord(Tok) then
      begin
        Apelido := Tok;
        Inc(AIdx);
      end;
    end;

    if Apelido <> '' then
      Registra(Apelido, Tabela);
    Registra(LastIdentPart(Tabela), Tabela);
    Result := True;
  end;

begin
  AAliases.Clear;
  T := TStringList.Create;
  try
    TokenizeSQL(ASQL, T);
    I := 0;
    while I < T.Count do
    begin
      Tok := T[I];
      if InArray(Tok, ['FROM', 'JOIN', 'STRAIGHT_JOIN', 'UPDATE', 'INTO']) then
      begin
        Inc(I);
        if LeReferencia(I) then
        begin
          // FROM a x, b y, c
          while (I < T.Count) and (T[I] = ',') do
          begin
            Inc(I);
            if not LeReferencia(I) then Break;
          end;
        end;
        Continue;
      end;
      Inc(I);
    end;
  finally
    T.Free;
  end;
end;

{ ---------------------------------------------------------------------------
  Contexto do cursor. Recebe o texto ate o cursor. }
function DetectCompletionContext(const ATextBeforeCaret: string;
  out AQualifier, APrefix: string): TMQueryCompletionContext;
var
  I, P: Integer;
  Palavra, Antes, Ultimo, Clausula: string;
  T: TStringList;
  Q: Char;
begin
  Result := mccGeneral;
  AQualifier := '';
  APrefix := '';

  // palavra sob o cursor (aceita ponto e aspas de identificador)
  I := Length(ATextBeforeCaret);
  while I > 0 do
  begin
    if ATextBeforeCaret[I] in IdentChars + ['.'] then
      Dec(I)
    else if ATextBeforeCaret[I] in ['"', '`', ']'] then
    begin
      if ATextBeforeCaret[I] = ']' then Q := '[' else Q := ATextBeforeCaret[I];
      Dec(I);
      while (I > 0) and (ATextBeforeCaret[I] <> Q) do Dec(I);
      if I > 0 then Dec(I);
    end
    else
      Break;
  end;
  Palavra := Copy(ATextBeforeCaret, I + 1, MaxInt);
  Antes := Copy(ATextBeforeCaret, 1, I);

  P := RPos('.', Palavra);
  if P > 0 then
  begin
    AQualifier := StripIdentQuotes(Copy(Palavra, 1, P - 1));
    APrefix := StripIdentQuotes(Copy(Palavra, P + 1, MaxInt));
    Exit(mccColumn);
  end;

  APrefix := StripIdentQuotes(Palavra);

  T := TStringList.Create;
  try
    TokenizeSQL(Antes, T);
    if T.Count = 0 then Exit;

    Ultimo := T[T.Count - 1];
    if InArray(Ultimo, TableWords) then
      Exit(mccTable);

    if Ultimo = ',' then
    begin
      Clausula := '';
      for I := T.Count - 1 downto 0 do
        if InArray(T[I], ClauseWords) then
        begin
          Clausula := UpperCase(T[I]);
          Break;
        end;
      if Clausula = 'FROM' then
        Exit(mccTable);
    end;
  finally
    T.Free;
  end;
end;

{ ---------------------------------------------------------------------------
  Monta a lista de sugestoes ja filtrada pelo que foi digitado.
  ACurrentToken e o texto que o componente de autocompletar vai substituir;
  se ele incluir "apelido.", os itens tambem incluem esse trecho. }
procedure BuildCompletionItems(ACatalog: TMQueryCatalog; const ASQL,
  ATextBeforeCaret, ACurrentToken: string; AItems: TStrings);
var
  Ctx: TMQueryCompletionContext;
  Qualificador, Prefixo, Insere, NomeTabela: string;
  Apelidos, Vistos, Cols: TStringList;
  I, J, P: Integer;

  procedure Adiciona(const S: string);
  var
    K: Integer;
  begin
    if S = '' then Exit;
    if (Prefixo <> '') and not AnsiStartsText(Prefixo, S) then Exit;
    if Vistos.Find(Insere + S, K) then Exit;
    Vistos.Add(Insere + S);
    AItems.Add(Insere + S);
  end;

  procedure AdicionaColunas(AColunas: TStringList);
  var
    K: Integer;
  begin
    if AColunas = nil then Exit;
    for K := 0 to AColunas.Count - 1 do
      Adiciona(AColunas[K]);
  end;

begin
  AItems.Clear;
  Ctx := DetectCompletionContext(ATextBeforeCaret, Qualificador, Prefixo);

  // O que o componente substitui pode ou nao conter "apelido."
  Insere := '';
  P := RPos('.', ACurrentToken);
  if P > 0 then
    Insere := Copy(ACurrentToken, 1, P);
  if ACurrentToken <> '' then
    Prefixo := StripIdentQuotes(Copy(ACurrentToken, P + 1, MaxInt));

  Apelidos := TStringList.Create;
  Vistos := TStringList.Create;
  try
    Vistos.Sorted := True;
    Vistos.CaseSensitive := False;
    ParseTableAliases(ASQL, Apelidos);

    case Ctx of
      mccColumn:
        begin
          if ACatalog = nil then Exit;
          NomeTabela := Apelidos.Values[Qualificador];
          if NomeTabela = '' then
            NomeTabela := Qualificador;
          AdicionaColunas(ACatalog.FindTable(NomeTabela));

          // "esquema." -> tabelas desse esquema, quando o catalogo as guarda assim
          for I := 0 to ACatalog.TableCount - 1 do
            if AnsiStartsText(Qualificador + '.', ACatalog.TableName(I)) then
              Adiciona(Copy(ACatalog.TableName(I), Length(Qualificador) + 2, MaxInt));
        end;

      mccTable:
        begin
          if ACatalog = nil then Exit;
          for I := 0 to ACatalog.TableCount - 1 do
            Adiciona(ACatalog.TableName(I));
        end;
    else
      begin
        // 1) colunas das tabelas usadas na consulta
        if ACatalog <> nil then
          for I := 0 to Apelidos.Count - 1 do
            AdicionaColunas(ACatalog.FindTable(Apelidos.ValueFromIndex[I]));

        // 2) apelidos e tabelas da consulta
        for I := 0 to Apelidos.Count - 1 do
          Adiciona(Apelidos.Names[I]);

        // 3) palavras-chave
        if ACatalog <> nil then
          for I := 0 to ACatalog.Keywords.Count - 1 do
            Adiciona(ACatalog.Keywords[I]);

        // 4) todas as tabelas
        if ACatalog <> nil then
          for I := 0 to ACatalog.TableCount - 1 do
            Adiciona(ACatalog.TableName(I));

        // 5) sem tabela na consulta: colunas de todas as tabelas (com prefixo)
        if (ACatalog <> nil) and (Apelidos.Count = 0) and (Prefixo <> '') then
          for I := 0 to ACatalog.TableCount - 1 do
          begin
            Cols := ACatalog.TableColumns(I);
            for J := 0 to Cols.Count - 1 do
              Adiciona(Cols[J]);
          end;
      end;
    end;
  finally
    Vistos.Free;
    Apelidos.Free;
  end;
end;

{ ---------------------------------------------------------------------------
  Divide um script em comandos separados por ";" fora de textos, comentarios
  e blocos $$...$$. Blocos de procedimento (CREATE FUNCTION/PROCEDURE/
  TRIGGER/PACKAGE, BEGIN ... END, DECLARE) sao enviados inteiros. }
procedure SplitSQLStatements(const ASQL: string; AList: TStrings);
var
  I, N, Start: Integer;
  C: Char;
  Cmd, U: string;

  procedure Emite(const S: string);
  var
    X: string;
  begin
    X := Trim(S);
    if X <> '' then
      AList.Add(X);
  end;

begin
  AList.Clear;
  U := UpperCase(ASQL);
  if (Pos('CREATE FUNCTION', U) > 0) or (Pos('CREATE OR REPLACE', U) > 0) or
     (Pos('CREATE PROCEDURE', U) > 0) or (Pos('CREATE TRIGGER', U) > 0) or
     (Pos('CREATE PACKAGE', U) > 0) or (Pos('DECLARE', U) > 0) or
     (Pos('BEGIN', U) > 0) then
  begin
    Cmd := Trim(ASQL);
    // um ";" final isolado continua aceito por quase todos os bancos,
    // exceto o Oracle em PL/SQL, que precisa dele; por isso fica como esta.
    Emite(Cmd);
    Exit;
  end;

  N := Length(ASQL);
  I := 1;
  Start := 1;
  while I <= N do
  begin
    C := ASQL[I];
    if (C = '-') and (I < N) and (ASQL[I + 1] = '-') then
    begin
      while (I <= N) and not (ASQL[I] in [#10, #13]) do Inc(I);
      Continue;
    end;
    if (C = '/') and (I < N) and (ASQL[I + 1] = '*') then
    begin
      Inc(I, 2);
      while (I < N) and not ((ASQL[I] = '*') and (ASQL[I + 1] = '/')) do Inc(I);
      Inc(I, 2);
      Continue;
    end;
    if C in ['''', '"', '`'] then
    begin
      Inc(I);
      while (I <= N) and (ASQL[I] <> C) do Inc(I);
      Inc(I);
      Continue;
    end;
    if (C = '$') and (I < N) and (ASQL[I + 1] = '$') then
    begin
      Inc(I, 2);
      while (I < N) and not ((ASQL[I] = '$') and (ASQL[I + 1] = '$')) do Inc(I);
      Inc(I, 2);
      Continue;
    end;
    if C = ';' then
    begin
      Emite(Copy(ASQL, Start, I - Start));
      Start := I + 1;
    end;
    Inc(I);
  end;
  if Start <= N then
    Emite(Copy(ASQL, Start, MaxInt));
end;

function StatementReturnsRows(const ASQL: string): Boolean;
var
  T: TStringList;
  Primeira: string;
begin
  Result := False;
  T := TStringList.Create;
  try
    TokenizeSQL(ASQL, T);
    if T.Count = 0 then Exit;
    Primeira := T[0];
    if Primeira = '(' then
      Exit(True);
    Result := InArray(Primeira, ['SELECT', 'WITH', 'SHOW', 'DESCRIBE', 'DESC',
      'EXPLAIN', 'PRAGMA', 'VALUES', 'TABLE']);
  finally
    T.Free;
  end;
end;

{ TMQueryCatalog }

constructor TMQueryCatalog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTables := TStringList.Create;
  FTables.OwnsObjects := True;
  FTables.CaseSensitive := False;
  FTables.Sorted := True;
  FTables.Duplicates := dupIgnore;
  FKeywords := TStringList.Create;
  LoadDefaultKeywords;
end;

destructor TMQueryCatalog.Destroy;
begin
  FTables.Free;
  FKeywords.Free;
  inherited Destroy;
end;

procedure TMQueryCatalog.LoadDefaultKeywords;
const
  KW: array[0..55] of string = (
    'SELECT', 'FROM', 'WHERE', 'AND', 'OR', 'NOT', 'IN', 'EXISTS', 'BETWEEN',
    'LIKE', 'IS NULL', 'IS NOT NULL', 'AS', 'DISTINCT', 'INNER JOIN',
    'LEFT JOIN', 'RIGHT JOIN', 'FULL JOIN', 'CROSS JOIN', 'JOIN', 'ON',
    'GROUP BY', 'ORDER BY', 'HAVING', 'ASC', 'DESC', 'LIMIT', 'OFFSET',
    'UNION', 'UNION ALL', 'INSERT INTO', 'VALUES', 'UPDATE', 'SET',
    'DELETE FROM', 'CREATE TABLE', 'ALTER TABLE', 'DROP TABLE', 'CASE',
    'WHEN', 'THEN', 'ELSE', 'END', 'NULL', 'COUNT', 'SUM', 'AVG', 'MIN',
    'MAX', 'COALESCE', 'CAST', 'UPPER', 'LOWER', 'TRIM', 'SUBSTRING',
    'CURRENT_DATE');
var
  I: Integer;
begin
  FKeywords.Clear;
  for I := Low(KW) to High(KW) do
    FKeywords.Add(KW[I]);
end;

procedure TMQueryCatalog.Clear;
begin
  FTables.Clear;
end;

function TMQueryCatalog.AddTable(const AName: string): TStringList;
var
  Idx: Integer;
  Nome: string;
begin
  Result := nil;
  Nome := StripIdentQuotes(AName);
  if Nome = '' then Exit;
  Idx := FTables.IndexOf(Nome);
  if Idx < 0 then
  begin
    Result := TStringList.Create;
    Result.CaseSensitive := False;
    FTables.AddObject(Nome, Result);
  end
  else
    Result := TStringList(FTables.Objects[Idx]);
end;

procedure TMQueryCatalog.AddColumn(const ATable, AColumn: string);
var
  Cols: TStringList;
  Col: string;
begin
  Col := StripIdentQuotes(AColumn);
  if Col = '' then Exit;
  Cols := AddTable(ATable);
  if (Cols <> nil) and (Cols.IndexOf(Col) < 0) then
    Cols.Add(Col);
end;

function TMQueryCatalog.FindTable(const AName: string): TStringList;
var
  Idx, I: Integer;
  Nome, Curto: string;
begin
  Result := nil;
  Nome := StripIdentQuotes(AName);
  if Nome = '' then Exit;

  Idx := FTables.IndexOf(Nome);
  if Idx >= 0 then
    Exit(TStringList(FTables.Objects[Idx]));

  // esquema.tabela -> tabela
  Curto := LastIdentPart(Nome);
  if Curto <> Nome then
  begin
    Idx := FTables.IndexOf(Curto);
    if Idx >= 0 then
      Exit(TStringList(FTables.Objects[Idx]));
  end;

  // tabela -> algum esquema.tabela do catalogo
  for I := 0 to FTables.Count - 1 do
    if SameText(LastIdentPart(FTables[I]), Curto) then
      Exit(TStringList(FTables.Objects[I]));
end;

function TMQueryCatalog.TableCount: Integer;
begin
  Result := FTables.Count;
end;

function TMQueryCatalog.TableName(AIndex: Integer): string;
begin
  Result := FTables[AIndex];
end;

function TMQueryCatalog.TableColumns(AIndex: Integer): TStringList;
begin
  Result := TStringList(FTables.Objects[AIndex]);
end;

end.
