        LIST P=16C84
;CONST
STATUS		EQU	03h
OPTN		EQU	01h	;(81h)
TRISA		EQU	05h	;(85h)
TRISB		EQU	06h	;(86h)
PORTA		EQU	05h
PORTB		EQU	06h

;RAM
FLAGS	        EQU     0Eh
KEYFL		EQU	0	;BITS
KEYFL1		EQU	1	;

SCAN	        EQU     0Fh
SCAN1	        EQU     10h
SCANCNT         EQU     11h
KEYTMR          EQU     12h

TIME		EQU	13h     ;FOR TM
TIME1		EQU	14h	;FOR TMLONG
Keyf            equ     15h
Protdelay1      equ     16h
Protdelay2      equ     17h
Delayreg1       equ     18h
Delayreg2       equ     19h
Doorf           equ     20h
; �祩�� ���
EE_Nkey         equ     00h
; ���� ���� �
DOORD           equ     0       ; ���稪 ����
TRANZ           equ     1       ; ᨫ���� �࠭�����
RED_LED         equ     2       ; ᢥ⮤���
RELE            equ     3       ; ५� ���ࠢ�����
ALERT           equ     4       ; ᨣ�������� ������
; ���� Doorf
ZAMOK           equ     1
DVER            equ     0
; ������ ᥪ�� : ��砫� �ᯮ��塞��� ����
;
        ORG     0
        goto    MAIN
;
        ORG     30h
MAIN
        CALL    INIP
BEGIN	MOVLW	B'00001110'
	MOVWF	PORTB
	CALL	KEYPRESS
	BTFSC	FLAGS,KEYFL
	GOTO	PRESS
	MOVLW	B'00001101'
	MOVWF	PORTB
	CALL	KEYPRESS
	BTFSC	FLAGS,KEYFL
	GOTO	PRESS
	MOVLW	B'00001011'
	MOVWF	PORTB
	CALL	KEYPRESS
	BTFSC	FLAGS,KEYFL
	GOTO	PRESS
	MOVLW	B'00000111'
	MOVWF	PORTB
	CALL	KEYPRESS
	BTFSC	FLAGS,KEYFL
	GOTO	PRESS

	CALL	TM
	BCF	FLAGS,KEYFL1
	DECFSZ	KEYTMR,1
	GOTO	BEGIN
	SLEEP
	GOTO	MAIN		
PRESS	MOVLW	0FFh
	MOVWF	KEYTMR
	CALL	TM
	BTFSC	FLAGS,KEYFL1
	GOTO	CON1
	MOVLW	20h
	MOVWF	SCANCNT
	BSF	FLAGS,KEYFL1
	MOVFW	SCAN
	MOVWF	SCAN1
	GOTO	BEGIN

CON1	MOVFW	SCAN1
	XORWF	SCAN,0
	BZ	CON2
	BCF	FLAGS,KEYFL1
	GOTO	BEGIN
CON2	DECFSZ	SCANCNT,1
	GOTO	BEGIN
	CALL	DECOD
	CLRF	PORTB
	BCF	FLAGS,KEYFL1
CON3	CALL	KEYPRESS
	BTFSC	FLAGS,KEYFL
	GOTO	CON4		
	DECFSZ	SCANCNT,1
	GOTO	CON3
	GOTO	BEGIN
CON4	MOVLW	20h
	MOVWF	SCANCNT
	MOVLW	0FFh
	MOVWF	KEYTMR
	GOTO	CON3
;        movlw   1h              ; ��� ������ ����থ�
 ;       movwf   Protdelay1      ;
  ;      clrf    Protdelay2      ;
   ;     bsf     PORT_A,RED_LED
    ;    call    Delay
     ;   bcf     PORT_A,RED_LED
      ;  bsf     PORT_A,RELE
       ; call    Delay
;        bcf     PORT_A,RELE
;RESLEEP
  ;      movlw   EE_Nkey         ;����� ����� ����
;        movwf   EEADR           ;
 ;       call    ReadEEPROM      ;
  ;      movfw   EEDATA          ;
   ;     movwf   Nkey            ;� Nkey ����� ����
    ;    clrf    Countkey
     ;   clrf    Keyf
;;
  ;      movfw   PORT_B          ;�p����� ��p� B
   ;     bcf     INTCON,RBIF     ;������ 䫠� ��.
    ;    bsf     INTCON,RBIE     ;ࠧ���� ���� ��.
