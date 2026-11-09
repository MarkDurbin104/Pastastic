#include <conio.h>       // For getch()
#include <malloc.h>      // For farcoreleft()

//==========================================================================
//F main
//S main used for unit testing of FILEIO.C
//D Load PLUFile (argv[1]) Load DeptFile (argv[2])
//D list the contents of both on stdout
//D Save the PLU Linked list into "PLU.DAT" and free it's memory
//D Save the Dept. Linked list into "DEPT.DAT"  and free it's memory
//P should be 3
//P [0]=command [1]=PLUFile [2]=DeptFile
//R ErrLevel = 0,OK 1,Invalid args 2,PLU file error 3,DEPT file error
int main(int argc,char *argv[])
{
    PLU *plulist=NULL;
    PLU *plu;
    DEPARTMENT *deptlist=NULL;
    DEPARTMENT *dept;
    CONFIG *cfglist=NULL;
    CONFIG *cfg;
    REMACSPLU *rplulist=NULL;
    INT pindex;
    LONG startmem;

    if (argc<3) {
        printf("Usage:\n\t%s PLUFile DEPTFile\n",argv[0]);
        return 1;
    }
    startmem=farcoreleft();
    fprintf(stderr,"Memory %ld\n",startmem);
    if (!LoadPLU(argv[1],&plulist)) {
        printf("Error in PLU File !\n");
        if (plulist==NULL) return 2;
        printf("Some Definitions May Be incorect !\n");
        getch();
    }
    if (!LoadDepartment(argv[2],&deptlist)) {
        printf("Error in Department File !\n");
        if (deptlist==NULL) return 3;
        printf("Some Definitions May Be incorect !\n");
        getch();
    }
    if (plulist!=NULL) printf("PLU file : %s :-\n",argv[1]);
    plu=plulist;
    while (plu!=NULL) {
        printf("PLU %06ld DESC1 %s DESC2 %s STAT %s ASSC %d ACT %d\n",
            plu->plu_code,
            plu->desc1,
            plu->desc2,
            plu->status.as_string,
            plu->assoc_dept,
            plu->action);
        for (pindex=0;pindex<6;pindex++) 
            printf("%3ld.%02ld ",plu->price[pindex]/100L,plu->price[pindex]%100L);
        printf("\n");
        plu=plu->next;
    }

    if (deptlist!=NULL) printf("Department file : %s :-\n",argv[2]);
    dept=deptlist;
    while (dept!=NULL) {
        printf("DEPT %02d STAT %s ACT. %s DESC %s Code1 %ld Code2 %ld Code3 %ld Action %d\n",
            dept->dept_number,
            dept->status.as_string,
            dept->active,
            dept->desc,
            dept->osp_code[0],
            dept->osp_code[1],
            dept->osp_code[2],
            dept->action);
        dept=dept->next;
    }
    if (!LoadConfig("\\KEYMAINT\\KEYMAINT.CFG",&cfglist)) {
        printf("Error in CONFIG File !\n");
        if (cfglist==NULL) return 2;
        printf("Some Definitions May Be incorect !\n");
        getch();
    }
    if (cfglist!=NULL) printf("Configuration file : \\KEYMAINT\\KEYMAINT.CFG :-\n");
    cfg=cfglist;
    while (cfg!=NULL) {
        printf("Control Ctr %03d DESC %s Term ID %02d DESC %s Type %s\n",
            cfg->ctrl_centre,
            cfg->cc_desc    ,
            cfg->term_id    ,
            cfg->term_desc  ,
            cfg->term_type  );
        cfg=cfg->next;
    }
    LoadLocalPLU("LREMACS.PLU",&rplulist);
    fprintf(stderr,"Memory %ld   USED - %ld\n",farcoreleft(),startmem-farcoreleft());
    LoadReMACSPLU("REMACS.PLU",&rplulist);
    fprintf(stderr,"Memory %ld   USED - %ld\n",farcoreleft(),startmem-farcoreleft());
    SaveDepartment("DEPT.DAT",&deptlist,TRUE);
    SavePLU("PLU.DAT",&plulist,TRUE);
    SaveConfig("KEYMAINT.CFG",&cfglist,TRUE);
    SaveLocalPLU("LREMACS.PLU",&rplulist,TRUE);
    fprintf(stderr,"Memory %ld   USED - %ld\n",farcoreleft(),startmem-farcoreleft());
    return 0;
}
//__________________________________________________________________________


