        LIST    P=16C57         ;closest PIC chip (has 2K)

        INCLUDE "SXDEFS.INC"    ;macro definitions for new instructions
        INCLUDE "MAKROS.INC"
DEVICE  EQU     PINS28+TURBO+OPTIONX+STACKX+BANKS8+PAGES4+OSC4MHZ

#DEFINE GENERAL_BANK  TBANK  0
#DEFINE MATH_BANK     TBANK  1
#DEFINE SPI_BANK      TBANK  2
#DEFINE LCD_BANK      TBANK  3

;REGISTR DEFINITION
;BANK1 - GENERAL BANK
FLAGI           EQU     08H
DES_DNEI        EQU     09H
EDIN_DNEI       EQU     0AH
TEMP            EQU     0BH
TMPLCD1         EQU     0CH
MINUTES         EQU     0DH
HOURS           EQU     0EH
DAY             EQU     0FH
DATE            EQU     10H
MOUNTH          EQU     11H
D_MINUTES       EQU     12H
D_HOURS         EQU     13H
TEMP_DAY        EQU     14H
D_DATE          EQU     15H
D_MOUNTH        EQU     16H
TEMP_I2C        EQU     17H
KEYFLAG         EQU     18H
STAT_LCD        EQU     19H
KEYS            EQU     1AH
REG_LOW_LCD     EQU     1BH
REG_HIGH_LCD    EQU     1CH
DDRAM           EQU     1DH
REZIM           EQU     1EH
TIP             EQU     1FH

;BANK1 MATH_BANK
TEMP_MATH_HIGH  EQU    10H
TEMP_MATH_LOW   EQU    11H
TEMP_CELCII     EQU    12H
T_NAR_LCD       EQU    13H
T_OBR_LCD       EQU    14H
T_OBR_RAS_LCD   EQU    15H
ZNAK            EQU    16H
ZNAK_NAR        EQU    17H
ZNAK_OBR        EQU    18H
LOW_CONST       EQU    19H
D_TEMP_CELCII   EQU    1AH
DT_OBR_RAS_LCD  EQU    1BH
HIGH_OBR_RAS    EQU    1DH
LOW_OBR_RAS     EQU    1EH
HIGH_CONST      EQU    1CH
WR_CONST        EQU    1FH
TEMPER_HIGH     EQU    1FH

;BANK2 SPI_BANK
T_NAR_HIGH      EQU     10H
T_OBR_HIGH      EQU     11H
T_VIH_HIGH      EQU     12H
T_NAR_LOW       EQU     13H
T_OBR_LOW       EQU     14H
T_VIH_LOW       EQU     15H
CHET_SPI        EQU     16H
TEMP_SPI        EQU     17H
TEMP2_SPI       EQU     18H
INP_DATA_SPI    EQU     19H
MATH_HIGH       EQU     1AH
MATH_LOW        EQU     1BH
MATH_HIGH8      EQU     1CH
MATH_LOW8       EQU     1DH
MATH_HIGH16     EQU     1EH
MATH_LOW16      EQU     1FH
HIGH_CONTROL    EQU     16H
LOW_CONTROL     EQU     17H

;LCD_BANK
CHETCHIK1       EQU     10H
CHETCHIK2       EQU     11H
CHETCHIK3       EQU     12H
HIGH_5_MIN      EQU     13H
LOW_5_MIN       EQU     14H
HIGH_20_SEK     EQU     15H
LOW_20_SEK      EQU     16H
;
DROBNOE            EQU  17H
DROB_OBR_LCD       EQU  18H
DROB_NAR_LCD       EQU  19H
DROB_VIH_LCD       EQU  1AH
ZNAK_VIH           EQU  1BH
T_VIH_LCD          EQU  1CH
TEMP_DEN           EQU  1DH


;CONSTANT DEFINITION
SET_PRERIV  EQU     B'00000110'
T_NARUZ     EQU     B'00001100'
T_OBRAT     EQU     B'00011100'
T_VIHOD     EQU     B'00101100'

;PIN DEFINITION
;
KEY1    EQU     2;PORTA
KEY2    EQU     1;PORTA
KEY3    EQU     0;PORTA
KEY4    EQU     3;PORTA
;
KEYPRESSED    EQU     0;FLAGi
IZMENENIE     EQU     1;FLAGi
LED           EQU     2;FLAGi
MIN_5         EQU     3;FLAGi
SMECHENIE     EQU     4;FLAGi
VHOD_V_REZIM  EQU     5;FLAGI
DNI           EQU     6;FLAGI
;
SPI_OUT EQU     0;PORTB
SPI_IN  EQU     1;PORTB
SPI_CS  EQU     2;PORTB
SPI_EOC EQU     3;PORTB
SPI_CLK EQU     4;PORTB

LED_OUT         EQU     0
RS              EQU     1
R_W             EQU     2
E               EQU     3
SDA_I2C         EQU     6
CLK_I2C         EQU     5

        ORG     0H
        CLRWDT
        GENERAL_BANK
        BTFSC   FLAGI,VHOD_V_REZIM
        CALL    VID_20_SEK
        MOVFW   PORTA
        ANDLW   H'0F'
        MOVWF   KEYFLAG

;       ISKLUCHENIE DREBEZGA
        BCF     STATUS,Z
        MOVFW   KEYS
        SUBWF   KEYFLAG,W
        BTFSC   STATUS,Z
        RETI
        MOVFW   KEYFLAG
        MOVWF   KEYS
        BSF     FLAGI,KEYPRESSED
;       ESLI NE NAZATA NI ODNA KLAVISHA
        BCF     STATUS,Z
        MOVLW   H'0F'
        SUBWF   KEYFLAG,W
        BTFSC   STATUS,Z
        BCF     FLAGI,KEYPRESSED
        RETI

        ORG     0015H
VID_20_SEK
         CLRF   RTCC
         LCD_BANK
         DECFSZ LOW_20_SEK,F
         GOTO LOOPV1
         DECFSZ HIGH_20_SEK,F
         GOTO LOOPV1
         GENERAL_BANK
         BCF    FLAGI,VHOD_V_REZIM
         BSF    FLAGI,KEYPRESSED
         MOVLF  REZIM,H'01'
LOOPV1   GENERAL_BANK
         RETP


ZADERZKA
         GENERAL_BANK
         MOVLF  TEMP,D'20'
         MOVLF  TEMP_I2C,H'FF'
PPP      NOP
         DECFSZ TEMP_I2C,F
         GOTO   PPP
         DECFSZ TEMP,F
         GOTO   PPP
         RETP
SUB_KEY1
         GENERAL_BANK
         CLRF   RTCC
         BTFSS  FLAGI,KEYPRESSED
         RETP
         BTFSC  KEYFLAG,KEY1
         RETP
         BCF    STATUS,C
         RLF    REZIM,F
         MOVLW  H'01'
         BTFSC  REZIM,4
         MOVWF  REZIM
         BCF    FLAGI,KEYPRESSED
         RETP
SUB_KEY4
         GENERAL_BANK
         CLRF   RTCC
         BTFSS  FLAGI,KEYPRESSED
         RETP
         BTFSC  KEYFLAG,KEY4
         RETP
         BCF    FLAGI,KEYPRESSED
         BTFSS  REZIM,7
         GOTO   SBROS
         BCF    REZIM,7
         RETP
SBROS
         BSF    REZIM,7
         RETP
SUB_KEY2
         CLRF   RTCC
         BTFSS  FLAGI,KEYPRESSED
         RETP
         BTFSC  KEYFLAG,KEY2
         RETP
         BCF    STATUS,C
         RLF    REG_LOW_LCD,F
         RLF    REG_HIGH_LCD,F
         MOVLW  H'01'
         BTFSC  STATUS,C
         MOVWF  REG_LOW_LCD
         INCF   DDRAM,F
         MOVLW  H'48'
         XORWF  DDRAM,W
         BTFSC  STATUS,Z
         CLRF   DDRAM
         MOVLW  H'40'
         BTFSC  DDRAM,3
         ADDWF  DDRAM,F
         BCF    DDRAM,3
         BCF    FLAGI,KEYPRESSED
         RETP
SUB_KEY3
         CLRF   RTCC
         BTFSS  FLAGI,KEYPRESSED
         RETP
         BTFSC  KEYFLAG,KEY3
         RETP
         BSF    STAT_LCD,KEY3
         BCF    FLAGI,KEYPRESSED
         RETP

PROVER_PRAZD
         MOVLW  H'0A'
         XORWF  EDIN_DNEI,W
         BTFSC  STATUS,Z
         CLRF   EDIN_DNEI

         MOVLW  H'0A'
         XORWF  DES_DNEI,W
         BTFSC  STATUS,Z
         CLRF   DES_DNEI

         MOVLW  H'01'
         BTFSC  TIP,3
         MOVWF  TIP
         BTFSS  REG_LOW_LCD,4
         RETP
         MOVLF  REG_LOW_LCD,H'01'
         CLRF   REG_HIGH_LCD
         CLRF   DDRAM
         RETP

