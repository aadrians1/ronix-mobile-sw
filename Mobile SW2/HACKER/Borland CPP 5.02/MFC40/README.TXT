MFC 4.0 Instructions
--------------------

Here are the steps to build MFC libraries with BC5. It assumes that
you have an unmodified copy of MFC 4.0 that came with MSVC version 4.0.
If you have modified your MFC source or headers significantly, then skip
to step 11 for instructions on how to patch by hand.

1) Install MFC4.0
   --------------

Install MSVC, say into a directory C:\MSVC40.

2) Install Borland Compiler
   ------------------------

Install BC5 into some directory, say C:\BC5.  All subsequent uses of the
directory C:\BC5 below should refer to this installation directory.


3) Check That You Have the Right Version of MFC
   --------------------------------------------

The file C:\MSVC40\MFC\INCLUDE\AFXVER_.H, line 17 should read:

#define _MFC_VER 0x0400 // Microsoft Foundation Classes version 4.00

4) Patch files (From SETUP40.EXE)
   ------------------------------

The SETUP40.EXE program will preform all of the patching for you.
Simply run SETUP40.EXE and follow the instructions.  It will also create
the proper configuration files.  Once you finish this step, you're done
patching, so go directly to step 7 (Building the Libraries).
Continue following the next two steps only if you wish to apply the
patch files by hand.  Skip to step 11 if you've modified your MFC source
and the patching process doesn't succeed.

5) Patch files (by hand, from the command line)
   --------------------------------------------

The following two steps (5 and 6) are only required if you choose not to
run the automatic tool, SETUP40.EXE.  Here you will modify some existing
MFC sources and headers (all mods are ifdef __BORLANDC__). It will also
add some makefiles, .def files and libs. After running each patch, check
the output to make sure there were no errors.

Execute the following commands:

	PATCH C:\MSVC40\MFC\SRC PAT40SRC
	PATCH C:\MSVC40\MFC\INCLUDE PAT40INC
	PATCH C:\MSVC40\MFC\SRC\INTEL PAT40DEF
	PATCH C:\BC5\LIB PAT40LIB

6) Edit config files
   -----------------

Edit the file C:\MSVC40\MFC\SRC\BCC32.CFG - lines 2,3,4 need to be
changed to reflect the install paths for BC5 and MFC.

    -I..\include
    -Ic:\bc5\include
    -Ic:\msvc40\include
    -Ld:\bc5\lib
    -D_X86_
    -D_MSC_VER=900
    -D_WINDOWS
    -D_WCHAR_T_DEFINED
    -D_AFX_PORTABLE
    -D_AFX_NOFORCE_LIBS
    -D_CRT_PORTABLE
    -D_AFX_NO_DEBUG_CRT
    -DDllMain=DllEntryPoint

Edit the file C:\MSVC40\MFC\SRC\BRCC32.CFG - lines 1 needs to be
changed to reflect the install paths for BC5 and MFC.

	/i..\include;c:\bc5\include;c:\msvc40\include

7) Build the Libraries
   -------------------
  Change the current directory to MSVC40\MFC\SRC. The libraries that
  are built by these makefiles are placed in MSVC40\MFC\LIB\BORLAND.

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

To build the monolithic MFC DLL BFC40.DLL and BFC40.LIB

    make -fbfcdll.mak DEBUG=0 LIBNAME=BFC40

NOTE: BFC40.DLL contains everything you'll need for MFC in non-debug
mode.  When building MFC with DEBUG=1, you'll end up with 4 DLLs (see
7.4)


7.4) Debug DLLs and Libraries
     ------------------------

To build MFC DLL BFC40D.DLL and BFC40D.LIB, OLE DLL BFCO40D.DLL and
BFCO40D.LIB, the database DLL BFCD40D.DLL and BFCD40D.LIB, and the
net DLL BFCN40D.DLL and BFCN40D.LIB

    make -fbfcdll.mak
    make -fbfcole.mak
    make -fbfcdb.mak
    make -fbfcnet.mak

8) Install Libraries and DLLs
   --------------------------

Copy the libraries you created to the Borland directory C:\BC5\LIB.
Copy the DLLs you created to the Windows System directory, typically
C:\WINDOWS\SYSTEM.


9) Try it out
   ----------

The Integrated Development Environment supports creating MFC projects. The
following steps assume that you've built the static, non-debug version of
the library and copied it to \BC5\LIB.

a. In the IDE, select File | New | Project and browse to an MFC sample app
   such as \msvc40\samples\mfc\general\hello and name the project hello.

b. In the Frameworks box, deselect OWL and then select MFC. Then select
   the 4.0 radio button.

c. Select the Static radio button and click OK.

d. Delete the .def file from the project.

