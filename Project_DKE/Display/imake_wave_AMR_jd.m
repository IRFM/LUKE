function wave = imake_wave_ART_jd(workdir,equil,opt_gui)
%
% This function makes the WAVE file from ART ray-tracing output
%
wave = '';
%
filename_wavedata = 'luke_rays.dat';
%
[AMR_file,AMR_path] = igetfile_jd(opt_gui,filename_wavedata,['Please select the AMR ''',filename_wavedata,''' file'],equil.info.datapath);
%
if AMR_file == 0,
    return
end
%
wavedata = load([AMR_path,AMR_file],'-ascii');
%
shotime = wavedata(1);
antenna.num = wavedata(2);
antenna.conf = wavedata(3);
omega_rf = 2*pi*wavedata(4)*1e9;%initially in GHz
yP0 = wavedata(5:end)*1e3;%intially in kW
%
if str2num(equil.info.shotime) ~= shotime,
    disp('-----> The shot time is not compatible with equilibrium')
    return
end
%
shotnum = equil.info.shotnum;
shotime = equil.info.shotime;
%
ny = length(yP0);
%
dNpar = input('Spectral width [0.06]:');
if isempty(dNpar),
    dNpar = 0.06;
end
if ~isnumeric(dNpar),
    disp('-----> Invalid Spectral width');
    return
end
%
kmode = input('Plasma model for wave propagation : (0:cold, 1:kinetic) [1] :');
if isempty(kmode),
    kmode = 1;
end
if ~isnumeric(kmode) | ~any(kmode == [0:4]),
    disp('-----> Invalid plasma model option');
    return
end
%
opt_rf = input('FLR effects : (0:all, 1:small) [0] :');
if isempty(opt_rf),
    opt_rf = 0;
end
if ~isnumeric(opt_rf) | ~any(opt_rf == [0:1]),
    disp('-----> Invalid FLR effects option');
    return
end
%
wave_id_o = ['AMR'];
%
wave_id = input(['Please provide an id for the wave [',wave_id_o,'] : '],'s');
if isempty(wave_id),
    wave_id = wave_id_o;
end
%
for iy = 1:ny,
    %
    antnum = num2str(antenna.num);
    antnum = ['0'*ones(1,2-length(antnum)),antnum];
    %
    antconf = num2str(antenna.conf);
    antconf = ['0'*ones(1,4-length(antconf)),antconf];
    %    
    raynum = num2str(iy);
    raynum = ['0'*ones(1,2-length(raynum)),raynum];
    %
    filename_ray = ['LUKERT_',antnum,'_',antconf,'_',shotnum,'_',shotime,'_',raynum,'.dat'];
    %
    if exist([AMR_path,filename_ray]) ~= 2,
        disp(['-----> Ray # ',num2str(iy),' not found. Aborted.'])
        return
    end
    %
    raydata = load([AMR_path,filename_ray],'-ascii');
    %
    ray.P0_2piRp = yP0(iy)/(2*pi*equil.Rp);% Power launched in the ray (W) [1,1]
    %
    ray.sx = raydata(:,1).' - equil.Rp;% Ray location (major radius) along the propagation [1,ns]
    %
    ns = length(ray.sx);
    %
    % warning: - sign comes from opposite phi definition
    %
    ray.sphi = - raydata(:,3).';% Ray location (toroidal angle) along the propagation [1,ns]
    ray.sy = raydata(:,2).' - equil.Zp;% Ray location (vertical) along the propagation [1,ns]
    %
    ray.ss = [];% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
    ray.spsin = [];% Ray location (normalized magnetic flux) along the propagation [1,ns]
    ray.stheta = [];% Ray location (poloidal angle) along the propagation [1,ns]
    %
    %- sign necessary to match Npars. Check in ART
    %
    ray.skx = [];% Ray wave vector (major radius) along the propagation [1,ns]
    ray.sn = [];% Ray wave number (toroidal) along the propagation [1,ns]
    ray.sky = [];% Ray wave vector (vertical) along the propagation [1,ns]
    %
    ray.sNpar = raydata(:,4).';% Ray parallel wave number [1,ns]
    ray.sNperp = raydata(:,5).';% Ray perpendicular wave number [1,ns]
    ray.sdNpar = dNpar*ones(1,ns);% Ray spectral width in Npar [1,ns] 
    %       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
    %
    ray.sepol_pmz = [];% polarization vector [3,ns] complex
    ray.sphi_xyz = [];% normalized power flow [3,ns]
    %
    rays{iy} = ray;
    %
    disp(['-----> Ray # ',num2str(iy),' is loaded.'])
    %
end
%
wave.id = wave_id;
wave.omega_rf = omega_rf;
wave.opt_rf = opt_rf;%option for FLR calculations [1,1]
wave.opt_disp = 1 + kmode;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp)  
wave.equil_id = equil.id;
wave.kextra = 0;
wave.rays = rays;
%
wave.info.type = 'RT';
wave.info.RT = 'AMR';
wave.info.rays = [AMR_path,AMR_file];
%