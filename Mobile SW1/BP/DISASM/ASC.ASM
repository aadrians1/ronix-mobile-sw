
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				ASC	                                 €€
;€€					                                 €€
;€€      Created:   28-Sep-99		                                 €€
;€€      Passes:    9          Analysis	Options on: none                 €€
;€€      Copyright (c) 1983,92 Borland3	                                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T3'                      ; Target assembler: TASM-3.2

include  srmacros.inc

.486p

.387


; The following equates show data references outside the range of the program.

data_1e		equ	8
data_2e		equ	10h
data_3e		equ	14h
data_4e		equ	80h
video_mode	equ	49h
video_columns	equ	4Ah
vid_curs_pos0	equ	50h
video_port	equ	63h
data_5e		equ	6Ch
video_options	equ	87h
PSP_free_seg	equ	2
data_6e		equ	52h
data_7e		equ	152h			;*

;------------------------------------------------------------  seg_a   ----

seg_a		segment	byte public use16
		assume cs:seg_a  , ds:seg_d , ss:stack_seg_e

		db	8, 'asc_tabl'
		db	 03h, 20h, 3Dh, 20h

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       Program	Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€


asc		proc	far

start:
		call	far ptr sub_18
		call	far ptr sub_2
		push	bp
;*		mov	bp,sp
		db	 89h,0E5h		;  Fixup - byte match
;*		xor	ax,ax			; Zero register
		db	 31h,0C0h		;  Fixup - byte match
		call	far ptr sub_29
		mov	di,52h
		push	ds
		push	di
		mov	di,0
		push	cs
		push	di
		call	far ptr sub_30
		mov	di,52h
		push	ds
		push	di
		call	far ptr sub_32
		call	far ptr sub_28
		mov	byte ptr ds:data_7e,0
		jmp	short loc_2
loc_1:
		inc	byte ptr ds:data_7e
loc_2:
		mov	di,data_6e
		push	ds
		push	di
		mov	al,ds:data_7e
;*		xor	ah,ah			; Zero register
		db	 30h,0E4h		;  Fixup - byte match
;*		xor	dx,dx			; Zero register
		db	 31h,0D2h		;  Fixup - byte match
		push	dx
		push	ax
;*		xor	ax,ax			; Zero register
		db	 31h,0C0h		;  Fixup - byte match
		push	ax
		call	far ptr sub_43
		mov	di,9
		push	cs
		push	di
;*		xor	ax,ax			; Zero register
		db	 31h,0C0h		;  Fixup - byte match
		push	ax
		call	far ptr sub_42
		mov	al,ds:data_7e
		push	ax
;*		xor	ax,ax			; Zero register
		db	 31h,0C0h		;  Fixup - byte match
		push	ax
		call	far ptr sub_41
		call	far ptr sub_38
		call	far ptr sub_28
		cmp	byte ptr ds:data_7e,0FFh
		jne	loc_1			; Jump if not equal
		mov	di,52h
		push	ds
		push	di
		call	far ptr sub_33
		call	far ptr sub_28
		pop	bp
;*		xor	ax,ax			; Zero register
		db	 31h,0C0h		;  Fixup - byte match
		call	far ptr sub_20		; Sub does not return here
		db	15 dup (0)

asc		endp

seg_a		ends



;------------------------------------------------------------  seg_b   ----

seg_b		segment	byte public use16
		assume cs:seg_b  , ds:seg_d , ss:stack_seg_e

loc_3:
		push	bp
;*		mov	bp,sp
		db	 89h,0E5h		;  Fixup - byte match
		mov	ax,0FFh
		call	far ptr sub_20		; Sub does not return here
		db	 5Dh,0C3h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_2		proc	far
		push	bp
;*		mov	bp,sp
		db	 89h,0E5h		;  Fixup - byte match
		call	sub_3
		mov	di,168h
		push	ds
		push	di
		callf	sub_9
		mov	di,168h
		push	ds
		push	di
		call	far ptr sub_31
		mov	di,268h
		push	ds
		push	di
		callf	sub_9
		mov	di,268h
		push	ds
		push	di
		call	far ptr sub_32
		pop	bp
		retf				; Return far
sub_2		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_3		proc	near
		mov	ah,0Fh
		call	sub_17
		cmp	al,7
		je	short loc_4		; Jump if equal
		cmp	al,3
		jbe	short loc_4		; Jump if below or =
		mov	ax,3
		call	sub_4
loc_4:
		call	sub_5
		mov	ah,8
		xor	bh,bh			; Zero register
		call	sub_17
		mov	al,ah
		and	al,7Fh
		mov	data_56,al
		mov	data_48,al
		xor	ax,ax			; Zero register
		mov	data_44,al
		mov	data_57,al
		mov	data_58,al
		inc	ax
		mov	data_43,al
		mov	es,data_37
		mov	di,data_5e
		mov	bl,es:[di]
loc_5:
		cmp	bl,es:[di]
		je	loc_5			; Jump if equal
		mov	bl,es:[di]
		mov	ax,0FFE4h
		cwd				; Word to double word
		call	sub_7
		not	ax
		not	dx
		mov	cx,37h
		div	cx			; ax,dx rem=dx:ax/reg
		mov	data_53,ax
		push	ds
		push	cs
		pop	ds
		mov	dx,offset int_1Bh_entry
		mov	ax,251Bh
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		pop	ds
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_4:
		mov	es,data_37
		and	byte ptr es:video_options,0FEh
		cmp	al,7
		je	short loc_6		; Jump if equal
		cmp	al,4
		jb	short loc_6		; Jump if below
		mov	al,3
loc_6:
		push	ax
		mov	ah,0
		call	sub_17
		pop	ax
		or	ah,ah			; Zero ?
		jz	short loc_ret_7		; Jump if zero
		mov	ax,1112h
		mov	bl,0
		call	sub_17
		mov	ax,1130h
		mov	bh,0
		mov	dl,0
		call	sub_17
		cmp	dl,2Ah			; '*'
		jne	short loc_ret_7		; Jump if not equal
		or	byte ptr es:video_options,1
		mov	ax,100h
		mov	cx,600h
		call	sub_17
		mov	ah,12h
		mov	bl,20h			; ' '
		call	sub_17

loc_ret_7:
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_5:
		mov	ah,0Fh
		call	sub_17
		push	ax
		mov	ax,1130h
		mov	bh,0
		mov	dl,0
		call	sub_17
		pop	ax
		mov	cl,0
		or	dl,dl			; Zero ?
		jnz	short loc_8		; Jump if not zero
		mov	dl,18h
		cmp	al,3
		ja	short loc_8		; Jump if above
		mov	cl,1
loc_8:
		mov	dh,dl
		mov	dl,ah
		dec	dl
		mov	ah,0
		cmp	dh,18h
		jbe	short loc_9		; Jump if below or =
		mov	ah,1
loc_9:
		mov	data_47,ax
		mov	data_54,dx
		mov	data_46,cl
		mov	byte ptr data_45,1
		xor	ax,ax			; Zero register
		mov	data_49,ax
		mov	data_51,dx
		retn
sub_3		endp


;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

int_1Bh_entry	proc	far
		push	ax
		push	ds
		mov	ax,seg_d
		mov	ds,ax
		cmp	byte ptr data_43,0
		je	short loc_10		; Jump if equal
		mov	byte ptr data_58,1
loc_10:
		pop	ds
		pop	ax
		iret				; Interrupt return
int_1Bh_entry	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_6		proc	near
		cmp	byte ptr data_58,0
		jne	short loc_11		; Jump if not equal
		retn
loc_11:
		mov	byte ptr data_58,0
loc_12:
		mov	ah,1
		int	16h			; Keyboard i/o  ah=function 01h
						;  get status, if zf=0  al=char
		jz	short loc_13		; Jump if zero
		mov	ah,0
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		jmp	short loc_12
loc_13:
		mov	al,5Eh			; '^'
		call	sub_11
		mov	al,43h			; 'C'
		call	sub_11
		call	sub_10
		jmp	loc_3
