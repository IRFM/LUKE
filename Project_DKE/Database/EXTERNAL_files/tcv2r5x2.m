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
function hxrcam = tcv2r5x2(ap,icam)
%
% This function builds R5X2 type camera data from TCV ap structure
%
hxrcam.camnum = ap.cg.cams(icam);
hxrcam.id = ['TCV HXR camera # ',num2str(hxrcam.camnum)];
%
hxrcam.chordsnum = ap.cg.chords{hxrcam.camnum};
hxrcam.chordsind = ap.cg.chords_abs{hxrcam.camnum};
%
hxrcam.centralchord = ap.cg.cc{hxrcam.camnum};
%
nc = length(hxrcam.chordsind);
%
% focal point position
hxrcam.R_hxr=ap.cg.rd(hxrcam.chordsind);
hxrcam.Z_hxr=ap.cg.zd(hxrcam.chordsind);
% chord angles
hxrcam.alpha_hxr=ap.cg.alpha(hxrcam.chordsind);
hxrcam.beta_hxr=ap.cg.beta(hxrcam.chordsind);
% etendue data
hxrcam.EG_hxr = ap.cg.etendue(hxrcam.chordsind);

% keep data for HXRC detector for the moment
hxrcam.kd_hxr = ones(nc,1)*[10,30,50,70,90,110,130,150,170,190,210,250];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Reference energies for the photofraction [m,p]
hxrcam.phf_hxr = ones(nc,1)*[0.75,0.62,0.51,0.41,0.32,0.2,0.2,0.2,0.2,0.2,0.2,0.2];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p]
hxrcam.res_hxr = ones(nc,1)*[6,-0.9]; % fit parameters of the energy resolution of the detectors [m,2]

% filter, window and absorber
hxrcam.ec_hxr = NaN(1,nc);          % thickness of the detector shield (mm) [1,m]
hxrcam.tc_hxr = repmat('fm',nc,1);  % type of material for the detector shield (Al,C ou Be) [m,2]
hxrcam.ef_hxr = NaN(1,nc);          % thickness of the vacuum window (mm) [1,m]
hxrcam.tf_hxr = repmat('wm',nc,1);  % type of material for the vacuum window (Al ou Be) [m,2]
hxrcam.ea_hxr = NaN(1,nc);          % thickness of the absorber (mm) [1,m] (WARNING: for 2 mm Cu: 2.83= 2*(29/26)^2*(dens_Cu/dens_Fe)  dens_Cu = 63.546, dens_Fe = 55.845)
hxrcam.ta_hxr = repmat('am',nc,1);  % type of material for the absorber (Al,Fe,Ge,Be ou Pb) [m,2]
hxrcam.ed_hxr = NaN(1,nc);          % thickness of the detector (mm) [1,m]
hxrcam.td_hxr = repmat('detm',nc,1);% type of material for the detector (BGO , CsI , NaI , Ge  , CdTe) [m,4]
for ic = 1:nc
    hxrcam.ec_hxr(ic) = ap.fch{hxrcam.chordsind(ic)}.filt{1}.d;
    hxrcam.tc_hxr(ic,:) = ap.fch{hxrcam.chordsind(ic)}.filt{1}.mt;
    hxrcam.ef_hxr(ic) = ap.fch{hxrcam.chordsind(ic)}.win{1}.d;
    hxrcam.tf_hxr(ic,:) = ap.fch{hxrcam.chordsind(ic)}.win{1}.mt;
    hxrcam.ea_hxr(ic) = ap.fch{hxrcam.chordsind(ic)}.abs{1}.d;
    hxrcam.ta_hxr(ic,:) = ap.fch{hxrcam.chordsind(ic)}.abs{1}.mt;
    hxrcam.ed_hxr(ic) = ap.det{hxrcam.chordsind(ic)}.d;
    hxrcam.td_hxr(ic,:) = ap.det{hxrcam.chordsind(ic)}.mt;
end
