%
% Script for studying effects of wave properties on heating and current drive with C3PO/LUKE 
%
% Results may be interactively displayed with irunluke_jd.m or iluke.m
%
% Can be modified by the user for specific studies
%
% by Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr> and J. Decker (CEA-IRFM) <joan.decker@cea.fr>
%
%*********************************************************************
%*********************************************************************
% WARNING: check the magnetic equilibrium first before !!!
% LUKE definition: Sign(Ip) > 0 and Sign(BPHI) > 0 is when Ip and BPHI 
% are clockwise when the tokamak is viewed from the top.
%*********************************************************************
%*********************************************************************
%
clear all
clc
warning('off')
%
% ---------------------- Remote/distributed computing ---------------------
%
computing_opts.remprofile = 'shenma';% remote profile name. Leave empty for an interactive choice of a remote profile or 'local' for local calculations
computing_opts.remnum = 11;% if it is defined (not NaN or empty) it overrides 'remprofile' field. 0: local sequential calculation
%
computing_opts.remtimout = 0;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
computing_opts.rempause = 5;% pause between job checks (in minutes) (only for remtimout > 0)
computing_opts.remstart = 0;% (1) start new simulation; (0) check older simulation (only for remtimout = 0)
computing_opts.remdebugmode = 0;% debug mode (0) off (1) on
computing_opts.remclean = 2;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
%
computing_opts.opt.save = 0;% (1): save LUKE_RESULTS or return error (0): return results or error
computing_opts.opt.fields = NaN;% selected fields in returned lukestructs. Use NaN for all fields
computing_opts.opt.backup = 0;% (1) save fluctuation time steps (0) do not save
computing_opts.opt.waves = -1;%(-1) waves are not saved in "wave_results/" and not stored in dke_out. In this case, C3PO must be rerun to see the rays (0) waves are stored in dke_out and saved in LUKE_RESULTS, (1) waves are saved in "wave_results/" but not stored in dke_out
computing_opts.opt.saveinputs = 0;% (1) save input structures in .mat files before starting (0) do not save
%
computing_opts.simul_path = '';
computing_opts.opt_struct = 0;%(0) light version, compatible with fluctuations, proc_luke and runhxr, (1) : heavy version, all fields are kept except XYD_rf and gridindex_rf (rarely used, except for looking for bug), (2) : full version,all fields are kept.
%
% ---------------------------------- Data load -----------------------------------
%
external_data.mode = 1;% (1) load and build equilibrium data from an external database, (0) load from local files at the LUKE format
external_data.remprofile = '';% remote profile name. Leave empty for interactive choice of a remote profile or 'local' for local calculations
external_data.remnum = 0;% if it is defined (not NaN or empty) it overrides 'remprofile' field,0: local access
%
% ------------------ Toroidal MHD equilibrium inputs ----------------------
%
tokamak_name = 'EAST';
shot_number = '043326';
time_slice = '012000';
%
simul_name = 'TRANSP_EM2';
%
%  ----------------------- Calculation parameters -------------------------
%
maxlaunchedjob = 110;%maximumum number of simulations in parallel. Uncomment and set to the level compatible with the cluster
redocrashedjobs = 1;%force to relaunched jobs that have been lost (lost network connections...)
forcepostprocessing = 1;%force rebuild post processed data
%icanceljob = 43;%cancel a job, and if redocrashedjobs = 1, relaunch it. Once used, comment the line otherwise it will cancel the job each time the script is launched
displayjobtimeid = 1;%display the job if necessary
%
rho_S = 25;%Number of magnetic flux surfaces (LUKE Fokker-Planck calculations). The grid is automatically optimized otherwise the exect normalized grid must be specified. (If one value: local calculation only, not used if empty)
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
%
% ------------------------ Display option  --------------------------------
% 
ij_scan_display = [3,7];%list of (i,j) values at which results are displayed (separated by ;)
ir_display = 10;%minor radius at which local data are displayed (0): no display, or a vector of index
%iscan_nodisplay = NaN;% a vector of index
p_opt = 0;%Display and printing options (-1: no display, 0: display, 1: display + save, 2: display + save + print)
%
%----------------------------- Wave scans  --------------------------------
%
scan(1).iantenna = 1;% antenna number that is concerned by the wave scan (leave empty or NaN if not used)
scan(1).type = 'Npar0';% leave empty if no wave scan. It must be a field of the antenna_data structure (see below)
scan(1).value = [1.8:0.1:2.3];%Put NaN for the value that must be replaced for the scan in the corresponding field
scan(1).label = 'N_{||0}';%for display
scan(1).unit = 'a.u.';%for display
%
scan(2).iantenna = 1;% antenna number that is concerned by the wave scan (leave empty or NaN if not used)
scan(2).type = 'P0';% leave empty if no wave scan. It must be a field of the antenna_data structure (see below)
scan(2).value = [0.01,0.02,0.05,0.1,0.2,0.5,1.0,2.0];%Put NaN for the value that must be replaced for the scan in the corresponding field
scan(2).label = 'P_{LH}';%for display
scan(2).unit = 'MW';%for display
%
%----------------------------- Antennas descriptions -----------------------------------
%
antenna_data(1).type = 'LH';% Wave type (LH,EC)
antenna_data(1).freq = 2.4;% Wave frequency in Ghz
antenna_data(1).mode = 'SW';% LH wave: SW/FW, EC wave: O/X
%
antenna_data(1).Npar0 = [NaN];%List of lobes in the power spectrum (Npar < 0 if sign(Ip.BPHI) > 0 otherwise Npar > 0)
antenna_data(1).dNpar0 = [0.23];% List of spectral widths 
antenna_data(1).P0 = [NaN];% List of power carried by rays (MW)
%antenna_data(1).P0 = [0.0610,0.0330,0.4420,0.0180,0.0700];% List of power carried by rays (MW)
antenna_data(1).phasing = NaN;%use full spectrum from ALOHA calculation
%
antenna_data(1).rZ0 = [-0.1460,-0.2920,0,0.2920,0.1460];%vertical launching positions [1,m_pol]
antenna_data(1).m0 = 0;%initial poloidal mode number [1,1]
antenna_data(1).phi0 = 0;%toroidal angle position [1,1]
antenna_data(1).LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
antenna_data(1).i_ref = -1;%Initial radial position index, relative to LCFS [1,1]
%
% As many antenna of different types may be added
%
%antenna_data(2).type = 'LH';% Wave type (LH,EC)
%antenna_data(2).freq = 4.6;% Wave frequency in Ghz
%antenna_data(2).mode = 'SW';% LH wave: SW/FW, EC wave: O/X
%
%antenna_data(2).Npar0 = [-7.2000 -6.3000 2.1000 2.5000 3.1000];%List of lobes in the power spectrum (Npar < 0 if sign(Ip.BPHI) > 0 otherwise Npar > 0)
%antenna_data(2).dNpar0 = [0.2200 0.2100 0.2300 0.1400 0.2100];% List of spectral widths 
%antenna_data(2).P0 = 0*[0.2540 0.1380 1.8420 0.0740 0.2920];% List of power carried by rays (MW)
%antenna_data(2).phasing = NaN;%use full spectrum from ALOHA calculation
%
%antenna_data(2).rZ0 = [0.2910 0.0970 -0.0970 -0.2910];%vertical launching positions [1,m_pol]
%antenna_data(2).m0 = 0;%initial poloidal mode number [1,1]
%antenna_data(2).phi0 = 0;%toroidal angle position [1,1]
%antenna_data(2).LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
%antenna_data(2).i_ref = -1;%Initial radial position index, relative to LCFS [1,1]
%
%antenna_data(3).type = 'EC';% Wave type (LH,EC)
%antenna_data(3).freq = 140;% Wave frequency in Ghz
%antenna_data(3).mode = 'X';% LH wave: SW/FW, EC wave: O/X
%
%antenna_data(3).yZ_L = 0.3;% Mirror vertical position (m) [1,1]
%antenna_data(3).yR_L = 3;% Mirror major radius (m) [1,1]
%antenna_data(3).yphi_L = 0;% Mirror toroidal angle position (deg) [1,1]
%antenna_data(3).yalpha_L = -160;% Mirror horizontal angle with respect to the major radius direction (deg) [1,1]
%antenna_data(3).ybeta_L = 110;% Mirror vertical angle with respect to the major radius direction (deg) [1,1]
%antenna_data(3).yP_L = 1;%Launched power (MW) [1,1]
%antenna_data(3).w0 = 0.0136;% Beam_width (m) [1,1]
%antenna_data(3).z0 = 0.0940;% Focal point distance from mirror (m) [1,1]
%
%antenna_data(4).type = 'EC';% Wave type (LH,EC)
%antenna_data(4).freq = 170;% Wave frequency in Ghz
%antenna_data(4).mode = 'X';% LH wave: SW/FW, EC wave: O/X

