// OWLCVT 07/07/94 00:47:58
#include "owl\compat.h"
#include <string.h>
#include <stdio.h>
#include "strclass.h"

Str::Str()
{
    init=1;
    len=0;
    string=NULL;
}
Str::Str(Str &s)
{
    if ((init==1)&&(string!=NULL)) delete string;
    init=1;
    len=s.len;
    string=new char[len];
    if (string!=NULL) strcpy(string,s.string);
}
Str::Str(char *s)
{
    if ((init==1)&&(string!=NULL)) delete string;
    init=1;
    len=strlen(s)+1;
    string=new char[len];
    if (string!=NULL) strcpy(string,s);
}

Str::Str(const char *s)
{
    if ((init==1)&&(string!=NULL)) delete string;
    init=1;
    len=strlen(s)+1;
    string=new char[len];
    if (string!=NULL) strcpy(string,s);
}
Str& Str::operator = (Str &s)
{
    if ((init==1)&&(string!=NULL)) delete string;
    init=1;
    len=s.len;
    string=new char[len];
    if (string!=NULL) strcpy(string,s.string);
    return *this;
}
Str& Str::operator = (char *s)
{
    if ((init==1)&&(string!=NULL)) delete string;
    init=1;
    len=strlen(s)+1;
    string=new char[len];
    if (string!=NULL) strcpy(string,s);
    return *this;
} 
Str& Str::operator = (const char *s)
{
    if ((init==1)&&(string!=NULL)) delete string;
    init=1;
    len=strlen(s)+1;
    string=new char[len];
    if (string!=NULL) strcpy(string,s);
    return *this;
}
Str Str::operator + (Str &s)
{
    Str r;
    r.len=len+s.len;
    r.string=new char[len];
    if (r.string!=NULL) {
        strcpy(r.string,string);
        strcat(r.string,s.string);
    } else {
        r.len=0;
    }
    return r;
}
Str Str::operator + (char *s)
{
    Str r;
    r.len=len+strlen(s)+1;
    r.string=new char[r.len];
    if (r.string!=NULL) {
        strcpy(r.string,string);
        strcat(r.string,s);
    } else {
        r.len=0;
    }
    return r;
}
Str Str::operator + (const char *s)
{
    Str r;
    r.len=len+strlen(s)+1;
    r.string=new char[r.len];
    if (r.string!=NULL) {
        strcpy(r.string,string);
        strcat(r.string,s);
    } else {
        r.len=0;
    }
    return r;
}
/*char Str::operator [](int index)
{
    if (index>len) return -1;
    return string[index];
} */
int Str::operator == (Str &s1)
{
    return !strcmp(s1.string,string);
}
int Str::operator == (char *s1)
{
    return !strcmp(s1,string);
}
int Str::operator == (const char *s1)
{
    return !strcmp(s1,string);
}
int Str::operator != (Str &s1)
{
    return strcmp(s1.string,string);
}
int Str::operator != (char *s1)
{
    return strcmp(s1,string);
}
int Str::operator != (const char *s1)
{
    return strcmp(s1,string);
}
Str::operator char *()
{
    if (len>0) return string;
    return "None";
} 
/*int main(void)
{
    PStr m[10];
    char tmp[2];
    tmp[1]=0;
    for (int i=0;i<10;i++) {
        tmp[0]=i+'A';
        m[i]=new Str(tmp);
    }
    
    char *s="Hello How Are You";
//    char *t="My Name is Mark";

    *(m[0])=s;

    for (i=5;i<9;i++) *(m[i])="My Name is Mark";
//    for (i=0;i<5;i++) *(m[i])=s;

    for (i=0;i<10;i++) printf("%s \n",(char *)(*(m[i])));
    return(0);
}

*/
