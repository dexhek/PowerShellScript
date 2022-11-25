#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Sleep 1
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

#no errors throughout
$ErrorActionPreference = 'silentlycontinue'

#Install WinGet if not installed
$hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
if (!$hasPackageManager -or [version]$hasPackageManager.Version -lt [version]"1.10.0.0") {
    "Installing winget Dependencies"
    Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'

    $releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri $releases_url
    $latestRelease = $releases.assets | Where { $_.browser_download_url.EndsWith('msixbundle') } | Select -First 1

    "Installing winget from $($latestRelease.browser_download_url)"
    Add-AppxPackage -Path $latestRelease.browser_download_url
}
else {" "}

#Configure WinGet - For documentation see: https://aka.ms/winget-settings
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json";
$settingsJson = 
@"
    {        
        "experimentalFeatures": {
          "experimentalMSStore": true,
		  "uninstall": true,
		  "list": true
        }
    }
"@;
$settingsJson | Out-File $settingsPath -Encoding utf8

#---------------------------------------------------------------------------------------------#
#		Install/Uninstall Code
#---------------------------------------------------------------------------------------------#

#Install Apps
$apps = @(
    @{name = "RARLab.WinRAR" }
	#,@{name = "RARLab.WinRAR" }
);
Foreach ($app in $apps) {
    $listApp = winget list --exact -q $app.name
    if (![String]::Join("", $listApp).Contains($app.name)) {
        Write-host "Installing:" $app.name
        if ($app.source -ne $null) {
            winget install --exact --silent $app.name --source $app.source
        }
        else { winget install --exact --silent $app.name }
    }    
	else { Write-host "Skipping Install of " $app.name }}



#Remove Apps
$apps = @(
     @{name = "Microsoft.MSPaint"}
	,@{name = "Microsoft.GetHelp"}
	,@{name = "Microsoft.Getstarted"}
	,@{name = "Microsoft.Messaging"}
	,@{name = "Microsoft.Microsoft3DViewer"}
	,@{name = "Microsoft.MicrosoftOfficeHub"}
	,@{name = "Microsoft.MicrosoftSolitaireCollection"}
	,@{name = "Microsoft.NetworkSpeedTest"}                  
	,@{name = "Microsoft.Office.Lens"}                
	,@{name = "Microsoft.Office.OneNote"}
	,@{name = "Microsoft.Office.Sway"}
	,@{name = "Microsoft.OneConnect"}
	,@{name = "Microsoft.People"}
	,@{name = "Microsoft.Print3D"} 
	,@{name = "Microsoft.WindowsFeedbackHub"}
	,@{name = "Microsoft.WindowsMaps"}
	,@{name = "Microsoft.Xbox.TCUI"}
	,@{name = "Microsoft.XboxApp"}
	,@{name = "Microsoft.XboxGameOverlay"}
	,@{name = "Microsoft.XboxGamingOverlay"}
	,@{name = "Microsoft.XboxIdentityProvider"}
	,@{name = "Microsoft.XboxSpeechToTextOverlay"}
	,@{name = "Microsoft.ZuneMusic"}
	,@{name = "Microsoft.ZuneVideo"}
	,@{name = "AdobeSystemsIncorporated.AdobePhotoshopExpress"}
	,@{name = "*PowerAutomateDesktop*"}
	,@{name = "*CandyCrush*"}
	,@{name = "*Duolingo*"}	
	,@{name = "*EclipseManager*"}	
	,@{name = "*Facebook*"}	
	,@{name = "*FarmHeroesSaga*"}	
	,@{name = "*Flipboard*"}	
	,@{name = "*Netflix*"}	
	,@{name = "*Twitter*"}	
	,@{name = "*Todos*"}
	,@{name = "*Teams*"}	
	
);
Foreach ($app in $apps){  
  Get-AppxPackage -Name $app.name| Remove-AppxPackage
  Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app.name | Remove-AppxProvisionedPackage -Online
}

#Update Apps
Write-host "Updating installed apps:"
winget upgrade --all