/****************************************************************************
* Project     : GPA
* File        : realprot.h
* Description : set of definitions for kbd, ticks, and zips
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:07:12  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/realprot.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:07:12   JGRAY
 *  
* 
****************************************************************************/
#define KBDSWITCHOFF    0x3160
#define KBDSWITCHON     0x3161
#define KBDSETBUFFER    0x3162
#define KBDSETSTART     0x3163
#define KBDSETEND       0x3164
#define KBDSETLOOP      0x3165
#define KBDSETSCAN      0x3166
#define KBDDISABLE      0x3167
#define TICKCOUNTER     0x3168
#define TICKEXITCTR     0x3169
#define KBDSETAPIBUF    0x3170
#define PUSHKEYPRESS    0x3171
#define SETDEBUGFLAG    0x3172
#define UPDATEFLAGS     0x3173
#define BACKUPDBM       0x3174
#define RESTOREDBM      0x3175
#define FILEZIP         0x3176
#define FILEUNZIP       0x3177
#define INACTIVETIME    0x3178
#define SETCRITCALLBACK 0x3179

#define PRNTSCRKEY      4000
#define KBDPUSHEND      5000

// **************************************************************************
// realprot.h <end-of-file>

