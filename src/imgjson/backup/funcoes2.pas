unit funcoes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, TypInfo, Grids , Process,  FileUtil , Controls , Graphics,  ExtCtrls
{$IFDEF MSWINDOWS}
,windows, jwaWinBase, shellAPI , Registry , JwaTlHelp32
{$ENDIF}
{$IFDEF LINUX}
//LCLType,
//LCLIntf
,BaseUnix
,UnixType
,Unix
{$ENDIF}
{$IFDEF DARWIN}

{$ENDIF}       ;

Function RetiraInfo(Value : string): string;
function BuscaChave( lista : TStringList; Ref: String; var posicao:integer): boolean;
function iif(condicao : boolean; verdade : variant; falso: variant):variant;
procedure CriaJSON(ADataset: TDataSet; const AFileName: String);
procedure PopulaPropertys(aGrid: TStringGrid; aObject: TObject);
function PreparaJSON(const Value: String): String;
procedure AdicionarLinhaAGrid(Grid: TStringGrid; Valores: array of string);
function splitstr(input: string): TStringList;
procedure AdicionarLog(const Mensagem: string);
function Callprg(filename: string; source: String; var Output: string): boolean;
function StrtoBin(const Str: string): string;
function BintoStr(const BinaryString: string): string;
function HexToStr(const Value: string): string;
function StrToHex(const Value: string): string;

function GetGPUName(device : integer): string;

implementation

uses setproject;


var LastTickCount     : cardinal = 0;
    LastProcessorTime : int64    = 0;
    FLastIdleTime: Int64;
    FLastKernelTime: Int64;
    FLastUserTime: Int64;

function StrtoBin(const Str: string): string;
var
      I, J: Integer;
      CharCode: Byte;
begin
      Result := '';
      for I := 1 to Length(Str) do
      begin
        CharCode := Ord(Str[I]);
        for J := 7 downto 0 do
          if (CharCode and (1 shl J)) <> 0 then
            Result := Result + '1'
          else
            Result := Result + '0';
      end;
end;

function HexToStr(const Value: string): string;
var
  i: Integer;
begin
  Result := '';
  if Value <> '' then
  begin
    for i := 1 to Length(Value) div 2 do
      Result := Result + Chr(StrToInt('$' + Copy(Value, (i - 1) * 2 + 1, 2)));
  end
  else
      Result := '';
end;

function StrToHex(const Value: string): string;
var
  i: Integer;
begin
  Result := '';
  if (Value <> '') then
  begin
    for i := 1 to Length(Value) do
      Result := Result + IntToHex(Ord(Value[i]), 2);
  end
  else
  begin
    result := '';
  end;
end;


function BintoStr(const BinaryString: string): string;
var
  cont : Integer;
  BinaryChar: string;
  CharCode: Byte;
  innerCont: Integer; // Renomeamos a variável para evitar sobrescrita
begin
  Result := '';
  for cont := 1 to Length(BinaryString) div 8 do
  begin
    BinaryChar := Copy(BinaryString, (cont - 1) * 8 + 1, 8);
    CharCode := 0;
    for innerCont := 1 to 8 do // Renomeamos a variável para evitar sobrescrita
    begin
      if BinaryChar[innerCont] = '1' then
        CharCode := CharCode or (1 shl (8 - innerCont));
    end;
    Result := Result + Chr(CharCode);
  end;
end;


function GetGPUName(device : integer): string;
var
   cmd : TProcess;
   AStringList: TStringList;
begin
   cmd := TProcess.Create(nil);
   // Cria o objeto TStringList.
   AStringList := TStringList.Create;
   cmd.CommandLine := 'nvidia-smi -i '+inttostr(device)+' --format=csv,noheader --query-gpu=gpu_name';

   cmd.Options := cmd.Options + [poWaitOnExit,poUsePipes,poNoConsole];

   cmd.Execute;
   AStringList.LoadFromStream(cmd.Output);

   //AStringList.SaveToFile('output.txt');
   result := trim(AStringList.Text);

   // Agora que o arquivo foi salvo nós podemos liberar a
   // TStringList e o TProcess.
   AStringList.Free;
   cmd.Free;
end;

{$IFDEF LINUX}
function Callprg(filename: string; source: String; var Output: string): boolean;
var
  AProcess: TProcess;
  MemStream: TMemoryStream;
  NumBytes: LongInt;
  Buffer: array[1..2048] of byte;
