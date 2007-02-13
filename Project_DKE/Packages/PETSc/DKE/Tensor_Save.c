#include <stdio.h>
#include <stdlib.h>
#include "tensor.h"
void Tensor_Save(char * file, struct Tensor A){
FILE * TENSOR;
TENSOR=fopen(file,"w");
int cookie=1;
fwrite(&(cookie),sizeof(int),1,TENSOR);
fwrite(&(A.ndims),sizeof(int),1,TENSOR);
fwrite(A.sizedim,sizeof(int),A.ndims,TENSOR);
fwrite(&(A.size),sizeof(int),1,TENSOR);
fwrite(A.vals,sizeof(DOUBLE),A.size,TENSOR);
fclose(TENSOR);
}
