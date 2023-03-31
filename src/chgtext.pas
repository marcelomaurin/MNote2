unit chgtext;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Menus,finds, SynEdit,item, ComCtrls,types, LCLType, setchgtext;

type

  { Tfrmchgtext }

  Tfrmchgtext = class(TForm)
    btchange: TButton;
    Button1: TButton;
    Button2: TButton;
    cbReplace: TComboBox;
    cbSearch: TComboBox;
    ckMatchcase: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbfind: TLabel;
    lbChange: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lstFind: TListBox;
    MenuItem2: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    popFind: TPopupMenu;
    procedure btchangeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbSearchEnter(Sender: TObject);
    procedure cbSearchKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstFindClick(Sender: TObject);
    procedure Panel4Click(Sender: TObject);

  private
    procedure setSelLength(var textComponent:TSynEdit; newValue:integer);
    procedure CarregaContexto();
  public
    strFind : String;
    FPos : integer;
    procedure Pesquisar(Sender: TObject);
    procedure Trocar(Sender: TObject);

  end;

var
  frmchgtext: Tfrmchgtext;

implementation

uses main;

{$R *.lfm}

{ Tfrmchgtext }

procedure Tfrmchgtext.CarregaContexto();
begin
  FSetchgtext.CarregaContexto();
  Left:= FSetchgtext.posx;
  top:= FSetchgtext.posy;
  if FSetchgtext.stay then
  begin
    //FormStyle:= fsStayOnTop;
    //mnStay.Caption:='Normal';
    //mnOnTopW.Caption:='Normal';
  end
  else
  begin
    //FormStyle:= fsNormal;
    //mnStay.Caption:='On Top';
    //mnOnTopW.Caption:='On Top';
  end;
  if not FSetchgtext.fixar then
  begin
    //BorderStyle:=bsSingle;
    //mnFixar.Caption:='Fix';
    //mnFixW.Caption:='Fix';
  end
  else
  begin
    //BorderStyle:=bsNone;
    //mnFixar.Caption:= 'Move';
    //mnFixW.caption := 'Move' ;
  end;
end;

procedure Tfrmchgtext.setSelLength(var textComponent:TSynEdit; newValue:integer);
begin
     textComponent.SelEnd:=textComponent.SelStart+newValue ;
end;

procedure Tfrmchgtext.lstFindClick(Sender: TObject);
var
   find : TFind;
   res : boolean;
begin
    If lstFind.SelCount > 0 then
    begin
        find := TFIND(lstFind.items.objects[lstFind.ItemIndex]);
        frmMNote.pgMain.ActivePage := find.tb;
        FPOS := find.IPOS;


        FPos := find.IPos + length(find.strFind);
        //   Hoved.BringToFront;       {Edit control must have focus in }
        find.syn.SetFocus;
        frmMnote.ActiveControl := find.syn;
        find.syn.SelStart:= find.IPos;  // -1;   mike   {Select the string found by POS}
        setSelLength(find.syn, find.FLen);     //Memo1.SelLength := FLen;
        //Found := True;
        FPos:=FPos+find.FLen-1;   //mike - move just past end of found item

    end;
end;

procedure Tfrmchgtext.Panel4Click(Sender: TObject);
begin

end;

procedure Tfrmchgtext.Button1Click(Sender: TObject);
begin
     strFind:= cbSearch.text;
     if (cbsearch.items.IndexOf(strFind)= 0) then
     begin
         cbSearch.Items.Append(strFind);
         cbSearch.Refresh;
     end;
     lbfind.caption := strFind;
     Pesquisar(Sender);
end;

procedure Tfrmchgtext.Button2Click(Sender: TObject);
var
   strReplace : String;
   pos: integer;
begin
 strReplace := cbReplace.text;
 if (strReplace <> '') then
 begin
      if (cbReplace.Items.IndexOf(strReplace)=0) then
      begin
             cbReplace.items.Append(strReplace);
      end;
      for pos := 0 to lstFind.Count-1 do
      begin
        lstFind.Selected[pos] := true;

        lbchange.caption := strReplace;
        Trocar(self);
      end;
  end;
