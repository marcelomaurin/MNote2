unit NNTrainning;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, base, pythonRun, sqledititem, Dialogs, grids,
  PythonEngine, FileUtil, Forms;

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
    FsqlTrainning : TSqlEditItem;
    FsqlTester : TSqlEditItem;
    Fgroupby : String;
    FgroupbyTester : String;
    FInputField : String;
    FInputRef: string;
    FInputRefField : string;
    FInputRefKey: string;

    FInputFieldTester : String;
    FInputRefTester: string;
    FInputRefFieldTester : string;
    FInputRefKeyTester: string;

    FOutputField : String;
    FOutputFieldTester : String;
    FPython : String;
    Fjsontrainning : String;
    FFilterValue : string;
    FFilterValueTester : string;
    FfileJSONTester : string;
    FJSONTester : string;
    FFilterCondition: string;
    FFilterConditionTester: string;
    FList: TStringList;
    FPythonlog : TPythonOutputEvent;
    FPythonlogTester : TPythonOutputEvent;
    Flogtrainning : String;
    FvalinputLeg : TStringList;
    valinput : TStringGrid;
    FvaloutputLeg : TStringList;
    valoutput : TStringGrid;

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

    procedure ExecutaTrainamento(pythonfile : string; jsonfile : string; var Output : String);
    function busca_referencia(palavras: TStringList): TStringList;
    procedure AddValor(inputvaluestr: TStringList; outputvalue: Integer);
    procedure AddValorTester(inputvaluestr: TStringList; outputvalue: Integer);
    procedure InicializaStringGrids();
    procedure InicializaStringGridsTester;
    function SafeFieldAsString(AFieldName: string): string;
    function SafeFieldAsInteger(AFieldName: string): Integer;
    function GetMarcaDiretorio: string;
  public
    constructor Create();
    destructor Destroy(); override;
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
    property InputRef : String read FInputRef write FInputRef;
    property InputRefField : string read FInputRefField write FInputRefField;
    property InputRefKey : string read FInputRefKey write FInputRefKey;
    property InputCols : integer read GetInputCols;

    property InputFieldTester: string read FInputFieldTester write SetInputFieldTester;
    property InputRefTester : String read FInputRefTester write FInputRefTester;
    property InputRefFieldTester : string read FInputRefFieldTester write FInputRefFieldTester;
    property InputRefKeyTester : string read FInputRefKeyTester write FInputRefKeyTester;

    property OutputField : string read FOutputField write SetOutputField;
    property OutputCols : integer read GetOutputCols;
    property OutputFieldTester : string read FOutputFieldTester write SetOutputFieldTester;

    property Python : String read FPython write FPython;
    property jsontrainning: string read Fjsontrainning write Fjsontrainning;
    property FilterValue : string read FFilterValue write SetFilterValue;
    property FilterValueTester : string read FFilterValueTester write SetFilterValueTester;
    property fileJSONTester : string read FfileJSONTester write FfileJSONTester;
    property JSONTester : string read FJSONTester write FJSONTester;
    property Pythonlog : TPythonOutputEvent read FPythonlog write FPythonLog;
    property PythonlogTester : TPythonOutputEvent read FPythonlogTester write FPythonLogTester;
    property PythonRunner : TPythonRunner read FPythonRunner write FPythonRunner;
    property logtrainning : string read Flogtrainning;
    property FilterCondition : string read FFilterCondition write FFilterCondition;
    property FilterConditionTester : string read FFilterConditionTester write FFilterConditionTester;
    property valinputLeg : TStringList read FvalinputLeg write FvalinputLeg;
    property valoutputLeg : TStringList read FvaloutputLeg write FvaloutputLeg;
  end;

implementation

uses setproject, funcoes;

function TNNTrainning.SafeFieldAsString(AFieldName: string): string;
begin
  Result := '';
  if (AFieldName <> '') and (dmbase.zqryAux.FindField(AFieldName) <> nil) then
    Result := dmbase.zqryAux.FieldByName(AFieldName).AsString;
end;

