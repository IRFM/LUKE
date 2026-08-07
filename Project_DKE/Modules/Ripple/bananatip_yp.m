% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function ripple = bananatip_yp(ntheta,psin,dpsin,pn,mhu,equil,XXf0,pn2dpn,mksa)
%LUKE -  calculate the electron distribution function at the banana tip for magnetic ripple losses
%
% Calculation the electron distribution function at the banana tip for magnetic ripple losses. 
% Upper or lower part of the plasma is chosen depending upon the vertical drift direction of the electrons.  
%
%   INPUTS:
%   
%       - ntheta: number of poloidal positions where the banan tips are calculated
%       - psin: normalized magnetic flux surfaces (given by LUKE) [1,npsi]
%       - pn: normalized momentum grid (given by LUKE) 
%       - mhu: pitch-angle grid (given by LUKE) 
%       - equil: toroidal MHD equilibrium structure (given by LUKE) 
%       - XXf0 : 3-D electron distribution function solution of the Fokker-Planck equation (given by LUKE) 
%       - mksa : MKSA data structure (given by LUKE)   
%       
%   OUTPUTS:
%   
%      - ripple:  output structure 
%            ripple.psin_tip: normalized magnetic flux surface label where the density banana tips are calculated (0 at the plasma center, 1 at the separatrix)
%            ripple.rho_tip: normalized minor radius where the density banana tips are calculated (0 at the plasma center, 1 at the separatrix)
%            ripple.theta_tip: poloidal angle where the density banana tips are calculated
%            ripple.Ec_tip: kinetic energies at the banana tips  [keV]
%            ripple.pn_tip: normalized momentum values at the banana tip (p/pth)
%            ripple.mhu_tip: pitch-angle at Bmin corresponding to the banana tip
%            ripple.XXf0_tip: Normalized electron distribution function of banana tips to ne_ref
%            ripple.R_tip: Major radius where the density banana tips are calculated
%            ripple.Z_tip: Vertical position where the density banana tips are calculated
%            ripple.ne_ref: reference density for XXf0_tip (m-3) 
%            ripple.Te_ref: reference temperature for XXf0_tip (keV) 
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 7,error('Error: wrong number of input arguments in bananatip_yp.m');end
%
if isfield(equil,'equil_fit'),
    equil_fit = equil.equil_fit;
else
    fitparam.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
    fitparam.nharm = NaN;%Number of harmonics in the magnetic equilibrium interpolation (NaN, Inf or empty, nharm = ntheta-1)
    fitparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
    fitparam.method = 'spline';%nearest,spline,pchip
    %
    equil_fit = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);%Build vectorized magnetic equilibrium structure
    %
    disp('----> Vectorization of the toroidal MHD equilibrium done.');
