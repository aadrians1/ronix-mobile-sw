	NOLIST
;SXDEFS.INC	OCT-4-98
;Scenix SX Definitions for MPASM.
;
;REVISIONS:
;FEB-23-98, Released.
;MAR-21-98, Added ID label. Corrected XT & HS defs by swapping them.
; Removed ASCII defs. New STATUS defs.
;MAR-27-98, Added PAGEA, BANKA, FCALL, FGOTO, SKIP.
;APR-13-98, Added CSA, CSBE (etc.) macros. Enclose all arguments in parentheses.
;  Indent macros.
;APR-23-98, Changed some comments.
;OCT-4-98, Removed "RADIX DEC", added processor type based on SX FUSEX bits,
;  added Trim bits to FUSEX and other cleanup.   R.O.


;Define special function registers:
IND	EQU	00h		;used for indirects thru fsr
RTCC	EQU	01h		;real time clock/counter
PC	EQU	02h		;low 8 bits of PC
STATUS	EQU	03h		;status bits
FSR	EQU	04h		;file select register
RA	EQU	05h		;I/O ports
RB	EQU	06h		;supports multi-input wake-up (MIWU)
RC	EQU	07h

;Define STATUS register bits:
C	EQU	0		;carry
DC	EQU	1		;digit carry
Z	EQU	2		;zero
PD	EQU	3		;sleep power down (true low)
TO	EQU	4		;watchdog time out (true low)
PA0	EQU	5		;page select (LSB)
PA1	EQU	6		;page select
PA2	EQU	7		;page select (MSB)

;Define port control registers:
TRISX	EQU	0Fh		;tristate (1=input, 0=output)
PLP	EQU	0Eh		;pullup (1=none, 0=20k)
LVL	EQU	0Dh		;level (1=TTL, 0=CMOS)
ST	EQU	0Ch		;Schmitt trigger (1=disabled, 0=enabled)
WKEN	EQU	0Bh		;wake up (1=disabled, 0=enabled)
WKED	EQU	0Ah		;wake up edge (1=falling, 0=rising)
WKPND	EQU	09h		;wake up pending (1=pending, 0=none)
CMP	EQU	08h		;comparator bit: 0=result, 6=output, 7=enabled


;Define device symbols for configuration words (FUSE & FUSEX):

OSCXT	EQU	b'00'		;normal external crystal/resonator (inverted)
OSCRC	EQU	b'10'		;external RC network
OSCLP	EQU	b'01'		;low power external crystal/resonator
OSCHS	EQU	b'11'		;high speed external crystal/resonator (default)


WATCHDOG EQU	1 << 2		;watchdog timer enabled
				; default is disabled
PROTECT	EQU	1 << 3		;code protect enabled (inverted)
				; default is to disable code protect

OSC4MHZ	EQU	b'11110001'	;internal 4MHz (inverted)
OSC2MHZ	EQU	b'11100001'	;internal 2MHz
OSC1MHZ	EQU	b'11010001'	;internal 1MHz
OSC500KHZ EQU	b'11000001'	;internal 500KHz
OSC250KHZ EQU	b'10110001'	;internal 250KHz
OSC125KHZ EQU	b'10100001'	;internal 125KHz
OSC62KHZ EQU	b'10010001'	;internal 62.5KHz
OSC31KHZ EQU	b'10000001'	;internal 31.25KHz

STACKX	EQU	1 << d'8'	;stack is extended to 8 levels (inverted)
				; default is 2 levels
OPTIONX	EQU	1 << d'9'	;extend option register to 8 bits (inverted)
				; default is 6 bits
SYNC	EQU	1 << d'10'	;input syncing enabled (inverted)
				; default is disabled
TURBO	EQU	1 << d'11'	;turbo mode enabled (inverted)
				; default is disabled

PAGES1	EQU	b'00' << d'12'	;default
PAGES2	EQU	b'01' << d'12'
PAGES4	EQU	b'10' << d'12'
PAGES8	EQU	b'11' << d'12'

BANKS1	EQU	b'00' << d'14'	;default
BANKS2	EQU	b'01' << d'14'
BANKS4	EQU	b'10' << d'14'
BANKS8	EQU	b'11' << d'14'

BOR40	EQU	b'11' << d'16'	;4.0V brownout reset
BOR25	EQU	b'10' << d'16'	;2.5
BOR13	EQU	b'01' << d'16'	;1.3
;BOR00	EQU	b'00' << d'16'	;disabled (default)

CARRYX	EQU	1 << d'18'	;ADDWF & SUBWF use carry input (inverted)
				; default is to ignore carry in

