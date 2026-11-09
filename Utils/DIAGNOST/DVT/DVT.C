/***********************************************************************
*
*   File:           dvt.c
*
*   Purpose:        main module for DVT
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 11-20-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVT.C_V  $
*  
*     Rev 1.4   24 Jan 1991 11:22:00   PJE
*  Added Low-Level format option for Hard disk if in FACTORY mode.
*  
*     Rev 1.3   11 Jan 1991 17:02:22   AJW
*  Adapted to new DVT test versions called "Utility" and "Factory"
*  
*     Rev 1.2   03 Jan 1991 16:51:18   AJW
*  Many changes.
*  
*     Rev 1.1   13 Dec 1990 16:26:48   PJE
*  
*  Added save and restore of video mode;
*  Added calls to init_com4 and init_pprn;
*  
*     Rev 1.0   10 Dec 1990 10:09:02   PJE
*  Initial revision.
*
***********************************************************************/
#define MAIN_MODULE

/**************
 Include Files            
***************/

#include <string.h>
#include <vv_sys.h>
#include <vv_menu.h>
#include <vv_main.h>
#include <dos.h>
#include <bios.h>

#include "eccodefs.h"
#include "bpokeys.h"
#include "dvtmsgs.h"
#include "globals.h"
#include "dvtprot.h"

#define SET_FP_SEG(fp,value)    *((unsigned *)&(fp) + 1) = value
#define SET_FP_OFF(fp,value)    *((unsigned *)&(fp)) = value
#define PORT4       3           /* 0 relative index  */
#define CMOS_BEG        0x10            /* CMOS RAM beginning address */
#define CMOS_END        0x2D            /* CMOS RAM ending address */
#define CMOS_MSCS       0x2E            /* CMOS RAM Most Sig. Checksum */
#define CMOS_LSCS       0x2F            /* CMOS RAM Least Sig. Checksum */

/* table of functions */

TEST_REC diagtable[] = {
    {test_rom,            FALSE,  SKIPPED,  BOTH  },
    {test_ram,            FALSE,  SKIPPED,  BOTH  },
    {test_cmos,           FALSE,  SKIPPED,  BOTH  },
    {test_keyboard,       FALSE,  SKIPPED,  BOTH  },
    {test_video,          FALSE,  SKIPPED,  BOTH  },
    {test_flformat,       FALSE,  SKIPPED,  BOTH  },
    {test_flwrite,        FALSE,  SKIPPED,  BOTH  },
    {test_flread,         FALSE,  SKIPPED,  BOTH  },
    {test_flprotect,      FALSE,  SKIPPED,  BOTH  },
    {test_flchange,       FALSE,  SKIPPED,  BOTH  },
    {test_clock,          FALSE,  SKIPPED,  BOTH  },
    {test_serialp,        FALSE,  SKIPPED,  CT    },
    {test_parallp,        FALSE,  SKIPPED,  BOP   },
    {test_fdread,         FALSE,  SKIPPED,  BOP   },
    {test_fdwrite,        FALSE,  SKIPPED,  BOP   },
    {test_fdformat,       FALSE,  SKIPPED,  BOP   },
    {test_modem,          FALSE,  SKIPPED,  BOP   },
    {test_internal_comms, FALSE,  SKIPPED,  BOTH  },
#ifdef FACTORY
    {test_external_comms, FALSE,  SKIPPED,  BOTH  },
#endif
};

extern  void  m80 (void);
#ifdef FACTORY
extern  int   log_error (char *message);
#endif

