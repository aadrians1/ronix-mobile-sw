Loren
Blaney
loren_blaney@idcomm.com
1/3/99 1:12 PM
nop required
options:email:loren_blaney@idcomm.com

;How come I need a nop in the following little program for it to work right?

	device	pins28,pages1,banks8,osc31khz
	reset	start

	org	10h
ramloc	ds	1

	org	0
start	mov	!rb,#$F0	;set up LEDs (on demo board) as outputs

	clr	fsr		;fill all ram with pattern
:loop	setb	fsr.4
	mov	ind,#%1010
	ijnz	fsr,:loop

	bank	$30		;select bank 1
;(code removed for simplicity)

	sub	fsr,#$20	;next bank
	sc			;skip if underflow
	 bank	$50		;select bank 2
;	nop			;*** REQUIRED ***

	mov	rb,ramloc	;display result on LEDs
	jmp	$		;lock up

;rb outputs the expected 1010b when the nop is present, but it outputs 0000b
; when the nop is commented out.
;Chips tested: SX28AC/DP 9818, 9812, 9747.


