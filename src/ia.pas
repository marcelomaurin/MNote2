unit IA;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Buttons, setmain, folders, mquery2, fpjson, jsonparser,
  item, SynEditTypes, SynEdit, DateUtils, mnote_ai_service,
  mnote_memory_map_panel;

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
    btLimpaHist: TSpeedButton;
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
    Splitter1: TSplitter;
    TabSheet1: TTabSheet;
    tsMapaMemoria: TTabSheet;
    tsPensamento: TTabSheet;
    tsLog: TTabSheet;
    lblTipoIA: TLabel;
    cbTipoIA: TComboBox;
    lblModeloIA: TLabel;
    cbModeloIA: TComboBox;
    procedure btLimpaHistClick(Sender: TObject);
    procedure btPerguntarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure meHistoricoChange(Sender: TObject);
    procedure meMapaMemoriaChange(Sender: TObject);
    procedure mePensamentoChange(Sender: TObject);
    procedure mePerguntaKeyPress(Sender: TObject; var Key: char);
    procedure cbTipoIAChange(Sender: TObject);
    procedure cbModeloIAChange(Sender: TObject);
  private
    lstAcao: TStringList;
    lstRealizar: TStringList;
    FMemoryMapPanel: TMNoteMemoryMapPanel;

    function EnsureRIAPath: string;
    procedure AddLog(const S: string);
    function TextoLimpo(const S: string): string;
    function ExecutarPerguntaIA(const DevMsg, Prompt: string; out Resposta: string): Boolean; overload;
    function ExecutarPerguntaIA(const DevMsg, Prompt: string; out Resposta: WideString): Boolean; overload;
    // ===== cache RIA =====
    function RIAFileName(const ANome: string): string;
    function ArquivoEhDoDia(const AFileName: string): Boolean;
    function CarregaRIASeValido(const AFileName: widestring; out ATexto: widestring): Boolean;
    procedure SalvaRIA(const AFileName, ATexto: string);
  public
    procedure PerguntaIA();
    procedure CarregarConfiguracoes();
    procedure AnalisaBanco();
    procedure AnalisaFolder();
    procedure MapeiaPensamento();
    procedure RespondePergunta();
    procedure LimparHistorico();
    function QuestoesFolder(): boolean;
    function QuestoesCaminho(): boolean;
    function QuestoesBanco(): boolean;
    procedure AnalisaRespostaFolder();
    function BancoConectado(): boolean;
    function CriaDicionarioPost(): string;
    function CriaDicionarioSQLite(): string;
    function VerificaContinuidade(): boolean;
    function GeraAcao(const Resposta: string): boolean;
    function AnalisaAcao(const Resposta: string): boolean;
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
  Screen.Cursor := crHourGlass;
  btPerguntar.Enabled := False;
  try
    meLog.Lines.Add(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' - Iniciando pesquisa na IA');
    PerguntaIA();

    if GeraAcao(meResposta.Lines.Text) then
    begin
      if AnalisaAcao(meResposta.Lines.Text) then
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
    Screen.Cursor := crDefault;
    btPerguntar.Enabled := True;
  end;
end;

procedure TfrmIA.AddLog(const S: string);
begin
  meLog.Lines.Add(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' - ' + S);
end;

function TfrmIA.TextoLimpo(const S: string): string;
begin
  Result := UTF8Encode(S);
end;

function TfrmIA.ExecutarPerguntaIA(const DevMsg, Prompt: string; out Resposta: string): Boolean;
var
  WResp: WideString;
begin
  Result := ExecutarPerguntaIA(DevMsg, Prompt, WResp);
  Resposta := WResp;
end;

function TfrmIA.ExecutarPerguntaIA(const DevMsg, Prompt: string; out Resposta: WideString): Boolean;
var
  LResposta: string;
begin
  Resposta := '';
  Result := MNoteAI.SendQuestion(Prompt, DevMsg, LResposta);
  if Result then
    Resposta := LResposta
  else
    Resposta := MNoteAI.LastError + LineEnding + MNoteAI.LastJSON;
end;


function TfrmIA.RIAFileName(const ANome: string): string;
begin
  Result := IncludeTrailingPathDelimiter(FSetMain.Defaultfolder) + ANome;
end;

function TfrmIA.ArquivoEhDoDia(const AFileName: string): Boolean;
var
  Dt: TDateTime;
begin
  Result := False;
  if not FileExists(AFileName) then Exit;
  if not FileAge(AFileName, Dt) then Exit;
  Result := SameDate(Dt, Now);
end;

function TfrmIA.CarregaRIASeValido(const AFileName: widestring; out ATexto: widestring): Boolean;
var
  SL: TStringList;
begin
  Result := False;
  ATexto := '';

  if frmFolders.flagMudanca then Exit;
  if not ArquivoEhDoDia(AFileName) then Exit;

  SL := TStringList.Create;
  try
    SL.LoadFromFile(AFileName);
    ATexto := SL.Text;
    Result := True;
  finally
    SL.Free;
  end;
end;

