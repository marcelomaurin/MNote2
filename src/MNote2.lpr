program MNote2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, tachartlazaruspkg, synuni, rxnew, pkg_gifanim, indylaz, zcomponent,
  main, ToolsOuvir,
  {$ifndef Darwin}
  folders, mquery2, pesquisar, triggers, view, Views, benchmark, porradawebapi,
  chart,config, config2, funcoes, setmain, sobre, jsonmain, about, base, NNTrainning,
  Novo, PythonRun, setproject, SQLItem, trainning,
newproject, uProjetoDB, sqlite_db, IA
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

