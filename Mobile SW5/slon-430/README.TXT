README.TXT                                                       12-20-96 CDC

For SatPro 430 Toshiba Access Panel (TAP)
=====================================================

This archive contains the following files.  These files must all be
present in the default directory in order to proceed.

README.TXT      This file
README.COM      Self-reading version of this file
430TAP1.PRG     Disk 1 image of 430 TAP (in DiskXpress format)
430TAP2.PRG     Disk 2 image of 430 TAP (in DiskXpress format)
430TAP3.PRG     Disk 3 image of 430 TAP User Guide (in DiskXpress format)
430TAP4.PRG     Disk 4 image of 430 TAP User Guide (in DiskXpress format)
MAKEDISK.BAT    Batch file for making installation disk


======================================================
INSTALLATION

Please use the MAKEDISK.BAT file to make the installation diskettes.  You
can execute MAKEDISK.BAT from the command prompt or by double-clicking 
MAKEDISK.BAT in Win95 Explorer.

The diskette image format requires that you have 4 formatted 1.44MB high
density diskettes ready.  The batch file will inform you of this as well.

MAKEDISK.BAT expects to find the diskette image files, 430TAP1.PRG,
430TAP2.PRG, 430TAP3.PRG, and 430TAP4.PRG in the current default directory
(usually the same directory as MAKEDISK.BAT).

Once you have made the installation diskettes, run the SETUP program on the
diskette by one of the following methods:

Windows 95

        From Win95 Explorer, explore A: drive
        Double-click SETUP.EXE

or

        Click on the Start button
        Click on Run
        Enter A:\SETUP in the command field, then click "OK"


=====================================================
Additional Information

MAKEDISK.BAT follows the following procedure, and can be edited to suit your 
specific needs.  Most users will have no need to modify it.

  o  The user is informed of the formatted diskette requirement
  o  User either aborts with Ctrl-C or presses a key to continue
  o  Checks for the existence of the 430TAP?.PRG files, and continues
     if found.  Execution is aborted with a message if the file is not found
  o  Renames 430TAP?.PRG to 430TAP?.EXE
  o  Extracts disk images to diskettes in A:
  o  If extraction was successful, a message is displayed.  If not,
     the program aborts with a message.

