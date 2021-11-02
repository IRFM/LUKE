function [Fei,Aei,Btei] = eicoll_dke_yp(mksa,dkeparam,Zmomcoef,gridDKE,equilDKE,ir,mgrid)
%
%Electron-ion collision operator (1: high velocity limit, 3 or 5 : Lorentz collision model (large zZi, zmi -> Inf, zxTi_norm = 0), all others collisions mode : non-relativistic Maxwellian background
%
%By Joan Decker (MIT-RLE) and Yves Peysson (CEA-DRFC,yves.peysson@cea.fr)
%	
if nargin < 4,
	error('Wrong number of input arguments in eicoll_dke_yp')
end
%
[~,me,~,~,~,~,~,~,~,~,~,amu] = pc_dke_yp;%Universal physics constants
%
[~,~,xzni_norm,xzTi_norm,~,~,xlnc_e,~,~] = normcoef_dke_yp(mksa,dkeparam,equilDKE,gridDKE);
%
me = me/amu;%Electron rest mass (u.m.a. units)
%
if strcmp(mgrid,'m')
    v = Zmomcoef.vm;
elseif strcmp(mgrid,'p')
    v = Zmomcoef.vp;
else
    v = Zmomcoef.v;
end
%
v2 = v.*v;
%
prel = gridDKE.pn*mksa.betath_ref;%conversion to relativistic units
%
if isfield(equilDKE,'screening') && ~isempty(equilDKE.screening)
    %
    if isfield(equilDKE.screening,'elastic') && ~isempty(equilDKE.screening.elastic)
        %
        gfp = [];
        %
        if length(equilDKE.Znucleus) > 3 %some impurities are present in the plasma
            %
            for iZimp = 1:length(equilDKE.Znucleus)-3 % loop on all species
                %
                gfp = [gfp,gfp_yp(prel,equilDKE.Znucleus(iZimp+3),equilDKE.screening.elastic,equilDKE.screening.dftpath)];%elastic screening function
                %
            end
            %
            if ~isempty(gfp)
                %
                gfp = [zeros(length(prel),3),gfp];%add three hydrogen isotope fully ionized
                %
            else
                %
                gfp = 0;
                %
            end
            %    
        else
            gfpn = 0;%hydrogen alone which is fully ionized
        end
        %
        gfpn = gfp/xlnc_e(ir);%normalisation by the collision frequency
        %
    else
        gfpn = 0;%screening is not considered
    end
    %
else
    %
    gfpn = 0;
    %
end
%
if isfield(equilDKE,'coulog_model') && ~isempty(equilDKE.coulog_model)
    %
    [~,~,~,xpcleirel] = coulomb_logarithm_yp(equilDKE.coulog_model,equilDKE.xne,equilDKE.xTe,prel);
    %~
    xpcleireln = xpcleirel./(xlnc_e*ones(1,length(prel)));
    %
else
    %
    [~,xcleith,~,~] = coulomb_logarithm_yp(1,equilDKE.xne,equilDKE.xTe,prel);%LUKE backward compatibility
    xpcleireln = (xcleith*ones(1,length(prel)))./(xlnc_e*ones(1,length(prel)));%no momentum dependence
    %
end
%
if isempty(gfpn)
    gfpn = 0;
end
%
%gfpn = 0;
%
if dkeparam.coll_mode == 1 %High-velocity limit
    %
    xx0 = xpcleireln(ir,:)'*equilDKE.zZi.^2 + gfpn;
    xx1 = ones(length(v),1)*xzni_norm(:,ir)';
    xx2 = ones(length(v),1)*(me./equilDKE.zmi).*xzni_norm(:,ir)';
    xx3 = ones(length(v),1)*(me./equilDKE.zmi).*xzni_norm(:,ir)'.*xzTi_norm(:,ir)';
    %
    Fei = sum(xx0'.*xx2',1)./v2;
    Aei = sum(xx0'.*xx3',1)./v./v2;
    Btei = sum(xx0'.*xx1',1)./v/2 - sum(xx0'.*xx3',1)./v./v2/2;
    %
	%Fei = sum((equilDKE.zZi.^2.*coulog).*(me./equilDKE.zmi).*xzni_norm(:,ir)')./v2;
	%Aei = sum((equilDKE.zZi.^2.*coulog).*(me./equilDKE.zmi).*xzni_norm(:,ir)'.*xzTi_norm(:,ir)')./v./v2;
	%Btei = sum((equilDKE.zZi.^2.*coulog).*xzni_norm(:,ir)')./v/2 - sum(equilDKE.zZi.^2.*xzni_norm(:,ir)'.*(me./equilDKE.zmi).*xzTi_norm(:,ir)')./v./v2/2;
    %
elseif dkeparam.coll_mode == 3 | dkeparam.coll_mode == 5 %Lorentz collision model (large zZi, zmi -> Inf, zxTi_norm = 0)
    %
    xx0 = xpcleireln(ir,:)'*equilDKE.zZi.^2 + gfpn;
    xx1 = ones(length(v),1)*xzni_norm(:,ir)';
    %
    Fei = zeros(size(v));
    Aei = zeros(size(v));
    Btei = sum(xx0'.*xx1',1)./v/2;
    %
    %Fei = zeros(size(v));
    %Aei = zeros(size(v));
    %Btei = sum((((equilDKE.zZi.^2.*cl + ion_screening)'.*xzni_norm(:,ir))*ones(1,length(v))))./v/2;
    %
else %Non-relativistic Maxwellian background
    %
    xzTi_norm(find(xzTi_norm(:,ir)==0),ir) = eps;%To remove singularities when Ti = 0 exactly
    %
	u = (ones(size(xzTi_norm(:,ir)))*v)./(sqrt(xzTi_norm(:,ir).*(me./equilDKE.zmi'))*ones(1,length(v)))./sqrt(2);
    %
    xx0 = xpcleireln(ir,:)'*equilDKE.zZi.^2 + gfpn;
    xx1 = ones(length(v),1)*xzni_norm(:,ir)';
    xx2 = ones(length(v),1)*(me./equilDKE.zmi).*xzni_norm(:,ir)';
    %
    Fei = sum(xx0'.*xx2'.*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi)),1)./v2;
    Aei = sum(xx0'.*xx1'.*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi))./u./u,1)./v/2;
    Btei = sum(xx0'.*xx1'.*((2-1./u./u).*erf(u) + 2*exp(-u.^2)./u/sqrt(pi)),1)./v/4;
    %
    %Fei = sum((((equilDKE.zZi'.^2.*coulog + gfp).*(me./equilDKE.zmi').*xzni_norm(:,ir))*ones(1,length(v))).*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi)))./v2;
  	%Aei = sum((((equilDKE.zZi'.^2.*coulog + gfp).*xzni_norm(:,ir))*ones(1,length(v))).*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi))./u./u)./v/2;	
  	%Btei = sum((((equilDKE.zZi'.^2.*coulog + gfp).*xzni_norm(:,ir))*ones(1,length(v))).*((2-1./u./u).*erf(u) + 2*exp(-u.^2)./u/sqrt(pi)))./v/4;
    %
end