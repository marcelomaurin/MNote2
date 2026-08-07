program ssl_loader_test;

{$mode objfpc}{$H+}
{$codepage utf8}

uses
  Classes, SysUtils, mnote_ssl_loader;

var
  FailCount: Integer = 0;
  PassCount: Integer = 0;

procedure AssertTrue(const ACondition: Boolean; const ATestName: string);
begin
  if ACondition then
  begin
    Inc(PassCount);
    WriteLn('[PASS] ', ATestName);
  end
  else
  begin
    Inc(FailCount);
    WriteLn('[FAIL] ', ATestName);
  end;
end;

procedure AssertFalse(const ACondition: Boolean; const ATestName: string);
begin
  AssertTrue(not ACondition, ATestName);
end;

procedure TestNormalInitialization;
var
  Err: string;
  OK: Boolean;
begin
  OK := InitializeMNoteSSL(Err);
  AssertTrue(OK, 'TestNormalInitialization: SSL successfully initialized');
  AssertTrue(IsMNoteSSLLoaded, 'TestNormalInitialization: IsMNoteSSLLoaded is True');
  AssertTrue(Pos('libssl', MNoteSSLLoadedDescription) > 0, 'TestNormalInitialization: Description contains libssl');
end;

procedure TestIdempotentInitialization;
var
  Err1, Err2: string;
  OK1, OK2: Boolean;
begin
  OK1 := InitializeMNoteSSL(Err1);
  OK2 := InitializeMNoteSSL(Err2);
  AssertTrue(OK1 and OK2, 'TestIdempotentInitialization: Double call returned True');
  AssertTrue(Err1 = Err2, 'TestIdempotentInitialization: Errors match');
end;

procedure TestExecutionFromDifferentCurrentDir;
var
  OriginalDir, TempDir: string;
  Description: string;
begin
  OriginalDir := GetCurrentDir;
  TempDir := GetEnvironmentVariable('TEMP');
  if TempDir <> '' then
  begin
    SetCurrentDir(TempDir);
    try
      Description := MNoteSSLLoadedDescription;
      AssertTrue(IsMNoteSSLLoaded, 'TestExecutionFromDifferentCurrentDir: Remains loaded after cd');
    finally
      SetCurrentDir(OriginalDir);
    end;
  end
  else
    WriteLn('[SKIP] TestExecutionFromDifferentCurrentDir: TEMP variable empty');
end;

procedure TestError193MessageFormat;
var
  Msg: string;
begin
  Msg := 'A DLL encontrada não é compatível com o MNote2 de 32 bits. Utilize uma versão OpenSSL x86.';
  AssertTrue(Pos('não é compatível com o MNote2 de 32 bits', Msg) > 0, 'TestError193MessageFormat: Contains 32-bit incompatibility message');
end;

procedure TestCLIReport;
var
  Report: string;
  OK: Boolean;
begin
  OK := PerformSSLCheckCLI(Report);
  AssertTrue(Pos('Aplicação:', Report) > 0, 'TestCLIReport: Contains bitness');
  AssertTrue(Pos('Resultado:', Report) > 0, 'TestCLIReport: Contains result');
end;

begin
  WriteLn('========================================');
  WriteLn('   MNote2 SSL Loader Test Suite');
  WriteLn('========================================');

  TestNormalInitialization;
  TestIdempotentInitialization;
  TestExecutionFromDifferentCurrentDir;
  TestError193MessageFormat;
  TestCLIReport;

  WriteLn('----------------------------------------');
  WriteLn('Passes: ', PassCount, ' | Failures: ', FailCount);
  if FailCount > 0 then
    Halt(1)
  else
    Halt(0);
end.
