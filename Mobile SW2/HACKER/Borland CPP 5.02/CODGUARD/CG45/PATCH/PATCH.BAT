@echo off
if "%1"=="" goto Usage
if "%1"=="/?" goto Usage
if "%1"=="/h" goto Usage
if "%1"=="/H" goto Usage
if "%1"=="-?" goto Usage
if "%1"=="-h" goto Usage
if "%1"=="-H" goto Usage
if "%1"=="?" goto Usage
if "%1"=="h" goto Usage
if "%1"=="H" goto Usage
rem Set Defaults
:Default
set bcdrive=c:
set bcdir=\bc45
set cddrive=d:
set patchdir=\patch
set windrive=c:
set winpath=\windows
set srcpath=c:\bc45\source
set examppath=c:\bc45\examples

rem Check Parameters
:ParameterSet
if not "%1"=="" set bcdrive=%1
if not "%2"=="" set bcdir=%2
if not "%3"=="" set cddrive=%3
if not "%4"=="" set windrive=%4
if not "%5"=="" set winpath=%5
if not "%6"=="" set srcpath=%6
if not "%7"=="" set examppath=%7
rem Check passed in parameters
:BC45Check
if not exist %bcdrive%%bcdir%\readme.txt goto Warning
if not exist %cddrive%%patchdir%\root.rtp goto Warning
if not exist %windrive%%winpath%\win.ini goto Warning

:Verify
@echo. 
@echo. 
@echo   The patch is about to be applied with this information: 
@echo. 
@echo      Borland C++ drive       = %bcdrive%
@echo      Borland C++ directory   = %bcdir%
@echo      CD Drive                = %cddrive%
@echo      Windows Drive           = %windrive%
@echo      Windows Directory       = %winpath%
@echo      Source Files Location   = %srcpath%
@echo      Example Files Location  = %examppath%
@echo.
@echo   This patch must not be run under Windows NT.  If you are
@echo   running Windows NT, you must boot DOS and restart.
@echo.
@echo   If this is not correct, or at any time you need to stop
@echo   the patch, press Control-C to quit.  If this is correct,
pause
cls

:Notice1
@echo.
@echo This batch file is intended to provide "up and running" ability for 4.50
@echo users who need to install CodeGuard but have not yet received their free
@echo update of Borland C++ 4.51 or 4.52.  Borland strongly recommends that you
@echo obtain your free update of Borland C++ by calling the Borland Order Desk
@echo at 1-800-645-4559 and reinstall at your earliest possible convenience. 
@echo Outside of North America, contact your local Borland representative.
@echo.
@echo If you experience any anomalous behavior after applying this patch, see
@echo the file INSTCG.TXT for more information.
@echo.
pause
cls

:TimeWarning
@echo.
@echo Depending on your CPU, hard disk speed, and how many features of Borland 
@echo C++ 4.5 you have installed, this patch will take between 20 minutes and 2
@echo hours to apply.  
@echo.
@echo.
@echo Depending on your configuration the patch program may report:
@echo     Warning wpt0015: Old File does not exist
@echo This is normal and does not indicate a failure.
@echo.
pause

rem Applies patches pre-dating Borland C++ 4.51 release
:Patch
%bcdrive%
cd %bcdir%
echo "Beginning Patch" > %bcdrive%%bcdir%\patch.log
echo Beginning Patch...
echo "Applying BC 4.5 Patch #1" >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\bc45p1 >> %bcdrive%%bcdir%\patch.log
echo "Applying BC 4.5 Patch #2" >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\bc45p2 >> %bcdrive%%bcdir%\patch.log
echo "Applying BC 4.5 Patch #3" >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\bc45p3 >> %bcdrive%%bcdir%\patch.log

rem Patches Pipeline and Root directory
echo "Applying Root Patch" >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\root >> %bcdrive%%bcdir%\patch.log
echo "Applying Pipeline Patch" >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\pipeline >> %bcdrive%%bcdir%\patch.log

rem Patches BIN directory
cd %bcdrive%%bcdir%\bin
echo "Applying Bin Patch" >> %bcdrive%%bcdir%\patch.log
echo Patching BIN Directory...
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\bin1 >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\bin2 >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\bin3 >> %bcdrive%%bcdir%\patch.log
echo Patching BIN Directory : 25% complete... 
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\bin4 >> %bcdrive%%bcdir%\patch.log
echo Patching BIN Directory : 50% complete...
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\bin5 >> %bcdrive%%bcdir%\patch.log
echo Patching BIN Directory : Done...
cd..

rem Patches BGI directory
cd %bcdrive%%bcdir%\bgi
echo "Applying BGI Patch" >> %bcdrive%%bcdir%\patch.log
echo Patching BGI Directory...
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\bgi >> %bcdrive%%bcdir%\patch.log
cd..

