ideal
p486

LptAdr	=	378h
XorMsk	=	80h

segment	code
assume	cs:code,ds:code

	org	41Ah
Head	dw	?
Tail	dw	?

	org	80h
PrmLen	db	?
Dlm	db	?
FName	db	14 dup (?)

	org	100h
@startup:
	push	0
	pop	fs

	in	al,21h
	push	ax
	mov	al,11111101b	; IRQ9 only
	out	21h,al

	mov	si,[fs:Tail]
	lea	di,[FBuf]

	mov	dx,LptAdr+1
	mov	al,0
	out	43h,al
	in	al,dx
	xor	al,XorMsk
	mov	ah,al
	in	al,40h
	mov	cl,al
	in	al,40h
	mov	ch,al

	xor	bx,bx
Scan:	mov	bp,bx		; ovf flag
	mov	al,0
	out	43h,al
	in	al,dx
	xor	al,XorMsk
	mov	bh,al
	in	al,40h
	mov	bl,al
	in	al,40h
	xchg	bh,al
	xchg	al,ah
	sub	bx,cx
	neg	bx		; (CX-BX) = (old-new) timer values (Dif)
	js	NoOvf
	or	bp,bp
	jns	NoOvf
	mov	[di],al
	inc	di
	mov	[word ptr di],0
	inc	di
	inc	di
NoOvf:	cmp	al,ah		; old & new port values
	jz	Same
	mov	[di],al		; value
	inc	di
	mov	[di],bx		; length
	inc	di
	inc	di
	sub	cx,bx		; corrected length
	xor	bx,bx
Same:	cmp	si,[fs:Tail]
	jnz	Done
	cmp	di,0FF00h
	jb	Scan

Done:	mov	bp,di
	not	al
	stosb
	pop	ax
	out	21h,al		; restore IRQ masks

	lea	bx,[Dlm]
	add	bl,[PrmLen]	; fname must be
	mov	[byte ptr bx],0	; finished by 0
	mov	di,bx

	lea	dx,[FName]
	xor	cx,cx
	mov	ah,3Ch		; create
	int	21h
	jc	Exit

	lea	dx,[FBuf]
	lea	cx,[bp+(0 - offset FBuf)]
	mov	bx,ax
	mov	ah,40h		; write
	int	21h

	mov	ah,3Eh		; close
	int	21h

	mov	bx,di
	mov	cx,5
	mov	al,'.'
	std
	repne scasb
	je	IsExt
	mov	di,bx
	dec	di
IsExt:	inc	di
	lea	si,[LnsExt]
	mov	cl,5
	cld
	rep movsb

	lea	dx,[FName]
	xor	cx,cx
	mov	ah,3Ch		; create
	int	21h
	jc	Exit

	mov	bx,ax
	lea	si,[FBuf]
Rec:	xor	edx,edx
Sum:	lodsb
	movzx	edi,[word ptr si]
	or	di,di
	jnz	Sum1
	inc	di
	shl	edi,16
Sum1:	add	edx,edi
	inc	si
	inc	si
	cmp	al,[si]
	jz	Sum
	rol	al,2
	and	al,3
	or	al,'0'
	lea	di,[LBuf]
	stosb
	inc	di

	push	si di

	mov	cl,10
DivLp:	xor	eax,eax
	xchg	eax,edx
	div	ecx
	xchg	eax,edx
	or	al,'0'
	stosb
	or	edx,edx
	jnz	DivLp

	pop	si
	lea	cx,[di+2]
	mov	[word ptr di],0A0Dh
	dec	di
Swap:	mov	al,[si]
	xchg	al,[di]
	mov	[si],al
	inc	si
	dec	di
	cmp	si,di
	jb	Swap
	pop	si

	lea	dx,[LBuf]
	sub	cx,dx
	mov	ah,40h		; write
	int	21h
	jc	WrErr

	cmp	si,bp
	jb	Rec

WrErr:	mov	ah,3Eh		; close
	int	21h

Exit:	cli
	mov	ax,[fs:Tail]
	mov	[fs:Head],ax	; reset keyboard buffer
	sti
	ret

LnsExt	db	'.lns',0
LBuf	db	'D 0987654321',13,10
FBuf	db	?

ends
end	@startup
