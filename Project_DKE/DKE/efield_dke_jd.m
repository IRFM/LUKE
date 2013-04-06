function [ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity] = efield_dke_jd(dkepath,dkeparam,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef,ohm,ZXXF_c)
%
% Calculate matrix coefficient for the Ohmic electric field in LUKE
%
% by Y. PEYSSON, CEA-DRFC (yves.peysson@cea.fr) and J. DECKER (joan.decke@cea.fr) 
%
display_mode = display.display_mode;
%
dke_mode = dkeparam.dke_mode;
bounce_mode = dkeparam.bounce_mode;
dke_mode = dkeparam.dke_mode;
temppath = dkepath.temppath;
%
etime_efield = 0;
time0 = clock;
%
%load([fullfile(temppath,'temp_DKE.mat'],'xepsi');
%
if exist('xepsi') == 1, %The bounce averaging coefficients were calculated before.
    %
  	%load([fullfile(temppath,'temp_DKE.mat'],'ZXXD_e','ZXXF_e','ZXXD_e_tp','ZXXF_e_tp','xepsi','xEfield_validity')
    %
    if display_mode >= 1,info_dke_yp(2,['Electric field flux coefficients retrieved.']);end	
    %
else
%
  xrho = equilDKE.xrho;
  xrhoT = equilDKE.xrhoT;
  xrhoP = equilDKE.xrhoP;
  xrhoV = equilDKE.xrhoV;
%
  xepsi_fsav = zeros(size(equilDKE.xrho));
  if ~isempty(ohm) && isstruct(ohm) && ~isempty(fieldnames(ohm)),
      if ~isfield(ohm,'rhotype') || strcmp(ohm.rhotype,'g'),%geometric rho
          xepsi_fsav = interp1(ohm.rho,ohm.epsi,xrho,'spline')/mksa.Edreicer_ref;%Normalized to the Dreicer value
      elseif strcmp(ohm.rhotype,'p'),
          xepsi_fsav = interp1(ohm.rho,ohm.epsi,xrhoP,'spline')/mksa.Edreicer_ref;%Normalized to the Dreicer value
      elseif strcmp(ohm.rhotype,'t'),
          xepsi_fsav = interp1(ohm.rho,ohm.epsi,xrhoT,'spline')/mksa.Edreicer_ref;%Normalized to the Dreicer value
      elseif strcmp(ohm.rhotype,'v'),
          xepsi_fsav = interp1(ohm.rho,ohm.epsi,xrhoV,'spline')/mksa.Edreicer_ref;%Normalized to the Dreicer value
      else
          error('unknown rho type in ohm structure')
      end
  end
  %
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
  XXlambda_b_p1m2p2  = Zbouncecoef.XXlambda_b_p1m2p2;
  XXRlambda_b_p1m1p2 = Zbouncecoef.XXRlambda_b_p1m1p2;
  XXRlambda_b_p1m1p2_p = Zbouncecoef.XXRlambda_b_p1m1p2_p;
  XXRlambda_b_p1m1p2_m = Zbouncecoef.XXRlambda_b_p1m1p2_m;
  XXRlambda_b_p2m2p2  = Zbouncecoef.XXRlambda_b_p2m2p2;
  XXRlambda_b_p2m2p2_p = Zbouncecoef.XXRlambda_b_p2m2p2_p;
  XXRlambda_b_p2m2p2_m = Zbouncecoef.XXRlambda_b_p2m2p2_m;
  xqbar = Zbouncecoef.xqbar;
  xqtilde = Zbouncecoef.xqtilde;
  xqhat = Zbouncecoef.xqhat;
    %
    % Output files initialization
    %
    %
    % Terms from Sp at l+1/2 (Notations: _imj -> (i,j+1+2);_ipj -> (i+1,j+1/2)
    %
    ZXXD_e.pp_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    ZXXD_e.pp_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    ZXXD_e.pm_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    ZXXD_e.pm_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    ZXXD_e.pr_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
    ZXXD_e.pr_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
    %   
    ZXXF_e.p_ipj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    ZXXF_e.p_imj = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    %
    % Terms from Sksi at l+1/2 (Notations: _ijp -> (i+1/2,j+1);_ijm -> (i+1/2,j)
    %
    ZXXD_e.mm_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    ZXXD_e.mm_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    ZXXD_e.mp_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    ZXXD_e.mp_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    ZXXD_e.mr_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
    ZXXD_e.mr_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
    %
    ZXXF_e.m_ijp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    ZXXF_e.m_ijm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%momentum dynamics only
    %
    % Terms from Spsi at (i+1/2,j+1/2) (Notations: _lm -> (l);_lp -> (l+1);
    %
    ZXXD_e.rr_lm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%radial dynamics only
    ZXXD_e.rr_lp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%radial dynamics only
    ZXXD_e.rp_lm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
    ZXXD_e.rp_lp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
    ZXXD_e.rm_lm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
    ZXXD_e.rm_lp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
    %
    ZXXF_e.r_lm = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%radial dynamics only
    ZXXF_e.r_lp = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);%radial dynamics only
    %
    % Terms used by the old scheme only for momentum cross-derivatives (M.
    % Shoucri and I. Shkarofsky,Comp. Phys. Comm., 82 (1994) 287)
    %
    ZXXD_e.pp_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
    ZXXD_e.pm_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
    ZXXD_e.mp_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
    ZXXF_e.p_ij = zeros(gridDKE.npn,gridDKE.nmhu,gridDKE.nr);
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
    if bounce_mode == 0 | xepsi_fsav(ir) == 0,
        xepsi(ir) = xepsi_fsav(ir);
    elseif bounce_mode == 1,
        if isreal(xepsi_fsav),%flux surface-averaging definition of LUKE using surface densities
            %xepsi(ir) = xepsi_fsav(ir)*(xqbar(ir)/xqtilde(ir))*(xB0(ir)/xBT0(ir))*(1+xx0(ir)/Rp)/XXlambda_b_p1m3p4(1,1,ir);%Value at Bmin for FP or DKE calculations
            xepsi(ir) = xepsi_fsav(ir)*(xqhat(ir)/xqtilde(ir))/XXlambda_b_p1m2p2(1,1,ir);%Value at Bmin for FP or DKE calculations
        else,%flux surface-averaging definition of CRONOS using volume densities
            xepsi(ir) = imag(xepsi_fsav(ir))*(xqhat(ir)/xqtilde(ir))/XXlambda_b_p1m2p2(1,1,ir);%Value at Bmin for FP or DKE calculations            
        end
    end
    if xepsi(ir) > 0.05, 
%        info_dke_yp(2,'WARNING: Ohmic electric field is likely too large. See the documentation');%To be consistent with the assumption of the linearized Fokker-Planck equation
    end 
%   
% Electric field flux coefficients calculations for f0 and g
%   
    ZXXF_e.p_ipj(:,:,ir) = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir);
    ZXXF_e.p_ij(:,:,ir) = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir); 
    ZXXF_e.p_imj(:,:,ir) = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir);
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