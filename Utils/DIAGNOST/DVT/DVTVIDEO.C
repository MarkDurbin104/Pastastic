
/***********************************************************************
*
*   File:           dvtvideo.c
*
*   Purpose:        video diagnostics module
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 12-4-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTVIDEO.C_V  $
*  
*     Rev 1.3   07 Jan 1991 13:48:16   AJW
*  Calls of system function replaced by calls of c40 and m80.
*  
*     Rev 1.2   03 Jan 1991 16:20:18   AJW
*  Added Location test.
*  
*     Rev 1.1   14 Dec 1990 12:46:58   PJE
*  Put "Press \key..." messages after each screen.
*  
*     Rev 1.0   10 Dec 1990 10:55:26   PJE
*  Initial revision.
*
***********************************************************************/
#include <dos.h>
#include "eccodefs.h"

typedef enum {MONO, CGA} VID_TYPE;

#include "globals.h"
#include "dvtmsgs.h"
#include "bpokeys.h"

/*  Color Attributes    */

#define BLACK       0x00
#define BG_BLUE     0x10
#define BG_GREEN    0x20
#define BG_RED      0x40
#define FG_BLUE     0x01
#define FG_GREEN    0x02
#define FG_RED      0x04
#define BRIGHT      0x08
#define BLINK       0x80

#define BG_WHITE    (BG_RED | BG_GREEN | BG_BLUE)


extern void m80 (void);
extern void c40 (void);


/***********************************************************************
*
*   Function:   get_videomode
*
*   Purpose:    returns video mode
*
*   Arguments:  none
*
*   Returns:    video mode:
*               0x00    40x25 16 text color burst off
*               0x01    40x25 16 text color
*               0x02    80x25 16 text color burst off
*               0x03    80x25 16 text color
*               0x04    320x200 4 color graphics
*               0x05    320x200 4 color graphics burst off
*               0x06    640x200 2 color graphics
*               0x07    80x25 mono text
*
***********************************************************************/
int get_videomode()
{
    union REGS regs;

    regs.h.ah = 0x0f;               /* get video mode       */
    int86 (0x10, &regs, &regs);     /* BIOS video interrupt */
    return ((int)regs.h.al);        /* return display mode  */
}

/***********************************************************************
*
*   Function:   set_videomode
*
*   Purpose:    sets the video mode
*
*   Arguments:  video mode
*
*   Returns:    none
*
***********************************************************************/
void set_videomode (int mode)
{
    union REGS regs;

    regs.h.ah = 0;              /* set mode */
    regs.h.al = (unsigned char)mode;

    int86 (0x10, &regs, &regs);
}

/***********************************************************************
*
*   Function:   set_cursor
*
*   Purpose:    sets the cursor position
*
*   Arguments:  row, col
*
*   Returns:    nothing
*
***********************************************************************/
int set_cursor (int row, int col)
{
    union REGS regs;

    regs.h.ah = 2;              /* bios set cursor position */
    regs.h.bh = 0;              /* video page */
    regs.h.dh = row;            /* y coordinate */
    regs.h.dl = col;            /* x coordinate */
    int86 (0x10, &regs, &regs); /* bios video interrupt */
}

/***********************************************************************
*
*   Function:   put_chatt
*
*   Purpose:    puts a character and attribute at the cursor position
*
*   Arguments:  
*
*   Returns:
*
*   Notes:      This call increments the cursor position.
*
***********************************************************************/
int put_chatt (int character, int att)
{
    union REGS regs;

    if (att == 0)
        regs.h.ah = 0x0a;       /* just write character */
    else
        regs.h.ah = 0x09;       /* write character and attribute */

    regs.h.al = ' ';
    regs.h.bh = 0;              /* display page */
    regs.h.bl = att;            /* attribute */
    regs.x.cx = 1;              /* replication count */
    int86 (0x10, &regs, &regs); /* video interrupt */

    regs.h.ah = 0x0e;
    regs.h.al = character;
    regs.h.bh = 0;
    int86 (0x10, &regs, &regs); /* video interrupt */
}

