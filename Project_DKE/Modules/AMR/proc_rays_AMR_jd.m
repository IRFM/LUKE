function wave = proc_rays_AMR_jd(wavedata,waveparam,equil)
%
% This function processes the AMR rays for LUKE
%
wave = '';
ny = size(wavedata,1);
%
shotnum = equil.info.shotnum;
shotime = equil.info.shotime;
%
antenna.num = wavedata(1,2);
antenna.conf = wavedata(1,3);
omega_rf = 2*pi*wavedata(1,4)*1e9;%initially in GHz
yP0 = wavedata(:,5)*1e3;%intially in kW
focalX = wavedata(1,6);
focalY = wavedata(1,7);
focalZ = wavedata(1,8);
w0 = wavedata(1,9);
%
rays = cell(1,ny);
%
for iy = 1:ny,
    %
    antnumbase = num2str(antenna.num);
    antnum = ['0'*ones(1,2-length(antnumbase)),antnumbase];
    %
    antconfbase = num2str(antenna.conf);
    antconf = ['0'*ones(1,4-length(antconfbase)),antconfbase];
    %    
    raynumbase = num2str(iy);
    raynum = ['0'*ones(1,2-length(raynumbase)),raynumbase];
    %
    filename_ray = ['LUKERT_',antnum,'_',antconf,'_',shotnum,'_',shotime,'_',raynum,'.dat'];
    %
    if ~exist([waveparam.AMR_path,filename_ray],'file'),
        disp(['-----> Ray # ',num2str(iy),' not found. Aborted.'])
        return
    end
    %
    raydata = load([waveparam.AMR_path,filename_ray],'-ascii');
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
	if waveparam.kmode == 2,
		ray.sNperp = NaN;
	else
    	ray.sNperp = raydata(:,5).';% Ray perpendicular wave number [1,ns]
	end
	%
    ray.sdNpar = waveparam.dNpar*ones(1,ns);% Ray spectral width in Npar [1,ns] 
    %       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
    %
    ray.sepol_pmz = NaN*ones(3,0);% polarization vector [3,ns] complex
    ray.sphi_xyz = NaN*ones(3,0);% normalized power flow [3,ns]
    %
    rays{iy} = ray;
    %
    disp(['-----> Ray # ',num2str(iy),' is loaded.'])
    %
end
%
wave.id = waveparam.id;
wave.omega_rf = omega_rf;
wave.opt_rf = waveparam.opt_rf;%option for FLR calculations [1,1]
wave.opt_disp = 1 + waveparam.kmode + 1i;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp)  
wave.equil_id = equil.id;
wave.kextra = 0;
wave.rays = rays;
%
wave.info.type = 'RT';
wave.info.RT = 'AMR';
wave.info.rayspath = waveparam.AMR_path;
%
if ny == 1,
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
    z0 = NaN;
end
%
raydisplay.ray = 0;
wave = make_beam_wave_jd(wave,equil,raydisplay,waveparam.nd,waveparam.nchi,w0,z0);
%