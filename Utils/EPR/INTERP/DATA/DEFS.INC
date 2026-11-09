#deftype NAP {n g_version,n feat_num,s ex_1141_cd,s ctg,s no,s ps_st,s house_1141_cd,s fp_acp_cd,s ab_ind,s loc,s licence_cd,s nb,s equipment_gr_ind,s hazard_gr_ind,s anticreep_gr_ind,s public_ind,n g_next_version,n g_generation}
#deftype BFT {s cd,s ex_1141_cd,n no,s alloc_cd,s ps_st,s nb}
#deftype BFT_S {n id,s bft_cd,s ps_st,n start_nap_feat_num,n end_nap_feat_num,n start_bj_id,n end_bj_id,s type,s start_fp_ind,s end_fp_ind,s netw_level,n ln_m,n install_yr,s nb}
#deftype BFT_J {n id,s ps_st,n nap_feat_num,s type}
#deftype FBP {n id,n bs_id,s ps_st,n bs_tube_no}
#deftype FB {n id,s cd,s ex_1141_cd,n no,s alloc_cd,s ps_st,n start_nap_feat_num,n end_nap_feat_num,s type,n ln_m,n install_yr,s netw_level,s nb}
#deftype BFT_T {s type,s txt,n diam_mm,n tubes_qty,n tube_ext_diam_mm,n tube_int_diam_mm}
#deftype BFT_BT {n id,n tube_no,s ps_st}
#deftype BFT_E {n id,s ps_st,n nap_feat_num,n bs1_id,n bs2_id,s type,n bs1_tube_no,n bs2_tube_no}
