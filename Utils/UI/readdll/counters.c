#include <windows.h>
#include <stdio.h>
#include <memory.h>
#include <ctype.h>
#include <malloc.h>
#include <dir.h>

typedef char CHAR;
typedef int  INT;

#define    RT_NEWRESOURCE      0x2000
#define    RT_ERROR            0x7fff
//#define    RT_CURSOR           1
//#define    RT_BITMAP           2
//#define    RT_ICON             3
//#define    RT_MENU             4
//#define    RT_DIALOG           5
//#define    RT_STRING           6
//#define    RT_FONTDIR          7
//#define    RT_FONT             8
//#define    RT_ACCELERATOR     9
//#define    RT_RCDATA           10
//#define    RT_MESSAGETABLE     11
//#define    RT_GROUP_CURSOR     12
//#define    RT_GROUP_ICON       14
//#define    RT_VERSION          16
#define    RT_NEWBITMAP        (RT_BITMAP|RT_NEWRESOURCE)
#define    RT_NEWMENU          (RT_MENU|RT_NEWRESOURCE)
#define    RT_NEWDIALOG        (RT_DIALOG|RT_NEWRESOURCE)

#define FA_NORMAL   0x00        /* Normal file, no attributes */
#define FA_RDONLY   0x01        /* Read only attribute */
#define FA_HIDDEN   0x02        /* Hidden file */
#define FA_SYSTEM   0x04        /* System file */
#define FA_LABEL    0x08        /* Volume label */
#define FA_DIREC    0x10        /* Directory */
#define FA_ARCH     0x20        /* Archive */

#define DLLFUNC FAR PASCAL _export
#define FILEATTR      FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DIRATTR       FA_DIREC

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
/*
typedef struct {        // DOS .EXE header
    WORD  e_magic     ; // Magic number
    WORD  e_cblp      ; // Bytes on last page of file
    WORD  e_cp        ; // Pages in file
    WORD  e_crlc      ; // Relocations
    WORD  e_cparhdr   ; // Size of header in paragraphs
    WORD  e_minalloc  ; // Minimum extra paragraphs needed
    WORD  e_maxalloc  ; // Maximum extra paragraphs needed
    WORD  e_ss        ; // Initial (relative) SS value
    WORD  e_sp        ; // Initial SP value
    WORD  e_csum      ; // Checksum
    WORD  e_ip        ; // Initial IP value
    WORD  e_cs        ; // Initial (relative) CS value
    WORD  e_lfarlc    ; // File address of relocation table
    WORD  e_ovno      ; // Overlay number
    WORD  e_res[4]    ; // Reserved words
    WORD  e_oemid     ; // OEM identifier (for e_oeminfo)
    WORD  e_oeminfo   ; // OEM information; e_oemid specific
    WORD  e_res2[10]  ; // Reserved words
    LONG  e_lfanew    ; // File address of new exe header

} IMAGE_DOS_HEADER;

typedef struct {
    WORD   Machine              ;
    WORD   NumberOfSections     ;
    DWORD  TimeDateStamp        ;
    DWORD  PointerToSymbolTable ;
    DWORD  NumberOfSymbols      ;
    WORD   SizeOfOptionalHeader ;
    WORD   Characteristics      ;
} IMAGE_FILE_HEADER;

typedef struct {
    DWORD VirtualAddress ;
    DWORD Size           ;
} IMAGE_DATA_DIRECTORY;

typedef struct {
    WORD  Magic                       ; // Standard fields.
    BYTE  MajorLinkerVersion          ;
    BYTE  MinorLinkerVersion          ;
    DWORD SizeOfCode                  ;
    DWORD SizeOfInitializedData       ;
    DWORD SizeOfUninitializedData     ;
    DWORD AddressOfEntryPoint         ;
    DWORD BaseOfCode                  ;
    DWORD BaseOfData                  ;
    DWORD ImageBase                   ; // NT additional fields.
    DWORD SectionAlignment            ;
    DWORD FileAlignment               ;
    WORD  MajorOperatingSystemVersion ;
    WORD  MinorOperatingSystemVersion ;
    WORD  MajorImageVersion           ;
    WORD  MinorImageVersion           ;
    WORD  MajorSubsystemVersion       ;
    WORD  MinorSubsystemVersion       ;
    DWORD Reserved1                   ;
    DWORD SizeOfImage                 ;
    DWORD SizeOfHeaders               ;
    DWORD CheckSum                    ;
    WORD  Subsystem                   ;
    WORD  DllCharacteristics          ;
    DWORD SizeOfStackReserve          ;
    DWORD SizeOfStackCommit           ;
    DWORD SizeOfHeapReserve           ;
    DWORD SizeOfHeapCommit            ;
    DWORD LoaderFlags                 ;
    DWORD NumberOfRvaAndSizes         ;
    IMAGE_DATA_DIRECTORY DataDirectory[IMAGE_NUMBEROF_DIRECTORY_ENTRIES];
} IMAGE_OPTIONAL_HEADER;

typedef struct {
    CHAR Name[IMAGE_SIZEOF_SHORT_NAME];
    DWORD PhysicalAddress      ; // or VirtualSize (union);
    DWORD VirtualAddress       ;
    DWORD SizeOfRawData        ;
    DWORD PointerToRawData     ;
    DWORD PointerToRelocations ;
    DWORD PointerToLinenumbers ;
    WORD  NumberOfRelocations  ;
    WORD  NumberOfLinenumbers  ;
    DWORD Characteristics      ;
} IMAGE_SECTION_HEADER;

typedef struct {
    DWORD                 Signature      ;
    IMAGE_FILE_HEADER     FileHeader     ;
    IMAGE_OPTIONAL_HEADER OptionalHeader ;
} IMAGE_NT_HEADERS;


typedef struct {
    DWORD Characteristics      ;
    DWORD TimeDateStamp        ;
    WORD  MajorVersion         ;
    WORD  MinorVersion         ;
    WORD  NumberOfNamedEntries ;
    WORD  NumberOfIdEntries    ;
} IMAGE_RESOURCE_DIRECTORY;


//typedef struct {
//    Length          : WORD;
//    NameString      : array [0..0] of WCHAR;
//} IMAGE_RESOURCE_DIR_STRING_U;
*/
typedef struct {
    DWORD Name        ;        // Or ID: Word (Union)
    DWORD OffsetToData;
} IMAGE_RESOURCE_DIRECTORY_ENTRYmd;

