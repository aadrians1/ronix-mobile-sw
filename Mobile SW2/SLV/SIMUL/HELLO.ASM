;HELLO.ASM	MAR-21-98
;"Hello World!" demo with 2-for-1 compression on the Scenix Micro
; by Loren Blaney
;
;The ability of the Scenix processor to read program memory is used to pack
; two 6-bit characters into a word. Normally the RETLW instruction would
; be used, but that only takes advantage of 8 of the 12 bits in a word.
;

	PROCESSOR 16C54		;closest PIC chip
	RADIX	DEC
	ERRORLEVEL -305,-306	;",F" is the default; page boundaries are ok
	LIST	ST=OFF

	INCLUDE	"SXDEFS.INC"	;macro definitions for new instructions
DEVICE	EQU	OSC4MHZ+WATCHDOG


	ORG	07h
TEMP	RES	1		;universal temporary scratch location

;Variables for MSGOUT routine:
MSGPTR	RES	2		;pointer to words in instruction memory
MSG2ND	RES	1		;holds the second of a pair of characters

CR	EQU	0Dh		;ASCII characters
LF	EQU	0Ah

TEXT	MACRO	A,B		;pack two ASCII characters into a 12-bit word
	DATA	(A-1Ch & 03Fh)<<6  |  B-1Ch & 03Fh
	ENDM


	ORG	0
;-------------------------------------------------------------------------------
;Output the character in W to the printer
;
CHOUT	CLRWDT			;reset watchdog timer
	BTFSC	RA,0		;loop until not busy (busy = 1)
	 GOTO	CHOUT
	MOVWF	RB		;send byte to printer

;	PRINTX			;simulator print command

	BCF	RA,1		;set strobe low (active) for at least 0.5us
	BSF	RA,1		;set strobe high (inactive)
	RETP

;-------------------------------------------------------------------------------
;Print the message pointed to by W and MODE. The W register contains the low 8
; bits of the address, and MODE contains the high 4 bits. Messages can span
; page boundaries. The W and MODE registers are changed, along with TEMP.
;
;Messages are written using ASCII character codes 20h thru 5Fh. The TEXT macro
; packs two characters into a 12-bit word. Some characters have special meaning:
;   \ = Reserved. (Used to loop back for second character.)
;   ] = String terminator (end of text).
;   ^ = Shift case (toggles upper/lower).
;   _ = New line (CR+LF).
;
MSGOUT	MOVWF	MSGPTR		;save pointer to message
	MOVMW
	MOVWF	MSGPTR+1	;also clear bit 5 to select uppercase letters

MO10	MOVF	MSGPTR+1,W	;move MSGPTR into MODE:W
	MOVWM			; copy low 4 bits in W into MODE
	MOVF	MSGPTR,W	; copy low 8 bits of MSGPTR into W
	IREAD			;move instruction word at (MODE:W) to MODE:W

	MOVWF	MSG2ND		;save second character
	MOVMW			;copy MODE to W to TEMP
	MOVWF	TEMP
	RLF	MSG2ND		;form first character (6 bits) in TEMP
	RLF	TEMP		; TEMP <-- MSG2ND
	RLF	MSG2ND,W
	RLF	TEMP

MO20	DECFSZ	TEMP		;test for special characters:
	 GOTO	MO30
	RETP			;1 = ] = string terminator

MO30	DECFSZ	TEMP
	 GOTO	MO40
	MOVLW	20h		;2 = ^ = shift case
	XORWF	MSGPTR+1	;toggle the case-shift flag bit
	GOTO	MO60

MO40	DECFSZ	TEMP
	 GOTO	MO50
	MOVLW	CR		;3 = _ = new line (CR & LF)
	CALL	CHOUT
	MOVLW	LF
	GOTO	MO55

MO50	MOVLW	1Fh		;add offset to convert back to ASCII
	ADDWF	TEMP
	MOVF	MSGPTR+1,W	;shift to uppercase if the case-shift bit
	ANDLW	20h		; is set
	IORWF	TEMP,W
MO55	CALL	CHOUT		;output the ASCII character

MO60	RRF	MSG2ND,W	;undo the RLF above
	CLRF	MSG2ND		;zero it for next time thru loop (0 = \)
	ANDLW	3Fh		;mask off garbage and set Z status
	MOVWF	TEMP		;get copy into TEMP (w/o changing status)
	BTFSS	STATUS,Z
	 GOTO	MO20		;loop back for second character

	INCFSZ	MSGPTR		;loop until terminator is found
	 GOTO	MO10
	INCF	MSGPTR+1	;(in case string spans a page boundary)
	 GOTO	MO10

;-------------------------------------------------------------------------------
;Initialize parallel output port to the printer
;
INIT	CLRWDT			;reset watchdog timer
	MOVLW	00h		;internal instruction clock
	OPTION			;(6-bit option register--no RTCC interrupts)

	MOVLW	0FDh		;PORT A:
	TRIS	RA		; bit 0 = input (printer busy line)
				; bit 1 = output (printer strobe line)
	BSF	RA,1		;set strobe high (inactive)

	MOVLW	00h		;make all port B bits outputs
	TRIS	RB
	RETP

;-------------------------------------------------------------------------------
;Entry point
;
START	CALL	INIT		;initialize parallel output port

LOOP	MODE	MSG >> 8	;get pointer to message
	MOVLW	MSG & 0FFh
	CALL	MSGOUT		;output message
	GOTO    LOOP		;loop forever


MSG	TEXT	'H', '^'	;Hello World!<CRLF>
	TEXT	'E', 'L'
	TEXT	'L', 'O'
	TEXT	' ', '^'
	TEXT	'W', '^'
	TEXT	'O', 'R'
	TEXT	'L', 'D'
	TEXT	'!', '_'
	TEXT	']', 0


	ORG	01FFh		;reset vector
	GOTO	START

	END