function TNNTrainning.SafeFieldAsInteger(AFieldName: string): Integer;
begin
  Result := 0;
  if (AFieldName <> '') and (dmbase.zqryAux.FindField(AFieldName) <> nil) then
    Result := dmbase.zqryAux.FieldByName(AFieldName).AsInteger;
end;

function TNNTrainning.GetMarcaDiretorio: string;
begin
  Result := Trim(FFilterCondition);
  if Result = '' then
    Result := Trim(FFilterConditionTester);
  if Result = '' then
    Result := Trim(FFilterValue);
  if Result = '' then
    Result := Trim(FFilterValueTester);
  if Result = '' then
    Result := 'default';
end;

function TNNTrainning.GeraSQLTrainning: String;
var
  resultado : string;
begin
  if not Assigned(FsqlTrainning) then Exit('');

  if (Trim(FFilterValue) <> '') then
  begin
    if InputQuery('Condição de Filtro',
      'Por favor, insira a condição de filtro para ' + FFilterValue + ':',
      FFilterCondition) then
    begin
      resultado := FsqlTrainning.SQL + ' WHERE ' + FFilterValue + ' like ''' + FFilterCondition + '''';
      if not Trim(Fgroupby).IsEmpty then
        resultado := resultado + ' GROUP BY ' + Fgroupby;
    end
    else
      resultado := '';
  end
  else
  begin
    resultado := FsqlTrainning.SQL;
    if not Trim(Fgroupby).IsEmpty then
      resultado := resultado + ' GROUP BY ' + Fgroupby;
  end;

  Result := resultado;
end;

function TNNTrainning.GeraSQLTester: String;
var
  resultado : string;
begin
  if not Assigned(FsqlTester) then Exit('');

  if Trim(FFilterConditionTester) = '' then
    FFilterConditionTester := FFilterCondition;

  if (Trim(FFilterValueTester) <> '') then
  begin
    resultado := FsqlTester.SQL + ' WHERE ' + FFilterValueTester + ' like ''' + FFilterConditionTester + '''';
    if not Trim(FgroupbyTester).IsEmpty then
      resultado := resultado + ' GROUP BY ' + FgroupbyTester;
  end
  else
  begin
    resultado := FsqlTester.SQL;
    if not Trim(FgroupbyTester).IsEmpty then
      resultado := resultado + ' GROUP BY ' + FgroupbyTester;
  end;

  Result := resultado;
end;

procedure TNNTrainning.CriaDatasetTrainning();
var
  OutputValue: Integer;
  InputValueStr : TStringList;
  InputValue : TStringList;
begin
  if FList = nil then
    FList := TStringList.Create;

  with dmbase.zqryAux do
  begin
    if Active then Close;
    Open;

    if RecordCount > 0 then
    begin
      FList.Clear;
      First;
      while not EOF do
      begin
        InputValueStr := splitstr(SafeFieldAsString(FInputField));
        try
          InputValue := busca_referencia(InputValueStr);
          try
            OutputValue := SafeFieldAsInteger(FOutputField);
            AddValor(InputValue, OutputValue);
          finally
            InputValue.Free;
          end;
        finally
          InputValueStr.Free;
        end;
        Next;
      end;

      Close;
    end
    else
      ShowMessage('Nenhum registro encontrado.');
  end;
end;

procedure TNNTrainning.CriaDatasetTester();
var
  OutputValue: Integer;
  InputValueStr : TStringList;
  InputValue : TStringList;
begin
  if FList = nil then
    FList := TStringList.Create;

  with dmbase.zqryAux do
  begin
    if Active then Close;
    Open;

    if RecordCount > 0 then
    begin
      FList.Clear;
      First;
      while not EOF do
      begin
        InputValueStr := splitstr(SafeFieldAsString(FInputFieldTester));
        try
          InputValue := busca_referencia(InputValueStr);
          try
            OutputValue := SafeFieldAsInteger(FOutputFieldTester);
            AddValorTester(InputValue, OutputValue);
          finally
            InputValue.Free;
          end;
        finally
          InputValueStr.Free;
        end;
        Next;
      end;

      Close;
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
  Result := FgroupbyTester;
end;

function TNNTrainning.GetInputCols: integer;
begin
  if FvalinputLeg <> nil then
    Result := FvalinputLeg.Count
  else
    Result := 0;
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
  if FvaloutputLeg <> nil then
    Result := FvaloutputLeg.Count
  else
    Result := 0;
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
  FClassNNTrainning := AValue;
end;

procedure TNNTrainning.SetComentario(AValue: String);
begin
  FComentario := AValue;
end;

procedure TNNTrainning.SetCommentario(AValue: string);
begin
  FComentario := AValue;
end;

procedure TNNTrainning.SetFilterValueTester(AValue: string);
begin
  FFilterValueTester := AValue;
end;

procedure TNNTrainning.SetGroupByTester(AValue: string);
begin
  FgroupbyTester := AValue;
end;

procedure TNNTrainning.SetInputFieldTester(AValue: string);
begin
  FInputFieldTester := AValue;
end;

procedure TNNTrainning.SetEntradas(AValue: integer);
begin
  FEntradas := AValue;
end;

procedure TNNTrainning.SetOutputFieldTester(AValue: string);
begin
  FOutputFieldTester := AValue;
end;

procedure TNNTrainning.SetSaidas(AValue: integer);
begin
  FSaidas := AValue;
end;

procedure TNNTrainning.SetInputField(AValue: String);
begin
  FInputField := AValue;
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
  FsqlTester := AValue;
end;

procedure TNNTrainning.SetSQLTrainning(AValue: TSqlEditItem);
begin
  FsqlTrainning := AValue;
end;

function TNNTrainning.RunTrainning(): boolean;
var
  arquivo: TStringList;
  origem : string;
  destinoDir : string;
  destino : string;
  marcaDir: string;
begin
  Result := False;
  Flogtrainning := '';

  arquivo := TStringList.Create;
  try
    arquivo.Text := Fjsontrainning;
    arquivo.SaveToFile('training_data.json');

    arquivo.Text := FPython;
    arquivo.SaveToFile('tmptreino.py');
  finally
    arquivo.Free;
  end;

  if FPythonRunner = nil then
    FPythonRunner := TPythonRunner.Create;

  try
    ExecutaTrainamento('tmptreino.py', 'training_data.json', Flogtrainning);

    marcaDir := GetMarcaDiretorio;
    destinoDir := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) +
                  'marcas' + PathDelim + marcaDir;
    ForceDirectories(destinoDir);

    if Assigned(Fsetproject) then
    begin
      origem := IncludeTrailingPathDelimiter(Fsetproject.Diretorio) + Fsetproject.Filename;
      destino := IncludeTrailingPathDelimiter(destinoDir) + marcaDir + '.json';
      if FileExists(origem) then
        CopyFile(origem, destino, True);
    end;

    Result := True;
  finally
    FreeAndNil(FPythonRunner);
  end;
end;

function TNNTrainning.CriaJSONTrainning(): string;
var
  i, j: Integer;
  inputLine, jsonStr, outputLine: string;
  inputLegLine, outputLegLine: string;
  dataatual : string;
begin
  jsonStr := '';
  dataatual := DateToStr(Now);
  jsonStr := jsonStr + '{ "training_detail": [' + #13;

  jsonStr := jsonStr + '{ "name":"' + FNome + '", "comment":"' + FComentario +
          '", "sql":"' + IfThen(Assigned(FsqlTrainning), FsqlTrainning.SQL, '') +
          '", "sqltester":"' + IfThen(Assigned(FsqlTester), FsqlTester.SQL, '') +
          '", "inputfield":"' + FInputField +
          '", "inputref":"' + FInputRef + '", "inputreffield":"' + FInputRefField +
          '", "inputfieldtester":"' + FInputFieldTester +
          '", "inputreftester":"' + FInputRefTester + '", "inputreffieldtester":"' + FInputRefFieldTester +
          '", "outputfield":"' + FOutputField + '", "outputfieldtester":"' + FOutputFieldTester +
          '", "filtercondition":"' + FFilterCondition + '", "filterconditiontester":"' + FFilterConditionTester +
          '", "InputCols":"' + IntToStr(FvalinputLeg.Count) + '", "OutputCols":"' + IntToStr(FvaloutputLeg.Count) +
          '", "dtatual":"' + dataatual + '"  }' + #13;
  jsonStr := jsonStr + '],';

  jsonStr := jsonStr + ' "training_tag": [' + #13;
  inputLegLine := '';
  outputLegLine := '';

  for j := 0 to FvalinputLeg.Count - 1 do
  begin
    inputLegLine := inputLegLine + '"' + FvalinputLeg.Strings[j] + '"';
    if (j <> FvalinputLeg.Count - 1) then
      inputLegLine := inputLegLine + ',';
  end;

  for j := 0 to FvaloutputLeg.Count - 1 do
  begin
    outputLegLine := outputLegLine + '"' + FvaloutputLeg.Strings[j] + '"';
    if (j <> FvaloutputLeg.Count - 1) then
      outputLegLine := outputLegLine + ',';
  end;

  jsonStr := jsonStr + Format('{ "inputs": [%s], "output": [%s] }', [inputLegLine, outputLegLine]) + #13;
  jsonStr := jsonStr + '],';
  jsonStr := jsonStr + ' "training_data": [' + #13;

  for i := 0 to valinput.RowCount - 1 do
  begin
    inputLine := '';
    for j := 0 to FvalinputLeg.Count - 1 do
    begin
      if valinput.Cells[j, i].IsEmpty then
        inputLine := inputLine + '"0"'
      else
        inputLine := inputLine + '"' + valinput.Cells[j, i] + '"';

      if (j <> FvalinputLeg.Count - 1) then
        inputLine := inputLine + ',';
    end;

    outputLine := '';
    for j := 0 to FvaloutputLeg.Count - 1 do
    begin
      if valoutput.Cells[j, i].Trim.IsEmpty then
        outputLine := outputLine + '"0"'
      else
        outputLine := outputLine + '"' + valoutput.Cells[j, i] + '"';

      if (j <> FvaloutputLeg.Count - 1) then
        outputLine := outputLine + ',';
    end;

    jsonStr := jsonStr + Format('{ "inputs": [%s], "output": [%s] }', [inputLine, outputLine]) + #13;

    if i < valinput.RowCount - 1 then
      jsonStr := jsonStr + ', ';
  end;

  jsonStr := jsonStr + ']}';
  Result := jsonStr;
end;

function TNNTrainning.CriaJSONTester(): string;
var
  i, j: Integer;
  inputLine, jsonStr, outputLine: string;
  inputLegLine: string;
  dataatual : string;
begin
  jsonStr := '';
  dataatual := DateToStr(Now);
  jsonStr := jsonStr + '{ "tester_detail": [' + #13;

  jsonStr := jsonStr + '{ "name":"' + FNome + '", "comment":"' + FComentario +
          '", "sql":"' + IfThen(Assigned(FsqlTrainning), FsqlTrainning.SQL, '') +
          '", "sqltester":"' + IfThen(Assigned(FsqlTester), FsqlTester.SQL, '') +
          '", "inputfield":"' + FInputField +
          '", "inputref":"' + FInputRef + '", "inputreffield":"' + FInputRefField +
          '", "inputfieldtester":"' + FInputFieldTester +
          '", "inputreftester":"' + FInputRefTester + '", "inputreffieldtester":"' + FInputRefFieldTester +
          '", "outputfield":"' + FOutputField + '", "outputfieldtester":"' + FOutputFieldTester +
          '", "filtercondition":"' + FFilterCondition + '", "filterconditiontester":"' + FFilterConditionTester +
          '", "InputCols":"' + IntToStr(FvalinputLeg.Count) + '", "OutputCols":"' + IntToStr(FvaloutputLeg.Count) +
          '", "dtatual":"' + dataatual + '"  }' + #13;
  jsonStr := jsonStr + '],';

  jsonStr := jsonStr + ' "tester_tag": [' + #13;
  inputLegLine := '';

  for j := 0 to FvalinputLeg.Count - 1 do
  begin
    inputLegLine := inputLegLine + '"' + FvalinputLeg.Strings[j] + '"';
    if (j <> FvalinputLeg.Count - 1) then
      inputLegLine := inputLegLine + ',';
  end;

  jsonStr := jsonStr + Format('{ "inputs": [%s] }', [inputLegLine]) + #13;
  jsonStr := jsonStr + '],';
  jsonStr := jsonStr + ' "tester_data": [' + #13;

  for i := 0 to valinput.RowCount - 1 do
  begin
    inputLine := '';
    for j := 0 to FvalinputLeg.Count - 1 do
    begin
      if valinput.Cells[j, i].IsEmpty then
        inputLine := inputLine + '"0"'
      else
        inputLine := inputLine + '"' + valinput.Cells[j, i] + '"';

      if (j <> FvalinputLeg.Count - 1) then
        inputLine := inputLine + ',';
    end;

    outputLine := '';
    for j := 0 to FvaloutputLeg.Count - 1 do
    begin
      if valoutput.Cells[j, i].Trim.IsEmpty then
        outputLine := outputLine + '"0"'
      else
        outputLine := outputLine + '"' + valoutput.Cells[j, i] + '"';

      if (j <> FvaloutputLeg.Count - 1) then
        outputLine := outputLine + ',';
    end;

    jsonStr := jsonStr + Format('{ "inputs": [%s], "output": [%s] }', [inputLine, outputLine]) + #13;

    if i < valinput.RowCount - 1 then
      jsonStr := jsonStr + ', ';
  end;

  jsonStr := jsonStr + ']}';
  Result := jsonStr;
end;

procedure TNNTrainning.ExecutaTrainamento(pythonfile : string; jsonfile : string; var Output : String);
var
  arquivo: TStringList;
begin
  arquivo := TStringList.Create;
  try
    arquivo.Text := FPython;
    arquivo.SaveToFile(pythonfile);
    arquivo.Text := Fjsontrainning;
    arquivo.SaveToFile(jsonfile);

    Output := '';
    if Callprg('python.exe', pythonfile + ' ' + jsonfile + ' ' + FFilterCondition, Output) then
      ShowMessage(Output);
  except
    on E: Exception do
      Output := 'Run Error - Python: ' + E.Message;
  end;
  arquivo.Free;
end;

function TNNTrainning.busca_referencia(palavras: TStringList): TStringList;
var
  i: Integer;
  palavra, valorChave: string;
  items : TStringList;
begin
  items := TStringList.Create;

  for i := 0 to palavras.Count - 1 do
  begin
    palavra := palavras[i];

    dmbase.zqryAux2.Close;
    dmbase.zqryAux2.SQL.Text := Format('SELECT %s FROM %s WHERE %s = :palavra',
      [FInputRefKey, FInputRef, FInputRefField]);
    dmbase.zqryAux2.ParamByName('palavra').AsString := palavra;
    dmbase.zqryAux2.Open;

    if not dmbase.zqryAux2.EOF then
      valorChave := dmbase.zqryAux2.FieldByName(FInputRefKey).AsString
    else
      valorChave := '0';

    items.Add(valorChave);
    dmbase.zqryAux2.Close;
  end;

  Result := items;
end;

procedure TNNTrainning.AddValor(inputvaluestr: TStringList; outputvalue: Integer);
var
  i, row: Integer;
  posicaoinput : integer;
  valorinput : string;
  posicaooutput : integer;
begin
  for i := 0 to inputvaluestr.Count - 1 do
  begin
    valorinput := inputvaluestr.Strings[i];
    posicaoinput := FvalinputLeg.IndexOf(valorinput);
    if (posicaoinput = -1) and (valorinput <> '0') then
      posicaoinput := FvalinputLeg.Add(valorinput);
  end;

  posicaooutput := FvaloutputLeg.IndexOf(IntToStr(outputvalue));
  if (posicaooutput = -1) then
    posicaooutput := FvaloutputLeg.Add(IntToStr(outputvalue));

  row := valinput.RowCount - 1;
  valinput.RowCount := row + 2;
  valoutput.RowCount := row + 2;

  if (valinput.ColCount < FvalinputLeg.Count) then
    valinput.ColCount := FvalinputLeg.Count;
  if (valoutput.ColCount < FvaloutputLeg.Count) then
    valoutput.ColCount := FvaloutputLeg.Count;

  for i := 0 to FvalinputLeg.Count - 1 do
    valinput.Cells[i, row] := '0';

  for i := 0 to FvaloutputLeg.Count - 1 do
    valoutput.Cells[i, row] := '0';

  for i := 0 to inputvaluestr.Count - 1 do
  begin
    valorinput := inputvaluestr.Strings[i];
    posicaoinput := FvalinputLeg.IndexOf(valorinput);
    if (posicaoinput <> -1) then
      valinput.Cells[posicaoinput, row] := '1';
  end;

  posicaooutput := FvaloutputLeg.IndexOf(IntToStr(outputvalue));
  if (posicaooutput <> -1) then
    valoutput.Cells[posicaooutput, row] := '1';
end;

procedure TNNTrainning.AddValorTester(inputvaluestr: TStringList; outputvalue: Integer);
var
  i, row: Integer;
  posicaoinput : integer;
  valorinput : string;
  posicaooutput : integer;
begin
  row := valinput.RowCount - 1;
  valinput.RowCount := row + 2;
  valoutput.RowCount := row + 2;

  if (valinput.ColCount < FvalinputLeg.Count) then
    valinput.ColCount := FvalinputLeg.Count;
  if (valoutput.ColCount < FvaloutputLeg.Count) then
    valoutput.ColCount := FvaloutputLeg.Count;

  for i := 0 to FvalinputLeg.Count - 1 do
    valinput.Cells[i, row] := '0';

  for i := 0 to FvaloutputLeg.Count - 1 do
    valoutput.Cells[i, row] := '0';

  for i := 0 to inputvaluestr.Count - 1 do
  begin
    valorinput := inputvaluestr.Strings[i];
    posicaoinput := FvalinputLeg.IndexOf(valorinput);
    if (posicaoinput <> -1) then
      valinput.Cells[posicaoinput, row] := '1';
  end;

  posicaooutput := FvaloutputLeg.IndexOf(IntToStr(outputvalue));
  if (posicaooutput <> -1) then
    valoutput.Cells[posicaooutput, row] := '1';
end;

procedure TNNTrainning.InicializaStringGrids();
var
  i : integer;
begin
  FPythonlog := nil;

  if not Assigned(valinput) then
    valinput := TStringGrid.Create(nil);
  if not Assigned(FvalinputLeg) then
    FvalinputLeg := TStringList.Create;

  if not Assigned(valoutput) then
    valoutput := TStringGrid.Create(nil);
  if not Assigned(FvaloutputLeg) then
    FvaloutputLeg := TStringList.Create;

  with valinput do
  begin
    ColCount := 1;
    RowCount := 1;
    FixedCols := 0;
    FixedRows := 0;
    for i := 0 to ColCount - 1 do
      Cells[i,0] := '0';
  end;

  with valoutput do
  begin
    ColCount := 1;
    RowCount := 1;
    FixedCols := 0;
    FixedRows := 0;
    for i := 0 to ColCount - 1 do
      Cells[i,0] := '0';
  end;

  FvalinputLeg.Clear;
  FvaloutputLeg.Clear;
end;

procedure TNNTrainning.InicializaStringGridsTester;
var
  i : integer;
begin
  FPythonlog := nil;

  if not Assigned(valinput) then
    valinput := TStringGrid.Create(nil);
  if not Assigned(valoutput) then
    valoutput := TStringGrid.Create(nil);

  with valinput do
  begin
    if ColCount <= 0 then ColCount := 1;
    RowCount := 1;
    FixedRows := 0;
    for i := 0 to ColCount - 1 do
      Cells[i,0] := '0';
  end;

  with valoutput do
  begin
    if ColCount <= 0 then ColCount := 1;
    RowCount := 1;
    FixedRows := 0;
    for i := 0 to ColCount - 1 do
      Cells[i,0] := '0';
  end;
end;

constructor TNNTrainning.Create;
begin
  inherited Create;
  FvalinputLeg := TStringList.Create;
  FvaloutputLeg := TStringList.Create;
  FList := TStringList.Create;
  valinput := nil;
  valoutput := nil;
end;

destructor TNNTrainning.Destroy;
begin
  FreeAndNil(FList);
  FreeAndNil(valinput);
  FreeAndNil(valoutput);
  FreeAndNil(FvalinputLeg);
  FreeAndNil(FvaloutputLeg);
  inherited Destroy;
end;

function TNNTrainning.ListClasseNNTrainning: string;
begin
  Result := 'CN_NONE' + #13 + 'RecImg' + #13 + 'NLPNeuralNetwork';
end;

function TNNTrainning.trainnerJSON: boolean;
var
  arquivo : TStringList;
begin
  Result := False;

  if not Assigned(dmbase) then
  begin
    ShowMessage('Base de dados não inicializada.');
    Exit;
  end;

  if not Assigned(FsqlTrainning) then
  begin
    ShowMessage('SQL de treinamento não informado.');
    Exit;
  end;

  arquivo := TStringList.Create;
  try
    InicializaStringGrids();
    dmbase.zqryAux.Close;
    dmbase.zqryAux.SQL.Text := GeraSQLTrainning;
    CriaDatasetTrainning();

    Fjsontrainning := CriaJSONTrainning();
    arquivo.Text := Fjsontrainning;
    arquivo.SaveToFile(IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + 'training_data.json');
    Result := True;
  finally
    arquivo.Free;
  end;
end;

function TNNTrainning.testerJSON(marca : string): boolean;
var
  arquivo : TStringList;
  dirname : string;
begin
  Result := False;

  if not Assigned(dmbase) then
  begin
    ShowMessage('Base de dados não inicializada.');
    Exit;
  end;

  if not Assigned(FsqlTester) then
  begin
    ShowMessage('SQL de teste não informado.');
    Exit;
  end;

  arquivo := TStringList.Create;
  try
    dirname := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) +
               'marcas' + PathDelim + marca;
    ForceDirectories(dirname);

    InicializaStringGridsTester();
    dmbase.zqryAux.Close;
    dmbase.zqryAux.SQL.Text := GeraSQLTester;
    CriaDatasetTester();

    FJSONTester := CriaJSONTester();
    arquivo.Text := FJSONTester;
    arquivo.SaveToFile(IncludeTrailingPathDelimiter(dirname) + marca + '_tester.json');
    FfileJSONTester := IncludeTrailingPathDelimiter(dirname) + marca + '_tester.json';
    Result := True;
  finally
    arquivo.Free;
  end;
end;

procedure TNNTrainning.AddTest(query_index: integer);
var
  item : TSQLEditItem;
begin
  if Assigned(Fsetproject) and (query_index >= 0) and (query_index < Fsetproject.Querycount) then
  begin
    item := Fsetproject.SQLEdit_Indexof(query_index);
    FsqlTester := item;
  end;
end;

procedure TNNTrainning.LoadvalInputLeg(valores: string);
begin
  FvalinputLeg.Text := valores;
end;

procedure TNNTrainning.LoadvalOutputLeg(valores: string);
begin
  FvaloutputLeg.Text := valores;
end;

function TNNTrainning.SavevalInputLeg: string;
begin
  if FvalinputLeg <> nil then
    Result := FvalinputLeg.Text
  else
    Result := '';
end;

function TNNTrainning.SavevalOutputLeg: string;
begin
  if FvaloutputLeg <> nil then
    Result := FvaloutputLeg.Text
  else
    Result := '';
end;

procedure TNNTrainning.AddTrainning(query_index: integer);
var
  item : TSQLEditItem;
begin
  if Assigned(Fsetproject) and (query_index >= 0) and (query_index < Fsetproject.Querycount) then
  begin
    item := Fsetproject.SQLEdit_Indexof(query_index);
    FsqlTrainning := item;
  end;
end;

end.
