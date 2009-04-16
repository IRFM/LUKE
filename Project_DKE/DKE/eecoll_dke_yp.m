function [Fee,Aee,Btee] = eecoll_dke_yp(v,z,gamma,sigma,pn,pn2,dpn,J1,J2,spfac,betath_ref,xne_norm,xTe_norm,ir,coll_mode,clustermode)
%LUKE - Electron-electron collision operator
%
%Electron-electron collision operator (1: high velocity limit, 2:
%linearized Belaiev-Budker, 3: Lorentz model, 4: non-relativistic
%Maxwellian background, 5: Ultrarelativistic Moller model (for runaways
%only)
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr) and 
%	
    if nargin < 16,
        error('Wrong number of input arguments in eecoll_dke_yp')
    end
    %
    v2 = v.*v;
    npn = length(pn);
    %
    if coll_mode == 1,%High-velocity limit
        Fee = xne_norm(ir)'./v2;
        Aee = xne_norm(ir)'.*xTe_norm(ir)'./v./v2;
        Btee = xne_norm(ir)'./v/2 - xne_norm(ir)'.*xTe_norm(ir)'./v./v2/2;
    elseif coll_mode == 0 | coll_mode == 2,%Linearized Belaiev-Budker
    %
    %Super momentum grid definitions for collision integrals
    %
    %  spnm = linspace(pn(1)/spfac,pnm(2),spfac);%In order to start from a point not to close to zero
    %  for ip=3:npn,
    %    spnm = [spnm(1:length(spnm)-1),linspace(pnm(ip-1),pnm(ip),spfac)];  
    %  end
    %

        spn = linspace(pn(1)/spfac,pn(1),spfac);
    %  spnp = linspace(pn(1)/spfac,pnp(1),spfac);
        for ip=2:npn,
            spn = [spn(1:length(spn)-1),linspace(pn(ip-1),pn(ip),spfac)];   
    %    spnp = [spnp(1:length(spnp)-1),linspace(pnp(ip-1),pnp(ip),spfac)];  
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
        if clustermode.eecoll_dke_yp.mode,%test distributed computing environment (not usefull for this function)
            for ip = 1:npn,arg_range{ip} = ip;end
            [dkecluster] = clustermode_luke(clustermode,'eecoll_dke_jd',0);     
            [flag,F1_1,F1_2,F2_1,B1_1,B1_2,B1_3,B1_4,B1_5,B2_1,B2_2,B2_3] = mdce_luke(@loop_eecoll_dke_yp,{ip,pn,sfM,spn,spn2,sv,sgamma,sgamma2,ssigma,sz,sJ1,sJ2},1,arg_range,dkecluster);
            rmdir(dkecluster.temppath,'s');
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
        Fee = 4*pi*(F1 + F2);
        Aee = 4*pi*xTe_norm(ir)*(F1 + F2)./v;
        B1 = B1_1./v/2 - B1_2./v./pn2/6 + B1_3./v./gamma./gamma./z./z/8 - B1_4./v./z./z/4 - B1_5./v./gamma./gamma/4;
        B2 = B2_1/2 + B2_2.*(-gamma.*gamma/6 + J1./z./z./gamma/8 - gamma.*J2./z./z/4) - B2_3.*(gamma - sigma./z)./pn2./gamma/4;   
        Btee = 4*pi*(B1 + B2);
    elseif coll_mode == 3,%Lorentz model
        Fee = zeros(1,npn);
        Aee = zeros(1,npn);
        Btee = zeros(1,npn);
    elseif coll_mode == 4,%Maxwellian background
        u = v/sqrt(2)/xTe_norm(ir)';
        Fee = xne_norm(ir)'.*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi))./v2;
        Aee = xne_norm(ir)'.*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi))./v./u./u/2;
        Btee = xne_norm(ir)'.*((2*u.^2-1).*erf(u)+2*u.*exp(-u.^2)/sqrt(pi))./v./u./u/4;
    elseif coll_mode == 5,%Ultrarelativistic Moller model
        Aee = xne_norm(ir)'.*xTe_norm(ir)'./v./v2;
        Fee = xne_norm(ir)'./v2;
        Btee = xne_norm(ir)'./v/2;
    end
%
end

function [F1_1,F1_2,F2_1,B1_1,B1_2,B1_3,B1_4,B1_5,B2_1,B2_2,B2_3] = loop_eecoll_dke_yp(ip,pn,sfM,spn,spn2,sv,sgamma,sgamma2,ssigma,sz,sJ1,sJ2)
%LUKE - Electron-electron Belaiev-Budker collision operator (loop function for distributed computing environment)
%
%Electron-electron Belaiev-Budker collision operator (loop function
%for distributed computing environment)
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr) 
%
    smasku = spn <= pn(ip);
    smaskl = spn >= pn(ip);
    %
    F1_1 = trapz_dke_yp([spn,sfM.*spn.*sv.*smasku])';
    F1_2 = trapz_dke_yp([spn,sfM.*spn.*sv.*(1 - sgamma.*ssigma./sz).*smasku])';
    F2_1 = trapz_dke_yp([spn,sfM.*spn.*smaskl])';
    %
    B1_1 = trapz_dke_yp([spn,sfM.*smasku.*spn2])';
    B1_2 = trapz_dke_yp([spn,sfM.*smasku.*spn2.*spn2])';
    B1_3 = trapz_dke_yp([spn,sfM.*smasku.*spn2.*sJ1./sgamma])';
    B1_4 = trapz_dke_yp([spn,sfM.*smasku.*spn2.*sJ2./sgamma])';
    B1_5 = trapz_dke_yp([spn,sfM.*smasku.*spn2.*((sgamma - ssigma./sz)./sgamma)])';
    B2_1 = trapz_dke_yp([spn,sfM.*smaskl.*spn2./sv])';
    B2_2 = trapz_dke_yp([spn,sfM.*smaskl.*spn2./sv./sgamma2])';
    B2_3 = trapz_dke_yp([spn,sfM.*smaskl.*spn2.*sv])'; 
end


