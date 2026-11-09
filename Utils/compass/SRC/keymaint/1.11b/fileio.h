//===============|========================================================|
//               |                                                        |
// Module        | FILEIO.H                                               |
//               |                                                        |
// Project       | Compass In-Unit Trading Project                        |
//               |                                                        |
// Description   | File I/O definitions for use by COMPKEY.C              |
//               |                                                        |
// Functions     | None                                                   |
//               |                                                        |
//===============|========================================================|
//               |                                                        |
// Copyright (c) | Unisys Limited                                         |
//               | 22 Southwark Bridge Road                               |
//               | London SE1 9HB                                         |
//               |                                                        |
// Author        | Mark Durbin                                            |
//               | P.S.L.                                                 |
//               | 160 Charles street, Greenhithe, Kent. DA9 9AJ          |
//               |                                                        |
//===============|========================================================|
// Date          | Modifications                                 | By     |
//===============|===============================================|========|
// 10/05/96      | Initial Version                               | MJD    |
//===============|========================================================|
//               |                                               |        |
//===============|========================================================|


#ifndef __FILEIO_H // entry sentry
#define __FILEIO_H

CHAR *      CleanBuf          (CHAR *str);
BOOL        ismenu            (DEPARTMENT *dept);
PLU *       FindPLU           (PLU *plulist,LONG plu_code);
REMACSPLU * FindRePLU         (REMACSPLU *plulist,LONG plu_code);
DEPARTMENT *FindDept          (DEPARTMENT *deptlist,INT dept);
BOOL        LoadDepartment    (CHAR *name,DEPARTMENT **deptlist,INT numbkey);
INT         LoadPLU           (CHAR *name,PLU **plulist,REMACSPLU *rplulist);
BOOL        LoadLocalPLU      (CHAR *name,REMACSPLU **plulist);
BOOL        LoadReMACSPLU     (CHAR *name,REMACSPLU **plulist);
BOOL        LoadConfig        (CHAR *name,CONFIG **cfglist);
ULONG *     LoadLayout        (CHAR *name,KEYMETRICS *keys);
void        LoadColours       (CHAR *name,INT *cbuf);
BOOL        SaveDepartment    (CHAR *name,DEPARTMENT **deptlist,INT numbkey,BOOL freelist);
BOOL        SavePLU           (CHAR *name,PLU **plulist,DEPARTMENT *deptlist,BOOL freelist);
BOOL        SaveConfig        (CHAR *name,CONFIG **cfglist,BOOL freelist);
BOOL        SaveLocalPLU      (CHAR *name,REMACSPLU **plulist,BOOL freelist);
void        FreeDeptList      (DEPARTMENT **deptlist);
void        FreePLUList       (PLU        **plulist );
void        FreeCFGList       (CONFIG     **cfglist );
void        FreeReMACSPLUList (REMACSPLU  **plulist );
INT         LoadPrinterParams (void);
void        AuditLog          (CHAR *format,...);

#endif // __FILEIO_H
