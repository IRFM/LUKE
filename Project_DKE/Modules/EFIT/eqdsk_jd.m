function [x,y,xypsin,psia,rpsin,rF,rp,rq,Rp,Zp,Ip,Rv,Zv,Bv] = eqdsk_jd(filename,display_mode,p_opt,dispname,savename,Ns);
%
% This function reads the equilibrium parameters from eqdsk files created
% by EFIT and saved in the formatted text file "filename"
%
% by J. Decker (jodecke@alum.mit.edu) 10/28/04
%
if nargin < 6
    Ns = 101;%magnetic axis recalculation supergrid factor 
end
if nargin < 5
    savename = filename;
end
if nargin < 4
    dispname = filename;
end
%
fid = fopen(filename);
%
str_intro = ' ';
while max(str_intro < 48 | str_intro > 57) | length(str_intro) < 2 | length(str_intro) > 3,
    str_intro = fscanf(fid,'%s',1);
end
%
nnx = str2num(str_intro);
%nnx = data(1);% number of points in the horizontal direction
data = fscanf(fid,'%d',2);
nny = data(1);% number of points in the vertical direction
nnr = data(2);% number of radial flux surfaces
if nnr == 0, 
    nnr = nnx;
end
%
data = fscanf(fid,'%e',5);
xbox = data(1);% horizontal full-width of the rectangle on which poloidal flux values are given
ybox = data(2);% vertical full-width of the rectangle on which poloidal flux values are given
Rv = data(3);% nominal major radius of the torus
Rmin = data(4);% major radius of the inner edge of the box of rectangular grid
Zv = data(5);% vertical shift of the rectangular box midplane
%
data = fscanf(fid,'%e',5);
Rp = data(1);% major radius of magnetic axis
Zp = data(2);% vertical height of magnetic axis
psip = data(3);% poloidal flux function value at the magnetic axis 
psia = data(4);% poloidal flux function value at the last closed flux surface (touching the limiter or the separatrix)
Bv = data(5);% vacuum toroidal magnetic field at radmaj
%
data = fscanf(fid,'%e',5);
Ip = data(1);% toroidal current
psimx1 = data(2);% not used
psimx2 = data(3);% not used
xax1 = data(4);% not used
xax2 = data(5);% not used
%
data = fscanf(fid,'%e',5);
zax1 = data(1);% not used
zax2 = data(2);% not used
psisep = data(3);% not used
xsep = data(4);% not used
zsep = data(5);% not used
%
rF = fscanf(fid,'%e',nnr).';% R*BPHI  at nnr equispaced points in psi from psimag to psilim.
rp = fscanf(fid,'%e',nnr).';% pressure values at the same points
rdFdpsi = fscanf(fid,'%e',nnr).';% fpsiar_prime, [i.e., d f/d (psi)] at the same points
rdpdpsi = fscanf(fid,'%e',nnr).';% p_prime [i.e., d prar/d (psi)] at the same points
xypsi = fscanf(fid,'%e',[nnx,nny]);% psi values on the nnr * nnz equispaced grid
rq = fscanf(fid,'%e',nnr).'; % safety factor q on the equispaced psi grid
%
ncoil = fscanf(fid,'%d',5);
ncoil = ncoil(ncoil>0)';% not used
ccoil = fscanf(fid,'%e',[ncoil(1),length(ncoil)]);% not used
%
fclose(fid);
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
[iR,iZ] = find(sigma*xypsi == min(min(sigma*xypsi)));
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
disp(['Old value of psip: ',num2str(psip_old),', new value: ',num2str(psip)])
disp(['Old value of Rp: ',num2str(Rp_old),', new value: ',num2str(Rp)])
disp(['Old value of Zp: ',num2str(Zp_old),', new value: ',num2str(Zp)])
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
    tit = [dispname];
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
    ap = interp1(xypsin(ix0:nnx,iy0),x(ix0:nnx),1,'spline');
    rpsi = interp1(x(ix0:nnx)/ap,xypsin(ix0:nnx,iy0),rho_list,'spline');
    %
    xlab = 'x (m)';
    ylab = 'y (m)';
    xlim = [min(x),max(x)];
    ylim = [min(y),max(y)];
    tit = [dispname];
    %
    graph2D_jd(x,y,xypsin,xlab,ylab,tit,xlim,ylim,0,NaN,rpsi,0,style,color,width,siz,red);
    axis('equal');
    axis([xlim,ylim]);
    %set(gca,'XTick',[0:1:2],'YTick',[-2:2]);
    print_jd(p_opt,[savename,'_rho_xy']);
 end