/***********************************************************************
*
*   Function:   usage
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
void usage()
{
    fprintf (stderr, text[TXT_USE_01]);
    fprintf (stderr, text[TXT_USE_02]);
    fprintf (stderr, text[TXT_USE_03]);
    fprintf (stderr, text[TXT_USE_04]);
    fprintf (stderr, text[TXT_USE_05]);
    exit(1);
}

/***********************************************************************
*
*   Function:   send_enter_to_keyboard
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int send_enter_to_keyboard(void)
{
    union REGS regs;

    while (_bios_keybrd(_KEYBRD_READY))
        _bios_keybrd(_KEYBRD_READ);

    regs.h.ah = 0x05;
    regs.h.ch = 0x1c;
    regs.h.cl = 0x0d;
    int86 (0x16, &regs, &regs);

    return (regs.h.al);
}

/***********************************************************************
*
*   Function:   set_com4_addr
*
*   Purpose:    sets the port address for COM4 int the BIOS data area
*
*   Arguments:  none
*
*   Returns:    none
*
***********************************************************************/
void set_com4_addr()
{
    char far *com4addr;             /* far pointer to com4 address  */

    /* set port 4 address in BIOS data area */
    SET_FP_SEG(com4addr, 0x40);
    SET_FP_OFF(com4addr, 0x06);
    *com4addr = 0x10;
    com4addr++;
    *com4addr = 0x03;
}

/***********************************************************************
*
*   Function:   init_pprn
*
*   Purpose:    checks for a parallel printer
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
void init_pprn()
{
    union REGS regs;

    regs.h.ah = 1;
    regs.x.dx = 0;
    int86(0x17, &regs, &regs);
    if (!((regs.h.ah == 0x90) || (regs.h.ah == 0x10)))
    {
        Disable_Print = TRUE;
    }
}

/***********************************************************************
*
*   Function:   init_com4
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
void init_com4 ()
{
    union REGS regs;

    regs.h.ah = 0x00;
    regs.h.al = 0x83;               /* 1200 N, 8, 1 */
    regs.x.dx = PORT4;
    int86 (0x14, &regs, &regs);

    if (regs.h.ah & 0x80)           /* timed out ? */
        Disable_Print = TRUE;
}

/***********************************************************************
*
*   Function:   print_serial_char
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int print_serial_char(char c)
{
    union REGS regs;

    regs.h.ah = 0x01;
    regs.h.al = (char )c;
    regs.x.dx = PORT4;
    int86 (0x14, &regs, &regs);
}

/***********************************************************************
*
*   Function:   print_serial
*
*   Purpose:    prints a line to the serial printer, with CR LF
*
*   Arguments:  string
*
*   Returns:    
*
***********************************************************************/
int print_serial(char *str)
{
    int i;

    for (i=0; i<strlen(str); i++)
    {
        print_serial_char (str[i]);
    }
    print_serial_char (13);
    print_serial_char (10);
}

/***********************************************************************
*
*   Function:   select_item
*
*   Purpose:    This function selects/deselects an item and updates
*               the TEST_REC array containing the list of tests
*               to be run.
*
*   Arguments:  menu pointer, provided by VV
*
*   Returns:    This is an action function
*
***********************************************************************/
int select_item (MFORMPTR mnp)
{
    MFIELDPTR mnfp;

    if ((diagtable[mnp->cur_item].type==BOTH)
    ||  (diagtable[mnp->cur_item].type==Location)
    ||  (Location==PC)               ) {
        CHECKMARK(mnp);                 /* toggle the checkmark     */

        mnfp = (MFIELDPTR)i_numptr(mnp->cur_item, mnp);
        if (mnf_ischecked(mnfp))
        {
            diagtable[mnp->cur_item].selected = TRUE;
        } else
        {
            diagtable[mnp->cur_item].selected = FALSE;
        }
    }
    return (SAMELEVEL);             /* return to calling menu   */
}

