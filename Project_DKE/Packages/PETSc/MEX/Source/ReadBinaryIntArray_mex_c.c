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

#define MAT_OUT   plhs[0]
 
/* mexFunction is the gateway routine for the MEX-file. */ 
void mexFunction(int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[] )
	     {
 char *file;
 int length,status;
 int *cookie,*ndims,*dim,*size,*vals;
 int ii,result;
 int *matout;
 
 if (mxIsChar(prhs[0]) != 1)
    {mexErrMsgTxt("Input must be a string.");}
 else{
    length=(mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
    file=mxCalloc(length,sizeof(char));
    status = mxGetString(prhs[0], file, length);
    if (status != 0) 
       {mexWarnMsgTxt("Not enough space. String is truncated.");}
 }
 
 FILE *TENSOR = fopen(file,"r");/* Open file */
 
 cookie = mxCalloc(1,sizeof(int));
 if (cookie == NULL) {mexErrMsgTxt("Memory allocation error in ReadBinaryIntArray_mex !");}
 result = fread(cookie,sizeof(int),1,TENSOR);/* copy the file into the buffer:*/
 if (result != 1) {mexErrMsgTxt("Reading file problem in ReadBinaryIntArray_mex !");}
 /*mexPrintf("Cookie=%i\n",cookie[0]);*//* Display COOKIE */
 
 ndims = mxCalloc(1,sizeof(int));
 if (ndims == NULL) {mexErrMsgTxt("Memory allocation error in ReadBinaryIntArray_mex !");}
 result = fread(ndims,sizeof(int),1,TENSOR);/*copy the file into the buffer:*/
 if (result != 1) {mexErrMsgTxt("Reading file problem in ReadBinaryIntArray_mex !");}
 /*mexPrintf("Ndims=%i\n",ndims[0]);*//* Display Ndims */

 dim = mxCalloc(ndims[0],sizeof(int));
 if (dim == NULL) {mexErrMsgTxt("Memory allocation error in ReadBinaryIntArray_mex !");}
 result = fread(dim,sizeof(int),ndims[0],TENSOR);/* copy the file into the buffer:*/
 if (result != ndims[0]) {mexErrMsgTxt("Reading file problem in ReadBinaryIntArray_mex !");}
 /*for (ii = 0;ii < ndims[0];ii++) {
     mexPrintf("dim[%i]=%i\n",ii,dim[ii]);
 }*/

 size = mxCalloc(1,sizeof(int));
 if (size == NULL) {mexErrMsgTxt("Memory allocation error in ReadBinaryIntArray_mex !");}
 result = fread(size,sizeof(int),1,TENSOR);/* copy the file into the buffer:*/
 if (result != 1) {mexErrMsgTxt("Reading file problem in ReadBinaryIntArray_mex !");}
 /*mexPrintf("Size=%i\n",size[0]);*//* Display Size */
 
 vals = mxCalloc(size[0],sizeof(int));
 if (vals == NULL) {mexErrMsgTxt("Memory allocation error in ReadBinaryIntArray_mex !");}
 result = fread(vals,sizeof(int),size[0],TENSOR);/* copy the file into the buffer:*/
 if (result != size[0]) {mexErrMsgTxt("Reading file problem in ReadBinaryIntArray_mex !");}
 /* for (ii = 0;ii < size[0];ii++) {
     mexPrintf("vals[%i]=%i\n",ii,vals[ii]);
 }*/
 
 fclose(TENSOR);
 

 MAT_OUT = mxCreateNumericArray(ndims[0],dim,mxINT32_CLASS,mxREAL);
 matout = mxGetData(MAT_OUT);
 for (ii = 0;ii < size[0];ii++) {
     matout[ii] = vals[ii];/*Write output*/
 }

 
 /* Clear allocated memory */
 mxFree (cookie);
 mxFree (dim);
 mxFree (ndims);
 mxFree (size);
 mxFree (vals);
 
 return;
}
