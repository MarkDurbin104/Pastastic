#define CONFIG_C

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <io.h>
#include <malloc.h>
#include <fcntl.h>
#include <ctype.h>

#include <sys\timeb.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "types.h"
#include "config.h"
#include "message.h"
#include "translog.h"
#include "function.h"
#include "formhand.h"
#include "dst.h"
#include "control.h"

void setvar(CHAR **s,CHAR *v)
{
	ENTRY(28);
	if (*s!=NULL) FREE(*s);
	*s=STRDUP(v);
	RETURN;
}
void clrvar(CHAR **s)
{
	ENTRY(29);
	if (*s!=NULL) FREE(*s);
	*s=NULL;
	RETURN;
}
// set all default values for global strings
void loaddefaults(CHAR *sys)
{
	static INT in=0;
	ENTRY(30);
	if (!in) {
    	setvar(&G_system    , sys           );
    	setvar(&G_cache     , "1"           );
    	setvar(&G_moneys    , "œ"           );
    	setvar(&G_moneyf    , "-999,99~.99" );
    	setvar(&G_weights   , "Kg"          );
    	setvar(&G_weightf   , "-9~.999"     );
    	setvar(&G_database  , ".\\"         );
    	setvar(&G_config    , ".\\"         );
    	setvar(&G_scrname   , "VGA"         );
    	setvar(&G_kbdfile   , "UKAT.KBD"    );
    	setvar(&G_harderr   , "REPLACE DISK FOR USER");
    	setvar(&G_noacc     , "ACCESS DENIED");
    	setvar(&G_nopass    , "INVALID PASSWORD");
    	setvar(&G_offdets   , "GPA.OFF"     );
    	setvar(&G_insertd   , "INSERT A DISK AND PRESS A KEY (F10 TO EXIT)");
    	setvar(&G_newdisk   , "READY TO FORMAT NEW DISK Y/N (F10 TO EXIT)");
    	setvar(&G_olddisk   , "DO YOU WISH TO OVERWRITE THIS CLERK DISK Y/N (F10 TO EXIT)");
    	setvar(&G_format    , "FORMATTING DISK PLEASE WAIT");
    	setvar(&G_formatf   , "DISK UNUSABLE PLEASE TRY ANOTHER DISK");
    	setvar(&G_formatok  , "NEW DISK READY FOR USE BY CLERK");
    	setvar(&G_posierr   , "YOU MUST FIRST LOGOFF AT POSITION");
    	setvar(&G_stoplist  , "STOPPED");
    	setvar(&G_newdata   , "NEW DATA TRANSFERED");
    	setvar(&G_revprmt   , "INSERT SUPERVISOR DISK AND ENTER PASSWORD:");
    	setvar(&G_clrstok   , "DO YOU WANT TO ZERO ALL YOUR STOCK:");
    	setvar(&G_netpath   , "\\");
    	setvar(&G_none      , "NONE");
    	setvar(&G_name      , "DEFAULT");
    	setvar(&G_base      , ".\\");
    	setvar(&G_wallpaper , "NONE");
    	setvar(&G_exact     , "USE EXACT CHANGE");
    	setvar(&G_dispwgt   , "KG. GM.");
    	strcpy(G_textfile   , ".\\"         );
    	strcpy(G_fontfile   , "STANDARD.FNT");
    	strcpy(G_langfiles[0], "GPALANG.DEF");
    	strcpy(G_days[0]   , "SUN"         );
    	strcpy(G_days[1]   , "MON"         );
    	strcpy(G_days[2]   , "TUE"         );
    	strcpy(G_days[3]   , "WED"         );
    	strcpy(G_days[4]   , "THUR"        );
    	strcpy(G_days[5]   , "FRI"         );
    	strcpy(G_days[6]   , "SAT"         );
    	strcpy(G_mnths[ 0] , "JAN"         );
    	strcpy(G_mnths[ 1] , "FEB"         );
    	strcpy(G_mnths[ 2] , "MAR"         );
    	strcpy(G_mnths[ 3] , "APR"         );
    	strcpy(G_mnths[ 4] , "MAY"         );
    	strcpy(G_mnths[ 5] , "JUNE"        );
    	strcpy(G_mnths[ 6] , "JUL"         );
    	strcpy(G_mnths[ 7] , "AUG"         );
    	strcpy(G_mnths[ 8] , "SEPT"        );
    	strcpy(G_mnths[ 9] , "OCT"         );
    	strcpy(G_mnths[10] , "NOV"         );
    	strcpy(G_mnths[11] , "DEC"         );
		G_denoms[0]=1; G_denoms[1]=5; G_denoms[2]=10; G_denoms[3]=25; G_denoms[4]=100;
		G_numhopp=5;
		in=1;
	}
	RETURN;
}
void clrconfig(void)
{
	ENTRY(31);
	clrvar(&G_cache);    clrvar(&G_system);   clrvar(&G_moneys);
	clrvar(&G_scrname);	 clrvar(&G_toname);   clrvar(&G_moneyf);
	clrvar(&G_weightf);  clrvar(&G_weights);  clrvar(&G_database);
	clrvar(&G_databas2); clrvar(&G_config);   
	clrvar(&G_backup);   clrvar(&G_kbdfile);
	clrvar(&G_harderr);  clrvar(&G_noacc);    clrvar(&G_nopass);
	clrvar(&G_offdets);  clrvar(&G_insertd);  clrvar(&G_newdisk);
	clrvar(&G_olddisk);  clrvar(&G_format);   clrvar(&G_formatf);
	clrvar(&G_formatok); clrvar(&G_posierr);  clrvar(&G_stoplist);
	clrvar(&G_newdata);  clrvar(&G_revprmt);  clrvar(&G_clrstok);
	clrvar(&G_netpath);  clrvar(&G_rupdate);  clrvar(&G_none);
	clrvar(&G_name);     clrvar(&G_base);     clrvar(&G_topline);
	clrvar(&G_thankyou); clrvar(&G_total);    clrvar(&G_clerk);
	clrvar(&G_fupdate);	 clrvar(&G_wallpaper); clrvar(&G_dispwgt);
	clrvar(&G_exact);
	RETURN;
}
// read the configuration information
INT readconfig(CHAR *sys)
{
    FILE *fp;
    INT i;
    CHAR tmp[161],*s;
	ENTRY(40);

    loaddefaults(sys);
    sprintf(tmp,"%s.cfg",sys);

    fp=fopen(tmp,"r");
    if (fp==NULL) RETURNV(0);

    while (fgets(tmp,160,fp)!=NULL) {
        s=strtok(tmp," ");
        if (s!=NULL) {
            for (i=0;i<NUMCONFIG;i++) if (!strcmp(G_confs[i],s)) break;
            if (i!=NUMCONFIG) {
                switch (i) {
                    case 0 :   // SYSTEM
                        s=strtok(NULL," \n");
                        if (s!=NULL) setvar(&G_system,s);
                        break;
                    case 1 :   // CACHE   
                        s=strtok(NULL," \n");
                        if (s!=NULL) setvar(&G_cache,s);
                        break;
                    case 6 :   // DATABASE
                        s=strtok(NULL," \n");
                        if (s!=NULL) setvar(&G_database,s);
                        break;
                    case 7 :   // CONFIG  
                        s=strtok(NULL," \n");
                        if (s!=NULL) setvar(&G_config,s);
                        break;
                    case 8 :   // LANG
						G_numlang=0;
                        while ((G_numlang<10)&&((s=strtok(NULL," \t\n"))!=NULL)) {
	                        strcpy(G_langfiles[G_numlang++],s);
						}
                        G_canswitch=G_numlang>1;
                        break;
                    case 9 :   // BACKUP  
                        s=strtok(NULL," \n");
                        if (s!=NULL) setvar(&G_backup,s);
                        break;
                    case 16 :  // OFFICE
                        s=strtok(NULL," \n");
                        if (s!=NULL) setvar(&G_offdets,s);
                        break;

                    case 26 :  // KEYDISK
                        s=strtok(NULL," \n");
                        if (s!=NULL) G_keydisk=atoi(s);
                        break;

                    case 32 :  // NETWORK
                        s=strtok(NULL," \n");
                        if (s!=NULL) {
                            switch(atoi(s)) {
                                case 1 :
//                                    G_network=LOCALSHARE|OTHERNET;
                                    G_semnet=0;
                                    break;
                                case 2 :
//                                    G_network=NOTONNET;
                                    G_semnet=1;
                                    break;
                                default :
//                                    G_network=NOTONNET;
                                    G_semnet=0;
                            }
                        }
                        break;

                    case 33 :  // NETPATH
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            setvar(&G_netpath,s);
                        }
                        break;

                    case 34 :  // RUPDATE
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            setvar(&G_rupdate,s);
                        }
                        break;

                    case 35 :  // FUPDATE
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            setvar(&G_fupdate,s);
                        }
                        break;

                    case 36 :  // TONAME
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            setvar(&G_toname,s);
                        }
                        break;

                    case 37 :  // DEBUG
                        s=strtok(NULL," \t\n");
                        *G_debug=atoi(s);
                        break;

                    case 42 :  // SERVER
                        s=strtok(NULL," \t\n");
                        G_isserver=atoi(s);
                        break;
                    case 47 :  // ONLYHOT
                        s=strtok(NULL," \n");
                        G_onlyhot=(CHAR)atoi(s);
                        break;
                	case 49 :  // REFSON
                        s=strtok(NULL," \n");
                        G_refson=atoi(s);
                    	break;
					case 51 : // WEIGHTAT
                        s=strtok(NULL," \n");
                        G_weighton=1;
                        G_weightat[0]=atoi(s);
                        s=strtok(NULL," \n");
                        G_weightat[1]=atoi(s);
                        s=strtok(NULL," \n");
                        G_weightat[2]=atoi(s);
                    	break;
					case 52 : // COINAT
                        s=strtok(NULL," \n");
                        G_coinon=1;
                        G_coinat[0]=atoi(s);
                        s=strtok(NULL," \n");
                        G_coinat[1]=atoi(s);
                        s=strtok(NULL," \n");
                        G_coinat[2]=atoi(s);
                    	break;
					case 53 : // DENOMS
						G_numhopp=0;
                        s=strtok(NULL," ,\n");
						while (s!=NULL) {
							G_denoms[G_numhopp++]=(CHAR)atoi(s);
                        	s=strtok(NULL," ,\n");
						}
                    	break;
					case 56 : // ERRORLAT
                        s=strtok(NULL," \n");
                        if (s!=NULL) G_elineat=atoi(s);
                        s=strtok(NULL," \n");
                        if (s!=NULL) G_elinecl=atoi(s);
                        s=strtok(NULL," \n");
                        if (s!=NULL) G_elinesz=atoi(s);
                        if ((G_elinesz<1)||(G_elinesz>3)) G_elinesz=3;
                    	break;
					case 57 : // CALCAT
						G_calcon=1;
                        s=strtok(NULL," \n");
                        G_calcxpos=atoi(s);
                        s=strtok(NULL," \n");
                        G_calcypos=atoi(s);
                    	break;
                    case 58 :  // DEBON
                        s=strtok(NULL," \t\n");
                        G_debon=atoi(s);
                        break;
                    case 59 :  // PALETTE
                        s=strtok(NULL,",. \t\n");
                        i=atoi(s);
                        if ((i<15)&&(i>=0)) {
                            i*=3;
                            s=strtok(NULL,",. \t\n");
                            if (s!=NULL) G_palentry[i++]=(CHAR)atoi(s);
                            s=strtok(NULL,",. \t\n");
                            if (s!=NULL) G_palentry[i++]=(CHAR)atoi(s);
                            s=strtok(NULL,",. \t\n");
                            if (s!=NULL) G_palentry[i]=(CHAR)atoi(s);
                        }
                        break;
                    case 60 :  // SWAPSIZE
                        s=strtok(NULL,",. \t\n");
                        i=atoi(s);
                        if ((i>1)&&(i<30)) G_swapsize=i;
                        break;
                }
            }
        }
    }
    fclose(fp);
