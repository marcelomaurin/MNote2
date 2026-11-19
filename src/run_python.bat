@ECHO OFF
ECHO RUN Python Script
ECHO %1

IF EXIST "%~dp0runtime\python\libs\windows\x86\python.exe" (
  "%~dp0runtime\python\libs\windows\x86\python.exe" %1
) ELSE (
  python %1
)
PAUSE
