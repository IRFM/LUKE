#include <math.h>
#include "Fokker-Planck_DKE_loop.h"
#include <stdio.h>
#include <stdlib.h>

void Scalar_Tensor_product(DOUBLE s,struct Tensor A,struct Tensor* B)
{
int i;
/* fprintf(stdout,"starting S_T_P\n");*/
/*(*B).ndims=A.ndims;
fprintf(stdout,"allocating Bsizedim S_T_P\n");
(*B).sizedim=A.sizedim;
(*B).size=A.size;
fprintf(stdout,"allocating Bvals S_T_P\n");
(*B).vals=malloc(A.size*sizeof(DOUBLE));*/
Tensor_Create(A.ndims,A.sizedim,B);
for(i=0;i<(*B).size;i++){
(*B).vals[i]=A.vals[i]*s;
}
}
