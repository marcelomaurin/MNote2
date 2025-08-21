unit PythonRun;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, PythonEngine;

type
  // Um único evento para saída (stdout + stderr redirecionado)
  TPythonOutputEvent = procedure(Sender: TObject; const Line: UTF8String) of object;

  { TPythonRunner }
  TPythonRunner = class
  private
    FPythonEngine: TPythonEngine;
    FIO: TPythonInputOutput;

    FInitialized: Boolean;
    FOnOutput: TPythonOutputEvent;
    FExtraPaths: TStrings;
    FVirtualEnv: string;
    FDllPath: string;
    FDllName: string;
    FPythonHome: string;

    procedure IO_SendData(Sender: TObject; const Data: AnsiString);
    procedure IO_SendUniData(Sender: TObject; const Data: UnicodeString);

    procedure EnsureEngine;
    procedure ApplyConfigPaths;

    class function PyEscaped(const S: string): string; static;
    class function BuildArgvCode(const ScriptName: string; const Params: array of string): string; static;
  public
    constructor Create;
    destructor Destroy; override;

    // Configuração (defina antes de Initialize)
    property DllPath: string read FDllPath write FDllPath;           // ex.: C:\...\Python311\
    property DllName: string read FDllName write FDllName;           // ex.: python311.dll (opcional)
    property PythonHome: string read FPythonHome write FPythonHome;  // ex.: C:\...\Python311\
    property VirtualEnv: string read FVirtualEnv write FVirtualEnv;  // ex.: C:\venvs\meuenv
    property ExtraPaths: TStrings read FExtraPaths;                   // libs do projeto

    // Evento de saída (stdout + stderr)
    property OnOutput: TPythonOutputEvent read FOnOutput write FOnOutput;

    // Ciclo de vida
    procedure Initialize;
    function  IsInitialized: Boolean;

    // Execução
    procedure ExecuteScriptFile(const ScriptPath: string; const Params: array of string);
    procedure ExecuteCode(const CodeUTF8: UTF8String; const Params: array of string);

    // Utilitário
    class function GuessWindowsDllName: string; static;
  end;

implementation

{ ==== Utils ================================================================ }

class function TPythonRunner.PyEscaped(const S: string): string;
var
  R: string;