PRAZDNIK_LCD
           STRANICA4
           CALL    CURSOR_HOME
           BTFSC   TIP,0
           MOVLW   'Z'
           BTFSC   TIP,1
           MOVLW   'W'
           BTFSC   TIP,2
           MOVLW   'H'
           STRANICA4
           CALL      ZAPIC_CHAR
           MOVLW   ' '
           STRANICA4
           CALL      ZAPIC_CHAR

           MOVFW  DES_DNEI
           STRANICA4
           CALL   SIMVOL_LCD

           MOVFW  EDIN_DNEI
           STRANICA4
           CALL   SIMVOL_LCD
           RETP

TERM_LCD
           STRANICA4
           CALL    CURSOR_HOME
;DISPLAY HOURS
           MOVFW  D_HOURS    ;Position 0
           STRANICA4
           CALL   SIMVOL_LCD
           MOVFW  HOURS      ;Position 1
           STRANICA4
           CALL   SIMVOL_LCD
           MOVLW  'h'        ;Position 2
           STRANICA4
           CALL   ZAPIC_CHAR
           MOVLW  ' '        ;Position 3
           STRANICA4
           CALL   ZAPIC_CHAR
;DISPLAY DAYS
           MOVLW  H'0'       ;Position 4
           STRANICA4
           CALL   SIMVOL_LCD
           MOVFW  DAY        ;Position 5
           STRANICA4
           CALL   SIMVOL_LCD
;DISPLAY T_VVODIMOE
           MOVLW  ' '        ;Position 6
           STRANICA4
           CALL   ZAPIC_CHAR
           MOVLW  '+'        ;Position 7
           STRANICA4
           CALL   ZAPIC_CHAR
           STRANICA1
           CALL      INDIK_2x8
           MATH_BANK
           MOVFW  DT_OBR_RAS_LCD
           GENERAL_BANK
           STRANICA4
           CALL   SIMVOL_LCD
;+++++++++++++++++++++++++++++++++++++++++
           MATH_BANK
           MOVFW  T_OBR_RAS_LCD
           GENERAL_BANK
           STRANICA4
           CALL   SIMVOL_LCD
;DISPLAY T_NARUZNOE
           MOVLW  ' '
           STRANICA4
           CALL   ZAPIC_CHAR

           MATH_BANK
           MOVFW  ZNAK_NAR
           GENERAL_BANK
           STRANICA4
           CALL   ZAPIC_CHAR
;
           MATH_BANK
           MOVFW  T_NAR_LCD
           GENERAL_BANK
           STRANICA4
           CALL   OUT_LCD
           MOVLW  H'A1'
           STRANICA4
           CALL   ZAPIC_CHAR
           RETP

           BSF     FLAGI,IZMENENIE
PRIB_DT_OBR
           MATH_BANK
           INCF   DT_OBR_RAS_LCD,F
           GENERAL_BANK
           BSF     FLAGI,IZMENENIE
           RETP
PRIB_T_OBR
           MATH_BANK
           INCF   T_OBR_RAS_LCD,F
           GENERAL_BANK
           BSF     FLAGI,IZMENENIE
           RETP
CLOCK_CORRECT
           STRANICA4
           GOTO  CLOCK_COR1

VOZV_CLK_COR
           RETP

INDIK_2x8
           MOVLW  H'40'
           STRANICA4
           CALL   SET_DDRAM
           RETP

SVERKA_TAIMERA
        GOTO  NULI
VOZV_NULI
        BTFSC  TIP,0
        RETP
        LCD_BANK
        MOVFW   TEMP_DEN; VREMENNO VMESTO DAY
        GENERAL_BANK
        XORWF   TEMP_DAY,W
        BTFSS   STATUS,Z
        GOTO    LOM
        MOVLW  H'03'
        BTFSC  TIP,1
        MOVWF  DAY
        MOVLW  H'06'
        BTFSC  TIP,2
        MOVWF  DAY
        RETP
LOM     STRANICA2
        CALL    CORRECT_TEMP_DAY
        MOVLW  H'03'
        BTFSC  TIP,1
        MOVWF  DAY
        MOVLW  H'06'
        BTFSC  TIP,2
        MOVWF  DAY
        RETP


        ORG     0105H
NACHALO
        CLRF    FLAGI
	STRANICA2
	CALL	LED_POSTANOVKA
        CLRF    STAT_LCD
        MOVLF   REZIM,H'01'
        MOVLF   KEYS,H'0F'
        MOVLF   KEYFLAG,H'0F'
        MOVLW   SET_PRERIV
        OPTION
;
        MOVLW   B'00000001'
        TRIS    PORTC   ;       PORTC NA VIVOD
        CLRF    PORTC   ;       OCHISTKA VIHODOV NA '0'
        MOVLW   B'11111111'
        TRIS    PORTB   ;       PORTB NA VIVOD
        CLRF    PORTB   ;       OCHISTKA VIHODOV NA '0'
        MOVLW   B'00001111'
        TRIS    PORTA   ;       PORTA NA VIVOD
        CLRF    PORTA   ;       OCHISTKA VIHODOV NA '0'
        MODE    H'0E'
        MOVLW   B'11110000'
        TRIS    PORTA
        MODE    H'0F'
        STRANICA4
        GOTO    INIT_LCD
VOZV_LCD
        TBANK  0
LALA
        SPI_BANK
        STRANICA2
        GOTO    SPI_MODULE
        GENERAL_BANK
VOZV_SPI
           STRANICA3
           GOTO   CLOCK_READ
VOZV_RD_CLOCK
           TBANK  0
           STRANICA4
           CALL    CURSOR_OFF
           STRANICA4
           CALL    CURSOR_HOME
           CALL    SUB_KEY4
           BTFSC   REZIM,7
           GOTO    VSE_DATCHIKI
;DISPLAY HOURS
           MOVFW  D_HOURS       ;Position 0
           STRANICA4
           CALL   SIMVOL_LCD
           MOVFW  HOURS         ;Position 1
           STRANICA4
           CALL   SIMVOL_LCD
           MOVLW  ':'           ;Position 2
           STRANICA4
           CALL   ZAPIC_CHAR
;DISPLAY MINUTES
           MOVFW  D_MINUTES     ;Position 3
           STRANICA4
           CALL   SIMVOL_LCD
           MOVFW  MINUTES       ;Position 4
           STRANICA4
           CALL   SIMVOL_LCD
           MOVLW  ' '           ;Position 5
           STRANICA4
           CALL   ZAPIC_CHAR

;DISPLAY T_NARUZNOE
           MATH_BANK
           MOVFW  ZNAK_NAR      ;Position 6
           GENERAL_BANK
           STRANICA4
           CALL   ZAPIC_CHAR
           STRANICA2
           GOTO    NAR_TEMP_LCD  ;Position 7,8
VOZV_TEMP_LCD
           MOVLW  H'A1'
           STRANICA4
           CALL   ZAPIC_CHAR
;DISPLAY T_OBRATNOE
           MATH_BANK
           MOVFW  ZNAK_OBR
           GENERAL_BANK
           STRANICA4
           CALL   ZAPIC_CHAR
           MATH_BANK
           MOVFW  T_OBR_LCD
           GENERAL_BANK
           STRANICA4
           CALL   OUT_LCD
           GENERAL_BANK
           MOVLW  ' '
           STRANICA4
           CALL   ZAPIC_CHAR
           MOVLW  ' '
           BTFSS  TIP,0
           MOVLW  'T'
           STRANICA4
           CALL   ZAPIC_CHAR
           MOVLW  ' '
           STRANICA4
           CALL   ZAPIC_CHAR

           CALL    SVERKA_TAIMERA
           STRANICA2
           GOTO   CONTROL_TEMPER
VOZV_SVERKA
           CALL   SUB_KEY1
           BTFSC  REZIM,1
           GOTO   TERM_CORRECT
           BTFSC  REZIM,2
           GOTO   PRAZDNIKI
           BTFSC  REZIM,3
           CALL   CLOCK_CORRECT
           GOTO   LALA

        RETURN

TERM_CORRECT
           MOVLF  D_HOURS,H'00'
           MOVLF  HOURS,H'00'
           MOVLF  DAY,H'01'
           MOVLF  REG_LOW_LCD,H'02'
           CLRF   REG_HIGH_LCD
           STRANICA4
           CALL    LCD_CLEAR
           STRANICA4
           CALL    CURSOR_ON
           MOVLF   DDRAM,H'01'
           MATH_BANK
           BCF     FLAGI,IZMENENIE
           GENERAL_BANK
LOOPT1
           LCD_BANK
           MOVLF    HIGH_20_SEK,H'0A'
           CLRF     LOW_20_SEK
           GENERAL_BANK
           BSF    FLAGI,VHOD_V_REZIM
           STRANICA3
           CALL   M24LC16_READ
           STRANICA4
           CALL   VICH_OBR_FAKT
           BTFSS   REG_HIGH_LCD,2
           GOTO    LEVA
           CLRF   REG_HIGH_LCD
           MOVLF  REG_LOW_LCD,H'02'
           MOVLF  DDRAM,H'01'
