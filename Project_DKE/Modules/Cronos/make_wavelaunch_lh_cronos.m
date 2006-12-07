function [launch] = make_wavelaunch_lh_cronos(equil,config,cons,cons_spec)
%
% Create the structure launch for CRONOS
%
%by Y.Peysson <yves.peysson@cea.fr> (CEA-DRFC) and J. Decker <joan.decker@cea.fr> (CEA-DRFC)
%
% -------------------------------- Tore Supra --------------------------------
%
if strcmp(config,'TS');%For the Lower Hybrid wave simulations
   launch.type = 'LH';
   launch.omega_rf = [3.7;3.7]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [0.7;0.7];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2;0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [0,0,0,0,0,0;0,0,0,0,0,0];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0;0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0;0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1;1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]
%
% -------------------------------- Tore Supra Mixte --------------------------------
%
elseif strcmp(config,'MIXTE');%For the Lower Hybrid wave simulations
   launch.type = 'LH';
   launch.omega_rf = [3.7;3.7]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [0.7;0.6];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2;0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [0,0,0,0,0,0;0,0,0,0,0,0];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0;0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0;0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1;1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]
%
% -------------------------------- Tore Supra CIEL --------------------------------
%
elseif strcmp(config,'CIEL');%For the Lower Hybrid wave simulations
   launch.type = 'LH';
   launch.omega_rf = [3.7;3.7]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [0.6;0.6];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2;0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [0,0,0,0,0,0;0,0,0,0,0,0];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0;0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0;0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1;1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]
%
% -------------------------------- C-MOD --------------------------------
%
elseif strcmp(config,'CMOD');%For the Lower Hybrid wave simulations 
   launch.type = 'LH';
   launch.omega_rf = [4.6]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [1.0];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [-0.0535,0.0001,0.0535];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]
%
% -------------------------------- JET --------------------------------
%
elseif strcmp(config,'JET');%For the Lower Hybrid wave simulations
   launch.type = 'LH';
   launch.omega_rf = [3.7;3.7]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [0.7;0.7];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2;0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [0,0,0,0,0,0;0,0,0,0,0,0];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0;0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0;0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1;1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]
%
% -------------------------------- ITER@3.7GHz --------------------------------
%
elseif strcmp(config,'ITER3.7GHz');%For the Lower Hybrid wave simulations
   launch.type = 'LH';
   launch.omega_rf = [3.7;3.7]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [0.7;0.7];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2;0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [0,0,0,0,0,0;0,0,0,0,0,0];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0;0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0;0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1;1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]
%
% -------------------------------- ITER@5.0GHz --------------------------------
%
elseif strcmp(config,'ITER5GHz');%For the Lower Hybrid wave simulations
   launch.type = 'LH';
   launch.omega_rf = [5.0;5.0]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [0.7;0.7];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2;0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [0,0,0,0,0,0;0,0,0,0,0,0];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0;0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0;0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1;1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]
%
% -------------------------------- FT-U --------------------------------
%
elseif strcmp(config,'FTU')
   launch.type = 'LH';
   launch.omega_rf = [8.0;8.0]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [0.85;0.85];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2;0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [0,0,0,0,0,0;0,0,0,0,0,0];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0;0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0;0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1;1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]  	
%
% -------------------------------- SST-1 --------------------------------
%
elseif strcmp(config,'SST1')
   launch.type = 'LH';
   launch.omega_rf = [3.7;3.7]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [0.75;0.75];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2;0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [0,0,0,0,0,0;0,0,0,0,0,0];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0;0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0;0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1;1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]  		
%
% -------------------------------- DEMO@3.7GHz --------------------------------
%
elseif strcmp(config,'DEMO3.7GHz')
   launch.type = 'LH';
   launch.omega_rf = [3.7;3.7]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [0.7;0.7];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2;0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [0,0,0,0,0,0;0,0,0,0,0,0];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0;0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0;0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1;1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]  		
%
% -------------------------------- DEMO@5.0GHz --------------------------------
%
elseif strcmp(config,'DEMO5.0GHz')
   launch.type = 'LH';
   launch.omega_rf = [5.0;5.0]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [0.7;0.7];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2;0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [0,0,0,0,0,0;0,0,0,0,0,0];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0;0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0;0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1;1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]  	
%
% -------------------------------- COMPASS --------------------------------
%
elseif strcmp(config,'TS');%For the Lower Hybrid wave simulations
   launch.type = 'LH';
   launch.omega_rf = [1.3]*2*pi*1e9;%wave angular frequency (rad/s) [n_antenna,1]
%
   directivity = [0.7];%Antenna directivity [n_antenna,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [n_antenna,n_lobe]
   launch.bPrftot = Plhtot;%initial power in the ray (W) [n_antenna,n_lobe]
   launch.bNpar0 = Npar0;%Initial Npar value [n_antenna,n_lobe]
 %
   launch.bdNpar0 = [0.2];%ray spectral width for Fokker-Planck calculations (main lobe) [n_antenna,n_lobe]
%
   launch.ry0 = [-0.0535;0.0001;0.0535];%vertical launching positions (m) [n_antenna,m_pol]
% 
   launch.m0 = [0];%initial poloidal mode number [n_antenna,1]
   launch.phi0 = [0];%toroidal angle position [n_antenna,1]
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launch.LFS = [1];% (-1) high field side launching, (1) low field side launching [n_antenna,1]
else
   error('The launch configuration name does not exists')  	
end







