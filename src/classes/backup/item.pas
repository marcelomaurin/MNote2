unit Item;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs, SynCompletion;

type
TTypeItem  = (ti_NODEFINE, ti_E , ti_H , ti_CCP, ti_PAS, ti_Reg, ti_BASH, ti_BAT, ti_CFG , ti_TXT, ti_SQL, ti_ALL);
TProjetoTipo = (pt_NODEFINE, pt_TEXT, pt_ProjetoRoot, pt_ProjetoSetup, pt_ProjetoSetupItem, pt_ProjetoFiles, pt_ProjetoDirFiles, pt_ProjetoFilesItem);
TTipoInfo = (Name, Path);
TItem = class
      private
         FListaItem: TObjectList;
         function PesquisaPar(param: string; lst: TStringlist): string;
         function AtribuiExt(Extensao: string): TTypeItem;
      public
         Name: String;
         FileName : String;
         DirName : String;
         FileExt : string;
         {#IFDEF WINDOWS}
         VolName : String;
         {#ENDIF}
         ItemType : TTypeItem; (*Nao esta sendo usado p nada*)
         ProjetoTipo : TProjetoTipo;  (*Nao esta sendo usado p nada*)
         Salvo : Boolean;
         synCompletion : TSynCompletion;
         constructor Create();
         procedure Mudou();
         procedure AtribuiNome(Arquivo:String);
         procedure AtribuiNovoNome();
         procedure Savefile(arquivo: string);
         procedure Loadfile(arquivo: string);


end;

implementation

procedure TItem.AtribuiNovoNome();
begin
     default;

end;

procedure TItem.default();
begin
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

constructor TItem.create();
begin
  default();
  Salvo := false;
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

procedure TITem.Loadfile(arquivo: string);
begin
  AtribuiNome(arquivo);

end;

end.