BOSC	EQU	1 << d'19'	;for changing the "BOSC" bit (inverted)
				; default is no change

TRIM0	EQU	b'00' << d'20'	;for modifying factory IRC calibration (default)
TRIM3	EQU	b'01' << d'20'
TRIM6	EQU	b'10' << d'20'
TRIM9	EQU	b'11' << d'20'	;lowest frequency, about 3% per step

PINS18	EQU	b'00' << d'22'	;for compatibility with SX-Key (default)
PINS28	EQU	b'01' << d'22'
PINS40	EQU	b'10' << d'22'
PINS64	EQU	b'11' << d'22'


_INVERT	EQU	070FF9h		;the default looks like a PIC16C54

_DEVICE	SET	DEVICE ^ _INVERT
_FUSE	SET	_DEVICE & 0FFFh
_FUSEX	SET	_DEVICE >> d'12'

;Select a Microchip processor enough like the Scenix processor to satisfy the
; assembler

	PROCESSOR	16C57	;select a default Microchip processor
_PINS	SET	(_FUSEX & 0C00h) >> d'10'
_ROM	SET	_FUSEX & 003h
	ERRORLEVEL	-223	;processor type change is OK
	IF	(_PINS == 00h) && (_ROM == 00h)	;18 pin, 512 words
	LIST
	PROCESSOR	16C54	; "SX18AA"
	NOLIST
	ENDIF
	IF	(_PINS == 01h) && (_ROM == 00h)	;28 pin, 512 words
	LIST
	PROCESSOR	16C55	; "SX28AA"
	NOLIST
	ENDIF
	IF	(_PINS == 00h) && (_ROM == 01h)	;18 pin, 1K words
	LIST
	PROCESSOR	16C56	; "SX18AB"
	NOLIST
	ENDIF
	IF	(_PINS == 01h) && (_ROM == 02h)	;28 pin, 2K words
	LIST
	PROCESSOR	16C57	; "SX28AC"
	NOLIST
	ENDIF
	IF	(_PINS == 00h) && (_ROM == 02h)	;18 pin, 2K words
	LIST
	PROCESSOR	16C58A	; "SX18AC"
	NOLIST
	ENDIF
	ERRORLEVEL	+223	;flag the processor type being changed

;Define macros for new Scenix instructions:

IREAD	MACRO
	  DATA	41h	;IREAD	;move instruction at (MODE:W) to MODE:W
	ENDM

MOVMW	MACRO
	  DATA	42h	;MOVMW	;move MODE register to W register
	ENDM

MOVWM	MACRO
	  DATA	43h	;MOVWM	;move W register to MODE register
	ENDM

RET	MACRO
	  DATA	0Ch	;RET	;return without destroying W register
	ENDM

RETP	MACRO
	  DATA	0Dh	;RETP	;RET & write return addr bits 10:9 into PA1:PA0
	ENDM

RETI	MACRO
	  DATA	0Eh	;RETI	;return from interrupt (pull W, STATUS, FSR, PC)
	ENDM

RETIW	MACRO
	  DATA	0Fh	;RETIW	;return from interrupt and add W to RTCC
	ENDM

PAGEX	MACRO	N		;(MPASM already uses "PAGE")
	  NOLIST
	  IF	(N)&0FFFFFFF8h
	  ERROR	"page > 7"
	  ENDIF
	  LIST
	  DATA	10h | (N)	;PAGE--write N into bits PA2:PA0 (N = 0-7)
	ENDM

PAGEA	MACRO	A		;(MPASM already uses "PAGE")
	  DATA	10h|((A)>>d'9')	;PAGE--write bits A12:A10 into PA2:PA0
	ENDM

BANKX	MACRO	N		;(MPASM already uses "BANK")
	  NOLIST
	  IF	(N)&0FFFFFFF8h
	  ERROR	"bank > 7"
	  ENDIF
	  LIST
	  DATA	18h|(N)	;BANK	;write N into bits FSR7:FSR5 (N = 0-7)
	ENDM

BANKA	MACRO	A		;(MPASM already uses "BANK")
	  DATA	18h|((A)>>5)	;BANK--write bits A7:A5 into FSR7:FSR5
	ENDM

MODE	MACRO	N
	  NOLIST
	  IF	(N)&0FFFFFFF0h
	  ERROR	"mode > 0Fh"
	  ENDIF
	  LIST
	  DATA	50h|(N)	;MODE	;write N into MODE register (N = 0-F)
	ENDM


;Define macros for SxSim simulator instructions:

