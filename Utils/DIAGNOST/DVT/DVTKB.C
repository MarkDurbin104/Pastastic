/***********************************************************************
*
*   File:           dvtkb.c
*
*   Purpose:        Diagnostics for keyboard
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
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTKB.C_V  $
*  
*     Rev 1.8   04 Mar 1991 13:45:22   PJE
*  Modified test_mcr to support multiple card swipes and reads before
*  evaluating whether the test passed or failed.
*  To continue swiping, SAME_CUST key is pressed;
*  for end of test, press END_CUST.
*  Allow operator to swipe card several times, pressing the SAME CUST
*  key to swipe another card, and pressing the END CUST key to
*  stop swiping.  As usual, after swipes, ENTER PASSES test and VOID
*  FAILs the test.
*  
*     Rev 1.7   01 Feb 1991 16:08:48   PJE
*  Set key termination test to accept any +/- symbol generatable by the
*  keyboard, followed by the ENTER key to end the test.
*  
*     Rev 1.6   01 Feb 1991  9:58:48   AJW
*  Added two new ending keyboard test sequences:
*  <+/END CUST><ENTER>, <-/SAME CUST><ENTER>.
*  
*  
*     Rev 1.5   14 Jan 1991 16:29:08   AJW
*  Improvements of user interface.
*  
*     Rev 1.4   11 Jan 1991 17:37:06   AJW
*  Adapted to new DVT test versions called "Utility" and "Factory"
*  
*     Rev 1.3   07 Jan 1991 11:25:30   PJE
*  Made additions to support MCR tests. Still needs some more work.  The
*  swipe card doesn't work properly.
*  
*     Rev 1.1   13 Dec 1990 16:28:30   PJE
*  
*  Added keyboard buzzer test;
*  Added MCR test - still fails, problem in driver;
*  
*  
*     Rev 1.0   10 Dec 1990 10:43:30   PJE
*  Initial revision.
*
***********************************************************************/
#include <dos.h>
#include <time.h>
#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>
#include "eccodefs.h"
#include "globals.h"
#include "dvtmsgs.h"
#include "bpokeys.h"

struct key_legends {
    int code;
    char *label;
};

