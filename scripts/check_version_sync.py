#!/usr/bin/env python3
"""Valida que a versao dos READMEs bate com src/mnote_version.pas."""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

PATTERNS = {
    'README.md': r'Versão desta entrega: \*\*([0-9.]+)\*\*',
    'README.pt.md': r'Versão desta entrega: \*\*([0-9.]+)\*\*',
    'README.en.md': r'Current source version: \*\*([0-9.]+)\*\*',
    'README.es.md': r'Versión actual del código fuente: \*\*([0-9.]+)\*\*',
    'README.fr.md': r'Version actuelle du code source : \*\*([0-9.]+)\*\*',
    'README.ar.md': r'\*\*([0-9.]+)\*\*',
}


def source_version():
    text = (ROOT / 'src' / 'mnote_version.pas').read_text(encoding='utf-8')
    match = re.search(r"MNOTE_APP_VERSION\s*=\s*'([0-9.]+)'", text)
    if not match:
        sys.exit('MNOTE_APP_VERSION nao encontrada em src/mnote_version.pas')
    return match.group(1)


def main():
    expected = source_version()
    failures = []
    for name, pattern in PATTERNS.items():
        path = ROOT / name
        if not path.exists():
            failures.append(f'{name}: arquivo ausente')
            continue
        match = re.search(pattern, path.read_text(encoding='utf-8'))
        if not match:
            failures.append(f'{name}: linha de versao nao encontrada')
        elif match.group(1) != expected:
            failures.append(f'{name}: {match.group(1)} != {expected}')
    if failures:
        print('Versao fora de sincronia com mnote_version.pas (%s):' % expected)
        for item in failures:
            print('  - ' + item)
        return 1
    print('Versao sincronizada: %s' % expected)
    return 0


if __name__ == '__main__':
    sys.exit(main())
