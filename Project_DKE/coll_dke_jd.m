function [ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM] = ...
    coll_dke_jd(Xmhup,Xmhu2p,X1mmhu2p,Xmhum,Xmhu2m,X1mmhu2m,...
        pn,pn2,dpn,pnm,pn2m,dpnm,pnp,pn2p,dpnp,Xpn,...
        gamma,gammam,gammap,gamma2,v,vm,vp,v2,v2m,v2p,...
        sigma,sigmam,sigmap,z,zm,zp,z2,J1,J2,...
        xTe_norm,xzTi_norm,xne_norm,xzni_norm,betath_ref,zZi,zmi,...
        XXRlambda_p2m1_p,XXRlambda_p2m1_m,XXRlambda_b_p1m1,XXRlambda_b_p1m1_p,XXRlambda_b_p1m1_m,...
        XXRlambda_b_p3m2_p,XXRlambda_b_p3m2_m,XXRlambda_b_p1m2_p,XXRlambda_b_p1m2_m,...
        spfac,coll_mode,dke_mode,display_mode,rdke,save_id,temppath);
%
eval(['load ',fullfile(temppath,'temp_DKE_'),save_id,'.mat XXfM']);
    %
if exist('XXfM') == 1, %The bounce averaging coefficients were calculated before.
  %
  eval(['load ',fullfile(temppath,'temp_DKE_'),save_id,'.mat ZXXD_c ZXXF_c ZXXD_c_tp ZXXF_c_tp'])
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
%Super momentum grid definitions for collision integrals
%
  spnm = linspace(pn(1)/spfac,pnm(2),spfac);%In order to start from a point not to close to zero
  for ip=3:npn,
    spnm = [spnm(1:length(spnm)-1),linspace(pnm(ip-1),pnm(ip),spfac)];  
  end
%
  spn = linspace(pn(1)/spfac,pn(1),spfac);
  spnp = linspace(pn(1)/spfac,pnp(1),spfac);
  for ip=2:npn,
    spn = [spn(1:length(spn)-1),linspace(pn(ip-1),pn(ip),spfac)];   
    spnp = [spnp(1:length(spnp)-1),linspace(pnp(ip-1),pnp(ip),spfac)];  
  end
%
  spnm = spnm(:);%for numerical integration by trapz_dke_yp subroutine
  spn = spn(:);%for numerical integration by trapz_dke_yp subroutine
  spnp = spnp(:);%for numerical integration by trapz_dke_yp subroutine
%
  spn2m = spnm.*spnm;
  spn2 = spn.*spn;
  spn2p = spnp.*spnp;
  spn3 = spn2.*spn;
%
  szm = betath_ref*spnm;
  sz = betath_ref*spn;
  szp = betath_ref*spnp;
  sz2m = szm.*szm;
  sz2 = sz.*sz;
  sz2p = szp.*szp;
%
  sgammam = sqrt(1 + sz2m);
  sgamma = sqrt(1 + sz2);
  sgammap = sqrt(1 + sz2p);
  sgamma2 = sgamma.*sgamma;
%
  ssigmam = asinh(szm);
  ssigma = asinh(sz);
  ssigmap = asinh(szp);
%
  svm = spnm./sgammam;
  sv = spn./sgamma;
  svp = spnp./sgammap;
  sv2 = sv.*sv;
%
  sJ1 = -3*sgamma + ssigma.*(3.0./sz + 2*sz);
  sJ2 = sgamma - ssigma./sz - 2*sgamma.*sz2/3;
%
  for ir = 1:nr,
