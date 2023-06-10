        ORG 0
        MOV R4,0
START:
        MOV A,#0
        MOV DPTR,#IADRREG
        MOVX @DPTR,A
        DEC DPL
        MOV A,R4
        ADD A,R3
        DEC A
        CALL SIMBOLS
        MOVX @DPTR,A
        INC DPTR
        MOV A,R3
        MOVX @DPTR,A
        MOV R2,#0
        DJNZ R2,$
        DJNZ R3,START
        MOV R3,#10
        DJNZ R5,START
        MOV R5,#50
        INC R4
        JMP START
       ds 160
SIMBOLS:
       MOV C,ACC.7
       MOV 0,C
       CLR C
       SUBB A,#32
       ANL A,#7FH
       CJNE A,#40H,SIM1
SIM1:
       JC SIM2
       SUBB A,#32
SIM2:
       ADD A,#SIMTB-SIMPC-1
SIMPC:
       MOVC A,@A+PC
       mov c,0
       mov acc.4,c
       CPL A
       RET
SIMTB:
       DB 00000000B  ; PROBEL
       DB 00000000B  ;!
       DB 01000010B  ;"
       DB 00000000B  ;#
       DB 00000000B  ;$
       DB 10100010B  ;%
       DB 00000000B  ;&
       DB 00000010B  ;'
       DB 11001001B  ;(
       DB 00001111B  ;)
       DB 00000000B  ;*
       DB 00000000B  ;+
       DB 00000100B  ;,
       DB 00100000B  ;-
       DB 00000000B  ;.
       DB 11000000B  ;/
       DB 11001111B  ;0
       DB 00000110B  ;1
       DB 10101011B  ;2
       DB 00101111B  ;3
       DB 01100110B  ;4
       DB 01101101B  ;5
       DB 11101101B  ;6
       DB 00000111B  ;7
       DB 11101111B  ;8
       DB 01101111B  ;9
       DB 00000000B  ;:
       DB 00000000B  ;;
       DB 00000000B  ;<
       DB 00001100B  ;=
       DB 00000000B  ;>
       DB 10100011B  ;?
       DB 00000001B  ;@`
       DB 11100111B  ;Aa
       DB 11101100B  ;Bb
       DB 11001001B  ;Cc
       DB 10101110B  ;Dd
       DB 11101001B  ;Ee
       DB 11100001B  ;Ff
       DB 11001101B  ;Gg
       DB 11100110B  ;Hh
       DB 10001000B  ;Ii
       DB 00001110B  ;Jj
       DB 00000000B  ;Kk
       DB 11001000B  ;Ll
       DB 00000000B  ;Mm
       DB 10100100B  ;Nn
       DB 10101100B  ;Oo
       DB 11100011B  ;Pp
       DB 00000000B  ;Qq
       DB 10100000B  ;Rr
       DB 01101101B  ;Ss
       DB 11101000B  ;Tt
       DB 10001100B  ;Uu
       DB 00000000B  ;Vv
       DB 00000000B  ;Ww
       DB 00000000B  ;Xx
       DB 00000000B  ;Yy
       DB 00000000B  ;Zz
       DB 11001001B  ;[{
       DB 00000000B  ;\|
       DB 00001111B  ;]}
       DB 00000001B  ;^~
       DB 00001000B  ;_

       DB 11001111B  ;0
       DB 00000110B  ;1
       DB 10101011B  ;2
       DB 00101111B  ;3
       DB 01100110B  ;4
       DB 01101101B  ;5
       DB 11101101B  ;6
       DB 00000111B  ;7
       DB 11101111B  ;8
       DB 01101111B  ;9
       DB 11001111B  ;0
       DB 00000110B  ;1
       DB 10101011B  ;2
       DB 00101111B  ;3
       DB 01100110B  ;4
       DB 01101101B  ;5
       DB 11101101B  ;6
       DB 00000111B  ;7
       DB 11101111B  ;8
       DB 01101111B  ;9
       DB 11001111B  ;0
       DB 00000110B  ;1
       DB 10101011B  ;2
       DB 00101111B  ;3
       DB 01100110B  ;4
       DB 01101101B  ;5
       DB 11101101B  ;6
       DB 00000111B  ;7
       DB 11101111B  ;8
       DB 01101111B  ;9
       DB 11001111B  ;0
       DB 00000110B  ;1
       DB 10101011B  ;2
       DB 00101111B  ;3
       DB 01100110B  ;4
       DB 01101101B  ;5
       DB 11101101B  ;6
       DB 00000111B  ;7
       DB 11101111B  ;8
       DB 01101111B  ;9
       DB 11001111B  ;0
       DB 00000110B  ;1
       DB 10101011B  ;2
       DB 00101111B  ;3
       DB 01100110B  ;4
       DB 01101101B  ;5
       DB 11101101B  ;6
       DB 00000111B  ;7
       DB 11101111B  ;8
       DB 01101111B  ;9


EXTDATA: SECTION
         .ABSOLUTE
         ORG 0A000H
TUKSS:    DS 1  ;A000
IDATAREG: DS 1  ;A001
IADRREG:  DS 1  ;A002
          ENDS
          END
