unit mnote_sql_validation_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, ZConnection, mnote_service_base;

type
  TMNoteSQLValidationService = class(TMNoteServiceBase)
  public
    function ValidateStructure(const ASQL: string): Boolean;
    function ValidatePlaceholders(const ASQL, AProtocol: string): Boolean;
    function ValidateWithExplain(AConnection: TZConnection;
      const ASQL: string): Boolean;
    class function StripMarkdown(const AText: string): string; static;
  end;

implementation

uses
  ZDataset, StrUtils;

function FirstKeyword(const ASQL: string): string;
var
  I: Integer;
begin
  Result := '';
  I := 1;
  while (I <= Length(ASQL)) and (ASQL[I] <= ' ') do Inc(I);
  while (I <= Length(ASQL)) and (ASQL[I] in ['A'..'Z', 'a'..'z']) do
  begin
    Result := Result + UpCase(ASQL[I]);
    Inc(I);
  end;
end;

class function TMNoteSQLValidationService.StripMarkdown(
  const AText: string): string;
var
  Value: string;
  EndFence: Integer;
begin
  Value := Trim(AText);
  if Copy(Value, 1, 3) <> '```' then Exit(Value);
  Delete(Value, 1, 3);
  if Pos(#10, Value) > 0 then
    Delete(Value, 1, Pos(#10, Value));
  EndFence := RPos('```', Value);
  if EndFence > 0 then Delete(Value, EndFence, MaxInt);
  Result := Trim(Value);
end;

function TMNoteSQLValidationService.ValidateStructure(
  const ASQL: string): Boolean;
const
  AllowedKeywords: array[0..11] of string = ('SELECT', 'WITH', 'INSERT',
    'UPDATE', 'DELETE', 'CREATE', 'ALTER', 'DROP', 'GRANT', 'REVOKE',
    'COMMENT', 'TRUNCATE');
var
  I, Parentheses: Integer;
  InSingleQuote, InDoubleQuote, InLineComment, InBlockComment,
  KeywordAllowed: Boolean;
  Keyword: string;
begin
  ClearError;
  Result := False;
  if Trim(ASQL) = '' then
  begin
    SetError('O SQL está vazio.');
    Exit;
  end;
  if Pos('```', ASQL) > 0 then
  begin
    SetError('A resposta ainda contém marcação Markdown.');
    Exit;
  end;
  Keyword := FirstKeyword(ASQL);
  KeywordAllowed := False;
  for I := Low(AllowedKeywords) to High(AllowedKeywords) do
    if Keyword = AllowedKeywords[I] then KeywordAllowed := True;
  if not KeywordAllowed then
  begin
    SetError('Comando SQL inicial não reconhecido: ' + Keyword);
    Exit;
  end;
  Parentheses := 0;
  InSingleQuote := False;
  InDoubleQuote := False;
  InLineComment := False;
  InBlockComment := False;
  I := 1;
  while I <= Length(ASQL) do
  begin
    if InLineComment then
    begin
      if ASQL[I] in [#10, #13] then InLineComment := False;
    end
    else if InBlockComment then
    begin
      if (ASQL[I] = '*') and (I < Length(ASQL)) and
        (ASQL[I + 1] = '/') then
      begin
        InBlockComment := False;
        Inc(I);
      end;
    end
    else if InSingleQuote then
    begin
      if ASQL[I] = '''' then
      begin
        if (I < Length(ASQL)) and (ASQL[I + 1] = '''') then Inc(I)
        else InSingleQuote := False;
      end;
    end
    else if InDoubleQuote then
    begin
      if ASQL[I] = '"' then InDoubleQuote := False;
    end
    else if (ASQL[I] = '-') and (I < Length(ASQL)) and
      (ASQL[I + 1] = '-') then
    begin
      InLineComment := True;
      Inc(I);
    end
    else if (ASQL[I] = '/') and (I < Length(ASQL)) and
      (ASQL[I + 1] = '*') then
    begin
      InBlockComment := True;
      Inc(I);
    end
    else if ASQL[I] = '''' then InSingleQuote := True
    else if ASQL[I] = '"' then InDoubleQuote := True
    else if ASQL[I] = '(' then Inc(Parentheses)
    else if ASQL[I] = ')' then
    begin
      Dec(Parentheses);
      if Parentheses < 0 then Break;
    end;
    Inc(I);
  end;
  if InSingleQuote or InDoubleQuote or InBlockComment then
    SetError('Aspas ou comentário de bloco não foram fechados.')
  else if Parentheses <> 0 then
    SetError('Parênteses não estão balanceados.')
  else
    Result := True;
end;

function TMNoteSQLValidationService.ValidatePlaceholders(const ASQL,
  AProtocol: string): Boolean;
var
  I, J: Integer;
  Protocol: string;
  InSingleQuote, InDoubleQuote, InLineComment, InBlockComment: Boolean;
  Kind: Char;
begin
  Result := ValidateStructure(ASQL);
  if not Result then Exit;
  Protocol := LowerCase(AProtocol);
  InSingleQuote := False;
  InDoubleQuote := False;
  InLineComment := False;
  InBlockComment := False;
  I := 1;
  while I <= Length(ASQL) do
  begin
    if InLineComment then
    begin
      if ASQL[I] in [#10, #13] then InLineComment := False;
      Inc(I); Continue;
    end;
    if InBlockComment then
    begin
      if (ASQL[I] = '*') and (I < Length(ASQL)) and (ASQL[I + 1] = '/') then
      begin InBlockComment := False; Inc(I, 2); end else Inc(I);
      Continue;
    end;
    if InSingleQuote then
    begin
      if ASQL[I] = '''' then
      begin
        if (I < Length(ASQL)) and (ASQL[I + 1] = '''') then Inc(I)
        else InSingleQuote := False;
      end;
      Inc(I); Continue;
    end;
    if InDoubleQuote then
    begin
      if ASQL[I] = '"' then InDoubleQuote := False;
      Inc(I); Continue;
    end;
    if (ASQL[I] = '-') and (I < Length(ASQL)) and (ASQL[I + 1] = '-') then
    begin InLineComment := True; Inc(I, 2); Continue; end;
    if (ASQL[I] = '/') and (I < Length(ASQL)) and (ASQL[I + 1] = '*') then
    begin InBlockComment := True; Inc(I, 2); Continue; end;
    if ASQL[I] = '''' then begin InSingleQuote := True; Inc(I); Continue; end;
    if ASQL[I] = '"' then begin InDoubleQuote := True; Inc(I); Continue; end;

    Kind := #0;
    if ASQL[I] = '?' then Kind := '?'
    else if (ASQL[I] = '$') and (I < Length(ASQL)) and
      (ASQL[I + 1] in ['0'..'9']) then Kind := '$'
    else if (ASQL[I] = ':') and (I < Length(ASQL)) and
      (ASQL[I + 1] <> ':') and
      (ASQL[I + 1] in ['A'..'Z', 'a'..'z', '_']) then Kind := ':'
    else if (ASQL[I] = '@') and (I < Length(ASQL)) and
      (ASQL[I + 1] in ['A'..'Z', 'a'..'z', '_']) then Kind := '@';
    if Kind <> #0 then
    begin
      if (Pos('postgres', Protocol) > 0) and not (Kind in ['$', ':']) then
      begin SetError('Placeholder ' + Kind + ' não é válido para PostgreSQL.'); Exit(False); end;
      if (Pos('sqlite', Protocol) > 0) and not (Kind in ['?', '$', ':', '@']) then
      begin SetError('Placeholder inválido para SQLite.'); Exit(False); end;
      if (Pos('mysql', Protocol) > 0) and not (Kind in ['?', ':']) then
      begin SetError('Placeholder ' + Kind + ' não é válido para MySQL.'); Exit(False); end;
      if (Pos('oracle', Protocol) > 0) and (Kind <> ':') then
      begin SetError('Placeholder ' + Kind + ' não é válido para Oracle.'); Exit(False); end;
      if ((Pos('mssql', Protocol) > 0) or (Pos('sqlserver', Protocol) > 0)) and
        not (Kind in ['@', ':']) then
      begin SetError('Placeholder ' + Kind + ' não é válido para SQL Server.'); Exit(False); end;
      if (Protocol = '') or (Protocol = 'generic') then
      begin SetError('Informe o engine para validar placeholders.'); Exit(False); end;
      J := I + 1;
      while (J <= Length(ASQL)) and
        (ASQL[J] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) do Inc(J);
      I := J;
      Continue;
    end;
    Inc(I);
  end;
  ClearError;
  Result := True;
end;

function TMNoteSQLValidationService.ValidateWithExplain(
  AConnection: TZConnection; const ASQL: string): Boolean;
var
  Query: TZReadOnlyQuery;
  Prefix, Keyword: string;
begin
  Result := ValidateStructure(ASQL);
  if not Result then Exit;
  if (AConnection = nil) or not AConnection.Connected then
  begin
    SetError('Validação estrutural concluída; EXPLAIN indisponível sem conexão ativa.');
    Exit(False);
  end;
  Keyword := FirstKeyword(ASQL);
  if (Keyword <> 'SELECT') and (Keyword <> 'WITH') and
    (Keyword <> 'INSERT') and (Keyword <> 'UPDATE') and
    (Keyword <> 'DELETE') then
  begin
    SetError('Validação estrutural concluída; este engine não oferece EXPLAIN seguro para ' + Keyword + '.');
    Exit(False);
  end;
  if Pos('sqlite', LowerCase(AConnection.Protocol)) > 0 then
    Prefix := 'EXPLAIN QUERY PLAN '
  else if Pos('postgres', LowerCase(AConnection.Protocol)) > 0 then
    Prefix := 'EXPLAIN '
  else
  begin
    SetError('EXPLAIN não está habilitado para o engine ' +
      AConnection.Protocol + '.');
    Exit(False);
  end;
  Query := TZReadOnlyQuery.Create(nil);
  try
    Query.Connection := AConnection;
    Query.SQL.Text := Prefix + ASQL;
    try
      Query.Open;
      Query.Close;
      ClearError;
      Result := True;
    except
      on E: Exception do
      begin
        SetError('EXPLAIN recusou o SQL: ' + E.Message);
        Result := False;
      end;
    end;
  finally
    Query.Free;
  end;
end;

end.