LEVA       CALL   TERM_LCD
           MOVFW  DDRAM
           STRANICA4
           CALL   SET_DDRAM
           STRANICA4
           CALL   CURSOR_ON
CIKL1      BTFSS  FLAGI,KEYPRESSED
           GOTO   CIKL1
           STRANICA4
           CALL   CURSOR_OFF
           CALL   SUB_KEY1
           BTFSS  REZIM,1
           GOTO   LALA
           CALL   SUB_KEY2
           CALL   SUB_KEY3
           BTFSS  STAT_LCD,KEY3
           GOTO   LOOPT1
           BCF    STAT_LCD,KEY3
;           BTFSC  REG_LOW_LCD,0
 ;          INCF   D_HOURS,F

           BTFSC  REG_LOW_LCD,1
           INCF   HOURS,F
           ;SIMVOL 'h'        2
           ;PROBEL            3
           ;BTFSC  REG_LOW_LCD,4
           ;INCF   D_DAY,F
           BTFSC  REG_LOW_LCD,5
           INCF   DAY,F
           ;PROBEL            6
           ;ZNAK '+'          7
           BTFSC  REG_HIGH_LCD,0
           CALL   PRIB_DT_OBR
           BTFSC  REG_HIGH_LCD,1
           CALL   PRIB_T_OBR
           STRANICA4
           GOTO   PROV_IZMEN
VOZV_IZMEN
           BTFSS  FLAGI,IZMENENIE
           GOTO   LOOPT1
           STRANICA2
           CALL         VICH_CONST
           MATH_BANK
           MOVFF        WR_CONST,HIGH_CONST
           GENERAL_BANK
           BCF          FLAGI,SMECHENIE
           STRANICA3
           CALL         M24LC16_WRITE
           CALL         ZADERZKA
           MATH_BANK
           MOVFF        WR_CONST,LOW_CONST
           GENERAL_BANK
           BSF          FLAGI,SMECHENIE
           STRANICA3
           CALL         M24LC16_WRITE
           GENERAL_BANK
           CALL    ZADERZKA
           GOTO   LOOPT1
;===========================================
VSE_DATCHIKI
             LCD_BANK
             MOVLF    HIGH_20_SEK,H'0A'
             CLRF     LOW_20_SEK
             GENERAL_BANK
             BSF    FLAGI,VHOD_V_REZIM
             STRANICA4
             GOTO      DATCHIKI_LCD
;===========================================
PRAZDNIKI
            STRANICA4
            GOTO      PRAZDNIK_CORRECT
VOZV_PRAZD  GOTO      LALA
;===========================================
NULI
     MOVFW      EDIN_DNEI
     ANDLW      H'0F'
     MOVWF      TEMP
     SWAPF      DES_DNEI,W
     ANDLW      H'F0'
     ADDWF      TEMP,F
     MOVLW      H'00'
     XORWF      TEMP,W
     BTFSS      STATUS,Z
     GOTO       VOZV_NULI
     MOVLF      TIP,H'01'
     GOTO       VOZV_NULI

TIMER_ON
     MOVLF   REZIM,H'01'
     GOTO    LALA
;========== PAGE 2 ==========

        ORG     0200H
CORRECT_TEMP_DAY
          BCF      STATUS,C
          DECF     EDIN_DNEI,F
          BTFSC    STATUS,C
          GOTO     OPLA
          MOVLF    EDIN_DNEI,H'09'
          BCF      STATUS,C
          DECF     DES_DNEI,F
          BTFSC    STATUS,C
          GOTO     OPLA
          CLRF     EDIN_DNEI
          CLRF     DES_DNEI
          MOVLF    TIP,H'01'
OPLA      CALL     WR_PRAZD
          RETP

WR_PRAZD
           STRANICA3
           GOTO   PRAZDNIK_WRITE
SLIV
        RETP

LED_POSTANOVKA
          GENERAL_BANK
	  BTFSC FLAGI,LED
	  GOTO OK
          MOVLW   B'00000000'
          TRIS    PORTC   ;       PORTC NA VIVOD
          RETP
OK        MOVLW   B'00000001'
          TRIS    PORTC   ;       PORTC NA VVOD
          RETP

SPI_DELAY
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        RETURN

SPI_REINIT
        BSF     TEMP_SPI,SPI_CS
        OUT_B   TEMP_SPI
        CALL    SPI_DELAY
        BCF     TEMP_SPI,SPI_CS
        OUT_B   TEMP_SPI
        CALL    SPI_DELAY
        BSF     TEMP_SPI,SPI_CS
        OUT_B   TEMP_SPI
        CALL    SPI_DELAY
        BCF     TEMP_SPI,SPI_CS
        OUT_B   TEMP_SPI
        CALL    SPI_DELAY
        RETURN

SPI_START
        CLRF    TEMP_SPI
        BSF     TEMP_SPI,SPI_CS
        BSF     TEMP_SPI,SPI_CLK
        OUT_B   TEMP_SPI
        CALL    SPI_DELAY
        BCF     TEMP_SPI,SPI_CS
        BCF     TEMP_SPI,SPI_CLK
        OUT_B   TEMP_SPI
        CALL    SPI_DELAY
        RETURN

SPI_STOP
        CALL    SPI_DELAY
        BSF     TEMP_SPI,SPI_CS
        BSF     TEMP_SPI,SPI_CLK
        OUT_B   TEMP_SPI
        NOP
        CALL    SPI_DELAY
        RETURN

EOC_TEST
        NOP
SPLOOP1 BTFSS   PORTB,SPI_EOC
        GOTO    SPLOOP1
        CALL    SPI_DELAY
        RETURN

SPI_READ
        CLRF    INP_DATA_SPI
        MOVWF   TEMP2_SPI
        CLRF    TEMP_SPI

LOOP11  BTFSS   TEMP2_SPI,7
        GOTO    NOLIK_SPI_OUT
        BCF     TEMP_SPI,SPI_CLK    ;
        BSF     TEMP_SPI,SPI_OUT    ;SDA - UP
        OUT_B   TEMP_SPI
        CALL    SPI_DELAY
        BSF     TEMP_SPI,SPI_CLK    ;CLK UP
        OUT_B   TEMP_SPI
        NOP
        CALL    SPI_VVOD
        CALL    SPI_DELAY
        CALL    SPI_DELAY
        BCF     TEMP_SPI,SPI_CLK    ;CLK DOWN
        OUT_B   TEMP_SPI
        CALL    SPI_DELAY
        CALL    SPI_DELAY
        RLF     TEMP2_SPI,F
        DECFSZ  CHET_SPI,F
        GOTO    LOOP11
        MOVFW   INP_DATA_SPI
        RETW

NOLIK_SPI_OUT
        BCF     TEMP_SPI,SPI_CLK    ;
        BCF     TEMP_SPI,SPI_OUT    ;SDA - UP
        OUT_B   TEMP_SPI
        CALL    SPI_DELAY
        BSF     TEMP_SPI,SPI_CLK    ;CLK UP
        OUT_B   TEMP_SPI
        NOP
        CALL    SPI_VVOD
        CALL    SPI_DELAY
        CALL    SPI_DELAY
        BCF     TEMP_SPI,SPI_CLK    ;CLK DOWN
        OUT_B   TEMP_SPI
        CALL    SPI_DELAY
        CALL    SPI_DELAY
        RLF     TEMP2_SPI,F
        DECFSZ  CHET_SPI,F
        GOTO    LOOP11
        MOVFW   INP_DATA_SPI
        RETW
;---------------------------------------
SPI_VVOD
        RLF     INP_DATA_SPI,F
        BTFSS   PORTB,SPI_IN
        GOTO    NOLIK_SPI_IN
        BSF     INP_DATA_SPI,0
        RETURN
NOLIK_SPI_IN
        BCF     INP_DATA_SPI,0
        RETURN
;-------MATH MODULE---------------------------------
VICH_CONST
        MATH_BANK
        MOVFF D_TEMP_CELCII,DT_OBR_RAS_LCD
        MOVFF TEMP_CELCII,T_OBR_RAS_LCD
        CLRF    TEMP_MATH_LOW
        CLRF    TEMP_MATH_HIGH

        MOVFW   D_TEMP_CELCII
        MOVWF   TEMP_MATH_LOW
        RLF     TEMP_MATH_LOW,F
        RLF     TEMP_MATH_LOW,F
        RLF     TEMP_MATH_LOW,F
        MOVLW   B'11111000'
        ANDWF   TEMP_MATH_LOW,F
        MOVFW   D_TEMP_CELCII
        ADDWF   TEMP_MATH_LOW,F
        MOVFW   D_TEMP_CELCII
        ADDWF   TEMP_MATH_LOW,F
        MOVFW   TEMP_CELCII
        ADDWF   TEMP_MATH_LOW,F
        NOP
