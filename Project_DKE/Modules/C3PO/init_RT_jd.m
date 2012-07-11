function xY = init_RT_jd(equil_fit,xrho,xtheta,xz,xomega,xNpar,xm,xkz,mmode,kmode,fluct_fit);
%
% This function solves the dispersion relation from initial positions and 
% wave characteristics to initiate ray-tracing calculations.
%
%   INPUTS :
%
%       - equil_fit: fitted axisymmetric magnetic equilibrium structure
%       - xrho: normalized minor radius positions [1,1]
%       - xtheta: poloidal positions (rad) [1,1]
%       - xz: axial or toroidal positions [m] [1,1]
%       - xomega: wave frequencies (rad/s) [1,1]
%       - xNpar: parallel indices of refraction [1,1]
%       - xm: poloidal mode numbers [1,1]
%       - xkz: axial or toroidal wave vector [1,1]
%       - xmode: cold plasma mode [1,1] : (-1) m (1) p 
%           p is the slow mode when kperp > 0 (ex : LH slow wave)
%       - sigma: direction of the wave propagation (outward, or inward)
%       - kmode: kinetic (1) or cold (0) plasma model
%       - fluct_fit: fluctuations of the magnetic equilibrium
%
%   OUTPUTS :
%
%       - xY: canonical coordinates vector [8,nx] decomposed into
%               - xpsin [1,1]
%               - xtheta (rad) [1,1]
%               - xz (rad) [1,1]
%               - xkrhon  [1,1]
%               - xm [1,1]
%               - xkz [1,1]
%               - xomega/clum (m^-1) [1,1]
%
%   By J. Decker DRFC-CEA <joan.decker@cea.fr> and Y. Peysson DRFC-CEA <yves.peysson@cea.fr>
%
if nargin < 9,
    error('Not enough input arguments')
end
%
if nargin < 10,
    kmode = 0;
end
%
if nargin < 11,
    fluct_fit = [];
end
%
%if abs(sigma) ~= 1,error('Parameter ''sigma'' for the wave direction atlaunch must be +1 or +1');end
%
if length(xtheta) ~= 1 | length(xz) ~= 1 | length(xomega) ~= 1 | length(xNpar) ~= 1 | length(xm) ~= 1 | length(xkz) ~= 1,,
    error('Input argument dimensions are not compatible');
end
%
xdxstardpsin = ppval(equil_fit.dxstardpsin_fit.pp_f,xrho);
%
zmi = equil_fit.zmi;
zZi = equil_fit.zZi;
if isfield(equil_fit,'Te_fit'),xTe = ppval(equil_fit.Te_fit.pp_f,xrho);else xTe = zeros(size(xrho));end
if isfield(equil_fit,'ne_fit'),xne = ppval(equil_fit.ne_fit.pp_f,xrho);else xne = zeros(size(xrho));end
if isfield(equil_fit,'zTi_fit'),zxTi = ppval(equil_fit.zTi_fit.pp_f,xrho);else zxTi = zeros(length(zZi),length(xrho));end
if isfield(equil_fit,'zni_fit'),zxni = ppval(equil_fit.zni_fit.pp_f,xrho);else zxni = zeros(length(zZi),length(xrho));end
%
x_a0_fit = ppval(equil_fit.x_fit.pp_a0,xrho);
x_an_fit = ppval(equil_fit.x_fit.pp_an,xrho);
x_bn_fit = ppval(equil_fit.x_fit.pp_bn,xrho);
%
y_a0_fit = ppval(equil_fit.y_fit.pp_a0,xrho);
y_an_fit = ppval(equil_fit.y_fit.pp_an,xrho);
y_bn_fit = ppval(equil_fit.y_fit.pp_bn,xrho);
%
Bx_a0_fit = ppval(equil_fit.Bx_fit.pp_a0,xrho);
Bx_an_fit = ppval(equil_fit.Bx_fit.pp_an,xrho);
Bx_bn_fit = ppval(equil_fit.Bx_fit.pp_bn,xrho);
%
By_a0_fit = ppval(equil_fit.By_fit.pp_a0,xrho);
By_an_fit = ppval(equil_fit.By_fit.pp_an,xrho);
By_bn_fit = ppval(equil_fit.By_fit.pp_bn,xrho);
%
Bz_a0_fit = ppval(equil_fit.Bz_fit.pp_a0,xrho);
Bz_an_fit = ppval(equil_fit.Bz_fit.pp_an,xrho);
Bz_bn_fit = ppval(equil_fit.Bz_fit.pp_bn,xrho);
%
% Build interpolated magnetic fields
%	
[xx,xdxdtheta] = calcval_yp(equil_fit,xtheta,x_a0_fit,x_an_fit,x_bn_fit);
[xy,xdydtheta] = calcval_yp(equil_fit,xtheta,y_a0_fit,y_an_fit,y_bn_fit);
[xBx] = calcval_yp(equil_fit,xtheta,Bx_a0_fit,Bx_an_fit,Bx_bn_fit);
[xBy] = calcval_yp(equil_fit,xtheta,By_a0_fit,By_an_fit,By_bn_fit);
[xBz] = calcval_yp(equil_fit,xtheta,Bz_a0_fit,Bz_an_fit,Bz_bn_fit);
%
sigmaIp =  sign(equil_fit.psia_apRp);%Sign of the plasma current
%
if isinf(equil_fit.Rp),
    Upsilon = 1.0;