PRINTX	MACRO
	  DATA	01h	;PRINT	;simulator instruction: print byte in W
	ENDM

INPUTX	MACRO
	  DATA	0Ah	;INPUT	;simulator instruction: W gets ASCII keystroke
	ENDM

OUTPUTX	MACRO
	  DATA	0Bh	;OUTPUT	;simulator instruction: display ASCII char in W
	ENDM


;Define some basic macros:

FGOTO	MACRO	A		;(MPASM already uses "LGOTO")
	  ERRORLEVEL	-306	;don't display "crossing page boundary" message
	  DATA	10h|((A)>>d'9')	;PAGE--write bits A12:A10 into PA2:PA0
	  GOTO	(A)&1FFh
	  ERRORLEVEL	+306	;restore "crossing page boundary" message
	ENDM

FCALL	MACRO	A		;(MPASM already uses "LCALL")
	  ERRORLEVEL	-306	;don't display "crossing page boundary" message
	  DATA	10h|((A)>>d'9')	;PAGE--write bits A12:A10 into PA2:PA0
	  CALL	(A)&1FFh
	  ERRORLEVEL	+306	;restore "crossing page boundary" message
	ENDM			;(don't replace 1FFh with 0FFh)

SKIP	MACRO			;in turbo mode this saves one cycle over a GOTO
	  NOLIST
	  IF	$&1		;odd location
	  LIST
	  BTFSC	PC,0		;always skips
	  NOLIST
	  ELSE			;even location
	  LIST
	  BTFSS	PC,0		;always skips
	  NOLIST
	  ENDIF
	  LIST
	ENDM

CSA	MACRO	X,Y
	  MOVF	X,W		;compare arg1 to arg2 and skip if above
	  SUBWF	Y,W
	  BTFSC	STATUS,C
	ENDM

CSA#	MACRO	X,Y
	  MOVLW	(Y)^0FFh	;compare arg1 to literal and skip if above
	  ADDWF	X,W
	  BTFSS	STATUS,C
	ENDM

CSAE	MACRO	X,Y
	  MOVF	Y,W		;compare arg1 to arg2 and skip if above or equal
	  SUBWF	X,W
	  BTFSS	STATUS,C
	ENDM

CSAE#	MACRO	X,Y
	  MOVLW	Y		;compare arg1 to lit. and skip if above or equal
	  SUBWF	X,W
	  BTFSS	STATUS,C
	ENDM

CSB	MACRO	X,Y
	  MOVF	Y,W		;compare arg1 to arg2 and skip if below
	  SUBWF	X,W
	  BTFSC	STATUS,C
	ENDM

CSB#	MACRO	X,Y
	  MOVLW	Y		;compare arg1 to literal and skip if below
	  SUBWF	X,W
	  BTFSC	STATUS,C
	ENDM

CSBE	MACRO	X,Y
	  MOVF	X,W		;compare arg1 to arg2 and skip if below or equal
	  SUBWF	Y,W
	  BTFSS	STATUS,C
	ENDM

CSBE#	MACRO	X,Y
	  MOVLW	(Y)^0FFh	;compare arg1 to lit. and skip if below or equal
	  ADDWF	X,W
	  BTFSC	STATUS,C
	ENDM


;Define macro for ID label. Example:
;	ID	'S', 'X', '-', 'D', 'e', 'm', 'o', ' '

ID	MACRO	A,B,C,D,E,F,G,H		;set up ID label
	  NOLIST
	  ERRORLEVEL	-220	;don't display "address exceeds range" warning
	  ORG	1000h
	  DATA	(A>>4)&0Fh, A&0Fh
	  DATA	(B>>4)&0Fh, B&0Fh
	  DATA	(C>>4)&0Fh, C&0Fh
	  DATA	(D>>4)&0Fh, D&0Fh
	  DATA	(E>>4)&0Fh, E&0Fh
	  DATA	(F>>4)&0Fh, F&0Fh
	  DATA	(G>>4)&0Fh, G&0Fh
	  DATA	(H>>4)&0Fh, H&0Fh
	  ERRORLEVEL	+220	;restore warning message
	  ORG	0
	  LIST
	ENDM

	ERRORLEVEL	-220	;don't display "address exceeds range" warning
	ORG	1010h
	LIST
	DATA	_FUSE		;configuration bits (TURBO, SYNC, OPTIONX, etc.)
	DATA	_FUSEX		; (PINS, CARRYX, BOR40, BANKS, PAGES)
	NOLIST
	ERRORLEVEL	+220	;restore warning message
	ORG	0
	LIST
