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

$Fixture = Join-Path $env:TEMP ('mnote2-solution-tree-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $Fixture 'src') -Force | Out-Null
Set-Content -LiteralPath (Join-Path $Fixture 'projeto.lpi') -Value '<CONFIG />' -Encoding UTF8
Set-Content -LiteralPath (Join-Path $Fixture 'src\principal.pas') -Value 'unit principal;' -Encoding UTF8
try {
  $Process = Start-Process -FilePath $Executable `
    -ArgumentList @('--solution-tree-test', $Fixture) `
    -WorkingDirectory (Split-Path -Parent $Executable) -WindowStyle Hidden `
    -Wait -PassThru
  Write-Output "MNote2 Solution Explorer exit code: $($Process.ExitCode)"
  exit $Process.ExitCode
}
finally {
  Remove-Item -LiteralPath $Fixture -Recurse -Force -ErrorAction SilentlyContinue
}
