@rem MAKEDISK.BAT for SatPro 430 Toshiba Access Panel
@rem by Clark Christensen
@rem 12-20-1996

@echo off
cls
echo.
echo.
echo.
echo MakeDisk for SatPro 430 Toshiba Access Panel requires 4 formatted
echo 1.44MB high density diskettes.  Would you like to continue?
askit
if errorlevel = 1 goto end


rem +++++++ check for the existence of all of the images +++++++++
if exist 430TAP1.PRG goto check2
cls
echo.
echo.
echo.
echo MakeDisk cannot find file 430TAP1.PRG
echo Extract downloaded archive into its own directory and run
echo MakeDisk again
goto end

:check2
if exist 430TAP2.PRG goto check3
cls
echo.
echo.
echo.
echo MakeDisk cannot find file 430TAP2.PRG
echo Extract downloaded archive into its own directory and run
echo MakeDisk again
goto end

:check3
if exist 430TAP3.PRG goto check4
cls
echo.
echo.
echo.
echo MakeDisk cannot find file 430TAP3.PRG
echo Extract downloaded archive into its own directory and run
echo MakeDisk again
goto end


:check4
if exist 430TAP4.PRG goto start
cls
echo.
echo.
echo.
echo MakeDisk cannot find file 430TAP4.PRG
echo Extract downloaded archive into its own directory and run
echo MakeDisk again
goto end


:start
ren 430TAP1.prg 430TAP1.EXE
ren 430TAP2.prg 430TAP2.EXE
ren 430TAP3.prg 430TAP3.EXE
ren 430TAP4.prg 430TAP4.EXE

@rem ++++++++++++ Check for partial session +++++++++++++++++
if "%toshmark%"=="" goto disk1
if "%toshmark%"=="disk2" goto resume
if "%toshmark%"=="disk3" goto resume
if "%toshmark%"=="disk4" goto resume


@rem ++++++++++++ Make Diskettes ++++++++++++++++++++++++++++
:disk1
echo.
echo.
echo.
echo Insert Diskette 1 into drive A: and
pause
cls
set toshmark=disk1
echo.
echo.
echo.
430TAP1 a:
if errorlevel 15 goto fail
if errorlevel 14 goto wp
if errorlevel 13 goto fail
if errorlevel 1 goto fail
cls
echo.
echo.
echo.
echo Disk 1 Complete

:disk2
echo.
echo.
echo.
echo Insert Diskette 2 into drive A: and
pause
cls
set toshmark=disk2
echo.
echo.
echo.
430TAP2 a:
if errorlevel 15 goto fail
if errorlevel 14 goto wp
if errorlevel 13 goto fail
if errorlevel 1 goto fail
cls
echo.
echo.
echo.
echo Disk 2 Complete

:disk3
echo.
echo.
echo.
echo Insert Diskette 3 into drive A: and
pause
cls
set toshmark=disk3
echo.
echo.
echo.
430TAP3 a:
if errorlevel 15 goto fail
if errorlevel 14 goto wp
if errorlevel 13 goto fail
if errorlevel 1 goto fail
cls
echo.
echo.
echo.
echo Disk 3 Complete


:disk4
echo.
echo.
echo.
echo Insert Diskette 4 into drive A: and
pause
cls
set toshmark=disk4
echo.
echo.
echo.
430TAP4 a:
if errorlevel 15 goto fail
if errorlevel 14 goto wp
if errorlevel 13 goto fail
if errorlevel 1 goto fail
cls
echo.
echo.
echo.
echo Disk 4 Complete


@rem +++++++++++++++++++++++ Cleanup and Finish +++++++++++++++++
ren 430TAP1.exe 430TAP1.prg
ren 430TAP2.exe 430TAP2.prg
ren 430TAP3.exe 430TAP3.prg
ren 430TAP4.exe 430TAP4.prg
goto finish


@rem ++++++++++++++++ Error handling & housekeeping +++++++++++++
:wp
cls
echo.
echo.
echo.
echo MakeDisk has detected that the diskette is write protected
echo Please switch diskettes, or remove write protection
echo Press Ctrl-C (Hold down the control key and press the letter "C") to quit or 
pause
cls
goto %toshmark%


:resume
cls
echo.
echo.
echo.
echo MakeDisk has detected an unfinished session.
echo Would you like to start over with the first diskette?
askit
if not errorlevel = 1 goto disk1
cls
goto %toshmark%

:fail
ren 430TAP1.exe 430TAP1.prg
ren 430TAP2.exe 430TAP2.prg
ren 430TAP3.exe 430TAP3.prg
ren 430TAP4.exe 430TAP4.prg
cls
echo.
echo.
echo.
echo MakeDisk operation failed
pause
goto end

:finish
cls
echo.
echo.
echo.
echo MakeDisk completed successfully
echo.
echo.
set toshmark=

:end
