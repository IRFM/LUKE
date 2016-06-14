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
equilval = equilval_yp(equil_fit,rho,theta);
%
Te = equilval.Te;
dTedrho = equilval.dTedrho;
d2Tedrho2 = equilval.d2Tedrho2;
%
ne = equilval.ne;
dnedrho = equilval.dnedrho;
d2nedrho2 = equilval.d2nedrho2;
%
zTi = equilval.zTi;
dzTidrho = equilval.dzTidrho;
d2zTidrho2 = equilval.d2zTidrho2;
%
zni = equilval.zni;
dznidrho = equilval.dznidrho;
d2znidrho2 = equilval.d2znidrho2;
%
x = equilval.x;
dxdtheta = equilval.dxdtheta;
d2xdtheta2 = equilval.d2xdtheta2;
dxdrho = equilval.dxdrho;
d2xdthetadrho = equilval.d2xdthetadrho;
%
y = equilval.y;
dydtheta = equilval.dydtheta;
d2ydtheta2 = equilval.d2ydtheta2;
dydrho = equilval.dydrho;
d2ydthetadrho = equilval.d2ydthetadrho;
%
r = equilval.r;
drdtheta = equilval.drdtheta;
drdrho = equilval.drdrho;
%
salpha = equilval.salpha;
dsalphadtheta = equilval.dsalphadtheta;
dsalphadrho = equilval.dsalphadrho;
%
calpha = equilval.calpha;
dcalphadtheta = equilval.dcalphadtheta;
dcalphadrho = equilval.dcalphadrho;
%
Bx = equilval.Bx;
dBxdtheta = equilval.dBxdtheta;
d2Bxdtheta2 = equilval.d2Bxdtheta2;
dBxdrho = equilval.dBxdrho;
d2Bxdthetadrho = equilval.d2Bxdthetadrho;
%
By = equilval.By;
dBydtheta = equilval.dBydtheta;
d2Bydtheta2 = equilval.d2Bydtheta2;
dBydrho = equilval.dBydrho;
d2Bydthetadrho = equilval.d2Bydthetadrho;
%
Bz = equilval.Bz;
dBzdtheta = equilval.dBzdtheta;
d2Bzdtheta2 = equilval.d2Bzdtheta2;
dBzdrho = equilval.dBzdrho;
d2Bzdthetadrho = equilval.d2Bzdthetadrho;
%
BP = equilval.BP;
dBPdtheta = equilval.dBPdtheta;
dBPdrho = equilval.dBPdrho;
%
B = equilval.B;
dBdtheta = equilval.dBdtheta;
dBdrho = equilval.dBdrho;
%
gradrho = equilval.gradrho;
dgradrhodtheta = equilval.dgradrhodtheta;
dgradrhodrho = equilval.dgradrhodrho;
%
Upsilon = equilval.Upsilon;
dUpsilondrho = equilval.dUpsilondrho;
dUpsilondtheta = equilval.dUpsilondtheta;
%
psin = equilval.psin;
dpsindrho = equilval.dpsindrho;
dxstardpsin = equilval.dxstardpsin;
ddxstardpsindrho = equilval.ddxstardpsindrho;
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha,kB] = pc_dke_yp;
%
if isfield(equil,'eqdsk')
    equil.eqdsk.prho = psi2rho_jd(equil,equil.eqdsk.psin,'spline');
    equil.eqdsk.gradpkinsgradrho = gradient(equil.eqdsk.pp)./gradient(equil.eqdsk.prho);
