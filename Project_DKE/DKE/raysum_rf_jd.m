function [ZXXD_rf,ZXXF_rf,ZXXD_rf_tp,ZXXF_rf_tp] = raysum_rf_jd(dkeparam,ZXYD_rf,ZXYF_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyP0_2piRp,gridindex_rf);
%
npn = gridindex_rf.npn;
nmhu = gridindex_rf.nmhu;
nr = gridindex_rf.nr;
nr_dke = gridindex_rf.nr_dke;
ny = gridindex_rf.ny;
nn_rf = gridindex_rf.nn_rf;
%
ixy = (gridindex_rf.mask_y - 1)*nr + gridindex_rf.mask_r;
%
XYP0_2piRp = xyP0_2piRp(ixy);
%
ZXYD_rf.pp_ipj = ZXYD_rf.pp_ipj.*XYP0_2piRp;
ZXYD_rf.pp_imj = ZXYD_rf.pp_imj.*XYP0_2piRp;
ZXYD_rf.pm_ipj = ZXYD_rf.pm_ipj.*XYP0_2piRp;
ZXYD_rf.pm_imj = ZXYD_rf.pm_imj.*XYP0_2piRp;
ZXYD_rf.pr_ipj = ZXYD_rf.pr_ipj.*XYP0_2piRp;
ZXYD_rf.pr_imj = ZXYD_rf.pr_imj.*XYP0_2piRp;
%
ZXYD_rf.mm_ijp = ZXYD_rf.mm_ijp.*XYP0_2piRp;
ZXYD_rf.mm_ijm = ZXYD_rf.mm_ijm.*XYP0_2piRp;
ZXYD_rf.mp_ijp = ZXYD_rf.mp_ijp.*XYP0_2piRp;
ZXYD_rf.mp_ijm = ZXYD_rf.mp_ijm.*XYP0_2piRp;
ZXYD_rf.mr_ijp = ZXYD_rf.mr_ijp.*XYP0_2piRp;
ZXYD_rf.mr_ijm = ZXYD_rf.mr_ijm.*XYP0_2piRp;
%
ZXYD_rf.rr_lp = ZXYD_rf.rr_lp.*XYP0_2piRp;
ZXYD_rf.rr_lm = ZXYD_rf.rr_lm.*XYP0_2piRp;
ZXYD_rf.rp_lp = ZXYD_rf.rp_lp.*XYP0_2piRp;
ZXYD_rf.rp_lm = ZXYD_rf.rp_lm.*XYP0_2piRp;
ZXYD_rf.rm_lp = ZXYD_rf.rm_lp.*XYP0_2piRp;
ZXYD_rf.rm_lm = ZXYD_rf.rm_lm.*XYP0_2piRp;
%
ZXYD_rf.pp_ij = ZXYD_rf.pp_ij.*XYP0_2piRp;
ZXYD_rf.pm_ij = ZXYD_rf.pm_ij.*XYP0_2piRp;
ZXYD_rf.mp_ij = ZXYD_rf.mp_ij.*XYP0_2piRp;
%
ZXYD_rf.parpar_ij = ZXYD_rf.parpar_ij.*XYP0_2piRp;
ZXYD_rf.ij = ZXYD_rf.ij.*XYP0_2piRp;
%
iXX = double(((gridindex_rf.mask_r - 1)*nmhu + (gridindex_rf.mask_m - 1))*npn + gridindex_rf.mask_p);
iyn = double((gridindex_rf.mask_n - 1)*ny + gridindex_rf.mask_y);
%
gridindex_rf = rmfield(gridindex_rf,['mask_r';'mask_m';'mask_p';'mask_n';'mask_y']);
%
ZXXD_rf.pp_ipj =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pp_ipj   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pp_imj =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pp_imj   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pm_ipj =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pm_ipj   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pm_imj =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pm_imj   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pr_ipj =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pr_ipj   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pr_imj =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pr_imj   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXF_rf.p_ipj =     zeros(npn,nmhu,nr);    
ZXXF_rf.p_imj =     zeros(npn,nmhu,nr);    
%
ZXXD_rf.mm_ijp =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mm_ijp   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.mm_ijm =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mm_ijm   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.mp_ijp =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mp_ijp   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.mp_ijm =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mp_ijm   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.mr_ijp =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mr_ijp   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.mr_ijm =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mr_ijm   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXF_rf.m_ijp =     zeros(npn,nmhu,nr);   
ZXXF_rf.m_ijm =     zeros(npn,nmhu,nr);   
%
ZXXD_rf.rr_lp =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.rr_lp   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.rr_lm =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.rr_lm   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.rp_lp =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.rp_lp   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.rp_lm =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.rp_lm   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.rm_lp =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.rm_lp   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.rm_lm =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.rm_lm   ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXF_rf.r_lp  =    zeros(npn,nmhu,nr);    
ZXXF_rf.r_lm  =    zeros(npn,nmhu,nr);    
%
ZXXD_rf.pp_ij =     reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pp_ij    ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pm_ij =     reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pm_ij    ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.mp_ij =     reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mp_ij    ),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXF_rf.p_ij =      zeros(npn,nmhu,nr);    
%
ZXXD_rf.parpar_ij = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.parpar_ij),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.ij = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.ij),ny*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
%
clear ZXYD_rf XYP0_2piRp
%
if isfield(dkeparam,'Dparparmax'),
	Dparparmax = dkeparam.Dparparmax;
