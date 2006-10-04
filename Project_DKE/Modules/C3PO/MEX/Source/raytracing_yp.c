/*
  
    raytracing.c    MEX file implementation of a universal ray-tracing for electron waves

    call -> [tout, yout] = raytracing_yp(rayparam,equil,y0)

    INPUT: 

    - rayparam: parameters for ray-tracing structure [1,1]
    - equil: numerical equilibrium structure [1,1]
    - y0: ray initial conditions [1,1]

    OUTPUT: 

    - tout: returned integration time points (row-vector).
    - yout: returned solution, one solution column-vector per tout-value.

    WARNING: none

    REFERENCE: none

    LAST UPDATE: 23/07/2006

    by Y.PEYSSON (CEA-DRFC)  <yves.peysson@cea.fr> and Joan Decker (CEA-DRFC) <joan.decker@cea.fr>
*/

#include <complex.h>
#include <math.h>
#include "mex.h"


struct raymagnetic {
    double *rn;
    double *drndx;
    double *Rn;
    double *dRndx;
    double *BPn;
    double *dBPndx;
    double *BPHIn;
    double *dBPHIndx;
    double *B;
    double *dBdx;
    double *salpha;
    double *dsalphadx;
    double *calpha;
    double *dcalphadx;
    double *gradrhon;
    double *dgradrhondx;
};

struct rayprofiles {
    double *Te;
    double *ne;
    double *zTi;
    double *zni;
    double *dTedx;
    double *dnedx;
    double **dzTidx;
    double **dznidx;
};

struct susceptibilitytensor {
    double complex *Xxx;
    double complex *Xxy;
    double complex *Xxz;
    double complex *Xyy;
    double complex *Xyz;
    double complex *Xzz;
    double complex *dXxxdx;
    double complex *dXxydx;
    double complex *dXxzdx;
    double complex *dXyydx;
    double complex *dXyzdx;
    double complex *dXzzdx; 
};

struct rayparam {
    double *testmode;
    double *tensortype;
    double *t0;
    double *tfinal;
    double *dt0;
    double *drho;
    double *tol;
    double *kmax;
    double *ncyclharm;
};

struct equilparam {
    double *zZi;
    double *zmi;
    int *ns;
    double *Rp;
    double *ap;
    double *Zp;
    double *psia;
};


struct polynomial_piecewise_1D {
    mxChar  *form_f;
    double  *breaks_f;
    double  *coefs_f;
    double  *pieces_f;
    double  *order_f;
    double  *dim_f;
    mxChar  *orient_f;
    mxChar  *form_dfdrho;
    double  *breaks_dfdrho;
    double  *coefs_dfdrho;
    double  *pieces_dfdrho;
    double  *order_dfdrho;
    double  *dim_dfdrho;
    mxChar  *orient_dfdrho;
};

struct polynomial_piecewise_2D {
    double  *n;
    mxChar  *form_a0;
    double  *breaks_a0;
    double  *coefs_a0;
    double  *pieces_a0;
    double  *order_a0;
    double  *dim_a0;
    mxChar  *orient_a0;
    mxChar  *form_da0drho;
    double  *breaks_da0drho;
    double  *coefs_da0drho;
    double  *pieces_da0drho;
    double  *order_da0drho;
    double  *dim_da0drho;
    mxChar  *orient_da0drho;
    mxChar  *form_an;
    double  *breaks_an;
    double  *coefs_an;
    double  *pieces_an;
    double  *order_an;
    double  *dim_an;
    mxChar  *orient_an;
    mxChar  *form_dandrho;
    double  *breaks_dandrho;
    double  *coefs_dandrho;
    double  *pieces_dandrho;
    double  *order_dandrho;
    double  *dim_dandrho;
    mxChar  *orient_dandrho;
    mxChar  *form_bn;
    double  *breaks_bn;
    double  *coefs_bn;
    double  *pieces_bn;
    double  *order_bn;
    double  *dim_bn;
    mxChar  *orient_bn;
    mxChar  *form_dbndrho;
    double  *breaks_dbndrho;
    double  *coefs_dbndrho;
    double  *pieces_dbndrho;
    double  *order_dbndrho;
    double  *dim_dbndrho;
    mxChar  *orient_dbndrho;
};

typedef struct polynomial_piecewise_1D pp_1D_format;
typedef struct polynomial_piecewise_2D pp_2D_format;
typedef struct rayparam rayparam_format;
typedef struct equilparam equilparam_format;
typedef struct susceptibilitytensor susceptibilitytensor_format;
typedef struct refractiveindex refractiveindex_format;
typedef struct raymagnetic raymagnetic_format;
typedef struct rayprofiles rayprofiles_format;

void ppval_1D();
void ppval_2D();
void ray();
void rayindex();
void susceptibility();
void coldtensor();
void dsolve();
void disprel();
void interpequil();
void interpequil_test();
equilparam_format load_equil_param();
rayparam_format load_ray_param();
pp_1D_format load_equil_1D();
pp_2D_format load_equil_2D();
double inf_norm();
double sgn();
void buildXstruc();
void calcY();
void Zdisp();
void ZFriedConte();
void hottensor();
void Gamma();
void modBessel();
void imagBessel();
void dawson();
void smith();
void vacuumtensor();

/* Input Arguments */

#define RAYPARAM_IN  prhs[0]
#define EQUIL_IN     prhs[1]
#define Y0_IN    prhs[2]

/* Output Arguments */

#define T_OUT   plhs[0]
#define Y_OUT   plhs[1]

#define M 8
#define SAFETY 0.8
#define PGROW 0.2
#define PSHRINK 0.25
#define PI 3.14159265358979
#define MAXCYCLHARM 101

/* Fehlberg coefficients */

static double alpha[5] = { 1.0/4.0,  3.0/8.0,  12.0/13.0,  1.0,  1.0/2.0 };

static double beta[5][5] = {
    { 1.0/4.0, 3.0/32.0,  1932.0/2197.0,   8341.0/4104.0,  -6080.0/20520.0 },
    {     0.0, 9.0/32.0, -7200.0/2197.0, -32832.0/4104.0,  41040.0/20520.0 },
    {     0.0,      0.0,  7296.0/2197.0,  29440.0/4104.0, -28352.0/20520.0 },
    {     0.0,      0.0,            0.0,   -845.0/4104.0,   9295.0/20520.0 },
    {     0.0,      0.0,            0.0,             0.0,  -5643.0/20520.0 }
};

static double gama[6][2] = {
    {   902880.0/7618050.0,   -2090.0/752400.0 },
    {                  0.0,                0.0 },
    {  3953664.0/7618050.0,   22528.0/752400.0 },
    {  3855735.0/7618050.0,   21970.0/752400.0 },
    { -1371249.0/7618050.0,  -15048.0/752400.0 },
    {   277020.0/7618050.0,  -27360.0/752400.0 }
};


void mexFunction(   int     nlhs,
    mxArray *plhs[],
    int     nrhs,
    const mxArray   *prhs[]
)
{
    
    double zZi,zmi;  
    pp_1D_format Te_fit,ne_fit,zTi_fit,zni_fit,dRstardpsin_fit;
    pp_2D_format R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit;
    rayparam_format rayparam;
    equilparam_format equilparam;
  
    double *Te,*dTedrho,*ne,*dnedrho,*zTi,*dzTidrho,*zni,*dznidrho;
    double *BR,*dBRdrho,*dBRdtheta;   
    double *BZ,*dBZdrho,*dBZdtheta;    
    double *BPHI,*dBPHIdrho,*dBPHIdtheta;
    double *R,*dRdrho,*dRdtheta,*d2Rdtheta2,*d2Rdthetadrho;
    double *Z,*dZdrho,*dZdtheta,*d2Zdtheta2,*d2Zdthetadrho;
    double dummy1,dummy2;
    
    /* Check out the arguments */

    if (nrhs != 3) {
        mexErrMsgTxt("Wrong number of input arguments for raytracing_yp");
    } else if (nlhs != 2) {
        mexErrMsgTxt("Wrong number of output arguments for raytracing_yp");
    }
    
    if (!mxIsStruct(prhs[0])) mexErrMsgTxt("Input arguments must be structures");
    if (!mxIsStruct(prhs[1])) mexErrMsgTxt("Input arguments must be structures");

/*    double complex iBn,iBnp,iBnpp;   
    modBessel(-5.4,(double complex)(3.0 +1.2*I),&iBn,&iBnp,&iBnpp);
    mexPrintf("Bessel(-5.4,3.+1.2*i),Bp,Bpp:%g,%g,%g,%g,%g,%g\n",iBn,iBnp,iBnpp);
*/

/* Get Input Arguments */

    rayparam = load_ray_param(RAYPARAM_IN);       
    equilparam = load_equil_param(EQUIL_IN);

    dRstardpsin_fit = load_equil_1D(EQUIL_IN,"dRstardpsin_fit"); 
    Te_fit = load_equil_1D(EQUIL_IN,"Te_fit");
    ne_fit = load_equil_1D(EQUIL_IN,"ne_fit");
    zTi_fit = load_equil_1D(EQUIL_IN,"zTi_fit"); 
    zni_fit = load_equil_1D(EQUIL_IN,"zni_fit");
    
    R_fit = load_equil_2D(EQUIL_IN,"R_fit");
    Z_fit = load_equil_2D(EQUIL_IN,"Z_fit");
    BR_fit = load_equil_2D(EQUIL_IN,"BR_fit");
    BZ_fit = load_equil_2D(EQUIL_IN,"BZ_fit");
    BPHI_fit = load_equil_2D(EQUIL_IN,"BPHI_fit"); 
    
/* Test mode only */
    
    if (rayparam.testmode[0]) {/* keep this section for tests if necessary */
        mexPrintf("tol : %g\n",rayparam.tol[0]);
        mexPrintf("zZi(4) : %g\n",equilparam.zZi[3]);
        
        mexPrintf("--------------\n");

        mexPrintf("Te_fit.coefs_f(1): %g\n",Te_fit.coefs_f[0]);
        mexPrintf("Te_fit.coefs_dfdrho(1): %g\n",Te_fit.coefs_dfdrho[0]);
        mexPrintf("BPHI_fit.n: %g\n",BPHI_fit.n[0]);
        mexPrintf("BPHI_fit.coefs_bn(1): %g\n",BPHI_fit.coefs_bn[0]);
        mexPrintf("BPHI_fit.coefs_dbndrho(1): %g\n",BPHI_fit.coefs_dbndrho[0]);

        mexPrintf("--------------\n");
            
        Te = mxCalloc(1,sizeof(double));
        dTedrho = mxCalloc(1,sizeof(double));
        ppval_1D(Te_fit,rayparam.drho[0],0.25,Te,dTedrho);
        mexPrintf("Te(0.25),dTedrho(0.25) (keV): %g,%g\n",Te[0],dTedrho[0]);    
        mxFree(Te);
        mxFree(dTedrho);
        
        ne = mxCalloc(1,sizeof(double));
        dnedrho = mxCalloc(1,sizeof(double));
        ppval_1D(ne_fit,rayparam.drho[0],0.25,ne,dnedrho);
        mexPrintf("ne(0.25),dnedrho(0.25) (10+19 m-3): %g,%g\n",ne[0]/1e19,dnedrho[0]/1e19);    
        mxFree(ne);
        mxFree(dnedrho);

        zTi = mxCalloc(equilparam.ns[0],sizeof(double));
        dzTidrho = mxCalloc(equilparam.ns[0],sizeof(double));
        ppval_1D(zTi_fit,rayparam.drho[0],0.25,zTi,dzTidrho);
        mexPrintf("zTi(2,0.25),dzTidrho(2,0.25) (keV): %g,%g\n",zTi[1],dzTidrho[1]);
        mxFree(zTi);
        mxFree(dzTidrho);
        
        zni = mxCalloc(equilparam.ns[0],sizeof(double));
        dznidrho = mxCalloc(equilparam.ns[0],sizeof(double));
        ppval_1D(zni_fit,rayparam.drho[0],0.25,zni,dznidrho);
        mexPrintf("zni(2,0.25),dznidrho(2,0.25) (10+19 m-3): %g,%g\n",zni[1]/1e19,dznidrho[1]/1e19);
        mxFree(zni);
        mxFree(dznidrho);
       
        R = mxCalloc(1,sizeof(double));
        dRdrho = mxCalloc(1,sizeof(double));
        dRdtheta = mxCalloc(1,sizeof(double));
        d2Rdtheta2 = mxCalloc(1,sizeof(double));
        d2Rdthetadrho = mxCalloc(1,sizeof(double));
        ppval_2D(R_fit,rayparam.drho[0],0.25,0.2,R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho);
        mexPrintf("R(0.25,0.2),dRdrho(0.25,0.2),dRdtheta(0.25,0.2) (m): %g,%g,%g\n",R[0],dRdrho[0],dRdtheta[0],d2Rdtheta2[0],d2Rdthetadrho[0]);
        mxFree(R);
        mxFree(dRdrho); 
        mxFree(dRdtheta);
        mxFree(d2Rdtheta2);
        mxFree(d2Rdthetadrho);
        
        Z = mxCalloc(1,sizeof(double));
        dZdrho = mxCalloc(1,sizeof(double));
        dZdtheta = mxCalloc(1,sizeof(double));
        d2Zdtheta2 = mxCalloc(1,sizeof(double));
        d2Zdthetadrho = mxCalloc(1,sizeof(double));
        ppval_2D(Z_fit,rayparam.drho[0],0.25,0.2,Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho);
        mexPrintf("Z(0.25,0.2),dZdrho(0.25,0.2),dZdtheta(0.25,0.2) (m): %g,%g,%g\n",Z[0],dZdrho[0],dZdtheta[0],d2Zdtheta2[0],d2Zdthetadrho[0]);
        mxFree(Z);
        mxFree(dZdrho); 
        mxFree(dZdtheta);
        mxFree(d2Zdtheta2);
        mxFree(d2Zdthetadrho);
                       
        BR = mxCalloc(1,sizeof(double));
        dBRdrho = mxCalloc(1,sizeof(double));
        dBRdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(BR_fit,rayparam.drho[0],0.25,0.2,BR,dBRdrho,dBRdtheta,&dummy1,&dummy2);
        mexPrintf("BR(0.25,0.2),dBRdrho(0.25,0.2),dBRdtheta(0.25,0.2) (T): %g,%g,%g\n",BR[0],dBRdrho[0],dBRdtheta[0]);
        mxFree(BR);
        mxFree(dBRdrho); 
        mxFree(dBRdtheta); 

        BZ = mxCalloc(1,sizeof(double));
        dBZdrho = mxCalloc(1,sizeof(double));
        dBZdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(BZ_fit,rayparam.drho[0],0.25,0.2,BZ,dBZdrho,dBZdtheta,&dummy1,&dummy2);
        mexPrintf("BZ(0.25,0.2),dBZdrho(0.25,0.2),dBZdtheta(0.25,0.2) (T): %g,%g,%g\n",BZ[0],dBZdrho[0],dBZdtheta[0]);
        mxFree(BZ);
        mxFree(dBZdrho); 
        mxFree(dBZdtheta);     
 
        BPHI = mxCalloc(1,sizeof(double));
        dBPHIdrho = mxCalloc(1,sizeof(double));
        dBPHIdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(BPHI_fit,rayparam.drho[0],0.25,0.2,BPHI,dBPHIdrho,dBPHIdtheta,&dummy1,&dummy2);
        mexPrintf("BPHI(0.25,0.2),dBPHIdrho(0.25,0.2),dBPHIdtheta(0.25,0.2) (T): %g,%g,%g\n",BPHI[0],dBPHIdrho[0],dBPHIdtheta[0]);
        mxFree(BPHI);
        mxFree(dBPHIdrho); 
        mxFree(dBPHIdtheta); 
          
    }
    
/* Runge-Kutta  */

    double  *tout,*yout; 
    double  *toutp,*youtp;
    double  *y;
    double  *y0;

    register unsigned int   K=0,m,k=0,kk,ii=0;

    double *s0,*s1,*s2,*s3,*s4,*s5,*s6;
    double *tempt,*temp0,*temp1,*temp2,*temp3,*temp4,*temp5,*temp6;

    double ymax,tau,delta,h,hmax,hmin;
    
    double ydel[M];
    
    double t1,t2,rho1,rho2,theta1,theta2,phi1,phi2,krho1,krho2,m1,m2,n1,n2,omega1,omega2;
    double rho_step,m_step;

    y0 = mxGetPr(Y0_IN);
    
    /*
     * Create and Initialize Return Arguments
     */

    t1 = rayparam.t0[0];
    
    rho1 = y0[0];
    theta1 = y0[1];
    phi1 = y0[2];
    krho1 = y0[3];
    m1 = y0[4];
    n1 = y0[5];
    omega1 = y0[6];
    
    rho_step = rho1;
    m_step = m1;

    /* solves the dispersion relation to have consistent initial input*/
    
    /*
    //mexPrintf("t1,rho1,theta1,phi1,krho1,m1,n1,omega1:%g,%g,%g,%g,%g,%g,%g,%g\n",t1,rho1,theta1,phi1,krho1,m1,n1,omega1);
    
    //dsolve(&y0[3],y0,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit);
 
    //mexPrintf("t1,y0[0],y0[1],y0[2],y0[3],y0[4],y0[5],y0[6]:%g,%g,%g,%g,%g,%g,%g,%g\n",t1,y0[0],y0[1],y0[2],y0[3],y0[4],y0[5],y0[6]);
    */

    /*
     * Create arguments for calling user function
     */

    tempt = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp0 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp1 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp2 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp3 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp4 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp5 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp6 = mxCalloc(rayparam.kmax[0],sizeof(double));

    s0 = mxCalloc(M,sizeof(double));
    s1 = mxCalloc(M,sizeof(double));
    s2 = mxCalloc(M,sizeof(double));
    s3 = mxCalloc(M,sizeof(double));
    s4 = mxCalloc(M,sizeof(double));
    s5 = mxCalloc(M,sizeof(double));
    s6 = mxCalloc(M,sizeof(double));

    /*
     * Initialization
     */

    h = rayparam.dt0[0];

    tempt[0] = t1;
    temp0[0] = rho1;
    temp1[0] = theta1;
    temp2[0] = phi1;
    temp3[0] = krho1;
    temp4[0] = m1;
    temp5[0] = n1;  
    temp6[0] = omega1;

    /*
     * The main loop
     */
    
   while ((t1 < rayparam.tfinal[0]) && (k < rayparam.kmax[0]-1)) {
        ii++; 
//        mexPrintf("ii:%d\n",ii);
        if ((t1 + h) > rayparam.tfinal[0]) {
            h = rayparam.tfinal[0] - t1;
        }
        if (ii > rayparam.kmax[0]) {
            goto Endloop;
        }
        
        /*
         * Compute the slopes
         */

        /* ts = t  and  s0 = y */

        s0[0] = rho1;
        s0[1] = theta1;
        s0[2] = phi1;
        s0[3] = krho1;
        s0[4] = m1;
        s0[5] = n1;
        s0[6] = omega1;
        
        for  (m = 0; m < M; m++) {
            y[m] = s0[m];
        }
        
        ray(s1,y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit,1);           
        /* s2 = feval(F, t+h*alpha(1), y+h*s1*beta(1,1), param); */

        for  (m = 0; m < M-3; m++) {/* only the first five coordinates are evolving (rho,theta,phi,krho,m) */
            y[m] = s0[m]+h*s1[m]*beta[0][0];
        }
         
            
        ray(s2,y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit,0);
        /* s3 = feval(F, t+h*alpha(2), y+h*[s1*beta(2,1)+s2*beta(2,2)], param); */

        for  (m = 0; m < M-3; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][1] + s2[m]*beta[1][1]);
        }

        ray(s3,y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit,0);

        /* s4 = feval(F, t+h*alpha(3), y+h*[s1*beta(3,1)+s2*beta(3,2)+...], param); */

        for  (m = 0; m < M-3; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][2] + s2[m]*beta[1][2]
                    +s3[m]*beta[2][2]);
        }
 
        ray(s4,y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit,0);

        /* s5 = feval(F, t+h*alpha(4), y+h*[s1*beta(4,1)+s2*beta(4,2)+...], param); */

        for  (m = 0; m < M-3; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][3] + s2[m]*beta[1][3]
                    +s3[m]*beta[2][3] + s4[m]*beta[3][3]);
        }


        ray(s5,y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit,0);

        /* s6 = feval(F, t+h*alpha(5), y+h*[s1*beta(5,1)+s2*beta(5,2)+...], param); */

        for  (m = 0; m < M-3; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][4] + s2[m]*beta[1][4]
                    +s3[m]*beta[2][4] + s4[m]*beta[3][4]
                    +s5[m]*beta[4][4]);
        }
        
        ray(s6,y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit,0);

        /*
         * Estimate the error and the acceptable error
         */

        for  (m = 0; m < M-3; m++) {
            ydel[m] = h*(s1[m]*gama[0][1] + s2[m]*gama[1][1]
                    + s3[m]*gama[2][1] + s4[m]*gama[3][1]
                    + s5[m]*gama[4][1] + s6[m]*gama[5][1]);
        }

        delta = inf_norm(ydel,M-3);/* only the first five coordinates are evolving (rho,theta,phi,krho,m) */
        ymax = inf_norm(s0,M-3);/* only the first five coordinates are evolving (rho,theta,phi,krho,m) */
        tau = rayparam.tol[0]*fmax(ymax,1.0);

        /*
         * Update the solution only if the error is acceptable
         */
        
         if (delta <= tau) {
            
            t2 = t1 + h;
            rho2 = rho1 + h*(s1[0]*gama[0][0] + s2[0]*gama[1][0]
                     + s3[0]*gama[2][0] + s4[0]*gama[3][0]
                     + s5[0]*gama[4][0] + s6[0]*gama[5][0]);
            theta2 = theta1 + h*(s1[1]*gama[0][0] + s2[1]*gama[1][0]
                     + s3[1]*gama[2][0] + s4[1]*gama[3][0]
                     + s5[1]*gama[4][0] + s6[1]*gama[5][0]);
            phi2 = phi1 + h*(s1[2]*gama[0][0] + s2[2]*gama[1][0]
                     + s3[2]*gama[2][0] + s4[2]*gama[3][0]
                     + s5[2]*gama[4][0] + s6[2]*gama[5][0]);
            krho2 = krho1 + h*(s1[3]*gama[0][0] + s2[3]*gama[1][0]
                     + s3[3]*gama[2][0] + s4[3]*gama[3][0]
                     + s5[3]*gama[4][0] + s6[3]*gama[5][0]);
            m2 = m1 + h*(s1[4]*gama[0][0] + s2[4]*gama[1][0]
                     + s3[4]*gama[2][0] + s4[4]*gama[3][0]
                     + s5[4]*gama[4][0] + s6[4]*gama[5][0]);
            n2 = n1;
            omega2 = omega1;

//            mexPrintf("t1,delta,ymax,h,rho2,theta2,phi2,krho2,m2:%g,%g,%g,%g,%g,%g,%g,%g,%g\n",t1,delta,ymax,h,rho2,theta2,phi2,krho2,m2); 
           mexPrintf("t1,rho2,theta2,phi2,krho2,m2:%g,%g,%g,%g,%g,%g\n",t1,rho2,theta2,phi2,krho2,m2); 
               
            if (rho2 < rayparam.drho[0]) {// Boundary condition at rho = 0  
                
                rho2 = rho1;
                theta2 = theta1 + PI;
                phi2 = phi1;
                krho2 = -krho1;
                m2 = m1;
                rho_step = rho2;
                m_step = m2;
              }
            
            if (rho2 > (1.0 - rayparam.drho[0])) {/* Specular reflexion enforced at rho = 1  */ 
                  mexPrintf("*****************specular reflection at rho = %g**************************\n",rho1);
                  rho2 = rho1;
                  phi2 = phi1;
                  theta2 = theta1;
 //                 s0[3] = - krho1;
 //                 dsolve(&krho2,s0,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit);
                  krho2 = -krho1; 
                  m2 = m1;
            }
            
    //        if (fabs(m2 - m_step) >= 1) {//step stored in Matlab memory

            if (fabs(rho2 - rho_step) >= rayparam.drho[0]) {//step stored in Matlab memory

//          if (fabs(rho2 - rho_step) >= rayparam.drho[0] && fabs(theta2 - theta_step) >= 1e-2) {//step stored in Matlab memory
                K = k+1;
                tempt[K] = t1;
                temp0[K] = rho2;
                temp1[K] = theta2;
                temp2[K] = phi2;
                temp3[K] = krho2;
                temp4[K] = m2;
                temp5[K] = n2;
                temp6[K] = omega2;
                
                rho_step = rho2;
                m_step = m2;
                k++;
            }
            
            t1 = t2;
            rho1 = rho2;
            theta1 = theta2;
            phi1 = phi2;
            krho1 = krho2;
            m1 = m2;
            n1 = n2;
            omega1 = omega2;
        
        }
    
        /*
         * Update the step size
         */


        if (delta) {
            if (delta < tau) {
                h = SAFETY*h*pow(tau/delta,PGROW);   
            } else {
                h = SAFETY*h*pow(tau/delta,PSHRINK);                
            }
        } else {       
           mexPrintf("WARNING delta :%g, the loop is stopped\n",delta);
           goto Endloop;
        }
        
    }

    if (t1 < rayparam.tfinal[0]) {
        mexPrintf("Singularity likely at t = %f or matrix full\n",t1);
    }
    
