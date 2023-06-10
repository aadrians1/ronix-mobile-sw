Zafar 
Ullah
zafar.ullah@scenix.com
8/14/98 12:07 PM
Re: External Osc
options:email:zafar.ullah@scenix.com
Hello Ralph,

For programming the SX part, you dont need to remove the oscillator. Only for debugging with the SX key, you need to remove the oscillator. The voltage at osc1 pin during programming is 12.5V. If you drive the clock from a TTL driver, and the clock circuit cann't withstand 12.5V, then you need to isolate the clock circuit during programming.
You can put a jumper (for your case that is not possible), or have a transistor circuit(as we discussed in our last conversation) which would isolate the clock block. Putting a cap in series didn't work for your case, right? Any more ideas? 


Ralph Wade on 8/13/98 12:33 PM said:

>>Is there any way to connect a external Osc to the SX28 and  have the SX key program it with out removing the osc from osc1 pin?
>>
>>My application is extremely small SSOP type boards. I do not have room to put a jumper for programming on the board. Not to mention that the vibration would be a problem with a jumper in my environment
>>
>>
>>

