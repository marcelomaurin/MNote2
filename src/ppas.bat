@echo off
SET THEFILE=D:\projetos\maurinsoft\MNote2\src\MNote2.exe
echo Linking %THEFILE%
C:\fpcupdeluxe\fpc\bin\x86_64-win64\ld.exe -b pei-x86-64  --gc-sections  -s --subsystem windows --entry=_WinMainCRTStartup    -o D:\projetos\maurinsoft\MNote2\src\MNote2.exe D:\projetos\maurinsoft\MNote2\src\link12244.res
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occurred while assembling %THEFILE%
goto end
:linkend
echo An error occurred while linking %THEFILE%
:end
