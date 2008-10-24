function wave = imake_wave_AMR_jd(basestr,equil,workdir,opt_gui)
%
% This function makes the WAVE file from ART ray-tracing output
%
wave = '';
%
l_opt = input_dke_yp('Do you want to load AMR results (0), run AMR (1), or cancel this operation (2): ',0,{0,1,2},'Invalid option');
%
if l_opt == 0,
    %
    filename_wavedata = 'luke_rays.dat';
    %
    [AMR_file,AMR_path] = igetfile_jd(opt_gui,filename_wavedata,['Please select the AMR ''',filename_wavedata,''' file'],equil.info.datapath);
    %
    if AMR_file == 0,
        return
    end
    %
elseif l_opt == 1,
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
    unix(['python ebe6.py']);
    cd(sd);
    %
    AMR_path = [AMR_path,'output/luke/'];
    AMR_file = 'luke_rays.dat';
else
    disp('-----> operation aborted.')
    return
end
%
wavedata = load([AMR_path,AMR_file],'-ascii');
%
shotime = wavedata(1,1);
antenna.num = wavedata(1,2);
antenna.conf = wavedata(1,3);
omega_rf = 2*pi*wavedata(1,4)*1e9;%initially in GHz
yP0 = wavedata(:,5)*1e3;%intially in kW
focalX = wavedata(1,6);
focalY = wavedata(1,7);
focalZ = wavedata(1,8);
w0 = wavedata(1,9);
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
dNpar = input('Spectral width (NaN if calculated from beam size) [NaN]:');
if isempty(dNpar),
    dNpar = NaN;
end
if ~isnumeric(dNpar),
    disp('-----> Invalid Spectral width');
    return
end
%
kmode = input('Plasma model for wave propagation : (0:cold, 1:kinetic, 2:R2D2 (requires IMSL)) [1] :');
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
    sR = raydata(:,1).';
    ray.sx = sR - equil.Rp;% Ray location (major radius) along the propagation [1,ns]
    %
    ns = length(ray.sx);
    %
    % warning: - sign comes from opposite phi definition
    %
    ray.sphi = - raydata(:,3).';% Ray location (toroidal angle) along the propagation [1,ns]
    %
    sZ = raydata(:,2).';
    ray.sy = sZ - equil.Zp;% Ray location (vertical) along the propagation [1,ns]
    %
    ss = zeros(1,ns);
    sRh = (sR(1:ns-1) + sR(2:ns))/2;
    ds = sqrt(diff(sR).^2 + (sRh.*diff(ray.sphi)).^2 + diff(sZ).^2);
    ss(2:ns) = cumsum(ds);
    %
    ray.ss = ss;% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
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
	%
	if kmode == 2,
		ray.sNperp = NaN;
	else
    	ray.sNperp = raydata(:,5).';% Ray perpendicular wave number [1,ns]
	end
	%
    ray.sdNpar = dNpar*ones(1,ns);% Ray spectral width in Npar [1,ns] 
    %       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
    %
    ray.sepol_pmz = NaN*ones(3,0);% polarization vector [3,ns] complex
    ray.sphi_xyz = NaN*ones(3,0);;% normalized power flow [3,ns]
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
wave.opt_disp = 1 + kmode + i;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp)  
wave.equil_id = equil.id;
wave.kextra = 0;
wave.rays = rays;
%
wave.info.type = 'RT';
wave.info.RT = 'AMR';
wave.info.rays = [AMR_path,AMR_file];
%
if ny == 1,
    %
    nd_in = 3;
    nchi_in = 4;
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
    sfocald = sqrt((focalX - sR.*cos(ray.sphi)).^2 +...
                   (focalY - sR.*sin(ray.sphi)).^2 +...
                   (focalZ - sZ).^2);
    is0 = find(sfocald == min(sfocald),1,'first');
    if sqrt(focalX.^2 + focalY.^2) > sR(1),
        z0 = -sfocald(1);
    else
        z0 = ray.ss(is0);
    end
    %
else
    nd = 1;
    nchi = 1;
    z0 = NaN;
end
%
raydisplay.ray = 0;
wave = make_beam_wave_jd(wave,equil,raydisplay,nd,nchi,w0,z0);
%