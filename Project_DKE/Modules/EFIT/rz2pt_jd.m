function [ptR,ptZ,ptdpsindr,ptdpsindz,ppsin,ttheta] = rz2pt_jd(rR,zZ,Rp,Zp,rzpsin,ppsin,ttheta,method,display_mode,p_opt,filename,sfac);
%
% This function inverts the magnetic geometry data.
%
% by J. Decker (jodecker@alum.mit.edu) 11/02/04
%
if nargin < 12
    sfac = 10;
end
if nargin < 11
    filename = 'tokamak';
end
if nargin < 10
    p_opt = -1;
end
if nargin < 9
    display_mode = 0;
end
if nargin < 8
    method = 'linear';
end
if nargin < 7
    ttheta = 65;
end
if nargin < 6
    ppsin = 101;
end
%
nt = length(ttheta);
if nt == 1
    nt = ttheta;
    ttheta = linspace(0,2*pi,nt);
end
%
np = length(ppsin);
if np == 1
    np = ppsin;
    ppsin = linspace(0,1,np);
end
%
nr=  length(rR);
nz = length(zZ);
%
% interpolation for better griddata
%
Rmin = min(rR);
Rmax = max(rR);
Zmin = min(zZ);
Zmax = max(zZ);
%
snr = sfac*(nr-1) + 1;
snz = sfac*(nz-1) + 1;
%
srR = linspace(Rmin,Rmax,snr);
szZ = linspace(Zmin,Zmax,snz);
%
% even finer grid near the center
%
iRc = find(abs(srR - Rp) == min(abs(srR - Rp)));
iZc = find(abs(szZ - Zp) == min(abs(szZ - Zp)));
%
srR = [srR(1:iRc - 2),linspace(srR(iRc - 1),srR(iRc + 1),2*sfac+1),srR(iRc + 2:snr)];
szZ = [szZ(1:iZc - 2),linspace(szZ(iZc - 1),szZ(iZc + 1),2*sfac+1),szZ(iZc + 2:snz)];
%
snr = length(srR);
snz = length(szZ);
%
srzpsin = interp2(rR,zZ,rzpsin',srR',szZ,method)';
%
% calculation of grad psi on half grid
%
hrR = (srR(1:snr-1) + srR(2:snr))/2;
hzZ = (szZ(1:snz-1) + szZ(2:snz))/2;
%
hnr = length(hrR);
hnz = length(hzZ);
%
hrzdR = repmat(diff(srR)',[1,hnz]);
hrzdZ = repmat(diff(szZ),[hnr,1]);
%
hrzpsin = (srzpsin(1:snr-1,1:snz-1) + srzpsin(1:snr-1,2:snz) + srzpsin(2:snr,1:snz-1) + srzpsin(2:snr,2:snz))/4;
hrzdpsindr = (diff(srzpsin(:,1:snz-1)) + diff(srzpsin(:,2:snz)))./(2*hrzdR);
hrzdpsindz = (diff(srzpsin(1:snr-1,:)') + diff(srzpsin(2:snr,:)'))'./(2*hrzdZ);
%
% change to (r,theta) grid
%
srzR = repmat(srR',[1,snz]);
srzZ = repmat(szZ,[snr,1]);
%
srzr = sqrt((srzR - Rp).^2 + (srzZ - Zp).^2);
srzR(srzR == Rp) = Rp - eps;
srztheta = atan((srzZ - Zp)./(srzR - Rp)) + pi*(srzR < Rp) + 2*pi*(srzR > Rp & srzZ < Zp);
%
%
hrzR = repmat(hrR',[1,hnz]);
hrzZ = repmat(hzZ,[hnr,1]);
%
hrzr = sqrt((hrzR - Rp).^2 + (hrzZ - Zp).^2);
hrzR(hrzR == Rp) = Rp - eps;
hrztheta = atan((hrzZ - Zp)./(hrzR - Rp)) + pi*(hrzR < Rp) + 2*pi*(hrzR > Rp & hrzZ < Zp);
%
% last closed flux-surface
%
[x1c,x2c,col] = contlimit_jd(srR,szZ,srzpsin',[-1,0.999]);
%
% selects the plasma among various closed systems   
%
for ic = 1:length(x1c),
    nc(ic) = length(x1c{ic});
end
ic = find(nc == max(nc)); 
sRa = x1c{ic};
sZa = x2c{ic};
%
% change to (r,theta) grid
%
sra = sqrt((sRa - Rp).^2 + (sZa - Zp).^2);
sRa(sRa == Rp) = Rp + eps;
sthetaa = atan((sZa - Zp)./(sRa - Rp)) + pi*(sRa < Rp) + 2*pi*(sRa > Rp & sZa < Zp);
[sthetaa,ia] = sort(sthetaa);
sra = sra(ia);
maska = [1,find(diff(sthetaa) ~= 0)+1];
sthetaa = sthetaa(maska);
sra = sra(maska);
sns = length(sthetaa);
sthetaa = [sthetaa(sns) - 2*pi,sthetaa,sthetaa(1) + 2*pi];
sra = [sra(sns),sra,sra(1)];
%
% redefine free space values for better interpolations
%
sXtheta = reshape(srztheta,[snr*snz,1]);
sXr = reshape(srzr,[snr*snz,1]);
sXpsin = reshape(srzpsin,[snr*snz,1]);
%
sXrmax = interp1(sthetaa,sra,sXtheta,method);
sXmask_in = sXr <= sXrmax;
%
sXtheta = sXtheta(sXmask_in);
sXr = sXr(sXmask_in);
sXpsin = sXpsin(sXmask_in);
%
%
hXtheta = reshape(hrztheta,[hnr*hnz,1]);
hXr = reshape(hrzr,[hnr*hnz,1]);
hXpsin = reshape(hrzpsin,[hnr*hnz,1]);
hXdpsindr = reshape(hrzdpsindr,[hnr*hnz,1]);
hXdpsindz = reshape(hrzdpsindz,[hnr*hnz,1]);
%
hXrmax = interp1(sthetaa,sra,hXtheta,method);
hXmask_in = hXr <= hXrmax;
%
hXtheta = hXtheta(hXmask_in);
hXr = hXr(hXmask_in);
hXpsin = hXpsin(hXmask_in);
hXdpsindr = hXdpsindr(hXmask_in);
hXdpsindz = hXdpsindz(hXmask_in);
%
% Remove central point (which is undefined)
%
smask0 = (sXr == min(sXr));
sXtheta = sXtheta(~smask0);
sXr = sXr(~smask0);
sXpsin = sXpsin(~smask0);
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
%
maskm = find(sXtheta < 2*pi & sXtheta > 2*pi - pi/8);
sXtheta = [sXtheta;sXtheta(maskm) - 2*pi];
sXr = [sXr;sXr(maskm)];
sXpsin = [sXpsin;sXpsin(maskm)];
%
%
hmaskp = find(hXtheta >= 0 & hXtheta < pi/8);
hXtheta = [hXtheta;2*pi+hXtheta(hmaskp)];
hXr = [hXr;hXr(hmaskp)];
hXpsin = [hXpsin;hXpsin(hmaskp)];
hXdpsindr = [hXdpsindr;hXdpsindr(hmaskp)];
hXdpsindz = [hXdpsindz;hXdpsindz(hmaskp)];
%
hmaskm = find(hXtheta < 2*pi & hXtheta > 2*pi - pi/8);
hXtheta = [hXtheta;hXtheta(hmaskm) - 2*pi];
hXr = [hXr;hXr(hmaskm)];
hXpsin = [hXpsin;hXpsin(hmaskm)];
hXdpsindr = [hXdpsindr;hXdpsindr(hmaskm)];
hXdpsindz = [hXdpsindz;hXdpsindz(hmaskm)];
%
p2psin = ppsin(2:np-1);
%
gdmethod = 'linear';
%
p2tr = griddata(sXpsin,sXtheta,sXr,p2psin',ttheta,gdmethod)';
tra = interp1(sthetaa,sra,ttheta,method);
ptr = [zeros(1,nt);p2tr;tra];
%
pttheta = repmat(ttheta,[np,1]);
%
ptR = Rp + ptr.*cos(pttheta);
ptZ = Zp + ptr.*sin(pttheta);
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
p2tdpsindr = griddata(hXpsin,hXtheta,hXdpsindr,p2psin',ttheta,gdmethod)';
p2tdpsindz = griddata(hXpsin,hXtheta,hXdpsindz,p2psin',ttheta,gdmethod)';
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
ptdpsindr = [zeros(1,nt);interp1(p2psin,p2tdpsindr,[p2psin,1],method,'extrap')];
ptdpsindz = [zeros(1,nt);interp1(p2psin,p2tdpsindz,[p2psin,1],method,'extrap')];
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
    Rmax = ptR(np,1);%Major radius where the last close flux-surface crosses the LFS midplane
    ap =  Rmax - Rp;%Plasma minor radius on the LFS midplane 
    prho = (ptR(:,1)' - Rp)/ap;
    %
    srho = linspace(0,1,21);
    stheta = linspace(0,2*pi,31);
    sR = interp1(prho,ptR,srho,method);  
    sZ = interp1(prho,ptZ,srho,method); 
    stR = interp1(ttheta,ptR',stheta,method)';  
    stZ = interp1(ttheta,ptZ',stheta,method)';    
%
    Rmin = min(min(ptR));
    Rmax = max(max(ptR));
    Zmin = min(min(ptZ));
    Zmax = max(max(ptZ));
    %
    figure(51),clf
%    
    [ax] = graph1D_jd(sR',sZ',0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],style,marker,color1,width1,siz,gca,red);pause(0.5)
    [ax] = graph1D_jd(stR,stZ,0,0,'R','Z','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],style,marker,color2,width2);pause(0.5)
    axis('equal');  
    axis([Rmin,Rmax,Zmin,Zmax]);
    print_jd(p_opt,[filename,'_rhotheta']);
    %
    figure(52),clf
%    
    sspsin = linspace(0,1,21);
    sR = interp1(sqrt(ppsin),ptR,sspsin,method);  
    sZ = interp1(sqrt(ppsin),ptZ,sspsin,method); 
    
    [ax] = graph1D_jd(sR',sZ',0,0,'R','Z','',NaN,[Rmin,Rmax],[Zmin,Zmax],style,marker,color1,width1,siz,gca,red);pause(0.5)
    axis('equal');  
    axis([Rmin,Rmax,Zmin,Zmax]);
    print_jd(p_opt,[filename,'_spsin']);
end