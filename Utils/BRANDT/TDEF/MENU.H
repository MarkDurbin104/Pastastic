/*
=============================================================================
               header file of structures for Menu files.
-----------------------------------------------------------------------------
*/
typedef struct
             {
              int   G_disp_no_hd;          /* menu id */
              int   G_menhd_line_n;        /* menu header line number */
              int   G_xpos_hd;             /* x-position of line on screen */
              char  G_disp_txt_hd[80];     /* text for menu header line */
             } menuhead;

typedef struct
             {
              int   G_disp_no;             /* display number */
              int   G_disp_attr;           /* background attr */
              int   G_disp_type;           /* display type */
             } display;

typedef struct
             {
              int   G_disp_no_ml;          /* menu id */
              int   G_disp_ln_ml;          /* menu line number */
              int   G_acces_prv_ml;        /* access level required */
              int   G_action_ml;           /* associated action */
              int   G_ypos_ml;             /* ypos of line on screen */
              int   G_disp_attr_ml;        /* display attr */
              char  G_dis_mnemonic;        /* mnemonic for item */
              char  G_disp_txt_ml[80];     /* text for item */
              char  G_prom_txt_ml[80];     /* prompt for item */
              char  G_help_txt_ml[80];     /* extra help for item */
             } menuline;
/*
=============================================================================
*/
