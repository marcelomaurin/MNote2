unit folders;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ShellCtrls,
  ExtCtrls, Menus, StdCtrls, setfolders, funcoes;

type

  { TfrmFolders }

  TfrmFolders = class(TForm)
    edFolder: TEdit;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    miDelete: TMenuItem;
    mirefresh: TMenuItem;
    miCreatedir: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    Separator1: TMenuItem;
    ShellListView1: TShellListView;
    ShellTreeView1: TShellTreeView;
    Splitter1: TSplitter;

    procedure edFolderKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure CarregaContexto();
    procedure MenuItem2Click(Sender: TObject);
    procedure miCreatedirClick(Sender: TObject);
    procedure miDeleteClick(Sender: TObject);
    procedure mirefreshClick(Sender: TObject);
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure ShellTreeView1Changing(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure ShellTreeView1GetSelectedIndex(Sender: TObject; Node: TTreeNode);
  private

  public

  end;

var
  frmFolders: TfrmFolders;

implementation

uses main;
{$R *.lfm}

{ TfrmFolders }

procedure TfrmFolders.MenuItem1Click(Sender: TObject);
var
  diretorio : string;
  arquivo : string;
begin
  diretorio := ShellTreeView1.Path;
  arquivo := ShellListView1.Selected.Caption;
  if (arquivo <> '') then
  begin
       frmMNote.CarregarArquivo(diretorio+arquivo);
  end;
end;

procedure TfrmFolders.CarregaContexto();
begin
  FSetFolders.CarregaContexto();

  if FSetFolders.stay then
  begin
    //FormStyle:= fsStayOnTop;
    //mnStay.Caption:='Normal';
    //mnOnTopW.Caption:='Normal';
  end
  else
  begin
    //FormStyle:= fsNormal;
    //mnStay.Caption:='On Top';
    //mnOnTopW.Caption:='On Top';
  end;
  if not FSetFolders.fixar then
  begin
    //BorderStyle:=bsSingle;
    //mnFixar.Caption:='Fix';
    //mnFixW.Caption:='Fix';
  end
  else
  begin
    //BorderStyle:=bsNone;
    //mnFixar.Caption:= 'Move';
    //mnFixW.caption := 'Move' ;
  end;
end;

procedure TfrmFolders.MenuItem2Click(Sender: TObject);
begin
  FSetFolders.DefaultFolder:= ShellTreeView1.Path;
  FSetFolders.SalvaContexto(false);

end;

procedure TfrmFolders.miCreatedirClick(Sender: TObject);
var
  folder : string;
  pathfolder : string;
begin

   folder := InputBox ('Create dir','FOLDER:','NewFolder');
   if (folder <> '') then
   begin
        pathfolder := edFolder.text+folder;
        if CreateDir(pathfolder) then
        begin
          frmMNote.MessageHint('Folder '+pathfolder+ ' create successful!');
          ShellTreeView1.refresh;
        end
        else
        begin
          frmMNote.MessageHint('Folder '+pathfolder+ ' create fail!');
        end;

   end;
end;

procedure TfrmFolders.miDeleteClick(Sender: TObject);
var

  pathfolder : string;
begin
  pathfolder := edFolder.text;
  //edFolder.text :=  ShellListView1.Selected.GetNamePath;
 // showmessage(ShellListView1.Root);
  ShellTreeView1.Path:=ShellListView1.Root;

  if ShowConfirm('Confirm delete '+pathfolder+'?') then
  begin
        (*
      if RemoveDir( pathfolder) then
      begin
          frmMNote.MessageHint('Folder '+pathfolder+ ' deleted successful!');
      end
      else
      begin
          frmMNote.MessageHint('Folder '+pathfolder+ ' deleted fail!');
      end;
      *)
  end;
end;

procedure TfrmFolders.mirefreshClick(Sender: TObject);
begin
  ShellListView1.Update;
end;

procedure TfrmFolders.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  edFolder.text :=  ShellTreeView1.Path; ;
end;

procedure TfrmFolders.ShellTreeView1Changing(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
     //edFolder.text :=   ShellTreeView1.Path;
end;

procedure TfrmFolders.ShellTreeView1GetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
   //edFolder.text :=   ShellTreeView1.Path;
end;


procedure TfrmFolders.FormCreate(Sender: TObject);
begin
  if (FSetFolders = nil) then
  begin
        FsetFolders := TsetFolders.create();

  end;
  CarregaContexto();
  edFolder.text := FSetFolders.DefaultFolder;
  ShellTreeView1.Path:=edFolder.text;

end;

procedure TfrmFolders.edFolderKeyPress(Sender: TObject; var Key: char);
begin
  if (key=#13) then
  begin
        ShellTreeView1.Path:=edFolder.text;
  end;
end;

procedure TfrmFolders.FormDestroy(Sender: TObject);
var
   info : string;
begin
  Fsetfolders.posx := Left;
  Fsetfolders.posy := top;
  Fsetfolders.width := Width;
  Fsetfolders.Height:= Height;

  FsetFolders.SalvaContexto(false);
  if FsetFolders <> nil then
  begin
    FsetFolders.Free();
    FsetFolders := nil;
  end;
end;

procedure TfrmFolders.FormShow(Sender: TObject);
begin
  frmfolders.Left:= FsetFolders.posx;
  frmfolders.top:= FSetFolders.posy;
  frmfolders.Width:=   Fsetfolders.width;
  frmfolders.Height:= Fsetfolders.Height;

end;

end.

