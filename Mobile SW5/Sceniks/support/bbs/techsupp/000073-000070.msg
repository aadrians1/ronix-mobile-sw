Loren
Blaney
loren_blaney@idcomm.com
1/5/99 9:59 AM
Re: nop required
options:email:loren_blaney@idcomm.com
zafar ullah on 1/4/99 1:59 PM said:

>>Hello Loren,>>
>>It is recommended to use NOP instruction in between  successive read-modify-write operations on I/O pins at high speed. Although the device has as internal write-back (4th stage of the pipeline)section to prevent unexpected result, it is still recommended that the program includes a NOP instruction as a buffer between successive read-modify-write instructions performed on the I/O pins of the same port. Take care.>>
>>  >>
>>>>
>>Loren Blaney on 1/3/99 1:12 PM said:>>
>>>>
>>>>>>
>>>>>>
>>>>;How come I need a nop in the following little program for it to work right?>>


Thanks for your reply, but that is not the problem. There is no read-modify-write operation on I/O, and 31kHz is hardly high speed. Turbo mode has no effect on the problem.

Since your newsgroup software doesn’t handle tabs, here’s a more readable version using space characters:

;How come I need a nop in the following little program for it to work right?

        device   pins28,pages1,banks8,osc31khz
        reset    start

        org      $10
ramloc  ds       1

        org      0
start   mov      !rb,#$F0     ;set up LEDs (on demo board) as outputs

        clr      fsr          ;fill all ram with pattern
:loop   setb     fsr.4
        mov      ind,#%1010
        ijnz     fsr,:loop

        bank     $30          ;select bank 1
;(code removed for simplicity)

        sub      fsr,#$20     ;next bank down
        sc                    ;skip if not underflow
         bank    $50          ; else select bank 2
        nop                   ;*** REQUIRED ***

        mov      rb,ramloc    ;display result on LEDs
        jmp      $            ;lock up

;rb outputs the expected 1010b when the nop is present, but it outputs 0000b
; when the nop is commented out.
;Chips tested: SX28AC/DP 9818, 9812, 9747.

