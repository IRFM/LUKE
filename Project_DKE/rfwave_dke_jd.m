function waveparam = rfwave_dke_jd(tokname,xrho,betath_ref,ne_ref,xrbetath,xrnhuth,xTe_norm,xne_norm,zxni_norm,Zi,mi,Bt,xq,Rp,ap,bounce_mode);
% 
%	RF input parameters for the Drift Kinetic equation solver (dke_4_1yp.m). Manual method, or with the cold plasma dispersion relation
% 
%	Input: None
%
%	Output: See the comments
%  
%	Warning: none
%	  
%Last Update: 08/06/03
%
%by J.Decker MIT/RLE <jodecker@mit.edu> and Y.Peysson CEA/DRFC <yves.peysson@cea.fr> 04/29/2003
%    
% ***************************** Test mode LH wave *****************************
% 
blist_lh = []; %Index of selected scenarios for the LH wave. Enter [] for none. [1,n_selected_scenario_lh]
%
yn_lh = [0,0,0];%RF resonance harmonic (zero for LH) [1,n_scenario_lh]
ythetab_lh = [0,0,0];%Poloidal location of LH beam (Degree) [1,n_scenario_lh]
%
% Choose (vparmin_lh,vparmax_lh) or (nparmin_lh,nparmax_lh) for square n// LH wave power spectrum, or (npar_lh,dnpar_lh) for Gaussian shape
%
yvparmin_lh = [3,NaN,NaN];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
yvparmax_lh = [5,NaN,NaN];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
ynparmin_lh = [NaN,NaN,NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
ynparmax_lh = [NaN,NaN,NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
ynpar_lh = [NaN,2,3];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
ydnpar_lh = [NaN,0.4,0.6];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
yomega_lh = [1,1,1];%LH wave frequency (GHz) (Not relevant when opt_lh > 0) [1,n_scenario_lh]
%
yD0c_lh = [1.0,1.0,1.0];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) (for benchmarking only) [1,n_scenario_lh]
D0_lh_prof = 0;%Quasilinear diffusion coefficient radial profile: (0) uniform , (1) gaussian radial profile [1,1]
peak_lh = 0.5;%Radial peak position of the LH quasi-linear diffusion coefficient (r/a) [1,1]
width_lh = 0.2;%Radial width of the LH quasi-linear diffusion coefficient (r/a) [1,1]
%
%Wave polarization (norm must be 1)
%
ynperp_lh = [0,0,0];%Not relevant when opt_lh > 0 [1,n_scenario_lh]
%
yepolp_lh = [0,0,0];%Not relevant when opt_lh > 0 [1,n_scenario_lh]
yepolm_lh = [0,0,0];%Not relevant when opt_lh > 0 [1,n_scenario_lh]
yepolz_lh = [1,1,1];%Only relevant polarization [1,n_scenario_lh]
%
%Option parameter for cross-comparison between old LH code: 
%	- (0): Exact calculation
%	- (1): no LRE effect for LH and 1/vpar dependence
%	- (2): no LRE effect for LH, no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
opt_lh = 2;  
%
% ***************************** Test mode EC Wave *****************************
% 
blist_ec = [];%Index of selected scenarios for the EC wave. Enter [] for none. [1,n_selected_scenario_ec]
%
yn_ec = [2,2,2];%EC resonance harmonic [1,n_scenario_ec]
ythetab_ec = [0,90,180];%poloidal location of EC beam (Degree) [1,n_scenario_ec]
%    
ynpar_ec = [0.3,0.3,0.3];%EC wave Gaussian N// Spectrum: peak n// [1,n_scenario_ec]
ydnpar_ec = [0.02,0.02,0.02];%EC wave Gaussian N// Spectrum: width in n// [1,n_scenario_ec]
%
yY_ec = [0.98,0.98,0.98];%Normalized EC wave frequency [1,n_scenario_ec]
yomega_ec = [NaN,NaN,NaN];%EC wave frequency (GHz) [1,n_scenario_ec]
%
yD0c_ec = [0.14,0.14,0.14];%Central EC QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) (for benchmarking only) [1,n_scenario_ec]
D0_ec_prof = 0;%Quasilinear diffusion coefficient radial profile: (0) uniform , (1) gaussian radial profile [1,1]
peak_ec = 0.4;%Radial peak position of the EC quasi-linear diffusion coefficient (r/a) [1,1]
width_ec = 0.2;%Radial width of the EC quasi-linear diffusion coefficient (r/a) [1,1]
%
%Polarization (norm must be 1)
%
yepolp_ec = [0,0,0];%Test X-Mode: (0) , test O-Mode: (0) (wpe < wpe and n// << 1) [1,n_scenario_ec]
yepolm_ec = [1,1,1];%Test X-Mode: (1) , test O-Mode: (0) (wpe < wpe and n// << 1) [1,n_scenario_ec]
yepolz_ec = [0,0,0];%Test X-Mode: (0) , test O-Mode: (1)  (wpe < wpe and n// << 1) [1,n_scenario_ec]
%
opt_ec = 0; %(0): exact, (1): small LRE 
%
%  ***************************** Cold plasma LH wave *****************************
%
blist_lhc = []; %Index of selected scenarios for the LH wave. Enter [] for none. [1,n_selected_scenario_lhc]
nb_lhc = length(blist_lhc);
%
yn_lhc = [0];%RF resonance harmonic (zero for LH) [1,n_scenario_lhc]
ythetab_lhc = [0]*pi/180;%Poloidal location of LH beam (Degree) [1,n_scenario_lhc]
%
% Choose (vparmin_lhc,vparmax_lhc) or (nparmin_lhc,nparmax_lhc) for square n// LH wave power spectrum, or (npar_lhc,dnpar_lhc) for Gaussian shape
%
yvparmin_lhc = [3.5];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lhc]
yvparmax_lhc = [6];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lhc]
ynparmin_lhc = [NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lhc]
ynparmax_lhc = [NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lhc]
ynpar_lhc = [NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lhc]
ydnpar_lhc = [NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lhc]
%
yomega_lhc = [4.6]*2*pi*1e9;%LH wave frequency (Rad/s)(Not relevant when opt_lhc > 0) [1,n_scenario_lhc]
%
yPinc_lhc = [2.0]*1e6;%Central LH Incident Power (W)
yP0_lhc_prof = [0];%Power radial profile: (0) uniform , (1) gaussian radial profile [1,n_scenario_lhc]
ypeak_lhc = [0.5];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a) [1,n_scenario_lhc]
ywidth_lhc = [0.2];%Radial width of the LH quasi-linear diffusion coefficient (r/a) [1,n_scenario_lhc]
%
%Option parameter for cross-comparison between old LH code: 
%	- (0): Exact calculation
%	- (1): no LRE effect for LH and 1/vpar dependence
%	- (2): no LRE effect for LH, no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
yopt_lhc = [0];  
yideal_lhc = [0]; %(0): cold dispersion model, (1): ideal case
yfinc_lhc = [1];% incidence factor. In the limit of infinitely thin flux-surface, yfinc_ecc = 1/cos(alpha)
%                                                       where alpha is the incidence angle of the ray on the surface 
%
%  ***************************** Local ECCD Calculation *****************************
%
blist_ecc = [];
nb_ecc = length(blist_ecc);
%
yn_ecc = [2];%EC resonance harmonic
ythetab_ecc = [0]*pi/180;%poloidal location of EC beam [rad]
ypol_ecc = [1];%polarization, (0): O-Mode, (1):X-Mode
%    
ynpar_ecc = [0.3];%EC wave Gaussian N// Spectrum: peak n//
ydnpar_ecc = [0.02];%EC wave Gaussian N// Spectrum: width in n//
ybwidth_ecc = [NaN];%EC wave Gaussian width. Used when xydnpar_ecc == NaN
yY_ecc = [0.98];%EC wave frequency [rad/s]
yomega_ecc = [NaN]*2*pi*1e9;%EC wave frequency [rad/s]
%
yPinc_ecc = [2]*1e6;%central EC incident power (W)
%
yopt_ecc = [0]; %(0): exact, (1): small LRE
yideal_ecc = [0]; %(0): warm plasma dispersion model, (1): cold plasma dispersion model, (2): ideal case
yfinc_ecc = [1];% incidence factor. In the limit of infinitely thin flux-surface, yfinc_ecc = 1/cos(alpha)
%                                                       where alpha is the incidence angle of the ray on the surface 
%
%  ***************************** Local EBW Calculation *****************************
%
blist_ebw = [];
nb_ebw = length(blist_ebw);
%
yn_ebw = [3];%EBW resonance harmonic
ythetab_ebw = [0]*pi/180;%poloidal location of EBW beam [rad]
%    
ynpar_ebw = [0.6];%EBW wave Gaussian N// Spectrum: peak n//
ydnpar_ebw = [0.05];%EBW wave Gaussian N// Spectrum: width in n//
ybwidth_ebw = [NaN];%EBW wave Gaussian width. Used when xydnpar_ebw == NaN
yY_ebw = [NaN];%EBW wave frequency shift n.omega_ce/omega_rf
yomega_ebw = [NaN]*2*pi*1e9;%EBW wave frequency [rad/s]
%
yPinc_ebw = [1]*1e6;%central EBW incident power (W)
%
yopt_ebw = [0]; %(0): exact, (1): small LRE
yfinc_ebw = [1];% incidence factor. In the limit of infinitely thin flux-surface, yfinc_ebw = 1/cos(alpha)
%                                                       where alpha is the incidence angle of the ray on the surface 
%                                                       where alpha is the incidence angle of the ray on the surface 
%
%***************************** Wave matrix calculation *****************************
%
qe = 1.60217733e-19;%Electron charge (C)
me = 9.1093897e-31;%Electron rest mass (Kg)
mc2 = 510.99905;%Electron energy rest mass (keV)
%
% modified j.d. 11/20/03 -> Poloidal component added, derived from q factor.
%
iaa = ap/Rp;
nr = length(xrho);
xia = xrho*iaa;
xBt0 = Bt./(1+xia);
xq(xq == 0) = eps;
xBp0 = xrho*iaa.*xBt0./xq;
xB0 = sqrt(xBt0.^2 + xBp0.^2);
xwce0 = qe*xB0/me;
%
Te_ref = mc2*betath_ref^2;
%
xyn_lh = ones(nr,1)*yn_lh;
xythetab_lh = ones(nr,1)*ythetab_lh*pi/180;%(deg -> rad)
xyvparmin_lh = ones(nr,1)*yvparmin_lh;
xyvparmax_lh = ones(nr,1)*yvparmax_lh;
xynparmin_lh = ones(nr,1)*ynparmin_lh ;
xynparmax_lh = ones(nr,1)*ynparmax_lh;
xynpar_lh = ones(nr,1)*ynpar_lh;
xydnpar_lh = ones(nr,1)*ydnpar_lh;
xyomega_lh = 2*pi*1e9*ones(nr,1)*yomega_lh;%(Hz - > rad/s)
xynperp_lh = ones(nr,1)*ynperp_lh;
xyepolp_lh = ones(nr,1)*yepolp_lh;
xyepolm_lh = ones(nr,1)*yepolm_lh;
xyepolz_lh = ones(nr,1)*yepolz_lh;
%
nb_lh = length(blist_lh);
ns_lh = size(xyn_lh,2);%Number of LH scenarios stored in rfwave_dke_jd.m
xyopt_lh = opt_lh*ones(nr,ns_lh); 
%
xyn_ec = ones(nr,1)*yn_ec;
xythetab_ec = ones(nr,1)*ythetab_ec*pi/180;%(deg -> rad)
xynpar_ec = ones(nr,1)*ynpar_ec;
xydnpar_ec = ones(nr,1)*ydnpar_ec;
xyY_ec = ones(nr,1)*yY_ec;
xyomega_ec = 2*pi*1e9*ones(nr,1)*yomega_ec;%(Hz - > rad/s)
xyepolp_ec = ones(nr,1)*yepolp_ec;
xyepolm_ec = ones(nr,1)*yepolm_ec;
xyepolz_ec = ones(nr,1)*yepolz_ec;
%
nb_ec = length(blist_ec);
ns_ec = size(xyn_ec,2);%Number of EC scenarios stored in rfwave_dke_jd.m
xyopt_ec = opt_ec*ones(nr,ns_ec);  
%
nb_test = nb_lh + nb_ec;
% 
% Case LH wave
%
if D0_lh_prof == 1 
    xyD0_lh = exp(-(xrho - peak_lh).^2./(width_lh/2/sqrt(log(2)))^2)*yD0c_lh;%Gaussian radial profile
