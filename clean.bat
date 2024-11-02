@echo off
color 4
echo Cleaning up system files...

REM Check for administrative privileges
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin

REM Check if browsers are open (e.g., Chrome)
tasklist | find /i "chrome.exe" >nul
if not errorlevel 1 (
    echo Please close all browsers before running this script.
    pause
    exit /b
)

REM Create a system restore point
echo Creating a system restore point...
powershell.exe -Command "Checkpoint-Computer -Description 'Pre-Cleanup Restore Point' -RestorePointType 'MODIFY_SETTINGS'"

REM Clear Recycle Bin
echo Emptying Recycle Bin...
rd /s /q %systemdrive%\$Recycle.Bin

REM Clear Windows Temp folder
echo Clearing Windows Temp folder...
del /s /f /q C:\Windows\Temp\*.*
rd /s /q C:\Windows\Temp
md C:\Windows\Temp

REM Clear Prefetch folder
echo Clearing Prefetch folder...
del /s /f /q C:\Windows\Prefetch\*.*

REM Clear User Temp folder
echo Clearing User Temp folder...
del /s /f /q %temp%\*.*
rd /s /q %temp%
md %temp%

REM Clear Temporary Internet Files
echo Clearing Temporary Internet Files...
rd /s /q "%userprofile%\AppData\Local\Microsoft\Windows\INetCache"
md "%userprofile%\AppData\Local\Microsoft\Windows\INetCache"

REM Clear Cookies
echo Clearing Cookies...
rd /s /q "%userprofile%\AppData\Local\Microsoft\Windows\INetCookies"
md "%userprofile%\AppData\Local\Microsoft\Windows\INetCookies"

REM Clear Recent Files
echo Clearing Recent Files...
rd /s /q "%userprofile%\Recent"
md "%userprofile%\Recent"

REM Clear Print Spooler Files
echo Clearing Print Spooler Files...
rd /s /q C:\Windows\System32\spool\PRINTERS
md C:\Windows\System32\spool\PRINTERS

REM Clear Windows Update Cache
echo Clearing Windows Update cache...
net stop wuauserv
rd /s /q "C:\Windows\SoftwareDistribution\Download"
net start wuauserv

REM Run Disk Cleanup
echo Running Disk Cleanup...
cleanmgr /sagerun:1

REM Clear Pagefile (set to clear on shutdown)
echo Clearing pagefile...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 1 /f

REM Clear Event Logs
for /F "tokens=*" %%G in ('wevtutil.exe el') DO (call :do_clear "%%G")
echo.
echo Event Logs have been cleared!

goto theEnd

:do_clear
echo Clearing event log %1
wevtutil.exe cl %1
goto :eof

:noAdmin
echo You must run this script as an Administrator!
pause
exit /b

:theEnd
echo Cleanup complete! Press any key to exit.
pause
exit