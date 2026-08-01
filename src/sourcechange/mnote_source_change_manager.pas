unit mnote_source_change_manager;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, StrUtils, md5, fpjson, jsonparser,
  mnote_source_change_types, mnote_unified_diff
  {$IFDEF MSWINDOWS}, Windows{$ENDIF};

type
  TAISourceChangeManager = class
  private
    FRootPath: string;
    FDryRun: Boolean;
    FRequireConfirmation: Boolean;
    FCreateBackup: Boolean;
    FAllowedExtensions: string;
    FMaxFileSize: Int64;
    FLastError: string;
    FFailAfterTempWrite: Boolean;
    function ResolvePath(const ARelativePath: string;
      out AFullPath: string): Boolean;
    function ValidateExistingFile(const AFileName: string;
      out AContent: string): Boolean;
    function WriteAtomic(const AFileName, AContent: string): Boolean;
    function BackupFile(ASet: TAISourceChangeSet;
      AChange: TAISourceChange): Boolean;
    procedure SaveHistory(ASet: TAISourceChangeSet; const AResult: string);
    function BackupName(ASet: TAISourceChangeSet;
      AChange: TAISourceChange): string;
  public
    constructor Create;
    function ContentHash(const AContent: string): string;
    function ProposeExactReplace(ASet: TAISourceChangeSet;
      const ARelativePath, AExpectedText, ANewText: string;
      AExpectedCount: Integer): TAISourceChange;
    function ProposeLineRange(ASet: TAISourceChangeSet;
      const ARelativePath: string; AStartLine, AEndLine: Integer;
      const AExpectedText, ANewText: string): TAISourceChange;
    function ProposeNewFile(ASet: TAISourceChangeSet;
      const ARelativePath, AContent: string): TAISourceChange;
    function SetHunkSelected(AChange: TAISourceChange; AIndex: Integer;
      ASelected: Boolean): Boolean;
    function SetAllHunksSelected(AChange: TAISourceChange;
      ASelected: Boolean): Boolean;
    function Apply(ASet: TAISourceChangeSet; AConfirmed: Boolean): Boolean;
    function Rollback(ASet: TAISourceChangeSet): Boolean;
    property RootPath: string read FRootPath write FRootPath;
    property DryRun: Boolean read FDryRun write FDryRun;
    property RequireConfirmation: Boolean read FRequireConfirmation write FRequireConfirmation;
    property CreateBackup: Boolean read FCreateBackup write FCreateBackup;
    property AllowedExtensions: string read FAllowedExtensions write FAllowedExtensions;
    property MaxFileSize: Int64 read FMaxFileSize write FMaxFileSize;
    property LastError: string read FLastError;
    property FailAfterTempWrite: Boolean read FFailAfterTempWrite write FFailAfterTempWrite;
  end;

implementation

function ReadFileBytes(const AFileName: string): string;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, Stream.Size);
    if Stream.Size > 0 then Stream.ReadBuffer(Result[1], Stream.Size);
  finally
    Stream.Free;
  end;
end;

function CountOccurrences(const AText, ASearch: string): Integer;
var
  P, Offset: Integer;
begin
  Result := 0;
  if ASearch = '' then Exit;
  Offset := 1;
  repeat
    P := PosEx(ASearch, AText, Offset);
    if P > 0 then
    begin
      Inc(Result);
      Offset := P + Length(ASearch);
    end;
  until P = 0;
end;

function ReplaceExact(const AText, AExpected, ANew: string): string;
var
  P, Offset: Integer;
begin
  Result := '';
  Offset := 1;
  repeat
    P := PosEx(AExpected, AText, Offset);
    if P = 0 then Break;
    Result := Result + Copy(AText, Offset, P - Offset) + ANew;
    Offset := P + Length(AExpected);
  until False;
  Result := Result + Copy(AText, Offset, MaxInt);
end;

