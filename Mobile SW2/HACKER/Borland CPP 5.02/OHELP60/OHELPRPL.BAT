@echo off
goto StartHere

:Bat_Info
echo ************************************************************************
echo *    OHELPRPL.BAT
echo *
echo *    Installs OpenHelp 6.0. Use this batch file if you have
echo *    Borland C++ and Borland C++Builder installed on your computer.
echo *
echo *    If you have only Borland C++ installed, use OHELPNEW.BAT.
echo *
:Bat_Usage
echo *
echo *    This batch file requires two parameters. 
echo *     * The first parameter specifies the drive and directory in which 
echo *       BC5 is installed. Enter a colon with the drive letter, 
echo *       followed by the backslash and directory name, e.g. C:\BC5 
echo *     * The second parameter specifies the drive where Windows is 
echo *       installed. Enter the drive letter followed by a colon, 
echo *       e.g. D:
echo *
echo *    Usage:   OHELPNRPL param1 param2
echo *    Example: OHELPRPL C:\BC5 D:
echo *
echo ************************************************************************
goto AllDone

:StartHere
  if "%1" == "" goto Bat_Usage
  if "%1" == "?" goto Bat_Usage
  if "%1" == "/?" goto Bat_Usage
  if "%1" == "-?" goto Bat_Usage
  if "%1" == "/h" goto Bat_Usage
  if "%1" == "/H" goto Bat_Usage
  if "%1" == "-h" goto Bat_Usage
  if "%1" == "-H" goto Bat_Usage
  if "%2" == "" goto Bat_Usage

echo *    Copy OPENHELP.CFG to BC5\HELP
COPY %1\BIN\OPENHELP.CFG %1\HELP
 
echo *    Rename OpenHelp and CFG files in BC5\BIN
REN %1\BIN\OPENHELP.EXE OHLP5EXE.SAV
REN %1\BIN\OPENHELP.CFG OHLP5CFG.SAV
REN %1\BIN\BOPNHLP.CFG BOPNHLP.SAV

echo *    Copy OPENHELP.EXE and OPENHELP.IN_ to BC5\BIN
COPY OPENHELP.EXE %1\BIN
COPY OPENHELP.IN_ %1\BIN
ATTRIB -R %1\BIN\OPENHELP.EXE
ATTRIB -R %1\BIN\OPENHELP.IN_

echo *    Rename OPENHELP 5.0 .HLP, .TOC and .CNT files in BC5\HELP
REN %1\HELP\OPENHELP.HLP OHLP5HLP.SAV
REN %1\HELP\OPENHELP.CNT OHLP5CNT.SAV
REN %1\HELP\OPENHELP.TOC OHLP5TOC.SAV

echo *    Copy OPENHELP.HLP, OPENHELP.CNT, OPENHELP.MST and OPENHELP.TOC 
echo *    to BC5\HELP
COPY OPENHELP.HLP %1\HELP
COPY OPENHELP.CNT %1\HELP
COPY OPENHELP.MST %1\HELP
COPY OPENHELP.TOC %1\HELP
ATTRIB -R %1\HELP\OPENHELP.HLP 
ATTRIB -R %1\HELP\OPENHELP.CNT
ATTRIB -R %1\HELP\OPENHELP.MST
ATTRIB -R %1\HELP\OPENHELP.TOC

echo *    Rename *.CNT in BC5\HELP to *.SAV
REN %1\HELP\BC5MAIN.CNT BC5MAIN.SAV
REN %1\HELP\BCDOS.CNT BCDOS.SAV
REN %1\HELP\BCERRMSG.CNT BCERRMSG.SAV
REN %1\HELP\BCPP.CNT BCPP.SAV
REN %1\HELP\BCTOOLS.CNT BCTOOLS.SAV
REN %1\HELP\BCVDTREF.CNT BCVDTREF.SAV
REN %1\HELP\BCW.CNT BCW.SAV
REN %1\HELP\BWCC.CNT BWCC.SAV
REN %1\HELP\CLASSLIB.CNT CLASSLIB.SAV
REN %1\HELP\OCF.CNT OCF.SAV
REN %1\HELP\OWL50.CNT OWL50.SAV
REN %1\HELP\OWLEX.CNT OWLEX.SAV
REN %1\HELP\SCRIPT.CNT SCRIPT.SAV
REN %1\HELP\STL.CNT STL.SAV
REN %1\HELP\WINSYS.CNT WINSYS.SAV
REN %1\HELP\WORKSHOP.CNT WORKSHOP.SAV
REN %1\HELP\BCWJAVA.CNT BCWJAVA.SAV
REN %1\HELP\BCWPVCS.CNT BCWPVCS.SAV
REN %1\HELP\CG5.CNT CG5.SAV
REN %1\HELP\TOGETHER.CNT TOGETHER.SAV

echo *    Reset attribute on GID files to read/write and delete
ATTRIB -H %1\HELP\*.GID
DEL %1\HELP\*.GID

echo *    Copy *.CNT to BC5\HELP
COPY *.CNT %1\HELP

echo *    Run OPENHELP.EXE to create new INI file
%1\BIN\OPENHELP /I /P%1HELP /E%1\BIN

echo *    Merge the new INI file with the existing one
TYPE %1\BIN\OPENHELP.INI >> %2\PROGRA~1\COMMON~1\BORLAND\OPENHELP\OPENHELP.INI

echo *    Delete OPENHELP.INI
DEL %1\BIN\OPENHELP.INI

:AllDone

