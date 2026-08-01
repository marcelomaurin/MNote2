param(
  [string]$FpcPath = 'C:\lazarus\fpc\3.2.2\bin\i386-win32\fpc.exe'
)

$ErrorActionPreference = 'Stop'
$TestRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $TestRoot
$OutputPath = Join-Path $TestRoot 'bin'

if (-not (Test-Path -LiteralPath $FpcPath)) {
  $Compiler = Get-Command fpc -ErrorAction SilentlyContinue
  if ($null -eq $Compiler) {
    throw 'Free Pascal não foi encontrado.'
  }
  $FpcPath = $Compiler.Source
}

New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null
& $FpcPath '-MObjFPC' '-Sh' "-Fu$ProjectRoot\src" "-Fu$ProjectRoot\src\services" "-Fu$ProjectRoot\src\ui" "-Fu$ProjectRoot\src\commands" "-Fu$ProjectRoot\src\completion" "-Fu$ProjectRoot\src\search" "-Fu$ProjectRoot\src\languages" "-Fu$ProjectRoot\src\project" "-Fu$ProjectRoot\src\sourcechange" "-Fu$ProjectRoot\src\ai" '-FuD:\projetos\maurinsoft\CHATGPT\pacote\AI Project Core' '-FuD:\projetos\maurinsoft\CHATGPT\pacote\packages\lib\openai_agentcore\i386-win32' '-FuD:\projetos\maurinsoft\CHATGPT\pacote\packages\lib\openai_graphcore\i386-win32' '-FuD:\projetos\maurinsoft\CHATGPT\pacote\packages\lib\i386-win32' '-FuC:\Users\mmaurin\AppData\Local\lazarus\onlinepackagemanager\packages\zeosdbo\packages\lazarus\lib\zcore\i386-win32' '-FuC:\Users\mmaurin\AppData\Local\lazarus\onlinepackagemanager\packages\zeosdbo\packages\lazarus\lib\zplain\i386-win32' '-FuC:\Users\mmaurin\AppData\Local\lazarus\onlinepackagemanager\packages\zeosdbo\packages\lazarus\lib\zdbc\i386-win32' '-FuC:\Users\mmaurin\AppData\Local\lazarus\onlinepackagemanager\packages\zeosdbo\packages\lazarus\lib\zparsesql\i386-win32' '-FuC:\Users\mmaurin\AppData\Local\lazarus\onlinepackagemanager\packages\zeosdbo\packages\lazarus\lib\zcomponent\i386-win32' '-FuC:\lazarus\components\lazutils\lib\i386-win32' '-FuC:\lazarus\lcl\units\i386-win32' '-FuC:\lazarus\lcl\units\i386-win32\win32' "-FU$OutputPath" "-FE$OutputPath" (Join-Path $TestRoot 'test_runner.lpr')
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& (Join-Path $OutputPath 'test_runner.exe')
exit $LASTEXITCODE
