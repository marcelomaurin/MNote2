//Objetivo construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data:07/02/2021

unit setmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes, graphics;

const filename = 'Setmain.cfg';


type
  { TfrmMenu }

  { TSetMain }

  TSetMain = class(TObject)

  private
        arquivo :Tstringlist;
        ckdevice : boolean;
        FPosX : integer;
        FPosY : integer;
        FFixar : boolean;
        FStay : boolean;
        FLastFiles : String;
        FPATH : string;
        FHeight : integer;
        FWidth : integer;
        FFONT : TFont;
        FCHATGPT : string;

        FRunScript : string;    //Script de Compilação
        FDebugScript : string;  //Script de Debug
        FCleanScript : string;  //Script de Limpeza
        FInstall : string;      //Script de Instalacao

        //filename : String;
        procedure SetDevice(const Value : Boolean);
        procedure SetPOSX(value : integer);
        procedure SetPOSY(value : integer);
        procedure SetFixar(value : boolean);
        procedure SetStay(value : boolean);
        procedure SetLastFiles(value : string);
        procedure SetFont(value : TFont);
        procedure SetCHATGPT(value : String);
        procedure Default();
  public
        constructor create();
        destructor Destroy();
        procedure SalvaContexto(flag : boolean);
        Procedure CarregaContexto();
        procedure IdentificaArquivo(flag : boolean);
        property device : boolean read ckdevice write SetDevice;
        property posx : integer read FPosX write SetPOSX;
        property posy : integer read FPosY write SetPOSY;
        property fixar : boolean read FFixar write SetFixar;
        property stay : boolean read FStay write SetStay;
        property lastfiles: string read FLastFiles write SetLastFiles;
        property Height: integer read FHeight write FHeight;
        property Width : integer read FWidth write FWidth;
        property RunScript : string read FRunScript write FRunScript;
        property DebugScript : string read FDebugScript write FDebugScript;
        property CleanScript : string read FCleanScript write FCleanScript;
        property Install : string read FInstall write FInstall;
        property Font : TFont read FFont write SetFont;
        property CHATGPT: String read FCHATGPT write SetCHATGPT;
  end;

  var
    FSetMain : TSetMain;


implementation

procedure TSetMain.SetDevice(const Value: Boolean);
begin
  ckdevice := Value;
end;


//Valores default do codigo
procedure TSetMain.Default();
begin
    ckdevice := false;
    fixar:=false;
    stay:=false;
    FPosX :=100;
    FPosY := 100;
    FFixar :=false;
    FStay := false;
    //FLastFiles :="";
    //    FPATH : string;
    FHeight :=400;
    FWidth :=400;
    FRunScript := '';   //Script de Run
    FDebugScript :='';  //Script de Debug
    FCleanScript :='';  //Script de Limpeza
    FInstall :='';      //Script de Instalacao
    if FFont = nil then
    begin
         FFONT := TFont.create();

    end;
    FCHATGPT:=''; //CHATGPT TOKEN


end;

procedure TSetMain.SetPOSX(value: integer);
begin
    Fposx := value;
end;

procedure TSetMain.SetPOSY(value: integer);
begin
    FposY := value;
end;

procedure TSetMain.SetFixar(value: boolean);
begin
    FFixar := value;
end;

procedure TSetMain.SetStay(value: boolean);
begin
    FStay := value;
end;

procedure TSetMain.SetLastFiles(value: string);
begin
  FLastFiles:= value;
end;

procedure TSetMain.SetFont(value: TFont);
begin
  //StringToFont(value,FFONT);
  FFont := value;
end;

procedure TSetMain.SetCHATGPT(value: String);
begin
  FCHATGPT:= value;
end;

procedure TSetMain.CarregaContexto();
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
    if  BuscaChave(arquivo,'HEIGHT:',posicao) then
    begin
      FHEIGHT := strtoint(RetiraInfo(arquivo.Strings[posicao]));
    end;
    if  BuscaChave(arquivo,'WIDTH:',posicao) then
    begin
      FWidth := strtoint(RetiraInfo(arquivo.Strings[posicao]));
    end;
    if  BuscaChave(arquivo,'RUNSCRIPT:',posicao) then
    begin
      FRunScript := RetiraInfo(arquivo.Strings[posicao]);
    end;
    if  BuscaChave(arquivo,'DEBUGSCRIPT:',posicao) then
    begin
      FDebugScript := RetiraInfo(arquivo.Strings[posicao]);
    end;
    if  BuscaChave(arquivo,'CLEANSCRIPT:',posicao) then
    begin
      FCleanScript := RetiraInfo(arquivo.Strings[posicao]);
    end;
    if  BuscaChave(arquivo,'INSTALLSCRIPT:',posicao) then
    begin
      FInstall := RetiraInfo(arquivo.Strings[posicao]);
    end;
    if  BuscaChave(arquivo,'FONT:',posicao) then
    begin
      StringToFont(RetiraInfo(arquivo.Strings[posicao]),FFONT);
    end;
    if  BuscaChave(arquivo,'CHATGPT:',posicao) then
    begin
      FCHATGPT := RetiraInfo(arquivo.Strings[posicao]);
    end;

end;


procedure TSetMain.IdentificaArquivo(flag: boolean);
begin
  //filename := 'Work'+ FormatDateTime('ddmmyy',now())+'.cfg';
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
constructor TSetMain.create();
begin
    arquivo := TStringList.create();
    FFONT := TFont.create();
    IdentificaArquivo(true);


end;


procedure TSetMain.SalvaContexto(flag: boolean);
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
  arquivo.Append('HEIGHT:'+inttostr(FHEIGHT));
  arquivo.Append('WIDTH:'+inttostr(FWIDTH));
  arquivo.Append('RUNSCRIPT:'+FRunScript);
  arquivo.Append('DEBUGSCRIPT:'+FDebugScript);
  arquivo.Append('CLEANSCRIPT:'+FCleanScript);
  arquivo.Append('INSTALLSCRIPT:'+FInstall);
  arquivo.Append('FONT:'+FontToString(FFONT));
  arquivo.Append('CHATGPT:'+FCHATGPT);

  arquivo.SaveToFile(fpath+filename);
end;

destructor TSetMain.Destroy;
begin
  //SalvaContexto(false);
  arquivo.free;
  arquivo := nil;
  FFONT.free;
end;

end.




