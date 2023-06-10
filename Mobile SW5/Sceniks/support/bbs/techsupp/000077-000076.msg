zafar
ullah
zafar.ullah@scenix.com
1/12/99 9:48 AM
Re: isp programming
options:email:zafar.ullah@scenix.com
Hello Wouter,

The 12.5V should be able to supply 2.5 ma of current.
To answer your second question: You can read the FUSE word before issue the ERASE command and re-program the FUSE word
after the ERASE command. 
Also, whenever the chip is in ISP mode (please refer to the user manual about the algorithm how to put the chip in ISP mode), the internal clcok running at 128KHz is activated for the synchronization and the data transfer with the programmer. I hope that helps. Take care. 


wouter van ooijen on 1/11/99 11:09 AM said:

>>Two questions:
>>
>>
>>
>>What current must the 12.5V supply deliver?
>>
>>
>>
>>What is the algorithm to start programming when it is not known whether the chip-to-be-programmed has the internal
>>
>>or external oscillator configured?
>>
>>
>>
>>regards,
>>
>>Wouter.
>>
>>
>>
>>
>>

