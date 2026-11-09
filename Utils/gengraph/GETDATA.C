#ifndef TESTING
#include <windows.h>
#endif

#include <stdio.h>  // fprintf etc.
#include <stdarg.h> // variable args used in outxy
#include <stdlib.h> // atol etc.
#include <string.h> // strcpy strcmp etc.
#include <malloc.h> // malloc free etc.
#include <time.h>   // just for time stamps !

#include "types.h"      // general type definitions
#include "deballoc.h"   // memory debugging routines
#include "datadef.h"    // specific type definitions

// #define DRAW_TEXT    // set to enable text draw via lines NOT windows font
#ifdef DRAW_TEXT        
#include "tintext.h"    // Character polygons
#endif

BOOL G_firstln=TRUE;    // used for output to stop CR on last line
FILE *G_fp;             // used by dummy graphics routines circle,line etc..
INT G_oy=0;             // For testing only
#include "graph.h"      // dummy graphics routines circle,line etc..
INT G_toffset[100];     // tube offsets for each level of depth
INT G_maxx=10;          // maximum x coordinate drawn
INT G_maxy=10;          // maximum y coordinate drawn
CHAR *G_filename=NULL;  // Pointer to filename between DLL calls

#define LEFT  1         // Left  side
#define RIGHT 2         // Right side

#define BOXWID   (7*10)      // 10 characters of 7 width
#define TEXTHGT  14          // 14 points high
#define TUBEHGT  TEXTHGT     // space between tubes
#define TUBEDHGT (TUBEHGT*3) // Tube description box height
#define TUBEDWID (7*20)      // Tube description box width
#define TUBEDOFS 14          // Tube description box top offset
#define BOXSPACE (TUBEDWID+(TUBEDOFS*2)+TUBEDHGT+3)
#define YUNITMID 10          // mid x poiny in a Yunit symbol

