unit mnote_service_base;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TMNoteServiceErrorEvent = procedure(Sender: TObject;
    const AError: string) of object;

  { TMNoteServiceBase }

  TMNoteServiceBase = class
  private
    FLastError: string;
    FOnError: TMNoteServiceErrorEvent;
  protected
    procedure SetError(const AError: string);
  public
    procedure ClearError;
    property LastError: string read FLastError;
    property OnError: TMNoteServiceErrorEvent read FOnError write FOnError;
  end;

implementation

procedure TMNoteServiceBase.SetError(const AError: string);
begin
  FLastError := AError;
  if Assigned(FOnError) then
    FOnError(Self, FLastError);
end;

procedure TMNoteServiceBase.ClearError;
begin
  FLastError := '';
end;

end.
