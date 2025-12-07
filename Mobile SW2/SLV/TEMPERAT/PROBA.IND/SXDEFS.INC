	NOLIST
;SXDEFS.INC	MAR-21-98
;Scenix SX Definitions for MPASM.
;If your code uses these definitions in lowercase, assemble with the /c- switch.
;
;REVISIONS:
;FEB-23-98, Released.
;MAR-21-98, Added ID label. Corrected XT & HS defs by swapping them.
; Removed ASCII defs. New STATUS defs.

	RADIX	DEC

;Define special function registers:
INDF	EQU	00h		;used for indirects thru fsr
RTCC	EQU	01h		;real time clock/counter
PC	EQU	02h		;low 8 bits of PC
STATUS	EQU	03h		;status bits
FSR	EQU	04h		;file select register
PORTA	EQU	05h		;I/O ports
PORTB	EQU	06h		;supports multi-input wake-up (MIWU)
PORTC	EQU	07h

;Define STATUS register bits:
C	EQU	0		;carry
DC	EQU	1		;digit carry
Z	EQU	2		;zero
PD	EQU	3		;sleep power down (true low)
TO	EQU	4		;watchdog time out (true low)
PA0	EQU	5		;page select (LSB)
PA1	EQU	6		;page select
PA2	EQU	7		;page select (MSB)

;Define MODE registers:
TRISX	EQU	0Fh		;tristate (1=input, 0=output)
PLP	EQU	0Eh		;pullup (1=none, 0=20k)
LVL	EQU	0Dh		;level (1=TTL, 0=CMOS)
ST	EQU	0Ch		;Schmitt trigger (1=disabled, 0=enabled)
WKEN	EQU	0Bh		;wake up (1=disabled, 0=enabled)
WKED	EQU	0Ah		;wake up edge (1=falling, 0=rising)
WKPND	EQU	09h		;wake up pending (1=pending, 0=none)
CMP	EQU	08h		;comparator bit: 0=result, 6=output, 7=enabled


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
	DATA	10h|N	;PAGE	;write N into bits PA2:PA0 (N = 0-7)
	ENDM

BANKX	MACRO	N		;(MPASM already uses "BANK")
	DATA	18h|N	;BANK	;write N into bits FSR7:FSR5 (N = 0-7)
	ENDM

MODE	MACRO	N
	DATA	50h|N	;MODE	;write N into MODE register (N = 0-F)
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


;Define macro for ID label. Example:
;	ID	'S', 'X', '-', 'D', 'e', 'm', 'o', ' '

ID	MACRO	A,B,C,D,E,F,G,H		;Set up ID label
	ERRORLEVEL	-220	;don't display "address exceeds range" warning
	ORG	1000h
	DATA	(A>>4) & 0Fh, A & 0Fh
	DATA	(B>>4) & 0Fh, B & 0Fh
	DATA	(C>>4) & 0Fh, C & 0Fh
	DATA	(D>>4) & 0Fh, D & 0Fh
	DATA	(E>>4) & 0Fh, E & 0Fh
	DATA	(F>>4) & 0Fh, F & 0Fh
	DATA	(G>>4) & 0Fh, G & 0Fh
	DATA	(H>>4) & 0Fh, H & 0Fh
	ERRORLEVEL	+220	;restore warning message
	ORG	0
	ENDM


;Define device symbols for configuration words (FUSE & FUSEX):

OSCXT	EQU	00b		;normal external crystal/resonator (inverted)
OSCRC	EQU	10b		;external RC network
OSCLP	EQU	01b		;low power external crystal/resonator
OSCHS	EQU	11b		;high speed external crystal/resonator (default)


WATCHDOG EQU	1 << 2		;watchdog timer enabled
				; default is disabled
PROTECT	EQU	1 << 3		;code protect enabled (inverted)
				; default is to disable code protect

OSC4MHZ	EQU	11110001b	;internal 4MHz (inverted)
OSC2MHZ	EQU	11100001b	;internal 2MHz
OSC1MHZ	EQU	11010001b	;internal 1MHz
OSC500KHZ EQU	11000001b	;internal 500KHz
OSC250KHZ EQU	10110001b	;internal 250KHz
OSC125KHZ EQU	10100001b	;internal 125KHz
OSC62KHZ EQU	10010001b	;internal 62.5KHz
OSC31KHZ EQU	10000001b	;internal 31.25KHz

STACKX	EQU	1 << 8		;stack is extended to 8 levels (inverted)
				; default is 2 levels
OPTIONX	EQU	1 << 9		;extend option register to 8 bits (inverted)
				; default is 6 bits
SYNC	EQU	1 << 10		;input syncing enabled (inverted)
				; default is disabled
TURBO	EQU	1 << 11		;turbo mode enabled (inverted)
				; default is disabled

PAGES1	EQU	00b << 12	;default
PAGES2	EQU	01b << 12
PAGES4	EQU	10b << 12
PAGES8	EQU	11b << 12

BANKS1	EQU	00b << 14	;default
BANKS2	EQU	01b << 14
BANKS4	EQU	10b << 14
BANKS8	EQU	11b << 14

BOR40	EQU	11b << 16	;4.0V brownout reset
BOR25	EQU	10b << 16	;2.5
BOR13	EQU	01b << 16	;1.3
;BOR00	EQU	00b << 16	;disabled (default)

CARRYX	EQU	1 << 18		;ADDWF & SUBWF use carry input (inverted)
				; default is to ignore carry in

PINS18	EQU	00b << 22	;for compatibility with SX-Key (default)
PINS28	EQU	01b << 22
PINS40	EQU	10b << 22
PINS64	EQU	11b << 22


_INVERT	EQU	070FF9h		;the default looks like a PIC16C54

_DEVICE	SET	DEVICE ^ _INVERT
_FUSE	SET	_DEVICE & 0FFFh
_FUSEX	SET	_DEVICE >> 12

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