unit IA;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Buttons, chatgpt, setmain, folders, mquery2, fpjson, jsonparser,
  item,SynEditTypes, SynEdit;

type
  TTipoAcao = (
    taGerar_PesquisarInformacao,
    taGerar_CriarTabela,
    taGerar_ModificarTabela,
    taGerar_ModificarCodigo,
    taGerar_NovoCodigo,
    taGerar_EnviarEmail
  );

  const
  TIPO_ACAO_NOME: array[TTipoAcao] of string = (
    'GERAR_PESQUISARINFORMACAO',
    'GERAR_CRIARTABELA',
    'GERAR_MODIFICARTABELA',
    'GERAR_MODIFICARCODIGO',
    'GERAR_NOVOCODIGO',
    'GERAR_ENVIAREMAIL'
  );

  const
  TIPO_ACAO_DESCRICAO: array[TTipoAcao] of string = (
    'Pesquisar informações no banco de dados (ex: gerar SELECTs, consultas e buscas).',
    'Criar novas tabelas no banco de dados, incluindo campos e tipos.',
    'Alterar a estrutura de uma tabela existente (ex: adicionar campos, alterar tipos).',
    'Modificar código já existente, aplicando correções ou melhorias.',
    'Gerar novo código do zero, criando arquivos, funções, classes ou estruturas.',
    'Gerar e enviar um e-mail automaticamente com base no conteúdo analisado.'
  );




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
    lstAcao: TStringList;
    lstRealizar: TStringList;
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
    function VerificaContinuidade(): boolean;
    function GeraAcao(const Resposta: string): boolean; //Verifica geracao de ação
    function AnalisaAcao(const Resposta: string) : boolean; //Identifica Acoes
    function AcaoToStr(Acao: TTipoAcao): string;
    procedure FazPerguntaIA();
    function IsAcaoValida(const S: string): boolean;
    function StrToAcao(const S: string; out Acao: TTipoAcao): boolean;
    procedure ExecutaAcao(const NomeAcao, TextoResposta: string);
    procedure Acao_Gerar_PesquisarInformacao(const TextoResposta: string);
    procedure Acao_Gerar_CriarTabela(const TextoResposta: string);
    procedure Acao_Gerar_ModificarTabela(const TextoResposta: string);
    procedure Acao_Gerar_ModificarCodigo(const TextoResposta: string);
    procedure Acao_Gerar_NovoCodigo(const TextoResposta: string);
    procedure Acao_Gerar_EnviarEmail(const TextoResposta: string);
  end;

var
  frmIA: TfrmIA;

implementation

{$R *.lfm}

uses
  LConvEncoding, main;



{ Utils }

function TfrmIA.AcaoToStr(Acao: TTipoAcao): string;
begin
  case Acao of
    taGerar_PesquisarInformacao: Result := 'GERAR_PESQUISARINFORMACAO';
    taGerar_CriarTabela:         Result := 'GERAR_CRIARTABELA';
    taGerar_ModificarTabela:     Result := 'GERAR_MODIFICARTABELA';
    taGerar_ModificarCodigo:     Result := 'GERAR_MODIFICARCODIGO';
    taGerar_NovoCodigo:          Result := 'GERAR_NOVOCODIGO';
    taGerar_EnviarEmail:         Result := 'GERAR_ENVIAREMAIL';
  end;
end;

procedure TfrmIA.FazPerguntaIA;
var
  i: Integer;
  NomeAcao: string;
begin
  Screen.Cursor := crHourGlass;   // cursor "processando"
  btPerguntar.Enabled := False;   // evita clique duplo
  try
    meLog.Lines.Add(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' - Iniciando pesquisa na IA');
    PerguntaIA();

    // meResposta.Lines.Text contém a resposta da IA principal
    if GeraAcao(meResposta.Lines.Text) then   // classificador "precisa de ação?"
    begin
      if AnalisaAcao(meResposta.Lines.Text) then // preenche lstRealizar
      begin
        meLog.Lines.Add('Ações identificadas pela IA: ' + IntToStr(lstRealizar.Count));

        for i := 0 to lstRealizar.Count - 1 do
        begin
          NomeAcao := lstRealizar[i];
          meLog.Lines.Add('Executando ação: ' + NomeAcao);
          ExecutaAcao(NomeAcao, meResposta.Lines.Text);
        end;
      end;
    end;

    mePergunta.SetFocus;
  finally
    Screen.Cursor := crDefault;   // volta ao normal
    btPerguntar.Enabled := True;  // reabilita o botão
  end;
