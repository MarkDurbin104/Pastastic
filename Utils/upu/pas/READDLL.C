#include <windows.h>
#include <stdio.h>
#include <io.h>
#include <memory.h>
#include <ctype.h>
#include <malloc.h>

typedef char CHAR;
typedef unsigned char UCHAR;
typedef int  INT;
typedef int  BOOL;

#define TRUE  1
#define FALSE 0

#define    RT_NEWRESOURCE      0x2000
#define    RT_ERROR            0x7fff
#define    RT_ACCELERATORS     9
#define    RT_NEWBITMAP        (RT_BITMAP|RT_NEWRESOURCE)
#define    RT_NEWMENU          (RT_MENU|RT_NEWRESOURCE)
#define    RT_NEWDIALOG        (RT_DIALOG|RT_NEWRESOURCE)


#define IMAGE_DOS_SIGNATURE    0x5A4D       // MZ
#define IMAGE_OS2_SIGNATURE    0x454E       // NE
#define IMAGE_OS2_SIGNATURE_LE 0x454C       // LE
#define IMAGE_VXD_SIGNATURE    0x454C       // LE
#define IMAGE_NT_SIGNATURE     0x00004550   // PE00

#define IMAGE_SIZEOF_SHORT_NAME           8
#define IMAGE_SIZEOF_SECTION_HEADER       40
#define IMAGE_NUMBEROF_DIRECTORY_ENTRIES  16
#define IMAGE_RESOURCE_NAME_IS_STRING     0x80000000
#define IMAGE_RESOURCE_DATA_IS_DIRECTORY  0x80000000
#define IMAGE_OFFSET_STRIP_HIGH           0x7FFFFFFF


typedef struct {
    DWORD Name        ;        // Or ID: Word (Union)
    DWORD OffsetToData;
} DIRECTORY_ENTRY;

typedef struct {
    DWORD OffsetToData ;
    DWORD Size         ;
    DWORD CodePage     ;
    DWORD Reserved     ;
} DATA_ENTRY;

typedef struct tlist {
    struct tlist *next;
    struct tlist *sub;
    INT ident;
    INT datasize;
    UCHAR *data;
} TLIST;

CHAR *G_buffer;
INT  G_buflen=0;
INT  G_blksize=0;

