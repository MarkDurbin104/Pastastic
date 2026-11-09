#include <stdio.h>
#include <stdlib.h> 
#include <stdarg.h> 
#include <string.h> 
#include <ctype.h>  
#include <limits.h> 

#ifdef __TURBOC__
#include <dir.h>
#include <dos.h>
#define  FILEATTR    FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#endif // __TURBOC__

typedef unsigned char  uchar;   
typedef unsigned int   uint;    
typedef unsigned short ushort;  
typedef unsigned long  ulong;   
typedef short node;

#define INIT_CRC        0  
#define BITBUFSIZ       (CHAR_BIT * sizeof bitbuf)
#define DICBIT          13    
#define DICSIZ          (1U<<DICBIT)
#define MATCHBIT        8    
#define MAXMATCH        256    
#define THRESHOLD       3    
#define PERC_FLAG       0x8000U
#define NC              (UCHAR_MAX+MAXMATCH+2-THRESHOLD)
#define CBIT            9  
#define CODE_BIT        16  
#define CRCPOLY         0xA001  
#define UPDATE_CRC(c)   crc=crctable[(crc^(c))&0xFF]^(crc>>CHAR_BIT)
#define PERCOLATE       1
#define NIL             0
#define MAX_HASH_VAL    (3*DICSIZ+(DICSIZ/512+1)*UCHAR_MAX)
#define HASH(p,c)       ((p)+((c)<<(DICBIT-9))+DICSIZ*2)
#define NP              (DICBIT+1)
#define NT              (CODE_BIT+3)
#define PBIT            4 
#define TBIT            5 
#define FNAME_MAX       (255-25)
#define namelen         header[19]
#define filename        ((char *)&header[20])

#if NT>NP
#define NPT             NT
#else
#define NPT             NP
#endif


int     unpackable;
ulong   origsize, compsize;
FILE    *arcfile, *infile, *outfile;
uint    crc, bitbuf;
ushort  left[], right[];
int     unpackable;
ulong   compsize,origsize;
uchar   buffer[DICSIZ];
uchar   header[255];
uchar   headersize,headersum;
uint    filecrc;
char    *tempname;
FILE    *arcfile,*infile,*outfile;
uint    crc,bitbuf;
ushort  crctable[UCHAR_MAX+1];
uint    subbitbuf;
int     bitcount;
uchar   *text,*childcount;
node    pos,matchpos,avail,*position,*parent,*prev,*next=NULL;
int     remainder,matchlen;
#if MAXMATCH<=(UCHAR_MAX+1)
	uchar *level;
#else
	ushort *level;
#endif
int     n,heapsize;
short   heap[NC+1];
ushort  *freq,*sortptr,lencnt[17];
uchar   *len;
ushort  left[2*NC-1],right[2*NC-1];
uchar   *buf,clen[NC],ptlen[NPT];
uint    bufsiz=0,blocksize;
ushort  cfreq[2*NC-1],ctable[4096],ccode[NC];
ushort  pfreq[2*NP-1],pttable[256],ptcode[NPT],tfreq[2*NT-1];
uint    outputpos,outputmask;
int     j;
char    *usage="Usage: arc command archive [file ...]\n"
               "Commands:\n"
               "   a: Add files to archive (replace if present)\n"
               "   x: Extract files from archive\n"
               "   r: Replace files in archive\n"
               "   d: Delete files from archive\n"
               "   p: Print files on standard output\n"
               "   l: List contents of archive\n";

void    error          (char *fmt, ...);
void    makecrctable   (void);
void    fillbuf        (int n);
uint    getbits        (int n);
void    putbits        (int n, uint x);
int     freadcrc       (uchar *p, int n, FILE *f);
void    fwritecrc      (uchar *p, int n, FILE *f);
void    initgetbits    (void);
void    initputbits    (void);
void    encode         (void);
void    decodestart    (void);
void    decode         (uint count, uchar text[]);
void    hufencodestart (void);
void    hufdecodestart (void);
uint    decodec        (void);
uint    decodep        (void);
void    output         (uint c, uint p);
void    hufencodeend   (void);
void    maketable      (int nchar, uchar bitlen[],int tablebits, ushort table[]);
int     maketree       (int nparm, ushort freqparm[],uchar lenparm[], ushort codeparm[]);

long maxsize=0L;
char operation[40];
char thefile[100];
FILE myfile[20];

#define MAXNUMARGS 1000
char *argv[MAXNUMARGS];
int numargs=0;
int argw=0;

int mclose(FILE *fp)
{
    fflush(fp);
    return fclose(fp);
}
FILE *mopen(char *path,char *mode)
{
    FILE *fp;
    fp=fopen(path,mode);
    return fp;
}

uint ratio(ulong a,ulong b) 
{
	int i;

	for (i=0;i<3;i++) if(a<=ULONG_MAX/10)a*=10; else b/=10;
	if ((ulong)(a+(b>>1))<a) { a>>=1; b>>=1; }
	if (b==0) return 0;
	return (uint)((a+(b>>1))/b);
}

