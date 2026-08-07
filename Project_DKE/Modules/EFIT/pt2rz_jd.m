% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function equil_RZ = pt2rz_jd(equil,x,y,nprz,method)
%
[np,nt] = size(equil.ptx);
%
if nargin < 5,
	method = 'linear';
end
%
if nargin < 4 || isempty(nprz),
	nprz = np;
end
%
equil_RZ.psi_apRp = equil.psi_apRp;
equil_RZ.ap = equil.ptx(end,1);
equil_RZ.Rp = equil.Rp;
equil_RZ.Zp = equil.Zp;
if isfield(equil,'zZi')
    equil_RZ.zZi = equil.zZi;
end
if isfield(equil,'zmi')
    equil_RZ.zmi = equil.zmi;
end
if isfield(equil,'id')
    equil_RZ.id = equil.id;
else
    equil.id = '';
    equil_RZ.id = '';
end
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
if isfield(equil,'ptr')
    ptr_ext = interp1(psin,equil.ptr,psin_ext,'linear','extrap');
end
%
if isfield(equil,'ptB')
    ptB_ext = interp1(psin,equil.ptB,psin_ext,'linear','extrap');
end
%
if isfield(equil,'ptdBdtheta')
    ptdBdtheta_ext = interp1(psin,equil.ptdBdtheta,psin_ext,'linear','extrap');
end
%
if isfield(equil,'ptBP')
    ptBP_ext = interp1(psin,equil.ptBP,psin_ext,'linear','extrap');
end
%
if isfield(equil,'ptdBPdtheta')
    ptdBPdtheta_ext = interp1(psin,equil.ptdBPdtheta,psin_ext,'linear','extrap');
end

%
if isfield(equil,'ptcalpha')
    ptcalpha_ext = interp1(psin,equil.ptcalpha,psin_ext,'linear','extrap');
end
%
if isfield(equil,'ptsalpha')
    ptsalpha_ext = interp1(psin,equil.ptsalpha,psin_ext,'linear','extrap');
end
%
if isfield(equil,'ptgradrho')
    ptgradrho_ext = interp1(psin,equil.ptgradrho,psin_ext,'linear','extrap');
end
%
if isfield(equil,'ptUpsilon')
    ptUpsilon_ext = interp1(psin,equil.ptUpsilon,psin_ext,'linear','extrap');
end
%
psi_apRp_ext =  psia_apRp*repmat(psin_ext.',[1,nt]);
%
warning('off')
%
equil_RZ.Bx = griddata(ptx_ext,pty_ext,ptBx_ext,equil_RZ.x,equil_RZ.y.',method).';
equil_RZ.By = griddata(ptx_ext,pty_ext,ptBy_ext,equil_RZ.x,equil_RZ.y.',method).';
equil_RZ.BPHI = griddata(ptx_ext,pty_ext,ptBPHI_ext,equil_RZ.x,equil_RZ.y.',method).';
equil_RZ.xypsi_apRp = griddata(ptx_ext,pty_ext,psi_apRp_ext,equil_RZ.x,equil_RZ.y.',method).';
%
if isfield(equil,'ptr')
    equil_RZ.r = griddata(ptx_ext,pty_ext,ptr_ext,equil_RZ.x,equil_RZ.y.',method).';
end
%
if isfield(equil,'ptB')
    equil_RZ.B = griddata(ptx_ext,pty_ext,ptB_ext,equil_RZ.x,equil_RZ.y.',method).';
end
%
if isfield(equil,'ptdBdtheta')
    equil_RZ.dBdtheta = griddata(ptx_ext,pty_ext,ptdBdtheta_ext,equil_RZ.x,equil_RZ.y.',method).';
end
%
if isfield(equil,'ptBP')
    equil_RZ.BP = griddata(ptx_ext,pty_ext,ptBP_ext,equil_RZ.x,equil_RZ.y.',method).';
end
%
if isfield(equil,'ptdBPdtheta')
    equil_RZ.dBPdtheta = griddata(ptx_ext,pty_ext,ptdBPdtheta_ext,equil_RZ.x,equil_RZ.y.',method).';
end
%
if isfield(equil,'ptcalpha')
    equil_RZ.calpha = griddata(ptx_ext,pty_ext,ptcalpha_ext,equil_RZ.x,equil_RZ.y.',method).';
end
%
if isfield(equil,'ptsalpha')
    equil_RZ.salpha = griddata(ptx_ext,pty_ext,ptsalpha_ext,equil_RZ.x,equil_RZ.y.',method).';
end
%
if isfield(equil,'ptgradrho')
    equil_RZ.gradrho = griddata(ptx_ext,pty_ext,ptgradrho_ext,equil_RZ.x,equil_RZ.y.',method).';
end
%
if isfield(equil,'ptUpsilon')
    equil_RZ.Upsilon = griddata(ptx_ext,pty_ext,ptUpsilon_ext,equil_RZ.x,equil_RZ.y.',method).';
end
%
warning('on')
%
if isfield(equil,'pTe')
    equil_RZ.pTe = interp1(psin,equil.pTe,psin_ext,'linear','extrap');
end
if isfield(equil,'pne')
    equil_RZ.pne = interp1(psin,equil.pne,psin_ext,'linear','extrap');
end
if isfield(equil,'pzTi')
    equil_RZ.pzTi = interp1(psin,equil.pzTi.',psin_ext,'linear','extrap').';
end
if isfield(equil,'pzni')
    equil_RZ.pzni = interp1(psin,equil.pzni.',psin_ext,'linear','extrap').';
end
%
if isfield(equil,'pTe')
    equil_RZ.pTe(equil_RZ.pTe < 0) = 0;
end
if isfield(equil,'pne')
    equil_RZ.pne(equil_RZ.pne < 0) = 0;
end
if isfield(equil,'pzTi')
    equil_RZ.pzTi(equil_RZ.pzTi < 0) = 0;
end
if isfield(equil,'pzni')
    equil_RZ.pzni(equil_RZ.pzni < 0) = 0;
end
%
if isfield(equil,'pTe') & isfield(equil,'pne') & isfield(equil,'pzTi') & isfield(equil,'pzni'),
    mask = equil_RZ.pTe == 0 & equil_RZ.pne == 0 & sum(equil_RZ.pzTi,1) == 0 & sum(equil_RZ.pzni,1) == 0;
    psin_ext(mask) = [];
end
%
if isfield(equil,'pTe')
    equil_RZ.pTe(mask) = [];
end
if isfield(equil,'pne')
    equil_RZ.pne(mask) = [];
end
if isfield(equil,'pzTi')
    equil_RZ.pzTi(:,mask) = [];
end
if isfield(equil,'pzni')
    equil_RZ.pzni(:,mask) = [];
end
equil_RZ.psi_apRp = psin_ext*psia_apRp;
%




