/*
  
    raytracing.c    MEX file implementation of a universal ray-tracing for electron waves

    call -> [tout, yout, yproc] = raytracing_yp(rayparam,equil,y0)

    INPUT: 

    - rayparam: parameters for ray-tracing structure [1,1]
    - equil: numerical equilibrium structure [1,1]
    - y0: ray initial conditions [1,1]

    OUTPUT: 

    - tout: returned integration time points (row-vector).
    - yout: returned solution, one solution column-vector per tout-value.
    - yproc: returned processed data, one set of data as column-vector per tout-value.

    WARNING: none

    REFERENCE: none

    by Y.PEYSSON (CEA-DRFC)  <yves.peysson@cea.fr>, Joan Decker (CEA-DRFC) <joan.decker@cea.fr> and Laurent Colas (CEA-DRFC) <laurent.colas@cea.fr>
*/

#include <complex.h>
#include <math.h>
#include "mex.h"

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

struct rayprofiles {
    double *Te;
    double *ne;
    double *zTi;
    double *zni;
    double *dTedY;
    double *dnedY;
    double **dzTidY;
    double **dznidY;
};

struct rayparam {
    double *testmode;
    double *tensortype;
    double *t0;
    double *tfinal;
    double *dt0;
    double *dS;
    double *tol;
    double *kmax;
    double *ncyclharm;
    double *reflection;
    double *rel_opt;
    double *nperp;
    double *pperpmax;
    double *tau_lim;
    double *kextra;
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

struct raymagnetic {
    double *rn;
    double *drndY;
    double *Rn;
    double *dRndY;
	double *Zn;
    double *dZndY;
    double *Bsn;
    double *dBsndY;
    double *BPHIn;
    double *dBPHIndY;
    double *B;
    double *dBdY;
    double *salpha;
    double *dsalphadY;
    double *calpha;
    double *dcalphadY;
    double *gradrhon;
    double *dgradrhondY;
};

struct susceptibilitytensor {
    double complex *Xxx;
    double complex *Xxy;
    double complex *Xxz;
    double complex *Xyy;
    double complex *Xyz;
    double complex *Xzz;
    double complex *dXxxdNperp;
    double complex *dXxydNperp;
    double complex *dXxzdNperp;
    double complex *dXyydNperp;
    double complex *dXyzdNperp;
    double complex *dXzzdNperp;
    double complex *dXxxdNpar;
    double complex *dXxydNpar;
    double complex *dXxzdNpar;
    double complex *dXyydNpar;
    double complex *dXyzdNpar;
    double complex *dXzzdNpar;
    double complex *dXxxdY;
    double complex *dXxydY;
    double complex *dXxzdY;
    double complex *dXyydY;
    double complex *dXyzdY;
    double complex *dXzzdY; 
};

typedef struct polynomial_piecewise_1D pp_1D_format;
typedef struct polynomial_piecewise_2D pp_2D_format;
typedef struct susceptibilitytensor susceptibilitytensor_format;
typedef struct rayparam rayparam_format;
typedef struct equilparam equilparam_format;
typedef struct refractiveindex refractiveindex_format;
typedef struct raymagnetic raymagnetic_format;
typedef struct rayprofiles rayprofiles_format;

/* subroutines list */

void ppval_1D();
void ppval_2D();
void ray();
void rayindex();
void susceptibility();
void rayprocess();
void metrictensor();
double alphaphi_jd();
void coldtensor();
void dsolve();
void disprel();
void interpequil();
void interpequil_test();
void load_idealequil_test();
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
int reflection();
void build_raymagnetic();
void weakrelativistictensor();
void Shka();
void ImShka();
void Fdnest();
void ImFdnest();


/* Input Arguments */

#define RAYPARAM_IN  prhs[0]
#define EQUIL_IN     prhs[1]
#define Y0_IN    prhs[2]
#define FLAG_IN prhs[3]

/* Output Arguments */

#define T_OUT   plhs[0]
#define Y_OUT   plhs[1]
#define Y_PROC  plhs[2]

#define MC 8
#define MPROC 23
#define SAFETY 0.8
#define PGROW 0.2
#define PSHRINK 0.25
#define MC 8
#define PI 3.14159265358979
#define CLUM 299792458 /*Speed of light (m/s) */

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
    pp_1D_format Te_fit,ne_fit,zTi_fit,zni_fit,dxstardpsin_fit;
    pp_2D_format x_fit,y_fit,Bx_fit,By_fit,BPHI_fit;
    rayparam_format rayparam;
    equilparam_format equilparam;
  
    double *Te,*dTedrho,*ne,*dnedrho,*zTi,*dzTidrho,*zni,*dznidrho;
    double *BR,*dBRdrho,*dBRdtheta;   
    double *BZ,*dBZdrho,*dBZdtheta;    
    double *BPHI,*dBPHIdrho,*dBPHIdtheta;
    double *x,*dRdrho,*dRdtheta,*d2Rdtheta2,*d2Rdthetadrho;
    double *y,*dZdrho,*dZdtheta,*d2Zdtheta2,*d2Zdthetadrho;
    double dummy1,dummy2;
    double flag;
    double flag_proc;
    
    /* Check out the arguments */

    if (nrhs < 3 || nrhs > 4) {
        mexErrMsgTxt("Wrong number of input arguments for raytracing_yp");
    }
 
    if (nlhs < 2 || nlhs > 3) {
        mexErrMsgTxt("Wrong number of output arguments for raytracing_yp");
    }
    
    if (!mxIsStruct(prhs[0])) mexErrMsgTxt("Input arguments must be structures");
    if (!mxIsStruct(prhs[1])) mexErrMsgTxt("Input arguments must be structures");
    
    if (nrhs == 3) {
        flag = 0;
    } else {
        flag = *(mxGetPr(FLAG_IN));
    }
    
    if (nlhs == 2) {
        flag_proc = 0;
    } else { /* flag for calculating additional ray data */
        flag_proc = 1;
    }
    
    

/*    double complex iBn,iBnp,iBnpp;   
    modBessel(-5.4,(double complex)(3.0 +1.2*I),&iBn,&iBnp,&iBnpp);
    mexPrintf("Bessel(-5.4,3.+1.2*i),Bp,Bpp:%g,%g,%g,%g,%g,%g\n",iBn,iBnp,iBnpp);
*/

/* Get Input Arguments */

    rayparam = load_ray_param(RAYPARAM_IN);    
    equilparam = load_equil_param(EQUIL_IN);

    dxstardpsin_fit = load_equil_1D(EQUIL_IN,"dxstardpsin_fit");
    
    if (equilparam.zZi[0] > 0) {/*Vacuum case otherwise (no density, temperature...)*/
       Te_fit = load_equil_1D(EQUIL_IN,"Te_fit");
       ne_fit = load_equil_1D(EQUIL_IN,"ne_fit");
       zTi_fit = load_equil_1D(EQUIL_IN,"zTi_fit"); 
       zni_fit = load_equil_1D(EQUIL_IN,"zni_fit");
    }
    
    x_fit = load_equil_2D(EQUIL_IN,"x_fit");
    y_fit = load_equil_2D(EQUIL_IN,"y_fit");
    Bx_fit = load_equil_2D(EQUIL_IN,"Bx_fit");
    By_fit = load_equil_2D(EQUIL_IN,"By_fit");
    BPHI_fit = load_equil_2D(EQUIL_IN,"BPHI_fit"); 
    
/* Test mode only */
    
    if (rayparam.testmode[0]) {/* keep this section for tests if necessary */
        mexPrintf("tol : %g\n",rayparam.tol[0]);
        mexPrintf("zZi(2) : %g\n",equilparam.zZi[1]);
        mexPrintf("--------------\n");
        
        if (equilparam.zZi[0] > 0) {        
            mexPrintf("Te_fit.coefs_f(1): %g\n",Te_fit.coefs_f[0]);
            mexPrintf("Te_fit.coefs_dfdrho(1): %g\n",Te_fit.coefs_dfdrho[0]);
        }

        mexPrintf("BPHI_fit.n: %g\n",BPHI_fit.n[0]);
        mexPrintf("BPHI_fit.coefs_bn(1): %g\n",BPHI_fit.coefs_bn[0]);
        mexPrintf("BPHI_fit.coefs_dbndrho(1): %g\n",BPHI_fit.coefs_dbndrho[0]);
        mexPrintf("--------------\n");
        
        if (equilparam.zZi[0] > 0) {                      
            Te = mxCalloc(1,sizeof(double));
            dTedrho = mxCalloc(1,sizeof(double));
            ppval_1D(Te_fit,rayparam.dS[0],0.25,Te,dTedrho);
            mexPrintf("Te(0.25),dTedrho(0.25) (keV): %g,%g\n",Te[0],dTedrho[0]);    
            mxFree(Te);
            mxFree(dTedrho);
        
            ne = mxCalloc(1,sizeof(double));
            dnedrho = mxCalloc(1,sizeof(double));
            ppval_1D(ne_fit,rayparam.dS[0],0.25,ne,dnedrho);
            mexPrintf("ne(0.25),dnedrho(0.25) (10+19 m-3): %g,%g\n",ne[0]/1e19,dnedrho[0]/1e19);    
            mxFree(ne);
            mxFree(dnedrho);

            zTi = mxCalloc(equilparam.ns[0],sizeof(double));
            dzTidrho = mxCalloc(equilparam.ns[0],sizeof(double));
            ppval_1D(zTi_fit,rayparam.dS[0],0.25,zTi,dzTidrho);
            mexPrintf("zTi(2,0.25),dzTidrho(2,0.25) (keV): %g,%g\n",zTi[1],dzTidrho[1]);
            mxFree(zTi);
            mxFree(dzTidrho);
        
            zni = mxCalloc(equilparam.ns[0],sizeof(double));
            dznidrho = mxCalloc(equilparam.ns[0],sizeof(double));
            ppval_1D(zni_fit,rayparam.dS[0],0.25,zni,dznidrho);
            mexPrintf("zni(2,0.25),dznidrho(2,0.25) (10+19 m-3): %g,%g\n",zni[1]/1e19,dznidrho[1]/1e19);
            mxFree(zni);
            mxFree(dznidrho);
        }
       
        x = mxCalloc(1,sizeof(double));
        dRdrho = mxCalloc(1,sizeof(double));
        dRdtheta = mxCalloc(1,sizeof(double));
        d2Rdtheta2 = mxCalloc(1,sizeof(double));
        d2Rdthetadrho = mxCalloc(1,sizeof(double));
        ppval_2D(x_fit,rayparam.dS[0],0.25,0.2,x,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho);
        mexPrintf("R(0.25,0.2),dRdrho(0.25,0.2),dRdtheta(0.25,0.2) (m): %g,%g,%g\n",x[0]+equilparam.Rp[0],dRdrho[0],dRdtheta[0],d2Rdtheta2[0],d2Rdthetadrho[0]);
        mxFree(x);
        mxFree(dRdrho); 
        mxFree(dRdtheta);
        mxFree(d2Rdtheta2);
        mxFree(d2Rdthetadrho);
        
        y = mxCalloc(1,sizeof(double));
        dZdrho = mxCalloc(1,sizeof(double));
        dZdtheta = mxCalloc(1,sizeof(double));
        d2Zdtheta2 = mxCalloc(1,sizeof(double));
        d2Zdthetadrho = mxCalloc(1,sizeof(double));
        ppval_2D(y_fit,rayparam.dS[0],0.25,0.2,y,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho);
        mexPrintf("Z(0.25,0.2),dZdrho(0.25,0.2),dZdtheta(0.25,0.2) (m): %g,%g,%g\n",y[0]+equilparam.Zp[0],dZdrho[0],dZdtheta[0],d2Zdtheta2[0],d2Zdthetadrho[0]);
        mxFree(y);
        mxFree(dZdrho); 
        mxFree(dZdtheta);
        mxFree(d2Zdtheta2);
        mxFree(d2Zdthetadrho);
                       
        BR = mxCalloc(1,sizeof(double));
        dBRdrho = mxCalloc(1,sizeof(double));
        dBRdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(Bx_fit,rayparam.dS[0],0.25,0.2,BR,dBRdrho,dBRdtheta,&dummy1,&dummy2);
        mexPrintf("BR(0.25,0.2),dBRdrho(0.25,0.2),dBRdtheta(0.25,0.2) (T): %g,%g,%g\n",BR[0],dBRdrho[0],dBRdtheta[0]);
        mxFree(BR);
        mxFree(dBRdrho); 
        mxFree(dBRdtheta); 

        BZ = mxCalloc(1,sizeof(double));
        dBZdrho = mxCalloc(1,sizeof(double));
        dBZdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(By_fit,rayparam.dS[0],0.25,0.2,BZ,dBZdrho,dBZdtheta,&dummy1,&dummy2);
        mexPrintf("BZ(0.25,0.2),dBZdrho(0.25,0.2),dBZdtheta(0.25,0.2) (T): %g,%g,%g\n",BZ[0],dBZdrho[0],dBZdtheta[0]);
        mxFree(BZ);
        mxFree(dBZdrho); 
        mxFree(dBZdtheta);     
 
        BPHI = mxCalloc(1,sizeof(double));
        dBPHIdrho = mxCalloc(1,sizeof(double));
        dBPHIdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(BPHI_fit,rayparam.dS[0],0.25,0.2,BPHI,dBPHIdrho,dBPHIdtheta,&dummy1,&dummy2);
        mexPrintf("BPHI(0.25,0.2),dBPHIdrho(0.25,0.2),dBPHIdtheta(0.25,0.2) (T): %g,%g,%g\n",BPHI[0],dBPHIdrho[0],dBPHIdtheta[0]);
        mxFree(BPHI);
        mxFree(dBPHIdrho); 
        mxFree(dBPHIdtheta); 
          
    }
    
    raymagnetic_format raymagnetic;
    rayprofiles_format rayprofiles;
    susceptibilitytensor_format X;
    
    register int i,j;

    /* Memory allocation */

    raymagnetic.rn = mxCalloc(1,sizeof(double));
    raymagnetic.Rn = mxCalloc(1,sizeof(double));
    raymagnetic.Zn = mxCalloc(1,sizeof(double));
    raymagnetic.Bsn = mxCalloc(1,sizeof(double));
    raymagnetic.B = mxCalloc(1,sizeof(double));
    raymagnetic.BPHIn = mxCalloc(1,sizeof(double));
    raymagnetic.salpha = mxCalloc(1,sizeof(double));
    raymagnetic.calpha = mxCalloc(1,sizeof(double));
    raymagnetic.gradrhon = mxCalloc(1,sizeof(double));

    raymagnetic.drndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dRndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dZndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBsndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBPHIndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBdY = mxCalloc(MC,sizeof(double));
    raymagnetic.dsalphadY = mxCalloc(MC,sizeof(double));
    raymagnetic.dcalphadY = mxCalloc(MC,sizeof(double));
    raymagnetic.dgradrhondY = mxCalloc(MC,sizeof(double));

    for (i = 0;i < MC; i++) {/*initialisation */
        raymagnetic.drndY[i] = 0.0;
        raymagnetic.dRndY[i] = 0.0;
        raymagnetic.dZndY[i] = 0.0;
        raymagnetic.dsalphadY[i] = 0.0;
        raymagnetic.dcalphadY[i] = 0.0;
        raymagnetic.dgradrhondY[i] = 0.0;
        raymagnetic.dBsndY[i] = 0.0;
        raymagnetic.dBPHIndY[i] = 0.0;
        raymagnetic.dBdY[i] = 0.0;
    }

    rayprofiles.Te = mxCalloc(1,sizeof(double));
    rayprofiles.ne = mxCalloc(1,sizeof(double));
    rayprofiles.zTi = mxCalloc(equilparam.ns[0],sizeof(double));
    rayprofiles.zni = mxCalloc(equilparam.ns[0],sizeof(double));

    rayprofiles.dTedY = mxCalloc(MC,sizeof(double));
    rayprofiles.dnedY = mxCalloc(MC,sizeof(double));

    rayprofiles.dzTidY = mxCalloc(equilparam.ns[0],sizeof(double *));
    rayprofiles.dznidY = mxCalloc(equilparam.ns[0],sizeof(double *));
    for (i = 0;i < equilparam.ns[0]; i++) {
        rayprofiles.dzTidY[i] = mxCalloc(MC,sizeof(double));       
        rayprofiles.dznidY[i] = mxCalloc(MC,sizeof(double));       
    }    

