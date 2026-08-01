unit mnote_task_list_panel;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, ComCtrls, Menus, Dialogs, fpjson,
  mnote_task_comment_index, mnote_project_service, aiproject_core;

type
  TMNoteTaskListNavigateEvent = procedure(const AFileName: string;
    ALine, AColumn, ALength: Integer) of object;

  TMNoteTaskListPanel = class(TComponent)
  private
    FList: TListView;
    FIndex: TMNoteTaskCommentIndex;
    FProjectService: TMNoteProjectService;
    FOnNavigate: TMNoteTaskListNavigateEvent;
    FOnTaskCreated: TNotifyEvent;
    procedure DoubleClick(Sender: TObject);
    procedure ConvertToTask(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AList: TListView;
      AProjectService: TMNoteProjectService);
    procedure Scan(const ARoot: string);
    property OnNavigate: TMNoteTaskListNavigateEvent read FOnNavigate
      write FOnNavigate;
    property OnTaskCreated: TNotifyEvent read FOnTaskCreated write FOnTaskCreated;
  end;

implementation

constructor TMNoteTaskListPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIndex := TMNoteTaskCommentIndex.Create;
end;

destructor TMNoteTaskListPanel.Destroy;
begin
  FIndex.Free;
  inherited Destroy;
end;

procedure TMNoteTaskListPanel.Initialize(AList: TListView;
  AProjectService: TMNoteProjectService);
var
  Menu: TPopupMenu;
  Item: TMenuItem;
begin
  FList := AList;
  FProjectService := AProjectService;
  if FList.Columns.Count < 4 then
    with FList.Columns.Add do begin Caption := 'Line'; Width := 55; end;
  FList.OnDblClick := @DoubleClick;
  Menu := TPopupMenu.Create(Self);
  Item := TMenuItem.Create(Self);
  Item.Caption := 'Converter em tarefa de projeto';
  Item.OnClick := @ConvertToTask;
  Menu.Items.Add(Item);
  FList.PopupMenu := Menu;
end;

procedure TMNoteTaskListPanel.Scan(const ARoot: string);
var
  I: Integer;
  ListItem: TListItem;
begin
  if (FList = nil) then Exit;
  if not DirectoryExists(ARoot) then
  begin
    FList.Items.Clear;
    Exit;
  end;
  FIndex.Scan(ARoot);
  FList.Items.BeginUpdate;
  try
    FList.Items.Clear;
    for I := 0 to FIndex.Count - 1 do
    begin
      ListItem := FList.Items.Add;
      ListItem.Caption := FIndex[I].Token;
      ListItem.SubItems.Add(FIndex[I].Description);
      ListItem.SubItems.Add(FIndex[I].FileName);
      ListItem.SubItems.Add(IntToStr(FIndex[I].Line));
      ListItem.Data := FIndex[I];
    end;
  finally
    FList.Items.EndUpdate;
  end;
end;

procedure TMNoteTaskListPanel.DoubleClick(Sender: TObject);
var Entry: TMNoteTaskComment;
begin
  if (FList.Selected = nil) or (FList.Selected.Data = nil) then Exit;
  Entry := TMNoteTaskComment(FList.Selected.Data);
  if Assigned(FOnNavigate) then FOnNavigate(Entry.FileName, Entry.Line, 1, 0);
end;

procedure TMNoteTaskListPanel.ConvertToTask(Sender: TObject);
var
  Entry: TMNoteTaskComment;
  ID: string;
  Task, Origin: TJSONObject;
begin
  if (FProjectService = nil) or (FList.Selected = nil) or
    (FList.Selected.Data = nil) then Exit;
  Entry := TMNoteTaskComment(FList.Selected.Data);
  ID := FProjectService.Tasks.AddTask(Entry.Token + ': ' + Entry.Description,
    'Criada a partir de comentário no código.', 'normal', 'DEV', '', 1);
  Task := FProjectService.Tasks.GetTaskByID(ID);
  if Task.Find('origin') is TJSONObject then Origin := Task.Objects['origin']
  else begin Origin := TJSONObject.Create; Task.Add('origin', Origin); end;
  JSONSetString(Origin, 'file', Entry.FileName);
  JSONSetInteger(Origin, 'line', Entry.Line);
  Task.Arrays['files_affected'].Add(Entry.FileName);
  if not FProjectService.Save then
    MessageDlg('Task List', FProjectService.LastError, mtError, [mbOK], 0)
  else MessageDlg('Task List', 'Tarefa ' + ID + ' criada e vinculada.',
    mtInformation, [mbOK], 0);
  if Assigned(FOnTaskCreated) then FOnTaskCreated(Self);
end;

end.
