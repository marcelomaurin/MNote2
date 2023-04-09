unit Item;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs, SynCompletion, ExtCtrls, SynEdit, SynHighlighterPas,
  SynHighlighterAny,SynHighlighterPo,SynHighlighterCpp,SynHighlighterSQL,SynHighlighterPython,
  SynHighlighterPHP,synhighlighterunixshellscript,SynHighlighterJava,SynHighlighterBat,
  SynHighlighterJScript,SynHighlighterCss, Graphics, SynEditKeyCmds, LCLType, mquery;

type
TTypeItem  = (ti_NODEFINE, ti_E , ti_H , ti_CCP, ti_PAS, ti_Reg, ti_BAT,
           ti_CFG , ti_TXT, ti_SQL,ti_PY, ti_PHP, ti_JAVA, ti_JS, ti_HTML, ti_CSS,
           ti_INO, ti_SHELL, ti_ALL);
TProjetoTipo = (pt_NODEFINE, pt_TEXT, pt_ProjetoRoot, pt_ProjetoSetup, pt_ProjetoSetupItem, pt_ProjetoFiles, pt_ProjetoDirFiles, pt_ProjetoFilesItem);
TTipoInfo = (Name, Path);

{ TItem }

TItem = class
      private
         FListaItem: TObjectList;
         FPalavrasReservadas : TStringList;
         FItemType : TTypeItem; (*Nao esta sendo usado p nada*)
         Fsyn : TSynEdit;
         FSynAutoComplete: TSynAutoComplete;
         Ftimer : TTimer;
         FSender: TObject;

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
         procedure ConfigureCppHighlighter(var ACppHighlighter: TSynCppSyn);
         procedure SynCompletion1CodeCompletion(var Value: string;
                     SourceValue: string; var SourceStart, SourceEnd: TPoint; KeyChar: TUTF8Char;
                     Shift: TShiftState);
         procedure SynCompletion1SearchPosition(var APosition: integer);
      public
         Name: String;
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
         //function classificaTipo(arquivo : string): TTypeItem;
         property ItemType : TTypeItem read FItemType write setItemType;
         property syn :TSynEdit read Fsyn write setSyn;
         property PalavrasReservadas : TStringlist read FPalavrasReservadas write FPalavrasReservadas;
         property SynAutoComplete: TSynAutoComplete read FSynAutoComplete write FSynAutoComplete;
end;

implementation


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

procedure TItem.AtribuiNovoNome();
begin
     default();

end;





