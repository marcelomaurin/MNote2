@ECHO ON
ECHO "RUN GCC"
ECHO %1

rem Iniciando compilação
C:\MinGW\bin\gcc.exe -o %1 prog.exe

rem Executando binario
prog.exe
PAUSE
