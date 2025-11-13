unit uDocText;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Zipper, laz2_DOM, laz2_XMLRead, LConvEncoding
  {$IFDEF WINDOWS}, Windows, ComObj, Variants{$ENDIF};

{ Retorna o conteúdo textual de um arquivo .doc ou .docx,
  como WideString, porém NORMALIZADO ao conjunto ANSI do Windows
  (caracteres fora do ANSI são substituídos por '?'). }
function GetDOCText(const FileName: string): WideString;

implementation

{ ========== Helpers de extensão/identificação ========== }

function FileExtLower(const S: string): string;
begin
  Result := LowerCase(ExtractFileExt(S));
end;

function IsDocx(const FN: string): Boolean;
begin
  Result := FileExtLower(FN) = '.docx';
end;

function IsDoc(const FN: string): Boolean;
begin
  Result := FileExtLower(FN) = '.doc';
end;

{ ========== Conversão ANSI <-> Wide ========== }

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
  // Aproximação fora do Windows: força CP1252-like
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
  // Mapeia para ANSI (ACP) substituindo não-mapeáveis por '?' e volta para Wide
  bytes := WideToAnsiBytes(W, GetACP);
  Result := AnsiBytesToWide(bytes, GetACP);
end;
{$ELSE}
begin
  // Em outros SOs, mantemos como está (UTF-16); ajuste se quiser "forçar ANSI-like"
  Result := W;
end;
{$ENDIF}

{ ========== Utilidades gerais ========== }

procedure AddLine(var Buf: UnicodeString; const S: UnicodeString);
begin
  if Buf <> '' then
    Buf := Buf + LineEnding;
  Buf := Buf + S;
end;

function ReadStreamToString(AStream: TStream): UnicodeString;
var
  ss: TStringStream;
begin
  // TStringStream moderno exige codepage explícito
  ss := TStringStream.Create('', CP_UTF8);
  try
    ss.CopyFrom(AStream, 0);
    Result := UTF8Decode(ss.DataString);
  finally
    ss.Free;
  end;
end;

