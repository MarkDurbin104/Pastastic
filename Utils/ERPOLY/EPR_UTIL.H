#include <windows.h>

#define DLL_BUILD

// Copied Block
typedef double NUMB;     /* redefine to change number type used throughout  */
#define ATON atof        /* redefine to change number type used throughout  */
//typedef long NUMB;
//#define ATON atol

typedef int BOOL;
#define FALSE 0
#define TRUE  1

typedef struct {
    NUMB X;
    NUMB Y;
} XYPOINT;

typedef struct Plist {
    NUMB X;
    NUMB Y;
    NUMB X1;
    NUMB Y1;
    struct Plist *next;
} PLIST;

#define INCREMENT 0.5
BOOL    erase_polygon   (void);

// Copied Block

BOOL    gmli_get_value  (char *paramblk);
BOOL    gmli_call_appl  (char *paramblk);
void    msg_issue       (char *err,char state);


XYPOINT *   G_poly=NULL;
int         G_numpoly=0;

#pragma warn -par
int FAR PASCAL LibMain (HINSTANCE h, WORD a, WORD b, LPSTR s)
{
  return 1;
}
#pragma warn +par

void msg_issue(char *err,char state)
{
    printf("%c %s\n",state,err);
}
BOOL gmli_get_value(char *paramblk)
{
    static int startpos=0;
    if (startpos==0) {
        strcpy(paramblk,"add");
    } else if (startpos==1) {
        sprintf(paramblk,"%d",G_numpoly);
    } else if (startpos==2) {
//        sprintf(paramblk,"%d",INCREMENT);
        sprintf(paramblk,"%f",INCREMENT);
    } else {
//        if (startpos&1) {
//            sprintf(paramblk,"%d",G_poly[(startpos-3)/2].X);
//        } else {
//            sprintf(paramblk,"%d",G_poly[(startpos-3)/2].Y);
//        }
        if (startpos&1) {
            sprintf(paramblk,"%f",G_poly[(startpos-3)/2].X);
        } else {
            sprintf(paramblk,"%f",G_poly[(startpos-3)/2].Y);
        }
    }
    startpos++;
    if ((startpos-3)/2>=G_numpoly) startpos=0;
    return(TRUE);
}

int LoadPoints(char *pfile,XYPOINT **p)
{
    FILE *fp;
    char tmp[100],*s;
    int i=0;

    if ((fp=fopen(pfile,"r"))==NULL) return 0;

    i=0; while (fgets(tmp,100,fp)!=NULL) i++;
    fseek(fp,0L,SEEK_SET);
    *p=malloc(i*sizeof(XYPOINT));

    if (*p==NULL) {
        fclose(fp);
        return 0;
    }

    i=0;
    while (fgets(tmp,100,fp)!=NULL) {
        s=strtok(tmp,", \r\n");
        if (s!=NULL) {
           (*p)[i].X=ATON(s);
           s=strtok(NULL,", \r\n");
           if (s!=NULL) {
              (*p)[i++].Y=ATON(s);
           }
        }
    }
    fclose(fp);

    return i;
}
void FAR PASCAL _export ErasePoints(void)
{
    G_numpoly=LoadPoints("POLYLIST.DAT",&G_poly);
    if (G_numpoly==0) return;
    while (erase_polygon());
    if (G_poly!=NULL) free(G_poly);
}
void FAR PASCAL _export EraseType(int type)
{
    type++;
}
void EraseRect(PLIST *p)
{
    PLIST *tmp=p;
    FILE *fp;
    
    if ((fp=fopen("XPLIST.DAT","w"))!=NULL) {
        while (p!=NULL) {
            fprintf(fp,"%d\n%d\n",(int)p->X,(int)p->X1);
            p=p->next;
        }
        fclose(fp);
    }
    p=tmp;
    if ((fp=fopen("YPLIST.DAT","w"))!=NULL) {
        while (p!=NULL) {
            fprintf(fp,"%d\n%d\n",(int)p->Y,(int)p->Y1);
            tmp=p;
            p=p->next;
            free(tmp);
        }
        fclose(fp);
    }
}
