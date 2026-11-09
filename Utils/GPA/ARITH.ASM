	.286p
	ifndef	??version
?debug	macro
	endm
publicdll macro	name
	public	name
	endm
$comm	macro	name,dist,size,count
	comm	dist name:BYTE:count*size
	endm
	else
$comm	macro	name,dist,size,count
	comm	dist name[size]:BYTE:count
	endm
	endif
	?debug	V 301h
	?debug	S "arith.c"
	?debug	C E92124431D0761726974682E63
	?debug	C E94020CA1C15443A5C42435C494E434C5544455C737464696F2E68
	?debug	C E94020CA1C15443A5C42435C494E434C5544455C5F646566732E68
	?debug	C E9E31E3B1D16443A5C42435C494E434C5544455C5F6E66696C652E+
	?debug	C 68
	?debug	C E94020CA1C15443A5C42435C494E434C5544455C5F6E756C6C2E68
	?debug	C E94020CA1C16443A5C42435C494E434C5544455C7374646172672E+
	?debug	C 68
	?debug	C E94020CA1C16443A5C42435C494E434C5544455C7374646C69622E+
	?debug	C 68
	?debug	C E94020CA1C16443A5C42435C494E434C5544455C737472696E672E+
	?debug	C 68
	?debug	C E94020CA1C15443A5C42435C494E434C5544455C63747970652E68
	?debug	C E94020CA1C16443A5C42435C494E434C5544455C6D616C6C6F632E+
	?debug	C 68
	?debug	C E94020CA1C15443A5C42435C494E434C5544455C616C6C6F632E68
	?debug	C E94020CA1C16443A5C42435C494E434C5544455C6D656D6F72792E+
	?debug	C 68
	?debug	C E94020CA1C13443A5C42435C494E434C5544455C6D656D2E68
	?debug	C E9E90A3E1D0774797065732E68
	?debug	C E9D5313E1D09636F6E74726F6C2E68
	?debug	C E91D24431D0761726974682E68
ARITH_TEXT	segment word public 'CODE'
ARITH_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:ARITH_TEXT,ds:DGROUP
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_DATA	segment word public 'DATA'
_G_nstk	label	word
	db	0
	db	0
