;RTCCINT.ASM	FEB-25-98
; Simple program using RTCC-rollover interrupt.
; RB.0 toggles via main code and RB.1 toggles via interrupt.
;

	PROCESSOR 16C58A	;closest PIC chip
	RADIX	DEC
	ERRORLEVEL 1
	LIST	ST=OFF

	INCLUDE	"SXDEFS.INC"	;macro definitions for new instructions

DEVICE	EQU	PAGES4+BANKS8+TURBO+OPTIONX+OSC4MHZ+BOR40


	ORG	0		;(3) interrupt routine (3 cycles in)
	MOVLW	10b		;(1) toggle RB.1
	XORWF	RB		;(1)

	MOVLW	-20		;(1) interrupt every 20*2 cycles
	RETIW			;(3) 9 cycles total interrupt time


START	MOVLW	10000000b	;enable RTCC interrupt, divide rate 1:2
	OPTION

	MOVLW	11111100b	;make RB.0 and RB.1 outputs
	TRIS	RB

	MOVLW	1		;ready to toggle RB.0
LOOP	XORWF	RB		;(1) toggle RB.0
	GOTO	LOOP		;(3) 4 cycles total loop time


	ORG	07FFh		;reset vector
	GOTO	START

	END
