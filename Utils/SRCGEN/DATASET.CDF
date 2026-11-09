#include "stdtypes.cdf"
#include "copymjd.cdf"
#include "dscomnt.cdf"
#name DATASET
#desc "Structure definitions and access functions" "for a data schema mantenance program"
#defvar G_testvar {CHARœ* NULL}
#defvar G_testvar123 {INT 0}
#deftype COLUMN {SPTR name,SPTR version,SPTR inbase,SPTR type,SPTR datatype,SPTR size,SPTR descript,SPTR comment}
#deftype COLUMNPTR {COLUMNœ* COLUMNPTR}
#deftype INDEX {SPTR name,SPTR version,SPTR inbase,UINT numcol,SPTR colname,SPTR descript,SPTR comment}
#deftype INDEXPTR {INDEXœ* INDEXPTR}
#deftype DATASET {SPTR name,SPTR version,SPTR inbase,BOOL active,UINT numcol,COLUMNPTR column,INDEXPTR primidx,UINT numidx,INDEXPTR index,SPTR descript,SPTR comment}
#deflen  DATASET {index numidx}
#deflen  DATASET {column numcol}
#setinit DATASET {primidx NULL}
#deftype DATASETPTR {DATASETœ* DATASETPTR}
#deftype DATABASE {SPTR name,SPTR password,SPTR currver,SPTR currbase,UINT numdataset,DATASETPTR dataset,SPTR descript}
#deflen  DATABASE {dataset numdataset}
#genfunc COLUMN   {slpfaidn eeeeeeee}
#genfunc INDEX    {slpfaidn eeeeeeee}
#genfunc DATASET  {slpfaidn eeeeeeee}
#genfunc DATABASE {slpfaidn eeeeeeee}
#deffind COLUMN  name !strcmp(#,#)
#deffind INDEX   name !strcmp(#,#)
#deffind DATASET name !strcmp(#,#)
#imodule CE "testdst.c"
