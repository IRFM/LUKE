function [mtheta,xpsin,psia,XR,XZ,XBR,XBZ,XBphi,xB0,xR0,xBT0,xBp0,xrho,xTe,xne,xzTi,xzni,zZi,zmi,xZeff,Rp,Zp,ap,xmhu0T2,xdV_dke,xdA_dke] = ...
    equilibrium_jd(equil,xpsin,xpsin_S_dke,display_mode,method,mfactor)
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
%
%   OUTPUTS:
%
%       - theta: poloidal angle grid [1,ntheta]
%       - xpsin: normalized poloidal flux grid [1,nr]
%       - psia: poloidal flux at the edge [1,1]
%       - XR: major radius [nr,ntheta]
%       - XZ: elevation [nr,ntheta]
%       - XBR: B-field component in R direction [nr,ntheta]
%       - XBZ: B-field component in Z direction [nr,ntheta]
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
    mfactor = 10;%Factor for super theta grid
end
if nargin < 5
    method = 'linear';%Interpolation method 
end
if nargin < 4
    display_mode = 0;
end
if nargin < 3
    xpsin_S_dke = NaN;%no incremental volume or surface calculations
end
if nargin < 2
    xpsin = NaN;%the radial grid is the equilibrium grid
end
if nargin < 1
    error('no tokamak specified');
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;
%
[npsi,ntheta] = size(equil.R);
%
% FFT interpolation on R,Z, BR, BZ, BPHI as a function of theta (very precise, works for uniform theta grids only)
%
mtheta = 0:2*pi/((ntheta-1)*mfactor):2*pi*((ntheta-1)*mfactor-1)/((ntheta-1)*mfactor); %super theta grid
%
mR = interpft(equil.R(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
mZ = interpft(equil.Z(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
mBR = interpft(equil.BR(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
mBZ = interpft(equil.BZ(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
mBPHI = interpft(equil.BPHI(:,1:(ntheta-1))',(ntheta-1)*mfactor)'; %FFT interpolation
%
mtheta = [mtheta,2*pi]; %2*pi point retrieved (for future interpolation)
mR = [mR,mR(:,1)]; %2*pi point retrieved
mZ = [mZ,mZ(:,1)]; %2*pi point retrieved
mBR = [mBR,mBR(:,1)]; %2*pi point retrieved
mBZ = [mBZ,mBZ(:,1)]; %2*pi point retrieved
mBPHI = [mBPHI,mBPHI(:,1)]; %2*pi point retrieved
%
nmtheta = length(mtheta);
%
Rp = mR(1,1);%Major radius of magnetic Axis
Zp = mZ(1,1);%Elevation of magnetic Axis
%
Rmax = mR(npsi,1);%Major radius where the last close flux-surface crosses the LFS midplane
ap =  Rmax - Rp;%Plasma minor radius on the LFS midplane 
%
psia = equil.ppsi(npsi);%Poloidal flux at the edge
ppsin = equil.ppsi/psia;%Normalized poloidal flux
%
pZeff = sum(equil.pzni.*repmat((equil.zZi.^2)',[1,npsi]))./equil.pne;%Effective charge (a.u.)
%
if isnan(xpsin)
    xpsin = ppsin;
end
%
nr = length(xpsin);
%
% Interpolation of calculation grid
%
XR = interp1(ppsin,mR,xpsin,method);
XZ = interp1(ppsin,mZ,xpsin,method);
XBR = interp1(ppsin,mBR,xpsin,method);
XBZ = interp1(ppsin,mBZ,xpsin,method);
XBphi = interp1(ppsin,mBPHI,xpsin,method);
%
xrho = (XR(:,1)' - Rp)/ap;%Normalized radius on the horizontal LFS midplane                          
%
xTe = interp1(ppsin,equil.pTe,xpsin,method);
xne = interp1(ppsin,equil.pne,xpsin,method);
xzTi = interp1(ppsin,equil.pzTi',xpsin,method)';
xzni = interp1(ppsin,equil.pzni',xpsin,method)';
xZeff = interp1(ppsin,pZeff,xpsin,method);
%
XBT = abs(XBphi);%Toroidal B-field
XBp = sqrt(XBR.^2 + XBZ.^2);%Poloidal B-field
XB = sqrt(XBphi.^2 + XBR.^2 + XBZ.^2);%Total B-field
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
xR0 = XR(xiB0);%Major radius at B=Bmin
%
% FS volume and poloidal surface
%
if ~isnan(xpsin_S_dke)
% half grids in theta and psi (for trapezoidal integration avoiding singularities)
    hmtheta = (mtheta(1:nmtheta-1) + mtheta(2:nmtheta))/2;
    hppsin = (ppsin(1:npsi-1) + ppsin(2:npsi))/2;
    hmR = (mR(1:npsi-1,1:nmtheta-1) + mR(2:npsi,1:nmtheta-1) + mR(1:npsi-1,2:nmtheta) + mR(2:npsi,2:nmtheta))/4;
    hmZ = (mZ(1:npsi-1,1:nmtheta-1) + mZ(2:npsi,1:nmtheta-1) + mZ(1:npsi-1,2:nmtheta) + mZ(2:npsi,2:nmtheta))/4;
    hmBR = (mBR(1:npsi-1,1:nmtheta-1) + mBR(2:npsi,1:nmtheta-1) + mBR(1:npsi-1,2:nmtheta) + mBR(2:npsi,2:nmtheta))/4;
    hmBZ = (mBZ(1:npsi-1,1:nmtheta-1) + mBZ(2:npsi,1:nmtheta-1) + mBZ(1:npsi-1,2:nmtheta) + mBZ(2:npsi,2:nmtheta))/4;
    hmBPHI = (mBPHI(1:npsi-1,1:nmtheta-1) + mBPHI(2:npsi,1:nmtheta-1) + mBPHI(1:npsi-1,2:nmtheta) + mBPHI(2:npsi,2:nmtheta))/4;
%
    dpsi = abs(diff(ppsi));
    dmtheta = diff(mtheta);
% FS Volume
    hmFV = 2*pi*((hmR - Rp).^2 + (hmZ - Zp).^2)./abs(hmBR.*(hmZ - Zp) - hmBZ.*(hmR - Rp));
%
    pdV = integral_dke_jd(dmtheta,hmFV,2);
    spdV = triu(repmat(pdV,[1,npsi-1]));
    pV = [0,integral_dke_jd(dpsi,spdV,1)'];
%    
% FS poloidal surface
    hmFA = ((hmR - Rp).^2 + (hmZ - Zp).^2)./abs(hmBR.*(hmZ - Zp) - hmBZ.*(hmR - Rp))./hmR;
%
    pdA = integral_dke_jd(dmtheta,hmFA,2);
    spdA = triu(repmat(pdA,[1,npsi-1]));
    pA = [0,integral_dke_jd(dpsi,spdA,1)'];
%
% DKE FS volume and poloidal surface
    xV_S_dke = interp1(ppsin,pV,xpsin_S_dke,method);
    xA_S_dke = interp1(ppsin,pA,xpsin_S_dke,method);
%
% DKE FS invremental volume and poloidal surface
    xdV_dke = diff(xV_S_dke);
    xdA_dke = diff(xA_S_dke);
else
    xdV_dke = NaN;
    xdA_dke = NaN;
end
%
% Display of equilibrium properties
%
if display_mode >= 2
%    
    prho = (equil.R(:,1)' - Rp)/ap;
%
% displays the equilibrium profiles
%
    figure(50),clf
    set(gcf,'units','inches','position',[0.5,1,10,6]);
    set(gca,'position',[0,0,1,1]);
%
    subplot('position',[1/12,0.5+1/16,5/24,5/16])
        [ax] = graph1D_jd(prho,ppsin,0,0,'','','',NaN,[0,1],[-eps,1],'-','none','b',0.5);
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
%       
% displays the magnetic flux-surfaces geometry
%       
    srho = linspace(0,1,21);
    stheta = linspace(0,2*pi,31);
    sR = interp1(prho,mR,srho,method);  
    sZ = interp1(prho,mZ,srho,method); 
    stR = interp1(mtheta,mR',stheta,method)';  
    stZ = interp1(mtheta,mZ',stheta,method)';    
%
    Rmin = min(min(equil.R));
    Rmax = max(max(equil.R));
    Zmin = min(min(equil.Z));
    Zmax = max(max(equil.Z));
    %
    figure(51),clf
%    
    [ax] = graph1D_jd(sR',sZ',0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','r',2);pause(0.5)
    [ax] = graph1D_jd(stR,stZ,0,0,'R','Z','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',0.5);pause(0.5)
    axis('equal');    
end
    





