function [ap,Rp,Zp,xpoint,Bt,...
	 Ip,j0,ja,ej,qmin,eq,...
	 Te0,Tea,eTe,ne0,nea,ene,Ti0,Tia,eTi,...
	 Zi,mi,fi,Zeff0,Zeffa,eZeff,...
	 HXR,file_helena] = ptok_dke_1yp(name);
% 
%Global plasma and tokamak parameters for script_dke_1yp (Drift Kinetic equation solver)
% 
%	Input:
%
%		- name: tokamak name (TS, RTP, TCV, CMOD, D3D,TEST15,TEST51,...) [1,1]
%
%	Output:
%
%		- ap: Plasma minor radius on the equatorial mid-plane of separatrix (m) [1,1]
%		- Rp: Plasma major radius of the separatrix (m) [1,1]
%		- Zp: Global plasma vertical shift (m) [1,1]
%-------------------------------------------------------------------------------------------------------------
%The plasma separatrix is determined by the vertical and horizontal positions of top and bottom X points
%and the local angles between the separatrix and the horizontal plane. Note that when angles are locally 
%zero on both side, there is no X point (elliptical plasma). The horizontal coordinate lies between -1 and 1,
%0 being the major radius position of the separatrix
%
%		 xpoint(1): Vertical position of the top X point (always positive value)
%		 xpoint(2): Horizontal position of the top X point
%		 xpoint(3): Angle between the separatrix and the horizontal plane for the top X point (degree)
%		 xpoint(4): Angle between the separatrix and the horizontal plane for the top X point (degree)
%		 xpoint(5): Vertical position of the bottom X point (always positive value)
%		 xpoint(6): Horizontal position of the bottom X point
%		 xpoint(7): Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%		 xpoint(8): Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%-------------------------------------------------------------------------------------------------------------		 
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
%-------------------------------------------------------------------------------------------------------------
%Fast electron bremsstrahlung diagnostic parameters (if exists)
%		 
%     - HXR{1,1}: Angular position of the intersection between detector axis direction and the reference toroidal surface (degrees)  [1,nchord]
%     - HXR{1,2}: Horizontal rotation for each chord (degrees) [1,nchord]
%   	- HXR{1,3}: Vertical rotation for each chord [1,nchord]
%   	- HXR{1,4}: Major radius of the reference toroidal surface (m) [1,1]
%   	- HXR{1,5}: Minor radius of the reference toroidal surface (m) [1,1]
%     - HXR{1,6}: Geometrical factor for each chord (m^2/str) [1,nchord]
%-----------------------------------------------------------------
%For running with HELENA FORTRAN version only	 
%     - file_helena : HELENA input file name	
%
%	Warning: none
%
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and J.Decker RLE-MIT <jodecker@mit.edu>
%
if nargin < 1,
	error('Wrong number of input arguments in ptok_dke_1yp')
end
%
% Default values or non applicable
%
Zp = 0;
HXR{1,1} = NaN;%No HXR tomographic system
file_helena = '';%No HELENA input file
xpoint = NaN;
j0 = NaN;
ja = NaN;
ej = NaN;
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
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
elseif strcmp(name,'TS') == 1,
	ap = 0.72;
	Rp = 2.39;%Separatrix major radius
	Zp = 0.0;
%
	xpoint(1) = 1;%Vertical position of the top X point
	xpoint(2) = 0;%Horizontal position of the top X point
	xpoint(3) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(4) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(5) = 1;%Vertical position of the bottom X point (always positive value)
	xpoint(6) = 0;%Horizontal position of the bottom X point
	xpoint(7) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
	xpoint(8) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%
	Bt = 3.65;
%
	Zi = [1,1,1,6];%	Zi = [1,1,1];%
	mi = [1,2,3,12];%mi = [1,2,3];%
	fi = [0,1,0.0];
	Zeff0 = 1.5;%Zeff0 = 1.0;%
	Zeffa = 1.5;%Zeffa = 1.0;%
	eZeff = 0;
%
	Ip = 1.0;
	j0 = 0.6;
	ja = 0;
	ej = 2;
	qmin = 1.13;
	eq = 2;
%
	Te0 = 4.7;%Te0 = 6;%
	Tea = 0.1*Te0;%Tea = 0*Te0;%
	eTe = 1.1;%eTe = 0;%
	Ti0 = 3;%Ti0 = 6;%
	Tia = 0.1*Ti0;%Tia = 0*Ti0;%
	eTi = 1.1;%eTi = 0;%
	ne0 = 2.0e+19;%ne0 = 2.0e+19;%
	nea = 0.24*ne0;%nea = 0*ne0;%
	ene = 1.3;%ene = 0;%
