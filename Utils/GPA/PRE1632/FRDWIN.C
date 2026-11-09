#define FRDWIN_C
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <search.h>
#include <conio.h>
#include <alloc.h>
#include <graphics.h>
#include <ctype.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "types.h"
#include "control.h"
#include "formhand.h"
#include "dst.h"
#include "config.h"
#include "keydef.h"
#include "win.h"
#include "frdscr.h"
#include "frdwin.h"
#include "frdgfx.h"

extern int shutdown(void);

int   G_insert  =(-1);
int   G_strlen  =0;
int   G_strlent =0;
int   G_inpxpos =0;
int   G_inpypos =0;
int   G_inpstrcp=0;
int   G_inpsiz  =0;
int   G_inpitem =0;
char *G_inpstr  =NULL;
char  G_origstr[160];
void scrsbf(int id,int dir,int pos)
{
    if (pos==M_STOP) return;
    if (dir==SBONCT) return;

    if (id==G_scrrsb) {
        G_formy=pos;
        sendmsg(G_scrn,M_PAINT);
        sendmsg(G_scrbsb,M_PAINT);
    } else if (id==G_scrbsb) {
        G_formx=pos;
        sendmsg(G_scrn,M_PAINT);
        sendmsg(G_scrrsb,M_PAINT);
    }
}
int nameidx(char *name)
{
    int i;
    for (i=0;i<G_numidx;i++) {
        if (!strcmp(name,G_fid[i].name)) return(i);
    }
    return(-1);
}
int afmcmp(const void *a,const void *b)
{
    return(strcmp((*(FORM **)a)->name,(*(FORM **)b)->name));
}
void sortforms(void)
{
    int i;
    char tmp[10];

    strcpy(tmp,G_form.name);
    sendmsg(G_scrn,M_DELETE);
    sendmsg(G_scrrsb,M_DELETE);
    sendmsg(G_scrbsb,M_DELETE);
    sendmsg(G_formlb,M_DELETE);
    qsort(G_forms,G_numidx,sizeof(FORM *),afmcmp);
    qsort(G_fid,G_numidx,sizeof(FINDEX),ficmp);
    G_lbi[0].item=nameidx(tmp);
    G_curform=(-1);
    lbox(&G_lbi[0]);
    G_lbi[0].item=0;
    modified();
}
void renbt(int b,int state)
{
    if (b==G_renok) {
        switch (state) {
            case M_BUTT1 :
                if (nameidx(G_form.name)!=(-1)) {
                    strcpy(G_form.name,G_forms[G_curform]->name);
                    sendmsg(10000,M_DELETE);
                    error("That Form Already Exists,\nCommand Ignored!");
                    return;
                }
                modified();
                strcpy(G_fid[G_curform].name,G_form.name);
                putform(G_curform);
                sendmsg(10000,M_DELETE);
                sortforms();
                break;
        }
    }
    if (b==G_renca) {
        switch (state) {
            case M_BUTT1 :
                strcpy(G_form.name,G_forms[G_curform]->name);
                sendmsg(10000,M_DELETE);
                break;
        }
    }
}
void renfunc(UINT tstat)
{
    switch (tstat) {
        case M_PAINT  :
        case M_STOP   :
            break;
        case M_CANCEL :
            renbt(G_renca,M_BUTT1);
            break;
        case M_UPDATE :
            renbt(G_renok,M_BUTT1);
    }
}
void dupbt(int b,int state)
{
    if (b==G_dupok) {
        switch (state) {
            case M_BUTT1 :
                if (nameidx(G_form.name)!=(-1)) {
                    strcpy(G_form.name,G_forms[G_curform]->name);
                    sendmsg(10000,M_DELETE);
                    error("That Form Already Exists,\nCommand Ignored!");
                    return;
                }
                modified();
                G_numidx++;
                G_fid=REALLOC(G_fid,G_numidx*sizeof(FINDEX));
                G_forms[G_numidx-1]=MALLOC(sizeof(FORM));
                strcpy(G_fid[G_numidx-1].name,G_form.name);
                memcpy(G_forms[G_numidx-1],&G_form,sizeof(FORM));
                G_form.items=NULL;
                sendmsg(10000,M_DELETE);
                sortforms();
                break;
        }
    }
    if (b==G_dupca) {
        switch (state) {
            case M_BUTT1 :
                strcpy(G_form.name,G_fid[G_curform].name);
                sendmsg(10000,M_DELETE);
                break;
        }
    }
}
void dupfunc(UINT tstat)
{
    switch (tstat) {
        case M_PAINT  :
        case M_STOP   :
            break;
        case M_CANCEL :
            dupbt(G_dupca,M_BUTT1);
            break;
        case M_UPDATE :
            dupbt(G_dupok,M_BUTT1);
    }
}
void newbt(int b,int state)
{
    if (b==G_newok) {
        switch (state) {
            case M_BUTT1 :
                if (nameidx(G_form.name)!=(-1)) {
                    strcpy(G_form.name,G_forms[G_curform]->name);
                    sendmsg(10000,M_DELETE);
                    error("That Form Already Exists,\nCommand Ignored!");
                    return;
                }
                modified();
                G_numidx++;
                G_fid=REALLOC(G_fid,G_numidx*sizeof(FINDEX));
                G_forms[G_numidx-1]=MALLOC(sizeof(FORM));
                strcpy(G_fid[G_numidx-1].name,G_form.name);
                strcpy(G_forms[G_numidx-1]->name,G_form.name);
                strcpy(G_form.name,G_fid[G_curform].name);
                putform(G_curform);
                strcpy(G_form.name,G_fid[G_numidx-1].name);
                G_forms[G_numidx-1]->numitem=0;
                G_forms[G_numidx-1]->items=MALLOC(1);
                sendmsg(10000,M_DELETE);
                sortforms();
                break;
        }
    }
    if (b==G_newca) {
        switch (state) {
            case M_BUTT1 :
                strcpy(G_form.name,G_fid[G_curform].name);
                sendmsg(10000,M_DELETE);
                break;
        }
    }
}
void newfunc(UINT tstat)
{
    switch (tstat) {
        case M_PAINT  :
        case M_STOP   :
            break;
        case M_CANCEL :
            newbt(G_newca,M_BUTT1);
            break;
        case M_UPDATE :
            newbt(G_newok,M_BUTT1);
    }
}
void savebt(int b,int state)
{
    if (b==G_saveok) {
        switch (state) {
            case M_BUTT1 :
                sendmsg(10000,M_DELETE);
                break;
        }
    }
    if (b==G_saveca) {
        switch (state) {
            case M_BUTT1 :
                sendmsg(10000,M_DELETE);
                break;
        }
    }
}