begin
  Result := False;
  Output := '';

  AProcess := TProcess.Create(nil);
  MemStream := TMemoryStream.Create;
  try
    AProcess.Executable := filename;
    AProcess.Parameters.Add(source);
    AProcess.Options := AProcess.Options + [poUsePipes];

    AProcess.Execute;

    while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do
    begin
      NumBytes := AProcess.Output.Read(Buffer, SizeOf(Buffer));
      if NumBytes > 0 then
      begin
        MemStream.Write(Buffer, NumBytes);
      end;
    end;

    SetLength(Output, MemStream.Size);
    MemStream.Position := 0;
    MemStream.Read(Output[1], MemStream.Size);

    Result := True;
  finally
    MemStream.Free;
    AProcess.Free;
  end;
end;
{$ENDIF}


{$IFDEF MSWINDOWS}
function Callprg(filename: string; source: String; var Output: string): boolean;
var
  resultado: boolean;
  commandLine: string;
  processInfo: TProcessInformation;
  startInfo: TStartupInfo;
  securityAttr: TSecurityAttributes;
  readPipe, writePipe: THandle;
  buffer : string;
  pbuffer: array[0..4095] of Char;
  bytesRead: DWORD;

begin
  resultado := false;
  Output := '';

  FillChar(securityAttr, SizeOf(securityAttr), 0);
  securityAttr.nLength := SizeOf(securityAttr);
  securityAttr.bInheritHandle := TRUE;

  if not CreatePipe(readPipe, writePipe, @securityAttr, 0) then
    Exit(False);

  try
    FillChar(startInfo, SizeOf(startInfo), 0);
    startInfo.cb := SizeOf(startInfo);
    startInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    startInfo.wShowWindow := SW_HIDE; // Oculta a janela do console
    startInfo.hStdOutput := writePipe;
    startInfo.hStdError := writePipe;

    {$IFDEF WINDOWS}
    commandLine := 'cmd.exe /C "' + filename + '" ' + source;
    {$ENDIF}
    //... Ajuste para Linux e macOS como no seu exemplo

    if CreateProcess(nil, PChar(commandLine), nil, nil, TRUE, 0, nil, nil, startInfo, processInfo) then
    begin
      CloseHandle(writePipe); // Não precisa mais do handle de escrita
      WaitForSingleObject(processInfo.hProcess, INFINITE);

      // Lê a saída do processo
      repeat
        bytesRead := 0;
        //function ReadFile(hFile: HANDLE; lpBuffer: LPVOID; nNumberOfBytesToRead: DWORD;  lpNumberOfBytesRead: LPDWORD; lpOverlapped: LPOVERLAPPED): BOOL; stdcall;
        ReadFile(readPipe, @pbuffer[0], 4096, @bytesRead, nil);
        SetString(buffer, pbuffer, bytesRead);
        Output := Output +  buffer;
      until bytesRead < 4096;

      CloseHandle(processInfo.hProcess);
      CloseHandle(processInfo.hThread);
      resultado := True;
    end;
  finally
    CloseHandle(readPipe);
  end;

  Result := resultado;
end;
{$ENDIF}


procedure AdicionarLog(const Mensagem: string);
var
  ArquivoLog: TextFile;
  NomeArquivoLog: string;
begin
  // Obtém o nome do programa atual e muda a extensão para .log
  NomeArquivoLog := ChangeFileExt(ExtractFileName(ParamStr(0)), '.log');

  // Tenta abrir o arquivo para adicionar texto. Se o arquivo não existir, ele será criado.
  AssignFile(ArquivoLog, NomeArquivoLog);
  if FileExists(NomeArquivoLog) then
    Append(ArquivoLog)  // Abre o arquivo para adicionar texto no final
  else
    Rewrite(ArquivoLog); // Cria um novo arquivo de log se não existir

  // Escreve a mensagem no arquivo
  WriteLn(ArquivoLog, Format('%s: %s', [DateTimeToStr(Now), Mensagem]));

  // Fecha o arquivo
  CloseFile(ArquivoLog);
end;


function splitstr(input: string): TStringList;
var
  i: Integer;
  start: Integer;
begin
  // Criando a TStringList que será retornada
  Result := TStringList.Create;

  // Substituindo '-' e '_' por espaços
  input := StringReplace(input, '-', ' ', [rfReplaceAll]);
  input := StringReplace(input, '_', ' ', [rfReplaceAll]);

  // Quebrando a string em palavras e adicionando à TStringList
  i := 1;
  while i <= Length(input) do
  begin
    // Encontrando uma palavra
    while (i <= Length(input)) and (input[i] = ' ') do Inc(i);
    if i <= Length(input) then
    begin
      start := i;
      while (i <= Length(input)) and (input[i] <> ' ') do Inc(i);
      Result.Add(trim(Copy(input, start, i - start)));
    end;
  end;
