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
set service=%2
set loc=%3
set id=%~4


::Check if enough parameters were passed to be functional
if %argc% GEQ 5 (
	echo Invalid parameters 
	goto help
)
if not defined parameters (
	goto help
)

::Parse services and set variables
::Service creation is done simply using an IF statement. The argument can be anything other than those
::already reserved. Variables need to include a "service_path" linking to the main executable for the
::selected service and a "service_id" which is any name for the service. 
::OPTIONALLY...generate a default sync location in the block below. This is not needed for the script
::to work normally and errors are handled gracefully should you leave this out. 
if "%service%" == "g" (
	set service_path=C:\Program Files\Google\Drive\googledrivesync.exe
	set service_id=Google Drive
)
if "%service%" == "t" (
	set service_path=%localappdata%\Tresorit\v0.8\Tresorit.exe
	set service_id=Tresorit
) 
if "%service%" == "e" (
	set service_path=%localappdata%\ExpanDriveapp\ExpanDrive.exe
	if not defined id (
		echo ERROR: ExpanDrive requires a service ID
		goto help
	)
	set service_id=%id%
) 
::=========================
::ADD OTHER SERVICES HERE
::=========================

::Perform logic on passed arguments to determine program control flow and call functions accordingly
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

::--------------------------------::
::      FUNCTION LIBRARY          ::
::------------------------------- ::

::Default to calling this HELP function and exiting for safety
:help
echo.
echo  -i [g^|t^|e] [CUSTOM_PATH] [SERVICE_ID]   	install icon 
echo  -r                   							remove icon 
echo.
echo Custom path should be quote wrapped. Leave blank for default location.
echo Service ID is the name you want to display on the File Explorer sidebar. It is 
echo only needed for ExpanDrive and will be ignored for all other services.
echo.
endlocal
exit /B

:importKeys
::Check if requested storage provider is installed on system. This prevents the installation of a blank or corrupted icon into the registry
if not exist "%service_path%" (
	echo %service_id% is not installed or it could not be located
	echo.
	echo NOTE: Only the default install location is supported
	endlocal
	exit /B
)

::Check if a sync directory was defined by user. If not, use the default path, otherwise set variables accordingly
::DEFINE DEFAULT SYNC LOCATIONS HERE
if not defined loc (
	if "!service!" == "g" (
		echo Custom location not set...using default path
		set loc="%userprofile%\Google Drive"
	) 
	if "!service!" == "t" (
		echo Custom location not set...using default path
		set loc="T:"
	)
	if "!service!" == "e" (
		echo ERROR: ExpanDrive requires a custom location to be set
		goto help
	)
	else (
		echo Invalid location
		goto help
	)
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
echo %xGUID%,%service_id% >> providers.txt

::Merge registry keys and values into corresponding hives. Only the hive CLSID needs to be unique. The SZ (NUL) CLSID is reusable. 
reg add HKCU\Software\Classes\CLSID\{%xGUID%} /ve /t REG_SZ /d "%service_id%" /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\DefaultIcon /ve /t REG_EXPAND_SZ /d "%service_path%,0" /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%} /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0x1 /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%} /v SortOrderIndex /t REG_DWORD /d 0x42 /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\InProcServer32 /ve /t REG_EXPAND_SZ /d %%systemroot%%\system32\shell32.dll /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\Instance /v CLSID /t REG_SZ /d {0E5AAE11-A475-4c5b-AB00-C66DE400274E} /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\Instance\InitPropertyBag /v Attributes /t REG_DWORD /d 0x11 /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\Instance\InitPropertyBag /v TargetFolderPath /t REG_EXPAND_SZ /d %loc%\ /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\ShellFolder /v FolderValueFlags /t REG_DWORD /d 0x28 /f
reg add HKCU\Software\Classes\CLSID\{%xGUID%}\ShellFolder /v Attributes /t REG_DWORD /d 0xF080004D /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{%xGUID%} /ve /t REG_SZ /d "%service_id%" /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {%xGUID%} /t REG_DWORD /d 0x1 /f
endlocal
exit /B

:removeKeys
::Function to remove icons. Load database of installed providers, parse GUIDs and delete corresponding registry keys
for /F "tokens=*" %%A IN (providers.txt) DO (
	set current_provider=%%A
	set current_guid=!current_provider:~0,36!
	reg delete HKCU\Software\Classes\CLSID\{!current_guid!} /va /f
)
endlocal
exit /B