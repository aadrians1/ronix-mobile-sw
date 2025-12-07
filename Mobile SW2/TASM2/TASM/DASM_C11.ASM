masm
p486
code segment use16
assume	cs:code,ds:code,es:code,ss:code,fs:code,gs:code
	org	82h
fname	db	13 dup (?)
	org	100h

begin:	jmp	main
fname1	db	'out_hc11.asm',0
handle	dw	?
handle1	dw	?
addr1	db	0
addr2	db	0
addr3	db	0
dta	db	?
dta1	db	?
len_hi	dw	0
len_lo	dw	0
hi_adr	db	0
chart	dw	?
val16	dw	0
val8	db	0
adr16	dw	0	
shift1	db	0
shift2	db	0
mess3	db	'error file$'
mess1	db	'All ok$    '
ftest	db	'test.fil',0
orec	db	?

main:	mov	cx,13
	lea	si,fname
	mov	bx,0
	lea	si,fname
l1:	mov	al,[si+bx]
	cmp	al,20h
	jz	change
	cmp	al,0dh
	jz	change
	inc	bx
	loop	L1
change:	mov	al,0
	mov	[si+bx],al
openfi:	mov	ah,3dh
	mov	al,0
	lea	dx,fname
	int	21h
	jc	err_F		;file error
	mov	handle,ax
	jmp	n_op_f
err_f:	call	close
m_er_f:	mov	ah,09
	lea	dx,mess3
	mov	cx,32
	int	21h
	ret
end_f:	call	close
	mov	ah,09
	lea	dx,mess1
	mov	cx,32
	int	21h
	ret
n_op_f:	call	crefi
cont_1:	call	read		;	\
;	cmp	ah,1
;	jz	end_f
	mov	ax,adr16
	mov	val16,ax
	call	prn16
cont_2:	mov	orec,20h
	call	rec
	mov	orec,20h
	call	rec
	mov	al,dta
	mov	val8,al
	call	prn8
	mov	orec,09h
	call	rec

a0:	cmp	dta,00h
	jnz	$+4
	jmp	m00
	cmp	dta,01h
	jnz	$+4
	jmp	m01
	cmp	dta,02h
	jnz	$+4
	jmp	m02
	cmp	dta,03h
	jnz	$+4
	jmp	m03
	cmp	dta,04h
	jnz	$+4
	jmp	m04
	cmp	dta,05h
	jnz	$+4
	jmp	m05
	cmp	dta,06h
	jnz	$+4
	jmp	m06
	cmp	dta,07h
	jnz	$+4
	jmp	m07
	cmp	dta,08h
	jnz	$+4
	jmp	m08
	cmp	dta,09h
	jnz	$+4
	jmp	m09
	cmp	dta,0ah
	jnz	$+4
	jmp	m0a
	cmp	dta,0bh
	jnz	$+4
	jmp	m0b
	cmp	dta,0ch
	jnz	$+4
	jmp	m0c
	cmp	dta,0dh
	jnz	$+4
	jmp	m0d
	cmp	dta,0eh
	jnz	$+4
	jmp	m0e
	cmp	dta,0fh
	jnz	$+4
	jmp	m0f

a1:	cmp	dta,10h
	jnz	$+4
	jmp	m10
	cmp	dta,11h
	jnz	$+4
	jmp	m11
	cmp	dta,12h
	jnz	$+4
	jmp	m12
	cmp	dta,13h
	jnz	$+4
	jmp	m13
	cmp	dta,14h
	jnz	$+4
	jmp	m14
	cmp	dta,15h
	jnz	$+4
	jmp	m15
	cmp	dta,16h
	jnz	$+4
	jmp	m16
	cmp	dta,17h
	jnz	$+4
	jmp	m17
	cmp	dta,18h
	jnz	$+4
	jmp	m18
	cmp	dta,19h
	jnz	$+4
	jmp	m19
	cmp	dta,1ah
	jnz	$+4
	jmp	m1a
	cmp	dta,1bh
	jnz	$+4
	jmp	m1b
	cmp	dta,1ch
	jnz	$+4
	jmp	m1c
	cmp	dta,1dh
	jnz	$+4
	jmp	m1d
	cmp	dta,1eh
	jnz	$+4
	jmp	m1e
	cmp	dta,1fh
	jnz	$+4
	jmp	m1f

a2:	cmp	dta,020h
	jnz	$+4
	jmp	m20
	cmp	dta,021h
	jnz	$+4
	jmp	m21
	cmp	dta,022h
	jnz	$+4
	jmp	m22
	cmp	dta,023h
	jnz	$+4
	jmp	m23
	cmp	dta,024h
	jnz	$+4
	jmp	m24
	cmp	dta,025h
	jnz	$+4
	jmp	m25
	cmp	dta,026h
	jnz	$+4
	jmp	m26
	cmp	dta,027h
	jnz	$+4
	jmp	m27
	cmp	dta,028h
	jnz	$+4
	jmp	m28
	cmp	dta,029h
	jnz	$+4
	jmp	m29
	cmp	dta,02ah
	jnz	$+4
	jmp	m2a
	cmp	dta,02bh
	jnz	$+4
	jmp	m2b
	cmp	dta,02ch
	jnz	$+4
	jmp	m2c
	cmp	dta,02dh
	jnz	$+4
	jmp	m2d
	cmp	dta,02eh
	jnz	$+4
	jmp	m2e
	cmp	dta,02fh
	jnz	$+4
	jmp	m2f

a3:	cmp	dta,030h
	jnz	$+4
	jmp	m30
	cmp	dta,031h
	jnz	$+4
	jmp	m31
	cmp	dta,032h
	jnz	$+4
	jmp	m32
	cmp	dta,033h
	jnz	$+4
	jmp	m33
	cmp	dta,034h
	jnz	$+4
	jmp	m34
	cmp	dta,035h
	jnz	$+4
	jmp	m35
	cmp	dta,036h
	jnz	$+4
	jmp	m36
	cmp	dta,037h
	jnz	$+4
	jmp	m37
	cmp	dta,038h
	jnz	$+4
	jmp	m38
	cmp	dta,039h
	jnz	$+4
	jmp	m39
	cmp	dta,03ah
	jnz	$+4
	jmp	m3a
	cmp	dta,03bh
	jnz	$+4
	jmp	m3b
	cmp	dta,03ch
	jnz	$+4
	jmp	m3c
	cmp	dta,03dh
	jnz	$+4
	jmp	m3d
	cmp	dta,03eh
	jnz	$+4
	jmp	m3e
	cmp	dta,03fh
	jnz	$+4
	jmp	m3f