/***********************************************************************
*
*   Function:   runsel
*
*   Purpose:    This executes all functions that have been selected
*
*   Arguments:  menu pointer 
*
*   Returns:    SAMELEVEL
*
***********************************************************************/
unsigned int parfree(void)
{
    union REGS regs;
    regs.h.ah=0x48;
    regs.x.bx=0xFFFF;
    intdos(&regs,&regs);
    return(regs.x.bx);
}
int runsel (MFORMPTR mnp)
{
    int i;
    STATUS stat;
    char buffer[81];
    char pbuffer[81];
    int done = FALSE;
    char timestr[9];
    char datestr[9];
    screen_up();

    do
    {
        disp_title ((char *)message[MSGRUNTESTS]);

        for (i=0; i<MAINMENUOPTS; i++)
        {
            if (diagtable[i].selected)
            {
                if (ki_chk())
                {
                    if (ki() == EXIT_KEY)        /* F10 or EXIT */
                    {
                        done = TRUE;
                        break;
                    }
                }
                stat = diagtable[i].fn();
                diagtable[i].status = stat;
                if (stat == FAILED)
                {
                    sprintf (buffer, "%s %s", menuopt[i], Statstr[stat]);
#ifdef FACTORY
                    log_error(buffer);
#endif
                    }
            }
        }

        /* display test results for iteration */

        screen_up ();                   /* make sure it's still up */
        disp_title ((char *)message[MSGTESTRESULTS]);
        wn_clr(wnp);

        date_get (datestr, "MM/DD/YY");
        time_get (timestr, "HH:MM:SS");

        if (Location == CT)
            init_com4();
        
        if (!Disable_Print)
        {
            if (Location == CT)
            {
                /* initialise serial printer for results printout */
                print_serial (" ");
                print_serial (text[TXT_RES_01]);
                print_serial (text[TXT_RES_02]);
                print_serial (text[TXT_RES_03]);
                sprintf (buffer, text[TXT_RES_05], datestr, timestr);
                print_serial (buffer);
                print_serial (text[TXT_RES_01]);
            } else
            {
                print_str (" ");
                print_str (text[TXT_RES_01]);
                print_str (text[TXT_RES_02]);
                print_str (text[TXT_RES_04]);
                sprintf (buffer, text[TXT_RES_05], datestr, timestr);
                print_str (buffer);
                print_str (text[TXT_RES_01]);
            }
        }

        for (i=0; i < MAINMENUOPTS; i++)
        {
            if (diagtable[i].selected)
            {
                sprintf (buffer, "%-30.30s %s",
                    menuopt[i], Statstr[diagtable[i].status]);
                v_stpl(i, CENTER_TEXT, buffer, wnp);
                if (!Disable_Print)
                {
                    if (Location == CT)
                    {
                        /* don't print the letter-space-dash-space */
                        print_serial (buffer+4);
                    } else
                    {
                        print_str (buffer);
                    }
                }
            }
        }

        if (!Burn_In)               /* if one pass, exit now */
        {
            done = TRUE;
        } else                      /* show intermediate results */
        {
            if (key_or_timeout (SHORT_DELAY) == EXIT_KEY)
                done = TRUE;
        }

        if (ki_chk())
        {
            if (ki() == EXIT_KEY)        /* F10 or EXIT */
                done = TRUE;
        }

        Iteration++;                    /* increment loop counter */

        for (i=0; i < MAINMENUOPTS; i++)
            diagtable[i].status = SKIPPED;

    } while (!done);
    
    disp_exit (message[PRESSKEY], NULL, ANY_MASK);

    screen_down();

    return (SAMELEVEL);
}

/***********************************************************************
*
*   Function:   runall
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int runall (MFORMPTR mnp)
{
    int i;
    MFIELDPTR mnfp;

    for (i=0; i < MAINMENUOPTS; i++)
    {
        /* select all tests */

        mnfp = (MFIELDPTR)i_numptr(i, mnp);             /* get field ptr    */
        if ((diagtable[i].type==BOTH)
        ||  (diagtable[i].type==Location)
        ||  (Location==PC)               ) {
            smnf_checkstatus (ON, mnfp);                /* turn it on       */
            diagtable[i].selected = TRUE;               /* set in table     */
        }
        else {
            smnf_checkstatus (OFF, mnfp);               /* turn it off      */
            diagtable[i].selected = FALSE;              /* set in table     */
        }
    }

    mn_upd(mnp);                                    /* update the menu  */

    /* call run selected tests */
    return (runsel(mnp));
}

