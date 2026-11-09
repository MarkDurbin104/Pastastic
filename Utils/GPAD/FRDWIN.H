#ifndef FRDWIN_H

#define FRDWIN_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef FRDWIN_C
#define PUBLIC 
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

// PUBLIC SYMBOLS S
PUBLIC void   allbp      (INT b,INT state);
PUBLIC void   copy       (void);
PUBLIC void   cut        (void);
PUBLIC void   cutavail   (INT s);
PUBLIC void   delform    (UINT bpress);
PUBLIC void   drawbut    (INT bn,INT x,INT y,INT state);
PUBLIC void   exitfunc   (UINT bpress);
PUBLIC void   formb      (INT b,INT state);
PUBLIC void   formt      (INT bn,INT x,INT y,INT state);
PUBLIC CHAR * getdfname  (INT i);
PUBLIC CHAR * getdname   (INT i);
PUBLIC CHAR * getfname   (INT i);
PUBLIC CHAR * getaname   (INT i);
PUBLIC CHAR * getdfdet   (INT i);
PUBLIC CHAR * getldet    (INT i);
PUBLIC void   getform    (INT i);
PUBLIC void   langb      (INT b,INT state);
PUBLIC void   langt      (INT bn,INT x,INT y,INT state);
PUBLIC void   modified   (void);
PUBLIC void   paste      (void);
PUBLIC void   pasteavail (INT s);
PUBLIC void   presbut    (INT b,INT state);
PUBLIC void   prntform   (UINT bpress);
PUBLIC void   putform    (INT i);
PUBLIC void   savebt     (INT b,INT state);
PUBLIC void   scrmap     (INT wnum,INT state);
PUBLIC void   undo       (void);
PUBLIC void   undoavail  (INT s);
PUBLIC void   updab      (INT b,INT state);
PUBLIC void   updat      (INT bn,INT x,INT y,INT state);
PUBLIC void   upddflb    (INT l,INT lp,INT cp);
PUBLIC void   upddlb     (INT l,INT lp,INT cp);
PUBLIC void   moddlb     (INT l,INT lp,INT cp);
PUBLIC void   moddflb    (INT l,INT lp,INT cp);
PUBLIC void   moddlib    (INT l,INT lp,INT cp);
PUBLIC void   updlb      (INT l,INT lp,INT cp);
PUBLIC void   upalb      (INT l,INT lp,INT cp);
PUBLIC void   updwid     (UINT tstat);
PUBLIC void   updhgt     (UINT tstat);
PUBLIC void   renbt      (INT b,INT state);
PUBLIC void   dstbt      (INT b,INT state);
PUBLIC void   renfunc    (UINT tstat);
PUBLIC void   dupbt      (INT b,INT state);
PUBLIC void   dupfunc    (UINT tstat);
PUBLIC void   newbt      (INT b,INT state);
PUBLIC void   newfunc    (UINT tstat);
PUBLIC void   scrsbf     (INT id,INT dir,INT pos);
PUBLIC void   quickexit  (void);
PUBLIC void   saveall    (void);
PUBLIC void   viewscr    (void);
PUBLIC void   drawatt    (INT bn,INT x,INT y,INT state);
PUBLIC void   presatt    (INT b,INT state);
PUBLIC void   drawsiz    (INT bn,INT x,INT y,INT state);
PUBLIC void   pressiz    (INT b,INT state);
PUBLIC void   drawcol    (INT bn,INT x,INT y,INT state);
PUBLIC void   prescol    (INT b,INT state);
PUBLIC void   fldattr    (INT onoff,INT item);
PUBLIC void   noactb     (INT b,INT state);
PUBLIC void   nextcls    (INT b,INT state);
PUBLIC void   modidst    (INT b,INT state);
PUBLIC void   maketab    (INT b,INT state);

