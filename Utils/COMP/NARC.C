int archive(char cmd,char *afile,char *file)
{
	int i,j,count,nfiles,found,done;

    cmd=toupper(cmd);

    if (!strchr("AXRDPL",cmd)) return(-1);
	
	nfiles=1;   

	arcfile=fopen(afile,"rb");
	if ((arcfile==NULL)&&(cmd!='A')) return(-2);
	
	if (strchr("ARD",cmd)) {
		temp_name=tmpnam(NULL);
		outfile=fopen(temp_name,"wb");
		if (outfile==NULL) {
            fclose(arcfile);
            return(-3);
        }
	} else temp_name=NULL;

	make_crctable();
    count=done=0;

	if (cmd=='A') {
		strcpy(filename,file);
		if (add(0)) count++;
		if (count==0||arcfile==NULL) done=1;
	}

	while(!done&&read_header()) {
        found=match(filename,file)
		switch (cmd) {
		case 'R':
			if (found) {
				if (add(1)) count++;  else copy();
			} else copy();
			break;
		case 'A':  case 'D':
			if (found) {
				count+=(cmd=='D');  skip();
			} else copy();
			break;
		case 'X':  case 'P':
			if (found) {
				extract(cmd=='X');
				if (++count==nfiles) done=1;
			} else skip();
			break;
		case 'L':
			if (found) {
				if (count==0) list_start();
				list();
				if (++count==nfiles) done=1;
			}
			skip();
            break;
		}
	}

	if (temp_name!=NULL&&count!=0) {
		fputc(0,outfile);  
		if (ferror(outfile)||fclose(outfile)==EOF) {
            fclose(outfile);
            remove(temp_name);
            return(-3);
        }
		remove(afile);
        rename(temp_name,argv[2]);
	}

	return(0);
}


