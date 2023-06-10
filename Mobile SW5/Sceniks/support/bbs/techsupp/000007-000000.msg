psychic
electron
psychtron@hotmail.com
8/14/98 4:52 PM
Generate composite color video with a scenix
options:email:psychtron@hotmail.com
HI, I am experimenting with generating composite color
video with a scenix chip. First as a video test pattern
generator, then interfacing a video A/D and DRAM to enable
video capture and image processing and compression.
Any ideas about running  scenix's in series/parallel???
Any composite video A/D circuits with sync extraction for genlocking and low power 10-20Mhz video D/A's ???
It should be possible to use a R/2R resister ladder
on 8 I/O pins if the result is monotonic enough.
Interfacing to say 1Mb DRAM should be straight forward,
use 10 I/O pins for multiplexed address, Multiplex 8 data
bits back onto 8 of these same I/O pins using DRAM OE.
Generate RAS CAS WR OE etc with more I/O pins.
What would be the fastest possible I/O burst from internal
Scenix memory??   Let's find out.  Psychic Electron


