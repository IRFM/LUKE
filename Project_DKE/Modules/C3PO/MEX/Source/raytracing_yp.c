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
    double *r;
    double *R;
    double *salpha;
    double *calpha;
    double *BP;
    double *BPHI;
    double *B;
    double *drdx;
    double *dRdx;
    double *dsalphadx;
    double *dcalphadx;
    double *dBPdx;
    double *dBPHIdx;
    double *dBdx;
};

struct susceptibilitytensor {
    double *Xxx;
    double *Xxy;
    double *Xxz;
    double *Xyy;
    double *Xyz;
    double *Xzz;
    double *dXxxdpsi;
    double *dXxydpsi;
    double *dXxzdpsi;
    double *dXyydpsi;
    double *dXyzdpsi;
    double *dXzzdpsi;
    double *dXxxdtheta;
    double *dXxydtheta;
    double *dXxzdtheta;
    double *dXyydtheta;
    double *dXyzdtheta;
    double *dXzzdtheta;
    double *dXxxdkpsi;
    double *dXxydkpsi;
    double *dXxzdkpsi;
    double *dXyydkpsi;
    double *dXyzdkpsi;
    double *dXzzdkpsi;
    double *dXxxdm;
    double *dXxydm;
    double *dXxzdm;
    double *dXyydm;
    double *dXyzdm;
    double *dXzzdm;    
    double *dXxxdn;
    double *dXxydn;
    double *dXxzdn;
    double *dXyydn;
    double *dXyzdn;
    double *dXzzdn;    
};

struct rayparam {
    double *testmode;
    double *tensortype;
    double *t0;
    double *tfinal;
    double *dt0;
    double *dpsi;
    double *tol;
    double *kmax;
};

struct equilparam {
    double*zZi;
    double *zmi;
    int *ns;
};


struct polynomial_piecewise_1D {
    mxChar  *form_f;
    double  *breaks_f;
    double  *coefs_f;
    double  *pieces_f;
    double  *order_f;
    double  *dim_f;
    mxChar  *orient_f;
    mxChar  *form_dfdpsi;
    double  *breaks_dfdpsi;
    double  *coefs_dfdpsi;
    double  *pieces_dfdpsi;
    double  *order_dfdpsi;
    double  *dim_dfdpsi;
    mxChar  *orient_dfdpsi;
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
    mxChar  *form_da0dpsi;
    double  *breaks_da0dpsi;
    double  *coefs_da0dpsi;
    double  *pieces_da0dpsi;
    double  *order_da0dpsi;
    double  *dim_da0dpsi;
    mxChar  *orient_da0dpsi;
    mxChar  *form_an;
    double  *breaks_an;
    double  *coefs_an;
    double  *pieces_an;
    double  *order_an;
    double  *dim_an;
    mxChar  *orient_an;
    mxChar  *form_dandpsi;
    double  *breaks_dandpsi;
    double  *coefs_dandpsi;
    double  *pieces_dandpsi;
    double  *order_dandpsi;
    double  *dim_dandpsi;
    mxChar  *orient_dandpsi;
    mxChar  *form_bn;
    double  *breaks_bn;
    double  *coefs_bn;
    double  *pieces_bn;
    double  *order_bn;
    double  *dim_bn;
    mxChar  *orient_bn;
    mxChar  *form_dbndpsi;
    double  *breaks_dbndpsi;
    double  *coefs_dbndpsi;
    double  *pieces_dbndpsi;
    double  *order_dbndpsi;
    double  *dim_dbndpsi;
    mxChar  *orient_dbndpsi;
};

typedef struct polynomial_piecewise_1D pp_1D_format;
typedef struct polynomial_piecewise_2D pp_2D_format;
typedef struct rayparam rayparam_format;
typedef struct equilparam equilparam_format;
typedef struct susceptibilitytensor susceptibilitytensor_format;
typedef struct refractiveindex refractiveindex_format;
typedef struct raymagnetic raymagnetic_format;

void ppval_1D();
void ppval_2D();
void ray();
void rayindex();
susceptibilitytensor_format susceptibility();
susceptibilitytensor_format coldtensor();
equilparam_format load_equil_param();
rayparam_format load_ray_param();
pp_1D_format load_equil_1D();
pp_2D_format load_equil_2D();

/* Input Arguments */

#define RAYPARAM_IN  prhs[0]
#define EQUIL_IN     prhs[1]
#define Y0_IN    prhs[2]


/* Output Arguments */

#define T_OUT   plhs[0]
#define Y_OUT   plhs[1]


#define max(A, B)   ((A) > (B) ? (A) : (B))
#define min(A, B)   ((A) < (B) ? (A) : (B))
#define absx(A)     ((A) >= 0 ? (A) : -(A))

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
    static double powr = 1.0/5.0;
    
    double zZi,zmi;  
    pp_1D_format Te_fit,ne_fit,zTi_fit,zni_fit;
    pp_2D_format BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit;
    rayparam_format rayparam;
    equilparam_format equilparam;
  
    double *Te,*dTedpsi,*ne,*dnedpsi,*zTi,*dzTidpsi,*zni,*dznidpsi; 
    double *BPHI,*dBPHIdpsi,*dBPHIdtheta;
    double *BP,*dBPdpsi,*dBPdtheta;
    double *R,*dRdpsi,*dRdtheta;
    double *Z,*dZdpsi,*dZdtheta;
    double *r,*drdpsi,*drdtheta;
    double *calpha,*dcalphadpsi,*dcalphadtheta;
    
    /* Check out the arguments */

    if (nrhs != 3) {
        mexErrMsgTxt("Wrong number of input arguments for raytracing_yp");
    } else if (nlhs != 2) {
        mexErrMsgTxt("Wrong number of output arguments for raytracing_yp");
    }
    
    if (!mxIsStruct(prhs[0])) mexErrMsgTxt("Input arguments must be structures");
    if (!mxIsStruct(prhs[1])) mexErrMsgTxt("Input arguments must be structures");

/*
* Get Input Arguments
*/
    rayparam = load_ray_param(RAYPARAM_IN);       
    equilparam = load_equil_param(EQUIL_IN);

    Te_fit = load_equil_1D(EQUIL_IN,"Te_fit");
    ne_fit = load_equil_1D(EQUIL_IN,"ne_fit");
    zTi_fit = load_equil_1D(EQUIL_IN,"zTi_fit"); 
    zni_fit = load_equil_1D(EQUIL_IN,"zni_fit");
    
    BPHI_fit = load_equil_2D(EQUIL_IN,"BPHI_fit");
    BP_fit = load_equil_2D(EQUIL_IN,"BP_fit");
    R_fit = load_equil_2D(EQUIL_IN,"R_fit");
    Z_fit = load_equil_2D(EQUIL_IN,"Z_fit");
    r_fit = load_equil_2D(EQUIL_IN,"r_fit");
    calpha_fit = load_equil_2D(EQUIL_IN,"calpha_fit");
    
/*    double complex z,zz,zz1,zz2;
    z = 3.0 + 4.0*I;
    zz = csin(z);
    zz1 = cexp(z);
    zz2 = 1/z;
    mexPrintf("zzr : %g\n",creal(zz));
    mexPrintf("zzi : %g\n",cimag(zz));
    mexPrintf("zz1r : %g\n",creal(zz1));
    mexPrintf("zz1i : %g\n",cimag(zz1));
    mexPrintf("zz2r : %g\n",creal(zz2));
    mexPrintf("zz2i : %g\n",cimag(zz2));
*/
    
    if (rayparam.testmode[0]) {// keep this section for tests if necessary
        mexPrintf("tol : %g\n",rayparam.tol[0]);
        mexPrintf("zZi(4) : %g\n",equilparam.zZi[3]);

        mexPrintf("Te_fit.coefs_f(1): %g\n",Te_fit.coefs_f[0]);
        mexPrintf("Te_fit.coefs_dfpsi(1): %g\n",Te_fit.coefs_dfdpsi[0]);
        mexPrintf("BPHI_fit.n: %g\n",BPHI_fit.n[0]);
        mexPrintf("BPHI_fit.coefs_bn(1): %g\n",BPHI_fit.coefs_bn[0]);
        mexPrintf("BPHI_fit.coefs_dbndpsi(1): %g\n",BPHI_fit.coefs_dbndpsi[0]);

        Te = mxCalloc(1,sizeof(double));
        dTedpsi = mxCalloc(1,sizeof(double));
        ppval_1D(Te_fit,0.25,Te,dTedpsi);
        mexPrintf("Te(0.25),dTedpsi(0.25): %g,%g\n",Te[0],dTedpsi[0]);    
        mxFree(Te);
        mxFree(dTedpsi);
        
        zni = mxCalloc(equilparam.ns[0],sizeof(double));
        dznidpsi = mxCalloc(equilparam.ns[0],sizeof(double));
        ppval_1D(zni_fit,0.25,zni,dznidpsi);
        mexPrintf("zni(2,0.25),dznidpsi(2,0.25): %g,%g\n",zni[1],dznidpsi[1]);
        mxFree(zni);
        mxFree(dznidpsi);
 
        BPHI = mxCalloc(1,sizeof(double));
        dBPHIdpsi = mxCalloc(1,sizeof(double));
        dBPHIdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(BPHI_fit,0.25,1.7,BPHI,dBPHIdpsi,dBPHIdtheta);
        mexPrintf("BPHI(0.25,1.7),dBPHIdpsi(0.25,1.7),dBPHIdtheta(0.25,1.7): %g,%g,%g\n",BPHI[0],dBPHIdpsi[0],dBPHIdtheta[0]);
        mxFree(BPHI);
        mxFree(dBPHIdpsi); 
        mxFree(dBPHIdtheta); 
    }
    
