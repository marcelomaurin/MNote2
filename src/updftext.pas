unit uPdfText;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

{ Parser PDF mínimo, sem executáveis externos.
  - Verifica se o arquivo existe.
  - Lê o PDF em memória.
  - Procura streams (stream...endstream).
  - Ignora streams marcados como /Subtype /Image.
  - Descomprime streams com /Filter /FlateDecode.
  - Dentro do conteúdo, extrai texto entre parênteses (...) (Tj/TJ).
  - Retorna texto como WideString, normalizado para ANSI (fora-ANSI -> '?'). }
function GetPDFText(const FileName: string): WideString;

implementation

uses
  ZStream
  {$IFDEF WINDOWS}, Windows{$ENDIF};

type
  TRawBytes = RawByteString;

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
  len := WideCharToMultiByte(CodePage, WC_NO_BEST_FIT_CHARS,
                             PWideChar(W), Length(W), nil, 0, nil, nil);
  SetLength(Result, len);
  if len > 0 then
    WideCharToMultiByte(CodePage, WC_NO_BEST_FIT_CHARS,
                        PWideChar(W), Length(W), PAnsiChar(Result), len, nil, nil);
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
  bytes := WideToAnsiBytes(W, GetACP);
  Result := AnsiBytesToWide(bytes, GetACP);
end;
{$ELSE}
begin
  Result := W;
end;
{$ENDIF}

{ ========== Utilidades básicas ========== }

function LoadFileToBuffer(const FileName: string): TRawBytes;
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(Result, fs.Size);
    if fs.Size > 0 then
      fs.ReadBuffer(Pointer(Result)^, fs.Size);
  finally
    fs.Free;
  end;
end;

function PosExA(const SubStr, S: TRawBytes; Offset: SizeInt = 1): SizeInt;
begin
  Result := Pos(SubStr, Copy(S, Offset, MaxInt));
  if Result > 0 then
    Inc(Result, Offset - 1);
end;

function FindLastDictStart(const Buf: TRawBytes; StreamPos: SizeInt; MaxBack: SizeInt = 4096): SizeInt;
var
  i, startSearch: SizeInt;
begin
  Result := 0;
  if StreamPos < 2 then Exit;
  if StreamPos > MaxBack then
    startSearch := StreamPos - MaxBack
  else
    startSearch := 1;

  for i := StreamPos downto startSearch do
  begin
    if (Buf[i] = '<') and (i < Length(Buf)) and (Buf[i+1] = '<') then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function ContainsToken(const S, Token: TRawBytes): Boolean;
begin
  Result := Pos(Token, S) > 0;
end;

{ ========== Descompressão FlateDecode ========== }

function InflateData(const Data: TRawBytes): TRawBytes;
var
  inStream, outStream: TMemoryStream;
  z: TDecompressionStream;
  buf: array[0..4095] of byte;
  n: Integer;
begin
  Result := '';
  if Data = '' then Exit;

  inStream := TMemoryStream.Create;
  outStream := TMemoryStream.Create;
  try
    inStream.WriteBuffer(Pointer(Data)^, Length(Data));
    inStream.Position := 0;

    z := TDecompressionStream.Create(inStream);
    try
      repeat
        n := z.Read(buf, SizeOf(buf));
        if n > 0 then
          outStream.WriteBuffer(buf, n);
      until n = 0;
    finally
      z.Free;
    end;

    SetLength(Result, outStream.Size);
    outStream.Position := 0;
    if outStream.Size > 0 then
      outStream.ReadBuffer(Pointer(Result)^, outStream.Size);
  finally
    outStream.Free;
    inStream.Free;
  end;
end;

{ ========== Extração de texto de conteúdo PDF (mínimo) ========== }

function ExtractTextFromContent(const S: TRawBytes): UnicodeString;
var
  i, len: SizeInt;
  inStr: Boolean;
  cur: TRawBytes;
  ch: AnsiChar;