/*  labels of CT keyboard   */
static struct key_legends ctlabels[] =
{
    {0x5d00, "LOCK"},
    {0x4400, "EXIT"},
    {0x0231, "1"},
    {0x0332, "2"},
    {0x0433, "3"},
    {0x0534, "4"},
    {0x0635, "5"},
    {0x0736, "6"},
    {0x0837, "7"},
    {0x0938, "8"},
    {0x0a39, "9"},
    {0x0b30, "0"},
    {0x0c2d, "-/MVL V10"},
    {0x0d3d, "=/DNS dep ord"},
    {0x0e08, "DEL"},
    {0x0faa, "ª/BVP"},
    {0x1051, "Q/Enqry"},
    {0x1157, "W/Local 1"},
    {0x1245, "E/blank"},
    {0x1352, "R/blank"},
    {0x1454, "T/Travel cheq"},
    {0x1559, "Y/blank"},
    {0x1655, "U/blank"},
    {0x1749, "I/blank"},
    {0x184F, "O/Other post"},
    {0x1950, "P/Philatelic"},
    {0x1071, "q/Enqry"},
    {0x1177, "w/Local 1"},
    {0x1265, "e/blank"},
    {0x1372, "r/blank"},
    {0x1474, "t/Travel cheq"},
    {0x1579, "y/blank"},
    {0x1675, "u/blank"},
    {0x1769, "i/blank"},
    {0x186F, "o/Other post"},
    {0x1970, "p/Philatelic"},
    {0x1a5b, "[/blank"},
    {0x1b5d, "]/BT stamp redm"},
    {0x1c0d, "ENTER/="},
    {0x6c00, "SHIFT RECPT"},
    {0x1d00, "RECPT"},
    {0x1e41, "A/Local 2"},
    {0x1f53, "S/Home help"},
    {0x2044, "D/Other saving stamp"},
    {0x2146, "F/TV saving stamp"},
    {0x2247, "G/BT saving stamp"},
    {0x2348, "H/blank"},
    {0x244a, "J/Disc whole stamp"},
    {0x254b, "K/Stamp book vend"},
    {0x264c, "L/Stamp book other"},
    {0x1e61, "a/Local 2"},
    {0x1f73, "s/Home help"},
    {0x2064, "d/Other saving stamp"},
    {0x2166, "f/TV saving stamp"},
    {0x2267, "g/BT saving stamp"},
    {0x2368, "h/blank"},
    {0x246a, "j/Disc whole stamp"},
    {0x256b, "k/Stamp book vend"},
    {0x266c, "l/Stamp book other"},
    {0x273b, ";/TV stamp redm"},
    {0x2827, "'/P&A other"},
    {0x2960, "`/BED"},
    {0x2b5c, "\\/BT recpt"},
    {0x2c5a, "Z/Local 3"},
    {0x2d58, "X/NIS high"},
    {0x2e43, "C/NIS other"},
    {0x2f56, "V/TV licnce"},
    {0x3042, "B/Phone card"},
    {0x314e, "N/Postal order"},
    {0x324d, "M/Post stamp"},
    {0x2c7a, "z/Local 3"},
    {0x2d78, "x/NIS high"},
    {0x2e63, "c/NIS other"},
    {0x2f76, "v/TV licnce"},
    {0x3062, "b/Phone card"},
    {0x316e, "n/Postal order"},
    {0x326d, "m/Post stamp"},
    {0x332c, ",/2nd stamp"},
    {0x342e, "./1st stamp"},
    {0x352f, "//DNS dep other"},
    {0x362a, "*/blank"},
    {0x6d00, "SHIFT CALC"},
    {0x3800, "CALC"},
    {0x3920, "SPACE BAR"},
    {0x3a00, "key A-13"},
    {0x6e00, "SHIFT HELP"},
    {0x3b00, "HELP"},
    {0x3c2b, "+/MVL V11"},
    {0x6f00, "SHIFT CE/VOID"},
    {0x011b, "CE/VOID"},
    {0x7000, "SHIFT DISCOUNT"},
    {0x3e00, "DISCOUNT"},
    {0x7100, "SHIFT PLU"},
    {0x3f00, "PLU"},
    {0x7200, "-/SAME CUST"},
    {0x7300, "+/END CUST"},
    {0x4223, "#/blank"},
    {0x4340, "@/Milk P&A"},
    {0x3d00, "Milk Giro"},
    {0x4500, "VOUCH"},
    {0x4600, "GIRO TRANSFER"},
    {0x4700, "PART CHEQ"},
    {0x4900, "PAGE UP"},
    {0x4800, "UP"},
    {0x6900, "PART CASH"},
    {0x4a00, "P&A 13"},
    {0x0f00, "TAB LEFT"},
    {0x4b00, "LEFT"},
    {0x0f09, "TAB RIGHT"},
    {0x4d00, "RIGHT"},
    {0x4e00, "key C-13"},
    {0x4f00, "x/CHEQ"},
    {0x5100, "PAGE DOWN"},
    {0x5000, "DOWN"},
    {0x4c00, "ö/CASH"},
    {0x6a00, "00"},
    {0x6a30, "00 key"},
    {0x53f9, "ù Number Pad"},
    {0x547b, "{/blank"},
    {0x557d, "}/DNS wdl ord"},
    {0x563a, ":/DNS wdl other"},
    {0x577e, "~/Other banks cheq"},
    {0x58b3, "³/blank"},
    {0x597c, "|/blank"},
    {0x5a3c, "</Other stamp redm"},
    {0x5b3e, ">/P&A 14"},
    {0x5c00, "Green Giro"},
    {0x6b00, "key B-13"},
    {0x5e21, "!/Comm charg"},
    {0x5f22, "\"/Giro trans-cash"},
    {0x609c, "œ/Giro vouch"},
    {0x6124, "$/Giro dep"},
    {0x625e, "^/Giro dep other"},
    {0x6326, "&/blank"},
    {0x6428, "(/Giro wdl"},
    {0x6529, ")/Giro wdl other"},
    {0x665f, "_/blank"},
    {0x673f, "?/P&A 5"},
    {0x6825, "%/P&A 11"},
    {0x0000, "END"}
};

