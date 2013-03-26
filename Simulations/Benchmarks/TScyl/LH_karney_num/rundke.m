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
p_opt = 2;
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_num';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.5];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'NO_DISPLAY';%For output code display
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
%
%************************************************************************************************************************************
%
wavestruct.omega_lh = [4]*2*pi*1e9; %(GHz -> rad/s). Wave frequency [1,1] Indicative, no effect in small FLR limit opt_lh > 0
%Option parameter for cross-comparison between old LH code: 
%	- (1): 1/vpar dependence
%	- (2): no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
wavestruct.opt_lh = 2; % [1,1]
%
% Choose (vparmin_lh,vparmax_lh) or (Nparmin_lh,Nparmax_lh) for square n// LH wave power spectrum,
% or (Npar_lh,dNpar_lh) for Gaussian shape
%
wavestruct.norm_ref = 1;%Normalization procedure for the LH quasilinear diffusion coefficient and spectrum boundaries
%
wavestruct.yvparmin_lh = [4];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [7];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
wavestruct.yNparmin_lh = [NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
wavestruct.yNparmax_lh = [NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
wavestruct.yNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
wavestruct.ydNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
%   Note: this diffusion coefficient is different from the general QL D0. It has a benchmarking purpose only 
wavestruct.yD0_in_c_lh = [1];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
%     
wavestruct.yD0_in_lh_prof = [0];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
wavestruct.ypeak_lh = [NaN];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
wavestruct.ywidth_lh = [NaN];%Radial width of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
%
wavestruct.ythetab_lh = [0]*pi/180;%(deg -> rad). Poloidal location of LH beam [0..2pi] [1,n_scenario_lh]
%               (0) from local values Te and ne, (1) from central values Te0 and ne0 
%
%************************************************************************************************************************************
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
%
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
% with norm_mode_f = 0, uncomment n-1 plots
%
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
% with coll_mode = 2, uncomment nit plots
%
dkeparam.coll_mode = 0;% Relativistic Maxwellian background
%
waves{1} = make_idealLHwave_jd(equil,wavestruct);
%
dkeparam.mlmaxitinv = 20;%Maximum number of iterations for iterative built-in MatLab matrix inversion method (between 1 and 20 usualy, if empty, mlmaxitinv = min(matrixdim,20). See matlab documentation.
dkeparam.mlprecinv = 1e-6;%Accuracy for the MatLab build-in matrix inversion. (default : 1e-6)
%
% Direct MATLAB inversion
%
dkeparam.invproc = 0;
%
[Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
memory_ML = dke_out.memoryLU_f_out;
time_ML = dke_out.time_DKE;
%
nit_ML = length(dke_out.residu_f{end});
%
norm_ML = Znorm.x_0;
curr_ML = Zcurr.x_0;
Prf_ML = ZP0.x_rf_fsav;
Pcoll_ML = ZP0.x_c_fsav;
%
disp(['Direct MatLab inversion done'])
%
% Exact LU factorization
%
dkeparam.invproc = 1;%MATLAB-CGS
dkeparam.ludroptol = 0;%Full LU factorization for preconditionning
%
[Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
memory_LU = dke_out.memoryLU_f_out;
time_LU = dke_out.time_DKE;
%
nit_LU = length(dke_out.residu_f{end});
%
norm_LU = Znorm.x_0;
curr_LU = Zcurr.x_0;
Prf_LU = ZP0.x_rf_fsav;
Pcoll_LU = ZP0.x_c_fsav;
%
disp('Full LU calculation done')
%
% Incomplete LU factorization
%
ludroptol_list = logspace(-8,-2,7);
mlprecinv_list = logspace(-8,-2,7);
iludrop = 1;
imlprecinv = 1;
%
nludroptol = length(ludroptol_list);
nmlprecinv = length(mlprecinv_list);
%
memory_LUi_1 = NaN(nludroptol,3);
time_LUi_1 = NaN(nludroptol,3);
nit_LUi_1 = NaN(nludroptol,3);
norm_LUi_1 = NaN(nludroptol,3);
curr_LUi_1 = NaN(nludroptol,3);
Prf_LUi_1 = NaN(nludroptol,3);
Pcoll_LUi_1 = NaN(nludroptol,3);
%
memory_LUi_2 = NaN(nmlprecinv,3);
time_LUi_2 = NaN(nmlprecinv,3);
nit_LUi_2 = NaN(nmlprecinv,3);
norm_LUi_2 = NaN(nmlprecinv,3);
curr_LUi_2 = NaN(nmlprecinv,3);
Prf_LUi_2 = NaN(nmlprecinv,3);
Pcoll_LUi_2 = NaN(nmlprecinv,3);
%
for imeth = 1:3,%Numerical method (CGS, BICG, QMR)
    %
    dkeparam.invproc  = imeth;
    %
    dkeparam.mlprecinv = 1e-6;%Accuracy for the MatLab build-in matrix inversion. (default : 1e-6)
    %
    for iludroptol = 1:nludroptol,%droptolerance scan
        %
        dkeparam.ludroptol = ludroptol_list(iludroptol);
        %
        try
            %
            [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
            % 
            memory_LUi_1(iludroptol,imeth) = dke_out.memoryLU_f_out;
            time_LUi_1(iludroptol,imeth) = dke_out.time_DKE;
            %
            nit_LUi_1(iludroptol,imeth) = length(dke_out.residu_f{end});
            %
            norm_LUi_1(iludroptol,imeth) = Znorm.x_0;
            curr_LUi_1(iludroptol,imeth) = Zcurr.x_0;
            Prf_LUi_1(iludroptol,imeth) = ZP0.x_rf_fsav;
            Pcoll_LUi_1(iludroptol,imeth) = ZP0.x_c_fsav;
            %
            disp(['Calculation with MatLab incomplete LU calculation #',int2str(iludroptol),' with matrix inversion method #',int2str(imeth),'  done'])
        catch
            disp(['Calculation with MatLab incomplete LU calculation #',int2str(iludroptol),' with matrix inversion method #',int2str(imeth),'  failed'])
        end
        %
    end
    %
    dkeparam.ludroptol = 1e-6;%Accuracy for the MatLab build-in matrix inversion. (default : 1e-6)
    %
    for imlprecinv = 1:nmlprecinv,%droptolerance scan
        %
        dkeparam.mlprecinv = mlprecinv_list(imlprecinv);
        %
        try
            %
            [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
            % 
            memory_LUi_2(imlprecinv,imeth) = dke_out.memoryLU_f_out;
            time_LUi_2(imlprecinv,imeth) = dke_out.time_DKE;
            %
            nit_LUi_2(imlprecinv,imeth) = length(dke_out.residu_f{end});
            %
            norm_LUi_2(imlprecinv,imeth) = Znorm.x_0;
            curr_LUi_2(imlprecinv,imeth) = Zcurr.x_0;
            Prf_LUi_2(imlprecinv,imeth) = ZP0.x_rf_fsav;
            Pcoll_LUi_2(imlprecinv,imeth) = ZP0.x_c_fsav;
            %
            disp(['Calculation with MatLab incomplete LU calculation #',int2str(imlprecinv),' with matrix inversion method #',int2str(imeth),'  done'])
        catch
            disp(['Calculation with MatLab incomplete LU calculation #',int2str(imlprecinv),' with matrix inversion method #',int2str(imeth),'  failed'])
        end
        %
    end
    %
end
%
eta_LU = curr_LU./Prf_LU;
eta_LUi_1 = curr_LUi_1./Prf_LUi_1;
eta_LUi_2 = curr_LUi_2./Prf_LUi_2;
etaerr_LUi_1 = abs(eta_LUi_1 - eta_LU)/eta_LU;
etaerr_LUi_2 = abs(eta_LUi_2 - eta_LU)/eta_LU;
%
disp('Incomplete LU calculation done')
%
% MUMPS package
%
if isfield(dkepath,'MUMPS') && (isfield(dkepath.MUMPS,'seq') || isfield(dkepath.MUMPS,'par')),
    dkeparam.invproc = -1;
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    memory_MU = dke_out.memoryLU_f_out;
    time_MU = dke_out.time_DKE;
    %
    nit_MU = length(dke_out.residu_f{end});
    %
    norm_MU = Znorm.x_0;
    curr_MU = Zcurr.x_0;
    Prf_MU = ZP0.x_rf_fsav;
    Pcoll_MU = ZP0.x_c_fsav;
    %
    disp(['Direct MUMPS calculation done'])
end
%
% MUMPSMEX package
%
if exist('dmumpsmex','file'),
    dkeparam.invproc = -2;
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    memory_MX = dke_out.memoryLU_f_out;
    time_MX = dke_out.time_DKE;
    %
    nit_MX = length(dke_out.residu_f{end});
    %
    norm_MX = Znorm.x_0;
    curr_MX = Zcurr.x_0;
    Prf_MX = ZP0.x_rf_fsav;
    Pcoll_MX = ZP0.x_c_fsav;
    %
    disp(['MUMPSMEX calculation done'])
else
    memory_MX = NaN;
    time_MX = NaN;
    nit_MX = NaN;
    norm_MX = NaN;
    curr_MX = NaN;
    Prf_MX = NaN;
    Pcoll_MX = NaN;
    %
    disp(['MUMPSMEX calculation skipped'])
end
%
eta_MX = curr_MX./Prf_MX;
etaerr_MX = abs(eta_MX - eta_LU)/eta_LU;
%
% SUPERLU package
%
if exist('mexlusolve'),
    dkeparam.invproc = -3;
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    memory_SX = dke_out.memoryLU_f_out;
    time_SX = dke_out.time_DKE;
    %
    nit_SX = length(dke_out.residu_f{end});
    %
    norm_SX = Znorm.x_0;
    curr_SX = Zcurr.x_0;
    Prf_SX = ZP0.x_rf_fsav;
    Pcoll_SX = ZP0.x_c_fsav;
    %
    disp(['SUPERLUMEX calculation done'])
end
%
% PETSc package
%
if isfield(dkepath,'PETSc'),
    dkeparam.invproc = -30;
    dkeparam.PETScparam.nproc = 1;%number of processor used by PETSc (depends of the computer framework). Default is 1
    %
    [flag,message] = unix('uname -n');
    %
    if strfind(message,'saturne'),%this option runs only on the SATURNE CEA-DRFC cluster
        dkeparam.PETScparam.matrixtype = '-matload_type superlu_dist';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
        dkeparam.PETScparam.kspmethod = '-ksp_type preonly';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
        dkeparam.PETScparam.pcmethod = '-pc_type lu';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation
        %
        dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
        %
        [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        %
        memory_PS0 = dke_out.memoryLU_f_out;
        time_PS0 = dke_out.time_DKE;
        %
        nit_PS0 = length(dke_out.residu_f{end});
        %
        norm_PS0 = Znorm.x_0;
        curr_PS0 = Zcurr.x_0;
        Prf_PS0 = ZP0.x_rf_fsav;
        Pcoll_PS0 = ZP0.x_c_fsav;
        %
        disp(['PETSc/SUPERLU calculation done (first collision operator loop in MatLab).'])
        %
        dkeparam.PETScparam.cloop = 1;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
        %
        [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        %
        memory_PS1 = dke_out.memoryLU_f_out;
        time_PS1 = dke_out.time_DKE;
        %
        nit_PS1 = length(dke_out.residu_f{end});
        %
        norm_PS1 = Znorm.x_0;
        curr_PS1 = Zcurr.x_0;
        Prf_PS1 = ZP0.x_rf_fsav;
        Pcoll_PS1 = ZP0.x_c_fsav;
        %
        disp(['PETSc/SUPERLU calculation done (first collision operator loop in C).'])
        %
        flag_PETSC = 1;
    else
        flag_PETSC = 0;
    end
    %
    dkeparam.PETScparam.matrixtype = '';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
    dkeparam.PETScparam.kspmethod = '-ksp_type bcgs';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
    dkeparam.PETScparam.pcmethod = '';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation
    %
    dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    memory_PB0 = dke_out.memoryLU_f_out;
    time_PB0 = dke_out.time_DKE;
    %
    nit_PB0 = length(dke_out.residu_f{end});
    %
    norm_PB0 = Znorm.x_0;
    curr_PB0 = Zcurr.x_0;
    Prf_PB0 = ZP0.x_rf_fsav;
    Pcoll_PB0 = ZP0.x_c_fsav;
    %
    disp(['PETSc/BCGS calculation done (first collision operator loop in MatLab).'])
    %
    dkeparam.PETScparam.cloop = 1;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    memory_PB1 = dke_out.memoryLU_f_out;
    time_PB1 = dke_out.time_DKE;
    %
    nit_PB1 = length(dke_out.residu_f{end});
    %
    norm_PB1 = Znorm.x_0;
    curr_PB1 = Zcurr.x_0;
    Prf_PB1 = ZP0.x_rf_fsav;
    Pcoll_PB1 = ZP0.x_c_fsav;
    %
    disp(['PETSc/BCGS calculation done (first collision operator loop in C).'])  
end
%
%************************************************************************************************************************************
%
figure(1),clf
%
leg = {'CGS','BICG','QMR','MUMPSMEX'};
xlim = 10.^[-9,-1];
ylim = [0,2];%[0,20];%
xlab = '\delta_{LU}';
ylab = 'FPE calculation time (s)';
tit = '';
siz = 20+14i;
%
graph1D_jd(ludroptol_list,time_LUi_1(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(ludroptol_list,time_LUi_1(:,2),1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
graph1D_jd(ludroptol_list,time_LUi_1(:,3),1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
graph1D_jd(xlim,[time_MX,time_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
% figure(2),clf
% %
% ylim = NaN;
% ylab = 'n-1';
% %
% graph1D_jd(ludroptol_list,norm_LUi_1(:,1)-1,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
% graph1D_jd(ludroptol_list,norm_LUi_1(:,2)-1,1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
% graph1D_jd(ludroptol_list,norm_LUi_1(:,3)-1,1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
% graph1D_jd(xlim,[norm_MX-1,norm_MX-1],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
% %
% %set(gca,'ytick',[0:0.2:1]*ylim(2))
% set(gca,'xtick',10.^[-9:-1])
% set(gca,'XMinorGrid','off')
% set(gca,'XMinorTick','on')
%
figure(3),clf
%
ylim = [0,0.005];
ylab = 'j';
%
graph1D_jd(ludroptol_list,curr_LUi_1(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(ludroptol_list,curr_LUi_1(:,2),1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
graph1D_jd(ludroptol_list,curr_LUi_1(:,3),1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
graph1D_jd(xlim,[curr_MX,curr_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(4),clf
%
ylim = [0,0.0002];
ylab = 'P';
%
graph1D_jd(ludroptol_list,Prf_LUi_1(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(ludroptol_list,Prf_LUi_1(:,2),1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
graph1D_jd(ludroptol_list,Prf_LUi_1(:,3),1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
graph1D_jd(xlim,[Prf_MX,Prf_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
graph1D_jd(ludroptol_list,-Pcoll_LUi_1(:,1),1,0,'','','',NaN,xlim,ylim,'-','o','r',2,siz,gca);
graph1D_jd(ludroptol_list,-Pcoll_LUi_1(:,2),1,0,'','','',NaN,xlim,ylim,'-','o','b',2,siz,gca);
graph1D_jd(ludroptol_list,-Pcoll_LUi_1(:,3),1,0,'','','',NaN,xlim,ylim,'-','o','g',2,siz,gca);
graph1D_jd(xlim,[-Pcoll_MX,-Pcoll_MX],1,0,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(5),clf
%
ylim = [0,50];
ylab = '\eta';
%
graph1D_jd(ludroptol_list,eta_LUi_1(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(ludroptol_list,eta_LUi_1(:,2),1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
graph1D_jd(ludroptol_list,eta_LUi_1(:,3),1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
graph1D_jd(xlim,[eta_MX,eta_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(6),clf
%
ylim = 10.^[-16,0];
ylab = 'Relative Error on \eta';
%
graph1D_jd(ludroptol_list,etaerr_LUi_1(:,1),1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(ludroptol_list,etaerr_LUi_1(:,2),1,1,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
graph1D_jd(ludroptol_list,etaerr_LUi_1(:,3),1,1,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
graph1D_jd(xlim,[etaerr_MX,etaerr_MX],1,1,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',10.^[-16:2:0])
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
% %
% figure(7),clf
% %
% ylim = [0,50];
% ylab = 'Number of Legendre iterations';
% %
% graph1D_jd(ludroptol_list,nit_LUi_1(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
% graph1D_jd(ludroptol_list,nit_LUi_1(:,2),1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
% graph1D_jd(ludroptol_list,nit_LUi_1(:,3),1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
% graph1D_jd(xlim,[nit_MX,nit_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
% %
% set(gca,'ytick',[0:0.2:1]*ylim(2))
% set(gca,'xtick',10.^[-9:-1])
% set(gca,'XMinorGrid','off')
% set(gca,'XMinorTick','on')
%
figure(8),clf
%
leg = {'MATLAB','MUMPS'};
ylim = [0,50];
ylab = 'LU matrix size (MBytes)';
%
graph1D_jd(ludroptol_list,memory_LUi_1(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(xlim,[memory_MX,memory_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(9),clf
%
leg = {'CGS','BICG','QMR','MUMPSMEX'};
xlim = 10.^[-9,-1];
ylim = [0,2];%[0,20];%
xlab = 'Iterative method tolerance';
ylab = 'FPE calculation time (s)';
tit = '';
siz = 20+14i;
%
graph1D_jd(mlprecinv_list,time_LUi_2(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(mlprecinv_list,time_LUi_2(:,2),1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
graph1D_jd(mlprecinv_list,time_LUi_2(:,3),1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
graph1D_jd(xlim,[time_MX,time_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
% figure(10),clf
% %
% ylim = NaN;
% ylab = 'n-1';
% %
% graph1D_jd(mlprecinv_list,norm_LUi_2(:,1)-1,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
% graph1D_jd(mlprecinv_list,norm_LUi_2(:,2)-1,1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
% graph1D_jd(mlprecinv_list,norm_LUi_2(:,3)-1,1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
% graph1D_jd(xlim,[norm_MX-1,norm_MX-1],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
% %
% %set(gca,'ytick',[0:0.2:1]*ylim(2))
% set(gca,'xtick',10.^[-9:-1])
% set(gca,'XMinorGrid','off')
% set(gca,'XMinorTick','on')
%
figure(11),clf
%
ylim = [0,0.005];
ylab = 'j';
%
graph1D_jd(mlprecinv_list,curr_LUi_2(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(mlprecinv_list,curr_LUi_2(:,2),1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
graph1D_jd(mlprecinv_list,curr_LUi_2(:,3),1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
graph1D_jd(xlim,[curr_MX,curr_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(12),clf
%
ylim = [0,0.0002];
ylab = 'P';
%
graph1D_jd(mlprecinv_list,Prf_LUi_2(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(mlprecinv_list,Prf_LUi_2(:,2),1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
graph1D_jd(mlprecinv_list,Prf_LUi_2(:,3),1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
graph1D_jd(xlim,[Prf_MX,Prf_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
graph1D_jd(mlprecinv_list,-Pcoll_LUi_2(:,1),1,0,'','','',NaN,xlim,ylim,'-','o','r',2,siz,gca);
graph1D_jd(mlprecinv_list,-Pcoll_LUi_2(:,2),1,0,'','','',NaN,xlim,ylim,'-','o','b',2,siz,gca);
graph1D_jd(mlprecinv_list,-Pcoll_LUi_2(:,3),1,0,'','','',NaN,xlim,ylim,'-','o','g',2,siz,gca);
graph1D_jd(xlim,[-Pcoll_MX,-Pcoll_MX],1,0,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(13),clf
%
ylim = [0,50];
ylab = '\eta';
%
graph1D_jd(mlprecinv_list,eta_LUi_2(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(mlprecinv_list,eta_LUi_2(:,2),1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
graph1D_jd(mlprecinv_list,eta_LUi_2(:,3),1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
graph1D_jd(xlim,[eta_MX,eta_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(14),clf
%
ylim = 10.^[-12,-3];
ylab = 'Relative Error on \eta';
%
graph1D_jd(mlprecinv_list,etaerr_LUi_2(:,1),1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(mlprecinv_list,etaerr_LUi_2(:,2),1,1,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
graph1D_jd(mlprecinv_list,etaerr_LUi_2(:,3),1,1,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
graph1D_jd(xlim,[etaerr_MX,etaerr_MX],1,1,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',10.^[-12:-3])
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
% figure(15),clf
% %
% ylim = [0,50];
% ylab = 'Number of Legendre iterations';
% %
% graph1D_jd(mlprecinv_list,nit_LUi_2(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
% graph1D_jd(mlprecinv_list,nit_LUi_2(:,2),1,0,'','','',NaN,xlim,ylim,'-','+','b',2,siz,gca);
% graph1D_jd(mlprecinv_list,nit_LUi_2(:,3),1,0,'','','',NaN,xlim,ylim,'-','+','g',2,siz,gca);
% graph1D_jd(xlim,[nit_MX,nit_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
% %
% set(gca,'ytick',[0:0.2:1]*ylim(2))
% set(gca,'xtick',10.^[-9:-1])
% set(gca,'XMinorGrid','off')
% set(gca,'XMinorTick','on')
%
figure(16),clf
%
leg = {'MATLAB','MUMPS'};
ylim = [0,50];
ylab = 'LU matrix size (MBytes)';
%
graph1D_jd(mlprecinv_list,memory_LUi_2(:,1),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(xlim,[memory_MX,memory_MX],1,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',10.^[-9:-1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
print_jd(p_opt,'fig_num_lutol_time','./figures',1)
%print_jd(p_opt,'fig_num_lutol_n','./figures',2)
print_jd(p_opt,'fig_num_lutol_j','./figures',3)
print_jd(p_opt,'fig_num_lutol_P','./figures',4)
print_jd(p_opt,'fig_num_lutol_eta','./figures',5)
print_jd(p_opt,'fig_num_lutol_etarel','./figures',6)
%print_jd(p_opt,'fig_num_lutol_nit','./figures',7)
print_jd(p_opt,'fig_num_lutol_memory','./figures',8)
%
print_jd(p_opt,'fig_num_ittol_time','./figures',9)
%print_jd(p_opt,'fig_num_ittol_n','./figures',10)
print_jd(p_opt,'fig_num_ittol_j','./figures',11)
print_jd(p_opt,'fig_num_ittol_P','./figures',12)
print_jd(p_opt,'fig_num_ittol_eta','./figures',13)
print_jd(p_opt,'fig_num_ittol_etarel','./figures',14)
%print_jd(p_opt,'fig_num_ittol_nit','./figures',15)
print_jd(p_opt,'fig_num_ittol_memory','./figures',16)
%
delete testmatinv.txt
%
diary testmatinv.txt
%
% disp('-------------------')
% disp('Direct Matlab Inversion')
% disp(['droptolerance: 0 - Full CPU time: ',num2str(time_ML),' (s) - LU memory size: ',num2str(memory_ML),' (MBytes)'])
% disp(['n: ',num2str(norm_ML),' - j: ',num2str(curr_ML),' - PLH: ',num2str(Prf_ML),' - Pcoll: ',num2str(Pcoll_ML)])
%
disp('-------------------')
disp('Full LU precondtionning, CGS iterative Krylov algorithm')
disp(['droptolerance: 0 - Full CPU time: ',num2str(time_LU),' (s) - LU memory size: ',num2str(memory_LU),' (MBytes) - Number of Leg. Iterations: ',num2str(nit_LU)])
disp(['n: ',num2str(norm_LU),' - j: ',num2str(curr_LU),' - PLH: ',num2str(Prf_LU),' - Pcoll: ',num2str(Pcoll_LU)])
%
disp('-------------------')
disp('Incomplete LU precondtionning, CGS iterative Krylov algorithm')
disp(['droptolerance: ',num2str(ludroptol_list(iludrop)),' - Full CPU time: ',num2str(time_LUi_1(iludrop,1)),' (s) - LU memory size: ',num2str(memory_LUi_1(iludrop,1)),' (MBytes) - Number of Leg. Iterations: ',num2str(nit_LUi_1(iludrop,1))])
disp(['n: ',num2str(norm_LUi_1(iludrop,1)),' - j: ',num2str(curr_LUi_1(iludrop,1)),' - PLH: ',num2str(Prf_LUi_1(iludrop,1)),' - Pcoll: ',num2str(Pcoll_LUi_1(iludrop,1))])
%
if isfield(dkepath,'MUMPS') & (isfield(dkepath.MUMPS,'seq') | isfield(dkepath.MUMPS,'par')),
    disp('-------------------')
    disp('Direct matrix inversion MUMPS')
    disp(['droptolerance: 0 - Full CPU time: ',num2str(time_MU),' (s) - LU memory size: ',num2str(memory_MU),' (MBytes) - Number of Leg. Iterations: ',num2str(nit_MU)])
    disp(['n: ',num2str(norm_MU),' - j: ',num2str(curr_MU),' - PLH: ',num2str(Prf_MU),' - Pcoll: ',num2str(Pcoll_MU)])
end
if exist('dmumpsmex'),
    disp('-------------------')
    disp('Matrix inversion MUMPSMEX')
    disp(['droptolerance: 0 - Full CPU time: ',num2str(time_MX),' (s) - LU memory size: ',num2str(memory_MX),' (MBytes) - Number of Leg. Iterations: ',num2str(nit_MX)])
    disp(['n: ',num2str(norm_MX),' - j: ',num2str(curr_MX),' - PLH: ',num2str(Prf_MX),' - Pcoll: ',num2str(Pcoll_MX)])
end
if exist('mexlusolve'),
    disp('-------------------')
    disp('Matrix inversion SUPERLUMEX')
    disp(['droptolerance: 0 - Full CPU time: ',num2str(time_SX),' (s) - LU memory size: ',num2str(memory_SX),' (MBytes) - Number of Leg. Iterations: ',num2str(nit_SX)])
    disp(['n: ',num2str(norm_SX),' - j: ',num2str(curr_SX),' - PLH: ',num2str(Prf_SX),' - Pcoll: ',num2str(Pcoll_SX)])
end
if isfield(dkepath,'PETSc'),
    if flag_PETSC == 1,
        disp('-------------------')
        disp('Matrix inversion PETSc/SUPERLU, 1 processor and first order collision correction in MatLab')
        disp(['droptolerance: 0 - Full CPU time: ',num2str(time_PS0),' (s) - LU memory size: ',num2str(memory_PS0),' (MBytes) - Number of Leg. Iterations: ',num2str(nit_PS0)])
        disp(['n: ',num2str(norm_PS0),' - j: ',num2str(curr_PS0),' - PLH: ',num2str(Prf_PS0),' - Pcoll: ',num2str(Pcoll_PS0)])
        disp('-------------------')
        disp('Matrix inversion PETSc/SUPERLU, 1 processor and first order collision correction in C')
        disp(['droptolerance: 0 - Full CPU time: ',num2str(time_PS1),' (s) - LU memory size: ',num2str(memory_PS1),' (MBytes) - Number of Leg. Iterations: ',num2str(nit_PS1)])
        disp(['n: ',num2str(norm_PS1),' - j: ',num2str(curr_PS1),' - PLH: ',num2str(Prf_PS1),' - Pcoll: ',num2str(Pcoll_PS1)])
    end
    disp('-------------------')  
    disp('Matrix inversion PETSc/BCGS, 1 processor and first order collision correction in MatLab')
    disp(['droptolerance: 0 - Full CPU time: ',num2str(time_PB0),' (s) - LU memory size: ',num2str(memory_PB0),' (MBytes) - Number of Leg. Iterations: ',num2str(nit_PB0)])
    disp(['n: ',num2str(norm_PB0),' - j: ',num2str(curr_PB0),' - PLH: ',num2str(Prf_PB0),' - Pcoll: ',num2str(Pcoll_PB0)])
    disp('-------------------')  
    disp('Matrix inversion PETSc/BCGS, 1 processor and first order collision correction in C')
    disp(['droptolerance: 0 - Full CPU time: ',num2str(time_PB1),' (s) - LU memory size: ',num2str(memory_PB1),' (MBytes) - Number of Leg. Iterations: ',num2str(nit_PB1)])
    disp(['n: ',num2str(norm_PB1),' - j: ',num2str(curr_PB1),' - PLH: ',num2str(Prf_PB1),' - Pcoll: ',num2str(Pcoll_PB1)])
end
%
diary off
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);