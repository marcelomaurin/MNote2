program MNote2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, tachartlazaruspkg, synuni, rxnew, pkg_gifanim, zcomponent, main, ToolsOuvir
  {$ifndef Darwin}
  folders, mquery2, pesquisar, triggers, view, Views, benchmark, porradawebapi,
  chart,config, config2, funcoes, setmain, sobre, jsonmain, about, base, NNTrainning,
  Novo, PythonRun, setproject, SqlEditItem, sqleditor, SQLItem, trainning
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

