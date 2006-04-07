function [ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi] = ...
    efield_dke_jd(xepsi_fsav,...
        Xmhu,X1mmhu2p,X1mmhu2m,...
        xqbar,xqtilde,xB0,xBT0,xR0,Rp,...
        XXlambda_b_p1m3p4,XXRlambda_b_p1m1p2,XXRlambda_b_p1m1p2_p,XXRlambda_b_p1m1p2_m,...
        XXRlambda_b_p2m2p2,XXRlambda_b_p2m2p2_p,XXRlambda_b_p2m2p2_m,...
        bounce_mode,dke_mode,display_mode,rdke,save_id,temppath);
%
etime_efield = 0;
time0 = clock;
%
%load([fullfile(temppath,'temp_DKE_'),save_id,'.mat'],'xepsi');
%
if exist('xepsi') == 1, %The bounce averaging coefficients were calculated before.
  %
%  load([fullfile(temppath,'temp_DKE_'),save_id,'.mat'],'ZXXD_e','ZXXF_e','ZXXD_e_tp','ZXXF_e_tp')
  %
  if display_mode >= 1,info_dke_yp(2,['Electric field flux coefficients retrieved.']);end	
  %
else
%
  [npn,nmhu] = size(Xmhu);%Size of the momentum grids for the distribution function (half grid)
  nr = length(xepsi_fsav);%Size of the radial grid for the distribution function (half grid)
  nr_dke = length(rdke);%Size of the effective radial grid for the drift kinetic equation (nr_dke = nr for FPE equation only)
%
% Output files initialization
%
  ZXXD_e.pp_ippj = zeros(npn,nmhu,nr);
  ZXXD_e.pp_ipj = zeros(npn,nmhu,nr);
  ZXXD_e.pp_ij = zeros(npn,nmhu,nr);
  ZXXD_e.pp_imj = zeros(npn,nmhu,nr);
  ZXXD_e.pp_immj = zeros(npn,nmhu,nr);
  ZXXD_e.pm_ipj = zeros(npn,nmhu,nr);
  ZXXD_e.pm_ij = zeros(npn,nmhu,nr);
  ZXXD_e.pm_imj = zeros(npn,nmhu,nr);
  ZXXD_e.mp_ijp = zeros(npn,nmhu,nr);
  ZXXD_e.mp_ij = zeros(npn,nmhu,nr);
  ZXXD_e.mp_ijm = zeros(npn,nmhu,nr);
  ZXXD_e.mm_ijp = zeros(npn,nmhu,nr);
  ZXXD_e.mm_ijm = zeros(npn,nmhu,nr);
%
  ZXXF_e.p_ippj = zeros(npn,nmhu,nr);
  ZXXF_e.p_ipj = zeros(npn,nmhu,nr);
  ZXXF_e.p_ij = zeros(npn,nmhu,nr);
  ZXXF_e.p_imj = zeros(npn,nmhu,nr);
  ZXXF_e.p_immj = zeros(npn,nmhu,nr);
  ZXXF_e.m_ijp = zeros(npn,nmhu,nr);
  ZXXF_e.m_ijm = zeros(npn,nmhu,nr);
%
  if dke_mode == 1
%
    ZXXD_e_tp.pp_ippj = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.pp_ipj = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.pp_ij = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.pp_imj = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.pp_immj = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.pm_ipj = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.pm_ij = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.pm_imj = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.mp_ijp = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.mp_ij = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.mp_ijm = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.mm_ijp = zeros(npn,nmhu,nr_dke);
    ZXXD_e_tp.mm_ijm = zeros(npn,nmhu,nr_dke);
