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
 double  *pr; 
  int   m,i,p=1;
  int* n;
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
  
  m = mxGetNumberOfDimensions(prhs[1]);
  n = mxGetDimensions(prhs[1]); 

for(i=0;i<m;i++){p=(*(n+i))*p;}

  io = fopen(filename,"w");
  fwrite (&MAT_FILE_COOKIE,sizeof(int),one,io);   
/*   mexPrintf("%s=%d\n","MAT_FILE_COOKIE",MAT_FILE_COOKIE); */
  fwrite (&m,sizeof(int),one,io);
 /* mexPrintf("%s=%d\n","m",m);*/ 

  fwrite (n,sizeof(int),m,io); 
  fwrite (&p,sizeof(int),one,io);
  
/* for(i=0;i<m;i++){
   mexPrintf("%i\n",*(n+i));}   
   mexPrintf("%s=%d\n","p",p);*/
   
  fwrite(pr, sizeof(double),p,io);
 /* for(i=0;i<p;i++){mexPrintf("%g\t",*(pr+i));}*/
  
  fclose(io);

  return;
}
