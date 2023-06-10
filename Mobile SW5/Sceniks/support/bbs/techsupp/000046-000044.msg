Stephen
Holland
support@scenix.com
10/9/98 4:07 PM
Re: RS 232 with send signal
options:email:support@scenix.com
Kai Klein on 10/8/98 9:50 AM said:

>>>>
>>hi,>>
>>i have big problems to get my serial to a transmitter running,>>
>>i need a hi signal on pin (RB.6) when i send a byte or string to the serial output pin ra.2, to bring my transmitter online when i am sending data.>>
>>>>
>>i use the demo program from scenix with 9600 8n1. for example.>>
>>>>
>>how can i do this ?>>
>>please help.>>
>> 
>>


Basically, you just need to set bit rb.6 in the send_byte routine and clear bit rb.6 on exit from that routine. I have modified the code for you, and you'll find it attached...

Scenix
