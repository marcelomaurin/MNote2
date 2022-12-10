program MNote2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lnetvisual, main, Item, sobre, funcoes, zcomponent, finds, folders,
  chgtext, setchgtext, hint, registro, splash, config
  { you can add units after this };


{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmMNote, frmMNote);
  Application.CreateForm(Tfrmchgtext, frmchgtext);
  Application.CreateForm(TfrmFolders, frmFolders);
  Application.Run;
end.