/***********************************************************************
*
*   Function:   put_string
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int put_string(char *str, int att)
{
    int i;

    for (i=0; str[i] != '\0'; i++)
    {
        put_chatt (str[i], att);
    }
}

/***********************************************************************
*
*   Function:   put_ascii_chart
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
void put_ascii_chart ()
{
    int character=0;
    int row, col;

    set_cursor (0, 0);
    put_string (text[TXT_VID_12], 0x70);

    row = 2;
    col = 0;

    set_cursor (row, col);
    for (character = 0; character < 256; character++)
    {
        if ((col % 32) == 0)
        {
            row++;
            col = 0;
        }

        set_cursor (row, col);
        put_chatt (character, 0x70);    /* black on white */
        col += 2;
    }
}
/***********************************************************************
*
*   Function:   clear_mono
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
void clear_screen (VID_TYPE vt)
{
    union REGS regs;

    /* clear window to inverse video */

    regs.h.ah = 0x06;           /* vid int initalize window */
    regs.h.al = 0;              /* just initialize  */
    regs.h.bh = 0x70;           /* black on white   */
    regs.h.ch = 0;              /* y coord, upper left  */
    regs.h.cl = 0;              /* x coord, upper left  */
    regs.h.dh = 24;             /* y coord, lower right */
    regs.h.dl = (vt == MONO) ? 79 : 39; /* x coord, lower right */
    int86 (0x10, &regs, &regs); /* video interrupt */
}
/***********************************************************************
*
*   Function:   put_full_screen
*
*   Purpose:    fill screen with 'H'
*
*   Arguments:  None
*
*   Returns:    None
*
***********************************************************************/
void put_full_screen(VID_TYPE vt)
{
    int row, col;
    int width;

    clear_screen(vt);
    width=(vt == MONO) ? 80 : 40;

    for (row=0;row<24;row++) {           /* for all lines              */
        for (col=0;col<width;col+=2) {   /* for all columns            */
            set_cursor(row,col+(row&1)); /* move cursor                */
            put_chatt('H',0x70);         /* place 'H' black on white   */
        }
    }
}


/* CGA Emulation Attributes */
int cga_atts[] = {
    BG_RED,
    BG_GREEN,
    BG_BLUE,
    BG_RED+BG_GREEN,
    BG_GREEN+BG_BLUE,
    BG_BLUE+BG_GREEN,
    BG_BLUE+BG_GREEN+BG_RED,
    BLACK
};

/***********************************************************************
*
*   Function:   test_cga
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int test_cga()
{
    STATUS result;
    union REGS regs;
    char buffer[41];
    int i;

    /* set monitor to cga emulation, video mode 01 */
    c40();
    //  system ("c40 > NUL");

    if (get_videomode() == 0x01)
    {
        /* proceed with test display */
        
        clear_screen (CGA);

        set_cursor (0, 0);
        put_string (text[TXT_VID_02], 0x70);
        set_cursor (1, 0);
        put_string (text[TXT_VID_03], 0x07);
        set_cursor (2, 0);
        put_string (text[TXT_VID_04], 0x70 | 0x80);
        set_cursor (3, 0);
        put_string (text[TXT_VID_05], 0x07 | 0x80);

        for (i=0; i < 8; i++)
        {
            set_cursor (5+i, 0);
            sprintf (buffer, "%-40.40s", " ");
            put_string (buffer, cga_atts[i]);
        }

        set_cursor (24, 0);
        put_string (message[PRESSKEY], 0x60);
        key_or_timeout(IDLE_TIME);    /* get a key       */
        clear_screen (CGA);
        put_ascii_chart();
        set_cursor (24, 0);
        put_string (message[PRESSKEY], 0x60);
        key_or_timeout(IDLE_TIME);    /* get a key again */

        put_full_screen (CGA);
        set_cursor (24, 0);
        put_string (message[PRESSKEY], 0x60);
        key_or_timeout(IDLE_TIME);    /* get a key again */
        
        result = PASSED;

    } else
    {
        result = FAILED;
    }
    return (result);
}

/*  Mono Attributes */

int mono_atts[] = {
    0x07,               /* normal                   */
    0x70,               /* reverse                  */
    0x01,               /* underlined               */
    0x87,               /* blinking normal          */
    0xf0,               /* blinking reverse         */
    0x81,               /* blinking underlined      */
    0x0f,               /* normal + bright          */
    0x78,               /* reverse + bright         */
    0x09,               /* underlined + bright      */
    0x8f,               /* blinking normal + br     */
    0xf8,               /* blinking reverse +br     */
    0x89,               /* blinking underlined +br  */
    0x00                /* terminator               */
};


