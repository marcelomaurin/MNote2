//Objetivo construir os parametros de setup da classe principal
//Criado por Marcelo Maurin Martins
//Data:07/02/2021

unit setproject;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, funcoes, graphics, controls, fpjson, jsonparser, Contnrs,
  SqlEditItem, NNTrainning;

//const filename = 'setproject.json';
type
  TProjectType = ( ptProject, ptDatabase, ptSQL, ptNNGroupNN, ptNNTrainning);
  TDatabaseType = ( dbNone, dbMysql, dbSQLSERVER, dbInterbase , dbOracle  );

type
  TTypeTrainning = ( ttNone, ttNLP, ttImageRec);

type
  { TfrmMenu }

  { Tsetproject }

  Tsetproject = class(TObject)

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
        FDllPath : string;
        FNomeProjeto : String;
        FFilename : String;
        FDiretorio : String;
        FDatabaseType : TDatabaseType;
        FStringConnection : String;
        FTypeTrainning : TTypeTrainning;

        FRunScript : string;    //Script de Compilação
        FDebugScript : string;  //Script de Debug
        FCleanScript : string;  //Script de Limpeza
        FInstall : string;      //Script de Instalacao
        FSqlItems :   TObjectList;
        FNNItems :   TObjectList;

        Fusername : string;
        Fpassword : string;
        FHostname : string;
        FDatabase : String;

        //filename : String;
        procedure SetDevice(const Value : Boolean);
        procedure SetPOSX(value : integer);
        procedure SetPOSY(value : integer);
        procedure SetFixar(value : boolean);
        procedure SetStay(value : boolean);
        procedure SetLastFiles(value : string);
        procedure SetFont(value : TFont);
        procedure SetCHATGPT(value : String);
        procedure SetDllPath( value : string);
        procedure SetNomeProjeto(value : string);
        procedure SetFilename(value : string);
        procedure SetDiretorio(value : String);
        procedure SetDatabaseType( value : TDatabaseType);
        procedure SetStringConnection( value: String);
        procedure SetTypeTrainning( value : TTypeTrainning);
        procedure SetUsername( value: String);
        procedure SetPassword( value: String);
        procedure SetHostName( value: String);
        procedure SetDatabase( value: string);
        procedure Default();
        function MontaSQLGroup(): String;
        function MontaNNTranningGroup(): String;
        function GetQueryCount() : integer;
        function GetNNCount() : integer;
  public
        constructor create();
        destructor Destroy();
        function sqlEditItem_indexof(item : TSQLEditItem) : integer;
        procedure SalvaContexto(flag : boolean);
        procedure SalvaContexto(Filename: string; flag : boolean);
        Procedure CarregaContexto();
        procedure IdentificaArquivo(flag : boolean);
        procedure addsql(item : TSQLEditItem);
        procedure addnntrainning(item : TNNTrainning);
        function SQLEdit_Indexof(posicao: integer): TSQLEditItem;
        function SQLEdit_ListName(): string;
        function NNTrainning_Indexof(posicao: integer): TNNTrainning;
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
        property DLLPath : String read FDllPath write SetDllPath;
        property NomeProjeto : String read FNomeProjeto write SetNomeProjeto;
        property Filename :String read FFilename write SetFilename;
        property Diretorio : String read FDiretorio write SetDiretorio;
        property DataBaseType : TDatabaseType read FDatabaseType write SetDatabaseType;
        property StringConnection : String read FStringConnection write SetStringConnection;
        property TypeTrainning : TTypeTrainning read FTypeTrainning write SetTypeTrainning;
        property Username : String read Fusername write SetUsername;
        property Password : String read Fpassword write SetPassword;
        property HostName : String read FHostname write SetHostName;
        property Database: string read FDatabase write SetDatabase;
        property Querycount : integer read GetQueryCount;
        property NNcount : integer read GetNNCount;




  end;

  var
    Fsetproject : Tsetproject;


implementation

procedure Tsetproject.SetDevice(const Value: Boolean);
begin
  ckdevice := Value;
end;


