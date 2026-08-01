param(
  [string]$Executable = ''
)

$ErrorActionPreference = 'Stop'
$TestRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $TestRoot
if ($Executable -eq '') {
  $Executable = Join-Path $ProjectRoot 'src\MNote2.exe'
}
if (-not (Test-Path -LiteralPath $Executable)) {
  throw "MNote2 não encontrado: $Executable"
}

$process = Start-Process -FilePath $Executable -ArgumentList '--smoke-test' `
  -WorkingDirectory (Split-Path -Parent $Executable) -WindowStyle Hidden `
  -Wait -PassThru
Write-Output "MNote2 smoke exit code: $($process.ExitCode)"
exit $process.ExitCode
