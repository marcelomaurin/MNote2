unit mnote_ai_tasks_form;
{$mode objfpc}{$H+}
{$codepage utf8}
interface
uses Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls,
  mnote_ai_task_orchestrator;
type
  TMNoteAITasksForm = class(TForm)
  private
    FPlanner: TMNoteAITaskOrchestrator;
    FRequest: TMemo;
    FIncludeSQL: TCheckBox;
    FTasks: TListBox;
    FResult: TMemo;
    FStatus: TLabel;
    procedure NewPlan(Sender: TObject);
    procedure RunNext(Sender: TObject);
    procedure Selected(Sender: TObject);
    procedure RefreshView;
  public
    constructor CreateForProject(AOwner: TComponent; const AProjectRoot: string);
    destructor Destroy; override;
  end;

implementation

constructor TMNoteAITasksForm.CreateForProject(AOwner: TComponent;
  const AProjectRoot: string);
var B: TButton;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'MNote2 - Análise por tarefas';
  SetBounds(0, 0, 800, 660);
  Position := poScreenCenter;
  FPlanner := TMNoteAITaskOrchestrator.Create(AProjectRoot);
  FRequest := TMemo.Create(Self);
  FRequest.Parent := Self;
  FRequest.SetBounds(12, 12, 760, 80);
  FRequest.ScrollBars := ssVertical;
  if FPlanner.Request <> '' then FRequest.Text := FPlanner.Request
  else FRequest.Text := 'Analisar o projeto e propor melhorias com evidências.';
  FIncludeSQL := TCheckBox.Create(Self);
  FIncludeSQL.Parent := Self;
  FIncludeSQL.SetBounds(12, 100, 320, 24);
  FIncludeSQL.Caption := 'Incluir análise SQL';
  FIncludeSQL.Checked := True;
  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'Criar plano';
  B.SetBounds(12, 132, 130, 30);
  B.OnClick := @NewPlan;
  B := TButton.Create(Self);
  B.Parent := Self;
  B.Caption := 'Executar próxima tarefa';
  B.SetBounds(155, 132, 200, 30);
  B.OnClick := @RunNext;
  FStatus := TLabel.Create(Self);
  FStatus.Parent := Self;
  FStatus.SetBounds(12, 174, 760, 23);
  FTasks := TListBox.Create(Self);
  FTasks.Parent := Self;
  FTasks.SetBounds(12, 202, 760, 145);
  FTasks.OnClick := @Selected;
  FResult := TMemo.Create(Self);
  FResult.Parent := Self;
  FResult.ReadOnly := True;
  FResult.ScrollBars := ssAutoBoth;
  FResult.SetBounds(12, 360, 760, 250);
  RefreshView;
end;

destructor TMNoteAITasksForm.Destroy;
begin
  FPlanner.Free;
  inherited Destroy;
end;

procedure TMNoteAITasksForm.RefreshView;
var I, Completed: Integer;
begin
  FTasks.Items.BeginUpdate;
  try
    FTasks.Clear;
    Completed := 0;
    for I := 0 to FPlanner.Count - 1 do
    begin
      FTasks.Items.Add(Format('%d. [%s] %s  (%s)', [I + 1,
        MNoteTaskStateName(FPlanner.Tasks[I].State), FPlanner.Tasks[I].Title,
        FPlanner.Tasks[I].Category]));
      if FPlanner.Tasks[I].State = atsCompleted then Inc(Completed);
    end;
    FStatus.Caption := Format('%d/%d concluídas — tarefas sequenciais com dependências',
      [Completed, FPlanner.Count]);
  finally
    FTasks.Items.EndUpdate;
  end;
end;

procedure TMNoteAITasksForm.NewPlan(Sender: TObject);
begin
  if MessageDlg('Tarefas IA', 'Substituir o plano atual e seus resultados?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  FPlanner.Plan(FRequest.Text, FIncludeSQL.Checked);
  FResult.Lines.Text := 'Plano criado. Inicie as tarefas uma a uma.';
  RefreshView;
end;

procedure TMNoteAITasksForm.RunNext(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    if not FPlanner.ExecuteNext then
      FResult.Lines.Add('Não foi possível executar: ' + FPlanner.LastError)
    else
      FResult.Lines.Add('Tarefa concluída. Selecione para consultar evidências.');
  finally
    Screen.Cursor := crDefault;
    RefreshView;
  end;
end;

procedure TMNoteAITasksForm.Selected(Sender: TObject);
var I: Integer;
begin
  I := FTasks.ItemIndex;
  if (I < 0) or (I >= FPlanner.Count) then Exit;
  FResult.Lines.Text := 'Tarefa: ' + FPlanner.Tasks[I].Title + LineEnding +
    'Depende de: ' + FPlanner.Tasks[I].DependsOn + LineEnding +
    'Estado: ' + MNoteTaskStateName(FPlanner.Tasks[I].State) + LineEnding +
    'Erro: ' + FPlanner.Tasks[I].ErrorText + LineEnding + LineEnding +
    FPlanner.Tasks[I].Evidence;
end;

end.