end
%
jparz_fsav = zeros(prho,1);
jparz_ohm_fsav = zeros(prho,1);
jperpz_fsav = zeros(prho,1);
%
Ip = 0;
Ip_ohm = 0;
%
S = zeros(prho,1);
Surf = 0;
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
a1 = drdrho.*BP./calpha + r.*dBPdrho./calpha - r.*BP.*dcalphadrho./calpha./calpha;%d(rBp/cosalpha)/drho
a2 = dsalphadtheta./Upsilon./calpha - salpha.*dcalphadtheta./Upsilon./calpha./calpha - salpha.*dUpsilondtheta./calpha./Upsilon./Upsilon;%d(sinalpha/Upsilon/cosalpha)/dtheta
a4 = dUpsilondrho.*Bz + Upsilon.*dBzdrho;%d(Upsilon*Bt)/drho
%
b1 = -a1.*BP.*calpha./r;
b2 = a2.*BP.*BP.*Upsilon.*calpha./r./gradrho;
b4 = -a4.*Bz./Upsilon;
%
c1 = a1.*Bz.*gradrho.*calpha./r./B;
c2 = -a2.*BP.*Upsilon.*calpha.*Bz./r./B;  
c4 =  -a4.*BP.*gradrho./Upsilon./B;
%
d1 = a1.*gradrho.*calpha./r;
d2 = -a2.*BP.*Upsilon.*calpha./r;
%
e1 = a1.*BP.*BP.*gradrho.*calpha./r./B./B;
e2 = -a2.*BP.*BP.*BP.*Upsilon.*calpha./r./B./B;
e4 = a4.*BP.*Bz.*gradrho./Upsilon./B./B;
%
gradpmagsgradrho = (b1 + b2 + b4)./mu0;
%
jz = (d1 + d2)./mu0;
%
jpar = (c1 + c2 + c4)./mu0;
jparz = jpar.*Bz./B;
%
jperpz = (e1 + e2 + e4)./mu0;
%
S = sum(r./Upsilon./BP./calpha.*dtheta,2);
Surf = sum(sum(abs(r./gradrho./calpha)*dtheta*drho));
%
jz_fsav = sum(jz.*r./Upsilon./BP./calpha.*dtheta,2)./S;
jparz_fsav = sum(jparz.*r./Upsilon./BP./calpha.*dtheta,2)./S;
jperpz_fsav = sum(jperpz.*r./Upsilon./BP./calpha.*dtheta,2)./S;
%
Ip_z = sum(sum(jz.*r.*dtheta*drho./gradrho./calpha));
Ip_z_fsav = abs(equil.psi_apRp(end))*sum(jz_fsav.*S./dxstardpsin(:)*drho);
%
Ip_parperpz = sum(sum((jparz + jperpz).*r.*dtheta*drho./gradrho./calpha));
Ip_parperpz_fsav = abs(equil.psi_apRp(end))*sum((jparz_fsav + jperpz_fsav).*S./dxstardpsin(:)*drho);
%
F = Bz.*(x + equil.Rp);%RBz
dFdpsi = (dBzdrho.*(x + equil.Rp) + Bz.*dxdrho).*(dxstardpsin(:)*ones(1,mtheta))/equil.psi_apRp(end)*equil.Rp;
FdFdpsi = F.*dFdpsi;
%
if isfield(equil,'eqdsk')
    %
    equilDKE = equilibrium_jd(equil,equil.eqdsk.psin,0,'spline');
    xq = qfactors_dke_yp(1,equilDKE.Rp,equilDKE.ap,equilDKE.Xx,equilDKE.Xy,equilDKE.XBx,equilDKE.XBy,equilDKE.XBphi,equilDKE.xx0,equilDKE.xB0,equilDKE.xBT0,equilDKE.xBp0);
    %
    pF_eqdsk = spline(equil.eqdsk.prho,equil.eqdsk.pF,rho)'*ones(1,length(theta));%
    pFdFdpsi_eqdsk = spline(equil.eqdsk.prho,equil.eqdsk.pFdFdpsi,rho)'*ones(1,length(theta));%
    figure,plot(rho,pFdFdpsi_eqdsk,'r',rho,FdFdpsi/3.5,'b')
    %
    pp_eqdsk = spline(equil.eqdsk.prho,equil.eqdsk.pp,rho)'*ones(1,length(theta));%
    pdpdpsi_eqdsk = spline(equil.eqdsk.prho,equil.eqdsk.pdpdpsi,rho)'*ones(1,length(theta));%
    pdpdpsi_eqdsk1 = gradient(equil.eqdsk.pp)./gradient(equil.eqdsk.psin)*abs(equil.eqdsk.psia);%
   % figure,plot(rho,pdpdpsi_eqdsk,'r',rho,pdpdpsi_eqdsk1,'b');
    %
    gradpkinsgradrho = equil.eqdsk.gradpkinsgradrho;

    
    
    keyboard
    jz_eqdsk = Upsilon.*pdpdpsi_eqdsk*equilDKE.Rp + pFdFdpsi_eqdsk./Upsilon/equilDKE.Rp;%
    %jpar_eqdsk = pdFdpsi_eqdsk.*B - mu0.*pF_eqdsk.*pdpdpsi_eqdsk.*B;%
    %
    if isfield( equil.eqdsk,'Ip'),
        Ip_eqdsk = equil.eqdsk.Ip;
    end
