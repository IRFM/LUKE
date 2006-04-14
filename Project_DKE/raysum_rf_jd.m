function [ZXXD_rf,ZXXF_rf,ZXXD_rf_tp,ZXXF_rf_tp] = raysum_rf_jd(dkeparam,ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyD0_rf,gridindex_rf);
%
npn = gridindex_rf.npn;
nmhu = gridindex_rf.nmhu;
nr = gridindex_rf.nr;
nr_dke = gridindex_rf.nr_dke;
nb = gridindex_rf.nb;
nn_rf = gridindex_rf.nn_rf;
%
ixy = (gridindex_rf.mask_y - 1)*nr + gridindex_rf.mask_r;
%
XYD0_rf = xyD0_rf(ixy);
%
ZXYD_rf.pp_ippj = ZXYD_rf.pp_ippj.*XYD0_rf;
ZXYD_rf.pp_ipj = ZXYD_rf.pp_ipj.*XYD0_rf;
ZXYD_rf.pp_ij = ZXYD_rf.pp_ij.*XYD0_rf;
ZXYD_rf.pp_imj = ZXYD_rf.pp_imj.*XYD0_rf;
ZXYD_rf.pp_immj = ZXYD_rf.pp_immj.*XYD0_rf;
ZXYD_rf.pm_ipj = ZXYD_rf.pm_ipj.*XYD0_rf;
ZXYD_rf.pm_ij = ZXYD_rf.pm_ij.*XYD0_rf;
ZXYD_rf.pm_imj = ZXYD_rf.pm_imj.*XYD0_rf;
ZXYD_rf.mp_ijp = ZXYD_rf.mp_ijp.*XYD0_rf;
ZXYD_rf.mp_ij = ZXYD_rf.mp_ij.*XYD0_rf;
ZXYD_rf.mp_ijm =ZXYD_rf.mp_ijm.*XYD0_rf;
ZXYD_rf.mm_ijp = ZXYD_rf.mm_ijp.*XYD0_rf;
ZXYD_rf.mm_ijm = ZXYD_rf.mm_ijm.*XYD0_rf;
%
iXX = double(((gridindex_rf.mask_r - 1)*nmhu + (gridindex_rf.mask_m - 1))*npn + gridindex_rf.mask_p);
iyn = double((gridindex_rf.mask_n - 1)*nb + gridindex_rf.mask_y);
%
gridindex_rf = rmfield(gridindex_rf,['mask_r';'mask_m';'mask_p';'mask_n';'mask_y']);
%
ZXXD_rf.pp_ippj =   reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pp_ippj),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pp_ipj =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pp_ipj),nb*nn_rf ,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pp_ij =     reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pp_ij),nb*nn_rf  ,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pp_imj =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pp_imj),nb*nn_rf ,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pp_immj =   reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pp_immj),nb*nn_rf,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pm_ipj =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pm_ipj),nb*nn_rf ,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pm_ij =     reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pm_ij),nb*nn_rf  ,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.pm_imj =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.pm_imj),nb*nn_rf ,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.mp_ijp =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mp_ijp),nb*nn_rf ,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.mp_ij =     reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mp_ij),nb*nn_rf  ,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.mp_ijm =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mp_ijm),nb*nn_rf ,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.mm_ijp =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mm_ijp),nb*nn_rf ,npn*nmhu*nr),1)),[npn,nmhu,nr]);
ZXXD_rf.mm_ijm =    reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf.mm_ijm),nb*nn_rf ,npn*nmhu*nr),1)),[npn,nmhu,nr]);
%
ZXXF_rf.p_ippj =    zeros(npn,nmhu,nr); 
ZXXF_rf.p_ipj =     zeros(npn,nmhu,nr);    
ZXXF_rf.p_ij =      zeros(npn,nmhu,nr);    
ZXXF_rf.p_imj =     zeros(npn,nmhu,nr);    
ZXXF_rf.p_immj =    zeros(npn,nmhu,nr);  
ZXXF_rf.m_ijp =     zeros(npn,nmhu,nr);   
ZXXF_rf.m_ijm =     zeros(npn,nmhu,nr);   
%
clear ZXYD_rf XYD0_rf
%
if dkeparam.dke_mode == 1,
    %
    XYD0_rf_tp = xyD0_rf(ixy(gridindex_rf.mask_dke));
    %
    ZXYD_rf_tp.pp_ippj = ZXYD_rf_tp.pp_ippj.*XYD0_rf_tp;
    ZXYD_rf_tp.pp_ipj = ZXYD_rf_tp.pp_ipj.*XYD0_rf_tp;
    ZXYD_rf_tp.pp_ij = ZXYD_rf_tp.pp_ij.*XYD0_rf_tp;
    ZXYD_rf_tp.pp_imj = ZXYD_rf_tp.pp_imj.*XYD0_rf_tp;
    ZXYD_rf_tp.pp_immj = ZXYD_rf_tp.pp_immj.*XYD0_rf_tp;
    ZXYD_rf_tp.pm_ipj = ZXYD_rf_tp.pm_ipj.*XYD0_rf_tp;
    ZXYD_rf_tp.pm_ij = ZXYD_rf_tp.pm_ij.*XYD0_rf_tp;
    ZXYD_rf_tp.pm_imj = ZXYD_rf_tp.pm_imj.*XYD0_rf_tp;
    ZXYD_rf_tp.mp_ijp = ZXYD_rf_tp.mp_ijp.*XYD0_rf_tp;
    ZXYD_rf_tp.mp_ij = ZXYD_rf_tp.mp_ij.*XYD0_rf_tp;
    ZXYD_rf_tp.mp_ijm =ZXYD_rf_tp.mp_ijm.*XYD0_rf_tp;
    ZXYD_rf_tp.mm_ijp = ZXYD_rf_tp.mm_ijp.*XYD0_rf_tp;
    ZXYD_rf_tp.mm_ijm = ZXYD_rf_tp.mm_ijm.*XYD0_rf_tp;
    %
    ZXYD_rf_tp.mp1_ijp = ZXYD_rf_tp.mp1_ijp.*XYD0_rf_tp;
    ZXYD_rf_tp.mp1_ij = ZXYD_rf_tp.mp1_ij.*XYD0_rf_tp;
    ZXYD_rf_tp.mp1_ijm =ZXYD_rf_tp.mp1_ijm.*XYD0_rf_tp;
    ZXYD_rf_tp.mm1_ijp = ZXYD_rf_tp.mm1_ijp.*XYD0_rf_tp;
    ZXYD_rf_tp.mm1_ijm = ZXYD_rf_tp.mm1_ijm.*XYD0_rf_tp;
    %
    ZXYF_rf_tp.p_ippj = ZXYF_rf_tp.p_ippj.*XYD0_rf_tp;
    ZXYF_rf_tp.p_ipj = ZXYF_rf_tp.p_ipj.*XYD0_rf_tp;
    ZXYF_rf_tp.p_ij = ZXYF_rf_tp.p_ij.*XYD0_rf_tp;
    ZXYF_rf_tp.p_imj = ZXYF_rf_tp.p_imj.*XYD0_rf_tp;
    ZXYF_rf_tp.p_immj = ZXYF_rf_tp.p_immj.*XYD0_rf_tp;
    ZXYF_rf_tp.m_ijp = ZXYF_rf_tp.m_ijp.*XYD0_rf_tp;
    ZXYF_rf_tp.m_ijm = ZXYF_rf_tp.m_ijm.*XYD0_rf_tp;
    %
    iXX = iXX(gridindex_rf.mask_dke);
    iyn = iyn(gridindex_rf.mask_dke);
    %
    ZXXD_rf_tp.pp_ippj = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pp_ippj),nb*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pp_ipj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pp_ipj),nb*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pp_ij =   reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pp_ij),nb*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pp_imj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pp_imj),nb*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pp_immj = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pp_immj),nb*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pm_ipj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pm_ipj),nb*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pm_ij =   reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pm_ij),nb*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.pm_imj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.pm_imj),nb*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mp_ijp =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp_ijp),nb*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mp_ij =   reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp_ij),nb*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mp_ijm =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp_ijm),nb*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mm_ijp =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mm_ijp),nb*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mm_ijm =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mm_ijm),nb*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    %
    % ---------------- Terms for wave-induced radial transport by adjoint technique (P. Helander model) ----------------
    %
    ZXXD_rf_tp.mp1_ijp = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp1_ijp),nb*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mp1_ij =  reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp1_ij),nb*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mp1_ijm = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mp1_ijm),nb*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mm1_ijp = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mm1_ijp),nb*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXD_rf_tp.mm1_ijm = reshape(full(sum(sparse(iyn,iXX,double(ZXYD_rf_tp.mm1_ijm),nb*nn_rf,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    %
    ZXXF_rf_tp.p_ippj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.p_ippj),nb*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.p_ipj =   reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.p_ipj),nb*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.p_ij =    reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.p_ij),nb*nn_rf   ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.p_imj =   reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.p_imj),nb*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.p_immj =  reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.p_immj),nb*nn_rf ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.m_ijp =   reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.m_ijp),nb*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
    ZXXF_rf_tp.m_ijm =   reshape(full(sum(sparse(iyn,iXX,double(ZXYF_rf_tp.m_ijm),nb*nn_rf  ,npn*nmhu*nr_dke),1)),[npn,nmhu,nr_dke]);
else
    ZXXD_rf_tp = [];
    ZXXF_rf_tp = [];
end
    