    for (i = 0;i < MC; i++) {/*initialisation */
        rayprofiles.dTedY[i] = 0.0;
        rayprofiles.dnedY[i] = 0.0;
    
        for (j=0;j<equilparam.ns[0];j++) {
            rayprofiles.dzTidY[j][i] = 0.0;
            rayprofiles.dznidY[j][i] = 0.0;
        }
    }

    X.Xxx = mxCalloc(1,sizeof(double complex));
    X.Xxy = mxCalloc(1,sizeof(double complex));
    X.Xxz = mxCalloc(1,sizeof(double complex));
    X.Xyy = mxCalloc(1,sizeof(double complex));
    X.Xyz = mxCalloc(1,sizeof(double complex));
    X.Xzz = mxCalloc(1,sizeof(double complex));

    X.dXxxdNperp = mxCalloc(1,sizeof(double complex));
    X.dXxydNperp = mxCalloc(1,sizeof(double complex));
    X.dXxzdNperp = mxCalloc(1,sizeof(double complex));
    X.dXyydNperp = mxCalloc(1,sizeof(double complex));
    X.dXyzdNperp = mxCalloc(1,sizeof(double complex));
    X.dXzzdNperp = mxCalloc(1,sizeof(double complex));

    X.dXxxdNpar = mxCalloc(1,sizeof(double complex));
    X.dXxydNpar = mxCalloc(1,sizeof(double complex));
    X.dXxzdNpar = mxCalloc(1,sizeof(double complex));
    X.dXyydNpar = mxCalloc(1,sizeof(double complex));
    X.dXyzdNpar = mxCalloc(1,sizeof(double complex));
    X.dXzzdNpar = mxCalloc(1,sizeof(double complex));

    X.dXxxdY = mxCalloc(MC,sizeof(double complex));
    X.dXxydY = mxCalloc(MC,sizeof(double complex));
    X.dXxzdY = mxCalloc(MC,sizeof(double complex));
    X.dXyydY = mxCalloc(MC,sizeof(double complex));
    X.dXyzdY = mxCalloc(MC,sizeof(double complex));
    X.dXzzdY = mxCalloc(MC,sizeof(double complex));

    for (i=0;i<MC;i++) {/*initialisation */
        X.dXxxdY[i] = 0.0;
        X.dXxydY[i] = 0.0;
        X.dXxzdY[i] = 0.0;
        X.dXyydY[i] = 0.0;
        X.dXyzdY[i] = 0.0;
        X.dXzzdY[i] = 0.0;
    }
    
/* Runge-Kutta  */

    double  *tout,*yout,*yproc;
    double  *toutp,*youtp;
    double  *y0,*y1,*y0_in;
    double  tau_lim = rayparam.tau_lim[0];

    register unsigned int  m,k=-1,kk,ii=0,kmax=rayparam.kmax[0];

    double *s0,*s1,*s2,*s3,*s4,*s5,*s6;
    double *tempt,*temp0,*temp1,*temp2,*temp3,*temp4,*temp5,*temp6,*temp7;

    double ymax,tau,delta,h,hmax,hmin;
    
    double ydel[MC],ys[7];
    
    double t1,t2,rho1,rho2,theta1,theta2,phi1,phi2,krho1,krho2,m1,m2,n1,n2,omega1,omega2;
    
    double S1,S2,S_step,Sdot1,Sdot2,Sdot3,Sdot4,Sdot5,Sdot6;
    
    double *rayproc,**temp_proc;
    double dS,depth=0.0,alpha1=0.0,alpha2,absphi;     
    double clum=CLUM;   
    
    int flag1,iimax=500000;

/*
Create arguments for calling user function
*/

    tempt = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp0 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp1 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp2 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp3 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp4 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp5 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp6 = mxCalloc(rayparam.kmax[0],sizeof(double));
    temp7 = mxCalloc(rayparam.kmax[0],sizeof(double));

    y0 = mxCalloc(MC,sizeof(double));
    y1 = mxCalloc(MC,sizeof(double));
    s0 = mxCalloc(MC,sizeof(double));
    s1 = mxCalloc(MC,sizeof(double));
    s2 = mxCalloc(MC,sizeof(double));
    s3 = mxCalloc(MC,sizeof(double));
    s4 = mxCalloc(MC,sizeof(double));
    s5 = mxCalloc(MC,sizeof(double));
    s6 = mxCalloc(MC,sizeof(double));
    
    y0_in = mxGetPr(Y0_IN);
    
    if (flag_proc == 1) {  
        
        rayproc = mxCalloc(MPROC+2*equilparam.ns[0],sizeof(double));;
       
        temp_proc = mxCalloc(MPROC+2*equilparam.ns[0]+1,sizeof(double *));
        for (i = 0;i < MPROC+2*equilparam.ns[0]+1; i++) {
            temp_proc[i] = mxCalloc(rayparam.kmax[0],sizeof(double));       
        }    

        for (i = 0;i < MPROC+2*equilparam.ns[0]+1; i++) {/*initialisation */
            for (kk = 0;kk < rayparam.kmax[0]; kk++) {
                temp_proc[i][kk] = 0.0;
            }
        }
                        
    }
/*
Create and Initialize Return Arguments
*/
    
    y0[0] = y0_in[0];/* Necessary to separe data from mex and matlab */
    y0[1] = y0_in[1];
    y0[2] = y0_in[2];
    y0[3] = y0_in[3];
    y0[4] = y0_in[4];
    y0[5] = y0_in[5];
    y0[6] = y0_in[6];

    t1 = rayparam.t0[0];

    rho1 = y0[0];
    theta1 = y0[1];
    phi1 = y0[2];
    krho1 = y0[3];
    m1 = y0[4];
    n1 = y0[5];
    omega1 = y0[6];
    
    S1 = 0.0; /* initial value of path length */
    S_step = S1;/* initial path position */
        
/* Solves the dispersion relation internally to remove numerical errors from initial conditions */
    if (fabs(flag) > 0) {
    /*   mexPrintf("krho1:%g\n",krho1); */
       dsolve(1,&krho1,y0,raymagnetic,rayprofiles,X,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,flag); 
    /*      mexPrintf("krho1:%g\n",krho1); */               
    }
    
/*
Initialization
*/

    h = rayparam.dt0[0];

/*
The main loop
*/
    
    while ((t1 < rayparam.tfinal[0]) && (k < kmax)) {
        ii++; 
/*        mexPrintf("ii:%d\n",ii);*/
        if ((t1 + h) > rayparam.tfinal[0]) {
            h = rayparam.tfinal[0] - t1;
        }
        if (ii > iimax) {
            goto Endloop;
            flag1 = 2;
        }
        
        /*mexPrintf("S1:%g\n",S1);*/
        
        if (k == -1 || fabs(S1 - S_step) >= rayparam.dS[0]) {/*step stored in Matlab memory */
            
            k++;
            
            tempt[k] = t1;
            temp0[k] = rho1;
            temp1[k] = theta1;
            temp2[k] = phi1;
            temp3[k] = krho1;
            temp4[k] = m1;
            temp5[k] = n1;
            temp6[k] = omega1;
            temp7[k] = S1;

            if (flag_proc == 1) { /* calculate additional ray parameters if required */ 

                dS = S1 - S_step; /* ray path from k-1 to k position */

                y0[0] = temp0[k];
                y0[1] = temp1[k];
                y0[2] = temp2[k];
                y0[3] = temp3[k];
                y0[4] = temp4[k];
                y0[5] = temp5[k];
                y0[6] = temp6[k];

                rayprocess(rayproc,rayparam,raymagnetic,rayprofiles,X,equilparam,y0,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,flag);

                for (i=0;i<MPROC+2*equilparam.ns[0];i++) {
                    temp_proc[i][k] = rayproc[i];
                }

                /* absphi = sqrt(fabs(phix2) + fabs(phiy2) + fabs(phiz2)); */
                absphi = sqrt(fabs(rayproc[9]*rayproc[9]) + fabs(rayproc[10]*rayproc[10]) + fabs(rayproc[11]*rayproc[11]));

                /* alpha = alphaphi*equilparam.ap[0]*y0[6]/clum/absphi; */
                alpha2 = rayproc[12]*equilparam.ap[0]*y0[6]/clum/absphi;

                /* Optical depth */

                depth = depth + (alpha1 + alpha2)*dS/2;

                temp_proc[MPROC+2*equilparam.ns[0]][k] = depth;

                if (tau_lim > 0 && depth > tau_lim) { /* The power is fully absorbed. */
                    mexPrintf("The wave is fully linearly damped at k = %i\n",k);
                         
                    kmax = fmin(kmax,k + rayparam.kextra[0]);
                    mexPrintf("----> Calculation stopped at k = %i\n",kmax);
                    tau_lim = 0;
                                        
                }
                
                alpha1 = alpha2;
            }

            S_step = S1;
        }
/*
Compute the slopes
*/

/* ts = t  and  s0 = y */

        s0[0] = rho1;
        s0[1] = theta1;
        s0[2] = phi1;
        s0[3] = krho1;
        s0[4] = m1;
        s0[5] = n1;
        s0[6] = omega1;
        
        for  (m = 0; m < MC; m++) {
            y1[m] = s0[m];
        }
        
        ray(s1,&Sdot1,y1,raymagnetic,rayprofiles,X,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,&flag);          
        /* s2 = feval(F, t+h*alpha(1), y1+h*s1*beta(1,1), param); */

        for  (m = 0; m < MC-3; m++) {/* only the first five coordinates are evolving (rho,theta,phi,krho,m) */
            y1[m] = s0[m]+h*s1[m]*beta[0][0];
        }
         
            
        ray(s2,&Sdot2,y1,raymagnetic,rayprofiles,X,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,&flag);
        /* s3 = feval(F, t+h*alpha(2), y1+h*[s1*beta(2,1)+s2*beta(2,2)], param); */

        for  (m = 0; m < MC-3; m++) {
            y1[m] = s0[m]+h*(s1[m]*beta[0][1] + s2[m]*beta[1][1]);
        }

        ray(s3,&Sdot3,y1,raymagnetic,rayprofiles,X,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,&flag);

        /* s4 = feval(F, t+h*alpha(3), y1+h*[s1*beta(3,1)+s2*beta(3,2)+...], param); */

        for  (m = 0; m < MC-3; m++) {
            y1[m] = s0[m]+h*(s1[m]*beta[0][2] + s2[m]*beta[1][2] + s3[m]*beta[2][2]);
        }
 
        ray(s4,&Sdot4,y1,raymagnetic,rayprofiles,X,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,&flag);

        /* s5 = feval(F, t+h*alpha(4), y1+h*[s1*beta(4,1)+s2*beta(4,2)+...], param); */

        for  (m = 0; m < MC-3; m++) {
            y1[m] = s0[m]+h*(s1[m]*beta[0][3] + s2[m]*beta[1][3] + s3[m]*beta[2][3] + s4[m]*beta[3][3]);
        }


        ray(s5,&Sdot5,y1,raymagnetic,rayprofiles,X,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,&flag);

        /* s6 = feval(F, t+h*alpha(5), y1+h*[s1*beta(5,1)+s2*beta(5,2)+...], param); */

        for  (m = 0; m < MC-3; m++) {
            y1[m] = s0[m]+h*(s1[m]*beta[0][4] + s2[m]*beta[1][4] + s3[m]*beta[2][4] + s4[m]*beta[3][4] + s5[m]*beta[4][4]);
        }
        
        ray(s6,&Sdot6,y1,raymagnetic,rayprofiles,X,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,&flag);

/*
Estimate the error and the acceptable error
*/

        for  (m = 0; m < MC-3; m++) {
            ydel[m] = h*(s1[m]*gama[0][1] + s2[m]*gama[1][1] + s3[m]*gama[2][1] + s4[m]*gama[3][1] + s5[m]*gama[4][1] + s6[m]*gama[5][1]);
            ys[0] = s0[m];
            ys[1] = s1[m];
            ys[2] = s2[m];
            ys[3] = s3[m];
            ys[4] = s4[m];
            ys[5] = s5[m];
            ys[6] = s6[m];
            ymax = inf_norm(ys,7);
            ydel[m] = ydel[m]/ymax;
        }

        delta = inf_norm(ydel,MC-3);/* only the first five coordinates are evolving (rho,theta,phi,krho,m) */
        tau = rayparam.tol[0];

/*
Update the solution only if the error is acceptable
*/    
        
/*      mexPrintf("t1,delta,ymax,h,rho1,theta1,phi1,krho1,m1:%g,%g,%g,%g,%g,%g,%g,%g,%g\n",t1,delta,ymax,h,rho1,theta1,phi1,krho1,m1); */

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
            
            S2 = S1 + h*(Sdot1*gama[0][0] + Sdot2*gama[1][0]
                       + Sdot3*gama[2][0] + Sdot4*gama[3][0]
                       + Sdot5*gama[4][0] + Sdot6*gama[5][0]);

/*           mexPrintf("t1,rho2,theta2,phi2,krho2,m2:%g,%g,%g,%g,%g,%g\n",t1,rho2,theta2,phi2,krho2,m2); */
               
            if (rho2 < rayparam.dS[0]) {/* Boundary condition at rho = 0  */     
                rho2 = rho1;
		        theta2 = theta1 + PI;
                phi2 = phi1;
		        krho2 = -krho1;
                m2 = m1;
                
                S2 = S1;
                S_step = S2;
            }
            
           
            if (rho2 > 1.0) {/* Wave reflexion at rho = 1  */ 
                if (rayparam.reflection[0] >=1.0) {/* The reflection is always enforced */
                    mexPrintf("********************************** Wave reflection is enforced at rho = %g**********************************\n",rho1);
                    rho2 = rho1;
                    phi2 = phi1;
                    theta2 = theta1;
                    if (reflection(rayparam,equilparam,raymagnetic,&krho2,rho1,theta1,krho1,m1,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit) == -1) {goto Endloop;}                                           
                    m2 = m1;
                } else {/* The code calculates if the reflection must takes place. It calculates kpsi for vacuum (keeping the magnetic field) ray leaves the plasma only if kspi is real.*/
                    s0[0] = rho1;
                    s0[1] = theta1;
                    s0[2] = phi1;
                    s0[3] = krho1;
                    s0[4] = m1;
                    s0[5] = n1;
                    s0[6] = omega1;             
                    dsolve(0,&krho2,s0,raymagnetic,rayprofiles,X,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,flag); 
/*                    mexPrintf("test2a,krho2,cimag(krho2):%g,%g,%g\n",krho2,cimag(krho2));*/       
                    if (cimag(krho2) == 0.0) {/* ray may propagate in vacuum. Propagation is stopped */
                        mexPrintf("********************************** The wave leaves the plasma at rho = %g**********************************\n",rho1);
                        flag1 = 1;
                        goto Endloop;  
                    } else {/* ray may not propagate in vacuum. Wave reflection is performed at plasma edge */
                        mexPrintf("********************************** Wave reflection takes place at rho = %g**********************************\n",rho1);
                        rho2 = rho1;
                        phi2 = phi1;
                        theta2 = theta1;
                        if (reflection(rayparam,equilparam,raymagnetic,&krho2,rho1,theta1,krho1,m1,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit) == -1) {goto Endloop;}                                           
                        m2 = m1;  
                    }
                }
            }
                                    
            t1 = t2;
            rho1 = rho2;
            theta1 = theta2;
            phi1 = phi2;
            krho1 = krho2;
            m1 = m2;
            n1 = n2;
            omega1 = omega2;
        
            S1 = S2;
        }
    
/*
Update the step size
*/
        
        if (delta) {
            if (delta < tau) {
                h = SAFETY*h*pow(tau/delta,PGROW);   
            } else {
                h = SAFETY*h*pow(tau/delta,PSHRINK);                
            }       
/*      mexPrintf("delta,tau,rho1,krho1,h:%g,%g,%g,%g,%g,%g\n",delta,tau,rho1,krho1,h);*/
            
        } else {       
           mexPrintf("WARNING delta :%g, the loop is stopped.\n",delta);
           if (flag1 == 0) {
               mexPrintf("---> The maximum number of iteration is reached.\n",delta);
           }
           if (flag1 == 1) {
               mexPrintf("---> The ray leaves the plasma.\n",delta);
           }
           if (flag1 == 2) {
               mexPrintf("WARNING: the code has reached a stationary point. Exit forced at %i steps.\n",iimax);
           }
           goto Endloop;
        }
        
    }

    /* if (t1 < rayparam.tfinal[0]) {
        mexPrintf("Singularity likely at t = %f or matrix full\n",t1);
    }*/
    