rem Patches DOC directory
cd %bcdrive%%bcdir%\doc
echo "Applying Doc Patch" >> %bcdrive%%bcdir%\patch.log
echo Patching DOC Directory... 
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\doc >> %bcdrive%%bcdir%\patch.log
cd..

rem Patches EXAMPLES directory
cd %examppath%
echo "Applying Examples Patch" >> %bcdrive%%bcdir%\patch.log
echo Patching EXAMPLES Directory...
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\examples >> %bcdrive%%bcdir%\patch.log
cd..

%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\delete >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\rdm >> %bcdrive%%bcdir%\patch.log

rem Patches EXPERT directory
cd %bcdrive%%bcdir%\expert
echo "Applying Expert Patch" >> %bcdrive%%bcdir%\patch.log
echo Patching EXPERT Directory...
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\expert >> %bcdrive%%bcdir%\patch.log
cd..

rem Patches INCLUDE directory
cd %bcdrive%%bcdir%\include
echo "Applying Include Patch" >> %bcdrive%%bcdir%\patch.log
echo Patching INCLUDE Directory... 
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\include >> %bcdrive%%bcdir%\patch.log
cd..

rem Patches LIB directory
cd %bcdrive%%bcdir%\lib
echo "Applying Lib Patch" >> %bcdrive%%bcdir%\patch.log
echo Patching LIB Directory... 
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\lib >> %bcdrive%%bcdir%\patch.log
cd..

rem Patches SOURCE trees
cd %srcpath%
echo "Applying Source Patch" >> %bcdrive%%bcdir%\patch.log
echo Patching SOURCE Directory...
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\AUTOSRC >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\CLSBSRC >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\DLLSRC >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\GUIDSRC >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\OBSLTSRC >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\REGSRC >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\OWLSRC >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\OCFSRC >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\BCLESRC >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\BOL32SRC >> %bcdrive%%bcdir%\patch.log
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\BOLESRC >> %bcdrive%%bcdir%\patch.log
cd ..

%windrive%
cd %winpath%
echo "Applying Windows Patch" >> %bcdrive%%bcdir%\patch.log
echo Patching WINDOWS Directory...
%cddrive%%patchdir%\rtpatch %cddrive%%patchdir%\WINDOWS >> %bcdrive%%bcdir%\patch.log

rem Cleanup
%bcdrive%
cd %bcdir%
rd OWL
rd OCF
rd BOLEUI
rd BOLEUI32
cd %bcdir%\source\ocf\bocole
del bole.ide
del bocolef.rc
del bocolef.def
copy %cddrive%%patchdir%\mainrdme %bcdrive%%cddir%\readme.txt
copy %cddrive%%patchdir%\mtrrdme %examppath%\owl\games\meteor\readme.txt
copy %cddrive%%patchdir%\blckrdme %examppath%\owl\games\blocks\readme.txt

goto End
%cddrive%%patchdir%

:Warning
@echo.
@echo.
@echo   WARNING! You have passed in an incorrect parameter list for this
@echo            batch file.  Please re-enter the command line.
@echo. 
@echo. 
pause
goto Usage

:Usage
@echo.
@echo Purpose:
@echo.
@echo This batch file updates Borland C++ 4.50 to version 4.51 to allow CodeGuard
@echo to be installed.  After running this batch file, you must run the CodeGuard
@echo installation program to install CodeGuard.  See also the file INSTCG.TXT
@echo for information on this patch.
@echo.
@echo Usage:
@echo.
@echo    %0 [bcdrive] [bcdir] [cddrive] [wdrive] [wpath] [spath] [epath]
@echo.
@echo        bcdrive is the drive where BC 4.50 is installed
@echo        bcdir is the directory where BC 4.50 is installed
@echo        cddrive is the drive you are patching from
@echo        wdrive is the drive where Windows, Win 95 or Win NT is installed
@echo        wpath is the path to where Windows, Win 95 or Win NT is installed
@echo        spath is the directory where BC 4.50 source is installed
@echo        epath is the directory where BC 4.50 examples is installed
@echo.
@echo  Ex: %0 c: \bc45 d: c: \windows c:\bc45\source c:\bc45\examples
@echo.

@echo.
goto Tail

:End
:Notice2
cls
@echo.
@echo This batch file is intended to provide "up and running" ability for 4.50
@echo users who need to install CodeGuard but have not yet received their free
@echo update of Borland C++ 4.51 or 4.52.  Borland strongly recommends that you
@echo obtain your free update of Borland C++ by calling the Borland Order Desk
@echo at 1-800-645-4559 and reinstall at your earliest possibly convenience. 
@echo Outside of North America, contact your local Borland representative.
@echo.
@echo If you experience any anomalous behavior after applying this patch, see
@echo the file INSTCG.TXT for more information.
@echo.
@echo You should now run %cddrive%\INSTALL\INSTALL.EXE to install CodeGuard
@echo.

:Tail
@echo.
@echo.