%
	ZXXF_e_tp.p_ippj = zeros(npn,nmhu,nr_dke);
	ZXXF_e_tp.p_ipj = zeros(npn,nmhu,nr_dke);
	ZXXF_e_tp.p_ij = zeros(npn,nmhu,nr_dke);
	ZXXF_e_tp.p_imj = zeros(npn,nmhu,nr_dke);
	ZXXF_e_tp.p_immj = zeros(npn,nmhu,nr_dke);
	ZXXF_e_tp.m_ijp = zeros(npn,nmhu,nr_dke);
	ZXXF_e_tp.m_ijm = zeros(npn,nmhu,nr_dke);
%    
  else
%    
	ZXXD_e_tp = NaN;
	ZXXF_e_tp = NaN;
%
  end

  for ir = 1:nr,
    if bounce_mode == 0,
        xepsi(ir) = xepsi_fsav(ir);
    elseif bounce_mode == 1,
        xepsi(ir) = xepsi_fsav(ir)*(xqbar(ir)/xqtilde(ir))*(xB0(ir)/xBT0(ir))*(xR0(ir)/Rp)/XXlambda_b_p1m3p4(1,1,ir);%Value at Bmin for FP or DKE calculations
    end
    if xepsi(ir) > 0.05, 
%        info_dke_yp(2,'WARNING: Ohmic electric field is likely too large. See the documentation');%To be consistent with the assumption of the linearized Fokker-Planck equation
    end 
%   
% Electric field flux coefficients calculations for f0 and g
%   
    ZXXF_e.p_ippj(:,:,ir) = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir);
    ZXXF_e.p_ipj(:,:,ir) = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir);
    ZXXF_e.p_ij(:,:,ir) = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir); 
    ZXXF_e.p_imj(:,:,ir) = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir);
    ZXXF_e.p_immj(:,:,ir) = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir);   
%
    ZXXF_e.m_ijp(:,:,ir) = -sqrt(X1mmhu2p).*XXRlambda_b_p1m1p2_p(:,:,ir)*xepsi(ir);
    ZXXF_e.m_ijm(:,:,ir) = -sqrt(X1mmhu2m).*XXRlambda_b_p1m1p2_m(:,:,ir)*xepsi(ir);    
%
% Electric field flux coefficients calculations for ftp
%   
    if dke_mode == 1
%
        ir_dke = find(ir == rdke);
        if isempty(ir_dke)
            continue
        end
%
        ZXXF_e_tp.p_ippj(:,:,ir_dke) = +Xmhu.*XXRlambda_b_p2m2p2(:,:,ir)*xepsi(ir);
        ZXXF_e_tp.p_ipj(:,:,ir_dke) = +Xmhu.*XXRlambda_b_p2m2p2(:,:,ir)*xepsi(ir);
        ZXXF_e_tp.p_ij(:,:,ir_dke) = +Xmhu.*XXRlambda_b_p2m2p2(:,:,ir)*xepsi(ir);    
        ZXXF_e_tp.p_imj(:,:,ir_dke) = +Xmhu.*XXRlambda_b_p2m2p2(:,:,ir)*xepsi(ir);
        ZXXF_e_tp.p_immj(:,:,ir_dke) = +Xmhu.*XXRlambda_b_p2m2p2(:,:,ir)*xepsi(ir);
%
        ZXXF_e_tp.m_ijp(:,:,ir_dke) = -sqrt(X1mmhu2p).*XXRlambda_b_p2m2p2_p(:,:,ir)*xepsi(ir);
        ZXXF_e_tp.m_ijm(:,:,ir_dke) = -sqrt(X1mmhu2m).*XXRlambda_b_p2m2p2_m(:,:,ir)*xepsi(ir);
    end
%
  end
%  save([fullfile(temppath,'temp_DKE_'),save_id,'.mat'],'ZXXD_e','ZXXF_e','ZXXD_e_tp','ZXXF_e_tp','xepsi','-append');
  %
  etime_efield = etime_efield + etime(clock,time0);
  if display_mode >= 1,info_dke_yp(2,['Electric field flux coefficients calculations done in ',num2str(etime_efield),' (s)']);end	
  %
%
end