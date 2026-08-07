// /////////////////////////////////////////
//
// Software name : LUKE
//
// Authors : Yves Savoye-Peysson and Joan Decker
//
// Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
//
// CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
//
// The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
//
// /////////////////////////////////////////
//
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
