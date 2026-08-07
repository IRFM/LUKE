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
% script iluke_hxrcamimport
%
hxr.cam = {};
%
if isfield(external.hxr,'ap') && isfield(external.hxr,'hxrparam'),% TCV data loaded by luke_get_hxr_diag_tcv
    %
%     hxr.param = external.hxr.hxrparam;
    %
    ncams = length(external.hxr.ap.cams);
    %
    hxr.cam = cell(1,ncams);
    %
    for icam = 1:ncams
        %
        hxr.cam{icam} = tcv2r5x2(external.hxr.ap,icam);
        %
        hxr.cam{icam}.selectedchord = find(hxr.cam{icam}.chordsnum == hxr.cam{icam}.centralchord);
        %
    end
    %
    kphot_diag_S = [external.hxr.hxr.kdiag_hxr(1,1:(end-1)),external.hxr.hxr.kdiag_hxr(2,end-1)];% photon energies representing energy bin limits
    kphot_diag = (kphot_diag_S(1:end-1) + kphot_diag_S(2:end))/2;% photon energies representing energy bin centers
    %
    hxr.param.kphot = unique([hxr.param.kphot,kphot_diag,kphot_diag_S]);% energies for bremsstrahlung calculations
    %
%     hxr.param.kmin = external.hxr.hxr.kdiag_hxr(1,end);
%     hxr.param.kmax = external.hxr.hxr.kdiag_hxr(2,end);
    %
    clear ncams icam kphot_diag
    %
end
    


