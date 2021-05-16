<#
#####################################################################################################################################################

PURPOSE
Configure most settings needed for a Windows 10 Golden Image.

DESCRIPTION


#####################################################################################################################################################
#>

# Set list of AppX Provisioned packages to be uninstalled.
$AppXProvisionedToRemove = @(
    "Microsoft.549981C3F5F10" # Cortana offline app
    "Microsoft.BingWeather" # Bing Weather app
    "Microsoft.Getstarted" # First-time run app
    "Microsoft.Microsoft3DViewer" # 3D model viewer app
    "Microsoft.MicrosoftOfficeHub" # Office Online app
    "Microsoft.MicrosoftSolitaireCollection" # Solitaire games
    "Microsoft.MixedReality.Portal" # Augmented Reality app
    "Microsoft.Office.OneNote" # OneNote app
    "Microsoft.People" # People app
    "Microsoft.SkypeApp" # Consumer Skype app
    "Microsoft.Wallet" # Digital Waller app
    "microsoft.windowscommunicationsapps" # Mail and Calendar apps
    "Microsoft.WindowsFeedbackHub" # Feedback Hub app
    "Microsoft.Xbox.TCUI" # Xbox app
    "Microsoft.XboxApp" # Xbox app
    "Microsoft.XboxGameOverlay" # Xbox app
    "Microsoft.XboxGamingOverlay" # Xbox app
    "Microsoft.XboxIdentityProvider" # Xbox app
    "Microsoft.XboxSpeechToTextOverlay" # Xbox app
    "Microsoft.YourPhone" # Your Phone app
)

#####################################################################################################################################################

<#
# Stop Windows Updates.
Write-Warning -Message "Stopping Windows Updates."
Stop-Service -Name wuauserv -Force | Out-Null # Stop Windows Update service.
Set-Service -Name wuauserv -StartupType Disabled # Set Windows Update service to disabled to prevent restarting.
Stop-Service -Name bits | Out-Null -Force # Stop bits service.
#>

# Import registry keys to set various settings and local GPOs.
Write-Warning -Message "Importing registry keys to set various settings and local GPOs." # Write message in console window.
$RegistryFilePath = $PSScriptRoot + "\Golden Image Registry Keys.reg"
& {reg import "$RegistryFilePath"}

# Delete Microsoft Edge shortcut.
Write-Warning -Message "Deleting Microsoft Edge Desktop shortcut." # Write message in console window.
Remove-Item -Path "C:\Users\Public\Desktop\Microsoft Edge.lnk" -Force # Delete shortcut.

# Set time zone to Central Standard Time.
Write-Warning -Message "Setting time zone to Central Standard Time." # Write message in console window.
cmd /c tzutil /s "Central Standard Time" # Set time zone to "Central Standard Time."

# Change power plan settings.
Write-Warning -Message "Setting power options." # Write message in console window.
powercfg /change monitor-timeout-ac 0 # Set monitor timeout to "Never" while plugged in.
powercfg /change disk-timeout-ac 0 # Set hard disk timeout to "Never" while plugged in.

# Uninstall OneDrive.
Write-Warning -Message "Uninstalling OneDrive." # Write message in console window.
Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue # Kill OneDrive.exe process and ignore any errors.
Start-Process -FilePath "$env:windir\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait # Uninstall OneDrive.

# Install Microsoft .NET 3.5.
Write-Warning -Message "Installing Microsoft .NET 3.5." # Write message in console window.
Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" | Out-Null # Install .Net 3.5.

# Uninstall Windows AppX packages.
Write-Warning -Message "Uninstalling all AppX packages." # Write message in console window.
Import-Module AppX # Import AppX PowerShell module.
Import-Module Dism # Import Dism PowerShell module.
Get-AppxPackage -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue # Get a list of all AppX packages, uninstall, and ignore any errors.

# Uninstall certain AppX Provisioned packages.
Write-Warning -Message "Uninstalling unnecessary AppX Provisioned packages."
$AllAppXProvisioned = (Get-AppXProvisionedPackage -Online).DisplayName # Get list of all AppX Provisioned packages.
$AllAppXProvisioned | ForEach-Object -Process { # For every item in the AppX Provisioned packages list, do the following.
    if ($_ -in $AppXProvisionedToRemove) { # If the current item is in the AppX Provisioned packages list, do the following.
        Get-AppxPackage -AllUsers $_ | Remove-AppxPackage # Remove the current AppX Provisioned package.
    } # Close if statement.
} # Close ForEach-Object -Process statement.