% diagnostics
%
%Fast electron bremsstrahlung tomography (if exists)
%
%	[alpha_hxr,beta_hxr,R_hxr,Z_hxr,EG_hxr,kd_hxr,phf_hxr,res_hxr,ef_hxr,tf_hxr,ea_hxr,ta_hxr,ec_hxr,tc_hxr,ed_hxr,td_hxr,kdiag_hxr] = bremTSconvert_dke_yp(1,10,1999);%Specific function for Tore Supra
%
if 0,
    HXR{1,1} = alpha_hxr;
	HXR{1,2} = beta_hxr;
	HXR{1,3} = R_hxr;
	HXR{1,4} = Z_hxr;
	HXR{1,5} = EG_hxr;
	HXR{1,6} = kd_hxr;
	HXR{1,7} = phf_hxr;
	HXR{1,8} = res_hxr;
	HXR{1,9} = ef_hxr;
	HXR{1,10} = tf_hxr;
	HXR{1,11} = ea_hxr;
	HXR{1,12} = ta_hxr;
	HXR{1,13} = ec_hxr;
	HXR{1,14} = tc_hxr;
	HXR{1,15} = ed_hxr;
	HXR{1,16} = td_hxr;
	HXR{1,17} = kdiag_hxr;end
% HELENA input file
	file_helena = '';
	dbstop 185
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
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'TCV') == 1,%some parameters are incorrect for TCV
	ap = 0.25;
	Rp = 0.88;
	Ip = 0.12;
	Bt = 1.4;
	Ncoils = NaN;
	Zi = [1,1,1,6];
	mi = [1,2,3,12];
	fi = [0,1,0.0];
%
	BeLi = NaN;
	qmin = 1.0;
	eq = 0;%Parabolic dependence
%
	Te0 = 3.5;
	Tea = 0.0;
	eTe = 3;
	eTe_ref = 3;
	ne0 = 1e+19;
	nea = 1;
	ene = 0;
	ene_ref = 0;
	Ti0 = 1;
	Tia = 0;
	eTi = 3;
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
% diagnostics
   HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'CMOD') == 1,
	ap = 0.22;
	Rp = 0.68;
	Ip = 0.678;%****** calculated from f3din for C-mod(qmin = 3.2, qmax = 2.1, eq=1)
	Bt = 4.0;
	Ncoils = NaN;
	Zi = [1 1 1];
	mi = [1 2 3];
	fi = [1 0 0];
%
	BeLi = NaN;
	qmin = 3.2;
	eq = 1;
%
	Te0 = 7.5;
	Tea = 0.0;
	eTe = 2;
	eTe_ref = 2;
	ne0 = 2.5e+20;
	nea = 0.2*ne0;
	ene = 0.5;
	ene_ref = 0.5;
	Ti0 = 4;
	Tia = 0;
	eTi = 2;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
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
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'D3D') == 1,
	ap = 0.67;
	Rp = 1.67;
	Ip = 1.2;
	Bt = 2.1;
	Ncoils = NaN;
	Zi = [1,1,1,6];
	mi = [1,2,3,12];
	fi = [0,1,0];
%
	BeLi = NaN;
	qmin = 1;
	eq = 2;
%
	Te0 = 4;
	Tea = 0;
	eTe = 2;
	eTe_ref = 2;
	ne0 = 3e+19;
	nea = 0.2*ne0;
	ene = 0.5;
	ene_ref = 0.5;
	Ti0 = 2;
	Tia = 0;
	eTi = 2;
	Zeff0 = 2;
	Zeffa = 2;
	eZeff = 0;
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
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
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'D3D_test4_CST') == 1,
	ap = 0.67;
	Rp = 1.67;
	Ip = 1.2e-3;
	Bt = 2.0;
	Ncoils = NaN;
	Zi = [1,1,1,6];
	mi = [1,2,3,12];
	fi = [0,1,0];
%
	BeLi = NaN;
	qmin = 1;
	eq = 0;
%
	Te0 = 4;
	Tea = Te0;
	eTe = 0;
	eTe_ref = 0;
	ne0 = 3e+19;
	nea = ne0;
	ene = 0;
	ene_ref = 0;
	Ti0 = 4;
	Tia = Ti0;
	eTi = 0;
	Zeff0 = 2;
	Zeffa = 2;
	eZeff = 0;
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
elseif strcmp(name,'FTU') == 1,
	ap = 0.29;
	Rp = 0.935;
	Ip = 0.001;%Poloidal feld therefore neglected
	Bt = 5.5;
	Ncoils = NaN;
	Zi = [1,1,1,6];
	mi = [1,2,3,12];
	fi = [1,0,0];
