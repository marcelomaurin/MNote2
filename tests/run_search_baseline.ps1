param(
  [string]$FpcPath = 'C:\lazarus\fpc\3.2.2\bin\i386-win32\fpc.exe'
)

$ErrorActionPreference = 'Stop'
$TestRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutputPath = Join-Path $TestRoot 'bin'
$ProgramPath = Join-Path $OutputPath 'legacy_search_baseline.exe'
$FixturePath = Join-Path $TestRoot 'fixtures\search\baseline_utf8.txt'
$OutputFile = Join-Path $OutputPath 'legacy_search_baseline.out'

New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null
& $FpcPath '-MObjFPC' '-Sh' "-FU$OutputPath" "-FE$OutputPath" `
  (Join-Path $TestRoot 'legacy_search_baseline.lpr')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$Process = Start-Process -FilePath $ProgramPath -ArgumentList $FixturePath `
  -NoNewWindow -RedirectStandardOutput $OutputFile -PassThru
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
Remove-Item -LiteralPath $OutputFile -Force
exit $Process.ExitCode
