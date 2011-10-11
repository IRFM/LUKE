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
if ~isfield(dkeparam,'opsplit'),dkeparam.opsplit = 0;end
%
if dkeparam.opsplit == 0,
    A_MUMPSMEX = MMXPC_f_t;
    B_MUMPSMEX = MMXR_t;
    %
    if job_MUMPSMEX == 1,
        id_MUMPSMEX = initmumps;
        id_MUMPSMEX = dmumps(id_MUMPSMEX);
        id_MUMPSMEX.ICNTL(1:4) = [6,0,0,1];%no display during runtime
        id_MUMPSMEX.JOB = job_MUMPSMEX;
        id_MUMPSMEX = dmumps(id_MUMPSMEX,A_MUMPSMEX);% Call to mumps
        if isfield(dkeparam.MUMPSparam,'thresholdpivoting'),
            if ~isempty(dkeparam.MUMPSparam.thresholdpivoting) | ~isnan(dkeparam.MUMPSparam.thresholdpivoting),
                id_MUMPSMEX.CNTL(1) = dkeparam.MUMPSparam.thresholdpivoting;%Relative threshold for numerical pivoting in the MUMPS partial LU decomposition (default MUMPS = 1e-2 for non-symmetric matrices)
            end
        end
        if isfield(dkeparam.MUMPSparam,'precinv'),
            if ~isempty(dkeparam.MUMPSparam.precinv) | ~isnan(dkeparam.MUMPSparam.precinv),
                id_MUMPSMEX.CNTL(2) = dkeparam.MUMPSparam.precinv;%Drop tolerance for the MUMPS partial LU decomposition
            end
        end    
    elseif job_MUMPSMEX == 2,
       id_MUMPSMEX.JOB = job_MUMPSMEX;
       id_MUMPSMEX = dmumps(id_MUMPSMEX,A_MUMPSMEX);% Call to mumps
       if id_MUMPSMEX.INFOG(1) == -13,
            error('Error in a Fortran ALLOCATE statement in MUMPS factorization. Try reducing the problem size (grid size)');
       end
    elseif job_MUMPSMEX == 3 | job_MUMPSMEX == 6,
       id_MUMPSMEX.JOB = job_MUMPSMEX;
       id_MUMPSMEX.RHS = full(B_MUMPSMEX);
       id_MUMPSMEX = dmumps(id_MUMPSMEX,A_MUMPSMEX);% Call to mumps
       if(norm(A_MUMPSMEX*id_MUMPSMEX.SOL - id_MUMPSMEX.RHS,'inf') > sqrt(eps))
          warning('Precision of the matrix inversion may not be OK (MUMPSMEX). Try to increase the dkeparam.MUMPSparam.thresholdpivoting parameters (see MUMPS documentation).');
       end
       X_MUMPSMEX = id_MUMPSMEX.SOL;
       flag_MUMPSMEX = 0;
    elseif job_MUMPSMEX == -2,
       id_MUMPSMEX.JOB = job_MUMPSMEX;
       id_MUMPSMEX = dmumps(id_MUMPSMEX);% destroy mumps instance
    end
