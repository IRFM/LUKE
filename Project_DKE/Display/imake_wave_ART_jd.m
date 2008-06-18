function wave = imake_wave_ART_jd(workdir,equil,opt_gui)
%
% This function makes the WAVE file from ART ray-tracing output
%
wave = '';
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;%Universal physics constants
%
[ART_file,ART_path] = igetfile_jd(opt_gui,'*.*',['Please select the ART output file'],workdir);
%
if ART_file == 0,
    return
end
load([ART_path,ART_file],'ARTsimdat');
%
P0 = input('Wave power (kW) :');
if isempty(P0) | ~isnumeric(P0),
    disp('-----> Invalid Wave power');
    return
end
%
freq = input('Wave frequency (GHz) [82.7]:');
if isempty(freq),
    freq = 82.7;
end
if ~isnumeric(freq),
    disp('-----> Invalid Wave frequency');
    return
end
%
dNpar = input('Spectral width [0.2]:');
if isempty(freq),
    dNpar = 0.2;
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
wave_id_o = ['ART'];
%
wave_id = input(['Please provide an id for the wave [',wave_id_o,'] : '],'s');
if isempty(wave_id),
    wave_id = wave_id_o;
end
%
omega_rf = 2*pi*freq*1e9;
%
smask = [1;1+find((diff(ARTsimdat.R.data) ~= 0) | (diff(ARTsimdat.Phi.data) ~= 0) | (diff(ARTsimdat.z.data) ~= 0))];
%
ray.P0_2piRp = 1e3*P0/(2*pi*equil.Rp);% Power launched in the ray (W) [1,1]
%
ray.sx = ARTsimdat.R.data(smask).'*1e-2 - equil.Rp;% Ray location (major radius) along the propagation [1,ns]
ray.sphi = - ARTsimdat.Phi.data(smask).'*pi/180;% Ray location (toroidal angle) along the propagation [1,ns]
ray.sy = ARTsimdat.z.data(smask).'*1e-2;% Ray location (vertical) along the propagation [1,ns]
%
ray.ss = [];% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
ray.spsin = [];% Ray location (normalized magnetic flux) along the propagation [1,ns]
ray.stheta = [];% Ray location (poloidal angle) along the propagation [1,ns]
%
%- sign necessary to match Npars. Check in ART
%
ray.skx = - ARTsimdat.NR.data(smask).'*omega_rf/clum;% Ray wave vector (major radius) along the propagation [1,ns]
ray.sn = - ARTsimdat.Nphi.data(smask).'.*ARTsimdat.R.data(smask).'*1e-2*omega_rf/clum;% Ray wave number (toroidal) along the propagation [1,ns]
ray.sky = - ARTsimdat.Nz.data(smask).'*omega_rf/clum;% Ray wave vector (vertical) along the propagation [1,ns]
%
ray.sNpar_comp = ARTsimdat.Npar.data(smask).';% Ray parallel wave number [1,ns]
ray.sNpar = [];% Ray parallel wave number [1,ns]
ray.sNperp = [];% Ray perpendicular wave number [1,ns]
ray.sdNpar = dNpar*ones(1,length(smask));% Ray spectral width in Npar [1,ns] 
%       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
%
ray.sepol_pmz = [];% polarization vector [3,ns] complex
ray.sphi_xyz = [];% normalized power flow [3,ns]
%
rays{1} = ray;
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
wave.info.RT = 'ART';
wave.info.rays = [ART_path,ART_file];
%