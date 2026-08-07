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
function  [Zbremplasma] = bremchordemission_dke_jd(Zbremplasma,Zbremchord,hxr,viewmode)
%R5-X2 - Calculation of  the plasma bremsstrahlung emission
%
% Calculates the plasma bremsstrahlung emission. Call first the function bremchord_dke_yp.m
%
%   INPUTS:
%   
%       - Zbremchord: HXR diagnostic chord arrangement data structure
%       - equilHXR: HXR magnetic equilibrium structure
%       - hxr: Bremsstrahlung structure
%       - hxrparam : Bremsstrahlung calculation and display parameter structure
%       - dkeparam: DKE data structure
%       - radialDKE: DKE radial grid structure   
%       - mksa: MKSA structure   
%       - momentumDKE: DKE momentum structure
%       - dke_out: DKE data output structure (distributions)
%       - niewmode: (NaN) exact topology (0) perp (1) forward (-1) backward
%       
%   OUTPUTS:
%   
%      - Zbremplasma: Plasma bremsstrahlung data structure
%         * Zbremplasma.kphot : photon energies (keV) [1,nk]
%         * Zbremplasma.brem_bd_out : photon number per unit energy (keV) and time (s) for each chord [nchord,nk]
%         * Zbremplasma.lchord : chord length (m) [1,nchord]
%
% by Joan Decker (CEA/IRFM,joan.decker@cea.fr) and Yves Peysson(CEA/IRFM,yves.peysson@cea.fr)
%
if nargin < 4,
    viewmode = NaN;
end
if nargin < 3,
    error('Not enough input arguments in bremchordemission_dke_jd')
end
%
if isempty(Zbremplasma)
    %
    return;
    %
end
%
vschords = Zbremchord.vschords;
%
nc = size(vschords,3);
%
zdatahxr_in = cell(1,nc);
%
for ic = 1:nc,%loop on each chord
    zdatahxr_in{ic}.vschords = vschords(:,:,ic);
    zdatahxr_in{ic}.EG_hxr = hxr.EG_hxr(ic);
end
%
dkepath = load_structures_yp('dkepath','','');
%
mdce_mode = 0;                                                     
%
clustermode.loop_brem_chord_yp.scheduler.mode = real(mdce_mode);
if ~isreal(mdce_mode),
    clustermode.loop_brem_chord_yp.scheduler.gpu = imag(mdce_mode);
else
    clustermode.loop_brem_chord_yp.scheduler.gpu = 0;
end
%
dkecluster = clustermode_luke(clustermode,'loop_brem_chord_yp',dkepath);
%
[flag,zbrem_bd_out,zlchord] = mdce_run(@loop_brem_chord_yp,{viewmode,Zbremplasma.kphot,Zbremplasma.cL,Zbremplasma.ZZIB,''},5,zdatahxr_in,dkecluster);
%
for ic = 1:nc,%loop on each chord
    Zbremplasma.brem_bd_out(ic,:) = zbrem_bd_out{ic};
    Zbremplasma.lchord(ic) = zlchord{ic};
end