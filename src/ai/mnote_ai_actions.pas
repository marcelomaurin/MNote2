unit mnote_ai_actions;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Contnrs, fpjson, jsonparser, mnote_ai_types,
  mnote_process_service, aiagentsafety;

type
  TMNoteAIActionEffect = (aaeReadOnly, aaeBuildArtifact, aaeSourceWrite,
    aaeExternalWrite);

  { TMNoteAIActionDescriptor }

  TMNoteAIActionDescriptor = class
  private
    FParameters: TStringList;
  public
    Name: string;
    Effect: TMNoteAIActionEffect;
    MaxOutputChars: Integer;
    RequiresConfirmation: Boolean;
    constructor Create(const AName: string; AEffect: TMNoteAIActionEffect;
      AMaxOutputChars: Integer; ARequiresConfirmation: Boolean);
    destructor Destroy; override;
    procedure AddParameter(const AName: string);
    function AcceptsParameter(const AName: string): Boolean;
    property Parameters: TStringList read FParameters;
  end;

  TMNoteAIActionConfirmEvent = function(Sender: TObject;
    ADescriptor: TMNoteAIActionDescriptor; AParameters: TJSONObject;
    out AReason: string): Boolean of object;
  TMNoteAIDictionaryEvent = function(Sender: TObject; out AJSON,
    AError: string): Boolean of object;
  TMNoteAIActionLogEvent = procedure(Sender: TObject;
    const ALogJSON: string) of object;

  { TMNoteAIActionExecutor }

  TMNoteAIActionExecutor = class
  private
    FRootPath: string;
    FActions: TObjectList;
    FProcess: TMNoteProcessService;
    FSafety: TAIAgentSafety;
    FOnConfirm: TMNoteAIActionConfirmEvent;
    FOnGetDictionary: TMNoteAIDictionaryEvent;
    FOnLog: TMNoteAIActionLogEvent;
    function FindAction(const AName: string): TMNoteAIActionDescriptor;
    function ParseRequest(const AJSON: string;
      out ADescriptor: TMNoteAIActionDescriptor;
      out AParameters: TJSONObject; out AData: TJSONData;
      out AError: string): Boolean;
    function RoleMayExecute(ARole: TMNoteAIRole;
      ADescriptor: TMNoteAIActionDescriptor): Boolean;
    function ResolveProjectFile(const AValue: string; out AFileName,
      AError: string): Boolean;
    function ExecuteReadFile(AParameters: TJSONObject; out AData: TJSONData;
      out ATruncated: Boolean; out AError: string): Boolean;
    function ExecuteSearchProject(AParameters: TJSONObject;
      out AData: TJSONData; out ATruncated: Boolean;
      out AError: string): Boolean;
    function ExecuteListSymbols(AParameters: TJSONObject;
      out AData: TJSONData; out ATruncated: Boolean;
      out AError: string): Boolean;
    function ExecuteListProjectFiles(AParameters: TJSONObject;
      out AData: TJSONData; out ATruncated: Boolean;
      out AError: string): Boolean;
    function ExecuteGitLog(AParameters: TJSONObject; out AData: TJSONData;
      out ATruncated: Boolean; out AError: string): Boolean;
    function ExecuteGitDiff(AParameters: TJSONObject; out AData: TJSONData;
      out ATruncated: Boolean; out AError: string): Boolean;
    function ExecuteDictionary(out AData: TJSONData;
      out ATruncated: Boolean; out AError: string): Boolean;
    function ExecuteCompile(AParameters: TJSONObject; out AData: TJSONData;
      out ATruncated: Boolean; out AError: string): Boolean;
    function LimitText(const AText: string; AMax: Integer;
      out ATruncated: Boolean): string;
    function ResultJSON(const AAction: string; ASuccess,
      ATruncated: Boolean; AData: TJSONData; const AError: string): string;
    procedure LogResult(const AAction: string; ARole: TMNoteAIRole;
      ASuccess, ATruncated: Boolean; const AError: string);
    procedure RegisterActions;
  public
    constructor Create(const ARootPath: string);
    destructor Destroy; override;
    function DescribeActions: string;
    function ExecuteRequest(const ARequestJSON: string; ARole: TMNoteAIRole;
      out AResultJSON, AError: string): Boolean;
    procedure Cancel;
    property RootPath: string read FRootPath;
    property Safety: TAIAgentSafety read FSafety;
    property OnConfirm: TMNoteAIActionConfirmEvent read FOnConfirm
      write FOnConfirm;
    property OnGetDictionary: TMNoteAIDictionaryEvent read FOnGetDictionary
      write FOnGetDictionary;
    property OnLog: TMNoteAIActionLogEvent read FOnLog write FOnLog;
  end;

function MNoteAIActionEffectName(AEffect: TMNoteAIActionEffect): string;

implementation

uses
  StrUtils, mnote_search_types, mnote_file_search_service,
  mnote_completion_types, mnote_project_symbol_index,
  mnote_git_read_service, mnote_build_service, mnote_diagnostics;

