unit mnote_search_panel;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, StdCtrls, Menus, ComCtrls,
  SynEdit, mnote_search_types, mnote_text_search_service,
  mnote_file_search_service, mnote_file_replace_service;

type
  TMNoteCollectDocumentsEvent = procedure(
    ADocuments: TMNoteSearchDocuments) of object;
  TMNoteNavigateSearchEvent = procedure(const AFileName: string;
    ALine, AColumn, ALength: Integer) of object;
  TMNoteGetProjectFolderEvent = function(out AFolder: string): Boolean of object;

  { TMNoteSearchPanel }

  TMNoteSearchPanel = class(TComponent)
  private
    FBar: TPanel;
    FQuery: TComboBox;
    FReplacement: TEdit;
    FPreviousButton: TButton;
    FNextButton: TButton;
    FCloseButton: TButton;
    FReplaceButton: TButton;
    FReplaceAllButton: TButton;
    FMatchCase: TCheckBox;
    FWholeWord: TCheckBox;
    FRegex: TCheckBox;
    FWrap: TCheckBox;
    FPreserveCase: TCheckBox;
    FScope: TComboBox;
    FCounter: TLabel;
    FDebounce: TTimer;
    FResultsList: TListView;
    FResults: TMNoteSearchResults;
    FService: TMNoteTextSearchService;
    FActiveEditor: TSynEdit;
    FActiveFile: string;
    FCurrentIndex: Integer;
    FReplaceMode: Boolean;
    FHistory: TStringList;
    FNextMenuItem: TMenuItem;
    FPreviousMenuItem: TMenuItem;
    FReplaceFilesMenuItem: TMenuItem;
    FFileService: TMNoteFileSearchService;
    FFileReplaceService: TMNoteFileReplaceService;
    FFolderRoot: string;
    FOnCollectDocuments: TMNoteCollectDocumentsEvent;
    FOnNavigate: TMNoteNavigateSearchEvent;
    FOnGetProjectFolder: TMNoteGetProjectFolderEvent;
    procedure QueryChanged(Sender: TObject);
    procedure QueryKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OptionsChanged(Sender: TObject);
    procedure DebounceTimer(Sender: TObject);
    procedure PreviousClick(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    procedure ReplaceClick(Sender: TObject);
    procedure ReplaceAllClick(Sender: TObject);
    procedure NextMenuClick(Sender: TObject);
    procedure PreviousMenuClick(Sender: TObject);
    procedure ReplaceFilesMenuClick(Sender: TObject);
    procedure FileSearchCompleted(Sender: TObject; ACancelled: Boolean);
    procedure ResultsDblClick(Sender: TObject);
    procedure ApplyFileReplacePreview;
    procedure RunSearch;
    procedure ClearResults;
    procedure RefreshResultList;
    procedure RefreshCounter;
    procedure NavigateCurrent;
    procedure AddHistory(const AQuery: string);
    procedure UpdateHighlight;
    function BuildOptions: TMNoteSearchOptions;
    function ReplacementWithPreservedCase(const AMatchedText,
      AReplacement: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AParent: TWinControl; AMainMenu: TMainMenu;
      AResultsList: TListView);
    procedure SetActiveEditor(AEditor: TSynEdit; const AFileName: string);
    procedure EditorChanged;
    procedure ShowFind;
    procedure ShowReplace;
    procedure Close;
    procedure FindNext;
    procedure FindPrevious;
    procedure FindAllReferences(const AQuery: string);
    procedure NavigateResult(AIndex: Integer);
    property OnCollectDocuments: TMNoteCollectDocumentsEvent
      read FOnCollectDocuments write FOnCollectDocuments;
    property OnNavigate: TMNoteNavigateSearchEvent read FOnNavigate
      write FOnNavigate;
    property OnGetProjectFolder: TMNoteGetProjectFolderEvent
      read FOnGetProjectFolder write FOnGetProjectFolder;
  end;

implementation

uses
  Dialogs, Forms, LCLType, Types, SynEditTypes, LazUTF8, CheckLst;

constructor TMNoteSearchPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FResults := TMNoteSearchResults.Create;
  FService := TMNoteTextSearchService.Create;
  FFileService := TMNoteFileSearchService.Create;
  FFileReplaceService := TMNoteFileReplaceService.Create;
  FHistory := TStringList.Create;
  FCurrentIndex := -1;
end;

destructor TMNoteSearchPanel.Destroy;
begin
  FFileService.OnCompleted := nil;
  FFileService.Cancel;
  FFileService.WaitFor;
  if FActiveEditor <> nil then
    FActiveEditor.SetHighlightSearch('', []);
  FHistory.Free;
  FService.Free;
  FFileReplaceService.Free;
  FFileService.Free;
  FResults.Free;
  inherited Destroy;
end;

procedure TMNoteSearchPanel.Initialize(AParent: TWinControl;
  AMainMenu: TMainMenu; AResultsList: TListView);
var
  EditMenu: TMenuItem;
begin
  FResultsList := AResultsList;
  FResultsList.OnDblClick := @ResultsDblClick;

  FBar := TPanel.Create(Self);
  FBar.Name := 'pnIDESearch';
  FBar.Parent := AParent;
  FBar.Align := alTop;
  FBar.Height := 40;
  FBar.BevelOuter := bvLowered;
  FBar.Visible := False;

  FQuery := TComboBox.Create(Self);
  FQuery.Parent := FBar;
  FQuery.Left := 8;
  FQuery.Top := 7;
  FQuery.Width := 270;
  FQuery.Height := 27;
  FQuery.TextHint := 'Localizar';
  FQuery.OnChange := @QueryChanged;
  FQuery.OnKeyDown := @QueryKeyDown;

  FPreviousButton := TButton.Create(Self);
  FPreviousButton.Parent := FBar;
  FPreviousButton.SetBounds(284, 7, 30, 27);
  FPreviousButton.Caption := '↑';
  FPreviousButton.Hint := 'Ocorrência anterior (Shift+F3)';
  FPreviousButton.ShowHint := True;
  FPreviousButton.OnClick := @PreviousClick;

  FNextButton := TButton.Create(Self);
  FNextButton.Parent := FBar;
  FNextButton.SetBounds(318, 7, 30, 27);
  FNextButton.Caption := '↓';
  FNextButton.Hint := 'Próxima ocorrência (F3)';
  FNextButton.ShowHint := True;
  FNextButton.OnClick := @NextClick;

  FCounter := TLabel.Create(Self);
  FCounter.Parent := FBar;
  FCounter.SetBounds(356, 12, 70, 18);
  FCounter.Caption := '0 de 0';

  FMatchCase := TCheckBox.Create(Self);
  FMatchCase.Parent := FBar;
  FMatchCase.SetBounds(430, 9, 94, 24);
  FMatchCase.Caption := 'Diferenciar';
  FMatchCase.OnChange := @OptionsChanged;

  FWholeWord := TCheckBox.Create(Self);
  FWholeWord.Parent := FBar;
  FWholeWord.SetBounds(526, 9, 108, 24);
  FWholeWord.Caption := 'Palavra inteira';
  FWholeWord.OnChange := @OptionsChanged;

  FRegex := TCheckBox.Create(Self);
  FRegex.Parent := FBar;
  FRegex.SetBounds(636, 9, 66, 24);
  FRegex.Caption := 'Regex';
  FRegex.OnChange := @OptionsChanged;

  FScope := TComboBox.Create(Self);
  FScope.Parent := FBar;
  FWrap := TCheckBox.Create(Self);
  FWrap.Parent := FBar;
  FWrap.SetBounds(700, 9, 68, 24);
  FWrap.Caption := 'Circular';
  FWrap.Checked := True;
  FWrap.OnChange := @OptionsChanged;

  FScope.SetBounds(772, 7, 150, 27);
  FScope.Style := csDropDownList;
  FScope.Items.Add('Documento atual');
  FScope.Items.Add('Documentos abertos');
  FScope.Items.Add('Projeto');
  FScope.Items.Add('Pasta...');
  FScope.ItemIndex := 0;
  FScope.OnChange := @OptionsChanged;

  FCloseButton := TButton.Create(Self);
  FCloseButton.Parent := FBar;
  FCloseButton.SetBounds(928, 7, 30, 27);
  FCloseButton.Caption := '×';
  FCloseButton.Hint := 'Fechar (Esc)';
  FCloseButton.ShowHint := True;
  FCloseButton.OnClick := @CloseClick;

  FReplacement := TEdit.Create(Self);
  FReplacement.Parent := FBar;
  FReplacement.SetBounds(8, 41, 270, 27);
  FReplacement.TextHint := 'Substituir por';
  FReplacement.OnKeyDown := @QueryKeyDown;

  FReplaceButton := TButton.Create(Self);
  FReplaceButton.Parent := FBar;
  FReplaceButton.SetBounds(284, 41, 88, 27);
  FReplaceButton.Caption := 'Substituir';
  FReplaceButton.OnClick := @ReplaceClick;

  FReplaceAllButton := TButton.Create(Self);
  FReplaceAllButton.Parent := FBar;
  FReplaceAllButton.SetBounds(376, 41, 112, 27);
  FReplaceAllButton.Caption := 'Substituir tudo';
  FReplaceAllButton.OnClick := @ReplaceAllClick;

  FPreserveCase := TCheckBox.Create(Self);
  FPreserveCase.Parent := FBar;
  FPreserveCase.SetBounds(498, 43, 120, 24);
  FPreserveCase.Caption := 'Preservar caixa';

  FDebounce := TTimer.Create(Self);
  FDebounce.Enabled := False;
  FDebounce.Interval := 250;
  FDebounce.OnTimer := @DebounceTimer;

  if AMainMenu.Items.Count > 1 then
    EditMenu := AMainMenu.Items[1]
  else
    EditMenu := AMainMenu.Items;
  FNextMenuItem := TMenuItem.Create(Self);
  FNextMenuItem.Caption := 'Find Next';
  FNextMenuItem.ShortCut := Menus.ShortCut(VK_F3, []);
  FNextMenuItem.OnClick := @NextMenuClick;
  EditMenu.Add(FNextMenuItem);
  FPreviousMenuItem := TMenuItem.Create(Self);
  FPreviousMenuItem.Caption := 'Find Previous';
  FPreviousMenuItem.ShortCut := Menus.ShortCut(VK_F3, [ssShift]);
  FPreviousMenuItem.OnClick := @PreviousMenuClick;
  EditMenu.Add(FPreviousMenuItem);
  FReplaceFilesMenuItem := TMenuItem.Create(Self);
  FReplaceFilesMenuItem.Caption := 'Replace in Files...';
  FReplaceFilesMenuItem.ShortCut := Menus.ShortCut(VK_H, [ssCtrl, ssShift]);
  FReplaceFilesMenuItem.OnClick := @ReplaceFilesMenuClick;
  EditMenu.Add(FReplaceFilesMenuItem);
  FFileService.OnCompleted := @FileSearchCompleted;
end;

procedure TMNoteSearchPanel.SetActiveEditor(AEditor: TSynEdit;
  const AFileName: string);
begin
  if FActiveEditor <> AEditor then
  begin
    if FActiveEditor <> nil then
      FActiveEditor.SetHighlightSearch('', []);
    FActiveEditor := AEditor;
  end;
  FActiveFile := AFileName;
  if (FBar <> nil) and FBar.Visible then
  begin
    RunSearch;
    UpdateHighlight;
  end;
end;

procedure TMNoteSearchPanel.EditorChanged;
begin
  if (FBar <> nil) and FBar.Visible and (Trim(FQuery.Text) <> '') then
  begin
    FDebounce.Enabled := False;
    FDebounce.Enabled := True;
  end;
end;

procedure TMNoteSearchPanel.ShowFind;
begin
  FReplaceMode := False;
  FBar.Height := 40;
  FReplacement.Visible := False;
  FReplaceButton.Visible := False;
  FReplaceAllButton.Visible := False;
  FPreserveCase.Visible := False;
  FBar.Visible := True;
  FBar.BringToFront;
  if (FActiveEditor <> nil) and (FActiveEditor.SelText <> '') and
    (Pos(#10, FActiveEditor.SelText) = 0) then
    FQuery.Text := FActiveEditor.SelText;
  RunSearch;
  FQuery.SetFocus;
  FQuery.SelectAll;
end;

procedure TMNoteSearchPanel.ShowReplace;
begin
  ShowFind;
  FReplaceMode := True;
  FBar.Height := 74;
  FReplacement.Visible := True;
  FReplaceButton.Visible := True;
  FReplaceAllButton.Visible := True;
  FPreserveCase.Visible := True;
end;

procedure TMNoteSearchPanel.Close;
begin
  FDebounce.Enabled := False;
  FFileService.Cancel;
  if FActiveEditor <> nil then
    FActiveEditor.SetHighlightSearch('', []);
  ClearResults;
  FBar.Visible := False;
  if FActiveEditor <> nil then
    FActiveEditor.SetFocus;
end;

procedure TMNoteSearchPanel.QueryChanged(Sender: TObject);
begin
  FDebounce.Enabled := False;
  FDebounce.Enabled := True;
end;

procedure TMNoteSearchPanel.QueryKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        Close;
        Key := 0;
      end;
    VK_RETURN:
      begin
        if FReplaceMode and (Sender = FReplacement) then
          ReplaceClick(Sender)
        else if ssShift in Shift then
          FindPrevious
        else
          FindNext;
        Key := 0;
      end;
  end;
end;

procedure TMNoteSearchPanel.OptionsChanged(Sender: TObject);
begin
  if (Sender = FScope) and (FScope.ItemIndex = 3) and
    (not SelectDirectory('Selecione a pasta para pesquisar', '',
      FFolderRoot)) then
    FScope.ItemIndex := 0;
  QueryChanged(Sender);
end;

procedure TMNoteSearchPanel.DebounceTimer(Sender: TObject);
begin
  FDebounce.Enabled := False;
  RunSearch;
end;

procedure TMNoteSearchPanel.PreviousClick(Sender: TObject);
begin
  FindPrevious;
end;

procedure TMNoteSearchPanel.NextClick(Sender: TObject);
begin
  FindNext;
end;

procedure TMNoteSearchPanel.CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TMNoteSearchPanel.ReplaceClick(Sender: TObject);
var
  ResultItem: TMNoteSearchResult;
  ReplacementText: string;
  Options: TMNoteSearchOptions;
begin
  if (FActiveEditor = nil) or (FCurrentIndex < 0) or
    (FCurrentIndex >= FResults.Count) then Exit;
  ResultItem := FResults[FCurrentIndex];
  if not SameFileName(ResultItem.FileName, FActiveFile) then
    NavigateCurrent;
  ReplacementText := FReplacement.Text;
  Options := BuildOptions;
  if not FService.ResolveReplacement(ResultItem.MatchedText, FQuery.Text,
    ReplacementText, Options, ReplacementText) then
  begin
    MessageDlg('Substituir', FService.LastError, mtError, [mbOK], 0);
    Exit;
  end;
  if FPreserveCase.Checked and (not Options.RegularExpression) then
    ReplacementText := ReplacementWithPreservedCase(
      ResultItem.MatchedText, ReplacementText);
  FActiveEditor.BeginUndoBlock;
  try
    FActiveEditor.BlockBegin := Point(ResultItem.Column, ResultItem.Line);
    FActiveEditor.BlockEnd := Point(ResultItem.Column + ResultItem.Length,
      ResultItem.Line);
    FActiveEditor.SelText := ReplacementText;
  finally
    FActiveEditor.EndUndoBlock;
  end;
  RunSearch;
end;

procedure TMNoteSearchPanel.ReplaceAllClick(Sender: TObject);
var
  Options: TMNoteSearchOptions;
  NewText: string;
  ReplaceCount, I, ByteStart: Integer;
  PreserveResults: TMNoteSearchResults;
  ReplacementText: string;
begin
  if FActiveEditor = nil then Exit;
  if FScope.ItemIndex >= 2 then
  begin
    ApplyFileReplacePreview;
    Exit;
  end;
  Options := BuildOptions;
  Options.Scope := ssCurrentDocument;
  if FPreserveCase.Checked and (not Options.RegularExpression) then
  begin
    PreserveResults := TMNoteSearchResults.Create;
    try
      if not FService.SearchText(FActiveEditor.Text, FQuery.Text, FActiveFile,
        Options, PreserveResults) then
      begin
        MessageDlg('Substituir', FService.LastError, mtError, [mbOK], 0);
        Exit;
      end;
      NewText := FActiveEditor.Text;
      ReplaceCount := PreserveResults.Count;
      for I := PreserveResults.Count - 1 downto 0 do
      begin
        ByteStart := PreserveResults[I].AbsoluteIndex;
        ReplacementText := ReplacementWithPreservedCase(
          PreserveResults[I].MatchedText, FReplacement.Text);
        Delete(NewText, ByteStart, Length(PreserveResults[I].MatchedText));
        Insert(ReplacementText, NewText, ByteStart);
      end;
    finally
      PreserveResults.Free;
    end;
  end
  else if not FService.ReplaceText(FActiveEditor.Text, FQuery.Text,
    FReplacement.Text, Options, NewText, ReplaceCount) then
  begin
    MessageDlg('Substituir', FService.LastError, mtError, [mbOK], 0);
    Exit;
  end;
  if ReplaceCount = 0 then Exit;
  FActiveEditor.BeginUndoBlock;
  try
    FActiveEditor.SelectAll;
    FActiveEditor.SelText := NewText;
  finally
    FActiveEditor.EndUndoBlock;
  end;
  MessageDlg('Substituir', Format('%d ocorrência(s) substituída(s).',
    [ReplaceCount]), mtInformation, [mbOK], 0);
  RunSearch;
end;

procedure TMNoteSearchPanel.NextMenuClick(Sender: TObject);
begin
  FindNext;
end;

procedure TMNoteSearchPanel.PreviousMenuClick(Sender: TObject);
begin
  FindPrevious;
end;

procedure TMNoteSearchPanel.ReplaceFilesMenuClick(Sender: TObject);
var
  ProjectFolder: string;
begin
  ShowReplace;
  ProjectFolder := '';
  if Assigned(FOnGetProjectFolder) and
    FOnGetProjectFolder(ProjectFolder) then
    FScope.ItemIndex := 2
  else if SelectDirectory('Selecione a pasta para substituir', '',
    FFolderRoot) then
    FScope.ItemIndex := 3
  else
    FScope.ItemIndex := 0;
  RunSearch;
end;

procedure TMNoteSearchPanel.FileSearchCompleted(Sender: TObject;
  ACancelled: Boolean);
begin
  if ACancelled then
  begin
    FCounter.Caption := 'Pesquisa cancelada';
    Exit;
  end;
  if FFileService.LastError <> '' then
  begin
    FCounter.Caption := FFileService.LastError;
    Exit;
  end;
  RefreshResultList;
  if FResults.Count > 0 then
  begin
    FCurrentIndex := 0;
    NavigateCurrent;
  end;
  RefreshCounter;
end;

procedure TMNoteSearchPanel.ResultsDblClick(Sender: TObject);
begin
  if (FResultsList.Selected <> nil) then
    NavigateResult(FResultsList.Selected.Index);
end;

procedure TMNoteSearchPanel.ApplyFileReplacePreview;
var
  Preview: TMNoteFileReplacePreview;
  PreviewForm: TForm;
  FileList: TCheckListBox;
  ButtonPanel: TPanel;
  ApplyButton, CancelButton: TButton;
  I, FilesChanged, Replacements: Integer;
begin
  if FFileService.IsRunning then
  begin
    MessageDlg('Substituir em arquivos',
      'Aguarde a pesquisa terminar ou feche a barra para cancelar.',
      mtInformation, [mbOK], 0);
    Exit;
  end;
  if FResults.Count = 0 then
  begin
    MessageDlg('Substituir em arquivos', 'Nenhuma ocorrência para revisar.',
      mtInformation, [mbOK], 0);
    Exit;
  end;
  Preview := TMNoteFileReplacePreview.Create;
  try
    if not FFileReplaceService.BuildPreview(FQuery.Text, FReplacement.Text,
      BuildOptions, FResults, Preview) then
    begin
      MessageDlg('Substituir em arquivos', FFileReplaceService.LastError,
        mtError, [mbOK], 0);
      Exit;
    end;

    PreviewForm := TForm.CreateNew(nil);
    try
      PreviewForm.Caption := 'Preview — Substituir em arquivos';
      PreviewForm.Position := poOwnerFormCenter;
      PreviewForm.Width := 760;
      PreviewForm.Height := 440;
      PreviewForm.BorderStyle := bsSizeable;

      FileList := TCheckListBox.Create(PreviewForm);
      FileList.Parent := PreviewForm;
      FileList.Align := alClient;
      for I := 0 to Preview.Count - 1 do
      begin
        FileList.Items.Add(Format('%s — %d ocorrência(s)',
          [Preview[I].FileName, Preview[I].MatchCount]));
        FileList.Checked[I] := True;
      end;

      ButtonPanel := TPanel.Create(PreviewForm);
      ButtonPanel.Parent := PreviewForm;
      ButtonPanel.Align := alBottom;
      ButtonPanel.Height := 46;
      ButtonPanel.BevelOuter := bvNone;

      ApplyButton := TButton.Create(PreviewForm);
      ApplyButton.Parent := ButtonPanel;
      ApplyButton.Caption := 'Aplicar selecionados';
      ApplyButton.ModalResult := mrOK;
      ApplyButton.SetBounds(470, 8, 140, 30);
      ApplyButton.Anchors := [akTop, akRight];

      CancelButton := TButton.Create(PreviewForm);
      CancelButton.Parent := ButtonPanel;
      CancelButton.Caption := 'Cancelar';
      CancelButton.ModalResult := mrCancel;
      CancelButton.SetBounds(618, 8, 100, 30);
      CancelButton.Anchors := [akTop, akRight];

      if PreviewForm.ShowModal <> mrOK then Exit;
      for I := 0 to Preview.Count - 1 do
        Preview[I].Enabled := FileList.Checked[I];
    finally
      PreviewForm.Free;
    end;

    if not FFileReplaceService.ApplyPreview(Preview, FilesChanged,
      Replacements) then
    begin
      MessageDlg('Substituir em arquivos', FFileReplaceService.LastError,
        mtError, [mbOK], 0);
      Exit;
    end;
    MessageDlg('Substituir em arquivos',
      Format('%d substituição(ões) aplicada(s) em %d arquivo(s).',
        [Replacements, FilesChanged]), mtInformation, [mbOK], 0);
    RunSearch;
  finally
    Preview.Free;
  end;
end;

function TMNoteSearchPanel.BuildOptions: TMNoteSearchOptions;
begin
  Result := DefaultSearchOptions;
  Result.MatchCase := FMatchCase.Checked;
  Result.WholeWord := FWholeWord.Checked;
  Result.RegularExpression := FRegex.Checked;
  Result.WrapAround := FWrap.Checked;
  case FScope.ItemIndex of
    1: Result.Scope := ssOpenDocuments;
    2: Result.Scope := ssProject;
    3: Result.Scope := ssFolder;
  else
    Result.Scope := ssCurrentDocument;
  end;
end;

procedure TMNoteSearchPanel.RunSearch;
var
  Options: TMNoteSearchOptions;
  Documents: TMNoteSearchDocuments;
  DocumentIndex, ResultIndex: Integer;
  DocumentResults: TMNoteSearchResults;
  SearchResult: TMNoteSearchResult;
  SearchRoot: string;
begin
  ClearResults;
  Options := BuildOptions;
  if (Trim(FQuery.Text) = '') or
    ((FActiveEditor = nil) and
     (Options.Scope in [ssCurrentDocument, ssOpenDocuments])) then
  begin
    UpdateHighlight;
    Exit;
  end;
  if Options.Scope = ssCurrentDocument then
  begin
    if not FService.SearchText(FActiveEditor.Text, FQuery.Text, FActiveFile,
      Options, FResults) then
    begin
      FCounter.Caption := FService.LastError;
      UpdateHighlight;
      Exit;
    end;
  end
  else if Options.Scope = ssOpenDocuments then
  begin
    Documents := TMNoteSearchDocuments.Create;
    DocumentResults := TMNoteSearchResults.Create;
    try
      if Assigned(FOnCollectDocuments) then
        FOnCollectDocuments(Documents);
      for DocumentIndex := 0 to Documents.Count - 1 do
      begin
        if not FService.SearchText(Documents[DocumentIndex].Text,
          FQuery.Text, Documents[DocumentIndex].FileName, Options,
          DocumentResults) then
        begin
          FCounter.Caption := FService.LastError;
          Exit;
        end;
        for ResultIndex := 0 to DocumentResults.Count - 1 do
        begin
          SearchResult := DocumentResults[ResultIndex];
          FResults.Add(TMNoteSearchResult.Create(SearchResult.FileName,
            SearchResult.Line, SearchResult.Column, SearchResult.Length,
            SearchResult.Preview, SearchResult.MatchedText,
            SearchResult.AbsoluteIndex));
        end;
      end;
    finally
      DocumentResults.Free;
      Documents.Free;
    end;
  end
  else
  begin
    SearchRoot := '';
    if Options.Scope = ssProject then
    begin
      if (not Assigned(FOnGetProjectFolder)) or
        (not FOnGetProjectFolder(SearchRoot)) then
      begin
        FCounter.Caption := 'Projeto sem pasta configurada';
        Exit;
      end;
    end
    else
      SearchRoot := FFolderRoot;
    if not DirectoryExists(SearchRoot) then
    begin
      FCounter.Caption := 'Pasta de pesquisa inválida';
      Exit;
    end;
    if FFileService.IsRunning then
    begin
      FFileService.Cancel;
      FFileService.WaitFor;
    end;
    FCounter.Caption := 'Pesquisando...';
    AddHistory(FQuery.Text);
    if not FFileService.StartSearch(SearchRoot, FQuery.Text, Options,
      FResults) then
      FCounter.Caption := FFileService.LastError;
    UpdateHighlight;
    Exit;
  end;
  AddHistory(FQuery.Text);
  RefreshResultList;
  UpdateHighlight;
  if FResults.Count > 0 then
  begin
    FCurrentIndex := 0;
    NavigateCurrent;
  end;
  RefreshCounter;
end;

procedure TMNoteSearchPanel.FindAllReferences(const AQuery: string);
begin
  FBar.Visible := True;
  FBar.Height := 40;
  FReplacement.Visible := False;
  FReplaceButton.Visible := False;
  FReplaceAllButton.Visible := False;
  FPreserveCase.Visible := False;
  FScope.ItemIndex := 2;
  FWholeWord.Checked := True;
  FRegex.Checked := False;
  FQuery.Text := AQuery;
  FQuery.SetFocus;
  RunSearch;
end;

procedure TMNoteSearchPanel.ClearResults;
begin
  FCurrentIndex := -1;
  if FResultsList <> nil then
    FResultsList.Items.Clear;
  FResults.Clear;
  RefreshCounter;
end;

procedure TMNoteSearchPanel.RefreshResultList;
var
  I: Integer;
  ListItem: TListItem;
begin
  if FResultsList = nil then Exit;
  FResultsList.Items.BeginUpdate;
  try
    FResultsList.Items.Clear;
    for I := 0 to FResults.Count - 1 do
    begin
      ListItem := FResultsList.Items.Add;
      ListItem.Caption := FResults[I].FileName;
      ListItem.SubItems.Add(IntToStr(FResults[I].Line));
      ListItem.SubItems.Add(IntToStr(FResults[I].Column));
      ListItem.SubItems.Add(FResults[I].Preview);
      ListItem.Data := FResults[I];
    end;
    FResultsList.Visible := FResults.Count > 0;
  finally
    FResultsList.Items.EndUpdate;
  end;
end;

procedure TMNoteSearchPanel.RefreshCounter;
begin
  if FResults.Count = 0 then
    FCounter.Caption := '0 de 0'
  else if FCurrentIndex < 0 then
    FCounter.Caption := Format('0 de %d', [FResults.Count])
  else
    FCounter.Caption := Format('%d de %d',
      [FCurrentIndex + 1, FResults.Count]);
end;

procedure TMNoteSearchPanel.NavigateCurrent;
var
  SearchResult: TMNoteSearchResult;
begin
  if (FCurrentIndex < 0) or (FCurrentIndex >= FResults.Count) then Exit;
  SearchResult := FResults[FCurrentIndex];
  if Assigned(FOnNavigate) then
    FOnNavigate(SearchResult.FileName, SearchResult.Line,
      SearchResult.Column, SearchResult.Length);
  if FResultsList <> nil then
    FResultsList.Selected := FResultsList.Items[FCurrentIndex];
  RefreshCounter;
end;

procedure TMNoteSearchPanel.FindNext;
begin
  if FResults.Count = 0 then
  begin
    RunSearch;
    Exit;
  end;
  if FCurrentIndex < FResults.Count - 1 then
    Inc(FCurrentIndex)
  else if BuildOptions.WrapAround then
    FCurrentIndex := 0
  else
    Exit;
  NavigateCurrent;
end;

procedure TMNoteSearchPanel.FindPrevious;
begin
  if FResults.Count = 0 then
  begin
    RunSearch;
    Exit;
  end;
  if FCurrentIndex > 0 then
    Dec(FCurrentIndex)
  else if BuildOptions.WrapAround then
    FCurrentIndex := FResults.Count - 1
  else
    Exit;
  NavigateCurrent;
end;

procedure TMNoteSearchPanel.NavigateResult(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FResults.Count) then Exit;
  FCurrentIndex := AIndex;
  NavigateCurrent;
end;

procedure TMNoteSearchPanel.AddHistory(const AQuery: string);
var
  Existing: Integer;
begin
  if Trim(AQuery) = '' then Exit;
  Existing := FHistory.IndexOf(AQuery);
  if Existing >= 0 then
    FHistory.Delete(Existing);
  FHistory.Insert(0, AQuery);
  while FHistory.Count > 20 do
    FHistory.Delete(FHistory.Count - 1);
  FQuery.Items.Assign(FHistory);
end;

procedure TMNoteSearchPanel.UpdateHighlight;
var
  Options: TSynSearchOptions;
begin
  if FActiveEditor = nil then Exit;
  Options := [];
  if FMatchCase.Checked then Include(Options, ssoMatchCase);
  if FWholeWord.Checked then Include(Options, ssoWholeWord);
  if FRegex.Checked then Include(Options, ssoRegExpr);
  if (FBar <> nil) and FBar.Visible and (FService.LastError = '') then
    FActiveEditor.SetHighlightSearch(FQuery.Text, Options)
  else
    FActiveEditor.SetHighlightSearch('', []);
end;

function TMNoteSearchPanel.ReplacementWithPreservedCase(
  const AMatchedText, AReplacement: string): string;
var
  FirstCharacter: string;
begin
  Result := AReplacement;
  if (AMatchedText = '') or (AReplacement = '') then Exit;
  if UTF8UpperCase(AMatchedText) = AMatchedText then
    Exit(UTF8UpperCase(AReplacement));
  FirstCharacter := UTF8Copy(AMatchedText, 1, 1);
  if UTF8UpperCase(FirstCharacter) = FirstCharacter then
    Result := UTF8UpperCase(UTF8Copy(AReplacement, 1, 1)) +
      UTF8Copy(AReplacement, 2, MaxInt);
end;

end.
