unit Item;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs, SynCompletion, ExtCtrls, SynEdit, SynHighlighterPas,
  SynHighlighterAny,SynHighlighterPo,SynHighlighterCpp,SynHighlighterSQL,SynHighlighterPython,
  SynHighlighterPHP,synhighlighterunixshellscript, SynHighlighterBat,
  SynHighlighterJava,  SynHighlighterJScript,
  SynHighlighterCss, //SynHighlighterJSON,
  Graphics, SynEditKeyCmds, LCLType, Variants,
  PythonEngine, PythonGUIInputOutput, setmain, funcoes, hint, Dialogs, StdCtrls;

type TFuncPosition = record
  y1, y2: integer;
end;

type
TTypeItem  = (ti_NODEFINE, ti_E , ti_H , ti_CCP, ti_PAS, ti_Reg, ti_BAT,
           ti_CFG , ti_TXT, ti_SQL,ti_PY, ti_PHP, ti_JAVA, ti_JS, ti_HTML, ti_CSS,
           ti_INO, ti_SHELL, ti_ALL);
TProjetoTipo = (pt_NODEFINE, pt_TEXT, pt_ProjetoRoot, pt_ProjetoSetup, pt_ProjetoSetupItem, pt_ProjetoFiles, pt_ProjetoDirFiles, pt_ProjetoFilesItem);
TTipoInfo = (Name, Path);

TPythonCtrl = class(TComponent)
   private
         FPythonEngine: TPythonEngine;
         FPythonGUIInputOutput1: TPythonGUIInputOutput;
         //FVarsList: PPyObject;
         FVarsDict: PPyObject;
         FVarsGlobal: PPyObject;
         FVarsGlobalKeys : PPyObject;
         FVarsLocal: PPyObject;
         FVarsLocalKeys : PPyObject;
         //FVarsLocal: PPyObject;
         FVarListGlobal_Size: NativeInt;
         FVarListLocal_Size: NativeInt;
         FVarsCheck : boolean;
   public
         property VarsDict: PPyObject read FVarsDict write FVarsDict;
         property PythonGUIInputOutput1: TPythonGUIInputOutput read FPythonGUIInputOutput1  write FPythonGUIInputOutput1;
         property VarsGlobal: PPyObject read FVarsGlobal write FVarsGlobal;
         property VarsLocal: PPyObject read FVarsLocal write FVarsLocal;
         property VarsGlobalKeys : PPyObject read  FVarsGlobalKeys write FVarsGlobalKeys;
         property VarsLocalKeys : PPyObject read  FVarsLocalKeys write FVarsLocalKeys;
         property PythonEngine: TPythonEngine read FPythonEngine write FPythonEngine;
         property VarListGlobal_Size : NativeInt read FVarListGlobal_Size write FVarListGlobal_Size;
         property VarListLocal_Size : NativeInt read FVarListLocal_Size write FVarListLocal_Size;
         property VarsCheck : boolean read FVarsCheck write FVarsCheck;
end;

{ TItem }