void getform(int i)
{
    if (G_form.items!=NULL) freeform(&G_form);
    memcpy(&G_form,G_forms[i],sizeof(FORM));
    G_form.items=MALLOC(G_form.numitem*sizeof(FORMF));
    if (G_form.items!=NULL)
        memcpy(G_form.items,G_forms[i]->items,G_form.numitem*sizeof(FORMF));
    if (G_form.bounds.tl.x==G_form.bounds.br.x) {
        G_form.bounds.tl.x=0;
        G_form.bounds.br.x=80;
    }
    if (G_form.bounds.tl.y==G_form.bounds.br.y) {
        G_form.bounds.tl.y=0;
        G_form.bounds.br.y=25;
    }
    G_scrwide=G_form.bounds.br.x-G_form.bounds.tl.x;
    G_scrhigh=G_form.bounds.br.y-G_form.bounds.tl.y;
    sprintf(G_widstr,"%d",G_scrwide);
    sprintf(G_hgtstr,"%d",G_scrhigh);
    G_curform=i;
}

void putform(int i)
{
    if (G_form.items!=NULL) {
        if (memcmp(G_form.items,G_forms[i]->items,G_form.numitem*sizeof(FORMF))) {
            modified();
            freeform(G_forms[i]);
            memcpy(G_forms[i],&G_form,sizeof(FORM));
            G_form.items=NULL;
        } else {
            freeform(&G_form);
            G_form.items=G_forms[i]->items;
            if (memcmp(&G_form,G_forms[i],sizeof(FORM))) {
                modified();
                memcpy(G_forms[i],&G_form,sizeof(FORM));
            }
            G_form.items=NULL;
        }
    }
    undoavail(0);
}
void prntform(UINT bpress)
{
    int x,y,i;
    int s=0;
    int pb;
    int hgt,wid;
    if (G_pbuf==NULL) return;
    if (bpress==OKBUTT) {
        hgt=G_scrhigh;
        wid=G_scrwide;
        for (y=0;y<hgt;y++) {
            for (x=0;x<wid;x++) {
                pb=*(G_pbuf+x+(y*132));
                if (s!=pb>>8) {
                    switch (s) {
                        case 1 : fprintf(stdprn,"%cW0",27);        break;
                        case 2 : fprintf(stdprn,"%cW0%cw0",27,27); break;
                    }
                    s=pb>>8;
                    switch (s) {
                        case 1 : fprintf(stdprn,"%cW1",27);        break;
                        case 2 : fprintf(stdprn,"%cW1%cw1",27,27); break;
                    }
                }
                if (s) x++;
                if (pb) {
                    fprintf(stdprn,"%c",pb&0xFF);
                } else {
                    for (i=x;i<wid;i++) {
                        if (*(G_pbuf+x+i+(y*132))!=0) break;
                    }
                    if (i!=wid) fprintf(stdprn," ");
                }
            }
            fprintf(stdprn,"\n");
        }
        fprintf(stdprn,"%c",12);
    }
}
void pasteavail(int s)
{
    G_mmopt[19].type=((s)?2 :0);
    G_mmopt[19].col =((s)?15:7);
}
void undoavail(int s)
{
    G_mmopt[15].type=((s)?2 :0);
    G_mmopt[15].col =((s)?15:7);
}
void cutavail(int s)
{
    G_mmopt[17].type=((s)?2 :0);
    G_mmopt[17].col =((s)?15:7);
    G_mmopt[18].type=((s)?2 :0);
    G_mmopt[18].col =((s)?15:7);
}
void modified(void)
{
    G_modified=1;
    undoavail(1);
    G_mmopt[13].type=3;
    G_mmopt[13].item=&G_msgbx[1];
    G_mmopt[5].col=15;
    G_mmopt[5].type=2;
}
void paste(void)
{
    int i;
    if (!G_cform.numitem) return;
    modified();
    deselectitems();
    for (i=0;i<G_cform.numitem;i++) {
        G_cform.items[i].ident=nextid();
        addformf(&G_form,&(G_cform.items[i]));
        selectitem(G_form.numitem-1);
    }
}
void copy(void)
{
    int i;
    modified();
    cutavail(0);
    if (!G_numsel) return;
    pasteavail(1);
    if (G_cform.items!=NULL) FREE(G_cform.items);
    G_cform.items=NULL;
    G_cform.numitem=0;
    for (i=0;i<G_numsel;i++) addformf(&G_cform,&(G_form.items[G_sel[i]]));
    deselectitems();
}
void cut(void)
{
    int i,j=G_numsel;
    modified();
    cutavail(0);
    if (!G_numsel) return;
    copy();
    for (i=0;i<j;i++) dispitem(G_sel[i],0,0,0);
    for (i=0;i<G_cform.numitem;i++) {
        for (j=0;j<G_form.numitem;j++) {
            if (G_form.items[j].ident==G_cform.items[i].ident) {
                delformf(&G_form,j);
                break;
            }
        }
    }
}
void undo(void)
{
    if (G_scrn!=(-1)) {
        freeform(&G_form);
        getform(G_curform);
        sendmsg(G_scrn ,M_PAINT);
        sendmsg(G_scrrsb,M_PAINT);
        sendmsg(G_scrbsb,M_PAINT);
        if (G_butst==1) {
            sendmsg(G_formb,M_PAINT);
            sendmsg(G_updtb,M_PAINT);
            sendmsg(G_widtb,M_PAINT);
            sendmsg(G_hgttb,M_PAINT);
            sendmsg(G_widtx,M_PAINT);
            sendmsg(G_hgttx,M_PAINT);
        }
    }
    undoavail(0);
}
void langt(int bn,int x,int y,int state)
{
    if (bn<0) return;
    settextstyle(0,0,0);
    settextjustify(CENTER_TEXT,CENTER_TEXT);
    setcolor(15);
    outtextxy(x+(state*2)+4*G_sysfw+9,y+(state*2)+10,G_name);
}

