		 ******************************************
		  WELCOME TO CODEGUARD FOR BORLAND C++ 4.5
		 ******************************************

This README file contains important information about CODEGUARD.  For the 
latest information about Borland C++ and its accompanying programs, read
this entire file.

*****************
TABLE OF CONTENTS
*****************

1.  How to Get Assistance
2.  Installation
3.  Features
4.  Important Information
    - General
    - Linker Errors with Undefined Symbols
    - Using Map Files
    - Using OpenHelp with CodeGuard

*********************************************
1. HOW TO GET ASSISTANCE
*********************************************

If you have any problems, please read this file, the INSTCG.TXT file
and other files in your DOC subdirectory, and check the on-line help. If
you still have a question and need assistance, help is available from the
following sources:

  1. Borland offers a wide variety of Technical Support plans
     providing a range of assistance from installation and general
     usage of Borland C++ to language syntax, programming, and
     debugging help. For information about these support programs,
     call 1-800-523-7070.

  2. For immediate assistance with everything from configuring Borland C++
     to C++ programming or debugging, call our C++ Programmer's Advisor 
     Lines ($2/minute, first minute free):
     * Windows / Win32:  1-900-555-1002  or 1-800-782-5558 (MC/Visa)
     * DOS :   1-900-555-1004  or 1-800-368-3366 (MC/Visa)

     For assistance outside of North America, see item 9 below.

  3. For on-line access to the Borland CompuServe forums, with their
     libraries of technical information and answers to common questions,
     type

     GO BCPPWIN   - CodeGuard is supported in section 17.

     If you are not a member of CompuServe, see the enclosed
     special offer, and write for full details on how to receive
     a free IntroPak containing a $15 credit toward your first
     month's on-line charges.

  4. Borland's TECHFAX service. Call (800) 822-4269 for a FAX
     catalog of technical document entries. For assistance outside of 
     North America, contact your local Borland representative.

  5. Borland DLBBS. Dial (408) 431-5096 (up to 9600 baud, 8-N-1)
     for a host of free technical documents and example programs.

  6. Technical information on Borland C++ is available on the Internet
     via anonymous ftp at our ftp site ftp.borland.com and via the
     World Wide Web at the URL http://www.borland.com.

  7. Subscribe to Borland's free electronic newsletter and get a regular
     update on the hottest programming tips and tricks.  Send your full
     name and address via electronic mail to tech-info@borland.com.

  8. Technical Support for European Customers is exclusively handled through
     a number of companies in Europe.  These companies are fully equipped and
     trained to handle all requests for Technical Support you may have and
     receive full backup support from Borland. The following numbers can be
     used for Technical Support in Europe and Australia.  In addition to free
     support for installation problems, there are several payable support
     programs available.

     Country         Phone number         Description
     --------------------------------------------------------------------
     Australia       1 800 641 144        Support for all products
		     1 800 632 266        Customer Services

     Germany,        +49 (0)8995914705    Free installation support
     Switzerland     Use the same number to inquire about support contracts
     and Austria

     France          +33 (1) 41377018     Free Database installation support
		     +33 (1) 41377019     Free Languages installation support
		     +33 (1) 41377009     Inquiries about support contracts

     UK and          +44 (0)1256 373477   Free dBASE installation support
     Ireland         +44 (0)1256 373478   Free Paradox installation support
		     +44 (0)1256 373479   Free Languages installation support
		     Use any of these numbers to inquire about support 
		     contracts

     Netherlands     +31 (0)30 833730     Free installation support
		     Use the same number to inquire about support contracts

     Belgium (NL)    +32 (0) 27143503     Free installation support
		     Use the same number to inquire about support contracts

     Belgium (FR)    +32 (0) 27143504     Free installation support
     and Luxembourg  Use the same number to inquire about support contracts

     Norway and      +47 (0) 22250017     Free installation support
     Iceland          Use the same number to inquire about support contracts

     Denmark         +45 (0) 45762313     Free installation support
		     Use the same number to inquire about support contracts

     Sweden          +46 (0) 86270110     Free installation support
		     Use the same number to inquire about support contracts

     Finland         +358 (0) 904209792   Free installation support
		     Use the same number to inquire about support contracts

     Spain and       +34 (1) 6618091      Free installation support
     Italy           +34 (1) 6615010      Inquiries about support contracts
		     +39 (2) 57303203     Free installation support
		     Use the same number to inquire about support contracts

     Czech republic  +42 (2) 6272135      Information about all support

*********************************************
2. INSTALLATION
*********************************************

Instructions for installing CodeGuard for Borland C++ 4.5 can be found in 
the CodeGuard for Borland C++ 4.5 User's Guide.  See also the files 
INSTCG.TXT and INSTALL.TXT which contain important information about
CodeGuard and Borland C++ 4.5 respectively.

