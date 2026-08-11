unit mnote_completion_aggregator;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_completion_types, mnote_completion_provider;

type
  { TMNoteCompletionAggregator }

  TMNoteCompletionAggregator = class
  private
    FProviders: TInterfaceList;
    function CalculateScore(AContext: TMNoteCompletionContext;
      AItem: TMNoteCompletionItem): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddProvider(const AProvider: IMNoteCompletionProvider);
    procedure Complete(AContext: TMNoteCompletionContext;
      AItems: TMNoteCompletionItems);
    property Providers: TInterfaceList read FProviders;
  end;

implementation

uses
  mnote_fuzzy_matcher;

constructor TMNoteCompletionAggregator.Create;
begin
  inherited Create;
  FProviders := TInterfaceList.Create;
end;

destructor TMNoteCompletionAggregator.Destroy;
begin
  FProviders.Free;
  inherited Destroy;
end;

procedure TMNoteCompletionAggregator.AddProvider(
  const AProvider: IMNoteCompletionProvider);
begin
  if AProvider <> nil then FProviders.Add(AProvider);
end;

function TMNoteCompletionAggregator.CalculateScore(
  AContext: TMNoteCompletionContext; AItem: TMNoteCompletionItem): Integer;
var
  FuzzyScore: Integer;
begin
  FuzzyScore := TMNoteFuzzyMatcher.Score(AContext.Query, AItem.Text);
  if FuzzyScore < 0 then Exit(-1);
  Result := FuzzyScore + (AItem.Priority * 100);

  { Semantic editor context must outrank broad project/static candidates. }
  if SameText(AItem.Origin, 'semantico') then Inc(Result, 5000);
  if SameText(AItem.Origin, 'documento') then Inc(Result, 400);
  if SameText(AItem.Origin, 'projeto') then Inc(Result, 300);

  if (AContext.FileName <> '') and (AItem.FileName <> '') and
    SameFileName(AContext.FileName, AItem.FileName) then
    Inc(Result, 600);

  if (AItem.Line > 0) and (AContext.CursorLine > 0) then
  begin
    if Abs(AItem.Line - AContext.CursorLine) <= 20 then Inc(Result, 250)
    else if Abs(AItem.Line - AContext.CursorLine) <= 100 then Inc(Result, 100);
  end;

  if (AItem.Kind = ckTable) and
    (Pos('FROM ', UpperCase(AContext.TextBeforeCursor)) > 0) then
    Inc(Result, 1000);
  if (AItem.Kind = ckField) and
    (Pos('.', AContext.TextBeforeCursor) > 0) then Inc(Result, 1000);
end;

procedure TMNoteCompletionAggregator.Complete(AContext: TMNoteCompletionContext;
  AItems: TMNoteCompletionItems);
var
  Provider: IMNoteCompletionProvider;
  CandidateItems: TMNoteCompletionItems;
  Candidate, Existing: TMNoteCompletionItem;
  I, J, CandidateScore: Integer;
begin
  AItems.Clear;
  CandidateItems := TMNoteCompletionItems.Create;
  try
    for I := 0 to FProviders.Count - 1 do
    begin
      Provider := IMNoteCompletionProvider(FProviders[I]);
      if not Provider.Supports(AContext) then Continue;
      CandidateItems.Clear;
      Provider.Collect(AContext, CandidateItems);
      for J := 0 to CandidateItems.Count - 1 do
      begin
        Candidate := CandidateItems[J];
        CandidateScore := CalculateScore(AContext, Candidate);
        if CandidateScore < 0 then Continue;
        Existing := AItems.FindByInsertText(Candidate.InsertText);
        if Existing = nil then
        begin
          Existing := Candidate.Clone;
          Existing.Score := CandidateScore;
          AItems.Add(Existing);
        end
        else
        begin
          if Length(Candidate.Documentation) > Length(Existing.Documentation) then
            Existing.Documentation := Candidate.Documentation;
          if (CandidateScore > Existing.Score) or
            ((CandidateScore = Existing.Score) and
             (Candidate.Priority > Existing.Priority)) then
          begin
            Existing.Kind := Candidate.Kind;
            Existing.Signature := Candidate.Signature;
            Existing.Origin := Candidate.Origin;
            Existing.Priority := Candidate.Priority;
            Existing.FileName := Candidate.FileName;
            Existing.Line := Candidate.Line;
            Existing.Score := CandidateScore;
          end;
        end;
      end;
    end;
    AItems.Sort;
  finally
    CandidateItems.Free;
  end;
end;

end.
