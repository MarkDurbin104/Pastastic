/****************************************************************************
* Project     : GPA
* File        : capfunc.h
* Description : conversion table from 8 char keyword to function name
* 
* $Revision:   1.2  $  $Date:   Nov 01 1995 16:06:40  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/capfunc.h_v  $
 * 
 *    Rev 1.2   Nov 01 1995 16:06:40   JGRAY
 *  
* 
****************************************************************************/

ACTMAP G_ufunc[]={
//   NAME         FUNCTION     SAVE SCREEN    ACCESS
//   8 CHARS MAX  NAME         FLAG 0/1       PRIV 0-9
    {"PRBAR"     ,prbar       },
    {"RCPTSTAT"  ,rcptstat    },
    {"STMPSTAT"  ,stmpstat    },
    {"SHOWGLB1"  ,showg1      },
    {"SHOWGLB1"  ,showg1      },
    {"STAMP1"    ,stamp1      },
    {"STAMP2"    ,stamp2      },
    {"STSEL1"    ,stsel1      },
    {"STSEL2"    ,stsel2      },
    {"STGTCT"    ,stgtct      },
    {"STOPST"    ,stopst      },
    {"STINZ"     ,stinz       },
    {"STINRZ"    ,stinrz      },
    {"STGTST"    ,stgtst      },
    {"STVOST"    ,stvost      },
    {"STREST"    ,strest      },
    {"DUMPTXN"   ,dumptxn     },
    {"CLOSETA"   ,closeta     },
    {"OPENTA"    ,openta      },
    {"REDUCE"    ,reduce      },
    {"INCREASE"  ,increase    },
    {"CHANGALR"  ,changalr    },
    {"CALENDAR"  ,calendar    },
    {"CAINFO"    ,cainfo      },
    {"BACKUP"    ,backup      },
    {"DATECVT"   ,datecvt     },
    {"CHKTPASS"  ,chktpass    },
    {"GENTPASS"  ,gentpass    },
    {"CARESTOR"  ,carestor    },
    {"CABACKUP"  ,cabackup    },
    {"BPRNLIST"  ,bprnlist    },
    {"RESETVRS"  ,resetvrs    },
    {"BUILDDEC"  ,builddec    },
    {"DECSLIST"  ,decslist    },
    {"CLOSEDEC"  ,closedec    },
    {"SETALIST"  ,setalist    },
    {"SETVRSNG"  ,setvrsng    },
    {"INIT96"    ,init96      },
    {"INIT95"    ,init95      },
    {"INIT94"    ,init94      },
    {"LUPDATE"   ,lupdate     },
    {"PUPDATE"   ,pupdate     },
    {"PUSHVRS"   ,pushvrs     },
    {"POPVRS"    ,popvrs      },
    {"DELOTOT"   ,delotot     },
    {"DELOSTK"   ,delostk     },
    {"PRINSTAT"  ,prinstat    },
    {"CHKMPASS"  ,chkmpass    },
    {"GENMPASS"  ,genmpass    },
    {"RUNCALC"   ,runcalc     },
    {"SREGION"   ,sregion     },
    {"RREGION"   ,rregion     },
    {"STARTCAL"  ,startcal    },
    {"CHMVLTXN"  ,chmvltxn    },
#ifdef PDFSCANNER
    {"PDF417"    ,pdf417      },
    {"MVLBAR"    ,mvlbar      },
    {"DCSLUBAR"  ,dcslubar    },
    {"CABAR"     ,cabar       },
    {"SENDPRN"   ,sendprn     },
    {"TAXDISKP"  ,taxdiskp    },
#endif
//----------------------------------------------------------
//  !!!! MUST BE NULL TERMINATED !!!!
    {NULL        ,NULL        }
};
// **************************************************************************
// capfunc.h <end-of-file>

