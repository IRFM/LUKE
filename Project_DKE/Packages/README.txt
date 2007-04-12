LUKE supports several external matrix solver packages which may be used to speed-up considerably the overall simulations, 
especially for very large matrices in presence of radial transport. So far the following packages have been
tested successfuly:

1) GLNXA64  - GNU Linux on x86_64 (64 bits)
    - MUMPS.4.6.4 (parallel, sequential & mex) with pgf90 fortran compiler and pgcc C/C++ compiler
    - MUMPS.4.6.4 (sequential & mex) with g95 fortran compiler and gcc-3.2 C/C++ compiler
    - PETSc-2.3.2-p8 (parallel, with/without SUPERLU_dist_2.0) with pgf90 fortran compiler and gcc-3.2 C/C++ compiler
    - SUPERLU_3.0 (mex) with pgcc C/C++ compiler
2) MAC - Apple Mac OS X on PPC (32 bits, powerbook)
    - MUMPS.4.6.4 (sequential & mex) with g95 fortran compiler and gcc-4.0 C/C++ compiler
    - MUMPS.4.6.4 (sequential & mex) with Absoft fortran compiler and Absoft C/C++ compiler
    - SUPERLU_3.0 (mex) with gcc-4.0 C/C++ compiler
3) PCWIN - Microsoft Windows on x86 (32 bits, laptop)
    -
    -

WARNING: Since the compilation procedure is machine-dependent, these packages are NOT given with LUKE, 
and must be downloaded independently from there respective websites. However, some simple support is provided in order to
simplify the installation process. It concerns only MUMPS and SUPERLU which are the most simple packages to install.
(Note: for MUMPS, other auxiliary packages must be also compiles like BLAS, [BLACS, SCALAPACK for parallel computing only] libraries, as well as
METIS and/or SCOTCH partitionners. All of them must be compiled consistently with MUMPS)

1) Create a subdirectory named 'Packages' at the same level than 'Project-DKE'. Put ALL your external packages in this new 
directory.
2) Use the following name for the packages:
     - 'MUMPS_4.6.4_P_<compiler_name>' for the parallel calculations
     - 'MUMPS_4.6.4_S_<compiler_name>' for the sequential & mex calculations
     - 'SUPERLU_3.0_<compiler_name> for mex calculations
3) put the  following subdirectories in the global MatLab path:
	 - '~/Packages/MUMPS_4.6.4_S_<compiler_name>/MATLAB' for the mex calculations
	 - '~/Packages/SUPERLU_3.0_<compiler_name>/MATLAB' for the mex calculations
(here ~ is all the path description)
4) run_all_examples.m M-file should work immediatly