function HasAllowedExtension(const AFileName, AAllowed: string): Boolean;
var
  Parts: TStringList;
  I: Integer;
  Extension: string;
begin
  Result := False;
  Extension := LowerCase(ExtractFileExt(AFileName));
  if (Extension = '.exe') or (Extension = '.dll') or (Extension = '.so') or
    (Extension = '.dylib') or (Extension = '.bin') then Exit;
  Parts := TStringList.Create;
  try
    Parts.Delimiter := ';';
    Parts.StrictDelimiter := True;
    Parts.DelimitedText := LowerCase(AAllowed);
    for I := 0 to Parts.Count - 1 do
      if Trim(Parts[I]) = Extension then Exit(True);
  finally
    Parts.Free;
  end;
end;

function ReplaceLineRangeText(const AContent: string; AStartLine,
  AEndLine: Integer; const AExpected, ANew: string; out AResult: string): Boolean;
var
  Normalized, NewNormalized, Actual, EOL: string;
  Lines, Replacement: TStringList;
  I: Integer;
  FinalBreak: Boolean;
begin
  Result := False;
  Normalized := StringReplace(AContent, #13#10, #10, [rfReplaceAll]);
  Normalized := StringReplace(Normalized, #13, #10, [rfReplaceAll]);
  FinalBreak := (Normalized <> '') and (Normalized[Length(Normalized)] = #10);
  if FinalBreak then Delete(Normalized, Length(Normalized), 1);
  Lines := TStringList.Create;
  Replacement := TStringList.Create;
  try
    Lines.Text := StringReplace(Normalized, #10, LineEnding, [rfReplaceAll]);
    if (AStartLine < 1) or (AEndLine < AStartLine) or (AEndLine > Lines.Count) then Exit;
    Actual := '';
    for I := AStartLine - 1 to AEndLine - 1 do
    begin
      if Actual <> '' then Actual := Actual + #10;
      Actual := Actual + Lines[I];
    end;
    if StringReplace(AExpected, #13#10, #10, [rfReplaceAll]) <> Actual then Exit;
    NewNormalized := StringReplace(ANew, #13#10, #10, [rfReplaceAll]);
    NewNormalized := StringReplace(NewNormalized, #13, #10, [rfReplaceAll]);
    Replacement.Text := StringReplace(NewNormalized, #10, LineEnding, [rfReplaceAll]);
    for I := AEndLine - 1 downto AStartLine - 1 do Lines.Delete(I);
    for I := Replacement.Count - 1 downto 0 do Lines.Insert(AStartLine - 1, Replacement[I]);
    if Pos(#13#10, AContent) > 0 then EOL := #13#10 else EOL := #10;
    AResult := '';
    for I := 0 to Lines.Count - 1 do
    begin
      if I > 0 then AResult := AResult + EOL;
      AResult := AResult + Lines[I];
    end;
    if FinalBreak then AResult := AResult + EOL;
    Result := True;
  finally
    Replacement.Free;
    Lines.Free;
  end;
end;

constructor TAISourceChangeManager.Create;
begin
  inherited Create;
  FRootPath := GetCurrentDir;
  FDryRun := True;
  FRequireConfirmation := True;
  FCreateBackup := True;
  FAllowedExtensions := '.pas;.pp;.lpr;.lfm;.lpi;.inc;.txt;.md;.json;.xml;' +
    '.ini;.cfg;.sql;.py;.js;.ts;.html;.htm;.css;.scss;.yaml;.yml;.sh;.ps1';
  FMaxFileSize := 2 * 1024 * 1024;
end;

function TAISourceChangeManager.ContentHash(const AContent: string): string;
begin
  Result := MD5Print(MD5String(AContent));
end;

function TAISourceChangeManager.ResolvePath(const ARelativePath: string;
  out AFullPath: string): Boolean;
var
  Relative, RootWithDelimiter, Walk, Segment: string;
  Parts: TStringList;
  I, Attr: Integer;
begin
  Result := False;
  FLastError := '';
  Relative := StringReplace(Trim(ARelativePath), '/', PathDelim, [rfReplaceAll]);
  if (Relative = '') or (ExtractFileDrive(Relative) <> '') or
    (Relative[1] = PathDelim) then
  begin FLastError := 'O caminho deve ser relativo ao projeto.'; Exit; end;
  Parts := TStringList.Create;
  try
    Parts.Delimiter := PathDelim;
    Parts.StrictDelimiter := True;
    Parts.DelimitedText := Relative;
    for I := 0 to Parts.Count - 1 do
      if (Parts[I] = '..') or (Parts[I] = '.') or (Parts[I] = '') then
      begin FLastError := 'Segmento de caminho inseguro: ' + Parts[I]; Exit; end;
  finally
    Parts.Free;
  end;
  RootWithDelimiter := IncludeTrailingPathDelimiter(ExpandFileName(FRootPath));
  AFullPath := ExpandFileName(RootWithDelimiter + Relative);
  if Pos(LowerCase(RootWithDelimiter), LowerCase(AFullPath)) <> 1 then
  begin FLastError := 'O caminho sai da raiz do projeto.'; Exit; end;
  Walk := RootWithDelimiter;
  Parts := TStringList.Create;
  try
    Parts.Delimiter := PathDelim;
    Parts.StrictDelimiter := True;
    Parts.DelimitedText := Relative;
    for I := 0 to Parts.Count - 2 do
    begin
      Segment := Parts[I];
      Walk := IncludeTrailingPathDelimiter(Walk + Segment);
      Attr := FileGetAttr(ExcludeTrailingPathDelimiter(Walk));
      if (Attr >= 0) and ((Attr and faSymLink) <> 0) then
      begin FLastError := 'Link simbólico não permitido no caminho.'; Exit; end;
    end;
  finally
    Parts.Free;
  end;
  if not HasAllowedExtension(AFullPath, FAllowedExtensions) then
  begin FLastError := 'Extensão não permitida: ' + ExtractFileExt(AFullPath); Exit; end;
  Result := True;
end;

function TAISourceChangeManager.ValidateExistingFile(const AFileName: string;
  out AContent: string): Boolean;
begin
  Result := False;
  if not FileExists(AFileName) then
  begin FLastError := 'Arquivo não encontrado: ' + AFileName; Exit; end;
  if Length(ReadFileBytes(AFileName)) > FMaxFileSize then
  begin FLastError := 'Arquivo excede o limite configurado.'; Exit; end;
  AContent := ReadFileBytes(AFileName);
  if Pos(#0, AContent) > 0 then
  begin FLastError := 'Arquivo binário não permitido.'; Exit; end;
  Result := True;
end;

function TAISourceChangeManager.ProposeExactReplace(ASet: TAISourceChangeSet;
  const ARelativePath, AExpectedText, ANewText: string;
  AExpectedCount: Integer): TAISourceChange;
var
  FullPath, Content: string;
begin
  Result := nil;
  if not ResolvePath(ARelativePath, FullPath) then Exit;
  if not ValidateExistingFile(FullPath, Content) then Exit;
  if (AExpectedText = '') or (CountOccurrences(Content, AExpectedText) <> AExpectedCount) then
  begin FLastError := 'A quantidade do texto esperado não coincide.'; Exit; end;
  Result := ASet.Add;
  Result.Kind := sckExactReplace;
  Result.FileName := ARelativePath;
  Result.ExpectedText := AExpectedText;
  Result.NewText := ANewText;
  Result.ExpectedCount := AExpectedCount;
  Result.OriginalHash := ContentHash(Content);
  Result.ProposedContent := ReplaceExact(Content, AExpectedText, ANewText);
  Result.Diff := TMNoteUnifiedDiff.Generate(Content, Result.ProposedContent,
    ARelativePath, Result.FallbackDiff);
  Result.InitializeHunks(TMNoteUnifiedDiff.HunkCount(Result.Diff));
end;

function TAISourceChangeManager.ProposeLineRange(ASet: TAISourceChangeSet;
  const ARelativePath: string; AStartLine, AEndLine: Integer;
  const AExpectedText, ANewText: string): TAISourceChange;
var
  FullPath, Content, Proposed: string;
begin
  Result := nil;
  if not ResolvePath(ARelativePath, FullPath) then Exit;
  if not ValidateExistingFile(FullPath, Content) then Exit;
  if not ReplaceLineRangeText(Content, AStartLine, AEndLine, AExpectedText,
    ANewText, Proposed) then
  begin FLastError := 'O intervalo ou suas linhas esperadas não coincidem.'; Exit; end;
  Result := ASet.Add;
  Result.Kind := sckLineRange;
  Result.FileName := ARelativePath;
  Result.StartLine := AStartLine;
  Result.EndLine := AEndLine;
  Result.ExpectedText := AExpectedText;
  Result.NewText := ANewText;
  Result.OriginalHash := ContentHash(Content);
  Result.ProposedContent := Proposed;
  Result.Diff := TMNoteUnifiedDiff.Generate(Content, Proposed, ARelativePath,
    Result.FallbackDiff);
  Result.InitializeHunks(TMNoteUnifiedDiff.HunkCount(Result.Diff));
end;

function TAISourceChangeManager.ProposeNewFile(ASet: TAISourceChangeSet;
  const ARelativePath, AContent: string): TAISourceChange;
var
  FullPath: string;
begin
  Result := nil;
  if not ResolvePath(ARelativePath, FullPath) then Exit;
  if FileExists(FullPath) then
  begin FLastError := 'O arquivo novo já existe.'; Exit; end;
  if (Length(AContent) > FMaxFileSize) or (Pos(#0, AContent) > 0) then
  begin FLastError := 'Conteúdo novo binário ou acima do limite.'; Exit; end;
  Result := ASet.Add;
  Result.Kind := sckNewFile;
  Result.FileName := ARelativePath;
  Result.ProposedContent := AContent;
  Result.Diff := TMNoteUnifiedDiff.Generate('', AContent, ARelativePath,
    Result.FallbackDiff);
  Result.InitializeHunks(TMNoteUnifiedDiff.HunkCount(Result.Diff));
end;

function TAISourceChangeManager.SetHunkSelected(AChange: TAISourceChange;
  AIndex: Integer; ASelected: Boolean): Boolean;
var
  FullPath, OriginalContent, SelectedDiff, Proposed, ErrorText: string;
  Selection: array of Boolean;
  I: Integer;
begin
  Result := False;
  FLastError := '';
  if AChange = nil then
  begin FLastError := 'Mudança não informada.'; Exit; end;
  if (AIndex < 0) or (AIndex >= AChange.HunkCount) then
  begin FLastError := 'Trecho de diff inválido.'; Exit; end;
  if AChange.Kind = sckNewFile then OriginalContent := ''
  else
  begin
    if not ResolvePath(AChange.FileName, FullPath) then Exit;
    if not ValidateExistingFile(FullPath, OriginalContent) then Exit;
    if ContentHash(OriginalContent) <> AChange.OriginalHash then
    begin FLastError := 'Hash original mudou após o preview: ' +
      AChange.FileName; Exit; end;
  end;
  AChange.SelectHunk(AIndex, ASelected);
  SetLength(Selection, AChange.HunkCount);
  for I := 0 to AChange.HunkCount - 1 do
    Selection[I] := AChange.HunkSelected(I);
  SelectedDiff := TMNoteUnifiedDiff.SelectHunks(AChange.Diff, Selection);
  if not TMNoteUnifiedDiff.Apply(OriginalContent, SelectedDiff, Proposed,
    ErrorText) then
  begin
    AChange.SelectHunk(AIndex, not ASelected);
    FLastError := 'Não foi possível reconstruir a seleção parcial: ' +
      ErrorText;
    Exit;
  end;
  AChange.ProposedContent := Proposed;
  AChange.Selected := AChange.SelectedHunkCount > 0;
  Result := True;
end;

function TAISourceChangeManager.SetAllHunksSelected(
  AChange: TAISourceChange; ASelected: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AChange = nil then Exit;
  if AChange.HunkCount = 0 then
  begin
    AChange.Selected := ASelected;
    Exit(True);
  end;
  for I := 0 to AChange.HunkCount - 1 do
    if not SetHunkSelected(AChange, I, ASelected) then Exit;
  Result := True;
end;

function TAISourceChangeManager.WriteAtomic(const AFileName,
  AContent: string): Boolean;
var
  Stream: TFileStream;
  TempFile: string;
begin
  Result := False;
  TempFile := AFileName + '.mnote-tmp';
  ForceDirectories(ExtractFileDir(AFileName));
  try
    Stream := TFileStream.Create(TempFile, fmCreate);
    try
      if AContent <> '' then Stream.WriteBuffer(AContent[1], Length(AContent));
    finally
      Stream.Free;
    end;
    if FFailAfterTempWrite and
      (Pos(LowerCase(PathDelim + '.mnote' + PathDelim), LowerCase(AFileName)) = 0) then
      raise Exception.Create('Falha de teste após a escrita temporária.');
    {$IFDEF MSWINDOWS}
    if not Windows.MoveFileEx(PChar(TempFile), PChar(AFileName), $1 or $8) then
      raise Exception.Create(SysErrorMessage(GetLastOSError));
    {$ELSE}
    if FileExists(AFileName) and (not DeleteFile(AFileName)) then
      raise Exception.Create('Não foi possível substituir o destino.');
    if not RenameFile(TempFile, AFileName) then
      raise Exception.Create('Não foi possível mover o temporário.');
    {$ENDIF}
    Result := True;
  except
    on E: Exception do FLastError := E.Message;
  end;
  if FileExists(TempFile) then SysUtils.DeleteFile(TempFile);
end;

function TAISourceChangeManager.BackupName(ASet: TAISourceChangeSet;
  AChange: TAISourceChange): string;
begin
  Result := IncludeTrailingPathDelimiter(FRootPath) + '.mnote' + PathDelim +
    'backups' + PathDelim + ASet.ID + PathDelim +
    StringReplace(AChange.FileName, '/', PathDelim, [rfReplaceAll]) + '.bak';
end;

function TAISourceChangeManager.BackupFile(ASet: TAISourceChangeSet;
  AChange: TAISourceChange): Boolean;
var
  SourceName, TargetName, Content: string;
begin
  Result := True;
  if (not FCreateBackup) or (AChange.Kind = sckNewFile) then Exit;
  if not ResolvePath(AChange.FileName, SourceName) then Exit(False);
  Content := ReadFileBytes(SourceName);
  TargetName := BackupName(ASet, AChange);
  Result := WriteAtomic(TargetName, Content);
end;

procedure TAISourceChangeManager.SaveHistory(ASet: TAISourceChangeSet;
  const AResult: string);
var
  FileName, Text: string;
  Data: TJSONData;
  History: TJSONArray;
  Entry: TJSONObject;
begin
  FileName := IncludeTrailingPathDelimiter(FRootPath) + '.mnote' + PathDelim +
    'changes' + PathDelim + 'history.json';
  ForceDirectories(ExtractFileDir(FileName));
  History := nil;
  if FileExists(FileName) then
  begin
    Text := ReadFileBytes(FileName);
    try
      Data := GetJSON(Text);
      if Data is TJSONArray then History := TJSONArray(Data) else Data.Free;
    except
      History := nil;
    end;
  end;
  if History = nil then History := TJSONArray.Create;
  try
    Entry := ASet.ToJSON;
    Entry.Add('result', AResult);
    Entry.Add('recorded_at', FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss', Now));
    History.Add(Entry);
    WriteAtomic(FileName, History.FormatJSON);
  finally
    History.Free;
  end;
end;

function TAISourceChangeManager.Apply(ASet: TAISourceChangeSet;
  AConfirmed: Boolean): Boolean;
var
  I, AppliedCount: Integer;
  AllApplied: Boolean;
  Change: TAISourceChange;
  FullPath, Content: string;
begin
  Result := False;
  FLastError := '';
  if FRequireConfirmation and (not AConfirmed) then
  begin FLastError := 'Confirmação explícita obrigatória.'; Exit; end;
  AppliedCount := 0;
  AllApplied := True;
  for I := 0 to ASet.Count - 1 do
  begin
    Change := ASet[I];
    if not Change.Selected then Continue;
    Inc(AppliedCount);
    if not ResolvePath(Change.FileName, FullPath) then Exit;
    if Change.Kind = sckNewFile then
    begin
      if FileExists(FullPath) then begin FLastError := 'Arquivo novo passou a existir.'; Exit; end;
    end
    else
    begin
      if not ValidateExistingFile(FullPath, Content) then Exit;
      if ContentHash(Content) <> Change.OriginalHash then
      begin FLastError := 'Hash original mudou após o preview: ' + Change.FileName; Exit; end;
    end;
  end;
  if AppliedCount = 0 then begin FLastError := 'Nenhum arquivo selecionado.'; Exit; end;
  ASet.Status := scsApproved;
  if FDryRun then
  begin SaveHistory(ASet, 'dry-run: nenhuma escrita executada'); Exit(True); end;
  for I := 0 to ASet.Count - 1 do
  begin
    Change := ASet[I];
    if not Change.Selected then Continue;
    if not BackupFile(ASet, Change) then begin AllApplied := False; Break; end;
    if not ResolvePath(Change.FileName, FullPath) then begin AllApplied := False; Break; end;
    if not WriteAtomic(FullPath, Change.ProposedContent) then begin AllApplied := False; Break; end;
    Change.AppliedHash := ContentHash(Change.ProposedContent);
    Change.Status := scsApplied;
  end;
  if not AllApplied then
  begin
    ASet.Status := scsFailed;
    Rollback(ASet);
    SaveHistory(ASet, 'failed: ' + FLastError);
    Exit(False);
  end;
  ASet.Status := scsApplied;
  SaveHistory(ASet, 'applied');
  Result := True;
end;

function TAISourceChangeManager.Rollback(ASet: TAISourceChangeSet): Boolean;
var
  I: Integer;
  Change: TAISourceChange;
  FullPath, BackupFileName, Current: string;
begin
  Result := False;
  for I := ASet.Count - 1 downto 0 do
  begin
    Change := ASet[I];
    if Change.Status <> scsApplied then Continue;
    if not ResolvePath(Change.FileName, FullPath) then Exit;
    if not FileExists(FullPath) then
    begin FLastError := 'Arquivo aplicado desapareceu: ' + Change.FileName; Exit; end;
    Current := ReadFileBytes(FullPath);
    if ContentHash(Current) <> Change.AppliedHash then
    begin FLastError := 'Rollback recusado: arquivo alterado depois do Apply.'; Exit; end;
    if Change.Kind = sckNewFile then
    begin
      if not SysUtils.DeleteFile(FullPath) then begin FLastError := 'Não foi possível remover arquivo criado.'; Exit; end;
    end
    else
    begin
      BackupFileName := BackupName(ASet, Change);
      if not FileExists(BackupFileName) then begin FLastError := 'Backup não encontrado.'; Exit; end;
      if not WriteAtomic(FullPath, ReadFileBytes(BackupFileName)) then Exit;
    end;
    Change.Status := scsReverted;
  end;
  ASet.Status := scsReverted;
  SaveHistory(ASet, 'reverted');
  Result := True;
end;

end.
