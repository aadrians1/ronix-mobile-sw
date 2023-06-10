	LIST
; P16CXX.INC  Standard Header File, Version 2.04    Microchip Technology, Inc.
	NOLIST

; This header file defines configurations, registers, and other useful bits of
; information for the 16CXX microcontrollers.  These names are taken to match 
; the data sheets as closely as possible.  The microcontrollers included
; in this file are:

;       16C61
;       16C62
;       16C620
;       16C621
;       16C622
;       16C63
;       16C64
;       16C65
;       16C71
;       16C73
;       16C74
;       16C84


; There is one group of defines that is valid for all microcontrollers.  
; Each microcontroller in this family also has its own section of special 
; defines.  Note that the processor must be selected before this file is 
; included.  The processor may be selected the following ways:

;       1. Command line switch:
;               C:\ MPASM MYFILE.ASM /P16C71
;       2. LIST directive in the source file
;               LIST   P=16C71
;       3. Processor Type entry in the MPASM full-screen interface

;==========================================================================
;
;       Generic Definitions
;
;==========================================================================

W                            EQU     H'0000'
F                            EQU     H'0001'

;----- Register Files------------------------------------------------------

INDF                         EQU     H'0000'
TMR0                         EQU     H'0001'
PCL                          EQU     H'0002'
STATUS                       EQU     H'0003'
FSR                          EQU     H'0004'
PORTA                        EQU     H'0005'
PORTB                        EQU     H'0006'

PCLATH                       EQU     H'000A'
INTCON                       EQU     H'000B'

OPTION_REG                   EQU     H'0081'
TRISA                        EQU     H'0085'
TRISB                        EQU     H'0086'

;----- INTCON Bits (except ADC/Periph) ------------------------------------

GIE                          EQU     H'0007'
T0IE                         EQU     H'0005'
INTE                         EQU     H'0004'
RBIE                         EQU     H'0003'
T0IF                         EQU     H'0002'
INTF                         EQU     H'0001'
RBIF                         EQU     H'0000'

;----- OPTION Bits --------------------------------------------------------

NOT_RBPU                     EQU     H'0007'
INTEDG                       EQU     H'0006'
T0CS                         EQU     H'0005'
T0SE                         EQU     H'0004'
PSA                          EQU     H'0003'
PS2                          EQU     H'0002'
PS1                          EQU     H'0001'
PS0                          EQU     H'0000'

;----- STATUS Bits --------------------------------------------------------

IRP                          EQU     H'0007'
RP1                          EQU     H'0006'
RP0                          EQU     H'0005'
NOT_TO                       EQU     H'0004'
NOT_PD                       EQU     H'0003'
Z                            EQU     H'0002'
DC                           EQU     H'0001'
C                            EQU     H'0000'

;==========================================================================
;
;       Processor-dependent Definitions
;
;==========================================================================

 IFDEF __16C61
   __MAXRAM H'0AF'
   __BADRAM H'07'-H'09', H'030'-H'07F', H'087'-H'089' 
   #define __CONFIG_0
 ENDIF

 IFDEF __16C62
PORTC                     EQU     H'0007'
   __MAXRAM H'0BF'
   __BADRAM H'08'-H'09',H'0D',H'018'-H'01F',H'08D',H'08F'-H'091',H'095'-H'09F'
   #define __CONFIG_2
 ENDIF

 IFDEF __16C620
;----- Register Files --------------------------------------------------
PIR1                      EQU     H'000C'
CMCON                     EQU     H'001F'

PIE1                      EQU     H'008C'
PCON                      EQU     H'008E'
VRCON                     EQU     H'009F'

   __MAXRAM H'09F'
   __BADRAM H'07'-H'09', H'0D'-H'01E', H'070'-H'07F', H'087'-H'089', H'08D', H'08F'-H'09E'
   #define __CONFIG_6
 ENDIF

 IFDEF __16C621
;----- Register Files --------------------------------------------------
PIR1                      EQU     H'000C'
CMCON                     EQU     H'001F'

PIE1                      EQU     H'008C'
PCON                      EQU     H'008E'
VRCON                     EQU     H'009F'

   __MAXRAM H'09F'
   __BADRAM H'07'-H'09', H'0D'-H'01E', H'70'-H'07F', H'087'-H'089', H'08D', H'08F'-H'09E'
   #define __CONFIG_4
 ENDIF

 IFDEF __16C622
