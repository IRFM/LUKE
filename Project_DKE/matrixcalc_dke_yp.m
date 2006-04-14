function [Zdelta,MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,Zpn2_t,sm_f,sm_g,sm_tp] = matrixcalc_dke_yp(dkeparam,display,gridDKE,equilDKE,Zbouncecoef,mksa,...
                                                                       Zmripple,...
                                                                       ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXILor,...
                                                                       ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,...
                                                                       ZYXXD_rf,ZYXXF_rf,ZYXXD_rf_tp,ZYXXF_rf_tp)
%
%   Calculate the super matrix for the 3D electron relativistic drift kinetic solver.
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC) (joan.decker@cea.fr)
%
time0 = clock;
etime_fp = 0;
%
boundary_mode_f = dkeparam.boundary_mode_f;
dke_mode = dkeparam.dke_mode;
bounce_mode = dkeparam.bounce_mode;
store_mode = dkeparam.store_mode;
dtn = dkeparam.dtn;
%
display_mode = display.display_mode;
%
nr = gridDKE.nr;
npn = gridDKE.npn;
nmhu = gridDKE.nmhu;
nr_dke = gridDKE.nr_dke;
mhu = gridDKE.mhu;
Xdmhumm = gridDKE.Xdmhumm;
Xdmhum = gridDKE.Xdmhum;
Xdmhu = gridDKE.Xdmhu;
Xdmhup = gridDKE.Xdmhup;
Xdmhupp = gridDKE.Xdmhupp;
Xdpnmm = gridDKE.Xdpnmm;
Xdpnm = gridDKE.Xdpnm;
Xdpn = gridDKE.Xdpn;
Xdpnp = gridDKE.Xdpnp;
Xdpnpp = gridDKE.Xdpnpp;
Xmhumm = gridDKE.Xmhumm;
Xmhum = gridDKE.Xmhum;
Xmhu = gridDKE.Xmhu;
Xmhup = gridDKE.Xmhup;
Xmhupp = gridDKE.Xmhupp;
X1mmhu2m = gridDKE.X1mmhu2m;
X1mmhu2 = gridDKE.X1mmhu2;
X1mmhu2p = gridDKE.X1mmhu2p;
Xpnmm = gridDKE.Xpnmm;
Xpnm = gridDKE.Xpnm;
Xpn = gridDKE.Xpn;
Xpnp = gridDKE.Xpnp;
Xpnpp = gridDKE.Xpnpp;
Xpn2m = gridDKE.Xpn2m;
Xpn2 = gridDKE.Xpn2;
Xpn2p = gridDKE.Xpn2p;
xpsin = gridDKE.xpsin;
rdke = gridDKE.rdke;
%
djmhut = Zbouncecoef.djmhut;
Zmask_f0_P = Zbouncecoef.Zmask_f0_P;
Zbouncecoef.Zmask_f0_P = Zmask_f0_P;
Zmask_f0_Tm = Zbouncecoef.Zmask_f0_Tm;
Zmask_f0_Tp = Zbouncecoef.Zmask_f0_Tp;
jmhut_min = Zbouncecoef.jmhut_min;
jmhut_max = Zbouncecoef.jmhut_max;
Zmask_f0_t = Zbouncecoef.Zmask_f0_t;
Zmask_f0_t_P = Zbouncecoef.Zmask_f0_t_P;
Zmask_f0_t_Tp = Zbouncecoef.Zmask_f0_t_Tp;
ns_f = Zbouncecoef.ns_f;     
XXRlambda_m = Zbouncecoef.XXRlambda_m;
XXRlambda_p = Zbouncecoef.XXRlambda_p;
xqtilde = Zbouncecoef.xqtilde;
sm_f = Zbouncecoef.sm_f;
sm_T_f = Zbouncecoef.sm_T_f;
blocksize_f_t = Zbouncecoef.blocksize_f_t;
blocksize_T_f_t = Zbouncecoef.blocksize_T_f_t;
%if dke_mode == 1,
   Zmask_g = Zbouncecoef.Zmask_g;
   ns_g = Zbouncecoef.ns_g;
   xftp_norm = mksa.xftp_norm_ref;
   boundary_mode_g = dkeparam.boundary_mode_g;
   sm_tp = Zbouncecoef.sm_tp;
   sm_g = Zbouncecoef.sm_g;
   blocksize_tp = Zbouncecoef.blocksize_tp;    
   blocksize_g_t = Zbouncecoef.blocksize_g_t;
