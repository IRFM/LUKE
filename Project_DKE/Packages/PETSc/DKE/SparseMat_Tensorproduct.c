#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Fokker-Planck_DKE_loop.h"

void SparseMat_Tensorproduct(struct SparseMatrix A,struct Tensor B,struct Tensor *C)
{
int i,j,p;
/*Check B is indeed a vector ie a (n,1) Tensor*/
if(B.sizedim[0]!=1){fprintf(stdout,"B is not a vector");
return;}

/*Check dimensions consistency*/
if(B.sizedim[1]!=A.m){fprintf(stdout,"Dimension mismatch\n");
/*printf("m=%i n=%i\n", A.m,A.n);
printf("Bm=%iBn=%i\n",B.sizedim[0],B.sizedim[1]);*/
return;}


/*Create C*/
(*C).ndims=2;
(*C).sizedim=malloc(2*sizeof(int));
(*C).sizedim[0]=1;
(*C).sizedim[1]=A.m;
(*C).size=A.m;
(*C).vals=malloc((*C).size*sizeof(DOUBLE));
for(i=0;i<(*C).size;i++){
(*C).vals[i]=0.0;
}
/*printf("C created\n");
printf("Csize=%i\n",(*C).size);*/
for(j=0;j<(*C).size;j++){
      for(p=A.jc[j];p<A.jc[j+1];p++){
         (*C).vals[A.ir[p]]+=A.vals[p]*B.vals[j];
      }
}
/* printf("done SparseMat_Tensorproduct\n");*/
}
