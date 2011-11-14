function graph_comp_RT_jd(rays,legs,equil_fit,filename,opt)
%
% This function compares C3PO results using numerical and analytical forms for the equilibrium.
%
if nargin == 0,
    disp('No ray to be displayed.')
    return
else
    nb = length(rays);
end
%
if nargin < 5,
    p_opt = -1;
    ntheta_fit = 65;
    nrho_fit = 15;
    propvar = 0;% (0) : ray.ss, (1) : ray.sphi/(2*pi)
else
    p_opt = opt.p_opt;
    ntheta_fit = opt.ntheta_fit;
    nrho_fit = opt.nrho_fit;
    propvar = opt.propvar;% (0) : ray.ss, (1) : ray.sphi/(2*pi)    
end
if nargin < 4,
    filename = 'Fig';
end
if nargin < 3,
    equil_fit = '';
elseif ~isempty(equil_fit) && (~isstruct(equil_fit) || (length(equil_fit) ~= 1 && length(equil_fit) ~= nb)),
    error('equils_fit must be a structure array of length 1 or nb.')
end
if nargin < 2 || isempty(legs),
    legs = cell(2,nb);
    for ib = 1:nb,
        legs{1,ib} = [ 'Ray # ',num2str(ib)];% for figure legend
        legs{2,ib} = [ 'Ray_',num2str(ib)];% for filename
    end
elseif size(legs,1) == 1,%automatic filenames
    for ib = 1:nb,
        legs{2,ib} = [ 'Ray_',num2str(ib)];% for filename
    end
end
%
% For poloidal ray trajectory comparison
%
rho_fit = linspace(0,1,nrho_fit);
theta_fit = linspace(0,2*pi,ntheta_fit);
phi_fit = linspace(0,2*pi,ntheta_fit);
%
neq = length(equil_fit);
%
Rmin = NaN(1,neq);
Rmax = NaN(1,neq);
Zmin = NaN(1,neq);
Zmax = NaN(1,neq);
%
for ieq = 1:neq,
    equil_fit(ieq).x_a0_fit = ppval(equil_fit(ieq).x_fit.pp_a0,rho_fit);
    equil_fit(ieq).x_an_fit = ppval(equil_fit(ieq).x_fit.pp_an,rho_fit);
    equil_fit(ieq).x_bn_fit = ppval(equil_fit(ieq).x_fit.pp_bn,rho_fit);
    equil_fit(ieq).y_a0_fit = ppval(equil_fit(ieq).y_fit.pp_a0,rho_fit);
    equil_fit(ieq).y_an_fit = ppval(equil_fit(ieq).y_fit.pp_an,rho_fit);
    equil_fit(ieq).y_bn_fit = ppval(equil_fit(ieq).y_fit.pp_bn,rho_fit);
    %
    equil_fit(ieq).R_fit = NaN(nrho_fit,ntheta_fit);
    equil_fit(ieq).Z_fit = NaN(nrho_fit,ntheta_fit);
    %
    for ii = 1:ntheta_fit,
        equil_fit(ieq).R_fit(:,ii) = equil_fit(ieq).Rp + equil_fit(ieq).x_a0_fit.' + ...
            equil_fit(ieq).x_an_fit*cos(equil_fit(ieq).x_fit.n*theta_fit(ii)) + equil_fit(ieq).x_bn_fit*sin(equil_fit(ieq).x_fit.n*theta_fit(ii));
        equil_fit(ieq).Z_fit(:,ii) = equil_fit(ieq).Zp + equil_fit(ieq).y_a0_fit.' + ...
            equil_fit(ieq).y_an_fit*cos(equil_fit(ieq).y_fit.n*theta_fit(ii)) + equil_fit(ieq).y_bn_fit*sin(equil_fit(ieq).y_fit.n*theta_fit(ii));
    end
    %
    Rmin(ieq) = min(min(equil_fit(ieq).R_fit));
    Rmax(ieq) = max(max(equil_fit(ieq).R_fit));
    Zmin(ieq) = min(min(equil_fit(ieq).Z_fit));
    Zmax(ieq) = max(max(equil_fit(ieq).Z_fit));
    %
