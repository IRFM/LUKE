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
function hxrspec = cam2hxrspec_jd(cam)
%
ncam = length(cam);
for icam = 1:ncam,
    cam{icam}.camindex = icam*ones(size(cam{icam}.chordsnum));
end
%
hxrspec = cell2mat_jd(cam,'chordsnum');
%
for icam = 1:ncam,
    hxrspec.ids{icam} = cam{icam}.id;
    hxrspec.centralchords{icam} = cam{icam}.centralchord;
    hxrspec.selectedchords{icam} = cam{icam}.selectedchord;
end

%
%            camnum: 1
%                id: 'TCV HXR camera # 1'
%         chordsnum: [5 6 7 8 9 10 11 12 13 14 15 16 17 18]
%         chordsind: [1 2 3 4 5 6 7 8 9 10 11 12 13 14]
%      centralchord: 16
%             R_hxr: [1.0480 1.0480 1.0480 1.0480 1.0480 1.0480 1.0480 1.0480 1.0480 1.0480 1.0480 1.0480 1.0480 1.0480]
%             Z_hxr: [-1.1370 -1.1370 -1.1370 -1.1370 -1.1370 -1.1370 -1.1370 -1.1370 -1.1370 -1.1370 -1.1370 -1.1370 -1.1370 -1.1370]
%         alpha_hxr: [3.1416 3.1416 3.1416 3.1416 0 0 0 0 0 0 0 0 0 0]
%          beta_hxr: [3.0824 3.0945 3.1109 3.1273 3.1394 3.1230 3.1067 3.0904 3.0740 3.0575 3.0411 3.0247 3.0083 2.9961]
%            EG_hxr: [1x14 double]
%            kd_hxr: [14x12 double]
%           phf_hxr: [14x12 double]
%           res_hxr: [14x2 double]
%            ec_hxr: [0.2000 0.2000 0.2000 0.2000 0.2000 0.2000 0.2000 0.2000 0.2000 0.2000 0.2000 0.2000 0.2000 0.2000]
%            tc_hxr: [14x2 char]
%            ef_hxr: [0.2500 0.2500 0.2500 0.2500 0.2500 0.2500 0.2500 0.2500 0.2500 0.2500 0.2500 0.2500 0.2500 0.2500]
%            tf_hxr: [14x2 char]
%            ea_hxr: [0 0 0 0 0 0 0 0 0 0 0 0 0 0]
%            ta_hxr: [14x2 char]
%            ed_hxr: [2 2 2 2 2 2 2 2 2 2 2 2 2 2]
%            td_hxr: [14x4 char]
%     selectedchord: 12
% 
% %
% % data from hxrs_getchords
% % focal point position
% hxrs.R_hxr=cg.rd([cg.chords_abs{cg.cams(2:end)}]);
% hxrs.Z_hxr=cg.zd([cg.chords_abs{cg.cams(2:end)}]);
% % chord angles
% hxrs.alpha_hxr=cg.alpha([cg.chords_abs{cg.cams(2:end)}]);
% hxrs.beta_hxr=cg.beta([cg.chords_abs{cg.cams(2:end)}]);
% % etendue data
% hxrs.EG_hxr = cg.etendue([cg.chords_abs{cg.cams(2:end)}]);% etendue [1,nchord]
% 
% % keep data for HXRC detector for the moment
% hxrs.kd_hxr = ones(96,1)*[10,30,50,70,90,110,130,150,170,190,210,250];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Reference energies for the photofraction [m,p]
% hxrs.phf_hxr = ones(96,1)*[0.75,0.62,0.51,0.41,0.32,0.2,0.2,0.2,0.2,0.2,0.2,0.2];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p]
% hxrs.res_hxr = ones(96,1)*[6,-0.9]; % fit parameters of the energy resolution of the detectors [m,2]
% 
% % Be window data from wiki, HXRS/Hardware
% hxrs.ef_hxr = 0.127*ones(1,96);      % thickness of the vacuum window (mm) [1,m]
% hxrs.tf_hxr = repmat('Be',96,1);    % type of material for the vacuum window (Al ou Be) [1,m]
% 
% % no absorber of detector shield
% hxrs.ea_hxr = zeros(1,96);          % thickness of the absorber (mm) [1,m] (WARNING: for 2 mm Cu: 2.83= 2*(29/26)^2*(dens_Cu/dens_Fe)  dens_Cu = 63.546, dens_Fe = 55.845)
% hxrs.ta_hxr = repmat('Fe',96,1);    % type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]
% hxrs.ec_hxr = zeros(1,96);     % thickness of the detector shield (mm) [1,m]
% hxrs.tc_hxr = repmat('Al',96,1);    % type of material for the detector shield (Al,C ou Be) [1,m]
% hxrs.ed_hxr = 2*ones(1,96);         % thickness of the detector (mm) [1,m]
% hxrs.td_hxr = repmat('CdTe',96,1);  % type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]
% 
% 
% %--------------------------------------------------------------------------
% % common data
% %--------------------------------------------------------------------------
% 
% hxr.kdiag_hxr = [10:10:180,50 ;...
%                  20:10:190,110];    % Measured photon energy spectrum (keV) [kmin1,kmin2,...,kmintphot,kmax1,kmax2,...,kmaxtphot] (here photon temp is calculated between 50 and 110 keV) [1,k]
% 
% hxr.kphot = [10:5:190];            % Photon energy in keV
% 
