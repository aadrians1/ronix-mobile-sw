Nick
Kelsey
nickkelsey@hotmail.com
12/20/98 7:25 PM
Noise problems
options:email:nickkelsey@hotmail.com
I am using a SX28 together with a IrDA transceiver and are having a number of noise problems.

The IrDA transceiver Rx output produces a perfect logic high (idle) when operating off the power supply, but produces spikes when running off the same psu as the SX28. When the Rx output of the IrDA transceiver is connected to rb.0 then the spikes are bigger and more regular. The result is that the interrupt is triggered with every spike.

I have also noticed that if the input pin on the SX28 is left floating then it continually triggers the int the same way.

The SX28 is decoupled with 4.7uF and a 100nF caps. The IrDA board is a evaluation board with the recommended components. 

The problem is completly eliminated by putting a LED across the IrDA output/SX input as my origional board has - presumably acting as a crude filter.

Any help would be appreciated

Thanks

Nick

