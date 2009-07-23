function [Zdelta,MMXT_f_t,MMXP_f_t,MMXR_f_t,Xmask_r_edge,MMXP_tp,MMXP_g_t,MMH_tp,Zpn2_t,sm_f,sm_g,sm_tp] =...
            matrixcalc_dke_yp(dkeparam,display,gridDKE,equilDKE,Zbouncecoef,mksa,Zmripple,Zmomcoef,transpfaste,...
                              ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXILor,...
                        	  ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,...
                              ZXXD_rf,ZXXF_rf,ZXXD_rf_tp,ZXXF_rf_tp,...
                              ZXXD_a,ZXXF_a,ZXXD_g,ZXXF_g)
%
%   Calculate the super matrix for the 3D electron relativistic drift kinetic solver.
%
%   by Y. Peysson (CEA-IRFM) (yves.peysson@cea.fr) and J. Decker (CEA-IRFM) (joan.decker@cea.fr)
%
time0 = clock;
etime_fp = 0;
%
spparms('default');%Set parameters for sparse matrix ordering algorithms and direct linear equation solver MatLab build-in functions only
spparms('supernd',4);%Set parameters for sparse matrix ordering algorithms and direct linear equation solver MatLab build-in functions only
spparms('rreduce',4);%Set parameters for sparse matrix ordering algorithms and direct linear equation solver MatLab build-in functions onlyXXdpsin
%
% Diffusion and convection coefficients (sum of all contributions)
%
Zcoeffs.XXDpp_ipj = ZXXD_c.pp_ipj + ZXXD_e.pp_ipj + ZXXD_rf.pp_ipj + ZXXD_a.pp_ipj + ZXXD_g.pp_ipj;
Zcoeffs.XXDpp_imj = ZXXD_c.pp_imj + ZXXD_e.pp_imj + ZXXD_rf.pp_imj + ZXXD_a.pp_imj + ZXXD_g.pp_imj;
Zcoeffs.XXDpm_ipj = ZXXD_c.pm_ipj + ZXXD_e.pm_ipj + ZXXD_rf.pm_ipj + ZXXD_a.pm_ipj + ZXXD_g.pm_ipj;
Zcoeffs.XXDpm_imj = ZXXD_c.pm_imj + ZXXD_e.pm_imj + ZXXD_rf.pm_imj + ZXXD_a.pm_imj + ZXXD_g.pm_imj;
Zcoeffs.XXDpr_ipj = ZXXD_c.pr_ipj + ZXXD_e.pr_ipj + ZXXD_rf.pr_ipj + ZXXD_a.pr_ipj + ZXXD_g.pr_ipj;
Zcoeffs.XXDpr_imj = ZXXD_c.pr_imj + ZXXD_e.pr_imj + ZXXD_rf.pr_imj + ZXXD_a.pr_imj + ZXXD_g.pr_imj;
%
Zcoeffs.XXFp_ipj  = ZXXF_c.p_ipj  + ZXXF_e.p_ipj  + ZXXF_rf.p_ipj  + ZXXF_a.p_ipj  + ZXXF_g.p_ipj;
Zcoeffs.XXFp_imj  = ZXXF_c.p_imj  + ZXXF_e.p_imj  + ZXXF_rf.p_imj  + ZXXF_a.p_imj  + ZXXF_g.p_imj;
%
Zcoeffs.XXDmm_ijp = ZXXD_c.mm_ijp + ZXXD_e.mm_ijp + ZXXD_rf.mm_ijp + ZXXD_a.mm_ijp + ZXXD_g.mm_ijp;
Zcoeffs.XXDmm_ijm = ZXXD_c.mm_ijm + ZXXD_e.mm_ijm + ZXXD_rf.mm_ijm + ZXXD_a.mm_ijm + ZXXD_g.mm_ijm;
Zcoeffs.XXDmp_ijp = ZXXD_c.mp_ijp + ZXXD_e.mp_ijp + ZXXD_rf.mp_ijp + ZXXD_a.mp_ijp + ZXXD_g.mp_ijp;
Zcoeffs.XXDmp_ijm = ZXXD_c.mp_ijm + ZXXD_e.mp_ijm + ZXXD_rf.mp_ijm + ZXXD_a.mp_ijm + ZXXD_g.mp_ijm;
Zcoeffs.XXDmr_ijp = ZXXD_c.mr_ijp + ZXXD_e.mr_ijp + ZXXD_rf.mr_ijp + ZXXD_a.mr_ijp + ZXXD_g.mr_ijp;
Zcoeffs.XXDmr_ijm = ZXXD_c.mr_ijm + ZXXD_e.mr_ijm + ZXXD_rf.mr_ijm + ZXXD_a.mr_ijm + ZXXD_g.mr_ijm;
%
Zcoeffs.XXFm_ijp  = ZXXF_c.m_ijp  + ZXXF_e.m_ijp  + ZXXF_rf.m_ijp  + ZXXF_a.m_ijp  + ZXXF_g.m_ijp;
Zcoeffs.XXFm_ijm  = ZXXF_c.m_ijm  + ZXXF_e.m_ijm  + ZXXF_rf.m_ijm  + ZXXF_a.m_ijm  + ZXXF_g.m_ijm;
%
Zcoeffs.XXDrr_lp  = ZXXD_c.rr_lp  + ZXXD_e.rr_lp  + ZXXD_rf.rr_lp  + ZXXD_a.rr_lp  + ZXXD_g.rr_lp; 
Zcoeffs.XXDrr_lm  = ZXXD_c.rr_lm  + ZXXD_e.rr_lm  + ZXXD_rf.rr_lm  + ZXXD_a.rr_lm  + ZXXD_g.rr_lm; 
Zcoeffs.XXDrp_lp  = ZXXD_c.rp_lp  + ZXXD_e.rp_lp  + ZXXD_rf.rp_lp  + ZXXD_a.rp_lp  + ZXXD_g.rp_lp; 
Zcoeffs.XXDrp_lm  = ZXXD_c.rp_lm  + ZXXD_e.rp_lm  + ZXXD_rf.rp_lm  + ZXXD_a.rp_lm  + ZXXD_g.rp_lm; 
Zcoeffs.XXDrm_lp  = ZXXD_c.rm_lp  + ZXXD_e.rm_lp  + ZXXD_rf.rm_lp  + ZXXD_a.rm_lp  + ZXXD_g.rm_lp; 
Zcoeffs.XXDrm_lm  = ZXXD_c.rm_lm  + ZXXD_e.rm_lm  + ZXXD_rf.rm_lm  + ZXXD_a.rm_lm  + ZXXD_g.rm_lm; 
%
Zcoeffs.XXFr_lp   = ZXXF_c.r_lp   + ZXXF_e.r_lp   + ZXXF_rf.r_lp   + ZXXF_a.r_lp   + ZXXF_g.r_lp;
Zcoeffs.XXFr_lm   = ZXXF_c.r_lm   + ZXXF_e.r_lm   + ZXXF_rf.r_lm   + ZXXF_a.r_lm   + ZXXF_g.r_lm;
%
% Terms used by the old scheme only for momentum cross-derivatives (M. Shoucri and I. Shkarofsky,Comp. Phys. Comm., 82 (1994) 287)
%
Zcoeffs.XXDpp_ij  = ZXXD_c.pp_ij  + ZXXD_e.pp_ij  + ZXXD_rf.pp_ij  + ZXXD_a.pp_ij  + ZXXD_g.pp_ij;
Zcoeffs.XXDpm_ij  = ZXXD_c.pm_ij  + ZXXD_e.pm_ij  + ZXXD_rf.pm_ij  + ZXXD_a.pm_ij  + ZXXD_g.pm_ij;
Zcoeffs.XXDmp_ij  = ZXXD_c.mp_ij  + ZXXD_e.mp_ij  + ZXXD_rf.mp_ij  + ZXXD_a.mp_ij  + ZXXD_g.mp_ij;
Zcoeffs.XXFp_ij   = ZXXF_c.p_ij   + ZXXF_e.p_ij   + ZXXF_rf.p_ij   + ZXXF_a.p_ij   + ZXXF_g.p_ij;
%
%Grid weights calculations
%
[Zdelta] = fppgridweights_dke_yp(gridDKE,Zcoeffs);          
%
% Calculates supermatrix coefficients
%

[ZMX,ZMT] = fpengine_dke_yp(0,dkeparam,gridDKE,equilDKE,Zdelta,Zbouncecoef,Zcoeffs,Zmripple);
%
% Build sparse matrices
%
[MMX,MMT] = fpmatrix_dke_yp(ZMX,ZMT);
%
% Set-up boundary conditions 
%
[MMXb,MMTb] = fpboundaries_dke_yp(MMX,MMT);


%
for ir = 1:nr,   
%
%Momentum dynamics matrix coefficients calculations
%   
%
%Boundaries of the bounce domain for f0
%  
    XXc(:,1,ir) = XXc(:,1,ir) + XXa(:,1,ir);%Because of cross-derivatives
    XXd(:,1,ir) = XXd(:,1,ir) + XXi(:,1,ir);%Because of cross-derivatives
    XXb(:,1,ir) = XXb(:,1,ir) + XXf(:,1,ir);%Because of cross-derivatives
%
    XXa(:,1,ir) = 0;%Because of cross-derivatives
    XXi(:,1,ir) = 0;%Because of cross-derivatives
    XXf(:,1,ir) = 0;%Because of cross-derivatives
%
    XXc(:,nmhu,ir) = XXc(:,nmhu,ir) + XXe(:,nmhu,ir);%Because of cross-derivatives
    XXd(:,nmhu,ir) = XXd(:,nmhu,ir) + XXg(:,nmhu,ir);%Because of cross-derivatives
    XXb(:,nmhu,ir) = XXb(:,nmhu,ir) + XXh(:,nmhu,ir);%Because of cross-derivatives
%
    XXe(:,nmhu,ir) = 0;%Because of cross-derivatives
    XXg(:,nmhu,ir) = 0;%Because of cross-derivatives
    XXh(:,nmhu,ir) = 0;%Because of cross-derivatives
%
    XXc(1,:,ir) = XXc(1,:,ir) + fliplr(XXb(1,:,ir));%Because of cross-derivatives
    XXa(1,:,ir) = XXa(1,:,ir) + fliplr(XXf(1,:,ir));%Because of cross-derivatives
    XXe(1,:,ir) = XXe(1,:,ir) + fliplr(XXh(1,:,ir));%Because of cross-derivatives
%
    XXb(1,:,ir) = 0;%Because of cross-derivatives
    XXh(1,:,ir) = 0;%Because of cross-derivatives
    XXf(1,:,ir) = 0;%Because of cross-derivatives
