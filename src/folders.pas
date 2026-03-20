unit folders;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ShellCtrls,
  ExtCtrls, Menus, StdCtrls, GifAnim, untsalesSwitch, funcoes, hint, setmain,
  chatgpt, Types, StrUtils, LConvEncoding, base, DateUtils, LazFileUtils,
  fpjson, jsonparser, jsonscanner, Math, uDocText , uPdfText;

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
    meTecnica: TMemo;
    meResposta: TMemo;
    miAnalisaArquivo: TMenuItem;
    Panel7: TPanel;
    pbScanning: TProgressBar;
    pnScanner: TPanel;
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
    TabSheet1: TTabSheet;
    tsTecnica: TTabSheet;
    tsFolders: TTabSheet;
    tsIA: TTabSheet;

    procedure btScannerClick(Sender: TObject);
    procedure btIAClick(Sender: TObject);
    procedure edFolderKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);

    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure meTecnicaChange(Sender: TObject);
    procedure miAnalisaArquivoClick(Sender: TObject);
    procedure miCreatedirClick(Sender: TObject);
    procedure miDeleteClick(Sender: TObject);
    procedure mirefreshClick(Sender: TObject);
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure ShellTreeView1Changing(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure ShellTreeView1GetSelectedIndex(Sender: TObject; Node: TTreeNode);
  private
     ArvoreDiretorios : widestring;
     Projeto : string;
     Arquivos : TStringList;
     AnaliseArquivo: TStringList; // << novo

     function Util_ClipText(const S: string; MaxChars: Integer): string;
     function AF_BuildDevMsg_ListaCodigos: widestring;

     // === Helpers usadas por AnalisaFonte (sem aninhar) ===
     function  AF_LoadTextLimited(const Path: string ): widestring;
     function  AF_AddLineNumbers(const S: string): string;
     function  AF_GuessLanguageByExt(const Ext: string): string;
     function  AF_BuildDevMsg: string;
     function  AF_BuildAsk(const Fonte, Linguagem, SrcNum: string): string;
     function  AF_SendToChatGPT(const DevMsg, Ask, Token: widestring; out Resp: widestring): Boolean;
     function  AF_BeautifyJson(const Resp: string): string;
     function AF_BuildAsk_ListaCodigos(
                const ArvoreY, SolicitacaoX: widestring; MaxItens: Integer): widestring;
     function ParseArquivosRecomendadosJSON(
      const JSONText: widestring; Dest: TStrings;
      out Solicitacao, Observacoes: widestring): Integer;
     function ClipForAsk(const S: string; Max: Integer = 15000): string;
     function ExtractPathFromItemJSON(const ItemJSON: string): string;

     // ==== IA helpers / etapas ====
    function IA_GerarDevPrompt(const Pergunta: string): string;

    // NOVO: resumo fixo do arquivo (.RIA) – independente da pergunta
    function IA_ResumoArquivoBase(const FullPath, RelPath: string;
      force: boolean; out Resumo: string): Boolean;

    // Orquestrador: chama resumo base (.RIA) + análise por pergunta (.PIA)
    function IA_ResumoArquivo(const Pergunta, FullPath, RelPath: string;
      force: boolean; out Resumo: string): Boolean;

    // Agora: análise orientada à pergunta, gravada em .PIA e SEM cache de leitura
    function IA_PontosImportantes(const Pergunta, FullPath, RelPath: string;
      force: boolean; out Resumo: string): Boolean;

    function PreparaListasAnaliseSuplementar(const Pergunta, FullPath, RelPath: string;
      force: boolean; out Resumo: string): Boolean;
    function IA_RespostaFinal(const DevPadrao, solicit: string): string;
    function IA_GeraMapaMental(const Texto, Questao: string): string; // << novo

    // ==== Fluxo principal quebrado ====
    procedure UI_Step(const Titulo: string; Posicao: Integer);
    function Recomendacoes_FromPergunta(const Pergunta: widestring; out solicit, obs: widestring): Integer;
    function ResolveFullPath(const RelPath: string): string;
    function DentroDaRaiz(const FullPath: string): Boolean;
    procedure PreparaListasAnalise;

    procedure VarreArquivosEProduzResumos(const Pergunta: string );
    procedure Log_Resultado(const solicit: string; qtd: Integer; const obs: string);

    procedure VarreArquivosEAchaSQL(const Pergunta: string );
    function ResolveFsIdFromRelPath(const RelPath, FullPath: string): Integer;


    // ==== NOVOS HELPERS PARA BuscaTermos ====
    function BT_BuildDevMsg: string;
    function BT_BuildAsk(const Pergunta, Arvore: string): string;
    function ParseBuscaTermosJSON(const JSONText: string; out DoSearch: Boolean;
                                  Terms, Files: TStrings; out Obs: string): Boolean;
    procedure BT_ScanFileForTerms(const RelPath: string; const Terms: TStrings);

    // ==== NOVOS HELPERS DE CAMINHO (cross-platform) ====
    function IsAbsolutePathPortable(const P: string): Boolean;
    function NormalizeRelPath(const P: string): string;
    function NormalizeAndExpand(const P: string): string;

    // ==== NOVOS HELPERS DE CACHE .RIA ====
    function ArquivoEhDoDia(const AFileName: string): Boolean;
    function FonteMudouAposCache(const FonteArquivo, CacheArquivo: string): Boolean;
    procedure ExcluiCacheSeFonteMudou(const FonteArquivo, CacheArquivo: string);

   public

     // <<< NOVO FLAG PÚBLICO >>>
     // Se True, força regerar o .RIA mesmo que já exista.
     // Valor padrão: False (inicializado no FormCreate).
     flagMudanca: Boolean;

     procedure ApagaRIA;
     function  Scanner(const Root: string): TStringList;
     procedure AtualizaProjeto;
     procedure LevantamentoDados(const Pergunta: widestring; out DevPadrao, Solicit: widestring; out Qtd: Integer; out Obs: widestring);

     procedure AnalisaFonte(const Fonte: string);
     procedure RegistraTabelas(Fonte: string; json : string);
     procedure AnalisaProjeto();
     function ListaCodigos(const ArvoreArquivosY, SolicitacaoX: widestring; MaxItens: Integer = 25): string;
     function AnalisaFolderIA(Pergunta: string): string;
     function ScannerRaw(const Root: string): TStringList;

     // ==== NOVA PROCEDURE PÚBLICA ====
     procedure BuscaTermos(const Pergunta: string);
     function FileBinNotRead(FullPath : string): boolean;
   end;


var
  frmFolders: TfrmFolders;

implementation

uses  main, IA;

{$R *.lfm}

{ ===== Helpers de caminho (cross-platform) ===== }

function TfrmFolders.IsAbsolutePathPortable(const P: string): Boolean;
var
  S: string;
begin
  S := Trim(P);
  if S = '' then Exit(False);
  {$IFDEF WINDOWS}
  Result :=
    ((Length(S) >= 2) and (S[2] = ':')) or
    AnsiStartsText('\\', S);
  {$ELSE}
  Result := (Length(S) > 0) and (S[1] = '/');
  {$ENDIF}
end;

function TfrmFolders.NormalizeRelPath(const P: string): string;
var
  S: string;
begin
  S := Trim(P);
  S := StringReplace(S, '/', PathDelim, [rfReplaceAll]);
  S := StringReplace(S, '\', PathDelim, [rfReplaceAll]);
  while (Length(S) > 0) and (S[1] = PathDelim) do
    Delete(S, 1, 1);
  while Pos(PathDelim + PathDelim, S) > 0 do
    S := StringReplace(S, PathDelim + PathDelim, PathDelim, [rfReplaceAll]);
  Result := S;
end;

function NormalizePathDelimsCompat(const P: string): string;
var
  S: string;
begin
  S := StringReplace(P, '/', PathDelim, [rfReplaceAll]);
  S := StringReplace(S, '\', PathDelim, [rfReplaceAll]);
  while Pos(PathDelim + PathDelim, S) > 0 do
    S := StringReplace(S, PathDelim + PathDelim, PathDelim, [rfReplaceAll]);
  Result := S;
end;

function ExpandAndNormalizeCompat(const P: string): string;
begin
  Result := NormalizePathDelimsCompat(ExpandFileName(P));
end;

function TfrmFolders.NormalizeAndExpand(const P: string): string;
begin
  Result := ExpandAndNormalizeCompat(P);
end;

{ ===== Helpers de cache .RIA ===== }

function TfrmFolders.ArquivoEhDoDia(const AFileName: string): Boolean;
var
  Dt: TDateTime;
begin
  Result := False;
  if not FileExists(AFileName) then Exit;
  if not FileAge(AFileName, Dt) then Exit;
  Result := SameDate(Dt, Now);
end;

function TfrmFolders.FonteMudouAposCache(const FonteArquivo, CacheArquivo: string): Boolean;
var
  DtFonte, DtCache: TDateTime;
begin
  Result := False;

  if (not FileExists(FonteArquivo)) or (not FileExists(CacheArquivo)) then
    Exit(False);

  if (not FileAge(FonteArquivo, DtFonte)) or (not FileAge(CacheArquivo, DtCache)) then
    Exit(False);

  Result := DtFonte > DtCache;
end;

procedure TfrmFolders.ExcluiCacheSeFonteMudou(const FonteArquivo, CacheArquivo: string);
begin
  if FileExists(CacheArquivo) and FonteMudouAposCache(FonteArquivo, CacheArquivo) then
  begin
    try
      DeleteFile(CacheArquivo);
      meLog.Lines.Append('Cache removido por alteração no fonte: ' + CacheArquivo);
    except
      on E: Exception do
        meLog.Lines.Append('Falha ao remover cache ' + CacheArquivo + ': ' + E.Message);
    end;
  end;
end;

procedure TfrmFolders.ApagaRIA;

  procedure VarreEApaga(const Dir: string);
  var
    SR: TSearchRec;
    code: Integer;
    FullPath: string;
  begin
    code := FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, SR);
    try
      while code = 0 do
      begin
        if (SR.Name <> '.') and (SR.Name <> '..') then
        begin
          FullPath := IncludeTrailingPathDelimiter(Dir) + SR.Name;

          if (SR.Attr and faDirectory) <> 0 then
          begin
            VarreEApaga(FullPath);
          end
          else
          begin
            if SameText(ExtractFileExt(SR.Name), '.RIA') then
            begin
              try
                DeleteFile(FullPath);
                meLog.Lines.Append('RIA apagado: ' + FullPath);
              except
                on E: Exception do
                  meLog.Lines.Append('Falha ao apagar RIA: ' + FullPath + ' -> ' + E.Message);
              end;
            end;
          end;
        end;
        code := FindNext(SR);
      end;
    finally
      FindClose(SR);
    end;
  end;

var
  RootPath: string;
begin
  RootPath := Trim(FSetMain.DefaultFolder);
  if RootPath = '' then
  begin
    MessageHint('DefaultFolder não informado.');
    Exit;
  end;

  RootPath := NormalizeAndExpand(RootPath);

  if not DirectoryExists(RootPath) then
  begin
    MessageHint('Pasta inválida para apagar RIA: ' + RootPath);
    Exit;
  end;

  meLog.Lines.Append('Iniciando limpeza de arquivos .RIA em: ' + RootPath);
  VarreEApaga(RootPath);
  meLog.Lines.Append('Limpeza de arquivos .RIA concluída.');
end;

{ =====================  FS / ID resolução  ===================== }

function TfrmFolders.ResolveFsIdFromRelPath(const RelPath, FullPath: string): Integer;
var
  parts: TStringList;
  i, parentId: Integer;
  dirName, fileName: string;
  rootId: Integer;
begin
  Result := 0;
  if Trim(RelPath) = '' then Exit;

  parts := TStringList.Create;
  try
    parts.Delimiter := '/';
    parts.StrictDelimiter := True;
    parts.DelimitedText := StringReplace(StringReplace(RelPath, '\', '/', [rfReplaceAll]), '//', '/', [rfReplaceAll]);

    if parts.Count = 0 then Exit;

    fileName := parts[parts.Count - 1];
    parts.Delete(parts.Count - 1);

    rootId := dmBase.EnsureRootId;
    parentId := rootId;
    for i := 0 to parts.Count - 1 do
    begin
      dirName := Trim(parts[i]);
      if dirName = '' then Continue;
      parentId := dmBase.EnsureDirUnderParent(parentId, dirName, DateTimeToUnix(Now));
      if parentId = 0 then Exit;
    end;

    dmBase.UpsertFile(parentId, fileName, FullPath);
    Result := dmBase.Buscafs_IDpeloNome(parentId, fileName);
  finally
    parts.Free;
  end;
end;

{ =====================  SQL mapping  ===================== }

procedure TfrmFolders.VarreArquivosEAchaSQL(const Pergunta: string);
var
  i: Integer;
  RelPath, FullPath: widestring;
  Src, Linguagem, SrcNum: widestring;
  DevMsg, Ask, Resp: widestring;
  fsId: Integer;

  function JsonOnly(const S: string): string;
  begin
    Result := Trim(S);
    if (Result <> '') and (Result[1] in [#65279]) then Delete(Result, 1, 1);
  end;

  procedure AplicaJSON(const RespJSON: string; const ARelPath: string; const AFsId: Integer);
  var
    Parser: TJSONParser;
    J: TJSONData;
    O: TJSONObject;
    Arr: TJSONArray;
    k: Integer;
    dbName, tabName, script: string;
    tabelaId: Integer;
  begin
    Parser := TJSONParser.Create(RespJSON, [joUTF8, joIgnoreTrailingComma]);
    try
      J := Parser.Parse;
      try
        if (J=nil) or (J.JSONType<>jtObject) then Exit;
        O := TJSONObject(J);

        if O.Find('tables')<>nil then
        begin
          Arr := O.Arrays['tables'];
          for k := 0 to Arr.Count-1 do
          begin
            dbName := Arr.Objects[k].Get('database','');
            tabName:= Arr.Objects[k].Get('name','');
            if (AFsId>0) and (tabName<>'') then
            begin
              tabelaId := dmBase.EnsureTabela(dbName, tabName, '');
              if tabelaId>0 then
                dmBase.VinculaFsATabela(AFsId, tabelaId);
            end;
          end;
        end;

        if O.Find('creates')<>nil then
        begin
          Arr := O.Arrays['creates'];
          for k := 0 to Arr.Count-1 do
          begin
            dbName := Arr.Objects[k].Get('database','');
            tabName:= Arr.Objects[k].Get('name','');
            script := Arr.Objects[k].Get('script','');
            if (AFsId>0) and (tabName<>'') then
            begin
              tabelaId := dmBase.EnsureTabela(dbName, tabName, script);
              if tabelaId>0 then
                dmBase.VinculaFsATabela(AFsId, tabelaId);
            end;
          end;
        end;

      finally
        J.Free;
      end;
    finally
      Parser.Free;
    end;
  end;

begin
  lbName.Caption := 'Varre arquivos e mapeia TABELAS SQL → fs_tabelas';
  Application.ProcessMessages;

  for i := 0 to Arquivos.Count - 1 do
  begin
    RelPath := Trim(ExtractPathFromItemJSON(Arquivos[i]));
    if RelPath = '' then Continue;

    FullPath := ResolveFullPath(RelPath);
    if not DentroDaRaiz(FullPath) then Continue;

    if not FileExists(FullPath) then
    begin
      meLog.Lines.Append('PATH: '+FullPath);
      meLog.Lines.Append('Aviso: arquivo não encontrado (SQL).');
      meLog.Lines.Append('');
      Continue;
    end;

    fsId := ResolveFsIdFromRelPath(RelPath, FullPath);

    Src := AF_LoadTextLimited(FullPath);
    if Src = '' then
    begin
      meLog.Lines.Append('PATH: '+RelPath);
      meLog.Lines.Append('Aviso: arquivo vazio (SQL).');
      meLog.Lines.Append('');
      Continue;
    end;

    Linguagem := AF_GuessLanguageByExt(ExtractFileExt(FullPath));

    if (Linguagem = 'word') or (Linguagem = 'pdf') then
      Exit;

    SrcNum    := AF_AddLineNumbers(Src);

    DevMsg :=
      'Você é um extrator de metadados SQL. '+
      'Responda ESTRITAMENTE em JSON puro (sem markdown). '+
      'Formato: {"tables":[{"database":"","name":""},...],"creates":[{"database":"","name":"","script":""},...]} '+
      'Se não houver nada, retorne {"tables":[],"creates":[]}';

    Ask :=
      'Extrair TABELAS e CREATE TABLE do código a seguir.'+LineEnding+
      'ARQUIVO: '+ExtractFileName(FullPath)+LineEnding+
      'CAMINHO_REL: '+RelPath+LineEnding+
      'LINGUAGEM_ESTIMADA: '+Linguagem+LineEnding+
      '--- CODIGO NUMERADO ---'+LineEnding+
      SrcNum+LineEnding+
      '--- FIM ---';

    if AF_SendToChatGPT(DevMsg, Ask, FSetMain.CHATGPT, Resp) then
    begin
      Resp := JsonOnly(Resp);
      try
        AplicaJSON(Resp, RelPath, fsId);
      except
        on E: Exception do
        begin
          meLog.Lines.Append('PATH: '+RelPath);
          meLog.Lines.Append('Falha JSON (SQL): '+E.Message);
          meLog.Lines.Append('Resposta (trecho): '+Copy(Resp,1,800));
          meLog.Lines.Append('');
        end;
      end;
    end
    else
    begin
      meLog.Lines.Append('PATH: '+RelPath);
      meLog.Lines.Append('Falha IA (SQL).');
      meLog.Lines.Append('');
    end;

    Sleep(250);
  end;

  meLog.Lines.Append('--- Mapeamento SQL concluído ---');
end;

function TfrmFolders.ScannerRaw(const Root: string): TStringList;

  procedure Walk(const Dir, Rel: string; SL: TStrings);
  var
    SR: TSearchRec;
    code: Integer;
    P, NewRel: string;
  begin
    code := FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, SR);
    try
      while code = 0 do
      begin
        if (SR.Name <> '.') and (SR.Name <> '..') then
        begin
          P := IncludeTrailingPathDelimiter(Dir) + SR.Name;
          if Rel = '' then
            NewRel := SR.Name
          else
            NewRel := IncludeTrailingPathDelimiter(Rel) + SR.Name;

          if (SR.Attr and faDirectory) <> 0 then
            Walk(P, NewRel, SL)
          else
          begin
            if not (SameText(ExtractFileExt(SR.Name), '.ria') or
                    SameText(ExtractFileExt(SR.Name), '.pia')) then
              SL.Add(NewRel);
          end;
        end;
        code := FindNext(SR);
      end;
    finally
      FindClose(SR);
    end;
  end;

begin
  Result := TStringList.Create;
  if DirectoryExists(Root) then
    Walk(ExpandFileName(Root), '', Result);
end;

procedure TfrmFolders.MenuItem1Click(Sender: TObject);
var
  diretorio : string;
  arquivo   : string;
  fullPath  : string;
begin
  diretorio := ShellTreeView1.Path;
  arquivo   := ShellListView1.Selected.Caption;
  if (arquivo <> '') then
  begin
    fullPath := IncludeTrailingPathDelimiter(diretorio) + arquivo;
    fullPath := NormalizeAndExpand(fullPath);
    frmMNote.FileLoad(fullPath);
  end;
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
  meTecnica.clear;
  if(FSetMain.Project<>'') then
    AtualizaProjeto;

  tree := Scanner(edFolder.Text);
  try
    meLog.Lines.Assign(tree);
    meLog.Lines.Append('');
    meLog.Lines.Append(Format('Total de linhas: %d', [tree.Count]));
  finally
    tree.Free;
  end;
end;

procedure TfrmFolders.meTecnicaChange(Sender: TObject);
begin
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

  dir  := edFolder.Text;
  nome := ShellListView1.Selected.Caption;

  arquivo := IncludeTrailingPathDelimiter(dir) + nome;

  if (not FileExists(arquivo)) and Assigned(ShellListView1.Selected) then
  begin
    try
      arquivo := ShellListView1.Selected.GetNamePath;
    except
    end;
  end;

  if arquivo <> '' then
    arquivo := NormalizeAndExpand(arquivo);

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
        pathfolder := IncludeTrailingPathDelimiter(edFolder.Text) + folder;

        if CreateDir(pathfolder) then
        begin
          MessageHint('Folder '+pathfolder+ ' create successful!');
          ShellTreeView1.refresh;
        end
        else
          MessageHint('Folder '+pathfolder+ ' create fail!');
   end;
end;

procedure TfrmFolders.miDeleteClick(Sender: TObject);
var
  pathfolder : string;
begin
  pathfolder := edFolder.text;

  if ShowConfirm('Confirm delete '+pathfolder+'?') then
  begin
  end;
end;

procedure TfrmFolders.mirefreshClick(Sender: TObject);
begin
  ShellListView1.Update;
end;

procedure TfrmFolders.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  edFolder.text :=  ShellTreeView1.Path;
end;

procedure TfrmFolders.ShellTreeView1Changing(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
end;

procedure TfrmFolders.ShellTreeView1GetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
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
      code := FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, SR);
      while code = 0 do
      begin
        if (SR.Name <> '.') and (SR.Name <> '..') then
        begin
             if (SR.Attr and faDirectory) <> 0 then
               SubDirs.Add(SR.Name)
             else
             begin
               if not (SameText(ExtractFileExt(SR.Name), '.ria') or
                       SameText(ExtractFileExt(SR.Name), '.pia')) then
                 Files.Add(SR.Name);
             end;
        end;
        code := FindNext(SR);
      end;
      FindClose(SR);

      SubDirs.Sort;
      Files.Sort;

      for i := 0 to SubDirs.Count - 1 do
      begin
        hasMore := (i < SubDirs.Count - 1) or (Files.Count > 0);
        AddLine(not hasMore, SubDirs[i], True);
        base := IncludeTrailingPathDelimiter(Dir) + SubDirs[i];
        if hasMore then
          ScanDir(base, Prefix + '│   ', SL)
        else
          ScanDir(base, Prefix + '    ', SL);
      end;

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

    Result.Add('[ROOT] ' + ExpandFileName(rootFixed));
    ScanDir(rootFixed, '', Result);
  except
    on E: Exception do
      Result.Add('*** Erro no Scanner: ' + E.Message + ' ***');
  end;
end;

procedure TfrmFolders.FormCreate(Sender: TObject);
var
  norm: string;
begin
  norm := Trim(FSetMain.DefaultFolder);
  if norm <> '' then
  begin
    norm := NormalizeAndExpand(norm);
    FSetMain.DefaultFolder := norm;
    edFolder.Text := norm;
  end
  else
    edFolder.Text := '';

  if AnaliseArquivo = nil then
    AnaliseArquivo := TStringList.Create
  else
    AnaliseArquivo.Clear;

  if Arquivos = nil then
    Arquivos := TStringList.Create
  else
    Arquivos.Clear;

  flagMudanca := False;

  if ((edFolder.Text = '') or (not ValidateDirectory(edFolder.Text))) then
  begin
    {$IFDEF LINUX}
    ShellTreeView1.Path := ExtractFilePath(Application.ExeName);
    edFolder.Text := ExtractFilePath(Application.ExeName);
    FSetMain.DefaultFolder := edFolder.Text;
    FSetMain.SalvaContexto(False);
    {$ENDIF}
    {$IFDEF WINDOWS}
    ShellTreeView1.Path := ExtractFilePath(Application.ExeName);
    edFolder.Text := ExtractFilePath(Application.ExeName);
    FSetMain.DefaultFolder := edFolder.Text;
    FSetMain.SalvaContexto(False);
    {$ENDIF}
  end;

  ShellTreeView1.Path := edFolder.Text;
end;

procedure TfrmFolders.edFolderKeyPress(Sender: TObject; var Key: char);
begin
  if (key=#13) then
    ShellTreeView1.Path:=edFolder.text;
end;

procedure TfrmFolders.btScannerClick(Sender: TObject);
var
  tree: TStringList;
begin
  tree := Scanner(edFolder.Text);
  try
    meLog.Lines.Assign(tree);
    meLog.Lines.Append('');
    meLog.Lines.Append(Format('Total de linhas: %d', [tree.Count]));
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

  function BuildSmallPreviews(const Root: string; const TreeRaw: TStrings;
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
      for i := 0 to TreeRaw.Count - 1 do
      begin
        Rel := Trim(TreeRaw[i]);
        if (Rel = '') then Continue;

        if not AnsiMatchText(LowerCase(ExtractFileExt(Rel)), ['.pas', '.pp', '.lfm', '.lpr', '.ini', '.json', '.yml', '.yaml','.php','.htm','.js', '.xml', '.c','.cpp','.txt','.doc','.docx','.pdf','.sql','.jsp','.py','.cob','.html','.md' ]) then
          Continue;

        Path := IncludeTrailingPathDelimiter(Root) + Rel;
        if not FileExists(Path) then Continue;

        Inc(cnt);
        if cnt > MaxFiles then Break;

        try
          SL.LoadFromFile(Path);
          Buf := UTF8Encode(SL.Text);
          L := Length(Buf);
          if L > MaxBytesPerFile then
            SetLength(Buf, MaxBytesPerFile);

          Result := Result +
            '--- FILE: ' + Rel + ' ---' + LineEnding +
            UTF8ToString(Buf) + LineEnding + LineEnding;
        except
        end;
      end;
    finally
      SL.Free;
    end;
  end;

var
  TreePretty, TreeRaw: TStringList;
  Chat : TCHATGPT;
  Dev, Prompt, Arvore, Previews, Raiz: widestring;
begin
  TreePretty := Scanner(edFolder.Text);
  TreeRaw    := ScannerRaw(edFolder.Text);
  try
    Raiz   := edFolder.Text;
    Arvore := TreePretty.Text;
    ArvoreDiretorios := Arvore;

    meLog.Lines.Append('');
    meLog.Lines.Append('Arvore de diretorios');
    meLog.Lines.Append(ArvoreDiretorios);
    meLog.Lines.Append('');

    Previews := BuildSmallPreviews(Raiz, TreeRaw, 12, 8000);

    Dev :=
      'Voce é uma IA de respostas sintéticas, sua tarefa é responder de forma direta.' + LineEnding +
      'Responda de forma concisa e estruturada. '+ LineEnding +
      'Assuma que voce terá acesso a todas as informações necessarias.';

    Prompt :=
      'Raiz do projeto: ' + Raiz + LineEnding + LineEnding +
      '--- ÁRVORE DE DIRETÓRIOS (exibição) ---' + LineEnding +
      Arvore + LineEnding +
      '--- TRECHOS DE ARQUIVOS (amostra a partir de caminhos reais) ---' + LineEnding +
      IfThen(Previews <> '', Previews, '(sem prévias)') + LineEnding +
      '--- PEDIDO ---' + LineEnding +
      '- Avalie a seguinte pergunta: ' + mePergunta.Text + LineEnding;

    Chat := TCHATGPT.Create(Self);
    try
      Chat.TOKEN := FSetMain.CHATGPT;
      Chat.Dev   := Dev;

      if Chat.SendQuestion(Prompt) then
        meLog.Lines.Append(Chat.Response)
      else
        meLog.Lines.append('Erro ao consultar IA: ' + Chat.Response);
    finally
      Projeto := meLog.Lines.Text;
      Chat.Free;
    end;
  finally
    TreePretty.Free;
    TreeRaw.Free;
  end;
end;

function TfrmFolders.ClipForAsk(const S: string; Max: Integer = 15000): string;
begin
  if Length(S) <= Max then
    Exit(S);
  Result := Copy(S, 1, Max) + LineEnding + '... (corte aplicado para caber no prompt)';
end;

function TfrmFolders.IA_GerarDevPrompt(const Pergunta: string): string;
var
  DevMsg, Ask, Resp: widestring;
begin
  DevMsg := 'Voce é um analista de IA, sua função é criar um prompt. ' +
            'Com base na Arvore de diretorio e na pergunta apresentada, monte uma pergunta.';

  Ask    := 'PERGUNTA:' + Pergunta + LineEnding +
            ' Arvore diretorio:'+
            ArvoreDiretorios  + LineEnding +
            ' Com base na pergunta crie um prompt para guiar a IA como ela deve se comportar perante o que se quer.';
  Result := '';
  Result := DevMsg+ ask;
end;

{ === NOVA FUNÇÃO: RESUMO BASE (.RIA), INDEPENDENTE DA PERGUNTA === }

function TfrmFolders.IA_ResumoArquivoBase(const FullPath, RelPath: string;
  force: boolean; out Resumo: string): Boolean;
var
  Src, SrcNum, Linguagem: widestring;
  DevMsg, Ask, Resp: widestring;
  Arquivo : TStringList;
  PathNorm, RIAPath: string;
begin
  Resumo := '';
  Result := False;

  PathNorm := NormalizeAndExpand(FullPath);
  RIAPath  := PathNorm + '.RIA';

  // se o fonte mudou depois do cache, apaga o .RIA antes de decidir reutilizar
  ExcluiCacheSeFonteMudou(PathNorm, RIAPath);

  // reaproveita apenas se:
  // 1) existir .RIA
  // 2) não forçado
  // 3) flagMudanca = False
  // 4) .RIA for de hoje
  if FileExists(RIAPath) and (not force) and (not flagMudanca) and ArquivoEhDoDia(RIAPath) then
  begin
    Arquivo := TStringList.Create;
    try
      Arquivo.LoadFromFile(RIAPath);
      Resumo := Arquivo.Text;
      meLog.Lines.Append('Resumo reutilizado do cache .RIA: ' + RIAPath);
    finally
      Arquivo.Free;
    end;
    Exit(True);
  end;

  try
    Src := AF_LoadTextLimited(PathNorm);
  except
    MessageHint('Erro ao abrir arquivo: ' + PathNorm);
    Exit(False);
  end;

  if Src = '' then
  begin
    Resumo := 'Aviso: arquivo vazio ou leitura falhou.';
    Exit(False);
  end;

  Linguagem := AF_GuessLanguageByExt(ExtractFileExt(PathNorm));
  SrcNum    := AF_AddLineNumbers(Src);

  DevMsg :=
    'Você é um analisador técnico de arquivos de código e texto.' + LineEnding +
    'Responda em TEXTO SIMPLES (sem JSON, sem markdown).' + LineEnding +
    'Descreva o que o arquivo faz, principais responsabilidades, entradas/saídas e regras de negócio.';

  Ask :=
    'RESUMO TÉCNICO DO ARQUIVO (INDEPENDENTE DE PERGUNTA).' + LineEnding +
    'ARQUIVO: ' + ExtractFileName(PathNorm) + LineEnding +
    'CAMINHO RELATIVO: ' + RelPath + LineEnding +
    'LINGUAGEM (estimada): ' + Linguagem + LineEnding +
    '--- CÓDIGO/TEXTO COM LINHAS ---' + LineEnding +
    SrcNum + LineEnding +
    '--- FIM ---' + LineEnding +
    'TAREFA:' + LineEnding +
    '- Escreva um RESUMO TÉCNICO em português, o mais detalhado possível, sobre o conteúdo deste arquivo.' + LineEnding +
    '- Explique finalidade, principais funções/métodos/estruturas e pontos críticos.' + LineEnding +
    '- Se aplicável, cite dependências internas/externas de forma breve.' + LineEnding +
    '- Não inclua JSON, markdown, etiquetas ou códigos. Apenas texto corrido.';

  if AF_SendToChatGPT(DevMsg, Ask, FSetMain.CHATGPT, Resp) then
  begin
    Resumo := Trim(Resp);
    Arquivo := TStringList.Create;
    try
      Arquivo.Clear;
      Arquivo.Append('Arquivo:' + ExtractFilePath(PathNorm));
      Arquivo.Append('FullPath:' + PathNorm);
      Arquivo.Append('Criado em:' + DateTimeToStr(Now));
      Arquivo.Append(Resumo);
      Arquivo.SaveToFile(RIAPath);
      meLog.Lines.Append('Resumo .RIA gerado: ' + RIAPath);
    finally
      Arquivo.Free;
    end;
    Result := True;
  end
  else
  begin
    Resumo := 'Falha ao consultar a IA para o resumo do arquivo.';
    Result := False;
  end;
end;

function TfrmFolders.IA_ResumoArquivo(const Pergunta, FullPath, RelPath: string;
  force: boolean; out Resumo: string): Boolean;
var
  ResRIA, ResPIA: string;
  okRIA, okPIA: Boolean;
begin
  Resumo := '';

  okRIA := IA_ResumoArquivoBase(FullPath, RelPath, force, ResRIA);
  okPIA := IA_PontosImportantes(Pergunta, FullPath, RelPath, True, ResPIA);

  if not okRIA then
    ResRIA := ResRIA;
  if not okPIA then
    ResPIA := ResPIA;

  Resumo :=
    '--- RESUMO DO ARQUIVO (.RIA) ---' + LineEnding +
    ResRIA + LineEnding + LineEnding +
    '--- ANÁLISE PARA A PERGUNTA (.PIA) ---' + LineEnding +
    ResPIA;

  Result := okRIA or okPIA;
end;

function TfrmFolders.IA_PontosImportantes(const Pergunta, FullPath, RelPath: string;
  force: boolean; out Resumo: string): Boolean;
var
  Src, SrcNum, Linguagem: widestring;
  DevMsg, Ask, Resp: widestring;
  Arquivo : TStringList;
  PathNorm, PIAPath: string;
begin
  Resumo := '';
  Result := False;

  PathNorm := NormalizeAndExpand(FullPath);
  PIAPath  := PathNorm + '.PIA';

  Src := AF_LoadTextLimited(PathNorm);
  if Src = '' then
  begin
    Resumo := 'Aviso: arquivo vazio ou leitura falhou.';
    Exit(False);
  end;

  Linguagem := AF_GuessLanguageByExt(ExtractFileExt(PathNorm));
  SrcNum    := AF_AddLineNumbers(Src);
  frmMNote.FileLoad(PathNorm);

  DevMsg :=
    'Você é um analisador técnico. Responda em TEXTO SIMPLES (sem JSON, sem markdown).' + LineEnding +
    'Colete as informações importantes deste arquivo para o levantamento do problema e posterior resposta.';

  Ask :=
    'PERGUNTA GERAL: ' + Pergunta + LineEnding +
    'ARQUIVO: ' + ExtractFileName(PathNorm) + LineEnding +
    'CAMINHO RELATIVO: ' + RelPath + LineEnding +
    'LINGUAGEM (estimada): ' + Linguagem + LineEnding +
    '--- CÓDIGO COM LINHAS ---' + LineEnding +
    SrcNum + LineEnding +
    '--- FIM ---' + LineEnding +
    'TAREFA:' + LineEnding +
    '- Levante os pontos importantes deste código que serão usados para responder a pergunta, seja o mais detalhista possível, em português.' + LineEnding +
    '- Explique de forma que seja fácil de entender a importância do fonte para a pergunta.' + LineEnding +
    '- Se necessário, mostre pequenos fragmentos do código para contextualizar.' + LineEnding +
    '- Apenas texto corrido, sem JSON ou markdown.';

  if AF_SendToChatGPT(DevMsg, Ask, FSetMain.CHATGPT, Resp) then
  begin
    Resumo := Trim(Resp);
    Arquivo := TStringList.Create;
    try
      Arquivo.Clear;
      Arquivo.Append('Arquivo:' + ExtractFilePath(PathNorm));
      Arquivo.Append('FullPath:' + PathNorm);
      Arquivo.Append('Pergunta:' + Pergunta);
      Arquivo.Append('Criado em:' + DateTimeToStr(Now));
      Arquivo.Append(Resumo);
      Arquivo.SaveToFile(PIAPath);
    finally
      Arquivo.Free;
    end;
    Result := True;
  end
  else
  begin
    Resumo := 'Falha ao consultar a IA para este arquivo (análise por pergunta).';
    Result := False;
  end;
end;

function TfrmFolders.PreparaListasAnaliseSuplementar(const Pergunta, FullPath, RelPath: string; force: boolean; out Resumo: string): Boolean;
begin
  Resumo := '';
  Result := False;
end;

function TfrmFolders.IA_GeraMapaMental(const Texto, Questao: string): string;
var
  DevMsg, Ask, Resp: widestring;
begin
  DevMsg :=
    'Você é um especialista em síntese. ' +
    'Seu trabalho é construir um MAPA MENTAL textual (ASCII) somente com os pontos RELEVANTES para a QUESTÃO. ' +
    'Ignore informações irrelevantes. ' +
    'Formato: uma árvore com tópicos e subtópicos usando hífens e indentação. ' +
    'Sem markdown, sem JSON, apenas texto puro.';

  Ask :=
    'QUESTÃO: ' + Questao + LineEnding +
    '--- INFORMAÇÕES DISPONÍVEIS ---' + LineEnding +
    Texto + LineEnding +
    '--- FIM ---' + LineEnding +
    'TAREFA:' + LineEnding +
    '- Construa um mapa mental objetivo, apenas com itens que ajudam diretamente a responder a QUESTÃO.' + LineEnding +
    '- Remova redundâncias e ruídos. Nada de listas gigantes; foque no essencial.';

  Result := '';
  if AF_SendToChatGPT(DevMsg, Ask, FSetMain.CHATGPT, Resp) then
    Result := Trim(Resp);
end;

function TfrmFolders.IA_RespostaFinal(const DevPadrao, solicit: string): string;

  function SplitIntoChunks(const S: string; MaxChunk: Integer): TStringList;
  var
    i, l: Integer;
    piece: string;
  begin
    Result := TStringList.Create;
    l := Length(S);
    i := 1;
    while i <= l do
    begin
      piece := Copy(S, i, MaxChunk);
      Result.Add(piece);
      Inc(i, MaxChunk);
    end;
  end;

  function SummarizeChunk(const DevMsg, PromptPrefix, Chunk: string; out OutText: string): Boolean;
  var
    Ask, Resp: widestring;
  begin
    Ask :=
      PromptPrefix + LineEnding +
      '--- TRECHO ---' + LineEnding +
      ClipForAsk(Chunk, 15000) + LineEnding +
      '--- FIM TRECHO ---' + LineEnding +
      'TAREFA:' + LineEnding +
      '- Produza um resumo técnico conciso (5–8 linhas) do trecho acima.' + LineEnding +
      '- Português, sem listas, sem markdown.';
    Result := AF_SendToChatGPT(DevMsg, Ask, FSetMain.CHATGPT, Resp);
    if Result then OutText := Trim(Resp) else OutText := '';
  end;

  function ReduceSummaries(const DevMsg, Solicitacao: string; const Partes: TStrings): string;
  var
    i: Integer;
    Acum, Ask, Resp: widestring;
  begin
    Acum := '';
    for i := 0 to Partes.Count - 1 do
      Acum := Acum + Format('[RESUMO %d]%s%s%s', [i+1, LineEnding, Partes[i], LineEnding]) + LineEnding;

    Ask :=
      'Você receberá resumos parciais de arquivos analisados. ' + LineEnding +
      'Com base neles, responda APENAS à solicitação a seguir com objetividade.' + LineEnding +
      '--- RESUMOS PARCIAIS ---' + LineEnding +
      ClipForAsk(Acum, 60000) + LineEnding +
      '--- FIM RESUMOS ---' + LineEnding +
      'SOLICITAÇÃO:' + LineEnding +
      Solicitacao;

    if AF_SendToChatGPT(DevMsg, Ask, FSetMain.CHATGPT, Resp) then
      Result := Trim(Resp)
    else
      Result := '';
  end;

var
  DevMsg, Ask, Resp: widestring;
  Contexto: widestring;
  Chunks, Resumos: TStringList;
  i: Integer;
  tmp: string;
begin
  if (DevPadrao <> '') then
    DevMsg := DevPadrao
  else
    DevMsg :=
      'Você é um analisador técnico. Responda ao que foi perguntado usando os resumos fornecidos.';

  Contexto := AnaliseArquivo.Text;

  if Length(Contexto) <= 14000 then
  begin
    Ask :=
      'INFORMAÇÕES (resumo consolidado dos arquivos analisados):' + LineEnding +
      Contexto + LineEnding + LineEnding +
      'SOLICITAÇÃO:' + LineEnding +
      solicit;

    if AF_SendToChatGPT(DevMsg, Ask, FSetMain.CHATGPT, Resp) then
      Exit(Trim(Resp))
    else
      Exit('');
  end;

  Chunks := SplitIntoChunks(Contexto, 14000);
  Resumos := TStringList.Create;
  try
    for i := 0 to Chunks.Count - 1 do
    begin
      if SummarizeChunk(DevMsg, 'Resumo parcial dos arquivos', Chunks[i], tmp) and (tmp <> '') then
        Resumos.Add(tmp)
      else
        Resumos.Add('(falha ao resumir parte ' + IntToStr(i+1) + ')');
      Sleep(200);
    end;

    Result := ReduceSummaries(DevMsg, solicit, Resumos);
  finally
    Resumos.Free;
    Chunks.Free;
  end;
end;

procedure TfrmFolders.UI_Step(const Titulo: string; Posicao: Integer);
begin
  if Posicao >= 0 then
    pbScanning.Position := Posicao;
  lbName.Caption := Titulo;
  Application.ProcessMessages;
end;

function TfrmFolders.Recomendacoes_FromPergunta(const Pergunta: widestring; out solicit, obs: widestring): Integer;
var
  jsonLista: widestring;
begin
  ArvoreDiretorios := '';
  AnalisaProjeto();

  jsonLista := ListaCodigos(ArvoreDiretorios, Pergunta, 20);

  if Arquivos = nil then
    Arquivos := TStringList.Create
  else
    Arquivos.Clear;

  Result := ParseArquivosRecomendadosJSON(jsonLista, Arquivos, solicit, obs);
end;

function TfrmFolders.ResolveFullPath(const RelPath: string): string;
var
  P, Root: string;
begin
  P := Trim(RelPath);
  if P = '' then Exit('');

  if IsAbsolutePathPortable(P) then
    Exit(NormalizeAndExpand(P));

  P := NormalizeRelPath(P);
  Root := IncludeTrailingPathDelimiter(FSetMain.Defaultfolder);
  Result := NormalizeAndExpand(Root + P);
end;

function TfrmFolders.DentroDaRaiz(const FullPath: string): Boolean;
var
  raiz, alvo: string;
begin
  raiz := NormalizeAndExpand(IncludeTrailingPathDelimiter(FSetMain.Defaultfolder));
  alvo := NormalizeAndExpand(FullPath);
  {$IFDEF WINDOWS}
  Result := AnsiStartsText(AnsiLowerCase(raiz), AnsiLowerCase(alvo));
  {$ELSE}
  Result := AnsiStartsStr(raiz, alvo);
  {$ENDIF}
end;

procedure TfrmFolders.PreparaListasAnalise;
begin
  if AnaliseArquivo = nil then
    AnaliseArquivo := TStringList.Create
  else
    AnaliseArquivo.Clear;
end;

procedure TfrmFolders.VarreArquivosEProduzResumos(const Pergunta: string);
var
  i: Integer;
  RelPath, FullPath: string;
  Resumo: string;
  ext: string;
begin
  UI_Step('Varre os arquivos recomendados e resume cada um', 4);

  for i := 0 to Arquivos.Count - 1 do
  begin
    RelPath := Trim(ExtractPathFromItemJSON(Arquivos[i]));
    if RelPath = '' then
      Continue;

    FullPath := ResolveFullPath(RelPath);
    if not DentroDaRaiz(FullPath) then
      Continue;

    if not FileExists(FullPath) then
    begin
      AnaliseArquivo.Add('PATH: ' + FullPath);
      AnaliseArquivo.Add('Aviso: arquivo não encontrado em disco.');
      AnaliseArquivo.Add('');
      Continue;
    end;

    ext := LowerCase(ExtractFileExt(FullPath));

    if (LowerCase(ext) = '.ria') or (LowerCase(ext) = '.pia') then
    begin
      AnaliseArquivo.Add('PATH: ' + RelPath);
      AnaliseArquivo.Add('Ignorado (cache .RIA/.PIA).');
      AnaliseArquivo.Add('');
      Continue;
    end;

    if FileBinNotRead(FullPath) then
    begin
      AnaliseArquivo.Add('PATH: ' + RelPath);
      AnaliseArquivo.Add('Ignorado (arquivo binário).');
      AnaliseArquivo.Add('');
      Continue;
    end;

    UI_Step('Criando resumo técnico e análise para: ' + RelPath, 5);

    if IA_ResumoArquivo(Pergunta, FullPath, RelPath, False, Resumo) then
    begin
      AnaliseArquivo.Add('PATH: ' + RelPath);
      AnaliseArquivo.Add(Resumo);
      AnaliseArquivo.Add('');
    end
    else
    begin
      AnaliseArquivo.Add('PATH: ' + RelPath);
      AnaliseArquivo.Add(Resumo);
      AnaliseArquivo.Add('');
    end;

    if PreparaListasAnaliseSuplementar(Pergunta, FullPath, RelPath, False, Resumo) then
    begin
      AnaliseArquivo.Add('PATH: ' + RelPath);
      AnaliseArquivo.Add(Resumo);
      AnaliseArquivo.Add('');
    end;

    Sleep(500);
  end;
end;

procedure TfrmFolders.Log_Resultado(const solicit: string; qtd: Integer; const obs: string);
begin
  UI_Step('Log enxuto e útil', 6);
  meLog.Lines.Append('Solicitação: ' + solicit);
  meLog.Lines.Append('Arquivos recomendados (itens): ' + IntToStr(qtd));
  if obs <> '' then
    meLog.Lines.Append('Observações: ' + obs);
  meLog.Lines.Append('');
  meLog.Lines.Append('--- Análises por arquivo ---');
  meLog.Lines.AddStrings(AnaliseArquivo);
  meLog.Lines.Append('-----');

  UI_Step('Pergunta final baseada nas ANÁLISES (NÃO usar meLog inteiro)', 7);
end;

procedure TfrmFolders.LevantamentoDados(const Pergunta: widestring; out DevPadrao, Solicit: widestring; out Qtd: Integer; out Obs: widestring);
begin
  meLog.Lines.Append('Inicia o guia de comportamento');
  meLog.Lines.Append('');
  UI_Step('Gera árvore e sugere arquivos relevantes', 1);
  meLog.Lines.Append('Gera árvore e sugere arquivos relevantes');
  meLog.Lines.Append('');

  meLog.Lines.Append('');
  meLog.Lines.Append('Recomendações a partir da pergunta');
  meLog.Lines.Append('');

  Qtd := Recomendacoes_FromPergunta(Pergunta, Solicit, Obs);
  meLog.Lines.Append('Solicitacoes:'+Solicit);
  meLog.Lines.Append('Observações:'+Obs);
  meLog.Lines.Append('');

  UI_Step('Inicializa a lista de análises', 2);
  meLog.Lines.Append('Inicializa a lista de análises');
  meLog.Lines.Append('');

  UI_Step('PreparaListasAnalise', 2);
  meLog.Lines.Append('PreparaListasAnalise');
  meLog.Lines.Append('');
  PreparaListasAnalise;
  meLog.Lines.Append('');

  UI_Step('Limite de leitura por arquivo', 3);
  meLog.Lines.Append('Limite de leitura por arquivo');
  meLog.Lines.Append('');

  UI_Step('Varre arquivos e gera resumos técnicos', 4);
  meLog.Lines.Append('Varre arquivos e gera resumos técnicos');
  meLog.Lines.Append('');

  VarreArquivosEProduzResumos(Pergunta);

  UI_Step('Busca termos da pergunta', 5);
  meLog.Lines.Append('Busca termos da pergunta');
  meLog.Lines.Append('');
  BuscaTermos(Pergunta);

  UI_Step('Log Resultado', 6);
  meLog.Lines.Append('Log Resultado');
  meLog.Lines.Append('');

  Log_Resultado(Solicit, Qtd, Obs);
end;

function TfrmFolders.AnalisaFolderIA(Pergunta: string): string;
var
  DevPadrao, Solicit, Obs: widestring;
  Qtd: Integer;
  RespFinal: widestring;
  MapaMental: widestring;
  PromptMapa: widestring;
begin
  pbScanning.Position := 0;
  pnScanner.Visible := True;
  Application.ProcessMessages;
  meLog.Clear;
  meTecnica.Clear;
  meLog.Lines.Append('Inicio de Analise pela IA');
  meLog.Lines.Append('');

  LevantamentoDados(Pergunta, DevPadrao, Solicit, Qtd, Obs);

  UI_Step('Gerando mapa mental (apenas itens relevantes)', 7);
  PromptMapa :=
    'Com base nas informações abaixo: ' + meLog.Lines.Text +
    ' atenda esta solicitação (apenas mapeando, não respondendo ainda): ' + Solicit;

  MapaMental := IA_GeraMapaMental(PromptMapa, Solicit);
  if Trim(MapaMental) <> '' then
  begin
    meLog.Lines.Append('');
    meLog.Lines.Append('--- Mapa mental (relevante à questão) ---');
    meLog.Lines.Append(MapaMental);
    meLog.Lines.Append('--- Fim do mapa mental ---');
  end
  else
  begin
    meLog.Lines.Append('');
    meLog.Lines.Append('--- Mapa mental não pôde ser gerado (sem retorno da IA) ---');
  end;

  UI_Step('Pergunta final baseada nas ANÁLISES (NÃO usar meLog inteiro)', 8);
  RespFinal := IA_RespostaFinal(DevPadrao, Solicit);
  if RespFinal <> '' then
  begin
    meLog.Lines.Append('');
    meLog.Lines.Append('--- Resposta final da IA ---');
    meLog.Lines.Append(RespFinal);
  end;

  pnScanner.Visible := False;
  Application.ProcessMessages;
  Result := RespFinal;
end;

procedure TfrmFolders.btIAClick(Sender: TObject);
begin
  meResposta.Lines.append(AnalisaFolderIA(mePergunta.Text));
  frmIA.meHistorico.Lines.Append(meResposta.Lines.text);
end;

procedure TfrmFolders.FormDestroy(Sender: TObject);
begin
  FSetMain.SalvaContexto(False);
  FreeAndNil(AnaliseArquivo);
  FreeAndNil(Arquivos);
end;

procedure TfrmFolders.FormShow(Sender: TObject);
begin
end;

procedure TfrmFolders.AtualizaProjeto;

  function FileMTimeUTC_OrNow(const FullPath: string): Int64;
  var
    dt: TDateTime;
  begin
    if FileAge(FullPath, dt) then
      Result := DateTimeToUnix(dt)
    else
      Result := DateTimeToUnix(Now);
  end;

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
            subId := dmbase.EnsureDirUnderParent(ParentId, childName, FileMTimeUTC_OrNow(full));
            IndexDir(full, subId);
          end
          else
            dmbase.UpsertFile(ParentId, childName, full);
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

  MessageHint('Iniciando indexação no SQLite...');
  if(dmBase = nil) then
    dmBase := Tdmbase.create(self);

  if not dmBase.zconlocal.Connected then
  begin
    if(FSetMain.Project= '') then
    begin
      MessageHint('*** SQLite não conectado (dmBase.zconlocal).');
      Exit;
    end;
  end;

  dmbase.DeleteFS;
  RootPath := Trim(FSetMain.DefaultFolder);
  if (RootPath = '') or (not DirectoryExists(RootPath)) then
  begin
    MessageHint('*** Pasta inválida: ' + RootPath);
    Exit;
  end;
  RootPath := NormalizeAndExpand(RootPath);

  dmBase.zconlocal.AutoCommit := False;
  try
    RootFSId := dmbase.EnsureRootId;
    IndexDir(RootPath, RootFSId);
    dmBase.zconlocal.Commit;
    MessageHint('Indexação concluída com sucesso.');
  except
    on E: Exception do
    begin
      dmBase.zconlocal.Rollback;
      MessageHint('*** Falha na indexação: ' + E.Message);
    end;
  end;
  dmBase.zconlocal.AutoCommit := True;
  pnScanner.Visible:= false;
  Application.ProcessMessages;
end;

procedure TfrmFolders.AnalisaFonte(const Fonte: string);
var
  Src, SrcNum, DevMsg, Ask, Resp, Beautified, Linguagem: widestring;
begin
  meLog.Clear;
  meLog.Lines.Append('Analisando: ' + Fonte);

  Src := AF_LoadTextLimited(Fonte);
  if Src = '' then
  begin
    MessageHint('Arquivo vazio ou não foi possível ler.');
    Exit;
  end;

  Linguagem := AF_GuessLanguageByExt(ExtractFileExt(Fonte));
  SrcNum    := AF_AddLineNumbers(Src);

  DevMsg := AF_BuildDevMsg;
  Ask    := AF_BuildAsk(Fonte, Linguagem, SrcNum);

  if not AF_SendToChatGPT(DevMsg, Ask, FSetMain.CHATGPT, Resp) then
  begin
    meLog.Lines.Append('Falha ao consultar a IA.');
    Exit;
  end;

  Beautified := AF_BeautifyJson(Resp);
  if Beautified = '' then
    Beautified := Resp;

  RegistraTabelas(Fonte, Beautified);
end;

function TfrmFolders.AF_LoadTextLimited(const Path: string): widestring;
var
  normPath: string;
begin
  Result := '';
  normPath := NormalizeAndExpand(Path);
  if not FileExists(normPath) then Exit;

  try
    frmMNote.FileLoad(normPath);
    Result := frmMNote.GetFile(normPath);
  except
    on E: Exception do
    begin
      Result := '';
      MessageHint('Erro ao carregar arquivo para análise: ' + E.Message);
    end;
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
    '.pdf'               :   Exit('pdf');
    '.doc', '.docx', '.odt' :Exit('word');
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
  const DevMsg, Ask, Token: widestring; out Resp: widestring): Boolean;
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
      meTecnica.Lines.Append(Resp);
      frmIA.meHistorico.Lines.Append(Resp);
      Result := True;
    end
    else
      Resp := Chat.Response;
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
  normFonte: string;
  iddir , id : integer;

  procedure ReplaceDebugMarkers(var S: string);
  begin
    p1 := Pos('{', S);
    p2 := RPos('}', S);
    if (p1 > 0) and (p2 >= p1) then
      S := Copy(S, p1, p2 - p1 + 1);

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
  normFonte := NormalizeAndExpand(Fonte);
  caminho := ExtractFilePath(normFonte);
  if (caminho <> '') and (caminho[Length(caminho)] in ['/', '\']) then
     Delete(caminho, Length(caminho), 1);
  arquivo := ExtractFileName(normFonte);
  extensao:= ExtractFileExt(normFonte);

  Clean := json;
  ReplaceDebugMarkers(Clean);

  Parser := TJSONParser.Create(Clean);
  try
    Data := Parser.Parse;
    try
      if Data.JSONType <> jtObject then
        raise Exception.Create('JSON raiz não é objeto.');
      Obj := TJSONObject(Data);

      SLUsadas        := TStringList.Create;
      SLRelacionadas  := TStringList.Create;
      SLFontes        := TStringList.Create;
      try
        FillListFromArray('tabela_usada',        SLUsadas);
        FillListFromArray('tabela_relacionada',  SLRelacionadas);
        FillListFromArray('fontes_vinculados',   SLFontes);
        Resumo := Obj.Get('resumo', '');

        meLog.Lines.Append('--- Resultado de ' + arquivo + ' ---');
        meLog.Lines.Append('resumo: ' + Resumo);

        meLog.Lines.Append('tabela_usada:');
        for i := 0 to SLUsadas.Count-1 do meLog.Lines.Append('  - ' + SLUsadas[i]);

        meLog.Lines.Append('tabela_relacionada:');
        for i := 0 to SLRelacionadas.Count-1 do meLog.Lines.Append('  - ' + SLRelacionadas[i]);

        meLog.Lines.Append('fontes_vinculados:');
        for i := 0 to SLFontes.Count-1 do meLog.Lines.Append('  - ' + SLFontes[i]);

        iddir := dmbase.Buscafs_IDpeloDiretorio(caminho);
        if (iddir<>0) then
        begin
            id := dmbase.Buscafs_IDpeloNome (iddir, arquivo);
            if (id <> 0) then
              dmbase.AtualizarResumo(id, Resumo)
            else
              MessageHint('Arquivo nao encontrado na base');
        end;

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

function TfrmFolders.AF_BuildDevMsg_ListaCodigos: widestring;
begin
  Result :=
    'Você é um assistente técnico de engenharia de software.' + LineEnding +
    'Sua tarefa é, dada uma ÁRVORE DE ARQUIVOS  e uma SOLICITAÇÃO/OBJETIVO,' + LineEnding +
    'selecionar o ou os arquivos  relevantes para análise a fim de atender a solicitacao.' + LineEnding +
    'REGRAS:' + LineEnding +
    '- Responda ESTRITAMENTE em JSON válido UTF-8.' + LineEnding +
    '- Não use markdown, cabeçalhos, comentários ou textos fora do JSON.' + LineEnding +
    '- A lista deve conter **apenas** caminhos que existam na Arvore de arquivos.' + LineEnding +
    '- Priorize pontos de entrada, módulos de regra de negócio, camadas de dados, configuração e testes-alvo.' + LineEnding +
    '- Evite binários/mídias e arquivos obviamente irrelevantes.' + LineEnding +
    '- Limite-se ao número máximo solicitado.' + LineEnding +
    '' + LineEnding +
    'FORMATO DO JSON:' + LineEnding +
    '{' + LineEnding +
    '  "solicitacao": "<eco da solicitacao>",' + LineEnding +
    '  "arquivos_recomendados": [' + LineEnding +
    '    {"path": "<caminho relativo conforme a Arvore de Diretórios>", "motivo": "<por que este arquivo>", "prioridade": <1-n>} ' + LineEnding +
    '  ],' + LineEnding +
    '  "observacoes": "<opcional, breves notas ou lacunas>"' + LineEnding +
    '}';
end;

function TfrmFolders.AF_BuildAsk_ListaCodigos(
  const ArvoreY, SolicitacaoX: widestring; MaxItens: Integer): widestring;
begin
  Result :=
    'SOLICITACAO: ' + SolicitacaoX + LineEnding + LineEnding +
    'LIMITE_MAX_ITENS: ' + IntToStr(MaxItens) + LineEnding + LineEnding +
    '--- ARVORE DE ARQUIVOS---' + LineEnding +
    ArvoreDiretorios + LineEnding +
    '--- FIM ARVORE ---' + LineEnding + LineEnding +
    'TAREFA:' + LineEnding +
    '- Selecione os arquivos da "ARVORE DE ARQUIVOS" relevantes para atender solicitação.' + LineEnding +
    '- Mantenha caminhos exatamente como aparecem na "ARVORE DE ARQUIVOS".' + LineEnding +
    '- Ordene por "prioridade" (1 = mais importante).' + LineEnding +
    '- Responda apenas no formato JSON especificado.';
end;

function TfrmFolders.ListaCodigos(
  const ArvoreArquivosY, SolicitacaoX: widestring; MaxItens: Integer): string;
var
  Dev, Ask, Resp: widestring;
begin
  if Trim(FSetMain.CHATGPT) = '' then
  begin
    ShowMessage('Configure o token do ChatGPT em SetMain.CHATGPT.');
    Exit('');
  end;

  Dev := AF_BuildDevMsg_ListaCodigos;
  Ask := AF_BuildAsk_ListaCodigos(ArvoreArquivosY, SolicitacaoX, MaxItens);

  if AF_SendToChatGPT(Dev, Ask, FSetMain.CHATGPT, Resp) then
  begin
    Result := Resp;
    if Result = '' then
      Result := Resp;
  end
  else
    Result := Resp;
end;

function TfrmFolders.ParseArquivosRecomendadosJSON(
  const JSONText: widestring; Dest: TStrings;
  out Solicitacao, Observacoes: widestring): Integer;
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

  if Trim(JSONText) = '' then
    Exit;

  try
    Parser := TJSONParser.Create(JSONText);
    try
      Data := Parser.Parse;
      try
        if (Data = nil) or (Data.JSONType <> jtObject) then
          Exit;

        Obj := TJSONObject(Data);

        Solicitacao := Obj.Get('solicitacao', '');
        Observacoes := Obj.Get('observacoes', '');

        Arr := nil;
        if Obj.Find('arquivos_recomendados', Arr) and (Arr <> nil) then
        begin
          for i := 0 to Arr.Count - 1 do
          begin
            if Arr.Items[i].JSONType = jtObject then
            begin
              ItemObj := TJSONObject(Arr.Items[i]);
              itemJson := ItemObj.AsJSON;
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
    begin
      MessageHint('Falha ao processar JSON da lista: ' + E.Message);
      if Dest <> nil then
        Dest.Clear;
      Result := 0;
      Solicitacao := '';
      Observacoes := '';
    end;
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
  end;
end;

function TfrmFolders.BT_BuildDevMsg: string;
begin
  Result :=
    'Você é um assistente técnico para varredura de código.'+LineEnding+
    'Responda ESTRITAMENTE em JSON UTF-8, sem markdown e sem texto fora do JSON.'+LineEnding+
    'Campos esperados:' + LineEnding+
    '{' + LineEnding+
    '  "busca_termos": true|false,' + LineEnding+
    '  "termos": ["palavra1","palavra2",...],' + LineEnding+
    '  "arquivos": ["caminho/relativo/arquivo1.ext","caminho/relativo/arquivo2.ext",...],' + LineEnding+
    '  "observacoes": "opcional"' + LineEnding+
    '}' + LineEnding+
    'Se não houver termos a buscar, retorne "busca_termos": false.';
end;

function TfrmFolders.BT_BuildAsk(const Pergunta, Arvore: string): string;
begin
  Result :=
    'PERGUNTA/OBJETIVO: ' + Pergunta + LineEnding + LineEnding +
    '--- ARVORE DO PROJETO (exibição) ---' + LineEnding +
    Util_ClipText(Arvore, 60000) + LineEnding +
    '--- FIM ARVORE ---' + LineEnding + LineEnding +
    'TAREFA:' + LineEnding +
    '- Defina se vale a pena executar uma BUSCA POR TERMOS no código (busca_termos).' + LineEnding +
    '- Se sim, proponha uma lista enxuta de "termos" (5 a 25 itens) diretamente ligados ao objetivo.' + LineEnding +
    '- Indique também uma lista de "arquivos" (caminhos relativos) candidatos à busca.' + LineEnding +
    '- Responda somente no JSON especificado (sem comentários).';
end;

function TfrmFolders.ParseBuscaTermosJSON(const JSONText: string; out DoSearch: Boolean;
                                          Terms, Files: TStrings; out Obs: string): Boolean;
var
  P: TJSONParser;
  D: TJSONData;
  O: TJSONObject;
  A: TJSONArray;
  i: Integer;
  entry: string;
begin
  Result := False;
  DoSearch := False;
  Obs := '';
  if Assigned(Terms) then Terms.Clear;
  if Assigned(Files) then Files.Clear;

  if Trim(JSONText) = '' then Exit;

  try
    P := TJSONParser.Create(JSONText, [joUTF8, joIgnoreTrailingComma]);
    try
      D := P.Parse;
      try
        if (D = nil) or (D.JSONType <> jtObject) then Exit;
        O := TJSONObject(D);

        DoSearch := O.Get('busca_termos', False);
        Obs := O.Get('observacoes', '');

        if Assigned(Terms) and O.Find('termos', A) and (A<>nil) then
          for i := 0 to A.Count-1 do
            if A.Items[i].JSONType = jtString then
              Terms.Add(Trim(A.Strings[i]));

        if Assigned(Files) and O.Find('arquivos', A) and (A<>nil) then
          for i := 0 to A.Count-1 do
            if A.Items[i].JSONType = jtString then
            begin
              entry := Trim(A.Strings[i]);
              Files.Add(entry);
            end;

        Result := True;
      finally
        D.Free;
      end;
    finally
      P.Free;
    end;
  except
    on E: Exception do
      MessageHint('Falha ao interpretar JSON de BuscaTermos: ' + E.Message);
  end;
end;

procedure TfrmFolders.BT_ScanFileForTerms(const RelPath: string; const Terms: TStrings);
var
  FullPath: string;
  Content: string;
  SL: TStringList;
  i, t: Integer;
  line: string;

  function ClipAround(const S, Term: string; MaxLen: Integer = 140): string;
  var
    p, startPos, endPos: Integer;
    lowS, lowTerm: string;
  begin
    lowS := AnsiLowerCase(S);
    lowTerm := AnsiLowerCase(Term);
    p := Pos(lowTerm, lowS);
    if p <= 0 then Exit(Util_ClipText(S, MaxLen));
    startPos := Max(1, p - 40);
    endPos   := Min(Length(S), p + Length(Term) + 40);
    Result := Copy(S, startPos, endPos - startPos + 1);
    if startPos > 1 then Result := '...' + Result;
    if endPos < Length(S) then Result := Result + '...';
  end;

begin
  if (Terms = nil) or (Terms.Count = 0) then Exit;

  FullPath := ResolveFullPath(RelPath);
  if not DentroDaRaiz(FullPath) then
  begin
    meLog.Lines.append(Format('[BuscaTermos] Ignorado (fora da raiz): %s', [FullPath]));
    Exit;
  end;

  if not FileExists(FullPath) then
  begin
    meLog.Lines.append(Format('[BuscaTermos] %s: arquivo não encontrado.', [FullPath]));
    Exit;
  end;

  Content := AF_LoadTextLimited(FullPath);
  if Content = '' then
  begin
    meLog.Lines.Append(Format('[BuscaTermos] %s: vazio ou ilegível.', [FullPath]));
    Exit;
  end;

  SL := TStringList.Create;
  try
    SL.Text := Content;

    for i := 0 to SL.Count - 1 do
    begin
      line := SL[i];
      for t := 0 to Terms.Count - 1 do
      begin
        if (Terms[t] <> '') and AnsiContainsText(line, Terms[t]) then
        begin
          meLog.Lines.append(
            Format('[BuscaTermos] termo "%s" em %s (linha %d): %s',
                   [Terms[t], RelPath, i+1, ClipAround(line, Terms[t])]));
        end;
      end;
    end;
  finally
    SL.Free;
  end;
end;

procedure TfrmFolders.BuscaTermos(const Pergunta: string);
var
  Dev, Ask, Resp: widestring;
  Terms, Files: TStringList;
  DoSearch: Boolean;
  Obs: string;
  i: Integer;
begin
  meLog.Lines.Add('=== BuscaTermos: consultando IA para obter termos/arquivos ===');

  if Trim(ArvoreDiretorios) = '' then
  begin
    meLog.Lines.Add('[BuscaTermos] ArvoreDiretorios vazia — execute AnalisaProjeto antes.');
    Exit;
  end;

  Terms := TStringList.Create;
  Files := TStringList.Create;
  try
    Dev := BT_BuildDevMsg;
    Ask := BT_BuildAsk(Pergunta, ArvoreDiretorios);

    if not AF_SendToChatGPT(Dev, Ask, FSetMain.CHATGPT, Resp) then
    begin
      meLog.Lines.Add('[BuscaTermos] Falha ao consultar IA para definição de termos.');
      Exit;
    end;

    if not ParseBuscaTermosJSON(Resp, DoSearch, Terms, Files, Obs) then
    begin
      meLog.Lines.Add('[BuscaTermos] Não foi possível interpretar o JSON retornado.');
      Exit;
    end;

    meLog.Lines.append(
      Format('[BuscaTermos] %d termo(s) e %d arquivo(s) indicados.', [Terms.Count, Files.Count])
    );
    meLog.Lines.append('[BuscaTermos] Observações: ' + Obs);

    if DoSearch and (Terms.Count > 0) and (Files.Count > 0) then
    begin
      meLog.Lines.Add('=== Iniciando varredura de arquivos existentes ===');
      for i := 0 to Files.Count - 1 do
      begin
        meLog.Lines.append(' Pesquisando arquivo ' + Files[i]);
        BT_ScanFileForTerms(Files[i], Terms);
      end;
    end
    else
      meLog.Lines.Add('[BuscaTermos] Busca por termos não autorizada ou listas vazias. Nada a varrer.');

  finally
    Terms.Free;
    Files.Free;
  end;

  meLog.Lines.Append('=== BuscaTermos: varredura concluída ===');
end;

function TfrmFolders.FileBinNotRead(FullPath: string): boolean;
const
  BinExt: array[0..18] of string = (
    '.exe', '.dll', '.jpg', '.jpeg', '.png', '.gif',
    '.bmp', '.avi', '.mp4', '.mp3', '.wav', '.zip',
    '.rar', '.7z', '.xls', '.xlsx', '.bin', '.ria', '.pia'
  );
var
  ext: string;
  FS: TFileStream;
  Buffer: array[0..1023] of Byte;
  ReadBytes, i: Integer;
begin
  Result := False;

  if not FileExists(FullPath) then
  begin
    Result := True;
    Exit;
  end;

  ext := LowerCase(ExtractFileExt(FullPath));

  for i := Low(BinExt) to High(BinExt) do
  begin
    if ext = BinExt[i] then
    begin
      Result := True;
      Exit;
    end;
  end;

  try
    FS := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
    try
      ReadBytes := FS.Read(Buffer, SizeOf(Buffer));

      for i := 0 to ReadBytes - 1 do
      begin
        if Buffer[i] = 0 then
        begin
          Result := True;
          Exit;
        end;

        if (Buffer[i] < 32) and not (Buffer[i] in [9, 10, 13]) then
        begin
          Result := True;
          Exit;
        end;
      end;
    finally
      FS.Free;
    end;
  except
    Result := True;
  end;
end;

end.