;----- Register Files --------------------------------------------------
PIR1                      EQU     H'000C'
CMCON                     EQU     H'001F'

PIE1                      EQU     H'008C'
PCON                      EQU     H'008E'
VRCON                     EQU     H'009F'

   __MAXRAM H'0BF'
   __BADRAM H'07'-H'09', H'0D'-H'01E', H'087'-H'089', H'08D', H'08F'-H'09E'
   #define __CONFIG_5
 ENDIF

 IFDEF __16C63
;----- Register Files --------------------------------------------------
PORTC                     EQU     H'0007'
PIR1                      EQU     H'000C'
TMR1L                     EQU     H'000E'
TMR1H                     EQU     H'000F'
T1CON                     EQU     H'0010'
TMR2                      EQU     H'0011'
T2CON                     EQU     H'0012'
SSPBUF                    EQU     H'0013'
SSPCON                    EQU     H'0014'
CCPR1L                    EQU     H'0015'
CCPR1H                    EQU     H'0016'
CCP1CON                   EQU     H'0017'
TRISC                     EQU     H'0087'
PIE1                      EQU     H'008C'
PCON                      EQU     H'008E'
PR2                       EQU     H'0092'
SSPADD                    EQU     H'0093'
SSPSTAT                   EQU     H'0094'

   __MAXRAM H'0BF'
   __BADRAM H'08'-H'09', H'0D', H'18'-H'1F', H'88', H'89', H'8D', H'8F'-H'91', H'95'-H'9F'
   #define __CONFIG_5
 ENDIF

 IFDEF __16C64
;----- Register Files --------------------------------------------------
PORTC                     EQU     H'0007'
PORTD                     EQU     H'0008'
PORTE                     EQU     H'0009'
PIR1                      EQU     H'000C'
TMR1L                     EQU     H'000E'
TMR1H                     EQU     H'000F'
T1CON                     EQU     H'0010'
TMR2                      EQU     H'0011'
T2CON                     EQU     H'0012'
SSPBUF                    EQU     H'0013'
SSPCON                    EQU     H'0014'
CCPR1L                    EQU     H'0015'
CCPR1H                    EQU     H'0016'
CCP1CON                   EQU     H'0017'
TRISC                     EQU     H'0087'
TRISD                     EQU     H'0088'
TRISE                     EQU     H'0089'
PIE1                      EQU     H'008C'
PCON                      EQU     H'008E'
PR2                       EQU     H'0092'
SSPADD                    EQU     H'0093'
SSPSTAT                   EQU     H'0094'
    __MAXRAM H'0BF'
   __BADRAM H'0D', H'018'-H'01F', H'08D', H'08F'-H'091', H'095'-H'09F'
   #define __CONFIG_2
 ENDIF

 IFDEF __16C65
;----- Register Files --------------------------------------------------
PORTC                     EQU     H'0007'
PORTD                     EQU     H'0008'
PORTE                     EQU     H'0009'
PIR1                      EQU     H'000C'
PIR2                      EQU     H'000D'
TMR1L                     EQU     H'000E'
TMR1H                     EQU     H'000F'
T1CON                     EQU     H'0010'
TMR2                      EQU     H'0011'
T2CON                     EQU     H'0012'
SSPBUF                    EQU     H'0013'
SSPCON                    EQU     H'0014'
CCPR1L                    EQU     H'0015'
CCPR1H                    EQU     H'0016'
CCP1CON                   EQU     H'0017'
RCSTA                     EQU     H'0018'
TXREG                     EQU     H'0019'
RCREG                     EQU     H'001A'
CCPR2L                    EQU     H'001B'
CCPR2H                    EQU     H'001C'
CCP2CON                   EQU     H'001D'
TRISC                     EQU     H'0087'
TRISD                     EQU     H'0088'
TRISE                     EQU     H'0089'
PIE1                      EQU     H'008C'
PIE2                      EQU     H'008D'
PCON                      EQU     H'008E'
PR2                       EQU     H'0092'
SSPADD                    EQU     H'0093'
SSPSTAT                   EQU     H'0094'
TXSTA                     EQU     H'0098'
SPBRG                     EQU     H'0099'

   __MAXRAM H'0FF'
   __BADRAM H'1E'-H'1F',H'08F'-H'091', H'095'-H'097', H'09A'-H'09F'
   #define __CONFIG_2
 ENDIF

 IFDEF __16C71
   __MAXRAM H'0AF'
   __BADRAM H'07', H'030'-H'07F', H'087'
   #define __ADC_CONFIG_0
   #define __CONFIG_0
 ENDIF

 IFDEF __16C73
