unit mnote_solution_explorer_panel;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, StrUtils, Controls, ExtCtrls, StdCtrls, ComCtrls,
  Menus, Dialogs, Clipbrd, Contnrs, mnote_project_context;

type
  TMNoteSolutionPathEvent = procedure(Sender: TObject;
    const APath: string) of object;

  TMNoteSolutionNodeKind = (snkSolution, snkProject, snkFolder, snkFile,
    snkDatabase, snkTableGroup, snkTable);

  TMNoteSolutionNodeData = class
  public
    Kind: TMNoteSolutionNodeKind;
    FullPath: string;
    Loaded: Boolean;
  end;

  { TMNoteSolutionExplorerPanel }

  TMNoteSolutionExplorerPanel = class(TComponent)
  private
    FTree: TTreeView;
    FStatus: TLabel;
    FShowAll: TCheckBox;
    FNodeData: TObjectList;
    FRootPath: string;
    FProjectName: string;
    FProjectFile: string;
    FProjectKind: TMNoteProjectKind;
    FDatabaseName: string;
    FDatabaseTables: TStringList;
    FOnOpenFile: TMNoteSolutionPathEvent;
    FOnNewProject: TNotifyEvent;
    FOnOpenProject: TNotifyEvent;
    FOnOpenFolder: TNotifyEvent;
    FOnProjectProperties: TNotifyEvent;
    function AddData(AKind: TMNoteSolutionNodeKind;
      const APath: string): TMNoteSolutionNodeData;
    function AddPathNode(AParent: TTreeNode; const ACaption, APath: string;
      AKind: TMNoteSolutionNodeKind): TTreeNode;
    function IsIgnored(const AName: string; ADirectory: Boolean): Boolean;
    function IsValidItemName(const AName: string): Boolean;
    procedure PopulateFolder(ANode: TTreeNode);
    procedure RefreshClick(Sender: TObject);
    procedure CollapseClick(Sender: TObject);
    procedure NewProjectClick(Sender: TObject);
    procedure OpenProjectClick(Sender: TObject);
    procedure OpenFolderClick(Sender: TObject);
    procedure ShowAllClick(Sender: TObject);
    procedure TreeExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure TreeDoubleClick(Sender: TObject);
    procedure OpenSelected(Sender: TObject);
    procedure NewFile(Sender: TObject);
    procedure NewFolder(Sender: TObject);
    procedure RenameSelected(Sender: TObject);
    procedure DeleteSelected(Sender: TObject);
    procedure CopyPath(Sender: TObject);
    procedure ProjectProperties(Sender: TObject);
    function SelectedData: TMNoteSolutionNodeData;
    function SelectedFolder: string;
    function ProjectNode: TTreeNode;
    procedure AddDatabaseNodes(ARoot: TTreeNode);
    procedure BuildPopup;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AParent: TWinControl);
    procedure SetProject(const ARootPath, AProjectName,
      AProjectFile: string; AKind: TMNoteProjectKind);
    procedure ClearProject;
    procedure Refresh;
    procedure SetDatabase(const ADatabaseName: string; ATables: TStrings);
    procedure ClearDatabase;
    function ContainsNode(const ACaption: string): Boolean;
    procedure GetTreeSnapshot(AItems: TStrings);
    procedure SelectFile(const AFileName: string);
    property RootPath: string read FRootPath;
    property OnOpenFile: TMNoteSolutionPathEvent read FOnOpenFile
      write FOnOpenFile;
    property OnNewProject: TNotifyEvent read FOnNewProject write FOnNewProject;
    property OnOpenProject: TNotifyEvent read FOnOpenProject
      write FOnOpenProject;
    property OnOpenFolder: TNotifyEvent read FOnOpenFolder write FOnOpenFolder;
    property OnProjectProperties: TNotifyEvent read FOnProjectProperties
      write FOnProjectProperties;
  end;

implementation

constructor TMNoteSolutionExplorerPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNodeData := TObjectList.Create(True);
  FDatabaseTables := TStringList.Create;
  FDatabaseTables.Sorted := True;
  FDatabaseTables.Duplicates := dupIgnore;