sub_6		endp

			                        ;* No entry point to code
		mov	bx,sp
		mov	ax,ss:[bx+4]
		call	sub_4
		call	sub_5
		mov	al,data_56
		mov	data_48,al
		retf	2
			                        ;* No entry point to code
		mov	bx,sp
		mov	dl,ss:[bx+0Ah]
		mov	dh,ss:[bx+8]
		mov	cl,ss:[bx+6]
		mov	ch,ss:[bx+4]
		cmp	dl,cl
		ja	short loc_ret_14	; Jump if above
		cmp	dh,ch
		ja	short loc_ret_14	; Jump if above
		dec	dl
		js	short loc_ret_14	; Jump if sign=1
		dec	dh
		js	short loc_ret_14	; Jump if sign=1
		dec	cl
		cmp	cl,byte ptr data_54
		ja	short loc_ret_14	; Jump if above
		dec	ch
		cmp	ch,byte ptr data_54+1
		ja	short loc_ret_14	; Jump if above
		mov	data_49,dx
		mov	data_51,cx
		call	sub_14

loc_ret_14:
		retf	8
			                        ;* No entry point to code
		mov	ax,600h
		mov	bh,data_48
		mov	cx,data_49
		mov	dx,data_51
		call	sub_17
		mov	dx,data_49
		call	sub_14
		retf
			                        ;* No entry point to code
		call	sub_13
		mov	ax,600h
		mov	bh,data_48
		mov	cx,dx
		mov	dl,byte ptr data_51
		call	sub_17
		retf
			                        ;* No entry point to code
		mov	ax,701h
		jmp	short loc_15
		db	0B8h, 01h, 06h
loc_15:
		push	ax
		call	sub_13
		pop	ax
		mov	bh,data_48
		mov	cl,byte ptr data_49
		mov	ch,dh
		mov	dx,data_51
		cmp	ch,dh
		jne	short loc_16		; Jump if not equal
		xor	al,al			; Zero register
loc_16:
		call	sub_17
		retf
			                        ;* No entry point to code
		mov	bx,sp
		mov	dl,ss:[bx+6]
		mov	dh,ss:[bx+4]
		dec	dl
		add	dl,byte ptr data_49
		jc	short loc_ret_17	; Jump if carry Set
		cmp	dl,byte ptr data_51
		ja	short loc_ret_17	; Jump if above
		dec	dh
		add	dh,byte ptr data_49+1
		jc	short loc_ret_17	; Jump if carry Set
		cmp	dh,byte ptr data_51+1
		ja	short loc_ret_17	; Jump if above
		call	sub_14

loc_ret_17:
		retf	4
			                        ;* No entry point to code
		call	sub_13
		mov	al,dl
		sub	al,byte ptr data_49
		inc	al
		retf
			                        ;* No entry point to code
		call	sub_13
		mov	al,dh
		sub	al,byte ptr data_49+1
		inc	al
		retf
			                        ;* No entry point to code
		mov	bx,sp
		mov	al,ss:[bx+4]
		test	al,0F0h
		jz	short loc_18		; Jump if zero
		and	al,0Fh
		or	al,80h
loc_18:
		and	byte ptr data_48,70h	; 'p'
		or	data_48,al
		retf	2
			                        ;* No entry point to code
		mov	bx,sp
		mov	al,ss:[bx+4]
		and	al,7
		mov	cl,4
		shl	al,cl			; Shift w/zeros fill
		and	byte ptr data_48,8Fh
		or	data_48,al
		retf	2
			                        ;* No entry point to code
		and	byte ptr data_48,0F7h
		retf
			                        ;* No entry point to code
		or	byte ptr data_48,8
		retf
			                        ;* No entry point to code
		mov	al,data_56
		mov	data_48,al
		retf
			                        ;* No entry point to code
		mov	bx,sp
		mov	cx,ss:[bx+4]
		jcxz	short loc_ret_20	; Jump if cx=0
		mov	es,data_37
		xor	di,di			; Zero register
		mov	bl,es:[di]

locloop_19:
		mov	ax,data_53
		xor	dx,dx			; Zero register
		call	sub_7
		loop	locloop_19		; Loop if cx > 0


loc_ret_20:
		retf	2			; Return far

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_7		proc	near
loc_21:
		sub	ax,1
		sbb	dx,0
		jc	short loc_ret_22	; Jump if carry Set
		cmp	bl,es:[di]
		je	loc_21			; Jump if equal

loc_ret_22:
		retn
sub_7		endp

			                        ;* No entry point to code
		mov	bx,sp
		mov	bx,ss:[bx+4]
		mov	ax,34DDh
		mov	dx,12h
		cmp	dx,bx
		jae	short loc_ret_24	; Jump if above or =
		div	bx			; ax,dx rem=dx:ax/reg
		mov	bx,ax
		in	al,61h			; port 61h, 8255 port B, read
		test	al,3
		jnz	short loc_23		; Jump if not zero
		or	al,3
		out	61h,al			; port 61h, 8255 B - spkr, etc
		mov	al,0B6h
		out	43h,al			; port 43h, 8253 timer control
loc_23:
		mov	al,bl
		out	42h,al			; port 42h, 8253 timer 2 spkr
		mov	al,bh
		out	42h,al			; port 42h, 8253 timer 2 spkr

loc_ret_24:
		retf	2
			                        ;* No entry point to code
		in	al,61h			; port 61h, 8255 port B, read
		and	al,0FCh
		out	61h,al			; port 61h, 8255 B - spkr, etc
						;  al = 0, disable parity
		retf
			                        ;* No entry point to code
		cmp	byte ptr data_57,0
		jne	short loc_25		; Jump if not equal
		mov	ah,1
		int	16h			; Keyboard i/o  ah=function 01h
						;  get status, if zf=0  al=char
		mov	al,0
		jz	short loc_ret_26	; Jump if zero
loc_25:
		mov	al,1

loc_ret_26:
		retf				; Return far

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_8		proc	near
		mov	al,data_57
		mov	byte ptr data_57,0
		or	al,al			; Zero ?
		jnz	short loc_27		; Jump if not zero
		xor	ah,ah			; Zero register
		int	16h			; Keyboard i/o  ah=function 00h
						;  get keybd char in al, ah=scan
		or	al,al			; Zero ?
		jnz	short loc_27		; Jump if not zero
		mov	data_57,ah
		or	ah,ah			; Zero ?
		jnz	short loc_27		; Jump if not zero
		mov	al,3
loc_27:
		call	sub_6
		retf				; Return far
sub_8		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_9		proc	near
		mov	bx,sp
		push	ds
		lds	di,dword ptr ss:[bx+4]	; Load 32 bit ptr
		mov	word ptr [di+2],0D7B0h
		mov	word ptr [di+4],80h
		lea	ax,cs:[80h][di]		; Load effective addr
		mov	[di+0Ch],ax
		mov	[di+0Eh],ds
		mov	word ptr [di+10h],367h
		mov	[di+12h],cs
		mov	byte ptr [di+30h],0
		pop	ds
		retf	4
sub_9		endp

			                        ;* No entry point to code
		mov	bx,sp
		push	ds
		lds	di,dword ptr ss:[bx+4]	; Load 32 bit ptr
		mov	ax,39Fh
		mov	bx,47Dh
		mov	cx,bx
		cmp	word ptr [di+2],0D7B1h
		je	short loc_28		; Jump if equal
		mov	word ptr [di+2],0D7B2h
		mov	ax,44Ch
		mov	bx,ax
loc_28:
		mov	[di+14h],ax
		mov	[di+16h],cs
		mov	[di+18h],bx
		mov	[di+1Ah],cs
		mov	[di+1Ch],cx
		mov	[di+1Eh],cs
		xor	ax,ax			; Zero register
		pop	ds
		retf	4
			                        ;* No entry point to code
		push	bp
		mov	bp,sp
		les	di,dword ptr [bp+6]	; Load 32 bit ptr
		mov	dx,es:[di+4]
		dec	dx
		dec	dx
		mov	si,es:[di+8]
		les	di,dword ptr es:[di+0Ch]	; Load 32 bit ptr
		xor	bx,bx			; Zero register
