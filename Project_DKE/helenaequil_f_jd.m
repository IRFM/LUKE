function helenaequil_f_jd(helenafilename,tokamak,savename)
%
%   This function generates the data file of an equilibrium based on
%   the information stored in ptok_dke_1yp and the magnetic geometry
%   obtained from the helena MHD code.
%
%   INPUTS:
%
%       - helenafilename: magnetic equilibrium from helena
%       - tokamak: tokamak scenario selected (in ptok_dke_1yp)
%       - savename: file name for storing the equilibrium 
%           (default: same as tokamak)
%
%   NOTE: 
%
%       - The non-magnetic profiles are obtained from the profile
%       parameters of ptok_dke_1yp, using the profile coordinate rho
%       derived from the magnetic geometry as rho = (R - Rp)/(Rmax - Rp)
%       taken on the outboard midplane.
%
%   By J. Decker <jodecker@alum.mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%   Created April 30, 2004
%
if nargin < 2
	error('not enough arguments');
end
if nargin < 3
	savename = tokamak;
end
%
psi = 0;
%
eval(['load ',helenafilename]);
[npsi,ntheta] = size(R);
clear j q rhoRZ x %we don't account for these data yet because so far we have not checked their consistency.
%                  they will be derived from the geometry of the magnetic equilibrium 
ppsi = psi-psi(1);
%
[ap,Rp,Ip,Bt,Ncoils,Zi,mi,fi,BeLi,...
	qmin,eq,Te0,Tea,eTe,eTe_ref,...
	ne0,nea,ene,ene_ref,Ti0,Tia,eTi,Zeff0,Zeffa,eZeff] = ...
		ptok_dke_1yp(tokamak);
clear eTe_ref ene_ref Ip qmin eq   
%
zZi = Zi;%[1,ni]
zmi = mi;%[1,ni]
clear Zi mi
%
pap = R(npsi,1) - R(1,1);
pRp = R(1,1);
pBt = BPHI(1,1);
if pap ~= ap
    disp(['minor radius from ptok: ',num2str(ap),', from helena (kept): ',num2str(pap)])
    ap = pap;clear pap
end
if pRp ~= Rp
    disp(['major radius from ptok: ',num2str(Rp),', from helena (kept): ',num2str(pRp)])
    Rp = pRp;clear pRp
end
if pBt ~= Bt
    disp(['magnetic field on axis from ptok: ',num2str(Bt),', from helena (kept): ',num2str(pBt)])
    Bt = pBt;clear pBt
end

prho = (R(:,1) - R(1,1))'/ap;% rho grid
theta = linspace(0,2*pi,ntheta);% uniform theta grid
%
%Plasma parameters
%
pTe = (Te0 - Tea)*(1 - prho.^2).^eTe + Tea;%Electron temperature (keV)
pne = (ne0 - nea)*(1 - prho.^2).^ene + nea;%Electron density (m-3)
pTi = (Ti0 - Tia)*(1 - prho.^2).^eTi + Tia;%Ion temperatures (keV)
%
pZeff = (Zeff0 - Zeffa)*(1 - prho.^2).^eZeff + Zeffa;%Effective charge (a.u.)
%
%Ion parameters
%
nz = length(zZi);
pzTi = repmat(pTi,[nz,1]); %same temperature for all ion species
pzni = zeros(nz,npsi);
%
if sum(zZi>1) > 1 %More than one impurity species
    % need each species density
elseif sum(zZi>1) == 1 % One impurity species
    Zimp = max(zZi);
    pnhyd = pne.*(Zimp - pZeff)/(Zimp - 1);  
    pnimp = pne.*(pZeff - 1)/(Zimp - 1)/Zimp;
    pzni(nz,:) = pnimp;
else % No Impurity
    pnhyd = pne;
    pnimp = 0*pne;
end
if sum(fi) == 1
    pzni(1:3,:) = fi'*pnhyd;
else
    error('Hydrogen isotopic fractions do not add to 1')
end   
clear fi
%
filename = ['EQUIL_',savename,'.mat'];
%
eval(['save ',filename,' ppsi theta R Z BR BZ BPHI pTe pne pzTi pzni zZi zmi Ncoils BeLi'])
