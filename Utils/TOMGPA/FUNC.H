/****************************************************************************
* Project     : GPA
* File        : func.h
* Description : Keyword to function map
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:52  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/func.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:52   JGRAY
 *  
* 
****************************************************************************/
#ifdef FUNCTION_H
ACTMAP G_actmap[]={
    {"CURSUP"   ,upfunc      },
    {"CURSDOWN" ,downfunc    },
    {"EXITFORM" ,exitform    },
    {"ENDFORM"  ,endform     },
    {"EXIT2TOP" ,exit2top    },
    {"EXIT2MRK" ,exit2mrk    },
    {"MARKFORM" ,markform    },
    {"PUSHBKEY" ,pushbkey    },
    {"BEEP"     ,beep        },
    {"PRODUCT"  ,prodlist    },
    {"USERDET"  ,userdetails },
    {"LOGTRANS" ,logtransact },
    {"ADDTOLOG" ,putcurinlog },
    {"GETUSER"  ,getuser     },
    {"DOMOP"    ,domop       },
    {"ADDMOP"   ,addmop      },
    {"ADDLAST"  ,addlast2    },
    {"SUBLAST"  ,sublast2    },
    {"GETLNAME" ,getplname   },
    {"GETPNAME" ,getpname    },
    {"GETUNAME" ,getuname    },
    {"TABSTUID" ,tabstuid    },
    {"TABSSUID" ,tabssuid    },
    {"CCHANGE"  ,cchange     },
    {"SETDATE"  ,setsdate    },
    {"SETTIME"  ,setstime    },
    {"LOGOFF"   ,logoff      },
    {"GETSCALE" ,getscale    },
    {"SCALZERO" ,scalez      },
    {"SCALNZRO" ,scalenz     },
    {"SCALSATB" ,scalestab   },
    {"SETONAME" ,setoname    },
    {"GETONAME" ,getoname    },
    {"SETOFFIC" ,setodets    },
    {"GETOFFIC" ,getodets    },
    {"SETCOUNT" ,setctdets   },
    {"GETCOUNT" ,getctdets   },
    {"GETNEWDI" ,getnewdiskno},
    {"NEWCDISK" ,newclerkdisk},
    {"CONSOLID" ,consolidd   },
    {"SETNEWDB" ,setnewdbm   },
    {"SETNEWSY" ,setnewsys   },
    {"SETNEWOF" ,setnewoff   },
    {"SETNEWCF" ,setnewcfg   },
    {"BLANKRST" ,blankrest   },
    {"CHECKPAS" ,checkpass   },
    {"GETUDETS" ,getuserdet  },
    {"CHECKPEQ" ,checkpequal },
    {"SETPASS"  ,setpassword },
    {"PICK_KEY" ,reversal    },
    {"ZEROTRAN" ,zerotran    },
    {"OBACKUP"  ,obackup     },
    {"YESNO"    ,yesno       },
    {"GETL1"    ,getl1       },
    {"GETL2"    ,getl2       },
    {"GETL3"    ,getl3       },
    {"DISPENSE" ,dispense    },
    {"PAYOUT"   ,payoutcn    },
    {"REDUCECN" ,reducecn    },
    {"GETCOINS" ,getcoins    },
    {"OPERDOOR" ,operdoor    },
    {"COINSTAT" ,coinstat    },
    {"ENDCUST"  ,endcust     },
    {NULL       ,NULL        }
};
#endif
// **************************************************************************
// func.h <end-of-file>