#ifndef __DPMI32__
	loadsdata(G_system);
#endif
	RETURNV(readlang(0));
}
void langln(CHAR *tmp)
{
    INT i,j;
    CHAR *s;
	ENTRY(50);
    s=strtok(tmp," ");
    if (s!=NULL) {
        for (i=0;i<NUMCONFIG;i++) if (!strcmp(G_confs[i],s)) break;
        if (i!=NUMCONFIG) {
            switch (i) {
                case 2 :   // MONEY   
                    s=strtok(NULL,":");
                    if (s!=NULL) {
	                    while (*s==' ') s++;
						setvar(&G_moneys,s);
					}
                    s=strtok(NULL,":\n");
                    if (s!=NULL) setvar(&G_moneyf,s);
                    break;
                case 3 :   // WEIGHT  
                    s=strtok(NULL,":");
                    if (s!=NULL) {
	                    while (*s==' ') s++;
						setvar(&G_weights,s);
					}
                    s=strtok(NULL,":");
                    if (s!=NULL) setvar(&G_weightf,s);
                    s=strtok(NULL,":\n");
                    if (s!=NULL) G_scaleout=atoi(s);
                    break;
                case 4 :   // DAYS      
                    for (j=0;j<7;j++) {
                        s=strtok(NULL," ,\n");
                        if (s!=NULL) strcpy(G_days[j],s);
                    }
                    break;
                case 5 :   // MONTHS  
                    for (j=0;j<12;j++) {
                        s=strtok(NULL," ,\n");
                        if (s!=NULL) strcpy(G_mnths[j],s);
						s=G_mnths[j];
						while ((*s)&&((*s<'0')||(*s>'9'))) s++;
						if (*s) { G_dpm[j]=(CHAR)atoi(s); *s=0; }
                    }
                    break;
                case 10 :  // FONT
                    s=strtok(NULL," \n");
                    if (s!=NULL) strcpy(G_fontfile,s);
                    break;
                case 11 :  // SCREEN
                    s=strtok(NULL," \n");
                    if (s!=NULL) {
						G_multilang=0;
						setvar(&G_scrname,s);
#ifndef ONLY_ME
//						asigndev(G_scrname,"OUTPUT1",'S');
#endif
					}
                    while ((s=strtok(NULL," \n"))!=NULL) {
						G_multilang=1;
#ifndef ONLY_ME
//						asigndev(s,"OUTPUT1",'+');
#endif
					}
                    break;
                case 12 :  // KEYBOARD
                    s=strtok(NULL," \n");
                    if (s!=NULL) setvar(&G_kbdfile,s);
                    break;
                case 13 :  // HARDERR
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_harderr,s);
                    }
                    break;
                case 14 :  // NOACCESS
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_noacc,s);
                    }
                    break;
                case 15 :  // NOPASS
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_nopass,s);
                    }
                    break;
                case 17 :  // INSERTD
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_insertd,s);
                    }
                    break;
                case 18 :  // NEWDISK
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_newdisk,s);
                    }
                    break;
                case 19 :  // OLDDISK
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_olddisk,s);
                    }
                    break;
                case 20 :  // FORMAT
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_format,s);
                    }
                    break;
                case 21 :  // FORMATF
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_formatf,s);
                    }
                    break;
                case 22 :  // FORMATOK
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_formatok,s);
                    }
                    break;

                case 23 :  // YES-NO
                    s=strtok(NULL," \n");
                    if (s!=NULL) G_yes=(*s)&0xFF;
                    s=strtok(NULL," \n");
                    if (s!=NULL) G_no=(*s)&0xFF;
                    break;

                case 24 :  // POSIERR
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_posierr,s);
                    }
                    break;

                case 25 :  // STOPLIST
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_stoplist,s);
                    }
                    break;
                case 27 :  // NEWDATA
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_newdata,s);
                    }
                    break;

                case 28 :   // TEXT    
                    s=strtok(NULL," \n");
                    if (s!=NULL) {
                        strcpy(G_textfile,s);
                    }
                    break;

                case 29 :  // REVPROMP
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_revprmt,s);
                    }
                    break;

                case 30 :   // ROUNDTO   
                    s=strtok(NULL," \n");
                    if (s!=NULL) G_roundval=atoi(s);
                    break;

                case 31 :  // CLRSTOK
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
                        setvar(&G_clrstok,s);
                    }
                    break;

                case 38 :  // NONE
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
						setvar(&G_none,s);
					}
                    break;
                case 39 :  // NAME
                    s=strtok(NULL," \n");
                    if (s!=NULL) setvar(&G_name,s);
                    break;
                case 40 :  // BASE
                    s=strtok(NULL," \n");
                    if (s!=NULL) setvar(&G_base,s);
                    break;
                case 41 :  // DATETYPE
                    s=strtok(NULL," \n");
					if (s!=NULL) {
                    	switch (*s) {
							case 'h' :
							case 'H' :
								G_datetype=HEGIRA;
		                    	break;
							case 'c' :
							case 'C' :
								G_datetype=CHINESE;
		                    	break;
							case 'j' :
							case 'J' :
								G_datetype=JULIAN;
		                    	break;
							case 'p' :
							case 'P' :
								G_datetype=PERSIAN;
		                    	break;
							case 'g' :
							case 'G' :
							default :
								G_datetype=GREGORIAN;
						}
                    	s=strtok(NULL," \n");
						if (s!=NULL) strcpy(G_dateorder,s);
					}
                   	break;
                case 43 :  // TOPLINE 
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
						setvar(&G_topline,s);
					}
                    break;
                case 44 :  // THANKYOU
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
						setvar(&G_thankyou,s);
					}
                    break;
                case 45 :  // TOTAL   
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
						setvar(&G_total,s);
					}
                    break;
                case 46 :  // CLERK   
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
						setvar(&G_clerk,s);
					}
                    break;
