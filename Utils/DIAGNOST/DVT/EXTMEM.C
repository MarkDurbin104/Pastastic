/************************************************************************/
/*  title:      extmem.c                                                */
/*                                                                      */
/*  purpose:    tests extended memory (384K beyond 1MB address)         */
/*                                                                      */
/*  author:     Paul J. Encarnacion                                     */
/*              UNISYS, Systems Development Group                       */
/*              5151 Camino Ruiz                                        */
/*              Camarillo, CA 93011                                     */
/*                                                                      */
/*  Revision:   August 30, 1988                                         */
/*                                                                      */
/*  Release   Date    Pgmr    Description                               */
/*                                                                      */
/************************************************************************
*       
*       $Log:   Z:\CM\F\BPO\DVT\VCS\EXTMEM.C_V  $
*  
*     Rev 1.0   10 Dec 1990 10:19:00   PJE
*  Initial revision.
*  
*     Rev 1.1   31 Aug 1988  9:37:44   PJE
*  
*  disabled interrupts before block move.
*  enabled interrupts after block move.
*  
*  
*     Rev 1.0   30 Aug 1988 21:15:04   PJE
*  
*  Extended memory test -- First Release.
*  Takes extended block number (in 32 KB blocks) and returns
*  TRUE or FALSE to pass or fail.
*  
*
*/  
/************************************************************************/
/*                                                                      */
/*  Include Files                                                       */
/*                                                                      */
/************************************************************************/

#include <stdio.h>
#include <malloc.h>
#include <memory.h>
#include <string.h>
#include <dos.h>

/************************************************************************/
/*                                                                      */
/*  Definitions                                                         */
/*                                                                      */
/************************************************************************/

#define PATTERN_1   0xAA            /* bit patterns for testing memory */
#define PATTERN_2   0x55
#define ZEROS       0x00

#define TRUE        1
#define FALSE       0

#define KBYTES      1024
#define BUF_SIZE    (32 * KBYTES)   /* memory checked in 32KB blocks */

#define EXTMEM_BASE (1024L * 1024L) /* 1MB starts extended memory */

#define MK_FP(a,b)  (void *)(long)(((long)a<<16)|(long)b)   

/************************************************************************/
/*                                                                      */
/*  Type Definitions                                                    */
/*                                                                      */
/************************************************************************/

typedef char            BYTE;
typedef unsigned int    WORD;
typedef char            ADDR24[3];

typedef struct 
{
    WORD    seg_limit;
    ADDR24  addr24;
    BYTE    data_acc_rights;
    WORD    reserved;

} GDT;


typedef struct 
{
    BYTE    dummy[8];
    BYTE    gdt_loc[8];
    GDT     source;
    GDT     destination;
    BYTE    bios[8];
    BYTE    stack[8];

} BLOCK_MOVE_GDT;
    
typedef int BOOLEAN;

/************************************************************************/
/*                                                                      */
/*  Global Data                                                         */
/*                                                                      */
/************************************************************************/

BLOCK_MOVE_GDT  gdt_table =
        {0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         {BUF_SIZE, 0,0,0, 0x93, 0},
         {BUF_SIZE, 0,0,0, 0x93, 0},
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0};

/************************************************************************/
/*                                                                      */
/*  External Functions                                                  */
/*                                                                      */
/************************************************************************/

    extern  int     byte_cmp();     /* MEM_CHK.ASM */


int  fill_block (buffer, pattern)                                  
/********************************************************************/
/*                                                                  */
/*     function:    fill_block                                      */
/*                                                                  */
/*     purpose:     fills a 32KB block of memory with 'pattern'     */
/*                                                                  */
/*     arguments:   pattern -- a byte to fill memory with           */
/*                                                                  */
/*     returns:     0   if all is well                              */
/*                  1   if error was encountered                    */
/*                                                                  */
/********************************************************************/
BYTE    *buffer;
BYTE    pattern;
{
    char *status;
        
    /* set the contents of buffer to be filled with pattern */

    status = memset(buffer, pattern, BUF_SIZE);

    if (status == NULL) 
        return (1);                 /* error encountered */
    else
        return (0);                 /* all ok */   
}


