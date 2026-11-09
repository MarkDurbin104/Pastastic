#include <dos.h>
#include <mem.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <stdarg.h>
#include <alloc.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#define  DEFSECSZ  512
#define  OUT_OF_MEM      (-2)
#define  OK                0
#define  WRITE_PROTECTION  3
#define  RESET_NO          7
#define  DISK_IO_NO        10

static   char  tmp_buf1[80];
static   char  tmp_buf2[80];
typedef unsigned int  uint;
typedef unsigned char uchar;

struct T_DISK_INFO {
    uint  numt;
    uint  nums;
    uint  numh;
} G_di;

int getdiskinfo(uint drive)
{
    int      i, j;
    int      done;
    union    REGS   inregs, outregs;
    struct   SREGS  segregs;

    done = 0;

    for (i = 0, j = 0; i < RESET_NO && j < DISK_IO_NO && !done; i++) {

        
        inregs.h.ah = 0x00;           
        inregs.h.dl = drive & 0xff;   

        
        int86x(0x13, &inregs, &outregs, &segregs);

        if (outregs.x.cflag == 0)
        {
            j++;
            
            inregs.h.ah = 0x08;          
            inregs.h.dl = drive & 0xff;  

            
            int86(0x13, &inregs, &outregs);

            
            if (outregs.x.cflag == 0)
            {
                done = 1;

                
                

                G_di.numt = (((outregs.h.cl & 0xc0) << 2) | outregs.h.ch); // + 1;
                G_di.nums = outregs.h.cl & 0x3f;
                G_di.numh = outregs.h.dh;
            }
        }
    }

    if (!done) {
        i = outregs.h.ah;
    } else {
        i = OK;
    }

    return (i);
}