%
	BeLi = NaN;
	qmin = 1;
	eq = 1;
%
	Te0 = 3.0;
	Tea = 0;
	eTe = 2;
	eTe_ref = 2;
	ne0 = 1.0e20;
	nea = 0;
	ene = 1;% Note: in order to match the equilibrium parameters from D. Farina (IFP 99/14), need to manually implement ne=ne0(1-(r/a)^3)
	ene_ref = 1;
	Ti0 = 1.5;
	Tia = Ti0;
	eTi = 0;
	Zeff0 = 3;
	Zeffa = 3;
	eZeff = 0;
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
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
	Te0 = 5.11e-4;
	Tea = Te0;
	eTe = 0;
	eTe_ref = 0;
	ne0 = 2.5e+19;
	nea = ne0;
	ene = 0;
	ene_ref = 0;
	Ti0 = Te0;
	Tia = 0;
	eTi = 0;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
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
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'TEST51') == 1,
	ap = 0.22;
	Rp = 0.68;
	Ip = 0.678;%****** calculated from f3din for C-mod(qmin = 3.2, qmax = 2.1, eq=1)
	Bt = 4.0;
	Ncoils = NaN;
	Zi = [1,1,1];
	mi = [1,2,3];
	fi = [1,0,0];
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
	nea = 1*ne0;
	ene = 0;
	ene_ref = 0;
	Ti0 = 0;
	Tia = 0;
	eTi = 0;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
elseif strcmp(name,'CQL3D_LH') == 1,
	ap = 2.3899;
	Rp = 2.39;%Separatrix major radius
	Zp = 0.0;
%
	xpoint(1) = 1;%Vertical position of the top X point
	xpoint(2) = 0;%Horizontal position of the top X point
	xpoint(3) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(4) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(5) = 1;%Vertical position of the bottom X point (always positive value)
	xpoint(6) = 0;%Horizontal position of the bottom X point
	xpoint(7) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
	xpoint(8) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%
	Bt = 3.65;
%
	Zi = [1,1,1];	
	mi = [1,2,3];
	fi = [1,0,0.0];
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
%
	Ip = 0.61;
	j0 = 0.6;
	ja = 0;
	ej = 2;
	qmin = 1.13;
	eq = 2;
%
	Te0 = 5.11;
	Tea = 5.11;
	eTe = 0;
	Ti0 = 5.11;
	Tia = 5.11;
	eTi = 0;
	ne0 = 1.0e+19;
	nea = 0;
	ene = 0;	
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'CQL3D_OHM') == 1,	
	ap = 2.3899;
	Rp = 2.39;%Separatrix major radius
	Zp = 0.0;
%
	xpoint(1) = 1;%Vertical position of the top X point
	xpoint(2) = 0;%Horizontal position of the top X point
	xpoint(3) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(4) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(5) = 1;%Vertical position of the bottom X point (always positive value)
	xpoint(6) = 0;%Horizontal position of the bottom X point
	xpoint(7) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
	xpoint(8) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%
	Bt = 3.65;
%
	Zi = [1,1,1];	
	mi = [1,2,3];
	fi = [1,0,0.0];
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
%
	Ip = 0.61;
	j0 = 0.6;
	ja = 0;
	ej = 2;
	qmin = 1.13;
	eq = 2;
%
	Te0 = 0.1;
	Tea = 0;
	eTe = 1;
	Ti0 = 0.1;
	Tia = 0;
	eTi = 1;
	ne0 = 1.0e+19;
	nea = 0;
	ene = 1;	
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'CQL3D_RUNAWAY') == 1,
	ap = 2.3899;
	Rp = 2.39;%Separatrix major radius
	Zp = 0.0;
%
	xpoint(1) = 1;%Vertical position of the top X point
	xpoint(2) = 0;%Horizontal position of the top X point
	xpoint(3) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(4) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(5) = 1;%Vertical position of the bottom X point (always positive value)
	xpoint(6) = 0;%Horizontal position of the bottom X point
	xpoint(7) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
	xpoint(8) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%
	Bt = 3.65;
%
	Zi = [1,1,1];	
	mi = [1,2,3];
	fi = [1,0,0.0];
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
%
	Ip = 0.61;
	j0 = 0.6;
	ja = 0;
	ej = 2;
	qmin = 1.13;
	eq = 2;
