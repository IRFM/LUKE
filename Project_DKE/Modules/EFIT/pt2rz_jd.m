function equil_RZ = pt2rz_jd(equil,xlim,ylim)
%
np = length(equil.psi_apRp);
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
    ylim = [min(pty(end,:)),max(pty(end,:))];
end
%
if nargin < 2,
    xlim = [min(ptx(end,:)),max(ptx(end,:))];
end
%
if xlim(1) < -equil.Rp,
    error('xlim(1) + equil.Rp < 0 is impossible')
end
%
equil_RZ.x = linspace(xlim(1),xlim(2),np);
equil_RZ.y = linspace(ylim(1),ylim(2),np);
%
psia_apRp = equil.psi_apRp(end);
psin = equil.psi_apRp/psia_apRp;
%
dpsin = psin(end) - psin(end-1);
dsdpsin_min = min(sqrt((ptx(end,:) - ptx(end-1,:)).^2 + (pty(end,:) - pty(end-1,:)).^2))/dpsin;
psin_max = 1 + sqrt((xlim(2) - xlim(1)).^2 + (ylim(2) - ylim(1)).^2)/dsdpsin_min;
psin_ext = [psin,1 + dpsin:dpsin:psin_max];
%
ptx_ext = interp1(psin,ptx,psin_ext,'linear','extrap');
pty_ext = interp1(psin,pty,psin_ext,'linear','extrap');
ptBx_ext = interp1(psin,equil.ptBx,psin_ext,'linear','extrap');
ptBy_ext = interp1(psin,equil.ptBy,psin_ext,'linear','extrap');
ptBPHI_ext = interp1(psin,equil.ptBPHI,psin_ext,'linear','extrap');
%
psi_apRp_ext =  psia_apRp*repmat(psin_ext.',[1,length(equil.theta)]);
%
warning('off')
%
equil_RZ.xyBx = griddata(ptx_ext,pty_ext,ptBx_ext,equil_RZ.x,equil_RZ.y.').';
equil_RZ.xyBy = griddata(ptx_ext,pty_ext,ptBy_ext,equil_RZ.x,equil_RZ.y.').';
equil_RZ.xyBPHI = griddata(ptx_ext,pty_ext,ptBPHI_ext,equil_RZ.x,equil_RZ.y.').';
equil_RZ.xypsi_apRp = griddata(ptx_ext,pty_ext,psi_apRp_ext,equil_RZ.x,equil_RZ.y.').';
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