loc_29:
		mov	byte ptr data_57,0
		callf	sub_8
		mov	cx,1
		cmp	al,8
		je	short locloop_30	; Jump if equal
		cmp	al,13h
		je	short locloop_30	; Jump if equal
		cmp	al,4
		je	short locloop_31	; Jump if equal
		dec	cx
		cmp	al,1Bh
		je	short locloop_30	; Jump if equal
		cmp	al,1
		je	short locloop_30	; Jump if equal
		cmp	al,6
		je	short locloop_31	; Jump if equal
		cmp	al,1Ah
		je	short loc_32		; Jump if equal
		cmp	al,0Dh
		je	short loc_33		; Jump if equal
		cmp	al,20h			; ' '
		jb	loc_29			; Jump if below
		cmp	bx,dx
		je	loc_29			; Jump if equal
		mov	es:[bx+di],al
		inc	bx
		call	sub_11
		cmp	bx,si
		jbe	loc_29			; Jump if below or =
		mov	si,bx
		jmp	short loc_29

locloop_30:
		or	bx,bx			; Zero ?
		jz	loc_29			; Jump if zero
		mov	al,8
		call	sub_11
		mov	al,20h			; ' '
		call	sub_11
		mov	al,8
		call	sub_11
		dec	bx
		loop	locloop_30		; Loop if cx > 0

		jmp	short loc_29

locloop_31:
		cmp	bx,si
		je	loc_29			; Jump if equal
		mov	al,es:[bx+di]
		cmp	al,20h			; ' '
		jb	loc_29			; Jump if below
		call	sub_11
		inc	bx
		loop	locloop_31		; Loop if cx > 0

		jmp	short loc_29
loc_32:
		cmp	byte ptr data_44,0
		je	loc_29			; Jump if equal
		mov	es:[bx+di],al
		inc	bx
		jmp	short loc_34
loc_33:
		call	sub_10
		mov	word ptr es:[bx+di],0A0Dh
		inc	bx
		inc	bx
loc_34:
		les	di,dword ptr [bp+6]	; Load 32 bit ptr
		xor	ax,ax			; Zero register
		mov	es:[di+8],ax
		mov	es:[di+0Ah],bx
		pop	bp
		retf	4
			                        ;* No entry point to code
		mov	bx,sp
		les	di,dword ptr ss:[bx+4]	; Load 32 bit ptr
		mov	cx,es:[di+8]
		sub	es:[di+8],cx
		jcxz	short loc_37		; Jump if cx=0
		les	di,dword ptr es:[di+0Ch]	; Load 32 bit ptr
		cmp	byte ptr data_45,0
		jne	short loc_36		; Jump if not equal

locloop_35:
		mov	al,es:[di]
		call	sub_11
		inc	di
		loop	locloop_35		; Loop if cx > 0

		jmp	short loc_37
loc_36:
		call	sub_15
loc_37:
		call	sub_6
		xor	ax,ax			; Zero register
		retf	4			; Return far
		db	 33h,0C0h,0CAh, 04h, 00h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_10		proc	near
		mov	al,0Dh
		call	sub_11
		mov	al,0Ah

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_11:
		push	bx
		push	cx
		push	dx
		push	es
		push	ax
		call	sub_13
		pop	ax
		cmp	al,7
		je	short loc_38		; Jump if equal
		cmp	al,8
		je	short loc_39		; Jump if equal
		cmp	al,0Dh
		je	short loc_40		; Jump if equal
		cmp	al,0Ah
		je	short loc_41		; Jump if equal
		mov	ah,9
		mov	bl,data_48
		xor	bh,bh			; Zero register
		mov	cx,1
		push	dx
		call	sub_17
		pop	dx
		inc	dl
		cmp	dl,byte ptr data_51
		jbe	short loc_42		; Jump if below or =
		mov	dl,byte ptr data_49
		jmp	short loc_41
loc_38:
		mov	ah,0Eh
		call	sub_17
		jmp	short loc_42
loc_39:
		cmp	dl,byte ptr data_49
		je	short loc_42		; Jump if equal
		dec	dl
		jmp	short loc_42
loc_40:
		mov	dl,byte ptr data_49
		jmp	short loc_42
loc_41:
		call	sub_12
loc_42:
		call	sub_14
		pop	es
		pop	dx
		pop	cx
		pop	bx
		retn
sub_10		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_12		proc	near
		inc	dh
		cmp	dh,byte ptr data_51+1
		jbe	short loc_ret_43	; Jump if below or =
		dec	dh
		push	cx
		push	dx
		mov	ax,601h
		mov	bh,data_48
		mov	cx,data_49
		mov	dx,data_51
		call	sub_17
		pop	dx
		pop	cx

loc_ret_43:
		retn
sub_12		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_13		proc	near
		mov	ah,3
		xor	bh,bh			; Zero register
		jmp	loc_60

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_14:
		mov	ah,2
		xor	bh,bh			; Zero register
		jmp	loc_60

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_15:
		push	ds
		mov	ds,data_37
		mov	dx,ds:vid_curs_pos0
		pop	ds
		mov	bx,dx
		mov	si,di

locloop_44:
		mov	al,es:[di]
		cmp	al,7
		je	short loc_45		; Jump if equal
		cmp	al,8
		je	short loc_46		; Jump if equal
		cmp	al,0Ah
		je	short loc_47		; Jump if equal
		cmp	al,0Dh
		je	short loc_48		; Jump if equal
		inc	di
		inc	dl
		cmp	dl,byte ptr data_51
		jbe	short loc_51		; Jump if below or =
		call	sub_16
		call	sub_12
		mov	dl,byte ptr data_49
		jmp	short loc_50
loc_45:
		call	sub_16
		push	cx
		push	dx
		mov	ax,0E07h
		call	sub_17
		pop	dx
		pop	cx
		jmp	short loc_49
loc_46:
		call	sub_16
		cmp	dl,byte ptr data_49
		je	short loc_49		; Jump if equal
		dec	dl
		jmp	short loc_49
loc_47:
		call	sub_16
		call	sub_12
		jmp	short loc_49
loc_48:
		call	sub_16
		mov	dl,byte ptr data_49
loc_49:
		inc	di
loc_50:
		mov	si,di
		mov	bx,dx
loc_51:
		loop	locloop_44		; Loop if cx > 0

		call	sub_16
		push	ds
		mov	ds,data_37
		mov	ds:vid_curs_pos0,dx
		mov	al,dh
		mul	byte ptr ds:video_columns	; ax = data * al
		xor	dh,dh			; Zero register
		add	ax,dx
		mov	cx,ax
		mov	dx,ds:video_port
		mov	al,0Eh
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 0Eh, cursor position hi
		jmp	short $+2		; delay for I/O
		mov	al,ch
		inc	dx
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		jmp	short $+2		; delay for I/O
		dec	dx
		mov	al,0Fh
		out	dx,al			; port 3D4h, CGA/EGA reg index
						;  al = 0Fh, cursor position lo
		jmp	short $+2		; delay for I/O
		mov	al,cl
		inc	dx
		out	dx,al			; port 3D5h, CGA/EGA indxd data
		pop	ds
		retn

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_16:
		cmp	si,di
		je	short loc_ret_59	; Jump if equal
		push	cx
		push	dx
		push	di
		push	ds
		push	es
		mov	cx,di
		sub	cx,si
		push	ds
		mov	ds,data_37
		mov	al,bh
		mul	byte ptr ds:video_columns	; ax = data * al
		xor	bh,bh			; Zero register
		add	ax,bx
		shl	ax,1			; Shift w/zeros fill
		mov	di,ax
		mov	dx,ds:video_port
		add	dx,6
		cmp	byte ptr ds:video_mode,7
		pop	ds
		mov	ax,data_39
		jnz	short loc_52		; Jump if not zero
		mov	ax,data_38
