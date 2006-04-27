function [xyY_rf,xyomega_rf,xynpar_rf,xydnpar_rf,xynparmin_rf,xynparmax_rf,xyP0_in_rf,xyfinc_rf,xythetab_rf,xyopt_rf,xyepolc_rf,xyn_rf,xyprop_dke_rf,yb_rf]...
            = straightray_jd(tokamak,xpsin,xpsin_dke,xdpsin_dke,xpsin_S_dke,r_dke,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,dke_mode,method);
%
% This function calculates straight ray caracteristics. 
% These rays are a good approximation for RF waves in 
% the limit where the wave frequency is much higher than the plasma frequency, 
% so that the wave exhibits essentially free-space caracteristics. In other
% words, the wave refraction is neglected.
%
% The launching parameters are determined in psim_straightray_jd.m
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 16
    method = 'spline';
end
%
[blist_rf,yomega_rf,ydnpar_rf,ywaist_rf,yP0_L,yalpha_L,ybeta_L,ytheta_L,yR_L,yZ_L,yopt_rf,yepolc_rf,nsmin]...
    = psim_straightray_jd; %launching parameters
%
nr = length(xpsin);
nr_dke = length(xpsin_dke);
if nr_dke < 3
    error('Need at least 3 DKE calculation points for coupling with RT calculations')
end
nb_rf = length(blist_rf);
if nb_rf == 0, 
    blist_rf=ones(1,nb_rf); %for correct empty matrix size management
end
%
ytest_maskdnpar_rf =  ~isnan(ydnpar_rf(blist_rf));
ytest_maskwaist_rf =  ~isnan(ywaist_rf(blist_rf));
ytest_width_rf = ytest_maskdnpar_rf + ytest_maskwaist_rf;
if ytest_width_rf ~= ones(1,nb_rf)
    error('RF beam width inputs not compatible')
end
%
ytest_masktheta_L =  ~isnan(ytheta_L(blist_rf));
ytest_yRZ_L =  ~isnan(yR_L(blist_rf)) & ~isnan(yZ_L(blist_rf));
ytest_launch_rf = ytest_masktheta_L + ytest_yRZ_L;
if ytest_launch_rf ~= ones(1,nb_rf)
    error('RF launching inputs not compatible')
end
%
yomega_rf = yomega_rf(blist_rf)*2*pi*1e9;%(Hz -> rad/s)
ydnpar_rf = ydnpar_rf(blist_rf);
ywaist_rf = ywaist_rf(blist_rf);
yP0_L = yP0_L(blist_rf)*1e6;%(MW -> W)
yalpha_L = yalpha_L(blist_rf)*pi/180;%(deg -> rad)
ybeta_L = ybeta_L(blist_rf)*pi/180;%(deg -> rad)
ytheta_L = ytheta_L(blist_rf)*pi/180;%(deg -> rad)
yR_L = yR_L(blist_rf);
yZ_L = yZ_L(blist_rf);
yopt_rf = yopt_rf(blist_rf); 
yepolc_rf = yepolc_rf(blist_rf); 
%
% Magnetic geometry parameters on the flux radial grid
%
[theta_S_dke,xpsin_S_dke,psia,XR_S_dke,XZ_S_dke,XBR_S_dke,XBZ_S_dke,XBphi_S_dke] = equilibrium_jd(tokamak,xpsin_S_dke);
%
if sum(ytest_masktheta_L) > 0
    % plasma edge is at psia = xpsin_S_dke(nr_dke + 1)
    [ytB_L,ytBP_L,ytr_L,ytR_L,ytZ_L] = ...
        mg_interp_jd(theta_S_dke,XR_S_dke(nr_dke + 1,:),XZ_S_dke(nr_dke + 1,:),XBR_S_dke(nr_dke + 1,:),XBZ_S_dke(nr_dke + 1,:),XBphi_S_dke(nr_dke + 1,:),Rp,Zp,ytheta_L(:,ytest_masktheta_L),method);
    yR_L(:,ytest_masktheta_L) = ytR_L;
    yZ_L(:,ytest_masktheta_L) = ytZ_L;    
end
%
drmin = min(min(sqrt(diff(XR_S_dke).^2 + diff(XZ_S_dke).^2))); %close to lower bound on FS width
ds = drmin/nsmin; %increment along ray path (m)
smax = max(sqrt(XR_S_dke(nr_dke,:).^2 + XZ_S_dke(nr_dke,:).^2)); %tokamak diagonal size (I removed the 2*)
%
for ib = 1:nb_rf
    [s,sh,sZ,R,Z,phi,alpha,beta,gR,gZ,gphi] = raypath_prop_jd(yR_L(ib),yZ_L(ib),yalpha_L(ib),ybeta_L(ib),ds,smax);
%   
    vsray = zeros(11,length(s));
    vsray(1,:) = s;
    vsray(2,:) = R;
    vsray(3,:) = Z;
    vsray(4,:) = sh;
    vsray(5,:) = sZ;
    vsray(6,:) = phi;
    vsray(7,:) = alpha;
    vsray(8,:) = beta;
    vsray(9,:) = gR;
    vsray(10,:) = gZ;
    vsray(11,:) = gphi;
%
    vsrays{ib} = vsray;
