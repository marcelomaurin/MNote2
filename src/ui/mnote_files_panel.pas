unit mnote_files_panel;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, StdCtrls, ComCtrls, Dialogs,
  aidisktreescanner, aidiskitem, mnote_project_inventory_service;

type
  TMNoteFileOpenEvent = procedure(Sender: TObject;
    const AFileName: string) of object;

  { TMNoteFilesPanel }

  TMNoteFilesPanel = class(TComponent)
  private
    FService: TMNoteProjectInventoryService;
    FRootPath: string;
    FEnabled: Boolean;
    FList: TListView;
    FStatus: TLabel;
    FOnOpenFile: TMNoteFileOpenEvent;
    procedure RefreshClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure DocumentClick(Sender: TObject);
    procedure ListDoubleClick(Sender: TObject);
    procedure ScanStart(Sender: TObject; TaskId: Integer;
      const Description: string);
    procedure ItemFound(Sender: TObject; TaskId: Integer;
      Item: TAIDiskItem);
    procedure ScanProgress(Sender: TObject; TaskId: Integer;
      ProcessedDirs, ProcessedFiles, FoundItems: Int64;
      const CurrentPath: string);
    procedure ScanFinish(Sender: TObject; TaskId: Integer;
      State: TAIDiskTaskState; TotalDirs, TotalFiles,
      TotalFound: Int64; const ErrorMsg: string);
    procedure ScanError(Sender: TObject; TaskId: Integer;
      const Path, ErrorMsg: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AParent: TWinControl; const ARootPath: string;
      AEnabled: Boolean);
    procedure Refresh;
    property Service: TMNoteProjectInventoryService read FService;
    property OnOpenFile: TMNoteFileOpenEvent read FOnOpenFile write FOnOpenFile;
  end;

implementation

procedure AddColumn(AList: TListView; const ACaption: string; AWidth: Integer);
begin
  with AList.Columns.Add do
  begin
    Caption := ACaption;
    Width := AWidth;
  end;
end;

constructor TMNoteFilesPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FService := TMNoteProjectInventoryService.Create;
end;

destructor TMNoteFilesPanel.Destroy;
begin
  FService.Free;
  inherited Destroy;
end;

procedure TMNoteFilesPanel.Initialize(AParent: TWinControl;
  const ARootPath: string; AEnabled: Boolean);
var
  Toolbar: TPanel;
  Button: TButton;
begin
  FRootPath := ARootPath;
  FEnabled := AEnabled;
  while AParent.ControlCount > 0 do AParent.Controls[0].Free;

  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := AParent;
  Toolbar.Align := alTop;
  Toolbar.Height := 34;
  Toolbar.BevelOuter := bvNone;

  Button := TButton.Create(Self);
  Button.Parent := Toolbar;
  Button.SetBounds(4, 4, 64, 25);
  Button.Caption := 'Atualizar';
  Button.OnClick := @RefreshClick;
  Button.Enabled := FEnabled;

  Button := TButton.Create(Self);
  Button.Parent := Toolbar;
  Button.SetBounds(72, 4, 50, 25);
  Button.Caption := 'Parar';
  Button.OnClick := @StopClick;
  Button.Enabled := FEnabled;

  Button := TButton.Create(Self);
  Button.Parent := Toolbar;
  Button.SetBounds(126, 4, 92, 25);
  Button.Caption := 'Documentar';
  Button.OnClick := @DocumentClick;
  Button.Enabled := FEnabled;

  FStatus := TLabel.Create(Self);
  FStatus.Parent := AParent;
  FStatus.Align := alBottom;
  FStatus.BorderSpacing.Around := 5;
  if FEnabled then FStatus.Caption := 'Inventário aguardando atualização.'
  else FStatus.Caption := 'TAIDiskTreeScanner desativado na configuração.';

  FList := TListView.Create(Self);
  FList.Parent := AParent;
  FList.Align := alClient;
  FList.ViewStyle := vsReport;
  FList.ReadOnly := True;
  FList.RowSelect := True;
  FList.OnDblClick := @ListDoubleClick;
  AddColumn(FList, 'Nome', 150);
  AddColumn(FList, 'Tipo', 55);
  AddColumn(FList, 'Caminho', 320);
  AddColumn(FList, 'Bytes', 75);

  FService.Scanner.OnTaskStart := @ScanStart;
  FService.Scanner.OnItemFound := @ItemFound;
  FService.Scanner.OnProgress := @ScanProgress;
  FService.Scanner.OnTaskFinish := @ScanFinish;
  FService.Scanner.OnError := @ScanError;
  if FEnabled then Refresh;
