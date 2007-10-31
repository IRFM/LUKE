function wave = make_idealLHwave_jd(equil,wavestruct)
%
% Creates a wave structure based on ideal LHCD parameters
%
%
omega_lh = wavestruct.omega_lh;
opt_lh = wavestruct.opt_lh;
norm_ref = wavestruct.norm_ref;
yvparmin_lh = wavestruct.yvparmin_lh;
yvparmax_lh = wavestruct.yvparmax_lh;
yNparmin_lh = wavestruct.yNparmin_lh;
yNparmax_lh = wavestruct.yNparmax_lh;
yNpar_lh = wavestruct.yNpar_lh;
ydNpar_lh = wavestruct.ydNpar_lh;
yD0_in_c_lh = wavestruct.yD0_in_c_lh;
yD0_in_lh_prof = wavestruct.yD0_in_lh_prof;
ypeak_lh = wavestruct.ypeak_lh;
ywidth_lh = wavestruct.ywidth_lh;
ythetab_lh = wavestruct.ythetab_lh;
%
% parameters for makefile
%
ns = 1000;%for sufficient radial resolution (even number)
method = 'spline';
%
%==========================================================================
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;
%
[equilDKE] = equilibrium_jd(equil);
%
srho = 1:-1/ns:1/ns;%radial position along the rays
%
Te0 = equilDKE.xTe(1);
ne0 = equilDKE.xne(1);
lnc_e_ref = 31.3 - 0.5*log(ne0) + log(Te0*1000);%Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
betath_ref = sqrt(Te0/mc2);
nhuth_ref = qe^4*ne0.*lnc_e_ref./(4*pi*e0^2*me^2.*(clum*betath_ref).^3);%Electron collision frequency (s-1)
%
sTe = interp1(equilDKE.xrho,equilDKE.xTe,srho,method);
sne = interp1(equilDKE.xrho,equilDKE.xne,srho,method);
slnc_e = 31.3 - 0.5*log(sne) + log(sTe*1000);%Coulomb logarithm (Sauter et al. Phys. Plasmas, 6 (1999) 2834)
sbetath = sqrt(sTe/mc2);
snhuth = qe^4*sne.*slnc_e./(4*pi*e0^2*me^2.*(clum*sbetath).^3);%Electron collision frequency (s-1)
swpe = sqrt(qe^2*sne/me/e0);
%
if norm_ref == 0,
    srbetath = ones(1,ns);
    srnhuth = ones(1,ns);
else
    srbetath = sbetath/betath_ref;
    srnhuth = snhuth/nhuth_ref;
