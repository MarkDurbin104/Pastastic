#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int      match           (char *t);
void     error           (char *err);
void     oper            (void);
void     expr            (void);
void     term            (void);
void     fact            (void);
void     part            (void);
void     cons            (void);
int      varib           (void);
int      func            (void);
int      value           (void);
int      cond            (void);

typedef int NUMB;
#define ATON atoi
#define NFORMAT "%d"
char *G_str;

#define TOPSTACK 100
NUMB G_stack[TOPSTACK];
NUMB G_top=0;

#define LINELEN 512
char G_linein[LINELEN];
FILE *G_fp;
int G_lnum=0;
int G_open=0;
int G_Err=0;

void push(NUMB v) { if (G_top<TOPSTACK) G_stack[G_top++]=v; }
NUMB pop (void) { if (G_top<1) return 0; else return G_stack[--G_top]; }
void neg   (void) { push(0-pop()); }
void not   (void) { push(! pop()); }
void add   (void) { push(pop() +  pop()); }
void mul   (void) { push(pop() *  pop()); }
void land  (void) { push(pop() && pop()); }
void lor   (void) { push(pop() || pop()); }
void and   (void) { push(pop() &  pop()); }
void or    (void) { push(pop() |  pop()); }
void note  (void) { push(pop() != pop()); }
void equal (void) { push(pop() == pop()); }
void sub   (void) { NUMB tmp=pop(); push(pop() -  tmp); }
void ndiv  (void) { NUMB tmp=pop(); push(pop() /  tmp); }
void mod   (void) { NUMB tmp=pop(); push(pop() %  tmp); }
void great (void) { NUMB tmp=pop(); push(pop() >  tmp); }
void greate(void) { NUMB tmp=pop(); push(pop() >= tmp); }
void less  (void) { NUMB tmp=pop(); push(pop() <  tmp); }
void lesse (void) { NUMB tmp=pop(); push(pop() <= tmp); }

void Error(char *s)
{
    char *t=G_linein;
    printf("Error : %d : %s\n",G_lnum,s);
    printf("%s\n",t);
    while ((t++)!=G_str) {
        printf("Í");
    }
    printf("¼");
    fclose(G_fp);
    G_Err=1;
    exit(1);
}
int  getline(void)
{
    G_str=fgets(G_linein,LINELEN,G_fp);
    if (G_str==NULL) {
        memset(G_linein,0,LINELEN);
        G_str=G_linein;
        return(0);
    }
    if (!*G_str) return(1);

    *(G_str+strlen(G_str)-1)=0;
    G_lnum++;
    return(1);
}
int match(char *t)  
{                   
    int len=strlen(t);

    while (isspace(*G_str)) G_str++;
    while (!(*G_str)) {
        if (!getline()) return(0);
        while (isspace(*G_str)) G_str++;
    }
    if (strncmpi(t,G_str,len)) return(0);
    if (isalpha(*(t+len-1))&&isalpha(*(G_str+len))) return(0);
    G_str+=len;
    return(1);
}
void oper(void)
{
  	expr();
   	for (;;) {
       	if (match("=")) {
          	printf("Result is ");
          	printf(NFORMAT,pop());
          	printf("\n");
      	} else break;
    }
}
void matchbrace(void)
{
    if (match("{")) {
        matchbrace();
        if (!match("}")) Error("missing '}'");
    } else if (match("(")) {
        matchbrace();
        if (!match(")")) Error("missing ')'");
    } else {
        while ((*G_str)&&(*G_str!='}')&&(*G_str!=')')&&(*G_str!='(')&&(*G_str!='{')) G_str++;
        if ((*G_str=='{')||(*G_str=='(')) matchbrace();
    }
}
void skip(void)
{
    matchbrace();
}
void expr(void)
{
    term();

    for (;;) {
        if      (match("and")) { term(); land(); }
        else if (match("or")) { term(); lor(); }
        else break;
    }
}
void  term(void)
{
    fact();

    for (;;) {
        if      (match("<="))  { fact(); lesse (); }
        else if (match("<" ))  { fact(); less  (); }
        else if (match(">="))  { fact(); greate(); }
        else if (match(">" ))  { fact(); great (); }
        else if (match("=="))  { fact(); equal (); }
        else if (match("<>"))  { fact(); note  (); }
        else break;
    }
}
void  fact(void)
{
    part();

    for (;;) {
        if      (match("+" )) {  part(); add(); }
        else if (match("-" )) {  part(); sub(); }
        else break;
    }
}
void  part(void)
{
    cons();
    for (;;) {
        if      (match("*" )) { part(); mul(); }
        else if (match("MOD" )) { part(); mod(); }
        else if (match("DIV" )) { part(); ndiv(); }
        else break;
    }
}
void cons(void)
{
    if (match("-")) {       neg(); }
    else if (match("NOT"))  { not(); }
    else if (match("{"))  {
        G_open++;
        oper();
        if (!match("}")) Error("missing '}'");
        G_open--;
    } else if (match("(")) {
        expr();
        if (!match(")")) Error("missing ')'");
    } else if ((!varib())&&(!func())&&(!value())&&(!cond())) {
        if (isdigit(*G_str)||(*G_str=='.')) {
            push(ATON(G_str));
            while (isdigit(*G_str)||(*G_str=='.')) G_str++;
        } else {
            Error("unknown Command");
        }
    }
}
int  varib(void)
{
    if (match("LOOKVAL")) {
        push(100);
        return(1);
    }
    return(0);
}
int  value(void)
{
    return(0);
}
int  func(void)
{
    return(0);
}
int  cond(void)
{
    return(0);
}
int CheckLine(char *line)
{
    G_str=line;
    while (*G_str!=0) oper();
    if (G_Err) return(0);
    return(1);
}
int main(void)
{
    G_str=G_linein;
    G_fp=fopen("Calc.dat","r");
    while (getline()) {
        if (!CheckLine(G_str))
            printf("Error\n");
    }
    fclose(G_fp);
    return 1;
}