a4:	cmp	dta,040h
	jnz	$+4
	jmp	m40
	cmp	dta,041h
	jnz	$+4
	jmp	m41
	cmp	dta,042h
	jnz	$+4
	jmp	m42
	cmp	dta,043h
	jnz	$+4
	jmp	m43
	cmp	dta,044h
	jnz	$+4
	jmp	m44
	cmp	dta,045h
	jnz	$+4
	jmp	m45
	cmp	dta,046h
	jnz	$+4
	jmp	m46
	cmp	dta,047h
	jnz	$+4
	jmp	m47
	cmp	dta,048h
	jnz	$+4
	jmp	m48
	cmp	dta,049h
	jnz	$+4
	jmp	m49
	cmp	dta,04ah
	jnz	$+4
	jmp	m4a
	cmp	dta,04bh
	jnz	$+4
	jmp	m4b
	cmp	dta,04ch
	jnz	$+4
	jmp	m4c
	cmp	dta,04dh
	jnz	$+4
	jmp	m4d
	cmp	dta,04eh
	jnz	$+4
	jmp	m4e
	cmp	dta,04fh
	jnz	$+4
	jmp	m4f

a5:	cmp	dta,050h
	jnz	$+4
	jmp	m50
	cmp	dta,051h
	jnz	$+4
	jmp	m51
	cmp	dta,052h
	jnz	$+4
	jmp	m52
	cmp	dta,053h
	jnz	$+4
	jmp	m53
	cmp	dta,054h
	jnz	$+4
	jmp	m54
	cmp	dta,055h
	jnz	$+4
	jmp	m55
	cmp	dta,056h
	jnz	$+4
	jmp	m56
	cmp	dta,057h
	jnz	$+4
	jmp	m57
	cmp	dta,058h
	jnz	$+4
	jmp	m58
	cmp	dta,059h
	jnz	$+4
	jmp	m59
	cmp	dta,05ah
	jnz	$+4
	jmp	m5a
	cmp	dta,05bh
	jnz	$+4
	jmp	m5b
	cmp	dta,05ch
	jnz	$+4
	jmp	m5c
	cmp	dta,05dh
	jnz	$+4
	jmp	m5d
	cmp	dta,05eh
	jnz	$+4
	jmp	m5e
	cmp	dta,05fh
	jnz	$+4
	jmp	m5f

a6:	cmp	dta,060h
	jnz	$+4
	jmp	m60
	cmp	dta,061h
	jnz	$+4
	jmp	m61
	cmp	dta,062h
	jnz	$+4
	jmp	m62
	cmp	dta,063h
	jnz	$+4
	jmp	m63
	cmp	dta,064h
	jnz	$+4
	jmp	m64
	cmp	dta,065h
	jnz	$+4
	jmp	m65
	cmp	dta,066h
	jnz	$+4
	jmp	m66
	cmp	dta,067h
	jnz	$+4
	jmp	m67
	cmp	dta,068h
	jnz	$+4
	jmp	m68
	cmp	dta,069h
	jnz	$+4
	jmp	m69
	cmp	dta,06ah
	jnz	$+4
	jmp	m6a
	cmp	dta,06bh
	jnz	$+4
	jmp	m6b
	cmp	dta,06ch
	jnz	$+4
	jmp	m6c
	cmp	dta,06dh
	jnz	$+4
	jmp	m6d
	cmp	dta,06eh
	jnz	$+4
	jmp	m6e
	cmp	dta,06fh
	jnz	$+4
	jmp	m6f

a7:	cmp	dta,070h
	jnz	$+4
	jmp	m70
	cmp	dta,071h
	jnz	$+4
	jmp	m71
	cmp	dta,072h
	jnz	$+4
	jmp	m72
	cmp	dta,073h
	jnz	$+4
	jmp	m73
	cmp	dta,074h
	jnz	$+4
	jmp	m74
	cmp	dta,075h
	jnz	$+4
	jmp	m75
	cmp	dta,076h
	jnz	$+4
	jmp	m76
	cmp	dta,077h
	jnz	$+4
	jmp	m77
	cmp	dta,078h
	jnz	$+4
	jmp	m78
	cmp	dta,079h
	jnz	$+4
	jmp	m79
	cmp	dta,07ah
	jnz	$+4
	jmp	m7a
	cmp	dta,07bh
	jnz	$+4
	jmp	m7b
	cmp	dta,07ch
	jnz	$+4
	jmp	m7c
	cmp	dta,07dh
	jnz	$+4
	jmp	m7d
	cmp	dta,07eh
	jnz	$+4
	jmp	m7e
	cmp	dta,07fh
	jnz	$+4
	jmp	m7f

a8:	cmp	dta,080h
	jnz	$+4
	jmp	m80
	cmp	dta,081h
	jnz	$+4
	jmp	m81
	cmp	dta,082h
	jnz	$+4
	jmp	m82
	cmp	dta,083h
	jnz	$+4
	jmp	m83
	cmp	dta,084h
	jnz	$+4
	jmp	m84
	cmp	dta,085h
	jnz	$+4
	jmp	m85
	cmp	dta,086h
	jnz	$+4
	jmp	m86
	cmp	dta,087h
	jnz	$+4
	jmp	m87
	cmp	dta,088h
	jnz	$+4
	jmp	m88
	cmp	dta,089h
	jnz	$+4
	jmp	m89
	cmp	dta,08ah
	jnz	$+4
	jmp	m8a
	cmp	dta,08bh
	jnz	$+4
	jmp	m8b
	cmp	dta,08ch
	jnz	$+4
	jmp	m8c
	cmp	dta,08dh
	jnz	$+4
	jmp	m8d
	cmp	dta,08eh
	jnz	$+4
	jmp	m8e
	cmp	dta,08fh
	jnz	$+4
	jmp	m8f

a9:	cmp	dta,090h
	jnz	$+4
	jmp	m90
	cmp	dta,091h
	jnz	$+4
	jmp	m91
	cmp	dta,092h
	jnz	$+4
	jmp	m92
	cmp	dta,093h
	jnz	$+4
	jmp	m93
	cmp	dta,094h
	jnz	$+4
	jmp	m94
	cmp	dta,095h
	jnz	$+4
	jmp	m95
	cmp	dta,096h
	jnz	$+4
	jmp	m96
	cmp	dta,097h
	jnz	$+4
	jmp	m97
	cmp	dta,098h
	jnz	$+4
	jmp	m98
	cmp	dta,099h
	jnz	$+4
	jmp	m99
	cmp	dta,09ah
	jnz	$+4
	jmp	m9a
	cmp	dta,09bh
	jnz	$+4
	jmp	m9b
	cmp	dta,09ch
	jnz	$+4
	jmp	m9c
	cmp	dta,09dh
	jnz	$+4
	jmp	m9d
	cmp	dta,09eh
	jnz	$+4
	jmp	m9e
	cmp	dta,09fh
	jnz	$+4
	jmp	m9f

