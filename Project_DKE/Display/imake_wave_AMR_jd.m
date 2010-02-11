function wave = imake_wave_AMR_jd(basestr,equil,launch,workdir,opt_gui)
%
% This function makes the WAVE file from AMR ray-tracing output
% 
% by J. Decker (CEA-DRFC) <joan.decker@cea.fr>
%
wave = '';
%
% The following notations are necessary to write and read proper output files
%
% 6-digit shot number SSSSSS with leading zeros
%
shotnum = equil.info.shotnum;
shotnum = [repmat('0',[1,6-length(shotnum)]),shotnum];
%
% Time in fixed format T.TTT
%
shotime = num2str(str2num(equil.info.shotime),'%1.3f');
%
if isempty(launch),	% Read the existing data file
    %
    launch.type = 'EC';
    if isfield(equil.info,'datapath')
		%
		AMR_output_path = equil.info.datapath;
		%
    else
    	%
		AMR_simul_path = igetdir_jd(opt_gui,'Please select the AMR simulation folder',workdir);
		%
		AMR_output_path = [AMR_simul_path,'output/luke/'];
		%
    end
    %
else	% Run AMR
    %
    %AMR_script_path = getenv('AMR');
    AMR_script_path = '/home/jurban/AMR/';
    if isempty(AMR_script_path),
        AMR_script_path = workdir;
    end
	%
	AMR_script_path = igetdir_jd(opt_gui,'Please select the AMR code folder',AMR_script_path);
	AMR_simul_path = igetdir_jd(opt_gui,'Please select the AMR simulation folder',workdir);
    %
    launch.AMR_script_path = AMR_script_path;
    launch.AMR_simul_path = AMR_simul_path;
    %
    nprz = 101;
    extfacR = 0.1;
    extfacZ = 0.02;
    %
	AMR_input_path = [AMR_simul_path,'input/'];
	%
	if ~exist(AMR_input_path,'dir'),
		%
		mkdir(AMR_input_path)
		%
	end
	%
	equil_id = [num2str(shotnum),'_',shotime];
	%
    make_equil_RZ_AMR_jd(equil_id,equil,AMR_input_path,nprz,extfacR,extfacZ);
    [AMRcfg_file,launch] = make_input_AMR(basestr,equil,launch,AMR_script_path,AMR_simul_path,opt_gui);
    %
    sd = pwd;
    cd(AMR_simul_path)
    unix(['python ',AMR_script_path,'ebe6.py ',AMRcfg_file]);
    cd(sd);
    %
	AMR_output_path = [AMR_simul_path,'output/luke/'];
	%
end
%
scan_plot_opt = input_dke_yp('Do you want to plot the conversion efficiency scan [y/n]','y',{'y','n'},'',[1,1]);
if scan_plot_opt == 'y'
    if exist([AMR_simul_path,'ebe_run/output/conv_eff_0000.dat'],'file');
    	read_AMR_outputs(AMR_simul_path,1,2);
    else
    	disp(['No conv_eff_0000.dat file in ' AMR_simul_path 'ebe_run/output/ .']);
    end
end
%
filename_wavedata = ['luke_rays_*_',shotnum,'_',shotime,'.dat'];
%
[AMR_output_file,AMR_output_path] = igetfile_jd(opt_gui,filename_wavedata,['Please select the AMR output ''',filename_wavedata,''' file'],AMR_output_path);
%
if AMR_output_file == 0,
    return
end
%
wavedata = load([AMR_output_path,AMR_output_file],'-ascii');
%
antenna.num = wavedata(1,2);
antenna.conf = wavedata(1,3);
%
antnumbase = num2str(antenna.num);
antnum = ['0'*ones(1,2-length(antnumbase)),antnumbase];
%
antconfbase = num2str(antenna.conf);
antconf = ['0'*ones(1,4-length(antconfbase)),antconfbase];
%
waveparam.filestr = [antnum,'_',antconf,'_',shotnum,'_',shotime];
%
shotime = wavedata(1,1);
ny = size(wavedata,1);
%
if str2double(equil.info.shotime) ~= shotime,
    disp('-----> The shot time is not compatible with equilibrium')
    return
end
%
dNpar = input('Spectral width (NaN if calculated from beam size) [NaN]:');
if isempty(dNpar),
    dNpar = NaN;
end
if ~isnumeric(dNpar),
    disp('-----> Invalid Spectral width');
    return
end
%
kmode = input('Plasma model for wave propagation :\n (0:cold, 1:kinetic, 2:R2D2 (requires IMSL), 4:electrostatic) [4] :');
if isempty(kmode),
    kmode = 4;
end
if ~isnumeric(kmode) || ~any(kmode == 0:4),
    disp('-----> Invalid plasma model option');
    return
end
%
opt_rf = input('FLR effects : (0:all, 1:small) [0] :');
if isempty(opt_rf),
    opt_rf = 0;
end
if ~isnumeric(opt_rf) || ~any(opt_rf == 0:1),
    disp('-----> Invalid FLR effects option');
    return
end
%
dsmin = input_dke_yp('Minimum length of ray fragments:',0,[0;Inf],'',[1,1]);
%
if ny == 1,
    %
    nd_in = 1;
    nchi_in = 1;
    %
    nd = input(['Number of transverse distance positions for beamlets: [',num2str(nd_in),'] :']);
    if isempty(nd),
        nd = nd_in;
    end
    if ~isnumeric(nd),
        disp('-----> Invalid choice');
        return
    end
    %
    nchi = input(['Number of angular positions for beamlets: [',num2str(nchi_in),'] :']);
    if isempty(nchi),
        nchi = nchi_in;
    end
    if ~isnumeric(nchi),
        disp('-----> Invalid choice');
        return
    end
    %
else
    nd = 1;
    nchi = 1;
end
%
wave_id_o = ['AMR_',antnum,'_',antconf];
%
wave_id = input(['Please provide an id for the wave [',wave_id_o,'] : '],'s');
if isempty(wave_id),
    wave_id = wave_id_o;
end
%
waveparam.id = wave_id;
waveparam.AMR_output_path = AMR_output_path;
%
waveparam.dNpar = dNpar;
waveparam.dsmin = dsmin;
waveparam.kmode = kmode;
waveparam.opt_rf = opt_rf;
%
waveparam.nd = nd;
waveparam.nchi = nchi;
%
wave = proc_rays_AMR_jd(wavedata,waveparam,equil);
wave.launch = launch;
%
