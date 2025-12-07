@goto program

		Programmer initialization file
		------------------------------

Description:

Reading initialization file:
1. given by the commandline: "/iFilename"
2. "uniprog.ini" in current directory
3. "uniprog.ini" in directory of "uniprog.exe"

@Lines without '=' or with '@' as the first character are comments.
Name must be defined first.
Then all parameters collect for this device until next Name found.
All not defined parameters are disabled.
Unknown parameters gives an error output and the program is terminated.
Additional characters are ignored:
@ "Flash= 1024" and "FLASHSIZE =1024Bytes" are the same
If no FLASH is defined, Erase is not avaiable.
Fuses are collected in the given order (max 8 fuses: 0..7)
Following parameters are valid:		default settings:
Connection Parameters:	BAud		9600
			COm		1
			PRog		0
Device Parameters:	EEprom		0
			FLash		0
			FUse		"" (all 8)
			LOck		0
			NAme		""
			SIgnature	""
			TYpe		"" (programming algorithm)
			VPp		0
Following program algorithm are implemented:
1051:	89C1051, 89C2051, 89C4051
1200:	90S1200, 90S2313
1200E:	EEPROM of 90S1200, 90S2313
EEPROM-hex files are default with .eep extension
EEPROM: read, write after FLASH, Checksum separat calculated
-------------------------------------------------------------------------
Definitions:

COM		= 2
Baud		= 57600
@Programmer	= 07a612	Checksum programmer, warning if not equal
Timeout		= 200		Waittime during blankcheck or 
				checksum calculation (* 1/18 seconds)
-------------------------------------------------------------------------
Name		= 89C1051
Type		= 1051
VPP		= 12		float
Flash		= 1024		decimal
Signature	= 1E11		hex
Lock		= 2
---------------------------------------
Name		= 89C2051
Type		= 1051
VPP		= 12
Flash		= 2048
Signature	= 1E21
Lock		= 2
---------------------------------------
Name		= 89C4051
Type		= 1051
VPP		= 12
Flash		= 4096
Signature	= 1E41FF
Lock		= 2
---------------------------------------
Name		= 90S1200
Type		= 1200
VPP		= 12
Flash		= 1024
EEPROM		= 64
Signature	= 1E9001
Lock		= 2
Fuse		= SPI
Fuse		= RCEN
---------------------------------------
Name		= 90S2313
Type		= 1200
VPP		= 12
Flash		= 2048
EEPROM		= 128
Signature	= 1E9101
Lock		= 1		2 only erasable at 4V !
Fuse		= SPIEN
Fuse		= FSTRT
---------------------------------------
Name            = TINY22
Type            = TINY22
VPP             = 5
Flash           = 2048
EEPROM          = 128
Signature       = 1E9103
Lock            = 1		2 only erasable at 4V !
Fuse		= SPIEN		not changed in low voltage mode
Fuse            = RCEN
---------------------------------------
END		= 0		ignore further lines
-------------------------------------------------------------------------

		Batch mode programming example
		------------------------------

:program
@echo off
if a%1 == a goto nobatch
REM Batch mode programming, Device must be inserted first !
uniprog.exe /iuniprog.bat /h%1 /ra.e.p.qj
goto end
				 a.	  = autoselect
				   e.	  = erase
				     p.	  = program
				       qy = quit
:nobatch
REM No Batch mode
uniprog.exe /iuniprog.bat
:end
