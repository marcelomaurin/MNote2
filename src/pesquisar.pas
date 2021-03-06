unit pesquisar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls,SynEdit,item;

type

  { TfrmPesquisar }

  TfrmPesquisar = class(TForm)
    btPesquisar: TButton;
    btSair: TButton;
    edPesquisar: TEdit;
    Label1: TLabel;
    procedure btPesquisarClick(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    tb : TTabSheet;
  end;

var
  frmPesquisar: TfrmPesquisar;

implementation

{$R *.lfm}

{ TfrmPesquisar }

procedure TfrmPesquisar.FormCreate(Sender: TObject);

begin


end;

procedure TfrmPesquisar.btPesquisarClick(Sender: TObject);

var
   syn : TSynEdit;
   item : TItem;
   arquivo : string;
   FindS: String;
   Found : boolean;
   IPos, FLen, SLen: Integer; {Internpos, Lengde søkestreng, lengde memotekst}
   Res : integer;
begin
   syn := TSynEdit(tb.Tag);
   item := TItem(syn.tag);


end;

procedure TfrmPesquisar.btSairClick(Sender: TObject);
begin

end;

end.

