Alexey
Vladimirov
avlad@mail.svtehs.com
1/18/99 2:40 PM
Re: Skipping long calls, banking instructions
options:email:avlad@mail.svtehs.com
Loren Blaney on 1/15/99 11:57 AM said:

>There are a few other things that could be >fixed in your documentation. 

Let's do it with exact references.

>For example, the RETIW instruction ADDS W >to RTCC, not subtracts it;

Table 16-1 in SX Datasheet page 33

>JMP and SKIP instructions take 2 cycles in >compatible mode, not 4.

Table 3-7 in User's manual page 53.

>I'll be happy to point out a bunch of other >little problems if you're serious about >fixing them.

Please, put it there. Probably it will be the fastest way to found all errors and typos on documentation. I prepare SX manual
and datasheet translation into Russian now and try to make it as free of errors, as possible.

Another one:

WKED_B (Mode=0Ah)
Set the bit to 1 to sense failing edge,
clear to 0 to sense rising edge, not
vice versa.

SX Datasheet page 9

>Also, I have a simulator program for the SX >(called SxSim), and I like to keep it as >accurate as possible. 

Loren, Parallax SX-Key did not support this
instructions, so your simulator will be
the only one, which really simulate SX,
if you add all this instructions...<grin>


>So, please let us know exactly what these >secret instructions do.

20/08/98 Steven Holland writes in this newsgroup, that this specifications
should be released in approx 6 weeks.
It is 20 weeks already gone, but specifications still not released. When it will be done, Chris ? 

P.S. Check http://www.svtehs.com/scenix.htm
more than 100 SX links now...

Best regards

Alexey Vladimirov