static struct key_legends boplabels[] =
{
    {0x3b00, "F1"},
    {0x3c00, "F2"},
    {0x3d00, "F3"},
    {0x3e00, "F4"},
    {0x3f00, "F5"},
    {0x4000, "F6"},
    {0x4100, "F7"},
    {0x4200, "F8"},
    {0x4300, "F9"},
    {0x4400, "F10"},
    {0x8500, "F11"},
    {0x8600, "F12"},
    {0x011b, "Esc"},
    {0x1c0d, "ENTER"},
    {0x3920, "SPACE BAR"},
    {0x0f08, "Tab"},
    {0x0f00, "Back Tab"},
    {0x0000, "END"}
};

/***********************************************************************
*
*   Function:   kblabel
*
*   Purpose:    gets label of CT keyboard
*
*   Arguments:  bios keycode
*
*   Returns:    ptr to label string
*
***********************************************************************/
char *kblabel (int bioskey)
{
    struct key_legends *table;
    int i;
    static char ascii_code[2];

    if (Location == CT)
        table = ctlabels;
    else
        table = boplabels;

    for (i = 0; table[i].code != 0x0000; i++)
    {
        if (table[i].code == bioskey)
            return ((char *)table[i].label);
    }
    /* if it falls through to here, check if there is an
     * ascii code with the key
     */
    ascii_code[1] = '\0';
    ascii_code[0] = (char)(bioskey & 0xff);

    if (ascii_code[0] != 0)
        return ((char *)ascii_code);
    else
        return ("Unknown");
}

/***********************************************************************
*
*   Function:   test_mcr
*
*   Purpose:    This function tests the mcr;
*
*   Arguments:  none
*
*   Returns:    PASSED | FAILED
*
***********************************************************************/
STATUS test_mcr()
{
    unsigned char buffer[129];
    int mode;
    int count;
    int i, j;
    STATUS stat;
    int key;
    BOOLEAN deciding = TRUE;
    STATUS result = FAILED;
    BOOLEAN testing = TRUE;


    do
    {
        clear_window();
        v_printf (wnp,"%s", text[TXT_KB_12]);
        while (ki_chk()) ki();

        kbd_buzz();
        disp_inst (text[TXT_KB_08], text[TXT_KB_17]);

        mode = mcr_swipe();
        disp_inst (NULL, NULL);

        if (mode == 1)
        {
            v_printf (wnp, "        SWIPE %s", Statstr[PASSED]);

            for (i = 0; i < 3; i++)     /* read the tracks */
            {
                v_printf (wnp, text[TXT_KB_13], i+1);
                count = 128;
                if ( mcr_readtrack (i, buffer, &count))
                {
                    v_printf (wnp, "%s\n", Statstr[PASSED] );
                    v_printf (wnp, text[TXT_KB_15]);
                    for (j=0; j < count; j++)
                    {
                        v_printf (wnp, "%02Xh ", buffer[j]);
                    }
                    v_printf (wnp, "\n");

                    /* convert to ANSI/ISO character set */
                    decode_track (i, buffer, count);
                    v_printf (wnp, text[TXT_KB_16]);
                    for (j=0; j < count; j++)
                        v_printf (wnp, "%c", buffer[j]);

                } else
                {
                    v_printf (wnp, text[TXT_KB_14]);
                }
            }

            disp_inst (text[TXT_KB_18], text[TXT_KB_19]);

            deciding = TRUE;
            do
            {
                key = key_or_timeout(IDLE_TIME);

                switch (key)
                {
                    case 0:
                    case ENDCUST_KEY:
                        testing = FALSE;
                        deciding = FALSE;
                        break;
                    case SAMECUST_KEY:
                        testing = TRUE;
                        deciding = FALSE;
                        break;
                    default:
                        kbd_buzz();
                        break;
                }
            }
            while (deciding);

            disp_inst (NULL, NULL);

        } else
        {
            v_st ("               ", wnp);
            if (mode == 0)
            {
                result = SKIPPED;
                testing = FALSE;
            }
        }
    }
    while (testing);

    if (result != SKIPPED)
    {
        key = disp_exit (text[TXT_KB_04],
                    text[TXT_KB_05],
                    ENTER_MASK | VOID_MASK);

        disp_inst (NULL, NULL);

        switch (key)
        {
            case ENTER_KEY:
                result = PASSED;
                break;
            case VOID_KEY:
                result = FAILED;
                break;
            case 0:
                result = SKIPPED;
                break;
        }
    }
    v_printf (wnp, "\n\n%s               ", text[TXT_KB_12]);

    v_st (Statstr[result], wnp);

    kbd_buzz();

    while (ki_chk()) ki();

}