%
%end
%
xB0 = equilDKE.xB0;
%
MMXP_f_t = [];
MMXT_f_t = [];
MMXP_tp = [];
MMXP_g_t = [];
MMH_tp = [];
%
spparms('default');%Set parameters for sparse matrix ordering algorithms and direct linear equation solver MatLab build-in functions only
spparms('supernd',4);%Set parameters for sparse matrix ordering algorithms and direct linear equation solver MatLab build-in functions only
spparms('rreduce',4);%Set parameters for sparse matrix ordering algorithms and direct linear equation solver MatLab build-in functions only
%
%   
% Fokker-Planck (zero order) matrix calculation
% 
for ir = 1:nr,
%
    XDpp_ippj = ZXXD_c.pp_ippj(:,:,ir) + ZXXD_e.pp_ippj(:,:,ir) + ZYXXD_rf.pp_ippj(:,:,ir);
    XDpp_ipj = ZXXD_c.pp_ipj(:,:,ir) + ZXXD_e.pp_ipj(:,:,ir) + ZYXXD_rf.pp_ipj(:,:,ir);
    XDpp_ij = ZXXD_c.pp_ij(:,:,ir) + ZXXD_e.pp_ij(:,:,ir) + ZYXXD_rf.pp_ij(:,:,ir);
    XDpp_imj = ZXXD_c.pp_imj(:,:,ir) + ZXXD_e.pp_imj(:,:,ir) + ZYXXD_rf.pp_imj(:,:,ir);
    XDpp_immj = ZXXD_c.pp_immj(:,:,ir) + ZXXD_e.pp_immj(:,:,ir) + ZYXXD_rf.pp_immj(:,:,ir);
%
    XDpm_ipj = ZXXD_c.pm_ipj(:,:,ir) + ZXXD_e.pm_ipj(:,:,ir) + ZYXXD_rf.pm_ipj(:,:,ir);
    XDpm_ij = ZXXD_c.pm_ij(:,:,ir) + ZXXD_e.pm_ij(:,:,ir) + ZYXXD_rf.pm_ij(:,:,ir);
    XDpm_imj = ZXXD_c.pm_imj(:,:,ir) + ZXXD_e.pm_imj(:,:,ir) + ZYXXD_rf.pm_imj(:,:,ir);
%
    XDmp_ijp = ZXXD_c.mp_ijp(:,:,ir) + ZXXD_e.mp_ijp(:,:,ir) + ZYXXD_rf.mp_ijp(:,:,ir);
    XDmp_ij = ZXXD_c.mp_ij(:,:,ir) + ZXXD_e.mp_ij(:,:,ir) + ZYXXD_rf.mp_ij(:,:,ir);
    XDmp_ijm = ZXXD_c.mp_ijm(:,:,ir) + ZXXD_e.mp_ijm(:,:,ir) + ZYXXD_rf.mp_ijm(:,:,ir);
%
    XDmm_ijp = ZXXD_c.mm_ijp(:,:,ir) + ZXXD_e.mm_ijp(:,:,ir) + ZYXXD_rf.mm_ijp(:,:,ir);
    XDmm_ijm = ZXXD_c.mm_ijm(:,:,ir) + ZXXD_e.mm_ijm(:,:,ir) + ZYXXD_rf.mm_ijm(:,:,ir);
%
    XFp_ippj = ZXXF_c.p_ippj(:,:,ir) + ZXXF_e.p_ippj(:,:,ir) + ZYXXF_rf.p_ippj(:,:,ir);
    XFp_ipj = ZXXF_c.p_ipj(:,:,ir) + ZXXF_e.p_ipj(:,:,ir) + ZYXXF_rf.p_ipj(:,:,ir);
    XFp_ij = ZXXF_c.p_ij(:,:,ir) + ZXXF_e.p_ij(:,:,ir) + ZYXXF_rf.p_ij(:,:,ir);
    XFp_imj = ZXXF_c.p_imj(:,:,ir) + ZXXF_e.p_imj(:,:,ir) + ZYXXF_rf.p_imj(:,:,ir);
    XFp_immj = ZXXF_c.p_immj(:,:,ir) + ZXXF_e.p_immj(:,:,ir) + ZYXXF_rf.p_immj(:,:,ir);
%
    XFm_ijp = ZXXF_c.m_ijp(:,:,ir) + ZXXF_e.m_ijp(:,:,ir) + ZYXXF_rf.m_ijp(:,:,ir);
    XFm_ijm = ZXXF_c.m_ijm(:,:,ir) + ZXXF_e.m_ijm(:,:,ir) + ZYXXF_rf.m_ijm(:,:,ir);
