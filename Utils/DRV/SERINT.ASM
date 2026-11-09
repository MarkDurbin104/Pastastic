	.386p
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
	?debug	V 300h
	?debug	S "serint.c"
	?debug	C E9E084411C08736572696E742E63
	?debug	C E94019CA1813443A5C42435C494E434C5544455C646F732E68
	?debug	C E94019CA1815443A5C42435C494E434C5544455C5F646566732E68
	?debug	C E94019CA1815443A5C42435C494E434C5544455C636F6E696F2E68
	?debug	C E94019CA1815443A5C42435C494E434C5544455C737464696F2E68
	?debug	C E94019CA1816443A5C42435C494E434C5544455C5F6E66696C652E+
	?debug	C 68
	?debug	C E94019CA1815443A5C42435C494E434C5544455C5F6E756C6C2E68
	?debug	C E94019CA1816443A5C42435C494E434C5544455C737472696E672E+
	?debug	C 68
	?debug	C E94019CA1816443A5C42435C494E434C5544455C7374646172672E+
	?debug	C 68
	?debug	C E93483411C086472697665722E68
_TEXT	segment byte public use16 'CODE'
_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:_TEXT,ds:DGROUP
_DATA	segment word public use16 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public use16 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_TEXT	segment byte public use16 'CODE'
   ;	
   ;	void abort(void) { ; }
   ;	
	assume	cs:_TEXT
_abort	proc	near
	push	bp
	mov	bp,sp
	pop	bp
	ret	
_abort	endp
   ;	
   ;	void _terminate(void) { ; }
   ;	
	assume	cs:_TEXT
__terminate	proc	near
	push	bp
	mov	bp,sp
	pop	bp
	ret	
__terminate	endp
   ;	
   ;	void _checknull(void) { ; }
   ;	
	assume	cs:_TEXT
__checknull	proc	near
	push	bp
	mov	bp,sp
	pop	bp
	ret	
__checknull	endp
   ;	
   ;	void _restorezero(void) { ; }
   ;	
	assume	cs:_TEXT
__restorezero	proc	near
	push	bp
	mov	bp,sp
	pop	bp
	ret	
__restorezero	endp
   ;	
   ;	void _cleanup(void) { ; }
   ;	
	assume	cs:_TEXT
__cleanup	proc	near
	push	bp
	mov	bp,sp
	pop	bp
	ret	
__cleanup	endp
	?debug	C E93C74411C09647276736572762E68
   ;	
   ;	void print(unsigned char far *s)
   ;	
	assume	cs:_TEXT
_print	proc	near
	push	bp
	mov	bp,sp
	jmp	short @6@198
@6@58:
   ;	
   ;	{
   ;		while(*s) {
   ;		    _AX=0x0E00|*(s++);
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx]
	mov	ah,0
	mov	dx,3584
	or	dx,ax
	mov	ax,dx
	inc	word ptr [bp+4]
   ;	
   ;			asm {
   ;	 			MOV  bx,7
   ;	
	MOV	  bx,7
   ;	
   ;			    PUSH bp
   ;	
	PUSH	 bp
   ;	
   ;			    INT  0x10
   ;	
	INT	  010H
   ;	
   ;			    POP  bp
   ;	
	POP	  bp
@6@198:
	les	bx,dword ptr [bp+4]
	cmp	byte ptr es:[bx],0
	jne	short @6@58
   ;	
   ;			}
   ;		}
   ;	}
   ;	
	pop	bp
	ret	
_print	endp
_TEXT	ends
_DATA	segment word public use16 'DATA'
	db	48
	db	48
	db	48
	db	48
	db	1 dup (0)
_DATA	ends
_TEXT	segment byte public use16 'CODE'
   ;	
   ;	void printx(int x)
   ;	
	assume	cs:_TEXT
