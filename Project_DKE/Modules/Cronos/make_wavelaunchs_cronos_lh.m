function [launchs] = make_wavelaunchs_cronos_lh(gene,par,cons,signe,conf,lob,freqlh,aloha_mode)
%
if nargin >= 8,
    par.aloha_mode = aloha_mode;
end
%
if nargin >= 7,
    par.freqlh = freqlh;
end
%
if nargin >= 6,
    par.lob = lob;
end
%
if nargin >= 5,
    par.conf = conf;
end
%
if nargin >= 4,
    gene.signe = signe;
end
%
if isempty(cons),
    launchs = cell(0,1);
    return
else
    nlh = length(cons);
end
%
if isfield(par,'lob')
    lob = par.lob;
else
    lob = 'No';
end
%
if isfield(par,'freqlh')
    freqlh = par.freqlh;
else
    freqlh = NaN;
end
%
conf = par.conf;
%
signe = gene.signe;
%
if ~isempty(strfind(conf,' (TS)'))
    conf = conf(1:(strfind(conf,' (TS)')-1));    
end
%
if isfield(par,'aloha_mode')
    for ilh = 1:nlh,
        aloha(ilh).mode    = par.aloha_mode(ilh);
        aloha(ilh).param   = par.aloha_param(ilh) + 1i*par.aloha_param0(ilh);
        aloha(ilh).file    = fullfile(fileparts(gene.file),strtrim(par.aloha_file{ilh}));
        aloha(ilh).scen    = par.aloha_scen(ilh);
    end
else
   for ilh = 1:nlh,
     aloha(ilh).mode = zeros(1,nlh);
   end
end
%
% Create the structure launch for CRONOS
%
%by Y.Peysson <yves.peysson@cea.fr> (CEA-DRFC) and J. Decker <joan.decker@cea.fr> (CEA-DRFC)
%
% -------------------------------- Tore Supra --------------------------------
%
if strcmp(conf,'TS');%For the Lower Hybrid wave simulations
    %
    % ------- LH antenna #1 (C1) -------
    %
    if nlh ~= 2,
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
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
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),lob);%Power and parallel refractive index [1,n_lobe]
    launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    %
    launchs{1}.rZ0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{1}.phi0 = [0];%toroidal angle position [1,1]
    launchs{1}.i_ref = -1;%Initial radial position index [1,1]
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
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),lob);%Power and parallel refractive index [1,n_lobe]
    launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{2}.bdNpar0  = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    %
    launchs{2}.rZ0 = [-0.244,-0.162,-0.080,0.080,0.162,0.244];%vertical launching positions (m) [1,m_pol]
    %
    launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{2}.phi0 = [0];%toroidal angle position [1,1]
    launchs{2}.i_ref = -1;%Initial radial position index [1,1]
    launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
    launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- Tore Supra Mixte --------------------------------
%
elseif strcmp(conf,'MIXTE') || strcmp(conf,'MIXTE (TS)') ;%For the Lower Hybrid wave simulations
    %
    % ------- LH antenna #1 (C2) -------
    %
    if nlh ~= 2,
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
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
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),lob);%Power and parallel refractive index [1,n_lobe]
    launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    %
    launchs{1}.rZ0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{1}.phi0 = [0];%toroidal angle position [1,1]
    launchs{1}.i_ref = -1;%Initial radial position index [1,1]
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
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),lob);%Power and parallel refractive index [1,n_lobe]
    launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
    %
    launchs{2}.rZ0 = [-0.244,-0.162,-0.080,0.080,0.162,0.244];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{2}.phi0 = [0];%toroidal angle position [1,1]
    launchs{2}.i_ref = -1;%Initial radial position index [1,1]
    launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
    launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- Tore Supra CIEL --------------------------------
%
elseif strcmp(conf,'CIEL') | strcmp(conf,'CIEL (TS)') ;%For the Lower Hybrid wave simulations
    %
    % ------- LH antenna #1 (C2) -------
    %
    if nlh ~= 2,
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
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
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),lob);%Power and parallel refractive index [1,n_lobe]
    launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    %
    launchs{1}.rZ0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{1}.phi0 = [0];%toroidal angle position [1,1]
    launchs{1}.i_ref = -1;%Initial radial position index [1,1]
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
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),lob);%Power and parallel refractive index [1,n_lobe]
    launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
    %
    launchs{2}.rZ0 = [-0.244,-0.162,-0.080,0.080,0.162,0.244];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{2}.phi0 = [0];%toroidal angle position [1,1]
    launchs{2}.i_ref = -1;%Initial radial position index [1,1]
    launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
    launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
    %
    % -------------------------------- C-MOD --------------------------------
    %
