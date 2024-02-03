unit NNTrainning;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, base, pythonRun , sqledititem, Dialogs, funcoes2, grids,
  PythonEngine, FileUtil;



type
  TClasseNNTrainning = (CN_NONE, CN_RecImg, CN_NLPNeuralNetwork);

type

  { TNNTrainning }

  TNNTrainning = class(TObject)
  private
    FJSONTest: string;
    FNome: string;
    FComentario : string;
    FClassNNTrainning :  TClasseNNTrainning;
    FSQL: string;
    FEntradas : integer;
    FSaidas: integer;
    FPythonRunner: TPythonRunner;
    //FPythonEngine : TPythonEngine;
    FsqlTrainning : TSqlEditItem;
    FsqlTester : TSqlEditItem;           //Novo
    Fgroupby : String;
    FgroupbyTester : String; //Novo
    FInputField : String;
    FInputRef: string;
    FInputRefField : string;
    FInputRefKey: string;

    FInputFieldTester : String;        //Novo
    FInputRefTester: string;           //Novo
    FInputRefFieldTester : string;     //Novo
    FInputRefKeyTester: string;        //Novo

    FOutputField : String;
    FOutputFieldTester : String; //Novo
    FPython : String;
    Fjsontrainning : String;
    FFilterValue : string;
    FFilterValueTester : string; //Novo
    FfileJSONTester : string;
    FJSONTester : string; //Novo
    FFilterCondition: string; //Novo
    FFilterConditionTester: string; //Novo
    FList: TStringlist;
    FPythonlog : TPythonOutputEvent;
    FPythonlogTester : TPythonOutputEvent;
    Flogtrainning : String;
    FvalinputLeg : TStringList;  //Legenda da etiqueta
    valinput : TStringGrid;     //Valor da entrada
    FvaloutputLeg : TStringList; //Legenda da etiqueta de saida
    valoutput : TStringGrid;    //Valor da saida

    function GeraSQLTrainning: String;
    function GeraSQLTester: String;
    procedure CriaDatasetTrainning();
    procedure CriaDatasetTester();
    function CriaJSONTrainning() :string;
    function CriaJSONTester() :string;
    function GetCommentario: string;
    function GetGroupByTester: string;
    function GetInputCols: integer;

    function GetNome: string;
    function GetEntrada : integer;
    function GetOutputCols: integer;

    function GetSaida : integer;
    function GetSQLTrainning: TSqlEditItem;
    function GetSQLTest: TSqlEditItem;
    function GetGroupBy : String;
    procedure SetCommentario(AValue: string);
    procedure SetFilterValueTester(AValue: string);
    procedure SetGroupByTester(AValue: string);
    procedure SetInputFieldTester(AValue: string);
    procedure SetNome(AValue: string);
    procedure SetClassNNTrainning(AValue: TClasseNNTrainning);
    procedure SetComentario(AValue : String);
    procedure SetEntradas(AValue : integer);
    procedure SetOutputFieldTester(AValue: string);
    procedure SetSaidas(AValue: integer);
    procedure SetInputField(AValue: String);
    procedure SetOutputField(AValue : String);
    procedure SetFilterValue(AValue : string);
    procedure SetGroupBy(AValue: String);
    procedure SetSQLTest(AValue: TSqlEditItem);
    procedure SetSQLTrainning(AValue: TSqlEditItem);

    //function CriarJsonTrainning(): string;

    procedure ExecutaTrainamento(pythonfile : string; jsonfile : string; var Output : String);
    function busca_referencia(palavras: TStringList): TStringList;
    procedure AddValor(inputvaluestr: TStringList; outputvalue: Integer);
    procedure AddValorTester(inputvaluestr: TStringList; outputvalue: Integer);
    procedure InicializaStringGrids();
    procedure InicializaStringGridsTester();
  public
    constructor create();
    destructor destroy();
    function RunTrainning() : boolean;
    function ListClasseNNTrainning(): string;
    function trainnerJSON() : boolean;
    function testerJSON(marca : string): boolean;
    procedure AddTest(query_index: integer);
    procedure LoadvalInputLeg(valores: string);
    procedure LoadvalOutputLeg(valores: string);
    function SavevalInputLeg(): string;
    function SavevalOutputLeg(): string;
    procedure AddTrainning(query_index: integer);
    property Nome: string read GetNome write SetNome;
    property Commentario : string read GetCommentario write SetCommentario;
    property ClassNNTrainning : TClasseNNTrainning read FClassNNTrainning write SetClassNNTrainning;
    property SQLTrainning: TSqlEditItem read GetSQLTrainning write SetSQLTrainning;
    property SQLTest: TSqlEditItem read GetSQLTest write SetSQLTest;
    property Entradas : integer read FEntradas;
    property Saidas: integer read FSaidas;
    property GroupBy : string read GetGroupBy write SetGroupBy;
    property GroupByTester : string read GetGroupByTester write SetGroupByTester;
    property InputField: string read FInputField write SetInputField;
    property InputRef : String read  FInputRef write FInputRef; //novo
    property InputRefField : string read FInputRefField write FInputRefField; //novo
    property InputRefKey : string read FInputRefKey write FInputRefKey; //novo
    property InputCols : integer read GetInputCols ;

    property InputFieldTester: string read FInputFieldTester write SetInputFieldTester;
    property InputRefTester : String read  FInputRefTester write FInputRefTester; //novo
    property InputRefFieldTester : string read FInputRefFieldTester write FInputRefFieldTester; //novo
    property InputRefKeyTester : string read FInputRefKeyTester write FInputRefKeyTester; //novo

    property OutputField : string read FOutputField write SetOutputField;
    property OutputCols : integer read GetOutputCols  ;
    property OutputFieldTester : string read FOutputFieldTester write SetOutputFieldTester;


    property Python : String read FPython write FPython;
    property jsontrainning: string read Fjsontrainning write Fjsontrainning;
    property FilterValue : string read FFilterValue write SetFilterValue;
    property FilterValueTester : string read FFilterValueTester write SetFilterValueTester;
    property fileJSONTester : string read FfileJSONTester write FfileJSONTester;
    property JSONTester : string read FJSONTest write FJSONTest;
    property Pythonlog : TPythonOutputEvent read FPythonlog write FPythonLog;
    property PythonlogTester : TPythonOutputEvent read FPythonlogTester write FPythonLogTester;
    //property PythonEngine : TPythonEngine read FPythonEngine write FPythonEngine;
    property PythonRunner : TPythonRunner read FPythonRunner write FPythonRunner;
    property logtrainning :  string read Flogtrainning;
    property FilterCondition : string read FFilterCondition write FFilterCondition;
    property FilterConditionTester : string read FFilterConditionTester write FFilterConditionTester;
    property valinputLeg : TStringList read FvalinputLeg write FvalinputLeg;          //Novo
    property valoutputLeg : TStringList read FvaloutputLeg write FvaloutputLeg;       //Novo


  end;

