function [NperpX,NperpO,xKxyz,x3eX_xyz,x3eO_xyz,x3eX_pmz,x3eO_pmz,x3eX_ppk,x3eO_ppk] = colddisp_OX_jd(tokamak,x,y,omega,xNpar);
%
if length(y) == 1
    y = repmat(y,size(x));
elseif length(x) == 1
    x = repmat(x,size(y));
elseif size(x) ~= size(y)
    error('x and y dimensions are incompatible')
end
if length(xNpar) == 1 
    xNpar = repmat(xNpar,size(x));
elseif size(x) ~= size(xNpar) 
    error('x and y dimensions are incompatible')
end
%
xrho = sqrt(x.^2 + y.^2);
Nr = length(xrho);
%
loadstr = ['PARAM_',tokamak];
load([loadstr,'ap','Rp','Ip','Bt','pne','Zi','mi','fi','pzTi','pzni','prho','pq');
%
xne = interp1(prho,pne,xrho);
zxni = interp1(prho,pzni',xrho)';
xq = interp1(prho,pq,xrho);
xq(xq == 0) = eps;
%
qe = 1.60217733e-19;%Electron charge (C)
me = 9.1093897e-31;%Electron rest mass (Kg)
%
xBt = Bt./(1 + x*ap/Rp);
xBp = xrho*ap/Rp.*xBt./xq;
xB = sqrt(xBt.^2 + xBp.^2);
%
xwce0 = qe*xB/me;
%
for ir=1:Nr
    [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_ppk,em_ppk] = colddisp_dke_jd(xNpar(ir),omega,xne(ir),zxni(:,ir),Zi,mi,xB(ir));
    
    NperpO(ir) = Nperpp.*(xwce0(ir) < omega) + Nperpm.*(xwce0(ir) > omega); 
    NperpX(ir) = Nperpp.*(xwce0(ir) > omega) + Nperpm.*(xwce0(ir) < omega); 
    
    xKxyz(1:3,1:3,ir) = Kxyz;
    
    eO_xyz = ep_xyz.*(xwce0(ir) < omega) + em_xyz.*(xwce0(ir) > omega); 
    eX_xyz = ep_xyz.*(xwce0(ir) > omega) + em_xyz.*(xwce0(ir) < omega); 
    eO_pmz = ep_pmz.*(xwce0(ir) < omega) + em_pmz.*(xwce0(ir) > omega); 
    eX_pmz = ep_pmz.*(xwce0(ir) > omega) + em_pmz.*(xwce0(ir) < omega); 
    eO_ppk = ep_ppk.*(xwce0(ir) < omega) + em_ppk.*(xwce0(ir) > omega); 
    eX_ppk = ep_ppk.*(xwce0(ir) > omega) + em_ppk.*(xwce0(ir) < omega); 
    
    x3eX_xyz(ir,1:3) = eX_xyz';
    x3eX_pmz(ir,1:3) = eX_pmz';
    x3eX_ppk(ir,1:3) = eX_ppk';
    x3eO_xyz(ir,1:3) = eO_xyz';
    x3eO_pmz(ir,1:3) = eO_pmz';
    x3eO_ppk(ir,1:3) = eO_ppk';
end
   
