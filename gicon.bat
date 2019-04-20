::---------------------------------------------------------------------------------------::
:: This script will modify the Windows Explorer sidebar to include an icon for Google    ::
:: Drive. It does this with a little registry tweak and is completely reversible and non-::
:: invasive. Run without any arguments to see the help prompt. This script is also fully ::
:: scriptable in itself, so you can feel free to include it in other scripts if you'd    ::
:: like.                                                                                 ::
::---------------------------------------------------------------------------------------::


@echo off
::Test for admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
	goto main
) else (
    echo This script must be run as Administrator
	exit /B
)
exit /B

:main
setlocal EnableExtensions 
setlocal EnableDelayedExpansion

::Initialize argument array
set argc=0

::Parse passed arguments into array
for %%x in (%*) do Set /A argc+=1

::Initialize variables
set parameters=%1
set loc=%2

::Check if enough parameters were passed to be functional
if %argc% GEQ 3 (
	echo Invalid parameters 
	goto help
)
if not defined parameters (
	goto help
)

::Perform login on passed arguments to determine program control flow and call functions accordingly
if "%parameters%" == "-i" (
	call :importKeys
	endlocal
	exit /B
) else (
	if "%parameters%" == "-r" (
		call :removeKeys
		exit /B
	)
)
echo Invalid argument
goto help

::Default to calling this HELP function and exiting for safety
:help
echo.
echo  -i [CUSTOM_PATH]     install icon 
echo  -r                   remove icon 
echo.
echo Custom path should be quote wrapped. Leave blank for default Google Drive location.
echo.
endlocal
exit /B

:importKeys
::Check if requested storage provider is installed on system. This prevents the installation of a blank or corrupted icon into the registry
if not exist "C:\Program Files\Google\Drive\googledrivesync.exe" (
	echo Google Drive is not installed or it could not be located
	echo.
	echo NOTE: Only the default install location for Backup and Sync is supported
	endlocal
	exit /B
)

::Check if a sync directory was defined by user. If not, use the default path, otherwise set variables accordingly
if not defined loc (
	echo Custom location not set...using default path
	set loc="%userprofile%\Google Drive"
) else (
	::Parse user passed path to handle trailing backslash. This reduces errors and allows the user some syntactical freedom
	if "!loc:~-2,-1!" == "\" (
		set loc=!loc:~0,-2!"
	)
)

::Generate a unique GUID out of a hexidecimal base
::Credit for this snippet goes to @RedVentures
echo Generating GUID
set "xGUID="
for /L %%n in (1,1,32) do (
	if "%%~n"=="9"  set "xGUID=!xGUID!-"
	if "%%~n"=="13" set "xGUID=!xGUID!-"
	if "%%~n"=="17" set "xGUID=!xGUID!-"
	if "%%~n"=="21" set "xGUID=!xGUID!-"
	set /a "xValue=!random! %% 16"
	if "!xValue!"=="10" set "xValue=A"
	if "!xValue!"=="11" set "xValue=B"
	if "!xValue!"=="12" set "xValue=C"
	if "!xValue!"=="13" set "xValue=D"
	if "!xValue!"=="14" set "xValue=E"
	if "!xValue!"=="15" set "xValue=F"
	set "xGUID=!xGUID!!xValue!"
)
::Save GUID and storage provider information into a portable database for referencing later during uninstallation
echo Saving GUID
echo. >> providers.txt
echo %xGUID%,Google Drive >> providers.txt

::Merge registry keys and values into corresponding hives. Only the hive CLSID needs to be unique. The SZ CLSID is reusable. 
reg add HKCU\Software\Classes\CLSID\{%xGUID%} /ve /t REG_SZ /d "Google Drive" /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\DefaultIcon /ve /t REG_EXPAND_SZ /d "C:\Program Files\Google\Drive\googledrivesync.exe,0" /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%} /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0x1 /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%} /v SortOrderIndex /t REG_DWORD /d 0x42 /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\InProcServer32 /ve /t REG_EXPAND_SZ /d %%systemroot%%\system32\shell32.dll /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\Instance /v CLSID /t REG_SZ /d {0E5AAE11-A475-4c5b-AB00-C66DE400274E} /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\Instance\InitPropertyBag /v Attributes /t REG_DWORD /d 0x11 /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\Instance\InitPropertyBag /v TargetFolderPath /t REG_EXPAND_SZ /d %loc%\ /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\ShellFolder /v FolderValueFlags /t REG_DWORD /d 0x28 /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\ShellFolder /v Attributes /t REG_DWORD /d 0xF080004D /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{%xGUID%} /ve /t REG_SZ /d "Google Drive" /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {%xGUID%} /t REG_DWORD /d 0x1 /f
endlocal
exit /B

:removeKeys
::Function to remove icons. Load database of installed providers, parse GUIDs and delete corresponding registry keys
for /F "tokens=*" %%A IN (providers.txt) DO (
	set "current_provider=%%A"
	for /F "tokens=1,2 delims=," %%Y in ("!current_provider!") do (
		set "xGUID=%%Y"
		reg delete HKCU\Software\Classes\CLSID\{!xGUID!} /va /f
	)
)
endlocal
exit /B