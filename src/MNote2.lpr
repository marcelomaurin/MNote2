program MNote2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  SysUtils,
  {$IFDEF WINDOWS}Windows,{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, tachartlazaruspkg, synuni, rxnew, pkg_gifanim, indylaz, zcomponent,
  main, ToolsOuvir,
  {$ifndef Darwin}
  folders, mquery2, pesquisar, triggers, view, Views, benchmark, porradawebapi,
  chart,config, config2, funcoes, setmain, sobre, jsonmain, about, base, NNTrainning,
  Novo, PythonRun, setproject, SQLItem, trainning,
newproject, uProjetoDB, sqlite_db, IA
  {$ENDIF}
  ,uDocText, uPdfText, ChangeSource, mnote_ai_service, mnote_smoke_test,
  mnote_token_calibration, mnote_neural_api_bootstrap;


{$R *.res}

var
  SmokeReport: string;
  CalibrationReport: string;
  NeuralApiBootstrap: TMNoteNeuralApiBootstrap;
  NeuralApiStatus: TMNoteNeuralApiStatus;
  NeuralApiInstaller, NeuralApiError: string;
  RunCloseTabTest: Boolean;

function ConsoleAvailable: Boolean;
begin
  {$IFDEF WINDOWS}
  Result := GetConsoleWindow <> 0;
  {$ELSE}
  Result := True;
  {$ENDIF}
end;

begin
  RunCloseTabTest := (ParamCount > 0) and
    SameText(ParamStr(1), '--close-tab-test');
  if (ParamCount > 0) and SameText(ParamStr(1), '--neural-api-check') then
  begin
    NeuralApiBootstrap := TMNoteNeuralApiBootstrap.Create;
    try
      NeuralApiBootstrap.CheckAndDownload(NeuralApiStatus,
        NeuralApiInstaller, NeuralApiError);
      if ConsoleAvailable then
      begin
        if NeuralApiError <> '' then WriteLn(NeuralApiError)
        else if NeuralApiInstaller <> '' then WriteLn(NeuralApiInstaller)
        else WriteLn(NeuralApiBootstrap.InstalledFolder);
      end;
      if NeuralApiStatus = nasError then Halt(1);
      Halt(0);
    finally
      NeuralApiBootstrap.Free;
    end;
  end;
  if (ParamCount > 0) and SameText(ParamStr(1), '--smoke-test') then
  begin
    if RunMNoteSmokeTest(SmokeReport) then
    begin
      if ConsoleAvailable then WriteLn(SmokeReport);
      Halt(0);
    end
    else
    begin
      if ConsoleAvailable then WriteLn(StdErr, SmokeReport);
      Halt(1);
    end;
  end;
  if (ParamCount > 0) and SameText(ParamStr(1), '--calibrate-tokens') then
  begin
    if TMNoteTokenCalibration.Run(
      ExpandFileName(ExtractFilePath(ParamStr(0)) + '..' + PathDelim +
        'docs' + PathDelim + 'tokenest_calibracao.md'), 20,
      CalibrationReport) then
    begin
      if ConsoleAvailable then WriteLn(CalibrationReport);
      Halt(0);
    end
    else
    begin
      if ConsoleAvailable then WriteLn(StdErr, CalibrationReport);
      Halt(1);
    end;
  end;
  InitializeMNoteAIService;
  try
    //RequireDerivedFormResource := True;
    Application.Initialize;
    Application.CreateForm(TfrmMNote, frmMNote);
    if RunCloseTabTest then
      Application.QueueAsyncCall(@frmMNote.RunCloseTabTest, 0);
    //Application.CreateForm(TfrmMQuery, frmMQuery);
    {$ifndef Darwin}
    {$ENDIF}
    Application.Run;
  finally
    FinalizeMNoteAIService;
  end;
end.