loc_52:
		mov	bl,data_46
		mov	bh,data_48
		push	es
		pop	ds
		mov	es,ax
		cld				; Clear direction
		or	bl,bl			; Zero ?
		jz	short loc_56		; Jump if zero

locloop_53:
		lodsb				; String [si] to al
		mov	bl,al
loc_54:
		in	al,dx			; port 3DAh, CGA/EGA vid status
		test	al,1
		jnz	loc_54			; Jump if not zero
		cli				; Disable interrupts
loc_55:
		in	al,dx			; port 3DAh, CGA/EGA vid status
		test	al,1
		jz	loc_55			; Jump if zero
		mov	ax,bx
		stosw				; Store ax to es:[di]
		sti				; Enable interrupts
		loop	locloop_53		; Loop if cx > 0

		jmp	short loc_58
loc_56:
		mov	ah,bh

locloop_57:
		lodsb				; String [si] to al
		stosw				; Store ax to es:[di]
		loop	locloop_57		; Loop if cx > 0

loc_58:
		pop	es
		pop	ds
		pop	di
		pop	dx
		pop	cx

loc_ret_59:
		retn
sub_13		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_17		proc	near
loc_60:
		push	si
		push	di
		push	bp
		push	es
		int	10h			; Video display   ah=functn 0Fh
						;  get state, al=mode, bh=page
						;   ah=columns on screen
		pop	es
		pop	bp
		pop	di
		pop	si
		retn
sub_17		endp

		db	0

seg_b		ends



;------------------------------------------------------------  seg_c   ----

seg_c		segment	byte public use16
		assume cs:seg_c  , ds:seg_d , ss:stack_seg_e


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_18		proc	far
		mov	dx,seg seg_d
		mov	ds,dx
		mov	data_34,es
		xor	bp,bp			; Zero register
		call	sub_48
		call	sub_19
		mov	ax,sp
		add	ax,13h
		mov	cl,4
		shr	ax,cl			; Shift w/zeros fill
		mov	dx,ss
		add	ax,dx
		mov	data_17,ax
		mov	data_18,ax
		add	ax,data_16
		mov	data_19,ax
		mov	data_22,ax
		mov	data_24,ax
		mov	data_26,ax
		mov	es,data_34
		mov	ax,es:PSP_free_seg
		mov	data_25,ax
		mov	data_27,0D6h
		mov	data_28,cs
		mov	di,368h
		mov	si,offset data_9
		mov	cx,13h
		nop

locloop_61:
		cld				; Clear direction
		lods	byte ptr cs:[si]	; String [si] to al
		mov	ah,35h
		int	21h			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		mov	[di],bx
		mov	[di+2],es
		add	di,4
		loop	locloop_61		; Loop if cx > 0

		push	ds
		push	cs
		pop	ds
		mov	dx,offset int_00h_entry
		mov	ax,2500h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	dx,offset int_23h_entry
		mov	ax,2523h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	dx,offset int_24h_entry
		mov	ax,2524h
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		mov	dx,offset int_3Fh_entry
		mov	ax,253Fh
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		pop	ds
		mov	ax,168h
		push	ds
		push	ax
		push	ds
		push	ax
		mov	ax,263h
		push	cs
		push	ax
		callf	sub_30
		callf	sub_31
		mov	ax,268h
		push	ds
		push	ax
		push	ds
		push	ax
		mov	ax,263h
		push	cs
		push	ax
		callf	sub_30
		callf	sub_32
		retf				; Return far

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_19:
		xor	ax,ax			; Zero register
		pushf				; Push flags
		pop	bx
		and	bh,0Fh
		push	bx
		popf				; Pop flags
		pushf				; Push flags
		pop	cx
		and	ch,0F0h
		cmp	ch,0F0h
		je	short loc_62		; Jump if equal
		inc	ax
		or	bh,0F0h
		push	bx
		popf				; Pop flags
		pushf				; Push flags
		pop	cx
		and	ch,0F0h
		jz	short loc_62		; Jump if zero
		inc	ax
loc_62:
		mov	data_40,al
		retn
		db	 33h,0C0h,0CAh, 02h, 00h
sub_18		endp


;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

int_24h_entry	proc	far
		sti				; Enable interrupts
		add	sp,6
		pop	ax
		and	di,1Fh
		add	di,96h
		cmp	ah,39h			; '9'
		jae	short loc_63		; Jump if above or =
		mov	di,0FFFFh
loc_63:
		push	di
		mov	ah,54h
		int	21h			; DOS Services  ah=function 54h
						;  get verify flag in al
		mov	bp,sp
		or	byte ptr [bp+16h],1
		pop	ax
		pop	bx
		pop	cx
		pop	dx
		pop	si
		pop	di
		pop	bp
		pop	ds
		pop	es
		iret				; Interrupt return
int_24h_entry	endp


;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

int_3Fh_entry	proc	far
		mov	ax,0D0h
		add	sp,6
		jmp	short loc_64
int_3Fh_entry	endp


;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

int_00h_entry	proc	far
		mov	ax,0C8h
loc_64:
		pop	cx
		pop	bx
		jmp	short loc_65
int_00h_entry	endp


;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;
;                       External Entry Point
;
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

int_23h_entry	proc	far
		mov	ax,0FFh
int_23h_entry	endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

;      Note: Subroutine does not return	to instruction after call

sub_20		proc	far
		xor	cx,cx			; Zero register
		xor	bx,bx			; Zero register
loc_65:
		mov	dx,seg seg_d
		mov	ds,dx
		sti				; Enable interrupts
		mov	data_31,ax
		mov	ax,cx
		or	ax,bx
		jz	short loc_70		; Jump if zero
		mov	ax,data_20
loc_66:
		or	ax,ax			; Zero ?
		jz	short loc_69		; Jump if zero
		mov	es,ax
		mov	ax,word ptr es:[10h]
		or	ax,ax			; Zero ?
		jz	short loc_67		; Jump if zero
		sub	ax,bx
		ja	short loc_67		; Jump if above
		neg	ax
		cmp	ax,1000h
		jae	short loc_67		; Jump if above or =
		mov	dx,10h
		mul	dx			; dx:ax = reg * ax
		add	ax,cx
		jc	short loc_67		; Jump if carry Set
		cmp	ax,word ptr es:[8]
		jb	short loc_68		; Jump if below
loc_67:
		mov	ax,word ptr es:[14h]
		jmp	short loc_66
loc_68:
		mov	cx,ax
		mov	bx,es
loc_69:
		sub	bx,data_34
		sub	bx,10h
loc_70:
		mov	data_32,cx
		mov	data_33,bx
		les	bx,data_29		; Load 32 bit ptr
		mov	ax,es
		or	ax,bx
		jz	short loc_71		; Jump if zero
		xor	ax,ax			; Zero register
		mov	word ptr data_29,ax
		mov	word ptr data_29+2,ax
		mov	data_36,ax
		mov	ax,16Eh
		push	cs
		push	ax
		push	es
		push	bx
		retf				; Return far
loc_71:
		mov	ax,168h
		push	ds
		push	ax
		callf	sub_33
		mov	ax,268h
		push	ds
		push	ax
		callf	sub_33
		mov	di,offset data_59
		mov	si,offset data_9
		mov	cx,13h
		nop

locloop_72:
		cld				; Clear direction
		lods	byte ptr cs:[si]	; String [si] to al
		mov	ah,25h			; '%'
		push	ds
		lds	dx,dword ptr [di]	; Load 32 bit ptr
		int	21h			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		pop	ds
		add	di,4
		loop	locloop_72		; Loop if cx > 0

		mov	ax,data_32
		or	ax,data_33
		jz	short loc_73		; Jump if zero
		mov	bx,offset data_10+11h	; ('R')
		call	sub_21
		mov	ax,data_31
		call	sub_22
		mov	bx,offset data_10+20h	; (' ')
		call	sub_21
		mov	ax,data_33
		call	sub_24
		mov	al,3Ah			; ':'
		call	sub_27
		mov	ax,data_32
		call	sub_24
		mov	bx,offset data_10+25h	; ('.')
		call	sub_21
