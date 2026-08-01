unit mnote_document_export_service;

{$mode objfpc}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, mnote_service_base, aioutput_docs;

type
  TMNoteDocumentFormat = (mdfText, mdfPDF);

  { TMNoteDocumentExportService }

  TMNoteDocumentExportService = class(TMNoteServiceBase)
  public
    function ExportDocument(const ATitle, AContent, AFileName: string;
      AFormat: TMNoteDocumentFormat): Boolean;
  end;

implementation

function TMNoteDocumentExportService.ExportDocument(const ATitle,
  AContent, AFileName: string; AFormat: TMNoteDocumentFormat): Boolean;
var
  Output: TAIOutputDocs;
  Lines: TStringList;
  I: Integer;
begin
  Result := False;
  ClearError;
  if Trim(AFileName) = '' then
  begin
    SetError('Informe o arquivo de destino.');
    Exit;
  end;
  Output := TAIOutputDocs.Create(nil);
  Lines := TStringList.Create;
  try
    Output.Title := ATitle;
    Output.Author := 'MNote2';
    Output.Subject := 'Documento exportado pela IDE';
    Output.AddHeading(ATitle, 1);
    Lines.Text := AContent;
    for I := 0 to Lines.Count - 1 do Output.AddParagraph(Lines[I]);
    case AFormat of
      mdfText:
        begin
          Output.FileNameTXT := AFileName;
          Result := Output.SaveToTXT;
        end;
      mdfPDF:
        begin
          Output.FileNamePDF := AFileName;
          Result := Output.SaveToPDF;
        end;
    end;
    if (not Result) or (not FileExists(AFileName)) then
    begin
      Result := False;
      if Output.LastError <> '' then SetError(Output.LastError)
      else SetError('O documento não foi gerado pelo componente de saída.');
    end;
  except
    on E: Exception do SetError('Falha ao exportar documento: ' + E.Message);
  end;
  Lines.Free;
  Output.Free;
end;

end.