else
    xyD0_lh = ones(nr,1)*yD0c_lh;%Uniform radial profile
end
%
xyrbetath_lh = repmat(xrbetath,[1,ns_lh]);
xyrnhuth_lh = repmat(xrnhuth,[1,ns_lh]);
%
test_maskvparmin_lh =  isnan(yvparmin_lh(blist_lh));
test_maskvparmax_lh =  isnan(yvparmax_lh(blist_lh));
test_masknparmin_lh =  isnan(ynparmin_lh(blist_lh));
test_masknparmax_lh =  isnan(ynparmax_lh(blist_lh));
test_masknpar_lh =  isnan(ynpar_lh(blist_lh));
test_maskdnpar_lh =  isnan(ydnpar_lh(blist_lh));
test_input_lh = [test_maskvparmin_lh;test_maskvparmax_lh;test_masknparmin_lh;test_masknparmax_lh;test_masknpar_lh;test_maskdnpar_lh];
%
xyvparmin_lh_ref = xyvparmin_lh.*xyrbetath_lh;%Normalization when norm_ref = 0
xyvparmax_lh_ref = xyvparmax_lh.*xyrbetath_lh;%Normalization when norm_ref = 0
xyD0_lh_ref_in = xyD0_lh.*xyrnhuth_lh.*xyrbetath_lh.*xyrbetath_lh;%Normalization when norm_ref = 0
%
mask_vlims = ~isnan(xyvparmin_lh_ref);
xynparmin_lh(mask_vlims) = 1./xyvparmax_lh_ref(mask_vlims)/betath_ref;%Conversion from vpar representation to npar one (if yvparmax_lh not a NaN)
xynparmax_lh(mask_vlims) = 1./xyvparmin_lh_ref(mask_vlims)/betath_ref;%Conversion from vpar representation to npar one (if yvparmin_lh not a NaN)
%
%The quasilinear diffusion coefficient  xyD0_lh_ref is must be transformed to the general expression
%Normalization of the diffusion coefficient for comparison with old calc. (Karney, Shoucri), see rfdiff_dke_jd
%
if nb_lh > 0,
    if (test_input_lh == [0;0;1;1;1;1]*ones(1,nb_lh)) |  (test_input_lh == [1;1;0;0;1;1]*ones(1,nb_lh)), 
    	xyD0_lh_ref = xyD0_lh_ref_in.*(xynparmax_lh - xynparmin_lh);%Square power spectrum
    elseif (test_input_lh == [1;1;1;1;0;0]*ones(1,nb_lh))
        xyD0_lh_ref = xyD0_lh_ref_in.*xydnpar_lh*sqrt(pi);%Gaussien power spectrum
    else
    	error('Input parameters for the LH wave quasilinear diffusion coefficient in rfwave_dke_jd are not consistent !');
    end
