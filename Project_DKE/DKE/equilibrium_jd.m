function [equilDKE] = equilibrium_jd(equil,radialDKE,display,method,mfactor,fig_id)
%
%   This function interpolates the equilibrium data on the radial grid.
%
%   It first performs a very precise FFT-based interpolation in theta in
%   order to obtain precise future interpolation and integration
%   calculations in theta.
%
%   It also calculates several quantities linked to the equilibrium, such
%   as the trapped/passing boundary in momentum space, the plasma minor
%   radius on LFS midplane, and the effective charge. 
%
%   NOTE: The equilibrium data in EQUIL_tokname must follow these
%   conventions:
%
%       - R Z BR BZ BPHI must be given on a (psi,theta) grid [npsi,ntheta].
%       - ppsi(1) = 0 is the magnetic axis.
%       - ppsi(npsi) is the poloidal flux on the last closed flux-surface.
%           It can be either positive or negative depending on the sign of the
%           current with respect to the toroidal angle phi.
%       - theta(1) = 0 and theta(ntheta) = 2pi is required.
%       - The psi can be non-uniform. The theta grid MUST be uniform
%       - other equilibrium parameters (temperatures, densities) are
%           assumed to be uniform within a flux-surface, because of the fast parallel
%           motion. They are therefore given on the psi grid.
%
%   INPUTS:
%
%       - tokamak: tokamak scenario selected
%       - xpsin: positions for FP calculations on the normalized psi grid
%           (NAN: ppsi grid)
%       - xpsin_S_dke: radial flux grid used for the calculation of FS volume and poloidal surface 
%       - display_mode: (0-1) text only (2) graphics
%       - method: interpolation method (linear,cubic,spline,...) 
%           (default: linear)
%       - mfactor: factor for super theta grid (default: 50)
%       - fig_id: figure ID of figure for the magnetic equilibrium (default = 51)
%
%   OUTPUTS:
%
%       - theta: poloidal angle grid [1,ntheta]
%       - xpsin: normalized poloidal flux grid [1,nr]
%       - psia_apRp: Edge normalized cylindrical poloidal flux (Wb) [1,1]
%       - Xx: major radius [nr,ntheta]
%       - Xy: elevation [nr,ntheta]
%       - XBx: B-field component in R direction [nr,ntheta]
%       - XBy: B-field component in Z direction [nr,ntheta]
%       - XBPHI: B-field component in PHI direction [nr,ntheta]
%       - xB0: minimum magnetic field on a flux-surface [1,nr]
%       - xR0: corresponding major radius [1,nr]
%       - xBT0: corresponding toroidal field [1,nr]
%       - xBp0: corresponding poloidal field [1,nr]
%       - xrho: normalized radius on the horizontal LFS midplane [1,nr]
%       - xTe: electron temperature [1,nr]
%       - xne: electron density [1,nr]
%       - xzTi: ion temperatures [ni,nr]
%       - xzni: ion densities [ni,nr]
%       - zZi: ion charges [1,ni]
%       - zmi: ion masses [1,ni]
%       - xZeff: effective charge [1,nr]
%       - Rp: major radius on axis [1,1]
%       - Zp: elevation on axis [1,1]
%       - ap: minor radius on LFS midplane [1,1]
%       - Ip: Toroidal plasma current [1,1]
%       - Ncoils: Number of toroidal magnetic field coils [1,1]
%       - BeLi: Beta + li/2 [1,1]
%       - xmhu0T2: pitch-angle (squared) at the trapped/passing boundary [1,nr]
%       - xdV_dke: incremental FS volume at dke positions
%       - xdA_dke: incremental FS poloidal surface at dke positions
%       - HXR: Fast electron bremsstrahlung
%
%   By J. Decker RLE-MIT <jodecker@alum.mit.edu> and Y. Peysson DRFC-CEA <yves.peysson@cea.fr>
%
if nargin < 6
    fig_id = 51;%Factor for super theta grid
    flag_id = 1;
else
    flag_id = 0;
end
if nargin < 5
    mfactor = 10;%Factor for super theta grid 
end
if nargin < 4
    method = 'linear';%Interpolation method 
end
if nargin < 3
    display_mode = 0;
elseif ~isstruct(display)
    display_mode = display;
else
    display_mode = display.display_mode;
end
if nargin < 2 | ~isstruct(radialDKE),
    xpsin_S_dke = NaN;%no incremental volume or surface calculations
    xpsin = NaN;%the radial grid is the equilibrium grid
else
    xpsin_S_dke = radialDKE.xpsin_S_dke;
    xpsin = radialDKE.xpsin_f;
