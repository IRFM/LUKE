% script make_rayinit_genray
%
% Creates rayinit structure from GENRAY output files
%
% by J. Decker (RLE/MIT) <jodecker@mit.edu> and Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
clear all
close all
clc
%
%
id_rayinit = 'GENRAY';%
%
% Source file parameters
%
filename = 'genray.nc';
path_file = '../GENRAY/Source_files/';
%
% Equilibrium parameters
%
id_equil = 'CMOD_060728014_01100';%For plasma equilibrium
path_equil = '../../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Wave parameters
%
m0 = NaN;
%
method = 'spline';
%
%==========================================================================
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
% Load equilibrium
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	break
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
end
%
% load structure with NETCDF data
%
data_out_netcdf = load_netcdf_jd([path_file,filename]);
%
[id_equil_out,omega_rf,sys,sypsin,syR,syZ,syphi,...
          syNpar,sydNpar,syNperp,...
          syepol_x,syepol_y,syepol_z,syphi_x,...
          syalpha,syB,syne,syTe,...
          yP0_in,yR_in,yZ_in,yphi_in,yNtor_in,yNpol_in] = process_genray_jd(data_out_netcdf);
%
ny = length(yR_in);   
%
Rp = equil.Rp;
Zp = equil.Zp;
%
yx_in = yR_in - Rp;
yy_in = yZ_in - Zp;
%
yr_in = sqrt(yx_in.^2 + yy_in.^2);
yx_in(yx_in == 0) = eps;%-eps;
ytheta_in = atan(yy_in./yx_in) + pi*(yx_in < 0) + 2*pi*(yx_in > 0 & yy_in < 0);     
%
ptr = sqrt(equil.ptx.^2 + equil.pty.^2);
%
psi_apRp = equil.psi_apRp;
psin = psi_apRp/psi_apRp(end);
theta = equil.theta;
%
% interpolation for r at ray poloidal locations    
%
pyr_in = interp1(theta,ptr.',ytheta_in,method).';
%
% interpolation for psi at ray position (along cst theta lines)
%
for iy = 1:ny,
    ypsin_in(iy) = interp1(pyr_in(:,iy),psin,yr_in(iy),method).';
end
%
yrho_in = psi2rho_jd(equil,ypsin_in);
%
if isnan(m0),%calculate m0 from yNpol and n0 from yNtor
    yBx_in = interp2(psin,theta,equil.ptBx.',ypsin_in,ytheta_in,method);
    yBy_in = interp2(psin,theta,equil.ptBy.',ypsin_in,ytheta_in,method);
    yBPHI_in = interp2(psin,theta,equil.ptBPHI.',ypsin_in,ytheta_in,method);
    %
    yBP_in = sqrt(yBx_in.^2 + yBy_in.^2);
    yBT_in = yBPHI_in;
    yB_in = sqrt(yBP_in.^2 + yBT_in.^2);
    %
    yP_in = yBP_in./yB_in;
    yT_in = yBT_in./yB_in;
    %
    yNphi_in = yNtor_in;
    yn0_in = yR_in.*yNphi_in*omega_rf/clum;
    %
    ycalpha_in = (yBy_in.*yx_in - yBx_in.*yy_in)./yr_in./yBP_in;
    %
    if 0,%determine yNpar_in from ym0_in and yn0_in
        yNs_in = yNpol_in;
        ym0_in = yr_in.*yNs_in*omega_rf/clum./ycalpha_in;
        %
        yNpar_in = (ycalpha_in.*yP_in.*ym0_in./yr_in + sign(yBPHI_in).*yT_in.*yn0_in./yR_in)*clum/omega_rf;
        %yNpar_in = yNpol_in.*yP_in + yNtor_in.*sign(yBPHI_in).*yT_in;
        figure(1),clf
        plot(1:ny,yNpar_in,'b',1:ny,syNpar(1,:),'r--');
        legend({'From m0 and no','From syNpar(1,:)'});
    else %determine ym0_i from yNpar_inn and yn0_in
        yNpar_in = syNpar(1,:);
        %
        ym0_in = (yNpar_in*omega_rf/clum - sign(yBPHI_in).*yT_in.*yn0_in./yR_in).*yr_in./ycalpha_in./yP_in;
        %ym0_in = yr_in.*yNpol_in*omega_rf/clum./ycalpha_in;
        figure(1),clf
        plot(1:ny,yr_in.*yNpol_in*omega_rf/clum./ycalpha_in,'b',1:ny,ym0_in,'r--');
        legend({'From yNpol','From syNpar(1,:) and yNtor'});
    end        
    %
else
    ym0_in = m0*ones(1,nb);
    yNpar_in = syNpar(1,:);
end
%
% Identify the different beams
%
iy_peak = 1 + find(yP0_in(3:ny) <= yP0_in(2:ny-1) & yP0_in(1:ny-2) < yP0_in(2:ny-1));
iy_dip = 1 + find(yP0_in(3:ny) >= yP0_in(2:ny-1) & yP0_in(1:ny-2) > yP0_in(2:ny-1));
%
nb = length(iy_peak);
if length(iy_dip) ~= nb-1,
    error('individual peaks not determined')
end
%
brho_in = yrho_in(iy_peak);
btheta_in = ytheta_in(iy_peak);
bphi_in = yphi_in(iy_peak);
ym0_in = ym0_in(iy_peak);
bNpar_in = yNpar_in(iy_peak);
%
bymin = [1,iy_dip];
bymax = [iy_dip+1,ny];
%
for ib = 1:nb,
    bP0_in(ib) = sum(yP0_in(bymin(ib):bymax(ib)));
    ymin_dNpar = bymin(ib) - 1 + min(find(yP0_in(bymin(ib):bymax(ib)) >= yP0_in(iy_peak(ib))/exp(1)));
    ymax_dNpar = bymin(ib) - 1 + max(find(yP0_in(bymin(ib):bymax(ib)) >= yP0_in(iy_peak(ib))/exp(1)));
    bdNpar_in(ib) = (yNpar_in(ymax_dNpar + 1) - yNpar_in(ymin_dNpar - 1))/2;
end
%
bP0_2piRp_in = bP0_in/(2*pi*Rp);
%
rayinit.omega_rf = omega_rf;
rayinit.yrho0 = brho_in;
rayinit.ytheta0 = btheta_in;
rayinit.yphi0 = bphi_in;
rayinit.ym0 = ym0_in;
rayinit.yNpar0 = bNpar_in;
rayinit.ydNpar0 = bdNpar_in;
rayinit.yP0_2piRp = bP0_2piRp_in;
%
save_str = ['RAYINIT_',id_equil,'_',id_rayinit,'.mat'];
eval(['save ',save_str,' rayinit']);


