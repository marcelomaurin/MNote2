unit mnote_visual_identity;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Controls, Graphics, ImgList, Menus, StdCtrls, ComCtrls,
  ExtCtrls;

const
  MNOTE_ICON_CLOSE = 0;
  MNOTE_ICON_CODE = 1;
  MNOTE_ICON_SAVE = 2;
  MNOTE_ICON_OPEN = 3;
  MNOTE_ICON_NEW = 4;
  MNOTE_ICON_FILE = 5;
  MNOTE_ICON_SEARCH = 6;
  MNOTE_ICON_SETTINGS = 7;
  MNOTE_ICON_DATABASE = 8;
  MNOTE_ICON_FONT = 9;
  MNOTE_ICON_LAYOUT = 10;
  MNOTE_ICON_TOOLS = 11;
  MNOTE_ICON_AI = 12;
  MNOTE_ICON_SERVER = 13;
  MNOTE_ICON_LANGUAGE = 14;
  MNOTE_ICON_SQL = 15;
  MNOTE_ICON_SOLUTION = 16;
  MNOTE_ICON_TASKS = 17;
  MNOTE_ICON_PROPERTIES = 18;
  MNOTE_ICON_CHANGES = 19;
  MNOTE_ICON_MONITOR = 20;
  MNOTE_ICON_LAB = 21;
  MNOTE_ICON_OUTPUT = 22;
  MNOTE_ICON_PROBLEM = 23;
  MNOTE_ICON_TERMINAL = 24;
  MNOTE_ICON_REFRESH = 25;
  MNOTE_ICON_EXPORT = 26;
  MNOTE_ICON_RUN = 27;
  MNOTE_ICON_STOP = 28;
  MNOTE_ICON_CLEAR = 29;
  MNOTE_ICON_VOICE = 30;
  MNOTE_ICON_INFO = 31;
  MNOTE_ICON_NAVIGATE = 32;
  MNOTE_ICON_VIEW = 33;
  MNOTE_ICON_THEME = 34;
  MNOTE_ICON_EDIT = 35;
  MNOTE_ICON_COPY = 36;
  MNOTE_ICON_PASTE = 37;
  MNOTE_ICON_CUT = 38;
  MNOTE_ICON_UNDO = 39;
  MNOTE_ICON_REDO = 40;
  MNOTE_ICON_PYTHON = 41;
  MNOTE_ICON_DEBUG = 42;
  MNOTE_ICON_INSTALL = 43;

procedure MNoteBuildProfessionalIcons(AImages: TImageList);
procedure MNoteApplyMenuIcons(AMenu: TMenu);
procedure MNoteApplyVisualIdentity(AParent: TWinControl);
function MNoteIconForCaption(const ACaption: string): Integer;
function MNoteDecoratedButtonCaption(const ACaption: string): string;

implementation

function BrandBlue: TColor;
begin
  Result := RGBToColor(66, 120, 246);
end;

function BrandCyan: TColor;
begin
  Result := RGBToColor(55, 190, 220);
end;

function BrandGreen: TColor;
begin
  Result := RGBToColor(56, 178, 120);
end;

function BrandAmber: TColor;
begin
  Result := RGBToColor(235, 167, 62);
end;

procedure Line(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer);
begin
  ACanvas.MoveTo(X1, Y1);
  ACanvas.LineTo(X2, Y2);
end;

procedure DrawIcon(ABitmap: TBitmap; AIndex: Integer);
const
  MaskColor = clFuchsia;
var
  C: TCanvas;
  MainColor, DetailColor: TColor;
