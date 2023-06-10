Loren
Blaney
loren_blaney@idcomm.com
1/24/99 11:00 PM
Re: Documentation Additions
options:email:loren_blaney@idcomm.com
Chris Fogelklou on 1/19/99 3:25 PM said:

>>Hi, Loren,>>
>>>>
>>We would greatly appreciate any input you have on what could be added to the documentation, such as the comment about retiw.  We are consistently trying to keep on top of this, but, as always, we do miss some details.  If you could let us know, your input is appreciated.  >>
>>>>
>>Thanks,>>
>>>>
>>Chris Fogelklou>>


Hi Chris,

Here’s a list of things you might fix in your documentation.

I’ve corrected the datasheet, even though it’s labeled PRELIMINARY, rather than the User’s Manual because it has the most recent date. It’s also more concise. I’m more concerned about accurate documentation of the functioning of the SX than about errors in examples and explanatory text.

It’s especially important that the changes Scenix made to Microchip’s design be accurately documented.

The first thing I notice is that your web site says: 10/24/98, but the document is dated December 3, 1998. It’s nice to see when an updated document is available without having to first download it.

1.2.1 CPU Features
Add interrupt response time for compatible mode: 160 ns internal, 200 ns external.

2.3 Part Numbering
18 and 20 pin devices actually have 137 (effective) bytes of RAM.

3.1 Reading and Writing the Ports
Forth paragraph should read: When a write is performed to a bit position for a port that has been configured as an input, a write to the port data register is still performed, but it has...

3.2.2 Port Configuration Registers; WKED_B: Wakeup Edge Register (MODE=0Ah)
Clear the bit to 0 to sense rising (low-to-high) edges. Set the bit to 1 to sense falling (high-to-low) edges.

4.2 STATUS Register (03h)
Bit 0:  Carry bit, C
   After addition:
   1 = A carry from bit 7 occurred
   0 = No carry from bit 7 occurred
   After subtraction:
   1 = No borrow from bit 7 occurred
   0 = A borrow from bit 7 occurred

   For rotate (RR and RL) instructions, this bit is loaded with the low or high order bit,
   respectively.


5.1 FUSE Word
The SYNC bit is not adequately explained.


5.2 FUSEX Word
Add bits 11:7: Trim2   Pins   Trim1   Trim0    BOSC 

Trim2:Trim0   Trim adjustment for internal RC oscillator. 000b = minimum frequency; 111b = maximum frequency. Each step is about 3%.

Pins on chip
   0 = 18 pins
   1 = 28 pins

BOSC    Enable the stop of oscillator by pulling OSC2 low on 8 clocks
More explanation needed.

BOR1:BOR0
   00b = brownout enabled (4.2V)
   01b = (reserved)
   10b = (reserved)
   11b = brownout disabled

MEM1:MEM0 Configured memory size on chip
   00b = 1 page (512 words)
   01b = 2 pages
   10b = 4 pages
   11b = 4 pages (default configuration)


7.0 POWER DOWN MODE
Should read: Power-down mode is entered by executing the SLEEP instruction. In power-down mode only the Watchdog Timer (WDT) is active.

There are three different ways to exit from power-down mode:

(It’s really confusing when you also refer to “power-down mode” as “SLEEP mode” and “low power sleep mode”. You might point out that the PD STATUS bit stands for “power down”.)


8.0 INTERRUPT SUPPORT
Third paragraph, second sentence should read: The WKEN_B and WKED_B registers are set to FFh upon reset.

Sixth paragraph, last sentence is: The vector for the interrupt service routine is address 0. Add: The STATUS bits PA2, PA1 and PA0 are cleared after STATUS has been saved in its shadow register.

Last paragraph, second to last sentence should read: RETIW behaves like RETI but also adds a literal to RTCC.

The following information from the Parallax SX-Key Development System Manual, Version 1.0, should be added:

Normally it is a requirement for an application to process every interrupt without missing any. To ensure this the longest path through the interrupt routine must take less time than the shortest possible delay between interrupts.

