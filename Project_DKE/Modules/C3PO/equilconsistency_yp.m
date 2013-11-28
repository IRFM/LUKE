function [gradpkin,gradpmag,jpar,jparz] = equilconsistency_yp(equil,equil_fit,prho,mtheta)
% LUKE - Test the consistency of the interpolated magnetic equilibrium
%
% Test the consistency of the interpolated magnetic equilibrium
%
% INPUT
%
%    - equil_in: numerical magnetic equilibrium structure
%    - equil_fit: interpolated magnetic equilibrium structure
%    - prho: number of radial points
%    - mtheta: number of poloidal points
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
if nargin == 2,
    prho = max(101,length(equil.psi_apRp));
    mtheta = max(105,length(equil.theta));
end
%
if nargin == 3,
    mtheta = max(105,length(equil.theta));
end
%
rho = linspace(0.01,1,prho);
drho = rho(2)-rho(1);
%
theta = linspace(0,2*pi,mtheta);
dtheta = theta(2)-theta(1);
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
        gradrho(irho,itheta),dgradrhodtheta(irho,itheta),dgradrhodrho(irho,itheta),...
	    Upsilon(irho,itheta),dUpsilondrho(irho,itheta),dUpsilondtheta(irho,itheta)] = equilval_yp(equil_fit,rho(irho),theta(itheta),1);
    %
    B(irho,itheta) = sqrt(BP(irho,itheta)*BP(irho,itheta) + Bz(irho,itheta)*Bz(irho,itheta));
    %
  end
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha,kB] = pc_dke_yp;
%
if isfield(equil,'eqdsk')
    equil.eqdsk.prho = psi2rho_jd(equil,equil.eqdsk.psin,'spline');
    equil.eqdsk.gradpkinsgradrho = gradient(equil.eqdsk.pp)./gradient(equil.eqdsk.prho);
end
%
Ip = 0;
Ip_ohm = 0;
Surf = 0;
%
jparz_fsav = zeros(prho,1);
S = zeros(prho,1);
jparz_ohm_fsav = zeros(prho,1);
%
for irho = 1:length(rho),
  for itheta = 1:length(theta),
    %   
    pthermal(irho,itheta) = (Te(irho,itheta).*ne(irho,itheta)  + sum(zTi{irho,itheta}.*zni{irho,itheta},2))*qe*1000;%T converted from eV to J
    gradpthermalsgradrho(irho,itheta) = (Te(irho,itheta).*dnedrho(irho,itheta) + dTedrho(irho,itheta).*ne(irho,itheta) + sum(zTi{irho,itheta}.*dznidrho{irho,itheta} + dzTidrho{irho,itheta}.*zni{irho,itheta},2))*qe*1000;%T converted from eV to J
    %
    a1 = drdrho(irho,itheta)*BP(irho,itheta)/calpha(irho,itheta) + r(irho,itheta)*dBPdrho(irho,itheta)/calpha(irho,itheta) - r(irho,itheta)*BP(irho,itheta)*dcalphadrho(irho,itheta)/calpha(irho,itheta)/calpha(irho,itheta);
    a2 = dsalphadtheta(irho,itheta)/Upsilon(irho,itheta)/calpha(irho,itheta) - salpha(irho,itheta)*dcalphadtheta(irho,itheta)/Upsilon(irho,itheta)/calpha(irho,itheta)/calpha(irho,itheta) - salpha(irho,itheta)*dUpsilondtheta(irho,itheta)/calpha(irho,itheta)/Upsilon(irho,itheta)/Upsilon(irho,itheta);
    a4 = dUpsilondrho(irho,itheta)*Bz(irho,itheta) + Upsilon(irho,itheta)*dBzdrho(irho,itheta);
    %
    b1 = -a1*BP(irho,itheta)*calpha(irho,itheta)./r(irho,itheta);
    b2 = a2*BP(irho,itheta)*BP(irho,itheta)*Upsilon(irho,itheta).*calpha(irho,itheta)./r(irho,itheta)./gradrho(irho,itheta);
    b4 = -a4*Bz(irho,itheta)/Upsilon(irho,itheta);
    %
    c1 = a1*Bz(irho,itheta)*gradrho(irho,itheta)*calpha(irho,itheta)/r(irho,itheta)/B(irho,itheta);
    c2 = -a2*BP(irho,itheta)*Upsilon(irho,itheta)*calpha(irho,itheta)*Bz(irho,itheta)/r(irho,itheta)/B(irho,itheta);  
    c4 =  -a4*BP(irho,itheta)*gradrho(irho,itheta)/Upsilon(irho,itheta)/B(irho,itheta);
    %
    gradpmagsgradrho(irho,itheta) = (b1 + b2 + b4)/mu0;
    %
    jpar(irho,itheta) = (c1 + c2 + c4)/mu0;
    jparz(irho,itheta) = jpar(irho,itheta)*Bz(irho,itheta)/B(irho,itheta);
    %
    jparz_fsav(irho) = jparz_fsav(irho) + jparz(irho,itheta)*r(irho,itheta)/Upsilon(irho,itheta)/BP(irho,itheta)/calpha(irho,itheta)*dtheta;
    S(irho) = S(irho) + r(irho,itheta)/Upsilon(irho,itheta)/BP(irho,itheta)/calpha(irho,itheta)*dtheta;
    %
    Ip = Ip + jparz(irho,itheta)*r(irho,itheta)*dtheta*drho/gradrho(irho,itheta)/calpha(irho,itheta);
    Surf = Surf + abs(r(irho,itheta)/gradrho(irho,itheta)/calpha(irho,itheta))*dtheta*drho;
    %
  end 