//Valores default do codigo
procedure Tsetproject.Default();
begin
    ckdevice := false;
    fixar:=false;
    stay:=false;
    FPosX :=100;
    FPosY := 100;
    FFixar :=false;
    FStay := false;
    FDllPath:= ExtractFilePath(ApplicationName);
    //FLastFiles :="";
    FPATH := ExtractFileDir(ApplicationName);
    FHeight :=400;
    FWidth :=400;
    FRunScript := '';   //Script de Run
    FDebugScript :='';  //Script de Debug
    FCleanScript :='';  //Script de Limpeza
    FInstall :='';      //Script de Instalacao
    FNomeProjeto:= 'New Name';
    if FFont = nil then
    begin
         FFONT := TFont.create();

    end;
    FCHATGPT:=''; //CHATGPT TOKEN


end;

procedure Tsetproject.SetPOSX(value: integer);
begin
    Fposx := value;
end;

procedure Tsetproject.SetPOSY(value: integer);
begin
    FposY := value;
end;

procedure Tsetproject.SetFixar(value: boolean);
begin
    FFixar := value;
end;

procedure Tsetproject.SetStay(value: boolean);
begin
    FStay := value;
end;

procedure Tsetproject.SetLastFiles(value: string);
begin
  FLastFiles:= value;
end;

procedure Tsetproject.SetFont(value: TFont);
begin
  //StringToFont(value,FFONT);
  FFont := value;
end;

procedure Tsetproject.SetCHATGPT(value: String);
begin
  FCHATGPT:= value;
end;

procedure Tsetproject.SetDllPath(value: string);
begin
  FDllPath:= value;
end;

procedure Tsetproject.SetNomeProjeto(value: string);
begin
  FNomeProjeto:= value;
  FFilename:= FNomeProjeto+'.json';
end;

procedure Tsetproject.SetFilename(value: string);
begin
  FFilename:= value;
end;

procedure Tsetproject.SetDiretorio(value: String);
begin
  FDiretorio:= value;
end;

procedure Tsetproject.SetDatabaseType(value: TDatabaseType);
begin
  FDatabaseType := value;
end;

procedure Tsetproject.SetStringConnection(value: String);
begin
  FStringConnection:= value;
end;

procedure Tsetproject.SetTypeTrainning(value: TTypeTrainning);
begin
  FTypeTrainning := value;
end;

procedure Tsetproject.SetUsername(value: String);
begin
  Fusername:= value;
end;

procedure Tsetproject.SetPassword(value: String);
begin
    Fpassword:= value;
end;

procedure Tsetproject.SetHostName(value: String);
begin
  FHostname:= value;
end;

procedure Tsetproject.SetDatabase(value: string);
begin
  FDatabase:= value;
end;

procedure Tsetproject.CarregaContexto();
var
  jsonData, sqlGroupData, sqlItemData: TJSONData;
  nnTrainningGroupData, nnTrainningItemData: TJSONData;
  jsonObject, sqlItemObject: TJSONObject;
  nntrainningItemObject: TJSONObject;
  jsonParser: TJSONParser;
  fileContents: TStringList;
  i: Integer;
  item: TSQLEditItem;
  itemNNTrainning : TNNTrainning;
