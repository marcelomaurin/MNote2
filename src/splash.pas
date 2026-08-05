unit splash;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TfrmSplash }

  TfrmSplash = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    lbversao: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    FStatusText: string;
    FProgress: Integer;
    FAnimationValue: Integer;
    procedure PaintBackground;
    procedure PaintContent;
  public
    procedure ShowAnimated;
    procedure CloseAnimated;
    procedure UpdateStatus(const AStatus: string; AProgress: Integer = -1);
  end;

var
  frmSplash: TfrmSplash;

implementation

{$R *.lfm}

function SplashColor(ARed, AGreen, ABlue: Byte): TColor;
begin
  Result := RGBToColor(ARed, AGreen, ABlue);
end;

procedure TfrmSplash.FormCreate(Sender: TObject);
var
  plat: string;
begin
  plat := '';
  {$IFDEF MSWINDOWS}
    plat := 'Windows ';
  {$ENDIF}
  {$IFDEF LINUX}
    plat := 'Linux ';
  {$ENDIF}
  {$IFDEF DARWIN}
    plat := 'macOS ';
  {$ENDIF}

  {$IFDEF CPU64}
    plat := plat + '64 bits';
  {$ELSE}
    plat := plat + '32 bits';
  {$ENDIF}

  if (lbversao <> nil) and ((lbversao.Caption = '') or (SameText(lbversao.Caption, 'lbversao'))) then
    lbversao.Caption := plat;
end;

procedure TfrmSplash.PaintBackground;
var
  Y, RedValue, GreenValue, BlueValue: Integer;
begin
  for Y := 0 to ClientHeight - 1 do
  begin
    RedValue := 10 + ((Y * 8) div ClientHeight);
    GreenValue := 15 + ((Y * 10) div ClientHeight);
    BlueValue := 31 + ((Y * 17) div ClientHeight);
    Canvas.Pen.Color := SplashColor(RedValue, GreenValue, BlueValue);
    Canvas.Line(0, Y, ClientWidth, Y);
  end;

  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Style := psClear;
  Canvas.Brush.Color := SplashColor(22, 35, 68);
  Canvas.Ellipse(ClientWidth - 190, -120, ClientWidth + 90, 160);
  Canvas.Brush.Color := SplashColor(18, 50, 76);
  Canvas.Ellipse(-130, ClientHeight - 130, 120, ClientHeight + 120);
end;

procedure TfrmSplash.PaintContent;
var
  CardRect: TRect;
  ProgressWidth: Integer;
  StatusText: string;
  ArchStr: string;
  ArchRect: TRect;
