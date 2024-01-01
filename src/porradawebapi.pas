unit porradawebapi;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, lNetComponents, lNet, switches, MKnob, LedNumber, fphttpclient;

type

  { Tfrmporradawebapi }

  Tfrmporradawebapi = class(TForm)
    btSend: TButton;
    cbtype: TComboBox;
    edInline: TEdit;
    edPort: TEdit;
    edURL: TEdit;
    edMethod: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lnNumber: TLEDNumber;
    ledRespostas: TLEDNumber;
    ledRealizadas: TLEDNumber;
    ledFalhas: TLEDNumber;
    ledSucesso: TLEDNumber;
    melog: TMemo;
    meJSON: TMemo;
    meLastReceive: TMemo;
    mrequest: TmKnob;
    OnOffSwitch1: TOnOffSwitch;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    tsStatus: TTabSheet;
    tslog: TTabSheet;
    Timer1: TTimer;
    tssetup: TTabSheet;
    procedure btSendClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mrequestChange(Sender: TObject; AValue: Longint);
    procedure OnOffSwitch1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
      procedure SendData();
  public
     contador: integer;
     contsucesso: integer;
     conterro: integer;
     contrespostas: integer;
     contmedia : integer;

  end;

var
  frmporradawebapi: Tfrmporradawebapi;

implementation

{$R *.lfm}

{ Tfrmporradawebapi }


procedure Tfrmporradawebapi.Timer1Timer(Sender: TObject);
begin
  SendData();
end;

procedure Tfrmporradawebapi.FormCreate(Sender: TObject);
begin
end;

procedure Tfrmporradawebapi.btSendClick(Sender: TObject);
begin
  SendData();
end;



procedure Tfrmporradawebapi.SendData();
var
  strComando: String;
  httpResponse: String;
  lHTTP1: TFPHttpClient;
  lData: TStrings;
  comando : string;

begin
  inc(contmedia);
  inc(contador);

  try
      httpResponse := '';
      lHTTP1 := TFPHttpClient.Create(nil);
      lData := TStringList.Create;
      // Tentativa de conexão
      //LTCPComponent1.Connect(edURL.text, StrToInt(edPort.Text));
      lHTTP1.AllowRedirect := True;
      lData.Clear;
      lData.Add(meJSON.Text);

      comando := edURL.text + edMethod.text;


      //httpResponse := lHTTP1.FormPost(edURL.text, lData);
      //GET
      if(cbtype.ItemIndex= 0) then
      begin
        httpResponse:= lHTTP1.Get(comando);
      end;
      //Post
      if(cbtype.ItemIndex= 1) then
      begin
        httpResponse:= lHTTP1.FormPost(comando, lData);
      end;
      //PUT
      if(cbtype.ItemIndex= 2) then
      begin
        httpResponse:= lHTTP1.Put(comando);
      end;
      //Delete
      if(cbtype.ItemIndex= 3) then
      begin
        httpResponse:= lHTTP1.Delete(comando);
      end;

      if (httpResponse<> '') then
      begin
        melog.Lines.Append('Recebeu:'+timetostr(now)+':'+httpResponse);
        meLastReceive.Text:= httpResponse;
        inc(contrespostas);

        // Receber resposta
        // Nota: Implementar lógica de recebimento de resposta aqui
        inc(contsucesso);
      end;

    except
      on E: Exception do
      begin
        // Registrar o erro em um log
        inc(conterro);
      end;



  end;

  // Atualizar a interface do usuário
  ledRealizadas.Caption := IntToStr(contador);
  ledFalhas.Caption := IntToStr(conterro);
  ledRespostas.Caption := IntToStr(contrespostas);
  ledSucesso.Caption := IntToStr(contsucesso);
end;




procedure Tfrmporradawebapi.FormDestroy(Sender: TObject);
begin

end;

procedure Tfrmporradawebapi.mrequestChange(Sender: TObject; AValue: Longint);
begin
   lnNumber.Caption :=  inttostr(mrequest.Position);
end;

procedure Tfrmporradawebapi.OnOffSwitch1Change(Sender: TObject);
begin
  Timer1.Enabled :=  OnOffSwitch1.Checked;

end;

end.