// Runge-Kutta part

    mxArray *T_TEMP,*Y_TEMP;
    mxArray *Y_OUT_TEMP1,*Y_OUT_TEMP2,*Y_OUT_TEMP3,*Y_OUT_TEMP4,*Y_OUT_TEMP5,*Y_OUT_TEMP6,*Y_OUT_TEMP7;
    mxArray *TEMPT,*TEMP0,*TEMP1,*TEMP2,*TEMP3,*TEMP4,*TEMP5,*TEMP6;

    double  inf_norm(double *y, unsigned int M);

    double  *tout,*yout; 
    double  *toutp,*youtp;
    double  *t,*y;
    double  *y0;

    register unsigned int   m,k,kk;
    unsigned int    M,K=0;

    double  ts;
    double s0[7];
    double  *s1,*s2,*s3,*s4,*s5,*s6;
    double  tau,delta,h,hmax,hmin;
    double  ymax;
    
    double  *ydel;
    
    double t1,t2,t3,psi1,psi2,psi3,theta1,theta2,theta3,phi1,phi2,phi3,kpsi1,kpsi2,kpsi3,m1,m2,m3,n1,n2,n3,omega1,omega2,omega3;
    double *tempt,*temp0,*temp1,*temp2,*temp3,*temp4,*temp5,*temp6;

    y0 = mxGetPr(Y0_IN);

    M = max(mxGetM(Y0_IN),mxGetN(Y0_IN));

    /*
     * Create and Initialize Return Arguments
     */

    t1 = rayparam.t0[0];
    
    psi1 = y0[0];
    theta1 = y0[1];
    phi1 = y0[2];
    kpsi1 = y0[3];
    m1 = y0[4];
    n1 = y0[5];
    omega1 = y0[6];

    /*
     * Create arguments for calling user function
     */

    T_TEMP = mxCreateDoubleMatrix(1, 1, mxREAL);
    Y_TEMP = mxCreateDoubleMatrix(mxGetM(Y0_IN),mxGetN(Y0_IN), mxREAL);
    Y_OUT_TEMP1 = mxCreateDoubleMatrix(mxGetM(Y0_IN),mxGetN(Y0_IN), mxREAL);
    Y_OUT_TEMP2 = mxCreateDoubleMatrix(mxGetM(Y0_IN),mxGetN(Y0_IN), mxREAL);
    Y_OUT_TEMP3 = mxCreateDoubleMatrix(mxGetM(Y0_IN),mxGetN(Y0_IN), mxREAL);
    Y_OUT_TEMP4 = mxCreateDoubleMatrix(mxGetM(Y0_IN),mxGetN(Y0_IN), mxREAL);
    Y_OUT_TEMP5 = mxCreateDoubleMatrix(mxGetM(Y0_IN),mxGetN(Y0_IN), mxREAL);
    Y_OUT_TEMP6 = mxCreateDoubleMatrix(mxGetM(Y0_IN),mxGetN(Y0_IN), mxREAL);
    Y_OUT_TEMP7 = mxCreateDoubleMatrix(mxGetM(Y0_IN),mxGetN(Y0_IN), mxREAL);
    TEMPT = mxCreateDoubleMatrix(rayparam.kmax[0],1, mxREAL);
    TEMP0 = mxCreateDoubleMatrix(rayparam.kmax[0],1, mxREAL);
    TEMP1 = mxCreateDoubleMatrix(rayparam.kmax[0],1, mxREAL);
    TEMP2 = mxCreateDoubleMatrix(rayparam.kmax[0],1, mxREAL);
    TEMP3 = mxCreateDoubleMatrix(rayparam.kmax[0],1, mxREAL);
    TEMP4 = mxCreateDoubleMatrix(rayparam.kmax[0],1, mxREAL);
    TEMP5 = mxCreateDoubleMatrix(rayparam.kmax[0],1, mxREAL);
    TEMP6 = mxCreateDoubleMatrix(rayparam.kmax[0],1, mxREAL);

    t = mxGetPr(T_TEMP);
    y = mxGetPr(Y_TEMP);
    
    tempt = mxGetPr(TEMPT);
    temp0 = mxGetPr(TEMP0); 
    temp1 = mxGetPr(TEMP1);
    temp2 = mxGetPr(TEMP2);
    temp3 = mxGetPr(TEMP3);
    temp4 = mxGetPr(TEMP4);
    temp5 = mxGetPr(TEMP5);
    temp6 = mxGetPr(TEMP6);

    /*
     * Create an array for ydel
     */

//  ydel = create_real_array(M);mexFile MatLab version 4.2c
    ydel = (double *) mxCalloc((M),sizeof(double));

    /*
     * Initialization
     */

    h = rayparam.dt0[0];

    k = 0;

    tempt[0] = t1;
    temp0[0] = psi1;
    temp1[0] = theta1;
    temp2[0] = phi1;
    temp3[0] = kpsi1;
    temp4[0] = m1;
    temp5[0] = n1;  
    temp6[0] = omega1;

    /*
     * The main loop
     */

    while ((t1 < rayparam.tfinal[0]) && (k < rayparam.kmax[0]-1)) {
        if ((t1 + h) > rayparam.tfinal[0]) {
            h = rayparam.tfinal[0] - t1;
        }

        /*
         * Compute the slopes
         */

        /* ts = t  and  s0 = y */

        ts = t1;
        s0[0] = psi1;
        s0[1] = theta1;
        s0[2] = phi1;
        s0[3] = kpsi1;
        s0[4] = m1;
        s0[5] = n1;
        s0[6] = omega1;

        for  (m = 0; m < M; m++) {
            y[m] = s0[m];
        }
        
        ray(mxGetPr(Y_OUT_TEMP1),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit); 
        s1 = mxGetPr(Y_OUT_TEMP1);


        /* s2 = feval(F, t+h*alpha(1), y+h*s1*beta(1,1), param); */

        *t = ts + h*alpha[0];
        for  (m = 0; m < M; m++) {
            y[m] = s0[m]+h*s1[m]*beta[0][0];
        }

        ray(mxGetPr(Y_OUT_TEMP2),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit);
        s2 = mxGetPr(Y_OUT_TEMP2);
        

        /* s3 = feval(F, t+h*alpha(2), y+h*[s1*beta(2,1)+s2*beta(2,2)], param); */

        *t = ts + h*alpha[1];
        for  (m = 0; m < M; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][1] + s2[m]*beta[1][1]);
        }

        ray(mxGetPr(Y_OUT_TEMP3),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit);
        s3 = mxGetPr(Y_OUT_TEMP3);
        

        /* s4 = feval(F, t+h*alpha(3), y+h*[s1*beta(3,1)+s2*beta(3,2)+...], param); */

        *t = ts + h*alpha[2];
        for  (m = 0; m < M; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][2] + s2[m]*beta[1][2]
                    +s3[m]*beta[2][2]);
        }

        ray(mxGetPr(Y_OUT_TEMP4),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit);
        s4 = mxGetPr(Y_OUT_TEMP4);

        /* s5 = feval(F, t+h*alpha(4), y+h*[s1*beta(4,1)+s2*beta(4,2)+...], param); */

        *t = ts + h*alpha[3];
        for  (m = 0; m < M; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][3] + s2[m]*beta[1][3]
                    +s3[m]*beta[2][3] + s4[m]*beta[3][3]);
        }

        ray(mxGetPr(Y_OUT_TEMP5),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit);
        s5 = mxGetPr(Y_OUT_TEMP5);
        

        /* s6 = feval(F, t+h*alpha(5), y+h*[s1*beta(5,1)+s2*beta(5,2)+...], param); */

        *t = ts + h*alpha[4];
        for  (m = 0; m < M; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][4] + s2[m]*beta[1][4]
                    +s3[m]*beta[2][4] + s4[m]*beta[3][4]
                     +s5[m]*beta[4][4]);
        }

        ray(mxGetPr(Y_OUT_TEMP6),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit);
        s6 = mxGetPr(Y_OUT_TEMP6);

        

        /*
         * Estimate the error and the acceptable error
         */

        for  (m = 0; m < M; m++) {
            ydel[m] = h*(s1[m]*gama[0][1] + s2[m]*gama[1][1]
                    + s3[m]*gama[2][1] + s4[m]*gama[3][1]
                    + s5[m]*gama[4][1] + s6[m]*gama[5][1]);
        }

        delta = inf_norm(ydel,M);
        ymax = inf_norm(s0,M);
        tau = rayparam.tol[0]*max(ymax,1.0);        
        

        /*
         * Update the solution only if the error is acceptable
         */
         
         printf("delta,tau=%f,%f\r",delta,tau);

        if (delta <= tau) {
        
            
            t2 = t1 + h;
            psi2 = psi1 + h*(s1[0]*gama[0][0] + s2[0]*gama[1][0]
                     + s3[0]*gama[2][0] + s4[0]*gama[3][0]
                     + s5[0]*gama[4][0] + s6[0]*gama[5][0]);
            theta2 = theta1 + h*(s1[1]*gama[0][0] + s2[1]*gama[1][0]
                     + s3[1]*gama[2][0] + s4[1]*gama[3][0]
                     + s5[1]*gama[4][0] + s6[1]*gama[5][0]);
            phi2 = phi1 + h*(s1[2]*gama[0][0] + s2[2]*gama[1][0]
                     + s3[2]*gama[2][0] + s4[2]*gama[3][0]
                     + s5[2]*gama[4][0] + s6[2]*gama[5][0]);
            kpsi2 = kpsi1 + h*(s1[3]*gama[0][0] + s2[3]*gama[1][0]
                     + s3[3]*gama[2][0] + s4[3]*gama[3][0]
                     + s5[3]*gama[4][0] + s6[3]*gama[5][0]);
            m2 = m1 + h*(s1[4]*gama[0][0] + s2[4]*gama[1][0]
                     + s3[4]*gama[2][0] + s4[4]*gama[3][0]
                     + s5[4]*gama[4][0] + s6[4]*gama[5][0]);
            n2 = n1;
            omega2 = omega1;

              if ((psi1>0) && (psi2<0)) {
                psi2 = -psi2;
                theta2 = theta2 + 3.14159265358979;
                kpsi2 = -kpsi2;
                m2 = m2;
                n2 = n2;
                omega2 = omega2;
              }

            if (absx(psi2-psi3) >= rayparam.dpsi[0]) {
                K = k+1;
                tempt[K] = t1;
                temp0[K] = psi2;
                temp1[K] = theta2;
                temp2[K] = phi2;
                temp3[K] = kpsi2;
                temp4[K] = m2;
                temp5[K] = n2;
                temp6[K] = omega2;
                
                t3 = t1;
                psi3 = psi2;
                theta3 = theta2;
                phi3 = phi2;
                kpsi3 = kpsi2;
                m3 = m2;
                n3 = n2;
                omega3 = omega2;

                k++;
            }
            
            t1 = t2;
            psi1 = psi2;
            theta1 = theta2;
            phi1 = phi2;
            kpsi1 = kpsi2;
            m1 = m2;
            n1 = n2;
            omega1 = omega2;
        }
        

        /*
         * Update the step size
         */

        if (delta) {
                h = 0.8*h*pow(tau/delta,powr);
        }
    }

    if (t1 < rayparam.tfinal[0]) {
        printf("Singularity likely at t = %f or matrix full\n",t1);
    }
/*  printf("k = %ld\r",k);*/


    /* Create final matrix for transferring data to MatLab */
    
    T_OUT = mxCreateDoubleMatrix(1,K,mxREAL);
    Y_OUT = mxCreateDoubleMatrix(m,K,mxREAL);
    tout = mxGetPr(T_OUT);
    yout = mxGetPr(Y_OUT);  
    for (kk = 0;kk < K; kk++) {
        tout[kk] = tempt[kk];
        yout[kk*M+0] = temp0[kk];
        yout[kk*M+1] = temp1[kk];
        yout[kk*M+2] = temp2[kk];
        yout[kk*M+3] = temp3[kk];
        yout[kk*M+4] = temp4[kk];
        yout[kk*M+5] = temp5[kk];
        yout[kk*M+6] = temp6[kk];
    }

    /*
     * Transpose the outputs
     */

    m = mxGetM(T_OUT);
    mxSetM(T_OUT,mxGetN(T_OUT));
    mxSetN(T_OUT,m);

    Y_TEMP = Y_OUT;
    mexCallMATLAB(1,&Y_OUT,1,&Y_TEMP,".'");

    mxDestroyArray(T_TEMP);
    mxDestroyArray(Y_TEMP);
    mxDestroyArray(Y_OUT_TEMP1);
    mxDestroyArray(Y_OUT_TEMP2);
    mxDestroyArray(Y_OUT_TEMP3);
    mxDestroyArray(Y_OUT_TEMP4);
    mxDestroyArray(Y_OUT_TEMP5);
    mxDestroyArray(Y_OUT_TEMP6);    
    mxDestroyArray(Y_OUT_TEMP7);    
    mxDestroyArray(TEMPT);
    mxDestroyArray(TEMP0);
    mxDestroyArray(TEMP1);
    mxDestroyArray(TEMP2);
    mxDestroyArray(TEMP3);
    mxDestroyArray(TEMP4);
    mxDestroyArray(TEMP5);
    mxDestroyArray(TEMP6);


    mxFree(ydel);

}