%antenna_data(4).yZ_L = 0.3;% Mirror vertical position (m) [1,1]
%antenna_data(4).yR_L = 3;% Mirror major radius (m) [1,1]
%antenna_data(4).yphi_L = 0;% Mirror toroidal angle position (deg) [1,1]
%antenna_data(4).yalpha_L = -160;% Mirror horizontal angle with respect to the major radius direction (deg) [1,1]
%antenna_data(4).ybeta_L = 110;% Mirror vertical angle with respect to the major radius direction (deg) [1,1]
%antenna_data(4).yP_L = 1;%Launched power (MW) [1,1]
%antenna_data(4).w0 = 0.0136;% Beam_width (m) [1,1]
%antenna_data(4).z0 = 0.0940;% Focal point distance from mirror (m) [1,1]
%
% Launched tail LH power spectrum model (can be used only if one lobe in Npar0)
%
%   - static mode (if dtn_fluct_correlation_npar0_lh = Inf, fast calculations)
%   - fluctuating mode (if dtn_fluct_correlation_npar0_lh < Inf, very long calculations).
%
dtn_fluct_correlation_npar0_lh = Inf;%
%
tail_mode = 0;% Mode for tail spectrum : (0) no tail model, (1)  Gaussian, (2) Linear, (3) calc_tail_jd
Nparmax_tail = 20;% npar0 extend from npar_antenna to Nparmax_tail. If Nparmax_tail is 0, it is calculated by the code in main_rayinit_launch_jd.m -> 6.5/sqrt(Te0)
opt_tail_0 = 0;% Final power fraction of the tail @ Nparmax_tail.
n_tail = 20;% Number of lobes to describe the tail. If n_tail = 0, no tail up to Nparmax_tail (tail_mode = 3 only). 
P_tail = 0.5;% Power fraction in the tail. If NaN, it is calculated from n_tail and opt_tail (tail_mode = 3 only). 
dnpar0_tail = 1;% Adjust (1) or not (0) the initial dNpar0 such that intial and tail lobes have the same width (tail_mode = 3 only).
%
if ~exist('simul_name','var'),simul_name = '';end
%
for iscan = 1:length(scan),
    if ~isempty(scan(iscan).type) && ~isempty(scan(iscan).iantenna) && ~isempty(scan(iscan).value),
        simul_name = [simul_name,'_ANTENNA_',int2str(scan(iscan).iantenna),'_FREQ_',num2str(antenna_data(scan(iscan).iantenna).freq),'GHz_',antenna_data(scan(iscan).iantenna).type,'_SCAN_',scan(iscan).type,simul_name];
    end
end
%
isim = 1;%simulation index
%
if isempty(scan(2).type),
    nsim = length(scan(1).value);
    index = [1:nsim];
    scan_type = scan(1).type;
elseif isempty(scan(1).type),
    nsim = length(scan(2).value);
    index = [1:nsim];
    scan_type = scan(2).type;
else
    nsim = length(scan(1).value)*length(scan(2).value);
    %
    index = [];
    for iscan = 1:length(scan(1).value),
         for jscan = 1:length(scan(2).value),
            index = [index;[iscan,jscan]];
         end
    end
    %
    scan_type = [scan(1).type,'-',scan(2).type];
