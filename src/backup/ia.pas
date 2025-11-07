unit IA;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Buttons, chatgpt, setmain, folders, mquery2;

type
  { TfrmIA }
  TfrmIA = class(TForm)
    btSair: TBitBtn;
    btPerguntar: TBitBtn;
    Chat: TTabSheet;
    meLog: TMemo;
    meHistorico: TMemo;
    meMapaMemoria: TMemo;
    mePensamento: TMemo;
    mePergunta: TMemo;
    meResposta: TMemo;
    pnResposta: TPanel;
    pnPergunta: TPanel;
    pgIA: TPageControl;
    pnTop: TPanel;
    pnBotton: TPanel;
    pnPainel: TPanel;
    btLimpaHist: TSpeedButton;
    Splitter1: TSplitter;
    TabSheet1: TTabSheet;
    tsMapaMemoria: TTabSheet;
    tsPensamento: TTabSheet;
    tsLog: TTabSheet;
    procedure btLimpaHistClick(Sender: TObject);
    procedure btPerguntarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure meHistoricoChange(Sender: TObject);
    procedure meMapaMemoriaChange(Sender: TObject);
    procedure mePensamentoChange(Sender: TObject);
    procedure mePerguntaKeyPress(Sender: TObject; var Key: char);
  private
    FChatGPT: TCHATGPT;
    procedure AddLog(const S: string);
    function TextoLimpo(const S: string): string;
  public
    procedure PerguntaIA();
    procedure AnalisaBanco();
    procedure AnalisaFolder();
    procedure MapeiaPensamento();
    procedure RespondePergunta();
    procedure LimparHistorico();
    function  QuestoesFolder(): boolean;
    function  QuestoesBanco(): boolean;
    procedure AnalisaRespostaFolder();  // <<< NOVA FUNÇÃO
    function BancoConectado(): boolean;
    function CriaDicionarioPost(): string;
  end;

var
  frmIA: TfrmIA;

implementation

{$R *.lfm}

uses
  LConvEncoding;

{ Utils }

procedure TfrmIA.AddLog(const S: string);
begin
  meLog.Lines.Add(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' - ' + S);
end;

function TfrmIA.TextoLimpo(const S: string): string;
begin
  // Garante UTF-8 para evitar caracteres “?” em logs/respostas
  Result := UTF8Encode(S);
end;

{ TfrmIA }

procedure TfrmIA.btLimpaHistClick(Sender: TObject);
begin
  LimparHistorico();
end;

procedure TfrmIA.btPerguntarClick(Sender: TObject);
begin
  PerguntaIA();
  mePergunta.SetFocus;
end;

procedure TfrmIA.FormCreate(Sender: TObject);
var
  arquivo, arquivo1, arquivo2 : string;
begin

  arquivo := FSetMain.Defaultfolder+'HISTORICO.RIA';
  arquivo1 :=FSetMain.Defaultfolder+'mapamemoria.RIA';
  arquivo2 :=FSetMain.Defaultfolder+'pensamento.RIA';
  if(FileExists(arquivo)) then
    meHistorico.Lines.LoadFromFile(arquivo);
  if(FileExists(arquivo1)) then
    meMapaMemoria.Lines.LoadFromFile(arquivo1);
  if(FileExists(arquivo2)) then
    mePensamento.Lines.LoadFromFile(arquivo2);

end;

procedure TfrmIA.meHistoricoChange(Sender: TObject);
var
  arquivo : string;
begin
  arquivo := FSetMain.Defaultfolder+'HISTORICO.RIA';
  if(FileExists(arquivo)) then
    meHistorico.Lines.SaveToFile(arquivo);
end;

procedure TfrmIA.meMapaMemoriaChange(Sender: TObject);
var
  arquivo : string;
begin
  arquivo := FSetMain.Defaultfolder+'mapamemoria.RIA';
  if(FileExists(arquivo)) then
    meMapaMemoria.Lines.SaveToFile(arquivo);