# Download and install available Windows Updates from Microsoft Update servers.
Write-Warning -Message "Starting download and install of Windows Updates from Microsoft Servers." # Write message in console window.
Stop-Service -Name wuauserv  -Force | Out-Null # Stop Windows Update service.
Set-Service -Name wuauserv -Status Stopped -StartupType Disabled # Set Windows Update service to disabled to prevent restarting.
Stop-Service -Name bits -Force | Out-Null # Stop bits service.
cmd.exe /c rmdir /s /q "C:\Windows\SoftwareDistribution" # Delete "SoftwareDistribution" folder.
Set-Service -Name wuauserv -Status Running -StartupType Automatic # Start Windows Update service.
Start-Sleep -Seconds 2 # Allow time for service to start.
cmd /c UsoClient.exe StartInteractiveScan # Initiate scan, download, and installation of Windows Updates.
Write-Warning -Message "Opening Windows Updates."
Start-Sleep -Seconds 2 # Allow message to be read.
Start-Process -FilePath ms-settings:windowsupdate # Open Windows Updates menu directly.
Write-Host # Write a blank line in the console.
Write-Host "The script is complete." -ForegroundColor Cyan
Pause # Keep the console window open until it's manually closed.


<#
$AllAppXProvisioned = (Get-AppXProvisionedPackage -Online).PackageName
$AllAppXProvisioned | ForEach-Object -Process {
    if ([Regex]::Match($_, '(?<=\.)(.*?)(?=_)').Value -notin $AppXProvisionedDontRemove) {
        Write-Host "$_ is not included in the list. Will uninstall it." -ForegroundColor Red
        #Remove-AppXProvisionedPackage -Online -PackageName $_
    }
    else {
        Write-Host "$_ is included in the list. Will not uninstall it." -ForegroundColor Cyan
        #Do nothing.
    }
}


<#
$AllAppXProvisioned = (Get-AppXProvisionedPackage -Online).PackageName
$AllAppXProvisioned | ForEach-Object -Process {
    if ($_ -notin $AppXProvisionedDontRemove) {
        Write-Host "$_ not included. will uninstall."
        #Remove-AppXProvisionedPackage -Online –PackageName $_
    }
    else {
        Write-Host "$_ included. Will not uninstall."
    }
}

#>


<#
# Set list of Provisioned AppX packages that should not be removed.
$AppXProvisionedDontRemove = @(
    "DesktopAppInstaller" # Used to install Win32 apps from the Microsoft Store.
    "GetHelp" # Built-in help app.
    "MicrosoftStickyNotes" # Sticky Notes app
    "MSPaint" # MS Paint app
    "StorePurchaseApp" # For in-app purchases
    "VCLibs"
    "WebMediaExtensions"
    "Windows.Photos" # Built-in Windows Photos app
    "WindowsAlarms" # Built-in Windows clock app
    "WindowsCalculator" # Built-in Windows Calculator app
    "WindowsCamera" # Built-in Windows camera app
    "WindowsMaps" # Built-in Windows maps app
    "WindowsSoundRecorder" # Built-in sound recorder app
    "WindowsStore" # Windows Store app
    "ZuneMusic" # Built-in Windows music app
    "ZuneVideo" # Built-in Windows video app
)
#>


<#
$AppXProvisionedDontRemove = @(
    "DesktopAppInstaller"
    "GetHelp"
)
#>

<#
$AllAppXProvisioned = (Get-AppXProvisionedPackage -Online).DisplayName
$AllAppXProvisioned | ForEach-Object -Process {
    if ([Regex]::Match($_, '(?<=\.)(.*?)(?=_)').Value -notin $AppXProvisionedDontRemove) {
        Write-Host "$_ is not included in the list. Will uninstall it." -ForegroundColor Red
        #Remove-AppXProvisionedPackage -Online -PackageName $_
    }
    else {
        Write-Host "$_ is included in the list. Will not uninstall it." -ForegroundColor Cyan
        #Do nothing.
    }
}
#>

<#
# Uninstall certain AppX Provisioned packages.
Write-Warning -Message "Uninstalling unnessary AppX Provisioned packages."
$AllAppXProvisioned = (Get-AppXProvisionedPackage -Online).DisplayName
$AllAppXProvisioned | ForEach-Object -Process {
    if ($_ -in $AppXProvisionedToRemove) {
        Write-Host "$_ is included in the list. Will uninstall it." -ForegroundColor Cyan
        #Remove-AppXProvisionedPackage -Online -PackageName $_
        Get-AppxPackage -AllUsers $_ | Remove-AppxPackage
    }
    else {
        Write-Host "$_ is not included in the list. Will not uninstall it." -ForegroundColor Red
        #Do nothing.
    }
}
#>