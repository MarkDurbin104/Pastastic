#include <stdio.h>

#define LINK  0
#define POPUP 1


void genfontcoltab(FILE *fp)
{
    fprintf(fp," {\\fonttbl\n");
    fprintf(fp," \\f0\\froman Times New Roman;\n");
    fprintf(fp," \\f1\\fdecor Courier New;\n");
    fprintf(fp," \\f2\\fswiss Arial;\n");
    fprintf(fp," }\n");
    fprintf(fp," \\deff0\n");

    fprintf(fp," {\\colortbl\n");
    fprintf(fp," \\red0  \\green0  \\blue0  ;\n");
    fprintf(fp," \\red0  \\green0  \\blue255;\n");
    fprintf(fp," \\red0  \\green255\\blue255;\n");
    fprintf(fp," \\red0  \\green255\\blue0  ;\n");
    fprintf(fp," \\red255\\green0  \\blue255;\n");
    fprintf(fp," \\red255\\green0  \\blue0  ;\n");
    fprintf(fp," \\red255\\green255\\blue0  ;\n");
    fprintf(fp," \\red255\\green255\\blue255;\n");
    fprintf(fp," \\red0  \\green0  \\blue128;\n");
    fprintf(fp," \\red0  \\green128\\blue128;\n");
    fprintf(fp," \\red0  \\green128\\blue0  ;\n");
    fprintf(fp," \\red128\\green0  \\blue128;\n");
    fprintf(fp," \\red128\\green0  \\blue0  ;\n");
    fprintf(fp," \\red128\\green128\\blue0  ;\n");
    fprintf(fp," \\red128\\green128\\blue128;\n");
    fprintf(fp," \\red192\\green192\\blue192;\n");
    fprintf(fp," }\n");
}
void marktopic(FILE *fp,char *context,char *title,char *keyword,char *browse)
{
    if (context!=NULL) fprintf(fp," #{\\footnote %s }\n",context);
    if (title  !=NULL) fprintf(fp," ${\\footnote %s }\n",title  );
    if (browse !=NULL) fprintf(fp," +{\\footnote %s }\n",browse );
    if (keyword!=NULL) {
        if ((keyword[0]=='k')||(keyword[0]=='K'))
            fprintf(fp," K{\\footnote  %s }\n",keyword);
        else
            fprintf(fp," K{\\footnote %s }\n",keyword);
    }
}
void endtopic(FILE *fp)
{
    fprintf(fp," \\par \\page\n");
}
void genlink(FILE *fp,char *name,char *link,int type)
{
    switch (type) {
        case LINK :
            fprintf(fp,"{\\uldb %s}{\\v %s}\n",name,link);
            break;
        case POPUP :
            fprintf(fp,"{\\ul %s}{\\v %s}\n",name,link);
            break;
    }
}
void genhelp(FILE *fp)
{
    fprintf(fp,"{\\rtf1\\ansi\n");
    genfontcoltab(fp);

    marktopic(fp,"HelpCont","HelpTitle","HelpKeyword","001");
    fprintf(fp,"\\keepn \\par  This is my first help file \\par \\pard\n");
    fprintf(fp,"it contains one link \\par\n");
    fprintf(fp,"\\par \\tab ");
    genlink(fp,"The Link","HelpCont2",LINK);
    fprintf(fp,"\\par The End! \n");
    endtopic(fp);

    marktopic(fp,"HelpCont2","HelpTitle No 2","HelpKeyword2","002");
    fprintf(fp,"\\par This is my first help file  page two\\par\n");
    fprintf(fp,"it contains one link \\par\n");
    fprintf(fp,"\\par \\tab ");
    genlink(fp,"Next Page","HelpCont3",POPUP);
    fprintf(fp,"\\par The End! \n");
    endtopic(fp);

    marktopic(fp,"HelpCont3","HelpTitle No 3","HelpKeyword3","003");
    fprintf(fp,"\\f1\\fs40\\par This is my first help file  page three\\par\n");
    fprintf(fp,"it contains one link \\par\n");
    fprintf(fp,"\\par \\tab ");
    genlink(fp,"Go Back","HelpCont",LINK);
    fprintf(fp,"\\par The End! \n");
    endtopic(fp);

    fprintf(fp,"}\n");
}

int main(void)
{
    genhelp(stdout);
    return 1;
}
