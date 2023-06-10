Chris 
Fogelklou
chris.fogelklou@scenix.com
1/14/99 10:25 AM
Skipping long calls, banking instructions
options:email:chris.fogelklou@scenix.com
Hi Loren,

I have a hunch...

The SX, I am sure, has a built in trick which skips the next instruction after a page instruction.  This allows the user to skip long calls (page,call).  It also means that if the user were just trying to skip the page, the SX would also skip the next instruction afterwards.  It's a cool trick, but only once you know it's there.  If you don't, it can be really frustrating to try to figure out the problem.

I am not sure (I'll have to check with engineering), but this trick may have been built in to deal with doing bank instructions as well.  It would make skipping register operations extremely easy, but only once you know it is there.  This would explain why the nop would fix the problem.  It would skip the bank, and the next instruction after the bank.

Regards,

Chris Fogelklou

Loren Blaney on 1/5/99 9:59 AM said:

>>zafar ullah on 1/4/99 1:59 PM said:>>
>>>>
>>>>Hello Loren,>>>>
>>>>It is recommended to use NOP instruction in between  successive read-modify-write operations on I/O pins at high speed. Although the device has as internal write-back (4th stage of the pipeline)section to prevent unexpected result, it is still recommended that the program includes a NOP instruction as a buffer between successive read-modify-write instructions performed on the I/O pins of the same port. Take care.>>>>
>>>>  >>>>
>>>>>>>>
>>>>Loren Blaney on 1/3/99 1:12 PM said:>>>>
>>>>>>>>
>>>>>>>>>>
>>>>>>>>>>
>>>>>>;How come I need a nop in the following little program for it to work right?>>>>
>>>>
>>>>
>>Thanks for your reply, but that is not the problem. There is no read-modify-write operation on I/O, and 31kHz is hardly high speed. Turbo mode has no effect on the problem.>>
>>>>
>>Since your newsgroup software doesn’t handle tabs, here’s a more readable version using space characters:>>
>>>>
>>;How come I need a nop in the following little program for it to work right?>>
>>>>
>>        device   pins28,pages1,banks8,osc31khz>>
>>        reset    start>>
>>>>
>>        org      $10>>
>>ramloc  ds       1>>
>>>>
>>        org      0>>
>>start   mov      !rb,#$F0     ;set up LEDs (on demo board) as outputs>>
>>>>
>>        clr      fsr          ;fill all ram with pattern>>
>>:loop   setb     fsr.4>>
>>        mov      ind,#%1010>>
>>        ijnz     fsr,:loop>>
>>>>
>>        bank     $30          ;select bank 1>>
>>;(code removed for simplicity)>>
>>>>
>>        sub      fsr,#$20     ;next bank down>>
>>        sc                    ;skip if not underflow>>
>>         bank    $50          ; else select bank 2>>
>>        nop                   ;*** REQUIRED ***>>
>>>>
>>        mov      rb,ramloc    ;display result on LEDs>>
>>        jmp      $            ;lock up>>
>>>>
>>;rb outputs the expected 1010b when the nop is present, but it outputs 0000b>>
>>; when the nop is commented out.>>
>>;Chips tested: SX28AC/DP 9818, 9812, 9747.>>
>>
>>

