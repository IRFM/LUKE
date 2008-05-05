#include <math.h>
#include <complex.h>
#include <bessel_IJK_jd.h>
/*#include "mex.h"*/
#define PI 3.141592653589793

double integral_fr_jd();

double alphaphi_jd(a,b,beta,npar,nperp,epolp,epolm,epolz,n,rel_opt,ns,pperpmax)
double a,b,beta,npar,nperp,pperpmax;
double complex epolp,epolm,epolz;
int n,rel_opt,ns;
{   /* Local test */
     
    /*mexPrintf("a : %g\n",a);
    mexPrintf("b : %g\n",b);
    mexPrintf("beta : %g\n",beta);
    mexPrintf("npar : %g\n",npar);
    mexPrintf("nperp : %g\n",nperp);
    mexPrintf("epolp : %g + i*%g\n",creal(epolp),cimag(epolp));
    mexPrintf("epolm : %g + i*%g\n",creal(epolm),cimag(epolm));
    mexPrintf("epolz : %g + i*%g\n",creal(epolz),cimag(epolz));
    mexPrintf("n,rel_opt,ns,pperpmax : %i,%i,%i,%g\n",n,rel_opt,ns,pperpmax);*/

    /*return(a);*/
    
    double absint,pperpmax_ellipse,r;
    double yn,slperp,npar2,beta2;
    int ntest;
    
    yn = b*n;
    slperp = nperp*beta/b;
    npar2 = npar*npar;
    beta2 = beta*beta;
    
    /* Tests for pperp grid accuracy */
    
    ntest = 2*PI*ns/pperpmax/slperp;
    if (ntest < 50) {
        mexPrintf("WARNING : Some positions have as little as %i integration steps per Bessel period\n",ntest);
    }
      
    /* Resonance curve type */
    
    absint = 0;
    
    if (rel_opt == 1) {/* relativistic case */
        if (npar2 > 1) {/* hyperbola */
            absint = integral_fr_jd(pperpmax,npar,yn,beta,epolp,epolm,epolz,slperp,n,ns,-1); 
        } else {        
        if (npar2 == 1 && n > 0) {/* parabola */
            absint = integral_fr_jd(pperpmax,npar,yn,beta,epolp,epolm,epolz,slperp,n,ns,0); 
        } else {        
        if (npar2 < 1 && n > 0 && yn > sqrt(1 - npar2)) {/* ellipse */
            
            /* pperpmax redefined for ellipse */
            
            pperpmax_ellipse = sqrt(yn*yn/(1 - npar2) - 1)/beta;
            if (pperpmax_ellipse > pperpmax) {
                pperpmax_ellipse = pperpmax;
            }
            
            absint = integral_fr_jd(pperpmax_ellipse,npar,yn,beta,epolp,epolm,epolz,slperp,n,ns,1); 
            absint = absint + integral_fr_jd(pperpmax_ellipse,npar,yn,beta,epolp,epolm,epolz,slperp,n,ns,-1); 
        }}}
    } else {/* non-relativistic case - straight line */
        if ((1 - yn)*(1 - yn) < npar2) {
            absint = integral_fr_jd(pperpmax,npar,yn,beta,epolp,epolm,epolz,slperp,n,ns,2); 
        }
    }

    
    if (rel_opt == 1) {
        if (beta2 < 0.002) { /* asymptotic expression */
            r = 1 - 15*beta2/8 + 345*beta2*beta2/128;
        } else {
            r = sqrt(PI/2)*beta/besskn(2,1/beta2)/exp(1/beta2);
        }
        
        /*mexPrintf("besskn(2,1/beta2)) : %g\n",besskn(2,1/beta2));
        mexPrintf("exp(1/beta2) : %g\n",exp(1/beta2));
        mexPrintf("r : %g\n",r);*/
        
    } else {
        r = 1;
    }
    
    /*mexPrintf("beta2,absint : %g,%g\n",beta2,absint);*/
    
    return(sqrt(PI/2)*a*r*absint/beta);
}

