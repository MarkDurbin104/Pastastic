#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <memory.h>
#include <ctype.h>
#include <malloc.h>
#include "deballoc.h"

FILE *G_ofp;

typedef char CHAR;
typedef int  INT;

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

#ifndef __FLAT__
#define    RT_MESSAGETABLE     11
#define    RT_VERSION          16

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

#endif // ndef __FLAT__

typedef struct {
    DWORD Name        ;        // Or ID: Word (Union)
    DWORD OffsetToData;
} I_RESOURCE_DIRECTORY_ENTRY;

typedef struct {
    DWORD OffsetToData ;
    DWORD Size         ;
    DWORD CodePage     ;
    DWORD Reserved     ;
} I_RESOURCE_DATA_ENTRY;

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
    DWORD style;
    DWORD dwExtstyle;
    WORD  x;
    WORD  y;
    WORD  w;
    WORD  h;
    WORD  wid;
} CONTROL;

typedef struct {
    WORD  dlgVer;
    WORD  signature;
    DWORD HelpID;
    DWORD dwExtendedStyle;
    DWORD style;
    WORD  numitem;
    WORD  x;
    WORD  y;
    WORD  w;
    WORD  h;
} DIALOGHEADEX;

typedef struct {
    DWORD HelpID;
    DWORD dwExtstyle;
    DWORD style;
    WORD  x;
    WORD  y;
    WORD  w;
    WORD  h;
    DWORD wid;
} CONTROLEX;

#define BUTTON    0x0080
#define EDIT      0x0081
#define STATIC    0x0082
#define LISTBOX   0x0083
#define SCROLLBAR 0x0084
#define COMBOBOX  0x0085
#define TESTFLG(a,b) ((a&b)==b)