end
%
nb_lh = length(yD0_in_c_lh);% number of stored scenarios
%
sythetab_lh = ones(ns,1)*ythetab_lh;
%
syvparmin_lh = ones(ns,1)*yvparmin_lh;
syvparmax_lh = ones(ns,1)*yvparmax_lh;
syNparmin_lh = ones(ns,1)*yNparmin_lh;
syNparmax_lh = ones(ns,1)*yNparmax_lh;
syNpar_lh = ones(ns,1)*yNpar_lh;
sydNpar_lh = ones(ns,1)*ydNpar_lh;
syD0_in_c_lh = ones(ns,1)*yD0_in_c_lh;
sypeak_lh = ones(ns,1)*ypeak_lh;
sywidth_lh = ones(ns,1)*ywidth_lh;
%
syrbetath_lh = repmat(srbetath',[1,nb_lh]);
syrnhuth_lh = repmat(srnhuth',[1,nb_lh]);
sybetath_loc =  repmat(sbetath',[1,nb_lh]);
%
ytest_maskvpar_lh =  ~isnan(yvparmin_lh) & ~isnan(yvparmax_lh);
ytest_maskNpars_lh =  ~isnan(yNparmin_lh) & ~isnan(yNparmax_lh);
ytest_maskNparg_lh =  ~isnan(yNpar_lh) & ~isnan(ydNpar_lh);
ytest_input_lh = [ytest_maskvpar_lh;ytest_maskNpars_lh;ytest_maskNparg_lh];
%
if sum(ytest_input_lh) ~= ones(1,nb_lh)
    error('LH Fourier spectrum input not compatible')
end
%
syvparmin_lh_loc = syvparmin_lh./syrbetath_lh;%Local Normalization (when norm_ref = 1)
syvparmax_lh_loc = syvparmax_lh./syrbetath_lh;%Local Normalization (when norm_ref = 1)
%
syNparmin_lh(:,ytest_maskvpar_lh) = 1./syvparmax_lh_loc(:,ytest_maskvpar_lh)./sybetath_loc(:,ytest_maskvpar_lh);%Conversion from vpar representation to Npar one (if yvparmax_lh not a NaN)
syNparmax_lh(:,ytest_maskvpar_lh) = 1./syvparmin_lh_loc(:,ytest_maskvpar_lh)./sybetath_loc(:,ytest_maskvpar_lh);%Conversion from vpar representation to Npar one (if yvparmin_lh not a NaN)
ytest_maskNpars_lh = logical(ytest_maskNpars_lh + ytest_maskvpar_lh);
%
syNpar_lh(:,ytest_maskNpars_lh) = (syNparmax_lh(:,ytest_maskvpar_lh) + syNparmin_lh(:,ytest_maskvpar_lh))/2;
%
% sydNpar_lh is made imaginary to identify square spectrum type (see rfwave)
sydNpar_lh(:,ytest_maskNpars_lh) = i*(syNparmax_lh(:,ytest_maskvpar_lh) - syNparmin_lh(:,ytest_maskvpar_lh));
%
yD0_in_lh_prof = logical(yD0_in_lh_prof);
%
syrho = srho'*ones(1,nb_lh);
%
syD0_in_lh = zeros(ns,nb_lh);
syD0_in_lh(:,yD0_in_lh_prof) = 2*sqrt(log(2))*exp(-(syrho(:,yD0_in_lh_prof) - sypeak_lh(:,yD0_in_lh_prof)).^2./(sywidth_lh(:,yD0_in_lh_prof)/2/sqrt(log(2))).^2).*syD0_in_c_lh(:,yD0_in_lh_prof)/sqrt(pi);%Gaussian radial profile on midplane
syD0_in_lh(:,~yD0_in_lh_prof) = syD0_in_c_lh(:,~yD0_in_lh_prof);%Uniform radial profile
%
syD0_lh = syD0_in_lh./(syrbetath_lh.*syrbetath_lh.*syrnhuth_lh);%Local Normalization
%
% Approximate values for relevant polarization and normalized power flow
% (Note: These eventually cancel out, but are useful for correct equivalent power scaling)
%
syepol_z_lh = 1./swpe'*omega_lh*ones(1,nb_lh);%approx Kperp=1, cancel out anyway
syphi_z_lh = 1./syNpar_lh;%approx Kperp=1, cancel out anyway
%
syepol_p_lh = [0]*ones(ns,nb_lh);%Not relevant in small FLR limit
syepol_m_lh = [0]*ones(ns,nb_lh);%Not relevant in small FLR limit
syphi_x_lh = [0]*ones(ns,nb_lh);%Not relevant
syphi_y_lh = [0]*ones(ns,nb_lh);%Not relevant
%
%Normalization of the diffusion coefficient for comparison with old calc. (Karney, Shoucri), see rfdiff_dke_jd
%
synorm_2piRp_lh = (srho*equilDKE.ap*me.*slnc_e.*swpe.^2*omega_lh)'*ones(1,nb_lh).*abs(syphi_z_lh)./syepol_z_lh.^2/2/pi;
%
syP0_2piRp_lh = zeros(ns,nb_lh);
syP0_2piRp_lh(:,ytest_maskNpars_lh) = synorm_2piRp_lh(:,ytest_maskNpars_lh).*syD0_lh(:,ytest_maskNpars_lh).*(syNparmax_lh(:,ytest_maskNpars_lh) - syNparmin_lh(:,ytest_maskNpars_lh));%Square power spectrum
syP0_2piRp_lh(:,ytest_maskNparg_lh) = synorm_2piRp_lh(:,ytest_maskNparg_lh).*syD0_lh(:,ytest_maskNparg_lh).*sydNpar_lh(:,ytest_maskNparg_lh)*sqrt(pi);%Gaussien power spectrum
%
% Note: The initial power in the ray is a scalar. In order to take into
% account the location dependence calculated above, and which results from
% D0 normalization, profiles and dnpar, we include this dependence in phi,
% while P0 is taken to be its maximum value along the ray. 
% (since Dql ~ P/|phi|)
%
yP0_2piRp_lh = max(syP0_2piRp_lh);
syphi_z_lh = syphi_z_lh.*(ones(ns,1)*yP0_2piRp_lh)./(syP0_2piRp_lh+eps);
%
%
syNperp_lh = syNpar_lh./syepol_z_lh;%Electrostatic limit. Indicative, not relevant in small FLR limit
%
syx = equilDKE.ap*syrho.*cos(sythetab_lh);
syy = equilDKE.ap*syrho.*sin(sythetab_lh);
syz = [0]*ones(ns,nb_lh);% so that the calculated finc is 1.
%
for i_lh = 1:length(ythetab_lh),
    ray.P0_2piRp = yP0_2piRp_lh(i_lh)';% Power launched in the ray (W) [1,1]
        %
    ray.sx = syx(:,i_lh)';% Ray location (major radius) along the propagation [1,ns]
    ray.sz = syz(:,i_lh)';% Ray location (vertical) along the propagation [1,ns]
    ray.sy = syy(:,i_lh)';% Ray location (toroidal angle) along the propagation [1,ns]
        %
    ray.ss = [];% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
    ray.spsin = [];% Ray location (normalized magnetic flux) along the propagation [1,ns]
    ray.stheta = [];% Ray location (poloidal angle) along the propagation [1,ns]
        %
    ray.skx = [];% Ray wave vector (major radius) along the propagation [1,ns]
    ray.skz = [];% Ray wave number (toroidal) along the propagation [1,ns]
    ray.sky = [];% Ray wave vector (vertical) along the propagation [1,ns]
        %
    ray.sNpar = syNpar_lh(:,i_lh)';% Ray parallel wave number [1,ns]
    ray.sNperp = syNperp_lh(:,i_lh)';% Ray perpendicular wave number [1,ns]
    ray.sdNpar = reshape(sydNpar_lh(:,i_lh),[1,ns]);% Ray spectral width in Npar [1,ns] 
        %       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. -> square spectrum (centered on sNpar)
        %
    syepol_pmz_lh = [syepol_p_lh(:,i_lh)';syepol_m_lh(:,i_lh)';syepol_z_lh(:,i_lh)'];
    syphi_xyz_lh = [syphi_x_lh(:,i_lh)';syphi_y_lh(:,i_lh)';syphi_z_lh(:,i_lh)'];
        %
    ray.sepol_pmz = syepol_pmz_lh;% polarization vector [3,ns] complex
    ray.sphi_xyz = syphi_xyz_lh;% normalized power flow [3,ns]
    %
    rays{i_lh} = ray;
end
%  
wave.omega_rf = omega_lh;
wave.opt_rf = opt_lh;%option for FLR calculations [1,1]
wave.opt_disp = 0;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp) 
wave.equil_id = equil.id;
wave.rays = rays;