;----- Register Files --------------------------------------------------
PORTC                     EQU     H'0007'
PIR1                      EQU     H'000C'
PIR2                      EQU     H'000D'
TMR1L                     EQU     H'000E'
TMR1H                     EQU     H'000F'
T1CON                     EQU     H'0010'
TMR2                      EQU     H'0011'
T2CON                     EQU     H'0012'
SSPBUF                    EQU     H'0013'
SSPCON                    EQU     H'0014'
CCPR1L                    EQU     H'0015'
CCPR1H                    EQU     H'0016'
CCP1CON                   EQU     H'0017'
RCSTA                     EQU     H'0018'
TXREG                     EQU     H'0019'
RCREG                     EQU     H'001A'
CCPR2L                    EQU     H'001B'
CCPR2H                    EQU     H'001C'
CCP2CON                   EQU     H'001D'

TRISC                     EQU     H'0087'
PIE1                      EQU     H'008C'
PIE2                      EQU     H'008D'
PCON                      EQU     H'008E'
PR2                       EQU     H'0092'
SSPADD                    EQU     H'0093'
SSPSTAT                   EQU     H'0094'
TXSTA                     EQU     H'0098'
SPBRG                     EQU     H'0099'

   __MAXRAM H'0FF'
   __BADRAM H'08F'-H'091', H'095'-H'097', H'09A'-H'09E'
   #define __ADC_CONFIG_1
   #define __CONFIG_2
 ENDIF

 IFDEF __16C74
;----- Register Files --------------------------------------------------
PORTC                     EQU     H'0007'
PORTD                     EQU     H'0008'
PORTE                     EQU     H'0009'
PIR1                      EQU     H'000C'
PIR2                      EQU     H'000D'
TMR1L                     EQU     H'000E'
TMR1H                     EQU     H'000F'
T1CON                     EQU     H'0010'
TMR2                      EQU     H'0011'
T2CON                     EQU     H'0012'
SSPBUF                    EQU     H'0013'
SSPCON                    EQU     H'0014'
CCPR1L                    EQU     H'0015'
CCPR1H                    EQU     H'0016'
CCP1CON                   EQU     H'0017'
RCSTA                     EQU     H'0018'
TXREG                     EQU     H'0019'
RCREG                     EQU     H'001A'
CCPR2L                    EQU     H'001B'
CCPR2H                    EQU     H'001C'
CCP2CON                   EQU     H'001D'

TRISC                     EQU     H'0087'
TRISD                     EQU     H'0088'
TRISE                     EQU     H'0089'
PIE1                      EQU     H'008C'
PIE2                      EQU     H'008D'
PCON                      EQU     H'008E'
PR2                       EQU     H'0092'
SSPADD                    EQU     H'0093'
SSPSTAT                   EQU     H'0094'
TXSTA                     EQU     H'0098'
SPBRG                     EQU     H'0099'

   __MAXRAM H'0FF'
   __BADRAM H'08F'-H'091', H'095'-H'097', H'09A'-H'09E'
   #define __ADC_CONFIG_1
   #define __CONFIG_2
 ENDIF

 IFDEF __16C84
;----- Register Files --------------------------------------------------
EEDATA                    EQU     H'0008'
EEADR                     EQU     H'0009'
EECON1                    EQU     H'0088'
EECON2                    EQU     H'0089'

   __MAXRAM H'0AF'
   __BADRAM H'07', H'030'-H'07F', H'087'
   #define __CONFIG_0
 ENDIF

;==========================================================================
;
;       Configuration Bits
;
;==========================================================================

 IFDEF __CONFIG_0
