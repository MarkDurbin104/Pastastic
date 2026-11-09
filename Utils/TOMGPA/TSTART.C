#include <string.h>
#include <direct.h>
#include <process.h>
int main(int argc,char *argv[])
{
    int ret=0;
    char curdir[100];
    char gpapath[100],*t;
	curdir[0]='\\';
	getcurdir(0,&curdir[1]);
    strcpy(gpapath,argv[0]);
	t=strrchr(gpapath,'\\');
	if (t!=NULL) { t++; strcpy(t,"GPA.BIN"); } else strcpy(gpapath,".\GPA.BIN");
    if (argc>1) {
        if ((argv[1][0]=='1')&&(argv[1][1]==0)) {
            if (argc==3) {
                ret=spawnl(P_WAIT,"TD","TD",gpapath,argv[2],NULL);
            } else {
                ret=spawnl(P_WAIT,"TD","TD",gpapath,NULL);
            }
        } else {
            ret=spawnl(P_WAIT,gpapath,gpapath,argv[1],NULL);
        }
    } else {
        ret=spawnl(P_WAIT,gpapath,gpapath,NULL);
    }
    return(ret);
}

