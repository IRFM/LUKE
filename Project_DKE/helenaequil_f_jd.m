function filename = helenaequil_f_jd(tokamak,qopt,savename)
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
%   By J. Decker <jodecker@mit.edu>, Y. Peysson <yves.peysson@cea.fr> and V. Basiuk <vincent.basiuk@cea.fr>
%
if nargin < 1,error('Not enough arguments');end
if nargin < 2,
	qopt = 1;
	savename = tokamak;
end
if nargin < 3,
	savename = tokamak;
end
%
if nargin < 4,savename = tokamak;end
%
[ap,Rp,Zp,elong,triang_up,triang_down,Bt,...
	 Ip,j0,ja,ej,qmin,eq,...
	 Te0,Tea,eTe,ne0,nea,ene,Ti0,Tia,eTi,...
	 Zi,mi,fi,Zeff0,Zeffa,eZeff] = ptok_dke_1yp(tokamak);        
%
% Initial calculations to set up the guess for HELENA
%
npsi_guess = 201;%For initial profile calculations
Bpa = (4*pi*1e-7)*Ip*1e6/(2*pi*ap);% Poloidal Field at the edge, Ampere's theorem (circular plasma cross-section for the initial guess)	
qmax = ap/Rp*Bt/Bpa;%Cylindrical safety factor at the plasma edge
%
prho_guess = linspace(0,1,npsi_guess);%Initial grid
if qopt == 1,
	 pq_guess = (qmax - qmin)*prho_guess.^eq + qmin;% Current profile defined by qmin and eq
else 
	 pq_guess = qmax*ones(1,npsi_guess);% Current profile defined with constant q (uniform current density)
end
pBpp_guess = prho_guess*ap/Rp*Bt./pq_guess;
%
spBpp_guess = triu(repmat((pBpp_guess(1:npsi_guess-1) + pBpp_guess(2:npsi_guess))'/2,[1,npsi_guess-1]));
pdprho_guess = diff(prho_guess);
ppsi_guess = [0,2*pi*ap*Rp*integral_dke_jd(pdprho_guess,spBpp_guess,1)'];
ppsin_guess = ppsi_guess/max(ppsi_guess);%Uniform normalized magnetic flux surface grid
%
zZi = Zi;%[1,ni]
zmi = mi;%[1,ni]
%
% Plasma parameters
%
pTe_guess = (Te0 - Tea)*(1 - ppsin_guess.^2).^eTe + Tea;%Electron temperature (keV)
pne_guess = (ne0 - nea)*(1 - ppsin_guess.^2).^ene + nea;%Electron density (m-3)
pTi_guess = (Ti0 - Tia)*(1 - ppsin_guess.^2).^eTi + Tia;%Ion temperatures (keV)
%
pZeff_guess = (Zeff0 - Zeffa)*(1 - ppsin_guess.^2).^eZeff + Zeffa;% Effective charge (a.u.)
%
% Ion parameters
%
pzTi_guess = repmat(pTi_guess,[length(zZi),1]);% Same temperature for all ion species
pzni_guess = species_dke_yp(pne_guess,pZeff_guess,zZi,fi);
%
%Run HELENA magnetic equilibrium code (FORTRAN MEX file). 
%
[s,dossier,machine,mexext] = comput_dke_yp;
if exist(['helmex77',mexext]) == 3,
	ptot_guess = pTe_guess.*pne_guess + sum(pzni_guess.*pzTi_guess);%Total plasma pressure profile
	pj_guess = (j0 - ja)*(1 - ppsin_guess.^2).^ej + ja;%Current density profile
%
	if (triang_up == triang_down),
		lsc = 0;
	else
		lsc = 1;
	end
%
	npsi = 101;%ONLY 101 radial profile grid points for HELENA
	ntheta = 65;%ONLY 65 poloidal grid points for HELENA
%
	ppsi_in = interp1(1:npsi_guess,ppsi_guess,linspace(1,201,101));%ONLY 101 radial profile grid points for HELENA
	ptot_in = interp1(1:npsi_guess,ptot_guess,linspace(1,201,101));%ONLY 101 radial profile grid points for HELENA
	pj_in = interp1(1:npsi_guess,pj_guess,linspace(1,201,101));%ONLY 101 radial profile grid points for HELENA 

	[C2,C3,rho2m,R,Zout,rho,Vp,drhoor,qpsi,ppsi,ftra,Fdia,psiT,B2,invB2,Sp, ...
	   rav,oor,drhoav,xshift,xrad,xell,xtriapos,xtrianeg,jout,iout,pout, ...
	   r2,oor2,r2tau2,drho2ob2,r3otau3,r3otau,BR,BZ,b,df2,kkbig,li, ...
	   dimerc,drmerc,balcrit,ifail]=...
	   helmex77(ppsi_in,ptot_in,pj_in,Rp,Bt,Ip*1e6,lsc,ap,elong,triang_up,triang_down,zeros(1,101),zeros(1,101),0,[],[],[],2);
%	  
		BPHI = (Fdia*ones(1,ntheta))./R;
%
		ap_helena = R(npsi,1) - R(1,1);
		Rp_helena = R(1,1);
		Bt_helena = BPHI(1,1);
		disp(' ');
		if ap_helena ~= ap
			 disp(['Minor radius from ptok (guess): ',num2str(ap),', from HELENA (kept): ',num2str(ap_helena)])
			 ap = ap_helena;clear pap
		end
		if Rp_helena ~= Rp
			 disp(['Major radius from ptok (guess): ',num2str(Rp),', from HELENA (kept): ',num2str(Rp_helena)])
			 Rp = Rp_helena;clear pRp
		end
		if Bt_helena ~= Bt
			 disp(['Magnetic field on axis from ptok (guess): ',num2str(Bt),', from HELENA (kept): ',num2str(Bt_helena)])
			 Bt = Bt_helena;clear pBt
		end
%
		ppsi = ppsi/2/pi;%In order to match the defintion of ppsi in DKE
		ppsin = ppsi'/max(ppsi);%Normalized flux grid
		theta = linspace(0,2*pi,ntheta);% uniform theta grid
%
%Plasma parameters
%
		pTe = (Te0 - Tea)*(1 - ppsin.^2).^eTe + Tea;%Electron temperature (keV)
		pne = (ne0 - nea)*(1 - ppsin.^2).^ene + nea;%Electron density (m-3)
		pTi = (Ti0 - Tia)*(1 - ppsin.^2).^eTi + Tia;%Ion temperatures (keV)
		%
		pZeff = (Zeff0 - Zeffa)*(1 - ppsin.^2).^eZeff + Zeffa;%Effective charge (a.u.)
%
%Ion parameters
%
		pzTi = repmat(pTi,[length(zZi),1]); %same temperature for all ion species
		pzni = species_dke_yp(pne,pZeff,zZi,fi);
%
		Z = Zout + Zp;%HELENA calculate magnetic equilibrium at Zp = 0. The vertical shift of the magnetic flux surfaces must be added after HELENA calculations  
%		
		filename = ['EQUIL_',savename,'.mat'];
%
	eval(['save ',dossier,s,filename,' ppsi theta R Z BR BZ BPHI pTe pne pzTi pzni zZi zmi ftra'])   
else
	error(['The mexfile helmex77',mexext,' does not exists ! Compile it for the computer you are using...']);
end