end;


function PreparaJSON(const Value: String): String;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Value) do
  begin
    case Value[i] of
      '\': Result := Result + '\\';
      '"': Result := Result + '\"';
      '/': Result := Result + '\/';
      #8: Result := Result + '\b';
      #9: Result := Result + '\t';
      #10: Result := Result + '\n';
      #12: Result := Result + '\f';
      #13: Result := Result + '\r';
    else
      Result := Result + Value[i];
    end;
  end;
end;

procedure AdicionarLinhaAGrid(Grid: TStringGrid; Valores: array of string);
var
  i, RowIndex: Integer;
begin
  // Checa se a grade tem colunas suficientes
  if High(Valores) >= Grid.ColCount then
    Grid.ColCount := High(Valores) + 1;

  // Adiciona uma nova linha
  RowIndex := Grid.RowCount;
  Grid.RowCount := Grid.RowCount + 1;

  // Preenche a linha com os valores fornecidos
  for i := Low(Valores) to High(Valores) do
    Grid.Cells[i, RowIndex] := Valores[i];
end;

procedure PopulaPropertys(aGrid: TStringGrid; aObject: TObject);
var
  ClassType: TClass;
  nome : ShortString;
  setproject : TSetProject;
begin
  //aGrid.Clear;
  // Obtendo informação do tipo do objeto
  ClassType := aObject.ClassType;
  nome := ClassType.ClassName;

  if(LowerCase(nome)='tsetproject') then
  begin
       setProject := TSetProject(aObject);
       AdicionarLinhaAGrid(aGrid,['ClassName', setProject.ClassName]);
       AdicionarLinhaAGrid(aGrid,['Filename', setProject.Filename]);
       AdicionarLinhaAGrid(aGrid,['Diretorio', setProject.Diretorio]);
       AdicionarLinhaAGrid(aGrid,['DataBaseType', inttostr(integer(setProject.DataBaseType))]);
       AdicionarLinhaAGrid(aGrid,['StringConnection', setProject.StringConnection]);
       AdicionarLinhaAGrid(aGrid,['Username', setProject.Username]);
       AdicionarLinhaAGrid(aGrid,['Password', setProject.Password]);
       AdicionarLinhaAGrid(aGrid,['Hostname', setProject.HostName]);
  end;


end;

procedure CriaJSON(ADataset: TDataSet; const AFileName: String);
var
  JSONStringList: TStringList;
  I: Integer;
  Field: TField;
  Line: String;
begin
  JSONStringList := TStringList.Create;
  try
    JSONStringList.Add('[');
    ADataset.First;
    while not ADataset.Eof do
    begin
      Line := '  {';
      for I := 0 to ADataset.FieldCount - 1 do
      begin
        Field := ADataset.Fields[I];
        Line := Line + Format('"%s":"%s"', [Field.FieldName, Field.AsString]);
        if I < ADataset.FieldCount - 1 then
          Line := Line + ', ';
      end;
      Line := Line + '}';
      ADataset.Next;
      if not ADataset.Eof then
        Line := Line + ',';
      JSONStringList.Add(Line);
    end;
    JSONStringList.Add(']');
    JSONStringList.SaveToFile(AFileName);
  finally
    JSONStringList.Free;
  end;
end;

function iif(condicao : boolean; verdade : variant; falso: variant):variant;
begin
     if condicao then
     begin
          result := verdade;
     end
     else
     begin
       result := falso
     end;
end;

//Retira o bloco de informação
Function RetiraInfo(Value : string): string;
var
  posicao : integer;
  resultado : string;
begin
     resultado := '';
     posicao := pos(':',value);
     if(posicao >-1) then
     begin
          resultado := copy(value,posicao+1,length(value));
     end;
     result := resultado;
end;

function BuscaChave( lista : TStringList; Ref: String; var posicao:integer): boolean;
var
  contador : integer;
  maximo : integer;
  item : string;
  indo : integer;
  resultado : boolean;
begin
     maximo := lista.Count-1;
     resultado := false;
     for contador := 0 to maximo do
     begin
       item := lista.Strings[contador];
       indo := pos(Ref,item);
       if (indo > 0) then
       begin
            posicao := contador;
            resultado := true;
            break;
       end;
     end;
     result := resultado;
end;

end.


