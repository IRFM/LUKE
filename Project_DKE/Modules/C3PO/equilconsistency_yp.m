function [equil,gradpthermalsgradrho,gradpmagsgradrho,gradpkinsgradrho,jparz_fsav,jparz_ohm_fsav] = equilconsistency_yp(equil,equil_fit,display_mode,prho,mtheta)
% LUKE - Test the consistency of the interpolated magnetic equilibrium
%
% Test the consistency of the interpolated magnetic equilibrium
%
% INPUT
%
%    - equil_in: numerical magnetic equilibrium structure
%    - equil_fit: interpolated magnetic equilibrium structure
%    - display_mode: display the results
%       (default display_mode = 0)
%    - prho: number of radial points
%       (default prho = max(101,length(equil.psi_apRp)))
%    - mtheta: number of poloidal points
%       (default mtheta = max(105,length(equil.theta)))
%
% OUTPUT: 
%
%    - equil: equilibrium with few additional fields like ip, li consistent with the magnetic field configuration
%    - gradpthermalsgradrho: module of the thermal pressure gradient (from density and temperature profiles) 
%    - gradpmagsgradrho: module of the magnetic pressure gradient (from B-field) 
%    - gradpkinsgradrho: module of the kinetic pressure gradient (from the external equilibrium data) 
%    - jparz_fsav: axial component of the parallel current density 
%    - jparz_fsav_ohmic: axial component of the parallel current density (Ohmic term, proportional to Te^3/2)
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin == 1,
    if isfield(equil,'equil_fit'),
        equil_fit = equil.equil_fit;
    else
        info_dke_yp(2,['Vectorized form of the magnetic equilibrium ',equil.id,' is being calculated...'],0);
        equil_fit = fitequil_yp(equil);
        info_dke_yp(2,'    ...done',0);
    end
    %
    display_mode = 0;%no display
    prho = max(101,length(equil.psi_apRp));
    mtheta = max(105,length(equil.theta));
end
%
if nargin == 2,
    display_mode = 0;%no display
    prho = max(101,length(equil.psi_apRp));
    mtheta = max(105,length(equil.theta));
end
%
if nargin == 3,
    prho = max(101,length(equil.psi_apRp));
    mtheta = max(105,length(equil.theta));
end
%
if nargin == 4,
    mtheta = max(105,length(equil.theta));
end
%
rho = linspace(0.01,1,prho);
drho = rho(2)-rho(1);
%
theta = linspace(0,2*pi,mtheta);
dtheta = theta(2)-theta(1);
%
if isempty(equil_fit),    
    if isfield(equil,'equil_fit'),
        equil_fit = equil.equil_fit;
    else
        info_dke_yp(2,['Vectorized form of the magnetic equilibrium ',equil.id,' is being calculated...'],0);
        equil_fit = fitequil_yp(equil);
        info_dke_yp(2,'    ...done',0);
        equil.equil_fit = equil_fit;
    end