else
    xyD0_lh_ref = xyD0_lh_ref_in;
end
%
%  Case EC wave
%
if D0_ec_prof == 1 
	xyD0_ec = exp(-(xrho - peak_ec).^2./(width_ec/2/sqrt(log(2)))^2)*yD0c_ec;%Gaussian radial profile 
else
	xyD0_ec = ones(nr,1)*yD0c_ec;%Uniform radial profile
end
%
xyrbetath_ec = repmat(xrbetath,[1,ns_ec]);
xyrnhuth_ec = repmat(xrnhuth,[1,ns_ec]);
%
xyD0_ec_ref_in = xyD0_ec.*xyrnhuth_ec.*xyrbetath_ec.*xyrbetath_ec; %Normalization when norm_ref = 0

%
xynparmin_ec = NaN*ones(nr,ns_ec);
xynparmax_ec = NaN*ones(nr,ns_ec);
%
xynperp_ec = sqrt(1 - xynpar_ec.^2);
%
xywce0_ec = repmat(xwce0,[1,ns_ec]);
xyia_ec = repmat(xia,[1,ns_ec]);
xypsib_ec = (1+xyia_ec)./(1+xyia_ec.*cos(xythetab_ec));
%    
mask_ygiven = ~isnan(xyY_ec);
xyomega_ec(mask_ygiven) = xyn_ec(mask_ygiven).*xywce0_ec(mask_ygiven).*xypsib_ec(mask_ygiven)./xyY_ec(mask_ygiven);
%
% Normalization of the diffusion coefficient for comparison with old calc. (Karney, Shoucri), see rfdiff_dke_jd  
%
xyD0_ec_ref = xyD0_ec_ref_in.*xydnpar_ec*sqrt(pi).*xyrbetath_ec; %Comment : the last rbetath is for the 1/vth factor
xyD0_ec_ref = 2*xyepolm_ec.*xyD0_ec_ref./(xyrbetath_ec.*betath_ref.*xynperp_ec.*xyomega_ec/2./xywce0_ec).^(2*(xyn_ec - 1))...
            + xyepolz_ec.*xyD0_ec_ref./(xyrbetath_ec.*betath_ref.*xynperp_ec.*xyomega_ec/2./xywce0_ec).^(2*xyn_ec);  
