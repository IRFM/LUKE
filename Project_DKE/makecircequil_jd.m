function makecircequil_jd(tokamak,np,nt)

if nargin < 3
	nt = 101;
end
if nargin < 2
	np = 41;
end
if nargin < 1
	error('Tokamak not specified');
end


loadstr = ['PARAM_',tokamak];
%
eval(['load ',loadstr,' ap Rp Ip Bt ']);

Zp = 0.0;
Ip = Ip*1e6;

mu0n = 1e-7;
Bpa = 2*mu0n*Ip/ap;

rho = linspace(0,1,np);
theta = linspace(0,2*pi,nt);

Xrho = repmat(rho',[1,nt]);
Xtheta = repmat(theta,[np,1]);

R = Rp + ap*Xrho.*cos(Xtheta);
Z = Zp + ap*Xrho.*sin(Xtheta);

BR = -Bpa*Xrho.*sin(Xtheta)*Rp./R;
BZ = Bpa*Xrho.*cos(Xtheta)*Rp./R;
BPHI = Bt*Rp./R;

filename = ['EQUIL_',tokamak];

eval(['save ',filename,' R Z BR BZ BPHI'])