void puttoheader(int i,int n,ulong x)
{
	while (--n>=0) {
		header[i++]=(uchar)((uint)x&0xFF);
        x>>=8;
	}
}

ulong getfromheader(int i,int n)
{
	ulong s;

	s=0;
	while (--n>=0) s=(s<<8)+header[i+n];  
	return s;
}

uint calcheadersum(void)
{
	int i;
	uint s;

	s=0;
	for (i=0;i<headersize;i++) s+=header[i];
	return(s&0xFF);
}

int readheader(void)
{
	headersize=(uchar)fgetc(arcfile);
	if (headersize==0) return 0; 
	headersum=(uchar)fgetc(arcfile);
	freadcrc(header,headersize,arcfile);  
	if (calcheadersum()!=headersum) error("Header sum error");
	compsize=getfromheader(5,4);
	origsize=getfromheader(9,4);
	filecrc=(uint)getfromheader(headersize-5,2);
	filename[namelen]='\0';
	return 1; 
}

void writeheader(void)
{
	fputc(headersize,outfile);
	
	puttoheader(headersize-5,2,(ulong)filecrc);
	fputc(calcheadersum(),outfile);
	fwritecrc(header,headersize,outfile);  
}

void skip(void)
{
	fseek(arcfile,compsize,SEEK_CUR);
}

void copy(void)
{
	uint n;

	writeheader();
	while (compsize!=0) {
		n=(uint)((compsize>DICSIZ)?DICSIZ:compsize);
		if (fread((char *)buffer,1,n,arcfile)!=n) error("Can't read");
		if (fwrite((char *)buffer,1,n,outfile)!=n) error("Can't write");
		compsize-=n;
	}
}

void store(void)
{
	uint n;

	origsize=0;
	crc=INIT_CRC;
	while ((n=fread((char *)buffer,1,DICSIZ,infile))!=0) {
		fwritecrc(buffer,n,outfile);  origsize+=n;
	}
	compsize=origsize;
}

int add(int replaceflag)
{
	long headerpos,arcpos;
	uint r;

	if ((infile=mopen(filename,"rb"))==NULL) {
		fprintf(stderr,"Can't open %s\n",filename);
		return 0; 
	}
	if (replaceflag) {
        strcpy(operation,"Replacing");
		printf("%s %s ",operation,filename);
        skip();
	} else {
        strcpy(operation,"Adding");
		printf("%s %s ",operation,filename);
    }
	headerpos=ftell(outfile);
	namelen=strlen(filename);
	headersize=25+namelen;
	memcpy(header,"MD1",5);
	writeheader();  
	arcpos=ftell(outfile);
	origsize=compsize=0;
    unpackable=0;
	crc=INIT_CRC;
    encode();
	if (unpackable) {
		header[3]='0';  
		rewind(infile);
		fseek(outfile,arcpos,SEEK_SET);
		store();
	}
	filecrc=crc^INIT_CRC;
	mclose(infile);
	r=ratio(compsize,origsize);
   	fprintf(stderr,"\r%s %-*s : (%3d.%d%%) %8ld > %8ld\n",operation,argw,thefile,r/10,r%10,origsize,compsize);
	puttoheader(5,4,compsize);
	puttoheader(9,4,origsize);
	memcpy(header+13,"\0\0\0\0\x20\x01",6);
	memcpy(header+headersize-3,"\x20\0\0",3);
	fseek(outfile,headerpos,SEEK_SET);
	writeheader();  
	fseek(outfile,0L,SEEK_END);
	return 1; 
}

int getline(char *s,int n)
{
	int i,c;

	i=0;
	while ((c=getchar())!=EOF &&c!= '\n') if (i<n) s[i++]=(char)c;
	s[i]='\0';
	return i;
}

void extract(int tofile)
{
	int n,method;
	uint extheadersize;

	if (tofile) {
		while ((outfile=mopen(filename,"wb"))==NULL) {
			fprintf(stderr,"Can't open %s\nNew filename:",filename);
			if (getline(filename,FNAME_MAX)==0) {
				fprintf(stderr,"Not extracted\n");
				skip();
                return;
			}
			namelen=strlen(filename);
		}
		printf("Extracting %s ",filename);
	} else {
		outfile=stdout;
		printf("=====%s=====\n",filename);
	}
	crc=INIT_CRC;
	method=header[3];
    header[3]=' ';
	if(!strchr("012",method)||memcmp("MD ",header,5)) {
		fprintf(stderr,"Unknown method: %u\n",method);
		skip();
	} else {
		extheadersize=(uint)getfromheader(headersize-2,2);
		while (extheadersize!=0) {
			fprintf(stderr,"There's an extended header of size %u.\n",
				extheadersize);
			compsize-=extheadersize;
			if (fseek(arcfile,extheadersize-2,SEEK_CUR)) error("Can't read");
			extheadersize=fgetc(arcfile);
			extheadersize+=(uint)fgetc(arcfile)<<8;
		}
		crc=INIT_CRC;
		if (method!='0') decodestart();
		while (origsize!=0) {
			n=(uint)((origsize>DICSIZ)?DICSIZ:origsize);
			if (method!='0') decode(n,buffer);
			else if (fread((char *)buffer,1,n,arcfile)!=n) error("Can't read");
			fwritecrc(buffer,n,outfile);
			if (outfile!=stdout) putc('.',stderr);
			origsize-=n;
		}
	}
	if (tofile) mclose(outfile);  else outfile=NULL;
	printf("\n");
	if ((crc^INIT_CRC)!=filecrc)
		fprintf(stderr,"CRC error\n");
}