If an external interrupt occurs during the interrupt routine, the pending register will be updated but the trigger will be ignored unless interrupts are turned off at the beginning of the interrupt routine and turned on again at the end. This also requires that the new interrupt doesn’t occur before interrupts are turned off in the interrupt routine. If there is a possibility of extra interrupts occurring before they can be disabled, the SX will miss those interrupt triggers.

Using more than one interrupt, such as multiple external interrupts or both RTCC and external interrupts, can result in missed or, at best, jittery interrupt handling should one occur during the processing of another.

When handling external interrupts, the interrupt routine should clear at least one pending register bit. The bit that is cleared should represent the interrupt being handled in order for the next interrupt to trigger.


10.1 RTCC
Add: Writing to the RTCC also clears the prescaler if it is assigned to RTCC (OPTION bit PSA = 0).

Figure 10-1
Separate the MUXes in the lower-left corner. PSA should connect to both MUXes.

14.0 REGISTER STATES UPON RESET
(Trivial: “upon different resets.”)
PC (02h)  FFh FFh FFh FFh FFh
STATUS (03h) Bits 3-4: 11  etc. (show the bits)  Watchdog timeout bits 0-2: Unchanged;
 MCLR bits 0-2: Unchanged
FSR(04h) Watchdog timeout: Unchanged; MCLR: Unchanged
 Bit 7: 1 ???  (is bank 0 really selected?)
WKPND_B Power-On: Undefined (according to the text)
PRESCALER ???
NOTE (at bottom of page): Indicate that bits are in TO,PD order.

15.13 Comparison and Conditional Branch Instructions
Add second paragraph:
If a skip instruction is immediately followed by a PAGE or BANK instruction (and the tested condition is true) then two instructions are skipped and the operation consumes three cycles. This is useful for conditional branching to another page where a PAGE instruction precedes a JMP. If several PAGE and BANK instructions immediately follow a skip instruction then they are all skipped plus the next instruction and a cycle is consumed for each.

16.0 INSTRUCTION SET SUMMARY TABLE
(Trivial: Table 16-1 lists all...)
XOR fr,W: Opcode: 0001 101f ffff
CLR !WDT  Add: TO=1, PD=1, Clears prescaler if assigned
MOV W,M  Add: High nibble is cleared
RETP  Flags Affected: PA1 PA0
RETIW Return from interrupt and add RTCC to W. Restore W, STATUS, FSR, and PC from shadow registers
BANK addr12 FSR(7:5)=addr12(2:0)
PAGE addr12 STATUS(7:5)=addr12(2:0); Flags Affected: PA2 PA1 PA0
SLEEP Add: PD=0 Clear prescaler if assigned

16.1 Equivalent Assembler Mnemonics
“CLC” (clear carry), which is interpreted the same as the instruction “clrb $03.0” (clear bit 0 in the STATUS register).

Some of the commonly supported equivalent assembler mnemonics are described in Table 16-2.

Table 16-2
Under “Cycles” replace “4 or” with “2 or” in 2 places, and remove it for the SKIP instruction.
Note 1: The JMP W or JMP PC+W instruction takes 2 cycles...
Note 3: Delete the last sentence.


-------------- TRIVIAL ERRORS ----------------

3.2.1 MODE Register
Second paragraph, last sentence: Upon power-up, the MODE register is initialized to 0Fh...
It’s more precise to say: Upon reset the MODE register is initialized to 0Fh...

3.2.3 Port Configuration Upon Power-Up
It’s more precise to say: Upon Reset

Two competing notations are used to represent hex numbers. For instance, the code example in 6.2.1 File Select Register: uses both notations in a single MOV instruction. Parallax recommends the “$” while tradition uses “h”.

Figure 6-1
Parallax uses IND instead of INDF.
RTCC vs: RTCC/W

7.2 Port B MIWU/Interrupt Configuration
Second paragraph: Below is an example of how to read...

Figure 8-1
Under WKED_B box: Replace “0” with: “From MODE (mode = 0A)”

Figure 8-2
The circled numbers aren’t referred to. In two places: 0000h should be 000h.

Figure 11-1
Draw the “+” and “-” in the comparator. (RB2 is “+”)

12.0 RESET
Is it an 8-bit or 10-bit counter?

18.0 PACKAGE DIMENSIONS
Indicate that dimensions are inches / (millimeters)


