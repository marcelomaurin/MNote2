unit Item;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs, SynCompletion, ExtCtrls, SynEdit;

type
TTypeItem  = (ti_NODEFINE, ti_E , ti_H , ti_CCP, ti_PAS, ti_Reg, ti_BASH, ti_BAT,
           ti_CFG , ti_TXT, ti_SQL,ti_PY, ti_PHP, ti_JAVA, ti_JS, ti_HTML, ti_CSS, ti_ALL);
TProjetoTipo = (pt_NODEFINE, pt_TEXT, pt_ProjetoRoot, pt_ProjetoSetup, pt_ProjetoSetupItem, pt_ProjetoFiles, pt_ProjetoDirFiles, pt_ProjetoFilesItem);
TTipoInfo = (Name, Path);

{ TItem }

TItem = class
      private
         FListaItem: TObjectList;
         FItemType : TTypeItem; (*Nao esta sendo usado p nada*)
         Fsyn : TSynEdit;
         Ftimer : TTimer;
         FSender: TObject;
         function PesquisaPar(param: string; lst: TStringlist): string;
         function AtribuiExt(Extensao: string): TTypeItem;
         procedure default();
         procedure SetItemType(value : TTypeItem);
         procedure SetSyn(value : TSynEdit);
         procedure  TimerEvento(Sender: TObject);
      public
         Name: String;
         FileName : String;
         DirName : String;
         FileExt : string;
         {#IFDEF WINDOWS}
         VolName : String;
         {#ENDIF}

         ProjetoTipo : TProjetoTipo;  (*Nao esta sendo usado p nada*)
         Salvo : Boolean;
         synCompletion : TSynCompletion;
         AutoComplete : TSynAutoComplete;

         constructor Create(Sender: TComponent);
         destructor destroy();
         procedure Mudou();
         procedure AtribuiNome(Arquivo:String);
         procedure AtribuiNovoNome();
         procedure Savefile(arquivo: string);
         procedure Loadfile(arquivo: string);
         property ItemType : TTypeItem read FItemType write setItemType;
         property syn :TSynEdit read Fsyn write setSyn;
end;

implementation

procedure TItem.AtribuiNovoNome();
begin
     default();

end;

procedure TItem.default();
begin

  Ftimer.Enabled := false;
  Ftimer.Interval:= 1000;
  Ftimer.OnTimer:= @TimerEvento;


  ItemType :=  ti_NODEFINE;
  ProjetoTipo := pt_NODEFINE;
  Name := 'Novo';
  DirName := '';
  FileName := '';
  FileExt := '';
  {#ifdef WINDOWS}
  VolName:= '';
  {#endif}


end;

procedure TItem.SetItemType(value: TTypeItem);
begin
  FItemType:= value;
  case FItemType of
    ti_PAS :
    begin
      if FileExists('Delphi32.dci') then
            AutoComplete.AutoCompleteList.LoadFromFile('Delphi32.dci');
    end;
    ti_PY :
    begin
      (*
      if FileExists('python.dci') then
            AutoComplete.AutoCompleteList.LoadFromFile('python.dci');
      *)
       AutoComplete.AutoCompleteList.clear;
    end;
    ti_SQL :
    begin
      (*
      if FileExists('sql.dci') then
            AutoComplete.AutoCompleteList.LoadFromFile('sql.dci');
      *)
      AutoComplete.AutoCompleteList.clear;
    end;
    ti_CCP :
    begin
      (*
      if FileExists('cpp.dci') then
            AutoComplete.AutoCompleteList.LoadFromFile('cpp.dci');
      *)
      AutoComplete.AutoCompleteList.clear;
    end;
    ti_H :
    begin
      (*
      if FileExists('cpp.dci') then
            AutoComplete.AutoCompleteList.LoadFromFile('cpp.dci');
      *)
      AutoComplete.AutoCompleteList.clear;
    end;
    ti_PHP :
    begin
      (*
      if FileExists('php.dci') then
            AutoComplete.AutoCompleteList.LoadFromFile('php.dci');
      *)
      AutoComplete.AutoCompleteList.clear;
    end;
    ti_JAVA :
    begin
      AutoComplete.AutoCompleteList.clear;
    end;
    ti_TXT :
    begin
      AutoComplete.AutoCompleteList.clear;
    end;
    ti_CFG :
    begin
      AutoComplete.AutoCompleteList.clear;
    end;
  end;
  //AutoComplete.AutoCompleteList.;
end;

procedure TItem.SetSyn(value: TSynEdit);
begin
  fsyn := value;
end;

procedure TItem.TimerEvento(Sender: TObject);
begin
  //Nada ainda
end;

constructor TItem.Create(Sender: TComponent);
begin
  FSender := Sender;
  Ftimer := TTimer.create(Sender);

  default();
  Salvo := false;
end;

destructor TItem.destroy();
begin
  Ftimer.free;;
end;

procedure TItem.Mudou();
begin
  Salvo := false;
end;

//Atribui Extensao
function TItem.AtribuiExt(Extensao: string):TTypeItem;
begin


end;

procedure TItem.AtribuiNome(Arquivo:String);
begin
  //Atribui parametros de Arquivo
  if (Arquivo <> '') then
  begin
       Name := ExtractFileName(Arquivo);
       DirName := ExtractFileDir(Arquivo);
       FileName := Arquivo;
       FileExt:= ExtractFileExt(Arquivo);
       ItemType := AtribuiExt(FileExt);
       {#ifdef WINDOWS}
       VolName:= ExtractFileDrive(Arquivo);
       {#endif}
  end;
end;

procedure TItem.Savefile(arquivo: string);
begin
  AtribuiNome(arquivo);

end;

function TItem.PesquisaPar(param: string; lst: TStringlist): string;
var
  a: integer;
  resultado : string;
begin
  resultado := '';
  for a:= 0 to lst.Count-1 do
  begin
    if (pos(param,lst.Strings[a])>=0) then
    begin
       resultado := copy( lst.Strings[a], length(param),length(lst.Strings[a]));

    end;
  end;
  result := resultado;

end;

procedure TItem.Loadfile(arquivo: string);
begin
  AtribuiNome(arquivo);

end;

end.

