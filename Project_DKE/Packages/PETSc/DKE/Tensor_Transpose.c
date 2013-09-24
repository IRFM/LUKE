#include "Fokker_Planck_DKE_loop.h"
#include <stdio.h>

void Tensor_Transpose(struct Tensor *A){
/*Simple routine to transpose vectors and tensors*/

/*check *A is a vector*/
if((*A).sizedim[0]!=1 && (*A).sizedim[1]!=1){
int i,j,dim;
int s[2];

DOUBLE val;
/*printf("A is a matrix\n");*/
/* for(i=0;i<(*A).sizedim[0];i++){
    for(j=0;j<i;j++){
       val=(*A).vals[i+j*(*A).sizedim[0]];
      (*A).vals[i+j*(*A).sizedim[0]]=(*A).vals[j+i*(*A).sizedim[1]];
      (*A).vals[j+i*(*A).sizedim[1]]=val;
    }
 }
 
  dim=(*A).sizedim[0];
 (*A).sizedim[0]=(*A).sizedim[1];
 (*A).sizedim[1]=dim;*/

struct Tensor B;
/*printf("Asize=%i,%i\n",(*A).sizedim[0],(*A).sizedim[1]);*/
s[0]=(*A).sizedim[1];
s[1]=(*A).sizedim[0];
/* printf("s=%i,%i\n",s[0],s[1]);*/
Tensor_Create(2,s,&B);
/*printf("s=%i,%i\n",B.sizedim[0],B.sizedim[1]);*/

/*printf("Create B\n");*/
for(i=0;i<B.sizedim[0];i++){
   for(j=0;j<B.sizedim[1];j++){
      B.vals[i+j*B.sizedim[0]]=(*A).vals[j+i*(*A).sizedim[0]];
   }
}
(*A).sizedim[0]=B.sizedim[0];
(*A).sizedim[1]=B.sizedim[1];
/*printf("Copy B\n");*/
for(i=0;i<(*A).size;i++){
   (*A).vals[i]=B.vals[i];
} 
free(B.vals);free(B.sizedim);
}
   
else{
int a=(*A).sizedim[0];
(*A).sizedim[0]=(*A).sizedim[1];
(*A).sizedim[1]=a;
}
/*printf("done transposing\n");*/
}
