#include <string.h>
#include <stdlib.h>
#include <dos.h>
#include <stdio.h>
#include <bios.h>
#include <ctype.h>
#include "gpa.h"

//--------------------------------------------------------------------------
//                  FUNCTION DECLAIRATIONS
//--------------------------------------------------------------------------
// ALL functions MUST be declaired   --   int funcname(void);

int             printtab     (void);
int             sndfiles     (void);
int             letdom      (void);
int             letdomva    (void);
int             letdomrg    (void);
int             pardom      (void);
int             pardomva    (void);
int             mosnum      (void);
int             mornum      (void);
int             mosfee      (void);
int             mosamt      (void);
int             moramt      (void);
int             mosvalid    (void);
int             rtvperio    (void);
int             rtvamt      (void);
int             rtvnew      (void);
int             rtvmonth    (void);
int             rtvlate     (void);
int             telperio    (void);
int             teldays     (void);
int             tellate     (void);
int             traperio    (void);
int             tradays     (void);
int             tralate     (void);
int             pzuperio    (void);
int             pzudays     (void);
int             pzulate     (void);
int             enedays     (void);
int             enelate     (void);
int             enefee      (void);
int             eneperio    (void);
int             renid       (void);
int             renamt      (void);
int             renfee      (void);
int             bankfee     (void);
int             custid      (void);
int             pkoacct     (void);
int             pkowamt     (void);
int             pkoposwi    (void);
int             pkoposde    (void);
int             addcheq     (void);
int             acctstop    (void);
int             cheqstop    (void);
int             prbar       (void);

//--------------------------------------------------------------------------
//                  ACTION / FUNCTION  Mapping
//--------------------------------------------------------------------------
#include "gpafunc.h"

