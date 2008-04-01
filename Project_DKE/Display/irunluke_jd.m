function irunluke_jd(basestr,signs)
%
% This script interactively loads the equilibrium, profiles and launching data, and runs LUKE with
% either C3PO, TORAY or ART ray-tracing data.
%
if nargin < 2,
    signs = '';
end
%
quitmsg = '-----> Run aborted';
warning off
%
% WORKING DIRECTORY
%
disp('');
disp('************** WORK DIRECTORY **************')
disp('');
workdir = uigetdir('','Please select the output directory'); 
if workdir == 0,
    disp(quitmsg);
    return
else
    disp(['-----> The working directory is :',workdir]);
end
%
% PATH
%
id_dkepath = 'LOCAL';%For all paths used by DKE solver
dkepath_file = which('PATH_LOCAL.mat');%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkepath_file,dkepath_path] = uigetfile('*.mat','Please select the PATH file containing dkepath',dkepath_file);
if dkepath_file == 0,
    dkepath_path = '';;
end
%
dkepath = load_structures_yp('dkepath',id_dkepath,dkepath_path);
%
% EQUILIBRIUM 
%
disp('');
disp('************** EQUILIBRIUM **************')
disp('');
l_opt = input('Do you want to load an existing LUKE equilibrium? [y/n] : ','s');
if strcmp(l_opt,'y'),
    [equil_file,equil_path] = uigetfile('EQUIL_*.mat','Please select the EQUIL file',workdir);
    %
    if equil_file == 0,
        disp('-----> No equilibrium structure specified.')
        disp(quitmsg)
        return
    end  
    %
    load([equil_path,equil_file],'equil');
    disp('-----> The equilibrium structure is loaded')
    e_opt = input('Do you want to plot the equilibrium? [y/n] : ','s');
    if strcmp(e_opt,'y'),
        equilibrium_jd(equil,NaN,2);
    end
    %
else
    equil = imake_equil_jd(workdir,basestr,signs);
    %
    if isempty(equil),
        disp(quitmsg)
        return
    end
    %
    disp('-----> The equilibrium structure is created')
    %
    e_opt = input('Do you want to save the equilibrium structure? [y/n] : ','s');
    if strcmp(e_opt,'y'),
        sd = pwd;
        cd(workdir);
        [equil_file,equil_path] = uiputfile('EQUIL_*.mat','Please provide the EQUIL file name',['EQUIL_',equil.id,'.mat']);
        %
        if equil_file == 0,
            disp('-----> No file name specified, equilibrium structure not saved.')
        else
            save([equil_path,equil_file],'equil');
            disp('-----> The equilibrium structure is saved')
        end
        cd(sd);
    end
end
%
% WAVES
%
disp('');
disp('************** WAVES **************')
disp('');
%
waves = '';
%
l_opt = input('Do you want to load existing WAVE structures? [y/n] : ','s');
if strcmp(l_opt,'y'),
    %
    [wave_file,wave_path] = uigetfile(['WAVE_',equil.id,'_*.mat'],'Please select the WAVE files',workdir,'MultiSelect','on');
    %
    if ~iscell(wave_file) & wave_file == 0,
        disp('-----> No wave structure specified.')
        disp(quitmsg)
        return
    end  
    %
    while iscell(wave_file) | wave_file ~= 0,
        %
        if iscell(wave_file) == 0,
                load([wave_path,wave_file],'wave');
                waves = [waves,{wave}];
                disp(['-----> The wave structure :',wave_path,wave_file,' is loaded'])
        else
            %
            for iw = 1:length(wave_file),
                load([wave_path,wave_file{iw}],'wave');
                waves = [waves,{wave}];
                disp(['-----> The wave structure :',wave_path,wave_file{iw},' is loaded'])
            end
        end
        %
%         w_opt = input('Do you want to plot the wave data? [y/n] : ','s');
%         if strcmp(w_opt,'y'),
%             graph_wave_jd();
%         end
        %
        [wave_file,wave_path] = uigetfile(['WAVE_',equil.id,'_*.mat'],'Load additional WAVE files (cancel if finished)',workdir,'MultiSelect','on');
        %
    end
    %
    clear wave wave_file wave_path
    %
