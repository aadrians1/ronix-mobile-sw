Stephen
Holland
support@scenix.com
8/28/98 11:53 AM
Re: rtcc interrupt by external source
options:email:support@scenix.com
juergen leistikow on 8/27/98 3:14 AM said:

>>Hello Scenix,>>
>>>>
>>thanks for your quick response.>>
>>Sorry, there was a missunderstanding. So i better tell you,>>
>>what i want to do in my next application.>>
>>In that next ap. i need two 8 bit ports and 1 interrupt source. The interrupt source should be the rtcc pin in turbo>>
>>mode and not assigned to the prescaler !>>
>>The rtcc register will be preset to ffh so that the next>>
>>transition on rtcc pin will generate an interrupt.>>
>>In your errata sheet from may 26 that option is announced>>
>>not to be yet implemented.>>
>>So, when will that be enabled?>>
>>>>
>>With kind regards>>
>>     >>
>>              j.leistikow
>>


Jeurgen,

This fault is in our errata sheet. The external RTCC clock source does have a bug where, while in turbo mode and no prescaler, the RTCC will not sense any external events. If the Prescaler is assigned to the RTCC, the counter function works as described. If the Prescaler is assigned to the WDT, then the RTCC will only function as an internal clock timer, but operation as an external event counter is inoperative. 

This will be fixed in the next rev.

Scenix