else
    Upsilon = 1 + xx/equil_fit.Rp;%toroidal factor (1 -> cylindrical limit)
end
%
xr = sqrt(xx.^2 + xy.^2);
xs = (xx.*xdxdtheta + xy.*xdydtheta)./xr./sqrt(xdxdtheta.^2 + xdydtheta.^2);
xc = sqrt(1.0 - xs.^2);
xBp = sqrt(xBx.^2 + xBy.^2); 
xB = sqrt(xBz.^2 + xBp.^2);
xBsn = sigmaIp*xBp./xB;
xBzn = xBz./xB;
%
xgradrho = Upsilon.*xBp.*xdxstardpsin/abs(equil_fit.psia_apRp);
%
% Plasma fluctuations or modulations
%
xBrhon = 0;
%
if isstruct(fluct_fit),
   [fluctval] = fluctval_yp(equil_fit,fluct_fit,xrho,xtheta,xz);
   %
   xne = xne + xne*fluctval.ner;%tanh(x) is for limitating the perturbation between -1 and 1
   xTe = xTe + xTe*fluctval.Ter;
   zxni = zxni + zxni.*fluctval.znir;
   zxTi = zxTi + zxTi.*fluctval.zTir;
   %
   xcta = cos(xtheta).*xc + sin(xtheta).*xs;
   xsta = -cos(xtheta).*xs + sin(xtheta).*xc;
   %
   xBrho = xB*(xcta*fluctval.Bxr + xsta*fluctval.Byr);%normalized to unperturbed magnetic equilibrium
   xBs = xB*(xBsn + xcta*fluctval.Byr - xsta*fluctval.Bxr);%normalized to unperturbed magnetic equilibrium
   xBphi = xB*(xBzn + fluctval.Bzr);%normalized to unperturbed magnetic equilibrium
   %
   xB = sqrt(xBrho.^2 + xBs.^2 + xBz.^2);%perturbed magnetic field
   %
   xBrhon = xBrho/xB;%normalized to perturbed magnetic equilibrium
   xBsn = xBs/xB;%normalized to perturbed magnetic equilibrium
   xBzn = xBz/xB;%normalized to perturbed magnetic equilibrium
   %
end
%
% Resolution of the dispersion relation
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
sm = [me;mp*zmi(:)];
sZ = qe*[-1;zZi(:)];
sxn = [xne;zxni(:)];
sxT = [xTe;zxTi(:)];
%
xNperp = zeros(1,1);
%
% Cold plasma calculations
%
[Nperpp,Nperpm,dummy,...
    dummy,dummy,dummy,dummy,dummy,dummy,...
    phip_xyz,phim_xyz] = colddisp_dke_jd(xNpar,xomega,xne,zxni,zZi,zmi,xB);
%
if mmode == 1,
    Nperpc = Nperpm;
    phic_xyz = phim_xyz;
elseif mmode == -1,
    Nperpc = Nperpp;
    phic_xyz = phip_xyz;
else
    error('Wrong input in mmode')
end
%
% Sign for choosing the inward propagating root
%
sigma = -sign(phic_xyz(1));
%
% Normalization
%
if kmode == 2,
    sa = sZ.^2.*sxn./sm/e0/xomega^2;
    sy = sZ*xB./sm/xomega;
    sbeta = sqrt(qe*sxT./sm/clum^2);
%
%   Kinetic plasma calculations
%
    xNperp = kineticdisp_jd(sa,sy,sbeta,xNpar,Nperpc,0);
else
    xNperp = Nperpc;