loc_73:
		mov	ax,data_31
		mov	ah,4Ch
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
sub_20		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_21		proc	near
loc_74:
		mov	al,cs:[bx]
		or	al,al			; Zero ?
		jz	short loc_ret_75	; Jump if zero
		call	sub_27
		inc	bx
		jmp	short loc_74

loc_ret_75:
		retn
sub_21		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_22		proc	near
		mov	cl,64h			; 'd'
		call	sub_23
		mov	cl,0Ah
		call	sub_23
		jmp	short loc_76

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_23:
		xor	ah,ah			; Zero register
		div	cl			; al, ah rem = ax/reg
loc_76:
		add	al,30h			; '0'
		push	ax
		call	sub_27
		pop	ax
		mov	al,ah
		retn
sub_22		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_24		proc	near
		push	ax
		mov	al,ah
		call	sub_25
		pop	ax

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_25:
		push	ax
		mov	cl,4
		shr	al,cl			; Shift w/zeros fill
		call	sub_26
		pop	ax
		and	al,0Fh

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_26:
		add	al,30h			; '0'
		cmp	al,3Ah			; ':'
		jb	short loc_77		; Jump if below
		add	al,7

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_27:
loc_77:
		mov	dl,al
		mov	ah,6
		int	21h			; DOS Services  ah=function 06h
						;  special char i/o, dl=subfunc
		retn
sub_24		endp

data_9		db	0
		db	2
data_10		db	1Bh, '!#$'
		db	'456789:;<=>?uRuntime error ', 0
		db	' at ', 0
		db	'.', 0Dh, 0Ah, 0
		db	'Portions '
copyright	db	'Copyright (c) 1983,92 Borland3'
		db	0C0h, 87h, 06h, 3Ch, 00h,0CBh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_28		proc	far
		cmp	data_36,0
		jne	short loc_78		; Jump if not equal
		retf				; Return far
loc_78:
		mov	ax,data_36
		jmp	loc_64
sub_28		endp

			                        ;* No entry point to code
		mov	si,sp
		mov	es,ss:[si+2]
		cmp	dx,es:[di+2]
		jg	short loc_79		; Jump if >
		jl	short loc_81		; Jump if <
		cmp	ax,es:[di]
		jb	short loc_81		; Jump if below
loc_79:
		cmp	dx,es:[di+6]
		jl	short loc_ret_80	; Jump if <
		jg	short loc_81		; Jump if >
		cmp	ax,es:[di+4]
		ja	short loc_81		; Jump if above

loc_ret_80:
		retf				; Return far
loc_81:
		mov	ax,0C9h
		jmp	loc_64
			                        ;* No entry point to code
		mov	ax,0D7h
		jmp	loc_64

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_29		proc	far
		add	ax,200h
		jc	short loc_82		; Jump if carry Set
		sub	ax,sp
		jnc	short loc_82		; Jump if carry=0
		neg	ax
		cmp	ax,data_35
		jb	short loc_82		; Jump if below
		retf				; Return far
loc_82:
		mov	ax,0CAh
		jmp	loc_64
sub_29		endp

		db	0BAh

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_30		proc	far
		xor	dx,dx			; Zero register
		mov	bx,sp
		push	ds
		les	di,dword ptr ss:[bx+8]	; Load 32 bit ptr
		lds	si,dword ptr ss:[bx+4]	; Load 32 bit ptr
		cld				; Clear direction
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		mov	ax,0D7B0h
		stosw				; Store ax to es:[di]
		mov	ax,80h
		stosw				; Store ax to es:[di]
		xor	ax,ax			; Zero register
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		stosw				; Store ax to es:[di]
		lea	ax,[di+74h]		; Load effective addr
		stosw				; Store ax to es:[di]
		mov	ax,es
		stosw				; Store ax to es:[di]
		mov	ax,7BDh
		stosw				; Store ax to es:[di]
		mov	ax,seg_c
		stosw				; Store ax to es:[di]
		xor	ax,ax			; Zero register
		mov	cx,0Eh
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		mov	cx,4Fh
		or	dx,dx			; Zero ?
		jnz	short locloop_83	; Jump if not zero
		lodsb				; String [si] to al
		cmp	cl,al
		jbe	short locloop_83	; Jump if below or =
		mov	cl,al
		jcxz	short loc_84		; Jump if cx=0

locloop_83:
		lodsb				; String [si] to al
		or	al,al			; Zero ?
		jz	short loc_84		; Jump if zero
		stosb				; Store al to es:[di]
		loop	locloop_83		; Loop if cx > 0

loc_84:
		xor	al,al			; Zero register
		stosb				; Store al to es:[di]
		pop	ds
		retf	8
sub_30		endp

			                        ;* No entry point to code
		mov	bx,sp
		les	di,dword ptr ss:[bx+0Ah]	; Load 32 bit ptr
		mov	ax,ss:[bx+4]
		mov	es:[di+4],ax
		mov	ax,ss:[bx+6]
		mov	es:[di+0Ch],ax
		mov	ax,ss:[bx+8]
		mov	es:[di+0Eh],ax
		xor	ax,ax			; Zero register
		mov	es:[di+8],ax
		mov	es:[di+0Ah],ax
		retf	0Ah			; Return far

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_31		proc	far
		mov	dx,0D7B1h
		jmp	short loc_85

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_32:
		mov	dx,0D7B2h
		jmp	short loc_85
		db	0BAh,0B3h,0D7h
loc_85:
		push	bp
		mov	bp,sp
		les	di,dword ptr [bp+6]	; Load 32 bit ptr
		mov	ax,es:[di+2]
		cmp	ax,0D7B1h
		je	short loc_86		; Jump if equal
		cmp	ax,0D7B2h
		je	short loc_86		; Jump if equal
		cmp	ax,0D7B0h
		je	short loc_87		; Jump if equal
		mov	data_36,66h
		jmp	short loc_88
loc_86:
		push	dx
		push	es
		push	di
		callf	sub_33
		pop	dx
loc_87:
		xor	ax,ax			; Zero register
		mov	es:[di+2],dx
		mov	es:[di+8],ax
		mov	es:[di+0Ah],ax
		mov	bx,10h
		call	sub_34
		jz	short loc_88		; Jump if zero
		mov	word ptr es:[di+2],0D7B0h
loc_88:
		pop	bp
		retf	4			; Return far
sub_31		endp

		db	0B0h, 00h,0EBh, 02h

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_33		proc	far
		mov	al,1
		push	bp
		mov	bp,sp
		les	di,dword ptr [bp+6]	; Load 32 bit ptr
		cmp	word ptr es:[di+2],0D7B1h
		je	short loc_90		; Jump if equal
		cmp	word ptr es:[di+2],0D7B2h
		je	short loc_89		; Jump if equal
		mov	data_36,67h
		jmp	short loc_91
loc_89:
		push	ax
		mov	bx,14h
		call	sub_34
		pop	ax
loc_90:
		or	al,al			; Zero ?
		jz	short loc_91		; Jump if zero
		mov	bx,1Ch
		call	sub_34
		mov	word ptr es:[di+2],0D7B0h
loc_91:
		pop	bp
		retf	4			; Return far
sub_33		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_34		proc	near
		push	es
		push	di
		push	es
		push	di
		call	dword ptr es:[bx+di]
		or	ax,ax			; Zero ?
		jz	short loc_92		; Jump if zero
		mov	data_36,ax
loc_92:
		pop	di
		pop	es
		retn
sub_34		endp

			                        ;* No entry point to code
		mov	bx,sp
		push	ds
		les	di,dword ptr ss:[bx+4]	; Load 32 bit ptr
		lds	dx,dword ptr es:[di+0Ch]	; Load 32 bit ptr
		mov	cx,es:[di+4]
		mov	bx,es:[di]
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		jc	short loc_94		; Jump if carry Set
		mov	es:[di+0Ah],ax
		xor	ax,ax			; Zero register
loc_93:
		mov	word ptr es:[di+8],0
		pop	ds
		retf	4			; Return far