%
%Edge boundary conditions for radial transport (Maxwellian solution enforced where radial transport is non-zero)
%
	if ~isempty(Xmask_r_edge) & ir == nr,
    	XXa(:,:,ir) = ~Xmask_r_edge.*XXa(:,:,ir);
    	XXb(:,:,ir) = ~Xmask_r_edge.*XXb(:,:,ir);
    	XXc(:,:,ir) = ~Xmask_r_edge.*XXc(:,:,ir);
    	XXd(:,:,ir) = ~Xmask_r_edge.*XXd(:,:,ir);
    	XXe(:,:,ir) = ~Xmask_r_edge.*XXe(:,:,ir);
    	XXf(:,:,ir) = ~Xmask_r_edge.*XXf(:,:,ir);
    	XXg(:,:,ir) = ~Xmask_r_edge.*XXg(:,:,ir);
    	XXh(:,:,ir) = ~Xmask_r_edge.*XXh(:,:,ir);
    	XXi(:,:,ir) = ~Xmask_r_edge.*XXi(:,:,ir);
    end
%
    if bounce_mode == 0,%No bounce averaging
        Xa_t = XXa(:,:,ir);
        Xb_t = XXb(:,:,ir);
        Xc_t = XXc(:,:,ir);
        Xd_t = XXd(:,:,ir);
        Xe_t = XXe(:,:,ir);
        Xf_t = XXf(:,:,ir);
        Xg_t = XXg(:,:,ir);
        Xh_t = XXh(:,:,ir);
        Xi_t = XXi(:,:,ir);              
        mhu_t = mhu;
        Xpn2_t = Xpn2;
    elseif bounce_mode == 1,%Full implicit bounce-averaging calculations, fifteen diagonals mode
         if djmhut(ir) > 3,%At least three points needed in the bounce domain        
            Xa_t = zeros(npn,nmhu - djmhut(ir));
            Xb_t = zeros(npn,nmhu - djmhut(ir));
            Xc_t = zeros(npn,nmhu - djmhut(ir));
            Xd_t = zeros(npn,nmhu - djmhut(ir));
            Xe_t = zeros(npn,nmhu - djmhut(ir));
            Xf_t = zeros(npn,nmhu - djmhut(ir));
            Xg_t = zeros(npn,nmhu - djmhut(ir));
            Xh_t = zeros(npn,nmhu - djmhut(ir));
            Xi_t = zeros(npn,nmhu - djmhut(ir));
            Xj_t = zeros(npn,nmhu - djmhut(ir));
            Xk_t = zeros(npn,nmhu - djmhut(ir));
            Xl_t = zeros(npn,nmhu - djmhut(ir));
            Xm_t = zeros(npn,nmhu - djmhut(ir));
            Xn_t = zeros(npn,nmhu - djmhut(ir));
            Xo_t = zeros(npn,nmhu - djmhut(ir));
%
            Xa_t(:,Zmask_f0_t_P{ir}) = XXa(:,Zmask_f0_P{ir},ir);
            Xb_t(:,Zmask_f0_t_P{ir}) = XXb(:,Zmask_f0_P{ir},ir);
            Xc_t(:,Zmask_f0_t_P{ir}) = XXc(:,Zmask_f0_P{ir},ir);
            Xd_t(:,Zmask_f0_t_P{ir}) = XXd(:,Zmask_f0_P{ir},ir);
            Xe_t(:,Zmask_f0_t_P{ir}) = XXe(:,Zmask_f0_P{ir},ir);
            Xf_t(:,Zmask_f0_t_P{ir}) = XXf(:,Zmask_f0_P{ir},ir);
            Xg_t(:,Zmask_f0_t_P{ir}) = XXg(:,Zmask_f0_P{ir},ir);
            Xh_t(:,Zmask_f0_t_P{ir}) = XXh(:,Zmask_f0_P{ir},ir);
            Xi_t(:,Zmask_f0_t_P{ir}) = XXi(:,Zmask_f0_P{ir},ir);             
%
%Symmetrization of the trapped region
%
            Xa_t(:,Zmask_f0_t_Tp{ir}) = (XXa(:,Zmask_f0_Tp{ir},ir) + fliplr(XXe(:,Zmask_f0_Tm{ir},ir)))/2;
            Xb_t(:,Zmask_f0_t_Tp{ir}) = (XXb(:,Zmask_f0_Tp{ir},ir) + fliplr(XXb(:,Zmask_f0_Tm{ir},ir)))/2;
            Xc_t(:,Zmask_f0_t_Tp{ir}) = (XXc(:,Zmask_f0_Tp{ir},ir) + fliplr(XXc(:,Zmask_f0_Tm{ir},ir)))/2;
            Xd_t(:,Zmask_f0_t_Tp{ir}) = (XXd(:,Zmask_f0_Tp{ir},ir) + fliplr(XXd(:,Zmask_f0_Tm{ir},ir)))/2;
            Xe_t(:,Zmask_f0_t_Tp{ir}) = (XXe(:,Zmask_f0_Tp{ir},ir) + fliplr(XXa(:,Zmask_f0_Tm{ir},ir)))/2;
            Xf_t(:,Zmask_f0_t_Tp{ir}) = (XXf(:,Zmask_f0_Tp{ir},ir) + fliplr(XXh(:,Zmask_f0_Tm{ir},ir)))/2;
            Xg_t(:,Zmask_f0_t_Tp{ir}) = (XXg(:,Zmask_f0_Tp{ir},ir) + fliplr(XXi(:,Zmask_f0_Tm{ir},ir)))/2;
            Xh_t(:,Zmask_f0_t_Tp{ir}) = (XXh(:,Zmask_f0_Tp{ir},ir) + fliplr(XXf(:,Zmask_f0_Tm{ir},ir)))/2;
            Xi_t(:,Zmask_f0_t_Tp{ir}) = (XXi(:,Zmask_f0_Tp{ir},ir) + fliplr(XXg(:,Zmask_f0_Tm{ir},ir)))/2;
%
            Xh_t(:,jmhut_max(ir) - djmhut(ir)) = Xh_t(:,jmhut_max(ir) - djmhut(ir))/2;
            Xe_t(:,jmhut_max(ir) - djmhut(ir)) = Xe_t(:,jmhut_max(ir) - djmhut(ir))/2;
            Xg_t(:,jmhut_max(ir) - djmhut(ir)) = Xg_t(:,jmhut_max(ir) - djmhut(ir))/2;
%
            Xj_t(:,jmhut_max(ir) - djmhut(ir)) = Xh_t(:,jmhut_max(ir) - djmhut(ir));%f0(i-1/2,j+1/2-djmhut) 
            Xk_t(:,jmhut_max(ir) - djmhut(ir)) = Xe_t(:,jmhut_max(ir) - djmhut(ir));%f0(i+1/2,j+1/2-djmhut)
            Xl_t(:,jmhut_max(ir) - djmhut(ir)) = Xg_t(:,jmhut_max(ir) - djmhut(ir));%f0(i+3/2,j+1/2-djmhut)
%
            Xm_t(:,jmhut_min(ir) - 1) = XXh(:,jmhut_min(ir) - 1,ir);%f0(i-1/2,j+1/2+djmhut)
            Xn_t(:,jmhut_min(ir) - 1) = XXe(:,jmhut_min(ir) - 1,ir);%f0(i+1/2,j+1/2+djmhut)
            Xo_t(:,jmhut_min(ir) - 1) = XXg(:,jmhut_min(ir) - 1,ir);%f0(i+3/2,j+1/2+djmhut)
%   
            Xh_t(:,jmhut_min(ir) - 1) = 0;
            Xe_t(:,jmhut_min(ir) - 1) = 0;
            Xg_t(:,jmhut_min(ir) - 1) = 0;
%
            Xa_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xb_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xc_t(:,nmhu/2 + 1 - djmhut(ir)) = 1;%df0(pn,mhu=pi/2) = 0
            Xd_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xe_t(:,nmhu/2 + 1 - djmhut(ir)) = -1;%df0(pn,mhu=pi/2) = 0
            Xf_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xg_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xh_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xi_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xj_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xk_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xl_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xm_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xn_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
            Xo_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
%       
            mhu_t = mhu(Zmask_f0_t{ir});
            Xpn2_t = Xpn2(:,Zmask_f0_t{ir});           
         else
            error(['WARNING: Not enough pitch-angle grid points in the bounce region for accurate bounce-averaged calculations (increasing nmhu may solve the problem) !'])
        end
    end
    %
    %Local boundary conditions at p = p(1/2): not necessary but help for the density conservation (Dirichlet boundary condition)
    %
    if boundary_mode_f > 0,
        Xa_t(1:boundary_mode_f,:) = 0;
        Xb_t(1:boundary_mode_f,:) = 0;
        Xc_t(1:boundary_mode_f,:) = 0;%Maxwellian solution enforced at p = p(1/2 -> boundary_mode_f-1/2) (More accurate but not fully necessary)
        Xd_t(1:boundary_mode_f,:) = 0;
        Xe_t(1:boundary_mode_f,:) = 0;
        Xf_t(1:boundary_mode_f,:) = 0;
        Xg_t(1:boundary_mode_f,:) = 0;
        Xh_t(1:boundary_mode_f,:) = 0;
        Xi_t(1:boundary_mode_f,:) = 0;
        if bounce_mode == 1,
            Xj_t(1:boundary_mode_f,:) = 0;
            Xk_t(1:boundary_mode_f,:) = 0;
            Xl_t(1:boundary_mode_f,:) = 0;
            Xm_t(1:boundary_mode_f,:) = 0;
            Xn_t(1:boundary_mode_f,:) = 0;
            Xo_t(1:boundary_mode_f,:) = 0;   