end;

procedure Tfrmchgtext.cbSearchEnter(Sender: TObject);
begin

end;

procedure Tfrmchgtext.cbSearchKeyPress(Sender: TObject; var Key: char);
begin
    if (key=#13) then
    begin
        Button1Click(sender);
    end;
end;

procedure Tfrmchgtext.FormCreate(Sender: TObject);
begin
  if (FSetchgtext = nil) then
  begin
        FSetchgtext := TSetchgtext.create();
  end;
  CarregaContexto();
end;

procedure Tfrmchgtext.FormDestroy(Sender: TObject);
var
   info : string;
begin
  FSetchgtext.posx := Left;
  FSetchgtext.posy := top;

  FSetchgtext.SalvaContexto(false);
  if FSetchgtext <> nil then
  begin
    FSetchgtext.Free();
    FSetchgtext := nil;
  end;

end;



procedure Tfrmchgtext.btchangeClick(Sender: TObject);
var
   strReplace : String;
begin
  strReplace := cbReplace.text;
  if (strReplace <> '') then
  begin
      if (cbReplace.Items.IndexOf(strReplace)=0) then
      begin
           cbReplace.items.Append(strReplace);
           cbReplace.Refresh;
      end;
      lbchange.caption := strReplace;
      Trocar(self);
  end;
end;

procedure Tfrmchgtext.Pesquisar(Sender: TObject);
Var
     find : TFind;
     syn : TSynEdit;
     item : TItem;
     tb : TTabsheet;
     arquivo : string;
     FindS: String;
     Found : boolean;
     IPos, FLen, SLen: Integer; {Internpos, Lengde søkestreng, lengde memotekst}
     Res : integer;
begin
    IPOS := 0;
    FPOS := 0;
    //syn := TSynEdit(pgMain.ActivePage.Tag);
    //item := TItem(syn.tag);
    item := TItem(frmMNote.pgMain.ActivePage.Tag);
    syn := item.syn;
    {FPos is global}
    Found:= False;
    FLen := Length(strFind);
    SLen := Length(syn.Text);
    //FindS := findDialog1.FindText;
    FindS := cbSearch.text;
    frmchgtext.lstFind.Items.clear;

    repeat
       if ckMatchcase.Checked then
          IPos := Pos(strFind, Copy(syn.Text,FPos+1,SLen-FPos))
       else
          IPos := Pos(AnsiUpperCase(strFind),AnsiUpperCase( Copy(syn.Text,FPos+1,SLen-FPos)));

       if (IPOS>0) then
       begin
         FPos := FPos + IPos;
         find := TFind.create(syn ,frmMNote.pgMain.ActivePage , item, FPOS, strFind);

         lstFind.Items.AddObject('Pos:'+inttostr(FPOS),tobject(find));

       end
       else
       begin
         FPOS := 0;
         break;
       end;
    until (IPOS <=0);

    If frmchgtext.lstFind.Count > 0 then
    begin
      //pnBotton.Visible:= true;
    end
    Else
    begin
      //pnBotton.Visible:= false;
      Res := Application.MessageBox('Text was not found!',
             'Find',  mb_OK + mb_ICONWARNING);
      FPos := 0;
    end;

end;

procedure Tfrmchgtext.Trocar(Sender: TObject);
var
   find : TFind;
   res : boolean;

begin
    If lstFind.SelCount > 0 then
    begin
        find := TFIND(lstFind.items.objects[lstFind.ItemIndex]);
        frmMNote.pgMain.ActivePage := find.tb;
        FPOS := find.IPOS;


        FPos := find.IPos + length(find.strFind);
        //   Hoved.BringToFront;       {Edit control must have focus in }
        find.syn.SetFocus;
        frmMnote.ActiveControl := find.syn;
        find.syn.SelStart:= find.IPos;  // -1;   mike   {Select the string found by POS}
        setSelLength(find.syn, find.FLen);     //Memo1.SelLength := FLen;
        find.syn.SelText:= lbChange.Caption;
        //Found := True;
        FPos:=FPos+find.FLen-1;   //mike - move just past end of found item

    end;


end;


end.

