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
    double *dpsin;
    double *tol;
    double *kmax;
};

struct equilparam {
    double*zZi;
    double *zmi;
    int *ns;
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
    mxChar  *form_dfdpsin;
    double  *breaks_dfdpsin;
    double  *coefs_dfdpsin;
    double  *pieces_dfdpsin;
    double  *order_dfdpsin;
    double  *dim_dfdpsin;
    mxChar  *orient_dfdpsin;
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
    mxChar  *form_da0dpsin;
    double  *breaks_da0dpsin;
    double  *coefs_da0dpsin;
    double  *pieces_da0dpsin;
    double  *order_da0dpsin;
    double  *dim_da0dpsin;
    mxChar  *orient_da0dpsin;
    mxChar  *form_an;
    double  *breaks_an;
    double  *coefs_an;
    double  *pieces_an;
    double  *order_an;
    double  *dim_an;
    mxChar  *orient_an;
    mxChar  *form_dandpsin;
    double  *breaks_dandpsin;
    double  *coefs_dandpsin;
    double  *pieces_dandpsin;
    double  *order_dandpsin;
    double  *dim_dandpsin;
    mxChar  *orient_dandpsin;
    mxChar  *form_bn;
    double  *breaks_bn;
    double  *coefs_bn;
    double  *pieces_bn;
    double  *order_bn;
    double  *dim_bn;
    mxChar  *orient_bn;
    mxChar  *form_dbndpsin;
    double  *breaks_dbndpsin;
    double  *coefs_dbndpsin;
    double  *pieces_dbndpsin;
    double  *order_dbndpsin;
    double  *dim_dbndpsin;
    mxChar  *orient_dbndpsin;
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
void susceptibility();
void coldtensor();
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
    pp_2D_format BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit,salpha_fit;
    rayparam_format rayparam;
    equilparam_format equilparam;
  
    double *Te,*dTedpsin,*ne,*dnedpsin,*zTi,*dzTidpsin,*zni,*dznidpsin; 
    double *BPHI,*dBPHIdpsin,*dBPHIdtheta;
    double *BP,*dBPdpsin,*dBPdtheta;
    double *R,*dRdpsin,*dRdtheta;
    double *Z,*dZdpsin,*dZdtheta;
    double *r,*drdpsin,*drdtheta;
    double *calpha,*dcalphadpsin,*dcalphadtheta;
    double *salpha,*dsalphadpsin,*dsalphadtheta;
    double *psia;
    
    /* Check out the arguments */

    if (nrhs != 3) {
        mexErrMsgTxt("Wrong number of input arguments for raytracing_yp");
    } else if (nlhs != 2) {
        mexErrMsgTxt("Wrong number of output arguments for raytracing_yp");
    }
    
    if (!mxIsStruct(prhs[0])) mexErrMsgTxt("Input arguments must be structures");
    if (!mxIsStruct(prhs[1])) mexErrMsgTxt("Input arguments must be structures");


// Get Input Arguments

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
    salpha_fit = load_equil_2D(EQUIL_IN,"salpha_fit");
    
// Test mode only
    
    if (rayparam.testmode[0]) {// keep this section for tests if necessary
        mexPrintf("tol : %g\n",rayparam.tol[0]);
        mexPrintf("zZi(4) : %g\n",equilparam.zZi[3]);
        
        mexPrintf("--------------\n");

        mexPrintf("Te_fit.coefs_f(1): %g\n",Te_fit.coefs_f[0]);
        mexPrintf("Te_fit.coefs_dfdpsin(1): %g\n",Te_fit.coefs_dfdpsin[0]);
        mexPrintf("BPHI_fit.n: %g\n",BPHI_fit.n[0]);
        mexPrintf("BPHI_fit.coefs_bn(1): %g\n",BPHI_fit.coefs_bn[0]);
        mexPrintf("BPHI_fit.coefs_dbndpsin(1): %g\n",BPHI_fit.coefs_dbndpsin[0]);

        mexPrintf("--------------\n");
            
        Te = mxCalloc(1,sizeof(double));
        dTedpsin = mxCalloc(1,sizeof(double));
        ppval_1D(Te_fit,0.25,Te,dTedpsin);
        mexPrintf("Te(0.25),dTedpsin(0.25) (keV): %g,%g\n",Te[0],dTedpsin[0]);    
        mxFree(Te);
        mxFree(dTedpsin);
        
        ne = mxCalloc(1,sizeof(double));
        dnedpsin = mxCalloc(1,sizeof(double));
        ppval_1D(ne_fit,0.25,ne,dnedpsin);
        mexPrintf("ne(0.25),dnedpsin(0.25) (10+19 m-3): %g,%g\n",ne[0]/1e19,dnedpsin[0]/1e19);    
        mxFree(ne);
        mxFree(dnedpsin);

        zTi = mxCalloc(equilparam.ns[0],sizeof(double));
        dzTidpsin = mxCalloc(equilparam.ns[0],sizeof(double));
        ppval_1D(zTi_fit,0.25,zTi,dzTidpsin);
        mexPrintf("zTi(2,0.25),dzTidpsin(2,0.25) (keV): %g,%g\n",zTi[1],dzTidpsin[1]);
        mxFree(zTi);
        mxFree(dzTidpsin);
        
        zni = mxCalloc(equilparam.ns[0],sizeof(double));
        dznidpsin = mxCalloc(equilparam.ns[0],sizeof(double));
        ppval_1D(zni_fit,0.25,zni,dznidpsin);
        mexPrintf("zni(2,0.25),dznidpsin(2,0.25) (10+19 m-3): %g,%g\n",zni[1]/1e19,dznidpsin[1]/1e19);
        mxFree(zni);
        mxFree(dznidpsin);
        
        R = mxCalloc(1,sizeof(double));
        dRdpsin = mxCalloc(1,sizeof(double));
        dRdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(R_fit,0.25,0.2,R,dRdpsin,dRdtheta);
        mexPrintf("R(0.25,0.2),dRdpsin(0.25,0.2),dRdtheta(0.25,0.2) (m): %g,%g,%g\n",R[0],dRdpsin[0],dRdtheta[0]);
        mxFree(R);
        mxFree(dRdpsin); 
        mxFree(dRdtheta); 
        
        r = mxCalloc(1,sizeof(double));
        drdpsin = mxCalloc(1,sizeof(double));
        drdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(r_fit,0.25,0.2,r,drdpsin,drdtheta);
        mexPrintf("r(0.25,0.2),drdpsin(0.25,0.2),drdtheta(0.25,0.2) (m): %g,%g,%g\n",r[0],drdpsin[0],drdtheta[0]);
        mxFree(r);
        mxFree(drdpsin); 
        mxFree(drdtheta);
 
        BPHI = mxCalloc(1,sizeof(double));
        dBPHIdpsin = mxCalloc(1,sizeof(double));
        dBPHIdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(BPHI_fit,0.25,0.2,BPHI,dBPHIdpsin,dBPHIdtheta);
        mexPrintf("BPHI(0.25,0.2),dBPHIdpsin(0.25,0.2),dBPHIdtheta(0.25,0.2) (T): %g,%g,%g\n",BPHI[0],dBPHIdpsin[0],dBPHIdtheta[0]);
        mxFree(BPHI);
        mxFree(dBPHIdpsin); 
        mxFree(dBPHIdtheta); 
        
        BP = mxCalloc(1,sizeof(double));
        dBPdpsin = mxCalloc(1,sizeof(double));
        dBPdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(BP_fit,0.25,0.2,BP,dBPdpsin,dBPdtheta);
        mexPrintf("BP(0.25,0.2),dBPdpsin(0.25,0.2),dBPdtheta(0.25,0.2) (T): %g,%g,%g\n",BP[0],dBPdpsin[0],dBPdtheta[0]);
        mxFree(BP);
        mxFree(dBPdpsin); 
        mxFree(dBPdtheta); 

        calpha = mxCalloc(1,sizeof(double));
        dcalphadpsin = mxCalloc(1,sizeof(double));
        dcalphadtheta = mxCalloc(1,sizeof(double));
        ppval_2D(calpha_fit,0.25,0.2,calpha,dcalphadpsin,dcalphadtheta);
        mexPrintf("calpha(0.25,0.2),dcalphadpsin(0.25,0.2),dcalphadtheta(0.25,0.2) : %g,%g,%g\n",calpha[0],dcalphadpsin[0],dcalphadtheta[0]);
        mxFree(calpha);
        mxFree(dcalphadpsin); 
        mxFree(dcalphadtheta);        
        
        salpha = mxCalloc(1,sizeof(double));
        dsalphadpsin = mxCalloc(1,sizeof(double));
        dsalphadtheta = mxCalloc(1,sizeof(double));
        ppval_2D(salpha_fit,0.25,0.2,salpha,dsalphadpsin,dsalphadtheta);
        mexPrintf("salpha(0.25,0.2),dsalphadpsin(0.25,0.2),dsalphadtheta(0.25,0.2) : %g,%g,%g\n",salpha[0],dsalphadpsin[0],dsalphadtheta[0]);
        mxFree(salpha);
        mxFree(dsalphadpsin); 
        mxFree(dsalphadtheta);        
       
        
        
    }
    
// Runge-Kutta 

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