void langb(int b,int state)
{
    if (b<0) return;
    if (state==M_BUTT1) {
        G_tno++;
		if (G_tno==G_numlang) G_tno=0;
		readlang(G_langfiles[G_tno]);
	    loadtext(G_system);
        if (G_scrn!=(-1)) {
            sendmsg(G_scrn,M_PAINT);
            sendmsg(G_scrrsb,M_PAINT);
            sendmsg(G_scrbsb,M_PAINT);
        }
    }
}
void formt(int bn,int x,int y,int state)
{
    if (bn<0) return;
    settextstyle(0,0,0);
    settextjustify(CENTER_TEXT,CENTER_TEXT);
    setcolor(15);
    outtextxy(x+(state*2)+4*G_sysfw+9,y+(state*2)+10,G_formtypes[G_form.type]);
}
void formb(int b,int state)
{
    if (b<0) return;
    if (state==M_BUTT1) {
        G_form.type++;
        G_form.type%=6;
        modified();
        if (G_scrn!=(-1)) {
            sendmsg(G_scrn,M_PAINT);
            sendmsg(G_scrrsb,M_PAINT);
            sendmsg(G_scrbsb,M_PAINT);
        }
    }
}
void updat(int bn,int x,int y,int state)
{
    char tmp[10];
    if (bn<0) return;
    settextstyle(0,0,0);
    settextjustify(CENTER_TEXT,CENTER_TEXT);
    setcolor(15);
    sprintf(tmp,"AUTO %s",(G_form.attribs&FA_UPDS)==0?"OFF":"ON");
    outtextxy(x+(state*2)+4*G_sysfw+9,y+(state*2)+10,tmp);
}
void updab(int b,int state)
{
    if (b<0) return;
    if (state==M_BUTT1) {
        G_form.attribs^=FA_UPDS;
        modified();
    }
}
void strtt(int w)
{
    int item,x,y;
    if (G_insert!=(-1)) return;
    G_strlen=G_scrwide-(wnxpos(w)/G_fntw);
    G_inpstr=malloc(G_strlen+1);
    if (G_inpstr==NULL) { G_strlen=0; return; }
    if ((item=onitem(wnxpos(w)/G_fntw,wnypos(w)/G_fnth))==0) {
        G_inpstr[0]=0;
        G_strlent=0;
        G_inpxpos=wnxpos(w)/G_fntw;
        G_inpypos=wnypos(w)/G_fnth;
        G_inpstrcp=0;
        G_inpsiz=0;
        G_inpitem=(-1);
    } else {
        item%=1000;
        item--;
        if (G_form.items[item].class==FF_TABL) {
            free(G_inpstr);
            G_strlen=0;
            return;
        }
        strcpy(G_inpstr,itemtext(item));
        G_strlent=strlen(G_inpstr);
        G_inpxpos=G_form.items[item].pos.x;
        G_inpypos=G_form.items[item].pos.y;
        G_inpsiz=G_form.items[item].size-1;
        G_inpstrcp=wnxpos(w)/G_fntw-G_inpxpos;
        if (G_inpsiz) G_inpstrcp/=2;
        G_inpitem=item;
    }
    G_insert=1;
    setvp(G_scrx,G_scry,G_scrx+G_scrw*G_fntw,G_scry+G_scrh*G_fnth);
    outxy(G_scrx+G_inpxpos*G_fntw,G_scry+G_inpypos*G_fnth,0,G_inpsiz,"%s",G_inpstr);
    outxy(G_scrx+G_inpxpos*G_fntw,G_scry+G_inpypos*G_fnth,20,G_inpsiz,"%s",G_inpstr);
    setvp(0,0,G_maxx,G_maxy);
    x=G_scrx+G_inpxpos*G_fntw+((G_fntw*((G_inpsiz>0)?2:1)*G_inpstrcp)-1);
    y=G_scry+G_inpypos*G_fnth;
    tcursor(1,x,y,G_fnth*((G_inpsiz==2)?2:1));
    strcpy(G_origstr,G_inpstr);
}
void replstr(int item,char *str)
{
    char tmp[9];
    int i;
    modified();
    for (i=0;i<G_tcnt;i++) {
        if (!strcmp(str,G_text[i])) {
            strcpy(G_form.items[item].item,G_tname[i]);
            return;
        }
    }
    if (i==G_tcnt) {
        sprintf(tmp,"TEXT_%03d",G_tcnt);
        G_text[G_tcnt]=STRDUP(str);
        G_tname[G_tcnt]=STRDUP(tmp);
        if (G_tno) {
            for (i=0;i<G_tcnt;i++) {
                if (!strcmp(G_form.items[item].item,G_tname1[i])) {
                    G_tname1[G_tcnt]=STRDUP(tmp);
                    G_text1[G_tcnt]=STRDUP(G_text1[i]);
                    break;
                }
            }
            if (i==G_tcnt) {
                G_text1[G_tcnt]=STRDUP(str);
                G_tname1[G_tcnt]=STRDUP(tmp);
            }
        } else {
            for (i=0;i<G_tcnt;i++) {
                if (!strcmp(G_form.items[item].item,G_tname2[i])) {
                    G_tname2[G_tcnt]=STRDUP(tmp);
                    G_text2[G_tcnt]=STRDUP(G_text2[i]);
                    break;
                }
            }
            if (i==G_tcnt) {
                G_text2[G_tcnt]=STRDUP(str);
                G_tname2[G_tcnt]=STRDUP(tmp);
            }
        }
        G_tcnt++;
        strcpy(G_form.items[item].item,tmp);
    }
}
int addfld(char *str)
{
    FORMF   fld;
    fld.pos.x   = G_inpxpos+G_formx;
    fld.pos.y   = G_inpypos+G_formy;
    fld.attrib  = 0;
    fld.class   = FF_MAND;
    fld.size    = 1;
    fld.ident   = nextid();
    strcpy(fld.name,"NONE");
    strcpy(fld.type,"NONE");
    strcpy(fld.item,"NONE");
    strcpy(fld.func,"NONE");
    strcpy(fld.fmt,str);
    if (!addformf(&G_form,&fld)) return(-1);
    modified();
    return(G_form.numitem-1);
}
int addstr(char *str)
{
    FORMF fld;

    fld.pos.x   = G_inpxpos+G_formx;
    fld.pos.y   = G_inpypos+G_formy;
    fld.attrib  = 0;
    fld.class   = FF_TEXT;
    fld.size    = 1;
    fld.ident   = nextid();
    strcpy(fld.name,"NONE");
    strcpy(fld.type,"NONE");
    strcpy(fld.fmt ,"NONE");
    strcpy(fld.func,"NONE");
    if (!addformf(&G_form,&fld)) return(-1);
    replstr(G_form.numitem-1,str);
    modified();
    return(G_form.numitem-1);
}
int osort(const void *a,const void *b)
{
    int x =G_form.items[*(int *)a].pos.x;
    int x1=G_form.items[*(int *)b].pos.x;
    int y =G_form.items[*(int *)a].pos.y;
    int y1=G_form.items[*(int *)b].pos.y;

    if (y>y1) return(2);
    if (y<y1) return(-2);
    if (x>x1) return(1);
    if (x<x1) return(-1);

    return(0);
}
void ordersel(void)
{
    qsort(G_sel,G_numsel,sizeof(int),osort);
}
void tabulate(int btype)
{
    FILE *fp;
    int tc=0,fc=0;
    int i,j,ofld[40];
    FORMF fld,*f;
    char txt[81],*s;
    char flds[130];
    
    flds[0]=0;
    if ((G_numsel==1)&&(G_form.items[G_sel[0]].class==FF_TABL)) {
        i=G_sel[0];
        if (G_form.items[i].fmt[0]=='S') {
            G_form.items[i].fmt[0]='N';
            deselectitems();
            sendmsg(G_scrn,M_PAINT);
            selectitem(i);
            modified();
        } else {
            strcpy(flds,G_form.items[i].item);
            s=strtok(flds,"~\n");
            j=0;
            while (s!=NULL) {
                ofld[j]=findid(atoi(s));
                G_form.items[ofld[j]].class&=~FF_TBLF;
                j++;
                s=strtok(NULL,"~\n");
            }
            deselectitems();
            delformf(&G_form,i);
            sendmsg(G_scrn,M_PAINT);
            modified();
            for (i=0;i<j;i++) selectfmitem(ofld[i]);
        }
    } else {
        if ((G_numsel%2==1)||(G_numsel<2)) {
            fp=fopen("DEBUGPAD.DAT","a+");
            fprintf(fp,"%s\n",datestr(0));
            if ((G_form.attribs&FA_UPDS)==FA_UPDS) 
                fprintf(fp,"Form %-8s  Type %d  Containing %d items Access level %d Update ON\n",G_form.name,G_form.type,G_form.numitem,G_form.access);
            else
                fprintf(fp,"Form %-8s  Type %d  Containing %d items Access level %d Update OFF\n",G_form.name,G_form.type,G_form.numitem,G_form.access);
            fprintf(fp,"X  Y  A CLASS     S ID ITEM                FUNC       FORMAT\n");             
            for (i=0;i<G_form.numitem;i++) {
                f=&G_form.items[i];
                fprintf(fp,"%02d %02d %d %-9.9s %d %02d [%-17s] [%-8s] [%s]\n",
                f->pos.x,f->pos.y,f->attrib,G_fclass[f->class&0x7FFF],f->size,f->ident,f->item,f->func,f->fmt);
            }
            fprintf(fp,"\n\n");
            fclose(fp);
            return;
        }

        ordersel();

        for (i=0;i<G_numsel;i++) {
            if (G_form.items[G_sel[i]].class==FF_TEXT) tc++; else fc++;
        }
        if (tc!=fc) return;

        if (tc>20) return;

        for (i=0;i<G_numsel;i+=2) {
            if (G_form.items[G_sel[i]].class!=FF_TEXT) return;
            if (G_form.items[G_sel[i+1]].class==FF_TEXT) return;
            G_form.items[G_sel[i]].class|=FF_TBLF; 
            G_form.items[G_sel[i+1]].class|=FF_TBLF;
            sprintf(txt,"%02d~%02d~",G_form.items[G_sel[i]].ident,G_form.items[G_sel[i+1]].ident);
            strcat(flds,txt);
        }
        
        fld.pos.x   = G_form.items[G_sel[0]].pos.x;
        fld.pos.y   = G_form.items[G_sel[0]].pos.y;
        fld.attrib  = 0;
        fld.class   = FF_TABL;
        fld.size    = 1;
        fld.ident   = nextid();
        strcpy(fld.item,flds);
        strcpy(fld.func,"NONE    ");
        i=fld.ident=nextid();
        sprintf(fld.fmt,"S:%02d:%c:%02d",10,btype,tc);

        deselectitems();
        addformf(&G_form,&fld);
        sendmsg(G_scrn,M_PAINT);
        selectitem(findid(i));
        modified();
    }
}
void strchitem(int type,int dx,int dy)
{
    int i;
    char tmp[3];
    if (G_numsel!=1) return;
    if (G_form.items[G_sel[0]].class!=FF_TABL) return;
    if (type!=2) {
        dx++;
        return;
    }
    if (!dy) return;
    i=atoi(&(G_form.items[G_sel[0]].fmt[2]));
    i+=dy;
    if (i<(G_form.items[G_sel[0]].pos.y-3)) i=G_form.items[G_sel[0]].pos.y-3;
    sprintf(tmp,"%02d",i);
    dispitem(G_sel[0],20,0,0);
    G_form.items[G_sel[0]].fmt[2]=tmp[0];
    G_form.items[G_sel[0]].fmt[3]=tmp[1];
//  Modify the scr pos if off bottom or top
//  scrsbf(G_scrrsb,1,G_formy+1); // down
//  scrsbf(G_scrrsb,1,G_formy-1); // up
//  scrsbf(G_scrbsb,1,G_formx+1); // right
//  scrsbf(G_scrbsb,1,G_formx-1); // left
    modified();
    dispitem(G_sel[0],20,0,0);
}
int isfmt(char c)
{
    char *s=G_ftl;
    while (*s) if (c==*(s++)) return(1);
    return(0);
}
int fmtstr(char *s)
{
    while ((*s)&&(isfmt(*s)||isspace(*s)||ispunct(*s))) s++;
    if (!*s) return(1);
    return(0);
}
void stopt(void)
{
    if (G_insert==(-1)) return;
    if (strcmp(G_origstr,G_inpstr)) {
        if (G_inpitem!=(-1)) {
            if (strlen(G_inpstr)!=0) {
                if (G_form.items[G_inpitem].class!=FF_TEXT) {
                    strcpy(G_form.items[G_inpitem].fmt,G_inpstr);
                } else {
                    replstr(G_inpitem,G_inpstr);
                }
                dispitem(G_inpitem,-1,0,0);
            } else {
                delformf(&G_form,G_inpitem);
            }
        }
        else {
            if (strlen(G_inpstr)!=0) {
                if (fmtstr(G_inpstr)) {
                    G_inpitem=addfld(G_inpstr);
                } else {
                    G_inpitem=addstr(G_inpstr);
                }
                dispitem(G_inpitem,-1,0,0);
            }
        }
    }
    free(G_inpstr);
    G_strlent=0;
    G_strlen=0;
    G_inpstrcp=0;
    G_insert=(-1);
    G_inpitem=(-1);
    tcursor(0,0,0,0);
}
void inputt(void)
{
    int i,k;
    int x,y;
    k=getkey();
    if (G_insert==(-1)) return;
    tcursor(0,0,0,0);
    x=G_scrx+G_inpxpos*G_fntw;
    y=G_scry+G_inpypos*G_fnth;
    setvp(G_scrx,G_scry,G_scrx+G_scrw*G_fntw,G_scry+G_scrh*G_fnth);
    outxy(x,y,20,G_inpsiz,"%s",G_inpstr);
    setvp(0,0,G_maxx,G_maxy);
    switch (k) {
        case INS :
            G_insert^=1;
            break;
        case BKSP :
            if (G_inpstrcp>0) G_inpstrcp--;
            for (i=G_inpstrcp;i<G_strlent;i++) G_inpstr[i]=G_inpstr[i+1];
            break;
        case DEL :
            for (i=G_inpstrcp;i<G_strlent;i++) G_inpstr[i]=G_inpstr[i+1];
            break;
        case LEFT :
            if (G_inpstrcp>0) G_inpstrcp--;
            break;
        case RGT :
            if (G_inpstrcp<G_strlent) G_inpstrcp++;
            break;
        case ENTER :
            stopt();
            return;
        case ESC :
            free(G_inpstr);
            G_strlent=0;
            G_inpstrcp=0;
            G_insert=(-1);
            dispitem(G_inpitem,-1,0,0);
            return;
        default :
            if ((k<1)||(G_strlent>=G_strlen)) {
                break;
            }
            if (G_insert) {
                for (i=G_strlent;i>=G_inpstrcp;i--) {
                    G_inpstr[i+1]=G_inpstr[i];
                }
            }
            G_inpstr[G_inpstrcp]=k;
            G_inpstrcp++;
    }
    G_strlent=strlen(G_inpstr);
    setvp(G_scrx,G_scry,G_scrx+G_scrw*G_fntw,G_scry+G_scrh*G_fnth);
    outxy(x,y,20,G_inpsiz,"%s",G_inpstr);
    setvp(0,0,G_maxx,G_maxy);
    x+=(G_fntw*((G_inpsiz>0)?2:1)*G_inpstrcp)-1;
    tcursor(1,x,y,G_fnth*((G_inpsiz==2)?2:1));
}
char *stripspace(char *s)
{
    char *e=s+strlen(s)-1;
    while ((*s)&&(isspace(*s))) s++;
    while ((e!=s)&&(isspace(*e))) e--;
    if (e==s) *s=0; else *(e+1)=0;
    return(s);
}
void fldattr(int onoff,int item)
{
    int i;
    if (onoff) {
        if (G_form.items[item].class!=FF_TABL) {
            strcpy(G_fldnams,G_form.items[item].name);
            strcpy(G_fldeefs,G_form.items[item].type);
            strcpy(G_fldacts,G_form.items[item].func);
            strcpy(G_fldflds,G_form.items[item].item);
            G_fcls=G_form.items[item].class;
            strcpy(G_fldclss,G_fclass[G_fcls]);
        }
        G_size=G_form.items[item].size-1;
        G_colour=G_form.items[item].attrib&0x15;
        if (G_at[0]==(-1)) {
            butt(&G_bti[13]);
            butt(&G_bti[14]);
            for(i=0;i<16;i++)
                G_at[i]=button(10+(i%8)*16,43+(i/8)*16,26+(i%8)*16,59+(i/8)*16,
                        OWNDRAW,drawatt,presatt);
            for(i=0;i<9;i++) tbox(&G_tbi[10+i]);
            for(i=0;i<5;i++) butt(&G_bti[16+i]);
            butt(&G_bti[22]);
            if (onoff<2) {
                sendmsg(G_fatt1,M_HIDE);
                sendmsg(G_fatt2,M_HIDE);
                sendmsg(G_fatt3,M_HIDE);
                sendmsg(G_fatt4,M_HIDE);
                sendmsg(G_fatd1,M_HIDE);
                sendmsg(G_fatd2,M_HIDE);
                sendmsg(G_fatd3,M_HIDE);
                sendmsg(G_fatd4,M_HIDE);
                sendmsg(G_clsid,M_HIDE);
                for(i=0;i<5;i++) sendmsg(G_clbid[i],M_HIDE);
            } 
        } else {
            sendmsg(G_sizid,M_PAINT);
            sendmsg(G_colid,M_PAINT);
            for(i=0;i<16;i++) sendmsg(G_at[i],M_PAINT);
            sendmsg(G_table,M_PAINT);
            if (onoff>1) {
                sendmsg(G_fatt1,M_PAINT);
                sendmsg(G_fatt2,M_PAINT);
                sendmsg(G_fatt3,M_PAINT);
                sendmsg(G_fatt4,M_PAINT);
                sendmsg(G_fatd1,M_PAINT);
                sendmsg(G_fatd2,M_PAINT);
                sendmsg(G_fatd3,M_PAINT);
                sendmsg(G_fatd4,M_PAINT);
                sendmsg(G_clsid,M_PAINT);
                for(i=0;i<5;i++) sendmsg(G_clbid[i],M_PAINT);
            } else {
                sendmsg(G_fatt1,M_HIDE);
                sendmsg(G_fatt2,M_HIDE);
                sendmsg(G_fatt3,M_HIDE);
                sendmsg(G_fatt4,M_HIDE);
                sendmsg(G_fatd1,M_HIDE);
                sendmsg(G_fatd2,M_HIDE);
                sendmsg(G_fatd3,M_HIDE);
                sendmsg(G_fatd4,M_HIDE);
                sendmsg(G_clsid,M_HIDE);
                for(i=0;i<5;i++) sendmsg(G_clbid[i],M_HIDE);
            } 
        }
    } else {
        if (G_at[0]!=(-1)) {
            if (G_form.items[item].class!=FF_TABL) {
                strcpy(G_form.items[item].name,G_fldnams);
                strcpy(G_form.items[item].type,G_fldeefs);
//                strcpy(G_form.items[item].func,G_fldacts);
//                strcpy(G_form.items[item].item,G_fldflds);
                if ((G_fcls!=G_form.items[item].class)&&(G_numsel==1)
                    &&(G_form.items[item].class!=FF_TABL)) {
                    if (G_fcls==FF_TEXT) {
                        replstr(item,G_form.items[item].fmt);
                        strcpy(G_form.items[item].fmt,"NONE");
                    } else if (G_form.items[item].class==FF_TEXT) {
                        strcpy(G_form.items[item].fmt,textstr(&G_form.items[item]));
                        strcpy(G_form.items[item].item,"NONE");
                    }
                    G_form.items[item].class=G_fcls;
                }
            }
            G_form.items[item].size=G_size+1;
            G_form.items[item].attrib=G_colour;

            sendmsg(G_sizid,M_HIDE);
            sendmsg(G_colid,M_HIDE);
            for(i=0;i<16;i++) sendmsg(G_at[i],M_HIDE);
            sendmsg(G_table,M_HIDE);
            sendmsg(G_fatt1,M_HIDE);
            sendmsg(G_fatt2,M_HIDE);
            sendmsg(G_fatt3,M_HIDE);
            sendmsg(G_fatt4,M_HIDE);
            sendmsg(G_fatd1,M_HIDE);
            sendmsg(G_fatd2,M_HIDE);
            sendmsg(G_fatd3,M_HIDE);
            sendmsg(G_fatd4,M_HIDE);
            sendmsg(G_clsid,M_HIDE);
            for(i=0;i<5;i++) sendmsg(G_clbid[i],M_HIDE);
        }
    }
}
void scrmap(int wnum,int state)
{
    int i,s;
    static int cst=0,button=0,mx,my,lx,ly,strch=0,inputnext=0;
    if (wnum<0) return;
    switch (state) {
        case M_PAINT :
            dispform();
            G_numsel=0;
            cutavail(0);
            break;
        case M_BUTT1 :
            stopt();
            deselectitems();
            inputnext=1;
            break;
        case M_KBHIT  :
            inputt();
            break;
        case M_BUTT2 :
            if (G_insert!=(-1)) stopt();
            if (button==0) {
                button=1;
                if ((i=onitem(wnxpos(wnum)/G_fntw,wnypos(wnum)/G_fnth))==0) {
                    deselectitems();
                    lx=mx=wnxpos(wnum);
                    ly=my=wnypos(wnum);
                    setcolor(4);
                    setwritemode(1);
                    square(mx,my,lx,ly);
                    setwritemode(0);
                } else {
                    strch=i/1000;
                    i%=1000; 
                    if (!itemselected(i-1)) deselectitems();
                    lx=mx=wnxpos(wnum)/G_fntw;
                    ly=my=wnypos(wnum)/G_fnth;
                    selectitem(i-1);
                    if (G_numsel>1) strch=0;
                }
            } else {
                if (!G_numsel) {
                    setcolor(4);
                    setwritemode(1);
                    square(mx,my,lx,ly);
                    square(mx,my,lx=wnxpos(wnum),ly=wnypos(wnum));
                    setwritemode(0);
                } else {
                    lx=wnxpos(wnum)/G_fntw;
                    ly=wnypos(wnum)/G_fnth;
                    if (!strch) {
                        moveitems(lx-mx,ly-my);
                    }
                    else {
                        strchitem(strch,lx-mx,ly-my);
                    }
                    mx=lx; my=ly;
                }
            }
            break;
        case M_STOP  :
            break;
        case M_MOVIN :
        case M_MOVE :
            if ((i=onitem(wnxpos(wnum)/G_fntw,wnypos(wnum)/G_fnth))!=0) {
                s=G_form.items[(i%1000)-1].size;
                if ((i/1000)!=0) {
                    if (cst!=4+(i/1000)) {
                        cst=4+(i/1000);
                        setcursor(cst);
                        if (!G_snapoff) setsnap(wnum,6+6,12);
                    }
                } else {
                    if (cst!=s+1) {
                        cst=s+1;
                        setcursor(cst);
                        if (!G_snapoff) setsnap(wnum,6+6*(s>1),12+12*(s==3));
                    }
                }
            } else {
                if (cst!=0) {
                    setsnap((-1),0,0);
                    cst=0;
                    setcursor(cst);
                }
            }
            break;
        case M_MOVOT :
            if (cst!=0) {
                setsnap((-1),0,0);
                cst=0;
                setcursor(cst);
            }
        case M_BUTT0 :
            if (button) {
                button=0;
                if (!G_numsel) {
                    setcolor(4);
                    setwritemode(1);
                    square(mx,my,lx,ly);
                    selectitems(mx/G_fntw,my/G_fnth,lx/G_fntw,ly/G_fnth);
                    setwritemode(0);
                } 
            }
            if (inputnext) {
                inputnext=0;
                strtt(wnum);
            }
            break;
    }
}
char *getfname(int i)
{
    return(G_fid[i].name);
}
void updlb(int l,int lp,int cp)
{
    if ((l==G_formlb)||(G_formlb==(-1))) {
        if (G_curform!=cp) {
            if (cp==M_STOP) return;
            if (G_scrn!=(-1)) {
                putform(lp);
                sendmsg(G_scrn,M_DELETE);
                sendmsg(G_scrrsb,M_DELETE);
                sendmsg(G_scrbsb,M_DELETE);
                undoavail(0);
            }
            getform(cp);
            G_wni[1].ti=G_fid[cp].name;
            wind(&G_wni[1]);
            sbar(&G_sbi[0]);
            sbar(&G_sbi[1]);
            sendmsg(G_formb,M_PAINT);
            sendmsg(G_updtb,M_PAINT);
            sendmsg(G_widtb,M_PAINT);
            sendmsg(G_hgttb,M_PAINT);
            sendmsg(G_widtx,M_PAINT);
            sendmsg(G_hgttx,M_PAINT);
        }
    }
}
void backup(void)
{
    char nfile[80];
    char ofile[80];
    char *s;

/*    strcpy(nfile,G_textfile1);
    s=&nfile[strlen(nfile)-1];
    while ((s!=nfile)&&((*s)!='.')) s--;
    if (s==nfile) s=&nfile[strlen(nfile)-1];
    strcpy(s,".BT1");
    unlink(nfile);
    rename(G_textfile1,nfile); */

/*    strcpy(nfile,G_textfile2);
    s=&nfile[strlen(nfile)-1];
    while ((s!=nfile)&&(*s!='.')) s--;
    if (s==nfile) s=&nfile[strlen(nfile)-1];
    strcpy(s,".BT2");
    unlink(nfile);
    rename(G_textfile2,nfile); */

    sprintf(nfile,"%s%sN.BKF",G_config,G_system);
    unlink(nfile);
    sprintf(ofile,"%s%sN.DAT",G_config,G_system);
    unlink(nfile);
    rename(ofile,nfile);
}
void saveall(void)
{
    FILE *fp;
    int fd;
    char tmp[80];
    int i,j,k,*ti,*tn,nt;
    backup();
    putform(G_curform);
    ti=malloc(G_tcnt*sizeof(int));
    tn=malloc(G_tcnt*sizeof(int));
    memset(ti,(-1),(G_tcnt*sizeof(int)));
    for (i=0;i<G_numidx;i++) {
        for (j=0;j<G_forms[i]->numitem;j++) {
            if ((G_forms[i]->items[j].class&(~FF_TBLF))==FF_TEXT) {
                k=atoi(&G_forms[i]->items[j].item[5]);
                ti[k]=k;
            }
        }
    }
    nt=0;
    for (i=0;i<G_tcnt;i++) {
        if (ti[i]!=(-1)) {
            tn[nt]=ti[i];
            ti[i]=nt++;
        }
    }
    
    for (i=0;i<G_numidx;i++) {
        for (j=0;j<G_forms[i]->numitem;j++) {
            if ((G_forms[i]->items[j].class&(~FF_TBLF))==FF_TEXT) {
                k=atoi(&G_forms[i]->items[j].item[5]);
                sprintf(G_forms[i]->items[j].item,"TEXT_%03d",ti[k]);
                sprintf(G_tname1[k],"TEXT_%03d",ti[k]);
                sprintf(G_tname2[k],"TEXT_%03d",ti[k]);
            }
        }
    }

/*    if (G_textfile1[strlen(G_textfile1)-1]=='\\')
        sprintf(tmp,"%s%sT.DAT",G_textfile1,G_system);
    else
        strcpy(tmp,G_textfile1);

    fp=fopen(tmp,"w");
    if (fp==NULL) return;
    for (i=0;i<nt;i++) {
        fprintf(fp,"%s %s\n",G_tname1[tn[i]],G_text1[tn[i]]);
    }
    fclose(fp);
    if (G_textfile2[strlen(G_textfile2)-1]=='\\')
        sprintf(tmp,"%s%sT.DAT",G_textfile2,G_system);
    else
        strcpy(tmp,G_textfile2);

    fp=fopen(tmp,"w");
    if (fp==NULL) return;
    for (i=0;i<nt;i++) {
        fprintf(fp,"%s %s\n",G_tname2[tn[i]],G_text2[tn[i]]);
    }
    fclose(fp); */
    free(tn);
    free(ti);
    G_tcnt=nt;

    sprintf(tmp,"%s%sN.DAT",G_config,G_system);
    if ((fd=open(tmp,O_RDWR|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE))==(-1)) return;

    i=0x5A4B;                       // Forms Signature
    write(fd,&i,sizeof(int));
    i=1;                            // Forms Version Number
    write(fd,&i,sizeof(int));
    i=sizeof(FORM);                 // the size (in bytes) of a form
    write(fd,&i,sizeof(int));
    i=sizeof(FORMF);                // the size (in bytes) of a form field
    write(fd,&i,sizeof(int));

    for (i=0;i<G_numidx;i++) {
        if ((write(fd,G_forms[i],sizeof(FORM)))!=sizeof(FORM)) return;
        if ((write(fd,G_forms[i]->items,G_forms[i]->numitem*sizeof(FORMF)))!=(G_forms[i]->numitem*sizeof(FORMF))) return;
    }
    close(fd);
    G_modified=0;
    undoavail(0);
    G_mmopt[5].col=7;
    G_mmopt[5].type=0;
    G_mmopt[13].type=2;
    G_mmopt[13].item=quickexit;
    getform(G_curform);
}
void exitfunc(UINT bpress)
{
    switch (bpress) {
        case YEBUTT :
            saveall();
        case NOBUTT :
            exit(shutdown());
            break;
    }
}
void quickexit(void)
{
    shutdown();
    exit(0);
}
void viewscr(void)
{
    return;
}
void drawbut(int bn,int x,int y,int state)
{
    if (bn<0) return;
    if ((G_butid==bn)||(G_butid==(-1))) {
        putimage(x+(state*2)+3,y+(state*2)+3,G_bm[G_butst],COPY_PUT);
    }                 
}
char *getdname(int i)
{
    return(G_store[i].name);
}
char *getdfname(int i)
{
    return(G_lib[G_store[G_cds].li[i]].name);
}
char *getaname(int i)
{
    return(G_anames[i]);
}
void upddflb(int l,int lp,int cp)
{
    if (cp==M_STOP) return;
    lp-=1;
    if ((l==G_dstflb)||(G_dstflb==(-1))) {
        G_cdsf=cp;
        if (G_numsel==1) {
            if ((G_form.items[G_sel[0]].class!=FF_TEXT)&&(G_form.items[G_sel[0]].class!=FF_TABL)) {
                sprintf(G_form.items[G_sel[0]].item,"%8s.%-8s",G_store[G_cds].name,G_lib[G_store[G_cds].li[G_cdsf]].name);
                sprintf(G_fldflds,"%8s.%-8s",G_store[G_cds].name,G_lib[G_store[G_cds].li[G_cdsf]].name);
                sendmsg(G_fatd4,M_PAINT);
            }
        }
    }
}
void upddlb(int l,int lp,int cp)
{
    if (cp==M_STOP) return;

    lp-=1;

    if ((l==G_dstlb)||(G_dstlb==(-1))) {
        G_cds=cp;
        G_numdsf=G_store[G_cds].numitem;
        if (G_dstflb==(-1)) {
            lbox(&G_lbi[2]);
        } else {
            sendmsg(G_dstflb,M_PAINT);
        }
    }
}
void upalb(int l,int lp,int cp)
{
    if (cp==M_STOP) return;

    lp-=1;

    if ((l==G_acclb)||(G_acclb==(-1))) {
        if (G_numsel==1) {
            sprintf(G_fldacts,"%-8.8s",G_anames[cp]);
            sprintf(G_form.items[G_sel[0]].func,"%-8.8s",G_anames[cp]);
            sendmsg(G_fatd3,M_PAINT);
            modified();
        }
    }
}
void allbp(int b,int state)
{
    if (b<0) return;
    if (state==M_BUTT1) return;
}
void presbut(int b,int state)
{
    if (b<0) return;
    if (state==M_BUTT1) {
        if (G_butid==b) {
            if (G_modifdst) {
                G_modifdst=0;
                sendmsg(G_dstml ,M_DELETE);
                sendmsg(G_dstfml,M_DELETE);
                sendmsg(G_dstlml,M_DELETE);
                restore();
                return;
            }
            G_butst++;
            if (G_butst>=3) G_butst=0;
            switch (G_butst) {
                case 2 : // DATA STORE
                    if (G_formlb!=(-1)) {
                        sendmsg(G_formlb,M_HIDE);
                        sendmsg(G_formb ,M_HIDE);
                        sendmsg(G_updtb ,M_HIDE);
                        sendmsg(G_langb ,M_HIDE);
                        sendmsg(G_widtb ,M_HIDE);
                        sendmsg(G_hgttb ,M_HIDE);
                        sendmsg(G_widtx ,M_HIDE);
                        sendmsg(G_hgttx ,M_HIDE);
                    }
                    if (G_acclb!=(-1)) {
                        sendmsg(G_acclb,M_HIDE);
                        sendmsg(G_noact,M_HIDE);
                    }
                    if (G_dstlb==(-1)) {
                        lbox(&G_lbi[1]);
                        butt(&G_bti[4]);
                    } else {
                        sendmsg(G_dstlb ,M_PAINT);
                        sendmsg(G_dstflb,M_PAINT);
                        sendmsg(G_dstab ,M_PAINT);
                    }
                    break;
                case 1 : // FORMS
                    if (G_dstlb!=(-1)) {
                        sendmsg(G_dstlb ,M_HIDE);
                        sendmsg(G_dstflb,M_HIDE);
                        sendmsg(G_dstab ,M_HIDE);
                    }
                    if (G_acclb!=(-1)) {
                        sendmsg(G_acclb,M_HIDE);
                        sendmsg(G_noact,M_HIDE);
                    }
                    if (G_formlb==(-1)) {
                        lbox(&G_lbi[0]);
                        butt(&G_bti[1]);
                        butt(&G_bti[2]);
                        butt(&G_bti[3]);
                        tbox(&G_tbi[0]);
                        tbox(&G_tbi[1]);
                    } else {
                        sendmsg(G_formlb,M_PAINT);
                        sendmsg(G_formb ,M_PAINT);
                        sendmsg(G_updtb ,M_PAINT);
                        sendmsg(G_langb ,M_PAINT);
                        sendmsg(G_widtb ,M_PAINT);
                        sendmsg(G_hgttb ,M_PAINT);
                        sendmsg(G_widtx ,M_PAINT);
                        sendmsg(G_hgttx ,M_PAINT);
                    }
                    break;
                case 0 : // ACTIONS
                    if (G_dstlb!=(-1)) {
                        sendmsg(G_dstlb ,M_HIDE);
                        sendmsg(G_dstflb,M_HIDE);
                        sendmsg(G_dstab ,M_HIDE);
                    }
                    if (G_formlb!=(-1)) {
                        sendmsg(G_formlb,M_HIDE);
                        sendmsg(G_formb ,M_HIDE);
                        sendmsg(G_updtb ,M_HIDE);
                        sendmsg(G_langb ,M_HIDE);
                        sendmsg(G_widtb ,M_HIDE);
                        sendmsg(G_hgttb ,M_HIDE);
                        sendmsg(G_widtx ,M_HIDE);
                        sendmsg(G_hgttx ,M_HIDE);
                    }
                    if (G_acclb==(-1)) {
                        lbox(&G_lbi[3]);
                        butt(&G_bti[15]);
                    } else {
                        sendmsg(G_acclb,M_PAINT);
                        sendmsg(G_noact,M_PAINT);
                    }
                    break;
            }
            return;
        }
    }
}
void delform(UINT bpress)
{
    int i;

    if (G_curform==(-1)) return;
    switch (bpress) {
        case YEBUTT :
            modified();
            freeform(&G_form);
            freeform(G_forms[G_curform]);
            FREE(G_forms[G_curform]);
            G_numidx--;
            for (i=G_curform;i<G_numidx;i++) {
                G_forms[i]=G_forms[i+1];
                memcpy(&G_fid[i],&G_fid[i+1],sizeof(FINDEX));
            }
            G_fid=REALLOC(G_fid,G_numidx*sizeof(FINDEX));
            G_curform=(-1);
            if (G_scrn!=(-1)) {
                sendmsg(G_scrn,M_DELETE);
                sendmsg(G_scrrsb,M_DELETE);
                sendmsg(G_scrbsb,M_DELETE);
            }
            if (G_formlb!=(-1)) sendmsg(G_formlb,M_PAINT);
            break;
        case NOBUTT :
            break;
    }
}
void updwid(UINT tstat)
{
    switch (tstat) {
        case M_PAINT  :
        case M_STOP   :
        case M_CANCEL :
            break;
        case M_UPDATE :
            modified();
            G_scrwide=atoi(G_widstr);
            G_form.bounds.br.x=G_scrwide;
            G_form.bounds.tl.x=0;
            sendmsg(G_scrn,M_PAINT);
            sendmsg(G_scrrsb,M_PAINT);
            sendmsg(G_scrbsb,M_PAINT);
    }
}
void updhgt(UINT tstat)
{
    switch (tstat) {
        case M_PAINT  :
        case M_STOP   :
        case M_CANCEL :
            break;
        case M_UPDATE :
            modified();
            G_scrhigh=atoi(G_hgtstr);
            G_form.bounds.br.y=G_scrhigh;
            G_form.bounds.tl.y=0;
            sendmsg(G_scrn,M_PAINT);
            sendmsg(G_scrrsb,M_PAINT);
            sendmsg(G_scrbsb,M_PAINT);
    }
}
void drawatt(int bn,int x,int y,int state)
{
    int i;
    if (bn<0) return;
    for (i=0;i<16;i++) {
        if ((G_at[i]==bn)||(G_at[i]==(-1))) {
            setfillstyle(1,i);
            bar(x+2-state,y+2-state,x+13+(state*2),y+13+(state*2));
            return;
        }
    }
}
void drawcol(int bn,int x,int y,int state)
{
    if (bn<0) return;
    if ((G_colid==bn)||(G_colid==(-1))) {
        setfillstyle(1,G_colour);
        bar(x+2-state,y+2-state,x+125+(state*2),y+13+(state*2));
        return;
    }
}
void prescol(int b,int state)
{
    if ((G_colid==b)||(G_colid==(-1))) {
        if (state==M_BUTT1) {
            G_colour++;
            if (G_colour>=16) G_colour=0;
            modified();
        }
    }
}
void presatt(int b,int state)
{
    int i;
    for (i=0;i<16;i++) {
        if ((G_at[i]==b)||(G_at[i]==(-1))) {
            if (state==M_BUTT1) {
                G_colour=i;
                sendmsg(G_colid,M_PAINT);
                modified();
            }
            return;
        }
    }
}
void drawsiz(int bn,int x,int y,int state)
{
    if (bn<0) return;
    if ((G_sizid==bn)||(G_sizid==(-1))) {
        outxy((state*2)+x+(128-8*G_fntw*(1+(G_size>0)))/2,
              (state*2)+y+4+((G_fnth/2)*(G_size<2)),31,G_size,"ABCDEFGH");
    }
}
void pressiz(int b,int state)
{
    int i;
    if ((G_sizid==b)||(G_sizid==(-1))) {
        if (state==M_BUTT1) {
            G_size++;
            if (G_size>=3) G_size=0;
            for (i=0;i<G_numsel;i++) {
                dispitem(G_sel[i],20,0,0);
                G_form.items[G_sel[i]].size=G_size+1;
                dispitem(G_sel[i],20,0,0);
            }
            modified();
        }
    }
}
void noactb(int b,int state)
{
    if ((G_noact==b)||(G_noact==(-1))) {
        if (state==M_BUTT1) {
            if (G_numsel==1) {
                strcpy(G_fldacts,"NONE");
                strcpy(G_form.items[G_sel[0]].func,"NONE");
                sendmsg(G_fatd3,M_PAINT);
                modified();
            }
        }
    }
}
void nextcls(int b,int state)
{
    if ((G_clbid[4]==b)||(G_clbid[4]==(-1))) {
        if (state==M_BUTT1) {
            if (G_form.items[G_sel[0]].class!=FF_TABL) {
                G_fcls++;
                if (!strcmp(G_fclass[G_fcls],"TABLE")) G_fcls++;
                if (G_fclass[G_fcls]==NULL) G_fcls=0;
                G_form.items[G_sel[0]].class=G_fcls;
                strcpy(G_fldclss,G_fclass[G_fcls]);
                sendmsg(G_clsid,M_PAINT);
                modified();
            }
        }
    }
}
void moddlb(int l,int lp,int cp)
{
    if (cp==M_STOP) {
        G_dstml=(-1);
        return;
    }
    lp-=1;
    if ((l==G_dstml)||(G_dstml==(-1))) {
        G_cds=cp;
        G_numdsf=G_store[G_cds].numitem;
        if (G_dstfml!=(-1)) {
            sendmsg(G_dstfml,M_PAINT);
        }
    }
}
void moddflb(int l,int lp,int cp)
{
    if (cp==M_STOP) {
        G_dstfml=(-1);
        return;
    }
    lp-=1;
    if ((l==G_dstfml)||(G_dstfml==(-1))) {
        sprintf(G_dststr,"%c %c %-8.8s %c %03d",
            ((G_store[G_cds].key&(0x80000000L>>cp))?'':' '),
            ((G_store[G_cds].skey&(0x80000000L>>cp))?'':' '),
            G_lib[G_store[G_cds].li[cp]].name,
            G_lib[G_store[G_cds].li[cp]].type,
            G_lib[G_store[G_cds].li[cp]].len);
        G_dststr[1]=G_dststr[3]=G_dststr[12]=G_dststr[14]=0;
        sendmsg(G_dstt[5],M_PAINT);
        sendmsg(G_dstt[6],M_PAINT);
        sendmsg(G_dstt[7],M_PAINT);
        sendmsg(G_dstt[8],M_PAINT);
        sendmsg(G_dstt[9],M_PAINT);
    }
}
void moddlib(int l,int lp,int cp)
{
    if (cp==M_STOP) {
        G_dstlml=(-1);
        return;
    }
    lp-=1;
    if (l==G_dstlml) {
        if (G_dstfml!=(-1)) {
            G_store[G_cds].li[G_store[G_cds].numitem]=cp;
            G_store[G_cds].numitem++;
            G_numdsf=G_store[G_cds].numitem;
            sendmsg(G_dstfml,M_PAINT);
        }
    }
}
char *getdfdet(int i)
{
    static char tmp[19];
    sprintf(tmp,"%c %c %-8.8s %c %03d",
        ((G_store[G_cds].key&(0x80000000L>>i))?'':' '),
        ((G_store[G_cds].skey&(0x80000000L>>i))?'':' '),
        G_lib[G_store[G_cds].li[i]].name,
        G_lib[G_store[G_cds].li[i]].type,
        G_lib[G_store[G_cds].li[i]].len);
    return(tmp);
}
char *getldet(int i)
{
    static char tmp[15];
    sprintf(tmp,"%-8.8s %c %03d",G_lib[i].name,G_lib[i].type,G_lib[i].len);
    return(tmp);
}
void modidst(int b,int state)
{
    if ((G_clbid[3]==b)||(G_clbid[3]==(-1))) {
        if (state==M_BUTT1) {
            dbox((DBOXITEM *)(&G_diadst));
        }
    }
}
void dstbt(int b,int state)
{
    if ((G_dstok==b)||(G_dstok==(-1))) {
        if (state==M_BUTT1) {
            sendmsg(10000,M_DELETE);
        }
    }
}
void maketab(int b,int state)
{
    if (G_table==b) {
        if (state==M_BUTT1) {
            tabulate(1);
        }
    }
}