Endloop:
    
    /* Create final matrix for transferring data to MatLab */
    
    T_OUT = mxCreateDoubleMatrix(K,1,mxREAL);
    Y_OUT = mxCreateDoubleMatrix(K,M,mxREAL);
    tout = mxGetPr(T_OUT);
    yout = mxGetPr(Y_OUT);  
    for (kk = 0;kk < K; kk++) {
        tout[kk] = tempt[kk];
    }
    for (kk = 0;kk < K; kk++) {
        yout[kk] = temp0[kk];
    }
    for (kk = 0;kk < K; kk++) {
        yout[kk + K] = temp1[kk];
    }
    for (kk = 0;kk < K; kk++) {
        yout[kk + 2*K] = temp2[kk];
    }
    for (kk = 0;kk < K; kk++) {
        yout[kk + 3*K] = temp3[kk];
    }
    for (kk = 0;kk < K; kk++) {
        yout[kk + 4*K] = temp4[kk];
    }
    for (kk = 0;kk < K; kk++) {
        yout[kk + 5*K] = temp5[kk];
    }
    for (kk = 0;kk < K; kk++) {
        yout[kk + 6*K] = temp6[kk];
    }

    mxFree(tempt);
    mxFree(temp0);
    mxFree(temp1);
    mxFree(temp2);
    mxFree(temp3);
    mxFree(temp4);
    mxFree(temp5);
    mxFree(temp6);
    
    mxFree(s0);
    mxFree(s1);
    mxFree(s2);
    mxFree(s3);
    mxFree(s4);
    mxFree(s5);
    mxFree(s6);



}


rayparam_format load_ray_param(structure_name)
mxArray *structure_name;
{
    rayparam_format data;
       
    data.testmode = mxGetData(mxGetField(structure_name, 0, "testmode"));
    data.t0 = mxGetData(mxGetField(structure_name, 0, "t0"));
    data.tfinal = mxGetData(mxGetField(structure_name, 0, "tfinal"));
    data.dt0 = mxGetData(mxGetField(structure_name, 0, "dt0"));
    data.drho = mxGetData(mxGetField(structure_name, 0, "drho"));
    data.tol = mxGetData(mxGetField(structure_name, 0, "tol"));   
    data.kmax = mxGetData(mxGetField(structure_name, 0, "kmax"));
    data.tensortype = mxGetData(mxGetField(structure_name, 0, "tensortype")); 
    data.ncyclharm = mxGetData(mxGetField(structure_name, 0, "ncyclharm")); 
    
    return(data);
}

equilparam_format load_equil_param(structure_name)
mxArray *structure_name;
{
    equilparam_format data;
   
    data.zZi= mxGetData(mxGetField(structure_name, 0, "zZi"));
    data.zmi = mxGetData(mxGetField(structure_name, 0, "zmi"));
    data.ns = mxCalloc(1,sizeof(int));
    data.ns[0] = fmax(mxGetM(mxGetField(structure_name, 0, "zmi")),mxGetN(mxGetField(structure_name, 0, "zmi")));
    data.ap = mxGetData(mxGetField(structure_name, 0, "ap"));
    data.Rp = mxGetData(mxGetField(structure_name, 0, "Rp"));
    data.Zp = mxGetData(mxGetField(structure_name, 0, "Zp"));
    data.psia = mxGetData(mxGetField(structure_name, 0, "psia"));
    
    return(data);
} 

pp_1D_format load_equil_1D(structure_name,field_name)
mxArray *structure_name;
char *field_name;
{
    mxArray *tmp,*sub_tmp;
    pp_1D_format fit;
    
    tmp = mxGetField(structure_name, 0, field_name);  
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,0));
    if (mxIsStruct(sub_tmp)) {
        fit.form_f = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_f = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_f = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_f = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_f = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_f = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_f = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }

    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,1));
    if (mxIsStruct(sub_tmp)) {
        fit.form_dfdrho = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dfdrho = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dfdrho = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dfdrho = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dfdrho = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dfdrho = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dfdrho = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }

    return(fit);  
}

pp_2D_format load_equil_2D(structure_name,field_name)
mxArray *structure_name;
char *field_name;
{
    mxArray *tmp,*sub_tmp;
    pp_2D_format fit;

    tmp = mxGetField(structure_name, 0, field_name);  
    
    fit.n = mxGetData(mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,0)));
        
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,1));
    if (mxIsStruct(sub_tmp)) {
        fit.form_a0 = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_a0 = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_a0 = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_a0 = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_a0 = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_a0 = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_a0 = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,4));
    if (mxIsStruct(sub_tmp)) {
        fit.form_da0drho = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_da0drho = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_da0drho = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_da0drho = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_da0drho = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_da0drho = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_da0drho = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,2));
    if (mxIsStruct(sub_tmp)) {
        fit.form_an = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_an = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_an = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_an = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_an = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_an = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_an = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,5));
    if (mxIsStruct(sub_tmp)) {
        fit.form_dandrho = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dandrho = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dandrho = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dandrho = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dandrho = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dandrho = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dandrho = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,3));
    if (mxIsStruct(sub_tmp)) {
        fit.form_bn = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_bn = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_bn = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_bn = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_bn = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_bn = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_bn = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,6));
    if (mxIsStruct(sub_tmp)) {
        fit.form_dbndrho = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dbndrho = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dbndrho = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dbndrho = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dbndrho = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dbndrho = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dbndrho = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    return(fit);  
}


