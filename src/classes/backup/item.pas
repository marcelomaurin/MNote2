unit Item;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs, SynCompletion, ExtCtrls, SynEdit;

type
TTypeItem  = (ti_NODEFINE, ti_E , ti_H , ti_CCP, ti_PAS, ti_Reg, ti_BAT,
           ti_CFG , ti_TXT, ti_SQL,ti_PY, ti_PHP, ti_JAVA, ti_JS, ti_HTML, ti_CSS,
           ti_INO, ti_SHELL, ti_ALL);
TProjetoTipo = (pt_NODEFINE, pt_TEXT, pt_ProjetoRoot, pt_ProjetoSetup, pt_ProjetoSetupItem, pt_ProjetoFiles, pt_ProjetoDirFiles, pt_ProjetoFilesItem);
TTipoInfo = (Name, Path);

{ TItem }

TItem = class
      private
         FListaItem: TObjectList;
         FPalavrasReservadas : TStringList;
         FItemType : TTypeItem; (*Nao esta sendo usado p nada*)
         Fsyn : TSynEdit;
         FSynAutoComplete: TSynAutoComplete;
         Ftimer : TTimer;
         FSender: TObject;
         function PesquisaPar(param: string; lst: TStringlist): string;
         function AtribuiExt(Extensao: string): TTypeItem;
         procedure default();
         procedure SetItemType(value : TTypeItem);
         procedure SetSyn(value : TSynEdit);
         procedure  TimerEvento(Sender: TObject);
         procedure SynCompletion1Execute(Sender: TObject);
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


         constructor Create(Sender: TComponent);
         destructor destroy();
         procedure Mudou();
         procedure AtribuiNome(Arquivo:String);
         procedure AtribuiNovoNome();
         procedure Savefile(arquivo: string);
         procedure Loadfile(arquivo: string);
         function classificaTipo(arquivo : string): TTypeItem;
         property ItemType : TTypeItem read FItemType write setItemType;
         property syn :TSynEdit read Fsyn write setSyn;
         property PalavrasReservadas : TStringlist read FPalavrasReservadas write FPalavrasReservadas;
         property SynAutoComplete: TSynAutoComplete read FSynAutoComplete write FSynAutoComplete;
end;

implementation

procedure TItem.AtribuiNovoNome();
begin
     default();

end;

procedure TItem.SynCompletion1Execute(Sender: TObject);
begin

end;

(*Classificação a partir da extensão*)
function TItem.classificaTipo(arquivo : string): TTypeItem;
var
  extensao : string;
begin
  result := ti_ALL;
  extensao := ExtractFileExt(arquivo);
  if(extensao = '.txt') then
  begin
    result := ti_TXT;
  end;
  if( extensao = '.cfg') then
  begin
    result := ti_CFG;
  end;
  if(extensao = '.h') then
  begin
    result := ti_H;
  end;
  if(extensao = '.c') then
  begin
    result := ti_CCP;
  end;
  if(extensao = '.cc') then
  begin
    result := ti_CCP;
  end;
  if(extensao = '.ccp') then
  begin
    result := ti_CCP;
  end;
  if(extensao = '.ino') then
  begin
    result := ti_INO.;
  end;
  if(extensao = '.sh') then
  begin
    result := ti_SHELL;
  end;
  if(extensao = '.bat') then
  begin
    result := ti_BAT.;
  end;

  if (extensao = '.sql') then
  begin
    result := ti_SQL;
  end;
  if( extensao = '.bak') then
  begin
    result := ti_SQL;
  end;
  if( extensao = '.pas') then
  begin
    result := ti_PAS;
  end;
  if (extensao = '.py') then
  begin
    result := ti_PY;
  end;
  if (extensao = '.php') then
  begin
    result := ti_PHP;
  end;
  if (extensao = '.java') then
  begin
    result := ti_JAVA;
  end;
  if (extensao = '.js') then
  begin
    result := ti_JS;
  end;
  if (extensao = '.htm') or (extensao = '.html') then
  begin
    result := ti_HTML;
  end;
  //
end;

procedure TItem.default();
begin

  Ftimer.Enabled := false;
  Ftimer.Interval:= 1000;
  Ftimer.OnTimer:= @TimerEvento;
  FPalavrasReservadas.clear;


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
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'delphi32.dci') then
      begin
            FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'delphi32.dci');
      end;
    end;
    ti_PY :
    begin
       FSynAutoComplete.AutoCompleteList.clear;
       if FileExists(ExtractFilePath(ApplicationName)+'pythonlist.dci') then
       begin
              FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'pythonlist.dci');
       end;
    end;
    ti_SQL :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'sqllist.dci') then
      begin
         FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'sqllist.dci');
      end;
    end;
    ti_SHELL :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'c.dci') then
      begin
          FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'c.dci');
      end;
      if FileExists(ExtractFilePath(ApplicationName)+'clist.txt') then
         FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'clist.txt');
    end;

    ti_CCP :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'c.dci') then
      begin
          FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'c.dci');
      end;
      if FileExists(ExtractFilePath(ApplicationName)+'clist.txt') then
         FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'clist.txt');
    end;
    ti_H :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'c.dci') then
      begin
          FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'c.dci');
      end;

    end;
    ti_INO :
      begin
        FSynAutoComplete.AutoCompleteList.clear;
        if FileExists(ExtractFilePath(ApplicationName)+'c.dci') then
        begin
            FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'c.dci');

        end;

      end;
    ti_PHP :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'phplist.dci') then
      begin
            FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'phplist.dci');
      end;
    end;
    ti_JAVA :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'javalist.dci') then
      begin
         FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'javalist.dci');
      end;
    end;
    ti_TXT :
    begin
      FSynAutoComplete.AutoCompleteList.clear;

    end;
    ti_CFG :
    begin
      FSynAutoComplete.AutoCompleteList.clear;

    end;
  end;
  //AutoComplete.AutoCompleteList.;
end;

procedure TItem.SetSyn(value: TSynEdit);
begin
  fsyn := value;
  FSynAutoComplete.Editor := value;

end;

procedure TItem.TimerEvento(Sender: TObject);
begin
  //Nada ainda
end;

constructor TItem.Create(Sender: TComponent);
begin
  FSender := Sender;
  Ftimer := TTimer.create(Sender);
  FPalavrasReservadas := TStringlist.create();
  FSynAutoComplete:= TSynAutoComplete.Create(sender);
  FSynAutoComplete.ExecCommandID:= ecSynAutoCompletionExecute;
  default();
  Salvo := false;
end;

destructor TItem.destroy();
begin
  Ftimer.free;
  FPalavrasReservadas.free;
  PalavrasReservadas:= nil;
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
       FItemType := classificaTipo(arquivo);
  end;
end;

procedure TItem.Savefile(arquivo: string);
begin
  AtribuiNome(arquivo);
  FItemType := classificaTipo(arquivo);

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
  FItemType := classificaTipo(arquivo);

end;

end.