end 
%
method = 'spline';
n_gauleg = 35;%Number of Legendre polynomials for projections of the electron velocity distribution
n_pol = n_gauleg;%Necessary for accurate reconstruction at ksi = -1
epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
%
[x_leg,w_leg] = gauleg_dke_yp(n_gauleg,epsi_gauleg);%Gauss-Legendre abscissa and weigth calculations between -1 and + 1
[Pm,cL] = leg_dke_yp(x_leg(:)',n_pol);%Legendre polynomial calculation
%
XXf0_c = zeros(size(XXf0,1),n_gauleg+1,size(XXf0,3));
%
for ir = 1:size(XXf0,3),%radial position
    Xf0 = XXf0(:,:,ir);%Non-thermal distribution function at poloidal location
    Xf0_i = interp1(mhu,Xf0',x_leg(:),method)';%Interpolation of the distribution function on the Legendre polynomial pitch-angle grid
    Xf0_c = (Xf0_i.*(w_leg*ones(1,size(Xf0_i,1)))')*Pm';%Calculation of the Legendre coefficients for local values of the distribution function
    %Xf0_i1 = (Pm'*(Xf0_c.*(ones(size(Xf0_i,1),1)*cL'))')';%Distribution function on the Legendre polynomials pitch-angle grid back calculated
    %epsif0 = (Xf0_i-Xf0_i1)./Xf0_i;epsif0(isnan(epsif0)==1)=0;
    XXf0_c(:,:,ir) = Xf0_c;        
end
%
disp('----> Projection of the electron distribution function at Bmin on the Legendre polynomial basis done.');
%
[~,~,~,~,~,~,~,mc2,~,~] = pc_dke_yp;%Universal physics constants
%
theta = linspace(0,2*pi,ntheta);%uniform poloidal angle grid grid
dtheta = theta(2) - theta(1);
%
ripple.psin_tip = psin;%Fokker-Planck psi grid
%
ripple.rho_tip = psi2rho_jd(equil,ripple.psin_tip);%Fokker-Planck rho grid
ripple.theta_tip = theta;%poloidal angle value at which the banana tip is located
%
ripple.Ec_tip = mc2*(sqrt(1 + pn.*pn*mksa.betath_ref^2) - 1);%Fast electron kinetic energy in keV at the banana tip;
ripple.pn_tip = pn;
%
ripple.mhu_tip = zeros(size(XXf0,3),ntheta);
%
ripple.XXf0_tip = zeros(size(XXf0,1),ntheta,size(XXf0,3));%at the banana tip
%
Xpn2dpn = pn2dpn(:)*ones(1,ntheta);
%
for ir = 1:length(ripple.rho_tip),
    %
    x_a0 = ppval(equil_fit.x_fit.pp_a0,ripple.rho_tip(ir));
    x_an = ppval(equil_fit.x_fit.pp_an,ripple.rho_tip(ir));
    x_bn = ppval(equil_fit.x_fit.pp_bn,ripple.rho_tip(ir));
    %
    y_a0 = ppval(equil_fit.y_fit.pp_a0,ripple.rho_tip(ir));
    y_an = ppval(equil_fit.y_fit.pp_an,ripple.rho_tip(ir));
    y_bn = ppval(equil_fit.y_fit.pp_bn,ripple.rho_tip(ir));
    %
    ripple.R_tip(:,ir) = calcval_yp(equil_fit,ripple.theta_tip,x_a0,x_an,x_bn)' + equil.Rp;
    ripple.Z_tip(:,ir) = calcval_yp(equil_fit,ripple.theta_tip,y_a0,y_an,y_bn)' + equil.Zp;
    %
    B_a0 = ppval(equil_fit.B_fit.pp_a0,ripple.rho_tip(ir));
    B_an = ppval(equil_fit.B_fit.pp_an,ripple.rho_tip(ir));
    B_bn = ppval(equil_fit.B_fit.pp_bn,ripple.rho_tip(ir));
    %
    BP_a0 = ppval(equil_fit.BP_fit.pp_a0,ripple.rho_tip(ir));
    BP_an = ppval(equil_fit.BP_fit.pp_an,ripple.rho_tip(ir));
    BP_bn = ppval(equil_fit.BP_fit.pp_bn,ripple.rho_tip(ir));
    %
    r_a0 = ppval(equil_fit.r_fit.pp_a0,ripple.rho_tip(ir));
    r_an = ppval(equil_fit.r_fit.pp_an,ripple.rho_tip(ir));
    r_bn = ppval(equil_fit.r_fit.pp_bn,ripple.rho_tip(ir));
    %
    calpha_a0 = ppval(equil_fit.calpha_fit.pp_a0,ripple.rho_tip(ir));
    calpha_an = ppval(equil_fit.calpha_fit.pp_an,ripple.rho_tip(ir));
    calpha_bn = ppval(equil_fit.calpha_fit.pp_bn,ripple.rho_tip(ir));
    %
    B_tip = calcval_yp(equil_fit,ripple.theta_tip,B_a0,B_an,B_bn);
    Bmin = calcval_yp(equil_fit,0,B_a0,B_an,B_bn);
    BP_tip = calcval_yp(equil_fit,ripple.theta_tip,BP_a0,BP_an,BP_bn);
    r_tip = calcval_yp(equil_fit,ripple.theta_tip,r_a0,r_an,r_bn);
    calpha_tip = calcval_yp(equil_fit,ripple.theta_tip,calpha_a0,calpha_an,calpha_bn);
    %
    ripple.mhu_tip(ir,:) = sqrt(1 - Bmin./B_tip);%pitch-angle value at Bmin which corresponds to the poloidal angle value at which the banana tip is located
    %
    [Pm,cL] = leg_dke_yp(ripple.mhu_tip(ir,:),n_pol);%Value of the Legendre polynomial on the mhu_tip grid 
    %
    ripple.XXf0_tip(:,:,ir) = (Pm'*(XXf0_c(:,:,ir).*(ones(size(XXf0,1),1)*cL'))')';%the distribution of electron banana tips on the grid
    %
    XJ_tip = ones(size(Xpn2dpn,1),1)*abs(r_tip./BP_tip./calpha_tip)';
    %
    ripple.DNeDphi_tip(:,:,ir) = 4*pi*mksa.ne_ref*XJ_tip.*ripple.XXf0_tip(:,:,ir).*Xpn2dpn*dpsin(ir)*dtheta;%the incremental density of electron banana tips on the grid
    %
end
%
ripple.ne_ref = mksa.ne_ref;
ripple.Te_ref = mksa.Te_ref;
%