begin
  fileContents := TStringList.Create;
  try
    fileContents.LoadFromFile(FDiretorio +'\'+ FFilename);
    jsonParser := TJSONParser.Create(fileContents.Text);
    try
      jsonData := jsonParser.Parse;
      if not Assigned(jsonData) then
        exit; // ou manipule o erro

      jsonObject := TJSONObject(jsonData);

      // Carregamento dos campos já existentes
      ckdevice := jsonObject.Get('DEVICE', false);
      FPOSX := jsonObject.Get('POSX', 0);
      FPOSY := jsonObject.Get('POSY', 0);
      FFixar := jsonObject.Get('FIXAR', false);
      FStay := jsonObject.Get('STAY', false);
      FLastFiles := jsonObject.Get('LASTFILES', '');
      FHEIGHT := jsonObject.Get('HEIGHT', 0);
      FWIDTH := jsonObject.Get('WIDTH', 0);
      FRunScript := jsonObject.Get('RUNSCRIPT', '');
      FDebugScript := jsonObject.Get('DEBUGSCRIPT', '');
      FCleanScript := jsonObject.Get('CLEANSCRIPT', '');
      FInstall := jsonObject.Get('INSTALLSCRIPT', '');
      FCHATGPT := jsonObject.Get('CHATGPT', '');
      FDLLPATH := jsonObject.Get('DLLPATH', '');
      FNomeProjeto := jsonObject.Get('NOMEPROJETO', '');
      FFilename := jsonObject.Get('FILENAME', '');
      FDiretorio:= jsonObject.Get('DIRETORIO', '');
      FStringConnection:= jsonObject.Get('STRINGCONNECTION', '');
      FDatabaseType:= TDatabasetype(strtoint(jsonObject.Get('DATABASETYPE', '0')));
      Fusername:= jsonObject.Get('USERNAME', '');
      Fpassword:= jsonObject.Get('PASSWORD', '');
      FHostname:= jsonObject.Get('HOSTNAME', '');
      FDatabase:= jsonObject.Get('DATABASE', '');


      // Processando o array SQLGroup
      sqlGroupData := jsonObject.FindPath('SQLGroup');
      if Assigned(sqlGroupData) and (sqlGroupData.JSONType = jtArray) then
      begin
        for i := 0 to sqlGroupData.Count - 1 do
        begin
          sqlItemData := sqlGroupData.Items[i];
          if (sqlItemData.JSONType = jtObject) then
          begin
            sqlItemObject := TJSONObject(sqlItemData).Find('SQLItem') as TJSONObject;
            if Assigned(sqlItemObject) then
            begin
              item := TSQLEditItem.Create;
              try
                item.Nome := sqlItemObject.Get('Nome', '');
                item.SQL := sqlItemObject.Get('SQL', '');
                addsql(item);
              finally
                //item.Free;
              end;
            end;
          end;
        end;
      end;

      // Processando o array NNTrainningGroup
      nntrainningGroupData := jsonObject.FindPath('NNTrainnigGroup');
      if Assigned(nntrainningGroupData) and (nntrainningGroupData.JSONType = jtArray) then
      begin
        for i := 0 to nntrainningGroupData.Count - 1 do
        begin
          nntrainningItemData := nntrainningGroupData.Items[i];
          if (nntrainningItemData.JSONType = jtObject) then
          begin
            nntrainningItemObject := TJSONObject(nntrainningItemData).Find('NNTrainningItem') as TJSONObject;
            if Assigned(nntrainningItemObject) then
            begin
              itemNNTrainning := TNNTrainning.Create;
              try
                itemNNTrainning.Nome := nntrainningItemObject.Get('Nome', '');
                itemNNTrainning.Commentario:= nntrainningItemObject.Get('Comentario', '');
                itemNNTrainning.SQLTrainning := TSQLEditItem(FSqlItems.Items[strtoint(nntrainningItemObject.Get('SQLTrainning', '-1'))]);
                itemNNTrainning.SQLTest := TSQLEditItem(FSqlItems.Items[strtoint(nntrainningItemObject.Get('SQLTest', '-1'))]);
                itemNNTrainning.ClassNNTrainning := TClasseNNTrainning(strtoint(nntrainningItemObject.Get('ClassNNTrainning', '-1')));
                itemNNTrainning.GroupBy := nntrainningItemObject.Get('GroupBy', ' ');
                itemNNTrainning.InputField := nntrainningItemObject.Get('InputField', ' ');
                itemNNTrainning.InputRef := nntrainningItemObject.Get('InputRef', ' ');
                itemNNTrainning.InputRefField := nntrainningItemObject.Get('InputRefField', ' ');
                itemNNTrainning.InputRefKey := nntrainningItemObject.Get('InputRefKey', ' ');
                itemNNTrainning.InputRefField := nntrainningItemObject.Get('InputRefField', ' ');
                //itemNNTrainning.InputCols := strtoint(nntrainningItemObject.Get('InputCols', ' '));
                itemNNTrainning.InputFieldTester := nntrainningItemObject.Get('InputFieldtester', ' ');
                itemNNTrainning.InputRefTester := nntrainningItemObject.Get('InputReftester', ' ');           //novo
                itemNNTrainning.InputRefFieldTester := nntrainningItemObject.Get('InputRefFieldtester', ' '); //novo
                itemNNTrainning.InputRefKeyTester := nntrainningItemObject.Get('InputRefKeytester', ' ');     //novo
                itemNNTrainning.InputRefFieldTester := nntrainningItemObject.Get('InputRefFieldtester', ' '); //novo

                itemNNTrainning.FilterCondition := nntrainningItemObject.Get('FilterCondition', ' ');
                itemNNTrainning.FilterConditionTester := nntrainningItemObject.Get('FilterConditiontester', ' ');

                itemNNTrainning.OutputField := nntrainningItemObject.Get('OutputField', ' ');
                itemNNTrainning.OutputFieldTester := nntrainningItemObject.Get('OutputFieldtester', ' '); //novo
                //itemNNTrainning.OutputCols := strtoint(nntrainningItemObject.Get('OutputCols', ' '));
                itemNNTrainning.Python := HexToStr(nntrainningItemObject.Get('Python', ' '));
                itemNNTrainning.jsontrainning := HexToStr(nntrainningItemObject.Get('JSONTrainning', ' '));
                itemNNTrainning.FilterValue:= nntrainningItemObject.Get('FilterValue', ' ');
                itemNNTrainning.FilterValueTester:= nntrainningItemObject.Get('FilterValuetester', ' '); //novo
                itemNNTrainning.fileJSONTester := nntrainningItemObject.Get('fileJSONtester', ' ');
                itemNNTrainning.JSONTester := HexToStr(nntrainningItemObject.Get('JSONtester', ' '));

                itemNNTrainning.valinputLeg.Text := HexToStr(nntrainningItemObject.Get('valinputLeg', '')); //novo
                itemNNTrainning.valoutputLeg.text := HexToStr(nntrainningItemObject.Get('valoutputLeg', '')); //novo
                addnntrainning(itemNNTrainning);
              finally
                //item.Free;
              end;
            end;
          end;
        end;
      end;

    finally
      jsonParser.Free;
    end;
  finally
    fileContents.Free;
  end;
end;


procedure Tsetproject.IdentificaArquivo(flag: boolean);
begin

  Fpath := FDiretorio +'\'+ FFilename;

  if (FileExists(fpath)) then
  begin
    arquivo.LoadFromFile(fpath);
    CarregaContexto();
  end
  else
  begin
    default();
    //SalvaContexto(false);
  end;

end;

procedure Tsetproject.addsql(item: TSQLEditItem);
begin

  FSqlItems.Add(TObject(item));
end;

procedure Tsetproject.addnntrainning(item: TNNTrainning);
begin
  FNNItems.Add(TObject(item));
end;

function Tsetproject.SQLEdit_Indexof(posicao: integer): TSQLEditItem;
begin
  if (FSqlItems <> nil) then
  begin
    if (posicao >= 0) and (posicao <= FSqlItems.Count - 1) then
    begin
      Result := FSqlItems.Items[posicao] as TSQLEditItem;
    end
    else
    begin
      Result := nil;
    end;
  end
  else
  begin
    result := nil;
  end;
end;

function Tsetproject.SQLEdit_ListName: string;
var
  cont : integer;
  resultado : string;

begin
  resultado := '';
  for cont:= 0 to FSqlItems.Count - 1 do
  begin
    resultado := resultado +  TSQLEditItem(FSqlItems.Items[cont]).Nome +#13;
  end;

  result := resultado;

end;

function Tsetproject.NNTrainning_Indexof(posicao: integer): TNNTrainning;
begin
  if (FNNItems <> nil) then
  begin
    if (posicao >= 0) and (posicao <= FNNItems.Count - 1) then
    begin
      Result := FNNItems.Items[posicao] as TNNTrainning;
    end
    else
    begin
      Result := nil;
    end;
  end
  else
  begin
    result := nil;
  end;
end;


//Metodo construtor
constructor Tsetproject.create();
begin
    arquivo := TStringList.create();
    FFONT := TFont.create();
    IdentificaArquivo(true);
    FSqlItems := TObjectList.create;
    FNNItems := TObjectList.create;
end;


function Tsetproject.MontaSQLGroup(): String;
var
  i: Integer;
  Item: TSQLEditItem;
  sqlItemsArray: TStringList;
begin
  sqlItemsArray := TStringList.Create;
  try
    for i := 0 to FSqlItems.Count - 1 do
    begin
      Item := TSQLEditItem(FSqlItems.Items[i]);
      if(i>0) then
      begin
            sqlItemsArray.Add(',');
      end;

      sqlItemsArray.Add(
        '{ "SQLItem": { "Nome":"' + PreparaJSON(Item.Nome) +
        '", "SQL":"' + PreparaJSON(Item.SQL) + '" } }'
      );
    end;

    // Constrói o grupo de SQLs como um array JSON
    Result := '"SQLGroup": [' + LineEnding +
              StringReplace(sqlItemsArray.text, ',', ',' + LineEnding, [rfReplaceAll]) +
              LineEnding + '],';
  finally
    sqlItemsArray.Free;
  end;
end;

function Tsetproject.MontaNNTranningGroup: String;
var
  i: Integer;
  Item: TNNTrainning;
  NNItemsArray: TStringList;
begin
  NNItemsArray := TStringList.Create;
  try
    for i := 0 to FNNItems.Count - 1 do
    begin
      Item := TNNTrainning(FNNItems.Items[i]);
      if(item <> nil) then
      begin
        if(i>0) then
        begin
              NNItemsArray.Add(',');
        end;
        NNItemsArray.Add(
          '{ "NNTrainningItem": { '+
          ' "Nome":"'+ PreparaJSON(Item.Nome)+'" '+
          ' ,"Comentario":"' + PreparaJSON(Item.Commentario) + '" '+
          ' ,"SQLTrainning":"' + PreparaJSON(inttostr(FSqlItems.IndexOf(Tobject(Item.SQLTrainning)))) + '" '+
          ' ,"SQLTest":"' + PreparaJSON(inttostr(FSqlItems.IndexOf(Tobject(Item.SQLTest)))) + '" '+
          ',"ClassNNTrainning": "' + PreparaJSON(inttostr(integer(Item.ClassNNTrainning))) + '" '  +
          ',"GroupBy": "' + PreparaJSON(Item.GroupBy) + '" '  +
          ',"InputField": "' + PreparaJSON(Item.InputField) + '" '  +
          ',"InputRef": "' + PreparaJSON(Item.InputRef) + '" '  +
          ',"InputRefField": "' + PreparaJSON(Item.InputRefField) + '" '  +
          ',"InputRefKey": "' + PreparaJSON(Item.InputRefKey) + '" '  +
          ',"InputCols": "' + PreparaJSON(inttostr(Item.InputCols)) + '" '  +
          ',"InputFieldtester": "' + PreparaJSON(Item.InputFieldtester) + '" '  +
          ',"InputReftester": "' + PreparaJSON(Item.InputReftester) + '" '  +
          ',"InputRefFieldtester": "' + PreparaJSON(Item.InputRefFieldtester) + '" '  + //novo
          ',"InputRefKeytester": "' + PreparaJSON(Item.InputRefKeytester) + '" '  +     //novo
          ',"valInputLeg": "' + PreparaJSON(StrToHex(Item.SavevalInputLeg())) + '" '  +     //novo
          ',"OutputField": "' + PreparaJSON(Item.OutputField) + '" '  +
          ',"OutputFieldtester": "' + PreparaJSON(Item.OutputFieldtester) + '" '  +     //novo
          ',"OutputCols": "' + PreparaJSON(inttostr(Item.OutputCols)) + '" '  +     //novo

          ',"FilterCondition": "' + PreparaJSON(Item.FilterCondition) + '" '  +     //novo
          ',"FilterConditiontester": "' + PreparaJSON(Item.FilterConditionTester) + '" '  +     //novo

          ',"valOutputLeg": "' + PreparaJSON(StrToHex(Item.SavevalOutputLeg())) + '" '  +     //novo
          ',"Python": "' + PreparaJSON(StrToHex(Item.Python)) + '" '  +
          ',"JSONTrainning": "' + PreparaJSON(StrToHex(Item.jsontrainning)) + '" ' +
          ',"FilterValue": "' + PreparaJSON(Item.FilterValue) + '" ' +
          ',"FilterValuetester": "' + PreparaJSON(Item.FilterValuetester) + '" ' +
          ',"fileJSONtester": "' + PreparaJSON(Item.fileJSONTester) + '" '  +
          ',"JSONtester": "' + PreparaJSON(StrToHex(Item.JSONTester)) + '" '  +
          ',"valinputLeg": "' + PreparaJSON(StrToHex(Item.valinputLeg.text)) + '" '  +
          ',"valoutputLeg": "' + PreparaJSON(StrToHex(Item.valoutputLeg.text)) + '" '  +
          '} }'
        );
      end;
    end;

    // Constrói o grupo de SQLs como um array JSON
    Result := '"NNTrainnigGroup": [' + LineEnding +
              StringReplace(NNItemsArray.text, ',', ',' + LineEnding, [rfReplaceAll]) +
              LineEnding + ']';
  finally
    NNItemsArray.Free;
  end;
end;

function Tsetproject.GetQueryCount: integer;
begin
  result := FSqlItems.Count;
end;

function Tsetproject.GetNNCount: integer;
begin
  result := FNNItems.Count;
end;




procedure Tsetproject.SalvaContexto(flag: boolean);
var
  jsonString: String;
  arquivo1 : string;
begin
  if (flag) then
  begin
    IdentificaArquivo(false);
  end;

  jsonString := '{' + LineEnding +
    '"DEVICE": "' + iif(ckdevice,'1','0') + '",' + LineEnding +
    '"POSX": "' + IntToStr(FPOSX) + '",' + LineEnding +
    '"POSY": "' + IntToStr(FPOSY) + '",' + LineEnding +
    '"FIXAR": "' + BoolToStr(FFixar) + '",' + LineEnding +
    '"STAY": "' + BoolToStr(FStay) + '",' + LineEnding +
    '"LASTFILES": "' + FLastFiles + '",' + LineEnding +
    '"HEIGHT": "' + IntToStr(FHEIGHT) + '",' + LineEnding +
    '"WIDTH": "' + IntToStr(FWIDTH) + '",' + LineEnding +
    '"RUNSCRIPT": "' + FRunScript + '",' + LineEnding +
    '"DEBUGSCRIPT": "' + PreparaJSON(FDebugScript) + '",' + LineEnding +
    '"CLEANSCRIPT": "' + PreparaJSON(FCleanScript) + '",' + LineEnding +
    '"INSTALLSCRIPT": "' + PreparaJSON(FInstall) + '",' + LineEnding +
    '"CHATGPT": "' + PreparaJSON(FCHATGPT) + '",' + LineEnding +
    '"DLLPATH": "' + PreparaJSON(FDLLPATH) + '",' + LineEnding +
    '"NOMEPROJETO": "' + PreparaJSON(FNomeProjeto) + '",' + LineEnding +
    '"FILENAME": "' + PreparaJSON(FFilename) + '",' + LineEnding +
    '"DIRETORIO": "' + PreparaJSON(FDiretorio) + '",' + LineEnding +
    '"STRINGCONNECTION": "' + PreparaJSON(FStringConnection) + '",' + LineEnding +
    '"DATABASETYPE": "' + inttostr(integer(FDatabaseType)) + '",' + LineEnding +
    '"USERNAME": "' + PreparaJSON(Fusername) + '",' + LineEnding +
    '"PASSWORD": "' + PreparaJSON(Fpassword) + '",' + LineEnding +
    '"DATABASE": "' + PreparaJSON(FDatabase) + '",' + LineEnding +
    '"HOSTNAME": "' + PreparaJSON(FHostname) + '",' + LineEnding +
    MontaSQLGroup()+
    MontaNNTranningGroup()+
    '}';

  // Salva a string JSON em um arquivo
  with TStringList.Create do
  try
    Text := jsonString;
    arquivo1 := FDiretorio +'\'+ ffilename;
    SaveToFile(arquivo1);
  finally
    Free;
  end;
end;

procedure Tsetproject.SalvaContexto(Filename: string; flag: boolean);
begin
  ffilename:= Filename;
  SalvaContexto(false);

end;


destructor Tsetproject.Destroy;
begin
  //SalvaContexto(false);
  arquivo.free;
  arquivo := nil;
  FFONT.free;
end;

function Tsetproject.sqlEditItem_indexof(item: TSQLEditItem): integer;
var
  cont : integer;
  posicao : integer;
begin
  posicao := -1;
  for cont := 0 to FSqlItems.Count - 1 do
  begin
       if (TSQLEditItem(FSqlItems.Items[cont])= item) then
       begin
            posicao := cont;
       end;
  end;
  result := posicao ;
end;

end.