int check_drive(uint drive)
{
    int      i, j;
    union    REGS   inregs, outregs;
    struct   SREGS  segregs;


    for (i = 0, j = 0; i < RESET_NO && j < DISK_IO_NO; i++) {

        
        inregs.h.ah = 0x00;           
        inregs.h.dl = drive & 0xff;   

        
        int86x(0x13, &inregs, &outregs, &segregs);

        if (outregs.x.cflag == 0)
        {
            j++;
            
            inregs.h.ah = 0x15;          
            inregs.h.dl = drive & 0xff;  

            
            int86(0x13, &inregs, &outregs);

            
            if (outregs.x.cflag == 0)
            {
                if (outregs.h.ah == 0) {
                    return (0);
                } else if ((outregs.h.ah == 1 || outregs.h.ah == 2) && drive == 0) {
                    return (1);
                } else {
                    return (0);
                }
            }
        }
    }

    return (0);
}
int read_sectors (uint drive, uint head, uint cylinder, 
                  uint start_sector, uint no_of_sectors,
                  char far *sectors_buffer)
{
    int      i,j;
    uint     ms2b_cyl_no;
    uint     seg_buf;
    uint     off_buf;
    uint     off_4;
    int      done;
    union    REGS   inregs,outregs;
    struct   SREGS  segregs;

    done=0;

    if (head>G_di.numh||cylinder>G_di.numt+1
	||  start_sector>G_di.nums||no_of_sectors>G_di.nums) return (1);

	ms2b_cyl_no=((cylinder>>8)&0x03)<<6;
    
	seg_buf=FP_SEG(sectors_buffer);
	off_buf=FP_OFF(sectors_buffer);
	off_4=off_buf;
	seg_buf+=((off_4>>4)&0x0FFF);
	off_buf=(off_buf&0x000F);
	segread(&segregs);

	for (i=0,j=0;i<RESET_NO&&j<DISK_IO_NO&&!done;i++) {
		if (outregs.x.cflag==0) {
			j++;
			inregs.h.ah=0x02;
			inregs.h.al=no_of_sectors;
			inregs.h.ch=cylinder&0xff;
			inregs.h.cl=start_sector|ms2b_cyl_no;
			inregs.h.dh=(char)(head&0xff);
			inregs.h.dl=drive&0xff;
			segregs.es=seg_buf;
			inregs.x.bx=off_buf;
			int86x(0x13,&inregs,&outregs,&segregs);
			if (outregs.x.cflag==0) done=1;
		}
		if (!done) {
			inregs.h.ah=0x00;
			inregs.h.dl=0x00;
			int86x(0x13,&inregs,&outregs,&segregs);
		}
	}

    return ((done)?OK:outregs.h.ah);
}
int write_sectors (uint drive, uint head, uint cylinder, 
                   uint start_sector, uint no_of_sectors,
                   char far *sectors_buffer)
{
    int      i, j;
    uint     ms2b_cyl_no;
    uint     seg_buf;
    uint     off_buf;
    uint     off_4;
    int  done;
    union    REGS   inregs, outregs;
    struct   SREGS  segregs;

    done = 0;

    if (head > G_di.numh ||
        cylinder > G_di.numt + 1 ||
        start_sector > G_di.nums ||
        no_of_sectors > G_di.nums) 
    {
       return (1);
    }

    
    
    

    ms2b_cyl_no = ((cylinder >> 8) & 0x03) << 6;

    
    seg_buf = FP_SEG(sectors_buffer);
    off_buf = FP_OFF(sectors_buffer);
    off_4 = off_buf;
    seg_buf += ((off_4 >> 4) & 0x0FFF);
    off_buf = (off_buf & 0x000F);
    segread(&segregs);

    for (i = 0, j = 0; i < RESET_NO && j < DISK_IO_NO && !done; i++) {

        
        inregs.h.ah = 0x00;   
        inregs.h.dl = 0x00;   

        
        int86x(0x13, &inregs, &outregs, &segregs);

        if (outregs.x.cflag == 0)
        {
            j++;

            
            inregs.h.ah = 0x03;                       
            inregs.h.al = no_of_sectors;              
            inregs.h.ch = cylinder & 0xff;            
            inregs.h.cl = start_sector | ms2b_cyl_no; 
            inregs.h.dh = (char)(head & 0xff);        
            inregs.h.dl = drive & 0xff;               
            segregs.es  = seg_buf;                    
            inregs.x.bx = off_buf;                    

            
            int86x(0x13, &inregs, &outregs, &segregs);

            if (outregs.x.cflag == 0)
            {
                done = 1;
            }
        }
    }

    if (!done) {
        i = outregs.h.ah;
    } else {
        i = OK;
    }

    return (i);
}
int format_track (uint drive, uint head, uint cylinder)
{
    int      i, j, k, l, l1, l2, l3;
    uint     ms2b_cyl_no;
    uint     seg_buf;
    uint     off_buf;
    uint     off_4;
    int  done;
    char far *afl_buffer;      // address field list
    char far *afl_2buffer;
    char far *afl_ptr;
    union    REGS   inregs, outregs;
    struct   SREGS  segregs;

    done = 0;

    if (head > G_di.numh ||
        cylinder > G_di.numt + 1) 
    {
        return (1);
    }

    
    
    

    ms2b_cyl_no = ((cylinder >> 8) & 0x03) << 6;

    
    afl_buffer   = malloc(DEFSECSZ*2);

    
    if (afl_buffer != NULL) {
        
        seg_buf = FP_SEG(afl_buffer);
        off_buf = FP_OFF(afl_buffer);
        off_4 = off_buf;
        seg_buf += ((off_4 >> 4) & 0x0FFF);
        off_buf = (off_buf & 0x000F);
        segread(&segregs);
        if (seg_buf>0xFFE0U) {
            afl_2buffer=afl_buffer+DEFSECSZ;
            seg_buf = FP_SEG(afl_2buffer);
            off_buf = FP_OFF(afl_2buffer);
            off_4 = off_buf;
            seg_buf += ((off_4 >> 4) & 0x0FFF);
            off_buf = (off_buf & 0x000F);
        }

        if (drive < 0x80) {
            for (k = 1, afl_ptr = afl_buffer; k <= G_di.nums; k++) {
               *afl_ptr = cylinder & 0xff;
               afl_ptr++;
               *afl_ptr = head;
               afl_ptr++;
               *afl_ptr = k;
               afl_ptr++;
               *afl_ptr = 2;
               afl_ptr++;
            }
        } else {
            l1 = 1;
            l2 = (G_di.nums % 3)? 
                 ((G_di.nums / 3) + 2): 
                 ((G_di.nums / 3) + 1);
            l3 = (2 * l1) - 1;
            for (k = 1, afl_ptr = afl_buffer; k <= G_di.nums; k++) {
               *afl_ptr = 0x00;
               afl_ptr++;
               if (k % 3 == 1)
                  l = l1++;
               else if (k % 3 == 2)
                  l = l2++;
               else
                  l = l3++;
               *afl_ptr = l;
               afl_ptr++;
            }
        }

        for (i = 0, j = 0; i < RESET_NO && j < DISK_IO_NO && !done; i++) {
            
            inregs.h.ah = 0x00;   
            inregs.h.dl = 0x00;   
            int86x(0x13, &inregs, &outregs, &segregs);

            if (outregs.x.cflag == 0) {
                j++;

                inregs.h.ah = 0x05;                        
                inregs.h.al = (drive < 0x80)?  
                               G_di.nums: 3; 
                inregs.h.ch = cylinder & 0xff;             
                inregs.h.cl = ms2b_cyl_no;                 
                inregs.h.dh = (char)(head & 0xff);         
                inregs.h.dl = drive & 0xff;                
                segregs.es  = seg_buf;                     
                inregs.x.bx = off_buf;                     

                
                int86x(0x13, &inregs, &outregs, &segregs);

                if (outregs.x.cflag == 0)
                   done = 1;
            }
        }

        
        free(afl_buffer);

        if (!done) {
            i = outregs.h.ah;
        } else {
            i = OK;
        }

    
    } else {
        i = OUT_OF_MEM;
    }

    return (i);
}
void prxy(int x,int y,int c,char *fmt,...)
{
    unsigned char str[140];
    va_list ap;

    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);

    textcolor(c);
    gotoxy(x+1,y+1);
    cprintf("%s",str);
}
void kcheck(void)
{
    if (kbhit()) {
        getch();
        prxy(0,24,14,"Operation Aborted Press any key to exit !");
        getch();
        textcolor(7);
        clrscr();
        exit(1);
    }
}
//if (read_sectors(0,j,i,1,18,cpbuf)) {
//if (write_sectors(0,j,i,1,18,buf)) {
//if (format_track(0,j,i)) {
int main(int argc,char *argv[])
{
    int i,j,fd,d;
    uchar *buf;
	if (argc<3) {
		printf("dcopy Drive: filename\n");
		return(0);
	}
	d=toupper(argv[1][0])-'A';
	if ((d<0)|(d>1))  {
		printf("Drive should be a: or b:\n");
		return(0);
	}
    buf=malloc(512*18);
	fd=open(argv[2],O_RDWR|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE);
	if (fd==(-1)) {
		printf("Can't Open File %s\n",argv[2]);
		return(0);
	}
    getdiskinfo(0);
    G_di.numt++;
	write(fd,&G_di,sizeof(G_di));
    for (i=0;i<G_di.numt;i++) {
        for (j=0;j<=G_di.numh;j++) {
	        printf("Track %02d Head %02d Number of Sectors %d",i,j,G_di.nums);
            if (read_sectors(0,j,i,1,G_di.nums,buf)==OK) {
				write(fd,buf,DEFSECSZ*G_di.nums);
            }
	        printf("\r");
        }
    }
	close(fd);
    printf("\n");
    return(0);
}
