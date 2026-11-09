#define CONFIG_C

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <io.h>
#include <alloc.h>
#include <fcntl.h>
#include <pxengine.h>

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
// set all default values for global strings
void loaddefaults(char *sys)
{
    strcpy(G_system    , sys           );
    strcpy(G_cache     , "1"           );
    strcpy(G_moneys    , "œ"           );
    strcpy(G_moneyf    , "-999,99~.99" );
    strcpy(G_weights   , "Kg"          );
    strcpy(G_weightf   , "-9~.999"     );
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
    strcpy(G_database  , ".\\"         );
    strcpy(G_config    , ".\\"         );
    strcpy(G_textfile1 , ".\\"         );
    strcpy(G_textfile2 , ".\\"         );
    strcpy(G_fontfile  , "STANDARD.FNT");
    strcpy(G_scrname   , "VGA"         );
    strcpy(G_kbdfile   , "UKAT.KBD"    );
    strcpy(G_harderr   , "REPLACE DISK FOR USER");
    strcpy(G_noacc     , "ACCESS DENIED");
    strcpy(G_nopass    , "INVALID PASSWORD");
    strcpy(G_offdets   , "GPA.OFF"     );
    strcpy(G_insertd   , "INSERT A DISK AND PRESS A KEY (F10 TO EXIT)");
    strcpy(G_newdisk   , "READY TO FORMAT NEW DISK Y/N (F10 TO EXIT)");
    strcpy(G_olddisk   , "DO YOU WISH TO OVERWRITE THIS CLERK DISK Y/N (F10 TO EXIT)");
    strcpy(G_format    , "FORMATTING DISK PLEASE WAIT");
    strcpy(G_formatf   , "DISK UNUSABLE PLEASE TRY ANOTHER DISK");
    strcpy(G_formatok  , "NEW DISK READY FOR USE BY CLERK");
    strcpy(G_posierr   , "YOU MUST FIRST LOGOFF AT POSITION");
    strcpy(G_stoplist  , "STOPPED");
    strcpy(G_newdata   , "NEW DATA TRANSFERED");
    strcpy(G_revprmt   , "INSERT SUPERVISOR DISK AND ENTER PASSWORD:");
    strcpy(G_clrstok   , "DO YOU WANT TO ZERO ALL YOUR STOCK:");
    strcpy(G_netpath   , "\\");
    strcpy(G_none      , "NONE");
}
// read the configuration information
int readconfig(char *sys)
{
    FILE *fp;
    int i,j;
    char tmp[81],*s;
    LOG('E',M_CONFIG,2);

    loaddefaults(sys);
    G_store=MALLOC(NUMSTORES*sizeof(STORE));
    if (G_store==NULL) RETURN(0);
    G_lib=MALLOC(NUMLIBITEM*sizeof(LSTOREF));
    if (G_lib==NULL) RETURN(0);

    G_text=MALLOC(1000*sizeof(char *));
    if (G_text==NULL) RETURN(0);
    G_tname=MALLOC(1000*sizeof(char *));
    if (G_tname==NULL) RETURN(0);

    sprintf(tmp,"%s.cfg",sys);

    fp=fopen(tmp,"r");
    if (fp==NULL) RETURN(0);

    while (fgets(tmp,80,fp)!=NULL) {
        s=strtok(tmp," ");
        if (s!=NULL) {
            for (i=0;i<NUMCONFIG;i++) if (!strcmp(G_confs[i],s)) break;
            if (i!=NUMCONFIG) {
                switch (i) {
                    case 0 :   // SYSTEM
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_system,s);
                        break;
                    case 1 :   // CACHE   
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_cache,s);
                        break;
                    case 2 :   // MONEY   
                        s=strtok(NULL," :");
                        if (s!=NULL) strcpy(G_moneys,s);
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_moneyf,s);
                        break;
                    case 3 :   // WEIGHT  
                        s=strtok(NULL," :");
                        if (s!=NULL) strcpy(G_weights,s);
                        s=strtok(NULL,":");
                        if (s!=NULL) strcpy(G_weightf,s);
                        s=strtok(NULL," \n");
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
                        }
                        break;
                    case 6 :   // DATABASE
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_database,s);
                        break;
                    case 7 :   // CONFIG  
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_config,s);
                        break;
                    case 8 :   // TEXT1    
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_textfile1,s);
                        s=strtok(NULL," \n");
                        if (s!=NULL)
                            strcpy(&G_textfile1[strlen(G_textfile1)+1],s);
                        else
                            G_textfile1[strlen(G_textfile1)+1]=0;
                        break;
                    case 9 :   // BACKUP  
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_backup,s);
                        break;
                    case 10 :  // FONT
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_fontfile,s);
                        break;
                    case 11 :  // SCREEN
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_scrname,s);
                        break;
                    case 12 :  // KEYBOARD
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_kbdfile,s);
                        break;
                    case 13 :  // HARDERR
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_harderr,s);
                        }
                        break;
                    case 14 :  // NOACCESS
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_noacc,s);
                        }
                        break;
                    case 15 :  // NOPASS
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_nopass,s);
                        }
                        break;
                    case 16 :  // OFFICE
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_offdets,s);
                        break;
                    case 17 :  // INSERTD
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_insertd,s);
                        }
                        break;
                    case 18 :  // NEWDISK
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_newdisk,s);
                        }
                        break;
                    case 19 :  // OLDDISK
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_olddisk,s);
                        }
                        break;
                    case 20 :  // FORMAT
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_format,s);
                        }
                        break;
                    case 21 :  // FORMATF
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_formatf,s);
                        }
                        break;
                    case 22 :  // FORMATOK
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_formatok,s);
                        }
                        break;
                    case 23 :  // YES-NO
                        s=strtok(NULL," \n");
                        if (s!=NULL) G_yes=*s;
                        s=strtok(NULL," \n");
                        if (s!=NULL) G_no=*s;
                        break;

                    case 24 :  // POSIERR
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_posierr,s);
                        }
                        break;

                    case 25 :  // STOPLIST
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_stoplist,s);
                        }
                        break;

                    case 26 :  // KEYDISK
                        s=strtok(NULL," \n");
                        if (s!=NULL) G_keydisk=atoi(s);
                        break;

                    case 27 :  // NEWDATA
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_newdata,s);
                        }
                        break;

                    case 28 :   // TEXT2    
                        s=strtok(NULL," \n");
                        if (s!=NULL) {
                            strcpy(G_textfile2,s);
                            G_canswitch=1;
                            s=strtok(NULL," \n");
                            if (s!=NULL)
                                strcpy(&G_textfile2[strlen(G_textfile2)+1],s);
                            else
                                G_textfile2[strlen(G_textfile2)+1]=0;
                        }
                        break;

                    case 29 :  // REVPROMP
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_revprmt,s);
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
                            strcpy(G_clrstok,s);
                        }
                        break;

                    case 32 :  // NETWORK
                        s=strtok(NULL," \n");
                        if (s!=NULL) {
                            switch(atoi(s)) {
                                case 1 :
                                    G_network=LOCALSHARE|OTHERNET;
                                    G_semnet=0;
                                    break;
                                case 2 :
                                    G_network=NOTONNET;
                                    G_semnet=1;
                                    break;
                                default :
                                    G_network=NOTONNET;
                                    G_semnet=0;
                            }
                        }
                        break;

                    case 33 :  // NETPATH
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_netpath,s);
                        }
                        break;

                    case 34 :  // RUPDATE
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_rupdate,s);
                        }
                        break;

                    case 35 :  // FUPDATE
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strcpy(G_fupdate,s);
                        }
                        break;

                    case 36 :  // TONAME
                        s=strtok(NULL,"\n");
                        if (s!=NULL) {
                            while (*s==' ') s++;
                            strncpy(G_toname,s,16);
                        }
                        break;

                    case 37 :  // DEBUG
                        s=strtok(NULL," \n");
                        G_debug=atoi(s);
                        break;
                    case 38 :  // NONE
                        s=strtok(NULL," \n");
                        if (s!=NULL) strcpy(G_none,s);
                        break;
                }
            }
        }
    }
    fclose(fp);
    strcpy(G_textfile,G_textfile1);
    RETURN(1);         
}
// return a string containing the current date/time according to 'type'
char *datestr(int type) 
{
    static char tmp[80];
    struct tm *t;
    struct timeb tb;
    int i,dd;

    ftime(&tb);
    t=localtime(&tb.time);

    switch (type) {
        case MINDT :
            sprintf(tmp,"%02d%02d%02d-%02d%02d%02d",t->tm_mday,t->tm_mon+1,t->tm_year,t->tm_hour,t->tm_min,t->tm_sec);
            break;
        case MINDATE :
            sprintf(tmp,"%02d%02d%02d",t->tm_year,t->tm_mon+1,t->tm_mday);
            break;
        case UKDATE :
            sprintf(tmp,"%02d-%02d-%02d",t->tm_mday,t->tm_mon+1,t->tm_year);
            break;
        case USDATE :
            sprintf(tmp,"%02d-%02d-%02d",t->tm_mon+1,t->tm_mday,t->tm_year);
            break;
        case MINTIME :
            sprintf(tmp,"%02d%02d%02d%02d",t->tm_hour,t->tm_min,t->tm_sec,tb.millitm/10);
            break;
        case TIMES :
            sprintf(tmp,"%02d:%02d:%02d.%02d",t->tm_hour,t->tm_min,t->tm_sec,tb.millitm/10);
            break;
        case TIMEM :
            sprintf(tmp,"%02d:%02d",t->tm_hour,t->tm_min);
            break;
        case UKDATEL :
            sprintf(tmp,"%02d-%02d-%4d",t->tm_mday,t->tm_mon+1,t->tm_year+1900);
            break;
        case USDATEL :
            sprintf(tmp,"%02d-%02d-%4d",t->tm_mon+1,t->tm_mday,t->tm_year+1900);
            break;
        case LOCDATES :
            sprintf(tmp,"%s %s %2d  %4d",G_days[t->tm_wday],G_mnths[t->tm_mon],t->tm_mday,t->tm_year+1900);
            break;
        case NUMDAYS :
            if (t->tm_year<50) t->tm_year+=100;
            t->tm_year-=80;
            dd=(365*t->tm_year);
            dd+=t->tm_year/4;
            if (((t->tm_year%4)==0)&&(t->tm_mon<2)) dd--;
            for (i=0;i<t->tm_mon;i++) dd+=G_dpm[i];
            dd+=t->tm_mday;
            sprintf(tmp,"%d",dd);
            break;
        case 1000 :
            sprintf(tmp,"%s %s %2d, %4d  %02d:%02d:%02d",G_days[t->tm_wday],G_mnths[t->tm_mon],t->tm_mday,t->tm_year+1900,t->tm_hour,t->tm_min,t->tm_sec);
            break;
        default :
            sprintf(tmp,"%s %s %2d, %4d  %02d:%02d",G_days[t->tm_wday],G_mnths[t->tm_mon],t->tm_mday,t->tm_year+1900,t->tm_hour,t->tm_min);
    }
    RETURN(tmp);
}
// read the font information into memory
char *readfont(void)
{
    int fd;
    fd=open(G_fontfile,O_RDONLY|O_BINARY);
    if (fd==(-1)) {
        return(NULL);
    }
    if (G_fontspace!=NULL) FREE(G_fontspace);
    G_fontspace=MALLOC(FONTSIZE);
    if (G_fontspace!=NULL) {
		memset(G_fontspace,0,FONTSIZE);
        read(fd,G_fontspace,FONTSIZE);
    }
    close(fd);
    return(G_fontspace);
}
// read the keyboard information into memory
int *readkeys(void)
{
    int fd;
    fd=open(G_kbdfile,O_RDONLY|O_BINARY);
    if (fd==(-1)) {
        return(NULL);
    }
    if (G_keyspace!=NULL) FREE(G_keyspace);
    G_keyspace=MALLOC(MAPSIZE);
    if (G_keyspace!=NULL) {
        read(fd,G_keyspace,MAPSIZE);
    }
    close(fd);
    return(G_keyspace);
}
// read the office details information into memory
int readoffdet(void)
{
    int fd;
    OFFICED office;

    fd=open(G_offdets,O_RDONLY|O_BINARY);
    if (fd==(-1)) return(0);
    if (read(fd,&office,sizeof(OFFICED))!=sizeof(OFFICED)) return(0);
    close(fd);
    memcpy(&G_office,&office,sizeof(OFFICED));
    G_office.set=1;
    G_position=atoi(G_office.cpos);

    return(1);
}
// write the office details information from memory
int writeoffdet(void)
{
    int fd;

    G_office.set=1;
    fd=open(G_offdets,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
    if (fd==(-1)) return(0);
    if (write(fd,&G_office,sizeof(OFFICED))!=sizeof(OFFICED)) return(0);
    close(fd);

    return(1);
}
// change some detail in the office information
int setoffdet(char type,char *det)
{
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
            G_position=atoi(det);
            strcpy(G_office.cpos,det);
            break;
    }
    if (!writeoffdet()) return(0);
    G_office.set=1;

    return(1);
}
// get some detail in the office information
int getoffdet(char type,char *det)
{
    if (!G_office.set) return(0);
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
            G_position=atoi(det);
            break;
    }

    return(1);
}