begin
  ABitmap.SetSize(24, 24);
  ABitmap.Transparent := True;
  ABitmap.TransparentColor := MaskColor;
  C := ABitmap.Canvas;
  C.Brush.Color := MaskColor;
  C.FillRect(0, 0, 24, 24);
  C.Pen.Style := psSolid;
  C.Pen.Width := 2;
  C.Pen.Color := BrandBlue;
  C.Brush.Style := bsClear;
  MainColor := BrandBlue;
  DetailColor := BrandCyan;

  case AIndex of
    MNOTE_ICON_CLOSE:
      begin
        C.Pen.Color := RGBToColor(210, 78, 86);
        Line(C, 6, 6, 18, 18); Line(C, 18, 6, 6, 18);
      end;
    MNOTE_ICON_CODE:
      begin
        Line(C, 9, 6, 4, 12); Line(C, 4, 12, 9, 18);
        Line(C, 15, 6, 20, 12); Line(C, 20, 12, 15, 18);
        C.Pen.Color := DetailColor; Line(C, 14, 4, 10, 20);
      end;
    MNOTE_ICON_SAVE:
      begin
        C.Brush.Style := bsSolid; C.Brush.Color := MainColor;
        C.Rectangle(5, 4, 19, 20);
        C.Brush.Color := clWhite; C.FillRect(8, 5, 16, 10);
        C.FillRect(8, 14, 16, 19);
      end;
    MNOTE_ICON_OPEN:
      begin
        C.Brush.Style := bsSolid; C.Brush.Color := RGBToColor(245, 185, 65);
        C.Pen.Color := RGBToColor(214, 145, 35);
        C.Polygon([Point(3, 8), Point(10, 8), Point(12, 11),
          Point(21, 11), Point(18, 20), Point(4, 20)]);
        C.Brush.Style := bsClear; Line(C, 4, 8, 4, 5); Line(C, 4, 5, 11, 5);
      end;
    MNOTE_ICON_NEW, MNOTE_ICON_FILE:
      begin
        C.Brush.Style := bsSolid; C.Brush.Color := RGBToColor(235, 241, 255);
        C.Polygon([Point(6, 3), Point(15, 3), Point(20, 8),
          Point(20, 21), Point(6, 21)]);
        C.Brush.Style := bsClear; Line(C, 15, 3, 15, 8); Line(C, 15, 8, 20, 8);
        if AIndex = MNOTE_ICON_NEW then
        begin
          C.Pen.Color := BrandGreen; Line(C, 9, 14, 17, 14);
          Line(C, 13, 10, 13, 18);
        end;
      end;
    MNOTE_ICON_SEARCH:
      begin
        C.Ellipse(4, 4, 15, 15); Line(C, 14, 14, 21, 21);
      end;
    MNOTE_ICON_SETTINGS:
      begin
        C.Ellipse(6, 6, 18, 18); C.Ellipse(10, 10, 14, 14);
        Line(C, 12, 2, 12, 6); Line(C, 12, 18, 12, 22);
        Line(C, 2, 12, 6, 12); Line(C, 18, 12, 22, 12);
        Line(C, 5, 5, 8, 8); Line(C, 16, 16, 19, 19);
        Line(C, 19, 5, 16, 8); Line(C, 8, 16, 5, 19);
      end;
    MNOTE_ICON_DATABASE, MNOTE_ICON_SQL, MNOTE_ICON_SERVER:
      begin
        C.Brush.Style := bsSolid; C.Brush.Color := RGBToColor(226, 235, 255);
        C.Ellipse(4, 4, 20, 10); C.Rectangle(4, 7, 20, 18);
        C.Ellipse(4, 14, 20, 21); C.Brush.Style := bsClear;
        C.Arc(4, 8, 20, 15, 0, 180 * 16);
        if AIndex = MNOTE_ICON_SERVER then
        begin
          C.Pen.Color := BrandGreen; C.Brush.Style := bsSolid;
          C.Brush.Color := BrandGreen; C.Ellipse(16, 15, 20, 19);
        end;
      end;
    MNOTE_ICON_FONT:
      begin
        C.Font.Name := 'Segoe UI'; C.Font.Size := 14; C.Font.Style := [fsBold];
        C.Font.Color := MainColor; C.TextOut(5, 1, 'A');
      end;
    MNOTE_ICON_LAYOUT:
      begin
        C.Rectangle(3, 4, 21, 20); Line(C, 9, 4, 9, 20);
        Line(C, 9, 10, 21, 10);
      end;
    MNOTE_ICON_TOOLS:
      begin
        Line(C, 5, 4, 19, 20); C.Ellipse(3, 2, 8, 7);
        C.Pen.Color := DetailColor; Line(C, 19, 4, 5, 20);
        C.Ellipse(17, 2, 22, 7);
      end;
    MNOTE_ICON_AI:
      begin
        C.Pen.Color := RGBToColor(117, 92, 230); C.Brush.Style := bsSolid;
        C.Brush.Color := RGBToColor(117, 92, 230);
        C.Polygon([Point(12, 2), Point(14, 9), Point(21, 12),
          Point(14, 15), Point(12, 22), Point(10, 15), Point(3, 12),
          Point(10, 9)]);
        C.Brush.Color := clWhite; C.Ellipse(10, 10, 14, 14);
      end;
    MNOTE_ICON_LANGUAGE:
      begin
        C.Ellipse(3, 3, 21, 21); Line(C, 3, 12, 21, 12);
        C.Arc(8, 3, 16, 21, 90 * 16, 180 * 16);
        C.Arc(8, 3, 16, 21, 270 * 16, 180 * 16);
      end;
    MNOTE_ICON_SOLUTION:
      begin
        C.Rectangle(3, 3, 10, 10); C.Rectangle(14, 3, 21, 10);
        C.Rectangle(8, 15, 16, 22); Line(C, 7, 10, 12, 15);
        Line(C, 17, 10, 12, 15);
      end;
    MNOTE_ICON_TASKS:
      begin
        C.Rectangle(5, 3, 20, 21); C.Pen.Color := BrandGreen;
        Line(C, 8, 9, 10, 11); Line(C, 10, 11, 14, 6);
        Line(C, 8, 16, 10, 18); Line(C, 10, 18, 14, 13);
      end;
    MNOTE_ICON_PROPERTIES:
      begin
        Line(C, 4, 6, 20, 6); Line(C, 4, 12, 20, 12);
        Line(C, 4, 18, 20, 18); C.Brush.Style := bsSolid;
        C.Brush.Color := DetailColor; C.Ellipse(7, 3, 12, 9);
        C.Ellipse(14, 9, 19, 15); C.Ellipse(5, 15, 10, 21);
      end;
    MNOTE_ICON_CHANGES:
      begin
        Line(C, 4, 8, 18, 8); Line(C, 18, 8, 14, 4);
        Line(C, 20, 16, 6, 16); Line(C, 6, 16, 10, 20);
      end;
    MNOTE_ICON_MONITOR:
      begin
        C.Rectangle(3, 4, 21, 18); C.Pen.Color := BrandGreen;
        Line(C, 5, 12, 9, 12); Line(C, 9, 12, 11, 7);
        Line(C, 11, 7, 14, 16); Line(C, 14, 16, 17, 10); Line(C, 17, 10, 20, 10);
        C.Pen.Color := MainColor; Line(C, 9, 21, 15, 21); Line(C, 12, 18, 12, 21);
      end;
    MNOTE_ICON_LAB:
      begin
        Line(C, 9, 3, 15, 3); Line(C, 11, 3, 11, 10);
        Line(C, 13, 3, 13, 10); C.Brush.Style := bsSolid;
        C.Brush.Color := RGBToColor(192, 235, 247);
        C.Polygon([Point(11, 10), Point(5, 20), Point(19, 20), Point(13, 10)]);
      end;
    MNOTE_ICON_OUTPUT, MNOTE_ICON_TERMINAL:
      begin
        C.Rectangle(3, 4, 21, 20); Line(C, 6, 8, 10, 12);
        Line(C, 10, 12, 6, 16); C.Pen.Color := DetailColor;
        Line(C, 12, 16, 18, 16);
      end;
    MNOTE_ICON_PROBLEM:
      begin
        C.Pen.Color := BrandAmber; C.Brush.Style := bsSolid;
        C.Brush.Color := RGBToColor(255, 239, 194);
        C.Polygon([Point(12, 3), Point(22, 21), Point(2, 21)]);
        C.Pen.Color := BrandAmber; Line(C, 12, 8, 12, 15);
        C.Ellipse(11, 17, 13, 19);
      end;
    MNOTE_ICON_REFRESH:
      begin
        C.Arc(4, 4, 20, 20, 35 * 16, 285 * 16);
        Line(C, 17, 4, 20, 8); Line(C, 20, 8, 15, 8);
      end;
    MNOTE_ICON_EXPORT:
      begin
        C.Rectangle(4, 10, 17, 21); Line(C, 12, 3, 12, 15);
        Line(C, 12, 3, 8, 7); Line(C, 12, 3, 16, 7);
      end;
    MNOTE_ICON_RUN:
      begin
        C.Brush.Style := bsSolid; C.Brush.Color := BrandGreen;
        C.Pen.Color := BrandGreen;
        C.Polygon([Point(7, 4), Point(20, 12), Point(7, 20)]);
      end;
    MNOTE_ICON_STOP:
      begin
        C.Brush.Style := bsSolid; C.Brush.Color := RGBToColor(210, 78, 86);
        C.Pen.Color := C.Brush.Color; C.Rectangle(6, 6, 19, 19);
      end;
    MNOTE_ICON_CLEAR:
      begin
        C.Pen.Color := RGBToColor(210, 78, 86);
        Line(C, 6, 7, 18, 19); Line(C, 18, 7, 6, 19);
        C.Pen.Color := MainColor; Line(C, 5, 4, 19, 4);
      end;
    MNOTE_ICON_VOICE:
      begin
        C.Rectangle(8, 3, 16, 14); C.Arc(5, 8, 19, 19, 180 * 16, 180 * 16);
        Line(C, 12, 19, 12, 22); Line(C, 8, 22, 16, 22);
      end;
    MNOTE_ICON_INFO:
      begin
        C.Ellipse(3, 3, 21, 21);
        C.Brush.Style := bsSolid;
        C.Brush.Color := MainColor;
        C.Ellipse(11, 6, 13, 8);
        Line(C, 12, 10, 12, 17);
        Line(C, 10, 10, 12, 10);
        Line(C, 10, 17, 14, 17);
      end;
    MNOTE_ICON_NAVIGATE:
      begin
        C.Ellipse(3, 3, 21, 21);
        C.Brush.Style := bsSolid;
        C.Brush.Color := RGBToColor(220, 50, 50);
        C.Pen.Color := C.Brush.Color;
        C.Polygon([Point(12, 6), Point(15, 12), Point(12, 11), Point(9, 12)]);
        C.Brush.Color := RGBToColor(160, 160, 160);
        C.Pen.Color := C.Brush.Color;
        C.Polygon([Point(12, 18), Point(15, 12), Point(12, 13), Point(9, 12)]);
      end;
    MNOTE_ICON_VIEW:
      begin
        C.Pen.Color := MainColor;
        C.Arc(3, 4, 21, 20, 20 * 16, 140 * 16);
        C.Arc(3, 4, 21, 20, 200 * 16, 140 * 16);
        C.Brush.Style := bsSolid;
        C.Brush.Color := DetailColor;
        C.Ellipse(9, 9, 15, 15);
        C.Brush.Color := clBlack;
        C.Ellipse(11, 11, 13, 13);
      end;
    MNOTE_ICON_THEME:
      begin
        C.Brush.Style := bsSolid;
        C.Brush.Color := RGBToColor(245, 235, 220);
        C.Pen.Color := RGBToColor(180, 140, 80);
        C.Ellipse(3, 4, 21, 20);
        C.Brush.Color := RGBToColor(225, 60, 60);
        C.Pen.Color := C.Brush.Color;
        C.Ellipse(6, 7, 9, 10);
        C.Brush.Color := BrandBlue;
        C.Pen.Color := C.Brush.Color;
        C.Ellipse(11, 6, 14, 9);
        C.Brush.Color := BrandGreen;
        C.Pen.Color := C.Brush.Color;
        C.Ellipse(15, 8, 18, 11);
        C.Brush.Color := BrandAmber;
        C.Pen.Color := C.Brush.Color;
        C.Ellipse(15, 13, 18, 16);
        C.Brush.Color := MaskColor;
        C.Pen.Color := RGBToColor(180, 140, 80);
        C.Ellipse(7, 13, 10, 16);
      end;
    MNOTE_ICON_EDIT:
      begin
        C.Pen.Color := BrandAmber;
        C.Brush.Style := bsSolid;
        C.Brush.Color := RGBToColor(255, 215, 100);
        C.Polygon([Point(6, 18), Point(15, 5), Point(18, 8), Point(9, 21)]);
        C.Brush.Color := RGBToColor(80, 80, 80);
        C.Pen.Color := C.Brush.Color;
        C.Polygon([Point(6, 18), Point(3, 21), Point(9, 21)]);
        C.Brush.Color := RGBToColor(220, 100, 120);
        C.Pen.Color := C.Brush.Color;
        C.Polygon([Point(15, 5), Point(17, 3), Point(20, 6), Point(18, 8)]);
      end;
    MNOTE_ICON_COPY:
      begin
        C.Pen.Color := DetailColor;
        C.Brush.Style := bsClear;
        C.Rectangle(4, 3, 15, 16);
        C.Pen.Color := MainColor;
        C.Brush.Style := bsSolid;
        C.Brush.Color := clWhite;
        C.Rectangle(8, 7, 19, 21);
        C.Pen.Color := DetailColor;
        Line(C, 11, 10, 16, 10);
        Line(C, 11, 13, 16, 13);
        Line(C, 11, 16, 15, 16);
      end;
    MNOTE_ICON_PASTE:
      begin
        C.Brush.Style := bsSolid;
        C.Brush.Color := RGBToColor(210, 175, 120);
        C.Pen.Color := RGBToColor(160, 120, 70);
        C.Rectangle(5, 5, 19, 21);
        C.Brush.Color := clWhite;
        C.Pen.Color := MainColor;
        C.Rectangle(7, 8, 17, 19);
        C.Brush.Color := RGBToColor(150, 160, 175);
        C.Pen.Color := RGBToColor(100, 110, 125);
        C.Rectangle(9, 3, 15, 7);
      end;
    MNOTE_ICON_CUT:
      begin
        C.Pen.Color := RGBToColor(100, 110, 130);
        Line(C, 6, 6, 18, 18);
        Line(C, 18, 6, 6, 18);
        C.Brush.Style := bsSolid;
        C.Brush.Color := RGBToColor(60, 60, 60);
        C.Ellipse(11, 11, 13, 13);
        C.Brush.Style := bsClear;
        C.Pen.Color := BrandBlue;
        C.Ellipse(3, 4, 8, 9);
        C.Ellipse(3, 15, 8, 20);
      end;
    MNOTE_ICON_UNDO:
      begin
        C.Pen.Color := BrandBlue;
        C.Arc(7, 7, 19, 19, 30 * 16, 210 * 16);
        Line(C, 7, 13, 4, 10);
        Line(C, 7, 13, 10, 10);
      end;
    MNOTE_ICON_REDO:
      begin
        C.Pen.Color := BrandBlue;
        C.Arc(5, 7, 17, 19, 300 * 16, 210 * 16);
        Line(C, 17, 13, 20, 10);
        Line(C, 17, 13, 14, 10);
      end;
    MNOTE_ICON_PYTHON:
      begin
        C.Brush.Style := bsSolid;
        C.Brush.Color := RGBToColor(55, 110, 180);
        C.Pen.Color := C.Brush.Color;
        C.Polygon([Point(6, 4), Point(14, 4), Point(14, 9), Point(9, 9), Point(9, 12), Point(6, 12)]);
        C.Brush.Color := clWhite;
        C.Ellipse(8, 6, 10, 8);
        C.Brush.Color := RGBToColor(245, 195, 45);
        C.Pen.Color := C.Brush.Color;
        C.Polygon([Point(18, 20), Point(10, 20), Point(10, 15), Point(15, 15), Point(15, 12), Point(18, 12)]);
        C.Brush.Color := clWhite;
        C.Ellipse(14, 16, 16, 18);
      end;
    MNOTE_ICON_DEBUG:
      begin
        C.Brush.Style := bsSolid;
        C.Brush.Color := RGBToColor(80, 170, 80);
        C.Pen.Color := C.Brush.Color;
        C.Ellipse(10, 4, 14, 8);
        C.Brush.Style := bsClear;
        C.Pen.Color := RGBToColor(70, 140, 70);
        Line(C, 10, 4, 7, 2);
        Line(C, 14, 4, 17, 2);
        C.Brush.Style := bsSolid;
        C.Brush.Color := RGBToColor(90, 185, 90);
        C.Pen.Color := RGBToColor(50, 130, 50);
        C.Ellipse(8, 7, 16, 18);
        Line(C, 5, 9, 9, 10);
        Line(C, 15, 10, 19, 9);
        Line(C, 4, 13, 8, 13);
        Line(C, 16, 13, 20, 13);
        Line(C, 5, 17, 9, 16);
        Line(C, 15, 16, 19, 17);
      end;
    MNOTE_ICON_INSTALL:
      begin
        C.Pen.Color := MainColor;
        C.Rectangle(4, 9, 20, 21);
        C.Pen.Color := BrandGreen;
        Line(C, 12, 3, 12, 14);
        Line(C, 12, 14, 8, 10);
        Line(C, 12, 14, 16, 10);
      end;
  end;
