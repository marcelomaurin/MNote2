unit mnote_fuzzy_matcher;

{$mode objfpc}{$H+}

interface

type
  { TMNoteFuzzyMatcher }

  TMNoteFuzzyMatcher = class
  public
    class function Score(const AQuery, ACandidate: string): Integer; static;
    class function Matches(const AQuery, ACandidate: string): Boolean; static;
  end;

implementation

uses
  SysUtils;

function IsWordBoundary(const AText: string; AIndex: Integer): Boolean;
begin
  Result := (AIndex <= 1) or
    (AText[AIndex - 1] in [' ', '_', '-', '.', '/', '\', ':']);
end;

class function TMNoteFuzzyMatcher.Score(const AQuery,
  ACandidate: string): Integer;
var
  QueryText, CandidateText: string;
  QueryIndex, CandidateIndex, MatchIndex, PreviousMatch: Integer;
begin
  QueryText := LowerCase(Trim(AQuery));
  CandidateText := LowerCase(Trim(ACandidate));
  if QueryText = '' then
    Exit(0);
  if CandidateText = '' then
    Exit(-1);
  if QueryText = CandidateText then
    Exit(100000);
  if Pos(QueryText, CandidateText) = 1 then
    Exit(80000 - (Length(CandidateText) - Length(QueryText)));
  MatchIndex := Pos(QueryText, CandidateText);
  if MatchIndex > 0 then
  begin
    Result := 60000 - MatchIndex -
      (Length(CandidateText) - Length(QueryText));
    if IsWordBoundary(CandidateText, MatchIndex) then
      Inc(Result, 5000);
    Exit;
  end;

  Result := 0;
  CandidateIndex := 1;
  PreviousMatch := 0;
  for QueryIndex := 1 to Length(QueryText) do
  begin
    MatchIndex := CandidateIndex;
    while (MatchIndex <= Length(CandidateText)) and
      (CandidateText[MatchIndex] <> QueryText[QueryIndex]) do
      Inc(MatchIndex);
    if MatchIndex > Length(CandidateText) then
      Exit(-1);

    Inc(Result, 100);
    if IsWordBoundary(CandidateText, MatchIndex) then
      Inc(Result, 60);
    if (PreviousMatch > 0) and (MatchIndex = PreviousMatch + 1) then
      Inc(Result, 35);
    Dec(Result, MatchIndex - CandidateIndex);
    PreviousMatch := MatchIndex;
    CandidateIndex := MatchIndex + 1;
  end;
  Dec(Result, Length(CandidateText) - Length(QueryText));
end;

class function TMNoteFuzzyMatcher.Matches(const AQuery,
  ACandidate: string): Boolean;
begin
  Result := Score(AQuery, ACandidate) >= 0;
end;

end.
