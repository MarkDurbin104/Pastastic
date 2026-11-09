void grafix(void) {					/* sets up graphics mode */
	int errormode;
	G_driver = VGA;
	G_mode = VGAHI;
	errormode=registerbgidriver(EGAVGA_driver);
	if( errormode < 0 ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		exit(1);
	}
	initgraph( &G_driver, &G_mode, "" );
	errormode = graphresult();
	if( errormode != grOk ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		exit(1);
	}
	G_maxx=getmaxx();
	G_maxy=getmaxy();
}
