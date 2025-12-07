@echo off
btc 0.ida idabase.tmp
if errorlevel = 1 goto Error
copy idabase.tmp 0.ida
del idabase.tmp
goto Ex
:Error
echo .
echo .  Compression failed.
echo .
:Ex
