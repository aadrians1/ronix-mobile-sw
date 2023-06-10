MOVFF   MACRO   KUDA,OTKUDA
        MOVFW   OTKUDA
        MOVWF   KUDA
        ENDM

STRANICA1       MACRO
                BCF     STATUS,5
                BCF     STATUS,6
                ENDM
STRANICA2       MACRO
                BSF     STATUS,5
                BCF     STATUS,6
                ENDM
STRANICA3       MACRO
                BCF     STATUS,5
                BSF     STATUS,6
                ENDM
STRANICA4       MACRO
                BSF     STATUS,5
                BSF     STATUS,6
                ENDM
OUT_B   MACRO   FIL
        MOVFW   FIL
        MOVWF   PORTB
        ENDM

MOVLF   MACRO   KUDA,CHTO
        MOVLW   CHTO
        MOVWF   KUDA
        ENDM

CORECT  MACRO   HIGH_BYTE,LOW_BYTE
        SWAPF   LOW_BYTE,W
        ANDLW   H'0F'
        MOVWF   LOW_BYTE
        SWAPF   HIGH_BYTE,W
        ANDLW   H'F0'
        ADDWF   LOW_BYTE,F
        SWAPF   HIGH_BYTE,W
        ANDLW   H'0F'
        MOVWF   HIGH_BYTE
        ENDM