Endloop:

    
/* Create final matrix for transferring data to MatLab */
    
    T_OUT = mxCreateDoubleMatrix(k,1,mxREAL);
    Y_OUT = mxCreateDoubleMatrix(k,MC,mxREAL);
    tout = mxGetPr(T_OUT);
    yout = mxGetPr(Y_OUT);  
    
    for (kk = 0;kk < k; kk++) {
        tout[kk] = tempt[kk];
    }
    for (kk = 0;kk < k; kk++) {
        yout[kk] = temp0[kk];
    }
    for (kk = 0;kk < k; kk++) {
        yout[kk + k] = temp1[kk];
    }
    for (kk = 0;kk < k; kk++) {
        yout[kk + 2*k] = temp2[kk];
    }
    for (kk = 0;kk < k; kk++) {
        yout[kk + 3*k] = temp3[kk];
    }
    for (kk = 0;kk < k; kk++) {
        yout[kk + 4*k] = temp4[kk];
    }
    for (kk = 0;kk < k; kk++) {
        yout[kk + 5*k] = temp5[kk];
    }
    for (kk = 0;kk < k; kk++) {
        yout[kk + 6*k] = temp6[kk];
    }
    for (kk = 0;kk < k; kk++) {
        yout[kk + 7*k] = temp7[kk];
    }

    /* Memory is released  */
    
    mxFree(raymagnetic.rn);
    mxFree(raymagnetic.Rn);
    mxFree(raymagnetic.Zn);
    mxFree(raymagnetic.Bsn);
    mxFree(raymagnetic.BPHIn);
    mxFree(raymagnetic.B);
    mxFree(raymagnetic.salpha);
    mxFree(raymagnetic.calpha);
    mxFree(raymagnetic.gradrhon);
    
    mxFree(raymagnetic.drndY);
    mxFree(raymagnetic.dRndY);
    mxFree(raymagnetic.dZndY);
    mxFree(raymagnetic.dBsndY);
    mxFree(raymagnetic.dBPHIndY);
    mxFree(raymagnetic.dBdY);   
    mxFree(raymagnetic.dsalphadY);
    mxFree(raymagnetic.dcalphadY);
    mxFree(raymagnetic.dgradrhondY);
    
    mxFree(rayprofiles.Te);
    mxFree(rayprofiles.ne);
    mxFree(rayprofiles.zTi);
    mxFree(rayprofiles.zni);

    mxFree(rayprofiles.dTedY);
    mxFree(rayprofiles.dnedY);
    
    for (i = 0;i < equilparam.ns[0]; i++) {
        mxFree(rayprofiles.dzTidY[i]);       
        mxFree(rayprofiles.dznidY[i]);       
    }    
    
    mxFree(rayprofiles.dzTidY);
    mxFree(rayprofiles.dznidY);

    mxFree(X.Xxx);
    mxFree(X.Xxy);
    mxFree(X.Xxz);
    mxFree(X.Xyy);
    mxFree(X.Xyz);
    mxFree(X.Xzz);

    mxFree(X.dXxxdNperp);
    mxFree(X.dXxydNperp);
    mxFree(X.dXxzdNperp);
    mxFree(X.dXyydNperp);
    mxFree(X.dXyzdNperp);
    mxFree(X.dXzzdNperp);

    mxFree(X.dXxxdNpar);
    mxFree(X.dXxydNpar);
    mxFree(X.dXxzdNpar);
    mxFree(X.dXyydNpar);
    mxFree(X.dXyzdNpar);
    mxFree(X.dXzzdNpar);

    mxFree(X.dXxxdY);
    mxFree(X.dXxydY);
    mxFree(X.dXxzdY);
    mxFree(X.dXyydY);
    mxFree(X.dXyzdY);
    mxFree(X.dXzzdY);

    mxFree(tempt);
    mxFree(temp0);
    mxFree(temp1);
    mxFree(temp2);
    mxFree(temp3);
    mxFree(temp4);
    mxFree(temp5);
    mxFree(temp6);
    mxFree(temp7);

    mxFree(y0);
    mxFree(y1);
    mxFree(s0);
    mxFree(s1);
    mxFree(s2);
    mxFree(s3);
    mxFree(s4);
    mxFree(s5);
    mxFree(s6);

    if (flag_proc == 1) {    
       
        Y_PROC = mxCreateDoubleMatrix(k,MPROC+2*equilparam.ns[0]+1,mxREAL);
        yproc = mxGetPr(Y_PROC);  
   
        for (kk = 0;kk < k; kk++) {
            for (i=0;i<MPROC+2*equilparam.ns[0]+1;i++) {
                yproc[kk + i*k] = temp_proc[i][kk];
            }
        }
        
        /* Memory is released  */
        
        for (i=0;i<MPROC+2*equilparam.ns[0]+1;i++) {
            mxFree(temp_proc[i]);       
        }    
        mxFree(temp_proc);
        
        mxFree(rayproc);
        
    }
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


void ray(Ydot,Sdot,Y,raymagnetic,rayprofiles,X,param,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,flag)
double Y[];
double Ydot[];
double *Sdot;
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
susceptibilitytensor_format X;
rayparam_format param;
equilparam_format equilparam;
pp_1D_format Te_fit;
pp_1D_format ne_fit;
pp_1D_format zTi_fit;
pp_1D_format zni_fit;
pp_2D_format x_fit;
pp_2D_format y_fit;
pp_2D_format BPHI_fit;
pp_2D_format Bx_fit;
pp_2D_format By_fit;
pp_1D_format dxstardpsin_fit;
double *flag;
{

    register int i,j;

    double complex dDdY[43][MC],Dtot,dDtotdY[MC];
    
    double Sdot2;
    double Gcov[3][3];
    double wcn[equilparam.ns[0]+1],wpn2[equilparam.ns[0]+1],betath[equilparam.ns[0]+1];
    
    double Npar,dNpardY[MC];
    double complex Nperp,dNperpdY[MC];
    double complex N6,N2,dN2dY[MC],dN6m1;

    double complex Nperp4,Nperp3,Nperp2,Nperp1;
    double Npar4,Npar3,Npar2,Npar1;
    double complex Xxx,Xxy,Xxz,Xyy,Xyz,Xzz;
    double complex Xxx2,Xxy2,Xxz2,Xyy2,Xyz2,Xzz2;

    /* Equilibrium interpolation at ray location */
    if (*flag == 0) {
       interpequil(param,raymagnetic,rayprofiles,equilparam,Y,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit);
    } else {
       interpequil_test(raymagnetic,rayprofiles,equilparam,Y,*flag);
    }

    /* Refractive index calculation */
    rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardY,dNperpdY,dN2dY);
    /* 
    mexPrintf("rn,Rn,Zn,Bsn,krho,sina,cosa,B,BPHIn:%g,%g,%g,%g,%g,%g,%g,%g,%g\n",raymagnetic.rn[0],raymagnetic.Rn[0],raymagnetic.Zn[0],raymagnetic.Bsn[0],Y[3],raymagnetic.salpha[0],raymagnetic.calpha[0],raymagnetic.B[0],raymagnetic.BPHIn[0]);
    mexPrintf("Npar,w*dNpardw,Nperpr,Nperpi,w*dNperpdwr,w*dNperpdwi:%g,%g,%g,%g,%g,%g\n",Npar,dNpardY[6],Nperp,dNperpdY[6]);
    */ 

    /* Susceptibility tensor  */

    susceptibility(X,wcn,wpn2,betath,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,Y[6]);

    if (*flag < 0) {/* dipersion relation */
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

    /* mexPrintf("N2,dN2dY[i],%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",N2,dN2dY[0],dN2dY[1],dN2dY[2],dN2dY[3],dN2dY[4],dN2dY[5],dN2dY[6],dN2dY[7]); */

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

    for (i = 0;i<MC;i++) {
    
        dN6m1 = 3*dN2dY[i]/N6/N2;
    
        dDdY[0][i] = 4.0*Nperp3*dNperpdY[i]/N6 - Nperp4*dN6m1;
        dDdY[1][i] = X.dXxxdY[i]*Nperp4/N6 + 4.0*Xxx*Nperp3*dNperpdY[i]/N6 - Xxx*Nperp4*dN6m1;
        dDdY[2][i] = 2.0*dNpardY[i]*Xxz*Nperp3/N6 + 2.0*Npar1*X.dXxzdY[i]*Npar3/N6 + 6.0*Npar1*Xxz*dNperpdY[i]*Nperp2/N6 - 2.0*Npar1*Xxz*Nperp3*dN6m1;    
        dDdY[3][i] = 2.0*Npar1*dNpardY[i]*Xxx*Nperp2/N6 + Npar2*X.dXxxdY[i]*Nperp2/N6 + 2.0*Npar2*Xxx*Nperp1*dNperpdY[i]/N6 - Npar2*Xxx*Nperp2*dN6m1;
        dDdY[4][i] = 2.0*Npar1*dNpardY[i]*Xzz*Nperp2/N6 + Npar2*X.dXzzdY[i]*Nperp2/N6 + 2.0*Npar2*Xzz*Nperp1*dNperpdY[i]/N6 - Npar2*Xzz*Nperp2*dN6m1;
        dDdY[5][i] = 4.0*Npar1*dNpardY[i]*Nperp2/N6 + 4.0*Npar2*Nperp1*dNperpdY[i]/N6 - 2.0*Npar2*Nperp2*dN6m1;
        dDdY[6][i] = -2.0*X.dXxxdY[i]*Nperp2/N6 - 4.0*Xxx*Nperp1*dNperpdY[i]/N6 + 2.0*Xxx*Nperp2*dN6m1;
        dDdY[7][i] = -X.dXyydY[i]*Nperp2/N6 - 2.0*Xyy*Nperp1*dNperpdY[i]/N6 + Xyy*Nperp2*dN6m1;
        dDdY[8][i] = -X.dXzzdY[i]*Nperp2/N6 - 2.0*Xzz*Nperp1*dNperpdY[i]/N6 + Xzz*Nperp2*dN6m1;
        dDdY[9][i] = -X.dXxxdY[i]*Xzz*Nperp2/N6 - Xxx*X.dXzzdY[i]*Nperp2/N6 - 2.0*Xxx*Xzz*Nperp1*dNperpdY[i]/N6 + Xxx*Xzz*Nperp2*dN6m1;
        dDdY[10][i] = 2.0*Xxz*X.dXxzdY[i]*Nperp2/N6 + 2.0*Xxz2*Nperp1*dNperpdY[i]/N6 - Xxz2*Nperp2*dN6m1;
        dDdY[11][i] = -X.dXxxdY[i]*Xyy*Nperp2/N6 - Xxx*X.dXyydY[i]*Nperp2/N6 - 2.0*Xxx*Xyy*Nperp1*dNperpdY[i]/N6 + Xxx*Xyy*Nperp2*dN6m1;
        dDdY[12][i] = -2.0*X.dXxydY[i]*Xxy*Nperp2/N6 - 2.0*Xxy2*Nperp1*dNperpdY[i]/N6 + Xxy2*Nperp2*dN6m1;
        dDdY[13][i] = -4.0*Nperp1*dNperpdY[i]/N6 + 2.0*Nperp2*dN6m1;
        dDdY[14][i] = -2.0*dNpardY[i]*Xyy*Xxz*Nperp1/N6 - 2.0*Npar1*X.dXyydY[i]*Xxz*Nperp1/N6 - 2.0*Npar1*Xyy*X.dXxzdY[i]*Nperp1/N6 - 2.0*Npar1*Xyy*Xxz*dNperpdY[i]/N6 + 2.0*Npar1*Xyy*Xxz*Nperp1*dN6m1;
        dDdY[15][i] = 2.0*dNpardY[i]*Xxy*Xyz*Nperp1/N6 + 2.0*Npar1*X.dXxydY[i]*Xyz*Nperp1/N6 + 2.0*Npar1*Xxy*X.dXyzdY[i]*Nperp1/N6 + 2.0*Npar1*Xxy*Xyz*dNperpdY[i]/N6 - 2.0*Npar1*Xxy*Xyz*Nperp1*dN6m1;
        dDdY[16][i] = -2.0*dNpardY[i]*Xxz*Nperp1/N6 - 2.0*Npar1*X.dXxzdY[i]*Nperp1/N6 - 2.0*Npar1*Xxz*dNperpdY[i]/N6 + 2.0*Npar1*Xxz*Nperp1*dN6m1;
        dDdY[17][i] = 6.0*Npar2*dNpardY[i]*Xxz*Nperp1/N6 + 2.0*Npar3*X.dXxzdY[i]*Nperp1/N6 + 2.0*Npar3*Xxz*dNperpdY[i]/N6 - 2.0*Npar3*Xxz*Nperp1*dN6m1;
        dDdY[18][i] = -dN6m1;
        dDdY[19][i] = 4.0*Npar3*Xzz*dNpardY[i]/N6 + Npar4*X.dXzzdY[i]/N6 - Npar4*Xzz*dN6m1;    
        dDdY[20][i] = 4.0*Npar3*dNpardY[i]/N6 - Npar4*dN6m1;
        dDdY[21][i] = 2.0*Npar1*dNpardY[i]*Xxz2/N6 + 2.0*Npar2*Xxz*X.dXxzdY[i]/N6 - Npar2*Xxz2*dN6m1;
        dDdY[22][i] = -2.0*Npar1*dNpardY[i]*Xyy*Xzz/N6 - Npar2*X.dXyydY[i]*Xzz/N6 - Npar2*Xyy*X.dXzzdY[i]/N6 + Npar2*Xyy*Xzz*dN6m1;
        dDdY[23][i] = -2.0*Npar1*dNpardY[i]*Xxx*Xzz/N6 - Npar2*X.dXxxdY[i]*Xzz/N6 - Npar2*Xxx*X.dXzzdY[i]/N6 + Npar2*Xxx*Xzz*dN6m1;
        dDdY[24][i] = -4.0*Npar1*dNpardY[i]*Xzz/N6 - 2.0*Npar2*X.dXzzdY[i]/N6 + 2.0*Npar2*Xzz*dN6m1;
        dDdY[25][i] = -2.0*Npar1*dNpardY[i]*Xyy/N6 - Npar2*X.dXyydY[i]/N6 + Npar2*Xyy*dN6m1;
        dDdY[26][i] = -2.0*Npar1*dNpardY[i]*Xyz2/N6 - 2.0*Npar2*Xyz*X.dXyzdY[i]/N6 + Npar2*Xyz2*dN6m1;
        dDdY[27][i] = -2.0*Npar1*dNpardY[i]*Xxx/N6 - Npar2*X.dXxxdY[i]/N6 + Npar2*Xxx*dN6m1;
        dDdY[28][i] = -4.0*Npar1*dNpardY[i]/N6 + 2.0*Npar2*dN6m1;
        dDdY[29][i] = X.dXyydY[i]*Xzz/N6 + Xyy*X.dXzzdY[i]/N6 - Xyy*Xzz*dN6m1;
        dDdY[30][i] = X.dXxxdY[i]*Xzz/N6 + Xxx*X.dXzzdY[i]/N6 - Xxx*Xzz*dN6m1;
        dDdY[31][i] = X.dXxxdY[i]*Xyy/N6 + Xxx*X.dXyydY[i]/N6 - Xxx*Xyy*dN6m1;
        dDdY[32][i] = X.dXxxdY[i]*Xyz2/N6 + 2.0*Xxx*Xyz*X.dXyzdY[i]/N6 - Xxx*Xyz2*dN6m1;
        dDdY[33][i] = 2.0*Xyz*X.dXyzdY[i]/N6 - Xyz2*dN6m1;
        dDdY[34][i] = X.dXxxdY[i]/N6 - Xxx*dN6m1;
        dDdY[35][i] = 2.0*Xxy*X.dXxydY[i]/N6 - Xxy2*dN6m1;
        dDdY[36][i] = 2.0*Xxy*X.dXxydY[i]*Xzz/N6 + Xxy2*X.dXzzdY[i]/N6 - Xxy2*Xzz*dN6m1;    
        dDdY[37][i] = -2.0*Xxz*X.dXxzdY[i]/N6 + Xxz2*dN6m1;
        dDdY[38][i] = -X.dXyydY[i]*Xxz2/N6 - 2.0*Xyy*Xxz*X.dXxzdY[i]/N6 + Xyy*Xxz2*dN6m1;
        dDdY[39][i] = X.dXyydY[i]/N6 - Xyy*dN6m1;
        dDdY[40][i] = X.dXzzdY[i]/N6 - Xzz*dN6m1;
        dDdY[41][i] = X.dXxxdY[i]*Xyy*Xzz/N6 + Xxx*X.dXyydY[i]*Xzz/N6 + Xxx*Xyy*X.dXzzdY[i]/N6 - Xxx*Xyy*Xzz*dN6m1;
        dDdY[42][i] = 2.0*X.dXxydY[i]*Xyz*Xxz/N6 + 2.0*Xxy*X.dXyzdY[i]*Xxz/N6 + 2.0*Xxy*Xyz*X.dXxzdY[i]/N6 - 2.0*Xxy*Xyz*Xxz*dN6m1;
    }

    for (i = 0;i<MC;i++) {
        dDtotdY[i] = 0.0; 
    }

    for (i = 0;i<43;i++) {
        for (j=0;j<MC;j++) {
            dDtotdY[j] = dDtotdY[j] + dDdY[i][j]; 
        }
    }

    if (equilparam.zZi[0] > 0) {
        Ydot[0] = -creal(dDtotdY[3])/creal(dDtotdY[6]); 
        Ydot[1] = -creal(dDtotdY[4])/creal(dDtotdY[6]); 
        Ydot[2] = -creal(dDtotdY[5])/creal(dDtotdY[6]); 
        Ydot[3] = creal(dDtotdY[0])/creal(dDtotdY[6]); 
        Ydot[4] = creal(dDtotdY[1])/creal(dDtotdY[6]);
        Ydot[5] = 0.0; 
        Ydot[6] = 0.0; 
    } else {/* vacuum case */
        Ydot[0] = -creal(dN2dY[3])/creal(dN2dY[6]); 
        Ydot[1] = -creal(dN2dY[4])/creal(dN2dY[6]); 
        Ydot[2] = -creal(dN2dY[5])/creal(dN2dY[6]); 
        Ydot[3] = creal(dN2dY[0])/creal(dN2dY[6]); 
        Ydot[4] = creal(dN2dY[1])/creal(dN2dY[6]);
        Ydot[5] = 0.0; 
        Ydot[6] = 0.0; 
    }

    /* Calculation of the infinitesimal path length */
    
    metrictensor(Gcov,raymagnetic);
    
    Sdot2 = 0.0;
    
    for (i=0;i<3;i++) {
        for (j=0;j<3;j++) {
            Sdot2 = Sdot2 + Gcov[i][j]*Ydot[i]*Ydot[j]; 
        }
    }
    
    Sdot[0] = sqrt(Sdot2);
    
    /* test for the cold dispersion relation */
/*    
    double complex P0,P2,P4,dP0dY[MC],dP2dY[MC],dP4dY[MC];
    double complex Kpar,Kperp,Kxy,dKpardY[MC],dKperpdY[MC],dKxydY[MC];
    double complex Dot_cold,dDtot_colddY[MC];
    double Ydot_cold[MC];

    Kpar = (1 + Xzz)/N2;
    Kperp = (1 + Xxx)/N2;
    Kxy = I*Xxy/N2;

    P0 = Kpar*((Npar2/N2 - Kperp)*(Npar2/N2 - Kperp) - Kxy*Kxy);
    P2 = (Npar2/N2 - Kperp)*(Kpar + Kperp) + Kxy*Kxy;
    P4 = Kperp;

    Dot_cold = P4*Nperp4/N2/N2 + P2*Nperp2/N2 + P0;
    mexPrintf("Dtot_cold:%g,%g\n",Dot_cold);

    for (i=0;i<MC;i++) {
        dKpardY[i] = X.dXzzdY[i]/N2 - (1+Xzz)*dN2dY[i]/N2/N2;
        dKperpdY[i] = X.dXxxdY[i]/N2 - (1+Xxx)*dN2dY[i]/N2/N2;
        dKxydY[i] = I*X.dXxydY[i]/N2 - I*Xxy*dN2dY[i]/N2/N2;  
        dP0dY[i] = dKpardY[i]*((Npar2/N2 - Kperp)*(Npar2/N2 - Kperp) - Kxy*Kxy) + Kpar*(2*(Npar2/N2 - Kperp)*(2*Npar1*dNpardY[i]/N2 - Npar2*dN2dY[i]/N2/N2 - dKperpdY[i]) - 2*Kxy*dKxydY[i]);  
        dP2dY[i] = (2*Npar1*dNpardY[i]/N2 - Npar2*dN2dY[i]/N2/N2 - dKperpdY[i])*(Kpar + Kperp) + (Npar2/N2 - Kperp)*(dKpardY[i] + dKperpdY[i]) + 2*Kxy*dKxydY[i];
        dP4dY[i] = dKperpdY[i];
        dDtot_colddY[i] = dP4dY[i]*Nperp4/N2/N2 + dP2dY[i]*Nperp2/N2 + dP0dY[i] + P4*(4*Nperp3*dNperpdY[i]/N2/N2 - 2*Nperp4*dN2dY[i]/N2/N2/N2) + P2*(2*Nperp*dNperpdY[i]/N2 - Nperp2*dN2dY[i]/N2/N2);
    }

    Ydot[0] = -creal(dDtot_colddY[3])/creal(dDtot_colddY[6]); 
    Ydot[1] = -creal(dDtot_colddY[4])/creal(dDtot_colddY[6]); 
    Ydot[2] = -creal(dDtot_colddY[5])/creal(dDtot_colddY[6]); 
    Ydot[3] = creal(dDtot_colddY[0])/creal(dDtot_colddY[6]); 
    Ydot[4] = creal(dDtot_colddY[1])/creal(dDtot_colddY[6]); 
    Ydot[5] = 0.0; 
    Ydot[6] = 0.0; 
*/
    
/*
    
    mexPrintf("dN2dY[1]:%g\n",dN2dY[1]);
    mexPrintf("dDtotdY:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",dDtotdY[0],dDtotdY[1],dDtotdY[2],dDtotdY[3],dDtotdY[4],dDtotdY[5],dDtotdY[6],dDtotdY[7]);
    mexPrintf("dDtot_colddY:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",dDtot_colddY[0],dDtot_colddY[1],dDtot_colddY[2],dDtot_colddY[3],dDtot_colddY[4],dDtot_colddY[5],dDtot_colddY[6]);
    mexPrintf("Ydot:%g,%g,%g,%g,%g,%g,%g,%g\n",Ydot[0],Ydot[1],Ydot[2],Ydot[3],Ydot[4],Ydot[5],Ydot[6],Ydot[7]);
    mexPrintf("Ydot_cold:%g,%g,%g,%g,%g,%g,%g\n",Ydot_cold[0],Ydot_cold[1],Ydot_cold[2],Ydot_cold[3],Ydot_cold[4],Ydot_cold[5],Ydot_cold[6]);
    
*/

}