end
if nargin < 1,
    error('Not enough input arguments in equilibrium_jd.m');
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;
%
% CASE OF LOCAL CALCULATION INDEPENDENT OF ANY ACTUAL TOKAMAK GENOMETRY
%
[npsi,ntheta] = size(equil.ptx);
%
if strcmp(equil.id,'LOCAL')
    mtheta = equil.theta;
    psin = equil.psi;
    if isnan(xpsin)
        xpsin = psin;
    end
    nr = length(xpsin);
    psia = NaN;
    %
    XR = interp1(ppsin,equil.R,xpsin,'linear');
    XZ = interp1(ppsin,equil.Z,xpsin,'linear');
    XBR = interp1(ppsin,equil.BR,xpsin,'linear');
    XBZ = interp1(ppsin,equil.BZ,xpsin,'linear');
    XBphi = interp1(ppsin,equil.BPHI,xpsin,'linear');
    xB0 = equil.BR(2,1);
    xBT0 = xB0;
    xBp0 = xB0;
    xrho = interp1(ppsin,equil.prho,xpsin,'linear');
    xTe = interp1(ppsin,equil.pTe,xpsin,'linear');
    xne = interp1(ppsin,equil.pne,xpsin,'linear');
    xzTi = interp1(ppsin,equil.pzTi',xpsin,'linear')';
    xzni = interp1(ppsin,equil.pzni',xpsin,'linear')';
    zZi = equil.zZi;
    zmi = equil.zmi;
    Rp = equil.R(1,1);
    Zp = equil.Z(1,1);
    xR0 = equil.R(2,1);
    ap = xR0-Rp;
    %
    xmhu0T2 = interp1(ppsin,equil.pmhu0T2,xpsin,'linear');
    xmhu0T2_new = 2*(xR0-Rp)/xR0;
    if abs(xmhu0T2_new - xmhu0T2)>1e-4
        error('something is wrong in the geometry')
    else
        xmhu0T2 = xmhu0T2_new;
    end
    xdV_dke = equil.xdV_dke;
    xdA_dke = equil.xdA_dke;
%    
    xZeff = sum(xzni.*repmat((zZi.^2)',[1,nr]))./xne;%Effective charge (a.u.)
%
    return
end
%
% FFT interpolation on R,Z, BR, BZ, BPHI as a function of theta (very precise, works for uniform theta grids only)
%
mtheta = 0:2*pi/((ntheta-1)*mfactor):2*pi*((ntheta-1)*mfactor-1)/((ntheta-1)*mfactor); %super theta grid
%
mx = interpft(equil.ptx(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
my = interpft(equil.pty(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
mBx = interpft(equil.ptBx(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
mBy = interpft(equil.ptBy(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
mBPHI = interpft(equil.ptBPHI(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
%
mtheta = [mtheta,2*pi]; %2*pi point retrieved (for future interpolation)
mx = [mx,mx(:,1)]; %2*pi point retrieved
my = [my,my(:,1)]; %2*pi point retrieved
mBx = [mBx,mBx(:,1)]; %2*pi point retrieved
mBy = [mBy,mBy(:,1)]; %2*pi point retrieved
mBPHI = [mBPHI,mBPHI(:,1)]; %2*pi point retrieved
%
nmtheta = length(mtheta);
%
Rp = equil.Rp;%Major radius of magnetic Axis
Zp = equil.Zp;%Elevation of magnetic Axis
%
ap =  mx(npsi,1);%Plasma minor radius on the LFS midplane 
%
psia_apRp = equil.psi_apRp(npsi);%Poloidal flux at the edge
psin = equil.psi_apRp/psia_apRp;%Normalized poloidal flux
%
pZeff = sum(equil.pzni.*repmat((equil.zZi.^2)',[1,npsi]))./equil.pne;%Effective charge (a.u.)
%
if isnan(xpsin)
    xpsin = psin;
end
if isnan(xpsin_S_dke)
    xpsin_S_dke = psin;
end
%
nr = length(xpsin);
%
% Interpolation of calculation grid
%
Xx = interp1(psin,mx,xpsin,method);
Xy = interp1(psin,my,xpsin,method);
XBx = interp1(psin,mBx,xpsin,method);
XBy = interp1(psin,mBy,xpsin,method);
XBphi = interp1(psin,mBPHI,xpsin,method);
%
xrho = Xx(:,1)'/ap;%Normalized radius on the horizontal LFS midplane                          
%
xTe = interp1(psin,equil.pTe,xpsin,method);
xne = interp1(psin,equil.pne,xpsin,method);
xzTi = interp1(psin,equil.pzTi.',xpsin,method).';
xzni = interp1(psin,equil.pzni.',xpsin,method).';
xZeff = interp1(psin,pZeff,xpsin,method);
%
XBT = abs(XBphi);%Toroidal B-field
XBp = sqrt(XBx.^2 + XBy.^2);%Poloidal B-field
XB = sqrt(XBphi.^2 + XBx.^2 + XBy.^2);%Total B-field
%
%index 0 refers to the minimum of the magnetic field
%
[xB0,xiB0] = min(XB'); %Minimum of B on flux surface
xBmax = max(XB'); %Maximum of B on flux surface
%
xmhu0T2 = 1 - xB0./xBmax; %Pitch-angle (squared) at the trapped-passing boundary
%
xiB0 = (xiB0 - 1)*nr + (1:nr);%Indices in (psi,theta) grid corresponding of B=Bmin
xBT0 = XBT(xiB0);%Toroidal field at B=Bmin
xBp0 = XBp(xiB0);%Poroidal field at B=Bmin
xx0 = Xx(xiB0);%Major radius at B=Bmin
%
% FS volume and poloidal surface
%
if ~isnan(xpsin_S_dke)
% half grids in theta and psi (for trapezoidal integration avoiding singularities)
    hmtheta = (mtheta(1:nmtheta-1) + mtheta(2:nmtheta))/2;
    hppsin = (psin(1:npsi-1) + psin(2:npsi))/2;
    hmx = (mx(1:npsi-1,1:nmtheta-1) + mx(2:npsi,1:nmtheta-1) + mx(1:npsi-1,2:nmtheta) + mx(2:npsi,2:nmtheta))/4;
    hmy = (my(1:npsi-1,1:nmtheta-1) + my(2:npsi,1:nmtheta-1) + my(1:npsi-1,2:nmtheta) + my(2:npsi,2:nmtheta))/4;
    hmBx = (mBx(1:npsi-1,1:nmtheta-1) + mBx(2:npsi,1:nmtheta-1) + mBx(1:npsi-1,2:nmtheta) + mBx(2:npsi,2:nmtheta))/4;
    hmBy = (mBy(1:npsi-1,1:nmtheta-1) + mBy(2:npsi,1:nmtheta-1) + mBy(1:npsi-1,2:nmtheta) + mBy(2:npsi,2:nmtheta))/4;
    hmBPHI = (mBPHI(1:npsi-1,1:nmtheta-1) + mBPHI(2:npsi,1:nmtheta-1) + mBPHI(1:npsi-1,2:nmtheta) + mBPHI(2:npsi,2:nmtheta))/4;
%
    dpsi = abs(diff(equil.psi_apRp));
    dmtheta = diff(mtheta);
% FS Volume per 2pi*Rp
    hmFV_2piRp = (hmx.^2 + hmy.^2)./abs(hmBx.*hmy - hmBy.*hmx)/ap;
%
    pdV_2piRp = integral_dke_jd(dmtheta,hmFV_2piRp,2);
    spdV_2piRp = triu(repmat(pdV_2piRp,[1,npsi-1]));
    pV_2piRp = [0,integral_dke_jd(dpsi,spdV_2piRp,1)'];
%    
% FS poloidal surface
    hmFA = (hmx.^2 + hmy.^2)./abs(hmBx.*hmy - hmBy.*hmx)./(1 + hmx/Rp)/ap;
%
    pdA = integral_dke_jd(dmtheta,hmFA,2);
    spdA = triu(repmat(pdA,[1,npsi-1]));
    pA = [0,integral_dke_jd(dpsi,spdA,1)'];
%
% DKE FS volume and poloidal surface
    xV_2piRp_S_dke = interp1(psin,pV_2piRp,xpsin_S_dke,method);
    xA_S_dke = interp1(psin,pA,xpsin_S_dke,method);
%
% DKE FS invremental volume and poloidal surface
    xdV_2piRp_dke = diff(xV_2piRp_S_dke);
    xdA_dke = diff(xA_S_dke);
else
    xdV_2piRp_dke = NaN;
    xdA_dke = NaN;
end
%
% Display of equilibrium properties
%
if display_mode >= 2,
%    
    prho = mx(:,1)'/ap;
%
% displays the equilibrium profiles
%
    if flag_id, 
       figure('Name','Magnetic equilibrium profile parameters'),clf
       set(gcf,'units','inches','position',[0.5,1,10,6]);
       set(gca,'position',[0,0,1,1]);
%
       subplot('position',[1/12,0.5+1/16,5/24,5/16])
          [ax] = graph1D_jd(prho,psin,0,0,'','','',NaN,[0,1],[-eps,1],'-','none','b',0.5);
          [ax] = graph1D_jd(xrho,xpsin,0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'none','+','r',2);
       subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
          [ax] = graph1D_jd(prho,equil.pTe,0,0,'','','',NaN,[0,1],[-eps,max(equil.pTe)],'-','none','b',0.5);
          [ax] = graph1D_jd(xrho,xTe,0,0,'\rho','T_e (keV)',equil.id,NaN,[0,1],[-eps,max(equil.pTe)],'none','+','r',2);
       subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
          [ax] = graph1D_jd(prho,equil.pne/1e19,0,0,'','','',NaN,[0,1],[-eps,max(equil.pne/1e19)],'-','none','b',0.5);
          [ax] = graph1D_jd(xrho,xne/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil.pne/1e19)],'none','+','r',2);
       subplot('position',[1/12,1/8,5/24,5/16])
          [ax] = graph1D_jd(prho,equil.pzTi,0,0,'','','',NaN,[0,1],[-eps,max(max(equil.pzTi))],'-','none','b',0.5);
          [ax] = graph1D_jd(xrho,xzTi,0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil.pzTi))],'none','+','r',2);
       subplot('position',[1/3+1/12,1/8,5/24,5/16])
          [ax] = graph1D_jd(prho,equil.pzni/1e19,0,0,'','','',NaN,[0,1],[-eps,max(max(equil.pzni/1e19))],'-','none','b',0.5);
          [ax] = graph1D_jd(xrho,xzni/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil.pzni/1e19))],'none','+','r',2);
       subplot('position',[2/3+1/12,1/8,5/24,5/16])
          [ax] = graph1D_jd(prho,pZeff,0,0,'','','',NaN,[0,1],[-eps,max(pZeff)],'-','none','b',0.5);
          [ax] = graph1D_jd(xrho,xZeff,0,0,'\rho','Z_{eff}','',NaN,[0,1],[-eps,max(pZeff)],'none','+','r',2);
    end
%       
% displays the magnetic flux-surfaces geometry
%       
    srho = linspace(0,1,21);
    stheta = linspace(0,2*pi,31);
    sx = interp1(prho,mx,srho,method);  
    sy = interp1(prho,my,srho,method); 
    stx = interp1(mtheta,mx',stheta,method)';  
    sty = interp1(mtheta,my',stheta,method)';    
%
    xmin = min(min(equil.ptx));
    xmax = max(max(equil.ptx));
    ymin = min(min(equil.pty));
    ymax = max(max(equil.pty));
   
    %
    figure('Name','Magnetic equilibrium flux surface contour'),clf
%    
    [ax] = graph1D_jd(sx',sy',0,0,'','','',NaN,[xmin,xmax],[ymin,ymax],'-','none','r',2);drawnow
    [ax] = graph1D_jd(stx,sty,0,0,'x(m)','y(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[xmin,xmax],[ymin,ymax],'-','none','b',0.5);
    axis('equal');drawnow  
end
%
zZi = equil.zZi;
zmi = equil.zmi;
%
if display_mode >=1,
    disp('-------------------------------------------------------------------------------------------------------------------');
    disp(['- Scenario name = ',equil.id]);
    disp('-------------------------------------------------------------------------------------------------------------------');
	disp(['------------------------------------- Tokamak magnetic equilibrium parameters ------------------------------------']);
	disp(['- Plasma minor radius on LFS midplane (m) ap = ',num2str(ap)]);
	disp(['- Plasma major radius on axis (m) Rp = ',num2str(Rp)]);
	disp(['- Plasma elevation on axis (m) Zp = ',num2str(Zp)]);
	disp(['- Edge normalized cylindrical poloidal flux (Wb) = ',num2str(psia_apRp)]);
	disp('-------------------------------------------------------------------------------------------------------------------');
end
%
equilDKE.tokname = equil.id;
equilDKE.mtheta = mtheta;
equilDKE.xpsin = xpsin;
equilDKE.psia_apRp = psia_apRp;
equilDKE.Xx = Xx;
equilDKE.Xy = Xy;
equilDKE.XBx = XBx;
equilDKE.XBy = XBy;
equilDKE.XBphi = XBphi;
equilDKE.xB0 = xB0;
equilDKE.xx0 = xx0;
equilDKE.xBT0 = xBT0;
equilDKE.xBp0 = xBp0;
equilDKE.xrho = xrho;
equilDKE.xTe = xTe;
equilDKE.xne = xne;
equilDKE.xzTi = xzTi;
equilDKE.xzni = xzni;
equilDKE.zZi = zZi;
equilDKE.zmi = zmi;
equilDKE.xZeff = xZeff;
equilDKE.Rp = Rp;
equilDKE.Zp = Zp;
equilDKE.ap = ap;
equilDKE.xmhu0T2 = xmhu0T2;
equilDKE.xdV_2piRp_dke = xdV_2piRp_dke;
equilDKE.xdA_dke = xdA_dke;


