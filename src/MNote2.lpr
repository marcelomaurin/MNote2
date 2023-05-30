program MNote2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lnetvisual, main, Item, sobre, funcoes, zcomponent, finds,
  {$ifndef Darwin}
  folders,
  {$ENDIF}
  chgtext, setchgtext, hint, registro, splash, config;


{$R *.res}

begin
  //RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmMNote, frmMNote);
  {$ifndef Darwin}
  {$ENDIF}
  Application.Run;
end.

