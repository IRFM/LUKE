function [XXf0,flag,text] = PETSc_Cloop_dke_ft(PETScparam,display_mode,dkepath)
%
%Link with the parallel matrix solver package PETSc written in C. The first
%order collision calculation is done in C (see PETSc_dke_ft when it is done
%in MatLab). It is assumed that all variables are passed with the
%writeCloopinput_dke_ft.m function
%
%Solve the linear system of equation AX=B(X)
%
% INPUTS:
%
%   - PETScparam: Structure for controling PETSc program. 
%   - display_mode: display some results [1,1]
%   - dkepath: paths structure
%
% OUTPUTS:
%
%   - XXf0: Solution of the linear system of equation [n,1]
%   - flag: execution flag (see the PETSC documentation) [1,1]
%   - text: execution documentation (see the PETSC documentation)

%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) ,Yves Peysson (CEA-DRFC,yves.peysson@cea.fr), Frederic Teisseire (CEA-DRFC)
%
if nargin < 3,error('Wrong number of input arguments in PETSc_Cloop_dke_ft !');end
%
flag = 0;text = '';
%
initial_dir = cd;
d = dir(dkepath.temppath);
if ~exist(dkepath.temppath);
	mkdir(dkepath.temppath);%Create calculation directory
end
cd(dkepath.temppath);%Move to calculation directory	
%
dir_in = [dkepath.temppath,'/DKESolver_variables/'];
dir_out = [dkepath.temppath,'/DKESolver_output/'];
%
% Computer management
%
nproc = nproc_dke_yp(display_mode,PETScparam,dkepath);
%
if nproc > 1,%Parallel processing is invoked
	if isfield(dkepath.PETSc,'par'),
        if display_mode >= 1,info_dke_yp(2,'Matrix inversion by PETSc solver - parallel processing -');end
        [flag,text] = unix(['mpirun -np ',int2str(nproc),' -machinefile .machines ',dkepath.PETSc.par,'/SolverLoop_DKE_c',' ',dir_in,' ',dir_out,' ',PETScparam.matrixtype,' ',PETScparam.kspmethod,' ',PETScparam.pcmethod]);      
    elseif isfield(dkepath.PETSc,'seq'),
        if display_mode >= 1,info_dke_yp(2,'Matrix inversion by PETSc solver - sequential processing enforced, no parallel processing package on this machine ! -');end
        [flag,text] = unix([dkepath.PETSc.seq,'/SolverLoop_DKE_c',' ',dir_in,' ',dir_out,' ',PETScparam.matrixtype,' ',PETScparam.kspmethod, ' ',PETScparam.pcmethod]);
    else
        error('PETSc package not correctly named for LUKE: <pakage name+version>_P_<compiler name> or  <pakage name+version>_S_<compiler name>');
    end
elseif nproc == 1,%Sequential processing is invoked
    if isfield(dkepath.PETSc,'seq'),
        if display_mode >= 1,info_dke_yp(2,'Matrix inversion by PETSc solver - sequential processing -');end
        [flag,text] = unix([dkepath.PETSc.seq,'/SolverLoop_DKE_c',' ',dir_in,' ',dir_out,' ',PETScparam.matrixtype,' ',PETScparam.kspmethod, ' ',PETScparam.pcmethod]);
    elseif isfield(dkepath.PETSc,'par'),
        if display_mode >= 1,info_dke_yp(2,'Matrix inversion by PETSc solver - parallel processing enforced, no sequential processing package on this machine !  -');end
        [flag,text] = unix(['mpirun -np ',int2str(nproc),' -machinefile .machines ',dkepath.PETSc.par,'/SolverLoop_DKE_c',' ',dir_in,' ',dir_out,' ',PETScparam.matrixtype,' ',PETScparam.kspmethod,' ',PETScparam.pcmethod]);      
    else
        error('PETSc package not correctly named for LUKE: <pakage name+version>_P_<compiler name> or  <pakage name+version>_S_<compiler name>');
    end
end
%
if exist([dkepath.temppath,'/DKESolver_output/XXf0']),
	XXf0 = ReadBinaryArray_mex_c([dkepath.temppath,'/DKESolver_output/XXf0']);
else
	error(['PETSc is going wrong and solution XXf0 is not created in the sub-directory ',dkepath.temppath,'/DKESolver_output !']);
end
%
cd(initial_dir);%return to the initial working directory



