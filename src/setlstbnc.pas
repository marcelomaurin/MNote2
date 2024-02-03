//Objetivo construir os parametros de setup da classe lista de conexoes
//Criado por Marcelo Maurin Martins
//Data:23/04/2023

unit Setlstbnc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes, TypeDB, setbanco;

const mfilename = 'Setlstbnc.cfg';

type
  { TSetLSTBNC }

  TSetLSTBNC = class(TObject)
  private
        Farquivo :Tstringlist;
        FLSTBNC : TStringList;
        FSetBanco : TSetBanco;
        Fpath : String;
        FCount : integer;
        procedure Default();
        function GetCount(): integer;
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
        function DeleteItem(item : integer) : boolean;

        procedure SalvaContexto(flag : boolean);
        Procedure CarregaContexto();
        procedure IdentificaArquivo(flag : boolean);
        function GetSetBanco(indice : integer) :  TSetBanco;

        property LSTBNC: TStringlist read FLSTBNC;
        property Count : integer read GetCount;
  end;

var
  FSetLSTBNC :  TSetLSTBNC;



implementation

var
  FSetBanco : TSetBanco;



//Valores default do codigo
procedure TSetLSTBNC.Default();
begin
  Fpath:= '';
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

end;

function TSetLSTBNC.GetCount: integer;
begin
   result := FLSTBNC.Count;
end;



//Metodo construtor
constructor TSetLSTBNC.create();
begin
    farquivo := TStringList.create(); //Cria lista do arquivo
    FLSTBNC := TStringlist.Create;

    IdentificaArquivo(true); //Pega referencia e carrega em memoria
    CarregaContexto();

end;

destructor TSetLSTBNC.destroy();
begin
  SalvaContexto(true);
  farquivo.free;
  farquivo := nil;
  //FSetBanco : TSetBanco;
end;

function TSetLSTBNC.GetSetBanco(indice: integer): TSetBanco;
begin
  result :=  TSetBanco(FLSTBNC.Objects[indice]);

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
  SalvaContexto(false);
  result :=  FSetBanco;

end;

function TSetLSTBNC.DeleteItem(item: integer): boolean;
begin
  FLSTBNC.Delete(item);
  result := true;
end;


procedure TSetLSTBNC.CarregaContexto();
var
  posicao: integer;
  info : TStringlist;
  a: integer;
  //FSetBanco : TSetBanco;
  auxiliar : string;
begin
    info := TStringlist.create();
    if (FileExists(Fpath+mfilename)) then
    begin
      farquivo.LoadFromFile(Fpath+mfilename);
      //CarregaContexto();
    end
    else
    begin
      default();
      //SalvaContexto(false);
    end;

    //Varre arquivo e busca por banco
    for a := 0 to Farquivo.Count-1 do
    begin
         info.clear;
         info.text := farquivo.Strings[a];
         if  BuscaChave(info,'BANCO:',posicao) then
         begin
           //FLSTBNC
           auxiliar :=  RetiraInfo(info.Strings[posicao]);
           FSetBanco := TSetBanco.create(auxiliar);
           if (FLstBNC <> nil) then
           begin
              FSetBanco.nrocfg := FLstBNC.Count;
           end;
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





