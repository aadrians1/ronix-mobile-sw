:start
echo off
cls
echo.
echo.
echo.
echo.                 
echo                    
echo.                        
echo.
echo.
echo.                           
echo.                             C35_21    KALBA
echo.                            
echo.
echo.
echo.                          1.   FLASH LANG C35_21
echo.
echo.                          
echo.
echo.                          Q.    ISEITI I DOSA
echo.
echo.
choice /c:12Q /n
if errorlevel 3 goto end

if errorlevel 1 goto one

:one
cls
Swup.exe 21.xbi /nocheck
CLS
goto start



:end
cls
EXIT
