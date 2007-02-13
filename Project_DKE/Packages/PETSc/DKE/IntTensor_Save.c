#include <stdio.h>
#include <stdlib.h>
#include "tensor.h"
void IntTensor_Save(char * file, struct IntTensor A){
FILE * TENSOR;
TENSOR=fopen(file,"w");
int cookie=1;
fwrite(&(cookie),sizeof(int),1,TENSOR);
fwrite(&(A.ndims),sizeof(int),1,TENSOR);
fwrite(A.sizedim,sizeof(int),A.ndims,TENSOR);
fwrite(&(A.size),sizeof(int),1,TENSOR);
fwrite(A.vals,sizeof(int),A.size,TENSOR);
fclose(TENSOR);
}