end
%
Rmin = min(Rmin);
Rmax = max(Rmax);
Zmin = min(Zmin);
Zmax = max(Zmax);
%
style = '-';
style1 = '--';
style2 = 'none';
marker = 'none';
marker2 = '.';
colors = {'r','b','g','m','c','y'};
width = 0.5;
width2 = 2;
siz = 20+14i;
red = 0.9;
lspace = 0.7;
bspace = 0.5;
%
ncol = length(colors);
%
if neq > 0,
    %
    Xmin_fit = Rmin*cos(phi_fit);   
    Ymin_fit = Rmin*sin(phi_fit); 
    Xmax_fit = Rmax*cos(phi_fit);   
    Ymax_fit = Rmax*sin(phi_fit); 
    %
    % --- all rays ---
    %
    figure('Name','Poloidal ray trajectories')
    axis('equal');
    for ib = 1:nb,
        ieq = min([ib,neq]);%equil_fit number
        graph1D_jd(rays{ib}.sx + equil_fit(ieq).Rp,rays{ib}.sy + equil_fit(ieq).Zp,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],style,marker,colors{rem(ib,ncol)},width2);
    end
    graph1D_jd(equil_fit(1).R_fit,equil_fit(1).Z_fit,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],style,marker,'k',width);
    graph1D_jd(equil_fit(1).R_fit.',equil_fit(1).Z_fit.',0,0,'R(m)','Z(m)','Poloidal Ray trajectories',legs(1,:),[Rmin,Rmax],[Zmin,Zmax],style,marker,'k',width,siz,gca,red,lspace,bspace);
    print_jd(p_opt,[filename,'_poloidal_trajectories']);
    %
    figure('Name','Toroidal ray trajectories')
    axis('equal');
    for ib = 1:nb,
        ieq = min([ib,neq]);%equil_fit number
        graph1D_jd((rays{ib}.sx + equil_fit(ieq).Rp).*cos(-rays{ib}.sphi),(rays{ib}.sx + equil_fit(ieq).Rp).*sin(-rays{ib}.sphi),0,0,'','','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],style,marker,colors{rem(ib,ncol)},width2);
    end
    graph1D_jd(Xmin_fit,Ymin_fit,0,0,'','','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],style,marker,'k',width);
    graph1D_jd(Xmax_fit,Ymax_fit,0,0,'','','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],style,marker,'k',width);
    graph1D_jd(equil_fit(1).Rp*cos(phi_fit),equil_fit(1).Rp*sin(phi_fit),0,0,'X(m)','Y(m)','Toroidal Ray trajectories',legs(1,:),[-Rmax,Rmax],[-Rmax,Rmax],style1,marker,'k',width,siz,gca,red,lspace,bspace);
    print_jd(p_opt,[filename,'_toroidal_trajectories']);
    %
    % --- each ray, with polarization ---
    %
    leg = {'mode p','mode m'};
    for ib = 1:nb,
        figure('Name',['Poloidal ray trajectory - ',legs{2,ib}])
        axis('equal');
        ieq = min([ib,neq]);%equil_fit number
        graph1D_jd(rays{ib}.sx(rays{ib}.spmode == 1) + equil_fit(ieq).Rp,rays{ib}.sy(rays{ib}.spmode == 1) + equil_fit(ieq).Zp,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],style2,marker2,'r',width2);
        graph1D_jd(rays{ib}.sx(rays{ib}.spmode ~= 1) + equil_fit(ieq).Rp,rays{ib}.sy(rays{ib}.spmode ~= 1) + equil_fit(ieq).Zp,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],style2,marker2,'b',width2);
        graph1D_jd(equil_fit(ieq).R_fit,equil_fit(ieq).Z_fit,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],style,marker,'k',width);
        graph1D_jd(equil_fit(ieq).R_fit.',equil_fit(ieq).Z_fit.',0,0,'R(m)','Z(m)',['Poloidal Ray trajectory - ',legs{2,ib}],leg,[Rmin,Rmax],[Zmin,Zmax],style,marker,'k',width,siz,gca,red,lspace,bspace);
        print_jd(p_opt,[filename,'_poloidal_trajectory_',legs{2,ib}]);
        %
        figure('Name',['Toroidal ray trajectory - ',legs{2,ib}])
        axis('equal');
        ieq = min([ib,neq]);%equil_fit number
        graph1D_jd((rays{ib}.sx(rays{ib}.spmode == 1) + equil_fit(ieq).Rp).*cos(-rays{ib}.sphi(rays{ib}.spmode == 1)),(rays{ib}.sx(rays{ib}.spmode == 1) + equil_fit(ieq).Rp).*sin(-rays{ib}.sphi(rays{ib}.spmode == 1)),0,0,'','','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],style2,marker2,'r',width2);
        graph1D_jd((rays{ib}.sx(rays{ib}.spmode ~= 1) + equil_fit(ieq).Rp).*cos(-rays{ib}.sphi(rays{ib}.spmode ~= 1)),(rays{ib}.sx(rays{ib}.spmode ~= 1) + equil_fit(ieq).Rp).*sin(-rays{ib}.sphi(rays{ib}.spmode ~= 1)),0,0,'','','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],style2,marker2,'b',width2);
        graph1D_jd(Xmin_fit,Ymin_fit,0,0,'','','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],style,marker,'k',width);
        graph1D_jd(Xmax_fit,Ymax_fit,0,0,'','','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],style,marker,'k',width);
        graph1D_jd(equil_fit(ieq).Rp*cos(phi_fit),equil_fit(ieq).Rp*sin(phi_fit),0,0,'X(m)','Y(m)',['Toroidal Ray trajectory - ',legs{2,ib}],leg,[-Rmax,Rmax],[-Rmax,Rmax],style1,marker,'k',width,siz,gca,red,lspace,bspace);
        print_jd(p_opt,[filename,'_toroidal_trajectory_',legs{2,ib}]);
    end
end
%
xlim = NaN;
if propvar == 0,
    propfield = 'ss';
    proplab = 'ray length (m)';
    propfac = 1;
else
    propfield = 'sphi';
    proplab = '|\phi|/(2\pi)';
    propfac = 2*pi;
end
%
% --- radial position ---
%
figure('Name','Normalized radial position')
ylim = [0,1];
for ib = 1:nb,
    ieq = min([ib,neq]);%equil_fit number
    graph1D_jd(abs(rays{ib}.(propfield))/propfac,rays{ib}.srho,0,0,'','','',NaN,xlim,ylim,style,marker,colors{rem(ib,ncol)},width2);
end
graph1D_jd(abs(rays{nb}.(propfield))/propfac,rays{nb}.srho,0,0,proplab,'\rho','Normalized radial position',NaN,xlim,ylim,style,marker,colors{rem(nb,ncol)},width2,siz,gca,red,lspace,bspace);
print_jd(p_opt,[filename,'_RhoComp']);
%
% --- poloidal position ---
%
figure('Name','Normalized poloidal position')
for ib = 1:nb,
    ieq = min([ib,neq]);%equil_fit number
    graph1D_jd(abs(rays{ib}.(propfield))/propfac,rays{ib}.stheta/(2*pi),0,0,'','','',NaN,xlim,ylim,style,marker,colors{rem(ib,ncol)},width2);
end
graph1D_jd(abs(rays{nb}.(propfield))/propfac,rays{nb}.stheta/(2*pi),0,0,proplab,'\theta/(2\pi)','Normalized poloidal position',NaN,xlim,ylim,style,marker,colors{rem(nb,ncol)},width2,siz,gca,red,lspace,bspace);
print_jd(p_opt,[filename,'_ThetaComp']);
%
% --- toroidal position ---
%
figure('Name','Normalized toroidal position')
for ib = 1:nb,
    ieq = min([ib,neq]);%equil_fit number
    graph1D_jd(abs(rays{ib}.(propfield))/propfac,rays{ib}.sphi/(2*pi),0,0,'','','',NaN,xlim,ylim,style,marker,colors{rem(ib,ncol)},width2);
end
graph1D_jd(abs(rays{nb}.(propfield))/propfac,rays{nb}.sphi/(2*pi),0,0,proplab,'\phi/(2\pi)','Normalized toroidal position',NaN,xlim,ylim,style,marker,colors{rem(nb,ncol)},width2,siz,gca,red,lspace,bspace);
print_jd(p_opt,[filename,'_PhiComp']);
%
% --- parallel wave refractive index ---
%
figure('Name','Parallel wave refractive index')
ylim = NaN;
for ib = 1:nb,
    ieq = min([ib,neq]);%equil_fit number
    graph1D_jd(abs(rays{ib}.(propfield))/propfac,real(rays{ib}.sNpar),0,0,'','','',NaN,xlim,ylim,style,marker,colors{rem(ib,ncol)},width2);
end
graph1D_jd(abs(rays{nb}.(propfield))/propfac,real(rays{nb}.sNpar),0,0,proplab,'N_{||}','Parallel wave refractive index',NaN,xlim,ylim,style,marker,colors{rem(nb,ncol)},width2,siz,gca,red,lspace,bspace);
print_jd(p_opt,[filename,'_NparComp']);
%
% --- perpendicular wave refractive index ---
%
figure('Name','Perpendicular wave refractive index')
ylim = NaN;
for ib = 1:nb,
    ieq = min([ib,neq]);%equil_fit number
    graph1D_jd(abs(rays{ib}.(propfield))/propfac,rays{ib}.sNperp,0,0,'','','',NaN,xlim,ylim,style,marker,colors{rem(ib,ncol)},width2);
end
graph1D_jd(abs(rays{nb}.(propfield))/propfac,rays{nb}.sNperp,0,0,proplab,'N_{||}','Perpendicular wave refractive index',NaN,xlim,ylim,style,marker,colors{rem(nb,ncol)},width2,siz,gca,red,lspace,bspace);
print_jd(p_opt,[filename,'_NperpComp']);
%
% --- dispersion relation ---
%
figure('Name','Dispersion relation')
ylim = NaN;
for ib = 1:nb,
    ieq = min([ib,neq]);%equil_fit number
    graph1D_jd(abs(rays{ib}.(propfield))/propfac,rays{ib}.sD,0,1,'','','',NaN,xlim,ylim,style,marker,colors{rem(ib,ncol)},width2);
end
graph1D_jd(abs(rays{nb}.(propfield))/propfac,rays{nb}.sD,0,1,proplab,'det(D)','Dispersion relation',NaN,xlim,ylim,style,marker,colors{rem(nb,ncol)},width2,siz,gca,red,lspace,bspace);
print_jd(p_opt,[filename,'_DispComp']);
%
% --- cold plasma mode ---
%
figure('Name','Cold plasma mode')
ylim = NaN;
for ib = 1:nb,
    ieq = min([ib,neq]);%equil_fit number
    graph1D_jd(abs(rays{ib}.(propfield))/propfac,rays{ib}.spmode,0,1,'','','',NaN,xlim,ylim,style,marker,colors{rem(ib,ncol)},width2);
end
graph1D_jd(abs(rays{nb}.(propfield))/propfac,rays{nb}.spmode,0,1,proplab,'p mode','Cold plasma mode',NaN,xlim,ylim,style,marker,colors{rem(nb,ncol)},width2,siz,gca,red,lspace,bspace);
print_jd(p_opt,[filename,'_PmodeComp']);
%
