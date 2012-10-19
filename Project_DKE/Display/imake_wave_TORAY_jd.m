function wave = imake_wave_TORAY_jd(equil)
%
% This function makes the WAVE file from TORAY ray-tracing ascii outputs
%
% by J. Decker (RLE/MIT) <jodecker@mit.edu> and Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
wave = '';
%
% get data
%
if isfield(equil,'info') & isfield(equil.info,'shotnum') & isfield(equil.info,'shotime');
    ray_file = ['rays.toray_',equil.info.shotnum,'t',equil.info.shotime];
    geom_file = ['raygeom_',equil.info.shotnum,'t',equil.info.shotime];
else
    ray_file = 'rays.toray_';
    geom_file = 'raygeom_';
end                
%
[ray_file,ray_path] = uigetfile('rays.toray_*.*',['Please select the toray rays data file :'],ray_file);
[geom_file,geom_path] = uigetfile('raygeom_*.*',['Please select the toray launching file :'],[ray_path,geom_file]);
%
if all(ray_file) == 0 | all(ray_file) == 0,
    return
end
%
% [ny] = textread([geom_path,geom_file],'%n',1);%number of rays
% [yX_L,yY_L,yZ_L,ybeta_L,yalpha_L,yfreq] = textread([geom_path,geom_file],'%n%n%n%n%n%n',ny+1);
%
fid = fopen([geom_path,geom_file]);
ny = fscanf(fid,'%d',1);
for iy = 1:ny,
    raydata = fscanf(fid,'%f',7);
    yX_L(iy) = raydata(1);
    yY_L(iy) = raydata(2);
    yZ_L(iy) = raydata(3);
    ybeta_L(iy) = raydata(4);
    yalpha_L(iy) = raydata(5);
    yfreq(iy) = raydata(6);
end
fclose(fid);
%
% group by beams
%
freq = -1;
ib = 0;
%
for iy = 1:ny,
    if yfreq(iy) ~= freq | abs(beta_L - ybeta_L(iy)) > 10, %new beam
        ib = ib + 1;
        beam{ib} = iy;
        freq = yfreq(iy);
        beta_L = ybeta_L(iy);
    else, %same beam
        beam{ib} = [beam{ib},iy];
    end
    nb = ib;
end
%
disp(['-----> The number of beams is ',num2str(nb)]);
for ib = 1:nb,
    freq(ib) = yfreq(beam{ib}(1));
    beta_L(ib) = mean(ybeta_L(beam{ib}));
    disp(['-----> Beam # ',num2str(ib),', frequency : ',num2str(freq(ib)),', beta_L : ',num2str(beta_L(ib))]);
end
%
% select the beam
%
ib = input('Select a beam number [1] : ');
if isempty(ib),
    ib = 1;
end
if ~isnumeric(ib) | ~any(ib == 1:nb),
    disp('-----> Invalid beam selection');
    return
end
%
freq_new = input(['Wave Frequency [',num2str(freq(ib)),']: ']);
if isempty(freq_new) 
    freq_new = freq(ib);
end
if ~isnumeric(freq(ib)),
    disp('-----> Invalid frequency value');
    return
end
%
% load ray-tracing data from TORAY
%
[sx,sy,sz,sPabs,ss,sNperp,sNpar] = textread([ray_path,ray_file],'%n%n%n%n%n%n%n');
%
% separate into individual rays
%
iy = 0;
while ~isempty(ss),
    iy = iy + 1;
    isep = min(find(ss == -1));
    %
    syx{iy} = sx(1:isep-1);
    syy{iy} = sy(1:isep-1);
    syz{iy} = sz(1:isep-1);
    syPabs{iy} = sPabs(1:isep-1);
    sys{iy} = ss(1:isep-1);
    syNperp{iy} = sNperp(1:isep-1);
    syNpar{iy} = sNpar(1:isep-1);
    ns(iy) = isep-1;
    %
    % Remove double points
    %
    idb = find(diff(sys{iy}) == 0);
    %
    syx{iy}(idb) = [];
    syy{iy}(idb) = [];
    syz{iy}(idb) = [];
    syPabs{iy}(idb) = [];
    sys{iy}(idb) = [];
    syNperp{iy}(idb) = [];
    syNpar{iy}(idb) = [];
    ns(iy) = ns(iy) - length(idb);
    %
    sx(1:isep) = [];
    sy(1:isep) = [];
    sz(1:isep) = [];
    sPabs(1:isep) = [];
    ss(1:isep) = [];
    sNperp(1:isep) = [];
    sNpar(1:isep) = [];
    %
