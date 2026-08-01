unit mnote_highlighter_factory;

{$mode objfpc}{$H+}

interface

uses
  Classes, SynEditHighlighter, mnote_language_profile;

type
  TMNoteHighlighterFactory = class
  public
    class function CreateHighlighter(AOwner: TComponent;
      AProfile: TMNoteLanguageProfile): TSynCustomHighlighter; static;
    class function ClassNameFor(AKind: TMNoteHighlighterKind): string; static;
  end;

implementation

uses
  SynHighlighterPas, SynHighlighterPython, SynHighlighterSQL,
  SynHighlighterJScript, SynHighlighterCss, SynHighlighterHTML,
  SynHighlighterXML, SynHighlighterIni, SynHighlighterPHP,
  SynHighlighterCpp, SynHighlighterJava, SynHighlighterUnixShellScript,
  SynHighlighterBat, SynHighlighterAny;

class function TMNoteHighlighterFactory.CreateHighlighter(AOwner: TComponent;
  AProfile: TMNoteLanguageProfile): TSynCustomHighlighter;
begin
  Result := nil;
  if AProfile = nil then Exit;
  case AProfile.HighlighterKind of
    hkPascal: Result := TSynPasSyn.Create(AOwner);
    hkPython: Result := TSynPythonSyn.Create(AOwner);
    hkSQL: Result := TSynSQLSyn.Create(AOwner);
    hkJavaScript: Result := TSynJScriptSyn.Create(AOwner);
    hkCSS: Result := TSynCssSyn.Create(AOwner);
    hkHTML: Result := TSynHTMLSyn.Create(AOwner);
    hkXML: Result := TSynXMLSyn.Create(AOwner);
    hkINI: Result := TSynIniSyn.Create(AOwner);
    hkPHP: Result := TSynPHPSyn.Create(AOwner);
    hkCpp: Result := TSynCppSyn.Create(AOwner);
    hkJava: Result := TSynJavaSyn.Create(AOwner);
    hkShell: Result := TSynUNIXShellScriptSyn.Create(AOwner);
    hkBat: Result := TSynBatSyn.Create(AOwner);
    hkGeneric: Result := TSynAnySyn.Create(AOwner);
  end;
end;

class function TMNoteHighlighterFactory.ClassNameFor(
  AKind: TMNoteHighlighterKind): string;
begin
  case AKind of
    hkPascal: Result := 'TSynPasSyn';
    hkPython: Result := 'TSynPythonSyn';
    hkSQL: Result := 'TSynSQLSyn';
    hkJavaScript: Result := 'TSynJScriptSyn';
    hkCSS: Result := 'TSynCssSyn';
    hkHTML: Result := 'TSynHTMLSyn';
    hkXML: Result := 'TSynXMLSyn';
    hkINI: Result := 'TSynIniSyn';
    hkPHP: Result := 'TSynPHPSyn';
    hkCpp: Result := 'TSynCppSyn';
    hkJava: Result := 'TSynJavaSyn';
    hkShell: Result := 'TSynUNIXShellScriptSyn';
    hkBat: Result := 'TSynBatSyn';
    hkGeneric: Result := 'TSynAnySyn (fallback genérico)';
  else
    Result := 'Sem highlighter';
  end;
end;

end.
