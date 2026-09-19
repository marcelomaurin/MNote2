#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$ROOT/ci/dependencies.json"
DEPS_ROOT="${MNOTE_DEPS_ROOT:-$ROOT/.ci-deps}"
BGRA_ROOT="$DEPS_ROOT/BGRABitmap"
ATSYN_ROOT="$DEPS_ROOT/ATSynEdit"

read_json() {
  python3 - "$MANIFEST" "$1" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    data=json.load(f)
value=data
for part in sys.argv[2].split("."):
    value=value[part]
print(value)
PY
}

BGRA_REPO="$(read_json bgrabitmap.repository)"
BGRA_COMMIT="$(read_json bgrabitmap.commit)"

mkdir -p "$DEPS_ROOT"

if [ ! -d "$BGRA_ROOT/.git" ]; then
  git clone --filter=blob:none --no-checkout "$BGRA_REPO" "$BGRA_ROOT"
fi
git -C "$BGRA_ROOT" fetch --depth=1 origin "$BGRA_COMMIT"
git -C "$BGRA_ROOT" checkout --detach "$BGRA_COMMIT"

BGRA_LPK="$BGRA_ROOT/bgrabitmap/bgrabitmappack.lpk"
test -f "$BGRA_LPK"

echo "==> Link/build BGRABitmapPack"
lazbuild --add-package-link "$BGRA_LPK"
lazbuild -B "$BGRA_LPK"

rm -rf "$ATSYN_ROOT"
mkdir -p "$ATSYN_ROOT"
curl -fsSL https://packages.lazarus-ide.org/ATSynEdit.zip -o "$DEPS_ROOT/ATSynEdit.zip"
unzip -q -o "$DEPS_ROOT/ATSynEdit.zip" -d "$ATSYN_ROOT"

BASE_LPK="$(find "$ATSYN_ROOT" -type f -iname 'atsynedit_package.lpk' | head -n 1)"
EX_LPK="$(find "$ATSYN_ROOT" -type f -iname 'atsynedit_ex_package.lpk' | head -n 1)"

if [ -z "$BASE_LPK" ] || [ -z "$EX_LPK" ]; then
  echo "Pacotes ATSynEdit esperados não encontrados." >&2
  find "$ATSYN_ROOT" -type f -name '*.lpk' -print >&2
  exit 1
fi

echo "==> Link/build atsynedit_package"
lazbuild --add-package-link "$BASE_LPK"
lazbuild -B "$BASE_LPK"

echo "==> Link/build atsynedit_ex_package"
lazbuild --add-package-link "$EX_LPK"
lazbuild -B "$EX_LPK"

echo "BGRABitmap e ATSynEdit preparados."


bootstrap_named_opm_package() {
  local archive="$1"
  local package_name="$2"
  local target_dir="$DEPS_ROOT/$archive"

  rm -rf "$target_dir"
  mkdir -p "$target_dir"
  curl -fsSL "https://packages.lazarus-ide.org/$archive.zip" -o "$DEPS_ROOT/$archive.zip"
  unzip -q -o "$DEPS_ROOT/$archive.zip" -d "$target_dir"

  local lpk
  lpk="$(python3 - "$target_dir" "$package_name" <<'PY'
from pathlib import Path
import re, sys
root = Path(sys.argv[1])
wanted = sys.argv[2].lower()
for path in root.rglob("*.lpk"):
    text = path.read_text(encoding="utf-8", errors="ignore")
    m = re.search(r'<Name Value="([^"]+)"', text, re.I)
    if m and m.group(1).lower() == wanted:
        print(path)
        break
PY
)"
  if [ -z "$lpk" ]; then
    echo "Pacote $package_name não encontrado em $archive.zip" >&2
    find "$target_dir" -type f -name '*.lpk' -print >&2
    exit 1
  fi

  echo "==> Link/build $package_name"
  lazbuild --add-package-link "$lpk"
  lazbuild -B "$lpk"
}

bootstrap_named_opm_package "ExtraSyn" "synuni"
bootstrap_named_opm_package "SynFacilSyn" "synfacilsyn"

echo "ExtraSyn e SynFacilSyn preparados."
