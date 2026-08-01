unit mnote_voice_command;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

type
  TMNoteVoiceCommand = class
  public
    class function TryParse(const ATranscript, AWakeWord: string;
      out ACommand: string): Boolean; static;
  end;

implementation

uses
  SysUtils, LazUTF8;

class function TMNoteVoiceCommand.TryParse(const ATranscript,
  AWakeWord: string; out ACommand: string): Boolean;
var
  Transcript, WakeWord: string;
begin
  ACommand := '';
  Transcript := Trim(ATranscript);
  WakeWord := Trim(AWakeWord);
  if WakeWord = '' then WakeWord := 'OK MNote';
  Result := UTF8Pos(UTF8LowerCase(WakeWord),
    UTF8LowerCase(Transcript)) = 1;
  if Result then
    ACommand := Trim(UTF8Copy(Transcript, UTF8Length(WakeWord) + 1, MaxInt));
end;

end.
