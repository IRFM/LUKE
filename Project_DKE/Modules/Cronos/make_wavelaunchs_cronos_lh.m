function [launchs] = make_wavelaunchs_cronos(equil,config,cons,cons_spec)
%
% Create the structure launch for CRONOS
%
%by Y.Peysson <yves.peysson@cea.fr> (CEA-DRFC) and J. Decker <joan.decker@cea.fr> (CEA-DRFC)
%
% -------------------------------- Tore Supra --------------------------------
%
if strcmp(config,'TS');%For the Lower Hybrid wave simulations
%
% ------- LH antenna #1 (C1) -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.05;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
%
% ------- LH antenna #2 (C2) -------
% 
   launchs{2}.type = 'LH';
   launchs{2}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
%
   launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{2}.a_sdNpar = 0.05;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{2}.ry0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
%
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
%
% -------------------------------- Tore Supra Mixte --------------------------------
%
elseif strcmp(config,'MIXTE');%For the Lower Hybrid wave simulations
%
% ------- LH antenna #1 (C2) -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons(1),cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.05;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
%
% ------- LH antenna #2 (C3) -------
% 
   launchs{2}.type = 'LH';
   launchs{2}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.6];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons(2),cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
   launchs{2}.a_sdNpar = 0.05;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{2}.ry0 = [-0.244,-0.162,-0.080,0.080,0.162,0.244];%vertical launching positions (m) [1,m_pol]
% 
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
%
% -------------------------------- Tore Supra CIEL --------------------------------
%
elseif strcmp(config,'CIEL');%For the Lower Hybrid wave simulations
%
% ------- LH antenna #1 (C2) -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.6];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.05;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
%
% ------- LH antenna #2 (C3) -------
% 
   launchs{2}.type = 'LH';
   launchs{2}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.6];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
   launchs{2}.a_sdNpar = 0.05;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{2}.ry0 = [-0.244,-0.162,-0.080,0.080,0.162,0.244];%vertical launching positions (m) [1,m_pol]
% 
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
%
% -------------------------------- C-MOD --------------------------------
%
elseif strcmp(config,'CMOD');%For the Lower Hybrid wave simulations 
%
% ------- LH antenna #1 -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [4.6]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [1.0];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
%
% -------------------------------- JET --------------------------------
%
elseif strcmp(config,'JET');%For the Lower Hybrid wave simulations
%
% ------- LH antenna #1 -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
%
% ------- LH antenna #2 -------
% 
   launchs{2}.type = 'LH';
   launchs{2}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
   launchs{2}.a_sdNpar = 0.0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{2}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
%
% -------------------------------- ITER@3.7GHz --------------------------------
%
elseif strcmp(config,'ITER3.7GHz');%For the Lower Hybrid wave simulations
%
% ------- LH antenna #1 -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
%
% ------- LH antenna #2 -------
% 
   launchs{2}.type = 'LH';
   launchs{2}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
   launchs{2}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{2}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
%
% -------------------------------- ITER@5.0GHz --------------------------------
%
elseif strcmp(config,'ITER5GHz');%For the Lower Hybrid wave simulations
%
% ------- LH antenna #1 -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [5.0]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
%
% ------- LH antenna #2 -------
% 
   launchs{2}.type = 'LH';
   launchs{2}.omega_rf = [5.0]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
   launchs{2}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{2}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
%
% -------------------------------- FT-U --------------------------------
%
elseif strcmp(config,'FTU')
%
% ------- LH antenna #1 -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [8.0]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.85];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
%
% -------------------------------- SST-1 --------------------------------
%
elseif strcmp(config,'SST1')
%
% ------- LH antenna #1 -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.75];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
%
% -------------------------------- DEMO@3.7GHz --------------------------------
%
elseif strcmp(config,'DEMO3.7GHz')
%
% ------- LH antenna #1 -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
%
% ------- LH antenna #2 -------
% 
   launchs{2}.type = 'LH';
   launchs{2}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
   launchs{2}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{2}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
%
% -------------------------------- DEMO@5.0GHz --------------------------------
%
elseif strcmp(config,'DEMO5.0GHz')
%
% ------- LH antenna #1 -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [5.0]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
%
% ------- LH antenna #2 -------
% 
   launchs{2}.type = 'LH';
   launchs{2}.omega_rf = [5.0]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
   launchs{2}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{2}.ry0 = [0,0,0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
%
% -------------------------------- COMPASS --------------------------------
%
elseif strcmp(config,'COMPASS');%For the Lower Hybrid wave simulations
%
% ------- LH antenna #1 -------
% 
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = [1.3]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.ry0 = [-0.0535;0.0001;0.0535];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
else
   error('The launch configuration name does not exists')  	
end







