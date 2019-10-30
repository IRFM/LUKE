function [Fee,Aee,Btee] = eecoll_dke_yp(dkepath,v,z,gamma,sigma,pn,pn2,dpn,J1,J2,spfac,betath_ref,xne_norm,xTe_norm,ir,coll_mode,mksa,dkeparam,equilDKE,gridDKE,inelastic_factor,clustermode)
%LUKE - Electron-electron collision operator
%
%Electron-electron collision operator (1 or 3: high velocity limit, 0 or 2: Belaiev-Budker collision operator, 4: non-relativistic Maxwellian background, 5: Ultrarelativistic high velocity limit (for runaways only)
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr) and 
%	
if nargin < 20,
    error('Wrong number of input arguments in eecoll_dke_yp')
end
%
[~,~,~,~,~,~,xlnc_e,~,~] = normcoef_dke_yp(mksa,dkeparam,equilDKE,gridDKE);
%
prel = gridDKE.pn*mksa.betath_ref;%conversion to relativistic units
%
if isfield(equilDKE,'coulog_model') && ~isempty(equilDKE.coulog_model)
    %
    [~,~,xpcleerel,~] = coulomb_logarithm_yp(equilDKE.coulog_model,equilDKE.xne,equilDKE.xTe,prel);
    %~
    xpcleereln = xpcleerel./(xlnc_e*ones(1,length(prel)));
    %
else
    %
    [xcleeth,~,~,~] = coulomb_logarithm_yp(1,equilDKE.xne,equilDKE.xTe,prel);%LUKE backward compatibility
    xpcleereln = (xcleeth*ones(1,length(prel)))./(xlnc_e*ones(1,length(prel)));%no momentum dependence
    %
end
%
inelastic_factor = inelastic_factor./(xlnc_e*ones(1,length(prel)));
%inelastic_factor = 0;
%
v2 = v.*v;
npn = length(pn);
%
if coll_mode == 1 | coll_mode == 3,%High-velocity limit
    %
    Fee = (xpcleereln(ir,:) + inelastic_factor).*xne_norm(ir)'./v2;
    Aee = xpcleereln(ir,:).*xne_norm(ir)'.*xTe_norm(ir)'./v./v2;% (inelastic factor)
    Btee = xpcleereln(ir,:).*xne_norm(ir)'./v/2 - xne_norm(ir)'.*xTe_norm(ir)'./v./v2/2;
    %
elseif coll_mode == 0 | coll_mode == 2,%Belaiev-Budker collision model
%
%Super momentum grid definitions for collision integrals
%
%  spnm = linspace(pn(1)/spfac,pnm(2),spfac);%In order to start from a point not to close to zero
%  for ip=3:npn,
%    spnm = [spnm(1:length(spnm)-1),linspace(pnm(ip-1),pnm(ip),spfac)];  
%  end
%

    spn = linspace(pn(1)/spfac,pn(1),spfac);
%   spnp = linspace(pn(1)/spfac,pnp(1),spfac);
    for ip=2:npn,
        spn = [spn(1:length(spn)-1),linspace(pn(ip-1),pn(ip),spfac)];   
%       spnp = [spnp(1:length(spnp)-1),linspace(pnp(ip-1),pnp(ip),spfac)];  
    end
%
    spn = spn(:);%for numerical integration by trapz_dke_yp subroutine
    sdpn = diff([0;spn]);%point i+1/2 (f grid)
    spn2 = spn.*spn;
    sz = betath_ref*spn;
    sz2 = sz.*sz;    
    sgamma = sqrt(1 + sz2);
    sgamma2 = sgamma.*sgamma;
    ssigma = asinh(sz);
    sv = spn./sgamma;
    sJ1 = -3*sgamma + ssigma.*(3.0./sz + 2*sz);
    sJ2 = sgamma - ssigma./sz - 2*sgamma.*sz2/3;
 %
    sfM = maxwellian_dke_yp(sgamma,spn2,sdpn,xne_norm,xTe_norm,ir);
%
    F1_1 = zeros(1,npn);
    F1_2 = zeros(1,npn);
    F2_1 = zeros(1,npn);