implementation

uses setproject;

function TNNTrainning.GeraSQLTrainning: String;
var

  resultado : string;
begin
  //FFilterCondition := '';
  if(FFilterValue<>'') then
  begin
    // Exibe uma caixa de diálogo para o usuário inserir a condição de filtro
    if InputQuery('Condição de Filtro', 'Por favor, insira a condição de filtro para ' + FFilterValue + ':', FFilterCondition) then
    begin
      // Construindo a consulta SQL
      resultado := FsqlTrainning.SQL + ' WHERE ' + FFilterValue + ' like ''' + FFilterCondition + ''''  ;
      if(not Fgroupby.IsEmpty()) then
         resultado := resultado + ' GROUP BY ' + Fgroupby;
    end
    else
    begin
      // O usuário cancelou a entrada, pode-se lidar com isso de maneira apropriada
      resultado := '';
    end;
  end
  else
  begin
    resultado := FsqlTrainning.SQL+' '  ;
  end;
  RESULT := resultado;
end;

function TNNTrainning.GeraSQLTester: String;
var
  resultado : string;
begin

  FFilterConditionTester := FFilterCondition;
  if(FFilterValueTester<>'') then
  begin
    //Não precisa perguntar pois já sabe no projeto
    //if InputQuery('Condição de Filtro', 'Por favor, insira a condição de filtro para ' + FFilterValueTester + ':', FFilterConditionTester) then

    // Construindo a consulta SQL
    resultado := FsqlTester.SQL + ' WHERE ' + FFilterValueTester + ' like ''' + FFilterConditionTester + ''''  ;
    if(not FgroupbyTester.IsEmpty()) then
    begin
       resultado := resultado + ' GROUP BY ' + FgroupbyTester;
    end;

  end
  else
  begin
    resultado := FsqlTester.SQL+' '  ;
  end;
  RESULT := resultado;
end;


procedure TNNTrainning.CriaDatasetTrainning();
var
  SQLString: string;
  OutputValue: Integer;
  InputValueStr : TStringList;
  InputValue : TStringList;
begin
  if (FList = nil) then
  begin
    FList := TStringList.create();
  end;

  with dmbase.zqryAux do
  begin
    if Active then
      Close; // Fechar a query caso esteja aberta

    Open; // Executar a consulta

    // Verificar o número de registros
    if RecordCount > 0 then
    begin
      //ShowMessage('Número de registros: ' + IntToStr(RecordCount));

      FList.Clear; // Limpar a lista antes de preenchê-la

      // Percorrer os registros e adicionar à lista
      First; // Posicionar no primeiro registro
      while not EOF do
      begin
        InputValueStr := splitstr(FieldByName(FInputField).Asstring);
        InputValue:= busca_referencia( InputValueStr);


        OutputValue := FieldByName(FOutputField).AsInteger;

        AddValor(InputValue, OutputValue); //Inclui as listas associadas


        Next; // Avançar para o próximo registro
      end;

      Close; // Fechar a query caso esteja aberta
    end
    else
      ShowMessage('Nenhum registro encontrado.');
  end;
end;

procedure TNNTrainning.CriaDatasetTester;
var
  SQLString: string;
  OutputValue: Integer;
  InputValueStr : TStringList;
  InputValue : TStringList;
begin
  if (FList = nil) then
  begin
    FList := TStringList.create();
  end;

  with dmbase.zqryAux do
  begin
    if Active then
      Close; // Fechar a query caso esteja aberta

    Open; // Executar a consulta

    // Verificar o número de registros
    if RecordCount > 0 then
    begin
      //ShowMessage('Número de registros: ' + IntToStr(RecordCount));

      FList.Clear; // Limpar a lista antes de preenchê-la

      // Percorrer os registros e adicionar à lista
      First; // Posicionar no primeiro registro
      while not EOF do
      begin
        InputValueStr := splitstr(FieldByName(FInputFieldTester).Asstring);
        InputValue:= busca_referencia( InputValueStr);


        OutputValue := FieldByName(FOutputFieldTester).AsInteger;

        AddValorTester(InputValue, OutputValue); //Inclui as listas associadas


        Next; // Avançar para o próximo registro
      end;

      Close; // Fechar a query caso esteja aberta
    end
    else
      ShowMessage('Nenhum registro encontrado.');
  end;
end;



function TNNTrainning.GetCommentario: string;
begin
  Result := FComentario;
end;

function TNNTrainning.GetGroupByTester: string;
begin
  result := FgroupbyTester;
end;

function TNNTrainning.GetInputCols: integer;
begin
  if (FvalinputLeg <> nil) then
  begin
     result := FvalinputLeg.Count;
  end
  else
  begin
    result := 0;
  end;
end;


function TNNTrainning.GetNome: string;
begin
  Result := FNome;
end;

function TNNTrainning.GetEntrada: integer;
begin
  Result := FEntradas;
end;

function TNNTrainning.GetOutputCols: integer;
begin
  if (FvaloutputLeg <> nil) then
  begin
    result := FvaloutputLeg.Count;
  end
  else
  begin
    result := 0;
  end;
end;


function TNNTrainning.GetSaida: integer;
begin
  Result := FSaidas;
end;


procedure TNNTrainning.SetNome(AValue: string);
begin
  FNome := AValue;
end;

procedure TNNTrainning.SetClassNNTrainning(AValue: TClasseNNTrainning);
begin
  FClassNNTrainning:= AValue;
end;

procedure TNNTrainning.SetComentario(AValue: String);
begin
  FComentario:= AValue;

end;

procedure TNNTrainning.SetCommentario(AValue: string);
begin
  FComentario:= AValue;
end;

procedure TNNTrainning.SetFilterValueTester(AValue: string);
begin
  FFilterValueTester:=AValue;
end;

procedure TNNTrainning.SetGroupByTester(AValue: string);
begin
  FgroupbyTester:=  AValue;
end;

procedure TNNTrainning.SetInputFieldTester(AValue: string);
begin
  FInputFieldTester:=AValue;
end;

procedure TNNTrainning.SetEntradas(AValue: integer);
begin
  FEntradas:= AValue;
end;


procedure TNNTrainning.SetOutputFieldTester(AValue: string);
begin
  if FOutputFieldTester=AValue then Exit;
  FOutputFieldTester:=AValue;
end;

procedure TNNTrainning.SetSaidas(AValue: integer);
begin
  FSaidas:=AValue;
end;

procedure TNNTrainning.SetInputField(AValue: String);
begin
  FInputField:= AValue;
end;

procedure TNNTrainning.SetOutputField(AValue: String);
begin
  FOutputField := AValue;
end;

procedure TNNTrainning.SetFilterValue(AValue: string);
begin
  FFilterValue := AValue;
end;

procedure TNNTrainning.SetGroupBy(AValue: String);
begin
  Fgroupby := AValue;
end;

function TNNTrainning.GetSQLTrainning: TSqlEditItem;
begin
  Result := FsqlTrainning;
end;

function TNNTrainning.GetSQLTest: TSqlEditItem;
begin
 Result := FsqlTester;
end;

function TNNTrainning.GetGroupBy: String;
begin
  Result := Fgroupby;
end;


procedure TNNTrainning.SetSQLTest(AValue: TSqlEditItem);
begin
 FsqlTester := avalue;
end;

procedure TNNTrainning.SetSQLTrainning(AValue: TSqlEditItem);
begin
 FsqlTrainning := avalue;
end;

function TNNTrainning.RunTrainning(): boolean;
var
  resultado : boolean;
  arquivo: Tstringlist;
  origem : string;
  destino : string;


begin
  Flogtrainning := '';
  arquivo := tstringlist.create();
  arquivo.Text:= FfileJSONTester;
  arquivo.SaveToFile('training_data.json');
  arquivo.Text:= FPython;
  arquivo.SaveToFile('tmptreino.py');

  resultado:= false;
  if (FPythonRunner = nil) then
  begin
       FPythonRunner := TPythonRunner.Create;
  end;

  ExecutaTrainamento('tmptreino.py','training_data.json', Flogtrainning);
  origem := Fsetproject.Diretorio+'\'+Fsetproject.Filename;
  //destino := ExtractFileDir(ApplicationName)+'marcas\'+FFilterValue+'\';
  destino := ExtractFileDir(ApplicationName)+'marcas\'+FFilterCondition+'\'+FFilterCondition+'.json';
  copyfile(origem, destino, True);
  resultado := true;
  FPythonRunner.free;
  FPythonRunner := nil;

  result := resultado;
end;

function TNNTrainning.CriaJSONTrainning() : string;
var
  i, j, cellValue: Integer;
  inputLine, jsonStr, outputLine: string;
  inputLegLine, outputLegLine: string;
  dataatual : string;
begin
  jsonStr := '';
  dataatual:= datetostr(now);
  jsonStr := jsonStr+ '{ "training_detail": ['+#13;

  jsonStr := jsonStr + '{ "name":"'+ FNome + '", "comment":"' + FComentario+
          '", "sql":"' + FsqlTrainning.SQL+
          '", "sqltester":"' + FsqlTester.SQL+
          '", "inputfield":"' +FInputField+
          '", "inputref":"' +FInputRef+'", "inputreffield":"' +FInputRefField+
          '", "inputfieldtester":"' +FInputFieldtester+
          '", "inputreftester":"' +FInputReftester+'", "inputreffieldtester":"' +FInputRefFieldtester+
          '", "outputfield":"' +FOutputField+'", "outputfieldtester":"' +FOutputFieldtester+
          '", "filtercondition":"' +FFilterCondition+'", "filterconditiontester":"' +FFilterConditiontester+
          '", "InputCols":"'+ inttostr(FvalinputLeg.Count)+'", "OutputCols":"' +inttostr(FvaloutputLeg.Count)+
          '", "dtatual":"' + dataatual + '"  }'+#13;
  jsonStr := jsonStr + '],';

  jsonStr := jsonStr+ ' "training_tag": ['+#13;
  inputLegLine := '';
  outputLegLine := '';

  //Captura o nro das colunas de input e output
  //FOutputCols:= valoutputLeg.Count;
  //FInputCols := valinputLeg.Count;

  //valoinputLeg
  for j := 0 to FvalinputLeg.Count-1 do
  begin
      inputLegLine := inputLegLine + '"'+FvalinputLeg.Strings[j]+'"';
      if(j <> FvalinputLeg.Count-1) then
      begin
        inputLegLine := inputLegLine +',';
      end;
  end;
  for j := 0 to FvaloutputLeg.Count-1 do
  begin
      outputLegLine := outputLegLine + '"'+FvaloutputLeg.Strings[j]+'"';

      if(j <> FvaloutputLeg.Count-1) then
      begin
        outputLegLine := outputLegLine +',';
      end;

  end;
  // Constrói a string JSON para a linha atual
  jsonStr := jsonStr + Format('{ "inputs": [%s], "output": [%s] }', [inputLegLine, outputLegLine])+#13;


  // Fecha a string JSON
  jsonStr := jsonStr + '],';
  // Inicia a string JSON
  jsonStr := jsonStr+ ' "training_data": ['+#13;

  // Itera pelas linhas dos grids
  for i := 0 to valinput.RowCount - 1 do
  begin
    inputLine := '';
    for j := 0 to FvalinputLeg.Count-1 do
    begin

      //valinput
      if (valinput.Cells[j, i].IsEmpty)  then
      begin
        inputLine := inputLine + '"0"'
      end
      else
      begin
        inputLine := inputLine + '"'+valinput.Cells[j, i]+'"';

      end;
      //Separa com virgula
      if(j <> FvalinputLeg.Count-1) then
      begin
         inputLine := inputLine +',';
      end;
    end;

    //Output
    outputLine := '';
    //maxValue:= valoutput.ColCount; //O valor maximo é o tamanho da legenda
    //FOutputCols:= valoutput.ColCount; //O valor maximo é o tamanho da legenda

    for j := 0 to FvaloutputLeg.Count -1 do
    begin
      if (valoutput.Cells[j, i].trim.IsEmpty)  then
      begin
        outputLine := outputLine + '"0"'
      end
      else
      begin
        outputLine := outputLine + '"'+valoutput.Cells[j, i]+'"';
      end;

      if(j <> FvaloutputLeg.Count-1) then
      begin
        outputLine := outputLine +',';
      end;
    end;
    // Constrói a string JSON para a linha atual
    jsonStr := jsonStr + Format('{ "inputs": [%s], "output": [%s] }', [inputLine, outputLine])+#13;

    // Adiciona vírgula entre objetos, exceto após o último
    if i < valinput.RowCount - 1 then
    begin
      jsonStr := jsonStr + ', ';
    end;
  end;

  // Fecha a string JSON
  jsonStr := jsonStr + ']}';

  Result := jsonStr;
end;

function TNNTrainning.CriaJSONTester: string;
var
  i, j, cellValue: Integer;
  inputLine, jsonStr, outputLine: string;
  inputLegLine, outputLegLine: string;
  dataatual : string;
begin
  jsonStr := '';
  dataatual:= datetostr(now);
  jsonStr := jsonStr+ '{ "tester_detail": ['+#13;

  jsonStr := jsonStr + '{ "name":"'+ FNome + '", "comment":"' + FComentario+
          '", "sql":"' + FsqlTrainning.SQL+
          '", "sqltester":"' + FsqlTester.SQL+
          '", "inputfield":"' +FInputField+
          '", "inputref":"' +FInputRef+'", "inputreffield":"' +FInputRefField+
          '", "inputfieldtester":"' +FInputFieldtester+
          '", "inputreftester":"' +FInputReftester+'", "inputreffieldtester":"' +FInputRefFieldtester+
          '", "outputfield":"' +FOutputField+'", "outputfieldtester":"' +FOutputFieldtester+
          '", "filtercondition":"' +FFilterCondition+'", "filterconditiontester":"' +FFilterConditiontester+
          '", "InputCols":"'+ inttostr(FvalinputLeg.Count)+'", "OutputCols":"' +inttostr(FvaloutputLeg.Count)+
          '", "dtatual":"' + dataatual + '"  }'+#13;
  jsonStr := jsonStr + '],';

  jsonStr := jsonStr+ ' "tester_tag": ['+#13;
  inputLegLine := '';
  outputLegLine := '';

  //Captura o nro das colunas de input e output
  //FOutputCols:= valoutputLeg.Count;
  //FInputCols := valinputLeg.Count;

  //valoinputLeg
  for j := 0 to FvalinputLeg.Count-1 do
  begin
      inputLegLine := inputLegLine + '"'+FvalinputLeg.Strings[j]+'"';
      if(j <> FvalinputLeg.Count-1) then
      begin
        inputLegLine := inputLegLine +',';
      end;
  end;

  // Constrói a string JSON para a linha atual
  jsonStr := jsonStr + Format('{ "inputs": [%s] }', [inputLegLine])+#13;


  // Fecha a string JSON
  jsonStr := jsonStr + '],';
  // Inicia a string JSON
  jsonStr := jsonStr+ ' "tester_data": ['+#13;

  // Itera pelas linhas dos grids
  for i := 0 to valinput.RowCount - 1 do
  begin
    inputLine := '';
    for j := 0 to FvalinputLeg.Count-1 do
    begin

      //valinput
      if (valinput.Cells[j, i].IsEmpty)  then
      begin
        inputLine := inputLine + '"0"'
      end
      else
      begin
        inputLine := inputLine + '"'+valinput.Cells[j, i]+'"';

      end;
      //Separa com virgula
      if(j <> FvalinputLeg.Count-1) then
      begin
         inputLine := inputLine +',';
      end;
    end;

    //Output
    outputLine := '';
    //maxValue:= valoutput.ColCount; //O valor maximo é o tamanho da legenda
    //FOutputCols:= valoutput.ColCount; //O valor maximo é o tamanho da legenda

    for j := 0 to FvaloutputLeg.Count -1 do
    begin
      if (valoutput.Cells[j, i].trim.IsEmpty)  then
      begin
        outputLine := outputLine + '"0"'
      end
      else
      begin
        outputLine := outputLine + '"'+valoutput.Cells[j, i]+'"';
      end;

      if(j <> FvaloutputLeg.Count-1) then
      begin
        outputLine := outputLine +',';
      end;
    end;
    // Constrói a string JSON para a linha atual
    jsonStr := jsonStr + Format('{ "inputs": [%s], "output": [%s] }', [inputLine, outputLine])+#13;

    // Adiciona vírgula entre objetos, exceto após o último
    if i < valinput.RowCount - 1 then
    begin
      jsonStr := jsonStr + ', ';
    end;
  end;

  // Fecha a string JSON
  jsonStr := jsonStr + ']}';

  Result := jsonStr;
end;


procedure TNNTrainning.ExecutaTrainamento(pythonfile : string; jsonfile : string; var Output : String);
var
  params : Array of String;
  filename : string;
  source1, source2 : string;
  //output : string;
  arquivo: TStringlist;
begin
  try
    arquivo := TStringlist.Create;
    arquivo.Text:= FPython;
    arquivo.SaveToFile(pythonfile);
    arquivo.Text := Fjsontrainning;
    arquivo.SaveToFile(jsonfile);
    output:= '';
    filename := 'cmd ';
    //if Callprg('python.exe',pythonfile+' '+ jsonfile + ' '+ FFilterValue,Output) then
    if Callprg('python.exe',pythonfile+' '+ jsonfile + ' '+ FFilterCondition,Output) then
    begin
      Showmessage(output);
    end;
  except
    on E: Exception do
      //ShowMessage('Run Error -  Python: ' + E.Message);
      output := 'Run Error -  Python: ' + E.Message;
  end;
  arquivo.free;
  arquivo := nil;
end;

function TNNTrainning.busca_referencia(palavras: TStringList): TStringList;
var
  i: Integer;
  palavra, valorChave: string;
  items : TStringList;
begin
  // Criando a TStringList que será retornada
  items := TStringList.Create;

  for i := 0 to palavras.Count - 1 do
  begin
    palavra := palavras[i];

    // Preparando e executando a consulta SQL utilizando qryAux1
    dmbase.zqryAux2.SQL.Text := Format('SELECT %s FROM %s WHERE %s = :palavra', [FInputRefKey , FInputRef, FInputRefField]);
    dmbase.zqryAux2.ParamByName('palavra').AsString := palavra;
    dmbase.zqryAux2.Open;

    // Verificando se algum resultado foi retornado
    if not dmbase.zqryAux2.EOF then
      valorChave := dmbase.zqryAux2.FieldByName(FInputRefKey).AsString
    else
      valorChave := '0';

    // Adicionando a chave encontrada (ou 0) à lista de resultados
    items.Add(valorChave);

    dmbase.zqryAux2.Close;
  end;
  result := items;
end;

procedure TNNTrainning.AddValor(inputvaluestr: TStringList; outputvalue: Integer
  );
var
  i, j, col, row: Integer;
  posicaoinput : integer;
  valorinput : string;
  posicaooutput : integer;
  valoroutput : string;
begin
  //Varre a lista procurando por novos itens
  for i := 0 to inputvaluestr.Count-1 do
  begin
    valorinput := inputvaluestr.Strings[i];
    posicaoinput := FvalinputLeg.IndexOf(valorinput); //Busca se item ja existe
    //valinputLeg, FvaloutputLeg;
    // Captura posicao Input
    if (posicaoinput=-1) then
    begin
      if((valorinput<>'0') and (valorinput<>'0')) then
      begin
           //Cadastra nova coluna
           posicaoinput := FvalinputLeg.Add(valorinput);
      end;
    end;
  end;

  //Captura posicao Output
  posicaooutput := FvaloutputLeg.IndexOf(inttostr(outputvalue));
  if (posicaooutput=-1) then
  begin
        //Cadastra nova coluna
        posicaooutput := FvaloutputLeg.Add(inttostr(outputvalue));
  end;



  row := valinput.RowCount-1;
  //Incrementa uma nova linha
  valinput.RowCount :=  row + 2;
  valoutput.RowCount := row + 2;
  if (valinput.ColCount<FvalinputLeg.Count) then
  begin
    valinput.ColCount:=FvalinputLeg.Count;
  end;
  if( valoutput.ColCount<FvaloutputLeg.Count) then
  begin
    valoutput.ColCount:= FvaloutputLeg.Count;
  end;

  // Inicializando a linha com 0
  for i := 0 to FvalinputLeg.Count - 1 do
  begin
    valinput.Cells[i, row] := '0';
  end;
  for i := 0 to FvaloutputLeg.Count - 1 do
  begin
    valoutput.Cells[i, row] := '0';
  end;


  // Preenche o valor na posicao correta de input
  for i := 0 to inputvaluestr.Count-1 do
  begin
    valorinput := inputvaluestr.Strings[i];
    posicaoinput := FvalinputLeg.IndexOf(valorinput);
    if (posicaoinput<>-1) then
    begin
       valinput.Cells[posicaoinput,row] := '1';
    end;
  end;

  // Preenche o valor na posicao correta de output
  posicaooutput := FvaloutputLeg.IndexOf(inttostr(outputvalue));
  if (posicaooutput<>-1) then
  begin
       valoutput.Cells[posicaooutput,row] := '1';
  end;

end;


//A addvalortester não modifica a entrada nem a saida apenas inclui se houver legenda
procedure TNNTrainning.AddValorTester(inputvaluestr: TStringList;
  outputvalue: Integer);
var
  i, j, col, row: Integer;
  posicaoinput : integer;
  valorinput : string;
  posicaooutput : integer;
  valoroutput : string;
begin
  //Varre a lista procurando por novos itens
  for i := 0 to inputvaluestr.Count-1 do
  begin
    valorinput := inputvaluestr.Strings[i];
    posicaoinput := FvalinputLeg.IndexOf(valorinput); //Busca se item ja existe
    //valinputLeg, FvaloutputLeg;
    // Captura posicao Input
    if (posicaoinput=-1) then
    begin
      if((valorinput<>'0') and (valorinput<>'0')) then
      begin
           //Cadastra nova coluna
           //posicaoinput := FvalinputLeg.Add(valorinput);
      end;
    end;
  end;

  //Captura posicao Output
  posicaooutput := FvaloutputLeg.IndexOf(inttostr(outputvalue));
  if (posicaooutput=-1) then
  begin
        //Cadastra nova coluna
        //posicaooutput := FvaloutputLeg.Add(inttostr(outputvalue));
  end;



  row := valinput.RowCount-1;
  //Incrementa uma nova linha
  valinput.RowCount :=  row + 2;
  valoutput.RowCount := row + 2;
  if (valinput.ColCount<FvalinputLeg.Count) then
  begin
    valinput.ColCount:=FvalinputLeg.Count;
  end;
  if( valoutput.ColCount<FvaloutputLeg.Count) then
  begin
    valoutput.ColCount:= FvaloutputLeg.Count;
  end;

  // Inicializando a linha com 0
  for i := 0 to FvalinputLeg.Count - 1 do
  begin
    valinput.Cells[i, row] := '0';
  end;
  for i := 0 to FvaloutputLeg.Count - 1 do
  begin
    valoutput.Cells[i, row] := '0';
  end;


  // Preenche o valor na posicao correta de input
  for i := 0 to inputvaluestr.Count-1 do
  begin
    valorinput := inputvaluestr.Strings[i];
    posicaoinput := FvalinputLeg.IndexOf(valorinput);
    if (posicaoinput<>-1) then
    begin
       valinput.Cells[posicaoinput,row] := '1';
    end;
  end;

  // Preenche o valor na posicao correta de output
  posicaooutput := FvaloutputLeg.IndexOf(inttostr(outputvalue));
  if (posicaooutput<>-1) then
  begin
       valoutput.Cells[posicaooutput,row] := '1';
  end;

end;



procedure TNNTrainning.InicializaStringGrids();
var
   i : integer;
begin
  FPythonlog := nil;
  // Verifica se os componentes já foram criados
  if not Assigned(valinput) then
  begin
    valinput := TStringGrid.Create(nil);
    FvalinputLeg := TStringList.create();
  end;


  if not Assigned(valoutput) then
  begin
    valoutput := TStringGrid.Create(nil);
    FvaloutputLeg := TStringList.create();
  end;

  // Configurações iniciais para valstinp
  with valinput do
  begin
    // Configurações específicas aqui, como:
    ColCount := 1; // Inicia com 1 coluna
    RowCount := 1; // Inicia com 1 linha
    FixedCols := 0; // Sem colunas fixas
    FixedRows := 0; // Sem linhas fixas
    //FInputCols:=1;


    for i := 0 to ColCount-1 do
    begin
      Cells[i,0] := '0';
    end;
    // Outras configurações podem ser adicionadas aqui
  end;

  // Configurações iniciais para valstoutp
  with valoutput do
  begin
    // Configurações específicas aqui, como:
    ColCount := 1; // Inicia com 1 coluna
    RowCount := 1; // Inicia com 1 linha
    FixedCols := 0; // Sem colunas fixas
    FixedRows := 0; // Sem linhas fixas
    for i := 0 to ColCount-1 do
    begin
      Cells[i,0] := '0';
    end;
    //FOutputCols:=1;

    // Outras configurações podem ser adicionadas aqui
  end;
  FvalinputLeg.clear;
  FvaloutputLeg.clear;
  //Valor maximo de colunas
  //valinput.ColCount:= MAXInputOutputColumns;
  //valoutput.ColCount:=MAXInputOutputColumns;
end;

procedure TNNTrainning.InicializaStringGridsTester;
var
   i : integer;
begin
  FPythonlog := nil;

  // Configurações iniciais para valstinp
  with valinput do
  begin
    // Configurações específicas aqui, como:
    RowCount := 1; // Inicia com 1 linha
    FixedRows := 0; // Sem linhas fixas
    //FInputCols:=1;
    for i := 0 to ColCount-1 do
    begin
      Cells[i,0] := '0';
    end;
    // Outras configurações podem ser adicionadas aqui
  end;

  // Configurações iniciais para valstoutp
  with valoutput do
  begin
    // Configurações específicas aqui, como:
    //ColCount := 1; // Inicia com 1 coluna
    RowCount := 1; // Inicia com 1 linha
    //FixedCols := 0; // Sem colunas fixas
    FixedRows := 0; // Sem linhas fixas
    for i := 0 to ColCount-1 do
    begin
      Cells[i,0] := '0';
    end;
    //FOutputCols:=1;

    // Outras configurações podem ser adicionadas aqui
  end;
end;

constructor TNNTrainning.create;
begin
  FvalinputLeg := TStringList.create();
  FvaloutputLeg := TStringList.create();
end;

destructor TNNTrainning.destroy;
begin
  FvalinputLeg.free;
  FvalinputLeg := nil;
  FvaloutputLeg.Free;
  FvaloutputLeg := nil;
end;




function TNNTrainning.ListClasseNNTrainning: string;
begin
  result := 'CN_NONE'+#13+'RecImg'+#13+'NLPNeuralNetwork';
end;

function TNNTrainning.trainnerJSON: boolean;
var
  SQL: String;
  arquivo : TStringList;
begin
  arquivo := TStringlist.create();
  InicializaStringGrids();
  dmbase.zqryaux.SQL.text := GeraSQLTrainning;
  CriaDatasetTrainning();
  // Supondo que CriaDataset configure um Dataset
  Fjsontrainning :=  CriaJSONTrainning();
  arquivo.Text:= Fjsontrainning;
  //arquivo.SaveToFile(ExtractFileDir(ApplicationName)+FFilterValue.'.json');
  arquivo.SaveToFile(ExtractFileDir(ApplicationName)+'training_data.json');
  // Implemente a lógica de treinamento aqui, se necessário
  Result := True; // ou retorne false em caso de falha
end;

function TNNTrainning.testerJSON(marca : string): boolean;
var
  SQL: String;
  arquivo : TStringList;
  dirname : string;
  applicname : string;
begin
  //Verifica se pasta foi criada de treinamento

  arquivo := TStringlist.create();
  InicializaStringGridsTester();

  applicname := ApplicationName;
  //dirname := ExtractFilePath(applicname);
  dirname := '.';
  dirname := dirname +'\marcas\'+marca;

  if(DirectoryExists(dirname,false)) then
  begin
    dmbase.zqryaux.SQL.text := GeraSQLTester;
    CriaDatasetTester(); //Cria o sql de treinamento
    //Carrega o treinamento na pasta



    // Supondo que CriaDataset configure um Dataset
    FJSONTester :=  CriaJSONTester();
    arquivo.Text:= FJSONTester;
    //arquivo.SaveToFile(ExtractFileDir(ApplicationName)+FFilterValue.'.json');
    arquivo.SaveToFile('.\marcas\'+FFilterConditionTester+'\'+FFilterConditionTester+'_tester.json');
    //arquivo.SaveToFile(ExtractFileDir(ApplicationName)+'training_data.json');
    // Implemente a lógica de treinamento aqui, se necessário
    Result := True; // ou retorne false em caso de falha
  end
  else
  begin
    ShowMessage('Not tester, first do network trainning !');
    result := false;
  end;
end;

procedure TNNTrainning.AddTest(query_index: integer);
var
   item : TSQLEditItem;
begin
  if (Fsetproject<> nil) then
  begin
     if(query_index<Fsetproject.Querycount) then
     begin
        item := Fsetproject.SQLEdit_Indexof(query_index);
        FsqlTester  := item;
     end;
  end;
end;

procedure TNNTrainning.LoadvalInputLeg(valores: string);
begin
  FvalinputLeg.Text:= valores;
end;

procedure TNNTrainning.LoadvalOutputLeg(valores: string);
begin
    FvaloutputLeg.text := valores;
end;

function TNNTrainning.SavevalInputLeg: string;
begin
  if (FvalinputLeg<>nil) then
  begin
    Result :=FvalinputLeg.Text;
  end
  else
  begin
    Result :='';
  end;
end;

function TNNTrainning.SavevalOutputLeg: string;
begin
  if (FvaloutputLeg<>nil) then
  begin
    Result :=FvaloutputLeg.Text;
  end
  else
  begin
    Result :='';
  end;

end;

procedure TNNTrainning.AddTrainning(query_index: integer);
var
   item : TSQLEditItem;
begin
  if (Fsetproject<> nil) then
  begin
     if(query_index<Fsetproject.Querycount) then
     begin
        item := Fsetproject.SQLEdit_Indexof(query_index);
        FsqlTrainning := item;

     end;
  end;
end;

end.


