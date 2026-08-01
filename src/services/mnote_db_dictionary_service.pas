unit mnote_db_dictionary_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, ZConnection, aidb_dictionary_base,
  aidb_postgresql_dictionary, aidb_sqlite_dictionary, aidb_types,
  mnote_service_base;

type
  TMNoteDBEngineStatus = (desUnavailable, desExperimental, desSupported);
  TMNoteDBProgressEvent = procedure(Sender: TObject; const AMessage: string;
    APosition, ATotal: Integer) of object;

  TMNoteDBDictionaryService = class(TMNoteServiceBase)
  private
    FDictionary: TAICustomDBDictionary;
    FConnection: TZConnection;
    FOnProgress: TMNoteDBProgressEvent;
    procedure DictionaryProgress(Sender: TObject; const AMessage: string;
      APosition, ATotal: Integer);
    procedure DictionaryError(Sender: TObject; const AMessage: string);
  public
    destructor Destroy; override;
    function AttachConnection(AConnection: TZConnection): Boolean;
    function TestConnection: Boolean;
    function Generate: Boolean;
    function AsJSON: string;
    function AsMarkdown: string;
    function AsText: string;
    function AsAIPrompt: string;
    procedure CollectSQLCompletions(AItems: TStrings);
    class function EngineStatus(const AProtocol: string): TMNoteDBEngineStatus; static;
    class function EngineStatusText(const AProtocol: string): string; static;
    property Dictionary: TAICustomDBDictionary read FDictionary;
    property Connection: TZConnection read FConnection;
    property OnProgress: TMNoteDBProgressEvent read FOnProgress write FOnProgress;
  end;

implementation

destructor TMNoteDBDictionaryService.Destroy;
begin
  FDictionary.Free;
  inherited Destroy;
end;

class function TMNoteDBDictionaryService.EngineStatus(
  const AProtocol: string): TMNoteDBEngineStatus;
var Protocol: string;
begin
  Protocol := LowerCase(AProtocol);
  if (Pos('postgres', Protocol) > 0) or (Pos('sqlite', Protocol) > 0) then
    Result := desSupported
  else if (Pos('mysql', Protocol) > 0) or (Pos('firebird', Protocol) > 0) or
    (Pos('oracle', Protocol) > 0) or (Pos('mssql', Protocol) > 0) then
    Result := desExperimental
  else Result := desUnavailable;
end;

class function TMNoteDBDictionaryService.EngineStatusText(
  const AProtocol: string): string;
begin
  case EngineStatus(AProtocol) of
    desSupported: Result := 'Suportado';
    desExperimental: Result := 'Experimental';
    else Result := 'Indisponível';
  end;
end;

function TMNoteDBDictionaryService.AttachConnection(
  AConnection: TZConnection): Boolean;
var Protocol: string;
begin
  ClearError;
  FreeAndNil(FDictionary);
  FConnection := AConnection;
  Result := False;
  if AConnection = nil then begin SetError('Conexão não informada.'); Exit; end;
  Protocol := LowerCase(AConnection.Protocol);
  if Pos('postgres', Protocol) > 0 then
    FDictionary := TAIPostgreSQLDictionary.Create(nil)
  else if Pos('sqlite', Protocol) > 0 then
    FDictionary := TAISQLiteDictionary.Create(nil)
  else
  begin SetError('Engine ' + AConnection.Protocol + ' está ' +
    LowerCase(EngineStatusText(AConnection.Protocol)) + '.'); Exit; end;
  FDictionary.Connection := AConnection;
  FDictionary.AutoConnect := False;
  FDictionary.OnProgress := @DictionaryProgress;
  FDictionary.OnError := @DictionaryError;
  Result := True;
end;

procedure TMNoteDBDictionaryService.DictionaryProgress(Sender: TObject;
  const AMessage: string; APosition, ATotal: Integer);
begin
  if Assigned(FOnProgress) then FOnProgress(Self, AMessage, APosition, ATotal);
end;

procedure TMNoteDBDictionaryService.DictionaryError(Sender: TObject;
  const AMessage: string);
begin
  SetError(AMessage);
end;

function TMNoteDBDictionaryService.TestConnection: Boolean;
begin
  Result := FDictionary <> nil;
  if not Result then begin SetError('Dicionário não selecionado.'); Exit; end;
  Result := FDictionary.TestConnection;
  if not Result then SetError(FDictionary.LastError);
end;

function TMNoteDBDictionaryService.Generate: Boolean;
begin
  ClearError;
  Result := FDictionary <> nil;
  if not Result then begin SetError('Dicionário não selecionado.'); Exit; end;
  Result := FDictionary.Generate;
  if not Result then SetError(FDictionary.LastError);
end;

function TMNoteDBDictionaryService.AsJSON: string;
begin if FDictionary <> nil then Result := FDictionary.AsJSON else Result := ''; end;
function TMNoteDBDictionaryService.AsMarkdown: string;
begin if FDictionary <> nil then Result := FDictionary.AsMarkdown else Result := ''; end;
function TMNoteDBDictionaryService.AsText: string;
begin if FDictionary <> nil then Result := FDictionary.AsText else Result := ''; end;
function TMNoteDBDictionaryService.AsAIPrompt: string;
begin if FDictionary <> nil then Result := FDictionary.AsAIPrompt else Result := ''; end;

procedure TMNoteDBDictionaryService.CollectSQLCompletions(AItems: TStrings);
var
  I, J: Integer;
  Table: TAIDBTableInfo;
begin
  if (FDictionary = nil) or (FDictionary.DataDictionary = nil) then Exit;
  for I := 0 to FDictionary.DataDictionary.Tables.Count - 1 do
  begin
    Table := FDictionary.DataDictionary.Tables[I];
    AItems.Add(Table.TableName + '|Tabela|Database');
    for J := 0 to Table.Columns.Count - 1 do
      AItems.Add(Table.TableName + '.' + Table.Columns[J].ColumnName +
        '|Coluna ' + Table.Columns[J].DataType + '|Database');
  end;
end;

end.