begin
  CardRect := Rect(28, 28, ClientWidth - 28, ClientHeight - 28);

  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Color := SplashColor(40, 55, 84);
  Canvas.Brush.Color := SplashColor(19, 27, 47);
  Canvas.RoundRect(CardRect.Left, CardRect.Top, CardRect.Right,
    CardRect.Bottom, 18, 18);

  Canvas.Pen.Style := psClear;
  Canvas.Brush.Color := SplashColor(70, 122, 255);
  Canvas.RoundRect(28, 28, 35, ClientHeight - 28, 7, 7);

  Canvas.Brush.Color := SplashColor(35, 52, 87);
  Canvas.RoundRect(64, 70, 146, 152, 18, 18);
  Canvas.Brush.Color := SplashColor(87, 139, 255);
  Canvas.RoundRect(72, 78, 138, 144, 14, 14);

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Name := 'Segoe UI';
  Canvas.Font.Color := clWhite;
  Canvas.Font.Height := -42;
  Canvas.Font.Style := [fsBold];
  Canvas.TextOut(84, 87, 'M');

  Canvas.Font.Height := -34;
  Canvas.Font.Style := [fsBold];
  Canvas.TextOut(172, 68, 'MNote2');

  // Desenhar Badge de Arquitetura (64 bits / 32 bits)
  {$IFDEF CPU64}
    ArchStr := '64 bits';
  {$ELSE}
    ArchStr := '32 bits';
  {$ENDIF}

  Canvas.Font.Height := -12;
  Canvas.Font.Style := [fsBold];
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := SplashColor(35, 75, 140);
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := SplashColor(87, 139, 255);
  ArchRect := Rect(ClientWidth - 120, 68, ClientWidth - 48, 92);
  Canvas.RoundRect(ArchRect.Left, ArchRect.Top, ArchRect.Right, ArchRect.Bottom, 10, 10);

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color := SplashColor(220, 235, 255);
  Canvas.TextRect(ArchRect, ArchRect.Left + ((ArchRect.Right - ArchRect.Left - Canvas.TextWidth(ArchStr)) div 2),
    ArchRect.Top + 4, ArchStr);

  Canvas.Font.Height := -16;
  Canvas.Font.Style := [];
  Canvas.Font.Color := SplashColor(155, 170, 201);
  Canvas.TextOut(174, 111, 'Ambiente inteligente de desenvolvimento');

  Canvas.Font.Height := -14;
  Canvas.Font.Color := SplashColor(108, 153, 255);
  Canvas.TextOut(174, 139, lbversao.Caption);

  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Color := SplashColor(42, 55, 78);
  Canvas.Line(64, 190, ClientWidth - 64, 190);

  StatusText := FStatusText;
  if StatusText = '' then
    StatusText := 'Preparando o MNote2...';
  Canvas.Font.Height := -15;
  Canvas.Font.Color := SplashColor(205, 214, 232);
  Canvas.TextOut(64, 218, StatusText);

  Canvas.Font.Height := -13;
  Canvas.Font.Color := SplashColor(112, 127, 157);
  Canvas.TextOut(64, 248, 'Maurinsoft  |  Open Source');

  Canvas.Pen.Style := psClear;
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := SplashColor(35, 46, 67);
  Canvas.RoundRect(64, ClientHeight - 68, ClientWidth - 64,
    ClientHeight - 62, 6, 6);
  ProgressWidth := ((ClientWidth - 128) * FProgress) div 100;
  if ProgressWidth > 0 then
  begin
    Canvas.Brush.Color := SplashColor(77, 132, 255);
    Canvas.RoundRect(64, ClientHeight - 68, 64 + ProgressWidth,
      ClientHeight - 62, 6, 6);
  end;
end;

procedure TfrmSplash.FormPaint(Sender: TObject);
begin
  PaintBackground;
  PaintContent;
end;

procedure TfrmSplash.ShowAnimated;
var
  StartedAt, Elapsed: QWord;
begin
  FStatusText := 'Preparando o MNote2...';
  FProgress := 12;
  FAnimationValue := 0;
  AlphaBlend := True;
  AlphaBlendValue := 0;
  Show;
  BringToFront;

  StartedAt := GetTickCount64;
  repeat
    Elapsed := GetTickCount64 - StartedAt;
    if Elapsed >= 260 then
      FAnimationValue := 255
    else
      FAnimationValue := (Elapsed * 255) div 260;
    AlphaBlendValue := FAnimationValue;
    Invalidate;
    Application.ProcessMessages;
    Sleep(10);
  until FAnimationValue >= 255;
  AlphaBlend := False;
end;

procedure TfrmSplash.CloseAnimated;
var
  StartedAt, Elapsed: QWord;
begin
  FProgress := 100;
  FStatusText := 'Tudo pronto.';
  AlphaBlend := True;
  AlphaBlendValue := 255;
  StartedAt := GetTickCount64;
  repeat
    Elapsed := GetTickCount64 - StartedAt;
    if Elapsed >= 170 then
      FAnimationValue := 0
    else
      FAnimationValue := 255 - ((Elapsed * 255) div 170);
    AlphaBlendValue := FAnimationValue;
    Invalidate;
    Application.ProcessMessages;
    Sleep(10);
  until FAnimationValue <= 0;
  Hide;
end;

procedure TfrmSplash.UpdateStatus(const AStatus: string; AProgress: Integer);
begin
  FStatusText := AStatus;
  if AProgress >= 0 then
  begin
    if AProgress > 100 then AProgress := 100;
    FProgress := AProgress;
  end;
  Invalidate;
  Application.ProcessMessages;
end;

end.