//--------------------------------------------------------------------------
//                  FUNCTION DEFINITIONS
//--------------------------------------------------------------------------
int printtab(void)
{
    int smode,j,cprod,lprod,qty,q=0;
    char prod[10],qnty[10],amnt[20],name[21],tmp[40];
    char tabl[8];

    if (G_tb==NULL) return(1);

    smode=CURR;
    if (!strcmp(G_tb->sn,TRAN_S)) {
        while (stread(TRAN_S,smode)) {
            if (!stget(TRAN_S,CODE,prod)) return(0);
            if (atoi(prod)==0) {
                stread(TRAN_S,NEXT);
                break;
            }
            smode=PREV;
        }
        smode=CURR;
        sendmsg("SPRN",'I');
        getoffdet(OFFICE_N,tmp);
        if (!sendmsg("SPRN",'o',-1,0,"%s\n",tmp)) return(0);
        getoffdet(OFFICE_L,tmp);
        if (!sendmsg("SPRN",'o',-1,0,"%s\n",tmp)) return(0);
        getoffdet(OFFICE_P,tmp);
        if (!sendmsg("SPRN",'o',-1,0,"%s\n\n",tmp)) return(0);

        if (!sendmsg("SPRN",'o',-1,0,"%s\n",datestr(0))) return(0);
        if (!sendmsg("SPRN",'o',-1,0,"NAZWISKO  -  %s\n\n",G_uname)) return(0);

        strcpy(tmp,"0");
        while (stread(TRAN_S,smode)) {
            if (!stget(TRAN_S,CODE,prod)) return(0);
            cprod=atoi(prod);
            if (cprod==0) break;
            if (!stget(TRAN_S,QNTY,qnty)) return(0);
            qty=atoi(qnty);
            if (!stget(TRAN_S,AMNT,amnt)) return(0);
            if (getprod(atoi(prod))) {
                if (!stget(PROD_S,NAME,name)) return(0);
            }
            else {
                strcpy(name,prod);
            }
            if ((cprod==1)&&(lprod!=1)) {
                for (j=0;j<35;j++) if (!sendmsg("SPRN",'o',-1,0,"-")) return(0);
                if (!sendmsg("SPRN",'o',-1,0,"\n%-3d           RAZEM %-15s\n",q,mstr(tmp,15))) return(0);
            }
            if ((cprod==1)&&(lprod==1)) strcpy(name,"RESZTA");
            if (!sendmsg("SPRN",'o',-1,0,"%-3d %15.15s %-15s\n",qty,name,mstr(mulm(amnt,qty),15))) return(0);
            if ((cprod==1)&&(lprod==1)) if (!sendmsg("SPRN",'o',-1,0,"\n")) return(0);
            strcpy(tmp,addm(tmp,mulm(amnt,qty)));
            if (cprod!=1) q+=qty;
            lprod=cprod;
            smode=NEXT;
        }
        for (j=0;j<11;j++) if (!sendmsg("SPRN",'o',-1,0,"-")) return(0);
        if (!sendmsg("SPRN",'o',-1,0," DZIEKUJEMY ")) return(0);
        for (j=0;j<12;j++) if (!sendmsg("SPRN",'o',-1,0,"-")) return(0);
        for (j=0;j<13;j++) if (!sendmsg("SPRN",'o',-1,0,"\n")) return(0);
        sendmsg("SPRN",'E');
    }
    smode=FRST;
    strcpy(TRAN_S,STOK_S);
    tabl[0]='~';
    if (!strcmp(G_tb->sn,tabl)) {
        sendmsg("SPRN",'I');

        if (!sendmsg("SPRN",'o',-1,0,"%s\n",datestr(0))) return(0);
        if (!sendmsg("SPRN",'o',-1,0,"NAZWISKO  -  %s\n\n",G_uname)) return(0);
        if (!sendmsg("SPRN",'o',-1,0,"STAN POSIADANIA\n\n")) return(0);

        while (stread(tabl,smode)) {
            if (!stget(tabl,CODE,prod)) return(0);
            if (getprod(atoi(prod))) {
                if (!stget(PROD_S,NAME,name)) return(0);
            }
            else {
                strcpy(name,prod);
            }
            if (!stget(tabl,QNTY,qnty)) return(0);
            if (!stget(tabl,AMNT,amnt)) return(0);
            qty=atoi(qnty);
            if (!sendmsg("SPRN",'o',-1,0,"%-3d %15.15s %-15s\n",qty,name,mstr(amnt,15))) return(0);
            smode=NEXT;
        }
        for (j=0;j<13;j++) if (!sendmsg("SPRN",'o',-1,0,"\n")) return(0);
        sendmsg("SPRN",'E');
    }
    return(1);
}
//--------------------------------------------------------------------------
int sndfiles(void)
{
	char *buf;
	char *t,tmp[160],file[16];
	int i=0,j;
	buf=MALLOC(512);
	if (buf==NULL) return(0);
	memset(buf,0,512);
	strcpy(tmp,G_fupdate);
	t=strtok(tmp,", \t\r\n;");
	while (t!=NULL) {
		strcpy(buf+i,G_database);
		sprintf(file,"%s.*",t);
		j=sendmsg("DISK",'x',buf+i,file);
		if (j!=0) {
			i+=j;
			*(buf+i)=' ';
			i++;
		}
		t=strtok(NULL,", \t\r\n;");
	}
    i=sendmsg("LAN",'F',buf);
	FREE(buf);
    return(i);
}
int G_rtvradio='N';
//------------------------------------------------------------------------
int letdom(void)
{
    char local[2];
    int weight = 0;

    if (!yesno()) return(0);

    weight=atoi(G_formvars[G_form.curitem-1]);
    strcpy(local, G_formvars[G_form.curitem]);

    if (G_formvars[G_form.curitem][0]==G_yes) {
        if (weight < 21) {
            strcpy(G_formvars[G_form.curitem+1], "1000");
        } 
        else {
            if (weight < 251) {
                strcpy(G_formvars[G_form.curitem+1], "2000");
            } 
            else {
                if (weight < 501) {
                    strcpy(G_formvars[G_form.curitem+1], "2500");
                } 
                else {
                    strcpy(G_formvars[G_form.curitem+1], "3000");
                }
            }
        }
    }
    else {
        if (weight < 21){
            strcpy(G_formvars[G_form.curitem+1], "1500");
        } 
        else {
            if (weight < 251){
                strcpy(G_formvars[G_form.curitem+1], "2500");
            } 
            else {
                if (weight < 501) {
                    strcpy(G_formvars[G_form.curitem+1], "3000");
                } 
                else {
                    strcpy(G_formvars[G_form.curitem+1], "4000");
                }
            }
        }
    }

    stput(TRAN_S,AMNT,G_formvars[G_form.curitem+1]);
    
    return(1);
}
/*
** name LETDOMVA {
**     f[cf+1]=3000+(((f[cf]-50000)/10000)*600)
** }
*/
//--------------------------------------------------------------------------
int letdomva(void)
{
    long i;
    long value = 0;
    long fee = 3000;
    char feestr[20];

    value=atol(G_formvars[G_form.curitem]);

    for (i = value; i > 50000; i=i-10000) {
        fee = fee + 600;
    }

    ltoa(fee, feestr, 10);

    strcpy(G_formvars[G_form.curitem+1], feestr);
    
    return(1);
}
/* name LETDOMRG {
**     getprod(global(curprod))
**     f[cf+1]=product.amount
** }
*/
//--------------------------------------------------------------------------
int letdomrg(void)
{
    char amount[20];

    getprod(G_prod);
    if (!stget(PROD_S,AMNT,amount)) return(0);

    strcpy(G_formvars[G_form.curitem+1], amount);
    
    return(1);
}
//--------------------------------------------------------------------------
int pardom(void)
{
    int weight = 0;

    weight=atoi(G_formvars[G_form.curitem]);

    if (weight < 1001){                
        strcpy(G_formvars[G_form.curitem+1], "5000");
    }
    else {
        if (weight < 2001){
            strcpy(G_formvars[G_form.curitem+1], "7000");
        }
        else {
            if (weight < 5001) {
                strcpy(G_formvars[G_form.curitem+1], "12000");
            }
            else {
                if (weight < 10001) {
                    strcpy(G_formvars[G_form.curitem+1], "18000");
                }
                else {
                    strcpy(G_formvars[G_form.curitem+1], "25000");
                }
            }
        }
    }

    stput(TRAN_S,AMNT,G_formvars[G_form.curitem+1]);
    
    return(1);
}
//--------------------------------------------------------------------------
int pardomva(void)
{
    long i;
    long value = 0;
    long fee = 3000;
    char feestr[20];

    value=atol(G_formvars[G_form.curitem]);

    for (i = value; i > 50000; i=i-10000) {
        fee = fee + 600;
    }

    ltoa(fee, feestr, 10);

    strcpy(G_formvars[G_form.curitem+1], feestr);
    
    return(1);
}
//--------------------------------------------------------------------------
int mosnum(void)
{
    char tmp[8];
    int i;
    if (!getoffdet(COUNTERPOS,tmp)) return(0);
    sprintf(G_formvars[G_form.curitem+1],"%s/",tmp);
    if (G_qnty!=1) sprintf(G_formvars[G_form.curitem+2],"%s/",tmp);
    if (!getoffdet(OFFICE_MIN,tmp)) return(0);
    strcat(G_formvars[G_form.curitem+1],tmp);
    if (G_qnty!=1) {
        i=atoi(tmp)+G_qnty;
        sprintf(tmp,"%d",i-1);
        strcat(G_formvars[G_form.curitem+2],tmp);
    }
    return(1);
}
//--------------------------------------------------------------------------
int mornum(void)
{
    char tmp[8];
    int i;
    if (!getoffdet(COUNTERPOS,tmp)) return(0);
    sprintf(G_formvars[G_form.curitem+1],"%s/",tmp);
    if (G_qnty!=1) sprintf(G_formvars[G_form.curitem+2],"%s/",tmp);
    if (!getoffdet(OFFICE_MON,tmp)) return(0);
    strcat(G_formvars[G_form.curitem+1],tmp);
    if (G_qnty!=1) {
        i=atoi(tmp)+G_qnty;
        sprintf(tmp,"%d",i-1);
        strcat(G_formvars[G_form.curitem+2],tmp);
    }
    return(1);
}
//--------------------------------------------------------------------------
int mosfee(void)
{
    char name[21];
    char feestr[20];
    long fee,i;

    if (!getprod(G_prod)) return(0);
    if (!stget(PROD_S,NAME,name)) return(0);

    fee=atol(G_log[G_numt-1].val)*G_qnty;
    if (fee <= 10000L){
        fee = 1500L;
    } else {
        if (fee <= 30000L){
            fee = 2000L;
        } else {
            if (fee <= 50000L){
                fee = 3000L;
            } else {
                if (fee <= 100000L){
                    fee = 6000L;
                } else {
                    if (fee <= 200000L){
                        fee = 12000L;
                    } else {
                        if (fee <= 500000L){
                            fee = 18000L;
                        } else {
                            if (fee <= 1000000L){
                                fee = 30000L;
                            } else {
                                if (fee <= 1500000L){
                                    fee = 40000L;
                                } else {
                                    i=fee;
                                    fee = 40000L;
                                    for (; i > 1500000L; i=i-500000){
                                         fee = fee+10000L;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ltoa((fee/G_qnty), feestr, 10);
    add2log(name,feestr," "," "," ");
    displog(G_tindex);
    return(1);
}

//--------------------------------------------------------------------------
int mocalamt(void)
{
    long amt;

    amt=atol(G_formvars[G_form.curitem]);

    if (((amt%100L) != 0)||(amt < 100)) {
        beep();
        amt-=amt%100L;
        if (amt < 100) amt=100;
        sprintf(G_formvars[G_form.curitem],"%ld",amt);
        G_form.curitem--;
        return(0);
    } 
    else {
        sprintf(G_formvars[G_form.curitem],"%ld",amt);
    }
    return(1);
}
//--------------------------------------------------------------------------
int mosamt(void)
{
    char tmp[20];
    char name[21];

    if (!getprod(G_prod)) return(0);
    if (!stget(PROD_S,NAME,name)) return(0);
    if (mocalamt()) {
        sprintf(tmp,"%d",G_qnty);
        add2log(name,divm(G_formvars[G_form.curitem],tmp),G_formvars[G_form.curitem-3],G_formvars[G_form.curitem-2],G_formvars[G_form.curitem-1]);
        if (!getoffdet(OFFICE_MIN,tmp)) return(0);
        sprintf(tmp,"%d",atoi(tmp)+G_qnty);
        if (!setoffdet(OFFICE_MIN,tmp)) return(0);
    }
    return(1);
}
//--------------------------------------------------------------------------
int moramt(void)
{
    char tmp[80];
    char name[21];
    char val[20];
    if (!getprod(G_prod)) return(0);
    if (!stget(PROD_S,NAME,name)) return(0);
    if (mocalamt()) {
        sprintf(tmp,"%s%s",G_formvars[G_form.curitem-4],G_formvars[G_form.curitem-3]);
        sprintf(val,"%d",G_qnty);
        add2log(name,subm("0",divm(G_formvars[G_form.curitem],val)),G_formvars[G_form.curitem-5],tmp,G_formvars[G_form.curitem-2]);
        if (!getoffdet(OFFICE_MON,tmp)) return(0);
        sprintf(tmp,"%d",atoi(tmp)+G_qnty);
        if (!setoffdet(OFFICE_MON,tmp)) return(0);
    }
    return(1);
}
//---------------------------------------------------
int mosvalid(void)
{
    char monum[9];
    int i,poslen, numlen;

    strcpy(monum, G_formvars[G_form.curitem]);


    poslen = strlen(strtok(monum, "/"));
    if (poslen > 2) {
        beep();
        G_form.curitem--;
        return(0);
    } else {
        for (i=0; i<poslen; i++){
            if (!isdigit(monum[i])) {
                beep();
                G_form.curitem--;
                return(0);
            }
        }
    }

    numlen = strlen(&monum[++i]);
    if (numlen==0 || numlen>5) {
        beep();
        G_form.curitem--;
        return(0);
    } else {
        for (i=1; i<=numlen; i++){
            if (!isdigit(monum[i+poslen])) {
                beep();
                G_form.curitem--;
                return(0);
            }
        }
    }    
    return(1);
}


//---------------------------------------------------
int rtvperio(void)
{
    stput(TRAN_S,ADF2,duedom(32));
    return(1);
}
int eneperio(void)
{
    stput(TRAN_S,ADF2,duedom(15));
    return(1);
}


//---------------------------------------------------
int rtvamt(void)
{
    char amounts[80];
    if (!yesno()) return(0);

    if (!getprod(G_prod)) return(0);
    if (!stget(PROD_S,AMNT,amounts)) return(0);

    G_rtvradio=G_formvars[G_form.curitem][0];
    if (G_formvars[G_form.curitem][0] == G_yes) {     /* radio only */
        if (!getprod(1209)) return(0);
        if (!stget(PROD_S,AMNT,amounts)) return(0);
    }
    else {
        if (!getprod(1206)) return(0);
        if (!stget(PROD_S,AMNT,amounts)) return(0);
    }

    if (G_formvars[G_form.curitem-1][0] == G_yes) {   /* single month */
        strcpy(amounts,divm(amounts,"2"));
    }

    stput(TRAN_S,AMNT,amounts);
    strcpy(G_formvars[G_form.curitem+1],amounts);
    return(1);
}
int rtvnew(void)
{
    char amounts[80];
    char name[80];


    if (G_rtvradio == G_yes) {     /* radio only */
        G_prod=1208;
    }

    if (!getprod(G_prod)) return(0);
    if (!stget(PROD_S,AMNT,amounts)) return(0);
    if (!stget(PROD_S,NAME,name)) return(0);

    add2log(name,amounts," "," "," ");

    return(1);
}


//---------------------------------------------------
int rtvmonth(void)
{
    int mi;

    if ((mi=months(G_formvars[G_form.curitem-1], datestr(MINDATE))) < 0) {
        mi=0;
    }

    sprintf(G_formvars[G_form.curitem+1],"%d",mi);

    return(1);
}


//---------------------------------------------------
int rtvlate(void)
{
    char feestr[20];
    int mi;
    long fee;

    mi= atoi(G_formvars[G_form.curitem]);
    fee= atol(G_formvars[G_form.curitem-1]);

    if (mi == 0) {
         fee = 0L;
    } else {
        if (mi < 3){
            fee = (long) fee*2/10;
        } else {
            if (mi < 5){                
                fee = (long) fee*3/10;
            } else {
                if (mi < 7){                
                    fee = (long) fee*4/10;
                } else {
                    fee = (long) fee*5/10;
                }
            }
        }
    }

    ltoa(fee, feestr, 10);
    strcpy(G_formvars[G_form.curitem+1], feestr);
    return(1);
}

//---------------------------------------------------
int telperio(void)
{
    stput(TRAN_S,ADF2,duedom(15));
    return(1);
}


//---------------------------------------------------
int teldays(void)
{
    int di;
    char tmp[80];
    strcpy(tmp,datestr(MINDATE));
    if ((di=days(G_formvars[G_form.curitem-1], tmp)) < 0) {
        di=0;
    }

    sprintf(G_formvars[G_form.curitem+1],"%d",di);
    return(1);
}


//---------------------------------------------------
int tellate(void)
{
    int di;

    di= atoi(G_formvars[G_form.curitem]);
    strcpy(G_formvars[G_form.curitem+1],divm(mulm(G_formvars[G_form.curitem-1],di*16),"10000"));
    return(1);
}


//---------------------------------------------------
int traperio(void)
{
    char tmp1[10],tmp2[10];
    sprintf(tmp1,"%02d0415",getyear(datestr(MINDATE)));
    sprintf(tmp2,"%02d0915",getyear(datestr(MINDATE)));
    stput(TRAN_S,ADF2,duehalf(tmp1,tmp2));
    return(1);
}


//---------------------------------------------------
int tradays(void)
{
    int di;

    if (yesno() == 0)
    {
        return(0);
    }
    if ((di=days(G_formvars[G_form.curitem-2], datestr(MINDATE))) < 0) {
        di=0;
    }

    sprintf(G_formvars[G_form.curitem+1],"%d",di);
    return(1);
}
//---------------------------------------------------
int tralate(void)
{
    int di;

    di= atoi(G_formvars[G_form.curitem]);
    strcpy(G_formvars[G_form.curitem+1],divm(mulm(G_formvars[G_form.curitem-2],di*2),"1000"));

    if (G_formvars[G_form.curitem-1][0] == G_yes) {
        strcpy(G_formvars[G_form.curitem+1],divm(G_formvars[G_form.curitem+1],"2"));
    }
    return(1);
}
//---------------------------------------------------
int pzuperio(void)
{
    char tmp1[10],tmp2[10];
    sprintf(tmp1,"%02d0415",getyear(datestr(MINDATE)));
    sprintf(tmp2,"%02d0915",getyear(datestr(MINDATE)));
    stput(TRAN_S,ADF2,duehalf(tmp1,tmp2));
    return(1);
}
//---------------------------------------------------
int pzudays(void)
{
    int di;

    if ((di=days(G_formvars[G_form.curitem-1], datestr(MINDATE))) < 0) {
        di=0;
    }
    sprintf(G_formvars[G_form.curitem+1],"%d",di);
    return(1);
}


//---------------------------------------------------
int pzulate(void)
{
    int di;

    di= atoi(G_formvars[G_form.curitem]);
    strcpy(G_formvars[G_form.curitem+1],
        divm(mulm(G_formvars[G_form.curitem-1],di*16),"10000"));
    return(1);
}


//---------------------------------------------------
int enedays(void)
{
    int di;
    if ((di=days(G_formvars[G_form.curitem-1], datestr(MINDATE))) < 0) {
        di=0;
    }
    sprintf(G_formvars[G_form.curitem+1],"%d",di);
    return(1);
}
//---------------------------------------------------
int enelate(void)
{
    int di;

    di= atoi(G_formvars[G_form.curitem]);
    strcpy(G_formvars[G_form.curitem+1],divm(mulm(G_formvars[G_form.curitem-1],di*3),"1000"));
    return(1);
}
//---------------------------------------------------
int enefee(void)
{
    char name[21];
    char feestr[20];
    long fee;
    if (!getprod(G_prod)) return(0);
    if (!stget(PROD_S,NAME,name)) return(0);

    fee=atol(G_log[G_numt-1].val);
    if (fee <= 10000L){
        fee =  800L;
    } else {
        if (fee <= 30000L){
            fee = 1200L;
        } else {
            if (fee <= 50000L){
                fee = 1600L;
            } else {
                if (fee <= 100000L){
                    fee = 3100L;
                } else {
                    if (fee <= 200000L){
                        fee =  5200L;
                    } else {
                        if (fee <= 500000L){
                            fee =  7800L;
                        } else {
                            if (fee <= 1000000L){
                                fee = 10000L;
                            } else {
                                fee = fee/100L;
                            }
                        }
                    }
                }
            }
        }
    }

    sprintf(feestr,"%ld",fee);
    add2log(name,feestr," "," "," ");
    displog(G_tindex);
    return(1);
}

//---------------------------------------------------
int renid(void)
{
    if (!stsrchp("account",2,FRST)) {
        G_form.curitem--;
        beep();
        return(0);
    }
    return(1);
}
//---------------------------------------------------
int renamt(void)
{
    char name[21];

    if (!getprod(G_prod)) return(0);
    if (!stget(PROD_S,NAME,name)) return(0);
    add2log(name,G_formvars[G_form.curitem],G_formvars[G_form.curitem-1]," "," ");
    stput(TRAN_S,ADF1,G_formvars[G_form.curitem-1]);
    return(1);
}
//---------------------------------------------------
int renfee(void)
{

    char name[21];
    char feestr[20];
    long fee,i;

    if (!getprod(G_prod)) return(0);
    if (!stget(PROD_S,NAME,name)) return(0);

    fee=atol(G_log[G_numt-1].val);
    if (fee <= 10000L){
        fee =  800L;
    } else {
        if (fee <= 30000L){
            fee = 1200L;
        } else {
            if (fee <= 50000L){
                fee = 1600L;
            } else {
                if (fee <= 100000L){
                    fee = 3100L;
                } else {
                    if (fee <= 200000L){
                        fee =  5200L;
                    } else {
                        if (fee <= 500000L){
                            fee =  7800L;
                        } else {
                            if (fee <= 1000000L){
                                fee = 10000L;
                            } else {
                                fee = fee/100L;
                            }
                        }
                    }
                }
            }
        }
    }
    sprintf(feestr,"%ld",fee);
    add2log(name,feestr,G_log[G_numt-1].a[0]," "," ");
    displog(G_tindex);
    return(1);
}
//---------------------------------------------------
int bankfee(void)
{

    char name[21];
    char feestr[20];
    long fee,i;

    if (!getprod(G_prod)) return(0);
    if (!stget(PROD_S,NAME,name)) return(0);

    fee=atol(G_log[G_numt-1].val);
    if (fee<=200000L) {
        fee=1000L;
    }
    else {
        fee/=200L;
    }
    sprintf(feestr,"%ld",fee);
    add2log(name,feestr,G_log[G_numt-1].a[0]," "," ");
    displog(G_tindex);
    return(1);
}
//---------------------------------------------------
int acctstop(void)
{
    char tmp[10];

    sprintf(tmp,"%sACCT",G_formvars[G_form.curitem-1]);
    strlwr(tmp);

    if (!stexist(tmp)) return(1);

    if (inrange(tmp,G_formvars[G_form.curitem])) {
        G_form.curitem--;
        beep();
        errorline(G_stoplist,1);
        return(0);
    }
    return(1);
}
int cheqstop(void)
{
    char tmp[10];

    sprintf(tmp,"%sCHEQ",G_formvars[G_form.curitem-2]);
    strlwr(tmp);

    if (!stexist(tmp)) return(1);

    if (inrange(tmp,G_formvars[G_form.curitem])) {
        G_form.curitem--;
        beep();
        errorline(G_stoplist,1);
        return(0);
    }
    return(1);
}
//---------------------------------------------------
int pkoacct(void)
{
    if (!stexist("pkoacct")) return(1);
    if (inrange("pkoacct",G_formvars[G_form.curitem])) {
        G_form.curitem--;
        beep();
        errorline(G_stoplist,1);
        return(0);
    }
    return(1);
}
//---------------------------------------------------
int custid(void)
{
    if (!stexist("custid")) return(1);
    if (inrange("custid",G_formvars[G_form.curitem])) {
        G_form.curitem--;
        beep();
        errorline(G_stoplist,1);
        return(0);
    }
    return(1);
}
//---------------------------------------------------
int pkowamt(void)
{
    long amt;
    long bal;
    char name[21];

    bal=atol(G_formvars[G_form.curitem-1]);
    amt=atol(G_formvars[G_form.curitem]);

    if (amt <= bal){
        if (amt > 1000000L) {
            beep();
            amt=1000000L;
            sprintf(G_formvars[G_form.curitem],"%ld",amt);
            G_form.curitem--;
            return(0);
        }
    }
    else {                          /* amt > bal */
        beep();
        sprintf(G_formvars[G_form.curitem],"%ld",bal);
        if (bal > 1000000L) {
            amt=1000000L;
            sprintf(G_formvars[G_form.curitem],"%ld",amt);
        }
        G_form.curitem--;
        return(0);
    }

    if (!getprod(G_prod)) return(0);
    if (!stget(PROD_S,NAME,name)) return(0);
    add2log(name,subm("0",G_formvars[G_form.curitem]),G_formvars[G_form.curitem-3],G_formvars[G_form.curitem-2],G_formvars[G_form.curitem-1]);
    sublast2();
    return(1);
}


int pkoposwi(void)
{
   int x;
   x = atoi(G_formvars[G_form.curitem]);
   if((x > 0) && (x < 8))
   {
      if(p4566(0,x)) beep();
      G_form.curitem--;
   }
   return(0);
}
  
int pkoposde(void)
{
   int x;
   x = atoi(G_formvars[G_form.curitem]);
   if((x > 0) && (x < 8))
   {
      if(p4566(1,x)) beep();
      G_form.curitem--;
   }
   return(0);
 } 

int addcheq(void)
{
    char name[21];
    char tmp[20];
    char a[2][40];

    if (!getprod(G_prod)) return(0);
    if (!stget(PROD_S,NAME,name)) return(0);
    strcpy(tmp,"0");
    strcpy(tmp,subm(tmp,G_formvars[G_form.curitem]));
    sprintf(a[0],"%s - %s",G_formvars[G_form.curitem-5],G_formvars[G_form.curitem-3]);
    sprintf(a[1],"%s - %s",G_formvars[G_form.curitem-2],G_formvars[G_form.curitem-1]);
    add2log(name,tmp,a[0],a[1],G_formvars[G_form.curitem-4]);
    displog(0);
    return(1);
}
int prbar(void)
{
	sendmsg("OUTPUT2",'C',G_formvars[G_form.curitem-1],G_formvars[G_form.curitem]);
	return(1);
}

