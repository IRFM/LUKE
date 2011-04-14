function pV = equilvol_mc_jd(Rp,theta,ptx,pty,N,mfac,method)
%
if nargin < 7,
    method = 'linear';
end
%
if nargin < 6,
    mfac = 50;
end
%
if nargin < 5,
    N = 10;
end
%
[np,nt] = size(ptx);
%
if any(theta ~= linspace(0,2*pi,nt)),
    error('case of nonuniform theta grid not yet implemented')
end
%
pmx = interpft(ptx(:,1:nt-1),(nt-1)*mfac,2); %FFT interpolation
pmy = interpft(pty(:,1:nt-1),(nt-1)*mfac,2); %FFT interpolation
%
pmx = [pmx,pmx(:,1)]; %2*pi point retrieved
pmy = [pmy,pmy(:,1)]; %2*pi point retrieved
pmr = sqrt(pmx.^2 + pmy.^2);
mtheta = linspace(0,2*pi,mfac*(nt-1)+1);
%
xmax = max(pmx(end,:),[],2);
ymin = min(pmy(end,:),[],2);
ymax = max(pmy(end,:),[],2);
%
Rmax = Rp + xmax;
%
Xmin = -Rmax;
Xmax = Rmax;
Ymin = -Rmax;
Ymax = Rmax;
Zmin = ymin;
Zmax = ymax;
%
Vtot = (Xmax - Xmin)*(Ymax - Ymin)*(Zmax - Zmin);
%
F = rand([N,3]);
%
X = Xmin + F(:,1)*(Xmax - Xmin);
Y = Ymin + F(:,2)*(Ymax - Ymin);
Z = Zmin + F(:,3)*(Zmax - Zmin);
R = sqrt(X.^2 + Y.^2);
%
x = R - Rp;
y = Z;
r = sqrt(x.^2 + y.^2);
theta = atan(y./x) + pi*(x < 0) + 2*pi*(x > 0 & y < 0);
theta(x == 0) = pi/2 + pi*(y(x == 0) < 0);
%
pr = interp1(mtheta,pmr.',theta,method).';
%
pV = Vtot*sum(repmat(r.',[np,1]) < pr,2)/N;