void metrictensor(Gcov,raymagnetic)
double Gcov[3][3];
raymagnetic_format raymagnetic;
{
    Gcov[0][0] = 1/raymagnetic.gradrhon[0]/raymagnetic.gradrhon[0]/raymagnetic.calpha[0]/raymagnetic.calpha[0];
    Gcov[0][1] = raymagnetic.rn[0]*raymagnetic.salpha[0]/raymagnetic.gradrhon[0]/raymagnetic.calpha[0]/raymagnetic.calpha[0];
    Gcov[0][2] = 0;
    Gcov[1][0] = Gcov[0][1];
    Gcov[1][1] = raymagnetic.rn[0]*raymagnetic.rn[0]/raymagnetic.calpha[0]/raymagnetic.calpha[0];
    Gcov[1][2] = 0;
    Gcov[2][0] = Gcov[0][2];
    Gcov[2][1] = Gcov[1][2];
    Gcov[2][2] = raymagnetic.Rn[0]*raymagnetic.Rn[0];        
}

void rayprocess(rayproc,param,raymagnetic,rayprofiles,X,equilparam,Y,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,flag)
double rayproc[];
rayparam_format param;
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
susceptibilitytensor_format X;
equilparam_format equilparam;
double Y[];
pp_1D_format Te_fit;
pp_1D_format ne_fit;
pp_1D_format zTi_fit;
pp_1D_format zni_fit;
pp_2D_format x_fit;
pp_2D_format y_fit;
pp_2D_format Bx_fit;
pp_2D_format By_fit;
pp_2D_format BPHI_fit;
pp_1D_format dxstardpsin_fit;
double flag;
{
    double Npar,Npar2,dNpardY[MC];
    double complex Nperp,dNperpdY[MC];
    double complex N2,dN2dY[MC];
    
    double complex Dtot;
    double complex a,b,c,d,epolx,epoly,epolz,epolp,epolm;
    double epolnorm,alphaphi,phix,phiy,phiz,pmin,pmax,yn,yn2;
    int n,nmin,nmax,flagn;
    register int i;
    
    double wcn[equilparam.ns[0]+1],wpn2[equilparam.ns[0]+1],betath[equilparam.ns[0]+1];

    /* Equilibrium interpolation at ray location */
    if (flag == 0) {
       interpequil(param,raymagnetic,rayprofiles,equilparam,Y,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit);
    } else {
       interpequil_test(raymagnetic,rayprofiles,equilparam,Y,flag);
    }

    /* Refractive index calculation */
    rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardY,dNperpdY,dN2dY);

    /* Susceptibility tensor  */

    susceptibility(X,wcn,wpn2,betath,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,Y[6]);

    /* dipersion relation */
    disprel(&Dtot,X,raymagnetic,Npar,Nperp,N2);

    /* test mode */
    
    /*
    epolp = 0.7;
    epolm = 0.7;
    epolz = 0.1;
    n = 0;
    phix = 0.1;
    phiy = 0.0;
    phiz = 0.5;
    */
    
    /* polarization vector */
    
    a = X.Xxz[0] + Npar*Nperp;
    b = Npar*Npar - 1 - X.Xxx[0];
    c = Nperp*Nperp - 1 - X.Xzz[0];
    
    /* 
    epolx = -I*(X.Xxy[0] - X.Xyz[0]*a/c);
    epoly = -I*(b - a*a/c);
    epolz = (X.Xyz[0]*b - X.Xxy[0]*a)/c;
    */
    
    epolx = I*(X.Xxy[0] - X.Xyz[0]*a/c);
    epoly = -I*(b - a*a/c);
    epolz = -I*(X.Xyz[0]*b - X.Xxy[0]*a)/c;
    
    epolnorm = sqrt(cabs(epolx)*cabs(epolx) + cabs(epoly)*cabs(epoly) + cabs(epolz)*cabs(epolz));
    
    epolx = epolx/epolnorm;
    epoly = epoly/epolnorm;
    epolz = epolz/epolnorm;    
    
    epolp = (epolx + I*epoly)/sqrt(2);
    epolm = (epolx - I*epoly)/sqrt(2); 
    
    /* energy flow vector */
    
    /* poynting contribution */
    
    phix = creal(Nperp);
    phiy = 0;
    phiz = Npar;
    
    d = conj(epolx)*Nperp + conj(epolz)*Npar;
        
    phix = phix - creal(d*epolx);
    phiy = phiy - creal(d*epoly);
    phiz = phiz - creal(d*epolz);
    
    /* thermal contribution */
    
    /*mexPrintf("epolx,epoly,epolz,d:%g+i*%g,%g+i*%g,%g+i*%g,%g+i*%g\n",epolx,epoly,epolz,d);
    mexPrintf("creal(Nperp),Npar,-creal(d*epolx),-creal(d*epoly),-creal(d*epolz):%g,%g,%g,%g,%g\n",creal(Nperp),Npar,-creal(d*epolx),-creal(d*epoly),-creal(d*epolz));
    mexPrintf("phiPx,phiPy,phiPz:%g,%g,%g\n",phix,phiy,phiz);*/
    
    phix = phix - creal(conj(epolx)*X.dXxxdNperp[0]*epolx)/2
                - 2*creal(conj(epolx)*X.dXxydNperp[0]*epoly)/2
                - 2*creal(conj(epolx)*X.dXxzdNperp[0]*epolz)/2
                - creal(conj(epoly)*X.dXyydNperp[0]*epoly)/2
                - 2*creal(conj(epoly)*X.dXyzdNperp[0]*epolz)/2
                - creal(conj(epolz)*X.dXzzdNperp[0]*epolz)/2;
                
    phiz = phiz - creal(conj(epolx)*X.dXxxdNpar[0]*epolx)/2
                - 2*creal(conj(epolx)*X.dXxydNpar[0]*epoly)/2
                - 2*creal(conj(epolx)*X.dXxzdNpar[0]*epolz)/2
                - creal(conj(epoly)*X.dXyydNpar[0]*epoly)/2
                - 2*creal(conj(epoly)*X.dXyzdNpar[0]*epolz)/2
                - creal(conj(epolz)*X.dXzzdNpar[0]*epolz)/2;
                
    /*mexPrintf("phiP,phiP,phiP:%g,%g,%g\n",phix,phiy,phiz);*/
    
    /*mexPrintf("wpn2,wcn,betath,Npar,Nperp,epolp,epolm,epolz,n,rel_opt,nperp,pperpmax:%g,%g,%g,%g,%g,%g,%g,%g,%i,%i,%i,%g\n",wpn2[0],wcn[0],betath[0],Npar,creal(Nperp),epolp,epolm,epolz,n,(int)param.rel_opt[0],(int)param.nperp[0],param.pperpmax[0]);*/

    /* harmonics to be considered */
    
    flagn = 0;
    Npar2 = Npar*Npar;
    pmax = param.pperpmax[0];
    
    if (Npar2 > 1 && betath[0]*pmax*sqrt(Npar2 - 1) > 1) {
        nmin = 0; /* Landau damping is significant */
    } else {
        nmin = 1; /* Only cyclotron damping is significant */
    }
    
    nmax = 0;
    
    while (flagn == 0) {
        nmax = nmax + 1;
        
        yn = -wcn[0]*nmax;
        yn2 = yn*yn;
        
        /* Minimum of p on resonance curves */
        
        if (Npar2 > 1) {
            pmin = fabs(sqrt(yn2 + Npar2 - 1) - sqrt(Npar2)*yn)/(Npar2 - 1)/betath[0];
        } else {
        if (Npar2 == 1) {
            pmin = fabs(yn2 - 1)/yn/betath[0]/2;
        } else {
        if (Npar2 < 1) {
            if (yn2 > 1 - Npar2) {
                pmin = fabs(sqrt(yn2 + Npar2 - 1) - sqrt(Npar2)*yn)/(1 - Npar2)/betath[0];
            } else {
                pmin = pmax + 1;
            }
        }}}
        
        if (pmin > pmax) { 
            if (yn <= 1) { /* LFS */
                if (nmin > 0) {
                    nmin = nmin + 1;
                }
            } else { /* HFS */
                nmax = nmax - 1;
                flagn = 1;
            }
        }
    }
    
    /*mexPrintf("nmin,nmax:%i,%i\n",nmin,nmax);*/
    
    /* wave absorption coefficient */
    
    alphaphi = 0.0;
    
    for (n=nmin;n<nmax+1;n++) {
        alphaphi = alphaphi + alphaphi_jd(wpn2[0],-wcn[0],betath[0],Npar,creal(Nperp),epolp,epolm,epolz,n,(int)param.rel_opt[0],(int)param.nperp[0],pmax);
    }
    
    rayproc[0] = cabs(Dtot);
    rayproc[1] = Npar;
    rayproc[2] = creal(Nperp);
    rayproc[3] = creal(epolp);
    rayproc[4] = cimag(epolp);
    rayproc[5] = creal(epolm);
    rayproc[6] = cimag(epolm);
    rayproc[7] = creal(epolz);
    rayproc[8] = cimag(epolz);
    rayproc[9] = phix;
    rayproc[10] = phiy;
    rayproc[11] = phiz;
    rayproc[12] = alphaphi;
    rayproc[13] = raymagnetic.Rn[0];
	rayproc[14] = raymagnetic.Zn[0];
    rayproc[15] = raymagnetic.B[0];
    rayproc[16] = raymagnetic.Bsn[0];
    rayproc[17] = raymagnetic.BPHIn[0];
    rayproc[18] = raymagnetic.rn[0];
    rayproc[19] = raymagnetic.salpha[0];
    rayproc[20] = raymagnetic.gradrhon[0];
    rayproc[21] = rayprofiles.Te[0];
    rayproc[22] = rayprofiles.ne[0];
    
    for (i=0;i<equilparam.ns[0];i++) {
        rayproc[MPROC + i] = rayprofiles.zTi[i];      
        rayproc[MPROC + equilparam.ns[0] + i] = rayprofiles.zni[i];      
    }    

}