;NO_INT
;        call    VerDoor
 ;       bsf     PORT_A,RED_LED
  ;      bcf     PORT_A,RED_LED
   ;     sleep
    ;    movfw   STATUS
     ;   andlw   B'11000'        ; �஢�ઠ �� ��室 �� SLEEP �� WDT
      ;  bz      NO_INT
       ; bcf     INTCON,RBIE     ;������� ���� ��.
;
;        clrf    TMR0
 ;       bcf     INTCON,RTIF
;NEW_KEY
 ;       btfsc   Savef,0
  ;        clrf    TMR0
   ;     btfsc   INTCON,RTIF
    ;      goto    RESLEEP
     ;   call    ScanKey
      ;  bz      NEW_KEY
;
;        clrf    TMR0
 ;       btfsc   Savef,0
  ;        call    LedsSavePress  ; �᫨ ������
   ;     btfss   Savef,0
    ;      call    LedsNormPress  ; �᫨ �� ������
     ;   movfw   Keyreg1
      ;  movwf   Prekey
;LOOP
 ;       btfsc   Savef,0
  ;        clrf    TMR0
   ;     btfsc   INTCON,RTIF
    ;      goto    RESLEEP
     ;   call    ScanKey
      ;  bnz     LOOP
;
;        btfsc   Savef,0
 ;         call    LedsSaveNoPress  ; �᫨ ������
  ;      btfss   Savef,0
   ;       call    LedsNormNoPress  ; �᫨ �� ������
;
;        movfw   Prekey
 ;       xorlw   0E1h
  ;      bz      MODE             ; ���室 �� ��� MODE
   ;     movfw   Prekey
    ;    xorlw   0D1h
     ;   bz      OPENDOOR
;
;        btfss   Savef,0
 ;         goto    NO_SAVE          ; ���室 �᫨ ��� �����
;SAVE
 ;       movfw   Prekey
  ;      movwf   EEDATA
   ;     incf    Nkey,w
     ;   movwf   EEADR
    ;    call    WriteEEPROM
 ;       incf    Nkey,f
  ;      goto    NEW_KEY
;NO_SAVE
 ;       incf    Countkey,w
  ;      movwf   EEADR
   ;     call    ReadEEPROM
    ;    movfw   Prekey
     ;   subwf   EEDATA,w
      ;  skpz
       ;   bsf     Keyf,0         ; ��⠭����� ���,�᫨ ����. ��.
        ;incf    Countkey,f
;        decfsz  Nkey,f
 ;         goto    NEW_KEY        ; ���室,�᫨ �� ���. ��.
  ;      btfsc   Keyf,0
   ;       goto    PASS_ER
;PASS_OK
;        call    PasswordOk
;        goto    PASS_END
;PASS_ER
;        call    PasswordErr
;PASS_END
;        goto    RESLEEP
;MODE
 ;       btfsc   Savef,0
  ;      goto    MODE_OFF
;MODE_ON
 ;       bsf     Savef,0         ; ������� ������
  ;      call    LedsSaveNoPress
   ;     clrf    Nkey
    ;    goto    MODE_END
;MODE_OFF
 ;       bcf     Savef,0         ; �몫���� ������
  ;      call    LedsNormNoPress
   ;     movfw   Nkey
    ;    movwf   EEDATA
     ;   movlw   EE_Nkey
      ;  movwf   EEADR
       ; call    WriteEEPROM
;MODE_END
 ;       goto    NEW_KEY
;OPENDOOR
 ;       call    PasswordOk
  ;      goto    RESLEEP
;;
;   � � � � � � � � � � � �
;
; �� ����p��p���� ࠧ�蠥� ������
;
;WriteEn
;        bsf     EECON1,WREN
;        return

INIP    CLRWDT
	CLRF	PORTA
        CLRF    PORTB
        CLRF	INTCON
        BSF     STATUS,5               ;��p��� ���� 1
        MOVLW   B'00010000'
        MOVWF   TRISA
        MOVLW   B'11110000'
        MOVWF   TRISB
        BSF     OPTN,0         ;����⥫�
        BSF     OPTN,1         ;����⥫�
        BSF     OPTN,2         ;����⥫�
        BCF     OPTN,3         ;����⥫� � RTCC
        BCF     OPTN,5         ;ᨣ��� �� ����� �������
        BCF     OPTN,7         ;p��p���� �������騥 p�����p�
        BCF	STATUS,5       ;��p��� ��p����� 0
	CLRWDT
	RETURN
