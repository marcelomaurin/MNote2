#!/usr/bin/env python3
from pathlib import Path
import json
import re
import sys

root = Path(__file__).resolve().parents[1]
manifest_path = root / "ci" / "dependencies.json"

def fail(msg):
    print("ERROR:", msg, file=sys.stderr)
    raise SystemExit(1)

if not manifest_path.is_file():
    fail("ci/dependencies.json ausente")

data = json.loads(manifest_path.read_text(encoding="utf-8"))
if data.get("schema") != 1:
    fail("schema de dependências não suportado")

chatgpt = data.get("chatgpt") or {}
repo = chatgpt.get("repository", "")
commit = chatgpt.get("commit", "")
packages = chatgpt.get("packages") or []
bgrabitmap = data.get("bgrabitmap") or {}
bgra_repo = bgrabitmap.get("repository", "")
bgra_commit = bgrabitmap.get("commit", "")

if repo != "https://github.com/marcelomaurin/CHATGPT.git":
    fail("repositório CHATGPT inesperado")
if not re.fullmatch(r"[0-9a-f]{40}", commit):
    fail("CHATGPT deve estar fixado por SHA completo de 40 caracteres")
if bgra_repo != "https://github.com/bgrabitmap/bgrabitmap.git":
    fail("repositório BGRABitmap inesperado")
if not re.fullmatch(r"[0-9a-f]{40}", bgra_commit):
    fail("BGRABitmap deve estar fixado por SHA completo de 40 caracteres")
if not packages:
    fail("lista de pacotes CHATGPT vazia")
if len(packages) != len(set(packages)):
    fail("pacotes CHATGPT duplicados")

required = {
    "openai_core",
    "openai_agent",
    "openai_graph",
    "openai_project_core",
    "openai_files",
    "openai_output",
}
missing = sorted(required.difference(packages))
if missing:
    fail("pacotes essenciais ausentes: " + ", ".join(missing))

lpi_path = root / "src" / "MNote2.lpi"
if not lpi_path.is_file():
    fail("src/MNote2.lpi ausente")

lpi = lpi_path.read_text(encoding="utf-8", errors="strict")
declared_packages = set(re.findall(r'<PackageName Value="([^"]+)"', lpi))

chatgpt_declared = {p for p in declared_packages if p.startswith("openai_")}
missing_chatgpt = sorted(chatgpt_declared.difference(packages))
if missing_chatgpt:
    fail("pacotes openai_* do MNote2 ausentes do manifesto: " + ", ".join(missing_chatgpt))

print(
    f"OK: dependências fixadas; CHATGPT={commit}, "
    f"{len(packages)} pacotes CHATGPT e {len(declared_packages)} pacotes Lazarus declarados."
)