elseif strcmp(conf,'CMOD');%For the Lower Hybrid wave simulations 
    %
    % ------- LH antenna #1 -------
    %
    if nlh ~= 1,
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
% 
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [1.0];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons,lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [0,0,0,0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = -1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- JET --------------------------------
%
elseif strcmp(conf,'JET');%For the Lower Hybrid wave simulations
    %
    if ~any(nlh == [1,2]),
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
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
    [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),lob);%Power and parallel refractive index [1,n_lobe]
    launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
    launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
    %
    launchs{1}.bdNpar0 = 0.2*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    %
    launchs{1}.rZ0 = [0.370 0.222 0.074 -0.074 -0.222 -0.370];%vertical launching positions (m) [1,m_pol]
    % 
    launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
    launchs{1}.phi0 = [0];%toroidal angle position [1,1]
    launchs{1}.i_ref = -2;%Initial radial position index [1,1]
    launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
    launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
    %
    % ------- LH antenna #2 -------
    % 
    if nlh > 1,
        launchs{2}.id = 'Antenna_2';
        launchs{2}.type = 'LH';
        launchs{2}.omega_rf = freqlh(2)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
        %
        directivity = [0.7];%Antenna directivity [1,1]
        %
        [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),lob);%Power and parallel refractive index [1,n_lobe]
        launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
        launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
        %
        launchs{2}.bdNpar0 = 0.2*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
        %
        launchs{2}.rZ0 = [0.370 0.222 0.074 -0.074 -0.222 -0.370];%vertical launching positions (m) [1,m_pol]
        % 
        launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
        launchs{2}.phi0 = [0];%toroidal angle position [1,1]
        launchs{2}.i_ref = -2;%Initial radial position index [1,1]
        launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
        launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
    end
    %
%
% -------------------------------- ITER@3.7GHz --------------------------------
%
elseif strcmp(conf,'ITER');%For the Lower Hybrid wave simulations
%
% ------- LH antenna #1 -------
% 
    if nlh ~= 1,
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
    %
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
%
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [0.15,1.15];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = -1;%Initial radial position index [1,1]
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
%   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons);%Power and parallel refractive index [1,n_lobe]
%   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
%   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
%
%   launchs{2}.bdNpar0 = [0.2,1.8];%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
%
%   launchs{2}.rZ0 = [0.15,1.15];%vertical launching positions (m) [1,m_pol]
% 
%   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
%   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
%   launchs{2}.i_ref = -1;%Initial radial position index [1,1]
%   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
%   launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave


%
% -------------------------------- FT-U --------------------------------
%
elseif strcmp(conf,'FTU')
%
% ------- LH antenna #1 -------
% 
    if nlh ~= 1,
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
    %
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.85];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = -1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- SST-1 --------------------------------
%
elseif strcmp(conf,'SST1')
%
% ------- LH antenna #1 -------
% 
    if nlh ~= 1,
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
    %
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.75];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = -1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- DEMO --------------------------------
%
elseif strcmp(conf,'DEMO')
%
% ------- LH antenna #1 -------
% 
    if nlh ~= 2,
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
    %
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
%
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = -1;%Initial radial position index [1,1]
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
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),lob);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
%
   launchs{2}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations (main lobe) [1,n_lobe]
%
   launchs{2}.rZ0 = [0];%vertical launching positions (m) [1,m_pol]
% 
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = -1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]  
   launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% -------------------------------- COMPASS --------------------------------
%
elseif strcmp(conf,'COMPASS');%For the Lower Hybrid wave simulations
%
% ------- LH antenna #1 -------
% 
    if nlh ~= 1,
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
    %
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
%
   launchs{1}.bdNpar0 = [0.2]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [-0.0535;0.0001;0.0535];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = -1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
   
