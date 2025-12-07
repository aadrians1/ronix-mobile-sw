@echo off
:
:	Use this file to make sure that you'll not lose
:	your work (each time you exit IDA, a backup copy will be done)
:
ida %1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 1 goto End
:
:	IDA returns	0 -> normal exit (database is in correct state)
:			1 -> fatal error
:			2 -> -? switch encountered in command line
:			3 -> User pressed Esc at 'About' box
:			4 -> Obsolete database format
:			5 -> Database is not closed
:		    other -> fatal errors
:
:MakeBackup
echo ...
echo Making a backup copy...
:
:	You may put here your own commands to make a backup copy
:
pkzip -u idabak.zip 0.ida 1.ida names.ida $segs.ida $segregs.ida
:End