end
%
jparz_fsav = jparz_fsav./S;
%
for j = 1:6,
    jparz_fsav_cyl(:,j) = j*Ip*(1 - rho(:).^2).^(j-1)/pi/equil_fit.ap/equil_fit.ap/1e6;
end
%
Surf_cyl = pi*equil_fit.ap*equil_fit.ap;
%
for irho = 1:length(rho),
  for itheta = 1:length(theta),
    %   
    jparz_ohm(irho,itheta) = Te(irho,itheta).^1.5;
    %
    jparz_ohm_fsav(irho) = jparz_ohm_fsav(irho) + jparz_ohm(irho,itheta)*r(irho,itheta)/Upsilon(irho,itheta)*Bz(irho,itheta)/B(irho,itheta)/BP(irho,itheta)/calpha(irho,itheta)*dtheta;
    %
    Ip_ohm = Ip_ohm + jparz_ohm(irho,itheta)*r(irho,itheta)*dtheta*drho/gradrho(irho,itheta)/calpha(irho,itheta);
    %
  end
end
%
jparz_ohm_fsav = abs(jparz_ohm_fsav*Ip/Ip_ohm./S).*sign(jparz_fsav);
%
L = 0;
LB = 0;
%
for itheta = 1:length(theta),
    %
    L = L + r(end,itheta)*dtheta/calpha(end,itheta);
    LB = LB + r(end,itheta)*dtheta*BP(end,itheta)/calpha(end,itheta);
    %
end
%
VB2 = 0;
V = 0;
%
for irho = 1:length(rho),
	for itheta = 1:length(theta),
        %
        VB2 = VB2 + r(irho,itheta)*Upsilon(irho,itheta)*drho*dtheta*BP(irho,itheta)*BP(irho,itheta)/gradrho(irho,itheta)/calpha(irho,itheta);
        V = V + r(irho,itheta)*Upsilon(irho,itheta)*drho*dtheta/gradrho(irho,itheta)/calpha(irho,itheta);
	end
end
%
li = L*L*VB2/LB/LB/V;
%
disp(['Plasma current, Ip = ',num2str(Ip/1e6),' (MA)']);
disp(['Normalized internal inductance, li = ',num2str(li)]);
%
figure('Name','Pressure gradient'),clf
if isfield(equil,'eqdsk')
    leg = {'Thermal','Kinetic','Magnetic','Location','SouthWest'};
else
    leg = {'Thermal','Magnetic','Location','SouthWest'};
