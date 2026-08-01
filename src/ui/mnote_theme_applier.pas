unit mnote_theme_applier;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Graphics, SynEdit, SynEditHighlighter, mnote_editor_theme;

type
  TMNoteThemeApplier = class
  public
    class procedure Apply(AEditor: TSynEdit;
      ATheme: TMNoteEditorTheme); static;
  end;

implementation

function SemanticColor(const AName: string; ATheme: TMNoteEditorTheme): TColor;
var
  NameText: string;
begin
  NameText := LowerCase(AName);
  if Pos('comment', NameText) > 0 then
    Result := TColor(ATheme.CommentColor)
  else if (Pos('key', NameText) > 0) or (Pos('reserved', NameText) > 0) then
    Result := TColor(ATheme.KeywordColor)
  else if (Pos('string', NameText) > 0) or (Pos('text', NameText) > 0) then
    Result := TColor(ATheme.StringColor)
  else if (Pos('number', NameText) > 0) or (Pos('float', NameText) > 0) then
    Result := TColor(ATheme.NumberColor)
  else if Pos('symbol', NameText) > 0 then
    Result := TColor(ATheme.SymbolColor)
  else
    Result := TColor(ATheme.IdentifierColor);
end;

class procedure TMNoteThemeApplier.Apply(AEditor: TSynEdit;
  ATheme: TMNoteEditorTheme);
var
  I: Integer;
  Attribute: TSynHighlighterAttributes;
begin
  if (AEditor = nil) or (ATheme = nil) then Exit;
  AEditor.Color := TColor(ATheme.EditorBackground);
  AEditor.Font.Color := TColor(ATheme.EditorForeground);
  AEditor.Gutter.Color := TColor(ATheme.GutterBackground);
  AEditor.SelectedColor.Background := TColor(ATheme.SelectionBackground);
  AEditor.SelectedColor.Foreground := TColor(ATheme.SelectionForeground);
  AEditor.LineHighlightColor.Background := TColor(ATheme.CurrentLine);
  if AEditor.Highlighter <> nil then
    for I := 0 to AEditor.Highlighter.AttrCount - 1 do
    begin
      Attribute := AEditor.Highlighter.Attribute[I];
      Attribute.Foreground := SemanticColor(Attribute.Name + ' ' +
        Attribute.StoredName, ATheme);
      Attribute.Background := TColor(ATheme.EditorBackground);
    end;
  AEditor.Invalidate;
end;

end.
