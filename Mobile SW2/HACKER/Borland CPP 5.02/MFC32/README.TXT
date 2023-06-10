MFC 3.2 instructions
--------------------

Here are the steps to build MFC 3.2 libraries with BC5. It assumes that
you have an unmodified copy of MFC 3.2 that came with MSVC version 2.2.
If you have modified your MFC source or headers significantly, then skip
to step 11 for instructions on how to patch by hand.

1) Install MFC 3.2
   --------------

Install MSVC, say into a directory C:\MSVC20.  Typically this will be on
the Visual C++ 2.2 CD-ROM.

2) Install Borland compiler
   ------------------------

Install BC5 into some directory, say C:\BC5.  All subsequent uses of the
directory "C:\BC5" below should refer to this installation directory.

3) Check that you have the right version of MFC
   --------------------------------------------

The file C:\MSVC20\MFC\INCLUDE\AFXVER_.H, line 18 should read:

#define _MFC_VER 0x0320 // Microsoft Foundation Classes 3.20


4) Patch files (From SETUP32.EXE)
   ------------------------------

The SETUP32.EXE program will preform all of the patching for you.
Simply run SETUP32.EXE and follow the instructions.  It will also create
the proper configuration files.  Once you finish this step, you're done
patching, so go directly to step 7 (Building the Libraries).
Continue following the next two steps only if you wish to apply the
patch files by hand.  Skip to step 11 if you've modified your MFC source
and the patching process doesn't succeed.

5) Patch files (by hand, from the command line)
   --------------------------------------------

The following two steps (5 and 6) are only required if you choose not to
run the automatic tool, SETUP32.EXE.  Here you will modify some existing
MFC sources and headers (all mods are ifdef __BORLANDC__). It will also
add some makefiles, .def files and libs. After running each patch, check
the output to make sure there were no errors.

Execute the following commands:

	PATCH C:\MSVC20\MFC\SRC PAT32SRC
	PATCH C:\MSVC20\MFC\INCLUDE PAT32INC
	PATCH C:\MSVC20\MFC\SRC\INTEL PAT32DEF
	PATCH C:\BC5\LIB PAT32LIB

6) Edit config files
   ----------------

Edit the file C:\MSVC20\MFC\SRC\BCC32.CFG - lines 2,3,4 need to be
changed to reflect the install paths for BC5 and MFC.

    -I..\include
    -Ic:\bc5\include
    -Ic:\msvc20\include
    -Ld:\bc5\lib
    -D_MSC_VER=900
    -D_WINDOWS
    -D_AFX_PORTABLE
    -D_AFX_NOFORCE_LIBS
    -D_ANONYMOUS_STRUCT
    -DDllMain=DllEntryPoint
    -D_DLL

Edit the file C:\MSVC20\MFC\SRC\BRCC32.CFG - lines 1 needs to be
changed to reflect the install paths for BC5 and MFC.

	/i..\include;c:\bc5\include;c:\msvc20\include

7) Build the Libraries
   -------------------
  Change the current directory to MSVC20\MFC\SRC. The libraries that
  are built by these makefiles are placed in MSVC20\MFC\LIB\BORLAND.

7.1) Static Non-Debug library
     ------------------------

To build static library NAFXCW.LIB (using default makefile)

    make -fborland.mak  DEBUG=0

7.2) Static Debug library
     --------------------

To build static debug library NAFXCWD.LIB (this library is about 50Mb)

    make  -fborland.mak

7.3) Non-Debug DLLs and Libraries
     ----------------------------

To build MFC DLL BFC30.DLL and BFC30.LIB, OLE DLL BFCO30.DLL and BFCO30.LIB,
the database DLL BFCD30.DLL and BFCD30.LIB, and the net DLL BFCN30.DLL and
BFCN30.LIB

    make -fbfcdll.mak   DEBUG=0
    make -fbfcole.mak   DEBUG=0
    make -fbfcdb.mak    DEBUG=0
    make -fbfcnet.mak   DEBUG=0

7.4) Debug DLLs and Libraries
     ------------------------

To build MFC DLL BFC30D.DLL and BFC30D.LIB, OLE DLL BFCO30D.DLL and
BFCO30D.LIB, the database DLL BFCD30D.DLL and BFCD30D.LIB, and the net DLL
BFCN30D.DLL and BFCN30D.LIB

    make -fbfcdll.mak
    make -fbfcole.mak
    make -fbfcdb.mak
    make -fbfcnet.mak

8) Install Libraries and DLLs
   --------------------------

Copy the libraries you created to the Borland directory C:\BC5\LIB.
Copy the DLLs you created to the Windows System directory, typically
C:\WIN95\SYSTEM, or C:\WINNT\SYSTEM32


9) Try it out
   ----------