else
	Dparparmax = Inf;
end
%
XXredfac = ZXXD_rf.parpar_ij/Dparparmax;
XXredfac(XXredfac < 1) = 1;
%
ZXXD_rf.pp_ipj = ZXXD_rf.pp_ipj./XXredfac;
ZXXD_rf.pp_imj = ZXXD_rf.pp_imj./XXredfac;
ZXXD_rf.pm_ipj = ZXXD_rf.pm_ipj./XXredfac;
ZXXD_rf.pm_imj = ZXXD_rf.pm_imj./XXredfac;
%
ZXXD_rf.mm_ijp = ZXXD_rf.mm_ijp./XXredfac;
ZXXD_rf.mm_ijm = ZXXD_rf.mm_ijm./XXredfac;
ZXXD_rf.mp_ijp = ZXXD_rf.mp_ijp./XXredfac;
ZXXD_rf.mp_ijm =ZXXD_rf.mp_ijm./XXredfac;
%
ZXXD_rf.pp_ij = ZXXD_rf.pp_ij./XXredfac;
ZXXD_rf.pm_ij = ZXXD_rf.pm_ij./XXredfac;
ZXXD_rf.mp_ij = ZXXD_rf.mp_ij./XXredfac;
%
ZXXD_rf.parpar_ij = ZXXD_rf.parpar_ij./XXredfac;
ZXXD_rf.ij = ZXXD_rf.ij./XXredfac;
%
if dkeparam.dke_mode == 1,
    %
    XYP0_2piRp_tp = xyP0_2piRp(ixy(gridindex_rf.mask_dke));
    %
    ZXYD_rf_tp.pp_ippj = ZXYD_rf_tp.pp_ippj.*XYP0_2piRp_tp;
    ZXYD_rf_tp.pp_ipj = ZXYD_rf_tp.pp_ipj.*XYP0_2piRp_tp;
    ZXYD_rf_tp.pp_ij = ZXYD_rf_tp.pp_ij.*XYP0_2piRp_tp;
    ZXYD_rf_tp.pp_imj = ZXYD_rf_tp.pp_imj.*XYP0_2piRp_tp;
    ZXYD_rf_tp.pp_immj = ZXYD_rf_tp.pp_immj.*XYP0_2piRp_tp;
    ZXYD_rf_tp.pm_ipj = ZXYD_rf_tp.pm_ipj.*XYP0_2piRp_tp;
    ZXYD_rf_tp.pm_ij = ZXYD_rf_tp.pm_ij.*XYP0_2piRp_tp;
    ZXYD_rf_tp.pm_imj = ZXYD_rf_tp.pm_imj.*XYP0_2piRp_tp;
    ZXYD_rf_tp.mp_ijp = ZXYD_rf_tp.mp_ijp.*XYP0_2piRp_tp;
    ZXYD_rf_tp.mp_ij = ZXYD_rf_tp.mp_ij.*XYP0_2piRp_tp;
    ZXYD_rf_tp.mp_ijm =ZXYD_rf_tp.mp_ijm.*XYP0_2piRp_tp;
    ZXYD_rf_tp.mm_ijp = ZXYD_rf_tp.mm_ijp.*XYP0_2piRp_tp;
    ZXYD_rf_tp.mm_ijm = ZXYD_rf_tp.mm_ijm.*XYP0_2piRp_tp;
    %
    ZXYD_rf_tp.mp1_ijp = ZXYD_rf_tp.mp1_ijp.*XYP0_2piRp_tp;
    ZXYD_rf_tp.mp1_ij = ZXYD_rf_tp.mp1_ij.*XYP0_2piRp_tp;
    ZXYD_rf_tp.mp1_ijm =ZXYD_rf_tp.mp1_ijm.*XYP0_2piRp_tp;
    ZXYD_rf_tp.mm1_ijp = ZXYD_rf_tp.mm1_ijp.*XYP0_2piRp_tp;
    ZXYD_rf_tp.mm1_ijm = ZXYD_rf_tp.mm1_ijm.*XYP0_2piRp_tp;
    %
    ZXYF_rf_tp.p_ippj = ZXYF_rf_tp.p_ippj.*XYP0_2piRp_tp;
    ZXYF_rf_tp.p_ipj = ZXYF_rf_tp.p_ipj.*XYP0_2piRp_tp;
    ZXYF_rf_tp.p_ij = ZXYF_rf_tp.p_ij.*XYP0_2piRp_tp;
    ZXYF_rf_tp.p_imj = ZXYF_rf_tp.p_imj.*XYP0_2piRp_tp;
    ZXYF_rf_tp.p_immj = ZXYF_rf_tp.p_immj.*XYP0_2piRp_tp;
    ZXYF_rf_tp.m_ijp = ZXYF_rf_tp.m_ijp.*XYP0_2piRp_tp;
    ZXYF_rf_tp.m_ijm = ZXYF_rf_tp.m_ijm.*XYP0_2piRp_tp;
    %
    iXX = iXX(gridindex_rf.mask_dke);
    iyn = iyn(gridindex_rf.mask_dke);
    %
    ZXXD_rf_tp.pp_ippj = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pp_ippj),ny*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pp_ipj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pp_ipj),ny*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pp_ij =   reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pp_ij),ny*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pp_imj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pp_imj),ny*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pp_immj = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pp_immj),ny*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pm_ipj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pm_ipj),ny*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pm_ij =   reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pm_ij),ny*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pm_imj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pm_imj),ny*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mp_ijp =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp_ijp),ny*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mp_ij =   reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp_ij),ny*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mp_ijm =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp_ijm),ny*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mm_ijp =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mm_ijp),ny*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mm_ijm =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mm_ijm),ny*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    %
    % ---------------- Terms for wave-induced radial transport by adjoint technique (P. Helander model) ----------------
    %
    ZXXD_rf_tp.mp1_ijp = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp1_ijp),ny*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mp1_ij =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp1_ij),ny*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mp1_ijm = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp1_ijm),ny*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mm1_ijp = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mm1_ijp),ny*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mm1_ijm = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mm1_ijm),ny*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    %
    ZXXF_rf_tp.p_ippj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.p_ippj),ny*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.p_ipj =   reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.p_ipj),ny*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.p_ij =    reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.p_ij),ny*nn_rf   ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.p_imj =   reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.p_imj),ny*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.p_immj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.p_immj),ny*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.m_ijp =   reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.m_ijp),ny*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.m_ijm =   reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.m_ijm),ny*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
else
    ZXXD_rf_tp = [];
    ZXXF_rf_tp = [];
end
    