//---------------------------------------------------------------------------
//F GasSeal
//S Draw a Gas Seal
//D Draw a Tempary Gas Seal facing left or right
//P x coord. of edge of rounded surface
//P y coord. of centre
//P TRUE if facing left i.e ||)- else -(||
void GasSeal(int x,int y,BOOL Left)
{
    if (Left) {
        line(x-4,y-4,x-4,y+4); // left flat
        line(x-6,y-4,x-6,y+4); // leftmost flat
        arc(x-4,y,270,90,4);   // arc
    } else {
        line(x+4,y-4,x+4,y+4); // right flat
        line(x+6,y-4,x+6,y+4); // rightmost flat
        arc(x+4,y,90,270,4);   // arc
    }
}
//---------------------------------------------------------------------------
//F outxy
//S formatted output at a given x/y coord.
//D formatted output at a given x/y coord.
//P X coord.
//P Y coord.
//P format aka printf
//P variable params
//R 
void outxy(INT x,INT y,CHAR *fmt,...)
{
#ifdef DRAW_TEXT
	INT xp,yp,i,mx;
	UCHAR *t,,*s;
#endif
    UCHAR tmp[LINELEN];
	va_list ap;                   
	va_start(ap,fmt);
	vsprintf((CHAR *)tmp,fmt,ap); // convert format info into string
	va_end(ap);

#ifndef DRAW_TEXT
    outtextxy(x,y,(CHAR *)tmp);   // use dummy routing graph to output
#else
    x-=strlen((CHAR *)tmp)*3;     // output using lines
	s=tmp;
	y+=9;
	while (*s) {
		mx=0;
		if ((*s>31)&&(*s<=127)) { // legacy code !! if you need an explanation
			i=G_charofs[*s-32];   // call me MJD.
			t=G_chardefs+i;
			i=((G_charofs[*s-31]-i)/2)-1;
			while (i--) {
				xp=(*t&0x3F)-(64*((*(t++)&0x40)!=0));
				yp=(*t&0x3F)-(64*((*(t  )&0x40)!=0));
				if (!(*(t)&0x80)) {
					moveto(x+xp,y-yp);
				} else {
					lineto(x+xp,y-yp);
				}
			  	mx=max(mx,x+xp);
				t++;
			}
		}
		s++;
		x=mx;
	}
#endif
}
//---------------------------------------------------------------------------
//F tube
//S Draw a BFT tube
//D Draw a BFT tube with either joint,gas seal or open end, printing the
//D numbering information above
//P X Coord. of left end
//P Y Coord.
//P tube status (bitmap) 8 - joint right, 4 - left, 2 - Occupied, 1 - Blocked.
//P start tube number
//P end tube number  (for grouped tubes)
//P length in 'depth' units
//R the mid point along the line
INT tube(int x,int y,INT stat,INT ts,INT te,INT len)
{
    INT x2;
    INT mx;
    if (len>1) {                            // calc. the other end
        x2=x+(BOXSPACE*len)+BOXWID*(len-1);
    } else {
        x2=x+BOXSPACE;
    }
    mx=x+((x2-x)/2);                        // calc. the mid point

    if (ts==te) {                           // don't group
        if (ts==1) {                        // first line - print 'TUBE'
            outxy(mx,y-TUBEHGT,"TUBE  %d",ts);
        } else {
            outxy(mx,y-TUBEHGT,"      %d",ts);
        }
    } else {                                // group
        if (ts==1) {                        // first line - print 'TUBE'
            outxy(mx,y-TUBEHGT,"TUBES %d-%d",ts,te);
        } else {
            outxy(mx,y-TUBEHGT,"      %d-%d",ts,te);
        }
    }
    if ((stat&4)==4) {  // joint on left end
        x-=BOXWID/2;
        if ((stat&8)==8) { // joint on right end
            x2+=BOXWID/2;
            circle(x ,y,2);
            circle(x2,y,3);
        } else {           // no joint on right end
            x2+=5;
            if ((stat&2)!=2) { // Seal on right end
                GasSeal(x2,y,FALSE);
            }
            circle(x,y,2);
        }
    } else {
        if ((stat&8)==8) { // joint on right end
            x2+=BOXWID/2;
            x-=5;
            if ((stat&2)!=2) { // Seal on left end
                GasSeal(x,y,TRUE);
            }
            circle(x2,y,3);
        } else {
            x-=5;
            x2+=5;
            if ((stat&2)!=2) {  // Seal on both ends
                GasSeal(x,y,TRUE);
                GasSeal(x2,y,FALSE);
            }
        }
    }
    line(x,y,x2,y); // draw the line
    return mx;      // return the mid point
}
//---------------------------------------------------------------------------
//F AddNAP
//S Add a NAP structure to G_nap
//D Add a NAP structure to the G_nap linked list (insert at beginning)
//P data string delimited with '$'
void AddNAP(CHAR *d)
{
    NAP *n;
    CHAR *t;
    if ((n=MALLOC(sizeof(NAP)))==NULL) return;
    GETTOK(t,d   ); n->fn=atol(t);
    GETTOK(t,NULL); n->fa=*t;
    GETTOK(t,NULL); strcpy(n->ctg,t);
    GETTOK(t,NULL); strcpy(n->no,t);
    n->next=G_nap;
    G_nap=n;
}
//---------------------------------------------------------------------------
//F AddBFT_L
//S Add a BFT_L structure to G_nap
//D Add a BFT_L structure to the G_nap linked list (insert at beginning)
//P data string delimited with '$'
void AddBFT_L(BFT_S *s,INT depth)
{
    BFT_L *n;
    if ((n=MALLOC(sizeof(BFT_L)))==NULL) return;
    n->bs=s;
    n->depth=depth;
    n->next=G_bft_l;
    G_bft_l=n;
}
//---------------------------------------------------------------------------
//F AddBFT_J
//S Add a BFT_J structure to G_nap
//D Add a BFT_J structure to the G_nap linked list (insert at beginning)
//P data string delimited with '$'
void AddBFT_J(CHAR *d)
{
    BFT_J *n;
    CHAR *t;
    if ((n=MALLOC(sizeof(BFT_J)))==NULL) return;
    GETTOK(t,d   ); n->id=atol(t);
    GETTOK(t,NULL); n->fn=atol(t);
    GETTOK(t,NULL); strcpy(n->type,t);
    n->next=G_bft_j;
    G_bft_j=n;
}
//---------------------------------------------------------------------------
//F AddBFT
//S Add a BFT structure to G_nap
//D Add a BFT structure to the G_nap linked list (insert at beginning)
//P data string delimited with '$'
void AddBFT(CHAR *d)
{
    BFT *n;
    CHAR *t;
    if ((n=MALLOC(sizeof(BFT)))==NULL) return;
    GETTOK(t,d   ); n->no=atol(t);
    GETTOK(t,NULL); strcpy(n->cd,t);
    GETTOK(t,NULL); strcpy(n->alcd,t);
    n->next=G_bft;
    G_bft=n;
}
//---------------------------------------------------------------------------
//F AddFB
//S Add a FB structure to G_nap
//D Add a FB structure to the G_nap linked list (insert at beginning)
//P data string delimited with '$'
void AddFB(CHAR *d)
{
    FB *n;
    CHAR *t;
    if ((n=MALLOC(sizeof(FB)))==NULL) return;
    GETTOK(t,d   ); n->id=atol(t);
    GETTOK(t,NULL); n->sn=atol(t);
    GETTOK(t,NULL); n->en=atol(t);
    n->next=G_fb;
    G_fb=n;
}
//---------------------------------------------------------------------------
//F AddFBP
//S Add a FBP structure to G_nap
//D Add a FBP structure to the G_nap linked list (insert at beginning)
//P data string delimited with '$'
void AddFBP(CHAR *d)
{
    FBP *n;
    CHAR *t;
    if ((n=MALLOC(sizeof(FBP)))==NULL) return;
    GETTOK(t,d   ); n->bsid=atol(t);
    GETTOK(t,NULL); n->id=atol(t);
    GETTOK(t,NULL); n->tn=atoi(t);
    n->next=G_fbp;
    G_fbp=n;
}
//---------------------------------------------------------------------------
//F AddBFT_BT
//S Add a BFT_BT structure to G_nap
//D Add a BFT_BT structure to the G_nap linked list (insert at beginning)
//P data string delimited with '$'
void AddBFT_BT(CHAR *d)
{
    BFT_BT *n;
    CHAR *t;
    if ((n=MALLOC(sizeof(BFT_BT)))==NULL) return;
    GETTOK(t,d   ); n->bsid=atol(t);
    GETTOK(t,NULL); n->tn=atoi(t);
    n->next=G_bft_bt;
    G_bft_bt=n;
}
//---------------------------------------------------------------------------
//F AddBFT_E
//S Add a BFT_E structure to G_nap
//D Add a BFT_E structure to the G_nap linked list (insert at beginning)
//P data string delimited with '$'
void AddBFT_E(CHAR *d)
{
    BFT_E *n;
    CHAR *t;
    if ((n=MALLOC(sizeof(BFT_E)))==NULL) return;
    GETTOK(t,d   ); n->bsid1=atol(t);
    GETTOK(t,NULL); n->tn1=atoi(t);
    GETTOK(t,NULL); n->bsid2=atol(t);
    GETTOK(t,NULL); n->tn2=atoi(t);
    GETTOK(t,NULL); n->fn=atol(t);
    n->next=G_bft_e;
    G_bft_e=n;
}
//---------------------------------------------------------------------------
//F AddBFT_T
//S Add a BFT_T structure to G_nap
//D Add a BFT_T structure to the G_nap linked list (insert at beginning)
//P data string delimited with '$'
void AddBFT_T(CHAR *d)
{
    BFT_T *n;
    CHAR *t;
    if ((n=MALLOC(sizeof(BFT_T)))==NULL) return;
    GETTOK(t,d   ); strcpy(n->type,t);
    GETTOK(t,NULL); n->qty=atoi(t);
    n->next=G_bft_t;
    G_bft_t=n;
}
//---------------------------------------------------------------------------
//F AddBFT_S
//S Add a BFT_S structure to G_nap
//D Add a BFT_S structure to the G_nap linked list (insert at beginning)
//P data string delimited with '$'
void AddBFT_S(CHAR *d)
{
    BFT_S *n;
    CHAR *t;
    if ((n=MALLOC(sizeof(BFT_S)))==NULL) return;
    GETTOK(t,d   ); n->sn=atol(t);
    GETTOK(t,NULL); n->en=atol(t);
    GETTOK(t,NULL); n->sj=atol(t);
    GETTOK(t,NULL); n->ej=atol(t);
    GETTOK(t,NULL); strcpy(n->type,t);
    GETTOK(t,NULL); strcpy(n->cd,t);
    GETTOK(t,NULL); n->bsid=atol(t);
    GETTOK(t,NULL); n->len=atol(t);
    n->traced=FALSE;
    n->next=G_bft_s;
    G_bft_s=n;
}
//---------------------------------------------------------------------------
//F ReadDFile
//S Read the data file
//D Read a date file and fill the approp. linked list using the 
//D first letter of each line to determine the structure type
//P the filename (with full path)
void ReadDFile(CHAR *file)
{
    CHAR line[LINELEN],*t;
    FILE *fp;
    if ((fp=fopen(file,"r"))==NULL) return;
    while (fgets(line,LINELEN,fp)!=NULL) {
        t=strtok(line,"$\r\n");
        if (t!=NULL) {
            switch (*t) {
                case 'N' : // Nap
                    t=strtok(NULL,"\r\n"); if (t!=NULL) AddNAP(t); break;
                case 'J' : // bft Joint
                    t=strtok(NULL,"\r\n"); if (t!=NULL) AddBFT_J(t); break;
                case 'B' : // Bft
                    t=strtok(NULL,"\r\n"); if (t!=NULL) AddBFT(t); break;
                case 'F' : // Fibre bundle
                    t=strtok(NULL,"\r\n"); if (t!=NULL) AddFB(t); break;
                case 'P' : // fibre bundle Part
                    t=strtok(NULL,"\r\n"); if (t!=NULL) AddFBP(t); break;
                case 'U' : // blocked tUbes
                    t=strtok(NULL,"\r\n"); if (t!=NULL) AddBFT_BT(t); break;
                case 'E' : // bft Equipment
                    t=strtok(NULL,"\r\n"); if (t!=NULL) AddBFT_E(t); break;
                case 'T' : // bft Type
                    t=strtok(NULL,"\r\n"); if (t!=NULL) AddBFT_T(t); break;
                case 'S' : // bft Section
                    t=strtok(NULL,"\r\n"); if (t!=NULL) AddBFT_S(t); break;
            }
        }
    }
    fclose(fp);
}
//---------------------------------------------------------------------------
//F FreeData
//S Free the data associated with the global linked lists
//D Free the data associated with the global linked lists
//P TRUE if all the lists free'd else just the G_nap_tl & G_bft_l lists
void FreeData(BOOL all)
{
    NAP    *nap;
    BFT_J  *bft_j;
    BFT    *bft;
    FB     *fb;
    FBP    *fbp;
    BFT_BT *bft_bt;
    BFT_E  *bft_e;
    BFT_T  *bft_t;
    BFT_S  *bft_s;
    NAP_TL *nap_tl;
    TUBE_L *tube_l;
    BFT_L  *bft_l;

    if (all) {
        while (G_nap!=NULL) {
            nap=G_nap;       G_nap=G_nap->next;       FREE(nap);
        }
        while (G_bft_j!=NULL) {
            bft_j=G_bft_j;   G_bft_j=G_bft_j->next;   FREE(bft_j);
        }
        while (G_bft!=NULL) {
            bft=G_bft;       G_bft=G_bft->next;       FREE(bft);
        }
        while (G_fb!=NULL) {
            fb=G_fb;         G_fb=G_fb->next;         FREE(fb);
        }
        while (G_fbp!=NULL) {
            fbp=G_fbp;       G_fbp=G_fbp->next;       FREE(fbp);
        }
        while (G_bft_bt!=NULL) {
            bft_bt=G_bft_bt; G_bft_bt=G_bft_bt->next; FREE(bft_bt);
        }
        while (G_bft_e!=NULL) {
            bft_e=G_bft_e;   G_bft_e=G_bft_e->next;   FREE(bft_e);
        }
        while (G_bft_t!=NULL) {
            bft_t=G_bft_t;   G_bft_t=G_bft_t->next;   FREE(bft_t);
        }
        while (G_bft_s!=NULL) {
            bft_s=G_bft_s;   G_bft_s=G_bft_s->next;   FREE(bft_s);
        }
    }    
    while (G_nap_tl!=NULL) {
        nap_tl=G_nap_tl;
        while (nap_tl->ltubes!=NULL) {
            tube_l=nap_tl->ltubes;
            nap_tl->ltubes=nap_tl->ltubes->next;
            FREE(tube_l);
        }
        while (nap_tl->rtubes!=NULL) {
            tube_l=nap_tl->rtubes;
            nap_tl->rtubes=nap_tl->rtubes->next;
            FREE(tube_l);
        }
        G_nap_tl=G_nap_tl->next;
        FREE(nap_tl);
    }
    while (G_bft_l!=NULL) {
        bft_l=G_bft_l;   G_bft_l=G_bft_l->next;   FREE(bft_l);
    }
}
//---------------------------------------------------------------------------
//F PrintData
//S Print the read data structure on stdout
//D Print the read data structure on stdout (for testing)
void PrintData(void)
{
    NAP    *nap;
    BFT_J  *bft_j;
    BFT    *bft;
    FB     *fb;
    FBP    *fbp;
    BFT_BT *bft_bt;
    BFT_E  *bft_e;
    BFT_T  *bft_t;
    BFT_S  *bft_s;

    nap=G_nap;
    while (nap!=NULL) {
        printf("NAP %ld,%c,%s,%s\n",nap->fn,nap->fa,nap->ctg,nap->no);
        nap=nap->next;
    }
    bft_j=G_bft_j;
    while (bft_j!=NULL) {
        printf("BFT_J %ld,%ld,%s\n",bft_j->id,bft_j->fn,bft_j->type);
        bft_j=bft_j->next;
    }
    bft=G_bft;
    while (bft!=NULL) {
        printf("BFT %ld,%s,%s\n",bft->no,bft->cd,bft->alcd);
        bft=bft->next;
    }
    fb=G_fb;
    while (fb!=NULL) {
        printf("FB %ld,%ld,%ld\n",fb->id,fb->sn,fb->en);
        fb=fb->next;
    }
    fbp=G_fbp;
    while (fbp!=NULL) {
        printf("FBP %ld,%ld,%d\n",fbp->bsid,fbp->id,fbp->tn);
        fbp=fbp->next;
    }
    bft_bt=G_bft_bt;
    while (bft_bt!=NULL) {
        printf("BFT_BT %ld,%d\n",bft_bt->bsid,bft_bt->tn);
        bft_bt=bft_bt->next;
    }
    bft_e=G_bft_e;
    while (bft_e!=NULL) {
        printf("BFT_E %ld,%d,%ld,%d,%ld\n" ,
            bft_e->bsid1,bft_e->tn1,bft_e->bsid2,bft_e->tn2,bft_e->fn);
        bft_e=bft_e->next;
    }
    bft_t=G_bft_t;
    while (bft_t!=NULL) {
        printf("BFT_T %s,%d\n" ,bft_t->type,bft_t->qty);
        bft_t=bft_t->next;
    }
    bft_s=G_bft_s;
    while (bft_s!=NULL) {
        printf("BFT_S %ld,%ld,%ld,%ld,%s,%s,%ld,%ld\n" ,
            bft_s->sn,bft_s->en,bft_s->sj,bft_s->ej,
            bft_s->type,bft_s->cd,bft_s->bsid,bft_s->len);
        bft_s=bft_s->next;
    }
}
//---------------------------------------------------------------------------
//F BFT_Cat
//S Return the BFT catagory
//D Return the BFT catagory i.e. alloc code, SPACE, BFT number -
//D used in the bottom line of the BFT description box.
//P the BFT code
//R the BFT catagory in a static string overwritten on each call
CHAR *BFT_Cat(CHAR *cd)
{
    static CHAR ret[40];
    BFT    *bft=G_bft;
    while (bft!=NULL) {
        if (!strcmp(bft->cd,cd)) {
            sprintf(ret,"%s %ld",bft->alcd,bft->no);
            return(ret);
        }
        bft=bft->next;
    }
    sprintf(ret,"Err. BFT %s",cd);
    return(ret);
}
//---------------------------------------------------------------------------
//F Cat
//S Return the Network Access Point catagory
//D Return the Network Access Point catagory 
//D i.e. F|A (FP/ACP), T|Y (T/Y Unit), NAP number
//P The NAP feature number
//R the NAP catagory in a static string overwritten on each call
CHAR *Cat(LONG fn)
{
    static CHAR ret[40];
    NAP    *nap=G_nap;
    while (nap!=NULL) {
        if (nap->fn==fn) {
            sprintf(ret,"%c%c%s",nap->fa,nap->ctg[0],nap->no);
            return(ret);
        }
        nap=nap->next;
    }
    sprintf(ret,"Err. NAP %ld",fn);
    return(ret);
}
//---------------------------------------------------------------------------
//F FindJointNap
//S Find the NAP featnumb from a BFT joint ident.
//D Find the NAP featnumb from a BFT joint ident by traversing the BFT
//D joint list
//P The BFT joint ident
//R The NAP feature number.
LONG FindJointNap(LONG jid)
{
    BFT_J  *bft_j=G_bft_j;
    while (bft_j!=NULL) {
        if (bft_j->id==jid) return bft_j->fn;
        bft_j=bft_j->next;
    }
    return 0L;
}
//---------------------------------------------------------------------------
//F Blocked
//S Return True if a tube is blocked
//D Return True if a tube is blocked by traversing the BFT Blocked Tubes list
//P BFT section ident
//P BFT tube number (1..n where n is 1|2|4|7)
//R TRUE if blocked else FALSE
BOOL Blocked(LONG bsid,INT tn)
{
    BFT_BT *bft_bt=G_bft_bt;
    while (bft_bt!=NULL) {
        if ((bft_bt->bsid==bsid)&&(bft_bt->tn==tn)) return TRUE;
        bft_bt=bft_bt->next;
    }
    return FALSE;
}
//---------------------------------------------------------------------------
//F Occupied
//S Return True if a tube is occupied
//D Return True if a tube is occupied by traversing the Fibre Bundle Parts list
//P BFT section ident
//P BFT tube number (1..n where n is 1|2|4|7)
//R TRUE if occupied else FALSE
BOOL Occupied(LONG bsid,INT tn)
{
    FBP *fbp=G_fbp;
    while (fbp!=NULL) {
        if ((fbp->bsid==bsid)&&(fbp->tn==tn)) return TRUE;
        fbp=fbp->next;
    }
    return FALSE;
}
//---------------------------------------------------------------------------
//F Equipment
//S Return True if a tube has connected equipment in a given NAP
//D Return True if a tube has connected equipment in a given NAP
//D by traversing the BFT Equipment list
//P BFT section ident
//P BFT tube number (1..n where n is 1|2|4|7)
//P NAP feature number
//P TRUE if refering to the tube2 entry (i.e. the right hand side)
//R TRUE if occupied else FALSE
BOOL Equipment(LONG bsid,INT tn,LONG fn,BOOL right)
{
    BFT_E *bft_e=G_bft_e;
    while (bft_e!=NULL) {
        if (bft_e->fn==fn) {
            if (right) {
                if ((bft_e->bsid2==bsid)&&(bft_e->tn2==tn)) return TRUE;
            } else {
                if ((bft_e->bsid1==bsid)&&(bft_e->tn1==tn)) return TRUE;
            }
        }
        bft_e=bft_e->next;
    }
    return FALSE;
}
//---------------------------------------------------------------------------
//F NumbTubes
//S Return the number of tubes in a BFT section
//D Return the number of tubes in a BFT section by traversing the BFT Types list
//P The tube type
//R The number of tubes (i.e. 1,2,4,7) or 0 if not found (NOTE for MJD use for 'UNKNOWN' lable in rosette)
INT NumbTubes(CHAR *type)
{
    BFT_T *bft_t=G_bft_t;
    while (bft_t!=NULL) {
        if (!strcmp(bft_t->type,type)) return bft_t->qty;
        bft_t=bft_t->next;
    }
    return 0;
}
//---------------------------------------------------------------------------
//F AddTube
//S Add a tube to the nap tube list structure
//D Add a tube to the nap tube list structure setting it's initial
//D X/Y offsets and assigning it to the left or right hand side of the NAP box
//P This NAP's tubelist structure
//P The BFT Section IDent
//P The tube number
//P tube status (bitmap) 8 - joint right, 4 - left, 2 - Occupied, 1 - Blocked.
//P the Depth i.e. X offset in 1 box units
//P the LEFT or RIGHT side of the NAP
void AddTube(TUBE_L **tl,LONG bsid,INT tn,INT ts,INT depth,INT side)
{
    TUBE_L *newt;
    TUBE_L *last;

    if ((newt=MALLOC(sizeof(TUBE_L)))==NULL) return;
    newt->bsid=bsid;
    newt->tn=tn;
    newt->ts=ts;
    newt->tofs=tn-1;
    newt->llink=NULL;
    newt->rlink=NULL;
    newt->next=NULL;
    newt->prev=NULL;
    if (*tl==NULL) {
        if (side==RIGHT)
            newt->tofs=G_toffset[depth]++;
        else
            newt->tofs=G_toffset[depth]++;
        *tl=newt;
        return;
    }
    last=*tl;
    while (last!=NULL) {
        if (last->next==NULL) {
            newt->prev=last;
            last->next=newt;
            if (side==RIGHT)
                newt->tofs=G_toffset[depth]++;
            else
                newt->tofs=G_toffset[depth]++;
            return;
        }
        last=last->next;
    }
}
//---------------------------------------------------------------------------
//F AddTubeList
//S Add the tube list to the start and end naps for a BFT
//D Add the tube list to the start and end naps for a BFT
//P Start NAP feature number
//P End NAP feature number
//P BFT section ident
//P The number of tubes
//P a pointer to an array of the tube stati
//P the Depth i.e. X offset in 1 box units
void AddTubeList(LONG sn,LONG en,LONG bsid,INT numt,INT *ts,INT depth)
{
    NAP_TL *nap_tl=G_nap_tl;
    INT i;
    BOOL donesn=FALSE;
    BOOL doneen=FALSE;

    while (nap_tl!=NULL) {
        if (nap_tl->fn==sn) {
            donesn=TRUE;
            for (i=0;i<numt;i++) AddTube(&(nap_tl->rtubes),bsid,i+1,*(ts+i),depth,RIGHT);
            if (doneen) return;
        }
        if (nap_tl->fn==en) {
            doneen=TRUE;
            for (i=0;i<numt;i++) AddTube(&(nap_tl->ltubes),bsid,i+1,*(ts+i),depth+1,LEFT);
            if (donesn) return;
        }
        nap_tl=nap_tl->next;
    }
    if (!donesn) {
        if ((nap_tl=MALLOC(sizeof(NAP_TL)))==NULL) return;
        nap_tl->fn=sn;
        nap_tl->depth=depth;
        nap_tl->parent=NULL;
        nap_tl->sibling=NULL;
        nap_tl->child=NULL;
        nap_tl->rtubes=NULL;
        nap_tl->ltubes=NULL;
        nap_tl->next=G_nap_tl;
        G_nap_tl=nap_tl;
        for (i=0;i<numt;i++) AddTube(&(nap_tl->rtubes),bsid,i+1,*(ts+i),depth,RIGHT);
    }
    if (!doneen) {
        if ((nap_tl=MALLOC(sizeof(NAP_TL)))==NULL) return;
        nap_tl->fn=en;
        nap_tl->depth=depth+1;
        nap_tl->parent=NULL;
        nap_tl->child=NULL;
        nap_tl->sibling=NULL;
        nap_tl->rtubes=NULL;
        nap_tl->ltubes=NULL;
        nap_tl->next=G_nap_tl;
        G_nap_tl=nap_tl;
        for (i=0;i<numt;i++) AddTube(&(nap_tl->ltubes),bsid,i+1,*(ts+i),depth+1,LEFT);
    }
}
//---------------------------------------------------------------------------
//F GetTubeInfo
//S Collect the tube information for one BFT section
//D Collect the tube information for one BFT section including the number of 
//D tubes, the status of each and the start offset within the NAP box
//P A BFT section structure
//P Start NAP feature number
//P End NAP feature number
//P the Depth i.e. X offset in 1 box units
void GetTubeInfo(BFT_S *bft_s,LONG sn,LONG en,INT depth)
{
    INT tn,nt;
    LONG bsid=bft_s->bsid;

    nt=bft_s->numt=NumbTubes(bft_s->type);

    for (tn=0;tn<nt;tn++) bft_s->tubestat[tn]=0;
    for (tn=1;tn<=bft_s->numt;tn++) {
        if (Blocked (bsid,tn))     bft_s->tubestat[tn-1]|=1;
        if (Occupied(bsid,tn))     bft_s->tubestat[tn-1]|=2;
        if (Equipment(bsid,tn,sn,TRUE )) bft_s->tubestat[tn-1]|=4;
        if (Equipment(bsid,tn,en,FALSE)) bft_s->tubestat[tn-1]|=8;
    }
    AddTubeList(sn,en,bsid,nt,bft_s->tubestat,depth);
}
//---------------------------------------------------------------------------
//F TraceFrTo
//S Trace all BFT sections that pass between two NAP's
//D Trace all BFT sections that pass between two NAP's
//D NOTE: This function sets the flag traced for each section
//P Start NAP feature number
//P End NAP feature number
//P the Depth i.e. X offset in 1 box units
void TraceFrTo(LONG sfnum,LONG efnum,INT depth)
{
    BFT_S  *bft_s=G_bft_s;
    LONG sn;
    LONG en;
    
    while (bft_s!=NULL) {
        if (!bft_s->traced) {
            sn=bft_s->sn;
            en=bft_s->en;
            if (((sn==sfnum)&&(en==efnum))||((en==sfnum)&&(sn==efnum))) {
                bft_s->traced=TRUE;
                AddBFT_L(bft_s,depth);
                G_toffset[depth]+=5;
                GetTubeInfo(bft_s,sn,en,depth);
            }
        }
        bft_s=bft_s->next;
    }
}
//---------------------------------------------------------------------------
//F TraceFrom
//S Trace all BFT sections that from a NAP
//D Trace all BFT sections that from a NAP
//D NOTE: This function sets the flag traced for each section
//P NAP feature number
//P TRUE if trace upstream
//P the Depth i.e. X offset in 1 box units
//P a NAP_TL strucure of the parent to this nap (NULL if first NAP in list)
void TraceFrom(LONG fnum,BOOL upstream,INT depth,NAP_TL *parent)
{
    NAP_TL *nap_tl=G_nap_tl;
    BFT_S  *bft_s=G_bft_s;
    INT topofbox;
    LONG sn;
    LONG en;
    BOOL first=TRUE;

    while (nap_tl!=NULL) {
        if (nap_tl->fn==fnum) {
            if (nap_tl->parent==NULL) {
                nap_tl->parent=parent;
                if (parent->child==NULL) parent->child=nap_tl;
            } else {
                if (nap_tl->parent!=parent) {
                    if (G_fp!=NULL) fprintf(G_fp,"8Mismatch in parents");
                }
            }
            break;
        }
        nap_tl=nap_tl->next;
    }
    while (bft_s!=NULL) {
        if (!bft_s->traced) {
            if (bft_s->sn==0) bft_s->sn=FindJointNap(bft_s->sj); 
            if (bft_s->en==0) bft_s->en=FindJointNap(bft_s->ej);
            sn=bft_s->sn;
            en=bft_s->en;
            if ((sn==fnum)||((upstream)&&(en==fnum))) {
                if (nap_tl==NULL) {
                    if ((nap_tl=MALLOC(sizeof(NAP_TL)))==NULL) return;
                    nap_tl->fn=fnum;
                    nap_tl->depth=depth;
                    nap_tl->rtubes=NULL;
                    nap_tl->ltubes=NULL;
                    nap_tl->parent=parent;
                    nap_tl->child=NULL;
                    nap_tl->sibling=NULL;
                    nap_tl->next=G_nap_tl;
                    G_nap_tl=nap_tl;
                    if ((parent!=NULL)&&(parent->child==NULL)) parent->child=nap_tl;
                }
                if (!first) {
                    G_toffset[depth]+=5;
                }
                first=FALSE;
                topofbox=G_toffset[depth];
                bft_s->traced=TRUE;
                AddBFT_L(bft_s,depth);
                GetTubeInfo(bft_s,sn,en,depth);
                TraceFrTo(sn,en,depth);
                G_toffset[depth+1]=topofbox;
                TraceFrom(en,upstream,depth+1,nap_tl);
            }
        }
        bft_s=bft_s->next;
    }
}
//---------------------------------------------------------------------------
//F ClearTrace
//S Clear the 'traced' flag for all BFT sections
//D Clear the 'traced' flag for all BFT sections
void ClearTrace(void)
{
    BFT_S *bft_s=G_bft_s;
    while (bft_s!=NULL) {
        if (bft_s->traced) bft_s->traced=FALSE;
        bft_s=bft_s->next;
    }
}
//---------------------------------------------------------------------------
//F TUnitId
//S Get a TUNIT NAP feature number from a nap number
//D Get a TUNIT NAP feature number from a nap number
//P The tunit nap number
//R The NAP feature number
LONG TUnitId(CHAR *tunit)
{
    NAP *nap=G_nap;
    while (nap!=NULL) {
        if ((!strcmp(nap->no,tunit))&&(!strcmp(nap->ctg,"TU")))
            return nap->fn;
        nap=nap->next;
    }
    return 0L;
}
//---------------------------------------------------------------------------
//F FindELink
//S Find the tube connected via equipment to the passed tube.
//D Find the tube connected via equipment to the passed tube and return
//D it's tube_l structure. This function is used to generate all the
//D left and right tube connection dependancies for tube alignment.
//P the tube_l structure
//P The NAP feature number
//P The BFT sectio ident
//P The tube number
//R A connected tube or NULL
TUBE_L *FindELink(TUBE_L *tube_l,LONG fn,LONG bsid,INT tn)
{
    BFT_E *bft_e=G_bft_e;
    LONG tbsid=0;
    INT ttn;
    while (bft_e!=NULL) {
        if (bft_e->fn==fn) {
            if ((bft_e->bsid2==bsid)&&(bft_e->tn2==tn)) {
                tbsid=bft_e->bsid1;
                ttn  =bft_e->tn1;
                break;
            }
            if ((bft_e->bsid1==bsid)&&(bft_e->tn1==tn)) {
                tbsid=bft_e->bsid2;
                ttn  =bft_e->tn2;
                break;
            }
        }
        bft_e=bft_e->next;
    }
    if (tbsid==0) return NULL;
    while (tube_l!=NULL) {
        if ((tube_l->bsid==tbsid)&&(tube_l->tn==ttn)) return tube_l;
        tube_l=tube_l->next;
    }
    return NULL;
}
//---------------------------------------------------------------------------
//F FindLink
//S Find a BFT section tube connected to the left or right hand side of a NAP
//D Find a BFT section tube connected to the left or right hand side of a NAP
//P The NAP feature number
//P The BFT sectio ident
//P The tube number
//P TRUE if connected to the right
//R The connected tube or NULL
TUBE_L *FindLink(LONG fn,LONG bsid,INT tn,BOOL right)
{
    BFT_L *bft_l=G_bft_l;
    NAP_TL *nap_tl=G_nap_tl;
    TUBE_L *tube_l;
    LONG tfn=0;
    while (bft_l!=NULL) {
        if (bft_l->bs->bsid==bsid) {
            if (bft_l->bs->sn==fn) {
                tfn=bft_l->bs->en;
            } else if (bft_l->bs->en==fn) {
                tfn=bft_l->bs->sn;
            }
            if (tfn==0) return NULL;
            while (nap_tl!=NULL) {
                if (nap_tl->fn==tfn) {
                    if (right) {
                        tube_l=nap_tl->ltubes;
                    } else {
                        tube_l=nap_tl->rtubes;
                    }
                    while (tube_l!=NULL) {
                        if ((tube_l->bsid==bsid)&&(tube_l->tn==tn))
                            return tube_l;
                        tube_l=tube_l->next;
                    }
                    return NULL;
                }
                nap_tl=nap_tl->next;
            }
            return NULL;
        }
        bft_l=bft_l->next;
    }
    return NULL;
}
//---------------------------------------------------------------------------
//F SetSiblings
//S Setup the Sibling ling between NAPS
//D Setup the Sibling ling between NAPS ( used for moving lower NAP boxes out of the way)
//P The parent nap
void SetSiblings(NAP_TL *parent)
{
    NAP_TL *nap_tl;
    NAP_TL *sib;
    INT depth;
//    INT tofs=32766;
//    INT cofs;

    if (parent==NULL) return;
    if (parent->child==NULL) return;
    parent=parent->child;
    nap_tl=G_nap_tl;
    sib=parent;
    depth=sib->depth;
//    if (sib->ltubes!=NULL) tofs=sib->ltubes->tofs;
//    if (sib->rtubes!=NULL) tofs=min(tofs,sib->rtubes->tofs);
    while (nap_tl!=NULL) {
//        cofs=32766;
//        if (nap_tl->ltubes!=NULL) cofs=nap_tl->ltubes->tofs;
//        if (nap_tl->rtubes!=NULL) cofs=min(cofs,nap_tl->rtubes->tofs);
//        if ((nap_tl->depth==depth)&&(nap_tl!=parent->child)&&(tofs<=cofs)) {
        if ((nap_tl->depth==depth)&&(nap_tl!=parent)) {
            sib->sibling=nap_tl;
            sib=nap_tl;
            sib->sibling=NULL;
        }
        nap_tl=nap_tl->next;
    }

}
//---------------------------------------------------------------------------
//F AddTubeLinks
//S Generate all the left and right tube links for the diagram
//D Generate all the left and right tube links for the diagram
void AddTubeLinks(void)
{
    NAP_TL *nap_tl=G_nap_tl;
    TUBE_L *tube_l;
    while (nap_tl!=NULL) {
        SetSiblings(nap_tl->parent);
        tube_l=nap_tl->ltubes;
        while (tube_l!=NULL) {
            tube_l->fn=nap_tl->fn;
            if ((tube_l->ts&8)!=0) {
                tube_l->rlink=FindELink(nap_tl->rtubes,nap_tl->fn,tube_l->bsid,tube_l->tn);
            }
            tube_l->llink=FindLink(nap_tl->fn,tube_l->bsid,tube_l->tn,FALSE);
            tube_l=tube_l->next;
        }
        tube_l=nap_tl->rtubes;
        while (tube_l!=NULL) {
            tube_l->fn=nap_tl->fn;
            if ((tube_l->ts&4)!=0) {
                tube_l->llink=FindELink(nap_tl->ltubes,nap_tl->fn,tube_l->bsid,tube_l->tn);
            }
            tube_l->rlink=FindLink(nap_tl->fn,tube_l->bsid,tube_l->tn,TRUE);
            tube_l=tube_l->next;
        }
        nap_tl=nap_tl->next;
    }
}
//---------------------------------------------------------------------------
//F ListTubeLinks
//S List on stdout the links between all the tubes
//D List on stdout the links between all the tubes for diagnostics
void ListTubeLinks(void)
{
    NAP_TL *nap_tl=G_nap_tl;
    TUBE_L *tube_l;
    while (nap_tl!=NULL) {
        printf("\nNap %s Depth %d Left Tubes\n",Cat(nap_tl->fn),nap_tl->depth);
        if (nap_tl->child==NULL)   printf("No Children\n"); else printf("Child %s\n",Cat(nap_tl->child->fn));
        if (nap_tl->parent==NULL)  printf("No Parent\n");  else printf("Parent %s\n",Cat(nap_tl->parent->fn));
        if (nap_tl->sibling==NULL) printf("No Siblings\n"); else printf("Sibling %s\n",Cat(nap_tl->sibling->fn));
        tube_l=nap_tl->ltubes;
        while (tube_l!=NULL) {
            printf("Sect         %ld Tube %d Offset %d State %d\n",tube_l->bsid,tube_l->tn,tube_l->tofs,tube_l->ts);
            if (tube_l->llink) 
                printf("Left  %s %ld Tube %d Offset %d State %d\n",Cat(tube_l->llink->fn),tube_l->llink->bsid,tube_l->llink->tn,tube_l->llink->tofs,tube_l->llink->ts);
            if (tube_l->rlink) 
                printf("Right %s %ld Tube %d Offset %d State %d\n",Cat(tube_l->rlink->fn),tube_l->rlink->bsid,tube_l->rlink->tn,tube_l->rlink->tofs,tube_l->rlink->ts);
            tube_l=tube_l->next;
        }
        printf("\nNap %s Depth %d Right Tubes\n",Cat(nap_tl->fn),nap_tl->depth);
        tube_l=nap_tl->rtubes;
        while (tube_l!=NULL) {
            printf("Sect         %ld Tube %d Offset %d State %d\n",tube_l->bsid,tube_l->tn,tube_l->tofs,tube_l->ts);
            if (tube_l->llink) 
                printf("Left  %s %ld Tube %d Offset %d State %d\n",Cat(tube_l->llink->fn),tube_l->llink->bsid,tube_l->llink->tn,tube_l->llink->tofs,tube_l->llink->ts);
            if (tube_l->rlink) 
                printf("Right %s %ld Tube %d Offset %d State %d\n",Cat(tube_l->rlink->fn),tube_l->rlink->bsid,tube_l->rlink->tn,tube_l->rlink->tofs,tube_l->rlink->ts);
            tube_l=tube_l->next;
        }
        nap_tl=nap_tl->next;
    }
}
//---------------------------------------------------------------------------
//F TubeBore
//S Draw a BFT section rosette tube
//D Draw a BFT section rosette tube with an 
//D 'O' for Occupied and an 'X' for Blocked
//P The X coord.               
//P The Y coord.
//P The radius
//P The tube status (bitmap) 2 - Occupied, 1 - Blocked
void TubeBore(INT x,INT y,INT r,INT ts)
{
    circle(x,y,r);
    if ((ts&2)!=0) {
        setcolor(14);
        circle(x,y,r-1);
        circle(x,y,r-2);
        setcolor(15);
    }
    if ((ts&1)!=0) {
        setcolor(12);
        line(x-r,y,x+r,y);
        line(x,y-r,x,y+r);
        setcolor(15);
    }
}
//---------------------------------------------------------------------------
//F DrawRosette
//S Draw a section rosette 
//D Draw a section rosette 
//P The X coord. 
//P The Y coord.
//P The number of tubes
//P The tube stati (bitmap) 2 - Occupied, 1 - Blocked
void DrawRosette(INT x,INT y,INT nt,INT *ts)
{
    int bsize;
    x+=TUBEDHGT/2+1;
    y+=TUBEDHGT/2;
    circle(x,y,TUBEDHGT/2);
    bsize=TUBEDHGT/7;

    switch (nt) {
        case 1 :
            TubeBore(x   ,y  ,1,ts[0]);
            break;
        case 2 :
            TubeBore(x   ,y-6,1,ts[0]);
            TubeBore(x   ,y+6,2,ts[1]);
            break;
        case 4 :
            TubeBore(x-6 ,y-6,1,ts[0]);
            TubeBore(x-6 ,y+6,2,ts[1]);
            TubeBore(x+6 ,y-6,3,ts[2]);
            TubeBore(x+6 ,y+6,4,ts[3]);
            break;
        case 7 :
            TubeBore(x         ,y            ,1,ts[6]);
            TubeBore(x+bsize*2 ,y            ,2,ts[1]);
            TubeBore(x+bsize   ,y+(bsize*7)/4,3,ts[2]);
            TubeBore(x-bsize   ,y+(bsize*7)/4,4,ts[3]);
            TubeBore(x-bsize*2 ,y            ,5,ts[4]);
            TubeBore(x-bsize   ,y-(bsize*7)/4,6,ts[5]);
            TubeBore(x+bsize   ,y-(bsize*7)/4,7,ts[0]);
            break;
        default :
            outxy(x,y-TEXTHGT/2,"UNKNOWN");
    }
}
//---------------------------------------------------------------------------
//F TubeBox
//S Draw the tube description box
//D Draw the tube description box
//P the BFT section ident
//P The left offset
//P The top offset
void TubeBox(LONG bsid,INT lofs,INT ofs)
{
    BFT_S *bft_s=G_bft_s;
    BFT   *bft=G_bft;
    rectangle(lofs,ofs,lofs+TUBEDWID,ofs+TUBEHGT*3);
    line(lofs,ofs+TUBEHGT  ,lofs+TUBEDWID,ofs+TUBEHGT  );
    line(lofs,ofs+TUBEHGT*2,lofs+TUBEDWID,ofs+TUBEHGT*2);
    while (bft_s!=NULL) {
        if (bft_s->bsid==bsid) {
            DrawRosette(lofs+TUBEDWID,ofs,bft_s->numt,bft_s->tubestat);
            outxy(lofs+20,ofs-TEXTHGT,"%ld.%03ld",bft_s->len/1000,bft_s->len%1000);
            outxy(lofs+TUBEDWID/2,ofs          ,bft_s->cd  );
            outxy(lofs+TUBEDWID/2,ofs+TEXTHGT  ,bft_s->type);
            while (bft!=NULL) {
                if (!strcmp(bft->cd,bft_s->cd)) {
                    outxy(lofs+TUBEDWID/2,ofs+TEXTHGT*2,"%s %ld",bft->alcd,bft->no);
                    return;
                }
                bft=bft->next;
            }
            return;
        }
        bft_s=bft_s->next;
    }
}
//---------------------------------------------------------------------------
//F NapDepth
//S Find the 'depth' of a NAP
//D Find the 'depth' of a NAP i.e. the X offset in box increments
//P The NAP feature number
//R The depth or 0 if not found
int NapDepth(LONG fn)
{
    NAP_TL *nap_tl=G_nap_tl;
    while (nap_tl!=NULL) {
        if (nap_tl->fn==fn) return nap_tl->depth;
        nap_tl=nap_tl->next;
    }
    return 0;
}
//---------------------------------------------------------------------------
//F DrawBFTSectionDiag
//S Draw the BFT Section Diagram
//D Draw the BFT Section Diagram
void DrawBFTSectionDiag(void)
{
    NAP_TL *nap_tl=G_nap_tl;
    TUBE_L *tube_l;
    BFT_J  *bft_j;
    INT mino,maxo,depth,tn,ofs,lofs;
    LONG bsid;
    CHAR *jt;
    INT condepth;

    while (nap_tl!=NULL) {
        depth=((nap_tl->depth-1)*(BOXWID+BOXSPACE))+20;
        maxo=0;              
        mino=32766;
        tube_l=nap_tl->rtubes;
        while (tube_l!=NULL) {
            mino=min(mino,tube_l->tofs);
            maxo=max(maxo,tube_l->tofs);
            tube_l=tube_l->next;
        }
        tube_l=nap_tl->ltubes;
        while (tube_l!=NULL) {
            mino=min(mino,tube_l->tofs);
            maxo=max(maxo,tube_l->tofs);
            tube_l=tube_l->next;
        }

        tube_l=nap_tl->rtubes;
        if (tube_l!=NULL) {
            while (tube_l!=NULL) {
                tn=tube_l->tn;
                if (tn==1) bsid=tube_l->bsid;
                ofs=tube_l->tofs*TUBEHGT+TUBEHGT/2;
                lofs=depth+BOXWID;
                if (tube_l->rlink!=NULL) {
                    condepth=NapDepth(tube_l->rlink->fn)-nap_tl->depth;
                } else {
                    condepth=1;
                }
                condepth=tube(lofs,ofs,tube_l->ts,tn,tn,condepth);
                condepth-=((TUBEDWID+(TUBEHGT*3)+1)/2);
                tube_l=tube_l->next;
                if (tube_l!=NULL) {
                    if (tube_l->tn==1) {
                        TubeBox(bsid,condepth,ofs+TUBEHGT);
                    }
                } else {
                    TubeBox(bsid,condepth,ofs+TUBEHGT);
                }
            }
        } else {
            tube_l=nap_tl->ltubes;
            while (tube_l!=NULL) {
                tn=tube_l->tn;
                if (tn==1) bsid=tube_l->bsid;
                ofs=tube_l->tofs*TUBEHGT+TUBEHGT/2;
                lofs=depth-BOXSPACE;
                condepth=tube(lofs,ofs,tube_l->ts,tn,tn,1);
                condepth-=((TUBEDWID+(TUBEHGT*3)+1)/2);
                tube_l=tube_l->next;
                if (tube_l!=NULL) {
                    if (tube_l->tn==1) {
                        TubeBox(bsid,condepth,ofs+TUBEHGT);
                    }
                } else {
                    TubeBox(bsid,condepth,ofs+TUBEHGT);
                }
            }
        }
        maxo++;
        jt=NULL;
        bft_j=G_bft_j;
        while (bft_j!=NULL) {
            if (bft_j->fn==nap_tl->fn) {
                jt=bft_j->type;
                break;
            }
            bft_j=bft_j->next;
        }
        
        if ((Cat(nap_tl->fn)[1]=='Y')&&(nap_tl->child==NULL)) {
            moveto(depth+YUNITMID,mino*TUBEHGT-YUNITMID);
            lineto(depth+YUNITMID*2,mino*TUBEHGT);
            lineto(depth+YUNITMID*2,maxo*TUBEHGT);
            lineto(depth+YUNITMID,maxo*TUBEHGT+YUNITMID);
            lineto(depth,maxo*TUBEHGT);
            lineto(depth,mino*TUBEHGT);
            lineto(depth+YUNITMID,mino*TUBEHGT-YUNITMID);
            outxy(depth+YUNITMID,(mino-2)*TUBEHGT,"%s",Cat(nap_tl->fn)+2);
        } else {
            rectangle(depth,mino*TUBEHGT,depth+BOXWID,maxo*TUBEHGT);
            if (jt!=NULL) {
                outxy(depth+BOXWID/2,(mino-2)*TUBEHGT,"%s",Cat(nap_tl->fn)+2);
                outxy(depth+BOXWID/2,(mino-1)*TUBEHGT,"%s",jt);
            } else {
                outxy(depth+BOXWID/2,(mino-1)*TUBEHGT,"%s",Cat(nap_tl->fn)+2);
            }
        }
        G_maxx=max(G_maxx,depth+BOXWID);
        G_maxy=max(G_maxy,(maxo+4)*TUBEHGT);
        nap_tl=nap_tl->next;
    }
}
//---------------------------------------------------------------------------
//F MoveTubesDown
//S Move all the lower tubes in this NAP down by a distance
//D Move all the lower tubes in this NAP down by a distance
//P The top tube link
//P The distance to move
//P TRUE if the whole section's tubes should be moved
void MoveTubesDown(TUBE_L *tube_l,INT distance,BOOL wholesect)
{
    if (wholesect) {
        while (tube_l!=NULL) {
            if (tube_l->tn==1) break;
            tube_l=tube_l->prev;
        }
    }
    while (tube_l!=NULL) {
        tube_l->tofs+=distance;
        tube_l=tube_l->next;
    }
}
//---------------------------------------------------------------------------
//F MoveLowerNaps
//S Move all the NAP boxes below 'fn' down by a distance
//D Move all the NAP boxes below 'fn' down by a distance
//P The NAP feature number
//P The offset of the current tube
//P The distance to move by
void MoveLowerNaps(LONG fn,INT offset,INT distance)
{
    NAP_TL *nap_tl;
    INT lofs,rofs;

    nap_tl=G_nap_tl;
    while (nap_tl!=NULL) {
        if (fn==nap_tl->fn) {
            nap_tl=nap_tl->sibling;
            while (nap_tl!=NULL) {
                if (nap_tl->ltubes!=NULL) {
                    lofs=nap_tl->ltubes->tofs;
                } else {
                    lofs=0;
                }
                if (nap_tl->rtubes!=NULL) {
                    rofs=nap_tl->rtubes->tofs;
                } else {
                    rofs=0;
                }
                if ((lofs>offset)||(rofs>offset)) {
                    while (nap_tl!=NULL) {
                        if (nap_tl->rtubes!=NULL) MoveTubesDown(nap_tl->ltubes,distance,FALSE);
                        MoveTubesDown(nap_tl->rtubes,distance,FALSE);
                        nap_tl=nap_tl->sibling;
                    }
                    return;
                }
                nap_tl=nap_tl->sibling;
            }
            return;
        }
        nap_tl=nap_tl->next;
    }
}
//---------------------------------------------------------------------------
//F AlignTubes
//S Align all tubes connected via left and right links
//D Align all tubes connected via left and right links by moving all tubes 
//D to the lowest tube's offset
void AlignTubes(void)
{
    NAP_TL *nap_tl=G_nap_tl;
    TUBE_L *tube_l;
    TUBE_L *tube_t;
    INT pos;
    INT depth,cdepth;
    G_oy=0;
    while (nap_tl!=NULL) {
        tube_l=nap_tl->rtubes;
        while (tube_l!=NULL) {
            cdepth=depth=nap_tl->depth;
            tube_t=tube_l;
            while (tube_t->llink!=NULL) { // move to left end of linked tubes
                tube_t=tube_t->llink;
                cdepth--;
            }
            pos=0;
            while (tube_t->rlink!=NULL) { // move to right end of linked line
                pos=max(pos,tube_t->tofs);
                tube_t=tube_t->rlink;
                cdepth++;
            }
            pos=max(pos,tube_t->tofs);
            while (tube_t!=NULL) { // move to left end of linked tubes
                if (pos-tube_t->tofs>0) {
                    MoveLowerNaps(tube_t->fn,tube_t->tofs,pos-tube_t->tofs);
                    MoveTubesDown(tube_t,pos-tube_t->tofs,cdepth>=depth); // FALSE
                }
                cdepth--;
                tube_t=tube_t->llink;
            }
            tube_l=tube_l->next;
        }
        nap_tl=nap_tl->next;
//        G_maxy=0;
//        DrawBFTSectionDiag();
//        G_oy+=G_maxy;
    }
//    G_maxy=G_oy;
}
//---------------------------------------------------------------------------
//F swapnlist
//S Swap the NAP tube list to reverse the traversal order
//D Swap the NAP tube list to reverse the traversal order this is done 
//D because the NAP tubes are inserted at the begining of the list
//D and we wish to traverse from the first NAP
void swapnlist(void)
{
    NAP_TL *nap_tl=G_nap_tl;
    NAP_TL *nap_p=NULL;
    NAP_TL *nap_n;
    while (nap_tl!=NULL) {
        nap_n=nap_tl->next;
        nap_tl->next=nap_p;
        nap_p=nap_tl;
        nap_tl=nap_n;
    }
    G_nap_tl=nap_p;
}
//---------------------------------------------------------------------------
//F TraceT
//S Trace the Tubes from a given NAP
//D Trace the Tubes from a given NAP
//P The TUNIT nap number (NOT feat numb)
//P TRUE if tracing both up and down stream 
//P TRUE if a diagnostic list should be generated only
//P TRUE if the trace should not align the tubes
void TraceT(CHAR *tunit,BOOL upstream,BOOL list,BOOL quick)
{
    LONG fnum=TUnitId(tunit);
    INT i;
    for (i=0;i<100;i++) G_toffset[i]=2;

    TraceFrom(fnum,upstream,1,NULL);

    swapnlist();
    AddTubeLinks();

    if (quick) return;

    AlignTubes();
    if (list)
        ListTubeLinks();
    else
        DrawBFTSectionDiag();
}
//---------------------------------------------------------------------------
//F ListNaps
//S List the NAP numbers into the file TUNITLST.GGF
//D List the NAP numbers into the file TUNITLST.GGF using only the NAP's
//D that have downstream connections
void ListNaps(void)
{
    FILE *fp;
    NAP  *nap;
    if ((fp=fopen("TUNITLST.GGF","w"))!=NULL) {
        nap=G_nap;
        if (nap==NULL) {
            fprintf(fp,"NO TUNITS FOUND\n");
        } else {
            while (nap!=NULL) {
                G_fp=NULL;
                if (nap->ctg[0]=='T') {
                    ClearTrace();
                    TraceT(nap->no,0,0,TRUE);
                    if ((G_nap_tl!=NULL)&&(G_nap_tl->child!=NULL)) {
                        fprintf(fp,"%s\n",nap->no);
                    }
                    FreeData(FALSE);
                }
                nap=nap->next;
            }
        }
        fclose(fp);
    }
}
#ifdef TESTING
//---------------------------------------------------------------------------
//F main
//S Entry point for test harness
//D Entry point for test harness argv[1] input file [2] NAP number [3] list only
//P The number of arguments
//P The arguments
//R 1 if no args supplied else  0 i.e. NO ERROR
INT main(INT argc,CHAR *argv[])
{
    if (argc<2) return 1;
    ReadDFile(argv[1]);
    G_fp=stdout;
    if (argc==2) {
        ListNaps();
    } else {
        ClearTrace();
        TraceT(argv[2],0,argc>3,FALSE);
    }
    FreeData(TRUE);
    return 0;
}
#else
#pragma warn -par
//---------------------------------------------------------------------------
//F LibMain
//S 16 bit DLL entry point 
//D 16 bit DLL entry point 
//P handle instance - not used
//P param           - not used
//P param           - not used
//P args            - not used
//R Always TRUE     
int FAR PASCAL LibMain (HINSTANCE h, WORD a, WORD b, LPSTR s)
{
    return TRUE;
}
//---------------------------------------------------------------------------
//F WEP
//S 16 bit DLL Windows Exit Point
//D 16 bit DLL Windows Exit Point
//P param - not used
//R Always TRUE     
int FAR PASCAL WEP (int nParameter)
{
    return 1;
}
#pragma warn +par
//---------------------------------------------------------------------------
//F PasToCStr
//S Convert a standard 'PASCAL' string to an ASCIZ string
//D Convert a standard 'PASCAL' string to an ASCIZ string using the first 
//D byte as a length 
//D NOTE this needs modification for 32 bit as the string is null terminated 
//D and the length indicator is not held in the first bytes.
//P the 'PASCAL' string
//R static ASCIZ string overwritten on each call
CHAR *PasToCStr(CHAR *str)
{
    static CHAR news[LINELEN];
    CHAR *newsp;
    INT len,i;
    len=(INT)*str;
    newsp=news;
    str++;
    for (i=0;i<len;i++) {
        *(newsp++)=*(str++);
    }
    *newsp=0;
    return news;
}
//---------------------------------------------------------------------------
//F MaxWidth
//S DLL exported function returning the width of the diagram
//D DLL exported function returning the width of the diagram
//R The diagram width NOTE: 16bit
INT  FAR PASCAL _export MaxWidth(void)
{
    return G_maxx;
}
//---------------------------------------------------------------------------
//F MaxWidth
//S DLL exported function returning the Height of the diagram
//D DLL exported function returning the Height of the diagram
//R The diagram height NOTE: 16bit
INT  FAR PASCAL _export MaxHeight(void)
{
    return G_maxy;
}
//---------------------------------------------------------------------------
//F LoadTable
//S Load the file specified (.IFD format) in to global structures and return NAP list
//D Load the file specified (.IFD format) in to global structures and return NAP list
//P (.IFD format) filename with full path and extension
void FAR PASCAL _export LoadTable(CHAR *filename)
{
    clock_t start,end;
    FILE *fp;
    INT i;

    start=clock();
    if (G_filename!=NULL) free(G_filename);
    G_filename=strdup(PasToCStr(filename));
    if ((fp=fopen("INPUT.GGF","w"))!=NULL) {
        fprintf(fp,"%s\n",G_filename);
        for (i=0;i<20;i++) fprintf(fp,"%02X ",G_filename[i]);
        fprintf(fp,"\n");
        fclose(fp);
    }
    ReadDFile(G_filename);
    ListNaps();
    FreeData(TRUE);
    end=clock();
    if ((fp=fopen("TT.GGF","w"))!=NULL) {
        fprintf(fp,"File %s Loaded in %ldms",G_filename,(end-start)+5);
        fclose(fp);
    }
}

