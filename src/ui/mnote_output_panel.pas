unit mnote_output_panel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, ComCtrls, StdCtrls,
  mnote_output_model;

type
  { TMNoteOutputPanel }

  TMNoteOutputPanel = class(TComponent)
  private
    FModel: TMNoteOutputModel;
    FPages: TPageControl;
    FMemos: array[TMNoteOutputChannel] of TMemo;
    FClearButton: TButton;
    procedure ModelChanged(Sender: TObject; AChannel: TMNoteOutputChannel);
    procedure ClearClick(Sender: TObject);
    function ActiveChannel: TMNoteOutputChannel;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AParent: TWinControl; AExistingBuildMemo: TMemo);
    procedure Add(AChannel: TMNoteOutputChannel; const AText: string);
    procedure SetText(AChannel: TMNoteOutputChannel; const AText: string);
    procedure Clear(AChannel: TMNoteOutputChannel);
    procedure Select(AChannel: TMNoteOutputChannel);
    property Model: TMNoteOutputModel read FModel;
  end;

implementation

constructor TMNoteOutputPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FModel := TMNoteOutputModel.Create;
  FModel.OnChanged := @ModelChanged;
end;

destructor TMNoteOutputPanel.Destroy;
begin
  FModel.OnChanged := nil;
  FModel.Free;
  inherited Destroy;
end;

procedure TMNoteOutputPanel.Initialize(AParent: TWinControl;
  AExistingBuildMemo: TMemo);
var
  Toolbar: TPanel;
  Page: TTabSheet;
  Channel: TMNoteOutputChannel;
begin
  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := AParent;
  Toolbar.Align := alTop;
  Toolbar.BevelOuter := bvNone;
  Toolbar.Height := 32;

  FClearButton := TButton.Create(Self);
  FClearButton.Parent := Toolbar;
  FClearButton.Caption := 'Limpar canal';
  FClearButton.SetBounds(8, 4, 105, 24);
  FClearButton.OnClick := @ClearClick;

  FPages := TPageControl.Create(Self);
  FPages.Parent := AParent;
  FPages.Align := alClient;
  for Channel := Low(TMNoteOutputChannel) to High(TMNoteOutputChannel) do
  begin
    Page := TTabSheet.Create(Self);
    Page.PageControl := FPages;
    Page.Caption := TMNoteOutputModel.ChannelName(Channel);
    if (Channel = mocBuild) and (AExistingBuildMemo <> nil) then
      FMemos[Channel] := AExistingBuildMemo
    else
      FMemos[Channel] := TMemo.Create(Self);
    FMemos[Channel].Parent := Page;
    FMemos[Channel].Align := alClient;
    FMemos[Channel].ReadOnly := True;
    FMemos[Channel].ScrollBars := ssAutoBoth;
    FMemos[Channel].WordWrap := False;
    FMemos[Channel].Visible := True;
  end;
  FPages.ActivePageIndex := Ord(mocBuild);
end;

procedure TMNoteOutputPanel.ModelChanged(Sender: TObject;
  AChannel: TMNoteOutputChannel);
begin
  if FMemos[AChannel] <> nil then
  begin
    FMemos[AChannel].Lines.Assign(FModel.LinesOf(AChannel));
    FMemos[AChannel].SelStart := Length(FMemos[AChannel].Text);
  end;
end;

function TMNoteOutputPanel.ActiveChannel: TMNoteOutputChannel;
begin
  Result := mocBuild;
  if (FPages <> nil) and (FPages.ActivePageIndex >= Ord(Low(TMNoteOutputChannel)))
    and (FPages.ActivePageIndex <= Ord(High(TMNoteOutputChannel))) then
    Result := TMNoteOutputChannel(FPages.ActivePageIndex);
end;

procedure TMNoteOutputPanel.ClearClick(Sender: TObject);
begin
  Clear(ActiveChannel);
end;

procedure TMNoteOutputPanel.Add(AChannel: TMNoteOutputChannel;
  const AText: string);
begin
  FModel.Add(AChannel, AText);
end;

procedure TMNoteOutputPanel.SetText(AChannel: TMNoteOutputChannel;
  const AText: string);
begin
  FModel.SetText(AChannel, AText);
end;

procedure TMNoteOutputPanel.Clear(AChannel: TMNoteOutputChannel);
begin
  FModel.Clear(AChannel);
end;

procedure TMNoteOutputPanel.Select(AChannel: TMNoteOutputChannel);
begin
  if FPages <> nil then FPages.ActivePageIndex := Ord(AChannel);
end;

end.