void ppval_1D(pp_1D_format in,double drho_lim,double x,double y[],double dydx[])
{
    register int j,k;
    int i0,i1,i2,i3;
 
    if (x>1.0 - drho_lim) {x = 1.0 - drho_lim/2.0;}//Avoid points outside the separatrix
    
    for (j = 0;j < (int)in.pieces_f[0];j++) {
        if ((x>=in.breaks_f[j]) && (x<=in.breaks_f[j+1])) {
            for (k = 1;k <= (int)in.dim_f[0]; k++) {
                if ((int)in.order_f[0] == 2) {
                    i0 = k-1+j*(int)in.dim_f[0] + 0*(int)in.pieces_f[0]*(int)in.dim_f[0];
                    i1 = k-1+j*(int)in.dim_f[0] + 1*(int)in.pieces_f[0]*(int)in.dim_f[0];
                    y[k-1] = in.coefs_f[i0]*(x - in.breaks_f[j]) + in.coefs_f[i1];
                } else if ((int)in.order_f[0] == 3) {
                    i0 = k-1+j*(int)in.dim_f[0] + 0*(int)in.pieces_f[0]*(int)in.dim_f[0];
                    i1 = k-1+j*(int)in.dim_f[0] + 1*(int)in.pieces_f[0]*(int)in.dim_f[0];
                    i2 = k-1+j*(int)in.dim_f[0] + 2*(int)in.pieces_f[0]*(int)in.dim_f[0];
                    y[k-1] = in.coefs_f[i0]*pow((x - in.breaks_f[j]),2) + in.coefs_f[i1]*(x - in.breaks_f[j]) + in.coefs_f[i2];
                } else if ((int)in.order_f[0] == 4) {
                    i0 = k-1+j*(int)in.dim_f[0] + 0*(int)in.pieces_f[0]*(int)in.dim_f[0];
                    i1 = k-1+j*(int)in.dim_f[0] + 1*(int)in.pieces_f[0]*(int)in.dim_f[0];
                    i2 = k-1+j*(int)in.dim_f[0] + 2*(int)in.pieces_f[0]*(int)in.dim_f[0];
                    i3 = k-1+j*(int)in.dim_f[0] + 3*(int)in.pieces_f[0]*(int)in.dim_f[0];                    
                    y[k-1] = in.coefs_f[i0]*pow((x - in.breaks_f[j]),3) + in.coefs_f[i1]*pow((x - in.breaks_f[j]),2) + in.coefs_f[i2]*(x - in.breaks_f[j]) + in.coefs_f[i3];
/*                    mexPrintf("kk,y: %d,%g\n",k,y[k-1]);  */
                }
            }
        }
    }   
    
    for (j = 0;j < (int)in.pieces_dfdrho[0];j++) {
        if ((x>=in.breaks_dfdrho[j]) && (x<=in.breaks_dfdrho[j+1])) {
            for (k = 1;k <= (int)in.dim_dfdrho[0]; k++) {
                if ((int)in.order_dfdrho[0] == 2) {
                    i0 = k-1+j*(int)in.dim_dfdrho[0] + 0*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    i1 = k-1+j*(int)in.dim_dfdrho[0] + 1*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    dydx[k-1] = in.coefs_dfdrho[i0]*(x - in.breaks_dfdrho[j]) + in.coefs_dfdrho[i1];
                } else if ((int)in.order_dfdrho[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dfdrho[0] + 0*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    i1 = k-1+j*(int)in.dim_dfdrho[0] + 1*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    i2 = k-1+j*(int)in.dim_dfdrho[0] + 2*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];                    
                    dydx[k-1] = in.coefs_dfdrho[i0]*pow((x - in.breaks_dfdrho[j]),2) + in.coefs_dfdrho[i1]*(x - in.breaks_dfdrho[j]) + in.coefs_dfdrho[i2];
/*                    mexPrintf("k,dydx: %d%g\n",k,dydx[k-1]);  */
                } else if ((int)in.order_dfdrho[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dfdrho[0] + 0*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    i1 = k-1+j*(int)in.dim_dfdrho[0] + 1*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    i2 = k-1+j*(int)in.dim_dfdrho[0] + 2*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    i3 = k-1+j*(int)in.dim_dfdrho[0] + 3*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    dydx[k-1] = in.coefs_dfdrho[i0]*pow((x - in.breaks_dfdrho[j]),3) + in.coefs_dfdrho[i1]*pow((x - in.breaks_dfdrho[j]),2) + in.coefs_dfdrho[i2]*(x - in.breaks_dfdrho[j]) + in.coefs_dfdrho[i3];
                }
            }
        }
    }   
}




void ppval_2D(pp_2D_format in,double drho_lim, double x, double t, double* y, double* dydx, double* dydt, double* d2ydt2, double* d2ydtdx)
{
    register int j,k;
    int i0,i1,i2,i3;
    double *a0,*an,*bn,*da0dx,*dandx,*dbndx;
    
    if (x>1.0 - drho_lim) {x = 1 - drho_lim/2.0;}//Avoid points outside the separatrix

    a0 = mxCalloc((int)in.dim_a0[0],sizeof(double));
    da0dx = mxCalloc((int)in.dim_da0drho[0],sizeof(double));
    an = mxCalloc((int)in.dim_an[0],sizeof(double));
    dandx = mxCalloc((int)in.dim_dandrho[0],sizeof(double));
    bn = mxCalloc((int)in.dim_bn[0],sizeof(double));
    dbndx = mxCalloc((int)in.dim_dbndrho[0],sizeof(double));

    for (j = 0;j < (int)in.pieces_a0[0];j++) {
        if ((x>=in.breaks_a0[j]) && (x<=in.breaks_a0[j+1])) {
            for (k = 1;k <= (int)in.dim_a0[0]; k++) {
                if ((int)in.order_a0[0] == 2) {
                    i0 = k-1+j*(int)in.dim_a0[0] + 0*(int)in.pieces_a0[0]*(int)in.dim_a0[0];
                    i1 = k-1+j*(int)in.dim_a0[0] + 1*(int)in.pieces_a0[0]*(int)in.dim_a0[0];
                    a0[k-1] = in.coefs_a0[i0]*(x - in.breaks_a0[j]) + in.coefs_a0[i1];
                } else if ((int)in.order_a0[0] == 3) {
                    i0 = k-1+j*(int)in.dim_a0[0] + 0*(int)in.pieces_a0[0]*(int)in.dim_a0[0];
                    i1 = k-1+j*(int)in.dim_a0[0] + 1*(int)in.pieces_a0[0]*(int)in.dim_a0[0];
                    i2 = k-1+j*(int)in.dim_a0[0] + 2*(int)in.pieces_a0[0]*(int)in.dim_a0[0];
                    a0[k-1] = in.coefs_a0[i0]*pow((x - in.breaks_a0[j]),2) + in.coefs_a0[i1]*(x - in.breaks_a0[j]) + in.coefs_a0[i2];
                } else if ((int)in.order_a0[0] == 4) {
                    i0 = k-1+j*(int)in.dim_a0[0] + 0*(int)in.pieces_a0[0]*(int)in.dim_a0[0];
                    i1 = k-1+j*(int)in.dim_a0[0] + 1*(int)in.pieces_a0[0]*(int)in.dim_a0[0];
                    i2 = k-1+j*(int)in.dim_a0[0] + 2*(int)in.pieces_a0[0]*(int)in.dim_a0[0];
                    i3 = k-1+j*(int)in.dim_a0[0] + 3*(int)in.pieces_a0[0]*(int)in.dim_a0[0];                    
                    a0[k-1] = in.coefs_a0[i0]*pow((x - in.breaks_a0[j]),3) + in.coefs_a0[i1]*pow((x - in.breaks_a0[j]),2) + in.coefs_a0[i2]*(x - in.breaks_a0[j]) + in.coefs_a0[i3]; 
                }
            }
        }
    }   
    
    for (j = 0;j < (int)in.pieces_da0drho[0];j++) {
        if ((x>=in.breaks_da0drho[j]) && (x<=in.breaks_da0drho[j+1])) {
            for (k = 1;k <= (int)in.dim_da0drho[0]; k++) {
                if ((int)in.order_da0drho[0] == 2) {
                    i0 = k-1+j*(int)in.dim_da0drho[0] + 0*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    i1 = k-1+j*(int)in.dim_da0drho[0] + 1*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    da0dx[k-1] = in.coefs_da0drho[i0]*(x - in.breaks_da0drho[j]) + in.coefs_da0drho[i1];
                } else if ((int)in.order_da0drho[0] == 3) {
                    i0 = k-1+j*(int)in.dim_da0drho[0] + 0*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    i1 = k-1+j*(int)in.dim_da0drho[0] + 1*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    i2 = k-1+j*(int)in.dim_da0drho[0] + 2*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];                    
                    da0dx[k-1] = in.coefs_da0drho[i0]*pow((x - in.breaks_da0drho[j]),2) + in.coefs_da0drho[i1]*(x - in.breaks_da0drho[j]) + in.coefs_da0drho[i2];
                } else if ((int)in.order_da0drho[0] == 4) {
                    i0 = k-1+j*(int)in.dim_da0drho[0] + 0*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    i1 = k-1+j*(int)in.dim_da0drho[0] + 1*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    i2 = k-1+j*(int)in.dim_da0drho[0] + 2*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    i3 = k-1+j*(int)in.dim_da0drho[0] + 3*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    da0dx[k-1] = in.coefs_da0drho[i0]*pow((x - in.breaks_da0drho[j]),3) + in.coefs_da0drho[i1]*pow((x - in.breaks_da0drho[j]),2) + in.coefs_da0drho[i2]*(x - in.breaks_da0drho[j]) + in.coefs_da0drho[i3];
                }
            }
        }
    }   

    for (j = 0;j < (int)in.pieces_an[0];j++) {
        if ((x>=in.breaks_an[j]) && (x<=in.breaks_an[j+1])) {
            for (k = 1;k <= (int)in.dim_an[0]; k++) {
                if ((int)in.order_an[0] == 2) {
                    i0 = k-1+j*(int)in.dim_an[0] + 0*(int)in.pieces_an[0]*(int)in.dim_an[0];
                    i1 = k-1+j*(int)in.dim_an[0] + 1*(int)in.pieces_an[0]*(int)in.dim_an[0];
                    an[k-1] = in.coefs_an[i0]*(x - in.breaks_an[j]) + in.coefs_an[i1];
                } else if ((int)in.order_an[0] == 3) {
                    i0 = k-1+j*(int)in.dim_an[0] + 0*(int)in.pieces_an[0]*(int)in.dim_an[0];
                    i1 = k-1+j*(int)in.dim_an[0] + 1*(int)in.pieces_an[0]*(int)in.dim_an[0];
                    i2 = k-1+j*(int)in.dim_an[0] + 2*(int)in.pieces_an[0]*(int)in.dim_an[0];
                    an[k-1] = in.coefs_an[i0]*pow((x - in.breaks_an[j]),2) + in.coefs_an[i1]*(x - in.breaks_an[j]) + in.coefs_an[i2];
                } else if ((int)in.order_an[0] == 4) {
                    i0 = k-1+j*(int)in.dim_an[0] + 0*(int)in.pieces_an[0]*(int)in.dim_an[0];
                    i1 = k-1+j*(int)in.dim_an[0] + 1*(int)in.pieces_an[0]*(int)in.dim_an[0];
                    i2 = k-1+j*(int)in.dim_an[0] + 2*(int)in.pieces_an[0]*(int)in.dim_an[0];
                    i3 = k-1+j*(int)in.dim_an[0] + 3*(int)in.pieces_an[0]*(int)in.dim_an[0];                    
                    an[k-1] = in.coefs_an[i0]*pow((x - in.breaks_an[j]),3) + in.coefs_an[i1]*pow((x - in.breaks_an[j]),2) + in.coefs_an[i2]*(x - in.breaks_an[j]) + in.coefs_an[i3];
                }
            }
        }
    }   
    
    for (j = 0;j < (int)in.pieces_dandrho[0];j++) {
        if ((x>=in.breaks_dandrho[j]) && (x<=in.breaks_dandrho[j+1])) {
            for (k = 1;k <= (int)in.dim_dandrho[0]; k++) {
                if ((int)in.order_dandrho[0] == 2) {
                    i0 = k-1+j*(int)in.dim_dandrho[0] + 0*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    i1 = k-1+j*(int)in.dim_dandrho[0] + 1*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    dandx[k-1] = in.coefs_dandrho[i0]*(x - in.breaks_dandrho[j]) + in.coefs_dandrho[i1];
                } else if ((int)in.order_dandrho[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dandrho[0] + 0*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    i1 = k-1+j*(int)in.dim_dandrho[0] + 1*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    i2 = k-1+j*(int)in.dim_dandrho[0] + 2*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];                    
                    dandx[k-1] = in.coefs_dandrho[i0]*pow((x - in.breaks_dandrho[j]),2) + in.coefs_dandrho[i1]*(x - in.breaks_dandrho[j]) + in.coefs_dandrho[i2];
                } else if ((int)in.order_dandrho[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dandrho[0] + 0*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    i1 = k-1+j*(int)in.dim_dandrho[0] + 1*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    i2 = k-1+j*(int)in.dim_dandrho[0] + 2*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    i3 = k-1+j*(int)in.dim_dandrho[0] + 3*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    dandx[k-1] = in.coefs_dandrho[i0]*pow((x - in.breaks_dandrho[j]),3) + in.coefs_dandrho[i1]*pow((x - in.breaks_dandrho[j]),2) + in.coefs_dandrho[i2]*(x - in.breaks_dandrho[j]) + in.coefs_dandrho[i3];
                }
            }
        }
    }   


    for (j = 0;j < (int)in.pieces_bn[0];j++) {
        if ((x>=in.breaks_bn[j]) && (x<=in.breaks_bn[j+1])) {
            for (k = 1;k <= (int)in.dim_bn[0]; k++) {
                if ((int)in.order_bn[0] == 2) {
                    i0 = k-1+j*(int)in.dim_bn[0] + 0*(int)in.pieces_bn[0]*(int)in.dim_bn[0];
                    i1 = k-1+j*(int)in.dim_bn[0] + 1*(int)in.pieces_bn[0]*(int)in.dim_bn[0];
                    bn[k-1] = in.coefs_bn[i0]*(x - in.breaks_bn[j]) + in.coefs_bn[i1];
                } else if ((int)in.order_bn[0] == 3) {
                    i0 = k-1+j*(int)in.dim_bn[0] + 0*(int)in.pieces_bn[0]*(int)in.dim_bn[0];
                    i1 = k-1+j*(int)in.dim_bn[0] + 1*(int)in.pieces_bn[0]*(int)in.dim_bn[0];
                    i2 = k-1+j*(int)in.dim_bn[0] + 2*(int)in.pieces_bn[0]*(int)in.dim_bn[0];
                    bn[k-1] = in.coefs_bn[i0]*pow((x - in.breaks_bn[j]),2) + in.coefs_bn[i1]*(x - in.breaks_bn[j]) + in.coefs_bn[i2];
                } else if ((int)in.order_bn[0] == 4) {
                    i0 = k-1+j*(int)in.dim_bn[0] + 0*(int)in.pieces_bn[0]*(int)in.dim_bn[0];
                    i1 = k-1+j*(int)in.dim_bn[0] + 1*(int)in.pieces_bn[0]*(int)in.dim_bn[0];
                    i2 = k-1+j*(int)in.dim_bn[0] + 2*(int)in.pieces_bn[0]*(int)in.dim_bn[0];
                    i3 = k-1+j*(int)in.dim_bn[0] + 3*(int)in.pieces_bn[0]*(int)in.dim_bn[0];                    
                    bn[k-1] = in.coefs_bn[i0]*pow((x - in.breaks_bn[j]),3) + in.coefs_bn[i1]*pow((x - in.breaks_bn[j]),2) + in.coefs_bn[i2]*(x - in.breaks_bn[j]) + in.coefs_bn[i3];
                }
            }
        }
    }   
    
    for (j = 0;j < (int)in.pieces_dbndrho[0];j++) {
        if ((x>=in.breaks_dbndrho[j]) && (x<=in.breaks_dbndrho[j+1])) {
            for (k = 1;k <= (int)in.dim_dbndrho[0]; k++) {
                if ((int)in.order_dbndrho[0] == 2) {
                    i0 = k-1+j*(int)in.dim_dbndrho[0] + 0*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    i1 = k-1+j*(int)in.dim_dbndrho[0] + 1*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    dbndx[k-1] = in.coefs_dbndrho[i0]*(x - in.breaks_dbndrho[j]) + in.coefs_dbndrho[i1];
                } else if ((int)in.order_dbndrho[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dbndrho[0] + 0*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    i1 = k-1+j*(int)in.dim_dbndrho[0] + 1*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    i2 = k-1+j*(int)in.dim_dbndrho[0] + 2*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];                    
                    dbndx[k-1] = in.coefs_dbndrho[i0]*pow((x - in.breaks_dbndrho[j]),2) + in.coefs_dbndrho[i1]*(x - in.breaks_dbndrho[j]) + in.coefs_dbndrho[i2];
                } else if ((int)in.order_dbndrho[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dbndrho[0] + 0*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    i1 = k-1+j*(int)in.dim_dbndrho[0] + 1*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    i2 = k-1+j*(int)in.dim_dbndrho[0] + 2*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    i3 = k-1+j*(int)in.dim_dbndrho[0] + 3*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    dbndx[k-1] = in.coefs_dbndrho[i0]*pow((x - in.breaks_dbndrho[j]),3) + in.coefs_dbndrho[i1]*pow((x - in.breaks_dbndrho[j]),2) + in.coefs_dbndrho[i2]*(x - in.breaks_dbndrho[j]) + in.coefs_dbndrho[i3];
                }
            }
        }
    }   
    
    y[0] = 0.0;
    dydx[0] = 0.0;
    dydt[0] = 0.0;
    d2ydt2[0] = 0.0;
    d2ydtdx[0] = 0.0;
    
    for (k = 1;k <= (int)in.dim_dbndrho[0]; k++) {
      y[0] = y[0] + an[k-1]*cos(k*t) + bn[k-1]*sin(k*t);
      dydx[0] = dydx[0] + dandx[k-1]*cos(k*t) + dbndx[k-1]*sin(k*t);
      dydt[0] = dydt[0] - k*an[k-1]*sin(k*t) + k*bn[k-1]*cos(k*t);
      d2ydt2[0] = d2ydt2[0] - k*k*an[k-1]*cos(k*t) - k*k*bn[k-1]*sin(k*t);
      d2ydtdx[0] = d2ydtdx[0] - k*dandx[k-1]*sin(k*t) + k*dbndx[k-1]*cos(k*t);
    }
    
    y[0] = y[0] + a0[0];
    dydx[0] = dydx[0] + da0dx[0];
    
    mxFree(a0);
    mxFree(da0dx);
    mxFree(an);
    mxFree(dandx);
    mxFree(bn);
    mxFree(dbndx);

}

double inf_norm(y,N)
double  y[];
unsigned int N;
{
    register unsigned int m;
    double  temp_max;

    temp_max = fabs(y[0]);

    for (m = 1; m < N; m++) {
        temp_max = fmax(temp_max,fabs(y[m]));
    }

    return(temp_max);
}

/* General coordinate time evolution dY/dt with Y=[rho,theta,phi,krho,m,n,omega/c] */


void ray(Ydot,Y,param,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit,flag)
double Y[];
double Ydot[];
rayparam_format param;
equilparam_format equilparam;
pp_1D_format Te_fit;
pp_1D_format ne_fit;
pp_1D_format zTi_fit;
pp_1D_format zni_fit;
pp_2D_format R_fit;
pp_2D_format Z_fit;
pp_2D_format BPHI_fit;
pp_2D_format BR_fit;
pp_2D_format BZ_fit;
pp_1D_format dRstardpsin_fit;
int flag;
{


double complex dDdx[43][M],Dtot,dDtotdx[M];

double Npar,dNpardx[M];
double complex Nperp,dNperpdx[M];
double complex N6,N2,dN2dx[M],dN6m1;

double complex Nperp4,Nperp3,Nperp2,Nperp1;
double Npar4,Npar3,Npar2,Npar1;
double complex Xxx,Xxy,Xxz,Xyy,Xyz,Xzz;
double complex Xxx2,Xxy2,Xxz2,Xyy2,Xyz2,Xzz2;

double rn2,drn2dx;

raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
susceptibilitytensor_format X;

register int i,j;

/* Memory allocation */

raymagnetic.rn = mxCalloc(1,sizeof(double));
raymagnetic.Rn = mxCalloc(1,sizeof(double));
raymagnetic.BPn = mxCalloc(1,sizeof(double));
raymagnetic.B = mxCalloc(1,sizeof(double));
raymagnetic.BPHIn = mxCalloc(1,sizeof(double));
raymagnetic.salpha = mxCalloc(1,sizeof(double));
raymagnetic.calpha = mxCalloc(1,sizeof(double));
raymagnetic.gradrhon = mxCalloc(1,sizeof(double));

raymagnetic.drndx = mxCalloc(M,sizeof(double));
raymagnetic.dRndx = mxCalloc(M,sizeof(double));
raymagnetic.dBPndx = mxCalloc(M,sizeof(double));
raymagnetic.dBPHIndx = mxCalloc(M,sizeof(double));
raymagnetic.dBdx = mxCalloc(M,sizeof(double));
raymagnetic.dsalphadx = mxCalloc(M,sizeof(double));
raymagnetic.dcalphadx = mxCalloc(M,sizeof(double));
raymagnetic.dgradrhondx = mxCalloc(M,sizeof(double));

for (i = 0;i < M; i++) {/*initialisation */
    raymagnetic.drndx[i] = 0.0;
    raymagnetic.dRndx[i] = 0.0;
    raymagnetic.dsalphadx[i] = 0.0;
    raymagnetic.dcalphadx[i] = 0.0;
    raymagnetic.dgradrhondx[i] = 0.0;
    raymagnetic.dBPndx[i] = 0.0;
    raymagnetic.dBPHIndx[i] = 0.0;
    raymagnetic.dBdx[i] = 0.0;
}

rayprofiles.Te = mxCalloc(1,sizeof(double));
rayprofiles.ne = mxCalloc(1,sizeof(double));
rayprofiles.zTi = mxCalloc(equilparam.ns[0],sizeof(double));
rayprofiles.zni = mxCalloc(equilparam.ns[0],sizeof(double));

rayprofiles.dTedx = mxCalloc(M,sizeof(double));
rayprofiles.dnedx = mxCalloc(M,sizeof(double));

rayprofiles.dzTidx = mxCalloc(equilparam.ns[0],sizeof(double *));
rayprofiles.dznidx = mxCalloc(equilparam.ns[0],sizeof(double *));
for (i = 0;i < equilparam.ns[0]; i++) {
    rayprofiles.dzTidx[i] = mxCalloc(M,sizeof(double));       
    rayprofiles.dznidx[i] = mxCalloc(M,sizeof(double));       
}    

for (i = 0;i < M; i++) {/*initialisation */
    rayprofiles.dTedx[i] = 0.0;
    rayprofiles.dnedx[i] = 0.0;
    
    for (j=0;j<equilparam.ns[0];j++) {
       rayprofiles.dzTidx[j][i] = 0.0;
       rayprofiles.dznidx[j][i] = 0.0;
    }
}

X.Xxx = mxCalloc(1,sizeof(double complex));
X.Xxy = mxCalloc(1,sizeof(double complex));
X.Xxz = mxCalloc(1,sizeof(double complex));
X.Xyy = mxCalloc(1,sizeof(double complex));
X.Xyz = mxCalloc(1,sizeof(double complex));
X.Xzz = mxCalloc(1,sizeof(double complex));

X.dXxxdx = mxCalloc(M,sizeof(double complex));
X.dXxydx = mxCalloc(M,sizeof(double complex));
X.dXxzdx = mxCalloc(M,sizeof(double complex));
X.dXyydx = mxCalloc(M,sizeof(double complex));
X.dXyzdx = mxCalloc(M,sizeof(double complex));
X.dXzzdx = mxCalloc(M,sizeof(double complex));

for (i=0;i<M;i++) {/*initialisation */
    X.dXxxdx[i] = 0.0;
    X.dXxydx[i] = 0.0;
    X.dXxzdx[i] = 0.0;
    X.dXyydx[i] = 0.0;
    X.dXyzdx[i] = 0.0;
    X.dXzzdx[i] = 0.0;
}

/* Equilibrium interpolation at ray location */
//interpequil(param,raymagnetic,rayprofiles,equilparam,Y,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit);
interpequil_test(raymagnetic,rayprofiles,equilparam,Y);


/* Refractive index calculation */
rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardx,dNperpdx,dN2dx);
//mexPrintf("r,R,BP,krho,sina,cosa,B,BPHI:%g,%g,%g,%g,%g,%g,%g,%g\n",raymagnetic.r[0],raymagnetic.R[0],raymagnetic.BP[0],Y[3],raymagnetic.salpha[0],raymagnetic.calpha[0],raymagnetic.B[0],raymagnetic.BPHI[0]);
//mexPrintf("Npar,w*dNpardw,Nperpr,Nperpi,w*dNperpdwr,w*dNperpdwi:%g,%g,%g,%g,%g,%g\n",Npar,dNpardx[6],Nperp,dNperpdx[6]);
 

/* Susceptibility tensor  */

susceptibility(X,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardx,Nperp,dNperpdx,Y[6]);

if (flag) {//dipersion relation
    disprel(&Dtot,X,raymagnetic,Npar,Nperp,N2);
}

/* Dispersion relation */
Nperp1 = Nperp;
Nperp2 = Nperp1*Nperp1;
Nperp3 = Nperp1*Nperp1*Nperp1;
Nperp4 = Nperp1*Nperp1*Nperp1*Nperp1;
Npar1 = Npar;
Npar2 = Npar1*Npar1;
Npar3 = Npar1*Npar1*Npar1;
Npar4 = Npar1*Npar1*Npar1*Npar1;

N6 = N2*N2*N2;

mexPrintf("N2,dN2dx[i],%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",N2,dN2dx[0],dN2dx[1],dN2dx[2],dN2dx[3],dN2dx[4],dN2dx[5],dN2dx[6],dN2dx[7]);

Xxx = X.Xxx[0];
Xxy = X.Xxy[0];
Xxz = X.Xxz[0];
Xyy = X.Xyy[0];
Xyz = X.Xyz[0];
Xzz = X.Xzz[0];
Xxx2 = X.Xxx[0]*X.Xxx[0];
Xxy2 = X.Xxy[0]*X.Xxy[0];
Xxz2 = X.Xxz[0]*X.Xxz[0];
Xyy2 = X.Xyy[0]*X.Xyy[0];
Xyz2 = X.Xyz[0]*X.Xyz[0];
Xzz2 = X.Xzz[0]*X.Xzz[0];

rn2 = raymagnetic.rn[0]*raymagnetic.rn[0];

for (i = 0;i<M;i++) {
    
    dN6m1 = 3*dN2dx[i]/N6/N2;
    drn2dx = 2.0*raymagnetic.drndx[i]*raymagnetic.rn[0];
    
    dDdx[0][i] = 4.0*rn2*Nperp3*dNperpdx[i]/N6 - rn2*Nperp4*dN6m1 + drn2dx*Nperp4/N6;
    dDdx[1][i] = X.dXxxdx[i]*Nperp4/N6 + 4.0*Xxx*Nperp3*dNperpdx[i]/N6 - Xxx*Nperp4*dN6m1;
    dDdx[2][i] = 2.0*dNpardx[i]*Xxz*Nperp3/N6 + 2.0*Npar1*X.dXxzdx[i]*Npar3/N6 + 6.0*Npar1*Xxz*dNperpdx[i]*Nperp2/N6 - 2.0*Npar1*Xxz*Nperp3*dN6m1;    
    dDdx[3][i] = 2.0*Npar1*dNpardx[i]*Xxx*Nperp2/N6 + Npar2*X.dXxxdx[i]*Nperp2/N6 + 2.0*Npar2*Xxx*Nperp1*dNperpdx[i]/N6 - Npar2*Xxx*Nperp2*dN6m1;
    dDdx[4][i] = 2.0*Npar1*dNpardx[i]*Xzz*Nperp2/N6 + Npar2*X.dXzzdx[i]*Nperp2/N6 + 2.0*Npar2*Xzz*Nperp1*dNperpdx[i]/N6 - Npar2*Xzz*Nperp2*dN6m1;
    dDdx[5][i] = 4.0*rn2*Npar1*dNpardx[i]*Nperp2/N6 + 4.0*rn2*Npar2*Nperp1*dNperpdx[i]/N6 - 2.0*rn2*Npar2*Nperp2*dN6m1 + 2.0*drn2dx*Npar2*Nperp2/N6;
    dDdx[6][i] = -2.0*rn2*X.dXxxdx[i]*Nperp2/N6 - 4.0*rn2*Xxx*Nperp1*dNperpdx[i]/N6 + 2.0*rn2*Xxx*Nperp2*dN6m1 - 2.0*drn2dx*Xxx*Nperp2/N6;
    dDdx[7][i] = -rn2*X.dXyydx[i]*Nperp2/N6 - 2.0*rn2*Xyy*Nperp1*dNperpdx[i]/N6 + rn2*Xyy*Nperp2*dN6m1 - Xyy*drn2dx*Nperp2/N6;
    dDdx[8][i] = -rn2*X.dXzzdx[i]*Nperp2/N6 - 2.0*rn2*Xzz*Nperp1*dNperpdx[i]/N6 + rn2*Xzz*Nperp2*dN6m1 - drn2dx*Xzz*Nperp2/N6;
    dDdx[9][i] = -X.dXxxdx[i]*Xzz*Nperp2/N6 - Xxx*X.dXzzdx[i]*Nperp2/N6 - 2.0*Xxx*Xzz*Nperp1*dNperpdx[i]/N6 + Xxx*Xzz*Nperp2*dN6m1;
    dDdx[10][i] = 2.0*Xxz*X.dXxzdx[i]*Nperp2/N6 + 2.0*Xxz2*Nperp1*dNperpdx[i]/N6 - Xxz2*Nperp2*dN6m1;
    dDdx[11][i] = -X.dXxxdx[i]*Xyy*Nperp2/N6 - Xxx*X.dXyydx[i]*Nperp2/N6 - 2.0*Xxx*Xyy*Nperp1*dNperpdx[i]/N6 + Xxx*Xyy*Nperp2*dN6m1;
    dDdx[12][i] = -2.0*X.dXxydx[i]*Xxy*Nperp2/N6 - 2.0*Xxy2*Nperp1*dNperpdx[i]/N6 + Xxy2*Nperp2*dN6m1;
    dDdx[13][i] = -4.0*rn2*rn2*Nperp1*dNperpdx[i]/N6 + 2.0*rn2*rn2*Nperp2*dN6m1 - 4.0*rn2*drn2dx*Nperp2/N6;
    dDdx[14][i] = -2.0*dNpardx[i]*Xyy*Xxz*Nperp1/N6 - 2.0*Npar1*X.dXyydx[i]*Xxz*Nperp1/N6 - 2.0*Npar1*Xyy*X.dXxzdx[i]*Nperp1/N6 - 2.0*Npar1*Xyy*Xxz*dNperpdx[i]/N6 + 2.0*Npar1*Xyy*Xxz*Nperp1*dN6m1;
    dDdx[15][i] = 2.0*dNpardx[i]*Xxy*Xyz*Nperp1/N6 + 2.0*Npar1*X.dXxydx[i]*Xyz*Nperp1/N6 + 2.0*Npar1*Xxy*X.dXyzdx[i]*Nperp1/N6 + 2.0*Npar1*Xxy*Xyz*dNperpdx[i]/N6 - 2.0*Npar1*Xxy*Xyz*Nperp1*dN6m1;
    dDdx[16][i] = -2.0*rn2*dNpardx[i]*Xxz*Nperp1/N6 - 2.0*rn2*Npar1*X.dXxzdx[i]*Nperp1/N6 - 2.0*rn2*Npar1*Xxz*dNperpdx[i]/N6 + 2.0*rn2*Npar1*Xxz*Nperp1*dN6m1 - 2.0*drn2dx*Npar1*Xxz*Nperp1/N6;
    dDdx[17][i] = 6.0*Npar2*dNpardx[i]*Xxz*Nperp1/N6 + 2.0*Npar3*X.dXxzdx[i]*Nperp1/N6 + 2.0*Npar3*Xxz*dNperpdx[i]/N6 - 2.0*Npar3*Xxz*Nperp1*dN6m1;
    dDdx[18][i] = -rn2*rn2*rn2*dN6m1 + 3.0*drn2dx*rn2*rn2/N6;
    dDdx[19][i] = 4.0*Npar3*Xzz*dNpardx[i]/N6 + Npar4*X.dXzzdx[i]/N6 - Npar4*Xzz*dN6m1;    
    dDdx[20][i] = 4.0*rn2*Npar3*dNpardx[i]/N6 - rn2*Npar4*dN6m1 + drn2dx*Npar4/N6;
    dDdx[21][i] = 2.0*Npar1*dNpardx[i]*Xxz2/N6 + 2.0*Npar2*Xxz*X.dXxzdx[i]/N6 - Npar2*Xxz2*dN6m1;
    dDdx[22][i] = -2.0*Npar1*dNpardx[i]*Xyy*Xzz/N6 - Npar2*X.dXyydx[i]*Xzz/N6 - Npar2*Xyy*X.dXzzdx[i]/N6 + Npar2*Xyy*Xzz*dN6m1;
    dDdx[23][i] = -2.0*Npar1*dNpardx[i]*Xxx*Xzz/N6 - Npar2*X.dXxxdx[i]*Xzz/N6 - Npar2*Xxx*X.dXzzdx[i]/N6 + Npar2*Xxx*Xzz*dN6m1;
    dDdx[24][i] = -4.0*rn2*Npar1*dNpardx[i]*Xzz/N6 - 2.0*rn2*Npar2*X.dXzzdx[i]/N6 + 2.0*rn2*Npar2*Xzz*dN6m1 - 2.0*drn2dx*Npar2*Xzz/N6;
    dDdx[25][i] = -2.0*rn2*Npar1*dNpardx[i]*Xyy/N6 - rn2*Npar2*X.dXyydx[i]/N6 + rn2*Npar2*Xyy*dN6m1 - drn2dx*Npar2*Xyy/N6;
    dDdx[26][i] = -2.0*Npar1*dNpardx[i]*Xyz2/N6 - 2.0*Npar2*Xyz*X.dXyzdx[i]/N6 + Npar2*Xyz2*dN6m1;
    dDdx[27][i] = -2.0*rn2*Npar1*dNpardx[i]*Xxx/N6 - rn2*Npar2*X.dXxxdx[i]/N6 + rn2*Npar2*Xxx*dN6m1 - drn2dx*Npar2*Xxx/N6;
    dDdx[28][i] = -4.0*rn2*rn2*Npar1*dNpardx[i]/N6 + 2.0*rn2*rn2*Npar2*dN6m1 - 4.0*drn2dx*rn2*Npar2/N6;
    dDdx[29][i] = rn2*X.dXyydx[i]*Xzz/N6 + rn2*Xyy*X.dXzzdx[i]/N6 - rn2*Xyy*Xzz*dN6m1 + drn2dx*Xyy*Xzz/N6;
    dDdx[30][i] = rn2*X.dXxxdx[i]*Xzz/N6 + rn2*Xxx*X.dXzzdx[i]/N6 - rn2*Xxx*Xzz*dN6m1 + drn2dx*Xxx*Xzz/N6;
    dDdx[31][i] = rn2*X.dXxxdx[i]*Xyy/N6 + rn2*Xxx*X.dXyydx[i]/N6 - rn2*Xxx*Xyy*dN6m1 + drn2dx*Xxx*Xyy/N6;
    dDdx[32][i] = X.dXxxdx[i]*Xyz2/N6 + 2.0*Xxx*Xyz*X.dXyzdx[i]/N6 - Xxx*Xyz2*dN6m1;
    dDdx[33][i] = 2.0*rn2*Xyz*X.dXyzdx[i]/N6 - rn2*Xyz2*dN6m1 + drn2dx*Xyz2/N6;
    dDdx[34][i] = rn2*rn2*X.dXxxdx[i]/N6 - rn2*rn2*Xxx*dN6m1 + 2.0*drn2dx*rn2*Xxx/N6;
    dDdx[35][i] = 2.0*rn2*Xxy*X.dXxydx[i]/N6 - rn2*Xxy2*dN6m1 + drn2dx*Xxy2/N6;
    dDdx[36][i] = 2.0*Xxy*X.dXxydx[i]*Xzz/N6 + Xxy2*X.dXzzdx[i]/N6 - Xxy2*Xzz*dN6m1;    
    dDdx[37][i] = -2.0*rn2*Xxz*X.dXxzdx[i]/N6 + rn2*Xxz2*dN6m1 - drn2dx*Xxz2/N6;
    dDdx[38][i] = -X.dXyydx[i]*Xxz2/N6 - 2.0*Xyy*Xxz*X.dXxzdx[i]/N6 + Xyy*Xxz2*dN6m1;
    dDdx[39][i] = rn2*rn2*X.dXyydx[i]/N6 - rn2*rn2*Xyy*dN6m1 + 2.0*drn2dx*rn2*Xyy/N6;
    dDdx[40][i] = rn2*rn2*X.dXzzdx[i]/N6 - rn2*rn2*Xzz*dN6m1 + 2.0*drn2dx*rn2*Xzz/N6;
    dDdx[41][i] = X.dXxxdx[i]*Xyy*Xzz/N6 + Xxx*X.dXyydx[i]*Xzz/N6 + Xxx*Xyy*X.dXzzdx[i]/N6 - Xxx*Xyy*Xzz*dN6m1;
    dDdx[42][i] = 2.0*X.dXxydx[i]*Xyz*Xxz/N6 + 2.0*Xxy*X.dXyzdx[i]*Xxz/N6 + 2.0*Xxy*Xyz*X.dXxzdx[i]/N6 - 2.0*Xxy*Xyz*Xxz*dN6m1;
}

for (i = 0;i<M;i++) {
    dDtotdx[i] = 0.0; 
}

for (i = 0;i<43;i++) {
    for (j=0;j<M;j++) {
        dDtotdx[j] = dDtotdx[j] + dDdx[i][j]; 
    }
}
Ydot[0] = -creal(dDtotdx[3])/creal(dDtotdx[6]); 
Ydot[1] = -creal(dDtotdx[4])/creal(dDtotdx[6]); 
Ydot[2] = -creal(dDtotdx[5])/creal(dDtotdx[6]); 
Ydot[3] = creal(dDtotdx[0])/creal(dDtotdx[6]); 
Ydot[4] = creal(dDtotdx[1])/creal(dDtotdx[6]);
Ydot[5] = 0.0; 
Ydot[6] = 0.0; 

/*
// test for the cold dispersion relation
double complex P0,P2,P4,dP0dx[M],dP2dx[M],dP4dx[M];
double complex Kpar,Kperp,Kxy,dKpardx[M],dKperpdx[M],dKxydx[M];
double complex Dot_cold,dDtot_colddx[M];
double Ydot_cold[M];

Kpar = (rn2 + Xzz)/N2;
Kperp = (rn2 + Xxx)/N2;
Kxy = I*Xxy/N2;

P0 = Kpar*((Npar2/N2 - Kperp)*(Npar2/N2 - Kperp) - Kxy*Kxy);
P2 = (Npar2/N2 - Kperp)*(Kpar + Kperp) + Kxy*Kxy;
P4 = Kperp;

Dot_cold = P4*Nperp4/N2/N2 + P2*Nperp2/N2 + P0;
mexPrintf("Dtot_cold:%g,%g\n",Dot_cold);

for (i=0;i<M;i++) {
 
    drn2dx = 2.0*raymagnetic.drndx[i]*raymagnetic.rn[0];

    dKpardx[i] = drn2dx/N2 + X.dXzzdx[i]/N2 - (rn2+Xzz)*dN2dx[i]/N2/N2;
    dKperpdx[i] = drn2dx/N2 + X.dXxxdx[i]/N2 - (rn2+Xxx)*dN2dx[i]/N2/N2;
    dKxydx[i] = I*X.dXxydx[i]/N2 - I*Xxy*dN2dx[i]/N2/N2;  
    dP0dx[i] = dKpardx[i]*((Npar2/N2 - Kperp)*(Npar2/N2 - Kperp) - Kxy*Kxy) + Kpar*(2*(Npar2/N2 - Kperp)*(2*Npar1*dNpardx[i]/N2 - Npar2*dN2dx[i]/N2/N2 - dKperpdx[i]) - 2*Kxy*dKxydx[i]);  
    dP2dx[i] = (2*Npar1*dNpardx[i]/N2 - Npar2*dN2dx[i]/N2/N2 - dKperpdx[i])*(Kpar + Kperp) + (Npar2/N2 - Kperp)*(dKpardx[i] + dKperpdx[i]) + 2*Kxy*dKxydx[i];
    dP4dx[i] = dKperpdx[i];
    dDtot_colddx[i] = dP4dx[i]*Nperp4/N2/N2 + dP2dx[i]*Nperp2/N2 + dP0dx[i] + P4*(4*Nperp3*dNperpdx[i]/N2/N2 - 2*Nperp4*dN2dx[i]/N2/N2/N2) + P2*(2*Nperp*dNperpdx[i]/N2 - Nperp2*dN2dx[i]/N2/N2);
}

Ydot_cold[0] = -creal(dDtot_colddx[3])/creal(dDtot_colddx[6]); 
Ydot_cold[1] = -creal(dDtot_colddx[4])/creal(dDtot_colddx[6]); 
Ydot_cold[2] = -creal(dDtot_colddx[5])/creal(dDtot_colddx[6]); 
Ydot_cold[3] = creal(dDtot_colddx[0])/creal(dDtot_colddx[6]); 
Ydot_cold[4] = creal(dDtot_colddx[1])/creal(dDtot_colddx[6]);
Ydot_cold[5] = 0.0; 
Ydot_cold[6] = 0.0; 
*/

//mexPrintf("dDtotdw:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",dDtotdx[0],dDtotdx[1],dDtotdx[2],dDtotdx[3],dDtotdx[4],dDtotdx[5],dDtotdx[6]);
//mexPrintf("dDtot_colddw:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",dDtot_colddx[0],dDtot_colddx[1],dDtot_colddx[2],dDtot_colddx[3],dDtot_colddx[4],dDtot_colddx[5],dDtot_colddx[6]);
//mexPrintf("Ydot:%g,%g,%g,%g,%g,%g,%g\n",Ydot[0],Ydot[1],Ydot[2],Ydot[3],Ydot[4],Ydot[5],Ydot[6]);
//mexPrintf("Ydot_cold:%g,%g,%g,%g,%g,%g,%g\n",Ydot_cold[0],Ydot_cold[1],Ydot_cold[2],Ydot_cold[3],Ydot_cold[4],Ydot_cold[5],Ydot_cold[6]);


/* Memory is released  */
    
    mxFree(raymagnetic.rn);
    mxFree(raymagnetic.Rn);
    mxFree(raymagnetic.BPn);
    mxFree(raymagnetic.BPHIn);
    mxFree(raymagnetic.B);
    mxFree(raymagnetic.salpha);
    mxFree(raymagnetic.calpha);
    mxFree(raymagnetic.gradrhon);
    
    mxFree(raymagnetic.drndx);
    mxFree(raymagnetic.dRndx);
    mxFree(raymagnetic.dBPndx);
    mxFree(raymagnetic.dBPHIndx);
    mxFree(raymagnetic.dBdx);   
    mxFree(raymagnetic.dsalphadx);
    mxFree(raymagnetic.dcalphadx);
    mxFree(raymagnetic.dgradrhondx);
    
    mxFree(rayprofiles.Te);
    mxFree(rayprofiles.ne);
    mxFree(rayprofiles.zTi);
    mxFree(rayprofiles.zni);

    mxFree(rayprofiles.dTedx);
    mxFree(rayprofiles.dnedx);
    
    for (i = 0;i < equilparam.ns[0]; i++) {
        mxFree(rayprofiles.dzTidx[i]);       
        mxFree(rayprofiles.dznidx[i]);       
    }    
    
    mxFree(rayprofiles.dzTidx);
    mxFree(rayprofiles.dznidx);

    mxFree(X.Xxx);
    mxFree(X.Xxy);
    mxFree(X.Xxz);
    mxFree(X.Xyy);
    mxFree(X.Xyz);
    mxFree(X.Xzz);

    mxFree(X.dXxxdx);
    mxFree(X.dXxydx);
    mxFree(X.dXxzdx);
    mxFree(X.dXyydx);
    mxFree(X.dXyzdx);
    mxFree(X.dXzzdx);

}

void dsolve(krho,Y,param,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit)
double *krho;
double Y[];
rayparam_format param;
equilparam_format equilparam;
pp_1D_format Te_fit;
pp_1D_format ne_fit;
pp_1D_format zTi_fit;
pp_1D_format zni_fit;
pp_2D_format R_fit;
pp_2D_format Z_fit;
pp_2D_format BR_fit;
pp_2D_format BZ_fit;
pp_2D_format BPHI_fit;
pp_1D_format dRstardpsin_fit;
{
    double Npar,dNpardx[M];
    double complex Nperp,dNperpdx[M];
    double complex N2,dN2dx[M];

    double frac,fracmax,exp,tol;
    double krho0,krho1,krho2,dkrho;
    double complex cD0,cD1;
    double D0,D1,D2;
    int maxit;

    raymagnetic_format raymagnetic;
    rayprofiles_format rayprofiles;
    susceptibilitytensor_format X;

    register int i,j;
    
    frac = 1 - 1e-4;
    fracmax = 2;
    exp = -1.5;
    tol = 1e-8;
    
    maxit = 50;

    /* Memory allocation */

    raymagnetic.rn = mxCalloc(1,sizeof(double));
    raymagnetic.Rn = mxCalloc(1,sizeof(double));
    raymagnetic.salpha = mxCalloc(1,sizeof(double));
    raymagnetic.calpha = mxCalloc(1,sizeof(double));
    raymagnetic.BPn = mxCalloc(1,sizeof(double));
    raymagnetic.BPHIn = mxCalloc(1,sizeof(double));
    raymagnetic.B = mxCalloc(1,sizeof(double));
    raymagnetic.gradrhon = mxCalloc(1,sizeof(double));

    raymagnetic.drndx = mxCalloc(M,sizeof(double));
    raymagnetic.dRndx = mxCalloc(M,sizeof(double));
    raymagnetic.dsalphadx = mxCalloc(M,sizeof(double));
    raymagnetic.dcalphadx = mxCalloc(M,sizeof(double));
    raymagnetic.dBPndx = mxCalloc(M,sizeof(double));
    raymagnetic.dBPHIndx = mxCalloc(M,sizeof(double));
    raymagnetic.dBdx = mxCalloc(M,sizeof(double));
    raymagnetic.dgradrhondx = mxCalloc(1,sizeof(double));

    for (i = 0;i < M; i++) {/* initialisation */
        raymagnetic.drndx[i] = 0.0;
        raymagnetic.dRndx[i] = 0.0;
        raymagnetic.dsalphadx[i] = 0.0;
        raymagnetic.dcalphadx[i] = 0.0;
        raymagnetic.dgradrhondx[i] = 0.0;
        raymagnetic.dBPndx[i] = 0.0;
        raymagnetic.dBPHIndx[i] = 0.0;
        raymagnetic.dBdx[i] = 0.0;
    }

    rayprofiles.Te = mxCalloc(1,sizeof(double));
    rayprofiles.ne = mxCalloc(1,sizeof(double));
    rayprofiles.zTi = mxCalloc(equilparam.ns[0],sizeof(double));
    rayprofiles.zni = mxCalloc(equilparam.ns[0],sizeof(double));

    rayprofiles.dTedx = mxCalloc(M,sizeof(double));
    rayprofiles.dnedx = mxCalloc(M,sizeof(double));

    rayprofiles.dzTidx = mxCalloc(equilparam.ns[0],sizeof(double *));
    rayprofiles.dznidx = mxCalloc(equilparam.ns[0],sizeof(double *));
    for (i = 0;i < equilparam.ns[0]; i++) {
        rayprofiles.dzTidx[i] = mxCalloc(M,sizeof(double));       
        rayprofiles.dznidx[i] = mxCalloc(M,sizeof(double));       
    }    

    for (i = 0;i < M; i++) {/*initialisation */
        rayprofiles.dTedx[i] = 0.0;
        rayprofiles.dnedx[i] = 0.0;
    }
    
    for (i=0;i<equilparam.ns[0];i++) {
        rayprofiles.zTi[i] = 0.0;
        rayprofiles.zni[i] = 0.0;             
        for (j = 0;j < M; j++) {
           rayprofiles.dzTidx[i][j] = 0.0;
           rayprofiles.dznidx[i][j] = 0.0;
        }
    }

    X.Xxx = mxCalloc(1,sizeof(double complex));
    X.Xxy = mxCalloc(1,sizeof(double complex));
    X.Xxz = mxCalloc(1,sizeof(double complex));
    X.Xyy = mxCalloc(1,sizeof(double complex));
    X.Xyz = mxCalloc(1,sizeof(double complex));
    X.Xzz = mxCalloc(1,sizeof(double complex));

    X.dXxxdx = mxCalloc(M,sizeof(double complex));
    X.dXxydx = mxCalloc(M,sizeof(double complex));
    X.dXxzdx = mxCalloc(M,sizeof(double complex));
    X.dXyydx = mxCalloc(M,sizeof(double complex));
    X.dXyzdx = mxCalloc(M,sizeof(double complex));
    X.dXzzdx = mxCalloc(M,sizeof(double complex));

    for (i=0;i<M;i++) {/*initialisation */
        X.dXxxdx[i] = 0.0;
        X.dXxydx[i] = 0.0;
        X.dXxzdx[i] = 0.0;
        X.dXyydx[i] = 0.0;
        X.dXyzdx[i] = 0.0;
        X.dXzzdx[i] = 0.0;
    }

    /* Equilibrium interpolation at ray location */
//    interpequil_test(raymagnetic,rayprofiles,equilparam,Y);
     interpequil(param,raymagnetic,rayprofiles,equilparam,Y,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit);

    krho0 = Y[3];
    krho1 = frac*krho0;
    
    rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardx,dNperpdx,dN2dx);
    susceptibility(X,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardx,Nperp,dNperpdx,Y[6]);
    disprel(&cD0,X,raymagnetic,Npar,Nperp);
    D0 = creal(cD0);/* to be changed if non-hermitian susceptibility tensors are used */
/*  mexPrintf("krho0,D0:%g,%g\n",krho0,D0); */
    
    Y[3] = krho1;
    rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardx,dNperpdx,dN2dx);
    susceptibility(X,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardx,Nperp,dNperpdx,Y[6]);
    disprel(&cD1,X,raymagnetic,Npar,Nperp,N2);
    D1 = creal(cD1);/* to be changed if non-hermitian susceptibility tensors are used */