begin
  R := StringReplace(S, '\', '\\', [rfReplaceAll]);
  R := StringReplace(R, '"', '\"', [rfReplaceAll]);
  R := StringReplace(R, #13#10, '\n', [rfReplaceAll]);
  R := StringReplace(R, #10,    '\n', [rfReplaceAll]);
  R := StringReplace(R, #13,    '\n', [rfReplaceAll]);
  Result := R;
end;

class function TPythonRunner.BuildArgvCode(const ScriptName: string; const Params: array of string): string;
var
  i: Integer;
  L: string;
begin
  L := 'import sys' + LineEnding;
  L := L + 'sys.argv = ["' + PyEscaped(ExtractFileName(ScriptName)) + '"';
  for i := Low(Params) to High(Params) do
    L := L + ', "' + PyEscaped(Params[i]) + '"';
  L := L + ']' + LineEnding;
  Result := L;
end;

{ ==== TPythonRunner ======================================================== }

constructor TPythonRunner.Create;
begin
  inherited Create;

  FPythonEngine := TPythonEngine.Create(nil);
  FPythonEngine.AutoLoad := False;

  FIO := TPythonInputOutput.Create(nil);
  FIO.UnicodeIO := True;
  FIO.OnSendData := @IO_SendData;
  FIO.OnSendUniData := @IO_SendUniData;
  FPythonEngine.IO := FIO;

  FExtraPaths := TStringList.Create;
  FDllPath := '';
  FDllName := '';
  FPythonHome := '';
  FVirtualEnv := '';
  FInitialized := False;
end;

destructor TPythonRunner.Destroy;
begin
  FExtraPaths.Free;
  FIO.Free;
  FPythonEngine.Free;
  inherited Destroy;
end;

procedure TPythonRunner.IO_SendData(Sender: TObject; const Data: AnsiString);
begin
  if Assigned(FOnOutput) then
    FOnOutput(Self, UTF8String(Data));
end;

procedure TPythonRunner.IO_SendUniData(Sender: TObject; const Data: UnicodeString);
begin
  if Assigned(FOnOutput) then
    FOnOutput(Self, UTF8Encode(Data));
end;

procedure TPythonRunner.EnsureEngine;
begin
  if not FInitialized then
    Initialize;
end;

procedure TPythonRunner.ApplyConfigPaths;
var
  i: Integer;
  Code: UTF8String;
  venvRoot: string;
begin
  // Monta um bootstrap Python:
  // - Redireciona stderr -> stdout (para não depender de OnSendError)
  // - Ativa site-packages do venv (se informado)
  // - Injeta ExtraPaths no sys.path
  Code := 'import sys, os' + LineEnding +
          'sys.stderr = sys.stdout' + LineEnding;

  if Trim(FVirtualEnv) <> '' then
  begin
    venvRoot := IncludeTrailingPathDelimiter(FVirtualEnv);
    venvRoot := StringReplace(venvRoot, '\', '/', [rfReplaceAll]);
    Code := Code +
      'for p in [' + LineEnding +
      '  r"' + UTF8String(PyEscaped(venvRoot + 'Lib/site-packages')) + '",' + LineEnding +
      '  r"' + UTF8String(PyEscaped(venvRoot + 'lib/site-packages')) + '"' + LineEnding +
      ']:' + LineEnding +
      '  if os.path.isdir(p) and p not in sys.path:' + LineEnding +
      '    sys.path.insert(0, p)' + LineEnding;
  end;

  for i := 0 to FExtraPaths.Count - 1 do
  begin
    Code := Code +
      'p = r"' + UTF8String(PyEscaped(FExtraPaths[i])) + '"' + LineEnding +
      'if os.path.isdir(p) and p not in sys.path:' + LineEnding +
      '  sys.path.insert(0, p)' + LineEnding;
  end;

  FPythonEngine.ExecString(Code);
end;

procedure TPythonRunner.Initialize;
begin
  if FInitialized then Exit;

  if Trim(FDllPath) <> '' then
    FPythonEngine.DllPath := IncludeTrailingPathDelimiter(FDllPath);
  if Trim(FDllName) <> '' then
    FPythonEngine.DllName := FDllName;
  if Trim(FPythonHome) <> '' then
    FPythonEngine.PythonHome := FPythonHome;

  FPythonEngine.LoadDll;   // carrega a DLL do Python
  ApplyConfigPaths;        // aplica stderr->stdout, venv e paths

  FInitialized := True;
end;

function TPythonRunner.IsInitialized: Boolean;
return
begin
  Result := FInitialized;
end;

procedure TPythonRunner.ExecuteScriptFile(const ScriptPath: string; const Params: array of string);
var
  Code: UTF8String;
begin
  EnsureEngine;

  if (Trim(ScriptPath) = '') or (not FileExists(ScriptPath)) then
    raise Exception.CreateFmt('Script Python não encontrado: %s', [ScriptPath]);

  Code :=
    UTF8String(BuildArgvCode(ScriptPath, Params)) +
    'with open(r"' + UTF8String(PyEscaped(ScriptPath)) + '", "r", encoding="utf-8") as f:' + LineEnding +
    '    _code = f.read()' + LineEnding +
    'exec(compile(_code, r"' + UTF8String(PyEscaped(ScriptPath)) + '", "exec"))';

  FPythonEngine.ExecString(Code);
end;

procedure TPythonRunner.ExecuteCode(const CodeUTF8: UTF8String; const Params: array of string);
var
  Full: UTF8String;
begin
  EnsureEngine;
  Full := UTF8String(BuildArgvCode('inline.py', Params)) + CodeUTF8;
  FPythonEngine.ExecString(Full);
end;

class function TPythonRunner.GuessWindowsDllName: string;
begin
  Result := 'python311.dll'; // ajuste se estiver em outra versão
end;

end.