%
%Actual cyclotron frequency when no trapped particle effect is considered (bounce_mode =0) (see rfdiff_dke_jd)
%
xythetab = [xythetab_lh(:,blist_lh),xythetab_ec(:,blist_ec)];
xywce0 = repmat(xwce0,[1,nb_test]);
xyia = repmat(xia,[1,nb_test]);
%
if bounce_mode == 0,
    xypsib = (1 + xyia)./(1 + xyia.*cos(xythetab));
    xywce_out = xywce0.*xypsib;
else
    xywce_out = xywce0;
end
%    
waveparam_test = zeros(nr,nb_test,14);
%
waveparam_test(:,:,1) = [xyn_lh(:,blist_lh),xyn_ec(:,blist_ec)];%RF resonance harmonic     
waveparam_test(:,:,2) = [xyomega_lh(:,blist_lh),xyomega_ec(:,blist_ec)];%RF wave frequency
waveparam_test(:,:,3) = xywce_out;%Midplane cyclotron frequency (r,theta=0) at the radial position considered 
waveparam_test(:,:,4) = [xyopt_lh(:,blist_lh),xyopt_ec(:,blist_ec)];%Options for Larmor radius effects and/or LH calc. 
waveparam_test(:,:,5) = xythetab;%Poloidal location of RF beam (relevant for bounce_mode > 0 only)    
waveparam_test(:,:,6) = [xyD0_lh_ref(:,blist_lh),xyD0_ec_ref(:,blist_ec)];%RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
waveparam_test(:,:,7) = [xynparmin_lh(:,blist_lh),xynparmin_ec(:,blist_ec)];%Square N// spectrum: Lower limit
waveparam_test(:,:,8) = [xynparmax_lh(:,blist_lh),xynparmax_ec(:,blist_ec)];%Square N// spectrum: Upper limit
waveparam_test(:,:,9) = [xynpar_lh(:,blist_lh),xynpar_ec(:,blist_ec)];%Gaussian N// spectrum: peak n//
waveparam_test(:,:,10) = [xydnpar_lh(:,blist_lh),xydnpar_ec(:,blist_ec)];%Gaussian N// spectrum: width in n//
waveparam_test(:,:,11) = [xynperp_lh(:,blist_lh),xynperp_ec(:,blist_ec)];%RF wave : n_perp
waveparam_test(:,:,12) = [xyepolp_lh(:,blist_lh),xyepolp_ec(:,blist_ec)];%RF wave : polarization plus
waveparam_test(:,:,13) = [xyepolm_lh(:,blist_lh),xyepolm_ec(:,blist_ec)];%RF wave : polarization minus
waveparam_test(:,:,14) = [xyepolz_lh(:,blist_lh),xyepolz_ec(:,blist_ec)];%RF wave : polarization parallel
%
% Case of Cold Plasma LHCD
%
xyn_lhc = ones(nr,1)*yn_lhc;%RF resonance harmonic (zero for LH) [1,n_scenario_lhc]
xythetab_lhc = ones(nr,1)*ythetab_lhc;%poloidal location of LH beam [rad]
ns_lhc = size(xyn_lhc,2);%number of LH scenarios stored in this file
%    
xyvparmin_lhc = ones(nr,1)*yvparmin_lhc;
xyvparmax_lhc = ones(nr,1)*yvparmax_lhc;
xynparmin_lhc = ones(nr,1)*ynparmin_lhc ;
xynparmax_lhc = ones(nr,1)*ynparmax_lhc;
xynpar_lhc = ones(nr,1)*ynpar_lhc;
xydnpar_lhc = ones(nr,1)*ydnpar_lhc;
%
xyrbetath_lhc = repmat(xrbetath,[1,ns_lhc]);
xyvparmin_lhc_ref = xyvparmin_lhc.*xyrbetath_lhc;%Normalization when norm_ref = 0
xyvparmax_lhc_ref = xyvparmax_lhc.*xyrbetath_lhc;%Normalization when norm_ref = 0
%
mask_vlims = ~isnan(xyvparmin_lhc_ref);
xynparmin_lhc(mask_vlims) = 1./xyvparmax_lhc_ref(mask_vlims)/betath_ref;%Conversion from vpar representation to npar one (if yvparmax_lh not a NaN)
xynparmax_lhc(mask_vlims) = 1./xyvparmin_lhc_ref(mask_vlims)/betath_ref;%Conversion from vpar representation to npar one (if yvparmin_lh not a NaN)
%
xyomega_lhc = ones(nr,1)*yomega_lhc;%LH wave frequency (GHz) (Not relevant when opt_lhc > 0)
%
xyPinc_lhc = ones(nr,1)*yPinc_lhc;%central LH incident power (W)
xyP0_lhc_prof = ones(nr,1)*yP0_lhc_prof;%Power radial profile: (0) uniform , (1) gaussian radial profile [1,1]
xypeak_lhc = ones(nr,1)*ypeak_lhc;%Radial peak position of the LH quasi-linear diffusion coefficient (r/a) [1,1]
xywidth_lhc = ones(nr,1)*ywidth_lhc;%Radial width of the LH quasi-linear diffusion coefficient (r/a) [1,1]
%
% Case of Gaussian radial deposition profile
%
xyrho_lhc = repmat(xrho,[1,ns_lhc]);
mask_p0_lhc = (xyP0_lhc_prof == 1);
xyPinc_lhc_gauss = xyPinc_lhc.*exp(-(xyrho_lhc - xypeak_lhc).^2./(xywidth_lhc/2/sqrt(log(2)))^2);
%
xyPinc_lhc(mask_p0_lhc) = xyPinc_lhc_gauss(mask_p0_lhc);
%
%Option parameter for cross-comparison between old LH code: 
%	- (0): Exact calculation
%	- (1): no LRE effect for LH and 1/vpar dependence
%	- (2): no LRE effect for LH, no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
xyopt_lhc = ones(nr,1)*yopt_lhc; 
%
xyideal_lhc = ones(nr,1)*yideal_lhc; %(0): cold dispersion model, (1): ideal case
xyfinc_lhc = ones(nr,1)*yfinc_lhc;% incidence factor. In the limit of infinitely thin flux-surface, yfinc_ecc = 1/cos(alpha)
%                                                       where alpha is the incidence angle of the ray on the surface 
%    
xyB0_lhc = repmat(xB0,[1,ns_lhc]); 
% cold plasma dispersion tensor solver
waveparam_0_lhc = coldlhcd_dke_jd(xyrho_lhc,xythetab_lhc,xyn_lhc,xyopt_lhc,xynparmin_lhc,xynparmax_lhc,xynpar_lhc,xydnpar_lhc,xyomega_lhc,xyPinc_lhc,xyfinc_lhc,Te_ref,ne_ref,xne_norm,zxni_norm,Zi,mi,xyB0_lhc,Rp,ap,bounce_mode);
% idealized polarization and spectrum
waveparam_1_lhc = ideallhcd_dke_jd(xyrho_lhc,xythetab_lhc,xyn_lhc,xyopt_lhc,xynparmin_lhc,xynparmax_lhc,xynpar_lhc,xydnpar_lhc,xyomega_lhc,xyPinc_lhc,xyfinc_lhc,Te_ref,ne_ref,xne_norm,zxni_norm,Zi,mi,xyB0_lhc,Rp,ap,bounce_mode);
%
xy14ideal_lhc = repmat(xyideal_lhc,[1,1,14]);
waveparam_lhc = xy14ideal_lhc.*waveparam_1_lhc + ~xy14ideal_lhc.*waveparam_0_lhc;
%
% Case of Cold Plasma ECCD
%
xyn_ecc = ones(nr,1)*yn_ecc;%EC resonance harmonic
xythetab_ecc = ones(nr,1)*ythetab_ecc;%poloidal location of EC beam [rad]
ns_ecc = size(xyn_ecc,2);%number of EC scenarios stored in this file
xypol_ecc = ones(nr,1)*ypol_ecc;%polarization, (0): O-Mode, (1):X-Mode
%    
xynpar_ecc = ones(nr,1)*ynpar_ecc;%EC wave Gaussian N// Spectrum: peak n//
xydnpar_ecc = ones(nr,1)*ydnpar_ecc;%EC wave Gaussian N// Spectrum: width in n//
xybwidth_ecc = ones(nr,1)*ybwidth_ecc;%EC wave Gaussian width. Used when xydnpar_ecc == NaN
xyY_ecc = ones(nr,1)*yY_ecc;%EC wave frequency [rad/s]
xyomega_ecc = ones(nr,1)*yomega_ecc;%EC wave frequency [rad/s]
%
xyPinc_ecc = ones(nr,1)*yPinc_ecc;%central EC incident power (W)
%
xyopt_ecc = ones(nr,1)*yopt_ecc; %(0): exact, (1): small LRE
xyideal_ecc = ones(nr,1)*yideal_ecc; %(0):  warm plasma dispersion model, (1): cold plasma dispersion model, (2): ideal case
xyfinc_ecc = ones(nr,1)*yfinc_ecc;
%
xyia_ecc = repmat(xia,[1,ns_ecc]);
xypsib_ecc = (1+xyia_ecc)./(1+xyia_ecc.*cos(xythetab_ecc));
xywce0_ecc = repmat(xwce0,[1,ns_ecc]);
mask_y_ecc = ~isnan(xyY_ecc);
xyomega_ecc(mask_y_ecc) = xyn_ecc(mask_y_ecc).*xywce0_ecc(mask_y_ecc).*xypsib_ecc(mask_y_ecc)./xyY_ecc(mask_y_ecc);
%    
xyrho_ecc = repmat(xrho,[1,ns_ecc]);
%    
xyB0_ecc = repmat(xB0,[1,ns_ecc]); 
% warm plasma dispersion tensor solver
if min(xyideal_ecc(:,blist_ecc)) == 0
	waveparam_0_ecc = warmeccd_dke_jd(tokname,xyrho_ecc,xythetab_ecc,xyn_ecc,xyopt_ecc,xynpar_ecc,xydnpar_ecc,xybwidth_ecc,xypol_ecc,xyomega_ecc,xyPinc_ecc,xyfinc_ecc,Te_ref,ne_ref,xne_norm,zxni_norm,Zi,mi,xyB0_ecc,Rp,ap,bounce_mode);
