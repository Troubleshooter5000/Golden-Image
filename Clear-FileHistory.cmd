@echo off

::###################################################################################################################################################
::
:: PURPOSE
:: Delete all File History in the Windows 10 Golden Image prior to Sysprep.
::
:: DESCRIPTION
:: A user's File History can persist through Sysprep and become a part of the Default Profile. Then, all new user profiles that are created
:: will have this File History by default. This script should clear all history and should be ran near the end of the image prepping process.
::
::###################################################################################################################################################

:: Delete all items in locations where file history is stored.
echo Clearing user File History.

:: Delete files/shortcuts in these locations.
del /f /q %APPDATA%\Microsoft\Windows\Recent\*
del /f /q %APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*
del /f /q %APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*

:: Delete all subkeys under these registry keys.
reg delete HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f > nul
reg delete HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths /va /f > nul
echo Complete.
echo.
pause