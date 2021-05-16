@echo off

::###################################################################################################################################################

::###############################################
:: Create SCRIPT_DIR variable and set this batch file's file path.
::###############################################
:: The %~dp0 variable resolves to be the directory location of this batch file with a backslash (\) at the end.
:: For example, if the file path of this batch file is "C:\path\to\script.bat". Then, "%~dp0" equals "C:\path\to\".
set SCRIPT_DIR=%~dp0

::###################################################################################################################################################

:: Run Set-GoldenImageSettings.ps1 as Administrator.
powershell -NoProfile -ExecutionPolicy Bypass -Command "&{Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File %SCRIPT_DIR%Set-GoldenImageSettings.ps1' -Verb RunAs}"