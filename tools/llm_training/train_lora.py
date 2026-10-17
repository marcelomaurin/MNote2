#!/usr/bin/env python3
"""Fine-tuning supervisionado LoRA/QLoRA; sem downloads implícitos de modelos."""
import argparse
import json
import os
import sys
from pathlib import Path


def check_config(config):
    required = ["model_path", "dataset_path", "output_dir"]
    for key in required:
        if not isinstance(config.get(key), str) or not config[key].strip():
            raise ValueError("Campo obrigatório: " + key)
    model = Path(config["model_path"]).expanduser()
    dataset = Path(config["dataset_path"]).expanduser()
    if not model.is_dir():
        raise ValueError("Pasta do modelo não encontrada: " + str(model))
    if not dataset.is_file():
        raise ValueError("Dataset não encontrado: " + str(dataset))
    if dataset.suffix.lower() != ".jsonl":
        raise ValueError("Dataset deve ser JSONL")
    examples = []
    for line_number, line in enumerate(dataset.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError as exc:
            raise ValueError(f"JSONL inválido na linha {line_number}: {exc}") from exc
        if not isinstance(row, dict) or not isinstance(row.get("text"), str) or not row["text"].strip():
            raise ValueError(f"Linha {line_number}: campo text obrigatório")
        examples.append(row["text"])
    if len(examples) < 2:
        raise ValueError("O dataset precisa de pelo menos dois exemplos textuais")
    mode = config.get("mode", "lora").lower()
    if mode not in ("lora", "qlora"):
        raise ValueError("mode deve ser lora ou qlora")
    for key, low, high in [("epochs", 1, 100), ("batch_size", 1, 64),
                            ("gradient_accumulation", 1, 128), ("max_length", 32, 8192),
                            ("lora_r", 1, 256), ("lora_alpha", 1, 1024)]:
        value = config.get(key, {"epochs": 1, "batch_size": 1, "gradient_accumulation": 4,
                                 "max_length": 512, "lora_r": 8, "lora_alpha": 16}[key])
        if not isinstance(value, int) or not low <= value <= high:
            raise ValueError(f"{key} deve ser inteiro entre {low} e {high}")
    out = Path(config["output_dir"]).expanduser().resolve()
    if out == model.resolve() or out == dataset.parent.resolve():
        raise ValueError("Escolha uma pasta de saída separada da origem")
    return examples, mode, out


def run(config, dry_run=False):
    texts, mode, out = check_config(config)
    if dry_run:
        print(json.dumps({"status": "valid", "examples": len(texts), "mode": mode,
                          "output_dir": str(out)}, ensure_ascii=False))
        return
    try:
        import torch
        from datasets import Dataset
        from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
        from transformers import (AutoTokenizer, AutoModelForCausalLM, Trainer,
                                  TrainingArguments, DataCollatorForLanguageModeling)
    except ImportError as exc:
        raise RuntimeError("Instale os pacotes de requirements.txt no ambiente Python do treino") from exc
    if mode == "qlora" and not torch.cuda.is_available():
        raise RuntimeError("QLoRA exige CUDA disponível neste backend")
    model_path = str(Path(config["model_path"]).expanduser().resolve())
    tokenizer = AutoTokenizer.from_pretrained(model_path, local_files_only=True,
                                               trust_remote_code=False)
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
    kwargs = {"local_files_only": True, "trust_remote_code": False}
    if mode == "qlora":
        from transformers import BitsAndBytesConfig
        kwargs["quantization_config"] = BitsAndBytesConfig(
            load_in_4bit=True, bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.float16, bnb_4bit_use_double_quant=True)
        kwargs["device_map"] = "auto"
    model = AutoModelForCausalLM.from_pretrained(model_path, **kwargs)
    if mode == "qlora":
        model = prepare_model_for_kbit_training(model)
    adapter = LoraConfig(
        r=config.get("lora_r", 8), lora_alpha=config.get("lora_alpha", 16),
        lora_dropout=0.05, bias="none", task_type="CAUSAL_LM",
        target_modules=config.get("target_modules", ["q_proj", "v_proj"]))
    model = get_peft_model(model, adapter)
    limit = config.get("max_length", 512)
    tokens = Dataset.from_dict({"text": texts}).map(
        lambda examples: tokenizer(examples["text"], truncation=True, max_length=limit),
        batched=True, remove_columns=["text"])
    args = TrainingArguments(
        output_dir=str(out), num_train_epochs=config.get("epochs", 1),
        per_device_train_batch_size=config.get("batch_size", 1),
        gradient_accumulation_steps=config.get("gradient_accumulation", 4),
        learning_rate=float(config.get("learning_rate", 2e-4)),
        save_strategy="epoch", logging_steps=5, report_to="none",
        remove_unused_columns=False)
    trainer = Trainer(model=model, args=args, train_dataset=tokens,
                     data_collator=DataCollatorForLanguageModeling(tokenizer, mlm=False))
    trainer.train()
    out.mkdir(parents=True, exist_ok=True)
    model.save_pretrained(str(out))
    tokenizer.save_pretrained(str(out))
    print(json.dumps({"status": "complete", "adapter_dir": str(out)}, ensure_ascii=False))


def main():
    parser = argparse.ArgumentParser(description="MNote2 - treinador LoRA/QLoRA")
    parser.add_argument("--config", required=True)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    try:
        config = json.loads(Path(args.config).read_text(encoding="utf-8"))
        if not isinstance(config, dict):
            raise ValueError("Configuração deve ser objeto JSON")
        run(config, args.dry_run)
    except Exception as exc:
        print(json.dumps({"status": "error", "message": str(exc)}, ensure_ascii=False), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
