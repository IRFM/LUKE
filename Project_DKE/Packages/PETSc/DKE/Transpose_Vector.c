#include "Fokker_Planck_DKE_loop.h"
#include <stdio.h>
void Transpose_Vector(struct Tensor *A){
/*Simple routine to make column vectors from row vectors and vice-versa*/

/*check *A is a vector*/
if((*A).sizedim[0]!=1 && (*A).sizedim[1]!=1){
int i,j,dim;
DOUBLE val;
/*printf("A is a matrix\n");*/
   for(i=0;i<(*A).sizedim[0];i++){
      for(j=0;j<(*A).sizedim[1];j++){   
      val=(*A).vals[i+j*(*A).sizedim[0]];
      (*A).vals[i+j*(*A).sizedim[0]]=(*A).vals[i*(*A).sizedim[1]+j];
      (*A).sizedim[1]=val;
      }
    }
      (*A).sizedim[0]=dim;
      (*A).sizedim[0]=(*A).sizedim[1];
      (*A).sizedim[1]=dim;
}

else{
int a=(*A).sizedim[0];
(*A).sizedim[0]=(*A).sizedim[1];
(*A).sizedim[1]=a;
}
}