The Integrated Development Environment supports creating MFC projects. The
following steps assume that you've built the static, non-debug version of
the library and copied it to \BC5\LIB.

a. In the IDE, select File | New | Project and browse to an MFC sample app
   such as \msvc20\samples\mfc\hello and name the project hello.

b. In the Frameworks box, deselect OWL and then select MFC. Then select
   the 3.2 radio button.

c. Select the Static radio button and click OK.

d. Delete the .def file from the project.

e. Go to Options | Project | Directories and add c:\msvc20\mfc\include to
   the include path.

f. Do a "build all" and it's ready to run!

The Borland C++ IDE will setup all the defines and libraries you'll need
to build an MFC program.  In case you want to add these into an existing
MAKEFILE or otherwise compile at the command line, here is a list of the
defines that should be added with -D in a compiler configuration file:

  MFC 3.2, Static,  No OLE:
    _X86_;_WINDOWS;_MSC_VER=900;_AFX_PORTABLE;_AFX_NOFORCE_LIBS;
    _MT;_CRT_PORTABLE;_AFX_NO_DEBUG_CRT;

  MFC 3.2, Static,  OLE:
    INC_OLE2;_X86_;_WINDOWS;_MSC_VER=900;_AFX_PORTABLE;
    _AFX_NOFORCE_LIBS;_MT;_CRT_PORTABLE;_AFX_NO_DEBUG_CRT;OLE2ANSI;

  MFC 3.2, Dynamic, No OLE:
    _RTLDLL;_AFXDLL;_DLL;_X86_;_WINDOWS;_MSC_VER=900;_AFX_PORTABLE;
    _AFX_NOFORCE_LIBS;_MT;_CRT_PORTABLE;_AFX_NO_DEBUG_CRT;

  MFC 3.2, Dynamic, OLE:
    INC_OLE2;_RTLDLL;_AFXDLL;_DLL;_X86_;_WINDOWS;_MSC_VER=900;_AFX_PORTABLE;
    _AFX_NOFORCE_LIBS;_MT;_CRT_PORTABLE;_AFX_NO_DEBUG_CRT;OLE2ANSI;


  The libraries needed to link with are as follows:

  MFC 3.2, Static,  No OLE:
    nafxcw.lib mfcans32.lib odbc32.lib import32.lib cw32mt.lib

  MFC 3.2, Static,  OLE:
    nafxcw.lib mfcans32.lib odbc32.lib ole2w32.lib import32.lib cw32mt.lib

  MFC 3.2, Dynamic, No OLE:
    bfc30.lib mfcans32.lib bfco30.lib bfcd30.lib bfcn30.lib odbc32.lib
    import32.lib cw32mti.lib

  MFC 3.2, Dynamic, OLE:
    bfc30.lib mfcans32.lib bfco30.lib bfcd30.lib bfcn30.lib odbc32.lib
    ole2w32.lib import32.lib cw32mti.lib


10) Notes on building the MFC examples
    ----------------------------------
The OLEVIEW example requires an extra source file added into it. Copy
\MSVC20\MFC\SRC\WINCTRL2.CPP into the OLEVIEW directory and add it to
the .IDE project.  This satisfies the otherwise undefined externals for
the CTree... symbols.

11) Preforming the patch process by hand
    ------------------------------------

If you've modified your copy of the MFC source code or headers, then the
patch process won't find the original files and hence, won't install.
You have two choices: either re-install a fresh copy of MFC from the CD
and then proceed with the automatic SETUP32.EXE program, or apply the
patches by hand.

The following instructions list the various changes that the patches
would have made to a fresh copy of MFC.  You can then hand-compare the
original with your modified copy to decide where, in your source, to
place the changes.

We have assumed that your copy of MFC is located in the c:\msvc20 directory.

First, unzip the PAT32MAK.ZIP file to the c:\msvc20\mfc\src directory.
Then unzip the PAT32DEF.ZIP file to the c:\msvc20\mfc\src\intel directory.
Finally unzip the PAT32LIB.ZIP file to the c:\bc5\lib directory.

Create the .CFG files as instructed in step 6.

Now you're ready to modify the following source and header files by hand.

c:\msvc20\mfc\include\afx.h
---------------------------
Line 1267: insert
#ifdef __BORLANDC__
void* AFX_CDECL operator new[](size_t nSize, LPCSTR lpszFileName, int nLine);
void* AFX_CDECL operator new[](size_t nSize);
void AFX_CDECL operator delete[](void* p);
#endif

c:\msvc20\include\ole2ui.h
--------------------------
Line 67: replace
#pragma pack(push, 8)
by

#ifdef __BORLANDC__
#pragma pack(push, 4)
#else
#pragma pack(push, 8)
#endif

c:\msvc20\mfc\src\stdafx.h
--------------------------
Line 44: insert
#ifdef __BORLANDC__
#define bool boolVal
#endif

