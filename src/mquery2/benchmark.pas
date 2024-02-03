unit benchmark;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Grids, SynEdit, GifAnim, mquery2;

type

  { TfrmBenchmark }

  TfrmBenchmark = class(TForm)
    btIniciar: TButton;
    btIniciar1: TButton;
    Label3: TLabel;
    lbOperacao: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    PageControl1: TPageControl;
    edRelatorio: TSynEdit;
    pbTestes: TProgressBar;
    pbPercentual: TProgressBar;
    tsRelatorio: TTabSheet;
    tsOperacoes: TTabSheet;
    procedure btIniciarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    sistema : string;
    tempoinicio : TDatetime;
    tempofim : TDatetime;
    procedure Teste01();
    procedure myTeste01();
    function  ConectarBanco(): boolean;
    function  ConectarBancoMy(): boolean;
    procedure CriaTabelaTeste01();
    procedure CriaTabelaMyTeste01();
    procedure ApagaTabelaTeste01();
    procedure ApagaTabelaMyTeste01();
    procedure GravacaoTeste01(volume: integer);
    procedure GravacaoMyTeste01(volume: integer);
    procedure LeituraTeste01(volume: integer);
    procedure LeituraMyTeste01(volume: integer);
    procedure LeituraTeste02(volume: integer);
    procedure LeituraMyTeste02(volume: integer);
  end;

var
  frmBenchmark: TfrmBenchmark;

implementation

{$R *.lfm}

uses main;

{ TfrmBenchmark }

procedure TfrmBenchmark.FormCreate(Sender: TObject);
begin
  {$IFDEF WINDOWS}
  SISTEMA := 'WINDOWS';
  {$ENDIF}
  {$IFDEF LINUX}
  SISTEMA := 'LINUX';
  {$ENDIF}


end;


procedure TfrmBenchmark.Teste01();
var
  tempointermediario1 : Tdatetime;
  tempointermediario2 : Tdatetime;
  volume : integer;
begin
   lbOperacao.Caption:= 'Teste 01';
   volume := 10000;
   tempoinicio:= now();
   if ConectarBanco() then
   begin
      CriaTabelaTeste01();
      tempointermediario1:= now();
      GravacaoTeste01(volume);
      tempointermediario2:=now();
      edRelatorio.Append('Tempo decorrido para teste de gravação de '+ inttostr(volume)+ ' registros '+ timetostr(tempointermediario2-tempointermediario1) );

      tempointermediario1:= now();
      LeituraTeste01(volume);
      tempointermediario2:=now();
      edRelatorio.Append('Tempo decorrido para teste de leitura1 de '+ inttostr(volume)+ ' registros '+ timetostr(tempointermediario2-tempointermediario1) );

      tempointermediario1:= now();
      LeituraTeste02(volume);
      tempointermediario2:=now();
      edRelatorio.Append('Tempo decorrido para teste de leitura2 de '+ inttostr(volume)+ ' registros '+ timetostr(tempointermediario2-tempointermediario1) );


      ApagaTabelaTeste01();
   end;
   Tempofim:= now;
   edRelatorio.Append('Tempo decorrido do teste:'+timetostr(TempoFim-TempoInicio));
end;

procedure TfrmBenchmark.myTeste01();
var
  tempointermediario1 : Tdatetime;
  tempointermediario2 : Tdatetime;
  volume : integer;
begin
   lbOperacao.Caption:= 'Teste My 01';
   volume := 10000;
   tempoinicio:= now();
   if ConectarBancoMy() then
   begin
      CriaTabelaMyTeste01();
      tempointermediario1:= now();
      GravacaoMyTeste01(volume);
      tempointermediario2:=now();
      edRelatorio.Append('Tempo decorrido para teste Mysql de gravação de '+ inttostr(volume)+ ' registros '+ timetostr(tempointermediario2-tempointermediario1) );

      tempointermediario1:= now();
      LeituraMyTeste01(volume);
      tempointermediario2:=now();
      edRelatorio.Append('Tempo decorrido para teste Mysql de leitura1 de '+ inttostr(volume)+ ' registros '+ timetostr(tempointermediario2-tempointermediario1) );

      tempointermediario1:= now();
      LeituraMyTeste02(volume);
      tempointermediario2:=now();
      edRelatorio.Append('Tempo decorrido para teste Mysql de leitura2 de '+ inttostr(volume)+ ' registros '+ timetostr(tempointermediario2-tempointermediario1) );


      ApagaTabelaMyTeste01();
   end;
   Tempofim:= now;
   edRelatorio.Append('Tempo decorrido do teste Mysql :'+timetostr(TempoFim-TempoInicio));
