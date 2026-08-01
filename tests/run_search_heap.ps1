param(
  [string]$FpcPath = 'C:\lazarus\fpc\3.2.2\bin\i386-win32\fpc.exe'
)

$ErrorActionPreference = 'Stop'
$TestRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $TestRoot
$OutputPath = Join-Path $TestRoot 'bin\heap'
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

& $FpcPath '-MObjFPC' '-Sh' '-gh' '-gl' "-Fu$ProjectRoot\src" `
  "-Fu$ProjectRoot\src\services" "-Fu$ProjectRoot\src\search" `
  '-FuC:\lazarus\components\lazutils\lib\i386-win32' `
  "-FU$OutputPath" "-FE$OutputPath" `
  (Join-Path $TestRoot 'search_heap_test.lpr')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$ErrorActionPreference = 'Continue'
$Output = & (Join-Path $OutputPath 'search_heap_test.exe') 2>&1
$ProcessExitCode = $LASTEXITCODE
$ErrorActionPreference = 'Stop'
$Output | ForEach-Object { Write-Output $_ }
if ($ProcessExitCode -ne 0) {
  throw "O cenário de heap terminou com código $ProcessExitCode."
}
$LeakLine = $Output | Select-String -Pattern '([0-9]+) unfreed memory blocks'
if ($LeakLine -and ([int]$LeakLine.Matches[0].Groups[1].Value -ne 0)) {
  throw 'heaptrc detectou blocos não liberados no fluxo de busca.'
}
Write-Output 'OK: heaptrc sem blocos não liberados atribuíveis à busca'
