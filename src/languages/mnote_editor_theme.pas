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
    procedure LoadBuiltInTheme(const AName: string);
    function LoadFromFile(const AFileName: string): Boolean;
    function LoadTheme(const AThemeName: string; const AFileName: string = ''): Boolean;
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
  LoadBuiltInTheme('Light');
end;

procedure TMNoteEditorThemeService.LoadBuiltInTheme(const AName: string);
var
  ThemeUpper: string;
begin
  ThemeUpper := UpperCase(Trim(AName));
  if ThemeUpper = 'DARK' then
  begin
    FCurrent.Name := 'Dark';
    FCurrent.EditorBackground := ParseColor('#1E1E1E', 0);
    FCurrent.EditorForeground := ParseColor('#D4D4D4', 0);
    FCurrent.SelectionBackground := ParseColor('#264F78', 0);
    FCurrent.SelectionForeground := ParseColor('#FFFFFF', 0);
    FCurrent.CurrentLine := ParseColor('#2A2D2E', 0);
    FCurrent.GutterBackground := ParseColor('#252526', 0);
    FCurrent.CommentColor := ParseColor('#6A9955', 0);
    FCurrent.KeywordColor := ParseColor('#569CD6', 0);
    FCurrent.StringColor := ParseColor('#CE9178', 0);
    FCurrent.NumberColor := ParseColor('#B5CEA8', 0);
    FCurrent.IdentifierColor := ParseColor('#D4D4D4', 0);
    FCurrent.SymbolColor := ParseColor('#D4D4D4', 0);
  end
  else if ThemeUpper = 'BLUE' then
  begin
    FCurrent.Name := 'Blue';
    FCurrent.EditorBackground := ParseColor('#FFFFFF', 0);
    FCurrent.EditorForeground := ParseColor('#1E1E1E', 0);
    FCurrent.SelectionBackground := ParseColor('#3399FF', 0);
    FCurrent.SelectionForeground := ParseColor('#FFFFFF', 0);
    FCurrent.CurrentLine := ParseColor('#EAF2F8', 0);
    FCurrent.GutterBackground := ParseColor('#DCE6F1', 0);
    FCurrent.CommentColor := ParseColor('#008000', 0);
    FCurrent.KeywordColor := ParseColor('#0000FF', 0);
    FCurrent.StringColor := ParseColor('#A31515', 0);
    FCurrent.NumberColor := ParseColor('#098658', 0);
    FCurrent.IdentifierColor := ParseColor('#1E1E1E', 0);
    FCurrent.SymbolColor := ParseColor('#000000', 0);
  end
  else
  begin
    FCurrent.Name := 'Light';
    FCurrent.EditorBackground := ParseColor('#FFFFFF', 0);
    FCurrent.EditorForeground := ParseColor('#1E1E1E', 0);
    FCurrent.SelectionBackground := ParseColor('#ADD6FF', 0);
    FCurrent.SelectionForeground := ParseColor('#000000', 0);
    FCurrent.CurrentLine := ParseColor('#F3F3F3', 0);
    FCurrent.GutterBackground := ParseColor('#F7F7F7', 0);
    FCurrent.CommentColor := ParseColor('#008000', 0);
    FCurrent.KeywordColor := ParseColor('#0000FF', 0);
    FCurrent.StringColor := ParseColor('#A31515', 0);
    FCurrent.NumberColor := ParseColor('#098658', 0);
    FCurrent.IdentifierColor := ParseColor('#1E1E1E', 0);
    FCurrent.SymbolColor := ParseColor('#000000', 0);
  end;
end;

function TMNoteEditorThemeService.LoadTheme(const AThemeName: string; const AFileName: string): Boolean;
begin
  ClearError;
  if (AFileName <> '') and FileExists(AFileName) then
  begin
    Result := LoadFromFile(AFileName);
    if Result then Exit;
  end;

  LoadBuiltInTheme(AThemeName);
  Result := True;
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