/*  mexPrintf("krho1,D1:%g,%g\n",krho1,D1); */

    /* Search for root bounding interval */

    while ((D1*D0 > 0) && (fracmax < 100)){
        
        frac = pow(frac,exp);
        krho1 = frac*krho0;
       
        Y[3] = krho1;
        rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardx,dNperpdx,dN2dx);
        susceptibility(X,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardx,Nperp,dNperpdx,Y[6]);
        disprel(&cD1,X,raymagnetic,Npar,Nperp,N2);
        D1 = creal(cD1);/* to be changed if non-hermitian susceptibility tensors are used */
/*      mexPrintf("krho1,D1:%g,%g\n",krho1,D1); */
    }
    
    if (D1*D0 > 0) {
        krho[0] = krho0;  /* put error message */
    }
/*    else if (fabs(D0) < tol){
       krho[0] = krho0;
    }
    else if (fabs(D1) < tol){
        krho[0] = krho1;
    }        
*/
    else {
        if (fabs(D0) < fabs(D1)) { /*Closest root is set to latest value. */
            krho2 = krho0; 
            krho0 = krho1;
            krho1 = krho2;
            D2 = D0;
            D0 = D1;
            D1 = D2;
        }       
       
        j = 0;
        
/*        mexPrintf("fabs(D1),tol,j,maxit:%g,%g,%d,%d\n",fabs(D1),tol,j,maxit); */
         
        while ((fabs(D1) > tol) && (j < maxit)) { /*Secant loop. */
            
/*          mexPrintf("krho0,D0,krho1,D1,frac,tol:%g,%g,%g,%g,%g,%g\n",krho0,D0,krho1,D1,frac,tol); */
            
            dkrho = (krho0 - krho1)*D1/(D1-D0); /*Increment with respect to latest value. */
            krho0 = krho1;
            D0 = D1;
            krho1 += dkrho;

            Y[3] = krho1;
            rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardx,dNperpdx,dN2dx);
            susceptibility(X,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardx,Nperp,dNperpdx,Y[6]);
            disprel(&cD1,X,raymagnetic,Npar,Nperp,N2);
            D1 = creal(cD1);/* to be changed if non-hermitian susceptibility tensor are used */
/*          mexPrintf("krho1,D1:%g,%g\n",krho1,D1); */
        }
        
        if (fabs(D1) <= tol) { /*Convergence. */
            krho[0] = krho1;
        }
        else {
            krho[0] = krho2; /* put error message */
        }
    }    
    
    
    /* krho[0] = -Y[3]; //old method not accurate */

    /* Memory is released  */
    
    mxFree(raymagnetic.rn);
    mxFree(raymagnetic.Rn);
    mxFree(raymagnetic.salpha);
    mxFree(raymagnetic.calpha);
    mxFree(raymagnetic.BPn);
    mxFree(raymagnetic.BPHIn);
    mxFree(raymagnetic.B);
    mxFree(raymagnetic.gradrhon);

    mxFree(raymagnetic.drndx);
    mxFree(raymagnetic.dRndx);
    mxFree(raymagnetic.dsalphadx);
    mxFree(raymagnetic.dcalphadx);
    mxFree(raymagnetic.dBPndx);
    mxFree(raymagnetic.dBPHIndx);
    mxFree(raymagnetic.dBdx);  
    mxFree(raymagnetic.dgradrhondx);
    
    mxFree(rayprofiles.Te);
    mxFree(rayprofiles.ne);
    mxFree(rayprofiles.zTi);
    mxFree(rayprofiles.zni);

    mxFree(rayprofiles.dTedx);
    mxFree(rayprofiles.dnedx);
    
    for (i = 0;i < equilparam.ns[0]; i++) {
        mxFree(rayprofiles.dzTidx[i]);       
        mxFree(rayprofiles.dznidx[i]);       
    }    
    
    mxFree(rayprofiles.dzTidx);
    mxFree(rayprofiles.dznidx);

    mxFree(X.Xxx);
    mxFree(X.Xxy);
    mxFree(X.Xxz);
    mxFree(X.Xyy);
    mxFree(X.Xyz);
    mxFree(X.Xzz);

    mxFree(X.dXxxdx);
    mxFree(X.dXxydx);
    mxFree(X.dXxzdx);
    mxFree(X.dXyydx);
    mxFree(X.dXyzdx);
    mxFree(X.dXzzdx);
    
}

void disprel(Dtot,X,raymagnetic,Npar,Nperp,N2)
double complex *Dtot;
susceptibilitytensor_format X;
raymagnetic_format raymagnetic;
double Npar;
double complex Nperp,N2;

