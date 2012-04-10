function [equil] = process_euitm_dataequil(magnetic_euitm,coreprof_euitm)
%LUKE - Function that process the ITM data to generate a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%Function that build a LUKE compliant magnetic equilibrium structure from ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 2,error('Not enough input arguments in process_euitm_dataequil.m');end
%
magnetic = CPO2LUKEstruct_yp('equilibrium',magnetic_euitm);% Data conversion between ITM CPO's and C3PO/LUKE format
coreprof = CPO2LUKEstruct_yp('coreprof',coreprof_euitm);% Data conversion between ITM CPO's and C3PO/LUKE format
%
% Profiles interpolation of the temperatures and densities on the 1-D psin grid defined in magnetic_LUKE
%
interp_method ='linear';
%
pTe_interp = interp1(coreprof_euitm.psi.value,coreprof.pTe,magnetic_euitm.profiles_1d.psi,interp_method,'extrap')';	
pne_interp = interp1(coreprof_euitm.psi.value,coreprof.pne,magnetic_euitm.profiles_1d.psi,interp_method,'extrap')';	
pzTi_interp = interp1(coreprof_euitm.psi.value',coreprof.pzTi',magnetic_euitm.profiles_1d.psi',interp_method,'extrap')'; 	
pzni_interp = interp1(coreprof_euitm.psi.value',coreprof.pzni',magnetic_euitm.profiles_1d.psi',interp_method,'extrap')'; 	
%	
psi_euitm= magnetic_euitm.profiles_1d.psi - magnetic_euitm.profiles_1d.psi(1);%psi = 0 on the magnetic axis (arbitrary choice)
psin_euitm= psi_euitm/psi_euitm(end);
%
psin = magnetic.psi_apRp'/magnetic.psi_apRp(end);
%
profiles.pTe = interp1(psin_euitm,pTe_interp,psin,interp_method,'extrap')';	
profiles.pne = interp1(psin_euitm,pne_interp,psin,interp_method,'extrap')';	
profiles.pzTi = interp1(psin_euitm',pzTi_interp',psin',interp_method,'extrap')'; 	
profiles.pzni = interp1(psin_euitm',pzni_interp',psin',interp_method,'extrap')';
%
profiles.zZi = coreprof.zZi;
profiles.zmi = coreprof.zmi;
%	
equil = conc_struct_jd(magnetic,profiles);%LUKE compatible magnetic equilibrium structure
