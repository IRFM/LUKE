function [ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM,XXILor] = coll_dke_jd(path,dkeparam,display,equilDKE,mksa,gridDKE,Zmomcoef,Zbouncecoef);
%
coll_mode = dkeparam.coll_mode;
bounce_mode = dkeparam.bounce_mode;
dke_mode = dkeparam.dke_mode;
temppath = path.temppath;
%
display_mode = display.display_mode;
%
etime_coll = 0;
time0 = clock;
%
%load([fullfile(temppath,'temp_DKE.mat'],'ZXXD_c','ZXXF_c','ZXXD_c_tp','ZXXF_c_tp','XXfM','XXILor');
%
if exist('XXfM') == 1, %The bounce averaging coefficients were calculated before.
  %
%  load([fullfile(temppath,'temp_DKE.mat'],'ZXXD_c','ZXXF_c','ZXXD_c_tp','ZXXF_c_tp','XXfM','XXILor')
  %
  if display_mode >= 1,info_dke_yp(2,['Collision flux coefficients retrieved.']);end	
  %
else
  [xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth] = normcoef_dke_yp(mksa,equilDKE,gridDKE);
%
  betath_ref = mksa.betath_ref;
%
 zZi = equilDKE.zZi;
 zmi = equilDKE.zmi;
%
  Xmhup = gridDKE.Xmhup;
  Xmhu2p = gridDKE.Xmhu2p;
  X1mmhu2p = gridDKE.X1mmhu2p;
  Xmhum = gridDKE.Xmhum;
  Xmhu2m = gridDKE.Xmhu2m;
  X1mmhu2m = gridDKE.X1mmhu2m;
  pn = gridDKE.pn;
  pn2 = gridDKE.pn2;
  dpn = gridDKE.dpn;
  pnm = gridDKE.pnm;
  pn2m = gridDKE.pn2m;
  dpnm = gridDKE.dpnm;
  pnp = gridDKE.pnp;
  pn2p = gridDKE.pn2p;
  dpnp = gridDKE.dpnp;
  Xpn = gridDKE.Xpn;
  spfac = gridDKE.spfac; 
  mhu = gridDKE.mhu;
  dmhu = gridDKE.dmhu;
  rdke = gridDKE.rdke;
  npn = gridDKE.npn;%Size of the momentum grids for the distribution function (half grid)
  nmhu = gridDKE.nmhu;
  nr = gridDKE.nr;%Size of the radial grid for the distribution function (half grid)
  nr_dke =gridDKE.nr_dke;%Size of the effective radial grid for the drift kinetic equation (nr_dke = nr for FPE equation only)
%
  gamma = Zmomcoef.gamma;
  gammam = Zmomcoef.gammam;
  gammap = Zmomcoef.gammap;
  v = Zmomcoef.v;
  vm = Zmomcoef.vm;
  vp = Zmomcoef.vp;
  v2 = Zmomcoef.v2;
  v2m = Zmomcoef.v2m;
  v2p = Zmomcoef.v2p;
  sigma = Zmomcoef.sigma;
  sigmam = Zmomcoef.sigmam;
  sigmap = Zmomcoef.sigmap;
  z = Zmomcoef.z;
  zm = Zmomcoef.zm;
  zp = Zmomcoef.zp;
  J1 = Zmomcoef.J1;
  J2 = Zmomcoef.J2;
%
  XXRlambda_p2m1_p = Zbouncecoef.XXRlambda_p2m1_p;
  XXRlambda_p2m1_m = Zbouncecoef.XXRlambda_p2m1_m;
  XXRlambda_b_p1m1 = Zbouncecoef.XXRlambda_b_p1m1;
  XXlambda_b_p3m2 =  Zbouncecoef.XXlambda_b_p3m2;
  XXlambda_p2m1 =  Zbouncecoef.XXlambda_p2m1;
  XXRlambda_b_p1m1_p = Zbouncecoef.XXRlambda_b_p1m1_p;
  XXRlambda_b_p1m1_m = Zbouncecoef.XXRlambda_b_p1m1_m;
  XXRlambda_b_p3m2_p = Zbouncecoef.XXRlambda_b_p3m2_p;
  XXRlambda_b_p3m2_m = Zbouncecoef.XXRlambda_b_p3m2_m;
  XXRlambda_b_p1m2_p = Zbouncecoef.XXRlambda_b_p1m2_p;
  XXRlambda_b_p1m2_m = Zbouncecoef.XXRlambda_b_p1m2_m;
  Zmask_f0_P = Zbouncecoef.Zmask_f0_P;

%
% Output files initialization
%
  ZXXD_c.pp_ippj = zeros(npn,nmhu,nr);
  ZXXD_c.pp_ipj = zeros(npn,nmhu,nr);
  ZXXD_c.pp_ij = zeros(npn,nmhu,nr);
  ZXXD_c.pp_imj = zeros(npn,nmhu,nr);
  ZXXD_c.pp_immj = zeros(npn,nmhu,nr);
  ZXXD_c.pm_ipj = zeros(npn,nmhu,nr);
  ZXXD_c.pm_ij = zeros(npn,nmhu,nr);
  ZXXD_c.pm_imj = zeros(npn,nmhu,nr);
  ZXXD_c.mp_ijp = zeros(npn,nmhu,nr);
  ZXXD_c.mp_ij = zeros(npn,nmhu,nr);
  ZXXD_c.mp_ijm = zeros(npn,nmhu,nr);
  ZXXD_c.mm_ijp = zeros(npn,nmhu,nr);
  ZXXD_c.mm_ijm = zeros(npn,nmhu,nr);
%
  ZXXF_c.p_ippj = zeros(npn,nmhu,nr);
  ZXXF_c.p_ipj = zeros(npn,nmhu,nr);
  ZXXF_c.p_ij = zeros(npn,nmhu,nr);
  ZXXF_c.p_imj = zeros(npn,nmhu,nr);
  ZXXF_c.p_immj = zeros(npn,nmhu,nr);
  ZXXF_c.m_ijp = zeros(npn,nmhu,nr);
  ZXXF_c.m_ijm = zeros(npn,nmhu,nr);
%
  if dke_mode == 1
%
    ZXXD_c_tp.pp_ippj = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.pp_ipj = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.pp_ij = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.pp_imj = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.pp_immj = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.pm_ipj = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.pm_ij = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.pm_imj = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.mp_ijp = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.mp_ij = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.mp_ijm = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.mm_ijp = zeros(npn,nmhu,nr_dke);
    ZXXD_c_tp.mm_ijm = zeros(npn,nmhu,nr_dke);
%
	ZXXF_c_tp.p_ippj = zeros(npn,nmhu,nr_dke);
	ZXXF_c_tp.p_ipj = zeros(npn,nmhu,nr_dke);
	ZXXF_c_tp.p_ij = zeros(npn,nmhu,nr_dke);
	ZXXF_c_tp.p_imj = zeros(npn,nmhu,nr_dke);
	ZXXF_c_tp.p_immj = zeros(npn,nmhu,nr_dke);
	ZXXF_c_tp.m_ijp = zeros(npn,nmhu,nr_dke);
	ZXXF_c_tp.m_ijm = zeros(npn,nmhu,nr_dke);
%    
  else
%    
	ZXXD_c_tp = NaN;
	ZXXF_c_tp = NaN;
%
  end
%
  for ir = 1:nr,
%
%Relativistic Maxwellian distribution function normalized to the local density
%
  	fM = maxwellian_dke_yp(gamma(:),pn2(:),dpn(:),xne_norm,xTe_norm,ir);
    xfM = fM*ones(1,length(fM));
    XXfM(:,:,ir) = fM*ones(1,nmhu);
%
%Electron-ion collision term (non-relativistic limit)
%
    [Fei,Aei,Btei] = eicoll_dke_yp(v,zZi,zmi,xzni_norm,xzTi_norm,ir,coll_mode);
    [Feim,Aeim] = eicoll_dke_yp(vm,zZi,zmi,xzni_norm,xzTi_norm,ir,coll_mode);
    [Feip,Aeip] = eicoll_dke_yp(vp,zZi,zmi,xzni_norm,xzTi_norm,ir,coll_mode);
%   
    Feim(1) = 1;%Avoid singularity at p = 0, but the value is not used  
    Feimm = [0,Fei(1:npn-1)];
    Feipp = [Fei(2:npn),0];
%       
    XFeimm = Feimm'*ones(1,nmhu);
    XFeim = Feim'*ones(1,nmhu);
    XFei = Fei'*ones(1,nmhu);
    XFeip = Feip'*ones(1,nmhu);
    XFeipp = Feipp'*ones(1,nmhu);
%
    Aeim(1) = 1;%Avoid singularity at p = 0, but the value is not used
    Aeimm = [eps,Aei(1:npn-1)];
    Aeipp = [Aei(2:npn),eps];
%
    XAeimm = Aeimm'*ones(1,nmhu);
    XAeim = Aeim'*ones(1,nmhu); 
    XAei = Aei'*ones(1,nmhu);
    XAeip = Aeip'*ones(1,nmhu);
    XAeipp = Aeipp'*ones(1,nmhu);
%
    XBtei = Btei'*ones(1,nmhu);     
%
%Fast electron-thermal electron collision term
%
    [Fee,Aee,Btee] = eecoll_dke_yp(v,z,gamma,sigma,pn,pn2,dpn,J1,J2,spfac,betath_ref,xne_norm,xTe_norm,ir,coll_mode);
    [Feem,Aeem] = eecoll_dke_yp(vm,zm,gammam,sigmam,pnm,pn2m,dpnm,J1,J2,spfac,betath_ref,xne_norm,xTe_norm,ir,coll_mode);
    [Feep,Aeep] = eecoll_dke_yp(vp,zp,gammap,sigmap,pnp,pn2p,dpnp,J1,J2,spfac,betath_ref,xne_norm,xTe_norm,ir,coll_mode);
%
    Feem(1) = 1;%Avoid singularity at p = 0, but the value is not used
    Feemm = [0,Fee(1:npn-1)];
    Feepp = [Fee(2:npn),0];
%       
    XFeemm = Feemm'*ones(1,nmhu);
    XFeem = Feem'*ones(1,nmhu);
    XFee = Fee'*ones(1,nmhu);
    XFeep = Feep'*ones(1,nmhu);
    XFeepp = Feepp'*ones(1,nmhu);
%
    Aeem(1) = 1;%Avoid singularity at p = 0, but the value is not used
    Aeemm = [eps,Aee(1:npn-1)];
    Aeepp = [Aee(2:npn),eps];
%
    XAeemm = Aeemm'*ones(1,nmhu);
    XAeem = Aeem'*ones(1,nmhu); 
    XAee = Aee'*ones(1,nmhu);
    XAeep = Aeep'*ones(1,nmhu);
    XAeepp = Aeepp'*ones(1,nmhu);
%
    XBtee = Btee'*ones(1,nmhu);    
%   
% Collisions flux coefficients calculations for f0 and g
%
    ZXXD_c.pp_ippj(:,:,ir) = XAeepp + XAeipp;
    ZXXD_c.pp_ipj(:,:,ir) = XAeep + XAeip;
    ZXXD_c.pp_ij(:,:,ir) = XAee + XAei;
    ZXXD_c.pp_imj(:,:,ir) = XAeem + XAeim;
    ZXXD_c.pp_immj(:,:,ir) = XAeemm + XAeimm;
%
    ZXXD_c.mm_ijp(:,:,ir) = (XBtee + XBtei).*XXRlambda_p2m1_p(:,:,ir);
    ZXXD_c.mm_ijm(:,:,ir) = (XBtee + XBtei).*XXRlambda_p2m1_m(:,:,ir);
%
    ZXXF_c.p_ippj(:,:,ir) = -XFeepp - XFeipp;
    ZXXF_c.p_ipj(:,:,ir) = -XFeep - XFeip;
    ZXXF_c.p_ij(:,:,ir) = -XFee - XFei;
    ZXXF_c.p_imj(:,:,ir) = -XFeem - XFeim;
    ZXXF_c.p_immj(:,:,ir) = -XFeemm - XFeimm;    
%
% Collisions flux coefficients calculations for ftp
%   
    if dke_mode == 1
%
        ir_dke = find(ir == rdke);
        if isempty(ir_dke)
            continue
        end
%
        ZXXD_c_tp.pp_ippj(:,:,ir_dke) = (XAeepp + XAeipp).*XXRlambda_b_p1m1(:,:,ir);
        ZXXD_c_tp.pp_ipj(:,:,ir_dke) = (XAeep + XAeip).*XXRlambda_b_p1m1(:,:,ir);
        ZXXD_c_tp.pp_ij(:,:,ir_dke) = (XAee + XAei).*XXRlambda_b_p1m1(:,:,ir);
        ZXXD_c_tp.pp_imj(:,:,ir_dke) = (XAeem + XAeim).*XXRlambda_b_p1m1(:,:,ir);
        ZXXD_c_tp.pp_immj(:,:,ir_dke) = (XAeemm + XAeimm).*XXRlambda_b_p1m1(:,:,ir);
%
        ZXXD_c_tp.mm_ijp(:,:,ir_dke) = (XBtee + XBtei).*XXRlambda_b_p3m2_p(:,:,ir);
        ZXXD_c_tp.mm_ijm(:,:,ir_dke) = (XBtee + XBtei).*XXRlambda_b_p3m2_m(:,:,ir);
%
        ZXXF_c_tp.p_ippj(:,:,ir_dke) = -(XFeepp + XFeipp).*XXRlambda_b_p1m1(:,:,ir);
        ZXXF_c_tp.p_ipj(:,:,ir_dke) = -(XFeep + XFeip).*XXRlambda_b_p1m1(:,:,ir);
        ZXXF_c_tp.p_ij(:,:,ir_dke) = -(XFee + XFei).*XXRlambda_b_p1m1(:,:,ir);
        ZXXF_c_tp.p_imj(:,:,ir_dke) = -(XFeem + XFeim).*XXRlambda_b_p1m1(:,:,ir);
        ZXXF_c_tp.p_immj(:,:,ir_dke) = -(XFeemm + XFeimm).*XXRlambda_b_p1m1(:,:,ir);  
%
        ZXXF_c_tp.m_ijp(:,:,ir_dke) = (XBtee + XBtei).*(XXRlambda_b_p1m1_p(:,:,ir) - XXRlambda_b_p1m2_p(:,:,ir)).*sqrt(X1mmhu2p)./Xpn./Xmhu2p./Xmhup;
        ZXXF_c_tp.m_ijm(:,:,ir_dke) = (XBtee + XBtei).*(XXRlambda_b_p1m1_m(:,:,ir) - XXRlambda_b_p1m2_m(:,:,ir)).*sqrt(X1mmhu2m)./Xpn./Xmhu2m./Xmhum;
    end
%    
  end
%
%   
%Pitch-angle integral for the Lorentz model (test mode only and initial guess for the drift kinetic equation, see documentation)
%   
XXILor =  zeros(npn,nmhu,nr);
for ir_dke = 1:nr_dke,
    jr2 = rdke(ir_dke);
    if bounce_mode == 1
        ILor_p = Zmask_f0_P{jr2}.*sum(((dmhu.*(mhu>=0).*XXlambda_b_p3m2(1,:,jr2)./XXlambda_p2m1(1,:,jr2))'*ones(1,nmhu)).*triu(ones(nmhu,nmhu)));
        ILor_m = fliplr(ILor_p);
        ILor = ILor_m + ILor_p;
        XXILor(:,:,jr2) = ones(npn,1)*ILor;
    else
        XXILor(:,:,jr2) = zeros(npn,nmhu);
    end 
end 
%
%  save([fullfile(temppath,'temp_DKE.mat'],'ZXXD_c','ZXXF_c','ZXXD_c_tp','ZXXF_c_tp','XXfM','XXILor','-append');
%
etime_coll = etime_coll + etime(clock,time0);
if display_mode >= 1,info_dke_yp(2,['Collision flux coefficients calculations done in ',num2str(etime_coll),' (s)']);end	
%
end