%
            Xpn2_t(boundary_mode_f+1:npn,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0 only for p values where the Maxwellian solution is not enforced
        end 
    else
        if bounce_mode == 1,
            Xpn2_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0 
        end
    end
%
    Zpn2_t{ir} = Xpn2_t;    
%
%Momentum flux matrix calculation
%
    if bounce_mode == 0,
        MXc = reshape(Xc_t',(nmhu-ns_f(ir))*npn,1);
        MXP_f_t = sparse([1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn],MXc,(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);
        MXa = reshape(Xa_t',(nmhu-ns_f(ir))*npn,1);
        MXP_f_t = MXP_f_t + sparse([1+1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-1],MXa(1+1:length(MXa)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);
        MXe = reshape(Xe_t',(nmhu-ns_f(ir))*npn,1);
        MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-1],[1+1:(nmhu-ns_f(ir))*npn],MXe(1:length(MXe)-1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);       
        MXb = reshape(Xb_t',(nmhu-ns_f(ir))*npn,1);
        MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir)):(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))],MXb(1+(nmhu-ns_f(ir)):length(MXb)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);           
        MXd = reshape(Xd_t',(nmhu-ns_f(ir))*npn,1);
        MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))],[1+(nmhu-ns_f(ir)):(nmhu-ns_f(ir))*npn],MXd(1:length(MXd)-(nmhu-ns_f(ir))),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);           
        MXf = reshape(Xf_t',(nmhu-ns_f(ir))*npn,1);
        MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))+1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-1],MXf(1+(nmhu-ns_f(ir))+1:length(MXf)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
        MXh = reshape(Xh_t',(nmhu-ns_f(ir))*npn,1);
        MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))-1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+1],MXh(1+(nmhu-ns_f(ir))-1:length(MXh)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
        MXi = reshape(Xi_t',(nmhu-ns_f(ir))*npn,1);
        MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+1],[1+(nmhu-ns_f(ir))-1:(nmhu-ns_f(ir))*npn],MXi(1:length(MXi)-(nmhu-ns_f(ir))+1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
        MXg = reshape(Xg_t',(nmhu-ns_f(ir))*npn,1);
        MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-1],[1+(nmhu-ns_f(ir))+1:(nmhu-ns_f(ir))*npn],MXg(1:length(MXg)-(nmhu-ns_f(ir))-1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
    elseif bounce_mode == 1,
        MXc = reshape(Xc_t',(nmhu-ns_f(ir))*npn,1);%c(i+1/2,j+1/2)
        MXP_f_t = sparse([1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn],MXc,(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);
        MXa = reshape(Xa_t',(nmhu-ns_f(ir))*npn,1);%a(i+1/2,j-1/2)
        MXP_f_t = MXP_f_t + sparse([1+1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-1],MXa(1+1:length(MXa)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);
        MXe = reshape(Xe_t',(nmhu-ns_f(ir))*npn,1);%e(i+1/2,j+3/2)
        MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-1],[1+1:(nmhu-ns_f(ir))*npn],MXe(1:length(MXe)-1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);           
        MXj = reshape(Xj_t',(nmhu-ns_f(ir))*npn,1);%j(i-1/2,j+1/2-djmhut) 
        MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))+djmhut(ir):(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-djmhut(ir)],MXj(1+(nmhu-ns_f(ir))+djmhut(ir):length(MXj)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);              
        MXk = reshape(Xk_t',(nmhu-ns_f(ir))*npn,1);%k(i+1/2,j+1/2-djmhut)
        MXP_f_t = MXP_f_t + sparse([1+djmhut(ir):(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-djmhut(ir)],MXk(1+djmhut(ir):length(MXk)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);        
        MXl = reshape(Xl_t',(nmhu-ns_f(ir))*npn,1);%l(i+3/2,j+1/2-djmhut)
        MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+djmhut(ir)],[1+(nmhu-ns_f(ir))-djmhut(ir):(nmhu-ns_f(ir))*npn],MXl(1:length(MXl)-(nmhu-ns_f(ir))+djmhut(ir)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);      
        MXf = reshape(Xf_t',(nmhu-ns_f(ir))*npn,1);%f(i-1/2,j-1/2)
        MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))+1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-1],MXf(1+(nmhu-ns_f(ir))+1:length(MXf)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
        MXb = reshape(Xb_t',(nmhu-ns_f(ir))*npn,1);%b(i-1/2,j+1/2)
        MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir)):(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))],MXb(1+(nmhu-ns_f(ir)):length(MXb)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);           
        MXh = reshape(Xh_t',(nmhu-ns_f(ir))*npn,1);%h(i-1/2,j+3/2)
        MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))-1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+1],MXh(1+(nmhu-ns_f(ir))-1:length(MXh)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
        MXi = reshape(Xi_t',(nmhu-ns_f(ir))*npn,1);%i(i+3/2,j-1/2)
        MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+1],[1+(nmhu-ns_f(ir))-1:(nmhu-ns_f(ir))*npn],MXi(1:length(MXi)-(nmhu-ns_f(ir))+1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
        MXd = reshape(Xd_t',(nmhu-ns_f(ir))*npn,1);%d(i+3/2,j+1/2)
        MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))],[1+(nmhu-ns_f(ir)):(nmhu-ns_f(ir))*npn],MXd(1:length(MXd)-(nmhu-ns_f(ir))),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);                   
        MXg = reshape(Xg_t',(nmhu-ns_f(ir))*npn,1);%g(i+3/2,j+3/2)
        MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-1],[1+(nmhu-ns_f(ir))+1:(nmhu-ns_f(ir))*npn],MXg(1:length(MXg)-(nmhu-ns_f(ir))-1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
        MXm = reshape(Xm_t',(nmhu-ns_f(ir))*npn,1);%m(i-1/2,j+1/2+djmhut)
        MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))-djmhut(ir):(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+djmhut(ir)],MXm(1+(nmhu-ns_f(ir))-djmhut(ir):length(MXm)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);      
        MXn = reshape(Xn_t',(nmhu-ns_f(ir))*npn,1);%n(i+1/2,j+1/2+djmhut)
        MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-djmhut(ir)],[1+djmhut(ir):(nmhu-ns_f(ir))*npn],MXn(1:length(MXn)-djmhut(ir)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);        
        MXo = reshape(Xo_t',(nmhu-ns_f(ir))*npn,1);%o(i+3/2,j+1/2+djmhut)
        MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-djmhut(ir)],[1+(nmhu-ns_f(ir))+djmhut(ir):(nmhu-ns_f(ir))*npn],MXo(1:length(MXo)-(nmhu-ns_f(ir))-djmhut(ir)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);      
    end
%    
    sm_f(ir+1) = sm_f(ir) + blocksize_f_t(ir);
    [i0_f,j0_f,s0_f] = find(MMXP_f_t);      
    [m0_f,n0_f] = size(MMXP_f_t);
    [i1_f,j1_f,s1_f] = find(MXP_f_t);
    [m1_f,n1_f] = size(MXP_f_t);
    MMXP_f_t = sparse(i0_f,j0_f,s0_f,m0_f+m1_f,m0_f+m1_f) + sparse(m0_f+i1_f,m0_f+j1_f,s1_f,m0_f+m1_f,m0_f+m1_f);
end
%
% Radial supermatrix calculation MMXR_f_t
%   
if ~isempty(transpfaste),%boundary conditions
	%
    % Interpolation coefficients
    %
    xdpsinmm = [0,xdpsin(1:nr-1)];
    xdpsinpp = [xdpsin(2:nr),0];
    %
    XXdpsin = reshape(repmat(xdpsin,npn*nmhu,1),[npn,nmhu,nr]);   
    XXdpsinm = reshape(repmat(xdpsinm,npn*nmhu,1),[npn,nmhu,nr]); 
    XXdpsinp = reshape(repmat(xdpsinp,npn*nmhu,1),[npn,nmhu,nr]); 
    XXdpsinmm = reshape(repmat(xdpsinmm,npn*nmhu,1),[npn,nmhu,nr]);   
    XXdpsinpp = reshape(repmat(xdpsinpp,npn*nmhu,1),[npn,nmhu,nr]);
    %
    XXdeltalp = XXdpsinpp./(XXdpsinpp + XXdpsin);%Grid interpolation coefficients
    XXdeltalm = XXdpsin./(XXdpsinmm + XXdpsin);%Grid interpolation coefficients
	%
    % Diagonal calculations
    %
    XXDpr_ipj = ZXXD_c.pr_ipj + ZXXD_e.pr_ipj + ZXXD_rf.pr_ipj + ZXXD_a.pr_ipj;
    XXDpr_imj = ZXXD_c.pr_imj + ZXXD_e.pr_imj + ZXXD_rf.pr_imj + ZXXD_a.pr_imj;
    %
    XXDmr_ijp = ZXXD_c.mr_ijp + ZXXD_e.mr_ijp + ZXXD_rf.mr_ijp + ZXXD_a.mr_ijp;
    XXDmr_ijm = ZXXD_c.mr_ijm + ZXXD_e.mr_ijm + ZXXD_rf.mr_ijm + ZXXD_a.mr_ijm;
    %
    XXDrr_lp = ZXXD_c.rr_lp + ZXXD_e.rr_lp + ZXXD_rf.rr_lp + ZXXD_a.rr_lp;
    XXDrr_lm = ZXXD_c.rr_lm + ZXXD_e.rr_lm + ZXXD_rf.rr_lm + ZXXD_a.rr_lm;
    XXDrp_lp = ZXXD_c.rp_lp + ZXXD_e.rp_lp + ZXXD_rf.rp_lp + ZXXD_a.rp_lp;
    XXDrp_lm = ZXXD_c.rp_lm + ZXXD_e.rp_lm + ZXXD_rf.rp_lm + ZXXD_a.rp_lm;
    XXDrm_lp = ZXXD_c.rm_lp + ZXXD_e.rm_lp + ZXXD_rf.rm_lp + ZXXD_a.rm_lp;
    XXDrm_lm = ZXXD_c.rm_lm + ZXXD_e.rm_lm + ZXXD_rf.rm_lm + ZXXD_a.rm_lm;
    XXFr_lp = ZXXF_c.r_lp + ZXXF_e.r_lp + ZXXF_rf.r_lp + ZXXF_a.r_lp;
    XXFr_lm = ZXXF_c.r_lm + ZXXF_e.r_lm + ZXXF_rf.r_lm + ZXXF_a.r_lm;
    %
    XXx0 = repmat(reshape(xx0',[1,1,nr]),[npn,nmhu,1]);
    XXx0mm = zeros(npn,nmhu,nr);
    XXx0mm(:,:,2:nr) = XXx0(:,:,1:nr-1);
    XXx0pp = zeros(npn,nmhu,nr);
    XXx0pp(:,:,1:nr-1) = XXx0(:,:,2:nr);
    %
    XXx0p = (1 - XXdeltalp).*XXx0pp + XXdeltalp.*XXx0;%Evaluation on the flux grid (linear interpolation)
    XXx0m = (1 - XXdeltalm).*XXx0 + XXdeltalm.*XXx0mm;%Evaluation on the flux grid (linear interpolation)
    %      
    XXqtilde = repmat(reshape(xqtilde',[1,1,nr]),[npn,nmhu,1]);
    XXqtildemm = zeros(npn,nmhu,nr);
    XXqtildemm(:,:,2:nr) = XXqtilde(:,:,1:nr-1);
    XXqtildepp = zeros(npn,nmhu,nr);
    XXqtildepp(:,:,1:nr-1) = XXqtilde(:,:,2:nr);
    %
    XXqtildep = (1 - XXdeltalp).*XXqtildepp + XXdeltalp.*XXqtilde;%Evaluation on the flux grid (linear interpolation)
    XXqtildem = (1 - XXdeltalm).*XXqtilde + XXdeltalm.*XXqtildemm;%Evaluation on the flux grid (linear interpolation)
    %   
    XXBp0 = repmat(reshape(xBp0',[1,1,nr]),[npn,nmhu,1]);
    XXBp0mm = zeros(npn,nmhu,nr);
    XXBp0mm(:,:,2:nr) = XXBp0(:,:,1:nr-1);
    XXBp0pp = zeros(npn,nmhu,nr);
    XXBp0pp(:,:,1:nr-1) = XXBp0(:,:,2:nr);
    %
    XXBp0p = (1 - XXdeltalp).*XXBp0pp + XXdeltalp.*XXBp0;%Evaluation on the flux grid (linear interpolation)
    XXBp0m = (1 - XXdeltalm).*XXBp0 + XXdeltalm.*XXBp0mm;%Evaluation on the flux grid (linear interpolation)
    %
    XXB0 = repmat(reshape(xB0',[1,1,nr]),[npn,nmhu,1]);
    XXB0mm = zeros(npn,nmhu,nr);
    XXB0mm(:,:,2:nr) = XXB0(:,:,1:nr-1);
    XXB0pp = zeros(npn,nmhu,nr);
    XXB0pp(:,:,1:nr-1) = XXB0(:,:,2:nr);
    %
    XXB0p = (1 - XXdeltalp).*XXB0pp + XXdeltalp.*XXB0;%Evaluation on the flux grid (linear interpolation)
    XXB0m = (1 - XXdeltalm).*XXB0 + XXdeltalm.*XXB0mm;%Evaluation on the flux grid (linear interpolation)
    %
    XXlambdamm = zeros(npn,nmhu,nr);
    XXlambdamm(:,:,2:nr) = XXlambda(:,:,1:nr-1);
    XXlambdapp = zeros(npn,nmhu,nr);
    XXlambdapp(:,:,1:nr-1) = XXlambda(:,:,2:nr);
    %
    XXlambdap = (1 - XXdeltalp).*XXlambdapp + XXdeltalp.*XXlambda;%Evaluation on the flux grid (linear interpolation)
    XXlambdam = (1 - XXdeltalm).*XXlambda + XXdeltalm.*XXlambdamm;%Evaluation on the flux grid (linear interpolation)
    %   
    XXgradpsinp = (1.0 + XXx0p/Rp).*XXBp0p*ap^2/psia_apRp;
    XXgradpsinm = (1.0 + XXx0m/Rp).*XXBp0m*ap^2/psia_apRp;
    %
    XXalpharp = XXqtildep.*XXgradpsinp.*XXlambdap./XXB0p;%Evaluation on the flux grid (linear interpolation)
    XXalpharm = XXqtildem.*XXgradpsinm.*XXlambdam./XXB0m;%Evaluation on the flux grid (linear interpolation)
    XXalpharm(:,:,1) = 0;%Force zero at the plasma center, which is the natural analytical limit (In cylindrical geometry, r=0)
    XXalpharp(:,:,nr) = 0;%Avoid NaN
    %      
    MMXR_f_t = sparse(nMMXP_f_t,nMMXP_f_t);%Create supermatrix
    %  
    XXMrm = -(XXalpharm.*XXgradpsinm./XXdpsinm./XXdpsin).*XXDrr_lm - (XXalpharm./XXdpsin).*XXFr_lm.*XXdeltalm;
    XXMr = (XXalpharp.*XXgradpsinp./XXdpsinp./XXdpsin).*XXDrr_lp + (XXalpharp./XXdpsin).*XXFr_lp.*XXdeltalp + (XXalpharm.*XXgradpsinm./XXdpsinm./XXdpsin).*XXDrr_lm - (XXalpharm./XXdpsin).*XXFr_lm.*(1 - XXdeltalm);                    
    XXMrp = -(XXalpharp.*XXgradpsinp./XXdpsinp./XXdpsin).*XXDrr_lp + (XXalpharp./XXdpsin).*XXFr_lp.*(1 - XXdeltalp);
    %
    XXMrm = (XXB0./XXqtilde).*XXMrm.*XXpn2./XXlambda;%Jacobian multiplication
    XXMr = (XXB0./XXqtilde).*XXMr.*XXpn2./XXlambda;%Jacobian multiplication
    XXMrp = (XXB0./XXqtilde).*XXMrp.*XXpn2./XXlambda;%Jacobian multiplication   
    %
    XXMrm(:,:,nr) = 0;%Edge boundary condition (Maxwellian solution)
    XXMr(:,:,nr) = 0;%Edge boundary condition (Maxwellian solution)
%
% Radial off-diagonal terms for fast electron transport
%
    if bounce_mode == 0,
        XXMrm = permute(XXMrm,[2,1,3]);
        MMrm_t = reshape(XXMrm,npn*nmhu*nr,1,1);
        XXMr = permute(XXMr,[2,1,3]);
        MMr_t = reshape(XXMr,npn*nmhu*nr,1,1);
        XXMrp = permute(XXMrp,[2,1,3]);
        MMrp_t = reshape(XXMrp,npn*nmhu*nr,1,1);
        %
        MMXR_f_t = MMXR_f_t + sparse(1+nmhu*npn:nMMXP_f_t,1:nMMXP_f_t-nmhu*npn,MMrm_t(1+npn*nmhu:nMMXP_f_t),nMMXP_f_t,nMMXP_f_t);
        MMXR_f_t = MMXR_f_t + sparse(1:nMMXP_f_t,1:nMMXP_f_t,MMr_t,nMMXP_f_t,nMMXP_f_t);    
        MMXR_f_t = MMXR_f_t + sparse(1:nMMXP_f_t-nmhu*npn,1+npn*nmhu:nMMXP_f_t,MMrp_t(1:nMMXP_f_t-nmhu*npn),nMMXP_f_t,nMMXP_f_t);
        %
        if display_mode >= 1,info_dke_yp(2,['Zero order configuration space matrix calculations done in ',num2str(etime(clock,time0)),' (s)']);end
    elseif bounce_mode == 1,
        %
        % First magnetic flux surface
        %
        ir = 1;
        ib0 = 0;
        ibp = max(cumsum(blocksize_f_t(1:ir)));
        %
        Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
        Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
        Xmask_f0p = (Xmhu2 < xmhubounce2(ir+1)) & (Xmhu < 0);%Only the half-bounce region is removed
        Xmask_f0p = nonzeros(~(Xmask_f0p(2,:)==1).*cumsum(ones(1,nmhu)))';
        %   
        imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir))); 
        imhup = sum((Xmhu(1,Xmask_f0p) < 0).*(Xmhu2(1,Xmask_f0p) > xmhubounce2(ir+1)));
        %
        XMr = XXMr(:,:,ir);
        XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
        MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
        %        
        MMXR_f_t_i = zeros(nMMXP_f_t*11*nr,1);%Create oversized sparse matrix to avoid reallocation
        MMXR_f_t_j = zeros(nMMXP_f_t*11*nr,1);
        MMXR_f_t_v = zeros(nMMXP_f_t*11*nr,1);
        %
        i = 1+ib0:ibp;
        j = 1+ib0:ibp;
        ia = 1;ib = ia+length(i);                 
        MMXR_f_t_i(ia:ib-1) = i;
        MMXR_f_t_j(ia:ib-1) = j;
        MMXR_f_t_v(ia:ib-1) = MMr_t;
        %           
        % Notations: bc: backward + circulating, t: trapped (half positive part only), fc: forward + circulating
        %           
        XMrp = XXMrp(:,:,ir);
        XMrp_t = XMrp(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
        XMrp1_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir+1));%bc -> bc
        XMrp2_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir+1)).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));%bc -> t
        XMrp3_t = XMrp_t.*(Xmhu(:,Xmask_f0) > 0);%fc + t -> fc + t
        %   
        for ip = 1:npn, 
            i = ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhup;
            j = ibp+(nmhu-ns_f(ir+1))*(ip-1)+1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup;
            ia = ib;ib = ia+length(i);
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = XMrp1_t(ip,1:imhup)';%bc -> bc
            %
            i = ib0+(nmhu-ns_f(ir))*(ip-1)+imhup+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0;
            j = ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhup):-1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhu0)+1;
            ia = ib;ib = ia+length(i);
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = XMrp2_t(ip,imhup+1:imhu0)';%bc -> t
            %
            i = ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip;
            j = ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup+1:ibp+(nmhu-ns_f(ir+1))*ip;
            ia = ib;ib = ia+length(i);
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = XMrp3_t(ip,imhu0+1:nmhu-ns_f(ir))';%fc + t -> fc + t 
        end 
        %
        % All magnetic flux surface except the first and the last ones
        %
        for ir = 2:nr-1,
            if ir == 2,
                ibm = 0;
            else
                ibm = max(cumsum(blocksize_f_t(1:ir-2)));%Block index reference
            end
            %
            ib0 = max(cumsum(blocksize_f_t(1:ir-1)));%Block index reference
            ibp = max(cumsum(blocksize_f_t(1:ir)));
            %
            Xmask_f0m = (Xmhu2 < xmhubounce2(ir-1)) & (Xmhu < 0);%Only the half-bounce region is removed
            Xmask_f0m = nonzeros(~(Xmask_f0m(2,:)==1).*cumsum(ones(1,nmhu)))';
            Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
            Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
            Xmask_f0p = (Xmhu2 < xmhubounce2(ir+1)) & (Xmhu < 0);%Only the half-bounce region is removed
            Xmask_f0p = nonzeros(~(Xmask_f0p(2,:)==1).*cumsum(ones(1,nmhu)))';
            %   
            imhum = sum((Xmhu(1,Xmask_f0m) < 0).*(Xmhu2(1,Xmask_f0m) > xmhubounce2(ir-1)));
            imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir))); 
            imhup = sum((Xmhu(1,Xmask_f0p) < 0).*(Xmhu2(1,Xmask_f0p) > xmhubounce2(ir+1)));
            %
            XMr = XXMr(:,:,ir);
            XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
            MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
            %           
            i = 1+ib0:ibp;
            j = 1+ib0:ibp;
            ia = ib;ib = ia+length(i); 
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = MMr_t;
            %           
            % Notations: bc: backward + circulating, t: trapped (half positive part only), fc: forward + circulating
            %
            XMrp = XXMrp(:,:,ir);
            XMrp_t = XMrp(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
            XMrp1_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir+1));%bc -> bc
            XMrp2_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir+1)).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));%bc -> t
            XMrp3_t = XMrp_t.*(Xmhu(:,Xmask_f0) > 0);%t+fc -> t+fc     
            %           
            XMrm = XXMrm(:,:,ir);
            XMrm_t = XMrm(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
            XMrm1_t = XMrm_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));%bc -> bc
            XMrm2_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir-1));%t -> t
            XMrm3_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir-1)).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir));%t -> fc
            XMrm4_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));%fc -> fc
            %            
            for ip = 1:npn, 
                i = ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhup;
                j = ibp+(nmhu-ns_f(ir+1))*(ip-1)+1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup;
                ia = ib;ib = ia+length(i);     
                MMXR_f_t_i(ia:ib-1) = i;
                MMXR_f_t_j(ia:ib-1) = j;
                MMXR_f_t_v(ia:ib-1) = XMrp1_t(ip,1:imhup)';%bc -> bc
                %               
                i = ib0+(nmhu-ns_f(ir))*(ip-1)+imhup+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0;
                j = ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhup):-1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhu0)+1;
                ia = ib;ib = ia+length(i);
                MMXR_f_t_i(ia:ib-1) = i;
                MMXR_f_t_j(ia:ib-1) = j;
                MMXR_f_t_v(ia:ib-1) = XMrp2_t(ip,imhup+1:imhu0)';  
                %               
                i = ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip;
                j = ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup+1:ibp+(nmhu-ns_f(ir+1))*ip;
                ia = ib;ib = ia+length(i);
                MMXR_f_t_i(ia:ib-1) = i;
                MMXR_f_t_j(ia:ib-1) = j;
                MMXR_f_t_v(ia:ib-1) = XMrp3_t(ip,imhu0+1:nmhu-ns_f(ir))'; 
                % 
                i = ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0;
                j = ibm+(nmhu-ns_f(ir-1))*(ip-1)+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhu0;
                ia = ib;ib = ia+length(i);
                MMXR_f_t_i(ia:ib-1) = i;
                MMXR_f_t_j(ia:ib-1) = j;
                MMXR_f_t_v(ia:ib-1) = XMrm1_t(ip,1:imhu0)'; 
                %
                i = ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*(ip-1)+((nmhu-ns_f(ir))-imhum);
                j = ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhum+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+((nmhu-ns_f(ir-1))-imhum);
                ia = ib;ib = ia+length(i);
                MMXR_f_t_i(ia:ib-1) = i;
                MMXR_f_t_j(ia:ib-1) = j;
                MMXR_f_t_v(ia:ib-1) = XMrm2_t(ip,imhu0+1:((nmhu-ns_f(ir))-imhum))'; 
                %
                i = ib0+(nmhu-ns_f(ir))*(ip-1)+((nmhu-ns_f(ir))-imhum)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+((nmhu-ns_f(ir))-imhu0);
                j = ibm+(nmhu-ns_f(ir-1))*(ip-1)+((nmhu-ns_f(ir-1))-imhum)+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+((nmhu-ns_f(ir-1))-imhu0);               
                ia = ib;ib = ia+length(i);
                MMXR_f_t_i(ia:ib-1) = i;
                MMXR_f_t_j(ia:ib-1) = j;
                MMXR_f_t_v(ia:ib-1) = XMrm3_t(ip,((nmhu-ns_f(ir))-imhum)+1:((nmhu-ns_f(ir))-imhu0))'/2; 
                j = ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhum:-1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhu0+1;
                ia = ib;ib = ia+length(i);
                MMXR_f_t_i(ia:ib-1) = i;
                MMXR_f_t_j(ia:ib-1) = j;
                MMXR_f_t_v(ia:ib-1) = XMrm3_t(ip,((nmhu-ns_f(ir))-imhum)+1:((nmhu-ns_f(ir))-imhu0))'/2; 
                %       
                i = ib0+(nmhu-ns_f(ir))*(ip-1)+(nmhu-ns_f(ir))-imhu0+1:ib0+(nmhu-ns_f(ir))*ip;
                j = ibm+(nmhu-ns_f(ir-1))*(ip-1)+(nmhu-ns_f(ir-1))-imhu0+1:ibm+(nmhu-ns_f(ir-1))*ip;
                ia = ib;ib = ia+length(i);
                MMXR_f_t_i(ia:ib-1) = i;
                MMXR_f_t_j(ia:ib-1) = j;
                MMXR_f_t_v(ia:ib-1) = XMrm4_t(ip,(nmhu-ns_f(ir))-imhu0+1:nmhu-ns_f(ir))';
            end 
        end
        %
        % Last magnetic flux surface
        %
        ir = nr;
        ibm = max(cumsum(blocksize_f_t(1:ir-2)));%Block index reference
        ib0 = max(cumsum(blocksize_f_t(1:ir-1)));%Block index reference
        ibp = max(cumsum(blocksize_f_t(1:ir)));
        %
        Xmask_f0m = (Xmhu2 < xmhubounce2(ir-1)) & (Xmhu < 0);%Only the half-bounce region is removed
        Xmask_f0m = nonzeros(~(Xmask_f0m(2,:)==1).*cumsum(ones(1,nmhu)))';
        Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
        Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
        %   
        imhum = sum((Xmhu(1,Xmask_f0m) < 0).*(Xmhu2(1,Xmask_f0m) > xmhubounce2(ir-1)));
        imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir))); 
        %
        XMr = XXMr(:,:,ir);
        XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
        MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
        %        
        i = 1+ib0:ibp;
        j = 1+ib0:ibp;
        ia = ib;ib = ia+length(i);
        MMXR_f_t_i(ia:ib-1) = i;
        MMXR_f_t_j(ia:ib-1) = j;
        MMXR_f_t_v(ia:ib-1) = MMr_t;
        %           
        XMrm = XXMrm(:,:,ir);
        XMrm_t = XMrm(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
        XMrm1_t = XMrm_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
        %         XMrm2_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0);
        XMrm2_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir-1));%t -> t
        XMrm3_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir-1)).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir));%t -> fc
        XMrm4_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));%fc -> fc