begin
  Result := '';
  len := Length(S);
  i := 1;
  inStr := False;
  cur := '';

  while i <= len do
  begin
    ch := S[i];

    if not inStr then
    begin
      if ch = '(' then
      begin
        inStr := True;
        cur := '';
      end;
    end
    else
    begin
      if ch = '\' then
      begin
        // escape: pega próximo char se houver
        Inc(i);
        if i <= len then
        begin
          ch := S[i];
          case ch of
            'n': cur := cur + #10;
            'r': cur := cur + #13;
            't': cur := cur + #9;
            'b': cur := cur + #8;
            'f': cur := cur + #12;
          else
            cur := cur + ch;
          end;
        end;
      end
      else if ch = ')' then
      begin
        // final de string
        if cur <> '' then
        begin
          // converte bytes "como estão" para Wide (heurística simples)
          {$IFDEF WINDOWS}
          Result := Result + AnsiBytesToWide(cur, GetACP);
          {$ELSE}
          Result := Result + UTF8Decode(UTF8String(cur));
          {$ENDIF}
        end;
        inStr := False;
        cur := '';
      end
      else
        cur := cur + ch;
    end;

    Inc(i);
  end;
end;

{ ========== Loop principal de streams do PDF ========== }

function ExtractTextFromPdfBuffer(const Buf: TRawBytes): UnicodeString;
var
  idx, streamPos, endStreamPos: SizeInt;
  dictStart: SizeInt;
  dictStr: TRawBytes;
  isImage, isFlate: Boolean;
  lineEndPos: SizeInt;
  streamDataStart, streamDataLen: SizeInt;
  rawStream, decStream: TRawBytes;
begin
  Result := '';
  idx := 1;
  while True do
  begin
    streamPos := PosExA('stream', Buf, idx);
    if streamPos = 0 then
      Break;

    endStreamPos := PosExA('endstream', Buf, streamPos + 6);
    if endStreamPos = 0 then
      Break;

    // Dicionário antes de "stream"
    dictStart := FindLastDictStart(Buf, streamPos);
    if dictStart > 0 then
      dictStr := Copy(Buf, dictStart, streamPos - dictStart)
    else
      dictStr := '';

    // Heurísticas:
    isImage := ContainsToken(dictStr, '/Subtype') and ContainsToken(dictStr, '/Image');
    if isImage then
    begin
      idx := endStreamPos + 9; // 'endstream'
      Continue; // ignora imagens
    end;

    isFlate := ContainsToken(dictStr, '/Filter') and ContainsToken(dictStr, 'FlateDecode');

    // posição real de início dos dados após "stream" + EOL
    lineEndPos := PosExA(#10, Buf, streamPos + 6); // assume LF
    if lineEndPos = 0 then
      lineEndPos := streamPos + 6
    else
      Inc(lineEndPos); // primeiro byte após LF

    streamDataStart := lineEndPos;
    streamDataLen := endStreamPos - streamDataStart;
    if (streamDataLen <= 0) or (streamDataStart <= 0) then
    begin
      idx := endStreamPos + 9;
      Continue;
    end;

    rawStream := Copy(Buf, streamDataStart, streamDataLen);

    if isFlate then
      decStream := InflateData(rawStream)
    else
      decStream := rawStream;

    if decStream <> '' then
      Result := Result + ExtractTextFromContent(decStream) + LineEnding;

    idx := endStreamPos + 9; // avança depois de 'endstream'
  end;

  Result := Trim(Result);
end;

{ ========== API principal ========== }

function GetPDFText(const FileName: string): WideString;
var
  buf: TRawBytes;
  rawWide: UnicodeString;
begin
  if not FileExistsStrict(FileName) then
    raise Exception.CreateFmt('Arquivo PDF não encontrado: %s', [FileName]);

  buf := LoadFileToBuffer(FileName);
  if buf = '' then
    Exit('');

  rawWide := ExtractTextFromPdfBuffer(buf);

  // Normaliza para ANSI (fora-ANSI -> '?'), mantendo tipo WideString
  Result := NormalizeToAnsiWide(rawWide);
end;

end.