rayparam_format load_ray_param(structure_name)
mxArray *structure_name;
{
    rayparam_format data;
       
    data.testmode = mxGetData(mxGetField(structure_name, 0, "testmode"));
    data.t0 = mxGetData(mxGetField(structure_name, 0, "t0"));
    data.tfinal = mxGetData(mxGetField(structure_name, 0, "tfinal"));
    data.dt0 = mxGetData(mxGetField(structure_name, 0, "dt0"));
    data.dpsi = mxGetData(mxGetField(structure_name, 0, "dpsi"));
    data.tol = mxGetData(mxGetField(structure_name, 0, "tol"));   
    data.kmax = mxGetData(mxGetField(structure_name, 0, "kmax"));
    data.tensortype = mxGetData(mxGetField(structure_name, 0, "tensortype")); 
    
    return(data);
}

equilparam_format load_equil_param(structure_name)
mxArray *structure_name;
{
    equilparam_format data;
   
    data.zZi= mxGetData(mxGetField(structure_name, 0, "zZi"));
    data.zmi = mxGetData(mxGetField(structure_name, 0, "zmi"));
    data.ns = mxCalloc(1,sizeof(int));
    data.ns[0] = max(mxGetM(mxGetField(structure_name, 0, "zmi")),mxGetN(mxGetField(structure_name, 0, "zmi")));
    
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
        fit.form_dfdpsi = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dfdpsi = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dfdpsi = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dfdpsi = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dfdpsi = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dfdpsi = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dfdpsi = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
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
        fit.form_da0dpsi = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_da0dpsi = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_da0dpsi = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_da0dpsi = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_da0dpsi = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_da0dpsi = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_da0dpsi = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
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
        fit.form_dandpsi = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dandpsi = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dandpsi = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dandpsi = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dandpsi = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dandpsi = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dandpsi = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
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
        fit.form_dbndpsi = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dbndpsi = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dbndpsi = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dbndpsi = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dbndpsi = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dbndpsi = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dbndpsi = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    return(fit);  
}