IMPORTANT!
CodeGuard must be installed into a working hard disk installation of 
Borland C++ 4.51 or 4.52 to function properly.  Earlier and later versions
of Borland C++ are not supported.  If you are running Borland C++ 4.50, 
see Section 4 "Updating Borland C++ 4.50" in the file INSTCG.TXT.

CodeGuard cannot be run from the CD-ROM and requires a hard disk
installation of Borland C++ 4.51 or 4.52.

Do not delete Borland C++ 4.5x before installing CodeGuard.

Do not use long file names when installing under Windows NT.

*********************************************
3. FEATURES
*********************************************

CodeGuard automatically locates and diagnoses hard-to-find memory bugs in
your 16-bit Windows and EasyWin applications.

+ Detects the most difficult runtime errors
     + memory overruns
     + invalid references
     + uninitialized data accesses
     + memory leaks
     + validates common Windows API and RTL function parameters
       and return values

+ Uses the Borland C++ compiler for unique capabilities
     + Creates special epilogs for member functions, constructors, and
       destructors to verify the this pointer on entry to every C++ method.
     + Creates data and stack layout descriptors to allow CodeGuard to
       report overruns and invalid pointers to locals, globals, and statics.

+ Seamless integration into the Borland C++ IDE
     + Easy activation using TargetExpert
     + Control over compiler support under Options | Project
     + A double click on any CodeGuard message takes you directly to the
       line of source where the problem occurs.
     + Help integrated

+ CodeGuard is fully customizable using the CodeGuard Configuration Utility
  (CGCONFIG.EXE)
     + Enable some or all of CodeGuard's features on a per function basis
     + Choose which errors to report for each resource type such as
		+ file and directory streams
		+ file handles
		+ memory blocks
		+ objects
		+ arrays
		+ Windows local and global memory
     + Easily accessible via the IDE's SpeedMenu or standalone from Windows

+ Log file support for command-line users
     + Indicates error, source line, and stack trace

+ Updates your compiler and libraries to Borland C++ 4.53
     + Supersedes Borland C++ version 4.52
     + Contains import libraries and header files for Windows 95.

*********************************************
4. IMPORTANT INFORMATION
*********************************************

This section contains important information not found in the manuals, online
Help, or online text files.

General
-------
The CodeGuard installation program updates your version of Borland C++ 4.51
or 4.52 to version 4.53.  Here are the differences between the four releases
of Borland C++ 4.5x:
      + Borland C++ 4.50 - Initial release
      + Borland C++ 4.51 - Adds final version of 32-bit OLE support.
			   Includes other major bug fixes.
      + Borland C++ 4.52 - Includes all changes from 4.51.
			   Updates import libraries, header files and VBX
			   support for the final version of Windows 95.
      + Borland C++ 4.53 - Includes all changes from 4.52.
			   Adds modifications throughout for CodeGuard.
If you are an owner of Borland C++ 4.51 and install CodeGuard, you do
not need to go back and install version 4.52.  However, owners of Borland C++
4.5 and Database Tools will want to obtain and install the BDE and SQL links
which are shipped with BC++ 4.52 in order to update them to version 2.5.

If running a CodeGuard-enabled application under Windows 95 and that
application generates a GP fault, Windows 95 will trap the fault and prevent
CodeGuard from ever seeing it. In this case, running your application under
Windows 3.1 or Windows NT will allow CodeGuard to provide you with additional
information. Another option is to use WinSpector and DFA to debug GP Faults
under Windows 95.   Due to this limitation, the ZERODIV and GPFAULT
CodeGuard examples should not be run under Windows 95.  

The default number of available file handles has been increased to 50 for
both the 16 and 32-bit runtime libraries.

When a program being tested is terminated, CodeGuard may take several
minutes to write large .CGL files to disk and may give the appearance of
being hung.  Allow CodeGuard time to complete its task.

If you run an application built with CodeGuard while its .CGL file is opened 
in an editor other than that in the Borland C++ Integrated Development
Environment (IDE), (i.e. being viewed by notepad) no CodeGuard information
will be written to disk. If you fail to receive CodeGuard information, check
to be sure that you do not have the .CGL file open in an editor.

If you are developing applications with CodeGuard across multiple
directories, take care when using relative paths (i.e. ..\foo.cpp).  If
your CodeGuard errors do not include source information, you may need to
specify in CGCONFIG.EXE the directory where your .OBJs reside rather than
your source directory to compensate for relative paths.

Programs which use the obsolete IOStream 1.2 constructors will report
resource Leaks when built with CodeGuard.  Borland does not plan to update
this obsolete code and will likely remove support for IOStream 1.2 in future
products.

The log view in Turbo Debugger for Windows (TDW) scrolls when full.  If you
are capturing CodeGuard messages in TDW's log view and it appears that you
are missing errors, see the application's .CGL file for a complete log.

