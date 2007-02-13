#include "tensor.h"

void integral_dke_jd(struct Tensor A, struct Tensor B,int d,struct Tensor *C);
/*Performs contraction of Tensor A with Tensor (vector B) along dimension d
(dimensions start at 1) and returns C*/

void Tensor_Create(int ndims,int* sizedim,struct Tensor *A);
/*Initializes and allocates memory for Tensor with data specified by ndims,
sizedim*/

void Scalar_Tensor_product(DOUBLE s,struct Tensor A,struct Tensor* B);
/*Performs *B=s*A*/

int Tensor_Sum(struct Tensor A,struct Tensor B,DOUBLE m, struct Tensor *C);
/*Performs *C=A+m*B*/

void Tensor_Transpose(struct Tensor *A);
/*Transposes *A if it's a vector or a matrix*/

void SparseMat_Tensorproduct(struct SparseMatrix A,struct Tensor B,struct Tensor
*C);
/*Performs *C=A*B with A a sparsematrix as written by
writeBinarySparseMat_mex_c.mex and B,*C Tensors (vectors)*/

void Tensor_Fill(struct Tensor *T, DOUBLE a);
/*Fills Tensor with DOUBLE value a*/

void IntTensor_Fill(struct IntTensor *T, int a);
/*Fills IntTensor with int value a)*/

void ReadBinary_DKE(char* file, struct Tensor *A);
/*READS Binary file containing Tensor as written by
writeBinaryTensor_mex_c.mex*/

void ReadBinaryArray_DKE(char* file,struct Tensor ** Array);
/*READS Binary file containing Cell Array*/

void ReadBinaryIntArray_DKE(char* file,struct IntTensor **Array);

void ReadBinarySparseMatrix_DKE(char* file,struct SparseMatrix *A);
/*READS SparseMatrix as written by writeBinarySparseMat_mex_c.mex*/

void Tensor_Save(char * file, struct Tensor A);
/*Writes Tensor A to file*/

void IntTensor_Save(char * file, struct IntTensor A);
/*Writes IntTensor A to file*/

int firstordercollop_dke_ft_c2(struct Tensor f1,
struct Tensor betath_ref,
struct Tensor masku,struct Tensor maskl, 
struct Tensor dpn, 
struct Tensor xpn, struct Tensor xpn2, struct Tensor xpn3, struct Tensor xsigma, struct Tensor xgamma,
struct Tensor xz, struct Tensor xz2,
struct Tensor pn, struct Tensor pn2, struct Tensor pn3,  
struct Tensor sigma, struct Tensor gamma,
struct Tensor z, struct Tensor z2, 
struct Tensor xJ1, struct Tensor xJ2, struct Tensor xJ3, struct Tensor xJ4,
struct Tensor J1, struct Tensor J2, struct Tensor J3, struct Tensor J4,struct
Tensor xTe_norm,struct Tensor *I1,struct Tensor *I2);
/*C transalation of function firstordercollop_dke*/

DOUBLE absolute(DOUBLE a);
/*Returns absolute value of a*/

int product(struct Tensor A,struct Tensor B,struct Tensor* C);
int division(struct Tensor A,struct Tensor B,struct Tensor* C);
