function [ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM] = ...
    coll_dke_jd(Xmhup,Xmhu2p,X1mmhu2p,Xmhum,Xmhu2m,X1mmhu2m,...
        pn,pn2,dpn,pnm,pn2m,dpnm,pnp,pn2p,dpnp,Xpn,...
        gamma,gammam,gammap,v,vm,vp,v2,v2m,v2p,...
        sigma,sigmam,sigmap,z,zm,zp,J1,J2,...
        xTe_norm,xzTi_norm,xne_norm,xzni_norm,betath_ref,zZi,zmi,...
        XXRlambda_p2m1_p,XXRlambda_p2m1_m,XXRlambda_b_p1m1,XXRlambda_b_p1m1_p,XXRlambda_b_p1m1_m,...
        XXRlambda_b_p3m2_p,XXRlambda_b_p3m2_m,XXRlambda_b_p1m2_p,XXRlambda_b_p1m2_m,...
        spfac,coll_mode,dke_mode,display_mode,rdke,save_id,temppath);
%
etime_coll = 0;
time0 = clock;
%
%load([fullfile(temppath,'temp_DKE_'),save_id,'.mat'],'XXfM');
%
if exist('XXfM') == 1, %The bounce averaging coefficients were calculated before.
  %
%  load([fullfile(temppath,'temp_DKE_'),save_id,'.mat'],'ZXXD_c','ZXXF_c','ZXXD_c_tp','ZXXF_c_tp')
  %
  if display_mode >= 1,info_dke_yp(2,['Collision flux coefficients retrieved.']);end	
  %
else
%
  [npn,nmhu] = size(Xmhup);%Size of the momentum grids for the distribution function (half grid)
  nr = length(xTe_norm);%Size of the radial grid for the distribution function (half grid)
  nr_dke = length(rdke);%Size of the effective radial grid for the drift kinetic equation (nr_dke = nr for FPE equation only)
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
%  save([fullfile(temppath,'temp_DKE_'),save_id,'.mat'],'ZXXD_c','ZXXF_c','ZXXD_c_tp','ZXXF_c_tp','XXfM','-append');
  %
  etime_coll = etime_coll + etime(clock,time0);
  if display_mode >= 1,info_dke_yp(2,['Collision flux coefficients calculations done in ',num2str(etime_coll),' (s)']);end	
  %
%
end