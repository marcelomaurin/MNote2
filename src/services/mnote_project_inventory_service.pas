unit mnote_project_inventory_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_service_base, aidisktreescanner,
  ai_docfilesmanager;

type
  { TMNoteProjectInventoryService }

  TMNoteProjectInventoryService = class(TMNoteServiceBase)
  private
    FRootPath: string;
    FScanner: TAIDiskTreeScanner;
    FDocuments: TAI_DOCFILESMANAGER;
  public
    constructor Create;
    destructor Destroy; override;
    function StartScan(const ARootPath: string): Boolean;
    procedure Cancel;
    function SaveDocumentationSnapshot(out AFileName: string): Boolean;
    property RootPath: string read FRootPath;
    property Scanner: TAIDiskTreeScanner read FScanner;
  end;

implementation

uses
  aidiskitem;

constructor TMNoteProjectInventoryService.Create;
begin
  inherited Create;
  FScanner := TAIDiskTreeScanner.Create(nil);
  FScanner.IncludeFiles := True;
  FScanner.IncludeDirectories := True;
  FScanner.Recursive := True;
  FScanner.FollowSymlinks := False;
  FScanner.IncludeHidden := False;
  FScanner.IncludeSystem := False;
  FScanner.ReturnOnMainThread := True;
  FScanner.AutoClearResults := True;
  FScanner.ExcludeDirs.Add('.git');
  FScanner.ExcludeDirs.Add('.mnote');
  FScanner.ExcludeDirs.Add('backup');
  FScanner.ExcludeDirs.Add('lib');
  FScanner.ExcludeDirs.Add('bin');
  FDocuments := TAI_DOCFILESMANAGER.Create(nil);
end;

destructor TMNoteProjectInventoryService.Destroy;
begin
  FScanner.Cancel;
  FDocuments.Free;
  FScanner.Free;
  inherited Destroy;
end;

function TMNoteProjectInventoryService.StartScan(
  const ARootPath: string): Boolean;
begin
  ClearError;
  FRootPath := ExcludeTrailingPathDelimiter(ExpandFileName(ARootPath));
  if (FRootPath = '') or (not DirectoryExists(FRootPath)) then
  begin
    SetError('A raiz do projeto não existe: ' + ARootPath);
    Exit(False);
  end;
  FScanner.RootPath := FRootPath;
  try
    Result := FScanner.ScanBranchAsync(FRootPath, dsmRecursive) > 0;
  except
    on E: Exception do
    begin
      SetError('Não foi possível iniciar o inventário: ' + E.Message);
      Result := False;
    end;
  end;
end;

procedure TMNoteProjectInventoryService.Cancel;
begin
  FScanner.Cancel;
end;

function TMNoteProjectInventoryService.SaveDocumentationSnapshot(
  out AFileName: string): Boolean;
var
  Lines: TStringList;
  Item: TAIDiskItem;
  I: Integer;
  StoragePath, TempName, SnapshotName: string;
begin
  Result := False;
  AFileName := '';
  ClearError;
  if FScanner.IsBusy then
  begin
    SetError('Aguarde o término do inventário antes de documentá-lo.');
    Exit;
  end;
  if (FRootPath = '') or (FScanner.ResultCount = 0) then
  begin
    SetError('Execute o inventário do projeto antes de gerar a documentação.');
    Exit;
  end;

  StoragePath := IncludeTrailingPathDelimiter(FRootPath) +
    '.mnote' + PathDelim + 'documentation';
  TempName := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'mnote_inventory_' + FormatDateTime('yyyymmdd_hhnnss_zzz', Now) + '.txt';
  SnapshotName := 'inventario_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.txt';
  Lines := TStringList.Create;
  try
    Lines.Add('Inventário factual do projeto');
    Lines.Add('Raiz: ' + FRootPath);
    Lines.Add('Gerado em: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    Lines.Add('Itens: ' + IntToStr(FScanner.ResultCount));
    Lines.Add('');
    for I := 0 to FScanner.ResultCount - 1 do
    begin
      Item := FScanner.GetResult(I);
      if Item = nil then Continue;
      if Item.ItemType = ditDirectory then
        Lines.Add('[DIR] ' + Item.FullPath)
      else
        Lines.Add('[FILE] ' + Item.FullPath + ' (' + IntToStr(Item.Size) + ' bytes)');
    end;
    Lines.SaveToFile(TempName);

    FDocuments.StoragePath := StoragePath;
    FDocuments.AllowOverwrite := True;
    if not FDocuments.Initialize then
    begin
      SetError(FDocuments.LastError);
      Exit;
    end;
    if not FDocuments.GrupoExists('Projeto') then
      if FDocuments.AddGrupo('Projeto') < 0 then
      begin
        SetError(FDocuments.LastError);
        Exit;
      end;
    if not FDocuments.SubGrupoExists('Projeto', 'Inventarios') then
      if FDocuments.AddSubGrupo('Projeto', 'Inventarios') < 0 then
      begin
        SetError(FDocuments.LastError);
        Exit;
      end;
    if not FDocuments.UploadSubGrupo('Projeto', 'Inventarios', TempName,
      SnapshotName) then
    begin
      SetError(FDocuments.LastError);
      Exit;
    end;
    AFileName := IncludeTrailingPathDelimiter(
      FDocuments.GetSubGrupoPath('Projeto', 'Inventarios')) + SnapshotName;
    Result := FileExists(AFileName);
    if not Result then SetError('O componente não confirmou o arquivo gerado.');
  finally
    Lines.Free;
    if FileExists(TempName) then DeleteFile(TempName);
  end;
end;

end.
