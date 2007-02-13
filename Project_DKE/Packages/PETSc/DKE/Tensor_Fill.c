#include "tensor.h"
void Tensor_Fill(struct Tensor *T, DOUBLE a)
{
int i;
for(i=0;i<(*T).size;i++){
   (*T).vals[i]=a;
}
}