#ifndef __DPMI32__
                case 48 :  // DBM2
                    s=strtok(NULL," \t\n");
                    if (s!=NULL) setvar(&G_databas2,s);
                    s=strtok(NULL," \t\n");
					while (s!=NULL) {
						if ((j=snum(s))!=(-1)) G_dbmap[j]=1;
	                    s=strtok(NULL," \t\n");
					}
                    break;
#endif
                case 50 :  // WALLPAPER
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
						setvar(&G_wallpaper,s);
					}
                    break;
                case 54 :  // EXACT
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
						setvar(&G_exact,s);
					}
                    break;
                case 55 :  // DISPWGT
                    s=strtok(NULL,"\n");
                    if (s!=NULL) {
                        while (*s==' ') s++;
						setvar(&G_dispwgt,s);
					}
                    break;
#ifndef __DPMI32__
                    case 61 :  // MEMSTORE
                        s=strtok(NULL," ,\t\n");
					    while (s!=NULL) {
						    if ((j=snum(s))>(-1)) G_msmap[j]=1;
	                        s=strtok(NULL," ,\t\n");
					    }
                        break;
#endif
                    case 62 :  // PRINTER
                        s=strtok(NULL," ,\t\n");
						if (s!=NULL) strcpy(G_printdef,s);
                        break;
            }
        }
    }
	RETURN;
}
INT readlang(INT lang)
{
    INT fd;
    CHAR tmp[161];
	CHAR *s,*t;
	INT  l,*ll;

	ENTRY(60);
    if (G_langspace==NULL) {
        G_langspace=MALLOC(10*sizeof(CHAR*));
        for (l=0;l<10;l++) G_langspace[l]=NULL;
    }
    if (G_langspace[lang]==NULL) {
    	fd=open(G_langfiles[lang],O_RDONLY|O_BINARY);
    	if (fd==(-1)) RETURNV(0);
		l=(INT)filelength(fd);
		G_langspace[lang]=MALLOC(l+sizeof(INT)+1);
        memset(G_langspace[lang],0,l+sizeof(INT)+1);
		if (G_langspace[lang]==NULL) {
			close(fd);
			RETURNV(0);
		}
		if (read(fd,G_langspace[lang]+sizeof(INT),l)!=l) {
			close(fd);
			RETURNV(0);
		}
		close(fd);
        ll=(INT *)G_langspace[lang];
        *ll=l;
    }
    s=G_langspace[lang]+sizeof(INT);

	while (*s) {
		t=s;
		while ((*s)&&((*s!='\n')&&(*s!='\r'))) s++;
		*(s++)=0;
		s++;
		strcpy(tmp,t);
		langln(tmp);
	}
	RETURNV(1);
}
INT getday(CHAR *dt)
{
	ENTRY(70);
    RETURNV(((dt[4]-'0')*10)+(dt[5]-'0'));
}
INT getmon(CHAR *dt)
{
	ENTRY(80);
    RETURNV(((dt[2]-'0')*10)+(dt[3]-'0'));
}
INT getyear(CHAR *dt)
{
	ENTRY(90);
    RETURNV(((dt[0]-'0')*10)+(dt[1]-'0'));
}
void orddto(INT *y,INT *m,INT *d)
{
	INT ret[3];
	INT i;
	ENTRY(100);
	for (i=0;i<3;i++) {
		switch (G_dateorder[i]) {
			case 'Y' :
			case 'y' :
				ret[i]=*y;
				break;
			case 'M' :
			case 'm' :
				ret[i]=*m;
				break;
			case 'D' :
			case 'd' :
				ret[i]=*d;
				break;
		}
	}
	*y=ret[0];
	*m=ret[1];
	*d=ret[2];
	RETURN;
}
void orddfrom(INT *y,INT *m,INT *d)
{
	INT ret[3];
	INT i;
	ENTRY(110);
 	ret[0]=*y;
	ret[1]=*m;
	ret[2]=*d;
	for (i=0;i<3;i++) {
		switch (G_dateorder[i]) {
			case 'Y' :
			case 'y' :
				*y=ret[i];
				break;
			case 'M' :
			case 'm' :
				*m=ret[i];
				break;
			case 'D' :
			case 'd' :
				*d=ret[i];
				break;
		}
	}
	RETURN;
}
ULONG memleft(void)
{
	ENTRY(115);
#ifndef __DPMI32__
    RETURNV(sendmsg("OSSDEV",MESSAGE_fm));
#else
    RETURNV(0L);
#endif
}
// RETURN a string containing the current date/time according to 'type'
CHAR *datestr(INT type) 
{
    static CHAR tmp[80],*s;
    static struct tm *t;
    static struct timeb tb;
	LONG l;
    UINT i,dd,dpy,tdpy,dd1,xit=0;
    INT year,mon,day;
#ifdef WIEN
    static INT millitm=0;
    static time_t last_time=0;
#endif//WIEN

	ENTRY(120);
	if (type<0) {
		dd=0-type;
		type=CALCDATE;
	} else {
    	ftime(&tb);
#ifdef WIEN
	if (tb.time==last_time)
	    millitm=tb.millitm=(millitm+10)%1000;
	else {
	    last_time=tb.time;
	    millitm=tb.millitm=0;
	    }
#endif//WIEN
		t=localtime(&tb.time);
		year=t->tm_year;
    	if (year<50) year+=100;
    	year-=80;
    	dd=(365*year);
    	dd+=year/4;
    	if (((year%4)==0)&&(t->tm_mon<2)) dd--;
    	for (i=0;i<t->tm_mon;i++) dd+=G_gdpm[i];
    	dd+=t->tm_mday;
	}

	switch (G_datetype) {
		case PERSIAN :
			dd1=dd;
			dpy=0;
		    for (i=0;i<G_nummon;i++) dpy+=G_dpm[i];
			dd1-=PERSTART;
			year=PERYEAR;
			do {
				tdpy=dpy;
				if (((year-PERYEAR)%4)==0) tdpy++;
				if (dd1>=tdpy) {
					dd1-=tdpy;
					year++;
				} else {
					xit=1;
				}
			} while (!xit);

			t->tm_mon=0;
			if (((year-PERYEAR)%4)==0) G_dpm[11]++;
			while (dd1>=G_dpm[t->tm_mon]) dd1-=G_dpm[t->tm_mon++];
			if (((year-PERYEAR)%4)==0) G_dpm[11]--;
			t->tm_mday=dd1+1;
			break;
		case HEGIRA :
			dpy=0;
		    for (i=0;i<G_nummon;i++) dpy+=G_dpm[i];
			dd1=dd-HEGSTART;
			year=HEGYEAR+(dd1/dpy);
			t->tm_mon=0;
			while (dd1>=G_dpm[t->tm_mon]) { dd1-=G_dpm[t->tm_mon]; t->tm_mon++; }
			t->tm_mday=dd1+1;
			break;
		case CHINESE :
		case GREGORIAN :
			if (type==CALCDATE) {
				dd1=dd;
				dpy=365;
				dd1-=GREGSTART;
				year=GREGYEAR;
				do {
					tdpy=dpy;
					if ((year%4)==0) tdpy++;
					if (dd1>=tdpy) {
						dd1-=tdpy;
						year++;
					} else {
						xit=1;
					}
				} while (!xit);

				t->tm_mon=0;
				if ((year%4)==0) G_gdpm[1]=29;
				while (dd1>=G_gdpm[t->tm_mon]) dd1-=G_gdpm[t->tm_mon++];
				if ((year%4)==0) G_gdpm[1]=28;
				t->tm_mday=dd1+1;
			} else {
				if (G_datetype==CHINESE) {
					year+=CHINYEAR;
				} else {
					year+=GREGYEAR;
				}
			}
			break;
	}
    switch (type) {
        case CALCDATE : //-1
			year%=100;
			mon=t->tm_mon+1;
			day=t->tm_mday;
	 		orddto(&year,&mon,&day);
            sprintf(tmp,"%02d%02d%02d",year,mon,day);
            break;
        case MINDT :    // 10
            sprintf(tmp,"%02d/%02d/%02d %02d:%02d",t->tm_mday,t->tm_mon+1,year%100,t->tm_hour,t->tm_min,t->tm_sec);
            break;
        case MINDATE :  // 8
			year%=100;
			mon=t->tm_mon+1;
			day=t->tm_mday;
#ifndef WIEN
//This function seems to turn the date around, but we need the format "YYMMDD"
	 		orddto(&year,&mon,&day);
#endif //WIEN
            sprintf(tmp,"%02d%02d%02d",year,mon,day);
            break;
        case UKDATE :   // 2
            sprintf(tmp,"%02d-%02d-%02d",t->tm_mday,t->tm_mon+1,year%100);
            break;
        case USDATE :   // 3
            sprintf(tmp,"%02d-%02d-%02d",t->tm_mon+1,t->tm_mday,year%100);
            break;
        case MINTIME :  // 9
            sprintf(tmp,"%02d%02d%02d%02d",t->tm_hour,t->tm_min,t->tm_sec,tb.millitm/10);
            break;
        case TIMES :    // 4
            sprintf(tmp,"%02d:%02d:%02d.%02d",t->tm_hour,t->tm_min,t->tm_sec,tb.millitm/10);
            break;
        case TIMEM :    // 5
            sprintf(tmp,"%02d:%02d",t->tm_hour,t->tm_min);
            break;
        case UKDATEL :  // 6
            sprintf(tmp,"%02d-%02d-%4d",t->tm_mday,t->tm_mon+1,year);
            break;
        case USDATEL :  // 7
            sprintf(tmp,"%02d-%02d-%4d",t->tm_mon+1,t->tm_mday,year);
            break;
        case LOCDATES : // 1
            sprintf(tmp,"%s %s %2d  %4d",G_days[t->tm_wday],G_mnths[t->tm_mon],t->tm_mday,year);
            break;
        case NUMDAYS :  // 11
            sprintf(tmp,"%d",dd);
            break;
        case 1000 :
            sprintf(tmp,"%s %s %2d, %4d  %02d:%02d:%02d",G_days[t->tm_wday],G_mnths[t->tm_mon],t->tm_mday,year,t->tm_hour,t->tm_min,t->tm_sec);
            break;
        case LOCDATEL2 ://12
            sprintf(tmp,"%s %2d %s %4d   %02d:%02d",G_days[t->tm_wday],t->tm_mday,G_mnths[t->tm_mon],year,t->tm_hour,t->tm_min);
			break;
        case 13 :       // memory
#ifdef __TURBOC__
            if (G_sstat!=NULL) {
                strcpy(tmp,"STORES:");
                s=tmp+7;
                for (i=0;i<15;i++) {
                    if (G_sstat[i].err) {
                        sprintf(s,"%02d=%03d ",i,G_sstat[i].err);
                        s+=7;
                    }
                }
                sprintf(s,"%ld ",memleft());
            } else {
    			l=G_sstart-_SP;
                sprintf(tmp,"Stk=%ld Free=%ld Used=%ld",l,memleft(),G_curmem,G_maxmem);
            }
#else 
            sprintf(tmp,"Stk=%d Free=%ld Used=%ld",stackavail(),memleft(),G_curmem,G_maxmem);
#endif 
			break;
        case 14 :   //??
			tmp[0]=0;
			break;
        case 15 :   //  day of week
            sprintf(tmp,"%d",t->tm_wday);
            break;
        case 16 :  // DDMM
			year%=100;
			mon=t->tm_mon+1;
			day=t->tm_mday;
	 		orddto(&year,&mon,&day);
            sprintf(tmp,"%02d%02d",day,mon);
            break;
        case 17 : // DDMMYY
			year%=100;
			mon=t->tm_mon+1;
			day=t->tm_mday;
	 		orddto(&year,&mon,&day);
            sprintf(tmp,"%02d%02d%02d",day,mon,year);
            break;
        default : //
			year%=100;
			mon=t->tm_mon+1;
			day=t->tm_mday;
#ifdef WIEN
         sprintf(tmp,"%s., %2d. %s. %4d  %2d:%02d",G_days[t->tm_wday],t->tm_mday,G_mnths[t->tm_mon],year,t->tm_hour,t->tm_min);
#else 
         sprintf(tmp,"%s %s %2d, %4d  %02d:%02d",G_days[t->tm_wday],G_mnths[t->tm_mon],t->tm_mday,year,t->tm_hour,t->tm_min);
#endif
    }
    RETURNV(tmp);
}
UINT datetonum(CHAR *dt)
{
    INT i;
    UINT dd;
    INT d,m,y,dpy;
    
	ENTRY(130);
    d=getday (dt);
    m=getmon (dt);
    y=getyear(dt);

	orddfrom(&y,&m,&d);
	switch (G_datetype) {
		case PERSIAN :
			dpy=0;
		    for (i=0;i<G_nummon;i++) dpy+=G_dpm[i];
			dd=PERSTART;
		    if (y<(PERYEAR%100)) y+=100;
			y-=PERYEAR%100;
		    dd+=(dpy*y);
		    dd+=y/4;
		    if ((y%4)==0) dd--;
		    for (i=0;i<m-1;i++) dd+=G_dpm[i];
		    dd+=d;
			break;
		case HEGIRA :
			dpy=0;
		    for (i=0;i<G_nummon;i++) dpy+=G_dpm[i];
			dd=HEGSTART;
		    if (y<(HEGYEAR%100)) y+=100;
			y-=HEGYEAR%100;
		    dd+=(dpy*y);
		    for (i=0;i<m-1;i++) dd+=G_dpm[i];
		    dd+=d;
			break;
		case CHINESE :
			y+=(GREGYEAR-CHINYEAR)-1900;
		case GREGORIAN :
			dpy=365;
		    if (y<50) y+=100;
		    y-=GREGYEAR%100;
		    dd=(dpy*y);
		    dd+=y/4;
		    if (((y%4)==0)&&(m<3)) dd--;
		    for (i=0;i<m-1;i++) dd+=G_gdpm[i];
		    dd+=d;
			break;
	}
	RETURNV(dd);
}
// read the keyboard information into memory
INT *readkeys(void)
{
    INT fd;
	ENTRY(140);
   	fd=open(G_kbdfile,O_RDONLY|O_BINARY);
   	if (fd==(-1)) {
       	RETURNV(NULL);
   	}
   	if (G_keyspace==NULL) G_keyspace=MALLOC(MAPSIZE);
   	if (G_keyspace!=NULL) {
       	read(fd,G_keyspace,MAPSIZE);
   	}
   	close(fd);
    RETURNV(G_keyspace);
}
// read the office details information into memory
INT readoffdet(void)
{
    INT fd;
    OFFICED office;

	ENTRY(150);
    fd=open(G_offdets,O_RDONLY|O_BINARY);
    if (fd==(-1)) RETURNV(0);
    if (read(fd,&office,sizeof(OFFICED))!=sizeof(OFFICED)) RETURNV(0);
    close(fd);
    memcpy(&G_office,&office,sizeof(OFFICED));
    G_office.set=1;
    G_position=(UCHAR)atoi(G_office.cpos);

    RETURNV(1);
}
// write the office details information from memory
INT writeoffdet(void)
{
    INT fd;

	ENTRY(160);
    G_office.set=1;
    fd=open(G_offdets,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
    if (fd==(-1)) RETURNV(0);
    if (write(fd,&G_office,sizeof(OFFICED))!=sizeof(OFFICED)) RETURNV(0);
    close(fd);

    RETURNV(1);
}
// change some detail in the office information
INT setoffdet(CHAR type,CHAR *det)
{
	ENTRY(170);
    switch (type) {
        case OFFICE_N :
            strcpy(G_office.name,det);
            break;
        case OFFICE_L :
            strcpy(G_office.loc,det);
            break;
        case OFFICE_P :
            strcpy(G_office.postc,det);
            break;
        case OFFICE_LD :
            strcpy(G_office.lastd,det);
            break;
        case OFFICE_MON :
            strcpy(G_office.mon,det);
            break;
        case OFFICE_MIN :
            strcpy(G_office.min,det);
            break;
        case COUNTERPOS :
            G_position=(UCHAR)atoi(det);
            strcpy(G_office.cpos,det);
            break;
    }
    if (!writeoffdet()) RETURNV(0);
    G_office.set=1;

    RETURNV(1);
}
// get some detail in the office information
INT getoffdet(CHAR type,CHAR *det)
{
	ENTRY(180);
    if (!G_office.set) RETURNV(0);
    switch (type) {
        case OFFICE_N :
            strcpy(det,G_office.name);
            break;
        case OFFICE_L :
            strcpy(det,G_office.loc);
            break;
        case OFFICE_P :
            strcpy(det,G_office.postc);
            break;
        case OFFICE_LD :
            strcpy(det,G_office.lastd);
            break;
        case OFFICE_MON :
            strcpy(det,G_office.mon);
            break;
        case OFFICE_MIN :
            strcpy(det,G_office.min);
            break;
        case COUNTERPOS :
            strcpy(det,G_office.cpos);
            G_position=(UCHAR)atoi(det);
            break;
    }

    RETURNV(1);
}
