unit mnote_language_profile;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils;

type
  TMNoteHighlighterKind = (hkNone, hkPascal, hkPython, hkSQL, hkJavaScript,
    hkCSS, hkHTML, hkXML, hkINI, hkPHP, hkCpp, hkJava, hkShell, hkBat,
    hkGeneric);

  { TMNoteLanguageProfile }

  TMNoteLanguageProfile = class
  private
    FID: string;
    FName: string;
    FExtensions: TStringList;
    FIconIndex: Integer;
    FKeywords: TStringList;
    FSnippets: TStringList;
    FLineComment: string;
    FBlockCommentStart: string;
    FBlockCommentEnd: string;
    FTabWidth: Integer;
    FUseTabs: Boolean;
    FAutoIndent: Boolean;
    FTokenCharacters: string;
    FCommands: TStringList;
    FLegacyType: Integer;
    FHighlighterKind: TMNoteHighlighterKind;
  public
    constructor Create(const AID, AName, AExtensions: string;
      ALegacyType: Integer; AHighlighterKind: TMNoteHighlighterKind;
      const ALineComment, ABlockCommentStart, ABlockCommentEnd: string;
      ATabWidth: Integer; AUseTabs, AAutoIndent: Boolean;
      const ATokenCharacters, ACommands: string; AIconIndex: Integer = -1);
    destructor Destroy; override;
    function SupportsExtension(const AExtension: string): Boolean;
    property ID: string read FID;
    property Name: string read FName;
    property Extensions: TStringList read FExtensions;
    property IconIndex: Integer read FIconIndex;
    property Keywords: TStringList read FKeywords;
    property Snippets: TStringList read FSnippets;
    property LineComment: string read FLineComment;
    property BlockCommentStart: string read FBlockCommentStart;
    property BlockCommentEnd: string read FBlockCommentEnd;
    property TabWidth: Integer read FTabWidth;
    property UseTabs: Boolean read FUseTabs;
    property AutoIndent: Boolean read FAutoIndent;
    property TokenCharacters: string read FTokenCharacters;
    property Commands: TStringList read FCommands;
    property LegacyType: Integer read FLegacyType;
    property HighlighterKind: TMNoteHighlighterKind read FHighlighterKind;
  end;

implementation

procedure ParseSemicolonList(const AText: string; AList: TStringList);
begin
  AList.Clear;
  AList.StrictDelimiter := True;
  AList.Delimiter := ';';
  AList.DelimitedText := AText;
end;

constructor TMNoteLanguageProfile.Create(const AID, AName,
  AExtensions: string; ALegacyType: Integer;
  AHighlighterKind: TMNoteHighlighterKind; const ALineComment,
  ABlockCommentStart, ABlockCommentEnd: string; ATabWidth: Integer;
  AUseTabs, AAutoIndent: Boolean; const ATokenCharacters, ACommands: string;
  AIconIndex: Integer);
begin
  inherited Create;
  FID := AID;
  FName := AName;
  FLegacyType := ALegacyType;
  FHighlighterKind := AHighlighterKind;
  FLineComment := ALineComment;
  FBlockCommentStart := ABlockCommentStart;
  FBlockCommentEnd := ABlockCommentEnd;
  FTabWidth := ATabWidth;
  FUseTabs := AUseTabs;
  FAutoIndent := AAutoIndent;
  FTokenCharacters := ATokenCharacters;
  FIconIndex := AIconIndex;
  FExtensions := TStringList.Create;
  FKeywords := TStringList.Create;
  FSnippets := TStringList.Create;
  FCommands := TStringList.Create;
  ParseSemicolonList(LowerCase(AExtensions), FExtensions);
  ParseSemicolonList(ACommands, FCommands);
end;

destructor TMNoteLanguageProfile.Destroy;
begin
  FCommands.Free;
  FSnippets.Free;
  FKeywords.Free;
  FExtensions.Free;
  inherited Destroy;
end;

function TMNoteLanguageProfile.SupportsExtension(
  const AExtension: string): Boolean;
var
  Extension: string;
begin
  Extension := LowerCase(Trim(AExtension));
  if (Extension <> '') and (Extension[1] <> '.') then
    Extension := '.' + Extension;
  Result := FExtensions.IndexOf(Extension) >= 0;
end;

end.
