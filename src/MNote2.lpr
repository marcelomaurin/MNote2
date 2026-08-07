program MNote2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  SysUtils,
  {$IFDEF WINDOWS}Windows,{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  main, ToolsOuvir,
  {$ifndef Darwin}
  folders, mquery2, pesquisar, triggers, view, Views, benchmark, porradawebapi,
  chart,config, config2, funcoes, setmain, sobre, jsonmain, about, base, NNTrainning,
  Novo, PythonRun, setproject, SQLItem, trainning,
  newproject, uProjetoDB, sqlite_db, IA
  {$ENDIF}
  ,uDocText, uPdfText, ChangeSource, mnote_ai_service, mnote_smoke_test,
  mnote_token_calibration, mnote_neural_api_bootstrap, mnote_ssl_loader;


{$R *.res}

var
  SmokeReport: string;
  CalibrationReport: string;
  SSLError, SSLCLIReport: string;
  NeuralApiBootstrap: TMNoteNeuralApiBootstrap;
  NeuralApiStatus: TMNoteNeuralApiStatus;
  NeuralApiInstaller, NeuralApiError: string;
  RunCloseTabTest, RunSolutionTreeTest: Boolean;

function ConsoleAvailable: Boolean;
const
  ATTACH_PARENT_PROCESS = DWORD(-1);
begin
  {$IFDEF WINDOWS}
  if GetConsoleWindow <> 0 then
    Exit(True);
  if AttachConsole(ATTACH_PARENT_PROCESS) then
  begin
    IsConsole := True;
    Exit(True);
  end;
  Result := False;
  {$ELSE}
  Result := True;
  {$ENDIF}
end;

begin
  // Inicialização central do SSL antes de qualquer serviço ou chamada HTTPS
  InitializeMNoteSSL(SSLError);

  if (ParamCount > 0) and SameText(ParamStr(1), '--ssl-check') then
  begin
    if PerformSSLCheckCLI(SSLCLIReport) then
    begin
      if ConsoleAvailable then WriteLn(SSLCLIReport);
      Halt(0);
    end
    else
    begin
      if ConsoleAvailable then WriteLn(StdErr, SSLCLIReport);
      Halt(1);
    end;
  end;

  RunCloseTabTest := (ParamCount > 0) and
    SameText(ParamStr(1), '--close-tab-test');
  RunSolutionTreeTest := (ParamCount > 1) and
    SameText(ParamStr(1), '--solution-tree-test');
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
    if RunSolutionTreeTest then
      Application.QueueAsyncCall(@frmMNote.RunSolutionExplorerTest, 0);
    //Application.CreateForm(TfrmMQuery, frmMQuery);
    {$ifndef Darwin}
    {$ENDIF}
    Application.Run;
  finally
    FinalizeMNoteAIService;
  end;
end.

