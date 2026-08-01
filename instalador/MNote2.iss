; Inno Setup script for MNote2
; 32-bit app for Windows x86/x64

#define MyAppName "MNote2"
#define MyAppVersion "2.66"
#define MyAppPublisher "Maurinsoft"
#define MyAppURL "http://maurinsoft.com.br"
#define MyAppExeName "MNote2.exe"
#define ProjectRoot "D:\projetos\maurinsoft\MNote2"

[Setup]
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=commandline

AppId={{5D8E2FD0-2823-4697-B0CE-7623F3C4ECF6}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={commonpf32}\{#MyAppName}
DisableProgramGroupPage=yes
OutputDir={#ProjectRoot}\bin
OutputBaseFilename=win_MNote2_66
SetupIconFile={#ProjectRoot}\src\MNote2.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Dirs]
Name: "{app}\db"
Name: "{app}\libs\sqlite\win32"
Name: "{app}\libs\mysql\win32\lib"
Name: "{app}\libs\postgres\win32"
Name: "{app}\libs\oracle\win32"
Name: "{app}\libs\mssql\win32"

[Files]
; Main executable
Source: "{#ProjectRoot}\src\MNote2.exe"; DestDir: "{app}"; Flags: ignoreversion

; Support files
Source: "{#ProjectRoot}\src\*.dci"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\src\*.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\src\*.bat"; DestDir: "{app}"; Flags: ignoreversion

; Runtime DLLs used by the app
Source: "{#ProjectRoot}\src\libmysql.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\src\libmysql32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\libs\mysql\win32\lib\libcrypto-1_1.dll"; DestDir: "{app}\libs\mysql\win32\lib"; Flags: ignoreversion
Source: "{#ProjectRoot}\libs\mysql\win32\lib\libssl-1_1.dll"; DestDir: "{app}\libs\mysql\win32\lib"; Flags: ignoreversion
Source: "{#ProjectRoot}\libs\mysql\win32\lib\mysqlcppconn-9-vs14.dll"; DestDir: "{app}\libs\mysql\win32\lib"; Flags: ignoreversion
Source: "{#ProjectRoot}\libs\mysql\win32\lib\mysqlcppconn8-2-vs14.dll"; DestDir: "{app}\libs\mysql\win32\lib"; Flags: ignoreversion

; PostgreSQL 32-bit runtime
Source: "{#ProjectRoot}\libs\postgres\win32\*.dll"; DestDir: "{app}\libs\postgres\win32"; Flags: ignoreversion

; Oracle 32-bit runtime
Source: "{#ProjectRoot}\libs\oracle\win32\oci.dll"; DestDir: "{app}\libs\oracle\win32"; Flags: ignoreversion

; SQLite 32-bit runtime in the path expected by the application
Source: "{#ProjectRoot}\libs\sqlite\win32\sqlite3.dll"; DestDir: "{app}\libs\sqlite\win32"; Flags: ignoreversion

; Generic runtime helpers
Source: "{#ProjectRoot}\src\legacy.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\src\libcrypto-1_1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\src\libcrypto.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\src\libeay32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\src\libpq.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\src\libssl-1_1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\src\libssl.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\src\ssleay32.dll"; DestDir: "{app}"; Flags: ignoreversion

; Tools
Source: "{#ProjectRoot}\tools\windows\srvFalar_1.4.exe"; DestDir: "{app}\tools"; Flags: ignoreversion

; Samples
Source: "{#ProjectRoot}\sample\gcc\hello.c"; DestDir: "{app}\sample\gcc"; Flags: ignoreversion
Source: "{#ProjectRoot}\sample\python\hello\hello.py"; DestDir: "{app}\sample\python\hello"; Flags: ignoreversion

; Default database template used by New Project
Source: "{#ProjectRoot}\db\projeto_padrao.db"; DestDir: "{app}\db"; Flags: ignoreversion

; SQL Server uses a configurable client DLL path.
; The repository currently does not ship a 32-bit SQL Server client DLL, so the
; installer only prepares the destination folder here.

[Icons]
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\tools\srvFalar_1.4.exe"; Description: "Iniciar srvFalar"; Flags: nowait postinstall skipifsilent runascurrentuser
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent runascurrentuser
