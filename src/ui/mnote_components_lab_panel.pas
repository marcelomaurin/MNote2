unit mnote_components_lab_panel;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, ComCtrls, Dialogs,
  mnote_capability_catalog, mnote_dependency_graph_service,
  mnote_document_export_service;

type
  { TMNoteComponentsLabPanel }

  TMNoteComponentsLabPanel = class(TComponent)
  private
    FCatalog: TMNoteCapabilityCatalog;
    FGraph: TMNoteDependencyGraphService;
    FExporter: TMNoteDocumentExportService;
    FRootPath: string;
    FVoiceEnabled: Boolean;
    FList: TListView;
    FDetails: TMemo;
    procedure RefreshClick(Sender: TObject);
    procedure GraphClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure SelectionChanged(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FillCatalog;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize(AParent: TWinControl; const ARootPath: string;
      AVoiceEnabled: Boolean);
    procedure SetProjectRoot(const ARootPath: string);
    property Catalog: TMNoteCapabilityCatalog read FCatalog;
  end;

implementation

procedure AddColumn(AList: TListView; const ACaption: string; AWidth: Integer);
begin
  with AList.Columns.Add do
  begin
    Caption := ACaption;
    Width := AWidth;
  end;
end;

constructor TMNoteComponentsLabPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCatalog := TMNoteCapabilityCatalog.Create;
  FGraph := TMNoteDependencyGraphService.Create;
  FExporter := TMNoteDocumentExportService.Create;
end;

destructor TMNoteComponentsLabPanel.Destroy;
begin
  FExporter.Free;
  FGraph.Free;
  FCatalog.Free;
  inherited Destroy;
end;

procedure TMNoteComponentsLabPanel.Initialize(AParent: TWinControl;
  const ARootPath: string; AVoiceEnabled: Boolean);
var
  Toolbar: TPanel;
  Button: TButton;
begin
  FRootPath := ARootPath;
  FVoiceEnabled := AVoiceEnabled;
  while AParent.ControlCount > 0 do AParent.Controls[0].Free;
  Toolbar := TPanel.Create(Self);
  Toolbar.Parent := AParent;
  Toolbar.Align := alTop;
  Toolbar.Height := 34;
  Toolbar.BevelOuter := bvNone;

  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.SetBounds(4, 4, 64, 25);
  Button.Caption := 'Atualizar'; Button.OnClick := @RefreshClick;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.SetBounds(72, 4, 94, 25);
  Button.Caption := 'Dependências'; Button.OnClick := @GraphClick;
  Button := TButton.Create(Self);
  Button.Parent := Toolbar; Button.SetBounds(170, 4, 88, 25);
  Button.Caption := 'Exportar'; Button.OnClick := @ExportClick;

  FDetails := TMemo.Create(Self);
  FDetails.Parent := AParent;
  FDetails.Align := alBottom;
  FDetails.Height := 190;
  FDetails.ReadOnly := True;
  FDetails.ScrollBars := ssAutoBoth;
  FDetails.WordWrap := False;

  FList := TListView.Create(Self);
  FList.Parent := AParent;
  FList.Align := alClient;
  FList.ViewStyle := vsReport;
  FList.ReadOnly := True;
  FList.RowSelect := True;
  FList.OnSelectItem := @SelectionChanged;
  AddColumn(FList, 'Área', 85);
  AddColumn(FList, 'Capacidade', 185);
  AddColumn(FList, 'Estado', 85);
  AddColumn(FList, 'Pacote', 120);
  FillCatalog;
end;

procedure TMNoteComponentsLabPanel.SetProjectRoot(const ARootPath: string);
begin
  if Trim(ARootPath) = '' then FRootPath := ''
  else FRootPath := ExpandFileName(ARootPath);
  if FDetails <> nil then
    if FRootPath = '' then FDetails.Text := 'Nenhum projeto aberto.'
    else FDetails.Text := 'Projeto ativo: ' + FRootPath;
end;

procedure TMNoteComponentsLabPanel.FillCatalog;
var
  I: Integer;
  Capability: TMNoteCapability;
  Item: TListItem;
begin
  FCatalog.Refresh(FVoiceEnabled);
  FList.Items.BeginUpdate;
  try
    FList.Items.Clear;
    for I := 0 to FCatalog.Items.Count - 1 do
    begin
      Capability := TMNoteCapability(FCatalog.Items[I]);
      Item := FList.Items.Add;
      Item.Caption := Capability.Category;
      Item.SubItems.Add(Capability.Name);
      Item.SubItems.Add(MNoteCapabilityStateName(Capability.State));
      Item.SubItems.Add(Capability.PackageName);
      Item.Data := Capability;
    end;
  finally
    FList.Items.EndUpdate;
  end;
  FDetails.Text := 'Selecione uma capacidade para ver dependências e evidência.';
end;

procedure TMNoteComponentsLabPanel.RefreshClick(Sender: TObject);
begin
  FillCatalog;
end;

procedure TMNoteComponentsLabPanel.GraphClick(Sender: TObject);
begin
  FDetails.Lines.Text := 'Analisando dependências reais do projeto...';
  Application.ProcessMessages;
  if FGraph.Build(FRootPath) then FDetails.Lines.Text := FGraph.AsText
  else FDetails.Lines.Text := FGraph.LastError;
end;

procedure TMNoteComponentsLabPanel.ExportClick(Sender: TObject);
var
  Dialog: TSaveDialog;
  Format: TMNoteDocumentFormat;
begin
  Dialog := TSaveDialog.Create(nil);
  try
    Dialog.Title := 'Exportar catálogo de capacidades';
    Dialog.Filter := 'Texto (*.txt)|*.txt|PDF (*.pdf)|*.pdf';
    Dialog.DefaultExt := 'txt';
    if not Dialog.Execute then Exit;
    if Dialog.FilterIndex = 2 then Format := mdfPDF else Format := mdfText;
    if not FExporter.ExportDocument('Capacidades do MNote2',
      FCatalog.AsText, Dialog.FileName, Format) then
      MessageDlg('Exportação', FExporter.LastError, mtError, [mbOK], 0)
    else
      MessageDlg('Exportação', 'Documento criado em:' + LineEnding +
        Dialog.FileName, mtInformation, [mbOK], 0);
  finally
    Dialog.Free;
  end;
end;

procedure TMNoteComponentsLabPanel.SelectionChanged(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  Capability: TMNoteCapability;
begin
  if not Selected or (Item = nil) then Exit;
  Capability := TMNoteCapability(Item.Data);
  if Capability = nil then Exit;
  FDetails.Lines.Text := Capability.Name + LineEnding +
    'Estado: ' + MNoteCapabilityStateName(Capability.State) + LineEnding +
    'Pacote: ' + Capability.PackageName + LineEnding +
    'Dependências: ' + Capability.Dependency + LineEnding +
    'Evidência: ' + Capability.Evidence;
end;

end.
