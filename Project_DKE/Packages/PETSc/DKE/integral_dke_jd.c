#include <stdio.h>
#include <stdlib.h>
#include "Fokker-Planck_DKE_loop.h"
#include <math.h>


void integral_dke_jd(struct Tensor B, struct Tensor A,int d,struct Tensor *C){
int i,j=0,k;
/*A Tensor,B vector to contract with, C output*/

/*char* file="/home/sccp/gsem/FT090307/Project_DKE/fred/Csource/A";
char* file2="/home/sccp/gsem/FT090307/Project_DKE/fred/Csource/B";*/
d-=1; /*for Consistency with Matlab indices starting at 1*/

printf("start integral\n");
if(A.sizedim[d]!=B.sizedim[1]){
printf("dimension mismatch\n");
printf("sizeA=%i\n",A.sizedim[d]);
printf("sizeB=%i\n",B.sizedim[1]);
return;}
else{printf("sizeA=%i\n",A.sizedim[d]);}
/*printf("sizeB=%i\n",B.sizedim[1]);*/
int *depth=malloc((A.ndims+1)*sizeof(int));
int ndims;
int *sizedim;
for(k=0;k<=A.ndims;k++){
depth[k]=1;
   for(i=0;i<k;i++){depth[k]*=A.sizedim[i];}
}

/*printf("compd depth\n");*/

if(A.ndims !=2){
   ndims=A.ndims-1;
   sizedim=malloc(ndims*sizeof(int));
   for(i=0;i<(*C).ndims;i++){
      if(i==d){j++;}
         *(sizedim+i)=*(A.sizedim+j);
   j++;
   }
}

/*Vectors are coded as (n,1) matrices*/
else {
   ndims=2;
   sizedim=malloc(ndims*sizeof(int));
   sizedim[0]=1;
   sizedim[1]=A.sizedim[abs(d-1)];
}
Tensor_Create(ndims,sizedim,C);
/*printf("computing C\n");*/
for(i=0;i<depth[d];i++){
   for(j=0;j<depth[A.ndims]/depth[d+1];j++){
   *((*C).vals+i+j*depth[d])=0.0;
      for(k=0;k<A.sizedim[d];k++){
      *((*C).vals+i+j*depth[d])+=*(A.vals+i+j*depth[d+1]+k*depth[d])*(*(B.vals+k));
      }
   }
}

/*fprintf(stdout,"C.ndims=%i\n",(*C).ndims);
for(i=0;i<(*C).ndims;i++){fprintf(stdout,"%i\n",(*C).sizedim[i]);}*/
printf("integral done\n");
}
