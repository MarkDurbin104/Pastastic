#include <dos.h>
#include <time.h>
#include <memory.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <direct.h>
#include <process.h>
#include "keynames.h"
#include <stdlib.h>       
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <malloc.h>

#define COUNTVALUE (-6000)
#define COUNTVALS  (-6001)

int G_keybuf[20000];
int G_keylen=0;
int inrep[20]={(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),
               (-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1)};
int inmin  [20]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int instart[20]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int inmax  [20]={0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,
               0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF};
int inwidth[20]={3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3};
int ininc  [20]={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
int replevel=0;
int keystroke(char *s)
{
	int retval=0;
	int l,i;
	l=strlen(s);
	if (l==1) {
		retval=(int)*s;
	} else {
		i=0;
		while (G_keyname[i]!=NULL) {
			if (!strncmp(s,G_keyname[i],l)) {
				retval=i-176;
				break;
			}
			i++;
		}
	}
	return retval;
}
void buffer(int k)
{
    G_keybuf[G_keylen++]=k;
}
void buffers(char *series)
{
    while ((*series)&&(*series!='"')) {
        buffer((int)*series);
        series++;
    }
}
void bufferk(char *key)
{
    int keycode;
    char *series=key;
    while ((*series)&&(*series!='>')) series++;
    if (*series) *series=0;
    keycode=keystroke(key);
    if (keycode) {
        buffer(keycode);
    }
}
int doline(char *line)
{
    char *s;
    char tmp[20];
    int replen,i,j;
    int repend,istart;
    s=strtok(line," \t");
    while (s!=NULL) {
        switch (*s) {
            case '\'':
                buffer((int)*(s+1));
                break;
            case '"':
                buffers(s+1);
                break;
            case 'P' :
                if (!strcmp(s,"PAUSE")) {
                    s=strtok(NULL," \r\n\t");
                    if (s==NULL) return 0;
                    buffer(10000);
                    buffer(atoi(s));
                }
                break;
            case 'C' :
                if (!strcmp(s,"COUNT") && inrep[replevel]==(-1)) {
                     buffer(COUNTVALUE);
                     for (i=1;i<inwidth[replevel-1];i++) {
                        buffer('0');
                     }
                } else if (!strcmp(s,"COUNTVALS") && inrep[replevel]==(-1)) {
                     if ((s=strtok(NULL," \t"))!=NULL) inmin  [replevel-1]=atoi(s);
                     if ((s=strtok(NULL," \t"))!=NULL) inmax  [replevel-1]=atoi(s);
                     if ((s=strtok(NULL," \t"))!=NULL) instart[replevel-1]=atoi(s);
                     if ((s=strtok(NULL," \t"))!=NULL) ininc  [replevel-1]=atoi(s);
                     if ((s=strtok(NULL," \t"))!=NULL) inwidth[replevel-1]=atoi(s);
                     if (ininc[replevel-1]==0) ininc[replevel-1]=1;
                     if (inmin[replevel-1]>inmax[replevel-1]) {
                        i=inmin[replevel-1];
                        inmin[replevel-1]=inmax[replevel-1];
                        inmax[replevel-1]=i;
                     }
                }
                break;
            case 'R' :
                if (!strcmp(s,"REPEAT") && inrep[replevel]==(-1)) {
                    s=strtok(NULL," \r\n\t");
                    if (s==NULL) return 0;
                    inrep[replevel++]=G_keylen;
                }
                break;
            case '}' :
                if ((replevel>0)&&(inrep[replevel-1]!=(-1))) {
                    s=strtok(NULL," \r\n\t");
                    if (s==NULL) return 0;
                    replen=atoi(s)-1;
                    repend=G_keylen;
                    istart=instart[replevel-1];
                    for (i=0;i<replen;i++) {
                        istart+=ininc[replevel-1];
                        if (ininc[replevel-1]<0) {
                            if (istart<inmin[replevel-1]) istart=inmax[replevel-1];
                        } else {
                            if (istart>inmax[replevel-1]) istart=inmin[replevel-1];
                        }
                        for (j=inrep[replevel-1];j<repend;j++) {
                            if (G_keybuf[j]==COUNTVALUE) {
                                if (istart<0) {
                                    sprintf(tmp,"%*.*d",inwidth[replevel-1]-1,inwidth[replevel-1]-1,istart);
                                } else {
                                    sprintf(tmp,"%*.*d",inwidth[replevel-1],inwidth[replevel-1],istart);
                                }
                                buffers(tmp);
                                j+=inwidth[replevel-1]-1;
                            } else {
                                buffer(G_keybuf[j]);
                            }
                        }
                    }
                    for (j=inrep[replevel-1];j<repend;j++) {
                        if (G_keybuf[j]==COUNTVALUE) {
                            if (instart[replevel-1]<0) {
                                sprintf(tmp,"%*.*d",inwidth[replevel-1]-1,inwidth[replevel-1]-1,instart[replevel-1]);
                            } else {
                                sprintf(tmp,"%*.*d",inwidth[replevel-1],inwidth[replevel-1],instart[replevel-1]);
                            }
                            for (i=0;i<inwidth[replevel-1];i++) {
                                G_keybuf[j+i]=tmp[i];
                            }
                        }
                    }
                    replevel--;
                    inrep[replevel]=(-1);
                    inmin  [replevel]=0;
                    instart[replevel]=0;
                    inmax  [replevel]=0x7FFF;
                    inwidth[replevel]=3;
                    ininc  [replevel]=1;
                }
                break;
            case ':' :
                return 1;
            case '<' :
                bufferk(s+1);
                break;
        }
        s=strtok(NULL," \t");
    }
    return 1;
}
int interp(char *file,int display)
{
    char tmp[200];
    FILE *fp;
    if ((fp=fopen(file,"r"))!=NULL) {
        while (fgets(tmp,200,fp)!=NULL) {
            while ((tmp[strlen(tmp)-1]=='\n')||(tmp[strlen(tmp)-1]=='\r')) tmp[strlen(tmp)-1]=0;
            if (display) printf("%s",tmp);
            if (!doline(tmp)) {
                fclose(fp);
                return 0;
            }
        }
        fclose(fp);
        return 1;
    }
    return 0;
}
int output(char *file)
{
    FILE *fp;
    if ((fp=fopen(file,"w"))!=NULL) {
        fwrite(G_keybuf,G_keylen,sizeof(int),fp);
        fclose(fp);
        return 1;
    }
    return 0;
}
int main(int argc,char *argv[])
{
    if (argc<3) return 1;
    if (interp(argv[1],argc==4)) output(argv[2]); else return 1;
    return 0;
}
