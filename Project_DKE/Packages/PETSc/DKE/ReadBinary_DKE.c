#include <stdlib.h>
#include <stdio.h>
#include "tensor.h"

void ReadBinary_DKE(char* file,struct Tensor *A)
{
FILE* TENSOR;
int i;
int cookie;
/*fprintf(stdout,"Opening\n");*/
TENSOR=fopen(file,"r");
if(!TENSOR){printf("couldn't open file\n");}

/*fprintf(stdout,"Reading cookie\n");*/
fread(&cookie,sizeof(int),1,TENSOR);

/*fprintf(stdout,"reading A ndims\n");*/
fread(&((*A).ndims),sizeof(int),1,TENSOR);


(*A).sizedim=malloc((*A).ndims*sizeof(int));
fread((*A).sizedim,sizeof(int),(*A).ndims,TENSOR);


fread(&((*A).size),sizeof(int),1,TENSOR);
/*fprintf(stdout,"YP*******,size=%d\n",(*A).size);*/

/*fprintf(stdout,"%i \n", *pp);*/

/*for(i=0;i<*pm;i++){
fprintf(stdout,"%i \n", *(*n+i));}*/



((*A).vals)=malloc((*A).size*sizeof(DOUBLE));
fread((*A).vals,sizeof(DOUBLE),(*A).size,TENSOR);

/*fprintf(stdout,"YP*******,toto=%d\n",toto);
fprintf(stdout,"YP*******,sizeofdouble=%d\n",sizeof(DOUBLE));
fprintf(stdout,"YP*******,sizeofint=%d\n",sizeof(int));*/



/*for(i=0;i<*pp;i++){
fprintf(stdout,"%g \t", *(*vals+i));}*/
fclose(TENSOR);
/* fprintf(stdout,"end read\n");*/
}