int reflection(rayparam,equilparam,raymagnetic,krho2,rho1,theta1,krho1,m1,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit)
rayparam_format rayparam;
equilparam_format equilparam;
raymagnetic_format raymagnetic;
double *krho2;
double rho1,theta1,krho1,m1;
pp_2D_format x_fit;
pp_2D_format y_fit;
pp_2D_format BPHI_fit;
pp_2D_format Bx_fit;
pp_2D_format By_fit;
pp_1D_format dxstardpsin_fit;
{

    double x,R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho;
    double y,Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho;
    double BR,dBRdrho,dBRdtheta;
    double BZ,dBZdrho,dBZdtheta;
    double BPHI,dBPHIdrho,dBPHIdtheta;
    double dRstardpsin,ddRstardpsindrho;
    double dummy1,dummy2;
    
    double delta, krho2p,krho2m;

    ppval_1D(dxstardpsin_fit,rayparam.dS[0],rho1,&dRstardpsin,&ddRstardpsindrho);
    ppval_2D(x_fit,rayparam.dS[0],rho1,theta1,&x,&dRdrho,&dRdtheta,&d2Rdtheta2,&d2Rdthetadrho);
    R = x + equilparam.Rp[0];
    ppval_2D(y_fit,rayparam.dS[0],rho1,theta1,&y,&dZdrho,&dZdtheta,&d2Zdtheta2,&d2Zdthetadrho);
    Z = y + equilparam.Zp[0];
    ppval_2D(Bx_fit,rayparam.dS[0],rho1,theta1,&BR,&dBRdrho,&dBRdtheta,&dummy1,&dummy2);
    ppval_2D(By_fit,rayparam.dS[0],rho1,theta1,&BZ,&dBZdrho,&dBZdtheta,&dummy1,&dummy2);
    ppval_2D(BPHI_fit,rayparam.dS[0],rho1,theta1,&BPHI,&dBPHIdrho,&dBPHIdtheta,&dummy1,&dummy2);  

    build_raymagnetic(theta1,raymagnetic,equilparam,R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho,Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho,BR,dBRdrho,dBRdtheta,BZ,dBZdrho,dBZdtheta,BPHI,dBPHIdrho,dBPHIdtheta,dRstardpsin,ddRstardpsindrho);

    delta = m1*m1*raymagnetic.salpha[0]*raymagnetic.salpha[0]/raymagnetic.rn[0]/raymagnetic.rn[0]
        - raymagnetic.gradrhon[0]*krho1*(-krho1*raymagnetic.gradrhon[0] + 2*m1*raymagnetic.salpha[0]/raymagnetic.rn[0]);
    krho2p = (m1*raymagnetic.salpha[0]/raymagnetic.rn[0] + sqrt(delta))/raymagnetic.gradrhon[0];
    krho2m = (m1*raymagnetic.salpha[0]/raymagnetic.rn[0] - sqrt(delta))/raymagnetic.gradrhon[0];
        
    if (sgn(krho2p)*sgn(krho1) < 0) { 
        krho2[0] = krho2p;
    } else {
        krho2[0] = krho2m;
    }

    if (sgn(krho2p)*sgn(krho2m) >= 0) { 
/*  mexPrintf("delta,krho1,krho2p,krho2m:%g,%g,%g,%g\n",delta,krho1,krho2p,krho2m); */
        mexPrintf("WARNING: Problem for the wave reflection at the plasma edge. Try to modify dt0 or PSHRINK is raytracing_yp.c !\n");
    return(-1);
    }

}


void dsolve(mode,krho,Y,raymagnetic,rayprofiles,X,param,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,flag)
int mode;
double *krho;
double Y[];
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
susceptibilitytensor_format X;
rayparam_format param;
equilparam_format equilparam;
pp_1D_format Te_fit;
pp_1D_format ne_fit;
pp_1D_format zTi_fit;
pp_1D_format zni_fit;
pp_2D_format x_fit;
pp_2D_format y_fit;
pp_2D_format Bx_fit;
pp_2D_format By_fit;
pp_2D_format BPHI_fit;
pp_1D_format dxstardpsin_fit;
double flag;
{
    double Npar,dNpardY[MC];
    double complex Nperp,dNperpdY[MC];
    double complex N2,dN2dY[MC];

    double frac,fracmax,exp,tol;
    double krho0,krho1,krho2,dkrho;
    double complex cD0,cD1;
    double D0,D1,D2;
    int maxit;

    double wcn[equilparam.ns[0]+1],wpn2[equilparam.ns[0]+1],betath[equilparam.ns[0]+1];

    register int j;
    
    frac = 1 - 1e-4;
    fracmax = 2;
    exp = -1.5;
    tol = 1e-12;
    
    maxit = 50;

    /* Equilibrium interpolation at ray location */
    if (flag == 0) {
        interpequil(param,raymagnetic,rayprofiles,equilparam,Y,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit);
    } else {
        interpequil_test(raymagnetic,rayprofiles,equilparam,Y,flag);
    }

    krho0 = Y[3];
    krho1 = frac*krho0;
    
    rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardY,dNperpdY,dN2dY);
    if (mode > 0) {/* plasma case */
        susceptibility(X,wcn,wpn2,betath,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,Y[6]);
    }
        
    disprel(&cD0,X,raymagnetic,Npar,Nperp,N2);
    D0 = creal(cD0);/* to be changed if non-hermitian susceptibility tensors are used */
/*  mexPrintf("krho0,D0:%g,%g\n",krho0,D0); */
    
    Y[3] = krho1;
    rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardY,dNperpdY,dN2dY);
    if (mode > 0) {/* plasma case */
        susceptibility(X,wcn,wpn2,betath,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,Y[6]);
    }
    disprel(&cD1,X,raymagnetic,Npar,Nperp,N2);
    D1 = creal(cD1);/* to be changed if non-hermitian susceptibility tensors are used */
/*  mexPrintf("krho1,D1:%g,%g\n",krho1,D1); */

    /* Search for root bounding interval */

    while ((D1*D0 > 0) && (fracmax < 100)){
        
        frac = pow(frac,exp);
        krho1 = frac*krho0;
       
        Y[3] = krho1;
        rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardY,dNperpdY,dN2dY);
        if (mode > 0) {/* plasma case */
            susceptibility(X,wcn,wpn2,betath,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,Y[6]);
        }
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
            rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardY,dNperpdY,dN2dY);
            if (mode > 0) {/* plasma case */
                susceptibility(X,wcn,wpn2,betath,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,Y[6]);
            }
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
    
    
    /* krho[0] = -Y[3]; /* old method not accurate */ 
    
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
    Dtot1 = (Xxx+1)*Nperp4/N6+2*Npar1*Xxz*Nperp3/N6-(-2*Npar2+Xyy-Npar2*Xzz+Xxy2+Xzz-Xxz2+Xxx*Xzz+Xxx*Xyy+2+2*Xxx-Xxx*Npar2)*Nperp2/N6-(2*Npar1*Xxz+2*Npar1*Xyy*Xxz-2*Xxy*Xyz*Npar-2*Npar3*Xxz)*Nperp1/N6-(-1-Xxx*Xyz2-Xxy2*Xzz+Xyy*Xxz2-2*Xxy*Xyz*Xxz-Xxx*Xyy*Xzz-Xzz+2*Npar2-Xyy-Xyz2-Npar4-Xxx-Xxy2+Xxz2+2*Npar2*Xzz-Xyy*Xzz+Npar2*Xyy-Xxx*Xzz+Xxx*Npar2-Xxx*Xyy-Npar4*Xzz+Npar2*Xyz2-Npar2*Xxz2+Npar2*Xyy*Xzz+Xxx*Npar2*Xzz)/N6;   
    mexPrintf("Dtot1:%g\n",Dtot1);
*/

    D[0] = Nperp4/N6;
    D[1] = Xxx*Nperp4/N6;
    D[2] = 2.0*Npar1*Xxz*Nperp3/N6;
    D[3] = Npar2*Xxx*Nperp2/N6;
    D[4] = Npar2*Xzz*Nperp2/N6;
    D[5] = 2.0*Npar2*Nperp2/N6;
    D[6] = -2.0*Xxx*Nperp2/N6;
    D[7] = -Xyy*Nperp2/N6;
    D[8] = -Xzz*Nperp2/N6;
    D[9] = -Xxx*Xzz*Nperp2/N6;
    D[10] = Xxz2*Nperp2/N6;
    D[11] = -Xxx*Xyy*Nperp2/N6;
    D[12] = -Xxy2*Nperp2/N6;
    D[13] = -2.0*Nperp2/N6;    
    D[14] = -2.0*Npar1*Xyy*Xxz*Nperp1/N6;
    D[15] = 2.0*Npar1*Xxy*Xyz*Nperp1/N6;
    D[16] = -2.0*Npar1*Xxz*Nperp1/N6;
    D[17] = 2.0*Npar3*Xxz*Nperp1/N6;
    D[18] = 1/N6;
    D[19] = Npar4*Xzz/N6;
    D[20] = Npar4/N6;
    D[21] = Npar2*Xxz2/N6;
    D[22] = -Npar2*Xyy*Xzz/N6;
    D[23] = -Npar2*Xxx*Xzz/N6;
    D[24] = -2.0*Npar2*Xzz/N6;
    D[25] = -Npar2*Xyy/N6;
    D[26] = -Npar2*Xyz2/N6;
    D[27] = -Npar2*Xxx/N6;
    D[28] = -2.0*Npar2/N6;
    D[29] = Xyy*Xzz/N6;
    D[30] = Xxx*Xzz/N6;
    D[31] = Xxx*Xyy/N6;
    D[32] = Xxx*Xyz2/N6;
    D[33] = Xyz2/N6;
    D[34] = Xxx/N6;
    D[35] = Xxy2/N6;
    D[36] = Xxy2*Xzz/N6;
    D[37] = -Xxz2/N6;
    D[38] = -Xyy*Xxz2/N6;
    D[39] = Xyy/N6;
    D[40] = Xzz/N6;
    D[41] = Xxx*Xyy*Xzz/N6;
    D[42] = 2.0*Xxy*Xyz*Xxz/N6;

/*     for (i = 0;i<43;i++) {
        mexPrintf("i,Dr,Di:%d,%g\n",i,creal(D[i]),cimag(D[i]));
    }*/

    Dtot[0] = 0.0;
    for (i = 0;i<43;i++) {
        Dtot[0] = Dtot[0] + D[i];
    }

   /* mexPrintf("Dtot:%g\n",Dtot[0]);*/

}

void susceptibility(X,wcn,wpn2,betath,tensortype,ncyclharm,equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,omega)
susceptibilitytensor_format X;
double wcn[],wpn2[],betath[];
double tensortype,omega;
int ncyclharm;
double Npar,dNpardY[];
double complex Nperp,dNperpdY[];

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

    double dwcndY[equilparam.ns[0]+1][MC],dwpn2dY[equilparam.ns[0]+1][MC],dbetathdY[equilparam.ns[0]+1][MC];

    int i,j,is;
    
    if (equilparam.zZi[0] > 0) {
    
        for (i = 0;i < equilparam.ns[0] + 1; i++) {/*initialisation */
            wcn[i] = 0.0;
            wpn2[i] = 0.0;
            betath[i] = 0.0;
            for (j=0;j<MC;j++) {
                dwcndY[i][j] = 0.0;
                dwpn2dY[i][j] = 0.0;
                dbetathdY[i][j] = 0.0;
            }
        }
    
        /* Normalized parameters */

        wcn[0] = -qe*raymagnetic.B[0]/me/omega;/*electrons */
        dwcndY[0][0] = -qe*raymagnetic.dBdY[0]/me/omega;
        dwcndY[0][1] = -qe*raymagnetic.dBdY[1]/me/omega;
        dwcndY[0][6] = -wcn[0];

        wpn2[0] = qe*qe*rayprofiles.ne[0]/epsi0/me/omega/omega;/*electrons */
        dwpn2dY[0][0] = qe*qe*rayprofiles.dnedY[0]/epsi0/me/omega/omega;
        dwpn2dY[0][6] = -2.0*wpn2[0];

        betath[0] = sqrt(rayprofiles.Te[0]/mc2);
        dbetathdY[0][0] = rayprofiles.dTedY[0]/betath[0]/2.0;

        for (is = 1;is < equilparam.ns[0]+1; is++) {
            if (rayprofiles.zni[is-1] > 0.0) {/* only when ion density is positive */
                wcn[is] = qe*equilparam.zZi[is-1]*raymagnetic.B[0]/equilparam.zmi[is-1]/mp/omega;/*ions */
                dwcndY[is][0] = qe*equilparam.zZi[is-1]*raymagnetic.dBdY[0]/equilparam.zmi[is-1]/mp/omega;
                dwcndY[is][1] = qe*equilparam.zZi[is-1]*raymagnetic.dBdY[1]/equilparam.zmi[is-1]/mp/omega; 
                dwcndY[is][6] = -wcn[is]; 

                wpn2[is] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*rayprofiles.zni[is-1]/epsi0/equilparam.zmi[is-1]/mp/omega/omega;/*ions */
                dwpn2dY[is][0] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*rayprofiles.dznidY[is-1][0]/epsi0/equilparam.zmi[is-1]/mp/omega/omega;        
                dwpn2dY[is][6] = -2.0*wpn2[is]; 

                betath[is] = sqrt(rayprofiles.zTi[is-1]*me/equilparam.zmi[is-1]/mp/mc2);
                dbetathdY[is][0] = rayprofiles.dzTidY[is-1][0]/betath[is]/2.0;
            }
        }
        
        if (tensortype == 0) {
/*        mexPrintf("Cold dielectric tensor\n"); */
            coldtensor(X,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardY,Nperp,dNperpdY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY);
        }
        if (tensortype == 1) {
/*        mexPrintf("Warm dielectric tensor\n");
            warmtensor(X,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardY,Nperp,dNperpdY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY); */
        }
        if (tensortype == 2) {
/*        mexPrintf("Hot dielectric tensor\n");*/
            hottensor(X,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardY,Nperp,dNperpdY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY); 
        }
        if (tensortype == 3) {
        mexPrintf("Weak relativistic dielectric tensor\n");
            weakrelativistictensor(X,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardY,Nperp,dNperpdY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY);
        }       
        if (tensortype == 4) {
/*        mexPrintf("Full relativistic dielectric tensor\n");
            fullrelativistictensor(X,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardY,Nperp,dNperpdY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY); */
        }       
        
    } else {
        vacuumtensor(X);
    }

} 


