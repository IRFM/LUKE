function [fluct] = fluctstruct_yp(equil,id,fluct_in)
%
% Calculates the fluctuations structure for C3PO
%
% INPUT
%    - equil: axisymmetric magnetic equilibrium structure
%    - id: fluct id 
%    - fluct_in: 
%       - naequilp: non axisymmetric perturbation of the toroidal MHD equilibrium (dynamic -> ne: density, B: magnetic field), or (static -> magnetic ripple)
%       - npar0_lh: perturbation of the launched npar for the LH wave only (simulate possible diffraction of the LH wave in the SOL by edge density fluctuations)
%
% OUTPUT:
%
%    - fluct: fluctuations or modulations output structure for C3PO
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin <= 2,
    fluct = [];
    warning('Not enough input arguments in fluctstruct_yp.m: fluctuation structure is empty.');
    return;
else
    if ~isfield(fluct_in,'naequilp') && ~isfield(fluct_in,'npar0_lh'),
        error('Unrecognized fluctuation types: naequilp or npar0_lh.');
    end
end
%
% Axisymmetric magnetic equilibrium
%
[equilDKE] = equilibrium_jd(equil,[],0,'linear',1);
%
[xq] = qfactors_dke_yp(1,equilDKE.Rp,equilDKE.ap,equilDKE.Xx,equilDKE.Xy,equilDKE.XBx,equilDKE.XBy,equilDKE.XBphi,equilDKE.xx0,equilDKE.xB0,equilDKE.xBT0,equilDKE.xBp0);%safety factor
if isnan(xq(1)), xq(1) = xq(2);end
%
dtheta = gradient(equilDKE.mtheta);
[dRdtheta,dRdrho] = gradient(equilDKE.Xx + equilDKE.Rp);%XR
dRdtheta = dRdtheta./(ones(length(equilDKE.xrho),1)*dtheta);
dRdrho = dRdrho./(equilDKE.xrho(:)*ones(1,length(dtheta)));
%
[dZdtheta,dZdrho] = gradient(equilDKE.Xy + equilDKE.Zp);%XZ
dZdtheta = dZdtheta./(ones(length(equilDKE.xrho),1)*dtheta);
dZdrho = dZdrho./(equilDKE.xrho(:)*ones(1,length(dtheta)));
%
XR = equilDKE.Xx + equilDKE.Rp;
Xr = sqrt(equilDKE.Xx.^2 + equilDKE.Xy.^2);
Xsalpha = (equilDKE.Xx.*dRdtheta + equilDKE.Xy.*dZdtheta)./Xr./sqrt(dRdtheta.^2 + dZdtheta.^2);
Xsalpha(1,:) = Xsalpha(2,:);
Xsalpha(end,:) = Xsalpha(end-1,:);
Xcalpha = sqrt(1.0 - Xsalpha.^2);
Xcalpha2 = Xcalpha.*Xcalpha;
%
sigmaIp =  sign(equil.psi_apRp(end));% Sign of the plasma current (only valid for tokamak, not for RFP !)
XBP = sqrt(equilDKE.XBx.^2 + equilDKE.XBy.^2);
XB = sqrt(equilDKE.XBx.^2 + equilDKE.XBy.^2 + equilDKE.XBphi.^2);
XP = sigmaIp*XBP./XB;
XP2 = XP.*XP;
XT = equilDKE.XBphi./XB;
XT2 = XT.*XT;
%
%Xrho = equilDKE.xrho(:)*ones(size(equilDKE.mtheta));
%Xtheta = ones(size(equilDKE.xrho(:)))*equilDKE.mtheta;
%
L_rho = equilDKE.ap;
xL_theta = sum(Xr./Xcalpha.*(ones(length(equilDKE.xrho),1)*dtheta),2);
xL_perp = sum(Xr./Xcalpha./abs(XT).*(ones(length(equilDKE.xrho),1)*dtheta),2)./xq(:);
XL_phi = 2*pi*(equilDKE.Xx + equilDKE.Rp);
%
% Build fluct structure for C3PO. One substructure for each fluctuation model
%
fluct.id = id;
fluct.equil_id = equil.id;
%
fluct.rho = equilDKE.xrho(:);
fluct.theta = equilDKE.mtheta;
fluct.phi = [];
%
fluct.xq = xq(:);
%
fluct.L_rho = L_rho;
fluct.xL_theta = xL_theta;
fluct.xL_perp = xL_perp;
fluct.XL_phi = XL_phi;
%
fluct.Xcm = Xr./sqrt(1.0 + (XP2./XT2).*Xcalpha2)/equilDKE.ap;%kpar = 0 fluctuation spectrum model
fluct.Xcm(:,end) = fluct.Xcm(:,1);%for spline-Fourier series expansion in the interpolation procedure
fluct.Xcn = -XR.*(XP./XT).*Xcalpha./sqrt(1.0 + (XP2./XT2).*Xcalpha2)/equilDKE.ap;%kpar = 0 fluctuation spectrum model
fluct.Xcn(:,end) = fluct.Xcn(:,1);%for spline-Fourier series expansion in the interpolation procedure
% 
if isfield(fluct_in,'naequilp'), 
    %
    inefluct_model = 1;
    iBfluct_model = 1;
    %
    if isfield(fluct_in.naequilp,'fluct'),
        for i = 1:length(fluct_in.naequilp.fluct.type),        
            if strcmp(fluct_in.naequilp.fluct.type{i},'ne'),
                fluct.ne(inefluct_model).model = fluct_in.naequilp.fluct.model(i);%fluctuation model
                %
                fluct.ne(inefluct_model).sigmar_max = fluct_in.naequilp.fluct.sigmar_max(i);%Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
                fluct.ne(inefluct_model).sigmar_hwhm = fluct_in.naequilp.fluct.sigmar_hwhm(i);%Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
                fluct.ne(inefluct_model).sigmar_rho = fluct_in.naequilp.fluct.sigmar_rho(i);%Radial location where the relative fluctuations variance peaks at the poloidal angle theta = 0 [1,nfluct_types]
                fluct.ne(inefluct_model).polmode = fluct_in.naequilp.fluct.polmode(i);%HFS/LFS relative fluctuations variance ratio. No poloidal dependency corresponds to 1 [1,nfluct_types]
                %
                fluct.ne(inefluct_model).epsi_rho = fluct_in.naequilp.fluct.epsi_rho(i);%
                fluct.ne(inefluct_model).epsi_theta = fluct_in.naequilp.fluct.epsi_theta(i);%
                fluct.ne(inefluct_model).epsi_phi = fluct_in.naequilp.fluct.epsi_phi(i);%
                %
                fluct.ne(inefluct_model).lmin = fluct_in.naequilp.fluct.lmin(i);%
                fluct.ne(inefluct_model).mmin = fluct_in.naequilp.fluct.mmin(i);%
                fluct.ne(inefluct_model).nmin = fluct_in.naequilp.fluct.nmin(i);%
                %
                fluct.ne(inefluct_model).lmax = fluct_in.naequilp.fluct.lmax(i);%
                fluct.ne(inefluct_model).mmax = fluct_in.naequilp.fluct.mmax(i);%
                fluct.ne(inefluct_model).nmax = fluct_in.naequilp.fluct.nmax(i);%
                %
                inefluct_model = inefluct_model + 1;
                %       
            elseif strcmp(fluct_in.naequilp.fluct.type{i},'B'),
                %
                fluct.B(iBfluct_model).model = fluct_in.naequilp.fluct.model(i);%fluctuation model
                %
                fluct.B(iBfluct_model).sigmar_max = fluct_in.naequilp.fluct.sigmar_max(i);%Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
                fluct.B(iBfluct_model).sigmar_hwhm = fluct_in.naequilp.fluct.sigmar_hwhm(i);%Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
                fluct.B(iBfluct_model).sigmar_rho = fluct_in.naequilp.fluct.sigmar_rho(i);%Radial location where the relative fluctuations variance peaks at the poloidal angle theta = 0 [1,nfluct_types]
                fluct.B(iBfluct_model).polmode = fluct_in.naequilp.fluct.polmode(i);%HFS/LFS relative fluctuations variance ratio. No poloidal dependency corresponds to 1 [1,nfluct_types]
                %
                fluct.B(iBfluct_model).epsi_rho = fluct_in.naequilp.fluct.epsi_rho(i);%
                fluct.B(iBfluct_model).epsi_theta = fluct_in.naequilp.fluct.epsi_theta(i);%
                fluct.B(iBfluct_model).epsi_phi = fluct_in.naequilp.fluct.epsi_phi(i);%
                %
                fluct.B(iBfluct_model).lmin = fluct_in.naequilp.fluct.lmin(i);%
                fluct.B(iBfluct_model).mmin= fluct_in.naequilp.fluct.mmin(i);%
                fluct.B(iBfluct_model).nmin = fluct_in.naequilp.fluct.nmin(i);%
                %
                fluct.B(iBfluct_model).lmax = fluct_in.naequilp.fluct.lmax(i);%
                fluct.B(iBfluct_model).mmax= fluct_in.naequilp.fluct.mmax(i);%
                fluct.B(iBfluct_model).nmax = fluct_in.naequilp.fluct.nmax(i);%
                %
                iBfluct_model = iBfluct_model + 1;
            end
        end
    end
    %
    % Magnetic ripple model
    %
    if isfield(fluct_in.naequilp,'ripple'), 
        %
        % B field terms
        %
        [aBx,aBy,aBz] = bripfield_yp(fluct_in.naequilp.ripple,equilDKE,3);%mode 3 for circular shaped windings cross-section
        B = sqrt(equilDKE.XBx.^2 + equilDKE.XBy.^2 + equilDKE.XBphi.^2);%
        %
        fluct.B(iBfluct_model).model = 0;%Magnetic ripple model
        %
        fluct.B(iBfluct_model).sigmar_max = [];
        fluct.B(iBfluct_model).sigmar_hwhm = [];
        fluct.B(iBfluct_model).sigmar_rho = [];
        fluct.B(iBfluct_model).polmode = [];
        %
        fluct.B(iBfluct_model).epsi_rho = [];
        fluct.B(iBfluct_model).epsi_theta = [];
        fluct.B(iBfluct_model).epsi_phi = [];
        %
        fluct.B(iBfluct_model).lmin = [];
        fluct.B(iBfluct_model).mmin= [];
        fluct.B(iBfluct_model).nmin = fluct_in.naequilp.ripple.N;%Number of toroidal magnetic field coils (one harmonic)
        %
        fluct.B(iBfluct_model).lmax = [];
        fluct.B(iBfluct_model).mmax= [];
        fluct.B(iBfluct_model).nmax = fluct_in.naequilp.ripple.N;%Number of toroidal magnetic field coils (one harmonic)
        %
        fluct.B(iBfluct_model).Xfx = aBx./B;
        fluct.B(iBfluct_model).Xfy = aBy./B;
        fluct.B(iBfluct_model).Xfz = aBz./B;%here z stand for phi the toroidal direction
        %    
        iBfluct_model = iBfluct_model + 1;
    end
end
%
% For the LH wave only
%
if isfield(fluct_in,'npar0_lh'), 
    if isfield(fluct_in.npar0_lh,'fluct'),
        fluct.npar0_lh.dtn = fluct_in.npar0_lh.fluct.dtn;
        fluct.npar0_lh.fwhm_npar0 = fluct_in.npar0_lh.fluct.fwhm_npar0;
        fluct.npar0_lh.h_npar0 = fluct_in.npar0_lh.fluct.h_npar0;
        fluct.npar0_lh.nparmax_npar0 = fluct_in.npar0_lh.fluct.nparmax_npar0;
    end
end