PUBLIC CHAR   *G_langname;
PUBLIC INT    *G_pbuf;
PUBLIC INT     G_fillbuf INIT(0);
PUBLIC UCHAR  *G_bm[5];
PUBLIC INT     G_bmw     INIT(90);
PUBLIC INT     G_bmh     INIT(65);
PUBLIC INT     G_bis     INIT(0);
PUBLIC INT     G_butst   INIT(1);
PUBLIC INT     G_mainw   INIT(-1);
PUBLIC INT     G_scrhigh INIT(25);
PUBLIC INT     G_scrwide INIT(80);
PUBLIC CHAR  **G_text1   INIT(NULL);
PUBLIC CHAR  **G_text2   INIT(NULL);
PUBLIC CHAR  **G_tname1  INIT(NULL);
PUBLIC CHAR  **G_tname2  INIT(NULL);
PUBLIC INT     G_tno     INIT(0);
PUBLIC FORM    G_cform;
PUBLIC CHAR    G_fldnams[9];
PUBLIC CHAR    G_fldeefs[9];
PUBLIC CHAR    G_fldacts[9];
PUBLIC CHAR    G_fldflds[18];
PUBLIC CHAR    G_fldcords[18];
PUBLIC CHAR    G_fldclss[10];
PUBLIC INT     G_colour INIT(0);
PUBLIC INT     G_size   INIT(0);
PUBLIC CHAR  **G_anames;
PUBLIC INT     G_numan  INIT(0);
PUBLIC INT     G_modifdst INIT(0);
PUBLIC CHAR    G_dststr[20];
PUBLIC CHAR    G_sysname[20];
// PUBLIC SYMBOLS E

#ifdef FRDWIN_C

INT     G_fcls=0;
CHAR   *G_ftl="AUL9XMWDTPK";
CHAR   *G_fclass[]={"MANDATORY","OPTIONAL","SEARCH","TEXT","MANDSRCH","MANDSECS","WAIT","DISPLAY","SECSRCH","TABLE",NULL};
CHAR   *G_formtypes[]={"FORM","SERVE","PROMPT","MENU","REPORT","PPFORM"};
INT     G_scrn  =(-1);
INT     G_butid =(-1);
INT     G_langb =(-1);
INT     G_formb =(-1);
INT     G_updtb =(-1);
INT     G_dstab =(-1);
INT     G_formlb=(-1);
INT     G_dstlb =(-1);
INT     G_dstflb=(-1);
INT     G_widtx =(-1);
INT     G_hgttx =(-1);
INT     G_widtb =(-1);
INT     G_hgttb =(-1);
INT     G_save  =(-1);
INT     G_saveok=(-1);
INT     G_saveca=(-1);
INT     G_renf  =(-1);
INT     G_renok =(-1);
INT     G_renca =(-1);
INT     G_renf1 =(-1);
INT     G_renf2 =(-1);
INT     G_renf3 =(-1);
INT     G_renf4 =(-1);
INT     G_dupf  =(-1);
INT     G_dupok =(-1);
INT     G_dupca =(-1);
INT     G_dupf1 =(-1);
INT     G_newf  =(-1);
INT     G_newok =(-1);
INT     G_newca =(-1);
INT     G_newf1 =(-1);
INT     G_scrrsb=(-1);
INT     G_scrbsb=(-1);
INT     G_at[16]={(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1)};
INT     G_sizid =(-1);
INT     G_colid =(-1);
INT     G_fatt1 =(-1);
INT     G_fatt2 =(-1);
INT     G_fatt3 =(-1);
INT     G_fatt4 =(-1);
INT     G_fatd1 =(-1);
INT     G_fatd2 =(-1);
INT     G_fatd3 =(-1);
INT     G_fatd4 =(-1);
INT     G_fatd5 =(-1);
INT     G_acclb =(-1);
INT     G_noact =(-1);
INT     G_clsid =(-1);
INT     G_clbid[10]={(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1),(-1)};
INT     G_dstml =(-1);
INT     G_dstfml=(-1);
INT     G_dstlml=(-1);
INT     G_dstw  =(-1);
INT     G_dstok =(-1);
INT     G_table =(-1);
INT     G_dstt[5]={(-1),(-1),(-1),(-1),(-1)};

WINDITEM G_wni[]={
    {&G_mainw ,  0,  0,639,479,OTWIN,"G.P.A. Designer. [ALPHA TEST]",NULL    },
    {&G_scrn  , 10,127,498,453,INWIN,"Screen Box"                  ,scrmap  },
    {&G_save  ,100, 40,540,340,INWIN,"Save As"                     ,NULL    },
    {&G_renf  ,160, 50,480,165,INWIN,"Rename Form"                 ,NULL    },
    {&G_dupf  ,160, 50,480,165,INWIN,"Duplicate Form"              ,NULL    },
    {&G_newf  ,160, 50,480,165,INWIN,"New From"                    ,NULL    },
    {&G_dstw  , 10,127,498,453,INWIN,"Data Store Designer"         ,NULL    }
};

