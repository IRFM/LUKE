function hxrexp = iluke_hxrexpimport(external)
%
hxrexp = '';
%
if isfield(external,'ap') && isfield(external,'data'),% TCV data loaded by luke_get_hxr_diag_tcv
    %
    nt = length(external.time);
    nk = size(external.hxr.kdiag_hxr,2) - 1;
    nc = external.ap.nc;
    %
    hxrexp.data = NaN(nt,nk,nc);
    %
    % new cameras
    %
    mask = external.ap.chords_abs{external.ap.cams(2)}(1):nc;
    ncm = length(mask);
    %
    hxrexp.data(:,:,mask) = permute(reshape(external.data,ncm,nk,nt),[3 2 1]);
    hxrexp.time = external.time;
    hxrexp.energy = external.hxr.kdiag_hxr(1,1:(end-1));
    %
end
    


