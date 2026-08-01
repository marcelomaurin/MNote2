# Prova factual do dicionário de dados

Em 31/07/2026, no Windows 11, Lazarus 4.4 e FPC 3.2.2/i386-win32, o pacote
`openai_aidbase.lpk` do repositório CHATGPT foi recompilado com sucesso contra
o mesmo `zcomponent` usado pelo MNote2. O pacote declara `openai_core`, `LCL`,
`FCL` e `zcomponent`; não foi criado adaptador para esconder incompatibilidades.

O MNote2 declara o pacote somente após essa prova. `TMNoteDBDictionaryService`
instancia `TAIPostgreSQLDictionary` ou `TAISQLiteDictionary` conforme o protocolo
da `TZConnection` já existente. A conexão e as credenciais continuam pertencendo
ao MQuery2. MySQL, Firebird, Oracle e SQL Server são apresentados como
experimentais e não são instanciados pelo serviço.

Comando factual executado: `lazbuild pacote/packages/openai_aidbase.lpk`.
Resultado: código de saída 0, sem erro de símbolo ou conflito Zeos.
