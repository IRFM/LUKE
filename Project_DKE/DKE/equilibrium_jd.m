function [varargout] = equilibrium_jd(equil,radialDKE,display,method,mfactor,axs,font)
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
%       - method: interpolation method (linear,pchip,spline,...) 
%           (default: linear)
%       - mfactor: factor for super theta grid (default: 50)
%       - axs: list of axes to update
%       - font : structure containing font parameters for graphs
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
%       - Bax: magnetic field on axis [1,1]
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
if nargin < 7,
    font = struct;
end
if nargin < 6,% individual figures are created
    flag_id = true;
    flag_consistency = true;
else% graphs added to current object
    flag_consistency = false;
    if isnan(axs)
        flag_id = true;
        clear axs
    else
        flag_id = false;
    end
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
if nargin < 2,
    radialDKE = NaN;
end
if nargin < 1,
    error('Not enough input arguments in equilibrium_jd.m');
end
%
if isnan(method) || isempty(method),
    method = 'linear';
end
%
if isnan(mfactor) || isempty(mfactor),
    mfactor = 10;
end
%
if isstruct(radialDKE),
    xpsin_S_dke = radialDKE.xpsin_S_dke;
    xpsin = radialDKE.xpsin_f;
elseif length(radialDKE) > 1,
    xpsin_S_dke = radialDKE;
    xpsin = (xpsin_S_dke(1:end-1) + xpsin_S_dke(2:end))/2;
else
    xpsin_S_dke = NaN;%no incremental volume or surface calculations
    xpsin = NaN;%the radial grid is the equilibrium grid
