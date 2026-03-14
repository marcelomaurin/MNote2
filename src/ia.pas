unit IA;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Buttons, chatgpt, setmain, folders, mquery2, fpjson, jsonparser,
  item, SynEditTypes, SynEdit;

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
    function QuestoesFolder(): boolean;
    function QuestoesCaminho(): boolean;
    function QuestoesBanco(): boolean;
    procedure AnalisaRespostaFolder();
    function BancoConectado(): boolean;
    function CriaDicionarioPost(): string;

    // >>>>>> NOVO: Dicionário SQLite <<<<<<
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
  // Mantém a ideia de garantir UTF-8.
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
  arquivo, arquivo1, arquivo2: string;
  ac: TTipoAcao;
begin
  lstAcao := TStringList.Create;
  lstRealizar := TStringList.Create;

  for ac := Low(TTipoAcao) to High(TTipoAcao) do
    lstAcao.Add(AcaoToStr(ac));

  arquivo  := FSetMain.Defaultfolder + 'HISTORICO.RIA';
  arquivo1 := FSetMain.Defaultfolder + 'mapamemoria.RIA';
  arquivo2 := FSetMain.Defaultfolder + 'pensamento.RIA';

  if FileExists(arquivo) then
    meHistorico.Lines.LoadFromFile(arquivo);
  if FileExists(arquivo1) then
    meMapaMemoria.Lines.LoadFromFile(arquivo1);
  if FileExists(arquivo2) then
    mePensamento.Lines.LoadFromFile(arquivo2);
end;

procedure TfrmIA.meHistoricoChange(Sender: TObject);
var
  arquivo: string;
begin
  arquivo := FSetMain.Defaultfolder + 'HISTORICO.RIA';
  try
    meHistorico.Lines.SaveToFile(arquivo);
  except
    // silencia erro de I/O
  end;
end;

procedure TfrmIA.meMapaMemoriaChange(Sender: TObject);
var
  arquivo: string;
begin
  arquivo := FSetMain.Defaultfolder + 'mapamemoria.RIA';
  try
    meMapaMemoria.Lines.SaveToFile(arquivo);
  except
  end;
end;

procedure TfrmIA.mePensamentoChange(Sender: TObject);
var
  arquivo: string;
begin
  arquivo := FSetMain.Defaultfolder + 'pensamento.RIA';
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

procedure TfrmIA.PerguntaIA();
begin
  if not VerificaContinuidade() then
  begin
    LimparHistorico();
  end
  else
  begin
    frmFolders.flagMudanca := false;
  end;

  AnalisaBanco();
  AnalisaFolder();
  MapeiaPensamento();
  RespondePergunta();
end;

function TfrmIA.CriaDicionarioPost(): string;
var
  baseDir, fileName: string;
begin
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
  baseDir, fileName, dbName: string;
  outSQL: TStringList;
  tbl, ddl, line: string;
