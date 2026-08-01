param(
  [string]$FpcPath = 'C:\lazarus\fpc\3.2.2\bin\i386-win32\fpc.exe'
)

$ErrorActionPreference = 'Stop'
$TestRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $TestRoot
$OutputPath = Join-Path $TestRoot 'bin\performance'
$ProgramPath = Join-Path $OutputPath 'search_performance.exe'
$OutputFile = Join-Path $OutputPath 'search_performance.out'
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

& $FpcPath '-MObjFPC' '-Sh' "-Fu$ProjectRoot\src" `
  "-Fu$ProjectRoot\src\services" "-Fu$ProjectRoot\src\search" `
  '-FuC:\lazarus\components\lazutils\lib\i386-win32' `
  "-FU$OutputPath" "-FE$OutputPath" `
  (Join-Path $TestRoot 'search_performance.lpr')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$Process = Start-Process -FilePath $ProgramPath -NoNewWindow `
  -RedirectStandardOutput $OutputFile -PassThru
$PeakWorkingSet = 0L
while (-not $Process.HasExited) {
  $Process.Refresh()
  if ($Process.WorkingSet64 -gt $PeakWorkingSet) {
    $PeakWorkingSet = $Process.WorkingSet64
  }
  Start-Sleep -Milliseconds 10
}
Get-Content -LiteralPath $OutputFile
Write-Output ('peak_working_set_bytes=' + $PeakWorkingSet)
Write-Output ('compiler_version=' + (& $FpcPath -iV))
Remove-Item -LiteralPath $OutputFile -Force
exit $Process.ExitCode