%   
        for ip = 1:npn, 
            i = ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0;
            j = ibm+(nmhu-ns_f(ir-1))*(ip-1)+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhu0;
            ia = ib;ib = ia+length(i);
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = XMrm1_t(ip,1:imhu0)'; 
            %
            i = ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*(ip-1)+((nmhu-ns_f(ir))-imhum);
            j = ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhum+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+((nmhu-ns_f(ir-1))-imhum);
            ia = ib;ib = ia+length(i);
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = XMrm2_t(ip,imhu0+1:((nmhu-ns_f(ir))-imhum))'; 
            %
            i = ib0+(nmhu-ns_f(ir))*(ip-1)+((nmhu-ns_f(ir))-imhum)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+((nmhu-ns_f(ir))-imhu0);
            j = ibm+(nmhu-ns_f(ir-1))*(ip-1)+((nmhu-ns_f(ir-1))-imhum)+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+((nmhu-ns_f(ir-1))-imhu0);
            ia = ib;ib = ia+length(i);
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = XMrm3_t(ip,((nmhu-ns_f(ir))-imhum)+1:((nmhu-ns_f(ir))-imhu0))'/2;
            j = ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhum:-1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhu0+1;
            ia = ib;ib = ia+length(i);
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = XMrm3_t(ip,((nmhu-ns_f(ir))-imhum)+1:((nmhu-ns_f(ir))-imhu0))'/2; 
            %       
            i = ib0+(nmhu-ns_f(ir))*(ip-1)+(nmhu-ns_f(ir))-imhu0+1:ib0+(nmhu-ns_f(ir))*ip;
            j = ibm+(nmhu-ns_f(ir-1))*(ip-1)+(nmhu-ns_f(ir-1))-imhu0+1:ibm+(nmhu-ns_f(ir-1))*ip;
            ia = ib;ib = ia+length(i);
            MMXR_f_t_i(ia:ib-1) = i;
            MMXR_f_t_j(ia:ib-1) = j;
            MMXR_f_t_v(ia:ib-1) = XMrm4_t(ip,(nmhu-ns_f(ir))-imhu0+1:nmhu-ns_f(ir))';
        end
        %
        MMXR_f_t = sparse(MMXR_f_t_i(1:ib-1),MMXR_f_t_j(1:ib-1),MMXR_f_t_v(1:ib-1),nMMXP_f_t,nMMXP_f_t);%Create sparse radial transport matrix
        %
        if display_mode >= 1,info_dke_yp(2,['Zero order configuration space matrix calculations done in ',num2str(etime(clock,time0)),' (s)']);end
    end     