void DumpStrings(FILE *fp,LONG base,LONG offset,INT size,LONG id,INT e)
{
    WORD *buffer,len;
    INT i,count,eid;
    if ((buffer=MALLOC(size))==NULL) {
        return;
    }
    fseek(fp,base+offset,SEEK_SET);
    if (fread(buffer,1,size,fp)!=size) {
        FREE(buffer);
        return;
    }
    count=0;
    eid=0;
    while (count<(size/sizeof(WORD))) {
        len=buffer[count++];
        if (len>0) {
            fprintf(G_ofp,"S<^>%ld\n",id);
            if (!e) {
                for (i=0;i<len;i++) {
                    switch (buffer[count]) {
                        case '\n' :
                            fprintf(G_ofp,"\\n");
                            break;
                        case '\r' :
                            fprintf(G_ofp,"\\r");
                            break;
                        case '\t' :
                            fprintf(G_ofp,"\\t");
                            break;
                        case '\\' :
                            fprintf(G_ofp,"\\\\");
                            break;
                        default:
                            fprintf(G_ofp,"%c",buffer[count]);
                    }
                    count++;
                }
            } else {
                count+=len;
            }
            fprintf(G_ofp,"\n");
        }
        id++;
        eid++;
        if (eid==16) break;
    }
    FREE(buffer);
}
WORD *addunistr(CHAR *str,WORD *ptr)
{
    while (*ptr) {
        switch ((CHAR)*ptr) {
            case '\n' :
                *(str++)='\\';
                *(str++)='n';
                break;
            case '\r' :
                *(str++)='\\';
                *(str++)='r';
                break;
            case '\t' :
                *(str++)='\\';
                *(str++)='t';
                break;
            case '\\' :
                *(str++)='\\';
                *(str++)='\\';
                break;
            default:
                if (*ptr>127) {
                   *(str++)='\\';
                   *(str++)=(CHAR)('0'+(*ptr/64)  );
                   *(str++)=(CHAR)('0'+(*ptr%64)/8);
                   *(str++)=(CHAR)('0'+(*ptr%8)   );
                } else {
                    *(str++)=(CHAR)(*ptr);
                }
        }
        ptr++;
    }
    *str=0;
    return ptr;
}
void DumpDialog(FILE *fp,LONG base,LONG offset,LONG size,DWORD id,INT e)
{
    DIALOGHEAD *dlg;
    CONTROL *cntl;
    DIALOGHEADEX *dlgex;
    CONTROLEX *cntlx;
    WORD *buffer,*ptr;
    static char dlgcapt[1000];
    static char dlgfont[1000];
    static char dlgmenu[1000];
    static char dlgclas[1000];
    static char clsclas[1000];
    static char clstext[1000];
    INT i,fs,ext=FALSE;
    if ((buffer=MALLOC((INT)size))==NULL) {
        return;
    }
    fseek(fp,base+offset,SEEK_SET);
    if (fread(buffer,1,(INT)size,fp)!=size) {
        FREE(buffer);
        return;
    }
    dlgex=(DIALOGHEADEX *)buffer;
    if ((dlgex->dlgVer==0x0001)&&(dlgex->signature==0xFFFF)) {
        ext=TRUE;
        ptr=(WORD *)(dlgex+1);

        dlgcapt[0]='\0';
        dlgfont[0]='\0';
        dlgmenu[0]='\0';
        dlgclas[0]='\0';
        if (*ptr==0xFFFF) {
            ptr++;
            sprintf(dlgmenu,"Menu id %d",*ptr);
        } else if (*ptr!=0) {
            ptr=addunistr(dlgmenu,ptr);
        }
        ptr++;
        if (*ptr==0xFFFF) {
            ptr++;
            sprintf(dlgclas,"Class id %d",*ptr);
        } else if (*ptr!=0) {
            ptr=addunistr(dlgclas,ptr);
        }
        ptr++;
        if (*ptr!=0) {
            ptr=addunistr(dlgcapt,ptr);
        }
        ptr++;
        if (!e) fprintf(G_ofp,"D<^>%ld\n%s\n",id,dlgcapt); else fprintf(G_ofp,"D<^>%ld\n\n",id);
        if (TESTFLG(dlgex->style,DS_SETFONT)) { // Font Specified
            fs=*(ptr++);
            ptr+=2;
            ptr=addunistr(dlgfont,ptr);
            ptr++;
            fprintf(G_ofp,"%d\n%s\n",fs,dlgfont);
        }
        fprintf(G_ofp,"%d\n%d\n%d\n%d\n",dlgex->x,dlgex->y,dlgex->w,dlgex->h);
        fprintf(G_ofp,"%d\n",dlgex->numitem);
    } else {
        dlg=(DIALOGHEAD *)buffer;
        ptr=(WORD *)(dlg+1);

        dlgcapt[0]='\0';
        dlgfont[0]='\0';
        dlgmenu[0]='\0';
        dlgclas[0]='\0';
        if (*ptr==0xFFFF) {
            ptr++;
            sprintf(dlgmenu,"Menu id %d",*ptr);
        } else if (*ptr!=0) {
            ptr=addunistr(dlgmenu,ptr);
        }
        ptr++;
        if (*ptr==0xFFFF) {
            ptr++;
            sprintf(dlgclas,"Class id %d",*ptr);
        } else if (*ptr!=0) {
            ptr=addunistr(dlgclas,ptr);
        }
        ptr++;
        if (*ptr!=0) {
            ptr=addunistr(dlgcapt,ptr);
        }
        ptr++;
        if (!e) fprintf(G_ofp,"D<^>%ld\n%s\n",id,dlgcapt); else fprintf(G_ofp,"D<^>%ld\n\n",id);
        if (TESTFLG(dlg->style,DS_SETFONT)) { // Font Specified
            fs=*(ptr++);
            ptr=addunistr(dlgfont,ptr);
            ptr++;
            fprintf(G_ofp,"%d\n%s\n",fs,dlgfont);
        }
        fprintf(G_ofp,"%d\n%d\n%d\n%d\n",dlg->x,dlg->y,dlg->w,dlg->h);
        fprintf(G_ofp,"%d\n",dlg->numitem);
    }
    if (ext) {
        for (i=0;i<dlgex->numitem;i++) {
            clsclas[0]='\0';
            clstext[0]='\0';
            while ((((LONG)ptr)%4)!=0) ptr++;
            cntlx=(CONTROLEX *)ptr;
            ptr=(WORD *)(cntlx+1);
            if (*ptr==0xFFFF) {
                ptr++;
                switch (*ptr) {
                    case BUTTON    :
                        switch (cntlx->style&0x0000000FL) {
                            case BS_PUSHBUTTON      :
                                sprintf(clsclas,"P\n");
                                break;
                            case BS_DEFPUSHBUTTON   :
                                sprintf(clsclas,"D\n");
                                break;
                            case BS_GROUPBOX      :
                                sprintf(clsclas,"G\n");
                                break;
                            case BS_AUTO3STATE      :
                            case BS_3STATE          :
                            case BS_AUTOCHECKBOX    :
                            case BS_CHECKBOX        :
                                sprintf(clsclas,"2\n");
                                break;
                            case BS_AUTORADIOBUTTON :
                            case BS_RADIOBUTTON     :
                                sprintf(clsclas,"3\n");
                                break;
                            default:
                                sprintf(clsclas,"O\n");
                        }
                        break;
                    case EDIT      :
                        sprintf(clsclas,"E\n");
                        break;
                    case STATIC    :
                        switch (cntlx->style&0x0000000FL) {
                            case SS_LEFTNOWORDWRAP :
                            case SS_LEFT           :
                                sprintf(clsclas,"L\n");
                                break;
                            case SS_CENTER         :
                                sprintf(clsclas,"T\n");
                                break;
                            case SS_RIGHT          :
                                sprintf(clsclas,"R\n");
                                break;
                            case SS_ICON           :
                                sprintf(clsclas,"I\n");
                                break;
                            case SS_BLACKRECT      :
                            case SS_GRAYRECT       :
                            case SS_WHITERECT      :
                            case SS_BLACKFRAME     :
                            case SS_GRAYFRAME      :
                            case SS_WHITEFRAME     :
                            case SS_SIMPLE         :
                                sprintf(clsclas,"1\n");
                                break;
                            default:
                                sprintf(clsclas,"O\n");
                        }
                        break;
                    case LISTBOX   :
                        sprintf(clsclas,"B\n");
                        break;
                    case COMBOBOX  :
                        sprintf(clsclas,"C\n");
                        break;
                    default:
                        sprintf(clsclas,"O\n");
                }
            } else {
                sprintf(clsclas,"O");
                ptr=addunistr(clsclas+1,ptr);
                strcat(clsclas,"\n");
//                fprintf(G_ofp,"\n");
            }
            ptr++;
            fprintf(G_ofp,"%c\n",clsclas[0]);
            if (*ptr==0xFFFF) {
                ptr++;
                fprintf(G_ofp,"id %04X\n",*ptr);
            } else {
                ptr=addunistr(clstext,ptr);
                if (!e) fprintf(G_ofp,"%s\n",clstext); else fprintf(G_ofp,"\n");
            }
            ptr++;
            ptr+=(*ptr)/sizeof(WORD);
            ptr++;
            fprintf(G_ofp,"%s%d\n%d\n%d\n%d\n%d\n",clsclas+1,cntlx->x,cntlx->y,cntlx->w,cntlx->h,i);
        }
    } else {
        for (i=0;i<dlg->numitem;i++) {
            clsclas[0]='\0';
            clstext[0]='\0';
            while ((((LONG)ptr)%4)!=0) ptr++;
            cntl=(CONTROL *)ptr;
            while (cntl->style==0) cntl=(CONTROL *)(((DWORD *)cntl)+1);
            ptr=(WORD *)(cntl+1);
            if (*ptr==0xFFFF) {
                ptr++;
                switch (*ptr) {
                    case BUTTON    :
                        switch (cntl->style&0x0000000FL) {
                            case BS_USERBUTTON      :
                            case BS_OWNERDRAW       :
                            case BS_PUSHBUTTON      :
                                sprintf(clsclas,"P\n");
                                break;
                            case BS_DEFPUSHBUTTON   :
                                sprintf(clsclas,"D\n");
                                break;
                            case BS_GROUPBOX      :
                                sprintf(clsclas,"G\n");
                                break;
                            case BS_AUTO3STATE      :
                            case BS_3STATE          :
                            case BS_AUTOCHECKBOX    :
                            case BS_CHECKBOX        :
                                sprintf(clsclas,"2\n");
                                break;
                            case BS_AUTORADIOBUTTON :
                            case BS_RADIOBUTTON     :
                                sprintf(clsclas,"3\n");
                                break;
                            default:
                                sprintf(clsclas,"O\n");
                        }
                        break;
                    case EDIT      :
                        sprintf(clsclas,"E\n");
                        break;
                    case STATIC    :
                        switch (cntl->style&0x0000000FL) {
                            case SS_LEFTNOWORDWRAP :
                            case SS_LEFT           :
                                sprintf(clsclas,"L\n");
                                break;
                            case SS_CENTER         :
                                sprintf(clsclas,"T\n");
                                break;
                            case SS_RIGHT          :
                                sprintf(clsclas,"R\n");
                                break;
                            case SS_ICON           :
                                sprintf(clsclas,"I\n");
                                break;
                            case SS_BLACKRECT      :
                            case SS_GRAYRECT       :
                            case SS_WHITERECT      :
                            case SS_BLACKFRAME     :
                            case SS_GRAYFRAME      :
                            case SS_WHITEFRAME     :
                            case SS_SIMPLE         :
                                sprintf(clsclas,"1\n");
                                break;
                            default:
                                sprintf(clsclas,"O\n");
                        }
                        break;
                    case LISTBOX   :
                        sprintf(clsclas,"B\n");
                        break;
                    case COMBOBOX  :
                        sprintf(clsclas,"C\n");
                        break;
                    default:
                        sprintf(clsclas,"O\n");
                }
            } else {
                sprintf(clsclas,"O");
                ptr=addunistr(clsclas+1,ptr);
                strcat(clsclas,"\n");
//                fprintf(G_ofp,"\n");
            }
            ptr++;
            fprintf(G_ofp,"%c\n",clsclas[0]);
            if (*ptr==0xFFFF) {
                ptr++;
                fprintf(G_ofp,"id %04X\n",*ptr);
            } else {
                ptr=addunistr(clstext,ptr);
                if (!e) fprintf(G_ofp,"%s\n",clstext); else fprintf(G_ofp,"\n");
            }
            ptr++;
            fprintf(G_ofp,"%s%d\n%d\n%d\n%d\n%d\n",clsclas+1,cntl->x,cntl->y,cntl->w,cntl->h,i);
        }
    }

    FREE(buffer);
}
void TraverseDataEntry(FILE *fp,DWORD addr,DWORD base,DWORD rva,DWORD id,INT type,DWORD pid,INT e)
{
    I_RESOURCE_DATA_ENTRY rdate;
    fseek(fp,base+addr,SEEK_SET);
    if (fread(&rdate,1,sizeof(I_RESOURCE_DATA_ENTRY),fp)==sizeof(I_RESOURCE_DATA_ENTRY)) {
        if (type==(DWORD)RT_STRING) {
            DumpStrings(fp,base,rdate.OffsetToData-rva,rdate.Size,(pid-1)<<4,e);
        } else if (type==(DWORD)RT_DIALOG) {
            DumpDialog(fp,base,rdate.OffsetToData-rva,rdate.Size,id,e);
        }
    }
}
void TraverseDir(FILE *fp,DWORD addr,DWORD base,DWORD rva,INT type,DWORD pid,INT e)
{
    static int level=0;
    static DWORD id;
    INT entry;
    IMAGE_RESOURCE_DIRECTORY rdir;
    I_RESOURCE_DIRECTORY_ENTRY rdire;

    level++;
    fseek(fp,base+addr,SEEK_SET);
    if (fread(&rdir,1,sizeof(IMAGE_RESOURCE_DIRECTORY),fp)==sizeof(IMAGE_RESOURCE_DIRECTORY)) {
        for (entry=0;entry<rdir.NumberOfIdEntries+rdir.NumberOfNamedEntries;entry++) {
            fseek(fp,base+addr+sizeof(IMAGE_RESOURCE_DIRECTORY)+entry*sizeof(I_RESOURCE_DIRECTORY_ENTRY),SEEK_SET);
            if (fread(&rdire,1,sizeof(I_RESOURCE_DIRECTORY_ENTRY),fp)==sizeof(I_RESOURCE_DIRECTORY_ENTRY)) {
                if ((rdire.OffsetToData&0x80000000L)!=0) {
                    if ((rdire.Name<=16)&&(level==1)) type=(INT)rdire.Name;
                    id=rdire.Name;
                    TraverseDir(fp,rdire.OffsetToData&0x7FFFFFFFL,base,rva,type,rdire.Name,e);
                } else {
                    TraverseDataEntry(fp,rdire.OffsetToData&0x7FFFFFFFL,base,rva,id,type,pid,e);
                }
            }
        }
    }
    level--;
}
void DumpStringsO(FILE *fp,LONG base,LONG offset,INT size,LONG id,INT e)
{
    WORD *buffer,len;
    INT i,count,eid;
    if ((buffer=MALLOC(size))==NULL) {
        return;
    }
    fseek(fp,base+offset,SEEK_SET);
    if (fread(buffer,1,size,fp)!=size) {
        FREE(buffer);
        return;
    }
    count=0;
    eid=0;
    while (count<(size/sizeof(WORD))) {
        len=buffer[count++];
        if (len>0) {
            if (!e) {
                for (i=0;i<len;i++) {
                    switch (buffer[count]) {
                        case '\n' :
                            fprintf(G_ofp,"\\n");
                            break;
                        case '\r' :
                            fprintf(G_ofp,"\\r");
                            break;
                        case '\t' :
                            fprintf(G_ofp,"\\t");
                            break;
                        case '\\' :
                            fprintf(G_ofp,"\\\\");
                            break;
                        default:
                            fprintf(G_ofp,"%c",buffer[count]);
                    }
                    count++;
                }
            } else {
                count+=len;
            }
            fprintf(G_ofp,"\n");
        }
        id++;
        eid++;
        if (eid==16) break;
    }
    FREE(buffer);
}
void DumpDialogO(FILE *fp,LONG base,LONG offset,LONG size,DWORD id,INT e)
{
    DIALOGHEAD *dlg;
    CONTROL *cntl;
    DIALOGHEADEX *dlgex;
    CONTROLEX *cntlx;
    WORD *buffer,*ptr;
    static char dlgcapt[1000];
    static char dlgfont[1000];
    static char dlgmenu[1000];
    static char dlgclas[1000];
    static char clsclas[1000];
    static char clstext[1000];
    INT i,fs,ext=FALSE;
    if ((buffer=MALLOC((INT)size))==NULL) {
        return;
    }
    fseek(fp,base+offset,SEEK_SET);
    if (fread(buffer,1,(INT)size,fp)!=size) {
        FREE(buffer);
        return;
    }
    dlgex=(DIALOGHEADEX *)buffer;
    if ((dlgex->dlgVer==0x0001)&&(dlgex->signature==0xFFFF)) {
        ext=TRUE;
        ptr=(WORD *)(dlgex+1);

        dlgcapt[0]='\0';
        dlgfont[0]='\0';
        if (*ptr==0xFFFF) { 
            ptr++;
        } else if (*ptr!=0) {
            while (*ptr) ptr++;
        }
        ptr++;
        if (*ptr==0xFFFF) {
            ptr++;
        } else if (*ptr!=0) {
            while (*ptr) ptr++;
        }
        ptr++;
        if (*ptr!=0) {
            ptr=addunistr(dlgcapt,ptr);
        }
        ptr++;
        if (!e) fprintf(G_ofp,"%s\n",dlgcapt); else fprintf(G_ofp,"\n");
        if (TESTFLG(dlgex->style,DS_SETFONT)) { // Font Specified
            fs=*(ptr++);
            ptr+=2;
            ptr=addunistr(dlgfont,ptr);
            ptr++;
            fprintf(G_ofp,"%s\n",dlgfont);
        }
    } else {
        dlg=(DIALOGHEAD *)buffer;
        ptr=(WORD *)(dlg+1);

        dlgcapt[0]='\0';
        dlgfont[0]='\0';
        dlgmenu[0]='\0';
        dlgclas[0]='\0';
        if (*ptr==0xFFFF) {
            ptr++;
        } else if (*ptr!=0) {
            while (*ptr) ptr++;
        }
        ptr++;
        if (*ptr==0xFFFF) {
            ptr++;
        } else if (*ptr!=0) {
            while (*ptr) ptr++;
        }
        ptr++;
        if (*ptr!=0) {
            ptr=addunistr(dlgcapt,ptr);
        }
        ptr++;
        if (!e) fprintf(G_ofp,"%s\n",dlgcapt); else fprintf(G_ofp,"\n");
        if (TESTFLG(dlg->style,DS_SETFONT)) { // Font Specified
            fs=*(ptr++);
            ptr=addunistr(dlgfont,ptr);
            ptr++;
            fprintf(G_ofp,"%s\n",dlgfont);
        }
    }
    if (ext) {
        for (i=0;i<dlgex->numitem;i++) {
            clsclas[0]='\0';
            clstext[0]='\0';
            while ((((LONG)ptr)%4)!=0) ptr++;
            cntlx=(CONTROLEX *)ptr;
            ptr=(WORD *)(cntlx+1);
            if (*ptr==0xFFFF) {
                ptr++;
            } else {
                while (*ptr) ptr++;
            }
            ptr++;
            if (*ptr==0xFFFF) {
                ptr++;
            } else {
                ptr=addunistr(clstext,ptr);
                if (!e) fprintf(G_ofp,"%s\n",clstext); else fprintf(G_ofp,"\n");
            }
            ptr++;
            ptr+=(*ptr)/sizeof(WORD);
            ptr++;
        }
    } else {
        for (i=0;i<dlg->numitem;i++) {
            clsclas[0]='\0';
            clstext[0]='\0';
            while ((((LONG)ptr)%4)!=0) ptr++;
            cntl=(CONTROL *)ptr;
            while (cntl->style==0) cntl=(CONTROL *)(((DWORD *)cntl)+1);
            ptr=(WORD *)(cntl+1);
            if (*ptr==0xFFFF) {
                ptr++;
            } else {
                while (*ptr) ptr++;
            }
            ptr++;
            if (*ptr==0xFFFF) {
                ptr++;
            } else {
                ptr=addunistr(clstext,ptr);
                if (!e) fprintf(G_ofp,"%s\n",clstext); else fprintf(G_ofp,"\n");
            }
            ptr++;
        }
    }

    FREE(buffer);
}
void TraverseDataEntryO(FILE *fp,DWORD addr,DWORD base,DWORD rva,DWORD id,INT type,DWORD pid,INT e)
{
    I_RESOURCE_DATA_ENTRY rdate;
    fseek(fp,base+addr,SEEK_SET);
    if (fread(&rdate,1,sizeof(I_RESOURCE_DATA_ENTRY),fp)==sizeof(I_RESOURCE_DATA_ENTRY)) {
        if (type==(DWORD)RT_STRING) {
            DumpStringsO(fp,base,rdate.OffsetToData-rva,rdate.Size,(pid-1)<<4,e);
        } else if (type==(DWORD)RT_DIALOG) {
            DumpDialogO(fp,base,rdate.OffsetToData-rva,rdate.Size,id,e);
        }
    }
}
void TraverseDirO(FILE *fp,DWORD addr,DWORD base,DWORD rva,INT type,DWORD pid,INT e)
{
    static int level=0;
    static DWORD id;
    INT entry;
    IMAGE_RESOURCE_DIRECTORY rdir;
    I_RESOURCE_DIRECTORY_ENTRY rdire;

    level++;
    fseek(fp,base+addr,SEEK_SET);
    if (fread(&rdir,1,sizeof(IMAGE_RESOURCE_DIRECTORY),fp)==sizeof(IMAGE_RESOURCE_DIRECTORY)) {
        for (entry=0;entry<rdir.NumberOfIdEntries+rdir.NumberOfNamedEntries;entry++) {
            fseek(fp,base+addr+sizeof(IMAGE_RESOURCE_DIRECTORY)+entry*sizeof(I_RESOURCE_DIRECTORY_ENTRY),SEEK_SET);
            if (fread(&rdire,1,sizeof(I_RESOURCE_DIRECTORY_ENTRY),fp)==sizeof(I_RESOURCE_DIRECTORY_ENTRY)) {
                if ((rdire.OffsetToData&0x80000000L)!=0) {
                    if ((rdire.Name<=16)&&(level==1)) type=(INT)rdire.Name;
                    id=rdire.Name;
                    TraverseDirO(fp,rdire.OffsetToData&0x7FFFFFFFL,base,rva,type,rdire.Name,e);
                } else {
                    TraverseDataEntryO(fp,rdire.OffsetToData&0x7FFFFFFFL,base,rva,id,type,pid,e);
                }
            }
        }
    }
    level--;
}
BOOL outdll(CHAR *name,INT e)
{
    FILE *fp;
    IMAGE_DOS_HEADER head;
    IMAGE_NT_HEADERS nthead;
    IMAGE_SECTION_HEADER shead;
    INT sect;

    if ((fp=fopen(name,"rb"))==NULL) return FALSE;
    if (fread(&head,1,sizeof(IMAGE_DOS_HEADER),fp)==sizeof(IMAGE_DOS_HEADER)) {

        if (head.e_magic==IMAGE_DOS_SIGNATURE) {
            fseek(fp,head.e_lfanew,SEEK_SET);
            if (fread(&nthead,1,sizeof(IMAGE_NT_HEADERS),fp)==sizeof(IMAGE_NT_HEADERS)) {
                if (nthead.Signature==IMAGE_NT_SIGNATURE) {
                    for (sect=0;sect<nthead.FileHeader.NumberOfSections;sect++) {
                        if (fread(&shead,1,sizeof(IMAGE_SECTION_HEADER),fp)==sizeof(IMAGE_SECTION_HEADER)) {
                            if (!memcmp(shead.Name,".rsrc",5)) {
                                TraverseDir(fp,0,shead.PointerToRawData,shead.VirtualAddress,0,0,e);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    fclose(fp);
    return TRUE;
}

BOOL outdllO(CHAR *name,INT e)
{
    FILE *fp;
    IMAGE_DOS_HEADER head;
    IMAGE_NT_HEADERS nthead;
    IMAGE_SECTION_HEADER shead;
    INT sect;

    if ((fp=fopen(name,"rb"))==NULL) return FALSE;
    if (fread(&head,1,sizeof(IMAGE_DOS_HEADER),fp)==sizeof(IMAGE_DOS_HEADER)) {

        if (head.e_magic==IMAGE_DOS_SIGNATURE) {
            fseek(fp,head.e_lfanew,SEEK_SET);
            if (fread(&nthead,1,sizeof(IMAGE_NT_HEADERS),fp)==sizeof(IMAGE_NT_HEADERS)) {
                if (nthead.Signature==IMAGE_NT_SIGNATURE) {
                    for (sect=0;sect<nthead.FileHeader.NumberOfSections;sect++) {
                        if (fread(&shead,1,sizeof(IMAGE_SECTION_HEADER),fp)==sizeof(IMAGE_SECTION_HEADER)) {
                            if (!memcmp(shead.Name,".rsrc",5)) {
                                TraverseDirO(fp,0,shead.PointerToRawData,shead.VirtualAddress,0,0,e);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    fclose(fp);
    return TRUE;
}

int main(int argc,char *argv[])
{
    INT i;
    G_ofp=stdout;
    for (i=1;i<argc;i++) outdllO(argv[i],0);
    return 0;
}

