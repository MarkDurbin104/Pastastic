#include <dos.h>
#include <memory.h>
#include <stdio.h>

typedef void interrupt (*ISRPTR)(void);

ISRPTR oldkeyb;

int G_keybuf[100];
int G_keyp=0;
char *klist=
//   0123456789ABCDEF0123456789ABCDEF
    " uominhgepbqfr**aljtdhywckvxsz  "
    " UOMINHGEPBQFR**ALJTDHYWCKVXSZ  "
    " 12 3   4   0 **567 8   9       "
    "              **                "
    "              **                "
    "              **                "
    "              **                "
    "              **                ";
void bufferkey(int k)
{
    G_keybuf[G_keyp++]=k;
}

void interrupt mykeyb(void)
{
    unsigned char stat;
    unsigned int k;

    disable();

    bufferkey(inp(0x60));

    stat=inp(0x61);
    outp(0x61,stat|0x80);
    outp(0x61,stat);
    outp(0x20,0x20);

    enable();
}
int main(void)
{
    int xit=0,j;
    int keybuf[100];
    int keyp=0;
    int flags=0;
    
    oldkeyb=getvect(0x09);
    setvect(0x09,mykeyb);
    while (!xit) {
        if (G_keyp) {
            disable();
            memcpy(keybuf,G_keybuf,G_keyp*sizeof(int));
            keyp=G_keyp;
            G_keyp=0;
            enable();
            for (j=0;j<keyp;j++) {
                switch(keybuf[j]) {
                    case 0x22 :
                        flags|=0x01;
                        break;
                    case 0x16 :
                        flags|=0x02;
                        break;
                    case 0x17 :
                        flags|=0x04;
                        break;
                    case 0x18 :
                        flags|=0x08;
                        break;
                    case 0x38 :
                        flags|=0x10;
                        break;
                    case 0xA2 :
                    case 0x96 :
                    case 0x97 :
                    case 0x98 :
                    case 0xB8 :
                        if ((flags&0x1F)!=0) {
                            printf("Flags    --------- %04X [ %c ]\n",flags,klist[flags]);
                            flags&=0xE0;
                        }
                        break;

                    case 0x4B :         // shiftkey 1 down
                        flags|=0x20;
                        break;
                    case 0xCB :         // shiftkey 1 up
                        flags&=0xDF;
                        break;

                    case 0x4C :         // shiftkey 2 down
                        flags|=0x40;
                        break;
                    case 0xCC :         // shiftkey 2 up
                        flags&=0xBF;
                        break;

                    case 0x4D :         // shiftkey 3 down
                        flags|=0x80;
                        break;
                    case 0xCD :         // shiftkey 3 up
                        flags&=0x7F;
                        break;

                    case 0x01 :         // quit
                        xit=1;
                        break;
                    case 0xE0 :
                        break;
                    default :
                         printf("%04X\n",keybuf[j]);
                }
            }
        }
    } 
    setvect(0x09,oldkeyb);
    return 1;
}