procedure TfrmIA.SalvaRIA(const AFileName, ATexto: string);
var
  SL: TStringList;
begin
  ForceDirectories(ExtractFileDir(AFileName));
  SL := TStringList.Create;
  try
    SL.Text := ATexto;
    SL.SaveToFile(AFileName);
  finally
    SL.Free;
  end;
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

procedure TfrmIA.CarregarConfiguracoes();
begin
  // Inicializa e popula os combo boxes da IA
  cbTipoIA.Items.Clear;
  cbTipoIA.Items.Add('OpenAI');      // 0
  cbTipoIA.Items.Add('OpenRouter');  // 1
  cbTipoIA.Items.Add('Cerebras');    // 2
  cbTipoIA.Items.Add('Local');       // 3 - llama.cpp
  cbTipoIA.Items.Add('Gemini');      // 4

  if (FSetMain.Provider >= 0) and (FSetMain.Provider < cbTipoIA.Items.Count) then
    cbTipoIA.ItemIndex := FSetMain.Provider
  else
    cbTipoIA.ItemIndex := 0;

  cbTipoIAChange(nil);
end;

procedure TfrmIA.FormCreate(Sender: TObject);
var
  arquivo, arquivo1, arquivo2: string;
  ac: TTipoAcao;
begin
  lstAcao := TStringList.Create;
  lstRealizar := TStringList.Create;

  for ac := Low(TTipoAcao) to High(TTipoAcao) do
    lstAcao.Add(AcaoToStr(ac));

  // garante que a pasta exista ao entrar
  EnsureRIAPath;

  arquivo  := RIAFileName('HISTORICO.RIA');
  arquivo1 := RIAFileName('mapamemoria.RIA');
  arquivo2 := RIAFileName('pensamento.RIA');

  if FileExists(arquivo) then
    meHistorico.Lines.LoadFromFile(arquivo);
  if FileExists(arquivo1) then
    meMapaMemoria.Lines.LoadFromFile(arquivo1);
  if FileExists(arquivo2) then
    mePensamento.Lines.LoadFromFile(arquivo2);

  meMapaMemoria.Visible := False;
  FMemoryMapPanel := TMNoteMemoryMapPanel.Create(Self);
  FMemoryMapPanel.Parent := tsMapaMemoria;
  FMemoryMapPanel.SetMemoryMap(MNoteAI.SessionMemory);

  CarregarConfiguracoes();
end;

procedure TfrmIA.cbTipoIAChange(Sender: TObject);
begin
  if cbTipoIA.ItemIndex >= 0 then
  begin
    FSetMain.Provider := cbTipoIA.ItemIndex;
    FSetMain.SalvaContexto(False);
  end;

  cbModeloIA.Items.Clear;
  case FSetMain.Provider of
    0: // OpenAI
      begin
        cbModeloIA.Items.Add('gpt-4o-mini');
        cbModeloIA.Items.Add('gpt-4o');
        cbModeloIA.Items.Add('gpt-4-turbo');
        cbModeloIA.Items.Add('gpt-4');
        cbModeloIA.Items.Add('gpt-3.5-turbo');
        cbModeloIA.Items.Add('o1-mini');
        cbModeloIA.Text := FSetMain.ModelOpenAI;
      end;
    1: // OpenRouter
      begin
        cbModeloIA.Items.Add('google/gemma-2-9b-it:free');
        cbModeloIA.Items.Add('meta-llama/llama-3-8b-instruct:free');
        cbModeloIA.Items.Add('mistralai/mistral-7b-instruct:free');
        cbModeloIA.Items.Add('microsoft/phi-3-medium-128k-instruct:free');
        cbModeloIA.Items.Add('deepseek/deepseek-chat');
        cbModeloIA.Text := FSetMain.ModelOpenRouter;
      end;
    2: // Cerebras
      begin
        cbModeloIA.Items.Add('llama3.1-8b');
        cbModeloIA.Items.Add('llama3.1-70b');
        cbModeloIA.Items.Add('llama-3.3-70b');
        cbModeloIA.Text := FSetMain.ModelCerebras;
      end;
    3: // Local
      begin
        cbModeloIA.Items.Add('llama3.2:3b');
        cbModeloIA.Items.Add('mistral');
        cbModeloIA.Items.Add('gemma2');
        cbModeloIA.Items.Add('deepseek-r1:1.5b');
        cbModeloIA.Items.Add('deepseek-r1:8b');
        cbModeloIA.Items.Add('qwen2.5:14b');
        cbModeloIA.Text := FSetMain.ModelLocal;
      end;
    4: // Gemini
      begin
        cbModeloIA.Items.Add('gemini-1.5-flash');
        cbModeloIA.Items.Add('gemini-1.5-pro');
        cbModeloIA.Items.Add('gemini-2.0-flash');
        cbModeloIA.Items.Add('gemini-2.5-flash');
        cbModeloIA.Items.Add('gemini-3.5-flash');
        cbModeloIA.Text := FSetMain.ModelGemini;
      end;
  else
    cbModeloIA.Text := '';
  end;
end;

