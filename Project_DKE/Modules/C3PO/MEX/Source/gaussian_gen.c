/*
 
	gaussian_gen.C	MEX file for a test program describing a centered random variable with a Gaussian distribution function
					
	[s0] = gaussian_gen(xn,halfmode,fwmh,xreset0)

	INPUT:
		- xn: number of trials [1,1]
        - halfmode: 0 -> x = (-inf:+Inf), 1 -> x = (0:+Inf)
        - fwmh: full width at half maximum
		- xreset0: initialization number for the random generator [1,1]  

	OUTPUT:
	
		- x : random value [xn,1]



by Y.PEYSSON CEA-DRFC <yves.peysson@cea.fr>
*/

#include <math.h>
#include "mex.h"

/*input arguments*/

#define	xn_IN		prhs[0]
#define	halfmode_IN	prhs[1]
#define	fwhm_IN	    prhs[2]
#define	xreset0_IN	prhs[3]           

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



tirgaussian(reset,halfmode,fwhm,res)
long int *reset;
double *halfmode,*fwhm,*res;
{
    long int test = 0;
    double rand1,rand2,rand3,rand4;
        
    while (test == 0) {
        rand1 = -(fwhm[0]/(2.0*sqrt(2.0*log(2.0))))*(fwhm[0]/(2.0*sqrt(2.0*log(2.0))))*log(ran2(reset));
        rand2 = -(fwhm[0]/(2.0*sqrt(2.0*log(2.0))))*(fwhm[0]/(2.0*sqrt(2.0*log(2.0))))*log(ran2(reset)); 
        rand3 = 0.5*(rand1-1.0)*(rand1-1.0);
        if (rand3 <= rand2) {
            if (halfmode[0] == 1) {
                res[0] = rand1;
            } else {
                res[0] = rand1*(2.0*ran2(reset) - 1.0);
            }
            test = 1;
        }
    }
}




static gaussian(s0out,xn,halfmode,fwhm,xreset0)
double s0out[];
double *xn,*xreset0,*halfmode,*fwhm;
{
	double xx;
	long int i,n,reset,reset0;
/*
	Initialisation generateur v.a. uniform
*/
	reset0 = (long int)xreset0[0];
	reset = -reset0;

	n = (long int)xn[0];
	
	for (i=0L; i < n; i++) {
		tirgaussian(&reset,halfmode,fwhm,&xx);
		s0out[i] = xx;
	}
}



void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) { 

	double *s0out;
	double *xn,*xreset0,*fwhm,*halfmode;

	/* Check for proper number of arguments */

	if (nrhs < 4) mexErrMsgTxt("The function gaussian_gen requires at least four input arguments.");
	if (nlhs > 1) mexErrMsgTxt("The function gaussian_gen requires up to one output argument.");
	
    xn = mxGetPr(xn_IN);
    halfmode = mxGetPr(halfmode_IN);
    fwhm = mxGetPr(fwhm_IN);
    xreset0 = mxGetPr(xreset0_IN);
	    	
	/* Create matrix for the return arguments */

	s0_OUT = mxCreateDoubleMatrix((mwSize)xn[0], 1, mxREAL);

	/* Assign pointers to the various parameters */

	s0out = mxGetPr(s0_OUT);

	/* Do the actual computations in a subroutine */

	gaussian(s0out,xn,halfmode,fwhm,xreset0);
	
	return;
}
