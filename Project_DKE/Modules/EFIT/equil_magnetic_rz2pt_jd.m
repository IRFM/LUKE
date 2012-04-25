function [equil_magnetic,prho,pspsin,pspsinT] = equil_magnetic_rz2pt_jd(equil_magnetic_data,display_mode,p_opt,dispname,savename,np,nt)
%
% This function reads and returns the magnetic equilibrium parameters from 
% magnetic field data on a RZ grid
%
%	INPUTS:
%
%		- equil_magnetic_data: equilibrium data
%		- display_mode: option for figure display
%		- p_opt: option for printing
%
% by J. Decker (joan.decker@cea.fr) and Y. Peysson
%
if nargin < 7,
    nt = 65;
end
%
if nargin < 6,
    np = 101;
end
%
if nargin < 5,
    savename = '';
end
%
if nargin < 4,
    dispname = '';
end
%
if nargin < 3,
    p_opt = -1;
end
%
if nargin < 2,
    display_mode = 0;
end
%
method = 'spline';%'linear';
%
x = equil_magnetic_data.x;
y = equil_magnetic_data.y;
Rp = equil_magnetic_data.Rp;
Zp = equil_magnetic_data.Zp;
xypsin = equil_magnetic_data.xypsin;
psia = equil_magnetic_data.psia;
xBt = equil_magnetic_data.xBt;
ypsin = equil_magnetic_data.psin;
yq = equil_magnetic_data.pq;
%
psin = linspace(0,1,np);
%
% Transforms on a (psi,theta) grid
%
[ptx,pty,ptdpsindx,ptdpsindy,psin,theta] = rz2pt_jd(x,y,xypsin,psin,nt,method,display_mode,p_opt,savename);
%
np = length(psin);
ap = ptx(np,1);%Plasma minor radius on the LFS midplane
psi_apRp = psin*psia*ap/Rp;%The poloidal flux coordinate is normalized by the aspect ratio 
ptR = Rp + ptx;
%
% Note that in DKE we have B = F.gradphi + gradphi x gradpsi.
%
ptBx = -ptdpsindy*psia./ptR;
ptBy = ptdpsindx*psia./ptR;
%
ptBPHI = interp1(x,xBt,ptx,method);
%
ptBP = sqrt(ptBx.^2 +ptBy.^2);
ptB = sqrt(ptBP.^2 + ptBPHI.^2);
%
prho = ptx(:,1).'/ap;
%
pq = interp1(ypsin,yq,psin,method,'extrap');
%
pq_h = (pq(1:end-1) + pq(2:end))/2;
pdpsin = diff(psin);
ppsiT = [0,cumsum(pq_h.*pdpsin)];
pspsinT = sqrt(ppsiT/ppsiT(end));
%
pspsin = sqrt(psin);
%
if display_mode == 2, 
%
    rx = [-fliplr(prho(2:np)),prho];
    rBx = [fliplr(ptBx(2:np,(nt+1)/2)'),ptBx(:,1)'];
    rBy = [fliplr(ptBy(2:np,(nt+1)/2)'),ptBy(:,1)'];
    rBPHI = [fliplr(ptBPHI(2:np,(nt+1)/2)'),ptBPHI(:,1)'];
    rBP = sqrt(rBx.^2 + rBy.^2);
    rB = sqrt(rBP.^2 + rBPHI.^2);
%
    style = '-';
    marker = 'none';
    color1 = 'r';
    color2 = 'b';
    color3 = 'k';
    width = 2;
    siz = 20;
    red = 0.9;
    lspace = 0.7;
    bspace = 0.6;
    tit = [dispname];
    %
    figure(12),clf
    %
    xlab = 'r/a';
    ylab = 'B(T)';
    xlim = [-1,1];
    ylim = NaN;
    leg = ['B_T';'B_P';'B  '];
%
    graph1D_jd(rx,abs(rBPHI),0,0,'','','',NaN,xlim,ylim,style,marker,color1,width,siz,gca,red,lspace,bspace);
    graph1D_jd(rx,rBP,0,0,'','','',NaN,xlim,ylim,style,marker,color2,width);
    graph1D_jd(rx,rB,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color3,width);
    print_jd(p_opt,[savename,'_Bfield']);
%
    figure(13),clf
    graph1D_jd(theta,ptB(2,:),0,0,'','','',NaN,'','',style,marker,'b',width);hold on
    plot(theta,ptB([2:end],:))
    legend(['r/a = ',num2str(prho(2))])
    axis([0,2*pi,0,ceil(max(max(ptB([2:end],:)))*10)/10])
    xlabel('\theta (rd)'),ylabel('B(T)'),title([dispname])
end
%
ptx(:,65) = ptx(:,1);
pty(:,65) = pty(:,1);
ptBx(:,65) = ptBx(:,1);
ptBy(:,65) = ptBy(:,1);
ptBPHI(:,65) = ptBPHI(:,1);
%
% equil structure
%
equil_magnetic.psi_apRp = psi_apRp;
equil_magnetic.theta = theta;
equil_magnetic.ptx = ptx;
equil_magnetic.pty = pty;
equil_magnetic.ptBx = ptBx;
equil_magnetic.ptBy = ptBy;
equil_magnetic.ptBPHI = ptBPHI;
equil_magnetic.Rp = Rp;
equil_magnetic.Zp = Zp;
%
