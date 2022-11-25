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
else {"Winget already installed!"}

#Configure WinGet - For documentation see: https://aka.ms/winget-settings
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json";
$settingsJson = 
@"
    {        
        "experimentalFeatures": {
          "experimentalMSStore": true,
        }
    }
"@;
$settingsJson | Out-File $settingsPath -Encoding utf8

#---------------------------------------------------------------------------------------------#


#Install Apps
$apps = @(
    @{name = "Microsoft.PowerToys" }
	,@{name = "RARLab.WinRAR" }
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
#Write-Output "Removing Apps"
#
#$apps = "*3DPrint*", "Microsoft.MixedReality.Portal"
#Foreach ($app in $apps)
#{
#  Write-host "Uninstalling:" $app
#  Get-AppxPackage -allusers $app | Remove-AppxPackage}