_printx	proc	near
	enter	12,0
   ;	
   ;	{
   ;		UCHAR tmp[5]="0000";
   ;	
	lea	ax,word ptr [bp-6]
	push	ss
	push	ax
	push	ds
	push	offset DGROUP:d@w+0
	mov	cx,5
	call	near ptr N_SCOPY@
   ;	
   ;		UCHAR far *t;
   ;		char i;
   ;	
   ;		t=tmp+4;
   ;	
	lea	ax,word ptr [bp-2]
	mov	word ptr [bp-8],ss
	mov	word ptr [bp-10],ax
   ;	
   ;	
   ;		for (i=3;i>=0;i--) {
   ;	
	mov	byte ptr [bp-11],3
	jmp	short @7@170
@7@58:
   ;	
   ;			t--;
   ;	
	dec	word ptr [bp-10]
   ;	
   ;			*(t)+=(x&15);
   ;	
	les	bx,dword ptr [bp-10]
	mov	al,byte ptr es:[bx]
	mov	dl,byte ptr [bp+4]
	and	dl,15
	add	al,dl
	les	bx,dword ptr [bp-10]
	mov	byte ptr es:[bx],al
   ;	
   ;			if (*t>57) *(t)+=7;
   ;	
	les	bx,dword ptr [bp-10]
	cmp	byte ptr es:[bx],57
	jbe	short @7@114
	les	bx,dword ptr [bp-10]
	mov	al,byte ptr es:[bx]
	add	al,7
	les	bx,dword ptr [bp-10]
	mov	byte ptr es:[bx],al
@7@114:
   ;	
   ;			x>>=4;
   ;	
	sar	word ptr [bp+4],4
	dec	byte ptr [bp-11]
@7@170:
	cmp	byte ptr [bp-11],0
	jge	short @7@58
	jmp	short @7@254
@7@226:
   ;	
   ;		}
   ;		while ((*t)&&(*t=='0')) t++;
   ;	
	inc	word ptr [bp-10]
@7@254:
	les	bx,dword ptr [bp-10]
	cmp	byte ptr es:[bx],0
	je	short @7@310
	les	bx,dword ptr [bp-10]
	cmp	byte ptr es:[bx],48
	je	short @7@226
@7@310:
   ;	
   ;		if (!*t) t--;
   ;	
	les	bx,dword ptr [bp-10]
	mov	al,byte ptr es:[bx]
	mov	ah,0
	or	ax,ax
	jne	short @7@366
	dec	word ptr [bp-10]
@7@366:
   ;	
   ;		print(t);
   ;	
	push	word ptr [bp-8]
	push	word ptr [bp-10]
	call	near ptr _print
	add	sp,4
   ;	
   ;	}
   ;	
	leave	
	ret	
_printx	endp
_TEXT	ends
_DATA	segment word public use16 'DATA'
	db	48
	db	49
	db	50
	db	51
	db	52
	db	53
	db	54
	db	55
	db	56
	db	57
	db	65
	db	66
	db	67
	db	68
	db	69
	db	70
	db	71
	db	72
	db	73
	db	74
	db	75
	db	76
	db	77
	db	78
	db	79
	db	80
	db	81
	db	82
	db	83
	db	84
	db	85
	db	86
	db	87
	db	88
	db	89
	db	90
	db	49
	db	50
	db	51
	db	52
	db	65
	db	66
	db	67
	db	68
	db	69
	db	70
	db	71
	db	72
	db	73
	db	74
	db	75
	db	76
	db	77
	db	78
	db	79
	db	80
	db	81
	db	82
	db	83
	db	84
	db	85
	db	86
	db	87
	db	88
	db	89
	db	90
	db	49
	db	50
	db	51
	db	52
	db	48
	db	49
	db	50
	db	51
	db	52
	db	53
	db	54
	db	55
	db	56
	db	57
	db	1 dup (0)
_DATA	ends
_TEXT	segment byte public use16 'CODE'
   ;	
   ;	void prat(char *fmt,...)
   ;	
	assume	cs:_TEXT
_prat	proc	near
	enter	2,0
   ;	
   ;	{
   ;		static char s[81]="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ1234ABCDEFGHIJKLMNOPQRSTUVWXYZ12340123456789";
   ;		void *ap;
   ;	//	va_list ap;
   ;	
   ;	    va_start(ap,fmt);
   ;	
	lea	ax,word ptr [bp+6]
	mov	word ptr [bp-2],ax
   ;	
   ;	    vsprintf(s,fmt,ap);
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp+4]
	push	offset DGROUP:d@w+5
	call	near ptr _vsprintf
	add	sp,6
   ;	
   ;	    va_end(ap);
   ;	
   ;	
   ;	
   ;		print(s);
   ;	
	push	ds
	push	offset DGROUP:d@w+5
	call	near ptr _print
	add	sp,4
   ;	
   ;	}
   ;	
	leave	
	ret	
