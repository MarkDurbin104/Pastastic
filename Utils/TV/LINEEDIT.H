char *inat(int x,int y,int len,char *def,int limits);

char *inat(int x,int y,int len,char *def,int limits) {
	char tmp[80],movestr[80],k;
	int i,j,insover=1,exflag=0;
	struct REGPACK regs;

    i=strlen(def);
	gotoxy(x,y);
	cprintf("%s",def);
	gotoxy(x+i,y);
	strcpy(tmp,def);
    regs.r_ax=0x0100;
   	regs.r_cx=0x0701;
    intr(0x10,&regs);
    do {
		switch(k=getch()) {
			case 8 : {
				if ((i>0)&&(i<=strlen(tmp))) {
					i--;
					tmp[i]=0;
					strcat(tmp,&tmp[i+1]);
					gotoxy(x+i,y);
					cprintf("%s ",&tmp[i]);
					gotoxy(x+i,y);
				}
				else {
					sound(1000);
					for (j=0;j<5000;j++);
					nosound();
				}
			} break;
			case 10 :
			case 13 :
			case 27 : {
				exflag=1;
			} break;
			case 0 : {
				switch(k=getch()) {
					case 'S' : { /*DELETE*/
						if (i<strlen(tmp)) {
							tmp[i]=0;
							strcat(tmp,&tmp[i+1]);
							gotoxy(x+i,y);
							cprintf("%s ",&tmp[i]);
							gotoxy(x+i,y);
						}
						else {
							sound(1000);
							for (j=0;j<5000;j++);
							nosound();
						}
					} break;
					case 'R' : { /*INSERT*/
						insover^=1;
                        if (insover) {
						    regs.r_ax=0x0100;
					    	regs.r_cx=0x0107;
						    intr(0x10,&regs);
                        }
						else {
						    regs.r_ax=0x0100;
					    	regs.r_cx=0x0607;
						    intr(0x10,&regs);
						}
					} break;
					case 'K' : { /*LEFT*/
						if (i>0) {
							i--;
							gotoxy(x+i,y);
						}
						else {
							if (!(limits&1)) {
								sound(1000);
								for (j=0;j<5000;j++);
								nosound();
							}
                            else {
								exflag=1;
							}
						}
					} break;
					case 'M' : { /*RIGHT*/
						if (i<strlen(tmp)) {
							i++;
							gotoxy(x+i,y);
						}
						else {
							if (!(limits&2)) {
								sound(1000);
								for (j=0;j<5000;j++);
								nosound();
							}
                            else {
								exflag=1;
							}
						}
					} break;
					default : {
                     exflag=1;
					}
				}
			} break;
			default : {
				if (i<len) {
					if (i==strlen(tmp)) {
						tmp[i]=k;
						tmp[i+1]=0;
						gotoxy(x+i,y);
						cprintf("%c",k);
					}
					else {
	                	if (insover) {
							strcpy(movestr,&tmp[i]);
							tmp[i]=k;
							strcpy(&tmp[i+1],movestr);
							tmp[len]=0;
							gotoxy(x,y);
							cprintf("%s",tmp);
						}
						else {
							tmp[i]=k;
							gotoxy(x+i,y);
							cprintf("%c",k);
						}
					}
					i++;
					gotoxy(x+i,y);
				}
				else {
					sound(1000);
					for (j=0;j<5000;j++);
					nosound();
				}
			}
		}
	} while (!(exflag));
    regs.r_ax=0x0100;
   	regs.r_cx=0x0607;
    intr(0x10,&regs);
	if (k==27) {
    	for (i=0;i<len;i++) {
			gotoxy(x+i,y);
			cprintf(" ");
		}
		gotoxy(x,y);
		cprintf("%s",def);
		strcpy(tmp,def);
    }
	strcpy(&movestr[1],tmp);
	movestr[0]=k;
	return(movestr);
}