else
    gradpkinsgradrho = [];
    jphi_eqdsk = [];
    Ip_eqdsk = [];
end
%
for j = 1:6,
    jparz_fsav_cyl(:,j) = j*abs(Ip_z)*(1 - rho(:).^2).^(j-1)/pi/equil_fit.ap/equil_fit.ap/1e6;
end
%
Surf_cyl = pi*equil_fit.ap*equil_fit.ap;
%
if ~isempty(zni) && ~isempty(zTi) && ~isempty(Te) && ~isempty(ne),
    jparz_ohm = (Te*ones(1,mtheta)).^1.5;
    Ip_parz_ohm= sum(sum(jparz_ohm.*r.*dtheta*drho./gradrho./calpha));
    %
    jparz_ohm_fsav = sum(jparz_ohm.*r./Upsilon./BP./calpha.*dtheta,2)./S;
    Ip_parz_ohm_fsav = abs(equil.psi_apRp(end))*sum(jparz_ohm_fsav.*S./dxstardpsin(:)*drho);
    %
    jparz_ohm_fsav = abs(jparz_ohm_fsav*Ip_parperpz_fsav/Ip_parz_ohm_fsav./S).*sign(jparz_fsav);
else
    jparz_ohm = NaN;
    jparz_ohm_fsav = NaN;
    Ip_parz_ohm_fsav = NaN;
end
%
L = sum(r(end,:).*dtheta./calpha(end,:));
LB = sum(r(end,:).*dtheta.*BP(end,:)./calpha(end,:));
%
Ip_contour = LB/mu0;
%
VB2 = sum(sum(r.*Upsilon.*drho.*dtheta.*BP.*BP./gradrho./calpha));
V = sum(sum(r.*Upsilon.*drho.*dtheta./gradrho./calpha));
%
Te = equil.pTe(:)*ones(1,mtheta);
VTe = sum(sum(r.*Upsilon.*drho.*dtheta.*Te./gradrho./calpha));
Te_vol = VTe/V;%Te volumic
%
ne = equil.pne(:)*ones(1,mtheta);
Vne = sum(sum(r.*Upsilon.*drho.*dtheta.*ne./gradrho./calpha));
ne_vol = Vne/V;%Te volumic
%
for iz = 1:length(equil.zZi)
    Ti = equil.pzTi(iz,:)'*ones(1,mtheta);
    VTi = sum(sum(r.*Upsilon.*drho.*dtheta.*Ti./gradrho./calpha));
    zTi_vol(iz) = VTi/V;%Ti volumic
    %
    ni = equil.pzni(iz,:)'*ones(1,mtheta);
    Vni = sum(sum(r.*Upsilon.*drho.*dtheta.*ni./gradrho./calpha));
    zni_vol(iz) = Vni/V;%ni volumic
end
%
li = L*L*VB2/LB/LB/V;
%
[pshift,pelong,ptrian,pli] = equilmoments_jd(equil.theta,equil.ptx,equil.pty,mtheta);
%
disp(['Plasma current, Ip(from j_z) = ',num2str(Ip_z/1e6),' (MA)']);
disp(['Plasma current, Ip(from j_z_fsav) = ',num2str(Ip_z_fsav/1e6),' (MA)']);
disp(['Plasma current, Ip(from j_par_z + j_perp_z) = ',num2str(Ip_parperpz/1e6),' (MA)']);
disp(['Plasma current, Ip(from j_par_z_fsav + j_perp_z_fsav) = ',num2str(Ip_parperpz_fsav/1e6),' (MA)']);
disp(['Plasma current, Ip(from contour) = ',num2str(Ip_contour/1e6),' (MA)']);
if ~isempty(Ip_eqdsk),
    disp(['Plasma current, Ip(eqdsk) = ',num2str(Ip_eqdsk/1e6),' (MA)']);
