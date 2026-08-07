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
/*COMPARES TXO BINARY FILES GIVEN AS COMMAND LINE ARGUMENTS args[1] and args[2].
TWO OPTIONS AVAILABLE: a=0 DISPLAYS THE RELATIVE ERROR AND a=1 DISPLAYS INDICES
OF ELEMENTS WITH ERRORS ARE > 1e6
pgcc -c Compare.c
pgcc -o Compare Compare.o ReadBinary_DKE.o absolute.o 
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "tensor.h"

void ReadBinary_DKE(char* file, struct Tensor *A);
DOUBLE absolute(DOUBLE a);

void main(int argc, char **args){
int i;
struct Tensor A,B;
char *file= args[1];
char *file2= args[2];
int a=0;
printf("%c\n",file);
ReadBinary_DKE(file,&A);
ReadBinary_DKE(file2,&B);
if(a==0){
   for(i=0;i<A.size;i++){
      printf("(A-B)/B[%i]=%g\n",i,(A.vals[i]-B.vals[i])/(B.vals[i]));
   }
}
if(a==1){
if(A.size!=B.size){printf("dimensiosn inconsitency\n");}
else {
for(i=0;i<A.size;i++){
if(absolute((A.vals[i]-B.vals[i])/B.vals[i])>0.001){printf("i=%i",i);}
}
}
}
}