;PRIVODIM XX,X
        RLF     TEMP_MATH_LOW,F
        MOVFF   TEMP_CELCII,TEMP_MATH_LOW
        BCF     STATUS,C
        RLF     TEMP_MATH_LOW,F
        RLF     TEMP_MATH_HIGH,F
        BCF     STATUS,C
        RLF     TEMP_MATH_LOW,F
        RLF     TEMP_MATH_HIGH,F
        MOVFW   TEMP_CELCII
        BCF     STATUS,C
        ADDWF   TEMP_MATH_LOW,F
        BTFSC   STATUS,C
        INCF    TEMP_MATH_HIGH,F
        MOVLW   H'AB'
        BCF     STATUS,C
        ADDWF   TEMP_MATH_LOW,F
        BTFSC   STATUS,C
        INCF    TEMP_MATH_HIGH,F
        MOVLW   H'0A'
        ADDWF   TEMP_MATH_HIGH,F
        GENERAL_BANK
        CALL    MULTx1_2
        SPI_BANK
        MOVFW   MATH_LOW
        MATH_BANK
        BCF     STATUS,C
        ADDWF   TEMP_MATH_LOW,F
        BTFSC   STATUS,C
        INCF    TEMP_MATH_HIGH,F
        SPI_BANK
        MOVFW   MATH_HIGH
        MATH_BANK
        ADDWF   TEMP_MATH_HIGH,F
        MOVFF   LOW_CONST,TEMP_MATH_LOW
        MOVFF   HIGH_CONST,TEMP_MATH_HIGH
        GENERAL_BANK
        RETP

MULTx1_2  SPI_BANK
          BCF     STATUS,C
          MOVFF MATH_HIGH,T_NAR_HIGH
          MOVFF MATH_LOW,T_NAR_LOW
          MOVFF MATH_HIGH8,MATH_HIGH
          MOVFF MATH_LOW8,MATH_LOW
          MOVFF MATH_HIGH16,MATH_HIGH8
          MOVFF MATH_LOW16,MATH_LOW8
;DIV/8
          RRF   MATH_LOW8,F
          RRF   MATH_LOW8,F
          RRF   MATH_LOW8,F
          MOVLW B'00011111'
          ANDWF MATH_LOW8,F
          RRF   MATH_HIGH8,F
          RRF   MATH_HIGH8,F
          RRF   MATH_HIGH8,F
          RRF   MATH_HIGH8,W
          ANDLW B'11100000'
          ADDWF MATH_LOW8,F
          MOVLW B'00011111'
          ANDWF MATH_HIGH8,F
;DIV/16
        BCF     STATUS,C
        SWAPF   MATH_LOW16,W
        ANDLW   H'0F'
        MOVWF   MATH_LOW16
        SWAPF   MATH_HIGH16,W
        ANDLW   H'F0'
        ADDWF   MATH_LOW16,F
        SWAPF   MATH_HIGH16,F
        MOVLW   H'0F'
        ANDWF   MATH_HIGH16,F
;DIV/8 ADD DIV/16
        BCF     STATUS,C
        MOVFW   MATH_LOW8
        ADDWF   MATH_LOW16,F
        BTFSC   STATUS,C
        INCF    MATH_HIGH16,F
        MOVFW   MATH_HIGH8
        ADDWF   MATH_HIGH16,F
;DANNIE + DIV/8 + DIV/16
        BCF     STATUS,C
        MOVFW   MATH_LOW16
        ADDWF   MATH_LOW,F
        BTFSC   STATUS,C
        INCF    MATH_HIGH,F
        MOVFW   MATH_HIGH16
        ADDWF   MATH_HIGH,F
        GENERAL_BANK
        RETP


        ORG     0302H
NAR_TEMP_LCD
           MATH_BANK
           SWAPF  T_NAR_LCD,W     ;Position 7
           GENERAL_BANK
           STRANICA4
           CALL   SIMVOL_LCD
           STRANICA1
           CALL      INDIK_2x8
           MATH_BANK
           MOVFW  T_NAR_LCD
           GENERAL_BANK
           STRANICA4
           CALL   SIMVOL_LCD
           STRANICA1
           GOTO   VOZV_TEMP_LCD


SPI_MODULE
        MOVLW   B'11101010'
        TRIS    PORTB
        SPI_BANK
;initial
        CALL    SPI_START
        CALL    SPI_STOP
        CALL    SPI_START
        MOVLF   CHET_SPI,D'8'
        MOVLW   T_NARUZ
        CALL    SPI_READ
        MOVLF   CHET_SPI,D'8'
        MOVLW   T_NARUZ
        CALL    SPI_READ
        CALL    EOC_TEST
        CALL    SPI_DELAY
        CALL    SPI_REINIT
;rEAD T_NARUZ
        MOVLF   CHET_SPI,D'8'
        MOVLW   T_OBRAT
        CALL    SPI_READ
        MOVWF   T_NAR_HIGH
        MOVLF   CHET_SPI,D'8'
        MOVLW   B'00000000'
        CALL    SPI_READ
        MOVWF   T_NAR_LOW
        CALL    EOC_TEST
        CALL    SPI_DELAY
        CALL    SPI_REINIT
;rEAD T_OBRAT
        MOVLF   CHET_SPI,D'8'
        MOVLW   T_VIHOD
        CALL    SPI_READ
        MOVWF   T_OBR_HIGH
        MOVLF   CHET_SPI,D'8'
        MOVLW   B'00000000'
        CALL    SPI_READ
        MOVWF   T_OBR_LOW
        CALL    EOC_TEST
        CALL    SPI_DELAY
        CALL    SPI_REINIT
;READ T_VHOD
        MOVLF   CHET_SPI,D'8'
        MOVLW   T_NARUZ
        CALL    SPI_READ
        MOVWF   T_VIH_HIGH
        MOVLF   CHET_SPI,D'8'
        MOVLW   B'00000000'
        CALL    SPI_READ
        MOVWF   T_VIH_LOW
        CALL    EOC_TEST
        CALL    SPI_DELAY
        CALL    SPI_STOP
        CORECT  T_NAR_HIGH,T_NAR_LOW
        CORECT  T_OBR_HIGH,T_OBR_LOW
        CORECT  T_VIH_HIGH,T_VIH_LOW
        STRANICA4
        CALL    VICH_TEM_LCD
        GENERAL_BANK

        STRANICA1
        GOTO      VOZV_SPI

CONTROL_TEMPER
           STRANICA3
           CALL M24LC16_READ
           GENERAL_BANK
           STRANICA4
           CALL   VICH_OBR_FAKT
           MATH_BANK
           MOVFF	TEMP_MATH_HIGH,HIGH_OBR_RAS
	   MOVFF	TEMP_MATH_LOW,LOW_OBR_RAS 
	   BTFSC	FLAGI,LED
	   GOTO		SLV

;########### NIZNIJ PREDEL REAGIROVANIJA ##################################
	   MATH_BANK
           MOVFF	HIGH_OBR_RAS,TEMP_MATH_HIGH
	   MOVFF	LOW_OBR_RAS ,TEMP_MATH_LOW

	   BCF      STATUS,C
	   MOVLW    H'0A'; INTERVAL GISTEREZISA
           SUBWF    LOW_OBR_RAS,F
           BTFSS    STATUS,C		;NIZNIJ PREDEL REAGIROVANIJA
           DECF     HIGH_OBR_RAS,F
;//////////////////////////////////////////////////////////////////////////
           MOVFW    LOW_OBR_RAS
           SPI_BANK
           BCF      STATUS,C
           SUBWF    T_OBR_LOW,F
           BTFSS    STATUS,C
           DECF     T_OBR_HIGH,F
           MATH_BANK
           MOVFW    HIGH_OBR_RAS
           SPI_BANK
           BCF      STATUS,C
           SUBWF    T_OBR_HIGH,F
           BTFSS    STATUS,C
	   BSF	    FLAGI,LED
           CALL     LED_POSTANOVKA
	   GENERAL_BANK
           STRANICA1
           GOTO      VOZV_SVERKA

;########### VERHNIJ PREDEL REAGIROVANIJA ##################################
SLV	   MATH_BANK
           MOVFF	HIGH_OBR_RAS,TEMP_MATH_HIGH
	   MOVFF	LOW_OBR_RAS ,TEMP_MATH_LOW

	   BCF      STATUS,C
	   MOVLW    H'0A' ;INTERVAL GISTEREZISA	
           ADDWF    LOW_OBR_RAS,F
           BTFSC    STATUS,C		;NIZNIJ PREDEL REAGIROVANIJA
           INCF     HIGH_OBR_RAS,F
;//////////////////////////////////////////////////////////////////////////
           MOVFW    LOW_OBR_RAS
           SPI_BANK
           BCF      STATUS,C
           SUBWF    T_OBR_LOW,F
           BTFSS    STATUS,C
           DECF     T_OBR_HIGH,F
           MATH_BANK
           MOVFW    HIGH_OBR_RAS
           SPI_BANK
           BCF      STATUS,C
           SUBWF    T_OBR_HIGH,F
           BTFSC    STATUS,C
	   BCF	    FLAGI,LED
           CALL     LED_POSTANOVKA
	   GENERAL_BANK
           STRANICA1
           GOTO      VOZV_SVERKA