aa:	cmp	dta,0A0h
	jnz	$+4
	jmp	mA0
	cmp	dta,0A1h
	jnz	$+4
	jmp	mA1
	cmp	dta,0A2h
	jnz	$+4
	jmp	mA2
	cmp	dta,0A3h
	jnz	$+4
	jmp	mA3
	cmp	dta,0A4h
	jnz	$+4
	jmp	mA4
	cmp	dta,0A5h
	jnz	$+4
	jmp	mA5
	cmp	dta,0A6h
	jnz	$+4
	jmp	mA6
	cmp	dta,0A7h
	jnz	$+4
	jmp	mA7
	cmp	dta,0A8h
	jnz	$+4
	jmp	mA8
	cmp	dta,0A9h
	jnz	$+4
	jmp	mA9
	cmp	dta,0Aah
	jnz	$+4
	jmp	mAa
	cmp	dta,0Abh
	jnz	$+4
	jmp	mab
	cmp	dta,0Ach
	jnz	$+4
	jmp	mac
	cmp	dta,0Adh
	jnz	$+4
	jmp	mad
	cmp	dta,0Aeh
	jnz	$+4
	jmp	mae
	cmp	dta,0Afh
	jnz	$+4
	jmp	maf

ab:	cmp	dta,0b0h
	jnz	$+4
	jmp	mb0
	cmp	dta,0b1h
	jnz	$+4
	jmp	mb1
	cmp	dta,0b2h
	jnz	$+4
	jmp	mb2
	cmp	dta,0b3h
	jnz	$+4
	jmp	mb3
	cmp	dta,0b4h
	jnz	$+4
	jmp	mb4
	cmp	dta,0b5h
	jnz	$+4
	jmp	mb5
	cmp	dta,0b6h
	jnz	$+4
	jmp	mb6
	cmp	dta,0b7h
	jnz	$+4
	jmp	mb7
	cmp	dta,0b8h
	jnz	$+4
	jmp	mb8
	cmp	dta,0b9h
	jnz	$+4
	jmp	mb9
	cmp	dta,0bah
	jnz	$+4
	jmp	mba
	cmp	dta,0bbh
	jnz	$+4
	jmp	mbb
	cmp	dta,0bch
	jnz	$+4
	jmp	mbc
	cmp	dta,0bdh
	jnz	$+4
	jmp	mbd
	cmp	dta,0beh
	jnz	$+4
	jmp	mbe
	cmp	dta,0bfh
	jnz	$+4
	jmp	mbf

ac:	cmp	dta,0c0h
	jnz	$+4
	jmp	mc0
	cmp	dta,0c1h
	jnz	$+4
	jmp	mc1
	cmp	dta,0c2h
	jnz	$+4
	jmp	mc2
	cmp	dta,0c3h
	jnz	$+4
	jmp	mc3
	cmp	dta,0c4h
	jnz	$+4
	jmp	mc4
	cmp	dta,0c5h
	jnz	$+4
	jmp	mc5
	cmp	dta,0c6h
	jnz	$+4
	jmp	mc6
	cmp	dta,0c7h
	jnz	$+4
	jmp	mc7
	cmp	dta,0c8h
	jnz	$+4
	jmp	mc8
	cmp	dta,0c9h
	jnz	$+4
	jmp	mc9
	cmp	dta,0cah
	jnz	$+4
	jmp	mca
	cmp	dta,0cbh
	jnz	$+4
	jmp	mcb
	cmp	dta,0cch
	jnz	$+4
	jmp	mcc
	cmp	dta,0cdh
	jnz	$+4
	jmp	mcd
	cmp	dta,0ceh
	jnz	$+4
	jmp	mce
	cmp	dta,0cfh
	jnz	$+4
	jmp	mcf

ad:	cmp	dta,0d0h
	jnz	$+4
	jmp	md0
	cmp	dta,0d1h
	jnz	$+4
	jmp	md1
	cmp	dta,0d2h
	jnz	$+4
	jmp	md2
	cmp	dta,0d3h
	jnz	$+4
	jmp	md3
	cmp	dta,0d4h
	jnz	$+4
	jmp	md4
	cmp	dta,0d5h
	jnz	$+4
	jmp	md5
	cmp	dta,0d6h
	jnz	$+4
	jmp	md6
	cmp	dta,0d7h
	jnz	$+4
	jmp	md7
	cmp	dta,0d8h
	jnz	$+4
	jmp	md8
	cmp	dta,0d9h
	jnz	$+4
	jmp	md9
	cmp	dta,0dah
	jnz	$+4
	jmp	mda
	cmp	dta,0dbh
	jnz	$+4
	jmp	mdb
	cmp	dta,0dch
	jnz	$+4
	jmp	mdc
	cmp	dta,0ddh
	jnz	$+4
	jmp	mdd
	cmp	dta,0deh
	jnz	$+4
	jmp	mde
	cmp	dta,0dfh
	jnz	$+4
	jmp	mdf

ae:	cmp	dta,0e0h
	jnz	$+4
	jmp	me0
	cmp	dta,0e1h
	jnz	$+4
	jmp	me1
	cmp	dta,0e2h
	jnz	$+4
	jmp	me2
	cmp	dta,0e3h
	jnz	$+4
	jmp	me3
	cmp	dta,0e4h
	jnz	$+4
	jmp	me4
	cmp	dta,0e5h
	jnz	$+4
	jmp	me5
	cmp	dta,0e6h
	jnz	$+4
	jmp	me6
	cmp	dta,0e7h
	jnz	$+4
	jmp	me7
	cmp	dta,0e8h
	jnz	$+4
	jmp	me8
	cmp	dta,0e9h
	jnz	$+4
	jmp	me9
	cmp	dta,0eah
	jnz	$+4
	jmp	mea
	cmp	dta,0ebh
	jnz	$+4
	jmp	meb
	cmp	dta,0ech
	jnz	$+4
	jmp	mec
	cmp	dta,0edh
	jnz	$+4
	jmp	med
	cmp	dta,0eeh
	jnz	$+4
	jmp	mee
	cmp	dta,0efh
	jnz	$+4
	jmp	mef

af:	cmp	dta,0f0h
	jnz	$+4
	jmp	mf0
	cmp	dta,0f1h
	jnz	$+4
	jmp	mf1
	cmp	dta,0f2h
	jnz	$+4
	jmp	mf2
	cmp	dta,0f3h
	jnz	$+4
	jmp	mf3
	cmp	dta,0f4h
	jnz	$+4
	jmp	mf4
	cmp	dta,0f5h
	jnz	$+4
	jmp	mf5
	cmp	dta,0f6h
	jnz	$+4
	jmp	mf6
	cmp	dta,0f7h
	jnz	$+4
	jmp	mf7
	cmp	dta,0f8h
	jnz	$+4
	jmp	mf8
	cmp	dta,0f9h
	jnz	$+4
	jmp	mf9
	cmp	dta,0fah
	jnz	$+4
	jmp	mfa
	cmp	dta,0fbh
	jnz	$+4
	jmp	mfb
	cmp	dta,0fch
	jnz	$+4
	jmp	mfc
	cmp	dta,0fdh
	jnz	$+4
	jmp	mfd
	cmp	dta,0feh
	jnz	$+4
	jmp	mfe