void liststart(void)
{
	printf("%-40s   Original Compressed Ratio CRC\n","Filename");
}

void list(void)
{
	uint r;

	printf("%-40s",filename);
	if (namelen>40) printf("\n%-40s","");
	r=ratio(compsize,origsize);
	printf(" %10lu %10lu %3u:1 %04X\n",
		origsize,compsize,1000/r,filecrc);
}

int match(char *s1,char *s2)
{
	for(;;) {
		while (*s2=='*'||*s2=='?') {
			if (*s2++=='*')
				while (*s1&&*s1!=*s2) s1++;
			else if (*s1==0)
				return 0;
			else s1++;
		}
		if (*s1!=*s2) return 0;
		if (*s1==0) return 1;
		s1++;
        s2++;
	}
}

int search(int argc,char *argv[])
{
	int i;

	if (argc==3) return 1;
	for (i=3;i<argc;i++)
		if (match(filename,argv[i])) return 1;
	return 0;
}

void exitfunc(void)
{
	mclose(outfile);
    remove(tempname);
}
#ifdef __TURBOC__
void findfile(char *filespec)
{
    struct ffblk f;
    int done;
    int numfd=0;
    char *nptr;
    static char path[100];
    static char name[100];
    static char tmp[100];
    static char opt[100];

    nptr=strrchr(filespec,'\\');
    if (nptr==NULL) {
        strcpy(name,filespec);
        strcpy(path,"");
    } else {
        strcpy(name,nptr+1);
        *nptr=0;
        sprintf(path,"%s\\",filespec);
        *nptr='\\';
    }
    sprintf(tmp,"%s%s",path,name);
    done=findfirst(tmp,&f,FILEATTR);
    while (done!=(-1)) {
        sprintf(opt,"%s%s",path,f.ff_name);
        if (numargs>=MAXNUMARGS) return;
        argv[numargs++]=strdup(opt);
        done=findnext(&f);
        numfd++;
    }
}
void addarg(char *arg)
{
    if (numargs>=MAXNUMARGS) return;
    if (strpbrk(arg,"*?")) {
        findfile(arg);
    } else {
        argv[numargs++]=strdup(arg);
    }
}
#else
void addarg(char *arg)
{
    if (numargs>=MAXNUMARGS) return;
    argv[numargs++]=strdup(arg);
}
#endif // __TURBOC__
int main(int argc,char *args[])
{
	int i,j,cmd,count,nfiles,found,done;

	
	for (i=0;i<argc;i++) addarg(args[i]);
    argc=numargs;
	for (i=3;i<argc;i++) argw=max(argw,strlen(argv[i]));

	if (argc<3 || argv[1][1]!='\0'
    || !strchr("AXRDPL",cmd=toupper(argv[1][0]))
	|| (argc ==3&& strchr("AD",cmd)))
		error(usage);

	
	for (i=3;i<argc;i++) if (strpbrk(argv[i],"*?")) break;
	if (cmd=='A'&&i<argc) error("Filenames may not contain '*' and '?'");
	if (i<argc) nfiles=-1; else nfiles=argc-3;   

	
	arcfile=mopen(argv[2],"rb");
	if (arcfile==NULL&&cmd!='A')
		error("Can't open archive '%s'",argv[2]);

	
	if (strchr("ARD",cmd)) {
		tempname=tmpnam(NULL);
		outfile=mopen(tempname,"wb");
		if (outfile==NULL) error("Can't open temporary file");
		atexit(exitfunc);
	} else tempname=NULL;

	makecrctable();
    count=done=0;

	if (cmd=='A') {
		for (i=3;i<argc;i++) {
			for (j=3;j<i;j++) if (strcmp(argv[j],argv[i])==0) break;
			if (j==i){
                memset(filename,0,FNAME_MAX);
				strcpy(thefile,argv[i]);
				strcpy(filename,argv[i]);
				if (add(0)) count++; else argv[i][0]=0;
			} else nfiles--;
		}
		if (count==0||arcfile==NULL) done=1;
	}

	while(!done&&readheader()) {
		found=search(argc,argv);
		switch (cmd) {
		case 'R':
			if (found) {
				if (add(1)) count++;  else copy();
			} else copy();
			break;
		case 'A':  case 'D':
			if (found) {
				count+=(cmd=='D');  skip();
			} else copy();
			break;
		case 'X':  case 'P':
			if (found) {
				extract(cmd=='X');
				if (++count==nfiles) done=1;
			} else skip();
			break;
		case 'L':
			if (found) {
				if (count==0) liststart();
				list();
				if (++count==nfiles) done=1;
			}
			skip();
            break;
		}
	}

	if (tempname!=NULL&&count!=0) {
		fputc(0,outfile);  
		if (ferror(outfile)||mclose(outfile)==EOF) error("Can't write");
		remove(argv[2]);
        rename(tempname,argv[2]);
	}

	printf("\n%d file%c\n",count,((count==1)?' ':'s'));
	return EXIT_SUCCESS;
}
void countlen(int i) 
{
	static int depth=0;

	if (i<n) {
        lencnt[(depth<16)?depth:16]++;
	} else {
		depth++;
		countlen(left [i]);
		countlen(right[i]);
		depth--;
	}
}