;========== PAGE 3 ==========

        ORG     0400H
I_MKS5
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        RETURN


;====================================

I2C_OUT
        MOVWF   TEMP_I2C
        CLRF    TEMP
        MOVLW   B'10011111'
        TRIS    PORTB
        MOVLW   D'8'
        MOVWF   TMPLCD1

LOOP6   BTFSS   TEMP_I2C,7
        GOTO    NOLIK_I2C_OUT

        BCF     TEMP,CLK_I2C    ;
        BSF     TEMP,SDA_I2C    ;SDA - UP
        OUT_B   TEMP
        CALL    I_MKS5
        BSF     TEMP,CLK_I2C    ;CLK UP
        OUT_B   TEMP
        CALL    I_MKS5
        CALL    I_MKS5

        BCF     TEMP,CLK_I2C    ;CLK DOWN
        OUT_B   TEMP
        CALL    I_MKS5

        BCF     TEMP,SDA_I2C    ;SDA DOWN
        OUT_B   TEMP
        CALL    I_MKS5
        RLF     TEMP_I2C,F
        DECFSZ  TMPLCD1,F
        GOTO    LOOP6
        RETURN

NOLIK_I2C_OUT
        BCF     TEMP,CLK_I2C    ;SDA - DOWN
        BCF     TEMP,SDA_I2C    ;SDA - DOWN
        OUT_B   TEMP
        CALL    I_MKS5

        BSF     TEMP,CLK_I2C    ;CLK UP
        OUT_B   TEMP
        CALL    I_MKS5
        CALL    I_MKS5

        BCF     TEMP,CLK_I2C    ;CLK DOWN
        OUT_B   TEMP
        CALL    I_MKS5

        BCF     TEMP,SDA_I2C    ;SDA DOWN
        OUT_B   TEMP
        CALL    I_MKS5

        RLF     TEMP_I2C,F
        DECFSZ  TMPLCD1,F
        GOTO    LOOP6
        RETURN
;===========================================================================
START_I2C
        CLRF    TEMP
        MOVLW   B'00011111'
        TRIS    PORTB
        BSF     TEMP,CLK_I2C    ;SDA - DOWN
        BSF     TEMP,SDA_I2C    ;SDA - DOWN
        OUT_B   TEMP
        CALL    I_MKS5
        BCF     TEMP,SDA_I2C
        OUT_B   TEMP
        CALL    I_MKS5
        BCF     TEMP,CLK_I2C
        OUT_B   TEMP
        CALL    I_MKS5
        RETURN
;===========================================================================
ASK_IN
        CLRF    TEMP
        MOVLW   B'11011111'
        TRIS    PORTB
        BCF     TEMP,CLK_I2C    ;CLK DOWN
        OUT_B   TEMP
        CALL    I_MKS5
        BSF     TEMP,CLK_I2C    ;CLK UP
        OUT_B   TEMP
;       CALL    I_MKS5
        CALL    I_MKS5
        BCF     TEMP,CLK_I2C    ;CLK DOWN
        OUT_B   TEMP
        CALL    I_MKS5
        RETURN
;===========================================================================
STOP_I2C
        CLRF    TEMP
        BSF     TEMP,CLK_I2C
        OUT_B   TEMP
        CALL    I_MKS5
        BSF     TEMP,SDA_I2C
        OUT_B   TEMP
        CALL    I_MKS5
        RETURN
;===========================================================================
ASK_MASTER
        CLRF    TEMP
        MOVLW   B'10011111'
        TRIS    PORTB
        BCF     TEMP,CLK_I2C    ;CLK UP
        BCF     TEMP,SDA_I2C    ;CLK UP
        OUT_B   TEMP
        CALL    I_MKS5
        BSF     TEMP,CLK_I2C    ;CLK UP
        OUT_B   TEMP
        CALL    I_MKS5
        CALL    I_MKS5
        BCF     TEMP,CLK_I2C    ;CLK DOWN
        OUT_B   TEMP
        CALL    I_MKS5
        RETURN
I2C_IN
        CLRF    TEMP
        CLRF    TEMP_I2C
        MOVLW   B'11011111'
        TRIS    PORTB
        MOVLW   D'8'
        MOVWF   TMPLCD1
LOOP7
        RLF     TEMP_I2C,F
        BCF     TEMP,CLK_I2C    ;CLK UP
        OUT_B   TEMP
        CALL    I_MKS5
        BSF     TEMP,CLK_I2C    ;CLK UP
        OUT_B   TEMP
        CALL    I_MKS5

        BTFSS   PORTB,SDA_I2C
        GOTO    NOLIK_I2C_IN
        BSF     TEMP_I2C,0
        CALL    I_MKS5
        BCF     TEMP,CLK_I2C    ;CLK DOWN
        OUT_B   TEMP
        CALL    I_MKS5
        DECFSZ  TMPLCD1,F
        GOTO    LOOP7
        MOVFW   TEMP_I2C
        RETW

NOLIK_I2C_IN
        BCF     TEMP_I2C,0
        CALL    I_MKS5
        BCF     TEMP,CLK_I2C    ;CLK DOWN
        OUT_B   TEMP
        CALL    I_MKS5
        DECFSZ  TMPLCD1,F
        GOTO    LOOP7
        MOVFW   TEMP_I2C
        RETW
;#########################################
; Microchip 24LC16B Module
;#########################################
M24LC16_WRITE
        GENERAL_BANK
        BCF     FLAGI,IZMENENIE
        CALL    START_I2C
        RLF     DAY,W
        ANDLW   B'00001110'
        MOVWF   TEMP
        BCF     TEMP,0
        MOVLW   H'A0'
        ADDWF   TEMP,W
        CALL    I2C_OUT ;SEND ADRESS1=DAY
        CALL    ASK_IN

        MOVFW   HOURS
        ANDLW   B'00001111'
        MOVWF   HOURS
        SWAPF   D_HOURS,W
        ANDLW   H'F0'
        ADDWF   HOURS,W
        MOVWF   TEMP
        BCF     STATUS,C
        RLF     TEMP,F
        BTFSC   FLAGI,SMECHENIE
        BSF     TEMP,0
        MOVFW   TEMP
        CALL    I2C_OUT ;SEND ADRESS2=HOURS
        CALL    ASK_MASTER

        MATH_BANK
        MOVFW   WR_CONST
        GENERAL_BANK
        CALL    I2C_OUT
        CALL    ASK_MASTER
;        CALL    ASK_IN
        CALL    STOP_I2C
        RETP

;################################
;#      random adress read
;################################

M24LC16_READ
        GENERAL_BANK
        CALL    START_I2C
        RLF     DAY,W
        ANDLW   B'00001110'
        MOVWF   TEMP
        BCF     TEMP,0
        MOVLW   H'A0'
        ADDWF   TEMP,W
        CALL    I2C_OUT ;SEND CONTOROL BYTE RW=0
        CALL    ASK_IN

        MOVFW   HOURS
        ANDLW   B'00001111'
        MOVWF   HOURS
        SWAPF   D_HOURS,W
        ANDLW   H'F0'
        ADDWF   HOURS,W
        MOVWF   TEMP
        BCF     STATUS,C
        RLF     TEMP,W
        CALL    I2C_OUT ;SEND ADRESS2=HOURS
        CALL    ASK_IN
;#######  CONTROL BYTE READ
        CALL    START_I2C
        RLF     DAY,W
        ANDLW   B'00001110'
        MOVWF   TEMP
        BSF     TEMP,0
        MOVLW   H'A0'
        ADDWF   TEMP,W
        CALL    I2C_OUT ;SEND CONTOROL BYTE RW=1
        CALL    ASK_MASTER

        CALL    I2C_IN  ; RESEIVE CONSTANTA STARSHIE RAZRJADI
        MATH_BANK
        MOVWF   HIGH_CONST
        GENERAL_BANK
        CALL    ASK_MASTER

        CALL    I2C_IN  ; RESEIVE T_OBR_RAS
        MATH_BANK
        MOVWF   LOW_CONST
        GENERAL_BANK
        CALL    STOP_I2C
        RETP

;============== CLOCK_READ  =============

        ORG     0500H
CLOCK_WRITE
        CALL    START_I2C
        MOVLW   H'D0'
        MOVWF   TEMP
        BCF     TEMP,0
        MOVFW   TEMP
        CALL    I2C_OUT ;SEND CONTOROL BYTE RW=0
        CALL    ASK_IN
;
        MOVLW   H'01'
        CALL    I2C_OUT ;SEND ADRESS=01
        CALL    ASK_MASTER
;       CALL    ASK_IN
;
;MINUTI
        SWAPF   D_MINUTES,F
        MOVFW   MINUTES
        ADDWF   D_MINUTES,W
        CALL    I2C_OUT
        CALL    ASK_MASTER