%
	Te0 = 0.1;
	Tea = 0;
	eTe = 1;
	Ti0 = 0.1;
	Tia = 0;
	eTi = 1;
	ne0 = 1.0e+19;
	nea = 0;
	ene = 1;	
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
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
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'JET') == 1,
	ap = 0.9;
	Rp = 3.00;
	Zp = 0.0;
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
	Ti0 = 3;
	Tia = 0.1*Ti0;
	eTi = 2;	
	ne0 = 2.0e+19;
	nea = 0.01*ne0;
	ene = 0.5;
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'JETH') == 1,%For use with HELENA FORTRAN version only
	ap = NaN;
	Rp = NaN;
	Zp = NaN;
	%
	xpoint(1) = NaN;%Vertical position of the top X point
	xpoint(2) = NaN;%Horizontal position of the top X point
	xpoint(3) = NaN;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(4) = NaN;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(5) = NaN;%Vertical position of the bottom X point (always positive value)
	xpoint(6) = NaN;%Horizontal position of the bottom X point
	xpoint(7) = NaN;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
	xpoint(8) = NaN;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
	%
	Bt = NaN;	
	%
	Zi = [NaN NaN NaN];
	mi = [NaN NaN NaN];
	fi = [NaN,NaN,NaN];
	Zeff0 = NaN;
	Zeffa = NaN;
	eZeff = NaN;
%	
	Ip = NaN;
	j0 = NaN;
	ja = NaN;
	ej = NaN;
	qmin = NaN;
	eq = NaN;
%
	Te0 = NaN;
	Tea = NaN;
	eTe = NaN;
	Ti0 = NaN;
	Tia = NaN;
	eTi = NaN;	
	ne0 = NaN;
	nea = NaN;
	ene = NaN;
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = 'helena1_in';
elseif strcmp(name,'JETb') == 1,
	ap = 0.9;
	Rp = 3.00;
	Zp = 0.0;
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
	Te0 = 10;
	Tea = 0.1*Te0;
	eTe = 0.5;
	Ti0 = 10;
	Tia = 0.1*Ti0;
	eTi = 0.5;	
	ne0 = 4.0e+19;
	nea = 0.01*ne0;
	ene = 0.5;
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'JET_C') == 1,%Counter current LH experiments (see Marc Goniche)
	ap = 0.98;
	Rp = 2.87;
	Zp = 0.0;
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
	Bt = 3.1;	
%
	Zi = [1 1 1 6];
	mi = [1 2 3 12];
	fi = [0,1,0];
	Zeff0 = 4;
	Zeffa = 4;
	eZeff = 0;
%	
	Ip = 1.5;
	j0 = 1.0;
	ja = 0;
	ej = 2;
	qmin = 1;
	eq = 1;
%
	Te0 = 8;
	Tea = 0.04*Te0;
	eTe = 3;
	Ti0 = 3;
	Tia = 0.04*Ti0;
	eTi = 3;	
	ne0 = 1.5e+19;
	nea = 0.05*ne0;
   ene = 0.5;
% diagnostics
   HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'TEST_LORENTZ') == 1,%Values based on NSTX case but circular plasma cross-section
   ap = 2.3899;
   Rp = 2.39; 
	Zp = 0.0;
%
	xpoint(1) = 1;%Vertical position of the top X point
	xpoint(2) = 0;%Horizontal position of the top X point
	xpoint(3) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(4) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
	xpoint(5) = 1;%Vertical position of the bottom X point (always positive value)
	xpoint(6) = 0;%Horizontal position of the bottom X point
	xpoint(7) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
	xpoint(8) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%
	Bt = 0.45;	
%
	Zi = [1 1 1 30];
	mi = [1 2 3 30];
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
	Tea = Te0;
	eTe = 0;
	Ti0 = 0.0015;
	Tia = Ti0;
	eTi = 0;	
	ne0 = 2.0e+19;
	nea = 0.001*ne0;
	ene = 2;
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
elseif strcmp(name,'RELAX_ECCD') == 1,
	ap = 1.125;
	Rp = 2.25;
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
	Te0 = 2.25;
	Tea = Te0;
	eTe = 0;
	eTe_ref = 0;
	ne0 = 4.13e+19;
	nea = ne0;
	ene = 0;
	ene_ref = 0;
	Ti0 = Te0;
	Tia = Ti0;
	eTi = 0;
	Zeff0 = 1;
	Zeffa = 1;
	eZeff = 0;
% diagnostics
	HXR{1,1} = NaN;%No HXR tomographic system
% HELENA input file
	file_helena = '';
else
	error('Wrong input name in ptok_dke_1yp.m')
end	
