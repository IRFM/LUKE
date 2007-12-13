function [Fei,Aei,Btei] = eicoll_dke_yp(v,zZi,zmi,xzni_norm,xzTi_norm,ir,coll_mode)
%
%Electron-ion collision operator (non-relativistic limit)
%
%By Joan Decker (MIT-RLE) and Yves Peysson (CEA-DRFC,yves.peysson@cea.fr)
%	
if nargin < 7,
	error('Wrong number of input arguments in eicoll_dke_yp')
end
%
me = 1/1860;%Electron rest mass (u.m.a. units)
v2 = v.*v;
%
if coll_mode == 1,%High-velocity limit
	Fei = sum(zZi.^2.*(me./zmi).*xzni_norm(:,ir)')./v2;
	Aei = sum(zZi.^2.*(me./zmi).*xzni_norm(:,ir)'.*xzTi_norm(:,ir)')./v./v2;
	Btei = sum(zZi.^2.*xzni_norm(:,ir)')./v/2 - sum(zZi.^2.*xzni_norm(:,ir)'.*(me./zmi).*xzTi_norm(:,ir)')./v./v2/2;
elseif coll_mode == 3,%Lorentz model 
	Fei = zeros(size(v));
	Aei = zeros(size(v));
	Btei = ones(size(v))/2;
elseif coll_mode == 5,%Ultrarelativistic Moller model
   Fei = zeros(size(v));
   Aei = zeros(size(v));
   Btei = sum(((zZi'.^2.*xzni_norm(:,ir))*ones(1,length(v))))./v/2;
else,%Maxwellian background (non-relativistic limit)
    iu = find(xzTi_norm(:,ir)==0);%To remove singularities when Ti = 0 exactly
	u = (ones(size(xzTi_norm(:,ir)))*v)./(sqrt(xzTi_norm(:,ir).*(me./zmi'))*ones(1,length(v)))./sqrt(2);
	u(iu,:) = 0.1;zZi(iu) = 0;
	Fei = sum(((zZi'.^2.*(me./zmi').*xzni_norm(:,ir))*ones(1,length(v))).*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi)))./v2;
	Aei = sum(((zZi'.^2.*xzni_norm(:,ir))*ones(1,length(v))).*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi))./u./u)./v/2;	
	Btei = sum(((zZi'.^2.*xzni_norm(:,ir))*ones(1,length(v))).*((2-1./u./u).*erf(u) + 2*exp(-u.^2)./u/sqrt(pi)))./v/4;
end