;	cmp	dta,0ffh
;	jnz	$+4
;	jmp	mff
;#1
m00:	lea	dx,c00	;test
	call	rec5
	call	nextb		
	jmp	enco
m01:	lea	dx,c01	;nop
	call	rec5
	call	nextb		
	jmp	enco
m02:	lea	dx,c02	;idiv
	call	rec5
	call	nextb		
	jmp	enco
m03:	lea	dx,c03	;fdiv
	call	rec5
	call	nextb		
	jmp	enco
m04:	lea	dx,c04	;lsrd
	call	rec5
	call	nextb		
	jmp	enco
m05:	lea	dx,c05	;lsld
	call	rec5
	call	nextb		
	jmp	enco
m06:	lea	dx,c06	;tap
	call	rec5
	call	nextb		
	jmp	enco
m07:	lea	dx,c07	;tpa
	call	rec5
	call	nextb		
	jmp	enco
m08:	cmp	shift2,1
	jz	m081
	lea	dx,c08	;inx(y)
	call	rec5
	call	nextb		
	jmp	enco
m081:	lea	dx,c081	;iny
	call	rec5
	call	nextb		
	jmp	enco

m09:	lea	dx,c09	;dex
	call	rec5
	call	nextb		
	jmp	enco
m0a:	lea	dx,c0a	;clv
	call	rec5
	call	nextb		
	jmp	enco
m0b:	lea	dx,c0b	;sev
	call	rec5
	call	nextb		
	jmp	enco
m0c:	lea	dx,c0c	;clc
	call	rec5
	call	nextb		
	jmp	enco
m0d:	lea	dx,c0d	;sec
	call	rec5
	call	nextb		
	jmp	enco
m0e:	lea	dx,c0e	;cli
	call	rec5
	call	nextb		
	jmp	enco
m0f:	lea	dx,c0f	;sei
	call	rec5
	call	nextb		
	jmp	enco
m10:	lea	dx,c10	;sba
	call	rec5
	call	nextb		
	jmp	enco
m11:	lea	dx,c11	;cba
	call	rec5
	call	nextb		
	jmp	enco
m12:	lea	dx,c12	;brset
	call	rec5
	call	p8a
	call	prob
	call	p8d
	call	prob
	call	p8s
	call	nextb		
	jmp	enco
m13:	lea	dx,c13	;brclr
	call	rec5
	call	p8a
	call	prob
	call	p8d
	call	prob
	call	p8s
	call	nextb		
	jmp	enco
m14:	lea	dx,c14	;bset
	call	rec5
	call	p8a
	call	prob
	call	p8d
	call	nextb		
	jmp	enco
m15:	lea	dx,c15	;bclr
	call	rec5
	call	p8a
	call	prob
	call	p8d
	call	nextb		
	jmp	enco
m16:	lea	dx,c16	;tab
	call	rec5
	call	nextb		
	jmp	enco
m17:	lea	dx,c17	;tba
	call	rec5
	call	nextb		
	jmp	enco
m18:	jmp	paje2
m19:	lea	dx,c19	;daa
	call	rec5
	call	nextb		
	jmp	enco
m1a:	jmp	paje3
m1b:	lea	dx,c1b	;aba
	call	rec5
	call	nextb		
	jmp	enco
m1c:	lea	dx,c1c	;bset
	call	rec5
	call	p8a
	call	xprob	;(--),x
	call	p8d
	call	nextb		
	jmp	enco
m1d:	lea	dx,c1d	;bclr
	call	rec5
	call	p8a
	call	xprob	;(--),x
	call	p8d
	call	nextb		
	jmp	enco
m1e:	lea	dx,c1e	;brset
	call	rec5
	call	p8a
	call	xprob
	call	p8d
	call	prob
	call	p8s
	call	nextb		
	jmp	enco
m1f:	lea	dx,c1f	;brclr
	call	rec5
	call	p8a
	call	xprob
	call	p8d
	call	prob
	call	p8s
	call	nextb		
	jmp	enco
m20:	lea	dx,c20	;bra	
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m21:	lea	dx,c21	;brn	
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m22:	lea	dx,c22	;bhi	
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m23:	lea	dx,c23	;bls
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m24:	lea	dx,c24	;bcc	
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m25:	lea	dx,c25	;bcs
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m26:	lea	dx,c26	;bne
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m27:	lea	dx,c27	;beq
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m28:	lea	dx,c28	;bvc	
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m29:	lea	dx,c29	;bvs
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m2a:	lea	dx,c2a	;bpl
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m2b:	lea	dx,c2b	;bmi
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m2c:	lea	dx,c2c	;bge
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m2d:	lea	dx,c2d	;blt
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m2e:	lea	dx,c2e	;bgt
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco
m2f:	lea	dx,c2f	;ble
	call	rec5
	call	p8s
	call	nextb		
	jmp	enco

m30:	cmp	shift2,1
	jz	m301
	lea	dx,c30	;tsx(y)
	call	rec5
	call	nextb		
	jmp	enco
m301:	lea	dx,c301	;tsy
	call	rec5
	call	nextb		
	jmp	enco

m31:	lea	dx,c31	;ins
	call	rec5
	call	nextb		
	jmp	enco
m32:	lea	dx,c32	;pula
	call	rec5
	call	nextb		
	jmp	enco
m33:	lea	dx,c33	;pulb
	call	rec5
	call	nextb		
	jmp	enco
m34:	lea	dx,c34	;des
	call	rec5
	call	nextb		
	jmp	enco
m35:	cmp	shift2,1
	jz	m351
	lea	dx,c35	;tx(y)s
	call	rec5
	call	nextb		
	jmp	enco
m351:	lea	dx,c351	;tys
	call	rec5
	call	nextb		
	jmp	enco

m36:	lea	dx,c36	;psha
	call	rec5
	call	nextb		
	jmp	enco
m37:	lea	dx,c37	;pshb
	call	rec5
	call	nextb		
	jmp	enco
m38:	cmp	shift2,1
	jz	m381
	lea	dx,c38	;pulx
	call	rec5
	call	nextb		
	jmp	enco
m381:	lea	dx,c381	;puly
	call	rec5
	call	nextb		
	jmp	enco
m39:	lea	dx,c39	;rts
	call	rec5
	call	nextb		
	jmp	enco
m3a:	cmp	shift2,1
	jz	m3a1
	lea	dx,c3a	;abx(y)
	call	rec5
	call	nextb		
	jmp	enco
m3a1:	lea	dx,c3a1	;aby
	call	rec5
	call	nextb		
	jmp	enco

