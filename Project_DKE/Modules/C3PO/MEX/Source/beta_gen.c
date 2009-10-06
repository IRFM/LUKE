/*
 
	mcaziyp.C	MEX file for a test program describing the random azimuthal angle (beta) around the magnetic field direction
					
	[s0] = beta_gen(xn,xreset0)

	INPUT:
		- xn: number of trials [1,1]
		- xreset0: initialization number for the random generator [1,1]  

	OUTPUT:
	
		- beta : random azimuthal angle (0:2*pi) [xn,1]



by Y.PEYSSON CEA-DRFC <yves.peysson@cea.fr>
*/

#include <math.h>
#include "mex.h"

/*input arguments*/

#define	xn_IN		prhs[0]
#define	xreset0_IN	prhs[1]           

/* Output Arguments */

#define	s0_OUT		plhs[0]
	
#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif




/*
      Uniform random variate between 0 and 1
      Long period (> 2e18) random number generator 
      (see Numerical Recipes, 2nd Edition, p282)
      
*/

static double ran2(idum)
long int *idum;
{

	long int j;
	long int k;
 	static long int idum2 = 123456789;
 	static long int iy = 0;
 	static long int iv[32];
 	double temp;
 
 	double eps = 1.2e-7,rnmx,am,ndiv;
 	long int im1 = 2147483563,im2 = 2147483399,imm1,ia1 = 40014,ia2 = 40692,iq1 = 53668,iq2 = 52774;
 	long int ir1 = 12211,ir2 = 3791,ntab = 32;
 
 	imm1 = im1 - 1L;
 	am = (double)1.0/(double)im1;
 	ndiv = (double)1.0+(double)imm1/(double)ntab;
 	rnmx = (double)1.0 - eps;
 
 	if (*idum <=0L) {
 		if(-(*idum) < 1L) *idum = 1L;
 		else *idum = -(*idum);
 		idum2 = (*idum);
 		for (j = ntab+7L;j>=0L;j--) {
 			k = (long int)(*idum)/iq1;
 			*idum = ia1*(*idum-k*iq1)-k*ir1;
 			if(*idum<0L) *idum += im1;
 			if (j < ntab) iv[j] = *idum;
 		}
 		iy = iv[0];
 	}
 	
 	k = (long int)(*idum)/iq1;
 	*idum = ia1*(*idum-k*iq1)-k*ir1;
 	if (*idum < 0L) *idum += im1;
 	k = (long int)(idum2/iq2);
 	idum2 = ia2*(idum2-k*iq2)-k*ir2;
 	if (idum2 < 0L) idum2 += im2;
 	j = (long)(iy/(long int)ndiv);
 	iy = iv[j]-idum2;
 	iv[j] = *idum;
 	if(iy < 1) iy += imm1;
 	if ((temp = am*(double)iy) > rnmx) return(rnmx);
 	else return(temp);
}



tirazi(reset,res)
long int *reset;
double *res;
{
    double pi = 3.141592653526;
	res[0] = (double)2.0*pi*ran2(reset);   
}




static azimuth(s0out,xn,xreset0)
double s0out[];
double *xn,*xreset0;
{
	double azi;
	long int i,n,reset,reset0;
/*
	Initialisation generateur v.a. uniform
*/
	reset0 = (long int)xreset0[0];
	reset = -reset0;

	n = (long int)xn[0];
	
	for (i=0L; i < n; i++) {
		tirazi(&reset,&azi);
		s0out[i] = azi;
	}
}



void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) { 

	double *s0out;
	double	*xn,*xreset0;

	/* Check for proper number of arguments */

	if (nrhs < 2) mexErrMsgTxt("mcaziyp requires at least 2 input arguments.");
	if (nlhs > 1) mexErrMsgTxt("mcaziyp requires up to one output argument.");
	
	xn = mxGetPr(xn_IN);
	xreset0 = mxGetPr(xreset0_IN);
	    
    /* Check the dimensions of input data */
        
    if (mxGetN(xn_IN) ==0 || mxGetM(xn_IN) ==0) mexErrMsgTxt("Empty first input argument in mcaziyp"); 
    if (mxGetN(xreset0_IN) ==0 || mxGetM(xreset0_IN) ==0) mexErrMsgTxt("Empty second input argument in mcaziyp"); 
    if (mxGetM(xn_IN) > 1 || mxGetN(xn_IN) > 1) mexErrMsgTxt("mcaziyp requires a scalar for the first input argument.");
    if (mxGetM(xreset0_IN) > 1 || mxGetN(xreset0_IN) > 1) mexErrMsgTxt("mcaziyp requires a scalar for the second input argument.");
	
	/* Create matrix for the return arguments */

	s0_OUT = mxCreateDoubleMatrix((mwSize)xn[0], 1, mxREAL);

	/* Assign pointers to the various parameters */

	s0out = mxGetPr(s0_OUT);

	/* Do the actual computations in a subroutine */

	azimuth(s0out,xn,xreset0);
	
	return;
}
