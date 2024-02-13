unit progress;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

type

  { Tfrmprogress }

  Tfrmprogress = class(TForm)
    lbprogress: TLabel;
    pbProgress: TProgressBar;
  private

  public

  end;

var
  frmprogress: Tfrmprogress;

implementation

{$R *.lfm}

end.