SBARITEM G_sbi[]={
	{&G_scrrsb,500,149,500,449,0,(UINT*)&G_scrhigh,25,scrsbf},    //  0
    {&G_scrbsb, 14,455,494,455,0,(UINT*)&G_scrwide,80,scrsbf}     //  1
};                                                         
                                                           
BUTTITEM G_bti[]={
    {&G_butid    ,524, 43,618,113,OWNDRAW,drawbut ,presbut }, //  0
    {&G_langb    ,524,303,606,323,OWNDRAW,langt   ,langb   }, //  1
    {&G_formb    ,524,333,606,353,OWNDRAW,formt   ,formb   }, //  2
    {&G_updtb    ,524,363,606,383,OWNDRAW,updat   ,updab   }, //  3
    {&G_dstab    ,524,425,606,445,TXTDRAW,"ALL"   ,allbp   }, //  4
    {&G_saveok   ,420, 70,520,100,TXTDRAW,"OK"    ,savebt  }, //  5
    {&G_saveca   ,420,110,520,140,TXTDRAW,"Cancel",savebt  }, //  6
    {&G_renok    ,370, 80,470,110,TXTDRAW,"OK"    ,renbt   }, //  7
    {&G_renca    ,370,120,470,150,TXTDRAW,"Cancel",renbt   }, //  8
    {&G_dupok    ,370, 80,470,110,TXTDRAW,"OK"    ,dupbt   }, //  9
    {&G_dupca    ,370,120,470,150,TXTDRAW,"Cancel",dupbt   }, // 10
    {&G_newok    ,370, 80,470,110,TXTDRAW,"OK"    ,newbt   }, // 11
    {&G_newca    ,370,120,470,150,TXTDRAW,"Cancel",newbt   }, // 12
    {&G_colid    ,10 ,75 ,138, 91,OWNDRAW,drawcol ,prescol }, // 13
    {&G_sizid    ,10 ,93 ,138,122,OWNDRAW,drawsiz ,pressiz }, // 14
    {&G_noact    ,524,425,606,445,TXTDRAW,"NONE"  ,noactb  }, // 15
    {&G_clbid[0] ,208, 43,223, 55,OWNDRAW,NULL    ,NULL    }, // 16
    {&G_clbid[1] ,208, 58,223, 70,OWNDRAW,NULL    ,NULL    }, // 17
    {&G_clbid[2] ,208, 73,223, 85,OWNDRAW,NULL    ,NULL    }, // 18
    {&G_clbid[3] ,208, 88,223,100,OWNDRAW,NULL    ,modidst }, // 19
    {&G_clbid[4] ,208,103,223,115,OWNDRAW,NULL    ,nextcls }, // 20
    {&G_dstok    ,370,150,470,180,TXTDRAW,"OK"    ,dstbt   }, // 21
    {&G_table    ,140,103,206,122,TXTDRAW,"TABLE" ,maketab }  // 22
};

LBOXITEM G_lbi[]={
    {&G_formlb,524,126,15,&G_numidx,getfname ,updlb  ,0,8 }, //  0
    {&G_dstlb ,524,126,10,&G_nums  ,getdname ,upddlb ,0,8 }, //  1
    {&G_dstflb,524,248,15,&G_numdsf,getdfname,upddflb,0,8 }, //  2
    {&G_acclb ,524,126,25,&G_numan ,getaname ,upalb  ,0,10}, //  3
    {&G_dstml , 45,210,20,&G_nums  ,getdname ,moddlb ,0,8 }, //  4
    {&G_dstfml,151,210,20,&G_numdsf,getdfdet ,moddflb,0,18}, //  5
    {&G_dstlml,335,210,20,&G_numl  ,getldet  ,moddlib,0,14}  //  6
};