long    convert_addr_24 (byte_ptr)                                  
/********************************************************************/
/*                                                                  */
/*     function:    convert_addr_24                                 */
/*                                                                  */
/*     purpose:     computes a location's 24-bit physical address   */
/*                                                                  */
/*     arguments:   pointer to a BYTE                               */   
/*                                                                  */
/*     returns:     a 24-bit physical address stored in a 32-bit    */
/*                  long variable                                   */
/*                                                                  */
/********************************************************************/
BYTE    *byte_ptr;
{
    long    segment;
    long    offset;

    segment = FP_SEG(byte_ptr);
    offset  = FP_OFF(byte_ptr);

    return  ((segment << 4) + offset);               
}


int     block_xfer_in (dst, block_no)                                  
/********************************************************************/
/*                                                                  */
/*     function:    block_xfer_in                                   */
/*                                                                  */
/*     purpose:     moves a block of memory 32KB long from          */
/*                  extended memory down into low memory            */
/*                                                                  */
/*     arguments:   dst -- BYTE pointer to the destination buffer   */
/*                  block_no -- extended memory block to move       */
/*                                                                  */
/*     returns:     0   if successful                               */
/*                  1   if memory parity error                      */
/*                  2   if any other exception interrupt occurred   */
/*                  3   if gate address line 20 failed              */
/*                                                                  */
/********************************************************************/
long    dst;                /* 32 bit BYTE pointer */
int     block_no;           /* extended memory block index */

{
    union   REGS     regs;
    struct  SREGS    sregs;
    long    dest_addr, source_addr;
    BYTE    *gdt_addr;

    char tmp[80];
    int i;

    dest_addr = convert_addr_24 (dst);

    gdt_table.destination.addr24[0] =  dest_addr        & 0xFF;
    gdt_table.destination.addr24[1] = (dest_addr >> 8)  & 0xFF;
    gdt_table.destination.addr24[2] = (dest_addr >> 16) & 0xFF;
      
    source_addr = EXTMEM_BASE + (block_no*(long)BUF_SIZE);

    gdt_table.source.addr24[0] =  source_addr        & 0xFF;
    gdt_table.source.addr24[1] = (source_addr >> 8)  & 0xFF;
    gdt_table.source.addr24[2] = (source_addr >> 16) & 0xFF;

    /* set up block move function call */
    regs.h.ah = 0x87;                       /* block move */
    regs.x.cx = BUF_SIZE / 2;               /* word count to move */

    gdt_addr  = &gdt_table.dummy[0];        /* address of the gdt table */
    sregs.es  = FP_SEG (gdt_addr); 
    regs.x.si = FP_OFF (gdt_addr);

    _disable();                             /* disable interrupts */

    int86x (0x15, &regs, &regs, &sregs);    /* INT 15 H call */
    
    _enable();                              /* enable interrupts */

    return (regs.h.ah);                     /* return status */
}


int     block_xfer_out (src, block_no)                                  
/********************************************************************/
/*                                                                  */
/*     function:    block_xfer_out                                  */
/*                                                                  */
/*     purpose:     moves a block of memory 32KB long from          */
/*                  low memory to extended memory                   */
/*                                                                  */
/*     arguments:   src -- BYTE pointer to the source buffer        */
/*                  block_no -- ext. memory block to transfer to    */
/*                                                                  */
/*     returns:     0   if successful                               */
/*                  1   if memory parity error                      */
/*                  2   if any other exception interrupt occurred   */
/*                  3   if gate address line 20 failed              */
/*                                                                  */
/********************************************************************/
long    src;                /* 32 bit BYTE pointer */
int     block_no;           /* extended memory block index */

{
    union   REGS     regs;
    struct  SREGS    sregs;
    long    dest_addr, source_addr;
    BYTE    *gdt_addr;
     
    source_addr = convert_addr_24 (src);

    gdt_table.source.addr24[0] =  source_addr        & 0xFF;
    gdt_table.source.addr24[1] = (source_addr >> 8)  & 0xFF;
    gdt_table.source.addr24[2] = (source_addr >> 16) & 0xFF;

    dest_addr = EXTMEM_BASE + (block_no*(long)BUF_SIZE);

    gdt_table.destination.addr24[0] =  dest_addr        & 0xFF;
    gdt_table.destination.addr24[1] = (dest_addr >> 8)  & 0xFF;
    gdt_table.destination.addr24[2] = (dest_addr >> 16) & 0xFF;
 
    /* set up block move function call */

    regs.h.ah = 0x87;                       /* block move */
    regs.x.cx = BUF_SIZE / 2;               /* word count to move */

    gdt_addr  = &gdt_table.dummy[0];        /* address of the gdt table */
    sregs.es  = FP_SEG (gdt_addr); 
    regs.x.si = FP_OFF (gdt_addr);

    _disable();                             /* disable interrupts */

    int86x (0x15, &regs, &regs, &sregs);    /* INT 15 H call */

    _enable();                              /* enable interrupts */

    return (regs.h.ah);                     /* return status */
}


