//Objetivo construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data:07/02/2021

unit setbanco;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes, TypeDB;

const mfilename = 'Setbanco%d.cfg';


type
  { TfrmMenu }

  { TSetBanco }

  TSetBanco = class(TObject)
    constructor create(pnrocfg: integer);
    destructor destroy();
  private
        arquivo :Tstringlist;
        FHostName : String;
        FTipoBanco : TypeDatabase;
        FUser : String;
        FPassword : String;
        filename : string;
        FDatabasename : String;
        FNroCfg : integer;
        FScheme : String;
        FPATH : string;
        FPORT : String;
        procedure SetTipoBanco(value : TypeDatabase);
        procedure SetHostName(value : string);
        procedure SetUser(value : string);
        procedure SetPassword(value : string);
        procedure SetDatabasename(value : string);
        procedure SetScheme(value : string);
        procedure SetPort(value: string);

        procedure Default();
  public

        procedure SalvaContexto(flag : boolean);
        Procedure CarregaContexto();
        procedure IdentificaArquivo(flag : boolean);
        property HostName: string read FHostName write SetHostName;
        property User: string read FUser write SetUser;
        property Password: string read FPassword write SetPassword;
        property TipoBanco: TypeDatabase read FTipoBanco write SetTipoBanco;
        property Databasename: String read FDatabasename write SetDatabaseName;
        property nrocfg : integer read FNrocfg;
        property Scheme : String read FScheme write SetScheme;
        property Port : string read FPort write SetPort;
  end;

  var
    FSetBanco : TSetBanco;


implementation

procedure TSetBanco.SetScheme(value : string);
begin
  FScheme := value;
end;

procedure TSetBanco.SetPort(value: string);
begin
  Fport := value;
end;

procedure TSetBanco.SetDatabasename(value : string);
begin
  FDatabasename := value;
end;

procedure TSetBanco.SetPassword(value : string);
begin
  FPassword := value;
end;


procedure TSetBanco.SetUser(value : string);
begin
  FUser := value;
end;


procedure TSetBanco.SetHostName(value : string);
begin
  FHostName := value;
end;

procedure TSetBanco.SetTipoBanco(value : TypeDatabase);
begin
  FTipoBanco := value;
end;



//Valores default do codigo
procedure TSetBanco.Default();
begin
    FDatabasename:='[database name]';
    FPassword := '[password]';
    FUser:='[username]';
    FHostName:='127.0.0.1';
end;


procedure TSetBanco.CarregaContexto();
var
  posicao: integer;
begin
    if  BuscaChave(arquivo,'TIPOBANCO:',posicao) then
    begin
      FTipoBanco := TypeDatabase(strtoint(RetiraInfo(arquivo.Strings[posicao])));
    end;
    if  BuscaChave(arquivo,'DATABASENAME:',posicao) then
    begin
      FDatabasename := RetiraInfo(arquivo.Strings[posicao]);
    end;
    if  BuscaChave(arquivo,'USER:',posicao) then
    begin
      FUser := RetiraInfo(arquivo.Strings[posicao]);
    end;
    if  BuscaChave(arquivo,'HOSTNAME:',posicao) then
    begin
      FHostName := RetiraInfo(arquivo.Strings[posicao]);
    end;
    if  BuscaChave(arquivo,'NFORCFG:',posicao) then
    begin
      FNroCfg := strtoint(RetiraInfo(arquivo.Strings[posicao]));
    end;
    if  BuscaChave(arquivo,'PASSWORD:',posicao) then
    begin
      FPassword := RetiraInfo(arquivo.Strings[posicao]);
    end;
    if  BuscaChave(arquivo,'PORT:',posicao) then
    begin
      FPORT := RetiraInfo(arquivo.Strings[posicao]);
    end;

end;


procedure TSetBanco.IdentificaArquivo(flag: boolean);
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

  filename := format(mfilename,[Fnrocfg]);

  if (FileExists(Fpath+filename)) then
  begin
    arquivo.LoadFromFile(Fpath+filename);
    CarregaContexto();
  end
  else
  begin
    default();
    SalvaContexto(false);
  end;

end;

//Metodo construtor
constructor TSetBanco.create(pnrocfg: integer);
begin
    FNroCfg := pnrocfg;
    filename := format(mfilename,[Fnrocfg]);
    arquivo := TStringList.create();
    IdentificaArquivo(true);

end;


procedure TSetBanco.SalvaContexto(flag: boolean);
begin
  if (flag) then
  begin
    IdentificaArquivo(false);
  end;
  //filename := 'Work'+ FormatDateTime('ddmmyy',now())+'.cfg';
  arquivo.Clear;
  arquivo.Append('TIPOBANCO:'+inttostr(integer(FTipoBanco)));
  arquivo.Append('HOSTNAME:'+FHostName);
  arquivo.Append('DATABASENAME:'+FDatabasename);
  arquivo.Append('NROCFG:'+inttostr(FNroCfg));
  arquivo.Append('SCHEME:'+FScheme);
  arquivo.Append('USER:'+FUser);
  arquivo.Append('PASSWORD:'+FPassword);
  arquivo.Append('PORT:'+FPORT);
  arquivo.SaveToFile(Fpath+filename);
end;

destructor TSetBanco.destroy();
begin
  SalvaContexto(true);
  arquivo.free;
  arquivo := nil;
end;

end.




