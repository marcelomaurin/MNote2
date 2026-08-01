# Compilação de referência

## Resultado

Em 31/07/2026, antes das alterações funcionais do roadmap, o MNote2 foi recompilado integralmente com sucesso. O comando executado foi:

```text
C:\lazarus\lazbuild.exe --build-all src\MNote2.lpi
```

Resultado factual: exit code `0`, alvo `src/MNote2.exe`, 26.323 linhas compiladas, 284 warnings, 541 hints e 302 notes. Os avisos preexistentes fazem parte da linha de base e não foram tratados como falha, mas novas regressões de compilação bloqueiam a etapa seguinte.

## Ambiente

| Item | Valor |
|---|---|
| Sistema operacional | Microsoft Windows 11 Pro 10.0.22631 (64 bits) |
| Processador | Intel Core i3-10100 @ 3.60 GHz, 8 processadores lógicos |
| Memória física | 15,8 GB |
| Lazarus | 4.4 em `C:\lazarus` |
| Free Pascal | 3.2.2, compilador `i386-win32` |
| Widgetset/target | Win32 / i386 |
| Configuração Lazarus | `C:\Users\mmaurin\AppData\Local\lazarus` |
| Projeto | `src/MNote2.lpi` |
| Executável | `src/MNote2.exe` |

## Pacotes requeridos

`atsynedit_ex_package`, `pkSalesSwitch`, `indylaz`, `IPEdit_pkg`, `zcomponentdesign`, `LazUtils`, `lnetbase`, `synuni`, `synfacilsyn`, `SynEditDsgn`, `SynEdit`, `myexamplepackage`, `TAChartLazarusPkg`, `FCL`, `poweredby`, `industrial`, `pkg_gifanim`, `zcomponent`, `multiloglaz`, `rxnew`, `python4lazarus_package`, `lnetvisual`, `LCL`, `openai_core` e `openai_python`.

Os pacotes `openai_core` e `openai_python` são resolvidos em `D:\projetos\maurinsoft\CHATGPT\pacote\packages`. O build também registrou a duplicidade preexistente da unit `funcoes` entre o MNote2 e `openai_core`; ela deve ser eliminada pela matriz de pacotes sem trocar silenciosamente a unit resolvida.

## Regra de regressão

- Cada tarefa deve terminar com `lazbuild src\MNote2.lpi` retornando zero.
- Mudanças de núcleo recebem também teste isolado pelo runner em `tests/`.
- Builds completos são repetidos nos marcos e antes do instalador.
- A entrega final deve registrar o hash SHA-256 do executável e do instalador.
