unit newproject;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  EditBtn, ComCtrls, base, funcoes, hint;

type

  { TfrmNewProject }

  TfrmNewProject = class(TForm)
    Button1: TButton;
    Button2: TButton;
    btProcess: TButton;
    cbDataBase: TComboBox;
    deTarget: TDirectoryEdit;
    edBancoPost: TEdit;
    edHostNamePost: TEdit;
    edPasswrdPost: TEdit;
    edproject: TEdit;
    edSchemaPost: TEdit;
    edusuarioPost: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    edPropose: TMemo;
    mespec: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  frmNewProject: TfrmNewProject;

implementation

{$R *.lfm}

{ TfrmNewProject }

procedure TfrmNewProject.Button1Click(Sender: TObject);
var
  original : string;
  destino : string;
  biblioteca : string;
begin
  {$IFDEF WINDOWS}
  original := ExtractFilePath(Application.ExeName)+'db\projeto_padrao.db';
  destino := deTarget.Text+'\'+edproject.Text+'.db';
  if(pos('\src',ExtractFilePath(Application.ExeName))>0) then
  begin
    biblioteca := ExtractFilePath(Application.ExeName)+'..\libs\sqlite\win32\sqlite3.dll'
  end
  else
  begin
    biblioteca := ExtractFilePath(Application.ExeName)+'libs\sqlite\win32\sqlite3.dll'
  end;
  {$ENDIF}
  {$IFDEF LINUX}
  original := ExtractFilePath(Application.ExeName)+'db/projeto_padrao.db';
  destino := deTarget.Text+'/'+edproject.Text+'.db';
  {$ENDIF}
  end;
  if(FileExists(original)) then
  begin
    CopiarArquivo(original, destino);
    if (dmbase=nil) then
    begin
      dmbase := TdmBase.create(self);
    end;
    if dmbase.ConectaSQLite(destino, biblioteca) then
    begin
      // Conectou com sucesso
      dmbase.SalvarDadosMaster(edproject.text, edPropose.text, destino, cbDataBase.ItemIndex );
    end;
  end
  else
  begin
    frmHint.MessageHint('Arquivo não encontrado');
  end;
end;

end.

