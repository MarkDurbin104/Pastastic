#include <windows.h>
#include <stdio.h>
#include <io.h>
#include <memory.h>
#include <ctype.h>
#include <malloc.h>

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


typedef struct {
    DWORD Name        ;        // Or ID: Word (Union)
    DWORD OffsetToData;
} IMAGE_RESOURCE_DIRECTORY_ENTRY_MD;

typedef struct {
    DWORD OffsetToData ;
    DWORD Size         ;
    DWORD CodePage     ;
    DWORD Reserved     ;
} IMAGE_RESOURCE_DATA_ENTRY_MD;

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

CHAR *ResType(DWORD type,INT level)
{
    static CHAR tmp[100];

    if (level==0) {
        switch (type) {
            case RT_CURSOR      : return ("Type CURSOR      ");
            case RT_BITMAP      : return ("Type BITMAP      ");
            case RT_ICON        : return ("Type ICON        ");
            case RT_MENU        : return ("Type MENU        ");
            case RT_DIALOG      : return ("Type DIALOG      ");
            case RT_STRING      : return ("Type STRING      ");
            case RT_FONTDIR     : return ("Type FONTDIR     ");
            case RT_FONT        : return ("Type FONT        ");
            case RT_ACCELERATORS: return ("Type ACCELERATORS");
            case RT_RCDATA      : return ("Type RCDATA      ");
            case RT_MESSAGETABLE: return ("Type MESSAGETABLE");
            case RT_GROUP_CURSOR: return ("Type GROUP_CURSOR");
            case RT_GROUP_ICON  : return ("Type GROUP_ICON  ");
            case RT_VERSION     : return ("Type VERSION     ");
        }
    }
//    sprintf(tmp,"Ident %d",type);
    sprintf(tmp,"");
    return tmp;
}
void DumpStrings(FILE *fp,LONG base,LONG offset,INT size,LONG id)
{
    WORD *buffer,len;
    INT i,count,eid;
    if ((buffer=malloc(size))==NULL) {
        printf("Memory Error\n");
        return;
    }
    fseek(fp,base+offset,SEEK_SET);
    if (fread(buffer,1,size,fp)!=size) {
        free(buffer);
        printf("Read Error\n");
        return;
    }
    count=0;
    eid=0;
    while (count<(size/sizeof(WORD))) {
        len=buffer[count++];
        if (len>0) {
            printf("%ld ",id);
            for (i=0;i<len;i++) {
                printf("%c",buffer[count++]);
            }
            printf("\n");
        }
        id++;
        eid++;
        if (eid==16) break;
    }
    free(buffer);
}
void DumpBlock(FILE *fp,LONG base,LONG offset,LONG size)
{
    LONG i;
    INT j;
    CHAR buffer[16];
    fseek(fp,base+offset,SEEK_SET);
    for (i=0;i<size;i+=16) {
        if (fread(buffer,1,16,fp)==16) {
            printf("%08lX ",base+offset+i);
            for (j=0;j<16;j++) {
                if (i+j<size)
                    printf("%02X ",buffer[j]&0xFF);
                else
                    printf("   ");
            }
            for (j=0;j<16;j++) {
                if (i+j<size)
                    printf("%c",isprint(buffer[j])?buffer[j]:' ');
                else
                    printf(" ");
            }
            printf("\n");
        }
    }
    printf("\n");
}
void hd(char *block)
{
    INT i;
    i=16;
    while (i--) {
        printf("%02X ",*(block++)&0xFF);
    }
    printf("\n");

}
#define BUTTON    0x0080
#define EDIT      0x0081
#define STATIC    0x0082
#define LISTBOX   0x0083
#define SCROLLBAR 0x0084
#define COMBOBOX  0x0085
#define TESTFLG(a,b) ((a&b)==b)

