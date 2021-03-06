unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterAny, SynHighlighterPo,
  SynHighlighterPas, SynHighlighterCpp,SynHighlighterSQL, Forms, Controls, Graphics, Dialogs,
  Menus, ExtCtrls, ComCtrls, StdCtrls, Grids, item, types, finds, setmain,
  mquery, TypeDB, folders, funcoes;


const versao = '2.9';

type

  { TfrmMNote }


  TfrmMNote = class(TForm)
    FindDialog1: TFindDialog;
    FontDialog1: TFontDialog;
    ImageList1: TImageList;
    lstFind: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    btNovo: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem4: TMenuItem;
    mnFixW: TMenuItem;
    mnOnTopW: TMenuItem;
    mnDesktopCenterW: TMenuItem;
    MenuItem2: TMenuItem;
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
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    pnBotton: TPanel;
    pgMain: TPageControl;
    Panel1: TPanel;
    popFind: TPopupMenu;
    popFechar: TPopupMenu;
    popSysEdit: TPopupMenu;
    PopupMenu1: TPopupMenu;
    ReplaceDialog1: TReplaceDialog;
    SaveDialog1: TSaveDialog;
    SynSQLSyn1: TSynSQLSyn;
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
    procedure setSelLength(var textComponent:TSynEdit; newValue:integer);
    procedure pntvClick(Sender: TObject);
    procedure pgMainChange(Sender: TObject);
    procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TabSheet2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private
    { private declarations }
    FPos : integer;
    strFind : String;
    procedure NovoItem();
    procedure Carregar(arquivo : String);
    procedure SalvarTab(tb : TTabSheet);
    procedure synChange(Sender: TObject);
    procedure SalvarComo(tb :TTabSheet);
    function Mudou(): boolean;
    function PerguntaSalvar(): boolean;
    procedure SalvarTudo();
    procedure Pesquisar(Sender: TObject);
    procedure CarregaContexto();
    procedure AssociarExtensao(Aba: TSynEdit);

  public
    { public declarations }
    procedure CarregarArquivo(arquivo : string);
  end;

var
  frmMNote: TfrmMNote;

implementation

{$R *.lfm}

{ TfrmMNote }
uses Sobre, LCLType, pesquisar;


procedure TfrmMNote.synChange(Sender: TObject);
var
  syn : TSynEdit;
  item : TItem;
begin
  syn := TSynEdit(Sender);
  item := TItem(syn.Tag);
  item.Mudou();

end;



procedure TfrmMNote.Carregar(arquivo : String);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
begin
  tb := pgMain.AddTabSheet();

  syn := TSynEdit.Create(tb);
  syn.Parent := tb;
  syn.Align:= alClient;
  syn.PopupMenu := popSysEdit;
  syn.Lines.LoadFromFile(arquivo);
  syn.OnChange := @synChange ;
  tb.tag := integer(pointer(syn));
  tb.ImageIndex:=0;
  tb.PopupMenu := popFechar;
  item := TItem.create();
  item.Loadfile(arquivo);
  item.salvo := true;
  syn.Tag:= integer(pointer(item));
  tb.Caption:= item.Name;
  pgMain.Refresh();
  AssociarExtensao(syn);

end;

procedure TfrmMNote.CarregarArquivo(arquivo : string);
begin
  if (arquivo = '') then
  begin
  if OpenDialog1.execute then
  begin
    Carregar(OpenDialog1.FileName);
  end;

  end
  else
  begin
     Carregar(arquivo);
  end;
end;

procedure TfrmMNote.NovoItem();
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
  tb.PopupMenu := popFechar;
  tb.Tag:= Integer(pointer(syn)); //Guarda o Sys
  tb.ImageIndex:=0;

  item := TItem.create();
  item.AtribuiNovoNome();
  syn.Tag:= integer(pointer(item));
  tb.Caption:= item.Name;
  pgMain.Refresh();

end;

procedure TfrmMNote.FormCreate(Sender: TObject);
var
   parametros : integer;
   strparametros : string;
   a : integer;
   lista : TStringlist;
   info : string;
   i : integer;
begin
  lista := TStringList.create;
  if (FSetMain = nil) then
  begin
        FsetMain := TsetMain.create();
  end;
  CarregaContexto();
  parametros := Application.ParamCount;
  for a := 1 to parametros-1 do
  begin
      Carregar(Application.Params[a]);
  end;
  strparametros := FsetMain.lastfiles;
  lista.delimiter := ' ';
  lista.DelimitedText :=  strparametros;
  for a  := 0 to lista.Count-1 do
  begin
     info :=lista[a];
     if FileExists(info) then
         Carregar(info);
  end;
  {$ifdef Darwin}
     //Nao faz nada

  {$else}
     for i := 1 to paramCount() do
     begin
        info := paramStr(i);
        if FileExists(info) then
        begin
            Carregar(info);
        end;
     end;

  {$endif}


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
    BorderStyle:=bsSingle;
    mnFixar.Caption:='Fix';
    mnFixW.Caption:='Fix';
  end
  else
  begin
    BorderStyle:=bsNone;
    mnFixar.Caption:= 'Move';
    mnFixW.caption := 'Move' ;
  end;
end;

procedure TfrmMNote.AssociarExtensao(Aba: TSynEdit);
var
   item : TItem;
   arquivo: string;
   ext : string;