/***********************************************************************
*
*   Function:   clearsel
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int clearsel (MFORMPTR mnp)
{
    int i;
    MFIELDPTR mnfp;

    for (i=0; i < MAINMENUOPTS; i++)
    {
        /* clear all tests */

        mnfp = (MFIELDPTR)i_numptr(i, mnp);         /* get field ptr    */
        smnf_checkstatus (OFF, mnfp);               /* turn it off      */
        diagtable[i].selected = FALSE;              /* set in table     */
    }

    mn_upd(mnp);                                    /* update the menu  */

    return (SAMELEVEL);
}

/***********************************************************************
*
*   Function:   setsel
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int setsel (MFORMPTR mnp)
{
    int i;
    MFIELDPTR mnfp;

    for (i=0; i < MAINMENUOPTS; i++)
    {
        /* set all tests */

        mnfp = (MFIELDPTR)i_numptr(i, mnp);             /* get field ptr    */
        if ((diagtable[i].type==BOTH)
        ||  (diagtable[i].type==Location)
        ||  (Location==PC)               ) {
            smnf_checkstatus (ON, mnfp);                /* turn it on       */
            diagtable[i].selected = TRUE;               /* set in table     */
        }
        else {
            smnf_checkstatus (OFF, mnfp);               /* turn it off      */
            diagtable[i].selected = FALSE;              /* set in table     */
        }
    }

    mn_upd(mnp);                                    /* update the menu  */

    return (SAMELEVEL);
}

/***********************************************************************
*
*   Function:   looptests
*
*   Purpose:    sets the Burn_In Flag to false or true
*
*   Arguments:  MFORMPTR
*
*   Returns:    SAMELEVEL
*
***********************************************************************/
int looptests (MFORMPTR mnp)
{
    MFIELDPTR mnfp;

    CHECKMARK(mnp);
    mnfp = (MFIELDPTR)i_numptr(LOOPTESTS, mnp); /* get field ptr    */
    if (mnf_ischecked(mnfp))
        Burn_In = TRUE;
    else
        Burn_In = FALSE;

    return (SAMELEVEL);
}
/***********************************************************************
*
*   Function:   prat
*
*   Purpose:    print a line on the screen at an x,y co-ordinate
*
*   Arguments:  x,y co-ord and line to print
*
*   Returns:    None
*
***********************************************************************/
void prat(int x,int y,char *line)
{
    unsigned int *scr=(unsigned int *)0xB0000000L;
    int i;
    for (i=0;i<strlen(line);i++)
        *(x+(y*80)+scr+i)=0x7000|line[i];
}
/***********************************************************************
*
*   Function:   list_error
*
*   Purpose:    list the error log to screen
*
*   Arguments:  menu option type
*
***********************************************************************/
int list_error (MFORMPTR mnp)
{
    unsigned int *scr=(unsigned int *)0xB0000000L;
    int i,j;
    FILE *fp;
    char buf[82];
    
    for (i=0;i<2000;i++)
        *(scr+i)=0x7000;   /* clear screen */
    prat(18,24,text[TXT_VERRORL]);
    fp=fopen("ERRORS.LOG","r");
    if (fp==(FILE *)NULL) {
        prat(0,0,"No Errors Found");
        key_or_timeout(IDLE_TIME);
    }
    else {
        j=0;
        while (fgets(buf,81,fp)!=(char *)NULL) {
            buf[strlen(buf)-1]=0;
            prat(0,j++,buf);
            if (j==24) {
                j=0;
                if (key_or_timeout (IDLE_TIME) == VOID_KEY)
                    break;
                for (i=0;i<1920;i++)
                    *(scr+i)=0x7000;   /* clear screen */
            }
        }
        if (j!=0) 
            key_or_timeout(IDLE_TIME);
        fclose(fp);
    }
    for (i=0;i<2000;i++)
        *(scr+i)=0x7000;   /* clear screen */
    mn_upd(mnp);                                    /* update the menu  */
    return (SAMELEVEL);
}
/***********************************************************************
*
*   Function:   suppress
*
*   Purpose:    sets the Disable_Print Flag to false or true
*
*   Arguments:  MFORMPTR
*
*   Returns:    SAMELEVEL
*
***********************************************************************/
int suppress (MFORMPTR mnp)
{
    MFIELDPTR mnfp;

    CHECKMARK(mnp);
    mnfp = (MFIELDPTR)i_numptr(SUPPRESS, mnp); /* get field ptr    */
    if (mnf_ischecked(mnfp))
        Disable_Print = TRUE;
    else
        Disable_Print = FALSE;

    return (SAMELEVEL);
}

