function [ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity] = efield_dke_jd(path,dkeparam,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef,ohm,ZXXF_c)
%
display_mode = display.display_mode;
%
dke_mode = dkeparam.dke_mode;
bounce_mode = dkeparam.bounce_mode;
dke_mode = dkeparam.dke_mode;
temppath = path.temppath;
%
etime_efield = 0;
time0 = clock;
%
%load([fullfile(temppath,'temp_DKE.mat'],'xepsi');
%
if exist('xepsi') == 1, %The bounce averaging coefficients were calculated before.
  %
%  load([fullfile(temppath,'temp_DKE.mat'],'ZXXD_e','ZXXF_e','ZXXD_e_tp','ZXXF_e_tp','xepsi','xEfield_validity')
  %
  if display_mode >= 1,info_dke_yp(2,['Electric field flux coefficients retrieved.']);end	
  %
else
%
  xepsi_fsav = zeros(size(equilDKE.xrho));
  if ~isempty(ohm),
      xepsi_fsav = interp1(ohm.rho,ohm.epsi,equilDKE.xrho,'spline')/mksa.Edreicer_ref;%Normalized to the Dreicer value
  end
%
  xrho = equilDKE.xrho;
  xB0 = equilDKE.xB0;
  xBT0 = equilDKE.xBT0;
  xx0 = equilDKE.xx0;
  Rp = equilDKE.Rp;
  Xmhu = gridDKE.Xmhu;
  X1mmhu2p = gridDKE.X1mmhu2p;
  X1mmhu2m = gridDKE.X1mmhu2m;
  ip_th_ref = gridDKE.ip_th_ref; 
  rdke =gridDKE.rdke;
  npn = gridDKE.npn;%Size of the momentum grids for the distribution function (half grid)
  nmhu = gridDKE.nmhu;
  nr = gridDKE.nr;%Size of the radial grid for the distribution function (half grid)
  nr_dke =gridDKE.nr_dke;%Size of the effective radial grid for the drift kinetic equation (nr_dke = nr for FPE equation only)
%
  XXlambda_b_p1m3p4  = Zbouncecoef.XXlambda_b_p1m3p4;
  XXRlambda_b_p1m1p2 = Zbouncecoef.XXRlambda_b_p1m1p2;
  XXRlambda_b_p1m1p2_p = Zbouncecoef.XXRlambda_b_p1m1p2_p;
  XXRlambda_b_p1m1p2_m = Zbouncecoef.XXRlambda_b_p1m1p2_m;
  XXRlambda_b_p2m2p2  = Zbouncecoef.XXRlambda_b_p2m2p2;
  XXRlambda_b_p2m2p2_p = Zbouncecoef.XXRlambda_b_p2m2p2_p;
  XXRlambda_b_p2m2p2_m = Zbouncecoef.XXRlambda_b_p2m2p2_m;
  xqbar = Zbouncecoef.xqbar;
  xqtilde = Zbouncecoef.xqtilde;
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
        xepsi(ir) = xepsi_fsav(ir)*(xqbar(ir)/xqtilde(ir))*(xB0(ir)/xBT0(ir))*(1+xx0(ir)/Rp)/XXlambda_b_p1m3p4(1,1,ir);%Value at Bmin for FP or DKE calculations
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
%
xEfield_validity = max(squeeze(ZXXF_e.p_ij(ip_th_ref,[1,nmhu],:)./ZXXF_c.p_ij(ip_th_ref,[1,nmhu],:)));%Comparison between electric field and collisions pinches at pth_ref (if above 1, the code validity breaks close to p = 0 leading to numerical particle leak)                 
if display_mode >= 2,
    figure('Name','Code validity with Ohmic electric field'),semilogy(xrho,abs(xEfield_validity),'r+')
    xlabel('r/a')
    ylabel('Fp_e/Fp_coll at pth_ref')
    zoom on, grid on
    title('Code validity with Ohmic electric field')
end
%
%  save([fullfile(temppath,'temp_DKE.mat'],'ZXXD_e','ZXXF_e','ZXXD_e_tp','ZXXF_e_tp','xepsi','xEfield_validity','-append');
  %
  etime_efield = etime_efield + etime(clock,time0);
  if display_mode >= 1,info_dke_yp(2,['Electric field flux coefficients calculations done in ',num2str(etime_efield),' (s)']);end	
  %
%
end