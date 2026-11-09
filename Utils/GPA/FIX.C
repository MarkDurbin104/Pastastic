void timeout(int limit)
{
    static int c,l;
    int t;
    if (!limit) { c=0; return(0); }
   	disable(); t=G_commticker; enable();
    if (l!=t) c++;
    l=t;
    return(c>=limit);
}
INT rxchar(INT p,CHAR *c)
{
    timeout(0);
    while (rxnotready(p)) {
		if (timeout(G_timlim)) RETURNV(0);
	}
    *c=inchar(p);
    RETURNV(1);
}
// output a character to the serial port with timeout
INT txchar(INT p,CHAR *c)
{
    timeout(0);
    while (txnotready(p)) {
		if (timeout(G_timlim)) RETURNV(0);
	}
    outchar(p,*c);
    RETURNV(1);
}

