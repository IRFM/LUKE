% *** TCV HARD X-RAY CONFIGURATION ***
% ************************************
% Create the local file HXR_hxr_TCV.mat
% 
%  by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
% and Joan Decker CEA-DRFC (joan.decker@cea.fr)
% and J. Kamleitner CRPP, EPFL
%
clear all
close all
hxr_id = 'TCV';%Set here the name (identifier) of the Hard X-ray configuration

%--------------------------------------------------------------------------
% HXRC: 19 chords: 1-19
%--------------------------------------------------------------------------

% define beta and alpha
beta_hxr_stefano = [NaN,NaN,NaN,NaN,183.3893,182.6976,...
    181.7569,180.8162,179.8755,178.9349,178.0000,177.0651,176.1245,...
    175.1838,174.2431,173.3024,172.3615,171.6614,NaN]/180*pi;

hxrc.beta_hxr = NaN(1,19);
hxrc.alpha_hxr = NaN(1,19);

hxrc.beta_hxr(beta_hxr_stefano <= pi) = beta_hxr_stefano(beta_hxr_stefano <= pi);
hxrc.alpha_hxr(beta_hxr_stefano <= pi) = 0;

% according to the correct definitions of alpha (-pi -> pi) and beta (0 -> pi)
hxrc.beta_hxr(beta_hxr_stefano > pi) = 2*pi - beta_hxr_stefano(beta_hxr_stefano > pi);
hxrc.alpha_hxr(beta_hxr_stefano > pi) = pi;

% define further parameters
hxrc.R_hxr = 1.048*ones(1,19);      % R [m] of a point on line of sight
hxrc.Z_hxr = -1.137*ones(1,19);     % Z [m] of a point on line of sight

hxrc.EG_hxr = [0,0,0,0,0.219,1.627,1.789,1.951,2.112,2.272,2.384,2.272,2.112,1.951,1.789,1.627,1.465,0.178,0]*1e-9;%geometrical extend (m^2) [1,nchord]
hxrc.kd_hxr = ones(19,1)*[10,30,50,70,90,110,130,150,170,190,210,250];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Reference energies for the photofraction [m,p]
hxrc.phf_hxr = ones(19,1)*[0.75,0.62,0.51,0.41,0.32,0.2,0.2,0.2,0.2,0.2,0.2,0.2];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p]
hxrc.res_hxr = ones(19,1)*[6,-0.9]; % fit parameters of the energy resolution of the detectors [m,2]
hxrc.ef_hxr = 0.25*ones(1,19);      % thickness of the vacuum window (mm) [1,m]
hxrc.tf_hxr = repmat('Be',19,1);    % type of material for the vacuum window (Al ou Be) [1,m]
% Air absoprtion is negligible as far as the photon energy is less than 10 keV, and the length is less than several meters (here air thickness is 57.64 cm)
hxrc.ea_hxr = zeros(1,19);          % thickness of the absorber (mm) [1,m] (WARNING: for 2 mm Cu: 2.83= 2*(29/26)^2*(dens_Cu/dens_Fe)  dens_Cu = 63.546, dens_Fe = 55.845)
hxrc.ta_hxr = repmat('Fe',19,1);    % type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]
hxrc.ec_hxr = 0.5*ones(1,19);       % thickness of the detector shield (mm) [1,m]
hxrc.tc_hxr = repmat('Al',19,1);    % type of material for the detector shield (Al,C ou Be) [1,m]
hxrc.ed_hxr = 2*ones(1,19);         % thickness of the detector (mm) [1,m]
hxrc.td_hxr = repmat('CdTe',19,1);  % type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]

%--------------------------------------------------------------------------
% HXRS: cams 5,2,4,7: 4*24 chords: 20-115
%--------------------------------------------------------------------------

cg=hxrs_getchords;

% data from hxrs_getchords
% focal point position
hxrs.R_hxr=cg.rd([cg.all.chords{cg.all.cams}]);
hxrs.Z_hxr=cg.zd([cg.all.chords{cg.all.cams}]);
% chord angles
hxrs.alpha_hxr=cg.alpha([cg.all.chords{cg.all.cams}]);
hxrs.beta_hxr=cg.beta([cg.all.chords{cg.all.cams}]);
% etendue data
hxrs.EG_hxr = cg.etendue([cg.all.chords{cg.all.cams}]);% etendue [1,nchord]

% keep data for HXRC detector for the moment
hxrs.kd_hxr = ones(96,1)*[10,30,50,70,90,110,130,150,170,190,210,250];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Reference energies for the photofraction [m,p]
hxrs.phf_hxr = ones(96,1)*[0.75,0.62,0.51,0.41,0.32,0.2,0.2,0.2,0.2,0.2,0.2,0.2];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p]
hxrs.res_hxr = ones(96,1)*[6,-0.9]; % fit parameters of the energy resolution of the detectors [m,2]

% Be window data from wiki, HXRS/Hardware
hxrs.ef_hxr = 0.127*ones(1,96);      % thickness of the vacuum window (mm) [1,m]
hxrs.tf_hxr = repmat('Be',96,1);    % type of material for the vacuum window (Al ou Be) [1,m]

% no absorber of detector shield
hxrs.ea_hxr = zeros(1,96);          % thickness of the absorber (mm) [1,m] (WARNING: for 2 mm Cu: 2.83= 2*(29/26)^2*(dens_Cu/dens_Fe)  dens_Cu = 63.546, dens_Fe = 55.845)
hxrs.ta_hxr = repmat('Fe',96,1);    % type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]
hxrs.ec_hxr = zeros(1,96);     % thickness of the detector shield (mm) [1,m]
hxrs.tc_hxr = repmat('Al',96,1);    % type of material for the detector shield (Al,C ou Be) [1,m]
hxrs.ed_hxr = 2*ones(1,96);         % thickness of the detector (mm) [1,m]
hxrs.td_hxr = repmat('CdTe',96,1);  % type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]


%--------------------------------------------------------------------------
% common data
%--------------------------------------------------------------------------

hxr.kdiag_hxr = [10:10:180,50 ;...
                 20:10:190,110];    % Measured photon energy spectrum (keV) [kmin1,kmin2,...,kmintphot,kmax1,kmax2,...,kmaxtphot] (here photon temp is calculated between 50 and 110 keV) [1,k]

hxr.kphot = [10:5:190];            % Photon energy in keV

hxrparam.mfactor = 1;%For the magnetic equilibrium
hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
hxrparam.ns = 3000;%for chord integration
hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection

%--------------------------------------------------------------------------
% merge and save data
%--------------------------------------------------------------------------

% get fields
hxrf=fields(hxrc);
% merge fields to hxr
for i=1:length(hxrf)
    if(size(hxrs.(hxrf{i}),1)==96 && size(hxrc.(hxrf{i}),1)==19)
        hxr.(hxrf{i})=[hxrc.(hxrf{i});hxrs.(hxrf{i})];
    elseif(size(hxrs.(hxrf{i}),2)==96 && size(hxrc.(hxrf{i}),2)==19)
        hxr.(hxrf{i})=[hxrc.(hxrf{i}),hxrs.(hxrf{i})];
    else
        error('dimensions of hxrs and hxrc do not correspond to each other or to the definition');
    end
end

% save data to the file
save(sprintf('HXR_%s.mat',hxr_id),'hxr','hxrparam');
