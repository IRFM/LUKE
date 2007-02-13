
CFLAGS	         = -I${PETSC_DIR}/src/dm/mesh/sieve ${BOOST_INCLUDE} ${TRIANGLE_INCLUDE} ${TETGEN_INCLUDE} 
FFLAGS	         = 
CPPFLAGS         = 
FPPFLAGS         =
LOCDIR           = DKE

MANSEC           = KSP
CLEANFILES       = rhs.vtk solution.vtk
NP               = 1
DISPLAY          = :0.0

include ${PETSC_DIR}/bmake/common/base

PETSc_DKE_ft : 	PETSc_DKE_ft.o  chkopts
	-${CLINKER}  -o PETSc_DKE_ft PETSc_DKE_ft.o ${PETSC_KSP_LIB} 
	${RM} PETSc_DKE_ft.o
	
SolverLoop_DKE_c : SolverLoop_DKE_c.o  chkopts
	-${CLINKER}  -o SolverLoop_DKE_c SolverLoop_DKE_c.o division.o\
firstordercollop_dke_ft_c.o integral_dke_jd.o product.o ReadBinaryArray_DKE.o\
ReadBinary_DKE.o ReadBinarySparseMatrix_DKE.o Scalar_Tensor_product.o\
Tensor_Sum.o ReadBinaryIntArray_DKE.o Tensor_Create.o SparseMat_Tensorproduct.o\
Tensor_Transpose.o absolute.o Tensor_Save.o IntTensor_Save.o Tensor_Fill.o ${PETSC_KSP_LIB} 
	${RM} SolverLoop_DKE_c.o

	
	

include ${PETSC_DIR}/bmake/common/test
