echo off
rem  SOURCER and BIOS Pre-Processor
rem    Information Viewer and optional installation 
:start
if not exist infosrb.exe goto done2
infosrb -b
if errorlevel 254 goto done
if errorlevel 32 goto demo
echo 컴컴컴컴 Transfering Files 컴컴컴컴
if errorlevel 26 goto disk26
if errorlevel 25 goto disk25
if errorlevel 24 goto disk24
if errorlevel 22 goto disk22
if errorlevel 21 goto disk21
if errorlevel 20 goto disk20
if errorlevel 18 goto disk18
if errorlevel 17 goto disk17
if errorlevel 16 goto disk16
if errorlevel 14 goto disk14
if errorlevel 13 goto disk13
if errorlevel 12 goto disk12
if errorlevel 9 goto disk9
if errorlevel 8 goto disk8
if errorlevel 6 goto disk6
if errorlevel 4 goto disk4
if errorlevel 2 goto disk2
if errorlevel 1 goto disk1
goto done

:disk26
g:
if exist \sourcer\sr.exe goto skipgc
md \sourcer
:skipgc
copy c:*.* \sourcer
cd \sourcer
goto unzipit
:disk25
g:
if exist \sourcer\sr.exe goto skipgb
md \sourcer
:skipgb
copy b:*.* \sourcer
cd \sourcer
goto unzipit
:disk24
g:
if exist \sourcer\sr.exe goto skipga
md \sourcer
:skipga
copy a:*.* \sourcer
cd \sourcer
goto unzipit
:disk22
f:
if exist \sourcer\sr.exe goto skipfc
md \sourcer
:skipfc
copy c:*.* \sourcer
cd \sourcer
goto unzipit
:disk21
f:
if exist \sourcer\sr.exe goto skipfb
md \sourcer
:skipfb
copy b:*.* \sourcer
cd \sourcer
goto unzipit
:disk20
f:
if exist \sourcer\sr.exe goto skipfa
md \sourcer
:skipfa
copy a:*.* \sourcer
cd \sourcer
goto unzipit
:disk18
e:
if exist \sourcer\sr.exe goto skipec
md \sourcer
:skipec
copy c:*.* \sourcer
cd \sourcer
goto unzipit
:disk17
e:
if exist \sourcer\sr.exe goto skipeb
md \sourcer
:skipeb
copy b:*.* \sourcer
cd \sourcer
goto unzipit
:disk16
e:
if exist \sourcer\sr.exe goto skipea
md \sourcer
:skipea
copy a:*.* \sourcer
cd \sourcer
goto unzipit
:disk14
d:
if exist \sourcer\sr.exe goto skipdc
md \sourcer
:skipdc
copy c:*.* \sourcer
cd \sourcer
goto unzipit
:disk13
d:
if exist \sourcer\sr.exe goto skipdb
md \sourcer
:skipdb
copy b:*.* \sourcer
cd \sourcer
goto unzipit
:disk12
d:
if exist \sourcer\sr.exe goto skipda
md \sourcer
:skipda
copy a:*.* \sourcer
cd \sourcer
goto unzipit
:disk9
c:
if exist \sourcer\sr.exe goto skipcb
md \sourcer
:skipcb
copy b:*.* \sourcer
cd \sourcer
goto unzipit
:disk8
c:
if exist \sourcer\sr.exe goto skipca
md \sourcer
:skipca
copy a:*.* \sourcer
cd \sourcer
goto unzipit
:disk6
b:
copy c:*.* b:
goto unzipit
:disk4
b:
copy a:*.* b:
goto unzipit
:disk2
a:
copy c:*.* a:
goto unzipit
:disk1
a:
copy b:*.* a:
:unzipit
echo 컴컴컴컴 Uncompressing files 컴컴컴컴
pkunzip srfiles.zip
goto start
:demo
echo 컴컴컴컴 Loading Sourcer 컴컴컴컴
if not exist sr.exe goto nofile
sr testyn.exe
if not exist testyn.lst goto donedemo
echo �
echo   The demo is now complete.  Note the output file created contains the listing
echo   created by Sourcer.  After exiting the information menu, this may be printed
echo   or examined with your editor.
goto donedemo
:nofile
echo �
echo   Cannot locate Sourcer (SR.EXE).  
:donedemo
echo �
pause
echo 컴컴컴컴 Returning to Info Menu 컴컴컴컴
goto start
:done2
echo  �
echo   INFOSRB.EXE was not found on the default drive.  Insert the master 
echo   diskette  in the floppy drive  and set the default diskette to the
echo   same drive.  For example, if the diskette is in drive A, then:
echo �
echo            at the DOS prompt enter     A:
echo            then enter                  README
echo �
:done
echo �
