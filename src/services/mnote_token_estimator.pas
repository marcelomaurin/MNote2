unit mnote_token_estimator;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

type
  TMNoteTokenEstimate = record
    UTF8Characters: Integer;
    Words: Integer;
    EstimatedTokens: Integer;
    SafetyMargin: Integer;
    TotalWithMargin: Integer;
    ContextLimit: Integer;
    Method: string;
    Confidence: string;
    ExceedsLimit: Boolean;
  end;

  TMNoteTokenEstimator = class
  private
    FCharactersPerToken: Double;
    FPortugueseCharactersPerToken: Double;
    FCodeCharactersPerToken: Double;
    FSafetyPercent: Integer;
  public
    constructor Create;
    function Estimate(const AText: string;
      AContextLimit: Integer): TMNoteTokenEstimate;
    function EstimateLanguage(const AText, ALanguage: string;
      AContextLimit: Integer): TMNoteTokenEstimate;
    function TruncateAtLine(const AText: string; ATokenLimit: Integer;
      out AOmittedLines: Integer): string;
    procedure Calibrate(ACharacters, AActualTokens: Integer);
    procedure CalibrateLanguage(ACharacters, AActualTokens: Integer;
      const ALanguage: string);
    procedure SetLanguageCoefficient(const ALanguage: string;
      ACharactersPerToken: Double);
    property CharactersPerToken: Double read FCharactersPerToken;
    property PortugueseCharactersPerToken: Double
      read FPortugueseCharactersPerToken;
    property CodeCharactersPerToken: Double read FCodeCharactersPerToken;
    property SafetyPercent: Integer read FSafetyPercent write FSafetyPercent;
  end;

implementation

uses
  Classes, SysUtils, Math, LazUTF8;

constructor TMNoteTokenEstimator.Create;
begin
  inherited Create;
  FCharactersPerToken := 4.0;
  FPortugueseCharactersPerToken := 3.5;
  FCodeCharactersPerToken := 3.2;
  FSafetyPercent := 15;
end;

function CountWords(const AText: string): Integer;
var
  I: Integer;
  InWord: Boolean;
begin
  Result := 0;
  InWord := False;
  for I := 1 to Length(AText) do
    if AText[I] in [#1..#32, ',', '.', ';', ':', '(', ')', '[', ']',
      '{', '}', '"', ''''] then
      InWord := False
    else if not InWord then
    begin
      Inc(Result);
      InWord := True;
    end;
end;

function TMNoteTokenEstimator.Estimate(const AText: string;
  AContextLimit: Integer): TMNoteTokenEstimate;
begin
  Result := EstimateLanguage(AText, 'auto', AContextLimit);
end;

function TMNoteTokenEstimator.EstimateLanguage(const AText,
  ALanguage: string; AContextLimit: Integer): TMNoteTokenEstimate;
var
  CharacterCount: Integer;
  Coefficient: Double;
begin
  CharacterCount := UTF8Length(AText);
  Coefficient := FCharactersPerToken;
  if SameText(ALanguage, 'code') or SameText(ALanguage, 'pascal') or
    SameText(ALanguage, 'sql') then Coefficient := FCodeCharactersPerToken
  else if SameText(ALanguage, 'portuguese') or SameText(ALanguage, 'pt') then
    Coefficient := FPortugueseCharactersPerToken;
  Result.UTF8Characters := CharacterCount;
  Result.Words := CountWords(AText);
  Result.EstimatedTokens := Ceil(CharacterCount / Coefficient);
  Result.SafetyMargin := Ceil(Result.EstimatedTokens * FSafetyPercent / 100);
  Result.TotalWithMargin := Result.EstimatedTokens + Result.SafetyMargin;
  Result.ContextLimit := AContextLimit;
  Result.Method := Format('estimativa por caracteres UTF-8 (%.2f caracteres/token)',
    [Coefficient]);
  Result.Confidence := 'heurística conservadora; não é contagem exata';
  Result.ExceedsLimit := (AContextLimit > 0) and
    (Result.TotalWithMargin > AContextLimit);
end;

function TMNoteTokenEstimator.TruncateAtLine(const AText: string;
  ATokenLimit: Integer; out AOmittedLines: Integer): string;
var
  Lines, Accepted: TStringList;
  I: Integer;
  Candidate: string;
  EstimateValue: TMNoteTokenEstimate;
begin
  AOmittedLines := 0;
  Lines := TStringList.Create;
  Accepted := TStringList.Create;
  try
    Lines.Text := StringReplace(AText, #13#10, #10, [rfReplaceAll]);
    for I := 0 to Lines.Count - 1 do
    begin
      Candidate := Accepted.Text + Lines[I] + LineEnding;
      EstimateValue := Estimate(Candidate, ATokenLimit);
      if EstimateValue.TotalWithMargin > ATokenLimit then Break;
      Accepted.Add(Lines[I]);
    end;
    AOmittedLines := Lines.Count - Accepted.Count;
    Result := Accepted.Text;
    if AOmittedLines > 0 then
      Result := Result + Format('[... %d linhas omitidas por limite de contexto ...]',
        [AOmittedLines]);
  finally
    Accepted.Free;
    Lines.Free;
  end;
end;

procedure TMNoteTokenEstimator.Calibrate(ACharacters, AActualTokens: Integer);
var
  ObservedRatio: Double;
begin
  if (ACharacters <= 0) or (AActualTokens <= 0) then Exit;
  ObservedRatio := ACharacters / AActualTokens;
  if ObservedRatio < 1.0 then ObservedRatio := 1.0;
  if ObservedRatio > 12.0 then ObservedRatio := 12.0;
  FCharactersPerToken := (FCharactersPerToken * 0.75) +
    (ObservedRatio * 0.25);
end;

procedure TMNoteTokenEstimator.CalibrateLanguage(ACharacters,
  AActualTokens: Integer; const ALanguage: string);
var
  ObservedRatio, Current: Double;
begin
  if (ACharacters <= 0) or (AActualTokens <= 0) then Exit;
  ObservedRatio := ACharacters / AActualTokens;
  if ObservedRatio < 1.0 then ObservedRatio := 1.0;
  if ObservedRatio > 12.0 then ObservedRatio := 12.0;
  if SameText(ALanguage, 'code') or SameText(ALanguage, 'pascal') or
    SameText(ALanguage, 'sql') then
  begin
    Current := FCodeCharactersPerToken;
    FCodeCharactersPerToken := (Current * 0.75) + (ObservedRatio * 0.25);
  end
  else if SameText(ALanguage, 'portuguese') or SameText(ALanguage, 'pt') then
  begin
    Current := FPortugueseCharactersPerToken;
    FPortugueseCharactersPerToken := (Current * 0.75) +
      (ObservedRatio * 0.25);
  end
  else
    Calibrate(ACharacters, AActualTokens);
end;

procedure TMNoteTokenEstimator.SetLanguageCoefficient(
  const ALanguage: string; ACharactersPerToken: Double);
begin
  if ACharactersPerToken < 1.0 then ACharactersPerToken := 1.0;
  if ACharactersPerToken > 12.0 then ACharactersPerToken := 12.0;
  if SameText(ALanguage, 'code') or SameText(ALanguage, 'pascal') or
    SameText(ALanguage, 'sql') then
    FCodeCharactersPerToken := ACharactersPerToken
  else if SameText(ALanguage, 'portuguese') or SameText(ALanguage, 'pt') then
    FPortugueseCharactersPerToken := ACharactersPerToken
  else
    FCharactersPerToken := ACharactersPerToken;
end;

end.