end
disp('-------------------------------------------------------------')
disp(['Normalized internal inductance, li = ',num2str(li)]);
disp('-------------------------------------------------------------')
disp(['Shafranov shift = ',num2str(pshift(end))]);
disp(['Plasma elongation = ',num2str(pelong(end))]);
disp(['Plasma triangularity = ',num2str(ptrian(end))]);
%
if display_mode,
    %
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
    figure('Name','Axial current density'),clf
    [ax] = graph1D_jd(rho,jz/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi], I_{p} = ',num2str(Ip_z/1e6),' (MA), li = ',num2str(li)],NaN,NaN,NaN,'-','none','r',2);drawnow
    [ax] = graph1D_jd(rho,jz_fsav/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],NaN,NaN,NaN,'-','none','b',1);drawnow
    if isfield(equil,'eqdsk'),
        %[ax] = graph1D_jd(equil.eqdsk.prho,jz_eqdsk/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi], I_{p} = ',num2str(Ip/1e6),' (MA), li = ',num2str(li)],NaN,NaN,NaN,'-','none','g',2);drawnow
    end
    %
    leg = {'j_{z}','<j_{z}>','<j_{z}>_{(eqdsk)}','Location','NorthEast'};
    axf = axis(ax);
    text(0.1,axf(3)+(axf(4)-axf(3))/10, ['I_p = ',num2str(Ip_z/1e6),' (MA)'], 'Color', 'b','FontSize',18);
    text(0.1,axf(3)+2*(axf(4)-axf(3))/10, ['l_i = ',num2str(li),], 'Color', 'b','FontSize',18);
    print_jd(2,['Axial_current_density_',equil.id]);
    %
    figure('Name','Axial component of the parallel current density'),clf
    [ax] = graph1D_jd(rho,jparz/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi], I_{p} = ',num2str(Ip_z/1e6),' (MA), li = ',num2str(li)],NaN,NaN,NaN,'-','none','r',2);drawnow
    [ax] = graph1D_jd(rho,jparz_fsav/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],NaN,NaN,NaN,'-','none','b',1);drawnow
    if isfield(equil,'eqdsk'),
        %[ax] = graph1D_jd(equil.eqdsk.prho,jparz_eqdsk/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi], I_{p} = ',num2str(Ip/1e6),' (MA), li = ',num2str(li)],NaN,NaN,NaN,'-','none','g',2);drawnow
    end
    %
    leg = {'j_{||z}','<j_{||z}>','Location','NorthEast'};
    axf = axis(ax);
    text(0.1,axf(3)+(axf(4)-axf(3))/10, ['I_p = ',num2str(Ip_parperpz/1e6),' (MA)'], 'Color', 'b','FontSize',18);
    text(0.1,axf(3)+2*(axf(4)-axf(3))/10, ['l_i = ',num2str(li),], 'Color', 'b','FontSize',18);
    print_jd(2,['Parallel_z_current_density_',equil.id]);
    %
    figure('Name','Axial component of the perpendicular current density'),clf
    [ax] = graph1D_jd(rho,jperpz/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi], I_{p} = ',num2str(Ip_z/1e6),' (MA), li = ',num2str(li)],NaN,NaN,NaN,'-','none','r',2);drawnow
    [ax] = graph1D_jd(rho,jperpz_fsav/1e6,0,0,'\rho','j_{||z} (MA/m^{2})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],NaN,NaN,NaN,'-','none','b',1);drawnow
    %
    leg = {'j_{perpz}','<j_{perpz}>','Location','NorthEast'};
    axf = axis(ax);
    text(0.1,axf(3)+(axf(4)-axf(3))/10, ['I_p = ',num2str(Ip_parperpz/1e6),' (MA)'], 'Color', 'b','FontSize',18);
    text(0.1,axf(3)+2*(axf(4)-axf(3))/10, ['l_i = ',num2str(li),], 'Color', 'b','FontSize',18);
    print_jd(2,['Perpendicular_z_current_density_',equil.id]);
    %
    if isfield(equil,'eqdsk'),
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
        text(0.1,axf(3)+9*(axf(4)-axf(3))/10, ['I_p = ',num2str(Ip_z/1e6),' (MA)'], 'Color', 'b','FontSize',18);
        text(0.1,axf(3)+8*(axf(4)-axf(3))/10, ['l_i = ',num2str(li),], 'Color', 'b','FontSize',18);  
        print_jd(2,['Safety_factor_',equil.id]);
        %
        figure('Name','Current flux function'),clf
        %
        if ~isinf(equilDKE.Rp),
            [ax] = graph1D_jd(rho,pF_eqdsk(:,1),0,0,'\rho','F(\psi)=RB_{\phi} [mT]',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','r',2);drawnow
            [ax] = graph1D_jd(rho,F(:,1),0,0,'\rho','F(\psi)=RB_{\phi} [mT]',strrep(equil.id,'_','-'),leg,NaN,NaN,'-','none','b',1);drawnow
            leg = {'EQDSK','Magnetic','Location','NorthEast'};
            [ax] = graph1D_jd(rho,pF_eqdsk(:,2:end),0,0,'\rho','F(\psi)=RB_{\phi} [mT]',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','r',2);drawnow
            [ax] = graph1D_jd(rho,F(:,2:end),0,0,'\rho','F(\psi)=RB_{\phi} [mT]',strrep(equil.id,'_','-'),leg,NaN,NaN,'-','none','b',1);drawnow
        end
        axf = axis(ax);
        text(0.1,axf(3)+9*(axf(4)-axf(3))/10, ['I_p = ',num2str(Ip_z/1e6),' (MA)'], 'Color', 'b','FontSize',18);
        text(0.1,axf(3)+8*(axf(4)-axf(3))/10, ['l_i = ',num2str(li),], 'Color', 'b','FontSize',18);  
        print_jd(2,['Current_flux_function_',equil.id]);
        %
        figure('Name','Flux derivative of the current flux function'),clf
        leg = {'Magnetic','EQDSK','Location','NorthEast'};
        %
        if ~isinf(equilDKE.Rp),
            [ax] = graph1D_jd(rho,pFdFdpsi_eqdsk,0,0,'\rho','q(\rho)',strrep(equil.id,'_','-'),NaN,NaN,NaN,'-','none','r',2);drawnow
            [ax] = graph1D_jd(rho,dFdpsi,0,0,'\rho','F(\psi)',strrep(equil.id,'_','-'),leg,NaN,NaN,'-','none','b',1);drawnow
        end
        axf = axis(ax);
        text(0.1,axf(3)+9*(axf(4)-axf(3))/10, ['I_p = ',num2str(Ip_z/1e6),' (MA)'], 'Color', 'b','FontSize',18);
        text(0.1,axf(3)+8*(axf(4)-axf(3))/10, ['l_i = ',num2str(li),], 'Color', 'b','FontSize',18);  
        print_jd(2,['Flux_derivative _urrent_flux_function_',equil.id]);
        %

    end
    %
    if ~isnan(jparz_ohm_fsav),
        %
        figure('Name','Current density and li'),clf 
        [ax] = graph1D_jd(rho,jparz_fsav/1e6/max(abs(jparz_fsav/1e6)),0,0,'\rho','j_{||z}/max(j_{||z})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],NaN,NaN,NaN,'-','none','b',2);drawnow
        [ax] = graph1D_jd(rho,jparz_ohm_fsav/1e6,0,0,'\rho','j_{||z}/max(j_{||z})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi]'],leg,NaN,NaN,'-','none','g',1);drawnow
        %       
        leg = {['<j_{||z}>, l_i=',num2str(li)],'<j_{||z}>_{Ohm}','Location','NorthEast'};
        %
        for j = 1:6,
            [ax] = graph1D_jd(rho,jparz_fsav_cyl(:,j)/max(abs(jparz_fsav_cyl(:,j))),0,0,'\rho','j_{||z}/max(j_{||z})',[strrep(equil.id,'_','-'),', \theta\in[0:\pi/',int2str((mtheta-1)/2),':2\pi], I_{p} = ',num2str(Ip/1e6),' (MA), li = ',num2str(li)],leg,NaN,NaN,'--','none','r',1);drawnow
        end
        %
        text(0.02,0.52, '<j_{||z}>_{circ.} ~ (1-\rho^2)^n', 'Color', 'r','FontSize',18);
        text(0.02,0.44, ['n = 5, l_i = ',num2str(1.80)], 'Color', 'r','FontSize',18);
        text(0.02,0.36, ['n = 4, l_i = ',num2str(1.67)], 'Color', 'r','FontSize',18);
        text(0.02,0.28, ['n = 3, l_i = ',num2str(1.45)], 'Color', 'r','FontSize',18);
        text(0.02,0.20, ['n = 2, l_i = ',num2str(1.21)], 'Color', 'r','FontSize',18);
        text(0.02,0.12, ['n = 1, l_i = ',num2str(0.91)], 'Color', 'r','FontSize',18);
        text(0.02,0.04, ['n = 0, l_i = ',num2str(0.5)], 'Color', 'r','FontSize',18);
        %
        print_jd(2,['Current_density_li_',equil.id]);
    end
    %
    disp(['Normalized surface Sn = ',num2str(Surf/Surf_cyl)])
    %
end
%
equil.ip = Ip;
equil.li = li;
equil.Te_vol = Te_vol;
equil.ne_vol = ne_vol;
equil.zTi_vol = zTi_vol;
equil.zni_vol = zni_vol;