end
%
l_opt = input('Do you want to build a new WAVE structures? [y/n] : ','s');
%
while strcmp(l_opt,'y'),
    %
    wave = imake_wave_jd(workdir,basestr,equil);
    %
    if isempty(wave),
        disp('-----> Current wave structure construction aborted')
        %
        l_opt = input('Do you want to build a new WAVE structures? [y/n] : ','s');
        %
        continue
    end
    %
    disp('-----> The wave structure is created')
    %
    w_opt = input('Do you want to save the wave structure? [y/n] : ','s');
    if strcmp(w_opt,'y'),
        sd = pwd;
        cd(workdir);
        [wave_file,wave_path] = uiputfile(['WAVE_',equil.id,'*.mat'],'Please provide the WAVE file name',['WAVE_',equil.id,'_',wave.id,'.mat']);
        %
        if wave_file == 0,
            disp('-----> No file name specified, wave structure not saved.')
        else
            save([wave_path,wave_file],'wave');
            disp('-----> The wave structure is saved')
        end
        cd(sd);
    end
    %
    waves = [waves,{wave}];
    %
    l_opt = input('Do you want to build a new WAVE structures? [y/n] : ','s');
end
%
% OHM
%
disp('');
disp('************** OHM **************')
disp('');
%
ohm = '';
%
o_opt = input('Do you want to load an existing OHM structures? [y/n] : ','s');
if strcmp(o_opt,'y'),
    %
    [ohm_file,ohm_path] = uigetfile(['OHM_',equil.id,'_*.mat'],'Please select the OHM file',workdir);
    %
    if ohm_file == 0,
        disp('-----> No ohm structure specified.')
        disp(quitmsg)
        return
    end  
    %
    load([ohm_path,ohm_file],'ohm');
    disp(['-----> The ohm structure :',ohm_path,ohm_file,' is loaded'])
    %
else
    %
    l_opt = input('Do you want to build a OHM structure? [y/n] : ','s');
    %
	if strcmp(l_opt,'y'),
        %
        ohm = imake_ohm_jd(basestr,equil);
        %
        if isempty(ohm),
            disp(quitmsg)
            return
        end
        %
        disp('-----> The ohm structure is created')
        %
        o_opt = input('Do you want to save the ohm structure? [y/n] : ','s');
        if strcmp(o_opt,'y'),
            sd = pwd;
            cd(workdir);
            [ohm_file,ohm_path] = uiputfile(['OHM_',equil.id,'*.mat'],'Please provide the OHM file name',['OHM_',equil.id,'_',ohm.id,'.mat']);
            %
            if ohm_file == 0,
                disp('-----> No file name specified, ohm structure not saved.')
            else
                save([ohm_path,ohm_file],'ohm');
                disp('-----> The ohm structure is saved')
            end
            cd(sd);
        end
        %
    end
end
%
% TRANSPORT parameters
%
disp('');
disp('************** FAST ELECTRON TRANSPORT **************')
disp('');
%
transpfaste = '';
%
t_opt = input('Do you want to load an existing TRANSP structures? [y/n] : ','s');
if strcmp(t_opt,'y'),
    %
    [transp_file,transp_path] = uigetfile(['TRANSP_',equil.id,'_*.mat'],'Please select the TRANSP file',workdir);
    %
    if transp_file == 0,
        disp('-----> No transp structure specified.')
        disp(quitmsg)
        return
    end  
    %
    load([transp_path,transp_file],'transpfaste');
    disp(['-----> The transpfaste structure :',transp_path,transp_file,' is loaded'])
    %