procedure TfrmIA.cbModeloIAChange(Sender: TObject);
begin
  case FSetMain.Provider of
    0: FSetMain.ModelOpenAI := cbModeloIA.Text;
    1: FSetMain.ModelOpenRouter := cbModeloIA.Text;
    2: FSetMain.ModelCerebras := cbModeloIA.Text;
    3: FSetMain.ModelLocal := cbModeloIA.Text;
    4: FSetMain.ModelGemini := cbModeloIA.Text;
  end;
  FSetMain.SalvaContexto(False);
end;

procedure TfrmIA.meHistoricoChange(Sender: TObject);
var
  arquivo: string;
begin
  arquivo := RIAFileName('HISTORICO.RIA');
  try
    EnsureRIAPath;
    meHistorico.Lines.SaveToFile(arquivo);
  except
  end;
end;

procedure TfrmIA.meMapaMemoriaChange(Sender: TObject);
var
  arquivo: string;
begin
  arquivo := RIAFileName('mapamemoria.RIA');
  try
    meMapaMemoria.Lines.SaveToFile(arquivo);
  except
  end;
end;

procedure TfrmIA.mePensamentoChange(Sender: TObject);
var
  arquivo: string;
begin
  arquivo := RIAFileName('pensamento.RIA');
  try
    mePensamento.Lines.SaveToFile(arquivo);
  except
  end;
end;

