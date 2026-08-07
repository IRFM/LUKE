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
#include <math.h>
#include "Fokker_Planck_DKE_loop.h"
#include <stdio.h>
#include <stdlib.h>

void Scalar_Tensor_product(DOUBLE s,struct Tensor A,struct Tensor* B)
{
int i;
/* fprintf(stdout,"starting S_T_P\n");*/
/*(*B).ndims=A.ndims;
fprintf(stdout,"allocating Bsizedim S_T_P\n");
(*B).sizedim=A.sizedim;
(*B).size=A.size;
fprintf(stdout,"allocating Bvals S_T_P\n");
(*B).vals=malloc(A.size*sizeof(DOUBLE));*/
Tensor_Create(A.ndims,A.sizedim,B);
for(i=0;i<(*B).size;i++){
(*B).vals[i]=A.vals[i]*s;
}
}
