; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "MNote2"
#define MyAppVersion "2.10"
#define MyAppPublisher "Maurinsoft"
#define MyAppURL "http://maurinsoft.com.br"
#define MyAppExeName "MNote2.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
PrivilegesRequired=admin

AppId={{5D8E2FD0-2823-4697-B0CE-7623F3C4ECF6}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\MEDIT2
DisableProgramGroupPage=yes
OutputDir=D:\projetos\maurinsoft\MNote2\bin
OutputBaseFilename=win_MNote2_10
SetupIconFile=d:\projetos\maurinsoft\MNote2\src\MNote2.ico
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "d:\projetos\maurinsoft\MNote2\src\MNote2.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "d:\projetos\maurinsoft\MNote2\src\*.dci"; DestDir: "{app}"; Flags: ignoreversion
Source: "d:\projetos\maurinsoft\MNote2\libs\sqlite\win32\*.*"; DestDir: "{app}\libs\sqlite\win32\"; Flags: ignoreversion
Source: "d:\projetos\maurinsoft\MNote2\libs\sqlite\win64\*.*"; DestDir: "{app}\libs\sqlite\win64\"; Flags: ignoreversion
Source: "d:\projetos\maurinsoft\MNote2\libs\postgres\win32\*.*"; DestDir: "{app}\libs\postgres\win32\"; Flags: ignoreversion
Source: "d:\projetos\maurinsoft\MNote2\libs\postgres\win64\*.*"; DestDir: "{app}\libs\postgres\win64\"; Flags: ignoreversion
Source: "d:\projetos\maurinsoft\MNote2\libs\mysql\win32\*.*"; DestDir: "{app}\libs\mysql\win32\"; Flags: ignoreversion
Source: "d:\projetos\maurinsoft\MNote2\libs\mysql\win64\*.*"; DestDir: "{app}\libs\mysql\win64\"; Flags: ignoreversion

Source: "D:\projetos\maurinsoft\MNote2\src\libs\win64\libmysql64.dll"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent  runascurrentuser 