else
    %
    l_opt = input('Do you want to build a TRANSP structure? [y/n] : ','s');
    %
	if strcmp(l_opt,'y'),
        %
        transpfaste = imake_transp_jd(basestr,equil);
        %
        if isempty(transpfaste),
            disp(quitmsg)
            return
        end
        %
        disp('-----> The transpfaste structure is created')
        %
        t_opt = input('Do you want to save the transpfaste structure? [y/n] : ','s');
        if strcmp(t_opt,'y'),
            sd = pwd;
            cd(workdir);
            [transp_file,transp_path] = uiputfile(['TRANSP_',equil.id,'*.mat'],'Please provide the OHM file name',['TRANSP_',equil.id,'_',transpfaste.id,'.mat']);
            %
            if transp_file == 0,
                disp('-----> No file name specified, transpfaste structure not saved.')
            else
                save([transp_path,transp_file],'transpfaste');
                disp('-----> The transpfaste structure is saved')
            end
            cd(sd);
        end
        %
    end
end
%
% LUKE PARAMETERS
%
disp('');
disp('************** LUKE PARAMETERS **************')
disp('');
%
if exist([workdir,'/DKEPARAM_',equil.id,'.mat']),
    dkeparam_file = [workdir,'/DKEPARAM_',equil.id,'.mat'];
else
    if strcmp(basestr,'TCV'),
        dkeparam_file = 'DKEPARAM_EC_RT.mat';
    else
        dkeparam_file = 'DKEPARAM_LH_RT.mat';
    end
    dkeparam_file = which(dkeparam_file);    
end
%
[dkeparam_file,dkeparam_path] = uigetfile('DKEPARAM_*.mat',['Please select the dkeparam default parameters file'],dkeparam_file);
if dkeparam_file == 0,
    disp(quitmsg)
    return
end
load([dkeparam_path,dkeparam_file],'dkeparam');
%
c_opt = input('Do you want to see/modify the LUKE parameters? [y/n] : ','s');
if strcmp(c_opt,'y'),
    dkeparam,
    %
    fname = input('Name of dkeparam field to modify (press enter if finished): ','s');
    while fname ~= 0,
        %
        if isfield(dkeparam,fname),
            eval(['f_val_o = dkeparam.',fname,';']);
            if isnumeric(f_val_o),
                f_val_o_s = num2str(f_val_o);
            else
                f_val_o_s =f_val_o;
            end
            f_val = input(['Provide value for field ',fname,' [',f_val_o_s,'] : ']);
            if isempty(f_val),
                f_val = f_val_o;
            end
            eval(['dkeparam.',fname,' = f_val;']);
        end
        %
        fname = input('Name of dkeparam field to modify (press enter if finished): ','s');
    end
    %
    s_opt = input('Do you want to save the dkeparam structure? [y/n] : ','s');
    if strcmp(s_opt,'y'),
        sd = pwd;
        cd(workdir);
        [save_file,save_path] = uiputfile(['DKEPARAM_',equil.id,'*.mat'],'Please provide the DKEPARAM file name',['DKEPARAM_',equil.id,'.mat']);
        %
        if save_file == 0,
            disp('-----> No file name specified, dkeparam structure not saved.')
        else
            save([save_path,save_file],'dkeparam');
            disp('-----> The dkeparam structure is saved')
        end
        cd(sd);
    end 
    %
end
%
% DISPLAY
%
dkedisplay_file = 'DISPLAY_PARTIAL_VISUAL.mat';
dkedisplay_file = which(dkedisplay_file);
if isempty(dkedisplay_file),
    disp(quitmsg)
    return
end
load(dkedisplay_file,'dkedisplay');
%
display_mode = input('Option for run evolution display: 0 (none), 1 (partial), 2 (full) [0] : ');
if isempty(display_mode),
    display_mode = 0;
end
if ~isnumeric(display_mode) | ~any(display_mode == [0,1,2]),
    disp('-----> Invalid display option');
    return
end
dkedisplay.display_mode = display_mode; 
%
% OTHER RUN PARAMETERS
%
rho_S = input('Please specify the radial grid: \nautomatic (provide number of points) \nmanual (vector of points from 0 to 1) \n[20] : ');
if isempty(rho_S),
    rho_S = 20;
end
if ~isnumeric(rho_S),
    disp('-----> Invalid radial grid specification');
    return
end
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
%
p_opt = input('Option for output figures? -1 (nothing), 0 (print), 1 (print and save), 2 (save) [-1] : ');
if isempty(p_opt) | ~isnumeric(p_opt) | ~any(p_opt == [0,1,2]),
    p_opt = -1;
