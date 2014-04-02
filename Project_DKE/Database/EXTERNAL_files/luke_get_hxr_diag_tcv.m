function [ hxr, hxrparam, ap ] = luke_get_hxr_diag_tcv( shot, cams, chords )
%LUKE_GET_HXR_DIAG_TCV [ hxr, hxrparam, ap ] = luke_get_hxr_diag_tcv( shot, cams, chords )
%   returns the HXR diagnostic configuration parameters required by LUKE
%   for a given TCV shot and (optional) the requested cameras and chords.
%   If a camera was not present for a shot a default configuration is
%   returned.
% INPUT:
%   shot ...... the TCV shot number
%   cams ...... the requested cameras. By default [1,5,2,7,4] with 1 being
%               the HXRC and [5,2,7,4] being the HXRS cameras according to
%               their numbering.
%   chords .... allows to select chords, by default all chords:
%               {5:18,1:24,[],1:24,1:24,[],1:24} of cams 1,2,4,5,7
%
%   J. Kamleitner, CRPP, EPFL, March 2014

if(nargin<2 || isempty(cams))
    cams=[1,5,2,7,4];
end
if(nargin<3 || isempty(chords))
    chords={5:18,1:24,[],1:24,1:24,[],1:24};
end

%--------------------------------------------------------------------------
% get all parameters and extract information required for LUKE
%--------------------------------------------------------------------------
ap=hxrs_getallpar(shot,cams,chords);

% data from hxrs_getchords

% focal point position
hxr.R_hxr=ap.cg.rd;
hxr.Z_hxr=ap.cg.zd;
% chord angles
hxr.alpha_hxr=ap.cg.alpha;
hxr.beta_hxr=ap.cg.beta;
% etendue data
hxr.EG_hxr = ap.cg.etendue;
% filter, window and absorber
hxr.ec_hxr = NaN(1,ap.nc);          % thickness of the detector shield (mm) [1,m]
hxr.tc_hxr = repmat('fm',ap.nc,1);  % type of material for the detector shield (Al,C ou Be) [m,2]
hxr.ef_hxr = NaN(1,ap.nc);          % thickness of the vacuum window (mm) [1,m]
hxr.tf_hxr = repmat('wm',ap.nc,1);  % type of material for the vacuum window (Al ou Be) [m,2]
hxr.ea_hxr = NaN(1,ap.nc);          % thickness of the absorber (mm) [1,m] (WARNING: for 2 mm Cu: 2.83= 2*(29/26)^2*(dens_Cu/dens_Fe)  dens_Cu = 63.546, dens_Fe = 55.845)
hxr.ta_hxr = repmat('am',ap.nc,1);  % type of material for the absorber (Al,Fe,Ge,Be ou Pb) [m,2]
hxr.ed_hxr = NaN(1,ap.nc);          % thickness of the detector (mm) [1,m]
hxr.td_hxr = repmat('detm',ap.nc,1);% type of material for the detector (BGO , CsI , NaI , Ge  , CdTe) [m,4]
for i=1:ap.nc
    hxr.ec_hxr(i)=ap.fch{i}.filt{1}.d;
    hxr.tc_hxr(i,:)=ap.fch{i}.filt{1}.mt;
    hxr.ef_hxr(i)=ap.fch{i}.win{1}.d;
    hxr.tf_hxr(i,:)=ap.fch{i}.win{1}.mt;
    hxr.ea_hxr(i)=ap.fch{i}.abs{1}.d;
    hxr.ta_hxr(i,:)=ap.fch{i}.abs{1}.mt;
    hxr.ed_hxr(i)=ap.det{i}.d;
    hxr.td_hxr(i,:)=ap.det{i}.mt;
end

%--------------------------------------------------------------------------
% additional information required for LUKE, not provided by hxrs_getallpar
%--------------------------------------------------------------------------

% keep data for HXRC detector for the moment
hxr.kd_hxr = ones(ap.nc,1)*[10,30,50,70,90,110,130,150,170,190,210,250];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Reference energies for the photofraction [m,p]
hxr.phf_hxr = ones(ap.nc,1)*[0.75,0.62,0.51,0.41,0.32,0.2,0.2,0.2,0.2,0.2,0.2,0.2];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p]
hxr.res_hxr = ones(ap.nc,1)*[6,-0.9]; % fit parameters of the energy resolution of the detectors [m,2]
% energy bin data
hxr.kdiag_hxr = [15:10:195,35 ;...
                 25:10:205,135];    % Measured photon energy spectrum (keV) [kmin1,kmin2,...,kmintphot,kmax1,kmax2,...,kmaxtphot] (here photon temp is calculated between 35 and 135 keV) [1,k]
hxr.kphot = [10:5:205];            % Photon energy in keV

%--------------------------------------------------------------------------
% hxrparam structure
%--------------------------------------------------------------------------

hxrparam.mfactor = 1;%For the magnetic equilibrium
hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
hxrparam.ns = 3000;%for chord integration
hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection


end

