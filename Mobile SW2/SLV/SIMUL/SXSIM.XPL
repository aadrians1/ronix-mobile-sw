\SXSIM.XPL	MAR-14-98	Version 1.05
\Simulator/Debugger for the Scenix SX18AC and SX28AC Microcontrollers.
\Copyright (C) 1998 Loren Blaney
\
\This program is free software; you can redistribute it and/or modify it under
\ the terms of the GNU General Public License version 2 as published by the
\ Free Software Foundation.
\This program is distributed in the hope that it will be useful, but WITHOUT
\ ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
\ FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
\ details.
\You should have received a copy of the GNU General Public License along with
\ this program (in the file LICENSE.DOC); if not, write to the Free Software
\ Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
\
\You can reach me at:			Mail:	Loren Blaney
\ Email: loren_blaney@idcomm.com		502 Pine Glade Dr.
\						Nederland, CO 80466, USA
\
\This program was compiled with the version 2.3 XPL0 compiler (XPLX, 16-bit).
\ It is available from: http://www.brouhaha.com/~eric/computers/xpl0/
\ I can send you a copy of this compiler if you can't find it.
\
\This simulation is based on preliminary, February 1998, documentation from
\ Scenix. Where a detail is not explained by the Scenix document, Microchip's
\ documentation for the PIC12C5xx is used.
\
\
\WARNINGS:
\Unused, high bits are not guaranteed to be cleared. For example, WReg can
\ be greater than $FF (because of carry propagation in add instructions).
\
\
\REVISIONS:
\1.00, JAN-12-98, Released.
\1.01, JAN-18-98, Interrupts. Clean up status code.
\1.02, JAN-26-98, Fix prescaler divide ratios. Enter=Spacebar=F7.
\1.03, FEB-25-98, Fix RETIW instruction. Fix CARRYX FUSEX bit. Simulate all
\ FUSE and FUSEX bits and load them from listing. Automatically set frequency if
\ internal osc is enabled. Interrupt saves PC in shadow register, not on stack.
\1.04, MAR-02-98, Add Alt-F1 command to view OUTPUT screen.
\1.05, MAR-14-98, Fix bug when saving F1-F3 checkpoints using mouse.

def	Debug = false;	\Enable debug code (turn this off in final version)

inc	\CXPL\CODESI;	\Include code definitions for intrinsic routines

def	ROMSizeMax = $1012, \Maximum size of instruction memory (12-bit words)
			    \ (The extra 12 is for fuse bits at $1010 and $1011)
	RAMSize = $100,	\Size of file register space (incl. mirrored locations)
	HistSize = 200,	\Size of history buffers = maximum backups +1
	LineBufSize = 5<<4;	\Max chars per line for mnemonics and comments
				\(Must be a multiple of 16 because of Malloc)
	\Addresses of special registers (Microchip's nomenclature):
def	INDF=0, RTCC=1, PCL=2, STATUS=3, FSR=4, PORTA=5, PORTB=6, PORTC=7;

def	OptionAddr=$100, MBitsAddr=$101, \Pseudo addresses for history buffer
	TRISAAddr=$102, TRISBAddr=$103, TRISCAddr=$104,
	WKENBAddr=$105, WKEDBAddr=$106, COMPBAddr=$107;

\Screen coordinates of displayed items (upper-left corner of number):
def	ExitX=0, ExitY=0,		\Exit button: [þ]
	SpecialRegX=11, SpecialRegY=1,	\INDF, RTCC, PCL, STATUS...
	StackX=17, StackY=1,
	RAMX=28, RAMY=1,		\File register dump
	PCX=2, PCY=11,			\Program counter
	MBitsX=8, MBitsY=11,		\MODE bits
	OptionX=14, OptionY=11,
	Fuse_X=21, Fuse_Y=11,		\Configuration registers
	FusexX=27, FusexY=11,
	WDTX=32, WDTY=11,
	OscX=39, OscY=11,
	TimeX=39, TimeY=13,
	WRegX=5, WRegY=12,
	StatusX=13, StatusY=13,		\Individual status bits
	PortX=56, PortY=11,		\I/O ports
	ListWinX=1, ListWinY=14;	\Code listing window

seg char LineBuf(ROMSizeMax);	\ ,LineBufSize) Holds lines of assembly code
int	ROM(ROMSizeMax); \Instruction memory (12-bit opcodes)

\"RAM" is the first global variable saved in checkpoints:
char	RAM(RAMSize),	\File registers (including mirrored locations 0-F)
	RAM0(RAMSize),	\Copy of RAM at last display, used to highlight changes
	Map(RAMSize),	\Handles multiple addresses for low banks (e.g: $20=$00)
	DoneRAM(RAMSize), \'true' if corresponding RAM location was stored into
	Breakpoint(ROMSizeMax); \'true' if corresponding PC location has bkpt
int	Count0(ROMSizeMax), \Instruction executed counter (1 trillion max)
	Count1(ROMSizeMax),
	Count2(ROMSizeMax),
	Stack(8),	\Subroutine return address stack
	Stack0(8);	\Copy of Stack at last display, for highlighting changes

\History buffers for backup command:
char	HistWReg(HistSize),	\WReg
	HistSTATUS(HistSize),	\Status
	HistRAMFRA(HistSize),	\Holds contents of RAM at FRA
	HistDoneRAM(HistSize),	\Holds DoneRAM at FRA
	HistTimer(HistSize),	\Timer (RTCC)
	HistPrescaler(HistSize);\Prescaler
int	HistPC(HistSize),	\PC
	HistFRA(HistSize),	\File Register Address
	HistSP(8+1, HistSize),	\Stack
	HistCycles0(HistSize),	\Cycle counter (low)
	HistCycles1(HistSize),	\ (medium)
	HistCycles2(HistSize),	\ (high)
	HistWDT0(HistSize),	\WDT (low)
	HistWDT1(HistSize);	\ (high)

