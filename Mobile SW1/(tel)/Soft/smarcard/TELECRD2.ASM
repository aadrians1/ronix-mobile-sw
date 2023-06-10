
	TITLE   "ISO 7816 Synchronous Memory Card Emulator"
	LIST    P=PIC16C84, R=HEX
	INCLUDE "PICREG.EQU"

; PIC16C84 I/O Pin Assignment List

CRD_CLK         equ     0       ; RB0 + RA4 = Card Clock
CRD_DTA         equ     0       ; RA0 = Card Data Output
CRD_RST         equ     1       ; RB1 = Card Reset, Low-Active
CRD_WE          equ     7       ; RB7 = Card Write-Enable, Hi-Active

; PIC16C84 RAM Register Assignments

CRD_ID          equ     0x00c   ; Smartcard ID, 12 bytes
FUSCNT          equ     0x018   ; Fused units counter
BITCNT          equ     0x019   ; Bitcounter
LOOPCNT         equ     0x01a   ; Loop Counter
EE_FLAG         equ     0x01b   ; EEPROM Write Flag
TEMP1           equ     0x01c   ; Temporary Storage #1
TEMP2           equ     0x01d   ; Temporary Storage #2
TEMP3           equ     0x01e   ; Temporary Storage #3
TEMP4           equ     0x01f   ; Temporary Storage #4
TEMP_W          equ     0x02e   ; Temporary W Save Address
TEMP_S          equ     0x02f   ; Temporary STATUS Save Address

	org     0x2000          ; Chip ID Data
	dw      042,042,042,042

	org     0x2007          ; Configuration Fuses
	dw      B'00000001'

	org     0x2100          ; Internal Data EEPROM Memory (Card ID Data!)
	db      0x081,0x042,0x000,0x011,0x022,0x033
	db      0x044,0x055,0x066,0x077,0x011,0x084
	db      0x002           ; Fresh Card Fused Units Count

	org     PIC84           ; Reset-vector
	goto    INIT            ; Jump to initialization routine

	org     INTVEC          ; Interupt-vector
	push                    ; Save registers
	call    INTMAIN         ; Call main interupt routine
	pop                     ; Restore registers
	retfie                  ; return from interupt & clear flag

	org     0x010           ; Start address for init rout.
INIT    bsf     STATUS,RP0      ; Access register bank 1
	clrwdt                  ; Clear watchdog timer
	movlw   B'11101000'     ; OPTION reg. settings
	movwf   OPTION          ; Store in OPTION register
	movlw   B'11111110'     ; Set PORT A Tristate Latches
	movwf   TRISA           ; Store in PORT A tristate register
	movlw   B'11111111'     ; Set PORT B Tristate Latches
	movwf   TRISB           ; Store in PORT B tristate register
	bcf     STATUS,RP0      ; Access register bank 0
	clrf    RTCC            ; Clear RTCC
	clrf    PORTA           ; Clear PORTA
	clrf    PORTB           ; Clear PORTB
	movlw   0d              ; 13 bytes to copy
	movwf   LOOPCNT         ; Store in LOOPCNT
	movlw   0c              ; Start storing at $0c in RAM
	movwf   FSR             ; Store in FSR
	clrf    EEADR           ; Start at EEPROM Address 0
EECOPY  
	bsf     STATUS,RP0      ; Access register bank 1
	bsf     EECON1,RD       ; Set EECON1 Read Data Flag
	bcf     STATUS,RP0      ; Access register bank 0
	movfw   EEDATA          ; Read one byte of EEPROM Data
	movwf   INDIR           ; Store in RAM pointed at by FSR
	incf    FSR             ; Increase FSR pointer
	incf    EEADR           ; Increase EEPROM Address Pointer
	decfsz  LOOPCNT,1       ; Decrease LOOPCNT until it's 0
	goto    EECOPY          ; Go and get some more bytes!
	bsf     STATUS,RP0      ; Access register bank 1
	bcf     EECON1,EEIF     ; Clear EEPROM Write Int. Flag
	bcf     EECON1,WREN     ; EEPROM Write Disable
	bcf     STATUS,RP0      ; Access register bank 0
	movlw   B'10010000'     ; Enable INT Interupt
	movwf   INTCON          ; Store in INTCON

