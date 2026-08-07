# Guia de Configuração e Diagnóstico OpenSSL / HTTPS no MNote2 (Windows 32-bit)

Este documento descreve a arquitetura de suporte a conexões seguras HTTPS/SSL no **MNote2**, os requisitos de DLLs para Windows 32 bits, o diagnóstico automatizado e a solução de problemas.

---

## 1. Visão Geral da Arquitetura SSL vs SSH

* **SSL / TLS (Transport Layer Security):** Utilizado por protocolos Web (HTTP/HTTPS), comunicação com APIs REST (ex.: GitHub, Neural API, OpenSSL, Web Services de Registro). No MNote2, a pilha HTTPS utiliza o suporte nativo OpenSSL do Free Pascal (`opensslsockets` / `TFPHTTPClient`) e/or Indy (`TIdHTTP`).
* **SSH (Secure Shell):** Utilizado para acesso a terminais e operações Git remotas.

---

## 2. Requisitos de Binários OpenSSL (Win32 / x86)

O **MNote2** é uma aplicação compilada para a arquitetura **Win32 (32 bits)** (`i386-win32`).

### ⚠️ Requisito Crítico de Arquitetura:
Todas as DLLs OpenSSL carregadas pelo executável `MNote2.exe` **devem ser binários PE32 de 32 bits (x86)**. Tentar carregar DLLs de 64 bits (`x64`) resultará no erro de sistema **193 (`ERROR_BAD_EXE_FORMAT`)**.

---

## 3. Nomes e Localização das DLLs

As DLLs devem estar localizadas no **mesmo diretório do executável `MNote2.exe`** (ex.: `C:\Program Files (x86)\MNote2\`).

### Par Principal (OpenSSL 1.1.x - Recomendado):
* `libssl-1_1.dll`
* `libcrypto-1_1.dll`

### Par Fallback (OpenSSL 1.0.x):
* `ssleay32.dll`
* `libeay32.dll`

O carregador central de SSL (`mnote_ssl_loader.pas`) define automaticamente `SetDllDirectory` para a pasta da aplicação e tenta inicializar primeiro o par 1.1.x e, em seguida, o par 1.0.x.

---

## 4. Diagnóstico por Linha de Comando (`--ssl-check`)

O MNote2 disponibiliza um comando CLI nativo para verificar e testar o ambiente OpenSSL e HTTPS sem abrir a interface gráfica.

### Comando:
```cmd
MNote2.exe --ssl-check
```

### Exemplo de Saída (Sucesso):
```text
Aplicação: 32 bits
Pasta: C:\Program Files (x86)\MNote2\
SSL: libssl-1_1.dll + libcrypto-1_1.dll
Resultado: OK
Conexão HTTPS (https://api.github.com/): OK (HTTP Status 200)
```

### Exemplo de Saída (Erro de Arquitetura x64 em Processo x86):
```text
Aplicação: 32 bits
Pasta: C:\Program Files (x86)\MNote2\
Resultado: ERRO
Código Windows: 193
Descrição: A DLL encontrada não é compatível com o MNote2 de 32 bits. Utilize uma versão OpenSSL x86.
```

---

## 5. Interpretação dos Códigos de Erro do Windows

Ao consultar o arquivo `EVENTOS.LOG` ou a saída do `--ssl-check`:

| Código Windows | Significado | Causa Comum & Solução |
| :--- | :--- | :--- |
| **126** | `ERROR_MOD_NOT_FOUND` | DLL OpenSSL ou dependência secundária ausente. Verifique se `libcrypto-1_1.dll` e `libssl-1_1.dll` estão na pasta do `MNote2.exe`. |
| **127** | `ERROR_PROC_NOT_FOUND` | Versão de DLL incompatível ou ponto de entrada ausente. Substitua o par de DLLs por um conjunto completo x86. |
| **193** | `ERROR_BAD_EXE_FORMAT` | **Arquitetura Incompatível.** Foi fornecida uma DLL de 64 bits para o MNote2 de 32 bits. Baixe a versão OpenSSL Win32 (x86). |

---

## 6. Como Substituir as DLLs com Segurança

1. Encerre o `MNote2.exe`.
2. Obtenha as DLLs `libssl-1_1.dll` e `libcrypto-1_1.dll` compiladas para **Win32 x86** (OpenSSL 1.1.1).
3. Copie os dois arquivos para a pasta de instalação do MNote2 (`C:\Program Files (x86)\MNote2\`).
4. Execute `MNote2.exe --ssl-check` para confirmar a validação.
