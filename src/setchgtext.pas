//Objetivo construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data:07/02/2021

unit setchgtext;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes;

const filename = 'Setchgtext.cfg';


type
  { TfrmMenu }

  { TSetMain }

  TSetchgtext = class(TObject)
    constructor create();
    destructor destroy();
  private
        arquivo :Tstringlist;
        ckdevice : boolean;
        FPosX : integer;
        FPosY : integer;
        FFixar : boolean;
        FStay : boolean;
        FIdioma : string;
        FLastFiles : String;
        FPATH : string;
        //filename : String;
        procedure SetDevice(const Value : Boolean);
        procedure SetPOSX(value : integer);
        procedure SetPOSY(value : integer);
        procedure SetFixar(value : boolean);
        procedure SetStay(value : boolean);
        procedure SetLastFiles(value : string);
        procedure SetIdioma(value : string);
        procedure Default();
  public
        procedure SalvaContexto(flag : boolean);
        Procedure CarregaContexto();
        procedure IdentificaArquivo(flag : boolean);
        property device : boolean read ckdevice write SetDevice;
        property posx : integer read FPosX write SetPOSX;
        property posy : integer read FPosY write SetPOSY;
        property fixar : boolean read FFixar write SetFixar;
        property stay : boolean read FStay write SetStay;
        property Idioma : string read FIdioma write SetIdioma;
        property lastfiles: string read FLastFiles write SetLastFiles;
  end;

  var
    FSetchgtext : TSetchgtext;


implementation


procedure TSetchgtext.SetIdioma(value : string);
begin
    fIdioma := value;
end;

procedure TSetchgtext.SetDevice(const Value: Boolean);
begin
  ckdevice := Value;
end;


//Valores default do codigo
procedure TSetchgtext.Default();
begin
    ckdevice := false;
    fixar:=false;
    stay:=false;
    FIdioma := 'PORTUGUESE';
end;

procedure TSetchgtext.SetPOSX(value: integer);
begin
    Fposx := value;
end;

procedure TSetchgtext.SetPOSY(value: integer);
begin
    FposY := value;
end;

procedure TSetchgtext.SetFixar(value: boolean);
begin
    FFixar := value;
end;

procedure TSetchgtext.SetStay(value: boolean);
begin
    FStay := value;
end;

procedure TSetchgtext.SetLastFiles(value: string);
begin
  FLastFiles:= value;
end;

procedure TSetchgtext.CarregaContexto();
var
  posicao: integer;
begin
    if  BuscaChave(arquivo,'DEVICE:',posicao) then
    begin
      ckdevice := (RetiraInfo(arquivo.Strings[posicao])='1');
    end;
    if  BuscaChave(arquivo,'POSX:',posicao) then
    begin
      FPOSX := strtoint(RetiraInfo(arquivo.Strings[posicao]));
    end;
    if  BuscaChave(arquivo,'POSY:',posicao) then
    begin
      FPOSY := strtoint(RetiraInfo(arquivo.Strings[posicao]));
    end;
    if  BuscaChave(arquivo,'FIXAR:',posicao) then
    begin
      FFixar := StrToBool(RetiraInfo(arquivo.Strings[posicao]));
    end;
    if  BuscaChave(arquivo,'STAY:',posicao) then
    begin
      FStay := strtoBool(RetiraInfo(arquivo.Strings[posicao]));
    end;
    if  BuscaChave(arquivo,'LASTFILES:',posicao) then
    begin
      FLastFiles := RetiraInfo(arquivo.Strings[posicao]);
    end;
    if  BuscaChave(arquivo,'IDIOMA:',posicao) then
    begin
      FIdioma := RetiraInfo(arquivo.Strings[posicao]);
    end;
end;


procedure TSetchgtext.IdentificaArquivo(flag: boolean);
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

  if (FileExists(fpath+filename)) then
  begin
    arquivo.LoadFromFile(fpath+filename);
    CarregaContexto();
  end
  else
  begin
    default();
    //SalvaContexto(false);
  end;

end;

//Metodo construtor
constructor TSetchgtext.create();
begin
    arquivo := TStringList.create();
    IdentificaArquivo(true);

end;


procedure TSetchgtext.SalvaContexto(flag: boolean);
begin
  if (flag) then
  begin
    IdentificaArquivo(false);
  end;
  //filename := 'Work'+ FormatDateTime('ddmmyy',now())+'.cfg';
  arquivo.Clear;
  arquivo.Append('DEVICE:'+iif(ckdevice,'1','0'));
  arquivo.Append('POSX:'+inttostr(FPOSX));
  arquivo.Append('POSY:'+inttostr(FPOSY));
  arquivo.Append('FIXAR:'+booltostr(FFixar));
  arquivo.Append('STAY:'+booltostr(FStay));
  arquivo.Append('LASTFILES:'+FLastFiles);
  arquivo.Append('IDIOMA:'+FIDIOMA);

  arquivo.SaveToFile(fpath+filename);
end;

destructor TSetchgtext.destroy();
begin
  SalvaContexto(true);
  arquivo.free;
  arquivo := nil;
end;

end.





