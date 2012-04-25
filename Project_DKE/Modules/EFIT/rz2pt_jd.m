function [ptx,pty,ptdpsindx,ptdpsindy,psin,theta] = rz2pt_jd(x,y,xypsin,psin,theta,method,display_mode,p_opt,filename,sfac);
%
% This function inverts the magnetic geometry data.
%
% by J. Decker (jodecker@alum.mit.edu) 11/02/04
%
if nargin < 10
    sfac = 10;
end
if nargin < 9
    filename = 'tokamak';
end
if nargin < 8
    p_opt = -1;
end
if nargin < 7
    display_mode = 0;
end
if nargin < 6
    method = 'linear';
end
if nargin < 5
    theta = 65;
end
if nargin < 4
    psin = 101;
end
%
nt = length(theta);
if nt == 1
    nt = theta;
    theta = linspace(0,2*pi,nt);
end
%
np = length(psin);
if np == 1
    np = psin;
    psin = linspace(0,1,np);
end
%
psin_lcfs = 0.999;%0.998;%
%
nx=  length(x);
ny = length(y);
%
% interpolation for better griddata
%
xmin = min(x);
xmax = max(x);
ymin = min(y);
ymax = max(y);
%
snx = sfac*(nx-1) + 1;
sny = sfac*(ny-1) + 1;
%
sx = linspace(xmin,xmax,snx);
sy = linspace(ymin,ymax,sny);
%
% even finer grid near the center
%
ix = find(abs(sx) == min(abs(sx)));
iy = find(abs(sy) == min(abs(sy)));
%
sx = sort([sx([1:ix-2,ix+2:end]),linspace(sx(ix - 1),sx(ix + 1),2*sfac+1)]);
sy = sort([sy([1:iy-2,iy+2:end]),linspace(sy(iy - 1),sy(iy + 1),2*sfac+1)]);
%
%
snx = length(sx);
sny = length(sy);
%
ix = find(abs(sx) == min(abs(sx)));
iy = find(abs(sy) == min(abs(sy)));
%
if abs(sx(ix)) > 10*eps | abs(sy(iy)) > 10*eps,
    warning('location of magnetic axis enforced')
end
sx(ix) = 0;
sy(iy) = 0;
%
sxypsin = interp2(x,y,xypsin.',sx.',sy,method).';
%
if abs(sxypsin(ix,iy)) > 10*eps,
    warning('value of psi at magnetic axis enforced')
