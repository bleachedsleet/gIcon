::---------------------------------------------------------------------------------------::
:: This script will modify the Windows Explorer sidebar to include an icon for Google    ::
:: Drive. It does this with a little registry tweak and is completely reversible and non-::
:: invasive. Run without any arguments to see the help prompt. This script is also fully ::
:: scriptable in itself, so you can feel free to include it in other scripts if you'd    ::
:: like.                                                                                 ::
::---------------------------------------------------------------------------------------::


@echo off
setlocal EnableExtensions EnableDelayedExpansion
net session >nul 2>&1
if %errorLevel% == 0 (
	goto main
) else (
    echo Run this script as Admin and try again
    exit /B
)
exit /B

:main
set argc=0
for %%x in (%*) do Set /A argc+=1
set parameters=%1
set loc=%2
if %argc% GEQ 3 (
	echo Invalid parameters 
	goto help
)
if not defined parameters (
	goto help
)
if "%parameters%" == "-i" (
	call :importKeys
	exit /B
) else (
	if "%parameters%" == "-r" (
		call :removeKeys
		exit /B
	)
)
echo Invalid argument
goto help

:help
echo.
echo  -i [CUSTOM_PATH]     install icon 
echo  -r                   remove icon 
echo.
echo Custom path should be quote wrapped. Leave blank for default Google Drive location.
echo.
exit /B

:importKeys
if not defined loc (
	echo Custom location not set...using default path
	set loc="%userprofile%\Google Drive"
) else (
	if "!loc:~-2,-1!" == "\" (
		set loc=!loc:~0,-2!"
	)
)
reg add HKCU\Software\Classes\CLSID\{9499128F-5BF8-4F88-989C-B5FE5F058E79} /ve /t REG_SZ /d "Google Drive" /f
reg add HKCU\Software\Classes\CLSID\{9499128F-5BF8-4F88-989C-B5FE5F058E79}\DefaultIcon /ve /t REG_EXPAND_SZ /d "C:\Program Files\Google\Drive\googledrivesync.exe,0" /f
reg add HKCU\Software\Classes\CLSID\{9499128F-5BF8-4F88-989C-B5FE5F058E79} /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0x1 /f
reg add HKCU\Software\Classes\CLSID\{9499128F-5BF8-4F88-989C-B5FE5F058E79} /v SortOrderIndex /t REG_DWORD /d 0x42 /f
reg add HKCU\Software\Classes\CLSID\{9499128F-5BF8-4F88-989C-B5FE5F058E79}\InProcServer32 /ve /t REG_EXPAND_SZ /d %%systemroot%%\system32\shell32.dll /f
reg add HKCU\Software\Classes\CLSID\{9499128F-5BF8-4F88-989C-B5FE5F058E79}\Instance /v CLSID /t REG_SZ /d {0E5AAE11-A475-4c5b-AB00-C66DE400274E} /f
reg add HKCU\Software\Classes\CLSID\{9499128F-5BF8-4F88-989C-B5FE5F058E79}\Instance\InitPropertyBag /v Attributes /t REG_DWORD /d 0x11 /f
reg add HKCU\Software\Classes\CLSID\{9499128F-5BF8-4F88-989C-B5FE5F058E79}\Instance\InitPropertyBag /v TargetFolderPath /t REG_EXPAND_SZ /d %loc%\ /f
reg add HKCU\Software\Classes\CLSID\{9499128F-5BF8-4F88-989C-B5FE5F058E79}\ShellFolder /v FolderValueFlags /t REG_DWORD /d 0x28 /f
reg add HKCU\Software\Classes\CLSID\{9499128F-5BF8-4F88-989C-B5FE5F058E79}\ShellFolder /v Attributes /t REG_DWORD /d 0xF080004D /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{9499128F-5BF8-4F88-989C-B5FE5F058E79} /ve /t REG_SZ /d "Google Drive" /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {9499128F-5BF8-4F88-989C-B5FE5F058E79} /t REG_DWORD /d 0x1 /f
exit /B

:removeKeys
reg delete HKCU\Software\Classes\CLSID\{9499128F-5BF8-4F88-989C-B5FE5F058E79} /va /f
exit /B