loc_94:
		mov	word ptr es:[di+0Ah],0
		jmp	short loc_93
			                        ;* No entry point to code
		mov	bx,sp
		push	ds
		les	di,dword ptr ss:[bx+4]	; Load 32 bit ptr
		lds	dx,dword ptr es:[di+0Ch]	; Load 32 bit ptr
		xor	cx,cx			; Zero register
		xchg	es:[di+8],cx
		mov	bx,es:[di]
		mov	ah,40h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jc	short loc_95		; Jump if carry Set
		sub	ax,cx
		jz	short loc_95		; Jump if zero
		mov	ax,65h
loc_95:
		pop	ds
		retf	4
			                        ;* No entry point to code
		mov	bx,sp
		push	ds
		les	di,dword ptr ss:[bx+4]	; Load 32 bit ptr
		lds	dx,dword ptr es:[di+0Ch]	; Load 32 bit ptr
		xor	cx,cx			; Zero register
		xchg	es:[di+8],cx
		mov	bx,es:[di]
		mov	ah,40h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer
		jc	short loc_96		; Jump if carry Set
		xor	ax,ax			; Zero register
loc_96:
		pop	ds
		retf	4
			                        ;* No entry point to code
		mov	bx,sp
		les	di,dword ptr ss:[bx+4]	; Load 32 bit ptr
		mov	bx,es:[di]
		cmp	bx,4
		jbe	short loc_97		; Jump if below or =
		mov	ah,3Eh
		int	21h			; DOS Services  ah=function 3Eh
						;  close file, bx=file handle
		jc	short loc_ret_98	; Jump if carry Set
loc_97:
		xor	ax,ax			; Zero register

loc_ret_98:
		retf	4			; Return far

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_35		proc	near
		cmp	data_36,0
		jne	short loc_ret_100	; Jump if not equal
		cmp	word ptr es:[bx+2],0D7B1h
		jne	short loc_101		; Jump if not equal
		mov	si,es:[bx+8]
		cmp	si,es:[bx+0Ah]
		je	short loc_102		; Jump if equal
loc_99:
		push	ds
		push	es
		push	bx
		push	dx
		lds	dx,dword ptr es:[bx+0Ch]	; Load 32 bit ptr
		mov	bx,es:[bx+0Ah]
		pop	es
		add	bx,dx
		add	si,dx
		cld				; Clear direction
		call	ax			;*
		sub	si,dx
		mov	dx,es
		pop	bx
		pop	es
		pop	ds
		mov	es:[bx+8],si
		or	ax,ax			; Zero ?
		jnz	short loc_102		; Jump if not zero

loc_ret_100:
		retn
loc_101:
		mov	data_36,68h
		retn
loc_102:
		push	ax
		push	cx
		push	dx
		push	di
		push	es
		push	bx
		call	sub_39
		pop	bx
		pop	es
		pop	di
		pop	dx
		pop	cx
		pop	ax
		mov	si,es:[bx+8]
		cmp	si,es:[bx+0Ah]
		jne	loc_99			; Jump if not equal
		retn
sub_35		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_36		proc	near
		cmp	data_36,0
		jne	short loc_ret_106	; Jump if not equal
		cmp	word ptr es:[bx+2],0D7B2h
		jne	short loc_107		; Jump if not equal
loc_103:
		mov	cx,es:[bx+4]
		mov	di,es:[bx+8]
		sub	cx,di
		sub	dx,cx
		jnc	short loc_104		; Jump if carry=0
		add	cx,dx
		xor	dx,dx			; Zero register
loc_104:
		push	es
		les	si,dword ptr es:[bx+0Ch]	; Load 32 bit ptr
		add	di,si
		mov	al,20h			; ' '
		cld				; Clear direction
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		sub	di,si
		pop	es
		mov	es:[bx+8],di
		cmp	di,es:[bx+4]
		jne	short loc_105		; Jump if not equal
		push	dx
		push	es
		push	bx
		call	sub_39
		pop	bx
		pop	es
		pop	dx
loc_105:
		or	dx,dx			; Zero ?
		jnz	loc_103			; Jump if not zero

loc_ret_106:
		retn
loc_107:
		mov	data_36,69h
		retn
sub_36		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_37		proc	near
		cmp	data_36,0
		jne	short loc_ret_111	; Jump if not equal
		cmp	word ptr es:[bx+2],0D7B2h
		jne	short loc_112		; Jump if not equal
loc_108:
		mov	cx,es:[bx+4]
		mov	di,es:[bx+8]
		sub	cx,di
		sub	ax,cx
		jnc	short loc_109		; Jump if carry=0
		add	cx,ax
		xor	ax,ax			; Zero register
loc_109:
		push	ds
		push	es
		push	bx
		mov	ds,dx
		les	bx,dword ptr es:[bx+0Ch]	; Load 32 bit ptr
		add	di,bx
		cld				; Clear direction
		rep	movsb			; Rep when cx >0 Mov [si] to es:[di]
		sub	di,bx
		pop	bx
		pop	es
		pop	ds
		mov	es:[bx+8],di
		cmp	di,es:[bx+4]
		jne	short loc_110		; Jump if not equal
		push	ax
		push	dx
		push	si
		push	es
		push	bx
		call	sub_39
		pop	bx
		pop	es
		pop	si
		pop	dx
		pop	ax
loc_110:
		or	ax,ax			; Zero ?
		jnz	loc_108			; Jump if not zero

loc_ret_111:
		retn
loc_112:
		mov	data_36,69h
		retn
sub_37		endp

			                        ;* No entry point to code
		push	bp
		mov	bp,sp
		les	bx,dword ptr [bp+6]	; Load 32 bit ptr
		mov	ax,5BBh
		xor	dx,dx			; Zero register
		call	sub_35
		jnz	short loc_113		; Jump if not zero
		cmp	word ptr es:[bx+1Ah],0
		je	short loc_113		; Jump if equal
		call	sub_40
loc_113:
		pop	bp
		retf	4			; Return far
loc_114:
		lodsb				; String [si] to al
		cmp	al,0Dh
		je	short loc_115		; Jump if equal
		cmp	al,1Ah
		je	short loc_116		; Jump if equal
		cmp	si,bx
		jne	loc_114			; Jump if not equal
		mov	ax,5BBh
		retn
loc_115:
		cmp	si,bx
		je	short loc_118		; Jump if equal
		lodsb				; String [si] to al
		cmp	al,0Ah
		je	short loc_117		; Jump if equal
loc_116:
		dec	si
loc_117:
		xor	ax,ax			; Zero register
		retn
loc_118:
		mov	ax,5D0h
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_38		proc	far
		push	bp
		mov	bp,sp
		les	bx,dword ptr [bp+6]	; Load 32 bit ptr
		mov	ax,2
		mov	si,50h
		mov	dx,ds
		call	sub_37
		jnz	short loc_119		; Jump if not zero
		cmp	word ptr es:[bx+1Ah],0
		je	short loc_119		; Jump if equal
		call	sub_40
loc_119:
		pop	bp
		retf	4
sub_38		endp

			                        ;* No entry point to code
		push	bp
		mov	bp,sp
		les	bx,dword ptr [bp+6]	; Load 32 bit ptr
		cmp	word ptr es:[bx+1Ah],0
		je	short loc_120		; Jump if equal
		cmp	data_36,0
		jne	short loc_120		; Jump if not equal
		call	sub_40
loc_120:
		pop	bp
		retf	4			; Return far

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_39		proc	near
		push	es
		push	bx
		call	dword ptr es:[bx+14h]	;*
		or	ax,ax			; Zero ?
		jz	short loc_ret_121	; Jump if zero
		mov	data_36,ax

loc_ret_121:
		retn
sub_39		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_40		proc	near
		push	es
		push	bx
		call	dword ptr es:[bx+18h]
		or	ax,ax			; Zero ?
		jz	short loc_ret_122	; Jump if zero
		mov	data_36,ax

loc_ret_122:
		retn
