function graph_comp_RT_jd(ray_numeric,ray_analytic,filename,p_opt)
%
% This function compares C3PO results using numerical and analytical forms for the equilibrium.
%
if nargin < 4,
    p_opt = -1;
end
if nargin < 3,
    filename = 'Fig';
end
if nargin < 2 || isempty(ray_analytic),
    flag = 0;%only one ray displayed
else
    flag = 1;
end
%
leg = {'Numeric','Analytic'};
%
figure('Name','Normalized radial position comparison')
graph1D_jd(ray_numeric.ss,ray_numeric.srho,0,0,'ss','\rho','Normalized radial position',NaN,'','','-','none','r',2,20,gca,0.9,0.7,0.5);
if flag,graph1D_jd(ray_analytic.ss,ray_analytic.srho,0,0,'','','',leg,'','','-','none','b',2);end
print_jd(p_opt,[filename,'_RhoComp']);
%
figure('Name','Normalized poloidal position comparison')
graph1D_jd(ray_numeric.ss,ray_numeric.stheta/(2*pi),0,0,'ss','\theta/(2\pi)','Poloidal angle',NaN,'','','-','none','r',2,20,gca,0.9,0.7,0.5);
if flag,graph1D_jd(ray_analytic.ss,ray_analytic.stheta/(2*pi),0,0,'','','',leg,'','','-','none','b',2);end
print_jd(p_opt,[filename,'_ThetaComp']);
%
figure('Name','Normalized toroidal position comparison')
graph1D_jd(ray_numeric.ss,ray_numeric.sphi/(2*pi),0,0,'ss','\phi/(2\pi)','Toroidal angle',NaN,'','','-','none','r',2,20,gca,0.9,0.7,0.5);
if flag,graph1D_jd(ray_analytic.ss,ray_analytic.sphi/(2*pi),0,0,'','','',leg,'','','-','none','b',2);end
print_jd(p_opt,[filename,'_PhiComp']);
%
figure('Name','Parallel wave refractive index comparison')
graph1D_jd(ray_numeric.ss,real(ray_numeric.sNpar),0,0,'ss','N_{||}','Parallel wave refractive index',NaN,'','','-','none','r',2,20,gca,0.9,0.7,0.5);
if flag,graph1D_jd(ray_analytic.ss,ray_analytic.sNpar,0,0,'','','',leg,'','','-','none','b',2);end
print_jd(p_opt,[filename,'_NparComp']);
%
figure('Name','Perpendicular wave refractive index comparison')
graph1D_jd(ray_numeric.ss,ray_numeric.sNperp,0,0,'ss','N_{\perp}','Perpendicular wave refractive index',NaN,'','','-','none','r',2,20,gca,0.9,0.7,0.5);
if flag,graph1D_jd(ray_analytic.ss,ray_analytic.sNperp,0,0,'','','',leg,'','','-','none','b',2);end
print_jd(p_opt,[filename,'_NperpComp']);