double integral_fr_jd(pperpmax,npar,yn,beta,epolp,epolm,epolz,slperp,n,ns,resopt) 
double pperpmax,npar,yn,beta,slperp;
double complex epolp,epolm,epolz;
int n,ns,resopt;
{
    /* simple method extracted from MATLAB version */
    
    double absint,fint,dpperp,pperp,pperp2,pparres,pparres2,zeta,theta2,gamma;
    double complex theta;
    double yn2,npar2,beta2;
    int m,sigma;
    
    /* mexPrintf("pperpmax,npar,yn,beta,epolp,epolm,epolz,slperp,n,ns,resopt : %g,%g,%g,%g,%g,%g,%g,%g,%i,%i,%i\n",pperpmax,npar,yn,beta,epolp,epolm,epolz,slperp,n,ns,resopt); */
    
    dpperp = pperpmax/ns;
    
    /* mexPrintf("ns,pperpmax,dpperp : %i,%g,%g\n",ns,pperpmax,dpperp);*/
    
    pperp = dpperp/2;
    yn2 = yn*yn;
    npar2 = npar*npar;
    beta2 = beta*beta;
    
    absint = 0;
    
    for (m = 0; m < ns; m++) {
        
        pperp2 = pperp*pperp;
        
        /* resonance condition gives ppar*/
        
        sigma = 0;
        if (npar > 0) {
            sigma = 1;
        } else {
        if (npar < 0) { 
            sigma = -1;
        }}        
        
        if (resopt == -1) {/* branch m */
            pparres = (npar*yn - sigma*sqrt(yn2 - (1 - npar2)*(1 + beta2*pperp2)))/(beta*(1 - npar2));            
        } else {
        if (resopt == 1) {/* branch p */
            pparres = (npar*yn + sigma*sqrt(yn2 - (1 - npar2)*(1 + beta2*pperp2)))/(beta*(1 - npar2));
        } else {
        if (resopt == 0) {/* branch 0 */
            pparres = sigma*(1 - yn2 + pperp2*beta2)/(2*beta*yn);
        } else { /* non-relativistic calculation */
            pparres = (1 - yn)/beta/npar;
        }}}

        /* mexPrintf("m,pparres,npar,npar2,sigma,yn,yn2,beta,beta2,pperp2 : %i,%g,%g,%g,%i,%g,%g,%g,%g,%g\n",m,pparres,npar,npar2,sigma,yn,yn2,beta,beta2,pperp2); */

        pparres2 = pparres*pparres;
        
        /* polarization term */
        
        zeta = pperp*slperp;
        theta = (epolp*bessjn(n+1,zeta) + epolm*bessjn(n-1,zeta))/sqrt(2) + epolz*bessjn(n,zeta)*pparres/pperp;
        theta2 = cabs(theta)*cabs(theta);
        
        /* integrand */
        
        if (resopt*resopt <= 1) { /* relativistic case */
            gamma = sqrt(1 + (pparres2 + pperp2)*beta2);
            fint = pperp2*pperp*theta2*exp(-(gamma - 1)/beta2)/fabs(gamma*npar - pparres*beta);
            
            /* mexPrintf("m,pparres,pperp,theta2,gamma,fint : %i,%g,%g,%g,%g,%g\n",m,pparres,pperp,theta2,gamma,fint); */
        } else {
            fint = pperp2*pperp*theta2*exp(-(pparres2 + pperp2)/2)/fabs(npar);
            
             /* mexPrintf("m,pparres,pperp,theta2,npar,fint : %i,%g,%g,%g,%g,%g\n",m,pparres,pperp,theta2,npar,fint); */
        }

        absint = absint + fint*dpperp;
        
        /* mexPrintf("m,pparres,pperp,fint,absint : %i,%g,%g,%g,%g\n",m,pparres,pperp,fint,absint); */

        pperp = pperp + dpperp;
                
    }
        
    return(absint);    
}    