procedure TfrmIA.mePerguntaKeyPress(Sender: TObject; var Key: char);
begin
  if (Key = #13) then
    FazPerguntaIA();
end;

function TfrmIA.EnsureRIAPath: string;
begin
  Result := Trim(FSetMain.Defaultfolder);

  if Result = '' then
    Result := ExtractFilePath(Application.ExeName);

  Result := IncludeTrailingPathDelimiter(Result);

  if not DirectoryExists(Result) then
    ForceDirectories(Result);
end;


procedure TfrmIA.PerguntaIA();
begin
  if not VerificaContinuidade() then
    LimparHistorico()
  else
    frmFolders.flagMudanca := false;

  AnalisaBanco();
  AnalisaFolder();
  MapeiaPensamento();
  RespondePergunta();
end;

function TfrmIA.CriaDicionarioPost(): string;
var
  baseDir, fileName: string;
begin
  Result := '';

  if frmmquery2 = nil then Exit;
  if not frmmquery2.zconpost.Connected then Exit;

  {$IFDEF WINDOWS}
  baseDir := GetAppConfigDir(False);
  {$ELSE}
  baseDir := GetUserDir;
  {$ENDIF}

  ForceDirectories(baseDir);
  fileName := IncludeTrailingPathDelimiter(baseDir) + 'dicionario.sql';

  Result := frmmquery2.CriaDicionarioPost(fileName);
end;

function TfrmIA.CriaDicionarioSQLite(): string;
var
  baseDir, fileName: string;
begin
  Result := '';

  if frmmquery2 = nil then Exit;
  if not frmmquery2.zconsqlite.Connected then Exit;

  {$IFDEF WINDOWS}
  baseDir := GetAppConfigDir(False);
  {$ELSE}
  baseDir := GetUserDir;
  {$ENDIF}

  ForceDirectories(baseDir);
  fileName := IncludeTrailingPathDelimiter(baseDir) + 'dicionario_sqlite.sql';

  Result := frmmquery2.CriaDicionarioSQLite(fileName);
end;

function TfrmIA.VerificaContinuidade(): boolean;
var
  DevMsg     : WideString;
  FullPrompt : WideString;
  Pergunta   : WideString;
  Resposta   : WideString;
  CacheFile  : string;
begin
  Result := False;

  if Assigned(mePergunta) then
    Pergunta := Trim(mePergunta.Text)
  else
    Pergunta := '';

  if Pergunta = '' then
  begin
    AddLog('Pergunta vazia. Nada a classificar.');
    Exit(False);
  end;

  CacheFile := RIAFileName('continuidade.RIA');
  if CarregaRIASeValido(CacheFile, Resposta) then
  begin
    AddLog('VerificaContinuidade: reutilizando cache do dia.');
  end
  else
  begin
    DevMsg :=
      'Você é um classificador.' + LineEnding +
      'Sua função é responder apenas com "Sim" ou "Nao".' + LineEnding +
      'Analise o histórico de conversas e a pergunta atual e diga se elas têm relação direta ou apresenta ideia de continuidade ao que esta sendo tratado.' + LineEnding +
      'Responda apenas com uma palavra: Sim ou Não.' + LineEnding +
      'Sem explicações, sem pontuação, sem comentários adicionais.';

    FullPrompt :=
      '--- HISTÓRICO DE CONVERSAS ---' + LineEnding +
      meHistorico.Lines.Text + LineEnding + LineEnding +
      '--- NOVA PERGUNTA ---' + LineEnding +
      Pergunta + LineEnding +
      'A pergunta tem relação direta com o histórico acima?';

    AddLog('Enviando pergunta ao classificador de continuidade...');

    if ExecutarPerguntaIA(DevMsg, FullPrompt, Resposta) then
      Resposta := Trim(LowerCase(TextoLimpo(Resposta)))
    else
      Resposta := Trim(LowerCase(TextoLimpo(Resposta)));

    SalvaRIA(CacheFile, Resposta);
  end;

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

  if Trim(Resposta) = '' then
    Exit(False);

  DevMsg :=
    'Você é um classificador binário.' + LineEnding +
    'Sua única função é responder se a orientação da IA exige a execução de uma AÇÃO .' + LineEnding +
    'Entenda como "AÇÃO do sistema" algo que precisa ser feito pelo usuario, tal como uma mudança de codigo, criar algo, ou mesmo uma pesquisa ou processo no banco de dados, ou em serviços tais como email and etc.' + LineEnding +
    'Responda **apenas** com "Sim" ou "Nao".' + LineEnding +
    'Sem explicações, sem pontuação, sem comentários adicionais.';

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

  AddLog('Analisando se a resposta exige ação (GeraAcao)...');

  if ExecutarPerguntaIA(DevMsg, Prompt, Resp) then
    Resp := TextoLimpo(Resp)
  else
    Resp := TextoLimpo(Resp);

  Resp := Trim(UpperCase(Resp));

  if Resp = '' then
    Exit(False);

  First := Resp[1];
  Result := (First = 'S');
end;

function TfrmIA.IsAcaoValida(const S: string): boolean;
var
  ac: TTipoAcao;
begin
  Result := False;
  for ac := Low(TTipoAcao) to High(TTipoAcao) do
    if SameText(S, AcaoToStr(ac)) then
      Exit(True);
end;

function TfrmIA.StrToAcao(const S: string; out Acao: TTipoAcao): boolean;
var
  ac: TTipoAcao;
  SUp: string;
begin
  Result := False;
  SUp := UpperCase(Trim(S));

  for ac := Low(TTipoAcao) to High(TTipoAcao) do
    if SUp = AcaoToStr(ac) then
    begin
      Acao := ac;
      Exit(True);
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
    taGerar_PesquisarInformacao: Acao_Gerar_PesquisarInformacao(TextoResposta);
    taGerar_CriarTabela:         Acao_Gerar_CriarTabela(TextoResposta);
    taGerar_ModificarTabela:     Acao_Gerar_ModificarTabela(TextoResposta);
    taGerar_ModificarCodigo:     Acao_Gerar_ModificarCodigo(TextoResposta);
    taGerar_NovoCodigo:          Acao_Gerar_NovoCodigo(TextoResposta);
    taGerar_EnviarEmail:         Acao_Gerar_EnviarEmail(TextoResposta);
  end;
end;

procedure TfrmIA.Acao_Gerar_PesquisarInformacao(const TextoResposta: string);
var
  TextoRestante, TextoRestanteMinusc: WideString;
  TextoAposInicio, BlocoSQL: WideString;
  PosInicio, TamMarcadorInicio, PosFimBlocoRelativo: Integer;
  AchouAlgum: Boolean;
  tb: TTabSheet;
  syn: TSynEdit;
  item: TItem;
begin
  meLog.Lines.Add('>> [AÇÃO] GERAR_PESQUISARINFORMACAO acionada.');

  TextoRestante := TextoResposta;
  AchouAlgum    := False;

  while True do
  begin
    TextoRestanteMinusc := LowerCase(TextoRestante);

    PosInicio := Pos('```sql', TextoRestanteMinusc);
    if PosInicio > 0 then
      TamMarcadorInicio := Length('```sql')
    else
    begin
      PosInicio := Pos('```', TextoRestante);
      TamMarcadorInicio := Length('```');
    end;

    if PosInicio = 0 then
    begin
      if not AchouAlgum then
        meLog.Lines.Add('Nenhum bloco ```sql``` encontrado na resposta (ou nenhum SELECT válido).');
      Break;
    end;

    TextoAposInicio := Copy(TextoRestante, PosInicio + TamMarcadorInicio, MaxInt);

    if (Length(TextoAposInicio) >= 2) and
       (TextoAposInicio[1] = #13) and (TextoAposInicio[2] = #10) then
      TextoAposInicio := Copy(TextoAposInicio, 3, MaxInt)
    else if (Length(TextoAposInicio) >= 1) and
            ((TextoAposInicio[1] = #10) or (TextoAposInicio[1] = #13)) then
      TextoAposInicio := Copy(TextoAposInicio, 2, MaxInt);

    PosFimBlocoRelativo := Pos('```', TextoAposInicio);
    if PosFimBlocoRelativo = 0 then
    begin
      meLog.Lines.Add('Bloco de código encontrado sem fechamento ```.');
      Break;
    end;

    BlocoSQL := Trim(Copy(TextoAposInicio, 1, PosFimBlocoRelativo - 1));

    if Pos('SELECT', UpperCase(BlocoSQL)) > 0 then
    begin
      AchouAlgum := True;

      if Assigned(frmMNote) then
      begin
        if not frmMNote.FileNewSave('', BlocoSQL) then
          meLog.Lines.Add('Falha ao criar nova aba no MNote com a consulta SQL.')
        else
        begin
          meLog.Lines.Add('Nova aba criada no MNote com consulta SELECT.');
          tb   := frmMNote.pgMain.ActivePage;
          item := TItem(tb.Tag);
          item.ItemType := ti_SQL;
          syn  := item.syn;
        end;
      end
      else
        meLog.Lines.Add('frmMNote não está disponível para abrir a consulta.');
    end
    else
      meLog.Lines.Add('Bloco de código encontrado, mas não contém SELECT (ignorado).');

    TextoRestante := Copy(TextoAposInicio,
                          PosFimBlocoRelativo + Length('```'),
                          MaxInt);

    if Trim(TextoRestante) = '' then
      Break;
  end;
end;

procedure TfrmIA.Acao_Gerar_CriarTabela(const TextoResposta: string);
begin
  meLog.Lines.Add('>> [AÇÃO] GERAR_CRIARTABELA acionada:' + TextoResposta);
end;

procedure TfrmIA.Acao_Gerar_ModificarTabela(const TextoResposta: string);
begin
  meLog.Lines.Add('>> [AÇÃO] GERAR_MODIFICARTABELA acionada:' + TextoResposta);
end;

procedure TfrmIA.Acao_Gerar_ModificarCodigo(const TextoResposta: string);
begin
  meLog.Lines.Add('>> [AÇÃO] GERAR_MODIFICARCODIGO acionada:' + TextoResposta);
end;

procedure TfrmIA.Acao_Gerar_NovoCodigo(const TextoResposta: string);
begin
  meLog.Lines.Add('>> [AÇÃO] GERAR_NOVOCODIGO acionada:' + TextoResposta);
end;

procedure TfrmIA.Acao_Gerar_EnviarEmail(const TextoResposta: string);
begin
  meLog.Lines.Add('>> [AÇÃO] GERAR_ENVIAREMAIL acionada:' + TextoResposta);
end;

function TfrmIA.AnalisaAcao(const Resposta: string): boolean;
var
  DevMsg   : string;
  Prompt   : string;
  Resp     : string;
  JsonRaiz : TJSONData;
  JsonAcoes: TJSONData;
  Obj      : TJSONObject;
  Arr      : TJSONArray;
  i        : Integer;
  SAcao    : string;
  ac       : TTipoAcao;
begin
  Result := False;
  lstRealizar.Clear;

  if Trim(Resposta) = '' then
    Exit(False);

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

  for ac := Low(TTipoAcao) to High(TTipoAcao) do
    DevMsg := DevMsg +
      '- ' + TIPO_ACAO_NOME[ac] + ' = ' + TIPO_ACAO_DESCRICAO[ac] + LineEnding;

  Prompt :=
    'Analise o TEXTO abaixo e identifique quais AÇÕES o sistema deve realizar.' + LineEnding +
    'Responda SOMENTE com um JSON no formato {"acoes":[...]} contendo zero ou mais ações.' + LineEnding +
    'Use apenas os valores permitidos listados na mensagem do sistema.' + LineEnding +
    LineEnding +
    '--- TEXTO ---' + LineEnding +
    Resposta;

  AddLog('Analisando ações em JSON (AnalisaAcao)...');

  if ExecutarPerguntaIA(DevMsg, Prompt, Resp) then
    Resp := Trim(TextoLimpo(Resp))
  else
    Resp := Trim(TextoLimpo(Resp));

  if Resp = '' then
    Exit(False);

  JsonRaiz := nil;
  try
    JsonRaiz := GetJSON(Resp);

    if not (JsonRaiz is TJSONObject) then
      Exit(False);

    Obj := TJSONObject(JsonRaiz);

    if not Obj.Find('acoes', JsonAcoes) then
      Exit(False);

    if not (JsonAcoes is TJSONArray) then
      Exit(False);

    Arr := TJSONArray(JsonAcoes);

    for i := 0 to Arr.Count - 1 do
    begin
      SAcao := Trim(UpperCase(Arr.Strings[i]));
      if IsAcaoValida(SAcao) then
        lstRealizar.Add(SAcao);
    end;

    Result := (lstRealizar.Count > 0);
  except
    on E: Exception do
    begin
      AddLog('Erro ao parsear JSON de ações: ' + E.Message);
      Result := False;
    end;
  end;

  if Assigned(JsonRaiz) then
    JsonRaiz.Free;
end;

procedure TfrmIA.AnalisaBanco();
var
  dicSqlite: string;
begin
  if QuestoesBanco() then
  begin
    if BancoConectado then
    begin
      if (frmmquery2.zconpost.Connected) or
         (frmmquery2.zconmysql.Connected) or
         (frmmquery2.zconsqlite.Connected) then
      begin
        if frmmquery2.zconpost.Connected then
          meMapaMemoria.Lines.Add(CriaDicionarioPost());

        if frmmquery2.zconmysql.Connected then
        begin
        end;

        if frmmquery2.zconsqlite.Connected then
        begin
          dicSqlite := CriaDicionarioSQLite();
          if Trim(dicSqlite) <> '' then
          begin
            meMapaMemoria.Lines.Add('--[DICIONARIO SQLITE]------------------------------');
            meMapaMemoria.Lines.Add(dicSqlite);
          end;
        end;
      end;
    end
    else
      meMapaMemoria.Lines.Add('Avisa o usuario que é necessário conectar no banco de dados para fazer analises de dados.');
  end;
end;

function TfrmIA.QuestoesCaminho(): boolean;
var
  Pergunta, DevMsg, Prompt, Resp: string;
  First: Char;
begin
  Result := False;

  Pergunta := Trim(mePergunta.Text);
  if Pergunta = '' then Exit;

  DevMsg :=
    'Você é um classificador. Responda apenas com "Sim" ou "Nao".' + LineEnding +
    'Sem explicações, sem justificativas e sem pontuação.' + LineEnding +
    'Voce tem acesso a diversas informações que serão passadas no momento apropriado, então considere que tem acesso a informações' + LineEnding +
    'Regras:' + LineEnding +
    '1) Se a pergunta for genérica (ex: "listar arquivos da pasta atual"), responda "Sim".' + LineEnding +
    '2) Se a pergunta exigir um caminho, nome de arquivo ou pasta específica que NÃO esteja contido no caminho, responda "Nao".' + LineEnding +
    '3) Se a árvore fornecer potencialmente o necessário, mesmo sem dados completos, responda "Sim".' + LineEnding +
    'Seu objetivo é determinar se O CAMINHO PODE conter o necessário — não se contém ou não.';

  Prompt :=
    'Vou te passar duas coisas:' + LineEnding +
    '1) A pergunta do usuário.' + LineEnding +
    '2) A árvore de pastas/projeto disponível.' + LineEnding +
    LineEnding +
    'Com base APENAS no caminho, determine:' + LineEnding +
    'É possível atender à solicitação feita na pergunta?' + LineEnding +
    'Responda somente com "Sim" ou "Nao".' + LineEnding +
    LineEnding +
    'Pergunta: "' + Pergunta + '"' + LineEnding +
    'Árvore disponível:' + LineEnding +
    FSetMain.Defaultfolder + LineEnding +
    meLog.Lines.Text + LineEnding +
    'Responda apenas com "Sim" ou "Nao".';

  AddLog('Classificando se a árvore tem informações suficientes...');

  if ExecutarPerguntaIA(DevMsg, Prompt, Resp) then
    Resp := LowerCase(Trim(Resp))
  else
    Resp := LowerCase(Trim(Resp));

  if Resp <> '' then
  begin
    First := LowerCase(Resp[1]);
    if First = 's' then
      Result := True
    else if First = 'n' then
      Result := False;
  end;

  AddLog(Format('QuestoesCaminho => Resp="%s" | Result=%s',
    [Resp, BoolToStr(Result, True)]));
end;

procedure TfrmIA.AnalisaFolder();
begin
  if QuestoesFolder() then
  begin
    frmFolders.AnalisaProjeto();
    if QuestoesCaminho() then
    begin
      meMapaMemoria.Lines.Add('--[FOLDER/PROJETO]------------------------------');
      meMapaMemoria.Lines.Add(frmFolders.AnalisaFolderIA(meHistorico.Text + ' ' + mePergunta.Lines.Text));
      meMapaMemoria.Lines.Add(frmFolders.meLog.Lines.Text);

      AnalisaRespostaFolder();
      meMapaMemoria.Lines.Add('');
    end;
  end;
end;

procedure TfrmIA.MapeiaPensamento();
var
  DevMsg, FullPrompt, Pergunta, Resposta: WideString;
  CacheFile: string;
begin
  Pergunta := Trim(mePergunta.Text);

  CacheFile := RIAFileName('pensamento_gerado.RIA');
  if CarregaRIASeValido(CacheFile, Resposta) then
  begin
    AddLog('MapeiaPensamento: reutilizando cache do dia.');
  end
  else
  begin
    DevMsg :=
      'Você é um analisador de dados e sua missão é montar um mapa de Pensamento coerente com a pergunta.' + LineEnding +
      'O histórico que será enviado representa as interações anteriores com o usuário,' +
      ' e deve ser considerado como base de contexto e aprendizado para manter a coerência.' + LineEnding + LineEnding +
      'Siga as regras:' + LineEnding +
      '1) Crie um Mapa de pensamento coerente com que foi solicitado e embasado na conversa histórica.' + LineEnding +
      '2) Use o histórico como base para lembrar do contexto da conversa.' + LineEnding +
      '3) Trate a pergunta atual como o ponto principal a ser respondido.' + LineEnding +
      '4) Se for código, retorne sempre o código completo e formatado.' + LineEnding +
      '5) Se não houver contexto suficiente, peça mais detalhes.';

    FullPrompt :=
      '--- CONTEXTO HISTÓRICO ---' + LineEnding +
      'Abaixo está o histórico de toda a conversa até o momento. Use-o apenas para entender o contexto:' + LineEnding + LineEnding +
      meHistorico.Lines.Text + LineEnding + LineEnding +
      '--- NOVA PERGUNTA ---' + LineEnding +
      'A seguir está a nova pergunta feita pelo usuário, que deve ser respondida considerando o histórico acima:' + LineEnding +
      Pergunta + LineEnding + LineEnding +
      '--- MAPA DE MEMÓRIA ---' + LineEnding +
      meMapaMemoria.Lines.Text + LineEnding + LineEnding +
      '--- PENSAMENTO (INSTRUÇÕES INTERNAS) ---' + LineEnding +
      mePensamento.Lines.Text;

    AddLog('MapeiaPensamento: enviando contexto para gerar mapa de pensamento...');
    if ExecutarPerguntaIA(DevMsg, FullPrompt, Resposta) then
      Resposta := TextoLimpo(Resposta)
    else
      Resposta := TextoLimpo(Resposta);

    SalvaRIA(CacheFile, Resposta);
  end;

  if Trim(Resposta) <> '' then
  begin
    mePensamento.Lines.Text := Resposta;
    meMapaMemoria.Lines.Add('--- [PENSAMENTO/IA] ---');
    meMapaMemoria.Lines.Add(Resposta);
  end;
end;

procedure TfrmIA.RespondePergunta();
var
  Pergunta, DevMsg, FullPrompt, Resposta: widestring;
  CacheFile: widestring;
begin
  Pergunta := Trim(mePergunta.Text);
  if Pergunta = '' then
  begin
    AddLog('Pergunta vazia. Nada a enviar.');
    Exit;
  end;

  CacheFile := RIAFileName('resposta_final.RIA');
  if CarregaRIASeValido(CacheFile, Resposta) then
  begin
    AddLog('RespondePergunta: reutilizando cache do dia.');
  end
  else
  begin
    DevMsg :=
      'Você é um assistente técnico e está participando de uma conversa contínua.' + LineEnding +
      'O histórico que será enviado representa as interações anteriores com o usuário,' +
      ' e deve ser considerado como base de contexto e aprendizado para manter a coerência.' + LineEnding + LineEnding +
      'Siga as regras:' + LineEnding +
      '1) Responda com clareza e objetividade.' + LineEnding +
      '2) Use o histórico como base para lembrar do contexto da conversa.' + LineEnding +
      '3) Trate a pergunta atual como o ponto principal a ser respondido.' + LineEnding +
      '4) Se for código, retorne sempre o código completo e formatado.' + LineEnding +
      '5) Se não houver contexto suficiente, peça mais detalhes.';

    FullPrompt :=
      '--- CONTEXTO HISTÓRICO ---' + LineEnding +
      'Abaixo está o histórico de toda a conversa até o momento. Use-o apenas para entender o contexto:' + LineEnding + LineEnding +
      meHistorico.Text + LineEnding + LineEnding +
      '--- NOVA PERGUNTA ---' + LineEnding +
      'A seguir está a nova pergunta feita pelo usuário, que deve ser respondida considerando o histórico acima:' + LineEnding +
      Pergunta + LineEnding + LineEnding +
      '--- MAPA DE MEMÓRIA ---' + LineEnding +
      meMapaMemoria.Text + LineEnding + LineEnding +
      '--- PENSAMENTO (INSTRUÇÕES INTERNAS) ---' + LineEnding +
      mePensamento.Text;

    AddLog('Enviando pergunta + histórico ao ChatGPT...');
    if ExecutarPerguntaIA(DevMsg, FullPrompt, Resposta) then
      Resposta := TextoLimpo(Resposta)
    else
      Resposta := TextoLimpo(Resposta);

    SalvaRIA(CacheFile, Resposta);
  end;

  meResposta.Lines.Text := Resposta;

  meHistorico.Lines.Add('');
  meHistorico.Lines.Add('Pergunta: ' + Pergunta);
  meHistorico.Lines.Add('Resposta: ' + Copy(Resposta, 1, 2000));
  AddLog('Resposta recebida com sucesso.');

  mePergunta.Lines.Clear;
end;

procedure TfrmIA.LimparHistorico();
begin
  MNoteAI.ClearSession;
  meHistorico.Lines.Clear;
  meMapaMemoria.Lines.Clear;
  mePensamento.Lines.Clear;
  meResposta.Lines.Clear;
  meLog.Lines.Clear;
  frmFolders.flagMudanca := true;
  AddLog('Histórico limpo.');
  if Assigned(frmFolders) then
    frmFolders.ApagaRIA;
end;

function TfrmIA.QuestoesFolder(): boolean;
var
  Pergunta, DevMsg, Prompt, Resp: string;
  First: Char;
begin
  Result := False;

  Pergunta := Trim(mePergunta.Text);
  if Pergunta = '' then Exit;

  DevMsg :=
    'Você é um classificador. Responda apenas com "Sim" ou "Nao".' + LineEnding +
    'Sem justificativas, sem pontuação, sem quebras de linha.';
  Prompt :=
    'A pergunta abaixo envolve acesso a ARQUIVOS/PASTAS/Projeto com operações do tipo (abrir ou salvar arquivo, listar diretórios, ' +
    'caminhos de pastas ou arquivos, leitura ou escrita de arquivos, criação ou manipulação de diretorios, informações sobre um projeto. ' + LineEnding +
    ' Em suma, qualquer informação que envolve dados que devam estar armazenados, porem voce não tem acesso na nuvem.)?' + LineEnding +
    'Pergunta: "' + Pergunta + '"' + LineEnding +
    'Responda apenas com "Sim" ou "Nao".';

  AddLog('Classificando se a pergunta envolve arquivos/pastas...');
  if ExecutarPerguntaIA(DevMsg, Prompt, Resp) then
  begin
    Resp := LowerCase(Trim(Resp));
    AddLog('sim');
  end
  else
  begin
    Resp := Trim(Resp);
    AddLog('nao');
  end;

  if Resp <> '' then
  begin
    First := LowerCase(Resp[1]);
    if First = 's' then
      Result := True
    else if First = 'n' then
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

  DevMsg :=
    'Você é um classificador. Responda apenas com "Sim" ou "Nao".' + LineEnding +
    'Sem justificativas, sem pontuação, sem quebras de linha.';
  Prompt :=
    'A pergunta abaixo envolve BANCO DE DADOS (consultas SQL, tabelas, campos, conexões, ' +
    'PostgreSQL, MySQL, SQLite, schemas, inserts, selects, updates, triggers, views, dicionario de dados, tabelas, banco, triggers  ou scripts de banco) ou qualquer informação associada que precise ser obtida em um banco de dados?' + LineEnding +
    'Pergunta: "' + Pergunta + '"' + LineEnding +
    'Responda apenas com "Sim" ou "Nao".';

  AddLog('Classificando se a pergunta envolve banco de dados...');
  if ExecutarPerguntaIA(DevMsg, Prompt, Resp) then
    Resp := Trim(Resp)
  else
    Resp := Trim(Resp);

  if Resp <> '' then
  begin
    First := UpCase(Resp[1]);
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
  Pergunta, DevMsg, Prompt, Resposta, Historico, LogTxt, Mapa: WideString;
  CacheFile: string;
begin
  Pergunta  := Trim(mePergunta.Text);
  Historico := meHistorico.Text;
  LogTxt    := meLog.Lines.Text;
  Mapa      := meMapaMemoria.Lines.Text;

  if (Pergunta = '') or (LogTxt = '') then
  begin
    AddLog('AnalisaRespostaFolder: pergunta ou log vazio(s).');
    Exit;
  end;

  CacheFile := RIAFileName('resumo_folder.RIA');
  if CarregaRIASeValido(CacheFile, Resposta) then
  begin
    AddLog('AnalisaRespostaFolder: reutilizando cache do dia.');
  end
  else
  begin
    DevMsg :=
      'Você é um assistente técnico que extrai respostas objetivas do LOG.' + LineEnding +
      'Use o histórico apenas como contexto mínimo.' + LineEnding +
      'Retorne um texto sintetizando as informações relevantes para atender a questão.' + LineEnding +
      'Se não houver nada útil, responda exatamente: Sem dados relevantes';

    Prompt :=
      '--- CONTEXTO HISTÓRICO (resumo) ---' + LineEnding +
      Historico + LineEnding + LineEnding +
      '--- CONTEXTO MAPA MENTAL (informações relevantes) ---' + LineEnding +
      Mapa + LineEnding + LineEnding +
      '--- LOG DO FOLDER (fonte factual) ---' + LineEnding +
      LogTxt + LineEnding + LineEnding +
      '--- PERGUNTA ---' + LineEnding +
      Pergunta + LineEnding + LineEnding +
      'TAREFA: Com base apenas no LOG, gere um texto curto com as respostas relevantes à pergunta.' + LineEnding +
      'Não explique o procedimento, apenas responda objetivamente.' + LineEnding +
      'Sem listas, sem títulos, sem rodapé.';

    AddLog('AnalisaRespostaFolder: gerando resumo relevante do log...');
    if ExecutarPerguntaIA(DevMsg, Prompt, Resposta) then
      Resposta := TextoLimpo(Trim(Resposta))
    else
      Resposta := TextoLimpo(Trim(Resposta));

    if Resposta = '' then
      Resposta := 'Sem dados relevantes';

    SalvaRIA(CacheFile, Resposta);
  end;

  meMapaMemoria.Lines.Add('--- [FOLDER/RESUMO RELEVANTE] ---');
  meMapaMemoria.Lines.Add(Resposta);
  AddLog('AnalisaRespostaFolder: resumo adicionado ao mapa de memória.');
end;

function TfrmIA.BancoConectado(): boolean;
begin
  if frmmquery2 <> nil then
    Result := frmmquery2.zconpost.Connected or
              frmmquery2.zconmysql.Connected or
              frmmquery2.zconsqlite.Connected
  else
    Result := False;
end;

end.
