#!/bin/sh
# Runner de testes portatil para Linux e macOS.
# Compila e executa o nucleo portatil, o mesmo alvo usado pelo job portable-core do CI.
set -e

TEST_ROOT=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(dirname "$TEST_ROOT")
cd "$PROJECT_ROOT"

lazbuild -B tests/ci_core_runner.lpi

BIN=$(find tests/ci-bin -type f -name ci_core_runner 2>/dev/null | head -n 1)
if [ -z "$BIN" ]; then
  echo 'ci_core_runner nao foi gerado.' >&2
  exit 1
fi

"$BIN"