%
%Momentum weights calculations (for f0 and ftp also)
%
    [Xdeltap_imj,Xdeltap_ipj,...
         Xdeltam_ijm,Xdeltam_ijp,...
         Xdeltap_imjmm,Xdeltap_imjpp,Xdeltap_ipjmm,Xdeltap_ipjpp,...
         Xdeltam_immjm,Xdeltam_ippjm,Xdeltam_immjp,Xdeltam_ippjp] = ...
         fppgridweights_dke_yp(Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
         Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
         XDpp_ippj,XDpp_ipj,XDpp_ij,XDpp_imj,XDpp_immj,...
         XFp_ippj,XFp_ipj,XFp_ij,XFp_imj,XFp_immj);
%
    XXdeltap_imj(:,:,ir) = Xdeltap_imj; 
    XXdeltap_ipj(:,:,ir) = Xdeltap_ipj;
    XXdeltam_ijp(:,:,ir) = Xdeltam_ijp;
    XXdeltam_ijm(:,:,ir) = Xdeltam_ijm;   
    XXdeltap_imjmm(:,:,ir) = Xdeltap_imjmm;
    XXdeltap_imjpp(:,:,ir) = Xdeltap_imjpp;
    XXdeltap_ipjmm(:,:,ir) = Xdeltap_ipjmm;
    XXdeltap_ipjpp(:,:,ir) = Xdeltap_ipjpp;
    XXdeltam_immjm(:,:,ir) = Xdeltam_immjm;
    XXdeltam_ippjm(:,:,ir) = Xdeltam_ippjm;
    XXdeltam_immjp(:,:,ir) = Xdeltam_immjp;
    XXdeltam_ippjp(:,:,ir) = Xdeltam_ippjp;
%
%Momentum dynamics matrix coefficients calculations
%   
    [XXa(:,:,ir),XXb(:,:,ir),XXc(:,:,ir),XXd(:,:,ir),XXe(:,:,ir),XXf(:,:,ir),XXg(:,:,ir),XXh(:,:,ir),XXi(:,:,ir)] = ...
    fpengine_dke_yp(0,...
    XXdeltap_imj(:,:,ir),XXdeltap_ipj(:,:,ir),XXdeltam_ijm(:,:,ir),XXdeltam_ijp(:,:,ir),...    	       
    XXdeltap_imjmm(:,:,ir),XXdeltap_imjpp(:,:,ir),XXdeltap_ipjmm(:,:,ir),XXdeltap_ipjpp(:,:,ir),...
    XXdeltam_immjm(:,:,ir),XXdeltam_ippjm(:,:,ir),XXdeltam_immjp(:,:,ir),XXdeltam_ippjp(:,:,ir),...
    XXRlambda_m(:,:,ir),XXRlambda_p(:,:,ir),...
    Xpnmm,Xpnm,Xpn,Xpnp,Xpnpp,Xpn2m,Xpn2p,Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
    Xmhumm,Xmhum,Xmhu,Xmhup,Xmhupp,X1mmhu2,X1mmhu2m,X1mmhu2p,Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
    XDpp_ippj,XDpp_ipj,XDpp_ij,XDpp_imj,XDpp_immj,...
    XDpm_ipj,XDpm_ij,XDpm_imj,...
    XDmp_ijp,XDmp_ij,XDmp_ijm,...
    XDmm_ijp,XDmm_ijm,...
    XFp_ippj,XFp_ipj,XFp_ij,XFp_imj,XFp_immj,...
    XFm_ijp,XFm_ijm);
% 
%Sink and source coefficients like magnetic ripple losses,described by a Krook term
%
    XXc(:,:,ir) = XXc(:,:,ir) +  Zmripple.XXlossripple(:,:,ir).*Xpn2;
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
            error(['WARNING: Not enough grid point in the bounce region for accurate bounce-averaged calculations at psin = ',num2str(xpsin(ir)),' !'])
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
    MXP_f_t = (xqtilde(ir)/xB0(ir))*MXP_f_t;%Partial Jacobian multiplication to avoid numerical singularities at p = 0  
%    
    sm_f(ir+1) = sm_f(ir) + blocksize_f_t(ir);
    [i0_f,j0_f,s0_f] = find(MMXP_f_t);      
    [m0_f,n0_f] = size(MMXP_f_t);
    [i1_f,j1_f,s1_f] = find(MXP_f_t);
    [m1_f,n1_f] = size(MXP_f_t);
    MMXP_f_t = sparse(i0_f,j0_f,s0_f,m0_f+m1_f,m0_f+m1_f) + sparse(m0_f+i1_f,m0_f+j1_f,s1_f,m0_f+m1_f,m0_f+m1_f);
