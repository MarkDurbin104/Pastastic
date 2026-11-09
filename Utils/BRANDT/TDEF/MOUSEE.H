/******************************************************************************/
/******************************  MOUSE.H    ***********************************/
/******* M.J.D -  Amended version for edit functions - ICJ 26/06/89  **********/
/******************************************************************************/

int    mousex,mousey,mousebutt;
struct REGPACK regs;

extern  void  setmousexto(int newx);
extern  void  setmouseyto(int newy);
extern  void  mousecur(int onoff);
extern  void  setupmouse(void);
extern  int   mousetrap(void);

void setmousexto(int newx)
{
/* this function uses register function 4 to update mouse xpos */
/* not currently used */

    regs.r_ax=4;
    regs.r_cx=newx;
    regs.r_dx=mousey;
    intr(0x33,&regs);
    mousex=newx;
}

void setmouseyto(int newy)
{
/* this function accepts a line number and converts it to pixels, then
    using it to update mouse ypos */

    newy *=8;
    regs.r_ax=4;
    regs.r_cx=mousex;
    regs.r_dx=newy;
    intr(0x33,&regs);
    mousey=newy;
}

void mousecur(int onoff)
{
/* this function uses register functions 1 & 2 to turn mouse cursor on/off */

    switch (onoff)
    {
        case 0:
        {
            regs.r_ax=2;
            intr(0x33,&regs);
        }
        break;

        case 1:
        {
            regs.r_ax=1;
            intr(0x33,&regs);
        }
        break;
    }
}

void setupmouse(void)
{
/* this function initialises the mouse registers */

    regs.r_ax=0;
    intr(0x33,&regs);

/* initialise mouse position on screen */

    regs.r_ax=4;
    regs.r_cx=0;
    regs.r_dx=0;

/* set limits for mouse ypos */

    intr(0x33,&regs);
    regs.r_ax=8;
    regs.r_cx=8;
    regs.r_dx=182;

/* set limits for mouse xpos */

    intr(0x33,&regs);
    regs.r_ax=7;
    regs.r_cx=8;
    regs.r_dx=632;

    intr(0x33,&regs);
}
int mousetrap(void)
{
/* this function uses interrupt to detect mouse actions.It returns 1 if
   any change, else 0. */

/*    int tmpx,tmpy,tmpb;
    tmpx=mousex;*/

    int tmpy,tmpb;

    tmpy=mousey;
    tmpb=mousebutt;
    regs.r_ax=3;
    intr(0x33,&regs);
    mousex=regs.r_cx;
    mousey=regs.r_dx;
    mousebutt=regs.r_bx;
/* temporarily exclude xpos changes

    if ((tmpx!=mousex)||(tmpy!=mousey)||(tmpb!=mousebutt)) return(1);*/

    if ((tmpy!=mousey)||(tmpb!=mousebutt)) return(1);
    return(0);
}
