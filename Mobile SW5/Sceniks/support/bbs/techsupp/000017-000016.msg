Stephen
Holland
support@scenix.com
8/26/98 8:17 PM
Re: rtcc extern pin interrrupt
options:email:support@scenix.com
juergen leistikow on 8/26/98 3:31 AM said:

>>Dear madam, dear sir,>>
>>for my next applications with the SX18/28 it is importend>>
>>for me to know, when the rtcc extern pin interrupt will be>>
>>available. I do not need an exact date, but i would like to>>
>>know, if you can make the chip do this until the end of 98 ?>>
>>>>
>>With kind regards>>
>> >>
>>              j.leistikow  >>
>>
>>

Jeurgen,

The RTCC already has the capability of being clocked by an external source via the RTCC pin. Example code for the internal RTCC clocking can be found in most of our virtual peripherals or also in the design hints area. The source in this example is the internal instruction cycle, but the external RTCC pin can be selected as the source by setting bit 5 of the option register. In this mode, The RTCC counter is incremented with each valid transition (through the prescaler) at the RTCC pin. Rising or falling edge detection can be selected via bit 4 of the option register. This is explained quite clearly on page 19 of our newest data sheet.

Up to 8 external interrupts are also supported on port B. Example code for the external interrupts can also be found in the design hints area.

I hope this helps.

Scenix