end
%
% CASE OF LOCAL CALCULATION INDEPENDENT OF ANY ACTUAL TOKAMAK GENOMETRY
%
[npsi,ntheta] = size(equil.ptx);
%
Rp = equil.Rp;%Major radius of magnetic Axis
Zp = equil.Zp;%Elevation of magnetic Axis
Bax = equil.ptBPHI(1,1);%magnetic field on axis
%
if strcmp(equil.id,'LOCAL'),
    %
    % Note that circular flux-surfaces are assumed in this case
    %
    if npsi ~= 1 || ntheta ~= 1,
        error('LOCAL is reserved for equilibria with one (psi,theta) position only')
    end
    if isnan(xpsin)
        %disp('WARNING : xpsin is enforced to the value 0.5')
        xpsin = 0.5;
    end
    %    
    theta = equil.theta;
    %
    xBT = abs(equil.ptBPHI);%Toroidal B-field
    xBp = sqrt(equil.ptBx.^2 + equil.ptBy.^2);%Poloidal B-field
    xB = sqrt(xBT.^2 + xBp.^2);%Total B-field
    %
    %index 0 refers to the minimum of the magnetic field
    %
    xr = sqrt(equil.ptx.^2 + equil.pty.^2);
    ep = xr/equil.Rp;
    xB0 = xB*(1 + ep*cos(theta))/(1 + ep);
    xBT0 = xBT*(1 + ep*cos(theta))/(1 + ep);%Toroidal field at B=Bmin
    xBp0 = xBp*(1 + ep*cos(theta))/(1 + ep);%Poroidal field at B=Bmin
    %
    xBmax = xB*(1 + ep*cos(theta))/(1 - ep);
    xmhu0T2 = 1 - xB0./xBmax; %Pitch-angle (squared) at the trapped-passing boundary
    %
    xx0 = xr;%
    %
    xrho = xpsin;
    xZeff = sum(equil.pzni.*equil.zZi.'.^2)./equil.pne;%Effective charge (a.u.)
    %
    ap = xr/xrho;
    xdV_2piRp_dke = NaN;
    xdA_dke = NaN;
    %
    equilDKE.tokname = equil.id;
    equilDKE.mtheta = theta;
    equilDKE.xpsin = xpsin;
    equilDKE.psia_apRp = equil.psi_apRp(end);
    equilDKE.Xx = equil.ptx;
    equilDKE.Xy = equil.pty;
    equilDKE.XBx = equil.ptBx;
    equilDKE.XBy = equil.ptBy;
    equilDKE.XBphi = equil.ptBPHI;
    equilDKE.xB0 = xB0;
    equilDKE.xx0 = xx0;
    equilDKE.xBT0 = xBT0;
    equilDKE.xBp0 = xBp0;
    equilDKE.xrho = xrho;
    equilDKE.xTe = equil.pTe;
    equilDKE.xne = equil.pne;
    equilDKE.xzTi = equil.pzTi;
    equilDKE.xzni = equil.pzni;
    equilDKE.zZi = equil.zZi;
    equilDKE.zmi = equil.zmi;
    equilDKE.xZeff = xZeff;
    equilDKE.Rp = equil.Rp;
    equilDKE.Zp = equil.Zp;
    equilDKE.Bax = Bax;
    equilDKE.ap = ap;
    equilDKE.xmhu0T2 = xmhu0T2;
    equilDKE.xdV_2piRp_dke = xdV_2piRp_dke;
    equilDKE.xdA_dke = xdA_dke;
    %
    return
end
%
% FFT interpolation on R,Z, BR, BZ, BPHI as a function of theta (very precise, works for uniform theta grids only)
%
tpx = equil.ptx(:,1:(ntheta-1)).';
tpy = equil.pty(:,1:(ntheta-1)).';
tpBx = equil.ptBx(:,1:(ntheta-1)).';
tpBy = equil.ptBy(:,1:(ntheta-1)).';
tpBPHI = equil.ptBPHI(:,1:(ntheta-1)).';
%
if Rp < Inf,
    %
    % extrema removal
    %
    nc = (ntheta-1)/2 + 1;%central fft point
    %
    tol = 0.1;% tolerance on magnetic field variations
    %
    tpB0 = sqrt(tpBx.^2 + tpBy.^2 + tpBPHI.^2);% total magnetic field
    %
    opt_extr = 3;%1+1i;%
    %
    if real(opt_extr) == 1,
        %
        % Try cutting off high theta harmonics if there are secondary extrema
        %
        for t = 1:nc,
            %
            tpB = sqrt(tpBx.^2 + tpBy.^2 + tpBPHI.^2);% total magnetic field
            %
            var = max(max(abs(tpB - tpB0)./tpB0));
            %
            extr_ind = diff(sign(diff([tpB(end,:);tpB;tpB(1,:)]))) ~= 0;
            nextr = sum(extr_ind);
            %
            if t == nc || var > tol || all(nextr <= 2),
                break
            end
            %
            ftpx = fft(tpx);
            ftpy = fft(tpy);
            ftpBx = fft(tpBx);
            ftpBy = fft(tpBy);
            ftpBPHI = fft(tpBPHI);
            %
            mask = (nc - t + 1):(nc + t - 1);
            %
            ftpx(mask,:) = 0;
            ftpy(mask,:) = 0;
            ftpBx(mask,:) = 0;
            ftpBy(mask,:) = 0;
            ftpBPHI(mask,:) = 0;
            %
            tpx = ifft(ftpx);
            tpy = ifft(ftpy);
            tpBx = ifft(ftpBx);
            tpBy = ifft(ftpBy);
            tpBPHI = ifft(ftpBPHI);
            %
        end
        %
        if t > 1,
            if var > tol || ~all(nextr <= 2),
                %
                disp(['Secondary extrema removal using Fourier filtering failed at  ',num2str(t - 1),'/',num2str(nc - 1),' harmonics.'])
                %
                if imag(opt_extr) == 1,
                    opt_extr = opt_extr + 1;
                end
                %
            else
                disp(['Secondary extrema removal suceeded after cutting ',num2str(t - 1),'/',num2str(nc - 1),' harmonics.'])
            end
            %
            disp(['  -> variations on B : ',num2str(var),'/',num2str(tol),'.'])
        end
        %
    end
    %
    if real(opt_extr) == 2,        
        %
        % Try smoothing the poloidal field components to remove secondary extrema
        %
        tpx = equil.ptx(:,1:(ntheta-1)).';
        tpy = equil.pty(:,1:(ntheta-1)).';
        tpBx = equil.ptBx(:,1:(ntheta-1)).';
        tpBy = equil.ptBy(:,1:(ntheta-1)).';
        tpBPHI = equil.ptBPHI(:,1:(ntheta-1)).';
        %
        thetah = equil.theta(1:ntheta-1);
        dtheta = 2*pi/(ntheta-1);
        %
        for t = 1:nc,
            %
            tpB = sqrt(tpBx.^2 + tpBy.^2 + tpBPHI.^2);% total magnetic field
            %
            var = max(max(abs(tpB - tpB0)./tpB0));
            %
            extr_ind = diff(sign(diff([tpB(end,:);tpB;tpB(1,:)]))) ~= 0;
            nextr = sum(extr_ind);
            %
            if t == nc || var > tol || all(nextr <= 2),
                break
            end
            %
            tpBx3 = smooth_jd([thetah-2*pi,thetah,thetah+2*pi],[tpBx;tpBx;tpBx],dtheta*t);
            tpBy3 = smooth_jd([thetah-2*pi,thetah,thetah+2*pi],[tpBy;tpBy;tpBy],dtheta*t);
            tpBx = tpBx3(ntheta:2*(ntheta-1),:);
            tpBy = tpBy3(ntheta:2*(ntheta-1),:);
            %
        end
        %
        if t > 1,
            if var > tol || ~all(nextr <= 2),
                %
                disp(['Secondary extrema removal using Gaussian smoothing failed at width ',num2str(dtheta*(t - 1)),'/pi.'])
                %
                if imag(opt_extr) == 1,
                    opt_extr = opt_extr + 1;
                end
                %
            else
                disp(['Secondary extrema removal suceeded at width ',num2str(dtheta*(t - 1)),'/pi.'])
            end
            disp(['  -> variations on B : ',num2str(var),'/',num2str(tol),'.'])
        end
    end
    %
    if real(opt_extr) == 3,        
        %
        % Try removing secondary extrema directly, linear interpolation
        %
        tpx = equil.ptx(:,1:(ntheta-1)).';
        tpy = equil.pty(:,1:(ntheta-1)).';
        tpBx = equil.ptBx(:,1:(ntheta-1)).';
        tpBy = equil.ptBy(:,1:(ntheta-1)).';
        tpBPHI = equil.ptBPHI(:,1:(ntheta-1)).';
        %
        thetah = equil.theta(1:ntheta-1);
        %
        nt = 1000*nc;
        %
        for t = 1:nt,
            %
            tpB = sqrt(tpBx.^2 + tpBy.^2 + tpBPHI.^2);% total magnetic field
            %
            var = max(max(abs(tpB - tpB0)./tpB0));
            %
            extr_ind = diff(sign(diff([tpB(end,:);tpB;tpB(1,:)]))) ~= 0;%local extrema indices
            nextr = sum(extr_ind);
            %
            if t == nt || var > tol || all(nextr <= 2),
                break
            end
            %
            disp(['Iteration : ',num2str(t),'; FS with extr. : ',num2str(sum(nextr > 2)),'/',...
                num2str(npsi),'; B var. : ',num2str(var),'/',num2str(tol),'.'])
            %
            for ir = 1:npsi,
                %
                mask = extr_ind(:,ir);%extrema positions
                %
                itmax = find(tpB(:,ir) == max(tpB0(:,ir)),1,'first');
                itmin = find(tpB(:,ir) == min(tpB0(:,ir)),1,'first');
                %
                mask(itmax) = false;%take global extrema indices away
                mask(itmin) = false;%take global extrema indices away
                %
                if ~any(mask),
                    continue
                end
                %
                tB = interp1([thetah(end) - 2*pi,thetah(~mask),2*pi],[tpB(end,ir);tpB(~mask,ir);tpB(1,ir)],thetah,'linear').';
                %
                tpBx(:,ir) = tpBx(:,ir).*tB./tpB(:,ir);
                tpBy(:,ir) = tpBy(:,ir).*tB./tpB(:,ir);
                tpBPHI(:,ir) = tpBPHI(:,ir).*tB./tpB(:,ir);
            end
            %
        end
        %
        if t > 1,
            if var > tol || ~all(nextr <= 2),
                %
                disp(['Secondary extrema direct removal failed after ',num2str(t-1),' iterations.'])
                %
                if imag(opt_extr) == 1,
                    opt_extr = opt_extr + 1;
                end
                %
            else
                disp(['Secondary extrema direct removal suceeded after ',num2str(t-1),' iterations.'])
            end
            disp(['  -> variations on B : ',num2str(var),'/',num2str(tol),'.'])
        end
    end
    %
    if var > tol || ~all(nextr <= 2),
        error('Extrema removal failed, aborted')
    end    
    %
end
%
for m = mfactor:-1:1,
    %
    mx = interpft(tpx,(ntheta-1)*m).'; %FFT interpolation
    my = interpft(tpy,(ntheta-1)*m).'; %FFT interpolation
    mBx = interpft(tpBx,(ntheta-1)*m).'; %FFT interpolation
    mBy = interpft(tpBy,(ntheta-1)*m).'; %FFT interpolation
    mBPHI = interpft(tpBPHI,(ntheta-1)*m).'; %FFT interpolation
    %
    if Rp < Inf
        %
        mB = sqrt(mBx.^2 + mBy.^2 + mBPHI.^2);
        %
        nextr = sum(diff(sign(diff(tpB))) ~= 0);
        %
        if all(nextr <= 2),
            break
        end
        %
    else
        break
    end
end
%
mx = [mx,mx(:,1)]; %2*pi point retrieved
my = [my,my(:,1)]; %2*pi point retrieved
mBx = [mBx,mBx(:,1)]; %2*pi point retrieved
mBy = [mBy,mBy(:,1)]; %2*pi point retrieved
mBPHI = [mBPHI,mBPHI(:,1)]; %2*pi point retrieved
%
mtheta = 0:2*pi/((ntheta-1)*mfactor):2*pi; %super theta grid
%
if m < mfactor,
    %
    disp(['FT interpolation successful up to m = ',num2str(m),'/',num2str(mfactor)])
    %
    mmtheta = 0:2*pi/((ntheta-1)*m):2*pi; %super theta grid
    %
    mx = interp1(mmtheta,mx,mtheta);
    my = interp1(mmtheta,my,mtheta);
    mBx = interp1(mmtheta,mBx,mtheta);
    mBy = interp1(mmtheta,mBy,mtheta);
    mBPHI = interp1(mmtheta,mBPHI,mtheta);
    %
end 
%
ap =  mx(npsi,1);%Plasma minor radius on the LFS midplane 
%
psi_apRp = reshape(equil.psi_apRp,[1,npsi]);
psia_apRp = psi_apRp(npsi);%Poloidal flux at the edge
psin = psi_apRp/psia_apRp;%Normalized poloidal flux
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
XBx(isnan(XBx)) = Inf;
XBy(isnan(XBy)) = Inf;
XBphi(isnan(XBphi)) = Inf;
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
% index 0 refers to the minimum of the magnetic field
%
[xB0,xiB0] = min(XB.'); %Minimum of B on flux surface
xBmax = max(XB.'); %Maximum of B on flux surface
%
xmhu0T2 = 1 - xB0./xBmax; %Pitch-angle (squared) at the trapped-passing boundary
%
xiB0 = (xiB0 - 1)*nr + (1:nr);%Indices in (psi,theta) grid corresponding of B=Bmin
xBT0 = XBT(xiB0);%Toroidal field at B=Bmin
xBp0 = XBp(xiB0);%Poroidal field at B=Bmin
xx0 = Xx(xiB0);%Major radius at B=Bmin
%
% volume and surface elements
%
% half grids in psi (for trapezoidal integration avoiding singularities)
%
hmx = (mx(1:npsi-1,:) + mx(2:npsi,:))/2;
hmy = (my(1:npsi-1,:) + my(2:npsi,:))/2;
hmBx = (mBx(1:npsi-1,:) + mBx(2:npsi,:))/2;
hmBy = (mBy(1:npsi-1,:) + mBy(2:npsi,:))/2;
hmBPHI = (mBPHI(1:npsi-1,:) + mBPHI(2:npsi,:))/2;
%
[hpq,hpqtilde,hpqbar,hpqhat,hpqcronos,hpB0] = qfactors_dke_yp(1,Rp,ap,hmx,hmy,hmBx,hmBy,hmBPHI);
%
dpsi_apRp = abs(diff(psi_apRp));
%
% FS Volume per 2pi*Rp
%
hpdV_2piRp = 2*pi*hpqhat./hpB0;
pV_2piRp = [0,cumsum(hpdV_2piRp.*dpsi_apRp)];
%    
% FS poloidal surface
%
hpdA = 2*pi*hpqbar./hpB0;
pA = [0,cumsum(hpdA.*dpsi_apRp)];
%
% Other definitions for rho
%
psiT = 2*pi*[0,cumsum(hpq.*dpsi_apRp)];
xrhoT = interp1(psin,sqrt(psiT/psiT(end)),xpsin);
xrhoV = interp1(psin,sqrt(pV_2piRp/pV_2piRp(end)),xpsin);
xrhoP = sqrt(xpsin);
%
% FS volume and poloidal surface
%
if ~isnan(xpsin_S_dke)
%
% DKE FS volume and poloidal surface
%
    xV_2piRp_S_dke = interp1(psin,pV_2piRp,xpsin_S_dke,method);
    xA_S_dke = interp1(psin,pA,xpsin_S_dke,method);
%
% DKE FS invremental volume and poloidal surface
%
    xdV_2piRp_dke = diff(xV_2piRp_S_dke);
    xdA_dke = diff(xA_S_dke);
else
    xdV_2piRp_dke = NaN;
    xdA_dke = NaN;
end
%
% Display of equilibrium properties
%
if abs(display_mode) >= 2,
    %
    if abs(display_mode) == 2,
        p_opt = input_dke_yp('Option for output figures : -1 (nothing), 0 (print), 1 (print and save), 2 (save)',-1,-1:2,'',[1,1]);
    else
        p_opt = -1;
    end
    %    
    prho = mx(:,1)'/ap;
    %       
    % displays the magnetic flux-surfaces geometry
    %    
    if imag(display_mode) == 0,
        srho = linspace(0,1,21);
    else
        srho = linspace(0,1,11);
    end
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
    if flag_id,
        figure('Name','Magnetic equilibrium flux surface contour'),clf
        ax = gca;
        red = 0.9;
        lspace = 0.7;
        bspace = 0.5;
        tit = 'Flux-surfaces labeled by \rho=0,0.05,0.1...1';
    else
        ax = axs(1);
        red = 1;
        lspace = NaN;
        bspace = NaN;
        tit = '';
    end
    %    
    [ax] = graph1D_jd(sx',sy',0,0,'x(m)','y(m)','',NaN,[xmin,xmax],[ymin,ymax],'-','none','r',2,font,ax,red,lspace,bspace);drawnow
    if imag(display_mode) == 0,
        [ax] = graph1D_jd(stx,sty,0,0,'','',tit,NaN,[xmin,xmax],[ymin,ymax],'-','none','b',0.5,font,ax);
    end
    axis(ax,'equal');drawnow  
    print_jd(p_opt,['Fig_EQUIL_',equil.id,'_mag'])
    %
    if flag_id,
        figure('Name','Electron Temperature and Density Profiles'),clf
        [ax] = graph1D2jd(prho,xTe,prho,xne/1e19,'\rho','T_e (keV)','n_e (10^{19} m^{-3})','',...
            [0,1],NaN,NaN,'-','none','r',2,'--','none','b',2,20,0.9,0.5,0.7);
        set(ax(1),'xtick',[0:0.2:1]);set(ax(2),'xtick',[0:0.2:1])
    else
        ax = axs(2);
        leg = {'T_e (keV)','n_e (10^{19} m^{-3})','Location','NorthEast'};
        [ax] = graph1D_jd(prho,equil.pTe,0,0,'','','',NaN,[0,1],NaN,'-','none','r',2,font,ax);
        [ax] = graph1D_jd(prho,equil.pne/1e19,0,0,'\rho','','',leg,[0,1],NaN,'--','none','b',2,font,ax);
        set(ax,'xtick',[0:0.2:1]);
    end
    %    
    print_jd(p_opt,['Fig_EQUIL_',equil.id,'_tene'])
    %
    % displays the equilibrium profiles
    %
    if flag_id, 
        figure('Name','Equilibrium profile parameters'),clf
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
    else
        ax = axs(3);
        [ax] = graph1D_jd(prho,pZeff,0,0,'\rho','Z_{eff}','',NaN,[0,1],[0,ceil(max(pZeff))],'-','none','r',2,font,ax,red,lspace,bspace);drawnow     
        set(ax,'ytick',[0:ceil(max(pZeff))]);
    end
    %
    if p_opt >= 0,
        %
        axlist = get(gcf,'children');
        figure('Name','Equilibrium profile > print'),clf
        cpaxlist = copyobj(axlist,gcf);
        %
        set(gcf,'position',[0,0,600,900]),
        set(cpaxlist(1),'units','normalized','position',[0.65,0.1,0.3,0.2])
        set(cpaxlist(2),'units','normalized','position',[0.65,0.4,0.3,0.2])
        set(cpaxlist(3),'units','normalized','position',[0.15,0.4,0.3,0.2])
        set(cpaxlist(4),'units','normalized','position',[0.65,0.7,0.3,0.2])
        set(cpaxlist(5),'units','normalized','position',[0.15,0.7,0.3,0.2])
        set(cpaxlist(6),'units','normalized','position',[0.15,0.1,0.3,0.2])    
        %
        set(get(cpaxlist(5),'title'),'string','')
        %
        print_jd(p_opt,['Fig_EQUIL_',equil.id,'_prof']);	
        %
    end
end
%
zZi = equil.zZi;
zmi = equil.zmi;
%
if abs(display_mode) >=1,
    disp('-------------------------------------------------------------------------------------------------------------------');
    disp(['- Scenario name = ',equil.id]);
    disp('-------------------------------------------------------------------------------------------------------------------');
	disp(['------------------------------------- Tokamak magnetic equilibrium parameters ------------------------------------']);
	disp(['- Plasma minor radius on LFS midplane (m) ap = ',num2str(ap)]);
	disp(['- Plasma major radius on axis (m) Rp = ',num2str(Rp)]);
	disp(['- Plasma elevation on axis (m) Zp = ',num2str(Zp)]);
	disp(['- Edge normalized cylindrical poloidal flux (Wb) = ',num2str(psia_apRp)]);
	if isfield(equil,'signs') && ~isempty(equil.signs),
        disp(['- Sign of the plasma current (LUKE convention) = ',num2str(equil.signs.Ip)]);
        disp(['- Sign of the toroidal magnetic field (LUKE convention) = ',num2str(equil.signs.Bt)]);
	end
	disp('-------------------------------------------------------------------------------------------------------------------');
end
%
if flag_consistency && abs(display_mode) >= 2,
	disp('Calculation of the equilibrium consistency (wait few seconds).');
    equilconsistency_yp(equil,fitequil_yp(equil));
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
equilDKE.xrhoP = xrhoP;
equilDKE.xrhoT = xrhoT;
equilDKE.xrhoV = xrhoV;
equilDKE.xTe = xTe;
equilDKE.xne = xne;
equilDKE.xzTi = xzTi;
equilDKE.xzni = xzni;
equilDKE.zZi = zZi;
equilDKE.zmi = zmi;
equilDKE.xZeff = xZeff;
equilDKE.Rp = Rp;
equilDKE.Zp = Zp;
equilDKE.Bax = Bax;
equilDKE.ap = ap;
equilDKE.xmhu0T2 = xmhu0T2;
equilDKE.xdV_2piRp_dke = xdV_2piRp_dke;
equilDKE.xdA_dke = xdA_dke;
%
if isfield(equil,'equil_fit'),
    equilDKE.equil_fit = equil.equil_fit;
end
%
if isfield(equil,'ip'),
    equilDKE.ip = equil.ip;
end
%
if isfield(equil,'li'),
    equilDKE.li = equil.li;
end
%
if nargout >= 1,
    varargout{1} = equilDKE;
end


