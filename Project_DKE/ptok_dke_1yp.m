function [ap,Rp,Zp,elong,triang_up,triang_down,Bt,...
	 Ip,j0,ja,ej,qmin,eq,...
	 Te0,Tea,eTe,ne0,nea,ene,Ti0,Tia,eTi,...
	 Zi,mi,fi,Zeff0,Zeffa,eZeff] = ptok_dke_1yp(name);
% 
%Global plasma and tokamak parameters for script_dke_1yp (Drift Kinetic equation solver)
% 
%	Input:
%
%		- name: tokamak name (TS, RTP, TCV, CMOD, D3D,TEST15,TEST51,...) [1,1]
%
%	Output:
%
%		- ap: Plasma minor radius on the equatorial mid-plane of the last closed magnetic surface (m) [1,1]
%		- Rp: Plasma major radius of the last closed magnetic surface (m) [1,1]
%		- Zp: Plasma vertical shift (m) [1,1]
%		- elong: Plasma elongation of the last closed magnetic surface [1,1]
%		- triang_up: Plasma triangularity of the last closed magnetic surface above the equatorial mid-plane [1,1]
%		- triang_down: Plasma triangularity of the last closed magnetic surface below the equatorial mid-plane [1,1]
%		- Bt: Toroidal magnetic field on the magnetic axis (T) [1,1]
%		- Ip: Toroidal plasma current (MA)  [1,1] 
%		- j0: Core toroidal curent density (MA/m2) [1,1]
%		- ja: Edge toroidal curent density (MA/m2) [1,1]
%		- ej: Exponent for j profile -> j(psin) = (j0-ja)*(1-(psin)^2)^ej + ja) [1,1]
%		- qmin: Safety factor q0 at plasma center [1,1]
%		- eq: Exponent for q radial profile -> q(psin) = (qmax - qmin)*(psin).^eq + qmin, qmax calculated by the Ampere's theorem at the plasma edge for circular magnetic flux surface only [1,1]
%		- Te0: Core electron temperature (keV) [1,1]
%		- Tea: Edge electron temperature (keV) [1,1]
%		- eTe: Exponent for Te profile -> Te(psin) = (Te0-Tea)*(1-(psin)^2)^eTe + Tea) [1,1]
%		- ne0: %Core electron density (m-3) [1,1]
%		- nea: %Edge electron density (m-3) [1,1]
%		- ene: %Exponent for ne profile -> ne(psin) = (ne0-nea)*(1-(psin)^2)^ene + nea) [1,1]
%		- Ti0: %Core ion temperature, same value for all species (keV) [1,1]
%		- Tia: %Edge ion temperature, same value for all species (keV) [1,1]
%		- eTi: %Exponent for Ti profile -> Ti(psin) = (Ti0-Tia)*(1-(psin)^2)^eTi + Tia) [1,1]
%		- Zi: Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
%		- mi: Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
%		- fi: Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%		- Zeff0: Core effective charge (a.u.) [1,1]
%		- Zeffa: Edge effective charge (a.u.) [1,1]
%		- eZeff: Exponent for the effective charge -> Zeff(psin) = (Zeff0-Zeffa)*(1-(psin)^2)^eZeff + Zeffa) [1,1]
%  
%	Warning: none
%
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
%
if nargin < 1,
	error('Wrong number of input arguments in ptok_dke_1yp')
end
%
disp('-------------------------------------------------------------------------------------------------------------------');
disp(['- Tokamak name = ',name]);
disp('-------------------------------------------------------------------------------------------------------------------');
%
if strcmp(name,'CTORUS') == 1,
	ap = 0.72;
	Rp = 0.8; 
	Ip = 0.61;
	Bt = 3.65;
	Ncoils = 18;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [0,1,0.0];
%
	BeLi = 1.0;
	qmin = 1.13;
	eq = 2;
%
	Te0 = 2.7;
	Tea = 0;
	eTe = 1.1;
	eTe_ref = 1.1;
	ne0 = 1.0e+19;
	nea = 0.24*ne0;
	ene = 1.3;
	ene_ref = 1.3;
	Ti0 = 1.5;
	Tia = 0;
	eTi = 1.1;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
