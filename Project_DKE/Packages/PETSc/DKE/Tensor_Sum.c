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
#include <math.h>
#include "Fokker_Planck_DKE_loop.h"
int Tensor_Sum(struct Tensor A,struct Tensor B,DOUBLE m,struct Tensor *C)
{
/*Does A+m*B*/
/* printf("Begon Tensor-Sum");*/
int i;
if(A.ndims!=B.ndims){printf("dimension mismatch 1");return -1;}
else {
    for(i=1;i<A.ndims;i++){
    if(A.sizedim[i]!=B.sizedim[i]){printf("dimension mismatch 2");return -1;}
    }
  /*(*C).ndims=A.ndims;
  (*C).sizedim=A.sizedim;
  (*C).size=A.size;
  (*C).vals=malloc(sizeof(DOUBLE)*(A.size));*/
  Tensor_Create(A.ndims,A.sizedim,C);
  for(i=0;i<(*C).size;i++){
  (*C).vals[i]=A.vals[i]+m*B.vals[i];
  }
}
}