end
%
id_equil = [tokamak_name,'_',shot_number,'_',time_slice];%base name for the simulation and the toroidal MHD equilibrium
dataname = [id_equil,simul_name];%full name  
%
filesimul = [pwd,'/LUKE_RESULTS_',dataname,'.mat'];
fileexternal = [pwd,'/EXTERNAL_',id_equil,'.mat'];
fileequil = [pwd,'/EQUIL_',id_equil,'.mat'];
%
if ~exist(filesimul,'file') || redocrashedjobs,
    %
    % ---------------------------- LUKE simulation inputs -----------------------------
    %
    id_dkepath = '';%For all paths used by LUKE
    path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
    %
    id_dkedisplay = 'NO_DISPLAY';%'PARTIAL_VISUAL';%For output code display
    path_dkedisplay = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
    %
    equilpath_name = '';%Where the toroidal MHD equilibrium is placed
    path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
    %
    id_ohm = '';%For Ohmic electric contribution
    path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
    %
    id_transpfaste = 'EM2';%For fast electron anomalous radial transport
    path_transpfaste = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
    %
    id_ripple = '';%For fast electron magnetic ripple losses
    path_ripple = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
    %
    antenna_types = '';
    %
    for iantenna = 1:length(antenna_data),
        antenna_types = [antenna_types,antenna_data(iantenna).type];
    end
    %
    if ~isempty(strfind(antenna_types,'LH')) && isempty(strfind(antenna_types,'EC'))
        id_dkeparam = 'LH_RT';%For LUKE code parameters
        path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
    elseif ~isempty(strfind(antenna_types,'EC')) && isempty(strfind(antenna_types,'LH'))
        id_dkeparam = 'EC_RT';%For LUKE code parameters
        path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
    else
        error('The wave type is not recognized in the simulation name.')
    end
    %
    if isfield(computing_opts,'opt_struct'),
        dkeparam.opt_struct = computing_opts.opt_struct;
    end
    %
    % ------------------------- Test remote connections ------------------------------
    %
    dkepath = load_structures_yp('dkepath',id_dkepath,path_dkepath);
    %
    if ~isfield(computing_opts,'remnum') || isempty(computing_opts.remnum) || isnan(computing_opts.remnum)
        computing_opts.remnum = select_remote_profile_yp(computing_opts.remprofile,dkepath);
    end
    %
    if external_data.mode,%load from an external database
        %
        if ~isfield(external_data,'remnum') || isempty(external_data.remnum) || isnan(external_data.remnum) 
            external_data.remnum = select_remote_profile_yp(external_data.remprofile,dkepath);
        end
        %
        if ~external_data.remnum,
            external_data_remote = [];
        else
            [external_data_remote] = load_remoteprofiles_jd(dkepath.remote(external_data.remnum));
        end
    else
        external_data_remote = [];
    end
    %
    % ------------------ load external data ---------------
    %
    if external_data.mode,
        if ~exist(fileexternal,'file')
            %
            external_in.workdir = 'DATA';
            external_in.shotnum = shot_number;
            external_in.shotime = time_slice;
            %
            [err,~,external] = matremote_jd(['load_externaldata_',tokamak_name],{external_in},external_data_remote);
            %
            if ~isempty(err) || isempty(external),
                error('ERROR: not able to load external data');
            end
            %
            save(['EXTERNAL_',id_equil,'.mat'],'external');
        else
            load(['EXTERNAL_',id_equil,'.mat'],'external');
        end
        %
        if ~exist(fileequil,'file'),
            %
            select.i_opt = 0;
            select.idequil = 1;
            select.disp = 1;
            select.print = 1;
            %
            equil = imake_equil_jd('',tokamak_name,'',external.equil,'',0,select);%make LUKE equilibrium from external data
            %
            save(['EQUIL_',id_equil,'.mat'],'equil');
            %
        end
    end
    %
    [equil,ohm,transpfaste,ripple,dkeparam,dkedisplay] = load_structures_yp('equil',id_equil,path_equil,'ohm',id_ohm,path_ohm,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_dkedisplay,path_dkedisplay);
    %
    % ----------------------------------- Setup parameters -------------------------
    %
    dkeparam.rho_S = rho_S;
    dkeparam.psin_S = psin_S;
    %
    if exist('dmumpsmex','file'),%MUMPSMEX fast linear sustem solver
        dkeparam.invproc = -2;
    end
    %
    dkepath.remnum = computing_opts.remnum;% remote profile number. Use 0 for local sequential calculations
    dkepath.remtimout = computing_opts.remtimout;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
    dkepath.rempause = computing_opts.rempause;% pause between job checks (in minutes) (only for remtimout > 0)
    dkepath.debugmode = computing_opts.remdebugmode;% debug mode (0) off (1) on
    dkepath.clean = computing_opts.remclean;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
    %
    if computing_opts.opt.waves == 1 && computing_opts.remnum > 0,
        computing_opts.opt.waves = 0;
        disp('WARNING: computing_opts.opt.waves = 1 is forbiden when remote computing is used. It is enforced to 0 to avoid simulation error')
    end
    %
    % ------------------------Build structures ----------------------------------
    %
    for iscan = 1:length(scan(1).value),
        %
        for jscan = 1:length(scan(2).value),
            %
            for iantenna = 1:length(antenna_data),
                %
                launch = struct;
                %
                id_rtparam = antenna_data(iantenna).type;%For C3PO code parameters
                path_rtparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
                rtparam = load_structures_yp('rtparam',id_rtparam,path_rtparam);%Default ray-tracing parameters
                %
                if strcmp(antenna_data(iantenna).type,'LH'),
                    if strcmp(antenna_data(iantenna).mode,'SW'),
                        waveparam.mmode = -1;% cold plasma mode [1] : (-1) m (1) p, p is the slow mode when kperp > 0 (ex : LH slow wave)
                    elseif strcmp(antenna_data(iantenna).type,'FW'),
                        waveparam.mmode = +1;% cold plasma mode [1] : (-1) m (1) p, p is the slow mode when kperp > 0 (ex : LH slow wave)
                    else
                        error('Wrong polarization of the wave')
                    end
                elseif strcmp(antenna_data(iantenna).type,'EC'),
                    if strcmp(antenna_data(iantenna).mode,'O'),
                        waveparam.mmode = -1;% cold plasma mode [1] : (-1) m (1) p, p is the slow mode when kperp > 0 (ex : LH slow wave)
                    elseif strcmp(antenna_data(iantenna).type,'X'),
                        waveparam.mmode = +1;% cold plasma mode [1] : (-1) m (1) p, p is the slow mode when kperp > 0 (ex : LH slow wave)
                    else
                        error('Wrong polarization of the wave')
                    end    
                else
                    error('Wrong wave type')
                end
                %
                waveparam = conc_struct_jd(rtparam.waveparam,waveparam);% merge default and customized parameters
                %
                % ---------------------------------------------------------------------------------
                %
                fitparam = struct;
                fitparam = conc_struct_jd(rtparam.fitparam,fitparam);% merge default and customized parameters
                %
                % ---------------------------------------------------------------------------------
                %
                rayparam = struct;
                rayparam = conc_struct_jd(rtparam.rayparam,rayparam);% merge default and customized parameters
                %
                % ---------------------------------------------------------------------------------
                %
                C3POdisplay = struct;
                C3POdisplay = conc_struct_jd(rtparam.C3POdisplay,C3POdisplay);% merge default and customized parameters
                %
                % ---------------------------------------------------------------------------------
                %
                C3POparam = struct;
                C3POparam = conc_struct_jd(rtparam.C3POparam,C3POparam);% merge default and customized parameters
                %
                launch.type = antenna_data(iantenna).type;%wave type
                launch.omega_rf = antenna_data(iantenna).freq*2*pi*1e9;%wave angular frequency (rad/s) [1,1] (same frequency)
                %
                if ~isempty(scan(1).type) && scan(1).iantenna == iantenna,
                    iref1 = find(isnan(antenna_data(iantenna).(scan(1).type)) == 1);  
                end
                %
                if ~isempty(scan(2).type) && scan(2).iantenna == iantenna,
                    iref2 = find(isnan(antenna_data(iantenna).(scan(2).type)) == 1);  
                end
                %
                if strcmp(launch.type,'LH'),
                    %
                    P0 = antenna_data(iantenna).P0;
                    if strcmp(scan(1).type,'P0') && scan(1).iantenna == iantenna,
                        P0(iref1) = scan(1).value(iscan);
                    end
                    if strcmp(scan(2).type,'P0') && scan(2).iantenna == iantenna,
                        P0(iref2) = scan(2).value(jscan);
                    end
                    launch.bPlhtot = P0*1e6;%initial power in the ray (W) (main lobe) [1,n_lobe]
                    %
                    Npar0 = antenna_data(iantenna).Npar0;
                    if strcmp(scan(1).type,'Npar0') && scan(1).iantenna == iantenna,
                        Npar0(iref1) = scan(1).value(iscan);
                    end
                    if strcmp(scan(2).type,'Npar0') && scan(2).iantenna == iantenna,
                        Npar0(iref2) = scan(2).value(jscan);
                    end
                    launch.bNpar0 = Npar0;%Initial Npar value [1,n_lobe]       
                    %
                    dNpar0 = antenna_data(iantenna).dNpar0;
                    if strcmp(scan(1).type,'dNpar0') && scan(1).iantenna == iantenna,
                        dNpar0(iref1) = scan(1).value(iscan);
                    end
                    if strcmp(scan(2).type,'dNpar0') && scan(2).iantenna == iantenna,
                        dNpar0(iref2) = scan(2).value(jscan);
                    end
                    launch.bdNpar0 = dNpar0;%ray spectral width for lobe width calculations [1,n_lobe]
                    %                        
                    m0 = antenna_data(iantenna).m0;
                    if strcmp(scan(1).type,'m0') && scan(1).iantenna == iantenna,
                        m0(iref1) = scan(1).value(iscan);
                    end
                    if strcmp(scan(2).type,'m0') && scan(2).iantenna == iantenna,
                        m0(iref2) = scan(2).value(jscan);
                    end
                    launch.m0 = m0;%initial poloidal mode number [1,1]
                    %                        
                    phi0 = antenna_data(iantenna).phi0;
                    if strcmp(scan(1).type,'phi0') && scan(1).iantenna == iantenna,
                        phi0(iref1) = scan(1).value(iscan);
                    end
                    if strcmp(scan(2).type,'phi0') && scan(2).iantenna == iantenna,
                        phi0(iref2) = scan(2).value(jscan);
                    end
                    launch.phi0 = phi0;%toroidal angle position [1,1]
                    %
                    LFS = antenna_data(iantenna).LFS;
                    if strcmp(scan(1).type,'LFS') && scan(1).iantenna == iantenna,
                        LFS(iref1) = scan(1).value(iscan);
                    end            
                    if strcmp(scan(2).type,'LFS') && scan(2).iantenna == iantenna,
                        LFS(iref2) = scan(2).value(jscan);
                    end            
                    launch.LFS = LFS;% (-1) high field side launching, (1) low field side launching [1,1]
                    %
                    rZ0 = antenna_data(iantenna).rZ0;
                    if strcmp(scan(1).type,'rZ0') && scan(1).iantenna == iantenna,
                        rZ0(iref1) = scan(1).value(iscan);
                    end                        
                    if strcmp(scan(2).type,'rZ0') && scan(2).iantenna == iantenna,
                        rZ0(iref2) = scan(2).value(jscan);
                    end                        
                    launch.rZ0 = rZ0;%vertical launching positions [1,m_pol]
                    %
                    i_ref = antenna_data(iantenna).i_ref;
                    if strcmp(scan(1).type,'i_ref') && scan(1).iantenna == iantenna,
                        i_ref(iref1) = scan(1).value(iscan);
                    end              
                    if strcmp(scan(2).type,'i_ref') && scan(2).iantenna == iantenna,
                        i_ref(iref2) = scan(2).value(jscan);
                    end              
                    launch.i_ref = i_ref;%Initial radial position index, relative to LCFS [1,1]
                    %
                    if tail_mode > 0,
                        %
                        tail.dtn = dtn_fluct_correlation_npar0_lh;
                        tail.mode = tail_mode;% mode for tail spectrum : (0)  Gaussian, (1) Linear, (2) calc_tail_jd
                        tail.bNparmax_tail = Nparmax_tail;%npar0 extend from npar_antenna to Nparmax_tail. If Nparmax_tail is NaN or empty, it is calculated by the code in main_rayinit_launch_jd.m -> 6.5/sqrt(Te0)
                        tail.bn_tail = n_tail;%number of lobes to describe the tail. If n_tail = 0, no tail up to Nparmax_tail (no used if linear_tail is chosen) 
                        tail.bP_tail = P_tail;%Power fraction in the tail. If NaN, it is calculated from n_tail and opt_tail (no used if linear_tail is chosen) 
                        tail.bopt_tail = opt_tail_0 + dnpar0_tail*1i;%Final power fraction of the tail @ Nparmax_tail (+1i) Adjust initial dNpar0 such that initial and tail lobes have the same width
                        %
                        id_tail = make_tail_simulid_jd(tail);
                        %
                        launch.tail = tail;
                    else
                        id_tail = '';
                    end
                    %
                elseif strcmp(launch.type,'EC'),
                    %
                    yP_L = antenna_data(iantenna).yP_L;
                    if strcmp(scan(1).type,'yP_L') && scan(1).iantenna == iantenna,
                        yP_L(iref1) = scan(1).value(iscan);
                    end
                    if strcmp(scan(2).type,'yP_L') && scan(2).iantenna == iantenna,
                        yP_L(iref2) = scan(2).value(jscan);
                    end
                    launch.yP_L = yP_L*1e6;%initial power in the ray (W)
                    %
                    yZ_L = antenna_data(iantenna).yZ_L;
                    if strcmp(scan(1).type,'yZ_L') && scan(1).iantenna == iantenna,
                        yZ_L(iref1) = scan(1).value(iscan);
                    end
                    if strcmp(scan(2).type,'yZ_L') && scan(2).iantenna == iantenna,
                        yZ_L(iref2) = scan(2).value(jscan);
                    end
                    launch.yZ_L = yZ_L;% Mirror vertical position (m) 
                    %
                    yR_L = antenna_data(iantenna).yR_L;
                    if strcmp(scan(1).type,'yR_L') && scan(1).iantenna == iantenna,
                        yR_L(iref1) = scan(1).value(iscan);
                    end
                    if strcmp(scan(2).type,'yR_L') && scan(2).iantenna == iantenna,
                        yR_L(iref2) = scan(2).value(jscan);
                    end
                    launch.yR_L = yR_L;%Mirror major radius (m)
                    %                        
                    yphi_L = antenna_data(iantenna).yphi_L;
                    if strcmp(scan(1).type,'yphi_L') && scan(1).iantenna == iantenna,
                        yphi_L(iref1) = scan(1).value(iscan);
                    end
                    if strcmp(scan(2).type,'yphi_L') && scan(2).iantenna == iantenna,
                        yphi_L(iref2) = scan(2).value(jscan);
                    end
                    launch.yphi_L = pi/180*yphi_L;% Mirror toroidal angle position (deg)
                    %                        
                    yalpha_L = antenna_data(iantenna).yalpha_L;
                    if strcmp(scan(1).type,'yalpha_L') && scan(1).iantenna == iantenna,
                        yalpha_L(iref1) = scan(1).value(iscan);
                    end
                    if strcmp(scan(2).type,'yalpha_L') && scan(2).iantenna == iantenna,
                        yalpha_L(iref2) = scan(2).value(jscan);
                    end
                    launch.yalpha_L = pi/180*yalpha_L;% Mirror horizontal angle with respect to the major radius direction (deg)
                    %
                    ybeta_L = antenna_data(iantenna).ybeta_L;
                    if strcmp(scan(1).type,'ybeta_L') && scan(1).iantenna == iantenna,
                        ybeta_L(iref1) = scan(1).value(iscan);
                    end            
                    if strcmp(scan(2).type,'ybeta_L') && scan(2).iantenna == iantenna,
                        ybeta_L(iref2) = scan(2).value(jscan);
                    end            
                    launch.ybeta_L = pi/180*ybeta_L;% Mirror vertical angle with respect to the major radius direction (deg)
                    %
                    w0 = antenna_data(iantenna).w0;
                    if strcmp(scan(1).type,'w0') && scan(1).iantenna == iantenna,
                        w0(iref1) = scan(1).value(iscan);
                    end                        
                    if strcmp(scan(2).type,'w0') && scan(2).iantenna == iantenna,
                        w0(iref2) = scan(2).value(jscan);
                    end                        
                    launch.w0 = w0;% Beam_width (m)
                    %
                    z0 = antenna_data(iantenna).z0;
                    if strcmp(scan(1).type,'z0') && scan(1).iantenna == iantenna,
                        z0(iref1) = scan(1).value(iscan);
                    end              
                    if strcmp(scan(2).type,'z0') && scan(2).iantenna == iantenna,
                        z0(iref2) = scan(2).value(jscan);
                    end              
                    launch.z0 = z0;% Focal point distance from mirror (m) 
                    %
                end
                %
                if ~isempty(id_tail),
                    wavestructs{iantenna}.id = [id_equil,'_antennna(',int2str(iantenna),')_',antenna_data(iantenna).type,'_f_',num2str(antenna_data(iantenna).freq),'GHz_P_',num2str(sum(antenna_data(iantenna).P0)),'MW_Mode_',antenna_data(iantenna).mode,'_Scan_',scan_type,'_Value_',num2str(isim),id_tail];
                else
                    wavestructs{iantenna}.id = [id_equil,'_antennna(',int2str(iantenna),')_',antenna_data(iantenna).type,'_f_',num2str(antenna_data(iantenna).freq),'GHz_P_',num2str(sum(antenna_data(iantenna).P0)),'MW_Mode_',antenna_data(iantenna).mode,'_Scan_',scan_type,'_Value_',num2str(isim)];
                end
                %
                wavestructs{iantenna}.launch = launch;
                wavestructs{iantenna}.waveparam = waveparam;
                wavestructs{iantenna}.fitequilparam = fitparam;
                wavestructs{iantenna}.rayparam = rayparam;
                wavestructs{iantenna}.C3POparam = C3POparam;
                wavestructs{iantenna}.wavesolver = 'C3PO';
                wavestructs{iantenna}.equil_id = equil.id;       
                wavestructs{iantenna}.C3POdisplay = C3POdisplay;%for display ray propagation
                %
            end
            %
            lukestructs0{isim}.simul.id_simul = [id_equil,'_Scan_',scan_type,'_Value_',num2str(isim)];
            lukestructs0{isim}.simul.path = '';
            if size(index,2) == 1,
                lukestructs0{isim}.simul.index = index(isim);
            elseif size(index,2) == 2,
                lukestructs0{isim}.simul.index = index(isim,:);
            end
            %
            lukestructs0{isim}.dkeparam = dkeparam;
            lukestructs0{isim}.dkepath = dkepath;
            lukestructs0{isim}.dkedisplay = dkedisplay;
            lukestructs0{isim}.equil = equil;
            lukestructs0{isim}.waves = '';
            lukestructs0{isim}.wavestructs = wavestructs;
            lukestructs0{isim}.ohm = ohm;
            lukestructs0{isim}.transpfaste = transpfaste;
            lukestructs0{isim}.ripple = ripple;  
            %
            lukestructs0{isim}.opt = computing_opts.opt; 
            %
            lukestructs0{isim}.launchedjob = 0;
            %
            procdata{isim} = NaN;
            %
            isim = isim + 1;
            %
        end
    end
    %
    disp('---------------------------------------------')
    disp(['--> Number of simulations : ',int2str(length(index))]);
    %
