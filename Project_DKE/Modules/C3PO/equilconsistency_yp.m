function [gradpkin,gradpmag,jpar,jparz] = equilconsistency_yp(equil,equil_fit,prho)
%
% Test the consistency of the interpolated magnetic equilibrium
%
% INPUT
%
%    - equil_in: numerical magnetic equilibrium structure
%    - equil_fit: interpolated magnetic equilibrium structure
%    - prho: radial grid
%
%
% OUTPUT: 
%
%    - gradpkin: module of the kinetic pressure gradient (from density and temperature profiles) 
%    - gradpmag: module of the magnetic pressure gradient (from B-field) 
%    - jpar: parallel current density 
%    - jparz: axial component of the parallel current density 
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
mtheta = 105;
theta = linspace(0,2*pi,mtheta);
dtheta = theta(2)-theta(1);
%
prho = 101;
rho = linspace(0.01,1,prho);
drho = rho(2)-rho(1);
%
for irho = 1:length(rho),
    for itheta = 1:length(theta),
    %
    [Te(irho,itheta),dTedrho(irho,itheta),d2Tedrho2(irho,itheta),ne(irho,itheta),dnedrho(irho,itheta),d2nedrho2(irho,itheta),zTi{irho,itheta},dzTidrho{irho,itheta},d2zTidrho2{irho,itheta},zni{irho,itheta},dznidrho{irho,itheta},d2znidrho2{irho,itheta},...
        x(irho,itheta),dxdtheta,d2xdtheta2(irho,itheta),dxdrho(irho,itheta),d2xdthetadrho(irho,itheta),y(irho,itheta),dydtheta(irho,itheta),d2ydtheta2(irho,itheta),dydrho(irho,itheta),d2ydthetadrho(irho,itheta),...
        r(irho,itheta),drdtheta,drdrho(irho,itheta),salpha(irho,itheta),dsalphadtheta(irho,itheta),dsalphadrho(irho,itheta),calpha(irho,itheta),dcalphadtheta(irho,itheta),dcalphadrho(irho,itheta),...
        Bx(irho,itheta),dBxdtheta(irho,itheta),d2Bxdtheta2(irho,itheta),dBxdrho(irho,itheta),d2Bxdthetadrho(irho,itheta),...
        By(irho,itheta),dBydtheta(irho,itheta),d2Bydtheta2(irho,itheta),dBydrho(irho,itheta),d2Bydthetadrho(irho,itheta),...
        Bz(irho,itheta),dBzdtheta(irho,itheta),d2Bzdtheta2(irho,itheta),dBzdrho(irho,itheta),d2Bzdthetadrho(irho,itheta),...
        BP(irho,itheta),dBPdtheta(irho,itheta),dBPdrho(irho,itheta),B(irho,itheta),dBdtheta(irho,itheta),dBdrho(irho,itheta),...
        gradrhon(irho,itheta),dgradrhondtheta(irho,itheta),dgradrhondrho(irho,itheta),...
	    Upsilon(irho,itheta),dUpsilondrho(irho,itheta),dUpsilondtheta(irho,itheta)] = equilval_yp(equil_fit,rho(irho),theta(itheta),1);
    %
    B(irho,itheta) = sqrt(BP(irho,itheta)*BP(irho,itheta) + Bz(irho,itheta)*Bz(irho,itheta));
    %
  end
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha,kB] = pc_dke_yp;
%
Ip = 0;
%
jparz_fsav = zeros(prho,1);
S = zeros(prho,1);
%
for irho = 1:length(rho),
  for itheta = 1:length(theta),
    %       
    gradpkinsgradrhon(irho,itheta) = (Te(irho,itheta).*dnedrho(irho,itheta) + dTedrho(irho,itheta).*ne(irho,itheta) + sum(zTi{irho,itheta}.*dznidrho{irho,itheta} + dzTidrho{irho,itheta}.*zni{irho,itheta},2))*qe*1000;%T converted from eV to J
    %
    a1 = drdrho(irho,itheta)*BP(irho,itheta)/calpha(irho,itheta) + r(irho,itheta)*dBPdrho(irho,itheta)/calpha(irho,itheta) - r(irho,itheta)*BP(irho,itheta)*dcalphadrho(irho,itheta)/calpha(irho,itheta)/calpha(irho,itheta);
    a2 = dsalphadtheta(irho,itheta)/Upsilon(irho,itheta)/calpha(irho,itheta) - salpha(irho,itheta)*dcalphadtheta(irho,itheta)/Upsilon(irho,itheta)/calpha(irho,itheta)/calpha(irho,itheta) - salpha(irho,itheta)*dUpsilondtheta(irho,itheta)/calpha(irho,itheta)/Upsilon(irho,itheta)/Upsilon(irho,itheta);
    a3 = dUpsilondtheta(irho,itheta).*Bz(irho,itheta) + Upsilon(irho,itheta)*dBzdtheta(irho,itheta);
    a4 = dUpsilondrho(irho,itheta)*Bz(irho,itheta) + Upsilon(irho,itheta)*dBzdrho(irho,itheta);
    %
    b1 = -a1*BP(irho,itheta)*calpha(irho,itheta)./r(irho,itheta);
    b2 = a2*BP(irho,itheta)*BP(irho,itheta)*Upsilon(irho,itheta).*calpha(irho,itheta)./r(irho,itheta)./gradrhon(irho,itheta);
    b3 = a3*Bz(irho,itheta)*salpha(irho,itheta)./Upsilon(irho,itheta)./r(irho,itheta)./gradrhon(irho,itheta);
    b4 = -a4*Bz(irho,itheta)/Upsilon(irho,itheta);
    %
    c1 = a1*Bz(irho,itheta)*gradrhon(irho,itheta)*calpha(irho,itheta)/r(irho,itheta)/B(irho,itheta);
    c2 = -a2*BP(irho,itheta)*Upsilon(irho,itheta)*calpha(irho,itheta)*Bz(irho,itheta)/r(irho,itheta)/B(irho,itheta);  
    c3 =  a3*BP(irho,itheta)*salpha(irho,itheta)/Upsilon(irho,itheta)/r(irho,itheta)/B(irho,itheta);   
    c4 =  -a4*BP(irho,itheta)*gradrhon(irho,itheta)/Upsilon(irho,itheta)/B(irho,itheta);  
    %
    gradpmagsgradrhon(irho,itheta) = (b1 + b2 + b3 + b4)/mu0;
    %
    jpar(irho,itheta) = (c1 + c2 + c3 + c4)/mu0;
    jparz(irho,itheta) = jpar(irho,itheta)*Bz(irho,itheta)/B(irho,itheta);
    %
    jparz_fsav(irho) = jparz_fsav(irho) + jparz(irho,itheta)*r(irho,itheta)/Upsilon(irho,itheta)/B(irho,itheta)/calpha(irho,itheta)*dtheta;
    S(irho) = S(irho) + r(irho,itheta)/Upsilon(irho,itheta)/B(irho,itheta)/calpha(irho,itheta)*dtheta;
    %
    Ip = Ip + jparz(irho,itheta)*r(irho,itheta)*dtheta*drho/gradrhon(irho,itheta)/calpha(irho,itheta);
    %
  end