void rayindex(mode,Y,raymagnetic,equilparam,Npar,Nperp,N2,dNpardY,dNperpdY,dN2dY)
int mode;
double Y[];
double *Npar,*dNpardY;
double complex *Nperp,*dNperpdY;
double complex *N2,*dN2dY;
raymagnetic_format raymagnetic;
equilparam_format equilparam;
{ 
    double dYdY[MC][MC];

    double Npar1,dNpar1dY,dNpar1dY1,dNpar1dY2,dNpar1dY3,dNpar1dY4,dNpar1dY5;
    double Npar2,dNpar2dY,dNpar2dY1,dNpar2dY2,dNpar2dY3,dNpar2dY4;
      
    double complex N21,dN21dY,dN21dY1,dN21dY2,dN21dY3;
    double complex N22,dN22dY,dN22dY1,dN22dY2,dN22dY3,dN22dY4,dN22dY5,dN22dY6;
    double complex N23,dN23dY,dN23dY1,dN23dY2,dN23dY3;
    double complex N24,dN24dY,dN24dY1,dN24dY2,dN24dY3;
    
    double ap,cnorm;
    double clum=CLUM;

    register int i,j;
    
    /*Covariant matrix */

    for (i=0;i<MC;i++) {
        for (j=0;j<MC;j++) {
            if ((i==j) && (i<7)) {
                dYdY[i][j] = 1.0;
            } else {
                dYdY[i][j] = 0.0;
            }
        }
    }

    
    for (i=0;i<MC;i++) {/*initialisation */
        dNpardY[i] = 0.0;
        dNperpdY[i] = 0.0;
        dN2dY[i] = 0.0;
    }
    
    ap = equilparam.ap[0];
    cnorm = clum/ap/Y[6];
    
   /*  mexPrintf("clum_norm,ap,clum,Y[6]:%g,%g,%g,%g\n",cnorm,ap,clum,Y[6]); */
    
    if (mode == 1) { 
        
        Npar1 = Y[4]*raymagnetic.calpha[0]*raymagnetic.Bsn[0]/raymagnetic.rn[0];
        Npar2 = Y[5]*raymagnetic.BPHIn[0]/raymagnetic.Rn[0];
  
        Npar[0] = cnorm*(Npar1 + Npar2);
        
/*
          mexPrintf("Nparth:%g\n",Npar[0]);
          mexPrintf("Y[0],Y[1],Y[2],Y[3],Y[4],Y[5]:%g,%g,%g,%g,%g,%g\n",Y[0],Y[1],Y[2],Y[3],Y[4],Y[5]);
          mexPrintf("Y[4],raymagnetic.calpha[0],raymagnetic.Bsn[0],raymagnetic.rn[0],Y[5],raymagnetic.BPHIn[0],raymagnetic.Rn[0]:%g,%g,%g,%g,%g,%g,%g\n",Y[4],raymagnetic.calpha[0],raymagnetic.Bsn[0],raymagnetic.rn[0],Y[5],raymagnetic.BPHIn[0],raymagnetic.Rn[0]);
*/
    
        for (i=0;i<MC;i++) {
    
            dNpar1dY1 = dYdY[4][i]*raymagnetic.calpha[0]*raymagnetic.Bsn[0]/raymagnetic.rn[0];
            dNpar1dY2 = Y[4]*raymagnetic.dcalphadY[i]*raymagnetic.Bsn[0]/raymagnetic.rn[0];
            dNpar1dY3 = Y[4]*raymagnetic.calpha[0]*raymagnetic.dBsndY[i]/raymagnetic.rn[0];
            dNpar1dY4 = -Y[4]*raymagnetic.calpha[0]*raymagnetic.Bsn[0]*dYdY[6][i]/raymagnetic.rn[0];
            dNpar1dY5 = -Y[4]*raymagnetic.calpha[0]*raymagnetic.Bsn[0]*raymagnetic.drndY[i]/raymagnetic.rn[0]/raymagnetic.rn[0];
        
            dNpar1dY = dNpar1dY1 + dNpar1dY2 + dNpar1dY3 + dNpar1dY4 + dNpar1dY5;
 
            dNpar2dY1 = dYdY[5][i]*raymagnetic.BPHIn[0]/raymagnetic.Rn[0];
            dNpar2dY2 = Y[5]*raymagnetic.dBPHIndY[i]/raymagnetic.Rn[0];
            dNpar2dY3 = -Y[5]*raymagnetic.BPHIn[0]*raymagnetic.dRndY[i]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dNpar2dY4 = -Y[5]*raymagnetic.BPHIn[0]*dYdY[6][i]/raymagnetic.Rn[0];
    
            dNpar2dY = dNpar2dY1 + dNpar2dY2 + dNpar2dY3 + dNpar2dY4;
        
            dNpardY[i] = cnorm*(dNpar1dY + dNpar2dY);
             
          /*   mexPrintf("i,dNpardY[i]:%d,%g\n",i,dNpardY[i]); */
          /*  mexPrintf("i,dYdY[3][i],dYdY[4][i],dYdY[5][i]:%d,%g,%g,%g\n",i,dYdY[3][i],dYdY[4][i],dYdY[4][i]); */
        }
    
        N21 = raymagnetic.gradrhon[0]*raymagnetic.gradrhon[0]*Y[3]*Y[3];
        N22 = -2.0*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*Y[3]/raymagnetic.rn[0];
        N23 = Y[4]*Y[4]/raymagnetic.rn[0]/raymagnetic.rn[0];
        N24 = Y[5]*Y[5]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
    
        N2[0] = cnorm*cnorm*(N21 + N22 + N23 + N24);
        Nperp[0] = sqrt(N2[0] - Npar[0]*Npar[0]);
        
/*        mexPrintf("Npar,Nperp,N2:%g,%g,%g,%g,%g\n",Npar[0],Nperp[0],N2[0]); */
        
        for (i=0;i<MC;i++) {
        
            dN21dY1 = 2.0*raymagnetic.gradrhon[0]*raymagnetic.dgradrhondY[i]*Y[3]*Y[3];
            dN21dY2 = 2.0*raymagnetic.gradrhon[0]*raymagnetic.gradrhon[0]*dYdY[3][i]*Y[3];
            dN21dY3 = -2.0*raymagnetic.gradrhon[0]*raymagnetic.gradrhon[0]*Y[3]*Y[3]*dYdY[6][i];
        
            dN21dY = dN21dY1 + dN21dY2 + dN21dY3;
        
            dN22dY1 = -2.0*raymagnetic.dgradrhondY[i]*raymagnetic.salpha[0]*Y[4]*Y[3]/raymagnetic.rn[0];
            dN22dY2 = -2.0*raymagnetic.gradrhon[0]*raymagnetic.dsalphadY[i]*Y[4]*Y[3]/raymagnetic.rn[0];
            dN22dY3 = -2.0*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*dYdY[4][i]*Y[3]/raymagnetic.rn[0];
            dN22dY4 = -2.0*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*dYdY[3][i]/raymagnetic.rn[0];
            dN22dY5 = 2.0*raymagnetic.drndY[i]*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*Y[3]/raymagnetic.rn[0]/raymagnetic.rn[0];
            dN22dY6 = 4.0*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*Y[3]*dYdY[6][i]/raymagnetic.rn[0];
        
            dN22dY = dN22dY1 + dN22dY2 + dN22dY3 + dN22dY4 + dN22dY5 + dN22dY6;
     
            dN23dY1 = 2.0*dYdY[4][i]*Y[4]/raymagnetic.rn[0]/raymagnetic.rn[0];
            dN23dY2 = -2.0*Y[4]*Y[4]*dYdY[6][i]/raymagnetic.rn[0]/raymagnetic.rn[0];
            dN23dY3 = -2.0*raymagnetic.drndY[i]*Y[4]*Y[4]/raymagnetic.rn[0]/raymagnetic.rn[0]/raymagnetic.rn[0];
        
            dN23dY = dN23dY1 + dN23dY2 + dN23dY3;
    
            dN24dY1 = 2.0*dYdY[5][i]*Y[5]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dN24dY2 = -2.0*Y[5]*Y[5]*raymagnetic.dRndY[i]/raymagnetic.Rn[0]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dN24dY3 = -2.0*Y[5]*Y[5]/raymagnetic.Rn[0]/raymagnetic.Rn[0]*dYdY[6][i];
        
            dN24dY = dN24dY1 + dN24dY2 + dN24dY3;
        
            dN2dY[i] = cnorm*cnorm*(dN21dY + dN22dY + dN23dY + dN24dY);

            dNperpdY[i] = (dN2dY[i] - 2.0*Npar[0]*dNpardY[i])/Nperp[0]/2.0;
               

        }
        
        
 /*      mexPrintf("Y[]:%g,%g,%g,%g,%g,%g,%g\n",Y[0],Y[1],Y[2],Y[3],Y[4],Y[5]);
         mexPrintf("r,2*r*drdY[]:%g,%g,%g,%g,%g,%g,%g,%g,%g\n",raymagnetic.rn[0],2.0*raymagnetic.rn[0]*raymagnetic.drndY[0],2.0*raymagnetic.rn[0]*raymagnetic.drndY[1],2.0*raymagnetic.rn[0]*raymagnetic.drndY[2],2.0*raymagnetic.rn[0]*raymagnetic.drndY[3],2.0*raymagnetic.rn[0]*raymagnetic.drndY[4],2.0*raymagnetic.rn[0]*raymagnetic.drndY[5],2.0*raymagnetic.rn[0]*raymagnetic.drndY[6],2.0*raymagnetic.rn[0]*raymagnetic.drndY[7],2.0*raymagnetic.rn[0]*raymagnetic.drndY[8]); 
         mexPrintf("dN2dY[]:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",dN2dY[0],dN2dY[1],dN2dY[2],dN2dY[3],dN2dY[4],dN2dY[5],dN2dY[6],dN2dY[7]); 
*/
    } else {
        
        
        
        
        
    }
    
}

void buildXstruc(X,ns,dNpardY,dNperpdY,dwcndY,dwpn2dY,dbetathdY,Xxx,Xxy,Xxz,Xyy,Xyz,Xzz,dXxxdNperp,dXxydNperp,dXxzdNperp,dXyydNperp,dXyzdNperp,dXzzdNperp,dXxxdNpar,dXxydNpar,dXxzdNpar,dXyydNpar,dXyzdNpar,dXzzdNpar,dXxxdbetath,dXxydbetath,dXxzdbetath,dXyydbetath,dXyzdbetath,dXzzdbetath,dXxxdwcn,dXxydwcn,dXxzdwcn,dXyydwcn,dXyzdwcn,dXzzdwcn,dXxxdwpn2,dXxydwpn2,dXxzdwpn2,dXyydwpn2,dXyzdwpn2,dXzzdwpn2)
susceptibilitytensor_format X;
int ns;
double dwcndY[][MC],dwpn2dY[][MC],dbetathdY[][MC],dNpardY[];
double complex dNperpdY[];
double complex Xxx[],Xxy[],Xxz[],Xyy[],Xyz[],Xzz[];
double complex dXxxdNperp[],dXxydNperp[],dXxzdNperp[],dXyydNperp[],dXyzdNperp[],dXzzdNperp[];
double complex dXxxdNpar[],dXxydNpar[],dXxzdNpar[],dXyydNpar[],dXyzdNpar[],dXzzdNpar[];
double complex dXxxdbetath[],dXxydbetath[],dXxzdbetath[],dXyydbetath[],dXyzdbetath[],dXzzdbetath[];
double complex dXxxdwcn[],dXxydwcn[],dXxzdwcn[],dXyydwcn[],dXyzdwcn[],dXzzdwcn[];
double complex dXxxdwpn2[],dXxydwpn2[],dXxzdwpn2[],dXyydwpn2[],dXyzdwpn2[],dXzzdwpn2[];
{
    
    int i,is;
    
    X.Xxx[0] = Xxx[0];
    X.Xxy[0] = Xxy[0];
    X.Xxz[0] = Xxz[0];
    X.Xyy[0] = Xyy[0];
    X.Xyz[0] = Xyz[0];
    X.Xzz[0] = Xzz[0];

    for (is = 1;is < ns + 1;is++) {
        X.Xxx[0] = X.Xxx[0] + Xxx[is];
        X.Xxy[0] = X.Xxy[0] + Xxy[is];
        X.Xxz[0] = X.Xxz[0] + Xxz[is];
        X.Xyy[0] = X.Xyy[0] + Xyy[is];
        X.Xyz[0] = X.Xyz[0] + Xyz[is];
        X.Xzz[0] = X.Xzz[0] + Xzz[is];           
    }

    X.dXxxdNperp[0] = dXxxdNperp[0];
    X.dXxydNperp[0] = dXxydNperp[0];
    X.dXxzdNperp[0] = dXxzdNperp[0];
    X.dXyydNperp[0] = dXyydNperp[0];
    X.dXyzdNperp[0] = dXyzdNperp[0];
    X.dXzzdNperp[0] = dXzzdNperp[0];

    for (is = 1;is < ns + 1;is++) {
        X.dXxxdNperp[0] = X.dXxxdNperp[0] + dXxxdNperp[is];
        X.dXxydNperp[0] = X.dXxydNperp[0] + dXxydNperp[is];
        X.dXxzdNperp[0] = X.dXxzdNperp[0] + dXxzdNperp[is];
        X.dXyydNperp[0] = X.dXyydNperp[0] + dXyydNperp[is];
        X.dXyzdNperp[0] = X.dXyzdNperp[0] + dXyzdNperp[is];
        X.dXzzdNperp[0] = X.dXzzdNperp[0] + dXzzdNperp[is];           
    }

    X.dXxxdNpar[0] = dXxxdNpar[0];
    X.dXxydNpar[0] = dXxydNpar[0];
    X.dXxzdNpar[0] = dXxzdNpar[0];
    X.dXyydNpar[0] = dXyydNpar[0];
    X.dXyzdNpar[0] = dXyzdNpar[0];
    X.dXzzdNpar[0] = dXzzdNpar[0];

    for (is = 1;is < ns + 1;is++) {
        X.dXxxdNpar[0] = X.dXxxdNpar[0] + dXxxdNpar[is];
        X.dXxydNpar[0] = X.dXxydNpar[0] + dXxydNpar[is];
        X.dXxzdNpar[0] = X.dXxzdNpar[0] + dXxzdNpar[is];
        X.dXyydNpar[0] = X.dXyydNpar[0] + dXyydNpar[is];
        X.dXyzdNpar[0] = X.dXyzdNpar[0] + dXyzdNpar[is];
        X.dXzzdNpar[0] = X.dXzzdNpar[0] + dXzzdNpar[is];           
    }

    for (i = 0;i < MC;i++) {/* Initialisation */
         X.dXxxdY[i] = 0.0;
         X.dXxydY[i] = 0.0;
         X.dXxzdY[i] = 0.0;
         X.dXyydY[i] = 0.0;
         X.dXyzdY[i] = 0.0;
         X.dXzzdY[i] = 0.0;
    }
    
    
    for (i = 0;i < MC;i++) {
        for (is = 0;is < ns + 1;is++) {
            X.dXxxdY[i] = X.dXxxdY[i] + dXxxdNperp[is]*dNperpdY[i] + dXxxdNpar[is]*dNpardY[i] + dXxxdbetath[is]*dbetathdY[is][i] + dXxxdwcn[is]*dwcndY[is][i] + dXxxdwpn2[is]*dwpn2dY[is][i];
            X.dXxydY[i] = X.dXxydY[i] + dXxydNperp[is]*dNperpdY[i] + dXxydNpar[is]*dNpardY[i] + dXxydbetath[is]*dbetathdY[is][i] + dXxydwcn[is]*dwcndY[is][i] + dXxydwpn2[is]*dwpn2dY[is][i];
            X.dXxzdY[i] = X.dXxzdY[i] + dXxzdNperp[is]*dNperpdY[i] + dXxzdNpar[is]*dNpardY[i] + dXxzdbetath[is]*dbetathdY[is][i] + dXxzdwcn[is]*dwcndY[is][i] + dXxzdwpn2[is]*dwpn2dY[is][i];
            X.dXyydY[i] = X.dXyydY[i] + dXyydNperp[is]*dNperpdY[i] + dXyydNpar[is]*dNpardY[i] + dXyydbetath[is]*dbetathdY[is][i] + dXyydwcn[is]*dwcndY[is][i] + dXyydwpn2[is]*dwpn2dY[is][i];
            X.dXyzdY[i] = X.dXyzdY[i] + dXyzdNperp[is]*dNperpdY[i] + dXyzdNpar[is]*dNpardY[i] + dXyzdbetath[is]*dbetathdY[is][i] + dXyzdwcn[is]*dwcndY[is][i] + dXyzdwpn2[is]*dwpn2dY[is][i];
            X.dXzzdY[i] = X.dXzzdY[i] + dXzzdNperp[is]*dNperpdY[i] + dXzzdNpar[is]*dNpardY[i] + dXzzdbetath[is]*dbetathdY[is][i] + dXzzdwcn[is]*dwcndY[is][i] + dXzzdwpn2[is]*dwpn2dY[is][i];      
        }
    }
    
/*    for (i = 0;i < MC;i++) {
        mexPrintf("i,dbetathdY[1][i]:%d,%g\n",i,dbetathdY[1][i]);
        mexPrintf("i,dwcndY[1][i]:%d,%g\n",i,dwcndY[1][i]);
        mexPrintf("i,dwpn2dY[1][i]:%d,%g\n",i,dwpn2dY[1][i]);
        mexPrintf("i,dXxxdY,dXxydY,dXxzdY,dXyydY,dXyzdY,dXzzdY:%d,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",i,X.dXxxdY[i],X.dXxydY[i],X.dXxzdY[i],X.dXyydY[i],X.dXyzdY[i],X.dXzzdY[i]);
        mexPrintf("i,dNpardY[i],dNperpdY[i]:%d,%g,%g\n",i,dNpardY[i],dNperpdY[i]);
    }
 */    
   
}





