function [launchs] = make_wavelaunchs_cronos_lh(equil,signe,config,cons,cons_spec,lob,freqlh,aloha)
%
if nargin < 7,
    freqlh = NaN;
end
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
    if isnan(freqlh),
        freqlh = [4.6,4.6];
    end
    %
    launchs{1}.id = 'Coupleur_C1';
    launchs{1}.type = 'LH';
    launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
    %
    directivity = [0.7];%Antenna directivity [1,1]
    %
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
    launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    launchs{1}.a_sdNpar = 0.0;%artificial upshift, 0.05 for TS
    %
    launchs{1}.rZ0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{1}.phi0 = [0];%toroidal angle position [1,1]
    launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
    launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
    launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
    %
    % ------- LH antenna #2 (C2) -------
    %
    launchs{2}.id = 'Coupleur_C2';
    launchs{2}.type = 'LH';
    launchs{2}.omega_rf = freqlh(2)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
    %
    directivity = [0.7];%Antenna directivity [1,1]
    %
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
    launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{2}.bdNpar0  = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    launchs{2}.a_sdNpar = 0.0;%artificial upshift, 0.05 for TS
    %
    launchs{2}.rZ0 = [-0.244,-0.162,-0.080,0.080,0.162,0.244];%vertical launching positions (m) [1,m_pol]
    %
    launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{2}.phi0 = [0];%toroidal angle position [1,1]
    launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
    launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
    launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- Tore Supra Mixte --------------------------------
%
elseif strcmp(config,'MIXTE') || strcmp(config,'MIXTE (TS)') ;%For the Lower Hybrid wave simulations
    %
    % ------- LH antenna #1 (C2) -------
    % 
    if isnan(freqlh),
        freqlh = [4.6,4.6];
    end
    %
    launchs{1}.id = 'Coupleur_C2';
    launchs{1}.type = 'LH';
    launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
    %
    directivity = [0.7];%Antenna directivity [1,1]
    %
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
    launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    launchs{1}.a_sdNpar = 0.0;%artificial upshift, 0.05 for TS
    %
    launchs{1}.rZ0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{1}.phi0 = [0];%toroidal angle position [1,1]
    launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
    launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
    launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
    %
    % ------- LH antenna #2 (C3) -------
    % 
    launchs{2}.id = 'Coupleur_C3';
    launchs{2}.type = 'LH';
    launchs{2}.omega_rf = freqlh(2)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
    %
    directivity = [0.6];%Antenna directivity [1,1]
    %
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
    launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
    launchs{2}.a_sdNpar = 0.0;%artificial upshift, 0.05 for TS
    %
    launchs{2}.rZ0 = [-0.244,-0.162,-0.080,0.080,0.162,0.244];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{2}.phi0 = [0];%toroidal angle position [1,1]
    launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
    launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
    launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- Tore Supra CIEL --------------------------------
%
elseif strcmp(config,'CIEL') | strcmp(config,'CIEL (TS)') ;%For the Lower Hybrid wave simulations
    %
    % ------- LH antenna #1 (C2) -------
    % 
    if isnan(freqlh),
        freqlh = [4.6,4.6];
    end
    %
    launchs{1}.id = 'Coupleur_C1';
    launchs{1}.type = 'LH';
    launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
    %
    directivity = [0.6];%Antenna directivity [1,1]
    %
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
    launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    launchs{1}.a_sdNpar = 0.0;%artificial upshift, 0.05 for TS
    %
    launchs{1}.rZ0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{1}.phi0 = [0];%toroidal angle position [1,1]
    launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
    launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
    launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
    %
    % ------- LH antenna #2 (C3) -------
    % 
    launchs{2}.id = 'Coupleur_C3';
    launchs{2}.type = 'LH';
    launchs{2}.omega_rf = freqlh(2)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
    %
    directivity = [0.6];%Antenna directivity [1,1]
    %
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
    launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
    launchs{2}.a_sdNpar = 0.0;%artificial upshift, 0.05 for TS
    %
    launchs{2}.rZ0 = [-0.244,-0.162,-0.080,0.080,0.162,0.244];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{2}.phi0 = [0];%toroidal angle position [1,1]
    launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
    launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
    launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- C-MOD --------------------------------
