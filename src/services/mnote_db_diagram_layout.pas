unit mnote_db_diagram_layout;
{$mode objfpc}{$H+}
interface
uses Classes, SysUtils, Math, fpjson, jsonparser, mnote_db_diagram_model;
procedure SaveDiagramLayout(M: TDiagramModel; Zoom: Double; const FileName: string);
procedure LoadDiagramLayout(M: TDiagramModel; var Zoom: Double; const FileName: string);
implementation
procedure SaveDiagramLayout(M: TDiagramModel; Zoom: Double; const FileName: string);
var Root, Item: TJSONObject; Items: TJSONArray; I: Integer; T: TDiagramTable; Text: TStringList;
begin
  Root := TJSONObject.Create; Text := TStringList.Create;
  try
    Root.Add('version', 2); Root.Add('filter', M.FilterText); Root.Add('focus', M.FocusKey); Root.Add('context', DiagramContextKey(M.Context)); Root.Add('zoom', Zoom);
    Items := TJSONArray.Create; Root.Add('tables', Items);
    for I := 0 to M.Tables.Count - 1 do begin
      T := TDiagramTable(M.Tables[I]); Item := TJSONObject.Create;
      Item.Add('key', T.Key); Item.Add('x', T.X); Item.Add('y', T.Y); Items.Add(Item);
    end;
    ForceDirectories(ExtractFileDir(ExpandFileName(FileName))); Text.Text := Root.FormatJSON;
    Text.SaveToFile(FileName);
  finally Text.Free; Root.Free; end;
end;
procedure LoadDiagramLayout(M: TDiagramModel; var Zoom: Double; const FileName: string);
var Data: TJSONData; Root, Item: TJSONObject; Items: TJSONArray; Text: TStringList;
  I: Integer; T: TDiagramTable; NewZoom: Double; NewFilter, NewFocus: string;
begin
  if not FileExists(FileName) then Exit;
  Text := TStringList.Create; Data := nil;
  try
    Text.LoadFromFile(FileName); Data := GetJSON(Text.Text);
    if not (Data is TJSONObject) then raise Exception.Create('Invalid layout format');
    Root := TJSONObject(Data);
    if not (Root.Get('version', 0) in [1, 2]) or (Root.Get('context', '') <> DiagramContextKey(M.Context)) then
      raise Exception.Create('Incompatible layout version or database context');
    Items := Root.Arrays['tables'];
    for I := 0 to Items.Count - 1 do begin
      Item := Items.Objects[I];
      if (Item.Get('x', -1) < 0) or (Item.Get('x', 100001) > 100000) or
        (Item.Get('y', -1) < 0) or (Item.Get('y', 100001) > 100000) or
        (Item.Get('key', '') = '') then raise Exception.Create('Invalid table position or key');
    end;
    NewZoom := Root.Get('zoom', 1.0);
    if IsNan(NewZoom) or IsInfinite(NewZoom) or (NewZoom < 0.4) or (NewZoom > 2.0) then
      raise Exception.Create('Invalid zoom');
    NewFilter := Root.Get('filter', ''); NewFocus := Root.Get('focus', '');
    Zoom := NewZoom; M.FilterText := NewFilter;
    if M.FindTable(NewFocus) <> nil then M.FocusKey := NewFocus else M.FocusKey := '';
    for I := 0 to Items.Count - 1 do begin
      Item := Items.Objects[I]; T := M.FindTable(Item.Get('key', ''));
      if T <> nil then begin T.X := Item.Get('x', 0); T.Y := Item.Get('y', 0); end;
    end;
  finally Data.Free; Text.Free; end;
end;
end.