    double ts;
    double s0[7];
    double *s1,*s2,*s3,*s4,*s5,*s6;
    double tau,delta,h,hmax,hmin;
    double ymax;
    
    double *ydel;
    
    double kpsin1,kpsin2,kpsin3;
    double t1,t2,t3,psin1,psin2,psin3,theta1,theta2,theta3,phi1,phi2,phi3,m1,m2,m3,n1,n2,n3,omega1,omega2,omega3;
    double *tempt,*temp0,*temp1,*temp2,*temp3,*temp4,*temp5,*temp6;

    y0 = mxGetPr(Y0_IN);

    M = max(mxGetM(Y0_IN),mxGetN(Y0_IN));// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)
    
    /*
     * Create and Initialize Return Arguments
     */

    t1 = rayparam.t0[0];
    
    psin1 = y0[0];
    theta1 = y0[1];
    phi1 = y0[2];
    kpsin1 = y0[3];
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

    ydel = (double *) mxCalloc(M,sizeof(double));

    /*
     * Initialization
     */

    h = rayparam.dt0[0];

    k = 0;

    tempt[0] = t1;
    temp0[0] = psin1;
    temp1[0] = theta1;
    temp2[0] = phi1;
    temp3[0] = kpsin1;
    temp4[0] = m1;
    temp5[0] = n1;  
    temp6[0] = omega1;