%
elseif strcmp(config,'CMOD');%For the Lower Hybrid wave simulations 
%
% ------- LH antenna #1 -------
% 
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [1.0];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons,cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- JET --------------------------------
%
elseif strcmp(config,'JET');%For the Lower Hybrid wave simulations
    %
    numa = length(cons);
    %
    % ------- LH antenna #1 -------
    % 
    if isnan(freqlh),
        freqlh = [3.7,3.7];
    end
    %
    launchs{1}.id = 'Antenna_1';
    launchs{1}.type = 'LH';
    launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
    %
    directivity = [0.7];%Antenna directivity [1,1]
    %
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
    launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{1}.bdNpar0 = 0.2*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    launchs{1}.a_sdNpar = 0.0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    %
    launchs{1}.rZ0 = [0.370 0.222 0.074 -0.074 -0.222 -0.370];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{1}.phi0 = [0];%toroidal angle position [1,1]
    launchs{1}.i_ref = length(equil.psi_apRp) - 2;%Initial radial position index [1,1]
    launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
    launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
    %
    % ------- LH antenna #2 -------
    % 
    if numa > 1 & cons(numa) > 0
        launchs{2}.id = 'Antenna_2';
        launchs{2}.type = 'LH';
        launchs{2}.omega_rf = freqlh(2)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
        %
        directivity = [0.7];%Antenna directivity [1,1]
        %
        [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
        launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
        launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
        %
        launchs{2}.bdNpar0 = 0.2*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
        launchs{2}.a_sdNpar = 0.0;%ray spectral width for Fokker-Planck calculations [1,n_lobe] 
        %
        launchs{2}.rZ0 = [0.370 0.222 0.074 -0.074 -0.222 -0.370];%vertical launching positions (m) [1,m_pol]
        % 
        launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
        launchs{2}.phi0 = [0];%toroidal angle position [1,1]
        launchs{2}.i_ref = length(equil.psi_apRp) - 2;%Initial radial position index [1,1]
        launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
        launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
    end
    %
%
% -------------------------------- ITER@3.7GHz --------------------------------
%
elseif strcmp(config,'ITER');%For the Lower Hybrid wave simulations
%
% ------- LH antenna #1 -------
% 
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [0.15,1.15];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% ------- LH antenna #2 -------
% 
%   launchs{2}.id = 'Antenna_2';
%   launchs{2}.type = 'LH';
%   launchs{2}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
%   directivity = [0.7];%Antenna directivity [1,1]
%
%   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons,cons_spec);%Power and parallel refractive index [1,n_lobe]
%   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
%   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
%
%   launchs{2}.bdNpar0 = [0.2,1.8];%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
%   launchs{2}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
%   launchs{2}.rZ0 = [0.15,1.15];%vertical launching positions (m) [1,m_pol]
% 
%   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
%   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
%   launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
%   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
%   launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave


%
% -------------------------------- FT-U --------------------------------
%
elseif strcmp(config,'FTU')
%
% ------- LH antenna #1 -------
% 
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.85];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.0;%artificial upshift, 0.05 for TS and FTU
%
   launchs{1}.rZ0 = [0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- SST-1 --------------------------------
%
elseif strcmp(config,'SST1')
%
% ------- LH antenna #1 -------
% 
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.75];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- DEMO --------------------------------
%
elseif strcmp(config,'DEMO')
%
% ------- LH antenna #1 -------
% 
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% ------- LH antenna #2 -------
% 
   launchs{2}.id = 'Antenna_2';
   launchs{2}.type = 'LH';
   launchs{2}.omega_rf = freqlh(2)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
   launchs{2}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{2}.rZ0 = [0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
   launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- COMPASS --------------------------------
%
elseif strcmp(config,'COMPASS');%For the Lower Hybrid wave simulations
%
% ------- LH antenna #1 -------
% 
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.00;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [-0.0535;0.0001;0.0535];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
   
elseif strcmp(config,'ASDEX');%For the Lower Hybrid wave simulations 
%
% ------- LH antenna #1 -------
% 
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.5]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [linspace(-0.35,-0.05,6) linspace(0.05,0.35,6)];%[-0.35,0,0.35];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% ------- LH antenna #2 -------
% 
   launchs{2}.id = 'Antenna_2';
   launchs{2}.type = 'LH';
   launchs{2}.omega_rf = [3.7]*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{2}.bdNpar0 = [0.5]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{2}.a_sdNpar = 0.0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{2}.rZ0 = [linspace(-0.35,-0.05,6) linspace(0.05,0.35,6)];%vertical launching positions (m) [1,m_pol]
% 
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
elseif strcmp(config,'EAST');%For the Lower Hybrid wave simulations 
%
% ------- LH antenna #1 -------
% 
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),cons_spec,lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.5]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.a_sdNpar = 0.0;%artificial upshift, 0.05 for TS and FTU and EAST
%
   launchs{1}.rZ0 = [-0.05 0 0.05];%[-0.35,0,0.35];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
else
   error('The launch configuration name does not exists')  	
end

if any(aloha.mode==1) & (strcmp(config,'CIEL')|strcmp(config,'TS')|strcmp(config,'ITER'))
    disp('use ALOHA file for the power spectrum, TS case')
    nblh   = length(aloha.mode);
    %
    for i=1:nblh
      if aloha.mode(i) == 1
        filename = deblank(char(aloha.file(i)));
        filename(isspace(filename)) = [];
        load(fullfile(aloha.path,filename));
        scheme  = scenario(aloha.scen);
        results = scheme(i).results;
        redfac = abs(cons(i))/(sum(results.dP_nz)*results.dnz);
        [bNpar0,bdNpar0,bPlhtot] = proc_aloha_spec_jd(results.nz,NaN,results.dP_nz,redfac,aloha.param(i));
        %
        if strcmp(lob,'No');
            mask = bNpar0 > 0;
            bNpar0 = bNpar0(mask);
            bdNpar0 = bdNpar0(mask);
            bPlhtot = bPlhtot(mask);
        end
        %
        bNpar0 = -signe.ip*signe.b0*bNpar0;%sign in aloha is positive
        %
        launchs{i}.bdNpar0    = bdNpar0;
        launchs{i}.bNpar0     = bNpar0;
        launchs{i}.bPlhtot    = bPlhtot;
        launchs{i}.aloha  = aloha;
        launchs{i}.aloha.file = fullfile(aloha.path,char(aloha.file(i)));
      end
    end
end