sub_40		endp

			                        ;* No entry point to code
		push	bp
		mov	bp,sp
		cmp	data_36,0
		jne	short loc_126		; Jump if not equal
		les	bx,dword ptr [bp+6]	; Load 32 bit ptr
		cmp	word ptr es:[bx+2],0D7B1h
		jne	short loc_125		; Jump if not equal
		mov	di,es:[bx+8]
		cmp	di,es:[bx+0Ah]
		jne	short loc_123		; Jump if not equal
		call	sub_39
		les	bx,dword ptr [bp+6]	; Load 32 bit ptr
		mov	di,es:[bx+8]
		cmp	di,es:[bx+0Ah]
		je	short loc_126		; Jump if equal
loc_123:
		inc	word ptr es:[bx+8]
		les	bx,dword ptr es:[bx+0Ch]	; Load 32 bit ptr
		mov	al,es:[bx+di]
loc_124:
		pop	bp
		retf				; Return far
loc_125:
		mov	data_36,68h
loc_126:
		mov	al,1Ah
		jmp	short loc_124

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_41		proc	far
		push	bp
		mov	bp,sp
		les	bx,dword ptr [bp+0Ah]	; Load 32 bit ptr
		mov	dx,[bp+6]
		dec	dx
		jle	short loc_127		; Jump if < or =
		call	sub_36
loc_127:
		cmp	data_36,0
		jne	short loc_128		; Jump if not equal
		cmp	word ptr es:[bx+2],0D7B2h
		jne	short loc_129		; Jump if not equal
		inc	word ptr es:[bx+8]
		mov	di,es:[bx+8]
		mov	dx,es:[bx+4]
		les	bx,dword ptr es:[bx+0Ch]	; Load 32 bit ptr
		mov	al,[bp+8]
		mov	es:[bx+di-1],al
		cmp	di,dx
		jne	short loc_128		; Jump if not equal
		les	bx,dword ptr [bp+0Ah]	; Load 32 bit ptr
		call	sub_39
loc_128:
		pop	bp
		retf	4			; Return far
loc_129:
		mov	data_36,69h
		jmp	short loc_128
sub_41		endp

			                        ;* No entry point to code
		push	bp
		mov	bp,sp
		les	bx,dword ptr [bp+0Ch]	; Load 32 bit ptr
		mov	ax,6E9h
		mov	cx,[bp+6]
		mov	di,[bp+8]
		mov	dx,[bp+0Ah]
		inc	di
		call	sub_35
		mov	ax,di
		les	di,dword ptr [bp+8]	; Load 32 bit ptr
		sub	ax,di
		dec	ax
		stosb				; Store al to es:[di]
		pop	bp
		retf	6			; Return far

locloop_130:
		lodsb				; String [si] to al
		cmp	al,0Dh
		je	short loc_131		; Jump if equal
		cmp	al,1Ah
		je	short loc_131		; Jump if equal
		stosb				; Store al to es:[di]
		cmp	si,bx
		loopnz	locloop_130		; Loop if zf=0, cx>0

		jcxz	short loc_132		; Jump if cx=0
		mov	ax,6E9h
		retn
loc_131:
		dec	si
loc_132:
		xor	ax,ax			; Zero register
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_42		proc	far
		push	bp
		mov	bp,sp
		les	bx,dword ptr [bp+8]	; Load 32 bit ptr
		mov	al,es:[bx]
		xor	ah,ah			; Zero register
		les	bx,dword ptr [bp+0Ch]	; Load 32 bit ptr
		mov	dx,[bp+6]
		sub	dx,ax
		jle	short loc_133		; Jump if < or =
		push	ax
		call	sub_36
		pop	ax
loc_133:
		or	ax,ax			; Zero ?
		jz	short loc_134		; Jump if zero
		mov	si,[bp+8]
		mov	dx,[bp+0Ah]
		inc	si
		call	sub_37
loc_134:
		pop	bp
		retf	6
sub_42		endp

			                        ;* No entry point to code
		push	bp
		mov	bp,sp
		sub	sp,20h
		les	bx,dword ptr [bp+6]	; Load 32 bit ptr
		mov	ax,764h
		mov	cx,20h
		lea	di,[bp-20h]		; Load effective addr
		mov	dx,ss
		call	sub_35
		mov	cx,di
		lea	di,[bp-20h]		; Load effective addr
		sub	cx,di
		jz	short loc_136		; Jump if zero
		push	ss
		pop	es
		call	sub_47
		jc	short loc_135		; Jump if carry Set
		jcxz	short loc_137		; Jump if cx=0
loc_135:
		mov	data_36,6Ah
loc_136:
		xor	ax,ax			; Zero register
		mov	dx,ax
loc_137:
		mov	sp,bp
		pop	bp
		retf				; Return far
loc_138:
		lodsb				; String [si] to al
		cmp	al,20h			; ' '
		ja	short loc_140		; Jump if above
		cmp	al,1Ah
		je	short loc_141		; Jump if equal
		cmp	si,bx
		jne	loc_138			; Jump if not equal
		mov	ax,764h
		retn

locloop_139:
		lodsb				; String [si] to al
		cmp	al,20h			; ' '
		jbe	short loc_141		; Jump if below or =
loc_140:
		stosb				; Store al to es:[di]
		cmp	si,bx
		loopnz	locloop_139		; Loop if zf=0, cx>0

		jcxz	short loc_142		; Jump if cx=0
		mov	ax,775h
		retn
loc_141:
		dec	si
loc_142:
		xor	ax,ax			; Zero register
		retn

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_43		proc	far
		push	bp
		mov	bp,sp
		sub	sp,20h
		mov	ax,[bp+8]
		mov	dx,[bp+0Ah]
		lea	di,[bp+0]		; Load effective addr
		push	ss
		pop	es
		call	sub_45
		les	bx,dword ptr [bp+0Ch]	; Load 32 bit ptr
		mov	dx,[bp+6]
		sub	dx,cx
		jle	short loc_143		; Jump if < or =
		push	cx
		push	di
		call	sub_36
		pop	di
		pop	cx
loc_143:
		mov	ax,cx
		mov	si,di
		mov	dx,ss
		call	sub_37
		mov	sp,bp
		pop	bp
		retf	6
sub_43		endp

			                        ;* No entry point to code
		mov	bx,sp
		push	ds
		lds	di,dword ptr ss:[bx+4]	; Load 32 bit ptr
		xor	cx,cx			; Zero register
		mov	[di],cx
		mov	ax,3D00h
		cmp	word ptr [di+2],0D7B1h
		je	short loc_144		; Jump if equal
		mov	al,2
		inc	word ptr [di]
		cmp	word ptr [di+2],0D7B3h
		je	short loc_144		; Jump if equal
		mov	ah,3Ch			; '<'
loc_144:
		cmp	byte ptr [di+30h],0
		je	short loc_145		; Jump if equal
		lea	dx,[di+30h]		; Load effective addr
		int	21h			; DOS Services  ah=function 3Ch
						;  create/truncate file @ ds:dx
		jc	short loc_149		; Jump if carry Set
		mov	[di],ax
loc_145:
		mov	ax,40Bh
		mov	dx,seg seg_c
		xor	cx,cx			; Zero register
		xor	bx,bx			; Zero register
		cmp	word ptr [di+2],0D7B1h
		je	short loc_148		; Jump if equal
		mov	bx,[di]
		mov	ax,4400h
		int	21h			; DOS Services  ah=function 44h
						;  IOctl-0 get info dx, bx=handl
		test	dl,80h
		mov	ax,460h
		mov	dx,seg seg_c
		mov	cx,ax
		mov	bx,dx
		jnz	short loc_147		; Jump if not zero
		cmp	word ptr [di+2],0D7B3h
		jne	short loc_146		; Jump if not equal
		call	sub_44
loc_146:
		mov	ax,43Bh
		mov	dx,seg seg_c
		xor	cx,cx			; Zero register
		xor	bx,bx			; Zero register
loc_147:
		mov	word ptr [di+2],0D7B2h
