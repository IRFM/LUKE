function [comment] = structinfo_yp(struct,field)
%
% This function paste up to date informations for a field of any defined structure or sub-structure used by C3PO/LUKE.
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
%
comment = '';
%
if strcmp(struct,'dkeparam'),
    if strcmp(field,'grid_uniformity'),comment = 'Pitch-angle and momentum grids uniformity: (0) no, (1) yes (-1 for specific test for DKE, transient and pitch-angle grid only)';return;end
    
    
    
    
    
    comment = '';
    return;
end
if strcmp(struct,'MUMPSparam'),
	if strcmp(field,'nproc'),comment = 'Number of processor used by MUMPS solver (depends of the computer framework). Default is 1';return;end
    if strcmp(field,'thresholdpivoting'),comment = 'Relative threshold for numerical pivoting in the MUMPS partial LU decomposition (default MUMPS = 1e-2: NaN or empty or field not existing). Increasing this parameter will reduce sparcity. Less than 1.';return;end
    if strcmp(field,'precinv'),comment = 'Accuracy for the MUMPS matrix inversion.(default MUMPS: NaN or empty or field not existing). Only for the solve phase.';return;end
    comment = '';
    return;
end
if strcmp(struct,'PETScparam'),
	if strcmp(field,'nproc'),comment = 'Number of processors used by PETSc (depends of the computer framework). Default is 1';return;end
	if strcmp(field,'matrixtype'),comment = 'Matrix type used by PETSc. For SUPERLU use ''-matload_type superlu_dist'' otherwise '' ''. See PETSc documentation';return;end
	if strcmp(field,'kspmethod'),comment = 'KSP method used by PETSc. ''-ksp_type preonly'': no iteration, direct matrix solve. Otherwise ''-ksp_type bicg'' or ''-ksp_type bcgs''  for example. See PETSc documentation';return;end
	if strcmp(field,'pcmethod'),comment = 'Preconditioning method used by PETSc. ''-pc_type lu'' for SUPERLU or ''-pc-type hypre'' for HYPRE.  See PETSc documentation';return;end
	if strcmp(field,'cloop'),comment = 'First order collision selfconsistency is done internaly in C (1) or in MatLab (0)';return;end
    comment = ''; 
    return;
end
%

