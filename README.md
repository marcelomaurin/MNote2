# MNote2

MNote2 é um editor de texto simples, multiplataforma, desenvolvido em Lazarus, projetado para funcionar em Linux X86, Windows e Raspberry Pi 3. O projeto demonstra o uso da ferramenta Lazarus para desenvolvimento multiplataforma em Pascal. 

## Funcionalidades principais
- Editor de texto básico com suporte a múltiplas plataformas.
- Interface intuitiva para criação e edição de notas.
- Arquitetura modular separando apresentação, lógica de negócios e acesso a dados.
- Historicamente suportou Mac (versões descontinuadas).
- Registro e tratamento de exceções específicos do domínio.
  
## Integração com OpenAI para Busca e Processamento de Fontes

### Visão geral

O MNote2 integra-se com os serviços da OpenAI para aprimorar a experiência do usuário por meio da busca inteligente e processamento avançado de notas. Essa integração possibilita funcionalidades como:

- Busca semântica aprimorada para localizar com mais precisão informações dentro das notas.
- Sugestões inteligentes e geração automática de conteúdo baseado no texto existente.
- Análise e resumo inteligente de notas para facilitar a revisão rápida de conteúdo.

### Como funciona a integração

1. **Conexão com a API OpenAI**  
   O aplicativo utiliza a API oficial da OpenAI por meio de requisições HTTP REST para enviar consultas e textos. Configurações de chave da API e parâmetros de autenticação são definidas no arquivo de configuração da aplicação (ex.: `AppConfig`).

2. **Processamento de texto**  
   As notas e buscas são enviadas para os modelos de linguagem da OpenAI (como GPT-4 ou outros modelos configurados) que processam o conteúdo para retornar textos relevantes, sumarizações ou sugestões.

3. **Uso no fluxo do usuário**  
   Na interface do usuário (ex.: `NoteEditor` ou `MainWindow`), comandos especiais permitem ativar a busca inteligente ou pedir ao sistema para gerar sugestões baseadas no conteúdo atual da nota aberta.

### Configuração necessária

- Obter uma conta válida e chave de API no portal da OpenAI.
- Configurar `OPENAI_API_KEY` no arquivo de configurações ou variáveis ambiente.
- Garantir conexão à internet para acesso à API.

### Segurança e privacidade

- Dados trafegados para a OpenAI são tratados conforme as políticas da empresa; recomenda-se revisar e estar ciente destas.
- Nenhuma informação sensível deve ser enviada sem criptografia e permissão do usuário.

### Exemplos de uso (pseudo-exemplo em Pascal)

```pascal
function RequestOpenAI(const Prompt: string): string;
begin
  // Envia o prompt para a API OpenAI e retorna a resposta processada
  // Implementação com chamadas HTTP e parsing JSON
end;

procedure ProcessarBusca(const Query: string);
var
  Resultado: string;
begin
  Resultado := RequestOpenAI('Busque e resuma as seguintes notas: ' + Query);
  ShowMessage(Resultado);
end;
```

---

## Links importantes

- [Site oficial do MNote2](https://maurinsoft.github.io/MNote2)
- [Vídeo explicativo do MNote2](https://youtu.be/examplevideo)
- [Documentação oficial da API OpenAI](https://platform.openai.com/docs)

---

