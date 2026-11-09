unit mquery_querytabs;

{ Abas de consulta do MQuery.

  - TMQueryCompletionController: liga um TSynCompletion a um TSynEdit e a um
    catalogo. Sugere tabelas depois de FROM/JOIN, colunas depois de
    "apelido.", filtra a lista conforme a digitacao e abre sozinho ao
    digitar ".". Usado tanto nos editores antigos de cada banco quanto nas
    novas abas de consulta.

  - TMQueryQueryTab: uma consulta. Editor em cima, divisor arrastavel e
    resultado embaixo (grade + mensagens), com barra de situacao.

  - TMQueryQueryBook: a aba "Consultas" de um banco, com varias consultas,
    botoes Nova/Abrir/Salvar/Fechar/Executar e a conexao daquele banco. }

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Controls, Forms, ComCtrls, ExtCtrls, StdCtrls,
  Dialogs, Graphics, Menus, LCLType, DB, DBGrids, DBCtrls,
  SynEdit, SynEditKeyCmds, SynCompletion, SynEditHighlighter,
  ZConnection, ZDataset, mquery_sqlassist;

type

  { TMQueryCompletionController }

  TMQueryCompletionController = class(TComponent)
  private
    FCompletion: TSynCompletion;
    FEditor: TSynEdit;
    FCatalog: TMQueryCatalog;
    FOldCommandProcessed: TProcessCommandEvent;
    procedure CompletionExecute(Sender: TObject);
    procedure CompletionSearchPosition(var APosition: Integer);
    procedure EditorCommandProcessed(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: Pointer);
    procedure OpenAsync(Data: PtrInt);
    function TextBeforeCaret: string;
    procedure Fill;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor CreateFor(AOwner: TComponent; ACompletion: TSynCompletion;
      AEditor: TSynEdit; ACatalog: TMQueryCatalog);
    destructor Destroy; override;
    procedure Open;
    property Catalog: TMQueryCatalog read FCatalog write FCatalog;
  end;

  TMQueryQueryBook = class;

  { TMQueryQueryTab }

  TMQueryQueryTab = class(TTabSheet)
  private
    FBook: TMQueryQueryBook;
    FTitle: string;
    FFileName: string;
    FEditor: TSynEdit;
    FSplitter: TSplitter;
    FResultPages: TPageControl;
    FTabGrid: TTabSheet;
    FTabMsg: TTabSheet;
    FGridBar: TPanel;
    FNav: TDBNavigator;
    FEditCheck: TCheckBox;
    FGrid: TDBGrid;
    FMsg: TMemo;
    FStatus: TStatusBar;
    FQuery: TZQuery;
    FExec: TZQuery;
    FDS: TDataSource;
    FCompletion: TSynCompletion;
    FAssist: TMQueryCompletionController;
    FSized: Boolean;
    procedure EditorChange(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditCheckChange(Sender: TObject);
    procedure DataChange(Sender: TObject; Field: TField);
    procedure TabResize(Sender: TObject);
    procedure AddMsg(const S: string);
    procedure UpdateCaption;
    procedure UpdateRecordStatus;
  public
    constructor CreateQuery(ABook: TMQueryQueryBook; const ATitle: string);
    destructor Destroy; override;
    procedure Execute;
    procedure LoadFromFile(const AFileName: string);
    function Save(AAskName: Boolean): Boolean;
    function CanClose: Boolean;
    function IsModified: Boolean;
    property Editor: TSynEdit read FEditor;
    property Query: TZQuery read FQuery;
    property FileName: string read FFileName;
  end;

  { TMQueryQueryBook }

  TMQueryQueryBook = class(TComponent)
  private
    FHost: TPageControl;
    FPage: TTabSheet;
    FBar: TPanel;
    FTabs: TPageControl;
    FTabMenu: TPopupMenu;
    FConnection: TZConnection;
    FCatalog: TMQueryCatalog;
    FTemplate: TSynEdit;
    FEngineName: string;
    FCounter: Integer;
    FOpenDialog: TOpenDialog;
    FSaveDialog: TSaveDialog;
    function NewButton(const ACaption, AHint: string; AWidth: Integer;
      AHandler: TNotifyEvent): TButton;
    procedure BtnNewClick(Sender: TObject);
    procedure BtnOpenClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnSaveAsClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnRunClick(Sender: TObject);
    procedure MenuCloseOthersClick(Sender: TObject);
    procedure TabsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CloseAsync(Data: PtrInt);
    function HasTab(ATab: TMQueryQueryTab): Boolean;
  public
    constructor CreateBook(AOwner: TComponent; AHost: TPageControl;
      AConnection: TZConnection; ACatalog: TMQueryCatalog; ATemplate: TSynEdit;
      const AEngineName: string; APageIndex: Integer);
    destructor Destroy; override;
    function NewQuery(const AText: string = ''): TMQueryQueryTab;
    function ActiveQuery: TMQueryQueryTab;
    function CloseQuery(ATab: TMQueryQueryTab): Boolean;
    procedure CloseQueryLater(ATab: TMQueryQueryTab);
    procedure OpenFile;
    procedure Show;
    property Page: TTabSheet read FPage;
    property Tabs: TPageControl read FTabs;
    property Connection: TZConnection read FConnection write FConnection;
    property Catalog: TMQueryCatalog read FCatalog;
    property Template: TSynEdit read FTemplate;
    property EngineName: string read FEngineName;
    property SaveDialog: TSaveDialog read FSaveDialog;
  end;

implementation

function FormatElapsed(AMs: QWord): string;
var
  H, M, S, Ms: QWord;
begin
  H := AMs div 3600000;
  M := (AMs div 60000) mod 60;
  S := (AMs div 1000) mod 60;
  Ms := AMs mod 1000;
  Result := Format('%.2d:%.2d:%.2d.%.3d', [H, M, S, Ms]);
end;

{ TMQueryCompletionController }

constructor TMQueryCompletionController.CreateFor(AOwner: TComponent;
  ACompletion: TSynCompletion; AEditor: TSynEdit; ACatalog: TMQueryCatalog);
begin
  inherited Create(AOwner);
  FCompletion := ACompletion;
  FEditor := AEditor;
  FCatalog := ACatalog;

  if FCompletion <> nil then
  begin
    FCompletion.FreeNotification(Self);
    if FEditor <> nil then
      FCompletion.Editor := FEditor;
    FCompletion.ShortCut := Menus.ShortCut(VK_SPACE, [ssCtrl]);
    FCompletion.EndOfTokenChr := '()[]+-*/=<>;,'' ';
    FCompletion.CaseSensitive := False;
    FCompletion.AutoUseSingleIdent := False;
    FCompletion.Width := 420;
    FCompletion.LinesInWindow := 12;
    FCompletion.OnExecute := @CompletionExecute;
    FCompletion.OnSearchPosition := @CompletionSearchPosition;
  end;

  if FEditor <> nil then
  begin
    FEditor.FreeNotification(Self);
    FOldCommandProcessed := FEditor.OnCommandProcessed;
    FEditor.OnCommandProcessed := @EditorCommandProcessed;
  end;
end;

destructor TMQueryCompletionController.Destroy;
begin
  Application.RemoveAsyncCalls(Self);
  if FEditor <> nil then
  begin
    FEditor.OnCommandProcessed := FOldCommandProcessed;
    FEditor.RemoveFreeNotification(Self);
  end;
  if FCompletion <> nil then
  begin
    FCompletion.OnExecute := nil;
    FCompletion.OnSearchPosition := nil;
    FCompletion.RemoveFreeNotification(Self);
  end;
  inherited Destroy;
end;

procedure TMQueryCompletionController.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FEditor then FEditor := nil;
    if AComponent = FCompletion then FCompletion := nil;
  end;
end;

function TMQueryCompletionController.TextBeforeCaret: string;
var
  P: TPoint;
  I, First: Integer;
begin
  Result := '';
  if FEditor = nil then Exit;
  P := FEditor.LogicalCaretXY;
  // As ultimas 300 linhas bastam para achar a clausula atual.
  First := Max(0, P.Y - 1 - 300);
  for I := First to P.Y - 2 do
    if I < FEditor.Lines.Count then
      Result := Result + FEditor.Lines[I] + LineEnding;
  if (P.Y >= 1) and (P.Y - 1 < FEditor.Lines.Count) then
    Result := Result + Copy(FEditor.Lines[P.Y - 1], 1, P.X - 1);
end;

procedure TMQueryCompletionController.Fill;
var
  Items: TStringList;
begin
  if (FCompletion = nil) or (FEditor = nil) then Exit;
  Items := TStringList.Create;
  try
    BuildCompletionItems(FCatalog, FEditor.Lines.Text, TextBeforeCaret,
      FCompletion.CurrentString, Items);
    FCompletion.ItemList.Assign(Items);
  finally
    Items.Free;
  end;
end;

procedure TMQueryCompletionController.CompletionExecute(Sender: TObject);
begin
  Fill;
end;

procedure TMQueryCompletionController.CompletionSearchPosition(var APosition: Integer);
begin
  Fill;
  if FCompletion.ItemList.Count > 0 then
    APosition := 0
  else
    APosition := -1;
end;

procedure TMQueryCompletionController.EditorCommandProcessed(Sender: TObject;
  var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: Pointer);
begin
  if Assigned(FOldCommandProcessed) then
    FOldCommandProcessed(Sender, Command, AChar, Data);
  // Abre a lista sozinho ao digitar "." (apelido.coluna / esquema.tabela)
  if (Command = ecChar) and (AChar = '.') and (FCatalog <> nil) and
     (FCatalog.TableCount > 0) then
    Application.QueueAsyncCall(@OpenAsync, 0);
end;

procedure TMQueryCompletionController.OpenAsync(Data: PtrInt);
begin
  if (FEditor <> nil) and FEditor.Focused then
    Open;
end;

procedure TMQueryCompletionController.Open;
begin
  if (FEditor = nil) or (FCompletion = nil) then Exit;
  if FCompletion.IsActive then Exit;
  FEditor.CommandProcessor(FCompletion.ExecCommandID, '', nil);
end;

{ TMQueryQueryTab }

constructor TMQueryQueryTab.CreateQuery(ABook: TMQueryQueryBook; const ATitle: string);
var
  Bottom: TPanel;
begin
  inherited Create(ABook);
  FBook := ABook;
  FTitle := ATitle;
  PageControl := ABook.Tabs;

  // ---- resultado (embaixo) ----
  FStatus := TStatusBar.Create(Self);
  FStatus.Parent := Self;
  FStatus.SimplePanel := True;
  FStatus.SimpleText := 'Pronto. F5 ou Ctrl+Enter executa (a seleção, se houver).';

  Bottom := TPanel.Create(Self);
  Bottom.Parent := Self;
  Bottom.BevelOuter := bvNone;
  Bottom.Align := alClient;

  // ---- editor (em cima) ----
  FEditor := TSynEdit.Create(Self);
  FEditor.Parent := Self;
  FEditor.Align := alTop;
  FEditor.Height := 220;
  if (ABook.Template <> nil) then
  begin
    FEditor.Font.Assign(ABook.Template.Font);
    FEditor.Highlighter := ABook.Template.Highlighter;
  end
  else
  begin
    FEditor.Font.Name := 'Courier New';
    FEditor.Font.Height := -13;
  end;
  FEditor.TabWidth := 2;
  FEditor.OnChange := @EditorChange;
  FEditor.OnKeyDown := @EditorKeyDown;

  FSplitter := TSplitter.Create(Self);
  FSplitter.Parent := Self;
  FSplitter.Align := alTop;
  FSplitter.Top := FEditor.Top + FEditor.Height + 1;
  FSplitter.Height := 6;
  FSplitter.ResizeStyle := rsUpdate;

  FResultPages := TPageControl.Create(Self);
  FResultPages.Parent := Bottom;
  FResultPages.Align := alClient;
  FResultPages.TabPosition := tpBottom;

  FTabGrid := TTabSheet.Create(Self);
  FTabGrid.PageControl := FResultPages;
  FTabGrid.Caption := 'Dados';

  FTabMsg := TTabSheet.Create(Self);
  FTabMsg.PageControl := FResultPages;
  FTabMsg.Caption := 'Mensagens';

  FGridBar := TPanel.Create(Self);
  FGridBar.Parent := FTabGrid;
  FGridBar.Align := alTop;
  FGridBar.Height := 30;
  FGridBar.BevelOuter := bvNone;
  FGridBar.Caption := '';

  FQuery := TZQuery.Create(Self);
  FQuery.Connection := ABook.Connection;
  FQuery.ParamCheck := False;

  FExec := TZQuery.Create(Self);
  FExec.Connection := ABook.Connection;
  FExec.ParamCheck := False;

  FDS := TDataSource.Create(Self);
  FDS.DataSet := FQuery;
  FDS.OnDataChange := @DataChange;

  FNav := TDBNavigator.Create(Self);
  FNav.Parent := FGridBar;
  FNav.Left := 4;
  FNav.Top := 3;
  FNav.Height := 24;
  FNav.Width := 240;
  FNav.DataSource := FDS;

  FEditCheck := TCheckBox.Create(Self);
  FEditCheck.Parent := FGridBar;
  FEditCheck.Left := FNav.Left + FNav.Width + 12;
  FEditCheck.Top := 6;
  FEditCheck.Caption := 'Permitir edição na grade';
  FEditCheck.Checked := False;
  FEditCheck.OnChange := @EditCheckChange;

  FGrid := TDBGrid.Create(Self);
  FGrid.Parent := FTabGrid;
  FGrid.Align := alClient;
  FGrid.DataSource := FDS;
  FGrid.ReadOnly := True;
  FGrid.Options := FGrid.Options + [dgAlwaysShowSelection, dgTruncCellHints,
    dgCellHints, dgDisplayMemoText] - [dgEditing];

  FMsg := TMemo.Create(Self);
  FMsg.Parent := FTabMsg;
  FMsg.Align := alClient;
  FMsg.ReadOnly := True;
  FMsg.ScrollBars := ssAutoBoth;
  FMsg.WordWrap := False;

  // ---- autocompletar ----
  FCompletion := TSynCompletion.Create(Self);
  FCompletion.Editor := FEditor;
  FAssist := TMQueryCompletionController.CreateFor(Self, FCompletion, FEditor,
    ABook.Catalog);

  FResultPages.ActivePage := FTabGrid;
  OnResize := @TabResize;
  UpdateCaption;
end;

destructor TMQueryQueryTab.Destroy;
begin
  if FQuery <> nil then FQuery.Close;
  inherited Destroy;
end;

procedure TMQueryQueryTab.TabResize(Sender: TObject);
begin
  // Na primeira vez que a aba ganha tamanho, o editor fica com ~45% da altura
  if (not FSized) and (ClientHeight > 200) then
  begin
    FSized := True;
    FEditor.Height := Max(120, ClientHeight * 45 div 100);
  end;
end;

function TMQueryQueryTab.IsModified: Boolean;
begin
  Result := FEditor.Modified;
end;

procedure TMQueryQueryTab.UpdateCaption;
var
  S: string;
begin
  if FFileName <> '' then
    S := ExtractFileName(FFileName)
  else
    S := FTitle;
  if IsModified then
    S := S + '*';
  Caption := S;
end;

procedure TMQueryQueryTab.EditorChange(Sender: TObject);
begin
  UpdateCaption;
end;

procedure TMQueryQueryTab.EditorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F5) or ((Key = VK_RETURN) and (ssCtrl in Shift)) then
  begin
    Key := 0;
    Execute;
  end
  else if (ssCtrl in Shift) and (Key = VK_S) then
  begin
    Key := 0;
    Save(ssShift in Shift);
  end
  else if (ssCtrl in Shift) and (Key = VK_N) then
  begin
    Key := 0;
    FBook.NewQuery;
  end
  else if (ssCtrl in Shift) and (Key = VK_O) then
  begin
    Key := 0;
    FBook.OpenFile;
  end
  else if (ssCtrl in Shift) and ((Key = VK_W) or (Key = VK_F4)) then
  begin
    Key := 0;
    // A aba nao pode ser liberada dentro do evento do proprio editor
    FBook.CloseQueryLater(Self);
  end;
