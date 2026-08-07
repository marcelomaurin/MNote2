unit mnote_problems_panel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, ComCtrls, StdCtrls,
  mnote_diagnostics;

type
  TMNoteProblemNavigateEvent = procedure(const AFileName: string;
    ALine, AColumn, ALength: Integer) of object;

  { TMNoteProblemsPanel }

  TMNoteProblemsPanel = class(TComponent)
  private
    FList: TListView;
    FDiagnostics: TMNoteDiagnostics;
    FErrors: TCheckBox;
    FWarnings: TCheckBox;
    FMessages: TCheckBox;
    FOnNavigate: TMNoteProblemNavigateEvent;
    function IsVisible(ADiagnostic: TMNoteDiagnostic): Boolean;
    procedure FilterClick(Sender: TObject);
    procedure ListDblClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AParent: TWinControl; AList: TListView);
    procedure ParseBuildOutput(const AOutput, AOrigin: string);
    procedure Refresh;
    property Diagnostics: TMNoteDiagnostics read FDiagnostics;
    property OnNavigate: TMNoteProblemNavigateEvent read FOnNavigate
      write FOnNavigate;
  end;

implementation

constructor TMNoteProblemsPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDiagnostics := TMNoteDiagnostics.Create;
end;

destructor TMNoteProblemsPanel.Destroy;
begin
  FDiagnostics.Free;
  inherited Destroy;
end;

procedure TMNoteProblemsPanel.Initialize(AParent: TWinControl;
  AList: TListView);
var
  Toolbar: TPanel;
begin
  FList := AList;
  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := AParent;
  Toolbar.Align := alTop;
  Toolbar.BevelOuter := bvNone;
  Toolbar.Height := 30;

  FErrors := TCheckBox.Create(Self);
  FErrors.Parent := Toolbar;
  FErrors.Caption := 'Erros';
  FErrors.Checked := True;
  FErrors.SetBounds(8, 5, 65, 22);
  FErrors.OnClick := @FilterClick;
  FWarnings := TCheckBox.Create(Self);
  FWarnings.Parent := Toolbar;
  FWarnings.Caption := 'Avisos';
  FWarnings.Checked := True;
  FWarnings.SetBounds(78, 5, 70, 22);
  FWarnings.OnClick := @FilterClick;
  FMessages := TCheckBox.Create(Self);
  FMessages.Parent := Toolbar;
  FMessages.Caption := 'Mensagens';
  FMessages.Checked := True;
  FMessages.SetBounds(153, 5, 95, 22);
  FMessages.OnClick := @FilterClick;
  FList.OnDblClick := @ListDblClick;
end;

function TMNoteProblemsPanel.IsVisible(ADiagnostic: TMNoteDiagnostic): Boolean;
begin
  case ADiagnostic.Severity of
    mdsError: Result := FErrors.Checked;
    mdsWarning: Result := FWarnings.Checked;
  else
    Result := FMessages.Checked;
  end;
end;

procedure TMNoteProblemsPanel.FilterClick(Sender: TObject);
begin
  Refresh;
end;

procedure TMNoteProblemsPanel.ListDblClick(Sender: TObject);
var
  Diagnostic: TMNoteDiagnostic;
begin
  if (FList.Selected = nil) or (FList.Selected.Data = nil) or
    (not Assigned(FOnNavigate)) then Exit;
  Diagnostic := TMNoteDiagnostic(FList.Selected.Data);
  FOnNavigate(Diagnostic.FileName, Diagnostic.Line, Diagnostic.Column, 0);
end;

procedure TMNoteProblemsPanel.ParseBuildOutput(const AOutput,
  AOrigin: string);
begin
  FDiagnostics.Clear;
  TMNoteDiagnosticParser.Parse(AOutput, AOrigin, FDiagnostics);
  MNoteRememberBuildDiagnostics(FDiagnostics);
  Refresh;
end;

procedure TMNoteProblemsPanel.Refresh;
var
  I: Integer;
  Diagnostic: TMNoteDiagnostic;
  ListItem: TListItem;
begin
  if FList = nil then Exit;
  FList.Items.BeginUpdate;
  try
    FList.Items.Clear;
    for I := 0 to FDiagnostics.Count - 1 do
    begin
      Diagnostic := FDiagnostics[I];
      if not IsVisible(Diagnostic) then Continue;
      ListItem := FList.Items.Add;
      ListItem.Caption := TMNoteDiagnosticParser.SeverityName(
        Diagnostic.Severity);
      ListItem.SubItems.Add(Diagnostic.MessageText);
      ListItem.SubItems.Add(Diagnostic.FileName);
      ListItem.SubItems.Add(IntToStr(Diagnostic.Line));
      ListItem.Data := Diagnostic;
    end;
  finally
    FList.Items.EndUpdate;
  end;
end;

end.
