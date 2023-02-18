; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Technitium DNS Server"
#define MyAppVersion "11.0"
#define MyAppPublisher "Technitium"
#define MyAppURL "https://technitium.com/dns/"
#define MyAppExeName "DnsServerSystemTrayApp.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{1052DB5E-35BD-4F67-89CD-1F45A1688E77}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
VersionInfoVersion=2.2.0.0
VersionInfoCopyright="Copyright (C) 2023 Technitium"
DefaultDirName={commonpf32}\Technitium\DNS Server
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=admin
OutputDir=.\Release
OutputBaseFilename=DnsServerSetup
SetupIconFile=.\logo.ico
WizardSmallImageFile=.\logo.bmp
Compression=lzma
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";

[Files]
Source: ".\publish\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\publish\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\DNS Server App"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Dashboard"; Filename: "http://localhost:5380/"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\DNS Server App"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Parameters: "--first-run"; Description: "{cm:LaunchProgram,{#StringChange("DNS Server App", '&', '&&')}}"; Flags: nowait postinstall skipifsilent runascurrentuser

#include "helper.iss"
#include "legacy.iss"
#include "dotnet.iss"
#include "appinstall.iss"

[Code]
{
  Skips the tasks page if it is an upgrade install
}
function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := ((PageID = wpSelectTasks) or (PageID = wpSelectDir)) and (IsLegacyInstallerInstalled or IsUpgrade);
end;

function InitializeSetup: Boolean;
begin
  CheckDotnetDependency;
  Result := true;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then begin //Step happens just before installing files
    WizardForm.StatusLabel.Caption := 'Stopping Tray App...';
    KillTrayApp(); //Stop the tray app if running

    if IsLegacyInstallerInstalled then 
    begin
      WizardForm.StatusLabel.Caption := 'Stopping Service...';
      DoStopService(); //Stop the service if running  

      WizardForm.StatusLabel.Caption := 'Removing Legacy Installer...';
      UninstallLegacyInstaller(); //Uninstall Legacy Installer if Installed already
    end else 
    begin
      WizardForm.StatusLabel.Caption := 'Uninstalling Service...';
      DoRemoveService(); //Stop and remove the service if installed
    end;
  end;

  if CurStep = ssPostInstall then begin //Step happens just after installing files
    WizardForm.StatusLabel.Caption := 'Installing Service...';
    DoInstallService(); //Install service after all files installed, if not a portable install
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then //Step happens before processing uninstall log
  begin
    UninstallProgressForm.StatusLabel.Caption := 'Resetting Network DNS...';
    ResetNetworkDNS(); //Reset Network DNS to default

    UninstallProgressForm.StatusLabel.Caption := 'Stopping Tray App...';
    KillTrayApp(); //Stop the tray app if running

    UninstallProgressForm.StatusLabel.Caption := 'Uninstalling Service...';
    DoRemoveService(); //Stop and remove the service
  end;
end;