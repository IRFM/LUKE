function [pshift,pelong,ptrian,pli] = equilmoments_jd(theta,ptx,pty,mfac)
%
if nargin < 4,
    mfac = 50;
end
%
nt = length(theta);
%
if any(theta ~= linspace(0,2*pi,nt)),
    error('case of nonuniform theta grid not yet implemented')
end
%
pmx = interpft(ptx(:,1:nt-1),(nt-1)*mfac,2); %FFT interpolation
pmy = interpft(pty(:,1:nt-1),(nt-1)*mfac,2); %FFT interpolation
%
pxmin = min(pmx,[],2);
pxmax = max(pmx,[],2);
pymin = min(pmy,[],2);
pymax = max(pmy,[],2);
%
pli = (pxmax - pxmin)/(pxmax(end) - pxmin(end));
pshift = (pxmax + pxmin)/2;
pelong = (pymax - pymin)./(pxmax - pxmin);
%
pmymin = repmat(pymin,[1,(nt-1)*mfac]);
pmymax = repmat(pymax,[1,(nt-1)*mfac]);
%
pxymin = sum(pmx.*(pmy == pmymin),2)./sum(pmy == pmymin,2);
pxymax = sum(pmx.*(pmy == pmymax),2)./sum(pmy == pmymax,2);
%
ptrian = -(pxymin + pxymax - 2*pshift)./(pxmax - pxmin);




