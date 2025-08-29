unit sqleditor;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  DBCtrls, DBGrids, StdCtrls, SynEdit, base, DB, ZDataset;

type

  { TfrmSQLEditor }

  TfrmSQLEditor = class(TForm)
    btSalvar: TButton;
    btCancel: TButton;
    btexecuta: TButton;
    dssql: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    edNome: TEdit;
    Label1: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    pngrid: TPanel;
    Panel4: TPanel;
    SynEdit1: TSynEdit;
    tsEdit: TTabSheet;
    tsGrid: TTabSheet;
    qrysql: TZReadOnlyQuery;
    procedure btCancelClick(Sender: TObject);
    procedure btexecutaClick(Sender: TObject);
    procedure btSalvarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
        flgsalvar : boolean;
  end;

var
  frmSQLEditor: TfrmSQLEditor;

implementation

{$R *.lfm}

{ TfrmSQLEditor }

procedure TfrmSQLEditor.btSalvarClick(Sender: TObject);
begin
   flgsalvar:= true;
   close;
end;

procedure TfrmSQLEditor.FormCreate(Sender: TObject);
begin
  flgsalvar:= false;
  SynEdit1.Lines.clear;
  PageControl1.ActivePageIndex:=0;

end;

procedure TfrmSQLEditor.btCancelClick(Sender: TObject);
begin
  flgsalvar:= false;
  close;
end;

procedure TfrmSQLEditor.btexecutaClick(Sender: TObject);
begin
  if (dmBase.zcon.Connected) then
  begin
      qrysql.close;
      qrysql.sql.Text:= SynEdit1.Lines.Text;
       try
        qrysql.Open;
        pngrid.SetFocus;

      except
        on E: Exception do
          ShowMessage('Erro ao executar SQL: ' + E.Message);
      end;
  end
  else
  begin
    showmessage('Sem conexão com o banco!');
  end;
end;

end.

