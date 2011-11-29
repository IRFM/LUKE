close all
clear all
%
%Wave display procedure. Data are in /local cephee disk
%
if strcmp(computer,'GLNXA64'),%
    root_dir = '/local/peysson/Simulations/Yves/DKE/FLUCT/';%if on cephee 
elseif strcmp(computer,'MACI64'),
    root_dir = '/IRFM-LOCAL/Simulations/Yves/DKE/FLUCT/';%Macbook pro Yves
    root_dir = '';
else
    root_dir = '';
end
%
scenario = input_dke_yp('Scenario name ?','');
itnmax = input_dke_yp('Number of iterations considered ?',1);
%
all_waves = [];
for itn = 1:itnmax
    load([root_dir,'wave_results/waves_',scenario,'_',int2str(itn),'.mat']); 
    %
    for iw = 1:length(waves)
        for jr = 1:length(waves{iw}.rays),
            waves{iw}.rays{jr}.P0_2piRp = waves{iw}.rays{jr}.P0_2piRp/itnmax;
            Npar0(itn,iw,jr) = real(waves{iw}.rays{jr}.sNpar(1));
        end
    end
    %
    all_waves = [all_waves,waves];
end
%
for jr = 1:length(waves{1}.rays),
    figure,hist(Npar0(:,iw,jr))
end
%
p_opt = input_dke_yp('Option for output figures : -1 (nothing), 0 (print), 1 (print and save), 2 (save)',-1,-1:2,'',[1,1]);
g_opt.abs_max = input_dke_yp('Option for ray trajectories : 0 (full trajectory), 1 (cut when damped)',0,0:1,'',[1,1]);
%
g_opt.mode = input_dke_yp('Option for showing ray polarization (n/y)','n',{'n','y'});
%xvaropt = input_dke_yp('Option for rho definition : 0 (geometric), 1 (poloidal flux), 2 (toroidal flux)',0,0:2,'',[1,1]);
xvar = input_dke_yp('Option for rho definition : ''g'' (geometric), ''p'' (poloidal flux), ''t'' (toroidal flux), ''v'' (volumic rho)','g',{'g','p','t','v'},'',[1,1]);
%
g_opt.print = p_opt;
g_opt.TeNpar = 1;
nr_dep = 40;
rho_disp = 0:0.1:1;
ymask = NaN;
%
graph_wave_jd(wavestructs{1}.equil,all_waves,nr_dep,g_opt,rho_disp,ymask,xvar);
%