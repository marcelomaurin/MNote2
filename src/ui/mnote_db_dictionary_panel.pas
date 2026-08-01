unit mnote_db_dictionary_panel;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Controls, ComCtrls, StdCtrls, ExtCtrls, Dialogs,
  ZConnection, aidb_types, mnote_db_dictionary_service;

type
  TMNoteDBDictionaryPanel = class(TComponent)
  private
    FService: TMNoteDBDictionaryService;
    FTree: TTreeView;
    FDetails: TMemo;
    FStatus: TLabel;
    FOnGenerateRequested: TNotifyEvent;
    FOnUseAIRequested: TNotifyEvent;
    FOnGenerateSQLRequested: TNotifyEvent;
    procedure GenerateClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure UseAIClick(Sender: TObject);
    procedure GenerateSQLClick(Sender: TObject);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure Progress(Sender: TObject; const AMessage: string;
      APosition, ATotal: Integer);
    procedure RefreshTree;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AParent: TWinControl);
    function GenerateFor(AConnection: TZConnection): Boolean;
    property Service: TMNoteDBDictionaryService read FService;
    property OnGenerateRequested: TNotifyEvent read FOnGenerateRequested
      write FOnGenerateRequested;
    property OnUseAIRequested: TNotifyEvent read FOnUseAIRequested
      write FOnUseAIRequested;
    property OnGenerateSQLRequested: TNotifyEvent read FOnGenerateSQLRequested
      write FOnGenerateSQLRequested;
  end;

implementation

constructor TMNoteDBDictionaryPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FService := TMNoteDBDictionaryService.Create;
  FService.OnProgress := @Progress;
end;

destructor TMNoteDBDictionaryPanel.Destroy;
begin
  FService.Free;
  inherited Destroy;
end;

procedure TMNoteDBDictionaryPanel.Initialize(AParent: TWinControl);
var
  Toolbar: TPanel;
  Button: TButton;
  Splitter: TSplitter;
begin
  while AParent.ControlCount > 0 do AParent.Controls[0].Free;
  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := AParent; Toolbar.Align := alTop; Toolbar.Height := 58;
  Toolbar.BevelOuter := bvNone;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Gerar da conexão ativa';
  Button.SetBounds(4, 4, 150, 26); Button.OnClick := @GenerateClick;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Exportar cache';
  Button.SetBounds(158, 4, 105, 26); Button.OnClick := @ExportClick;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Perguntar à IA';
  Button.SetBounds(267, 4, 100, 26); Button.OnClick := @UseAIClick;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.Caption := 'Gerar SQL';
  Button.SetBounds(371, 4, 82, 26); Button.OnClick := @GenerateSQLClick;
  FStatus := TLabel.Create(Self);
  FStatus.Parent := Toolbar; FStatus.SetBounds(4, 36, 320, 18);
  FStatus.Caption := 'PostgreSQL/SQLite suportados; demais engines experimentais.';
  FTree := TTreeView.Create(Self);
  FTree.Parent := AParent; FTree.Align := alLeft; FTree.Width := 180;
  FTree.ReadOnly := True; FTree.OnChange := @TreeChange;
  Splitter := TSplitter.Create(Self);
  Splitter.Parent := AParent; Splitter.Align := alLeft;
  FDetails := TMemo.Create(Self);
  FDetails.Parent := AParent; FDetails.Align := alClient;
  FDetails.ReadOnly := True; FDetails.ScrollBars := ssAutoBoth;
end;

procedure TMNoteDBDictionaryPanel.GenerateClick(Sender: TObject);
begin
  if Assigned(FOnGenerateRequested) then FOnGenerateRequested(Self);
end;

procedure TMNoteDBDictionaryPanel.UseAIClick(Sender: TObject);
begin
  if Assigned(FOnUseAIRequested) then FOnUseAIRequested(Self);
end;

procedure TMNoteDBDictionaryPanel.GenerateSQLClick(Sender: TObject);
begin
  if Assigned(FOnGenerateSQLRequested) then FOnGenerateSQLRequested(Self);
end;

