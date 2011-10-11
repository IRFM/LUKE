%
%Link with the parallel matrix solver package PARDISO written in C/C++
%for MEX file (single processor).  
%
%Solve the linear system of equation AX=B
%
% INPUTS:
%
%	- A: Matrix [n,n]
%   - B: Vector for solving the linear system of equations AX=B [n,1]  
%   - job: PARDISO job type (1,2,3,5,6,-2) see MUMPS documentation
%  
% OUTPUTS:
%
%   - X: Solution of the linear system of equation [n,1]
%   - flag: execution flag (see the PARDISO documentation) [1,1]
%
%By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr) and
%
verbose_PARDISO = false;
%
if job_PARDISOMEX == 1,
    % Initialize the PARDISO internal data structures. We've told PARDISO to
    % handle real non-symmetric matrices using the sparse direct solver.
    %
    info_PARDISO = pardisoinit(11,0);
%    info_PARDISO.iparm(3) = 6;
%    info_PARDISO.iparm(4) = 61;
%    info_PARDISO.iparm(8) = 10;
    %
elseif job_PARDISOMEX == 2,
    %
    A_PARDISOMEX = MMXPC_f_t;
    %
    % Analyze the matrix and compute a symbolic factorization.
    %
    info_PARDISO = pardisoreorder(A_PARDISOMEX,info_PARDISO,verbose_PARDISO);
    %fprintf('The factors have %d nonzero entries.\n',info_PARDISO.iparm(18));
    %
    % Compute the numeric factorization.
    %
    info_PARDISO = pardisofactor(A_PARDISOMEX,info_PARDISO,verbose_PARDISO);
    %
elseif job_PARDISOMEX == 3,
    %
    B_PARDISOMEX = MMXR_t;
    %
    % Compute the solutions X using the symbolic factorization.
    %
    [X_PARDISOMEX,info_PARDISO] = pardisosolve(A_PARDISOMEX,B_PARDISOMEX,info_PARDISO,verbose_PARDISO);
    %
    fprintf('PARDISO performed %d iterative refinement steps.\n',info_PARDISO.iparm(7));        
    %
    % Compute the residuals.
    R_PARDISOMEX = max(abs(A_PARDISOMEX*X_PARDISOMEX - B_PARDISOMEX));
    fprintf('The maximum residual for the solution X is %0.3g.\n',max(R_PARDISOMEX(:)));
    flag_PARDISOMEX = 0;
elseif job_PARDISOMEX == -2,
    % Free the PARDISO data structures.
    pardisofree(info_PARDISO);
    % clear info
end 
    
    
    
    
    
    
    
  