void makelen(int root)
{
	int i,k;
	uint cum;

	for (i=0;i<=16;i++) lencnt[i]=0;
	countlen(root);
	cum=0;
	for (i=16;i>0;i--) cum+=lencnt[i]<<(16-i);
	while (cum!=(1U<<16)) {
		fprintf(stderr,"17");
		lencnt[16]--;
		for (i=15;i>0;i--) {
			if (lencnt[i]!=0) {
				lencnt[i]--;
                lencnt[i+1]+=2;
                break;
			}
		}
		cum--;
	}
	for (i=16;i>0;i--) {
		k=lencnt[i];
		while (--k>=0) len[*sortptr++]=i;
	}
}

void downheap(int i)
	
{
	int j,k;

	k=heap[i];
	while ((j=2*i)<=heapsize) {
		if (j<heapsize&&freq[heap[j]]>freq[heap[j+1]]) j++;
		if (freq[k]<=freq[heap[j]]) break;
		heap[i]=heap[j];
        i=j;
	}
	heap[i]=k;
}

void makecode(int n,uchar len[],ushort code[])
{
	int i;
	ushort start[18];

	start[1]=0;
	for (i=1;i<=16;i++) start[i+1]=(start[i]+lencnt[i])<<1;
	for (i=0;i<n;i++) code[i]=start[len[i]]++;
}

int maketree(int nparm,ushort freqparm[],uchar lenparm[],ushort codeparm[])
{
	int i,j,k,avail;

	n=nparm;
    freq=freqparm;
    len=lenparm;
	avail=n;
    heapsize=0;
    heap[1]=0;

	for (i=0;i<n;i++) {
		len[i]=0;
		if (freq[i]) heap[++heapsize]=i;
	}
	if (heapsize<2) {
		codeparm[heap[1]]=0;
        return heap[1];
	}
	for (i=heapsize/2;i>=1;i--) downheap(i);  
	sortptr=codeparm;
	do { 
		i=heap[1];  
		if (i<n) *sortptr++=i;
		heap[1]=heap[heapsize--];
		downheap(1);
		j=heap[1];  
		if (j<n) *sortptr++=j;
		k=avail++;  
		freq[k]=freq[i]+freq[j];
		heap[1]=k;
        downheap(1);  
		left[k]=i;
        right[k]=j;
	} while (heapsize>1);
	sortptr=codeparm;
	makelen(k);
	makecode(nparm,lenparm,codeparm);
	return k; 
}
void maketable(int nchar,uchar bitlen[],int tablebits,ushort table[])
{
	ushort count[17],weight[17],start[18],*p;
	uint i,k,len,ch,jutbits,avail,nextcode,mask;

	for (i=1;i<=16;i++) count[i]=0;
	for (i=0;i<nchar;i++) count[bitlen[i]]++;

	start[1]=0;
	for (i=1;i<=16;i++) start[i+1]=start[i]+(count[i]<<(16-i));
	if (start[17]!=(ushort)(1U<<16)) error("Bad table");

	jutbits=16-tablebits;
	for (i=1;i<=tablebits;i++) {
		start[i]>>=jutbits;
		weight[i]=1U<<(tablebits-i);
	}
	while(i<=16)weight[i++]=1U<<(16-i);

	i=start[tablebits+1]>>jutbits;
	if(i!=(ushort)(1U<<16)) {
		k=1U<<tablebits;
		while(i!=k)table[i++]=0;
	}

	avail=nchar;
	mask=1U<<(15-tablebits);
	for (ch=0;ch<nchar;ch++) {
		if ((len=bitlen[ch])==0) continue;
		nextcode=start[len]+weight[len];
		if (len<=tablebits) {
			for (i=start[len];i<nextcode;i++) table[i]=ch;
		} else {
			k=start[len];
			p=&table[k>>jutbits];
			i=len-tablebits;
			while(i!=0){
				if (*p==0) {
					right[avail]=left[avail]=0;
					*p=avail++;
				}
				if (k&mask)p=&right[*p];
				else  p=&left[*p];
				k<<=1;
                i--;
			}
			*p=ch;
		}
		start[len]=nextcode;
	}
}
void error(char *fmt,...)
{
	va_list args;

	va_start(args,fmt);
	putc('\n',stderr);
	vfprintf(stderr,fmt,args);
	putc('\n',stderr);
	va_end(args);
	exit(EXIT_FAILURE);
}

