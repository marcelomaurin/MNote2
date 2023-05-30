unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  Menus, ExtCtrls, ComCtrls, StdCtrls, Grids, PopupNotifier, item, types, finds,
  setmain, TypeDB, folders, funcoes, LCLType, ValEdit, chgtext, hint, registro,
  splash, setFolders, config, SynEditKeyCmds, PythonEngine, chatgpt;


const versao = '2.27';

type

  { TfrmMNote }

  TfrmMNote = class(TForm)
    FontDialog1: TFontDialog;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    meChatHist: TMemo;
    edChat: TMemo;
    MenuItem14: TMenuItem;
    MenuItem17: TMenuItem;
    miChatGPT: TMenuItem;
    mniJSONVALID: TMenuItem;
    mnidos2unix: TMenuItem;
    Panel2: TPanel;
    pnChatGPT: TPanel;
    pcInspector: TPageControl;
    pnclient: TPanel;
    pnInspector: TPanel;
    Separator4: TMenuItem;
    miRedo: TMenuItem;
    miSelectAll: TMenuItem;
    miSelectCmd: TMenuItem;
    miSelectBlock: TMenuItem;
    Separator3: TMenuItem;
    Separator2: TMenuItem;
    miPaste: TMenuItem;
    micopy: TMenuItem;
    mnHideResult: TMenuItem;
    meResult: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    btNovo: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    mnNone: TMenuItem;
    mnJava: TMenuItem;
    mnSQL: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    mnrun: TMenuItem;
    mndebug: TMenuItem;
    mnclean: TMenuItem;
    mninstall: TMenuItem;
    mnPHP: TMenuItem;
    pnResult: TPanel;
    pmResult: TPopupMenu;
    Separator1: TMenuItem;
    miConfig: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem9: TMenuItem;
    miUndo: TMenuItem;
    mnFixW: TMenuItem;
    mnOnTopW: TMenuItem;
    mnDesktopCenterW: TMenuItem;
    mnDesktopCenter: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    mnFixar: TMenuItem;
    mnStay: TMenuItem;
    mnLazarus: TMenuItem;
    mnFechar2: TMenuItem;
    mnPython: TMenuItem;
    mnC: TMenuItem;
    mnAssociar: TMenuItem;
    mnfont: TMenuItem;
    mnSetup: TMenuItem;
    mnScript: TMenuItem;
    mnFechar: TMenuItem;
    mnCarregar: TMenuItem;
    MenuItem3: TMenuItem;
    mnSalvar: TMenuItem;
    mnSalvarComo: TMenuItem;
    MenuItem6: TMenuItem;
    mnPesqItem: TMenuItem;
    OpenDialog1: TOpenDialog;
    pgMain: TPageControl;
    Panel1: TPanel;
    popFechar: TPopupMenu;
    popFind: TPopupMenu;
    popSysEdit: TPopupMenu;
    PopupMenu1: TPopupMenu;
    ReplaceDialog1: TReplaceDialog;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    tsLocal: TTabSheet;
    tsGlobal: TTabSheet;
    TrayIcon1: TTrayIcon;
    vlGlobal: TValueListEditor;
    vlLocal: TValueListEditor;
    procedure edChatKeyPress(Sender: TObject; var Key: char);
    procedure FindDialog1Find(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btNovoClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lstFindChangeBounds(Sender: TObject);
    procedure lstFindClick(Sender: TObject);
    procedure lstFindContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure lstFindDblClick(Sender: TObject);
    procedure lstFindSelectionChange(Sender: TObject; User: boolean);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure miChatGPTClick(Sender: TObject);
    procedure micopyClick(Sender: TObject);
    procedure miPasteClick(Sender: TObject);
    procedure miRedoClick(Sender: TObject);
    procedure mncleanClick(Sender: TObject);
    procedure mndebugClick(Sender: TObject);
    procedure mnHideResultClick(Sender: TObject);
    procedure mnidos2unixClick(Sender: TObject);
    procedure mniJSONVALIDClick(Sender: TObject);
    procedure mninstallClick(Sender: TObject);
    procedure mnJavaClick(Sender: TObject);
    procedure mnNoneClick(Sender: TObject);
    procedure mnPHPClick(Sender: TObject);
    procedure mnSQLClick(Sender: TObject);
    procedure MenuItem15Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure mnrunClick(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure miConfigClick(Sender: TObject);
    procedure miUndoClick(Sender: TObject);
    procedure mnFixWClick(Sender: TObject);
    procedure mnOnTopWClick(Sender: TObject);
    procedure mnDesktopCenterWClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure mnDesktopCenterClick(Sender: TObject);
    procedure mnCClick(Sender: TObject);
    procedure mnFechar2Click(Sender: TObject);
    procedure mnFixarClick(Sender: TObject);
    procedure mnLazarusClick(Sender: TObject);
    procedure mnAssociarClick(Sender: TObject);
    procedure mnfontClick(Sender: TObject);
    procedure mnPythonClick(Sender: TObject);
    procedure mnScriptClick(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure mnFecharClick(Sender: TObject);
    procedure mnPesqItemClick(Sender: TObject);
    procedure mnSalvarClick(Sender: TObject);
    procedure mnSalvarComoClick(Sender: TObject);
    procedure mnCarregarClick(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure mnStayClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure pnBottonClick(Sender: TObject);
    procedure ReplaceDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure pntvClick(Sender: TObject);
    procedure pgMainChange(Sender: TObject);


    procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TabSheet2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);

    procedure MudaTodasaFontes();
  private
    { private declarations }
    FCHATGPT : TCHATGPT;

    procedure CarregarParametros();
    procedure CarregarOld();
    function NovoItem():TTabSheet;
    procedure Carregar(arquivo : String);
    procedure SalvarTab(tb : TTabSheet);
    procedure synChange(Sender: TObject);
    procedure SalvarComo(tb :TTabSheet);
    function Mudou(): boolean;
    function PerguntaSalvar(): boolean;
    procedure SalvarTudo();
    procedure CarregaContexto();
    procedure AssociarExtensao(item: Titem);

    //procedure ConfigureCppHighlighter(var ACppHighlighter: TSynCppSyn);
    (*
    procedure SynEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
      *)
    procedure SynEditkey(Sender: TObject; var Key: char);
    function SubmeteChatGPT( info : string) : string;

  public
    { public declarations }
    procedure MessageHint(info : string);
    function ExistFileOpen(Arquivo : string): boolean;
    procedure CarregarArquivo(arquivo : string);
  end;

var
  frmMNote: TfrmMNote;

implementation

{$R *.lfm}

{ TfrmMNote }
uses Sobre;



function TfrmMNote.ExistFileOpen(Arquivo : string): boolean;
var
  resposta : boolean;
  cont : integer;
  syn : TSynEdit;
  item : TItem;
begin
  resposta := false;
  for cont:=0 to pgMain.PageCount-1 do
  begin
     item := TItem(pgMain.Pages[cont].Tag);

     if (Arquivo=item.FileName) then
     begin
       resposta := true;
     end;
  end;
  result := resposta;

end;

procedure TfrmMNote.synChange(Sender: TObject);
var
  syn : TSynEdit;
  item : TItem;
begin
  //syn := TSynEdit(Sender);
  //item := TItem(syn.Tag);
  //item.Mudou();
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  item.mudou();
end;



(*
procedure TfrmMNote.SynEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  syn : TSynEdit;
begin
  //Altered:= TRUE;
  if (Shift = [ssCtrl]) then
  begin

    syn := TSynedit(Sender);
    case Key of
      VK_C:
      begin
        syn.CommandProcessor(TSynEditorCommand(ecCopy), ' ', nil);

      end;
      VK_V:
      begin
        //syn.CommandProcessor(TSynEditorCommand(ecPaste), ' ', nil);
        //syn.PasteFromClipboard;
        miPasteClick(sender);
      end;
      VK_X:
      begin
        syn.CommandProcessor(TSynEditorCommand(ecCut), ' ', nil);
        //syn.PasteFromClipboard;

      end;
    end;
  end;

end;
*)

procedure TfrmMNote.SynEditkey(Sender: TObject; var Key: char);
var
  syn : TSynEdit;
begin
   syn := TSynedit(Sender);
   case Key of
      char(VK_C):
      begin
        //syn.CommandProcessor(TSynEditorCommand(ecCopy), ' ', nil);

      end;
      char(VK_V):
      begin
        //syn.CommandProcessor(TSynEditorCommand(ecPaste), ' ', nil);
        //syn.PasteFromClipboard;
        //miPasteClick(sender);
      end;
      char(VK_X):
      begin
        syn.CommandProcessor(TSynEditorCommand(ecCut), ' ', nil);
        //syn.PasteFromClipboard;
      end;
      else
      begin
        //showmessage(inttostr(ord(Key)));
      end;

   end;

end;

function TfrmMNote.SubmeteChatGPT(info: string): string;
var
  resultado : string;
begin
  if (FSetMain.CHATGPT = '') then
  begin
    Resultado := 'Inclua o token do chatgpt';
  end
  else
  begin
    Resultado:= 'Not yet';
  end;
  result := resultado;
end;




procedure TfrmMNote.MessageHint(info: string);
var
  frmHint : TfrmHint;
begin
  frmHint := TfrmHint.create(self);
  frmHint.messagehint(info);
end;



procedure TfrmMNote.Carregar(arquivo : String);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  if FileExists(arquivo) then
  begin
    if(not FileExists(arquivo)) then
    begin
        MessageHint(arquivo + ' not exits');
    end
    else
    begin
      tb := NovoItem();
      item := Titem(tb.tag);
      syn := item.syn;
      try

        syn.Lines.LoadFromFile(arquivo);

        //item.ItemType := classificaTipo(arquivo);
        except
            on E: Exception do
            begin
              tb.Destroy;
              MessageHint('File cannot be read:'+ E.Message);
              exit;
            end;

        end;
      end;


      tb.tag := PtrInt(item);
      tb.ImageIndex:=0;
      tb.PopupMenu := popFechar;

      item.Loadfile(arquivo);
      item.salvo := true;

      if FileGetAttr(arquivo) = faReadOnly then
      begin
          syn.ReadOnly:=true;
          tb.Caption:= item.Nome;
      end
      else
      begin
           tb.Caption:= item.Nome;
      end;
      //CheckTipoArquivo(syn,arquivo, item);
      pgMain.Refresh();

  end;
end;

procedure TfrmMNote.CarregarArquivo(arquivo : string);
begin
  if (arquivo = '') then
  begin
    OpenDialog1.InitialDir:= FSetFolders.DefaultFolder;
    if OpenDialog1.execute then
    begin
      if FileExists(OpenDialog1.FileName) then
      begin
          if not ExistFileOpen(OpenDialog1.FileName) then  //Verifica se existe essa aba ja
          begin
            Carregar(OpenDialog1.FileName);
            Application.ProcessMessages;
          end;
      end
      else
      begin
           MessageHint('File not found!');
      end;
    end;
  end
  else
  begin
     if FileExists(arquivo) then
     begin
        if not ExistFileOpen(arquivo) then  //Verifica se existe essa aba ja
        begin
          Carregar(arquivo);
        end;
     end;
  end;
end;

function TfrmMNote.NovoItem():TTabSheet;
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;

begin
  tb := pgMain.AddTabSheet();

  syn := TSynEdit.Create(tb);
  syn.Parent := tb;
  syn.Align:= alClient;
  syn.Lines.Clear;
  syn.PopupMenu := popSysEdit;
  syn.OnChange:= @synChange;
  syn.Font := FSetMain.Font;
  //syn.OnKeyDown:=@SynEdit1KeyDown;
  syn.OnKeyPress:= @SynEditkey;



  item := TItem.create(self);
  item.AtribuiNovoNome();
  item.syn := syn; //Ponteiro de editor

  tb.PopupMenu := popFechar;
  tb.Tag:= PtrInt(item); //Guarda o item
  tb.ImageIndex:=0;

  tb.Caption:= item.Nome;
  pgMain.Refresh();
  application.ProcessMessages;
  result := tb;
end;

procedure TfrmMNote.CarregarParametros();
var
   parametros : integer;
   info : string;
   a : integer;
   pesquisa : integer;
begin
  parametros := Application.ParamCount;
  for a := 1 to parametros do
  begin
      pesquisa := pos('--',Application.Params[a]);
      if (pesquisa<>-1) then
      begin
        info := Application.Params[a];
        if FileExists(info) then
        begin
          //MessageHint(info);
          if not ExistFileOpen(info) then  //Verifica se existe essa aba ja
          begin
            Carregar(info);
          end;
          application.ProcessMessages;
        end
        else
        begin
          MessageHint(info+' file not found!');
        end;
      end;
  end;
end;

procedure TfrmMNote.CarregarOld();
var
   a : integer;
   lista : TStringlist;
   strparametros : string;
   info : string;
begin
  strparametros := FsetMain.lastfiles;
  lista := TStringList.create;
  lista.delimiter := ' ';
  lista.DelimitedText :=  strparametros;
  for a  := 0 to lista.Count-1 do
  begin
     info :=lista[a];
     if(FileExists(info)) then
     begin
         //MessageHint(info);
         if not ExistFileOpen(info) then  //Verifica se existe essa aba ja
         begin
           Carregar(info);
         end;
         Application.ProcessMessages;
     end;
  end;
  application.ProcessMessages;
end;

procedure TfrmMNote.FormCreate(Sender: TObject);
var
   filename: string;
begin
  frmSplash := TfrmSplash.Create(self);
  frmSplash.lbversao.Caption:= versao;
  frmSplash.show();
  filename := extractfilename(application.ExeName);
  if IsRun(filename) then
  begin
    if KillAppByName(filename) then
    begin
      MessageHint('Assumindo funções MNote anterior!');
    end;
  end;
  if (FSetMain = nil) then
  begin
        FsetMain := TsetMain.create();
  end;
  CarregaContexto();


  {$ifdef Darwin}
     //Nao faz nada

  {$else}
  (*
     for i := 1 to paramCount() do
     begin
        info := paramStr(i);
        if FileExists(info) then
        begin
            Carregar(info);
        end;
     end;
   *)
  {$endif}
  CarregarOld();
  CarregarParametros();
  frmRegistrar := TfrmRegistrar.Create(self);
  frmRegistrar.Identifica();
end;

procedure TfrmMNote.CarregaContexto();
begin
  FSetMain.CarregaContexto();
  Left:= FsetMain.posx;
  top:= FSetMain.posy;
  Width:=   FSetMain.width;
  Height:= FSetMain.Height;
  if FSetMain.stay then
  begin
    FormStyle:= fsStayOnTop;
    mnStay.Caption:='Normal';
    mnOnTopW.Caption:='Normal';
  end
  else
  begin
    FormStyle:= fsNormal;
    mnStay.Caption:='On Top';
    mnOnTopW.Caption:='On Top';
  end;
  if not FSetMain.fixar then
  begin
    BorderStyle:=bsSizeable;
    mnFixar.Caption:='Fix';
    mnFixW.Caption:='Fix';
  end
  else
  begin
    BorderStyle:=bsSingle;
    mnFixar.Caption:= 'Move';
    mnFixW.caption := 'Move' ;
  end;
end;


procedure TfrmMNote.AssociarExtensao(item: Titem);
var
   arquivo: string;
   ext : string;
begin
   ext := ExtractFileExt(item.FileName);
   arquivo := Application.ExeName;

   if not (ext = '') then
   begin
        ext := copy(ext,2,Length(ext));
        {$ifdef WINDOWS}
        if IsAdministrator then
        begin
          if not VerificaRegExt(ext) then
          begin
             if ShowConfirm('Associa extensão '+ext + ' a aplicação!') then
             begin
                  //if RegisterFileType2(Arquivo, application.ExeName) then
                  if  RegistrarExtensao(  ExtractFileExt(application.ExeName), 'Aplicativo de edição de texto', ExtractFileName(application.ExeName), Application.ExeName) then
                  begin
                    //showmessage('Extensão associada!');
                    //MessageHint('Extensão associada!');
                  end
                  else
                  begin
                     //showmessage('Extensão não foi associada!');
                    //MessageHint('Extensão não foi associada!');
                  end;
             end;
          end;
        end
        else
        begin
           (*
           PopupNotifier1.Title:='Atenção!';
           PopupNotifier1.Text:='Associação de extensão somente possivel quando estiver rodando como administrador';
           PopupNotifier1.Show;
           *)
          //MessageHint('Associação de extensão somente possivel quando estiver rodando como administrador');
        end;
        {$endif}
   end;
end;


procedure TfrmMNote.mnStayClick(Sender: TObject);
begin
  if FormStyle = fsNormal then
  begin
    FormStyle:= fsStayOnTop;
    Fsetmain.stay := true;
    mnStay.Caption:='Normal';
    mnOnTopW.Caption:='Normal';
  end
  else
  begin
    FormStyle:=fsNormal;
    Fsetmain.stay := false;
    mnStay.Caption:='On Top';
    mnOnTopW.Caption:='On Top';
  end;
  refresh;
  Fsetmain.SalvaContexto(false);
end;


//Verifica se ha algum fonte sem salvar
function TfrmMNote.Mudou(): boolean;
var
   a : integer;
   resultado : boolean;
   syn : TSynEdit;
   item : TItem;
   tb :TTabSheet;
begin
   resultado := true;
   for a := 0 to pgMain.PageCount-1 do
   begin
      tb := pgMain.Pages[a];
      item := TItem(tb.tag);
      syn := item.syn;
      resultado :=  resultado and  item.Salvo;
   end;
   result := resultado;
end;

function TfrmMNote.PerguntaSalvar(): boolean;
var
   reply, BOXStyle : integer;
   resultado : boolean;

begin
   resultado := false;
   BoxStyle := MB_ICONQuestion + MB_YESNO;
   Reply := Application.MessageBox('Do you want to save the files?', 'Confirm', BOXStyle);
   if Reply = IDYES then
   begin
      resultado := true;
   end;

   result := resultado;
end;

procedure TfrmMNote.SalvarTudo();
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   a : integer;
begin
   for a := 0 to pgMain.PageCount-1 do
   begin
      tb := pgMain.Pages[a];
      item := TItem(tb.tag);
      syn := item.syn;
      if not(item.Salvo) then
      begin
         SalvarTab(tb);
      end;
   end;
end;

procedure TfrmMNote.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if not Mudou() then
  begin
    if PerguntaSalvar() then
    begin
      //Deve salvar antes
      SalvarTudo();
    end;
  end;
  CloseAction:= caFree;
end;

procedure TfrmMNote.FindDialog1Find(Sender: TObject);
begin

end;

procedure TfrmMNote.edChatKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
     if(FCHATGPT = nil) then
     begin
         FCHATGPT := TCHATGPT.create(self);
     end;
      FCHATGPT.TOKEN:= FSetMain.CHATGPT;
      meChatHist.Append('Question:'+edChat.Text);
      FCHATGPT.SendQuestion(edChat.Text);
      meChatHist.Append('Response:'+ FCHATGPT.Response);
      meChatHist.Append(' ');
      edChat.Text:= '';
  end;
end;

procedure TfrmMNote.btNovoClick(Sender: TObject);
begin
  NovoItem();

end;

procedure TfrmMNote.FormDestroy(Sender: TObject);
var
   info : string;
   syn : TSynEdit;
   tb : TTabSheet;
   item : TItem;
   a: integer;
begin
  Fsetmain.posx := Left;
  Fsetmain.posy := top;
  Fsetmain.width := Width;
  Fsetmain.Height:= Height;
  (*
  if (frmMQuery <> nil) then
  begin
    frmMQuery.Destroy;
    frmmquery := nil;
  end;
  *)
  if (frmFolders <> nil) then
  begin
      frmFolders.destroy;
      frmFolders := nil;

  end;

  //Salva arquivos abertos
  info := '';
  for a:= 0 to pgMain.PageCount-1 do
  begin
     tb := pgMain.Pages[a];
     item := TItem(tb.tag);
     syn := item.syn;
     info := info + item.FileName+ ' ';
  end;

  FSetMain.lastfiles:=info; (*Salva contexto final*)

  Fsetmain.SalvaContexto(false);
  if Fsetmain <> nil then
  begin
    Fsetmain.Free();
    Fsetmain := nil;
  end;
  if (FCHATGPT <> nil) then
  begin
    FCHATGPT.free;

  end;

end;

procedure TfrmMNote.FormShow(Sender: TObject);
begin
  if (frmSplash <> nil) then
  begin
    frmSplash.hide;
    frmSplash.Free;
    frmSplash := nil;
  end;
end;

procedure TfrmMNote.lstFindChangeBounds(Sender: TObject);
begin


end;

procedure TfrmMNote.lstFindClick(Sender: TObject);
begin

end;

procedure TfrmMNote.lstFindContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure TfrmMNote.lstFindDblClick(Sender: TObject);
begin

end;

procedure TfrmMNote.lstFindSelectionChange(Sender: TObject; User: boolean);
begin

end;

procedure TfrmMNote.MenuItem10Click(Sender: TObject);
begin
  frmSobre := TFrmsobre.create(self);
  frmSobre.lbversao.Caption := versao;
  frmSobre.showmodal();
  frmSobre.destroy();
  frmSobre := nil;
end;

procedure TfrmMNote.MenuItem12Click(Sender: TObject);
begin

end;

procedure TfrmMNote.MenuItem14Click(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  //syn.CommandProcessor(TsynEditorCommand(ecCut),'',nil);
  syn.CutToClipboard;
end;

procedure TfrmMNote.miChatGPTClick(Sender: TObject);
begin
    pnChatGPT.Visible:= not pnChatGPT.Visible;
end;

procedure TfrmMNote.micopyClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  //syn.CommandProcessor(TsynEditorCommand(ecCopy),'',nil);
  syn.CopyToClipboard;

end;

procedure TfrmMNote.miPasteClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  //syn.CommandProcessor(TsynEditorCommand(ecPaste),'',nil);
  syn.PasteFromClipboard;

end;

procedure TfrmMNote.miRedoClick(Sender: TObject);
var

tb : TTabSheet;
syn : TSynEdit;
item : TItem;
begin
item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
syn := item.syn;
syn.Redo;
end;

procedure TfrmMNote.mncleanClick(Sender: TObject);
var
     Output : string;
     filename : string;
begin
     mnSalvarClick(self); (*Salva antes de rodar*)
     filename := FSetMain.CleanScript;
     if (filename <> '') then
     begin
          if(Callprg(filename, '', Output)=true) then
          begin
               //showmessage('Run program!!');
               MessageHint('Clean script'+ filename);
               meResult.Lines.Text:= Output;
               pnResult.Visible:= true;
          end
          else
          begin
               //showmessage('Fail debug!!');
               MessageHint('fail clean script'+ filename);
               pnResult.Visible:= false;
          end;
     end
     else
     begin
         MessageHint('Config clean need!'+ filename);
         pnResult.Visible:= false;
     end;

end;

procedure TfrmMNote.mndebugClick(Sender: TObject);
var
     Output : string;
     filename : string;
  begin
     mnSalvarClick(self); (*Salva antes de rodar*)
     filename := FSetMain.DebugScript;
     if (filename <> '') then
     begin
          if(Callprg(filename,'', Output)=true) then
          begin
               //showmessage('Run program!!');
               MessageHint('Debug script'+ filename);
               meResult.Lines.Text:= Output;
               pnResult.Visible:= true;
          end
          else
          begin
               //showmessage('Fail debug!!');
               MessageHint('fail debug script'+ filename);
               pnResult.Visible:= false;
          end;
     end
     else
     begin
         MessageHint('Config Debug need!'+ filename);
         pnResult.Visible:= false;
     end;


end;

procedure TfrmMNote.mnHideResultClick(Sender: TObject);
begin
  pnResult.Visible:=false;
end;

procedure TfrmMNote.mnidos2unixClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  if (pgMain.PageCount <>0 ) then
  begin
    item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
    syn := item.syn;
    RemoveCtrlMFromSynEdit(syn);
  end;

end;

procedure TfrmMNote.mniJSONVALIDClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  if (pgMain.PageCount <>0 ) then
  begin
    item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
    syn := item.syn;
    if ValidateJson(syn) then
    begin
      ShowMessage('JSON VALID!');
    end
    else
    begin
      ShowMessage('JSON NOT VALID!');
    end;
  end;
end;

procedure TfrmMNote.mninstallClick(Sender: TObject);
var
     Output : string;
     filename : string;
  begin
     mnSalvarClick(self); (*Salva antes de rodar*)
     filename := FSetMain.Install;
     if (filename <> '') then
     begin
          if(Callprg(filename, '', Output)=true) then
          begin
               //showmessage('Run program!!');
               MessageHint('Install script'+ filename);
               meResult.Lines.Text:= Output;
               pnResult.Visible:= true;
          end
          else
          begin
               //showmessage('Fail debug!!');
               MessageHint('fail Install script'+ filename);
               pnResult.Visible:= false;
          end;
     end
     else
     begin
         MessageHint('Config Install need!'+ filename);
         pnResult.Visible:= false;
     end;


end;

procedure TfrmMNote.mnJavaClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  syn.Highlighter := nil;
end;

procedure TfrmMNote.mnNoneClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  syn.Highlighter := nil;
end;

procedure TfrmMNote.mnPHPClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  syn.Highlighter := nil;
end;

procedure TfrmMNote.mnSQLClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
  // sql : TSynSQLSyn;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  //sql := TSynSQLSyn.create(self);
  //sql.sqldialect := sqlMySQL;
  //sql.TableNames.clear;


  //syn.Highlighter :=  SynSQLSyn1;
  //item.ItemType:= ti_SQL;


end;

procedure TfrmMNote.MenuItem15Click(Sender: TObject);
begin
  if (frmFolders = nil) then
  begin
       frmFolders := TfrmFolders.Create(self);
  end;
  {$ifndef Darwin}
  if frmFolders.Showing then
  begin
    frmFolders.hide;
  end
  else
  begin
    frmFolders.show();

  end;
  {$else}
   MessageHint('Folder not run in MACOS');
  {$ENDIF}

end;

procedure TfrmMNote.MenuItem16Click(Sender: TObject);
begin

end;


procedure TfrmMNote.mnrunClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   I : NativeInt;
   variavel : PPyObject;
   variavelname : string;

begin
   mnSalvarClick(self); (*Salva antes de rodar*)
   item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
   meResult.Lines.clear;
   item.Resultado := meResult;

   item.Run();
   syn := item.syn;
   pnResult.Visible:=true;
   if (item.PythonCtrl.VarsCheck) then
   begin
      pnInspector.Visible:=true;
   end;
   if item.Error then
   begin
      syn.CaretY:= item.LinhaError;
   end
   else
   begin
     if (item.PythonCtrl.VarsCheck) then
     begin
         for I := 0 to item.PythonCtrl.VarListGlobal_Size -1  do
         begin
               //ShowMessage('Variável: ' + PyVarsList[I] + #13#10 +
               //  'Valor: ' + VarToStr(PyVarsDict.GetItem(PyVarsList[I])));
               //vlGlobal.InsertRow(item.VarsList[I],item.VarsList.Strings[i], true);
               variavel := item.PythonCtrl.PythonEngine.PyList_GetItem(item.PythonCtrl.VarsGlobalKeys,I);
               variavelname := item.PythonCtrl.PythonEngine.PyUnicodeAsString(variavel);
               vlGlobal.InsertRow(variavelname,'',true);
         end;
         for I := 0 to item.PythonCtrl.VarListLocal_Size -1  do
         begin
               //ShowMessage('Variável: ' + PyVarsList[I] + #13#10 +
               //  'Valor: ' + VarToStr(PyVarsDict.GetItem(PyVarsList[I])));
               //vlGlobal.InsertRow(item.VarsList[I],item.VarsList.Strings[i], true);
               variavel := item.PythonCtrl.PythonEngine.PyList_GetItem(item.PythonCtrl.VarsLocalKeys,I);
               variavelname := item.PythonCtrl.PythonEngine.PyUnicodeAsString(variavel);
               vlLocal.InsertRow(variavelname,'',true);
         end;
     end;

   end;


end;

procedure TfrmMNote.MenuItem4Click(Sender: TObject);
begin
  (*
  if frmmquery = nil then
  begin
    frmmquery := TFrmMQuery.create(self);
  end;
  if frmMQuery.Showing then
  begin
    frmmquery.hide();
  end
  else
  begin
    frmmquery.show();
  end;
  *)
end;

procedure TfrmMNote.miConfigClick(Sender: TObject);
begin
  frmConfig := TfrmConfig.create(self);
  frmConfig.showmodal();
  frmConfig.free();
end;

procedure TfrmMNote.miUndoClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   //cpp : TSynCppSyn;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  //cpp := TSynCppSyn.create(self);
  //syn.Highlighter := cpp;
  syn.Undo;
end;

procedure TfrmMNote.mnFixWClick(Sender: TObject);
begin
  mnFixarClick(self);
end;

procedure TfrmMNote.mnOnTopWClick(Sender: TObject);
begin
  mnStayClick(self);
end;

procedure TfrmMNote.mnDesktopCenterWClick(Sender: TObject);
begin
  mnDesktopCenterClick(self);
end;

procedure TfrmMNote.MenuItem1Click(Sender: TObject);
begin

end;

procedure TfrmMNote.MenuItem2Click(Sender: TObject);
begin

end;

procedure TfrmMNote.mnDesktopCenterClick(Sender: TObject);
begin
  frmMNote.top := (Screen.WorkAreaTop  - frmMNote.Height) DIV 2;
  frmMNote.left := (Screen.WorkAreaLeft  - frmMNote.Width) DIV 2;
  Fsetmain.posx:=Left;
  Fsetmain.posy:=top;
  Fsetmain.width := Width;
  Fsetmain.Height:= Height;
end;

procedure TfrmMNote.mnCClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   //cpp : TSynCppSyn;

begin
  //syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  //item := TItem(syn.tag);
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  //cpp := TSynCppSyn.create(self);
  //syn.Highlighter := SynCppSyn1;
  //ConfigureCppHighlighter(SynCppSyn1);

end;

procedure TfrmMNote.mnFechar2Click(Sender: TObject);
begin
  mnFecharClick(sender);
end;

procedure TfrmMNote.mnFixarClick(Sender: TObject);
begin
    if (BorderStyle = bsNone) then
    begin
      BorderStyle:=bsSingle;
      Fsetmain.fixar := false;
      mnFixar.Caption:='Fix';
      mnFixW.caption := 'Fix';
      self.refresh;
    end
    else
    begin
      BorderStyle:=bsNone;
      Fsetmain.fixar := true;
      mnFixar.Caption:='Move';
      mnFixW.caption := 'Move';
      //self.hide;
      //self.show;
      self.refresh;
    end;
    Fsetmain.SalvaContexto(false);
end;

procedure TfrmMNote.mnLazarusClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;

begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  //syn.Highlighter := SynPasSyn1;
end;

procedure TfrmMNote.mnAssociarClick(Sender: TObject);
begin

end;

procedure TfrmMNote.MudaTodasaFontes();
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   a : integer;

begin
  for a := 0 to pgMain.PageCount-1 do
  begin
       item := TItem(pgMain.Pages[a].Tag);
       syn := item.syn;
       syn.Font := FSetMain.Font;
  end;

end;

procedure TfrmMNote.mnfontClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  //syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  //item := TItem(syn.tag);
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  FontDialog1.Font := syn.Font;

  if FontDialog1.Execute then
  begin
      syn.Font := FontDialog1.Font;
      FSetMain.Font := FontDialog1.Font;
      MudaTodasaFontes();
      FSetMain.SalvaContexto(false);


  end;
end;

procedure TfrmMNote.mnPythonClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  //syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  //item := TItem(syn.tag);
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  //syn.Highlighter := SynPythonSyn1;
end;

procedure TfrmMNote.mnScriptClick(Sender: TObject);
begin

end;

procedure TfrmMNote.MenuItem6Click(Sender: TObject);
begin

  close;
end;

procedure TfrmMNote.MenuItem8Click(Sender: TObject);
begin

end;

procedure TfrmMNote.MenuItem9Click(Sender: TObject);
var
   pagecont : integer;
   tb :TTabSheet;
begin
  for pagecont:=0 to pgMain.PageCount-1 do
  begin
      tb := pgMain.Pages[pagecont];
      SalvarTab(tb);
   end;
   MessageHint('All Saved!');

end;

procedure TfrmMNote.mnFecharClick(Sender: TObject);
var
   a : integer;
   resultado : boolean;
   syn : TSynEdit;
   item : TItem;
   tb :TTabSheet;
begin
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  //syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  //item := TItem(syn.tag);

  pgMain.ActivePage.Hide;
  pgMain.Pages[pgMain.ActivePageIndex].free;
  //syn.Free;
  item.Free;
end;



procedure TfrmMNote.mnPesqItemClick(Sender: TObject);
begin
  if frmchgtext.Showing then
  begin
    frmchgtext.hide;
  end
  else
  begin
       frmchgtext.show;
  end;

end;


procedure TfrmMNote.SalvarComo(tb :TTabSheet);
var
   syn : TSynEdit;
   item : TItem;
   arquivo : string;
begin
   //syn := TSynEdit(tb.Tag);
   item := TItem(tb.Tag);
   syn := item.syn;
   //item := TItem(syn.tag);
   arquivo := item.FileName;
   if arquivo <> '' then
   begin
        SaveDialog1.InitialDir:= ExtractFilePath(arquivo);
   end
   else
   begin
      SaveDialog1.InitialDir:= ExtractFilePath(ApplicationName);
   end;
   if (SaveDialog1.Execute) then
   begin
        item.Savefile(SaveDialog1.FileName);
        tb.Caption:= ExtractFileName(SaveDialog1.FileName);
        item.FileName:= SaveDialog1.FileName;
        item.salvo := false;
        SalvarTab(tb);
   end;
end;

procedure TfrmMNote.SalvarTab(tb : TTabSheet);
var
   syn : TSynEdit;
   item : TItem;
   arquivo : string;
begin
   //syn := TSynEdit(tb.Tag);
   //item := TItem(pointer(syn.tag));
   item := TItem(tb.Tag);
   syn := item.syn;
   arquivo := item.FileName;
   if not (item.FileName = '') then
   begin
        if (item.salvo=false) then
        begin
             syn.Lines.SaveToFile(arquivo);
        end;
        //CheckTipoArquivo(syn,arquivo, item);
   end
   else
   begin
        SalvarComo(tb);
   end;

end;

procedure TfrmMNote.mnSalvarClick(Sender: TObject);
var
   tb : TTabSheet;
   arquivo : string;
   item : TItem;
begin
   if (pgMain.ActivePage <> nil) then
   begin
      tb := pgMain.ActivePage;
      item := TItem(tb.Tag);

      arquivo := item.FileName;
      SalvarTab(tb);
      MessageHint('Saved in '+ arquivo);
   end;
end;

procedure TfrmMNote.mnSalvarComoClick(Sender: TObject);
var
   tb : TTabSheet;
begin
   if (pgMain.ActivePage <> nil) then
   begin
         tb := pgMain.ActivePage;
         SalvarComo(tb);
   end;

end;

procedure TfrmMNote.mnCarregarClick(Sender: TObject);
begin
  CarregarArquivo('');
end;

procedure TfrmMNote.MenuItem3Click(Sender: TObject);
begin

end;

procedure TfrmMNote.PageControl1Change(Sender: TObject);
begin

end;

procedure TfrmMNote.Panel1Click(Sender: TObject);
begin

end;

procedure TfrmMNote.pnBottonClick(Sender: TObject);
begin

end;

procedure TfrmMNote.ReplaceDialog1Find(Sender: TObject);
begin

end;

procedure TfrmMNote.ReplaceDialog1Replace(Sender: TObject);
var
   syn : TSynEdit;
   tb : TTabSheet;
   listagem : TListBox;
begin
   if (pgMain.ActivePage <> nil) then
   begin
      tb := pgMain.ActivePage;
      syn := TSynEdit(tb.tag);

   end;
end;

procedure TfrmMNote.pntvClick(Sender: TObject);
begin

end;

procedure TfrmMNote.pgMainChange(Sender: TObject);
begin


end;





procedure TfrmMNote.TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure TfrmMNote.TabSheet2ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;



end.