BOOLEAN test_extended (int block_no)
/********************************************************************/
/*                                                                  */
/*     function:    test_extended                                   */
/*                                                                  */
/*     purpose:     tests a 32KB block of extended memory           */
/*                                                                  */
/*     arguments:   block_no -- the relative block number of        */
/*                              32KB extended memory                */
/*                              (0 - 11 acceptable)                 */
/*                                                                  */
/*     returns:     TRUE  (=1)  if test is successful               */
/*                  FALSE (=0)  if test fails                       */
/*                                                                  */
/********************************************************************/
{
    BYTE    *extmem_save;
    BYTE    *workspace;
    long    source_addr, dest_addr;
    BOOLEAN final_status;
    /* begin function */

    /* 
     * allocate a 32KB local save area for the extended memory 
     */

    extmem_save = (BYTE *) malloc(BUF_SIZE);


    if (extmem_save != NULL) 
    {
        /* move the contents of the extended block into the save area */
        if (block_xfer_in (extmem_save, block_no) == 0)
        {
            /*
             * allocate a 32KB local work buffer for the extended 
             * mem test
             */
            workspace = (BYTE *) malloc(BUF_SIZE);
            if (workspace != NULL)
            {
                /* fill with test pattern 1 */
                if (fill_block (workspace, PATTERN_1) == 0) 
                {
                    /* move it to extended mem */
                    if (block_xfer_out(workspace, block_no) == 0) 
                    {
                        /* clear memory */
                        if (fill_block (workspace, ZEROS) == 0) 
                        {
                            /* bring back extended memory */
                            if (block_xfer_in (workspace, block_no) == 0) 
                            {
                                /* check for pattern */
                                if (byte_cmp(workspace, PATTERN_1, (unsigned)BUF_SIZE) == 0)
                                {
                                    /* fill with test pattern 2 */
                                    if (fill_block (workspace, PATTERN_2) == 0)
                                    {
                                        /* move it to extended memory */
                                        if (block_xfer_out(workspace, block_no) == 0)
                                        {
                                            /* clear memory */
                                            if (fill_block (workspace, ZEROS) == 0)
                                            {
                                                /* bring back extended memory */
                                                if (block_xfer_in (workspace, block_no) == 0)
                                                {
                                                    /* check for pattern */
                                                    if (byte_cmp(workspace, PATTERN_2, (unsigned)BUF_SIZE) == 0)
                                                    {
                                                        /* restore extended memory  */
                                                        if (block_xfer_out (extmem_save, block_no) == 0)
                                                        {
                                                            /* passed test */             
                                                            final_status = TRUE;
                                                        } else
                                                        {
                                                            final_status = FALSE;
                                                        }
                                                    } else /* pattern 2 compare failed */
                                                    {
                                                        final_status = FALSE;
                                                    }
                                                } else /* return of pattern 2 failed */
                                                { 
                                                    final_status = FALSE;
                                                }
                                            } else /* zero block fill failed */
                                            { 
                                                final_status = FALSE;
                                            }
                                        } else /* block xfer out of pattern 2 failed */
                                        {
                                            final_status = FALSE;
                                        }
                                    } else /* fill of pattern 2 failed */
                                    {
                                        final_status = FALSE;
                                    }
                                } else /* differences found in pattern 1 */
                                {
                                    final_status = FALSE;
                                }
                            } else /* return of pattern 1 failed */
                            {
                                final_status = FALSE;
                            }
                        } else /* zero block fill failed */
                        {
                            final_status = FALSE;
                        }
                    } else /* block xfer out of pattern 1 failed */
                    {
                        final_status = FALSE;
                    }
                } else  /* fill of test pattern 1 failed */
                {
                    final_status = FALSE;
                }
                free (workspace);
            } else      /* workspace not malloced properly */
            {
                final_status = FALSE;
            }
            /*
             * restore back out the saved extended memory
             */
            block_xfer_out (extmem_save, block_no);

        } else  /* block transfer in of ext. memory failed */
        {
            final_status = FALSE;
        }
        free (extmem_save);     /* free the malloced mem */
    } else
    {
        final_status = FALSE;
    }

    if (final_status == TRUE)
        return (TRUE);
    else
        return (FALSE);

}