end;

procedure TMNoteFilesPanel.Refresh;
begin
  if not FEnabled then Exit;
  FList.Items.Clear;
  if not FService.StartScan(FRootPath) then
    FStatus.Caption := FService.LastError;
end;

procedure TMNoteFilesPanel.RefreshClick(Sender: TObject);
begin
  Refresh;
end;

procedure TMNoteFilesPanel.StopClick(Sender: TObject);
begin
  FService.Cancel;
  FStatus.Caption := 'Inventário cancelado.';
end;

procedure TMNoteFilesPanel.DocumentClick(Sender: TObject);
var
  FileName: string;
begin
  if MessageDlg('Documentar inventário',
    'Criar uma cópia do inventário em .mnote/documentation?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  if not FService.SaveDocumentationSnapshot(FileName) then
    MessageDlg('Inventário', FService.LastError, mtError, [mbOK], 0)
  else
    MessageDlg('Inventário', 'Documento criado em:' + LineEnding + FileName,
      mtInformation, [mbOK], 0);
end;

procedure TMNoteFilesPanel.ListDoubleClick(Sender: TObject);
var
  FileName: string;
begin
  if (FList.Selected = nil) or (FList.Selected.SubItems.Count < 2) then Exit;
  FileName := FList.Selected.SubItems[1];
  if FileExists(FileName) and Assigned(FOnOpenFile) then
    FOnOpenFile(Self, FileName);
end;

procedure TMNoteFilesPanel.ScanStart(Sender: TObject; TaskId: Integer;
  const Description: string);
begin
  FStatus.Caption := Description;
end;

procedure TMNoteFilesPanel.ItemFound(Sender: TObject; TaskId: Integer;
  Item: TAIDiskItem);
var
  ListItem: TListItem;
begin
  if Item = nil then Exit;
  ListItem := FList.Items.Add;
  ListItem.Caption := Item.Name;
  if Item.ItemType = ditDirectory then ListItem.SubItems.Add('Pasta')
  else ListItem.SubItems.Add('Arquivo');
  ListItem.SubItems.Add(Item.FullPath);
  ListItem.SubItems.Add(IntToStr(Item.Size));
end;

procedure TMNoteFilesPanel.ScanProgress(Sender: TObject; TaskId: Integer;
  ProcessedDirs, ProcessedFiles, FoundItems: Int64;
  const CurrentPath: string);
begin
  FStatus.Caption := Format('%d pastas, %d arquivos, %d itens',
    [ProcessedDirs, ProcessedFiles, FoundItems]);
end;

procedure TMNoteFilesPanel.ScanFinish(Sender: TObject; TaskId: Integer;
  State: TAIDiskTaskState; TotalDirs, TotalFiles, TotalFound: Int64;
  const ErrorMsg: string);
begin
  case State of
    dtsFinished: FStatus.Caption := Format(
      'Concluído: %d pastas, %d arquivos, %d itens.',
      [TotalDirs, TotalFiles, TotalFound]);
    dtsCancelled: FStatus.Caption := 'Inventário cancelado.';
    dtsError: FStatus.Caption := 'Falha no inventário: ' + ErrorMsg;
  else
    FStatus.Caption := 'Inventário finalizado.';
  end;
end;

procedure TMNoteFilesPanel.ScanError(Sender: TObject; TaskId: Integer;
  const Path, ErrorMsg: string);
begin
  FStatus.Caption := 'Falha em ' + Path + ': ' + ErrorMsg;
end;

end.