_CP_ON                       EQU     H'3FEF'
_CP_OFF                      EQU     H'3FFF'
_PWRTE_ON                    EQU     H'3FFF'
_PWRTE_OFF                   EQU     H'3FF7'
_WDT_ON                      EQU     H'3FFF'
_WDT_OFF                     EQU     H'3FFB'
_LP_OSC                      EQU     H'3FFC'
_XT_OSC                      EQU     H'3FFD'
_HS_OSC                      EQU     H'3FFE'
_RC_OSC                      EQU     H'3FFF'

   #undefine __CONFIG_0
 ENDIF


 IFDEF __CONFIG_1
_BODEN_ON                    EQU     H'3FFF'
_BODEN_OFF                   EQU     H'3FBF'
_CP_ON                       EQU     H'004F'
_CP_OFF                      EQU     H'3FFF'
_PWRTE_OFF                   EQU     H'3FFF'
_PWRTE_ON                    EQU     H'3FF7'
_WDT_ON                      EQU     H'3FFF'
_WDT_OFF                     EQU     H'3FFB'
_LP_OSC                      EQU     H'3FFC'
_XT_OSC                      EQU     H'3FFD'
_HS_OSC                      EQU     H'3FFE'
_RC_OSC                      EQU     H'3FFF'

   #undefine __CONFIG_1
 ENDIF


 IFDEF __CONFIG_2
_CP_ALL                      EQU     H'3F8F'
_CP_75                       EQU     H'3F9F'
_CP_50                       EQU     H'3FAF'
_CP_OFF                      EQU     H'3FBF'
_PWRTE_ON                    EQU     H'3FBF'
_PWRTE_OFF                   EQU     H'3FB7'
_WDT_ON                      EQU     H'3FBF'
_WDT_OFF                     EQU     H'3FBB'
_LP_OSC                      EQU     H'3FBC'
_XT_OSC                      EQU     H'3FBD'
_HS_OSC                      EQU     H'3FBE'
_RC_OSC                      EQU     H'3FBF'

   #undefine __CONFIG_2
 ENDIF


 IFDEF __CONFIG_3
_CP_ON                       EQU     H'000F'
_CP_OFF                      EQU     H'3FFF'
_PWRTE_ON                    EQU     H'3FFF'
_PWRTE_OFF                   EQU     H'3FF7'
_WDT_ON                      EQU     H'3FFF'
_WDT_OFF                     EQU     H'3FFB'
_LP_OSC                      EQU     H'3FFC'
_XT_OSC                      EQU     H'3FFD'
_HS_OSC                      EQU     H'3FFE'
_RC_OSC                      EQU     H'3FFF'

   #undefine __CONFIG_3
 ENDIF


 IFDEF __CONFIG_4
_BODEN_ON                    EQU     H'3FFF'
_BODEN_OFF                   EQU     H'3FBF'
_CP_ALL                      EQU     H'00CF'
_CP_50                       EQU     H'15DF'
_CP_OFF                      EQU     H'3FFF'
_PWRTE_OFF                   EQU     H'3FFF'
_PWRTE_ON                    EQU     H'3FF7'
_WDT_ON                      EQU     H'3FFF'
_WDT_OFF                     EQU     H'3FFB'
_LP_OSC                      EQU     H'3FFC'
_XT_OSC                      EQU     H'3FFD'
_HS_OSC                      EQU     H'3FFE'
_RC_OSC                      EQU     H'3FFF'

   #undefine __CONFIG_4
 ENDIF


 IFDEF __CONFIG_5
_BODEN_ON                    EQU     H'3FFF'
_BODEN_OFF                   EQU     H'3FBF'
_CP_ALL                      EQU     H'00CF'
_CP_75                       EQU     H'15DF'
_CP_50                       EQU     H'2AEF'
_CP_OFF                      EQU     H'3FFF'
_PWRTE_OFF                   EQU     H'3FFF'
_PWRTE_ON                    EQU     H'3FF7'
_WDT_ON                      EQU     H'3FFF'
_WDT_OFF                     EQU     H'3FFB'
_LP_OSC                      EQU     H'3FFC'
_XT_OSC                      EQU     H'3FFD'
_HS_OSC                      EQU     H'3FFE'
_RC_OSC                      EQU     H'3FFF'

   #undefine __CONFIG_5
 ENDIF

 IFDEF __CONFIG_6