m3b:	lea	dx,c3b	;rti
	call	rec5
	call	nextb		
	jmp	enco
m3c:	cmp	shift2,1
	jz	m3c1
	lea	dx,c3c	;pshx(y)
	call	rec5
	call	nextb		
	jmp	enco
m3c1:	lea	dx,c3c1	;pshy
	call	rec5
	call	nextb		
	jmp	enco

m3d:	lea	dx,c3d	;mul
	call	rec5
	call	nextb		
	jmp	enco
m3e:	lea	dx,c3e	;wai
	call	rec5
	call	nextb		
	jmp	enco
m3f:	lea	dx,c3f	;swi
	call	rec5
	call	nextb		
	jmp	enco
m40:	lea	dx,c40	;nega
	call	rec5
	call	nextb		
	jmp	enco
m41:	lea	dx,c00a	;(na)
	call	rec5
	call	nextb		
	jmp	enco
m42:	lea	dx,c00a	;(na)
	call	rec5
	call	nextb		
	jmp	enco
m43:	lea	dx,c43	;coma
	call	rec5
	call	nextb		
	jmp	enco
m44:	lea	dx,c44	;lsra
	call	rec5
	call	nextb		
	jmp	enco
m45:	lea	dx,c00a	;(na)
	call	rec5
	call	nextb		
	jmp	enco
m46:	lea	dx,c46	;rora
	call	rec5
	call	nextb		
	jmp	enco
m47:	lea	dx,c47	;asra
	call	rec5
	call	nextb		
	jmp	enco
m48:	lea	dx,c48	;asla
	call	rec5
	call	nextb		
	jmp	enco
m49:	lea	dx,c49	;rola
	call	rec5
	call	nextb		
	jmp	enco
m4a:	lea	dx,c4a	;deca
	call	rec5
	call	nextb		
	jmp	enco
m4b:	lea	dx,c00a	;(na)
	call	rec5
	call	nextb		
	jmp	enco
m4c:	lea	dx,c4c	;inca
	call	rec5
	call	nextb		
	jmp	enco
m4d:	lea	dx,c4d	;tsta
	call	rec5
	call	nextb		
	jmp	enco
m4e:	lea	dx,c00a	;(na)
	call	rec5
	call	nextb		
	jmp	enco
m4f:	lea	dx,c4f	;clra
	call	rec5
	call	nextb		
	jmp	enco

m50:	lea	dx,c50	;negb
	call	rec5
	call	nextb		
	jmp	enco
m51:	lea	dx,c00a	;(na)
	call	rec5
	call	nextb		
	jmp	enco
m52:	lea	dx,c00a	;(na)
	call	rec5
	call	nextb		
	jmp	enco
m53:	lea	dx,c53	;comb
	call	rec5
	call	nextb		
	jmp	enco
m54:	lea	dx,c54	;lsrb
	call	rec5
	call	nextb		
	jmp	enco
m55:	lea	dx,c00a	;(na)
	call	rec5
	call	nextb		
	jmp	enco
m56:	lea	dx,c56	;rorb
	call	rec5
	call	nextb		
	jmp	enco
m57:	lea	dx,c57	;asrb
	call	rec5
	call	nextb		
	jmp	enco
m58:	lea	dx,c58	;aslb
	call	rec5
	call	nextb		
	jmp	enco
m59:	lea	dx,c59	;rolb
	call	rec5
	call	nextb		
	jmp	enco
m5a:	lea	dx,c5a	;decb
	call	rec5
	call	nextb		
	jmp	enco
m5b:	lea	dx,c00a	;(na)
	call	rec5
	call	nextb		
	jmp	enco
m5c:	lea	dx,c5c	;incb
	call	rec5
	call	nextb		
	jmp	enco
m5d:	lea	dx,c5d	;tstb
	call	rec5
	call	nextb		
	jmp	enco
m5e:	lea	dx,c00a	;(na)
	call	rec5
	call	nextb		
	jmp	enco
m5f:	lea	dx,c5f	;clrb
	call	rec5
	call	nextb		
	jmp	enco

m60:	lea	dx,c60	;neg	
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
m61:	lea	dx,c61	;---	
	call	rec5
	call	nextb		
	jmp	enco
m62:	lea	dx,c62	;---	
	call	rec5
	call	nextb		
	jmp	enco
m63:	lea	dx,c63	;com
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
m64:	lea	dx,c64	;lsr	
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
m65:	lea	dx,c65	;---
	call	rec5
	call	nextb		
	jmp	enco
m66:	lea	dx,c66	;ror
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
m67:	lea	dx,c67	;asr
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
m68:	lea	dx,c68	;asl
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
m69:	lea	dx,c69	;rol
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
m6a:	lea	dx,c6a	;dec
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
m6b:	lea	dx,c6b	;---
	call	rec5
	call	nextb		
	jmp	enco
m6c:	lea	dx,c6c	;inc
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
m6d:	lea	dx,c6d	;tst
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
m6e:	lea	dx,c6e	;jmp
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
m6f:	lea	dx,c6f	;clr
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco

m70:	lea	dx,c70	;neg	
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
m71:	lea	dx,c71	;---	
	call	rec5
	call	nextb		
	jmp	enco
m72:	lea	dx,c72	;---	
	call	rec5
	call	nextb		
	jmp	enco
m73:	lea	dx,c73	;com
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
m74:	lea	dx,c74	;lsr	
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
m75:	lea	dx,c75	;---
	call	rec5
	call	nextb		
	jmp	enco
m76:	lea	dx,c76	;ror
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
m77:	lea	dx,c77	;asr
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
m78:	lea	dx,c78	;asl
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
m79:	lea	dx,c79	;rol
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
m7a:	lea	dx,c7a	;dec
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
m7b:	lea	dx,c7b	;---
	call	rec5
	call	nextb		
	jmp	enco
m7c:	lea	dx,c7c	;inc
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
m7d:	lea	dx,c7d	;tst
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
m7e:	lea	dx,c7e	;jmp
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
m7f:	lea	dx,c7f	;clr
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco

m80:	lea	dx,c80	;suba
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
m81:	lea	dx,c81	;cmpa
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
m82:	lea	dx,c82	;sbca
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
m83:	lea	dx,c83	;subd
	call	rec5
	call	p16d
	call	nextb		
	jmp	enco
m84:	lea	dx,c84	;anda
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
m85:	lea	dx,c85	;bita
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
m86:	lea	dx,c86	;ldaa
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
m87:	lea	dx,c87	;---
	call	rec5
	call	nextb		
	jmp	enco
m88:	lea	dx,c88	;eora
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
m89:	lea	dx,c89	;adca
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
m8a:	lea	dx,c8a	;oraa
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
m8b:	lea	dx,c8b	;adda
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
m8c:	cmp	shift2,1
	jz	m8c1
	lea	dx,c8c	;cpx(y)
	call	rec5
	call	p16d
	call	nextb		
	jmp	enco