void ppval_1D(pp_1D_format in, double x,double y[],double dydx[])
{
    register int j,k;
    int i0,i1,i2,i3;
 
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
//                    mexPrintf("kk,y: %d,%g\n",k,y[k-1]); 
                }
            }
        }
    }   
    
    for (j = 0;j < (int)in.pieces_dfdpsi[0];j++) {
        if ((x>=in.breaks_dfdpsi[j]) && (x<=in.breaks_dfdpsi[j+1])) {
            for (k = 1;k <= (int)in.dim_dfdpsi[0]; k++) {
                if ((int)in.order_dfdpsi[0] == 2) {
                    i0 = k-1+j*(int)in.dim_dfdpsi[0] + 0*(int)in.pieces_dfdpsi[0]*(int)in.dim_dfdpsi[0];
                    i1 = k-1+j*(int)in.dim_dfdpsi[0] + 1*(int)in.pieces_dfdpsi[0]*(int)in.dim_dfdpsi[0];
                    dydx[k-1] = in.coefs_dfdpsi[i0]*(x - in.breaks_dfdpsi[j]) + in.coefs_dfdpsi[i1];
                } else if ((int)in.order_dfdpsi[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dfdpsi[0] + 0*(int)in.pieces_dfdpsi[0]*(int)in.dim_dfdpsi[0];
                    i1 = k-1+j*(int)in.dim_dfdpsi[0] + 1*(int)in.pieces_dfdpsi[0]*(int)in.dim_dfdpsi[0];
                    i2 = k-1+j*(int)in.dim_dfdpsi[0] + 2*(int)in.pieces_dfdpsi[0]*(int)in.dim_dfdpsi[0];                    
                    dydx[k-1] = in.coefs_dfdpsi[i0]*pow((x - in.breaks_dfdpsi[j]),2) + in.coefs_dfdpsi[i1]*(x - in.breaks_dfdpsi[j]) + in.coefs_dfdpsi[i2];
//                    mexPrintf("k,dydx: %d%g\n",k,dydx[k-1]); 
                } else if ((int)in.order_dfdpsi[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dfdpsi[0] + 0*(int)in.pieces_dfdpsi[0]*(int)in.dim_dfdpsi[0];
                    i1 = k-1+j*(int)in.dim_dfdpsi[0] + 1*(int)in.pieces_dfdpsi[0]*(int)in.dim_dfdpsi[0];
                    i2 = k-1+j*(int)in.dim_dfdpsi[0] + 2*(int)in.pieces_dfdpsi[0]*(int)in.dim_dfdpsi[0];
                    i3 = k-1+j*(int)in.dim_dfdpsi[0] + 3*(int)in.pieces_dfdpsi[0]*(int)in.dim_dfdpsi[0];
                    dydx[k-1] = in.coefs_dfdpsi[i0]*pow((x - in.breaks_dfdpsi[j]),3) + in.coefs_dfdpsi[i1]*pow((x - in.breaks_dfdpsi[j]),2) + in.coefs_dfdpsi[i2]*(x - in.breaks_dfdpsi[j]) + in.coefs_dfdpsi[i3];
                }
            }
        }
    }   
}




void ppval_2D(pp_2D_format in, double x, double t, double* y, double* dydx, double* dydt)
{
    register int j,k;
    int i0,i1,i2,i3;
    double *a0,*an,*bn,*da0dx,*dandx,*dbndx;
    
    a0 = mxCalloc((int)in.dim_a0[0],sizeof(double));
    da0dx = mxCalloc((int)in.dim_da0dpsi[0],sizeof(double));
    an = mxCalloc((int)in.dim_an[0],sizeof(double));
    dandx = mxCalloc((int)in.dim_dandpsi[0],sizeof(double));
    bn = mxCalloc((int)in.dim_bn[0],sizeof(double));
    dbndx = mxCalloc((int)in.dim_dbndpsi[0],sizeof(double));

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
    
    for (j = 0;j < (int)in.pieces_da0dpsi[0];j++) {
        if ((x>=in.breaks_da0dpsi[j]) && (x<=in.breaks_da0dpsi[j+1])) {
            for (k = 1;k <= (int)in.dim_da0dpsi[0]; k++) {
                if ((int)in.order_da0dpsi[0] == 2) {
                    i0 = k-1+j*(int)in.dim_da0dpsi[0] + 0*(int)in.pieces_da0dpsi[0]*(int)in.dim_da0dpsi[0];
                    i1 = k-1+j*(int)in.dim_da0dpsi[0] + 1*(int)in.pieces_da0dpsi[0]*(int)in.dim_da0dpsi[0];
                    da0dx[k-1] = in.coefs_da0dpsi[i0]*(x - in.breaks_da0dpsi[j]) + in.coefs_da0dpsi[i1];
                } else if ((int)in.order_da0dpsi[0] == 3) {
                    i0 = k-1+j*(int)in.dim_da0dpsi[0] + 0*(int)in.pieces_da0dpsi[0]*(int)in.dim_da0dpsi[0];
                    i1 = k-1+j*(int)in.dim_da0dpsi[0] + 1*(int)in.pieces_da0dpsi[0]*(int)in.dim_da0dpsi[0];
                    i2 = k-1+j*(int)in.dim_da0dpsi[0] + 2*(int)in.pieces_da0dpsi[0]*(int)in.dim_da0dpsi[0];                    
                    da0dx[k-1] = in.coefs_da0dpsi[i0]*pow((x - in.breaks_da0dpsi[j]),2) + in.coefs_da0dpsi[i1]*(x - in.breaks_da0dpsi[j]) + in.coefs_da0dpsi[i2];
                } else if ((int)in.order_da0dpsi[0] == 4) {
                    i0 = k-1+j*(int)in.dim_da0dpsi[0] + 0*(int)in.pieces_da0dpsi[0]*(int)in.dim_da0dpsi[0];
                    i1 = k-1+j*(int)in.dim_da0dpsi[0] + 1*(int)in.pieces_da0dpsi[0]*(int)in.dim_da0dpsi[0];
                    i2 = k-1+j*(int)in.dim_da0dpsi[0] + 2*(int)in.pieces_da0dpsi[0]*(int)in.dim_da0dpsi[0];
                    i3 = k-1+j*(int)in.dim_da0dpsi[0] + 3*(int)in.pieces_da0dpsi[0]*(int)in.dim_da0dpsi[0];
                    da0dx[k-1] = in.coefs_da0dpsi[i0]*pow((x - in.breaks_da0dpsi[j]),3) + in.coefs_da0dpsi[i1]*pow((x - in.breaks_da0dpsi[j]),2) + in.coefs_da0dpsi[i2]*(x - in.breaks_da0dpsi[j]) + in.coefs_da0dpsi[i3];
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
    
    for (j = 0;j < (int)in.pieces_dandpsi[0];j++) {
        if ((x>=in.breaks_dandpsi[j]) && (x<=in.breaks_dandpsi[j+1])) {
            for (k = 1;k <= (int)in.dim_dandpsi[0]; k++) {
                if ((int)in.order_dandpsi[0] == 2) {
                    i0 = k-1+j*(int)in.dim_dandpsi[0] + 0*(int)in.pieces_dandpsi[0]*(int)in.dim_dandpsi[0];
                    i1 = k-1+j*(int)in.dim_dandpsi[0] + 1*(int)in.pieces_dandpsi[0]*(int)in.dim_dandpsi[0];
                    dandx[k-1] = in.coefs_dandpsi[i0]*(x - in.breaks_dandpsi[j]) + in.coefs_dandpsi[i1];
                } else if ((int)in.order_dandpsi[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dandpsi[0] + 0*(int)in.pieces_dandpsi[0]*(int)in.dim_dandpsi[0];
                    i1 = k-1+j*(int)in.dim_dandpsi[0] + 1*(int)in.pieces_dandpsi[0]*(int)in.dim_dandpsi[0];
                    i2 = k-1+j*(int)in.dim_dandpsi[0] + 2*(int)in.pieces_dandpsi[0]*(int)in.dim_dandpsi[0];                    
                    dandx[k-1] = in.coefs_dandpsi[i0]*pow((x - in.breaks_dandpsi[j]),2) + in.coefs_dandpsi[i1]*(x - in.breaks_dandpsi[j]) + in.coefs_dandpsi[i2];
                } else if ((int)in.order_dandpsi[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dandpsi[0] + 0*(int)in.pieces_dandpsi[0]*(int)in.dim_dandpsi[0];
                    i1 = k-1+j*(int)in.dim_dandpsi[0] + 1*(int)in.pieces_dandpsi[0]*(int)in.dim_dandpsi[0];
                    i2 = k-1+j*(int)in.dim_dandpsi[0] + 2*(int)in.pieces_dandpsi[0]*(int)in.dim_dandpsi[0];
                    i3 = k-1+j*(int)in.dim_dandpsi[0] + 3*(int)in.pieces_dandpsi[0]*(int)in.dim_dandpsi[0];
                    dandx[k-1] = in.coefs_dandpsi[i0]*pow((x - in.breaks_dandpsi[j]),3) + in.coefs_dandpsi[i1]*pow((x - in.breaks_dandpsi[j]),2) + in.coefs_dandpsi[i2]*(x - in.breaks_dandpsi[j]) + in.coefs_dandpsi[i3];
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
    
    for (j = 0;j < (int)in.pieces_dbndpsi[0];j++) {
        if ((x>=in.breaks_dbndpsi[j]) && (x<=in.breaks_dbndpsi[j+1])) {
            for (k = 1;k <= (int)in.dim_dbndpsi[0]; k++) {
                if ((int)in.order_dbndpsi[0] == 2) {
                    i0 = k-1+j*(int)in.dim_dbndpsi[0] + 0*(int)in.pieces_dbndpsi[0]*(int)in.dim_dbndpsi[0];
                    i1 = k-1+j*(int)in.dim_dbndpsi[0] + 1*(int)in.pieces_dbndpsi[0]*(int)in.dim_dbndpsi[0];
                    dbndx[k-1] = in.coefs_dbndpsi[i0]*(x - in.breaks_dbndpsi[j]) + in.coefs_dbndpsi[i1];
                } else if ((int)in.order_dbndpsi[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dbndpsi[0] + 0*(int)in.pieces_dbndpsi[0]*(int)in.dim_dbndpsi[0];
                    i1 = k-1+j*(int)in.dim_dbndpsi[0] + 1*(int)in.pieces_dbndpsi[0]*(int)in.dim_dbndpsi[0];
                    i2 = k-1+j*(int)in.dim_dbndpsi[0] + 2*(int)in.pieces_dbndpsi[0]*(int)in.dim_dbndpsi[0];                    
                    dbndx[k-1] = in.coefs_dbndpsi[i0]*pow((x - in.breaks_dbndpsi[j]),2) + in.coefs_dbndpsi[i1]*(x - in.breaks_dbndpsi[j]) + in.coefs_dbndpsi[i2];
                } else if ((int)in.order_dbndpsi[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dbndpsi[0] + 0*(int)in.pieces_dbndpsi[0]*(int)in.dim_dbndpsi[0];
                    i1 = k-1+j*(int)in.dim_dbndpsi[0] + 1*(int)in.pieces_dbndpsi[0]*(int)in.dim_dbndpsi[0];
                    i2 = k-1+j*(int)in.dim_dbndpsi[0] + 2*(int)in.pieces_dbndpsi[0]*(int)in.dim_dbndpsi[0];
                    i3 = k-1+j*(int)in.dim_dbndpsi[0] + 3*(int)in.pieces_dbndpsi[0]*(int)in.dim_dbndpsi[0];
                    dbndx[k-1] = in.coefs_dbndpsi[i0]*pow((x - in.breaks_dbndpsi[j]),3) + in.coefs_dbndpsi[i1]*pow((x - in.breaks_dbndpsi[j]),2) + in.coefs_dbndpsi[i2]*(x - in.breaks_dbndpsi[j]) + in.coefs_dbndpsi[i3];
                }
            }
        }
    }   
    
    y[0] = 0.0;
    dydx[0] = 0.0;
    dydt[0] = 0.0;
    
    for (k = 1;k <= (int)in.dim_dbndpsi[0]; k++) {
      y[0] = y[0] + an[k-1]*cos(k*t) + bn[k-1]*sin(k*t);
      dydx[0] = dydx[0] + dandx[k-1]*cos(k*t) + dbndx[k-1]*sin(k*t);
      dydt[0] = dydt[0] - k*an[k-1]*sin(k*t) + k*bn[k-1]*cos(k*t);
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

double inf_norm(y,M)
double  y[];
unsigned int M;
{
    register unsigned int m;
    double  temp_max,yabs;

    temp_max = absx(y[0]);

    for (m = 1; m < M; m++) {
        yabs = absx(y[m]);
        temp_max = max(temp_max,yabs);
    }

    return(temp_max);
}

/*General coordinate time evolution dY/dt with Y=[psi,theta,phi,kpsi,m,n,omega]*/


void ray(Ydot,Y,param,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit)
double Y[];
double Ydot[];
rayparam_format param;
equilparam_format equilparam;
pp_1D_format Te_fit;
pp_1D_format ne_fit;
pp_1D_format zTi_fit;
pp_1D_format zni_fit;
pp_2D_format BPHI_fit;
pp_2D_format BP_fit;
pp_2D_format R_fit;
pp_2D_format Z_fit;
pp_2D_format r_fit;
pp_2D_format calpha_fit;
{
double qe = 1.602176462e-19;//Absolute value of the electron charge (C)
double me = 9.10938188e-31;//Electron rest mass (Kg)
double mp = 1.67262158e-27;//Proton rest mass (Kg)
double epsi0 = 8.854187818e-12;//Free space permittivity (F/m)
double mu0 = 12.566370614e-7;//Free space permeability (F/m)
double clum = 299792458;//Speed of light (m/s)
double mc2 = 510.998902;//Electron energy rest mass (keV)

double D[43],dDdw[43],dDdpsi[43],dDdtheta[43],dDdkpsi[43],dDdm[43],dDdn[43];
double Dtot=0,dDtotdw=0,dDtotdpsi=0,dDtotdtheta=0,dDtotdkpsi=0,dDtotdm=0,dDtotdn=0;

double dYdY[8][8];

double *BPHI,*dBPHIdx,*BP,*dBPdx,*B,*dBdx;
double *R,*dRdx,*r,*drdx;
double *calpha,*dcalphadx,*salpha,*dsalphadx;
double *Te,*dTedx,*ne,*dnedx;
double *zTi,**dzTidx,*zni,**dznidx;
double *wcn,*wpn2,*betath;
double **dwcndx,**dwpn2dx,**dbetathdx;

double complex *Npar,*Nperp,*dNpardx,*dNperpdx;


/*double Nperp4,Nperp3,Nperp2,Nperp;
double Npar4,Npar3,Npar2,Npar;
double Xxx,Xxy,Xxz,Xyy,Xyz,Xzz;
double Xxx2,Xxy2,Xxz2,Xyy2,Xyz2,Xzz2;
double dNperpdpsi,dNpardpsi,dXxxdpsi,dXxydpsi,dXxzdpsi,dXyydpsi,dXyzdpsi,dXzzdpsi;
double dNperpdtheta,dNpardtheta,dXxxdtheta,dXxydtheta,dXxzdtheta,dXyydtheta,dXyzdtheta,dXzzdtheta;
double dNperpdkpsi,dNpardkpsi,dXxxdkpsi,dXxydkpsi,dXxzdkpsi,dXyydkpsi,dXyzdkpsi,dXzzdkpsi;
double dNperpdm,dNpardm,dXxxdm,dXxydm,dXxzdm,dXyydm,dXyzdm,dXzzdm;
double dNperpdn,dNpardn,dXxxdn,dXxydn,dXxzdn,dXyydn,dXyzdn,dXzzdn;*/

raymagnetic_format raymagnetic;
susceptibilitytensor_format X;

register int i,j,is;

// Memory allocation

Te = mxCalloc(1,sizeof(double));
ne = mxCalloc(1,sizeof(double));
zTi = mxCalloc(equilparam.ns[0],sizeof(double));
zni = mxCalloc(equilparam.ns[0],sizeof(double));

dTedx = mxCalloc(8,sizeof(double));
dnedx = mxCalloc(8,sizeof(double));

dzTidx = mxCalloc(8,sizeof(double *));
dznidx = mxCalloc(8,sizeof(double *));
dzTidx[0] = mxCalloc(equilparam.ns[0]*8,sizeof(double));//full block memory allocation
dznidx[0] = mxCalloc(equilparam.ns[0]*8,sizeof(double));
for (i=1;i<8;i++) {
    dzTidx[i] = dzTidx[0] + i*equilparam.ns[0];//contiguous memory allocation
    dznidx[i] = dznidx[0] + i*equilparam.ns[0];
}

raymagnetic.r = mxCalloc(1,sizeof(double));
raymagnetic.R = mxCalloc(1,sizeof(double));
raymagnetic.salpha = mxCalloc(1,sizeof(double));
raymagnetic.calpha = mxCalloc(1,sizeof(double));
raymagnetic.BP = mxCalloc(1,sizeof(double));
raymagnetic.BPHI = mxCalloc(1,sizeof(double));
raymagnetic.B = mxCalloc(1,sizeof(double));

raymagnetic.drdx = mxCalloc(8,sizeof(double));
raymagnetic.dRdx = mxCalloc(8,sizeof(double));
raymagnetic.dsalphadx = mxCalloc(8,sizeof(double));
raymagnetic.dcalphadx = mxCalloc(8,sizeof(double));
raymagnetic.dBPdx = mxCalloc(8,sizeof(double));
raymagnetic.dBPHIdx = mxCalloc(8,sizeof(double));
raymagnetic.dBdx = mxCalloc(8,sizeof(double));

wcn = mxCalloc(equilparam.ns[0]+1,sizeof(double));
wpn2 = mxCalloc(equilparam.ns[0]+1,sizeof(double));
betath = mxCalloc(equilparam.ns[0]+1,sizeof(double));

dwcndx = mxCalloc(8,sizeof(double *));
dwpn2dx = mxCalloc(8,sizeof(double *));
dbetathdx = mxCalloc(8,sizeof(double *));
dwcndx[0] = mxCalloc((equilparam.ns[0]+1)*8,sizeof(double));//full block memory allocation
dwpn2dx[0] = mxCalloc((equilparam.ns[0]+1)*8,sizeof(double));
dbetathdx[0] = mxCalloc((equilparam.ns[0]+1)*8,sizeof(double));
for (i=1;i<8;i++) {
    dwcndx[i] = dwcndx[0] + i*(equilparam.ns[0]+1);//contiguous memory allocation
    dwpn2dx[i] = dwpn2dx[0] + i*(equilparam.ns[0]+1);
    dbetathdx[i] = dbetathdx[0] + i*(equilparam.ns[0]+1);
}

Npar = mxCalloc(1,sizeof(double complex));
Nperp = mxCalloc(1,sizeof(double complex));
dNpardx = mxCalloc(8,sizeof(double complex));
dNperpdx = mxCalloc(8,sizeof(double complex));

// Equilibrium interpolation

ppval_1D(Te_fit,Y[0],&Te[0],&dTedx[0]);
ppval_1D(ne_fit,Y[0],&ne[0],&dnedx[0]);
ppval_1D(zTi_fit,Y[0],zTi,dzTidx[0]);
ppval_1D(zni_fit,Y[0],zni,dznidx[0]);

ppval_2D(BPHI_fit,Y[0],Y[1],&raymagnetic.BPHI[0],&raymagnetic.dBPHIdx[0],&raymagnetic.dBPHIdx[1]);
ppval_2D(BP_fit,Y[0],Y[1],&raymagnetic.BP[0],&raymagnetic.dBPdx[0],&raymagnetic.dBPdx[1]);
ppval_2D(R_fit,Y[0],Y[1],&raymagnetic.R[0],&raymagnetic.dRdx[0],&raymagnetic.dRdx[1]);
ppval_2D(r_fit,Y[0],Y[1],&raymagnetic.r[0],&raymagnetic.drdx[0],&raymagnetic.drdx[1]);
ppval_2D(calpha_fit,Y[0],Y[1],&raymagnetic.calpha[0],&raymagnetic.dcalphadx[0],&raymagnetic.dcalphadx[1]);

raymagnetic.salpha[0] = sqrt(1-raymagnetic.calpha[0]*raymagnetic.calpha[0]);
raymagnetic.dsalphadx[0] = - raymagnetic.dcalphadx[0]*raymagnetic.calpha[0]/raymagnetic.salpha[0];// calpha may never been zero
raymagnetic.dsalphadx[1] = - raymagnetic.dcalphadx[1]*raymagnetic.calpha[0]/raymagnetic.salpha[0];// calpha may never been zero

raymagnetic.B[0] = sqrt(pow(raymagnetic.BPHI[0],2)+pow(raymagnetic.BP[0],2));// total magnetic field
raymagnetic.dBdx[0] = (raymagnetic.BP[0]*raymagnetic.dBPdx[0]+raymagnetic.BPHI[0]*raymagnetic.dBPHIdx[0])/raymagnetic.B[0];
raymagnetic.dBdx[1] = (raymagnetic.BP[0]*raymagnetic.dBPdx[1]+raymagnetic.BPHI[0]*raymagnetic.dBPHIdx[1])/raymagnetic.B[0];


// Normalized parameters

wcn[0] = qe*raymagnetic.B[0]/me/Y[6];//electrons
dwcndx[0][0] = qe*raymagnetic.dBdx[0]/me/Y[6];
dwcndx[0][1] = qe*raymagnetic.dBdx[1]/me/Y[6];
wpn2[0] = qe*qe*ne[0]/epsi0/me/Y[6]/Y[6];//electrons
dwpn2dx[0][0] = qe*qe*dnedx[0]/epsi0/me/Y[6]/Y[6];
betath[0] = sqrt(Te[0]/mc2);
dbetathdx[0][0] = dTedx[0]/betath[0]/2.0;
//mexPrintf("B,ne,Te,wlh:%g,%g,%g,%g\n",raymagnetic.B[0],ne[0],Te[0],Y[6]);
//mexPrintf("wcn,wpn2,betath:%g,%g,%g\n",wcn[0],wpn2[0],betath[0]);
//mexPrintf("dwcndpsi,dwcndtheta:%g,%g\n",dwcndx[0][0],dwcndx[0][1]);
//mexPrintf("dwpn2dpsi,dwpn2dtheta:%g,%g\n",dwpn2dx[0][0],dwpn2dx[0][1]);

for (is = 1;is < equilparam.ns[0]+1; is++) {
    wcn[is] = qe*equilparam.zZi[is-1]*raymagnetic.B[0]/equilparam.zmi[is-1]/mp/Y[6];//ions
    dwcndx[is][0] = qe*equilparam.zZi[is-1]*raymagnetic.dBdx[0]/equilparam.zmi[is-1]/mp/Y[6];
    dwcndx[is][1] = qe*equilparam.zZi[is-1]*raymagnetic.dBdx[1]/equilparam.zmi[is-1]/mp/Y[6];    
    wpn2[is] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*zni[is-1]/epsi0/equilparam.zmi[is-1]/mp/Y[6]/Y[6];//ions
    dwpn2dx[is][0] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*dznidx[is-1][0]/epsi0/equilparam.zmi[is-1]/mp/Y[6]/Y[6];        
    betath[is] = sqrt(zTi[is-1]*me/equilparam.zmi[is-1]/mp/mc2);
    dbetathdx[is][0] = dzTidx[is-1][0]/betath[is]/2.0;
    //mexPrintf("is,wcn,wpn2,betath:%d,%g,%g,%g\n",is,wcn[is],wpn2[is],betath[is]);
    //mexPrintf("is,dwcndpsi,dwcndtheta:%d,%g,%g\n",is,dwcndx[is][0],dwcndx[is][1]);
    //mexPrintf("is,dwpn2dpsi,dwpn2dtheta:%d,%g,%g\n",is,dwpn2dx[is][0],dwpn2dx[is][1]);

}

//Covariant matrix

for (i=0;i<8;i++) {
    for (j=0;j<8;j++) {
        if (i==j) {
            dYdY[i][j] = 1.0;
        } else {
            dYdY[i][j] = 0.0;
        }
    }
}

// Refractive index calculation

rayindex(clum,Y,dYdY,raymagnetic,Npar,Nperp,dNpardx,dNperpdx);
//mexPrintf("r,R,BP,kpsi,sina,cosa,B,BPHI:%g,%g,%g,%g,%g,%g,%g,%g\n",raymagnetic.r[0],raymagnetic.R[0],raymagnetic.BP[0],Y[3],raymagnetic.salpha[0],raymagnetic.calpha[0],raymagnetic.B[0],raymagnetic.BPHI[0]);
//mexPrintf("Npar,Nperp,dNpardm,dNperpdm:%g,%g,%g,%g\n",Npar[0],Nperp[0],dNpardx[4],dNperpdx[4]);


// Susceptibility tensor 


//X = susceptibility(param.tensortype[0],equilparam.ns[0],N,wcn,dwcndpsi,dwcndtheta,wpn,dwpndpsi,betath,dbetathdpsi);


/*
Nperp4 = pow(N.Nperp[0],4);
Nperp3 = pow(N.Nperp[0],3);
Nperp2 = pow(N.Nperp[0],2);
Nperp = N.Nperp[0];
Npar4 = pow(N.Npar[0],4);
Npar3 = pow(N.Npar[0],3);
Npar2 = pow(N.Npar[0],2);
Npar = N.Npar[0];
Xxx = X.Xxx[0];
Xxy = X.Xxy[0];
Xxz = X.Xxz[0];
Xyy = X.Xyy[0];
Xyz = X.Xyz[0];
Xzz = X.Xzz[0];
Xxx2 = pow(X.Xxx[0],2);
Xxy2 = pow(X.Xxy[0],2);
Xxz2 = pow(X.Xxz[0],2);
Xyy2 = pow(X.Xyy[0],2);
Xyz2 = pow(X.Xyz[0],2);
Xzz2 = pow(X.Xzz[0],2);




D[0] = Nperp4;
D[1] = Xxx*Nperp4;
D[2] = 2*Npar*Xxz*Nperp3;
D[3] = Npar2*Xxx*Nperp3;
D[4] = Npar2*Xzz*Nperp3;
D[5] = 2*Npar2*Nperp2;
D[6] = -2*Xxx*Nperp2;
D[7] = -Xyy*Nperp2;
D[8] = -Xzz*Nperp2;
D[9] = -Xxx*Xzz*Nperp2;
D[10] = Xxz2*Nperp2;
D[11] = -Xxx*Xyy*Nperp2;
D[12] = -Xxy2*Nperp2;
D[13] = -2*Nperp2;
D[14] = -2*Npar*Xyy*Xxx*Nperp;
D[15] = 2*Npar*Xxy*Xyz*Nperp;
D[16] = -2*Npar*Xxz*Nperp;
D[17] = 2*Npar3*Xxz*Nperp;
D[18] = 1;
D[19] = Npar4*Xzz;
D[20] = Npar4;
D[21] = Npar2*Xxz2;
D[22] = -Npar2*Xyy*Xzz;
D[23] = -Npar2*Xxx*Xzz;
D[24] = -2*Npar2*Xzz;
D[25] = -Npar2*Xyy;
D[26] = -Npar2*Xyz2;
D[27] = -Npar2*Xxx;
D[28] = -2*Npar2;
D[29] = Xyy*Xzz;
D[30] = Xxx*Xzz;
D[31] = Xxx*Xyy;
D[32] = Xxx*Xyz2;
D[33] = Xyz2;
D[34] = Xxx;
D[35] = Xxy2;
D[36] = Xxy2*Xzz;
D[37] = -Xxz2;
D[38] = -Xyy*Xxz2;
D[39] = Xyy;
D[40] = Xzz;
D[41] = Xxx*Xyy*Xzz;
D[42] = 2*Xxy*Xyz*Xxz;



dDdpsi[0] = D[0]*(4*dNperpdpsi);
dDdpsi[1] = D[1]*(dXxxdpsi + 4*dNperpdpsi);
dDdpsi[2] = D[2]*(2*dNpardpsi + dXxzdpsi + 3*dNperpdpsi);
dDdpsi[3] = D[3]*(2*dNpardpsi + dXxxdpsi + 2*dNperpdpsi);
dDdpsi[4] = D[4]*(2*dNpardpsi + dXzzdpsi + 2*dNperpdpsi);
dDdpsi[5] = D[5]*(2*dNpardpsi + 2*dNperpdpsi);
dDdpsi[6] = D[6]*(dXxxdpsi + 2*dNperpdpsi);
dDdpsi[7] = D[7]*(dXyydpsi + 2*dNperpdpsi);
dDdpsi[8] = D[8]*(dXzzdpsi + 2*dNperpdpsi);
dDdpsi[9] = D[9]*(dXxxdpsi + dXzzdpsi + 2*dNperpdpsi);
dDdpsi[10] = D[10]*(2*dXxzdpsi + 2*dNperpdpsi);
dDdpsi[11] = D[11]*(dXxxdpsi + dXyydpsi + 2*dNperpdpsi);
dDdpsi[12] = D[12]*(2*dXxydpsi + 2*dNperpdpsi);
dDdpsi[13] = D[13]*(2*dNperpdpsi);
dDdpsi[14] = D[14]*(dNpardpsi + dXyydpsi + dXxzdpsi + dNperpdpsi);
dDdpsi[15] = D[15]*(dNpardpsi + dXxydpsi + dXyzdpsi + dNperpdpsi);
dDdpsi[16] = D[16]*(dNpardpsi + dXxzdpsi + dNperpdpsi);
dDdpsi[17] = D[17]*(3*dNpardpsi + dXxzdpsi + dNperpdpsi);
dDdpsi[18] = D[18]*0.0;
dDdpsi[19] = D[19]*(4*dNpardpsi + dXzzdpsi);
dDdpsi[20] = D[20]*(4*dNpardpsi);
dDdpsi[21] = D[21]*(2*dNpardpsi + 2*dXxzdpsi);
dDdpsi[22] = D[22]*(2*dNpardpsi + dXyydpsi + dXzzdpsi);
dDdpsi[23] = D[23]*(2*dNpardpsi + dXxxdpsi + dXzzdpsi);
dDdpsi[24] = D[24]*(2*dNpardpsi + dXzzdpsi);
dDdpsi[25] = D[25]*(2*dNpardpsi + dXyydpsi);
dDdpsi[26] = D[26]*(2*dNpardpsi + 2*dXyzdpsi);
dDdpsi[27] = D[27]*(2*dNpardpsi + dXxxdpsi);
dDdpsi[28] = D[28]*(2*dNpardpsi);
dDdpsi[29] = D[29]*(dXyydpsi + dXzzdpsi);
dDdpsi[30] = D[30]*(dXxxdpsi + dXzzdpsi);
dDdpsi[31] = D[31]*(dXxxdpsi + dXyydpsi);
dDdpsi[32] = D[32]*(dXxxdpsi + 2*dXyzdpsi);
dDdpsi[33] = D[33]*(2*dXyzdpsi);
dDdpsi[34] = D[34]*(dXxxdpsi);
dDdpsi[35] = D[35]*(2*dXxydpsi);
dDdpsi[36] = D[36]*(2*dXxydpsi + dXzzdpsi);
dDdpsi[37] = D[37]*(2*dXxzdpsi);
dDdpsi[38] = D[38]*(dXyydpsi + 2*dXxzdpsi);
dDdpsi[39] = D[39]*(dXyydpsi);
dDdpsi[40] = D[40]*(dXzzdpsi);
dDdpsi[41] = D[41]*(dXxxdpsi + dXyydpsi + dXzzdpsi);
dDdpsi[42] = D[42]*(dXxydpsi + dXyzdpsi + dXxzdpsi);




for (i = 0;i<43;i++) {
    Dtot = Dtot + D[i];
    dDtotdw = dDtotdw + dDdw[i];
    dDtotdpsi = dDtotdpsi + dDdpsi[i];
    dDtotdtheta = dDtotdtheta + dDdtheta[i];
    dDtotdkpsi = dDtotdkpsi + dDdkpsi[i];
    dDtotdm = dDtotdm + dDdm[i];
    dDtotdn = dDtotdn + dDdn[i];
}



/*
mexPrintf("Npar:%g\n",N.Npar[0]);
mexPrintf("Nperp:%g\n",N.Nperp[0]);
mexPrintf("dNperpdpsi:%g\n",N.dNperpdpsi[0]);
mexPrintf("dNperpdtheta:%g\n",N.dNperpdtheta[0]);
mexPrintf("dNperpdkpsi:%g\n",N.dNperpdkpsi[0]);
mexPrintf("dNperpdm:%g\n",N.dNperpdm[0]);
mexPrintf("dNperpdn:%g\n",N.dNperpdn[0]);


mexPrintf("psi:%g\n",psi);
mexPrintf("theta:%g\n",theta);
mexPrintf("phi:%g\n",phi);
mexPrintf("kspi:%g\n",kpsi);
mexPrintf("m:%g\n",m);
mexPrintf("n:%g\n",n);
*/

 /*
for (i = 0;i<43;i++) {
    Dtot = Dtot + D[i];
//    dDdw = dDdw + dDsdw[i];
    dDtotdpsi = dDtotdpsi + dDdpsi[i];
    dDtotdtheta = dDtotdtheta + dDdtheta[i];
    dDtotdkpsi = dDtotdkpsi + dDdkpsi[i];
    dDtotdm = dDtotdm + dDdm[i];
    dDtotdn = dDtotdn + dDdn[i];
}
    mexPrintf("Dtot:%g\n",Dtot);
    mexPrintf("Ydot[0...5]:%g,%g,%g,%g,%g,%g\n",Ydot[0],Ydot[1],Ydot[2],Ydot[3],Ydot[4],Ydot[5],Ydot[6]);
    Ydot[0] = -dDtotdkpsi;
    Ydot[1] = -dDtotdm;
    Ydot[2] = -dDtotdn;
    Ydot[3] = dDtotdpsi;
    Ydot[4] = dDtotdtheta;
    Ydot[5] = 0;
    Ydot[6] = 0;



/*

    Ydot[0] = -dDdkpsi/dDdw;
    Ydot[1] = -dDdm/dDdw;
    Ydot[2] = -dDdn/dDdw;
    Ydot[3] = dDdpsi/dDdw;
    Ydot[4] = dDdtheta/dDdw;
    Ydot[5] = 0;
    Ydot[6] = 0;
 */   
    

    mxFree(Te);
    mxFree(ne);
    mxFree(zTi);
    mxFree(zni);
    mxFree(wcn);
    mxFree(wpn2);
    mxFree(betath);    
    
    mxFree(dTedx);
    mxFree(dnedx);
    mxFree(dzTidx);
    mxFree(dznidx);
    mxFree(dwcndx);
    mxFree(dwpn2dx);
    mxFree(dbetathdx);
    
    mxFree(raymagnetic.r);
    mxFree(raymagnetic.R);
    mxFree(raymagnetic.salpha);
    mxFree(raymagnetic.calpha);
    mxFree(raymagnetic.BP);
    mxFree(raymagnetic.BPHI);
    mxFree(raymagnetic.B);

    mxFree(raymagnetic.drdx);
    mxFree(raymagnetic.dRdx);
    mxFree(raymagnetic.dsalphadx);
    mxFree(raymagnetic.dcalphadx);
    mxFree(raymagnetic.dBPdx);
    mxFree(raymagnetic.dBPHIdx);
    mxFree(raymagnetic.dBdx);
    
    mxFree(Npar);
    mxFree(Nperp);
    
    mxFree(dNpardx);
    mxFree(dNperpdx);
    
}

/*susceptibilitytensor_format susceptibility(tensortype,ns,N,wcn,dwcndpsi,dwcndtheta,wpn,dwpndpsi,betath,dbetathdpsi)
double tensortype,wcn[],dwcndpsi[],dwcndtheta[],wpn[],dwpndpsi[],betath[],dbetathdpsi[];
int ns;
refractiveindex_format N;
{
    susceptibilitytensor_format X;
    
    if (tensortype == 0) {
//        mexPrintf("Cold dielectric tensor\n");
        X = coldtensor(ns,N,wcn,dwcndpsi,dwcndtheta,wpn,dwpndpsi,betath,dbetathdpsi);
    }
    if (tensortype == 1) {
//        mexPrintf("Warm dielectric tensor\n");
//        X = warmtensor(ns,N,wcn,dwcndpsi,dwcndtheta,wpn,dwpndpsi,betath,dbetathdpsi);
    }
    if (tensortype == 2) {
//        mexPrintf("Hot dielectric tensor\n");
//        X = hottensor(ns,N,wcn,dwcndpsi,dwcndtheta,wpn,dwpndpsi,betath,dbetathdpsi);
    }
    if (tensortype == 3) {
//        mexPrintf("Relativistic dielectric tensor\n");
//        X = relativistictensor(ns,N,wcn,dwcndpsi,dwcndtheta,wpn,dwpndpsi,betath,dbetathdpsi);
    }       
       
    return(X);
} 

*/

void rayindex(clum,Y,dYdY,raymagnetic,Npar1,Nperp1,dNpardx1,dNperpdx1)
double complex Y[];
double dYdY[][8];
double clum;
double complex *Npar1,*Nperp1,dNpardx1[],dNperpdx1[];
raymagnetic_format raymagnetic;
{ 
    
    double complex kpar1,dkpar1dx,dkpar1dx1,dkpar1dx2,dkpar1dx3,dkpar1dx4,dkpar1dx5,dkpar1dx6;
    double complex kpar2,dkpar2dx,dkpar2dx1,dkpar2dx2,dkpar2dx3,dkpar2dx4,dkpar2dx5;
    double complex kpar3,dkpar3dx,dkpar3dx1,dkpar3dx2,dkpar3dx3,dkpar3dx4;
    double complex N2,dN2dx,dNpardx,dNperpdx;
    
    double complex k21,dk21dx,dk21dx1,dk21dx2,dk21dx3;
    double complex k22,dk22dx,dk22dx1,dk22dx2,dk22dx3,dk22dx4,dk22dx5,dk22dx6;
    double complex k23,dk23dx,dk23dx1,dk23dx2;
    double complex k24,dk24dx,dk24dx1,dk24dx2;
    
    register int i,j;

    kpar1 = raymagnetic.R[0]*raymagnetic.BP[0]*Y[3]*raymagnetic.salpha[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0];
    kpar2 = Y[4]/raymagnetic.r[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0];
    kpar3 = Y[5]*raymagnetic.BPHI[0]/raymagnetic.R[0]/raymagnetic.B[0];
  
    Npar1[0] = clum*(-kpar1 + kpar2 + kpar3)/Y[6];
    
    for (i=0;i<8;i++) {

        dkpar1dx1 = raymagnetic.dRdx[i]*raymagnetic.BP[0]*Y[3]*raymagnetic.salpha[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0];
        dkpar1dx2 = 2.0*raymagnetic.R[0]*raymagnetic.dBPdx[i]*Y[3]*raymagnetic.salpha[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0];
        dkpar1dx3 = raymagnetic.R[0]*raymagnetic.BP[0]*dYdY[3][i]*raymagnetic.salpha[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0];
        dkpar1dx4 = raymagnetic.R[0]*raymagnetic.BP[0]*Y[3]*raymagnetic.dsalphadx[i]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0];
        dkpar1dx5 = raymagnetic.R[0]*raymagnetic.BP[0]*Y[3]*raymagnetic.salpha[0]*raymagnetic.dcalphadx[i]*raymagnetic.BP[0]/raymagnetic.B[0];
        dkpar1dx6 = -raymagnetic.R[0]*raymagnetic.BP[0]*Y[3]*raymagnetic.salpha[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]*raymagnetic.dBdx[i]/raymagnetic.B[0]/raymagnetic.B[0];
    
        dkpar1dx = dkpar1dx1 + dkpar1dx2 + dkpar1dx3 + dkpar1dx4 + dkpar1dx5 + dkpar1dx6;
    
        dkpar2dx1 = dYdY[4][i]/raymagnetic.r[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0];
        dkpar2dx2 = -raymagnetic.drdx[i]*Y[4]/raymagnetic.r[0]/raymagnetic.r[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0];
        dkpar2dx3 = Y[4]/raymagnetic.r[0]*raymagnetic.dcalphadx[i]*raymagnetic.BP[0]/raymagnetic.B[0];
        dkpar2dx4 = Y[4]/raymagnetic.r[0]*raymagnetic.calpha[0]*raymagnetic.dBPdx[i]/raymagnetic.B[0];
        dkpar2dx5 = -Y[4]/raymagnetic.r[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]*raymagnetic.dBdx[i]/raymagnetic.B[0]/raymagnetic.B[0];
        
        dkpar2dx = dkpar2dx1 + dkpar2dx2 + dkpar2dx3 + dkpar2dx4 + dkpar2dx5;
 
        dkpar3dx1 = dYdY[5][i]*raymagnetic.BPHI[0]/raymagnetic.R[0]/raymagnetic.B[0];
        dkpar3dx2 = Y[5]*raymagnetic.dBPHIdx[i]/raymagnetic.R[0]/raymagnetic.B[0];
        dkpar3dx3 = -Y[5]*raymagnetic.BPHI[0]*raymagnetic.dRdx[i]/raymagnetic.R[0]/raymagnetic.R[0]/raymagnetic.B[0];
        dkpar3dx4 = Y[5]*raymagnetic.BPHI[0]/raymagnetic.R[0]*raymagnetic.dBdx[i]/raymagnetic.B[0]/raymagnetic.B[0];
    
        dkpar3dx = dkpar3dx1 + dkpar3dx2 + dkpar3dx3 + dkpar3dx4;
        
        dNpardx1[i] = clum*(-dkpar1dx + dkpar2dx + dkpar3dx)/Y[6];
//        mexPrintf("i,dNpardx[i]:%d,%g\n",i,dNpardx1[i]);
//        mexPrintf("i,dYdY[3][i],dYdY[4][i],dYdY[5][i]:%d,%g,%g,%g\n",i,dYdY[3][i],dYdY[4][i],dYdY[4][i]);
    }
    

    k21 = raymagnetic.R[0]*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.BP[0]*Y[3]*Y[3];
    k22 = 2*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.salpha[0]*Y[4]*Y[3]/raymagnetic.r[0];
    k23 = Y[4]*Y[4]/raymagnetic.r[0]/raymagnetic.r[0];
    k24 = Y[5]*Y[5]/raymagnetic.R[0]/raymagnetic.R[0];
    
    N2 = clum*clum*(k21 + k22 + k23 + k24)/Y[6]/Y[6];
    Nperp1[0] = sqrt(N2 - Npar1[0]);

    for (i=0;i<8;i++) {
        
        dk21dx1 = 2*raymagnetic.dRdx[i]*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.BP[0]*Y[3]*Y[3];
        dk21dx2 = 2*raymagnetic.R[0]*raymagnetic.R[0]*raymagnetic.dBPdx[i]*raymagnetic.BP[0]*Y[3]*Y[3];
        dk21dx3 = 2*raymagnetic.R[0]*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.BP[0]*dYdY[3][i]*Y[3];
        
        dk21dx = dk21dx1 + dk21dx2 + dk21dx3;
        
        dk22dx1 = 2*raymagnetic.dRdx[i]*raymagnetic.BP[0]*raymagnetic.salpha[0]*Y[4]*Y[3]/raymagnetic.r[0];
        dk22dx2 = 2*raymagnetic.R[0]*raymagnetic.dBPdx[i]*raymagnetic.salpha[0]*Y[4]*Y[3]/raymagnetic.r[0];
        dk22dx3 = 2*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.dsalphadx[i]*Y[4]*Y[3]/raymagnetic.r[0];
        dk22dx4 = 2*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.salpha[0]*dYdY[4][i]*Y[3]/raymagnetic.r[0];
        dk22dx5 = 2*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.salpha[0]*Y[4]*dYdY[3][i]/raymagnetic.r[0];
        dk22dx6 = -2*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.salpha[0]*Y[4]*Y[3]*raymagnetic.drdx[i]/raymagnetic.r[0]/raymagnetic.r[0];
        
        dk22dx = dk22dx1 + dk22dx2 + dk22dx3 + dk22dx4 + dk22dx5 + dk22dx6;
     
        dk23dx1 = 2*dYdY[i][4]*Y[4]/raymagnetic.r[0]/raymagnetic.r[0];
        dk23dx2 = -2*Y[4]*Y[4]*raymagnetic.drdx[i]/raymagnetic.r[0]/raymagnetic.r[0]/raymagnetic.r[0];
        
        dk23dx = dk23dx1 + dk23dx2;
    
        dk24dx1 = 2*dYdY[i][5]*Y[5]/raymagnetic.R[0]/raymagnetic.R[0];
        dk24dx2 = -2*Y[5]*Y[5]*raymagnetic.dRdx[i]/raymagnetic.R[0]/raymagnetic.R[0]/raymagnetic.R[0];

        dk24dx = dk24dx1 + dk24dx2;
        
        dN2dx = clum*clum*(dk21dx + dk22dx + dk23dx + dk24dx)/Y[6]/Y[6];
        
        dNperpdx1[i] = (dN2dx - 2.0*Npar1[0]*dNpardx1[i])/Nperp1[0]/2.0;
//        mexPrintf("i,dNperpdx[i]:%d,%g\n",i,dNperpdx1[i]);
     }
    
}

/*
susceptibilitytensor_format coldtensor(ns,N,wcn,dwcndpsi,dwcndtheta,wpn,dwpndpsi,betath,dbetathdpsi)
double wcn[],dwcndpsi[],dwcndtheta[],wpn[],dwpndpsi[],betath[],dbetathdpsi[];
int ns;
refractiveindex_format N;
{
    susceptibilitytensor_format X;
    
    double *dXxxdNperp,*dXxydNperp,*dXxzdNperp,*dXyydNperp,*dXyzdNperp,*dXzzdNperp;
    double *dXxxdNpar,*dXxydNpar,*dXxzdNpar,*dXyydNpar,*dXyzdNpar,*dXzzdNpar;
    double *dXxxdbetath,*dXxydbetath,*dXxzdbetath,*dXyydbetath,*dXyzdbetath,*dXzzdbetath;
    double *dXxxdwcn,*dXxydwcn,*dXxzdwcn,*dXyydwcn,*dXyzdwcn,*dXzzdwcn;
    double *dXxxdwpn,*dXxydwpn,*dXxzdwpn,*dXyydwpn,*dXyzdwpn,*dXzzdwpn;
    
    int is;
    
    
   
    X.Xxx = mxCalloc(1,sizeof(double));
    X.Xxy = mxCalloc(1,sizeof(double));
    X.Xxz = mxCalloc(1,sizeof(double));
    X.Xyy = mxCalloc(1,sizeof(double));
    X.Xyz = mxCalloc(1,sizeof(double));
    X.Xzz = mxCalloc(1,sizeof(double));
    X.dXxxdpsi = mxCalloc(1,sizeof(double));
    X.dXxydpsi = mxCalloc(1,sizeof(double));
    X.dXxzdpsi = mxCalloc(1,sizeof(double));
    X.dXyydpsi = mxCalloc(1,sizeof(double));
    X.dXyzdpsi = mxCalloc(1,sizeof(double));
    X.dXzzdpsi = mxCalloc(1,sizeof(double));
    X.dXxxdtheta = mxCalloc(1,sizeof(double));
    X.dXxydtheta = mxCalloc(1,sizeof(double));
    X.dXxzdtheta = mxCalloc(1,sizeof(double));
    X.dXyydtheta = mxCalloc(1,sizeof(double));
    X.dXyzdtheta = mxCalloc(1,sizeof(double));
    X.dXzzdtheta = mxCalloc(1,sizeof(double));
    X.dXxxdkpsi = mxCalloc(1,sizeof(double));
    X.dXxydkpsi = mxCalloc(1,sizeof(double));
    X.dXxzdkpsi = mxCalloc(1,sizeof(double));
    X.dXyydkpsi = mxCalloc(1,sizeof(double));
    X.dXyzdkpsi = mxCalloc(1,sizeof(double));
    X.dXzzdkpsi = mxCalloc(1,sizeof(double));
    X.dXxxdm = mxCalloc(1,sizeof(double));
    X.dXxydm = mxCalloc(1,sizeof(double));
    X.dXxzdm = mxCalloc(1,sizeof(double));
    X.dXyydm = mxCalloc(1,sizeof(double));
    X.dXyzdm = mxCalloc(1,sizeof(double));
    X.dXzzdm = mxCalloc(1,sizeof(double));    
    X.dXxxdn = mxCalloc(1,sizeof(double));
    X.dXxydn = mxCalloc(1,sizeof(double));
    X.dXxzdn = mxCalloc(1,sizeof(double));
    X.dXyydn = mxCalloc(1,sizeof(double));
    X.dXyzdn = mxCalloc(1,sizeof(double));
    X.dXzzdn = mxCalloc(1,sizeof(double));    
   
    dXxxdNperp = mxCalloc(ns+1,sizeof(double));
    dXxydNperp = mxCalloc(ns+1,sizeof(double));
    dXxzdNperp = mxCalloc(ns+1,sizeof(double));
    dXyydNperp = mxCalloc(ns+1,sizeof(double));
    dXyzdNperp = mxCalloc(ns+1,sizeof(double));
    dXzzdNperp = mxCalloc(ns+1,sizeof(double));
    dXxxdNpar = mxCalloc(ns+1,sizeof(double));
    dXxydNpar = mxCalloc(ns+1,sizeof(double));
    dXxzdNpar = mxCalloc(ns+1,sizeof(double));
    dXyydNpar = mxCalloc(ns+1,sizeof(double));
    dXyzdNpar = mxCalloc(ns+1,sizeof(double));
    dXzzdNpar = mxCalloc(ns+1,sizeof(double));
    dXxxdbetath = mxCalloc(ns+1,sizeof(double));
    dXxydbetath = mxCalloc(ns+1,sizeof(double));
    dXxzdbetath = mxCalloc(ns+1,sizeof(double));
    dXyydbetath = mxCalloc(ns+1,sizeof(double));
    dXyzdbetath = mxCalloc(ns+1,sizeof(double));
    dXzzdbetath = mxCalloc(ns+1,sizeof(double));
    dXxxdwcn = mxCalloc(ns+1,sizeof(double));
    dXxydwcn = mxCalloc(ns+1,sizeof(double));
    dXxzdwcn = mxCalloc(ns+1,sizeof(double));
    dXyydwcn = mxCalloc(ns+1,sizeof(double));
    dXyzdwcn = mxCalloc(ns+1,sizeof(double));
    dXzzdwcn = mxCalloc(ns+1,sizeof(double));    
    dXxxdwpn = mxCalloc(ns+1,sizeof(double));
    dXxydwpn = mxCalloc(ns+1,sizeof(double));
    dXxzdwpn = mxCalloc(ns+1,sizeof(double));
    dXyydwpn = mxCalloc(ns+1,sizeof(double));
    dXyzdwpn = mxCalloc(ns+1,sizeof(double));
    dXzzdwpn = mxCalloc(ns+1,sizeof(double));
    
    for (is = 0;is < ns + 1; is++) {
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
        dXxxdwcn[is] = -2.0*wpn[is]*wpn[is]*wcn[is]/pow(1 - wcn[is]*wcn[is],2);
        dXxydwcn[is] = -2.0*wpn[is]*wpn[is]*wcn[is]*wcn[is]/pow(1 - wcn[is]*wcn[is],2) - wpn[is]*wpn[is]/(1 - wcn[is]*wcn[is]);
        dXxzdwcn[is] = 0.0;
        dXyydwcn[is] = -2.0*wpn[is]*wpn[is]*wcn[is]/pow(1 - wcn[is]*wcn[is],2);
        dXyzdwcn[is] = 0.0;
        dXzzdwcn[is] = 0.0;    
        dXxxdwpn[is] = -2.0*wpn[is]/(1 - wcn[is]*wcn[is]);
        dXxydwpn[is] = -2.0*wpn[is]*wcn[is]/(1 - wcn[is]*wcn[is]);
        dXxzdwpn[is] = 0.0;
        dXyydwpn[is] = -2.0*wpn[is]/(1 - wcn[is]*wcn[is]);
        dXyzdwpn[is] = 0.0;
        dXzzdwpn[is] = -2.0*wpn[is];
    }
     
    X.Xxx[0] = 0.0;
    X.Xxy[0] = 0.0;
    X.Xxz[0] = 0.0;
    X.Xyy[0] = 0.0;
    X.Xyz[0] = 0.0;
    X.Xzz[0] = 0.0;
    
    for (is = 0;is < ns + 1;is++) {
        X.Xxx[0] = X.Xxx[0] - wpn[is]*wpn[is]/(1 - wcn[is]*wcn[is]);
        X.Xxy[0] = X.Xxy[0] - wpn[is]*wpn[is]*wcn[is]/(1 - wcn[is]*wcn[is]);
        X.Xxz[0] = X.Xxz[0];
        X.Xyy[0] = X.Xyy[0] - wpn[is]*wpn[is]/(1 - wcn[is]*wcn[is]);
        X.Xyz[0] = X.Xyz[0];
        X.Xzz[0] = X.Xzz[0] - wpn[is]*wpn[is];
    }
    
    X.dXxxdpsi[0] = 0.0;
    X.dXxydpsi[0] = 0.0;
    X.dXxzdpsi[0] = 0.0;
    X.dXyydpsi[0] = 0.0;
    X.dXyzdpsi[0] = 0.0;
    X.dXzzdpsi[0] = 0.0;
    
    for (is = 0;is < ns + 1;is++) {
        X.dXxxdpsi[0] = X.dXxxdpsi[0] + dXxxdNperp[is]*N.dNperpdpsi[0] + dXxxdNpar[is]*N.dNpardpsi[0] + dXxxdbetath[is]*dbetathdpsi[is] + dXxxdwcn[is]*dwcndpsi[is] + dXxxdwpn[is]*dwpndpsi[is];
        X.dXxydpsi[0] = X.dXxydpsi[0] + dXxydNperp[is]*N.dNperpdpsi[0] + dXxydNpar[is]*N.dNpardpsi[0] + dXxydbetath[is]*dbetathdpsi[is] + dXxydwcn[is]*dwcndpsi[is] + dXxydwpn[is]*dwpndpsi[is];
        X.dXxzdpsi[0] = X.dXxzdpsi[0] + dXxzdNperp[is]*N.dNperpdpsi[0] + dXxzdNpar[is]*N.dNpardpsi[0] + dXxzdbetath[is]*dbetathdpsi[is] + dXxzdwcn[is]*dwcndpsi[is] + dXxzdwpn[is]*dwpndpsi[is];
        X.dXyydpsi[0] = X.dXyydpsi[0] + dXyydNperp[is]*N.dNperpdpsi[0] + dXyydNpar[is]*N.dNpardpsi[0] + dXyydbetath[is]*dbetathdpsi[is] + dXyydwcn[is]*dwcndpsi[is] + dXyydwpn[is]*dwpndpsi[is];
        X.dXyzdpsi[0] = X.dXyzdpsi[0] + dXyzdNperp[is]*N.dNperpdpsi[0] + dXyzdNpar[is]*N.dNpardpsi[0] + dXyzdbetath[is]*dbetathdpsi[is] + dXyzdwcn[is]*dwcndpsi[is] + dXyzdwpn[is]*dwpndpsi[is];
        X.dXzzdpsi[0] = X.dXzzdpsi[0] + dXzzdNperp[is]*N.dNperpdpsi[0] + dXzzdNpar[is]*N.dNpardpsi[0] + dXzzdbetath[is]*dbetathdpsi[is] + dXzzdwcn[is]*dwcndpsi[is] + dXzzdwpn[is]*dwpndpsi[is];
    }

    X.dXxxdtheta[0] = 0.0;
    X.dXxydtheta[0] = 0.0;
    X.dXxzdtheta[0] = 0.0;
    X.dXyydtheta[0] = 0.0;
    X.dXyzdtheta[0] = 0.0;
    X.dXzzdtheta[0] = 0.0;
    
    for (is = 0;is < ns + 1;is++) {
        X.dXxxdtheta[0] = X.dXxxdtheta[0] + dXxxdNperp[is]*N.dNperpdtheta[0] + dXxxdNpar[is]*N.dNpardtheta[0] + dXxxdwcn[is]*dwcndtheta[is];
        X.dXxydtheta[0] = X.dXxydtheta[0] + dXxydNperp[is]*N.dNperpdtheta[0] + dXxydNpar[is]*N.dNpardtheta[0] + dXxydwcn[is]*dwcndtheta[is];
        X.dXxzdtheta[0] = X.dXxzdtheta[0] + dXxzdNperp[is]*N.dNperpdtheta[0] + dXxzdNpar[is]*N.dNpardtheta[0] + dXxzdwcn[is]*dwcndtheta[is];
        X.dXyydtheta[0] = X.dXyydtheta[0] + dXyydNperp[is]*N.dNperpdtheta[0] + dXyydNpar[is]*N.dNpardtheta[0] + dXyydwcn[is]*dwcndtheta[is];
        X.dXyzdtheta[0] = X.dXyzdtheta[0] + dXyzdNperp[is]*N.dNperpdtheta[0] + dXyzdNpar[is]*N.dNpardtheta[0] + dXyzdwcn[is]*dwcndtheta[is];
        X.dXzzdtheta[0] = X.dXzzdtheta[0] + dXzzdNperp[is]*N.dNperpdtheta[0] + dXzzdNpar[is]*N.dNpardtheta[0] + dXzzdwcn[is]*dwcndtheta[is];
    }
    
    X.dXxxdkpsi[0] = 0.0;
    X.dXxydkpsi[0] = 0.0;
    X.dXxzdkpsi[0] = 0.0;
    X.dXyydkpsi[0] = 0.0;
    X.dXyzdkpsi[0] = 0.0;
    X.dXzzdkpsi[0] = 0.0;
    
    for (is = 0;is < ns + 1;is++) {
        X.dXxxdkpsi[0] = X.dXxxdkpsi[0] + dXxxdNperp[is]*N.dNperpdkpsi[0] + dXxxdNpar[is]*N.dNpardkpsi[0];
        X.dXxydkpsi[0] = X.dXxydkpsi[0] + dXxydNperp[is]*N.dNperpdkpsi[0] + dXxydNpar[is]*N.dNpardkpsi[0];
        X.dXxzdkpsi[0] = X.dXxzdkpsi[0] + dXxzdNperp[is]*N.dNperpdkpsi[0] + dXxzdNpar[is]*N.dNpardkpsi[0];
        X.dXyydkpsi[0] = X.dXyydkpsi[0] + dXyydNperp[is]*N.dNperpdkpsi[0] + dXyydNpar[is]*N.dNpardkpsi[0];
        X.dXyzdkpsi[0] = X.dXyzdkpsi[0] + dXyzdNperp[is]*N.dNperpdkpsi[0] + dXyzdNpar[is]*N.dNpardkpsi[0];
        X.dXzzdkpsi[0] = X.dXzzdkpsi[0] + dXzzdNperp[is]*N.dNperpdkpsi[0] + dXzzdNpar[is]*N.dNpardkpsi[0];
    }
 
    X.dXxxdm[0] = 0.0;
    X.dXxydm[0] = 0.0;
    X.dXxzdm[0] = 0.0;
    X.dXyydm[0] = 0.0;
    X.dXyzdm[0] = 0.0;
    X.dXzzdm[0] = 0.0;
    
    for (is = 0;is < ns + 1;is++) {
        X.dXxxdm[0] = X.dXxxdm[0] + dXxxdNperp[is]*N.dNperpdm[0] + dXxxdNpar[is]*N.dNpardm[0];
        X.dXxydm[0] = X.dXxydm[0] + dXxydNperp[is]*N.dNperpdm[0] + dXxydNpar[is]*N.dNpardm[0];
        X.dXxzdm[0] = X.dXxzdm[0] + dXxzdNperp[is]*N.dNperpdm[0] + dXxzdNpar[is]*N.dNpardm[0];
        X.dXyydm[0] = X.dXyydm[0] + dXyydNperp[is]*N.dNperpdm[0] + dXyydNpar[is]*N.dNpardm[0];
        X.dXyzdm[0] = X.dXyzdm[0] + dXyzdNperp[is]*N.dNperpdm[0] + dXyzdNpar[is]*N.dNpardm[0];
        X.dXzzdm[0] = X.dXzzdm[0] + dXzzdNperp[is]*N.dNperpdm[0] + dXzzdNpar[is]*N.dNpardm[0];
    }

    X.dXxxdn[0] = 0.0;
    X.dXxydn[0] = 0.0;
    X.dXxzdn[0] = 0.0;
    X.dXyydn[0] = 0.0;
    X.dXyzdn[0] = 0.0;
    X.dXzzdn[0] = 0.0;
    
    for (is = 0;is < ns + 1;is++) {
        X.dXxxdn[0] = X.dXxxdn[0] + dXxxdNperp[is]*N.dNperpdn[0] + dXxxdNpar[is]*N.dNpardn[0];
        X.dXxydn[0] = X.dXxydn[0] + dXxydNperp[is]*N.dNperpdn[0] + dXxydNpar[is]*N.dNpardn[0];
        X.dXxzdn[0] = X.dXxzdn[0] + dXxzdNperp[is]*N.dNperpdn[0] + dXxzdNpar[is]*N.dNpardn[0];
        X.dXyydn[0] = X.dXyydn[0] + dXyydNperp[is]*N.dNperpdn[0] + dXyydNpar[is]*N.dNpardn[0];
        X.dXyzdn[0] = X.dXyzdn[0] + dXyzdNperp[is]*N.dNperpdn[0] + dXyzdNpar[is]*N.dNpardn[0];
        X.dXzzdn[0] = X.dXzzdn[0] + dXzzdNperp[is]*N.dNperpdn[0] + dXzzdNpar[is]*N.dNpardn[0];
    }
    
    mxFree(dXxxdNperp);
    mxFree(dXxydNperp);
    mxFree(dXxzdNperp);
    mxFree(dXyydNperp);
    mxFree(dXyzdNperp);
    mxFree(dXzzdNperp);
    mxFree(dXxxdNpar);
    mxFree(dXxydNpar);
    mxFree(dXxzdNpar);
    mxFree(dXyydNpar);
    mxFree(dXyzdNpar);
    mxFree(dXzzdNpar);
    mxFree(dXxxdbetath);
    mxFree(dXxydbetath);
    mxFree(dXxzdbetath);
    mxFree(dXyydbetath);
    mxFree(dXyzdbetath);
    mxFree(dXzzdbetath);
    mxFree(dXxxdwcn);
    mxFree(dXxydwcn);
    mxFree(dXxzdwcn);
    mxFree(dXyydwcn);
    mxFree(dXyzdwcn);
    mxFree(dXzzdwcn);    
    mxFree(dXxxdwpn);
    mxFree(dXxydwpn);
    mxFree(dXxzdwpn);
    mxFree(dXyydwpn);
    mxFree(dXyzdwpn);
    mxFree(dXzzdwpn);
    
    return(X);
   
}
    
    
    */
    
    
    


