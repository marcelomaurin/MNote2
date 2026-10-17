# Treinamento de LLM — MNote2

## Escopo

O treinamento tradicional em `src/imgjson` permanece preservado. A modalidade LLM utiliza fine-tuning supervisionado de um **modelo causal local em formato Transformers** com adaptadores LoRA/QLoRA. Não treina modelos do zero e não usa arquivos GGUF como entrada direta.

## Interface da IDE

No menu principal do MNote2, abra **Treinamento LLM (LoRA / QLoRA)**. Indique o Python do ambiente de treinamento, a pasta local do modelo Transformers, dataset JSONL e pasta de saída. Escolha modalidade, épocas, batch size e limite de tokens. Use **Validar configuração** para executar o diagnóstico sem treinar; **Iniciar treinamento** para executar, e **Interromper** para solicitar o encerramento do processo. O painel inferior exibe a saída do processo. A janela deve permanecer aberta durante o treino. O instalador inclui os scripts Python, mas não instala automaticamente as bibliotecas pesadas necessárias.

## Execução

Crie ambiente Python dedicado, instale `tools/llm_training/requirements.txt`, copie `config.example.json` e aponte para um modelo local, dataset JSONL e uma pasta de saída separada.

```bash
python tools/llm_training/train_lora.py --config minha_config.json --dry-run
python tools/llm_training/train_lora.py --config minha_config.json
```

O dry-run verifica parâmetros, arquivos e o formato do dataset **sem carregar o modelo**. A saída é um adaptador PEFT, não um modelo GGUF pronto para Ollama ou llama.cpp.

## Dataset

Cada linha contém um JSON com campo `text` não vazio; dois ou mais exemplos são exigidos. Revise dados pessoais, direitos de uso e consentimento antes de treinar.

## Hardware e compatibilidade

QLoRA é destinado a CUDA com bitsandbytes e exige ambiente compatível. Modelos e arquiteturas diferem em módulos adaptáveis; ajuste `target_modules` de acordo com o modelo. Para GPUs com VRAM limitada, diminua `max_length`, batch size e use acumulação de gradientes. A execução não garante compatibilidade com todas as arquiteturas, sistemas ou placas.

## Segurança e limitações

A configuração exige caminho de modelo local e desabilita `trust_remote_code`; não baixa pesos automaticamente. A execução pode consumir bastante RAM/VRAM e tempo. Execute sob conta sem privilégios, monitore uso de recursos e faça cópias do dataset. Não há publicação de modelos nem upload externo pelo script.

## Estado de validação

Implementação inicial do motor Python, exemplos, interface Lazarus e empacotamento no instalador. Ainda não houve compilação da IDE nem teste real de treinamento nesta sessão; funcionalidades e compatibilidade devem ser validadas antes de release.