end
%
[Te,dTedrho,d2Tedrho2,...
    ne,dnedrho,d2nedrho2,...
    zTi,dzTidrho,d2zTidrho2,...
    zni,dznidrho,d2znidrho2,...
    x,dxdtheta,d2xdtheta2,dxdrho,d2xdthetadrho,...
    y,dydtheta,d2ydtheta2,dydrho,d2ydthetadrho,...
    r,drdtheta,drdrho,...
    salpha,dsalphadtheta,dsalphadrho,...
    calpha,dcalphadtheta,dcalphadrho,...
    Bx,dBxdtheta,d2Bxdtheta2,dBxdrho,d2Bxdthetadrho,...
    By,dBydtheta,d2Bydtheta2,dBydrho,d2Bydthetadrho,...
    Bz,dBzdtheta,d2Bzdtheta2,dBzdrho,d2Bzdthetadrho,...
    BP,dBPdtheta,dBPdrho,B,dBdtheta,dBdrho,...
    gradrho,dgradrhodtheta,dgradrhodrho,...
    Upsilon,dUpsilondrho,dUpsilondtheta] = equilval_yp(equil_fit,rho,theta,1);

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
if ~isempty(zni) && ~isempty(zTi) && ~isempty(Te) && ~isempty(ne')
    pthermal_ion = sum(zTi.*zni,2);
    dpthermal_iondrho = sum(zTi.*dznidrho + dzTidrho.*zni,2);
    %
    pthermal = (Te.*ne  + pthermal_ion)*qe*1000;%T converted from eV to J
    gradpthermalsgradrho = (Te.*dnedrho + dTedrho.*ne + dpthermal_iondrho)*qe*1000;%T converted from eV to J
else
    pthermal_ion = NaN;
    dpthermal_iondrho = NaN;
    pthermal = NaN;
    gradpthermalsgradrho = NaN;
end   
%
a1 = drdrho.*BP./calpha + r.*dBPdrho./calpha - r.*BP.*dcalphadrho./calpha./calpha;
a2 = dsalphadtheta./Upsilon./calpha - salpha.*dcalphadtheta./Upsilon./calpha./calpha - salpha.*dUpsilondtheta./calpha./Upsilon./Upsilon;
a4 = dUpsilondrho.*Bz + Upsilon.*dBzdrho;
%
b1 = -a1.*BP.*calpha./r;
b2 = a2.*BP.*BP.*Upsilon.*calpha./r./gradrho;
b4 = -a4.*Bz./Upsilon;
%
c1 = a1.*Bz.*gradrho.*calpha./r./B;
c2 = -a2.*BP.*Upsilon.*calpha.*Bz./r./B;  
c4 =  -a4.*BP.*gradrho./Upsilon./B;
%
gradpmagsgradrho = (b1 + b2 + b4)./mu0;
%
jpar = (c1 + c2 + c4)./mu0;
jparz = jpar.*Bz./B;
%
jparz_fsav = sum(jparz.*r./Upsilon./BP./calpha.*dtheta,2);
S = sum(r./Upsilon./BP./calpha.*dtheta,2);
%
Ip = sum(sum(jparz.*r.*dtheta*drho./gradrho./calpha));
Ip_fsav = sum(jparz_fsav.*S);
%
Surf = sum(sum(abs(r./gradrho./calpha)*dtheta*drho));
%
if isfield(equil,'eqdsk')
    gradpkinsgradrho = equil.eqdsk.gradpkinsgradrho;
else
    gradpkinsgradrho = [];
end
%
jparz_fsav = jparz_fsav./S;
%
%keyboard
if isfield(equil,'eqdsk')
    %
	%jparz_eqdsk = 
%jparz_eqdsk_fsav = jparz_eqdsk./Bz./B.


%Ip_eqdsk_fsav = 

end
%
for j = 1:6,
    jparz_fsav_cyl(:,j) = j*Ip*(1 - rho(:).^2).^(j-1)/pi/equil_fit.ap/equil_fit.ap/1e6;
end
%
Surf_cyl = pi*equil_fit.ap*equil_fit.ap;
%
if ~isempty(zni) && ~isempty(zTi) && ~isempty(Te) && ~isempty(ne')
    jparz_ohm = (Te*ones(1,mtheta)).^1.5;
    jparz_ohm_fsav = sum(jparz_ohm.*r./Upsilon.*Bz./B./BP./calpha.*dtheta,2);
    Ip_ohm = sum(sum(jparz_ohm.*r.*dtheta.*drho./gradrho./calpha));
    %
    jparz_ohm_fsav = abs(jparz_ohm_fsav*Ip/Ip_ohm./S).*sign(jparz_fsav);
else
    jparz_ohm = NaN;
    jparz_ohm_fsav = NaN;
    Ip_ohm = NaN;
    %
    jparz_ohm_fsav = NaN;
end
%
L = sum(r(end,:).*dtheta./calpha(end,:));
LB = sum(r(end,:).*dtheta.*BP(end,:)./calpha(end,:));
%
VB2 = sum(sum(r.*Upsilon.*drho.*dtheta.*BP.*BP./gradrho./calpha));
V = sum(sum(r.*Upsilon.*drho.*dtheta./gradrho./calpha));
%
li = L*L*VB2/LB/LB/V;
%
[pshift,pelong,ptrian,pli] = equilmoments_jd(equil.theta,equil.ptx,equil.pty,mtheta);
%
disp(['Plasma current, Ip = ',num2str(Ip/1e6),' (MA)']);
disp(['Normalized internal inductance, li = ',num2str(li)]);
disp(['Shafranov shift = ',num2str(pshift(end))]);
disp(['Plasma elongation = ',num2str(pelong(end))]);
disp(['Plasma triangularity = ',num2str(ptrian(end))]);
%
if display_mode,
    %
    %keyboard
    figure('Name','Pressure gradient'),clf
    if isfield(equil,'eqdsk')
        if ~isnan(jparz_ohm_fsav),
            leg = {'Thermal','Kinetic','Magnetic','Location','SouthWest'};
        else
            leg = {'Kinetic','Magnetic','Location','SouthWest'};
        end
    else
        if ~isnan(jparz_ohm_fsav),
            leg = {'Thermal','Magnetic','Location','SouthWest'};
        else
            leg = {'Magnetic','Location','SouthWest'};
        end
    end
    if ~isnan(jparz_ohm_fsav),
        [ax] = graph1D_jd(rho,gradpthermalsgradrho(:,1),0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','r',2);drawnow
    end
    if isfield(equil,'eqdsk')
        [ax] = graph1D_jd(equil.eqdsk.prho,equil.eqdsk.gradpkinsgradrho,0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','g',1);
        [ax] = graph1D_jd(rho,gradpmagsgradrho,0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],NaN,NaN,NaN,'--','none','b',2);
        if ~isnan(jparz_ohm_fsav),
            [ax] = graph1D_jd(rho,gradpthermalsgradrho(:,1),0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','r',2);drawnow
        end
        [ax] = graph1D_jd(equil.eqdsk.prho,equil.eqdsk.gradpkinsgradrho,0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),leg,NaN,NaN,'-','none','g',1);
    else
        [ax] = graph1D_jd(rho,gradpmagsgradrho,0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','b',2);drawnow
        if ~isnan(jparz_ohm_fsav),
            [ax] = graph1D_jd(rho,gradpthermalsgradrho(:,1),0,0,'\rho','\nablap\cdot\psi/|\nabla\rho|',strrep(equil.id,'_','-'),leg,NaN,NaN,'-','none','r',2);drawnow
        end
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
    if ~isnan(jparz_ohm_fsav),
        [ax] = graph1D_jd(rho,jparz_ohm_fsav/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],leg,NaN,NaN,'-','none','g',1);drawnow
    end
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
    %
end
%
equil.ip = Ip;
equil.li = li;
