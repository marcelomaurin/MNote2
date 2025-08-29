unit folders;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ShellCtrls,
  ExtCtrls, Menus, StdCtrls, funcoes, hint, setmain, chatgpt,  Types,
  StrUtils, LConvEncoding;

type

  { TfrmFolders }

  TfrmFolders = class(TForm)
    btScanner: TButton;
    btIA: TButton;
    edFolder: TEdit;
    meLog: TMemo;
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
    procedure miCreatedirClick(Sender: TObject);
    procedure miDeleteClick(Sender: TObject);
    procedure mirefreshClick(Sender: TObject);
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure ShellTreeView1Changing(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure ShellTreeView1GetSelectedIndex(Sender: TObject; Node: TTreeNode);
  private

  public
    function Scanner(const Root: string): TStringList;
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
          frmMNote.MessageHint('Folder '+pathfolder+ ' deleted successful!');
      end
      else
      begin
          frmMNote.MessageHint('Folder '+pathfolder+ ' deleted fail!');
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
  finally
    tree.Free;
  end;
end;

procedure TfrmFolders.btIAClick(Sender: TObject);

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

    // (opcional) trechos de arquivos — ajuste limites se quiser
    Previews := BuildSmallPreviews(Raiz, Tree, {MaxFiles=} 12, {MaxBytesPerFile=} 8000);

    // sistema (instruções fixas para a IA)
    Dev :=
      'Voce é uma IA de respostas sintéticas, sua tarefa é responder de forma direta. .' + LineEnding;
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
      Chat.Free;
    end;

  finally
    Tree.Free;
  end;
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

end.