CodeGuard cannot give accurate source positions for errors that occur within
inline functions.  The command line compiler defaults to generating inline
functions out of line when debugging information is turned on, but the IDE
does not.  For debugging purposes, it is best to compile your CodeGuard
enabled applications with "Out of line inline functions" (-vi-) enabled.
The online help for Borland C++ incorrectly lists this option as -vi.

Conditions which produce the message "CodeGuard Error: That entrypoint 
is not available (undefined dynalink)" will leave CodeGuard in an unstable
state.  Until you restart Windows, or, under Windows NT, shutdown VDMs, all
subsequent CodeGuard enabled applications run will produce a similar error.

The message "Resource from different RTL" will sometimes indicate a mixing
of far and near memory allocation routines.  For example, allocating memory
with faralloc() and releasing it with free() can produce this message even
when used from the same RTL.

Versions of the OWL, BIDS and ObjectComponents libraries built with
CodeGuard enabled are provided in the CD-ROM version of CodeGuard in the
directory \CGEDDLLS.

If you enable CodeGuard for a DLL, the EXE which uses that DLL must also
be CodeGuard-enabled.  This is true for the OWL, BIDS or ObjectComponents
DLLs that have been CodeGuarded and provided in \CGEDDLLS as well as all
other DLLs.

If you are building an application using CodeGuard, any DLLs used by that
application must also have CodeGuard enabled if they share the same version
of the RTL DLL with the EXE.  If the DLLs use a different version of the RTL
DLL or use the RTL linked statically the DLLs need not be built with
CodeGuard.  In either of these cases, however, it is important to link
CG16.LIB *before* any of the import libraries for the other DLLs or you
will see spurious resource leak errors.  See the online help for TLINK
for information on library ordering on the command line.  In the IDE, you
must enable Options | Environment | Project View | Show run-time nodes to
see and change the library ordering in your project.

You should not run an application built without CodeGuard which uses the
RTL DLL at the same time as an application built with CodeGuard that uses
the RTL DLL.

CodeGuard expects source files to be saved to disk and unmodified when
providing line number information.  If you have made modifications to
your source which are not committed to disk, or if you have committed
modifications to disk without rebuilding, CodeGuard may provide you
with code excerpts which are unrelated to the error detected.
In the IDE, turn on Options | Environment | Preferences | Auto Save |
Editor files to automatically save all dirty buffers before build, run,
debug run, exit, or transfer.

Linker Errors with Undefined Symbols
------------------------------------
If your application includes any modules that are CodeGuard-enabled, you
must link CG16.LIB. The linker emits the following error message if you
don't use CG16.LIB and you attempt to link a CodeGuard-enabled module:

	Undefined symbol _CG_DESC in module FILENAME.CPP.
	Undefined symbol _CG_THIS in module FILENAME.CPP.

These are symbols which the compiler inserts into your modules to allow
CodeGuard to detect errors.  If you disable CodeGuard for an application,
it is important to perform an entire rebuild of that application (rather
than a make) to remove these symbols from your OBJs.

Using Map Files
---------------
A general debugging technique with CodeGuard is to use the .CGL file in
conjunction with map files for the modules in your program.  In the .CGL
file, the segments and offset of a problem within the module is given. These
correspond directly to entries in the map file generated for the module. Be
sure to generate a detailed map file with line numbers for every module in
your application.

Once you have the map files, look up the first line of the error in
your .CGL file:

 >> Resource type mismatch: a(n) object was expected. delete(0x4AA7:0012)
 >> Call Tree: 0x5B27:01AA(=FOO.DLL:0x33:01AA)
 >> 0x610F:083D(=FOO.DLL:0x13:083D) 0x610F:321B(=FOO.DLL:0x13:321B)
 >> 0x610F:08FE(=FOO.DLL:0x13:08FE) 0x5B27:27EE(=FOO.DLL:0x33:27EE)
 >> 0x5B27:1AA0(=FOO.DLL:0x33:1AA0)

In this case, it is FOO.DLL:0x33:01AA. You know the problem is coming
from FOO, and it is in segment 0x33 offset 0x1AA. If you take a look at
the map file, you'll see which OBJ this is in. From the offset, you can
find out which function is causing the problem.  The line numbers section
will give you file name and line number positions for the segment and
offset for a more detailed location of the problem.

Using OpenHelp with CodeGuard
-----------------------------
In order for keywords from the CodeGuard help file (CODEGARD.HLP) to appear
in keyword list when you choose Search All from a help file, you need to run
the OpenHelp configuration program and add CODEGARD.HLP to your search
ranges.

See the online Help provided with OpenHelp (OPENHELP.HLP) for details on
how to use and configure the Borland online help search engine.
