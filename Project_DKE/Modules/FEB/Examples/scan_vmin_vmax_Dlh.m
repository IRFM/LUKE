%Script for running the DKE solver (can be modified by the user for specific simulations)
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
clear mex
clear functions
close all
warning off
global nfig
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul0 = 'LH_karney';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.3,0.7];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScirc';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {''};%For RF waves contribution (put all the type of waves needed)
paths_wave = {''};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = '';%For fast electron radial transport
path_transpfaste = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ripple = '';%For fast electron magnetic ripple losses
path_ripple = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_hxr = 'TScirc';%For HXR diagnostic configuration
path_hxr = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path

%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,hxr,hxrparam] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple,'hxr',id_hxr,path_hxr);
%
%************************************************************************************************************************************
%
dkeparam.boundary_mode_f = 1;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
dkeparam.np_S = 101;
dkeparam.nmhu_S = 101;
dkeparam.pnmax_S = 30;
%
dkeparam.bounce_mode = 0;
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkedisplay.display_mode = 0;
%
vmin = [3.5];
vmax = [5.5,6.5,7.5];
D0 = logspace(-2,1,15);
%
norm = zeros(length(vmin),length(vmax),length(D0));
curr = zeros(length(vmin),length(vmax),length(D0));
Tph = zeros(length(vmin),length(vmax),length(D0));
Tph_star = zeros(length(vmin),length(vmax),length(D0));
%
itn = 0;
disp('---------------------------------------------------------------------');
for ivmin = 1:length(vmin),
    for ivmax = 1:length(vmax),
        for iD0 = 1:length(D0),
            [norm(ivmin,ivmax,iD0),curr(ivmin,ivmax,iD0),Tph(ivmin,ivmax,iD0),Tph_star(ivmin,ivmax,iD0)] = loop_scan_vmin_vmax_Dlh(vmin(ivmin),vmax(ivmax),D0(iD0),rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,hxr,hxrparam);
            itn = itn + 1;
            disp(['Iteration : ',int2str(itn),'/',int2str(length(vmin)*length(vmax)*length(D0)),' done.']);
        end
    end
end
%
figure(1),semilogx(D0,squeeze(Tph(1,:,:))),axis([-1,4,0,70]),grid on
figure(2),semilogx(D0,squeeze(Tph_star(1,:,:))),axis([-1,4,0,70]),grid on
save toto.mat