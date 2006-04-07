/*=================================================================
 *
 * trapz_dke_yp.C  .MEX file corresponding to trapz_dke_yp.M
 *
 * Numerical integration by the trapeze's method of a function y = f(x).
 *Steps may be irregular. (see the .m equivalent trapz_dke_yp.m)
 *
 *	Input:
 *
 *		- f: [x,f1,f2,...,fm], x is the abciss vector, fi are m functions [n,m+1]
 *
 *	Output:
 *
 *		- sf: [sf1,sf2,...,sfm], sum of fi's [n,m] 
 *
 *
 *by Y.PEYSSON CEA-DRFC (yves.peysson@cea.fr) and Joan Decker CEA-DRFC (joan.decker@cea.fr)
 *
 * This is a MEX-file for DKE.  
 *
 *=================================================================
 */
#include <math.h>
#include <stdlib.h>
#include "mex.h"

/* Input Arguments */

#define	F_IN	prhs[0]

/* Output Arguments */

#define	SF_OUT	plhs[0]

#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif

void trapz(sf,f,m,n)
double	sf[];
double	f[];
unsigned int m;
unsigned int n;		
{
unsigned int i;
unsigned int j;
unsigned int k;
double	*delta;
double	dd;

    delta = mxMalloc(m*sizeof(double)+1);

    if (m > 2) {
          for (i=0;i<m-1;i++) {
	         delta[i] = f[i+1] - f[i];
		  }		  
	     for (j=1;j<n;j++) {
            for (i=0;i<m-1;i++) {
			   k = i+m*j;
	           sf[j-1] = sf[j-1] + delta[i]*(f[k+1] + f[k])/2.0;
	        }
	     }
    } else if (m == 2) {
       for (j=1;j<n;j++) {
	      sf[j-1] = (f[m*j] + f[1+m*j])/2.;
	   }
	} else if (m == 1) {
       for (j=1;j<n;j++) {
	      sf[j-1] = f[j];
	   } 
	}



   mxFree(delta);


}

void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
     
{ 
    double *sf; 
    double *f; 
    unsigned int m,n; 
    
    /* Check for proper number of arguments */
    
    if (nrhs != 1) { 
	mexErrMsgTxt("One input argument required."); 
    } else if (nlhs > 1) {
	mexErrMsgTxt("Too many output arguments."); 
    } 
    
    /* Check the dimensions of F */
    
    m = mxGetM(F_IN);/*number of rows*/ 
    n = mxGetN(F_IN);/*number of columns*/
    if (!mxIsDouble(F_IN)) {
	mexErrMsgTxt("trapz_dke_yp requires double type input data"); 
    } 
	
    if (n==0 || m==0) {
	mexErrMsgTxt("Empty matrix in trapz_dke_yp"); 
    } 
    
    /* Create a matrix for the return argument */ 
	SF_OUT = mxCreateDoubleMatrix(1, n-1, mxREAL); 
    
    /* Assign pointers to the various parameters */ 
    sf = mxGetPr(SF_OUT);
    f = mxGetPr(F_IN); 
           
    /* Do the actual computations in a subroutine */
	
    trapz(sf,f,m,n); 
    return;
    
}