else
    load(filesimul,'lukestructs','dkepath','procdata');
    disp('---------------------------------------------')
end
%
if ~exist(filesimul,'file'),
    lukestructs = lukestructs0;
    clear('lukestructs0');
else
    if redocrashedjobs,
        load(filesimul,'lukestructs','dkepath','procdata');
    end
end
%
%--------------------------- Run C3PO/LUKE --------------------------- 
%
disp(['--> Simulation : ',dataname]);
if computing_opts.remnum > 0
    disp(['--> ',dkepath.profilestr{computing_opts.remnum}]);
else
    disp(['--> Local calculations']);
end
disp('---------------------------------------------')
%
suspendedjob = 0;
runningjob = 0;
finishedjob = 0; 
errjob = 0;
%
for isim = 1:length(lukestructs),
    %
    if exist('icanceljob','var')
        if isim == icanceljob,
            lukestructs{isim} = rmfield(lukestructs{isim},'job');
            lukestructs{isim}.err = 'Job manually cancelled.';
        end
	end
    %
    if isfield(lukestructs{isim},'job')
        runningjob = runningjob + 1;
        if displayjobtimeid,
            disp(['Job time id : ',lukestructs{isim}.job.timeid]);
        end
    else
        if isfield(lukestructs{isim},'output')
            finishedjob = finishedjob + 1;
            if ~isfield(lukestructs{isim},'launchedjob')
                lukestructs{isim}.launchedjob = 1;%to recover all simulations
            end
        else
            if isfield(lukestructs{isim},'err')
               errjob = errjob + 1;
               %
               if redocrashedjobs,
                   lukestructs{isim} = rmfield(lukestructs{isim},'err');
                   lukestructs{isim} = lukestructs0{isim};
               end                
            elseif ~lukestructs{isim}.launchedjob,
                suspendedjob = suspendedjob + 1;
            else
                runningjob = runningjob + 1;
            end
        end
    end
