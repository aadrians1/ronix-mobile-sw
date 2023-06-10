Stephen
Holland
support@scenix.com
1/11/99 9:29 AM
Re: i search Hex to ASCII convert Modul 
options:email:support@scenix.com
kai klein on 1/11/99 5:02 AM said:

>>Hi ,>>
>>has some one a SX Modul (Virtual Per.) to convert >>
>>Hex to Ascii ?>>
>>>>
>>ff = 256 (to send this via Serial Virtual Per.)>>
>>>>
>>i need this for the Dallas Temp Sensor DS1820>>
>>>>
>>Please Help ! 
>>


Kai,

Actually, in our SXDemo code, you'll see the send_hex function for sending a hex value out through the UART to the terminal.

Here's the code...

; ASCII lookup
_hex		dw	'0123456789ABCDEF'

hex_to_ascii
:digit		and	w,#$f			;read hex chr
		mov	temp,w
		mov	w,#_hex
		clc
		add	w,temp
		mov	m,#4
		iread
		mov	m,#$f
                retp

Just load the value to be converted into W, and then call hex_to_ascii.

Scenix


