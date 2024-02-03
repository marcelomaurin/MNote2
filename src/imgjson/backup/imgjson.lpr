program imgjson;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, runtimetypeinfocontrols, jsonmain, about, base, setmain, funcoes, config,
  zcomponent, Novo, SQLItem, sqleditor, SqlEditItem, trainning, frmnntrainning,
  PythonRun, jsonmain;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmmainJSON, frmmainJSON);
  Application.Run;
end.