_prat	endp
_TEXT	ends
_DATA	segment word public use16 'DATA'
_G_ticker	label	word
	db	0
	db	0
_G_signon	label	word
	dw	DGROUP:s@
_DATA	ends
_TEXT	segment byte public use16 'CODE'
   ;	
   ;	void interrupt ticker(void)
   ;	
	assume	cs:_TEXT
_ticker	proc	far
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push	si
	push	di
	push	bp
	mov	bp,cs:DGROUP@
	mov	ds,bp
	mov	bp,sp
   ;	
   ;	{
   ;		(oldtick)();
   ;	
	pushf	
	call	dword ptr DGROUP:_oldtick
   ;	
   ;		if ((++G_ticker)>10000) G_ticker=0;
   ;	
	inc	word ptr DGROUP:_G_ticker
	mov	ax,word ptr DGROUP:_G_ticker
	cmp	ax,10000
	jle	short @9@86
	mov	word ptr DGROUP:_G_ticker,0
@9@86:
   ;	
   ;	}
   ;	
	pop	bp
	pop	di
	pop	si
	pop	ds
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	iret	
_ticker	endp
   ;	
   ;	void pascal drventry(PARMBLK far *req)
   ;	
	assume	cs:_TEXT
DRVENTRY	proc	near
	push	bp
	mov	bp,sp
	push	si
   ;	
   ;	{
   ;	    int res;
   ;	    switch (req->r.cmd) {
   ;	
	les	bx,dword ptr [bp+4]
	mov	al,byte ptr es:[bx+2]
	cbw	
	mov	bx,ax
	cmp	bx,12
	ja	short @10@170
	shl	bx,1
	jmp	word ptr cs:@10@C418[bx]
@10@114:
   ;	
   ;	        case INIT    :
   ;	            res=drvinit(&(req->p.ini));
   ;	
	mov	ax,word ptr [bp+4]
	add	ax,13
	push	word ptr [bp+6]
	push	ax
	call	near ptr _drvinit
	add	sp,4
	mov	si,ax
   ;	
   ;	            break;
   ;	
	jmp	short @10@198
@10@142:
	jmp	short @10@170
@10@170:
   ;	
   ;			case MEDCHK  :
   ;			case BLDBPB  :
   ;			case IOCRLTI :
   ;			case INPUT   :
   ;			case IPNOWT  :
   ;			case IPSTAT  :
   ;			case IPFLSH  :
   ;			case OUTPUT  :
   ;			case OPVERI  :
   ;			case OPSTAT  :
   ;			case OPFLSH  :
   ;			case IOCRLTO :
   ;	            res=0;
   ;	            break;
   ;	        default:
   ;	            res=0;
   ;	
	xor	si,si
@10@198:
   ;	
   ;	    }
   ;	    req->r.stat=res|DONE;
   ;	
	mov	ax,si
	or	ax,256
	les	bx,dword ptr [bp+4]
	mov	word ptr es:[bx+3],ax
   ;	
   ;	}
   ;	
	pop	si
	pop	bp
	ret	4
DRVENTRY	endp
@10@C418	label	word
	dw	@10@114
	dw	@10@142
	dw	@10@142
	dw	@10@142
	dw	@10@142
	dw	@10@142
	dw	@10@142
	dw	@10@142
	dw	@10@142
	dw	@10@142
	dw	@10@142
	dw	@10@142
	dw	@10@142
   ;	
   ;	int drvinit(INITBLK far *ibp)
   ;	
	assume	cs:_TEXT
