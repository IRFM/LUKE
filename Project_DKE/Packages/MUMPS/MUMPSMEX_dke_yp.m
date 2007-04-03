%
%Link with the parallel matrix solver package MUMPS written in FORTAN 95
%for MEX file (single processor).  
%
%Solve the linear system of equation AX=B
%
% INPUTS:
%
%	- A: Matrix [n,n]
%   - B: Vector for solving the linear system of equations AX=B [n,1]  
%   - job: MUMPS job type (1,2,3,5,6,-2) see MUMPS documentation
%  
% OUTPUTS:
%
%   - X: Solution of the linear system of equation [n,1]
%   - flag: execution flag (see the MUMPS documentation) [1,1]
%
%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
A_MUMPSMEX = MMXPC_f_t;
B_MUMPSMEX = MMXR_t;
%
if job_MUMPSMEX == 1,
   id_MUMPSMEX = initmumps;
   id_MUMPSMEX = dmumps(id_MUMPSMEX);
   id_MUMPSMEX.JOB = job_MUMPSMEX;
   id_MUMPSMEX = dmumps(id_MUMPSMEX,A_MUMPSMEX);% Call to mumps
elseif job_MUMPSMEX == 2,
   id_MUMPSMEX.JOB = job_MUMPSMEX;
   id_MUMPSMEX = dmumps(id_MUMPSMEX,A_MUMPSMEX);% Call to mumps
elseif job_MUMPSMEX == 3 | job_MUMPSMEX == 6,
   id_MUMPSMEX.JOB = job_MUMPSMEX;
   id_MUMPSMEX.RHS = full(B_MUMPSMEX);
   id_MUMPSMEX = dmumps(id_MUMPSMEX,A_MUMPSMEX);% Call to mumps
   if(norm(A_MUMPSMEX*id_MUMPSMEX.SOL - id_MUMPSMEX.RHS,'inf') > sqrt(eps))
	  warning('Precision of the matrix inversion may not be OK (MUMPSMEX)');
   end
   X_MUMPSMEX = id_MUMPSMEX.SOL;
   flag_MUMPSMEX = 0;
elseif job_MUMPSMEX == -2,
   id_MUMPSMEX.JOB = job_MUMPSMEX;
   id_MUMPSMEX = dmumps(id_MUMPSMEX);% destroy mumps instance
end



  
  
  