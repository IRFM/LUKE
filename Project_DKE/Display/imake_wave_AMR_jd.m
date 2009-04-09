function wave = imake_wave_AMR_jd(basestr,equil,workdir,opt_gui)
%
% This function makes the WAVE file from ART ray-tracing output
%
wave = '';
%
shotnum = equil.info.shotnum;
shotime = equil.info.shotime;
%
l_opt = input_dke_yp('Do you want to load AMR results (0), run AMR (1), or cancel this operation (2): ',0,{0,1,2},'Invalid option');
%
if l_opt == 1,
    %
    AMR_path = getenv('AMR');
    if isempty(AMR_path),
        AMR_path = igetdir_jd(opt_gui,'Please select the AMR code folder',workdir);
    end
    %
    nprz = 101;
    extfacR = 0.1;
    extfacZ = 0.02;
    %
    make_equil_RZ_AMR_jd(equil,[AMR_path,'input/'],nprz,extfacR,extfacZ);
    make_input_AMR(basestr,equil,AMR_path);
    %
    sd = pwd;
    cd(AMR_path)
    unix('python ebe6.py');
    cd(sd);
    %
elseif l_opt == 2,
    disp('-----> operation aborted.')
    return
end
%
filename_wavedata = ['luke_rays_*_',shotnum,'_',shotime,'.dat'];
%
[AMR_file,AMR_path] = igetfile_jd(opt_gui,filename_wavedata,['Please select the AMR ''',filename_wavedata,''' file'],equil.info.datapath);
%
if AMR_file == 0,
    return
end
%
wavedata = load([AMR_path,AMR_file],'-ascii');
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
kmode = input('Plasma model for wave propagation : (0:cold, 1:kinetic, 2:R2D2 (requires IMSL)) [2] :');
if isempty(kmode),
    kmode = 2;
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
waveparam.AMR_path = AMR_path;
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
%