begin
  Result := '';

  if (frmmquery2 = nil) then Exit;
  if not frmmquery2.zconsqlite.Connected then Exit;

  {$IFDEF WINDOWS}
  baseDir := GetAppConfigDir(False);
  {$ELSE}
  baseDir := GetUserDir;
  {$ENDIF}

  ForceDirectories(baseDir);
  fileName := IncludeTrailingPathDelimiter(baseDir) + 'dicionario_sqlite.sql';

  dbName := '';
  if Assigned(frmmquery2.edDatabase) then
    dbName := ExtractFileName(Trim(frmmquery2.edDatabase.Text));

  outSQL := TStringList.Create;
  try
    outSQL.Add('-- =========================================');
    outSQL.Add('-- Dicionário de dados (SQLite) - IA');
    outSQL.Add('-- Gerado em: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    if Trim(dbName) <> '' then
      outSQL.Add('-- DB: ' + dbName);
    outSQL.Add('-- =========================================');
    outSQL.Add('');

    // lista tabelas (exclui sqlite_%)
    frmmquery2.zliteqry.Close;
    frmmquery2.zliteqry.SQL.Text :=
      'SELECT name '+
      'FROM sqlite_master '+
      'WHERE type = ''table'' AND name NOT LIKE ''sqlite_%'' '+
      'ORDER BY name';
    frmmquery2.zliteqry.Open;

    while not frmmquery2.zliteqry.EOF do
    begin
      tbl := frmmquery2.zliteqry.FieldByName('name').AsString;

      outSQL.Add('-- ' + tbl);

      // tenta pegar CREATE direto
      frmmquery2.zliteqry1.Close;
      frmmquery2.zliteqry1.SQL.Text :=
        'SELECT sql FROM sqlite_master WHERE type=''table'' AND name=:n';
      frmmquery2.zliteqry1.ParamByName('n').AsString := tbl;
      frmmquery2.zliteqry1.Open;

      ddl := '';
      if (not frmmquery2.zliteqry1.IsEmpty) and (Trim(frmmquery2.zliteqry1.Fields[0].AsString) <> '') then
        ddl := frmmquery2.zliteqry1.Fields[0].AsString;

      if Trim(ddl) <> '' then
        outSQL.Add(ddl + ';')
      else
      begin
        // fallback: gera via PRAGMA table_info
        outSQL.Add('CREATE TABLE ' + tbl + ' (');

        frmmquery2.zliteqry1.Close;
        frmmquery2.zliteqry1.SQL.Text := 'PRAGMA table_info(' + QuotedStr(tbl) + ')';
        frmmquery2.zliteqry1.Open;

        while not frmmquery2.zliteqry1.EOF do
        begin
          line := '  ' + frmmquery2.zliteqry1.FieldByName('name').AsString + ' ' +
                  frmmquery2.zliteqry1.FieldByName('type').AsString;

          if frmmquery2.zliteqry1.FieldByName('notnull').AsInteger = 1 then
            line := line + ' NOT NULL';

          if not frmmquery2.zliteqry1.FieldByName('dflt_value').IsNull then
            line := line + ' DEFAULT ' + frmmquery2.zliteqry1.FieldByName('dflt_value').AsString;

          frmmquery2.zliteqry1.Next;

          if frmmquery2.zliteqry1.EOF then
            outSQL.Add(line)
          else
            outSQL.Add(line + ',');
        end;

        outSQL.Add(');');
      end;

      outSQL.Add('');
      frmmquery2.zliteqry.Next;
    end;

    // salva e retorna
    try
      outSQL.SaveToFile(fileName);
    except
      // se falhar, só ignora o save e retorna o texto
    end;

    Result := outSQL.Text;
  finally
    outSQL.Free;
  end;
end;

function TfrmIA.VerificaContinuidade(): boolean;
var
  DevMsg     : WideString;
  FullPrompt : WideString;
  Pergunta   : WideString;
  Resposta   : WideString;
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

  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    AddLog('Token do ChatGPT não configurado em FSetMain.CHATGPT.');
    Exit(False);
  end;

  FChatGPT.TOKEN := FSetMain.CHATGPT;

  DevMsg :=
    'Você é um classificador.' + LineEnding +
    'Sua função é responder apenas com "Sim" ou "Nao".' + LineEnding +
    'Analise o histórico de conversas e a pergunta atual e diga se elas têm relação direta ou apresenta ideia de continuidade ao que esta sendo tratado.' + LineEnding +
    'Responda apenas com uma palavra: Sim ou Não.' + LineEnding +
    'Sem explicações, sem pontuação, sem comentários adicionais.';
  FChatGPT.Dev := DevMsg;

  FullPrompt :=
    '--- HISTÓRICO DE CONVERSAS ---' + LineEnding +
    meHistorico.Lines.Text + LineEnding + LineEnding +
    '--- NOVA PERGUNTA ---' + LineEnding +
    Pergunta + LineEnding +
    'A pergunta tem relação direta com o histórico acima?';

  AddLog('Enviando pergunta ao classificador de continuidade...');
  if FChatGPT.SendQuestion(FullPrompt) then
    Resposta := Trim(LowerCase(TextoLimpo(FChatGPT.Response)))
  else
    Resposta := Trim(LowerCase(TextoLimpo(FChatGPT.Response)));

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

  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit(False);
  end;

  DevMsg :=
    'Você é um classificador binário.' + LineEnding +
    'Sua única função é responder se a orientação da IA exige a execução de uma AÇÃO .' + LineEnding +
    'Entenda como "AÇÃO do sistema" algo que precisa ser feito pelo usuario, tal como uma mudança de codigo, criar algo, ou mesmo uma pesquisa ou processo no banco de dados, ou em serviços tais como email e etc.' + LineEnding +
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
  JsonData : TJSONData;
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

  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit(False);
  end;

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

  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev   := DevMsg;

  AddLog('Analisando ações em JSON (AnalisaAcao)...');

  if FChatGPT.SendQuestion(Prompt) then
    Resp := Trim(TextoLimpo(FChatGPT.Response))
  else
    Resp := Trim(TextoLimpo(FChatGPT.Response));

  if Resp = '' then
    Exit(False);

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

    if not Obj.Find('acoes', JsonData) then
      Exit(False);

    if not (JsonData is TJSONArray) then
      Exit(False);

    Arr := TJSONArray(JsonData);

    for i := 0 to Arr.Count - 1 do
    begin
      SAcao := Trim(UpperCase(Arr.Strings[i]));
      if IsAcaoValida(SAcao) then
        lstRealizar.Add(SAcao);
    end;

    Result := (lstRealizar.Count > 0);
  finally
    JsonData.Free;
  end;
end;

procedure TfrmIA.AnalisaBanco();
var
  dicSqlite: string;
begin
  if QuestoesBanco() then
  begin
    if BancoConectado then
    begin
      // >>>> Ajuste: agora inclui SQLite também <<<<
      if (frmmquery2.zconpost.Connected) or (frmmquery2.zconmysql.Connected) or (frmmquery2.zconsqlite.Connected) then
      begin
        if frmmquery2.zconpost.Connected then
          meMapaMemoria.Lines.Add(CriaDicionarioPost());

        if frmmquery2.zconmysql.Connected then
        begin
          // ponto para dicionário MySQL, se quiser no futuro
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

  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

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

  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev   := DevMsg;

  AddLog('Classificando se a árvore tem informações suficientes...');

  if FChatGPT.SendQuestion(Prompt) then
    Resp := LowerCase(Trim(FChatGPT.Response))
  else
    Resp := LowerCase(Trim(FChatGPT.Response));

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
      meMapaMemoria.Lines.Add(frmFolders.AnalisaFolderIA(meHistorico.text+' '+mePergunta.Lines.Text));
      meMapaMemoria.Lines.Add(frmFolders.meLog.Lines.Text);

      AnalisaRespostaFolder();
      meMapaMemoria.Lines.Add('');
    end;
  end;
end;

procedure TfrmIA.MapeiaPensamento();
var
  DevMsg, FullPrompt, Pergunta, Resposta: WideString;
begin
  Pergunta := Trim(mePergunta.Text);

  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    AddLog('Token do ChatGPT não configurado em FSetMain.CHATGPT (MapeiaPensamento).');
    Exit;
  end;

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

  FullPrompt :=
    '--- CONTEXTO HISTÓRICO ---' + LineEnding +
    'Abaixo está o histórico de toda a conversa até o momento. Use-o apenas para entender o contexto:' + LineEnding +
    LineEnding +
    meHistorico.Lines.Text + LineEnding + LineEnding +
    '--- NOVA PERGUNTA ---' + LineEnding +
    'A seguir está a nova pergunta feita pelo usuário, que deve ser respondida considerando o histórico acima:' + LineEnding +
    Pergunta + LineEnding + LineEnding +
    '--- MAPA DE MEMÓRIA ---' + LineEnding +
    meMapaMemoria.Lines.Text + LineEnding + LineEnding +
    '--- PENSAMENTO (INSTRUÇÕES INTERNAS) ---' + LineEnding +
    mePensamento.Lines.Text;

  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev   := DevMsg;

  AddLog('MapeiaPensamento: enviando contexto para gerar mapa de pensamento...');
  if FChatGPT.SendQuestion(FullPrompt) then
    Resposta := TextoLimpo(FChatGPT.Response)
  else
    Resposta := TextoLimpo(FChatGPT.Response);

  if Trim(Resposta) <> '' then
  begin
    mePensamento.Lines.Text := Resposta;
    meMapaMemoria.Lines.Add('--- [PENSAMENTO/IA] ---');
    meMapaMemoria.Lines.Add(Resposta);
  end;
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
  FChatGPT.Dev   := DevMsg;

  AddLog('Enviando pergunta + histórico ao ChatGPT...');
  if FChatGPT.SendQuestion(FullPrompt) then
    Resposta := TextoLimpo(FChatGPT.Response)
  else
    Resposta := TextoLimpo(FChatGPT.Response);

  meResposta.Lines.Text := Resposta;

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
  frmFolders.flagMudanca := true;
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

  DevMsg :=
    'Você é um classificador. Responda apenas com "Sim" ou "Nao".' + LineEnding +
    'Sem justificativas, sem pontuação, sem quebras de linha.';
  Prompt :=
    'A pergunta abaixo envolve acesso a ARQUIVOS/PASTAS/Projeto com operações do tipo (abrir ou salvar arquivo, listar diretórios, ' +
    'caminhos de pastas ou arquivos, leitura ou escrita de arquivos, criação ou manipulação de diretorios, informações sobre um projeto. ' + LineEnding +
    ' Em suma, qualquer informação que envolve dados que devam estar armazenados, porem voce não tem acesso na nuvem.)?' + LineEnding +
    'Pergunta: "' + Pergunta + '"' + LineEnding +
    'Responda apenas com "Sim" ou "Nao".';

  FChatGPT.TOKEN := FSetMain.CHATGPT;
  FChatGPT.Dev   := DevMsg;

  AddLog('Classificando se a pergunta envolve arquivos/pastas...');
  if FChatGPT.SendQuestion(Prompt) then
  begin
    Resp := LowerCase(Trim(FChatGPT.Response));
    AddLog('sim');
  end
  else
  begin
    Resp := Trim(FChatGPT.Response);
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

  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

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

  if FChatGPT = nil then
    FChatGPT := TCHATGPT.Create(Self);

  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

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
  if frmmquery2 <> nil then
    // >>>> Ajuste: inclui SQLite
    Result := frmmquery2.zconpost.Connected or frmmquery2.zconmysql.Connected or frmmquery2.zconsqlite.Connected
  else
    Result := False;
end;

end.
