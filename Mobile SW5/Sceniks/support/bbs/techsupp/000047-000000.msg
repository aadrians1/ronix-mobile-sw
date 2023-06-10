Kai
Klein
kai.klein@t-online.de
10/12/98 2:15 PM
Still OSC Problems 
options:email:kai.klein@t-online.de
Hi Scenix,

i have still the time problem with the Internal OSC from the SX 18 , but i now more details, i ordert 5 new SX 18 Rev.9818 to by shure that the SX is not destroyed.

1.) ok i used first my Programm with SX 18 INT OSC with 4MHZ, 2 Serials 9600bps a.s.o result: the serial is to slow
2.) i used the same SX with EXT OSC 4MHZ result: Perfect !
3.) i used the SX 18 with Debug Mode with 4MHZ SXKey OSC result: Perfect !
4.) i used the SX 28 with INT OSC 4MHZ result: Perfect !
5.) i used the SX 28 with EXT OSC 4MHZ result: Perfect !

i tryed this also with your programm rtcc_int.src

; Simple program using rtcc-rollover interrupt
; rb.0 toggles via main code and rb.1 toggles via interrupt
; (see sxkey.txt for complete list of instructions)

device pins18,pages4,banks8,turbo,optionx,osc4mhz
FREQ 4_000_000
reset start 

;goto 'start' on reset
org 0               ;3 ;interrupt routine (3 cycles in)
xor rb,#%00000010   ;2 ;toggle rb.1
mov w,#-20          ;1 ;interrupt every 20 cycles
retiw               ;3 ;9 cycles total interrupt time
start mov !option,#%00000000        ;start, enable rtcc interrupt
mov !rb,#%11111100  ;make rb.0 and rb.1 outputs
mov w,#%00000001    ;ready to toggle rb.0
:loop xor rb,w      ;1 ;toggle rb.0
jmp :loop           ;3 ;4 cycles total loop time

wath is here wrong ? where is my mistake ?
please Help me.