%
%Relativistic Maxwellian distribution function for collision integrals
%
    fM = exp(-pn2./(1 + gamma)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
    normfM = 4*pi*integral_dke_jd(dpn,pn.*pn.*fM,2);
    fM = fM*xne_norm(ir)/normfM;
    xfM = fM'*ones(1,length(fM));
    XXfM(:,:,ir) = fM'*ones(1,nmhu);
%
    fMm = exp(-pn2m./(1 + gammam)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
    normfMm = 4*pi*integral_dke_jd(dpnm,pnm.*pnm.*fMm,2);
    fMm = fMm*xne_norm(ir)/normfMm;
%
    fMp = exp(-pn2p./(1 + gammap)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
    normfMp = 4*pi*integral_dke_jd(dpnp,pnp.*pnp.*fMp,2);
    fMp = fMp*xne_norm(ir)/normfMp;
%
%Collision integrals
%   
    sfMm = exp(-spn2m./(1 + sgammam)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
    snormfMm = 4*pi*trapz_dke_yp([spnm,spn2m.*sfMm]);
    sfMm = sfMm*xne_norm(ir)/snormfMm;
%   
    sfM = exp(-spn2./(1 + sgamma)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
    snormfM = 4*pi*trapz_dke_yp([spn,spn2.*sfM]);
    sfM = sfM*xne_norm(ir)/snormfM;
%
    sfMp = exp(-spn2p./(1 + sgammap)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
    snormfMp = 4*pi*trapz_dke_yp([spnp,spn2p.*sfMp]);
    sfMp = sfMp*xne_norm(ir)/snormfMp;
%
    for ip = 1:npn,%Loop for very accurate collision integral calculation close to p = 0 especially (crucial for numerical conservative scheme)
        smasku = spn <= pn(ip);
        smaskl = spn >= pn(ip);
        smaskup = spnp <= pnp(ip);
        smasklp = spnp >= pnp(ip);
        smaskum = spnm <= pnm(ip);
        smasklm = spnm >= pnm(ip);
%
        F1_1(1,ip) = trapz_dke_yp([spn,sfM.*spn.*sv.*smasku])';
        F1_2(1,ip) = trapz_dke_yp([spn,sfM.*spn.*sv.*(1 - sgamma.*ssigma./sz).*smasku])';
        F2_1(1,ip) = trapz_dke_yp([spn,sfM.*spn.*smaskl])';
%       
        F1_1m(1,ip) = trapz_dke_yp([spnm,sfMm.*spnm.*svm.*smaskum])';
        F1_2m(1,ip) = trapz_dke_yp([spnm,sfMm.*spnm.*svm.*(1 - sgammam.*ssigmam./szm).*smaskum])';
        F2_1m(1,ip) = trapz_dke_yp([spnm,sfMm.*spnm.*smasklm])';
%       
        F1_1p(1,ip) = trapz_dke_yp([spnp,sfMp.*spnp.*svp.*smaskup])';
        F1_2p(1,ip) = trapz_dke_yp([spnp,sfMp.*spnp.*svp.*(1 - sgammap.*ssigmap./szp).*smaskup])';
        F2_1p(1,ip) = trapz_dke_yp([spnp,sfMp.*spnp.*smasklp])';
%
        B1_1(1,ip) = trapz_dke_yp([spn,sfM.*smasku.*spn2])';
        B1_2(1,ip) = trapz_dke_yp([spn,sfM.*smasku.*spn2.*spn2])';
        B1_3(1,ip) = trapz_dke_yp([spn,sfM.*smasku.*spn2.*sJ1./sgamma])';
        B1_4(1,ip) = trapz_dke_yp([spn,sfM.*smasku.*spn2.*sJ2./sgamma])';
        B1_5(1,ip) = trapz_dke_yp([spn,sfM.*smasku.*spn2.*((sgamma - ssigma./sz)./sgamma)])';
        B2_1(1,ip) = trapz_dke_yp([spn,sfM.*smaskl.*spn2./sv])';
        B2_2(1,ip) = trapz_dke_yp([spn,sfM.*smaskl.*spn2./sv./sgamma2])';
        B2_3(1,ip) = trapz_dke_yp([spn,sfM.*smaskl.*spn2.*sv])';  
    end
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
    if coll_mode == 1,%High-velocity limit
        Fee = xne_norm(ir)'./v2;
        Feem = xne_norm(ir)'./v2m;      
        Feep = xne_norm(ir)'./v2p;      
    elseif coll_mode == 0 | coll_mode == 2,%Linearized Belaiev-Budker
        F1 = F1_1./v2 + F1_2./pn2;
        F2 = (1 - sigma./z./gamma).*F2_1./v;
        Fee = 4*pi*(F1 + F2);
%
        F1m = F1_1m ./v2m + F1_2m./pn2m;  
        F2m = (1 - sigmam./zm./gammam).*F2_1m./vm;  
        Feem = 4*pi*(F1m + F2m);        
%   
        F1p = F1_1p./v2p + F1_2p./pn2p;   
        F2p = (1 - sigmap./zp./gammap).*F2_1p./vp;
        Feep = 4*pi*(F1p + F2p);
    elseif coll_mode == 3,%Lorentz model
        Fee = zeros(1,npn);
        Feem = zeros(1,npn);
        Feep = zeros(1,npn);
    elseif coll_mode == 4,%Maxwellian background
        u = v/sqrt(2)/xTe_norm(ir)';Fee = xne_norm(ir)'.*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi))./v2;
        um = vm/sqrt(2)/xTe_norm(ir)';Feem = xne_norm(ir)'.*(erf(um)-2*um.*exp(-um.^2)/sqrt(pi))./v2m;  
        up = vp/sqrt(2)/xTe_norm(ir)';Feep = xne_norm(ir)'.*(erf(up)-2*up.*exp(-up.^2)/sqrt(pi))./v2p;  
    elseif coll_mode == 5,%Ultrarelativistic Moller model
        Fee = xne_norm(ir)'./v2;
        Feem = xne_norm(ir)'./v2m;
        Feep = xne_norm(ir)'./v2p;  
    end
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
    if coll_mode == 1,%High-velocity limit
        Aee = xne_norm(ir)'.*xTe_norm(ir)'./v./v2;
        Aeem = xne_norm(ir)'.*xTe_norm(ir)'./vm./v2m;
        Aeep = xne_norm(ir)'.*xTe_norm(ir)'./vp./v2p;
    elseif coll_mode == 0 | coll_mode == 2,%Linearized Belaiev-Budker
        Aee = 4*pi*xTe_norm(ir)*(F1 + F2)./v;
        Aeem = 4*pi*xTe_norm(ir)*(F1m + F2m)./vm;
        Aeep = 4*pi*xTe_norm(ir)*(F1p + F2p)./vp;
    elseif coll_mode == 3,%Lorentz model
        Aee = zeros(1,npn);
        Aeem = zeros(1,npn);
        Aeep = zeros(1,npn);
    elseif coll_mode == 4,%Maxwellian background
        u = v/sqrt(2)/xTe_norm(ir)';Aee = xne_norm(ir)'.*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi))./v./u./u/2;
        um = vm/sqrt(2)/xTe_norm(ir)';Aeem = xne_norm(ir)'.*(erf(um)-2*um.*exp(-um.^2)/sqrt(pi))./vm./um./um/2; 
        Am(1) = 1;%Avoid singularity at p = 0, but the value is not used
        up = vp/sqrt(2)/xTe_norm(ir)';Aeep = xne_norm(ir)'.*(erf(up)-2*up.*exp(-up.^2)/sqrt(pi))./vp./up./up/2; 
    elseif coll_mode == 5,%Ultrarelativistic Moller model
        Aee = xne_norm(ir)'.*xTe_norm(ir)'./v./v2;
        Aeem = xne_norm(ir)'.*xTe_norm(ir)'./vm./v2m;
        Aeep = xne_norm(ir)'.*xTe_norm(ir)'./vp./v2p;
    end
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
    if coll_mode == 1,%High-velocity limit
        Btee = xne_norm(ir)'./v/2 - xne_norm(ir)'.*xTe_norm(ir)'./v./v2/2;
    elseif coll_mode == 0 | coll_mode == 2,%Linearized Belaiev-Budker
        B1 = B1_1./v/2 - B1_2./v./pn2/6 + B1_3./v./gamma2./z2/8 - B1_4./v./z2/4 - B1_5./v./gamma2/4;
        B2 = B2_1/2 + B2_2.*(-gamma2/6 + J1./z2./gamma/8 - gamma.*J2./z2/4) - B2_3.*(gamma - sigma./z)./pn2./gamma/4;   
        Btee = 4*pi*(B1 + B2);      
    elseif coll_mode == 3,%Lorentz model
        Btee = zeros(1,npn);
    elseif coll_mode == 4,%Maxwellian background
        u = v/sqrt(2)/xTe_norm(ir)';                  
        Btee = xne_norm(ir)'.*((2*u.^2-1).*erf(u)+2*u.*exp(-u.^2)/sqrt(pi))./v./u./u/4;
    elseif coll_mode == 5,%Ultrarelativistic Moller model
       Btee = xne_norm(ir)'./v/2;
    end
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
        ZXXF_c_tp.p_ippj = -(XFeepp + XFeipp).*XXRlambda_b_p1m1(:,:,ir);
        ZXXF_c_tp.p_ipj = -(XFeep + XFeip).*XXRlambda_b_p1m1(:,:,ir);
        ZXXF_c_tp.p_ij = -(XFee + XFei).*XXRlambda_b_p1m1(:,:,ir);
        ZXXF_c_tp.p_imj = -(XFeem + XFeim).*XXRlambda_b_p1m1(:,:,ir);
        ZXXF_c_tp.p_immj = -(XFeemm + XFeimm).*XXRlambda_b_p1m1(:,:,ir);  
%
        ZXXF_c_tp.m_ijp = (XBtee + XBtei).*(XXRlambda_b_p1m1_p(:,:,ir) - XXRlambda_b_p1m2_p(:,:,ir)).*sqrt(X1mmhu2p)./Xpn./Xmhu2p./Xmhup;
        ZXXF_c_tp.m_ijm = (XBtee + XBtei).*(XXRlambda_b_p1m1_m(:,:,ir) - XXRlambda_b_p1m2_m(:,:,ir)).*sqrt(X1mmhu2m)./Xpn./Xmhu2m./Xmhum;
    end
%    
  end
  eval(['save ',fullfile(temppath,'temp_DKE_'),save_id,'.mat ZXXD_c ZXXF_c ZXXD_c_tp ZXXF_c_tp XXfM -append']);
  %
  if display_mode >= 1,info_dke_yp(2,['Collision flux coefficients saved.']);end	
  %
%
end