m8c1:	lea	dx,c8c1	;cpy
	call	rec5
	call	p16d
	call	nextb		
	jmp	enco

m8d:	lea	dx,c8d	;bsr
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
m8e:	lea	dx,c8e	;lds
	call	rec5
	call	p16d
	call	nextb		
	jmp	enco
m8f:	cmp	shift2,1
	jz	m8f1
	lea	dx,c8f	;xgdx(y)
	call	rec5
	call	nextb		
	jmp	enco
m8f1:	lea	dx,c8f1	;xgdy
	call	rec5
	call	nextb		
	jmp	enco

m90:	lea	dx,c90	;suba
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m91:	lea	dx,c91	;cmpa
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m92:	lea	dx,c92	;sbca
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m93:	lea	dx,c93	;subd
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m94:	lea	dx,c94	;anda
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m95:	lea	dx,c95	;bita
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m96:	lea	dx,c96	;ldaa
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m97:	lea	dx,c97	;staa
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m98:	lea	dx,c98	;eora
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m99:	lea	dx,c99	;adca
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m9a:	lea	dx,c9a	;oraa
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m9b:	lea	dx,c9b	;adda
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m9c:	cmp	shift2,1
	jz	m9c1
	lea	dx,c9c	;cpx(y)
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m9c1:	lea	dx,c9c1	;cpy
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco

m9d:	lea	dx,c9d	;jsr
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m9e:	lea	dx,c9e	;lds
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
m9f:	lea	dx,c9f	;sts
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco

ma0:	lea	dx,ca0	;suba
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
ma1:	lea	dx,ca1	;cmpa
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
ma2:	lea	dx,ca2	;sbca
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
ma3:	lea	dx,ca3	;subd
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
ma4:	lea	dx,ca4	;anda
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
ma5:	lea	dx,ca5	;bita
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
ma6:	lea	dx,ca6	;ldaa
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
ma7:	lea	dx,ca6	;staa
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
ma8:	lea	dx,ca8	;eora
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
ma9:	lea	dx,ca9	;adca
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
maa:	lea	dx,caa	;oraa
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mab:	lea	dx,cab	;adda
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mac:	cmp	shift2,1
	jz	mac1
	lea	dx,cac	;cpx(y)
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mac1:	lea	dx,cac1	;cpy
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco

mad:	lea	dx,cad	;jsr
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mae:	lea	dx,cae	;lds
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
maf:	lea	dx,caf	;sts
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco

mb0:	lea	dx,cb0	;suba
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mb1:	lea	dx,cb1	;cmpa
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mb2:	lea	dx,cb2	;sbca
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mb3:	lea	dx,cb3	;subd
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mb4:	lea	dx,cb4	;anda
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mb5:	lea	dx,cb5	;bita
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mb6:	lea	dx,cb6	;ldaa
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mb7:	lea	dx,cb6	;staa
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mb8:	lea	dx,cb8	;eora
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mb9:	lea	dx,cb9	;adca
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mba:	lea	dx,cba	;oraa
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mbb:	lea	dx,cbb	;adda
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mbc:	cmp	shift2,1
	jz	mbc1
	lea	dx,cbc	;cpx(y)
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mbc1:	lea	dx,cbc1	;cpy
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco

mbd:	lea	dx,cbd	;jsr
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mbe:	lea	dx,cbe	;lds
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco
mbf:	lea	dx,cbf	;sts
	call	rec5
	call	p16a
	call	nextb		
	jmp	enco

mc0:	lea	dx,cc0	;subb
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
mc1:	lea	dx,cc1	;cmpb
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
mc2:	lea	dx,cc2	;sbcb
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
mc3:	lea	dx,cc3	;addd
	call	rec5
	call	p16d
	call	nextb		
	jmp	enco
mc4:	lea	dx,cc4	;andb
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
mc5:	lea	dx,cc5	;bitb
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
mc6:	lea	dx,cc6	;ldbb
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
mc7:	lea	dx,cc7	;---
	call	rec5
	call	nextb		
	jmp	enco
mc8:	lea	dx,cc8	;eorb
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
mc9:	lea	dx,cc9	;adcb
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
mca:	lea	dx,cca	;orab
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
mcb:	lea	dx,ccb	;addb
	call	rec5
	call	p8d
	call	nextb		
	jmp	enco
mcc:	lea	dx,ccc	;ldd
	call	rec5
	call	p16d
	call	nextb		
	jmp	enco
mcd:	lea	dx,ccd	;				---------paje 4
	call	rec5
	call	p8d
	call	nextb		
	jmp	paje4
mce:	cmp	shift2,1
	jz	mce1
	lea	dx,cce	;ldx(y)
	call	rec5
	call	p16d
	call	nextb		
	jmp	enco
mce1:	lea	dx,cce1	;ldy
	call	rec5
	call	p16d
	call	nextb		
	jmp	enco

mcf:	lea	dx,ccf	;stop
	call	rec5
	call	nextb		
	jmp	enco

md0:	lea	dx,cd0	;subb
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
md1:	lea	dx,cd1	;cmpb
	call	rec5
	call	p8a
	call	nextb	
	jmp	enco
md2:	lea	dx,cd2	;sbcb
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
md3:	lea	dx,cd3	;addd
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
md4:	lea	dx,cd4	;andb
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
md5:	lea	dx,cd5	;bitb
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
md6:	lea	dx,cd6	;ldbb
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
md7:	lea	dx,cd7	;stbb
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
md8:	lea	dx,cd8	;eorb
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
md9:	lea	dx,cd9	;adcb
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
mda:	lea	dx,cda	;orab
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
mdb:	lea	dx,cdb	;addb
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
mdc:	lea	dx,cdc	;ldd
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
mdd:	lea	dx,cdd	;std
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
mde:	cmp	shift2,1
	jz	mde1
	lea	dx,cde	;ldx(y)
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
mde1:	lea	dx,cde1	;ldy
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
mdf:	cmp	shift2,1
	jz	mdf1
	lea	dx,cdf	;stx(y)
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco
mdf1:	lea	dx,cdf1	;sty
	call	rec5
	call	p8a
	call	nextb		
	jmp	enco

me0:	lea	dx,ce0	;subb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
me1:	lea	dx,ce1	;cmpb
	call	rec5
	call	p8a
	call	xprob
	call	nextb	
	jmp	enco
