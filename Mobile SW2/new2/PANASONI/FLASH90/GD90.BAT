@echo off
:inicio
cls
cd\flash90
echo.
echo Software for Flash Panasonic GD90 by Aikon GsM TeAm (c) 2000
echo. 
echo 1. Flash Intel
echo 2. Flash Atmel
choice /n /c1,2 Select the flash type:

if errorlevel 2 goto atmel
if errorlevel 1 goto intel

goto error

:intel
go gad90a12
goto final

:atmel
go gad90b12
goto final 

:error
echo Please select your flash type...
pause>nul
goto inicio

:final
cls
echo Aikon GsM TeAm (c) 2000

