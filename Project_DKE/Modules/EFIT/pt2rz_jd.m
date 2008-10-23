function equil_RZ = pt2rz_jd(equil,x,y,nprz,method)
%
[np,nt] = size(equil.ptx);
%
if nargin < 5,
	method = 'linear';
end
%
if nargin < 4,
	nprz = np;
end
%
equil_RZ.psi_apRp = equil.psi_apRp;
equil_RZ.ap = equil.ptx(end,1);
equil_RZ.Rp = equil.Rp;
equil_RZ.Zp = equil.Zp;
equil_RZ.zZi = equil.zZi;
equil_RZ.zmi = equil.zmi;
equil_RZ.id = equil.id;
%
ptx = equil.ptx;
pty = equil.pty;
%
if nargin < 3,
    y = [min(pty(end,:)),max(pty(end,:))];
end
%
if nargin < 2,
    x = [min(ptx(end,:)),max(ptx(end,:))];
end
%
if length(x) == 1,
    extfacx = x;
    x = NaN;
end
%
if length(y) == 1,
    extfacy = y;
    y = NaN;
end
%
psia_apRp = equil.psi_apRp(end);
psin = equil.psi_apRp/psia_apRp;
%
dpsin = psin(end) - psin(end-1);
%
if isnan(x),
    xmin = min(ptx(end,:));
    xmax = max(ptx(end,:));
    %
    itxmin = find(ptx(end,:) == xmin,1,'first');
    itxmax = find(ptx(end,:) == xmax,1,'first');
    %
    dxmin = (ptx(end,itxmin) - ptx(end-1,itxmin))*extfacx/dpsin;
    dxmax = (ptx(end,itxmax) - ptx(end-1,itxmax))*extfacx/dpsin;
    %
    x = [xmin + dxmin,xmax + dxmax];
end
%
if isnan(y),
    ymin = min(pty(end,:));
    ymax = max(pty(end,:));
    %
    itymin = find(pty(end,:) == ymin,1,'first');
    itymax = find(pty(end,:) == ymax,1,'first');
    %
    dymin = (pty(end,itymin) - pty(end-1,itymin))*extfacy/dpsin;
    dymax = (pty(end,itymax) - pty(end-1,itymax))*extfacy/dpsin;
    %
    y = [ymin + dymin,ymax + dymax];
end
%
if min(x) < -equil.Rp,
    error('min(x) < -equil.Rp');
end
%
dsdpsin_min = min(sqrt((ptx(end,:) - ptx(end-1,:)).^2 + (pty(end,:) - pty(end-1,:)).^2))/dpsin;
psin_max = 1 + sqrt((max(x) - min(x)).^2 + (max(y) - min(y)).^2)/dsdpsin_min;
psin_ext = [psin,1 + dpsin:dpsin:psin_max];
%
if length(x) > 2,
    equil_RZ.x = x;
else
    equil_RZ.x = linspace(x(1),x(2),nprz);
end
%
if length(y) > 2,
    equil_RZ.y = y;
else
    equil_RZ.y = linspace(y(1),y(2),nprz);
end    
%
ptx_ext = interp1(psin,ptx,psin_ext,'linear','extrap');
pty_ext = interp1(psin,pty,psin_ext,'linear','extrap');
ptBx_ext = interp1(psin,equil.ptBx,psin_ext,'linear','extrap');
ptBy_ext = interp1(psin,equil.ptBy,psin_ext,'linear','extrap');
ptBPHI_ext = interp1(psin,equil.ptBPHI,psin_ext,'linear','extrap');
%
psi_apRp_ext =  psia_apRp*repmat(psin_ext.',[1,nt]);
%
warning('off')
%
%equil_RZ.xyBx = griddata(ptx_ext,pty_ext,ptBx_ext,equil_RZ.x,equil_RZ.y.',method).';
%equil_RZ.xyBy = griddata(ptx_ext,pty_ext,ptBy_ext,equil_RZ.x,equil_RZ.y.',method).';
%equil_RZ.xyBPHI = griddata(ptx_ext,pty_ext,ptBPHI_ext,equil_RZ.x,equil_RZ.y.',method).';
equil_RZ.xypsi_apRp = griddata(ptx_ext,pty_ext,psi_apRp_ext,equil_RZ.x,equil_RZ.y.',method).';
%
warning('on')
%
equil_RZ.pTe = interp1(psin,equil.pTe,psin_ext,'linear','extrap');
equil_RZ.pne = interp1(psin,equil.pne,psin_ext,'linear','extrap');
equil_RZ.pzTi = interp1(psin,equil.pzTi.',psin_ext,'linear','extrap').';
equil_RZ.pzni = interp1(psin,equil.pzni.',psin_ext,'linear','extrap').';
%
equil_RZ.pTe(equil_RZ.pTe < 0) = 0;
equil_RZ.pne(equil_RZ.pne < 0) = 0;
equil_RZ.pzTi(equil_RZ.pzTi < 0) = 0;
equil_RZ.pzni(equil_RZ.pzni < 0) = 0;
%
mask = equil_RZ.pTe == 0 & equil_RZ.pne == 0 & sum(equil_RZ.pzTi,1) == 0 & sum(equil_RZ.pzni,1) == 0;
%
psin_ext(mask) = [];
equil_RZ.pTe(mask) = [];
equil_RZ.pne(mask) = [];
equil_RZ.pzTi(:,mask) = [];
equil_RZ.pzni(:,mask) = [];
equil_RZ.psi_apRp = psin_ext*psia_apRp;
%




