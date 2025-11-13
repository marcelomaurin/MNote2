unit uPdfText;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

{ Extrai o texto de um PDF usando executáveis externos (pdftotext ou mutool).
  Retorna um WideString com caracteres NORMALIZADOS ao conjunto ANSI do Windows
  (fora-ANSI substituídos por '?'), mantendo o tipo WideString por compatibilidade. }
function GetText(const FileName: string): WideString;

implementation

uses
  Process
  {$IFDEF WINDOWS}
  , Windows
  {$ENDIF}
  ;

function FileExistsStrict(const FN: string): Boolean;
begin
  Result := (FN <> '') and FileExists(FN);
end;

{$IFDEF WINDOWS}
function WideToAnsiBytes(const W: UnicodeString; CodePage: UINT): RawByteString;
var
  len: Integer;
begin
  if W = '' then Exit('');
  len := WideCharToMultiByte(CodePage, WC_NO_BEST_FIT_CHARS, PWideChar(W), Length(W), nil, 0, nil, nil);
  SetLength(Result, len);
  if len > 0 then
    WideCharToMultiByte(CodePage, WC_NO_BEST_FIT_CHARS, PWideChar(W), Length(W), PAnsiChar(Result), len, nil, nil);
end;

function AnsiBytesToWide(const A: RawByteString; CodePage: UINT): UnicodeString;
var
  lenW: Integer;
begin
  if A = '' then Exit('');
  lenW := MultiByteToWideChar(CodePage, 0, PAnsiChar(A), Length(A), nil, 0);
  SetLength(Result, lenW);
  if lenW > 0 then
    MultiByteToWideChar(CodePage, 0, PAnsiChar(A), Length(A), PWideChar(Result), lenW);
end;
{$ELSE}
function WideToAnsiBytes(const W: UnicodeString; CodePage: Cardinal): RawByteString;
begin
  // Em não-Windows, aproxima para CP1252 -> volta para Wide (mantendo compatibilidade)
  Result := UTF8Encode(UTF8Encode(W));
end;

function AnsiBytesToWide(const A: RawByteString; CodePage: Cardinal): UnicodeString;
begin
  Result := UTF8Decode(UTF8String(A));
end;
{$ENDIF}

function NormalizeToAnsiWide(const W: UnicodeString): UnicodeString;
{$IFDEF WINDOWS}
var
  bytes: RawByteString;
begin
  // Converte p/ ANSI do Windows (ACP) com '?' para não mapeáveis e volta p/ Wide
  bytes := WideToAnsiBytes(W, GetACP);
  Result := AnsiBytesToWide(bytes, GetACP);
end;
{$ELSE}
begin
  // Em outros SOs deixamos como está (UTF-16)
  Result := W;
end;
{$ENDIF}

function ReadAllFromPipe(AProc: TProcess): UnicodeString;
const
  BUF_SIZE = 32768;
var
  Mem: TStringStream;
  Buf: array[0..BUF_SIZE-1] of byte;
  N: SizeInt;
begin
  Mem := TStringStream.Create('', CP_UTF8); // UTF-8 aware
  try
    while AProc.Running do
    begin
      if AProc.Output.NumBytesAvailable > 0 then
      begin
        N := AProc.Output.Read(Buf, SizeOf(Buf));
        if N > 0 then
          Mem.WriteBuffer(Buf, N);
      end
      else
        Sleep(5);
    end;

    // Lê qualquer resto após terminar
    while AProc.Output.NumBytesAvailable > 0 do
    begin
      N := AProc.Output.Read(Buf, SizeOf(Buf));
      if N > 0 then
        Mem.WriteBuffer(Buf, N);
    end;

    Result := UTF8Decode(Mem.DataString);
  finally
    Mem.Free;
  end;
end;

function ExecAndCapture(const Exe: string; const Params: array of string;
                        out StdOutText: UnicodeString; out ExitCode: Integer): Boolean;
var
  P: TProcess;
  i: Integer;
begin
  Result := False;
  StdOutText := '';
  ExitCode := -1;

  P := TProcess.Create(nil);
  try
    P.Executable := Exe;
    for i := Low(Params) to High(Params) do
      P.Parameters.Add(Params[i]);
    P.Options := [poUsePipes, poNoConsole];
    P.ShowWindow := swoHIDE;
    try
      P.Execute;
    except
      Exit(False);
    end;

    StdOutText := ReadAllFromPipe(P);
    P.WaitOnExit;
    ExitCode := P.ExitStatus;
    Result := (ExitCode = 0);
  finally
    P.Free;
  end;
end;

function TryWithPdftotext(const FileName: string; out Txt: UnicodeString): Boolean;
var
  Code: Integer;
begin
  // -q        : quiet
  // -nopgbrk  : não força quebra entre páginas
  // -enc UTF-8: saída em UTF-8
  // -eol unix : quebras \n simples (facilita normalizar)
  Result := ExecAndCapture('pdftotext',
                           ['-q', '-nopgbrk', '-enc', 'UTF-8', '-eol', 'unix', FileName, '-'],
                           Txt, Code);
end;

function TryWithMutool(const FileName: string; out Txt: UnicodeString): Boolean;
var
  Code: Integer;
begin
  // MuPDF: mutool draw -F txt -o - file.pdf
  Result := ExecAndCapture('mutool',
                           ['draw', '-F', 'txt', '-o', '-', FileName],
                           Txt, Code);
end;

function CleanText(const S: UnicodeString): UnicodeString;
var
  R: UnicodeString;
  i: Integer;
begin
  R := S;
  // Normalizações simples: CRLF/U+000C etc.
  R := StringReplace(R, #$0C, LineEnding, [rfReplaceAll]); // form feed -> newline
  // Normaliza \n para LineEnding
  R := StringReplace(R, #10, LineEnding, [rfReplaceAll]);
  // Remove \r residuais se existirem
  R := StringReplace(R, #13#13, LineEnding, [rfReplaceAll]);
  // Trim final
  i := Length(R);
  while (i > 0) and (R[i] in [#10, #13, ' ']) do Dec(i);
  SetLength(R, i);
  Result := R;
end;

function GetText(const FileName: string): WideString;
var
  RawUtf: UnicodeString;
  Ok: Boolean;
begin
  if not FileExistsStrict(FileName) then
    raise Exception.CreateFmt('Arquivo não encontrado: %s', [FileName]);

  // 1) Tenta Poppler (pdftotext)
  Ok := TryWithPdftotext(FileName, RawUtf);

  // 2) Se falhar, tenta MuPDF (mutool)
  if not Ok then
    Ok := TryWithMutool(FileName, RawUtf);

  if not Ok then
    raise Exception.Create('Não foi possível extrair texto do PDF. '+
      'Instale e/ou coloque no PATH o "pdftotext" (Poppler) ou o "mutool" (MuPDF).');

  // Limpezas e normalização
  RawUtf := CleanText(RawUtf);

  // Retorna como WideString “limitado” ao conjunto ANSI (ACP) para compatibilidade
  Result := NormalizeToAnsiWide(RawUtf);
end;

end.

