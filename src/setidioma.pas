//Objetivo construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data:21/02/2021

unit setIdioma;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes;

const filenamePt = 'SetIdiomaPt.cfg';
const filenameEn = 'SetIdiomaEn.cfg';
const filenameEs = 'SetIdiomaEs.cfg';


type
  { TfrmMenu }

  { TSetMain }

  TSetMain = class(TObject)
    constructor create();
    destructor destroy();
  private
        arquivo : TStringList;
        Item:  Tstringlist;
        Traducao : TStringlist;
        FIdioma : string;
        //filename : String;
        procedure SetIdioma(value : string);
        procedure Default();
  public
        procedure SalvaContexto(flag : boolean);
        Procedure CarregaContexto();
        procedure IdentificaArquivo(flag : boolean);
        property Idioma : String read FIdioma write SetIdioma;

  end;

  var
    FSetMain : TSetMain;


implementation


procedure TSetMain.SetIdioma(value : String);
begin
    fIdioma := value;
    CarregaContexto();
end;



//Valores default do codigo
procedure TSetMain.Default();
begin
    FIdioma := 'PORTUGUESE';
    IdentificaArquivo(false);
end;


procedure TSetMain.CarregaContexto();
var
  posicao: integer;
  a : integer;
begin
    if  BuscaChave(arquivo,'IDIOMA:',posicao) then
    begin
      FIdioma := RetiraInfo(arquivo.Strings[posicao]);
    end;
    for a := 0 to Item.count-1 do
    begin
         if  BuscaChave(arquivo,item[a],posicao) then
         begin
              Traducao.add(RetiraInfo(arquivo.Strings[posicao]));
         end;
    end;
end;


procedure TSetMain.IdentificaArquivo(flag: boolean);
var
  filename : string;
begin
  //filename := 'Work'+ FormatDateTime('ddmmyy',now())+'.cfg';
  filename := 'Portuguese';
  if FIdioma = 'Portuguese' then
  begin
    filename := filenamePt;
  end;
  if FIdioma = 'English' then
  begin
      filename := filenameEn;
  end;
  if FIdioma = 'Spanish' then
  begin
      filename := filenameEs;
  end;

  if (FileExists(filename)) then
  begin
    arquivo.LoadFromFile(filename);
    CarregaContexto();
  end
  else
  begin
    default();
    SalvaContexto(false);
  end;

end;

//Metodo construtor
constructor TSetMain.create();
begin
    arquivo := TStringList.create();
    Item := TStringList.create();
    IdentificaArquivo(true);


end;


procedure TSetMain.SalvaContexto(flag: boolean);
var
  filename : string;
begin
  if (flag) then
  begin
    IdentificaArquivo(false);
  end;
  //filename := 'Work'+ FormatDateTime('ddmmyy',now())+'.cfg';
  arquivo.Clear;
  arquivo.Append('IDIOMA:'+FIDIOMA);


  filename := 'Portuguese';
  if FIdioma = 'Portuguese' then
  begin
    filename := filenamePt;
  end;
  if FIdioma = 'English' then
  begin
      filename := filenameEn;
  end;
  if FIdioma = 'Spanish' then
  begin
      filename := filenameEs;
  end;


  arquivo.SaveToFile(filename);
end;

destructor TSetMain.destroy();
begin
  SalvaContexto(true);
  arquivo.free;
  arquivo := nil;
end;

end.




