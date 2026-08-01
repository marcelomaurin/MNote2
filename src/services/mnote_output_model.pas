unit mnote_output_model;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TMNoteOutputChannel = (mocBuild, mocAI, mocSearch, mocDatabase,
    mocPython, mocAgent);
  TMNoteOutputChangedEvent = procedure(Sender: TObject;
    AChannel: TMNoteOutputChannel) of object;

  { TMNoteOutputModel }

  TMNoteOutputModel = class
  private
    FLines: array[TMNoteOutputChannel] of TStringList;
    FOnChanged: TMNoteOutputChangedEvent;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(AChannel: TMNoteOutputChannel; const AText: string);
    procedure SetText(AChannel: TMNoteOutputChannel; const AText: string);
    procedure Clear(AChannel: TMNoteOutputChannel);
    function TextOf(AChannel: TMNoteOutputChannel): string;
    function LinesOf(AChannel: TMNoteOutputChannel): TStrings;
    class function ChannelName(AChannel: TMNoteOutputChannel): string; static;
    property OnChanged: TMNoteOutputChangedEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TMNoteOutputModel.Create;
var
  Channel: TMNoteOutputChannel;
begin
  inherited Create;
  for Channel := Low(TMNoteOutputChannel) to High(TMNoteOutputChannel) do
    FLines[Channel] := TStringList.Create;
end;

destructor TMNoteOutputModel.Destroy;
var
  Channel: TMNoteOutputChannel;
begin
  for Channel := Low(TMNoteOutputChannel) to High(TMNoteOutputChannel) do
    FLines[Channel].Free;
  inherited Destroy;
end;

procedure TMNoteOutputModel.Add(AChannel: TMNoteOutputChannel;
  const AText: string);
var
  Value: string;
begin
  if AText = '' then Exit;
  Value := AText;
  if (FLines[AChannel].Count > 0) and
    (FLines[AChannel][FLines[AChannel].Count - 1] <> '') and
    (Value[1] <> #10) and (Value[1] <> #13) then
    FLines[AChannel][FLines[AChannel].Count - 1] :=
      FLines[AChannel][FLines[AChannel].Count - 1] + Value
  else
    FLines[AChannel].Text := FLines[AChannel].Text + Value;
  if Assigned(FOnChanged) then FOnChanged(Self, AChannel);
end;

procedure TMNoteOutputModel.SetText(AChannel: TMNoteOutputChannel;
  const AText: string);
begin
  FLines[AChannel].Text := AText;
  if Assigned(FOnChanged) then FOnChanged(Self, AChannel);
end;

procedure TMNoteOutputModel.Clear(AChannel: TMNoteOutputChannel);
begin
  FLines[AChannel].Clear;
  if Assigned(FOnChanged) then FOnChanged(Self, AChannel);
end;

function TMNoteOutputModel.TextOf(AChannel: TMNoteOutputChannel): string;
begin
  Result := FLines[AChannel].Text;
end;

function TMNoteOutputModel.LinesOf(AChannel: TMNoteOutputChannel): TStrings;
begin
  Result := FLines[AChannel];
end;

class function TMNoteOutputModel.ChannelName(
  AChannel: TMNoteOutputChannel): string;
begin
  case AChannel of
    mocBuild: Result := 'Build';
    mocAI: Result := 'AI';
    mocSearch: Result := 'Search';
    mocDatabase: Result := 'Database';
    mocPython: Result := 'Python';
  else
    Result := 'Agent';
  end;
end;

end.
