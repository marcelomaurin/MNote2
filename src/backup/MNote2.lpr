program MNote2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lnetvisual, main,
  {$ifndef Darwin}
  folders
  {$ENDIF}
  ;


{$R *.res}

begin
  //RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmMNote, frmMNote);
  //Application.CreateForm(TfrmMQuery, frmMQuery);
  {$ifndef Darwin}
  {$ENDIF}
  Application.Run;
end.