TItem = class(TComponent)
      private
         FListaItem: TObjectList;
         FPalavrasReservadas : TStringList;
         FItemType : TTypeItem; (*Nao esta sendo usado p nada*)
         Fsyn : TSynEdit;
         FResultado : TCustomMemo;
         FSynAutoComplete: TSynAutoComplete;
         Ftimer : TTimer;
         FSender: TComponent;
         FPythonCtrl : TPythonCtrl; //Python controle
         FError : Boolean;
         FLinhaError : integer;
         FColumError : integer;
         FFileError : String; //Erro no arquivo



         FMainModule : PPyObject;
         (*Decoration*)
         FSynPasSyn1: TSynPasSyn;
         FSynBatSyn1: TSynBatSyn;

         FSynCppSyn1: TSynCppSyn;
         FSynCssSyn1: TSynCssSyn;
         FSynJavaSyn1: TSynJavaSyn;
         FSynJScriptSyn1: TSynJScriptSyn;
         FSynPHPSyn1: TSynPHPSyn;
         FSynPythonSyn1: TSynPythonSyn;
         FSynSQLSyn1: TSynSQLSyn;
         FSynSQLSyn2: TSynSQLSyn;
         FSynUNIXShellScriptSyn1: TSynUNIXShellScriptSyn;
         FsynCompletion : TSynCompletion;

         function PesquisaPar(param: string; lst: TStringlist): string;

         procedure default();
         procedure SetItemType(value : TTypeItem);
         procedure SetSyn(value : TSynEdit);
         procedure  TimerEvento(Sender: TObject);
         procedure SynCompletion1Execute(Sender: TObject);
         procedure CheckTipoArquivo();
         procedure ConfigurePHPHighlighter(var APHPHighlighter: TSynPHPSyn);
         procedure ConfigureCppHighlighter(var ACppHighlighter: TSynCppSyn);
         procedure ConfigureJScriptHighlighter(var AJScriptHighlighter: TSynJScriptSyn);
         procedure ConfigureJavaHighlighter(var AJavaHighlighter: TSynJavaSyn);
         procedure SynCompletion1CodeCompletion(var Value: string;
                     SourceValue: string; var SourceStart, SourceEnd: TPoint; KeyChar: TUTF8Char;
                     Shift: TShiftState);
         procedure SynCompletion1SearchPosition(var APosition: integer);
         procedure MessageHint(sender : TComponent; info: string);
         function getPascfuncs(SynEdit: TSynEdit): TFuncPosition;
      public
         Nome: String;
         FileName : String;
         DirName : String;
         FileExt : string;
         {#IFDEF WINDOWS}
         VolName : String;
         {#ENDIF}

         ProjetoTipo : TProjetoTipo;  (*Nao esta sendo usado p nada*)
         Salvo : Boolean;



         constructor Create(Sender: TComponent);
         destructor destroy();
         procedure Mudou();
         procedure AtribuiNome(Arquivo:String);
         procedure AtribuiNovoNome();
         procedure Savefile(arquivo: string);
         procedure Loadfile(arquivo: string);
         procedure SetResultado( value : TCustomMemo);
         procedure Run();
         //function classificaTipo(arquivo : string): TTypeItem;
         property ItemType : TTypeItem read FItemType write setItemType;
         property syn :TSynEdit read Fsyn write setSyn;
         property PalavrasReservadas : TStringlist read FPalavrasReservadas write FPalavrasReservadas;
         property SynAutoComplete: TSynAutoComplete read FSynAutoComplete write FSynAutoComplete;
         property Resultado : TCustomMemo read FResultado  write SetResultado;
         property LinhaError : integer read FLinhaError;
         property Error : boolean read FError;
         property FileError : String read FFileError;
         property PythonCtrl : TPythonCtrl read FPythonCtrl;

end;

implementation




function TItem.getPascfuncs(SynEdit: TSynEdit): TFuncPosition;
var
  i, j: integer;
  funcBegin, funcEnd: boolean;
begin
  Result.y1 := -1; // Inicia a posição como -1 para indicar que a posição não foi encontrada
  Result.y2 := -1;
  funcBegin := false;
  funcEnd := false;
  (*
  for i := 0 to SynEdit.Lines.Count - 1 do // Percorre todas as linhas do SynEdit
  begin
    j := 1;

    while j <= Length(SynEdit.Lines[i]) do // Percorre cada caractere da linha
    begin
      if (SynEdit.Lines[i][j] = 'f') and (SynEdit.Lines[i][j+1] = 'u') and (SynEdit.Lines[i][j+2] = 'n') and
         (SynEdit.Lines[i][j+3] = 'c') and (SynEdit.Lines[i][j+4] = 't') and (SynEdit.Lines[i][j+5] = 'i') and
         (SynEdit.Lines[i][j+6] = 'o') and (SynEdit.Lines[i][j+7] = 'n') then // Verifica se a linha contém a palavra "function"
      begin
        Result.y1 := i; // Armazena a posição de início da função
        funcBegin := true; // Marcador para indicar que a função foi encontrada
        Break;
      end
      else if (SynEdit.Lines[i][j] = 'p') and (SynEdit.Lines[i][j+1] = 'r') and (SynEdit.Lines[i][j+2] = 'o') and
              (SynEdit.Lines[i][j+3] = 'c') and (SynEdit.Lines[i][j+4] = 'e') and (SynEdit.Lines[i][j+5] = 'd') and
              (SynEdit.Lines[i][j+6] = 'u') and (SynEdit.Lines[i][j+7] = 'r') and (SynEdit.Lines[i][j+8] = 'e') then // Verifica se a linha contém a palavra "procedure"
      begin
        Result.y1 := i; // Armazena a posição de início do procedimento
        funcBegin := true; // Marcador para indicar que o procedimento foi encontrado
        Break;
      end;
      inc(j);
    end;

    if funcBegin then // Se a função ou procedimento foi encontrada, encontra sua linha final
    begin
      while i <= SynEdit.Lines.Count - 1 do // Percorre as linhas a partir da posição onde a função ou procedimento foi iniciado
      begin
        j := 1;

        while j <= Length(SynEdit.Lines[i]) do // Percorre cada caractere da linha
        begin
          if (SynEdit.Lines[i][j] = 'e') and (SynEdit.Lines[i][j+1] = 'n') and (SynEdit.Lines[i][j+2] = 'd') then // Verifica se a linha contém a palavra "end"
          begin
            Result.y2 := i; // Armazena a posição final da função ou procedimento
            funcEnd := True; // Marcador para indicar que a posição final foi encontrada
            Break;
          end;
          j := j +1;
        end;

        if funcEnd then // Se a posição final foi encontrada, sai do segundo loop
        begin
          Break
        end
        else // Senão, passa para a próxima linha do SynEdit
        begin
          i := i +1;
        end;
      end;

      if funcEnd then // Se a posição final foi encontrada, sai do primeiro loop
      begin
        Break
      end
      else // Senão, armazena -1 nas posições de início e fim e sai do primeiro loop
      begin
        Result.y1 := -1;
        Result.y2 := -1;
        Break;
      end;
    end;

  end;
  *)
end;

procedure TItem.SynCompletion1SearchPosition(var APosition: integer);
begin
  (*
   if (FItemType = ti_sql) then
   begin
     if frmMQuery <> nil then
      begin
        sql.sqldialect := sqlMySQL;
        if (frmMQuery.zmycon.Connected) then
        begin
          if (frmMQuery.getdatabasetype = DBMysql) then
          begin
            sql.SQLDialect:= sqlMySQL;
          end;
          if (frmMQuery.getdatabasetype = DBPostgres) then
          begin
            sql.SQLDialect:= sqlPostgres;
          end;
          sql.tableNames := frmMQuery.GetTables();
        end;


   end;
    *)


end;


procedure TItem.SynCompletion1CodeCompletion(var Value: string;
  SourceValue: string; var SourceStart, SourceEnd: TPoint; KeyChar: TUTF8Char;
  Shift: TShiftState);
var
   listagem : TStringlist;

begin
   listagem := TStringlist.Create();
   listagem.Text:= SourceValue;
   if SourceStart.x > 0 then
   begin
       if syn.Lines[SourceStart.y - 1][SourceStart.x-1] = '\' then
       begin
           SourceStart.x -= 1;
           SourceValue := '\' + SourceValue;
       end;
    end;
end;

procedure TItem.SynCompletion1Execute(Sender: TObject);
var
    i: Integer;
begin
   // Limpa a lista de sugestões antes de adicionar novas
   FSynCompletion.ItemList.Clear;

   // Adiciona sugestões à lista de itens
   for i := 0 to FPalavrasReservadas.Count - 1 do
   begin
        if Pos(FSynCompletion.CurrentString, FPalavrasReservadas[i]) = 1 then
        begin
          FSynCompletion.ItemList.Add(FPalavrasReservadas[i]);
        end;
   end;

end;

procedure TItem.ConfigurePHPHighlighter(var APHPHighlighter: TSynPHPSyn);
begin
  // Configuração padrão para comentários
  APHPHighlighter.CommentAttri.Foreground := clGreen;
  APHPHighlighter.CommentAttri.Style := [fsItalic];

  // Configuração padrão para palavras-chave
  APHPHighlighter.KeyAttri.Foreground := clNavy;
  APHPHighlighter.KeywordAttribute.Style := [fsBold];

  // Configuração padrão para identificadores
  APHPHighlighter.IdentifierAttri.Foreground := clBlack;

  // Configuração padrão para números
  APHPHighlighter.NumberAttri.Foreground := clTeal;

  // Configuração padrão para strings e caracteres
  APHPHighlighter.StringAttri.Foreground := clMaroon;
  //APHPHighlighter.CharAttri.Foreground := clMaroon;


  // Configuração padrão para diretivas de pré-processador
  //APHPHighlighter.PreprocessorAttri.Foreground := clPurple;

  //APHPHighlighter.PreprocessorAttri.Style := [fsBold];
  //APHPHighlighter.GetTokenAttribute.Style := [fsBold];



  // Configuração padrão para símbolos e pontuação
  APHPHighlighter.SymbolAttri.Foreground := clBlack;
end;


procedure TItem.ConfigureCppHighlighter(var ACppHighlighter: TSynCppSyn);
begin
  // Configuração padrão para comentários
  ACppHighlighter.CommentAttri.Foreground := clGreen;
  ACppHighlighter.CommentAttri.Style := [fsItalic];

  // Configuração padrão para palavras-chave
  ACppHighlighter.KeyAttri.Foreground := clNavy;
  ACppHighlighter.KeywordAttribute.Style := [fsBold];

  // Configuração padrão para identificadores
  ACppHighlighter.IdentifierAttri.Foreground := clBlack;

  // Configuração padrão para números
  ACppHighlighter.NumberAttri.Foreground := clTeal;

  // Configuração padrão para strings e caracteres
  ACppHighlighter.StringAttri.Foreground := clMaroon;
  //ACppHighlighter.CharAttri.Foreground := clMaroon;


  // Configuração padrão para diretivas de pré-processador
  //ACppHighlighter.PreprocessorAttri.Foreground := clPurple;

  //ACppHighlighter.PreprocessorAttri.Style := [fsBold];
  //ACppHighlighter.GetTokenAttribute.Style := [fsBold];



  // Configuração padrão para símbolos e pontuação
  ACppHighlighter.SymbolAttri.Foreground := clBlack;
end;

procedure TItem.ConfigureJScriptHighlighter(
  var AJScriptHighlighter: TSynJScriptSyn);
begin
  // Configuração padrão para comentários
  AJScriptHighlighter.CommentAttri.Foreground := clGreen;
  AJScriptHighlighter.CommentAttri.Style := [fsItalic];

  // Configuração padrão para palavras-chave
  AJScriptHighlighter.KeyAttri.Foreground := clNavy;
  AJScriptHighlighter.KeywordAttribute.Style := [fsBold];

  // Configuração padrão para identificadores
  AJScriptHighlighter.IdentifierAttri.Foreground := clBlack;

  // Configuração padrão para números
  AJScriptHighlighter.NumberAttri.Foreground := clTeal;

  // Configuração padrão para strings e caracteres
  AJScriptHighlighter.StringAttri.Foreground := clMaroon;
  //AJScriptHighlighter.CharAttri.Foreground := clMaroon;


  // Configuração padrão para diretivas de pré-processador
  //AJScriptHighlighter.PreprocessorAttri.Foreground := clPurple;

  //AJScriptHighlighter.PreprocessorAttri.Style := [fsBold];
  //AJScriptHighlighter.GetTokenAttribute.Style := [fsBold];



  // Configuração padrão para símbolos e pontuação
  AJScriptHighlighter.SymbolAttri.Foreground := clBlack;

end;

procedure TItem.ConfigureJavaHighlighter(var AJavaHighlighter: TSynJavaSyn);
begin
  // Configuração padrão para comentários
   AJavaHighlighter.CommentAttri.Foreground := clGreen;
   AJavaHighlighter.CommentAttri.Style := [fsItalic];

   // Configuração padrão para palavras-chave
   AJavaHighlighter.KeyAttri.Foreground := clNavy;
   AJavaHighlighter.KeywordAttribute.Style := [fsBold];

   // Configuração padrão para identificadores
   AJavaHighlighter.IdentifierAttri.Foreground := clBlack;

   // Configuração padrão para números
   AJavaHighlighter.NumberAttri.Foreground := clTeal;

   // Configuração padrão para strings e caracteres
   AJavaHighlighter.StringAttri.Foreground := clMaroon;
   //ACppHighlighter.CharAttri.Foreground := clMaroon;


   // Configuração padrão para diretivas de pré-processador
   //ACppHighlighter.PreprocessorAttri.Foreground := clPurple;

   //ACppHighlighter.PreprocessorAttri.Style := [fsBold];
   //ACppHighlighter.GetTokenAttribute.Style := [fsBold];



   // Configuração padrão para símbolos e pontuação
   AJavaHighlighter.SymbolAttri.Foreground := clBlack;

end;

procedure TItem.AtribuiNovoNome();
begin
     default();

end;





procedure TItem.default();
begin

  Ftimer.Enabled := false;
  Ftimer.Interval:= 1000;
  FError := false;
  FLinhaError:= 0;
  FColumError:= 0;
  FFileError := '';
  PythonCtrl.VarsCheck := false;
  Ftimer.OnTimer:= @TimerEvento;
  FPalavrasReservadas.clear;
  if (FSynCompletion = nil) then
     FSynCompletion := TSynCompletion.Create(Fsender);
  FSynCompletion.Editor := Fsyn;
  FSynCompletion.OnCodeCompletion:=@SynCompletion1CodeCompletion;
  FSynCompletion.OnExecute:=@SynCompletion1Execute;
  FSynCompletion.OnSearchPosition:=@SynCompletion1SearchPosition;





  ItemType :=  ti_NODEFINE;
  ProjetoTipo := pt_NODEFINE;
  Nome := 'Novo';
  DirName := '';
  FileName := '';
  FileExt := '';

  {#ifdef WINDOWS}
  VolName:= '';
  {#endif}
end;

procedure TItem.CheckTipoArquivo();
var
    a : integer;
begin
   //item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
   //syn := item.syn;
   //if (item.ItemType = ti_sql) then
  //posicao := pos('.pas',arquivo);
  if(FileExt ='.pas') then
  begin
    if (FSynPasSyn1 = nil) then
    begin
      FSynPasSyn1 := TSynPasSyn.Create(FSender);
    end;
    Fsyn.Highlighter := FSynPasSyn1;
    FItemType := ti_PAS;
  end;
  if(FileExt ='.sh')  then
  begin
    if(FSynUNIXShellScriptSyn1 = nil) then
    begin
      FSynUNIXShellScriptSyn1 := TSynUNIXShellScriptSyn.create(FSender);
    end;
    Fsyn.Highlighter := FSynUNIXShellScriptSyn1;
    FItemType := ti_SHELL;
  end;
  if(FileExt = '.php') then
  begin
    if(FSynPHPSyn1 = nil) then
    begin
      FSynPHPSyn1 := TSynPHPSyn.create(FSender);

    end;
    Fsyn.Highlighter := FSynPHPSyn1;
    ConfigurePHPHighlighter(FSynPHPSyn1);
    FItemType := ti_PHP;
  end;
  if(FileExt='.c') then
  begin
    if(FSynCppSyn1 = nil) then
    begin
      FSynCppSyn1 := TSynCppSyn.create(FSender);
    end;
    Fsyn.Highlighter := FSynCppSyn1;
    FItemType := ti_CCP;
    ConfigureCppHighlighter(FSynCppSyn1);
  end;
  if(FileExt = '.cpp') then
  begin
    if(FSynCppSyn1 = nil) then
    begin
      FSynCppSyn1 := TSynCppSyn.create(FSender);
    end;
    Fsyn.Highlighter := FSynCppSyn1;
    FItemType := ti_CCP;

    ConfigureCppHighlighter(FSynCppSyn1);
  end;
  if(FileExt ='.h') then
  begin
    if(FSynCppSyn1 = nil) then
    begin
      FSynCppSyn1 := TSynCppSyn.create(FSender);
    end;
    Fsyn.Highlighter := FSynCppSyn1;
    FItemType := ti_CCP;
    ConfigureCppHighlighter(FSynCppSyn1);
  end;
  if(FileExt = '.sql') then
  begin
    if(FSynSQLSyn1 = nil) then
    begin
      FSynSQLSyn1 := TSynSQLSyn.create(FSender);
    end;
    Fsyn.Highlighter := FSynSQLSyn1;
    FItemType := ti_SQL;
    (*
    if (frmMQuery <> nil) then
    begin
       for a := 0 to frmMQuery.Tables.Count-1 do
       begin
         FListaItem.Add(frmMQuery.Tables.Objects[a]);
       end;
    end;
    *)
  end;
  if(FileExt = '.py') then
  begin
    if(FSynPythonSyn1 = nil) then
    begin
      FSynPythonSyn1 := TSynPythonSyn.create(FSender);
    end;
    Fsyn.Highlighter := FSynPythonSyn1;
    //Fsyn.Highlighter := FSynUNIXShellScriptSyn1;
    FItemType := ti_PY;
  end;
  if(FileExt='.java') then
  begin
    if(FSynJavaSyn1 = nil) then
    begin
      FSynJavaSyn1 := TSynJavaSyn.create(FSender);
    end;
    Fsyn.Highlighter := FSynJavaSyn1;
    ConfigureJavaHighlighter(FSynJavaSyn1);
    FItemType := ti_JAVA;
  end;
  if(FileExt='.css') then
  begin
    if(FSynCssSyn1 = nil) then
    begin
      FSynCssSyn1 := TSynCssSyn.create(FSender);
    end;
    Fsyn.Highlighter := FSynCssSyn1;
    FItemType := ti_CSS;
  end;
  if(FileExt='.js') then
  begin
    if(FSynJScriptSyn1 = nil) then
    begin
      FSynJScriptSyn1 := TSynJScriptSyn.create(FSender);
    end;
    Fsyn.Highlighter := FSynJScriptSyn1;
    FItemType := ti_js;
    ConfigureJScriptHighlighter(FSynJScriptSyn1);
  end;
end;

procedure TItem.SetItemType(value: TTypeItem);
begin
  FItemType:= value;
  case FItemType of
    ti_PAS :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'delphi32.dci') then
      begin
            FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'delphi32.dci');
      end;
    end;
    ti_PY :
    begin
       FSynAutoComplete.AutoCompleteList.clear;
       if FileExists(ExtractFilePath(ApplicationName)+'pythonlist.dci') then
       begin
              FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'pythonlist.dci');
       end;
    end;
    ti_SQL :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'sqllist.dci') then
      begin
         FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'sqllist.dci');
      end;
    end;
    ti_SHELL :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'c.dci') then
      begin
          FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'c.dci');
      end;
    end;

    ti_CCP :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'c.dci') then
      begin
          FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'c.dci');
      end;
    end;
    ti_H :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'c.dci') then
      begin
          FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'c.dci');
      end;

    end;
    ti_INO :
      begin
        FSynAutoComplete.AutoCompleteList.clear;
        if FileExists(ExtractFilePath(ApplicationName)+'c.dci') then
        begin
            FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'c.dci');
        end;

      end;
    ti_PHP :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'phplist.dci') then
      begin
            FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'phplist.dci');
      end;
    end;
    ti_JAVA :
    begin
      FSynAutoComplete.AutoCompleteList.clear;
      if FileExists(ExtractFilePath(ApplicationName)+'javalist.dci') then
      begin
         FSynAutoComplete.AutoCompleteList.LoadFromFile(ExtractFilePath(ApplicationName)+'javalist.dci');
      end;
    end;
    ti_TXT :
    begin
      FSynAutoComplete.AutoCompleteList.clear;

    end;
    ti_CFG :
    begin
      FSynAutoComplete.AutoCompleteList.clear;

    end;
  end;
  //AutoComplete.AutoCompleteList.;