end;


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
     FazPerguntaIA();
end;


procedure TfrmIA.FormCreate(Sender: TObject);
var
  arquivo, arquivo1, arquivo2 : string;

  ac: TTipoAcao;
begin
  lstAcao := TStringList.Create;
  lstRealizar := TStringList.Create;

  // Preenche lista estática baseada no ENUM
  for ac := Low(TTipoAcao) to High(TTipoAcao) do
    lstAcao.Add(AcaoToStr(ac));

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
    FazPerguntaIA();
end;

procedure TfrmIA.PerguntaIA();
begin
  //AnalisaContinuidade
  if(not VerificaContinuidade()) then
  begin
     LimparHistorico();
  end;
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

function TfrmIA.VerificaContinuidade(): boolean;
var
  DevMsg     : WideString;
  FullPrompt : WideString;
  Pergunta   : WideString;
  Resposta   : WideString;
begin
  Result := False;

  // Obtém a pergunta atual
  if Assigned(mePergunta) then
    Pergunta := Trim(mePergunta.Text)
  else
    Pergunta := '';

  if Pergunta = '' then
  begin
    AddLog('Pergunta vazia. Nada a classificar.');
    Exit(False);
  end;

  // Garante instância e token
  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    AddLog('Token do ChatGPT não configurado em FSetMain.CHATGPT.');
    Exit(False);
  end;

  FChatGPT.TOKEN := FSetMain.CHATGPT;

  // Mensagem de sistema: define papel e regras
  DevMsg :=
    'Você é um classificador.' + LineEnding +
    'Sua função é responder apenas com "Sim" ou "Nao".' + LineEnding +
    'Analise o histórico de conversas e a pergunta atual e diga se elas têm relação direta ou apresenta ideia de continuidade ao que esta sendo tratado.' + LineEnding +
    'Responda apenas com uma palavra: Sim ou Não.' + LineEnding +
    'Sem explicações, sem pontuação, sem comentários adicionais.';
  FChatGPT.Dev := DevMsg;

  // Prompt principal
  FullPrompt :=
    '--- HISTÓRICO DE CONVERSAS ---' + LineEnding +
    meHistorico.Lines.Text + LineEnding + LineEnding +
    '--- NOVA PERGUNTA ---' + LineEnding +
    Pergunta + LineEnding +
    'A pergunta tem relação direta com o histórico acima?';

  // Log e envio
  AddLog('Enviando pergunta ao classificador de continuidade...');
  if FChatGPT.SendQuestion(FullPrompt) then
    Resposta := Trim(LowerCase(TextoLimpo(FChatGPT.Response)))
  else
    Resposta := Trim(LowerCase(TextoLimpo(FChatGPT.Response)));

  // Verifica se a resposta foi "sim"
  if (Resposta = 'sim') or (Resposta = 'yes') then
  begin
    Result := True;
    AddLog('Classificação: SIM (há continuidade)');
  end
  else
  begin
    Result := False;
    AddLog('Classificação: NÃO (sem continuidade)');
  end;

  // Atualiza campos visuais
  mePensamento.Lines.Text := Resposta;
  meMapaMemoria.Lines.Add('Classificação de continuidade: ' + Resposta);
end;

function TfrmIA.GeraAcao(const Resposta: string): boolean;
var
  DevMsg   : string;
  Prompt   : string;
  Resp     : string;
  First    : Char;