end
%
clear('lukestructs0');
%
disp(['Number of simulations to be done     : ',int2str(length(lukestructs))]);
disp(['Number of simulations running        : ',int2str(runningjob)]);
disp(['Number of simulations finished       : ',int2str(finishedjob)]);
disp(['Number of simulations suspended      : ',int2str(suspendedjob)]);
disp(['Number of simulations lost           : ',int2str(errjob)]);
disp('---------------------------------------------')
%
%--------------------------- Redo lost jobs  --------------------------- 
%
if ~exist('maxlaunchedjob','var'),maxlaunchedjob = length(lukestructs);end
disp(['Maximum number of simulations allowed to run in parallel : ',int2str(maxlaunchedjob)]);
disp('---------------------------------------------')
%
unsuspendedjob = 0;
newmaxlaunchedjob = maxlaunchedjob;
%
for isim = 1:length(lukestructs),
    %
    if isfield(lukestructs{isim},'launchedjob') && lukestructs{isim}.launchedjob == 0 && unsuspendedjob < maxlaunchedjob - runningjob,
        unsuspendedjob = unsuspendedjob + 1;
        lukestructs{isim}.launchedjob = 1;%new job launched
    end
end
%
disp(['Number of new simulations launched   : ',int2str(unsuspendedjob)]);
disp('---------------------------------------------')
%
lukestructs = run_lukert(lukestructs,dkepath);%run C3PO/LUKE locally or remotely 
%
flag_running = false(1,length(lukestructs));
flag_suspended = false(1,length(lukestructs));
%
disp('---------------------------------------------')
%
for isim = 1:length(lukestructs),
    if isfield(lukestructs{isim},'job'),
        flag_running(isim) = true;
        %
        [runtime_str,duration_str,runtime_num{isim},duration_num{isim}] = displayrunningjob(lukestructs{isim}.job,isim);   
    else
        if isfield(lukestructs{isim},'output'),
            simul = lukestructs{isim}.simul.jobparams;
            simul.id = int2str(isim);
            [runtime_str,duration_str,runtime_num{isim},duration_num{isim}] = displayrunningjob(simul,isim);     
        else
            flag_suspended(isim) = true;
            disp([' - Simulation #',int2str(isim),' is suspended.'])
        end
    end