void makecrctable(void)
{
	uint i,j,r;

	for (i=0;i<=UCHAR_MAX;i++) {
		r=i;
		for (j=0;j<CHAR_BIT;j++)
			if (r&1) r=(r>>1)^CRCPOLY; else r>>=1;
		crctable[i]=r;
	}
}

void fillbuf(int n) 
{
	bitbuf<<=n;
	while (n>bitcount) {
		bitbuf|=subbitbuf<<(n-=bitcount);
		if (compsize!=0) {
			compsize--;
            subbitbuf=(uchar)getc(arcfile);
		} else subbitbuf=0;
		bitcount=CHAR_BIT;
	}
	bitbuf|=subbitbuf>>(bitcount-=n);
}

uint getbits(int n)
{
	uint x;

	x=bitbuf>>(BITBUFSIZ-n);
    fillbuf(n);
	return x;
}

void putbits(int n,uint x) 
{
	if (n<bitcount) {
		subbitbuf|=x<<(bitcount-=n);
	} else {
		if (compsize<origsize) {
			putc(subbitbuf|(x>>(n-=bitcount)),outfile);
			compsize++;
		} else unpackable=1;
		if (n<CHAR_BIT) {
			subbitbuf=x<<(bitcount=CHAR_BIT-n);
		} else {
			if (compsize<origsize) {
				putc(x>>(n-CHAR_BIT),outfile);
				compsize++;
			} else unpackable=1;
			subbitbuf=x<<(bitcount=2*CHAR_BIT-n);
		}
	}
}

int freadcrc(uchar *p,int n,FILE *f)
{
	int i;

	i=n=fread(p,1,n,f);
    origsize+=n;
	while (--i>=0) UPDATE_CRC(*p++);
	return n;
}

void fwritecrc(uchar *p,int n,FILE *f)
{
	if (fwrite(p,1,n,f)<n) error("Unable to write");
	while (--n>=0) UPDATE_CRC(*p++);
}

void initgetbits(void)
{
	bitbuf=0;
    subbitbuf=0;
    bitcount=0;
	fillbuf(BITBUFSIZ);
}

void initputbits(void)
{
	bitcount=CHAR_BIT;
    subbitbuf=0;
}
void countt_freq(void)
{
	int i,k,n,count;

	for (i=0;i<NT;i++) tfreq[i]=0;
	n=NC;
	while (n>0&&clen[n-1]==0) n--;
	i=0;
	while (i<n) {
		k=clen[i++];
		if (k==0) {
			count=1;
			while (i<n&&clen[i]==0) {
                i++;
                count++;
            }
			if (count<=2) tfreq[0]+=count;
			else if (count<=18) tfreq[1]++;
			else if (count==19) {
                tfreq[0]++;
                tfreq[1]++;
            } else tfreq[2]++;
		} else tfreq[k+2]++;
	}
}

void writeptlen(int n,int nbit,int ispecial)
{
	int i,k;

	while (n>0&&ptlen[n-1]==0) n--;
	putbits(nbit,n);
	i=0;
	while (i<n) {
		k=ptlen[i++];
		if (k<=6)putbits(3,k);
		else putbits(k-3,(1U<<(k-3))-2);
		if (i==ispecial) {
			while (i<6&&ptlen[i]==0) i++;
			putbits(2,(i-3)&3);
		}
	}
}

void writec_len(void)
{
	int i,k,n,count;

	n=NC;
	while (n>0&&clen[n-1]==0) n--;
	putbits(CBIT,n);
	i=0;
	while (i<n) {
		k=clen[i++];
		if (k==0) {
			count=1;
			while (i<n&&clen[i]==0) {
                i++;
                count++;
            }
			if (count<=2) {
				for (k=0;k<count;k++) putbits(ptlen[0],ptcode[0]);
			} else if (count<=18) {
				putbits(ptlen[1],ptcode[1]);
				putbits(4,count-3);
			} else if (count==19) {
				putbits(ptlen[0],ptcode[0]);
				putbits(ptlen[1],ptcode[1]);
				putbits(4,15);
			} else {
				putbits(ptlen[2],ptcode[2]);
				putbits(CBIT,count-20);
			}
		} else putbits(ptlen[k+2],ptcode[k+2]);
	}
}