begin
  Result := False;

  // Se não tem texto, não tem ação
  if Trim(Resposta) = '' then
    Exit(False);

  // Garante instância do ChatGPT
  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  // Confere token configurado
  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit(False);
  end;

  // Mensagem de sistema (modo classificador binário)
  DevMsg :=
    'Você é um classificador binário.' + LineEnding +
    'Sua única função é responder se a orientação da IA exige a execução de uma AÇÃO .' + LineEnding +
    'Entenda como "AÇÃO do sistema" algo que precisa ser feito pelo usuario, tal como uma mudança de codigo, criar algo, ou mesmo uma pesquisa ou processo no banco de dados, ou em serviços tais como email e etc.' + LineEnding +
    'Responda **apenas** com "Sim" ou "Nao".' + LineEnding +
    'Sem explicações, sem pontuação, sem comentários adicionais.';

  // Prompt enviado ao modelo
  Prompt :=
    'Analise o TEXTO abaixo e responda se ele exige que o sistema realize alguma AÇÃO prática,' + LineEnding +
    'como por exemplo: executar um comando, chamar uma função, clicar em um botão,' + LineEnding +
    'disparar um processo, alterar um estado, gravar algo em banco de dados, pesquisar em banco , etc.' + LineEnding +
    LineEnding +
    'IMPORTANTE:' + LineEnding +
    '- Se o texto contiver códigos, comandos, exemplos de SQL, ou instruções técnicas,' + LineEnding +
    '  considere que isso exige uma ação do sistema e responda "Sim".' + LineEnding +
    LineEnding +
    'Responda apenas com "Sim" ou "Nao".' + LineEnding +
    LineEnding +
    '--- TEXTO ---' + LineEnding +
    Resposta;


  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev   := DevMsg;

  AddLog('Analisando se a resposta exige ação (GeraAcao)...');

  if FChatGPT.SendQuestion(Prompt) then
    Resp := TextoLimpo(FChatGPT.Response)
  else
    Resp := TextoLimpo(FChatGPT.Response);

  Resp := Trim(UpperCase(Resp));

  if Resp = '' then
    Exit(False);

  // Considera "Sim" qualquer resposta começando com 'S'
  First := Resp[1];
  Result := (First = 'S');
end;

function TfrmIA.IsAcaoValida(const S: string): boolean;
var
  ac: TTipoAcao;
begin
  Result := False;
  for ac := Low(TTipoAcao) to High(TTipoAcao) do
  begin
    if SameText(S, AcaoToStr(ac)) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TfrmIA.StrToAcao(const S: string; out Acao: TTipoAcao): boolean;
var
  ac: TTipoAcao;
  SUp: string;
begin
  Result := False;
  SUp := UpperCase(Trim(S));

  for ac := Low(TTipoAcao) to High(TTipoAcao) do
  begin
    if SUp = AcaoToStr(ac) then
    begin
      Acao := ac;
      Result := True;
      Exit;
    end;
  end;
end;

procedure TfrmIA.ExecutaAcao(const NomeAcao, TextoResposta: string);
var
  Acao: TTipoAcao;
begin
  if not StrToAcao(NomeAcao, Acao) then
  begin
    meLog.Lines.Add('Ação inválida ou não reconhecida: ' + NomeAcao);
    Exit;
  end;

  case Acao of
    taGerar_PesquisarInformacao:
      Acao_Gerar_PesquisarInformacao(TextoResposta);

    taGerar_CriarTabela:
      Acao_Gerar_CriarTabela(TextoResposta);

    taGerar_ModificarTabela:
      Acao_Gerar_ModificarTabela(TextoResposta);

    taGerar_ModificarCodigo:
      Acao_Gerar_ModificarCodigo(TextoResposta);

    taGerar_NovoCodigo:
      Acao_Gerar_NovoCodigo(TextoResposta);

    taGerar_EnviarEmail:
      Acao_Gerar_EnviarEmail(TextoResposta);
  end;
end;


procedure TfrmIA.Acao_Gerar_PesquisarInformacao(const TextoResposta: string);
var
  TextoRestante, TextoRestanteMinusc: WideString;
  TextoAposInicio, BlocoSQL: WideString;
  PosInicio, TamMarcadorInicio, PosFimBlocoRelativo: Integer;
  AchouAlgum: Boolean;
  tb : TTabSheet;
  syn : TSynEdit;
  item : TItem;