c:\msvc20\mfc\src\appui3.cpp
----------------------------
Line 1: If there is a "c" as the first character on the line, delete it.
The line should read:
    // This is a part of the Microsoft Foundation Classes C++ library.

c:\msvc20\mfc\src\afxmem.cpp
----------------------------
Line 86: insert
#ifdef __BORLANDC__
void* AFX_CDECL operator new[](size_t nSize)
{
	// memory corrupt before global new
	if (afxMemDF & checkAlwaysMemDF)
		ASSERT(AfxCheckMemory());

	void* p = AfxAllocMemoryDebug(nSize, FALSE, NULL, 0);

	if (p == NULL)
	{
		TRACE1("::operator new(%u) failed - throwing exception.\n", nSize);
		AfxThrowMemoryException();
	}

	return p;
}

void* AFX_CDECL operator new[](size_t nSize, LPCSTR lpszFileName, int nLine)
{
	// memory corrupt before global new
	if (afxMemDF & checkAlwaysMemDF)
		ASSERT(AfxCheckMemory());

	void* p = AfxAllocMemoryDebug(nSize, FALSE, lpszFileName, Line);

	if (p == NULL)
	{
		TRACE1("::operator new(%u) failed - throwing exception.\n", nSize);
		AfxThrowMemoryException();
	}

	return p;
}

void AFX_CDECL operator delete[](void* p)
{
	// memory corrupt before global delete
	if (afxMemDF & checkAlwaysMemDF)
		ASSERT(AfxCheckMemory());

	AfxFreeMemoryDebug(p, FALSE);
}
#endif

c:\msvc20\mfc\src\afxstate.cpp
------------------------------
Line 124: replace
#ifndef _NTSDK
    ASSERT(_afxSharedData != (BOOL)-1);
#else
    if (_afxSharedData == (BOOL)-1)
        RawDllMain(NULL, DLL_PROCESS_ATTACH, NULL);
#endif
By:

#ifdef __BORLANDC__
    if (_afxSharedData == (BOOL)-1)
        RawDllMain(NULL, DLL_PROCESS_ATTACH, NULL);
#else
#ifndef _NTSDK
    ASSERT(_afxSharedData != (BOOL)-1);
#else
    if (_afxSharedData == (BOOL)-1)
        RawDllMain(NULL, DLL_PROCESS_ATTACH, NULL);
#endif
#endif

c:\msvc20\mfc\src\filelist.cpp
------------------------------
Line 22: insert
#ifdef __BORLANDC__
#define new DEBUG_NEW
#endif

c:\msvc20\mfc\src\olemisc.cpp
-----------------------------
Line 676: If the following line appears, replace:
		LARGE_INTEGER zero = { 0, 0 };
by

#ifdef __BORLANDC__
            LARGE_INTEGER zero;
            zero.LowPart = zero.HighPart = 0;
#else
            LARGE_INTEGER zero = { 0, 0 };
#endif

c:\msvc20\mfc\src\winsplit.cpp
------------------------------
Line 22: insert
#ifdef __BORLANDC__
#define new DEBUG_NEW
#endif

c:\msvc20\mfc\include\afxdlgs.h
-------------------------------
Line 23: insert
#ifdef __BORLANDC__
#pragma warn - hid
#endif

c:\msvc20\mfc\include\afxwin.h
------------------------------
Line 3743: insert
#ifdef __BORLANDC__
#pragma warn + hid
#endif

Line 42: insert
#ifdef __BORLANDC__
#pragma warn - hid
#endif

c:\msvc20\mfc\include\afxdlgs.h
-------------------------------
Line 32: insert
#endif

Line 31: insert
#ifdef __BORLANDC__
#include <oledlg.h>
#endif
#else

c:\msvc20\mfc\src\olecall.cpp
-----------------------------
Line 45: insert
#endif

Line 32: insert
#if defined(__BORLANDC__)
    __emit__(0x5A,             // pop  edx       ; edx = return address
             0x58,             // pop  eax       ; eax = pfn
             0x59,             // pop  ecx       ; ecx = pArgs
             0x03,0x0C,0x24,   // add  ecx,[esp] ; ecx += nSizeArgs (=scratch area)
             0x89,0x11,        // mov  [ecx],edx ; scratch[0] = return address
             0x2B,0x0C,0x24,   // sub  ecx,[esp] ; ecx = pArgs (again)
             0x8B,0xE1,        // mov  esp,ecx   ; esp = pArgs (usually already correct)
             0x59,             // pop  ecx       ; ecx = this pointer (the CCmdTarget*)
             '\xFF',0xD0,      // call eax       ; call member function
             0xC3              // ret            ; esp[0] should = scratch[0] = return address
            );
#else