;
; �� ����p��p���� �����뢠�� � EEPROM
;
;WriteEEPROM
;        clrwdt
;        MPAGE   1
;        call    WriteEn
;        movlw   055h
;        movwf   EECON2
;        movlw   0AAh
;        movwf   EECON2
;        bsf     EECON1,WR
;_write1
;        btfss   EECON1,EEIF
;        goto    _write1
;        bcf     EECON1,WREN
;        bcf     EECON1,EEIF
;        MPAGE   0
;        return
;
; �� ����p��p���� ���뢠�� �� EEPROM
;
;ReadEEPROM
;        MPAGE   1
;        bsf     EECON1,RD
;        MPAGE   0
;        return
;
; �� ����p��p���� �ࠢ���� ᢥ⮤�����
;
;LedsSaveNoPress
;        bsf     PORT_A,RED_LED
 ;       return
;LedsNormNoPress
;        bcf     PORT_A,RED_LED
;        return
;LedsSavePress
;        bcf     PORT_A,RED_LED
;        return
;LedsNormPress
;        bsf     PORT_A,RED_LED
;        return
; �� ����p��p���� ��뢠���� �� �ࠢ.����
;
;PasswordOk
;        bcf     PORT_A,RELE
;        bsf     PORT_A,TRANZ
 ;       call    Delay
  ;      call    Delay
  ;      movlw   1h              ; ��� ������ ����থ�
 ;       movwf   Protdelay1      ;
 ;       clrf    Protdelay2      ;
 ;       bcf     PORT_A,TRANZ
 ;       bsf     Doorf,ZAMOK
  ;      return
;
; �� ����p��p���� ��뢠���� �� ���ࠢ.����
;
;PasswordErr
;        bsf     PORT_A,RED_LED
 ;       clrc
  ;      rlf     Protdelay1,f
  ;      rlf     Protdelay2,f
;
   ;     movfw   Protdelay2
    ;    movwf   Delayreg2
;_passer1
 ;       movfw   Protdelay1
 ;       movwf   Delayreg1
;_passer2
 ;       call    Delay
 ;       decfsz  Delayreg1,f    ;㬥����� �� 1
 ;       goto    _passer2       ;� ��p�室��� ��p�⭮, ���� �� �⠭�� = 0
 ;       tstf    Delayreg2,f
 ;       bz      _passer3
 ;       decf    Delayreg2,f    ;㬥����� �� 1
  ;      goto    _passer1       ;� ��p�室��� ��p�⭮, ���� �� �⠭�� = 0
;
;_passer3
 ;       bcf     PORT_A,RED_LED
  ;      return
;
; �� ����p��p���� ��뢠���� ��� �஢�ન ����
;
;VerDoor
;        clrwdt
;        btfss   PORT_A,DOORD
;          goto    _door_close
;_door_open                     ; ����� �����
;        btfss   Doorf,ZAMOK
;          goto    _door_vzlom
;        goto    DoorUpdate
;_door_vzlom
;        bsf     PORT_A.ALERT  ; ����� !!!!
;        call    Delay
;        bcf     PORT_A,ALERT
;        return
;_door_close                    ; ����� ������
;        btfss   Doorf,DVER
;          return               ; ����� �뫠 ������
;        bsf     PORT_A,RELE
;        call    Delay
;        bsf     PORT_A,TRANZ
;        call    Delay
;        call    Delay
;        bcf     PORT_A,TRANZ
;        bcf     PORT_A,RELE
;        bcf     Doorf,ZAMOK
;DoorUpdate
;        movfw   PORT_A
;        andlw   1h
;        movwf   Doorf
;        return
;
; �� ����p��p���� - ����প�
;
TM      MOVLW   0FFh
        MOVWF	TIME
TMCON	CLRWDT
	DECFSZ	TIME,1
	GOTO	TMCON
	RETURN

TMLONG  MOVLW   0Fh
        MOVWF	TIME1
TMLCON	CALL	TM
	DECFSZ	TIME1,1
	GOTO	TMLCON
	RETURN

KEYPRESS
	MOVFW	PORTB
	MOVWF	SCAN
	ANDLW	B'11110000'
	XORLW	B'11110000'
	BZ	NOTP
	BSF	FLAGS,KEYFL
	RETURN
NOTP	BCF	FLAGS,KEYFL
	RETURN

DECOD	MOVLW	B'00001110'
	MOVWF	PORTA
	CALL	TMLONG
	CLRF	PORTA
	RETURN









;        clrf    tmpReg
;_delay1
;        clrwdt
;        decfsz  tmpReg,1       ;㬥����� �� 1
;        goto    _delay1        ;� ��p�室��� ��p�⭮, ���� �� �⠭�� = 0
;        decfsz  Keyreg2
;        goto    _delay2
;        clrwdt
;        return
;
;
END