elseif dkeparam.opsplit >= 1,
    if mode_MUMPSMEX,
        A_MUMPSMEX = MMXPC_P_f_t;
        B_MUMPSMEX = MMXR_t;
        %
        if job_MUMPSMEX == 1,
            id_MUMPSMEX_P = initmumps;
            id_MUMPSMEX_P = dmumps(id_MUMPSMEX_P);
            id_MUMPSMEX_P.ICNTL(1:4) = [6,0,0,1];%no display during runtime
            id_MUMPSMEX_P.JOB = job_MUMPSMEX;
            id_MUMPSMEX_P = dmumps(id_MUMPSMEX_P,A_MUMPSMEX);% Call to mumps
            if isfield(dkeparam.MUMPSparam,'thresholdpivoting'),
                if ~isempty(dkeparam.MUMPSparam.thresholdpivoting) | ~isnan(dkeparam.MUMPSparam.thresholdpivoting),
                    id_MUMPSMEX_P.CNTL(1) = dkeparam.MUMPSparam.thresholdpivoting;%Relative threshold for numerical pivoting in the MUMPS partial LU decomposition (default MUMPS = 1e-2 for non-symmetric matrices)
                end
            end
            if isfield(dkeparam.MUMPSparam,'precinv'),
                if ~isempty(dkeparam.MUMPSparam.precinv) | ~isnan(dkeparam.MUMPSparam.precinv),
                    id_MUMPSMEX_P.CNTL(2) = dkeparam.MUMPSparam.precinv;%Drop tolerance for the MUMPS partial LU decomposition
                end
            end    
        elseif job_MUMPSMEX == 2,
           id_MUMPSMEX_P.JOB = job_MUMPSMEX;
           id_MUMPSMEX_P = dmumps(id_MUMPSMEX_P,A_MUMPSMEX);% Call to mumps
           if id_MUMPSMEX_P.INFOG(1) == -13,
                error('Error in a Fortran ALLOCATE statement in MUMPS factorization. Try reducing the problem size (grid size)');
           end
        elseif job_MUMPSMEX == 3 | job_MUMPSMEX == 6,
           id_MUMPSMEX_P.JOB = job_MUMPSMEX;
           id_MUMPSMEX_P.RHS = full(B_MUMPSMEX);
           id_MUMPSMEX_P = dmumps(id_MUMPSMEX_P,A_MUMPSMEX);% Call to mumps
           if(norm(A_MUMPSMEX*id_MUMPSMEX_P.SOL - id_MUMPSMEX_P.RHS,'inf') > sqrt(eps))
              warning('Precision of the matrix inversion may not be OK (MUMPSMEX). Try to increase the dkeparam.MUMPSparam.thresholdpivoting parameters (see MUMPS documentation).');
           end
           X_MUMPSMEX = id_MUMPSMEX_P.SOL;
           flag_MUMPSMEX = 0;
        elseif job_MUMPSMEX == -2,
           id_MUMPSMEX_P.JOB = job_MUMPSMEX;
           id_MUMPSMEX_P = dmumps(id_MUMPSMEX_P);% destroy mumps instance
        end 
    else
        A_MUMPSMEX = MMXPC_R_f_t;
        B_MUMPSMEX = MMXR_t;
        %
        if job_MUMPSMEX == 1,
            id_MUMPSMEX_R = initmumps;
            id_MUMPSMEX_R = dmumps(id_MUMPSMEX_R);
            id_MUMPSMEX_R.ICNTL(1:4) = [6,0,0,1];%no display during runtime
            id_MUMPSMEX_R.JOB = job_MUMPSMEX;
            id_MUMPSMEX_R = dmumps(id_MUMPSMEX_R,A_MUMPSMEX);% Call to mumps
            if isfield(dkeparam.MUMPSparam,'thresholdpivoting'),
                if ~isempty(dkeparam.MUMPSparam.thresholdpivoting) | ~isnan(dkeparam.MUMPSparam.thresholdpivoting),
                    id_MUMPSMEX_R.CNTL(1) = dkeparam.MUMPSparam.thresholdpivoting;%Relative threshold for numerical pivoting in the MUMPS partial LU decomposition (default MUMPS = 1e-2 for non-symmetric matrices)
                end
            end
            if isfield(dkeparam.MUMPSparam,'precinv'),
                if ~isempty(dkeparam.MUMPSparam.precinv) | ~isnan(dkeparam.MUMPSparam.precinv),
                    id_MUMPSMEX_R.CNTL(2) = dkeparam.MUMPSparam.precinv;%Drop tolerance for the MUMPS partial LU decomposition
                end
            end    
        elseif job_MUMPSMEX == 2,
           id_MUMPSMEX_R.JOB = job_MUMPSMEX;
           id_MUMPSMEX_R = dmumps(id_MUMPSMEX_R,A_MUMPSMEX);% Call to mumps
           if id_MUMPSMEX_R.INFOG(1) == -13,
                error('Error in a Fortran ALLOCATE statement in MUMPS factorization. Try reducing the problem size (grid size)');
           end
        elseif job_MUMPSMEX == 3 | job_MUMPSMEX == 6,
           id_MUMPSMEX_R.JOB = job_MUMPSMEX;
           id_MUMPSMEX_R.RHS = full(B_MUMPSMEX);
           id_MUMPSMEX_R = dmumps(id_MUMPSMEX_R,A_MUMPSMEX);% Call to mumps
           if(norm(A_MUMPSMEX*id_MUMPSMEX_R.SOL - id_MUMPSMEX_R.RHS,'inf') > sqrt(eps))
              warning('Precision of the matrix inversion may not be OK (MUMPSMEX). Try to increase the dkeparam.MUMPSparam.thresholdpivoting parameters (see MUMPS documentation).');
           end
           X_MUMPSMEX = id_MUMPSMEX_R.SOL;
           flag_MUMPSMEX = 0;
        elseif job_MUMPSMEX == -2,
           id_MUMPSMEX_R.JOB = job_MUMPSMEX;
           id_MUMPSMEX_R = dmumps(id_MUMPSMEX_R);% destroy mumps instance
        end 
    end
end
  
  
  