end
%
xlambda = xc.*xBsn - xs.*xBrhon;
%
if isnan(xkz),%xm is specified at the plasma edge (tokamak case)
    if abs(xBrhon) < 1e-6,
        xkz = Upsilon.*(xNpar.*xomega/clum - xm.*xc.*xBsn./xr)./xBzn;
        xkrho = (xm.*xs./xr + sigma*sqrt(-(xm.*xc./xr).^2 - (xkz./Upsilon).^2 + (xNperp.^2 + xNpar.^2).*xomega.^2/clum^2))./xgradrho;
    else
        xdelta = xNpar.*xomega./clum - xm.*xlambda./xr;
        a = (1.0 - xBsn.*xBsn)./xBrhon./xBrhon;
        b = xBzn.*(xNpar.*xomega/clum - xm.*xBsn.*xc./xr)./xBrhon./xBrhon;
        c = (xNpar.*xomega/clum - xm.*xlambda./xr).^2*(1.0 - xBrhon.*xBrhon)./xBrhon./xBrhon + xm.*xm.*(1.0 - xlambda.*xlambda)./xr./xr - 2.0.*xm.*(xNpar.*xomega/clum - xm.*xlambda./xr).*(xs + xBrhon.*xlambda)./xr./xBrhon - (xNperp.*xomega/clum).^2;
        xkzp = Upsilon.*(b + sqrt(b.*b - a*c))/a;
        xkzm = Upsilon.*(b - sqrt(b.*b - a*c))/a;
        xkrhop = (-xkzp.*xBzn./Upsilon + xdelta)./xBrhon./xgradrho;
        xkrhom = (-xkzm.*xBzn./Upsilon + xdelta)./xBrhon./xgradrho;
        %
        if imag(xkrhop) ~= 0 & imag(xkrhom) ~= 0,
            error('The wave cannot propagate in the plasma. Let change the initial conditions.')
        else
            xkrhoroots = [xkrhop,xkrhom];
            xkzroots = [xkzp,xkzm];
            xkrho = xkrhoroots(find(xkrhoroots>0));%choice of the root for inward propagation
            xkz = xkzroots(find(xkrhoroots>0));
        end
        %
    end
elseif isnan(xm),%xkz is specified at the plasma edge (RFP case)
    if abs(xBrhon) < eps,
        xm = xr.*(xNpar.*xomega/clum - xkz.*xBzn./Upsilon)./xc./xBsn;
        xkrho = (xm.*xs./xr + sigma*sqrt(-(xm.*xc./xr).^2 - (xkz./Upsilon).^2 + (xNperp.^2 + xNpar.^2).*xomega.^2/clum^2))./xgradrho;
    else
        %TODO: calculation for RFP
        %xdelta = xNpar.*xomega./clum - xkz.*xBzn./Uspilon;
        %a = ;
        %b = ;
        %c = ;
        %xmp = xr.*(b + sqrt(b.*b - a*c))/a;
        %xmm = xr.*(b - sqrt(b.*b - a*c))/a;
        %xkrhop = (-xmp.*xlambda./xr + xdelta)./xBrhon./xgradrho;
        %xkrhom = (-xmm.*xlambda./xr + xdelta)./xBrhon./xgradrho;
        %
        if imag(xkrhop) ~= 0 & imag(xkrhom) ~= 0,
            error('The wave cannot propagate in the plasma. Let change the initial conditions.')
        else   
            if imag(xkrhop) == 0,
                xkrho = xkrhop;
                xm = xmp;
            else
                xkrho = xkrhom;
                xm = xmm;
            end
        end
    end
end
%
xY = [xrho;xtheta;xz;xkrho;xm;xkz;xomega];
%
% verification
%
if 1,
    xNpar2 = (xkrho*xgradrho.*xBrhon + xm.*xlambda./xr + xkz.*xBzn./Upsilon)*clum./xomega;
    %
    %xNperp2 = sqrt((xkrho*xgradrho - xs.*xm./xr).^2 + (xBzn.*xc.*xm./xr - xBsn.*xkz./Upsilon).^2)*clum./xomega;
    %
    xNperp2 = sqrt(xkrho.^2*xgradrho.^2.*(1.0 - xBrhon.^2) + xm.^2./xr.^2.*(1.0 - xlambda.^2) + xkz.^2./Upsilon.^2.*(1.0 - xBzn.^2) ... 
            - 2.0*xkrho.*xgradrho.*xkz./Upsilon.*xBrhon.*xBzn ...
            - 2.0*xm./xr.*(xkrho.*xgradrho.*(xs + xBrhon.*xlambda) + xlambda.*xkz.*xBzn./Upsilon))*clum./xomega;    
      
    [Nperpp2,Nperpm2,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk,sigmap,sigmam,Dp,Dm]...
        = colddisp_dke_jd(xNpar2,xomega,xne,zxni,zZi,zmi,xB,xNperp2);
    disp(['xNpar,xNperp,xNpar2,xNperp2,Dp,Dm:',num2str(xNpar),',',num2str(xNperp),',',num2str(xNpar2),',',num2str(xNperp2),',',num2str(Dp),',',num2str(Dm)]);
end