end;

procedure MNoteBuildProfessionalIcons(AImages: TImageList);
var
  Bitmap: TBitmap;
  I: Integer;
begin
  if AImages = nil then Exit;
  AImages.Clear;
  AImages.Width := 24;
  AImages.Height := 24;
  Bitmap := TBitmap.Create;
  try
    for I := MNOTE_ICON_CLOSE to MNOTE_ICON_INSTALL do
    begin
      DrawIcon(Bitmap, I);
      AImages.AddMasked(Bitmap, clFuchsia);
    end;
  finally
    Bitmap.Free;
  end;
end;

function MNoteIconForCaption(const ACaption: string): Integer;
var
  Text: string;
begin
  Text := LowerCase(StringReplace(ACaption, '&', '', [rfReplaceAll]));
  Text := Trim(Text);
  Result := -1;
  if Text = '' then Exit;

  // Specific edit actions
  if (Text = 'undo') or (Text = 'desfazer') then Result := MNOTE_ICON_UNDO
  else if (Text = 'redo') or (Text = 'refazer') then Result := MNOTE_ICON_REDO
  else if (Text = 'cut') or (Pos('recort', Text) > 0) or (Text = 'cortar') then Result := MNOTE_ICON_CUT
  else if (Pos('copy', Text) > 0) or (Pos('copiar', Text) > 0) then Result := MNOTE_ICON_COPY
  else if (Pos('paste', Text) > 0) or (Pos('colar', Text) > 0) then Result := MNOTE_ICON_PASTE
  else if (Pos('select', Text) > 0) or (Pos('selecion', Text) > 0) then Result := MNOTE_ICON_EDIT
  else if (Text = 'edit') or (Text = 'editar') then Result := MNOTE_ICON_EDIT

  // Python and development tools
  else if Pos('python', Text) > 0 then Result := MNOTE_ICON_PYTHON
  else if (Pos('debug', Text) > 0) or (Pos('depurar', Text) > 0) then Result := MNOTE_ICON_DEBUG
  else if (Pos('install', Text) > 0) or (Pos('instalar', Text) > 0) then Result := MNOTE_ICON_INSTALL
  else if (Pos('clean', Text) > 0) or (Pos('limpar', Text) > 0) or
    (Pos('clear', Text) > 0) or (Pos('rejeitar', Text) > 0) then Result := MNOTE_ICON_CLEAR

  // Navigation, Search & References
  else if (Pos('defin', Text) > 0) or (Pos('goto', Text) > 0) or
    (Pos('naveg', Text) > 0) or (Pos('navig', Text) > 0) then Result := MNOTE_ICON_NAVIGATE
  else if (Pos('search', Text) > 0) or (Pos('find', Text) > 0) or
    (Pos('pesq', Text) > 0) or (Pos('localiz', Text) > 0) or
    (Pos('refer', Text) > 0) then Result := MNOTE_ICON_SEARCH

  // General actions
  else if (Pos('close', Text) > 0) or (Pos('fechar', Text) > 0) or
    (Pos('exit', Text) > 0) or (Pos('sair', Text) > 0) then Result := MNOTE_ICON_CLOSE
  else if (Pos('voice', Text) > 0) or (Pos('falar', Text) > 0) or
    (Pos('ouvir', Text) > 0) then Result := MNOTE_ICON_VOICE
  else if (Pos('save', Text) > 0) or (Pos('salvar', Text) > 0) then Result := MNOTE_ICON_SAVE
  else if (Pos('new', Text) > 0) or (Pos('novo', Text) > 0) or
    (Pos('nova', Text) > 0) then Result := MNOTE_ICON_NEW
  else if (Pos('open', Text) > 0) or (Pos('load', Text) > 0) or
    (Pos('abrir', Text) > 0) or (Pos('folder', Text) > 0) or
    (Pos('pasta', Text) > 0) then Result := MNOTE_ICON_OPEN
  else if (Pos('config', Text) > 0) or (Pos('setup', Text) > 0) then Result := MNOTE_ICON_SETTINGS
  else if (Pos('database', Text) > 0) or (Pos('mquery', Text) > 0) then Result := MNOTE_ICON_DATABASE
  else if Pos('sql', Text) > 0 then Result := MNOTE_ICON_SQL
  else if Pos('font', Text) > 0 then Result := MNOTE_ICON_FONT
  else if (Pos('language', Text) > 0) or (Pos('idioma', Text) > 0) or
    (Text = 'portuguese') or (Text = 'english') or (Text = 'spanish') then Result := MNOTE_ICON_LANGUAGE
  else if (Pos('project', Text) > 0) or (Pos('solution', Text) > 0) or
    (Pos('projeto', Text) > 0) then Result := MNOTE_ICON_SOLUTION
  else if Pos('task', Text) > 0 then Result := MNOTE_ICON_TASKS
  else if Pos('propert', Text) > 0 then Result := MNOTE_ICON_PROPERTIES
  else if (Pos('change', Text) > 0) or (Pos('replace', Text) > 0) or
    (Pos('substitu', Text) > 0) then Result := MNOTE_ICON_CHANGES
  else if Pos('monitor', Text) > 0 then Result := MNOTE_ICON_MONITOR
  else if (Pos('lab', Text) > 0) or (Pos('json', Text) > 0) then Result := MNOTE_ICON_LAB
  else if Pos('problem', Text) > 0 then Result := MNOTE_ICON_PROBLEM
  else if (Pos('terminal', Text) > 0) or (Pos('console', Text) > 0) then Result := MNOTE_ICON_TERMINAL
  else if Pos('output', Text) > 0 then Result := MNOTE_ICON_OUTPUT
  else if (Pos('run', Text) > 0) or (Pos('execut', Text) > 0) or
    (Pos('compil', Text) > 0) then Result := MNOTE_ICON_RUN
  else if (Pos('stop', Text) > 0) or (Pos('parar', Text) > 0) then Result := MNOTE_ICON_STOP
  else if Pos('export', Text) > 0 then Result := MNOTE_ICON_EXPORT
  else if (Pos('atualizar', Text) > 0) or (Pos('refresh', Text) > 0) or
    (Pos('reset', Text) > 0) then Result := MNOTE_ICON_REFRESH
  else if (Pos('view', Text) > 0) or (Pos('exibir', Text) > 0) or
    (Pos('visualiz', Text) > 0) or (Pos('logview', Text) > 0) then Result := MNOTE_ICON_VIEW
  else if (Pos('theme', Text) > 0) or (Pos('tema', Text) > 0) or
    (Text = 'light') or (Text = 'dark') or (Text = 'blue') then Result := MNOTE_ICON_THEME
  else if (Pos('about', Text) > 0) or (Pos('sobre', Text) > 0) or
    (Pos('info', Text) > 0) then Result := MNOTE_ICON_INFO
  else if (Text = 'ia') or (Text = 'ai') or (Pos(' ia', Text) > 0) or
    (Pos('ia ', Text) = 1) or (Pos(' ai', Text) > 0) or
    (Pos('ai ', Text) = 1) or (Pos('chatgpt', Text) > 0) or
    (Pos('suger', Text) > 0) or (Pos('propor', Text) > 0) then Result := MNOTE_ICON_AI
  else if (Pos('script', Text) > 0) or (Pos('code', Text) > 0) or
    (Pos('dos2unix', Text) > 0) or (Text = 'type') or (Text = 'tipo') or
    (Text = 'none') or (Pos('pascal', Text) > 0) or (Pos('c/c++', Text) > 0) or
    (Text = 'php') or (Text = 'java') then Result := MNOTE_ICON_CODE
  else if (Pos('stress', Text) > 0) or (Pos('server', Text) > 0) or
    (Pos('porrada', Text) > 0) then Result := MNOTE_ICON_SERVER
  else if Pos('tool', Text) > 0 then Result := MNOTE_ICON_TOOLS
  else if (Pos('window', Text) > 0) or (Pos('janela', Text) > 0) or
    (Text = 'fix') or (Text = 'on top') or (Text = 'desktop center') or
    (Text = 'hide') then Result := MNOTE_ICON_LAYOUT
  else if (Pos('file', Text) > 0) or (Pos('arquivo', Text) > 0) then Result := MNOTE_ICON_FILE;
