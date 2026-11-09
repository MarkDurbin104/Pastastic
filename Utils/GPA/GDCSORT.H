#define RECLEN 265L
#define RpBLK (64000L/RECLEN)
#define MAXREC (16000L)
#define MAXBLK ((MAXREC/RpBLK)+1L)
#define MAXGRP 1000

struct str_awk{
	unsigned int gr;
	unsigned long mg;
};
struct str_blsrt{
	unsigned int ser;
	unsigned long date;
	unsigned int cnt[8];
	unsigned long sum;
};