end
%
jparz_fsav = jparz_fsav./S;
%
disp(['Plasma current, Ip = ',num2str(Ip/1e6),' (MA')]);
%
deltagradpsgradrhon = abs(gradpmagsgradrhon(2:end,:) - gradpkinsgradrhon(2:end,:));
%
figure('Name','Pressure gradient'),clf
leg = {'Kinetic','Magnetic','Location','NorthEast'};
[ax] = graph1D_jd(rho,gradpkinsgradrhon(:,1),0,0,'\rho','\nablap/|\nabla\rho|',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','r',2);drawnow
[ax] = graph1D_jd(rho,gradpmagsgradrhon,0,0,'\rho','\nablap/|\nabla\rho|',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],leg,NaN,NaN,'--','none','b',2);drawnow
[ax] = graph1D_jd(rho,gradpkinsgradrhon(:,1),0,0,'\rho','\nablap/|\nabla\rho|',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','r',2);drawnow
%
figure('Name','Pressure gradient differences'),clf
graph2D_jd(rho(2:end),theta,deltagradpsgradrhon,'\rho','\theta (rd)',[strrep(equil.id,'_','-'),', |\nablap/|\nabla\rho|| absolute error'],NaN,NaN,1,NaN,20);colorbar
%
figure('Name','Current density'),clf
[ax] = graph1D_jd(rho,jparz/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],NaN,NaN,NaN,'-','+','r',2);drawnow
[ax] = graph1D_jd(rho,jparz_fsav/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],NaN,NaN,NaN,'-','+','b',2);drawnow
leg = {'j_{||z}','<j_{||z}>','Location','NorthEast'};
%
L = 0;
LB = 0;
%
for itheta = 1:length(theta)-1,
    %
    L = L + r(end,itheta)*dtheta/calpha(end,itheta);
    LB = LB + r(end,itheta)*dtheta*BP(end,itheta)*BP(end,itheta)/calpha(end,itheta);
    %
end
%
VB = 0;
V = 0;
%
for irho = 1:length(rho)-1,
	for itheta = 1:length(theta)-1,
        %
        VB = VB + r(irho,itheta)*Upsilon(irho,itheta)*drho*dtheta*BP(irho,itheta)*BP(irho,itheta)/gradrhon(irho,itheta)/calpha(irho,itheta);
        V = V + r(irho,itheta)*Upsilon(irho,itheta)*drho*dtheta/gradrhon(irho,itheta)/calpha(irho,itheta);
	end
end
%
li = L*VB/LB/V;
%
disp(['Normalized internal inductance, li = ',num2str(li)]);


