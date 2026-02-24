unit ChangeSource;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  SynEdit, SynEditTypes; // SynEditTypes para TSynStatusChanges

type

  { TfrmChangeSource }

  TfrmChangeSource = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Splitter1: TSplitter;
    synOld: TSynEdit;
    synNew: TSynEdit;
    ToggleBox1: TToggleBox; // Sugestão: "Diferencas (Novo)"
    ToggleBox2: TToggleBox; // Sugestão: "Diferencas (Velho)"
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure synChange(Sender: TObject);
  private
    FSyncScroll: Boolean;
    FOldChanged: TList; // lista de linhas alteradas no velho
    FNewChanged: TList; // lista de linhas alteradas no novo

    procedure DoStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure DoSpecialLineColors(Sender: TObject; Line: integer;
                                  var Special: boolean; var FG, BG: TColor);

    procedure BuildDiff;
    function  LineIsChanged(ALine: Integer; AList: TList): Boolean;
  public
    // carrega os textos, calcula diff e mostra a tela
    function Executar(var Novo, Velho: WideString): Boolean;
  end;

// Função externa para usar na aplicação
function ConfirmaOperacao(var Novo, Velho: WideString): Boolean;

var
  frmChangeSource: TfrmChangeSource;

implementation

{$R *.lfm}

{ Função externa }

function ConfirmaOperacao(var Novo, Velho: WideString): Boolean;
begin
  Result := False;
  frmChangeSource := TfrmChangeSource.Create(nil);
  try
    Result := frmChangeSource.Executar(Novo, Velho);
  finally
    frmChangeSource.Free;
  end;
end;

{ TfrmChangeSource }

procedure TfrmChangeSource.FormCreate(Sender: TObject);
begin
  FSyncScroll  := False;
  FOldChanged  := TList.Create;
  FNewChanged  := TList.Create;

  // Scroll sincronizado via OnStatusChange
  synOld.OnStatusChange := @DoStatusChange;
  synNew.OnStatusChange := @DoStatusChange;

  // Cores especiais por linha (diferenças)
  synOld.OnSpecialLineColors := @DoSpecialLineColors;
  synNew.OnSpecialLineColors := @DoSpecialLineColors;

  // Recalcular diff quando texto mudar
  synOld.OnChange := @synChange;
  synNew.OnChange := @synChange;
end;

procedure TfrmChangeSource.FormDestroy(Sender: TObject);
begin
  FOldChanged.Free;
  FNewChanged.Free;
end;

procedure TfrmChangeSource.synChange(Sender: TObject);
begin
  BuildDiff;
end;

procedure TfrmChangeSource.DoStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
var
  Src, Dst: TSynEdit;
begin
  // Evita loop de sincronização
  if FSyncScroll then Exit;

  if not ((scTopLineChanged in Changes) or (scLeftCharChanged in Changes)) then
    Exit;

  if Sender = synOld then
  begin
    Src := synOld;
    Dst := synNew;
  end
  else if Sender = synNew then
  begin
    Src := synNew;
    Dst := synOld;
  end
  else
    Exit;

  FSyncScroll := True;
  try
    // Sincroniza rolagem vertical
    if scTopLineChanged in Changes then
      Dst.TopLine := Src.TopLine;
    // Sincroniza rolagem horizontal
    if scLeftCharChanged in Changes then
      Dst.LeftChar := Src.LeftChar;
  finally
    FSyncScroll := False;
  end;
end;

procedure TfrmChangeSource.DoSpecialLineColors(Sender: TObject; Line: integer;
  var Special: boolean; var FG, BG: TColor);
var
  List: TList;
begin
  // Decide qual lista usar (velho ou novo)
  if Sender = synOld then
  begin
    if not ToggleBox2.Checked then Exit; // só marca se estiver ligado
    List := FOldChanged;
  end
  else if Sender = synNew then
  begin
    if not ToggleBox1.Checked then Exit; // só marca se estiver ligado
    List := FNewChanged;
  end
  else
    Exit;

  if LineIsChanged(Line, List) then
  begin
    Special := True;
    // Cor de fundo para destacar diferenças (ajuste como quiser)
    BG := clMoneyGreen;
    // FG permanece o padrão, a menos que queira mudar
  end;
end;

function TfrmChangeSource.LineIsChanged(ALine: Integer; AList: TList): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to AList.Count - 1 do
    if PtrInt(AList[i]) = ALine then
    begin
      Result := True;
      Exit;
    end;
end;

procedure TfrmChangeSource.BuildDiff;
var
  OldSL, NewSL: TStringList;
  i, MaxLines: Integer;
begin
  FOldChanged.Clear;
  FNewChanged.Clear;

  OldSL := TStringList.Create;
  NewSL := TStringList.Create;
  try
    OldSL.Text := synOld.Text;
    NewSL.Text := synNew.Text;

    if OldSL.Count > NewSL.Count then
      MaxLines := OldSL.Count
    else
      MaxLines := NewSL.Count;

    for i := 0 to MaxLines - 1 do
    begin
      // Linha existe em um e não no outro -> diferença
      if (i >= OldSL.Count) or (i >= NewSL.Count) then
      begin
        if i < OldSL.Count then
          FOldChanged.Add(Pointer(PtrInt(i + 1)));
        if i < NewSL.Count then
          FNewChanged.Add(Pointer(PtrInt(i + 1)));
      end
      else
      // Conteúdo diferente -> diferença
      if OldSL[i] <> NewSL[i] then
      begin
        FOldChanged.Add(Pointer(PtrInt(i + 1)));
        FNewChanged.Add(Pointer(PtrInt(i + 1)));
      end;
    end;
  finally
    OldSL.Free;
    NewSL.Free;
  end;

  // Redesenha para aplicar as cores
  synOld.Invalidate;
  synNew.Invalidate;
end;

function TfrmChangeSource.Executar(var Novo, Velho: WideString): Boolean;
begin
  // Carrega os textos
  synOld.Text := Velho;
  synNew.Text := Novo;

  // Ativa marcação de diferenças por padrão
  ToggleBox1.Checked := True; // novo
  ToggleBox2.Checked := True; // velho

  BuildDiff;

  // Mostra como modal; precisa ter botões com ModalResult = mrOk/mrCancel no form
  Result := (ShowModal = mrOk);

  if Result then
  begin
    // Se usuário confirmou, devolve textos possivelmente modificados
    Velho := synOld.Text;
    Novo  := synNew.Text;
  end;
end;

end.

