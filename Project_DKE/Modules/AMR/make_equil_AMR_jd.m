function [equil_magnetic,equil_prof,equil_RZ] = make_equil_AMR_jd(equil_path,shotnum,shotime,display_mode,p_opt,dispname,savename,np,nt,method)%,Ns,nx
%
%
% This function reads and returns the magnetic equilibrium parameters from 
% AMR equilibrium files
%
%	INPUTS:
%
%		- equil_path: equilibrium data directory
%		- shotnum: shot number
%		- shotime: shot time
%
% by J. Decker (joan.decker@cea.fr) and Y. Peysson
%
% if nargin < 12,
%     nx = 1001;
% end
% %
% if nargin < 11,
%     Ns = 101;
% end
%
if nargin < 11,
    method = 'spline';
end
%
if nargin < 10,
    nt = 65;
end
%
if nargin < 9,
    np = 101;
end
%
if nargin < 8,
    savename = [shotnum,'_',shotime];
end
%
if nargin < 7,
    dispname = savename;
end
%
if nargin < 6,
    p_opt = -1;
end
%
if nargin < 5,
    display_mode = 0;
end
%
if nargin < 4,
    Zeff = 1;
end
%
% Ion data
%
zZi = [1,1,1,6];
zmi = [1,2,3,12];
fi = [0,1,0];
%
Zimp = zZi(end);
nz = length(zZi);
%
% Reads AMR equil data
%
filename_R = ['m_equil_',shotnum,'_',shotime,'_R.dat'];
filename_Z = ['m_equil_',shotnum,'_',shotime,'_Z.dat'];
filename_BR = ['m_equil_',shotnum,'_',shotime,'_BR.dat'];
filename_BZ = ['m_equil_',shotnum,'_',shotime,'_BZ.dat'];
filename_Bphi = ['m_equil_',shotnum,'_',shotime,'_Bphi.dat'];
filename_PsiRZ = ['m_equil_',shotnum,'_',shotime,'_Psi.dat'];
filename_values = ['m_equil_',shotnum,'_',shotime,'_values.dat'];
%
filename_psi = ['m_profs_',shotnum,'_',shotime,'_Psi.dat'];
filename_Te = ['m_profs_',shotnum,'_',shotime,'_Te.dat'];
filename_ne = ['m_profs_',shotnum,'_',shotime,'_ne.dat'];
filename_Zeff = ['m_profs_',shotnum,'_',shotime,'_Zeff.dat'];
%
R = load([equil_path,filename_R],'-ascii');
Z = load([equil_path,filename_Z],'-ascii');
BR = load([equil_path,filename_BR],'-ascii').';
BZ = load([equil_path,filename_BZ],'-ascii').';
Bphi = load([equil_path,filename_Bphi],'-ascii').';
PsiRZ = load([equil_path,filename_PsiRZ],'-ascii').';
values = load([equil_path,filename_values],'-ascii');
%
xpsi = load([equil_path,filename_psi],'-ascii').';
xTe = load([equil_path,filename_Te],'-ascii').';
xne = load([equil_path,filename_ne],'-ascii').';
xZeff = load([equil_path,filename_Zeff],'-ascii').';
%
psip = xpsi(1);
%
% Rp and Zp are calculated in accordance with xypsi data  
%
% psia = xpsi(end);
% %
% if psia > psip,
%     sigma = 1; % increasing psi, Ip clockwise from top
% else 
%     sigma = -1; % decreasing psi, Ip counter-clockwise from top
% end
% %
% [iR,iZ] = find(sigma*PsiRZ == min(min(sigma*PsiRZ)));
% %
% if length(iR) ~= 1,
%     error('unable to locate minimum in xypsi data');
% end
% %
% ss = linspace(0,1,Ns);
% sR = R(iR-1) + (R(iR+1)-R(iR-1))*ss;
% sZ = Z(iZ-1) + (Z(iZ+1)-Z(iZ-1))*ss;
% %
% sspsi = interp2(R,Z,PsiRZ.',sR.',sZ,'spline').';
% psip = sigma*min(min(sigma*sspsi));
% [isR,isZ] = find(sspsi == psip);
% %
% if length(isR) ~= 1,
%     error('unable to locate minimum in xypsi data');
% end
% %
% Rp = sR(isR);
% Zp = sZ(isZ);
%
% psia, Rp and Zp are loaded from file  
%
Rp = values(1);
Zp = values(2);
psia = values(3);
%
disp(' ')
disp(['psip: ',num2str(psip)])
disp(['psia: ',num2str(psia)])
disp(['Rp: ',num2str(Rp)])
disp(['Zp: ',num2str(Zp)])
disp(' ')
%
x = R - Rp;
y = Z - Zp;
%
xypsi = PsiRZ - psip;
psia = psia - psip;
xpsi = xpsi - psip;
%
equil_RZ.Rp = Rp;
equil_RZ.Zp = Zp;
equil_RZ.zZi = zZi;
equil_RZ.zmi =zmi;
%
equil_RZ.x = x.';
equil_RZ.y = y.';
%
if length(xZeff) == 1,
    xZeff = xZeff*ones(size(xne));