end;

procedure TMQueryQueryTab.EditCheckChange(Sender: TObject);
begin
  FGrid.ReadOnly := not FEditCheck.Checked;
  if FEditCheck.Checked then
    FGrid.Options := FGrid.Options + [dgEditing]
  else
    FGrid.Options := FGrid.Options - [dgEditing];
end;

procedure TMQueryQueryTab.DataChange(Sender: TObject; Field: TField);
begin
  if Field = nil then
    UpdateRecordStatus;
end;

procedure TMQueryQueryTab.UpdateRecordStatus;
begin
  if (FQuery <> nil) and FQuery.Active then
    FNav.Hint := Format('Registro %d de %d', [FQuery.RecNo, FQuery.RecordCount]);
end;

procedure TMQueryQueryTab.AddMsg(const S: string);
begin
  FMsg.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + S);
end;

procedure TMQueryQueryTab.Execute;
var
  SQLText, Cmd: string;
  Cmds: TStringList;
  I, Afetadas, Erros: Integer;
  T0, T1: QWord;
  Linhas: Integer;
begin
  if (FBook.Connection = nil) or not FBook.Connection.Connected then
  begin
    FStatus.SimpleText := FBook.EngineName + ' não conectado. Conecte na aba de conexão.';
    MessageDlg('MQuery', FBook.EngineName + ' não conectado.' + LineEnding +
      'Conecte na aba de conexão antes de executar.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if FEditor.SelAvail then
    SQLText := FEditor.SelText
  else
    SQLText := FEditor.Lines.Text;
  if Trim(SQLText) = '' then Exit;

  FQuery.Connection := FBook.Connection;
  FExec.Connection := FBook.Connection;

  Cmds := TStringList.Create;
  try
    SplitSQLStatements(SQLText, Cmds);
    if Cmds.Count = 0 then Exit;

    FMsg.Clear;
    Afetadas := 0;
    Erros := 0;
    Linhas := -1;
    FStatus.SimpleText := 'Executando...';
    Screen.Cursor := crSQLWait;
    T0 := GetTickCount64;
    try
      for I := 0 to Cmds.Count - 1 do
      begin
        Cmd := Cmds[I];
        try
          if StatementReturnsRows(Cmd) then
          begin
            FQuery.Close;
            FQuery.SQL.Text := Cmd;
            FQuery.Open;
            Linhas := FQuery.RecordCount;
            AddMsg(Format('%d registro(s) retornado(s).', [Linhas]));
          end
          else
          begin
            FExec.Close;
            FExec.SQL.Text := Cmd;
            FExec.ExecSQL;
            Inc(Afetadas, Max(0, FExec.RowsAffected));
            AddMsg(Format('Comando executado. %d linha(s) afetada(s).',
              [FExec.RowsAffected]));
          end;
        except
          on E: Exception do
          begin
            Inc(Erros);
            AddMsg('Erro: ' + E.Message);
            AddMsg('Comando: ' + Copy(Cmd, 1, 500));
            Break;  // para no primeiro erro, como os editores SQL usuais
          end;
        end;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
    T1 := GetTickCount64 - T0;

    if Erros > 0 then
    begin
      FStatus.SimpleText := 'Erro na execução. Veja a aba Mensagens.   ' + FormatElapsed(T1);
      FResultPages.ActivePage := FTabMsg;
    end
    else
    begin
      if Linhas >= 0 then
        FStatus.SimpleText := Format('Consulta executada com sucesso.   %d registro(s)   %s',
          [Linhas, FormatElapsed(T1)])
      else
        FStatus.SimpleText := Format('Comando executado com sucesso.   %d linha(s) afetada(s)   %s',
          [Afetadas, FormatElapsed(T1)]);
      if FQuery.Active then
        FResultPages.ActivePage := FTabGrid
      else
        FResultPages.ActivePage := FTabMsg;
    end;
    UpdateRecordStatus;
  finally
    Cmds.Free;
  end;
end;

procedure TMQueryQueryTab.LoadFromFile(const AFileName: string);
begin
  FEditor.Lines.LoadFromFile(AFileName);
  FFileName := AFileName;
  FEditor.Modified := False;
  UpdateCaption;
end;

function TMQueryQueryTab.Save(AAskName: Boolean): Boolean;
var
  Dlg: TSaveDialog;
begin
  Result := False;
  if AAskName or (FFileName = '') then
  begin
    Dlg := FBook.SaveDialog;
    if FFileName <> '' then
      Dlg.FileName := FFileName
    else
      Dlg.FileName := FTitle + '.sql';
    if not Dlg.Execute then Exit;
    FFileName := Dlg.FileName;
  end;
  FEditor.Lines.SaveToFile(FFileName);
  FEditor.Modified := False;
  UpdateCaption;
  Result := True;
end;

function TMQueryQueryTab.CanClose: Boolean;
begin
  Result := True;
  if not IsModified then Exit;
  if Trim(FEditor.Lines.Text) = '' then Exit;
  case MessageDlg('MQuery', 'Salvar as alterações em "' + Caption + '"?',
         mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
    mrYes: Result := Save(False);
    mrNo: Result := True;
  else
    Result := False;
  end;
end;

{ TMQueryQueryBook }

constructor TMQueryQueryBook.CreateBook(AOwner: TComponent; AHost: TPageControl;
  AConnection: TZConnection; ACatalog: TMQueryCatalog; ATemplate: TSynEdit;
  const AEngineName: string; APageIndex: Integer);
var
  Item: TMenuItem;
begin
  inherited Create(AOwner);
  FHost := AHost;
  FConnection := AConnection;
  FCatalog := ACatalog;
  FTemplate := ATemplate;
  FEngineName := AEngineName;

  FPage := TTabSheet.Create(Self);
  FPage.PageControl := FHost;
  FPage.Caption := 'Consultas';
  if (APageIndex >= 0) and (APageIndex < FHost.PageCount) then
    FPage.PageIndex := APageIndex;

  FBar := TPanel.Create(Self);
  FBar.Parent := FPage;
  FBar.Align := alTop;
  FBar.Height := 32;
  FBar.BevelOuter := bvNone;
  FBar.Caption := '';

  // Botoes da direita para a esquerda (alLeft empilha na ordem de criacao)
  NewButton('Nova consulta', 'Nova consulta (Ctrl+N)', 112, @BtnNewClick);
  NewButton('Abrir...', 'Abrir arquivo .sql (Ctrl+O)', 70, @BtnOpenClick);
  NewButton('Salvar', 'Salvar (Ctrl+S)', 64, @BtnSaveClick);
  NewButton('Salvar como...', 'Salvar como (Ctrl+Shift+S)', 100, @BtnSaveAsClick);
  NewButton('Fechar', 'Fechar consulta (Ctrl+W)', 64, @BtnCloseClick);
  NewButton('Executar (F5)', 'Executa a seleção ou o texto todo (F5 / Ctrl+Enter)',
    100, @BtnRunClick);

  FTabs := TPageControl.Create(Self);
  FTabs.Parent := FPage;
  FTabs.Align := alClient;
  FTabs.OnMouseUp := @TabsMouseUp;

  FTabMenu := TPopupMenu.Create(Self);
  Item := TMenuItem.Create(FTabMenu);
  Item.Caption := 'Nova consulta';
  Item.OnClick := @BtnNewClick;
  FTabMenu.Items.Add(Item);
  Item := TMenuItem.Create(FTabMenu);
  Item.Caption := 'Fechar';
  Item.OnClick := @BtnCloseClick;
  FTabMenu.Items.Add(Item);
  Item := TMenuItem.Create(FTabMenu);
  Item.Caption := 'Fechar as outras';
  Item.OnClick := @MenuCloseOthersClick;
  FTabMenu.Items.Add(Item);
  FTabs.PopupMenu := FTabMenu;

  FOpenDialog := TOpenDialog.Create(Self);
  FOpenDialog.Filter := 'Arquivos SQL (*.sql)|*.sql|Todos os arquivos (*.*)|*.*';
  FOpenDialog.Options := FOpenDialog.Options + [ofAllowMultiSelect, ofFileMustExist];

  FSaveDialog := TSaveDialog.Create(Self);
  FSaveDialog.Filter := FOpenDialog.Filter;
  FSaveDialog.DefaultExt := 'sql';
  FSaveDialog.Options := FSaveDialog.Options + [ofOverwritePrompt];

  NewQuery;
end;

destructor TMQueryQueryBook.Destroy;
begin
  Application.RemoveAsyncCalls(Self);
  inherited Destroy;
end;

function TMQueryQueryBook.NewButton(const ACaption, AHint: string;
  AWidth: Integer; AHandler: TNotifyEvent): TButton;
begin
  Result := TButton.Create(Self);
  Result.Parent := FBar;
  Result.Caption := ACaption;
  Result.Hint := AHint;
  Result.ShowHint := True;
  Result.Width := AWidth;
  Result.Align := alLeft;
  Result.BorderSpacing.Around := 3;
  Result.Left := FBar.ControlCount * 200;  // mantem a ordem de criacao
  Result.OnClick := AHandler;
end;

function TMQueryQueryBook.NewQuery(const AText: string): TMQueryQueryTab;
begin
  Inc(FCounter);
  Result := TMQueryQueryTab.CreateQuery(Self, 'SQL' + IntToStr(FCounter));
  if AText <> '' then
  begin
    Result.Editor.Lines.Text := AText;
    Result.Editor.Modified := False;
  end;
  FTabs.ActivePage := Result;
  if Result.Editor.CanFocus then
    Result.Editor.SetFocus;
end;

function TMQueryQueryBook.ActiveQuery: TMQueryQueryTab;
begin
  Result := nil;
  if (FTabs.ActivePage <> nil) and (FTabs.ActivePage is TMQueryQueryTab) then
    Result := TMQueryQueryTab(FTabs.ActivePage);
end;

function TMQueryQueryBook.HasTab(ATab: TMQueryQueryTab): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FTabs.PageCount - 1 do
    if FTabs.Pages[I] = ATab then
      Exit(True);
end;

function TMQueryQueryBook.CloseQuery(ATab: TMQueryQueryTab): Boolean;
begin
  Result := False;
  if (ATab = nil) or not HasTab(ATab) then Exit;
  if not ATab.CanClose then Exit;
  ATab.Free;
  Result := True;
  if FTabs.PageCount = 0 then
    NewQuery;
end;

procedure TMQueryQueryBook.CloseQueryLater(ATab: TMQueryQueryTab);
begin
  Application.QueueAsyncCall(@CloseAsync, PtrInt(ATab));
end;

procedure TMQueryQueryBook.CloseAsync(Data: PtrInt);
begin
  CloseQuery(TMQueryQueryTab(Data));
end;

procedure TMQueryQueryBook.OpenFile;
var
  I: Integer;
  Tab: TMQueryQueryTab;
begin
  if not FOpenDialog.Execute then Exit;
  for I := 0 to FOpenDialog.Files.Count - 1 do
  begin
    Tab := ActiveQuery;
    // reaproveita a aba atual se ela estiver vazia e sem arquivo
    if (Tab = nil) or (Tab.FileName <> '') or (Trim(Tab.Editor.Lines.Text) <> '') then
      Tab := NewQuery;
    try
      Tab.LoadFromFile(FOpenDialog.Files[I]);
    except
      on E: Exception do
        MessageDlg('MQuery', 'Não foi possível abrir ' + FOpenDialog.Files[I] +
          LineEnding + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TMQueryQueryBook.Show;
begin
  FHost.ActivePage := FPage;
  if (ActiveQuery <> nil) and ActiveQuery.Editor.CanFocus then
    ActiveQuery.Editor.SetFocus;
end;

procedure TMQueryQueryBook.BtnNewClick(Sender: TObject);
begin
  NewQuery;
end;

procedure TMQueryQueryBook.BtnOpenClick(Sender: TObject);
begin
  OpenFile;
end;

procedure TMQueryQueryBook.BtnSaveClick(Sender: TObject);
begin
  if ActiveQuery <> nil then ActiveQuery.Save(False);
end;

procedure TMQueryQueryBook.BtnSaveAsClick(Sender: TObject);
begin
  if ActiveQuery <> nil then ActiveQuery.Save(True);
end;

procedure TMQueryQueryBook.BtnCloseClick(Sender: TObject);
begin
  CloseQueryLater(ActiveQuery);
end;

procedure TMQueryQueryBook.BtnRunClick(Sender: TObject);
begin
  if ActiveQuery <> nil then ActiveQuery.Execute;
end;

procedure TMQueryQueryBook.MenuCloseOthersClick(Sender: TObject);
var
  I: Integer;
  Atual: TTabSheet;
begin
  Atual := FTabs.ActivePage;
  for I := FTabs.PageCount - 1 downto 0 do
    if (FTabs.Pages[I] <> Atual) and (FTabs.Pages[I] is TMQueryQueryTab) then
      if not CloseQuery(TMQueryQueryTab(FTabs.Pages[I])) then
        Exit;
end;

procedure TMQueryQueryBook.TabsMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
begin
  // clique do meio fecha a aba, como nos navegadores
  if Button <> mbMiddle then Exit;
  Idx := FTabs.IndexOfTabAt(X, Y);
  if (Idx >= 0) and (FTabs.Pages[Idx] is TMQueryQueryTab) then
    CloseQueryLater(TMQueryQueryTab(FTabs.Pages[Idx]));
end;

end.