{
    double complex Nperp4,Nperp3,Nperp2,Nperp1;
    double Npar4,Npar3,Npar2,Npar1;
    double complex Xxx,Xxy,Xxz,Xyy,Xyz,Xzz;
    double complex Xxx2,Xxy2,Xxz2,Xyy2,Xyz2,Xzz2;

    double complex D[43],N6;
    
    double rn2;

    int i;

    Nperp1 = Nperp;
    Nperp2 = Nperp1*Nperp1;    
    Nperp3 = Nperp1*Nperp1*Nperp1;    
    Nperp4 = Nperp1*Nperp1*Nperp1*Nperp1;
    Npar1 = Npar;
    Npar2 = Npar1*Npar1;
    Npar3 = Npar1*Npar1*Npar1;
    Npar4 = Npar1*Npar1*Npar1*Npar1;
    
    N6 = N2*N2*N2;

    Xxx = X.Xxx[0];
    Xxy = X.Xxy[0];
    Xxz = X.Xxz[0];
    Xyy = X.Xyy[0];
    Xyz = X.Xyz[0];
    Xzz = X.Xzz[0];
    Xxx2 = X.Xxx[0]*X.Xxx[0];
    Xxy2 = X.Xxy[0]*X.Xxy[0];
    Xxz2 = X.Xxz[0]*X.Xxz[0];
    Xyy2 = X.Xyy[0]*X.Xyy[0];
    Xyz2 = X.Xyz[0]*X.Xyz[0];
    Xzz2 = X.Xzz[0]*X.Xzz[0];
    
    rn2 = raymagnetic.rn[0]*raymagnetic.rn[0];

/*
    mexPrintf("Nperp4r,Nperp4i:%g,%g\n",creal(Nperp4),cimag(Nperp4));
    mexPrintf("Npar:%g\n",Npar1);
    mexPrintf("Nperpr,Nperpi:%g,%g\n",creal(Nperp1),cimag(Nperp1));
    mexPrintf("Xxxr,XXxxi:%g,%g\n",creal(Xxx),cimag(Xxx));
    mexPrintf("Xxyr,XXxyi:%g,%g\n",creal(Xxy),cimag(Xxy));
    mexPrintf("Xxzr,XXxzi:%g,%g\n",creal(Xxz),cimag(Xxz));
    mexPrintf("Xyyr,XXyyi:%g,%g\n",creal(Xyy),cimag(Xyy));
    mexPrintf("Xyzr,XXyzi:%g,%g\n",creal(Xyz),cimag(Xyz));
    mexPrintf("Xzzr,XXzzi:%g,%g\n",creal(Xzz),cimag(Xzz));

    double complex Dtot1;
    Dtot1 = (Xxx+rn2)*Nperp4/N6+2*Npar1*Xxz*Nperp3/N6-(-2*rn2*Npar2+Xyy*rn2-Npar2*Xzz+Xxy2+rn2*Xzz-Xxz2+Xxx*Xzz+Xxx*Xyy+2*rn2*rn2+2*Xxx*rn2-Xxx*Npar2)*Nperp2/N6-(2*Npar1*rn2*Xxz+2*Npar1*Xyy*Xxz-2*Xxy*Xyz*Npar-2*Npar3*Xxz)*Nperp1/N6-(-rn2*rn2*rn2-Xxx*Xyz2-Xxy2*Xzz+Xyy*Xxz2-2*Xxy*Xyz*Xxz-Xxx*Xyy*Xzz-rn2*rn2*Xzz+2*rn2*rn2*Npar2-rn2*rn2*Xyy-rn2*Xyz2-Npar4*rn2-Xxx*rn2*rn2-Xxy2*rn2+rn2*Xxz2+2*rn2*Npar2*Xzz-rn2*Xyy*Xzz+Npar2*Xyy*rn2-Xxx*rn2*Xzz+Xxx*rn2*Npar2-Xxx*Xyy*rn2-Npar4*Xzz+Npar2*Xyz2-Npar2*Xxz2+Npar2*Xyy*Xzz+Xxx*Npar2*Xzz)/N6;   
    mexPrintf("Dtot1:%g\n",Dtot1);*/

    D[0] = rn2*Nperp4/N6;
    D[1] = Xxx*Nperp4/N6;
    D[2] = 2.0*Npar1*Xxz*Nperp3/N6;
    D[3] = Npar2*Xxx*Nperp2/N6;
    D[4] = Npar2*Xzz*Nperp2/N6;
    D[5] = 2.0*rn2*Npar2*Nperp2/N6;
    D[6] = -2.0*rn2*Xxx*Nperp2/N6;
    D[7] = -Xyy*rn2*Nperp2/N6;
    D[8] = -rn2*Xzz*Nperp2/N6;
    D[9] = -Xxx*Xzz*Nperp2/N6;
    D[10] = Xxz2*Nperp2/N6;
    D[11] = -Xxx*Xyy*Nperp2/N6;
    D[12] = -Xxy2*Nperp2/N6;
    D[13] = -2.0*rn2*rn2*Nperp2/N6;    
    D[14] = -2.0*Npar1*Xyy*Xxz*Nperp1/N6;
    D[15] = 2.0*Npar1*Xxy*Xyz*Nperp1/N6;
    D[16] = -2.0*rn2*Npar1*Xxz*Nperp1/N6;
    D[17] = 2.0*Npar3*Xxz*Nperp1/N6;
    D[18] = rn2*rn2*rn2/N6;
    D[19] = Npar4*Xzz/N6;
    D[20] = rn2*Npar4/N6;
    D[21] = Npar2*Xxz2/N6;
    D[22] = -Npar2*Xyy*Xzz/N6;
    D[23] = -Npar2*Xxx*Xzz/N6;
    D[24] = -2.0*rn2*Npar2*Xzz/N6;
    D[25] = -rn2*Npar2*Xyy/N6;
    D[26] = -Npar2*Xyz2/N6;
    D[27] = -rn2*Npar2*Xxx/N6;
    D[28] = -2.0*rn2*rn2*Npar2/N6;
    D[29] = rn2*Xyy*Xzz/N6;
    D[30] = rn2*Xxx*Xzz/N6;
    D[31] = rn2*Xxx*Xyy/N6;
    D[32] = Xxx*Xyz2/N6;
    D[33] = rn2*Xyz2/N6;
    D[34] = rn2*rn2*Xxx/N6;
    D[35] = rn2*Xxy2/N6;
    D[36] = Xxy2*Xzz/N6;
    D[37] = -rn2*Xxz2/N6;
    D[38] = -Xyy*Xxz2/N6;
    D[39] = rn2*rn2*Xyy/N6;
    D[40] = rn2*rn2*Xzz/N6;
    D[41] = Xxx*Xyy*Xzz/N6;
    D[42] = 2.0*Xxy*Xyz*Xxz/N6;

/*     for (i = 0;i<43;i++) {
        mexPrintf("i,Dr,Di:%d,%g\n",i,creal(D[i]),cimag(D[i]));
    }*/

    Dtot[0] = 0.0;
    for (i = 0;i<43;i++) {
        Dtot[0] = Dtot[0] + D[i];
    }

    mexPrintf("Dtot:%g\n",Dtot[0]);

}

void susceptibility(X,tensortype,ncyclharm,equilparam,raymagnetic,rayprofiles,Npar,dNpardx,Nperp,dNperpdx,omega)
susceptibilitytensor_format X;
double tensortype,omega;
int ncyclharm;
double Npar,dNpardx[];
double complex Nperp,dNperpdx[];

raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
equilparam_format equilparam;
{
    double qe = 1.602176462e-19;/*Absolute value of the electron charge (C) */
    double me = 9.10938188e-31;/*Electron rest mass (Kg) */
    double mp = 1.67262158e-27;/*Proton rest mass (Kg) */
    double epsi0 = 8.854187818e-12;/*Free space permittivity (F/m) */
    double mu0 = 12.566370614e-7;/*Free space permeability (F/m) */
    double mc2 = 510.998902;/*Electron energy rest mass (keV) */

    double wcn[equilparam.ns[0]+1],wpn2[equilparam.ns[0]+1],betath[equilparam.ns[0]+1];
    double dwcndx[equilparam.ns[0]+1][M],dwpn2dx[equilparam.ns[0]+1][M],dbetathdx[equilparam.ns[0]+1][M];

    int i,j,is;
    
    if (equilparam.zZi[0] > 0) {
    
        for (i = 0;i < equilparam.ns[0] + 1; i++) {/*initialisation */
            wcn[i] = 0.0;
            wpn2[i] = 0.0;
            betath[i] = 0.0;
            for (j=0;j<M;j++) {
                dwcndx[i][j] = 0.0;
                dwpn2dx[i][j] = 0.0;
                dbetathdx[i][j] = 0.0;
            }
        }
    
        /* Normalized parameters */

        wcn[0] = -qe*raymagnetic.B[0]/me/omega;/*electrons */
        dwcndx[0][0] = -qe*raymagnetic.dBdx[0]/me/omega;
        dwcndx[0][1] = -qe*raymagnetic.dBdx[1]/me/omega;
        dwcndx[0][6] = -wcn[0];

        wpn2[0] = qe*qe*rayprofiles.ne[0]/epsi0/me/omega/omega;/*electrons */
        dwpn2dx[0][0] = qe*qe*rayprofiles.dnedx[0]/epsi0/me/omega/omega;
        dwpn2dx[0][6] = -2.0*wpn2[0];

        betath[0] = sqrt(rayprofiles.Te[0]/mc2);
        dbetathdx[0][0] = rayprofiles.dTedx[0]/betath[0]/2.0;

        for (is = 1;is < equilparam.ns[0]+1; is++) {
            if (rayprofiles.zni[is-1] > 0.0) {//only when ion density is positive
                wcn[is] = qe*equilparam.zZi[is-1]*raymagnetic.B[0]/equilparam.zmi[is-1]/mp/omega;/*ions */
                dwcndx[is][0] = qe*equilparam.zZi[is-1]*raymagnetic.dBdx[0]/equilparam.zmi[is-1]/mp/omega;
                dwcndx[is][1] = qe*equilparam.zZi[is-1]*raymagnetic.dBdx[1]/equilparam.zmi[is-1]/mp/omega; 
                dwcndx[is][6] = -wcn[is]; 

                wpn2[is] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*rayprofiles.zni[is-1]/epsi0/equilparam.zmi[is-1]/mp/omega/omega;/*ions */
                dwpn2dx[is][0] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*rayprofiles.dznidx[is-1][0]/epsi0/equilparam.zmi[is-1]/mp/omega/omega;        
                dwpn2dx[is][6] = -2.0*wpn2[is]; 

                betath[is] = sqrt(rayprofiles.zTi[is-1]*me/equilparam.zmi[is-1]/mp/mc2);
                dbetathdx[is][0] = rayprofiles.dzTidx[is-1][0]/betath[is]/2.0;
            }
        }
        
        if (tensortype == 0) {
/*        mexPrintf("Cold dielectric tensor\n"); */
            coldtensor(X,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx);
        }
        if (tensortype == 1) {
/*        mexPrintf("Warm dielectric tensor\n");
            warmtensor(X,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx); */
        }
        if (tensortype == 2) {
/*        mexPrintf("Hot dielectric tensor\n");*/
            hottensor(X,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx); 
        }
        if (tensortype == 3) {
/*        mexPrintf("Weak relativistic dielectric tensor\n");
            weakrelativistictensor(X,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx); */
        }       
        if (tensortype == 4) {
/*        mexPrintf("Full relativistic dielectric tensor\n");
            fullrelativistictensor(X,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx); */
        }       
        
    } else {
        vacuumtensor(X);
    }

} 


void rayindex(mode,Y,raymagnetic,equilparam,Npar,Nperp,N2,dNpardx,dNperpdx,dN2dx)
int mode;
double Y[];
double *Npar,*dNpardx;
double complex *Nperp,*dNperpdx;
double complex *N2,*dN2dx;
raymagnetic_format raymagnetic;
equilparam_format equilparam;
{ 
    double dYdY[M][M];

    double Npar1,dNpar1dx,dNpar1dx1,dNpar1dx2,dNpar1dx3,dNpar1dx4;
    double Npar2,dNpar2dx,dNpar2dx1,dNpar2dx2,dNpar2dx3,dNpar2dx4,dNpar2dx5;
      
    double complex N21,dN21dx,dN21dx1,dN21dx2,dN21dx3,dN21dx4;
    double complex N22,dN22dx,dN22dx1,dN22dx2,dN22dx3,dN22dx4,dN22dx5,dN22dx6;
    double complex N23,dN23dx,dN23dx1,dN23dx2;
    double complex N24,dN24dx,dN24dx1,dN24dx2,dN24dx3,dN24dx4;
    
    double ap,cnorm;
    double clum = 299792458;/*Speed of light (m/s) */

    register int i,j;
    
    /*Covariant matrix */

    for (i=0;i<M;i++) {
        for (j=0;j<M;j++) {
            if ((i==j) && (i<7)) {
                dYdY[i][j] = 1.0;
            } else {
                dYdY[i][j] = 0.0;
            }
        }
    }

    
    for (i=0;i<M;i++) {/*initialisation */
        dNpardx[i] = 0.0;
        dNperpdx[i] = 0.0;
        dN2dx[i] = 0.0;
    }
    
    ap = equilparam.ap[0];
    cnorm = clum/ap/Y[6];
    
    if (mode == 1) {// 
    
        Npar1 = Y[4]*raymagnetic.calpha[0]*raymagnetic.BPn[0];
        Npar2 = raymagnetic.rn[0]*Y[5]*raymagnetic.BPHIn[0]/raymagnetic.Rn[0];
  
        Npar[0] = cnorm*(Npar1 + Npar2);
        
//        mexPrintf("Nparth:%g\n",Npar[0]/raymagnetic.rn[0]);
//        mexPrintf("Y[0],Y[1],Y[2],Y[3],Y[4],Y[5]:%g,%g,%g,%g,%g,%g\n",Y[0],Y[1],Y[2],Y[3],Y[4],Y[5]);
//        mexPrintf("Y[4],raymagnetic.calpha[0],raymagnetic.BPn[0],raymagnetic.rn[0],Y[5],raymagnetic.BPHIn[0],raymagnetic.Rn[0]:%g,%g,%g,%g,%g,%g,%g\n",Y[4],raymagnetic.calpha[0],raymagnetic.BPn[0],raymagnetic.rn[0],Y[5],raymagnetic.BPHIn[0],raymagnetic.Rn[0]);
    
        for (i=0;i<M;i++) {
    
            dNpar1dx1 = dYdY[4][i]*raymagnetic.calpha[0]*raymagnetic.BPn[0];
            dNpar1dx2 = Y[4]*raymagnetic.dcalphadx[i]*raymagnetic.BPn[0];
            dNpar1dx3 = Y[4]*raymagnetic.calpha[0]*raymagnetic.dBPndx[i];
            dNpar1dx4 = -Y[4]*raymagnetic.calpha[0]*raymagnetic.BPn[0]*dYdY[6][i];
        
            dNpar1dx = dNpar1dx1 + dNpar1dx2 + dNpar1dx3 + dNpar1dx4;
 
            dNpar2dx1 = raymagnetic.rn[0]*dYdY[5][i]*raymagnetic.BPHIn[0]/raymagnetic.Rn[0];
            dNpar2dx2 = raymagnetic.drndx[i]*Y[5]*raymagnetic.BPHIn[0]/raymagnetic.Rn[0];
            dNpar2dx3 = raymagnetic.rn[0]*Y[5]*raymagnetic.dBPHIndx[i]/raymagnetic.Rn[0];
            dNpar2dx4 = -raymagnetic.rn[0]*Y[5]*raymagnetic.BPHIn[0]*raymagnetic.dRndx[i]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dNpar2dx5 = -raymagnetic.rn[0]*Y[5]*raymagnetic.BPHIn[0]*dYdY[6][i]/raymagnetic.Rn[0];
    
            dNpar2dx = dNpar2dx1 + dNpar2dx2 + dNpar2dx3 + dNpar2dx4 + dNpar2dx5;
        
            dNpardx[i] = cnorm*(dNpar1dx + dNpar2dx);
             
          //  mexPrintf("i,dNpardx[i]:%d,%g\n",i,dNpardx[i]);
          //  mexPrintf("i,dYdY[3][i],dYdY[4][i],dYdY[5][i]:%d,%g,%g,%g\n",i,dYdY[3][i],dYdY[4][i],dYdY[4][i]); 
        }
    
        N21 = raymagnetic.rn[0]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.gradrhon[0]*Y[3]*Y[3];
        N22 = -2.0*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*Y[3];
        N23 = Y[4]*Y[4];
        N24 = Y[5]*Y[5]*raymagnetic.rn[0]*raymagnetic.rn[0]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
    
        N2[0] = cnorm*cnorm*(N21 + N22 + N23 + N24);
        Nperp[0] = sqrt(N2[0] - Npar[0]*Npar[0]);
        
        mexPrintf("Npar,Nperp,N2:%g,%g,%g,%g,%g\n",Npar[0]/raymagnetic.rn[0],Nperp[0]/raymagnetic.rn[0],N2[0]/raymagnetic.rn[0]/raymagnetic.rn[0]); 
        
        for (i=0;i<M;i++) {
        
            dN21dx1 = 2.0*raymagnetic.rn[0]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.dgradrhondx[i]*Y[3]*Y[3];
            dN21dx2 = 2.0*raymagnetic.rn[0]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.gradrhon[0]*dYdY[3][i]*Y[3];
            dN21dx3 = 2.0*raymagnetic.drndx[i]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.gradrhon[0]*Y[3]*Y[3];
            dN21dx4 = -2.0*raymagnetic.rn[0]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.gradrhon[0]*Y[3]*Y[3]*dYdY[6][i];
        
            dN21dx = dN21dx1 + dN21dx2 + dN21dx3 + dN21dx4;
        
            dN22dx1 = -2.0*raymagnetic.rn[0]*raymagnetic.dgradrhondx[i]*raymagnetic.salpha[0]*Y[4]*Y[3];
            dN22dx2 = -2.0*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.dsalphadx[i]*Y[4]*Y[3];
            dN22dx3 = -2.0*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*dYdY[4][i]*Y[3];
            dN22dx4 = -2.0*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*dYdY[3][i];
            dN22dx5 = -2.0*raymagnetic.drndx[i]*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*Y[3];
            dN22dx6 = 4.0*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*Y[3]*dYdY[6][i];
        
            dN22dx = dN22dx1 + dN22dx2 + dN22dx3 + dN22dx4 + dN22dx5 + dN22dx6;
     
            dN23dx1 = 2.0*dYdY[4][i]*Y[4];
            dN23dx2 = -2.0*Y[4]*Y[4]*dYdY[6][i];
        
            dN23dx = dN23dx1 + dN23dx2;
    
            dN24dx1 = 2.0*dYdY[5][i]*Y[5]*raymagnetic.rn[0]*raymagnetic.rn[0]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dN24dx2 = -2.0*Y[5]*Y[5]*raymagnetic.rn[0]*raymagnetic.rn[0]*raymagnetic.dRndx[i]/raymagnetic.Rn[0]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dN24dx4 = 2.0*Y[5]*Y[5]*raymagnetic.drndx[i]*raymagnetic.rn[0]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dN24dx3 = -2.0*Y[5]*Y[5]*raymagnetic.rn[0]*raymagnetic.rn[0]/raymagnetic.Rn[0]/raymagnetic.Rn[0]*dYdY[6][i];
        
            dN24dx = 0.0*(dN24dx1 + dN24dx2 + dN24dx3 + dN24dx4);
        
            dN2dx[i] = cnorm*cnorm*(dN21dx + dN22dx + dN23dx + dN24dx);

            dNperpdx[i] = (dN2dx[i] - 2.0*Npar[0]*dNpardx[i])/Nperp[0]/2.0;
   

        }
        
        
        
         mexPrintf("dN2dx[]:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",dN2dx[0],dN2dx[1],dN2dx[2],dN2dx[3],dN2dx[4],dN2dx[5],dN2dx[6],dN2dx[7]); 
        mexPrintf("r,2*r*drdx[]:%g,%g,%g,%g,%g,%g,%g,%g,%g\n",raymagnetic.rn[0],2.0*raymagnetic.rn[0]*raymagnetic.drndx[0],2.0*raymagnetic.rn[0]*raymagnetic.drndx[1],2.0*raymagnetic.rn[0]*raymagnetic.drndx[2],2.0*raymagnetic.rn[0]*raymagnetic.drndx[3],2.0*raymagnetic.rn[0]*raymagnetic.drndx[4],2.0*raymagnetic.rn[0]*raymagnetic.drndx[5],2.0*raymagnetic.rn[0]*raymagnetic.drndx[6],2.0*raymagnetic.rn[0]*raymagnetic.drndx[7],2.0*raymagnetic.rn[0]*raymagnetic.drndx[8]); 

    } else {
        
        
        
        
        
    }
    
}

void coldtensor(X,ns,ncyclharm,raymagnetic,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx)
susceptibilitytensor_format X;
int ns;
int ncyclharm;
raymagnetic_format raymagnetic;
double wcn[],wpn2[],betath[];
double dwcndx[][M],dwpn2dx[][M],dbetathdx[][M];
double Npar,dNpardx[];
double complex Nperp,dNperpdx[];
{ 
    double complex Xxx[ns+1],Xxy[ns+1],Xxz[ns+1],Xyy[ns+1],Xyz[ns+1],Xzz[ns+1];
    double complex dXxxdNperp[ns+1],dXxydNperp[ns+1],dXxzdNperp[ns+1],dXyydNperp[ns+1],dXyzdNperp[ns+1],dXzzdNperp[ns+1];
    double complex dXxxdNpar[ns+1],dXxydNpar[ns+1],dXxzdNpar[ns+1],dXyydNpar[ns+1],dXyzdNpar[ns+1],dXzzdNpar[ns+1];
    double complex dXxxdbetath[ns+1],dXxydbetath[ns+1],dXxzdbetath[ns+1],dXyydbetath[ns+1],dXyzdbetath[ns+1],dXzzdbetath[ns+1];
    double complex dXxxdwcn[ns+1],dXxydwcn[ns+1],dXxzdwcn[ns+1],dXyydwcn[ns+1],dXyzdwcn[ns+1],dXzzdwcn[ns+1];
    double complex dXxxdwpn2[ns+1],dXxydwpn2[ns+1],dXxzdwpn2[ns+1],dXyydwpn2[ns+1],dXyzdwpn2[ns+1],dXzzdwpn2[ns+1];
    
    int is,i;
    
        
    for (is = 0;is < ns + 1;is++) {
        
/* Dielectric tensor */
        
        Xxx[is] = - wpn2[is]/(1 - wcn[is]*wcn[is]);
        Xxy[is] = + wpn2[is]*wcn[is]*I/(1 - wcn[is]*wcn[is]);
        Xxz[is] = 0.0;
        Xyy[is] = - wpn2[is]/(1 - wcn[is]*wcn[is]);
        Xyz[is] = 0.0;
        Xzz[is] = - wpn2[is];

/* derivatives of the dielectric tensor */
        
        dXxxdNperp[is] = 0.0;
        dXxydNperp[is] = 0.0;
        dXxzdNperp[is] = 0.0;
        dXyydNperp[is] = 0.0;
        dXyzdNperp[is] = 0.0;
        dXzzdNperp[is] = 0.0;

        dXxxdNpar[is] = 0.0;
        dXxydNpar[is] = 0.0;
        dXxzdNpar[is] = 0.0;
        dXyydNpar[is] = 0.0;
        dXyzdNpar[is] = 0.0;
        dXzzdNpar[is] = 0.0;

        dXxxdbetath[is] = 0.0;
        dXxydbetath[is] = 0.0;
        dXxzdbetath[is] = 0.0;
        dXyydbetath[is] = 0.0;
        dXyzdbetath[is] = 0.0;
        dXzzdbetath[is] = 0.0;

        dXxxdwcn[is] = -2.0*wpn2[is]*wcn[is]/(1 - wcn[is]*wcn[is])/(1 - wcn[is]*wcn[is]);
        dXxydwcn[is] = +(2.0*wpn2[is]*wcn[is]*wcn[is]/(1 - wcn[is]*wcn[is])/(1 - wcn[is]*wcn[is]) + wpn2[is]/(1 - wcn[is]*wcn[is]))*I;
        dXxzdwcn[is] = 0.0;
        dXyydwcn[is] = -2.0*wpn2[is]*wcn[is]/(1 - wcn[is]*wcn[is])/(1 - wcn[is]*wcn[is]);
        dXyzdwcn[is] = 0.0;
        dXzzdwcn[is] = 0.0;    

        dXxxdwpn2[is] = -1.0/(1 - wcn[is]*wcn[is]);
        dXxydwpn2[is] = +wcn[is]*I/(1 - wcn[is]*wcn[is]);
        dXxzdwpn2[is] = 0.0;
        dXyydwpn2[is] = -1.0/(1 - wcn[is]*wcn[is]);
        dXyzdwpn2[is] = 0.0;
        dXzzdwpn2[is] = -1.0;    
        
    }
     
    buildXstruc(X,ns,raymagnetic,dNpardx,dNperpdx,dwcndx,dwpn2dx,dbetathdx,Xxx,Xxy,Xxz,Xyy,Xyz,Xzz,dXxxdNperp,dXxydNperp,dXxzdNperp,dXyydNperp,dXyzdNperp,dXzzdNperp,dXxxdNpar,dXxydNpar,dXxzdNpar,dXyydNpar,dXyzdNpar,dXzzdNpar,dXxxdbetath,dXxydbetath,dXxzdbetath,dXyydbetath,dXyzdbetath,dXzzdbetath,dXxxdwcn,dXxydwcn,dXxzdwcn,dXyydwcn,dXyzdwcn,dXzzdwcn,dXxxdwpn2,dXxydwpn2,dXxzdwpn2,dXyydwpn2,dXyzdwpn2,dXzzdwpn2);
} 