end
%
xTi = xTe;
xnH = xne.*(Zimp - xZeff)/(Zimp - 1);
xnZ = xne.*(xZeff - 1)/Zimp/(Zimp - 1);
xzni = [fi.'*xnH;xnZ];
xzTi = ones(nz,1)*xTi;
%
equil_RZ.pTe = xTe;
equil_RZ.pne = xne;
equil_RZ.pzTi = xzTi;
equil_RZ.pzni = xzni;
%
% Determine psia
%
% psimax = max(max(sigma*xypsi));
% %
% xpsia0 = linspace(0,sigma*psimax,nx);
%     %
%     % selects the plasma among various closed systems   
%     %
% for ix = 1:nx,
%     [xc,yc] = contlimit_jd(x,y,sigma*xypsi.',[-1,xpsia0(ix)]);
%     %
%     if ~isempty(xc),
%         %
%         for ic = 1:length(xc),
%             nc(ic) = length(xc{ic});
%         end
%         %
%         ic = find(nc == max(nc)); 
%         sxa = xc{ic};
%         sya = yc{ic};
%         %
%         if sxa(1) ~= sxa(end) || sya(1) ~= sya(end)
%             ix = ix - 1;
%             break
%         end
%         %
%     end
% end
% %
% psia = xpsia0(ix);
%
xypsin = xypsi/psia;
xpsin = xpsi/psia;
%
psin = linspace(0,1,np);
%[x,y,xypsin,psia,psin,pF,pp,pq,Rp,Zp] = eqdsk_jd(filename,display_mode,p_opt,dispname,savename);
% Transforms on a (psi,theta) grid
%
[ptx,pty,ptdpsindx,ptdpsindy,psin,theta] = rz2pt_jd(x,y,xypsin,psin,nt,method,display_mode,p_opt,savename);
%
% Warning : this - sign comes from an inconsistency in the source files
%   B field is assumed correct
%
% psia = - psia;
%
ap = ptx(np,1);%Plasma minor radius on the LFS midplane
psi_apRp = psin*psia*ap/Rp;%The poloidal flux coordinate is normalized by the aspect ratio 
ptR = Rp + ptx;
%
% Note that in DKE we have B = F.gradphi + gradphi x gradpsi.
%
ptBx_2 = -ptdpsindy*psia./ptR;
ptBy_2 = ptdpsindx*psia./ptR;
%
ptBx = interp2(x,y,BR.',ptx,pty,method);
ptBy = interp2(x,y,BZ.',ptx,pty,method);
ptBPHI = interp2(x,y,Bphi.',ptx,pty,method);
%
% Warning : this - sign comes from the opposite phi definition
%
ptBPHI = - ptBPHI;
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
    tit = dispname;
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
    plot(theta,ptB(2:end,:))
    legend(['r/a = ',num2str(prho(2))])
    axis([0,2*pi,0,ceil(max(max(ptB(2:end,:)))*10)/10])
    xlabel('\theta (rd)'),ylabel('B(T)'),title(dispname)
end
%
ptx(:,65) = ptx(:,1);
pty(:,65) = pty(:,1);
ptBx(:,65) = ptBx(:,1);
ptBy(:,65) = ptBy(:,1);
ptBPHI(:,65) = ptBPHI(:,1);
%
pTe = interp1(xpsin,xTe,psin,method);
pne = interp1(xpsin,xne,psin,method);
pZeff = interp1(xpsin,xZeff,psin,method);
%
pTi = pTe;
%
pnH = pne.*(Zimp - pZeff)/(Zimp - 1);
pnZ = pne.*(pZeff - 1)/Zimp/(Zimp - 1);
pzni = [fi.'*pnH;pnZ];
pzTi = ones(nz,1)*pTi;
%
% equil structure
%
equil_RZ.ap = ap;
equil_RZ.psi_apRp = xpsi*ap/Rp;
equil_RZ.xypsi_apRp = xypsi*ap/Rp;
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
equil_prof.zZi = zZi;
equil_prof.zmi = zmi;
equil_prof.pTe = pTe;
equil_prof.pne = pne;
equil_prof.pzTi = pzTi;
equil_prof.pzni = pzni;
%