end
%
disp('---------------------------------------------')
%
if exist('lukestructs','var')
    save(['LUKE_RESULTS_',dataname,'.mat'],'lukestructs','dkepath','-v7.3');
else
    disp('WARNING: lukestructs variable is nomore existing. Check the script because you may loose all the simulation ! ')
    return
end
%
if isfield(lukestructs{1},'job'), 
    inittime_str = lukestructs{1}.job.timestartlocal;
else
    inittime_str = lukestructs{1}.simul.jobparams.timestartlocal;
end
%
duration_str = datestr(etime(clock,datevec(inittime_str))/86400,'HH:MM:SS');
%
disp(['----> Simulation has been started the ',inittime_str]);
disp(['----> Elapsed time since simulation started up : ',duration_str,' (HH:MM:SS)']);
disp(['----> ',int2str(sum(flag_running)),'/',int2str(length(lukestructs)),' jobs are still running.'])
disp(['----> ',int2str(sum(flag_suspended)),'/',int2str(length(lukestructs)),' jobs must still to be launched.'])
%
% ------------------------- data postprocessing and display ------------------------
%
if forcepostprocessing,
    clear procdata;%force rebuild the processed data
end
%
if ~exist('procdata','var'), 
    procdata = cell(1,length(lukestructs));
end
%
if (sum(flag_running) + sum(flag_suspended))/length(lukestructs) < 0.5,%already 50% of the job done. Plots can be displayed even partially
    %
    for isim = 1:length(lukestructs),
        %
        clear('rawdata');
        %
        if ~flag_running(isim)  && ~flag_suspended(isim)  && ~isstruct(procdata{isim}),% to avoid to reprocess existing processed simulations
            %
            rawdata.Znorm = lukestructs{isim}.output.Znorm;
            rawdata.Zcurr = lukestructs{isim}.output.Zcurr;
            rawdata.ZP0 = lukestructs{isim}.output.ZP0;
            rawdata.dke_out = lukestructs{isim}.output.dke_out;
            rawdata.radialDKE = lukestructs{isim}.output.radialDKE;
            rawdata.equilDKE = lukestructs{isim}.output.equilDKE;
            rawdata.equil = lukestructs{isim}.output.dke_out.equil;
            rawdata.momentumDKE = lukestructs{isim}.output.momentumDKE;
            rawdata.gridDKE = lukestructs{isim}.output.gridDKE;
            rawdata.Zmomcoef = lukestructs{isim}.output.Zmomcoef;
            rawdata.Zbouncecoef = lukestructs{isim}.output.Zbouncecoef;
            rawdata.Zmripple = lukestructs{isim}.output.Zmripple;
            rawdata.mksa = lukestructs{isim}.output.mksa;
            rawdata.XXsinksource = lukestructs{isim}.output.XXsinksource;
            %
            if isfield(rawdata.dke_out,'waves'),
                for iray = 1:length(rawdata.dke_out.waves{1}.rays),
                    if ~isfield(rawdata.dke_out.waves{1}.rays{iray},'mask_p') | ~isfield(rawdata.dke_out.waves{1}.rays{iray},'mask_m');
                        rawdata.dke_out.waves{1}.rays{iray}.mask_p = zeros(size(rawdata.dke_out.waves{1}.rays{iray}.ss));
                        rawdata.dke_out.waves{1}.rays{iray}.mask_m = ones(size(rawdata.dke_out.waves{1}.rays{iray}.ss));
                    end        
                end
            end
            %      
            dataname_out = dataname;
            %
            if exist('ij_scan_display','var') 
                for idisplay = 1:size(ij_scan_display,1),
                    if (index(isim,1) == ij_scan_display(idisplay,1)) && (index(isim,2) == ij_scan_display(idisplay,2)),
                        for i_ir_display = 1:length(ir_display),
                            procdata{isim} = proc_luke_jd(rawdata,ir_display(i_ir_display),p_opt);
                        end
                    else
                        procdata{isim} = proc_luke_jd(rawdata);
                    end
                end
            else
                 procdata{isim} = proc_luke_jd(rawdata);
            end    
            %
        elseif isfield(procdata{isim},'simul'),
            break
        else
            procdata{isim} = NaN;
        end
    end
    %
    movefile(['LUKE_RESULTS_',dataname,'.mat'],['xxLUKE_RESULTS_',dataname,'.mat'])
    %
    if exist('lukestructs','var') 
        save(['LUKE_RESULTS_',dataname,'.mat'],'procdata','lukestructs','dkepath','-v7.3')
    else
        disp('WARNING: lukestructs variable has been removed. Check the script ! ')
        keyboard
    end
    %
    delete(['xxLUKE_RESULTS_',dataname,'.mat']);%be cause '-append' option fails on very large files ....
    %
else
    return
end
%
disp('--------------------------------------------------------------------------------------------');
disp('--------------------------------------------------------------------------------------------');
disp('----> All calculations are done and results are now stored back on the local computer in the directory : ')
disp(['----> ',pwd]);
disp('----> and the file : ');
disp(['----> LUKE_RESULTS_',dataname,'.mat']);
if computing_opts.remclean == 2,
    disp('----> remclean = 2 option has been chosen : temporary simulations files have been removed from the local and remote computers');
elseif computing_opts.remclean == 1,
     disp('----> remclean = 1 option has been chosen : temporary simulations files have been remove from the remote computers only');
elseif computing_opts.remclean == 0,
     disp('----> remclean = 0 option has been chosen : temporary simulations files have not been removed from the local and remote computers.'); 
     disp('----> *********************************************************************');
     disp('----> WARNING: POSSIBLE MEMORY STORAGE LIMITATIONS ON THE REMOTE COMPUTER');
     disp('----> *********************************************************************');