;HOURS
        SWAPF   D_HOURS,F
        MOVFW   HOURS
        ADDWF   D_HOURS,W
        CALL    I2C_OUT
        CALL    ASK_MASTER
;DAY
        MOVFW   DAY
        ANDLW   B'00000111'
        CALL    I2C_OUT
        CALL    ASK_MASTER
;DATE
        SWAPF   D_DATE,F
        MOVFW   DATE
        ADDWF   D_DATE,W
        CALL    I2C_OUT
        CALL    ASK_MASTER
;MOUNTH
        SWAPF   D_MOUNTH,F
        MOVFW   MOUNTH
        ADDWF   D_MOUNTH,W
        CALL    I2C_OUT
        CALL    ASK_MASTER
        CALL    STOP_I2C

        CALL    START_I2C
        MOVLW   H'D0'
        MOVWF   TEMP
        BCF     TEMP,0
        MOVFW   TEMP
        CALL    I2C_OUT ;SEND CONTOROL BYTE RW=0
        CALL    ASK_IN
;
        MOVLW   H'01'
        CALL    I2C_OUT ;SEND ADRESS2=0
        CALL    ASK_IN
        CALL    STOP_I2C
;
        CALL    START_I2C
        MOVLW   H'D0'
        MOVWF   TEMP
        BSF     TEMP,0  ;SEND CONTROL BYTE RW=1
        MOVFW   TEMP
        CALL    I2C_OUT
        CALL    ASK_MASTER
;        CALL    ASK_IN
;MINUTI
        CALL    I2C_IN  ; RESEIVE MINUTES
        ANDLW   B'01111111'
        MOVWF   MINUTES
        MOVWF   D_MINUTES
        SWAPF   D_MINUTES,F
        MOVLW   H'0F'
        ANDWF   D_MINUTES,F
        ANDWF   MINUTES,F
        CALL    ASK_MASTER
;HOURS
        CALL    I2C_IN  ; RESEIVE HOURS
        ANDLW   B'00111111'
        MOVWF   HOURS
        MOVWF   D_HOURS
        SWAPF   D_HOURS,F
        MOVLW   H'0F'
        ANDWF   D_HOURS,F
        ANDWF   HOURS,F
        CALL    ASK_MASTER
;DAY
        CALL    I2C_IN  ; RESEIVE DAY
        ANDLW   B'00000111'
        MOVWF   DAY
        CALL    ASK_MASTER
;DATE
        CALL    I2C_IN  ;RESEIVE DATE
        ANDLW   B'00111111'
        MOVWF   DATE
        MOVWF   D_DATE
        SWAPF   D_DATE,F
        MOVLW   H'0F'
        ANDWF   D_DATE,F
        ANDWF   DATE,F
        CALL    ASK_MASTER
;MOUNTH
        CALL    I2C_IN  ;RESEIVE MONTH
        ANDLW   B'00011111'
        MOVWF   MOUNTH
        MOVWF   D_MOUNTH
        SWAPF   D_MOUNTH,F
        MOVLW   H'0F'
        ANDWF   D_MOUNTH,F
        ANDWF   MOUNTH,F
        CALL    ASK_MASTER
        CALL    I2C_IN  ;RESEIVESLIP
        CALL    STOP_I2C
        STRANICA4
        GOTO      VOZV_WR_CLK
CLOCK_READ
        CALL    START_I2C
        MOVLW   H'D0'
        MOVWF   TEMP
        BCF     TEMP,0
        MOVFW   TEMP
        CALL    I2C_OUT ;SEND CONTOROL BYTE RW=0
        CALL    ASK_IN
;
        MOVLW   H'01'
        CALL    I2C_OUT ;SEND ADRESS2=0
        CALL    ASK_IN
        CALL    STOP_I2C
;
        CALL    START_I2C
        MOVLW   H'D0'
        MOVWF   TEMP
        BSF     TEMP,0  ;SEND CONTROL BYTE RW=1
        MOVFW   TEMP
        CALL    I2C_OUT
        CALL    ASK_MASTER
;        CALL    ASK_IN
;MINUTI
        CALL    I2C_IN  ; RESEIVE MINUTES
        ANDLW   B'01111111'
        MOVWF   MINUTES
        MOVWF   D_MINUTES
        SWAPF   D_MINUTES,F
        MOVLW   H'0F'
        ANDWF   D_MINUTES,F
        ANDWF   MINUTES,F
        CALL    ASK_MASTER
;HOURS
        CALL    I2C_IN  ; RESEIVE HOURS
        ANDLW   B'00111111'
        MOVWF   HOURS
        MOVWF   D_HOURS
        SWAPF   D_HOURS,F
        MOVLW   H'0F'
        ANDWF   D_HOURS,F
        ANDWF   HOURS,F
        CALL    ASK_MASTER
;DAY
        CALL    I2C_IN  ; RESEIVE DAY
        ANDLW   B'00000111'
        MOVWF   DAY
        LCD_BANK
        MOVWF   TEMP_DEN
        GENERAL_BANK
        CALL    ASK_MASTER
;DATE
        CALL    I2C_IN  ;RESEIVE DATE
        ANDLW   B'00111111'
        MOVWF   DATE
        MOVWF   D_DATE
        SWAPF   D_DATE,F
        MOVLW   H'0F'
        ANDWF   D_DATE,F
        ANDWF   DATE,F
        CALL    ASK_MASTER
;MOUNTH
        CALL    I2C_IN  ;RESEIVE MONTH
        ANDLW   B'00011111'
        MOVWF   MOUNTH
        MOVWF   D_MOUNTH
        SWAPF   D_MOUNTH,F
        MOVLW   H'0F'
        ANDWF   D_MOUNTH,F
        ANDWF   MOUNTH,F
;
        CALL    ASK_MASTER
        CALL    I2C_IN  ;RESEIVE YEARS

        CALL    ASK_MASTER
        CALL    I2C_IN  ;RESEIVE CONTROL

        CALL    ASK_MASTER
        CALL    I2C_IN  ;RESEIVE METKA
        MOVWF   TIP

        CALL    ASK_MASTER
        CALL    I2C_IN  ;RESEIVE
        MOVWF   EDIN_DNEI

        CALL    ASK_MASTER
        CALL    I2C_IN  ;RESEIVE
        MOVWF   DES_DNEI

        CALL    ASK_MASTER
        CALL    I2C_IN  ;RESEIVE
        MOVWF   TEMP_DAY
        CALL    STOP_I2C

        STRANICA1
        GOTO      VOZV_RD_CLOCK

PRAZDNIK_WRITE
        CALL    START_I2C
        MOVLW   H'D0'
        MOVWF   TEMP
        BCF     TEMP,0
        MOVFW   TEMP
        CALL    I2C_OUT ;SEND CONTOROL BYTE RW=0
        CALL    ASK_IN
;
        MOVLW   H'08'
        CALL    I2C_OUT ;SEND ADRESS=01
        CALL    ASK_MASTER
;       CALL    ASK_IN
;
        MOVFW   TIP
        CALL    I2C_OUT
        CALL    ASK_MASTER
;MINUTI
        MOVFW   EDIN_DNEI
        CALL    I2C_OUT
        CALL    ASK_MASTER

        MOVFW   DES_DNEI
        CALL    I2C_OUT
        CALL    ASK_MASTER

        LCD_BANK
        MOVFW   TEMP_DEN; DAY -VREMENNO
        GENERAL_BANK
        CALL    I2C_OUT
        CALL    ASK_MASTER
        CALL    STOP_I2C
        STRANICA4
        GOTO      SLIV
;PAGE4

        ORG     0600H


MKS150
        LCD_BANK
        MOVLW   D'150'
        MOVWF   CHETCHIK1
LOOP1   NOP
        DECFSZ  CHETCHIK1,F
        GOTO    LOOP1
        GENERAL_BANK
        RETURN
;-----------------------------------
; ZADERZKA 5MKS , (5 NOPOV)
MKS5
        NOP
        NOP
        NOP
        NOP
        NOP
        RETURN
;-----------------------------------
MS5     ;ZADERZKA 5 MS (D'34'=5000 NOPOV)
        LCD_BANK
        MOVLW   D'34'
        MOVWF   CHETCHIK2
LOOP2   CALL    MKS150
        LCD_BANK
        DECFSZ  CHETCHIK2,F
        GOTO    LOOP2
        GENERAL_BANK
        RETURN

;-----------------------------------
SIMVOL_LCD
       CALL     ASC_CORRECT
       CALL     ZAPIC_CHAR
       RETP

ENABLE_LCD
        CALL    MKS5 ; ZADERZKA 5 MKS
        BSF     PORTC,E
        CALL    MKS5 ; ZADERZKA 5 MKS
        BCF     PORTC,E
        CALL    MKS5 ; ZADERZKA 5 MKS
        RETURN