void vacuumtensor(X)
susceptibilitytensor_format X;
{ 
    int i;
    
    X.Xxx[0] = 0.0;
    X.Xxy[0] = 0.0;
    X.Xxz[0] = 0.0;
    X.Xyy[0] = 0.0;
    X.Xyz[0] = 0.0;
    X.Xzz[0] = 0.0;

    for (i = 0;i < M;i++) {
         X.dXxxdx[i] = 0.0;
         X.dXxydx[i] = 0.0;
         X.dXxzdx[i] = 0.0;
         X.dXyydx[i] = 0.0;
         X.dXyzdx[i] = 0.0;
         X.dXzzdx[i] = 0.0;
    }
} 

void buildXstruc(X,ns,raymagnetic,dNpardx,dNperpdx,dwcndx,dwpn2dx,dbetathdx,Xxx,Xxy,Xxz,Xyy,Xyz,Xzz,dXxxdNperp,dXxydNperp,dXxzdNperp,dXyydNperp,dXyzdNperp,dXzzdNperp,dXxxdNpar,dXxydNpar,dXxzdNpar,dXyydNpar,dXyzdNpar,dXzzdNpar,dXxxdbetath,dXxydbetath,dXxzdbetath,dXyydbetath,dXyzdbetath,dXzzdbetath,dXxxdwcn,dXxydwcn,dXxzdwcn,dXyydwcn,dXyzdwcn,dXzzdwcn,dXxxdwpn2,dXxydwpn2,dXxzdwpn2,dXyydwpn2,dXyzdwpn2,dXzzdwpn2)
susceptibilitytensor_format X;
int ns;
raymagnetic_format raymagnetic;
double dwcndx[][M],dwpn2dx[][M],dbetathdx[][M],dNpardx[];
double complex dNperpdx[];
double complex Xxx[],Xxy[],Xxz[],Xyy[],Xyz[],Xzz[];
double complex dXxxdNperp[],dXxydNperp[],dXxzdNperp[],dXyydNperp[],dXyzdNperp[],dXzzdNperp[];
double complex dXxxdNpar[],dXxydNpar[],dXxzdNpar[],dXyydNpar[],dXyzdNpar[],dXzzdNpar[];
double complex dXxxdbetath[],dXxydbetath[],dXxzdbetath[],dXyydbetath[],dXyzdbetath[],dXzzdbetath[];
double complex dXxxdwcn[],dXxydwcn[],dXxzdwcn[],dXyydwcn[],dXyzdwcn[],dXzzdwcn[];
double complex dXxxdwpn2[],dXxydwpn2[],dXxzdwpn2[],dXyydwpn2[],dXyzdwpn2[],dXzzdwpn2[];
{
    double complex dXxxdrn2[ns+1],dXxydrn2[ns+1],dXxzdrn2[ns+1],dXyydrn2[ns+1],dXyzdrn2[ns+1],dXzzdrn2[ns+1];
    double rn2,drn2dx[M];
    
    int i,is;

    rn2 = raymagnetic.rn[0]*raymagnetic.rn[0];
    for (i = 0;i < M; i++) {
        drn2dx[i] = 2.0*raymagnetic.drndx[i]*raymagnetic.rn[0];
    }
    
    X.Xxx[0] = rn2*Xxx[0];
    X.Xxy[0] = rn2*Xxy[0];
    X.Xxz[0] = rn2*Xxz[0];
    X.Xyy[0] = rn2*Xyy[0];
    X.Xyz[0] = rn2*Xyz[0];
    X.Xzz[0] = rn2*Xzz[0];

    for (is = 1;is < ns + 1;is++) {/* dielectric tensor multiplied by rn2 */
        X.Xxx[0] = X.Xxx[0] + rn2*Xxx[is];
        X.Xxy[0] = X.Xxy[0] + rn2*Xxy[is];
        X.Xxz[0] = X.Xxz[0] + rn2*Xxz[is];
        X.Xyy[0] = X.Xyy[0] + rn2*Xyy[is];
        X.Xyz[0] = X.Xyz[0] + rn2*Xyz[is];
        X.Xzz[0] = X.Xzz[0] + rn2*Xzz[is];           
    }

    for (is = 0;is < ns + 1; is++) {/* derivatives of the dielectric tensor to rn2 */
        dXxxdrn2[is] = Xxx[is];
        dXxydrn2[is] = Xxy[is];
        dXxzdrn2[is] = Xxz[is];
        dXyydrn2[is] = Xyy[is];
        dXyzdrn2[is] = Xyz[is];
        dXzzdrn2[is] = Xzz[is];
    }


    for (i = 0;i < M;i++) {/* Initialisation */
         X.dXxxdx[i] = 0.0;
         X.dXxydx[i] = 0.0;
         X.dXxzdx[i] = 0.0;
         X.dXyydx[i] = 0.0;
         X.dXyzdx[i] = 0.0;
         X.dXzzdx[i] = 0.0;
    }
    
    
    for (i = 0;i < M;i++) {
        for (is = 0;is < ns + 1;is++) {
            X.dXxxdx[i] = X.dXxxdx[i] + dXxxdrn2[is]*drn2dx[i] + rn2*dXxxdNperp[is]*dNperpdx[i] + rn2*dXxxdNpar[is]*dNpardx[i] + rn2*dXxxdbetath[is]*dbetathdx[is][i] + rn2*dXxxdwcn[is]*dwcndx[is][i] + rn2*dXxxdwpn2[is]*dwpn2dx[is][i];
            X.dXxydx[i] = X.dXxydx[i] + dXxydrn2[is]*drn2dx[i] + rn2*dXxydNperp[is]*dNperpdx[i] + rn2*dXxydNpar[is]*dNpardx[i] + rn2*dXxydbetath[is]*dbetathdx[is][i] + rn2*dXxydwcn[is]*dwcndx[is][i] + rn2*dXxydwpn2[is]*dwpn2dx[is][i];
            X.dXxzdx[i] = X.dXxzdx[i] + dXxzdrn2[is]*drn2dx[i] + rn2*dXxzdNperp[is]*dNperpdx[i] + rn2*dXxzdNpar[is]*dNpardx[i] + rn2*dXxzdbetath[is]*dbetathdx[is][i] + rn2*dXxzdwcn[is]*dwcndx[is][i] + rn2*dXxzdwpn2[is]*dwpn2dx[is][i];
            X.dXyydx[i] = X.dXyydx[i] + dXyydrn2[is]*drn2dx[i] + rn2*dXyydNperp[is]*dNperpdx[i] + rn2*dXyydNpar[is]*dNpardx[i] + rn2*dXyydbetath[is]*dbetathdx[is][i] + rn2*dXyydwcn[is]*dwcndx[is][i] + rn2*dXyydwpn2[is]*dwpn2dx[is][i];
            X.dXyzdx[i] = X.dXyzdx[i] + dXyzdrn2[is]*drn2dx[i] + rn2*dXyzdNperp[is]*dNperpdx[i] + rn2*dXyzdNpar[is]*dNpardx[i] + rn2*dXyzdbetath[is]*dbetathdx[is][i] + rn2*dXyzdwcn[is]*dwcndx[is][i] + rn2*dXyzdwpn2[is]*dwpn2dx[is][i];
            X.dXzzdx[i] = X.dXzzdx[i] + dXzzdrn2[is]*drn2dx[i] + rn2*dXzzdNperp[is]*dNperpdx[i] + rn2*dXzzdNpar[is]*dNpardx[i] + rn2*dXzzdbetath[is]*dbetathdx[is][i] + rn2*dXzzdwcn[is]*dwcndx[is][i] + rn2*dXzzdwpn2[is]*dwpn2dx[is][i];      
        }
    }
    
/*    for (i = 0;i < M;i++) {
        mexPrintf("i,dbetathdx[1][i]:%d,%g\n",i,dbetathdx[1][i]);
        mexPrintf("i,dwcndx[1][i]:%d,%g\n",i,dwcndx[1][i]);
        mexPrintf("i,dwpn2dx[1][i]:%d,%g\n",i,dwpn2dx[1][i]);
        mexPrintf("i,dXxxdx,dXxydx,dXxzdx,dXyydx,dXyzdx,dXzzdx:%d,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",i,X.dXxxdx[i],X.dXxydx[i],X.dXxzdx[i],X.dXyydx[i],X.dXyzdx[i],X.dXzzdx[i]);
        mexPrintf("i,dNpardx[i],dNperpdx[i]:%d,%g,%g\n",i,dNpardx[i],dNperpdx[i]);
    }
 */    
   
}



void interpequil(rayparam,raymagnetic,rayprofiles,equilparam,Y,Te_fit,ne_fit,zTi_fit,zni_fit,R_fit,Z_fit,BR_fit,BZ_fit,BPHI_fit,dRstardpsin_fit)
rayparam_format rayparam;
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
equilparam_format equilparam;
double Y[];
pp_1D_format Te_fit;
pp_1D_format ne_fit;
pp_1D_format zTi_fit;
pp_1D_format zni_fit;
pp_2D_format R_fit;
pp_2D_format Z_fit;
pp_2D_format BR_fit;
pp_2D_format BZ_fit;
pp_2D_format BPHI_fit;
pp_1D_format dRstardpsin_fit;
{
/* interpolation from numerical equilibrium data*/
    
    double dummyTi[equilparam.ns[0]],dummyni[equilparam.ns[0]];
    double R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho;
    double r,drdrho,drdtheta;
    double Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho;
    double BR,dBRdrho,dBRdtheta;
    double BZ,dBZdrho,dBZdtheta;
    double BPHI,dBPHIdrho,dBPHIdtheta;
    double BP,dBPdrho,dBPdtheta;
    double B,dBdrho,dBdtheta;
    double salpha,dsalphadrho,dsalphadtheta;
    double dummy1,dummy2,sn;
    double dRstardpsin,ddRstardpsindrho;
    
    int i,is;
    
    /* Equilibrium interpolation */
    
    ppval_1D(dRstardpsin_fit,rayparam.drho[0],Y[0],&dRstardpsin,&ddRstardpsindrho);
    
    ppval_1D(Te_fit,rayparam.drho[0],Y[0],&rayprofiles.Te[0],&rayprofiles.dTedx[0]);
    ppval_1D(ne_fit,rayparam.drho[0],Y[0],&rayprofiles.ne[0],&rayprofiles.dnedx[0]);
    
    ppval_1D(zTi_fit,rayparam.drho[0],Y[0],rayprofiles.zTi,dummyTi);
    for (is=0;is<equilparam.ns[0];is++) {
        rayprofiles.dzTidx[is][0] = dummyTi[is];
    }
    
    ppval_1D(zni_fit,rayparam.drho[0],Y[0],rayprofiles.zni,dummyni);
    for (is=0;is<equilparam.ns[0];is++) {
        if (rayprofiles.zni > 0) {
            rayprofiles.dznidx[is][0] = dummyni[is];
        }
    }

/*    for (i=0;i<equilparam.ns[0];i++) {
        mexPrintf("i,Ti,dzTidx[0],dzTidx[1],dzTidx[2],dzTidx[3],dzTidx[4],dzTidx[5],dzTidx[6]:%d,%g,%g,%g,%g,%g,%g,%g,%g\n",i,rayprofiles.zTi[i],rayprofiles.dzTidx[i][0],rayprofiles.dzTidx[i][1],rayprofiles.dzTidx[i][2],rayprofiles.dzTidx[i][3],rayprofiles.dzTidx[i][4],rayprofiles.dzTidx[i][5],rayprofiles.dzTidx[i][6]);
        mexPrintf("i,ni,dznidx[0],dznidx[1],dznidx[2],dznidx[3],dznidx[4],dznidx[5],dznidx[6]:%d,%g,%g,%g,%g,%g,%g,%g,%g\n",i,rayprofiles.zni[i],rayprofiles.dznidx[i][0],rayprofiles.dznidx[i][1],rayprofiles.dznidx[i][2],rayprofiles.dznidx[i][3],rayprofiles.dznidx[i][4],rayprofiles.dznidx[i][5],rayprofiles.dznidx[i][6]);

    }*/
 
    ppval_2D(R_fit,rayparam.drho[0],Y[0],Y[1],&R,&dRdrho,&dRdtheta,&d2Rdtheta2,&d2Rdthetadrho);
    ppval_2D(Z_fit,rayparam.drho[0],Y[0],Y[1],&Z,&dZdrho,&dZdtheta,&d2Zdtheta2,&d2Zdthetadrho);
    ppval_2D(BR_fit,rayparam.drho[0],Y[0],Y[1],&BR,&dBRdrho,&dBRdtheta,&dummy1,&dummy2);
    ppval_2D(BZ_fit,rayparam.drho[0],Y[0],Y[1],&BZ,&dBZdrho,&dBZdtheta,&dummy1,&dummy2);
    ppval_2D(BPHI_fit,rayparam.drho[0],Y[0],Y[1],&BPHI,&dBPHIdrho,&dBPHIdtheta,&dummy1,&dummy2);  
    
    BP = sqrt(BR*BR + BZ*BZ);
    dBPdrho = (BR*dBRdrho + BZ*dBZdrho)/BP;
    dBPdtheta = (BR*dBRdtheta + BZ*dBZdtheta)/BP;
    
    B = sqrt(BR*BR + BZ*BZ + BPHI*BPHI);
    dBdrho = (BR*dBRdrho + BZ*dBZdrho + BPHI*dBPHIdrho)/B;
    dBdtheta = (BR*dBRdtheta + BZ*dBZdtheta + BPHI*dBPHIdtheta)/B;
    
    raymagnetic.BPn[0] = BP/B;
    raymagnetic.dBPndx[0] = dBPdrho/B - BP*dBdrho/B/B;
    raymagnetic.dBPndx[1] = dBPdtheta/B - BP*dBdtheta/B/B;
   
    raymagnetic.BPHIn[0] = BPHI/B;
    raymagnetic.dBPHIndx[0] = dBPHIdrho/B - BPHI*dBdrho/B/B;
    raymagnetic.dBPHIndx[1] = dBPHIdtheta/B - BPHI*dBdtheta/B/B;
    
    raymagnetic.B[0] = B;
    raymagnetic.dBdx[0] = dBdrho;
    raymagnetic.dBdx[1] = dBdtheta;
    
    r = sqrt((R - equilparam.Rp[0])*(R - equilparam.Rp[0])+(Z - equilparam.Zp[0])*(Z - equilparam.Zp[0]));
    drdrho = (dRdrho*(R - equilparam.Rp[0]) + dZdrho*(Z - equilparam.Zp[0]))/r;
    drdtheta = (dRdtheta*(R - equilparam.Rp[0]) + dZdtheta*(Z - equilparam.Zp[0]))/r;
    
    raymagnetic.rn[0] = r/equilparam.ap[0];
    raymagnetic.drndx[0] = drdrho/equilparam.ap[0];
    raymagnetic.drndx[1] = drdtheta/equilparam.ap[0];
    
    raymagnetic.Rn[0] = R/equilparam.ap[0];
    raymagnetic.dRndx[0] = dRdrho/equilparam.ap[0];
    raymagnetic.dRndx[1] = dRdtheta/equilparam.ap[0];    
    
    sn = sqrt(dRdtheta*dRdtheta + dZdtheta*dZdtheta);
    salpha = ((R - equilparam.Rp[0])*dRdtheta + (Z - equilparam.Zp[0])*dZdtheta)/r/sn;
    dsalphadrho = (dRdtheta*dRdrho + dZdtheta*dZdrho)/r/sn 
                  + ((R - equilparam.Rp[0])*d2Rdthetadrho + (Z - equilparam.Zp[0])*d2Zdthetadrho)/r/sn
                  - drdrho*salpha/r
                  - (dRdtheta*d2Rdthetadrho + dZdtheta*d2Zdthetadrho)*salpha/sn/sn;
    dsalphadtheta = sn/r
                    + ((R - equilparam.Rp[0])*d2Rdtheta2 + (Z - equilparam.Zp[0])*d2Zdtheta2)/r/sn
                    - drdtheta*salpha/r 
                    - (dRdtheta*d2Rdtheta2 + dZdtheta*d2Zdtheta2)*salpha/sn/sn;    
    
    raymagnetic.salpha[0] = salpha;
    raymagnetic.dsalphadx[0] = dsalphadrho;
    raymagnetic.dsalphadx[1] = dsalphadtheta;
    
    raymagnetic.calpha[0] = sqrt(1.0 - salpha*salpha);
    raymagnetic.dcalphadx[0] = -salpha*dsalphadrho/sqrt(1.0 - salpha*salpha);
    raymagnetic.dcalphadx[1] = -salpha*dsalphadtheta/sqrt(1.0 - salpha*salpha); 

    raymagnetic.gradrhon[0] = R*BP*dRstardpsin/equilparam.psia[0];
    raymagnetic.dgradrhondx[0] = (dRdrho*BP*dRstardpsin + R*dBPdrho*dRstardpsin + R*BP*ddRstardpsindrho)/equilparam.psia[0];
    raymagnetic.dgradrhondx[1] = (dRdtheta*BP*dRstardpsin + R*dBPdtheta*dRstardpsin)/equilparam.psia[0];
   
    
/*    mexPrintf("rho,theta:%g,%g\n",Y[0],Y[1]);
    mexPrintf("Te[0],dTedx[0],dTedx[1],ne[0],dnedx[0],dnedx[1]:%g,%g,%g,%g,%g,%g\n",rayprofiles.Te[0],rayprofiles.dTedx[0],rayprofiles.dTedx[1],rayprofiles.ne[0],rayprofiles.dnedx[0],rayprofiles.dnedx[1]);
    for (is=0;is<equilparam.ns[0];is++) {
        mexPrintf("is,zTi[is],dzTidx[is][0],dzTidx[is][1],zni[is],dznidx[is][0],dznidx[is][1]:%d,%g,%g,%g,%g,%g,%g\n",is,rayprofiles.zTi[is],rayprofiles.dzTidx[is][0],rayprofiles.dzTidx[is][1],rayprofiles.zni[is],rayprofiles.dznidx[is][0],rayprofiles.dznidx[is][1]);
    }*/
    
//     mexPrintf("rn[0],drndx[0],drndx[1],Rn[0],dRndx[0],dRndx[1]:%g,%g,%g,%g,%g,%g\n",raymagnetic.rn[0],raymagnetic.drndx[0],raymagnetic.drndx[1],raymagnetic.Rn[0],raymagnetic.dRndx[0],raymagnetic.dRndx[1]);
//     mexPrintf("BPn[0],dBPndx[0],dBPndx[1]:%g,%g,%g\n",raymagnetic.BPn[0],raymagnetic.dBPndx[0],raymagnetic.dBPndx[1]);
//     mexPrintf("BPHIn[0],dBPHIndx[0],dBPHIndx[1]:%g,%g,%g\n",raymagnetic.BPHIn[0],raymagnetic.dBPHIndx[0],raymagnetic.dBPHIndx[1]);
//     mexPrintf("B[0],dBdx[0],dBdx[1]:%g,%g,%g\n",raymagnetic.B[0],raymagnetic.dBdx[0],raymagnetic.dBdx[1]);
//     mexPrintf("salpha[0],dsalphadx[0],dsalphadx[1]:%g,%g,%g\n",raymagnetic.salpha[0],raymagnetic.dsalphadx[0],raymagnetic.dsalphadx[1]);
//     mexPrintf("calpha[0],dcalphadx[0],dcalphadx[1]:%g,%g,%g\n",raymagnetic.calpha[0],raymagnetic.dcalphadx[0],raymagnetic.dcalphadx[1]);
//    mexPrintf("gradrhon[0],dgradrhondx[0],dgradrhondx[1]:%g,%g,%g\n",raymagnetic.gradrhon[0],raymagnetic.dgradrhondx[0],raymagnetic.dgradrhondx[1]);
//    mexPrintf("dRstardpsin,ddRstardpsindrho,psia:%g,%g,%gma\n",dRstardpsin,ddRstardpsindrho,equilparam.psia[0]);

}


