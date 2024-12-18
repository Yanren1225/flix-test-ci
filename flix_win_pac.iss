; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Flix"
#define MyAppVersion "beta.v0.1.7"
#define MyAppPublisher "Flix co."
#define MyAppExeName "flix.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{1E2961C8-4A31-4DE2-850C-D9BBE26DCFC9}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputDir=C:\Users\world\Documents\flix
OutputBaseFilename=Flix_installer
SetupIconFile=C:\work\flutter\androp\windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\bonsoir_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\connectivity_plus_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\desktop_drop_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\downloadsfolder_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\file_selector_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\firebase_core_plugin.lib"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\flix.exp"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\flix.lib"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\open_dir_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\pasteboard_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\permission_handler_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\screen_retriever_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\share_plus_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\sqlite3.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\sqlite3_flutter_libs_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\video_player_win_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\work\flutter\androp\build\windows\x64\runner\flix\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