void hdblock(CHAR *ptr)
{
    INT i;
    for (i=0;i<16;i++) printf("%02X ",*(ptr+i)&0xFF);
    printf("  ");
    for (i=0;i<16;i++) printf("%c",((*(ptr+i)&0xFF)>31)?(*(ptr+i)&0xFF):' ');
    printf("\n");
    ptr+=16;
    for (i=0;i<16;i++) printf("%02X ",*(ptr+i)&0xFF);
    printf("  ");
    for (i=0;i<16;i++) printf("%c",((*(ptr+i)&0xFF)>31)?(*(ptr+i)&0xFF):' ');
    printf("\n");
}
void DumpDialog(FILE *fp,LONG base,LONG offset,LONG size)
{
    DIALOGHEAD *dlg;
    DIALOGHEADEX *dlgex;
    CONTROL *cntl;
    CONTROLEX *cntlx;
    WORD *buffer,*ptr;
    BOOL ext=FALSE;
    INT i;
    if ((buffer=malloc(size))==NULL) {
        printf("Memory Error\n");
        return;
    }
    fseek(fp,base+offset,SEEK_SET);
    if (fread(buffer,1,size,fp)!=size) {
        free(buffer);
        printf("Read Error\n");
        return;
    }
    dlgex=(DIALOGHEADEX *)buffer;
    if ((dlgex->dlgVer==0x0001)&&(dlgex->signature==0xFFFF)) {
        ext=TRUE;
        printf("Dialog Style %08lX EStyle %08lX\n",dlgex->style,dlgex->dwExtendedStyle);
        printf("X=%d y=%d W=%d H=%d\n",dlgex->x,dlgex->y,dlgex->w,dlgex->h);
        printf("Containing %d Controls\n",dlgex->numitem);
        ptr=(WORD *)(dlgex+1);
        if (*ptr==0xFFFF) {
            ptr++;
            printf("Menu id %d\n",*ptr);
        } else if (*ptr!=0) {
            printf("Menu ");
            while (*ptr) printf("%c",(CHAR)(*(ptr++)));
            printf("\n");
        }
        ptr++;
        if (*ptr==0xFFFF) {
            ptr++;
            printf("Class id %d\n",*ptr);
        } else if (*ptr!=0) {
            printf("Class ");
            while (*ptr) printf("%c",(CHAR)(*(ptr++)));
            printf("\n");
        }
        ptr++;
        if (*ptr!=0) {
            printf("Caption \"");
            while (*ptr) printf("%c",(CHAR)(*(ptr++)));
            printf("\"\n");
        }
        ptr++;
        if (TESTFLG(dlgex->style,DS_SETFONT)) { // Font Specified
            printf("Font Size    %d\n",*(ptr++));
            printf("Font Weight  %d\n",*(ptr++));
            printf("Font bItalic %d\n",*(ptr++));
            printf("Font \"");
            while (*ptr) printf("%c",(CHAR)(*(ptr++)));
            printf("\"\n");
            ptr++;
        }
    } else {
        dlg=(DIALOGHEAD *)buffer;
        printf("Dialog Style %08lX EStyle %08lX\n",dlg->style,dlg->dwExtendedStyle);
        printf("X=%d y=%d W=%d H=%d\n",dlg->x,dlg->y,dlg->w,dlg->h);
        printf("Containing %d Controls\n",dlg->numitem);
        ptr=(WORD *)(dlg+1);
        if (*ptr==0xFFFF) {
            ptr++;
            printf("Menu id %d\n",*ptr);
        } else if (*ptr!=0) {
            printf("Menu ");
            while (*ptr) printf("%c",(CHAR)(*(ptr++)));
            printf("\n");
        }
        ptr++;
        if (*ptr==0xFFFF) {
            ptr++;
            printf("Class id %d\n",*ptr);
        } else if (*ptr!=0) {
            printf("Class ");
            while (*ptr) printf("%c",(CHAR)(*(ptr++)));
            printf("\n");
        }
        ptr++;
        if (*ptr!=0) {
            printf("Caption \"");
            while (*ptr) printf("%c",(CHAR)(*(ptr++)));
            printf("\"\n");
        }
        ptr++;
        if (TESTFLG(dlg->style,DS_SETFONT)) { // Font Specified
            printf("Font Size %d\n",*(ptr++));
            printf("Font \"");
            while (*ptr) printf("%c",(CHAR)(*(ptr++)));
            printf("\"\n");
            ptr++;
        }
    }
    if (ext) {
        printf("********************************************************************************\n");
        printf("********************************************************************************\n");
        printf("********************************************************************************\n");
        for (i=0;i<dlgex->numitem;i++) {
            while ((((LONG)ptr)%4)!=0) ptr++;
//            hdblock((CHAR *)ptr);
            cntlx=(CONTROLEX *)ptr;
            ptr=(WORD *)(cntlx+1);
            if (*ptr==0xFFFF) {
                ptr++;
                switch (*ptr) {
                    case BUTTON    :
                        switch (cntlx->style&0x0000000FL) {
                            case BS_PUSHBUTTON      :
                                printf("   PUSHBUTTON");
                                break;
                            case BS_DEFPUSHBUTTON   :
                                printf("   DEFPUSHBUTTON");
                                break;
                            case BS_CHECKBOX        :
                                printf("   CHECKBOX");
                                break;
                            case BS_AUTOCHECKBOX    :
                                printf("   AUTOCHECKBOX");
                                break;
                            case BS_RADIOBUTTON     :
                                printf("   RADIOBUTTON");
                                break;
                            case BS_3STATE          :
                                printf("   3STATE");
                                break;
                            case BS_AUTO3STATE      :
                                printf("   AUTO3STATE");
                                break;
                            case BS_GROUPBOX        :
                                printf("   GROUPBOX");
                                break;
                            case BS_USERBUTTON      :
                                printf("   USERBUTTON");
                                break;
                            case BS_AUTORADIOBUTTON :
                                printf("   AUTORADIOBUTTON");
                                break;
                            case BS_OWNERDRAW       :
                                printf("   OWNERDRAW");
                                break;
                            default:
                                printf("   BUTTON");
                        }
                        break;
                    case EDIT      :
                        printf("   EDIT ");
                        break;
                    case STATIC    :
                        switch (cntlx->style&0x0000000FL) {
                            case SS_LEFT           :
                                printf("   LTEXT");
                                break;
                            case SS_CENTER         :
                                printf("   CTEXT");
                                break;
                            case SS_RIGHT          :
                                printf("   RTEXT");
                                break;
                            case SS_ICON           :
                                printf("   ICON");
                                break;
                            case SS_BLACKRECT      :
                                printf("   BLACKRECT");
                                break;
                            case SS_GRAYRECT       :
                                printf("   GRAYRECT");
                                break;
                            case SS_WHITERECT      :
                                printf("   WHITERECT");
                                break;
                            case SS_BLACKFRAME     :
                                printf("   BLACKFRAME");
                                break;
                            case SS_GRAYFRAME      :
                                printf("   GRAYFRAME");
                                break;
                            case SS_WHITEFRAME     :
                                printf("   WHITEFRAME");
                                break;
                            case SS_SIMPLE         :
                                printf("   SIMPLE");
                                break;
                            case SS_LEFTNOWORDWRAP :
                                printf("   LEFTNOWORDWRAP");
                                break;
                            default:
                                printf("   STATIC");
                        }
                        break;
                    case LISTBOX   :
                        printf("   LISTBOX");
                        break;
                    case SCROLLBAR :
                        printf("   SCROLLBAR");
                        break;
                    case COMBOBOX  :
                        printf("   COMBOBOX");
                        break;
                    default:
                        printf("   Class id %04X",*ptr);
                }
            } else if (*ptr!=0) {
                printf("   ");
                while (*ptr) printf("%c",(CHAR)(*(ptr++)));
                printf(" ");
            }
            ptr++;
            if (*ptr==0xFFFF) {
                ptr++;
                printf(" id %04X ",*ptr);
            } else if (*ptr!=0) {
                printf(" \"");
                while (*ptr) printf("%c",(CHAR)(*(ptr++)));
                printf("\" ");
            }
            ptr++;
            ptr+=(*ptr)/sizeof(WORD);
            ptr++;
            printf(" ident=%d X=%d Y=%d W=%d H=%d\n",
                cntlx->wid,cntlx->x,cntlx->y,cntlx->w,cntlx->h);
        }
    } else {
        for (i=0;i<dlg->numitem;i++) {
            while ((((LONG)ptr)%4)!=0) ptr++;
            cntl=(CONTROL *)ptr;
            while (cntl->style==0) cntl=(CONTROL *)(((DWORD *)cntl)+1);
            ptr=(WORD *)(cntl+1);
            if (*ptr==0xFFFF) {
                ptr++;
                switch (*ptr) {
                    case BUTTON    :
                        switch (cntl->style&0x0000000FL) {
                            case BS_PUSHBUTTON      :
                                printf("   PUSHBUTTON");
                                break;
                            case BS_DEFPUSHBUTTON   :
                                printf("   DEFPUSHBUTTON");
                                break;
                            case BS_CHECKBOX        :
                                printf("   CHECKBOX");
                                break;
                            case BS_AUTOCHECKBOX    :
                                printf("   AUTOCHECKBOX");
                                break;
                            case BS_RADIOBUTTON     :
                                printf("   RADIOBUTTON");
                                break;
                            case BS_3STATE          :
                                printf("   3STATE");
                                break;
                            case BS_AUTO3STATE      :
                                printf("   AUTO3STATE");
                                break;
                            case BS_GROUPBOX        :
                                printf("   GROUPBOX");
                                break;
                            case BS_USERBUTTON      :
                                printf("   USERBUTTON");
                                break;
                            case BS_AUTORADIOBUTTON :
                                printf("   AUTORADIOBUTTON");
                                break;
                            case BS_OWNERDRAW       :
                                printf("   OWNERDRAW");
                                break;
                            default:
                                printf("   BUTTON");
                        }
                        break;
                    case EDIT      :
                        printf("   EDIT ");
                        break;
                    case STATIC    :
                        switch (cntl->style&0x0000000FL) {
                            case SS_LEFT           :
                                printf("   LTEXT");
                                break;
                            case SS_CENTER         :
                                printf("   CTEXT");
                                break;
                            case SS_RIGHT          :
                                printf("   RTEXT");
                                break;
                            case SS_ICON           :
                                printf("   ICON");
                                break;
                            case SS_BLACKRECT      :
                                printf("   BLACKRECT");
                                break;
                            case SS_GRAYRECT       :
                                printf("   GRAYRECT");
                                break;
                            case SS_WHITERECT      :
                                printf("   WHITERECT");
                                break;
                            case SS_BLACKFRAME     :
                                printf("   BLACKFRAME");
                                break;
                            case SS_GRAYFRAME      :
                                printf("   GRAYFRAME");
                                break;
                            case SS_WHITEFRAME     :
                                printf("   WHITEFRAME");
                                break;
                            case SS_SIMPLE         :
                                printf("   SIMPLE");
                                break;
                            case SS_LEFTNOWORDWRAP :
                                printf("   LEFTNOWORDWRAP");
                                break;
                            default:
                                printf("   STATIC");
                        }
                        break;
                    case LISTBOX   :
                        printf("   LISTBOX");
                        break;
                    case SCROLLBAR :
                        printf("   SCROLLBAR");
                        break;
                    case COMBOBOX  :
                        printf("   COMBOBOX");
                        break;
                    default:
                        printf("   Class id %04X",*ptr);
                }
            } else if (*ptr!=0) {
                printf("   ");
                while (*ptr) printf("%c",(CHAR)(*(ptr++)));
                printf(" ");
            }
            ptr++;
            if (*ptr==0xFFFF) {
                ptr++;
                printf(" id %04X ",*ptr);
            } else if (*ptr!=0) {
                printf(" \"");
                while (*ptr) printf("%c",(CHAR)(*(ptr++)));
                printf("\" ");
            }
    //        printf(" Style %08lX EStyle %08lX\n",cntl->style,cntl->dwExtstyle);
            printf(" ident=%d X=%d Y=%d W=%d H=%d\n",
                cntl->wid,cntl->x,cntl->y,cntl->w,cntl->h);
            ptr++;

        }
    }

    free(buffer);
}
void TraverseDataEntry(FILE *fp,DWORD addr,DWORD base,DWORD rva,INT dent,INT type,DWORD pid)
{
    IMAGE_RESOURCE_DATA_ENTRY_MD rdate;
    fseek(fp,base+addr,SEEK_SET);
    if (fread(&rdate,1,sizeof(IMAGE_RESOURCE_DATA_ENTRY_MD),fp)==sizeof(IMAGE_RESOURCE_DATA_ENTRY_MD)) {
        if (type==(DWORD)RT_STRING) {
            DumpStrings(fp,base,rdate.OffsetToData-rva,rdate.Size,(pid-1)<<4);
        } else if (type==(DWORD)RT_DIALOG) {
            DumpBlock(fp,base,rdate.OffsetToData-rva,rdate.Size);
            DumpDialog(fp,base,rdate.OffsetToData-rva,rdate.Size);
        } else {
            printf("%*.*sAddress %08lX (Actual %08lX)\n",dent,dent,"",base+rdate.OffsetToData-rva,base+rdate.OffsetToData);
            printf("%*.*sSize    %04X\n",dent,dent,"",rdate.Size);
//            DumpBlock(fp,base,rdate.OffsetToData-rva,rdate.Size);
            DumpBlock(fp,base,rdate.OffsetToData-rva,32);
        }
        printf("\n");
    }
}
void TraverseDir(FILE *fp,DWORD addr,DWORD base,DWORD rva,INT dent,INT type,DWORD pid)
{
    INT entry;
    IMAGE_RESOURCE_DIRECTORY rdir;
    IMAGE_RESOURCE_DIRECTORY_ENTRY_MD rdire;

    fseek(fp,base+addr,SEEK_SET);
    if (fread(&rdir,1,sizeof(IMAGE_RESOURCE_DIRECTORY),fp)==sizeof(IMAGE_RESOURCE_DIRECTORY)) {
        printf("%*.*sDirectory With %d Entries and %d Named Entries\n",dent,dent,"",rdir.NumberOfIdEntries,rdir.NumberOfNamedEntries);
        for (entry=0;entry<rdir.NumberOfIdEntries+rdir.NumberOfNamedEntries;entry++) {
            fseek(fp,base+addr+sizeof(IMAGE_RESOURCE_DIRECTORY)+entry*sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY_MD),SEEK_SET);
            if (fread(&rdire,1,sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY_MD),fp)==sizeof(IMAGE_RESOURCE_DIRECTORY_ENTRY_MD)) {
                if ((rdire.OffsetToData&0x80000000L)!=0) {
                    if ((rdire.Name<=16)&&(dent==0)) type=rdire.Name;
                    printf("%*.*s%s\n",dent,dent,"",ResType(rdire.Name,dent));
                    printf("%*.*sDirectory offset %08lX\n",dent,dent,"",rdire.OffsetToData+base);
                    TraverseDir(fp,rdire.OffsetToData&0x7FFFFFFFL,base,rva,dent+1,type,rdire.Name);
                } else {
                    printf("%*.*sDirectory offset %08lX\n",dent,dent,"",rdire.OffsetToData+base);
                    printf("%*.*s Containing Data at %08lX :-\n",dent,dent,"",(rdire.OffsetToData&0x7FFFFFFFL)+base);
                    TraverseDataEntry(fp,rdire.OffsetToData&0x7FFFFFFFL,base,rva,dent+1,type,pid);
                }
            }
        }
    }
}
int main(int argc,char *argv[])
{
    FILE *fp;
    IMAGE_DOS_HEADER head;
    IMAGE_NT_HEADERS nthead;
    IMAGE_SECTION_HEADER shead;
    INT sect;

    if (argc<2) return 1;

    if ((fp=fopen(argv[1],"rb"))==NULL) return 2;
    printf("File Length = %08lX\n",filelength(fp->fd));
    if (fread(&head,1,sizeof(IMAGE_DOS_HEADER),fp)==sizeof(IMAGE_DOS_HEADER)) {

        if (head.e_magic==IMAGE_DOS_SIGNATURE) {
            fseek(fp,head.e_lfanew,SEEK_SET);
            if (fread(&nthead,1,sizeof(IMAGE_NT_HEADERS),fp)==sizeof(IMAGE_NT_HEADERS)) {
                if (nthead.Signature==IMAGE_NT_SIGNATURE) {
                    printf("%d sections\n",nthead.FileHeader.NumberOfSections);
                    for (sect=0;sect<nthead.FileHeader.NumberOfSections;sect++) {
                        if (fread(&shead,1,sizeof(IMAGE_SECTION_HEADER),fp)==sizeof(IMAGE_SECTION_HEADER)) {
                            printf("Header %s rva=%08lX Address %08lX\n",shead.Name,shead.VirtualAddress,shead.PointerToRawData);
                            if (!memcmp(shead.Name,".rsrc",5)) {
                                TraverseDir(fp,0,shead.PointerToRawData,shead.VirtualAddress,0,0,0);
//                                break;
                            }
                        }
                    }
//                    if (sect==nthead.FileHeader.NumberOfSections) {
//                        printf("No Resources\n");
//                    }
                }
            }
        }
    }
    fclose(fp);
    return 0;
}