end;

procedure TfrmIA.mePensamentoChange(Sender: TObject);
var
    arquivo : string;
begin
    arquivo := FSetMain.Defaultfolder+'pensamento.RIA';
    if(FileExists(arquivo)) then
      meMapaMemoria.Lines.SaveToFile(arquivo);
end;

procedure TfrmIA.mePerguntaKeyPress(Sender: TObject; var Key: char);
begin
  if (key = #13) then
    PerguntaIA();
end;

procedure TfrmIA.PerguntaIA();
begin
  // 1) Coleta de contexto
  AnalisaBanco();
  AnalisaFolder();

  // 2) Consolida o “raciocínio” (mapa de memória -> pensamento)
  MapeiaPensamento();

  // 3) Faz a pergunta efetiva (gera resposta, histórico e log)
  RespondePergunta();
end;

function TfrmIA.CriaDicionarioPost(): string;
var
  baseDir, fileName: string;
begin
  {$IFDEF WINDOWS}
  // AppData do usuário (pasta de configuração da aplicação)
  baseDir := GetAppConfigDir(False);      // ex.: C:\Users\<user>\AppData\Local\<AppName>\
  {$ELSE}
  // Linux/macOS: pasta do usuário
  baseDir := GetUserDir;                  // ex.: /home/<user>/
  {$ENDIF}

  ForceDirectories(baseDir);
  fileName := IncludeTrailingPathDelimiter(baseDir) + 'dicionario.sql';

  // injeta o caminho por parâmetro
  result := frmmquery2.CriaDicionarioPost(fileName);

end;

procedure TfrmIA.AnalisaBanco();
begin
  if(QuestoesBanco()) then
  begin
      if(BancoConectado) then
      begin
        (*
          // Ponto de integração: traga resumos do banco (schemas/tabelas/colunas),
          // dependências, DDLs, etc. por agora, deixo um placeholder organizado.
          // Você pode popular este memo a partir do seu MQuery2/DM.
          meMapaMemoria.Lines.Add('--[BANCO]---------------------------------------');
          meMapaMemoria.Lines.Add('Schemas relevantes: public');
          meMapaMemoria.Lines.Add('Tabelas-chave: (preencha aqui via MQuery2/DM)');
          meMapaMemoria.Lines.Add('Dependências/FKs: (preencha aqui via MQuery2/DM)');
          meMapaMemoria.Lines.Add('');
         *)

        if(frmmquery2.zconpost.connected or frmmquery2.zconmysql.Connected) then
        begin
          //Conexao postgres
          if(frmmquery2.zconpost.connected) then
          begin
               meMapaMemoria.Lines.Add(CriaDicionarioPost());
          end;
          if(frmmquery2.zconmysql.Connected) then
          begin

          end;
        end;

      end
       else
      begin
          meMapaMemoria.Lines.Add('Avisa o usuario que é necessário conectar no banco de dados para fazer analises de dados.');

      end;
  end;


end;

procedure TfrmIA.AnalisaFolder();
begin
  if QuestoesFolder() then
  begin
    // Integra análise da unit Folders
    meMapaMemoria.Lines.Add('--[FOLDER/PROJETO]------------------------------');
    meMapaMemoria.Lines.Add(frmFolders.AnalisaFolderIA(mePergunta.Lines.Text));
    meMapaMemoria.Lines.Add(frmFolders.meLog.Lines.Text);

    // Resumo orientado à pergunta, extraído do meLog + pergunta
    AnalisaRespostaFolder();  // <<< chama a nova função
    meMapaMemoria.Lines.Add(''); // separador visual
  end;

end;

procedure TfrmIA.MapeiaPensamento();
var
  DevMsg : widestring;
  FullPrompt : widestring;
  Pergunta : widestring;
  Resposta : widestring;
begin
  // Converte o mapa de memória em um resumo curto e útil para o prompt.
  //mePensamento.Lines.Clear;
  mePensamento.Lines.Add('Resumo do contexto (banco + projeto):');
  mePensamento.Lines.Add('- Use nomes de schema/tabela/coluna exatamente como no mapa.');
  mePensamento.Lines.Add('- Considere dependências, FKs e DDL quando a pergunta envolver SQL.');
  mePensamento.Lines.Add('- Considere a estrutura de pastas e arquivos ao sugerir melhorias.');
  mePensamento.Lines.Add('');
  mePensamento.Lines.Add('Contexto condensado:');
  mePensamento.Lines.Add(meMapaMemoria.Text); // mantém prompt enxuto

  if FChatGPT = nil then
     FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

  Pergunta := mePergunta.Lines.text;


  // Mensagem de sistema (instruções para o modelo)
  DevMsg :=
    'Você é um analisador de dados e sua missão é montar um mapa de Pensamento coerente com a pergunta.' + LineEnding +
    'O histórico que será enviado representa as interações anteriores com o usuário,' + LineEnding +
    'e deve ser considerado como base de contexto e aprendizado para manter a coerência.' + LineEnding +
    LineEnding +
    'Siga as regras:' + LineEnding +
    '1) Crie um Mapa de pensamento coerente com que foi solicitado e embasado na conversa histórica.' + LineEnding +
    '2) Use o histórico como base para lembrar do contexto da conversa.' + LineEnding +
    '3) Trate a pergunta atual como o ponto principal a ser respondido.' + LineEnding +
    '4) Se for código, retorne sempre o código completo e formatado.' + LineEnding +
    '5) Se não houver contexto suficiente, peça mais detalhes.' + LineEnding;

  // Prompt principal enviado ao modelo
  FullPrompt :=
    '--- CONTEXTO HISTÓRICO ---' + LineEnding +
    'Abaixo está o histórico de toda a conversa até o momento. Use-o apenas para entender o contexto:' + LineEnding +
    LineEnding +
    meHistorico.lines.Text + LineEnding + LineEnding +
    '--- NOVA PERGUNTA ---' + LineEnding +
    'A seguir está a nova pergunta feita pelo usuário, que deve ser respondida considerando o histórico acima:' + LineEnding +
    Pergunta + LineEnding + LineEnding +
    '--- MAPA DE MEMÓRIA ---' + LineEnding +
    meMapaMemoria.lines.Text + LineEnding + LineEnding +
    '--- PENSAMENTO (INSTRUÇÕES INTERNAS) ---' + LineEnding +
    mePensamento.lines.Text;

  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev := DevMsg;

  AddLog('Enviando pergunta + histórico ao ChatGPT...');
  if FChatGPT.SendQuestion(FullPrompt) then
    Resposta := TextoLimpo(FChatGPT.Response)
  else
    Resposta := TextoLimpo(FChatGPT.Response);

  mePensamento.Lines.Text := Resposta;
   meMapaMemoria.Lines.Add(Resposta);


end;

procedure TfrmIA.RespondePergunta();
var
  Pergunta, DevMsg, FullPrompt, Resposta: string;
begin
  Pergunta := Trim(mePergunta.Text);
  if Pergunta = '' then
  begin
    AddLog('Pergunta vazia. Nada a enviar.');
    Exit;
  end;

  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

  // Mensagem de sistema (instruções para o modelo)
  DevMsg :=
    'Você é um assistente técnico e está participando de uma conversa contínua.' + LineEnding +
    'O histórico que será enviado representa as interações anteriores com o usuário,' + LineEnding +
    'e deve ser considerado como base de contexto e aprendizado para manter a coerência.' + LineEnding +
    LineEnding +
    'Siga as regras:' + LineEnding +
    '1) Responda com clareza e objetividade.' + LineEnding +
    '2) Use o histórico como base para lembrar do contexto da conversa.' + LineEnding +
    '3) Trate a pergunta atual como o ponto principal a ser respondido.' + LineEnding +
    '4) Se for código, retorne sempre o código completo e formatado.' + LineEnding +
    '5) Se não houver contexto suficiente, peça mais detalhes.' + LineEnding;

  // Prompt principal enviado ao modelo
  FullPrompt :=
    '--- CONTEXTO HISTÓRICO ---' + LineEnding +
    'Abaixo está o histórico de toda a conversa até o momento. Use-o apenas para entender o contexto:' + LineEnding +
    LineEnding +
    meHistorico.Text + LineEnding + LineEnding +
    '--- NOVA PERGUNTA ---' + LineEnding +
    'A seguir está a nova pergunta feita pelo usuário, que deve ser respondida considerando o histórico acima:' + LineEnding +
    Pergunta + LineEnding + LineEnding +
    '--- MAPA DE MEMÓRIA ---' + LineEnding +
    meMapaMemoria.Text + LineEnding + LineEnding +
    '--- PENSAMENTO (INSTRUÇÕES INTERNAS) ---' + LineEnding +
    mePensamento.Text;

  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev := DevMsg;

  AddLog('Enviando pergunta + histórico ao ChatGPT...');
  if FChatGPT.SendQuestion(FullPrompt) then
    Resposta := TextoLimpo(FChatGPT.Response)
  else
    Resposta := TextoLimpo(FChatGPT.Response);

  meResposta.Lines.Text := Resposta;

  // Atualiza histórico (mantém coerência para próximas interações)
  meHistorico.Lines.Add('');
  meHistorico.Lines.Add('Pergunta: ' + Pergunta);
  meHistorico.Lines.Add('Resposta: ' + Copy(Resposta, 1, 2000));
  AddLog('Resposta recebida com sucesso.');

  mePergunta.Lines.Clear;
end;

procedure TfrmIA.LimparHistorico();
begin
  meHistorico.Lines.Clear;
  meMapaMemoria.Lines.Clear;
  mePensamento.Lines.Clear;
  meResposta.Lines.Clear;
  meLog.Lines.Clear;
  AddLog('Histórico limpo.');
end;

function TfrmIA.QuestoesFolder(): boolean;
var
  Pergunta, DevMsg, Prompt, Resp: string;
  First: Char;
begin
  Result := False;

  Pergunta := Trim(mePergunta.Text);
  if Pergunta = '' then Exit;

  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

  // Responder apenas "Sim" ou "Nao"
  DevMsg :=
    'Você é um classificador. Responda apenas com "Sim" ou "Nao".' + LineEnding +
    'Sem justificativas, sem pontuação, sem quebras de linha.';
  Prompt :=
    'A pergunta abaixo envolve ARQUIVOS/PASTAS (abrir/salvar arquivo, listar diretórios, '+
    'caminhos, upload/download, leitura/escrita, extensão, nome de arquivo, e informações sobre um projeto.)?' + LineEnding +
    'Pergunta: "' + Pergunta + '"' + LineEnding +
    'Responda apenas com "Sim" ou "Nao".';

  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev   := DevMsg;

  AddLog('Classificando se a pergunta envolve arquivos/pastas...');
  if FChatGPT.SendQuestion(Prompt) then
    Resp := Trim(FChatGPT.Response)
  else
    Resp := Trim(FChatGPT.Response);

  if Resp <> '' then
  begin
    First := UpCase(Resp[1]);  // evita problemas com acentos
    if First = 'S' then
      Result := True
    else if First = 'N' then
      Result := False;
  end;

  AddLog(Format('QuestoesFolder => Resp="%s" | Result=%s',
    [Resp, BoolToStr(Result, True)]));
end;

function TfrmIA.QuestoesBanco(): boolean;
var
  Pergunta, DevMsg, Prompt, Resp: string;
  First: Char;
begin
  Result := False;

  Pergunta := Trim(mePergunta.Text);
  if Pergunta = '' then Exit;

  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

  // Responder apenas "Sim" ou "Nao"
  DevMsg :=
    'Você é um classificador. Responda apenas com "Sim" ou "Nao".' + LineEnding +
    'Sem justificativas, sem pontuação, sem quebras de linha.';
  Prompt :=
    'A pergunta abaixo envolve BANCO DE DADOS (consultas SQL, tabelas, campos, conexões, ' +
    'PostgreSQL, MySQL, SQLite, schemas, inserts, selects, updates, triggers, views, dicionario de dados, tabelas, banco, triggers  ou scripts de banco) ou qualquer informação associada que precise ser obtida em um banco de dados?' + LineEnding +
    'Pergunta: "' + Pergunta + '"' + LineEnding +
    'Responda apenas com "Sim" ou "Nao".';

  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev   := DevMsg;

  AddLog('Classificando se a pergunta envolve banco de dados...');
  if FChatGPT.SendQuestion(Prompt) then
    Resp := Trim(FChatGPT.Response)
  else
    Resp := Trim(FChatGPT.Response);

  if Resp <> '' then
  begin
    First := UpCase(Resp[1]);  // evita problemas com acentos
    if First = 'S' then
      Result := True
    else if First = 'N' then
      Result := False;
  end;

  AddLog(Format('QuestoesBanco => Resp="%s" | Result=%s',
    [Resp, BoolToStr(Result, True)]));
end;


procedure TfrmIA.AnalisaRespostaFolder();
var
  Pergunta, DevMsg, Prompt, Resposta, Historico, LogTxt: string;
begin
  // Gera resumo do LOG focado na pergunta atual e grava no meMapaMemoria
  Pergunta  := Trim(mePergunta.Text);
  Historico := Copy(meHistorico.Text, 1, 4000);   // mantém curto
  LogTxt    := Copy(meLog.Lines.Text, 1, 8000);   // fonte dos fatos

  if (Pergunta = '') or (LogTxt = '') then
  begin
    AddLog('AnalisaRespostaFolder: pergunta ou log vazio(s).');
    Exit;
  end;

  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

  // Instruções para extrair somente o que é pertinente à pergunta
  DevMsg :=
    'Você é um assistente técnico que extrai respostas objetivas do LOG.' + LineEnding +
    'Use o histórico apenas como contexto mínimo.' + LineEnding +
    'Retorne um texto corrido, sem listas, sem preâmbulo, no máx. 1000 caracteres.' + LineEnding +
    'Se não houver nada útil, responda exatamente: Sem dados relevantes';

  Prompt :=
    '--- CONTEXTO HISTÓRICO (resumo) ---' + LineEnding +
    Historico + LineEnding + LineEnding +
    '--- LOG DO FOLDER (fonte factual) ---' + LineEnding +
    LogTxt + LineEnding + LineEnding +
    '--- PERGUNTA ---' + LineEnding +
    Pergunta + LineEnding + LineEnding +
    'TAREFA: Com base apenas no LOG, gere um texto curto com as respostas relevantes à pergunta.' + LineEnding +
    'Não explique o procedimento, apenas responda objetivamente.' + LineEnding +
    'Sem listas, sem títulos, sem rodapé.';

  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev   := DevMsg;

  AddLog('AnalisaRespostaFolder: gerando resumo relevante do log...');
  if FChatGPT.SendQuestion(Prompt) then
    Resposta := TextoLimpo(Trim(FChatGPT.Response))
  else
    Resposta := TextoLimpo(Trim(FChatGPT.Response));

  if Resposta = '' then
    Resposta := 'Sem dados relevantes';

  meMapaMemoria.Lines.Add('--- [FOLDER/RESUMO RELEVANTE] ---');
  meMapaMemoria.Lines.Add(Resposta);
  AddLog('AnalisaRespostaFolder: resumo adicionado ao mapa de memória.');
end;

function TfrmIA.BancoConectado(): boolean;
begin
  if(frmmquery2 <> nil) then
  begin
    result := frmmquery2.zconpost.Connected or  frmmquery2.zconmysql.Connected;
  end
  else
    result := false;
end;

end.

