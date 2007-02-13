#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Fokker-Planck_DKE_loop.h"
int Tensor_Sum(struct Tensor A,struct Tensor B,DOUBLE m,struct Tensor *C)
{
/*Does A+m*B*/
printf("Begon Tensor-Sum");
int i;
if(A.ndims!=B.ndims){printf("dimension mismatch 1");return -1;}
else {
    for(i=1;i<A.ndims;i++){
    if(A.sizedim[i]!=B.sizedim[i]){printf("dimension mismatch 2");return -1;}
    }
  /*(*C).ndims=A.ndims;
  (*C).sizedim=A.sizedim;
  (*C).size=A.size;
  (*C).vals=malloc(sizeof(DOUBLE)*(A.size));*/
  Tensor_Create(A.ndims,A.sizedim,C);
  for(i=0;i<(*C).size;i++){
  (*C).vals[i]=A.vals[i]+m*B.vals[i];
  }
}
}

