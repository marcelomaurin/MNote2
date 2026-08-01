unit mnote_commands;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs;

type
  TMNoteCommandHandler = procedure(Sender: TObject) of object;

  { TMNoteCommand }

  TMNoteCommand = class
  private
    FID: string;
    FTitle: string;
    FCategory: string;
    FShortcut: Word;
    FEnabled: Boolean;
    FHandler: TMNoteCommandHandler;
  public
    constructor Create(const AID, ATitle, ACategory: string;
      AShortcut: Word; AHandler: TMNoteCommandHandler);
    function Execute(Sender: TObject): Boolean;
    property ID: string read FID;
    property Title: string read FTitle;
    property Category: string read FCategory;
    property Shortcut: Word read FShortcut write FShortcut;
    property Enabled: Boolean read FEnabled write FEnabled;
  end;

  { TMNoteCommandRegistry }

  TMNoteCommandRegistry = class
  private
    FCommands: TObjectList;
    function GetCount: Integer;
    function GetCommand(AIndex: Integer): TMNoteCommand;
  public
    constructor Create;
    destructor Destroy; override;
    function RegisterCommand(const AID, ATitle, ACategory: string;
      AShortcut: Word; AHandler: TMNoteCommandHandler): TMNoteCommand;
    function Find(const AID: string): TMNoteCommand;
    function Execute(const AID: string; Sender: TObject): Boolean;
    property Count: Integer read GetCount;
    property Commands[AIndex: Integer]: TMNoteCommand read GetCommand; default;
  end;

implementation

constructor TMNoteCommand.Create(const AID, ATitle, ACategory: string;
  AShortcut: Word; AHandler: TMNoteCommandHandler);
begin
  inherited Create;
  FID := AID;
  FTitle := ATitle;
  FCategory := ACategory;
  FShortcut := AShortcut;
  FHandler := AHandler;
  FEnabled := True;
end;

function TMNoteCommand.Execute(Sender: TObject): Boolean;
begin
  Result := FEnabled and Assigned(FHandler);
  if Result then
    FHandler(Sender);
end;

constructor TMNoteCommandRegistry.Create;
begin
  inherited Create;
  FCommands := TObjectList.Create(True);
end;

destructor TMNoteCommandRegistry.Destroy;
begin
  FCommands.Free;
  inherited Destroy;
end;

function TMNoteCommandRegistry.GetCount: Integer;
begin
  Result := FCommands.Count;
end;

function TMNoteCommandRegistry.GetCommand(AIndex: Integer): TMNoteCommand;
begin
  Result := TMNoteCommand(FCommands[AIndex]);
end;

function TMNoteCommandRegistry.RegisterCommand(const AID, ATitle,
  ACategory: string; AShortcut: Word;
  AHandler: TMNoteCommandHandler): TMNoteCommand;
begin
  if Trim(AID) = '' then
    raise Exception.Create('O ID do comando não pode ser vazio.');
  if Find(AID) <> nil then
    raise Exception.CreateFmt('Comando duplicado: %s', [AID]);
  Result := TMNoteCommand.Create(AID, ATitle, ACategory, AShortcut, AHandler);
  FCommands.Add(Result);
end;

function TMNoteCommandRegistry.Find(const AID: string): TMNoteCommand;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FCommands.Count - 1 do
    if SameText(TMNoteCommand(FCommands[I]).ID, AID) then
      Exit(TMNoteCommand(FCommands[I]));
end;

function TMNoteCommandRegistry.Execute(const AID: string;
  Sender: TObject): Boolean;
var
  Command: TMNoteCommand;
begin
  Command := Find(AID);
  Result := (Command <> nil) and Command.Execute(Sender);
end;

end.
