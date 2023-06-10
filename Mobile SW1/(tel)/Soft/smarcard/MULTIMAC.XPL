; MULTIMAC.XPL allows you to update MultiMac-compatible cards
; (PIC, Deluxe etc.) without using the remote control to enter
; in new secret codes

; Version 1.1 - 31/3/98

87 02 00 00 03 R01 00 00 28 R02
87 04 00 00 07 R01 R07 R02
87 06 00 00 04 R01 R04 R02

CA A4 04 00 03 R01

; Replace the three bytes below with the PPID of the channel you
; wish to update, eg. TV1000 = 00 04 10, TV3 = 00 04 00 etc.

FF FF FF


R02

CA 88 00

; Replace the byte below with the index of the key you wish to update,
; ie. 08 - 0F for EuroCrypt-M channels, or 00 for EuroCrypt-S2 channels

FF


24 R01
;  ^^^ - we will call the value of the byte returned by this 'X'

; One of the following two sections must be uncommented (remove the
; semi-colons from the start of each line) for the script to work.
; On some cards, you will need to use the first block of data, on
; others you will need to use the second block. Only uncomment ONE
; block out of the two.

; Additionally, if you are using block 1, you will need to uncomment
; *either* sub-block 1a *or* sub-block 1b.

; BLOCK 1       ---> Uncomment this block if X = '77'

;    DF R01 00
;R01 E1 R01 04 R01 00 R01 00 R01 00 R01 00
;R01 EA R01 10 R01 00 R01 00 R01 00 R01 00 R01 00 R01 00 R01 00 R01 00
;              R01 00 R01 00 R01 00 R01 00 R01 00 R01 00 R01 00 R01 00
;R01 F0 R01 08 R01
;              ^^^ - we will call the value of this byte 'Y'

; Sub-block 1a  ---> Uncomment this block if Y = '77'

;11 R01 22 R01 33 R01 44 R01 55 R01 66 R01 77 R01 88

; Sub-block 1b  ---> Uncomment this block if Y = '88' or Y = '89'

;11 22 33 44 55 66 77 88

; BLOCK 2       ---> Uncomment this block if X = '88'

;DF 00
;E1 04 00 00 00 00
;EA 10 00 00 00 00 00 00 00 00
;      00 00 00 00 00 00 00 00
;F0 08 00 00 00 00 00 00 00 00

R02

CA C0 00 00 12
R01 R10 R02

; Enter the MultiMac codes on the lines below, replacing 8880, 8881 etc.
; with the actual MultiMac code you want to enter

CA 24 00 00 09 R01

000000000000 8880 0F R02

CA 24 00 00 09 R01

000000000000 8881 0F R02

CA 24 00 00 09 R01

000000000000 8882 0F R02

CA 24 00 00 09 R01

000000000000 8883 0F R02

CA 24 00 00 09 R01

000000000000 8884 0F R02

CA 24 00 00 09 R01

000000000000 8885 0F R02

CA 24 00 00 09 R01

000000000000 8886 0F R02


; Assuming everything has gone well, your card has now been
; successfully updated!