end
%
% Coupling from RT code to DKE code
%
[xyvray_dke,xythetab_rf_dke,xyfinc_rf_dke,xyprop_dke_rf,yb] = propagation_jd(tokamak,vsrays,xpsin_dke,xdpsin_dke,xpsin_S_dke,method);
%
nb_rf = size(yb,2);%number of actual rays
nbb_rf = size(xyvray_dke,2);%number of ray subdivisions
%
xygR_dke = xyvray_dke(:,:,9);
xygZ_dke = xyvray_dke(:,:,10);
xygphi_dke = xyvray_dke(:,:,11);
%
[xyBb_rf_dke,xyBPb_rf_dke,xyrb_rf_dke,xyRb_rf_dke,xyZb_rf_dke,xyBRb_rf_dke,xyBZb_rf_dke,xyBphib_rf_dke] = ...
    mg_interp_jd(theta,XR(r_dke,:),XZ(r_dke,:),XBR(r_dke,:),XBZ(r_dke,:),XBphi(r_dke,:),Rp,Zp,xythetab_rf_dke,method);
%
% Parallel index of refraction
%
xygB_dke = (xygR_dke.*xyBRb_rf_dke + xygZ_dke.*xyBZb_rf_dke + xygphi_dke.*xyBphib_rf_dke)./xyBb_rf_dke;%projection of the ray on the magnetic field line
xynpar_rf_dke = xygB_dke;%in the approximation wpe << w              
%
xynparmin_rf = NaN*ones(nr,nbb_rf);
xynparmax_rf = NaN*ones(nr,nbb_rf);
xyY_rf = NaN*ones(nr,nbb_rf);
%
xyomega_rf = zeros(nr,nbb_rf);
xynpar_rf = zeros(nr,nbb_rf);
xydnpar_rf = zeros(nr,nbb_rf);
xywaist_rf = zeros(nr,nbb_rf);
xyP0_in_rf = zeros(nr,nbb_rf);
xyfinc_rf = zeros(nr,nbb_rf);
xythetab_rf = zeros(nr,nbb_rf);
xyopt_rf = zeros(nr,nbb_rf);
xyepolc_rf = zeros(nr,nbb_rf);
xyn_rf = zeros(nr,nbb_rf);
%
for ibb = 1:nbb_rf
    ib_rf(ibb) = max(find(yb(1,:) <= ibb));%new ray number
end
ib_rf_old = yb(2,ib_rf);%old ray number (may be different if some rays did not enter the plasma)
%
% parameters that do not vary along the ray
%
xyomega_rf = ones(nr,1)*yomega_rf(ib_rf_old);% wave frequency
xyopt_rf = ones(nr,1)*yopt_rf(ib_rf_old);% FLR option
xyepolc_rf = ones(nr,1)*yepolc_rf(ib_rf_old);% polarization
xydnpar_rf = ones(nr,1)*ydnpar_rf(ib_rf_old);% spectrum width
xywaist_rf = ones(nr,1)*ywaist_rf(ib_rf_old);% beam waist
xytest_maskwaist_rf = logical(ones(nr,1)*ytest_maskwaist_rf(ib_rf_old));% beam waist mask
%
% parameters that vary along the ray and are calculated for dke positions only
% for positions that are not visited by the ray, we set xyP0_in_rf = 0
%
xymask_prop_dke = xyprop_dke_rf ~= 0;%DKE points visited by the ray
if dke_mode == 1 % interpolation for the FP positions (only necessary if dke_mode == 1)
    for ibb = 1:nbb_rf
        xmask_prop_fp = [(min(r_dke(xymask_prop_dke(:,ibb))) - 1):(max(r_dke(xymask_prop_dke(:,ibb))) + 1)];%corresponding FP points
%        
        xynpar_rf(xmask_prop_fp,ibb) = interp(xpsin_dke(xymask_prop_dke(:,ibb)),xynpar_rf_dke(xymask_prop_dke(:,ibb)),xpsin(xmask_prop_fp),method);
        xyfinc_rf(xmask_prop_fp,ibb) = interp(xpsin_dke(xymask_prop_dke(:,ibb)),xyfinc_rf_dke(xymask_prop_dke(:,ibb)),xpsin(xmask_prop_fp),method);
        xythetab_rf(xmask_prop_fp,ibb) = interp(xpsin_dke(xymask_prop_dke(:,ibb)),xythetab_rf_dke(xymask_prop_dke(:,ibb)),xpsin(xmask_prop_fp),method);
%
        xyP0_in_rf(xmask_prop_fp,ibb) = yP0_L(ib_rf_old(ibb));% initial incident power
    end
else
    xynpar_rf = xynpar_rf_dke;
    xyfinc_rf = xyfinc_rf_dke;
    xythetab_rf = xythetab_rf_dke;
    xyP0_in_rf = xymask_prop_dke.*(ones(nr,1)*yP0_L(ib_rf_old));% initial incident power
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
% relation between beam waist and spectrum width
%
xydnpar_rf(xytest_maskwaist_rf) = clum.*sqrt(1 - xynpar_rf(xytest_maskwaist_rf).^2)./xywaist_rf(xytest_maskwaist_rf)./xyomega_rf(xytest_maskwaist_rf);
%
% determination of the most relevant harmonic
%
[xyBb_rf] = mg_interp_jd(theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xythetab_rf,method);
%
xyomega_ce_b_rf = qe*xyBb_rf/me;
%
xyn_rf = ceil(sqrt(1 - (xynpar_rf + xydnpar_rf).^2).*xyomega_rf./xyomega_ce_b_rf);
%
yb_rf = yb(1,:);