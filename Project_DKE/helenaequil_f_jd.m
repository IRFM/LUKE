function filename = helenaequil_f_jd(tokamak,qopt,npsi,savename)
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
if nargin < 1,error('Not enough arguments');end
if nargin < 2,
	qopt = 1;
	npsi = 201;
	savename = tokamak;
end
if nargin < 3,
	npsi = 201;
	savename = tokamak;
end

if nargin < 4,savename = tokamak;end
%
[ap,Rp,Zp,elong,triang_up,triang_down,Bt,...
	 Ip,j0,ja,ej,qmin,eq,...
	 Te0,Tea,eTe,ne0,nea,ene,Ti0,Tia,eTi,...
	 Zi,mi,fi,Zeff0,Zeffa,eZeff] = ptok_dke_1yp(tokamak);        
%
% Initial calculations to set up the guess for HELENA
%
Bpa = (4*pi*1e-7)*Ip*1e6/(2*pi*ap);% Poloidal Field at the edge, Ampere's theorem (circular plasma cross-section for the initial guess)	
qmax = ap/Rp*Bt/Bpa;%Cylindrical safety factor at the plasma edge
%
prho = linspace(0,1,npsi);%Initial grid
if qopt == 1,
	 pq = (qmax - qmin)*prho.^eq + qmin;% Current profile defined by qmin and eq
else 
	 pq = qmax*ones(1,npsi);% Current profile defined with constant q (uniform current density)
end
pBpp = prho*ap/Rp*Bt./pq;
%
spBpp = triu(repmat((pBpp(1:npsi-1) + pBpp(2:npsi))'/2,[1,npsi-1]));
pdprho = diff(prho);
ppsi = [0,2*pi*ap*Rp*integral_dke_jd(pdprho,spBpp,1)'];
ppsin = ppsi/max(ppsi);%Uniform normalized magnetic flux surface grid
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
pzni = species_dke_yp(pne,pZeff,zZi,fi);
%
%Run HELENA magnetic equilibrium code (FORTRAN MEX file)
%
[s,dossier,machine,mexext] = comput_dke_yp;
if exist(['helmex77',mexext]) == 3,
	ptot = pTe.*pne + sum(pzni.*pzTi);%Total plasma pressure profile
	pj = (j0 - ja)*(1 - ppsin.^2).^ej + ja;%Current density profile
%
	if (triang_up == triang_down),
		lsc = 0;
	else
		lsc = 1;
	end
%
dbstop 109
	[C2,C3,rho2m,R,Zout,rho,Vp,drhoor,qpsi,psipout,ftra,Fdia,psiT,B2,invB2,Sp, ...
	   rav,oor,drhoav,xshift,xrad,xell,xtriapos,xtrianeg,jout,iout,pout, ...
	   r2,oor2,r2tau2,drho2ob2,r3otau3,r3otau,BR,BZ,b,df2,kkbig,li, ...
	   dimerc,drmerc,balcrit,ifail]=...
	   helmex77(ppsi',ptot',pj',Rp,Bt,Ip*1e6,lsc,ap,elong,triang_up,triang_down,zeros(250,1),zeros(250,1),0,[],[],[],[]);
%
%
%	  
		BPHI = Fdia./R;
%
		ap_helena = R(npsi,1) - R(1,1);
		Rp_helena = R(1,1);
		Bt_helena = BPHI(1,1);
		if ap_helena ~= ap
			 disp(['Minor radius from ptok (guess): ',num2str(ap),', from HELENA (kept): ',num2str(ap_helena)])
			 ap = ap_helena;clear pap
		end
		if Rp_helena ~= Rp
			 disp(['major radius from ptok (guess): ',num2str(Rp),', from HELENA (kept): ',num2str(Rp_helena)])
			 Rp = Rp_helena;clear pRp
		end
		if Bt_helena ~= Bt
			 disp(['magnetic field on axis from ptok (guess): ',num2str(Bt),', from helena (kept): ',num2str(Bt_helena)])
			 Bt = Bt_helena;clear pBt
		end
%
		prho = (R(:,1) - R(1,1))'/ap;%Normalized rho grid
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
		pzni = species_dke_yp(pne,pZeff,zZi,fi);
%
		Z = Zout + Zp;%HELENA calculate magnetic equilibrium at Zp = 0. The vertical shift of the magnetic flux surfaces must be added after HELENA calculations  
%
	filename = ['EQUIL_',savename,'.mat'];
%
	eval(['save ',dossier,s,filename,' ppsi theta R Z BR BZ BPHI pTe pne pzTi pzni zZi zmi'])   
else
	error(['The mexfile helmex77',mexext,' does not exists ! Compile it for the computer you are using...']);
end





