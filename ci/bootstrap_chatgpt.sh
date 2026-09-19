#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$ROOT/ci/dependencies.json"
DEPS_ROOT="${MNOTE_DEPS_ROOT:-$ROOT/.ci-deps}"
CHATGPT_ROOT="${MNOTE_CHATGPT_ROOT:-$DEPS_ROOT/CHATGPT}"

if ! command -v git >/dev/null 2>&1; then
  echo "git não encontrado." >&2
  exit 1
fi
if ! command -v lazbuild >/dev/null 2>&1; then
  echo "lazbuild não encontrado." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 não encontrado." >&2
  exit 1
fi

read_manifest() {
  python3 - "$MANIFEST" "$1" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    data=json.load(f)
value=data
for part in sys.argv[2].split("."):
    value=value[part]
if isinstance(value,list):
    for item in value:
        print(item)
else:
    print(value)
PY
}

CHATGPT_REPO="$(read_manifest chatgpt.repository)"
CHATGPT_COMMIT="$(read_manifest chatgpt.commit)"

mkdir -p "$DEPS_ROOT"
if [ ! -d "$CHATGPT_ROOT/.git" ]; then
  git clone --filter=blob:none --no-checkout "$CHATGPT_REPO" "$CHATGPT_ROOT"
fi

git -C "$CHATGPT_ROOT" fetch --depth=1 origin "$CHATGPT_COMMIT"
git -C "$CHATGPT_ROOT" checkout --detach "$CHATGPT_COMMIT"

actual="$(git -C "$CHATGPT_ROOT" rev-parse HEAD)"
if [ "$actual" != "$CHATGPT_COMMIT" ]; then
  echo "SHA do CHATGPT divergente: esperado $CHATGPT_COMMIT, obtido $actual" >&2
  exit 1
fi

while IFS= read -r package; do
  [ -n "$package" ] || continue
  lpk="$CHATGPT_ROOT/pacote/packages/$package.lpk"
  if [ ! -f "$lpk" ]; then
    echo "Pacote CHATGPT ausente no commit fixado: $lpk" >&2
    exit 1
  fi
  echo "==> Link: $package"
  lazbuild --add-package-link "$lpk"
  echo "==> Build: $package"
  lazbuild -B "$lpk"
done < <(read_manifest chatgpt.packages)

echo "CHATGPT dependency set pronto em $CHATGPT_ROOT"
echo "MNOTE_CHATGPT_ROOT=$CHATGPT_ROOT"