function TMNoteDBDictionaryPanel.GenerateFor(
  AConnection: TZConnection): Boolean;
begin
  Result := FService.AttachConnection(AConnection) and
    FService.TestConnection and FService.Generate;
  if Result then
  begin
    RefreshTree;
    FStatus.Caption := 'Dicionário carregado da conexão ' + AConnection.Protocol + '.';
  end
  else
  begin
    FStatus.Caption := FService.LastError;
    MessageDlg('Data Dictionary', FService.LastError, mtError, [mbOK], 0);
  end;
end;

procedure TMNoteDBDictionaryPanel.Progress(Sender: TObject;
  const AMessage: string; APosition, ATotal: Integer);
begin
  FStatus.Caption := Format('%s (%d/%d)', [AMessage, APosition, ATotal]);
  FStatus.Update;
end;

procedure TMNoteDBDictionaryPanel.RefreshTree;
var
  I: Integer;
  Table: TAIDBTableInfo;
  Root, SchemaNode, TableNode: TTreeNode;
  Schema: string;
begin
  FTree.Items.Clear;
  if (FService.Dictionary = nil) or
    (FService.Dictionary.DataDictionary = nil) then Exit;
  Root := FTree.Items.Add(nil, 'Data Dictionary');
  SchemaNode := nil;
  Schema := #0;
  for I := 0 to FService.Dictionary.DataDictionary.Tables.Count - 1 do
  begin
    Table := FService.Dictionary.DataDictionary.Tables[I];
    if Table.SchemaName <> Schema then
    begin
      Schema := Table.SchemaName;
      if Schema = '' then SchemaNode := FTree.Items.AddChild(Root, '(default)')
      else SchemaNode := FTree.Items.AddChild(Root, Schema);
    end;
    TableNode := FTree.Items.AddChild(SchemaNode, Table.TableName);
    TableNode.Data := Table;
  end;
  Root.Expand(True);
end;

procedure TMNoteDBDictionaryPanel.TreeChange(Sender: TObject; Node: TTreeNode);
var
  Table: TAIDBTableInfo;
  I: Integer;
begin
  FDetails.Clear;
  if (Node = nil) or (Node.Data = nil) then Exit;
  Table := TAIDBTableInfo(Node.Data);
  FDetails.Lines.Add(Table.SchemaName + '.' + Table.TableName +
    ' [' + Table.TableType + ']');
  FDetails.Lines.Add('');
  for I := 0 to Table.Columns.Count - 1 do
    FDetails.Lines.Add(Format('%s: %s nullable=%s PK=%s FK=%s',
      [Table.Columns[I].ColumnName, Table.Columns[I].DataType,
       BoolToStr(Table.Columns[I].Nullable, True),
       BoolToStr(Table.Columns[I].IsPrimaryKey, True),
       BoolToStr(Table.Columns[I].IsForeignKey, True)]));
end;

procedure TMNoteDBDictionaryPanel.ExportClick(Sender: TObject);
var
  Dialog: TSaveDialog;
  Text: string;
  Stream: TFileStream;
begin
  if (FService.Dictionary = nil) or
    (FService.Dictionary.DataDictionary.Tables.Count = 0) then
  begin MessageDlg('Data Dictionary', 'Gere o dicionário antes de exportar.',
    mtInformation, [mbOK], 0); Exit; end;
  Dialog := TSaveDialog.Create(nil);
  try
    Dialog.Filter := 'JSON|*.json|Markdown|*.md|Texto|*.txt|AI Prompt|*.prompt.txt';
    Dialog.DefaultExt := 'json';
    if not Dialog.Execute then Exit;
    case Dialog.FilterIndex of
      1: Text := FService.AsJSON;
      2: Text := FService.AsMarkdown;
      3: Text := FService.AsText;
      else Text := FService.AsAIPrompt;
    end;
    Stream := TFileStream.Create(Dialog.FileName, fmCreate);
    try if Text <> '' then Stream.WriteBuffer(Text[1], Length(Text));
    finally Stream.Free; end;
  finally
    Dialog.Free;
  end;
end;

end.
