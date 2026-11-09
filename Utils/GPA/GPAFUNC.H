ACTMAP G_ufunc[]={
//   NAME         FUNCTION     SAVE SCREEN    ACCESS
//   8 CHARS MAX  NAME         FLAG 0/1       PRIV 0-9
    {"MYVOID"    ,myvoid      },
    {"BEGINTXN"  ,actbgntx    },
    {"COMMIT"    ,actcomit    },
    {"ROLLBACK"  ,actrlbck    },
    {"RBEGINTX"  ,rcpbgntx    },
    {"RCOMMIT"   ,rcpcomit    },
    {"RROLLBCK"  ,rcprlbck    },
    {"LOGSUMME"  ,logsumme    },
    {"WSLOGNUM"  ,wsnummer    },
    {"GELDFRMT"  ,geldfrmt    },
    {"GEWIFRMT"  ,gewfrmt     },
    {"MENGFRMT"  ,mengfrmt    },
    {"MYSCALE"   ,myscale     },
#ifdef WIEN
    {"GETONAME"  ,getoname    },
    {"GETOPLZ"   ,getoplz     },
    {"GETOSTRT"  ,getostreet  },
    {"SETONAME"  ,setoname    },
    {"GETOFFIC"  ,getodets    },
    {"SETOFFIC"  ,setodets    },
#endif//WIEN
    {"CLEARLOG"  ,clearlog    },
    {"LOGCOUNT"  ,logcount      },
    {"BREAKPNT"  ,breakpnt      },
    {"GETGEBAR"  ,getgebar      },
    {"STATLINE"  ,statline      },
    {"GETVG"     ,GetVerrgr     },
    {"CPYMEMST"  ,Store2Memstor  },
    {"SHOWLOG"  ,ShowLog        },
    {"TOVENUS"  ,ToVenus        },
    {"BRFLOSDR"  ,BrieflosDruck },
    {"GDCSORT"   ,GDCSort       },
    {"AWCSORT"   ,AWCSort       },
    {"CWAITINP"  ,CWaitInp      },
    {"ADMEXIT"   ,AdmExit       },
//    {"ENDCUST"   ,endcust     },

//----------------------------------------------------------
//  !!!! MUST BE NULL TERMINATED !!!!
    {NULL        ,NULL        }
};