void encodec(int c)
{
	putbits(clen[c],ccode[c]);
}

void encodep(uint p)
{
	uint c,q;

	c=0;
    q=p;
    while (q) {
        q>>=1;
        c++;
    }
	putbits(ptlen[c],ptcode[c]);
	if (c>1) putbits(c-1,p&(0xFFFFU>>(17-c)));
}

void sendblock(void)
{
	uint i,k,flags,root,pos,size;

	root=maketree(NC,cfreq,clen,ccode);
	size=cfreq[root];
    putbits(16,size);
	if (root>=NC) {
		countt_freq();
		root=maketree(NT,tfreq,ptlen,ptcode);
		if (root>=NT) {
			writeptlen(NT,TBIT,3);
		} else {
			putbits(TBIT,0);
            putbits(TBIT,root);
		}
		writec_len();
	} else {
        putbits(TBIT,0);
        putbits(TBIT,0);
		putbits(CBIT,0);
        putbits(CBIT,root);
	}
	root=maketree(NP,pfreq,ptlen,ptcode);
	if (root>=NP) {
		writeptlen(NP,PBIT,-1);
	} else {
		putbits(PBIT,0);
        putbits(PBIT,root);
	}
	pos=0;
	for (i=0;i<size;i++) {
		if (i%CHAR_BIT==0) flags=buf[pos++]; else flags<<=1;
		if (flags&(1U<<(CHAR_BIT-1))) {
			encodec(buf[pos++]+(1U<<CHAR_BIT));
			k=buf[pos++]<<CHAR_BIT;
            k+=buf[pos++];
			encodep(k);
		} else encodec(buf[pos++]);
		if (unpackable) return;
	}
	for (i=0;i<NC;i++) cfreq[i]=0;
	for (i=0;i<NP;i++) pfreq[i]=0;
}


void output(uint c,uint p)
{
	static uint cpos;

	if ((outputmask>>=1)==0){
		outputmask=1U<<(CHAR_BIT-1);
		if (outputpos>=bufsiz-3*CHAR_BIT) {
			sendblock();
			if (unpackable) return;
			outputpos=0;
		}
		cpos=outputpos++;
        buf[cpos]=0;
	}
	buf[outputpos++]=(uchar)c;
    cfreq[c]++;
	if (c>=(1U<<CHAR_BIT)) {
		buf[cpos]|=outputmask;
		buf[outputpos++]=(uchar)(p>>CHAR_BIT);
		buf[outputpos++]=(uchar) p;
		c=0;
        while (p) {
            p>>=1;
            c++;
        }
		pfreq[c]++;
	}
}

void hufencodestart(void)
{
	int i;

	if (bufsiz==0) {
		bufsiz=16*1024U;
		while ((buf=malloc(bufsiz))==NULL) {
			bufsiz=(bufsiz/10U)*9U;
			if (bufsiz<4*1024U) error("Out of memory.");
		}
	}
	buf[0]=0;
	for (i=0;i<NC;i++) cfreq[i]=0;
	for (i=0;i<NP;i++) pfreq[i]=0;
	outputpos=outputmask=0;
	initputbits();
}

void hufencodeend(void)
{
	if (!unpackable) {
		sendblock();
		putbits(CHAR_BIT-1,0);  
	}
}

void readptlen(int nn,int nbit,int ispecial)
{
	int i,c,n;
	uint mask;

	n=getbits(nbit);
	if(n==0){
		c=getbits(nbit);
		for (i=0;i<nn;i++) ptlen[i]=0;
		for (i=0;i<256;i++) pttable[i]=c;
	} else {
		i=0;
		while (i<n) {
			c=bitbuf>>(BITBUFSIZ-3);
			if(c==7){
				mask=1U<<(BITBUFSIZ-1-3);
				while (mask&bitbuf) {
                    mask>>=1;
                    c++;
                }
			}
			fillbuf((c<7)?3:c-3);
			ptlen[i++]=c;
			if (i==ispecial) {
				c=getbits(2);
				while (--c>=0) ptlen[i++]=0;
			}
		}
		while (i<nn) ptlen[i++]=0;
		maketable(nn,ptlen,8,pttable);
	}
}

void readc_len(void)
{
	int i,c,n;
	uint mask;

	n=getbits(CBIT);
	if (n==0) {
		c=getbits(CBIT);
		for (i=0;i<NC;i++) clen[i]=0;
		for (i=0;i<4096;i++) ctable[i]=c;
	} else {
		i=0;
		while (i<n) {
			c=pttable[bitbuf>>(BITBUFSIZ-8)];
			if(c>=NT) {
				mask=1U<<(BITBUFSIZ-1-8);
				do {
					if (bitbuf&mask) c=right[c]; else c=left[c];
					mask>>=1;
				} while(c>=NT);
			}
			fillbuf(ptlen[c]);
			if (c<=2) {
				if (c==0) c=1;
				else if (c==1) c=getbits(4)+3;
				else  c=getbits(CBIT)+20;
				while (--c>=0) clen[i++]=0;
			} else clen[i++]=c-2;
		}
		while (i<NC) clen[i++]=0;
		maketable(NC,clen,12,ctable);
	}
}