end
%
disp('----> Type the matlab command : ''check_used_remotestorage(lukestructs)'' to check the amount of free memory space on the remote computer');
%
disp('----> This script can be executed as many time as necessary without relaunching the calculations ')
disp('----> as far as the file :');
disp(['----> LUKE_RESULTS_',dataname,'.mat']);
disp('----> is in the local directory. Remove it or rename it for restarting a new simulation.');
disp('----> or set the computing_opts.remstart ption to 1.');
disp('--------------------------------------------------------------------------------------------');
disp('--------------------------------------------------------------------------------------------');
disp('Global simulation results')
disp('--------------------------------------------------------------------------------------------');
disp('--------------------------------------------------------------------------------------------');
disp(['Simulation id : ',dataname]);
disp('--------------------------------------------------------------------------------------------');
disp('--------------------------------------------------------------------------------------------');
%
% -------------------------------- Display global results --------------------------------
%
for isim = 1:length(lukestructs),
    %
    if isfield(lukestructs{isim},'output'),
        %
        scocurr = sign(lukestructs{isim}.output.equilDKE.psia_apRp)*sign(lukestructs{isim}.output.equilDKE.XBphi(1,1));
        %
        if isstruct(procdata{isim})
            Is_tot(isim) = procdata{isim}.scalar.I_tot;
            PRFs_tot(isim) = procdata{isim}.scalar.p_rf_2piRp*equil.Rp*2*pi;
            Effs_tot(isim) = procdata{isim}.scalar.EtaRFRp;
            %
            if isstruct(procdata{isim}.scalar) && ~isempty(procdata{isim}.scalar.P_rf_rhoG) && ~isempty(procdata{isim}.scalar.P_rf_drhoG),
                P_rf_rhoG(isim) = procdata{isim}.scalar.P_rf_rhoG;
                P_rf_drhoG(isim) = procdata{isim}.scalar.P_rf_drhoG;
                jrhoG(isim) = procdata{isim}.scalar.jrhoG;
                jdrhoG(isim) = procdata{isim}.scalar.jdrhoG;
            else
                P_rf_rhoG(isim) = NaN; 
                P_rf_drhoG(isim) = NaN;  
                jrhoG(isim) = NaN; 
                jdrhoG(isim) = NaN; 
            end               
        else
            Is_tot(isim) = NaN;
            PRFs_tot(isim) = NaN;
            Effs_tot(isim) = NaN;
            P_rf_rhoG(isim) = NaN; 
            P_rf_drhoG(isim) = NaN;  
            jrhoG(isim) = NaN; 
            jdrhoG(isim) = NaN; 
        end
        %
        POHMs_tot(isim) = sum(lukestructs{isim}.output.ZP0.x_e_fsav.*lukestructs{isim}.output.equilDKE.xdV_2piRp_dke*lukestructs{isim}.output.mksa.P_ref*2*pi*lukestructs{isim}.output.equilDKE.Rp); 
        %
        if size(index,2) == 1
            info_dke_yp(2,[' - Scan for RF antenna ',int2str(scan(1).iantenna),' @ ',num2str(antenna_data(scan(1).iantenna).freq),'GHz - ',scan(1).type,' : ',num2str(scan(1).value)]);        
        else
            info_dke_yp(2,[' - Scan for RF antenna ',int2str(scan(1).iantenna),' @ ',num2str(antenna_data(scan(1).iantenna).freq),'GHz - ',scan(1).type,' : ',num2str(scan(1).value(index(isim,1)))]);        
            info_dke_yp(2,[' - Scan for RF antenna ',int2str(scan(2).iantenna),' @ ',num2str(antenna_data(scan(2).iantenna).freq),'GHz - ',scan(2).type,' : ',num2str(scan(2).value(index(isim,2)))]);        
        end  
        %
        disp('--------------------------------------------------------------------------------------------');
        info_dke_yp(2,[' - Total Ohmic power                    : ',num2str(POHMs_tot(isim)),' (MW)']);
        info_dke_yp(2,[' - Total RF power                       : ',num2str(PRFs_tot(isim)),' (MW)']);
        info_dke_yp(2,[' - Total current (co-current > 0)       : ',num2str(Is_tot(isim)),' (MA)']);
        info_dke_yp(2,[' - RF Efficiency                        : ',num2str(Effs_tot(isim)),' (n_19*I*Rp/P)']);
        info_dke_yp(2,[' - RF power mean position (rhoG)        : ',num2str(P_rf_rhoG(isim)),' (a.u.)']);
        info_dke_yp(2,[' - RF power mean width (drhoG)          : ',num2str(P_rf_drhoG(isim)),' (a.u.)']);
        info_dke_yp(2,[' - Current density mean position (rhoG) : ',num2str(jrhoG(isim)),' (a.u.)']);
        info_dke_yp(2,[' - Current density mean width (drhoG)   : ',num2str(jdrhoG(isim)),' (a.u.)']);
        
        disp('--------------------------------------------------------------------------------------------');
    else
        Is_tot(isim) = NaN;
        PRFs_tot(isim) = NaN;
        POHMs_tot(isim) = NaN;
        Effs_tot(isim) = NaN;
        P_rf_rhoG(isim) = NaN; 
        P_rf_drhoG(isim) = NaN;  
        jrhoG(isim) = NaN; 
        jdrhoG(isim) = NaN; 
    end
