function [equil_magnetic,prho,psin] = equil_magnetic_ACCOME_yp(filename,display_mode,p_opt,dispname,savename)
%
% This function reads and returns the magnetic equilibrium parameters from files created
% by ACCOME
%
%	INPUTS:
%
%		- filename: equilibrium data and save name
%		- display_mode: option for figure display
%		- p_opt: option for printing
%
% by J. Decker (joan.decker@cea.fr) 11/01/04
%
if nargin < 5,
    dispname = filename;
end
%
if nargin < 4,
    dispname = filename;
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
nt = 65;
%
% Reads ACCOME data
%
accomename = [filename,'.bfield'];
[x,y,xypsin,psia,psin,xyBPHI,Rp,Zp] = accome_yp(accomename,display_mode,p_opt,dispname,savename);
%
% Transforms on a (psi,theta) grid
%
[ptx,pty,ptdpsindx,ptdpsindy,psin,theta] = rz2pt_jd(x,y,xypsin,psin,nt,method,display_mode,p_opt,savename);
%
ptBPHI = griddata(x,y,xyBPHI',ptx,pty);
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
ptBP = sqrt(ptBx.^2 +ptBy.^2);
ptB = sqrt(ptBP.^2 + ptBPHI.^2);
%
prho = ptx(:,1).'/ap;
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
    figure(13),,clf
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
