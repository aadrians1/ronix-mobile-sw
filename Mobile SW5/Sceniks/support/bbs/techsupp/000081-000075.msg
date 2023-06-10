Chris
Fogelklou
chris.fogelklou@scenix.com
1/14/99 6:04 PM
Re: (IREAD) i search Hex to ASCII convert Modul 
options:email:chris.fogelklou@scenix.com
Just in addition to Stephen,

The code he showed you was missing the org instruction.

Doing ireads requires that you have the m register set up with the upper 4 bits of the page you are on.  In the code he posted, he was loading #4 into the mreg, which will make the iread read from page 4.  He missed the org instruction before the hex table, however, which would put the table in program memory at page 4.  Simply add this line before the rest of the code...

org $400

;ASCII lookup

_hex...

That should to the trick.

Regards,

Chris Fogelklou

Stephen Holland on 1/11/99 9:29 AM said:

>>kai klein on 1/11/99 5:02 AM said:>>
>>>>
>>>>Hi ,>>>>
>>>>has some one a SX Modul (Virtual Per.) to convert >>>>
>>>>Hex to Ascii ?>>>>
>>>>>>>>
>>>>ff = 256 (to send this via Serial Virtual Per.)>>>>
>>>>>>>>
>>>>i need this for the Dallas Temp Sensor DS1820>>>>
>>>>>>>>
>>>>Please Help ! >>
>>>>>>
>>>>
>>>>
>>Kai,>>
>>>>
>>Actually, in our SXDemo code, you'll see the send_hex function for sending a hex value out through the UART to the terminal.>>
>>>>
>>Here's the code...>>
>>>>
c>>>>
>>hex_to_ascii>>
>>:digit		and	w,#$f			;read hex chr>>
>>		mov	temp,w>>
>>		mov	w,#_hex>>
>>		clc>>
>>		add	w,temp>>
>>		mov	m,#4>>
>>		iread>>
>>		mov	m,#$f>>
>>                retp>>
>>>>
>>Just load the value to be converted into W, and then call hex_to_ascii.>>
>>>>
>>Scenix>>
>>>>
>>
>>