TBOXITEM G_tbi[]={
    {&G_widtx  ,524,393, 6,1,"Width"             ,NULL   ,0},  //  0
    {&G_hgttx  ,524,415, 6,1,"Height"            ,NULL   ,0},  //  1
    {&G_widtb  ,580,393, 3,1,G_widstr            ,updwid ,1},  //  2
    {&G_hgttb  ,580,415, 3,1,G_hgtstr            ,updhgt ,1},  //  3
    {&G_renf1  ,170, 80, 9,1,"Form Name"         ,NULL   ,0},  //  4
    {&G_renf2  ,170,120, 8,1,"New Name"          ,NULL   ,0},  //  5
    {&G_renf3  ,250, 80, 8,1,G_form.name         ,NULL   ,0},  //  6
    {&G_renf4  ,250,120, 8,1,G_form.name         ,renfunc,1},  //  7
    {&G_dupf1  ,250,120, 8,1,G_form.name         ,dupfunc,1},  //  8
    {&G_newf1  ,250,120, 8,1,G_form.name         ,newfunc,1},  //  9
    {&G_fatt1  ,150, 43, 4,1,"Name"              ,NULL   ,0},  // 10
    {&G_fatt2  ,150, 58, 6,1,"EEFunc"            ,NULL   ,0},  // 11
    {&G_fatt3  ,150, 73, 6,1,"Action"            ,NULL   ,0},  // 12
    {&G_fatt4  ,150, 88, 5,1,"Field"             ,NULL   ,0},  // 13
    {&G_fatd1  ,225, 43, 8,1,G_fldnams           ,NULL   ,1},  // 14
    {&G_fatd2  ,225, 58, 8,1,G_fldeefs           ,NULL   ,1},  // 15
    {&G_fatd3  ,225, 73, 8,1,G_fldacts           ,NULL   ,1},  // 16
    {&G_fatd4  ,225, 88,17,1,G_fldflds           ,NULL   ,1},  // 17
    {&G_clsid  ,225,103, 9,1,G_fldclss           ,NULL   ,1},  // 18
    {&G_dstt[0], 45,196, 5,1,"STORE"             ,NULL   ,0},  // 19
    {&G_dstt[1],151,172, 5,1,"FIELD"             ,NULL   ,0},  // 20
    {&G_dstt[2],335,184,10,1,"DICTIONARY"        ,NULL   ,0},  // 21
    {&G_dstt[3],151,184,18,1,"P S NAME     T LEN",NULL   ,0},  // 22
    {&G_dstt[4],335,196,14,1,"NAME     T LEN"    ,NULL   ,0},  // 23
    {&G_dstt[5],151,196, 1,1,&G_dststr[0]        ,NULL   ,1},  // 24
    {&G_dstt[6],167,196, 1,1,&G_dststr[2]        ,NULL   ,1},  // 25
    {&G_dstt[7],183,196, 8,1,&G_dststr[4]        ,NULL   ,1},  // 26
    {&G_dstt[8],255,196, 1,1,&G_dststr[13]       ,NULL   ,1},  // 27
    {&G_dstt[9],271,196, 3,1,&G_dststr[15]       ,NULL   ,1},  // 28
    {&G_fatd5  ,320, 73,17,1,G_fldcords          ,NULL   ,1}   // 29
};
MBOXITEM G_msgbx[]={
    {"Print"       ,"Insert Paper and Press\nOK when ready."             ,OKBUTT|CABUTT       ,prntform},
    {"Exit"        ,"The forms have been modified!\nDo you wish to Save?",YEBUTT|NOBUTT|CABUTT,exitfunc},
    {"Delete Form" ,"The current form will be deleted\nContinue?"        ,YEBUTT|NOBUTT       ,delform}
};


