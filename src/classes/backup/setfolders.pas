//Objetivo construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data:07/02/2021

unit setFolders;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes;

const filename = 'Setfolders.cfg';


type
  { TfrmFolders }

  { TSetFolders }

  TSetFolders = class(TObject)
    constructor create();
    destructor destroy();
  private
        arquivo :Tstringlist;
        ckdevice : boolean;
        FPosX : integer;
        FPosY : integer;
        FFixar : boolean;
        FStay : boolean;
        FLastFiles : String;
        FPATH : string;
        FDefaultfolder : string;
        FHeight : integer;
        FWidth : integer;
        //filename : String;
        procedure SetDevice(const Value : Boolean);
        procedure SetPOSX(value : integer);
        procedure SetPOSY(value : integer);
        procedure SetFixar(value : boolean);
        procedure SetStay(value : boolean);
        procedure SetLastFiles(value : string);
        procedure SetDefaultFolder(value: string);
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
        property lastfiles: string read FLastFiles write SetLastFiles;
        property DefaultFolder : string read FDefaultFolder write SetDefaultFolder;
        property Height: integer read FHeight write FHeight;
        property Width : integer read FWidth write FWidth;
  end;

  var
    FSetFolders : TSetFolders;


implementation

procedure TSetFolders.SetDevice(const Value: Boolean);
begin
  ckdevice := Value;
end;


//Valores default do codigo
procedure TSetFolders.Default();
begin
    ckdevice := false;
    fixar:=false;
    stay:=false;
end;

procedure TSetFolders.SetPOSX(value: integer);
begin
    Fposx := value;
end;

procedure TSetFolders.SetPOSY(value: integer);
begin
    FposY := value;
end;

procedure TSetFolders.SetFixar(value: boolean);
begin
    FFixar := value;
end;

procedure TSetFolders.SetStay(value: boolean);
begin
    FStay := value;
end;

procedure TSetFolders.SetLastFiles(value: string);
begin
  FLastFiles:= value;
end;

procedure TSetFolders.SetDefaultFolder(value: string);
begin
  FDefaultfolder:=value;
end;

procedure TSetFolders.CarregaContexto();
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
    if  BuscaChave(arquivo,'DEFAULTFOLDER:',posicao) then
    begin
      FDefaultFolder := RetiraInfo(arquivo.Strings[posicao]);
    end;
    if  BuscaChave(arquivo,'HEIGHT:',posicao) then
    begin
      FHEIGHT := strtoint(RetiraInfo(arquivo.Strings[posicao]));
    end;
    if  BuscaChave(arquivo,'WIDTH:',posicao) then
    begin
      FWidth := strtoint(RetiraInfo(arquivo.Strings[posicao]));
    end;


end;


procedure TSetFolders.IdentificaArquivo(flag: boolean);
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
    SalvaContexto(false);
  end;

end;

//Metodo construtor
constructor TSetFolders.create();
begin
    Default();
    arquivo := TStringList.create();
    IdentificaArquivo(true);

end;


procedure TSetFolders.SalvaContexto(flag: boolean);
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
  arquivo.Append('DEFAULTFOLDER:'+FDefaultfolder);
  arquivo.Append('HEIGHT:'+inttostr(FHEIGHT));
  arquivo.Append('WIDTH:'+inttostr(FWIDTH);


  arquivo.SaveToFile(fpath+filename);
end;

destructor TSetFolders.destroy();
begin
  SalvaContexto(true);
  arquivo.free;
  arquivo := nil;
end;

end.