MAIN    bsf     STATUS,RP0      ; Access register bank 1
	btfsc   EECON1,WR       ; Check if EEPROM Write Flag Set
	goto    MAIN            ; Skip if EEPROM Write is Completed
	bcf     EECON1,EEIF     ; Reset Write Completion Flag
	bcf     EECON1,WREN     ; EEPROM Write Disable
	bcf     STATUS,RP0      ; Access register bank 0
	btfss   EE_FLAG,LSB     ; Check for EEPROM Write Flag
	goto    MAIN            ; If not set, jump back and wait some more
	clrf    EE_FLAG         ; Clear EEPROM Write Flag
	movlw   0c              ; Units is stored in byte $0c
	movwf   EEADR           ; Store in EEPROM Address Counter
	movfw   FUSCNT          ; Get fused units counter
	movwf   EEDATA          ; Store in EEDATA
	bsf     STATUS,RP0      ; Access register bank 1
	bsf     EECON1,WREN     ; EEPROM Write Enable
	bcf     INTCON,GIE      ; Disable all interupts
	movlw   055             ; Magic Number #1 for EEPROM Write
	movwf   EECON2          ; Store in EECON2
	movlw   0aa             ; Magic Number #2 for EEPROM Write
	movwf   EECON2          ; Store in EECON2
	bsf     EECON1,WR       ; Execute EEPROM Write
	bsf     INTCON,GIE      ; Enable all interupts again!
	bcf     STATUS,RP0      ; Access register bank 0
	goto    MAIN            ; Program main loop!

INTMAIN btfsc   INTCON,INTF     ; Check for INT Interupt
	goto    INTMAIN2        ; If set, jump to INTMAIN2
	movlw   B'00010000'     ; Enable INT Interupt
	movwf   INTCON          ; Store in INTCON
	return

INTMAIN2
	bcf     STATUS,RP0      ; Access register bank 0
	bsf     PORTA,CRD_DTA   ; Set Data Output High
	btfsc   PORTB,CRD_RST   ; Check if reset is low
	goto    NO_RST          ; If not, skip reset sequence
	movfw   RTCC            ; Get RTCC Value
	movwf   TEMP4           ; Store in TEMP4
	clrf    RTCC            ; Clear RTCC
	movlw   055             ; Subtract $55 from TEMP4
	subwf   TEMP4,0         ; to check for card reset....
	bnz     NO_RST2         ; If not zero, jump to NO_RST
	movlw   02              ; Unused one has $02 in FUSCNT
	movwf   FUSCNT          ; Store full value in FUSCNT
	bsf     EE_FLAG,LSB     ; Set EEPROM Write Flag
NO_RST2 bcf     INTCON,INTF     ; Clear INT Interupt Flag
	return                  ; Mission Accomplished, return to sender

NO_RST  movfw   RTCC            ; Get RTCC Value
	movwf   BITCNT          ; Copy it to BITCNT
	movwf   TEMP1           ; Copy it to TEMP1
	movwf   TEMP2           ; Copy it to TEMP2
	movlw   060             ; Load W with $60
	subwf   TEMP1,0         ; Subtract $60 from TEMP1
	bz      CREDIT          ; If it is equal to $60
	bc      CREDIT          ; or greater, then skip to units area
	rrf     TEMP2           ; Rotate TEMP2 one step right
	rrf     TEMP2           ; Rotate TEMP2 one step right
	rrf     TEMP2           ; Rotate TEMP2 one step right
	movlw   0f              ; Load W with $f
	andwf   TEMP2,1         ; And TEMP2 with W register
	movfw   TEMP2           ; Load W with TEMP2
	addlw   0c              ; Add W with $0c
	movwf   FSR             ; Store data address in FSR
	movfw   INDIR           ; Get databyte pointed at by FSR
	movwf   TEMP3           ; Store it in TEMP3
	movlw   07              ; Load W with $07
	andwf   TEMP1,1         ; And TEMP1 with $07
	bz      NO_ROT          ; If result is zero, skip shift loop
ROTLOOP rlf     TEMP3           ; Shift TEMP3 one step left
	decfsz  TEMP1,1         ; Decrement TEMP1 until zero
	goto    ROTLOOP         ; If not zero, repeat until it is!
NO_ROT  btfss   TEMP3,MSB       ; Check if MSB of TEMP3 is set
	bcf     PORTA,CRD_DTA   ; Clear Data Output
	bcf     INTCON,INTF     ; Clear INT Interupt Flag
	return                  ; Mission Accomplished, return to sender

CREDIT  btfss   PORTB,CRD_WE    ; Check if Card Write Enable is High
	goto    NO_WRT          ; Abort write operation if not...
	btfss   PORTB,CRD_RST   ; Check if Card Reset is High
	goto    NO_WRT          ; Abort write operation if not...
	incf    FUSCNT          ; Increase used-up units counter
	bsf     EE_FLAG,LSB     ; Set EEPROM Write-Flag
	bcf     INTCON,INTF     ; Clear INT Interupt Flag
	return                  ; Mission Accomplished, return to sender

NO_WRT  movlw   060             ; Load W with $60
	subwf   BITCNT,1        ; Subtract $60 from BITCNT
	movfw   FUSCNT          ; Load W with FUSCNT
	subwf   BITCNT,1        ; Subtract FUSCNT from BITCNT
	bnc     FUSED           ; If result is negative, unit is fused
	bcf     PORTA,CRD_DTA   ; Clear Data Output
FUSED   bcf     INTCON,INTF     ; Clear INT Interupt Flag
	return                  ; Mission Accomplished, return to sender
	
	END