void interpequil_test(raymagnetic,rayprofiles,equilparam,Y)
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
equilparam_format equilparam;
double Y[];
{
/* toroidal circular equilibrium from Bonoli and Ott, PoF 25, 359 (1982) */
    
    /*  In this equilibrium the radial coordinate is psi = r/a.
        The Shafranov shift is neglected in first approximation.
        As a consequence, BT0 and BP0 are uniform.
     */
    
    double Te0,Tea,eTe;
    double ne0,nea,ene;
    double Ti0,Tia,eTi;
    double fi[3];
    
    double Rp;
    double BT0,BP0,dBP0dY1;
    double ep,cyl;
    double B,dBdrho,dBdtheta;
    double BP,dBPdrho,dBPdtheta;
    double BPHI,dBPHIdrho,dBPHIdtheta;
    double R,dRdrho,dRdtheta;
    
    double Ip,BPa,qmin,qmax,eq,q,dqdrho;
    
    int is;
   
    if (equilparam.ns[0] > 4) mexErrMsgTxt("Only one high-Z impurity allowed in analytical equilibrium");

    cyl = 1.0;//cylindrical factor
    
    BT0 = 3.0;
    Rp = 3.0*cyl;
    ep = 0.3/cyl;
    
    Te0 = 4.0;
    Tea = Te0/10.0;
    eTe = 1.0;
    
    ne0 = 3.0e+19;
    nea = 1e-10;
    ene = 1.0;
    
    Ti0 = Te0;
    Tia = Ti0/10.0;
    eTi = 1.0;
    
    fi[0] = 0.0;
    fi[1] = 1.0;
    fi[2] = 0.0;    
    
    Ip = 1.0;//MA
    qmin = 1.0;//Edge safety factor q
    eq = 2.0;//q=0 flat q profile
    
    equilparam.zZi[0] = 0.0;//vacuum case
        
    rayprofiles.Te[0] = Tea + (Te0 - Tea)*pow(1 - Y[0]*Y[0],eTe);
    rayprofiles.dTedx[0] = -2*Y[0]*eTe*(Te0 - Tea)*pow(1 - Y[0]*Y[0],eTe - 1);  
    
    rayprofiles.ne[0] = nea + (ne0 - nea)*pow(1 - Y[0]*Y[0],ene);
    rayprofiles.dnedx[0] = -2*Y[0]*ene*(ne0 - nea)*pow(1 - Y[0]*Y[0],ene - 1);  
    
    /* impurity calculation to be implemeted */
    
    for (is=0;is<equilparam.ns[0];is++) {
        rayprofiles.zTi[is] = Tia + (Ti0 - Tia)*pow(1 - Y[0]*Y[0],eTi);
        rayprofiles.dzTidx[is][0] = -2*Y[0]*eTi*(Ti0 - Tia)*pow(1 - Y[0]*Y[0],eTi - 1);     
    }
    
    for (is=0;is<3;is++) {
        rayprofiles.zni[is] = fi[is]*(nea + (ne0 - nea)*pow(1 - Y[0]*Y[0],ene));
        rayprofiles.dznidx[is][0] = -fi[is]*(2*Y[0]*ene*(ne0 - nea)*pow(1 - Y[0]*Y[0],ene - 1));       
    }
    
    for (is=3;is<equilparam.ns[0];is++) {
        rayprofiles.zni[is] = 0;
        rayprofiles.dznidx[is][0] = 0;         
    }

    raymagnetic.rn[0] = Y[0];
    raymagnetic.drndx[0] = 1;
    raymagnetic.drndx[1] = 0.0;
    
    R = Rp*(1.0 + ep*Y[0]*cos(Y[1]));
    dRdrho = Rp*ep*cos(Y[1]);
    dRdtheta = -Rp*ep*Y[0]*sin(Y[1]);
    
    raymagnetic.Rn[0] = R/equilparam.ap[0];
    raymagnetic.dRndx[0] = dRdrho/equilparam.ap[0];
    raymagnetic.dRndx[1] = dRdtheta/equilparam.ap[0];
    
    BPHI = Rp*BT0/R;
    dBPHIdrho = -Rp*BT0*dRdrho/R/R;
    dBPHIdtheta =  -Rp*BT0*dRdtheta/R/R;
    
    BPa = 0.2*Ip/Rp/ep;
    qmax = ep*cyl*fabs(BT0/BPa);//cylindrical limit
    q = (qmax - qmin)*pow(Y[0],eq) + qmin;
    dqdrho = eq*(qmax - qmin)*pow(Y[0],eq - 1.0);
    
    BP = sgn(BPa)*sgn(BT0)*cyl*ep*Rp*Y[0]*BT0/q/R;//cylindrical limit
    dBPdrho = sgn(BPa)*sgn(BT0)*cyl*ep*Rp*(BT0/q/R - dqdrho*Y[0]*BT0/q/q/R - dRdrho*Y[0]*BT0/R/R/q);
    dBPdtheta = -sgn(BPa)*sgn(BT0)*cyl*ep*Rp*dRdtheta*Y[0]*BT0/R/R/q;//cylindrical limit by construction
//    mexPrintf("cyl,ep,Rp,BPa,qmax,q,dqdrho,Y[0],BP,BT0,R,dBPdrho,dBPdtheta:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",cyl,ep,Rp,BPa,qmax,q,dqdrho,Y[0],BP,BT0,R,dBPdrho,dBPdtheta);
      
    B = sqrt(BP*BP + BPHI*BPHI);
    dBdrho = (BP*dBPdrho + BPHI*dBPHIdrho)/B;
    dBdtheta = (BP*dBPdtheta + BPHI*dBPHIdtheta)/B; 
    
    raymagnetic.BPHIn[0] = BPHI/B;
    raymagnetic.dBPHIndx[0] = dBPHIdrho/B - BPHI*dBdrho/B/B;
    raymagnetic.dBPHIndx[1] = dBPHIdtheta/B - BPHI*dBdtheta/B/B;
   
    raymagnetic.BPn[0] = BP/B;
    raymagnetic.dBPndx[0] = dBPdrho/B - BP*dBdrho/B/B;
    raymagnetic.dBPndx[1] = dBPdtheta/B - BP*dBdtheta/B/B;
    
    raymagnetic.B[0] = B;
    raymagnetic.dBdx[0] = dBdrho;
    raymagnetic.dBdx[1] = dBdtheta;

    raymagnetic.calpha[0] = 1.0;
    raymagnetic.dcalphadx[0] = 0.0;
    raymagnetic.dcalphadx[1] = 0.0;
    
    raymagnetic.salpha[0] = 0.0;
    raymagnetic.dsalphadx[0] = 0.0;
    raymagnetic.dsalphadx[1] = 0.0;
    
    raymagnetic.gradrhon[0] = 1.0;
    raymagnetic.dgradrhondx[0] = 0.0;
    raymagnetic.dgradrhondx[1] = 0.0;
    
/*
    mexPrintf("rho,theta:%g,%g\n",Y[0],Y[1]);
    mexPrintf("Te[0],dTedx[0],dTedx[1],ne[0],dnedx[0],dnedx[1]:%g,%g,%g,%g,%g,%g\n",rayprofiles.Te[0],rayprofiles.dTedx[0],rayprofiles.dTedx[1],rayprofiles.ne[0],rayprofiles.dnedx[0],rayprofiles.dnedx[1]);
    for (is=0;is<equilparam.ns[0];is++) {
        mexPrintf("is,zTi[is],dzTidx[is][0],dzTidx[is][1],zni[is],dznidx[is][0],dznidx[is][1]:%d,%g,%g,%g,%g,%g,%g\n",is,rayprofiles.zTi[is],rayprofiles.dzTidx[is][0],rayprofiles.dzTidx[is][1],rayprofiles.zni[is],rayprofiles.dznidx[is][0],rayprofiles.dznidx[is][1]);
    }*/
    
    mexPrintf("rn[0],drndx[0],drndx[1],Rn[0],dRndx[0],dRndx[1]:%g,%g,%g,%g,%g,%g\n",raymagnetic.rn[0],raymagnetic.drndx[0],raymagnetic.drndx[1],raymagnetic.Rn[0],raymagnetic.dRndx[0],raymagnetic.dRndx[1]);
    mexPrintf("BPn[0],dBPndx[0],dBPndx[1]:%g,%g,%g\n",raymagnetic.BPn[0],raymagnetic.dBPndx[0],raymagnetic.dBPndx[1]);
    mexPrintf("BPHIn[0],dBPHIndx[0],dBPHIndx[1]:%g,%g,%g\n",raymagnetic.BPHIn[0],raymagnetic.dBPHIndx[0],raymagnetic.dBPHIndx[1]);
    mexPrintf("B[0],dBdx[0],dBdx[1]:%g,%g,%g\n",raymagnetic.B[0],raymagnetic.dBdx[0],raymagnetic.dBdx[1]);
    mexPrintf("salpha[0],dsalphadx[0],dsalphadx[1]:%g,%g,%g\n",raymagnetic.salpha[0],raymagnetic.dsalphadx[0],raymagnetic.dsalphadx[1]);
    mexPrintf("calpha[0],dcalphadx[0],dcalphadx[1]:%g,%g,%g\n",raymagnetic.calpha[0],raymagnetic.dcalphadx[0],raymagnetic.dcalphadx[1]);
    mexPrintf("gradrhon[0],dgradrhondx[0],dgradrhondx[1]:%g,%g,%g\n",raymagnetic.gradrhon[0],raymagnetic.dgradrhondx[0],raymagnetic.dgradrhondx[1]);

}


double sgn(x)
double x;
{
   if (x < 0.0) {return(-1.0);} 
   if (x == 0.0) {return(0.0);}    
   if (x > 0.0) {return(1.0);}    
    
}


void hottensor(X,ns,ncyclharm,raymagnetic,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx)
susceptibilitytensor_format X;
int ns;
int ncyclharm;
raymagnetic_format raymagnetic;
double wcn[],wpn2[],betath[];
double dwcndx[][M],dwpn2dx[][M],dbetathdx[][M];
double Npar,dNpardx[];
double complex Nperp,dNperpdx[];
{ 
    double complex Xxx[ns+1],Xxy[ns+1],Xxz[ns+1],Xyy[ns+1],Xyz[ns+1],Xzz[ns+1];
    double complex dXxxdNperp[ns+1],dXxydNperp[ns+1],dXxzdNperp[ns+1],dXyydNperp[ns+1],dXyzdNperp[ns+1],dXzzdNperp[ns+1];
    double complex dXxxdNpar[ns+1],dXxydNpar[ns+1],dXxzdNpar[ns+1],dXyydNpar[ns+1],dXyzdNpar[ns+1],dXzzdNpar[ns+1];
    double complex dXxxdbetath[ns+1],dXxydbetath[ns+1],dXxzdbetath[ns+1],dXyydbetath[ns+1],dXyzdbetath[ns+1],dXzzdbetath[ns+1];
    double complex dXxxdwcn[ns+1],dXxydwcn[ns+1],dXxzdwcn[ns+1],dXyydwcn[ns+1],dXyzdwcn[ns+1],dXzzdwcn[ns+1];
    double complex dXxxdwpn2[ns+1],dXxydwpn2[ns+1],dXxzdwpn2[ns+1],dXyydwpn2[ns+1],dXyzdwpn2[ns+1],dXzzdwpn2[ns+1];
    
    double Yxx[ns+1][2*ncyclharm+1],Yxy[ns+1][2*ncyclharm+1],Yxz[ns+1][2*ncyclharm+1],Yyy[ns+1][2*ncyclharm+1],Yyz[ns+1][2*ncyclharm+1],Yzz[ns+1][2*ncyclharm+1];
    double dYxxdNperp[ns+1][2*ncyclharm+1],dYxydNperp[ns+1][2*ncyclharm+1],dYxzdNperp[ns+1][2*ncyclharm+1],dYyydNperp[ns+1][2*ncyclharm+1],dYyzdNperp[ns+1][2*ncyclharm+1],dYzzdNperp[ns+1][2*ncyclharm+1];
    double dYxxdNpar[ns+1][2*ncyclharm+1],dYxydNpar[ns+1][2*ncyclharm+1],dYxzdNpar[ns+1][2*ncyclharm+1],dYyydNpar[ns+1][2*ncyclharm+1],dYyzdNpar[ns+1][2*ncyclharm+1],dYzzdNpar[ns+1][2*ncyclharm+1];
    double dYxxdbetath[ns+1][2*ncyclharm+1],dYxydbetath[ns+1][2*ncyclharm+1],dYxzdbetath[ns+1][2*ncyclharm+1],dYyydbetath[ns+1][2*ncyclharm+1],dYyzdbetath[ns+1][2*ncyclharm+1],dYzzdbetath[ns+1][2*ncyclharm+1];
    double dYxxdwcn[ns+1][2*ncyclharm+1],dYxydwcn[ns+1][2*ncyclharm+1],dYxzdwcn[ns+1][2*ncyclharm+1],dYyydwcn[ns+1][2*ncyclharm+1],dYyzdwcn[ns+1][2*ncyclharm+1],dYzzdwcn[ns+1][2*ncyclharm+1];
    double dYxxdwpn2[ns+1][2*ncyclharm+1],dYxydwpn2[ns+1][2*ncyclharm+1],dYxzdwpn2[ns+1][2*ncyclharm+1],dYyydwpn2[ns+1][2*ncyclharm+1],dYyzdwpn2[ns+1][2*ncyclharm+1],dYzzdwpn2[ns+1][2*ncyclharm+1];
    
    double zeta,dzetadNperp,dzetadNpar,dzetadbetath,dzetadwcn,dzetadwpn2; 
    
    int is,i;


    calcY(ns,ncyclharm,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx,Yxx,Yxy,Yxz,Yyy,Yyz,Yzz,dYxxdNperp,dYxydNperp,dYxzdNperp,dYyydNperp,dYyzdNperp,dYzzdNperp,dYxxdNpar,dYxydNpar,dYxzdNpar,dYyydNpar,dYyzdNpar,dYzzdNpar,dYxxdbetath,dYxydbetath,dYxzdbetath,dYyydbetath,dYyzdbetath,dYzzdbetath,dYxxdwcn,dYxydwcn,dYxzdwcn,dYyydwcn,dYyzdwcn,dYzzdwcn,dYxxdwpn2,dYxydwpn2,dYxzdwpn2,dYyydwpn2,dYyzdwpn2,dYzzdwpn2);

    for (is = 0;is < ns + 1;is++) {/* initialisation */           
        Xxx[is] = 0.0;
        Xxy[is] = 0.0;
        Xxz[is] = 0.0;
        Xyy[is] = 0.0;
        Xyz[is] = 0.0;
        Xzz[is] = 0.0;

        dXxxdNperp[is] = 0.0;
        dXxydNperp[is] = 0.0;
        dXxzdNperp[is] = 0.0;
        dXyydNperp[is] = 0.0;
        dXyzdNperp[is] = 0.0;
        dXzzdNperp[is] = 0.0;

        dXxxdNpar[is] = 0.0;
        dXxydNpar[is] = 0.0;
        dXxzdNpar[is] = 0.0;
        dXyydNpar[is] = 0.0;
        dXyzdNpar[is] = 0.0;
        dXzzdNpar[is] = 0.0;

        dXxxdbetath[is] = 0.0;
        dXxydbetath[is] = 0.0;
        dXxzdbetath[is] = 0.0;
        dXyydbetath[is] = 0.0;
        dXyzdbetath[is] = 0.0;
        dXzzdbetath[is] = 0.0;

        dXxxdwcn[is] = 0.0;
        dXxydwcn[is] = 0.0;
        dXxzdwcn[is] = 0.0;
        dXyydwcn[is] = 0.0;
        dXyzdwcn[is] = 0.0;
        dXzzdwcn[is] = 0.0;    

        dXxxdwpn2[is] = 0.0;
        dXxydwpn2[is] = 0.0;
        dXxzdwpn2[is] = 0.0;
        dXyydwpn2[is] = 0.0;
        dXyzdwpn2[is] = 0.0;
        dXzzdwpn2[is] = 0.0;    
    }
    
    for (is = 0;is < ns + 1;is++) {
        for (i = -ncyclharm;i <= ncyclharm; i++) {
            
            zeta = (1.0 - i*wcn[is])/fabs(Npar)*betath[is];
            dzetadNperp = 0.0;
            dzetadNpar = -sgn(Npar)*zeta/Npar;
            dzetadbetath = -zeta/betath[is];
            dzetadwcn = - i/fabs(Npar)*betath[is];
            dzetadwpn2 = 0.0;
            
/* Dielectric tensor */
            
            Xxx[is] = Xxx[is] + wpn2[is]*zeta*Yxx[is][i];
            Xxy[is] = Xxy[is] + wpn2[is]*zeta*Yxy[is][i];
            Xxz[is] = Xxz[is] + wpn2[is]*zeta*Yxz[is][i];
            Xyy[is] = Xyy[is] + wpn2[is]*zeta*Yyy[is][i];
            Xyz[is] = Xyz[is] + wpn2[is]*zeta*Yyz[is][i];
            Xzz[is] = Xzz[is] + wpn2[is]*zeta*Yzz[is][i];

 /* derivatives of the dielectric tensor */

            dXxxdNperp[is] = dXxxdNperp[is] + wpn2[is]*dzetadNperp*Yxx[is][i] + wpn2[is]*zeta*dYxxdNperp[is][i];
            dXxydNperp[is] = dXxydNperp[is] + wpn2[is]*dzetadNperp*Yxy[is][i] + wpn2[is]*zeta*dYxydNperp[is][i];
            dXxzdNperp[is] = dXxzdNperp[is] + wpn2[is]*dzetadNperp*Yxz[is][i] + wpn2[is]*zeta*dYxzdNperp[is][i];
            dXyydNperp[is] = dXyydNperp[is] + wpn2[is]*dzetadNperp*Yyy[is][i] + wpn2[is]*zeta*dYyydNperp[is][i];
            dXyzdNperp[is] = dXyzdNperp[is] + wpn2[is]*dzetadNperp*Yyz[is][i] + wpn2[is]*zeta*dYyzdNperp[is][i];
            dXzzdNperp[is] = dXzzdNperp[is] + wpn2[is]*dzetadNperp*Yzz[is][i] + wpn2[is]*zeta*dYzzdNperp[is][i];

            dXxxdNpar[is] = dXxxdNpar[is] + wpn2[is]*dzetadNpar*Yxx[is][i] + wpn2[is]*zeta*dYxxdNpar[is][i];
            dXxydNpar[is] = dXxydNpar[is] + wpn2[is]*dzetadNpar*Yxy[is][i] + wpn2[is]*zeta*dYxydNpar[is][i];
            dXxzdNpar[is] = dXxzdNpar[is] + wpn2[is]*dzetadNpar*Yxz[is][i] + wpn2[is]*zeta*dYxzdNpar[is][i];
            dXyydNpar[is] = dXyydNpar[is] + wpn2[is]*dzetadNpar*Yyy[is][i] + wpn2[is]*zeta*dYyydNpar[is][i];
            dXyzdNpar[is] = dXyzdNpar[is] + wpn2[is]*dzetadNpar*Yyz[is][i] + wpn2[is]*zeta*dYyzdNpar[is][i];
            dXzzdNpar[is] = dXzzdNpar[is] + wpn2[is]*dzetadNpar*Yzz[is][i] + wpn2[is]*zeta*dYzzdNpar[is][i];

            dXxxdbetath[is] = dXxxdbetath[is] + wpn2[is]*dzetadbetath*Yxx[is][i] + wpn2[is]*zeta*dYxxdbetath[is][i];
            dXxydbetath[is] = dXxydbetath[is] + wpn2[is]*dzetadbetath*Yxy[is][i] + wpn2[is]*zeta*dYxydbetath[is][i];
            dXxzdbetath[is] = dXxzdbetath[is] + wpn2[is]*dzetadbetath*Yxz[is][i] + wpn2[is]*zeta*dYxzdbetath[is][i];
            dXyydbetath[is] = dXyydbetath[is] + wpn2[is]*dzetadbetath*Yyy[is][i] + wpn2[is]*zeta*dYyydbetath[is][i];
            dXyzdbetath[is] = dXyzdbetath[is] + wpn2[is]*dzetadbetath*Yyz[is][i] + wpn2[is]*zeta*dYyzdbetath[is][i];
            dXzzdbetath[is] = dXzzdbetath[is] + wpn2[is]*dzetadbetath*Yzz[is][i] + wpn2[is]*zeta*dYzzdbetath[is][i];

            dXxxdwcn[is] = dXxxdwcn[is] + wpn2[is]*dzetadwcn*Yxx[is][i] + wpn2[is]*zeta*dYxxdwcn[is][i];
            dXxydwcn[is] = dXxydwcn[is] + wpn2[is]*dzetadwcn*Yxy[is][i] + wpn2[is]*zeta*dYxydwcn[is][i];
            dXxzdwcn[is] = dXxzdwcn[is] + wpn2[is]*dzetadwcn*Yxz[is][i] + wpn2[is]*zeta*dYxzdwcn[is][i];
            dXyydwcn[is] = dXyydwcn[is] + wpn2[is]*dzetadwcn*Yyy[is][i] + wpn2[is]*zeta*dYyydwcn[is][i];
            dXyzdwcn[is] = dXyzdwcn[is] + wpn2[is]*dzetadwcn*Yyz[is][i] + wpn2[is]*zeta*dYyzdwcn[is][i];
            dXzzdwcn[is] = dXzzdwcn[is] + wpn2[is]*dzetadwcn*Yzz[is][i] + wpn2[is]*zeta*dYzzdwcn[is][i];    

            dXxxdwpn2[is] = dXxxdwpn2[is] + zeta*Yxx[is][i] + wpn2[is]*dzetadwpn2*Yxx[is][i] + wpn2[is]*zeta*dYxxdwpn2[is][i];
            dXxydwpn2[is] = dXxydwpn2[is] + zeta*Yxy[is][i] + wpn2[is]*dzetadwpn2*Yxy[is][i] + wpn2[is]*zeta*dYxydwpn2[is][i];
            dXxzdwpn2[is] = dXxzdwpn2[is] + zeta*Yxz[is][i] + wpn2[is]*dzetadwpn2*Yxz[is][i] + wpn2[is]*zeta*dYxzdwpn2[is][i];
            dXyydwpn2[is] = dXyydwpn2[is] + zeta*Yyy[is][i] + wpn2[is]*dzetadwpn2*Yyy[is][i] + wpn2[is]*zeta*dYyydwpn2[is][i];
            dXyzdwpn2[is] = dXyzdwpn2[is] + zeta*Yyz[is][i] + wpn2[is]*dzetadwpn2*Yyz[is][i] + wpn2[is]*zeta*dYyzdwpn2[is][i];
            dXzzdwpn2[is] = dXzzdwpn2[is] + zeta*Yzz[is][i] + wpn2[is]*dzetadwpn2*Yzz[is][i] + wpn2[is]*zeta*dYzzdwpn2[is][i];    
        }
    }
     
    buildXstruc(X,ns,raymagnetic,dNpardx,dNperpdx,dwcndx,dwpn2dx,dbetathdx,Xxx,Xxy,Xxz,Xyy,Xyz,Xzz,dXxxdNperp,dXxydNperp,dXxzdNperp,dXyydNperp,dXyzdNperp,dXzzdNperp,dXxxdNpar,dXxydNpar,dXxzdNpar,dXyydNpar,dXyzdNpar,dXzzdNpar,dXxxdbetath,dXxydbetath,dXxzdbetath,dXyydbetath,dXyzdbetath,dXzzdbetath,dXxxdwcn,dXxydwcn,dXxzdwcn,dXyydwcn,dXyzdwcn,dXzzdwcn,dXxxdwpn2,dXxydwpn2,dXxzdwpn2,dXyydwpn2,dXyzdwpn2,dXzzdwpn2);
} 


