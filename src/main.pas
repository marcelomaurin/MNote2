unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterAny, SynHighlighterPo,
  SynHighlighterPas, SynHighlighterCpp, SynHighlighterSQL, SynCompletion,
  SynHighlighterPython, SynHighlighterPHP, Forms, Controls, Graphics, Dialogs,
  Menus, ExtCtrls, ComCtrls, StdCtrls, Grids, PopupNotifier, item, types, finds,
  setmain, mquery, TypeDB, folders, funcoes, LCLType, chgtext;


const versao = '2.11';

type

  { TfrmMNote }

  TfrmMNote = class(TForm)
    FontDialog1: TFontDialog;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    btNovo: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
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
    PopupNotifier1: TPopupNotifier;
    ReplaceDialog1: TReplaceDialog;
    SaveDialog1: TSaveDialog;
    SynAutoComplete1: TSynAutoComplete;
    SynCompletion1: TSynCompletion;
    SynCppSyn1: TSynCppSyn;
    SynPasSyn1: TSynPasSyn;
    SynPHPSyn1: TSynPHPSyn;
    SynPythonSyn1: TSynPythonSyn;
    SynSQLSyn1: TSynSQLSyn;
    SynSQLSyn2: TSynSQLSyn;
    TrayIcon1: TTrayIcon;
    procedure FindDialog1Find(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btNovoClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstFindChangeBounds(Sender: TObject);
    procedure lstFindClick(Sender: TObject);
    procedure lstFindContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure lstFindDblClick(Sender: TObject);
    procedure lstFindSelectionChange(Sender: TObject; User: boolean);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem15Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
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
    procedure SynCompletion1CodeCompletion(var Value: string;
      SourceValue: string; var SourceStart, SourceEnd: TPoint;
      KeyChar: TUTF8Char; Shift: TShiftState);
    procedure SynCompletion1Execute(Sender: TObject);
    procedure SynCompletion1SearchPosition(var APosition: integer);
    procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TabSheet2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private
    { private declarations }


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
    function classificaTipo(arquivo : string): TTypeItem;
    procedure MessageHint(info : string);

  public
    { public declarations }

    procedure CarregarArquivo(arquivo : string);
  end;

var
  frmMNote: TfrmMNote;

implementation

{$R *.lfm}

{ TfrmMNote }
uses Sobre;


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

(*Classificação a partir da extensão*)
function TfrmMNote.classificaTipo(arquivo : string): TTypeItem;
var
  extensao : string;
begin
  extensao := ExtractFileExt(arquivo);
  if extensao = '.txt' then
  begin
    result := ti_TXT;
  end;
  if extensao = '.cfg' then
  begin
    result := ti_CFG;
  end;
  if extensao = '.h' then
  begin
    result := ti_H;
  end;
  if extensao = '.c' then
  begin
    result := ti_CCP;
  end;
  if extensao = '.cc' then
  begin
    result := ti_CCP;
  end;
  if extensao = '.ccp' then
  begin
    result := ti_CCP;
  end;
  if extensao = '.sh' then
  begin
    result := ti_BASH;
  end;
  if extensao = '.sql' then
  begin
    result := ti_SQL;
  end;
  if extensao = '.bak' then
  begin
    result := ti_SQL;
  end;
  if extensao = '.pas' then
  begin
    result := ti_PAS;
  end;
  if extensao = '.py' then
  begin
    result := ti_PY;
  end;
end;


procedure TfrmMNote.MessageHint(info: string);
var
  x , y : integer;
begin
     PopupNotifier1.Title:='Atenção!';
     PopupNotifier1.Text:=info;
     y := Screen.Height;
     x := screen.Width;
     PopupNotifier1.ShowAtPos(x,y);
     PopupNotifier1.Show;
     sleep(2000);
end;

procedure TfrmMNote.Carregar(arquivo : String);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   fSynCompletion : TSynCompletion;
   fAutoComplete : TSynAutoComplete;
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

        fSynCompletion := item.synCompletion;
        fAutoComplete := item.AutoComplete;
        syn.Lines.LoadFromFile(arquivo);

        item.ItemType := classificaTipo(arquivo);
        except
            on E: Exception do
            begin
              tb.Destroy;
              MessageHint('File cannot be read:'+ E.Message);
              exit;
            end;

        end;
      end;
      syn.OnChange := @synChange ;
      tb.tag := PtrInt(item);
      tb.ImageIndex:=0;
      tb.PopupMenu := popFechar;

      item.Loadfile(arquivo);
      item.salvo := true;

      if FileGetAttr(arquivo) = faReadOnly then
      begin
          syn.ReadOnly:=true;
          tb.Caption:= item.Name;
      end
      else
      begin
           tb.Caption:= item.Name;
      end;
      pgMain.Refresh();
      AssociarExtensao(item);
  end;
end;

procedure TfrmMNote.CarregarArquivo(arquivo : string);
begin
  if (arquivo = '') then
  begin
    if OpenDialog1.execute then
    begin
      if FileExists(OpenDialog1.FileName) then
      begin
            Carregar(OpenDialog1.FileName);
            Application.ProcessMessages;
      end
      else
      begin
           MessageHint('File not found!');
      end;
    end;
  end
  else
  begin
     if FileExists(OpenDialog1.FileName) then
     begin
          Carregar(arquivo);
     end;
  end;
end;

function TfrmMNote.NovoItem():TTabSheet;
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   SynCompletion : TSynCompletion;
   synAutoComplet : TSynAutoComplete;
begin
  tb := pgMain.AddTabSheet();

  syn := TSynEdit.Create(tb);
  syn.Parent := tb;
  syn.Align:= alClient;
  syn.Lines.Clear;
  syn.PopupMenu := popSysEdit;
  syn.OnChange:= @synChange;
  (*Complete*)
  SynCompletion := TSynCompletion.Create(self);
  SynCompletion.Editor := syn;
  SynCompletion.OnCodeCompletion:=@SynCompletion1CodeCompletion;
  SynCompletion.OnExecute:=@SynCompletion1Execute;
  SynCompletion.OnSearchPosition:=@SynCompletion1SearchPosition;

  (*Autocomplete*)
  synAutoComplet := TSynAutoComplete.create(self);
  synAutoComplet.Editor := syn;

  item := TItem.create(self);
  item.AtribuiNovoNome();
  item.synCompletion:= SynCompletion;    //Ponteiro de SynCompletion
  item.AutoComplete :=  synAutoComplet;  //Ponteiro de synAutocompletion
  item.syn := syn; //Ponteiro de editor

  tb.PopupMenu := popFechar;
  tb.Tag:= PtrInt(item); //Guarda o item
  tb.ImageIndex:=0;

  tb.Caption:= item.Name;
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
        if FileExists(Application.Params[a]) then
        begin
          info := Application.Params[a];
          MessageHint(info);
          Carregar(info);
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
         MessageHint(info);
         Carregar(info);
         Application.ProcessMessages;
     end;
  end;
  application.ProcessMessages;
end;

procedure TfrmMNote.FormCreate(Sender: TObject);
begin

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
end;

procedure TfrmMNote.CarregaContexto();
begin
  FSetMain.CarregaContexto();
  Left:= FsetMain.posx;
  top:= FSetMain.posy;
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

procedure TfrmMNote.AssociarExtensao(item: TItem);
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
                    MessageHint('Extensão associada!');
                  end
                  else
                  begin
                     //showmessage('Extensão não foi associada!');
                    MessageHint('Extensão não foi associada!');
                  end;
             end;
          end;
        end
        else
        begin
           PopupNotifier1.Title:='Atenção!';
           PopupNotifier1.Text:='Associação de extensão somente possivel quando estiver rodando como administrador';
           PopupNotifier1.Show;
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
   Reply := Application.MessageBox('Deseja Salvar os textos', 'Confirma', BOXStyle);
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

      CloseAction:= caNone;
    end
     else
    begin
      CloseAction:= caFree;
    end;
  end
end;

procedure TfrmMNote.FindDialog1Find(Sender: TObject);
begin

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

  if (frmMQuery <> nil) then
  begin
    frmMQuery.Destroy;
    frmmquery := nil;
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
   sql : TSynSQLSyn;
   fSynCompletion:TSynCompletion;
   fAutoComplete : TSynAutoComplete;
begin
  //syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  //item := TItem(syn.tag);
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  sql := TSynSQLSyn.create(self);
  fsynCompletion :=  item.synCompletion;
  fAutoComplete := item.AutoComplete;
  fAutoComplete.AutoCompleteList.LoadFromFile('sql.dci');


  sql.sqldialect := sqlMySQL;
  sql.TableNames.clear;

  syn.Highlighter := sql;
  item.ItemType:= ti_SQL;


end;

procedure TfrmMNote.MenuItem15Click(Sender: TObject);
begin
  frmFolders.show();
end;

procedure TfrmMNote.MenuItem4Click(Sender: TObject);
begin
  if frmmquery = nil then
  begin
    frmmquery := TFrmMQuery.create(self);
  end;
  frmmquery.show();
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
  Fsetmain.posx:=frmMNote.Left;
  Fsetmain.posy:=frmMNote.top;
end;

procedure TfrmMNote.mnCClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   cpp : TSynCppSyn;

begin
  //syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  //item := TItem(syn.tag);
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  cpp := TSynCppSyn.create(self);
  syn.Highlighter := cpp;

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
   pas : TSynPasSyn;
   fAutoComplete : TSynAutoComplete;
begin
  //syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  //item := TItem(syn.tag);
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  fAutoComplete := item.AutoComplete;
  fAutoComplete.AutoCompleteList.LoadFromFile('Delphi32.dci');
  pas := TSynPasSyn.create(self);
  syn.Highlighter := pas;
end;

procedure TfrmMNote.mnAssociarClick(Sender: TObject);
begin

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
  FontDialog1.Font :=  syn.Font;
  if FontDialog1.Execute then
  begin
      syn.Font := FontDialog1.Font;
  end;
end;

procedure TfrmMNote.mnPythonClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   python : TSynPythonSyn;
   fAutoComplete : TSynAutoComplete;
begin
  //syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  //item := TItem(syn.tag);
  item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
  syn := item.syn;
  fAutoComplete := item.AutoComplete;
  fAutoComplete.AutoCompleteList.LoadFromFile('python.dci');

  python := TSynPythonSyn.create(self);
  syn.Highlighter := python;
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

begin

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
  frmchgtext.show;

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
   end
   else
   begin
        SalvarComo(tb);
   end;
end;

procedure TfrmMNote.mnSalvarClick(Sender: TObject);
var
   tb : TTabSheet;
begin
   if (pgMain.ActivePage <> nil) then
   begin
      tb := pgMain.ActivePage;
      SalvarTab(tb);
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

procedure TfrmMNote.SynCompletion1CodeCompletion(var Value: string;
  SourceValue: string; var SourceStart, SourceEnd: TPoint; KeyChar: TUTF8Char;
  Shift: TShiftState);
var
   syn : TSynEdit;
   tb : TTabSheet;
   listagem : TListBox;

begin
   if (pgMain.ActivePage <> nil) then
   begin
      tb := pgMain.ActivePage;
      syn := TSynEdit(tb.tag);
      listagem := TListBox.Create(syn);
      listagem.Items.Text:= SourceValue;
      //listagem
      //SourceValue :=  SourceValue;
      (*
      if SourceStart.x > 0 then
      begin
        if syn.Lines[SourceStart.y - 1][SourceStart.x-1] = '\' then
        begin
          SourceStart.x -= 1;
          SourceValue := '\' + SourceValue;
        end;
      end;
      *)
   end;
end;

procedure TfrmMNote.SynCompletion1Execute(Sender: TObject);
begin
  //showmessage('execute');
  MessageHint('execute');
end;

procedure TfrmMNote.SynCompletion1SearchPosition(var APosition: integer);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   sql : TSynSQLSyn;
   fSynCompletion:TSynCompletion;
   fAutoComplete : TSynAutoComplete;
begin
   //syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
   //item := TItem(syn.tag);
   item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
   syn := item.syn;
   if (item.ItemType = ti_sql) then
   begin


   end;
   fSynCompletion :=  item.synCompletion;
   fAutoComplete := item.AutoComplete;

   if frmMQuery <> nil then
    begin
      sql.sqldialect := sqlMySQL;
      if (frmMQuery.zmycon.Connected) then
      begin
        if (frmMQuery.getdatabasetype = DBMysql) then
        begin
          sql.SQLDialect:= sqlMySQL;
        end;
        if (frmMQuery.getdatabasetype = DBPostgres) then
        begin
          sql.SQLDialect:= sqlPostgres;
        end;
        fSynCompletion.ItemList.Append(frmMQuery.GetTables().Text);
        sql.tableNames := frmMQuery.GetTables();
      end;
    end;
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