//---------------------------------------------------------------------------
//F Traverse
//S Traverse from a NAP to all subsiquent NAPs
//D Traverse from a NAP to all subsiquent NAPs 
//D MUST BE CALLED AFTER LoadTable()
//P TUNIT nap number
//P 1 if tubes should be grouped 
//P 1 if trace should go upstream
void FAR PASCAL _export Traverse(CHAR *TUnit,INT group,INT fromto)
{
    clock_t start,end;
    char *t;
    if (G_filename==NULL) return;
    start=clock();

    TUnit=PasToCStr(TUnit);
    G_maxx=0;
    G_maxy=0;

    if ((G_fp=fopen("COMPNT.GGF","w"))==NULL) return;
    fprintf(G_fp,"8Params %s %d %d\n",TUnit,group,fromto);
    t=strtok(TUnit," \t\r\n");
    if (t==NULL) return;
    fprintf(G_fp,"8File %s\n",G_filename);
    fprintf(G_fp,"8TUNIT %s",t);
    fflush(G_fp);
    G_firstln=FALSE;

    ReadDFile(G_filename);
    ClearTrace();
    TraceT(t,0,0,FALSE);
    FreeData(TRUE);

    G_maxx+=20;
    G_maxy+=20;
    end=clock();
    fprintf(G_fp,"\n8TUNIT %s (%d X %d) Time(%ldms)",t,G_maxx,G_maxy,end-start);

    fclose(G_fp);
    G_fp=NULL;
}
#endif
//---------------------------------------------------------------------------
//                           END OF FILE 
//---------------------------------------------------------------------------
