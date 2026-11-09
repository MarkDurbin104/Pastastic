#ifndef GLOBAL_H    // stop multiple includes

#define GLOBAL_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef GLOBAL_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

PUBLIC      INT          findgname (CHAR *n);
PUBLIC      INT          isglobal  (CHAR *n);
PUBLIC      CHAR        *getglobal (INT i);
PUBLIC      INT          setglobal (INT i,CHAR *v);
PUBLIC      void         printglob (INT i);

// PUBLIC SYMBOLS E
#ifdef GLOBAL_C

//------------------------PRIVATE Prototypes & Variables-------------------

typedef struct {
    CHAR *n;
    CHAR t;
    void *v;
} GLOBALVAR;

GLOBALVAR G_gvars[]= {
    { "GSYSTEM"      , 'm' , (void *)(&(G_system    )) }, // 00
    { "GCACHE"       , 'm' , (void *)(&(G_cache     )) }, // 01
    { "GMONEYS"      , 'm' , (void *)(&(G_moneys    )) }, // 02
    { "GMONEYF"      , 'm' , (void *)(&(G_moneyf    )) }, // 03
    { "GWEIGHTS"     , 'm' , (void *)(&(G_weights   )) }, // 04
    { "GWEIGHTF"     , 'm' , (void *)(&(G_weightf   )) }, // 05
    { "GDAYS"        , 'm' , (void *)(&(G_days      )) }, // 06
    { "GMNTHS"       , 'm' , (void *)(&(G_mnths     )) }, // 07
    { "GDATABASE"    , 'm' , (void *)(&(G_database  )) }, // 08
    { "GCONFIG"      , 'm' , (void *)(&(G_config    )) }, // 09
    { "GTEXTFILE"    , 'm' , (void *)(&(G_textfile  )) }, // 10
    { "GBACKUP"      , 'm' , (void *)(&(G_backup    )) }, // 11
    { "GFONTFILE"    , 'm' , (void *)(&(G_fontfile  )) }, // 12
    { "GKBDFILE"     , 'm' , (void *)(&(G_kbdfile   )) }, // 13
    { "GSCRNAME"     , 'm' , (void *)(&(G_scrname   )) }, // 14
    { "GHARDERR"     , 'm' , (void *)(&(G_harderr   )) }, // 15
    { "GNOACC"       , 'm' , (void *)(&(G_noacc     )) }, // 16
    { "GNOPASS"      , 'm' , (void *)(&(G_nopass    )) }, // 17
    { "GOFFDETS"     , 'm' , (void *)(&(G_offdets   )) }, // 18
    { "GINSERTD"     , 'm' , (void *)(&(G_insertd   )) }, // 19
    { "GNEWDISK"     , 'm' , (void *)(&(G_newdisk   )) }, // 20
    { "GOLDDISK"     , 'm' , (void *)(&(G_olddisk   )) }, // 21
    { "GFORMAT"      , 'm' , (void *)(&(G_format    )) }, // 22
    { "GFORMATF"     , 'm' , (void *)(&(G_formatf   )) }, // 23
    { "GFORMATOK"    , 'm' , (void *)(&(G_formatok  )) }, // 24
    { "GPOSIERR"     , 'm' , (void *)(&(G_posierr   )) }, // 25
    { "GSTOPLIST"    , 'm' , (void *)(&(G_stoplist  )) }, // 26
    { "GNEWDATA"     , 'm' , (void *)(&(G_newdata   )) }, // 27
    { "GREVPRMT"     , 'm' , (void *)(&(G_revprmt   )) }, // 28
    { "GCLRSTOK"     , 'm' , (void *)(&(G_clrstok   )) }, // 29
    { "GNETPATH"     , 'm' , (void *)(&(G_netpath   )) }, // 30
    { "GFUPDATE"     , 'm' , (void *)(&(G_fupdate   )) }, // 31
    { "GRUPDATE"     , 'm' , (void *)(&(G_rupdate   )) }, // 32
    { "GTONAME"      , 'm' , (void *)(&(G_toname    )) }, // 33
    { "GFIXED"       , 'm' , (void *)(&(G_fixed     )) }, // 34
    { "GROUND"       , 'I' , (void *)(&(G_round     )) }, // 35
    { "GROUNDVAL"    , 'I' , (void *)(&(G_roundval  )) }, // 36
    { "GKEYDISK"     , 'I' , (void *)(&(G_keydisk   )) }, // 37
    { "GYES"         , 'c' , (void *)(&(G_yes       )) }, // 38
    { "GNO"          , 'c' , (void *)(&(G_no        )) }, // 39
    { "GCANSWITC"    , 'I' , (void *)(&(G_canswitch )) }, // 40
    { "GPOSITION"    , 'i' , (void *)(&(G_position  )) }, // 41
    { "GSCALEOUT"    , 'I' , (void *)(&(G_scaleout  )) }, // 42
    { "GUID"         , 'i' , (void *)(&(G_uid       )) }, // 43
    { "GACCESS"      , 'i' , (void *)(&(G_access    )) }, // 44
    { "GUPASS"       , 's' , (void *)(&(G_upass     )) }, // 45
    { "GUNAME"       , 's' , (void *)(&(G_uname     )) }, // 46
    { "GQNTY"        , 'I' , (void *)(&(G_qnty      )) }, // 47
    { "GTYPE"        , 'I' , (void *)(&(G_type      )) }, // 48
    { "GERROR"       , 'I' , (void *)(&(G_error     )) }, // 49
    { "GPROD"        , 'I' , (void *)(&(G_prod      )) }, // 50
    { "GLOGLEV"      , 'I' , (void *)(&(G_loglev    )) }, // 51
    { "GDPM"         , 's' , (void *)(&(G_dpm       )) }, // 52
    { "GLANG"        , 'I' , (void *)(&(G_lang      )) }, // 53
    { "GNETWORK"     , 'I' , (void *)(&(G_network   )) }, // 54
    { "GNETOK"       , 'I' , (void *)(&(G_netok     )) }, // 55
    { "GSEMNET"      , 'I' , (void *)(&(G_semnet    )) }, // 56
    { "GFRUPD"       , 's' , (void *)(&(G_frupd     )) }, // 57
    { "GFINRED"      , 'I' , (void *)(&(G_finredraw )) }, // 58
    { "GDEBUG"       , 'I' , (void *)(&(G_debug     )) }, // 59
    { "GNONE"        , 'm' , (void *)(&(G_none      )) }, // 60
    { "GLOB0"        , 's' , (void *)(&(G_globs[0]))   }, // 61
    { "GLOB1"        , 's' , (void *)(&(G_globs[1]))   }, // 62
    { "GLOB2"        , 's' , (void *)(&(G_globs[2]))   }, // 63
    { "GLOB3"        , 's' , (void *)(&(G_globs[3]))   }, // 64
    { "GLOB4"        , 's' , (void *)(&(G_globs[4]))   }, // 65
    { "GLOB5"        , 's' , (void *)(&(G_globs[5]))   }, // 66
    { "GLOB6"        , 's' , (void *)(&(G_globs[6]))   }, // 67
    { "GLOB7"        , 's' , (void *)(&(G_globs[7]))   }, // 68
    { "GLOB8"        , 's' , (void *)(&(G_globs[8]))   }, // 69
    { "GLOB9"        , 's' , (void *)(&(G_globs[9]))   }, // 70
    { "GPAGENUM"     , 'I' , (void *)(&(G_pagenum  ))  }, // 71
    { "GNUMPAGE"     , 'I' , (void *)(&(G_numpage  ))  }, // 72
    { "GSCOND"       , 'I' , (void *)(&(G_scond	 ))    }, // 73
    { "GSREC"        , 'I' , (void *)(&(G_srec	 ))    }, // 74
    { "GSFNAME"      , 's' , (void *)(&(G_sfname   ))  }, // 75
    { "GATFLDS"      , 'm' , (void *)(&(G_tflds    ))  }, // 76
    { "GLASTVAL"     , 's' , (void *)(&(G_lastval  ))  }, // 77
    { "GMODIFIED"    , 'I' , (void *)(&(G_modified ))  }, // 78
    { "GSPACINGX"    , 'I' , (void *)(&(G_spacingx ))  }, // 79
    { "GSPACINGY"    , 'I' , (void *)(&(G_spacingy ))  }, // 80
    { "GCURTCOL"     , 'I' , (void *)(&(G_curtcol  ))  }, // 81
    { "GLINENO"      , 'I' , (void *)(&(G_curpline ))  }, // 82
    { "GFORMNAM"     , 's' , (void *)(&(G_form.name))  }, // 83
    { "GFUDGEIT"     , 'I' , (void *)(&(G_fudgeit) )   }, // 84
    { "GTBSPACE"     , 'I' , (void *)(&(G_tbspace) )   }, // 85
    { "GHOTKEYS"     , 'I' , (void *)(&(G_hotkeys) )   }, // 86
    { "GDATEORD"     , 's' , (void *)(&(G_dateorder))  }, // 87
     
    { NULL           , (-1), (void *)NULL              }  // End Marker
};

#endif  //  def GLOBAL_C

#endif  //  ndef GLOBAL_H

