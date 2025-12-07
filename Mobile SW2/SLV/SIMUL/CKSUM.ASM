;CKSUM.ASM	FEB-25-98
;Routine to calculate the checksum of instruction memory
; by Loren Blaney
;
	LIST	P=16C57		;closest PIC chip (has 2K)

	INCLUDE	"SXDEFS.INC"	;macro definitions for new instructions
DEVICE	EQU	PINS28+TURBO+SYNC+OPTIONX+STACKX+BANKS8+PAGES4


	ORG	10h
POINTER	RES	2		;pointer to words in instruction memory
SUM	RES	1		;accumulator for checksum


	ORG	0
START	CALL	CKSUM		;calculate checksum of ROM
	SLEEP			;stop
	GOTO	START		;loop forever

;----------------------------------------------------------------------

CKSUM	CLRF	POINTER		;initialize pointer to ROM
	CLRF	POINTER+1
	CLRF	SUM		;initialize checksum

CKSUM10	MOVF	POINTER+1,W	;move POINTER into MODE:W
	MOVWM			; copy low 4 bits in W into MODE
	MOVF	POINTER,W	; copy low 8 bits of POINTER into W
	IREAD			;move instr at (MODE:W) to MODE:W
	ADDWF	SUM,F		;add in low 8 bits
	MOVMW			;copy MODE to W
	ADDWF	SUM,F		;add in high 4 bits

	INCFSZ	POINTER,F	;loop for all of ROM (000-7FFh)
	 GOTO	CKSUM10
	INCF	POINTER+1,F
	BTFSS	POINTER+1,3	;does pointer = 800h ?
	 GOTO	CKSUM10		;loop if not

	MOVF	SUM,W		;return with checksum in W register
	RET


	ORG	07FFh		;reset vector
	GOTO	START

	END
