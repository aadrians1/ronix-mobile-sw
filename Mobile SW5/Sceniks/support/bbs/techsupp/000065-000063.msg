Stephen
Holland
support@scenix.com
11/25/98 2:51 PM
Re: Problem with port B interrupt
options:email:support@scenix.com
wayne glasser on 11/25/98 1:39 AM said:

>>>>
>>We are experiencing a problem when using the port B interrupt on an 18 pin 9818 date device.  If another interrupt is received before the first code has cleared and returned, the interrupt system becomes inoperative however non interrupt code keeps running.  Is this a known bug or is there something we need to do within or when exiting the interrupt code to stop this happening.  I have included a sample of the source code we were using to track the problem
>>


This is a recent bug which has been discovered which can be easily fixed by adding the following 3 lines of code right before the return from interrupt:
  mov   m,#$0b     ;Enable Port B interrupts
  mov   !rb,#$f0   ;Enable interrupts on rb.0-3
  mov   m,#$0f     ;Point mode back to ports

This has been fixed in all future releases of SX chips...

Scenix
