#include <stdio.h>
#include <io.h>
#include "pdfapi.h"

int main(int argc,char *argv[])
{
    int s;
    FILE *fp,*ofp;
    PDFObject IFile, OFile;
    long length;
    if (argc<3) return(0);
    unlink(argv[2]);
    if ((ofp=fopen(argv[2],"w"))!=NULL) {
        PDFSetDimType(USE_LIMITS);
//        PDFSetDimType(USE_FIXED);
        MakeFileObject(&OFile,PDFOUTPUT,ofp);
        PDFOutputFilter(output_dump,0,0);
        if ((fp=fopen(argv[1],"rb"))!=NULL) {
            length=filelength(fileno(fp));
            MakeFileObject(&IFile,PDFINPUT,fp);
            if ((s=PDFEncode(&IFile,length))>0) s=PDFMakeImage(&OFile,NULL);
            fclose(fp);
            fclose(ofp);
            if (s<0) unlink(argv[2]);
        }
        else {
            unlink(argv[2]);
        }
    }
    return(0);
}

