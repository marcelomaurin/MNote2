unit uDocText;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Zipper, laz2_DOM, laz2_XMLRead
  {$IFDEF WINDOWS}, Windows, ComObj, Variants{$ENDIF};

function GetDOCText(const FileName: string): WideString;
function DocFileToText(const FileName: string): WideString; // alias de compatibilidade

implementation

function FileExtLower(const S: string): string;
begin
  Result := LowerCase(ExtractFileExt(S));
end;

// === ALIAS DE COMPATIBILIDADE PARA CÓDIGO ANTIGO ===
function DocFileToText(const FileName: string): WideString;
begin
  Result := GetDOCText(FileName);
end;

function IsDocx(const FN: string): Boolean;
begin
  Result := FileExtLower(FN) = '.docx';
end;

function IsDoc(const FN: string): Boolean;
begin
  Result := FileExtLower(FN) = '.doc';
end;

{ ========== EXTRAÇÃO SOMENTE DO TEXTO ========== }

procedure ExtractTextOnly(Node: TDOMNode; var Acc: UnicodeString);
var
  i: integer;
  s: UnicodeString;
  name: string;
begin
  if Node = nil then
    Exit;

  name := Node.NodeName;

  // Texto dentro de <w:t>
  if name = 'w:t' then
  begin
    // DOCX é UTF-8 no XML; DOM devolve UTF-8, então convertemos para UnicodeString
    s := UTF8Decode(Node.TextContent);
    Acc := Acc + s;
    Exit;
  end;

  // Quebra de linha explícita <w:br> ou <w:cr>
  if (name = 'w:br') or (name = 'w:cr') then
  begin
    Acc := Acc + LineEnding;
    Exit;
  end;

  // Tabulação <w:tab>
  if name = 'w:tab' then
  begin
    Acc := Acc + #9;
    Exit;
  end;

  // Parágrafo <w:p>: processa filhos e adiciona quebra de linha no final
  if name = 'w:p' then
  begin
    for i := 0 to Node.ChildNodes.Count - 1 do
      ExtractTextOnly(Node.ChildNodes[i], Acc);

    // Fecha parágrafo com quebra de linha
    Acc := Acc + LineEnding;
    Exit;
  end;

  // Demais nós: só desce nos filhos
  for i := 0 to Node.ChildNodes.Count - 1 do
    ExtractTextOnly(Node.ChildNodes[i], Acc);
end;

procedure ParseXmlTextOnly(S: TStream; var OutAcc: UnicodeString);
var
  Doc: TXMLDocument;
begin
  Doc := nil;
  try
    try
      ReadXMLFile(Doc, S);
    except
      on E: Exception do
        raise Exception.Create('Erro ao ler XML do DOCX: ' + E.Message);
    end;

    if (Doc <> nil) and (Doc.DocumentElement <> nil) then
      ExtractTextOnly(Doc.DocumentElement, OutAcc);
  finally
    if Assigned(Doc) then
      Doc.Free;
  end;
end;

type
  TZipCtx = class
  public
    Target: string;
    Mem: TMemoryStream;
    Found: Boolean;
    Acc: PUnicodeString;

    procedure OnCreate(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
    procedure OnDone(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
  end;

procedure TZipCtx.OnCreate(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
var
  normName: string;
begin
  // Normaliza o caminho dentro do ZIP para usar '/'
  normName := StringReplace(AItem.ArchiveFileName, '\', '/', [rfReplaceAll]);

  if SameText(normName, Target) then
  begin
    Mem := TMemoryStream.Create;
    AStream := Mem;
  end
  else
    AStream := TMemoryStream.Create;
end;

procedure TZipCtx.OnDone(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
begin
  try
    if (Mem <> nil) and (AStream = Mem) then
    begin
      Mem.Position := 0;
      ParseXmlTextOnly(Mem, Acc^);
      Found := True;
    end;
  finally
    AStream.Free;
    if AStream = Mem then
      Mem := nil;
  end;
end;

function ExtractDocxTextOnly(const FileName: string): UnicodeString;
const
  MAIN = 'word/document.xml';
var
  Z: TUnZipper;
  L: TStringList;
  C: TZipCtx;
begin
  Result := '';
  Z := TUnZipper.Create;
  C := TZipCtx.Create;
  L := TStringList.Create;
  try
    Z.FileName := FileName;

    // define alvo e acumulador
    C.Target := MAIN;
    C.Acc    := @Result;
    C.Found  := False;

    Z.OnCreateStream := @C.OnCreate;
    Z.OnDoneStream   := @C.OnDone;

    // só pedimos o document.xml
    L.Add(MAIN);

    try
      Z.UnZipFiles(L);
    except
      on E: Exception do
        raise Exception.Create('Erro ao descompactar DOCX: ' + E.Message);
    end;

    if not C.Found then
      raise Exception.Create('DOCX inválido: word/document.xml não encontrado.');
  finally
    L.Free;
    C.Free;
    Z.Free;
  end;
end;

{$IFDEF WINDOWS}
function ExtractDocText(const FileName: string): UnicodeString;
var
  WApp, Doc: OleVariant;
begin
  WApp := CreateOleObject('Word.Application');
  WApp.Visible := False;

  Doc := WApp.Documents.Open(FileName, False, True);
  Result := Doc.Content.Text;

  Doc.Close(False);
  WApp.Quit;
end;
{$ENDIF}

function GetDOCText(const FileName: string): WideString;
begin
  if not FileExists(FileName) then
    raise Exception.Create('Arquivo não encontrado.');

  if IsDocx(FileName) then
    Result := ExtractDocxTextOnly(FileName)
  else if IsDoc(FileName) then
  begin
    {$IFDEF WINDOWS}
    Result := ExtractDocText(FileName);
    {$ELSE}
    raise Exception.Create('.doc só funciona no Windows com Word instalado.');
    {$ENDIF}
  end
  else
    raise Exception.Create('Extensão inválida (use .doc ou .docx).');

  Result := Trim(Result);
end;

end.

