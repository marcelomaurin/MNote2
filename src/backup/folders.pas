unit folders;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ShellCtrls,
  ExtCtrls, Menus, setfolders;

type

  { TfrmFolders }

  TfrmFolders = class(TForm)
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;

    ShellListView1: TShellListView;
    ShellTreeView1: TShellTreeView;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure CarregaContexto();
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
  Left:= FsetFolders.posx;
  top:= FSetFolders.posy;
  if FSetFolders.stay then
  begin
    FormStyle:= fsStayOnTop;
    //mnStay.Caption:='Normal';
    //mnOnTopW.Caption:='Normal';
  end
  else
  begin
    FormStyle:= fsNormal;
    //mnStay.Caption:='On Top';
    //mnOnTopW.Caption:='On Top';
  end;
  if FSetFolders.fixar then
  begin
    BorderStyle:=bsSingle;
    //mnFixar.Caption:='Fix';
    //mnFixW.Caption:='Fix';
  end
  else
  begin
    BorderStyle:=bsNone;
    //mnFixar.Caption:= 'Move';
    //mnFixW.caption := 'Move' ;
  end;
end;


procedure TfrmFolders.FormCreate(Sender: TObject);
begin
  if (FSetFolders = nil) then
  begin
        FsetFolders := TsetFolders.create();
  end;
  CarregaContexto();

end;

procedure TfrmFolders.FormDestroy(Sender: TObject);
var
   info : string;
begin
  Fsetfolders.posx := Left;
  Fsetfolders.posy := top;

  FsetFolders.SalvaContexto(false);
  if FsetFolders <> nil then
  begin
    FsetFolders.Free();
    FsetFolders := nil;
  end;
end;

end.

