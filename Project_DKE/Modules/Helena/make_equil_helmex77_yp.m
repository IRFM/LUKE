function [equil] = make_equil_helmex77_yp(helmex77param,display_opt)
%
%   Create a magnetic equilibrium structure for C3PO/LUKE using HELENA code
%   (mex file version)
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM,joan.decker@cea.fr)
%
if nargin == 1,
    display_opt = 0;
end
%
equil.id = helmex77param.id;% scenario identification
%
id_path = helmex77param.id_path;%For all paths used by DKE solver
path_path = helmex77param.path_path;%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
dkepath = load_structures_yp('dkepath',id_path,path_path);
%
% Equilibrium parameters
%
ap_guess = helmex77param.ap_guess;%  Plasma minor radius on LFS midplane (m)
Rp_guess = helmex77param.Rp_guess;%  Plasma major radius on axis (m)
Zp_guess = helmex77param.Zp_guess;%  Global plasma vertical shift (m)
%
xpoint(1) = helmex77param.xpoint(1);%Vertical position of the top X point
xpoint(2) = helmex77param.xpoint(2);%Horizontal position of the top X point
xpoint(3) = helmex77param.xpoint(3);%Angle between the separatrix and the horizontal plane for the top X point (degree)
xpoint(4) = helmex77param.xpoint(4);%Angle between the separatrix and the horizontal plane for the top X point (degree)
xpoint(5) = helmex77param.xpoint(5);%Vertical position of the bottom X point (always positive value)
xpoint(6) = helmex77param.xpoint(6);%Horizontal position of the bottom X point
xpoint(7) = helmex77param.xpoint(7);%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
xpoint(8) = helmex77param.xpoint(8);%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%
npsi_guess = helmex77param.npsi_guess;%For initial profile calculations
ntheta_guess = helmex77param.ntheta_guess;%Number of poloidal positions for the guessed separatrix
npsi = helmex77param.npsi;%ONLY 101 radial profile grid points for HELMEX77
ntheta = helmex77param.ntheta;%ONLY 65 poloidal grid points for HELMEX77
%
Ip = helmex77param.Ip;%  Plasma current (MA)  
%
qmin = helmex77param.qmin;%  Safety factor q0 at plasma center
eq = helmex77param.eq;%  Exponent for q radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calaculated by the Ampere's theorem at the plasma edge with a circular plasma cross-section)
qopt = helmex77param.qopt;%Option for q profile. (0): constant (default, uniform current, psi=rho^2), (1): from qmin and eq 
%
Bt = helmex77param.Bt;%  Toroidal magnetic field on the magnetic axis (T) 
%
Zi = helmex77param.Zi;%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
mi = helmex77param.mi;%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
fi = helmex77param.fi;%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
Te0 = helmex77param.Te0;%  Core electron temperature (keV)
dTea = helmex77param.dTea;%  Edge electron temperature parameter
eTe1 = helmex77param.eTe1;%  Exponent #1 for Te profile 
eTe2 = helmex77param.eTe2;%  Exponent #1 for Te profile 
%
ne0 = helmex77param.ne0;%  Core electron density (m-3)
dnea = helmex77param.dnea;%  Edge electron density parameter
ene1 = helmex77param.ene1;%  Exponent #1 for ne profile 
ene2 = helmex77param.ene2;%  Exponent #2 for ne profile
%
Ti0 = helmex77param.Ti0;%  Core ion temperature (keV)
dTia = helmex77param.dTia;%  Edge ion temperature (keV)
eTi1 = helmex77param.eTi1;%  Exponent #1 for Ti profile
eTi2 = helmex77param.eTi2;%  Exponent #1 for Ti profile
%
Zeff0 = helmex77param.Zeff0;%  Core effective charge (a.u.)
Zeffa = helmex77param.Zeffa;%  Edge effective charge (a.u.)
eZeff = helmex77param.eZeff;%  Define the slope at the radial point where the derivative is maximum (must be >> 1)
xZeff = helmex77param.xZeff;%Radial normalized position at which the derivative is maximum
%
%**************************************************************************************************
%
%
% Initial calculations to set up the guess for HELMEX77
%
Bpa = (4*pi*1e-7)*Ip*1e6/(2*pi*ap_guess);% Poloidal Field at the edge, Ampere's theorem (circular plasma cross-section for the initial guess)	
qmax = ap_guess/Rp_guess*Bt/Bpa;%Cylindrical safety factor at the plasma edge
%
prho_guess = linspace(0,1,npsi_guess);%Initial grid
%
if qopt == 1,
	 pq_guess = (qmax - qmin)*prho_guess.^eq + qmin;% Current profile defined by qmin and eq
	 pdq_guess = eq*(qmax - qmin)*prho_guess.^(eq-1);
