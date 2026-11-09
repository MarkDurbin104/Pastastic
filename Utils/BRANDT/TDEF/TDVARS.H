int				G_wid[25]=	{	  1,110,110,110,110,
								110,110,110,130,120,
								110,130,130,130,130,
								130,110, 80, 80,110,
								110,30,300,110,110		};
int				G_hgt[25]=	{	 1,80,80,80,80,
								80,80,80,40,80,
								80,60,60,60,60,
								60,60,50,30,60,
								60,30,90,80,80			};
char			*G_proctypes=	"MPTSARPD";
char			G_fldtypes[16]= "OTDSCWAMLQ      ";
char			G_used[4]=			{0,0,0,0};
char			G_icontype[6][9]={	{	 0, 1, 2,28,27,29,30,31,32,	},
									{	 8, 3, 9, 5, 4, 6, 7,11,10,	},
									{	 3,12,13,14,15,35,-1,-1,-1,	},
									{	16,17,18,19,-1,-1,-1,-1,-1,	},
									{	17,20,21,19,-1,-1,-1,-1,-1,	},
									{	-1,12,13,14,15,-1,-1,-1,-1,	}};
char			G_iconselc[5][9]={	{	 1, 2, 3, 4, 5, 6, 7, 8, 9,	},
									{	 2,11,12,13,14,21,-1,-1,-1,	},
									{	15,16,17,18,-1,-1,-1,-1,-1,	},
									{	16,19,20,18,-1,-1,-1,-1,-1,	},
									{	-1,11,12,13,14,-1,-1,-1,-1,	}};
char			G_levtype=1;
char 			comtype[33]={
	1,1,3,3,3,3,3,9,3,3,3,3,3,3,3,4,4,
	5,5,6,6,6,6,8,8,8,0,13,7,10,11,11,12	};

char		*cmd[46]={ 	"IF","CP","FR","FC","FT","FA","FD","RF","RN","RP",
						"RW","FF","AR","RO","DR","MT","MR","DA","UA","MS",
						"ME","QU","QC","PS","PK","SE","SJ","SC","SL","SR",
						"SI","SO","LS","MV","NA","FW","SN","NS","IU","MD",
						"EX","AN","OR","XO","NO","UT" };

char 			*command[35]={
	"IF","COMPARE",
	"OPEN FILE","CLOSE FILE","TRUNCATE FILE","CREATE FILE","DELETE FILE",
	"FIND RECORD IN","GET NEXT RECORD FROM","GET PREV RECORD FROM",
	"GET FIRST RECORD FROM","GET LAST RECORD FROM",
	"WRITE RECORD TO","OVERWRITE RECORD IN","DELETE RECORD FROM",
	"TRANSMIT MESSAGE","WAIT ON MESSAGE",
	"OPEN ARRAY","CLOSE ARRAY",
	"START TRANSACTION","END TRANSACTION",
	"EXIT","CLOSE FILES & EXIT",
	"SPAWN PROCESS","KILL PROCESS","SIGNAL","USING KEY","SYSTEM",
	"STRING JOIN","STRING CUT","STRING INSERT",
	"STRING OVERWRITE","STRING LENGTH","UNTIL","REPEAT"  };

char 			*operator[26]= {
		"=",">",">=","==","!=","<","<=","<>","AND","OR","EXOR","NOT",
		"(",")","IS NOT IN USE","SHL","SHR",
		"+","-","*","/","=","(",")","DIV","MOD"	};
char 			*G_const[26]={
	"B","N","P","S","m","R","e","p","x","E","a","t","A","D","o","O","j",
	"T","r","C","H0","H1","H2","H3","H4","M" };