else
	MMXR_f_t = sparse(nMMXP_f_t,nMMXP_f_t);%Create empty supermatrix
end
%
% Time diagonal supermatrix calculation MMXT_f_t
%
for ir = 1:nr,
    MXT = reshape(Zpn2_t{ir}',(nmhu-ns_f(ir))*npn,1)/dtn;%Partial momentum Jacobian 
    MXT_f_t = sparse([1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn],MXT,(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);%Resizing for 3D calculations + multiplication by the remaining Jacobian
%
    sm_T_f(ir+1) = sm_T_f(ir) + blocksize_T_f_t(ir);
    [i0_T_f,j0_T_f,s0_T_f] = find(MMXT_f_t);        
    [m0_T_f,n0_T_f] = size(MMXT_f_t);
    [i1_T_f,j1_T_f,s1_T_f] = find(MXT_f_t);
    [m1_T_f,n1_T_f] = size(MXT_f_t);
    MMXT_f_t = sparse(i0_T_f,j0_T_f,s0_T_f,m0_T_f+m1_T_f,m0_T_f+m1_T_f) + sparse(m0_T_f+i1_T_f,m0_T_f+j1_T_f,s1_T_f,m0_T_f+m1_T_f,m0_T_f+m1_T_f);   
%   
    etime_fp = etime_fp + etime(clock,time0);
    time0 = clock;
end
%
Zdelta.XXdeltap_limj = XXdeltap_limj; 
Zdelta.XXdeltap_lipj = XXdeltap_lipj;
Zdelta.XXdeltam_lijp = XXdeltam_lijp;
Zdelta.XXdeltam_lijm = XXdeltam_lijm;   
Zdelta.XXdeltap_limjmm = XXdeltap_limjmm;
Zdelta.XXdeltap_limjpp = XXdeltap_limjpp;
Zdelta.XXdeltap_lipjmm = XXdeltap_lipjmm;
Zdelta.XXdeltap_lipjpp = XXdeltap_lipjpp;
Zdelta.XXdeltam_limmjm = XXdeltam_limmjm;
Zdelta.XXdeltam_lippjm = XXdeltam_lippjm;
Zdelta.XXdeltam_limmjp = XXdeltam_limmjp;
Zdelta.XXdeltam_lippjp = XXdeltam_lippjp;
%
if display_mode >= 1,info_dke_yp(2,['Zero order momentum space matrix calculations done in ',num2str(etime_fp),' (s)']);end
%
% DKE (first order) matrix calculation
%
%boundary_mode_f = dkeparam.boundary_mode_f;
%dke_mode = dkeparam.dke_mode;
%bounce_mode = dkeparam.bounce_mode;
%store_mode = dkeparam.store_mode;
%dtn = dkeparam.dtn;
%
%display_mode = display.display_mode;
%
%nr = gridDKE.nr;
%npn = gridDKE.npn;
%nmhu = gridDKE.nmhu;
%nr_dke = gridDKE.nr_dke;
%mhu = gridDKE.mhu;
%Xdmhumm = gridDKE.Xdmhumm;
%Xdmhum = gridDKE.Xdmhum;
%Xdmhu = gridDKE.Xdmhu;
%Xdmhup = gridDKE.Xdmhup;
%Xdmhupp = gridDKE.Xdmhupp;
%Xdpnmm = gridDKE.Xdpnmm;
%Xdpnm = gridDKE.Xdpnm;
%Xdpn = gridDKE.Xdpn;
%Xdpnp = gridDKE.Xdpnp;
%Xdpnpp = gridDKE.Xdpnpp;
%Xmhumm = gridDKE.Xmhumm;
%Xmhum = gridDKE.Xmhum;
%Xmhu = gridDKE.Xmhu;
%Xmhu2 = gridDKE.Xmhu2;
%Xmhup = gridDKE.Xmhup;
%Xmhupp = gridDKE.Xmhupp;
%X1mmhu2m = gridDKE.X1mmhu2m;
%X1mmhu2 = gridDKE.X1mmhu2;
%X1mmhu2p = gridDKE.X1mmhu2p;
%pn = gridDKE.pn;
%Xpnmm = gridDKE.Xpnmm;
%Xpnm = gridDKE.Xpnm;
%Xpn = gridDKE.Xpn;
%Xpnp = gridDKE.Xpnp;
%Xpnpp = gridDKE.Xpnpp;
%Xpn2m = gridDKE.Xpn2m;
%Xpn2 = gridDKE.Xpn2;
%Xpn2p = gridDKE.Xpn2p;
%XXpn2 = gridDKE.XXpn2;
%
%xpsin = gridDKE.xpsin;
%xdpsin = gridDKE.xdpsin_dke;
%xdpsinm = gridDKE.xdpsinm_dke;
%xdpsinp = gridDKE.xdpsinp_dke;
%xmhubounce2 = gridDKE.xmhubounce2;
%rdke = gridDKE.rdke;
%xrho = gridDKE.xrho;
%
%gamma = Zmomcoef.gamma;
%Xvpar = Zmomcoef.Xvpar;
%
%djmhut = Zbouncecoef.djmhut;
%Zmask_f0_P = Zbouncecoef.Zmask_f0_P;
%Zbouncecoef.Zmask_f0_P = Zmask_f0_P;
%Zmask_f0_Tm = Zbouncecoef.Zmask_f0_Tm;
%Zmask_f0_Tp = Zbouncecoef.Zmask_f0_Tp;
%jmhut_min = Zbouncecoef.jmhut_min;
%jmhut_max = Zbouncecoef.jmhut_max;
%Zmask_f0_t = Zbouncecoef.Zmask_f0_t;
%Zmask_f0_t_P = Zbouncecoef.Zmask_f0_t_P;
%Zmask_f0_t_Tp = Zbouncecoef.Zmask_f0_t_Tp;
%ns_f = Zbouncecoef.ns_f;    
%XXlambda = Zbouncecoef.XXlambda;
%XXRlambda_m = Zbouncecoef.XXRlambda_m;
%XXRlambda_p = Zbouncecoef.XXRlambda_p;
%sm_f = Zbouncecoef.sm_f;
%sm_T_f = Zbouncecoef.sm_T_f;
%blocksize_f_t = Zbouncecoef.blocksize_f_t;
%blocksize_T_f_t = Zbouncecoef.blocksize_T_f_t;
%xqtilde = Zbouncecoef.xqtilde;
%
%xx0 = equilDKE.xx0;
%xBp0 = equilDKE.xBp0;
%xB0 = equilDKE.xB0;
%ap = equilDKE.ap;
%Rp = equilDKE.Rp;
%psia_apRp = equilDKE.psia_apRp;
%
%betath_ref = mksa.betath_ref;
%nhu_ref = mksa.nhu_ref;
%
%bounce_mode = dkeparam.bounce_mode;    
%
%if dke_mode == 1,
%Zmask_g = Zbouncecoef.Zmask_g;
%ns_g = Zbouncecoef.ns_g;
%xftp_norm = mksa.xftp_norm_ref;
%boundary_mode_g = dkeparam.boundary_mode_g;
%sm_tp = Zbouncecoef.sm_tp;
%sm_g = Zbouncecoef.sm_g;
%blocksize_tp = Zbouncecoef.blocksize_tp;    
%blocksize_g_t = Zbouncecoef.blocksize_g_t;
%
%end
%
%
%nMMXP_f_t = max(cumsum(Zbouncecoef.blocksize_f_t));
%
%MMXP_tp = [];
%MMXP_g_t = [];
%MMH_tp = [];
%
etime_dke = 0;
time0 = clock;
%
if dke_mode == 1,
    for ir_dke = 1:nr_dke,
%
        jr1 = rdke(ir_dke)-1;
        jr2 = rdke(ir_dke);
        jr3 = rdke(ir_dke)+1;
%   
% D and F tensors
% 
        XDpp_tp_ippj = ZXXD_c_tp.pp_ippj(:,:,ir_dke) + ZXXD_e_tp.pp_ippj(:,:,ir_dke) + ZXXD_rf_tp.pp_ippj(:,:,ir_dke);
        XDpp_tp_ipj = ZXXD_c_tp.pp_ipj(:,:,ir_dke) + ZXXD_e_tp.pp_ipj(:,:,ir_dke) + ZXXD_rf_tp.pp_ipj(:,:,ir_dke);
        XDpp_tp_ij = ZXXD_c_tp.pp_ij(:,:,ir_dke) + ZXXD_e_tp.pp_ij(:,:,ir_dke) + ZXXD_rf_tp.pp_ij(:,:,ir_dke);
        XDpp_tp_imj = ZXXD_c_tp.pp_imj(:,:,ir_dke) + ZXXD_e_tp.pp_imj(:,:,ir_dke) + ZXXD_rf_tp.pp_imj(:,:,ir_dke);
        XDpp_tp_immj = ZXXD_c_tp.pp_immj(:,:,ir_dke) + ZXXD_e_tp.pp_immj(:,:,ir_dke) + ZXXD_rf_tp.pp_immj(:,:,ir_dke);
%
        XDpm_tp_ipj = ZXXD_c_tp.pm_ipj(:,:,ir_dke) + ZXXD_e_tp.pm_ipj(:,:,ir_dke) + ZXXD_rf_tp.pm_ipj(:,:,ir_dke);
        XDpm_tp_ij = ZXXD_c_tp.pm_ij(:,:,ir_dke) + ZXXD_e_tp.pm_ij(:,:,ir_dke) + ZXXD_rf_tp.pm_ij(:,:,ir_dke);
        XDpm_tp_imj = ZXXD_c_tp.pm_imj(:,:,ir_dke) + ZXXD_e_tp.pm_imj(:,:,ir_dke) + ZXXD_rf_tp.pm_imj(:,:,ir_dke);
%
        XDmp_tp_ijp = ZXXD_c_tp.mp_ijp(:,:,ir_dke) + ZXXD_e_tp.mp_ijp(:,:,ir_dke) + ZXXD_rf_tp.mp_ijp(:,:,ir_dke);
        XDmp_tp_ij = ZXXD_c_tp.mp_ij(:,:,ir_dke) + ZXXD_e_tp.mp_ij(:,:,ir_dke) + ZXXD_rf_tp.mp_ij(:,:,ir_dke);
        XDmp_tp_ijm = ZXXD_c_tp.mp_ijm(:,:,ir_dke) + ZXXD_e_tp.mp_ijm(:,:,ir_dke) + ZXXD_rf_tp.mp_ijm(:,:,ir_dke);
%
        XDmm_tp_ijp = ZXXD_c_tp.mm_ijp(:,:,ir_dke) + ZXXD_e_tp.mm_ijp(:,:,ir_dke) + ZXXD_rf_tp.mm_ijp(:,:,ir_dke);
        XDmm_tp_ijm = ZXXD_c_tp.mm_ijm(:,:,ir_dke) + ZXXD_e_tp.mm_ijm(:,:,ir_dke) + ZXXD_rf_tp.mm_ijm(:,:,ir_dke);
%
        XFp_tp_ippj = ZXXF_c_tp.p_ippj(:,:,ir_dke) + ZXXF_e_tp.p_ippj(:,:,ir_dke) + ZXXF_rf_tp.p_ippj(:,:,ir_dke);
        XFp_tp_ipj = ZXXF_c_tp.p_ipj(:,:,ir_dke) + ZXXF_e_tp.p_ipj(:,:,ir_dke) + ZXXF_rf_tp.p_ipj(:,:,ir_dke);
        XFp_tp_ij = ZXXF_c_tp.p_ij(:,:,ir_dke) + ZXXF_e_tp.p_ij(:,:,ir_dke) + ZXXF_rf_tp.p_ij(:,:,ir_dke);
        XFp_tp_imj = ZXXF_c_tp.p_imj(:,:,ir_dke) + ZXXF_e_tp.p_imj(:,:,ir_dke) + ZXXF_rf_tp.p_imj(:,:,ir_dke);
        XFp_tp_immj = ZXXF_c_tp.p_immj(:,:,ir_dke) + ZXXF_e_tp.p_immj(:,:,ir_dke) + ZXXF_rf_tp.p_immj(:,:,ir_dke);
%
        XFm_tp_ijp = ZXXF_c_tp.m_ijp(:,:,ir_dke) + ZXXF_e_tp.m_ijp(:,:,ir_dke) + ZXXF_rf_tp.m_ijp(:,:,ir_dke);
        XFm_tp_ijm = ZXXF_c_tp.m_ijm(:,:,ir_dke) + ZXXF_e_tp.m_ijm(:,:,ir_dke) + ZXXF_rf_tp.m_ijm(:,:,ir_dke);
%
        [Xa_tp,Xb_tp,Xc_tp,Xd_tp,Xe_tp,Xf_tp,Xg_tp,Xh_tp,Xi_tp] = ...
            fpengine_dke_yp(dkeparam,1,...
            XXdeltap_limj(:,:,jr2),XXdeltap_lipj(:,:,jr2),XXdeltam_lijm(:,:,jr2),XXdeltam_lijp(:,:,jr2),...
            XXdeltap_limjmm(:,:,jr2),XXdeltap_limjpp(:,:,jr2),XXdeltap_lipjmm(:,:,jr2),XXdeltap_lipjpp(:,:,jr2),...
            XXdeltam_limmjm(:,:,jr2),XXdeltam_lippjm(:,:,jr2),XXdeltam_limmjp(:,:,jr2),XXdeltam_lippjp(:,:,jr2),...
            XXRlambda_m(:,:,jr2),XXRlambda_p(:,:,jr2),...
            Xpnmm,Xpnm,Xpn,Xpnp,Xpnpp,Xpn2m,Xpn2p,Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
            Xmhumm,Xmhum,Xmhu,Xmhup,Xmhupp,X1mmhu2,X1mmhu2m,X1mmhu2p,Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
            XDpp_tp_ippj,XDpp_tp_ipj,XDpp_tp_ij,XDpp_tp_imj,XDpp_tp_immj,...
            XDpm_tp_ipj,XDpm_tp_ij,XDpm_tp_imj,...
            XDmp_tp_ijp,XDmp_tp_ij,XDmp_tp_ijm,...
            XDmm_tp_ijp,XDmm_tp_ijm,...
            XFp_tp_ippj,XFp_tp_ipj,XFp_tp_ij,XFp_tp_imj,XFp_tp_immj,...
            XFm_tp_ijp,XFm_tp_ijm); 
%
%Boundary conditions because of cross-derivatives (symmetry of f: fj-1/2=fj+1/2)
%
        Xc_tp(:,1) = Xc_tp(:,1) + Xa_tp(:,1);
        Xd_tp(:,1) = Xd_tp(:,1) + Xi_tp(:,1);
        Xb_tp(:,1) = Xb_tp(:,1) + Xf_tp(:,1);

        Xa_tp(:,1) = 0;
        Xi_tp(:,1) = 0;
        Xf_tp(:,1) = 0;

        Xc_tp(:,nmhu) = Xc_tp(:,nmhu) + Xe_tp(:,nmhu);
        Xd_tp(:,nmhu) = Xd_tp(:,nmhu) + Xg_tp(:,nmhu);
        Xb_tp(:,nmhu) = Xb_tp(:,nmhu) + Xh_tp(:,nmhu);

        Xe_tp(:,nmhu) = 0;
        Xg_tp(:,nmhu) = 0;
        Xh_tp(:,nmhu) = 0;

        Xc_tp(1,:) = Xc_tp(1,:) + fliplr(Xb_tp(1,:));
        Xa_tp(1,:) = Xa_tp(1,:) + fliplr(Xf_tp(1,:));
        Xe_tp(1,:) = Xe_tp(1,:) + fliplr(Xh_tp(1,:));

        Xb_tp(1,:) = 0;
        Xh_tp(1,:) = 0;
        Xf_tp(1,:) = 0;
%
%Correction matrix resulting from the radial gradient of Chang and Cooper interpolation coefficients
%                   
        dpsim = (xpsin(jr1) - xpsin(jr2));%Radial step for parabolic gradient calculations (dke)
        dpsi = (xpsin(jr3) - xpsin(jr1));%Radial step for parabolic gradient calculations (dke)
        dpsip = (xpsin(jr3) - xpsin(jr2));%Radial step for parabolic gradient calculations (dke)      
%                           
        XXH_tp_mm(:,:,jr1) = (xftp_norm(jr2)*dpsip/dpsi/dpsim)*(XXdeltap_limj(:,:,jr2) - XXdeltap_limj(:,:,jr1)).*XFp_tp_imj.*Xmhu.*Xpn2m.*Xpnm./Xdpn;
        XXH_tp_mp(:,:,jr1) = (xftp_norm(jr2)*dpsip/dpsi/dpsim)*(XXdeltap_lipj(:,:,jr2) - XXdeltap_lipj(:,:,jr1)).*XFp_tp_ipj.*Xmhu.*Xpn2p.*Xpnp./Xdpn;
        XXH_tp_m(:,:,jr1) = -XXH_tp_mm(:,:,jr1) - XXH_tp_mp(:,:,jr1);
%
        XXH_tp_pm(:,:,jr3) = -(xftp_norm(jr2)*dpsim/dpsi/dpsip)*(XXdeltap_limj(:,:,jr2) - XXdeltap_limj(:,:,jr3)).*XFp_tp_imj.*Xmhu.*Xpn2m.*Xpnm./Xdpn;
        XXH_tp_pp(:,:,jr3) = -(xftp_norm(jr2)*dpsim/dpsi/dpsip)*(XXdeltap_lipj(:,:,jr2) - XXdeltap_lipj(:,:,jr3)).*XFp_tp_ipj.*Xmhu.*Xpn2p.*Xpnp./Xdpn;       
        XXH_tp_p(:,:,jr3) = -XXH_tp_pm(:,:,jr3) - XXH_tp_pp(:,:,jr3);
%
%Matrix coefficients calculations for g
%
        Xa_g = XXa(:,:,jr2);%g(i+1/2,j-1/2)
        Xb_g = XXb(:,:,jr2);%g(i-1/2,j+1/2)
        Xc_g = XXc(:,:,jr2);%g(i+1/2,j+1/2) (Since matrix coefficients for f0 and g are the same)
        Xd_g = XXd(:,:,jr2);%g(i+3/2,j+1/2)
        Xe_g = XXe(:,:,jr2);%g(i+1/2,j+3/2)
        Xf_g = XXf(:,:,jr2);%g(i-1/2,j-1/2)
        Xg_g = XXg(:,:,jr2);%g(i+3/2,j+3/2)
        Xh_g = XXh(:,:,jr2);%g(i-1/2,j+3/2)
        Xi_g = XXi(:,:,jr2);%g(i+3/2,j-1/2)
%
%Boundary conditions for g (the Lorentz model is enforced at p = 0)
%
        if boundary_mode_g > 0,
            Xa_g(1:boundary_mode_g,:) = 0;%g(i+1/2,j-1/2)
            Xb_g(1:boundary_mode_g,:) = 0;%g(i-1/2,j+1/2)
            Xc_g(1:boundary_mode_g,:) = 1;%g(i+1/2,j+1/2)
            Xd_g(1:boundary_mode_g,:) = 0;%g(i+3/2,j+1/2)
            Xe_g(1:boundary_mode_g,:) = 0;%g(i+1/2,j+3/2)
            Xf_g(1:boundary_mode_g,:) = 0;%g(i-1/2,j-1/2)
            Xg_g(1:boundary_mode_g,:) = 0;%g(i+3/2,j+3/2)
            Xh_g(1:boundary_mode_g,:) = 0;%g(i-1/2,j+3/2)
            Xi_g(1:boundary_mode_g,:) = 0;%g(i+3/2,j-1/2)
        end
%
%Boundaries of the bounce domain for g
%
        Xa_g_t = Xa_g(:,Zmask_g{ir_dke});%Matrix reduction along the angular direction
        Xb_g_t = Xb_g(:,Zmask_g{ir_dke});
        Xc_g_t = Xc_g(:,Zmask_g{ir_dke});
        Xd_g_t = Xd_g(:,Zmask_g{ir_dke});
        Xe_g_t = Xe_g(:,Zmask_g{ir_dke});
        Xf_g_t = Xf_g(:,Zmask_g{ir_dke});
        Xg_g_t = Xg_g(:,Zmask_g{ir_dke});
        Xh_g_t = Xh_g(:,Zmask_g{ir_dke});
        Xi_g_t = Xi_g(:,Zmask_g{ir_dke});
%
        Xe_g_t(:,(nmhu - ns_g(ir_dke))/2) = 0;%g(pn,mhu = -mhut) = 0
        Xg_g_t(:,(nmhu - ns_g(ir_dke))/2) = 0;%g(pn,mhu = -mhut) = 0
        Xh_g_t(:,(nmhu - ns_g(ir_dke))/2) = 0;%g(pn,mhu = -mhut) = 0
%
        Xa_g_t(:,(nmhu - ns_g(ir_dke))/2 + 1) = 0;%g(pn,mhu = mhut) = 0
        Xf_g_t(:,(nmhu - ns_g(ir_dke))/2 + 1) = 0;%g(pn,mhu = mhut) = 0
        Xi_g_t(:,(nmhu - ns_g(ir_dke))/2 + 1) = 0;%g(pn,mhu = mhut) = 0
%
%Matrix calculation for ftp
%
        MXc_tp = reshape(Xc_tp',nmhu*npn,1);
        MXP_tp = sparse([1:nmhu*npn],[1:nmhu*npn],MXc_tp,nmhu*npn,nmhu*npn);
        MXa_tp = reshape(Xa_tp',nmhu*npn,1);
        MXP_tp = MXP_tp + sparse([1+1:nmhu*npn],[1:nmhu*npn-1],MXa_tp(1+1:length(MXa_tp)),nmhu*npn,nmhu*npn);
        MXe_tp = reshape(Xe_tp',nmhu*npn,1);
        MXP_tp = MXP_tp + sparse([1:nmhu*npn-1],[1+1:nmhu*npn],MXe_tp(1:length(MXe_tp)-1),nmhu*npn,nmhu*npn);       
        MXb_tp = reshape(Xb_tp',nmhu*npn,1);
        MXP_tp = MXP_tp + sparse([1+nmhu:nmhu*npn],[1:nmhu*npn-nmhu],MXb_tp(1+nmhu:length(MXb_tp)),nmhu*npn,nmhu*npn);            
        MXd_tp = reshape(Xd_tp',nmhu*npn,1);
        MXP_tp = MXP_tp + sparse([1:nmhu*npn-nmhu],[1+nmhu:nmhu*npn],MXd_tp(1:length(MXd_tp)-nmhu),nmhu*npn,nmhu*npn);            
        MXf_tp = reshape(Xf_tp',nmhu*npn,1);
        MXP_tp = MXP_tp + sparse([1+nmhu+1:nmhu*npn],[1:nmhu*npn-nmhu-1],MXf_tp(1+nmhu+1:length(MXf_tp)),nmhu*npn,nmhu*npn);      
        MXh_tp = reshape(Xh_tp',nmhu*npn,1);
        MXP_tp = MXP_tp + sparse([1+nmhu-1:nmhu*npn],[1:nmhu*npn-nmhu+1],MXh_tp(1+nmhu-1:length(MXh_tp)),nmhu*npn,nmhu*npn);      
        MXi_tp = reshape(Xi_tp',nmhu*npn,1);
        MXP_tp = MXP_tp + sparse([1:nmhu*npn-nmhu+1],[1+nmhu-1:nmhu*npn],MXi_tp(1:length(MXi_tp)-nmhu+1),nmhu*npn,nmhu*npn);      
        MXg_tp = reshape(Xg_tp',nmhu*npn,1);
        MXP_tp = MXP_tp + sparse([1:nmhu*npn-nmhu-1],[1+nmhu+1:nmhu*npn],MXg_tp(1:length(MXg_tp)-nmhu-1),nmhu*npn,nmhu*npn);                
%       
        sm_tp(ir_dke+1) = sm_tp(ir_dke) + blocksize_tp(ir_dke);
        [i0_tp,j0_tp,s0_tp] = find(MMXP_tp);        
        [m0_tp,n0_tp] = size(MMXP_tp);
        [i1_tp,j1_tp,s1_tp] = find(MXP_tp);
        [m1_tp,n1_tp] = size(MXP_tp);
        MMXP_tp = sparse(i0_tp,j0_tp,s0_tp,m0_tp+m1_tp,m0_tp+m1_tp) + sparse(m0_tp+i1_tp,m0_tp+j1_tp,s1_tp,m0_tp+m1_tp,m0_tp+m1_tp);
%
%Matrix calculation for g
%
        MXc_g_t = reshape(Xc_g_t',(nmhu - ns_g(ir_dke))*npn,1);
        MXP_g_t = sparse([1:(nmhu - ns_g(ir_dke))*npn],[1:(nmhu - ns_g(ir_dke))*npn],MXc_g_t,(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);
        MXa_g_t = reshape(Xa_g_t',(nmhu - ns_g(ir_dke))*npn,1);
        MXP_g_t = MXP_g_t + sparse([1+1:(nmhu - ns_g(ir_dke))*npn],[1:(nmhu - ns_g(ir_dke))*npn-1],MXa_g_t(1+1:length(MXa_g_t)),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);
        MXe_g_t = reshape(Xe_g_t',(nmhu - ns_g(ir_dke))*npn,1);
        MXP_g_t = MXP_g_t + sparse([1:(nmhu - ns_g(ir_dke))*npn-1],[1+1:(nmhu - ns_g(ir_dke))*npn],MXe_g_t(1:length(MXe_g_t)-1),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);       
        MXb_g_t = reshape(Xb_g_t',(nmhu - ns_g(ir_dke))*npn,1);
        MXP_g_t = MXP_g_t + sparse([1+(nmhu - ns_g(ir_dke)):(nmhu - ns_g(ir_dke))*npn],[1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))],MXb_g_t(1+(nmhu - ns_g(ir_dke)):length(MXb_g_t)),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);           
        MXd_g_t = reshape(Xd_g_t',(nmhu - ns_g(ir_dke))*npn,1);
        MXP_g_t = MXP_g_t + sparse([1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))],[1+(nmhu - ns_g(ir_dke)):(nmhu - ns_g(ir_dke))*npn],MXd_g_t(1:length(MXd_g_t)-(nmhu - ns_g(ir_dke))),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);           
        MXf_g_t = reshape(Xf_g_t',(nmhu - ns_g(ir_dke))*npn,1);
        MXP_g_t = MXP_g_t + sparse([1+(nmhu - ns_g(ir_dke))+1:(nmhu - ns_g(ir_dke))*npn],[1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))-1],MXf_g_t(1+(nmhu - ns_g(ir_dke))+1:length(MXf_g_t)),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);     
        MXh_g_t = reshape(Xh_g_t',(nmhu - ns_g(ir_dke))*npn,1);
        MXP_g_t = MXP_g_t + sparse([1+(nmhu - ns_g(ir_dke))-1:(nmhu - ns_g(ir_dke))*npn],[1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))+1],MXh_g_t(1+(nmhu - ns_g(ir_dke))-1:length(MXh_g_t)),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);     
        MXi_g_t = reshape(Xi_g_t',(nmhu - ns_g(ir_dke))*npn,1);
        MXP_g_t = MXP_g_t + sparse([1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))+1],[1+(nmhu - ns_g(ir_dke))-1:(nmhu - ns_g(ir_dke))*npn],MXi_g_t(1:length(MXi_g_t)-(nmhu - ns_g(ir_dke))+1),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);     
        MXg_g_t = reshape(Xg_g_t',(nmhu - ns_g(ir_dke))*npn,1);
        MXP_g_t = MXP_g_t + sparse([1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))-1],[1+(nmhu - ns_g(ir_dke))+1:(nmhu - ns_g(ir_dke))*npn],MXg_g_t(1:length(MXg_g_t)-(nmhu - ns_g(ir_dke))-1),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);     
%
        sm_g(ir_dke+1) = sm_g(ir_dke) + blocksize_g_t(ir_dke);
        [i0_g,j0_g,s0_g] = find(MMXP_g_t);      
        [m0_g,n0_g] = size(MMXP_g_t);
        [i1_g,j1_g,s1_g] = find(MXP_g_t);
        [m1_g,n1_g] = size(MXP_g_t);
        MMXP_g_t = sparse(i0_g,j0_g,s0_g,m0_g+m1_g,m0_g+m1_g) + sparse(m0_g+i1_g,m0_g+j1_g,s1_g,m0_g+m1_g,m0_g+m1_g);
%
        etime_dke = etime_dke + etime(clock,time0);
       time0 = clock;
    end
      
      
else
%
% for collisions
%
    XXDpp_c_tp_imj = zeros(npn,nmhu,nr);
    XXDpm_c_tp_imj = zeros(npn,nmhu,nr);
    XXFp_c_tp_imj = zeros(npn,nmhu,nr);
    XXDpp_c_tp_ipj = zeros(npn,nmhu,nr);
    XXDpm_c_tp_ipj = zeros(npn,nmhu,nr);
    XXFp_c_tp_ipj = zeros(npn,nmhu,nr);
%
    XXDmm_c_tp_ijm = zeros(npn,nmhu,nr);
    XXDmp_c_tp_ijm = zeros(npn,nmhu,nr);
    XXFm_c_tp_ijm = zeros(npn,nmhu,nr);
    XXDmm_c_tp_ijp = zeros(npn,nmhu,nr);
    XXDmp_c_tp_ijp = zeros(npn,nmhu,nr);
    XXFm_c_tp_ijp = zeros(npn,nmhu,nr);
%
% For Ohmic electric field
%
    XXDpp_e_tp_imj = zeros(npn,nmhu,nr);
    XXDpm_e_tp_imj = zeros(npn,nmhu,nr);
    XXFp_e_tp_imj = zeros(npn,nmhu,nr);
    XXDpp_e_tp_ipj = zeros(npn,nmhu,nr);
    XXDpm_e_tp_ipj = zeros(npn,nmhu,nr);
    XXFp_e_tp_ipj = zeros(npn,nmhu,nr);
%
    XXDmm_e_tp_ijm = zeros(npn,nmhu,nr);
    XXDmp_e_tp_ijm = zeros(npn,nmhu,nr);
    XXFm_e_tp_ijm = zeros(npn,nmhu,nr);
    XXDmm_e_tp_ijp = zeros(npn,nmhu,nr);
    XXDmp_e_tp_ijp = zeros(npn,nmhu,nr);
    XXFm_e_tp_ijp = zeros(npn,nmhu,nr);
%
end
%
%Second order radial gradient correction for ftp (radial derivative of the Chang and Cooper momentum terms) 
%
if dke_mode == 1,
%    XXH_tp_mm = permute(XXH_tp_mm,[2,1,3]);
%    XXH_tp_m = permute(XXH_tp_m,[2,1,3]);
%    XXH_tp_mp = permute(XXH_tp_mp,[2,1,3]);
%    XXH_tp_pm = permute(XXH_tp_pm,[2,1,3]);
%    XXH_tp_p = permute(XXH_tp_p,[2,1,3]);
%    XXH_tp_pp = permute(XXH_tp_pp,[2,1,3]);
%   
%    MMH_tp_mm = reshape(XXH_tp_mm,npn*nmhu*nr,1,1);
%    MMH_tp_m = reshape(XXH_tp_m,npn*nmhu*nr,1,1);
%    MMH_tp_mp = reshape(XXH_tp_mp,npn*nmhu*nr,1,1); 
%    MMH_tp_pm = reshape(XXH_tp_pm,npn*nmhu*nr,1,1);
%    MMH_tp_p = reshape(XXH_tp_p,npn*nmhu*nr,1,1);
%    MMH_tp_pp = reshape(XXH_tp_pp,npn*nmhu*nr,1,1);
%
%    MMH_tp = MMH_tp + sparse([1+(nmhu-1)*npn:nMMH_tp],[1:nMMH_tp-(nmhu-1)*npn],MMH_tp_mm(1+npn*(nmhu-1):nMMH_tp),nMMH_tp,nMMH_tp);  
%    MMH_tp = MMH_tp + sparse([1+nmhu*npn:nMMH_tp],[1:nMMH_tp-nmhu*npn],MMH_tp_m(1+npn*nmhu:nMMH_tp),nMMH_tp,nMMH_tp);   
%    MMH_tp = MMH_tp + sparse([1+(nmhu+1)*npn:nMMH_tp],[1:nMMH_tp-(nmhu+1)*npn],MMH_tp_mp(1+npn*(nmhu+1):nMMH_tp),nMMH_tp,nMMH_tp);
%    MMH_tp = MMH_tp + sparse([1:nMMH_tp-(nmhu-1)*npn],[1+(nmhu-1)*npn:nMMH_tp],MMH_tp_pm(1:nMMH_tp-npn*(nmhu-1)),nMMH_tp,nMMH_tp);      
%    MMH_tp = MMH_tp + sparse([1:nMMH_tp-nmhu*npn],[1+nmhu*npn:nMMH_tp],MMH_tp_p(1:nMMH_tp-npn*nmhu),nMMH_tp,nMMH_tp);
%    MMH_tp = MMH_tp + sparse([1:nMMH_tp-(nmhu+1)*npn],[1+(nmhu+1)*npn:nMMH_tp],MMH_tp_pp(1:nMMH_tp-npn*(nmhu+1)),nMMH_tp,nMMH_tp);
%
%    if display_mode >= 1,info_dke_yp(2,['Second order radial gradient correction for ftp matrix calculations done in ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end
end
%
if store_mode == 1,
%    save([fullfile(temppath,'MXP_mat'],'Zmask_f0_t','Zmask_g','-append');
end
%