end;

procedure TItem.SetSyn(value: TSynEdit);
begin
  fsyn := value;
  FSynAutoComplete.Editor := value;

end;

procedure TItem.TimerEvento(Sender: TObject);
begin
  //Nada ainda
end;

constructor TItem.Create(Sender: TComponent);
begin
  FSender := Sender;
  Ftimer := TTimer.create(FSender);
  FPalavrasReservadas := TStringlist.create();
  FSynCompletion := TSynCompletion.create(Fsender);
  FSynAutoComplete:= TSynAutoComplete.Create(FSynCompletion);

  FSynAutoComplete.ExecCommandID:= ecSynAutoCompletionExecute;
  FPythonCtrl := TPythonCtrl.Create(sender); //Python controle
  //FVarsList := TStringList.Create;

  default();
  Salvo := false;
end;

destructor TItem.destroy();
begin
  Ftimer.free;
  //FVarsList.Free;
  FPalavrasReservadas.free;
  PalavrasReservadas:= nil;
end;

procedure TItem.Mudou();
begin
  Salvo := false;
end;


procedure TItem.AtribuiNome(Arquivo:String);
begin
  //Atribui parametros de Arquivo
  if (Arquivo <> '') then
  begin
       Nome := ExtractFileName(Arquivo);
       DirName := ExtractFileDir(Arquivo);
       FileName := Arquivo;
       FileExt:= ExtractFileExt(Arquivo);
       //ItemType := AtribuiExt(FileExt);
       {#ifdef WINDOWS}
       VolName:= ExtractFileDrive(Arquivo);
       {#endif}
       CheckTipoArquivo();
  end;
end;

procedure TItem.Savefile(arquivo: string);
begin
  AtribuiNome(arquivo);

  CheckTipoArquivo();

end;

function TItem.PesquisaPar(param: string; lst: TStringlist): string;
var
  a: integer;
  resultado1 : string;
begin
  resultado1 := '';
  for a:= 0 to lst.Count-1 do
  begin
    if (pos(param,lst.Strings[a])>=0) then
    begin
       resultado1 := copy( lst.Strings[a], length(param),length(lst.Strings[a]));

    end;
  end;
  result := resultado1;

end;

procedure TItem.Loadfile(arquivo: string);
begin
  AtribuiNome(arquivo);
  //FItemType := classificaTipo(arquivo);
  CheckTipoArquivo();

end;

procedure TItem.SetResultado(value: TCustomMemo);
begin
  FResultado := value;
end;

procedure TItem.MessageHint(sender : TComponent; info: string);
var
  frmHint : TfrmHint;
begin
  frmHint := TfrmHint.create(sender);
  frmHint.messagehint(info);
end;

procedure TItem.Run();
var
   Output : string;
   filenamerun : string;
   PyMainModule: PPyObject;
begin
   //FItemType:= value;
  case FItemType of
    ti_PY :
    begin
       if(FSetMain.DLLPath<>'') then
       begin
         if (FPythonCtrl.PythonEngine = nil) then
         begin
            FPythonCtrl.PythonEngine := TPythonEngine.Create(FSender);
         end;
         if(FResultado = nil) then
         begin
            FResultado.Lines.clear;
         end;
         if (FPythonCtrl.PythonGUIInputOutput1 = nil) then
         begin
              FPythonCtrl.PythonGUIInputOutput1 := TPythonGUIInputOutput.create(FSender);
         end;
         //FVarsList.Clear;
         FPythonCtrl.PythonEngine.Name := 'PythonEngine';
         FPythonCtrl.PythonEngine.AutoLoad := true;
         FPythonCtrl.PythonEngine.FatalAbort := True;
         FPythonCtrl.PythonEngine.FatalMsgDlg := True;
         FPythonCtrl.PythonEngine.UseLastKnownVersion := True;
         FPythonCtrl.PythonEngine.AutoLoad:= true;
         FFileError := ''; //Zera o erro
         //FPythonEngine.PythonPath:='C:\Users\marcelo.maurin\AppData\Local\Programs\Python\Python311\';
         //FPythonEngine.DllPath:='C:\Users\marcelo.maurin\AppData\Local\Programs\Python\Python311\';
         FPythonCtrl.FPythonEngine.DllPath:= FSetMain.DLLPath;
         //PythonEngine.RegVersion :=  '3.11';

         //  PythonEngine.DllName := 'libpython3.7.dylib';
         //  PythonEngine.DllPath :=
         //    '/usr/local/Cellar/python/3.7.7/Frameworks/Python.framework/Versions/3.7/lib/';
         //  PythonEngine.RegVersion := '3.7';
         //  PythonEngine.UseLastKnownVersion := False;


         FPythonCtrl.PythonEngine.AutoFinalize := True;
         FPythonCtrl.PythonEngine.InitThreads := True;
         FPythonCtrl.PythonEngine.PyFlags := [pfInteractive];
         FPythonCtrl.PythonEngine.IO := FPythonCtrl.FPythonGUIInputOutput1;
         if( FResultado <> nil) then
         begin
            FPythonCtrl.PythonGUIInputOutput1.Output :=FResultado;
         end;
         if not FPythonCtrl.PythonEngine.Initialized then
         begin
            FPythonCtrl.PythonEngine.LoadDll;

         //FPythonCtrl.PythonEngine.Py_Initialize;
         end;

         filenamerun:= FileName;


         //showmessage(filenamerun);
         try

            FPythonCtrl.PythonEngine.ExecStrings(Fsyn.Lines);

            if (PythonCtrl.VarsCheck) then
            begin
                 FMainModule:= PythonCtrl.FPythonEngine.PyImport_ImportModule('__main__');

                 FPythonCtrl.FVarsDict := FPythonCtrl.PythonEngine.PyModule_GetDict(FMainModule);

                 PyMainModule := FPythonCtrl.PythonEngine.PyImport_AddModule('__main__');
                 FPythonCtrl.VarsDict:= FPythonCtrl.PythonEngine.PyModule_GetDict(PyMainModule);


                 FPythonCtrl.FVarsGlobal  :=  @FPythonCtrl.FPythonEngine.PyDict_New;

                 FPythonCtrl.VarsGlobalKeys:= FPythonCtrl.PythonEngine.PyDict_Keys(FPythonCtrl.VarsGlobal);
                 if (FPythonCtrl.VarsGlobalKeys <> nil) then
                 begin
                      FPythonCtrl.VarListGlobal_Size := FPythonCtrl.PythonEngine.PyList_Size(FPythonCtrl.VarsGlobalKeys);

                 end;


                 FPythonCtrl.VarsLocal:=@FPythonCtrl.PythonEngine.PyDict_New;
                 FPythonCtrl.VarsLocalKeys:= FPythonCtrl.PythonEngine.PyDict_Keys(FPythonCtrl.VarsLocal);
                 if (FPythonCtrl.VarsLocalKeys <> nil) then
                 begin
                      FPythonCtrl.VarListLocal_Size := FPythonCtrl.PythonEngine.PyList_Size(FPythonCtrl.VarsLocalKeys);
                 end;
            end;
            FError := false;


         except
               on E: EPythonError  do
               begin
                 FError := true;

                 FResultado.Append('Erro Python: ' + E.Message);
               end;
               on E: EPySyntaxError do
               begin
                 FLinhaError:= E.ELineNumber;
                 FColumError:=E.EEndOffset;
                 FFileError := E.EFileName;
                 FResultado.Append('Erro Python: ' +E.EFileName + ' ' + E.ELineStr);
               end;
               on E: EPyIndentationError do
               begin
                 FLinhaError:= E.ELineNumber;
                 FColumError:=E.EEndOffset;
                 FFileError := E.EFileName;
                 FResultado.Append('Erro Python: ' +E.EFileName + ' ' + E.ELineStr);
               end;
         end;

         //PythonEngine.;
         //PythonGUIInputOutput1.free;
         //PythonEngine.Free;
       end
       else
       begin
         filenamerun := FSetMain.RunScript+' '+FileName ;
         if (filenamerun <> '') then
         begin
              {$IFDEF WINDOWS}
              if(Callprg(filenamerun, '', Output)=true) then
              begin
                   //showmessage('Run program!!');
                   MessageHint(Fsender,'Run script'+ filenamerun);
                   //meResult.Lines.Text:= Output;
                   //pnResult.Visible:= true;
              end
              else
              begin
                   //showmessage('Fail run!!');
                   MessageHint(Fsender,'fail run script'+ filenamerun);
                   //pnResult.Visible:= false;
              end;
              {$ENDIF}
         end
         else
         begin
             MessageHint(Fsender,'Config RUN need!'+ filenamerun);
             //pnResult.Visible:= false;
         end;
       end;
    end;
    else
    begin

       filenamerun := FSetMain.RunScript;
       if (filenamerun <> '') then
       begin
            {$IFDEF WINDOWS}
            if(Callprg(filenamerun, '', Output)=true) then
            begin
                 //showmessage('Run program!!');
                 MessageHint(Fsender,'Run script'+ filenamerun);
                 //meResult.Lines.Text:= Output;
                 //pnResult.Visible:= true;
            end
            else
            begin
                 //showmessage('Fail run!!');
                 MessageHint(Fsender,'fail run script'+ filenamerun);
                 //pnResult.Visible:= false;
            end;
            {$ENDIF}
       end
       else
       begin
           MessageHint(Fsender,'Config RUN need!'+ filenamerun);
           //pnResult.Visible:= false;
       end;
    end;
  end;

end;

end.

