function [x,y,xypsin,psia,rpsin,rF,rp,rq,Rp,Zp,Ip,Rv,Zv,Bv,rdFdpsi,rdpdpsi] = eqdsk_jd(eqdsk,display_mode,p_opt,dispname,savename,Ns)
% EFIT - function that reads the equilibrium parameters from eqdsk files by EFIT
%
% This function reads the equilibrium parameters from eqdsk files created
% by EFIT and saved in the formatted text file "filename"
%
% INPUT
%
%    - eqdsk: file that contains the EQDSK structure
%    - display_mode: display option (0,2)
%       (default display_mode = 0, no display)
%    - p_opt: printing option
%       (default p_opt = 2, print mutiple formats)
%    - dispname: name displayed in the figures
%       (default dispname = '')
%    - savename: name used for saving the the figures
%       (default savename = 'equil')
%    - Ns: magnetic axis recalculation supergrid factor
%       (default Ns = 101; 
%
% OUTPUT: 
%    - x: R - Rp values on the nnr * nnz equispaced grid
%    - y: Z - Zp values on the nnr * nnz equispaced grid
%    - xypsin: normalized psi values on the nnr * nnz equispaced grid
%    - psia: poloidal flux function value at the last closed flux surface (touching the limiter or the separatrix)
%    - rpsin: normalized poloidal magnetic flux grid
%    - rF: R*BPHI at nnr equispaced points in psi from psimag to psilim.
%    - rp: pressure values at nnr equispaced points in psi from psimag to psilim.
%    - rq: safety factor q on the equispaced psi grid
%    - Rp: major radius of magnetic axis
%    - Zp: vertical height of magnetic axis
%    - Ip: toroidal lasma current
%    - Rv: nominal major radius of the torus
%    - Zv: vertical shift of the rectangular box midplane
%    - Bv: vacuum toroidal magnetic field at radmaj
%    - rdFdpsi: fpsiar_prime, [i.e., d f/d (psi)] at nnr equispaced points in psi from psimag to psilim.
%    - rdpdpsi: p_prime [i.e., d prar/d (psi)] at nnr equispaced points in psi from psimag to psilim.
%
% WARNING: EFIT sign treatment
%
% By convention, the EFIT calculations always give psia > 0 regardless of the direction of the
% toroidal current. The signs of Bv and Ip are given with respect to phi_eqdsk which is such that
% (R,phi_eqdsk,Z) is right handed. The sign of phi_dke is opposite such that (R,Z,phi_dke) and
% (r,theta,phi_dke) be both right handed. The outputs of eqdsk_jd must respect the DKE convention.
% In that case the signs of Ip and of psia must be identical.
%
% by J. Decker (joan.decker@alum.mit.edu) 10/28/04
%
%
if nargin < 6
    Ns = 101;%magnetic axis recalculation supergrid factor 
end
%
if nargin < 5
    savename = 'equil';
end
%
if nargin < 4
    dispname = '';
end
%
if nargin < 3
    p_opt = 2;
end
%
if nargin < 2
    display_mode = 0;
end
%
if exist(eqdsk,'file'),
    eqdsk = fileread(eqdsk);
end
%
istr = find(double(eqdsk) == 10,1,'first');
str_intro = eqdsk(1:istr-1);
eqdsk = eqdsk(istr+1 : end);
sc = 0;
nn = [];
while length(str_intro) > 0 & length(nn) < 3,
    if str_intro(end) ~= ' ' 
        if sc == 0,
            sc = 1;
            str = str_intro(end);
        else
            str = [str_intro(end),str];
        end
    else
        if sc == 1,
            nn = [nn,str2num(str)];
            sc = 0;
        end           
    end
    str_intro(end) = '';
end
%
if nn(3) < 10,
    nnx = nn(2);
    nny = nn(1);
    nnr = nn(2);
else
    nnx = nn(3);
    nny = nn(2);
    if nn(1) == 0,
        nnr = nn(2);%CQL3D (COMPASS)
    else
        nnr = nn(1);
    end
end
%
[data,~,~,ind] = sscanf(eqdsk,'%e',5);
xbox = data(1);% horizontal full-width of the rectangle on which poloidal flux values are given
ybox = data(2);% vertical full-width of the rectangle on which poloidal flux values are given
Rv = data(3);% nominal major radius of the torus
Rmin = data(4);% major radius of the inner edge of the box of rectangular grid
Zv = data(5);% vertical shift of the rectangular box midplane
%
eqdsk = eqdsk(ind:end);
[data,~,~,ind] = sscanf(eqdsk,'%e',5);
Rp = data(1);% major radius of magnetic axis
Zp = data(2);% vertical height of magnetic axis
psip = data(3);% poloidal flux function value at the magnetic axis 
psia = data(4);% poloidal flux function value at the last closed flux surface (touching the limiter or the separatrix)
Bv = data(5);% vacuum toroidal magnetic field at radmaj
%
eqdsk = eqdsk(ind:end);
[data,~,~,ind] = sscanf(eqdsk,'%e',5);
Ip = data(1);% toroidal current
psimx1 = data(2);% not used
psimx2 = data(3);% not used
xax1 = data(4);% not used
xax2 = data(5);% not used
%
eqdsk = eqdsk(ind:end);
[data,~,~,ind] = sscanf(eqdsk,'%e',5);
zax1 = data(1);% not used
zax2 = data(2);% not used
psisep = data(3);% not used
xsep = data(4);% not used
zsep = data(5);% not used
%
eqdsk = eqdsk(ind:end);
[rF,~,~,ind] = sscanf(eqdsk,'%e',nnr);% R*BPHI  at nnr equispaced points in psi from psimag to psilim.
eqdsk = eqdsk(ind:end);
[rp,~,~,ind] = sscanf(eqdsk,'%e',nnr);% pressure values at the same points
eqdsk = eqdsk(ind:end);
[rdFdpsi,~,~,ind] = sscanf(eqdsk,'%e',nnr);% fpsiar_prime, [i.e., d f/d (psi)] at the same points
eqdsk = eqdsk(ind:end);
[rdpdpsi,~,~,ind] = sscanf(eqdsk,'%e',nnr);% p_prime [i.e., d prar/d (psi)] at the same points
%
rF = rF.';
rp = rp.';
rdFdpsi = rdFdpsi.';
rdpdpsi = rdpdpsi.';
%
eqdsk = eqdsk(ind:end);
[xypsi,~,~,ind] = sscanf(eqdsk,'%e',[nnx,nny]);% psi values on the nnr * nnz equispaced grid
%
eqdsk = eqdsk(ind:end);
[rq,~,~,ind] = sscanf(eqdsk,'%e',nnr); % safety factor q on the equispaced psi grid
rq = rq.';
%
eqdsk = eqdsk(ind:end);
[ncoil,~,~,ind] = sscanf(eqdsk,'%d',5);
ncoil = ncoil(ncoil>0).';% not used
eqdsk = eqdsk(ind:end);
[ccoil,~,~,ind] = sscanf(eqdsk,'%e',[ncoil(1),length(ncoil)]);% not used
%
R = Rmin + linspace(0,xbox,nnx);
Z = Zv + linspace(-ybox/2,ybox/2,nny);
%
% To compensate irregularities in the EFIt output
% Rp, Zp and psip are recalculated in accordance
% with xypsi data  
%
psip_old = psip;
Rp_old = Rp;
Zp_old = Zp;
%
if psip < psia, %IPHI is positive, PHI clockwise from top
    sigma = 1;
else %IPHI is negative, PHI clockwise from top
    sigma = -1;
end
%
% create mask to search for minimum... within the plasma
%
xR = repmat(R.',[1,nny]);
xZ = repmat(Z,[nnx,1]);
xd = sqrt((xR - Rp).^2 + (xZ - Zp).^2);
xmask_out = (sigma*xypsi > sigma*psia);% these points are outside the plasma
dmin = min(xd(xmask_out));
xmask_excl = (xd > dmin);
xypsi_excl = xypsi;
xypsi_excl(xmask_excl) = sigma*Inf;
%
[iR,iZ] = find(sigma*xypsi_excl == min(min(sigma*xypsi_excl)));
%
if length(iR) ~= 1,
    error('unable to locate minimum in xypsi data');
end
%
ss = linspace(0,1,Ns);
sR = R(iR-1) + (R(iR+1)-R(iR-1))*ss;
sZ = Z(iZ-1) + (Z(iZ+1)-Z(iZ-1))*ss;
%
sspsi = interp2(R,Z,xypsi.',sR.',sZ,'spline').';
psip = sigma*min(min(sigma*sspsi));
[isR,isZ] = find(sspsi == psip);
%
if length(isR) ~= 1,
    error('unable to locate minimum in xypsi data');
end
%
Rp = sR(isR);
Zp = sZ(isZ);
%
if display_mode >= 1,
    disp(['Old value of psip: ',num2str(psip_old),', new value: ',num2str(psip)])
    disp(['Old value of Rp: ',num2str(Rp_old),', new value: ',num2str(Rp)])
    disp(['Old value of Zp: ',num2str(Zp_old),', new value: ',num2str(Zp)])
end
%
% iRp = find(abs(R - Rp) == min(abs(R - Rp)));
% if abs(R(iRp) - Rp)/Rp < 1/(100*nnr) %one R point is very close to Rp 
%     R = R + Rp - R(iRp);
%     psimag = min(min(epsi));
% else
%     warning('No R = Rp point');
% end
%
%
x = R - Rp;
y = Z - Zp;
%
xypsi = xypsi - psip;
psia = (psia - psip);
%
xypsin = xypsi/psia;
rpsin = linspace(0,1,nnr);
%
% EFIT sign treatment
%
% By convention, the EFIT calculations always give psia > 0 regardless of the direction of the
% toroidal current. The signs of Bv and Ip are given with respect to phi_eqdsk which is such that
% (R,phi_eqdsk,Z) is right handed. The sign of phi_dke is opposite such that (R,Z,phi_dke) and
% (r,theta,phi_dke) be both right handed. The outputs of eqdsk_jd must respect the DKE convention.
% In that case the signs of Ip and of psia must be identical.
%
Ip = - Ip;
Bv = - Bv;
rF = - rF;
rdFdpsi = - rdFdpsi;
%
if sign(Ip) ~= sign(psia),
    psia = - psia;
end
%
if sign(Bv) ~= sign(rF(1)),
    rF = - rF;
    rdFdpsi = - rdFdpsi;
end
%
if display_mode >= 2,
    %
    style = '-';
    marker = '+';
    color = 'r';
    width = 2;
    siz = 20;
    red = 0.9;
    lspace = 0.7;
    bspace = 0.6;
    tit = strrep(dispname,'_','-');
    %
    figure(1),clf
    %
    xlab = 'x (m)';
    ylab = 'y (m)';
    xlim = [min(x),max(x)];
    ylim = [min(y),max(y)];
    %
    graph2D_jd(x,y,xypsin,xlab,ylab,tit,xlim,ylim,0,NaN,[0:0.05:1],0,style,color,width,siz,red);
    axis('equal');
    axis([xlim,ylim]);
    %set(gca,'XTick',[0:1:2],'YTick',[-2:2]);
    print_jd(p_opt,[savename,'_psi_xy']);
    %
    figure(2),clf
    %
    xlab = '\psi_n^{1/2}';
    ylab = 'F(\psi)=RB_{\phi} (mT)';
    xlim = [0,1];
    ylim = NaN;
    %
    graph1D_jd(sqrt(rpsin),rF,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_F_psi']);
    %
    figure(3),clf
    %
    ylab = 'p(\psi) (hPa)';
    ylim = NaN;
    %
    graph1D_jd(sqrt(rpsin),rp/1e5,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_p_psi']);
    %
    figure(4),clf
    %
    ylab = 'dF/d\psi (m^{-1})';
    ylim = NaN;
    %
    graph1D_jd(sqrt(rpsin),rdFdpsi,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_dF_psi']);
    %
    figure(5),clf
    %
    ylab = 'dp/d\psi (hPaB^{-1}m^{-2})';
    ylim = NaN;
    %
    graph1D_jd(sqrt(rpsin),rdpdpsi/1e5,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_dp_psi']);
    %
    figure(6),clf
    %
    ylab = 'q(\psi)';
    ylim = NaN;
    %
    graph1D_jd(sqrt(rpsin),rq,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_q_psi']);
    %
    figure(7),clf
    %
    rho_list = [0:0.05:0.999];
    iy0 = find(abs(y) == min(abs(y)));
    ix0 = min(find(x >= 0));
    ap = interp1(xypsin(ix0:nnx,iy0(1)),x(ix0:nnx),1,'spline');
    rpsi = interp1(x(ix0:nnx)/ap,xypsin(ix0:nnx,iy0(1)),rho_list,'spline');
    %
    xlab = 'x (m)';
    ylab = 'y (m)';
    xlim = [min(x),max(x)];
    ylim = [min(y),max(y)];
    tit = strrep(dispname,'_','-');
    %
    graph2D_jd(x,y,xypsin,xlab,ylab,tit,xlim,ylim,0,NaN,rpsi,0,style,color,width,siz,red);
    axis('equal');
    axis([xlim,ylim]);
    %set(gca,'XTick',[0:1:2],'YTick',[-2:2]);
    print_jd(p_opt,[savename,'_rho_xy']);
 end