/***********************************************************************
*
*   Function:   test_keyboard
*
*   Purpose:    function called to test keyboard
*
*   Arguments:  none
*
*   Returns:    PASSED | SKIPPED | FAILED
*
*   Note:       This test should time out if no attendant
*
***********************************************************************/
int test_keyboard()
{
    FILE *fp;
    char tmp[20];
    int lastkey = 0;
    int done = FALSE;
    int bioskey;
    int vvkey;
    int key;
    STATUS result = SKIPPED;
    STATUS tresult = SKIPPED;
    time_t start, stop;

    disp_title (menuopt[3]);

    clear_window();
    if (Location==CT) {
        disp_inst ("Press ALL the keys,","[ENTER] should be the LAST key Pressed");
        system("KEYTEST CT");
        done=TRUE;
        fp=fopen("KBDERR.LOG","r");
        fgets(tmp,20,fp);
        switch (tmp[0]) {
            case 'E' : result=FAILED;  break;
            case 'P' : result=PASSED;  break;
            case 'S' : result=SKIPPED; break;
        }
        fclose(fp);
    } else {
        disp_inst (text[TXT_KB_01], text[TXT_KB_02]);
        time(&start);
        do {
            if (get_key_status()) {
                bioskey=get_key();
                v_printf(wnp,text[TXT_KB_03],kblabel(bioskey));
                if (bioskey==0x1c0d) {
                    if (lastkey=='+') {
                        done=TRUE;
                        result=PASSED;
                    } else
                    if (lastkey=='-') {
                        done=TRUE;
                        result=FAILED;
                    }
                }
                lastkey=bioskey;
                switch (lastkey) {
                    case 0x7200: lastkey='-'; break;
                    case 0x7300: lastkey='+'; break;
                    default: lastkey=lastkey&0xff;
                }
                time(&start);
            } else {
                time (&stop);
                if ((stop-start)>(IDLE_TIME/18)) {
                    result=SKIPPED;
                    done=TRUE;
                }
            }
        }
        while (!done);
    }

    clear_window();
    disp_inst (NULL, NULL);

    v_stpl (0,  0, text[TXT_KB_11], wnp);
    v_stpl (0, 40, Statstr[result], wnp);

    /********************************************/
    /*  Test the keyboard buzzer if appropriate */
    /********************************************/

    if (Location == CT)
    {
        v_st ("\nÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ", wnp);
        v_stpl (2, 0, text[TXT_KB_07], wnp);
        tresult = (kbd_buzz() ? PASSED : FAILED);
        if (tresult == PASSED)
        {
            key = disp_exit (text[TXT_KB_06],
                             text[TXT_KB_05],
                             ENTER_MASK | VOID_MASK);

            disp_inst (NULL, NULL);

            switch (key)
            {
                case ENTER_KEY:
                    tresult = PASSED;
                    break;
                case VOID_KEY:
                    tresult = FAILED;
                    break;
                case 0:
                    tresult = SKIPPED;
                    break;
            }
            v_stpl (2, 40, Statstr[tresult], wnp);
        } else
        {
            v_stpl (2, 40, Statstr[FAILED], wnp);
        }

        if (tresult == FAILED)
            result = FAILED;
        kbd_buzz();

        /* see if the MCR is to be tested */
        key = disp_exit (text[TXT_KB_09],
                         text[TXT_KB_10],
                         ENTER_MASK | VOID_MASK);
        disp_inst (NULL, NULL);

        if (key == ENTER_KEY)
        {
            tresult = test_mcr();
            if (tresult == FAILED)
                result = FAILED;
        }
    }
    
    key_or_timeout (SHORT_DELAY);

    clear_window();
    disp_inst (NULL, NULL);

    return (result);
}