function MNoteAIActionEffectName(AEffect: TMNoteAIActionEffect): string;
begin
  case AEffect of
    aaeBuildArtifact: Result := 'build_artifact';
    aaeSourceWrite: Result := 'source_write';
    aaeExternalWrite: Result := 'external_write';
  else
    Result := 'read_only';
  end;
end;

function JSONString(AObject: TJSONObject; const AName,
  ADefault: string): string;
var
  Value: TJSONData;
begin
  Result := ADefault;
  if AObject = nil then Exit;
  Value := AObject.Find(AName);
  if (Value <> nil) and (Value.JSONType = jtString) then Result := Value.AsString;
end;

function JSONInteger(AObject: TJSONObject; const AName: string;
  ADefault: Integer): Integer;
var
  Value: TJSONData;
begin
  Result := ADefault;
  if AObject = nil then Exit;
  Value := AObject.Find(AName);
  if (Value <> nil) and (Value.JSONType = jtNumber) then Result := Value.AsInteger;
end;

function JSONBoolean(AObject: TJSONObject; const AName: string;
  ADefault: Boolean): Boolean;
var
  Value: TJSONData;
begin
  Result := ADefault;
  if AObject = nil then Exit;
  Value := AObject.Find(AName);
  if (Value <> nil) and (Value.JSONType = jtBoolean) then Result := Value.AsBoolean;
end;

function IsSensitivePath(const AFileName: string): Boolean;
var
  Value, BaseName, Extension: string;