;
ZAPIC_KOMANDI_8
        MOVWF   TMPLCD1
        ANDLW   B'11110000'
        MOVWF   TEMP
        CALL    MS5
        BCF     TEMP,LED_OUT
        BCF     TEMP,RS
        BCF     TEMP,R_W
        MOVFW   TEMP
        MOVWF   PORTC
        CALL    ENABLE_LCD
        SWAPF   TMPLCD1,W
ZAPIC_KOMANDI_4
        ANDLW   B'11110000'
        MOVWF   TEMP
        BCF     TEMP,LED_OUT
        BCF     TEMP,RS
        BCF     TEMP,R_W
        MOVFW   TEMP
        MOVWF   PORTC
        CALL    ENABLE_LCD
        RETURN

ASC_CORRECT
        ANDLW   B'00001111'
        MOVWF   TEMP
        MOVLW   H'30'
        ADDWF   TEMP,W
        RETW

ZAPIC_CHAR

        MOVWF   TMPLCD1
        ANDLW   B'11110000'
        MOVWF   TEMP
        CALL    MS5
        BCF     TEMP,LED_OUT
        BSF     TEMP,RS
        BCF     TEMP,R_W
        MOVFW   TEMP
        MOVWF   PORTC
        CALL    ENABLE_LCD
        SWAPF   TMPLCD1,W
        ANDLW   B'11110000'
        MOVWF   TEMP
        BCF     TEMP,LED_OUT
        BSF     TEMP,RS
        BCF     TEMP,R_W
        MOVFW   TEMP
        MOVWF   PORTC
        CALL    ENABLE_LCD
        RETP
SET_DDRAM
        ANDLW   H'7F'
        MOVWF   TEMP
        MOVLW   H'80'
        ADDWF   TEMP,W
        CALL    ZAPIC_KOMANDI_8
        RETP

CURSOR_HOME
        MOVLW   B'00000010'     ;6
        CALL    ZAPIC_KOMANDI_8
        RETP
CURSOR_ON
        MOVLW   B'00001110'     ;6
        CALL    ZAPIC_KOMANDI_8
        RETP
CURSOR_OFF
        MOVLW   B'00001100'     ;6
        CALL    ZAPIC_KOMANDI_8
        RETP
OUT_LCD
        MOVWF   TEMP_I2C
        SWAPF   TEMP_I2C,W
        CALL    ASC_CORRECT
        CALL    ZAPIC_CHAR
        MOVFW   TEMP_I2C
        CALL    ASC_CORRECT
        CALL    ZAPIC_CHAR
        RETP
LCD_CLEAR
        MOVLW   B'00000001'     ;6
        CALL    ZAPIC_KOMANDI_8
;------------ DISPLAY HOME------------
        MOVLW   B'00000010'     ;6
        CALL    ZAPIC_KOMANDI_8
        RETP

KELV_TO_CEL
        MOVLF   ZNAK,'+'
        CLRF    TEMP_CELCII
        CLRF    D_TEMP_CELCII
        BCF     STATUS,C
        MOVLW   H'AB'
        SUBWF   TEMP_MATH_LOW,F
        BTFSS   STATUS,C
        DECF    TEMP_MATH_HIGH,F
        MOVLW   H'0A'
        SUBWF   TEMP_MATH_HIGH,F
        MOVFW   TEMP_MATH_HIGH
        ANDLW   H'F0'
        BCF     STATUS,Z
        XORLW   H'F0'
        BTFSS   STATUS,Z
        GOTO    MATH_LOOP
        MOVLF   ZNAK,'-'
        COMF    TEMP_MATH_HIGH,F
        COMF    TEMP_MATH_LOW,F
        INCF    TEMP_MATH_LOW,F
MATH_LOOP
        BCF     STATUS,C
        MOVLW   D'10'
        SUBWF   TEMP_MATH_LOW,F
        BTFSS   STATUS,C
        DECF    TEMP_MATH_HIGH,F
        INCF    TEMP_CELCII,F
        MOVFW   TEMP_MATH_HIGH
        ANDLW   H'F0'
        BCF     STATUS,Z
        XORLW   H'F0'
        BTFSS   STATUS,Z
        GOTO    MATH_LOOP
        DECF    TEMP_CELCII,F
        MOVLW   D'10'
        ADDWF   TEMP_MATH_LOW,W
        LCD_BANK
        MOVWF   DROBNOE
        MATH_BANK
;       DESATKI & EDINICI
        CLRF    TEMP_MATH_HIGH
        MOVFF   TEMP_MATH_LOW,TEMP_CELCII
MATH_LOOP1
        MOVLW   D'10'
        SUBWF   TEMP_MATH_LOW,F
        ADDWF   TEMP_MATH_HIGH,F
        INCF    D_TEMP_CELCII,F
        MOVFW   TEMP_MATH_LOW
        ANDLW   H'F0'
        BCF     STATUS,Z
        XORLW   H'F0'
        BTFSS   STATUS,Z
        GOTO    MATH_LOOP1
        DECF    D_TEMP_CELCII,F
        MOVLW   D'10'
        SUBWF   TEMP_MATH_HIGH,F
        MOVFW   TEMP_MATH_HIGH
        SUBWF   TEMP_CELCII,F
        RETP

VICH_TEM_LCD
        SPI_BANK
        MOVFW    T_NAR_HIGH
        MATH_BANK
        MOVWF    TEMP_MATH_HIGH
        SPI_BANK
        MOVFW    T_NAR_LOW
        MATH_BANK
        MOVWF    TEMP_MATH_LOW
        CALL     KELV_TO_CEL
        SWAPF    D_TEMP_CELCII,W
        ANDLW    H'F0'
        MOVWF    T_NAR_LCD
        MOVFW    TEMP_CELCII
        ANDLW    H'0F'
        ADDWF    T_NAR_LCD,F
        MOVFF    ZNAK_NAR,ZNAK
        LCD_BANK
        MOVFF    DROB_NAR_LCD,DROBNOE

        SPI_BANK
        MOVFW    T_OBR_HIGH
        MATH_BANK
        MOVWF    TEMP_MATH_HIGH
        SPI_BANK
        MOVFW    T_OBR_LOW
        MATH_BANK
        MOVWF    TEMP_MATH_LOW
        CALL     KELV_TO_CEL
        SWAPF    D_TEMP_CELCII,W
        ANDLW    H'F0'
        MOVWF    T_OBR_LCD
        MOVFW    TEMP_CELCII
        ANDLW    H'0F'
        ADDWF    T_OBR_LCD,F
        MOVFF    ZNAK_OBR,ZNAK
        LCD_BANK
        MOVFF    DROB_OBR_LCD,DROBNOE

        SPI_BANK
        MOVFW    T_VIH_HIGH
        MATH_BANK
        MOVWF    TEMP_MATH_HIGH
        SPI_BANK
        MOVFW    T_VIH_LOW
        MATH_BANK
        MOVWF    TEMP_MATH_LOW
        CALL     KELV_TO_CEL
        SWAPF    D_TEMP_CELCII,W
        ANDLW    H'F0'
        LCD_BANK
        MOVWF    T_VIH_LCD
        MATH_BANK
        MOVFW    TEMP_CELCII
        ANDLW    H'0F'
        LCD_BANK
        ADDWF    T_VIH_LCD,F
        MOVFF    DROB_VIH_LCD,DROBNOE
        MATH_BANK
        MOVFW    ZNAK
        LCD_BANK
        MOVWF    ZNAK_VIH
        GENERAL_BANK
        RETP

VICH_OBR_FAKT
        STRANICA2
        CALL     MULTx1_2
        SPI_BANK
        MOVFW    MATH_LOW
        MATH_BANK
        BCF     STATUS,C
        SUBWF   LOW_CONST,W
        MOVWF   TEMP_MATH_LOW
        MOVWF   LOW_OBR_RAS
        BTFSS   STATUS,C
        DECF    HIGH_CONST,F

        SPI_BANK
        MOVFW    MATH_HIGH
        MATH_BANK
        BCF     STATUS,C
        SUBWF   HIGH_CONST,W
        MOVWF   TEMP_MATH_HIGH
        MOVWF   HIGH_OBR_RAS
        CALL    KELV_TO_CEL
        MOVFW   TEMP_CELCII
        ANDLW   H'0F'
        MOVWF   T_OBR_RAS_LCD
        MOVFW    D_TEMP_CELCII
        ANDLW    H'0F'
        MOVWF    DT_OBR_RAS_LCD
        GENERAL_BANK
        RETP

        ORG     0702H
INIT_LCD

        MOVLW   B'00110000'
        CALL    ZAPIC_KOMANDI_4
;-----------------------------
        CALL    MS5 ; ZADERZKA 5 MS
        MOVLW   B'00110000'
        CALL    ZAPIC_KOMANDI_4
;-----------------------------
        CALL    MKS150 ; ZADERZKA 150 MKS
        MOVLW   B'00110000'
        CALL    ZAPIC_KOMANDI_4
