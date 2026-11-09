#define DETECT 1
#define grOk 1
int G_x=0;
int G_y=0;
#pragma warn -par
void clearviewport(void) { ; }
void closegraph(void) { ; }
void initgraph(int *a,int *b,char *s) { ; }
int graphresult(void) { return grOk; }
char *grapherrormsg(int a) { return NULL; }
void settextstyle(int a,int b,int c) { ; }
void settextjustify(int a,int b) { ; }

void rectangle(int x,int y,int x1,int y1) {
    if (G_fp==NULL) return;
    y+=G_oy;
    y1+=G_oy;
    if (G_firstln) G_firstln=FALSE; else fprintf(G_fp,"\n");
    fprintf(G_fp,"1%05d%05d%05d%05d",x,y,x1,y1);
    fflush(G_fp);
}
void line(int x,int y,int x1,int y1) {
    if (G_fp==NULL) return;
    y+=G_oy;
    y1+=G_oy;
    if (G_firstln) G_firstln=FALSE; else fprintf(G_fp,"\n");
    fprintf(G_fp,"2%05d%05d%05d%05d",x,y,x1,y1);
    fflush(G_fp);
}
void outtextxy(int x,int y,char *s) {
    if (G_fp==NULL) return;
    y+=G_oy;
    if (G_firstln) G_firstln=FALSE; else fprintf(G_fp,"\n");
    fprintf(G_fp,"3%05d%05d%s",x,y,s);
    fflush(G_fp);
}
void moveto(int x,int y) {
    if (G_fp==NULL) return;
    y+=G_oy;
    G_x=x;
    G_y=y;
}
void lineto(int x,int y) {
    if (G_fp==NULL) return;
    y+=G_oy;
    line(G_x,G_y,x,y);
    G_x=x;
    G_y=y;
}
void circle(int x,int y,int r) {
    if (G_fp==NULL) return;
    y+=G_oy;
    if (G_firstln) G_firstln=FALSE; else fprintf(G_fp,"\n");
    fprintf(G_fp,"4%05d%05d%05d%05d",x-r,y-r,x+r,y+r);
    fflush(G_fp);                           
}
void arc(int x,int y,int sa,int ea,int r) {
    if (G_fp==NULL) return;
    y+=G_oy;
    if (G_firstln) G_firstln=FALSE; else fprintf(G_fp,"\n");
    if (sa<180) {
        fprintf(G_fp,"5%05d%05d%05d%05d%05d%05d%05d%05d",x-r,y-r,x+r,y+r,x,y-r,x,y+r);
    } else {
        fprintf(G_fp,"5%05d%05d%05d%05d%05d%05d%05d%05d",x-r,y-r,x+r,y+r,x,y+r,x,y-r);
    }
    fflush(G_fp);
}
void setcolor(int c) {
    if (G_fp==NULL) return;
//    fprintf(G_fp,"6%05d",c);
}
#pragma warn +par
