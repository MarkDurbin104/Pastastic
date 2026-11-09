#define SCVCS_C
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <dos.h>
#include <ctype.h>
#include <alloc.h>
#include <dir.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <sys\timeb.h>

#define FILEATTR    FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DIRATTR     FA_DIREC
#define NOACCESS    FA_RDONLY
#define WRACCESS    FA_NORMAL

char ln1[260];
char ln2[260];
int  G_recurse=0;
char G_sys[80]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
char G_dir[80]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
char G_usr[80]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
char G_path[80]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int  G_numf=0;
char *G_files[100];

// return a string containing dt=0-time HH:MM:SS dt=1=date DD/MM/YY
char *datestr(int dt) 
{
    static char dtmp[20];
    static char ttmp[20];
    struct tm *t;
    struct timeb tb;
    ftime(&tb);
    t=localtime(&tb.time);
    if (dt) {
        sprintf(dtmp,"%02d/%02d/%02d",t->tm_mday,t->tm_mon+1,t->tm_year);
        return(dtmp);
    }
    sprintf(ttmp,"%02d:%02d:%02d",t->tm_hour,t->tm_min,t->tm_sec);
    return(ttmp);
}
// strip directory and file if part return the directory else return the filename
char *strip(char *str,int part)
{
    char s[80];
    char *t=s;

    strcpy(s,str);

    t+=strlen(s);
    while ((t!=s)&&(*t!='\\')) t--;
    if (t!=s) t++;
    if (part) {
        if (t!=s) {
            *t=0;
            t=s;
            return(t);
        }
        else {
            return(".\\");
        }
    }
    return(t);
}
// return TRUE if file exists
int exists(char *file)
{
    struct REGPACK r;
    r.r_ax=0x4300;
    r.r_ds=FP_SEG(file);
    r.r_dx=FP_OFF(file);
    intr(0x21,&r);
    if (r.r_flags&1) return(0);
    return(1);
}
char *freefile(char *orig)
{
    static char new[80];
    int i;
    char tmp[20];
    char *t;

    strcpy(tmp,orig);
    t=&tmp[strlen(tmp)];
    while ((*t!='.')&&(t!=tmp)) t--;
    if (*t!='.') strcat(tmp,"._"); else *(t+2)=0;
    for (i=0;i<256;i++) {
        sprintf(new,"%s%s%02X",G_path,tmp,i);
        if (!exists(new)) return(new);
    }
    strcpy(tmp,orig);
    t=&tmp[strlen(tmp)];
    while ((*t!='.')&&(t!=tmp)) t--;
    if (*t!='.') strcat(tmp,"."); else *(t+1)=0;
    for (i=256;i<4096;i++) {
        sprintf(new,"%s%s%03X",G_path,tmp,i);
        if (!exists(new)) return(new);
    }
    return(new);
}
char *allfiles(char *orig)
{
    static char tmp[80];
    char *t;

    strcpy(tmp,orig);
    t=&tmp[strlen(tmp)];
    while ((*t!='.')&&(t!=tmp)) t--;
    if (*t!='.') strcat(tmp,"._*"); else { *(t+2)='*'; *(t+3)=0; }
    return(tmp);
}
// return true if files n1 and n2 are the same
int compfiles(char *n1,char *n2) {
    int fd,i;
    unsigned int nb;
    long csum1=0L,csum2=0L,*buf,*b;
    fd=open(n1,O_RDONLY|O_BINARY);
    if (fd!=(-1)) {
        buf=malloc(60000U);
        if (buf!=NULL) {
            memset(buf,0,60000U);
            while ((nb=read(fd,buf,60000U))>0) {
                nb+=sizeof(long)-1;
                nb/=sizeof(long);
                b=buf;
                for (i=0;i<nb;i++) csum1+=*b++;
                memset(buf,0,60000U);
            }
            free(buf);
        }
        close(fd);
    }
    fd=open(n2,O_RDONLY|O_BINARY);
    if (fd!=(-1)) {
        buf=malloc(60000U);
        if (buf!=NULL) {
            memset(buf,0,60000U);
            while ((nb=read(fd,buf,60000U))>0) {
                nb+=sizeof(long)-1;
                nb/=sizeof(long);
                b=buf;
                for (i=0;i<nb;i++) csum2+=*b++;
                memset(buf,0,60000U);
            }
            free(buf);
        }
        close(fd);
    }
    return(csum1==csum2);
}
// compare two files n1=new n2=old and generate a rebuild control file
void transfiles(char *n1,char *n2)
{
    FILE *fp1,*fp2,*output;
    int i,rl,t;
    fpos_t fo,fn;
    unsigned fc1=0,s=0;
    char *of=freefile(strip(n1,0));
    output=fopen(of,"w");
    fp2=fopen(n2,"r");
    fp1=fopen(n1,"r");
    fprintf(stderr,"%s %s %s %s %s\n",n1,n2,datestr(1),datestr(0),G_usr);
    fprintf(output,"%s %s %s %s %s\n",n1,n2,datestr(1),datestr(0),G_usr);
    while (fgets(ln1,256,fp1)!=NULL) {
        fc1++;
        fgetpos(fp2,&fo);
        if (fgets(ln2,256,fp2)!=NULL) {
            if (strcmp(ln1,ln2)) {
                i=1;
                rl=0;
                fgetpos(fp2,&fn);
                while ((fgets(ln2,256,fp2)!=NULL)&&(!rl)) {
                    if (!strcmp(ln1,ln2)) {
                        fseek(fp2,fn,SEEK_SET);
                        if (fc1!=s) {
                            if (((fc1-1)-s)!=0) fprintf(output,"t%d\n",(fc1-1)-s);
                            s=fc1-1;
                        }
                        fprintf(output,"s%d\n",i);
                        rl=1;
                    }
                    i++;
                    fgetpos(fp2,&fn);
                }
                if (!rl) {
                    if (fc1!=s) {
                        if (((fc1-1)-s)!=0) fprintf(output,"t%d\n",(fc1-1)-s);
                        s=fc1;
                    }
                    fprintf(output,"i%s",ln1);
                    fseek(fp2,fo,SEEK_SET);
                }
            }
        }
        else {
            if (fc1!=s) {
                if (((fc1-1)-s)>0) fprintf(output,"t%d\n",(fc1-1)-s);
                s=fc1;
            }
            fprintf(output,"i%s",ln1);
        }
    }
    i=0;
    while (fgets(ln2,256,fp2)!=NULL) i++;
    if (i!=0) fprintf(output,"s%d\n",i);
    if (fc1!=s) fprintf(output,"t%d\n",fc1-s);

    fclose(fp1);
    fclose(fp2);
    fclose(output);
//    _dos_setfileattr(of,NOACCESS);
}
// rebuild a file from the control file cf if nf!=null use nf as the new file name ver is the version to be rebuilt
int rebuild(char *cf,char *nf,int ver)
{
    int i;
    char n1[80],n2[80],d[10],t[10];
    FILE *fp1,*fp2,*fp3;

    fp2=fopen(cf,"r");
    if (ver!=0) ver=0;  // insert version rebuild here
    fgets(ln2,256,fp2);
    sscanf(ln2,"%s %s %s %s",&n1,&n2,&d,&t);
    if (nf!=NULL) strcpy(n1,nf);
    printf("rebuilding \"%s\" from \"%s\" using \"%s\" created on %s at %s\n",n1,n2,cf,d,t);
    fp1=fopen(n2,"r");
    fp3=fopen(n1,"w");
    while (fgets(ln2,256,fp2)!=NULL) {
        switch (ln2[0]) {
            case 't' : 
                i=atoi(&ln2[1]);
                while (i) {
                    fgets(ln1,256,fp1);
                    fputs(ln1,fp3);
                    i--;
                }
                break;
            case 's' : 
                i=atoi(&ln2[1]);
                while (i) {
                    fgets(ln1,256,fp1);
                    i--;
                }
                break;
            case 'i' : 
                fputs(&ln2[1],fp3);
                break;
        }
    }
    fclose(fp1);
    fclose(fp2);
    fclose(fp3);
    return(0);
}
// recursively get files
void getfiles(char *path,char *search,int depth)
{
    struct ffblk *fi;
    char *curpath;
    char *newpath;
    char *dirpath;

    curpath=malloc(strlen(path)+strlen(search)+2);
    newpath=malloc(strlen(path)+16);
    dirpath=malloc(strlen(path)+5);
    fi=malloc(sizeof(struct ffblk));

    sprintf(curpath,"%s%s",path,search);
    sprintf(dirpath,"%s%s",path,"*.*");

    findfirst(dirpath,fi,DIRATTR);
    if (strcmp(fi->ff_name,".")) {
        sprintf(newpath,"%s%s\\",path,fi->ff_name);
        if (G_recurse) getfiles(newpath,search,depth+1);
    }
    else {
        findnext(fi);
    }
    while (findnext(fi)==0) {
        if (fi->ff_attrib&DIRATTR)  {
            sprintf(newpath,"%s%s\\",path,fi->ff_name);/* concat dir name      */
            if (G_recurse) getfiles(newpath,search,depth+1);
        }
    }

    if (findfirst(curpath,fi,FILEATTR)==0) {
        do {                                      
            sprintf(newpath,"%s%s",path,fi->ff_name);
            G_files[G_numf++]=strdup(newpath);
        } while (findnext(fi)==0);
    }

    path[strlen(path)-1]=0;

    free(fi);
    free(dirpath);
    free(newpath);
    free(curpath);
}
// copy file s from sp to dp 
int copyfile(char *source,char *dest)
{
    int fi,fo,i;
    int nb;
    char *buf;
    
    buf=malloc(32760);
    if (buf==NULL) return(0);

//    _dos_setfileattr(dest,WRACCESS);

    fi=open(source,O_RDONLY|O_BINARY);
    if (fi!=(-1)) {
        fo=open(dest,O_RDWR|O_TRUNC|O_CREAT|O_BINARY,S_IREAD|S_IWRITE);
        if (fo!=(-1)) {
            while ((nb=read(fi,buf,32760))>0) {
                if (write(fo,buf,nb)!=nb) {
                    free(buf);
                    close(fi);
                    close(fo);
                    return(0);
                }
            }
            close(fo);
        }
        else {
            free(buf);
            close(fi);
            close(fo);
            return(0);
        }
        close(fi);
    }
    free(buf);
//    _dos_setfileattr(dest,NOACCESS);
    return(1);
}
// first copy of a file under vcs file s from sp to dp 
int origfile(char *s,char *sp,char *dp)
{
    char source[80];
    char dest[80];
    char *t;
    fprintf(stderr,"Copy orig %s from %s to %s\n",s,sp,dp);    
    sprintf(source,"%s%s",sp,s);
    sprintf(dest,"%s%s",dp,s);
    t=&dest[strlen(dest)];
    while ((*t!='.')&&(t!=dest)) t--;
    if (*t!='.')
        strcat(dest,"._VC");
    else
        strcpy(t+2,"VC");
    copyfile(source,dest);
    return(1);
}
// latest copy of a file under vcs file s from sp to dp 
int currfile(char *s,char *sp,char *dp)
{
    char source[80];
    char dest[80];
    
    fprintf(stderr,"Copy latest %s from %s to %s\n",s,sp,dp);    
    sprintf(source,"%s%s",sp,s);
    sprintf(dest,"%s%s",dp,s);
    copyfile(source,dest);
    return(1);
}
int putinfile(int idx)
{
    char *n=G_files[idx];
    char tmp[80];
    char name[20];
    strcpy(name,strip(n,0));
    if (!exists(n)) {
        fprintf(stderr,"Can't find file %s\n",name);
        return(0);
    }
    sprintf(tmp,"%s%s",G_path,name);
    if (!exists(tmp)) {
        origfile(name,strip(n,1),G_path);
        currfile(name,strip(n,1),G_path);
    } else {
        if (!compfiles(n,tmp)) {
            transfiles(n,tmp);
            currfile(name,strip(n,1),G_path);
        }
    }
    return(1);
}
void usage(void)
{
    fprintf(stderr,"scvcs [-p|g|l|v|r] file\n");
    fprintf(stderr,"options :\n");
    fprintf(stderr," default -p  put \"file\" under vcs\n");
    fprintf(stderr,"         -g  get \"file\" from vcs into current directory\n");
    fprintf(stderr,"         -l  list information on \"file\"\n");
    fprintf(stderr,"         -v  set version of \"file\"\n");
    fprintf(stderr,"         -r  report on all versions/levels for \"file\"\n");
    fprintf(stderr,"file :\n");
    fprintf(stderr,"         @filename - list file\n");
    fprintf(stderr,"         \dir\*.c ???.h - wild card matching\n");
    fprintf(stderr,"         file.c    - single file\n\n");
    fprintf(stderr,"uses enviroment variables :\n\n");
    fprintf(stderr,"         VCSDIR for directory   ");
    if (getenv("VCSDIR")==NULL)
        fprintf(stderr,"- NOT currently set\n");
    else 
        fprintf(stderr,"- currently set to %s\n",       getenv("VCSDIR"));
    fprintf(stderr,"         VCSSYS for system name ");
    if (getenv("VCSSYS")==NULL)
        fprintf(stderr,"- NOT currently set\n");
    else 
        fprintf(stderr,"- currently set to %s\n",       getenv("VCSSYS"));
    fprintf(stderr,"         VCSUSR for user name   ");
    if (getenv("VCSUSR")==NULL)
        fprintf(stderr,"- NOT currently set\n");
    else                                         
        fprintf(stderr,"- currently set to %s\n",       getenv("VCSUSR"));
                                                 
}
// SCVCS.C 'C' Source Code Version Control System
int main(int argc,char *argv[])
{
    int i;
    int an=1;
    char otype='n';
    FILE *fp;
    char filename[16];
    char *dir;                                      /* holding string       */
    char *file;                                     /* holding string       */
    char zipfile[100];
    char zipcmd[100];
    char curdir[100];
	curdir[0]='\\';
	getcurdir(0,&curdir[1]);

    if (argc<2) {
        usage();
        return(1);
    }
    if (getenv("VCSDIR")!=NULL) {
        strcpy(G_dir,getenv("VCSDIR"));
    } else {
        fprintf(stderr,"VCSDIR not set\ntype \"scvcs\" for help\n");
        return(1);
    }
    if (getenv("VCSSYS")!=NULL) {
        strcpy(G_sys,getenv("VCSSYS"));
    } else {
        fprintf(stderr,"VCSSYS not set\ntype \"scvcs\" for help\n");
        return(1);
    }
    if (getenv("VCSUSR")!=NULL) {
        strcpy(G_usr,getenv("VCSUSR"));
    } else {
        fprintf(stderr,"VCSUSR not set\ntype \"scvcs\" for help\n");
        return(1);
    }

    fprintf(stderr,"'C' Source Code Version Control System Copyright (c) 1993 Cykor Systems.\n\n");
    if (argv[an][0]=='-') {
        otype=argv[an++][1];
    }
    G_recurse=0;
    if (argv[an][0]=='@') {
        fp=fopen(&argv[an][1],"r");
        if (fp==NULL) {
            fprintf(stderr,"Can't Open %s\n",&argv[an][1]);
            return(1);
        }
        while (fgets(filename,15,fp)!=NULL) {
            filename[strlen(filename)-1]=0;
            if ((filename[0]!=0)&&(filename[0]!=' '))
                G_files[G_numf++]=strdup(filename);
        }
        fclose(fp);
    }
    else {
        dir=malloc(strlen(argv[an])+2);                  /* get space for path */
        file=malloc(strlen(argv[an])+2);                 /* get space for file */

        for (i=strlen(argv[an])-1;i>=0;i--) {
            if (argv[an][i]=='\\') {
                strcpy(dir,argv[an]);
                strcpy(file,&argv[an][i+1]);
                dir[i+1]=0;
                break;
            }
        }
        if (i==(-1)) {
            strcpy(file,argv[an]);
            strcpy(dir,".\\");
        }
        strupr(dir);                                    /* change to uppercase  */
        strupr(file);                                   /* change to uppercase  */

        getfiles(dir,file,0);                           /* do the work          */

        free(dir);
        free(file);
    }

    if (G_dir[strlen(G_dir)-1]=='\\') G_dir[strlen(G_dir)-1]=0;
    if (!exists(G_dir)) mkdir(G_dir);
    if (G_sys[0]!=0) {
        sprintf(G_path,"%s\\%s",G_dir,G_sys);
        if (!exists(G_path)) mkdir(G_path);
        strcat(G_path,"\\");
    } else {
        sprintf(G_path,"%s\\",G_dir);
    }
    switch (otype) {
        case 'p':
            fclose(stdout);
        case 'P':
            sprintf(zipfile,"%s\\%s\\%s.VCS",G_dir,G_sys,G_sys);
            _dos_setfileattr(zipfile,WRACCESS);

            for (i=0;i<G_numf;i++) {
                sprintf(zipcmd,"%s\\%s",G_dir,G_sys);
        	    chdir(zipcmd);
                sprintf(zipcmd,"pkunzip -s_john_e %s.VCS %s",G_sys,allfiles(strip(G_files[i],0)));
                system(zipcmd);
        	    chdir(curdir);
                putinfile(i);
            }
            sprintf(zipcmd,"%s\\%s",G_dir,G_sys);
        	chdir(zipcmd);
            sprintf(zipcmd,"pkzip -s_john_e %s.VCS -m *.*",G_sys);
            system(zipcmd);
        	chdir(curdir);
            _dos_setfileattr(zipfile,NOACCESS);
            break;
        case 'g': 
            fclose(stdout);
        case 'G':
//            for (i=0;i<G_numf;i++) getoutfile(i);
            break;
        case 'v':
            fclose(stdout);
        case 'V':
//            for (i=0;i<G_numf;i++) setver(i);
            break;
        case 'r':
            fclose(stdout);
        case 'R':
//            for (i=0;i<G_numf;i++) report(i);
            break;
        default :
            fclose(stdout);
//            for (i=0;i<G_numf;i++) listfile(i);
    }

    for (i=0;i<G_numf;i++) free(G_files[i]);
    return(0);
}