BOOL getblock(void *buf,INT *ofs,INT size)
{
    if (*ofs+size>G_buflen) return FALSE;
    memcpy(buf,G_buffer+*ofs,size);
    *ofs+=size;
    return TRUE;
}
void TraverseDataEntry(CHAR *buf,DWORD addr,DWORD base,DWORD rva,INT dent,INT type,DWORD pid)
{
    DATA_ENTRY rdate;
    INT ofs=base+addr;
    if (getblock(&rdate,&ofs,sizeof(DATA_ENTRY))) {
        if (buf!=NULL) {
            memcpy(buf+G_blksize,G_buffer+base+rdate.OffsetToData-rva,rdate.Size);
        }
        G_blksize+=rdate.Size;
        if (buf==NULL) printf("%*.*sAddress  %08lX (Actual %08lX,base %08lX,rva %08lX)\n",dent,dent,"",base+rdate.OffsetToData-rva,rdate.OffsetToData,base,rva);
        if (buf==NULL) printf("%*.*sSize     %08lX\n",dent,dent,"",rdate.Size);
        if (buf==NULL) printf("%*.*sCodePage %08lX\n",dent,dent,"",rdate.CodePage);
        if (buf==NULL) printf("%*.*sReserved %08lX\n",dent,dent,"",rdate.Reserved);
    }
}
void TraverseDir(CHAR *buf,DWORD addr,DWORD base,DWORD rva,INT dent,INT type,DWORD pid)
{
    INT entry;
    IMAGE_RESOURCE_DIRECTORY rdir;
    DIRECTORY_ENTRY rdire;
    INT ofs;

    ofs=base+addr;
    if (getblock(&rdir,&ofs,sizeof(IMAGE_RESOURCE_DIRECTORY))) {
        if (buf==NULL) printf("%*.*sDirectory With %d Entries and %d Named Entries\n",dent,dent,"",rdir.NumberOfIdEntries,rdir.NumberOfNamedEntries);
        for (entry=0;entry<rdir.NumberOfIdEntries+rdir.NumberOfNamedEntries;entry++) {
            if (getblock(&rdire,&ofs,sizeof(DIRECTORY_ENTRY))) {
                if ((rdire.OffsetToData&0x80000000L)!=0) {
                    if (dent==0) type=rdire.Name;
                    if ((type==5)||(type==6)) {
                        if (buf==NULL) printf("%*.*sName   %08lX at %08lX\n",dent,dent,"",rdire.Name,ofs);
                        if (buf==NULL) printf("%*.*sOffset %08lX\n",dent,dent,"",rdire.OffsetToData);
                        if (buf==NULL) printf("%*.*sDirectory offset %08lX restype %d\n",dent,dent,"",rdire.OffsetToData+base,type);
                        TraverseDir(buf,rdire.OffsetToData&0x7FFFFFFFL,base,rva,dent+4,type,rdire.Name);
                    }
                } else {
                    if (buf==NULL) printf("%*.*sDirectory offset %08lX at %08lX\n",dent,dent,"",rdire.OffsetToData+base,ofs);
                    if (buf==NULL) printf("%*.*sContaining Data at %08lX :-\n",dent,dent,"",(rdire.OffsetToData&0x7FFFFFFFL)+base);
                    TraverseDataEntry(buf,rdire.OffsetToData&0x7FFFFFFFL,base,rva,dent+4,type,pid);
                }
            }
        }
    }
}
int main(int argc,char *argv[])
{
    FILE *fp;
    INT ofs;
    CHAR *buf=NULL;
    IMAGE_DOS_HEADER head;
    IMAGE_NT_HEADERS nthead;
    IMAGE_SECTION_HEADER shead;
    INT sect;
    
    if (argc<2) return 1;

    if ((fp=fopen(argv[1],"rb"))==NULL) return 2;

    G_buflen=filelength(fp->fd);
    if ((G_buffer=malloc(G_buflen))==NULL) return 1;
    fread(G_buffer,1,G_buflen,fp);
    fclose(fp);

    G_blksize=0;
    printf("File Length = %08lX\n",G_buflen);
    ofs=0;
    if (getblock(&head,&ofs,sizeof(IMAGE_DOS_HEADER))) {
        if (head.e_magic==IMAGE_DOS_SIGNATURE) {
            ofs=head.e_lfanew;
            if (getblock(&nthead,&ofs,sizeof(IMAGE_NT_HEADERS))) {
                if (nthead.Signature==IMAGE_NT_SIGNATURE) {
                    printf("%d sections\n",nthead.FileHeader.NumberOfSections);
                    for (sect=0;sect<nthead.FileHeader.NumberOfSections;sect++) {
                        if (getblock(&shead,&ofs,sizeof(IMAGE_SECTION_HEADER))) {
                            printf("Header %s rva=%08lX Address %08lX\n",shead.Name,shead.VirtualAddress,shead.PointerToRawData);
                            if (!memcmp(shead.Name,".rsrc",5)) {
                                TraverseDir(buf,0,shead.PointerToRawData,shead.VirtualAddress,0,0,0);
                            }
                        }
                    }
                }
            }
        }
    }
    printf("Block to copy %d\n",G_blksize);
    if ((buf=malloc(G_blksize))==NULL) return 0;
    G_blksize=0;
    ofs=0;
    if (getblock(&head,&ofs,sizeof(IMAGE_DOS_HEADER))) {
        if (head.e_magic==IMAGE_DOS_SIGNATURE) {
            ofs=head.e_lfanew;
            if (getblock(&nthead,&ofs,sizeof(IMAGE_NT_HEADERS))) {
                if (nthead.Signature==IMAGE_NT_SIGNATURE) {
                    printf("%d sections\n",nthead.FileHeader.NumberOfSections);
                    for (sect=0;sect<nthead.FileHeader.NumberOfSections;sect++) {
                        if (getblock(&shead,&ofs,sizeof(IMAGE_SECTION_HEADER))) {
                            printf("Header %s rva=%08lX Address %08lX\n",shead.Name,shead.VirtualAddress,shead.PointerToRawData);
                            if (!memcmp(shead.Name,".rsrc",5)) {
                                TraverseDir(buf,0,shead.PointerToRawData,shead.VirtualAddress,0,0,0);
                            }
                        }
                    }
                }
            }
        }
    }
    free(G_buffer);
    free(buf);
    return 0;
}
