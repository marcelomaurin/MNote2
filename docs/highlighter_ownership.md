# Ownership e cobertura dos highlighters

## MIDE-G04 — decisão de ownership

Antes da migração, `TItem.CheckTipoArquivo` criava até doze highlighters com o
form principal como owner. Ao fechar uma aba, o `TItem` era destruído, mas esses
componentes permaneciam vivos até o encerramento da aplicação. Além disso, o
destrutor de `TItem` tinha toda a liberação comentada.

A implementação nova usa `TMNoteHighlighterFactory` e cria exatamente uma
instância por `TItem`, com o próprio item como owner. A instância não é
compartilhada: highlighters mantêm atributos mutáveis e estado de range durante
o parse. Ao trocar de perfil, o editor é desassociado antes da liberação; ao
fechar a aba, o ownership de `TComponent` libera a instância.

`tests/highlighter_ownership_test.lpi` cria duas instâncias Pascal, comprova
owners distintos, altera o atributo de apenas uma e verifica que a outra não
muda. O cenário é compilado com `heaptrc`.

## MIDE-048A — matriz de cobertura

| Extensões | Perfil | Classe real | Decisão/fallback |
| --- | --- | --- | --- |
| `.pas .pp .lpr .lpk .inc` | Pascal | `TSynPasSyn` | Sem fallback |
| `.py .pyw` | Python | `TSynPythonSyn` | Sem fallback |
| `.sql` | SQL | `TSynSQLSyn` | Sem fallback |
| `.js .mjs .cjs .ts .tsx` | JavaScript | `TSynJScriptSyn` | TypeScript usa semântica JS parcial |
| `.json` | JSON | `TSynJScriptSyn` | Próximo à gramática JSON; sem comentários válidos |
| `.xml .xsd .xsl .svg` | XML | `TSynXMLSyn` | Sem fallback |
| `.html .htm` | HTML | `TSynHTMLSyn` | Sem fallback |
| `.css .scss` | CSS | `TSynCssSyn` | SCSS recebe cobertura CSS parcial |
| `.ini .cfg` | INI | `TSynIniSyn` | Sem fallback |
| `.md .markdown` | Markdown | `TSynAnySyn` | Fallback genérico, sem semântica Markdown |
| `.yaml .yml` | YAML | `TSynAnySyn` | Fallback genérico, sem semântica YAML |
| `.php .phtml` | PHP | `TSynPHPSyn` | Sem fallback |
| `.c .cc .cpp .cxx .h .hpp` | C/C++ | `TSynCppSyn` | Sem fallback |
| `.java` | Java | `TSynJavaSyn` | Sem fallback |
| `.sh .bash` | Shell | `TSynUNIXShellScriptSyn` | Sem fallback |
| `.bat .cmd` | Batch | `TSynBatSyn` | Sem fallback |
| `.txt .log .conf` e desconhecidas | Text | nenhum | Texto simples intencional |
