function [R,Z,psin,psia,xpsin,xF,xp,xq,Rv,Zv,Bv,Rp,Zp,Ip] = eqdsk_jd(filename,display_mode,p_opt,dispname,savename);
%
% This function reads the equilibrium parameters from eqdsk files created
% by EFIT and saved in the formatted text file "filename"
%
% by J. Decker (jodecke@alum.mit.edu) 10/28/04
%
if nargin < 5
    savename = filename;
end
if nargin < 4
    dispname = filename;
end
fid = fopen(filename);
name = fscanf(fid,'%s',1);
date = fscanf(fid,'%s',1);
%dummy = fscanf(fid,'%d',1);
time = fscanf(fid,'%s',1);
ipestg = fscanf(fid,'%d',1);
%
data = fscanf(fid,'%d',3);
nnr = data(1);% number of points in the horizontal direction
nnz = data(2);% number of points in the vertical direction
nnv = data(3);% number of radial flux surfaces
if nnv == 0, 
    nnv = nnr;
end
%
data = fscanf(fid,'%e',5);
rbox = data(1);% horizontal full-width of the rectangle on which poloidal flux values are given
zbox = data(2);% vertical full-width of the rectangle on which poloidal flux values are given
radmaj = data(3);% nominal major radius of the torus
rboxdst = data(4);% major radius of the inner edge of the box of rectangular grid
ymideqd = data(5);% vertical shift of the rectangular box midplane
%
data = fscanf(fid,'%e',5);
raxis = data(1);% major radius of magnetic axis
zaxis = data(2);% vertical height of magnetic axis
psimag = data(3);% poloidal flux function value at the magnetic axis 
psilim = data(4);% poloidal flux function value at the last closed flux surface (touching the limiter or the separatrix)
btor = data(5);% vacuum toroidal magnetic field at radmaj
%
data = fscanf(fid,'%e',5);
toteqd = data(1);% toroidal current
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
fpsiar = fscanf(fid,'%e',nnv);% r * B_phi  at nnr equispaced points in psi from psimag to psilim.
prar = fscanf(fid,'%e',nnv);% pressure values at the same points
ffpar = fscanf(fid,'%e',nnv);% fpsiar_prime, [i.e., d f/d (psi)] at the same points
ppar = fscanf(fid,'%e',nnv);% p_prime [i.e., d prar/d (psi)] at the same points
epsi = fscanf(fid,'%e',[nnr,nnz]);% psi values on the nnr * nnz equispaced grid
qar = fscanf(fid,'%e',nnv); % safety factor q on the equispaced psi grid
%
ncoil = fscanf(fid,'%d',5);
ncoil = ncoil(ncoil>0)';% not used
ccoil = fscanf(fid,'%e',[ncoil(1),length(ncoil)]);% not used
%
fclose(fid);
%
Rv = radmaj;
Zv = ymideqd;
Bv = btor;
Rp = raxis;
Zp = zaxis;
Ip = toteqd;
%
R = rboxdst + linspace(0,rbox,nnr);
iRp = find(abs(R - Rp) == min(abs(R - Rp)));
if abs(R(iRp) - Rp)/Rp < 1/(100*nnr) %one R point is very close to Rp 
    R = R + Rp - R(iRp);
    psimag = min(min(epsi));
else
    warning('No R = Rp point');
end
%
Z = ymideqd + linspace(-zbox/2,zbox/2,nnz);
psi = (epsi - psimag);
psia = (psilim - psimag);
psin = psi/psia;
xpsin = linspace(0,1,nnv);
%
xF = fpsiar;
xp = prar;
xq = qar;

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
    xlab = 'R';
    ylab = 'Z';
    %xlim = [0,max(R)];
    xlim = [min(R),max(R)];
    ylim = [min(Z),max(Z)];
    %
    %set(gcf,'position',[1,1,6,8])
    graph2D_jd(R,Z,psin,xlab,ylab,tit,xlim,ylim,0,NaN,[0:0.05:1],0,style,color,width,siz,red);
    axis('equal');
    axis([xlim,ylim]);
    %set(gca,'XTick',[0:1:2],'YTick',[-2:2]);
    print_jd(p_opt,[savename,'_psi_RZ']);
    %
    figure(2),clf
    %
    %xlab = '\psi/\psi_a';
    xlab = '\psi_n^{1/2}';
    ylab = 'F(\psi)=RB_{\phi}';
    xlim = [0,1];
    ylim = NaN;
    %
    graph1D_jd(sqrt(xpsin),fpsiar,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_F_psi']);
    %
    figure(3),clf
    %
    ylab = 'p(\psi)';
    ylim = NaN;
    %
    graph1D_jd(sqrt(xpsin),prar,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_p_psi']);
    %
    figure(4),clf
    %
    ylab = 'dF/d\psi';
    ylim = NaN;
    %
    graph1D_jd(sqrt(xpsin),ffpar,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_dF_psi']);
    %
    figure(5),clf
    %
    ylab = 'dp/d\psi';
    ylim = NaN;
    %
    graph1D_jd(sqrt(xpsin),ppar,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_dp_psi']);
    %
    figure(6),clf
    %
    ylab = 'q(\psi)';
    ylim = NaN;
    %
    graph1D_jd(sqrt(xpsin),qar,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_q_psi']);
    %
    figure(7),clf
    %
    rho_list = [0:0.05:0.999];
    iZ0 = find(abs(Z) == min(abs(Z)));
    R0max = interp1(psin(iRp:nnr,iZ0),R(iRp:nnr),1,'spline');
    rrho = (R(iRp:nnr) - Rp)./(R0max - Rp);
    rpsi = interp1(rrho,psin(iRp:nnr,iZ0),rho_list,'spline');
    %
    xlab = 'R';
    ylab = 'Z';
    %xlim = [0,max(R)];
    xlim = [min(R),max(R)];
    ylim = [min(Z),max(Z)];
    tit = [dispname];
    %
    %set(gcf,'position',[1,1,6,8])
    graph2D_jd(R,Z,psin,xlab,ylab,tit,xlim,ylim,0,NaN,rpsi,0,style,color,width,siz,red);
    axis('equal');
    axis([xlim,ylim]);
    %set(gca,'XTick',[0:1:2],'YTick',[-2:2]);
    print_jd(p_opt,[savename,'_rho_RZ']);
 end








