#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Fokker-Planck_DKE_loop.h"

void Tensor_Create(int ndims,int* sizedim,struct Tensor *A)
{int i;

(*A).ndims=ndims;

(*A).sizedim=malloc(ndims*sizeof(int));
for(i=0;i<ndims;i++){
(*A).sizedim[i]=sizedim[i];
}
(*A).size=1;
for(i=0;i<ndims;i++){
(*A).size*=(*A).sizedim[i];

/*printf("sizedim=%d,%d\n",i,(*A).sizedim[i]);
printf("size=%i\n",(*A).size);*/
}
(*A).vals=malloc((*A).size*sizeof(DOUBLE));
/*printf("Done creating tensor\n");
printf("Csize=%i\n",(*A).size);
fprintf(stdout,"YP5******************\n");*/
}