end
%
if exist('dmumpsmex');%MUMPSMEX
    dkeparam.invproc = -2;
end
%
id_simul_o = equil.id;
for iw = 1:length(waves),
    id_simul_o = [id_simul_o,'_',waves{iw}.id];
end
if ~isempty(ohm),
    id_simul_o = [id_simul_o,'_',ohm.id];
end
if ~isempty(transpfaste),
    id_simul_o = [id_simul_o,'_',transpfaste.id];
end
%
id_simul = input(['Please provide a name for the run [',id_simul_o,'] : '],'s');
if isempty(id_simul),
    id_simul = id_simul_o;
end
%
ripple = '';
%
% RUN LUKE
%
disp('');
disp('************** RUN LUKE **************')
disp('');
%
r_opt = input('You are about to run LUKE. Do you want to proceed now (0) or use the command line first (1) [0] : ');
if isempty(r_opt),
    r_opt = 0;
end 
if ~isnumeric(r_opt) | ~any(r_opt == [0,1]),
    p_opt = -1;
end
if r_opt == 1,
    disp('-----> Type ''RETURN'' to start LUKE, type ''dbquit'' to abort run and leave workspace.');    
    keyboard
end
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = run_lukert(id_simul,[],waves,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[],0);
%	    
% GRAPHIC OUTPUT
%
scocurr = sign(equil.psi_apRp(end))*sign(equil.ptBPHI(1,1));
%
I_tot = sum(Zcurr.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref*scocurr);
figure('Name','Current profile'),
graph1D_jd(equilDKE.xrho,Zcurr.x_0_fsav*mksa.j_ref*scocurr,0,0,'\rho','J_{tot} (MA/m^2)',['I_{tot} = ',num2str(I_tot*1000),' (kA)'],NaN,'','','-','none','r',2);drawnow
print_jd(p_opt,[id_simul,'_Curr']);
%
PRF_tot = sum(ZP0.x_rf_fsav.*equilDKE.xdV_2piRp_dke(:)*mksa.P_ref*2*pi*equilDKE.Rp);
figure('Name','RF Power'),
graph1D_jd(equilDKE.xrho,ZP0.x_rf_fsav*mksa.P_ref,0,0,'\rho','P_{LH} (MW/m^3)',['P_{RF} = ',num2str(PRF_tot*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
print_jd(p_opt,[id_simul,'_RF_Power']);
%
POHM_tot = sum(ZP0.x_e_fsav.*equilDKE.xdV_2piRp_dke*mksa.P_ref*2*pi*equilDKE.Rp);
figure('Name','Ohmic Power'),
graph1D_jd(equilDKE.xrho,ZP0.x_e_fsav*mksa.P_ref,0,0,'\rho','P_{OHM} (MW/m^3)',['P_{OHM} = ',num2str(POHM_tot*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
print_jd(p_opt,[id_simul,'_Ohm']);
%	    
% ---------------------------------------------- Save results ----------------------------------------------
%
s_opt = input('Do you want to save the output data? [y/n] : ','s');
if strcmp(s_opt,'y'),
    sd = pwd;
    cd(workdir);
    [save_file,save_path] = uiputfile(['LUKE_RESULTS_',id_simul,'*.mat'],'Please provide the RESULTS file name',['LUKE_RESULTS_',id_simul,'.mat']);
    %
    if save_file == 0,
        disp('-----> No file name specified, output data not saved.')
    else
        save([save_path,save_file]);
        disp('-----> The output data is saved')
    end
    cd(sd);
end 
%
clear Znorm Zcurr ZP0 dke_out radialDKE equilDKE momentumDKE gridDKE Zmomcoef Zbouncecoef Zmripple mksa XXsinksource
clear id_simul waves psin_S rho_S dkepath equil dkeparam dkedisplay ohm transpfaste ripple
%
s_opt = input('Do you want to calculate the hard X-ray emission? [y/n] : ','s');
%
if strcmp(s_opt,'y'),
    irunhxr_jd(workdir,basestr,[save_path,save_file]);
end 










