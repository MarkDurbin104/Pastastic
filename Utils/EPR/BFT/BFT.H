//=============================== BFT.H =================================
#ifndef BFT_H
#define BFT_H

#ifdef PUBLIC
#undef PUBLIC
#endif // PUBLIC

#ifdef BFT_C
#define PUBLIC
#else
#define PUBLIC extern
#endif  // BFT_C

//===============================GLOBAL======================================
typedef unsigned long UINT;
typedef struct {
    UINT feat_num;
    UINT ex_1141_cd;
    UINT ctg;
    UINT no;
    UINT ps_st;
    UINT house_1141_cd;
    UINT fp_acp_cd;
    UINT ab_ind;
    UINT loc;
    UINT licence_cd;
    UINT nb;
    UINT equipment_gr_ind;
    UINT hazard_gr_ind;
    UINT anticreep_gr_ind;
} NETWORK_ACCESS_POINT;
typedef struct {
    UINT cd;
    UINT ex_1141_cd;
    UINT no;
    UINT alloc_cd;
    UINT ps_st;
    UINT nb;
} BLOWN_FIBRE_TUBING;
typedef struct {
    UINT id;
    UINT bft_cd;
    UINT ps_st;
    UINT start_nap_feat_num;
    UINT end_nap_feat_num;
    UINT start_bj_id;
    UINT end_bj_id;
    UINT type;
    UINT start_fp_ind;
    UINT end_fp_ind;
    UINT netw_level;
    UINT ln_m;
    UINT install_yr;
    UINT nb;
} BFT_SECTION;
typedef struct {
    UINT id;
    UINT ps_st;
    UINT nap_feat_num;
    UINT type;
} BFT_JOINT;
typedef struct {
    UINT id;
    UINT bs_id;
    UINT ps_st;
    UINT bs_tube_no;
} FIBRE_BUNDLE_PART;
typedef struct {
    UINT id;
    UINT cd;
    UINT ex_1141_cd;
    UINT no;
    UINT alloc_cd;
    UINT ps_st;
    UINT start_nap_feat_num;
    UINT end_nap_feat_num;
    UINT type;
    UINT ln_m;
    UINT install_yr;
    UINT netw_level;
    UINT nb;
} FIBRE_BUNDLE;
typedef struct {
    UINT type;
    UINT txt;
    UINT diam_mm;
    UINT tubes_qty;
    UINT tube_ext_diam_mm;
    UINT tube_int_diam_mm;
} BFT_TYPE;
typedef struct {
    UINT id;
    UINT tube_no;
    UINT ps_st;
} BFT_BLOCKED_TUBES;
typedef struct {
    UINT id;
    UINT ps_st;
    UINT nap_feat_num;
    UINT bs1_id;
    UINT bs2_id;
    UINT type;
    UINT bs1_tube_no;
    UINT bs2_tube_no;
} BFT_EQUIPMENT;
//===============================LOCAL=======================================
#ifdef BFT_C



#endif  // BFT_C
#endif  // BFT_H
//===============================END OF FILE=================================