    /*
     * The main loop
     */
//int ii=0;
    while ((t1 < rayparam.tfinal[0]) && (k < rayparam.kmax[0]-1)) {
//    for (ii=0;ii<50;ii++) {
//        ii++; 
        if ((t1 + h) > rayparam.tfinal[0]) {
            h = rayparam.tfinal[0] - t1;
        }

        /*
         * Compute the slopes
         */

        /* ts = t  and  s0 = y */

        ts = t1;
        s0[0] = psin1;
        s0[1] = theta1;
        s0[2] = phi1;
        s0[3] = kpsin1;
        s0[4] = m1;
        s0[5] = n1;
        s0[6] = omega1;
        
        for  (m = 0; m < M; m++) {
            y[m] = s0[m];
        }
        
        ray(mxGetPr(Y_OUT_TEMP1),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit,salpha_fit);          
        s1 = mxGetPr(Y_OUT_TEMP1);

        /* s2 = feval(F, t+h*alpha(1), y+h*s1*beta(1,1), param); */

        *t = ts + h*alpha[0];
        for  (m = 0; m < M; m++) {
            y[m] = s0[m]+h*s1[m]*beta[0][0];
        }
        y[5] = n1;// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)
        y[6] = omega1;// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)

        ray(mxGetPr(Y_OUT_TEMP2),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit,salpha_fit);
        s2 = mxGetPr(Y_OUT_TEMP2);

        /* s3 = feval(F, t+h*alpha(2), y+h*[s1*beta(2,1)+s2*beta(2,2)], param); */

        *t = ts + h*alpha[1];
        for  (m = 0; m < M; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][1] + s2[m]*beta[1][1]);
        }
        y[5] = n1;// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)
        y[6] = omega1;// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)

        ray(mxGetPr(Y_OUT_TEMP3),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit,salpha_fit);
        s3 = mxGetPr(Y_OUT_TEMP3);

        /* s4 = feval(F, t+h*alpha(3), y+h*[s1*beta(3,1)+s2*beta(3,2)+...], param); */

        *t = ts + h*alpha[2];
        for  (m = 0; m < M; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][2] + s2[m]*beta[1][2]
                    +s3[m]*beta[2][2]);
        }
        y[5] = n1;// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)
        y[6] = omega1;// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)
        
        ray(mxGetPr(Y_OUT_TEMP4),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit,salpha_fit);
        s4 = mxGetPr(Y_OUT_TEMP4);

        /* s5 = feval(F, t+h*alpha(4), y+h*[s1*beta(4,1)+s2*beta(4,2)+...], param); */

        *t = ts + h*alpha[3];
        for  (m = 0; m < M; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][3] + s2[m]*beta[1][3]
                    +s3[m]*beta[2][3] + s4[m]*beta[3][3]);
        }
        y[5] = n1;// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)
        y[6] = omega1;// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)
        
        ray(mxGetPr(Y_OUT_TEMP5),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit,salpha_fit);
        s5 = mxGetPr(Y_OUT_TEMP5);

        /* s6 = feval(F, t+h*alpha(5), y+h*[s1*beta(5,1)+s2*beta(5,2)+...], param); */

        *t = ts + h*alpha[4];
        for  (m = 0; m < M; m++) {
            y[m] = s0[m]+h*(s1[m]*beta[0][4] + s2[m]*beta[1][4]
                    +s3[m]*beta[2][4] + s4[m]*beta[3][4]
                    +s5[m]*beta[4][4]);
        }
        y[5] = n1;// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)
        y[6] = omega1;// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)
        
        ray(mxGetPr(Y_OUT_TEMP6),y,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit,salpha_fit);
        s6 = mxGetPr(Y_OUT_TEMP6);

        /*
         * Estimate the error and the acceptable error
         */

        for  (m = 0; m < M; m++) {
            ydel[m] = h*(s1[m]*gama[0][1] + s2[m]*gama[1][1]
                    + s3[m]*gama[2][1] + s4[m]*gama[3][1]
                    + s5[m]*gama[4][1] + s6[m]*gama[5][1]);
        }

        delta = inf_norm(ydel,M-2);// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)
        ymax = inf_norm(s0,M-2);// only the first five coordinates are evolving (psin,theta,phi,kpsin,m)
        tau = rayparam.tol[0]*max(ymax,1.0);        
        

        /*
         * Update the solution only if the error is acceptable
         */

         if (delta <= tau) {
            
            t2 = t1 + h;
            psin2 = psin1 + h*(s1[0]*gama[0][0] + s2[0]*gama[1][0]
                     + s3[0]*gama[2][0] + s4[0]*gama[3][0]
                     + s5[0]*gama[4][0] + s6[0]*gama[5][0]);
            theta2 = theta1 + h*(s1[1]*gama[0][0] + s2[1]*gama[1][0]
                     + s3[1]*gama[2][0] + s4[1]*gama[3][0]
                     + s5[1]*gama[4][0] + s6[1]*gama[5][0]);
            phi2 = phi1 + h*(s1[2]*gama[0][0] + s2[2]*gama[1][0]
                     + s3[2]*gama[2][0] + s4[2]*gama[3][0]
                     + s5[2]*gama[4][0] + s6[2]*gama[5][0]);
            kpsin2 = kpsin1 + h*(s1[3]*gama[0][0] + s2[3]*gama[1][0]
                     + s3[3]*gama[2][0] + s4[3]*gama[3][0]
                     + s5[3]*gama[4][0] + s6[3]*gama[5][0]);
            m2 = m1 + h*(s1[4]*gama[0][0] + s2[4]*gama[1][0]
                     + s3[4]*gama[2][0] + s4[4]*gama[3][0]
                     + s5[4]*gama[4][0] + s6[4]*gama[5][0]);
            n2 = n1;
            omega2 = omega1;

            
            if ((psin1<11) && (psin2>1)) {//Specular reflexion enforced at psin = 1

            }
            

            if (absx(psin2-psin3) >= rayparam.dpsin[0]) {
                K = k+1;
                tempt[K] = t1;
                temp0[K] = psin2;
                temp1[K] = theta2;
                temp2[K] = phi2;
                temp3[K] = kpsin2;
                temp4[K] = m2;
                temp5[K] = n2;
                temp6[K] = omega2;
                
                t3 = t1;
                psin3 = psin2;
                theta3 = theta2;
                phi3 = phi2;
                kpsin3 = kpsin2;
                m3 = m2;
                n3 = n2;
                omega3 = omega2;

                k++;
            }
            
            t1 = t2;
            psin1 = psin2;
            theta1 = theta2;
            phi1 = phi2;
            kpsin1 = kpsin2;
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
        mexPrintf("Singularity likely at t = %f or matrix full\n",t1);
    }

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
    data.dpsin = mxGetData(mxGetField(structure_name, 0, "dpsin"));
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
        fit.form_dfdpsin = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dfdpsin = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dfdpsin = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dfdpsin = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dfdpsin = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dfdpsin = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dfdpsin = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
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
        fit.form_da0dpsin = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_da0dpsin = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_da0dpsin = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_da0dpsin = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_da0dpsin = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_da0dpsin = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_da0dpsin = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
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
        fit.form_dandpsin = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dandpsin = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dandpsin = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dandpsin = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dandpsin = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dandpsin = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dandpsin = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
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
        fit.form_dbndpsin = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dbndpsin = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dbndpsin = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dbndpsin = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dbndpsin = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dbndpsin = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dbndpsin = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
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
    
    for (j = 0;j < (int)in.pieces_dfdpsin[0];j++) {
        if ((x>=in.breaks_dfdpsin[j]) && (x<=in.breaks_dfdpsin[j+1])) {
            for (k = 1;k <= (int)in.dim_dfdpsin[0]; k++) {
                if ((int)in.order_dfdpsin[0] == 2) {
                    i0 = k-1+j*(int)in.dim_dfdpsin[0] + 0*(int)in.pieces_dfdpsin[0]*(int)in.dim_dfdpsin[0];
                    i1 = k-1+j*(int)in.dim_dfdpsin[0] + 1*(int)in.pieces_dfdpsin[0]*(int)in.dim_dfdpsin[0];
                    dydx[k-1] = in.coefs_dfdpsin[i0]*(x - in.breaks_dfdpsin[j]) + in.coefs_dfdpsin[i1];
                } else if ((int)in.order_dfdpsin[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dfdpsin[0] + 0*(int)in.pieces_dfdpsin[0]*(int)in.dim_dfdpsin[0];
                    i1 = k-1+j*(int)in.dim_dfdpsin[0] + 1*(int)in.pieces_dfdpsin[0]*(int)in.dim_dfdpsin[0];
                    i2 = k-1+j*(int)in.dim_dfdpsin[0] + 2*(int)in.pieces_dfdpsin[0]*(int)in.dim_dfdpsin[0];                    
                    dydx[k-1] = in.coefs_dfdpsin[i0]*pow((x - in.breaks_dfdpsin[j]),2) + in.coefs_dfdpsin[i1]*(x - in.breaks_dfdpsin[j]) + in.coefs_dfdpsin[i2];
//                    mexPrintf("k,dydx: %d%g\n",k,dydx[k-1]); 
                } else if ((int)in.order_dfdpsin[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dfdpsin[0] + 0*(int)in.pieces_dfdpsin[0]*(int)in.dim_dfdpsin[0];
                    i1 = k-1+j*(int)in.dim_dfdpsin[0] + 1*(int)in.pieces_dfdpsin[0]*(int)in.dim_dfdpsin[0];
                    i2 = k-1+j*(int)in.dim_dfdpsin[0] + 2*(int)in.pieces_dfdpsin[0]*(int)in.dim_dfdpsin[0];
                    i3 = k-1+j*(int)in.dim_dfdpsin[0] + 3*(int)in.pieces_dfdpsin[0]*(int)in.dim_dfdpsin[0];
                    dydx[k-1] = in.coefs_dfdpsin[i0]*pow((x - in.breaks_dfdpsin[j]),3) + in.coefs_dfdpsin[i1]*pow((x - in.breaks_dfdpsin[j]),2) + in.coefs_dfdpsin[i2]*(x - in.breaks_dfdpsin[j]) + in.coefs_dfdpsin[i3];
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
    da0dx = mxCalloc((int)in.dim_da0dpsin[0],sizeof(double));
    an = mxCalloc((int)in.dim_an[0],sizeof(double));
    dandx = mxCalloc((int)in.dim_dandpsin[0],sizeof(double));
    bn = mxCalloc((int)in.dim_bn[0],sizeof(double));
    dbndx = mxCalloc((int)in.dim_dbndpsin[0],sizeof(double));

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
    
    for (j = 0;j < (int)in.pieces_da0dpsin[0];j++) {
        if ((x>=in.breaks_da0dpsin[j]) && (x<=in.breaks_da0dpsin[j+1])) {
            for (k = 1;k <= (int)in.dim_da0dpsin[0]; k++) {
                if ((int)in.order_da0dpsin[0] == 2) {
                    i0 = k-1+j*(int)in.dim_da0dpsin[0] + 0*(int)in.pieces_da0dpsin[0]*(int)in.dim_da0dpsin[0];
                    i1 = k-1+j*(int)in.dim_da0dpsin[0] + 1*(int)in.pieces_da0dpsin[0]*(int)in.dim_da0dpsin[0];
                    da0dx[k-1] = in.coefs_da0dpsin[i0]*(x - in.breaks_da0dpsin[j]) + in.coefs_da0dpsin[i1];
                } else if ((int)in.order_da0dpsin[0] == 3) {
                    i0 = k-1+j*(int)in.dim_da0dpsin[0] + 0*(int)in.pieces_da0dpsin[0]*(int)in.dim_da0dpsin[0];
                    i1 = k-1+j*(int)in.dim_da0dpsin[0] + 1*(int)in.pieces_da0dpsin[0]*(int)in.dim_da0dpsin[0];
                    i2 = k-1+j*(int)in.dim_da0dpsin[0] + 2*(int)in.pieces_da0dpsin[0]*(int)in.dim_da0dpsin[0];                    
                    da0dx[k-1] = in.coefs_da0dpsin[i0]*pow((x - in.breaks_da0dpsin[j]),2) + in.coefs_da0dpsin[i1]*(x - in.breaks_da0dpsin[j]) + in.coefs_da0dpsin[i2];
                } else if ((int)in.order_da0dpsin[0] == 4) {
                    i0 = k-1+j*(int)in.dim_da0dpsin[0] + 0*(int)in.pieces_da0dpsin[0]*(int)in.dim_da0dpsin[0];
                    i1 = k-1+j*(int)in.dim_da0dpsin[0] + 1*(int)in.pieces_da0dpsin[0]*(int)in.dim_da0dpsin[0];
                    i2 = k-1+j*(int)in.dim_da0dpsin[0] + 2*(int)in.pieces_da0dpsin[0]*(int)in.dim_da0dpsin[0];
                    i3 = k-1+j*(int)in.dim_da0dpsin[0] + 3*(int)in.pieces_da0dpsin[0]*(int)in.dim_da0dpsin[0];
                    da0dx[k-1] = in.coefs_da0dpsin[i0]*pow((x - in.breaks_da0dpsin[j]),3) + in.coefs_da0dpsin[i1]*pow((x - in.breaks_da0dpsin[j]),2) + in.coefs_da0dpsin[i2]*(x - in.breaks_da0dpsin[j]) + in.coefs_da0dpsin[i3];
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
    
    for (j = 0;j < (int)in.pieces_dandpsin[0];j++) {
        if ((x>=in.breaks_dandpsin[j]) && (x<=in.breaks_dandpsin[j+1])) {
            for (k = 1;k <= (int)in.dim_dandpsin[0]; k++) {
                if ((int)in.order_dandpsin[0] == 2) {
                    i0 = k-1+j*(int)in.dim_dandpsin[0] + 0*(int)in.pieces_dandpsin[0]*(int)in.dim_dandpsin[0];
                    i1 = k-1+j*(int)in.dim_dandpsin[0] + 1*(int)in.pieces_dandpsin[0]*(int)in.dim_dandpsin[0];
                    dandx[k-1] = in.coefs_dandpsin[i0]*(x - in.breaks_dandpsin[j]) + in.coefs_dandpsin[i1];
                } else if ((int)in.order_dandpsin[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dandpsin[0] + 0*(int)in.pieces_dandpsin[0]*(int)in.dim_dandpsin[0];
                    i1 = k-1+j*(int)in.dim_dandpsin[0] + 1*(int)in.pieces_dandpsin[0]*(int)in.dim_dandpsin[0];
                    i2 = k-1+j*(int)in.dim_dandpsin[0] + 2*(int)in.pieces_dandpsin[0]*(int)in.dim_dandpsin[0];                    
                    dandx[k-1] = in.coefs_dandpsin[i0]*pow((x - in.breaks_dandpsin[j]),2) + in.coefs_dandpsin[i1]*(x - in.breaks_dandpsin[j]) + in.coefs_dandpsin[i2];
                } else if ((int)in.order_dandpsin[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dandpsin[0] + 0*(int)in.pieces_dandpsin[0]*(int)in.dim_dandpsin[0];
                    i1 = k-1+j*(int)in.dim_dandpsin[0] + 1*(int)in.pieces_dandpsin[0]*(int)in.dim_dandpsin[0];
                    i2 = k-1+j*(int)in.dim_dandpsin[0] + 2*(int)in.pieces_dandpsin[0]*(int)in.dim_dandpsin[0];
                    i3 = k-1+j*(int)in.dim_dandpsin[0] + 3*(int)in.pieces_dandpsin[0]*(int)in.dim_dandpsin[0];
                    dandx[k-1] = in.coefs_dandpsin[i0]*pow((x - in.breaks_dandpsin[j]),3) + in.coefs_dandpsin[i1]*pow((x - in.breaks_dandpsin[j]),2) + in.coefs_dandpsin[i2]*(x - in.breaks_dandpsin[j]) + in.coefs_dandpsin[i3];
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
    
    for (j = 0;j < (int)in.pieces_dbndpsin[0];j++) {
        if ((x>=in.breaks_dbndpsin[j]) && (x<=in.breaks_dbndpsin[j+1])) {
            for (k = 1;k <= (int)in.dim_dbndpsin[0]; k++) {
                if ((int)in.order_dbndpsin[0] == 2) {
                    i0 = k-1+j*(int)in.dim_dbndpsin[0] + 0*(int)in.pieces_dbndpsin[0]*(int)in.dim_dbndpsin[0];
                    i1 = k-1+j*(int)in.dim_dbndpsin[0] + 1*(int)in.pieces_dbndpsin[0]*(int)in.dim_dbndpsin[0];
                    dbndx[k-1] = in.coefs_dbndpsin[i0]*(x - in.breaks_dbndpsin[j]) + in.coefs_dbndpsin[i1];
                } else if ((int)in.order_dbndpsin[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dbndpsin[0] + 0*(int)in.pieces_dbndpsin[0]*(int)in.dim_dbndpsin[0];
                    i1 = k-1+j*(int)in.dim_dbndpsin[0] + 1*(int)in.pieces_dbndpsin[0]*(int)in.dim_dbndpsin[0];
                    i2 = k-1+j*(int)in.dim_dbndpsin[0] + 2*(int)in.pieces_dbndpsin[0]*(int)in.dim_dbndpsin[0];                    
                    dbndx[k-1] = in.coefs_dbndpsin[i0]*pow((x - in.breaks_dbndpsin[j]),2) + in.coefs_dbndpsin[i1]*(x - in.breaks_dbndpsin[j]) + in.coefs_dbndpsin[i2];
                } else if ((int)in.order_dbndpsin[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dbndpsin[0] + 0*(int)in.pieces_dbndpsin[0]*(int)in.dim_dbndpsin[0];
                    i1 = k-1+j*(int)in.dim_dbndpsin[0] + 1*(int)in.pieces_dbndpsin[0]*(int)in.dim_dbndpsin[0];
                    i2 = k-1+j*(int)in.dim_dbndpsin[0] + 2*(int)in.pieces_dbndpsin[0]*(int)in.dim_dbndpsin[0];
                    i3 = k-1+j*(int)in.dim_dbndpsin[0] + 3*(int)in.pieces_dbndpsin[0]*(int)in.dim_dbndpsin[0];
                    dbndx[k-1] = in.coefs_dbndpsin[i0]*pow((x - in.breaks_dbndpsin[j]),3) + in.coefs_dbndpsin[i1]*pow((x - in.breaks_dbndpsin[j]),2) + in.coefs_dbndpsin[i2]*(x - in.breaks_dbndpsin[j]) + in.coefs_dbndpsin[i3];
                }
            }
        }
    }   
    
    y[0] = 0.0;
    dydx[0] = 0.0;
    dydt[0] = 0.0;
    
    for (k = 1;k <= (int)in.dim_dbndpsin[0]; k++) {
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
    double  temp_max;

    temp_max = absx(y[0]);

    for (m = 1; m < M; m++) {
        temp_max = max(temp_max,absx(y[m]));
    }

    return(temp_max);
}

/*General coordinate time evolution dY/dt with Y=[psin,theta,phi,kpsin,m,n,omega/c]*/


void ray(Ydot,Y,param,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit,salpha_fit)
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
pp_2D_format salpha_fit;
{
double qe = 1.602176462e-19;//Absolute value of the electron charge (C)
double me = 9.10938188e-31;//Electron rest mass (Kg)
double mp = 1.67262158e-27;//Proton rest mass (Kg)
double epsi0 = 8.854187818e-12;//Free space permittivity (F/m)
double mu0 = 12.566370614e-7;//Free space permeability (F/m)
double clum = 299792458;//Speed of light (m/s)
double mc2 = 510.998902;//Electron energy rest mass (keV)

double complex D[43],dDdx[43][8],Dtot,dDtotdx[8];

double dYdY[8][8];

double *BPHI,*dBPHIdx,*BP,*dBPdx,*B,*dBdx;
double *R,*dRdx,*r,*drdx;
double *calpha,*dcalphadx,*salpha,*dsalphadx;

double Te,dTedx[8],ne,dnedx[8];
double zTi[equilparam.ns[0]],zni[equilparam.ns[0]];
double dzTidx[equilparam.ns[0]][8],dznidx[equilparam.ns[0]][8];
double dummyTi[equilparam.ns[0]],dummyni[equilparam.ns[0]];

double wcn[equilparam.ns[0]+1],wpn2[equilparam.ns[0]+1],betath[equilparam.ns[0]+1];
double dwcndx[equilparam.ns[0]+1][8],dwpn2dx[equilparam.ns[0]+1][8],dbetathdx[equilparam.ns[0]+1][8];

double Npar,dNpardx[8];
double complex Nperp,dNperpdx[8];

double complex Nperp4,Nperp3,Nperp2,Nperp1;
double Npar4,Npar3,Npar2,Npar1;
double complex Xxx,Xxy,Xxz,Xyy,Xyz,Xzz;
double complex Xxx2,Xxy2,Xxz2,Xyy2,Xyz2,Xzz2;


raymagnetic_format raymagnetic;
susceptibilitytensor_format X;

register int i,j,is;

// Memory allocation

for (i=0;i<8;i++) {//initialisation
   dTedx[i] = 0.0; 
   dnedx[i] = 0.0;
}

for (i = 0;i < equilparam.ns[0]; i++) {//initialisation
   for (j=0;j<8;j++) {
       dzTidx[i][j] = 0.0;
       dznidx[i][j] = 0.0;
   }
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

for (i = 0;i < 8; i++) {//initialisation
    raymagnetic.drdx[i] = 0.0;
    raymagnetic.dRdx[i] = 0.0;
    raymagnetic.dsalphadx[i] = 0.0;
    raymagnetic.dcalphadx[i] = 0.0;
    raymagnetic.dBPdx[i] = 0.0;
    raymagnetic.dBPHIdx[i] = 0.0;
    raymagnetic.dBdx[i] = 0.0;
}

for (i = 0;i < equilparam.ns[0] + 1; i++) {//initialisation
    wcn[i] = 0.0;
    wpn2[i] = 0.0;
    betath[i] = 0.0;
    for (j=0;j<8;j++) {
        dwcndx[i][j] = 0.0;
        dwpn2dx[i][j] = 0.0;
        dbetathdx[i][j] = 0.0;
    }
}

for (i=0;i<8;i++) {//initialisation
    dNpardx[i] = 0.0;
    dNperpdx[i] = 0.0;
}

X.Xxx = mxCalloc(1,sizeof(double complex));
X.Xxy = mxCalloc(1,sizeof(double complex));
X.Xxz = mxCalloc(1,sizeof(double complex));
X.Xyy = mxCalloc(1,sizeof(double complex));
X.Xyz = mxCalloc(1,sizeof(double complex));
X.Xzz = mxCalloc(1,sizeof(double complex));

X.dXxxdx = mxCalloc(8,sizeof(double complex));
X.dXxydx = mxCalloc(8,sizeof(double complex));
X.dXxzdx = mxCalloc(8,sizeof(double complex));
X.dXyydx = mxCalloc(8,sizeof(double complex));
X.dXyzdx = mxCalloc(8,sizeof(double complex));
X.dXzzdx = mxCalloc(8,sizeof(double complex));

for (i=0;i<8;i++) {//initialisation
    X.dXxxdx[i] = 0.0;
    X.dXxydx[i] = 0.0;
    X.dXxzdx[i] = 0.0;
    X.dXyydx[i] = 0.0;
    X.dXyzdx[i] = 0.0;
    X.dXzzdx[i] = 0.0;
}

// Equilibrium interpolation
ppval_1D(Te_fit,Y[0],&Te,&dTedx[0]);
ppval_1D(ne_fit,Y[0],&ne,&dnedx[0]);

ppval_1D(zTi_fit,Y[0],zTi,dummyTi);
for (is=0;is<equilparam.ns[0];is++) {
    dzTidx[is][0] = dummyTi[is];
}
ppval_1D(zni_fit,Y[0],zni,dummyni);
for (is=0;is<equilparam.ns[0];is++) {
    dznidx[is][0] = dummyni[is];
}

//for (i=0;i<equilparam.ns[0];i++) {
//    mexPrintf("i,Ti,dzTidx[0],dzTidx[1],dzTidx[2],dzTidx[3],dzTidx[4],dzTidx[5],dzTidx[6]:%d,%g,%g,%g,%g,%g,%g,%g,%g\n",i,zTi[i],dzTidx[i][0],dzTidx[i][1],dzTidx[i][2],dzTidx[i][3],dzTidx[i][4],dzTidx[i][5],dzTidx[i][6]);
//    mexPrintf("i,ni,dznidx[0],dznidx[1],dznidx[2],dznidx[3],dznidx[4],dznidx[5],dznidx[6]:%d,%g,%g,%g,%g,%g,%g,%g,%g\n",i,zni[i],dznidx[i][0],dznidx[i][1],dznidx[i][2],dznidx[i][3],dznidx[i][4],dznidx[i][5],dznidx[i][6]);
//}

ppval_2D(BPHI_fit,Y[0],Y[1],&raymagnetic.BPHI[0],&raymagnetic.dBPHIdx[0],&raymagnetic.dBPHIdx[1]);
ppval_2D(BP_fit,Y[0],Y[1],&raymagnetic.BP[0],&raymagnetic.dBPdx[0],&raymagnetic.dBPdx[1]);
ppval_2D(R_fit,Y[0],Y[1],&raymagnetic.R[0],&raymagnetic.dRdx[0],&raymagnetic.dRdx[1]);
ppval_2D(r_fit,Y[0],Y[1],&raymagnetic.r[0],&raymagnetic.drdx[0],&raymagnetic.drdx[1]);
ppval_2D(calpha_fit,Y[0],Y[1],&raymagnetic.calpha[0],&raymagnetic.dcalphadx[0],&raymagnetic.dcalphadx[1]);
ppval_2D(salpha_fit,Y[0],Y[1],&raymagnetic.salpha[0],&raymagnetic.dsalphadx[0],&raymagnetic.dsalphadx[1]);

raymagnetic.B[0] = sqrt(pow(raymagnetic.BPHI[0],2)+pow(raymagnetic.BP[0],2));// total magnetic field
raymagnetic.dBdx[0] = (raymagnetic.BP[0]*raymagnetic.dBPdx[0]+raymagnetic.BPHI[0]*raymagnetic.dBPHIdx[0])/raymagnetic.B[0];
raymagnetic.dBdx[1] = (raymagnetic.BP[0]*raymagnetic.dBPdx[1]+raymagnetic.BPHI[0]*raymagnetic.dBPHIdx[1])/raymagnetic.B[0];

// Normalized parameters

wcn[0] = -qe*raymagnetic.B[0]/me/Y[6];//electrons
dwcndx[0][0] = -qe*raymagnetic.dBdx[0]/me/Y[6];
dwcndx[0][1] = -qe*raymagnetic.dBdx[1]/me/Y[6];
dwcndx[0][6] = -wcn[0];

wpn2[0] = qe*qe*ne/epsi0/me/Y[6]/Y[6];//electrons
dwpn2dx[0][0] = qe*qe*dnedx[0]/epsi0/me/Y[6]/Y[6];
dwpn2dx[0][6] = -2.0*wpn2[0];

betath[0] = sqrt(Te/mc2);
dbetathdx[0][0] = dTedx[0]/betath[0]/2.0;

for (is = 1;is < equilparam.ns[0]+1; is++) {
    if (zni[is-1] > 0.0) {
        wcn[is] = qe*equilparam.zZi[is-1]*raymagnetic.B[0]/equilparam.zmi[is-1]/mp/Y[6];//ions
        dwcndx[is][0] = qe*equilparam.zZi[is-1]*raymagnetic.dBdx[0]/equilparam.zmi[is-1]/mp/Y[6];
        dwcndx[is][1] = qe*equilparam.zZi[is-1]*raymagnetic.dBdx[1]/equilparam.zmi[is-1]/mp/Y[6]; 
        dwcndx[is][6] = -wcn[is]; 

        wpn2[is] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*zni[is-1]/epsi0/equilparam.zmi[is-1]/mp/Y[6]/Y[6];//ions
        dwpn2dx[is][0] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*dznidx[is-1][0]/epsi0/equilparam.zmi[is-1]/mp/Y[6]/Y[6];        
        dwpn2dx[is][6] = -2.0*wpn2[is]; 
    
        betath[is] = sqrt(zTi[is-1]*me/equilparam.zmi[is-1]/mp/mc2);
        dbetathdx[is][0] = dzTidx[is-1][0]/betath[is]/2.0;
    } else {
        
        
    }
}

//Covariant matrix

for (i=0;i<8;i++) {
    for (j=0;j<8;j++) {
        if ((i==j) && (i<6)) {
            dYdY[i][j] = 1.0;
        } else {
            dYdY[i][j] = 0.0;
        }
    }
}

// Refractive index calculation
rayindex(Y,dYdY,raymagnetic,equilparam,&Npar,&Nperp,dNpardx,dNperpdx);
//mexPrintf("r,R,BP,kpsin,sina,cosa,B,BPHI:%g,%g,%g,%g,%g,%g,%g,%g\n",raymagnetic.r[0],raymagnetic.R[0],raymagnetic.BP[0],Y[3],raymagnetic.salpha[0],raymagnetic.calpha[0],raymagnetic.B[0],raymagnetic.BPHI[0]);
//mexPrintf("Npar,w*dNpardw,Nperpr,Nperpi,w*dNperpdwr,w*dNperpdwi:%g,%g,%g,%g,%g,%g\n",Npar,dNpardx[6],Nperp,dNperpdx[6]);
//mexPrintf("wce[0],w*dwcedw[0],wce[1],w*dwcedw[1]:%g,%g,%g,%g\n",wcn[0],dwcndx[0][6],wcn[1],dwcndx[1][6]);
//mexPrintf("wpn2[0],w*dwpn2dw[0],wpn2[1],w*dwpn2dw[1]:%g,%g,%g,%g\n",wpn2[0],dwpn2dx[0][6],wpn2[1],dwpn2dx[1][6]);
//mexPrintf("wce[0],dwcedn[0],wce[1],dwcedn[1]:%g,%g,%g,%g\n",wcn[0],dwcndx[0][5],wcn[1],dwcndx[1][5]);
//mexPrintf("wpn2[0],dwpn2dn[0],wpn2[1],dwpn2dn[1]:%g,%g,%g,%g\n",wpn2[0],dwpn2dx[0][5],wpn2[1],dwpn2dx[1][5]);

// Susceptibility tensor 

susceptibility(X,param.tensortype[0],equilparam.ns[0],Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx);

// Dispersion relation

Nperp4 = Nperp*Nperp*Nperp*Nperp;
Nperp3 = Nperp*Nperp*Nperp;
Nperp2 = Nperp*Nperp;
Nperp1 = Nperp;
Npar4 = Npar*Npar*Npar*Npar;
Npar3 = Npar*Npar*Npar;
Npar2 = Npar*Npar;
Npar1 = Npar;
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

//mexPrintf("Nperp4r,Nperp4i:%g,%g\n",creal(Nperp4),cimag(Nperp4));
//mexPrintf("Npar:%g\n",Npar1);
//mexPrintf("Nperpr,Nperpi:%g,%g\n",creal(Nperp1),cimag(Nperp1));
//mexPrintf("Xxxr,XXxxi:%g,%g\n",creal(Xxx),cimag(Xxx));
//mexPrintf("Xxyr,XXxyi:%g,%g\n",creal(Xxy),cimag(Xxy));
//mexPrintf("Xxzr,XXxzi:%g,%g\n",creal(Xxz),cimag(Xxz));
//mexPrintf("Xyyr,XXyyi:%g,%g\n",creal(Xyy),cimag(Xyy));
//mexPrintf("Xyzr,XXyzi:%g,%g\n",creal(Xyz),cimag(Xyz));
//mexPrintf("Xzzr,XXzzi:%g,%g\n",creal(Xzz),cimag(Xzz));

//double complex Dtot1;
//Dtot1 = 1+2*Xxy*Xyz*Xxz+(Xxx+1)*Nperp4+(Xxx*Npar2-Xzz+2*Npar2-Xxy2-2*Xxx-Xxx*Xzz-2+Xxz2-Xyy+Npar2*Xzz-Xxx*Xyy)*Nperp2+(-2*Npar1*Xyy*Xxz-2*Npar1*Xxz+2*Xxy*Xyz*Npar1+2*Npar3*Xxz)*Nperp1-Xxx*Npar2*Xzz+Xxx*Xyy*Xzz-Npar2*Xyy*Xzz+Xyy*Xzz+Npar4*Xzz-Npar2*Xyy-Npar2*Xyz2+Xxx*Xzz-Xxx*Npar2+Xxx*Xyy+Xxy2*Xzz+Npar2*Xxz2-Xyy*Xxz2-2*Npar2*Xzz+Xyy+Xxx*Xyz2-Xxz2-2*Npar2+Xyz2+2*Nperp3*Npar1*Xxz+Xxx+Xzz+Npar4+Xxy2;
//mexPrintf("Dtot1:%g\n",Dtot1);

D[0] = Nperp4;
D[1] = Xxx*Nperp4;
D[2] = 2.0*Npar1*Xxz*Nperp3;
D[3] = Npar2*Xxx*Nperp2;
D[4] = Npar2*Xzz*Nperp2;
D[5] = 2.0*Npar2*Nperp2;
D[6] = -2.0*Xxx*Nperp2;
D[7] = -Xyy*Nperp2;
D[8] = -Xzz*Nperp2;
D[9] = -Xxx*Xzz*Nperp2;
D[10] = Xxz2*Nperp2;
D[11] = -Xxx*Xyy*Nperp2;
D[12] = -Xxy2*Nperp2;
D[13] = -2.0*Nperp2;
D[14] = -2.0*Npar1*Xyy*Xxz*Nperp1;
D[15] = 2.0*Npar1*Xxy*Xyz*Nperp1;
D[16] = -2.0*Npar1*Xxz*Nperp1;
D[17] = 2.0*Npar3*Xxz*Nperp1;
D[18] = 1.0;
D[19] = Npar4*Xzz;
D[20] = Npar4;
D[21] = Npar2*Xxz2;
D[22] = -Npar2*Xyy*Xzz;
D[23] = -Npar2*Xxx*Xzz;
D[24] = -2.0*Npar2*Xzz;
D[25] = -Npar2*Xyy;
D[26] = -Npar2*Xyz2;
D[27] = -Npar2*Xxx;
D[28] = -2.0*Npar2;
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
D[42] = 2.0*Xxy*Xyz*Xxz;

//for (i = 0;i<43;i++) {
//    mexPrintf("i,Dr,Di:%d,%g\n",i,creal(D[i]),cimag(D[i]));
//}

for (i = 0;i<8;i++) {
    dDdx[0][i] = 4.0*Nperp3*dNperpdx[i];
    dDdx[1][i] = X.dXxxdx[i]*Nperp4 + 4.0*Xxx*Nperp3*dNperpdx[i];
    dDdx[2][i] = 2.0*dNpardx[i]*Xxz*Nperp3 + 2.0*Npar1*X.dXxzdx[i]*Npar3 + 6.0*Npar1*Xxz*dNperpdx[i]*Nperp2;    
    dDdx[3][i] = 2.0*Npar1*dNpardx[i]*Xxx*Nperp2 + Npar2*X.dXxxdx[i]*Nperp2 + 2.0*Npar2*Xxx*Nperp1*dNperpdx[i];
    dDdx[4][i] = 2.0*Npar1*dNpardx[i]*Xzz*Nperp2 + Npar2*X.dXzzdx[i]*Nperp2 + 2.0*Npar2*Xzz*Nperp1*dNperpdx[i];
    dDdx[5][i] = 4.0*Npar1*dNpardx[i]*Nperp2 + 4.0*Npar2*Nperp1*dNperpdx[i];
    dDdx[6][i] = -2.0*X.dXxxdx[i]*Nperp2 - 4.0*Xxx*Nperp1*dNperpdx[i];
    dDdx[7][i] = -X.dXyydx[i]*Nperp2 - 2.0*Xyy*Nperp1*dNperpdx[i];
    dDdx[8][i] = -X.dXzzdx[i]*Nperp2 - 2.0*Xzz*Nperp1*dNperpdx[i];
    dDdx[9][i] = -X.dXxxdx[i]*Xzz*Nperp2 - Xxx*X.dXzzdx[i]*Nperp2 - 2.0*Xxx*Xzz*Nperp1*dNperpdx[i];
    dDdx[10][i] = 2.0*Xxz*X.dXxzdx[i]*Nperp2 + 2.0*Xxz2*Nperp1*dNperpdx[i];
    dDdx[11][i] = -X.dXxxdx[i]*Xyy*Nperp2 - Xxx*X.dXyydx[i]*Nperp2 - 2.0*Xxx*Xyy*Nperp1*dNperpdx[i];
    dDdx[12][i] = -2.0*X.dXxydx[i]*Xxy*Nperp2 - 2.0*Xxy2*Nperp1*dNperpdx[i];
    dDdx[13][i] = -4.0*Nperp1*dNperpdx[i];
    dDdx[14][i] = -2.0*dNpardx[i]*Xyy*Xxz*Nperp1 - 2.0*Npar1*X.dXyydx[i]*Xxz*Nperp1 - 2.0*Npar1*Xyy*X.dXxzdx[i]*Nperp1 - 2.0*Npar1*Xyy*Xxz*dNperpdx[i];
    dDdx[15][i] = 2.0*dNpardx[i]*Xxy*Xyz*Nperp1 + 2.0*Npar1*X.dXxydx[i]*Xyz*Nperp1 + 2.0*Npar1*Xxy*X.dXyzdx[i]*Nperp1 + 2.0*Npar1*Xxy*Xyz*dNperpdx[i];
    dDdx[16][i] = -2.0*dNpardx[i]*Xxz*Nperp1 - 2.0*Npar1*X.dXxzdx[i]*Nperp1 - 2.0*Npar1*Xxz*dNperpdx[i];
    dDdx[17][i] = 6.0*Npar2*dNpardx[i]*Xxz*Nperp1 + 2.0*Npar3*X.dXxzdx[i]*Nperp1 + 2.0*Npar3*Xxz*dNperpdx[i];
    dDdx[18][i] = 0.0;
    dDdx[19][i] = 4.0*Npar3*Xzz*dNpardx[i] + Npar4*X.dXzzdx[i];
    dDdx[20][i] = 4.0*Npar3*dNpardx[i];
    dDdx[21][i] = 2.0*Npar1*dNpardx[i]*Xxz2 + 2.0*Npar2*Xxz*X.dXxzdx[i];
    dDdx[22][i] = -2.0*Npar1*dNpardx[i]*Xyy*Xzz - Npar2*X.dXyydx[i]*Xzz - Npar2*Xyy*X.dXzzdx[i];
    dDdx[23][i] = -2.0*Npar1*dNpardx[i]*Xxx*Xzz - Npar2*X.dXxxdx[i]*Xzz - Npar2*Xxx*X.dXzzdx[i];
    dDdx[24][i] = -4.0*Npar1*dNpardx[i]*Xzz - 2.0*Npar2*X.dXzzdx[i];
    dDdx[25][i] = -2.0*Npar1*dNpardx[i]*Xyy - Npar2*X.dXyydx[i];
    dDdx[26][i] = -2.0*Npar1*dNpardx[i]*Xyz2 - 2.0*Npar2*Xyz*X.dXyzdx[i];
    dDdx[27][i] = -2.0*Npar1*dNpardx[i]*Xxx - Npar2*X.dXxxdx[i];
    dDdx[28][i] = -4.0*Npar1*dNpardx[i];
    dDdx[29][i] = X.dXyydx[i]*Xzz + Xyy*X.dXzzdx[i];
    dDdx[30][i] = X.dXxxdx[i]*Xzz + Xxx*X.dXzzdx[i];
    dDdx[31][i] = X.dXxxdx[i]*Xyy + Xxx*X.dXyydx[i];
    dDdx[32][i] = X.dXxxdx[i]*Xyz2 + 2.0*Xxx*Xyz*X.dXyzdx[i];
    dDdx[33][i] = 2.0*Xyz*X.dXyzdx[i];
    dDdx[34][i] = X.dXxxdx[i];
    dDdx[35][i] = 2.0*Xxy*X.dXxydx[i];
    dDdx[36][i] = 2.0*Xxy*X.dXxydx[i]*Xzz + Xxy2*X.dXzzdx[i];
    dDdx[37][i] = -2.0*Xxz*X.dXxzdx[i];
    dDdx[38][i] = -X.dXyydx[i]*Xxz2 - 2.0*Xyy*Xxz*X.dXxzdx[i];
    dDdx[39][i] = X.dXyydx[i];
    dDdx[40][i] = X.dXzzdx[i];
    dDdx[41][i] = X.dXxxdx[i]*Xyy*Xzz + Xxx*X.dXyydx[i]*Xzz + Xxx*Xyy*X.dXzzdx[i];
    dDdx[42][i] = 2.0*X.dXxydx[i]*Xyz*Xxz + 2.0*Xxy*X.dXyzdx[i]*Xxz + 2.0*Xxy*Xyz*X.dXxzdx[i];
}

Dtot = 0.0;
for (i = 0;i<8;i++) {
    dDtotdx[i] = 0.0; 
}

for (i = 0;i<43;i++) {
    Dtot = Dtot + D[i];
    for (j=0;j<8;j++) {
        dDtotdx[j] = dDtotdx[j] + dDdx[i][j]; 
    }
}

//mexPrintf("Dtotr,Dtoti:%g,%g\n",creal(Dtot),cimag(Dtot));

Ydot[0] = creal(dDtotdx[3])/creal(dDtotdx[6]); 
Ydot[1] = creal(dDtotdx[4])/creal(dDtotdx[6]); 
Ydot[2] = creal(dDtotdx[5])/creal(dDtotdx[6]); 
Ydot[3] = -creal(dDtotdx[0])/creal(dDtotdx[6]); 
Ydot[4] = -creal(dDtotdx[1])/creal(dDtotdx[6]);
Ydot[5] = 0.0; 
Ydot[6] = 0.0; 

//mexPrintf("dDtotdx:%g\n",creal(dDtotdx[5]));
//mexPrintf("Ydot:%g,%g,%g,%g,%g,%g,%g\n",Ydot[0],Ydot[1],Ydot[2],Ydot[3],Ydot[4],Ydot[5],Ydot[6]);

// Memory is released 
    
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
}

void susceptibility(X,tensortype,ns,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx)
susceptibilitytensor_format X;
double tensortype;
double wcn[],wpn2[],betath[];
double dwcndx[][10],dwpn2dx[][10],dbetathdx[][10];
double Npar,dNpardx[];
double complex Nperp,dNperpdx[];
int ns;
{
    if (tensortype == 0) {
//        mexPrintf("Cold dielectric tensor\n");
        coldtensor(X,ns,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx);
    }
    if (tensortype == 1) {
//        mexPrintf("Warm dielectric tensor\n");
//        warmtensor(ns,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx);
    }
    if (tensortype == 2) {
//        mexPrintf("Hot dielectric tensor\n");
//        hottensor(ns,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx);
    }
    if (tensortype == 3) {
//        mexPrintf("Relativistic dielectric tensor\n");
//        relativistictensor(ns,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx);
    }       

} 


void rayindex(Y,dYdY,raymagnetic,equilparam,Npar,Nperp,dNpardx,dNperpdx)
double Y[];
double dYdY[][8];
double *Npar,*dNpardx;
double complex *Nperp,*dNperpdx;
raymagnetic_format raymagnetic;
equilparam_format equilparam;
{ 
    
    double Npar1,dNpar1dx,dNpar1dx1,dNpar1dx2,dNpar1dx3,dNpar1dx4,dNpar1dx5,dNpar1dx6;
    double Npar2,dNpar2dx,dNpar2dx1,dNpar2dx2,dNpar2dx3,dNpar2dx4,dNpar2dx5;
    
    double complex N2,dN2dx;   
    double complex N21,dN21dx,dN21dx1,dN21dx2,dN21dx3,dN21dx4;
    double complex N22,dN22dx,dN22dx1,dN22dx2,dN22dx3,dN22dx4,dN22dx5,dN22dx6,dN22dx7;
    double complex N23,dN23dx,dN23dx1,dN23dx2,dN23dx3;
    double complex N24,dN24dx,dN24dx1,dN24dx2,dN24dx3;
    
    double psia;
    double clum = 299792458;//Speed of light (m/s)

    register int i,j;
    
    psia = equilparam.psia[0];

    Npar1 = clum*Y[4]/raymagnetic.r[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0]/Y[6];
    Npar2 = clum*Y[5]*raymagnetic.BPHI[0]/raymagnetic.R[0]/raymagnetic.B[0]/Y[6];
  
    Npar[0] = Npar1 + Npar2;
    
    for (i=0;i<8;i++) {
    
        dNpar1dx1 = clum*dYdY[4][i]/raymagnetic.r[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0]/Y[6];
        dNpar1dx2 = -clum*raymagnetic.drdx[i]*Y[4]/raymagnetic.r[0]/raymagnetic.r[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0]/Y[6];
        dNpar1dx3 = clum*Y[4]/raymagnetic.r[0]*raymagnetic.dcalphadx[i]*raymagnetic.BP[0]/raymagnetic.B[0]/Y[6];
        dNpar1dx4 = clum*Y[4]/raymagnetic.r[0]*raymagnetic.calpha[0]*raymagnetic.dBPdx[i]/raymagnetic.B[0]/Y[6];
        dNpar1dx5 = -clum*Y[4]/raymagnetic.r[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]*raymagnetic.dBdx[i]/raymagnetic.B[0]/raymagnetic.B[0]/Y[6];
        dNpar1dx6 = -clum*Y[4]/raymagnetic.r[0]*raymagnetic.calpha[0]*raymagnetic.BP[0]/raymagnetic.B[0]*dYdY[6][i]/Y[6];
        
        dNpar1dx = dNpar1dx1 + dNpar1dx2 + dNpar1dx3 + dNpar1dx4 + dNpar1dx5 + dNpar1dx6;
 
        dNpar2dx1 = clum*dYdY[5][i]*raymagnetic.BPHI[0]/raymagnetic.R[0]/raymagnetic.B[0]/Y[6];
        dNpar2dx2 = clum*Y[5]*raymagnetic.dBPHIdx[i]/raymagnetic.R[0]/raymagnetic.B[0]/Y[6];
        dNpar2dx3 = -clum*Y[5]*raymagnetic.BPHI[0]*raymagnetic.dRdx[i]/raymagnetic.R[0]/raymagnetic.R[0]/raymagnetic.B[0]/Y[6];
        dNpar2dx4 = -clum*Y[5]*raymagnetic.BPHI[0]/raymagnetic.R[0]*raymagnetic.dBdx[i]/raymagnetic.B[0]/raymagnetic.B[0]/Y[6];
        dNpar2dx5 = -clum*Y[5]*raymagnetic.BPHI[0]/raymagnetic.R[0]/raymagnetic.B[0]*dYdY[6][i]/Y[6];
    
        dNpar2dx = dNpar2dx1 + dNpar2dx2 + dNpar2dx3 + dNpar2dx4 + dNpar2dx5;
        
        dNpardx[i] = dNpar1dx + dNpar2dx;
//        mexPrintf("i,dNpardx[i]:%d,%g\n",i,dNpardx[i]);
//        mexPrintf("i,dYdY[3][i],dYdY[4][i],dYdY[5][i]:%d,%g,%g,%g\n",i,dYdY[3][i],dYdY[4][i],dYdY[4][i]);
    }
    

    N21 = clum*clum*raymagnetic.R[0]*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.BP[0]*Y[3]/psia*Y[3]/psia/Y[6]/Y[6];
    N22 = -clum*clum*2.0*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.salpha[0]*Y[4]*Y[3]/psia/raymagnetic.r[0]/Y[6]/Y[6];
    N23 = clum*clum*Y[4]*Y[4]/raymagnetic.r[0]/raymagnetic.r[0]/Y[6]/Y[6];
    N24 = clum*clum*Y[5]*Y[5]/raymagnetic.R[0]/raymagnetic.R[0]/Y[6]/Y[6];
    
    N2 = N21 + N22 + N23 + N24;
    Nperp[0] = sqrt(N2 - Npar[0]*Npar[0]);

    for (i=0;i<8;i++) {
        
        dN21dx1 = clum*clum*2.0*raymagnetic.dRdx[i]*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.BP[0]*Y[3]/psia*Y[3]/psia/Y[6]/Y[6];
        dN21dx2 = clum*clum*2.0*raymagnetic.R[0]*raymagnetic.R[0]*raymagnetic.dBPdx[i]*raymagnetic.BP[0]*Y[3]/psia*Y[3]/psia/Y[6]/Y[6];
        dN21dx3 = clum*clum*2.0*raymagnetic.R[0]*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.BP[0]*dYdY[3][i]/psia*Y[3]/psia/Y[6]/Y[6];
        dN21dx4 = -clum*clum*2.0*raymagnetic.R[0]*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.BP[0]*Y[3]/psia*Y[3]/psia*dYdY[6][i]/Y[6]/Y[6];
        
        dN21dx = dN21dx1 + dN21dx2 + dN21dx3 + dN21dx4;
        
        dN22dx1 = -clum*clum*2.0*raymagnetic.dRdx[i]*raymagnetic.BP[0]*raymagnetic.salpha[0]*Y[4]*Y[3]/psia/raymagnetic.r[0]/Y[6]/Y[6];
        dN22dx2 = -clum*clum*2.0*raymagnetic.R[0]*raymagnetic.dBPdx[i]*raymagnetic.salpha[0]*Y[4]*Y[3]/psia/raymagnetic.r[0]/Y[6]/Y[6];
        dN22dx3 = -clum*clum*2.0*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.dsalphadx[i]*Y[4]*Y[3]/psia/raymagnetic.r[0]/Y[6]/Y[6];
        dN22dx4 = -clum*clum*2.0*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.salpha[0]*dYdY[4][i]*Y[3]/psia/raymagnetic.r[0]/Y[6]/Y[6];
        dN22dx5 = -clum*clum*2.0*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.salpha[0]*Y[4]*dYdY[3][i]/psia/raymagnetic.r[0]/Y[6]/Y[6];
        dN22dx6 = clum*clum*2.0*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.salpha[0]*Y[4]*Y[3]/psia*raymagnetic.drdx[i]/raymagnetic.r[0]/raymagnetic.r[0]/Y[6]/Y[6];
        dN22dx7 = clum*clum*4.0*raymagnetic.R[0]*raymagnetic.BP[0]*raymagnetic.salpha[0]*Y[4]*Y[3]/psia/raymagnetic.r[0]*dYdY[6][i]/Y[6]/Y[6];
        
        dN22dx = dN22dx1 + dN22dx2 + dN22dx3 + dN22dx4 + dN22dx5 + dN22dx6 + dN22dx7;
     
        dN23dx1 = clum*clum*2.0*dYdY[i][4]*Y[4]/raymagnetic.r[0]/raymagnetic.r[0]/Y[6]/Y[6];
        dN23dx2 = -clum*clum*2.0*Y[4]*Y[4]*raymagnetic.drdx[i]/raymagnetic.r[0]/raymagnetic.r[0]/raymagnetic.r[0]/Y[6]/Y[6];
        dN23dx3 = -clum*clum*2.0*Y[4]*Y[4]/raymagnetic.r[0]/raymagnetic.r[0]*dYdY[6][i]/Y[6]/Y[6];
        
        dN23dx = dN23dx1 + dN23dx2 + dN23dx3;
    
        dN24dx1 = clum*clum*2.0*dYdY[i][5]*Y[5]/raymagnetic.R[0]/raymagnetic.R[0]/Y[6]/Y[6];
        dN24dx2 = -clum*clum*2.0*Y[5]*Y[5]*raymagnetic.dRdx[i]/raymagnetic.R[0]/raymagnetic.R[0]/raymagnetic.R[0]/Y[6]/Y[6];
        dN24dx3 = -clum*clum*2.0*Y[5]*Y[5]/raymagnetic.R[0]/raymagnetic.R[0]*dYdY[6][i]/Y[6]/Y[6];
        
        dN24dx = dN24dx1 + dN24dx2 + dN24dx3;
        
        dN2dx = dN21dx + dN22dx + dN23dx + dN24dx;
        
        dNperpdx[i] = (dN2dx - 2.0*Npar[0]*dNpardx[i])/Nperp[0]/2.0;
//        mexPrintf("i,dNperpdx[i]:%d,%g\n",i,dNperpdx[i]);
     }
    
}


void coldtensor(X,ns,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx)
susceptibilitytensor_format X;
double wcn[],wpn2[],betath[];
double dwcndx[][8],dwpn2dx[][8],dbetathdx[][8];
double Npar,dNpardx[];
double complex Nperp,dNperpdx[];
int ns;
{ 
    double complex dXxxdNperp[ns+1],dXxydNperp[ns+1],dXxzdNperp[ns+1],dXyydNperp[ns+1],dXyzdNperp[ns+1],dXzzdNperp[ns+1];
    double complex dXxxdNpar[ns+1],dXxydNpar[ns+1],dXxzdNpar[ns+1],dXyydNpar[ns+1],dXyzdNpar[ns+1],dXzzdNpar[ns+1];
    double complex dXxxdbetath[ns+1],dXxydbetath[ns+1],dXxzdbetath[ns+1],dXyydbetath[ns+1],dXyzdbetath[ns+1],dXzzdbetath[ns+1];
    double complex dXxxdwcn[ns+1],dXxydwcn[ns+1],dXxzdwcn[ns+1],dXyydwcn[ns+1],dXyzdwcn[ns+1],dXzzdwcn[ns+1];
    double complex dXxxdwpn2[ns+1],dXxydwpn2[ns+1],dXxzdwpn2[ns+1],dXyydwpn2[ns+1],dXyzdwpn2[ns+1],dXzzdwpn2[ns+1];
    
    int is,i;
    
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
        dXxxdwcn[is] = -2.0*wpn2[is]*wcn[is]/(1 - wcn[is]*wcn[is])/(1 - wcn[is]*wcn[is]);
        dXxydwcn[is] = -(2.0*wpn2[is]*wcn[is]*wcn[is]/(1 - wcn[is]*wcn[is])/(1 - wcn[is]*wcn[is]) + wpn2[is]/(1 - wcn[is]*wcn[is]))*I;
        dXxzdwcn[is] = 0.0;
        dXyydwcn[is] = -2.0*wpn2[is]*wcn[is]/(1 - wcn[is]*wcn[is])/(1 - wcn[is]*wcn[is]);
        dXyzdwcn[is] = 0.0;
        dXzzdwcn[is] = 0.0;    
        dXxxdwpn2[is] = -1.0/(1 - wcn[is]*wcn[is]);
        dXxydwpn2[is] = -1.0*wcn[is]*I/(1 - wcn[is]*wcn[is]);
        dXxzdwpn2[is] = 0.0;
        dXyydwpn2[is] = -1.0/(1 - wcn[is]*wcn[is]);
        dXyzdwpn2[is] = 0.0;
        dXzzdwpn2[is] = -1.0;
    }
     
    X.Xxx[0] = 0.0;
    X.Xxy[0] = 0.0;
    X.Xxz[0] = 0.0;
    X.Xyy[0] = 0.0;
    X.Xyz[0] = 0.0;
    X.Xzz[0] = 0.0;
    
    for (is = 0;is < ns + 1;is++) {
        X.Xxx[0] = X.Xxx[0] - wpn2[is]/(1 - wcn[is]*wcn[is]);
        X.Xxy[0] = X.Xxy[0] - wpn2[is]*wcn[is]*I/(1 - wcn[is]*wcn[is]);
        X.Xxz[0] = X.Xxz[0];
        X.Xyy[0] = X.Xyy[0] - wpn2[is]/(1 - wcn[is]*wcn[is]);
        X.Xyz[0] = X.Xyz[0];
        X.Xzz[0] = X.Xzz[0] - wpn2[is];
    }
    
    for (i = 0;i < 8;i++) {
         X.dXxxdx[i] = 0.0;
         X.dXxydx[i] = 0.0;
         X.dXxzdx[i] = 0.0;
         X.dXyydx[i] = 0.0;
         X.dXyzdx[i] = 0.0;
         X.dXzzdx[i] = 0.0;
    }
    
    for (i = 0;i < 8;i++) {
        for (is = 0;is < ns + 1;is++) {
            X.dXxxdx[i] = X.dXxxdx[i] + dXxxdNperp[is]*dNperpdx[i] + dXxxdNpar[is]*dNpardx[i] + dXxxdbetath[is]*dbetathdx[is][i] + dXxxdwcn[is]*dwcndx[is][i] + dXxxdwpn2[is]*dwpn2dx[is][i];
            X.dXxydx[i] = X.dXxydx[i] + dXxydNperp[is]*dNperpdx[i] + dXxydNpar[is]*dNpardx[i] + dXxydbetath[is]*dbetathdx[is][i] + dXxydwcn[is]*dwcndx[is][i] + dXxydwpn2[is]*dwpn2dx[is][i];
            X.dXxzdx[i] = X.dXxzdx[i] + dXxzdNperp[is]*dNperpdx[i] + dXxzdNpar[is]*dNpardx[i] + dXxzdbetath[is]*dbetathdx[is][i] + dXxzdwcn[is]*dwcndx[is][i] + dXxzdwpn2[is]*dwpn2dx[is][i];
            X.dXyydx[i] = X.dXyydx[i] + dXyydNperp[is]*dNperpdx[i] + dXyydNpar[is]*dNpardx[i] + dXyydbetath[is]*dbetathdx[is][i] + dXyydwcn[is]*dwcndx[is][i] + dXyydwpn2[is]*dwpn2dx[is][i];
            X.dXyzdx[i] = X.dXyzdx[i] + dXyzdNperp[is]*dNperpdx[i] + dXyzdNpar[is]*dNpardx[i] + dXyzdbetath[is]*dbetathdx[is][i] + dXyzdwcn[is]*dwcndx[is][i] + dXyzdwpn2[is]*dwpn2dx[is][i];
            X.dXzzdx[i] = X.dXzzdx[i] + dXzzdNperp[is]*dNperpdx[i] + dXzzdNpar[is]*dNpardx[i] + dXzzdbetath[is]*dbetathdx[is][i] + dXzzdwcn[is]*dwcndx[is][i] + dXzzdwpn2[is]*dwpn2dx[is][i];      
        }
    }
    
//    for (i = 0;i < 8;i++) {
//        mexPrintf("i,dbetathdx[1][i]:%d,%g\n",i,dbetathdx[1][i]);
//        mexPrintf("i,dwcndx[1][i]:%d,%g\n",i,dwcndx[1][i]);
//        mexPrintf("i,dwpn2dx[1][i]:%d,%g\n",i,dwpn2dx[1][i]);
//        mexPrintf("i,dXxxdx,dXxydx,dXxzdx,dXyydx,dXyzdx,dXzzdx:%d,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",i,X.dXxxdx[i],X.dXxydx[i],X.dXxzdx[i],X.dXyydx[i],X.dXyzdx[i],X.dXzzdx[i]);
//        mexPrintf("i,dNpardx[i],dNperpdx[i]:%d,%g,%g\n",i,dNpardx[i],dNperpdx[i]);
//    }
    
   
}