else 
	 pq_guess = qmax*ones(1,npsi_guess);% Current profile defined with constant q (uniform current density)
	 pdq_guess = zeros(1,npsi_guess);
end
%
pBpp_guess = prho_guess*ap_guess/Rp_guess*Bt./pq_guess;
%
spBpp_guess = triu(repmat((pBpp_guess(1:npsi_guess-1) + pBpp_guess(2:npsi_guess))'/2,[1,npsi_guess-1]));
pdprho_guess = diff(prho_guess);
ppsi_guess = [0,2*pi*ap_guess*Rp_guess*integral_dke_jd(pdprho_guess,spBpp_guess,1)'];
ppsin_guess = ppsi_guess/max(ppsi_guess);%Uniform normalized magnetic flux surface grid
%
zZi = Zi;%[1,ni]
zmi = mi;%[1,ni]
%
% Plasma parameters
%
pTe_guess = Te0*((1 - dTea)*(1 - ppsin_guess.^eTe1).^eTe2 + dTea);%Electron temperature (keV)
pne_guess = ne0*((1 - dnea)*(1 - ppsin_guess.^ene1).^ene2 + dnea);%Electron density (m-3)
pTi_guess = Ti0*((1 - dTia)*(1 - ppsin_guess.^eTi1).^eTi2 + dTia);%Ion temperatures (keV)
%
pZeff_guess = 0.5*(Zeffa - Zeff0)*tanh(eZeff*(ppsin_guess - xZeff)) + 0.5*(Zeffa + Zeff0);% Effective charge (a.u.)
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
	pj_guess = 2*Bt./pq_guess/(4*pi*1e-7)/Rp_guess - Bt*pdq_guess.*prho_guess./pq_guess.^2/(4*pi*1e-7)/Rp_guess;
%	
%	figure(1),plot(prho_guess,pj_guess)
%	figure(2),plot(prho_guess,pBpp_guess)
%	figure(3),plot(prho_guess,pq_guess) 
%	figure(4),plot(prho_guess,ppsin_guess)
%	 
    Ip_guess= 2*pi*trapz_dke_yp([prho_guess(:),prho_guess(:).*pj_guess(:)])*ap_guess*ap_guess;  
%
    lim_top = atan(0.5*xpoint(1)/(1-xpoint(2)))*180/pi;%In order to avoid convergence problem in separatrix MEX file
	if xpoint(4) > lim_top,xpoint(4) = lim_top - 0.1;end
	lim_bottom = atan(0.5*xpoint(5)/(1-xpoint(6)))*180/pi;%In order to avoid convergence problem in separatrix MEX file
	if xpoint(8) > lim_bottom,xpoint(8) = lim_bottom - 0.1;end
%
	[x1,y1] = separatrice(xpoint,1);%The LCS is approximated by four ellipses (mode = 1)

	rr = x1*ap_guess;
	zz = y1*ap_guess;
	alpha  = unwrap(angle(rr+ i .* zz));%poloidal angle
	if alpha(end) < -5
		alpha = alpha - alpha(end);
	end
%
	theta_sep  = linspace(0,2*pi,ntheta_guess);% poloidal points
	ind = find(diff(alpha) == 0);
	alpha(ind) = [];
	rr(ind) = [];
	zz(ind) = [];
%    
	R_sep0 = spline(alpha',rr',theta_sep) + Rp_guess;%resampling 
	Z_sep0 = spline(alpha',zz',theta_sep) + Zp_guess;%resampling 
%   
    if display_opt ~= 0,
        figure('Name','JETh77 separatrix')
        [ax] = graph1D_jd(R_sep0 - Rp_guess,Z_sep0 - Zp_guess,0,0,'R - R_{p} (m)','Z - Z_{p} (m)','JETh77 separatrix',NaN,'','','--','none','b',2);
        axis('equal')
        zoom on
    end
%
% For the input to HELENA
%
 %
   ap_in = ap_guess;
   Rp_in = Rp_guess;
   Zp_in = Zp_guess;
   R_in = R_sep0;
   Z_in = Z_sep0 - Zp_in;%because HELENA work only at Zp = 0.
%
    Bt_in = Bt;
%
	ppsi_in = interp1(1:npsi_guess,ppsi_guess,linspace(1,ntheta_guess,npsi));
	ptot_in = interp1(1:npsi_guess,ptot_guess,linspace(1,ntheta_guess,npsi));
	pj_in = interp1(1:npsi_guess,pj_guess,linspace(1,ntheta_guess,npsi)); 
%
    init = [0,1e-3,1e-7];%Second argument is the accuracy on the current, the third on the global equilibrium
%
	absBt_in = abs(Bt_in);%The toroidal magnetic field must be always positive for helmex77
    absIp = abs(Ip);%The plasma current must be positive for helmex77 so that the current output is correctly normalized
%
 	[C2,C3,rho2m,R,Zout,rho,Vp,drhoor,qpsi,ppsi,ftra,Fdia,psiT,B2,invB2,Sp, ...
			rav,oor,drhoav,xshift,xrad,xell,xtriapos,xtrianeg,jout,ipout,pout, ...
			r2,oor2,r2tau2,drho2ob2,r3otau3,r3otau,BR,BZ,b,df2,dpr,kkbig,li, ...
			dimerc,drmerc,balcrit,frmode,ifail,nchi,cpsurf,radius,gem11,gem12,gem33,rspot,zspot,brspot,bzspot]= ...
			helmex77(ppsi_in,ptot_in,pj_in*1e6,Rp_in,absBt_in,absIp*1e6,2,ap_in,0,0,0,R_in,Z_in,init,0,0*ppsi_in,[],2);
%
	[qe,me,mp,mn,e0,mu0] = pc_dke_yp;
	Ip_helmex = ipout.* max(xrad).*absBt_in/mu0*1e-6*sign(Ip);%For test only (MA)
%	  
	BPHI = (Fdia*ones(1,ntheta))./R*sign(Bt_in);%Recover also the correct sign
    BR(1,:) = 0;%avoid problems at the plasma center. BR must be zero exactly (sometimes spurious values)
    BZ(1,:) = 0;%avoid problems at the plasma center. BZ must be zero exactly (sometimes spurious values)
	BR = BR*sign(Ip);%Recover also the correct sign
	BZ = BZ*sign(Ip);%Recover also the correct sign
	ppsi = ppsi*sign(Ip);%Recover also the correct sign  
%    
	ap_helmex = R(npsi,1) - R(1,1);
	Rp_helmex = R(1,1);
	Bt_helmex = BPHI(1,1);
%
    if display_opt ~= 0,
        disp('------------------------------------------------------');
        disp(['Minor radius from ptok (in): ',num2str(ap_in),', from HELMEX77 (kept): ',num2str(ap_helmex)])
        disp(['Major radius from ptok (in): ',num2str(Rp_in),', from HELMEX77 (kept): ',num2str(Rp_helmex)])
        disp(['Plama current (in): ',num2str(Ip_guess/1e6),', from HELMEX77 (kept): ',num2str(Ip_helmex)])
        disp(['Magnetic field on axis from ptok (in): ',num2str(Bt_in),', from HELMEX77 (kept): ',num2str(Bt_helmex)])
        disp('------------------------------------------------------');
    end
%
	ppsi = ppsi/2/pi;%In order to match the defintion of ppsi in DKE
	ppsin = ppsi'/max(ppsi);%Normalized flux grid
	theta = linspace(0,2*pi,ntheta);% uniform theta grid
%
%Plasma parameters
%
	pTe = Te0*((1 - dTea)*(1 - ppsin.^eTe1).^eTe2 + dTea);%Electron temperature (keV)
    pne = ne0*((1 - dnea)*(1 - ppsin.^ene1).^ene2 + dnea);%Electron density (m-3)
    pTi = Ti0*((1 - dTia)*(1 - ppsin.^eTi1).^eTi2 + dTia);%Ion temperatures (keV)
%
    pZeff = 0.5*(Zeffa - Zeff0)*tanh(eZeff*(ppsin - xZeff)) + 0.5*(Zeffa + Zeff0);% Effective charge (a.u.)
%
%Ion parameters
%
	pzTi = repmat(pTi,[length(zZi),1]); %same temperature for all ion species
	pzni = species_dke_yp(pne,pZeff,zZi,fi);
%
    Zp_helmex = Zout(1,1);%Vertical position of the plasma at theta = 0
    Y_helmex = Zout - Zp_helmex;%HELMEX77 calculate magnetic equilibrium at Zp = 0 but small vertical shift must be corrected. The vertical shift of the magnetic flux surfaces must be added after HELENA calculations  
%		
%		Transfer to the equil structure
%
    if display_opt ~= 0,
        figure(1),
        [ax] = graph1D_jd(R(npsi,:) - Rp_helmex,Y_helmex(npsi,:),0,0,'R - R_{p} (m)','Z - Z_{p} (m)','JETh77 separatrix',NaN,'','','--','none','r',2);
        legend('Guess','HELENA');
        [ax] = graph1D_jd(R_sep0(1,1) - Rp_guess,Z_sep0(1,1) - Zp_guess,0,0,'R - R_{p} (m)','Z - Z_{p} (m)','JETh77 separatrix',NaN,'','','none','+','b',2);
        [ax] = graph1D_jd(R(npsi,1) - Rp_helmex,Y_helmex(npsi,1),0,0,'R - R_{p} (m)','Z - Z_{p} (m)','JETh77 separatrix',NaN,'','','none','*','r',2);
%  
        figure('name','JETh77 magnetic equilibrium')
        [ax] = graph1D_jd(R(npsi,:),Zout(npsi,:),0,0,'R (m)','Z (m)','JETh77 separatrix',NaN,'','','--','none','r',2);
        [ax] = graph1D_jd(R(npsi,1),Zout(npsi,1),0,0,'R (m)','Z (m)','JETh77 separatrix',NaN,'','','none','*','r',2);
        axis('equal')
    end
%
	equil.psi_apRp = ppsi*ap_helmex/Rp_helmex;%psi_apRp = psi(toroidal usual)*ap/Rp for the cylindrical limit
	equil.theta = theta;
	equil.ptx = R - Rp_helmex;
	equil.pty = Y_helmex;
	equil.ptBx = BR;
	equil.ptBy = BZ;
	equil.ptBPHI = BPHI;
	equil.pTe = pTe;
	equil.pne = pne;
	equil.pzTi = pzTi;
	equil.pzni = pzni;
	equil.zZi = zZi;
	equil.zmi = zmi;
	equil.Rp = Rp_helmex;
    equil.Zp = Zp_helmex;
%
	equil.ftra = ftra;
%
else
	error(['The mexfile helmex77',mexext,' does not exists ! Compile it for the computer you are using...']);
end