end
%
if iy ~= ny,
    disp('-----> Ray propagation and geometry data have different numbers of rays.');
    return
end
%
% filter rays for the beam
%
syx = syx(beam{ib});
syy = syy(beam{ib});
syz = syz(beam{ib});
syPabs = syPabs(beam{ib});
sys = sys(beam{ib});
syNperp = syNperp(beam{ib});
syNpar = syNpar(beam{ib});
ns = ns(beam{ib});
%
ny = length(beam{ib});
%
% normalization
%
for iy = 1:ny,
    syx{iy} = syx{iy}/1e2;%cm -> m
    syy{iy} = syy{iy}/1e2;
    syz{iy} = syz{iy}/1e2;
    sys{iy} = sys{iy}/1e2;
    %
    syR{iy} = sqrt(syx{iy}.^2 + syy{iy}.^2);
    syZ{iy} = syz{iy};
    syphi{iy} = -atan(syy{iy}./syx{iy});%LUKE definition of phi
end
%
% ray spectral width
%
dNpar0 = input('Ray spectral width [0.02] : ');
if isempty(dNpar0),
    dNpar0 = 0.02;
end
if ~isnumeric(dNpar0),
    disp('-----> Invalid choice');
    return
end
%
for iy = 1:ny,
    sydNpar{iy} = dNpar0*ones(ns(iy),1);
end
%
% ray power
%
P0 = input('Total power in the beam [MW] : ');
if isempty(P0) | ~isnumeric(P0),
    disp('-----> Invalid choice');
    return
end
%
for iy = 1:ny,
    ray.P0_2piRp = 1e6*P0/ny/(2*pi*equil.Rp);% Power launched in the ray (W) [1,1]
    %
    ray.sx = syR{iy}.' - equil.Rp;% Ray location (major radius) along the propagation [1,ns]
    ray.sphi = syphi{iy}.';% Ray location (toroidal angle) along the propagation [1,ns]
    %ray.sy = syZ{iy}.' - equil.Zp;% Ray location (vertical) along the propagation [1,ns]
    ray.sy = syZ{iy}.';% toray data vs Z = Zp (!!!!! or Z = Zp_offset???)
    %
    ray.ss = sys{iy}.';% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
    ray.spsin = [];% Ray location (normalized magnetic flux) along the propagation [1,ns]
    ray.stheta = [];% Ray location (poloidal angle) along the propagation [1,ns]
    %
    ray.skx = [];% Ray wave vector (major radius) along the propagation [1,ns]
    ray.sn = [];% Ray wave number (toroidal) along the propagation [1,ns]
    ray.sky = [];% Ray wave vector (vertical) along the propagation [1,ns]
    %
    ray.sNpar = syNpar{iy}.';% Ray parallel wave number [1,ns]
    ray.sNperp = syNperp{iy}.';% Ray perpendicular wave number [1,ns]
    ray.sdNpar = sydNpar{iy}.';% Ray spectral width in Npar [1,ns] 
    %       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
    %
    ray.sepol_pmz = [];% polarization vector [3,ns] complex
    ray.sphi_xyz = [];% normalized power flow [3,ns]
    %
    ray.sP_2piRp_lin = ray.P0_2piRp*(1 - syPabs{iy}.');
    %
    rays{iy} = ray;
end
%
kmode = input('Plasma model for wave propagation : (0:cold, 1:warm, 2:kinetic nonrelativistic, 3:kinetic relativistic) [0] :');
if isempty(kmode),
    kmode = 0;
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
wave_id_o = ['TORAY_',num2str(ib)];
%
wave_id = input(['Please provide an id for the wave [',wave_id_o,'] : '],'s');
if isempty(wave_id),
    wave_id = wave_id_o;
end
%
wave.id = wave_id;
wave.omega_rf = 2*pi*freq_new*1e9;
wave.opt_rf = opt_rf;%option for FLR calculations [1,1]
wave.opt_disp = 1 + kmode;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp)  
wave.equil_id = equil.id;
wave.kextra = 0;
wave.rays = rays;
%
wave.info.type = 'RT';
wave.info.RT = 'TORAY';
wave.info.geom = [geom_path,geom_file];
wave.info.rays = [ray_path,ray_file];
%
%