_BODEN_ON                    EQU     H'3FFF'
_BODEN_OFF                   EQU     H'3FBF'
_CP_ON                       EQU     H'00CF'
_CP_OFF                      EQU     H'3FFF'
_PWRTE_OFF                   EQU     H'3FFF'
_PWRTE_ON                    EQU     H'3FF7'
_WDT_ON                      EQU     H'3FFF'
_WDT_OFF                     EQU     H'3FFB'
_LP_OSC                      EQU     H'3FFC'
_XT_OSC                      EQU     H'3FFD'
_HS_OSC                      EQU     H'3FFE'
_RC_OSC                      EQU     H'3FFF'

   #undefine __CONFIG_6
 ENDIF

;==========================================================================
;
;       More Bit Definitions
;
;==========================================================================

 IFDEF __ADC_CONFIG_0
;---- Register Files ---------------------------------------------------
ADCON0                    EQU     H'0008'
ADRES                     EQU     H'0009'

ADCON1                    EQU     H'0088'

;---- Finish INTCON Definition -----------------------------------------
ADIE                      EQU     H'0006'

;----- ADCON0 Bits -----------------------------------------------------
ADCS1                     EQU     H'0007'
ADCS0                     EQU     H'0006'
CHS1                      EQU     H'0004'
CHS0                      EQU     H'0003'
GO                        EQU     H'0002'
NOT_DONE                  EQU     H'0002'
GO_DONE                   EQU     H'0002'
ADIF                      EQU     H'0001'
ADON                      EQU     H'0000'

;----- ADCON1 Bits -----------------------------------------------------
PCFG1                     EQU     H'0001'
PCFG0                     EQU     H'0000'

   #undefine __ADC_CONFIG_0
 ELSE
;---- Finish INTCON Definition -----------------------------------------
PEIE                      EQU     H'0006'
 ENDIF


 IFDEF __ADC_CONFIG_1
;----- Register Files --------------------------------------------------
ADRES                     EQU     H'001E'
ADCON0                    EQU     H'001F'

ADCON1                    EQU     H'009F'

;----- ADCON0 Bits -----------------------------------------------------
ADCS1                     EQU     H'0007'
ADCS0                     EQU     H'0006'
CHS2                      EQU     H'0005'
CHS1                      EQU     H'0004'
CHS0                      EQU     H'0003'
GO                        EQU     H'0002'
NOT_DONE                  EQU     H'0002'
GO_DONE                   EQU     H'0002'
ADON                      EQU     H'0000'

;----- ADCON1 Bits -----------------------------------------------------
PCFG2                     EQU     H'0002'
PCFG1                     EQU     H'0001'
PCFG0                     EQU     H'0000'

;----- PIE1 and PIR1 ADC Bits ------------------------------------------
ADIE                      EQU     H'0006'
ADIF                      EQU     H'0006'

   #undefine __ADC_CONFIG_1
 ENDIF


 IFDEF CCP1CON
CCP1X                        EQU     H'0005'
CCP1Y                        EQU     H'0004'
CCP1M3                       EQU     H'0003'
CCP1M2                       EQU     H'0002'
CCP1M1                       EQU     H'0001'
CCP1M0                       EQU     H'0000'
 ENDIF


 IFDEF CCP2CON
CCP2X                        EQU     H'0005'
CCP2Y                        EQU     H'0004'
CCP2M3                       EQU     H'0003'
CCP2M2                       EQU     H'0002'
CCP2M1                       EQU     H'0001'
CCP2M0                       EQU     H'0000'
 ENDIF


 IFDEF CMCON
C2OUT                        EQU     H'0007'
C1OUT                        EQU     H'0006'
CIS                          EQU     H'0003'
CM2                          EQU     H'0002'
CM1                          EQU     H'0001'
CM0                          EQU     H'0000'

;----- PIE1 and PIR1 ADC Bits ------------------------------------------
CMIE                      EQU     H'0006'
CMIF                      EQU     H'0006'
 ENDIF


 IFDEF EECON1
EEIF                         EQU     H'0004'
WRERR                        EQU     H'0003'
WREN                         EQU     H'0002'
WR                           EQU     H'0001'
RD                           EQU     H'0000'
 ENDIF


 IFDEF PCON
NOT_POR                      EQU     H'0001'
NOT_BO                       EQU     H'0000'
 ENDIF


 IFDEF PIE1