begin
   item := Titem(Aba.tag);
   ext := ExtractFileExt(item.FileName);
   arquivo := Application.ExeName;
   if not (ext = '') then
   begin
        ext := copy(ext,2,Length(ext));
        {$ifdef WINDOWS}
        if not VerificaRegExt(ext) then
        begin
             if ShowConfirm('Associa extensão '+ext + ' a aplicação!') then
             begin
                  if RegisterFileType(ext,Arquivo) then
                  begin
                    showmessage('Extensão associada!');
                  end
                  else
                  begin
                     showmessage('Extensão não foi associada!');
                  end;
             end;
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
      syn := TSynEdit(tb.Tag);
      item := TItem(syn.tag);
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
      syn := TSynEdit(tb.Tag);
      item := TItem(syn.tag);
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
     strFind:= findDialog1.FindText;
     Pesquisar(Sender);
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
     syn := TSynEdit(tb.Tag);
     item := TItem(syn.tag);
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
var
   find : TFind;
   res : boolean;

begin

    If lstFind.SelCount > 0 then
    begin


        find := TFIND(lstFind.items.objects[lstFind.ItemIndex]);
        pgMain.ActivePage := find.tb;
        FPOS := find.IPOS;


        FPos := find.IPos + length(find.strFind);
        //   Hoved.BringToFront;       {Edit control must have focus in }
        find.syn.SetFocus;
        Self.ActiveControl := find.syn;
        find.syn.SelStart:= find.IPos;  // -1;   mike   {Select the string found by POS}
        setSelLength(find.syn, find.FLen);     //Memo1.SelLength := FLen;
        //Found := True;
        FPos:=FPos+find.FLen-1;   //mike - move just past end of found item

    end;

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

begin
  syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  item := TItem(syn.tag);
  sql := TSynSQLSyn.create(self);

  sql.sqldialect := sqlMySQL;
  sql.TableNames.clear;
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

      sql.tableNames := frmMQuery.GetTables();
    end;
  end;
  syn.Highlighter := sql;


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
   pnBotton.Visible:=false;
end;

procedure TfrmMNote.mnDesktopCenterClick(Sender: TObject);
begin
  frmMNote.Top := (Screen.DesktopHeight - frmMNote.Height) DIV 2;
  frmMNote.Left := (Screen.DesktopWidth - frmMNote.Width) DIV 2;
end;

procedure TfrmMNote.mnCClick(Sender: TObject);
var
   tb : TTabSheet;
   syn : TSynEdit;
   item : TItem;
   cpp : TSynCppSyn;

begin
  syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  item := TItem(syn.tag);
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
begin
  syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  item := TItem(syn.tag);
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
  syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  item := TItem(syn.tag);
  FontDialog1.Font :=  syn.Font;
  if FontDialog1.Execute then
  begin
      syn.Font := FontDialog1.Font;
  end;
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
    FPos:= 0;
  if ReplaceDialog1.Execute then
  begin

  end;
end;

procedure TfrmMNote.mnFecharClick(Sender: TObject);
var
   a : integer;
   resultado : boolean;
   syn : TSynEdit;
   item : TItem;
   tb :TTabSheet;
begin
  syn := TSynEdit( pgMain.Pages[pgMain.ActivePageIndex].Tag);
  item := TItem(syn.tag);
  pgMain.ActivePage.Hide;
  pgMain.Pages[pgMain.ActivePageIndex].free;
  //syn.Free;
  item.Free;
end;

procedure TfrmMNote.setSelLength(var textComponent:TSynEdit; newValue:integer);
begin
textComponent.SelEnd:=textComponent.SelStart+newValue ;
end;

procedure TfrmMNote.mnPesqItemClick(Sender: TObject);
begin
  FPos:= 0;
  if FindDialog1.Execute then
  begin

  end;

end;

procedure TfrmMNote.Pesquisar(Sender: TObject);
Var
     find : TFind;
     syn : TSynEdit;
     item : TItem;
     tb : TTabsheet;
     arquivo : string;
     //FindS: String;
     Found : boolean;
     IPos, FLen, SLen: Integer; {Internpos, Lengde søkestreng, lengde memotekst}
     Res : integer;
begin
    IPOS := 0;
    FPOS := 0;
    syn := TSynEdit(pgMain.ActivePage.Tag);
    item := TItem(syn.tag);

    {FPos is global}
    Found:= False;
    FLen := Length(strFind);
    SLen := Length(syn.Text);
    //FindS := findDialog1.FindText;
    lstFind.Items.clear;

    repeat

       //following 'if' added by mike
       if frMatchcase in findDialog1.Options then
          IPos := Pos(strFind, Copy(syn.Text,FPos+1,SLen-FPos))
       else
          IPos := Pos(AnsiUpperCase(strFind),AnsiUpperCase( Copy(syn.Text,FPos+1,SLen-FPos)));

       if (IPOS>0) then
       begin
         FPos := FPos + IPos;
         find := TFind.create(syn ,pgMain.ActivePage , item, FPOS, strFind);

         lstFind.Items.AddObject('Pos:'+inttostr(FPOS),tobject(find));

       end
       else
       begin
         FPOS := 0;
         break;
       end;
    until (IPOS <=0);

    If lstFind.Count > 0 then begin
      pnBotton.Visible:= true;
    end
    Else
    begin
      pnBotton.Visible:= false;
      Res := Application.MessageBox('Text was not found!',
             'Find',  mb_OK + mb_ICONWARNING);
      FPos := 0;     //mike  nb user might cancel dialog, so setting here is not enough
    end;             //   - also do it before exec of dialog.

end;

procedure TfrmMNote.SalvarComo(tb :TTabSheet);
var
   syn : TSynEdit;
   item : TItem;
   arquivo : string;
begin
   syn := TSynEdit(tb.Tag);
   item := TItem(syn.tag);
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
   syn := TSynEdit(tb.Tag);
   item := TItem(syn.tag);
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