end
[ax] = graph1D_jd(rho,gradpthermalsgradrho(:,1),0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','r',2);drawnow

if isfield(equil,'eqdsk')
    [ax] = graph1D_jd(equil.eqdsk.prho,equil.eqdsk.gradpkinsgradrho,0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','g',1);
    [ax] = graph1D_jd(rho,gradpmagsgradrho,0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],NaN,NaN,NaN,'--','none','b',2);
    [ax] = graph1D_jd(rho,gradpthermalsgradrho(:,1),0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','r',2);drawnow
    [ax] = graph1D_jd(equil.eqdsk.prho,equil.eqdsk.gradpkinsgradrho,0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),leg,NaN,NaN,'-','none','g',1);
else
    [ax] = graph1D_jd(rho,gradpmagsgradrho,0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','b',2);drawnow
    [ax] = graph1D_jd(rho,gradpthermalsgradrho(:,1),0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),leg,NaN,NaN,'-','none','r',2);drawnow
end
print_jd(2,['Pressure_gradient_',equil.id]);
%
figure('Name','Current density'),clf
[ax] = graph1D_jd(rho,jparz/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi], I_{p} = ',num2str(Ip/1e6),' (MA), li = ',num2str(li)],NaN,NaN,NaN,'-','none','r',2);drawnow
[ax] = graph1D_jd(rho,jparz_fsav/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],NaN,NaN,NaN,'-','none','b',1);drawnow
leg = {'j_{||z}','<j_{||z}>','Location','NorthEast'};
axf = axis(ax);
text(0.1,axf(3)+(axf(4)-axf(3))/10, ['I_p = ',num2str(Ip/1e6),' (MA)'], 'Color', 'b','FontSize',18);
text(0.1,axf(3)+2*(axf(4)-axf(3))/10, ['l_i = ',num2str(li),], 'Color', 'b','FontSize',18);
print_jd(2,['Current_density_',equil.id]);
%
if isfield(equil,'eqdsk'),
    equilDKE = equilibrium_jd(equil,equil.eqdsk.psin,0,'spline');
    xq = qfactors_dke_yp(1,equilDKE.Rp,equilDKE.ap,equilDKE.Xx,equilDKE.Xy,equilDKE.XBx,equilDKE.XBy,equilDKE.XBphi,equilDKE.xx0,equilDKE.xB0,equilDKE.xBT0,equilDKE.xBp0);
    %
    figure('Name','Safety factor'),clf
    leg = {'Magnetic','EQDSK','Location','NorthEast'};
    if isinf(equilDKE.Rp),
        [ax] = graph1D_jd(equil.eqdsk.prho,equil.eqdsk.pq*equilDKE.Rp/equilDKE.ap,0,0,'\rho','q(\rho)*R_p/a_p',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','r',2);drawnow
        [ax] = graph1D_jd(equil.eqdsk.prho(2:end),xq,0,0,'\rho','q(\rho)*R_p/a_p',strrep(equil.id,'_','-'),leg,NaN,NaN,'-','none','b',1);drawnow
    else
        [ax] = graph1D_jd(equil.eqdsk.prho,equil.eqdsk.pq,0,0,'\rho','q(\rho)',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','r',2);drawnow
        [ax] = graph1D_jd(equil.eqdsk.prho(2:end),xq*equilDKE.ap/equilDKE.Rp,0,0,'\rho','q(\rho)',strrep(equil.id,'_','-'),leg,NaN,NaN,'-','none','b',1);drawnow
    end
    axf = axis(ax);
    text(0.1,axf(3)+9*(axf(4)-axf(3))/10, ['I_p = ',num2str(Ip/1e6),' (MA)'], 'Color', 'b','FontSize',18);
    text(0.1,axf(3)+8*(axf(4)-axf(3))/10, ['l_i = ',num2str(li),], 'Color', 'b','FontSize',18);  
    print_jd(2,['Safety factor_',equil.id]);
end
%
figure('Name','Current density and li'),clf
leg = {['<j_{||z}>, l_i=',num2str(li)],'<j_{||z (\Omega)}>','Location','NorthEast'};
[ax] = graph1D_jd(rho,jparz_fsav/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],NaN,NaN,NaN,'-','none','b',2);drawnow
[ax] = graph1D_jd(rho,jparz_ohm_fsav/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],leg,NaN,NaN,'-','none','g',1);drawnow
for j = 1:6,
    [ax] = graph1D_jd(rho,abs(jparz_fsav_cyl(:,j)),0,0,'\rho','<j_{||z}> (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi], I_{p} = ',num2str(Ip/1e6),' (MA), li = ',num2str(li)],leg,NaN,NaN,'--','none','r',1);drawnow
end
%
irho = max(find(rho <= 0.2));
text(rho(irho),abs(jparz_fsav_cyl(irho,1)), ['n = 0, l_i = ',num2str(0.5*Surf/Surf_cyl)], 'Color', 'r','FontSize',18);
text(rho(irho),abs(jparz_fsav_cyl(irho,2)), ['n = 1, l_i = ',num2str(0.91*Surf/Surf_cyl)], 'Color', 'r','FontSize',18);
text(rho(irho),abs(jparz_fsav_cyl(irho,3)), ['n = 2, l_i = ',num2str(1.21*Surf/Surf_cyl)], 'Color', 'r','FontSize',18);
text(rho(irho),abs(jparz_fsav_cyl(irho,4)), ['n = 3, l_i = ',num2str(1.45*Surf/Surf_cyl)], 'Color', 'r','FontSize',18);
text(rho(irho),abs(jparz_fsav_cyl(irho,5)), ['n = 4, l_i = ',num2str(1.67*Surf/Surf_cyl)], 'Color', 'r','FontSize',18);
text(rho(irho),abs(jparz_fsav_cyl(irho,6)), ['n = 5, l_i = ',num2str(1.80*Surf/Surf_cyl)], 'Color', 'r','FontSize',18);
%
print_jd(2,['Current_density_li_',equil.id]);
%
disp(['Normalized surface Sn = ',num2str(Surf/Surf_cyl)])
