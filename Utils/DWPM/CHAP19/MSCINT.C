/* Windows int86 routines for use with Microsoft C
   in small model. Do not use with INT 0x25 or 0x26 */

#include <dos.h>

/* Fake Windows prototypes (no arguments) */
void far pascal GlobalFix(void);
void far pascal GlobalUnfix(void);
void far pascal AllocDStoCSAlias(void);
void far pascal FreeSelector(void);

/* register structure equates */
#define Res [si]
#define Rds [si+6]
#define Rax [si]
#define Rbx [si+2]
#define Rcx [si+4]
#define Rdx [si+6]
#define Rsi [si+8]
#define Rdi [si+10]
#define Rcfl [si+12]


int int86x(int intno,union REGS *rin,union REGS *rout,
           struct SREGS *s)
  {
  void (_far * pgm)(void);
  char  ary[5];
  int     rv;  /* return value */

  _asm
        {
        push ds
        mov byte ptr ary, 55H    /* push bp */
        mov byte ptr ary+1, 0CDH  /* INT */
        mov ax, intno
        mov byte ptr ary+2, al
        mov word ptr ary+3, 5DH    /* pop bp */
        mov byte ptr ary+4, 0CBH   /* ret */
        lea cx, ary
        mov word ptr pgm, cx
        push    ss
        }
  GlobalFix();  /* fix ss */
  _asm
        {
        push    ss
        }
        AllocDStoCSAlias();  /* Get alias for ss */
   _asm
        {
        mov word ptr pgm+2, ax

        /* Set registers */

        mov si, s
        push Res
        push Rds
        mov si, rin
        mov ax, Rax
        mov bx, Rbx
        mov cx, Rcx
        mov dx, Rdx
        mov di, Rdi
        mov si, Rsi
        pop ds
        pop es
        }
/* Call interrupt */
        (* pgm)();
   _asm
        {
/* Set register structure  */

        pushf
        push si
        push ds
        push es
        mov ds, [bp-20]
        mov si, s
        pop Res
        pop Rds
        mov si, rout
        pop Rsi
        pop Rcfl
        and word ptr Rcfl, 1
        mov Rdi, di
        mov Rdx, dx
        mov Rcx, cx
        mov Rbx, bx
        mov Rax, ax
        push ax      /* save AX */
        push word ptr pgm+2
        }
/* free alias selector */
     FreeSelector();
      _asm
        {
        push ss
        }
/* unfix ss */
        GlobalUnfix();
      _asm
        {
        pop ax      /* restore AX */
        pop ds
/* Just in case */
        mov rv,ax
        }
      return(rv);
   }


int int86(int intno,union REGS *rin,union REGS *rout)
  {
  struct SREGS s;
  segread(&s);
  return int86x(intno,rin,rout,&s);
  }

