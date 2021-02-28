unit TypeDB;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
TypeDatabase = (DBMysql, DBPostgres);

TEleTipoDB = (ETConection, ETDBBanco , ETDTabelas, ETDBCampos, ETDBPK, ETDBFK, ETDViews, ETDProcedure, ETDFunctions, ETDSequence );



implementation

end.

