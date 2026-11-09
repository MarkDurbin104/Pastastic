/****************************************************************************
* Project     : GPA
* File        : gpafunc.h
* Description : Table of GPA keywords vs functions
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:54  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/gpafunc.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:54   JGRAY
 *  
* 
****************************************************************************/
ACTMAP G_ufunc[]={
//   NAME         FUNCTION     SAVE SCREEN    ACCESS
//   8 CHARS MAX  NAME         FLAG 0/1       PRIV 0-9
    {"MYVOID"    ,myvoid      },
    {"BEGINTXN"  ,actbgntx    },
    {"COMMIT"    ,actcomit    },
    {"ROLLBACK"  ,actrlbck    },
    {"LOGSUMME"  ,logsumme    },
    {"WSLOGNUM"  ,wsnummer    },
    {"GELDFRMT"  ,geldfrmt    },
    {"GEWIFRMT"  ,gewfrmt     },
    {"MYSCALE"   ,myscale     },
//    {"ENDCUST"   ,endcust     },

//----------------------------------------------------------
//  !!!! MUST BE NULL TERMINATED !!!!
    {NULL        ,NULL        }
};

// **************************************************************************
// gpafunc.h <end-of-file>

