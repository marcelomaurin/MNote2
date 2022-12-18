@ECHO ON
ECHO "RUN GCC"
ECHO %1
set PATH=%PATH%;C:\MinGW\lib\;C:\MinGW\bin\

rem Iniciando compilação
gcc.exe %1 -o prog.exe


rem Executando binario
prog.exe
PAUSE
