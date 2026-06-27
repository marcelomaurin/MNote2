unit mnote_python_service;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, pythonconnector, aipythonruntime, setmain;

type
  TMNotePythonExecutionMode = (
    mpemDLL,
    mpemProcess
  );

  { TMNotePythonService }

  TMNotePythonService = class(TComponent)
  private
    FPython: TPythonConnector;
    FRuntime: TAIPythonRuntime;
    FLastError: string;
    FLastOutput: string;
    FLastDiagnostic: TStringList;

    procedure ConfigurarConnector;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Start: Boolean;
    procedure Stop;

    function ExecuteCode(const ACode: string): Boolean;
    function ExecuteLines(ALines: TStrings): Boolean;
    function GetVar(const AVarName: string): string;
    function Eval(const AExpression: string): string;

    procedure GetDiagnosticReport(AReport: TStrings);

    property LastError: string read FLastError;
    property LastOutput: string read FLastOutput;
    property Python: TPythonConnector read FPython;
    property Runtime: TAIPythonRuntime read FRuntime;
  end;

implementation

{ TMNotePythonService }

constructor TMNotePythonService.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FLastError := '';
  FLastOutput := '';
  FLastDiagnostic := TStringList.Create;

  FPython := TPythonConnector.Create(Self);
  FRuntime := TAIPythonRuntime.Create(Self);

  ConfigurarConnector;
end;

destructor TMNotePythonService.Destroy;
begin
  Stop;
  FLastDiagnostic.Free;
  inherited Destroy;
end;

procedure TMNotePythonService.ConfigurarConnector;
begin
  if FPython = nil then
    Exit;

  // Primeiro modo recomendado para integração segura:
  // processo separado evita travar o MNote2 caso o Python quebre.
  FPython.ExecutionMode := pemProcess;
  FPython.LoadMode := plmAuto;

  // Se o usuário configurou DLLPath no MNote2, reaproveita.
  // Em modo processo, esse campo pode apontar para python.exe/python3.
  if Trim(FSetMain.DLLPath) <> '' then
    FPython.DLLPath := FSetMain.DLLPath;

  FPython.MinPythonMajor := 3;
  FPython.MinPythonMinor := 8;
  FPython.MaxPythonMajor := 3;
  FPython.MaxPythonMinor := 14;
end;

function TMNotePythonService.Start: Boolean;
begin
  FLastError := '';
  FLastOutput := '';

  ConfigurarConnector;

  if Assigned(FRuntime) then
  begin
    FRuntime.DetectRuntime;
    FRuntime.ConfigureEnvironment;
  end;

  Result := FPython.StartPython;

  if not Result then
  begin
    FLastError := FPython.LastError;
    FPython.GetDiagnosticReport(FLastDiagnostic);
  end;
end;

procedure TMNotePythonService.Stop;
begin
  if Assigned(FPython) then
    FPython.StopExecution;
end;

function TMNotePythonService.ExecuteCode(const ACode: string): Boolean;
begin
  FLastError := '';
  FLastOutput := '';

  if not FPython.IsInitialized then
  begin
    if not Start then
      Exit(False);
  end;

  Result := FPython.ExecString(ACode);

  FLastOutput := FPython.LastOutput;

  if not Result then
    FLastError := FPython.LastError;
end;

function TMNotePythonService.ExecuteLines(ALines: TStrings): Boolean;
begin
  if ALines = nil then
  begin
    FLastError := 'Lista de linhas Python não informada.';
    Exit(False);
  end;

  Result := ExecuteCode(ALines.Text);
end;

// Implementações do GetVar e Eval corrigidas baseadas no que estiver declarado no TPythonConnector do pacote:
// Se o pacote declara GetVar como WideString ou string, vamos nos atentar.
function TMNotePythonService.GetVar(const AVarName: string): string;
begin
  Result := '';

  if not FPython.IsInitialized then
  begin
    if not Start then
      Exit;
  end;

  Result := FPython.GetVar(AVarName);
end;

function TMNotePythonService.Eval(const AExpression: string): string;
begin
  Result := '';

  if not FPython.IsInitialized then
  begin
    if not Start then
      Exit;
  end;

  Result := FPython.Eval(AExpression);
end;

procedure TMNotePythonService.GetDiagnosticReport(AReport: TStrings);
begin
  if AReport = nil then
    Exit;

  AReport.Clear;

  if Assigned(FPython) then
    FPython.GetDiagnosticReport(AReport)
  else
    AReport.Add('TPythonConnector não criado.');
end;

end.
