// 	     
// !"#$%&'()*+,-./0123456789:;<=>?@
// ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`
// abcdefghijklmnopqrstuvwxyz{|}~€
// ‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ 
// ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿À
// ÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßà
// áâãäåæçèéêëìíîïğñòóôõö÷øùúûüışÿ

#include <conio.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <graphics.h>

int G_tw=4;
int G_th=6;
int G_ph=66;
int G_pw=80;

int grafix(void)
{
    int gd = VGA;
    int gm = VGAHI;
    int err;

    err=registerfarbgidriver(EGAVGA_driver_far);
    if (err<0) {
        printf("graphics System Error: %s\n",grapherrormsg(err));
        return(0);
    }
    initgraph(&gd,&gm,"c:\\bc\\bgi");
    
    err=graphresult();
    if (err<0) {
        printf("graphics System Error: %s\n",grapherrormsg(err));
        return(0);
    }
    return(1);
}
void prat(int x,int y,char *fmt, ... )
{
    unsigned char str[250],b[2];
    int i=0;
    va_list ap;
    b[1]=0;
    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);
    while (str[i]) {
        b[0]=str[i++];
        outtextxy(x+i*G_tw,y,b);
    }
}
int main(int argc,char *argv[])
{
    int b,a,xit=0,i;
    char s[100];
    FILE *fp;
    fp=fopen(argv[1],"r");
    grafix();
    settextstyle(0,HORIZ_DIR,0);
    G_th=textheight("8")+1;
    G_tw=textwidth("8")+1;
    setcolor(8);
    setfillstyle(1,15);
    bar(0,0,G_tw*(G_pw*2),G_th*G_ph);
    line(G_tw*G_pw,0,G_tw*G_pw,G_th*G_ph);
    b=0;
    a=0;
    while ((fgets(s,G_pw+1,fp)!=NULL)&&(!xit)) {
        s[strlen(s)-1]=0;
        setcolor(0);
        prat(a+0,(b%G_ph)*G_th,"%s",s);
        b++;
        if (strstr(s,"")!=NULL) {
            if (b<=G_ph) b=G_ph; else b=(G_ph*2);
        }
        if (b==G_ph) a=(G_pw*G_tw);
        if (b==(G_ph*2)) {
            if (getch()==27) xit=1;
            cleardevice();
            setcolor(8);
            setfillstyle(1,15);
            bar(0,0,G_tw*(G_pw*2),G_th*G_ph);
            line(G_tw*G_pw,0,G_tw*G_pw,G_th*G_ph);
            b=0;
            a=0;
        }
    }
    fclose(fp);
    if (!xit) getch();
    closegraph();
    return(0);
}

