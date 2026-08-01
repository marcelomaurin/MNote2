unit mnote_command_palette;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, StdCtrls, Menus, LCLType,
  mnote_commands;

type
  TMNotePaletteMode = (pmCommands, pmFiles);
  TMNoteCollectFilesEvent = procedure(AFiles: TStrings) of object;
  TMNoteOpenFileEvent = procedure(const AFileName: string) of object;

  { TMNoteCommandPalette }

  TMNoteCommandPalette = class(TComponent)
  private
    FRegistry: TMNoteCommandRegistry;
    FTopPanel: TPanel;
    FEdit: TEdit;
    FResults: TListBox;
    FScores: TList;
    FMatchedFiles: TStringList;
    FOriginalHeight: Integer;
    FMode: TMNotePaletteMode;
    FSearchMenu: TMenuItem;
    FCommandMenuItem: TMenuItem;
    FFileMenuItem: TMenuItem;
    FOnCollectFiles: TMNoteCollectFilesEvent;
    FOnOpenFile: TMNoteOpenFileEvent;
    procedure EditChange(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ResultsDblClick(Sender: TObject);
    procedure CommandMenuClick(Sender: TObject);
    procedure FileMenuClick(Sender: TObject);
    procedure RefreshMatches;
    procedure InsertCommand(ACommand: TMNoteCommand; AScore: Integer);
    procedure InsertFile(const AFileName: string; AScore: Integer);
    procedure ExecuteSelected;
    procedure SetExpanded(AValue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(ATopPanel: TPanel; AMainMenu: TMainMenu;
      ARegistry: TMNoteCommandRegistry);
    procedure ShowPalette(AMode: TMNotePaletteMode);
    procedure ClosePalette;
    property OnCollectFiles: TMNoteCollectFilesEvent read FOnCollectFiles
      write FOnCollectFiles;
    property OnOpenFile: TMNoteOpenFileEvent read FOnOpenFile write FOnOpenFile;
  end;

implementation

uses
  mnote_fuzzy_matcher;

constructor TMNoteCommandPalette.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScores := TList.Create;
  FMatchedFiles := TStringList.Create;
end;

destructor TMNoteCommandPalette.Destroy;
begin
  FMatchedFiles.Free;
  FScores.Free;
  inherited Destroy;
end;

procedure TMNoteCommandPalette.Initialize(ATopPanel: TPanel;
  AMainMenu: TMainMenu; ARegistry: TMNoteCommandRegistry);
begin
  FTopPanel := ATopPanel;
  FRegistry := ARegistry;
  FOriginalHeight := FTopPanel.Height;

  FEdit := TEdit.Create(Self);
  FEdit.Name := 'edIDECommandSearch';
  FEdit.Parent := FTopPanel;
  FEdit.Width := 360;
  FEdit.Height := 27;
  FEdit.Left := FTopPanel.ClientWidth - FEdit.Width - 145;
  FEdit.Top := 11;
  FEdit.Anchors := [akTop, akRight];
  FEdit.TextHint := 'Pesquisar comandos (Ctrl+Q)';
  FEdit.OnChange := @EditChange;
  FEdit.OnKeyDown := @EditKeyDown;

  FResults := TListBox.Create(Self);
  FResults.Name := 'lstIDECommandSearch';
  FResults.Parent := FTopPanel;
  FResults.Left := FEdit.Left;
  FResults.Top := FEdit.Top + FEdit.Height + 2;
  FResults.Width := FEdit.Width;
  FResults.Height := 150;
  FResults.Anchors := [akTop, akRight];
  FResults.OnKeyDown := @EditKeyDown;
  FResults.OnDblClick := @ResultsDblClick;
  FResults.Visible := False;

  FSearchMenu := TMenuItem.Create(Self);
  FSearchMenu.Caption := 'Search';
  AMainMenu.Items.Add(FSearchMenu);

  FCommandMenuItem := TMenuItem.Create(Self);
  FCommandMenuItem.Caption := 'Command Palette...';
  FCommandMenuItem.ShortCut := Menus.ShortCut(VK_Q, [ssCtrl]);
  FCommandMenuItem.ShortCutKey2 := Menus.ShortCut(VK_P, [ssCtrl, ssShift]);
  FCommandMenuItem.OnClick := @CommandMenuClick;
  FSearchMenu.Add(FCommandMenuItem);

  FFileMenuItem := TMenuItem.Create(Self);
  FFileMenuItem.Caption := 'Quick Open File...';
  FFileMenuItem.ShortCut := Menus.ShortCut(VK_P, [ssCtrl]);
  FFileMenuItem.OnClick := @FileMenuClick;
  FSearchMenu.Add(FFileMenuItem);
end;

procedure TMNoteCommandPalette.SetExpanded(AValue: Boolean);
begin
  FResults.Visible := AValue;
  if AValue then
    FTopPanel.Height := FResults.Top + FResults.Height + 4
  else
    FTopPanel.Height := FOriginalHeight;
end;

procedure TMNoteCommandPalette.ShowPalette(AMode: TMNotePaletteMode);
begin
  FMode := AMode;
  FEdit.Clear;
  if FMode = pmCommands then
    FEdit.TextHint := 'Pesquisar comandos (Ctrl+Q)'
  else
    FEdit.TextHint := 'Abrir arquivo rapidamente (Ctrl+P)';
  SetExpanded(True);
  RefreshMatches;
  FEdit.SetFocus;
end;

procedure TMNoteCommandPalette.ClosePalette;
begin
  FEdit.Clear;
  SetExpanded(False);
end;

procedure TMNoteCommandPalette.EditChange(Sender: TObject);
begin
  if not FResults.Visible then
  begin
    FMode := pmCommands;
    SetExpanded(True);
  end;
  RefreshMatches;
end;

procedure TMNoteCommandPalette.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        ClosePalette;
        Key := 0;
      end;
    VK_RETURN:
      begin
        ExecuteSelected;
        Key := 0;
      end;
    VK_DOWN:
      begin
        if FResults.Count > 0 then
          FResults.ItemIndex := (FResults.ItemIndex + 1) mod FResults.Count;
        Key := 0;
      end;
    VK_UP:
      begin
        if FResults.Count > 0 then
        begin
          if FResults.ItemIndex <= 0 then
            FResults.ItemIndex := FResults.Count - 1
          else
            FResults.ItemIndex := FResults.ItemIndex - 1;
        end;
        Key := 0;
      end;
  end;
end;

procedure TMNoteCommandPalette.ResultsDblClick(Sender: TObject);
begin
  ExecuteSelected;
end;

procedure TMNoteCommandPalette.CommandMenuClick(Sender: TObject);
begin
  ShowPalette(pmCommands);
end;

procedure TMNoteCommandPalette.FileMenuClick(Sender: TObject);
begin
  ShowPalette(pmFiles);
end;

procedure TMNoteCommandPalette.InsertCommand(ACommand: TMNoteCommand;
  AScore: Integer);
var
  InsertAt: Integer;
  Current: TMNoteCommand;
begin
  InsertAt := 0;
  while InsertAt < FResults.Count do
  begin
    Current := TMNoteCommand(FResults.Items.Objects[InsertAt]);
    if (AScore > PtrInt(FScores[InsertAt])) or
      ((AScore = PtrInt(FScores[InsertAt])) and
       ((CompareText(ACommand.Title, Current.Title) < 0) or
        ((CompareText(ACommand.Title, Current.Title) = 0) and
         (CompareText(ACommand.ID, Current.ID) < 0)))) then
      Break;
    Inc(InsertAt);
  end;
  FResults.Items.InsertObject(InsertAt,
    ACommand.Title + '  —  ' + ACommand.Category, ACommand);
  FScores.Insert(InsertAt, Pointer(PtrInt(AScore)));
end;

procedure TMNoteCommandPalette.InsertFile(const AFileName: string;
  AScore: Integer);
var
  InsertAt: Integer;
begin
  InsertAt := 0;
  while InsertAt < FResults.Count do
  begin
    if (AScore > PtrInt(FScores[InsertAt])) or
      ((AScore = PtrInt(FScores[InsertAt])) and
       (CompareText(AFileName, FMatchedFiles[InsertAt]) < 0)) then
      Break;
    Inc(InsertAt);
  end;
  FResults.Items.Insert(InsertAt, ExtractFileName(AFileName) +
    '  —  ' + ExtractFileDir(AFileName));
  FMatchedFiles.Insert(InsertAt, AFileName);
  FScores.Insert(InsertAt, Pointer(PtrInt(AScore)));
end;

procedure TMNoteCommandPalette.RefreshMatches;
var
  I, ScoreValue: Integer;
  SearchText, Candidate: string;
  Files: TStringList;
  Command: TMNoteCommand;
begin
  if (FRegistry = nil) or (FResults = nil) then
    Exit;
  FResults.Items.BeginUpdate;
  try
    FResults.Clear;
    FScores.Clear;
    FMatchedFiles.Clear;
    SearchText := Trim(FEdit.Text);
    if FMode = pmCommands then
    begin
      for I := 0 to FRegistry.Count - 1 do
      begin
        Command := FRegistry[I];
        if not Command.Enabled then Continue;
        Candidate := Command.Title + ' ' + Command.Category;
        ScoreValue := TMNoteFuzzyMatcher.Score(SearchText, Candidate);
        if ScoreValue >= 0 then
          InsertCommand(Command, ScoreValue);
      end;
    end
    else
    begin
      Files := TStringList.Create;
      try
        if Assigned(FOnCollectFiles) then
          FOnCollectFiles(Files);
        Files.Sort;
        for I := 0 to Files.Count - 1 do
        begin
          ScoreValue := TMNoteFuzzyMatcher.Score(SearchText, Files[I]);
          if ScoreValue >= 0 then
            InsertFile(Files[I], ScoreValue);
        end;
      finally
        Files.Free;
      end;
    end;
    if FResults.Count > 0 then
      FResults.ItemIndex := 0;
  finally
    FResults.Items.EndUpdate;
  end;
end;

procedure TMNoteCommandPalette.ExecuteSelected;
var
  Command: TMNoteCommand;
  FileName: string;
begin
  if (FResults.ItemIndex < 0) or
    (FResults.ItemIndex >= FResults.Count) then Exit;
  if FMode = pmCommands then
  begin
    Command := TMNoteCommand(FResults.Items.Objects[FResults.ItemIndex]);
    if Command <> nil then
      Command.Execute(Self);
  end
  else if Assigned(FOnOpenFile) and
    (FResults.ItemIndex < FMatchedFiles.Count) then
  begin
    FileName := FMatchedFiles[FResults.ItemIndex];
    FOnOpenFile(FileName);
  end;
  ClosePalette;
end;

end.
