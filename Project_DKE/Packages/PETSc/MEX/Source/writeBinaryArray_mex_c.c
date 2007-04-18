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
  int   m,i,j,k,p=1;
  int* n;
  FILE *io;
  size_t one = 1;
  int ARRAY_FILE_COOKIE=1;
  int CELLARRAY_FILE_COOKIE=0;
  (void) nlhs;     /* unused parameters */
  (void) plhs;
   int class,cm,*cn,index;
   mxArray* cell;
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
    
 class=mxGetClassID(prhs[1]);  
 
 if(class==mxCELL_CLASS){
 /*mexPrintf("Cell Array \n");*/
 cm=mxGetNumberOfDimensions(prhs[1]);
 /*mexPrintf("%i\t",cm);*/
 cn=mxGetDimensions(prhs[1]);
 for(j=0;j<cm;j++){p=(*(cn+j))*p;}
 /*mexPrintf("%i\t",cn[0]);
 mexPrintf("%i\n",cn[1]);*/
 int ind[2];
 ind[1]=0;
 ind[0]=0;
 io = fopen(filename,"w");
 fwrite (&CELLARRAY_FILE_COOKIE,sizeof(int),one,io);
 fwrite (&cm,sizeof(int),one,io);
 fwrite (cn,sizeof(int),cm,io); 
 fwrite (&p,sizeof(int),one,io);
 
 for(i=0;i<cn[0];i++){
    for(k=0;k<cn[1];k++){
    p=1;
    index=mxCalcSingleSubscript(prhs[1],cm,ind);
    cell=mxGetCell(prhs[1],index);
    pr=mxGetPr(cell);
    m = mxGetNumberOfDimensions(cell);
    n = mxGetDimensions(cell); 
    /*mexPrintf("%i\t",m);*/
 
    for(j=0;j<m;j++){p=(*(n+j))*p;}
    ind[1] ++;
    
    /*Writing to file*/ 
    fwrite (&m,sizeof(int),one,io);
    fwrite (n,sizeof(int),m,io); 
    fwrite (&p,sizeof(int),one,io);  
    fwrite(pr, sizeof(double),p,io); 
   }
 ind[0]++;
 }
 fclose(io);
}
 else{ 
  pr = mxGetPr(prhs[1]);
  
  m = mxGetNumberOfDimensions(prhs[1]);
  n = mxGetDimensions(prhs[1]); 
  
  
  for(i=0;i<m;i++){p=(*(n+i))*p;}

  io = fopen(filename,"w");
  fwrite (&ARRAY_FILE_COOKIE,sizeof(int),one,io);   
/*   mexPrintf("%s=%d\n","MAT_FILE_COOKIE",MAT_FILE_COOKIE); */
  fwrite (&m,sizeof(int),one,io);
  /*mexPrintf("%s=%d\n","m",m); */

  fwrite (n,sizeof(int),m,io); 
  fwrite (&p,sizeof(int),one,io);
  
 /* for(i=0;i<m;i++){
   mexPrintf("%i\n",*(n+i));}   
   mexPrintf("%s=%d\n","p",p);*/ 
   
  fwrite(pr, sizeof(double),p,io);
  /*for(i=0;i<p;i++){mexPrintf("%g\t",*(pr+i));}*/
  
  fclose(io);
}

  return;
}