elseif strcmp(name,'TS') == 1,
	ap = 0.72;
	Rp = 2.39;
	Zp = 0.0;
	elong = 1;
	triang_up = 0;
	triang_down = 0;
%
	Bt = 3.65;
%
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [0,1,0.0];
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
%
	Ip = 1.0;
	j0 = 0.6;
	ja = 0;
	ej = 2;
	qmin = 1.13;
	eq = 2;
%
	Te0 = 4.7;
	Tea = 0.01*Te0;
	eTe = 1.1;
	Ti0 = 4.7;
	Tia = 0.01*Ti0;
	eTi = 1.1;
	ne0 = 1.0e+19;
	nea = 0.24*ne0;
	ene = 1.3;
elseif strcmp(name,'RTP') == 1,
	ap = 0.165;
	Rp = 0.72;
	Ip = 0.09;%****** calculated from f3din for C-mod(qmin = 3.2, qmax = 2.1, eq=1)
	Bt = 2.0;
	Ncoils = NaN;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [0,1,0.0];
%
	BeLi = NaN;
	qmin = 1.0;
	eq = 2;%Parabolic dependence
%
	Te0 = 0.8;
	Tea = 0.0;
	eTe = 2;
	eTe_ref = 2;
	ne0 = 2.5e+19;
	nea = 0;
	ene = 1;
	ene_ref = 1;
	Ti0 = 0.4;
	Tia = 0;
	eTi = 2;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
elseif strcmp(name,'TCV') == 1,%some parameters are incorrect for TCV
	ap = 0.25;
	Rp = 0.87;
	Ip = 0.09;%****** calculated from f3din for C-mod(qmin = 3.2, qmax = 2.1, eq=1)
	Bt = 2.0;
	Ncoils = NaN;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [0,1,0.0];
%
	BeLi = NaN;
	qmin = 1.0;
	eq = 2;%Parabolic dependence
%
	Te0 = 1.88;
	Tea = 0.03;
	eTe = 2;
	eTe_ref = 2;
	ne0 = 1.95e+19;
	nea = 0;
	ene = 1;
	ene_ref = 1;
	Ti0 = 0.94;
	Tia = 0;
	eTi = 2;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
elseif strcmp(name,'JT60_exp') == 1,%PoP 7 1927 (2000)
        ap = 0.8;
        Rp = 3.35;
        Ip = 0.8;
        Bt = 3.4;
        Ncoils = NaN;
        Zi = [1 1 1 6];
        mi = [1 2 3 12];
        fi = [0,1,0];
%
        BeLi = NaN;
        qmin = [1.0];% wrong!!.... not to be used for dke calculations
                 % for exact q profile, see tokparams       
        eq = 1;
%
        Te0 = 6.2;
        Tea = 1.5;
        eTe = 1.55;
        eTe_ref = eTe;
        ne0 = 3.8e+19;
        nea = 0.25e+19;
        ene = 1.5;
        ene_ref = ene;
        Ti0 = 7.6;
        Tia = 0.6;
        eTi = 1;
        Zeff0 = 3;%PoP 7 1935 (1999)
        Zeffa = 3;
        eZeff = 0;
elseif strcmp(name,'CMOD') == 1,
	ap = 0.22;
	Rp = 0.68;
	Ip = 0.678;%****** calculated from f3din for C-mod(qmin = 3.2, qmax = 2.1, eq=1)
	Bt = 4.0;
	Ncoils = NaN;
	Zi = [12 1 1];
	mi = [12 2 3];
	fi = [1,0,0];
%
	BeLi = NaN;
	qmin = 3.2;
	eq = 1;
%
	Te0 = 7.5;
	Tea = 0.0;
	eTe = 2*0;
	eTe_ref = 2*0;
	ne0 = 2.5e+20;
	nea = 0.2*ne0;
	ene = 0.5;
	ene_ref = 0.5;
	Ti0 = 4*0.01;
	Tia = 0;
	eTi = 2*0;
	Zeff0 = 12;
	Zeffa = 12;
	eZeff = 0;
elseif strcmp(name,'NSTX') == 1,
	ap = 0.67;
	Rp = 0.86;
	Zp = 0.0;
	elong = 1;
	triang_up = 0;
	triang_down = 0;
%
	Bt = 0.45;	
