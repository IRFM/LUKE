function [XXfM,ZXXD_c_pp_ipj,ZXXD_c_pp_ij,ZXXD_c_pp_imj,ZXXD_c_mm_ijp,ZXXD_c_mm_ijm,ZXXF_c_p_ipj,ZXXF_c_p_ij,ZXXF_c_p_imj] = loop_coll_dke_jd1(ir,gridDKE,Zmomcoef,Zbouncecoef,equilDKE,mksa,dkepath,dkeparam,xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth)
%LUKE - Collision operator (loop function for distributed computing environment)
%
%Collision operator (loop function for distributed computing environment)
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr) 
%
%Relativistic Maxwellian distribution function normalized to the local density
%
  	fM = maxwellian_dke_yp(Zmomcoef.gamma(:),gridDKE.pn2(:),gridDKE.dpn(:),xne_norm,xTe_norm,ir);
    xfM = fM*ones(1,length(fM));
    XXfM = fM*ones(1,gridDKE.nmhu);
	%
	%Electron-ion collision term (non-relativistic limit)
	%
    [Fei,Aei,Btei] = eicoll_dke_yp(mksa,dkeparam,Zmomcoef,gridDKE,equilDKE,ir,'+');
    [Feim,Aeim] = eicoll_dke_yp(mksa,dkeparam,Zmomcoef,gridDKE,equilDKE,ir,'m');
    [Feip,Aeip] = eicoll_dke_yp(mksa,dkeparam,Zmomcoef,gridDKE,equilDKE,ir,'p');
    % 
    Feim(1) = 1;%Avoid singularity at p = 0, but the value is not used  
	%       
    XFeim = Feim'*ones(1,gridDKE.nmhu);
    XFei = Fei'*ones(1,gridDKE.nmhu);
    XFeip = Feip'*ones(1,gridDKE.nmhu);
	%
    Aeim(1) = 1;%Avoid singularity at p = 0, but the value is not used
	%
    XAeim = Aeim'*ones(1,gridDKE.nmhu); 
    XAei = Aei'*ones(1,gridDKE.nmhu);
    XAeip = Aeip'*ones(1,gridDKE.nmhu);
	%
    XBtei = Btei'*ones(1,gridDKE.nmhu);     
	%
	%Fast electron-thermal electron collision term
	%
    if isfield(equilDKE,'screening') && ~isempty(equilDKE.screening)
        %
        if isfield(equilDKE.screening,'inelastic') && ~isempty(equilDKE.screening.inelastic)
            %
            inelastic_factor = inelastic_yp(equilDKE,mksa,xzni_norm,xbetath,Zmomcoef.gamma,gridDKE.pn);%enhanced electron slowing-down by excitation of ions
            inelastic_factor_m = inelastic_yp(equilDKE,mksa,xzni_norm,xbetath,Zmomcoef.gammam,gridDKE.pnm);%enhanced electron slowing-down by excitation of ions
            inelastic_factor_p = inelastic_yp(equilDKE,mksa,xzni_norm,xbetath,Zmomcoef.gammap,gridDKE.pnp);%enhanced electron slowing-down by excitation of ions
            %
        else
            %
            inelastic_factor = 0;%ion excitation is not considered
            inelastic_factor_m = 0;%ion excitation is not considered
            inelastic_factor_p = 0;%ion excitation is not considered
            %
        end
        %
    else
        %
        inelastic_factor = 0;%ion excitation is not considered
        inelastic_factor_m = 0;%ion excitation is not considered
        inelastic_factor_p = 0;%ion excitation is not considered
        %
    end
    %
    [Fee,Aee,Btee] = eecoll_dke_yp(dkepath,Zmomcoef.v,Zmomcoef.z,Zmomcoef.gamma,Zmomcoef.sigma,gridDKE.pn,gridDKE.pn2,gridDKE.dpn,Zmomcoef.J1,Zmomcoef.J2,dkeparam.spfac,mksa.betath_ref,xne_norm,xTe_norm,ir,dkeparam.coll_mode,mksa,dkeparam,equilDKE,gridDKE,inelastic_factor,dkeparam.clustermode);
    [Feem,Aeem] = eecoll_dke_yp(dkepath,Zmomcoef.vm,Zmomcoef.zm,Zmomcoef.gammam,Zmomcoef.sigmam,gridDKE.pnm,gridDKE.pn2m,gridDKE.dpnm,Zmomcoef.J1,Zmomcoef.J2,dkeparam.spfac,mksa.betath_ref,xne_norm,xTe_norm,ir,dkeparam.coll_mode,mksa,dkeparam,equilDKE,gridDKE,inelastic_factor_m,dkeparam.clustermode);
    [Feep,Aeep] = eecoll_dke_yp(dkepath,Zmomcoef.vp,Zmomcoef.zp,Zmomcoef.gammap,Zmomcoef.sigmap,gridDKE.pnp,gridDKE.pn2p,gridDKE.dpnp,Zmomcoef.J1,Zmomcoef.J2,dkeparam.spfac,mksa.betath_ref,xne_norm,xTe_norm,ir,dkeparam.coll_mode,mksa,dkeparam,equilDKE,gridDKE,inelastic_factor_p,dkeparam.clustermode);
	%
    Feem(1) = 1;%Avoid singularity at p = 0, but the value is not used
	%       
    XFeem = Feem'*ones(1,gridDKE.nmhu);
    XFee = Fee'*ones(1,gridDKE.nmhu);
    XFeep = Feep'*ones(1,gridDKE.nmhu);
	%
    Aeem(1) = 1;%Avoid singularity at p = 0, but the value is not used
	%
    XAeem = Aeem'*ones(1,gridDKE.nmhu); 
    XAee = Aee'*ones(1,gridDKE.nmhu);
    XAeep = Aeep'*ones(1,gridDKE.nmhu);
	%
    XBtee = Btee'*ones(1,gridDKE.nmhu);    
	%   
	% Collisions flux coefficients calculations for f0 and g
	%
    ZXXD_c_pp_ipj = XAeep + XAeip;
    ZXXD_c_pp_ij = XAee + XAei;
    ZXXD_c_pp_imj = XAeem + XAeim;
	%
    ZXXD_c_mm_ijp = (XBtee + XBtei).*Zbouncecoef.XXRlambda_p2m1_p(:,:,ir);
    ZXXD_c_mm_ijm = (XBtee + XBtei).*Zbouncecoef.XXRlambda_p2m1_m(:,:,ir);
	%
    ZXXF_c_p_ipj = -XFeep - XFeip;
    ZXXF_c_p_ij = -XFee - XFei;
    ZXXF_c_p_imj = -XFeem - XFeim;
end
