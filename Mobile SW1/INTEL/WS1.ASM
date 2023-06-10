        org 0
        nop
        sjmp mlocal
        org 24h
mlocal: jmp  headnew
headnew:
        CALL KEYIN
        jz TWAIT
        MOV R0,A
L00B2:
         MOV R4,#6FH
         MOV R5,#0A0H
         MOV DPTR,#text1
L003
         DJNZ R0,L001
         JMP L002
L001:
         mov a,dpl
         ADD a,#60H
         mov dpl,a
         JNC L003
         inc DPH
         SJMP L003
L002:
         MOV R2,#60H
L004:
         CLR  A
         MOVC A,@A+DPTR
         inc DPTR
         MOV R6,DPH
         MOV R7,DPL
         MOV DPH,R4
         MOV DPL,R5
         MOVX @DPTR,A
         inc DPTR
         MOV R4,DPH
         MOV R5,DPL
         MOV DPH,R6
         MOV DPL,R7
         DJNZ R2,L004
L005:
         CALL KEYIN
         JNZ L005
         MOV R1,0
         MOV R2,0
TWAIT:
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
         DJNZ R2,TWAIT
         DJNZ R1,TWAIT
         DJNZ R3,TWAIT
TWAIT2:
         JMP  002CH
KEYIN:
         MOV     R2,#05H
         setb    0
L0075    CLR     P1.0
         MOV     DPTR,#9effh
         MOVX    A,@DPTR
         SETB    P1.0
         XRL     A,#0FFH
         JNB     ACC.5,TWAIT2  ;L00B2   ;programmñýana
         CLR     P1.0
         MOV     DPTR,#09FF7H
         MOVX    A,@DPTR
         SETB    P1.0
         XRL     A,#0FFH
         ANL     A,#03FH
         JNB     0,PAL1
         MOV     R0,A
         SJMP    PAL2
PAL1:
         XRL     A,R0
         JNZ     KEYIN
PAL2:
         CLR     P1.0
         MOV     DPTR,#09FfbH
         MOVX    A,@DPTR
         SETB    P1.0
         XRL     A,#0FFH
         ANL     A,#03FH
         JNB     0,PAL3
         MOV     R1,A
         SJMP    PAL4
PAL3:
         XRL     A,R1
         JNZ     KEYIN
PAL4:
         CLR     0
         DJNZ    R2,L0075
         mov     a,r1
         orl     a,r0
         jnz     pal5
         ret
pal5:
         MOV R2,#0
         MOV A,R0
         JNZ PAL6
         MOV A,#6
         ADD A,R2
         MOV R2,A
         MOV A,R1
PAL6:
         RR A
         INC R2
         JNC PAL6
         MOV A,R2
         MOV DPTR,#KEYTAB
         MOVC A,@A+DPTR
         RET
KEYTAB:  DB 0,6,9,0,0,8,7,10,2,4,5,3,1