end;

procedure ApplyMenuItemIcons(AItem: TMenuItem);
var
  I, IconIndex: Integer;
begin
  if AItem = nil then Exit;
  if AItem.Caption <> '-' then
  begin
    IconIndex := MNoteIconForCaption(AItem.Caption);
    if IconIndex >= 0 then AItem.ImageIndex := IconIndex;
  end;
  for I := 0 to AItem.Count - 1 do ApplyMenuItemIcons(AItem.Items[I]);
end;

procedure MNoteApplyMenuIcons(AMenu: TMenu);
var
  I: Integer;
begin
  if AMenu = nil then Exit;
  for I := 0 to AMenu.Items.Count - 1 do ApplyMenuItemIcons(AMenu.Items[I]);
end;

function ButtonPrefix(const ACaption: string): string;
var
  IconIndex: Integer;
begin
  IconIndex := MNoteIconForCaption(ACaption);
  case IconIndex of
    MNOTE_ICON_CLOSE, MNOTE_ICON_CLEAR: Result := '× ';
    MNOTE_ICON_SAVE: Result := '✓ ';
    MNOTE_ICON_OPEN: Result := '↗ ';
    MNOTE_ICON_NEW: Result := '+ ';
    MNOTE_ICON_SEARCH: Result := '⌕ ';
    MNOTE_ICON_SETTINGS: Result := '⚙ ';
    MNOTE_ICON_AI: Result := '✦ ';
    MNOTE_ICON_RUN: Result := '▶ ';
    MNOTE_ICON_STOP: Result := '■ ';
    MNOTE_ICON_REFRESH: Result := '↻ ';
    MNOTE_ICON_EXPORT: Result := '⇱ ';
    MNOTE_ICON_CHANGES: Result := '⇄ ';
    MNOTE_ICON_TASKS: Result := '☑ ';
    MNOTE_ICON_DATABASE, MNOTE_ICON_SQL: Result := '▤ ';
    MNOTE_ICON_VOICE: Result := '♪ ';
    MNOTE_ICON_PROPERTIES: Result := '≡ ';
    MNOTE_ICON_INFO: Result := 'ℹ ';
    MNOTE_ICON_NAVIGATE: Result := '🧭 ';
    MNOTE_ICON_VIEW: Result := '👁 ';
    MNOTE_ICON_THEME: Result := '🎨 ';
    MNOTE_ICON_EDIT: Result := '✎ ';
    MNOTE_ICON_COPY, MNOTE_ICON_PASTE: Result := '📋 ';
    MNOTE_ICON_CUT: Result := '✂ ';
    MNOTE_ICON_UNDO: Result := '↺ ';
    MNOTE_ICON_REDO: Result := '↻ ';
    MNOTE_ICON_PYTHON: Result := '🐍 ';
    MNOTE_ICON_DEBUG: Result := '🪲 ';
    MNOTE_ICON_INSTALL: Result := '📦 ';
  else
    Result := '';
  end;
