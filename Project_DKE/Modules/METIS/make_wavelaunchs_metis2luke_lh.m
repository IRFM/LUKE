function launchs = make_wavelaunchs_metis2luke_lh(option,lhparam)
%
% This function returns LH wave launching parameters
%
% by J. Decker and J.-F. Artaud, 02/02/2011
%
if lhparam.plh < lhparam.plhmin,% not enough power to account for wave
    launchs = cell(1,0);
    return
end
%
if lhparam.mode == 0,
    %
    % simple LUKE case with v1, v2, D, to match prescription or HXR profile
    %
    error('lhparam.mode = 0 not yet implemented')
    %
elseif lhparam.mode == 1,
    %
    % C3PO/LUKE case with one antenna and midplane vertical launching position
    %
    launch.id = 'LH';
    launch.type = 'LH';
    launch.omega_rf = lhparam.freqlh*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
    %
    if lhparam.lob,%negative lobe accounted for
        launch.bNpar0 = option.signe*[lhparam.npar0,-6];%wave parallel index of refraction [1,n_lobe]
        launch.bPlhtot = lhparam.plh*[lhparam.directivity,1 - lhparam.directivity];%wave initial power [1,n_lobe]
    else
        launch.bNpar0 = [lhparam.npar0];
        launch.bPlhtot = lhparam.plh*lhparam.directivity;
    end        
    %
    launch.bNpar0 = -option.signe*launch.bNpar0;% for co-current
    %
    launch.bdNpar0 = lhparam.dnpar0*ones(size(launch.bNpar0));%ray spectral width for Fokker-Planck calculations [1,n_lobe]
    %
    launch.rZ0 = lhparam.z0;%vertical launching positions (m) [1,m_pol]
    % 
    launch.m0 = lhparam.m0;%initial poloidal mode number [1,1]
    launch.phi0 = lhparam.phi0;%toroidal angle position [1,1]
    launch.i_ref = lhparam.i_ref;%Initial radial position index [1,1]
    launch.LFS = lhparam.LFS;% (-1) high field side launching, (1) low field side launching [1,1]
    launch.mmode = lhparam.mmode;% (-1) for slow wave, (1) for fast wave [1,1]
    launch.nparp = lhparam.nparp;% spectral broadening factor [1,1]
    launch.a_sdNpar = lhparam.a_sdNpar;  % initial spectral upshift [1,1]  
    %
    launchs{1} = launch;
    %
elseif lhparam.mode == 2,
    %
    % C3PO/LUKE case with detailed antenna structure and/or ALOHA
    %
    error('lhparam.mode = 2 not yet implemented')
    %
%     gene_lh.signe.b0 = 1;
%     gene_lh.signe.ip = option.signe;
%     %
%     par_lh.freqlh = lhparam.freqlh;
%     par_lh.aloha_mode = lhparam.aloha_mode;
%     par_lh.lob = lhparam.lob;
%     par_lh.conf = lhparam.conf;
%     par_lh.a_sdNpar = lhparam.a_sdNpar;
%     par_lh.nparp = lhparam.nparp;
%     %
%     cons_lh = lhparam.plh*exp(1i*lhparam.npar0);
%     %
%     launchs = make_wavelaunchs_cronos_lh(gene_lh,par_lh,cons_lh);%for the LH waves
    %
end
%

