;BITCNT.ASM	NOV-02-97
;Optimized routines to count the number of set bits in a byte.
; by Loren Blaney

	DEVICE	PIC16C54,XT_OSC,WDT_OFF,PROTECT_OFF

BUF	EQU	08h		;buffer scratch location
CNT	EQU	09h		;counter

PAT	EQU	0Ah		;bit pattern
CNT1	EQU	0Bh		;bit count using method 1
CON	EQU	0Ch		;constant 19h

WREG	EQU	RTCC


	ORG	0
;------------------------------------------------------------------------------
;Tests three methods of counting the number of set bits in a byte.
;
	MOVLW	7Fh		;map W register into RTCC
	OPTION

	CLRF	PAT		;for all possible bytes...
LOOP	MOVF	PAT,W		;count bits using method 1
	CALL	BITCNT1
	MOVWF	CNT1		;save bit count

	MOVF	PAT,W		;count bits using method 2
	CALL	BITCNT2
	MOVF	CNT,W		;get bit count (it's different)

	XORWF	CNT1,W		;do the two methods give same result?
	BTFSS	STATUS.2	;skip if so
L1	GOTO	L1		;lock up if not

	MOVF	PAT,W		;count bits using method 3
	CALL	BITCNT3

	XORWF	CNT1,W		;is this count the same as the others?
	BTFSS	STATUS.2	;skip if so
L2	GOTO	L2		;lock up if not

	DECFSZ	PAT		;next pattern
	GOTO	LOOP
	SLEEP
	GOTO	LOOP

;------------------------------------------------------------------------------
;Counts the number of set bits in the W register. The count is returned in W.
; Straightforward method:
; 17 instructions, 18 cycles, 1 RAM variable.
;
BITCNT1	MOVWF	BUF
	ANDLW	01h		;initialize W with count for first bit
	BTFSC	BUF.1		;test remaining bits one at a time
	INCF	WREG		;increment count if bit is set
	BTFSC	BUF.2
	INCF	WREG
	BTFSC	BUF.3
	INCF	WREG
	BTFSC	BUF.4
	INCF	WREG
	BTFSC	BUF.5
	INCF	WREG
	BTFSC	BUF.6
	INCF	WREG
	BTFSC	BUF.7
	INCF	WREG
	RETLW	0	;RETURN

;------------------------------------------------------------------------------
;Counts the number of set bits in the W register. The count is returned in CNT.
; Optimized for size:
; 8 instructions, 9-58 cycles, 2 RAM variables.
;
BITCNT2	CLRF	CNT		;initialize bit counter
BC10	MOVWF	BUF		;shift W right
	ADDWF	BUF,W
	BTFSC	STATUS.0	;skip if carry is clear
	INCFSZ	CNT		;else count this bit
	BTFSS	STATUS.2	;skip if no more bits
	GOTO	BC10		;else loop
	RETLW	0	;RETURN

;------------------------------------------------------------------------------
;Scenix version with W register mapped into RTCC.
;Counts the number of set bits in the W register. The count is returned in W.
; Optimized for speed (without using a 256-entry lookup table):
; 14 instructions, 15 cycles, 1 RAM location.
;
BITCNT3	MOVWF	BUF

	RRF	WREG
	ANDLW	77h
	SUBWF	BUF

	RRF	WREG
	ANDLW	77h
	SUBWF	BUF

	RRF	WREG
	ANDLW	77h
	SUBWF	BUF

	SWAPF	BUF,W		;add counts in high and low nibbles
	ADDWF	BUF,W
	ANDLW	0Fh		;return with count in W
	RETLW	0	;RETURN