uint decodec(void)
{
	uint j,mask;

	if (blocksize==0) {
		blocksize=getbits(16);
		readptlen(NT,TBIT,3);
		readc_len();
		readptlen(NP,PBIT,-1);
	}
	blocksize--;
	j=ctable[bitbuf>>(BITBUFSIZ-12)];
	if(j>=NC) {
		mask=1U<<(BITBUFSIZ-1-12);
		do {
			if (bitbuf&mask) j=right[j]; else j=left[j];
			mask>>=1;
		} while(j>=NC);
	}
	fillbuf(clen[j]);
	return j;
}

uint decodep(void)
{
	uint j,mask;

	j=pttable[bitbuf>>(BITBUFSIZ-8)];
	if(j>=NP) {
		mask=1U<<(BITBUFSIZ-1-8);
		do {
			if (bitbuf&mask) j=right[j]; else j=left[j];
			mask>>=1;
		} while(j>=NP);
	}
	fillbuf(ptlen[j]);
	if (j!=0) j=(1U<<(j-1))+getbits(j-1);
	return j;
}

void hufdecodestart(void)
{
	initgetbits();
    blocksize=0;
}
void allocatememory(void)
{
	if (next!=NULL) return;
    text=malloc(DICSIZ*2+MAXMATCH);
	level=malloc((DICSIZ+UCHAR_MAX+1)*sizeof(*level));
	childcount=malloc((DICSIZ+UCHAR_MAX+1)*sizeof(*childcount));
	#if PERCOLATE
	  position=malloc((DICSIZ+UCHAR_MAX+1)*sizeof(*position));
	#else
	  position=malloc(DICSIZ*sizeof(*position));
	#endif
	parent =malloc(DICSIZ*2*sizeof(*parent));
	prev   =malloc(DICSIZ*2*sizeof(*prev));
	next   =malloc((MAX_HASH_VAL+1)*sizeof(*next));
	if (next==NULL) error("Out of memory.");
}

void initslide(void)
{
	node i;

	for(i= DICSIZ;i<=DICSIZ+UCHAR_MAX;i++) {
		level[i]=1;
		#if PERCOLATE
			position[i]=NIL;  
		#endif
	}
	for (i=DICSIZ;i<DICSIZ*2;i++) parent[i]=NIL;
	avail=1;
	for (i=1;i<DICSIZ-1;i++) next[i]=i+1;
	next[DICSIZ-1]= NIL;
	for (i=DICSIZ*2;i<=MAX_HASH_VAL;i++) next[i]=NIL;
}


node child(node q,uchar c)
{
	node r;

	r=next[HASH(q,c)];
	parent[NIL]=q; 
	while (parent[r]!=q) r=next[r];
	return r;
}

void makechild(node q,uchar c,node r)
{
	node h,t;

	h=HASH(q,c);
	t=next[h];
    next[h]=r;
    next[r]=t;
	prev[t]=r;
    prev[r]=h;
	parent[r]=q;
    childcount[q]++;
}

void split(node old)
{
	node new,t;

	new=avail;
    avail=next[new];
    childcount[new]=0;
	t=prev[old];
    prev[new]=t;
    next[t]=new;
	t=next[old];
    next[new]=t;
    prev[t]=new;
	parent[new]=parent[old];
	level[new]=matchlen;
	position[new]=pos;
	makechild(new,text[matchpos+matchlen],old);
	makechild(new,text[pos+matchlen],pos);
}

void insertnode(void)
{
	node q,r,j,t;
	uchar c,*t1,*t2;

	if (matchlen>=4) {
		matchlen--;
		r=(matchpos+1)|DICSIZ;
		while ((q=parent[r])==NIL) r=next[r];
		while (level[q]>=matchlen) {
			r=q;
            q=parent[q];
		}
		#if PERCOLATE
			t=q;
			while (position[t]<0){
				position[t]=pos;
                t=parent[t];
			}
			if(t<DICSIZ) position[t]=pos|PERC_FLAG;
		#else
			t=q;
			while(t<DICSIZ) {
				position[t]=pos;
                t=parent[t];
			}
		#endif
	} else {
		q=text[pos]+DICSIZ;
        c=text[pos+1];
		if ((r=child(q,c))==NIL) {
			makechild(q,c,pos);
            matchlen=1;
			return;
		}
		matchlen=2;
	}
	for(;;) {
		if(r>= DICSIZ) {
			j=MAXMATCH;
            matchpos=r;
		} else {
			j=level[r];
			matchpos=position[r]&~PERC_FLAG;
		}
		if (matchpos>=pos) matchpos-=DICSIZ;
		t1=&text[pos+matchlen];
        t2=&text[matchpos+matchlen];
		while (matchlen <j){
			if (*t1!=*t2) {
                split(r);
                return;
            }
			matchlen++;
            t1++;
            t2++;
		}
		if (matchlen>=MAXMATCH) break;
		position[r]=pos;
		q=r;
		if ((r=child(q,*t1))==NIL) {
			makechild(q,*t1,pos);
            return;
		}
		matchlen++;
	}
	t=prev[r];
    prev[pos]=t;
    next[t]=pos;
	t=next[r];
    next[pos]=t;
    prev[t]=pos;
	parent[pos]=q;
    parent[r]=NIL;
	next[r]=pos;  
}

