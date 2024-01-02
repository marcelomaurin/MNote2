@ECHO OFF
ECHO DEBUG Python Script
ECHO %1

cd C:\Users\marcelo.maurin\.spyder-py3\


python -m pdb  %1
PAUSE
