param(
  [string]$FpcPath = '',
  [string[]]$ExtraUnitPaths = @(),
  [string]$ChatGPTRoot = $env:MNOTE_CHATGPT_ROOT,
  [string]$ZeosRoot = $env:MNOTE_ZEOS_ROOT
)

$ErrorActionPreference = 'Stop'
$TestRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $TestRoot
$OutputPath = Join-Path $TestRoot 'bin'

function Resolve-Compiler {
  param([string]$Requested)
  if ($Requested -and (Test-Path -LiteralPath $Requested)) {
    return (Resolve-Path -LiteralPath $Requested).Path
  }
  $Compiler = Get-Command fpc -ErrorAction SilentlyContinue
  if ($null -eq $Compiler) {
    throw 'Free Pascal não foi encontrado. Informe -FpcPath ou adicione fpc ao PATH.'
  }
  return $Compiler.Source
}

function Get-FpcInfo {
  param([string]$Compiler, [string]$Switch)
  $Value = (& $Compiler $Switch 2>$null | Select-Object -First 1)
  if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($Value)) {
    throw "Não foi possível consultar $Switch em $Compiler."
  }
  return $Value.Trim()
}

function Add-ExistingUnitPath {
  param(
    [System.Collections.Generic.List[string]]$List,
    [string]$Path
  )
  if ([string]::IsNullOrWhiteSpace($Path)) { return }
  if (Test-Path -LiteralPath $Path) {
    $Resolved = (Resolve-Path -LiteralPath $Path).Path
    if (-not $List.Contains($Resolved)) {
      $List.Add($Resolved)
    }
  }
}

function Invoke-FpcProgram {
  param(
    [string]$SourceFile,
    [string]$ExecutableName,
    [System.Collections.Generic.List[string]]$UnitPaths,
    [string]$Compiler
  )

  $Args = [System.Collections.Generic.List[string]]::new()
  $Args.Add('-MObjFPC')
  $Args.Add('-Sh')
  foreach ($Path in $UnitPaths) {
    $Args.Add("-Fu$Path")
  }
  $Args.Add("-FU$OutputPath")
  $Args.Add("-FE$OutputPath")
  $Args.Add($SourceFile)

  & $Compiler @Args
  if ($LASTEXITCODE -ne 0) {
    throw "Falha ao compilar $SourceFile."
  }

  $Exe = Join-Path $OutputPath $ExecutableName
  if (-not (Test-Path -LiteralPath $Exe)) {
    throw "Executável não foi gerado: $Exe"
  }

  & $Exe
  if ($LASTEXITCODE -ne 0) {
    throw "Teste falhou: $ExecutableName"
  }
}

$FpcPath = Resolve-Compiler $FpcPath
$TargetCPU = Get-FpcInfo $FpcPath '-iTP'
$TargetOS = Get-FpcInfo $FpcPath '-iTO'
$Target = "$TargetCPU-$TargetOS"

$UnitPaths = [System.Collections.Generic.List[string]]::new()

# Fontes do próprio MNote2.
@(
  'src',
  'src/services',
  'src/ui',
  'src/commands',
  'src/completion',
  'src/search',
  'src/languages',
  'src/project',
  'src/sourcechange',
  'src/ai',
  'src/classes',
  'src/imgjson',
  'src/mquery2',
  'src/toolsfalar',
  'src/toolsouvir'
) | ForEach-Object {
  Add-ExistingUnitPath $UnitPaths (Join-Path $ProjectRoot $_)
}

# CHATGPT é uma dependência externa do runner estendido. O local é configurável,
# nunca codificado no repositório.
if ($ChatGPTRoot) {
  @(
    'pacote/AI Project Core',
    "pacote/packages/lib/openai_agentcore/$Target",
    "pacote/packages/lib/openai_graphcore/$Target",
    "pacote/packages/lib/$Target"
  ) | ForEach-Object {
    Add-ExistingUnitPath $UnitPaths (Join-Path $ChatGPTRoot $_)
  }
}

# Zeos também é opcional e configurável.
if ($ZeosRoot) {
  @(
    "packages/lazarus/lib/zcore/$Target",
    "packages/lazarus/lib/zplain/$Target",
    "packages/lazarus/lib/zdbc/$Target",
    "packages/lazarus/lib/zparsesql/$Target",
    "packages/lazarus/lib/zcomponent/$Target"
  ) | ForEach-Object {
    Add-ExistingUnitPath $UnitPaths (Join-Path $ZeosRoot $_)
  }
}

# Caminhos extras podem ser passados por parâmetro ou por variável de ambiente.
if ($env:MNOTE_EXTRA_UNIT_PATHS) {
  $ExtraUnitPaths += ($env:MNOTE_EXTRA_UNIT_PATHS -split [IO.Path]::PathSeparator)
}
foreach ($Path in $ExtraUnitPaths) {
  Add-ExistingUnitPath $UnitPaths $Path
}

New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

Write-Host "FPC: $FpcPath"
Write-Host "Target: $Target"
Write-Host "Unit paths externos configurados: $($UnitPaths.Count)"

try {
  Invoke-FpcProgram (Join-Path $TestRoot 'test_runner.lpr') 'test_runner.exe' $UnitPaths $FpcPath
}
catch {
  Write-Error @"
$($_.Exception.Message)

O runner estendido depende de pacotes Lazarus/CHATGPT que não fazem parte do
núcleo portátil. Configure MNOTE_CHATGPT_ROOT, MNOTE_ZEOS_ROOT e, quando
necessário, MNOTE_EXTRA_UNIT_PATHS (separados por '$([IO.Path]::PathSeparator)').
"@
  exit 1
}

# SSL loader é validado separadamente. Copia DLLs apenas quando estiverem
# disponíveis no checkout para a arquitetura Windows correspondente.
if ($TargetOS -eq 'win32' -or $TargetOS -eq 'win64') {
  $SslDir = if ($TargetCPU -eq 'i386') {
    Join-Path $ProjectRoot 'libs/mysql/win32/lib'
  } else {
    Join-Path $ProjectRoot 'libs/mysql/win64/lib'
  }

  if (Test-Path -LiteralPath $SslDir) {
    Get-ChildItem -LiteralPath $SslDir -Filter 'libssl*.dll' -ErrorAction SilentlyContinue |
      Copy-Item -Destination $OutputPath -Force
    Get-ChildItem -LiteralPath $SslDir -Filter 'libcrypto*.dll' -ErrorAction SilentlyContinue |
      Copy-Item -Destination $OutputPath -Force
  }
}

try {
  Invoke-FpcProgram (Join-Path $TestRoot 'ssl_loader_test.lpr') 'ssl_loader_test.exe' $UnitPaths $FpcPath
}
catch {
  Write-Error $_.Exception.Message
  exit 1
}

exit 0