me2:	lea	dx,ce2	;sbcb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
me3:	lea	dx,ce3	;addd
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
me4:	lea	dx,ce4	;andb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
me5:	lea	dx,ce5	;bitb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
me6:	lea	dx,ce6	;ldbb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
me7:	lea	dx,ce7	;stbb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
me8:	lea	dx,ce8	;eorb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
me9:	lea	dx,ce9	;adcb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mea:	lea	dx,cea	;orab
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
meb:	lea	dx,ceb	;addb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mec:	lea	dx,cec	;ldd
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
med:	lea	dx,ced	;std
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mee:	cmp	shift2,1
	jz	mee1
	lea	dx,cee	;ldx(y)
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mee1:	lea	dx,cee1	;ldy
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mef:	cmp	shift2,1
	jz	mef1
	lea	dx,cef	;stx(y)
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mef1:	lea	dx,cef1	;sty
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco

mf0:	lea	dx,cf0	;subb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mf1:	lea	dx,cf1	;cmpb
	call	rec5
	call	p8a
	call	xprob
	call	nextb	
	jmp	enco
mf2:	lea	dx,cf2	;sbcb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mf3:	lea	dx,cf3	;addd
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mf4:	lea	dx,cf4	;andb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mf5:	lea	dx,cf5	;bitb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mf6:	lea	dx,cf6	;ldbb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mf7:	lea	dx,cf7	;stbb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mf8:	lea	dx,cf8	;eorb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mf9:	lea	dx,cf9	;adcb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mfa:	lea	dx,cfa	;orab
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mfb:	lea	dx,cfb	;addb
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mfc:	lea	dx,cfc	;ldd
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mfd:	lea	dx,cfd	;std
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mfe:	cmp	shift2,1
	jz	mfe1
	lea	dx,cfe	;ldx(y)
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mfe1:	lea	dx,cfe1	;ldy
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mff:	cmp	shift2,1
	jz	mff1
	lea	dx,cff	;stx(y)
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
mff1:	lea	dx,cff1	;sty
	call	rec5
	call	p8a
	call	xprob
	call	nextb		
	jmp	enco
;%
enco:	inc	adr16
	mov	shift1,0
	mov	shift2,0
	cmp	adr16,10h
	jz	end_f_
	jmp	cont_1
end_f_:	jmp	end_f

paje2:	call	read		;cod 18
	inc	adr16
	mov	shift1,1	;IND,Y
	mov	shift2,1	;CMP(Y)
	jmp	a0

paje3:	call	read		;cod 1A
	inc	adr16
	mov	shift2,1	;CMP(Y)
	jmp	a0

paje4:	call	read		;cod CD
	inc	adr16
	mov	shift1,1	;IND,Y
	jmp	a0

;		*** close file ***
;		------------------

close:	mov	ah,3eh		
	mov	bx,handle 
	int	21h	
	mov	ah,3eh
	mov	bx,handle1
	int	21h
	ret


;		*** open file ***
;		-----------------

open:	mov	ah,3dh
	mov	al,0
	lea	dx,fname
	int	21h
	mov	handle,ax
	ret

;		*** read file ***
;		-----------------

read:	mov	ah,3fh
	mov	bx,handle
	mov	cx,1
	lea	dx,dta
	int	21h
	jc	read_e
	mov	ah,0
	ret
read_e:	mov	ah,1
	ret

;		*** created file ***
;		--------------------

crefi:	mov	ah,3ch
	mov	cx,00
	lea	dx,fname1
	int	21h
	mov	handle1,ax
	ret

;		*** rec file ***
;		----------------
	
rec:	mov	ah,40h
	mov	bx,handle1
	mov	cx,1
	lea	dx,orec
	int	21h
	ret

;		*** rec file 5 bytes ***
;		------------------------
	rec5:	mov	ah,40h
	mov	bx,handle1
	mov	cx,5
;	lea	dx,orec
	int	21h
	ret

prob:	mov	orec,' '
	call	rec
	ret

xprob:	mov	orec,','
	call	rec
	cmp	shift1,1
	jz	x_prob
	mov	orec,'X'
	call	rec
	mov	orec,' '
	call	rec
	ret
x_prob:	mov	orec,'Y'
	call	rec
	mov	orec,' '
	call	rec
	ret

nextb:	mov	orec,0ah
	call	rec
	mov	orec,0dh
	call	rec
	ret

p16d:	mov	orec,23h	;#
	call	rec
p16a:	mov	orec,24h	;$
	call	rec
	call	read
	inc	adr16
	mov	al,dta
	mov	val8,al
	call	read
	inc	adr16
	mov	ah,val8
	mov	al,dta
	mov	val16,ax
	call	prn16
	ret

p8d:	mov	orec,23h	;#
	call	rec
p8a:	mov	orec,24h	;$
	call	rec
	call	read
	inc	adr16
	mov	al,dta
	mov	val8,al
	call	prn8
	ret

p8s:	mov	orec,12h	;
	call	rec
	call	read
	inc	adr16
	mov	al,dta
	mov	val8,al
	call	prn8
	ret


;-------------------------------
prn16:	mov	ax,val16
	shr	ax,12	 
	call	meta_
	mov	ax,val16
	shr	ax,8	 
	call	meta_
	mov	ax,val16	;save 16 bit value
	shr	ax,4
	call	meta_
	mov	ax,val16
	call	meta_
	ret

prn8:	mov	al,val8		;save 8 bit value
	shr	al,4
	call	meta_
	mov	al,val8
	call	meta_
	ret

meta_:	and	al,0fh
	cmp	al,9
	jle	digit_
	add	al,7
digit_:	add	al,30h
	mov	orec,al
	call	rec
	ret	


c00	db	'TEST '
c01	db	'NOP  '
c02	db	'IDIV '
c03	db	'FDIV '
c04	db	'LSRD '
c05	db	'ASLD '
c06	db	'TAP  '
c07	db	'TPA  '
c08	db	'INX  '
c081	db	'INY  '
c09	db	'DEX  '
c0A	db	'CLV  '
c0B	db	'SEV  '
c0C	db	'CLC  '
c0D	db	'SEC  '
c0E	db	'CLI  '
c0F	db	'SEI  '
c10	db	'SBA  '
c11	db	'CBA  '
c12	db	'BRSET'
c13	db	'BRCLR'
c14	db	'BSET '
c15	db	'BCLR '
c16	db	'TAB  '
c17	db	'TBA  '
c18	db	'P 2  '
c19	db	'DAA  '
c1a	db	'P 3  '
c1b	db	'ABA  '
c1c	db	'BSET '
c1d	db	'BCLR '
c1e	db	'BRSET'
c1f	db	'BRCLR'
c20	db	'BRA  '
c21	db	'BRN  '
c22	db	'BHI  '
c23	db	'BLS  '
c24	db	'BCC  '
c25	db	'BCS  '
c26	db	'BNE  '
c27	db	'BEQ  '
c28	db	'BVC  '
c29	db	'BVS  '
c2a	db	'BPL  '
c2b	db	'BMI  '
c2c	db	'BGE  '
c2d	db	'BLT  '
c2e	db	'BGT  '
c2f	db	'BLE  '
c30	db	'TSX  '
c301	db	'TSY  '
c31	db	'INS  '
c32	db	'PULA '
c33	db	'PULB '
c34	db	'DES  '
c35	db	'TXS  '
c351	db	'TYS  '
c36	db	'PSHA '
c37	db	'PSHB '
c38	db	'PULX '
c381	db	'PULY '
c39	db	'RTS  '
c3a	db	'ABX  '
c3a1	db	'ABY  '
c3b	db	'RTI  '
c3c	db	'PSHX '
c3c1	db	'PSHY '
c3d	db	'MUL  '
c3e	db	'WAI  '
c3f	db	'SWI  '
c40	db	'NEGA '
c41	db	'-----'
c42	db	'-----'
c43	db	'COMA '
c44	db	'LSRA '
c45	db	'-----'
c46	db	'RORA '
c47	db	'ASRA '
c48	db	'ASLA '
c49	db	'ROLA '
c4a	db	'DECA '
c4b	db	'-----'
c4c	db	'INCA '
c4d	db	'TSTA '
c4e	db	'-----'
c4f	db	'CLRA '
c50	db	'NEGB '
c51	db	'-----'
c52	db	'-----'
c53	db	'COMB '
c54	db	'LSRB '
c55	db	'-----'
c56	db	'RORB '
c57	db	'ASRB '
c58	db	'ASLB '
c59	db	'ROLB '
c5a	db	'DECB '
c5b	db	'-----'
c5c	db	'INCB '
c5d	db	'TSTB '
c5e	db	'-----'
c5f	db	'CLRB '