void deletenode(void)
{
	#if PERCOLATE
		node q,r,s,t,u;
	#else
		node r,s,t,u;
	#endif

	if (parent[pos]==NIL) return;
	r=prev[pos];
    s=next[pos];
	next[r]=s;
    prev[s]=r;
	r=parent[pos];
    parent[pos]=NIL;
	if (r>=DICSIZ||--childcount[r]>1) return;
	#if PERCOLATE
		t=position[r]&~PERC_FLAG;
	#else
		t=position[r];
	#endif
	if (t>=pos) t-=DICSIZ;
	#if PERCOLATE
		s=t;
        q=parent[r];
		while ((u=position[q])&PERC_FLAG) {
			u&=~PERC_FLAG;
            if (u>=pos) u-=DICSIZ;
			if (u>s) s=u;
			position[q]=(s|DICSIZ);
            q=parent[q];
		}
		if(q<DICSIZ) {
			if (u>=pos) u-=DICSIZ;
			if (u>s) s=u;
			position[q]=s|DICSIZ|PERC_FLAG;
		}
	#endif
	s=child(r,text[t+level[r]]);
	t=prev[s];
    u=next[s];
	next[t]=u;
    prev[u]=t;
	t=prev[r];
    next[t]=s;
    prev[s]=t;
	t=next[r];
    prev[t]=s;
    next[s]=t;
	parent[s]=parent[r];
    parent[r]=NIL;
	next[r]=avail;
    avail=r;
}

void getnextmatch(void)
{
	int n;
	remainder--;
	if (++pos==DICSIZ*2){
		memmove(&text[0],&text[DICSIZ],DICSIZ+MAXMATCH);
		n=freadcrc(&text[DICSIZ+MAXMATCH],DICSIZ,infile);
		remainder+=n;
        pos=DICSIZ;
    	fprintf(stderr,"\r%s %-*s : %d%%",operation,argw,thefile,((origsize*100L)/maxsize));
	}
	deletenode();
    insertnode();
}

void encode(void)
{
    long curpos;
	int lastmatchlen;
	node lastmatchpos;

	allocatememory();
    initslide();
    hufencodestart();
	remainder=freadcrc(&text[DICSIZ],DICSIZ+MAXMATCH,infile);
    curpos=ftell(infile);
    fseek(infile,0,SEEK_END);
    maxsize=ftell(infile);
    fseek(infile,curpos,SEEK_SET);
  	fprintf(stderr,"\r%s %-*s : %d%%",operation,argw,thefile,((origsize*100L)/maxsize));
	matchlen=0;
	pos=DICSIZ;
    insertnode();
	if (matchlen>remainder) matchlen=remainder;
	while (remainder>0&&!unpackable) {
		lastmatchlen=matchlen;
        lastmatchpos=matchpos;
		getnextmatch();
		if (matchlen>remainder) matchlen=remainder;
		if (matchlen>lastmatchlen||lastmatchlen<THRESHOLD)
			output(text[pos-1],0);
		else {
			output(lastmatchlen+(UCHAR_MAX+1-THRESHOLD),
				 (pos-lastmatchpos -2)& (DICSIZ-1));
			while (--lastmatchlen>0) getnextmatch();
			if (matchlen>remainder) matchlen=remainder;
		}
	}
	hufencodeend();
}

void decodestart(void)
{
	hufdecodestart();
	j=0;
}

void decode(uint count,uchar buffer[])
{
	static uint i;
	uint r,c;

	r=0;
	while (--j>=0) {
		buffer[r]=buffer[i];
		i=(i+1)&(DICSIZ-1);
		if (++r==count) return;
	}
	for(;;) {
		c=decodec();
		if (c<=UCHAR_MAX) {
			buffer[r]=c;
			if (++r==count) return;
		} else {
			j=c-(UCHAR_MAX+1-THRESHOLD);
			i=(r-decodep()-1)&(DICSIZ-1);
			while (--j>=0) {
				buffer[r]=buffer[i];
				i=(i+1)&(DICSIZ-1);
				if (++r==count) return;
			}
		}
	}
}


