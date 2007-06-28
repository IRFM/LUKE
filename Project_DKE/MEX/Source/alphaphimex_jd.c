/*================================================================================================
    alphaphimex_jd.c    MEX file implementation of : 
    alphaphi_jd.c,  which is a c subroutine for the calculation of 
    the fully relativistic absorption coefficient 
    for arbitrary RF waves interacting with electrons

=> xalphaphi = alphaphimex_jd(xa,xb,xbeta,xNpar,xNperp,xepolp,xepolm,xepolz,n,rel_opt,ns,pperpmax);

    INPUTS : 

        REQUIRED
        
        - xa    : omega_pe^2/omega_rf^2 [1,nx]
        - xb    : omega_ce/omega_rf [1,nx]
        - xbeta : sqrt(kTe/mc2) [1,nx]
        - xnpar : parallel index of refraction [1,nx]
        - xnperp: perpendicular index of refraction [1,nx]
        - xepolp: polarization vector component in rotating direction p [1,nx]
        - xepolm: polarization vector component in rotating direction m [1,nx]
        - xepolz: polarization vector component in parallel direction z [1,nx]
        - n     : harmonic number [1,1] 
        
        OPTIONAL
           
        - rel_opt : option for non-relativistic (0) or relativistic (1) calculations (default: 0)
        - ns      : number of pperp integration steps [1,1] (default: 1000)
        - pperpmax: maximum value for pperp integration [1,1] (default: 10)
  Note: pperpmax valid only where xNpar >= 1; elsewhere, pperpmax chosen by ellipse max position.

    OUTPUTS :

        - xalphaphi: alpha/(omega_rf/clum/phi) [1,nx]

by Joan Decker (CEA-DRFC) <joan.decker@cea.fr> and Yves Peysson (CEA-DRFC)  <yves.peysson@cea.fr> 

================================================================================================*/

/*#include <math.h>*/
#include "mex.h"
#include <complex.h>

/* subroutines list */

double alphaphi_jd();

/* Input Arguments */

#define XA_IN           prhs[0]
#define XB_IN           prhs[1]
#define XBETA_IN        prhs[2]
#define XNPAR_IN        prhs[3]
#define XNPERP_IN       prhs[4]
#define XEPOLP_R_IN     prhs[5]
#define XEPOLP_I_IN     prhs[6]
#define XEPOLM_R_IN     prhs[7]
#define XEPOLM_I_IN     prhs[8]
#define XEPOLZ_R_IN     prhs[9]
#define XEPOLZ_I_IN     prhs[10]
#define N_IN            prhs[11]
#define REL_OPT_IN      prhs[12]
#define NS_IN           prhs[13]
#define PPERPMAX_IN     prhs[14]

/* Output Arguments */

#define XALPHAPHI_OUT   plhs[0]

void mexFunction( int nlhs, mxArray *plhs[], 
            int nrhs, const mxArray *prhs[] )
     
{     
    
    int n,rel_opt,ns;
    double pperpmax;
    double *xa,*xb,*xbeta,*xnpar,*xnperp;
    double *xepolp_r,*xepolp_i,*xepolm_r,*xepolm_i,*xepolz_r,*xepolz_i;
    double *xalphaphi;
    
    double complex xepolp,xepolm,xepolz;
    
    int nx,m;
    
    /* Check out the arguments */

    if (nlhs != 1) {
        mexErrMsgTxt("Wrong number of output arguments for alphaphi_fr_jd");
    }
    
    if (nrhs < 12) {
        mexErrMsgTxt("Not enough input arguments calling alphaphi_fr_jd");
    }
 
    if (nrhs > 15) {
        mexErrMsgTxt("Too many input arguments calling alphaphi_fr_jd");
    }
      
    if (nrhs < 13) {
        rel_opt = 0;} 
    else {
        rel_opt = *mxGetPr(REL_OPT_IN);
    }    
    
    if (nrhs < 14) {
        ns = 1000;} 
    else {
        ns = *mxGetPr(NS_IN);
    }    
    
    if (nrhs < 15) {
        pperpmax = 10;} 
    else {
        pperpmax = *mxGetPr(PPERPMAX_IN);
    }    
    
    /* Get Input Arguments */

    xa = mxGetPr(XA_IN);
    xb = mxGetPr(XB_IN);
    xbeta = mxGetPr(XBETA_IN);
    xnpar = mxGetPr(XNPAR_IN);
    xnperp = mxGetPr(XNPERP_IN);
    xepolp_r = mxGetPr(XEPOLP_R_IN);
    xepolp_i = mxGetPr(XEPOLP_I_IN);
    xepolm_r = mxGetPr(XEPOLM_R_IN);
    xepolm_i = mxGetPr(XEPOLM_I_IN);
    xepolz_r = mxGetPr(XEPOLZ_R_IN);
    xepolz_i = mxGetPr(XEPOLZ_I_IN);
    
    n = *mxGetPr(N_IN);
    
    /* Create Output Arguments */
    
    nx = mxGetN(XA_IN);
    XALPHAPHI_OUT = mxCreateDoubleMatrix(1,nx,mxREAL);
    xalphaphi = mxGetPr(XALPHAPHI_OUT);  
    
    /* Local test 
    
    xalphaphi[0] = 0.1;
    xalphaphi[1] = 0.2;
    
    mexPrintf("xa[0],xa[1] : %g,%g\n",xa[0],xa[1]);
    mexPrintf("xb[0],xb[1] : %g,%g\n",xb[0],xb[1]);
    mexPrintf("xbeta[0],xbeta[1] : %g,%g\n",xbeta[0],xbeta[1]);
    mexPrintf("xnpar[0],xnpar[1] : %g,%g\n",xnpar[0],xnpar[1]);
    mexPrintf("xnperp[0],xnperp[1] : %g,%g\n",xnperp[0],xnperp[1]);
    
    mexPrintf("n,rel_opt,ns,pperpmax : %i,%i,%i,%g\n",n,rel_opt,ns,pperpmax);*/

    for (m = 0; m < nx; m++) {
        
        xepolp = xepolp_r[m] + I*xepolp_i[m];
        xepolm = xepolm_r[m] + I*xepolm_i[m];
        xepolz = xepolz_r[m] + I*xepolz_i[m];
        
        /*mexPrintf("xepolp : %g + I*%g\n",creal(xepolp),cimag(xepolp));
        mexPrintf("xepolm : %g + I*%g\n",creal(xepolm),cimag(xepolm));
        mexPrintf("xepolz : %g + I*%g\n",creal(xepolz),cimag(xepolz));*/
    
        xalphaphi[m] = alphaphi_jd(xa[m],xb[m],xbeta[m],xnpar[m],xnperp[m],xepolp,xepolm,xepolz,n,rel_opt,ns,pperpmax);
    }
     
}