c60	db	'NEG  '
c61	db	'-----'
c62	db	'-----'
c63	db	'COM  '
c64	db	'LSR  '
c65	db	'-----'
c66	db	'ROR  '
c67	db	'ASR  '
c68	db	'ASL  '
c69	db	'ROL  '
c6a	db	'DEC  '
c6b	db	'-----'
c6c	db	'INC  '
c6d	db	'TST  '
c6e	db	'JMP  '
c6f	db	'CLR  '

c70	db	'NEG  '
c71	db	'-----'
c72	db	'-----'
c73	db	'COM  '
c74	db	'LSR  '
c75	db	'-----'
c76	db	'ROR  '
c77	db	'ASR  '
c78	db	'ASL  '
c79	db	'ROL  '
c7a	db	'DEC  '
c7b	db	'-----'
c7c	db	'INC  '
c7d	db	'TST  '
c7e	db	'JMP  '
c7f	db	'CLR  '

c80	db	'SUBA '
c81	db	'CMPA '
c82	db	'SBCA '
c83	db	'SUBD '
c84	db	'ANDA '
c85	db	'BITA '
c86	db	'LDAA '
c87	db	'-----'
c88	db	'EORA '
c89	db	'ADCA '
c8a	db	'ORAA '
c8b	db	'ADDA '
c8c	db	'CPX  '
c8c1	db	'CPY  '
c8d	db	'BSR  '
c8e	db	'LDS  '
c8f	db	'XGDX '
c8f1	db	'XGDY '

c90	db	'SUBA '
c91	db	'CMPA '
c92	db	'SBCA '
c93	db	'SUBD '
c94	db	'ANDA '
c95	db	'BITA '
c96	db	'LDAA '
c97	db	'STAA '
c98	db	'EORA '
c99	db	'ADCA '
c9a	db	'ORAA '
c9b	db	'ADDA '
c9c	db	'CPX  '
c9c1	db	'CPY  '
c9d	db	'JSR  '
c9e	db	'LDS  '
c9f	db	'STS  '

ca0	db	'SUBA '
ca1	db	'CMPA '
ca2	db	'SBCA '
ca3	db	'SUBD '
ca4	db	'ANDA '
ca5	db	'BITA '
ca6	db	'LDAA '
ca7	db	'STAA '
ca8	db	'EORA '
ca9	db	'ADCA '
caa	db	'ORAA '
cab	db	'ADDA '
cac	db	'CPX  '
cac1	db	'CPY  '
cad	db	'JSR  '
cae	db	'LDS  '
caf	db	'STS  '

cb0	db	'SUBA '
cb1	db	'CMPA '
cb2	db	'SBCA '
cb3	db	'SUBD '
cb4	db	'ANDA '
cb5	db	'BITA '
cb6	db	'LDAA '
cb7	db	'STAA '
cb8	db	'EORA '
cb9	db	'ADCA '
cba	db	'ORAA '
cbb	db	'ADDA '
cbc	db	'CPX  '
cbc1	db	'CPY  '
cbd	db	'JSR  '
cbe	db	'LDS  '
cbf	db	'STS  '

cc0	db	'SUBB '
cc1	db	'CMPB '
cc2	db	'SBCB '
cc3	db	'ADDD '
cc4	db	'ANDB '
cc5	db	'BITB '
cc6	db	'LDAB '
cc7	db	'-----'
cc8	db	'EORB '
cc9	db	'ADCB '
cca	db	'ORAB '
ccb	db	'ADDB '
ccc	db	'LDD  '
ccd	db	'P 4  '
cce	db	'LDX  '
cce1	db	'LDY  '
ccf	db	'STOP '

cd0	db	'SUBB '
cd1	db	'CMPB '
cd2	db	'SBCB '
cd3	db	'ADDD '
cd4	db	'ANDB '
cd5	db	'BITB '
cd6	db	'LDAB '
cd7	db	'STAB '
cd8	db	'EORB '
cd9	db	'ADCB '
cda	db	'ORAB '
cdb	db	'ADDB '
cdc	db	'LDD  '
cdd	db	'STD  '
cde	db	'LDX  '
cde1	db	'LDY  '
cdf	db	'STX  '
cdf1	db	'STY  '

ce0	db	'SUBB '
ce1	db	'CMPB '
ce2	db	'SBCB '
ce3	db	'ADDD '
ce4	db	'ANDB '
ce5	db	'BITB '
ce6	db	'LDAB '
ce7	db	'STAB '
ce8	db	'EORB '
ce9	db	'ADCB '
cea	db	'ORAB '
ceb	db	'ADDB '
cec	db	'LDD  '
ced	db	'STD  '
cee	db	'LDX  '
cee1	db	'LDY  '
cef	db	'STX  '
cef1	db	'STY  '

cf0	db	'SUBB '
cf1	db	'CMPB '
cf2	db	'SBCB '
cf3	db	'ADDD '
cf4	db	'ANDB '
cf5	db	'BITB '
cf6	db	'LDBB '
cf7	db	'STBB '
cf8	db	'EORB '
cf9	db	'ADCB '
cfa	db	'ORAB '
cfb	db	'ADDB '
cfc	db	'LDD  '
cfd	db	'STD  '
cfe	db	'LDX  '
cfe1	db	'LDY  '
cff	db	'STX  '
cff1	db	'STY  '
c00a	db	'(NA) '

code	ends
	end	begin 
