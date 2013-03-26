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
id_simul = 'Runaway_bounce_val';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil_cyl = 'TScyl';%For plasma equilibrium
id_equil = 'TScirc_e1';%For plasma equilibrium
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
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
[equil_cyl] = load_structures_yp('equil',id_equil_cyl,path_equil);
%
%************************************************************************************************************************************
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
dkeparam.tn = 10000;%time for asymptotic solution with norm_mode_f = 1
dkeparam.dtn = 1000;%10 time steps required for accurate runaway solution - see rundke_dtn
%
dkeparam.psin_S = psin_S;
iar_list = [0.1,0.2,0.3,0.5,0.8];
%
epsi = 0.04;
betath = 0.001;%validated for NR limit
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
equil_cyl.pTe = betath^2*mc2*ones(size(equil_cyl.pTe));
equil_cyl.pzTi = betath^2*mc2*ones(size(equil_cyl.pzTi));
%equil_cyl.pzTi = 1e-10*ones(size(equil_cyl.pzTi));
%
ohm_cyl = ohm_flat(equil_cyl,epsi);
ohm = ohm_flat(equil,epsi);
%
dkeparam.np_S = 201;
dkeparam.nmhu_S = 201;
%
ap = equil.ptx(end,1);
rho_list = iar_list*equil.Rp/ap;
%
nrho = length(rho_list);
RR_0 = NaN(1,nrho);
RR = NaN(1,nrho);
%
for irho = 1:nrho,
    %
    dkeparam.bounce_mode = 1;
    dkeparam.mhu_S = [];
    %
    dkeparam.rho_S = rho_list(irho);
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    if dke_out.residu_f{end}(end) <= dkeparam.prec0_f,
        RR(irho) = dke_out.XxRR_fsav(end,:);
    end  
    %
    dkeparam.bounce_mode = 0;
    dkeparam.mhu_S = momentumDKE.mhu_S;
    %
    dkeparam.rho_S = 0.5;
    %
    [Znorm_cyl,Zcurr_cyl,ZP0_cyl,dke_out_cyl] = main_dke_yp(id_simul,dkepath,equil_cyl,dkeparam,dkedisplay,ohm_cyl,waves,transpfaste,ripple,[],[]);
    if dke_out_cyl.residu_f{end}(end) <= dkeparam.prec0_f,
        RR_0(irho) = dke_out_cyl.XxRR_fsav(end,:);
    end        
end
%	    
%************************************************************************************************************************************
%
RRn = RR./RR_0;
%
%************************************************************************************************************************************
%
format
%
delete res_runaway_val
%
diary res_runaway_val
%
disp(['Comparison LUKE/Coppi/Connor - NR calculations (betath = 0.001)'])
disp(['----------------------'])
disp(['--> eps = 0.1 : RR/RR_cyl = ',num2str(RRn(1))]) 
disp(['--> eps = 0.2 : RR/RR_cyl = ',num2str(RRn(2))]) 
disp(['--> eps = 0.3 : RR/RR_cyl = ',num2str(RRn(3))]) 
disp(['--> eps = 0.5 : RR/RR_cyl = ',num2str(RRn(4))]) 
disp(['--> eps = 0.8 : RR/RR_cyl = ',num2str(RRn(5))]) 
%
diary off
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);