end
sxypsin(ix,iy) = 0;
%
% calculation of grad psi
%
hx = (sx(1:snx-1) + sx(2:snx))/2;
hy = (sy(1:sny-1) + sy(2:sny))/2;
%
hxyx = repmat(hx.',[1,sny]);
hxyy = repmat(hy,[snx,1]);
%
hxypsin_x = interp1(sx,sxypsin,hx,method);
hxypsin_y = interp1(sy,sxypsin.',hy,method).';
%
sxydpsindx = zeros(snx,sny);
sxydpsindy = zeros(snx,sny);
%
sxydpsindx(2:snx-1,:) = diff(hxypsin_x)./diff(hxyx);
sxydpsindy(:,2:sny-1) = diff(hxypsin_y.').'./diff(hxyy.').';
%
sxydpsindx(1,:) = (hxypsin_x(1,:) - sxypsin(1,:))/(hx(1) - sx(1));
sxydpsindy(:,1) = (hxypsin_y(:,1) - sxypsin(:,1))/(hy(1) - sy(1));
%
sxydpsindx(snx,:) = (sxypsin(snx,:) - hxypsin_x(snx-1,:))/(sx(snx) - hx(snx-1));
sxydpsindy(:,sny) = (sxypsin(:,sny) - hxypsin_y(:,sny-1))/(sy(sny) - hy(sny-1));
%
sxydpsindx(ix,iy) = 0;
sxydpsindy(ix,iy) = 0;
%
% change to (r,theta) grid
%
sxyx = repmat(sx.',[1,sny]);
sxyy = repmat(sy,[snx,1]);
%
sxyr = sqrt(sxyx.^2 + sxyy.^2);
sxyx(sxyx == 0) = - eps;
sxytheta = atan(sxyy./sxyx) + pi*(sxyx < 0) + 2*pi*(sxyx > 0 & sxyy < 0);
%
% last closed flux-surface
%
[xc,yc] = contlimit_jd(sx,sy,sxypsin',[-1,psin_lcfs]);
%
% selects the plasma among various closed systems   
%
for ic = 1:length(xc),
    nc(ic) = length(xc{ic});
end
ic = find(nc == max(nc)); 
sxa = xc{ic};
sya = yc{ic};
%
% change to (r,theta) grid
%
sra = sqrt(sxa.^2 + sya.^2);
sxa(sxa == 0) = - eps;
sthetaa = atan(sya./sxa) + pi*(sxa < 0) + 2*pi*(sxa > 0 & sya < 0);
[sthetaa,ia] = sort(sthetaa);
sra = sra(ia);
maska = [1,find(diff(sthetaa) ~= 0)+1];
sthetaa = sthetaa(maska);
sra = sra(maska);
sna = length(sthetaa);
sthetaa = [sthetaa(sna) - 2*pi,sthetaa,sthetaa(1) + 2*pi];
sra = [sra(sna),sra,sra(1)];
%
% redefine free space values for better interpolations
%
sXtheta = reshape(sxytheta,[snx*sny,1]);
sXr = reshape(sxyr,[snx*sny,1]);
sXpsin = reshape(sxypsin,[snx*sny,1]);
sXdpsindx = reshape(sxydpsindx,[snx*sny,1]);
sXdpsindy = reshape(sxydpsindy,[snx*sny,1]);
%
sXrmax = interp1(sthetaa,sra,sXtheta,method);
sXmask_in = sXr <= sXrmax;
%
sXtheta = sXtheta(sXmask_in);
sXr = sXr(sXmask_in);
sXpsin = sXpsin(sXmask_in);
sXdpsindx = sXdpsindx(sXmask_in);
sXdpsindy = sXdpsindy(sXmask_in);
%
% Remove central point (which is undefined)
%
smask0 = (sXr ~= 0);
%
sXtheta = sXtheta(smask0);
sXr = sXr(smask0);
sXpsin = sXpsin(smask0);
sXdpsindx = sXdpsindx(smask0);
sXdpsindy = sXdpsindy(smask0);
%
% For better theta calculations
%
%sXtheta = [sXtheta;ttheta'];
%sXr = [sXr;zeros(nt,1)];
%sXpsin = [sXpsin;zeros(nt,1)];
%
smaskp = find(sXtheta >= 0 & sXtheta < pi/8);
sXtheta = [sXtheta;2*pi+sXtheta(smaskp)];
sXr = [sXr;sXr(smaskp)];
sXpsin = [sXpsin;sXpsin(smaskp)];
sXdpsindx = [sXdpsindx;sXdpsindx(smaskp)];
sXdpsindy = [sXdpsindy;sXdpsindy(smaskp)];
%
smaskm = find(sXtheta < 2*pi & sXtheta > 2*pi - pi/8);
sXtheta = [sXtheta;sXtheta(smaskm) - 2*pi];
sXr = [sXr;sXr(smaskm)];
sXpsin = [sXpsin;sXpsin(smaskm)];
sXdpsindx = [sXdpsindx;sXdpsindx(smaskm)];
sXdpsindy = [sXdpsindy;sXdpsindy(smaskm)];
%
hpsin = psin(2:np-1);
%
gdmethod = 'cubic';
%
hptr = griddata(sXpsin,sXtheta,sXr,hpsin.',theta,gdmethod).';
tra = interp1(sthetaa,sra,theta,method);
ptr = [zeros(1,nt);hptr;tra];
%
pttheta = repmat(theta,[np,1]);
%
ptx = ptr.*cos(pttheta);
pty = ptr.*sin(pttheta);
%
%sXR = reshape(srzR,[snr*snz,1]);
%sXZ = reshape(srzZ,[snr*snz,1]);
%sXR = sXR(sXmask_in);
%sXZ = sXZ(sXmask_in);
%sXR = sXR(~smask0);
%sXZ = sXZ(~smask0);
%sXR = [sXR;sXR(smaskp)];
%sXZ = [sXZ;sXZ(smaskp)];
%sXR = [sXR;sXR(smaskm)];
%sXZ = [sXZ;sXZ(smaskm)];
%p2tR = griddata(sXpsin,sXtheta,sXR,p2psin',ttheta,gdmethod)';
%p2tZ = griddata(sXpsin,sXtheta,sXZ,p2psin',ttheta,gdmethod)';
%
%h2psin = [hpsin(1:end-1),linspace(hpsin(end),1,sfac)];
h2psin = hpsin;
%
h2ptdpsindx = griddata(sXpsin,sXtheta,sXdpsindx,h2psin.',theta,gdmethod).';
h2ptdpsindy = griddata(sXpsin,sXtheta,sXdpsindy,h2psin.',theta,gdmethod).';
%
%p2tdpsindr
%
%hXR = reshape(hrzR,[hnr*hnz,1]);
%hXZ = reshape(hrzZ,[hnr*hnz,1]);
%hXR = hXR(hXmask_in);
%hXZ = hXZ(hXmask_in);
%hXR = [hXR;hXR(hmaskp)];
%hXZ = [hXZ;hXZ(hmaskp)];
%hXR = [hXR;hXR(hmaskm)];
%hXZ = [hXZ;hXZ(hmaskm)];
%p2tR = griddata(hXpsin,hXtheta,hXR,p2psin',ttheta,gdmethod)';
%p2tZ = griddata(hXpsin,hXtheta,hXZ,p2psin',ttheta,gdmethod)';
%
ipmax = max(find(sum(isnan(h2ptdpsindx.') | isnan(h2ptdpsindy.')) == 0));
mask = 1:ipmax;
%
ptdpsindx = [zeros(1,nt);interp1(h2psin(mask),h2ptdpsindx(mask,:),[hpsin,1],gdmethod,'extrap')];
ptdpsindy = [zeros(1,nt);interp1(h2psin(mask),h2ptdpsindy(mask,:),[hpsin,1],gdmethod,'extrap')];
%
if display_mode >= 2,
    %
    style = '-';
    marker = 'none';
    color1 = 'r';
    color2 = 'b';
    width1 = 2;
    width2 = 0.5;
    siz = 20;
    red = 0.9;
    %
    ap = ptx(np,1);%Plasma minor radius on the LFS midplane 
    prho = ptx(:,1).'/ap;
    %
    srho = linspace(0,1,21);
    stheta = linspace(0,2*pi,33);
    sx = interp1(prho,ptx,srho,method);  
    sy = interp1(prho,pty,srho,method); 
    stx = interp1(theta,ptx',stheta,method)';  
    sty = interp1(theta,pty',stheta,method)';    
    %
    xmin = min(min(ptx));
    xmax = max(max(ptx));
    ymin = min(min(pty));
    ymax = max(max(pty));
    %
    figure_yp('','Poloidal view - MHD equilibrium','clf');
    %    
    [ax] = graph1D_jd(sx',sy',0,0,'','','',NaN,[xmin,xmax],[ymin,ymax],style,marker,color1,width1,siz,gca,red);pause(0.5)
    [ax] = graph1D_jd(stx,sty,0,0,'x','y','',NaN,[xmin,xmax],[ymin,ymax],style,marker,color2,width2);pause(0.5)
    axis('equal');  
    axis([xmin,xmax,ymin,ymax]);
    print_jd(p_opt,[filename,'_rhotheta']);
    %
    figure_yp('','Poloidal view - MHD equilibrium','clf');
    %    
    sspsin = linspace(0,1,21);
    sx = interp1(sqrt(psin),ptx,sspsin,method);  
    sy = interp1(sqrt(psin),pty,sspsin,method); 
    %
    [ax] = graph1D_jd(sx',sy',0,0,'x','y','',NaN,[xmin,xmax],[ymin,ymax],style,marker,color1,width1,siz,gca,red);pause(0.5)
    axis('equal');  
    axis([xmin,xmax,ymin,ymax]);
    print_jd(p_opt,[filename,'_spsin']);
    %
    %figure_yp('','Toroidal view - MHD equilibrium','clf');
    %
    
    
    
    
    
    
end