%
    B1_1 = zeros(1,npn);
    B1_2 = zeros(1,npn);
    B1_3 = zeros(1,npn);
    B1_4 = zeros(1,npn);
    B1_5 = zeros(1,npn);
    B2_1 = zeros(1,npn);
    B2_2 = zeros(1,npn);
    B2_3 = zeros(1,npn); 
    %
    if isfield(clustermode,'eecoll_dke_yp') && isfield(clustermode.eecoll_dke_yp,'scheduler') && clustermode.eecoll_dke_yp.scheduler.mode,%test distributed computing environment (not usefull for this function)
        for ip = 1:npn,arg_range{ip} = ip;end
        [dkecluster] = clustermode_luke(clustermode,'eecoll_dke_jd',dkepath);     
        [flag,F1_1,F1_2,F2_1,B1_1,B1_2,B1_3,B1_4,B1_5,B2_1,B2_2,B2_3] = mdce_run(@loop_eecoll_dke_yp,{ip,pn,sfM,spn,spn2,sv,sgamma,sgamma2,ssigma,sz,sJ1,sJ2},1,arg_range,dkecluster);
        F1_1 = cell2mat(F1_1)';F1_2 = cell2mat(F1_2)';
        F2_1 = cell2mat(F2_1)';
        B1_1 = cell2mat(B1_1)';B1_2 = cell2mat(B1_2)';B1_3 = cell2mat(B1_3)';B1_4 = cell2mat(B1_4)';B1_5 = cell2mat(B1_5)';
        B2_1 = cell2mat(B2_1)';B2_2 = cell2mat(B2_2)';B2_3 = cell2mat(B2_3)';
    else
        for ip = 1:npn,%Loop for very accurate collision integral calculation close to p = 0 especially (crucial for numerical conservative scheme)
            [F1_1(1,ip),F1_2(1,ip),F2_1(1,ip),B1_1(1,ip),B1_2(1,ip),B1_3(1,ip),B1_4(1,ip),B1_5(1,ip),B2_1(1,ip),B2_2(1,ip),B2_3(1,ip)] = loop_eecoll_dke_yp(ip,pn,sfM,spn,spn2,sv,sgamma,sgamma2,ssigma,sz,sJ1,sJ2);
        end
    end
    %
    F1 = F1_1./v2 + F1_2./pn2;
    F2 = (1 - sigma./z./gamma).*F2_1./v;
    Fee = 4*pi*(F1 + F2).*(xpcleereln(ir,:) + inelastic_factor);
    Aee = 4*pi*xTe_norm(ir)*(F1 + F2)./v.*xpcleereln(ir,:);
    B1 = B1_1./v/2 - B1_2./v./pn2/6 + B1_3./v./gamma./gamma./z./z/8 - B1_4./v./z./z/4 - B1_5./v./gamma./gamma/4;
    B2 = B2_1/2 + B2_2.*(-gamma.*gamma/6 + J1./z./z./gamma/8 - gamma.*J2./z./z/4) - B2_3.*(gamma - sigma./z)./pn2./gamma/4;   
    Btee = 4*pi*(B1 + B2).*xpcleereln(ir,:);
elseif coll_mode == 4,%Non-relativistic Maxwellian background
    u = v/sqrt(2)/xTe_norm(ir)';
    Fee = xne_norm(ir)'.*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi))./v2.*(xpcleereln(ir,:) + inelastic_factor);
    Aee = xne_norm(ir)'.*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi))./v./u./u/2.*xpcleereln(ir,:);
    Btee = xne_norm(ir)'.*((2*u.^2-1).*erf(u)+2*u.*exp(-u.^2)/sqrt(pi))./v./u./u/4.*xpcleereln(ir,:);
elseif coll_mode == 5,%Ultrarelativistic high-velocity-limit model
    Aee = xne_norm(ir)'.*xTe_norm(ir)'./v./v2.*xpcleereln(ir,:);
    Fee = xne_norm(ir)'./v2.*(xpcleereln(ir,:) + inelastic_factor);
    Btee = xne_norm(ir)'./v/2.*xpcleereln(ir,:);
end
%
end

      
       

