Stephen
Holland
support@scenix.com
8/15/98 0:26 AM
Re: External Osc
options:email:support@scenix.com
From experience, extra resistance in series with the external oscillator cannot sustain oscillation at high frequencies. Nice thought though. I have considered a diode in series, but havn't tried that yet...


psychic electron on 8/14/98 5:24 PM said:

>>One idea would be to connect a resister in series with the external oscillator. Then apply sxkey directly to the osc1 pin, If the sxkey has enough drive it would take >>
>>control,the trick would be to find the right resister value,>>
>>!!!!DISCLAIMER!!!!!! This is only a thought i have not tried this myself. The resister would have to be great enough to prevent damage to the sxkey and external oscillator, and small enough to overwhelm the external oscillator's signal and generate a clean clock pulse with full voltage swing and current to the scenix. You might have to add a 5 volt zener>>
>>to ground on the external oscillator to protect it from the 12 volts from the sxkey. Use an oscilloscope to monitor both sides of the resister as you slowly lowered the resistance. Before doing this carefully consider the output drive currents and voltages from the sxkey(up to~12volts)and the external oscillator and the resultant combined voltages and currents. There are many variables involved here BE CAREFUL.>>
>>The final result must still meet Scenixs clock>>
>>specifications!!! Good Luck>>
>>         
>>

