/***********************************************************************
*
*   File:           dvtcmos.c
*
*   Purpose:        cmos test
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 11-27-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTCMOS.C_V  $
*  
*     Rev 1.2   14 Jan 1991 16:19:20   AJW
*  Improvements of user interface.
*  
*     Rev 1.1   11 Jan 1991 17:40:10   AJW
*  Adapted to new DVT test versions called "Utility" and "Factory"
*  
*     Rev 1.0   10 Dec 1990 10:29:50   PJE
*  Initial revision.
*
***********************************************************************/

/**************
 Include Files            
***************/

#include <dos.h>
#include <stdlib.h>
#include <malloc.h>

#include "eccodefs.h"
#include "globals.h"
#include "dvtmsgs.h"
#include "bpokeys.h"


#define CMOS_BEG        0x10            /* CMOS RAM beginning address */
#define CMOS_END        0x2D            /* CMOS RAM ending address */
#define CMOS_MSCS       0x2E            /* CMOS RAM Most Sig. Checksum */
#define CMOS_LSCS       0x2F            /* CMOS RAM Least Sig. Checksum */

static char *flopy_type[] = {"NONE", "360K", "1.2M", "720K", "1.44M"};
static char *video_type[] = {"EGA/VGA", "CGA 40x25", "CGA 80x25", "MDA"};

/***********************************************************************
*
*     function:               diag_cmos()
*
*     purpose:                confirm CMOS RAM set correctly
*
*     arguments:              none
*
*     returns:                int
*
*                             PASSED if test passed
*                             FAILED, if test failed
*
************************************************************************/

int test_cmos()
{
    int    key, checksum;
    int    i, j, k, l;
    short  result;
    char   temp_str[80];

    clear_all_windows();
    disp_title (menuopt[2]);
    disp_inst (NULL, NULL);

    v_stpl ( 1, 0, text[TXT_CMOS_01], wnp);

    result = PASSED;                    /* default to PASS */

    for (i = CMOS_BEG, checksum = 0; i <= CMOS_END; i++) {
        j = get_cmos(i);
        checksum += j;
    }

    j = get_cmos(CMOS_MSCS);            /* Read MS Checksum value */

    k = get_cmos(CMOS_LSCS);            /* Read LS Checksum value */

    j = j << 8;
    j = j | k;

    if (j == checksum) {
        v_st (Statstr[PASSED], wnp);
        result = PASSED;
    } else {
        v_printf(wnp, "%0x-%0x    %s", checksum, j, Statstr[FAILED]);
        result = FAILED;
    }

#ifdef FACTORY

    key = disp_exit(text[TXT_CMOS_02], text[TXT_CMOS_03],
                    ENTER_MASK | VOID_MASK);
    disp_inst (NULL, NULL);
    if (key == ENTER_KEY)
    {
        clear_window(wnp);
        cs_mv(1, 0, wnp);

        i = get_cmos(0x04);
        j = get_cmos(0x02);
        k = get_cmos(0x00);
        v_printf(wnp, text[TXT_CMOS_04], i, j, k);

        i = get_cmos(0x05);
        j = get_cmos(0x03);
        k = get_cmos(0x01);
        v_printf(wnp, text[TXT_CMOS_05], i, j, k);

        i = get_cmos(0x08);
        j = get_cmos(0x07);
        k = get_cmos(0x09);
        l = get_cmos(0x32);
        v_printf(wnp, text[TXT_CMOS_06], i, j, l, k);

        i = get_cmos(0x15);
        j = get_cmos(0x16);
        i &= 0x00FF;
        j <<= 8;
        j &= 0xFF00;
        i |= j;
        if (i!=1024) {
            put_cmos(0x15,0);
            put_cmos(0x16,4);
        }
        v_printf(wnp, text[TXT_CMOS_07], i);

        i = get_cmos(0x17);
        j = get_cmos(0x18);
        i &= 0x00FF;
        j <<= 8;
        j &= 0xFF00;
        i |= j;
        v_printf(wnp, text[TXT_CMOS_08], i);

        i = get_cmos(0x14);
        j = (i >> 4) & 0x0003;
        v_printf(wnp, text[TXT_CMOS_09], video_type[j]);

        if (i & 0x0002)
            v_st (text[TXT_CMOS_10], wnp);

        if (i & 0x0001)
        {
            j = (i >> 6) & 0x0003;
            v_printf(wnp, text[TXT_CMOS_11], j+1);

            i = get_cmos(0x10);
            j = i >> 4;
            k = i & 0x000F;
            v_printf(wnp, text[TXT_CMOS_12], flopy_type[j]);
            v_printf(wnp, text[TXT_CMOS_13], flopy_type[k]);
        }

        i = get_cmos(0x12);
        j = i >> 4;
        k = i & 0x000F;
        if (j == 0x000F)
            j = get_cmos(0x19);
        if (k == 0x000F)
            k = get_cmos(0x1A);
        if (j)
            sprintf(temp_str, text[TXT_CMOS_14], j);
        else
            strcpy(temp_str, text[TXT_CMOS_15]);
        v_printf(wnp, text[TXT_CMOS_16], temp_str);
        if (k)
            sprintf(temp_str, text[TXT_CMOS_14], k);
        else
            strcpy(temp_str, text[TXT_CMOS_15]);
        v_printf(wnp, text[TXT_CMOS_17], temp_str);

        i = get_cmos(0x2E);
        j = get_cmos(0x2F);
        i &= 0x00FF;
        j <<= 8;
        j &= 0xFF00;
        i |= j;
        cs_mv(1, 45, wnp);
        v_printf(wnp, text[TXT_CMOS_18], i);

        i = get_cmos(0x0E);
        j = 3;
        cs_mv(j, 45, wnp);
        v_printf(wnp, text[TXT_CMOS_19], i);
        if (i & 0x00FC)
        {
            if (i & 0x0080)
                v_stpl (j++, 50, text[TXT_CMOS_20], wnp);
            if (i & 0x0040)
                v_stpl (j++, 50, text[TXT_CMOS_21], wnp);
            if (i & 0x0020)
                v_stpl (j++, 50, text[TXT_CMOS_22], wnp);
            if (i & 0x0010)
                v_stpl (j++, 50, text[TXT_CMOS_23], wnp);
            if (i & 0x0008)
                v_stpl (j++, 50, text[TXT_CMOS_24], wnp);
            if (i & 0x0004)
                v_stpl (j++, 50, text[TXT_CMOS_25], wnp);
        }
        key = disp_exit(message[PRESSKEY], NULL, ANY_MASK);
        disp_inst (NULL, NULL);
    }
#else

    delay_ticks(SHORT_DELAY);
#endif

    return(result);
}


