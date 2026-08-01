unit mnote_language_toolbar;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, StdCtrls, Contnrs,
  mnote_commands, mnote_language_profile, mnote_visual_identity;

type
  { TMNoteLanguageToolbar }

  TMNoteLanguageToolbar = class(TComponent)
  private
    FPanel: TPanel;
    FLanguageLabel: TLabel;
    FButtons: TObjectList;
    FRegistry: TMNoteCommandRegistry;
    FProfileID: string;
    procedure CommandButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AParent: TPanel; ARegistry: TMNoteCommandRegistry);
    procedure SetProfile(AProfile: TMNoteLanguageProfile);
    property ProfileID: string read FProfileID;
  end;

implementation

constructor TMNoteLanguageToolbar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButtons := TObjectList.Create(False);
end;

destructor TMNoteLanguageToolbar.Destroy;
begin
  FButtons.Free;
  inherited Destroy;
end;

procedure TMNoteLanguageToolbar.Initialize(AParent: TPanel;
  ARegistry: TMNoteCommandRegistry);
begin
  FRegistry := ARegistry;
  FPanel := TPanel.Create(Self);
  FPanel.Name := 'pnIDELanguageCommands';
  FPanel.Parent := AParent;
  FPanel.Align := alLeft;
  FPanel.Width := 620;
  FPanel.BevelOuter := bvNone;

  FLanguageLabel := TLabel.Create(Self);
  FLanguageLabel.Parent := FPanel;
  FLanguageLabel.SetBounds(8, 17, 78, 20);
  FLanguageLabel.Caption := 'Text';
end;

procedure TMNoteLanguageToolbar.SetProfile(AProfile: TMNoteLanguageProfile);
var
  I, LeftPosition: Integer;
  Button: TButton;
  Command: TMNoteCommand;
  CommandID, ButtonCaption: string;
begin
  if AProfile = nil then Exit;
  if SameText(FProfileID, AProfile.ID) then Exit;
  for I := FButtons.Count - 1 downto 0 do
    TObject(FButtons[I]).Free;
  FButtons.Clear;
  FProfileID := AProfile.ID;
  FLanguageLabel.Caption := AProfile.Name;
  LeftPosition := 90;
  for I := 0 to AProfile.Commands.Count - 1 do
  begin
    CommandID := AProfile.Commands[I];
    Command := FRegistry.Find(CommandID);
    if Command <> nil then
      ButtonCaption := Command.Title
    else
      ButtonCaption := Copy(CommandID, Pos('.', CommandID) + 1, MaxInt);
    Button := TButton.Create(Self);
    Button.Parent := FPanel;
    Button.SetBounds(LeftPosition, 10, 96, 30);
    Button.Caption := MNoteDecoratedButtonCaption(ButtonCaption);
    Button.Font.Name := 'Segoe UI';
    Button.Hint := CommandID;
    Button.ShowHint := True;
    Button.Enabled := (Command <> nil) and Command.Enabled;
    Button.Tag := I;
    Button.OnClick := @CommandButtonClick;
    FButtons.Add(Button);
    Inc(LeftPosition, 100);
    if LeftPosition > FPanel.Width - 90 then Break;
  end;
end;

procedure TMNoteLanguageToolbar.CommandButtonClick(Sender: TObject);
var
  CommandID: string;
begin
  if not (Sender is TButton) then Exit;
  CommandID := TButton(Sender).Hint;
  FRegistry.Execute(CommandID, Sender);
end;

end.