DBOXITEM G_diasave[]={
    {DBOXWIND,&G_wni[2]},
    {DBOXBUTT,&G_bti[5]},
    {DBOXBUTT,&G_bti[6]},
    {DBOXLAST,NULL     }
};
DBOXITEM G_diaren[]={
    {DBOXWIND,&G_wni[3]},
    {DBOXTBOX,&G_tbi[4]},
    {DBOXTBOX,&G_tbi[5]},
    {DBOXTBOX,&G_tbi[6]},
    {DBOXTBOX,&G_tbi[7]},
    {DBOXBUTT,&G_bti[7]},
    {DBOXBUTT,&G_bti[8]},
    {DBOXLAST,NULL     }
};
DBOXITEM G_diadup[]={
    {DBOXWIND,&G_wni[4 ]},
    {DBOXTBOX,&G_tbi[4 ]},
    {DBOXTBOX,&G_tbi[5 ]},
    {DBOXTBOX,&G_tbi[6 ]},
    {DBOXTBOX,&G_tbi[8 ]},
    {DBOXBUTT,&G_bti[9 ]},
    {DBOXBUTT,&G_bti[10]},
    {DBOXLAST,NULL     }
};
DBOXITEM G_dianew[]={
    {DBOXWIND,&G_wni[5 ]},
    {DBOXTBOX,&G_tbi[5 ]},
    {DBOXTBOX,&G_tbi[9 ]},
    {DBOXBUTT,&G_bti[11]},
    {DBOXBUTT,&G_bti[12]},
    {DBOXLAST,NULL     }
};
DBOXITEM G_diadst[]={
    {DBOXWIND,&G_wni[6 ]},
    {DBOXTBOX,&G_tbi[19]},
    {DBOXTBOX,&G_tbi[20]},
    {DBOXTBOX,&G_tbi[21]},
    {DBOXTBOX,&G_tbi[22]},
    {DBOXTBOX,&G_tbi[23]},
    {DBOXTBOX,&G_tbi[24]},
    {DBOXTBOX,&G_tbi[25]},
    {DBOXTBOX,&G_tbi[26]},
    {DBOXTBOX,&G_tbi[27]},
    {DBOXTBOX,&G_tbi[28]},
    {DBOXBUTT,&G_bti[21]},
    {DBOXLBOX,&G_lbi[4 ]},
    {DBOXLBOX,&G_lbi[6 ]},
    {DBOXLBOX,&G_lbi[5 ]},
    {DBOXLAST,NULL     }
};

MENUITEM G_mmopt[]={
    { "_File"      ,15,1,&G_mmopt[ 5],0,0 }, // 00
    { "_Edit"      ,15,1,&G_mmopt[15],0,0 }, // 01
    { "Fo_rm"      ,15,1,&G_mmopt[21],0,0 }, // 02
    { "_View"      ,15,2,viewscr     ,0,0 }, // 03
    { "^"          , 0,0,NULL        ,0,0 }, // 04

    { "_Save"      , 7,0,saveall     ,0,0 }, // 05
    { "Save _As"   ,15,4,G_diasave   ,0,0 }, // 06
    { "~"          ,15,0,NULL        ,0,0 }, // 07
    { "_Print"     ,15,3,&G_msgbx[0] ,0,0 }, // 08
    { "~"          ,15,0,NULL        ,0,0 }, // 09
    { "_Import"    , 7,2,NULL        ,0,0 }, // 10
    { "_Export"    , 7,2,NULL        ,0,0 }, // 11
    { "~"          ,15,0,NULL        ,0,0 }, // 12
    { "E_xit"      ,15,2,quickexit   ,0,0 }, // 13
    { "^"          , 0,0,NULL        ,0,0 }, // 14

    { "_Undo"      , 7,0,undo        ,0,0 }, // 15
    { "~"          ,15,0,NULL        ,0,0 }, // 16
    { "_Cut"       , 7,0,cut         ,0,0 }, // 17
    { "C_opy"      , 7,0,copy        ,0,0 }, // 18
    { "_Paste"     , 7,0,paste       ,0,0 }, // 19
    { "^"          , 0,0,NULL        ,0,0 }, // 20

    { "_New"       ,15,4,G_dianew    ,0,0 }, // 21
    { "_Delete"    ,15,3,&G_msgbx[2] ,0,0 }, // 22
    { "~"          ,15,0,NULL        ,0,0 }, // 23
    { "D_uplicate" ,15,4,G_diadup    ,0,0 }, // 24
    { "R_e-name"   ,15,4,G_diaren    ,0,0 }, // 25
    { "^"          , 0,0,NULL        ,0,0 }  // 26
};


#else

PUBLIC WINDITEM G_wni[];
PUBLIC BUTTITEM G_bti[];
PUBLIC LBOXITEM G_lbi[];
PUBLIC TBOXITEM G_tbi[];
PUBLIC MBOXITEM G_msgbx[];
PUBLIC MENUITEM G_mmopt[];

#endif

#endif