_drvinit	proc	near
	enter	6,0
	push	si
   ;	
   ;	{
   ;		int i;
   ;		char tmp[2];
   ;		char far *t;
   ;		ibp->brk[0]=0x2000;
   ;	
	les	bx,dword ptr [bp+4]
	mov	word ptr es:[bx+1],8192
   ;	
   ;	    ibp->brk[1]=_CS;
   ;	
	les	bx,dword ptr [bp+4]
	mov	word ptr es:[bx+3],cs
   ;	
   ;	
   ;	    oldtick=getvect(0x1C);
   ;	
	push	28
	call	near ptr _getvect
	pop	cx
	mov	word ptr DGROUP:_oldtick+2,dx
	mov	word ptr DGROUP:_oldtick,ax
   ;	
   ;	    setvect(0x1C,ticker);
   ;	
	push	seg _ticker
	push	offset _ticker
	push	28
	call	near ptr _setvect
	add	sp,6
   ;	
   ;	
   ;	    print(G_signon);
   ;	
	push	ds
	push	word ptr DGROUP:_G_signon
	call	near ptr _print
	add	sp,4
   ;	
   ;		printx(VER_MAJOR); print(".0"); printx(VER_MINOR); print("\r\n");
   ;	
	push	1
	call	near ptr _printx
	pop	cx
	push	ds
	push	offset DGROUP:s@+32
	call	near ptr _print
	add	sp,4
	push	0
	call	near ptr _printx
	pop	cx
	push	ds
	push	offset DGROUP:s@+35
	call	near ptr _print
	add	sp,4
   ;	
   ;	    prat("%s","Copyright (c) Unisys Ltd. 1994\r\n");
   ;	
	push	offset DGROUP:s@+41
	push	offset DGROUP:s@+38
	call	near ptr _prat
	add	sp,4
   ;	
   ;		t=ibp->bpb;
   ;	
	les	bx,dword ptr [bp+4]
	mov	eax,dword ptr es:[bx+5]
	mov	dword ptr [bp-6],eax
   ;	
   ;		tmp[1]=0;
   ;	
	mov	byte ptr [bp-1],0
   ;	
   ;		for (i=0;i<80;i++) {
   ;	
	xor	si,si
	jmp	short @11@198
@11@58:
   ;	
   ;			if ((!*t)||(*t=='\r')) break;
   ;	
	les	bx,dword ptr [bp-6]
	mov	al,byte ptr es:[bx]
	cbw	
	or	ax,ax
	je	short @11@114
	les	bx,dword ptr [bp-6]
	cmp	byte ptr es:[bx],13
	jne	short @11@142
@11@114:
	jmp	short @11@226
@11@142:
   ;	
   ;			tmp[0]=*(t++);
   ;	
	les	bx,dword ptr [bp-6]
	mov	al,byte ptr es:[bx]
	mov	byte ptr [bp-2],al
	inc	word ptr [bp-6]
   ;	
   ;			print(tmp);
   ;	
	push	ss
	lea	ax,word ptr [bp-2]
	push	ax
	call	near ptr _print
	add	sp,4
	inc	si
@11@198:
	cmp	si,80
	jl	short @11@58
@11@226:
   ;	
   ;		}
   ;	    print("\r\n\r\n");
   ;	
	push	ds
	push	offset DGROUP:s@+74
	call	near ptr _print
	add	sp,4
   ;	
   ;	/*	i=0;
   ;		while (i<36) {
   ;			if (i!=G_ticker) print(".");
   ;			i=G_ticker;
   ;		}*/
   ;	    return(0);
   ;	
	xor	ax,ax
	jmp	short @11@254
@11@254:
   ;	
   ;	}
   ;	
	pop	si
	leave	
	ret	
_drvinit	endp
_TEXT	ends
_BSS	segment word public use16 'BSS'
_oldtick	label	dword
	db	4 dup (?)
___brklvl	label	word
	db	2 dup (?)
_errno	label	word
	db	2 dup (?)
	?debug	C E9
	?debug	C FA00000000
_BSS	ends
_DATA	segment word public use16 'DATA'
s@	label	byte
	db	13
	db	10
	db	'Serial device driver Version '
	db	0
	db	'.0'
	db	0
	db	13
	db	10
	db	0
	db	'%s'
	db	0
	db	'Copyright (c) Unisys Ltd. 1994'
	db	13
	db	10
	db	0
	db	13
	db	10
	db	13
	db	10
	db	0
_DATA	ends
_TEXT	segment byte public use16 'CODE'
	extrn	DGROUP@:word
_TEXT	ends
	public	DRVENTRY
	public	_ticker
	public	_drvinit
	public	_G_signon
	public	_G_ticker
	public	_oldtick
	public	_prat
	extrn	N_SCOPY@:far
	public	_printx
	public	_print
	public	___brklvl
	public	__cleanup
	public	__restorezero
	public	__checknull
	public	__terminate
	public	_abort
	extrn	_vsprintf:near
	extrn	_setvect:near
	extrn	_getvect:near
	public	_errno
_s@	equ	s@
	end