_DATA	ends
ARITH_TEXT	segment word public 'CODE'
   ;	
   ;	void _fastcall push(CHAR type,NUMB v)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@push	proc	far
	inc	bp
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
	mov	byte ptr [bp-1],al
   ;	
   ;	{
   ;		ENTRY(1990);
   ;	    if (G_nstk>=MAXSTACK) RETURN;
   ;	
	cmp	word ptr DGROUP:_G_nstk,50
	jl	@@0
	jmp	@1@310
@@0:
   ;	
   ;	
   ;	    G_stackt[G_nstk]=type;
   ;	
	mov	bx,word ptr DGROUP:_G_nstk
	mov	al,byte ptr [bp-1]
	mov	byte ptr DGROUP:_G_stackt[bx],al
   ;	
   ;	    switch (type) {
   ;	
	cbw	
	cmp	ax,110
	je	short @1@198
	cmp	ax,115
	je	short @1@226
	pop	di
	pop	si
	leave	
	dec	bp
	ret	4
@1@198:
   ;	
   ;	        case 'n' :
   ;	            *((NUMB *)G_stack[G_nstk++])=v;
   ;	
	mov	bx,word ptr DGROUP:_G_nstk
	imul	bx,bx,81
	mov	dx,word ptr [bp+8]
	mov	ax,word ptr [bp+6]
	mov	word ptr DGROUP:_G_stack[bx+2],dx
	mov	word ptr DGROUP:_G_stack[bx],ax
	inc	word ptr DGROUP:_G_nstk
   ;	
   ;	            break;
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	4
@1@226:
   ;	
   ;	        case 's':
   ;	            if (v) {
   ;	
	mov	ax,word ptr [bp+6]
	or	ax,word ptr [bp+8]
	je	short @1@282
   ;	
   ;	                strcpy(G_stack[G_nstk++],(CHAR*)v);
   ;	
	push	ds
	pop	es
	mov	di,word ptr DGROUP:_G_nstk
	inc	word ptr DGROUP:_G_nstk
	imul	di,di,81
	add	di,offset DGROUP:_G_stack
	push	es
	mov	es,word ptr [bp+8]
	push	di
	mov	di,word ptr [bp+6]
	cld	
	xor	ax,ax
	mov	cx,-1
	repnz 	scasb	
	not	cx
	sub	di,cx
	shr	cx,1
	mov	dx,word ptr [bp+8]
	mov	si,word ptr [bp+6]
	pop	di
	pop	es
	push	ds
	mov	ds,dx
	rep 	movsw	
	adc	cx,cx
	rep 	movsb	
	pop	ds
   ;	
   ;	            } else {
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	4
@1@282:
   ;	
   ;	                G_stack[G_nstk++][0]=0;
   ;	
	mov	bx,word ptr DGROUP:_G_nstk
	imul	bx,bx,81
	mov	byte ptr DGROUP:_G_stack[bx],0
	inc	word ptr DGROUP:_G_nstk
@1@310:
   ;	
   ;	            }
   ;	            break;
   ;	    }
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	4
@push	endp
   ;	
   ;	CHAR _fastcall pop(void *var)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@pop	proc	far
	inc	bp
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
   ;	
   ;	{
   ;	    CHAR type;
   ;		ENTRY(2000);
   ;	    if (!G_nstk) RETURNV(0);
   ;	
	cmp	word ptr DGROUP:_G_nstk,0
	jne	short @2@86
	mov	al,0
	pop	di
	pop	si
	leave	
	dec	bp
	ret	4
@2@86:
   ;	
   ;	    G_nstk--;
   ;	
	dec	word ptr DGROUP:_G_nstk
   ;	
   ;	    switch (type=G_stackt[G_nstk]) {
   ;	
	mov	bx,word ptr DGROUP:_G_nstk
	mov	al,byte ptr DGROUP:_G_stackt[bx]
	mov	byte ptr [bp-1],al
	cbw	
	cmp	ax,110
	je	short @2@226
	cmp	ax,115
	je	short @2@254
	jmp	short @2@366
@2@226:
   ;	
   ;	        case 'n' :
   ;	            *((NUMB *)var)=*((NUMB *)G_stack[G_nstk]);
   ;	
	mov	bx,word ptr DGROUP:_G_nstk
	imul	bx,bx,81
	mov	dx,word ptr DGROUP:_G_stack[bx+2]
	mov	ax,word ptr DGROUP:_G_stack[bx]
	les	bx,dword ptr [bp+6]
	mov	word ptr es:[bx+2],dx
	mov	word ptr es:[bx],ax
   ;	
   ;	            break;
   ;	
	jmp	short @2@366
@2@254:
   ;	
   ;	        case 's' :
   ;	            if (G_stack[G_nstk]) {
   ;	
	mov	ax,word ptr DGROUP:_G_nstk
	imul	ax,ax,81
	mov	dx,ds
	add	ax,offset DGROUP:_G_stack
	or	ax,dx
	je	short @2@310
   ;	
   ;	                strcpy(((CHAR *)var),(CHAR *)G_stack[G_nstk]);
   ;	
	push	ds
	pop	es
	mov	di,word ptr DGROUP:_G_nstk
	imul	di,di,81
	add	di,offset DGROUP:_G_stack
	mov	dx,word ptr [bp+8]
	mov	si,word ptr [bp+6]
	cld	
	xor	ax,ax
	mov	cx,-1
	repnz 	scasb	
	not	cx
	sub	di,cx
	shr	cx,1
	push	ds
	mov	ds,dx
	xchg	si,di
	mov	bx,ds
	mov	ax,es
	mov	ds,ax
	mov	es,bx
	rep 	movsw	
	adc	cx,cx
	rep 	movsb	
	pop	ds
   ;	
   ;	            } else {
   ;	
	jmp	short @2@366
@2@310:
   ;	
   ;	                if (var) *((CHAR *)var)=0;
   ;	
	mov	ax,word ptr [bp+6]
	or	ax,word ptr [bp+8]
	je	short @2@366
	les	bx,dword ptr [bp+6]
	mov	byte ptr es:[bx],0
@2@366:
   ;	
   ;	            }
   ;	            break;
   ;	    }
   ;	    RETURNV(type);
   ;	
	mov	al,byte ptr [bp-1]
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	4
@pop	endp
   ;	
   ;	CHAR _fastcall stktype(INT place)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@stktype	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2010);
   ;	    if (place>=G_nstk) RETURNV(0);
   ;	
	cmp	ax,word ptr DGROUP:_G_nstk
	jl	short @3@86
	mov	al,0
	pop	di
	pop	si
	ret	
@3@86:
   ;	
   ;	    RETURNV(G_stackt[G_nstk-(place+1)]);
   ;	
	mov	dx,ax
	inc	dx
	mov	bx,word ptr DGROUP:_G_nstk
	sub	bx,dx
	mov	al,byte ptr DGROUP:_G_stackt[bx]
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@stktype	endp
   ;	
   ;	CHAR _fastcall stknum(INT place,NUMB *n)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@stknum	proc	far
	inc	bp
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	push	di
	mov	word ptr [bp-2],ax
   ;	
   ;	{
   ;	    CHAR t;
   ;		ENTRY(2020);
   ;	    switch (t=stktype(place)) {
   ;	
	mov	ax,word ptr [bp-2]
	push	cs
	call	near ptr @stktype
	mov	byte ptr [bp-3],al
	cbw	
	cmp	ax,110
	je	short @4@142
	cmp	ax,115
	je	short @4@170
	jmp	short @4@198
@4@142:
   ;	
   ;	        case 'n' :
   ;	            *n=*((NUMB *)G_stack[G_nstk-(place+1)]);
   ;	
	mov	dx,word ptr [bp-2]
	inc	dx
	mov	bx,word ptr DGROUP:_G_nstk
	sub	bx,dx
	imul	bx,bx,81
	mov	dx,word ptr DGROUP:_G_stack[bx+2]
	mov	bx,word ptr DGROUP:_G_stack[bx]
	les	si,dword ptr [bp+6]
	mov	word ptr es:[si+2],dx
	mov	word ptr es:[si],bx
   ;	
   ;	            break;
   ;	
	jmp	short @4@198
@4@170:
   ;	
   ;	        case 's' :
   ;	            *n=ATON(G_stack[G_nstk-(place+1)]);
   ;	
	push	ds
	mov	dx,word ptr [bp-2]
	inc	dx
	mov	bx,word ptr DGROUP:_G_nstk
	sub	bx,dx
	imul	bx,bx,81
	add	bx,offset DGROUP:_G_stack
	push	bx
	call	far ptr _atol
	add	sp,4
	les	bx,dword ptr [bp+6]
	mov	word ptr es:[bx+2],dx
	mov	word ptr es:[bx],ax
   ;	
   ;	            break;
   ;	
@4@198:
   ;	
   ;	    }
   ;	    RETURNV(t);
   ;	
	mov	al,byte ptr [bp-3]
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	4
@stknum	endp
   ;	
   ;	CHAR _fastcall stkstr(INT place,CHAR *s)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@stkstr	proc	far
	inc	bp
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
	push	di
	mov	word ptr [bp-2],ax
   ;	
   ;	{
   ;	    CHAR t;
   ;		ENTRY(2030);
   ;	    switch (t=stktype(place)) {
   ;	
	mov	ax,word ptr [bp-2]
	push	cs
	call	near ptr @stktype
	mov	byte ptr [bp-3],al
	cbw	
	cmp	ax,110
	je	short @5@142
	cmp	ax,115
	jne	short @5@170
   ;	
   ;	        case 's' :
   ;	            strcpy(s,G_stack[G_nstk-(place+1)]);
   ;	
	push	ds
	pop	es
	mov	ax,word ptr [bp-2]
	inc	ax
	mov	di,word ptr DGROUP:_G_nstk
	sub	di,ax
	imul	di,di,81
	add	di,offset DGROUP:_G_stack
	mov	dx,word ptr [bp+8]
	mov	si,word ptr [bp+6]
	cld	
	xor	ax,ax
	mov	cx,-1
	repnz 	scasb	
	not	cx
	sub	di,cx
	shr	cx,1
	push	ds
	mov	ds,dx
	xchg	si,di
	mov	bx,ds
	mov	ax,es
	mov	ds,ax
	mov	es,bx
	rep 	movsw	
	adc	cx,cx
	rep 	movsb	
	pop	ds
   ;	
   ;	            break;
   ;	
	jmp	short @5@170
@5@142:
   ;	
   ;	        case 'n' :
   ;	            NTOA(s,*((NUMB *)G_stack[G_nstk-(place+1)]));
   ;	
	push	10
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	mov	ax,word ptr [bp-2]
	inc	ax
	mov	bx,word ptr DGROUP:_G_nstk
	sub	bx,ax
	imul	bx,bx,81
	push	word ptr DGROUP:_G_stack[bx+2]
	push	word ptr DGROUP:_G_stack[bx]
	call	far ptr _ltoa
	add	sp,10
   ;	
   ;	            break;
   ;	
@5@170:
   ;	
   ;	    }
   ;	    RETURNV(t);
   ;	
	mov	al,byte ptr [bp-3]
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	4
@stkstr	endp
   ;	
   ;	INT _fastcall stksize(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@stksize	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2040);
   ;	    RETURNV(G_nstk);
   ;	
	mov	ax,word ptr DGROUP:_G_nstk
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@stksize	endp
   ;	
   ;	LONG _fastcall popl(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@popl	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2050);
   ;	    getnum();
   ;	
	call	far ptr @getnum
   ;	
   ;	    RETURNV((LONG)G_n1);
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@popl	endp
   ;	
   ;	void _fastcall get2strs(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@get2strs	proc	far
	inc	bp
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
   ;	
   ;	{
   ;	    char t1,t0;
   ;		ENTRY(2060);
   ;	    t1=stktype(1);
   ;	
	mov	ax,1
	push	cs
	call	near ptr @stktype
	mov	byte ptr [bp-1],al
   ;	
   ;	    if (!t1) RETURN;
   ;	
	cmp	byte ptr [bp-1],0
	jne	@@1
	jmp	@8@282
@@1:
   ;	
   ;	    t0=stktype(0);
   ;	
	xor	ax,ax
	push	cs
	call	near ptr @stktype
	mov	dl,al
   ;	
   ;	    if (t0==t1) {
   ;	
	cmp	dl,byte ptr [bp-1]
	jne	short @8@198
   ;	
   ;	        if (t0=='n') {
   ;	
	cmp	dl,110
	jne	short @8@170
   ;	
   ;	            POP(&G_n2);
   ;	
	push	ds
	push	offset DGROUP:_G_n2
	push	cs
	call	near ptr @pop
   ;	
   ;	            NTOA(G_s2,G_n2);
   ;	
	push	10
	push	ds
	push	offset DGROUP:_G_s2
	push	word ptr DGROUP:_G_n2+2
	push	word ptr DGROUP:_G_n2
	call	far ptr _ltoa
	add	sp,10
@8@142:
   ;	
   ;	            POP(&G_n1);
   ;	
	push	ds
	push	offset DGROUP:_G_n1
	push	cs
	call	near ptr @pop
   ;	
   ;	            NTOA(G_s1,G_n1);
   ;	
	push	10
	push	ds
	push	offset DGROUP:_G_s1
	push	word ptr DGROUP:_G_n1+2
	push	word ptr DGROUP:_G_n1
	call	far ptr _ltoa
	add	sp,10
   ;	
   ;	        } else {
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	
@8@170:
   ;	
   ;	            POP(&G_s2);
   ;	
	push	ds
	push	offset DGROUP:_G_s2
	push	cs
	call	near ptr @pop
   ;	
   ;	            POP(&G_s1);
   ;	
	push	ds
	push	offset DGROUP:_G_s1
	push	cs
	call	near ptr @pop
	pop	di
	pop	si
	leave	
	dec	bp
	ret	
@8@198:
   ;	
   ;	        }
   ;	    } else {
   ;	        if (t0=='s') {
   ;	
	cmp	dl,115
	jne	short @8@254
   ;	
   ;	            POP(&G_s2);
   ;	
	push	ds
	push	offset DGROUP:_G_s2
	push	cs
	call	near ptr @pop
	jmp	short @8@142
@8@254:
   ;	
   ;	            POP(&G_n1);
   ;	            NTOA(G_s1,G_n1);
   ;	        } else {
   ;	            POP(&G_n2);
   ;	
	push	ds
	push	offset DGROUP:_G_n2
	push	cs
	call	near ptr @pop
   ;	
   ;	            NTOA(G_s2,G_n2);
   ;	
	push	10
	push	ds
	push	offset DGROUP:_G_s2
	push	word ptr DGROUP:_G_n2+2
	push	word ptr DGROUP:_G_n2
	call	far ptr _ltoa
	add	sp,10
   ;	
   ;	            POP(&G_s1);
   ;	
	push	ds
	push	offset DGROUP:_G_s1
	push	cs
	call	near ptr @pop
@8@282:
   ;	
   ;	        }
   ;	    }
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	
@get2strs	endp
   ;	
   ;	void _fastcall get2nums(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@get2nums	proc	far
	inc	bp
	push	bp
	mov	bp,sp
	sub	sp,2
	push	si
	push	di
   ;	
   ;	{
   ;	    char t1,t0;
   ;		ENTRY(2070);
   ;	    t1=stktype(1);
   ;	
	mov	ax,1
	push	cs
	call	near ptr @stktype
	mov	byte ptr [bp-1],al
   ;	
   ;	    if (!t1) RETURN;
   ;	
	cmp	byte ptr [bp-1],0
	jne	@@2
	jmp	@9@282
@@2:
   ;	
   ;	    t0=stktype(0);
   ;	
	xor	ax,ax
	push	cs
	call	near ptr @stktype
	mov	dl,al
   ;	
   ;	
   ;	    if (t0==t1) {
   ;	
	cmp	dl,byte ptr [bp-1]
	jne	short @9@198
   ;	
   ;	        if (t0=='n') {
   ;	
	cmp	dl,110
	jne	short @9@142
   ;	
   ;	            POP(&G_n2);
   ;	
	push	ds
	push	offset DGROUP:_G_n2
	push	cs
	call	near ptr @pop
   ;	
   ;	            POP(&G_n1);
   ;	
	push	ds
	push	offset DGROUP:_G_n1
	push	cs
	call	near ptr @pop
   ;	
   ;	        } else {
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	
@9@142:
   ;	
   ;	            POP(&G_s2);
   ;	
	push	ds
	push	offset DGROUP:_G_s2
	push	cs
	call	near ptr @pop
   ;	
   ;	            G_n2=ATON(G_s2);
   ;	
	push	ds
	push	offset DGROUP:_G_s2
	call	far ptr _atol
	add	sp,4
	mov	word ptr DGROUP:_G_n2+2,dx
	mov	word ptr DGROUP:_G_n2,ax
@9@170:
   ;	
   ;	            POP(&G_s1);
   ;	
	push	ds
	push	offset DGROUP:_G_s1
	push	cs
	call	near ptr @pop
   ;	
   ;	            G_n1=ATON(G_s1);
   ;	
	push	ds
	push	offset DGROUP:_G_s1
	call	far ptr _atol
	add	sp,4
	mov	word ptr DGROUP:_G_n1+2,dx
	mov	word ptr DGROUP:_G_n1,ax
	pop	di
	pop	si
	leave	
	dec	bp
	ret	
@9@198:
   ;	
   ;	        }
   ;	    } else {
   ;	        if (t0=='s') {
   ;	
	cmp	dl,115
	jne	short @9@254
   ;	
   ;	            POP(&G_s2);
   ;	
	push	ds
	push	offset DGROUP:_G_s2
	push	cs
	call	near ptr @pop
   ;	
   ;	            G_n2=ATON(G_s2);
   ;	
	push	ds
	push	offset DGROUP:_G_s2
	call	far ptr _atol
	add	sp,4
	mov	word ptr DGROUP:_G_n2+2,dx
	mov	word ptr DGROUP:_G_n2,ax
   ;	
   ;	            POP(&G_n1);
   ;	
	push	ds
	push	offset DGROUP:_G_n1
	push	cs
	call	near ptr @pop
   ;	
   ;	        } else {
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	
@9@254:
   ;	
   ;	            POP(&G_n2);
   ;	
	push	ds
	push	offset DGROUP:_G_n2
	push	cs
	call	near ptr @pop
	jmp	short @9@170
@9@282:
   ;	
   ;	            POP(&G_s1);
   ;	            G_n1=ATON(G_s1);
   ;	        }
   ;	    }
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	
@get2nums	endp
   ;	
   ;	void _fastcall getnum(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@getnum	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;	    char t;
   ;		ENTRY(2080);
   ;	    t=stktype(0);
   ;	
	xor	ax,ax
	push	cs
	call	near ptr @stktype
	mov	dl,al
   ;	
   ;	    if (!t) RETURN;
   ;	
	or	dl,dl
	je	short @10@142
   ;	
   ;	
   ;	    if (t=='n') {
   ;	
	cmp	dl,110
	jne	short @10@114
   ;	
   ;	        POP(&G_n1);
   ;	
	push	ds
	push	offset DGROUP:_G_n1
	push	cs
	call	near ptr @pop
   ;	
   ;	    } else {
   ;	
	pop	di
	pop	si
	ret	
@10@114:
   ;	
   ;	        POP(&G_s1);
   ;	
	push	ds
	push	offset DGROUP:_G_s1
	push	cs
	call	near ptr @pop
   ;	
   ;	        G_n1=ATON(G_s1);
   ;	
	push	ds
	push	offset DGROUP:_G_s1
	call	far ptr _atol
	add	sp,4
	mov	word ptr DGROUP:_G_n1+2,dx
	mov	word ptr DGROUP:_G_n1,ax
@10@142:
   ;	
   ;	    }
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@getnum	endp
   ;	
   ;	CHAR * _fastcall pops(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@pops	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2090);
   ;	    getstr();
   ;	
	call	far ptr @getstr
   ;	
   ;	    RETURNV(G_s1);
   ;	
	mov	dx,ds
	mov	ax,offset DGROUP:_G_s1
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@pops	endp
   ;	
   ;	void _fastcall getstr(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@getstr	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;	    char t;
   ;		ENTRY(2100);
   ;	    t=stktype(0);
   ;	
	xor	ax,ax
	push	cs
	call	near ptr @stktype
	mov	dl,al
   ;	
   ;	    if (!t) RETURN;
   ;	
	or	dl,dl
	je	short @12@142
   ;	
   ;	
   ;	    if (t=='n') {
   ;	
	cmp	dl,110
	jne	short @12@114
   ;	
   ;	        POP(&G_n1);
   ;	
	push	ds
	push	offset DGROUP:_G_n1
	push	cs
	call	near ptr @pop
   ;	
   ;	        NTOA(G_s1,G_n1);
   ;	
	push	10
	push	ds
	push	offset DGROUP:_G_s1
	push	word ptr DGROUP:_G_n1+2
	push	word ptr DGROUP:_G_n1
	call	far ptr _ltoa
	add	sp,10
   ;	
   ;	    } else {
   ;	
	pop	di
	pop	si
	ret	
@12@114:
   ;	
   ;	        POP(&G_s1);
   ;	
	push	ds
	push	offset DGROUP:_G_s1
	push	cs
	call	near ptr @pop
@12@142:
   ;	
   ;	    }
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@getstr	endp
   ;	
   ;	void _fastcall add(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@add	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2110);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((G_n1+G_n2));
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	add	ax,word ptr DGROUP:_G_n2
	adc	dx,word ptr DGROUP:_G_n2+2
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@add	endp
   ;	
   ;	void _fastcall sub(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@sub	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2120);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((G_n1-G_n2));
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	sub	ax,word ptr DGROUP:_G_n2
	sbb	dx,word ptr DGROUP:_G_n2+2
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@sub	endp
   ;	
   ;	void _fastcall mul(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@mul	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2130);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((G_n1*G_n2));
   ;	
	mov	cx,word ptr DGROUP:_G_n1+2
	mov	bx,word ptr DGROUP:_G_n1
	mov	dx,word ptr DGROUP:_G_n2+2
	mov	ax,word ptr DGROUP:_G_n2
	call	far ptr F_LXMUL@
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@mul	endp
   ;	
   ;	void _fastcall divide(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@divide	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2140);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    if (G_n2)
   ;	
	mov	ax,word ptr DGROUP:_G_n2
	or	ax,word ptr DGROUP:_G_n2+2
	je	short @16@114
   ;	
   ;	        PUSHN((G_n1/G_n2));
   ;	
	push	word ptr DGROUP:_G_n2+2
	push	word ptr DGROUP:_G_n2
	push	word ptr DGROUP:_G_n1+2
	push	word ptr DGROUP:_G_n1
	call	far ptr F_LDIV@
	push	dx
	push	ax
@16@86:
	mov	al,110
	push	cs
	call	near ptr @push
	pop	di
	pop	si
	ret	
@16@114:
   ;	
   ;	    else
   ;	        PUSHN(0);
   ;	
	push	0
	push	0
	jmp	short @16@86
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@divide	endp
   ;	
   ;	void _fastcall mod(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@mod	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2150);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    if (G_n2)
   ;	
	mov	ax,word ptr DGROUP:_G_n2
	or	ax,word ptr DGROUP:_G_n2+2
	je	short @17@114
   ;	
   ;	        PUSHN(((LONG)G_n1%(LONG)G_n2));
   ;	
	push	word ptr DGROUP:_G_n2+2
	push	word ptr DGROUP:_G_n2
	push	word ptr DGROUP:_G_n1+2
	push	word ptr DGROUP:_G_n1
	call	far ptr F_LMOD@
	push	dx
	push	ax
@17@86:
	mov	al,110
	push	cs
	call	near ptr @push
	pop	di
	pop	si
	ret	
@17@114:
   ;	
   ;	    else
   ;	        PUSHN(0);
   ;	
	push	0
	push	0
	jmp	short @17@86
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@mod	endp
   ;	
   ;	void _fastcall land(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@land	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2160);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((G_n1&&G_n2));
   ;	
	mov	ax,word ptr DGROUP:_G_n1
	or	ax,word ptr DGROUP:_G_n1+2
	je	short @18@114
	mov	ax,word ptr DGROUP:_G_n2
	or	ax,word ptr DGROUP:_G_n2+2
	je	short @18@114
	mov	ax,1
	jmp	short @18@142
@18@114:
	xor	ax,ax
@18@142:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@land	endp
   ;	
   ;	void _fastcall lor(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@lor	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2170);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((G_n1||G_n2));
   ;	
	mov	ax,word ptr DGROUP:_G_n1
	or	ax,word ptr DGROUP:_G_n1+2
	jne	short @19@86
	mov	ax,word ptr DGROUP:_G_n2
	or	ax,word ptr DGROUP:_G_n2+2
	je	short @19@114
@19@86:
	mov	ax,1
	jmp	short @19@142
@19@114:
	xor	ax,ax
@19@142:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@lor	endp
   ;	
   ;	void _fastcall lxor(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@lxor	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2180);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((((LONG)G_n1^(LONG)G_n2)!=0));
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	xor	ax,word ptr DGROUP:_G_n2
	xor	dx,word ptr DGROUP:_G_n2+2
	or	ax,dx
	je	short @20@86
	mov	ax,1
	jmp	short @20@114
@20@86:
	xor	ax,ax
@20@114:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@lxor	endp
   ;	
   ;	void _fastcall lnot(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@lnot	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2190);
   ;	    getnum();
   ;	
	push	cs
	call	near ptr @getnum
   ;	
   ;	    PUSHN((!G_n1));
   ;	
	mov	ax,word ptr DGROUP:_G_n1
	or	ax,word ptr DGROUP:_G_n1+2
	jne	short @21@86
	mov	ax,1
	jmp	short @21@114
@21@86:
	xor	ax,ax
@21@114:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@lnot	endp
   ;	
   ;	void _fastcall equal(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@equal	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2200);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((G_n1==G_n2));
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	cmp	dx,word ptr DGROUP:_G_n2+2
	jne	short @22@114
	cmp	ax,word ptr DGROUP:_G_n2
	jne	short @22@114
	mov	ax,1
	jmp	short @22@142
@22@114:
	xor	ax,ax
@22@142:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@equal	endp
   ;	
   ;	void _fastcall notequal(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@notequal	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2210);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((G_n1!=G_n2));
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	cmp	dx,word ptr DGROUP:_G_n2+2
	jne	short @23@86
	cmp	ax,word ptr DGROUP:_G_n2
	je	short @23@114
@23@86:
	mov	ax,1
	jmp	short @23@142
@23@114:
	xor	ax,ax
@23@142:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@notequal	endp
   ;	
   ;	void _fastcall less(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@less	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2220);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((G_n1<G_n2));
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	cmp	dx,word ptr DGROUP:_G_n2+2
	jg	short @24@142
	jl	short @24@114
	cmp	ax,word ptr DGROUP:_G_n2
	jae	short @24@142
@24@114:
	mov	ax,1
	jmp	short @24@170
@24@142:
	xor	ax,ax
@24@170:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@less	endp
   ;	
   ;	void _fastcall lessequal(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@lessequal	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2230);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((G_n1<=G_n2));
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	cmp	dx,word ptr DGROUP:_G_n2+2
	jg	short @25@142
	jne	short @25@114
	cmp	ax,word ptr DGROUP:_G_n2
	ja	short @25@142
@25@114:
	mov	ax,1
	jmp	short @25@170
@25@142:
	xor	ax,ax
@25@170:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@lessequal	endp
   ;	
   ;	void _fastcall great(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@great	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2240);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((G_n1>G_n2));
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	cmp	dx,word ptr DGROUP:_G_n2+2
	jl	short @26@142
	jg	short @26@114
	cmp	ax,word ptr DGROUP:_G_n2
	jbe	short @26@142
@26@114:
	mov	ax,1
	jmp	short @26@170
@26@142:
	xor	ax,ax
@26@170:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@great	endp
   ;	
   ;	void _fastcall greatequal(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@greatequal	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2250);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    PUSHN((G_n1>=G_n2));
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	cmp	dx,word ptr DGROUP:_G_n2+2
	jl	short @27@142
	jne	short @27@114
	cmp	ax,word ptr DGROUP:_G_n2
	jb	short @27@142
@27@114:
	mov	ax,1
	jmp	short @27@170
@27@142:
	xor	ax,ax
@27@170:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@greatequal	endp
   ;	
   ;	void _fastcall not(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@not	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2260);
   ;	    getnum();
   ;	
	push	cs
	call	near ptr @getnum
   ;	
   ;	    PUSHN((~(LONG)G_n1));
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	not	ax
	not	dx
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@not	endp
   ;	
   ;	void _fastcall neg(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@neg	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2270);
   ;	    getnum();
   ;	
	push	cs
	call	near ptr @getnum
   ;	
   ;	    PUSHN((-G_n1));
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	neg	dx
	neg	ax
	sbb	dx,0
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@neg	endp
   ;	
   ;	void _fastcall sequal(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@sequal	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2280);
   ;	    get2strs();
   ;	
	push	cs
	call	near ptr @get2strs
   ;	
   ;	    PUSHN((strcmp(G_s1,G_s2)==0));
   ;	
	mov	si,offset DGROUP:_G_s1
	push	ds
	pop	es
	mov	di,offset DGROUP:_G_s2
	cld	
	xor	ax,ax
	mov	cx,-1
	repnz 	scasb	
	not	cx
	sub	di,cx
	xor	ax,ax
	repz 	cmpsb	
	je	short @30@86
	sbb	ax,ax
	sbb	ax,-1
@30@86:
	or	ax,ax
	jne	short @30@142
	mov	ax,1
	jmp	short @30@170
@30@142:
	xor	ax,ax
@30@170:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@sequal	endp
   ;	
   ;	void _fastcall snotequal(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@snotequal	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2290);
   ;	    get2strs();
   ;	
	push	cs
	call	near ptr @get2strs
   ;	
   ;	    PUSHN((strcmp(G_s1,G_s2)!=0));
   ;	
	mov	si,offset DGROUP:_G_s1
	push	ds
	pop	es
	mov	di,offset DGROUP:_G_s2
	cld	
	xor	ax,ax
	mov	cx,-1
	repnz 	scasb	
	not	cx
	sub	di,cx
	xor	ax,ax
	repz 	cmpsb	
	je	short @31@86
	sbb	ax,ax
	sbb	ax,-1
@31@86:
	or	ax,ax
	je	short @31@142
	mov	ax,1
	jmp	short @31@170
@31@142:
	xor	ax,ax
@31@170:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@snotequal	endp
   ;	
   ;	void _fastcall sless(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@sless	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2300);
   ;	    get2strs();
   ;	
	push	cs
	call	near ptr @get2strs
   ;	
   ;	    PUSHN((strcmp(G_s1,G_s2)<0));
   ;	
	mov	si,offset DGROUP:_G_s1
	push	ds
	pop	es
	mov	di,offset DGROUP:_G_s2
	cld	
	xor	ax,ax
	mov	cx,-1
	repnz 	scasb	
	not	cx
	sub	di,cx
	xor	ax,ax
	repz 	cmpsb	
	je	short @32@86
	sbb	ax,ax
	sbb	ax,-1
@32@86:
	or	ax,ax
	jge	short @32@142
	mov	ax,1
	jmp	short @32@170
@32@142:
	xor	ax,ax
@32@170:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@sless	endp
   ;	
   ;	void _fastcall slessequal(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@slessequal	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2310);
   ;	    get2strs();
   ;	
	push	cs
	call	near ptr @get2strs
   ;	
   ;	    PUSHN((strcmp(G_s1,G_s2)<=0));
   ;	
	mov	si,offset DGROUP:_G_s1
	push	ds
	pop	es
	mov	di,offset DGROUP:_G_s2
	cld	
	xor	ax,ax
	mov	cx,-1
	repnz 	scasb	
	not	cx
	sub	di,cx
	xor	ax,ax
	repz 	cmpsb	
	je	short @33@86
	sbb	ax,ax
	sbb	ax,-1
@33@86:
	or	ax,ax
	jg	short @33@142
	mov	ax,1
	jmp	short @33@170
@33@142:
	xor	ax,ax
@33@170:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@slessequal	endp
   ;	
   ;	void _fastcall sgreat(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@sgreat	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2320);
   ;	    get2strs();
   ;	
	push	cs
	call	near ptr @get2strs
   ;	
   ;	    PUSHN((strcmp(G_s1,G_s2)>0));
   ;	
	mov	si,offset DGROUP:_G_s1
	push	ds
	pop	es
	mov	di,offset DGROUP:_G_s2
	cld	
	xor	ax,ax
	mov	cx,-1
	repnz 	scasb	
	not	cx
	sub	di,cx
	xor	ax,ax
	repz 	cmpsb	
	je	short @34@86
	sbb	ax,ax
	sbb	ax,-1
@34@86:
	or	ax,ax
	jle	short @34@142
	mov	ax,1
	jmp	short @34@170
@34@142:
	xor	ax,ax
@34@170:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@sgreat	endp
   ;	
   ;	void _fastcall sgreatequal(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@sgreatequal	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2330);
   ;	    get2strs();
   ;	
	push	cs
	call	near ptr @get2strs
   ;	
   ;	    PUSHN((strcmp(G_s1,G_s2)>=0));
   ;	
	mov	si,offset DGROUP:_G_s1
	push	ds
	pop	es
	mov	di,offset DGROUP:_G_s2
	cld	
	xor	ax,ax
	mov	cx,-1
	repnz 	scasb	
	not	cx
	sub	di,cx
	xor	ax,ax
	repz 	cmpsb	
	je	short @35@86
	sbb	ax,ax
	sbb	ax,-1
@35@86:
	or	ax,ax
	jl	short @35@142
	mov	ax,1
	jmp	short @35@170
@35@142:
	xor	ax,ax
@35@170:
	cwd	
	push	dx
	push	ax
	mov	al,110
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@sgreatequal	endp
   ;	
   ;	void _fastcall sjoin(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@sjoin	proc	far
	inc	bp
	push	bp
	mov	bp,sp
	sub	sp,160
	push	si
	push	di
   ;	
   ;	{
   ;	    CHAR tmp[MAXSTRLEN*2];
   ;		ENTRY(2340);
   ;	    get2strs();
   ;	
	push	cs
	call	near ptr @get2strs
   ;	
   ;	    strcpy(tmp,G_s1);
   ;	
	mov	ax,ss
	lea	si,word ptr [bp-160]
	push	ds
	pop	es
	mov	di,offset DGROUP:_G_s1
	cld	
	push	ax
	xor	ax,ax
	mov	cx,-1
	repnz 	scasb	
	not	cx
	sub	di,cx
	shr	cx,1
	mov	ax,ds
	pop	ds
	push	ax
	xchg	si,di
	mov	bx,ds
	mov	ax,es
	mov	ds,ax
	mov	es,bx
	rep 	movsw	
	adc	cx,cx
	rep 	movsb	
	pop	ds
   ;	
   ;	    strcat(tmp,G_s2);
   ;	
	mov	ax,ss
	lea	si,word ptr [bp-160]
	push	ds
	pop	es
	mov	di,offset DGROUP:_G_s2
	cld	
	push	ax
	xor	ax,ax
	mov	cx,-1
	repnz 	scasb	
	not	cx
	sub	di,cx
	mov	ax,ds
	pop	ds
	push	ax
	xchg	si,di
	mov	bx,ds
	mov	ax,es
	mov	ds,ax
	mov	es,bx
	push	cx
	mov	cx,-1
	xor	ax,ax
	repnz 	scasb	
	dec	di
	pop	cx
	rep 	movsb	
	pop	ds
   ;	
   ;	    PUSHS(tmp);
   ;	
	lea	ax,word ptr [bp-160]
	push	ss
	push	ax
	mov	al,115
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	dec	bp
	ret	
@sjoin	endp
   ;	
   ;	void _fastcall scut(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
@scut	proc	far
	push	si
	push	di
   ;	
   ;	{
   ;		ENTRY(2350);
   ;	    get2nums();
   ;	
	push	cs
	call	near ptr @get2nums
   ;	
   ;	    if (G_n1>G_n2) { G_n0=G_n1; G_n1=G_n2; G_n2=G_n0; }
   ;	
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	cmp	dx,word ptr DGROUP:_G_n2+2
	jl	short @37@142
	jg	short @37@114
	cmp	ax,word ptr DGROUP:_G_n2
	jbe	short @37@142
@37@114:
	mov	dx,word ptr DGROUP:_G_n1+2
	mov	ax,word ptr DGROUP:_G_n1
	mov	word ptr DGROUP:_G_n0+2,dx
	mov	word ptr DGROUP:_G_n0,ax
	mov	dx,word ptr DGROUP:_G_n2+2
	mov	ax,word ptr DGROUP:_G_n2
	mov	word ptr DGROUP:_G_n1+2,dx
	mov	word ptr DGROUP:_G_n1,ax
	mov	dx,word ptr DGROUP:_G_n0+2
	mov	ax,word ptr DGROUP:_G_n0
	mov	word ptr DGROUP:_G_n2+2,dx
	mov	word ptr DGROUP:_G_n2,ax
@37@142:
   ;	
   ;	    if (G_n2>=MAXSTRLEN) G_n2=MAXSTRLEN-1;
   ;	
	cmp	word ptr DGROUP:_G_n2+2,0
	jl	short @37@254
	jne	short @37@226
	cmp	word ptr DGROUP:_G_n2,80
	jb	short @37@254
@37@226:
	mov	word ptr DGROUP:_G_n2+2,0
	mov	word ptr DGROUP:_G_n2,79
@37@254:
   ;	
   ;	
   ;	    getstr();
   ;	
	push	cs
	call	near ptr @getstr
   ;	
   ;	    G_s1[(INT)(G_n2)+1]=0;
   ;	
	mov	bx,word ptr DGROUP:_G_n2
	mov	byte ptr DGROUP:_G_s1[bx+1],0
   ;	
   ;	    PUSHS(&G_s1[(INT)(G_n1)]);
   ;	
	mov	ax,word ptr DGROUP:_G_n1
	add	ax,offset DGROUP:_G_s1
	push	ds
	push	ax
	mov	al,115
	push	cs
	call	near ptr @push
   ;	
   ;		RETURN;
   ;	}
   ;	
	pop	di
	pop	si
	ret	
@scut	endp
   ;	
   ;	void arithend(void)
   ;	
	assume	cs:ARITH_TEXT,ds:DGROUP
_arithend	proc	far
	push	si
	push	di
	jmp	short @38@86
@38@58:
   ;	
   ;	{
   ;		ENTRY(2360);
   ;	 	while (G_nstk) {
   ;			getstr();
   ;	
	push	cs
	call	near ptr @getstr
   ;	
   ;			printf("%s",G_s1);
   ;	
	push	ds
	push	offset DGROUP:_G_s1
	push	ds
	push	offset DGROUP:s@
	call	far ptr _printf
	add	sp,8
@38@86:
	cmp	word ptr DGROUP:_G_nstk,0
	jne	short @38@58
   ;	
   ;		}
   ;		RETURN;
   ;	
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	ret	
_arithend	endp
ARITH_TEXT	ends
_BSS	segment word public 'BSS'
_G_n0	label	word
	db	4 dup (?)
_G_n1	label	word
	db	4 dup (?)
_G_n2	label	word
	db	4 dup (?)
_G_s0	label	byte
	db	80 dup (?)
_G_s1	label	byte
	db	80 dup (?)
_G_s2	label	byte
	db	80 dup (?)
_G_stack	label	byte
	db	4050 dup (?)
_G_stackt	label	byte
	db	50 dup (?)
	?debug	C E9
	?debug	C FA90000000
_BSS	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	'%s'
	db	0
_DATA	ends
ARITH_TEXT	segment word public 'CODE'
ARITH_TEXT	ends
_s@	equ	s@
	extrn	_printf:far
	extrn	_atol:far
	extrn	_ltoa:far
	public	_G_n0
	public	_G_n1
	public	_G_n2
	public	_G_s0
	public	_G_s1
	public	_G_s2
	public	_G_stack
	public	_G_stackt
	public	_G_nstk
	public	@push
	public	@pop
	public	@stktype
	public	@stknum
	public	@stkstr
	public	@stksize
	public	@popl
	public	@pops
	public	@add
	public	@sub
	public	@mul
	public	@land
	public	@lor
	public	@lxor
	public	@lnot
	public	@equal
	public	@notequal
	public	@less
	public	@lessequal
	public	@great
	public	@greatequal
	public	@not
	public	@neg
	public	@sequal
	public	@snotequal
	public	@sless
	public	@slessequal
	public	@sgreat
	public	@sgreatequal
	public	@divide
	public	@mod
	public	@sjoin
	public	@scut
	public	@get2strs
	public	@get2nums
	public	@getnum
	public	@getstr
	public	_arithend
	extrn	F_LXMUL@:far
	extrn	F_LDIV@:far
	extrn	F_LMOD@:far
	end
