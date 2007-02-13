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
void
mexFunction( int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[] )
{
 double  *pr, *pi;
  int  *ir, *jc;
  int   m,n,nnz;
  int i,j,*nnzr;
  FILE *io;
  size_t one = 1;
  int MAT_FILE_COOKIE=1211216;

  (void) nlhs;     /* unused parameters */
  (void) plhs;

  char *filename;
  int   buflen,status;
    
  /* Check for proper number of arguments. */
  if (nrhs != 2) 
    mexErrMsgTxt("Two inputs required.");

  /* First argument must be a string. */
  if (mxIsChar(prhs[0]) != 1)
    mexErrMsgTxt("First argument must be a string.");

  /* Second argument must be a sparse matrix. */
  if (mxIsSparse(prhs[1]) != 1)
    mexErrMsgTxt("Second argument must be a sparse matrix.");

  /* Get the length of the input string. */
  buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;

  /* Allocate memory for input and output strings. */
  filename = mxCalloc(buflen, sizeof(char));

  /* Copy the string data from prhs[0] into a C string 
   * filename. */
  status = mxGetString(prhs[0], filename, buflen);
  if (status != 0) 
    mexWarnMsgTxt("Not enough space. String is truncated.");

  /* Get the starting positions of all four data arrays. */ 
  pr = mxGetPr(prhs[1]);
  pi = mxGetPi(prhs[1]);
  ir = mxGetIr(prhs[1]);
  jc = mxGetJc(prhs[1]);
  
  m = mxGetM(prhs[1]); /* number of rows of A' (columns of A) */
  n = mxGetN(prhs[1]); /* number of columns of A' (rows of A) */
/*   nnz = mxGetNzmax(prhs[1]); */ /* this is only an upper bound! */

/* Figure out number of nonzero elements */
  nnz=0;
  /*for (j=0;j<n;j++) {
    nnzr=jc[j+1]-jc[j]; /* number of nonzero elements in column j+1 of A' (row j+1 of A) */
    /*nnz=nnz+nnzr;
  }*/
  
nnz=jc[n]-jc[0];

  io = fopen(filename,"w");
  fwrite (&MAT_FILE_COOKIE,sizeof(int),one,io);   
/*   mexPrintf("%s=%d\n","MAT_FILE_COOKIE",MAT_FILE_COOKIE); */
  fwrite (&n,sizeof(int),one,io); 
/*   mexPrintf("%s=%d\n","n",n); */
  fwrite (&m,sizeof(int),one,io); 
/*   mexPrintf("%s=%d\n","m",m);   */
  fwrite (&nnz,sizeof(int),one,io); 
/*   mexPrintf("%s=%d\n","nnz",nnz);   */
nnzr=mxCalloc(n,sizeof(int));
  for (j=0;j<n;j++) {
    nnzr[j]=jc[j+1]-jc[j];
/*     mexPrintf("%s=%d\n","nnzr",nnzr); */
  }
  fwrite (jc,sizeof(int),n+1,io); 
  fwrite (ir,sizeof(int),(size_t) nnz,io); /* row indices of of nonzero elements of A' (column indices of A) */
  /*fwrite (pr,sizeof(double),(size_t) nnz,io);*/ /* actual data */
  fwrite (pr,sizeof(double),(size_t) nnz,io);
  fclose(io);

  return;
}