\Simulated microcontroller registers:
int	COMPB,		\Comparator enable register for port B
	FUSE, FUSEX,	\Configuration registers
	LATCHA, LATCHB, LATCHC, \Latch for ports A, B & C
	LATCHA0, LATCHB0, LATCHC0, \Copy for highlighting changes
	MBits,		\Mode bits
	MBits0,		\Copy for highlighting changes
	OldPortB,	\Previous Port B pins (used to detect edge on RAM(PORTB)
	Option,		\Option register (6 or 8 bits depending on FUSE bit 9)
	Option0,	\Copy of Option at last display, to highlight changes
	PC,		\Program counter (A10:A9:A8:PCL)
	PC0,		\Copy to highlight changes
	Prescaler,	\Programmable prescaler
	RTCCPin,	\Level on RTCC pin (=0 or #0)
	ShadowFSR,	\Shadow registers for interrupt
	ShadowPC,
	ShadowSTATUS,
	ShadowWReg,
	Timer,		\Separate from RAM(RTCC) because WReg can be mapped here
	TRISA, TRISB, TRISC, \Tristate control registers for ports A, B & C
	TRISA0, TRISB0, TRISC0, \Copy for highlighting changes
	WKENB,		\Wake-up enable register for port B
	WKEDB,		\Wake-up edge select register for port B
	WReg,		\Working (W) register (accumulator)
	WReg0,		\Copy of WReg at last display, used to highlight changes

\Other variables:
	BreakLoc,	\Temporary, non-displayed breakpoint for F8 & F4 cmds
	Cpureg,		\Address of CPU register array
	ClockInhibit,	\Inhibits incrementing Timer 2 cycles after writing it
	CursorShape,	\Shape of flashing cursor to be restored when exiting
	Cycles0,	\Cycle counter (enough for a trillion cycles - low)
	Cycles1,	\(medium)
	Cycles2,	\(high)
	FRA,		\File Register Address (effective address of operand)
	HaveInterrupt,	\Flag: An interrupt is pending
	HaveMouse,	\Flag: A mouse driver is installed and the mouse works
	HistInx,	\Index into history buffers
	HistBase,	\Index to base of valid data in history buffers
	KnobX, KnobY,	\Knob position on scroll bar (character coordinates)
	LineCursor,	\ROM address corresponding to black cursor position
	PCLine,		\Line on screen (in listing window) where PC cursor is
	ROMMask,	\= ROMSize-1.  Note that ROMSize must be a power of 2
	ROMSize,	\Size of instruction memory (12-bit words) (power of 2)
	ROMSizeEven,	\ROMSize rounded down to multiple of ScrollBarHeight
	ScreenHeight,	\Number of lines of text on the screen
	ScreenWidth,	\Number of character columms on the screen
	ScrollBarHeight,\Number of chars in scroll bar (not including arrows)
	ShowingCount,	\Flag: Display execution count (Count0..Count2)
	SP,		\Stack pointer used for detecting underflows & overflows
	StackSize,	\Maximum depth of subroutine stack (2 or 8--see FUSE)
	StatusTable,	\Table of relative X coordinates for each status bit
	StmChar,	\Character read from .STM file
	StmExists,	\Flag: Stimulus (.STM) file exists and it is open
	StmFilePtr0,	\.STM file pointer (low)
	StmFilePtr1,	\ (high)
	StmHandle,	\Handle to stimulus input file (if it exists)
	TraceMode,	\Flag: Show state of SX chip and wait for (key) command
	WDT0, WDT1,	\WDT cycle counter (enough for 100 million cycles)
	WDTimeout,	\Flag: WDT has timed out
	WinHeight,	\Height of the listing window in lines
	WinPtr;		\ROM address where listing window starts (can be < 0)
real	Osc,		\Oscillator frequency (Hertz)
	StmCycles,	\Cycle count at which to apply next input stimulus
	WDTPeriod;	\Watchdog timer timeout period in seconds

\DOSOpen variables:
int	PSPSEG,		\Paragraph address of PSP segment (for file I/O)
	DATASEG;	\Paragraph address of data segment (heap & stack)
def	FileNameSize=40;	\Maximum number of characters in a file name
char	StmFileName(FileNameSize), \Stimulus file name (.STM)
	CfgFileName(FileNameSize), \Configuration file name (.CFG)
	CkpFileName(FileNameSize); \Checkpoint file name (.CP_)

def	TV=6;							\Output device
def	Nul=$00, Bel=$07, BS=$08, Tab=$09, LF=$0A, FF=$0C,	\Control chars
	CR=$0D, Up=$18, Dn=$19, EOF=$1A, Esc=$1B, Space=$20, Ctrl=$40;
def	UpArrow=$48, DnArrow=$50, LtArrow=$4B, RtArrow=$4D,	\Key scan codes
	PageUp=$49, PageDn=$51, Home=$47, End=$4F, Func=$3A,
	ShiftFunc=$53, CtrlFunc=$5D, AltFunc=$67, AltX=$2D;

def	Black, Blue, Green, Cyan, Red, Magenta, Brown, White,	\Attribute colors
	Gray, LBlue, LGreen, LCyan, LRed, LMagenta, Yellow, BWhite; \ EGA palette
def	Flashing=$80;	\(Windows doesn't do flashing)

\===============================================================================

proc	Beep;		\A not-too-obnoxious beep
begin
Sound(false, 1, 1000);	\Synchronize with system timer to make tone a
Sound(true, 1, 3000);	\ consistent duration and a consistent sound.
end;	\Beep



func real Int(X);	\Return integer part of real number
real	X;		\e.g: Int(12.9) = 12.0
return X -Mod(X, 1.0);	\     Int(-3.7) = -3.0



func	CallInt(Int, AX, BX, CX, DX, BP, DS, ES);\Call software interrupt (BIOS)
int	Int, AX, BX, CX, DX, BP, DS, ES; \(Unused arguments need not be passed)
begin
Cpureg:= Getreg;
Cpureg(0):= AX;
Cpureg(1):= BX;
Cpureg(2):= CX;
Cpureg(3):= DX;
Cpureg(6):= BP;
Cpureg(9):= DS;
Cpureg(11):= ES;
Softint(Int);
return Cpureg(0);		\Return AX register
end;	\CallInt



func	GetKey;		\Get character from keyboard (wait if necessary)
int	SC, Ch;			\This is a low-level routine with no echo,
begin				\ no Ctrl+C, and no cursor.
SC:= CallInt($16, $0000);	\Function $00
Ch:= SC & $FF;
if Ch = 0 then Ch:= -(SC>>8);	\Return non-ASCII chars as negative scan code
return Ch;
end;	\GetKey



proc	SetColReg(N, R, G, B); \Set VGA color register (DAC) N
int	N,	 \Register to set (0..255)
	R, G, B; \Red, Green, and Blue (only low 6 bits are used)
		 \ 2**6 = 64;  64 *64 *64 = 262144 possible colors
begin
CallInt($10, $1010, N, G<<8 ! B&$FF, R<<8);  \Function $10, subfunction $10
end;	\SetColReg



proc	SetBkgndColor(X, Y, C);	\Set background color for text
int	X, Y, C;	\Text coordinates (X,Y) and background color (C)
int	AC;		\Attribute (high byte) and character (low byte)
begin
\Set cursor position
CallInt($10, $0200, $0000, 0, Y<<8!X);

\Get attribute and character at cursor
AC:= CallInt($10, $0800, $0000);

\Change background color and write attribute back at cursor
CallInt($10,   $0900 ! AC&$00FF,   AC>>8 & $0F ! C<<4,   1);
end;	\SetBkgndColor



proc	Backlight(X0, Y0, X1, Y1, C); \Hilight but don't change foreground color
int	X0, Y0, X1, Y1, C;
int	X, Y;
begin
for Y:= Y0, Y1 do
    for X:= X0, X1 do
	SetBkgndColor(X, Y, C);
end;	\Backlight

\-------------------------------------------------------------------------------

proc	SpOut(Dev, N);	\Output N spaces to specified device
int	Dev, N;
int	I;
for I:= 1, N do Chout(Dev, ^ );



func	StrLen(Str);	\Returns the number of characters in a string
char	Str;
int	I;
for I:= 0, 32766 do
	if Str(I) >= $80 then return I+1;



proc	Hex1Out(Dev, N); \Output N as one ASCII hex digit
int	Dev, N;
char	HexDigit; 	\Array: ASCII hex digits (0 - F)
begin
HexDigit:= "0123456789ABCDEF ";
Chout(Dev, HexDigit(N & $0F));
end;	\Hex1Out



proc	Hex2Out(Dev, N); \Output byte N as two ASCII hex digits
int	Dev, N;
char	HexDigit; 	\Array: ASCII hex digits (0 - F)
begin
HexDigit:= "0123456789ABCDEF ";
Chout(Dev, HexDigit(N >>4 & $0F));
Chout(Dev, HexDigit(N & $0F));
end;	\Hex2Out



proc	Hex3Out(Dev, N); \Output N as three ASCII hex digits
int	Dev, N;
begin
Hex1Out(Dev, N >>8);
Hex2Out(Dev, N);
end;	\Hex3Out



proc	Bin4OutColor(Dev, N, C); \Output ASCII binary nibble (4 bits) to device
int	Dev, N, C;	\Color bits, xor old and new to highlight changes
int	B;
begin
B:= $08;
while B do
	begin
	Attrib(Cyan<<4 ! (if C & B then BWhite else Black));
	Chout(Dev, if N & B then ^1 else ^0);
	B:= B >> 1;
	end;
end;	\Bin4OutColor



proc	Bin8OutColor(Dev, N, C); \Output ASCII binary byte (8 bits) to device
int	Dev, N, C;	\Color bits, xor old and new to highlight changes
int	B;
begin
B:= $80;
while B do
	begin
	Attrib(Cyan<<4 ! (if C & B then BWhite else Black));
	Chout(Dev, if N & B then ^1 else ^0);
	B:= B >> 1;
	end;
end;	\Bin8OutColor



proc	Bin8Out(Dev, N); \Output ASCII binary byte (8 bits) to device
int	Dev, N;
int	B;
begin
B:= $80;
while B do
	begin
	Chout(Dev, if N & B then ^1 else ^0);
	B:= B >> 1;
	end;
end;	\Bin8Out

\============================== MOUSE ROUTINES ================================

func	OpenMouse;		\Initializes mouse; returns 'false' if it fails
begin				\Pointer is set to center of screen but is hidden
CallInt($21, $3533);		\Make sure mouse vector ($33) points to something
HaveMouse:= false;
if Cpureg(1)=0 & Cpureg(11)=0 then return false;
HaveMouse:= CallInt($33, $0000); \Reset mouse and get status
if HaveMouse then HaveMouse:= true; \(Beware of 'not' operator in 32-bit XPL)
return HaveMouse;		\Return 'false' if failure
end;	\OpenMouse



proc	ShowMouse(On);		\Turn mouse pointer on or off
\The video mode should be set before calling this routine.
\This counts the number of times the pointer is turned on or off. If the
\ pointer is turned off twice, it must be turned on twice before it
\ actually goes on. The pointer should be turned off before drawing over
\ it and before your program exits. Setting the video mode will also turn
\ off the pointer.
int	On;	\Flag: True = pointer on; False = pointer off
if HaveMouse then
	CallInt($33, if On then $0001 else $0002);



func	GetMousePosition(N);	\Return position of specified mouse coordinate
int	N;	\0 = X coordinate; 1 = Y coordinate
\For video modes $0-$E and $13 the maximum coordinates are 639x199, minus
\ the size of the pointer. For modes $F-$12 the coordinates are the same as
\ the pixels. For 80-column text modes divide the mouse coordinates by 8 to
\ get the character cursor position.
begin
if ~HaveMouse then return 0;
CallInt($33, $0003);
return if N then Cpureg(3) else Cpureg(2);
end;	\GetMousePosition



func	GetMouseButton(N);	\Return 'true' if specified mouse button is down
int	N;	\Button number: 0 = left; 1 = right (or middle)
begin
if ~HaveMouse then return false;
CallInt($33, $0003);
return if N then (Cpureg(1)&2)=2 else (Cpureg(1)&1)=1;
end;	\GetMouseButton



proc	MoveMouse(X, Y);	\Move mouse pointer to X,Y
int	X, Y;
if HaveMouse then
	CallInt($33, $0004, 0, X, Y);

\-------------------------------------------------------------------------------

proc	ClearPage1;	\Clear page 1 (the output screen)
begin
ShowMouse(false);
CallInt($10, $0501);	\Set page 1
Chout(0, FF);		\Clear it
CallInt($10, $0500);	\Set page 0
ShowMouse(true);
end;	\ClearPage1

\=============================== DOS FILE I/O =================================

proc	DOSOpen;	\Routine to open MS-DOS files
int	Inx,		\Index into Tail
	InHand;		\Input file handle
char	InFileName(FileNameSize); \Input file name
char	Tail, TLen(80);



proc	CopyName(From, To, Ext);
\Copy file name from "From" to "To" and append Ext
char	From, To,	\Strings are terminated by 0 & must be <= FileNameSize
	Ext;		\Extension started with "." and terminated with an
			\ unused char with MSB set
int	I, J, Ch;
begin
I:= 0;
loop	begin
	Ch:= From(I);
	if Ch=0 ! Ch=^. then quit;
	To(I):= Ch;
	if I < FileNameSize-1 then I:= I +1;
	end;

for J:= 0, 3 do
	begin
	To(I):= Ext(J);
	if I < FileNameSize-1 then I:= I +1;
	end;
To(I):= 0;
end;	\CopyName



proc	CopyNameX(From, To, Ext);
\Copy file name from "From" to "To" and append Ext if no extension is given
char	From, To,	\Strings are terminated by 0 & must be <= FileNameSize
	Ext;		\Extension started with "." and terminated with an
			\ unused char with MSB set
int	I, J, Ch, HaveExt;
begin
I:= 0;
HaveExt:= false;
loop	begin
	Ch:= From(I);
	if Ch = 0 then quit;
	if Ch = ^. then HaveExt:= true;
	To(I):= Ch;
	if I < FileNameSize-1 then I:= I +1;
	end;
if HaveExt then return;

for J:= 0, 3 do
	begin
	To(I):= Ext(J);
	if I < FileNameSize-1 then I:= I +1;
	end;
To(I):= 0;
end;	\CopyNameX



proc	GetName(Name);
\Inputs: Inx, Tail, FileNameSize
char	Name;
int	I, Ch;
begin
while Tail(Inx) = Space do Inx:= Inx +1;
I:= 0;
repeat	Ch:= Tail(Inx);
	Inx:= Inx +1;
	if Ch=Space ! Ch=CR then Ch:= 0;	\Terminate Name with 0
	Name(I):= Ch;
	if I < FileNameSize-1 then I:= I +1;
until Ch =0;
end;	\GetName



begin	\DOSOpen
Tail:= TLen +1;
Blit(PSPSEG, $80, DATASEG, TLen, 79);
if TLen(0)>79 then TLen(0):= 79;

Inx:= 0;
GetName(InFileName);
if InFileName(0) = 0 then		\Fatal error if no file specified
	[Text(0, "No input listing (.LST) file specified
");   exit];

CopyName(InFileName, StmFileName, ".STM ");
CopyName(InFileName, CfgFileName, ".CFG ");
CopyName(InFileName, CkpFileName, ".CP_ ");
CopyNameX(InFileName, InFileName, ".LST ");
Trap(false);
InHand:= Fopen(InFileName, 0);		\Get input handle
if Geterr \#0\ then 
	[Text(0, "Listing (.LST) file not found
");   exit];
Trap(Debug);

Fset(InHand, ^I);
Openi(3);
end;	\DOSOpen

\==============================================================================

proc	LoadListCode;	\Read listing (.LST) file, and load ROM and LineBuf
\Breakpoints are cleared at locations that are loaded and left set at unused
\ (and hence illegal) locations. The highest location loaded is returned in
\ ROMSize so the smallest standard ROM size can be selected.
\ Inputs:  ROM, LineBuf
\ Outputs: ROM, LineBuf, Breakpoint, ROMSize
int	I, Ch, LCh, Addr, Addr2, Inx, Done;
char	Str;


	proc	CheckOp;	\Check that opcode starts with a 0 (is 12 bits)
	begin			\(Don't accidently load 14-bit opcodes)
	if Ch>=^1 & Ch<=^9 then
		begin
		Crlf(0);
		Text(0, "Invalid listing (.LST) file.  Not 12-bit opcodes.");
		Crlf(0);

		cond Debug;	\Only do this while debugging because it's messy
		Crlf(0);	\Show listing at point that error was detected
		Chout(0, Bel);
		while Ch # EOF do
			begin
			if Ch = FF then Crlf(0) else Chout(0, Ch);
			Ch:= Chin(3);
			end;
		cond true;

		exit;		\We can't handle this--give up
		end;
	end;	\CheckOp


\Warning, this routine is a house of cards. It's carefully kluged to handle
\ both SPASM and MPASM listing files.
\0123 0456                  00012        MPASM
\    12    0123- 0456            <tab>   SPASM

begin	\LoadListCode
Str:= "	xorlw	0ffh
";		\Unburned locations are $0FFF, which assembles into xorlw 0ffh
for Addr:= 0, ROMSizeMax-1 do
    for I:= 0, 11 do
	LineBuf(Addr, I):= Str(I);

ROMSize:= 0;
Openi(3);
loop	begin			\Read in file
	loop	begin			\Read in line
		Ch:= LF;			\Skip to leading 0 or 1
		Done:= false;
		repeat	begin			\The address must start with 0
			LCh:= Ch;		\Save last character
			Ch:= Chin(3);
			if Ch = EOF then return;
			if Ch = Tab then Ch:= Space;
			if Ch#Space & (Ch<^0 ! Ch>^9) then quit;  \Ignore line
			if Ch=^0 & (LCh=Space ! LCh=LF) then
				begin
				Done:= true;
				Addr:= Hexin(3); \Read 3 digits of address
				end;
			if Ch=^1 & LCh=LF then
				begin
				Done:= true;
				Addr:= Hexin(3); \Read 3 digits of address
				Addr:= Addr + $1000;
				end;
			end;
		until Done;

		if Addr<0 ! Addr>=ROMSizeMax then quit; \For safety--ignore line

		Ch:= Chin(3);
		if Ch=CR ! Ch=LF ! Ch=^; then quit;   \Ignore line
		if Ch # ^0 then			\Opcode must start with 0 also
			begin
			CheckOp;		\Opcodes starting with other
			Ch:= Chin(3);		\ than 0 aren't 12-bit opcodes
			CheckOp;		\Skip possible space character
			if Ch # ^0 then quit;	\Only one extra space allowed
			end;
		ROM(Addr):= Hexin(3);		\Get 3 digits of opcode into ROM
		Breakpoint(Addr):= false;	\Clear breakpoint at loaded loc
		if Addr < $1010 \fuses\ then
			if Addr > ROMSize then ROMSize:= Addr;

		Ch:= Chin(3);
		if Ch # ^0 then
			begin
			for I:= 1, 15 do	\Skip some garbage
				begin		\Both SPASM & MPASM have 16
				if Ch=CR ! Ch=LF then \ chars of garbage here
					begin
					LineBuf(Addr, 0):= CR;	\Blank line
					quit;
					end;
				if Ch = EOF then return;
				Ch:= Chin(3);
				end;
			end
		else	begin			\More than one opcode on line
			Addr2:= Addr;
			while Ch = ^0 do
				begin		\Get next opcode
				Addr2:= Addr2 + 1;
				ROM(Addr2):= Hexin(3);
				Breakpoint(Addr2):= false;
				if Addr2 < $1010 \fuses\ then
					if Addr2 > ROMSize then ROMSize:= Addr2;
				LineBuf(Addr2, 0):= CR;		\Blank line
				Ch:= Chin(3);
				if Ch=CR ! Ch=LF then
					begin
					LineBuf(Addr, 0):= CR;	\Blank line
					quit;
					end;
				end;
			while Ch # Tab do	\SPASM separates opcodes from
				begin		\ comments with a tab
				Ch:= Chin(3);	\(doesn't work for MPASM)
				if Ch = CR then quit;	\(for MPASM safety)
				if Ch = EOF then return;
				end;
			end;

		Inx:= 0;			\Index of start of line
		repeat	begin			\Read rest of line into buffer
			Ch:= Chin(3);
			if Ch = EOF then	\(Always terminate line with CR)
				[LineBuf(Addr, Inx):= CR;   return];
			LineBuf(Addr, Inx):= Ch;
			Inx:= Inx + 1;
			if Inx >= LineBufSize then Inx:= LineBufSize-1;
			end;
		until Ch=CR ! Ch=LF;
		quit;				\Done reading in line (almost)
		end;	\loop

	while Ch # LF do			\Eat rest of line
		begin
		Ch:= Chin(3);
		if Ch = EOF then return;
		end;
	end;					\Loop back for next line
end;	\LoadListCode

\-------------------------------------------------------------------------------

proc	ShowCode(Addr);	\Show assembly code listing making sure that specified
\ address appears somewhere in the listing window.
int	Addr;
\Inputs: Breakpoint, Count0,1,2, LineBuf, LineCursor, PC, ROM,
\	 ROMSize, ScreenHeight, WinHeight, ListWinY, WinPtr.
\Outputs: PCLine, WinPtr, KnobX, KnobY.
int	Y, A;


	proc	ShowLine;	\Show line of assembly code at specified address
	\Inputs: A, Count0,1,2, LineBuf, ROM
	int	Ch, Inx, X;
	begin
	\0123456789012345678901234567890	<- X coordinate (screen column)
	\..xxxú.xxx..text...			<- Format normally
	\..xxx..xxx..999999999999..text...	<- Format if ShowingCount
	Chout(TV, ^ );
	Hex3out(TV, A);			\Show address
	Chout(TV, if Count0(A)#0 ! Count1(A)#0 ! Count2(A)#0 then ^ú else ^ );

	if A = LineCursor then Attrib(Black<<4 ! Yellow);
	Chout(TV, ^ );
	Hex3out(TV, ROM(A));		\Show instruction code
	Chout(TV, ^ );

	if A = PC then Attrib(Green<<4 ! BWhite);
	Chout(TV, ^ );

	if ShowingCount then 
		begin		     \Show instruction count (999999999999 max)
		Ch:= ^ ;
		if Count2(A) < 1000 then Chout(TV, Ch);
		if Count2(A) < 100 then Chout(TV, Ch);
		if Count2(A) < 10 then Chout(TV, Ch);
		if Count2(A) < 1 then Chout(TV, Ch)
		else	begin
			Intout(TV, Count2(A));
			Ch:= ^0;
			end;
		if Count1(A) < 1000 then Chout(TV, Ch);
		if Count1(A) < 100 then Chout(TV, Ch);
		if Count1(A) < 10 then Chout(TV, Ch);
		if Count1(A) < 1 then Chout(TV, Ch)
		else	begin
			Intout(TV, Count1(A));
			Ch:= ^0;
			end;
		if Count0(A) < 1000 then Chout(TV, Ch);
		if Count0(A) < 100 then Chout(TV, Ch);
		if Count0(A) < 10 then Chout(TV, Ch);
		Intout(TV, Count0(A));
		Text(TV, "  ");
		X:= 26;			\Starting column for listing text
		end
	else	X:= 12;			\Starting column for listing text

	Inx:= 0;			\Show line of text from listing
	loop	begin
		Ch:= LineBuf(A, Inx);	\Get character of text
		Inx:= Inx + 1;
		if Ch = CR then quit;
		if Ch = Tab then	\Convert tabs to spaces (tab stops are
			begin		\ oriented to starting column)
			repeat Chout(TV, ^ );
				X:= X + 1;
				if X >= ScreenWidth-1 then quit;
			until (X - (if ShowingCount then 26 else 12) & $07) = 0;
			end
		else	begin		\Display normal character
			Chout(TV, Ch);
			X:= X + 1;
			if X >= ScreenWidth-1 then quit;
			end;
		end;
	while X < ScreenWidth-1 do	\Erase rest of line
		begin
		Chout(TV, ^ );
		X:= X + 1;
		end;
	end;	\ShowLine


begin	\ShowCode
ShowMouse(false);
\if Addr is not in window then set WinPtr to Addr, with one extra line at top.
if Addr <= WinPtr  !  Addr >= WinPtr+WinHeight then WinPtr:= Addr -1;

PCLine:= 0;	\Undefined unless determined below to be in listing window
\Display lines starting at WinPtr
for Y:= ListWinY, ScreenHeight-2 do	\For all lines in listing window...
	begin
	Cursor(1, Y);
	Attrib(Blue<<4 ! Yellow);	\Assume no cursors
	A:= WinPtr + Y - ListWinY;	\Get ROM address of line to be displayed
	if A = PC then PCLine:= Y;	\Tell others what line PC cursor is on
	if A<0 ! A>=ROMSize then Spout(TV, ScreenWidth-2)
	else	begin
		\Show colored cursors for PC, LineCursor, and breakpoints
		if Breakpoint(A) then Attrib(Red<<4 ! Yellow);
		ShowLine(A);
		end;
	end;

if HaveMouse then
	begin				\Show scroll bar
	Attrib(Blue<<4 ! White);
	Cursor(ScreenWidth-1, ListWinY);
	Chout(TV, $1E);			\Up arrow
	Cursor(ScreenWidth-1, ScreenHeight-2);
	Chout(TV, $1F);			\Down arrow

	\Draw knob at new location
	KnobX:= ScreenWidth-1;
	\KnobYOffset/ScrollBarHeight = WinPtr/ROMSizeEven
	A:= Fix( Float(WinPtr) * Float(ScrollBarHeight-1) / Float(ROMSizeEven) );
	KnobY:= A + ListWinY + 1;

	for Y:= ListWinY+1, ScreenHeight-3 do
		begin
		Cursor(ScreenWidth-1, Y);
		Chout(TV, if Y = KnobY then $FE else $DB);   \$FE = Knob symbol
		end;
	end;
ShowMouse(true);
end;	\ShowCode

\===============================================================================

proc	SaveRegs;
\Record displayed values so that any changes can be displayed in bright white
int	I;
begin
PC0:= PC;
WReg0:= WReg;
Option0:= Option;
MBits0:= MBits;
TRISA0:= TRISA;   TRISB0:= TRISB;   TRISC0:= TRISC;
LATCHA0:= LATCHA;   LATCHB0:= LATCHB;   LATCHC0:= LATCHC;
for I:= 0, RAMSize-1 do RAM0(I):= RAM(I);
for I:= 0, 8-1 do Stack0(I):= Stack(I);
end;	\SaveRegs

\------------------------------------------------------------------------------

proc	DisplayRegs;	\Display contents of RAM and other registers
int	I, J, Addr, Ghost, GhostRC,
	S, S1, B;	\Used for status bits
char	Str;
real	Cycles,		\Number of instruction cycles
	Clock,		\Instruction clock frequency (Osc or Osc/4.0)
	O,		\Local copy of Osc
	Time;		\Amount of time used to execute instruction cycles
begin
RAM(INDF):= RAM(Map(RAM(FSR)));		\Lie for the display
RAM(PCL):= PC;
RAM(PORTA):= RAM(PORTA) & $0F;
RAM0(PORTA):= RAM0(PORTA) & $0F;

ShowMouse(false);

Cursor(SpecialRegX-8, SpecialRegY+1);
Attrib(White<<4 ! Black);
if FUSE & $200 ! Option & $80 then
	begin
	RAM(RTCC):= Timer;		\Map Timer into RTCC location
	Text(TV, "RTCC");
	end
else	begin
	RAM(RTCC):= WReg;		\Map W into RTCC location (for safety)
	Text(TV, "W   ");
	end;

for I:= 0, 7 do							\Special Regs
	begin
	Cursor(SpecialRegX-1, SpecialRegY+I);
	if I = 7 \RC\ & (FUSEX & $C00) = 0 \18pin\ then Attrib(Cyan<<4 ! White)
	else	Attrib(Cyan<<4 ! (if RAM(I) = RAM0(I) then Black else BWhite));
	Chout(TV, ^ );
	if I = 5\PORTA\ then
		begin
		Chout(TV, ^ );
		Hex1Out(TV, RAM(I));
		end
	else	Hex2Out(TV, RAM(I));
	Chout(TV, if DoneRAM(I) then ^ú else ^ );
	end;

for I:= 0, StackSize-1 do						\Stack
	begin
	Stack(I):= Stack(I) & ROMMask;
	Stack0(I):= Stack0(I) & ROMMask;
	Cursor(StackX-1, StackY+I);
	Attrib(Cyan<<4 ! (if Stack(I) = Stack0(I) then Black else BWhite));
	Chout(TV, ^ );   Hex3Out(TV, Stack(I));   Chout(TV, ^ );
	end;
Attrib(Cyan<<4 ! White);
for I:= StackSize, 8-1 do		\Ghost any unused portion of stack
	begin
	Cursor(StackX-1, StackY+I);
	Chout(TV, ^ );   Hex3Out(TV, Stack(I));   Chout(TV, ^ );
	end;

Addr:= 0;								\RAM
GhostRC:= if (FUSEX & $C00) = 0 \18pin\ then $06 else $07;
for I:= 0, 8 do
	begin
	Cursor(RAMX-6, RAMY+I);
	Attrib(White<<4 ! Black);
	Text(TV, if I-1 = RAM(FSR)>>5 then "->" else "  ");

	Cursor(RAMX-1, RAMY+I);
	Attrib(Cyan<<4 ! Black);	\(background for space character)
	for J:= 0, $F do
		begin
		if (J&3) = 0 then Chout(TV, ^ );
		if Addr <= GhostRC then
			begin
			Attrib(Cyan<<4 ! White);
			Text(TV, "<- ");		\Arrow to special regs
			end
		else	begin
			Ghost:= Addr >= $10;		\Ghost unactivated RAM
			case FUSEX & $00C of
			  $C:	if Addr >= $10 then Ghost:= false;
			  $8:	if Addr >= $90 then Ghost:= false;
			  $4:	if Addr >= $D0 then Ghost:= false;
			  $0:	if Addr >= $F0 then Ghost:= false
			other;
			Attrib(Cyan<<4 ! (if Ghost then White else
			    (if RAM(Addr) = RAM0(Addr) then Black else BWhite)));
			Hex2Out(TV, RAM(Addr));
			Chout(TV, if DoneRAM(Addr) then ^ú else ^ );
			end;
		Addr:= Addr + 1;
		end;
	if Addr # $10 then Addr:= Addr + $10;
	end;

PC:= PC & ROMMask;
PC0:= PC0 & ROMMask;
Cursor(PCX-1, PCY);							\PC
Attrib(Cyan<<4 ! (if PC = PC0 then Black else BWhite));
Chout(TV, ^ );   Hex3Out(TV, PC);   Chout(TV, ^ );

MBits:= MBits & $0F;
MBits0:= MBits0 & $0F;
Cursor(MBitsX-1, MBitsY);						\MBits
Attrib(Cyan<<4 ! (if MBits = MBits0 then Black else BWhite));
Chout(TV, ^ );   Hex1Out(TV, MBits);   Chout(TV, ^ );

Option:= Option & $FF;
Option0:= Option0 & $FF;
Cursor(OptionX-1, OptionY);						\Option
Attrib(Cyan<<4 ! (if Option = Option0 then Black else BWhite));
Chout(TV, ^ );   Hex2Out(TV, Option);   Chout(TV, ^ );

Cursor(Fuse_X, Fuse_Y);							\Fuse
Attrib(Cyan<<4 ! Black);
Hex3Out(TV, Fuse);

Cursor(FusexX, FusexY);							\Fusex
Attrib(Cyan<<4 ! Black);
Hex3Out(TV, Fusex);

\Display WDT time in either seconds (s), milliseconds (m), or microseconds (æ):
if FUSE & $004 then							\WDT
	begin		\Enabled
	Cycles:= Float(WDT1) * 10000.0 + Float(WDT0);
	Clock:= if FUSE & $800 \~Turbo\ then Osc/4.0 else Osc;
	if Option & $08\PSA\ then	\Prescaler assigned to WDT
		Cycles:= Cycles * Float( 1<<(Option & $07) );
	Time:= Cycles / Clock;
	end
else	Time:= 0.0;	\Disabled

I:= 0;
loop	begin
	if Time>=0.9995 ! Time=0.0 then quit;	\(0.9995 is rounded up to 1.000)
	Time:= Time * 1000.0;
	I:= I + 1;
	end;
Cursor(WDTX-1, WDTY);
Attrib(Cyan<<4 ! (if FUSE & $004 \enabled\ then BWhite else Black));
Chout(TV, ^ );
case of
  Time < 9.9995: J:= 3;
  Time < 99.995: J:= 2
other	J:= 1;
Format(1, J);
Rlout(6, Time);
Str:= "smænpf ";	\(way more than enough units)
Chout(6, Str(I));
Chout(TV, ^ );

\Display Osc in either megahertz (M) or kilohertz (k):
I:= 0;									\Osc
O:= Osc;
loop	begin
	if O < 999.9995 then quit;	\(beware of rounding)
	O:= O / 1000.0;
	I:= I + 1;
	end;
Cursor(OscX, OscY);
Attrib(Cyan<<4 ! Black);
Format(3, 3);
Rlout(6, O);
Str:= "HkMGT ";		\(way more than enough units)
Chout(6, Str(I));

\Display Time in either seconds (s), milliseconds (m), or microseconds (æ): Time
Cycles:= (Float(Cycles2)*10000.0 + Float(Cycles1))*10000.0 + Float(Cycles0);			\Time
Clock:= if FUSE & $800 \~Turbo\ then Osc/4.0 else Osc;
Time:= Cycles / Clock;
I:= 4;			\Index for "s" = seconds
if Time # 0.0 then
	begin
	while Time < 0.9995 do		\(0.9995 is rounded up to 1.000)
		begin
		Time:= Time * 1000.0;
		I:= I + 1;
		end;
	while Time >= 999.5 do
		begin
		Time:= Time / 1000.0;
		I:= I - 1;
		end;
	end;

Cursor(TimeX, TimeY);
Attrib(Cyan<<4 ! BWhite);
Format(3, 3);
Rlout(6, Time);
Str:= "TGMksmænpf ";	\(way more than enough units)
Chout(6, Str(I));

WReg:= WReg & $FF;
WReg0:= WReg0 & $FF;
Cursor(WRegX-1, WRegY);
Attrib(Cyan<<4 ! (if WReg = WReg0 then Black else BWhite));		\WReg
Chout(TV, ^ );   Hex2Out(TV, WReg);   Chout(TV, ^ );
Cursor(WRegX+4-1, WRegY);
Chout(TV, ^ );
Chout(TV, if WReg#CR & WReg#LF then WReg else ^ );
Chout(TV, ^ );
Cursor(WRegX-4, WRegY+1);
Chout(TV, ^ );   Bin8OutColor(TV, WReg, WReg|WReg0);   Chout(TV, ^ );

S:= RAM(STATUS);							\STATUS
S1:= S | RAM0(STATUS);
B:= $80;
for I:= 0, 7 do
	begin
	Cursor(StatusX+StatusTable(I)-1, StatusY);
	Attrib(Cyan<<4 ! (if S1 & B then BWhite else Black));
	Chout(TV, ^ );   Chout(TV, if S & B then ^1 else ^0);   Chout(TV, ^ );
	B:= B >> 1;
	end;


Cursor(PortX, PortY);							\TRISA
Bin4OutColor(TV, TRISA, TRISA|TRISA0);

Cursor(PortX, PortY+1);
Bin4OutColor(TV, LATCHA, LATCHA|LATCHA0);

Cursor(PortX, PortY+2);
Bin4OutColor(TV, RAM(PORTA), RAM(PORTA)|RAM0(PORTA));


Cursor(PortX+5, PortY);							\TRISB
Bin8OutColor(TV, TRISB, TRISB|TRISB0);

Cursor(PortX+5, PortY+1);
Bin8OutColor(TV, LATCHB, LATCHB|LATCHB0);

Cursor(PortX+5, PortY+2);
Bin8OutColor(TV, RAM(PORTB), RAM(PORTB)|RAM0(PORTB));


if (FUSEX & $C00) = 0 \18pin\ then					\TRISC
	begin
	Attrib(Cyan<<4 ! White);	\Ghost

	Cursor(PortX+14, PortY);
	Bin8Out(TV, TRISC);

	Cursor(PortX+14, PortY+1);
	Bin8Out(TV, LATCHC);

	Cursor(PortX+14, PortY+2);
	Bin8Out(TV, RAM(PORTC));
	end
else	begin
	Cursor(PortX+14, PortY);
	Bin8OutColor(TV, TRISC, TRISC|TRISC0);

	Cursor(PortX+14, PortY+1);
	Bin8OutColor(TV, LATCHC, LATCHC|LATCHC0);

	Cursor(PortX+14, PortY+2);
	Bin8OutColor(TV, RAM(PORTC), RAM(PORTC)|RAM0(PORTC));
	end;

ShowMouse(true);

SaveRegs;
RAM(INDF):= $00;	\Cover the lie
end;	\DisplayRegs

\-------------------------------------------------------------------------------

proc	ShowLabels;	\Display legends, etc.
begin
ShowMouse(false);
Hilight(0, 0, ScreenWidth-1, ListWinY-1, White<<4!Black);

Cursor(0, 0);
Attrib(White<<4 ! Black);
RawText(TV, if HaveMouse then "[þ] " else "    ");
Attrib(White<<4 ! Red);
Text(TV, " SxSim 1.05");
Attrib(White<<4 ! Black);
Text(TV,
"  STACK        0  1  2  3   4  5  6  7   8  9  A  B   C  D  E  F
 0 IND                  00 
 1                      10 
 2 PC                   30 
 3 STATUS               50 
 4 FSR                  70 
 5 RA                   90 
 6 RB                   B0 
 7 RC                   D0 
                        F0 
  PC  MODE  OPTION  FUSE  FUSEX   WDT     OSC     PORT   RA     RB       RC   
                                                  TRIS                        
  W         PA2 PA1 PA0 TO PD Z  DC C    TIME     LATCH                       
                                                  PIN                         ");

\Spaces at end of lines are required because CR does not clear the rest of line.
\ Garbage from the help screen will appear otherwise.

Hilight(PCX-1, PCY, OscX+8, PCY, Cyan<<4!Black);
Hilight(StatusX-5, StatusY, TimeX+8, StatusY, Cyan<<4!Black);
Hilight(PortX-1, PortY, PortX+22, PortY+2, Cyan<<4!Black);
ShowMouse(true);
end;	\ShowLabels

\-------------------------------------------------------------------------------

proc	ShowPrompts;	\Show key commands on prompt line
int	X, F;
begin
ShowMouse(false);
Cursor(1, ScreenHeight-1);
Attrib(White<<4 ! Black);
Text(TV,
"F1=Help F2=Bkpt F3=Clear F4=Here F5=Time F6=Go F7=Step F8=Over F9=Run F10=MClr");

\    F0   1   2   3   4   5   6   7   8   9  10		(Also see DoCmd)
X:= [-1,  1,  9, 17, 26, 34, 42, 48, 56, 64, 71];	\X coordinates of "Fn"
Attrib(White<<4 ! Red);
for F:= 1, 10 do
    if X(F) >= 0 then
	begin
	Cursor(X(F), ScreenHeight-1);
	Chout(TV, ^F);
	Intout(TV, F);
	end;
ShowMouse(true);
end;	\ShowPrompts



proc	ShowAltPrompts;	\Show Alt key commands on prompt line
int	X, F;
begin
ShowMouse(false);
Cursor(1, ScreenHeight-1);
Attrib(White<<4 ! Red);
Text(TV,
"Alt:");
Attrib(White<<4 ! Black);
Text(TV,
" F1=Output  F3=Count F4=Jump       F6=Slow F7=Back F8=Return     F10=Reset");

\    F0   1   2   3   4   5   6   7   8   9  10		(Also see DoCmd)
X:= [-1,  6, -1, 17, 26, -1, 40, 48, 56, -1, 70];	\X coordinates of "Fn"
Attrib(White<<4 ! Red);
for F:= 1, 10 do
    if X(F) >= 0 then
	begin
	Cursor(X(F), ScreenHeight-1);
	Chout(TV, ^F);
	Intout(TV, F);
	end;
ShowMouse(true);
end;	\ShowAltPrompts



proc	ShowShiftPrompts;	\Show Shift key commands on prompt line
begin
ShowMouse(false);
Cursor(1, ScreenHeight-1);
Attrib(White<<4 ! Red);
Text(TV, "Shift:");
Attrib(White<<4 ! Black);
Text(TV," Save checkpoint");
Attrib(White<<4 ! Red);
Text(TV,"     F1   F2   F3   F4   F5   F6   F7   F8   F9   F10   ");
	\(Also see DoCmd)
ShowMouse(true);
end;	\ShowShiftPrompts



proc	ShowCtrlPrompts;	\Show Ctrl key commands on prompt line
begin
ShowMouse(false);
Cursor(1, ScreenHeight-1);
Attrib(White<<4 ! Red);
Text(TV, "Ctrl:");
Attrib(White<<4 ! Black);
Text(TV,"  Restore checkpoint");
Attrib(White<<4 ! Red);
Text(TV,"  F1   F2   F3   F4   F5   F6   F7   F8   F9   F10   ");
	\(Also see DoCmd)
ShowMouse(true);
end;	\ShowCtrlPrompts



proc	ShowPromptLine(Force);	\Display prompt line
int	Force;		\Force display, don't assume it's already displayed
int	KeyFlags, OldKeyFlags;
begin
OldKeyFlags:= [0];		\Own variable
KeyFlags:= CallInt($16, $0200);
\Bit: 0=right Shift, 1=left Shift, 2=Ctrl, 3=Alt
if Force  !  KeyFlags # OldKeyFlags(0) then
	begin
	case of
	 KeyFlags & $08: ShowAltPrompts;
	 KeyFlags & $04: ShowCtrlPrompts;
	 KeyFlags & $03: ShowShiftPrompts
	other ShowPrompts;
	OldKeyFlags(0):= KeyFlags;
	end;
end;	\ShowPromptLine

\-------------------------------------------------------------------------------

proc	ShowRunning;	\Show "Running..." message on prompt line
char	Msg;
begin
ShowMouse(false);
Cursor(0, ScreenHeight-1);
Attrib(White<<4 ! Black);
Spout(TV, ScreenWidth-1);
Msg:= "Running...";
Cursor((ScreenWidth-StrLen(Msg))>>1, ScreenHeight-1);
Attrib(Flashing ! White<<4 ! LGreen);
Text(TV, Msg);
ShowMouse(true);
end;	\ShowRunning



proc	Error(Msg);	\Display error message centered on bottom line
char	Msg;
begin
ShowMouse(false);
CallInt($10, $0500);	\Set page 0 (in case of OUTPUT instr)
Cursor(0, ScreenHeight-1);
Attrib(White<<4 ! Black);
Spout(TV, ScreenWidth-1);

Cursor((ScreenWidth-StrLen(Msg))>>1, ScreenHeight-1);
Attrib(Flashing ! White<<4 ! LRed);
Text(TV, Msg);
ShowMouse(true);
Chout(0, Bel);

while GetMouseButton(0) ! GetMouseButton(1) do;	\Wait for release
Openi(0);

\Wait for keystroke or mouse button
repeat until Chkkey ! GetMouseButton(0) ! GetMouseButton(1);
Openi(0);		\Clear possible keystroke
while GetMouseButton(0) ! GetMouseButton(1) do;	\Wait for release

ShowPromptLine(true);
TraceMode:= true;
end;	\Error



proc	IllegalOp;
begin
Error("ILLEGAL OPCODE");
end;	\IllegalOp

\===============================================================================

proc	PointOut;	\Point out locations about to be used by Execute
\Inputs: PCLine (from ShowCode--line to display GOTO arrow, etc.)
int	D,	\Destination select; D=0 store result in W, else store in FRA
	B,	\Bit
	Opcode;	\Instruction code (12 bits)
def	PromptCol=10;



proc	BacklightStack;	\Highlight top location on stack
begin
Backlight(StackX-1, StackY, StackX+3, StackY, Green);
end;	\BacklightStack



proc	BacklightPC;
begin
Backlight(PCX-1, PCY, PCX+3, PCY, Green);
Backlight(SpecialRegX-1, SpecialRegY+2, SpecialRegX+2, SpecialRegY+2, Green);
end;	\BacklightPC



proc	BacklightMBits;
begin
Backlight(MBitsX-1, MBitsY, MBitsX+1, MBitsY, Green);
end;	\BacklightMBits



proc	BacklightOption;
begin
Backlight(OptionX-1, OptionY, OptionX+2, OptionY, Green);
end;	\BacklightOption



proc	BacklightWDT;
begin
Backlight(WDTX-1, WDTY, WDTX+6, WDTY, Green);
end;	\BacklightWDT



proc	BacklightWReg;
begin
Backlight(WRegX-1, WRegY, WRegX+5, WRegY, Green);
Backlight(WRegX-4, WRegY+1, WRegX+5, WRegY+1, Green);

if (FUSE & $200) = 0  &  (Option & $80) = 0 then	\WReg mapped into RTCC
	Backlight(SpecialRegX-1, SpecialRegY+RTCC,
		SpecialRegX+2, SpecialRegY+RTCC, Green);
end;	\BacklightWReg



proc	BacklightTRISA;
begin
Backlight(PortX, PortY, PortX+3, PortY, Green);				\TRISA
Backlight(PortX, PortY+2, PortX+3, PortY+2, Green);			\PINA
Backlight(SpecialRegX-1, SpecialRegY+5, SpecialRegX+2, SpecialRegY+5, Green);
end;	\BacklightTRISA



proc	BacklightTRISB;
begin
Backlight(PortX+5, PortY, PortX+5+7, PortY, Green);			\TRISB
Backlight(PortX+5, PortY+2, PortX+5+7, PortY+2, Green);			\PINB
Backlight(SpecialRegX-1, SpecialRegY+6, SpecialRegX+2, SpecialRegY+6, Green);
end;	\BacklightTRISB



proc	BacklightTRISC;
begin
Backlight(PortX+14, PortY, PortX+14+7, PortY, Green);			\TRISC
Backlight(PortX+14, PortY+2, PortX+14+7, PortY+2, Green);		\PINC
Backlight(SpecialRegX-1, SpecialRegY+7, SpecialRegX+2, SpecialRegY+7, Green);
end;	\BacklightTRISC



proc	BacklightPortA(Read, Bit);
int	Read, Bit;
begin
Backlight(PortX+3-Bit, PortY+2, PortX+3-Bit, PortY+2, Green);		\PINA
Backlight(SpecialRegX-1, SpecialRegY+5, SpecialRegX+2, SpecialRegY+5, Green);
if Read then return;
Backlight(PortX+3-Bit, PortY+1, PortX+3-Bit, PortY+1, Green);		\LATCHA
end;	\BacklightPortA



proc	BacklightPortB(Read, Bit);
int	Read, Bit;
begin
Backlight(PortX+5+7-Bit, PortY+2, PortX+5+7-Bit, PortY+2, Green); 	\PINB
Backlight(SpecialRegX-1, SpecialRegY+6, SpecialRegX+2, SpecialRegY+6, Green);
if Read then return;
Backlight(PortX+5+7-Bit, PortY+1, PortX+5+7-Bit, PortY+1, Green);	\LATCHB
end;	\BacklightPortB



proc	BacklightPortC(Read, Bit);
int	Read, Bit;
begin
Backlight(PortX+14+7-Bit, PortY+2, PortX+14+7-Bit, PortY+2, Green);	\PINC
Backlight(SpecialRegX-1, SpecialRegY+7, SpecialRegX+2, SpecialRegY+7, Green);
if Read then return;
Backlight(PortX+14+7-Bit, PortY+1, PortX+14+7-Bit, PortY+1, Green);	\LATCHC
end;	\BacklightPortC



proc	BacklightRAM(A);	\Highlight RAM at address A
int	A;
int	GhostRC, I, X, Y;
begin
A:= Map(A);
GhostRC:= if (FUSEX & $C00) = 0 \18pin\ then $06 else $07;
if A <= GhostRC then
	begin
	Backlight(SpecialRegX-1, SpecialRegY+A, SpecialRegX+2, SpecialRegY+A,
		Green);
	case A of
	  RTCC:	 if (FUSE & $200) = 0  &  (Option & $80) = 0 then BacklightWReg;
	  PCL:	 BacklightPC;
	  PORTA: for I:= 0, 3 do BacklightPortA(false, I);
	  PORTB: for I:= 0, 7 do BacklightPortB(false, I);
	  PORTC: for I:= 0, 7 do BacklightPortC(false, I)
	other;
	end
else	begin
	X:= (A & $0F) * 3 + (A>>2 & $03);
	if A >= $10 then A:= A + $10;
	Y:= A >> 5;
	Backlight(RAMX+X-1, RAMY+Y, RAMX+X+2, RAMY+Y, Green);
	end;
end;	\BacklightRAM



proc	BacklightStatus(Bit);
int	Bit;
int	I;
begin
BacklightRAM(STATUS);
I:= 7 - Bit;
Backlight(StatusX+StatusTable(I)-1, StatusY, StatusX+StatusTable(I)+1, StatusY,
	Green);
end;	\BacklightStatus

\-------------------------------------------------------------------------------

proc	Class00;	\Point out locations for 0000 0000 xxxx instructions
begin
case Opcode & $000F of
  $00:	begin								\NOP
	end;
  $01:	begin								\PRINT
	end;
  $02:	begin								\OPTION
	BacklightOption;
	BacklightWReg;
	end;
  $03,									\SLEEP
  $04:	begin								\CLRWDT
	BacklightWDT;
	BacklightStatus(4);
	BacklightStatus(3);
	end;
  $05:	begin								\TRIS A
	BacklightWReg;
	if (MBits & $0F) = $0F then BacklightTRISA;
	end;
  $06:	begin								\TRIS B
	BacklightWReg;
	if (MBits & $0F) = $0F then BacklightTRISB;
	end;
  $07:	begin								\TRIS C
	BacklightWReg;
	if (MBits & $0F) = $0F then BacklightTRISC;
	end;
  $0A:	begin								\INPUT
	end;
  $0B:	begin								\OUTPUT
	end;
  $0C:	begin								\RETURN
	BacklightStack;
	BacklightPC;
	if PCLine\#0\ then
		begin
		Cursor(PromptCol, PCLine);	\Show up or down arrow
		Chout(1, if Stack(0) > PC then Dn else Up);
		end;
	end;
  $0D:	begin								\RETP
	BacklightStack;
	BacklightPC;
	if PCLine\#0\ then
		begin
		Cursor(PromptCol, PCLine);	\Show up or down arrow
		Chout(1, if Stack(0) > PC then Dn else Up);
		end;
	BacklightStatus(7);			\(4K part assumed ??)
	BacklightStatus(6);
	BacklightStatus(5);
	end;
  $0E:	begin								\RETI
	BacklightPC;
	if PCLine\#0\ then
		begin
		Cursor(PromptCol, PCLine);	\Show up or down arrow
		Chout(1, if Stack(0) > PC then Dn else Up);
		end;
	BacklightWReg;
	BacklightRAM(STATUS);
	BacklightRAM(FSR);
	end;
  $0F:	begin								\RETIW
	BacklightPC;
	if PCLine\#0\ then
		begin
		Cursor(PromptCol, PCLine);	\Show up or down arrow
		Chout(1, if Stack(0) > PC then Dn else Up);
		end;
	BacklightWReg;
	BacklightRAM(STATUS);
	BacklightRAM(FSR);
	BacklightRAM(RTCC);	\(ok if WReg is mapped at loc 01)
	end
other	[];		\Illegal ops are handled by Execute
end;	\Class00



proc	Class0;		\Point out locations for 00xx xxxx xxxx instructions

	proc	BacklightFRA;	\Highlight location at file register address
	int	FRAx;
	begin
	FRA:= Opcode & $001F  !  RAM(FSR) & $E0;
	BacklightRAM(FRA);
	if (FRA & $1F) = INDF then
		begin
		FRA:= RAM(FSR);
		BacklightRAM(FRA);
		BacklightRAM(FSR);
		end;
	if (FRA & $1F) = FSR then
		begin
		FRAx:= RAM(FSR);
		BacklightRAM(FRAx);
		BacklightRAM(INDF);
		end;
	end;	\BacklightFRA

begin
D:=  Opcode & $0020;  \Destination select; D=0 store into W else store into FRA

case Opcode>>6 & $000F of
  $0:	begin
	case Opcode>>4 & $0003 of
	  0:	Class00;
	  1:	if Opcode & $0008 then
			begin						\BANK
			BacklightRAM(FSR);
			end
		else	begin						\PAGE
			BacklightStatus(7);
			BacklightStatus(6);
			BacklightStatus(5);
			end
	other	begin							\MOVWF
		BacklightFRA;
		BacklightWReg;
		end;
	end;

  $1:	begin
	case Opcode>>4 & $0003 of
	  0:	begin
		case Opcode & $3F of
		  0:	begin						\CLRW
			BacklightWReg;
			BacklightStatus(2);
			end;
		  1,							\IREAD
		  2,							\MOVMW
		  3:	begin						\MOVWM 
			BacklightWReg;
			BacklightMBits;
			end
		other	[];		\Illegal ops are handled by Execute
		end;

	  1:	begin							\MODE 
		BacklightMBits;
		end
	other	begin							\CLRF
		BacklightFRA;
		BacklightStatus(2);
		end;
	end;

  $2,									\SUBWF
  $7:	begin								\ADDWF
	BacklightFRA;
	BacklightStatus(2);
	BacklightStatus(1);
	BacklightStatus(0);
	BacklightWReg;
	end;
  $3,									\DECF
  $8,									\MOVF
  $9,									\COMF
  $A:	begin								\INCF
	BacklightFRA;
	BacklightStatus(2);
	if D = 0 then BacklightWReg;
	end;
  $4,									\IORWF
  $5,									\ANDWF
  $6:	begin								\XORWF
	BacklightFRA;
	BacklightStatus(2);
	BacklightWReg;
	end;
  $B,									\DECFSZ
  $F:	begin								\INCFSZ
	BacklightFRA;
	BacklightPC;
	if D = 0 then BacklightWReg;
	end;
  $C,									\RRF
  $D:	begin								\RLF
	BacklightFRA;
	BacklightStatus(0);
	if D = 0 then BacklightWReg;
	if PCLine\#0\ then
		begin
		Cursor(PromptCol, PCLine);	\Show up or down arrow
		Chout(1, if Opcode & $040 then ^® else ^¯);
		end;
	end;
  $E:	begin								\SWAPF
	BacklightFRA;
	if D = 0 then BacklightWReg;
	end
other;
end;	\Class0



proc	Class1;		\Point out locations for 01xx xxxx xxxx instructions
int	GhostRC, FRAx, Read;	\ (BCF, BSF, BTFSC, BTFSS)
begin
FRA:= Opcode & $001F  !  RAM(FSR) & $E0;

GhostRC:= if (FUSEX & $C00) = 0 \18pin\ then $06 else $07;
if (FRA & $1F) < PORTA  !  (FRA & $1F) > GhostRC then BacklightRAM(FRA);
if (FRA & $1F) = INDF then
	begin
	FRA:= RAM(FSR);
	if (FRA & $1F) < PORTA  !  (FRA & $1F) > GhostRC then BacklightRAM(FRA);
	BacklightRAM(FSR);
	end;
if (FRA & $1F) = FSR then
	begin
	FRAx:= RAM(FSR);
	if (FRAx & $1F) < PORTA ! (FRAx & $1F) >GhostRC then BacklightRAM(FRAx);
	BacklightRAM(INDF);
	end;

B:= Opcode>>5 & $0007;

case Opcode>>8 & $0003 of
  $0, $1: [];								\BCF BSF
  $2:	begin								\BTFSC
	BacklightPC;
	if PCLine\#0\ then
		begin
		Cursor(PromptCol, PCLine);
		Chout(1, if RAM(Map(FRA)) & 1<<B then Space else Dn);
		end;
	end;
  $3:	begin								\BTFSS
	BacklightPC;
	if PCLine\#0\ then
		begin
		Cursor(PromptCol, PCLine);
		Chout(1, if RAM(Map(FRA)) & 1<<B then Dn else Space);
		end;
	end
other;

\If FRA = PORT or STATUS then highlight individual bit
Read:= Opcode & $0200;
case FRA & $1F of
  STATUS:	BacklightStatus(B);
  PORTA:	BacklightPortA(Read,B);
  PORTB:	BacklightPortB(Read,B);
  PORTC:	if (FUSEX & $C00) \28pin\ then BacklightPortC(Read,B)
other;
end;	\Class1



proc	Class2;		\Point out locations for 10xx xxxx xxxx instructions
begin
case Opcode>>8 & $0003 of
$0:	begin								\RETLW
	BacklightWReg;
	BacklightStack;
	BacklightPC;
	if PCLine\#0\ then
		begin
		Cursor(PromptCol, PCLine);	\Show up or down arrow
		Chout(1, if Stack(0) > PC then Dn else Up);
		end;
	end;
  $1:	begin								\CALL
	BacklightStack;
	BacklightPC;
	if PCLine\#0\ then
		begin
		Cursor(PromptCol, PCLine);	\Show up or down arrow
		Chout(1, if (Opcode & $00FF ! RAM(STATUS)<<4 & $0600) > PC then
			Dn else Up);			\Show up or down arrow
		end;
	end;
  $2,									\GOTO
  $3:	begin								\GOTO
	BacklightPC;
	if PCLine\#0\ then
		begin
		Cursor(PromptCol, PCLine);	\Show up or down arrow
		Chout(1, if (Opcode & $01FF ! RAM(STATUS)<<4 & $0600) > PC then
			Dn else Up);			\Show up or down arrow
		end;
	end
other;
end;	\Class2



proc	Class3;		\Point out locations for 11xx xxxx xxxx instructions
begin			\ (MOVLW, IORLW, ANDLW, XORLW)
BacklightWReg;
if (Opcode>>8 & $0003) # 0 then BacklightStatus(2);
	\Everything except MOVLW affects ZF
end;	\Class3



begin	\PointOut
ShowMouse(false);
Opcode:= ROM(PC & ROMMask);	\Fetch instruction from ROM
case Opcode >> 10 of
  0:	Class0;
  1:	Class1;
  2:	Class2;
  3:	Class3
other	[];			\Illegal ops are handled by Execute
ShowMouse(true);
end;	\PointOut

\===============================================================================

proc	ShowHelp;	\Show help screen
int	Y;
begin
ShowMouse(false);

Attrib(White<<4 ! Black);
for Y:= ListWinY, ScreenHeight-2 do	\Erase LineCursor arrow
	begin
	Cursor(0, Y);
	Chout(TV, ^ );
	end;

Cursor(0, 0);
Spout(TV, ScreenWidth-1);
Cursor(ScreenWidth>>1-4, 0);
Text(TV, "HELP");

if HaveMouse then
	begin
	\Remove any scroll bar
	Attrib(White<<4 ! Black);
	for Y:= ListWinY, ScreenHeight-2 do
		begin
		Cursor(ScreenWidth-1, Y);
		Chout(TV, ^ );
		end;
	end;

Attrib(Blue<<4 ! Yellow);
SetWind(1, 1, ScreenWidth-2, ScreenHeight-2, 2, true);

\(Tabs don't work here)
Text(TV, "
       F1  Help    Show this help screen
       F2  Bkpt    Set or clear breakpoint at line cursor (toggles)
       F3  Clear   Remove all breakpoints
       F4  Here    Execute code until line cursor is reached
       F5  Time    Reset elapsed time to zero
       F6  Go      Execute code and display result for each instruction
       F7  Step    Execute one instruction
       F8  Over    Same as F7 but skip over CALLs (run them at full speed)
       F9  Run     Execute code at full speed (until breakpoint)
       F10 MClr    Simulate master clear (hardware reset)
   Alt:
       F1  Output  Show screen used for OUTPUT instruction
       F3  Count   Show instruction execution counts
       F4  Jump    Jump to line-cursor location (without executing)
       F6  Slow    Execute and display at slow speed (Go Slow)
       F7  Back    Undo last instruction (step backward)
       F8  Return  Execute until return to caller (skip rest of CALL)
       F10 Reset   Simulate master clear and zero registers

       Spacebar    Execute one instruction (same as F7 and Enter)
       Backspace   Undo last instruction (same as Alt+F7)

       ^X ^Y         Move line cursor up or down a line
       Page Up/Dn  Move line cursor up or down a page
       Home        Move line cursor to location 000
       End         Move line cursor to last location

       Mouse       Left button:  Increment value / Set or clear breakpoint
                   Right button: Decrement value / Execute up to here
       Esc         Exit back to operating system

                                                     loren_blaney@idcomm.com");

\Last line overwrites previous lines if screen is small (clip in SetWind)

SetWind(0, 0, ScreenWidth-1, ScreenHeight-1, $0102, false);	\Turn off scroll

ShowMouse(true);
while GetMouseButton(0) ! GetMouseButton(1) do;	\Wait for release
Openi(0);

\Wait for keystroke or mouse button
repeat	ShowPromptLine(false);
until Chkkey ! GetMouseButton(0) ! GetMouseButton(1);

Openi(0);		\Clear possible keystroke
while GetMouseButton(0) ! GetMouseButton(1) do;	\Wait for release

ShowLabels;
end;	\ShowHelp



proc	ShowOutput;	\Show OUTPUT screen
int	Y;
begin
ShowMouse(false);
CallInt($10, $0501);	\Set page 1
ShowMouse(true);
while GetMouseButton(0) ! GetMouseButton(1) do;	\Wait for release
Openi(0);

\Wait for keystroke or mouse button
repeat
\ShowPromptLine(false);
until Chkkey ! GetMouseButton(0) ! GetMouseButton(1);

Openi(0);		\Clear possible keystroke
while GetMouseButton(0) ! GetMouseButton(1) do;	\Wait for release
ShowMouse(false);
CallInt($10, $0500);	\Set page 0
ShowMouse(true);
end;	\ShowOutput



func	VerifyExit;	\Show message and return true if verified
begin
ShowMouse(false);
Attrib(Blue<<4 ! Yellow);
SetWind((ScreenWidth-15)>>1, 5, (ScreenWidth+15)>>1-1, 5+2, 0, true);
Text(TV, "
  Exit (Y/N)?");

SetWind(0, 0, ScreenWidth-1, ScreenHeight-1, $0102, false);	\Turn off scroll
ShowMouse(true);

Openi(0);
repeat until Chkkey;				\Wait for keystroke
if (GetKey ! $20) = ^y then return true;	\(don't echo, especially Ctrl+C)

DisplayRegs;
ShowCode(LineCursor);	\(outputs PCLine)
PointOut;		\(inputs PCLine)
return false;
end;	\VerifyExit

\==============================================================================

proc	GetFUSE;	\Set FUSE registers & Osc with values saved on disk
int	Hand;
\Inputs: CfgFileName
\Outputs: FUSE, FUSEX, Osc, WDTPeriod
begin
Trap(false);
Hand:= Fopen(CfgFileName, 0);		\Get input handle
if Geterr \#0\ then	\If file not found then use default values for Scenix
	begin		\ (don't throw a fit: I/O ERROR)
	FUSE:= $0FB;
	FUSEX:= $7FE;
	Osc:= 1.0e6;	\(One microsecond per cycle provides a cycle counter)
	WDTPeriod:= 18e-3;
	end
else	begin
	Fset(Hand, ^I);
	Openi(3);
	FUSE:= Hexin(3);
	FUSEX:= Hexin(3);
	Osc:= Rlin(3);
	WDTPeriod:= Rlin(3);
	FClose(Hand);
	end;
Trap(Debug);
end;	\GetFUSE



proc	SaveFUSE;	\Save FUSE & Osc values to disk file
int	Hand;
\Inputs: CfgFileName, FUSE, FUSEX, Osc, WDTPeriod
begin
Hand:= Fopen(CfgFileName, 1);		\Get output handle
Fset(Hand, ^O);
Openo(3);
Hex3out(3, FUSE);   Crlf(3);
Hex3out(3, FUSEX);   Crlf(3);
Format(-1, 8);
Rlout(3, Osc);   Crlf(3);
Rlout(3, WDTPeriod);   Crlf(3);
Close(3);
FClose(Hand);
end;	\SaveFUSE



proc	Exit;		\Make a clean exit
begin
ShowMouse(false);
Chout(0, FF);
Text(0, "

SxSim 1.05, Copyright (C) 1998 Loren Blaney

SxSim comes with ABSOLUTELY NO WARRANTY.

This is free software. You are welcome and encouraged to redistribute
it under certain conditions. For details see LICENSE.DOC.


");
SaveFUSE;
SetColReg(Green, 0, 42, 0);		\Restore green intensity
CallInt($10, $0100, 0, CursorShape);	\Restore flashing cursor
exit;
end;	\Exit

\=============================== STIMULUS FILES ================================

proc	BumpTimer;	\Increment Timer and check for interrupt
begin
Timer:= Timer + 1;
if (Timer & $FF) = 0 then
	if (FUSE & $200) = 0  &  (Option & $40) = 0 then
		HaveInterrupt:= true;
end;	\BumpTimer



func	Getch;		\Get next character from .STM file
\Skip white space and comments; Convert to uppercase
int	Ch;
begin
loop	begin
	Ch:= Chin(3);
	while Ch <= $20 do
		begin
		if Ch = EOF then return EOF;
		Ch:= Chin(3);
		end;

	if Ch = ^; then
		begin
		repeat Ch:= Chin(3) until Ch=CR ! Ch=EOF;
		if Ch = EOF then return EOF;
		end
	else quit;
	end;

return if Ch>=^a & Ch<=^z then Ch&$DF else Ch;
end;	\Getch



proc	GetTime;	\Read time from .STM file and convert to StmCycles
int	Ch;
real	Clock, Cycles, Time, Now;
begin
Clock:= if FUSE & $800 \~Turbo\ then Osc/4.0 else Osc;

Ch:= StmChar;
if Ch = EOF then
	begin		\Set infinite time
	StmCycles:= 1e12;
	return;
	end;

Now:= 0.0;		\Assume absolute time will be input
if Ch = ^D then		\Delta time is input
	begin		\Determine current time (Now)
	Cycles:= (Float(Cycles2)*10000.0 + Float(Cycles1))*10000.0 +
		Float(Cycles0);
	Now:= Cycles / Clock;
	Ch:= Getch;
	end;
if Ch # ^T then Error("^"T^" expected in .STM file");
if Getch # ^= then Error("^"=^" expected in .STM file");
Time:= Rlin(3) + Now;
StmCycles:= Time * Clock;	\Convert time to cycles
end;	\GetTime



func	GetInput(In);
int	In;
int	Ch, B;
begin
Ch:= Getch;
if Ch = ^= then		\Full port (RB=D5h)
	In:= Hexin(3)
else if Ch >=^0 & Ch<=^7 then
	begin		\One pin (RB3=1)
	B:= Ch & $07;
	if Getch = ^= then
		begin
		case Getch of
		  ^0:	In:= In & ~(1<<B);
		  ^1:	In:= In ! 1<<B
		other	Error("0 or 1 expected in .STM file");
		end
	else Error("^"=^" expected in .STM file");
	end
else Error("^"=^" expected in .STM file");
return In;
end;	\GetInput



proc	Increment;	\Increment Timer if external clock pin is selected
int	OldPre;
begin
if Option & $20\T0CS\ then		\External clock pin selected
	begin
	if Option & $08\PSA\ then	\No prescaler
		begin
		if ClockInhibit = 0 then BumpTimer;
		end
	else	begin			\Prescaler
		OldPre:= Prescaler;
		Prescaler:= Prescaler + 1;
		OldPre:= (OldPre | Prescaler) & ~Prescaler;	\Carries
		if (OldPre & 1<<(Option & $07)) then
			if ClockInhibit = 0 then BumpTimer;
		end;
	end;
end;	\Increment



proc	DoInput;	\Change input according to stimulus file
int	N;
begin
case Getch of
  ^A:	RAM(PORTA):= GetInput(RAM(PORTA)) & TRISA  !  LATCHA & ~TRISA;
  ^B:	RAM(PORTB):= GetInput(RAM(PORTB)) & TRISB  !  LATCHB & ~TRISB;
  ^C:	begin
	if (FUSEX & $C00) = 0 \18pin\ then
		Error("RC not expected in .STM file");
	N:= GetInput(RAM(PORTC)) & TRISC  !  LATCHC & ~TRISC;
	if (FUSEX & $C00) \28pin\ then RAM(PORTC):= N;
	end;
  ^T:	begin		\RTCC=1
	if Getch # ^C then Error("^"C^" expected in .STM file");	\1st C
	if Getch # ^C then Error("^"C^" expected in .STM file");	\2nd C
	if Getch = ^= then
		begin
		case Getch of
		  ^0:	begin
			if RTCCPin#0 & (Option & $10)#0 then Increment;
			RTCCPin:= 0;
			end;
		  ^1:	begin
			if RTCCPin=0 & (Option & $10)=0 then Increment;
			RTCCPin:= 1;
			end
		other	Error("0 or 1 expected in .STM file");
		end
	else Error("^"=^" expected in .STM file");
	end
other	Error("A, B, C or T expected in .STM file");
StmChar:= Getch;
end;	\DoInput



proc	GetStimulus;	\Change input according to stimulus file
int	Ch;
begin
Ch:= Getch;
if Ch # ^R then Error("^"R^" expected in .STM file");
DoInput;

while StmChar = ^R do DoInput;
end;	\GetStimulus



proc	OpenStm;	\Open stimulus (.STM) file and get first Time
begin
Trap(false);
StmHandle:= Fopen(StmFileName, 0);		\Get input handle
StmExists:= false;
if Geterr = 0 then	\If file not found then use default values
	begin
	StmExists:= true;
	Fset(StmHandle, ^i);  \Use small buffer so checkpoints can use large one
	Openi(3);
	StmChar:= Getch;
	GetTime;
	end;
Trap(Debug);
Cycles0:= 0;   Cycles1:= 0;   Cycles2:= 0;	\Initialize cycle count
end;	\OpenStm



proc	ReOpenStm;	\Reopen stimulus (.STM) file and get first Time
begin
if StmExists then
	begin
	Openi(3);
	StmChar:= Getch;
	GetTime;
	end;
Cycles0:= 0;   Cycles1:= 0;   Cycles2:= 0;	\Initialize cycle count
end;	\ReOpenStm



proc	GetStmFilePtr;	\Get .STM file pointer
begin
if StmExists then
	begin
	CallInt($21, $4201, StmHandle, 0, 0);
	if Cpureg(7) \carry\ then Error("GetStmFilePtr failed");
	StmFilePtr0:= Cpureg(0);
	StmFilePtr1:= Cpureg(3);
	end;
end;	\GetStmFilePtr



proc	SetStmFilePtr;	\Set .STM file pointer
begin
if StmExists then
	begin
	CallInt($21, $4200, StmHandle, StmFilePtr1, StmFilePtr0);
	if Cpureg(7) \carry\ then Error("SetStmFilePtr failed");
	end;
end;	\SetStmFilePtr

\================================ CHECKPOINTS ==================================

proc	AppendCkp(N);
\Put checkpoint number (N) on end of file name, e.g: NAME.CP_
int	N;
int	I;
begin
if N = 10 then N:= 0;
if N<0 ! N>9 then Error("Illegal Checkpoint number");
for I:= 0, FileNameSize do
	begin
	if I >= FileNameSize then Error("File name missing ^".^"")
	else if CkpFileName(I) = ^. then
		begin
		if I+3 >= FileNameSize then Error("File name too long")
		else CkpFileName(I+3):= N + ^0;
		I:= FileNameSize;
		end;
	end;
end;	\AppendCkp



proc	SaveCheckPoint(N);	\Save most all variables to disk
int	N;			\Number (1 thru 10)
int	Hand, I;
char	A, B;
seg int	Screen(1);
begin
GetStmFilePtr;
AppendCkp(N);
Hand:= Fopen(CkpFileName, 1);	\Get output handle
Fset(Hand, ^O);
Openo(3);

A:= addr RAM;			\First global variable to save
B:= addr N;			\Last variable + 1
repeat	Chout(3, A(0));		\('for' loop won't work for unsigned addresses)
	A:= A +1;
until A = B;

\Save page 1, the output screen
Screen(0):= $B800 + ((ScreenHeight*ScreenWidth)<<1)>>4;
for I:= 0, ScreenHeight*ScreenWidth-1 do
	Chout(3, Screen(0, I));	\Save low byte, the character, of each word
Chout(3, Peek($40, $52));	\Save cursor position
Chout(3, Peek($40, $53));

Close(3);
FClose(Hand);
end;	\SaveCheckPoint



proc	RestoreCheckPoint(N);	\Load variables from saved disk file
int	N;	\(Must be at same heap location as it is in SaveCheckPoint)
int	Hand, I;
char	A, B;
seg int	Screen(1);
begin
AppendCkp(N);
Trap(false);
Hand:= Fopen(CkpFileName, 0);	\Get input handle
if Geterr \#0\ then
	Error("Ckeckpoint file not found")
else	begin
	Fset(Hand, ^I);
	Openi(3);

	A:= addr RAM;		\First global variable
	B:= addr N;		\Last variable + 1
	repeat	A(0):= Chin(3);	\('for' loop won't work for unsigned addresses)
		A:= A +1;
	until A = B;

	\Restore page 1, the output screen
	Screen(0):= $B800 + ((ScreenHeight*ScreenWidth)<<1)>>4;
	for I:= 0, ScreenHeight*ScreenWidth-1 do
		Screen(0, I):= Chin(3) \! Black<<12\ ! White<<8;  \Read low byte
	Poke($40, $52, Chin(3));	\Restore cursor position
	Poke($40, $53, Chin(3));

	FClose(Hand);
	if StmExists then Fset(StmHandle, ^i);
	end;
Trap(Debug);
SetStmFilePtr;
end;	\RestoreCheckPoint

\===============================================================================

proc	Backup;		\Restore state saved in history buffers
int	Val, I;
begin
if HistInx # HistBase then
	begin
	HistInx:= HistInx - 1;
	if HistInx < 0 then HistInx:= HistSize-1;

	PC:= HistPC(HistInx);
	Cycles0:= HistCycles0(HistInx);
	Cycles1:= HistCycles1(HistInx);
	Cycles2:= HistCycles2(HistInx);
	WDT0:= HistWDT0(HistInx);
	WDT1:= HistWDT1(HistInx);

	Count0(PC):= Count0(PC) - 1;
	if Count0(PC) < 0 then
		begin
		if Debug then
			if Count0(PC) < -1 then Error("Count0 < -1");
		Count0(PC):= Count0(PC) + 10000;
		Count1(PC):= Count1(PC) - 1;
		if Count1(PC) < 0 then
			begin
			Count1(PC):= Count1(PC) + 10000;
			Count2(PC):= Count2(PC) - 1;
			if Count2(PC) < 0 then
				begin
				if Debug then Error("Count < 0");
				Count2(PC):= 0;
				Count1(PC):= 0;
				Count0(PC):= 0;
				end;
			end;
		end;

	Timer:= HistTimer(HistInx);
	Prescaler:= HistPrescaler(HistInx);

	for I:= 0, StackSize-1 do
		Stack(I):= HistSP(I, HistInx);
	SP:= HistSP(8, HistInx);

	WReg:= HistWReg(HistInx);

	RAM(STATUS):= HistSTATUS(HistInx);

	FRA:= HistFRA(HistInx);
	Val:= HistRAMFRA(HistInx);
	if FRA < RAMSize then
		begin
		case FRA & $1F of
		 PORTA:	begin
			LATCHA:= Val;
			RAM(PORTA):= RAM(PORTA) & TRISA  !  LATCHA & ~TRISA;
			end;
		 PORTB:	begin
			LATCHB:= Val;
			RAM(PORTB):= RAM(PORTB) & TRISB  !  LATCHB & ~TRISB;
			end;
		 PORTC:	begin
			if (FUSEX & $C00) \28pin\ then
			    begin
			    LATCHC:= Val;
			    RAM(PORTC):= RAM(PORTC) & TRISC  !  LATCHC & ~TRISC;
			    end
			else RAM(Map(FRA)):= Val;
			end
		other	RAM(Map(FRA)):= Val;

		DoneRAM(Map(FRA)):= HistDoneRAM(HistInx);
		end
	else	begin			\Pseudo address for other registers
		case FRA of
		 OptionAddr:	Option:= Val;
		 MBitsAddr:	MBits:= Val;
		 TRISAAddr:	TRISA:= Val;
		 TRISBAddr:	TRISB:= Val;
		 TRISCAddr:	TRISC:= Val;
		 WKENBAddr:	WKENB:= Val;
		 WKEDBAddr:	WKEDB:= Val;
		 COMPBAddr:	COMPB:= Val
		other	Error("INTERNAL ERROR #1");
		end;
	end
else Beep;
end;	\Backup

\------------------------------------------------------------------------------

proc	ResetWDT;	\Reset Watch Dog Timer to nominal value
real	Clock,		\Instruction clock frequency (Osc or Osc/4.0)
	Cycles;		\Number of instruction cycles for WDT to timeout
begin
Clock:= if FUSE & $800 \~Turbo\ then Osc/4.0 else Osc;
Cycles:= Clock * WDTPeriod;

WDT1:= Fix(Int(Cycles / 10000.0));
WDT0:= Fix(Cycles - Float(WDT1) * 10000.0);

Prescaler:= 0;
WDTimeout:= false;
end;	\ResetWDT



proc	MClrReset;	\Simulate a MClr reset
int	I;
begin
PC:= ROMMask;
SP:= 0;
TRISA:= $0F;   TRISB:= $FF;   TRISC:= $FF;
WKENB:= $FF;   WKEDB:= $FF;   COMPB:= $FF;

Option:= $FF;		\(regardless of FUSE)
MBits:= $0F;
ClockInhibit:= 0;
RTCCPin:= 0;
HaveInterrupt:= false;

ResetWDT;

for I:= 0, 8-1 do Stack(I):= 0;	\(Makes it easy to see the amount used)

RAM(PCL):= PC;

RAM(STATUS):= RAM(STATUS) & $1F;

case FUSEX & $00C of	\Set for number of configured RAM banks
  $0:	RAM(FSR):= RAM(FSR) ! $E0;
  $4:	RAM(FSR):= RAM(FSR) ! $C0;
  $8:	RAM(FSR):= RAM(FSR) ! $80
other;
end;	\MClrReset

\------------------------------------------------------------------------------

proc	Push(A);	\Push subroutine address (A) onto stack
\The stack does not work like most computers. It "behaves like one of those
\ plate holders in a salad buffet." SP is used solely for detecting errors.
int	A;
int	I;
begin
if SP >= StackSize then
	begin
	Error("STACK OVERFLOW");
	SP:= StackSize-1;
	end;
SP:= SP +1;

for I:= -(StackSize-2), 0 do
	Stack(-I+1):= Stack(-I);
Stack(0):= A;
end;	\Push



func	Pop;		\Pop subroutine address (A) off stack and return it
int	A, I;
begin
SP:= SP -1;
if SP < 0 then
	begin
	Error("STACK UNDERFLOW");
	SP:= 0;
	end;
A:= Stack(0);
for I:= 0, StackSize-2 do
	Stack(I):= Stack(I+1);
return A;
end;	\Pop

\===============================================================================

proc	Execute;	\Execute instruction at PC
int	I,	\Scratch
	D,	\Destination select; D=0 store result in W, else store in FRA
	T,	\Temporary
	B,	\Bit
	Lit,	\Literal value
	Opcode,	\Instruction code (12 bits)
	Op,	\Opcode read with IREAD
	AffectsStatus,	\Flag: Instruction affects one of more status bits
	SS,	\Save status
	ZF, DC, CF,	\Flags: Status bits
	OldPre,	\Old Prescaler
	PINA, PINB, PINC;	\Port pin values
\Local variables are not used in the procedures below so that they can be
\ optimized for maximum speed.



proc	NextCycle;		\Increment cycle counter


	proc	NextWDT;	\Decrement WDT counter
	begin
	if WDT0 <= 0 then
		begin
		if WDT1 <= 0 then WDTimeout:= true;
		WDT1:= WDT1 - 1;
		WDT0:= 10000;
		end;
	WDT0:= WDT0 - 1;
	end;	\NextWDT


begin	\NextCycle
Cycles0:= Cycles0 +1;
if Cycles0 >= 10000 then
	begin
	Cycles0:= 0;
	Cycles1:= Cycles1 +1;
	if Cycles1 >= 10000 then
		begin
		Cycles1:= 0;
		Cycles2:= Cycles2 +1;
		if Cycles2 >= 10000 then Cycles2:= 0;	\Wrap
		end;
	end;

OldPre:= Prescaler;
Prescaler:= Prescaler + 1;
if FUSE & $004 then
	begin				\WDT enabled
	if Option & $08\PSA\ then	\Prescaler assigned to WDT
		begin
		OldPre:= (OldPre | Prescaler) & ~Prescaler;	\Carries
		if ((OldPre<<1 ! 1) & 1<<(Option & $07)) then NextWDT;
		end
	else	NextWDT;
	end;

if ClockInhibit = 0 then
	begin
	if (Option & $20\T0CS\) = 0 then		\Internal clock selected
		begin
		if Option & $08\PSA\ then BumpTimer	\No prescaler
		else	begin
			OldPre:= (OldPre | Prescaler) & ~Prescaler;     \Carries
			if (OldPre & 1<<(Option & $07)) then BumpTimer;
			end;
		end;
	end
else	ClockInhibit:= ClockInhibit -1;
end;	\NextCycle



proc	Class00;	\Execute 0000 0000 xxxx instructions
begin
case Opcode & $000F of
  $00:	begin								\NOP
	end;
  $01:	begin								\PRINT
	Chout(5, WReg);
	end;
  $02:	begin								\OPTION
	HistFRA(HistInx):= OptionAddr;
	HistRAMFRA(HistInx):= Option;
	Option:= WReg;
	end;
  $03:	begin								\SLEEP
	ResetWDT;
	if FUSE & $004 then			\WDT enabled
		repeat NextCycle until WDTimeout
	else	TraceMode:= true;
	RAM(STATUS):= RAM(STATUS) & $F7 ! $10;	\TO_:=1; PD_:=0
	end;
  $04:	begin								\CLRWDT
	ResetWDT;
	RAM(STATUS):= RAM(STATUS) ! $18;	\TO_:=1; PD_:=1
	end;
  $05:	begin								\TRIS A
	if (MBits & $0F) = $0F then
		begin
		HistFRA(HistInx):= TRISAAddr;
		HistRAMFRA(HistInx):= TRISA;
		TRISA:= WReg;
		RAM(PORTA):= RAM(PORTA) & TRISA  !  LATCHA & ~TRISA;
		end;
	end;
  $06:	begin								\TRIS B
	case MBits & $0F of
	  $0F:	begin
		HistFRA(HistInx):= TRISBAddr;
		HistRAMFRA(HistInx):= TRISB;
		TRISB:= WReg;
		RAM(PORTB):= RAM(PORTB) & TRISB  !  LATCHB & ~TRISB;
		end;
	  $0B:	begin		\Wake-up interrupt enable
		HistFRA(HistInx):= WKENBAddr;
		HistRAMFRA(HistInx):= WKENB;
		WKENB:= WReg;
		end;
	  $0A:	begin		\Wake-up edge select
		HistFRA(HistInx):= WKEDBAddr;
		HistRAMFRA(HistInx):= WKEDB;
		WKEDB:= WReg;
		end;
	  $09:	begin		\Swap W with WKENB
		HistFRA(HistInx):= WKENBAddr;
		HistRAMFRA(HistInx):= WKENB;
		T:= WKENB;
		WKENB:= WReg;
		WReg:= T;
		end;
	  $08:	begin		\Swap W with COMPB
		HistFRA(HistInx):= COMPBAddr;
		HistRAMFRA(HistInx):= COMPB;
		T:= COMPB;
		COMPB:= WReg;
		WReg:= T;
		end
	other	[];
	end;
  $07:	begin								\TRIS C
	if (FUSEX & $C00) \28pin\ then
		begin
		if (MBits & $0F) = $0F then
			begin
			HistFRA(HistInx):= TRISCAddr;
			HistRAMFRA(HistInx):= TRISC;
			TRISC:= WReg;
			RAM(PORTC):= RAM(PORTC) & TRISC  !  LATCHC & ~TRISC;
			end;
		end
	else	IllegalOp;
	end;
  $0A:	begin								\INPUT
  	WReg:= GetKey;
	if WReg = Esc then TraceMode:= true;
	end;
  $0B:	begin								\OUTPUT
	ShowMouse(false);
	CallInt($10, $0501);	\Set page 1
	Chout(0, WReg);
	ShowMouse(true);
	if TraceMode then Sound(0, 6, 1);	\Delay 1/3 second
	end;
  $0C:	begin								\RETURN
	PC:= Pop;
	NextCycle;
	if (FUSE & $800) = 0 then NextCycle;
	end;
  $0D:	begin								\RETP
	PC:= Pop;
	RAM(STATUS):= (RAM(STATUS) & $9F) ! (PC>>4 & $60);
	NextCycle;
	if (FUSE & $800) = 0 then NextCycle;
	end;
  $0E:	begin								\RETI
	PC:= ShadowPC;
	WReg:= ShadowWReg;
	RAM(STATUS):= ShadowSTATUS;
	RAM(FSR):= ShadowFSR;
	case FUSEX & $00C of	\Make sure it's set for number of RAM banks
	  $0:	RAM(FSR):= RAM(FSR) ! $E0;
	  $4:	RAM(FSR):= RAM(FSR) ! $C0;
	  $8:	RAM(FSR):= RAM(FSR) ! $80
	other;
	NextCycle;
	if (FUSE & $800) = 0 then NextCycle;
	end;
  $0F:	begin								\RETIW
	Timer:= Timer + WReg;
	PC:= ShadowPC;
	WReg:= ShadowWReg;
	RAM(STATUS):= ShadowSTATUS;
	RAM(FSR):= ShadowFSR;
	case FUSEX & $00C of	\Make sure it's set for number of RAM banks
	  $0:	RAM(FSR):= RAM(FSR) ! $E0;
	  $4:	RAM(FSR):= RAM(FSR) ! $C0;
	  $8:	RAM(FSR):= RAM(FSR) ! $80
	other;
	NextCycle;
	if (FUSE & $800) = 0 then NextCycle;
	end

other	IllegalOp;
end;	\Class00



proc	Class0;		\Execute 00xx xxxx xxxx instructions
begin
FRA:= Opcode & $001F  !  RAM(FSR) & $E0;
if (FRA & $1F) = INDF then FRA:= RAM(FSR);

HistFRA(HistInx):= FRA;			\Assume RAM will be changed
HistRAMFRA(HistInx):= RAM(Map(FRA));	\ (Might be a special register instead)
HistDoneRAM(HistInx):= DoneRAM(Map(FRA));

D:=  Opcode & $0020;  \Destination select; D=0 store into W else store into FRA
\D=1 if a file register is changed, even for class00 instructions

if (FRA & $1F) <= $07 then
	begin
	case FRA & $1F of
	  STATUS:
		begin
		SS:= RAM(STATUS);	\TO & PD bits can't be changed when D=1
		AffectsStatus:= true;	\Assume instruction affects status
		ZF:= (RAM(STATUS) & $04) # 0;	\Save status bits in case of 
		DC:= (RAM(STATUS) & $02) # 0;	\ write to STATUS register
		CF:= (RAM(STATUS) & $01) # 0;
		end;
	  PCL:	RAM(PCL):= PC;
	  RTCC: RAM(RTCC):= if FUSE & $200 ! Option & $80 then Timer else WReg
	other;
	end;

PINA:= RAM(PORTA);
PINB:= RAM(PORTB);
if (FUSEX & $C00) \28pin\ then PINC:= RAM(PORTC);

case Opcode>>6 & $000F of
  $0:	begin
	case Opcode>>4 & $0003 of
	  0:	Class00;		\D=0
	  1:	if Opcode & $0008 then	\D=0
			begin
			HistFRA(HistInx):= FSR;
			HistRAMFRA(HistInx):= RAM(FSR);
			HistDoneRAM(HistInx):= DoneRAM(FSR);
			RAM(FSR):= RAM(FSR) & $1F  !  Opcode<<5 & $E0;	\BANK
			case FUSEX & $00C of	\Set for number of RAM banks
			  $0:	RAM(FSR):= RAM(FSR) ! $E0;
			  $4:	RAM(FSR):= RAM(FSR) ! $C0;
			  $8:	RAM(FSR):= RAM(FSR) ! $80
			other;
			end
		else	begin						\PAGE
			RAM(STATUS):= RAM(STATUS) & $1F  !  Opcode<<5 & $E0;
			end
	other	begin
		RAM(Map(FRA)):= WReg;	\D=1\				\MOVWF
		AffectsStatus:= false;
		end;
	end;

  $1:	begin
	case Opcode>>4 & $0003 of
	  0:	begin			\D=0\
		case Opcode & $3F of
		  0:	begin						\CLRW
			WReg:= 0;
			RAM(STATUS):= RAM(STATUS) ! $04; \ZF:= true
			end;
		  1:	begin						\IREAD
			Op:= ROM( (MBits<<8 ! WReg&$FF) & ROMMask);
			WReg:= Op;
			HistFRA(HistInx):= MBitsAddr;
			HistRAMFRA(HistInx):= MBits;
			MBits:= Op>>8;
			if (FUSE & $800) = 0 then
				[NextCycle;   NextCycle;   NextCycle];
			end;
		  2:	WReg:= MBits & $0F;				\MOVMW
		  3:	begin
			HistFRA(HistInx):= MBitsAddr;
			HistRAMFRA(HistInx):= MBits;
			MBits:= WReg \& $0F\;				\MOVWM 
			end
		other	IllegalOp;
		end;
	  1:	begin			\D=0\
		HistFRA(HistInx):= MBitsAddr;
		HistRAMFRA(HistInx):= MBits;
		MBits:= Opcode \& $000F\;				\MODE 
		end
	other	begin			\D=1\				\CLRF
		RAM(Map(FRA)):= 0;
		RAM(STATUS):= RAM(STATUS) ! $04; \ZF:= true
		end;
	end;

  $2:	begin								\SUBWF
	T:= (RAM(Map(FRA)) ! $FF00) - (WReg & $00FF);
	CF:= (RAM(STATUS) & $01) # 0;
	if ~CF & (FUSEX & $40) = 0 then T:= T - 1;
	ZF:= (T & $FF) = $00;
	CF:= (T & $100) = $100;
	DC:= ( (RAM(Map(FRA)) ! $FFF0) - (WReg & $0F) & $10 ) = $10;
	if D then RAM(Map(FRA)):= T else WReg:= T;
	RAM(STATUS):= RAM(STATUS) & $F8  !  ZF & $04  !  DC & $02  !  CF & $01;
	end;
  $3:	begin								\DECF
	T:= RAM(Map(FRA)) - 1;
	ZF:= (T & $FF) = $00;
	if D then RAM(Map(FRA)):= T else WReg:= T;
	RAM(STATUS):= RAM(STATUS) & $FB  !  ZF & $04;
	end;
  $4:	begin								\IORWF
	T:= WReg ! RAM(Map(FRA));
	ZF:= (T & $FF) = $00;
	if D then RAM(Map(FRA)):= T else WReg:= T;
	RAM(STATUS):= RAM(STATUS) & $FB  !  ZF & $04;
	end;
  $5:	begin								\ANDWF
	T:= WReg & RAM(Map(FRA));
	ZF:= (T & $FF) = $00;
	if D then RAM(Map(FRA)):= T else WReg:= T;
	RAM(STATUS):= RAM(STATUS) & $FB  !  ZF & $04;
	end;
  $6:	begin								\XORWF
	T:= WReg | RAM(Map(FRA));
	ZF:= (T & $FF) = $00;
	if D then RAM(Map(FRA)):= T else WReg:= T;
	RAM(STATUS):= RAM(STATUS) & $FB  !  ZF & $04;
	end;
  $7:	begin								\ADDWF
	T:= (WReg & $FF) + RAM(Map(FRA));
	CF:= (RAM(STATUS) & $01) # 0;
	if CF & (FUSEX & $40) = 0 then T:= T + 1;
	ZF:= (T & $FF) = $00;
	CF:= T >= $100;
	DC:= (WReg & $0F) + (RAM(Map(FRA)) & $0F) >= $10;
	if D then RAM(Map(FRA)):= T else WReg:= T;
	RAM(STATUS):= RAM(STATUS) & $F8  !  ZF & $04  !  DC & $02  !  CF & $01;
	end;
  $8:	begin								\MOVF
	T:= RAM(Map(FRA));
	ZF:= (T & $FF) = $00;
	if D then \RAM(Map(FRA)):= T\ else WReg:= T;
	RAM(STATUS):= RAM(STATUS) & $FB  !  ZF & $04;
	end;
  $9:	begin								\COMF
	T:= ~RAM(Map(FRA));
	ZF:= (T & $FF) = $00;
	if D then RAM(Map(FRA)):= T else WReg:= T;
	RAM(STATUS):= RAM(STATUS) & $FB  !  ZF & $04;
	end;
  $A:	begin								\INCF
	T:= RAM(Map(FRA)) + 1;
	ZF:= (T & $FF) = $00;
	if D then RAM(Map(FRA)):= T else WReg:= T;
	RAM(STATUS):= RAM(STATUS) & $FB  !  ZF & $04;
	end;
  $B:	begin								\DECFSZ
	T:= RAM(Map(FRA)) - 1;
	if (T & $FF) = $00 then [PC:= PC +1;   NextCycle];
	if D then RAM(Map(FRA)):= T else WReg:= T;
	AffectsStatus:= false;
	end;
  $C:	begin								\RRF
	CF:= (RAM(STATUS) & $01) # 0;
	T:= RAM(Map(FRA)) ! CF & $0100;
	CF:= (T & $01) = $01;
	if D then RAM(Map(FRA)):= T>>1 else WReg:= T>>1;
	RAM(STATUS):= RAM(STATUS) & $FE  !  CF & $01;
	end;
  $D:	begin								\RLF
	CF:= (RAM(STATUS) & $01) # 0;
	T:= RAM(Map(FRA)) << 1;
	if CF then T:= T ! $01;
	CF:= T >= $100;
	if D then RAM(Map(FRA)):= T else WReg:= T;
	RAM(STATUS):= RAM(STATUS) & $FE  !  CF & $01;
	end;
  $E:	begin								\SWAPF
	T:= RAM(Map(FRA))<<4 ! RAM(Map(FRA))>>4;
	if D then RAM(Map(FRA)):= T else WReg:= T;
	AffectsStatus:= false;
	end;
  $F:	begin								\INCFSZ
	T:= RAM(Map(FRA)) + 1;
	if (T & $FF) = $00 then [PC:= PC +1;   NextCycle];
	if D then RAM(Map(FRA)):= T else WReg:= T;
	AffectsStatus:= false;
	end
other;

if D then
    begin
    if (FRA & $1F) <= $07 then
	begin
	case FRA & $1F of
	  RTCC:	begin
		if FUSE & $200  !  Option & $80 then 
		 	begin
			Timer:= RAM(RTCC);
			ClockInhibit:= 2;
			Prescaler:= 0;
			end
		else	begin
			WReg:= RAM(RTCC);
			end;
		end;
	  PCL:	begin
		PC:= RAM(PCL)  !  RAM(STATUS)<<4 & $0600;
		NextCycle;
		if (FUSE & $800) = 0 then NextCycle;
		end;
	  STATUS:
		begin
		if AffectsStatus then	\E.g: CLRF STATUS -> 000u uuuu
			RAM(STATUS):= RAM(STATUS) & $F8  !
				ZF & $04  !  DC & $02  !  CF & $01;
		RAM(STATUS):= RAM(STATUS) & $E7  !  SS & $18;
			\Make sure TO & PD bits are not changed if D=1
			\ (D=0 for SLEEP, CLRWDT & RETI)
		end;
	  FSR:	case FUSEX & $00C of	\Set for configured number of RAM banks
		  $0:	RAM(FSR):= RAM(FSR) ! $E0;
		  $4:	RAM(FSR):= RAM(FSR) ! $C0;
		  $8:	RAM(FSR):= RAM(FSR) ! $80
		other;
	  PORTA:
		begin
		HistRAMFRA(HistInx):= LATCHA;
		LATCHA:= RAM(PORTA);
		RAM(PORTA):= PINA & TRISA  !  LATCHA & ~TRISA;
		end;
	  PORTB:
		begin
		HistRAMFRA(HistInx):= LATCHB;
		LATCHB:= RAM(PORTB);
		RAM(PORTB):= PINB & TRISB  !  LATCHB & ~TRISB;
		end;
	  PORTC:
		begin
		if (FUSEX & $C00) \28pin\ then 
			begin
			HistRAMFRA(HistInx):= LATCHC;
			LATCHC:= RAM(PORTC);
			RAM(PORTC):= PINC & TRISC  !  LATCHC & ~TRISC;
			end;
		end
	other;
	end;

    DoneRAM(Map(FRA&$FF)):= true;	\Indicate initialized RAM location
    end;
end;	\Class0



proc	Class1;		\Execute 01xx xxxx xxxx instructions
begin
FRA:= Opcode & $001F  !  RAM(FSR) & $E0;
if (FRA & $1F) = INDF then FRA:= RAM(FSR);

HistFRA(HistInx):= FRA;			\Assume RAM will be changed
HistRAMFRA(HistInx):= RAM(Map(FRA));
HistDoneRAM(HistInx):= DoneRAM(Map(FRA));

if (FRA & $1F) <= $07 then
	begin
	case FRA & $1F of
	  RTCC: RAM(RTCC):= if FUSE & $200 ! Option & $80 then Timer else WReg;
	  PCL:	RAM(PCL):= PC;
	  STATUS:
		SS:= RAM(STATUS)	\TO & PD bits can't be changed here
	other;
	end;

B:= Opcode>>5 & $0007;

case Opcode>>8 & $0003 of
  $0, $1:
	begin
	if (FRA & $1F) <= $07 then
		begin
		PINA:= RAM(PORTA);
		PINB:= RAM(PORTB);
		if (FUSEX & $C00) \28pin\ then PINC:= RAM(PORTC);
		end;

	if Opcode & $100 then
		RAM(Map(FRA)):= RAM(Map(FRA)) ! 1<<B			\BSF
	else	RAM(Map(FRA)):= RAM(Map(FRA)) & ~(1<<B);		\BCF

	if (FRA & $1F) <= $07 then
		begin
		case FRA & $1F of
		  INDF:	RAM(INDF):= 0;
		  RTCC:	begin
			if FUSE & $200 ! Option & $80 then 
			 	begin
				Timer:= RAM(RTCC);
				ClockInhibit:= 2;
				Prescaler:= 0;
				end
			else	begin
				WReg:= RAM(RTCC);
				end;
			end;
		  PCL:	begin
			PC:= RAM(PCL)  !  RAM(STATUS)<<4 & $0600;
			NextCycle;
			if (FUSE & $800) = 0 then NextCycle;
			end;
		  STATUS:
			begin
			RAM(STATUS):= RAM(STATUS) & $E7  !  SS & $18;
				\Make sure TO & PD are not changed
			end;
		  FSR:	case FUSEX & $00C of	\Set for number of RAM banks
			  $0:	RAM(FSR):= RAM(FSR) ! $E0;
			  $4:	RAM(FSR):= RAM(FSR) ! $C0;
			  $8:	RAM(FSR):= RAM(FSR) ! $80
			other;
		  PORTA:
			begin
			HistRAMFRA(HistInx):= LATCHA;
			LATCHA:= RAM(PORTA);
			RAM(PORTA):= PINA & TRISA  !  LATCHA & ~TRISA;
			end;
		  PORTB:
			begin
			HistRAMFRA(HistInx):= LATCHB;
			LATCHB:= RAM(PORTB);
			RAM(PORTB):= PINB & TRISB  !  LATCHB & ~TRISB;
			end;
		  PORTC:
			begin
			if (FUSEX & $C00) \28pin\ then
				begin
				HistRAMFRA(HistInx):= LATCHC;
				LATCHC:= RAM(PORTC);
				RAM(PORTC):= PINC & TRISC  !  LATCHC & ~TRISC;
				end;
			end
		other;
		end;
	end;

  $2:	begin
	if RAM(Map(FRA)) & 1<<B then []					\BTFSC
	else	begin
		PC:= PC +1;
		NextCycle;
		end;
	end;
  $3:	begin
	if RAM(Map(FRA)) & 1<<B then					\BTFSS
		begin
		PC:= PC +1;
		NextCycle;
		end;
	end
other;
end;	\Class1



proc	Class2;		\Execute 10xx xxxx xxxx instructions
begin
HistFRA(HistInx):= 0;			\No RAM location is changed
HistRAMFRA(HistInx):= 0;		\Don't "restore" a random location

case Opcode>>8 & $0003 of
  $0:	begin								\RETLW
	PC:= Pop;
	WReg:= Opcode;
	NextCycle;
	if (FUSE & $800) = 0 then NextCycle;
	end;
  $1:	begin								\CALL
	Push(PC);
	PC:= Opcode & $00FF  !  RAM(STATUS)<<4 & $0600;
	NextCycle;
	if (FUSE & $800) = 0 then NextCycle;
	end;
  $2,									\GOTO
  $3:	begin								\GOTO
	PC:= Opcode & $01FF  !  RAM(STATUS)<<4 & $0600;
	NextCycle;
	if (FUSE & $800) = 0 then NextCycle;
	end
other;
end;	\Class2



proc	Class3;		\Execute 11xx xxxx xxxx instructions
begin
HistFRA(HistInx):= 0;			\No RAM location is changed
HistRAMFRA(HistInx):= 0;		\Don't "restore" a random location

Lit:= Opcode & $00FF;
case Opcode>>8 & $0003 of
  $0:	begin								\MOVLW
	WReg:= Lit;
	end;
  $1:	begin								\IORLW
	WReg:= WReg ! Lit;
	ZF:= (WReg & $FF) = $00;
	RAM(STATUS):= RAM(STATUS) & $FB  !  ZF & $04;
	end;
  $2:	begin								\ANDLW
	WReg:= WReg & Lit;
	ZF:= (WReg & $FF) = $00;
	RAM(STATUS):= RAM(STATUS) & $FB  !  ZF & $04;
	end;
  $3:	begin								\XORLW
	WReg:= WReg | Lit;
	ZF:= (WReg & $FF) = $00;
	RAM(STATUS):= RAM(STATUS) & $FB  !  ZF & $04;
	end
other;
end;	\Class3



begin	\Execute
if StmExists then
	begin
	if (Float(Cycles2)*10000.0 + Float(Cycles1))*10000.0 + Float(Cycles0) >=
	    StmCycles - 0.1 then
		begin
		GetStimulus;
		GetTime;
		end;
	end;

if ~WKENB & $FF then	\Wake-up interrupts are enabled
	begin
	T:= RAM(PORTB) | OldPortB;	\Detect edge
	\if enabled & edge & selected edge then...
	if ((~WKENB & T) & (WKEDB | RAM(PORTB))) & $FF then
		HaveInterrupt:= true;
	NextCycle;	\External interrupts take more cycles
	if (FUSE & $800) = 0 then NextCycle;
	end;
OldPortB:= RAM(PORTB);

PC:= PC & ROMMask;	\For safety
if PC = BreakLoc then return;
if Breakpoint(PC) then
	if ~TraceMode then [TraceMode:= true;   return];
	\If in trace mode, allow single stepping through breakpoints

\Save state of microcontroller for backup command:
HistPC(HistInx):= PC;
HistCycles0(HistInx):= Cycles0;
HistCycles1(HistInx):= Cycles1;
HistCycles2(HistInx):= Cycles2;
HistWDT0(HistInx):= WDT0;
HistWDT1(HistInx):= WDT1;
HistTimer(HistInx):= Timer;
HistPrescaler(HistInx):= Prescaler;
for I:= 0, StackSize-1 do
	HistSP(I, HistInx):= Stack(I);
HistSP(8, HistInx):= SP;
HistWReg(HistInx):= WReg;
HistSTATUS(HistInx):= RAM(STATUS);
\(RAM is saved later)

Opcode:= ROM(PC);	\Fetch instruction from ROM

Count0(PC):= Count0(PC) +1;
if Count0(PC) >= 10000 then
	begin
	Count0(PC):= 0;
	Count1(PC):= Count1(PC) +1;
	if Count1(PC) >= 10000 then
		begin
		Count1(PC):= 0;
		Count2(PC):= Count2(PC) +1;
		if Count2(PC) >= 10000 then Count2(PC):= 0;
		end;
	end;

PC:= PC +1;
NextCycle;

if ChkKey then
	begin
	TraceMode:= true;
	Openi(0);	\Eat keystroke
	end;
if HaveMouse then
	begin
	CallInt($33, $0003);
	if Cpureg(1) & $03 then
		begin
		TraceMode:= true;	\Wait for buttons released
		repeat CallInt($33, $0003) until (Cpureg(1) & $03) = 0;
		end;
	end;
	
case Opcode >> 10 of
  0:	Class0;
  1:	Class1;
  2:	Class2;
  3:	Class3
other	IllegalOp;

PC:= PC & ROMMask;	\For safety--beware of executing at $7FF

if HaveInterrupt then
	begin
	HaveInterrupt:= false;

	ShadowPC:= PC;
	ShadowWReg:= WReg;
	ShadowSTATUS:= RAM(STATUS);
	ShadowFSR:= RAM(FSR);
	PC:= 0;		\Interrupt vector

	\Bump cycle count (internal/external)
	NextCycle;
	if (FUSE & $800) = 0 then NextCycle;
	end;

HistInx:= HistInx + 1;
if HistInx >= HistSize then HistInx:= 0;

if HistInx = HistBase then
	begin
	HistBase:= HistBase + 1;
	if HistBase >= HistSize then HistBase:= 0;
	end;

if WDTimeout then
	begin		\(beware of processing in middle of GOTO instructions)
	RAM(STATUS):= RAM(STATUS) & $EF;    \T0_ := 0
	MClrReset;
	end;
end;	\Execute

\===============================================================================

proc	DoCmd;		\Execute keyboard or mouse commands
int	Ch, I, T, B,
	X, Y, Inc, But0, But1,	\Mouse control variables
	X1, X2, X3, X4, Addr, GhostRC,
	KeyFlags, OldKeyFlags,
	ButtonState,		\Used by mouse button autorepeat
	YRel, OldWinPtr;
def	Speed= 10;		\Alt+F6 speed (18ths of a second)
real	RlTbl, RlInc;



proc	GoCmd(Spd);	\Execute Go or Slow command
int	Spd;
int	S;
begin
TraceMode:= true;	\Execute past possible breakpoint
Execute;
LineCursor:= PC;	\Show results
ShowMouse(false);
CallInt($10, $0500);	\Set page 0 (in case of OUTPUT instr)
ShowMouse(true);
ShowCode(LineCursor);	\(outputs PCLine)
DisplayRegs;
PointOut;		\(inputs PCLine)
for S:= 1, Spd do Sound(0, 1, 1);	\Delay

TraceMode:= false;
repeat	begin
	Execute;
	LineCursor:= PC;	\Show results
	ShowMouse(false);
	CallInt($10, $0500);	\Set page 0 (in case of OUTPUT instr)
	ShowMouse(true);
	ShowCode(LineCursor);	\(outputs PCLine)
	DisplayRegs;
	PointOut;		\(inputs PCLine)
	for S:= 1, Spd do Sound(0, 1, 1);	\Delay
	end;
until TraceMode;	\Repeat until breakpoint, keystroke or mouse click.
end;	\GoCmd



func	ButtonTrigger(ID);	\Returns 'true' when autorepeat button triggers
int	ID;	\Button identifier (don't change buttons in middle of a repeat)
int	Tmr, SID;
begin
Tmr:= [0];	\Own (static) variables
SID:= [0];	\Save initial button ID (usually is X & Y screen coordinates)

if ButtonState = 0 then SID(0):= ID;	\First-time call for this button

if ID = SID(0) then		\If it's the button we started with...
	begin
	case ButtonState of
	  0:	begin
		Tmr(0):= 9;	\About 1/2 second delay before autorepeat starts
		ButtonState:= 1;
		return true;	\Trigger on initial press
		end;
	  1:	begin		\Subsequent calls come here and check timer
		Sound(0, 1, 1);	\Delay 1/18 second
		Tmr(0):= Tmr(0) - 1;
		if Tmr(0) <= 0 then
			begin
			ButtonState:= 2;
			return true;	\Trigger button when timer times out
			end;
		end
	  other	begin
		Tmr(0):= 2;	\About 0.1 second delay for autorepeat rate
		ButtonState:= 1;
		end
	end;

return false;
end;	\ButtonTrigger



proc	UpdateDisplay;	\Update display to reflect a change in a register
begin
\Don't highlight changes made by mouse because they're hard to see
RAM(INDF):= RAM(Map(RAM(FSR)));		\Lie for the display
SaveRegs;
RAM(INDF):= $00;			\Cover the lie

DisplayRegs;
PointOut;	\(Inputs PCLine from ShowCode)
end;	\UpdateDisplay



begin	\DoCmd
ButtonState:= 0;
loop begin
if Chkkey then
	begin
	Ch:= GetKey;
	case Ch of
	  -Func-1:							\Help
		ShowHelp;
	  -AltFunc-1:							\Output
		ShowOutput;
	  -Func-2:							\Bkpt
		Breakpoint(LineCursor):= ~Breakpoint(LineCursor);
	  -Func-3:							\Clear
		for I:= 0, ROMSizeMax-1 do Breakpoint(I):= false;
	  -AltFunc-3:							\Count
		ShowingCount:= ~ShowingCount;
	  -Func-4:							\Here
		begin
		ShowRunning;
		TraceMode:= true;	\Execute past possible breakpoint
		Execute;
		BreakLoc:= LineCursor;
		TraceMode:= false;
		repeat Execute until PC=BreakLoc ! TraceMode;
		BreakLoc:= -1;
		LineCursor:= PC;
		ShowMouse(false);
		CallInt($10, $0500);	\Set page 0 (in case of OUTPUT instr)
		ShowMouse(true);
		end;
	  -AltFunc-4:							\Jump
		PC:= LineCursor & ROMMask;
	  -Func-5:							\Zero
		begin
		ReOpenStm;
		end;
	  -Func-6:							\Go
		GoCmd(0);
	  -AltFunc-6:							\Slow
		GoCmd(Speed);
	  -Func-7, Space, CR:						\Step
		begin
		TraceMode:= true;
		Execute;
		LineCursor:= PC;
		ShowMouse(false);
		CallInt($10, $0500);	\Set page 0 (in case of OUTPUT instr)
		ShowMouse(true);
		end;
	  -AltFunc-7, BS:						\Back
		begin
		TraceMode:= true;
		Backup;
		LineCursor:= PC;
		end;
	  -Func-8:							\Over
		begin
		if (ROM(PC&ROMMask) & $F00) = $900 \CALL\ then
			begin
			ShowRunning;
			BreakLoc:= PC+1;
			TraceMode:= true;  \Execute past possible breakpoint
			Execute;
			TraceMode:= false;
			repeat Execute until PC=BreakLoc ! TraceMode;
			BreakLoc:= -1;
			end
		else	begin		   \Single step other instructions 
			TraceMode:= true;  \Execute past possible breakpoint
			Execute;
			end;
		LineCursor:= PC;
		ShowMouse(false);
		CallInt($10, $0500);	\Set page 0 (in case of OUTPUT instr)
		ShowMouse(true);
		end;
	  -AltFunc-8:							\Return
		begin
		ShowRunning;
		BreakLoc:= Stack(0);
		TraceMode:= true;	\Execute past possible breakpoint
		Execute;
		TraceMode:= false;
		repeat Execute until PC=BreakLoc ! TraceMode;
		BreakLoc:= -1;
		LineCursor:= PC;
		ShowMouse(false);
		CallInt($10, $0500);	\Set page 0 (in case of OUTPUT instr)
		ShowMouse(true);
		end;
	  -Func-9:							\Run
		begin
		ShowRunning;
		TraceMode:= true;	\Execute past possible breakpoint
		Execute;
		TraceMode:= false;
		repeat Execute until TraceMode;
		LineCursor:= PC;
		ShowMouse(false);
		CallInt($10, $0500);	\Set page 0 (in case of OUTPUT instr)
		ShowMouse(true);
		end;
	  -Func-10:							\MClr
		begin
		ReOpenStm;
		TraceMode:= true;
		MClrReset;
		WinPtr:= PC - WinHeight>>1; \Display PC line in middle of window
		LineCursor:= PC;
		end;
	  -AltFunc-10:							\Reset
		begin
		ClearPage1;
		ReOpenStm;
		for I:= 0, RAMSize-1 do RAM(I):= 0;
		WReg:= 0;
		Timer:= 0;
		LATCHA:= 0;   LATCHB:= 0;   LATCHC:= 0; 
		for I:= 0, ROMSizeMax-1 do
			[Count0(I):= 0;   Count1(I):= 0;   Count2(I):= 0];
		for I:= 0, RAMSize-1 do	DoneRAM(I):= false;
		TraceMode:= true;
		MClrReset;

		RAM(INDF):= RAM(Map(RAM(FSR)));		\Lie for the display
		SaveRegs;				\Don't highlight zeros
		RAM(INDF):= $00;			\Cover the lie

		WinPtr:= PC - WinHeight>>1; \Display PC line in middle of window
		LineCursor:= PC;
		end;
	  -UpArrow:
		begin
		LineCursor:= LineCursor - 1;
		if LineCursor < 0 then LineCursor:= 0;
		end;
	  -DnArrow:
		begin
		LineCursor:= LineCursor + 1;
		if LineCursor >= ROMSize then LineCursor:= ROMSize-1;
		end;
	  -LtArrow, -RtArrow:
		LineCursor:= PC;
	  -PageUp:
		begin
		LineCursor:= LineCursor - WinHeight;
		if LineCursor < 0 then LineCursor:= 0;
		WinPtr:= WinPtr - WinHeight;
		if WinPtr < -1 then WinPtr:= -1;
		end;
	  -PageDn:
		begin
		LineCursor:= LineCursor + WinHeight;
		if LineCursor >= ROMSize then LineCursor:= ROMSize-1;
		WinPtr:= WinPtr + WinHeight;
		if WinPtr >= ROMSize-2 then WinPtr:= ROMSize-2;
		end;
	  -Home:
		LineCursor:= 0;
	  -End:
		LineCursor:= ROMSize-1;
	   Esc, -AltX, ^C-Ctrl:
		if VerifyExit then Exit
	other	begin
		Ch:= -Ch;
		if Ch >= ShiftFunc+1  &  Ch <= ShiftFunc+10 then
			SaveCheckPoint(Ch-ShiftFunc)
		else if Ch >= CtrlFunc+1  &  Ch <= CtrlFunc+10 then
			RestoreCheckPoint(Ch-CtrlFunc)
		else	Beep;
		end;

	ShowCode(LineCursor);		\(outputs PCLine)
	if ~ChkKey then DisplayRegs;
	if ~ChkKey then PointOut;	\(inputs PCLine)
	OldKeyFlags:= -1;		\Display the prompt line
	end;

KeyFlags:= CallInt($16, $0200);		\Get keyboard flags
\Bit: 0=right Shift, 1=left Shift, 2=Ctrl, 3=Alt
if KeyFlags # OldKeyFlags then
	begin
	case of
	 KeyFlags & $08: ShowAltPrompts;
	 KeyFlags & $04: ShowCtrlPrompts;
	 KeyFlags & $03: ShowShiftPrompts
	other ShowPrompts;
	OldKeyFlags:= KeyFlags;
	end;

\MOUSE CONTROL:
But0:= GetMouseButton(0);		\Get copies of mouse buttons for
But1:= GetMouseButton(1);		\ consistent readings
if But0 ! But1 then			\A button is pressed
	begin
	X:= GetMousePosition(0) >> 3;	\Get mouse position in text coordinates
	Y:= GetMousePosition(1) >> 3;

	case of				\See if a soft button is pressed
	X>=SpecialRegX & X<=SpecialRegX+1 & Y>=SpecialRegY & Y<=SpecialRegY+7:
	    if ButtonTrigger(Y<<8!X) then
		begin
		Inc:= if X = SpecialRegX then $10 else $1;
		if But1 then Inc:= -Inc;		\Right button decrements
		RAM(Y-SpecialRegY):= RAM(Y-SpecialRegY) + Inc;
		if FUSE & $200 ! Option & $80 then 
			Timer:= RAM(RTCC)
		else	WReg:= RAM(RTCC);
		case FUSEX & $00C of	\Set for number of RAM banks
		  $0:	RAM(FSR):= RAM(FSR) ! $E0;
		  $4:	RAM(FSR):= RAM(FSR) ! $C0;
		  $8:	RAM(FSR):= RAM(FSR) ! $80
		other;
		PC:= (PC & $FF00) ! RAM(PCL);
		ShowCode(PC);		\(outputs PCLine for PointOut)
		UpdateDisplay;
		end;
	X>=StackX & X<=StackX+2 & Y>=StackY & Y<=StackY+7:		\STACK
	    if ButtonTrigger(Y<<8!X) then
		begin
		Inc:= 1 << ((2+StackX-X)<<2);	\$100, $10 or $1
		if But1 then Inc:= -Inc;
		Stack(Y-StackY):= Stack(Y-StackY) + Inc;
		UpdateDisplay;
		end;
	X>=RAMX & X<=RAMX+49 & Y>=RAMY & Y<=RAMY+8:			\RAM
	    if ButtonTrigger(Y<<8!X) then
		begin
		X1:= X - RAMX;			\X1 = offset into RAM
		Addr:= (X1/13) * 4;		\13 characters per group of 4
		X2:= Rem(0);			\Position within group of 4
		Addr:= Addr + X2/3;		\Byte within group
		X3:= Rem(0);			\Character position near byte
		if X2/3 = 4 then X3:= 2;	\It's a space

		Inc:= $10;			\Assume position 0, $10 place
		if X3 = 1 then Inc:= 1;		\Position 1 is 1 place

		Addr:= Addr + (Y-RAMY)*$20;
		if Y # RAMY then Addr:= Addr - $10;

		GhostRC:= if (FUSEX & $C00) = 0 \18pin\ then $06 else $07;
		if X3#2 & Addr>GhostRC then	\Position 2 is a space--ignore
			begin
			X4:= X;
			if Inc = 1 then X4:= X4 - 1;
			if But1 then Inc:= -Inc;
			RAM(Addr):= RAM(Addr) + Inc;
			end;
		UpdateDisplay;
		end;

	X>=PCX & X<=PCX+2 & Y=PCY:					\PC
	    if ButtonTrigger(Y<<8!X) then
		begin
		Inc:= 1 << ((2+PCX-X)<<2);	\$100, $10 or $1
		if But1 then Inc:= -Inc;
		PC:= (PC + Inc) & ROMMask;	\(for safety)
		RAM(PCL):= PC;
		LineCursor:= PC;
		ShowCode(PC);
		UpdateDisplay;
		end;
	X=MBitsX & Y=MBitsY:						\MODE
	    if ButtonTrigger(Y<<8!X) then
		begin
		Inc:= $1;
		if But1 then Inc:= -Inc;
		MBits:= MBits + Inc;
		UpdateDisplay;
		end;
	X>=OptionX & X<=OptionX+1 & Y=OptionY:				\OPTION
	    if ButtonTrigger(Y<<8!X) then
		begin
		Inc:= if X = OptionX then $10 else $1;
		if But1 then Inc:= -Inc;
		Option:= Option + Inc;
		UpdateDisplay;
		end;
	X>=Fuse_X & X<=Fuse_X+2 & Y=Fuse_Y:				\FUSE
	    if ButtonTrigger(Y<<8!X) then
		begin
		Inc:= 1 << ((2+Fuse_X-X)<<2);	\$100, $10 or $1
		if But1 then Inc:= -Inc;
		FUSE:= FUSE + Inc;
		StackSize:= if FUSE & $100 then 2 else 8;
		UpdateDisplay;
		end;
	X>=FusexX & X<=FusexX+2 & Y=FusexY:				\FUSEX
	    if ButtonTrigger(Y<<8!X) then
		begin
		Inc:= 1 << ((2+FusexX-X)<<2);	\$100, $10 or $1
		if But1 then Inc:= -Inc;
		FUSEX:= FUSEX + Inc;
		UpdateDisplay;
		end;
	X>=OscX & X<=OscX+6 & Y=OscY:					\OSC
	    if ButtonTrigger(Y<<8!X) then
		begin				\e.g: 123.456k
		RlTbl:= [100.0, 10.0, 1.0, 0.0, 0.1, 0.01, 0.001];
		RlInc:= RlTbl(X-OscX);
		case of
		  Osc >= 1e9: RlInc:= RlInc * 1e9;
		  Osc >= 1e6: RlInc:= RlInc * 1e6;
		  Osc >= 1e3: RlInc:= RlInc * 1e3
		other;
		if But1 then RlInc:= -RlInc;
		Osc:= Osc + RlInc;
		if Osc < 1.0e3 then Osc:= 1.0e3;
		if Osc > 1.0e9 then Osc:= 1.0e9;
		ResetWDT;			\(Cuz WDT is a function of Osc)
		UpdateDisplay;
		end;
	X=OscX+7 & Y=OscY:			\OSC units (kilo or Meg)
	    if ButtonTrigger(Y<<8!X) then
		begin				\e.g: 123.456M
		Osc:= if But1 then Osc / 1000.0 else Osc * 1000.0;
		if Osc < 1.0e3 then Osc:= 1.0e3;
		if Osc > 1.0e9 then Osc:= 1.0e9;
		ResetWDT;			\(Cuz WDT is a function of Osc)
		UpdateDisplay;
		end;

	X>=WRegX & X<=WRegX+1 & Y=WRegY:				\W
	    if ButtonTrigger(Y<<8!X) then
		begin
		Inc:= if X = WRegX then $10 else $1;
		if But1 then Inc:= -Inc;
		WReg:= WReg + Inc;
		if (FUSE&$200) = 0 & (Option&$80) = 0 then RAM(RTCC):= WReg;
		UpdateDisplay;
		end;
	X=WRegX+4 & Y=WRegY:			\W's ASCII character
	    if ButtonTrigger(Y<<8!X) then
		begin
		Inc:= 1;
		if But1 then Inc:= -Inc;
		WReg:= WReg + Inc;
		if (FUSE&$200) = 0 & (Option&$80) = 0 then RAM(RTCC):= WReg;
		UpdateDisplay;
		end;
	X>=WRegX-3 & X<=WRegX+4 & Y=WRegY+1:	\W's binary
	    if ButtonTrigger(Y<<8!X) then
		begin
		WReg:= WReg | 1<<(7-(X-(WRegX-3)));
		if (FUSE&$200) = 0 & (Option&$80) = 0 then RAM(RTCC):= WReg;
		UpdateDisplay;
		end;
	X>=StatusX & X<=StatusX+23 & Y=StatusY:				\STATUS
	    if ButtonTrigger(Y<<8!X) then
		begin
		Inc:= 0;	\Determine which bit (assume none)
		for I:= 0, 7 do
			if X-StatusX = StatusTable(I) then Inc:= $80 >> I;
		RAM(STATUS):= RAM(STATUS) | Inc;
		UpdateDisplay;
		end;
	X>=TimeX & X<=TimeX+7 & Y=TimeY:				\TIME
	    if ButtonTrigger(Y<<8!X) then
		begin				\e.g: 123.456k
		ReOpenStm;
		UpdateDisplay;
		end;

	X>=PortX & X<=PortX+3 & Y=PortY:				\TRISA
	    if ButtonTrigger(Y<<8!X) then
		begin
		TRISA:= TRISA | 1<<(3-(X-PortX));
		RAM(PORTA):= RAM(PORTA) & TRISA  !  LATCHA & ~TRISA;
		UpdateDisplay;
		end;
	X>=PortX & X<=PortX+3 & Y=PortY+1:				\LATCHA
	    if ButtonTrigger(Y<<8!X) then
		begin
		LATCHA:= LATCHA | 1<<(3-(X-PortX));
		RAM(PORTA):= RAM(PORTA) & TRISA  !  LATCHA & ~TRISA;
		UpdateDisplay;
		end;
	X>=PortX & X<=PortX+3 & Y=PortY+2:				\PINA
	    if ButtonTrigger(Y<<8!X) then
		begin			\Cannot set output pin with mouse
		RAM(PORTA):= RAM(PORTA) | 1<<(3-(X-PortX));
		RAM(PORTA):= RAM(PORTA) & TRISA  !  LATCHA & ~TRISA;
		UpdateDisplay;
		end;

	X>=PortX+5 & X<=PortX+7+5 & Y=PortY:				\TRISB
	    if ButtonTrigger(Y<<8!X) then
		begin
		TRISB:= TRISB | 1<<(7-(X-(PortX+5)));
		RAM(PORTB):= RAM(PORTB) & TRISB  !  LATCHB & ~TRISB;
		UpdateDisplay;
		end;
	X>=PortX+5 & X<=PortX+7+5 & Y=PortY+1:				\LATCHB
	    if ButtonTrigger(Y<<8!X) then
		begin
		LATCHB:= LATCHB | 1<<(7-(X-(PortX+5)));
		RAM(PORTB):= RAM(PORTB) & TRISB  !  LATCHB & ~TRISB;
		UpdateDisplay;
		end;
	X>=PortX+5 & X<=PortX+7+5 & Y=PortY+2:				\PINB
	    if ButtonTrigger(Y<<8!X) then
		begin
		RAM(PORTB):= RAM(PORTB) | 1<<(7-(X-(PortX+5)));
		RAM(PORTB):= RAM(PORTB) & TRISB  !  LATCHB & ~TRISB;
		UpdateDisplay;
		end;

	X>=PortX+14 & X<=PortX+7+14 & Y=PortY:				\TRISC
	    if ButtonTrigger(Y<<8!X) then
		begin
		TRISC:= TRISC | 1<<(7-(X-(PortX+14)));
		RAM(PORTC):= RAM(PORTC) & TRISC  !  LATCHC & ~TRISC;
		UpdateDisplay;
		end;
	X>=PortX+14 & X<=PortX+7+14 & Y=PortY+1:			\LATCHC
	    if ButtonTrigger(Y<<8!X) then
		begin
		LATCHC:= LATCHC | 1<<(7-(X-(PortX+14)));
		RAM(PORTC):= RAM(PORTC) & TRISC  !  LATCHC & ~TRISC;
		UpdateDisplay;
		end;
	X>=PortX+14 & X<=PortX+7+14 & Y=PortY+2:			\PINC
	    if ButtonTrigger(Y<<8!X) then
		begin
		RAM(PORTC):= RAM(PORTC) | 1<<(7-(X-(PortX+14)));
		RAM(PORTC):= RAM(PORTC) & TRISC  !  LATCHC & ~TRISC;
		UpdateDisplay;
		end;

	X>=ExitX & X<=ExitX+2 & Y=ExitY:				\[þ]
	    if ButtonTrigger(Y<<8!X) then
		begin
		repeat	begin
			B:= GetMousePosition(1)>>3 = ExitY &
			    GetMousePosition(0)>>3 >= ExitX &
			    GetMousePosition(0)>>3 <= ExitX+2;
			ShowMouse(false);
			Backlight(ExitX, ExitY, ExitX+2, ExitY,
				if B then Cyan else White);
			ShowMouse(true);
			Sound(0, 1, 1);	\Delay to reduce flicker
			end;
		until ~GetMouseButton(0) & ~GetMouseButton(1);
		if B then Exit;
		end;

	X<ScreenWidth-1 & Y>=ListWinY & Y<=ScreenHeight-2:		\LISTING
	    if ButtonTrigger(Y<<8!X) then
		begin
		repeat until ~GetMouseButton(0) & ~GetMouseButton(1);
		if GetMousePosition(1)>>3 = Y then	\Still on original line
			begin
			LineCursor:= WinPtr + (Y-ListWinY);
			case of
			  LineCursor < 0:    \Fix LineCursor and ignore command
				LineCursor:= 0;
			  LineCursor >= ROMSize:
				LineCursor:= ROMSize-1
			other	begin
				if But1 then
				      CallInt($16, $0500, 0, (Func+4)<<8)  \Here
				else  CallInt($16, $0500, 0, (Func+2)<<8); \Bkpt
				end;
			end;
		end;

	\Scroll bar:
	X=KnobX & Y=ListWinY:					\Up arrow
	    if ButtonTrigger(Y<<8!X) then
		begin
		WinPtr:= WinPtr - 1;
		if WinPtr < -1 then WinPtr:= -1;
		LineCursor:= LineCursor - 1;
		if LineCursor < 0 then LineCursor:= 0;
		ShowCode(LineCursor);
		UpdateDisplay;
		end;
	X=KnobX & Y=ScreenHeight-2:				\Down arrow
	    if ButtonTrigger(Y<<8!X) then
		begin
		WinPtr:= WinPtr + 1;
		if WinPtr >= ROMSize-2 then WinPtr:= ROMSize-2;
		LineCursor:= LineCursor + 1;
		if LineCursor >= ROMSize then LineCursor:= ROMSize-1;
		ShowCode(LineCursor);
		UpdateDisplay;
		end;
	X=KnobX & Y>=ListWinY+1 & Y<KnobY:			\Up page
	    if ButtonTrigger(Y<<8!X) then
		CallInt($16, $0500, 0, PageUp<<8);
	X=KnobX & Y>KnobY & Y<=ScreenHeight-3:			\Down page
	    if ButtonTrigger(Y<<8!X) then
		CallInt($16, $0500, 0, PageDn<<8);
	X=KnobX & Y=KnobY:					\Knob
	    if ButtonTrigger(Y<<8!X) then
		begin
		OldWinPtr:= -2;		\(used to reduce flicker)
		loop	begin
			\WP / ROMSizeEven = YRel / ScrollBarHeight
			YRel:= Y - (ListWinY+1);
			WinPtr:= Fix( Float(YRel) * Float(ROMSizeEven) /
				Float(ScrollBarHeight-1) ) - 1;
			if WinPtr >= ROMSize-2 then WinPtr:= ROMSize-2;
			if WinPtr # OldWinPtr then	\To reduce flicker, only
				begin			\ redraw the code window
				OldWinPtr:= WinPtr;	\ when it changes
				LineCursor:= WinPtr+1;
				ShowCode(LineCursor);
				PointOut;		\(for arrow on PCLine)
				end;
			if ~GetMouseButton(0) & ~GetMouseButton(1) then quit;
			Sound(0, 1, 1);		\Delay to reduce cursor flicker
			Y:= GetMousePosition(1) >> 3;
			if Y < ListWinY+1 then Y:= ListWinY+1;
			if Y > ScreenHeight-3 then Y:= ScreenHeight-3;
			end;
		end;

\Alt:            F3=Count F4=Jump       F6=Slow F7=Back F8=Return     F10=Reset
\Ctrl:  Restore checkpoint  F1   F2   F3   F4   F5   F6   F7   F8   F9   F10   
\Shift: Save checkpoint     F1   F2   F3   F4   F5   F6   F7   F8   F9   F10   
\F1=Help F2=Bkpt F3=Clear F4=Here F5=Time F6=Go F7=Step F8=Over F9=Run F10=MClr

	Y = ScreenHeight-1:
		begin
		case of	    \X coordinates of "Fn" (See ShowPrompts etc.)
			    \F0   1   2   3   4   5   6   7   8   9  10  11
		  KeyFlags & $08:				\Alt
			T:= [ 0,  6, 16, 17, 26, 34, 40, 48, 56, 66, 70, 80];
		  KeyFlags & $07:				\Ctrl or Shift
			T:= [ 0, 27, 32, 37, 42, 47, 52, 57, 62, 67, 72, 78]
		other
			T:= [ 0,  1,  9, 17, 26, 34, 42, 48, 56, 64, 71, 80];

		for I:= 1, 10 do
		    begin
		    if X >= T(I)  &  X <= T(I+1)-2 then
			begin
			if ButtonTrigger(I+^F) then
				begin
				repeat	begin	\B = mouse still on soft button
					B:= GetMousePosition(1)>>3 = Y &
					    GetMousePosition(0)>>3 >= T(I) &
					    GetMousePosition(0)>>3 <= T(I+1)-2;
					ShowMouse(false);
					if I=7 & But1 & (KeyFlags&$0F)=0 then
						begin		\Change label
						Attrib(Cyan<<4 ! Black);
						Cursor(51, ScreenHeight-1);
						Text(TV, "Back");
						end;
					Backlight(T(I), Y, T(I+1)-2, Y, 
					    if B then Cyan else White);
					ShowMouse(true);
					Sound(0, 1, 1);	\Delay to reduce flicker
					end;
				until ~GetMouseButton(0) & ~GetMouseButton(1);

				ShowMouse(false);	\Unhilight button
				Backlight(T(I), Y, T(I+1)-2, Y, White);
				if I=7 & But1 & (KeyFlags&$0F)=0 then
					begin		\Restore label
					Attrib(White<<4 ! Black);
					Cursor(51, ScreenHeight-1);
					Text(TV, "Step");
					end;
				ShowMouse(true);

				\If still on original button then fake keystroke
				if B then
				  case of
				    KeyFlags & $08:
				      CallInt($16, $0500, 0, (AltFunc+I)<<8);
				    KeyFlags & $04: 
				      CallInt($16, $0500, 0, (CtrlFunc+I)<<8);
				    KeyFlags & $03:
				      CallInt($16, $0500, 0, (ShiftFunc+I)<<8)
				  other
				      begin
				      if I=7 & But1 then	\Backup
				        CallInt($16, $0500, 0, (AltFunc+I)<<8)
				      else CallInt($16, $0500, 0, (Func+I)<<8);
				      end;
				end;
			end;
		    end;
		ButtonTrigger(Y<<8!X);	\Don't trigger soft button if cursor
		end		\ slides onto it while mouse button is down

	other	ButtonTrigger(Y<<8!X);	\Don't trigger soft button if cursor
	end			\ slides onto it while mouse button is down

else	ButtonState:= 0;
end;	\loop
end;	\DoCmd

\===============================================================================

proc	Initialize;	\Initialize this simulator program
int	Seg, I, Div;
begin
Cpureg:= Getreg;	\Set up for DOSOpen
PSPSEG:= Cpureg(11);
DATASEG:= Cpureg(12);

ScreenWidth:= CallInt($10, $0F00)>>8; \Stretch display to actual width of screen
ScreenHeight:= Peek(0, $484);	     \Stretch display to actual height of screen
ScreenHeight:= if ScreenHeight<23 ! ScreenHeight>64 then 25 else ScreenHeight+1;
WinHeight:= ScreenHeight-1 - ListWinY;
ScrollBarHeight:= WinHeight - 2;
ClearPage1;

StatusTable:= [0, 4, 8, 11, 14, 17, 20, 23];	\Status bit's X coordinate

\Malloc takes about 2.5 ms per call so just grab a big hunk and chop it up
Seg:= Malloc(LineBufSize>>4 * ROMSizeMax);
for I:= 0, ROMSizeMax-1 do
	begin
	LineBuf(I):= Seg;
	Seg:= Seg + LineBufSize>>4;
	ROM(I):= $FFF;		\Unburned ROM
	Breakpoint(I):= true;	\Set all breakpoints (cleared by LoadListCode)
	Count0(I):= 0;   Count1(I):= 0;   Count2(I):= 0;	\Unexecuted
	end;

Text(0, "Loading list file...
");
DOSOpen;	\(leaves traps turned off if not debug)
ROM($1010):= $A5A5;	ROM($1011):= $A5A5;	\Set impossible fuse values
LoadListCode;

GetFUSE;

FUSEX:= FUSEX & $FFC;
case of
  ROMSize < $200: [ROMSize:=  $200];
  ROMSize < $400: [ROMSize:=  $400;   FUSEX:= FUSEX ! $001];
  ROMSize < $800: [ROMSize:=  $800;   FUSEX:= FUSEX ! $002]
other		  [ROMSize:= $1000;   FUSEX:= FUSEX ! $003];

\If fuse values are loaded from listing, they override default or saved values
if ROM($1010) # $A5A5 then FUSE:= ROM($1010);
if ROM($1011) # $A5A5 then FUSEX:= ROM($1011);

ROMSize:= $200 << (FUSEX & $003);

ROMMask:= ROMSize - 1;
ROMSizeEven:= (ROMSize+1) / ScrollBarHeight * ScrollBarHeight;
\ROMSizeEven is truncated to multiple of ScrollBarHeight.
\The +1 is for the blank line at the top of the listing.

StackSize:= if FUSE & $100 then 2 else 8;

if (FUSE & $080) = 0 then	\Internal RC oscillator is enabled
	begin			\Set Osc frequency according to FUSE bits
	Div:= FUSE>>4 & $007;
	Osc:= 4e6 / Float(1<<Div);
	end;

OpenStm;

TrapC(true);		\Force user to make a clean exit, restoring cursor etc.

CallInt($10, $0300);	\Save cursor shape so it can be restored when exiting
CursorShape:= Cpureg(2);

\Turn off flashing cursor (after loading, in case of disk error & abort, so
\ cursor won't be missing in DOS)
CallInt($10, $0100, 0, $2000);

SetColReg(Green, 0, 50, 0);	\Turn up green intensity for better contrast

Text(0, "Looking for mouse...
");
OpenMouse;				\This can take a whole second!
MoveMouse((ScreenWidth-1)*8, 0);	\Show mouse cursor in upper-right corner

HistInx:= 0;
HistBase:= 0;
BreakLoc:= -1;
TraceMode:= true;
ShowingCount:= false;

for I:= 0, RAMSize-1 do			\Set up "Map" to undo twisted memory map
	begin
	Map(I):= if I & $10 then I else I & $0F;
	DoneRAM(I):= false;
	RAM(I):= Ran(256);
	end;
WReg:= Ran(256);
Timer:= Ran(256);
LATCHA:= Ran(256);   LATCHB:= Ran(256);   LATCHC:= Ran(256);

RAM(RTCC):= Timer;
RAM(STATUS):= RAM(STATUS) ! $18;	\T0_=1 PD_=1;

MClrReset;
WinPtr:= PC - WinHeight>>1;		\Display PC line in middle of window

RAM(INDF):= RAM(Map(RAM(FSR)));		\Lie for the display
SaveRegs;				\Indicate no changes for no highlights
RAM(INDF):= $00;			\Cover the lie
end;	\Initialize

\------------------------------------------------------------------------------

begin	\Main
Initialize;

Chout(0, FF);				\Set up the screen
Hilight(0, ListWinY, ScreenWidth-1, ScreenHeight-1, White<<4!Black);
Hilight(ListWinX, ListWinY, ScreenWidth-2, ScreenHeight-2, Blue<<4!Yellow);
SetWind(0, 0, ScreenWidth-1, ScreenHeight-1, $0102, false);	\Turn off scroll
ShowMouse(true);

ShowLabels;
LineCursor:= PC;
ShowCode(LineCursor);	\(outputs PCLine)
DisplayRegs;
PointOut;		\(inputs PCLine)
ShowPromptLine(true);

Openi(0);		\Discard any pending keystroke
DoCmd;			\Go execute commands (never returns)
end;	\Main