end;


function TfrmBenchmark.ConectarBancoMy(): boolean;
var
  tempointermediario1 : Tdatetime;
  tempointermediario2 : Tdatetime;
begin
   tempointermediario1:=now();
   if not(frmmquery2.zconmysql.Connected) then
   begin

      frmmquery2.btConectarMyClick(self); (*Conectando no banco*)
      tempointermediario2:=now();
      edRelatorio.Append('Tempo para abertura de banco Mysql com leitura de todas as estruturas '+ timetostr(tempointermediario2-tempointermediario1));
      edRelatorio.Append('Banco Mysql conectado com sucesso!');
   end;
   if not frmmquery2.zconmysql.Connected then
   begin
      edRelatorio.Append('Falha ao tentar conectar no banco de dados');
      result := false;
   end
   else
   begin
     result := true;
   end;

end;

function TfrmBenchmark.ConectarBanco(): boolean;
var
  tempointermediario1 : Tdatetime;
  tempointermediario2 : Tdatetime;
begin
   tempointermediario1:=now();
   if not(frmmquery2.zconpost.Connected) then
   begin

      frmmquery2.refreshPost(); (*Conectando no banco*)
      tempointermediario2:=now();
      edRelatorio.Append('Tempo para abertura de banco com leitura de todas as estruturas '+ timetostr(tempointermediario2-tempointermediario1));
      edRelatorio.Append('Banco postgres conectado com sucesso!');
   end;
   if not frmmquery2.zconpost.Connected then
   begin
      edRelatorio.Append('Falha ao tentar conectar no banco de dados');
      result := false;
   end
   else
   begin
     result := true;
   end;

end;

procedure TfrmBenchmark.CriaTabelaTeste01();
begin
  frmmquery2.zpostqry1.SQL.text := 'create table tmp_teste01 '+
    '('+
    ' indice integer primary key, '+
    ' descricao varchar(30) '+
    ')';
  frmmquery2.zpostqry1.ExecSQL;

end;

procedure TfrmBenchmark.CriaTabelaMyTeste01();
begin
  frmmquery2.zmyqry1.SQL.text := 'create table tmp_teste01 '+
    '('+
    ' indice int primary key, '+
    ' descricao varchar(30) '+
    ')';
  frmmquery2.zmyqry1.ExecSQL;

end;


procedure TfrmBenchmark.ApagaTabelaTeste01();
begin
  frmmquery2.zpostqry1.SQL.text := 'drop table tmp_teste01; ';
  frmmquery2.zpostqry1.ExecSQL;
end;

procedure TfrmBenchmark.ApagaTabelaMyTeste01();
begin
  frmmquery2.zmyqry1.SQL.text := 'drop table tmp_teste01; ';
  frmmquery2.zmyqry1.ExecSQL;
end;


procedure TfrmBenchmark.LeituraTeste01(volume: integer);
var
  a : integer;
begin
  pbPercentual.Max:=volume;

  for a := 1 to volume do
  begin
    Application.ProcessMessages;
    frmmquery2.zpostqry1.SQL.text := 'select * from tmp_teste01 '+
      ' where '+
      ' indice =  '+inttostr(a)+';';
    frmmquery2.zpostqry1.open;
    pbPercentual.Position:=a;
  end;
end;

procedure TfrmBenchmark.LeituraMyTeste01(volume: integer);
var
  a : integer;