void calcY(ns,ncyclharm,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx,Yxx,Yxy,Yxz,Yyy,Yyz,Yzz,dYxxdNperp,dYxydNperp,dYxzdNperp,dYyydNperp,dYyzdNperp,dYzzdNperp,dYxxdNpar,dYxydNpar,dYxzdNpar,dYyydNpar,dYyzdNpar,dYzzdNpar,dYxxdbetath,dYxydbetath,dYxzdbetath,dYyydbetath,dYyzdbetath,dYzzdbetath,dYxxdwcn,dYxydwcn,dYxzdwcn,dYyydwcn,dYyzdwcn,dYzzdwcn,dYxxdwpn2,dYxydwpn2,dYxzdwpn2,dYyydwpn2,dYyzdwpn2,dYzzdwpn2)
int ns;
int ncyclharm;
double Npar,dNpardx[M];
double complex Nperp,dNperpdx[M];
double wcn[],dwcndx[][M],wpn2[],dwpn2dx[][M],betath[],dbetathdx[][M];
double complex Yxx[][MAXCYCLHARM],Yxy[][MAXCYCLHARM],Yxz[][MAXCYCLHARM],Yyy[][MAXCYCLHARM],Yyz[][MAXCYCLHARM],Yzz[][MAXCYCLHARM];
double complex dYxxdNperp[][MAXCYCLHARM],dYxydNperp[][MAXCYCLHARM],dYxzdNperp[][MAXCYCLHARM],dYyydNperp[][MAXCYCLHARM],dYyzdNperp[][MAXCYCLHARM],dYzzdNperp[][MAXCYCLHARM];
double complex dYxxdNpar[][MAXCYCLHARM],dYxydNpar[][MAXCYCLHARM],dYxzdNpar[][MAXCYCLHARM],dYyydNpar[][MAXCYCLHARM],dYyzdNpar[][MAXCYCLHARM],dYzzdNpar[][MAXCYCLHARM];
double complex dYxxdbetath[][MAXCYCLHARM],dYxydbetath[][MAXCYCLHARM],dYxzdbetath[][MAXCYCLHARM],dYyydbetath[][MAXCYCLHARM],dYyzdbetath[][MAXCYCLHARM],dYzzdbetath[][MAXCYCLHARM];
double complex dYxxdwcn[][MAXCYCLHARM],dYxydwcn[][MAXCYCLHARM],dYxzdwcn[][MAXCYCLHARM],dYyydwcn[][MAXCYCLHARM],dYyzdwcn[][MAXCYCLHARM],dYzzdwcn[][MAXCYCLHARM];
double complex dYxxdwpn2[][MAXCYCLHARM],dYxydwpn2[][MAXCYCLHARM],dYxzdwpn2[][MAXCYCLHARM],dYyydwpn2[][MAXCYCLHARM],dYyzdwpn2[][MAXCYCLHARM],dYzzdwpn2[][MAXCYCLHARM];
{ 
    double zeta,dzetadNperp,dzetadNpar,dzetadbetath,dzetadwcn,dzetadwpn2;
    double complex lambda,dlambdadNperp,dlambdadNpar,dlambdadbetath,dlambdadwcn,dlambdadwpn2;
    double complex Z,Zp,Zpp,G,Gp,Gpp;
    double sigmas;
    
    int is,i;  
 
    if (2*ncyclharm+1 > MAXCYCLHARM) {mexPrintf("******** WARNING: the code is limited to 50 cylotron harmonics only ! ********");}
    
    for (is = 0;is < ns + 1;is++) {
        
        sigmas = sgn(-1.0+2.0*is);/* sign of the charge, electron is always first, the ions */
        
        for (i = -ncyclharm;i <= ncyclharm; i++) {
            
            zeta = (1.0 - i*wcn[is])/fabs(Npar)*betath[is];
            dzetadNperp = 0.0;
            dzetadNpar = -sgn(Npar)*zeta/Npar;
            dzetadbetath = -zeta/betath[is];
            dzetadwcn = - i/fabs(Npar)*betath[is];
            dzetadwpn2 = 0.0;
            
            lambda = Nperp*betath[is]/wcn[is];
            dlambdadNperp = betath[is]/wcn[is];
            dlambdadNpar = 0.0;
            dlambdadbetath = Nperp/wcn[is];
            dlambdadwcn = - lambda/wcn[is];
            dlambdadwpn2 = 0.0;
            
            Zdisp((double complex)zeta,&Z,&Zp,&Zpp);
            Gamma((double)i,lambda,&G,&Gp,&Gpp);
            
/* Dielectric tensor */
                       
            Yxx[is][i] = i*i*G*Z/lambda;
            Yxy[is][i] = I*sigmas*i*Gp*Z;
            Yxz[is][i] = -sgn(Npar)*i*G*Zp/sqrt(2.0*lambda);
            Yyy[is][i] = (i*i*G/lambda - 2.0*lambda*Gp)*Z;
            Yyz[is][i] = I*sigmas*sgn(Npar)*sqrt(lambda/2.0)*Gp*Zp;
            Yzz[is][i] = -G*zeta*Zp;

 /* derivatives of the dielectric tensor */

            dYxxdNperp[is][i] = i*i*Gp*dlambdadNperp*Z/lambda + i*i*G*Zp*dzetadNperp - i*i*G*Z*dlambdadNperp/lambda/lambda;
            dYxydNperp[is][i] = I*sigmas*i*Gpp*dlambdadNperp*Z + I*sigmas*i*Gp*Zp*dzetadNperp;
            dYxzdNperp[is][i] = -sgn(Npar)*i*Gp*dlambdadNperp*Zp/sqrt(2.0*lambda) - sgn(Npar)*i*G*Zpp*dzetadNperp/sqrt(2.0*lambda) + sgn(Npar)*i*G*Zp*dlambdadNperp/sqrt(2.0*lambda)/(2.0*lambda);
            dYyydNperp[is][i] = (i*i*Gp*dlambdadNperp/lambda - i*i*G*dlambdadNperp/lambda/lambda - 2.0*dlambdadNperp*Gp - 2.0*lambda*dlambdadNperp*Gpp)*Z + (i*i*G/lambda - 2.0*lambda*Gp)*Zp*dzetadNperp;
            dYyzdNperp[is][i] = I*sigmas*sgn(Npar)*dlambdadNperp*Gp*Zp/sqrt(lambda/2.0)/4.0 + I*sigmas*sgn(Npar)*sqrt(lambda/2.0)*Gpp*dlambdadNperp*Zp + I*sigmas*sgn(Npar)*sqrt(lambda/2.0)*Gp*Zpp*dzetadNperp;
            dYzzdNperp[is][i] = -Gp*dlambdadNperp*zeta*Zp - G*dzetadNperp*Zp - G*zeta*Zpp*dzetadNperp;

            dYxxdNpar[is][i] = i*i*Gp*dlambdadNpar*Z/lambda + i*i*G*Zp*dzetadNpar - i*i*G*Z*dlambdadNpar/lambda/lambda;
            dYxydNpar[is][i] = I*sigmas*i*Gpp*dlambdadNpar*Z + I*sigmas*i*Gp*Zp*dzetadNpar;
            dYxzdNpar[is][i] = -sgn(Npar)*i*Gp*dlambdadNpar*Zp/sqrt(2.0*lambda) - sgn(Npar)*i*G*Zpp*dzetadNpar/sqrt(2.0*lambda) + sgn(Npar)*i*G*Zp*dlambdadNpar/sqrt(2.0*lambda)/(2.0*lambda);
            dYyydNpar[is][i] = (i*i*Gp*dlambdadNpar/lambda - i*i*G*dlambdadNpar/lambda/lambda - 2.0*dlambdadNpar*Gp - 2.0*lambda*dlambdadNpar*Gpp)*Z + (i*i*G/lambda - 2.0*lambda*Gp)*Zp*dzetadNpar;
            dYyzdNpar[is][i] = I*sigmas*sgn(Npar)*dlambdadNpar*Gp*Zp/sqrt(lambda/2.0)/4.0 + I*sigmas*sgn(Npar)*sqrt(lambda/2.0)*Gpp*dlambdadNpar*Zp + I*sigmas*sgn(Npar)*sqrt(lambda/2.0)*Gp*Zpp*dzetadNpar;
            dYzzdNpar[is][i] = -Gp*dlambdadNpar*zeta*Zp - G*dzetadNpar*Zp - G*zeta*Zpp*dzetadNpar;

            dYxxdbetath[is][i] = i*i*Gp*dlambdadbetath*Z/lambda + i*i*G*Zp*dzetadbetath - i*i*G*Z*dlambdadbetath/lambda/lambda;
            dYxydbetath[is][i] = I*sigmas*i*Gpp*dlambdadbetath*Z + I*sigmas*i*Gp*Zp*dzetadbetath;
            dYxzdbetath[is][i] = -sgn(Npar)*i*Gp*dlambdadbetath*Zp/sqrt(2.0*lambda) - sgn(Npar)*i*G*Zpp*dzetadbetath/sqrt(2.0*lambda) + sgn(Npar)*i*G*Zp*dlambdadbetath/sqrt(2.0*lambda)/(2.0*lambda);
            dYyydbetath[is][i] = (i*i*Gp*dlambdadbetath/lambda - i*i*G*dlambdadbetath/lambda/lambda - 2.0*dlambdadbetath*Gp - 2.0*lambda*dlambdadbetath*Gpp)*Z + (i*i*G/lambda - 2.0*lambda*Gp)*Zp*dzetadbetath;
            dYyzdbetath[is][i] = I*sigmas*sgn(Npar)*dlambdadbetath*Gp*Zp/sqrt(lambda/2.0)/4.0 + I*sigmas*sgn(Npar)*sqrt(lambda/2.0)*Gpp*dlambdadbetath*Zp + I*sigmas*sgn(Npar)*sqrt(lambda/2.0)*Gp*Zpp*dzetadbetath;
            dYzzdbetath[is][i] = -Gp*dlambdadbetath*zeta*Zp - G*dzetadbetath*Zp - G*zeta*Zpp*dzetadbetath;

            dYxxdwcn[is][i] = i*i*Gp*dlambdadwcn*Z/lambda + i*i*G*Zp*dzetadwcn - i*i*G*Z*dlambdadwcn/lambda/lambda;
            dYxydwcn[is][i] = I*sigmas*i*Gpp*dlambdadwcn*Z + I*sigmas*i*Gp*Zp*dzetadwcn;
            dYxzdwcn[is][i] = -sgn(Npar)*i*Gp*dlambdadwcn*Zp/sqrt(2.0*lambda) - sgn(Npar)*i*G*Zpp*dzetadwcn/sqrt(2.0*lambda) + sgn(Npar)*i*G*Zp*dlambdadwcn/sqrt(2.0*lambda)/(2.0*lambda);
            dYyydwcn[is][i] = (i*i*Gp*dlambdadwcn/lambda - i*i*G*dlambdadwcn/lambda/lambda - 2.0*dlambdadwcn*Gp - 2.0*lambda*dlambdadwcn*Gpp)*Z + (i*i*G/lambda - 2.0*lambda*Gp)*Zp*dzetadwcn;
            dYyzdwcn[is][i] = I*sigmas*sgn(Npar)*dlambdadwcn*Gp*Zp/sqrt(lambda/2.0)/4.0 + I*sigmas*sgn(Npar)*sqrt(lambda/2.0)*Gpp*dlambdadwcn*Zp + I*sigmas*sgn(Npar)*sqrt(lambda/2.0)*Gp*Zpp*dzetadwcn;
            dYzzdwcn[is][i] = -Gp*dlambdadwcn*zeta*Zp - G*dzetadwcn*Zp - G*zeta*Zpp*dzetadwcn;    

            dYxxdwpn2[is][i] = i*i*Gp*dlambdadwpn2*Z/lambda + i*i*G*Zp*dzetadwpn2 - i*i*G*Z*dlambdadwpn2/lambda/lambda;
            dYxydwpn2[is][i] = I*sigmas*i*Gpp*dlambdadwpn2*Z + I*sigmas*i*Gp*Zp*dzetadwpn2;
            dYxzdwpn2[is][i] = -sgn(Npar)*i*Gp*dlambdadwpn2*Zp/sqrt(2.0*lambda) - sgn(Npar)*i*G*Zpp*dzetadwpn2/sqrt(2.0*lambda) + sgn(Npar)*i*G*Zp*dlambdadwpn2/sqrt(2.0*lambda)/(2.0*lambda);
            dYyydwpn2[is][i] = (i*i*Gp*dlambdadwpn2/lambda - i*i*G*dlambdadwpn2/lambda/lambda - 2.0*dlambdadwpn2*Gp - 2.0*lambda*dlambdadwpn2*Gpp)*Z + (i*i*G/lambda - 2.0*lambda*Gp)*Zp*dzetadwpn2;
            dYyzdwpn2[is][i] = I*sigmas*sgn(Npar)*dlambdadwpn2*Gp*Zp/sqrt(lambda/2.0)/4.0 + I*sigmas*sgn(Npar)*sqrt(lambda/2.0)*Gpp*dlambdadwpn2*Zp + I*sigmas*sgn(Npar)*sqrt(lambda/2.0)*Gp*Zpp*dzetadwpn2;
            dYzzdwpn2[is][i] = -Gp*dlambdadwpn2*zeta*Zp - G*dzetadwpn2*Zp - G*zeta*Zpp*dzetadwpn2;    
        }
    }   
}

void Gamma(nhu,z,g,gp,gpp)
int nhu;
double complex z,*g,*gp,*gpp;
{ 
    double complex mBn,mBnp,mBnpp;
    
    modBessel(nhu,z,&mBn,&mBnp,&mBnpp);
    
    g[0] = cexp(-z)*mBn;
    gp[0] = -g[0] + cexp(-z)*mBnp;
    gpp[0] = g[0] - cexp(-z)*(2.0*mBnp - mBnpp);
    
}


void Zdisp(z,Z,Zp,Zpp)
double complex z;
double complex *Z,*Zp,*Zpp;
{  

    ZFriedConte(z,Z);

    Zp[0] = -2.0*(1.0 + z*Z[0]);
    Zpp[0] = 4.0*z + Z[0]*(4*z*z - 2.0);
}

void ZFriedConte(z,Z)
double complex z;
double complex *Z;
{
    double daw,x,y;
    if (cimag(z) == 0.0) {//pure real argument
        x = creal(z);
        dawson(x,&daw);
        Z[0]=-2.0*daw+I*sqrt(PI)*exp(x*x);
    } else if (creal(z) == 0.0) {//pure imaginary argument
        y = cimag(z);
        Z[0] = I*sqrt(PI)*exp(y*y)*erfc(-y);
    } else {
        smith(z,Z); 
    }
}


void modBessel(nhu,z,mBn,mBnp,mBnpp)
double nhu;
double complex z,*mBn,*mBnp,*mBnpp;
{   
    double complex iBn,iBnp,iBnpp;
    
    imagBessel(nhu,I*z,&iBn,&iBnp,&iBnpp);

    mBn[0] = cpow(-I,nhu)*iBn;
    mBnp[0] = -cpow(-I,nhu+1.0)*iBnp;
    mBnpp[0] = -cpow(-I,nhu)*iBnpp;
    
//    mexPrintf("modBesseln:%g,%g\n",mBn[0]);
    
}



void imagBessel(nhu,z,iBn,iBnp,iBnpp)
double nhu;
double complex z,*iBn,*iBnp,*iBnpp;
{   
    mxArray *rhs[3], *lhs[1];
    
    double  *pr,*pi;
    double complex Besseln,Besselnm1,Besselnm2;
    double *Bessel_r,*Bessel_i;
    
    rhs[0] = mxCreateString("J");
    rhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
    rhs[2] = mxCreateDoubleMatrix(1, 1, mxCOMPLEX);
    
    pr = mxGetPr(rhs[2]);
    pr[0] = creal(z);
    pi = mxGetPi(rhs[2]);
    pi[0] = cimag(z);
    
    pr = mxGetPr(rhs[1]);
    pr[0] = nhu;
    mexCallMATLAB(1,lhs,3,rhs,"besselmx");//call the MatLab built-in Bessel function: [w,ierr] = besselmx(double('J'),0,z)
    Bessel_r = mxGetData(lhs[0]);
    Bessel_i = mxGetImagData(lhs[0]);
    Besseln = Bessel_r[0] + I*Bessel_i[0];
    
//    mexPrintf("Besseln:%g,%g\n",Besseln);
    
    pr = mxGetPr(rhs[1]);
    pr[0] = nhu - 1.0;
    mexCallMATLAB(1,lhs,3,rhs,"besselmx");//call the MatLab built-in Bessel function: [w,ierr] = besselmx(double('J'),0,z)
    Bessel_r = mxGetData(lhs[0]);
    Bessel_i = mxGetImagData(lhs[0]);
    Besselnm1 = Bessel_r[0] + I*Bessel_i[0];
    
//    mexPrintf("Besseln:%g,%g\n",Besselnm1);
    
    
    pr = mxGetPr(rhs[1]);
    pr[0] = nhu - 2.0;
    mexCallMATLAB(1,lhs,3,rhs,"besselmx");//call the MatLab built-in Bessel function: [w,ierr] = besselmx(double('J'),0,z)
    Bessel_r = mxGetData(lhs[0]);
    Bessel_i = mxGetImagData(lhs[0]);
    Besselnm2 = Bessel_r[0] + I*Bessel_i[0];

//    mexPrintf("Besseln:%g,%g\n",Besselnm2);
  
    iBn[0] = Besseln;
    iBnp[0] = Besselnm1 - nhu*Besseln/z;
    iBnpp[0] = Besselnm2 + (2.0*nhu - 1.0)*Besselnm1/z + nhu*(nhu + 1.0)*Besseln/z/z;
    
    /* cleanup allocated memory */
    
    mxDestroyArray(rhs[0]);
    mxDestroyArray(rhs[1]);
    mxDestroyArray(rhs[2]);
    mxDestroyArray(lhs[0]);
}



void smith(z,Z) 
double complex z, *Z;
{

    /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Z dispersion function
    % with complex argument zeta.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % For real argument use also Dawson integral
    % with Tchebychev polynomials
    % Z=-2.0*dawson(zeta)+i*sqrt(pi)*exp(-zeta.*zeta);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % For pure imaginary argument also use
    % Z(i*x)=i*sqrt(pi)*exp(x.*x).*erfc(-x)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Inspired by Gary R. Smith
    % Phys. Fluids 27 (6) june 1984 p. 1510 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    */

    double complex z2, z_2, som, ZZ;
    double rz,iz;
    double criterion, sigma; 
    int nn; 

    /* % epsilon=1e-10
    % b=4.74
    % nmax1=58
    % nmax2=25
    % nmax3=27

    % epsilon=1e-12 */

    static double b=5.51; /* boundary between formulas */
    static double nmax1=75; /* nmax for series expansion */
    static double nmax2=34; /* nmax for continued fraction */
    static double nmax3=27; /* nmax for asymptotic expansion */
    static double complex czero = 0.0;
    static double complex cone = 1.0;
    static double complex isqrtpi = 1.772453850905516*I;

    z2=z*z;
    som=czero;
    rz=abs(creal(z));
    iz=abs(cimag(z));

    /* Series expansion around zeta = 0
     formula A10 */
    if ((rz <= b) & (iz <= 2.0-1.5*rz/b)) {
        for (nn = nmax1;nn > 0;nn--) {
            som = 1.0/nn*z2*1.0/(2.0*nn + 1.0 + som);
        }
        ZZ = cexp(-z2)*(isqrtpi - 2.0*z*(som + 1.0));
    }

    /* Continued fraction expansion
     formula A12 & A13 */

    if (((rz <= b) & (iz > 2.0-1.5*rz/b)) | ((rz > b) & (iz > 0.5))) {

        z_2 = cone/z2;
        for (nn = nmax2;nn > 0;nn--) {
            som = -0.5*nn*z_2/(som + 1.0);
        }
        ZZ = -1.0/(z*(som + 1.0));        
        if (cimag(z) < 0.0) {
            ZZ = ZZ + 2.0*isqrtpi*cexp(-z2);
        }
    }

    /* %% Asymptotic expansion
    %% formula A15 */
    if ((rz > b) & (iz <= 0.5)) {
        z_2 = cone/z2;
        for (nn = nmax3;nn > 0;nn--) {
            som = (nn-0.5)*z_2*(som + 1.0);
        }
        ZZ = -(som + 1.0)/z;    
        criterion = 0.7853981633974483331/rz;
        sigma = (cimag(z) < criterion) + (cimag(z) < -criterion);
        if (sigma>0.0) {
            ZZ = ZZ + sigma*isqrtpi*cexp(-z2);
        }
    }

    Z[0] = ZZ;
} 



void dawson(zeta,dwork) 
double zeta;
double *dwork;
{

   /*     A FUNCTION TO EVALUATE DAWSON'S INTEGRAL,    
         Dawson(Zeta) = Integral ( t=0->Zeta ) Exp(t**2-Zeta**2) dt,
         = -0.5 * Real part of Fried & Conte Z function   
         USING A CHEBYCHEV POLYNOMIAL SERIES.  */

    static double half = 0.5; 
    static double one = 1.0; 
    static double two = 2.0; 
    static double ten = 10.0;
    /* nmax=    5         => 1e-2 precision
               10         => 1e-4
               15         => 1e-6
               20         => single
               50         => double */
    static int nmax=50;
    
    static double tcoef [51]={2.3770636862073187, -0.2214259431356961, -0.0232524179380925, 0.1327809189298409, -0.1325824891002065,
          0.0825446940740374, -0.0337827509774703, 0.0070874724137126, 0.0009814185303952, -0.0010948499244205,
          0.0001341521888280,0.0001204181702739,-0.0000351287219323,-0.0000146145750095,0.0000062641524139,
          0.0000022709548584,-0.0000010280349044,-0.0000004487400975,0.0000001532631036,0.0000001005306690,
          -0.0000000166366048,-0.0000000226490692,-0.0000000006425396,0.0000000046258504,0.0000000011681305,
          -0.0000000007317958,-0.0000000004540732,0.0000000000395128,0.0000000001175806,0.0000000000278655,
          -0.0000000000190620,-0.0000000000134858,-0.0000000000001751,0.0000000000033395,0.0000000000013606,
          -0.0000000000003122,-0.0000000000004896,-0.0000000000001295,0.0000000000000741,0.0000000000000694,
          0.0000000000000122,-0.0000000000000135,-0.0000000000000101,-0.0000000000000013,0.0000000000000022,
          0.0000000000000016,0.0000000000000002,-0.0000000000000004,-0.0000000000000003,0.0000000000000000,
          0.0000000000000001};
    double zeta2, t, twot, tn, tnm1,tnm2;
    int ind;

    zeta2=zeta*zeta;
    t=(zeta2-ten)/(zeta2+ten);
    twot=two*t;
    tnm1=one;
    tn=t;
    dwork[0]=half*tcoef[0]*tnm1+tcoef[1]*tn;
    for (ind=2;ind<=nmax;ind++) {
       tnm2=tnm1;
       tnm1=tn;
       tn=twot*tnm1-tnm2;
       dwork[0] += tcoef[ind]*tn;
    }
    dwork[0] *= zeta/(one+two*zeta2);  
}