end;

function MNoteDecoratedButtonCaption(const ACaption: string): string;
var
  Prefix: string;
begin
  Prefix := ButtonPrefix(ACaption);
  if (Prefix <> '') and (Pos(Prefix, ACaption) <> 1) then
    Result := Prefix + ACaption
  else
    Result := ACaption;
end;

procedure StyleControls(AParent: TWinControl);
var
  I: Integer;
  Control: TControl;
  Prefix: string;
begin
  for I := 0 to AParent.ControlCount - 1 do
  begin
    Control := AParent.Controls[I];
    if Control is TButton then
    begin
      TButton(Control).Font.Name := 'Segoe UI';
      TButton(Control).Font.Size := 9;
      Prefix := ButtonPrefix(TButton(Control).Caption);
      if Prefix <> '' then
        TButton(Control).Caption :=
          MNoteDecoratedButtonCaption(TButton(Control).Caption);
      if TButton(Control).Height < 27 then TButton(Control).Height := 27;
    end
    else if Control is TPageControl then
    begin
      TPageControl(Control).Font.Name := 'Segoe UI';
      TPageControl(Control).Font.Size := 9;
    end
    else if Control is TTreeView then
    begin
      TTreeView(Control).Font.Name := 'Segoe UI';
      TTreeView(Control).Indent := 20;
      TTreeView(Control).RowSelect := True;
    end
    else if Control is TListView then
    begin
      TListView(Control).Font.Name := 'Segoe UI';
      TListView(Control).RowSelect := True;
    end;
    if Control is TWinControl then StyleControls(TWinControl(Control));
  end;
end;

procedure MNoteApplyVisualIdentity(AParent: TWinControl);
begin
  if AParent = nil then Exit;
  StyleControls(AParent);
end;

end.