/***********************************************************************
*
*   Function:   halt
*
*   Purpose:    This function is called if the system cannot be
*               initialised properly.  It causes execution to
*               terminate and doesn't allow the user to proceed.
*
*   Arguments:  error code
*
*   Returns:    None
*
***********************************************************************/
void halt (ERRORCODE error)
{
    fprintf (stderr, "Error %d initialising system.  Please restart.\n", error);
    do
    {
        ki();
        bell();
    }
    while (TRUE);
}

/***********************************************************************
*
*   Function:   init_menu
*
*   Purpose:    defines the main menu
*
*   Arguments:  none
*
*   Returns:    none
*
***********************************************************************/
int init_menu()
{
    MFIELDPTR mnfp;
    int i;

    /* define the menu */

    mainmnp = mn_def (MNSTANDARD, 0, 0, 25, screen_cols, LNORMAL, BDR_NULLP);
    if (mainmnp == NULL)
    {
        halt (MENUDEF_ERR);
    }

    /* define the options */

    for (i=0; i < MAINMENUOPTS; i++)
    {
        if ((diagtable[i].type==BOTH)
        ||  (diagtable[i].type==Location)
        ||  (Location==PC)               ) {
            mnfp = mnf_def (i+2, 5, menuopt[i], NULL, NULL,
                            select_item, mainmnp);
        }
        else {
            strcpy(&menuopt[i][4],"Not Applicable");
            mnfp = mnf_def (i+2, 5, menuopt[i], NULL, NULL,
                            select_item, mainmnp);
        }
    }
    mnfp = mnf_def (2, 45, menuopt[RUNALL], NULL, NULL, runall, mainmnp);
    mnfp = mnf_def (3, 45, menuopt[RUNSEL], NULL, NULL, runsel, mainmnp);
    mnfp = mnf_def (4, 45, menuopt[CLEARSEL], NULL, NULL, clearsel, mainmnp);
    mnfp = mnf_def (5, 45, menuopt[SETSEL], NULL, NULL, setsel, mainmnp);
    mnfp = mnf_def (7, 45, menuopt[SUPPRESS], NULL, NULL, suppress, mainmnp);
    mnfp = mnf_def (8, 45, menuopt[LOOPTESTS], NULL, NULL, looptests, mainmnp);
#ifdef FACTORY
    if (Location == BOP)
        mnfp = mnf_def (10, 45, menuopt[FORMATHD], NULL, NULL, hd_format, mainmnp);
    mnfp = mnf_def (12, 45, menuopt[LISTERROR], NULL, NULL, list_error, mainmnp);
#endif
    if (Location == CT)
        bg_txtdef  ( 0, CENTER_TEXT, message[CTTITLE], LNORMAL, mainmnp);
    else if (Location == BOP)
        bg_txtdef  ( 0, CENTER_TEXT, message[BOPTITLE], LNORMAL, mainmnp);
    else
        bg_txtdef  ( 0, CENTER_TEXT, message[PCTITLE], LNORMAL, mainmnp);

    bg_txtdef  ( 0, RIGHT_TEXT, text[TXT_VER_01], LNORMAL, mainmnp);
    bg_linedef ( 1, 0, screen_cols, RIGHT, LNORMAL, LINE_SLNP, mainmnp);
    bg_linedef (22, 0, screen_cols, RIGHT, LNORMAL, LINE_SLNP, mainmnp);
    bg_txtdef  (23, CENTER_TEXT, message[MSGRUNALL], LNORMAL, mainmnp);
    bg_txtdef  (24, CENTER_TEXT, message[MSGRUNSEL], LNORMAL, mainmnp);

    smn_checkmark (0x10, mainmnp);

}