begin
  pbPercentual.Max:=volume;

  for a := 1 to volume do
  begin
    Application.ProcessMessages;
    frmmquery2.zmyqry1.SQL.text := 'select * from tmp_teste01 '+
      ' where '+
      ' indice =  '+inttostr(a)+';';
    frmmquery2.zmyqry1.open;
    pbPercentual.Position:=a;
  end;
end;


procedure TfrmBenchmark.LeituraTeste02(volume: integer);
var
  a : integer;
begin
  pbPercentual.Max:=volume;

  for a := 1 to volume do
  begin
    Application.ProcessMessages;
    frmmquery2.zpostqry1.SQL.text := 'select * from tmp_teste01 '+
      ' where '+
      ' descricao =  '+#39+'Teste'+inttostr(a)+#39+';';
    frmmquery2.zpostqry1.open;
    pbPercentual.Position:=a;
  end;
end;

procedure TfrmBenchmark.LeituraMyTeste02(volume: integer);
var
  a : integer;
begin
  pbPercentual.Max:=volume;

  for a := 1 to volume do
  begin
    Application.ProcessMessages;
    frmmquery2.zmyqry1.SQL.text := 'select * from tmp_teste01 '+
      ' where '+
      ' descricao =  '+#39+'Teste'+inttostr(a)+#39+';';
    frmmquery2.zmyqry1.open;
    pbPercentual.Position:=a;
  end;
end;


procedure TfrmBenchmark.GravacaoTeste01(volume: integer);
var
  a : integer;
begin
  pbPercentual.Max:=volume;

  for a := 1 to volume do
  begin
    Application.ProcessMessages;
    frmmquery2.zpostqry1.SQL.text := 'insert into tmp_teste01 '+
      '('+
      ' indice, '+
      ' descricao'+
      ' ) values ( '+
        inttostr(a)+','+
        #39+'Teste'+inttostr(a)+#39+
      ');';
    frmmquery2.zpostqry1.ExecSQL;
    pbPercentual.Position:=a;
  end;
end;

procedure TfrmBenchmark.GravacaoMyTeste01(volume: integer);
var
  a : integer;
begin
  pbPercentual.Max:=volume;

  for a := 1 to volume do
  begin
    Application.ProcessMessages;
    frmmquery2.zmyqry1.SQL.text := 'insert into tmp_teste01 '+
      '('+
      ' indice, '+
      ' descricao'+
      ' ) values ( '+
        inttostr(a)+','+
        #39+'Teste'+inttostr(a)+#39+
      ');';
    frmmquery2.zmyqry1.ExecSQL;
    pbPercentual.Position:=a;
  end;
end;

procedure TfrmBenchmark.btIniciarClick(Sender: TObject);
begin
  pbTestes.Max:=4;

  pbTestes.Min:=0;
  pbTestes.Position:=0;
  edRelatorio.Clear; (*Limpa relatorio*)
  edRelatorio.Append('Relatorio de Benchmark');
  edRelatorio.Append('======================');
  edRelatorio.Append('Sistema Operacional '+ SISTEMA);
  edRelatorio.Append(' ');
  lbOperacao.Caption:= 'Carregando Estrutura do Banco Postgres';
  Application.ProcessMessages;

  if ConectarBanco() then
  begin
     pbTestes.Position := pbTestes.Position+ 1;
     lbOperacao.Caption:= 'Realizando Teste 1';
     Application.ProcessMessages;
     Teste01();
     pbTestes.Position := pbTestes.Position+ 1;
  end;
  lbOperacao.Caption:= 'Carregando Estrutura do Banco Mysql';
  Application.ProcessMessages;

  if ConectarBancoMy() then
  begin
     pbTestes.Position := pbTestes.Position+ 1;
     lbOperacao.Caption:= 'Realizando Teste 1 do Mysql';
     Application.ProcessMessages;
     MyTeste01();
     pbTestes.Position := pbTestes.Position+ 1;
     Application.ProcessMessages;
  end;


  (*Fim de teste*)

  Application.ProcessMessages;
  Showmessage('Analise realizada com sucesso!');

end;

end.