e. Go to Options | Project | Directories and add c:\msvc40\mfc\include to
   the include path.

f. Do a "build all" and it's ready to run!

The Borland C++ IDE will setup all the defines and libraries you'll need
to build an MFC program.  In case you want to add these into an existing
MAKEFILE or otherwise compile at the command line, here is a list of the
defines that should be added with -D in a compiler configuration file:

  MFC 4.0, Static,  No OLE:
    _X86_;_WINDOWS;_MSC_VER=900;_AFX_PORTABLE;_AFX_NOFORCE_LIBS;_MT;
    _CRT_PORTABLE;_AFX_NO_DEBUG_CRT;

  MFC 4.0, Static,  OLE:
    INC_OLE2;_X86_;_WINDOWS;_MSC_VER=900;_AFX_PORTABLE;_AFX_NOFORCE_LIBS;
    _MT;_CRT_PORTABLE;_AFX_NO_DEBUG_CRT;

  MFC 4.0, Dynamic, No OLE:
    _RTLDLL;_AFXDLL;_DLL;_X86_;_WINDOWS;_MSC_VER=900;_AFX_PORTABLE;
    _AFX_NOFORCE_LIBS;_MT;_CRT_PORTABLE;_AFX_NO_DEBUG_CRT;

  MFC 4.0, Dynamic, OLE:
    INC_OLE2;_RTLDLL;_AFXDLL;_DLL;_X86_;_WINDOWS;_MSC_VER=900;
    _AFX_PORTABLE;_AFX_NOFORCE_LIBS;_MT;_CRT_PORTABLE;_AFX_NO_DEBUG_CRT;

  The libraries needed to link with are as follows:

  MFC 4.0, Static,  No Diagnostics, No OLE:
    nafxcw.lib odbc32.lib import32.lib cw32mt.lib

  MFC 4.0, Static,  No Diagnostics, OLE:
    nafxcw.lib ole2w32.lib odbc32.lib import32.lib cw32mt.lib

  MFC 4.0, Static,  Diagnostics,    No OLE:
    nafxcwd.lib odbc32.lib import32.lib cw32mt.lib

  MFC 4.0, Static,  Diagnostics,    OLE:
    nafxcwd.lib ole2w32.lib odbc32.lib import32.lib cw32mt.lib

  MFC 4.0, Dynamic, No Diagnostics, No OLE:
    bfcs40.lib bfc40.lib odbc32.lib import32.lib cw32mti.lib

  MFC 4.0, Dynamic, No Diagnostics, OLE:
    bfcs40.lib bfc40.lib ole2w32.lib odbc32.lib import32.lib cw32mti.lib

  MFC 4.0, Dynamic, Diagnostics,    No OLE:
    bfcs40d.lib bfc40d.lib bfco40d.lib bfcd40d.lib bfcn40d.lib odbc32.lib
    import32.lib cw32mti.lib

  MFC 4.0, Dynamic, Diagnostics,    OLE:
    bfcs40d.lib bfc40d.lib bfco40d.lib bfcd40d.lib bfcn40d.lib
    ole2w32.lib odbc32.lib import32.lib cw32mti.lib

10) Notes on building the MFC examples
    ----------------------------------
    \SAMPLES\MFC\OLE\WORDPAD
      DOCTYPE.CPP - Line 145 should read:
        file.Close();

11) Preforming the patch process by hand
    ------------------------------------

If you've modified your copy of the MFC source code or headers, then the
patch process won't find the original files and hence, won't install.
You have two choices: either re-install a fresh copy of MFC from the CD
and then proceed with the automatic SETUP40.EXE program, or apply the
patches by hand.

The following instructions list the various changes that the patches
would have made to a fresh copy of MFC.  You can then hand-compare the
original with your modified copy to decide where, in your source, to
place the changes.

We have assumed that your copy of MFC is located in the c:\msvc40 directory.

First, unzip the PAT40MAK.ZIP file to the c:\msvc40\mfc\src directory.
Then unzip the PAT40DEF.ZIP file to the c:\msvc40\mfc\src\intel directory.
Finally unzip the PAT40LIB.ZIP file to the c:\bc5\lib directory.

Create the .CFG files as instructed in step 6.

Now you're ready to modify the following source and header files by hand.

c:\msvc40\mfc\include\afx.h
---------------------------
Line 1489: insert

#ifdef __BORLANDC__
void* AFX_CDECL operator new[](size_t nSize, LPCSTR lpszFileName, int nLine);
void AFX_CDECL operator delete[](void* p);
#endif

c:\ msvc40\mfc\include\afxtempl.h
---------------------------------
Line 128: replace
return ((UINT)(void*)(DWORD)key) >> 4;
by:

#ifdef __BORLANDC__
    return (*((UINT*)(void*) &key)) >> 4;
#else
    return ((UINT)(void*)(DWORD)key) >> 4;
#endif

c:\msvc40\mfc\src\stdafx.h
--------------------------
Line 65: insert

#ifdef __BORLANDC__
#define bool boolVal
#endif

c:\msvc40\mfc\src\cmdtarg.cpp
-----------------------------
Line 31: replace
#if _AFXDLL
    m_pModuleState = AfxGetModuleState();
    ASSERT(m_pModuleState != NULL);
#endif
by:

#ifdef __BORLANDC__
#ifdef _AFXDLL
    m_pModuleState = AfxGetModuleState();
    ASSERT(m_pModuleState != NULL);
#endif
#else
#if _AFXDLL
    m_pModuleState = AfxGetModuleState();
    ASSERT(m_pModuleState != NULL);
#endif
#endif

c:\msvc40\mfc\src\ctlfont.cpp
-----------------------------
Line 85: replace
		pFontDesc = &_fdDefault;
By:

#ifdef __BORLANDC__
            _fdDefault.cySize.Lo = 120000;
            _fdDefault.cySize.Hi = 0;
            pFontDesc = &_fdDefault;
#else
            pFontDesc = &_fdDefault;
#endif

Line 51: replace
static const FONTDESC _fdDefault =
    { sizeof(FONTDESC), OLESTR("MS Sans Serif"), FONTSIZE(12), FW_NORMAL,
      DEFAULT_CHARSET, FALSE, FALSE, FALSE };
By:

#ifdef __BORLANDC__
static FONTDESC _fdDefault =
    { sizeof(FONTDESC), OLESTR("MS Sans Serif"), {}, FW_NORMAL,
      DEFAULT_CHARSET, FALSE, FALSE, FALSE };
#else
static const FONTDESC _fdDefault =
    { sizeof(FONTDESC), OLESTR("MS Sans Serif"), FONTSIZE(12), FW_NORMAL,
      DEFAULT_CHARSET, FALSE, FALSE, FALSE };
#endif

c:\msvc40\mfc\src\ctlpset.cpp
-----------------------------
Line 704: insert
#ifdef __BORLANDC__
                        _fdDefault.cySize.Lo = 120000;
                        _fdDefault.cySize.Hi = 0;
#endif

Line 688: insert
#endif

Line 685: insert
#ifdef __BORLANDC__
static FONTDESC _fdDefault =
        { sizeof(FONTDESC), OLESTR("Helv"), {}, FW_NORMAL,
          DEFAULT_CHARSET, FALSE, FALSE, FALSE };
#else

Line 31: replace
static LARGE_INTEGER liZero = {0,0};
By:

#ifdef __BORLANDC__
static LARGE_INTEGER liZero = {};
#else
static LARGE_INTEGER liZero = {0,0};
#endif

c:\msvc40\mfc\src\daocore.cpp
-----------------------------
Line 4469: replace
DAO_CHECK(m_pDAORecordset->FillCache(
        pSize != NULL ? (VARIANT)COleVariant(*pSize) : _afxOptionalVariant,
        pBookmark != NULL ? (VARIANT)*pBookmark : _afxOptionalVariant));
by:

#ifdef __BORLANDC__
    if (pSize)
        DAO_CHECK(m_pDAORecordset->FillCache(
            (VARIANT)COleVariant(*pSize),
            pBookmark != NULL ? (VARIANT)*pBookmark : _afxOptionalVariant));
    else
        DAO_CHECK(m_pDAORecordset->FillCache(
            _afxOptionalVariant,
            pBookmark != NULL ? (VARIANT)*pBookmark : _afxOptionalVariant));
#else
    DAO_CHECK(m_pDAORecordset->FillCache(
        pSize != NULL ? (VARIANT)COleVariant(*pSize) : _afxOptionalVariant,
        pBookmark != NULL ? (VARIANT)*pBookmark : _afxOptionalVariant));
#endif

Line 864: replace
DAO_CHECK(pDaoState->m_pDAODBEngine->CompactDatabase(
        V_BSTR(&varSrcName), V_BSTR(&varDestName),
        COleVariant(lpszLocale, VT_BSTRT), COleVariant((long)nOptions),
        lpszPassword != NULL ? (VARIANT)COleVariant(lpszPassword, VT_BSTRT)
:
        _afxOptionalVariant));
by:

#ifdef __BORLANDC__
    if (lpszPassword != NULL)
        DAO_CHECK(pDaoState->m_pDAODBEngine->CompactDatabase(
            V_BSTR(&varSrcName), V_BSTR(&varDestName),
            COleVariant(lpszLocale, VT_BSTRT), COleVariant((long)nOptions),
            (VARIANT)COleVariant(lpszPassword, VT_BSTRT)));
    else
        DAO_CHECK(pDaoState->m_pDAODBEngine->CompactDatabase(
            V_BSTR(&varSrcName), V_BSTR(&varDestName),
            COleVariant(lpszLocale, VT_BSTRT), COleVariant((long)nOptions),
            _afxOptionalVariant));
#else
    DAO_CHECK(pDaoState->m_pDAODBEngine->CompactDatabase(
        V_BSTR(&varSrcName), V_BSTR(&varDestName),
        COleVariant(lpszLocale, VT_BSTRT), COleVariant((long)nOptions),
        lpszPassword != NULL ? (VARIANT)COleVariant(lpszPassword, VT_BSTRT) :
        _afxOptionalVariant));
#endif

c:\msvc40\mfc\src\dockcont.cpp
------------------------------
Line 126: replace
m_rectFrameDragHorz = m_rectDragHorz = CRect(rect.TopLeft(), sizeHorz);
m_rectFrameDragVert = m_rectDragVert = CRect(rect.TopLeft(), sizeVert);
By:

#ifdef __BORLANDC__
        m_rectDragHorz = CRect(rect.TopLeft(), sizeHorz);
        m_rectFrameDragHorz = m_rectDragHorz;
        m_rectDragVert = CRect(rect.TopLeft(), sizeVert);
        m_rectFrameDragVert = m_rectDragVert;
#else
        m_rectFrameDragHorz = m_rectDragHorz = CRect(rect.TopLeft(), sizeHorz);
        m_rectFrameDragVert = m_rectDragVert = CRect(rect.TopLeft(), sizeVert);
#endif

c:\msvc40\mfc\src\nolib.cpp
---------------------------
Line 149: insert
#endif

Line 23: insert
#ifndef __BORLANDC__

c:\msvc40\mfc\src\occsite.cpp
-----------------------------
Line 1328: replace
pThis->m_rect = lprcPosRect;
By

#ifdef __BORLANDC__
    pThis->m_rect = *lprcPosRect;
#else
    pThis->m_rect = lprcPosRect;
#endif

c:\msvc40\mfc\src\olemisc.cpp
-----------------------------
Line 709: replace
LARGE_INTEGER zero = { 0, 0 };
By

#ifdef __BORLANDC__
            LARGE_INTEGER zero;
            zero.LowPart = zero.HighPart = 0;
#else
            LARGE_INTEGER zero = { 0, 0 };
#endif

c:\msvc40\mfc\src\olepset.cpp
-----------------------------
Line 1493: replace
LARGE_INTEGER liZero = {0,0};
By

#ifdef __BORLANDC__
    LARGE_INTEGER liZero;
    liZero.LowPart = 0;
    liZero.HighPart = 0;
#else
    LARGE_INTEGER liZero = {0,0};
#endif

c:\msvc40\mfc\src\olevar.cpp
----------------------------
Line 782: insert
#endif

Line 745: insert
#if defined(__BORLANDC__) && defined(_DEBUG)

Line 719: insert
#endif

Line 709: insert
#if defined(__BORLANDC__) && defined(_DEBUG)

c:\msvc40\mfc\src\wincore.cpp
-----------------------------
Line 798: replace
delete m_pCtrlCont;
By

#ifdef __BORLANDC__
    delete (CCmdTarget *)m_pCtrlCont;
#else
    delete m_pCtrlCont;
#endif

Line 758: replace
delete m_pCtrlCont;
By

#ifdef __BORLANDC__
    delete (CCmdTarget *)m_pCtrlCont;
#else
    delete m_pCtrlCont;
#endif

File c:\msvc40\mfc\src\app3ds.cpp
---------------------------------
Line 25: replace
#pragma comment(lib, "ctl3d32s.lib")

By
#ifndef __BORLANDC__
#pragma comment(lib, "ctl3d32s.lib")
#endif

File c:\msvc40\mfc\src\appcore.cpp
----------------------------------
Line 179: insert
#ifdef __BORLANDC__
#define __argc _argc
#define __argv _argv
#endif

Line 13: insert
#include <dos.h>

File c:\msvc40\mfc\src\dllole.cpp
----------------------------------
Line 267: insert
#ifdef __BORLANDC__
void * operator new(size_t size, void *ptr)
{
        return ptr;
}
#endif

File c:\msvc40\mfc\src\olecall.cpp
----------------------------------
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

File c:\msvc40\mfc\src\bormem.cpp
----------------------------------
#include "stdafx.h"
// This function is for the "placement new operator" used with Borland C++
void *operator new(size_t size, void *ptr)
{
	return ptr;
}
