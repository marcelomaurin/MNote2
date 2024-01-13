unit codigo;


interface

uses
  Classes, SysUtils, Generics.Collections, contnrs;

type
  TFonte = class
  public
    Tipo: string;
    Codigo: string;
  end;

  TCodigo = class
  private
    FItems: TObjectList;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AnalisaTexto(texto: string);
    property Items: TObjectList read FItems;
    property Count: Integer read GetCount;
  end;

implementation

{ TCodigo }

constructor TCodigo.Create;
begin
  inherited Create;
  FItems := TObjectList.Create(True); // True para a lista gerenciar a memória dos objetos
end;

destructor TCodigo.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TCodigo.GetCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TCodigo.AnalisaTexto(texto: string);
var
  inicioBloco, fimBloco, inicioTipo, fimTipo, inicioCodigo: Integer;
  bloco: TFonte;
  tipo : string;
  codigo : string;
begin
  FItems.Clear;
  inicioBloco := Pos('```', texto);

  while inicioBloco > 0 do
  begin
    fimBloco := Pos('```', texto, inicioBloco + 3);
    if fimBloco = 0 then Break; //inicio sem fim

    inicioTipo := inicioBloco + 3;
    fimTipo := Pos(#10, texto, inicioTipo);
    inicioCodigo := fimTipo + 1;

    bloco := TFonte.Create;
    if fimTipo > inicioTipo then
      tipo := Trim(Copy(texto, inicioTipo, (fimTipo) - inicioTipo))
    else
      tipo := '';
    bloco.Tipo := tipo ;

    codigo := Trim(Copy(texto, fimTipo+1, (fimBloco-1) - (fimTipo+1)));
    bloco.Codigo := codigo;
    FItems.Add(bloco);

    inicioBloco := Pos('```', texto, fimBloco + 3);
  end;
end;

end.
