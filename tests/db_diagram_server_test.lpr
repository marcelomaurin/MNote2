program db_diagram_server_test;
{$mode objfpc}{$H+}
uses Interfaces, Forms, Classes, SysUtils, ZConnection,
  mnote_db_diagram_model, mnote_db_diagram_reader, mnote_db_diagram_job;
var Passed, Failed, Skipped: Integer;
procedure ValidateServer(const Prefix, Protocol: string);
var C: TZConnection; Context: TDiagramContext; Job: IDiagramJob;
  M: TDiagramModel; I, J, Expected: Integer; Deadline: QWord;
  R: TDiagramRelation; Pair: TDiagramPair; Source: TDiagramTable;
  Password, ErrorText: string;
  function Setting(const Key: string): string;
  begin Result := GetEnvironmentVariable('MQUERY_' + Prefix + '_' + Key); end;
begin
  if Setting('DATABASE') = '' then begin
    Inc(Skipped); WriteLn('SKIP ', Prefix, ': no test configuration'); Exit;
  end;
  C := TZConnection.Create(nil); M := nil; Password := Setting('PASSWORD');
  try
    try
      C.Name := 'Test' + Prefix; C.Protocol := Protocol;
      C.HostName := Setting('HOST'); C.Port := StrToIntDef(Setting('PORT'), 0);
      C.Database := Setting('DATABASE'); C.User := Setting('USER');
      C.Password := Password; C.LibraryLocation := Setting('LIBRARY');
      C.LoginPrompt := False; C.ReadOnly := True; C.Connect;
      Context := DiagramConnectionContext(C, Setting('SCHEMA'));
      Job := StartDiagramJob(C, Context); Deadline := GetTickCount64 + 60000;
      while not Job.Status.Done do begin
        if GetTickCount64 > Deadline then begin
          Job.Cancel; raise Exception.Create('Metadata test timed out; driver cancellation is cooperative');
        end;
        Sleep(10);
      end;
      if Job.Status.ErrorText <> '' then raise Exception.Create(Job.Status.ErrorText);
      M := Job.TakeModel;
      if M = nil then raise Exception.Create('No metadata returned');
      if M.Tables.Count = 0 then raise Exception.Create('No visible tables in selected scope');
      Expected := StrToIntDef(Setting('EXPECT_TABLES'), -1);
      if (Expected >= 0) and (M.Tables.Count <> Expected) then raise Exception.Create('Unexpected table count');
      Expected := StrToIntDef(Setting('EXPECT_FKS'), -1);
      if (Expected >= 0) and (M.Relations.Count <> Expected) then raise Exception.Create('Unexpected FK count');
      for I := 0 to M.Relations.Count - 1 do begin
        R := TDiagramRelation(M.Relations[I]); Source := M.FindTable(R.SourceKey);
        if (Source = nil) or (R.Pairs.Count = 0) then raise Exception.Create('Invalid FK source or pairs');
        for J := 0 to R.Pairs.Count - 1 do begin
          Pair := TDiagramPair(R.Pairs[J]);
          if (Pair.Position <> J + 1) or (Source.ColumnIndex(Pair.SourceColumn) < 0) then
            raise Exception.Create('Invalid composite FK ordering or column');
        end;
      end;
      Inc(Passed); WriteLn('PASS ', Prefix, ': ', M.Tables.Count, ' tables, ',
        M.Relations.Count, ' foreign keys, ', M.Warnings.Count, ' warnings');
    except on E: Exception do begin
      ErrorText := E.Message;
      if Password <> '' then ErrorText := StringReplace(ErrorText, Password, '[redacted]', [rfReplaceAll]);
      Inc(Failed); WriteLn('FAIL ', Prefix, ': ', ErrorText);
    end; end;
  finally M.Free; C.Free; end;
end;
begin
  Application.Initialize;
  ValidateServer('POSTGRES', 'postgresql');
  ValidateServer('MYSQL', 'mysql');
  ValidateServer('MSSQL', 'mssql');
  ValidateServer('ORACLE', 'oracle');
  WriteLn('RESULT: ', Passed, ' passed, ', Failed, ' failed, ', Skipped, ' skipped');
  if Failed > 0 then Halt(1);
  if Skipped > 0 then Halt(2);
end.
