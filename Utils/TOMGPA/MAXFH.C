/* PRODUCT  :  C/C++         BORLAND: TI2577.TXT      NUMBER  :  2577
   VERSION  :  All
        OS  :  Ext DOS
      DATE  :  August 4, 1994

     TITLE  :  Increase maximum file handles availible in DPMI16

DISCLAIMER: You have the right to use this technical information
subject to the terms of the No-Nonsense License Statement that
you received with the Borland product to which this information
pertains.

* $Revision:   1.0  $  $Date:   Oct 30 1995 15:27:16  $  $Author:   TBARTON  $
*
* $Log:   I:/pvcs/gpa/c/maxfh.c_v  $
 * 
 *    Rev 1.0   Oct 30 1995 15:27:16   TBARTON
 *  
*
*/

/*-----------------------------------------------------------------------*/
/*                                                                       */
/*  SETFIL16.C - Example of how to expand the maximum number of files    */
/*               availible in a DPMI16 application.  This is the only    */
/*               file needed.  Other fixes required the RTL source code  */
/*               "FILE.C" and "FILES2.C".  This program incorperates     */
/*               everything into this one file.  Simply link it into your*/
/*               project and it will get called from the startup code.   */
/*                                                                       */
/*-----------------------------------------------------------------------*/
 
#include <process.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#include <dos.h>
 
#include <_nfile.h>
#undef _NFILE_                  // undefine the old maximum
#define _NFILE_ 100             // set your new maximum here
 
int _SetFileMax (void);
#pragma startup _SetFileMax 0   // This causes the function to be called
                                // from the startup code.
 
unsigned _nfile = _NFILE_;
 
#define _F_STDIN    (_F_READ | _F_TERM | _F_LBUF)
#define _F_STDOUT   (_F_WRIT | _F_TERM | _F_LBUF)
#define _F_STDERR   (_F_WRIT | _F_TERM)
#define _F_STDAUX   (_F_RDWR | _F_TERM | _F_BIN)
#define _F_STDPRN   (_F_WRIT | _F_TERM | _F_BIN)
 
FILE    _streams [_NFILE_] =
{
    { 0, _F_STDIN,   0, 0, 0, NULL, NULL, 0, (short) stdin },
    { 0, _F_STDOUT,  1, 0, 0, NULL, NULL, 0, (short) stdout },
    { 0, _F_STDERR,  2, 0, 0, NULL, NULL, 0, (short) stderr },
    { 0, _F_STDAUX,  3, 0, 0, NULL, NULL, 0, (short) stdaux },
    { 0, _F_STDPRN,  4, 0, 0, NULL, NULL, 0, (short) stdprn }
};
 
unsigned int    _openfd[_NFILE_] =
{
    O_RDONLY | O_DEVICE | O_TEXT,
    O_WRONLY | O_DEVICE | O_TEXT,
    O_WRONLY | O_DEVICE | O_TEXT,
    O_RDWR   | O_DEVICE | O_BINARY,
    O_WRONLY | O_DEVICE | O_BINARY
};
 
int _SetFileMax (void)
//
// This function will set a new maximum file handle limit.
// If it fails it returns 0 else 1.
//
{
  if ((_nfile > 20) && (_osmajor >= 3))
  {
    if ((_osmajor == 3) && (_osminor < 0x1E)) // Check for >= DOS 3.3
      return 0;
 
    _AX = 0x5801;
    _BX = 2;
    geninterrupt (0x21);               // Set last fit allocation
    if ((_FLAGS & 1) == 1)
      return 0;
 
    _AH = 0x67;
    _BX = _nfile;
    geninterrupt (0x21);               // Expand handle table
    if ((_FLAGS & 1) == 1)
      return 0;
 
    _AX = 0x5801;
    _BX = 0;
    geninterrupt (0x21);               // Set first fit allocation
    if ((_FLAGS & 1) == 1)
      return 0;
    }
    return 1;
}

//
//  define SUPPLY_MAIN if you want this file to be a stand-alone demo.
//
//#ifdef SUPPLY_MAIN
//FILE *array[_NFILE_];
//#pragma argsused
//int main (int argc, char *argv[])
//{
//  int j;
//  char str[20];
// 
//  for (j=0;j<_NFILE_;j++)
//  {
//    sprintf (str, "__tst.%03d", j);
//    if ((array[j] = fopen (str, "wt")) == NULL)
//    {
//      perror (str);
//      return 1;
//    }
//    printf ("%s\n", str);
//  }
//  fcloseall ();
//  return 0;
//}
//#endif  // SUPPLY_MAIN
//
//**********************************************************************
// End of file - MAXFH.C
