Loren
Blaney
loren_blaney@idcomm.com
1/15/99 11:57 AM
Re: Skipping long calls, banking instructions
options:email:loren_blaney@idcomm.com
Chris  Fogelklou on 1/14/99 10:25 AM said:

>>Hi Loren,>>
>>>>
>>I have a hunch...>>
>>>>
>>The SX, I am sure, has a built in trick which skips the next instruction after a page instruction.  This allows the user to skip long calls (page,call).  It also means that if the user were just trying to skip the page, the SX would also skip the next instruction afterwards.  It's a cool trick, but only once you know it's there.  If you don't, it can be really frustrating to try to figure out the problem.>>
>>>>
>>I am not sure (I'll have to check with engineering), but this trick may have been built in to deal with doing bank instructions as well.  It would make skipping register operations extremely easy, but only once you know it is there.  This would explain why the nop would fix the problem.  It would skip the bank, and the next instruction after the bank.>>
>>>>
>>Regards,>>
>>>>
>>Chris Fogelklou>>
>


Hi Chris,

I went ahead and used the SX-Key debugger to trace down this problem, and I can confirm your suspicions. The skip instructions do indeed skip a second instruction when the skip is immediately followed by either a BANK or PAGE instruction. It takes 3 cycles to skip these two instructions.

Things really get interesting when there are several BANK and PAGE instructions in a row. They’re ALL skipped, and a cycle is taken for each. Interrupts do not interfere with this skipping behavior.

Chris, I haven’t seen your name here before, and I appreciate you taking an interest in my problem. I would hope that you’d follow through and make sure that this little “trick” gets documented so that others aren’t tripped up. While you’re at it, there are a few other things that could be fixed in your documentation. For example, the RETIW instruction ADDS W to RTCC, not subtracts it; JMP and SKIP instructions take 2 cycles in compatible mode, not 4. I’ll be happy to point out a bunch of other little problems if you’re serious about fixing them.

While snooping around with the debugger, I couldn’t help but notice that you’ve got some other undocumented features. Why, you guys are holding no fewer than *12* new instructions up your sleeve!

I think I understand the four new push instructions that push W onto the W, FSR, STATUS, and PC “shadow registers,” which are actually 2-level stacks; but unfortunately I haven’t had time to thoroughly figure out the rest. You appear to have a secret FIFO for saving and restoring values and a breakpoint register or two.

I understand that you’re reserving these secret instructions for the debugger and that using them prevents using the debugger, but some of the them are just what I needed for my multitasking executive. Also, I have a simulator program for the SX (called SxSim), and I like to keep it as accurate as possible. So, please let us know exactly what these secret instructions do.

Thanks,
Loren