typedef struct {
    DWORD OffsetToData ; 
    DWORD Size         ;
    DWORD CodePage     ;
    DWORD Reserved     ;
} IMAGE_RESOURCE_DATA_ENTRYmd;



typedef struct {
    DWORD style;
    DWORD dwExtendedStyle;
    WORD  numitem;
    WORD  x;
    WORD  y;
    WORD  w;
    WORD  h;
} DIALOGHEAD;

typedef struct {
    WORD  id;
    DWORD style;
    DWORD dwExtstyle;
    WORD  x;
    WORD  y;
    WORD  w;
    WORD  h;
    WORD  res[3];
} CONTROL;

CHAR G_dll[256];

void PrType(FILE *fp,LONG base,LONG offset,FILE *ofp)
{
    CHAR buffer[100];
    CHAR name[100];
    CHAR *buf;
    fseek(fp,base+offset,SEEK_SET);
    if (fread(buffer,1,4,fp)==4) {
        if (memcmp(buffer,"TPF0",4)==0) {
            if (fread(buffer,1,100,fp)==100) {
                buf=buffer;
                buf+=(*buf)+1;
                memcpy(name,buf+1,*buf);
                name[*buf]=0;
                fprintf(ofp,"%s\n%s\n",G_dll,name);
            }
        }
    }
}
void TraverseDataEntry(FILE *fp,DWORD addr,DWORD base,DWORD rva,FILE *ofp)
{
    IMAGE_RESOURCE_DATA_ENTRYmd rdate;
    fseek(fp,base+addr,SEEK_SET);
    if (fread(&rdate,1,sizeof(IMAGE_RESOURCE_DATA_ENTRYmd),fp)==sizeof(IMAGE_RESOURCE_DATA_ENTRYmd)) {
        PrType(fp,base,rdate.OffsetToData-rva,ofp);
    }
}
void TraverseDir(FILE *fp,DWORD addr,DWORD base,DWORD rva,INT type,FILE *ofp)
{
    static INT dent=0;
    INT entry;
    IMAGE_RESOURCE_DIRECTORY rdir;
    IMAGE_RESOURCE_DIRECTORY_ENTRYmd rdire;

    dent++;
    fseek(fp,base+addr,SEEK_SET);
    if (fread(&rdir,1,sizeof(IMAGE_RESOURCE_DIRECTORY),fp)==sizeof(IMAGE_RESOURCE_DIRECTORY)) {
        for (entry=0;entry<rdir.NumberOfIdEntries+rdir.NumberOfNamedEntries;entry++) {
            fseek(fp,base+addr+sizeof(IMAGE_RESOURCE_DIRECTORY)+entry*sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRYmd),SEEK_SET);
            if (fread(&rdire,1,sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRYmd),fp)==sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRYmd)) {
                if ((rdire.OffsetToData&0x80000000L)!=0) {
                    if ((rdire.Name<=16)&&(dent==1)) type=rdire.Name;
                    TraverseDir(fp,rdire.OffsetToData&0x7FFFFFFFL,base,rva,type,ofp);
                } else {
                    TraverseDataEntry(fp,rdire.OffsetToData&0x7FFFFFFFL,base,rva,ofp);
                }
            }
        }
    }
}
void ListForms(CHAR *dll,FILE *ofp)
{
    FILE *fp;
    IMAGE_DOS_HEADER head;
    IMAGE_NT_HEADERS nthead;
    IMAGE_SECTION_HEADER shead;
    INT sect;

    strcpy(G_dll,dll);
    G_dll[strlen(G_dll)-4]=0;

    if ((fp=fopen(dll,"rb"))==NULL) return;

    if (fread(&head,1,sizeof(IMAGE_DOS_HEADER),fp)==sizeof(IMAGE_DOS_HEADER)) {
        if (head.e_magic==IMAGE_DOS_SIGNATURE) {
            fseek(fp,head.e_lfanew,SEEK_SET);
            if (fread(&nthead,1,sizeof(IMAGE_NT_HEADERS),fp)==sizeof(IMAGE_NT_HEADERS)) {
                if (nthead.Signature==IMAGE_NT_SIGNATURE) {
                    for (sect=0;sect<nthead.FileHeader.NumberOfSections;sect++) {
                        if (fread(&shead,1,sizeof(IMAGE_SECTION_HEADER),fp)==sizeof(IMAGE_SECTION_HEADER)) {
                            if (!memcmp(shead.Name,".rsrc",5)) {
                                TraverseDir(fp,0,shead.PointerToRawData,shead.VirtualAddress,0,ofp);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    fclose(fp);
}
void DLLFUNC CreateFormList(CHAR *filename)
{
    FILE *fp;
    struct ffblk f;
    int done;

    if ((fp=fopen(filename,"w"))==NULL) return;

    done=findfirst("*.DLL",&f,FILEATTR);
    while (done!=(-1)) {
        ListForms(f.ff_name,fp);
        done=findnext(&f);
    }
    fclose(fp);
}