procedure TItem.default();
begin

  Ftimer.Enabled := false;
  Ftimer.Interval:= 1000;
  Ftimer.OnTimer:= @TimerEvento;
  FPalavrasReservadas.clear;
  if (FSynCompletion = nil) then
     FSynCompletion := TSynCompletion.Create(TComponent(Fsender));
  FSynCompletion.Editor := Fsyn;
  FSynCompletion.OnCodeCompletion:=@SynCompletion1CodeCompletion;
  FSynCompletion.OnExecute:=@SynCompletion1Execute;
  FSynCompletion.OnSearchPosition:=@SynCompletion1SearchPosition;





  ItemType :=  ti_NODEFINE;
  ProjetoTipo := pt_NODEFINE;
  Name := 'Novo';
  DirName := '';
  FileName := '';
  FileExt := '';

  {#ifdef WINDOWS}
  VolName:= '';
  {#endif}
end;

procedure TItem.CheckTipoArquivo();
begin
   //item := TItem(pgMain.Pages[pgMain.ActivePageIndex].Tag);
   //syn := item.syn;
   //if (item.ItemType = ti_sql) then
  //posicao := pos('.pas',arquivo);
  if(FileExt ='.pas') then
  begin
    if (FSynPasSyn1 = nil) then
    begin
      FSynPasSyn1 := TSynPasSyn.Create(TComponent(FSender));
    end;
    Fsyn.Highlighter := FSynPasSyn1;
    FItemType := ti_PAS;
  end;
  if(FileExt ='.sh')  then
  begin
    if(FSynUNIXShellScriptSyn1 = nil) then
    begin
      FSynUNIXShellScriptSyn1 := TSynUNIXShellScriptSyn.create(TComponent(FSender));
    end;
    Fsyn.Highlighter := FSynUNIXShellScriptSyn1;
    FItemType := ti_SHELL;
  end;
  if(FileExt = '.php') then
  begin
    if(FSynPHPSyn1 = nil) then
    begin
      FSynPHPSyn1 := TSynPHPSyn.create(TComponent(FSender));
    end;

    Fsyn.Highlighter := FSynPHPSyn1;
    FItemType := ti_PHP;
  end;
  if(FileExt='.c') then
  begin
    if(FSynCppSyn1 = nil) then
    begin
      FSynCppSyn1 := TSynCppSyn.create(TComponent(FSender));
    end;
    Fsyn.Highlighter := FSynCppSyn1;
    FItemType := ti_CCP;
    ConfigureCppHighlighter(FSynCppSyn1);
  end;
  if(FileExt = '.cpp') then
  begin
    if(FSynCppSyn1 = nil) then
    begin
      FSynCppSyn1 := TSynCppSyn.create(TComponent(FSender));
    end;
    Fsyn.Highlighter := FSynCppSyn1;
    FItemType := ti_CCP;

    ConfigureCppHighlighter(FSynCppSyn1);
  end;
  if(FileExt ='.h') then
  begin
    if(FSynCppSyn1 = nil) then
    begin
      FSynCppSyn1 := TSynCppSyn.create(TComponent(FSender));
    end;
    Fsyn.Highlighter := FSynCppSyn1;
    FItemType := ti_CCP;
    ConfigureCppHighlighter(FSynCppSyn1);
  end;
  if(FileExt = '.sql') then
  begin
    if(FSynSQLSyn1 = nil) then
    begin
      FSynSQLSyn1 := TSynSQLSyn.create(TComponent(FSender));
    end;
    Fsyn.Highlighter := FSynSQLSyn1;
    FItemType := ti_SQL;
  end;
  if(FileExt = '.py') then
  begin
    if(FSynPythonSyn1 = nil) then
    begin
      FSynPythonSyn1 := TSynPythonSyn.create(TComponent(FSender));
    end;
    Fsyn.Highlighter := FSynPythonSyn1;
    FItemType := ti_PY;
  end;
  if(FileExt='.java') then
  begin
    if(FSynJavaSyn1 = nil) then
    begin
      FSynJavaSyn1 := TSynJavaSyn.create(TComponent(FSender));
    end;
    Fsyn.Highlighter := FSynJavaSyn1;
    FItemType := ti_JAVA;
  end;
  if(FileExt='.css') then
  begin
    if(FSynCssSyn1 = nil) then
    begin
      FSynCssSyn1 := TSynCssSyn.create(TComponent(FSender));
    end;
    Fsyn.Highlighter := FSynCssSyn1;
    FItemType := ti_CSS;
  end;
  if(FileExt='.js') then
  begin
    if(FSynJScriptSyn1 = nil) then
    begin
      FSynJScriptSyn1 := TSynJScriptSyn.create(TComponent(FSender));
    end;
    Fsyn.Highlighter := FSynJScriptSyn1;
    FItemType := ti_js;
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
  Ftimer := TTimer.create(TComponent(FSender);
  FPalavrasReservadas := TStringlist.create();
  FSynCompletion := TSynCompletion.create(TComponent(Fsender));
  FSynAutoComplete:= TSynAutoComplete.Create(FSynCompletion);

  FSynAutoComplete.ExecCommandID:= ecSynAutoCompletionExecute;

  default();
  Salvo := false;
end;

destructor TItem.destroy();
begin
  Ftimer.free;
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
       Name := ExtractFileName(Arquivo);
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
  resultado : string;
begin
  resultado := '';
  for a:= 0 to lst.Count-1 do
  begin
    if (pos(param,lst.Strings[a])>=0) then
    begin
       resultado := copy( lst.Strings[a], length(param),length(lst.Strings[a]));

    end;
  end;
  result := resultado;

end;

procedure TItem.Loadfile(arquivo: string);
begin
  AtribuiNome(arquivo);
  //FItemType := classificaTipo(arquivo);
  CheckTipoArquivo();

end;

end.

