#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Fokker-Planck_DKE_loop.h"

int division(struct Tensor A,struct Tensor B,struct Tensor* C)
{
int i;

/* fprintf(stdout,"Checking B");*/
 for(i=0;i<B.size;i++){
     if(B.vals[i]==0.0){return -1;}
 }
     
 if (B.ndims ==2 && B.sizedim[0]==1 && B.sizedim[1]==1)/*B is a scalar*/ {
   /*fprintf(stdout,"divCase1\n");*/
   Tensor_Create(A.ndims,A.sizedim,C);  
/*(*C).ndims=A.ndims;
(*C).sizedim=A.sizedim;
(*C).size=A.size;
(*C).vals=malloc(A.size*sizeof(DOUBLE));*/
   for(i=0;i<A.size;i++){
     (*C).vals[i]=A.vals[i]/B.vals[0];
     }
return 0;
 } 
 
/*Other cases:Checking dimensions consistency*/   

else if(A.ndims !=B.ndims){return -1;}   
else {/*fprintf(stdout,"divCase2\n");*/
    for(i=0;i<A.ndims;i++){
       if(A.sizedim[i] != B.sizedim[i]){return -1;}
     }
   /*fprintf(stdout,"divcomputeC\n");*/
 
/*(*C).ndims=A.ndims;
(*C).sizedim=A.sizedim;
(*C).size=A.size;
(*C).vals=malloc(A.size*sizeof(DOUBLE)); */
   Tensor_Create(A.ndims,A.sizedim,C);  
   /*fprintf(stdout,"computing C.vals\n");*/    
   for(i=0;i<A.size;i++){
      (*C).vals[i]=A.vals[i]/B.vals[i];
    }
}

/* fprintf(stdout,"end\n");*/
return 0;
}
