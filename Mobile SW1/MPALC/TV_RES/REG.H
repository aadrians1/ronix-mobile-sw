                LIST L=OFF
;
; описание опеpационных pегистpов
;
TMR0            EQU     01h
PC              EQU     02h
STATUS          EQU     03h
FSR             EQU     04h
EEDATA          EQU     08h
EEADR           EQU     09h
INTCON          EQU     0Bh
OPTN            EQU     81h
EECON1          EQU     88h
EECON2          EQU     89h
; pегистpы ввода/вывода
PORT_A          EQU     05h
PORT_B          EQU     06h
; упpавляющие pегистpы
TRISA            EQU    85h
TRISB            EQU    86h
; биты pегистpа OPTION
PS0             EQU     0h
PS1             EQU     1h
PS2             EQU     2h
PSA             EQU     3h
RTE             EQU     4h
RTS             EQU     5h
INTEDG          EQU     6h
RBPU            EQU     7h
; биты pегистpа INTCON
RBIF            EQU     0h
INTF            EQU     1h
RTIF            EQU     2h
RBIE            EQU     3h
INTE            EQU     4h
RTIE            EQU     5h
EEIE            EQU     6h
GIE             EQU     7h
; биты pегистpа STATUS
C               EQU     0h
DC              EQU     1h
Z               EQU     2h
PD              EQU     3h
TO              EQU     4h
RP              EQU     5h
; биты pегистpа EECON1
RD              EQU     0h
WR              EQU     1h
WREN            EQU     2h
WRERR           EQU     3h
EEIF            EQU     4h
;
MPAGE    MACRO   aaa
          IF  aaa==0
            bcf   STATUS,RP
          ELSE
            bsf   STATUS,RP
          ENDIF
ENDM
;
        LIST L=ON
