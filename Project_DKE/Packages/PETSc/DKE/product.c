#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Fokker-Planck_DKE_loop.h"

int product(struct Tensor A,struct Tensor B,struct Tensor* C){
int i;

if (A.ndims ==2 && A.sizedim[0]==1 && A.sizedim[1]==1)/*A is a scalar*/
{/*fprintf(stdout,"Case 2\n");*/
Tensor_Create(B.ndims,B.sizedim,C);
   for(i=0;i<B.size;i++){
      (*C).vals[i]=A.vals[0]*B.vals[i];
   }
return 0;}
else if (B.ndims ==2 && B.sizedim[0]==1 && B.sizedim[1]==1)/*B is a scalar*/{
   /*fprintf(stdout,"Case3\n");*/
   Tensor_Create(A.ndims,A.sizedim,C);
   for(i=0;i<A.size;i++){
      (*C).vals[i]=B.vals[0]*A.vals[i];
   }
   return 0;
}
/*Other cases:Checking dimensions consistency*/
else if(A.ndims !=B.ndims){return -1;fprintf(stdout,"Case1\n");}
else {/*fprintf(stdout,"Case4\n");*/
    for(i=0;i<A.ndims;i++){
       if(A.sizedim[i] != B.sizedim[i] && ((A.ndims !=2 && A.sizedim[0]!=1 && A.sizedim[1]!=1) ||
(B.ndims !=2 && B.sizedim[0]!=1 &&
B.sizedim[1]!=1))){/*printf("product:dimension mismatch\n");*/
return -1;}
       }
     Tensor_Create(A.ndims,A.sizedim,C); 
    /* fprintf(stdout,"computing C.vals\n");*/
    for(i=0;i<A.size;i++){
       (*C).vals[i]=A.vals[i]*B.vals[i];
    }
}
fprintf(stdout,"endprod\n");
return 0;}