end;

destructor TMNoteSolutionExplorerPanel.Destroy;
begin
  FDatabaseTables.Free;
  FNodeData.Free;
  inherited Destroy;
end;

function TMNoteSolutionExplorerPanel.AddData(AKind: TMNoteSolutionNodeKind;
  const APath: string): TMNoteSolutionNodeData;
begin
  Result := TMNoteSolutionNodeData.Create;
  Result.Kind := AKind;
  Result.FullPath := APath;
  Result.Loaded := False;
  FNodeData.Add(Result);
end;

function TMNoteSolutionExplorerPanel.AddPathNode(AParent: TTreeNode;
  const ACaption, APath: string; AKind: TMNoteSolutionNodeKind): TTreeNode;
begin
  Result := FTree.Items.AddChild(AParent, ACaption);
  Result.Data := AddData(AKind, APath);
  if AKind in [snkProject, snkFolder] then
    FTree.Items.AddChild(Result, '');
end;

procedure TMNoteSolutionExplorerPanel.AddDatabaseNodes(ARoot: TTreeNode);
var
  DatabaseNode, TablesNode: TTreeNode;
  I: Integer;
begin
  if (ARoot = nil) or (Trim(FDatabaseName) = '') then Exit;
  DatabaseNode := AddPathNode(ARoot, 'Banco de dados ''' + FDatabaseName + '''',
    '', snkDatabase);
  TablesNode := AddPathNode(DatabaseNode,
    Format('Tabelas (%d)', [FDatabaseTables.Count]), '', snkTableGroup);
  for I := 0 to FDatabaseTables.Count - 1 do
    AddPathNode(TablesNode, FDatabaseTables[I], '', snkTable);
  DatabaseNode.Expand(False);
  TablesNode.Expand(False);
end;

function TMNoteSolutionExplorerPanel.IsIgnored(const AName: string;
  ADirectory: Boolean): Boolean;
var
  NameLower: string;
begin
  Result := False;
  if FShowAll.Checked then Exit;
  NameLower := LowerCase(AName);
  if ADirectory then
    Result := (NameLower = '.git') or (NameLower = '.mnote') or
      (NameLower = 'backup') or (NameLower = 'node_modules') or
      (NameLower = '__pycache__') or (NameLower = '.idea') or
      (NameLower = '.vs')
  else
    Result := AnsiEndsText('.ppu', NameLower) or
      AnsiEndsText('.o', NameLower) or AnsiEndsText('.or', NameLower) or
      AnsiEndsText('.compiled', NameLower) or AnsiEndsText('.lps', NameLower) or
      AnsiEndsText('.bak', NameLower) or AnsiEndsText('.tmp', NameLower);
end;

function TMNoteSolutionExplorerPanel.IsValidItemName(
  const AName: string): Boolean;
const
  InvalidChars = '\/:*?"<>|';
var
  I: Integer;
begin
  Result := (Trim(AName) <> '') and (Trim(AName) <> '.') and
    (Trim(AName) <> '..');
  if not Result then Exit;
  for I := 1 to Length(InvalidChars) do
    if Pos(Copy(InvalidChars, I, 1), AName) > 0 then Exit(False);
end;

procedure TMNoteSolutionExplorerPanel.PopulateFolder(ANode: TTreeNode);
var
  Data: TMNoteSolutionNodeData;
  Search: TSearchRec;
  Directories, Files: TStringList;
  I: Integer;
  FullName: string;
begin
  if (ANode = nil) or (ANode.Data = nil) then Exit;
  Data := TMNoteSolutionNodeData(ANode.Data);
  if Data.Loaded or not (Data.Kind in [snkProject, snkFolder]) then Exit;
  Data.Loaded := True;
  while ANode.HasChildren do ANode.GetFirstChild.Delete;
  Directories := TStringList.Create;
  Files := TStringList.Create;
  try
    Directories.Sorted := True;
    Files.Sorted := True;
    if FindFirst(IncludeTrailingPathDelimiter(Data.FullPath) + '*',
      faAnyFile, Search) = 0 then
    try
      repeat
        if (Search.Name = '.') or (Search.Name = '..') then Continue;
        if Search.Attr and faDirectory <> 0 then
        begin
          if not IsIgnored(Search.Name, True) then Directories.Add(Search.Name);
        end
        else if not IsIgnored(Search.Name, False) then Files.Add(Search.Name);
      until FindNext(Search) <> 0;
    finally
      FindClose(Search);
    end;
    for I := 0 to Directories.Count - 1 do
    begin
      FullName := IncludeTrailingPathDelimiter(Data.FullPath) + Directories[I];
      AddPathNode(ANode, Directories[I], FullName, snkFolder);
    end;
    for I := 0 to Files.Count - 1 do
    begin
      FullName := IncludeTrailingPathDelimiter(Data.FullPath) + Files[I];
      AddPathNode(ANode, Files[I], FullName, snkFile);
    end;
  finally
    Files.Free;
    Directories.Free;
  end;
end;

procedure TMNoteSolutionExplorerPanel.Initialize(AParent: TWinControl);
var
  Toolbar: TPanel;
  Button: TButton;
begin
  while AParent.ControlCount > 0 do AParent.Controls[0].Free;
  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := AParent;
  Toolbar.Align := alTop;
  Toolbar.Height := 58;
  Toolbar.BevelOuter := bvNone;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.SetBounds(4, 4, 38, 25);
  Button.Caption := 'Novo'; Button.OnClick := @NewProjectClick;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.SetBounds(46, 4, 38, 25);
  Button.Caption := 'Abrir'; Button.OnClick := @OpenProjectClick;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.SetBounds(88, 4, 42, 25);
  Button.Caption := 'Pasta'; Button.OnClick := @OpenFolderClick;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.SetBounds(134, 4, 48, 25);
  Button.Caption := 'Atualizar'; Button.OnClick := @RefreshClick;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.SetBounds(186, 4, 48, 25);
  Button.Caption := 'Recolher'; Button.OnClick := @CollapseClick;
  FShowAll := TCheckBox.Create(Self);
  FShowAll.Parent := Toolbar; FShowAll.SetBounds(6, 34, 150, 20);
  FShowAll.Caption := 'Mostrar todos os arquivos';
  FShowAll.OnClick := @ShowAllClick;
  FStatus := TLabel.Create(Self);
  FStatus.Parent := AParent;
  FStatus.Align := alBottom;
  FStatus.BorderSpacing.Around := 5;
  FTree := TTreeView.Create(Self);
  FTree.Parent := AParent;
  FTree.Align := alClient;
  FTree.ReadOnly := True;
  FTree.OnExpanding := @TreeExpanding;
  FTree.OnDblClick := @TreeDoubleClick;
  BuildPopup;
  ClearProject;
end;

procedure TMNoteSolutionExplorerPanel.BuildPopup;
  procedure AddItem(AMenu: TPopupMenu; const ACaption: string;
    AHandler: TNotifyEvent);
  var
    Item: TMenuItem;
  begin
    Item := TMenuItem.Create(Self);
    Item.Caption := ACaption;
    Item.OnClick := AHandler;
    AMenu.Items.Add(Item);
  end;
var
  Menu: TPopupMenu;
begin
  Menu := TPopupMenu.Create(Self);
  AddItem(Menu, 'Abrir', @OpenSelected);
  AddItem(Menu, 'Novo arquivo...', @NewFile);
  AddItem(Menu, 'Nova pasta...', @NewFolder);
  Menu.Items.AddSeparator;
  AddItem(Menu, 'Renomear...', @RenameSelected);
  AddItem(Menu, 'Excluir', @DeleteSelected);
  Menu.Items.AddSeparator;
  AddItem(Menu, 'Copiar caminho', @CopyPath);
  AddItem(Menu, 'Propriedades do projeto', @ProjectProperties);
  FTree.PopupMenu := Menu;
end;

procedure TMNoteSolutionExplorerPanel.SetProject(const ARootPath,
  AProjectName, AProjectFile: string; AKind: TMNoteProjectKind);
begin
  FRootPath := ExpandFileName(ARootPath);
  FProjectName := AProjectName;
  FProjectFile := AProjectFile;
  FProjectKind := AKind;
  Refresh;
end;

procedure TMNoteSolutionExplorerPanel.ClearProject;
begin
  FRootPath := '';
  FProjectName := '';
  FProjectFile := '';
  FProjectKind := mpkNone;
  FDatabaseName := '';
  FDatabaseTables.Clear;
  if FTree <> nil then
  begin
    FTree.Items.Clear;
    FNodeData.Clear;
    FTree.Items.Add(nil, 'Nenhum projeto aberto');
  end;
  if FStatus <> nil then FStatus.Caption := 'Abra uma pasta ou projeto.';
end;

procedure TMNoteSolutionExplorerPanel.Refresh;
var
  Root, AProjectNode: TTreeNode;
begin
  if (FTree = nil) or not DirectoryExists(FRootPath) then
  begin
    ClearProject;
    Exit;
  end;
  FTree.Items.BeginUpdate;
  try
    FTree.Items.Clear;
    FNodeData.Clear;
    Root := AddPathNode(nil, 'Solution ''' + FProjectName + '''', '',
      snkSolution);
    AProjectNode := AddPathNode(Root, 'Projeto ''' + FProjectName + '''',
      FRootPath, snkProject);
    PopulateFolder(AProjectNode);
    AddDatabaseNodes(Root);
    Root.Expand(False);
    AProjectNode.Expand(False);
  finally
    FTree.Items.EndUpdate;
  end;
  FStatus.Caption := MNoteProjectKindName(FProjectKind) + ': ' + FRootPath;
end;

procedure TMNoteSolutionExplorerPanel.SetDatabase(const ADatabaseName: string;
  ATables: TStrings);
begin
  FDatabaseName := Trim(ADatabaseName);
  FDatabaseTables.BeginUpdate;
  try
    FDatabaseTables.Clear;
    if ATables <> nil then FDatabaseTables.AddStrings(ATables);
  finally
    FDatabaseTables.EndUpdate;
  end;
  if (FTree <> nil) and DirectoryExists(FRootPath) then Refresh;
end;

procedure TMNoteSolutionExplorerPanel.ClearDatabase;
begin
  FDatabaseName := '';
  FDatabaseTables.Clear;
  if (FTree <> nil) and DirectoryExists(FRootPath) then Refresh;
end;

function TMNoteSolutionExplorerPanel.ContainsNode(
  const ACaption: string): Boolean;
var
  Node: TTreeNode;
begin
  Result := False;
  if FTree = nil then Exit;
  Node := FTree.Items.GetFirstNode;
  while Node <> nil do
  begin
    if SameText(Node.Text, ACaption) then Exit(True);
    Node := Node.GetNext;
  end;
end;

procedure TMNoteSolutionExplorerPanel.GetTreeSnapshot(AItems: TStrings);
var
  Node: TTreeNode;
begin
  if AItems = nil then Exit;
  AItems.Clear;
  if FTree = nil then Exit;
  Node := FTree.Items.GetFirstNode;
  while Node <> nil do
  begin
    AItems.Add(StringOfChar(' ', Node.Level * 2) + Node.Text);
    Node := Node.GetNext;
  end;
end;

procedure TMNoteSolutionExplorerPanel.RefreshClick(Sender: TObject);
begin
  Refresh;
end;

procedure TMNoteSolutionExplorerPanel.CollapseClick(Sender: TObject);
begin
  if (FTree <> nil) and (FTree.Items.GetFirstNode <> nil) then
    FTree.Items.GetFirstNode.Collapse(True);
end;

procedure TMNoteSolutionExplorerPanel.NewProjectClick(Sender: TObject);
begin
  if Assigned(FOnNewProject) then FOnNewProject(Self);
end;

procedure TMNoteSolutionExplorerPanel.OpenProjectClick(Sender: TObject);
begin
  if Assigned(FOnOpenProject) then FOnOpenProject(Self);
end;

procedure TMNoteSolutionExplorerPanel.OpenFolderClick(Sender: TObject);
begin
  if Assigned(FOnOpenFolder) then FOnOpenFolder(Self);
end;

procedure TMNoteSolutionExplorerPanel.ShowAllClick(Sender: TObject);
begin
  Refresh;
end;

procedure TMNoteSolutionExplorerPanel.TreeExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
begin
  PopulateFolder(Node);
  AllowExpansion := True;
end;

function TMNoteSolutionExplorerPanel.SelectedData: TMNoteSolutionNodeData;
begin
  Result := nil;
  if (FTree <> nil) and (FTree.Selected <> nil) and
    (FTree.Selected.Data <> nil) then
    Result := TMNoteSolutionNodeData(FTree.Selected.Data);
end;

function TMNoteSolutionExplorerPanel.SelectedFolder: string;
var
  Data: TMNoteSolutionNodeData;
begin
  Result := FRootPath;
  Data := SelectedData;
  if Data = nil then Exit;
  if Data.Kind in [snkProject, snkFolder] then Result := Data.FullPath
  else if Data.Kind = snkFile then Result := ExtractFileDir(Data.FullPath);
end;

function TMNoteSolutionExplorerPanel.ProjectNode: TTreeNode;
var
  Data: TMNoteSolutionNodeData;
begin
  Result := nil;
  if FTree = nil then Exit;
  Result := FTree.Items.GetFirstNode;
  while Result <> nil do
  begin
    if Result.Data <> nil then
    begin
      Data := TMNoteSolutionNodeData(Result.Data);
      if Data.Kind = snkProject then Exit;
    end;
    Result := Result.GetNext;
  end;
end;

procedure TMNoteSolutionExplorerPanel.TreeDoubleClick(Sender: TObject);
begin
  OpenSelected(Sender);
end;

procedure TMNoteSolutionExplorerPanel.OpenSelected(Sender: TObject);
var
  Data: TMNoteSolutionNodeData;
begin
  Data := SelectedData;
  if (Data <> nil) and (Data.Kind = snkFile) and FileExists(Data.FullPath) and
    Assigned(FOnOpenFile) then FOnOpenFile(Self, Data.FullPath);
end;

procedure TMNoteSolutionExplorerPanel.NewFile(Sender: TObject);
var
  Data: TMNoteSolutionNodeData;
  ItemName, FileName: string;
  Stream: TFileStream;
begin
  Data := SelectedData;
  if (Data <> nil) and not (Data.Kind in [snkProject, snkFolder, snkFile]) then
    Exit;
  ItemName := '';
  if not InputQuery('Novo arquivo', 'Nome:', ItemName) or
    (Trim(ItemName) = '') then Exit;
  if not IsValidItemName(ItemName) then
  begin
    MessageDlg('Solution Explorer', 'Nome de arquivo inválido.',
      mtError, [mbOK], 0);
    Exit;
  end;
  FileName := IncludeTrailingPathDelimiter(SelectedFolder) + Trim(ItemName);
  if FileExists(FileName) or DirectoryExists(FileName) then
  begin
    MessageDlg('Solution Explorer', 'Já existe um item com esse nome.',
      mtError, [mbOK], 0);
    Exit;
  end;
  try
    Stream := TFileStream.Create(FileName, fmCreate);
    Stream.Free;
    Refresh;
    if Assigned(FOnOpenFile) then FOnOpenFile(Self, FileName);
  except
    on E: Exception do MessageDlg('Solution Explorer', E.Message,
      mtError, [mbOK], 0);
  end;
end;

procedure TMNoteSolutionExplorerPanel.NewFolder(Sender: TObject);
var
  Data: TMNoteSolutionNodeData;
  ItemName, Folder: string;
begin
  Data := SelectedData;
  if (Data <> nil) and not (Data.Kind in [snkProject, snkFolder, snkFile]) then
    Exit;
  ItemName := '';
  if not InputQuery('Nova pasta', 'Nome:', ItemName) or
    (Trim(ItemName) = '') then Exit;
  if not IsValidItemName(ItemName) then
  begin
    MessageDlg('Solution Explorer', 'Nome de pasta inválido.',
      mtError, [mbOK], 0);
    Exit;
  end;
  Folder := IncludeTrailingPathDelimiter(SelectedFolder) + Trim(ItemName);
  if not CreateDir(Folder) then
    MessageDlg('Solution Explorer', 'Não foi possível criar a pasta.',
      mtError, [mbOK], 0)
  else Refresh;
end;

procedure TMNoteSolutionExplorerPanel.RenameSelected(Sender: TObject);
var
  Data: TMNoteSolutionNodeData;
  ItemName, Target: string;
begin
  Data := SelectedData;
  if (Data = nil) or not (Data.Kind in [snkFolder, snkFile]) then Exit;
  ItemName := ExtractFileName(Data.FullPath);
  if not InputQuery('Renomear', 'Novo nome:', ItemName) or
    (Trim(ItemName) = '') then Exit;
  if not IsValidItemName(ItemName) then
  begin
    MessageDlg('Solution Explorer', 'Nome inválido.', mtError, [mbOK], 0);
    Exit;
  end;
  Target := IncludeTrailingPathDelimiter(ExtractFileDir(Data.FullPath)) +
    Trim(ItemName);
  if not RenameFile(Data.FullPath, Target) then
    MessageDlg('Solution Explorer', 'Não foi possível renomear o item.',
      mtError, [mbOK], 0)
  else Refresh;
end;

procedure TMNoteSolutionExplorerPanel.DeleteSelected(Sender: TObject);
var
  Data: TMNoteSolutionNodeData;
  Removed: Boolean;
begin
  Data := SelectedData;
  if (Data = nil) or not (Data.Kind in [snkFolder, snkFile]) then Exit;
  if MessageDlg('Excluir item', 'Excluir definitivamente ' +
    ExtractFileName(Data.FullPath) + '?', mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then Exit;
  if Data.Kind = snkFolder then Removed := RemoveDir(Data.FullPath)
  else Removed := SysUtils.DeleteFile(Data.FullPath);
  if not Removed then
    MessageDlg('Solution Explorer',
      'Não foi possível excluir. Pastas precisam estar vazias.',
      mtError, [mbOK], 0)
  else Refresh;
end;

procedure TMNoteSolutionExplorerPanel.CopyPath(Sender: TObject);
var
  Data: TMNoteSolutionNodeData;
begin
  Data := SelectedData;
  if (Data <> nil) and (Data.FullPath <> '') then
    Clipboard.AsText := Data.FullPath;
end;

procedure TMNoteSolutionExplorerPanel.ProjectProperties(Sender: TObject);
begin
  if Assigned(FOnProjectProperties) then FOnProjectProperties(Self);
end;

procedure TMNoteSolutionExplorerPanel.SelectFile(const AFileName: string);
var
  Node, Child: TTreeNode;
  Data: TMNoteSolutionNodeData;
  RelativeName: string;
  Parts: TStringList;
  I: Integer;
begin
  if (FTree = nil) or (AFileName = '') or (FRootPath = '') then Exit;
  Node := ProjectNode;
  if Node = nil then Exit;
  RelativeName := ExtractRelativePath(IncludeTrailingPathDelimiter(FRootPath),
    ExpandFileName(AFileName));
  if AnsiStartsText('..', RelativeName) then Exit;
  RelativeName := StringReplace(RelativeName, '\', '/', [rfReplaceAll]);
  Parts := TStringList.Create;
  try
    Parts.StrictDelimiter := True;
    Parts.Delimiter := '/';
    Parts.DelimitedText := RelativeName;
    for I := 0 to Parts.Count - 1 do
    begin
      PopulateFolder(Node);
      Child := Node.GetFirstChild;
      while Child <> nil do
      begin
        if Child.Data <> nil then
        begin
          Data := TMNoteSolutionNodeData(Child.Data);
          if SameText(ExtractFileName(Data.FullPath), Parts[I]) then Break;
        end;
        Child := Child.GetNextSibling;
      end;
      if Child = nil then Exit;
      Node.Expand(False);
      Node := Child;
    end;
    FTree.Selected := Node;
    Node.MakeVisible;
  finally
    Parts.Free;
  end;
end;

end.
