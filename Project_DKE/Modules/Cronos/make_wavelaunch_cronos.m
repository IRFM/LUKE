function [launch] = make_wavelaunch_cronos(config,equil)
%
% Create the structure launch for CRONOS
% 
if strcmp(config,'TS');%For the Lower Hybrid wave simulations
   launch.type = 'LH';
   launch.omega_rf = [4.6]*2*pi*1e9;%wave angular frequency (rad/s)
   launch.bPlhtotp = [0.2]*1e6;%initial power in the ray (W) (main lobe) [1,n_lobe]
   launch.bNpar0p = [-1.55];%Initial Npar value (main lobe) [1,n_lobe]
   launch.bwidthp = [0.2];%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launch.ry0p = [-0.0535;0.0001;0.0535];%vertical launching positions [m_pol,1]
%
   launch.bPlhtotm = []*1e6;%initial power in the ray (W) (satellite lobe) [1,n_lobe]
   launch.bNpar0m = [];%Initial Npar value (satellite lobe) [1,n_lobe]
   launch.bwidthm = [];%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launch.ry0m = [];%vertical launching positions [m_pol,1]
%
   launch.m0 = 0;%initial poloidal mode number
   launch.phi0 = 0;%toroidal angle position
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index (last 
   launch.LFS = 1;% (-1) high field side launching, (1) low field side launching

  
  
  
elseif strcmp(config,'CMOD');%For the Lower Hybrid wave simulations
   launch.type = 'LH';
   launch.omega_rf = [4.6]*2*pi*1e9;%wave angular frequency (rad/s)
   launch.bPlhtotp = [0.2]*1e6;%initial power in the ray (W) (main lobe) [1,n_lobe]
   launch.bNpar0p = [-1.55];%Initial Npar value (main lobe) [1,n_lobe]
   launch.bwidthp = [0.2];%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launch.ry0p = [-0.0535;0.0001;0.0535];%vertical launching positions [m_pol,1]
%
   launch.bPlhtotm = []*1e6;%initial power in the ray (W) (satellite lobe) [1,n_lobe]
   launch.bNpar0m = [];%Initial Npar value (satellite lobe) [1,n_lobe]
   launch.bwidthm = [];%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launch.ry0m = [];%vertical launching positions [m_pol,1]
%
   launch.m0 = 0;%initial poloidal mode number
   launch.phi0 = 0;%toroidal angle position
   launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index (last 
   launch.LFS = 1;% (-1) high field side launching, (1) low field side launching

	
	
	
	
	
	
	
	
	
	
	
	
	
	
elseif strcmp(config,'MIXTE');%For the Lower Hybrid wave simulations
	
	
	
	
elseif strcmp(config,'CIEL');%For the Lower Hybrid wave simulations
	
elseif strcmp(config,'JET');%For the Lower Hybrid wave simulations
elseif strcmp(config,'ITER3.7GHz');%For the Lower Hybrid wave simulations
elseif strcmp(config,'ITER5GHz');%For the Lower Hybrid wave simulations
	
	
else
   error('The launch configuration name does not exists')  	
end







