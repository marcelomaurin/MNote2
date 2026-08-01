# Integração contínua

O workflow `.github/workflows/ci.yml` compila e executa o núcleo portátil em
Windows e Linux x64 com Lazarus 4.4. A matriz usa `tests/ci_core_runner.lpi` e
falha imediatamente se a compilação ou qualquer validação retornar código
diferente de zero.

O runner portátil cobre busca UTF-8, leitura de usage real, estimativa de tokens,
palavra de ativação e diff parcial. Um job adicional confirma que o projeto usa
os pacotes core e não introduziu `openai_agent` pesado no contrato da IDE.

Validação local desta entrega: build `x86_64-win64` e execução do runner com
mensagem final `OK: núcleo portátil compilado e validado em x86_64-Win64`.

O runner desktop completo continua em `tests/run_tests.ps1`, pois valida também
integrações Lazarus/Windows e os pacotes instalados localmente.
