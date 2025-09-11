unit folders;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ShellCtrls,
  ExtCtrls, Menus, StdCtrls, GifAnim, untsalesSwitch, funcoes, hint, setmain,
  chatgpt, Types, StrUtils, LConvEncoding, base, DateUtils, LazFileUtils,
  fpjson, jsonparser;

type

  { TfrmFolders }

  TfrmFolders = class(TForm)
    btScanner: TButton;
    btIA: TButton;
    edFolder: TEdit;
    GifAnim1: TGifAnim;
    Label1: TLabel;
    Label2: TLabel;
    lbName: TLabel;
    meLog: TMemo;
    miAnalisaArquivo: TMenuItem;
    Panel7: TPanel;
    ProgressBar1: TProgressBar;
    Separator3: TMenuItem;
    mePergunta: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PageControl1: TPageControl;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    pnScanner: TPanel;
    pbScanning: TProgressBar;
    Separator2: TMenuItem;
    miDelete: TMenuItem;
    mirefresh: TMenuItem;
    miCreatedir: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    Separator1: TMenuItem;
    ShellListView1: TShellListView;
    ShellTreeView1: TShellTreeView;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    tsFolders: TTabSheet;
    tsIA: TTabSheet;

    procedure btScannerClick(Sender: TObject);
    procedure btIAClick(Sender: TObject);
    procedure edFolderKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure CarregaContexto();
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure miAnalisaArquivoClick(Sender: TObject);
    procedure miCreatedirClick(Sender: TObject);
    procedure miDeleteClick(Sender: TObject);
    procedure mirefreshClick(Sender: TObject);
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure ShellTreeView1Changing(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure ShellTreeView1GetSelectedIndex(Sender: TObject; Node: TTreeNode);
  private
     ArvoreDiretorios : string;
     Projeto : string;
     Arquivos : TStringList;
     function Util_ClipText(const S: string; MaxChars: Integer): string;
     function AF_BuildDevMsg_ListaCodigos: string;
     // === Helpers usadas por AnalisaFonte (sem aninhar) ===
     function  AF_LoadTextLimited(const Path: string; const MaxBytes: Integer): string;
     function  AF_AddLineNumbers(const S: string): string;
     function  AF_GuessLanguageByExt(const Ext: string): string;
     function  AF_BuildDevMsg: string;
     function  AF_BuildAsk(const Fonte, Linguagem, SrcNum: string): string;
     function  AF_SendToChatGPT(const DevMsg, Ask, Token: string; out Resp: string): Boolean;
     function  AF_BeautifyJson(const Resp: string): string;
     function AF_BuildAsk_ListaCodigos(
                const ArvoreY, SolicitacaoX: string; MaxItens: Integer): string;
     function ParseArquivosRecomendadosJSON(
      const JSONText: string; Dest: TStrings;
      out Solicitacao, Observacoes: string): Integer;

     function ExtractPathFromItemJSON(const ItemJSON: string): string;
   public
     function  Scanner(const Root: string): TStringList;
     procedure AtualizaProjeto;
     procedure AnalisaFonte(const Fonte: string);
     procedure RegistraTabelas(Fonte: string; json : string);
     procedure AnalisaProjeto();
     function  ListaCodigos(const ArvoreArquivosY, SolicitacaoX: string; MaxItens: Integer = 25): string;
   end;


var
  frmFolders: TfrmFolders;

implementation

uses main;
{$R *.lfm}

{ TfrmFolders }

procedure TfrmFolders.MenuItem1Click(Sender: TObject);
var
  diretorio : string;
  arquivo : string;
begin
  diretorio := ShellTreeView1.Path;
  arquivo := ShellListView1.Selected.Caption;
  if (arquivo <> '') then
  begin
       frmMNote.CarregarArquivo(diretorio+arquivo);
  end;
end;

procedure TfrmFolders.CarregaContexto();
begin

end;

procedure TfrmFolders.MenuItem2Click(Sender: TObject);
begin

  Fsetmain.Defaultfolder:= ShellTreeView1.Path;
  FSetMain.SalvaContexto(false);
end;

procedure TfrmFolders.MenuItem3Click(Sender: TObject);
var
  tree: TStringList;
begin
  meLog.Clear;
  if(FSetMain.Project<>'') then
  begin
      // grava no SQLite
      AtualizaProjeto;
  end;
  // mostra a árvore
  tree := Scanner(edFolder.Text);
  try
    meLog.Lines.Assign(tree);
    meLog.Lines.Add('');
    meLog.Lines.Add(Format('Total de linhas: %d', [tree.Count]));
  finally
    tree.Free;
  end;
end;

procedure TfrmFolders.miAnalisaArquivoClick(Sender: TObject);
var
  dir, nome, arquivo: string;
begin
  if (ShellListView1.Selected = nil) then
  begin
    MessageHint('Selecione um arquivo na lista.');
    Exit;
  end;

  // diretório atual (você já sincroniza edFolder com o ShellTreeView)
  dir  := edFolder.Text;
  nome := ShellListView1.Selected.Caption;

  arquivo := IncludeTrailingPathDelimiter(dir) + nome;

  // fallback: alguns temas retornam melhor pelo GetNamePath
  if (not FileExists(arquivo)) and Assigned(ShellListView1.Selected) then
  begin
    try
      arquivo := ShellListView1.Selected.GetNamePath; // se disponível no seu Lazarus
    except
      // ignora
    end;
  end;

  if DirectoryExists(arquivo) then
  begin
    MessageHint('Selecione um arquivo (não uma pasta).');
    Exit;
  end;

  if not FileExists(arquivo) then
  begin
    MessageHint('Arquivo não encontrado: ' + arquivo);
    Exit;
  end;

  AnalisaFonte(arquivo);
end;

procedure TfrmFolders.miCreatedirClick(Sender: TObject);
var
  folder : string;
  pathfolder : string;
begin

   folder := InputBox ('Create dir','FOLDER:','NewFolder');
   if (folder <> '') then
   begin
        pathfolder := edFolder.text+folder;
        if CreateDir(pathfolder) then
        begin
          MessageHint('Folder '+pathfolder+ ' create successful!');
          ShellTreeView1.refresh;
        end
        else
        begin
          MessageHint('Folder '+pathfolder+ ' create fail!');
        end;

   end;
end;

procedure TfrmFolders.miDeleteClick(Sender: TObject);
var

  pathfolder : string;
begin
  pathfolder := edFolder.text;
  //edFolder.text :=  ShellListView1.Selected.GetNamePath;
 // showmessage(ShellListView1.Root);
  //ShellTreeView1.Path:=ShellListView1.Root;

  if ShowConfirm('Confirm delete '+pathfolder+'?') then
  begin
        (*
      if RemoveDir( pathfolder) then
      begin
          MessageHint('Folder '+pathfolder+ ' deleted successful!');
      end
      else
      begin
          MessageHint('Folder '+pathfolder+ ' deleted fail!');
      end;
      *)
  end;
end;

procedure TfrmFolders.mirefreshClick(Sender: TObject);
begin
  ShellListView1.Update;
end;

procedure TfrmFolders.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  edFolder.text :=  ShellTreeView1.Path; ;
end;

procedure TfrmFolders.ShellTreeView1Changing(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
     //edFolder.text :=   ShellTreeView1.Path;
end;

procedure TfrmFolders.ShellTreeView1GetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
   //edFolder.text :=   ShellTreeView1.Path;
end;

function TfrmFolders.Scanner(const Root: string): TStringList;

  procedure ScanDir(const Dir: string; const Prefix: string; SL: TStrings);
  var
    SR: TSearchRec;
    SubDirs, Files: TStringList;
    i: Integer;
    base: string;
    code: Integer;
    hasMore: Boolean;

    procedure AddLine(const IsLast: Boolean; const Name: string; const IsDir: Boolean);
    var
      branch: string;
      mark: string;
    begin
      if IsLast then branch := '└── ' else branch := '├── ';
      if IsDir then mark := '[DIR] ' else mark := '';
      SL.Add(Prefix + branch + mark + Name);
    end;

  begin
    SubDirs := TStringList.Create;
    Files   := TStringList.Create;
    try
      // Lista conteúdo do diretório
      code := FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, SR);
      while code = 0 do
      begin
        if (SR.Name <> '.') and (SR.Name <> '..') then
        begin
          if (SR.Attr and faDirectory) <> 0 then
            SubDirs.Add(SR.Name)
          else
            Files.Add(SR.Name);
        end;
        code := FindNext(SR);
      end;
      FindClose(SR);

      // Ordena para saída mais estável
      SubDirs.Sort;
      Files.Sort;

      // Emite subpastas
      for i := 0 to SubDirs.Count - 1 do
      begin
        hasMore := (i < SubDirs.Count - 1) or (Files.Count > 0);
        AddLine(not hasMore, SubDirs[i], True);
        base := IncludeTrailingPathDelimiter(Dir) + SubDirs[i];
        // Recurse com prefixo adequado
        if hasMore then
          ScanDir(base, Prefix + '│   ', SL)
        else
          ScanDir(base, Prefix + '    ', SL);
      end;

      // Emite arquivos
      for i := 0 to Files.Count - 1 do
        AddLine(i = Files.Count - 1, Files[i], False);

    finally
      SubDirs.Free;
      Files.Free;
    end;
  end;

var
  rootFixed: string;
begin
  Result := TStringList.Create;
  try
    rootFixed := Trim(Root);
    if rootFixed = '' then
    begin
      Result.Add('*** Pasta raiz não informada. ***');
      Exit;
    end;

    if not DirectoryExists(rootFixed) then
    begin
      Result.Add('*** Pasta não existe: ' + rootFixed + ' ***');
      Exit;
    end;

    // Cabeçalho
    Result.Add('[ROOT] ' + ExpandFileName(rootFixed));
    // Varrimento
    ScanDir(rootFixed, '', Result);
  except
    on E: Exception do
    begin
      Result.Add('*** Erro no Scanner: ' + E.Message + ' ***');
    end;
  end;
end;


procedure TfrmFolders.FormCreate(Sender: TObject);
begin
  edFolder.text := FSetmain.DefaultFolder;

  if ((edFolder.text = '') or (not ValidateDirectory(edFolder.text))) then
  begin
    {$IFDEF LINUX}
    ShellTreeView1.Path:=ExtractFilePath(application.ExeName);
    edFolder.text := ExtractFilePath(application.ExeName);
    fsetmain.DefaultFolder := ExtractFilePath(application.ExeName);
    fsetmain.SalvaContexto(false);

    {$ENDIF}
    {$IFDEF WINDOWS}
    ShellTreeView1.Path:=ExtractFilePath(application.ExeName);
    edFolder.text := ExtractFilePath(application.ExeName);
    fsetmain.DefaultFolder := ExtractFilePath(application.ExeName);
    fsetmain.SalvaContexto(false);
    {$ENDIF}
  end;

  ShellTreeView1.Path:=edFolder.text;

end;

procedure TfrmFolders.edFolderKeyPress(Sender: TObject; var Key: char);
begin
  if (key=#13) then
  begin
        ShellTreeView1.Path:=edFolder.text;
  end;
end;

procedure TfrmFolders.btScannerClick(Sender: TObject);
var
  tree: TStringList;
begin
  meLog.Clear;
  tree := Scanner(edFolder.Text);
  try
    meLog.Lines.Assign(tree); // mostra a árvore no memo
    meLog.Lines.Add('');
    meLog.Lines.Add(Format('Total de linhas: %d', [tree.Count]));
    //meLog.Lines.SaveToFile(ArvoreDiretorios);
  finally
    tree.Free;
  end;
end;

procedure TfrmFolders.AnalisaProjeto();
function ClipText(const S: string; MaxChars: Integer): string;
begin
  if Length(S) <= MaxChars then Exit(S);
  Result := Copy(S, 1, MaxChars) + LineEnding +
            '... (cortado; árvore muito grande, envie filtros/mais detalhes se necessário)';
end;

// (opcional) monte uma pequena prévia de arquivos .pas/.lfm/.ini para a IA ter contexto
function BuildSmallPreviews(const Root: string; const Tree: TStrings;
                            MaxFiles, MaxBytesPerFile: Integer): string;
var
  i, cnt, L: Integer;
  Path, Rel: string;
  SL: TStringList;
  Buf: AnsiString;
begin
  Result := '';
  SL := TStringList.Create;
  try
    cnt := 0;
    for i := 0 to Tree.Count - 1 do
    begin
      Rel := Trim(Tree[i]);              // sua Scanner deve devolver caminhos relativos
      if (Rel = '') then Continue;

      // filtra extensões que ajudam a análise
      if not AnsiMatchText(ExtractFileExt(Rel), ['.pas', '.pp', '.lfm', '.lpr', '.ini', '.json', '.yml', '.yaml']) then
        Continue;

      Path := IncludeTrailingPathDelimiter(Root) + Rel;
      if not FileExists(Path) then Continue;

      // limita quantidade de arquivos
      Inc(cnt);
      if cnt > MaxFiles then Break;

      try
        SL.LoadFromFile(Path);
        // corta por bytes (simples): junta, converte e limita
        Buf := UTF8Encode(SL.Text);
        L := Length(Buf);
        if L > MaxBytesPerFile then
          SetLength(Buf, MaxBytesPerFile);

        Result := Result +
          '--- FILE: ' + Rel + ' ---' + LineEnding +
          UTF8ToString(Buf) + LineEnding + LineEnding;
      except
        // ignora erro de leitura isolado
      end;
    end;
  finally
    SL.Free;
  end;
end;

var
Tree: TStringList;
Chat : TCHATGPT;
Dev, Prompt, Arvore, Previews, Raiz: string;
begin
meLog.Clear;

// gera a árvore
Tree := Scanner(edFolder.Text);
try
  Raiz   := edFolder.Text;
  Arvore := ClipText(Tree.Text, 60000); // evita estourar tokens
  ArvoreDiretorios:= Arvore;

  // (opcional) trechos de arquivos — ajuste limites se quiser
  Previews := BuildSmallPreviews(Raiz, Tree, {MaxFiles=} 12, {MaxBytesPerFile=} 8000);

  // sistema (instruções fixas para a IA)
  Dev :=
    'Voce é uma IA de respostas sintéticas, sua tarefa é responder de forma direta. .' + LineEnding+
    'Responda de forma concisa e estruturada.';

  // mensagem do usuário com a árvore e (opcional) trechos
  Prompt :=
    'Raiz do projeto: ' + Raiz + LineEnding + LineEnding +
    '--- ÁRVORE DE DIRETÓRIOS E ARQUIVOS ---' + LineEnding +
    Arvore + LineEnding +
    '--- TRECHOS DE ARQUIVOS (amostra) ---' + LineEnding +
    IfThen(Previews <> '', Previews, '(sem prévias)') + LineEnding +
    '--- PEDIDO ---' + LineEnding +
    '- Avalie a seguinte pergunta:' +mePergunta.text+  LineEnding;

  // chama a IA
  Chat := TCHATGPT.Create(Self);
  try
    Chat.TOKEN := FSetMain.CHATGPT;  // já usado no seu projeto
    Chat.Dev   := Dev;

    if Chat.SendQuestion(Prompt) then
      meLog.Lines.Text := Chat.Response
    else
      meLog.Lines.Text := 'Erro ao consultar IA: ' + Chat.Response;
  finally
    Projeto := meLog.Lines.text;
    Chat.Free;
  end;

finally
  Tree.Free;
end;
end;


procedure TfrmFolders.btIAClick(Sender: TObject);
var
  jsonLista, solicit, obs: string;
  qtd, i: Integer;
begin
  ArvoreDiretorios := '';
  AnalisaProjeto();  // preenche ArvoreDiretorios

  jsonLista := ListaCodigos(ArvoreDiretorios, mePergunta.Text, 20);

  if Arquivos = nil then
    Arquivos := TStringList.Create
  else
    Arquivos.Clear;

  qtd := ParseArquivosRecomendadosJSON(jsonLista, Arquivos, solicit, obs);

  // Exibe um resumo e o JSON completo no log
  meLog.Clear;
  meLog.Lines.Add('Solicitação: ' + solicit);
  meLog.Lines.Add('Arquivos carregados (JSON por item): ' + IntToStr(qtd));
  if obs <> '' then meLog.Lines.Add('Observações: ' + obs);
  meLog.Lines.Add('');
  meLog.Lines.Add('-----');
  meLog.Lines.Add('');
  meLog.Lines.Add('Arquivos:');
  // se quiser listar só os paths para conferência:
  for i := 0 to Arquivos.Count - 1 do
    meLog.Lines.Add(ExtractPathFromItemJSON(Arquivos[i]));
  meLog.Lines.Add('-----');
  meLog.Lines.Add('');
  meLog.Lines.Add('--- JSON bruto da IA ---');
  meLog.Lines.Add(AF_BeautifyJson(jsonLista));
end;





procedure TfrmFolders.FormDestroy(Sender: TObject);
var
   info : string;
begin
  Fsetmain.SalvaContexto(false);
end;

procedure TfrmFolders.FormShow(Sender: TObject);
begin

end;

procedure TfrmFolders.AtualizaProjeto;



  // converte data de modificação para epoch (segundos)
  function FileMTimeUTC_OrNow(const FullPath: string): Int64;
  var
    dt: TDateTime;
  begin
    // FileAge retorna localtime; usamos DateUtils para converter
    if FileAge(FullPath, dt) then
      Result := DateTimeToUnix(dt)
    else
      Result := DateTimeToUnix(Now);
  end;


  // varre recursivamente o filesystem gravando na tabela fs
  procedure IndexDir(const DirPath: string; const ParentId: Integer);
  var
    SR: TSearchRec;
    code: Integer;
    subId: Integer;
    childName, full: string;
    isDir: Boolean;
  begin


    code := FindFirst(IncludeTrailingPathDelimiter(DirPath) + '*', faAnyFile, SR);
    try
      while code = 0 do
      begin
        if (SR.Name <> '.') and (SR.Name <> '..') then
        begin
          isDir   := (SR.Attr and faDirectory) <> 0;
          childName := SR.Name;
          full      := IncludeTrailingPathDelimiter(DirPath) + childName;

          if isDir then
          begin
            lbName.Caption:= childName;
            pbScanning.Position:= pbScanning.Position + 1;
            Application.ProcessMessages;
            if isDir then
               subId := dmbase.EnsureDirUnderParent(ParentId, DirPath, FileMTimeUTC_OrNow(full))
            else
              subId := dmbase.EnsureDirUnderParent(ParentId, childName, FileMTimeUTC_OrNow(full));
            IndexDir(full, subId);
          end
          else
          begin
            dmbase.UpsertFile(ParentId, childName, full);
          end;
        end;
        code := FindNext(SR);
      end;
    finally
      FindClose(SR);


    end;
  end;

var
  RootFSId: Integer;
  RootPath: string;
begin
  pnScanner.Visible:= true;
  Application.ProcessMessages;
  //meLog.Lines.Add('Iniciando indexação no SQLite...');

  MessageHint('Iniciando indexação no SQLite...');
  if(dmBase = nil) then
  begin
    dmBase := Tdmbase.create(self);
  end;

  if not dmBase.zconlocal.Connected then
  begin

    //meLog.Lines.Add('*** SQLite não conectado (dmBase.zconlocal).');
    if(FSetMain.Project= '') then
    begin

      MessageHint('*** SQLite não conectado (dmBase.zconlocal).');
      Exit;
    end
    else
    begin

    end;
  end;
  dmbase.DeleteFS; //Apaga base de dados anterior
  RootPath := Trim(FSetMain.DefaultFolder);
  if (RootPath = '') or (not DirectoryExists(RootPath)) then
  begin
    //meLog.Lines.Add('*** Pasta inválida: ' + RootPath);

    MessageHint('*** Pasta inválida: ' + RootPath);
    Exit;
  end;

  // transação (opcional, acelera bastante)
  dmBase.zconlocal.AutoCommit := False;
  try
    RootFSId := dmbase.EnsureRootId; // cria “/” se precisar
    IndexDir(RootPath, RootFSId);
    dmBase.zconlocal.Commit;
    //meLog.Lines.Add('Indexação concluída com sucesso.');


    MessageHint('Indexação concluída com sucesso.');
  except
    on E: Exception do
    begin
      dmBase.zconlocal.Rollback;
      //meLog.Lines.Add('*** Falha na indexação: ' + E.Message);

      MessageHint('*** Falha na indexação: ' + E.Message);
    end;
  end;
  dmBase.zconlocal.AutoCommit := True;
  pnScanner.Visible:= false;
  Application.ProcessMessages;
end;

{ =====================  ANALISAFONTE ORQUESTRADORA  ===================== }

procedure TfrmFolders.AnalisaFonte(const Fonte: string);
var
  Src, SrcNum, DevMsg, Ask, Resp, Beautified, Linguagem: string;
  MaxBytes: Integer;
begin
  meLog.Clear;
  meLog.Lines.Add('Analisando: ' + Fonte);

  // 1) Carrega o conteúdo com limite (ex: 200 KB)
  MaxBytes := 200 * 1024;
  Src := AF_LoadTextLimited(Fonte, MaxBytes);
  if Src = '' then
  begin
    MessageHint('Arquivo vazio ou não foi possível ler.');
    Exit;
  end;

  // 2) Enriquecimentos de contexto
  Linguagem := AF_GuessLanguageByExt(ExtractFileExt(Fonte));
  SrcNum    := AF_AddLineNumbers(Src);

  // 3) Monta mensagens para a IA
  DevMsg := AF_BuildDevMsg;
  Ask    := AF_BuildAsk(Fonte, Linguagem, SrcNum);

  // 4) Consulta IA
  if not AF_SendToChatGPT(DevMsg, Ask, FSetMain.CHATGPT, Resp) then
  begin
    meLog.Lines.Add('Falha ao consultar a IA.');
    Exit;
  end;

  // 5) Embeleza JSON (se possível) e registra
  Beautified := AF_BeautifyJson(Resp);
  if Beautified = '' then
    Beautified := Resp; // se falhou, usa bruto

  // 6) Persistência específica (suas tabelas/relacionamentos)
  RegistraTabelas(Fonte, Beautified);
end;

{ =====================  HELPERS (SEM FUNÇÕES ANINHADAS)  ===================== }

function TfrmFolders.AF_LoadTextLimited(const Path: string; const MaxBytes: Integer): string;
var
  FS: TFileStream;
  Buf: RawByteString;
begin
  Result := '';
  if not FileExists(Path) then Exit;

  FS := TFileStream.Create(Path, fmOpenRead or fmShareDenyNone);
  try
    if FS.Size > MaxBytes then
      SetLength(Buf, MaxBytes)
    else
      SetLength(Buf, FS.Size);

    if Length(Buf) > 0 then
    begin
      FS.ReadBuffer(Pointer(Buf)^, Length(Buf));
      // tenta decodificar como UTF-8; se vier vazio, assume binário/ANSI
      Result := UTF8ToString(Buf);
      if Result = '' then
        Result := String(Buf);
    end;
  finally
    FS.Free;
  end;
end;

function TfrmFolders.AF_AddLineNumbers(const S: string): string;
var
  SL: TStringList;
  i: Integer;
begin
  SL := TStringList.Create;
  try
    SL.Text := S;
    for i := 0 to SL.Count - 1 do
      SL[i] := Format('%6d | %s', [i + 1, SL[i]]);
    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

function TfrmFolders.AF_GuessLanguageByExt(const Ext: string): string;
begin
  case LowerCase(Ext) of
    '.pas', '.pp', '.lpr':   Exit('pascal/delphi');
    '.lfm':                  Exit('lazarus-form');
    '.sql':                  Exit('sql');
    '.py':                   Exit('python');
    '.js':                   Exit('javascript');
    '.ts':                   Exit('typescript');
    '.json':                 Exit('json');
    '.ini', '.cfg':          Exit('ini');
    '.yml', '.yaml':         Exit('yaml');
    '.php':                  Exit('php');
    '.java':                 Exit('java');
    '.cs':                   Exit('csharp');
    '.c', '.h':              Exit('c');
    '.cpp', '.hpp', '.cc':   Exit('cpp');
  else
    Exit('texto');
  end;
end;

function TfrmFolders.AF_BuildDevMsg: string;
begin
  Result :=
    'Você é um analisador de código.' + LineEnding +
    'Responda ESTRITAMENTE em JSON válido UTF-8.' + LineEnding +
    'Não use markdown, não escreva nada fora do JSON e não inclua comentários.';
end;

function TfrmFolders.AF_BuildAsk(const Fonte, Linguagem, SrcNum: string): string;
begin
  Result :=
    'ARQUIVO: ' + ExtractFileName(Fonte) + LineEnding +
    'CAMINHO: ' + Fonte + LineEnding +
    'LINGUAGEM (estimada): ' + Linguagem + LineEnding + LineEnding +
    '--- CÓDIGO COM LINHAS ---' + LineEnding +
    SrcNum + LineEnding +
    '--- FIM ---' + LineEnding + LineEnding +
    'TAREFA:' + LineEnding +
    '- Gere SOMENTE o JSON no formato fonte, lista de tabelas usadas ou relacionadas no fonte. ' + LineEnding +
    '- Identifique as tabelas usadas(tabela_usada).' + LineEnding +
    '- Identifique as tabelas relacionadas(tabela_relacionada).' + LineEnding +
    '- Faça um resumo do que é feito em poucas linhas; priorize regras de negócio (resumo).' + LineEnding +
    '- Mostre os fontes chamados neste fonte (fontes_vinculados).' + LineEnding +
    '- NUNCA inclua markdown, rótulos, ou texto fora do JSON.';
end;

function TfrmFolders.AF_SendToChatGPT(
  const DevMsg, Ask, Token: string; out Resp: string): Boolean;
var
  Chat: TCHATGPT;
begin
  Result := False;
  Resp   := '';

  if Trim(Token) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit;
  end;

  Chat := TCHATGPT.Create(Self);
  try
    Chat.TOKEN := Token;
    Chat.Dev   := DevMsg;
    if Chat.SendQuestion(Ask) then
    begin
      Resp   := Chat.Response;
      Result := True;
    end
    else
      Resp := Chat.Response; // pode vir JSON de erro
  finally
    Chat.Free;
  end;
end;

function TfrmFolders.AF_BeautifyJson(const Resp: string): string;
var
  Parser: TJSONParser;
  Data: TJSONData;
begin
  Result := '';
  try
    Parser := TJSONParser.Create(Resp);
    try
      Data := Parser.Parse;
      try
        Result := Data.FormatJSON([], 2);
      finally
        Data.Free;
      end;
    finally
      Parser.Free;
    end;
  except
    // Se falhar o parse, devolve vazio e quem chama decide usar bruto
  end;
end;



procedure TfrmFolders.RegistraTabelas(Fonte: string; json: string);
var
  Clean: string;
  p1, p2: SizeInt;
  Parser: TJSONParser;
  Data: TJSONData;
  Obj: TJSONObject;
  SLUsadas, SLRelacionadas, SLFontes: TStringList;
  Resumo: string;
  i: Integer;
  caminho : string;
  arquivo : string;
  extensao : string;
  iddir , id : integer;

  procedure ReplaceDebugMarkers(var S: string);
  begin
    // Remove prefixos do tipo “$08296158^: ” pegando do primeiro “{” até o último “}”
    p1 := Pos('{', S);
    p2 := RPos('}', S); // requer StrUtils
    if (p1 > 0) and (p2 >= p1) then
      S := Copy(S, p1, p2 - p1 + 1);

    // Converte marcadores do depurador para quebras reais
    if Pos('#$0', S) > 0 then
    begin
      S := StringReplace(S, '''#$0D#$0A''', LineEnding, [rfReplaceAll]);
      S := StringReplace(S, '#$0D#$0A', LineEnding, [rfReplaceAll]);
      S := StringReplace(S, '#$0D', #13, [rfReplaceAll]);
      S := StringReplace(S, '#$0A', #10, [rfReplaceAll]);
    end;
  end;

  procedure FillListFromArray(const Key: string; L: TStrings);
  var
    A: TJSONArray;
    j: Integer;
  begin
    L.Clear;
    if not Obj.Find(Key, A) then Exit;
    if A = nil then Exit;
    for j := 0 to A.Count - 1 do
      if A.Items[j].JSONType = jtString then
        L.Add(A.Strings[j]);
  end;

begin
  caminho := ExtractFilePath(Fonte);
  if (caminho <> '') and (caminho[Length(caminho)] in ['/', '\']) then
     Delete(caminho, Length(caminho), 1);
  arquivo := ExtractFileName(fonte);
  extensao:= ExtractFileExt(fonte);

  // 1) Sanitiza entrada
  Clean := json;
  ReplaceDebugMarkers(Clean);

  // 2) Parse JSON
  Parser := TJSONParser.Create(Clean);
  try
    Data := Parser.Parse;
    try
      if Data.JSONType <> jtObject then
        raise Exception.Create('JSON raiz não é objeto.');
      Obj := TJSONObject(Data);

      // 3) Extrai campos
      SLUsadas        := TStringList.Create;
      SLRelacionadas  := TStringList.Create;
      SLFontes        := TStringList.Create;
      try
        FillListFromArray('tabela_usada',        SLUsadas);
        FillListFromArray('tabela_relacionada',  SLRelacionadas);
        FillListFromArray('fontes_vinculados',   SLFontes);
        Resumo := Obj.Get('resumo', '');

        // 4) (Exemplo) Exibe no log — troque aqui pelo que quiser fazer com as listas
        meLog.Lines.Add('--- Resultado de ' + ExtractFileName(Fonte) + ' ---');
        meLog.Lines.Add('resumo: ' + Resumo);

        meLog.Lines.Add('tabela_usada:');
        for i := 0 to SLUsadas.Count-1 do meLog.Lines.Add('  - ' + SLUsadas[i]);

        meLog.Lines.Add('tabela_relacionada:');
        for i := 0 to SLRelacionadas.Count-1 do meLog.Lines.Add('  - ' + SLRelacionadas[i]);

        meLog.Lines.Add('fontes_vinculados:');
        for i := 0 to SLFontes.Count-1 do meLog.Lines.Add('  - ' + SLFontes[i]);

        //Busca o id do diretorio
        iddir := dmbase.Buscafs_IDpeloDiretorio(caminho);
        if (iddir<>0) then
        begin
            id := dmbase.Buscafs_IDpeloNome (iddir, arquivo);
            if (id <> 0) then
            begin
              dmbase.AtualizarResumo(id, Resumo);
            end
            else
            begin
              MessageHint('Arquivo nao encontrado na base');
            end;
        end;





        // 👉 Ou já persistir nas suas tabelas (fs_tabelas / tabelas):
        // - descobrir fs_id a partir de Fonte (na sua tabela fs)
        // - garantir tabela_id em `tabelas` (criando se faltar)
        // - para cada item SLUsadas/SLRelacionadas, chamar RegistraRelacaoFsTabela(fs_id, tabela_id)
      finally
        SLUsadas.Free;
        SLRelacionadas.Free;
        SLFontes.Free;
      end;

    finally
      Data.Free;
    end;
  except
    on E: Exception do
      MessageHint('Falha ao parsear JSON: ' + E.Message);
  end;
  Parser.Free;
end;

function TfrmFolders.Util_ClipText(const S: string; MaxChars: Integer): string;
begin
  if Length(S) <= MaxChars then
    Exit(S);
  Result := Copy(S, 1, MaxChars) + LineEnding +
            '... (cortado para caber no prompt)';
end;

function TfrmFolders.AF_BuildDevMsg_ListaCodigos: string;
begin
  // Regras: resposta ESTRITAMENTE em JSON válido UTF-8, sem markdown
  Result :=
    'Você é um assistente técnico de engenharia de software.' + LineEnding +
    'Sua tarefa é, dada uma ÁRVORE DE ARQUIVOS (Y) e uma SOLICITAÇÃO/OBJETIVO (X),' + LineEnding +
    'selecionar os arquivos mais relevantes para análise a fim de atender X.' + LineEnding +
    'REGRAS:' + LineEnding +
    '- Responda ESTRITAMENTE em JSON válido UTF-8.' + LineEnding +
    '- Não use markdown, cabeçalhos, comentários ou textos fora do JSON.' + LineEnding +
    '- A lista deve conter **apenas** caminhos que existam em Y.' + LineEnding +
    '- Priorize pontos de entrada, módulos de regra de negócio, camadas de dados, configuração e testes-alvo.' + LineEnding +
    '- Evite binários/mídias e arquivos obviamente irrelevantes.' + LineEnding +
    '- Limite-se ao número máximo solicitado.' + LineEnding +
    '' + LineEnding +
    'FORMATO DO JSON:' + LineEnding +
    '{' + LineEnding +
    '  "solicitacao": "<eco de X>",' + LineEnding +
    '  "arquivos_recomendados": [' + LineEnding +
    '    {"path": "<caminho relativo conforme Y>", "motivo": "<por que este arquivo>", "prioridade": <1-n>} ' + LineEnding +
    '  ],' + LineEnding +
    '  "observacoes": "<opcional, breves notas ou lacunas>"' + LineEnding +
    '}';
end;

function TfrmFolders.AF_BuildAsk_ListaCodigos(
  const ArvoreY, SolicitacaoX: string; MaxItens: Integer): string;
begin
  Result :=
    'SOLICITACAO (X): ' + SolicitacaoX + LineEnding + LineEnding +
    'LIMITE_MAX_ITENS: ' + IntToStr(MaxItens) + LineEnding + LineEnding +
    '--- ARVORE DE ARQUIVOS (Y) ---' + LineEnding +
    ArvoreY + LineEnding +
    '--- FIM ARVORE ---' + LineEnding + LineEnding +
    'TAREFA:' + LineEnding +
    '- Selecione até ' + IntToStr(MaxItens) + ' arquivos da árvore (Y) mais relevantes para atender X.' + LineEnding +
    '- Mantenha caminhos exatamente como aparecem em Y quando possível.' + LineEnding +
    '- Ordene por "prioridade" (1 = mais importante).' + LineEnding +
    '- Responda apenas no formato JSON especificado.';
end;

function TfrmFolders.ListaCodigos(
  const ArvoreArquivosY, SolicitacaoX: string; MaxItens: Integer): string;
var
  Dev, Ask, Resp, Y: string;
begin
  // Proteção básica
  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit('');
  end;

  // Evita estourar contexto (ajuste se quiser)
  Y   := Util_ClipText(ArvoreArquivosY, 60000);
  Dev := AF_BuildDevMsg_ListaCodigos;
  Ask := AF_BuildAsk_ListaCodigos(Y, SolicitacaoX, MaxItens);

  if AF_SendToChatGPT(Dev, Ask, FSetMain.CHATGPT, Resp) then
  begin
    // Embeleza se for JSON válido; caso contrário, devolve bruto
    Result := AF_BeautifyJson(Resp);
    if Result = '' then
      Result := Resp;
  end
  else
  begin
    // Se falhar, retorna a resposta de erro da API (geralmente JSON também)
    Result := Resp;
  end;
end;

function TfrmFolders.ParseArquivosRecomendadosJSON(
  const JSONText: string; Dest: TStrings;
  out Solicitacao, Observacoes: string): Integer;
var
  Parser: TJSONParser;
  Data: TJSONData;
  Obj, ItemObj: TJSONObject;
  Arr: TJSONArray;
  i: Integer;
  itemJson: string;
begin
  Result := 0;
  Solicitacao := '';
  Observacoes := '';

  if Dest <> nil then
    Dest.Clear;

  if Trim(JSONText) = '' then Exit;

  try
    Parser := TJSONParser.Create(JSONText);
    try
      Data := Parser.Parse;
      try
        if (Data = nil) or (Data.JSONType <> jtObject) then Exit;
        Obj := TJSONObject(Data);

        Solicitacao := Obj.Get('solicitacao', '');
        Observacoes := Obj.Get('observacoes', '');

        if Obj.Find('arquivos_recomendados', Arr) and (Arr <> nil) then
        begin
          for i := 0 to Arr.Count - 1 do
          begin
            if Arr.Items[i].JSONType = jtObject then
            begin
              ItemObj := TJSONObject(Arr.Items[i]);
              // JSON compacto do item (uma linha)
              itemJson := ItemObj.AsJSON;   // fpjson gera JSON sem quebras
              if (itemJson <> '') and (Dest <> nil) then
              begin
                Dest.Add(itemJson);
                Inc(Result);
              end;
            end;
          end;
        end;
      finally
        Data.Free;
      end;
    finally
      Parser.Free;
    end;
  except
    on E: Exception do
      MessageHint('Falha ao processar JSON da lista: ' + E.Message);
  end;
end;

function TfrmFolders.ExtractPathFromItemJSON(const ItemJSON: string): string;
var
  P: TJSONParser;
  D: TJSONData;
  O: TJSONObject;
begin
  Result := '';
  if Trim(ItemJSON) = '' then Exit;
  try
    P := TJSONParser.Create(ItemJSON);
    try
      D := P.Parse;
      try
        if (D <> nil) and (D.JSONType = jtObject) then
        begin
          O := TJSONObject(D);
          Result := O.Get('path', '');
        end;
      finally
        D.Free;
      end;
    finally
      P.Free;
    end;
  except
    // silencioso
  end;
end;




end.

