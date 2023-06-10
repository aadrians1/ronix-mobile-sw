Stephen
Holland
support@scenix.com
8/20/98 9:02 AM
Re: toggling I/O pins
options:email:support@scenix.com
Ralph Wade on 8/20/98 7:51 AM said:

>>I am having a problem with the SX key. If I single step the program below. The RC port is first all set to high. And then the bits are cleared on bit at a time. It works fine in single step mode. The problem come in when you run full speed stop the program at the do nothing loop. The bit pattern is a 2A instead of a 0. I have tried two differant SX Keys with two differant Demo boards. I have tried placinf nops to give tome for stuf to settle down and the results vary with the number of nops I use. Any ideas?
>>
>>
>>
>>		device	pins28,pages2,banks8,oschs
>>
>>		device	turbo,stackx,optionx
>>
>>		id	'I2C demo'
>>
>>		reset	reset_entry
>>
>>		ORG	20h
>>
>>;
>>
>>;
>>
>>reset_entry
>>
>>
>>
>>	
>>
>>
>>
>>
>>
>>;******************** set PCM voltage
>>
>>		mov	!RC,#0		;set RC to output
>>
>>		nop
>>
>>		mov	RC,#$ff		;set all bits in RC to high
>>
>>		nop
>>
>>		clrb	rc.0		;set bit 0 to low
>>
>>		nop
>>
>>		clrb	rc.1		;set bit 1 to low
>>
>>		nop
>>
>>		clrb	rc.2		;set bit 2 to low
>>
>>		nop
>>
>>		clrb	rc.3		;set bit 3 to low
>>
>>		nop
>>
>>		clrb	rc.4		;set bit 4 to low
>>
>>		nop
>>
>>		clrb	rc.5		;set bit 5 to low
>>
>>		nop
>>
>>		clrb	rc.6		;set bit 6 to low
>>
>>		nop
>>
>>		clrb	rc.7		;set bit 7 to low
>>
>>		nop
>>
>>
>>
>>
>>
>>		jmp	$
>>
>>
>>
>>
>>

Ralph,

I tried your code here and everything is exactly what is expected - when stopped RC is cleared. 

What version of SX-Key software are you using? As my results differ from yours, all I can suggest is to try downloading the latest version (0.84) from Parallax's web site at www.parallaxinc.com

Scenix