begin
  Value := LowerCase(StringReplace(AFileName, '\', '/', [rfReplaceAll]));
  BaseName := LowerCase(ExtractFileName(AFileName));
  Extension := LowerCase(ExtractFileExt(AFileName));
  Result := (Pos('/.git/', '/' + Value + '/') > 0) or
    (BaseName = '.env') or AnsiStartsStr('.env.', BaseName) or
    (Pos('credential', BaseName) > 0) or (Pos('secret', BaseName) > 0) or
    (BaseName = 'id_rsa') or (BaseName = 'id_ed25519') or
    (Extension = '.key') or (Extension = '.pfx') or
    (Extension = '.p12') or (Extension = '.pem');
end;

function IsAllowedTextExtension(const AFileName: string): Boolean;
const
  ALLOWED_EXTENSIONS: array[0..19] of string = ('.pas', '.pp', '.inc',
    '.lpr', '.lpi', '.lpk', '.json', '.md', '.txt', '.sql', '.py', '.c',
    '.h', '.cpp', '.hpp', '.ini', '.cfg', '.xml', '.yml', '.sh');
var
  Extension: string;
  I: Integer;
begin
  Result := False;
  Extension := LowerCase(ExtractFileExt(AFileName));
  for I := Low(ALLOWED_EXTENSIONS) to High(ALLOWED_EXTENSIONS) do
    if Extension = ALLOWED_EXTENSIONS[I] then Exit(True);
end;

function HasSymbolicPathPart(const ARoot, AFileName: string): Boolean;
var
  RelativeName, CurrentName: string;
  Parts: TStringList;
  I, Attributes: Integer;
begin
  Result := False;
  RelativeName := Copy(AFileName,
    Length(IncludeTrailingPathDelimiter(ARoot)) + 1, MaxInt);
  RelativeName := StringReplace(RelativeName, '\', '/', [rfReplaceAll]);
  Parts := TStringList.Create;
  try
    Parts.StrictDelimiter := True;
    Parts.Delimiter := '/';
    Parts.DelimitedText := RelativeName;
    CurrentName := ExcludeTrailingPathDelimiter(ARoot);
    for I := 0 to Parts.Count - 1 do
    begin
      if Parts[I] = '' then Continue;
      CurrentName := IncludeTrailingPathDelimiter(CurrentName) + Parts[I];
      Attributes := FileGetAttr(CurrentName);
      {$IF declared(faSymLink)}
      if (Attributes <> -1) and ((Attributes and faSymLink) <> 0) then
        Exit(True);
      {$ENDIF}
    end;
  finally
    Parts.Free;
  end;
end;

function ExistingFileSize(const AFileName: string): Int64;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    Result := Stream.Size;
  finally
    Stream.Free;
  end;
end;

constructor TMNoteAIActionDescriptor.Create(const AName: string;
  AEffect: TMNoteAIActionEffect; AMaxOutputChars: Integer;
  ARequiresConfirmation: Boolean);
begin
  inherited Create;
  Name := AName;
  Effect := AEffect;
  MaxOutputChars := AMaxOutputChars;
  RequiresConfirmation := ARequiresConfirmation;
  FParameters := TStringList.Create;
  FParameters.CaseSensitive := False;
  FParameters.Sorted := True;
  FParameters.Duplicates := dupIgnore;
end;

destructor TMNoteAIActionDescriptor.Destroy;
begin
  FParameters.Free;
  inherited Destroy;
end;

procedure TMNoteAIActionDescriptor.AddParameter(const AName: string);
begin
  FParameters.Add(AName);
end;

function TMNoteAIActionDescriptor.AcceptsParameter(
  const AName: string): Boolean;
begin
  Result := FParameters.IndexOf(AName) >= 0;
end;

constructor TMNoteAIActionExecutor.Create(const ARootPath: string);
begin
  inherited Create;
  FRootPath := ExcludeTrailingPathDelimiter(ExpandFileName(ARootPath));
  FActions := TObjectList.Create(True);
  FProcess := TMNoteProcessService.Create;
  FSafety := TAIAgentSafety.Create(nil);
  FSafety.Enabled := True;
  FSafety.SimulationMode := False;
  FSafety.ReadOnlyMode := True;
  FSafety.RequireConfirmation := False;
  FSafety.SafeBasePath := FRootPath;
  RegisterActions;
end;

destructor TMNoteAIActionExecutor.Destroy;
begin
  FSafety.Free;
  FProcess.Free;
  FActions.Free;
  inherited Destroy;
end;

procedure TMNoteAIActionExecutor.RegisterActions;
var
  Action: TMNoteAIActionDescriptor;
  I: Integer;
begin
  Action := TMNoteAIActionDescriptor.Create('ReadFile', aaeReadOnly,
    20000, False);
  Action.AddParameter('path');
  Action.AddParameter('max_chars');
  Action.AddParameter('offset_chars');
  Action.AddParameter('start_line');
  Action.AddParameter('end_line');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('SearchProject', aaeReadOnly,
    16000, False);
  Action.AddParameter('query');
  Action.AddParameter('include');
  Action.AddParameter('exclude');
  Action.AddParameter('regex');
  Action.AddParameter('match_case');
  Action.AddParameter('whole_word');
  Action.AddParameter('max_results');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('ListSymbols', aaeReadOnly,
    16000, False);
  Action.AddParameter('max_results');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('ListProjectFiles', aaeReadOnly,
    20000, False);
  Action.AddParameter('include');
  Action.AddParameter('exclude');
  Action.AddParameter('max_results');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('GitLog', aaeReadOnly,
    12000, False);
  Action.AddParameter('count');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('GitDiff', aaeReadOnly,
    24000, False);
  Action.AddParameter('commit');
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('DBDictionary', aaeReadOnly,
    24000, False);
  FActions.Add(Action);

  Action := TMNoteAIActionDescriptor.Create('Compile', aaeBuildArtifact,
    30000, True);
  Action.AddParameter('rebuild');
  FActions.Add(Action);

  FSafety.AllowedActions.Clear;
  for I := 0 to FActions.Count - 1 do
    FSafety.AllowedActions.Add(TMNoteAIActionDescriptor(FActions[I]).Name);
end;

function TMNoteAIActionExecutor.FindAction(
  const AName: string): TMNoteAIActionDescriptor;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FActions.Count - 1 do
    if SameText(TMNoteAIActionDescriptor(FActions[I]).Name, AName) then
      Exit(TMNoteAIActionDescriptor(FActions[I]));
end;

function TMNoteAIActionExecutor.ParseRequest(const AJSON: string;
  out ADescriptor: TMNoteAIActionDescriptor; out AParameters: TJSONObject;
  out AData: TJSONData; out AError: string): Boolean;
var
  Root: TJSONObject;
  Value: TJSONData;
  I: Integer;
begin
  Result := False;
  ADescriptor := nil;
  AParameters := nil;
  AData := nil;
  AError := '';
  if (Trim(AJSON) = '') or (Trim(AJSON)[1] <> '{') or
    (Trim(AJSON)[Length(Trim(AJSON))] <> '}') then
  begin
    AError := 'A solicitação deve conter somente um objeto JSON.';
    Exit;
  end;
  try
    AData := GetJSON(AJSON);
  except
    on E: Exception do
    begin
      AError := 'JSON de ação inválido: ' + E.Message;
      Exit;
    end;
  end;
  if not (AData is TJSONObject) then
  begin
    AError := 'A raiz da ação deve ser um objeto JSON.';
    FreeAndNil(AData);
    Exit;
  end;
  Root := TJSONObject(AData);
  for I := 0 to Root.Count - 1 do
    if (Root.Names[I] <> 'action') and (Root.Names[I] <> 'parameters') then
    begin
      AError := 'Campo desconhecido na ação: ' + Root.Names[I];
      FreeAndNil(AData);
      Exit;
    end;
  Value := Root.Find('action');
  if (Value = nil) or (Value.JSONType <> jtString) then
  begin
    AError := 'O campo action é obrigatório e deve ser texto.';
    FreeAndNil(AData);
    Exit;
  end;
  ADescriptor := FindAction(Value.AsString);
  if ADescriptor = nil then
  begin
    AError := 'Ação não autorizada: ' + Value.AsString;
    FreeAndNil(AData);
    Exit;
  end;
  Value := Root.Find('parameters');
  if (Value = nil) or not (Value is TJSONObject) then
  begin
    AError := 'O campo parameters é obrigatório e deve ser um objeto.';
    FreeAndNil(AData);
    Exit;
  end;
  AParameters := TJSONObject(Value);
  for I := 0 to AParameters.Count - 1 do
    if not ADescriptor.AcceptsParameter(AParameters.Names[I]) then
    begin
      AError := 'Parâmetro não declarado para ' + ADescriptor.Name + ': ' +
        AParameters.Names[I];
      AParameters := nil;
      FreeAndNil(AData);
      Exit;
    end;
  Result := True;
end;

function TMNoteAIActionExecutor.RoleMayExecute(ARole: TMNoteAIRole;
  ADescriptor: TMNoteAIActionDescriptor): Boolean;
begin
  Result := (ADescriptor <> nil) and
    not (ARole in [airTriage, airArbiter]);
  if Result and SameText(ADescriptor.Name, 'DBDictionary') then
    Result := ARole in [airLightWork, airRecovery, airDatabase, airManagement];
  if Result and SameText(ADescriptor.Name, 'Compile') then
    Result := ARole in [airLightWork, airRecovery, airManagement];
end;

function TMNoteAIActionExecutor.ResolveProjectFile(const AValue: string;
  out AFileName, AError: string): Boolean;
var
  RootWithDelimiter, Candidate: string;
begin
  Result := False;
  AFileName := '';
  AError := '';
  if Trim(AValue) = '' then
  begin
    AError := 'O caminho do arquivo é obrigatório.';
    Exit;
  end;
  RootWithDelimiter := IncludeTrailingPathDelimiter(FRootPath);
  if ExtractFileDrive(AValue) <> '' then Candidate := ExpandFileName(AValue)
  else Candidate := ExpandFileName(RootWithDelimiter + AValue);
  {$IFDEF WINDOWS}
  if not SameText(Copy(IncludeTrailingPathDelimiter(Candidate), 1,
    Length(RootWithDelimiter)), RootWithDelimiter) then
  {$ELSE}
  if Copy(IncludeTrailingPathDelimiter(Candidate), 1,
    Length(RootWithDelimiter)) <> RootWithDelimiter then
  {$ENDIF}
  begin
    AError := 'O caminho informado está fora da raiz do projeto.';
    Exit;
  end;
  if not FileExists(Candidate) then
  begin
    AError := 'Arquivo inexistente: ' + Candidate;
    Exit;
  end;
  if not FSafety.ValidateFilePath(Candidate, AError) then
  begin
    AError := 'Agent Safety: ' + AError;
    Exit;
  end;
  if HasSymbolicPathPart(FRootPath, Candidate) then
  begin
    AError := 'Links simbólicos não são permitidos em ações da IA.';
    Exit;
  end;
  if IsSensitivePath(Candidate) then
  begin
    AError := 'A leitura de arquivos sensíveis não é permitida.';
    Exit;
  end;
  if not IsAllowedTextExtension(Candidate) then
  begin
    AError := 'Extensão não suportada para leitura pela IA: ' +
      ExtractFileExt(Candidate);
    Exit;
  end;
  AFileName := Candidate;
  Result := True;
end;

function TMNoteAIActionExecutor.LimitText(const AText: string; AMax: Integer;
  out ATruncated: Boolean): string;
const
  TruncationMarker = #10'[saída truncada pelo limite da ferramenta]';
begin
  if AMax < Length(TruncationMarker) + 1 then AMax := 1024;
  ATruncated := Length(AText) > AMax;
  if ATruncated then
    Result := Copy(AText, 1, AMax - Length(TruncationMarker)) +
      TruncationMarker
  else
    Result := AText;
end;

function TMNoteAIActionExecutor.ExecuteReadFile(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  FileName, Content: string;
  Lines: TStringList;
  Maximum: Integer;
  OutputObject: TJSONObject;
begin
  AData := nil;
  ATruncated := False;
  if not ResolveProjectFile(JSONString(AParameters, 'path', ''), FileName,
    AError) then Exit(False);
  if ExistingFileSize(FileName) > 2 * 1024 * 1024 then
  begin
    AError := 'O arquivo excede o limite de leitura de 2 MB.';
    Exit(False);
  end;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FileName);
    Maximum := JSONInteger(AParameters, 'max_chars', 20000);
    if Maximum < 256 then Maximum := 256;
    if Maximum > 20000 then Maximum := 20000;
    Content := LimitText(Lines.Text, Maximum, ATruncated);
  finally
    Lines.Free;
  end;
  OutputObject := TJSONObject.Create;
  OutputObject.Add('path', ExtractRelativePath(
    IncludeTrailingPathDelimiter(FRootPath), FileName));
  OutputObject.Add('content', Content);
  AData := OutputObject;
  Result := True;
end;

function TMNoteAIActionExecutor.ExecuteSearchProject(
  AParameters: TJSONObject; out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  SearchService: TMNoteFileSearchService;
  Results: TMNoteSearchResults;
  Options: TMNoteSearchOptions;
  OutputArray: TJSONArray;
  Item: TJSONObject;
  Query: string;
  I, Maximum: Integer;
begin
  Result := False;
  AData := nil;
  ATruncated := False;
  Query := JSONString(AParameters, 'query', '');
  if Query = '' then
  begin
    AError := 'O texto de busca é obrigatório.';
    Exit;
  end;
  Options := DefaultSearchOptions;
  Options.Scope := ssProject;
  Options.IncludePatterns := JSONString(AParameters, 'include', '*.*');
  Options.ExcludePatterns := JSONString(AParameters, 'exclude',
    '!.git/**;!lib/**;!backup/**;!.mnote/**');
  Options.RegularExpression := JSONBoolean(AParameters, 'regex', False);
  Options.MatchCase := JSONBoolean(AParameters, 'match_case', False);
  Options.WholeWord := JSONBoolean(AParameters, 'whole_word', False);
  Maximum := JSONInteger(AParameters, 'max_results', 100);
  if Maximum < 1 then Maximum := 1;
  if Maximum > 200 then Maximum := 200;
  SearchService := TMNoteFileSearchService.Create;
  Results := TMNoteSearchResults.Create;
  OutputArray := TJSONArray.Create;
  try
    if not SearchService.SearchFolder(FRootPath, Query, Options, Results) then
    begin
      AError := SearchService.LastError;
      Exit;
    end;
    ATruncated := Results.Count > Maximum;
    for I := 0 to Results.Count - 1 do
    begin
      if I >= Maximum then Break;
      Item := TJSONObject.Create;
      Item.Add('path', ExtractRelativePath(IncludeTrailingPathDelimiter(
        FRootPath), Results[I].FileName));
      Item.Add('line', Results[I].Line);
      Item.Add('column', Results[I].Column);
      Item.Add('preview', Results[I].Preview);
      OutputArray.Add(Item);
    end;
    AData := OutputArray;
    OutputArray := nil;
    Result := True;
  finally
    OutputArray.Free;
    Results.Free;
    SearchService.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteListSymbols(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  Symbols: TMNoteCompletionItems;
  OutputArray: TJSONArray;
  Item: TJSONObject;
  I, Maximum: Integer;
begin
  Result := False;
  AData := nil;
  ATruncated := False;
  Maximum := JSONInteger(AParameters, 'max_results', 100);
  if Maximum < 1 then Maximum := 1;
  if Maximum > 500 then Maximum := 500;
  if not MNoteProjectSymbols.IndexFolder(FRootPath) then
  begin
    AError := 'Não foi possível indexar os símbolos do projeto.';
    Exit;
  end;
  Symbols := TMNoteCompletionItems.Create;
  OutputArray := TJSONArray.Create;
  try
    MNoteProjectSymbols.ListSymbols(Symbols, Maximum + 1);
    ATruncated := Symbols.Count > Maximum;
    for I := 0 to Symbols.Count - 1 do
    begin
      if I >= Maximum then Break;
      Item := TJSONObject.Create;
      Item.Add('name', Symbols[I].Text);
      Item.Add('kind', CompletionKindName(Symbols[I].Kind));
      Item.Add('signature', Symbols[I].Signature);
      Item.Add('path', ExtractRelativePath(IncludeTrailingPathDelimiter(
        FRootPath), Symbols[I].FileName));
      Item.Add('line', Symbols[I].Line);
      OutputArray.Add(Item);
    end;
    AData := OutputArray;
    OutputArray := nil;
    Result := True;
  finally
    OutputArray.Free;
    Symbols.Free;
  end;
end;

function MaskMatches(const AFileName, AMasks: string): Boolean;
var
  Values: TStringList;
  I: Integer;
  Mask, NameValue, MaskValue: string;
begin
  if Trim(AMasks) = '' then Exit(True);
  Result := False;
  Values := TStringList.Create;
  try
    Values.StrictDelimiter := True;
    Values.Delimiter := ';';
    Values.DelimitedText := AMasks;
    NameValue := LowerCase(StringReplace(AFileName, '\', '/', [rfReplaceAll]));
    for I := 0 to Values.Count - 1 do
    begin
      Mask := Trim(Values[I]);
      if Mask = '' then Continue;
      MaskValue := LowerCase(StringReplace(Mask, '\', '/', [rfReplaceAll]));
      if (MaskValue = '*') or (MaskValue = '*.*') or
        ((Length(MaskValue) > 1) and (MaskValue[1] = '*') and
         AnsiEndsStr(Copy(MaskValue, 2, MaxInt), NameValue)) or
        SameText(ExtractFileName(NameValue), MaskValue) then Exit(True);
    end;
  finally
    Values.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteListProjectFiles(
  AParameters: TJSONObject; out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  IncludeMask, ExcludeMask, RootPrefix: string;
  Maximum, Added: Integer;
  Files: TJSONArray;
  Output: TJSONObject;
  procedure Scan(const AFolder: string);
  var
    Search: TSearchRec;
    FullName, RelativeName: string;
  begin
    if ATruncated then Exit;
    if FindFirst(IncludeTrailingPathDelimiter(AFolder) + '*', faAnyFile,
      Search) <> 0 then Exit;
    try
      repeat
        if (Search.Name = '.') or (Search.Name = '..') then Continue;
        FullName := IncludeTrailingPathDelimiter(AFolder) + Search.Name;
        RelativeName := Copy(FullName, Length(RootPrefix) + 1, MaxInt);
        RelativeName := StringReplace(RelativeName, '\', '/', [rfReplaceAll]);
        if (Search.Attr and faDirectory) <> 0 then
        begin
          if SameText(Search.Name, '.git') or SameText(Search.Name, '.mnote') or
            SameText(Search.Name, 'lib') or SameText(Search.Name, 'backup') or
            SameText(Search.Name, 'bin') or
            ((Trim(ExcludeMask) <> '') and
             MaskMatches(RelativeName + '/', ExcludeMask)) then Continue;
          {$IF declared(faSymLink)}
          if (Search.Attr and faSymLink) <> 0 then Continue;
          {$ENDIF}
          Scan(FullName);
        end
        else if MaskMatches(RelativeName, IncludeMask) and
          ((Trim(ExcludeMask) = '') or
           (not MaskMatches(RelativeName, ExcludeMask))) and
          (not IsSensitivePath(RelativeName)) then
        begin
          if (Added >= Maximum) or (Length(Output.AsJSON) >= 19500) then
          begin ATruncated := True; Exit; end;
          Files.Add(TJSONObject.Create(['path', RelativeName,
            'extension', LowerCase(ExtractFileExt(RelativeName)),
            'size', Search.Size]));
          Inc(Added);
        end;
      until FindNext(Search) <> 0;
    finally
      FindClose(Search);
    end;
  end;
begin
  Result := False;
  AData := nil;
  AError := '';
  ATruncated := False;
  IncludeMask := JSONString(AParameters, 'include', '*');
  ExcludeMask := JSONString(AParameters, 'exclude', '');
  if (Pos('..', IncludeMask) > 0) or (Pos(':', IncludeMask) > 0) or
    (Pos('..', ExcludeMask) > 0) or (Pos(':', ExcludeMask) > 0) then
  begin AError := 'Máscara de arquivo insegura.'; Exit; end;
  Maximum := JSONInteger(AParameters, 'max_results', 500);
  if Maximum < 1 then Maximum := 1;
  if Maximum > 500 then Maximum := 500;
  if not DirectoryExists(FRootPath) then
  begin AError := 'A raiz do projeto não existe.'; Exit; end;
  RootPrefix := IncludeTrailingPathDelimiter(ExpandFileName(FRootPath));
  Output := TJSONObject.Create;
  Files := TJSONArray.Create;
  Output.Add('root', FRootPath);
  Output.Add('files', Files);
  Added := 0;
  try
    Scan(FRootPath);
    Output.Add('count', Added);
    Output.Add('truncated', ATruncated);
    AData := Output;
    Output := nil;
    Result := True;
  finally
    Output.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteGitLog(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  Service: TMNoteGitReadService;
  Output: string;
  Count: Integer;
begin
  AData := nil;
  ATruncated := False;
  Count := JSONInteger(AParameters, 'count', 20);
  Service := TMNoteGitReadService.Create;
  try
    if not Service.ShortLog(FRootPath, Count, Output) then
    begin
      AError := Service.LastError;
      Exit(False);
    end;
    AData := TJSONString.Create(LimitText(Output, 12000, ATruncated));
    Result := True;
  finally
    Service.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteGitDiff(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  Service: TMNoteGitReadService;
  Output: string;
begin
  AData := nil;
  ATruncated := False;
  Service := TMNoteGitReadService.Create;
  try
    if not Service.CommitDiff(FRootPath,
      JSONString(AParameters, 'commit', ''), Output) then
    begin
      AError := Service.LastError;
      Exit(False);
    end;
    AData := TJSONString.Create(LimitText(Output, 24000, ATruncated));
    Result := True;
  finally
    Service.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteDictionary(out AData: TJSONData;
  out ATruncated: Boolean; out AError: string): Boolean;
var
  DictionaryJSON: string;
  SourceData: TJSONData;
  SourceObject, OutputObject: TJSONObject;
  SourceTables, OutputTables: TJSONArray;
  I, OmittedTables: Integer;
begin
  Result := False;
  AData := nil;
  ATruncated := False;
  SourceData := nil;
  OutputObject := nil;
  if not Assigned(FOnGetDictionary) then
  begin
    AError := 'Nenhum dicionário de banco foi gerado nesta sessão.';
    Exit;
  end;
  if not FOnGetDictionary(Self, DictionaryJSON, AError) then Exit;
  if Trim(DictionaryJSON) = '' then
  begin
    AError := 'O cache do dicionário de banco está vazio.';
    Exit;
  end;
  try
    try
      SourceData := GetJSON(DictionaryJSON);
      if not (SourceData is TJSONObject) then
      begin
        AError := 'O cache do dicionário não contém um objeto JSON.';
        Exit;
      end;
      SourceObject := TJSONObject(SourceData);
      if not (SourceObject.Find('tables') is TJSONArray) then
      begin
        AError := 'O cache do dicionário não contém a lista de tabelas.';
        Exit;
      end;
      SourceTables := SourceObject.Arrays['tables'];
      OutputObject := TJSONObject.Create;
      OutputObject.Add('engine', JSONString(SourceObject, 'engine', ''));
      OutputObject.Add('schema', JSONString(SourceObject, 'schema', ''));
      OutputObject.Add('database', JSONString(SourceObject, 'database', ''));
      OutputTables := TJSONArray.Create;
      OutputObject.Add('tables', OutputTables);
      OmittedTables := 0;
      for I := 0 to SourceTables.Count - 1 do
        if Length(OutputObject.AsJSON) + Length(SourceTables.Items[I].AsJSON) +
          256 <= 24000 then
          OutputTables.Add(SourceTables.Items[I].Clone)
        else
          Inc(OmittedTables);
      OutputObject.Add('omitted_tables', OmittedTables);
      OutputObject.Add('truncated_by_table', OmittedTables > 0);
      ATruncated := OmittedTables > 0;
      AData := OutputObject;
      OutputObject := nil;
    except
      on E: Exception do
        AError := 'O cache do dicionário não contém JSON válido: ' + E.Message;
    end;
  finally
    OutputObject.Free;
    SourceData.Free;
  end;
  if AData = nil then Exit;
  Result := True;
end;

function TMNoteAIActionExecutor.ExecuteCompile(AParameters: TJSONObject;
  out AData: TJSONData; out ATruncated: Boolean;
  out AError: string): Boolean;
var
  Build: TMNoteBuildService;
  Arguments: TStringList;
  ExecutableName, WorkingDirectory, Output, LimitedOutput: string;
  Diagnostics: TMNoteDiagnostics;
  OutputObject, DiagnosticObject: TJSONObject;
  DiagnosticArray: TJSONArray;
  I, DiagnosticCount: Integer;
begin
  Result := False;
  AData := nil;
  ATruncated := False;
  Build := TMNoteBuildService.Create;
  Arguments := TStringList.Create;
  Diagnostics := TMNoteDiagnostics.Create;
  try
    if not Build.Prepare(FRootPath,
      JSONBoolean(AParameters, 'rebuild', False), ExecutableName,
      WorkingDirectory, Arguments, AError) then Exit;
    if not FProcess.Execute(ExecutableName, Arguments, WorkingDirectory,
      10 * 60 * 1000) then AError := FProcess.LastError;
    Output := FProcess.StdOut + FProcess.StdErr;
    LimitedOutput := LimitText(Output, 30000, ATruncated);
    TMNoteDiagnosticParser.Parse(Output, 'AI Compile', Diagnostics);
    OutputObject := TJSONObject.Create;
    OutputObject.Add('exit_code', FProcess.ExitCode);
    OutputObject.Add('timed_out', FProcess.TimedOut);
    OutputObject.Add('cancelled', FProcess.WasCancelled);
    OutputObject.Add('output', LimitedOutput);
    DiagnosticArray := TJSONArray.Create;
    DiagnosticCount := Diagnostics.Count;
    if DiagnosticCount > 200 then
    begin
      DiagnosticCount := 200;
      ATruncated := True;
    end;
    for I := 0 to DiagnosticCount - 1 do
    begin
      DiagnosticObject := TJSONObject.Create;
      DiagnosticObject.Add('path', Diagnostics[I].FileName);
      DiagnosticObject.Add('line', Diagnostics[I].Line);
      DiagnosticObject.Add('column', Diagnostics[I].Column);
      DiagnosticObject.Add('severity',
        TMNoteDiagnosticParser.SeverityName(Diagnostics[I].Severity));
      DiagnosticObject.Add('code', Diagnostics[I].Code);
      DiagnosticObject.Add('message', Diagnostics[I].MessageText);
      DiagnosticArray.Add(DiagnosticObject);
    end;
    OutputObject.Add('diagnostics', DiagnosticArray);
    AData := OutputObject;
    Result := FProcess.ExitCode = 0;
    if Result then AError := ''
    else if AError = '' then
    begin
      for I := 0 to Diagnostics.Count - 1 do
        if Diagnostics[I].Severity = mdsError then
        begin
          AError := Format(
            'Compilação falhou (código %d). Primeiro erro: %s(%d,%d): %s',
            [FProcess.ExitCode, Diagnostics[I].FileName, Diagnostics[I].Line,
             Diagnostics[I].Column, Diagnostics[I].MessageText]);
          Break;
        end;
      if AError = '' then
        AError := Format(
          'Compilação falhou com código %d e sem diagnóstico reconhecido.',
          [FProcess.ExitCode]);
    end;
  finally
    Diagnostics.Free;
    Arguments.Free;
    Build.Free;
  end;
end;

function TMNoteAIActionExecutor.ResultJSON(const AAction: string; ASuccess,
  ATruncated: Boolean; AData: TJSONData; const AError: string): string;
var
  Output: TJSONObject;
begin
  Output := TJSONObject.Create;
  try
    Output.Add('ok', ASuccess);
    Output.Add('action', AAction);
    Output.Add('simulated', False);
    Output.Add('truncated', ATruncated);
    if AData <> nil then Output.Add('data', AData)
    else Output.Add('data', TJSONNull.Create);
    if AError <> '' then Output.Add('error', AError);
    Result := Output.AsJSON;
  finally
    Output.Free;
  end;
end;

procedure TMNoteAIActionExecutor.LogResult(const AAction: string;
  ARole: TMNoteAIRole; ASuccess, ATruncated: Boolean; const AError: string);
var
  LogObject: TJSONObject;
begin
  if not Assigned(FOnLog) then Exit;
  LogObject := TJSONObject.Create;
  try
    LogObject.Add('action', AAction);
    LogObject.Add('role', MNoteAIRoleID(ARole));
    LogObject.Add('ok', ASuccess);
    LogObject.Add('truncated', ATruncated);
    if AError <> '' then LogObject.Add('error', AError);
    FOnLog(Self, LogObject.AsJSON);
  finally
    LogObject.Free;
  end;
end;

function TMNoteAIActionExecutor.DescribeActions: string;
var
  Output: TJSONArray;
  ActionObject: TJSONObject;
  ParameterArray: TJSONArray;
  Descriptor: TMNoteAIActionDescriptor;
  I, J: Integer;
begin
  Output := TJSONArray.Create;
  try
    for I := 0 to FActions.Count - 1 do
    begin
      Descriptor := TMNoteAIActionDescriptor(FActions[I]);
      ActionObject := TJSONObject.Create;
      ActionObject.Add('name', Descriptor.Name);
      ActionObject.Add('effect', MNoteAIActionEffectName(Descriptor.Effect));
      ActionObject.Add('requires_confirmation',
        Descriptor.RequiresConfirmation);
      ActionObject.Add('max_output_chars', Descriptor.MaxOutputChars);
      ParameterArray := TJSONArray.Create;
      for J := 0 to Descriptor.Parameters.Count - 1 do
        ParameterArray.Add(Descriptor.Parameters[J]);
      ActionObject.Add('parameters', ParameterArray);
      Output.Add(ActionObject);
    end;
    Result := Output.AsJSON;
  finally
    Output.Free;
  end;
end;

function TMNoteAIActionExecutor.ExecuteRequest(const ARequestJSON: string;
  ARole: TMNoteAIRole; out AResultJSON, AError: string): Boolean;
var
  Descriptor: TMNoteAIActionDescriptor;
  Parameters: TJSONObject;
  RequestData, ResultData: TJSONData;
  Truncated: Boolean;
  ConfirmationReason: string;
begin
  Result := False;
  AResultJSON := '';
  AError := '';
  Truncated := False;
  ResultData := nil;
  if not ParseRequest(ARequestJSON, Descriptor, Parameters, RequestData,
    AError) then
  begin
    AResultJSON := ResultJSON('', False, False, nil, AError);
    Exit;
  end;
  try
    if not RoleMayExecute(ARole, Descriptor) then
      AError := 'O papel ' + MNoteAIRoleName(ARole) +
        ' não tem permissão para executar ' + Descriptor.Name + '.'
    else if not FSafety.ValidateAction(Descriptor.Name, nil, AError) then
      AError := 'Agent Safety: ' + AError
    else if Descriptor.Effect in [aaeSourceWrite, aaeExternalWrite] then
      AError := 'Alterações de fonte e efeitos externos só podem passar pela revisão de Changes.'
    else if Descriptor.RequiresConfirmation and
      ((not Assigned(FOnConfirm)) or
       (not FOnConfirm(Self, Descriptor, Parameters, ConfirmationReason))) then
    begin
      if ConfirmationReason = '' then
        ConfirmationReason := 'A execução não foi confirmada pelo usuário.';
      AError := ConfirmationReason;
    end;

    if AError = '' then
    begin
      if SameText(Descriptor.Name, 'ReadFile') then
        Result := ExecuteReadFile(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'SearchProject') then
        Result := ExecuteSearchProject(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'ListSymbols') then
        Result := ExecuteListSymbols(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'ListProjectFiles') then
        Result := ExecuteListProjectFiles(Parameters, ResultData, Truncated,
          AError)
      else if SameText(Descriptor.Name, 'GitLog') then
        Result := ExecuteGitLog(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'GitDiff') then
        Result := ExecuteGitDiff(Parameters, ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'DBDictionary') then
        Result := ExecuteDictionary(ResultData, Truncated, AError)
      else if SameText(Descriptor.Name, 'Compile') then
        Result := ExecuteCompile(Parameters, ResultData, Truncated, AError);
    end;
    AResultJSON := ResultJSON(Descriptor.Name, Result, Truncated,
      ResultData, AError);
    ResultData := nil;
    LogResult(Descriptor.Name, ARole, Result, Truncated, AError);
  finally
    ResultData.Free;
    RequestData.Free;
  end;
end;

procedure TMNoteAIActionExecutor.Cancel;
begin
  FProcess.Cancel;
end;

end.
