@echo off
cls
btv -c 0.ida
btv 0.ida idachk.tmp
if errorlevel = 1 goto Error
del 0.ida
rename idachk.tmp 0.ida
idacomp 0.ida
goto Ex
:Error
echo .
echo .	Error during validation
echo .
:Ex
