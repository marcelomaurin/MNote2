unit mnote_editor_theme;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_service_base;

type
  { TMNoteEditorTheme }

  TMNoteEditorTheme = class
  public
    Name: string;
    EditorBackground: LongInt;
    EditorForeground: LongInt;
    SelectionBackground: LongInt;
    SelectionForeground: LongInt;
    CurrentLine: LongInt;
    GutterBackground: LongInt;
    CommentColor: LongInt;
    KeywordColor: LongInt;
    StringColor: LongInt;
    NumberColor: LongInt;
    IdentifierColor: LongInt;
    SymbolColor: LongInt;
    procedure Assign(ASource: TMNoteEditorTheme);
  end;

  { TMNoteEditorThemeService }

  TMNoteEditorThemeService = class(TMNoteServiceBase)
  private
    FCurrent: TMNoteEditorTheme;
    procedure LoadFallback;
    function ParseColor(const AValue: string; ADefault: LongInt): LongInt;
  public
    constructor Create;
    destructor Destroy; override;
    function LoadFromFile(const AFileName: string): Boolean;
    property Current: TMNoteEditorTheme read FCurrent;
  end;

implementation

uses
  fpjson, jsonparser;

procedure TMNoteEditorTheme.Assign(ASource: TMNoteEditorTheme);
begin
  if ASource = nil then Exit;
  Name := ASource.Name;
  EditorBackground := ASource.EditorBackground;
  EditorForeground := ASource.EditorForeground;
  SelectionBackground := ASource.SelectionBackground;
  SelectionForeground := ASource.SelectionForeground;
  CurrentLine := ASource.CurrentLine;
  GutterBackground := ASource.GutterBackground;
  CommentColor := ASource.CommentColor;
  KeywordColor := ASource.KeywordColor;
  StringColor := ASource.StringColor;
  NumberColor := ASource.NumberColor;
  IdentifierColor := ASource.IdentifierColor;
  SymbolColor := ASource.SymbolColor;
end;

constructor TMNoteEditorThemeService.Create;
begin
  inherited Create;
  FCurrent := TMNoteEditorTheme.Create;
  LoadFallback;
end;

destructor TMNoteEditorThemeService.Destroy;
begin
  FCurrent.Free;
  inherited Destroy;
end;

procedure TMNoteEditorThemeService.LoadFallback;
begin
  FCurrent.Name := 'Light';
  FCurrent.EditorBackground := $FFFFFF;
  FCurrent.EditorForeground := $1E1E1E;
  FCurrent.SelectionBackground := $FFD6AD;
  FCurrent.SelectionForeground := $000000;
  FCurrent.CurrentLine := $F3F3F3;
  FCurrent.GutterBackground := $F7F7F7;
  FCurrent.CommentColor := $008000;
  FCurrent.KeywordColor := $FF0000;
  FCurrent.StringColor := $1515A3;
  FCurrent.NumberColor := $588609;
  FCurrent.IdentifierColor := $1E1E1E;
  FCurrent.SymbolColor := $000000;
end;

function TMNoteEditorThemeService.ParseColor(const AValue: string;
  ADefault: LongInt): LongInt;
var
  R, G, B: LongInt;
begin
  Result := ADefault;
  if (Length(AValue) <> 7) or (AValue[1] <> '#') then Exit;
  if not TryStrToInt('$' + Copy(AValue, 2, 2), R) then Exit;
  if not TryStrToInt('$' + Copy(AValue, 4, 2), G) then Exit;
  if not TryStrToInt('$' + Copy(AValue, 6, 2), B) then Exit;
  Result := R or (G shl 8) or (B shl 16);
end;

function TMNoteEditorThemeService.LoadFromFile(
  const AFileName: string): Boolean;
var
  Source: TStringList;
  Data: TJSONData;
  ThemeObject: TJSONObject;
begin
  ClearError;
  Result := False;
  LoadFallback;
  if not FileExists(AFileName) then
  begin
    SetError('Arquivo de tema não encontrado: ' + AFileName);
    Exit;
  end;
  Source := TStringList.Create;
  Data := nil;
  try
    try
      Source.LoadFromFile(AFileName);
      Data := GetJSON(Source.Text);
      if Data.JSONType <> jtObject then
        raise Exception.Create('A raiz do tema deve ser um objeto JSON.');
      ThemeObject := TJSONObject(Data);
      FCurrent.Name := ThemeObject.Get('name', FCurrent.Name);
      FCurrent.EditorBackground := ParseColor(
        ThemeObject.Get('editor_background', ''), FCurrent.EditorBackground);
      FCurrent.EditorForeground := ParseColor(
        ThemeObject.Get('editor_foreground', ''), FCurrent.EditorForeground);
      FCurrent.SelectionBackground := ParseColor(
        ThemeObject.Get('selection_background', ''), FCurrent.SelectionBackground);
      FCurrent.SelectionForeground := ParseColor(
        ThemeObject.Get('selection_foreground', ''), FCurrent.SelectionForeground);
      FCurrent.CurrentLine := ParseColor(ThemeObject.Get('current_line', ''),
        FCurrent.CurrentLine);
      FCurrent.GutterBackground := ParseColor(
        ThemeObject.Get('gutter_background', ''), FCurrent.GutterBackground);
      FCurrent.CommentColor := ParseColor(ThemeObject.Get('comment', ''),
        FCurrent.CommentColor);
      FCurrent.KeywordColor := ParseColor(ThemeObject.Get('keyword', ''),
        FCurrent.KeywordColor);
      FCurrent.StringColor := ParseColor(ThemeObject.Get('string', ''),
        FCurrent.StringColor);
      FCurrent.NumberColor := ParseColor(ThemeObject.Get('number', ''),
        FCurrent.NumberColor);
      FCurrent.IdentifierColor := ParseColor(ThemeObject.Get('identifier', ''),
        FCurrent.IdentifierColor);
      FCurrent.SymbolColor := ParseColor(ThemeObject.Get('symbol', ''),
        FCurrent.SymbolColor);
      Result := True;
    except
      on E: Exception do
      begin
        LoadFallback;
        SetError('Tema inválido; fallback Light aplicado: ' + E.Message);
      end;
    end;
  finally
    Data.Free;
    Source.Free;
  end;
end;

end.