end
%
XIs_tot = reshape(Is_tot,length(scan(2).value),length(scan(1).value));
XPRFs_tot = reshape(PRFs_tot,length(scan(2).value),length(scan(1).value));
XPOHMs_tot = reshape(POHMs_tot,length(scan(2).value),length(scan(1).value));
XEffs_tot = reshape(Effs_tot,length(scan(2).value),length(scan(1).value));
XP_rf_rhoG = reshape(P_rf_rhoG,length(scan(2).value),length(scan(1).value));
XP_rf_drhoG = reshape(P_rf_drhoG,length(scan(2).value),length(scan(1).value));
XjrhoG = reshape(jrhoG,length(scan(2).value),length(scan(1).value));
XjdrhoG = reshape(jdrhoG,length(scan(2).value),length(scan(1).value));
%
%
% -------------------------------- Plot parameters --------------------------------
%
% Lines and points styles and color
%
opt.rho = 'g';
opt.nr_dep = 0;
opt.peakmode = 0;
opt.peak = 'n';
opt.wave = 'n';
opt.blist = '';
opt.diaryname = '';
opt.spec = 0;
%
style0 = 'none';
style = '-';
style2 = '--';
%
marker0 = 'none';
marker1 = '+';
marker2 = 'o';
marker3 = 's';
marker4 = 'x';
marker5 = 'd';
marker6 = '*';
%
color1 = 'k';
color2 = 'r';
color3 = 'b';
color4 = 'g';
color5 = 'm';
color6 = 'c';
color7 = 'y';
%
markers = {marker1,marker2,marker3,marker4,marker5,marker6};
colors = {color1,color2,color3,color4,color5,color6,color7};
%
% Lines width and points size
%
width = 0.5;
width2 = 2;
siz = 20;
%
% Advanced drawing options
%
red = 0.9;
lspace = 0.7;
lspace2 = 0.5;
bspace = 0.7;
bspace2 = 0.5;
%
opt.nr_dep = -1;
opt.peak = 'n';
opt.wave = 'y';
opt.peakmode = 1;
opt.rho = 'g';
opt.spec = 1;
%
for iscan = 1:length(scan),
    %
    scandisplay.iscan = iscan;
    scandisplay.scan = scan;
    scandisplay.procdata = procdata;
    scandisplay.index = index;
    %
    scandisplay.color = colormap('lines');
    scandisplay.width = width2;
    scandisplay.style = style;
    scandisplay.marker = markers;
    scandisplay.p_opt = p_opt;
    %
    % Total current
    %
    if sum(sum(isnan(XIs_tot))) < length(lukestructs),
        scandisplay.id_simul = [dataname,'_Ip'];
        scandisplay.data = XIs_tot;
        scandisplay.xdata = 1;
        scandisplay.title = ['J > 0 for co-current'];
        scandisplay.ylabel = 'I_p (MA)';
        scandisplay.path_simul = '';
        %
        scandisplay.profile.mode = 1;
        scandisplay.profile.ylabel = 'j(\psi) (MA/m2)'; 
        scandisplay.profile.field = 'J_tot'; 
        scandisplay.profile.colors = colors;
        scandisplay.profile.markers = markers;
        %
        plotscan(scandisplay);
        %
        scandisplay = rmfield(scandisplay,'profile');
    end
    %
    % RF Power
    %
    if sum(sum(isnan(XPRFs_tot))) < length(lukestructs)
        scandisplay.id_simul = [dataname,'_Prf'];
        scandisplay.data = XPRFs_tot;
        scandisplay.xdata = 1;
        scandisplay.title = 'Absorbed RF power';
        scandisplay.ylabel = 'P_{rf} (MW)';
        scandisplay.path_simul = '';
        %
        plotscan(scandisplay);
    end
    %
    % Ohmic Power
    %
    if sum(sum(isnan(XPOHMs_tot))) < length(lukestructs) || isempty(lukestructs{1}.ohm)
        scandisplay.id_simul = [dataname,'_Pohm'];
        scandisplay.data = XPOHMs_tot;
        scandisplay.title = '';
        scandisplay.ylabel = 'P_{Ohm} (MW)';
        scandisplay.path_simul = '';
        %
        plotscan(scandisplay);
    end
    %
    % Efficiency
    %
    if sum(sum(isnan(XEffs_tot))) < length(lukestructs),
        scandisplay.id_simul = [dataname,'_Eff'];
        scandisplay.data = XEffs_tot;
        scandisplay.title = '';
        scandisplay.ylabel = 'CD Efficiency (10^{+19} A/(W.m^{2})';
        scandisplay.path_simul = '';
        %
        plotscan(scandisplay);
    end
    %    
    % RF power density mean peak position 
    %
    if sum(sum(isnan(XP_rf_rhoG))) < length(lukestructs),
        scandisplay.id_simul = [dataname,'_P_rf_rhoG'];
        scandisplay.data = XP_rf_rhoG;
        scandisplay.title = 'RF power density mean peak position';
        scandisplay.ylabel = '\Delta\rho_{Prf} ';
        scandisplay.path_simul = '';
        %
        plotscan(scandisplay);
    end
    %   
    % RF power density mean peak width
    %
    if sum(sum(isnan(XP_rf_drhoG))) < length(lukestructs),
        scandisplay.id_simul = [dataname,'_P_rf_drhoG'];
        scandisplay.data = XP_rf_drhoG;
        scandisplay.title = 'RF power density mean width';
        scandisplay.ylabel = '\rho_{Prf} ';
        scandisplay.path_simul = '';
        %
        plotscan(scandisplay);
    end
    %    
    % Current density mean peak position 
    %
    if sum(sum(isnan(XjrhoG))) < length(lukestructs),
        scandisplay.id_simul = [dataname,'_jrhoG'];
        scandisplay.data = XP_rf_rhoG;
        scandisplay.title = 'Current density mean peak position';
        scandisplay.ylabel = '\rho_{j} ';
        scandisplay.path_simul = '';
        %
        plotscan(scandisplay);
    end
    %   
    % Current density mean peak width
    %
    if sum(sum(isnan(XjdrhoG))) < length(lukestructs),
        scandisplay.id_simul = [dataname,'_jdrhoG'];
        scandisplay.data = XjdrhoG;
        v = 'Current density mean width';
        scandisplay.ylabel = '\Delta\rho_{j} ';
        scandisplay.path_simul = '';
        %
        plotscan(scandisplay);
    end
end
%

if 0,
ylabel = 'j(\psi) (MA/m2)';
%
for iscan = 1:length(scan(1).value),
    %
    figure('Name',[ylabel,' = f(',scan(1).label,')']),clf
    title = [scan(1).label,' = ',num2str(scan(1).value(iscan)),' (',scan(1).unit,')'];
    %
    ylim_min = Inf;
    ylim_max = -Inf;
    %
    maxlegendscan = 0;
    %
    full_legend='';
    %
    for jscan = 1:length(scan(2).value),
        %
        isim = jscan + (iscan-1)*length(scan(2).value);
        %
        if isstruct(procdata{isim}),
            ylim_min = min(ylim_min,min(procdata{isim}.radial.J_tot));
            ylim_max = max(ylim_max,max(procdata{isim}.radial.J_tot));
            %
            legendscan{jscan} = [scan(2).label,' = ',num2str(scan(2).value(jscan)), ' (',scan(2).unit,')'];
            lengthlegendscan(jscan) = length(legendscan{jscan});
            %
            lengthchainblank = max(lengthlegendscan) - length(legendscan{jscan});
            chainblank = '';for ichainblank = 1:lengthchainblank,chainblank = [chainblank,' '];end
            legendscan{jscan} = [legendscan{jscan},chainblank];
            full_legend = [full_legend;legendscan{jscan}];
        end
        %
    end
    %
    for jscan = 1:length(scan(2).value),
        %
        isim = jscan + (iscan-1)*length(scan(2).value);
        %
        if isstruct(procdata{isim}),
            graph1D_jd(procdata{isim}.radial.xrhoG,procdata{isim}.radial.J_tot,0,0,'r/a','J (MA/m^2)',title,NaN,[0,1],[ylim_min,ylim_max],'-',markers{max(1,rem(jscan,length(markers)))},colors{max(1,rem(jscan,length(colors)))},2);
        end
    end
    %
    legend(full_legend);
    %  
end
%
%kscan = iscan + (-1)^(scandisplay.iscan+1)
%
ylabel = 'j(\psi) (MA/m2)';
%
for iscan = 1:length(scan(2).value),
    %
    figure('Name',[ylabel,' = f(',scan(2).label,')']),clf
    title = [scan(2).label,' = ',num2str(scan(2).value(iscan)),' (',scan(2).unit,')'];
    %
    ylim_min = Inf;
    ylim_max = -Inf;
    %
    maxlegendscan = 0;
    %
    full_legend='';
    %
    for jscan = 1:length(scan(1).value),
        %
        isim = jscan + (iscan-1)*length(scan(1).value);
        %
        if isstruct(procdata{isim}),
            ylim_min = min(ylim_min,min(procdata{isim}.radial.J_tot));
            ylim_max = max(ylim_max,max(procdata{isim}.radial.J_tot));
            %
            legendscan{jscan} = [scan(1).label,' = ',num2str(scan(1).value(jscan)), ' (',scan(1).unit,')'];
            lengthlegendscan(jscan) = length(legendscan{jscan});
            %
            lengthchainblank = max(lengthlegendscan) - length(legendscan{jscan});
            chainblank = '';for ichainblank = 1:lengthchainblank,chainblank = [chainblank,' '];end
            legendscan{jscan} = [legendscan{jscan},chainblank];
            full_legend = [full_legend;legendscan{jscan}];
        end
        %
    end
    %
    for jscan = 1:length(scan(1).value),
        %
        isim = jscan + (iscan-1)*length(scan(1).value);
        %
        if isstruct(procdata{isim}),
            graph1D_jd(procdata{isim}.radial.xrhoG,procdata{isim}.radial.J_tot,0,0,'r/a','J (MA/m^2)',title,NaN,[0,1],[ylim_min,ylim_max],'-',markers{max(1,rem(jscan,length(markers)))},colors{max(1,rem(jscan,length(colors)))},2);
        end
    end
    %
    legend(full_legend);
    %  
end
%
end

