unit mnote_language_registry;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs, mnote_language_profile;

type
  { TMNoteLanguageRegistry }

  TMNoteLanguageRegistry = class
  private
    FProfiles: TObjectList;
    function GetCount: Integer;
    function GetProfile(AIndex: Integer): TMNoteLanguageProfile;
  public
    constructor Create(ARegisterDefaults: Boolean = True);
    destructor Destroy; override;
    procedure RegisterDefaults;
    function RegisterProfile(AProfile: TMNoteLanguageProfile): Integer;
    function FindByID(const AID: string): TMNoteLanguageProfile;
    function FindByExtension(const AExtension: string): TMNoteLanguageProfile;
    property Count: Integer read GetCount;
    property Profiles[AIndex: Integer]: TMNoteLanguageProfile
      read GetProfile; default;
  end;

function MNoteLanguages: TMNoteLanguageRegistry;

implementation

var
  GLanguages: TMNoteLanguageRegistry;

constructor TMNoteLanguageRegistry.Create(ARegisterDefaults: Boolean);
begin
  inherited Create;
  FProfiles := TObjectList.Create(True);
  if ARegisterDefaults then RegisterDefaults;
end;

destructor TMNoteLanguageRegistry.Destroy;
begin
  FProfiles.Free;
  inherited Destroy;
end;

function TMNoteLanguageRegistry.GetCount: Integer;
begin
  Result := FProfiles.Count;
end;

function TMNoteLanguageRegistry.GetProfile(
  AIndex: Integer): TMNoteLanguageProfile;
begin
  Result := TMNoteLanguageProfile(FProfiles[AIndex]);
end;

function TMNoteLanguageRegistry.RegisterProfile(
  AProfile: TMNoteLanguageProfile): Integer;
begin
  if AProfile = nil then
    raise Exception.Create('O perfil de linguagem não pode ser nulo.');
  if FindByID(AProfile.ID) <> nil then
    raise Exception.CreateFmt('Perfil de linguagem duplicado: %s',
      [AProfile.ID]);
  Result := FProfiles.Add(AProfile);
end;

function TMNoteLanguageRegistry.FindByID(
  const AID: string): TMNoteLanguageProfile;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FProfiles.Count - 1 do
    if SameText(Profiles[I].ID, AID) then Exit(Profiles[I]);
end;

function TMNoteLanguageRegistry.FindByExtension(
  const AExtension: string): TMNoteLanguageProfile;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FProfiles.Count - 1 do
    if Profiles[I].SupportsExtension(AExtension) then Exit(Profiles[I]);
  Result := FindByID('text');
end;

procedure TMNoteLanguageRegistry.RegisterDefaults;

  procedure Add(const AID, AName, AExtensions: string; ALegacyType: Integer;
    AHighlighter: TMNoteHighlighterKind; const ALine, ABlockStart,
    ABlockEnd: string; ATabWidth: Integer; AUseTabs: Boolean;
    const ATokens, ACommands: string);
  begin
    RegisterProfile(TMNoteLanguageProfile.Create(AID, AName, AExtensions,
      ALegacyType, AHighlighter, ALine, ABlockStart, ABlockEnd, ATabWidth,
      AUseTabs, True, ATokens, ACommands));
  end;

begin
  Add('pascal', 'Pascal', '.pas;.pp;.lpr;.lpk;.inc', 4, hkPascal, '//',
    '{', '}', 2, False, '._',
    'outline.show;project.build;project.run;symbol.navigate;editor.toggle_comment');
  Add('python', 'Python', '.py;.pyw', 10, hkPython, '#', '', '', 4, False,
    '._', 'python.run;python.stop;python.environment;output.show;variables.show;editor.toggle_comment');
  Add('sql', 'SQL', '.sql', 9, hkSQL, '--', '/*', '*/', 2, False, '._',
    'database.show;sql.execute;sql.explain;database.dictionary;output.show;editor.toggle_comment');
  Add('javascript', 'JavaScript', '.js;.mjs;.cjs;.ts;.tsx', 13,
    hkJavaScript, '//', '/*', '*/', 2, False, '._$',
    'web.preview;project.run;editor.toggle_comment');
  Add('html', 'HTML', '.html;.htm', 14, hkHTML, '', '<!--', '-->', 2,
    False, '.-_', 'web.preview;document.format;document.validate');
  Add('css', 'CSS', '.css;.scss', 15, hkCSS, '', '/*', '*/', 2, False,
    '.-#_', 'web.preview;document.format');
  Add('php', 'PHP', '.php;.phtml', 11, hkPHP, '//', '/*', '*/', 2, False,
    '._$', 'web.preview;project.run');
  Add('json', 'JSON', '.json', 16, hkJavaScript, '', '', '', 2, False,
    '._-', 'document.format;document.validate');
  Add('xml', 'XML', '.xml;.xsd;.xsl;.svg', 17, hkXML, '', '<!--', '-->',
    2, False, '.:-_', 'document.format;document.validate');
  Add('yaml', 'YAML', '.yaml;.yml', 18, hkGeneric, '#', '', '', 2, False,
    '.-_', 'document.format;document.validate');
  Add('ini', 'INI', '.ini;.cfg', 19, hkINI, ';', '', '', 2, False,
    '.-_', 'document.format;document.validate');
  Add('markdown', 'Markdown', '.md;.markdown', 20, hkGeneric, '', '<!--',
    '-->', 2, False, '.-_', 'web.preview;document.format');
  Add('cpp', 'C/C++', '.c;.cc;.cpp;.cxx;.h;.hpp', 3, hkCpp, '//', '/*',
    '*/', 2, False, '._:', 'project.build;project.run;symbol.navigate');
  Add('java', 'Java', '.java', 12, hkJava, '//', '/*', '*/', 4, False,
    '._', 'project.build;project.run;symbol.navigate');
  Add('shell', 'Shell', '.sh;.bash', 22, hkShell, '#', '', '', 2, False,
    '._-', 'project.run');
  Add('batch', 'Batch', '.bat;.cmd', 6, hkBat, 'rem ', '', '', 4, False,
    '._-', 'project.run');
  Add('text', 'Text', '.txt;.log;.conf', 8, hkNone, '', '', '', 4, False,
    '._-', 'document.format');
end;

function MNoteLanguages: TMNoteLanguageRegistry;
begin
  if GLanguages = nil then
    GLanguages := TMNoteLanguageRegistry.Create(True);
  Result := GLanguages;
end;

finalization
  FreeAndNil(GLanguages);

end.
