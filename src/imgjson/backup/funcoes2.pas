unit funcoes2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, TypInfo, Grids , Process,  FileUtil , Controls , Graphics,  ExtCtrls
{$IFDEF MSWINDOWS}
,windows, jwaWinBase, shellAPI , Registry , JwaTlHelp32
{$ENDIF}
{$IFDEF LINUX}
//LCLType,
//LCLIntf
,BaseUnix
,UnixType
,Unix
{$ENDIF}
{$IFDEF DARWIN}

{$ENDIF}       ;



implementation

uses setproject;


var LastTickCount     : cardinal = 0;
    LastProcessorTime : int64    = 0;
    FLastIdleTime: Int64;
    FLastKernelTime: Int64;
    FLastUserTime: Int64;











function GetGPUName(device : integer): string;
var
   cmd : TProcess;
   AStringList: TStringList;
begin
   cmd := TProcess.Create(nil);
   // Cria o objeto TStringList.
   AStringList := TStringList.Create;
   cmd.CommandLine := 'nvidia-smi -i '+inttostr(device)+' --format=csv,noheader --query-gpu=gpu_name';

   cmd.Options := cmd.Options + [poWaitOnExit,poUsePipes,poNoConsole];

   cmd.Execute;
   AStringList.LoadFromStream(cmd.Output);

   //AStringList.SaveToFile('output.txt');
   result := trim(AStringList.Text);

   // Agora que o arquivo foi salvo nós podemos liberar a
   // TStringList e o TProcess.
   AStringList.Free;
   cmd.Free;
end;



{$IFDEF MSWINDOWS}
function Callprg(filename: string; source: String; var Output: string): boolean;
var
  resultado: boolean;
  commandLine: string;
  processInfo: TProcessInformation;
  startInfo: TStartupInfo;
  securityAttr: TSecurityAttributes;
  readPipe, writePipe: THandle;
  buffer : string;
  pbuffer: array[0..4095] of Char;
  bytesRead: DWORD;

begin
  resultado := false;
  Output := '';

  FillChar(securityAttr, SizeOf(securityAttr), 0);
  securityAttr.nLength := SizeOf(securityAttr);
  securityAttr.bInheritHandle := TRUE;

  if not CreatePipe(readPipe, writePipe, @securityAttr, 0) then
    Exit(False);

  try
    FillChar(startInfo, SizeOf(startInfo), 0);
    startInfo.cb := SizeOf(startInfo);
    startInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    startInfo.wShowWindow := SW_HIDE; // Oculta a janela do console
    startInfo.hStdOutput := writePipe;
    startInfo.hStdError := writePipe;

    {$IFDEF WINDOWS}
    commandLine := 'cmd.exe /C "' + filename + '" ' + source;
    {$ENDIF}
    //... Ajuste para Linux e macOS como no seu exemplo

    if CreateProcess(nil, PChar(commandLine), nil, nil, TRUE, 0, nil, nil, startInfo, processInfo) then
    begin
      CloseHandle(writePipe); // Não precisa mais do handle de escrita
      WaitForSingleObject(processInfo.hProcess, INFINITE);

      // Lê a saída do processo
      repeat
        bytesRead := 0;
        //function ReadFile(hFile: HANDLE; lpBuffer: LPVOID; nNumberOfBytesToRead: DWORD;  lpNumberOfBytesRead: LPDWORD; lpOverlapped: LPOVERLAPPED): BOOL; stdcall;
        ReadFile(readPipe, @pbuffer[0], 4096, @bytesRead, nil);
        SetString(buffer, pbuffer, bytesRead);
        Output := Output +  buffer;
      until bytesRead < 4096;

      CloseHandle(processInfo.hProcess);
      CloseHandle(processInfo.hThread);
      resultado := True;
    end;
  finally
    CloseHandle(readPipe);
  end;

  Result := resultado;
end;
{$ENDIF}



















end.


