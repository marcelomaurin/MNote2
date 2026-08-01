program highlighter_ownership_test;

{$mode objfpc}{$H+}

uses
  Interfaces, Classes, SysUtils, Graphics, SynEditHighlighter, mnote_language_registry,
  mnote_language_profile, mnote_highlighter_factory;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then raise Exception.Create(AMessage);
end;

var
  OwnerA, OwnerB: TComponent;
  Profile: TMNoteLanguageProfile;
  HighlighterA, HighlighterB: TSynCustomHighlighter;
  OriginalColor, NewColor: TColor;
begin
  OwnerA := TComponent.Create(nil);
  OwnerB := TComponent.Create(nil);
  try
    Profile := MNoteLanguages.FindByID('pascal');
    HighlighterA := TMNoteHighlighterFactory.CreateHighlighter(OwnerA, Profile);
    HighlighterB := TMNoteHighlighterFactory.CreateHighlighter(OwnerB, Profile);
    Check((HighlighterA <> nil) and (HighlighterB <> nil),
      'A fábrica não criou os highlighters Pascal.');
    Check(HighlighterA <> HighlighterB,
      'Abas diferentes não podem compartilhar highlighter mutável.');
    Check((HighlighterA.Owner = OwnerA) and (HighlighterB.Owner = OwnerB),
      'O ownership do highlighter não pertence à aba lógica.');
    Check((OwnerA.ComponentCount = 1) and (OwnerB.ComponentCount = 1),
      'O owner não registrou exatamente seu highlighter.');
    if (HighlighterA.AttrCount > 0) and (HighlighterB.AttrCount > 0) then
    begin
      OriginalColor := HighlighterB.Attribute[0].Foreground;
      if OriginalColor = clRed then NewColor := clBlue else NewColor := clRed;
      HighlighterA.Attribute[0].Foreground := NewColor;
      Check(HighlighterB.Attribute[0].Foreground = OriginalColor,
        'Atributos visuais vazaram entre duas abas.');
    end;
  finally
    OwnerB.Free;
    OwnerA.Free;
  end;
  Writeln('OK: highlighters distintos, ownership por aba e sem estado cruzado');
end.