/***********************************************************************
*
*   Function:   test_mono
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int test_mono()
{
    STATUS result;
    char buffer[81];
    int i;

    /* set monitor to monochrome text video mode 07 */
    m80();
    //   system ("m80 > NUL");

    if (get_videomode() == 0x07)
    {
        /* proceed with test display */

        /* set 3-in-1 to support double wide attribute, bit 4 */

        outp (0x03b8, 0x00);        /* disable display */
        outp (0x03bf, 0x08);        /* enable enhanced mode reg */
        outp (0x03ba, 0x43);        /* mono-mono, enable double wide */
        outp (0x03b8, 0x29);        /* set configuration, enable display */

        clear_screen (MONO);

        set_cursor (0, 0);
        put_string (text[TXT_VID_01], 0x70);        /* black on white */
        set_cursor (1, 0);
        put_string (text[TXT_VID_10], 0x07);        /* white on black */
        set_cursor (2, 0);
        put_string (text[TXT_VID_03], 0x07);        /* white on black */
        set_cursor (3, 0);
        put_string (text[TXT_VID_04], 0x70 | 0x80); /* blink black on white */
        set_cursor (4, 0);
        put_string (text[TXT_VID_05], 0x07 | 0x80); /* blink white on black */
        set_cursor (5, 0);
        put_string (text[TXT_VID_07], 0x70 | 0x10); /* double wide */
        
        for (i=0; mono_atts[i] != 0; i++)
        {
            sprintf (buffer, text[TXT_VID_13+i], mono_atts[i]);
            set_cursor (7+i, 0);
            put_string (buffer, mono_atts[i]);
        }

        set_cursor (24, 0);
        put_string (message[PRESSKEY], 0x07);

        key_or_timeout(IDLE_TIME);    /* get a key */
        outp (0x03bf, 0x00);        /* disable enhanced mode reg */

        set_cursor (1, 0);
        put_string (text[TXT_VID_11], 0x07);        /* white on black */
        set_cursor (24, 0);
        put_string (message[PRESSKEY], 0x07);
        
        key_or_timeout(IDLE_TIME);    /* get a key again */

        clear_screen (MONO);
        set_cursor(0, 0);
        put_ascii_chart();
        set_cursor (24, 0);
        put_string (message[PRESSKEY], 0x70);

        key_or_timeout (IDLE_TIME);

        put_full_screen (MONO);
        set_cursor (24, 0);
        put_string (message[PRESSKEY], 0x60);
        key_or_timeout(IDLE_TIME);    /* get a key again */

        result = PASSED;


    } else
    {
        result = FAILED;
    }
    return (result);
}

/***********************************************************************
*
*   Function:   test_video
*
*   Purpose:    Tests the 3-in-1 magic combo video card
*
*   Arguments:  none
*
*   Returns:    
*
***********************************************************************/
int test_video()
{
    WINDOWPTR savewnp;
    STATUS result;
    int key;
    int videomode;                  /* save current mode */

    clear_window();
    disp_title (menuopt[4]);

    if (Location == PC) {       //  AJW
        result = SKIPPED;
        return (result);
    }

    videomode = get_videomode();

    savewnp = wn_def (0, 0, 25, screen_cols, LNORMAL, BDR_NULLP);
    if (savewnp != NULL)
    {
        wn_up (savewnp);

        if (Location == CT)
            result = test_cga();
        else
            result = test_mono();

        /* restore video mode */
        if (videomode == 1)          /* if color */
        {
            c40();
        } else
        if (videomode == 7 )
        {
            m80();
        }
        set_videomode(videomode);
        wn_dn (savewnp);
        wn_free (savewnp);

        if (result != FAILED)
        {
            clear_window();
            v_stpl (9, CENTER_TEXT, text[TXT_VID_06], wnp);

            key = disp_exit(text[TXT_SPRN_02], text[TXT_SPRN_03], ENTER_MASK | VOID_MASK);
            if (key == ENTER_KEY) {
                result = PASSED;
            } else
            if (key == 0)
            {
                result = SKIPPED;
            } else
            {
                result = FAILED;
            }
        }
    } else
    {
        disp_error ("Cannot Allocate Memory",
            "Press any key to continue", ANY_MASK);
        result = SKIPPED;
    }
    csr_hide();
    return (result);
}