void interpequil(rayparam,raymagnetic,rayprofiles,equilparam,Y,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit)
rayparam_format rayparam;
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
equilparam_format equilparam;
double Y[];
pp_1D_format Te_fit;
pp_1D_format ne_fit;
pp_1D_format zTi_fit;
pp_1D_format zni_fit;
pp_2D_format x_fit;
pp_2D_format y_fit;
pp_2D_format Bx_fit;
pp_2D_format By_fit;
pp_2D_format BPHI_fit;
pp_1D_format dxstardpsin_fit;
{
/* interpolation from numerical equilibrium data*/
    
    double dummyTi[equilparam.ns[0]],dummyni[equilparam.ns[0]];
    double x,R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho;
    double y,Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho;
    double BR,dBRdrho,dBRdtheta;
    double BZ,dBZdrho,dBZdtheta;
    double BPHI,dBPHIdrho,dBPHIdtheta;
    double dRstardpsin,ddRstardpsindrho;
    double dummy1,dummy2;
    
    int i,is;
    
    /* Equilibrium interpolation */
    
    ppval_1D(dxstardpsin_fit,rayparam.dS[0],Y[0],&dRstardpsin,&ddRstardpsindrho);
    
    if (equilparam.zZi[0] > 0) {
        ppval_1D(Te_fit,rayparam.dS[0],Y[0],&rayprofiles.Te[0],&rayprofiles.dTedY[0]);
        ppval_1D(ne_fit,rayparam.dS[0],Y[0],&rayprofiles.ne[0],&rayprofiles.dnedY[0]);
        ppval_1D(zTi_fit,rayparam.dS[0],Y[0],rayprofiles.zTi,dummyTi);
        for (is=0;is<equilparam.ns[0];is++) {
            rayprofiles.dzTidY[is][0] = dummyTi[is];
        }
    
        ppval_1D(zni_fit,rayparam.dS[0],Y[0],rayprofiles.zni,dummyni);
            for (is=0;is<equilparam.ns[0];is++) {
            if (rayprofiles.zni > 0) {
                 rayprofiles.dznidY[is][0] = dummyni[is];
            }
        }
        
   
 /*   for (i=0;i<equilparam.ns[0];i++) {
        mexPrintf("i,Ti,dzTidY[0],dzTidY[1],dzTidY[2],dzTidY[3],dzTidY[4],dzTidY[5],dzTidY[6]:%d,%g,%g,%g,%g,%g,%g,%g,%g\n",i,rayprofiles.zTi[i],rayprofiles.dzTidY[i][0],rayprofiles.dzTidY[i][1],rayprofiles.dzTidY[i][2],rayprofiles.dzTidY[i][3],rayprofiles.dzTidY[i][4],rayprofiles.dzTidY[i][5],rayprofiles.dzTidY[i][6]);
        mexPrintf("i,ni,dznidY[0],dznidY[1],dznidY[2],dznidY[3],dznidY[4],dznidY[5],dznidY[6]:%d,%g,%g,%g,%g,%g,%g,%g,%g\n",i,rayprofiles.zni[i],rayprofiles.dznidY[i][0],rayprofiles.dznidY[i][1],rayprofiles.dznidY[i][2],rayprofiles.dznidY[i][3],rayprofiles.dznidY[i][4],rayprofiles.dznidY[i][5],rayprofiles.dznidY[i][6]);

    }*/   
        
/*        
        mexPrintf("rho,theta:%g,%g\n",Y[0],Y[1]);
        mexPrintf("Te[0],dTedY[0],dTedY[1],ne[0],dnedY[0],dnedY[1]:%g,%g,%g,%g,%g,%g\n",rayprofiles.Te[0],rayprofiles.dTedY[0],rayprofiles.dTedY[1],rayprofiles.ne[0],rayprofiles.dnedY[0],rayprofiles.dnedY[1]);
        for (is=0;is<equilparam.ns[0];is++) {
           mexPrintf("is,zTi[is],dzTidY[is][0],dzTidY[is][1],zni[is],dznidY[is][0],dznidY[is][1]:%d,%g,%g,%g,%g,%g,%g\n",is,rayprofiles.zTi[is],rayprofiles.dzTidY[is][0],rayprofiles.dzTidY[is][1],rayprofiles.zni[is],rayprofiles.dznidY[is][0],rayprofiles.dznidY[is][1]);
        }
        */
    }

 
    ppval_2D(x_fit,rayparam.dS[0],Y[0],Y[1],&x,&dRdrho,&dRdtheta,&d2Rdtheta2,&d2Rdthetadrho);
    R = x + equilparam.Rp[0];
    ppval_2D(y_fit,rayparam.dS[0],Y[0],Y[1],&y,&dZdrho,&dZdtheta,&d2Zdtheta2,&d2Zdthetadrho);
    Z = y + equilparam.Zp[0];
    ppval_2D(Bx_fit,rayparam.dS[0],Y[0],Y[1],&BR,&dBRdrho,&dBRdtheta,&dummy1,&dummy2);
    ppval_2D(By_fit,rayparam.dS[0],Y[0],Y[1],&BZ,&dBZdrho,&dBZdtheta,&dummy1,&dummy2);
    ppval_2D(BPHI_fit,rayparam.dS[0],Y[0],Y[1],&BPHI,&dBPHIdrho,&dBPHIdtheta,&dummy1,&dummy2);
    
    build_raymagnetic(Y[1],raymagnetic,equilparam,R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho,Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho,BR,dBRdrho,dBRdtheta,BZ,dBZdrho,dBZdtheta,BPHI,dBPHIdrho,dBPHIdtheta,dRstardpsin,ddRstardpsindrho);
}

void build_raymagnetic(theta,raymagnetic,equilparam,R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho,Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho,BR,dBRdrho,dBRdtheta,BZ,dBZdrho,dBZdtheta,BPHI,dBPHIdrho,dBPHIdtheta,dRstardpsin,ddRstardpsindrho) 
raymagnetic_format raymagnetic;
equilparam_format equilparam;

double theta;
double R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho;
double Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho;
double BR,dBRdrho,dBRdtheta;
double BZ,dBZdrho,dBZdtheta;
double BPHI,dBPHIdrho,dBPHIdtheta;
double dRstardpsin,ddRstardpsindrho;

{
    double r,drdrho,drdtheta;
    double BP,dBPdrho,dBPdtheta;
    double B,dBdrho,dBdtheta;
    double salpha,dsalphadrho,dsalphadtheta;
    double sn,sigmaIp;

    
/*    WARNING: the definitions used in the DKE code, and here crucial for HXR calculations are the following
          1) the toroidal frame (R,Z,phi) is direct (phi is positive clockwise when the tokamak is seen from the top)
          2) the poloidal frame (r,theta,phi) is direct
          3) (psi,s,phi) must be direct : if Ip.phi > 0, then B.theta > 0 and psi > 0, and s.theta > 0 (s as the same direction of theta)
          4) the sign of psi is the sign of Ip.phi
  With the definitions above, if Ip is positive, psi is turned outward, Btheta is counterclockwise poloidally, and s too. The Ampere theorem is OK !
  This definition is used also for DKE and HXR calculations
 */   
    
    sigmaIp =  sgn(equilparam.psia[0]);/* Sign of the plasma current (only valid for tokamak, not for RFP !) */

    BP = sqrt(BR*BR + BZ*BZ);/* Poloidal magnetic field */
    dBPdrho = (BR*dBRdrho + BZ*dBZdrho)/BP;
    dBPdtheta = (BR*dBRdtheta + BZ*dBZdtheta)/BP;
    
    B = sqrt(BR*BR + BZ*BZ + BPHI*BPHI);/* Total magnetic field */
    dBdrho = (BR*dBRdrho + BZ*dBZdrho + BPHI*dBPHIdrho)/B;
    dBdtheta = (BR*dBRdtheta + BZ*dBZdtheta + BPHI*dBPHIdtheta)/B;
    
    raymagnetic.Bsn[0] = sigmaIp*BP/B;/* Normlaized poloidal magnetic field */
    raymagnetic.dBsndY[0] = sigmaIp*(dBPdrho/B - BP*dBdrho/B/B);
    raymagnetic.dBsndY[1] = sigmaIp*(dBPdtheta/B - BP*dBdtheta/B/B);
   
    raymagnetic.BPHIn[0] = BPHI/B;/* Normlaized toroidal magnetic field */
    raymagnetic.dBPHIndY[0] = dBPHIdrho/B - BPHI*dBdrho/B/B;
    raymagnetic.dBPHIndY[1] = dBPHIdtheta/B - BPHI*dBdtheta/B/B;
    
    raymagnetic.B[0] = B;/* Total magnetic field */
    raymagnetic.dBdY[0] = dBdrho;
    raymagnetic.dBdY[1] = dBdtheta;
    
    r = sqrt((R - equilparam.Rp[0])*(R - equilparam.Rp[0])+(Z - equilparam.Zp[0])*(Z - equilparam.Zp[0]));
    drdrho = (dRdrho*(R - equilparam.Rp[0]) + dZdrho*(Z - equilparam.Zp[0]))/r;
    drdtheta = (dRdtheta*(R - equilparam.Rp[0]) + dZdtheta*(Z - equilparam.Zp[0]))/r;
    
    raymagnetic.rn[0] = r/equilparam.ap[0];
    raymagnetic.drndY[0] = drdrho/equilparam.ap[0];
    raymagnetic.drndY[1] = drdtheta/equilparam.ap[0];
    
    raymagnetic.Rn[0] = R/equilparam.ap[0];
    raymagnetic.dRndY[0] = dRdrho/equilparam.ap[0];
    raymagnetic.dRndY[1] = dRdtheta/equilparam.ap[0];    
    
    raymagnetic.Zn[0] = Z/equilparam.ap[0];
    raymagnetic.dZndY[0] = dZdrho/equilparam.ap[0];
    raymagnetic.dZndY[1] = dZdtheta/equilparam.ap[0];
    
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
    raymagnetic.dsalphadY[0] = dsalphadrho;
    raymagnetic.dsalphadY[1] = dsalphadtheta;
    
    raymagnetic.calpha[0] = sqrt(1.0 - salpha*salpha);
    raymagnetic.dcalphadY[0] = -salpha*dsalphadrho/sqrt(1.0 - salpha*salpha);
    raymagnetic.dcalphadY[1] = -salpha*dsalphadtheta/sqrt(1.0 - salpha*salpha); 

    raymagnetic.gradrhon[0] = R*BP*dRstardpsin/fabs(equilparam.psia[0]);
    raymagnetic.dgradrhondY[0] = (dRdrho*BP*dRstardpsin + R*dBPdrho*dRstardpsin + R*BP*ddRstardpsindrho)/fabs(equilparam.psia[0]);
    raymagnetic.dgradrhondY[1] = (dRdtheta*BP*dRstardpsin + R*dBPdtheta*dRstardpsin)/fabs(equilparam.psia[0]);
/*    
    mexPrintf("rn[0],drndY[0],drndY[1],Rn[0],dRndY[0],dRndY[1],Zn[0],dZndY[0],dZndY[1]:%g,%g,%g,%g,%g,%g,%g,%g,%g\n",raymagnetic.rn[0],raymagnetic.drndY[0],raymagnetic.drndY[1],raymagnetic.Rn[0],raymagnetic.dRndY[0],raymagnetic.dRndY[1],raymagnetic.Zn[0],raymagnetic.dZndY[0],raymagnetic.dZndY[1]);
    mexPrintf("Bsn[0],dBsndY[0],dBsndY[1]:%g,%g,%g\n",raymagnetic.Bsn[0],raymagnetic.dBsndY[0],raymagnetic.dBsndY[1]);
    mexPrintf("BPHIn[0],dBPHIndY[0],dBPHIndY[1]:%g,%g,%g\n",raymagnetic.BPHIn[0],raymagnetic.dBPHIndY[0],raymagnetic.dBPHIndY[1]);
    mexPrintf("B[0],dBdY[0],dBdY[1]:%g,%g,%g\n",raymagnetic.B[0],raymagnetic.dBdY[0],raymagnetic.dBdY[1]);
    mexPrintf("salpha[0],dsalphadY[0],dsalphadY[1]:%g,%g,%g\n",raymagnetic.salpha[0],raymagnetic.dsalphadY[0],raymagnetic.dsalphadY[1]);
 
  
    mexPrintf("calpha[0],dcalphadY[0],dcalphadY[1]:%g,%g,%g\n",raymagnetic.calpha[0],raymagnetic.dcalphadY[0],raymagnetic.dcalphadY[1]);
    mexPrintf("gradrhon[0],dgradrhondY[0],dgradrhondY[1]:%g,%g,%g\n",raymagnetic.gradrhon[0],raymagnetic.dgradrhondY[0],raymagnetic.dgradrhondY[1]);
    mexPrintf("dRstardpsin,ddRstardpsindrho,psia:%g,%g,%gma\n",dRstardpsin,ddRstardpsindrho,equilparam.psia[0]);
*/
}

