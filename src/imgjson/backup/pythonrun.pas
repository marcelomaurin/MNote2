unit PythonRun;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, PythonEngine;

type
  TPythonOutputEvent = procedure(Sender: TObject; const OutputLine: String) of object;

  TPythonRunner = class
  private
    FPythonEngine: TPythonEngine;
    FOnPythonOutput: TPythonOutputEvent;
    procedure PythonOutput(Sender: TObject; const Data: AnsiString);
  public
    constructor Create;
    destructor Destroy; override;
    procedure ExecuteScript(const Script: String; const Params: array of String);
    property OnPythonOutput: TPythonOutputEvent read FOnPythonOutput write FOnPythonOutput;
  end;

implementation

constructor TPythonRunner.Create;
begin
  inherited Create;
  FPythonEngine := TPythonEngine.Create(nil);
  FPythonEngine.IO := TPythonInputOutput.Create(nil);
  TPythonInputOutput(FPythonEngine.IO).OnSendData := @PythonOutput;
  // Configure o PythonEngine conforme necessário
end;

destructor TPythonRunner.Destroy;
begin
  FPythonEngine.Free;
  inherited Destroy;
end;

procedure TPythonRunner.PythonOutput(Sender: TObject; const Data: AnsiString);
begin
  if Assigned(FOnPythonOutput) then
    FOnPythonOutput(Self, Data);
end;

procedure TPythonRunner.ExecuteScript(const Script: String; const Params: array of String);
var
  FullScript, ParamStr: String;
  I: Integer;
begin
  // Construir a string de parâmetros
  ParamStr := '';
  for I := Low(Params) to High(Params) do
    ParamStr := ParamStr + ' ' + Params[I];

  // Construir o script completo para execução
  FullScript := Format('import sys; sys.argv = ["%s"%s]; exec(open("%s").read())',
                      [ExtractFileName(Script), ParamStr, Script]);

  // Executar o script
  FPythonEngine.ExecString(UTF8Encode(FullScript));
end;

end.

