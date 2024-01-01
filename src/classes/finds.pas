unit finds;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,SynEdit,item, StdCtrls,Controls,ExtCtrls, FileUtil,ComCtrls;


type
TFinds = class(TObject)

      public
            syn : TSynEdit;
            tb : TTabSheet;
            item : TItem;
            IPOS : integer;
            FLen : integer;
            strFind : string;

            constructor create(fsyn: TSynEdit; ftb: TTabSheet; fitem: TItem; FIPOS: integer; fstrFind : string);
            destructor destroy();
      private

end;

implementation

constructor TFinds.create(fsyn: TSynEdit; ftb: TTabSheet; fitem: TItem; FIPOS: integer; fstrFind : string);
begin
     syn := fsyn;
     tb := ftb;
     item := fitem;
     IPOS := FIPOS;
     strFind := fstrFind;
     FLen := Length(strFind);
end;

destructor TFinds.destroy();
begin

end;




end.

