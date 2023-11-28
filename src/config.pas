unit config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  setmain;

type

  { Tfrmconfig }

  Tfrmconfig = class(TForm)
    btSave: TButton;
    btCancel: TButton;
    edCHATGPT: TFileNameEdit;
    edDebug: TEdit;
    edDLLPATH: TFileNameEdit;
    edInstall: TFileNameEdit;
    edClean: TFileNameEdit;
    edRun: TFileNameEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmconfig: Tfrmconfig;

implementation

{$R *.lfm}

{ Tfrmconfig }

procedure Tfrmconfig.btSaveClick(Sender: TObject);
begin
  FSetMain.Install := edInstall.text;
  FSetMain.CleanScript:= edClean.text;
  FSetMain.RunScript:=edRun.text;
  FSetMain.DebugScript:=edDebug.text;
  FSetMain.DLLPath:= edDLLPATH.text;
  FSetMain.CHATGPT:= edCHATGPT.text;
  FSetMain.SalvaContexto(false);
  close;
end;

procedure Tfrmconfig.FormCreate(Sender: TObject);
begin
  edinstall.text := FSetMain.Install;
  edclean.text := FSetMain.CleanScript;
  edRun.text := FSetMain.RunScript;
  edDebug.text := FSetMain.DebugScript;
  edCHATGPT.Text := FSetMain.CHATGPT;
  edDLLPATH.text := FSetMain.DLLPath;
end;

procedure Tfrmconfig.btCancelClick(Sender: TObject);
begin
  close;
end;

end.