function SameZipPath(const A, B: string): Boolean;
begin
  // Dentro do ZIP os separadores são '/'
  Result := AnsiCompareText(StringReplace(A, '\', '/', [rfReplaceAll]),
                            StringReplace(B, '\', '/', [rfReplaceAll])) = 0;
end;

{ ========== Extração de texto dos nós XML DOCX ========== }

procedure ExtractNodeText(Node: TDOMNode; var Acc: UnicodeString);
var
  i: Integer;
  s: UnicodeString;
begin
  if Node = nil then Exit;

  // Texto de run
  if (Node.NodeName = 'w:t') then
  begin
    s := UTF8Decode(Node.TextContent);
    Acc := Acc + s;
    Exit;
  end;

  // Quebra de linha explícita
  if (Node.NodeName = 'w:br') then
  begin
    Acc := Acc + LineEnding;
    Exit;
  end;

  // Tabulação
  if (Node.NodeName = 'w:tab') then
  begin
    Acc := Acc + #9;
    Exit;
  end;

  // Descer nos filhos
  for i := 0 to Node.ChildNodes.Count - 1 do
    ExtractNodeText(Node.ChildNodes[i], Acc);

  // Ao final de um parágrafo, garante quebra
  if (Node.NodeName = 'w:p') then
    Acc := Acc + LineEnding;
end;

procedure ParseXmlAndAppend(S: TStream; var OutAcc: UnicodeString);
var
  Doc: TXMLDocument;
begin
  Doc := nil;
  try
    ReadXMLFile(Doc, S); // laz2_XMLRead cuida de encoding
    if (Doc <> nil) and (Doc.DocumentElement <> nil) then
      ExtractNodeText(Doc.DocumentElement, OutAcc);
  finally
    if Assigned(Doc) then Doc.Free;
  end;
end;

{ ========== Contexto para UnZipper (eventos of object) ========== }

type
  TZipExtractCtx = class
  public
    TargetPath: string;
    Mem: TMemoryStream;
    Hit: Boolean;
    Acc: PUnicodeString; // aponta para o acumulador externo (OutText)

    procedure OnCreateStream(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
    procedure OnDoneStream(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
  end;

procedure TZipExtractCtx.OnCreateStream(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
begin
  if SameZipPath(AItem.ArchiveFileName, TargetPath) then
  begin
    Mem := TMemoryStream.Create;
    AStream := Mem;
  end
  else
    AStream := TMemoryStream.Create; // descartável
end;

procedure TZipExtractCtx.OnDoneStream(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
begin
  try
    if (AStream = Mem) and (Mem <> nil) then
    begin
      Mem.Position := 0;
      ParseXmlAndAppend(Mem, Acc^);
      Hit := True;
    end;
  finally
    AStream.Free;
    if AStream = Mem then
      Mem := nil;
  end;
end;

{ ========== Leitura de partes do DOCX (ZIP) ========== }

procedure AppendIfExistsFromZip(const ZipName, InternalPath: string; var OutText: UnicodeString);
var
  Z : TUnZipper;
  L : TStringList;
  C : TZipExtractCtx;
  i : Integer;
  FoundEntry: Boolean;
begin
  FoundEntry := False;

  Z := TUnZipper.Create;
  C := TZipExtractCtx.Create;
  L := TStringList.Create;
  try
    Z.FileName := ZipName;

    // Primeiro, verifique se a entrada existe
    Z.Examine;
    for i := 0 to Z.Entries.Count - 1 do
      if SameZipPath(Z.Entries[i].ArchiveFileName, InternalPath) then
      begin
        FoundEntry := True;
        Break;
      end;

    if not FoundEntry then
      Exit;

    // Configura contexto/handlers
    C.TargetPath := InternalPath;
    C.Mem := nil;
    C.Hit := False;
    C.Acc := @OutText;

    Z.OnCreateStream := @C.OnCreateStream;
    Z.OnDoneStream   := @C.OnDoneStream;

    // Descompacta apenas o arquivo desejado
    L.Add(InternalPath);
    Z.UnZipFiles(L);

    if C.Hit then
      OutText := Trim(OutText);
  finally
    L.Free;
    C.Free;
    Z.Free;
  end;
end;

function ExtractDocxText(const FileName: string): UnicodeString;
const
  MAIN_DOC = 'word/document.xml';
  PARTS: array[0..7] of string = (
    'word/header1.xml',
    'word/header2.xml',
    'word/header3.xml',
    'word/footer1.xml',
    'word/footer2.xml',
    'word/footer3.xml',
    'word/footnotes.xml',
    'word/endnotes.xml'
  );
var
  i: Integer;
begin
  Result := '';
  // Documento principal
  AppendIfExistsFromZip(FileName, MAIN_DOC, Result);
  // Headers/Footers/Notes (se existirem)
  for i := Low(PARTS) to High(PARTS) do
    AppendIfExistsFromZip(FileName, PARTS[i], Result);
  // Normaliza
  Result := Trim(Result);
end;

{$IFDEF WINDOWS}
function ExtractDocTextWithWord(const FileName: string): UnicodeString;
var
  WordApp, Doc: OleVariant;
  Opened: Boolean;
begin
  Result := '';
  Opened := False;
  WordApp := Unassigned;
  Doc := Unassigned;
  try
    WordApp := CreateOleObject('Word.Application');
    WordApp.Visible := False;
    // ReadOnly, sem conversão, sem prompts
    Doc := WordApp.Documents.Open(FileName, False, True, False, EmptyParam, EmptyParam,
                                  False, EmptyParam, EmptyParam, False, False, False, False, False, 0);
    Opened := True;
    Result := Doc.Content.Text; // WideString
  finally
    try
      if Opened then Doc.Close(False);
    except end;
    try
      if not VarIsEmpty(WordApp) then WordApp.Quit;
    except end;
  end;
end;
{$ENDIF}

{ ========== API principal ========== }

function GetDOCText(const FileName: string): WideString;
var
  rawWide: UnicodeString;
begin
  if not FileExists(FileName) then
    raise Exception.CreateFmt('Arquivo não encontrado: %s', [FileName]);

  if IsDocx(FileName) then
    rawWide := ExtractDocxText(FileName)
  else
  if IsDoc(FileName) then
  begin
    {$IFDEF WINDOWS}
    rawWide := ExtractDocTextWithWord(FileName);
    {$ELSE}
    raise Exception.Create('.doc requer Windows com MS Word instalado (OLE Automation).');
    {$ENDIF}
  end
  else
    raise Exception.Create('Extensão não suportada. Use .doc ou .docx.');

  // Normaliza para “padrão ANSI” (fora-ANSI -> '?') e retorna em WideString
  Result := NormalizeToAnsiWide(rawWide);
end;

end.

