/*Reads Binary Sparse Matrices as written by writeBinarySparseMat_mex_c*/

#include <stdlib.h>
#include <stdio.h>
#include "Fokker-Planck_DKE_loop.h"

void ReadBinarySparseMatrix_DKE(char* file,struct SparseMatrix *A)
{
FILE* TENSOR;
int i;
int cookie;
fprintf(stdout,"Opening\n");
TENSOR=fopen(file,"r");

/*fprintf(stdout,"Reading cookie\n");*/
fread(&cookie,sizeof(int),1,TENSOR);

/*fprintf(stdout,"reading A m\n");*/
fread(&((*A).m),sizeof(int),1,TENSOR);

/*fprintf(stdout,"reading A n\n");*/
fread(&((*A).n),sizeof(int),1,TENSOR);

/*fprintf(stdout,"reading A nnz\n");*/
fread((&(*A).nnz),sizeof(int),1,TENSOR);

(*A).jc=malloc((*A).m*sizeof(int));
fread((*A).jc,sizeof(int),((*A).n+1),TENSOR);

(*A).ir=malloc((*A).nnz*sizeof(int));
fread(((*A).ir),sizeof(int),(*A).nnz,TENSOR);

(*A).vals=malloc((*A).nnz*sizeof(DOUBLE));
fread(((*A).vals),sizeof(DOUBLE),(*A).nnz,TENSOR);

/*fprintf(stdout,"%i \t", ((*A).m));
fprintf(stdout,"%i \t", ((*A).n));
fprintf(stdout,"%i \t", ((*A).nnz));*/

fclose(TENSOR);
fprintf(stdout,"end read\n");
}