loc_148:
		mov	[di+14h],ax
		mov	[di+16h],dx
		mov	[di+18h],cx
		mov	[di+1Ah],bx
		mov	word ptr [di+1Ch],480h
		mov	word ptr [di+1Eh],seg_c
		xor	ax,ax			; Zero register
loc_149:
		pop	ds
		retf	4			; Return far

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_44		proc	near
		xor	dx,dx			; Zero register
		xor	cx,cx			; Zero register
		mov	bx,[di]
		mov	ax,4202h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		sub	ax,80h
		sbb	dx,0
		jnc	short loc_150		; Jump if carry=0
		xor	ax,ax			; Zero register
		xor	dx,dx			; Zero register
loc_150:
		mov	cx,dx
		mov	dx,ax
		mov	bx,[di]
		mov	ax,4200h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		lea	dx,ds:data_4e[di]	; Load effective addr
		mov	cx,80h
		mov	bx,[di]
		mov	ah,3Fh
		int	21h			; DOS Services  ah=function 3Fh
						;  read file, bx=file handle
						;   cx=bytes to ds:dx buffer
		jnc	short loc_151		; Jump if carry=0
		xor	ax,ax			; Zero register
loc_151:
		xor	bx,bx			; Zero register
loc_152:
		cmp	bx,ax
		je	short loc_ret_154	; Jump if equal
		cmp	byte ptr ds:data_4e[bx+di],1Ah
		je	short loc_153		; Jump if equal
		inc	bx
		jmp	short loc_152
loc_153:
		mov	dx,bx
		sub	dx,ax
		mov	cx,0FFFFh
		mov	bx,[di]
		mov	ax,4202h
		int	21h			; DOS Services  ah=function 42h
						;  move file ptr, bx=file handle
						;   al=method, cx,dx=offset
		xor	cx,cx			; Zero register
		mov	bx,[di]
		mov	ah,40h
		int	21h			; DOS Services  ah=function 40h
						;  write file  bx=file handle
						;   cx=bytes from ds:dx buffer

loc_ret_154:
		retn
sub_44		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_45		proc	near
		mov	cx,di
		mov	si,0Ah
		mov	bx,dx
		or	bx,bx			; Zero ?
		jns	short loc_155		; Jump if not sign
		neg	bx
		neg	ax
		sbb	bx,0
		call	sub_46
		dec	di
		mov	byte ptr es:[di],2Dh	; '-'
		inc	cx
		retn
sub_45		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_46		proc	near
loc_155:
		xor	dx,dx			; Zero register
		xchg	bx,ax
		div	si			; ax,dx rem=dx:ax/reg
		xchg	bx,ax
		div	si			; ax,dx rem=dx:ax/reg
		add	dl,30h			; '0'
		cmp	dl,3Ah			; ':'
		jb	short loc_156		; Jump if below
		add	dl,7
loc_156:
		dec	di
		mov	es:[di],dl
		mov	dx,ax
		or	dx,bx
		jnz	loc_155			; Jump if not zero
		sub	cx,di
		retn
sub_46		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_47		proc	near
		xor	ax,ax			; Zero register
		xor	dx,dx			; Zero register
		xor	si,si			; Zero register
		jcxz	short loc_163		; Jump if cx=0
		cmp	byte ptr es:[di],2Bh	; '+'
		je	short loc_157		; Jump if equal
		cmp	byte ptr es:[di],2Dh	; '-'
		jne	short loc_158		; Jump if not equal
		dec	si
loc_157:
		inc	di
		dec	cx
		jz	short loc_163		; Jump if zero
loc_158:
		cmp	byte ptr es:[di],24h	; '$'
		je	short loc_164		; Jump if equal

locloop_159:
		mov	bl,es:[di]
		sub	bl,3Ah			; ':'
		add	bl,0Ah
		jnc	short loc_160		; Jump if carry=0
		test	dh,0F0h
		jnz	short loc_163		; Jump if not zero
		push	bx
		shl	ax,1			; Shift w/zeros fill
		rcl	dx,1			; Rotate thru carry
		push	dx
		push	ax
		shl	ax,1			; Shift w/zeros fill
		rcl	dx,1			; Rotate thru carry
		shl	ax,1			; Shift w/zeros fill
		rcl	dx,1			; Rotate thru carry
		pop	bx
		add	ax,bx
		pop	bx
		adc	dx,bx
		pop	bx
		xor	bh,bh			; Zero register
		add	ax,bx
		adc	dx,0
		inc	di
		loop	locloop_159		; Loop if cx > 0

loc_160:
		mov	bx,ax
		or	bx,dx
		jz	short loc_ret_162	; Jump if zero
		or	si,si			; Zero ?
		jns	short loc_161		; Jump if not sign
		neg	dx
		neg	ax
		sbb	dx,0
loc_161:
		xor	si,dx
		js	short loc_163		; Jump if sign=1

loc_ret_162:
		retn
loc_163:
		stc				; Set carry flag
		retn
loc_164:
		inc	di
		dec	cx
		jz	loc_163			; Jump if zero

locloop_165:
		mov	bl,es:[di]
		cmp	bl,61h			; 'a'
		jb	short loc_166		; Jump if below
		sub	bl,20h			; ' '
loc_166:
		sub	bl,3Ah			; ':'
		add	bl,0Ah
		jc	short loc_167		; Jump if carry Set
		sub	bl,17h
		add	bl,6
		jnc	loc_160			; Jump if carry=0
		add	bl,0Ah
loc_167:
		mov	bh,4
loc_168:
		shl	ax,1			; Shift w/zeros fill
		rcl	dx,1			; Rotate thru carry
		jc	loc_163			; Jump if carry Set
		dec	bh
		jnz	loc_168			; Jump if not zero
		or	al,bl
		inc	di
		loop	locloop_165		; Loop if cx > 0

		or	si,si			; Zero ?
		jns	short loc_169		; Jump if not sign
		neg	dx
		neg	ax
		sbb	dx,0
loc_169:
		clc				; Clear carry flag
		retn
sub_47		endp


;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_48		proc	near
		mov	di,offset data_41
		push	ds
		pop	es
		mov	cx,3B4h
		sub	cx,di
		shr	cx,1			; Shift w/zeros fill
		xor	ax,ax			; Zero register
		cld				; Clear direction
		rep	stosw			; Rep when cx >0 Store ax to es:[di]
		retn
sub_48		endp

		db	7 dup (0)

seg_c		ends



;------------------------------------------------------------  seg_d   ----

seg_d		segment	byte public use16
		assume cs:seg_d  , ds:seg_d , ss:stack_seg_e

		db	0, 0, 0, 0
data_16		dw	0
		db	0, 0, 0, 0
data_17		dw	0
data_18		dw	0
data_19		dw	0
data_20		dw	0
		db	0, 0
data_21		dw	0FFFFh, 0
data_22		dw	0
		db	0, 0
data_24		dw	0
		db	0, 0
data_25		dw	0
		db	0, 0
data_26		dw	0
		db	0, 0, 0, 0
data_27		dw	0
data_28		dw	0			; segment storage
data_29		dd	00000h
data_31		dw	0
data_32		dw	0
data_33		dw	0
data_34		dw	0			; segment storage
data_35		dw	0
data_36		dw	0
		db	 00h, 00h, 00h, 00h, 00h, 10h
data_37		dw	40h
		db	 00h,0A0h
data_38		dw	0B000h
data_39		dw	0B800h
data_40		db	0
		db	 00h, 02h, 00h, 0Dh, 0Ah
data_41		db	0
		db	257 dup (0)
data_43		db	0
data_44		db	0
data_45		db	0
data_46		db	0
data_47		dw	0
data_48		db	0
		db	0
data_49		dw	0
data_51		dw	0
data_53		dw	0
data_54		dw	0
data_56		db	0
data_57		db	0
data_58		db	0
		db	513 dup (0)
data_59		db	0
		db	87 dup (0)

seg_d		ends



;------------------------------------------------------  stack_seg_e   ----

stack_seg_e	segment	word stack 'STACK' use16

		db	0
		db	16383 dup (0)

stack_seg_e	ends



		end	start