elseif strcmp(conf,'AUG') || strcmp(conf,'ASDEX');%For the Lower Hybrid wave simulations 
%
% ------- LH antenna #1 -------
% 
    if nlh ~= 2,
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
    %
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
%
   launchs{1}.bdNpar0 = [0.5]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{1}.rZ0 = [linspace(-0.35,-0.05,6) linspace(0.05,0.35,6)];%[-0.35,0,0.35];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = -1;%Initial radial position index [1,1]
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
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(2),lob);%Power and parallel refractive index [1,n_lobe]
   launchs{2}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{2}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
%
   launchs{2}.bdNpar0 = [0.5]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
   launchs{2}.rZ0 = [linspace(-0.35,-0.05,6) linspace(0.05,0.35,6)];%vertical launching positions (m) [1,m_pol]
% 
   launchs{2}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{2}.phi0 = [0];%toroidal angle position [1,1]
   launchs{2}.i_ref = -1;%Initial radial position index [1,1]
   launchs{2}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
elseif strcmp(conf,'EAST');%For the Lower Hybrid wave simulations 
%
% ------- LH antenna #1 -------
% 
    if nlh ~= 1,
        error('Mismatch in antenna number between LH cons and make_wavelaunchs_cronos_lh')
    end
    %
   launchs{1}.id = 'Antenna_1';
   launchs{1}.type = 'LH';
   launchs{1}.omega_rf = freqlh(1)*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
%
   directivity = [0.7];%Antenna directivity [1,1]
%
   [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons(1),lob);%Power and parallel refractive index [1,n_lobe]
   launchs{1}.bPlhtot = Plhtot;%initial power in the ray (W) [1,n_lobe]
   launchs{1}.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]
 %
   launchs{1}.bdNpar0 = [0.5]*ones(size(Npar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   launchs{1}.rZ0 = [-0.05 0 0.05];%[-0.35,0,0.35];%vertical launching positions (m) [1,m_pol]
% 
   launchs{1}.m0 = [0];%initial poloidal mode number [1,1]
   launchs{1}.phi0 = [0];%toroidal angle position [1,1]
   launchs{1}.i_ref = -1;%Initial radial position index [1,1]
   launchs{1}.LFS = [1];% (-1) high field side launching, (1) low field side launching [1,1]
   launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
else
   error('The launch configuration name does not exists')  	
end
%
% ============================= ALOHA =====================================
%
for ilh=1:nlh,
    if aloha(ilh).mode == 1 && abs(cons(ilh)) > 0,
        %
        disp(['use ALOHA file for the power spectrum of LH wave # ',num2str(ilh)])
        %
        load(aloha(ilh).file);
        scheme  = scenario(aloha(ilh).scen);
        results = scheme.results;
        redfac = abs(cons(ilh))/(sum(results.dP_nz)*results.dnz);
        param = aloha(ilh).param;%number of fitted peaks + number of peaks left intact
        opt_optim = 0; %(if 1 use  toolbox optimisation)
        [bNpar0,bdNpar0,bPlhtot] = proc_aloha_spec_jd(results.nz,NaN,results.dP_nz,redfac,param,opt_optim);
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
        launchs{ilh}.bdNpar0    = bdNpar0;
        launchs{ilh}.bNpar0     = bNpar0;
        launchs{ilh}.bPlhtot    = bPlhtot;
    end
    %
    launchs{ilh}.aloha  = aloha(ilh);
end
%
% ====================== OTHER PARAMETERS ==========================
%
%
for ilh=1:nlh,
    %
    launch = launchs{ilh};
    %
    if isfield(par,'nparp') && par.nparp(ilh) ~= 0,
        for ib = 1:length(launch.bNpar0),
            disp(['artificial upshift for LH wave ',num2str(ilh),...
                ' Npar0: ',num2str(launch.bNpar0(ib)),' ==> ',num2str(launch.bNpar0(ib) + sign(launch.bNpar0(ib)).*par.nparp(ilh))])
            launch.bNpar0(ib) = launch.bNpar0(ib) + sign(launch.bNpar0(ib)).*par.nparp(ilh);
        end
    else
        launch.nparp = 0;
    end
    %
    if isfield(par,'a_sdNpar') && par.a_sdNpar(ilh) ~= 0,
        launch.a_sdNpar = par.a_sdNpar(ilh);
        disp(['artificial upshift for LH wave ',num2str(ilh),...
            ': a_sdNpar = ',num2str(par.a_sdNpar(ilh))])
    else
        launch.a_sdNpar = 0;
    end
    %
    launchs{ilh} = launch;
    %
end
%