PSPIE                        EQU     H'0007'
SSPIE                        EQU     H'0003'
CCP1IE                       EQU     H'0002'
TMR2IE                       EQU     H'0001'
TMR1IE                       EQU     H'0000'
 ENDIF


 IFDEF PIR1
PSPIF                        EQU     H'0007'
SSPIF                        EQU     H'0003'
CCP1IF                       EQU     H'0002'
TMR2IF                       EQU     H'0001'
TMR1IF                       EQU     H'0000'
 ENDIF


 IFDEF PIE2                                             ; Assumes PIE2 and PIR2
CCP2IE                       EQU     H'0000'
CCP2IF                       EQU     H'0000'
 ENDIF


 IFDEF RCSTA
SPEN                         EQU     H'0007'
RC9                          EQU     H'0006'
NOT_RC8                      EQU     H'0006'
RC8_9                        EQU     H'0006'
SREN                         EQU     H'0005'
CREN                         EQU     H'0004'
FERR                         EQU     H'0002'
OERR                         EQU     H'0001'
RCD8                         EQU     H'0000'

;----- PIE1 and PIR1 RC Bits ------------------------------------------
RCIE                      EQU     H'0005'
RBFL                      EQU     H'0005'
 ENDIF


 IFDEF SSPCON
WCOL                         EQU     H'0007'
SSPOV                        EQU     H'0006'
SSPEN                        EQU     H'0005'
CKP                          EQU     H'0004'
SSPM3                        EQU     H'0003'
SSPM2                        EQU     H'0002'
SSPM1                        EQU     H'0001'
SSPM0                        EQU     H'0000'
 ENDIF


 IFDEF SSPSTAT
D                            EQU     H'0005'
I2C_DATA                     EQU     H'0005'
NOT_A                        EQU     H'0005'
NOT_ADDRESS                  EQU     H'0005'
D_A                          EQU     H'0005'
DATA_ADDRESS                 EQU     H'0005'
P                            EQU     H'0004'
I2C_STOP                     EQU     H'0004'
S                            EQU     H'0003'
I2C_START                    EQU     H'0003'
R                            EQU     H'0002'
I2C_READ                     EQU     H'0002'
NOT_W                        EQU     H'0002'
NOT_WRITE                    EQU     H'0002'
R_W                          EQU     H'0002'
READ_WRITE                   EQU     H'0002'
UA                           EQU     H'0001'
BF                           EQU     H'0000'
 ENDIF


 IFDEF T1CON
T1CKPS1                      EQU     H'0005'
T1CKPS0                      EQU     H'0004'
T1OSCEN                      EQU     H'0003'
T1INSYNC                     EQU     H'0002'
TMR1CS                       EQU     H'0001'
TMR1ON                       EQU     H'0000'
 ENDIF


 IFDEF T2CON
TOUTPS3                      EQU     H'0006'
TOUTPS2                      EQU     H'0005'
TOUTPS1                      EQU     H'0004'
TOUTPS0                      EQU     H'0003'
TMR2ON                       EQU     H'0002'
T2CKPS1                      EQU     H'0001'
T2CKPS0                      EQU     H'0000'
 ENDIF


 IFDEF TRISE
IBF                          EQU     H'0007'
OBF                          EQU     H'0006'
IBOV                         EQU     H'0005'
PSPMODE                      EQU     H'0004'
TRISE2                       EQU     H'0002'
TRISE1                       EQU     H'0001'
TRISE0                       EQU     H'0000'
 ENDIF


 IFDEF TXSTA
CSRC                         EQU     H'0007'
TX9                          EQU     H'0006'
NOT_TX8                      EQU     H'0006'
TX8_9                        EQU     H'0006'
TXEN                         EQU     H'0005'
SYNC                         EQU     H'0004'
BRGH                         EQU     H'0002'
TRMT                         EQU     H'0001'
TXD8                         EQU     H'0000'

;----- PIE1 and PIR1 TX Bits ------------------------------------------

TXIE                      EQU     H'0004'
TXIF                      EQU     H'0004'
 ENDIF


 IFDEF VRCON
VREN                         EQU     H'0007'
VROE                         EQU     H'0006'
VRR                          EQU     H'0005'
VR3                          EQU     H'0003'
VR2                          EQU     H'0002'
VR1                          EQU     H'0001'
VR0                          EQU     H'0000'
 ENDIF

	LIST
