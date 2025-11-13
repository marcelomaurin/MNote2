unit uDocText;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Zipper, laz2_DOM, laz2_XMLRead
  {$IFDEF WINDOWS}, Windows, ComObj, Variants{$ENDIF};

function GetDOCText(const FileName: string): WideString;

implementation

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

{ ========== EXTRAÇÃO SOMENTE DO TEXTO ========== }

procedure ExtractTextOnly(Node: TDOMNode; var Acc: UnicodeString);
var
  i: integer;
  s: UnicodeString;
begin
  if Node = nil then Exit;

  // Texto dentro de <w:t>
  if Node.NodeName = 'w:t' then
  begin
    s := UTF8Decode(Node.TextContent);
    Acc := Acc + s;
    Exit;
  end;

  // Desce nos filhos
  for i := 0 to Node.ChildNodes.Count - 1 do
    ExtractTextOnly(Node.ChildNodes[i], Acc);
end;

procedure ParseXmlTextOnly(S: TStream; var OutAcc: UnicodeString);
var
  Doc: TXMLDocument;
begin
  Doc := nil;
  try
    ReadXMLFile(Doc, S);
    if (Doc <> nil) and (Doc.DocumentElement <> nil) then
      ExtractTextOnly(Doc.DocumentElement, OutAcc);
  finally
    if Assigned(Doc) then Doc.Free;
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
begin
  if SameText(StringReplace(AItem.ArchiveFileName, '\', '/', [rfReplaceAll]), Target) then
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
    if AStream = Mem then
    begin
      Mem.Position := 0;
      ParseXmlTextOnly(Mem, Acc^);
      Found := True;
    end;
  finally
    AStream.Free;
    if AStream = Mem then Mem := nil;
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
    Z.Examine;

    // só usamos document.xml — ignorar headers, footnotes, etc
    C.Target := MAIN;
    C.Acc := @Result;

    Z.OnCreateStream := @C.OnCreate;
    Z.OnDoneStream   := @C.OnDone;

    L.Add(MAIN);
    Z.UnZipFiles(L);
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
  else
  if IsDoc(FileName) then
  begin
    {$IFDEF WINDOWS}
    Result := ExtractDocText(FileName);
    {$ELSE}
    raise Exception.Create('.doc só funciona no Windows com Word.');
    {$ENDIF}
  end
  else
    raise Exception.Create('Extensão inválida (use .doc ou .docx).');

  Result := Trim(Result);
end;

end.