%
	Zi = [1 1 1];
	mi = [1 2 3];
	fi = [0,1,0];
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
%	
	Ip = 0.8;
	j0 = 0.4;
	ja = 0;
	ej = 2;
	qmin = 1;
	eq = 1;
%
	Te0 = 1.5;
	Tea = 0.001*Te0;
	eTe = 2;
	Ti0 = 1.5;
	Tia = 0.001*Ti0;
	eTi = 2;	
	ne0 = 2.0e+19;
	nea = 0.001*ne0;
	ene = 0.5;	
elseif strcmp(name,'D3D') == 1,
	ap = 0.67;
	Rp = 1.67;
	Ip = 1.0;
	Bt = 2.0;
	Ncoils = NaN;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [0,1,0.0];
%
	BeLi = NaN;
	qmin = 1;
	eq = 2;
%
	Te0 = 7.8+0.76368;
	Tea = 0+0.76368;
	eTe = 1.1;
	eTe_ref = 1.1;
	ne0 = 4.3e+19;
	nea = 0.24*ne0;
	ene = 1.3;
	ene_ref = 1.3;
	Ti0 = 6.2;
	Tia = 0;
	eTi = 1.1;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
elseif strcmp(name,'D3D_test4') == 1,
	ap = 0.67;
	Rp = 1.67;
	Ip = 1.2;
	Bt = 2.0;
	Ncoils = NaN;
	Zi = [1,1,1,6];
	mi = [1,2,3,12];
	fi = [0,1,0];
%
	BeLi = NaN;
	qmin = 1;
	eq = 1.31;
%
	Te0 = 4;
	Tea = 0;
	eTe = 1;
	eTe_ref = 1;
	ne0 = 3e+19;
	nea = 0*ne0;
	ene = 1;
	ene_ref = 1;
	Ti0 = 4;
	Tia = 0;
	eTi = 1;
	Zeff0 = 2;
	Zeffa = 2;
	eZeff = 0;
elseif strcmp(name,'TEST0') == 1,
	ap = 0.22;
	Rp = 0.68;
	Ip = 0.678;%****** calculated from f3din for C-mod(qmin = 3.2, qmax = 2.1, eq=1)
	Bt = 4.0;
	Ncoils = NaN;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [0,1,0.0];
%
	BeLi = NaN;
	qmin = 3.2;
	eq = 1;
%
	Te0 = 0.001;
	Tea = 0.0;
	eTe = 2*0;
	eTe_ref = 2*0;
	ne0 = 2.5e+19;
	nea = 0.2*ne0;
	ene = 0.5*0;
	ene_ref = 0.5*0;
	Ti0 = 0.0005;
	Tia = 0;
	eTi = 2*0;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
elseif strcmp(name,'TEST15') == 1,
	ap = 0.22;
	Rp = 0.68;
	Ip = 0.678;%****** calculated from f3din for C-mod(qmin = 3.2, qmax = 2.1, eq=1)
	Bt = 4.0;
	Ncoils = NaN;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [0,1,0.0];
%
	BeLi = NaN;
	qmin = 3.2;
	eq = 1;
%
	Te0 = 1.5;
	Tea = 0.0;
	eTe = 2;
	eTe_ref = 2;
	ne0 = 2.5e+19;
	nea = 0.2*ne0;
	ene = 0.5;
	ene_ref = 0.5;
	Ti0 = 0.75;
	Tia = 0;
	eTi = 2;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
elseif strcmp(name,'TEST51') == 1,
	ap = 0.22;
	Rp = 0.68;
	Ip = 0.678;%****** calculated from f3din for C-mod(qmin = 3.2, qmax = 2.1, eq=1)
	Bt = 4.0;
	Ncoils = NaN;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [0,1,0.0];
%
	BeLi = NaN;
	qmin = 3.2;
	eq = 1;
%
	Te0 = 5.11;
	Tea = 5.11;
	eTe = 0;
	eTe_ref = 0;
	ne0 = 2.5e+19;
	nea = 0.2*ne0;
	ene = 0.5;
	ene_ref = 0.5;
	Ti0 = 2.555*0;
	Tia = 0;
	eTi = 2;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
elseif strcmp(name,'CQL3D_LH') == 1,
	ap = 0.72;
	Rp = 2.39; 
	Ip = 0.61;
	Bt = 3.65;
	Ncoils = 18;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [1,0,0];
