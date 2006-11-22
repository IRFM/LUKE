%
%   This script generates the data file of an ideal circular equilibrium based on
%   equilibrium profile parameters
%
%   By J. Decker <jodecker@alum.mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%   Created Feb. 17, 2004
%
clear all
%
equil.id = 'JETh77';% scenario identification
%
% Equilibrium parameters
%
ap_guess = 0.9;%  Plasma minor radius on LFS midplane (m)
Rp_guess = 3.0;%  Plasma major radius on axis (m)
Zp_guess = 0;%  Global plasma vertical shift (m)
%
xpoint(1) = 1.687;%Vertical position of the top X point
xpoint(2) = 0.466;%Horizontal position of the top X point
xpoint(3) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
xpoint(4) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
xpoint(5) = 2.001;%Vertical position of the bottom X point (always positive value)
xpoint(6) = 0.568;%Horizontal position of the bottom X point
xpoint(7) = 22.46;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
xpoint(8) = 67.92;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%
npsi_guess = 201;%For initial profile calculations
ntheta_guess = 201;%Number of poloidal positions for the guessed separatrix
npsi = 101;%ONLY 101 radial profile grid points for HELMEX77
ntheta = 65;%ONLY 65 poloidal grid points for HELMEX77
%
Ip = 1.3;%  Plasma current (MA)  
j0 = 0.4;%  Core toroidal curent density (MA/m2) [1,1]
ja = 0;%    Edge toroidal curent density (MA/m2) [1,1]
ej = 2;%    Exponent for j profile -> j(psin) = (j0-ja)*(1-(psin)^2)^ej + ja) [1,1]
%
qmin = 1;%  Safety factor q0 at plasma center
eq = 1;%  Exponent for q radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calaculated by the Ampere's theorem at the plasma edge with a circular plasma cross-section)
qopt = 1;%Option for q profile. (0): constant (default, uniform current, psi=rho^2), (1): from qmin and eq 
%
Bt = 3.5;%  Toroidal magnetic field on the magnetic axis (T) 
%
Zi = [1,1,1,6];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
mi = [1,2,3,12];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
fi = [0,1,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
Te0 = 5;%  Core electron temperature (keV)
dTea = 0.1*Te0;%  Edge electron temperature parameter
eTe1 = 2;%  Exponent #1 for Te profile 
eTe2 = 2;%  Exponent #1 for Te profile 
%
ne0 = 2.0e19;%  Core electron density (m-3)
dnea = 0.01*ne0;%  Edge electron density parameter
ene1 = 2;%  Exponent #1 for ne profile 
ene2 = 0.5;%  Exponent #2 for ne profile
%
Ti0 = 2;%  Core ion temperature (keV)
dTia = 00.1*Ti0;%  Edge ion temperature (keV)
eTi1 = 2;%  Exponent #1 for Ti profile
eTi2 = 2;%  Exponent #1 for Ti profile
%
Zeff0 = 1.5%  Core effective charge (a.u.)
Zeffa = 1.5;%  Edge effective charge (a.u.)
eZeff = 0;%  Define the slope at the radial point where the derivative is maximum (must be >> 1)
xZeff = 0.5;%Radial normalized position at which the derivative is maximum
%
%**************************************************************************************************
%
%
% Initial calculations to set up the guess for HELMEX77
%
Bpa = (4*pi*1e-7)*Ip*1e6/(2*pi*ap_guess);% Poloidal Field at the edge, Ampere's theorem (circular plasma cross-section for the initial guess)	
qmax = ap_guess/Rp_guess*Bt/Bpa,%Cylindrical safety factor at the plasma edge
%
prho_guess = linspace(0,1,npsi_guess);%Initial grid
if qopt == 1,
	 pq_guess = (qmax - qmin)*prho_guess.^eq + qmin;% Current profile defined by qmin and eq
else 
	 pq_guess = qmax*ones(1,npsi_guess);% Current profile defined with constant q (uniform current density)
end
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
	pj_guess = (j0 - ja)*(1 - ppsin_guess.^2).^ej + ja;%Current density profile
    
    Ip = trapz_dke_yp([ppsin_guess(:),ppsin_guess(:).*pj_guess(:)])*2*pi*0.2*0.2    
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
    figure('Name','JETh77 separatrix')
    [ax] = graph1D_jd(R_sep0 - Rp_guess,Z_sep0 - Zp_guess,0,0,'R - R_{p} (m)','Z - Z_{p} (m)','JETh77 separatrix',NaN,'','','--','none','b',2);
    [ax] = graph1D_jd(R_sep0(1,1) - Rp_guess,Z_sep0(1,1) - Zp_guess,0,0,'R - R_{p} (m)','Z - Z_{p} (m)','JETh77 separatrix',NaN,'','','none','+','b',2);
    axis('equal')
    zoom on
%
        zoom on
%
% For the input to HELENA
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
	[C2,C3,rho2m,R,Zout,rho,Vp,drhoor,qpsi,ppsi,ftra,Fdia,psiT,B2,invB2,Sp, ...
			rav,oor,drhoav,xshift,xrad,xell,xtriapos,xtrianeg,jout,iout,pout, ...
			r2,oor2,r2tau2,drho2ob2,r3otau3,r3otau,BR,BZ,b,df2,kkbig,li, ...
			dimerc,drmerc,balcrit,ifail]=...
			helmex77(ppsi_in,ptot_in,pj_in*1e6,Rp_in,Bt_in,Ip*1e6,2,ap_in,0,0,0,R_in,Z_in,init,[],[],[],1);
%			
		BPHI = (Fdia*ones(1,ntheta))./R;
%
		ap_helmex = R(npsi,1) - R(1,1);
		Rp_helmex = R(1,1);
		Bt_helmex = BPHI(1,1);
		disp(' ');
	if ap_helmex ~= ap_in
	   disp(['Minor radius from ptok (in): ',num2str(ap_in),', from HELMEX77 (kept): ',num2str(ap_helmex)])
    else 
       ap_helmex = ap_in;
	end
	if Rp_helmex ~= Rp_in
	   disp(['Major radius from ptok (in): ',num2str(Rp_in),', from HELMEX77 (kept): ',num2str(Rp_helmex)])
    else
       Rp_helmex = Rp_in;
	end
	if Bt_helmex ~= Bt_in
	   disp(['Magnetic field on axis from ptok (in): ',num2str(Bt_in),', from HELMEX77 (kept): ',num2str(Bt_helmex)])
    else
       Bt_helmex = Bt_in;
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
		filename = ['EQUIL_',equil.id,'.mat'];  
		eval(['save ',filename,' equil']);
else
	error(['The mexfile helmex77',mexext,' does not exists ! Compile it for the computer you are using...']);
end


