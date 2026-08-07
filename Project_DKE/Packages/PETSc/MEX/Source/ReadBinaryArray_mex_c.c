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
/*=================================================================
 * Mex function to write sparse matrix in PETSc binary format. 
 * USAGE: writePetscBinaryMat(filename,A'), where
 *          filename: string containing name of file to write to
 *          A: sparse matrix to write out.
 * IMPORTANT: To write out matrix A you MUST pass A' (A transpose)
 *            as the 2d argument. This is because matlab stores 
 *            sparse matrices internally in column major format. 
 *            This is exactly the opposite of what is needed for 
 *            writing out a PETSc binary file.
 *=================================================================*/

#include <stdio.h>
#include <string.h>
#include "mex.h"

 
/* mexFunction is the gateway routine for the MEX-file. */ 
void mexFunction(int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[] )
	     {
 char *file;
 int length,status;
 int ndims,*dim,size,*cookie;
 double *vals;
 
 if (mxIsChar(prhs[0]) != 1)
    {mexErrMsgTxt("Input must be a string.");}
 else{
    length=(mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
    file=mxCalloc(length,sizeof(char));
    status = mxGetString(prhs[0], file, length);
    if (status != 0) 
       {mexWarnMsgTxt("Not enough space. String is truncated.");}
 }
 
 FILE *TENSOR=fopen(file,"r");
 fread(&cookie,sizeof(int),1,TENSOR);
 fread(&ndims,sizeof(int),1,TENSOR);
 dim=mxCalloc(ndims,sizeof(int));
 fread(dim,sizeof(int),ndims,TENSOR);
 fread(&size,sizeof(int),1,TENSOR);
 vals=mxCalloc(size,sizeof(double));
 fread(vals,sizeof(double),size,TENSOR);  
 fclose(TENSOR);
 mxArray * pA;
 plhs[0]=mxCreateNumericArray(ndims,dim,mxDOUBLE_CLASS,mxREAL);
 mxSetPr(plhs[0],vals);
  return;
}