/***********************************************************************
*
*   Function:   init_mmi
*
*   Purpose:    This function initialises the system.
*
*   Arguments:  None
*
*   Returns:    TRUE | FALSE
*
***********************************************************************/
int init_mmi(LOCATION loc)
{
    int status;

    // m80();
    // system ("M80 > NUL");           /* set mono 80 columns */

    init_vv();

    /* get pointers to the windows */

    title_wnp = &title_wn;
    inst_wnp = &inst_wn;
    error_wnp = &error_wn;
    wnp = &wn;
    
    /* initialise the windows */
    screen_cols = 80;

    status = wn_sdef ( 0,  0,  2, screen_cols, LNORMAL, BDR_NULLP, title_wnp);
    if (status == 0)
    {
        halt (TITLE_ERR);
    }
    status = wn_sdef (22,  0,  3, screen_cols, LNORMAL, BDR_NULLP, inst_wnp);
    if (status == 0)
    {
        halt (PROMPT_ERR);
    }
    status = wn_sdef (22,  0,  3, screen_cols, LURGENT, BDR_NULLP, error_wnp);
    if (status == 0)
    {
        halt (ERROR_ERR);
    }
    status = wn_sdef ( 2,  0, 20, screen_cols, LNORMAL, BDR_NULLP, wnp);
    if (status == 0)
    {
        halt (WN_ERR);
    }

    init_menu();

    csr_hide();
}
void mybuzz(PTR a)
{
    kbd_buzz();
}
void set_ram_val(void) {
    unsigned int i,checksum,j;

    i=((get_cmos(0x16)&0xFF)<<8)|(get_cmos(0x15)&0xFF);
    if (i!=1024) {
        printf("Base Memory Found At %dK\nCMOS Adjusted To 1024K\n",i);
        put_cmos(0x15,0);
        put_cmos(0x16,4);
    }
    checksum=0;
    for (i=CMOS_BEG;i<=CMOS_END;i++) {
        j=get_cmos(i);
        checksum+=j;
    }
    put_cmos(CMOS_MSCS,checksum>>8  );       /* Set MS Checksum value */
    put_cmos(CMOS_LSCS,checksum&0xFF);       /* Set LS Checksum value */
}
/***********************************************************************
*
*   Function:   main
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
main(int argc, char **argv)
{
    int i, vidmode;                 /* save video mode              */
    Burn_In = FALSE;                /* default to FALSE (global)    */
    Disable_Print = FALSE;          /* default to FALSE (global)    */
    Iteration = 0;                  /* initialise interation count  */

    vidmode = get_videomode();

    _att_tbl[LNORMAL ][0]=REVERSE;
    _att_tbl[LREVERSE][0]=NORMAL;
    _att_tbl[LMNINACT][0]=REVERSE;
    _att_tbl[LMNACT  ][0]=NORMAL;
    _att_tbl[LMNSELCH][0]=REVERSE;

    if (argc >= 2)
    {
        if (strcmp(strupr(argv[1]), "CT") == 0) {
//            set_ram_val();
            Location = CT;
            set_com4_addr();
        }
        else if (strcmp(strupr(argv[1]), "BOP") == 0) {
            set_ram_val();
            Location = BOP;
        }
        else if (strcmp(strupr(argv[1]), "PC") == 0) {
            Location = PC;
        }
        else {
            usage();
        }
    } else
    {
        usage();
    }
    init_mmi(Location);
    if (Location==CT) {
        kt_rplkey(KT_DEFAULT,mybuzz,VIEWKTP);
        kt_rplkey(KT_DEFAULT,mybuzz,HELPKTP);
        kt_rplkey(KT_DEFAULT,mybuzz,DRAGKTP);
    }
#ifdef FACTORY
    mn_proc (0, mainmnp);
#else
    for (;;) mn_proc (RUNALL, mainmnp);
#endif
    mn_free (mainmnp);

    set_videomode (vidmode);
}