begin
  meLog.Lines.Add('>> [AÇÃO] GERAR_PESQUISARINFORMACAO acionada.');

  TextoRestante       := TextoResposta;
  AchouAlgum          := False;

  // Loop para tratar POSSÍVEIS VÁRIOS blocos ```sql``` na mesma resposta
  while True do
  begin
    TextoRestanteMinusc := LowerCase(TextoRestante);

    // 1) Procura o início do bloco de código - primeiro ```sql
    PosInicio := Pos('```sql', TextoRestanteMinusc);
    if PosInicio > 0 then
      TamMarcadorInicio := Length('```sql')    // 6
    else
    begin
      // Se não achar, tenta apenas ```
      PosInicio := Pos('```', TextoRestante);
      TamMarcadorInicio := Length('```');      // 3
    end;

    if PosInicio = 0 then
    begin
      // Não há mais blocos de código
      if not AchouAlgum then
        meLog.Lines.Add('Nenhum bloco ```sql``` encontrado na resposta (ou nenhum SELECT válido).');
      Break;
    end;

    // 2) Pega o texto após a abertura do bloco
    TextoAposInicio := Copy(TextoRestante, PosInicio + TamMarcadorInicio, MaxInt);

    // Se logo depois vier uma quebra de linha (#13#10, #10 ou #13), pula ela
    if (Length(TextoAposInicio) >= 2) and
       (TextoAposInicio[1] = #13) and (TextoAposInicio[2] = #10) then
      TextoAposInicio := Copy(TextoAposInicio, 3, MaxInt)
    else if (Length(TextoAposInicio) >= 1) and
            ((TextoAposInicio[1] = #10) or (TextoAposInicio[1] = #13)) then
      TextoAposInicio := Copy(TextoAposInicio, 2, MaxInt);

    // 3) Acha o fechamento ``` *DENTRO* desse trecho
    PosFimBlocoRelativo := Pos('```', TextoAposInicio);
    if PosFimBlocoRelativo = 0 then
    begin
      meLog.Lines.Add('Bloco de código encontrado sem fechamento ```.');
      Break;
    end;

    // 4) Extrai o conteúdo do bloco de código (entre início e fim)
    BlocoSQL := Trim(Copy(TextoAposInicio, 1, PosFimBlocoRelativo - 1));

    // 5) Garante que é uma consulta (SELECT)
    if Pos('SELECT', UpperCase(BlocoSQL)) > 0 then
    begin
      AchouAlgum := True;

      // 6) Abre nova aba no MNote com o SQL
      if Assigned(frmMNote) then
      begin
        if not frmMNote.FileNewSave('', BlocoSQL) then
          meLog.Lines.Add('Falha ao criar nova aba no MNote com a consulta SQL.')
        else
          meLog.Lines.Add('Nova aba criada no MNote com consulta SELECT.');
          tb := pgMain.ActivePage;
          item := TItem(tb.Tag);
          item.
          syn := item.syn;
      end
      else
        meLog.Lines.Add('frmMNote não está disponível para abrir a consulta.');
    end
    else
      meLog.Lines.Add('Bloco de código encontrado, mas não contém SELECT (ignorado).');

    // 7) Avança o TextoRestante para depois do bloco atual
    //    Pega o resto após o fechamento ```
    TextoRestante := Copy(TextoAposInicio,
                          PosFimBlocoRelativo + Length('```'),
                          MaxInt);

    // Se sobrar pouco texto, encerra o loop
    if Trim(TextoRestante) = '' then
      Break;
  end;
end;





procedure TfrmIA.Acao_Gerar_CriarTabela(const TextoResposta: string);
begin
  // TODO: Implementar geração de SQL para criar tabela, etc.
  meLog.Lines.Add('>> [AÇÃO] GERAR_CRIARTABELA acionada:'+TextoResposta);
end;

procedure TfrmIA.Acao_Gerar_ModificarTabela(const TextoResposta: string);
begin
   // TODO: Implementar alteração de estrutura de tabela
  meLog.Lines.Add('>> [AÇÃO] GERAR_MODIFICARTABELA acionada:'+TextoResposta);
end;

procedure TfrmIA.Acao_Gerar_ModificarCodigo(const TextoResposta: string);
begin
  // TODO: Implementar modificação de código existente
  meLog.Lines.Add('>> [AÇÃO] GERAR_MODIFICARCODIGO acionada:'+TextoResposta);
end;

procedure TfrmIA.Acao_Gerar_NovoCodigo(const TextoResposta: string);
begin
   // TODO: Implementar criação de novo código fonte
  meLog.Lines.Add('>> [AÇÃO] GERAR_NOVOCODIGO acionada:'+TextoResposta);
end;

procedure TfrmIA.Acao_Gerar_EnviarEmail(const TextoResposta: string);
begin
  // TODO: Implementar envio de e-mail com base na resposta
  meLog.Lines.Add('>> [AÇÃO] GERAR_ENVIAREMAIL acionada:'+TextoResposta);
end;


function TfrmIA.AnalisaAcao(const Resposta: string): boolean;
var
  DevMsg   : string;
  Prompt   : string;
  Resp     : string;
  JsonData : TJSONData;
  Obj      : TJSONObject;
  Arr      : TJSONArray;
  i        : Integer;
  SAcao    : string;
  ac       : TTipoAcao;
begin
  Result := False;
  lstRealizar.Clear;

  // Se não tem texto, não tem ação
  if Trim(Resposta) = '' then
    Exit(False);

  // Garante instância do ChatGPT
  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  // Confere token configurado
  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit(False);
  end;

  // Mensagem de sistema: EXTRATOR DE AÇÕES EM JSON
  DevMsg :=
    'Você é um EXTRATOR DE AÇÕES.' + LineEnding +
    'Sua função é analisar um texto e identificar quais AÇÕES o sistema deve realizar.' + LineEnding +
    'Você DEVE responder SEMPRE em JSON VÁLIDO, no formato exato:' + LineEnding +
    '{"acoes":["' + TIPO_ACAO_NOME[taGerar_PesquisarInformacao] + '","' +
                  TIPO_ACAO_NOME[taGerar_CriarTabela] + '"]}' + LineEnding +
    'Se não houver nenhuma ação, responda exatamente: {"acoes":[]}' + LineEnding +
    LineEnding +
    'NUNCA escreva explicações, comentários, texto fora do JSON.' + LineEnding +
    'As ações possíveis são APENAS estas (use exatamente estes valores):' + LineEnding;

  // Acrescenta a lista de ações com descrições
  for ac := Low(TTipoAcao) to High(TTipoAcao) do
    DevMsg := DevMsg +
      '- ' + TIPO_ACAO_NOME[ac] + ' = ' + TIPO_ACAO_DESCRICAO[ac] + LineEnding;

  // Prompt enviado ao modelo
  Prompt :=
    'Analise o TEXTO abaixo e identifique quais AÇÕES o sistema deve realizar.' + LineEnding +
    'Responda SOMENTE com um JSON no formato {"acoes":[...]} contendo zero ou mais ações.' + LineEnding +
    'Use apenas os valores permitidos listados na mensagem do sistema.' + LineEnding +
    LineEnding +
    '--- TEXTO ---' + LineEnding +
    Resposta;

  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev   := DevMsg;

  AddLog('Analisando ações em JSON (AnalisaAcao)...');

  if FChatGPT.SendQuestion(Prompt) then
    Resp := Trim(TextoLimpo(FChatGPT.Response))
  else
    Resp := Trim(TextoLimpo(FChatGPT.Response));

  if Resp = '' then
    Exit(False);

  // Tenta parsear o JSON
  try
    JsonData := GetJSON(Resp);
  except
    on E: Exception do
    begin
      AddLog('Erro ao parsear JSON de ações: ' + E.Message);
      Exit(False);
    end;
  end;

  try
    if not (JsonData is TJSONObject) then
      Exit(False);

    Obj := TJSONObject(JsonData);

    // Tenta pegar o array "acoes"
    if not Obj.Find('acoes', JsonData) then
      Exit(False);

    if not (JsonData is TJSONArray) then
      Exit(False);

    Arr := TJSONArray(JsonData);

    // Varre o array de ações
    for i := 0 to Arr.Count - 1 do
    begin
      SAcao := Trim(UpperCase(Arr.Strings[i]));

      // Garante que só entra ação válida
      if IsAcaoValida(SAcao) then
        lstRealizar.Add(SAcao);
    end;

    Result := (lstRealizar.Count > 0);
  finally
    JsonData.Free;
  end;
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
    'A pergunta abaixo envolve ARQUIVOS/PASTAS/Projeto (abrir/salvar arquivo, listar diretórios, '+
    'caminhos, upload/download, leitura/escrita, extensão, nome de arquivo, e informações sobre um projeto. Em suma informações que envolvem dados que devem estar armazenados porem voce não tem acesso.)?' + LineEnding +
    'Pergunta: "' + Pergunta + '"' + LineEnding +
    'Responda apenas com "Sim" ou "Nao".';

  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev   := DevMsg;

  AddLog('Classificando se a pergunta envolve arquivos/pastas...');
  if FChatGPT.SendQuestion(Prompt) then
  begin
    Resp := Trim(FChatGPT.Response);
    AddLog('SIM');
  end
  else
  begin
    Resp := Trim(FChatGPT.Response);
    AddLog('Não');
  end;

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


