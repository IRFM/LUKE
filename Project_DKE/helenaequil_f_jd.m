function helenaequil_f_jd(tokamak,npsi,savename)
%
%   This function generates the data file of an equilibrium based on
%   the information stored in ptok_dke_1yp and the magnetic geometry
%   obtained from the helena MHD code.
%
%   INPUTS:
%
%       - tokamak: tokamak scenario selected (in ptok_dke_1yp)
%       - npsi: number of magnetic flux surfaces (ntheta is fixed in helena)
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
%   By J. Decker <jodecker@mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%
if nargin < 1,error('not enough arguments');end
if nargin < 2,
	npsi = 201;
	savename = tokamak;
end
if nargin < 3,savename = tokamak;end
%
ppsin = linspace(0,1,npsi);%Uniform normalized magnetic flux surface grid
%
[ap,Rp,Zp,elong,triang_up,triang_down,Bt,...
	 Ip,j0,ja,ej,qmin,eq,...
	 Te0,Tea,eTe,ne0,nea,ene,Ti0,Tia,eTi,...
	 Zi,mi,fi,Zeff0,Zeffa,eZeff] = ptok_dke_1yp(tokamak);        
%
zZi = Zi;%[1,ni]
zmi = mi;%[1,ni]
%
% Plasma parameters
%
pTe = (Te0 - Tea)*(1 - ppsin.^2).^eTe + Tea;%Electron temperature (keV)
pne = (ne0 - nea)*(1 - ppsin.^2).^ene + nea;%Electron density (m-3)
pTi = (Ti0 - Tia)*(1 - ppsin.^2).^eTi + Tia;%Ion temperatures (keV)
%
pZeff = (Zeff0 - Zeffa)*(1 - ppsin.^2).^eZeff + Zeffa;% Effective charge (a.u.)
%
% Ion parameters
%
nz = length(zZi);
pzTi = repmat(pTi,[nz,1]);% Same temperature for all ion species
pzni = zeros(nz,npsi);
%
if sum(zZi>1) > 1,% More than one impurity species
	 % need each species density (***** to be implemented *****)
elseif sum(zZi>1) == 1,% One impurity species
	 Zimp = max(zZi);
	 pnhyd = pne.*(Zimp - pZeff)/(Zimp - 1);  
	 pnimp = pne.*(pZeff - 1)/(Zimp - 1)/Zimp;
	 pzni(nz,:) = pnimp;
else,% No impurity
	 pnhyd = pne;
	 pnimp = 0*pne;
end
if sum(fi) == 1
	 pzni(1:3,:) = fi'*pnhyd;
else
	 error('Hydrogen isotopic fractions do not add to 1')
end    
%
%Run HELENA magnetic equilibrium code (FORTRAN MEX file)
%
[s,dossier,machine,mexext] = comput_dke_yp;
ls helena
if exists(['helena/helmex77',mexext]) == 2,
	ptot = pTe.*pne + sum(pzni.*pzTi);%Total plasma pressure profile
	pj = (j0 - ja)*(1 - ppsin.^2).^ej + ja;%Current density profile
	if (triang_up == triang_down),
		lsc = 0;
	else
		lsc = 1;
	end
	
	[C2,C3,rho2m,R,Z,rho,Vp,drhoor,qpsi,psipout,ftra,Fdia,psiT,B2,invB2,Sp, ...
	   rav,oor,drhoav,xshift,xrad,xell,xtriapos,xtrianeg,jout,iout,pout, ...
	   r2,oor2,r2tau2,drho2ob2,r3otau3,r3otau,BPR,BPZ,b,df2,kkbig,li, ...
	   dimerc,drmerc,balcrit,ifail]=...
	   helmex77(psipin',ptot',pj',Rp,Bt,Ip*1e6,lsc,ap,elong,triang_up,triang_down,Rext,Zext,0,b,df2,kkbig,ecrit);
	   
	   
	   %%%%%%%% a finir %%%%%%%%%%%%
%
	filename = ['EQUIL_',savename,'.mat'];
%
	eval(['save ',dossier,s,filename,' ppsi theta R Z BR BZ BPHI pTe pne pzTi pzni zZi zmi'])   
else
	error(['The mexfile helmex77',mexext,' does not exists ! Compile it for the computer you are using...']);
end





