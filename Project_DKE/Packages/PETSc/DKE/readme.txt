For compiling SolverLoop_DKE_c.c, type in the current directory


1) compile all following routines (pgcc compiler may be changed by another 
one if necessary)

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



2) type "make SolverLoop_DKE_c"

3) check that dkepath.PETSC = '~/Packages/petsc-2.3.2-p8' is well recognized 
in the path files. (see Project_DKE/Database/PATH_files)