%
	BeLi = 1.0;
	qmin = 1.13;
	eq = 2;
%
	Te0 = 5.11/100000;
	Tea = 0;
	eTe = 0;
	eTe_ref = 0;
	ne0 = 1.0e+19;
	nea = 0*ne0;
	ene = 0;
	ene_ref = 0;
	Ti0 = 5.11*0;
	Tia = 0;
	eTi = 0;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
elseif strcmp(name,'CQL3D_OHM') == 1,
	ap = 2.3899;
	Rp = 2.39; 
	Ip = 0.61;
	Bt = 3.65;
	Ncoils = 18;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [1,0,0];
%
	BeLi = 1.0;
	qmin = 1.13;
	eq = 2;
%
	Te0 = 0.1;
	Tea = 0;
	eTe = 0;
	eTe_ref = 0;
	ne0 = 1.0e+19;
	nea = 0*ne0;
	ene = 0;
	ene_ref = 0;
	Ti0 = 0;
	Tia = 0;
	eTi = 0;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
elseif strcmp(name,'CQL3D_RUNAWAY') == 1,
	ap = 2.3899;
	Rp = 2.39; 
	Ip = 0.61;
	Bt = 3.65;
	Ncoils = 18;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [0,1,0.0];
%
	BeLi = 1.0;
	qmin = 1.13;
	eq = 2;
%
	Te0 = 0.1;
	Tea = 0;
	eTe = 0;
	eTe_ref = 0;
	ne0 = 1.0e+19;
	nea = 0*ne0;
	ene = 0;
	ene_ref = 0;
	Ti0 = 0.1;
	Tia = 0;
	eTi = 0;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
elseif strcmp(name,'CQL3D_ECCD') == 1,
	ap = 2.3899;
	Rp = 2.39; 
	Ip = 0.61;
	Bt = 3.65;
	Ncoils = 18;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [0,1,0.0];
%
	BeLi = 1.0;
	qmin = 1.13;
	eq = 2;
%
	Te0 = 5.11;
	Tea = 0;
	eTe = 0;
	eTe_ref = 0;
	ne0 = 1.0e+19;
	nea = 0*ne0;
	ene = 0;
	ene_ref = 0;
	Ti0 = 5.11;
	Tia = 0;
	eTi = 0;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
elseif strcmp(name,'JET') == 1,
		ap = 0.9;
		Rp = 3.00;
		Zp = 0.0;
		elong = 1.7;
		triang_up = 0.24;
		triang_down = 0.24;
	%
		Bt = 3.5;	
	%
		Zi = [1 1 1 6];
		mi = [1 2 3 12];
		fi = [0,1,0];
		Zeff0 = 1.5;
		Zeffa = 1.5;
		eZeff = 0;
	%	
		Ip = 1.3;
		j0 = 0.4;
		ja = 0;
		ej = 2;
		qmin = 1;
		eq = 1;
	%
		Te0 = 5;
		Tea = 0.1*Te0;
		eTe = 2;
		Ti0 = 2;
		Tia = 0.1*Ti0;
		eTi = 2;	
		ne0 = 1.0e+19;
		nea = 0.001*ne0;
		ene = 0.5;	
elseif strcmp(name,'TEST_LORENTZ') == 1,%Values based on NSTX case
	ap = 0.67;
	Rp = 0.86;
	Zp = 0.0;
	elong = 1;
	triang_up = 0;
	triang_down = 0;
%
	Bt = 0.45;	
%
	Zi = [30 1 1 ];
	mi = [30 2 3 ];
	fi = [1,0,0];
	Zeff0 = 30;
	Zeffa = 30;
	eZeff = 0;
%	
	Ip = 0.8;
	j0 = 0.2;
	ja = 0;
	ej = 2;
	qmin = 1;
	eq = 1;
%
	Te0 = 0.15;
	Tea = 0.001*Te0;
	eTe = 0;
	Ti0 = 0.0015;
	Tia = 0.001*Ti0;
	eTi = 0;	
	ne0 = 2.0e+19;
	nea = 0.001*ne0;
	ene = 0.5;	
else
	error('Wrong input name in ptok_dke_1yp.m')
end	
