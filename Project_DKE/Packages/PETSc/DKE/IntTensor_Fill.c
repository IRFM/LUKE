#include "tensor.h"
void IntTensor_Fill(struct IntTensor *T, int a)
{
int i;
for(i=0;i<(*T).size;i++){
   (*T).vals[i]=a;
}
}
