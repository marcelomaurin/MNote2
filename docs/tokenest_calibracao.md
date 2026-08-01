# Calibração real do estimador de tokens

- Data: 2026-08-01 08:44:37
- Provider: Gemini
- Modelo efetivamente chamado: `gemini-2.5-flash`
- Aquecimento independente: 10 chamadas reais
- Validação: 20 chamadas reais
- Margem conservadora: 15% sobre a estimativa
- Privacidade: chave, prompts, respostas e JSON bruto não são gravados neste relatório.

## Aquecimento

- 1: portuguese, 362 caracteres, 96 tokens, 1485 ms, `usageMetadata.promptTokenCount`
- 2: code, 407 caracteres, 133 tokens, 797 ms, `usageMetadata.promptTokenCount`
- 3: portuguese, 524 caracteres, 138 tokens, 1468 ms, `usageMetadata.promptTokenCount`
- 4: code, 555 caracteres, 183 tokens, 1594 ms, `usageMetadata.promptTokenCount`
- 5: portuguese, 281 caracteres, 75 tokens, 828 ms, `usageMetadata.promptTokenCount`
- 6: code, 333 caracteres, 108 tokens, 797 ms, `usageMetadata.promptTokenCount`
- 7: portuguese, 443 caracteres, 117 tokens, 1031 ms, `usageMetadata.promptTokenCount`
- 8: code, 481 caracteres, 158 tokens, 750 ms, `usageMetadata.promptTokenCount`
- 9: portuguese, 605 caracteres, 159 tokens, 766 ms, `usageMetadata.promptTokenCount`
- 10: code, 262 caracteres, 86 tokens, 844 ms, `usageMetadata.promptTokenCount`

## Validação após aquecimento

| # | Perfil | Caracteres | Estimativa | Com margem | Real | Erro absoluto | Latência ms |
|---:|---|---:|---:|---:|---:|---:|---:|
| 1 | portuguese | 525 | 141 | 163 | 139 | 1,44% | 843 |
| 2 | code | 562 | 186 | 214 | 190 | 2,11% | 719 |
| 3 | portuguese | 687 | 184 | 212 | 181 | 1,66% | 828 |
| 4 | code | 712 | 235 | 271 | 242 | 2,89% | 766 |
| 5 | portuguese | 849 | 227 | 262 | 223 | 1,79% | 719 |
| 6 | code | 863 | 285 | 328 | 295 | 3,39% | 812 |
| 7 | portuguese | 444 | 119 | 137 | 118 | 0,85% | 766 |
| 8 | code | 487 | 161 | 186 | 164 | 1,83% | 812 |
| 9 | portuguese | 606 | 162 | 187 | 160 | 1,25% | 1375 |
| 10 | code | 637 | 211 | 243 | 216 | 2,31% | 813 |
| 11 | portuguese | 768 | 205 | 236 | 202 | 1,49% | 922 |
| 12 | code | 787 | 260 | 299 | 268 | 2,99% | 578 |
| 13 | portuguese | 931 | 249 | 287 | 245 | 1,63% | 859 |
| 14 | code | 412 | 136 | 157 | 138 | 1,45% | 844 |
| 15 | portuguese | 525 | 141 | 163 | 139 | 1,44% | 922 |
| 16 | code | 562 | 186 | 214 | 190 | 2,11% | 812 |
| 17 | portuguese | 687 | 184 | 212 | 181 | 1,66% | 969 |
| 18 | code | 712 | 235 | 271 | 242 | 2,89% | 1000 |
| 19 | portuguese | 849 | 227 | 262 | 223 | 1,79% | 1422 |
| 20 | code | 863 | 285 | 328 | 295 | 3,39% | 781 |

## Coeficientes e aceite

- Português: inicial 3,5000; calibrado 3,7467 caracteres/token.
- Código Pascal: inicial 3,2000; calibrado 3,0328 caracteres/token.
- Erro percentual absoluto médio: 2,02%.
- Pior subestimação antes da margem: 3,39%.
- Cobertura da margem conservadora: 20/20.

**ACEITE: aprovado.** Todas as chamadas de validação ficaram dentro do total estimado com margem.
