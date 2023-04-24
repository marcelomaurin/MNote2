//Objetivo construir os parametros de setup da classe lista de conexoes
//Criado por Marcelo Maurin Martins
//Data:23/04/2023

unit Setlstbnc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes, TypeDB, setbanco;

const mfilename = 'Setlstbnc.cfg';
const MAXCON = 200;


type



  { TSetBanco }

  { TSetLSTBNC }

  TSetLSTBNC = class(TObject)
  private
        Farquivo :Tstringlist;
        FBANCOCFG : String;
        FLSTBNC : TStringList;
        FConexoes : TStringlist;
        Fpath : String;
        //procedure SetBancoCFG(value: string);
        procedure Default();
  public
        constructor create();
        destructor destroy();
        function NovaConexao(
                LHostname  : string;
                LPassword  : string;
                LUsername  : string;
                Ldbtype    : TypeDatabase;
                LPort      : string;
                LDatabase  : string ): TSetBanco;

        procedure SalvaContexto(flag : boolean);
        Procedure CarregaContexto();
        procedure IdentificaArquivo(flag : boolean);
        property LSTBNC : TStringList read FLSTBNC;
        property conexoes :  TStringList read FConexoes;
  end;

  var
    FSetLSTBNC : TSetLSTBNC;


implementation





//Valores default do codigo
procedure TSetLSTBNC.Default();
begin
    FLSTBNC := TStringlist.Create;
    Fpath:= '';;
end;



//Metodo construtor
constructor TSetLSTBNC.create();
begin
    farquivo := TStringList.create(); //Cria lista do arquivo
    IdentificaArquivo(true); //Pega referencia e carrega em memoria

end;

destructor TSetLSTBNC.destroy();
//var
  //FSetBanco : TSetBanco;
begin
  SalvaContexto(true);
  farquivo.free;
  farquivo := nil;
  //FSetBanco : TSetBanco;
end;

//Registra uma nova conexao
function TSetLSTBNC.NovaConexao(
        LHostname: string;
        LPassword: string;
        LUsername: string;
        Ldbtype: TypeDatabase;
        LPort: string;
        LDatabase: string
        ):TSetBanco;
var
  FSetBanco : TSetBanco;
begin
  FSetBanco := TSetBanco.create(LHostname+'_'+Ldatabase);
  FSetBanco.Hostname := LHostName;
  FSetBanco.Password:= LPassword;
  FSetBanco.User:= LUsername;
  FSetBanco.TipoBanco:= Ldbtype;
  FSetBanco.Port:= LPort;
  FSetBanco.Databasename:= LDatabase;
  FSetBanco.nrocfg := FLstBNC.Count;
  FSetBanco.SalvaContexto(false);
  FLSTBNC.AddObject(LHostname+'_'+Ldatabase,TObject(FSetBanco));
  result :=  FSetBanco;

end;


procedure TSetLSTBNC.CarregaContexto();
var
  posicao: integer;
  info : TStringlist;
  a: integer;
  FSetBanco : TSetBanco;
  auxiliar : string;
begin
    info := TStringlist.create();
    //Varre arquivo e busca por banco
    for a := 0 to Farquivo.Count-1 do
    begin
         info.clear;
         info.add(farquivo.Strings[a]);
         if  BuscaChave(info,'BANCO:',posicao) then
         begin
           auxiliar :=  RetiraInfo(info.Strings[posicao]);
           FSetBanco := TSetBanco.create(auxiliar);
           FSetBanco.nrocfg := FLstBNC.Count;
           FSetBanco.SalvaContexto(false);

           FLSTBNC.AddObject(auxiliar,TObject(FSetBanco));
         end;
    end;
end;


procedure TSetLSTBNC.IdentificaArquivo(flag: boolean);
begin
  {$ifdef Darwin}
    //Nao testado ainda
    Fpath :=GetAppConfigDir(false);
    if not(FileExists(FPATH)) then
    begin
      createdir(fpath);
    end;
  {$ENDIF}
  {$IFDEF LINUX}
      //Fpath :='/home/';
      //Fpath := GetUserDir()
      Fpath :=GetAppConfigDir(false);
      if not(FileExists(FPATH)) then
      begin
         createdir(fpath);
      end;
  {$ENDIF}
  {$IFDEF WINDOWS}
      Fpath :=GetAppConfigDir(false);
      if not(FileExists(FPATH)) then
      begin
         createdir(fpath);
      end;
  {$ENDIF}

  //filename := format(mfilename,[Fnrocfg]);
  //filename := mfilename;

  if (FileExists(Fpath+mfilename)) then
  begin
    farquivo.LoadFromFile(Fpath+mfilename);
    CarregaContexto();
  end
  else
  begin
    default();
    //SalvaContexto(false);
  end;

end;



procedure TSetLSTBNC.SalvaContexto(flag: boolean);
var
  a : integer;
begin
  if (flag) then
  begin
    IdentificaArquivo(false);
  end;
  //filename := 'Work'+ FormatDateTime('ddmmyy',now())+'.cfg';
  farquivo.Clear;
  for a := 0 to FLSTBNC.Count-1 do
  begin
       farquivo.Append('BANCO:'+FLSTBNC.Strings[a]);
  end;
  farquivo.SaveToFile(Fpath+mfilename);
end;


end.




