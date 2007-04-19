For compiling SolverLoop_DKE_c.c, type in the current directory

WARNING: if you install the PETSc package with a given name, like PETSc_dir, and want to work with LUKE, you must rename it 
PETSc_dir_S_<compiler_name> (single processor computations) or PETSc_dir_P_<compiler_name> (multi-processor computations) AFTER ALL compilations. If it is necessary to re-compile some applications in DKE, change back to the initial name of the directory for the compilation phase, and rename the PETS_dir
as it was before. Do separate directories for single or multiprocessor calculations.
1) create a environment variable PETSC_DIR (setenv PETSC_DIR = <pathPETSc>)

2) copy $HOME/LUKE/Project_DKE/Packages/PETSc/DKE directory into PETSC_DIR

3) check in the file "tensor.h" that the definition of DOUBLE is correct for your computer (long double is not always supported on all computers. In that case, replace long double by double)

4) compile first all following routines 

(use pgcc instead of gcc for Portland C/C++ compiler on GLNXA64)

pgcc -c division.c
pgcc -c firstordercollop_dke_ft_c.c
pgcc -c integral_dke_jd.c 
pgcc -c product.c 
pgcc -c ReadBinaryArray_DKE.c
pgcc -c ReadBinary_DKE.c
pgcc -c ReadBinarySparseMatrix_DKE.c
pgcc -c Scalar_Tensor_product.c
pgcc -c Tensor_Sum.c
pgcc -c ReadBinaryIntArray_DKE.c
pgcc -c Tensor_Create.c
pgcc -c SparseMat_Tensorproduct.c
pgcc -c Tensor_Transpose.c
pgcc -c absolute.c
pgcc -c Tensor_Save.c
pgcc -c IntTensor_Save.c
pgcc -c Tensor_Fill.c


or 


gcc -c division.c
gcc -c firstordercollop_dke_ft_c.c
gcc -c integral_dke_jd.c 
gcc -c product.c 
gcc -c ReadBinaryArray_DKE.c
gcc -c ReadBinary_DKE.c
gcc -c ReadBinarySparseMatrix_DKE.c
gcc -c Scalar_Tensor_product.c
gcc -c Tensor_Sum.c
gcc -c ReadBinaryIntArray_DKE.c
gcc -c Tensor_Create.c
gcc -c SparseMat_Tensorproduct.c
gcc -c Tensor_Transpose.c
gcc -c absolute.c
gcc -c Tensor_Save.c
gcc -c IntTensor_Save.c
gcc -c Tensor_Fill.c

5) type "make PETSc_DKE_ft"

6) type "make SolverLoop_DKE_c"

7) set in the path file (see in $HOME/LUKE/Project_DKE/Database/PATH_files/)

dkepath.PETSC = <petscdir>;%Where PETSC matrix solver (independent program) is stored
dkepath.PETSc_DIR = <petscdir>;
dkepath.variables.input = [<petscdir>/DKE/DKESolver_variables'];%directory where all inout variables are written
dkepath.variables.output = [<petscdir>/DKE/DKESolver_output'];%location directory where the distribution function is written by C program before going back to matlab