;###################################################

        CALL    MS5 ; ZADERZKA 5 MS
        MOVLW   B'00100000'
        CALL    ZAPIC_KOMANDI_4

;------------ FUNCTION SET ------------
        MOVLW   B'00101000'     ;3
        CALL    ZAPIC_KOMANDI_8

;------------ DISPLAY OFF ------------
;       MOVLW   B'00001000'     ;4
;       CALL    ZAPIC_KOMANDI_8

;------------ DISPLAY ON ------------
        CALL  CURSOR_ON
;------------ MODE SET ------------
        MOVLW   B'00000110'     ;6
        CALL    ZAPIC_KOMANDI_8
;------------ CLR DISPLAY ------------
        CALL    LCD_CLEAR
        STRANICA1
        GOTO      VOZV_LCD
PROV_IZMEN
           GENERAL_BANK
           MOVLW   H'01'
           BTFSC   DAY,3
           MOVWF   DAY
           MOVLW   H'0A'
           BCF     STATUS,Z
           XORWF   HOURS,W
           BTFSS   STATUS,Z
           GOTO    LEP
           CLRF    HOURS
           INCF    D_HOURS,F
LEP        MOVFF   TEMP,HOURS
           SWAPF   D_HOURS,W
           ADDWF   TEMP,F
           MOVLW   H'24'
           BCF     STATUS,Z
           XORWF   TEMP,W
           BTFSS   STATUS,Z
           GOTO    LEP1
           CLRF    D_HOURS
           CLRF    HOURS
LEP1       MATH_BANK
           MOVLW   H'0A'
           BCF     STATUS,Z
           XORWF   DT_OBR_RAS_LCD,W
           BTFSC   STATUS,Z
           CLRF    DT_OBR_RAS_LCD
           GENERAL_BANK
           STRANICA1
           GOTO VOZV_IZMEN

CLOCK_COR1
           GENERAL_BANK
           MOVLW  H'01'
           MOVWF  REG_LOW_LCD
           CLRF   REG_HIGH_LCD
           CALL    LCD_CLEAR
           CALL    CURSOR_ON
           CLRF    DDRAM
           BTFSC  TIP,0
           GOTO   LOOPK1
           STRANICA1
           GOTO      TIMER_ON
LOOPK1
           LCD_BANK
           MOVLF    HIGH_20_SEK,H'0A'
           CLRF     LOW_20_SEK
           GENERAL_BANK
           BSF    FLAGI,VHOD_V_REZIM
           CALL    CURSOR_HOME
;DISPLAY HOURS

           MOVFW  D_HOURS       ;0
           CALL   SIMVOL_LCD
           MOVFW  HOURS         ;1
           CALL   SIMVOL_LCD
           MOVLW  ':'           ;2
           CALL   ZAPIC_CHAR
;DISPLAY MINUTES
           MOVFW  D_MINUTES     ;3
           CALL   SIMVOL_LCD
           MOVFW  MINUTES       ;4
           CALL   SIMVOL_LCD
           MOVLW  ' '           ;5
           CALL   ZAPIC_CHAR
;DISPLAY DATE
           MOVFW  D_DATE        ;6
           CALL   SIMVOL_LCD
           MOVFW  DATE          ;7
           CALL   SIMVOL_LCD
           STRANICA1
           CALL      INDIK_2x8

           MOVLW  '.'
           CALL   ZAPIC_CHAR
;DISPLAY MOUNTH
           MOVFW  D_MOUNTH
           CALL   SIMVOL_LCD
           MOVFW  MOUNTH
           CALL   SIMVOL_LCD
           MOVLW  ' '
           CALL   ZAPIC_CHAR
;DISPLAY DAY
           MOVLW  H'0'
           CALL   SIMVOL_LCD
           MOVFW  DAY
           CALL   SIMVOL_LCD
           MOVFW  DDRAM
           CALL   SET_DDRAM
           CALL   CURSOR_ON
CIKL       BTFSS  FLAGI,KEYPRESSED
           GOTO   CIKL
           CALL   CURSOR_OFF
           STRANICA1
           CALL   SUB_KEY1
           BTFSS  REZIM,3
           GOTO   OUT_CLK_CORRECT
           STRANICA1
           CALL   SUB_KEY2
           STRANICA1
           CALL   SUB_KEY3
           BTFSS  STAT_LCD,KEY3
           GOTO   LOOPK1
           BCF    STAT_LCD,KEY3
           BTFSC  REG_LOW_LCD,0
           INCF   D_HOURS,F
           BTFSC  REG_LOW_LCD,1
           INCF   HOURS,F
           BTFSC  REG_LOW_LCD,3
           INCF   D_MINUTES,F
           BTFSC  REG_LOW_LCD,4
           INCF   MINUTES,F
           BTFSC  REG_LOW_LCD,6
           INCF   D_DATE,F
           BTFSC  REG_LOW_LCD,7
           INCF   DATE,F
           BTFSC  REG_HIGH_LCD,1
           INCF   D_MOUNTH,F
           BTFSC  REG_HIGH_LCD,2
           INCF   MOUNTH,F
           BTFSC  REG_HIGH_LCD,5
           INCF   DAY,F
           STRANICA3
           GOTO   CLOCK_WRITE
VOZV_WR_CLK
           GENERAL_BANK
           GOTO   LOOPK1
OUT_CLK_CORRECT
           STRANICA1
           GOTO      VOZV_CLK_COR
;============================================
DATCHIKI_LCD
           ;DISPLAY T_NARUZNOE
           MATH_BANK
           MOVFW  ZNAK_NAR      ;0
           GENERAL_BANK
           CALL   ZAPIC_CHAR
;;
           MATH_BANK
           MOVFW  T_NAR_LCD     ;1,2
           GENERAL_BANK
           CALL   OUT_LCD
           LCD_BANK
           MOVFW  DROB_NAR_LCD   ;3
           GENERAL_BANK
           CALL   SIMVOL_LCD
           MOVLW  H'A1'          ;4
           CALL   ZAPIC_CHAR
;DISPLAY T_OBRATNOE
           MATH_BANK
           MOVFW  ZNAK_OBR       ;5
           GENERAL_BANK
           CALL   ZAPIC_CHAR
           MATH_BANK
           MOVFW  T_OBR_LCD      ;6,7
           GENERAL_BANK
           CALL   OUT_LCD
           STRANICA1
           CALL      INDIK_2x8
           LCD_BANK
           MOVFW  DROB_OBR_LCD
           GENERAL_BANK
           CALL   SIMVOL_LCD
           MOVLW  ' '
           CALL   ZAPIC_CHAR
;DISPLAY T_VIHODA
           LCD_BANK
           MOVFW  ZNAK_VIH
           GENERAL_BANK
           CALL   ZAPIC_CHAR
           LCD_BANK
           MOVFW  T_VIH_LCD
           GENERAL_BANK
           CALL   OUT_LCD
           LCD_BANK
           MOVFW  DROB_VIH_LCD
           GENERAL_BANK
           CALL   SIMVOL_LCD
           MOVLW  H'A1'
           CALL   ZAPIC_CHAR
           GENERAL_BANK
           STRANICA1
           GOTO      LALA

PRAZDNIK_CORRECT
;           MOVLF   TIP,H'01'
            MOVLF   REG_LOW_LCD,H'01'
            CLRF    REG_HIGH_LCD

;           CLRF    EDIN_DNEI
;           CLRF    DES_DNEI
           CALL    LCD_CLEAR
           CALL    CURSOR_ON
           CLRF    DDRAM
LOOPP1
           LCD_BANK
           MOVLF    HIGH_20_SEK,H'0A'
           CLRF     LOW_20_SEK
           GENERAL_BANK

           BSF    FLAGI,VHOD_V_REZIM
           STRANICA1
           CALL   PROVER_PRAZD
           STRANICA1
           CALL   PRAZDNIK_LCD
           MOVFW  DDRAM
           CALL   SET_DDRAM
           CALL   CURSOR_ON
CIKP1      BTFSS  FLAGI,KEYPRESSED
           GOTO   CIKP1
           CALL   CURSOR_OFF
           STRANICA1
           CALL   SUB_KEY1
           BTFSS  REZIM,2
           GOTO   LEON
           STRANICA1
           CALL   SUB_KEY2
           STRANICA1
           CALL   SUB_KEY3
           BTFSS  STAT_LCD,KEY3
           GOTO   LOOPP1
           BCF    STAT_LCD,KEY3

           BCF  STATUS,C
           BTFSC  REG_LOW_LCD,0
           RLF    TIP,F

           BTFSC  REG_LOW_LCD,2
           INCF   DES_DNEI,F

           BTFSC  REG_LOW_LCD,3
           INCF   EDIN_DNEI,F
           STRANICA1
           CALL   PROVER_PRAZD
           STRANICA2
           CALL   WR_PRAZD
           GOTO   LOOPP1

LEON       STRANICA1
           GOTO      VOZV_PRAZD



;===============================================
        ORG     07FFh           ;reset vector
        GOTO    NACHALO
        END
