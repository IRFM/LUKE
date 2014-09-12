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
    kphot_diag = (external.hxr.hxr.kdiag_hxr(1,1:(end-1)) + external.hxr.hxr.kdiag_hxr(2,1:(end-1)))/2;
    %
    hxr.param.kphot = unique([hxr.param.kphot,kphot_diag]);
    %
%     hxr.param.kmin = external.hxr.hxr.kdiag_hxr(1,end);
%     hxr.param.kmax = external.hxr.hxr.kdiag_hxr(2,end);
    %
    clear ncams icam kphot_diag
    %
end
    


