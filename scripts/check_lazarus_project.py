#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[1]
LPI = ROOT / "src" / "MNote2.lpi"
SRC = ROOT / "src"


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    if not LPI.exists():
        fail(f"project file not found: {LPI}")

    tree = ET.parse(LPI)
    root = tree.getroot()
    missing: list[str] = []
    backup_refs: list[str] = []

    for node in root.findall(".//Units/*/Filename"):
        value = node.attrib.get("Value", "").strip()
        if not value:
            continue
        normalized = value.replace("\\", "/")
        if "/backup/" in f"/{normalized.lower()}/" or normalized.lower().startswith("backup/"):
            backup_refs.append(value)
        path = SRC / pathlib.PurePosixPath(normalized)
        if not path.exists():
            missing.append(value)

    if missing:
        fail("files declared in MNote2.lpi are missing: " + ", ".join(missing))
    if backup_refs:
        fail("backup files must not be part of the Lazarus project: " + ", ".join(backup_refs))

    unit_names: dict[str, list[pathlib.Path]] = {}
    for path in SRC.rglob("*.pas"):
        if "backup" in {p.lower() for p in path.parts}:
            continue
        try:
            head = path.read_text(encoding="utf-8", errors="ignore")[:4096]
        except OSError:
            continue
        match = re.search(r"(?im)^\s*unit\s+([A-Za-z_][A-Za-z0-9_]*)\s*;", head)
        if match:
            unit_names.setdefault(match.group(1).lower(), []).append(path)

    critical = {"main", "item", "setmain", "toolsouvir", "toolsfalar"}
    duplicates = []
    for name in sorted(critical):
        files = unit_names.get(name, [])
        if len(files) > 1:
            duplicates.append(f"{name}: " + ", ".join(str(p.relative_to(ROOT)) for p in files))
    if duplicates:
        fail("duplicate critical Pascal units: " + " | ".join(duplicates))

    voice_service = SRC / "services" / "mnote_voice_input_service.pas"
    tools_ouvir = SRC / "toolsouvir" / "toolsouvir.pas"
    if not voice_service.exists():
        fail("CHATGPT voice input service is missing")
    voice_text = voice_service.read_text(encoding="utf-8", errors="ignore").lower()
    for unit in ("aiaudio", "aispeechrecognizer", "aiwhisperengine"):
        if unit not in voice_text:
            fail(f"voice input service does not use CHATGPT component unit {unit}")
    ouvir_text = tools_ouvir.read_text(encoding="utf-8", errors="ignore").lower()
    if "mnote_voice_input_service" not in ouvir_text:
        fail("ToolsOuvir is not wired to the CHATGPT voice input service")

    print("Lazarus project integrity: OK")


if __name__ == "__main__":
    main()