%
%Time diagonal matrix calculation
%   
    MXT = reshape(Zpn2_t{ir}',(nmhu-ns_f(ir))*npn,1)/dtn;%Partial momentum Jacobian 
    MXT_f_t = (xqtilde(ir)/xB0(ir))*sparse([1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn],MXT,(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);%Resizing for 3D calculations + multiplication by the remaining Jacobian
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
Zdelta.XXdeltap_imj = XXdeltap_imj; 
Zdelta.XXdeltap_ipj = XXdeltap_ipj;
Zdelta.XXdeltam_ijp = XXdeltam_ijp;
Zdelta.XXdeltam_ijm = XXdeltam_ijm;   
Zdelta.XXdeltap_imjmm = XXdeltap_imjmm;
Zdelta.XXdeltap_imjpp = XXdeltap_imjpp;
Zdelta.XXdeltap_ipjmm = XXdeltap_ipjmm;
Zdelta.XXdeltap_ipjpp = XXdeltap_ipjpp;
Zdelta.XXdeltam_immjm = XXdeltam_immjm;
Zdelta.XXdeltam_ippjm = XXdeltam_ippjm;
Zdelta.XXdeltam_immjp = XXdeltam_immjp;
Zdelta.XXdeltam_ippjp = XXdeltam_ippjp;
%
if display_mode >= 1,info_dke_yp(2,['Zero order momentum space matrix calculations done in ',num2str(etime_fp),' (s)']);end
%
% DKE (first order) matrix calculation
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
        XDpp_tp_ippj = ZXXD_c_tp.pp_ippj(:,:,ir_dke) + ZXXD_e_tp.pp_ippj(:,:,ir_dke) + ZYXXD_rf_tp.pp_ippj(:,:,ir_dke);
        XDpp_tp_ipj = ZXXD_c_tp.pp_ipj(:,:,ir_dke) + ZXXD_e_tp.pp_ipj(:,:,ir_dke) + ZYXXD_rf_tp.pp_ipj(:,:,ir_dke);
        XDpp_tp_ij = ZXXD_c_tp.pp_ij(:,:,ir_dke) + ZXXD_e_tp.pp_ij(:,:,ir_dke) + ZYXXD_rf_tp.pp_ij(:,:,ir_dke);
        XDpp_tp_imj = ZXXD_c_tp.pp_imj(:,:,ir_dke) + ZXXD_e_tp.pp_imj(:,:,ir_dke) + ZYXXD_rf_tp.pp_imj(:,:,ir_dke);
        XDpp_tp_immj = ZXXD_c_tp.pp_immj(:,:,ir_dke) + ZXXD_e_tp.pp_immj(:,:,ir_dke) + ZYXXD_rf_tp.pp_immj(:,:,ir_dke);
%
        XDpm_tp_ipj = ZXXD_c_tp.pm_ipj(:,:,ir_dke) + ZXXD_e_tp.pm_ipj(:,:,ir_dke) + ZYXXD_rf_tp.pm_ipj(:,:,ir_dke);
        XDpm_tp_ij = ZXXD_c_tp.pm_ij(:,:,ir_dke) + ZXXD_e_tp.pm_ij(:,:,ir_dke) + ZYXXD_rf_tp.pm_ij(:,:,ir_dke);
        XDpm_tp_imj = ZXXD_c_tp.pm_imj(:,:,ir_dke) + ZXXD_e_tp.pm_imj(:,:,ir_dke) + ZYXXD_rf_tp.pm_imj(:,:,ir_dke);
%
        XDmp_tp_ijp = ZXXD_c_tp.mp_ijp(:,:,ir_dke) + ZXXD_e_tp.mp_ijp(:,:,ir_dke) + ZYXXD_rf_tp.mp_ijp(:,:,ir_dke);
        XDmp_tp_ij = ZXXD_c_tp.mp_ij(:,:,ir_dke) + ZXXD_e_tp.mp_ij(:,:,ir_dke) + ZYXXD_rf_tp.mp_ij(:,:,ir_dke);
        XDmp_tp_ijm = ZXXD_c_tp.mp_ijm(:,:,ir_dke) + ZXXD_e_tp.mp_ijm(:,:,ir_dke) + ZYXXD_rf_tp.mp_ijm(:,:,ir_dke);
%
        XDmm_tp_ijp = ZXXD_c_tp.mm_ijp(:,:,ir_dke) + ZXXD_e_tp.mm_ijp(:,:,ir_dke) + ZYXXD_rf_tp.mm_ijp(:,:,ir_dke);
        XDmm_tp_ijm = ZXXD_c_tp.mm_ijm(:,:,ir_dke) + ZXXD_e_tp.mm_ijm(:,:,ir_dke) + ZYXXD_rf_tp.mm_ijm(:,:,ir_dke);
%
        XFp_tp_ippj = ZXXF_c_tp.p_ippj(:,:,ir_dke) + ZXXF_e_tp.p_ippj(:,:,ir_dke) + ZYXXF_rf_tp.p_ippj(:,:,ir_dke);
        XFp_tp_ipj = ZXXF_c_tp.p_ipj(:,:,ir_dke) + ZXXF_e_tp.p_ipj(:,:,ir_dke) + ZYXXF_rf_tp.p_ipj(:,:,ir_dke);
        XFp_tp_ij = ZXXF_c_tp.p_ij(:,:,ir_dke) + ZXXF_e_tp.p_ij(:,:,ir_dke) + ZYXXF_rf_tp.p_ij(:,:,ir_dke);
        XFp_tp_imj = ZXXF_c_tp.p_imj(:,:,ir_dke) + ZXXF_e_tp.p_imj(:,:,ir_dke) + ZYXXF_rf_tp.p_imj(:,:,ir_dke);
        XFp_tp_immj = ZXXF_c_tp.p_immj(:,:,ir_dke) + ZXXF_e_tp.p_immj(:,:,ir_dke) + ZYXXF_rf_tp.p_immj(:,:,ir_dke);
%
        XFm_tp_ijp = ZXXF_c_tp.m_ijp(:,:,ir_dke) + ZXXF_e_tp.m_ijp(:,:,ir_dke) + ZYXXF_rf_tp.m_ijp(:,:,ir_dke);
        XFm_tp_ijm = ZXXF_c_tp.m_ijm(:,:,ir_dke) + ZXXF_e_tp.m_ijm(:,:,ir_dke) + ZYXXF_rf_tp.m_ijm(:,:,ir_dke);
%
        [Xa_tp,Xb_tp,Xc_tp,Xd_tp,Xe_tp,Xf_tp,Xg_tp,Xh_tp,Xi_tp] = ...
            fpengine_dke_yp(1,...
            XXdeltap_imj(:,:,jr2),XXdeltap_ipj(:,:,jr2),XXdeltam_ijm(:,:,jr2),XXdeltam_ijp(:,:,jr2),...
            XXdeltap_imjmm(:,:,jr2),XXdeltap_imjpp(:,:,jr2),XXdeltap_ipjmm(:,:,jr2),XXdeltap_ipjpp(:,:,jr2),...
            XXdeltam_immjm(:,:,jr2),XXdeltam_ippjm(:,:,jr2),XXdeltam_immjp(:,:,jr2),XXdeltam_ippjp(:,:,jr2),...
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
        XXH_tp_mm(:,:,jr1) = (xftp_norm(jr2)*dpsip/dpsi/dpsim)*(XXdeltap_imj(:,:,jr2) - XXdeltap_imj(:,:,jr1)).*XFp_tp_imj.*Xmhu.*Xpn2m.*Xpnm./Xdpn;
        XXH_tp_mp(:,:,jr1) = (xftp_norm(jr2)*dpsip/dpsi/dpsim)*(XXdeltap_ipj(:,:,jr2) - XXdeltap_ipj(:,:,jr1)).*XFp_tp_ipj.*Xmhu.*Xpn2p.*Xpnp./Xdpn;
        XXH_tp_m(:,:,jr1) = -XXH_tp_mm(:,:,jr1) - XXH_tp_mp(:,:,jr1);
%
        XXH_tp_pm(:,:,jr3) = -(xftp_norm(jr2)*dpsim/dpsi/dpsip)*(XXdeltap_imj(:,:,jr2) - XXdeltap_imj(:,:,jr3)).*XFp_tp_imj.*Xmhu.*Xpn2m.*Xpnm./Xdpn;
        XXH_tp_pp(:,:,jr3) = -(xftp_norm(jr2)*dpsim/dpsi/dpsip)*(XXdeltap_ipj(:,:,jr2) - XXdeltap_ipj(:,:,jr3)).*XFp_tp_ipj.*Xmhu.*Xpn2p.*Xpnp./Xdpn;       
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