void interpequil_test(raymagnetic,rayprofiles,equilparam,Y,flag)
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
equilparam_format equilparam;/* is an output in this case, since nothing is used from MatLab */
double Y[];
double flag;
{
/* toroidal circular equilibrium from Bonoli and Ott, PoF 25, 359 (1982) */
    
    /*  In this equilibrium the radial coordinate is psi = r/a.
        The Shafranov shift is neglected in first approximation.
        As a consequence, BT0 and BP0 are uniform.
     */
    
    double Te0,Tea,eTe;
    double ne0,nea,ene;
    double Ti0,Tia,eTi;
    double fi[3],zZi[4],zmi[4];
    
    double Zp,Rp,ap,rho,theta,cyl;
    double BPHI0,BP0,dBP0dY1;
    double B,dBdrho,dBdtheta;
    double BP,dBPdrho,dBPdtheta;
    double BPHI,dBPHIdrho,dBPHIdtheta;
    double R,dRdrho,dRdtheta;
    double Z,dZdrho,dZdtheta;
    double Zeff0,Zeffa,eZeff,pZeff,dpZeffdrho;
    
    double Ip,BPa,sigmaIp,eq,qmin,qmax,q,dqdrho,ep;
    
    int is,ns;
   
    rho = Y[0];
    theta = Y[1];
    
    load_idealequil_test(flag,&cyl,&Zp,&Rp,&ap,&BPHI0,&Ip,&eq,&qmin,&Te0,&Tea,&eTe,&ne0,&nea,&ene,&Ti0,&Tia,&eTi,&Zeff0,&Zeffa,&eZeff,&ns,fi,zZi,zmi);
    
    ep = ap/Rp;
        
/* 
    mexPrintf("ap,Rp,Zp,BPHI0,Ip,eq,qmin,Te0,Tea,eTe,ne0,nea,ene,Ti0,Tia,eTi,Zeff0,Zeffa,eZeff,n=%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",ap,Rp,Zp,BPHI0,Ip,eq,qmin,Te0,Tea,eTe,ne0,nea,ene,Ti0,Tia,eTi,Zeff0,Zeffa,eZeff);
    mexPrintf("fi[0],fi[1],fi[2],zZi[0],zZi[1],zZi[2],zmi[0],zmi[1],zmi[2]=%g,%g,%g,%g,%g,%g,%g,%g,%g\n",fi[0],fi[1],fi[2],zZi[0],zZi[1],zZi[2],zmi[0],zmi[1],zmi[2]);
*/      
    pZeff = Zeff0 + (Zeffa-Zeff0)*pow(rho,eZeff);
    dpZeffdrho = eZeff*(Zeffa-Zeff0)*pow(rho,eZeff-1);
    
    if (ns > 4) {
       mexErrMsgTxt("Only one fully stripped impurity can be used !"); 
    }
   
    if ((abs(flag) == 1) || (abs(flag) == 2))  {/*Jetlike and RTtest */
    
       rayprofiles.Te[0] = Tea + (Te0 - Tea)*pow(1 - rho*rho,eTe);
       rayprofiles.dTedY[0] = -2*rho*eTe*(Te0 - Tea)*pow(1 - rho*rho,eTe - 1);  
    
       rayprofiles.ne[0] = nea + (ne0 - nea)*pow(1 - rho*rho,ene);
       rayprofiles.dnedY[0] = -2*rho*ene*(ne0 - nea)*pow(1 - rho*rho,ene - 1);  
    
    
       for (is=0;is<ns;is++) {
           rayprofiles.zTi[is] = Tia + (Ti0 - Tia)*pow(1 - rho*rho,eTi);
           rayprofiles.dzTidY[is][0] = -2*rho*eTi*(Ti0 - Tia)*pow(1 - rho*rho,eTi - 1);     
       }
    } else if ((abs(flag) == 3) || (abs(flag) == 4)) {/*VERSATOR2 and PLT */        
        
       rayprofiles.Te[0] = Tea + (Te0 - Tea)*(exp(-eTe*Y[0]*Y[0]) - exp(-eTe))/(1 - exp(-eTe));
       rayprofiles.dTedY[0] = -2*eTe*Y[0]*(Te0 - Tea)*exp(-eTe*Y[0]*Y[0])/(1 - exp(-eTe));  
    
       rayprofiles.ne[0] = nea + (ne0 - nea)*(exp(ene) - exp(ene*Y[0]*Y[0]))/(exp(ene) - 1);
       rayprofiles.dnedY[0] = -2*ene*Y[0]*(ne0 - nea)*exp(ene*Y[0]*Y[0])/(exp(ene) - 1);  
    
       for (is=0;is<ns;is++) {
           rayprofiles.zTi[is] = Tia + (Ti0 - Tia)*(exp(-eTi*Y[0]*Y[0]) - exp(-eTi))/(1 - exp(-eTi));
           rayprofiles.dzTidY[is][0] = -2*eTi*Y[0]*(Ti0 - Tia)*exp(-eTi*Y[0]*Y[0])/(1 - exp(-eTi));;     
       }
    }
    
    for (is=0;is<3;is++) { /*For a single impurity fully stripped. Only the first is selected after the isotope of hydrogen */
        rayprofiles.zni[is] = fi[is]*rayprofiles.ne[0]*(equilparam.zZi[3] - pZeff)/(equilparam.zZi[3]-1.0);
        rayprofiles.dznidY[is][0] = fi[is]*(rayprofiles.dnedY[0]*(equilparam.zZi[3] - pZeff) - rayprofiles.ne[0]*dpZeffdrho)/(equilparam.zZi[3]-1.0);     
    }
    
    for (is=3;is<ns;is++) {/*For a single impurity fully stripped. Only the first is selected after the isotope of hydrogen */
        rayprofiles.zni[is] = rayprofiles.ne[0]*(pZeff - 1.0)/(equilparam.zZi[3]-1)/equilparam.zZi[3];
        rayprofiles.dznidY[is][0] = (rayprofiles.dnedY[0]*(pZeff - 1.0) + rayprofiles.ne[0]*dpZeffdrho)/(equilparam.zZi[3]-1)/equilparam.zZi[3];         
    }
              
    equilparam.zZi = zZi;
    equilparam.zmi = zmi;
    equilparam.ns[0] = ns;

    equilparam.Rp[0] = Rp;
    equilparam.ap[0] = ap;
    equilparam.Zp[0] = Zp;

    raymagnetic.rn[0] = rho;
    raymagnetic.drndY[0] = 1.0;
    raymagnetic.drndY[1] = 0.0;
    
    R = Rp + ap*rho*cos(theta);
    dRdrho = ap*cos(theta);
    dRdtheta = -ap*rho*sin(theta);
    
    raymagnetic.Rn[0] = R/ap;
    raymagnetic.dRndY[0] = dRdrho/ap;
    raymagnetic.dRndY[1] = dRdtheta/ap;
    
    Z = Zp + ap*rho*sin(theta);
    dZdrho = ap*sin(theta);
    dZdtheta = ap*rho*cos(theta);
    
    raymagnetic.Zn[0] = Z/ap;
    raymagnetic.dZndY[0] = dZdrho/ap;
    raymagnetic.dZndY[1] = dZdtheta/ap;
    
    BPHI = Rp*BPHI0/R;
    dBPHIdrho = -BPHI*dRdrho/R;
    dBPHIdtheta =  -BPHI*dRdtheta/R;
    
    BPa = 0.2*fabs(Ip)/ap;/* MA */
    qmax = ep*cyl*fabs(BPHI0)/BPa;/* cylindrical limit */
    
    if ((abs(flag) == 1) || (abs(flag) == 3) ||(abs(flag) == 4))  {/*RTtest, VERSATOR2 and PLT */
       q = (qmax - qmin)*pow(Y[0],eq) + qmin;
       dqdrho = eq*(qmax - qmin)*pow(Y[0],eq - 1.0);
       equilparam.psia[0] = ap*ap*fabs(BPHI0)*log(qmax/qmin)/(qmax - qmin)/2;
 /*      mexPrintf("qmax,BPa,equilparam.psia[0] = %g,%g,%g\n",qmax,BPa,equilparam.psia[0]);*/
        
    } else if(abs(flag) == 2) {/*JETlike */
  /*  BP = BPa*(1 - pow(1 - rho*rho,2))*Rp/R/rho;/* Poloidal magnetic field, cylindrical limit */
  /*  dBPdrho = BPa*(4*(1 - rho*rho) - (1 - pow(1 - rho*rho,2))/rho/rho)*Rp/R - BP*dRdrho/R; */
       
       if (Y[0] == 0.0) {
          q = qmax/(1+eq);
          dqdrho = 0.0;   
       } else {
          q = qmax*pow(Y[0],2)/(1 - pow(1-Y[0]*Y[0],1+eq));  
          dqdrho = 2*q*(1 - (eq+1)*pow(1-Y[0]*Y[0],eq)*q/qmax)/Y[0];    
       }        
       equilparam.psia[0] = ap*ap*Rp*BPa*3/4/ap;  
    }
     
    BP = qmax*BPa*Rp*Y[0]/q/R;/* Poloidal magnetic field, cylindrical limit */
    dBPdrho = qmax*BPa*Rp*(1.0 - dqdrho*Y[0]/q - dRdrho*Y[0]/R)/q/R;
    dBPdtheta = -BP*dRdtheta/R;
    
    /* mexPrintf("ap,Rp,BPa,rho,BP,BPHI0,R,dBPdrho,dBPdtheta:%g,%g,%g,%g,%g,%g,%g,%g,%g\n",ap,Rp,BPa,rho,BP,BPHI0,R,dBPdrho,dBPdtheta); */
      
    sigmaIp = sgn(Ip);
    
    B = sqrt(BP*BP + BPHI*BPHI);
    dBdrho = (BP*dBPdrho + BPHI*dBPHIdrho)/B;
    dBdtheta = (BP*dBPdtheta + BPHI*dBPHIdtheta)/B; 
    
    raymagnetic.BPHIn[0] = BPHI/B;
    raymagnetic.dBPHIndY[0] = dBPHIdrho/B - BPHI*dBdrho/B/B;
    raymagnetic.dBPHIndY[1] = dBPHIdtheta/B - BPHI*dBdtheta/B/B;
   
    raymagnetic.Bsn[0] = sigmaIp*BP/B;
    raymagnetic.dBsndY[0] = sigmaIp*(dBPdrho/B - BP*dBdrho/B/B);
    raymagnetic.dBsndY[1] = sigmaIp*(dBPdtheta/B - BP*dBdtheta/B/B);
    
    raymagnetic.B[0] = B;
    raymagnetic.dBdY[0] = dBdrho;
    raymagnetic.dBdY[1] = dBdtheta;

    raymagnetic.calpha[0] = 1.0;
    raymagnetic.dcalphadY[0] = 0.0;
    raymagnetic.dcalphadY[1] = 0.0;
    
    raymagnetic.salpha[0] = 0.0;
    raymagnetic.dsalphadY[0] = 0.0;
    raymagnetic.dsalphadY[1] = 0.0;
    
    raymagnetic.gradrhon[0] = 1.0;
    raymagnetic.dgradrhondY[0] = 0.0;
    raymagnetic.dgradrhondY[1] = 0.0;
    
/*    
   
    mexPrintf("---- Interpequil_test ----\n");
    mexPrintf("rho,theta:%g,%g\n",rho,theta);
    mexPrintf("Te[0],dTedY[0],dTedY[1],ne[0],dnedY[0],dnedY[1]:%g,%g,%g,%g,%g,%g\n",rayprofiles.Te[0],rayprofiles.dTedY[0],rayprofiles.dTedY[1],rayprofiles.ne[0],rayprofiles.dnedY[0],rayprofiles.dnedY[1]);
    for (is=0;is<ns;is++) {
        mexPrintf("is,zTi[is],dzTidY[is][0],dzTidY[is][1],zni[is],dznidY[is][0],dznidY[is][1]:%d,%g,%g,%g,%g,%g,%g\n",is,rayprofiles.zTi[is],rayprofiles.dzTidY[is][0],rayprofiles.dzTidY[is][1],rayprofiles.zni[is],rayprofiles.dznidY[is][0],rayprofiles.dznidY[is][1]);
    }
    
   
    mexPrintf("rn[0],drndY[0],drndY[1],Rn[0],dRndY[0],dRndY[1],Zn[0],dZndY[0],dZndY[1]:%15.10g,%15.10g,%15.10g,%15.10g,%15.10g,%15.10g,%15.10g,%15.10g,%15.10g\n",raymagnetic.rn[0],raymagnetic.drndY[0],raymagnetic.drndY[1],raymagnetic.Rn[0],raymagnetic.dRndY[0],raymagnetic.dRndY[1],raymagnetic.Zn[0],raymagnetic.dZndY[0],raymagnetic.dZndY[1]);
    mexPrintf("Bsn[0],dBsndY[0],dBsndY[1]:%15.10g,%15.10g,%15.10g\n",raymagnetic.Bsn[0],raymagnetic.dBsndY[0],raymagnetic.dBsndY[1]);
    mexPrintf("BPHIn[0],dBPHIndY[0],dBPHIndY[1]:%15.10g,%15.10g,%15.10g\n",raymagnetic.BPHIn[0],raymagnetic.dBPHIndY[0],raymagnetic.dBPHIndY[1]);
    mexPrintf("B[0],dBdY[0],dBdY[1]:%15.10g,%15.10g,%15.10g\n",raymagnetic.B[0],raymagnetic.dBdY[0],raymagnetic.dBdY[1]);
    mexPrintf("salpha[0],dsalphadY[0],dsalphadY[1]:%15.10g,%15.10g,%15.10g\n",raymagnetic.salpha[0],raymagnetic.dsalphadY[0],raymagnetic.dsalphadY[1]);
    mexPrintf("calpha[0],dcalphadY[0],dcalphadY[1]:%15.10g,%15.10g,%15.10g\n",raymagnetic.calpha[0],raymagnetic.dcalphadY[0],raymagnetic.dcalphadY[1]);
    mexPrintf("gradrhon[0],dgradrhondY[0],dgradrhondY[1]:%15.10g,%15.10g,%15.10g\n",raymagnetic.gradrhon[0],raymagnetic.dgradrhondY[0],raymagnetic.dgradrhondY[1]);
*/
}


double sgn(x)
double x;
{
   if (x < 0.0) {return(-1.0);} 
   if (x == 0.0) {return(0.0);}    
   if (x > 0.0) {return(1.0);}    
    
}


void load_idealequil_test(flag,cyl,Zp,Rp,ap,BPHI0,Ip,eq,qmin,Te0,Tea,eTe,ne0,nea,ene,Ti0,Tia,eTi,Zeff0,Zeffa,eZeff,ns,fi,zZi,zmi)
double *cyl,*Zp,*Rp,*ap,*BPHI0,*Ip,*eq,*qmin,*Te0,*Tea,*eTe,*ne0,*nea,*ene,*Ti0,*Tia,*eTi,*Zeff0,*Zeffa,*eZeff;
double fi[],zZi[],zmi[];
double flag;
int *ns;
{

   if (fabs(flag) == 1) {/* RTtest case */
      cyl[0] = 1.0;/* cylindrical factor */
    
      Rp[0] = 3.0*cyl[0];
      Zp[0] = 0;
      ap[0] = 0.9;
      BPHI0[0] = 3.0;/* Signed toroidal magnetic component (T), see the conventions */
      Ip[0] = 1.0;/* Signed toroidal component of the plasma current (MA), see the conventions */
      qmin[0] = 1.0;/* Edge safety factor q */
      eq[0] = 2.0;/* q=0 flat q profile */

      Te0[0] = 4.0;
      Tea[0] = Te0[0]/10.0;
      eTe[0] = 1.0;
    
      ne0[0] = 3.0e+19;
      nea[0] = 1e-10;
      ene[0] = 1.0;
    
      Ti0[0] = Te0[0];
      Tia[0] = Tea[0];
      eTi[0] = eTe[0];
    
      fi[0] = 1.0;
      fi[1] = 0.0;
      fi[2] = 0.0;
         
      zZi[0] = 1.0;
      zZi[1] = 1.0;
      zZi[2] = 1.0;
      zZi[3] = 6.0;/* Carbon */
      
      zmi[0] = 1.0;
      zmi[1] = 2.0;
      zmi[2] = 3.0;
      zmi[3] = 12.0;/* Carbon */
      
      ns[0] = 4;   
      
      Zeff0[0] = 1.0;/* No impurity case, only hydrogen */
      Zeffa[0] = 1.0;
      eZeff[0] = 0.0;
      
   } else if (fabs(flag) == 2) {/* Jetlike case */
      cyl[0] = 1.0;/* cylindrical factor */
    
      Rp[0] = 3.05*cyl[0];
      Zp[0] = 0;
      ap[0] = 0.95;
      BPHI0[0] = 3.2;/* Signed toroidal magnetic component (T), see the conventions */
      Ip[0] = 3.5;/* Signed toroidal component of the plasma current (MA), see the conventions */
      qmin[0] = 1.0;/* Edge safety factor q */
      eq[0] = 1.0;/* q=0 flat q profile */

      Te0[0] = 6.0;
      Tea[0] = 0.1;
      eTe[0] = 1.5;
    
      ne0[0] = 5.0e+19;
      nea[0] = 0.01e+19;
      ene[0] = 1.0;
    
      Ti0[0] = Te0[0];
      Tia[0] = Tea[0];
      eTi[0] = eTe[0];
    
      fi[0] = 1.0;
      fi[1] = 0.0;
      fi[2] = 0.0;
         
      zZi[0] = 1.0;
      zZi[1] = 1.0;
      zZi[2] = 1.0;
      
      zmi[0] = 1.0;
      zmi[1] = 2.0;
      zmi[2] = 3.0;
      
      ns[0] = 3;   
      
      Zeff0[0] = 1.0;/* No impurity case, only hydrogen */
      Zeffa[0] = 1.0;
      eZeff[0] = 0.0;
   } else if (fabs(flag) == 3) {/* VERSATOR2 case */
      cyl[0] = 1.0;/* cylindrical factor */
    
      Rp[0] = 0.4*cyl[0];
      Zp[0] = 0;
      ap[0] = 0.325*0.4;
      BPHI0[0] = 1.4;/* Signed toroidal magnetic component (T), see the conventions */
      Ip[0] = 0.05;/* Signed toroidal component of the plasma current (MA), see the conventions */
      qmin[0] = 1.0;/* Edge safety factor q */
      eq[0] = 2.0;/* q=0 flat q profile */

      Te0[0] = 0.40;
      Tea[0] = 0.02;
      eTe[0] = 3.94;
    
      ne0[0] = 2.0e19;
      nea[0] = 2e18;
      ene[0] = 0.1;
    
      Ti0[0] = 0.15;
      Tia[0] = 0.02;
      eTi[0] = 3.94;
    
      fi[0] = 1.0;
      fi[1] = 0.0;
      fi[2] = 0.0;
         
      zZi[0] = 1.0;
      zZi[1] = 1.0;
      zZi[2] = 1.0;
      zZi[3] = 6.0;
      
      zmi[0] = 1.0;
      zmi[1] = 2.0;
      zmi[2] = 3.0;
      zmi[3] = 12.0;
      
      ns[0] = 4;   
      
      Zeff0[0] = 2.0;/* No impurity case, only hydrogen */
      Zeffa[0] = 2.0;
      eZeff[0] = 0.0;
   } else if (fabs(flag) == 4) {/* PLT case */
      cyl[0] = 1.0;/* cylindrical factor */
    
      Rp[0] = 1.32*cyl[0];
      Zp[0] = 0;
      ap[0] = 0.303*1.32;
      BPHI0[0] = 3.1;/* Signed toroidal magnetic component (T), see the conventions */
      Ip[0] = 0.2;/* Signed toroidal component of the plasma current (MA), see the conventions */
      qmin[0] = 1.0;/* Edge safety factor q */
      eq[0] = 2.0;/* q=0 flat q profile */

      Te0[0] = 1.5;
      Tea[0] = 0.03;
      eTe[0] = 3.99;
    
      ne0[0] = 0.5625e19;
      nea[0] = 0.5625e18;
      ene[0] = -0.571;
    
      Ti0[0] = 0.5;
      Tia[0] = 0.03;
      eTi[0] = 2.90;
    
      fi[0] = 1.0;
      fi[1] = 0.0;
      fi[2] = 0.0;
         
      zZi[0] = 1.0;
      zZi[1] = 1.0;
      zZi[2] = 1.0;
      zZi[3] = 6.0;
      
      zmi[0] = 1.0;
      zmi[1] = 2.0;
      zmi[2] = 3.0;
      zmi[3] = 12.0;
      
      ns[0] = 4;   
      
      Zeff0[0] = 4.0;/* No impurity case, only hydrogen */
      Zeffa[0] = 4.0;
      eZeff[0] = 0.0;
    }
}

