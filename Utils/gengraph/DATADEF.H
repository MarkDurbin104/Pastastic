#define GETTOK(a,b) if ((a=strtok(b,"$\r\n"))==NULL) return

typedef struct bft_l {
    struct bft_s *bs;
    int depth;
    struct bft_l *next;
} BFT_L;
typedef struct nap   {
    LONG fn;
    CHAR fa;
    CHAR ctg[5];
    CHAR no[10];
    struct nap *next;
} NAP;
typedef struct bft_j {
    LONG id;
    LONG fn;
    CHAR type[11];
    struct bft_j *next;
} BFT_J;
typedef struct bft   {
    LONG no;
    CHAR cd[21];
    CHAR alcd[4];
    struct bft *next;
} BFT;
typedef struct fb    {
    LONG id;
    LONG sn;
    LONG en;
    struct fb *next;
} FB;
typedef struct fbp   {
    LONG bsid;
    LONG id;
    INT  tn;
    struct fbp *next;
} FBP;
typedef struct tube_l {
    LONG fn;
    LONG bsid;
    INT  tn;
    INT  ts;
    INT  tofs;
    struct tube_l *llink;
    struct tube_l *rlink;
    struct tube_l *next;
    struct tube_l *prev;
} TUBE_L;
typedef struct nap_tl{
    LONG fn;
    INT  depth;
    TUBE_L *rtubes;
    TUBE_L *ltubes;
    struct nap_tl *child;
    struct nap_tl *parent;
    struct nap_tl *sibling;
    struct nap_tl *next;
} NAP_TL;
typedef struct bft_bt{
    LONG bsid;
    INT  tn;
    struct bft_bt *next;
} BFT_BT;
typedef struct bft_e {
    LONG bsid1;
    INT  tn1;
    LONG bsid2;
    INT  tn2;
    LONG fn;
    struct bft_e *next;
} BFT_E;
typedef struct bft_t {
    CHAR type[21];
    INT  qty;
    struct bft_t *next;
} BFT_T;
typedef struct bft_s {
    LONG sn;
    LONG en;
    LONG sj;
    LONG ej;
    CHAR type[21];
    CHAR cd[21];
    LONG bsid;
    LONG len;
    BOOL traced;
    INT  numt;
    INT  tubestat[7];
    struct bft_s *next;
} BFT_S;

NAP    * G_nap   =NULL;
BFT_J  * G_bft_j =NULL;
BFT    * G_bft   =NULL;
FB     * G_fb    =NULL;
FBP    * G_fbp   =NULL;
BFT_BT * G_bft_bt=NULL;
BFT_E  * G_bft_e =NULL;
BFT_T  * G_bft_t =NULL;
BFT_S  * G_bft_s =NULL;
NAP_TL * G_nap_tl=NULL;
BFT_L  * G_bft_l =NULL;