else
	waveparam_0_ecc = zeros(nr,ns_ecc,14);
end
% cold plasma dispersion tensor solver
waveparam_1_ecc = coldeccd_dke_jd(xyrho_ecc,xythetab_ecc,xyn_ecc,xyopt_ecc,xynpar_ecc,xydnpar_ecc,xybwidth_ecc,xypol_ecc,xyomega_ecc,xyPinc_ecc,xyfinc_ecc,Te_ref,ne_ref,xne_norm,zxni_norm,Zi,mi,xyB0_ecc,Rp,ap,bounce_mode);
% idealized polarization and spectrum
waveparam_2_ecc = idealeccd_dke_jd(xyrho_ecc,xythetab_ecc,xyn_ecc,xyopt_ecc,xynpar_ecc,xydnpar_ecc,xybwidth_ecc,xypol_ecc,xyomega_ecc,xyPinc_ecc,xyfinc_ecc,Te_ref,ne_ref,xyB0_ecc,Rp,ap,bounce_mode);
%
xy14ideal_ecc = repmat(xyideal_ecc,[1,1,14]);
%waveparam_ecc = (xy14ideal_ecc == 0).*waveparam_0_ecc + (xy14ideal_ecc == 1).*waveparam_1_ecc + (xy14ideal_ecc == 2).*waveparam_2_ecc;
waveparam_ecc = (xy14ideal_ecc == 1).*waveparam_1_ecc + (xy14ideal_ecc == 2).*waveparam_2_ecc;
%
% Case of local EBW
%
xyn_ebw = ones(nr,1)*yn_ebw;%EBW resonance harmonic
xythetab_ebw = ones(nr,1)*ythetab_ebw;%poloidal location of EBW beam [rad]
ns_ebw = size(xyn_ebw,2);%number of EBW scenarios stored in this file
xypol_ebw = ones(nr,ns_ebw)*[0];% not effective for EBW
%    
xynpar_ebw = ones(nr,1)*ynpar_ebw;%EBW wave Gaussian N// Spectrum: peak n//
xydnpar_ebw = ones(nr,1)*ydnpar_ebw;%EBW wave Gaussian N// Spectrum: width in n//
xybwidth_ebw = ones(nr,1)*ybwidth_ebw;%EBW wave Gaussian width. Used when xydnpar_ebw == NaN
xyY_ebw = ones(nr,1)*yY_ebw;%EBW wave frequency shift n.omega_ce/omega_rf
xyomega_ebw = ones(nr,1)*yomega_ebw;%EBW wave frequency [rad/s]
%
xyPinc_ebw = ones(nr,1)*yPinc_ebw;%central EBW incident power (W)
%
xyopt_ebw = ones(nr,1)*yopt_ebw; %(0): exact, (1): small LRE
xyideal_ebw = ones(nr,ns_ebw)*[0]; % not effective for EBW
xyfinc_ebw = ones(nr,1)*yfinc_ebw;
%
xyia_ebw = repmat(xia,[1,ns_ebw]);
xypsib_ebw = (1+xyia_ebw)./(1+xyia_ebw.*cos(xythetab_ebw));
xywce0_ebw = repmat(xwce0,[1,ns_ebw]);
mask_y_ebw = ~isnan(xyY_ebw);
xyomega_ebw(mask_y_ebw) = xyn_ebw(mask_y_ebw).*xywce0_ebw(mask_y_ebw).*xypsib_ebw(mask_y_ebw)./xyY_ebw(mask_y_ebw);
%    
xyrho_ebw = repmat(xrho,[1,ns_ebw]);
%    
xyB0_ebw = repmat(xB0,[1,ns_ebw]); 
% dispersion tensor solver
if nb_ebw > 0
	waveparam_ebw = ebw_dke_jd(tokname,xyrho_ebw,xythetab_ebw,xyn_ebw,xyopt_ebw,xynpar_ebw,xydnpar_ebw,xybwidth_ebw,xypol_ebw,xyomega_ebw,xyPinc_ebw,xyfinc_ebw,Te_ref,ne_ref,xne_norm,zxni_norm,Zi,mi,xyB0_ebw,Rp,ap,bounce_mode);
else
	waveparam_ebw = zeros(nr,0,14);
end
%
% Generates Waveparam
% 
nb = nb_ecc + nb_lhc + nb_ebw + nb_test;
%
waveparam = zeros(nr,nb,14);
%
waveparam(:,1:nb_ecc,:) = waveparam_ecc(:,blist_ecc,:);
waveparam(:,(nb_ecc+1):(nb_ecc+nb_lhc),:) = waveparam_lhc(:,blist_lhc,:);
waveparam(:,(nb_ecc+nb_lhc+1):(nb_ecc+nb_lhc+nb_ebw),:) = waveparam_ebw(:,blist_ebw,:);
waveparam(:,(nb_ecc+nb_lhc+nb_ebw+1):nb,:) = waveparam_test;
