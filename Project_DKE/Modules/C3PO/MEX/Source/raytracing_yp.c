/*
  
	raytracing.c	MEX file implementation of a universal ray-tracing for electron waves

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

	by Y.PEYSSON (CEA-DRFC)  <yves.peysson@cea.fr>, Joan Decker (CEA-DRFC) <joan.decker@cea.fr> and Laurent Colas (CEA-DRFC) <laurent.colas@cea.fr>
*/

#include <complex.h>
#include <math.h>
#include "mex.h"


struct raymagnetic {
    double *rn;
    double *drndY;
    double *Rn;
    double *dRndY;
    double *BPn;
    double *dBPndY;
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
    double *sigmaIp;
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

struct susceptibilitytensor {
    double complex *Xxx;
    double complex *Xxy;
    double complex *Xxz;
    double complex *Xyy;
    double complex *Xyz;
    double complex *Xzz;
    double complex *dXxxdY;
    double complex *dXxydY;
    double complex *dXxzdY;
    double complex *dXyydY;
    double complex *dXyzdY;
    double complex *dXzzdY; 
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
    double *reflection;
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

/* subroutines list */

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
void reflection();
void build_raymagnetic();
void weakrelativistictensor();
void Shka();
void ImShka();
void Fdnest();
void ImFdnest();


/* Input Arguments */

#define	RAYPARAM_IN	 prhs[0]
#define	EQUIL_IN	 prhs[1]
#define	Y0_IN	 prhs[2]

/* Output Arguments */

#define	T_OUT	plhs[0]
#define	Y_OUT	plhs[1]

#define	MC 8
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


void mexFunction(	int		nlhs,
	mxArray	*plhs[],
	int		nrhs,
	const mxArray	*prhs[]
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
        }
       
        x = mxCalloc(1,sizeof(double));
        dRdrho = mxCalloc(1,sizeof(double));
        dRdtheta = mxCalloc(1,sizeof(double));
        d2Rdtheta2 = mxCalloc(1,sizeof(double));
        d2Rdthetadrho = mxCalloc(1,sizeof(double));
        ppval_2D(x_fit,rayparam.drho[0],0.25,0.2,x,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho);
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
        ppval_2D(y_fit,rayparam.drho[0],0.25,0.2,y,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho);
        mexPrintf("Z(0.25,0.2),dZdrho(0.25,0.2),dZdtheta(0.25,0.2) (m): %g,%g,%g\n",y[0]+equilparam.Zp[0],dZdrho[0],dZdtheta[0],d2Zdtheta2[0],d2Zdthetadrho[0]);
        mxFree(y);
        mxFree(dZdrho); 
        mxFree(dZdtheta);
        mxFree(d2Zdtheta2);
        mxFree(d2Zdthetadrho);
                       
        BR = mxCalloc(1,sizeof(double));
        dBRdrho = mxCalloc(1,sizeof(double));
        dBRdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(Bx_fit,rayparam.drho[0],0.25,0.2,BR,dBRdrho,dBRdtheta,&dummy1,&dummy2);
        mexPrintf("BR(0.25,0.2),dBRdrho(0.25,0.2),dBRdtheta(0.25,0.2) (T): %g,%g,%g\n",BR[0],dBRdrho[0],dBRdtheta[0]);
        mxFree(BR);
        mxFree(dBRdrho); 
        mxFree(dBRdtheta); 

        BZ = mxCalloc(1,sizeof(double));
        dBZdrho = mxCalloc(1,sizeof(double));
        dBZdtheta = mxCalloc(1,sizeof(double));
        ppval_2D(By_fit,rayparam.drho[0],0.25,0.2,BZ,dBZdrho,dBZdtheta,&dummy1,&dummy2);
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

    double	*tout,*yout; 
    double	*toutp,*youtp;
    double	*y0,*y1;

    register unsigned int	K=0,m,k=0,kk,ii=0;

    double *s0,*s1,*s2,*s3,*s4,*s5,*s6;
    double *tempt,*temp0,*temp1,*temp2,*temp3,*temp4,*temp5,*temp6;

    double ymax,tau,delta,h,hmax,hmin;
	
    double ydel[MC];
	
    double t1,t2,rho1,rho2,theta1,theta2,phi1,phi2,krho1,krho2,m1,m2,n1,n2,omega1,omega2;
    double rho_step,m_step;
    
    int flag;

    y0 = mxGetPr(Y0_IN);
    
/*
Create and Initialize Return Arguments
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

    y1 = mxCalloc(MC,sizeof(double));
    s0 = mxCalloc(MC,sizeof(double));
    s1 = mxCalloc(MC,sizeof(double));
    s2 = mxCalloc(MC,sizeof(double));
    s3 = mxCalloc(MC,sizeof(double));
    s4 = mxCalloc(MC,sizeof(double));
    s5 = mxCalloc(MC,sizeof(double));
    s6 = mxCalloc(MC,sizeof(double));

/*
Initialization
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
The main loop
*/
    
   while ((t1 < rayparam.tfinal[0]) && (k < rayparam.kmax[0]-1)) {
        ii++; 
/*        mexPrintf("ii:%d\n",ii);*/
	if ((t1 + h) > rayparam.tfinal[0]) {
	    h = rayparam.tfinal[0] - t1;
	}
        if (ii > rayparam.kmax[0]) {
	    goto Endloop;
            flag = 0;
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
        
        ray(s1,y1,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,0);	        
		/* s2 = feval(F, t+h*alpha(1), y1+h*s1*beta(1,1), param); */

	for  (m = 0; m < MC-3; m++) {/* only the first five coordinates are evolving (rho,theta,phi,krho,m) */
	    y1[m] = s0[m]+h*s1[m]*beta[0][0];
	}
         
            
        ray(s2,y1,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,0);
		/* s3 = feval(F, t+h*alpha(2), y1+h*[s1*beta(2,1)+s2*beta(2,2)], param); */

	for  (m = 0; m < MC-3; m++) {
	    y1[m] = s0[m]+h*(s1[m]*beta[0][1] + s2[m]*beta[1][1]);
	}

	ray(s3,y1,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,0);

		/* s4 = feval(F, t+h*alpha(3), y1+h*[s1*beta(3,1)+s2*beta(3,2)+...], param); */

	for  (m = 0; m < MC-3; m++) {
	    y1[m] = s0[m]+h*(s1[m]*beta[0][2] + s2[m]*beta[1][2] + s3[m]*beta[2][2]);
	}
 
        ray(s4,y1,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,0);

        /* s5 = feval(F, t+h*alpha(4), y1+h*[s1*beta(4,1)+s2*beta(4,2)+...], param); */

	for  (m = 0; m < MC-3; m++) {
	    y1[m] = s0[m]+h*(s1[m]*beta[0][3] + s2[m]*beta[1][3] + s3[m]*beta[2][3] + s4[m]*beta[3][3]);
	}


        ray(s5,y1,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,0);

        /* s6 = feval(F, t+h*alpha(5), y1+h*[s1*beta(5,1)+s2*beta(5,2)+...], param); */

	for  (m = 0; m < MC-3; m++) {
	    y1[m] = s0[m]+h*(s1[m]*beta[0][4] + s2[m]*beta[1][4] + s3[m]*beta[2][4] + s4[m]*beta[3][4] + s5[m]*beta[4][4]);
	}
        
	ray(s6,y1,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,0);

/*
Estimate the error and the acceptable error
*/

	for  (m = 0; m < MC-3; m++) {
	    ydel[m] = h*(s1[m]*gama[0][1] + s2[m]*gama[1][1] + s3[m]*gama[2][1] + s4[m]*gama[3][1] + s5[m]*gama[4][1] + s6[m]*gama[5][1]);
	}

	delta = inf_norm(ydel,MC-3);/* only the first five coordinates are evolving (rho,theta,phi,krho,m) */
	ymax = inf_norm(s0,MC-3);/* only the first five coordinates are evolving (rho,theta,phi,krho,m) */
	tau = rayparam.tol[0]*fmax(ymax,1.0);

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
            

/*           mexPrintf("t1,rho2,theta2,phi2,krho2,m2:%g,%g,%g,%g,%g,%g\n",t1,rho2,theta2,phi2,krho2,m2); */
               
            if (rho2 < rayparam.drho[0]) {/* Boundary condition at rho = 0  */     
                rho2 = rho1;
		theta2 = theta1 + PI;
                phi2 = phi1;
		krho2 = -krho1;
                m2 = m1;
                rho_step = rho2;
                m_step = m2;
            }
            
           
            if (rho2 > 1.0) {/* Wave reflexion at rho = 1  */ 
                if (rayparam.reflection[0] >=1.0) {/* The reflection is always enforced */
                    mexPrintf("********************************** Wave reflection is enforced at rho = %g**********************************\n",rho1);
                    rho2 = rho1;
                    phi2 = phi1;
                    theta2 = theta1;
                    reflection(rayparam,equilparam,&krho2,rho1,theta1,krho1,m1,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit);
                    m2 = m1;
                } else {/* The code calculates if the reflection must takes place. It calculates kpsi for vacuum (keeping the magnetic field) ray leaves the plasma only if kspi is real.*/
                    s0[0] = rho1;
                    s0[1] = theta1;
                    s0[2] = phi1;
                    s0[3] = krho1;
                    s0[4] = m1;
                    s0[5] = n1;
                    s0[6] = omega1;  		    
                    dsolve(0,&krho2,s0,rayparam,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit); 
/*                    mexPrintf("test2a,krho2,cimag(krho2):%g,%g,%g\n",krho2,cimag(krho2));*/	    
                    if (cimag(krho2) == 0.0) {/* ray may propagate in vacuum. Propagation is stopped */
                        mexPrintf("********************************** The wave leaves the plasma at rho = %g**********************************\n",rho1);
                        flag = 1;
                        goto Endloop;  
                    } else {/* ray may not propagate in vacuum. Wave reflection is performed at plasma edge */
                        mexPrintf("********************************** Wave reflection takes place at rho = %g**********************************\n",rho1);
                        rho2 = rho1;
                        phi2 = phi1;
                        theta2 = theta1;
                        reflection(rayparam,equilparam,&krho2,rho1,theta1,krho1,m1,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit);
                        m2 = m1;  
                    }
                }
            }
            

            if (fabs(rho2 - rho_step) >= rayparam.drho[0]) {/*step stored in Matlab memory */
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
Update the step size
*/
        
        if (delta) {
            if (delta < tau) {
                h = SAFETY*h*pow(tau/delta,PGROW);   
            } else {
                h = SAFETY*h*pow(tau/delta,PSHRINK);                
            }
        } else {       
           mexPrintf("WARNING delta :%g, the loop is stopped.\n",delta);
           if (flag == 0) {
               mexPrintf("---> The maximum number of iteration is reached.\n",delta);
           }
           if (flag == 1) {
               mexPrintf("---> The ray leaves the plasma.\n",delta);
           }
           goto Endloop;
        }
        
    }

    if (t1 < rayparam.tfinal[0]) {
        mexPrintf("Singularity likely at t = %f or matrix full\n",t1);
    }
    
Endloop:

    
/* Create final matrix for transferring data to MatLab */
	
    T_OUT = mxCreateDoubleMatrix(K,1,mxREAL);
    Y_OUT = mxCreateDoubleMatrix(K,MC,mxREAL);
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

   mxFree(y1);
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
    data.reflection = mxGetData(mxGetField(structure_name, 0, "reflection")); 
    
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


void ppval_1D(pp_1D_format in,double drho_lim,double x,double y[],double dydY[])
{
    register int j,k;
    int i0,i1,i2,i3;
 
    if (x>1.0) {x = 1.0 - drho_lim/2.0;}/*Avoid points outside the separatrix */
    
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
                    dydY[k-1] = in.coefs_dfdrho[i0]*(x - in.breaks_dfdrho[j]) + in.coefs_dfdrho[i1];
                } else if ((int)in.order_dfdrho[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dfdrho[0] + 0*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    i1 = k-1+j*(int)in.dim_dfdrho[0] + 1*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    i2 = k-1+j*(int)in.dim_dfdrho[0] + 2*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];                    
                    dydY[k-1] = in.coefs_dfdrho[i0]*pow((x - in.breaks_dfdrho[j]),2) + in.coefs_dfdrho[i1]*(x - in.breaks_dfdrho[j]) + in.coefs_dfdrho[i2];
/*                    mexPrintf("k,dydY: %d%g\n",k,dydY[k-1]);  */
                } else if ((int)in.order_dfdrho[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dfdrho[0] + 0*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    i1 = k-1+j*(int)in.dim_dfdrho[0] + 1*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    i2 = k-1+j*(int)in.dim_dfdrho[0] + 2*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    i3 = k-1+j*(int)in.dim_dfdrho[0] + 3*(int)in.pieces_dfdrho[0]*(int)in.dim_dfdrho[0];
                    dydY[k-1] = in.coefs_dfdrho[i0]*pow((x - in.breaks_dfdrho[j]),3) + in.coefs_dfdrho[i1]*pow((x - in.breaks_dfdrho[j]),2) + in.coefs_dfdrho[i2]*(x - in.breaks_dfdrho[j]) + in.coefs_dfdrho[i3];
                }
            }
        }
    }   
}




void ppval_2D(pp_2D_format in,double drho_lim, double x, double t, double* y, double* dydY, double* dydt, double* d2ydt2, double* d2ydtdY)
{
    register int j,k;
    int i0,i1,i2,i3;
    double *a0,*an,*bn,*da0dY,*dandY,*dbndY;
    
    if (x>1.0) {x = 1.0 - drho_lim/2.0;}/* Avoid points outside the separatrix */

    a0 = mxCalloc((int)in.dim_a0[0],sizeof(double));
    da0dY = mxCalloc((int)in.dim_da0drho[0],sizeof(double));
    an = mxCalloc((int)in.dim_an[0],sizeof(double));
    dandY = mxCalloc((int)in.dim_dandrho[0],sizeof(double));
    bn = mxCalloc((int)in.dim_bn[0],sizeof(double));
    dbndY = mxCalloc((int)in.dim_dbndrho[0],sizeof(double));

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
                    da0dY[k-1] = in.coefs_da0drho[i0]*(x - in.breaks_da0drho[j]) + in.coefs_da0drho[i1];
                } else if ((int)in.order_da0drho[0] == 3) {
                    i0 = k-1+j*(int)in.dim_da0drho[0] + 0*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    i1 = k-1+j*(int)in.dim_da0drho[0] + 1*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    i2 = k-1+j*(int)in.dim_da0drho[0] + 2*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];                    
                    da0dY[k-1] = in.coefs_da0drho[i0]*pow((x - in.breaks_da0drho[j]),2) + in.coefs_da0drho[i1]*(x - in.breaks_da0drho[j]) + in.coefs_da0drho[i2];
                } else if ((int)in.order_da0drho[0] == 4) {
                    i0 = k-1+j*(int)in.dim_da0drho[0] + 0*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    i1 = k-1+j*(int)in.dim_da0drho[0] + 1*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    i2 = k-1+j*(int)in.dim_da0drho[0] + 2*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    i3 = k-1+j*(int)in.dim_da0drho[0] + 3*(int)in.pieces_da0drho[0]*(int)in.dim_da0drho[0];
                    da0dY[k-1] = in.coefs_da0drho[i0]*pow((x - in.breaks_da0drho[j]),3) + in.coefs_da0drho[i1]*pow((x - in.breaks_da0drho[j]),2) + in.coefs_da0drho[i2]*(x - in.breaks_da0drho[j]) + in.coefs_da0drho[i3];
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
                    dandY[k-1] = in.coefs_dandrho[i0]*(x - in.breaks_dandrho[j]) + in.coefs_dandrho[i1];
                } else if ((int)in.order_dandrho[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dandrho[0] + 0*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    i1 = k-1+j*(int)in.dim_dandrho[0] + 1*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    i2 = k-1+j*(int)in.dim_dandrho[0] + 2*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];                    
                    dandY[k-1] = in.coefs_dandrho[i0]*pow((x - in.breaks_dandrho[j]),2) + in.coefs_dandrho[i1]*(x - in.breaks_dandrho[j]) + in.coefs_dandrho[i2];
                } else if ((int)in.order_dandrho[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dandrho[0] + 0*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    i1 = k-1+j*(int)in.dim_dandrho[0] + 1*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    i2 = k-1+j*(int)in.dim_dandrho[0] + 2*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    i3 = k-1+j*(int)in.dim_dandrho[0] + 3*(int)in.pieces_dandrho[0]*(int)in.dim_dandrho[0];
                    dandY[k-1] = in.coefs_dandrho[i0]*pow((x - in.breaks_dandrho[j]),3) + in.coefs_dandrho[i1]*pow((x - in.breaks_dandrho[j]),2) + in.coefs_dandrho[i2]*(x - in.breaks_dandrho[j]) + in.coefs_dandrho[i3];
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
                    dbndY[k-1] = in.coefs_dbndrho[i0]*(x - in.breaks_dbndrho[j]) + in.coefs_dbndrho[i1];
                } else if ((int)in.order_dbndrho[0] == 3) {
                    i0 = k-1+j*(int)in.dim_dbndrho[0] + 0*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    i1 = k-1+j*(int)in.dim_dbndrho[0] + 1*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    i2 = k-1+j*(int)in.dim_dbndrho[0] + 2*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];                    
                    dbndY[k-1] = in.coefs_dbndrho[i0]*pow((x - in.breaks_dbndrho[j]),2) + in.coefs_dbndrho[i1]*(x - in.breaks_dbndrho[j]) + in.coefs_dbndrho[i2];
                } else if ((int)in.order_dbndrho[0] == 4) {
                    i0 = k-1+j*(int)in.dim_dbndrho[0] + 0*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    i1 = k-1+j*(int)in.dim_dbndrho[0] + 1*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    i2 = k-1+j*(int)in.dim_dbndrho[0] + 2*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    i3 = k-1+j*(int)in.dim_dbndrho[0] + 3*(int)in.pieces_dbndrho[0]*(int)in.dim_dbndrho[0];
                    dbndY[k-1] = in.coefs_dbndrho[i0]*pow((x - in.breaks_dbndrho[j]),3) + in.coefs_dbndrho[i1]*pow((x - in.breaks_dbndrho[j]),2) + in.coefs_dbndrho[i2]*(x - in.breaks_dbndrho[j]) + in.coefs_dbndrho[i3];
                }
            }
        }
    }   
    
    y[0] = 0.0;
    dydY[0] = 0.0;
    dydt[0] = 0.0;
    d2ydt2[0] = 0.0;
    d2ydtdY[0] = 0.0;
    
    for (k = 1;k <= (int)in.dim_dbndrho[0]; k++) {
      y[0] = y[0] + an[k-1]*cos(k*t) + bn[k-1]*sin(k*t);
      dydY[0] = dydY[0] + dandY[k-1]*cos(k*t) + dbndY[k-1]*sin(k*t);
      dydt[0] = dydt[0] - k*an[k-1]*sin(k*t) + k*bn[k-1]*cos(k*t);
      d2ydt2[0] = d2ydt2[0] - k*k*an[k-1]*cos(k*t) - k*k*bn[k-1]*sin(k*t);
      d2ydtdY[0] = d2ydtdY[0] - k*dandY[k-1]*sin(k*t) + k*dbndY[k-1]*cos(k*t);
    }
    
    y[0] = y[0] + a0[0];
    dydY[0] = dydY[0] + da0dY[0];
    
    mxFree(a0);
    mxFree(da0dY);
    mxFree(an);
    mxFree(dandY);
    mxFree(bn);
    mxFree(dbndY);

}

double inf_norm(y,N)
double	y[];
unsigned int N;
{
	register unsigned int m;
	double	temp_max;

	temp_max = fabs(y[0]);

	for (m = 1; m < N; m++) {
		temp_max = fmax(temp_max,fabs(y[m]));
	}

	return(temp_max);
}

/* General coordinate time evolution dY/dt with Y=[rho,theta,phi,krho,m,n,omega/c] */


void ray(Ydot,Y,param,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit,flag)
double Y[];
double Ydot[];
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
int flag;
{


double complex dDdY[43][MC],Dtot,dDtotdY[MC];

double Npar,dNpardY[MC];
double complex Nperp,dNperpdY[MC];
double complex N6,N2,dN2dY[MC],dN6m1;

double complex Nperp4,Nperp3,Nperp2,Nperp1;
double Npar4,Npar3,Npar2,Npar1;
double complex Xxx,Xxy,Xxz,Xyy,Xyz,Xzz;
double complex Xxx2,Xxy2,Xxz2,Xyy2,Xyz2,Xzz2;

double rn2,drn2dY[MC];

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
raymagnetic.sigmaIp = mxCalloc(1,sizeof(double));

raymagnetic.drndY = mxCalloc(MC,sizeof(double));
raymagnetic.dRndY = mxCalloc(MC,sizeof(double));
raymagnetic.dBPndY = mxCalloc(MC,sizeof(double));
raymagnetic.dBPHIndY = mxCalloc(MC,sizeof(double));
raymagnetic.dBdY = mxCalloc(MC,sizeof(double));
raymagnetic.dsalphadY = mxCalloc(MC,sizeof(double));
raymagnetic.dcalphadY = mxCalloc(MC,sizeof(double));
raymagnetic.dgradrhondY = mxCalloc(MC,sizeof(double));

for (i = 0;i < MC; i++) {/*initialisation */
    raymagnetic.drndY[i] = 0.0;
    raymagnetic.dRndY[i] = 0.0;
    raymagnetic.dsalphadY[i] = 0.0;
    raymagnetic.dcalphadY[i] = 0.0;
    raymagnetic.dgradrhondY[i] = 0.0;
    raymagnetic.dBPndY[i] = 0.0;
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
    drn2dY[i] = 0.0;
    
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

/* Equilibrium interpolation at ray location */
interpequil(param,raymagnetic,rayprofiles,equilparam,Y,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit);
/* interpequil_test(raymagnetic,rayprofiles,equilparam,Y);*/


/* Refractive index calculation */
rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardY,dNperpdY,dN2dY);
/* 
mexPrintf("rn,Rn,BPn,krho,sina,cosa,B,BPHIn:%g,%g,%g,%g,%g,%g,%g,%g\n",raymagnetic.rn[0],raymagnetic.Rn[0],raymagnetic.BPn[0],Y[3],raymagnetic.salpha[0],raymagnetic.calpha[0],raymagnetic.B[0],raymagnetic.BPHIn[0]);
mexPrintf("Npar,w*dNpardw,Nperpr,Nperpi,w*dNperpdwr,w*dNperpdwi:%g,%g,%g,%g,%g,%g\n",Npar,dNpardY[6],Nperp,dNperpdY[6]);
*/ 

/* Susceptibility tensor  */

susceptibility(X,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,Y[6]);

if (flag) {/* dipersion relation */
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

rn2 = raymagnetic.rn[0]*raymagnetic.rn[0];


for (i=0;i<MC;i++) {
    drn2dY[i] = 2.0*raymagnetic.drndY[i]*raymagnetic.rn[0];
}


for (i = 0;i<MC;i++) {
    
    dN6m1 = 3*dN2dY[i]/N6/N2;
    
    dDdY[0][i] = 4.0*rn2*Nperp3*dNperpdY[i]/N6 - rn2*Nperp4*dN6m1 + drn2dY[i]*Nperp4/N6;
    dDdY[1][i] = X.dXxxdY[i]*Nperp4/N6 + 4.0*Xxx*Nperp3*dNperpdY[i]/N6 - Xxx*Nperp4*dN6m1;
    dDdY[2][i] = 2.0*dNpardY[i]*Xxz*Nperp3/N6 + 2.0*Npar1*X.dXxzdY[i]*Npar3/N6 + 6.0*Npar1*Xxz*dNperpdY[i]*Nperp2/N6 - 2.0*Npar1*Xxz*Nperp3*dN6m1;    
    dDdY[3][i] = 2.0*Npar1*dNpardY[i]*Xxx*Nperp2/N6 + Npar2*X.dXxxdY[i]*Nperp2/N6 + 2.0*Npar2*Xxx*Nperp1*dNperpdY[i]/N6 - Npar2*Xxx*Nperp2*dN6m1;
    dDdY[4][i] = 2.0*Npar1*dNpardY[i]*Xzz*Nperp2/N6 + Npar2*X.dXzzdY[i]*Nperp2/N6 + 2.0*Npar2*Xzz*Nperp1*dNperpdY[i]/N6 - Npar2*Xzz*Nperp2*dN6m1;
    dDdY[5][i] = 4.0*rn2*Npar1*dNpardY[i]*Nperp2/N6 + 4.0*rn2*Npar2*Nperp1*dNperpdY[i]/N6 - 2.0*rn2*Npar2*Nperp2*dN6m1 + 2.0*drn2dY[i]*Npar2*Nperp2/N6;
    dDdY[6][i] = -2.0*rn2*X.dXxxdY[i]*Nperp2/N6 - 4.0*rn2*Xxx*Nperp1*dNperpdY[i]/N6 + 2.0*rn2*Xxx*Nperp2*dN6m1 - 2.0*drn2dY[i]*Xxx*Nperp2/N6;
    dDdY[7][i] = -rn2*X.dXyydY[i]*Nperp2/N6 - 2.0*rn2*Xyy*Nperp1*dNperpdY[i]/N6 + rn2*Xyy*Nperp2*dN6m1 - Xyy*drn2dY[i]*Nperp2/N6;
    dDdY[8][i] = -rn2*X.dXzzdY[i]*Nperp2/N6 - 2.0*rn2*Xzz*Nperp1*dNperpdY[i]/N6 + rn2*Xzz*Nperp2*dN6m1 - drn2dY[i]*Xzz*Nperp2/N6;
    dDdY[9][i] = -X.dXxxdY[i]*Xzz*Nperp2/N6 - Xxx*X.dXzzdY[i]*Nperp2/N6 - 2.0*Xxx*Xzz*Nperp1*dNperpdY[i]/N6 + Xxx*Xzz*Nperp2*dN6m1;
    dDdY[10][i] = 2.0*Xxz*X.dXxzdY[i]*Nperp2/N6 + 2.0*Xxz2*Nperp1*dNperpdY[i]/N6 - Xxz2*Nperp2*dN6m1;
    dDdY[11][i] = -X.dXxxdY[i]*Xyy*Nperp2/N6 - Xxx*X.dXyydY[i]*Nperp2/N6 - 2.0*Xxx*Xyy*Nperp1*dNperpdY[i]/N6 + Xxx*Xyy*Nperp2*dN6m1;
    dDdY[12][i] = -2.0*X.dXxydY[i]*Xxy*Nperp2/N6 - 2.0*Xxy2*Nperp1*dNperpdY[i]/N6 + Xxy2*Nperp2*dN6m1;
    dDdY[13][i] = -4.0*rn2*rn2*Nperp1*dNperpdY[i]/N6 + 2.0*rn2*rn2*Nperp2*dN6m1 - 4.0*rn2*drn2dY[i]*Nperp2/N6;
    dDdY[14][i] = -2.0*dNpardY[i]*Xyy*Xxz*Nperp1/N6 - 2.0*Npar1*X.dXyydY[i]*Xxz*Nperp1/N6 - 2.0*Npar1*Xyy*X.dXxzdY[i]*Nperp1/N6 - 2.0*Npar1*Xyy*Xxz*dNperpdY[i]/N6 + 2.0*Npar1*Xyy*Xxz*Nperp1*dN6m1;
    dDdY[15][i] = 2.0*dNpardY[i]*Xxy*Xyz*Nperp1/N6 + 2.0*Npar1*X.dXxydY[i]*Xyz*Nperp1/N6 + 2.0*Npar1*Xxy*X.dXyzdY[i]*Nperp1/N6 + 2.0*Npar1*Xxy*Xyz*dNperpdY[i]/N6 - 2.0*Npar1*Xxy*Xyz*Nperp1*dN6m1;
    dDdY[16][i] = -2.0*rn2*dNpardY[i]*Xxz*Nperp1/N6 - 2.0*rn2*Npar1*X.dXxzdY[i]*Nperp1/N6 - 2.0*rn2*Npar1*Xxz*dNperpdY[i]/N6 + 2.0*rn2*Npar1*Xxz*Nperp1*dN6m1 - 2.0*drn2dY[i]*Npar1*Xxz*Nperp1/N6;
    dDdY[17][i] = 6.0*Npar2*dNpardY[i]*Xxz*Nperp1/N6 + 2.0*Npar3*X.dXxzdY[i]*Nperp1/N6 + 2.0*Npar3*Xxz*dNperpdY[i]/N6 - 2.0*Npar3*Xxz*Nperp1*dN6m1;
    dDdY[18][i] = -rn2*rn2*rn2*dN6m1 + 3.0*drn2dY[i]*rn2*rn2/N6;
    dDdY[19][i] = 4.0*Npar3*Xzz*dNpardY[i]/N6 + Npar4*X.dXzzdY[i]/N6 - Npar4*Xzz*dN6m1;    
    dDdY[20][i] = 4.0*rn2*Npar3*dNpardY[i]/N6 - rn2*Npar4*dN6m1 + drn2dY[i]*Npar4/N6;
    dDdY[21][i] = 2.0*Npar1*dNpardY[i]*Xxz2/N6 + 2.0*Npar2*Xxz*X.dXxzdY[i]/N6 - Npar2*Xxz2*dN6m1;
    dDdY[22][i] = -2.0*Npar1*dNpardY[i]*Xyy*Xzz/N6 - Npar2*X.dXyydY[i]*Xzz/N6 - Npar2*Xyy*X.dXzzdY[i]/N6 + Npar2*Xyy*Xzz*dN6m1;
    dDdY[23][i] = -2.0*Npar1*dNpardY[i]*Xxx*Xzz/N6 - Npar2*X.dXxxdY[i]*Xzz/N6 - Npar2*Xxx*X.dXzzdY[i]/N6 + Npar2*Xxx*Xzz*dN6m1;
    dDdY[24][i] = -4.0*rn2*Npar1*dNpardY[i]*Xzz/N6 - 2.0*rn2*Npar2*X.dXzzdY[i]/N6 + 2.0*rn2*Npar2*Xzz*dN6m1 - 2.0*drn2dY[i]*Npar2*Xzz/N6;
    dDdY[25][i] = -2.0*rn2*Npar1*dNpardY[i]*Xyy/N6 - rn2*Npar2*X.dXyydY[i]/N6 + rn2*Npar2*Xyy*dN6m1 - drn2dY[i]*Npar2*Xyy/N6;
    dDdY[26][i] = -2.0*Npar1*dNpardY[i]*Xyz2/N6 - 2.0*Npar2*Xyz*X.dXyzdY[i]/N6 + Npar2*Xyz2*dN6m1;
    dDdY[27][i] = -2.0*rn2*Npar1*dNpardY[i]*Xxx/N6 - rn2*Npar2*X.dXxxdY[i]/N6 + rn2*Npar2*Xxx*dN6m1 - drn2dY[i]*Npar2*Xxx/N6;
    dDdY[28][i] = -4.0*rn2*rn2*Npar1*dNpardY[i]/N6 + 2.0*rn2*rn2*Npar2*dN6m1 - 4.0*drn2dY[i]*rn2*Npar2/N6;
    dDdY[29][i] = rn2*X.dXyydY[i]*Xzz/N6 + rn2*Xyy*X.dXzzdY[i]/N6 - rn2*Xyy*Xzz*dN6m1 + drn2dY[i]*Xyy*Xzz/N6;
    dDdY[30][i] = rn2*X.dXxxdY[i]*Xzz/N6 + rn2*Xxx*X.dXzzdY[i]/N6 - rn2*Xxx*Xzz*dN6m1 + drn2dY[i]*Xxx*Xzz/N6;
    dDdY[31][i] = rn2*X.dXxxdY[i]*Xyy/N6 + rn2*Xxx*X.dXyydY[i]/N6 - rn2*Xxx*Xyy*dN6m1 + drn2dY[i]*Xxx*Xyy/N6;
    dDdY[32][i] = X.dXxxdY[i]*Xyz2/N6 + 2.0*Xxx*Xyz*X.dXyzdY[i]/N6 - Xxx*Xyz2*dN6m1;
    dDdY[33][i] = 2.0*rn2*Xyz*X.dXyzdY[i]/N6 - rn2*Xyz2*dN6m1 + drn2dY[i]*Xyz2/N6;
    dDdY[34][i] = rn2*rn2*X.dXxxdY[i]/N6 - rn2*rn2*Xxx*dN6m1 + 2.0*drn2dY[i]*rn2*Xxx/N6;
    dDdY[35][i] = 2.0*rn2*Xxy*X.dXxydY[i]/N6 - rn2*Xxy2*dN6m1 + drn2dY[i]*Xxy2/N6;
    dDdY[36][i] = 2.0*Xxy*X.dXxydY[i]*Xzz/N6 + Xxy2*X.dXzzdY[i]/N6 - Xxy2*Xzz*dN6m1;    
    dDdY[37][i] = -2.0*rn2*Xxz*X.dXxzdY[i]/N6 + rn2*Xxz2*dN6m1 - drn2dY[i]*Xxz2/N6;
    dDdY[38][i] = -X.dXyydY[i]*Xxz2/N6 - 2.0*Xyy*Xxz*X.dXxzdY[i]/N6 + Xyy*Xxz2*dN6m1;
    dDdY[39][i] = rn2*rn2*X.dXyydY[i]/N6 - rn2*rn2*Xyy*dN6m1 + 2.0*drn2dY[i]*rn2*Xyy/N6;
    dDdY[40][i] = rn2*rn2*X.dXzzdY[i]/N6 - rn2*rn2*Xzz*dN6m1 + 2.0*drn2dY[i]*rn2*Xzz/N6;
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
    Ydot[0] = -creal(dN2dY[3] - drn2dY[3])/creal(dN2dY[6] - drn2dY[6]); 
    Ydot[1] = -creal(dN2dY[4] - drn2dY[4])/creal(dN2dY[6] - drn2dY[6]); 
    Ydot[2] = -creal(dN2dY[5] - drn2dY[5])/creal(dN2dY[6] - drn2dY[6]); 
    Ydot[3] = creal(dN2dY[0] - drn2dY[0])/creal(dN2dY[6] - drn2dY[6]); 
    Ydot[4] = creal(dN2dY[1] - drn2dY[1])/creal(dN2dY[6] - drn2dY[6]);
    Ydot[5] = 0.0; 
    Ydot[6] = 0.0; 
}


/* test for the cold dispersion relation */
/*
double complex P0,P2,P4,dP0dY[MC],dP2dY[MC],dP4dY[MC];
double complex Kpar,Kperp,Kxy,dKpardY[MC],dKperpdY[MC],dKxydY[MC];
double complex Dot_cold,dDtot_colddY[MC];
double Ydot_cold[MC];

Kpar = (rn2 + Xzz)/N2;
Kperp = (rn2 + Xxx)/N2;
Kxy = I*Xxy/N2;

P0 = Kpar*((Npar2/N2 - Kperp)*(Npar2/N2 - Kperp) - Kxy*Kxy);
P2 = (Npar2/N2 - Kperp)*(Kpar + Kperp) + Kxy*Kxy;
P4 = Kperp;

Dot_cold = P4*Nperp4/N2/N2 + P2*Nperp2/N2 + P0;
mexPrintf("Dtot_cold:%g,%g\n",Dot_cold);

for (i=0;i<MC;i++) {
    dKpardY[i] = drn2dY[i]/N2 + X.dXzzdY[i]/N2 - (rn2+Xzz)*dN2dY[i]/N2/N2;
    dKperpdY[i] = drn2dY[i]/N2 + X.dXxxdY[i]/N2 - (rn2+Xxx)*dN2dY[i]/N2/N2;
    dKxydY[i] = I*X.dXxydY[i]/N2 - I*Xxy*dN2dY[i]/N2/N2;  
    dP0dY[i] = dKpardY[i]*((Npar2/N2 - Kperp)*(Npar2/N2 - Kperp) - Kxy*Kxy) + Kpar*(2*(Npar2/N2 - Kperp)*(2*Npar1*dNpardY[i]/N2 - Npar2*dN2dY[i]/N2/N2 - dKperpdY[i]) - 2*Kxy*dKxydY[i]);  
    dP2dY[i] = (2*Npar1*dNpardY[i]/N2 - Npar2*dN2dY[i]/N2/N2 - dKperpdY[i])*(Kpar + Kperp) + (Npar2/N2 - Kperp)*(dKpardY[i] + dKperpdY[i]) + 2*Kxy*dKxydY[i];
    dP4dY[i] = dKperpdY[i];
    dDtot_colddY[i] = dP4dY[i]*Nperp4/N2/N2 + dP2dY[i]*Nperp2/N2 + dP0dY[i] + P4*(4*Nperp3*dNperpdY[i]/N2/N2 - 2*Nperp4*dN2dY[i]/N2/N2/N2) + P2*(2*Nperp*dNperpdY[i]/N2 - Nperp2*dN2dY[i]/N2/N2);
}

Ydot_cold[0] = -creal(dDtot_colddY[3])/creal(dDtot_colddY[6]); 
Ydot_cold[1] = -creal(dDtot_colddY[4])/creal(dDtot_colddY[6]); 
Ydot_cold[2] = -creal(dDtot_colddY[5])/creal(dDtot_colddY[6]); 
Ydot_cold[3] = creal(dDtot_colddY[0])/creal(dDtot_colddY[6]); 
Ydot_cold[4] = creal(dDtot_colddY[1])/creal(dDtot_colddY[6]);
Ydot_cold[5] = 0.0; 
Ydot_cold[6] = 0.0; 
*/


/* 
mexPrintf("dN2dY[1],drn2dY[1]:%g,%g\n",dN2dY[1],drn2dY[1]);
mexPrintf("dDtotdY:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",dDtotdY[0],dDtotdY[1],dDtotdY[2],dDtotdY[3],dDtotdY[4],dDtotdY[5],dDtotdY[6],dDtotdY[7]);
mexPrintf("dDtot_colddY:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",dDtot_colddY[0],dDtot_colddY[1],dDtot_colddY[2],dDtot_colddY[3],dDtot_colddY[4],dDtot_colddY[5],dDtot_colddY[6]);
mexPrintf("Ydot:%g,%g,%g,%g,%g,%g,%g,%g\n",Ydot[0],Ydot[1],Ydot[2],Ydot[3],Ydot[4],Ydot[5],Ydot[6],Ydot[7]);
mexPrintf("Ydot_cold:%g,%g,%g,%g,%g,%g,%g\n",Ydot_cold[0],Ydot_cold[1],Ydot_cold[2],Ydot_cold[3],Ydot_cold[4],Ydot_cold[5],Ydot_cold[6]);
*/

/* Memory is released  */
    
    mxFree(raymagnetic.rn);
    mxFree(raymagnetic.Rn);
    mxFree(raymagnetic.BPn);
    mxFree(raymagnetic.BPHIn);
    mxFree(raymagnetic.B);
    mxFree(raymagnetic.salpha);
    mxFree(raymagnetic.calpha);
    mxFree(raymagnetic.gradrhon);
    mxFree(raymagnetic.sigmaIp);
    
    mxFree(raymagnetic.drndY);
    mxFree(raymagnetic.dRndY);
    mxFree(raymagnetic.dBPndY);
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

    mxFree(X.dXxxdY);
    mxFree(X.dXxydY);
    mxFree(X.dXxzdY);
    mxFree(X.dXyydY);
    mxFree(X.dXyzdY);
    mxFree(X.dXzzdY);

}



void reflection(rayparam,equilparam,krho2,rho1,theta1,krho1,m1,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit)
rayparam_format rayparam;
equilparam_format equilparam;
double *krho2;
double rho1,theta1,krho1,m1;
pp_2D_format x_fit;
pp_2D_format y_fit;
pp_2D_format BPHI_fit;
pp_2D_format Bx_fit;
pp_2D_format By_fit;
pp_1D_format dxstardpsin_fit;
{
    raymagnetic_format raymagnetic;

    double x,R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho;
    double y,Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho;
    double BR,dBRdrho,dBRdtheta;
    double BZ,dBZdrho,dBZdtheta;
    double BPHI,dBPHIdrho,dBPHIdtheta;
    double dRstardpsin,ddRstardpsindrho;
    double dummy1,dummy2;
    
    double delta, krho2p,krho2m;

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
    raymagnetic.sigmaIp = mxCalloc(1,sizeof(double));

    raymagnetic.drndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dRndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBPndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBPHIndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBdY = mxCalloc(MC,sizeof(double));
    raymagnetic.dsalphadY = mxCalloc(MC,sizeof(double));
    raymagnetic.dcalphadY = mxCalloc(MC,sizeof(double));
    raymagnetic.dgradrhondY = mxCalloc(MC,sizeof(double));

    ppval_1D(dxstardpsin_fit,rayparam.drho[0],rho1,&dRstardpsin,&ddRstardpsindrho);
    ppval_2D(x_fit,rayparam.drho[0],rho1,theta1,&x,&dRdrho,&dRdtheta,&d2Rdtheta2,&d2Rdthetadrho);
    R = x + equilparam.Rp[0];
    ppval_2D(y_fit,rayparam.drho[0],rho1,theta1,&y,&dZdrho,&dZdtheta,&d2Zdtheta2,&d2Zdthetadrho);
    Z = y + equilparam.Zp[0];
    ppval_2D(Bx_fit,rayparam.drho[0],rho1,theta1,&BR,&dBRdrho,&dBRdtheta,&dummy1,&dummy2);
    ppval_2D(By_fit,rayparam.drho[0],rho1,theta1,&BZ,&dBZdrho,&dBZdtheta,&dummy1,&dummy2);
    ppval_2D(BPHI_fit,rayparam.drho[0],rho1,theta1,&BPHI,&dBPHIdrho,&dBPHIdtheta,&dummy1,&dummy2);  

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
        mexPrintf("WARNING: Problem for the wave reflection at the plasma edge !");
    }

/* Memory is released  */
    
    mxFree(raymagnetic.rn);
    mxFree(raymagnetic.Rn);
    mxFree(raymagnetic.BPn);
    mxFree(raymagnetic.BPHIn);
    mxFree(raymagnetic.B);
    mxFree(raymagnetic.salpha);
    mxFree(raymagnetic.calpha);
    mxFree(raymagnetic.gradrhon);
    mxFree(raymagnetic.sigmaIp);
    
    mxFree(raymagnetic.drndY);
    mxFree(raymagnetic.dRndY);
    mxFree(raymagnetic.dBPndY);
    mxFree(raymagnetic.dBPHIndY);
    mxFree(raymagnetic.dBdY);   
    mxFree(raymagnetic.dsalphadY);
    mxFree(raymagnetic.dcalphadY);
    mxFree(raymagnetic.dgradrhondY);
}


void dsolve(mode,krho,Y,param,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit)
int mode;
double *krho;
double Y[];
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
{
    double Npar,dNpardY[MC];
    double complex Nperp,dNperpdY[MC];
    double complex N2,dN2dY[MC];

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
    raymagnetic.sigmaIp = mxCalloc(1,sizeof(double));

    raymagnetic.drndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dRndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dsalphadY = mxCalloc(MC,sizeof(double));
    raymagnetic.dcalphadY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBPndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBPHIndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBdY = mxCalloc(MC,sizeof(double));
    raymagnetic.dgradrhondY = mxCalloc(MC,sizeof(double));

    for (i = 0;i < MC; i++) {/* initialisation */
        raymagnetic.drndY[i] = 0.0;
        raymagnetic.dRndY[i] = 0.0;
        raymagnetic.dsalphadY[i] = 0.0;
        raymagnetic.dcalphadY[i] = 0.0;
        raymagnetic.dgradrhondY[i] = 0.0;
        raymagnetic.dBPndY[i] = 0.0;
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
    }
    
    for (i=0;i<equilparam.ns[0];i++) {
        rayprofiles.zTi[i] = 0.0;
        rayprofiles.zni[i] = 0.0;             
        for (j = 0;j < MC; j++) {
           rayprofiles.dzTidY[i][j] = 0.0;
           rayprofiles.dznidY[i][j] = 0.0;
        }
    }

    X.Xxx = mxCalloc(1,sizeof(double complex));
    X.Xxy = mxCalloc(1,sizeof(double complex));
    X.Xxz = mxCalloc(1,sizeof(double complex));
    X.Xyy = mxCalloc(1,sizeof(double complex));
    X.Xyz = mxCalloc(1,sizeof(double complex));
    X.Xzz = mxCalloc(1,sizeof(double complex));

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

    /* Equilibrium interpolation at ray location */
    interpequil(param,raymagnetic,rayprofiles,equilparam,Y,Te_fit,ne_fit,zTi_fit,zni_fit,x_fit,y_fit,Bx_fit,By_fit,BPHI_fit,dxstardpsin_fit);
/*     interpequil_test(raymagnetic,rayprofiles,equilparam,Y);*/

    krho0 = Y[3];
    krho1 = frac*krho0;
    
    rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardY,dNperpdY,dN2dY);
    if (mode > 0) {/* plasma case */
        susceptibility(X,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,Y[6]);
    }
        
    disprel(&cD0,X,raymagnetic,Npar,Nperp);
    D0 = creal(cD0);/* to be changed if non-hermitian susceptibility tensors are used */
/*  mexPrintf("krho0,D0:%g,%g\n",krho0,D0); */
    
    Y[3] = krho1;
    rayindex(1,Y,raymagnetic,equilparam,&Npar,&Nperp,&N2,dNpardY,dNperpdY,dN2dY);
    if (mode > 0) {/* plasma case */
        susceptibility(X,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,Y[6]);
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
            susceptibility(X,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,Y[6]);
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
                susceptibility(X,param.tensortype[0],(int)param.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,Y[6]);
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

    /* Memory is released  */
    
    mxFree(raymagnetic.rn);
    mxFree(raymagnetic.Rn);
    mxFree(raymagnetic.salpha);
    mxFree(raymagnetic.calpha);
    mxFree(raymagnetic.BPn);
    mxFree(raymagnetic.BPHIn);
    mxFree(raymagnetic.B);
    mxFree(raymagnetic.gradrhon);
    mxFree(raymagnetic.sigmaIp);

    mxFree(raymagnetic.drndY);
    mxFree(raymagnetic.dRndY);
    mxFree(raymagnetic.dsalphadY);
    mxFree(raymagnetic.dcalphadY);
    mxFree(raymagnetic.dBPndY);
    mxFree(raymagnetic.dBPHIndY);
    mxFree(raymagnetic.dBdY);  
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

    mxFree(X.dXxxdY);
    mxFree(X.dXxydY);
    mxFree(X.dXxzdY);
    mxFree(X.dXyydY);
    mxFree(X.dXyzdY);
    mxFree(X.dXzzdY);
    
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

/*    mexPrintf("Dtot:%g\n",Dtot[0]);*/

}

void susceptibility(X,tensortype,ncyclharm,equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Nperp,dNperpdY,omega)
susceptibilitytensor_format X;
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

    double wcn[equilparam.ns[0]+1],wpn2[equilparam.ns[0]+1],betath[equilparam.ns[0]+1];
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

    double Npar1,dNpar1dY,dNpar1dY1,dNpar1dY2,dNpar1dY3,dNpar1dY4;
    double Npar2,dNpar2dY,dNpar2dY1,dNpar2dY2,dNpar2dY3,dNpar2dY4,dNpar2dY5;
      
    double complex N21,dN21dY,dN21dY1,dN21dY2,dN21dY3,dN21dY4;
    double complex N22,dN22dY,dN22dY1,dN22dY2,dN22dY3,dN22dY4,dN22dY5,dN22dY6;
    double complex N23,dN23dY,dN23dY1,dN23dY2;
    double complex N24,dN24dY,dN24dY1,dN24dY2,dN24dY3,dN24dY4;
    
    double ap,cnorm;
    double clum = 299792458;/*Speed of light (m/s) */

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
        
        Npar1 = Y[4]*raymagnetic.calpha[0]*raymagnetic.sigmaIp[0]*raymagnetic.BPn[0];
        Npar2 = raymagnetic.rn[0]*Y[5]*raymagnetic.BPHIn[0]/raymagnetic.Rn[0];
  
        Npar[0] = cnorm*(Npar1 + Npar2);
        
/*
          mexPrintf("Nparth:%g\n",Npar[0]/raymagnetic.rn[0]);
          mexPrintf("Y[0],Y[1],Y[2],Y[3],Y[4],Y[5]:%g,%g,%g,%g,%g,%g\n",Y[0],Y[1],Y[2],Y[3],Y[4],Y[5]);
          mexPrintf("Y[4],raymagnetic.calpha[0],raymagnetic.sigmaIp[0],raymagnetic.BPn[0],raymagnetic.rn[0],Y[5],raymagnetic.BPHIn[0],raymagnetic.Rn[0]:%g,%g,%g,%g,%g,%g,%g,%g\n",Y[4],raymagnetic.calpha[0],raymagnetic.sigmaIp[0],raymagnetic.BPn[0],raymagnetic.rn[0],Y[5],raymagnetic.BPHIn[0],raymagnetic.Rn[0]);
*/
	
        for (i=0;i<MC;i++) {
    
            dNpar1dY1 = dYdY[4][i]*raymagnetic.calpha[0]*raymagnetic.sigmaIp[0]*raymagnetic.BPn[0];
            dNpar1dY2 = Y[4]*raymagnetic.dcalphadY[i]*raymagnetic.sigmaIp[0]*raymagnetic.BPn[0];
            dNpar1dY3 = Y[4]*raymagnetic.calpha[0]*raymagnetic.sigmaIp[0]*raymagnetic.dBPndY[i];
            dNpar1dY4 = -Y[4]*raymagnetic.calpha[0]*raymagnetic.sigmaIp[0]*raymagnetic.BPn[0]*dYdY[6][i];
        
            dNpar1dY = dNpar1dY1 + dNpar1dY2 + dNpar1dY3 + dNpar1dY4;
 
            dNpar2dY1 = raymagnetic.rn[0]*dYdY[5][i]*raymagnetic.BPHIn[0]/raymagnetic.Rn[0];
            dNpar2dY2 = raymagnetic.drndY[i]*Y[5]*raymagnetic.BPHIn[0]/raymagnetic.Rn[0];
            dNpar2dY3 = raymagnetic.rn[0]*Y[5]*raymagnetic.dBPHIndY[i]/raymagnetic.Rn[0];
            dNpar2dY4 = -raymagnetic.rn[0]*Y[5]*raymagnetic.BPHIn[0]*raymagnetic.dRndY[i]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dNpar2dY5 = -raymagnetic.rn[0]*Y[5]*raymagnetic.BPHIn[0]*dYdY[6][i]/raymagnetic.Rn[0];
    
            dNpar2dY = dNpar2dY1 + dNpar2dY2 + dNpar2dY3 + dNpar2dY4 + dNpar2dY5;
        
            dNpardY[i] = cnorm*(dNpar1dY + dNpar2dY);
             
          /*   mexPrintf("i,dNpardY[i]:%d,%g\n",i,dNpardY[i]); */
          /*  mexPrintf("i,dYdY[3][i],dYdY[4][i],dYdY[5][i]:%d,%g,%g,%g\n",i,dYdY[3][i],dYdY[4][i],dYdY[4][i]); */
        }
    
        N21 = raymagnetic.rn[0]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.gradrhon[0]*Y[3]*Y[3];
        N22 = -2.0*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*Y[3];
        N23 = Y[4]*Y[4];
        N24 = Y[5]*Y[5]*raymagnetic.rn[0]*raymagnetic.rn[0]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
    
        N2[0] = cnorm*cnorm*(N21 + N22 + N23 + N24);
        Nperp[0] = sqrt(N2[0] - Npar[0]*Npar[0]);
        
/*        mexPrintf("Npar,Nperp,N2:%g,%g,%g,%g,%g\n",Npar[0]/raymagnetic.rn[0],Nperp[0]/raymagnetic.rn[0],N2[0]/raymagnetic.rn[0]/raymagnetic.rn[0]); */
	    
        for (i=0;i<MC;i++) {
        
            dN21dY1 = 2.0*raymagnetic.rn[0]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.dgradrhondY[i]*Y[3]*Y[3];
            dN21dY2 = 2.0*raymagnetic.rn[0]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.gradrhon[0]*dYdY[3][i]*Y[3];
            dN21dY3 = 2.0*raymagnetic.drndY[i]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.gradrhon[0]*Y[3]*Y[3];
            dN21dY4 = -2.0*raymagnetic.rn[0]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.gradrhon[0]*Y[3]*Y[3]*dYdY[6][i];
        
            dN21dY = dN21dY1 + dN21dY2 + dN21dY3 + dN21dY4;
        
            dN22dY1 = -2.0*raymagnetic.rn[0]*raymagnetic.dgradrhondY[i]*raymagnetic.salpha[0]*Y[4]*Y[3];
            dN22dY2 = -2.0*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.dsalphadY[i]*Y[4]*Y[3];
            dN22dY3 = -2.0*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*dYdY[4][i]*Y[3];
            dN22dY4 = -2.0*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*dYdY[3][i];
            dN22dY5 = -2.0*raymagnetic.drndY[i]*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*Y[3];
            dN22dY6 = 4.0*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*raymagnetic.salpha[0]*Y[4]*Y[3]*dYdY[6][i];
        
            dN22dY = dN22dY1 + dN22dY2 + dN22dY3 + dN22dY4 + dN22dY5 + dN22dY6;
     
            dN23dY1 = 2.0*dYdY[4][i]*Y[4];
            dN23dY2 = -2.0*Y[4]*Y[4]*dYdY[6][i];
        
            dN23dY = dN23dY1 + dN23dY2;
    
            dN24dY1 = 2.0*dYdY[5][i]*Y[5]*raymagnetic.rn[0]*raymagnetic.rn[0]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dN24dY2 = -2.0*Y[5]*Y[5]*raymagnetic.rn[0]*raymagnetic.rn[0]*raymagnetic.dRndY[i]/raymagnetic.Rn[0]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dN24dY4 = 2.0*Y[5]*Y[5]*raymagnetic.drndY[i]*raymagnetic.rn[0]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dN24dY3 = -2.0*Y[5]*Y[5]*raymagnetic.rn[0]*raymagnetic.rn[0]/raymagnetic.Rn[0]/raymagnetic.Rn[0]*dYdY[6][i];
        
            dN24dY = dN24dY1 + dN24dY2 + dN24dY3 + dN24dY4;
        
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

void coldtensor(X,ns,ncyclharm,raymagnetic,Npar,dNpardY,Nperp,dNperpdY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY)
susceptibilitytensor_format X;
int ns;
int ncyclharm;
raymagnetic_format raymagnetic;
double wcn[],wpn2[],betath[];
double dwcndY[][MC],dwpn2dY[][MC],dbetathdY[][MC];
double Npar,dNpardY[];
double complex Nperp,dNperpdY[];
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
     
    buildXstruc(X,ns,raymagnetic,dNpardY,dNperpdY,dwcndY,dwpn2dY,dbetathdY,Xxx,Xxy,Xxz,Xyy,Xyz,Xzz,dXxxdNperp,dXxydNperp,dXxzdNperp,dXyydNperp,dXyzdNperp,dXzzdNperp,dXxxdNpar,dXxydNpar,dXxzdNpar,dXyydNpar,dXyzdNpar,dXzzdNpar,dXxxdbetath,dXxydbetath,dXxzdbetath,dXyydbetath,dXyzdbetath,dXzzdbetath,dXxxdwcn,dXxydwcn,dXxzdwcn,dXyydwcn,dXyzdwcn,dXzzdwcn,dXxxdwpn2,dXxydwpn2,dXxzdwpn2,dXyydwpn2,dXyzdwpn2,dXzzdwpn2);
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

    for (i = 0;i < MC;i++) {
         X.dXxxdY[i] = 0.0;
         X.dXxydY[i] = 0.0;
         X.dXxzdY[i] = 0.0;
         X.dXyydY[i] = 0.0;
         X.dXyzdY[i] = 0.0;
         X.dXzzdY[i] = 0.0;
    }
} 

void buildXstruc(X,ns,raymagnetic,dNpardY,dNperpdY,dwcndY,dwpn2dY,dbetathdY,Xxx,Xxy,Xxz,Xyy,Xyz,Xzz,dXxxdNperp,dXxydNperp,dXxzdNperp,dXyydNperp,dXyzdNperp,dXzzdNperp,dXxxdNpar,dXxydNpar,dXxzdNpar,dXyydNpar,dXyzdNpar,dXzzdNpar,dXxxdbetath,dXxydbetath,dXxzdbetath,dXyydbetath,dXyzdbetath,dXzzdbetath,dXxxdwcn,dXxydwcn,dXxzdwcn,dXyydwcn,dXyzdwcn,dXzzdwcn,dXxxdwpn2,dXxydwpn2,dXxzdwpn2,dXyydwpn2,dXyzdwpn2,dXzzdwpn2)
susceptibilitytensor_format X;
int ns;
raymagnetic_format raymagnetic;
double dwcndY[][MC],dwpn2dY[][MC],dbetathdY[][MC],dNpardY[];
double complex dNperpdY[];
double complex Xxx[],Xxy[],Xxz[],Xyy[],Xyz[],Xzz[];
double complex dXxxdNperp[],dXxydNperp[],dXxzdNperp[],dXyydNperp[],dXyzdNperp[],dXzzdNperp[];
double complex dXxxdNpar[],dXxydNpar[],dXxzdNpar[],dXyydNpar[],dXyzdNpar[],dXzzdNpar[];
double complex dXxxdbetath[],dXxydbetath[],dXxzdbetath[],dXyydbetath[],dXyzdbetath[],dXzzdbetath[];
double complex dXxxdwcn[],dXxydwcn[],dXxzdwcn[],dXyydwcn[],dXyzdwcn[],dXzzdwcn[];
double complex dXxxdwpn2[],dXxydwpn2[],dXxzdwpn2[],dXyydwpn2[],dXyzdwpn2[],dXzzdwpn2[];
{
    double complex dXxxdrn2[ns+1],dXxydrn2[ns+1],dXxzdrn2[ns+1],dXyydrn2[ns+1],dXyzdrn2[ns+1],dXzzdrn2[ns+1];
    double rn2,drn2dY[MC];
    
    int i,is;

    rn2 = raymagnetic.rn[0]*raymagnetic.rn[0];
    for (i = 0;i < MC; i++) {
        drn2dY[i] = 2.0*raymagnetic.drndY[i]*raymagnetic.rn[0];
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
            X.dXxxdY[i] = X.dXxxdY[i] + dXxxdrn2[is]*drn2dY[i] + rn2*dXxxdNperp[is]*dNperpdY[i] + rn2*dXxxdNpar[is]*dNpardY[i] + rn2*dXxxdbetath[is]*dbetathdY[is][i] + rn2*dXxxdwcn[is]*dwcndY[is][i] + rn2*dXxxdwpn2[is]*dwpn2dY[is][i];
            X.dXxydY[i] = X.dXxydY[i] + dXxydrn2[is]*drn2dY[i] + rn2*dXxydNperp[is]*dNperpdY[i] + rn2*dXxydNpar[is]*dNpardY[i] + rn2*dXxydbetath[is]*dbetathdY[is][i] + rn2*dXxydwcn[is]*dwcndY[is][i] + rn2*dXxydwpn2[is]*dwpn2dY[is][i];
            X.dXxzdY[i] = X.dXxzdY[i] + dXxzdrn2[is]*drn2dY[i] + rn2*dXxzdNperp[is]*dNperpdY[i] + rn2*dXxzdNpar[is]*dNpardY[i] + rn2*dXxzdbetath[is]*dbetathdY[is][i] + rn2*dXxzdwcn[is]*dwcndY[is][i] + rn2*dXxzdwpn2[is]*dwpn2dY[is][i];
            X.dXyydY[i] = X.dXyydY[i] + dXyydrn2[is]*drn2dY[i] + rn2*dXyydNperp[is]*dNperpdY[i] + rn2*dXyydNpar[is]*dNpardY[i] + rn2*dXyydbetath[is]*dbetathdY[is][i] + rn2*dXyydwcn[is]*dwcndY[is][i] + rn2*dXyydwpn2[is]*dwpn2dY[is][i];
            X.dXyzdY[i] = X.dXyzdY[i] + dXyzdrn2[is]*drn2dY[i] + rn2*dXyzdNperp[is]*dNperpdY[i] + rn2*dXyzdNpar[is]*dNpardY[i] + rn2*dXyzdbetath[is]*dbetathdY[is][i] + rn2*dXyzdwcn[is]*dwcndY[is][i] + rn2*dXyzdwpn2[is]*dwpn2dY[is][i];
            X.dXzzdY[i] = X.dXzzdY[i] + dXzzdrn2[is]*drn2dY[i] + rn2*dXzzdNperp[is]*dNperpdY[i] + rn2*dXzzdNpar[is]*dNpardY[i] + rn2*dXzzdbetath[is]*dbetathdY[is][i] + rn2*dXzzdwcn[is]*dwcndY[is][i] + rn2*dXzzdwpn2[is]*dwpn2dY[is][i];      
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
    
    ppval_1D(dxstardpsin_fit,rayparam.drho[0],Y[0],&dRstardpsin,&ddRstardpsindrho);
    
    if (equilparam.zZi[0] > 0) {
        ppval_1D(Te_fit,rayparam.drho[0],Y[0],&rayprofiles.Te[0],&rayprofiles.dTedY[0]);
        ppval_1D(ne_fit,rayparam.drho[0],Y[0],&rayprofiles.ne[0],&rayprofiles.dnedY[0]);
        ppval_1D(zTi_fit,rayparam.drho[0],Y[0],rayprofiles.zTi,dummyTi);
        for (is=0;is<equilparam.ns[0];is++) {
            rayprofiles.dzTidY[is][0] = dummyTi[is];
        }
    
        ppval_1D(zni_fit,rayparam.drho[0],Y[0],rayprofiles.zni,dummyni);
            for (is=0;is<equilparam.ns[0];is++) {
            if (rayprofiles.zni > 0) {
                 rayprofiles.dznidY[is][0] = dummyni[is];
            }
        }
        
   
 /*   for (i=0;i<equilparam.ns[0];i++) {
        mexPrintf("i,Ti,dzTidY[0],dzTidY[1],dzTidY[2],dzTidY[3],dzTidY[4],dzTidY[5],dzTidY[6]:%d,%g,%g,%g,%g,%g,%g,%g,%g\n",i,rayprofiles.zTi[i],rayprofiles.dzTidY[i][0],rayprofiles.dzTidY[i][1],rayprofiles.dzTidY[i][2],rayprofiles.dzTidY[i][3],rayprofiles.dzTidY[i][4],rayprofiles.dzTidY[i][5],rayprofiles.dzTidY[i][6]);
        mexPrintf("i,ni,dznidY[0],dznidY[1],dznidY[2],dznidY[3],dznidY[4],dznidY[5],dznidY[6]:%d,%g,%g,%g,%g,%g,%g,%g,%g\n",i,rayprofiles.zni[i],rayprofiles.dznidY[i][0],rayprofiles.dznidY[i][1],rayprofiles.dznidY[i][2],rayprofiles.dznidY[i][3],rayprofiles.dznidY[i][4],rayprofiles.dznidY[i][5],rayprofiles.dznidY[i][6]);

    }*/    
        
    }

 
    ppval_2D(x_fit,rayparam.drho[0],Y[0],Y[1],&x,&dRdrho,&dRdtheta,&d2Rdtheta2,&d2Rdthetadrho);
    R = x + equilparam.Rp[0];
    ppval_2D(y_fit,rayparam.drho[0],Y[0],Y[1],&y,&dZdrho,&dZdtheta,&d2Zdtheta2,&d2Zdthetadrho);
    Z = y + equilparam.Zp[0];
    ppval_2D(Bx_fit,rayparam.drho[0],Y[0],Y[1],&BR,&dBRdrho,&dBRdtheta,&dummy1,&dummy2);
    ppval_2D(By_fit,rayparam.drho[0],Y[0],Y[1],&BZ,&dBZdrho,&dBZdtheta,&dummy1,&dummy2);
    ppval_2D(BPHI_fit,rayparam.drho[0],Y[0],Y[1],&BPHI,&dBPHIdrho,&dBPHIdtheta,&dummy1,&dummy2);
    
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
    double sn;

    
/*    WARNING: the definitions used in the DKE code, and here crucial for HXR calculations are the following
          1) the toroidal frame (R,Z,phi) is direct (phi is positive clockwise when the tokamak is seen from the top)
          2) the poloidal frame (r,theta,phi) is direct
          3) (psi,s,phi) must be direct : if Ip.phi > 0, then B.theta > 0 and psi > 0, and s.theta > 0 (s as the same direction of theta)
          4) the sign of psi is the sign of Ip.phi
  With the definitions above, if Ip is positive, psi is turned outward, Btheta is counterclockwise poloidally, and s too. The Ampere theorem is OK !
  This definition is used either for DKE and HXR calculations
 */   
    
    raymagnetic.sigmaIp[0] =  sgn(-BR*sin(theta) + BZ*cos(theta));/* Sign of the plasma current (only valid for tokamak, not for RFP !) */

    BP = sqrt(BR*BR + BZ*BZ);/* Poloidal magnetic field */
    dBPdrho = (BR*dBRdrho + BZ*dBZdrho)/BP;
    dBPdtheta = (BR*dBRdtheta + BZ*dBZdtheta)/BP;
    
    B = sqrt(BR*BR + BZ*BZ + BPHI*BPHI);/* Total magnetic field */
    dBdrho = (BR*dBRdrho + BZ*dBZdrho + BPHI*dBPHIdrho)/B;
    dBdtheta = (BR*dBRdtheta + BZ*dBZdtheta + BPHI*dBPHIdtheta)/B;
    
    raymagnetic.BPn[0] = BP/B;/* Normlaized poloidal magnetic field */
    raymagnetic.dBPndY[0] = dBPdrho/B - BP*dBdrho/B/B;
    raymagnetic.dBPndY[1] = dBPdtheta/B - BP*dBdtheta/B/B;
   
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

    raymagnetic.gradrhon[0] = R*BP*dRstardpsin/equilparam.psia[0];
    raymagnetic.dgradrhondY[0] = (dRdrho*BP*dRstardpsin + R*dBPdrho*dRstardpsin + R*BP*ddRstardpsindrho)/equilparam.psia[0];
    raymagnetic.dgradrhondY[1] = (dRdtheta*BP*dRstardpsin + R*dBPdtheta*dRstardpsin)/equilparam.psia[0];
   
    
/*    mexPrintf("rho,theta:%g,%g\n",Y[0],Y[1]);
    mexPrintf("Te[0],dTedY[0],dTedY[1],ne[0],dnedY[0],dnedY[1]:%g,%g,%g,%g,%g,%g\n",rayprofiles.Te[0],rayprofiles.dTedY[0],rayprofiles.dTedY[1],rayprofiles.ne[0],rayprofiles.dnedY[0],rayprofiles.dnedY[1]);
    for (is=0;is<equilparam.ns[0];is++) {
        mexPrintf("is,zTi[is],dzTidY[is][0],dzTidY[is][1],zni[is],dznidY[is][0],dznidY[is][1]:%d,%g,%g,%g,%g,%g,%g\n",is,rayprofiles.zTi[is],rayprofiles.dzTidY[is][0],rayprofiles.dzTidY[is][1],rayprofiles.zni[is],rayprofiles.dznidY[is][0],rayprofiles.dznidY[is][1]);
    }*/
    
/*     mexPrintf("rn[0],drndY[0],drndY[1],Rn[0],dRndY[0],dRndY[1]:%g,%g,%g,%g,%g,%g\n",raymagnetic.rn[0],raymagnetic.drndY[0],raymagnetic.drndY[1],raymagnetic.Rn[0],raymagnetic.dRndY[0],raymagnetic.dRndY[1]);
     mexPrintf("BPn[0],dBPndY[0],dBPndY[1]:%g,%g,%g\n",raymagnetic.BPn[0],raymagnetic.dBPndY[0],raymagnetic.dBPndY[1]);
     mexPrintf("BPHIn[0],dBPHIndY[0],dBPHIndY[1]:%g,%g,%g\n",raymagnetic.BPHIn[0],raymagnetic.dBPHIndY[0],raymagnetic.dBPHIndY[1]);
     mexPrintf("B[0],dBdY[0],dBdY[1]:%g,%g,%g\n",raymagnetic.B[0],raymagnetic.dBdY[0],raymagnetic.dBdY[1]);
     mexPrintf("salpha[0],dsalphadY[0],dsalphadY[1]:%g,%g,%g\n",raymagnetic.salpha[0],raymagnetic.dsalphadY[0],raymagnetic.dsalphadY[1]);
*/ 
/*   
     mexPrintf("calpha[0],dcalphadY[0],dcalphadY[1]:%g,%g,%g\n",raymagnetic.calpha[0],raymagnetic.dcalphadY[0],raymagnetic.dcalphadY[1]);
     mexPrintf("gradrhon[0],dgradrhondY[0],dgradrhondY[1]:%g,%g,%g\n",raymagnetic.gradrhon[0],raymagnetic.dgradrhondY[0],raymagnetic.dgradrhondY[1]);
     mexPrintf("dRstardpsin,ddRstardpsindrho,psia:%g,%g,%gma\n",dRstardpsin,ddRstardpsindrho,equilparam.psia[0]);
*/
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
    double BPHI0,BP0,dBP0dY1;
    double ep,cyl;
    double B,dBdrho,dBdtheta;
    double BP,dBPdrho,dBPdtheta;
    double BPHI,dBPHIdrho,dBPHIdtheta;
    double R,dRdrho,dRdtheta;
    
    double Ip,BPa,qmin,qmax,eq,q,dqdrho;
    
    int is;
   
    if (equilparam.ns[0] > 4) mexErrMsgTxt("Only one high-Z impurity allowed in analytical equilibrium");

    cyl = 1.0;/* cylindrical factor */
    
    BPHI0 = 3.0;/* Signed toroidal magnetic component (T), see the conventions */
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
    
    Ip = 1.0;/* sign toroidal component of the plasma current (MA), see the conventions */
    qmin = 1.0;/* Edge safety factor q */
    eq = 2.0;/* q=0 flat q profile */
    
    equilparam.zZi[0] = 0.0;/* vacuum case */
        
    rayprofiles.Te[0] = Tea + (Te0 - Tea)*pow(1 - Y[0]*Y[0],eTe);
    rayprofiles.dTedY[0] = -2*Y[0]*eTe*(Te0 - Tea)*pow(1 - Y[0]*Y[0],eTe - 1);  
    
    rayprofiles.ne[0] = nea + (ne0 - nea)*pow(1 - Y[0]*Y[0],ene);
    rayprofiles.dnedY[0] = -2*Y[0]*ene*(ne0 - nea)*pow(1 - Y[0]*Y[0],ene - 1);  
    
    /* impurity calculation to be implemeted */
    
    for (is=0;is<equilparam.ns[0];is++) {
        rayprofiles.zTi[is] = Tia + (Ti0 - Tia)*pow(1 - Y[0]*Y[0],eTi);
        rayprofiles.dzTidY[is][0] = -2*Y[0]*eTi*(Ti0 - Tia)*pow(1 - Y[0]*Y[0],eTi - 1);     
    }
    
    for (is=0;is<3;is++) {
        rayprofiles.zni[is] = fi[is]*(nea + (ne0 - nea)*pow(1 - Y[0]*Y[0],ene));
        rayprofiles.dznidY[is][0] = -fi[is]*(2*Y[0]*ene*(ne0 - nea)*pow(1 - Y[0]*Y[0],ene - 1));       
    }
    
    for (is=3;is<equilparam.ns[0];is++) {
        rayprofiles.zni[is] = 0;
        rayprofiles.dznidY[is][0] = 0;         
    }

    raymagnetic.rn[0] = Y[0];
    raymagnetic.drndY[0] = 1;
    raymagnetic.drndY[1] = 0.0;
    
    R = Rp*(1.0 + ep*Y[0]*cos(Y[1]));
    dRdrho = Rp*ep*cos(Y[1]);
    dRdtheta = -Rp*ep*Y[0]*sin(Y[1]);
    
    raymagnetic.Rn[0] = R/equilparam.ap[0];
    raymagnetic.dRndY[0] = dRdrho/equilparam.ap[0];
    raymagnetic.dRndY[1] = dRdtheta/equilparam.ap[0];
    
    BPHI = Rp*BPHI0/R;
    dBPHIdrho = -Rp*BPHI0*dRdrho/R/R;
    dBPHIdtheta =  -Rp*BPHI0*dRdtheta/R/R;
    
    BPa = 0.2*fabs(Ip)/Rp/ep;
    qmax = ep*cyl*fabs(BPHI0)/BPa;/* cylindrical limit */
    q = (qmax - qmin)*pow(Y[0],eq) + qmin;
    dqdrho = eq*(qmax - qmin)*pow(Y[0],eq - 1.0);
    
    BP = cyl*ep*Rp*Y[0]*fabs(BPHI0)/q/R;/* Poloidal magnetic field, cylindrical limit */
    dBPdrho = cyl*ep*Rp*(fabs(BPHI0)/q/R - dqdrho*Y[0]*fabs(BPHI0)/q/q/R - dRdrho*Y[0]*fabs(BPHI0)/R/R/q);
    dBPdtheta = -cyl*ep*Rp*dRdtheta*Y[0]*fabs(BPHI0)/R/R/q;/* cylindrical limit by construction */
/*     mexPrintf("cyl,ep,Rp,BPa,qmax,q,dqdrho,Y[0],BP,BPHI0,R,dBPdrho,dBPdtheta:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",cyl,ep,Rp,BPa,qmax,q,dqdrho,Y[0],BP,BPHI0,R,dBPdrho,dBPdtheta); */
      
    raymagnetic.sigmaIp[0] = sgn(Ip);
    
    B = sqrt(BP*BP + BPHI*BPHI);
    dBdrho = (BP*dBPdrho + BPHI*dBPHIdrho)/B;
    dBdtheta = (BP*dBPdtheta + BPHI*dBPHIdtheta)/B; 
    
    raymagnetic.BPHIn[0] = BPHI/B;
    raymagnetic.dBPHIndY[0] = dBPHIdrho/B - BPHI*dBdrho/B/B;
    raymagnetic.dBPHIndY[1] = dBPHIdtheta/B - BPHI*dBdtheta/B/B;
   
    raymagnetic.BPn[0] = BP/B;
    raymagnetic.dBPndY[0] = dBPdrho/B - BP*dBdrho/B/B;
    raymagnetic.dBPndY[1] = dBPdtheta/B - BP*dBdtheta/B/B;
    
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
    mexPrintf("rho,theta:%g,%g\n",Y[0],Y[1]);
    mexPrintf("Te[0],dTedY[0],dTedY[1],ne[0],dnedY[0],dnedY[1]:%g,%g,%g,%g,%g,%g\n",rayprofiles.Te[0],rayprofiles.dTedY[0],rayprofiles.dTedY[1],rayprofiles.ne[0],rayprofiles.dnedY[0],rayprofiles.dnedY[1]);
    for (is=0;is<equilparam.ns[0];is++) {
        mexPrintf("is,zTi[is],dzTidY[is][0],dzTidY[is][1],zni[is],dznidY[is][0],dznidY[is][1]:%d,%g,%g,%g,%g,%g,%g\n",is,rayprofiles.zTi[is],rayprofiles.dzTidY[is][0],rayprofiles.dzTidY[is][1],rayprofiles.zni[is],rayprofiles.dznidY[is][0],rayprofiles.dznidY[is][1]);
    }*/
    
    mexPrintf("rn[0],drndY[0],drndY[1],Rn[0],dRndY[0],dRndY[1]:%g,%g,%g,%g,%g,%g\n",raymagnetic.rn[0],raymagnetic.drndY[0],raymagnetic.drndY[1],raymagnetic.Rn[0],raymagnetic.dRndY[0],raymagnetic.dRndY[1]);
    mexPrintf("BPn[0],dBPndY[0],dBPndY[1]:%g,%g,%g\n",raymagnetic.BPn[0],raymagnetic.dBPndY[0],raymagnetic.dBPndY[1]);
    mexPrintf("BPHIn[0],dBPHIndY[0],dBPHIndY[1]:%g,%g,%g\n",raymagnetic.BPHIn[0],raymagnetic.dBPHIndY[0],raymagnetic.dBPHIndY[1]);
    mexPrintf("B[0],dBdY[0],dBdY[1]:%g,%g,%g\n",raymagnetic.B[0],raymagnetic.dBdY[0],raymagnetic.dBdY[1]);
    mexPrintf("salpha[0],dsalphadY[0],dsalphadY[1]:%g,%g,%g\n",raymagnetic.salpha[0],raymagnetic.dsalphadY[0],raymagnetic.dsalphadY[1]);
    mexPrintf("calpha[0],dcalphadY[0],dcalphadY[1]:%g,%g,%g\n",raymagnetic.calpha[0],raymagnetic.dcalphadY[0],raymagnetic.dcalphadY[1]);
    mexPrintf("gradrhon[0],dgradrhondY[0],dgradrhondY[1]:%g,%g,%g\n",raymagnetic.gradrhon[0],raymagnetic.dgradrhondY[0],raymagnetic.dgradrhondY[1]);

}


double sgn(x)
double x;
{
   if (x < 0.0) {return(-1.0);} 
   if (x == 0.0) {return(0.0);}    
   if (x > 0.0) {return(1.0);}    
    
}


void hottensor(X,ns,ncyclharm,raymagnetic,Npar,dNpardY,Nperp,dNperpdY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY)
susceptibilitytensor_format X;
int ns;
int ncyclharm;
raymagnetic_format raymagnetic;
double wcn[],wpn2[],betath[];
double dwcndY[][MC],dwpn2dY[][MC],dbetathdY[][MC];
double Npar,dNpardY[];
double complex Nperp,dNperpdY[];
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


    calcY(ns,ncyclharm,Npar,dNpardY,Nperp,dNperpdY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY,Yxx,Yxy,Yxz,Yyy,Yyz,Yzz,dYxxdNperp,dYxydNperp,dYxzdNperp,dYyydNperp,dYyzdNperp,dYzzdNperp,dYxxdNpar,dYxydNpar,dYxzdNpar,dYyydNpar,dYyzdNpar,dYzzdNpar,dYxxdbetath,dYxydbetath,dYxzdbetath,dYyydbetath,dYyzdbetath,dYzzdbetath,dYxxdwcn,dYxydwcn,dYxzdwcn,dYyydwcn,dYyzdwcn,dYzzdwcn,dYxxdwpn2,dYxydwpn2,dYxzdwpn2,dYyydwpn2,dYyzdwpn2,dYzzdwpn2);

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
     
    buildXstruc(X,ns,raymagnetic,dNpardY,dNperpdY,dwcndY,dwpn2dY,dbetathdY,Xxx,Xxy,Xxz,Xyy,Xyz,Xzz,dXxxdNperp,dXxydNperp,dXxzdNperp,dXyydNperp,dXyzdNperp,dXzzdNperp,dXxxdNpar,dXxydNpar,dXxzdNpar,dXyydNpar,dXyzdNpar,dXzzdNpar,dXxxdbetath,dXxydbetath,dXxzdbetath,dXyydbetath,dXyzdbetath,dXzzdbetath,dXxxdwcn,dXxydwcn,dXxzdwcn,dXyydwcn,dXyzdwcn,dXzzdwcn,dXxxdwpn2,dXxydwpn2,dXxzdwpn2,dXyydwpn2,dXyzdwpn2,dXzzdwpn2);
} 


void calcY(ns,ncyclharm,Npar,dNpardY,Nperp,dNperpdY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY,Yxx,Yxy,Yxz,Yyy,Yyz,Yzz,dYxxdNperp,dYxydNperp,dYxzdNperp,dYyydNperp,dYyzdNperp,dYzzdNperp,dYxxdNpar,dYxydNpar,dYxzdNpar,dYyydNpar,dYyzdNpar,dYzzdNpar,dYxxdbetath,dYxydbetath,dYxzdbetath,dYyydbetath,dYyzdbetath,dYzzdbetath,dYxxdwcn,dYxydwcn,dYxzdwcn,dYyydwcn,dYyzdwcn,dYzzdwcn,dYxxdwpn2,dYxydwpn2,dYxzdwpn2,dYyydwpn2,dYyzdwpn2,dYzzdwpn2)
int ns;
int ncyclharm;
double Npar,dNpardY[MC];
double complex Nperp,dNperpdY[MC];
double wcn[],dwcndY[][MC],wpn2[],dwpn2dY[][MC],betath[],dbetathdY[][MC];
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
    if (cimag(z) == 0.0) {/* pure real argument */
        x = creal(z);
        dawson(x,&daw);
        Z[0]=-2.0*daw+I*sqrt(PI)*exp(x*x);
    } else if (creal(z) == 0.0) {/* pure imaginary argument */
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
    
/*     mexPrintf("modBesseln:%g,%g\n",mBn[0]); */
    
}



void imagBessel(nhu,z,iBn,iBnp,iBnpp)
double nhu;
double complex z,*iBn,*iBnp,*iBnpp;
{   
    mxArray *rhs[3], *lhs[1];
    
    double	*pr,*pi;
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
    mexCallMATLAB(1,lhs,3,rhs,"besselmx");/* call the MatLab built-in Bessel function: [w,ierr] = besselmx(double('J'),0,z) */
    Bessel_r = mxGetData(lhs[0]);
    Bessel_i = mxGetImagData(lhs[0]);
    Besseln = Bessel_r[0] + I*Bessel_i[0];
    
/*     mexPrintf("Besseln:%g,%g\n",Besseln); */
    
    pr = mxGetPr(rhs[1]);
    pr[0] = nhu - 1.0;
    mexCallMATLAB(1,lhs,3,rhs,"besselmx");/* call the MatLab built-in Bessel function: [w,ierr] = besselmx(double('J'),0,z) */
    Bessel_r = mxGetData(lhs[0]);
    Bessel_i = mxGetImagData(lhs[0]);
    Besselnm1 = Bessel_r[0] + I*Bessel_i[0];
    
/*     mexPrintf("Besseln:%g,%g\n",Besselnm1); */
    
    
    pr = mxGetPr(rhs[1]);
    pr[0] = nhu - 2.0;
    mexCallMATLAB(1,lhs,3,rhs,"besselmx");/* call the MatLab built-in Bessel function: [w,ierr] = besselmx(double('J'),0,z) */
    Bessel_r = mxGetData(lhs[0]);
    Bessel_i = mxGetImagData(lhs[0]);
    Besselnm2 = Bessel_r[0] + I*Bessel_i[0];

/*     mexPrintf("Besseln:%g,%g\n",Besselnm2); */
  
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

    z2 = z*z;
    som = czero;
    rz = fabs(creal(z));
    iz = fabs(cimag(z));

/* Series expansion around zeta = 0 formula A10 */
    
    if ((rz <= b) & (iz <= 2.0-1.5*rz/b)) {
        for (nn = nmax1;nn > 0;nn--) {
            som = 1.0/nn*z2*1.0/(2.0*nn + 1.0 + som);
        }
        ZZ = cexp(-z2)*(isqrtpi - 2.0*z*(som + 1.0));
    }

/* Continued fraction expansion formula A12 & A13 */

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

/* Asymptotic expansion formula A15 */
    if ((rz > b) & (iz <= 0.5)) {
        z_2 = cone/z2;
        for (nn = nmax3;nn > 0;nn--) {
            som = (nn-0.5)*z_2*(som + 1.0);
        }
        ZZ = -(som + 1.0)/z;    
        criterion = 0.7853981633974483331/rz;
        sigma = (cimag(z) < criterion) + (cimag(z) < -criterion);
        if (sigma > 0.0) {
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
       USING A CHEBYCHEV POLYNOMIAL SERIES.  
*/

    static double half = 0.5; 
    static double one = 1.0; 
    static double two = 2.0; 
    static double ten = 10.0;
    
/* nmax=	5 	      => 1e-2 precision
    	       10	      => 1e-4
    	       15	      => 1e-6
    	       20	      => single
    	       50	      => double 
*/
    static int nmax = 50;
    
    static double tcoef [51]={2.3770636862073187, -0.2214259431356961, -0.0232524179380925, 0.1327809189298409, -0.1325824891002065,
           0.0825446940740374,-0.0337827509774703, 0.0070874724137126, 0.0009814185303952,-0.0010948499244205,
           0.0001341521888280, 0.0001204181702739,-0.0000351287219323,-0.0000146145750095, 0.0000062641524139,
           0.0000022709548584,-0.0000010280349044,-0.0000004487400975, 0.0000001532631036, 0.0000001005306690,
          -0.0000000166366048,-0.0000000226490692,-0.0000000006425396, 0.0000000046258504, 0.0000000011681305,
          -0.0000000007317958,-0.0000000004540732, 0.0000000000395128, 0.0000000001175806, 0.0000000000278655,
          -0.0000000000190620,-0.0000000000134858,-0.0000000000001751, 0.0000000000033395, 0.0000000000013606,
          -0.0000000000003122,-0.0000000000004896,-0.0000000000001295, 0.0000000000000741, 0.0000000000000694,
           0.0000000000000122,-0.0000000000000135,-0.0000000000000101,-0.0000000000000013, 0.0000000000000022,
           0.0000000000000016, 0.0000000000000002,-0.0000000000000004,-0.0000000000000003, 0.0000000000000000,
           0.0000000000000001};
    double zeta2,t,twot,tn,tnm1,tnm2;
    int ind;

    zeta2 = zeta*zeta;
    t = (zeta2 - ten)/(zeta2 + ten);
    twot = two*t;
    tnm1 = one;
    tn = t;
    dwork[0] = half*tcoef[0]*tnm1 + tcoef[1]*tn;
    for (ind=2;ind <= nmax;ind++) {
        tnm2 = tnm1;
        tnm1 = tn;
        tn = twot*tnm1 - tnm2;
        dwork[0] += tcoef[ind]*tn;
    }
    dwork[0] *= zeta/(one + two*zeta2);  
}

void weakrelativistictensor(X,ns,raymagnetic,Npar,dNpardx,Nperp,dNperpdx,wcn,dwcndx,wpn2,dwpn2dx,betath,dbetathdx)
susceptibilitytensor_format X;
int ns;
raymagnetic_format raymagnetic;
double wcn[],wpn2[],betath[];
double dwcndx[][MC],dwpn2dx[][MC],dbetathdx[][MC];
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

    double npar2, te, B, XX, Y_1, Y_2, mu, halfmu, mu2, delta1, delta2, delta3, mudelta1, mudelta2, mudelta3;
    double halfnpar2, psi2, twopsi2, pipo1;
    double F50, F70, F90, dF50dz, dF70dz, dF90dz, dF30da, dF50da, dF70da, dF90da, dF110da;
    double I50, I70, I90, dI50dz, dI70dz, dI90dz, dI30da, dI50da, dI70da, dI90da, dI110da;
    double F51, F71, F91, dF51dz, dF71dz, dF91dz,         dF51da, dF71da, dF91da, dF111da;
    double I51, I71, I91, dI51dz, dI71dz, dI91dz,         dI51da, dI71da, dI91da, dI111da;
    double      F72, F92,         dF72dz, dF92dz,                 dF72da, dF92da, dF112da;
    double      I72, I92,         dI72dz, dI92dz,                 dI72da, dI92da, dI112da;
    double           F93,                 dF93dz,                         dF93da;
    double           I93,                 dI93dz,                         dI93da;

    double muF50, dmuF50dTe, dmuF50dnpar2, muI50, dmuI50dTe, dmuI50dnpar2;
    double dF70dTe, dF70dnpar2, dI70dTe, dI70dnpar2, dF90dTe, dF90dnpar2, dI90dTe, dI90dnpar2;
    double muF701, dmuF701dTe, dmuF701dnpar2, muI701, dmuI701dTe, dmuI701dnpar2;
    double F901, dF901dTe, dF901dnpar2, I901, dI901dTe, dI901dnpar2;
    double twopsi2muF702, dtwopsi2muF702dTe, dtwopsi2muF702dnpar2, twopsi2muI702, dtwopsi2muI702dTe, dtwopsi2muI702dnpar2;
    double twopsi2F902, dtwopsi2F902dTe, dtwopsi2F902dnpar2, twopsi2I902, dtwopsi2I902dTe, dtwopsi2I902dnpar2;
    double twopsi2F1102,dtwopsi2F1102dTe,dtwopsi2F1102dnpar2,twopsi2I1102,dtwopsi2I1102dTe,dtwopsi2I1102dnpar2;
    double muF51, dmuF51dY, dmuF51dTe, dmuF51dnpar2, muI51, dmuI51dY, dmuI51dTe, dmuI51dnpar2;
    double dF71dY, dF71dTe, dF71dnpar2, dI71dY, dI71dTe, dI71dnpar2;
    double dF91dY, dF91dTe, dF91dnpar2, dI91dY, dI91dTe, dI91dnpar2;
    double muF711, dmuF711dY, dmuF711dTe, dmuF711dnpar2, muI711, dmuI711dY, dmuI711dTe, dmuI711dnpar2;
    double F911, dF911dY, dF911dTe, dF911dnpar2, I911, dI911dY, dI911dTe, dI911dnpar2;
    double twopsi2F912,  dtwopsi2F912dY,  dtwopsi2F912dTe,  dtwopsi2F912dnpar2;
    double twopsi2I912,  dtwopsi2I912dY,  dtwopsi2I912dTe,  dtwopsi2I912dnpar2;
    double twopsi2F1112, dtwopsi2F1112dY, dtwopsi2F1112dTe, dtwopsi2F1112dnpar2;
    double twopsi2I1112,  dtwopsi2I1112dY, dtwopsi2I1112dTe, dtwopsi2I1112dnpar2;
    double dF72dY, dF72dTe, dF72dnpar2, dI72dY, dI72dTe, dI72dnpar2;
    double dF92dY, dF92dTe, dF92dnpar2, dI92dY, dI92dTe, dI92dnpar2;
    double F921, dF921dY, dF921dTe, dF921dnpar2, I921, dI921dY, dI921dTe, dI921dnpar2;
    double twopsi2F1122, dtwopsi2F1122dY, dtwopsi2F1122dTe, dtwopsi2F1122dnpar2;
    double twopsi2I1122, dtwopsi2I1122dY, dtwopsi2I1122dTe, dtwopsi2I1122dnpar2;
    double dF93dY, dF93dTe, dF93dnpar2, dI93dY, dI93dTe, dI93dnpar2;
    double delta_1, delta_1_1, delta_1_2, delta_2, delta_2_1, delta_2_2, delta_3, delta_3_1;
    double F5_1, dF5_1dz, muF5_1, dmuF5_1dY, dmuF5_1dTe, dmuF5_1dnpar2;
    double F7_1, dF7_1dz, dF7_1dY, dF7_1dTe, dF7_1dnpar2;
    double F9_1, dF9_1dz, dF9_1dY, dF9_1dTe, dF9_1dnpar2;
    double muF7_11, dmuF7_11dY, dmuF7_11dTe, dmuF7_11dnpar2;
    double F9_11, dF9_11dY, dF9_11dTe, dF9_11dnpar2;
    double twopsi2F9_12,  dtwopsi2F9_12dY,  dtwopsi2F9_12dTe,  dtwopsi2F9_12dnpar2;
    double twopsi2F11_12, dtwopsi2F11_12dY, dtwopsi2F11_12dTe, dtwopsi2F11_12dnpar2;
    double F7_2, dF7_2dz, dF7_2dY, dF7_2dTe, dF7_2dnpar2;
    double F9_2, dF9_2dz, dF9_2dY, dF9_2dTe, dF9_2dnpar2;
    double F9_21, dF9_21dY, dF9_21dTe, dF9_21dnpar2;
    double twopsi2F11_22, dtwopsi2F11_22dY, dtwopsi2F11_22dTe, dtwopsi2F11_22dnpar2;
    double F9_3, dF9_3dz, dF9_3dY, dF9_3dTe, dF9_3dnpar2;
    double coeff1, coeff2, coeff3, coeff4, coeff5, coeff6, coeff7, coeff8;

    double complex R0, dR0dX, dR0dY, dR0dTe, dR0dnpar2;
    double complex R1, dR1dX, dR1dY, dR1dTe, dR1dnpar2;
    double complex R2, dR2dX, dR2dY, dR2dTe, dR2dnpar2;
    double complex RR, dRdX , dRdY , dRdTe , dRdnpar2;
    double complex L0, dL0dX, dL0dY, dL0dTe, dL0dnpar2;
    double complex L1, dL1dX, dL1dY, dL1dTe, dL1dnpar2;
    double complex L2, dL2dX, dL2dY, dL2dTe, dL2dnpar2;
    double complex L , dLdX , dLdY , dLdTe , dLdnpar2;
    double complex P0, dP0dX, dP0dY, dP0dTe, dP0dnpar2;
    double complex P1, dP1dX, dP1dY, dP1dTe, dP1dnpar2;
    double complex P2, dP2dX, dP2dY, dP2dTe, dP2dnpar2;
    double complex P , dPdX , dPdY , dPdTe , dPdnpar2;
    double complex T1, dT1dX, dT1dY, dT1dTe, dT1dnpar2;
    double complex T2, dT2dX, dT2dY, dT2dTe, dT2dnpar2;
    double complex T,  dTdX,  dTdY,   dTdTe, dTdnpar2;
    double complex M0, dM0dX, dM0dY, dM0dTe, dM0dnpar2;
    double complex M1, dM1dX, dM1dY, dM1dTe, dM1dnpar2;
    double complex M, dMdX, dMdY, dMdTe, dMdnpar2;
    double complex N0, dN0dX, dN0dY, dN0dTe, dN0dnpar2;
    double complex N1, dN1dX, dN1dY, dN1dTe, dN1dnpar2;
    double complex N, dNdX,  dNdY,  dNdTe,  dNdnpar2;
    double complex S0, S1, S2, S;
    double complex Nperp2;

    

/* Hot plasma, both modes FLR approximation up to (kperp*rhoe)^4
   Te is normalized Te => kTe/mc2 
   ne is normalized ne => X=e^2*ne/(me*epsilon0*omega0^2)
   B is normalized B => Y=e*B/(me*omega0)
    k is normalized k => k*clumn = refractive index 
*/ 	

    npar2 = Npar*Npar;
    te = betath[0]*betath[0];
    B = wcn[0];
    XX = wpn2[0];
    Y_1 = 1.0/B;
    Y_2 = Y_1*Y_1;
    mu = 1.0/te;
    halfmu = 0.5*mu;
    mu2 = mu*mu;
    delta1 = 1.0-B;
    delta2 = delta1-B;
    delta3 = delta2-B;
    halfnpar2 = 0.5*npar2;
    psi2 = mu*halfnpar2;
    twopsi2 = 2.0*psi2;

/* Compute Shkarovsky functions together with its partial derivatives 
   for resonant parameters mu*(1.0-n*Y)  
   Non-resonant parameters (n<0) => asymptotic approximation 
*/


/* Resonant terms N=0 */
    Shka(mu,psi2,&F50,&F70,&F90,&dF50dz,&dF70dz,&dF90dz,&dF30da,&dF50da,&dF70da,&dF90da,&dF110da);

    muF50 = mu*F50;
    dmuF50dTe = -mu2*(mu*(dF50dz+halfnpar2*dF50da)+F50);
    dmuF50dnpar2 = mu*halfmu*dF50da;

    dF70dTe = -mu2*(dF70dz+halfnpar2*dF70da);
    dF70dnpar2 = halfmu*dF70da; 
    dF90dTe = -mu2*(dF90dz+halfnpar2*dF90da);
    dF90dnpar2 = halfmu*dF90da; 

    muF701 = mu*dF70dz;
    dmuF701dTe = -mu2*(mu*(dF50da+halfnpar2*(dF70da-dF50da))+dF70dz);
    dmuF701dnpar2 = mu*halfmu*(dF70da-dF50da);

    F901 = dF90dz;
    dF901dTe = -mu2*(dF70da+halfnpar2*(dF90da-dF70da));
    dF901dnpar2 = halfmu*(dF90da-dF70da);
 
    twopsi2muF702 = mu*twopsi2*dF50da;
    dtwopsi2muF702dTe = -mu2*mu*twopsi2*(dF50da-dF30da+halfnpar2*(dF70da-2.0*dF50da+dF30da)) - 2.0*mu*twopsi2muF702;
    dtwopsi2muF702dnpar2 = mu*twopsi2*halfmu*(dF70da-2.0*dF50da+dF30da)+mu2*dF50da;

    twopsi2F902 = twopsi2*dF70da;
    dtwopsi2F902dTe = -mu2*twopsi2*(dF70da-dF50da+halfnpar2*(dF90da-2.0*dF70da+dF50da)) - mu*twopsi2F902;
    dtwopsi2F902dnpar2 = twopsi2*halfmu*(dF90da-2.0*dF70da+dF50da)+mu*dF70da;
	 
    twopsi2F1102 = twopsi2*dF90da;
    dtwopsi2F1102dTe = -mu2*twopsi2*(dF90da-dF70da+halfnpar2*(dF110da-2.0*dF90da+dF70da)) - mu*twopsi2F1102;
    dtwopsi2F1102dnpar2=twopsi2*halfmu*(dF110da-2.0*dF90da+dF70da)+mu*dF90da;

    if (mu < psi2) {
        ImShka(mu,psi2,&I50,&I70,&I90,&dI50dz,&dI70dz,&dI90dz,&dI30da,&dI50da,&dI70da,&dI90da,&dI110da);
        muI50 = mu*I50;
        dmuI50dTe = -mu2*(mu*(dI50dz+halfnpar2*dI50da)+I50);
        dmuI50dnpar2 = mu*halfmu*dI50da;
        dI70dTe = -mu2*(dI70dz+halfnpar2*dI70da);
        dI70dnpar2 = halfmu*dI70da; 
        dI90dTe = -mu2*(dI90dz+halfnpar2*dI90da);
        dI90dnpar2 = halfmu*dI90da;
        muI701 = mu*dI70dz;
        dmuI701dTe = -mu2*(mu*(dI50da+halfnpar2*(dI70da-dI50da))+dI70dz);
        dmuI701dnpar2 = mu*halfmu*(dI70da-dI50da);
        I901 = dI90dz;
        dI901dTe = -mu2*(dI70da+halfnpar2*(dI90da-dI70da));
        dI901dnpar2 = halfmu*(dI90da-dI70da);
        twopsi2muI702 = mu*twopsi2*dI50da;
        dtwopsi2muI702dTe = -mu2*mu*twopsi2*(dI50da-dI30da+halfnpar2*(dI70da-2.0*dI50da+dI30da)) - 2.0*mu*twopsi2muI702;
        dtwopsi2muI702dnpar2 = mu*twopsi2*halfmu*(dI70da-2.0*dI50da+dI30da)+mu2*dI50da;
        twopsi2I902 = twopsi2*dI70da;
        dtwopsi2I902dTe = -mu2*twopsi2*(dI70da-dI50da+halfnpar2*(dI90da-2.0*dI70da+dI50da)) - mu*twopsi2I902;
        dtwopsi2I902dnpar2 = twopsi2*halfmu*(dI90da-2.0*dI70da+dI50da)+mu*dI70da;
        twopsi2I1102 = twopsi2*dI90da;
        dtwopsi2I1102dTe = -mu2*twopsi2*(dI90da-dI70da+halfnpar2*(dI110da-2.0*dI90da+dI70da)) - mu*twopsi2I1102;
        dtwopsi2I1102dnpar2 = twopsi2*halfmu*(dI110da-2.0*dI90da+dI70da)+mu*dI90da;
    } else {
        I50 = 0.0;I70 = 0.0; I90 = 0.0; dI50dz = 0.0; dI70dz = 0.0; dI90dz = 0.0;
        dI30da = 0.0; dI50da = 0.0; dI70da = 0.0; dI90da = 0.0; dI110da = 0.0;
        muI50 = 0.0; dmuI50dTe = 0.0; dmuI50dnpar2 = 0.0;
        dI70dTe = 0.0; dI70dnpar2 = 0.0;
        dI90dTe = 0.0; dI90dnpar2 = 0.0;
        muI701 = 0.0; dmuI701dTe = 0.0; dmuI701dnpar2 = 0.0;
        I901 = 0.0;   dI901dTe = 0.0;   dI901dnpar2 = 0.0;
        twopsi2muI702 = 0.0; dtwopsi2muI702dTe = 0.0; dtwopsi2muI702dnpar2 = 0.0;
        twopsi2I902  = 0.0; dtwopsi2I902dTe  = 0.0; dtwopsi2I902dnpar2  = 0.0;
        twopsi2I1102 = 0.0; dtwopsi2I1102dTe = 0.0; dtwopsi2I1102dnpar2 = 0.0;
    }

/* Resonant terms N=+1 */
    Shka(mu*delta1,psi2,&F51,&F71,&F91,&dF51dz,&dF71dz,&dF91dz,&pipo1,&dF51da,&dF71da,&dF91da,&dF111da);         

    muF51 = mu*F51;
    dmuF51dY = -mu2*dF51dz;
    dmuF51dTe = -mu2*(mu*(delta1*dF51dz + halfnpar2*dF51da)+F51);
    dmuF51dnpar2 = mu*halfmu*dF51da;

    dF71dY = -mu*dF71dz;
    dF71dTe = -mu2*(delta1*dF71dz + halfnpar2*dF71da);
    dF71dnpar2 = halfmu*dF71da;

    dF91dY = -mu*dF91dz;
    dF91dTe = -mu2*(delta1*dF91dz + halfnpar2*dF91da);
    dF91dnpar2 = halfmu*dF91da;

    muF711 = mu*dF71dz;
    dmuF711dY = -mu2*dF51da;
    dmuF711dTe = -mu2*(mu*(delta1*dF51da+halfnpar2*(dF71da-dF51da))+dF71dz);
    dmuF711dnpar2 = mu*halfmu*(dF71da-dF51da);

    F911 = dF91dz;
    dF911dY = -mu*dF71da;
    dF911dTe = -mu2*(delta1*dF71da+halfnpar2*(dF91da-dF71da));
    dF911dnpar2 = halfmu*(dF91da-dF71da); 
	 
    twopsi2F912 = twopsi2*dF71da;
    dtwopsi2F912dY = -twopsi2*mu*(dF71da-dF51da);
    dtwopsi2F912dTe = -mu2*twopsi2*(delta1*(dF71da-dF51da) + halfnpar2*(dF91da-2.0*dF71da+dF51da)) - mu*twopsi2F912;
    dtwopsi2F912dnpar2 = twopsi2*halfmu*(dF91da-2.0*dF71da+dF51da)+mu*dF71da;
	 
    twopsi2F1112 = twopsi2*dF91da;
    dtwopsi2F1112dY = -twopsi2*mu*(dF91da-dF71da);
    dtwopsi2F1112dTe = -mu2*twopsi2*(delta1*(dF91da-dF71da) + halfnpar2*(dF111da-2.0*dF91da+dF71da)) - mu*twopsi2F1112;
    dtwopsi2F1112dnpar2 = twopsi2*halfmu*(dF111da-2.0*dF91da+dF71da)+mu*dF91da;

    if (mu*delta1<psi2) {
        ImShka(mu*delta1,psi2,&I51,&I71,&I91,&dI51dz,&dI71dz,&dI91dz,&pipo1,&dI51da,&dI71da,&dI91da,&dI111da);
        muI51 = mu*I51;
        dmuI51dY = -mu2*dI51dz;
        dmuI51dTe = -mu2*(mu*(delta1*dI51dz+halfnpar2*dI51da)+I51);
        dmuI51dnpar2 = mu*halfmu*dI51da;
        dI71dY = -mu*dI71dz;
        dI71dTe = -mu2*(delta1*dI71dz+halfnpar2*dI71da);
        dI71dnpar2 = halfmu*dI71da;
        dI91dY = -mu*dI91dz;
        dI91dTe = -mu2*(delta1*dI91dz+halfnpar2*dI91da);
        dI91dnpar2 = halfmu*dI91da;
        muI711 = mu*dI71dz;
        dmuI711dY = -mu2*dI51da;
        dmuI711dTe = -mu2*(mu*(delta1*dI51da+halfnpar2*(dI71da-dI51da))+dI71dz);
        dmuI711dnpar2 = mu*halfmu*(dI71da-dI51da);
        I911 = dI91dz;
        dI911dY = -mu*dI71da;
        dI911dTe = -mu2*(delta1*dI71da+halfnpar2*(dI91da-dI71da));
        dI911dnpar2 = halfmu*(dI91da-dI71da);
        twopsi2I912 = twopsi2*dI71da;
        dtwopsi2I912dY = -twopsi2*mu*(dI71da-dI51da);
        dtwopsi2I912dTe = -mu2*twopsi2*(delta1*(dI71da-dI51da) + halfnpar2*(dI91da-2.0*dI71da+dI51da)) - mu*twopsi2I912;
        dtwopsi2I912dnpar2 = twopsi2*halfmu*(dI91da-2.0*dI71da+dI51da)+mu*dI71da;
        twopsi2I1112 = twopsi2*dI91da;
        dtwopsi2I1112dY = -twopsi2*mu*(dI91da-dI71da);
        dtwopsi2I1112dTe = -mu2*twopsi2*(delta1*(dI91da-dI71da) + halfnpar2*(dI111da-2.0*dI91da+dI71da)) - mu*twopsi2I1112;
        dtwopsi2I1112dnpar2 = twopsi2*halfmu*(dI111da-2.0*dI91da+dI71da)+mu*dI91da;
    } else {
        I51 = 0.0;
	I71 = 0.0;
	I91 = 0.0;
	dI51dz = 0.0;
	dI71dz = 0.0;
	dI91dz = 0.0;
        dI51da = 0.0;
	dI71da = 0.0;
	dI91da = 0.0;
	dI111da = 0.0;
        muI51 = 0.0;
	dmuI51dY = 0.0;
	dmuI51dTe = 0.0;
	dmuI51dnpar2 = 0.0;
        dI71dY = 0.0;
	dI71dTe = 0.0;
	dI71dnpar2 = 0.0;
        dI91dY = 0.0;
	dI91dTe = 0.0;
	dI91dnpar2 = 0.0;
        muI711 = 0.0;
	dmuI711dY = 0.0;
	dmuI711dTe = 0.0;
	dmuI711dnpar2 = 0.0;
        I911 = 0.0;
	dI911dY = 0.0;
	dI911dTe = 0.0;
	dI911dnpar2 = 0.0;
        twopsi2I912  = 0.0;
	dtwopsi2I912dY  = 0.0;
	dtwopsi2I912dTe  = 0.0;
	dtwopsi2I912dnpar2  = 0.0;
        twopsi2I1112 = 0.0;
	dtwopsi2I1112dY = 0.0;
	dtwopsi2I1112dTe = 0.0;
	dtwopsi2I1112dnpar2 = 0.0;
    }

/* Resonant terms N = +2 */
    Shka(mu*delta2,psi2,&pipo1,&F72,&F92,&pipo1,&dF72dz,&dF92dz,&pipo1,&pipo1,&dF72da,&dF92da,&dF112da);         

    dF72dY = -2.0*mu*dF72dz;
    dF72dTe = -mu2*(delta2*dF72dz+halfnpar2*dF72da);
    dF72dnpar2 = halfmu*dF72da;

    dF92dY = -2.0*mu*dF92dz;
    dF92dTe = -mu2*(delta2*dF92dz+halfnpar2*dF92da);
    dF92dnpar2 = halfmu*dF92da;

    F921 = dF92dz;
    dF921dY = -2.0*mu*dF72da;
    dF921dTe = -mu2*(delta2*dF72da+halfnpar2*(dF92da-dF72da));
    dF921dnpar2 = halfmu*(dF92da-dF72da);

    twopsi2F1122 = twopsi2*dF92da;
    dtwopsi2F1122dY = -2.0*twopsi2*mu*(dF92da-dF72da);
    dtwopsi2F1122dTe = -mu2*twopsi2*(delta2*(dF92da-dF72da) + halfnpar2*(dF112da-2.0*dF92da+dF72da)) - mu*twopsi2F1122;
    dtwopsi2F1122dnpar2 = twopsi2*halfmu*(dF112da-2.0*dF92da+dF72da)+mu*dF92da; 

    if (mu*delta2<psi2) {
        ImShka(mu*delta2,psi2,&pipo1,&I72,&I92,&pipo1,&dI72dz,&dI92dz,&pipo1,&pipo1,&dI72da,&dI92da,&dI112da);         

        dI72dY = -2.0*mu*dI72dz;
        dI72dTe = -mu2*(delta2*dI72dz+halfnpar2*dI72da);
        dI72dnpar2 = halfmu*dI72da;
        dI92dY = -2.0*mu*dI92dz;
        dI92dTe = -mu2*(delta2*dI92dz+halfnpar2*dI92da);
        dI92dnpar2 = halfmu*dI92da;
        I921 = dI92dz;
        dI921dY = -2.0*mu*dI72da;
        dI921dTe = -mu2*(delta2*dI72da+halfnpar2*(dI92da-dI72da));
        dI921dnpar2 = halfmu*(dI92da-dI72da);
        twopsi2I1122 = twopsi2*dI92da;
        dtwopsi2I1122dY = -2.0*twopsi2*mu*(dI92da-dI72da);
        dtwopsi2I1122dTe = -mu2*twopsi2*(delta2*(dI92da-dI72da) + halfnpar2*(dI112da-2.0*dI92da+dI72da)) - mu*twopsi2I1122;
        dtwopsi2I1122dnpar2 = twopsi2*halfmu*(dI112da-2.0*dI92da+dI72da)+mu*dI92da;
    } else {
        I72 = 0.0;
	I92 = 0.0;
	dI72dz = 0.0;
	dI92dz = 0.0;
        dI72da = 0.0;
	dI92da = 0.0;
	dI112da = 0.0;         
        dI72dY = 0.0;
	dI72dTe = 0.0;
	dI72dnpar2 = 0.0;
        dI92dY = 0.0;
	dI92dTe = 0.0;
	dI92dnpar2 = 0.0;
        I921 = 0.0;
	dI921dY = 0.0;
	dI921dTe = 0.0;
	dI921dnpar2 = 0.0;
        twopsi2I1122 = 0.0;
	dtwopsi2I1122dY = 0.0;
	dtwopsi2I1122dTe = 0.0;
	dtwopsi2I1122dnpar2 = 0.0;
    }

/* Resonant terms N = +3 */
    
    Shka(mu*delta3,psi2,&pipo1,&pipo1,&F93,&pipo1,&pipo1,&dF93dz,&pipo1,&pipo1,&pipo1,&dF93da,&pipo1);         

    dF93dY = -3.0*mu*dF93dz;
    dF93dTe = -mu2*(delta3*dF93dz+halfnpar2*dF93da);
    dF93dnpar2 = halfmu*dF93da;

    if (mu*delta3<psi2) {
        ImShka(mu*delta3,psi2,&pipo1,&pipo1,&I93,&pipo1,&pipo1,&dI93dz,&pipo1,&pipo1,&pipo1,&dI93da,&pipo1);         

        dI93dY = -3.0*mu*dI93dz;
        dI93dTe = -mu2*(delta3*dI93dz+halfnpar2*dI93da);
        dI93dnpar2 = halfmu*dI93da;
    } else {
        I93 = 0.0; dI93dz = 0.0;
        dI93da = 0.0;
	dI93dY = 0.0;
	dI93dTe = 0.0;
	dI93dnpar2 = 0.0;
    }

         
/* Non-resonant parameters (n<0)  = > asymptotic approximation for Shkarovski functions */

    delta_1 = 1.0+B;
    delta_2 = delta_1+B;
    delta_3 = delta_2+B;
    delta_1_1 = 1.0/delta_1;
    delta_1_2 = delta_1_1*delta_1_1;
    delta_2_1 = 1.0/delta_2;
    delta_2_2 = delta_2_1*delta_2_1;
    delta_3_1 = 1.0/delta_3;

    muF5_1 = delta_1_1;
    dmuF5_1dY = -delta_1_2;
    dmuF5_1dTe = 0.0;
    dmuF5_1dnpar2 = 0.0;

    F7_1 = te*delta_1_1;
    dF7_1dY = -te*delta_1_2;
    dF7_1dTe = delta_1_1;
    dF7_1dnpar2 = 0.0;

    F9_1 = F7_1; dF9_1dY = dF7_1dY; dF9_1dTe = dF7_1dTe; dF9_1dnpar2 = 0.0;

    muF7_11 = -te*delta_1_2;
    dmuF7_11dY = -2.0*muF7_11*delta_1_1;
    dmuF7_11dTe = mu*muF7_11;
    dmuF7_11dnpar2 = 0.0;

    F9_11 = -te*te*delta_1_2;
    dF9_11dY = -2.0*F9_11*delta_1_1;
    dF9_11dTe = 2.0*mu*F9_11;
    dF9_11dnpar2 = 0.0; 

    dtwopsi2F9_12dnpar2 = 2.0*te*te*delta_1_2*delta_1_1;
    twopsi2F9_12 = npar2*dtwopsi2F9_12dnpar2;
    dtwopsi2F9_12dY = -3.0*delta_1_1*twopsi2F9_12;
    dtwopsi2F9_12dTe = 2.0*mu*twopsi2F9_12;

    twopsi2F11_12 = twopsi2F9_12; dtwopsi2F11_12dY = dtwopsi2F9_12dY; 
    dtwopsi2F11_12dTe = dtwopsi2F9_12dTe; dtwopsi2F11_12dnpar2 = dtwopsi2F9_12dnpar2; 
	 
    F7_2 = te*delta_2_1;
    dF7_2dY = -2.0*te*delta_2_2;
    dF7_2dTe = delta_2_1;
    dF7_2dnpar2 = 0.0;

    F9_2 = F7_2; dF9_2dY = dF7_2dY; dF9_2dTe = dF7_2dTe; dF9_2dnpar2 = 0.0;

    F9_21 = -te*te*delta_2_2;
    dF9_21dY = -4.0*F9_21*delta_2_1;
    dF9_21dTe = 2.0*mu*F9_21;
    dF9_21dnpar2 = 0.0;

    dtwopsi2F11_22dnpar2 = 2.0*te*te*delta_2_2*delta_2_1;
    twopsi2F11_22 = npar2*dtwopsi2F11_22dnpar2;
    dtwopsi2F11_22dY = -6.0*delta_2_1*twopsi2F11_22;
    dtwopsi2F11_22dTe = 2.0*mu*twopsi2F11_22; 

    F9_3 = te*delta_3_1;
    dF9_3dY = -3.0*F9_3*delta_3_1;
    dF9_3dTe = delta_3_1;
    dF9_3dnpar2 = 0.0;

/* Compute the weakly relativistic tensor elements in rotating frame.
   FLR approxomation up to (kperp*rhoe)^4, 
   Tensor is developped up to the +/- second harmonic of Wce.
   I.P. Shkarovsky, J. Plasma Phys. (1986) vol. 35 part2, pp319-331.
    = > valid for O1, X1, O2, X2, X3 ECRH scenarios */

    coeff1 = 0.5*Y_2;
    coeff2 = XX*coeff1;
    coeff4 = XX*Y_1;
    coeff3 = mu*coeff4;
    coeff5 = 0.5*te*coeff1*coeff1; /*  = te/(8*Y^4) */
    coeff6 = XX*coeff5;
    coeff7 = 0.25*Y_2*Y_1;
    coeff8 = XX*coeff7;

    dR0dX = -muF51-I*muI51;
    R0 = XX*dR0dX;
    dR0dY = -XX*(dmuF51dY+I*dmuI51dY);
    dR0dTe =  -XX*(dmuF51dTe+I*dmuI51dTe);
    dR0dnpar2 = -XX*(dmuF51dnpar2+I*dmuI51dnpar2);/* ligne a tester YP */

    dR1dX = coeff1*((3.0*F71-F7_1-2.0*F72)+I*(3.0*I71 - 2.0*I72));
    R1 = XX*dR1dX;
    dR1dY = -2.0*R1*Y_1+coeff2*((3.0*dF71dY-dF7_1dY-2.0*dF72dY) + I*(3.0*dI71dY-2.0*dI72dY));
    dR1dTe = coeff2*((3.0*dF71dTe - dF7_1dTe - 2.0*dF72dTe) + I*(3.0*dI71dTe - 2.0*dI72dTe));
    dR1dnpar2 = coeff2*((3.0*dF71dTe-dF7_1dTe-2.0*dF72dTe)+I*(3.0*dI71dTe-2.0*dI72dTe));
    dR2dX = coeff5*((5.0*F9_1-10.0*F91-2.0*F9_2-3.0*F93) + I*(-10.0*I91-3.0*I93));
    R2 = XX*dR2dX;
    dR2dY = -4.0*R2*Y_1+coeff6*((5.0*dF9_1dY-10.0*dF91dY-2.0*dF9_2dY-3.0*dF93dY) + I*(-10.0*dI91dY-3.0*dI93dY));
    dR2dTe = mu*R2+coeff6*((5.0*dF9_1dTe-10.0*dF91dTe-2.0*dF9_2dTe-3.0*dF93dTe) + I*(-10.0*dI91dTe-3.0*dI93dTe));
    dR2dnpar2 = coeff6*((5.0*dF9_1dnpar2-10.0*dF91dnpar2-2.0*dF9_2dnpar2-3.0*dF93dnpar2) + I*(-10.0*dI91dnpar2-3.0*dI93dnpar2));/*  sign Im term to be checked YP ******/

    dL0dX = -muF5_1;
    L0 = -XX*muF5_1;
    dL0dY = -XX*dmuF5_1dY;
    dL0dTe = -XX*dmuF5_1dTe;
    dL0dnpar2 = -XX*dmuF5_1dnpar2;

    dL1dX = coeff1*((3.0*F7_1-F71-2.0*F7_2) + I*(-I71));
    L1 = XX*dL1dX;
    dL1dY = -2.0*L1*Y_1+coeff2*((3.0*dF7_1dY-dF71dY-2.0*dF7_2dY) + I*(-dI71dY));
    dL1dTe = coeff2*((3.0*dF7_1dTe-dF71dTe-2.0*dF7_2dTe) +I*(-dI71dTe));
    dL1dnpar2 = coeff2*((3.0*dF7_1dnpar2-dF71dnpar2-2.0*dF7_2dnpar2) + I*(-dI71dnpar2)); 

    dL2dX = coeff5*((5.0*F91-10.0*F9_1-2.0*F92-3.0*F9_3) + I*(5.0*I91-2.0*I92));
    L2 = XX*dL2dX;
    dL2dY = -4.0*L2*Y_1+coeff6*((5.0*dF91dY-10.0*dF9_1dY-2.0*dF92dY-3.0*dF9_3dY) + I*(5.0*dI91dY-2.0*dI92dY));
    dL2dTe = mu*L2+coeff6*((5.0*dF91dTe-10.0*dF9_1dTe-2.0*dF92dTe-3.0*dF9_3dTe) + I*(5.0*dI91dTe-2.0*dI92dTe));
    dL2dnpar2 = coeff6*((5.0*dF91dnpar2-10.0*dF9_1dnpar2 -2.0*dF92dnpar2-3.0*dF9_3dnpar2) + I*(5.0*dI91dnpar2-2.0*dI92dnpar2));

    dP0dX = (-muF50-twopsi2muF702)+I*(-muI50-twopsi2muI702);
    P0 = XX*dP0dX;
    dP0dY = 0.0; 
    dP0dTe = -XX*((dmuF50dTe+dtwopsi2muF702dTe) + I*(dmuI50dTe+dtwopsi2muI702dTe));
    dP0dnpar2 = -XX*((dmuF50dnpar2 +dtwopsi2muF702dnpar2) + I*(dmuI50dnpar2 +dtwopsi2muI702dnpar2));

    dP1dX = coeff1*((2.0*(F70+twopsi2F902)-(F71+twopsi2F912)-(F7_1+twopsi2F9_12)) + I*(2.0*(I70+twopsi2I902)-(I71+twopsi2I912)));                        	 
    P1 = XX*dP1dX;
    dP1dY = -2.0*coeff4*dP1dX-coeff2*((dF71dY+dtwopsi2F912dY+dF7_1dY+dtwopsi2F9_12dY) + I*(dI71dY+dtwopsi2I912dY));
    dP1dTe = coeff2*((2.0*(dF70dTe+dtwopsi2F902dTe)-(dF71dTe+dtwopsi2F912dTe)-(dF7_1dTe+dtwopsi2F9_12dTe)) + I*(2.0*(dI70dTe+dtwopsi2I902dTe)-(dI71dTe+dtwopsi2I912dTe))); 
    dP1dnpar2 = coeff2*((2.0*(dF70dnpar2+dtwopsi2F902dnpar2)-(dF71dnpar2+dtwopsi2F912dnpar2)-(dF7_1dnpar2+dtwopsi2F9_12dnpar2)) + I*(2.0*(dI70dnpar2+dtwopsi2I902dnpar2)-(dI71dnpar2+dtwopsi2I912dnpar2)                                  ));

    dP2dX = coeff5*((-6.0*(F90+twopsi2F1102)+4.0*(F91+twopsi2F1112+F9_1+twopsi2F11_12)-(F92+twopsi2F1122+F9_2+twopsi2F11_22)) +I*(-6.0*(I90+twopsi2I1102)+4.0*(I91+twopsi2I1112)-(I92+twopsi2I1122                   )));
    P2 = XX*dP2dX;
    dP2dY = -4.0*P2*Y_1+coeff6*((+4.0*(dF91dY+dtwopsi2F1112dY+dF9_1dY+dtwopsi2F11_12dY) - (dF92dY+dtwopsi2F1122dY+dF9_2dY+dtwopsi2F11_22dY)) + I*(+4.0*(dI91dY+dtwopsi2I1112dY) - (dI92dY+dtwopsi2I1122dY                         )));
    dP2dTe = mu*P2+coeff6*((-6.0*(dF90dTe+dtwopsi2F1102dTe)+4.0*(dF91dTe+dtwopsi2F1112dTe+dF9_1dTe+dtwopsi2F11_12dTe)-(dF92dTe+dtwopsi2F1122dTe+dF9_2dTe+dtwopsi2F11_22dTe))+I*(-6.0*(dI90dTe+dtwopsi2I1102dTe)+4.0*(dI91dTe+dtwopsi2I1112dTe)-(dI92dTe+dtwopsi2I1122dTe)));
    dP2dnpar2 = coeff6*((-6.0*(dF90dnpar2+dtwopsi2F1102dnpar2)+4.0*(dF91dnpar2+dtwopsi2F1112dnpar2+dF9_1dnpar2+dtwopsi2F11_12dnpar2)-(dF92dnpar2+dtwopsi2F1122dnpar2+dF9_2dnpar2+dtwopsi2F11_22dnpar2))+I*(-6.0*(dI90dnpar2+dtwopsi2I1102dnpar2)+4.0*(dI91dnpar2+dtwopsi2I1112dnpar2)-(dI92dnpar2+dtwopsi2I1122dnpar2)));

    dT1dX = coeff1*((2.0*F70-F71-F7_1)+I*(2.0*I70-I71));
    T1 = XX*dT1dX;
    dT1dY = -2.0*coeff4*dT1dX-coeff2*((dF71dY+dF7_1dY) + I*(dI71dY));/*  sign Im term to be checked YP ******/
    dT1dTe = coeff2*((2.0*dF70dTe-dF71dTe-dF7_1dTe)+I*(2.0*dI70dTe-dI71dTe));
    dT1dnpar2 = coeff2*((2.0*dF70dnpar2 -dF71dnpar2-dF7_1dnpar2)+I*(2.0*dI70dnpar2-dI71dnpar2));

    dT2dX = coeff5*((16.0*(F91+F9_1)+4.0*(F92+F9_2)-12.0*F90)+I*(16.0*(I91)+4.0*(I92)-12.0*I90));
    T2 = XX*dT2dX;
    dT2dY = -4.0*Y_1*T2+coeff6*((16.0*(dF91dY+dF9_1dY)+4.0*(dF92dY+dF9_2dY)) +I*(16.0* dI91dY+4.0* dI92dY));
    dT2dTe = mu*T2+coeff6*((16.0*(dF91dTe+dF9_1dTe)+4.0*(dF92dTe+dF9_2dTe)-12.0*dF90dTe) +I*(16.0* dI91dTe+4.0* dI92dTe) -12.0*dI90dTe);
    dT2dnpar2 = coeff6*((16.0*(dF91dnpar2+dF9_1dnpar2)+4.0*(dF92dnpar2+dF9_2dnpar2)-12.0*dF90dnpar2)+I*(16.0* dI91dnpar2+4.0* dI92dnpar2-12.0*dI90dnpar2));


/* L. Colas 11-02-2004 */
/* the sign of dM0dX is not clearly established */
         
    dM0dX = Y_1*(-muF7_11+muF701+I*muI701);
    M0 = XX*dM0dX;
    dM0dY = coeff4*(-dmuF7_11dY-dM0dX);
    dM0dTe = coeff4*(-dmuF7_11dTe+dmuF701dTe+I*dmuI701dTe);
    dM0dnpar2 = coeff4*(-dmuF7_11dnpar2+dmuF701dnpar2+I*dmuI701dnpar2);


/* The sign of M1 is not clear */

    dM1dX = coeff7*((2.0*F911+6.0*F9_11+2.0*F9_21-3.0*F901)+I*(2.0*I911-3.0*I901));
    M1 = XX*dM1dX;
    dM1dY = -3.0*M1*Y_1+coeff8*((2.0*dF911dY+6.0*dF9_11dY+2.0*dF9_21dY)+I*(2.0*dI911dY));
    dM1dTe = coeff8*((2.0*dF911dTe+6.0*dF9_11dTe+2.0*dF9_21dTe   -3.0*dF901dTe)+I*(2.0*dI911dTe-3.0*dI901dTe));
    dM1dnpar2 = coeff8*((2.0*dF911dnpar2+6.0*dF9_11dnpar2+2.0*dF9_21dnpar2-3.0*dF901dnpar2)+I*(2.0*dI911dnpar2-3.0*dI901dnpar2)); 


/* L. Colas 11-02-2004 */
/* the sign of dN0dX is not clearly established */

    dN0dX = Y_1*((muF711-muF701)+I*(muI711-muI701));
    N0 = XX*dN0dX;
    dN0dY = coeff4*(dmuF711dY-dN0dX+I*dmuI711dY);
    dN0dTe = coeff4*((dmuF711dTe-dmuF701dTe)+I*(dmuI711dTe-dmuI701dTe));
    dN0dnpar2 = coeff4*(dmuF711dnpar2-dmuF701dnpar2) + I*(dmuI711dnpar2-dmuI701dnpar2);/*  ligne ˆ tester YP */


/* The sign of N1 is not clear */

    dN1dX = coeff7*((-2.0*F9_11-6.0*F911-2.0*F921+3.0*F901)+I*(-6.0*I911-2.0*I921+3.0*I901));
    N1 = XX*dN1dX;
    dN1dY = -3.0*N1*Y_1+coeff8*((-2.0*dF9_11dY-6.0*dF911dY-2.0*dF921dY) +I*(-6.0*dI911dY-2.0*dI921dY));
    dN1dTe = coeff8*((-2.0*dF9_11dTe-6.0*dF911dTe-2.0*dF921dTe+3.0*dF901dTe) +I*(-6.0*dI911dTe-2.0*dI921dTe+3.0*dI901dTe));
    dN1dnpar2 = coeff8*((-2.0*dF9_11dnpar2-6.0*dF911dnpar2-2.0*dF921dnpar2+3.0*dF901dnpar2)+I*(-6.0*dI911dnpar2-2.0*dI921dnpar2+3.0*dI901dnpar2)); 

         
    Nperp2 = Nperp*Nperp;
    RR = R0+Nperp2*(R1+Nperp2*R2);
    L = L0+Nperp2*(L1+Nperp2*L2);
    S = 0.5*(RR+L);
    P = P0+Nperp2*(P1+Nperp2*P2);
    T = Nperp2*(T1+Nperp2*T2);
    M = M0+Nperp2*M1;
    N = N0+Nperp2*N1;
   
    dRdX = dR0dX+Nperp2*(dR1dX+Nperp2*dR2dX);
    dLdX = dL0dX+Nperp2*(dL1dX+Nperp2*dL2dX);
    dPdX = dP0dX+Nperp2*(dP1dX+Nperp2*dP2dX);
    dTdX =       Nperp2*(dT1dX+Nperp2*dT2dX);
    dMdX = dM0dX+Nperp2*dM1dX;
    dNdX = dN0dX+Nperp2*dN1dX;

    dRdY = dR0dY+Nperp2*(dR1dY+Nperp2*dR2dY);
    dLdY = dL0dY+Nperp2*(dL1dY+Nperp2*dL2dY);
    dPdY = dP0dY+Nperp2*(dP1dY+Nperp2*dP2dY);
    dTdY =       Nperp2*(dT1dY+Nperp2*dT2dY);
    dMdY = dM0dY+Nperp2*dM1dY;
    dNdY = dN0dY+Nperp2*dN1dY;
        
    dRdTe = dR0dTe+Nperp2*(dR1dTe+Nperp2*dR2dTe);
    dLdTe = dL0dTe+Nperp2*(dL1dTe+Nperp2*dL2dTe);
    dPdTe = dP0dTe+Nperp2*(dP1dTe+Nperp2*dP2dTe);
    dTdTe =        Nperp2*(dT1dTe+Nperp2*dT2dTe);
    dMdTe = dM0dTe+Nperp2*dM1dTe;
    dNdTe = dN0dTe+Nperp2*dN1dTe;

    dRdnpar2 = dR0dnpar2+Nperp2*(dR1dnpar2+Nperp2*dR2dnpar2);
    dLdnpar2 = dL0dnpar2+Nperp2*(dL1dnpar2+Nperp2*dL2dnpar2);
    dPdnpar2 = dP0dnpar2+Nperp2*(dP1dnpar2+Nperp2*dP2dnpar2);
    dTdnpar2 =           Nperp2*(dT1dnpar2+Nperp2*dT2dnpar2);
    dMdnpar2 = dM0dnpar2+Nperp2*dM1dnpar2;
    dNdnpar2 = dN0dnpar2+Nperp2*dN1dnpar2;


/* Dielectric tensor for electrons, STIX frame */
/* Marco BRAMBILLA, "Kinetic theory of plasma waves" 
	equation (24.1) */
   
    Xxx[0] = S;
    Xxy[0] = 0.5*I*(L-RR);
    Xxz[0] = 0.5*Npar*Nperp*(M+N);
    Xyy[0] = S-2.0*T;
    Xyz[0] = 0.5*I*Npar*Nperp*(M-N);
    Xzz[0] = P;

/* Ionic susceptibility is negligible at high frequencies */
        
    for (is = 1;is < ns + 1;is++) {
        Xxx[is] = 0.0;
        Xxy[is] = 0.0;
        Xxz[is] = 0.0;
        Xyy[is] = 0.0;
        Xyz[is] = 0.0;
        Xzz[is] = 0.0;
    }
 
/* derivatives of the dielectric tensor for electrons, STIX frame */

    dXxxdNperp[0] = Nperp*(R1+L1+2.0*Nperp2*(R2+L2));
    dXxydNperp[0] = I*Nperp*(L1-R1+2.0*Nperp2*(L2-R2));
    dXxzdNperp[0] = Npar*(0.5*(M+N)+Nperp2*(M1+N1));
    dXyydNperp[0] = dXxxdNperp[0]-4.0*Nperp*(T1+2.0*Nperp2*T2);
    dXyzdNperp[0] = I*Npar*(0.5*(M-N)+Nperp2*(M1-N1));
    dXzzdNperp[0] = 2.0*Nperp*(P1+2.0*Nperp2*P2);        

    dXxxdNpar[0] = Npar*(dRdnpar2+dLdnpar2);
    dXxydNpar[0] = Npar*I*(dLdnpar2-dRdnpar2);
    dXxzdNpar[0] = npar2*Nperp*(dMdnpar2+dNdnpar2)+0.5*Nperp*(M+N);
    dXyydNpar[0] = dXxxdNpar[0]-4.0*Npar*dTdnpar2;
    dXyzdNpar[0] = I*npar2*Nperp*(dMdnpar2-dNdnpar2)+0.5*I*Nperp*(M-N);;
    dXzzdNpar[0] = 2.0*Npar*dPdnpar2;

    dXxxdbetath[0] = betath[0]*(dRdTe+dLdTe);
    dXxydbetath[0] = betath[0]*I*(dLdTe-dRdTe);
    dXxzdbetath[0] = betath[0]*Npar*Nperp*(dMdTe+dNdTe);
    dXyydbetath[0] = 2.0*betath[0]*(0.5*(dRdTe+dLdTe)-2.0*dTdTe);
    dXyzdbetath[0] = betath[0]*I*Npar*Nperp*(dMdTe-dNdTe);
    dXzzdbetath[0] = 2.0*betath[0]*dPdTe;

    dXxxdwcn[0] = 0.5*(dRdY+dLdY);
    dXxydwcn[0] = 0.5*I*(dLdY-dRdY);
    dXxzdwcn[0] = 0.5*Npar*Nperp*(dMdY+dNdY);
    dXyydwcn[0] = 0.5*(dRdY+dLdY)-2.0*dTdY;
    dXyzdwcn[0] = 0.5*I*Npar*Nperp*(dMdY-dNdY);
    dXzzdwcn[0] = dPdY;
 
    dXxxdwpn2[0] = 0.5*(dRdX+dLdX);
    dXxydwpn2[0] = 0.5*I*(dLdX-dRdX);
    dXxzdwpn2[0] = 0.5*Npar*Nperp*(dMdX+dNdX);
    dXyydwpn2[0] = 0.5*(dRdX+dLdX)-2.0*dTdX;
    dXyzdwpn2[0] = 0.5*I*Npar*Nperp*(dMdX-dNdX);
    dXzzdwpn2[0] = dPdX;    

/* Ionic susceptibility is negligible at high frequencies */
        
    for (is = 1;is < ns + 1; is++) {
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
        dXyydwpn2[is] =0.0;
        dXyzdwpn2[is] = 0.0;
        dXzzdwpn2[is] = 0.0;    
    }
     
    buildXstruc(X,ns,raymagnetic,dNpardx,dNperpdx,dwcndx,dwpn2dx,dbetathdx,Xxx,Xxy,Xxz,Xyy,Xyz,Xzz,dXxxdNperp,dXxydNperp,dXxzdNperp,dXyydNperp,dXyzdNperp,dXzzdNperp,dXxxdNpar,dXxydNpar,dXxzdNpar,dXyydNpar,dXyzdNpar,dXzzdNpar,dXxxdbetath,dXxydbetath,dXxzdbetath,dXyydbetath,dXyzdbetath,dXzzdbetath,dXxxdwcn,dXxydwcn,dXxzdwcn,dXyydwcn,dXyzdwcn,dXzzdwcn,dXxxdwpn2,dXxydwpn2,dXxzdwpn2,dXyydwpn2,dXyzdwpn2,dXzzdwpn2);
}



void Shka(z,a,RF5,RF7,RF9,dRF5dz,dRF7dz,dRF9dz,dRF3da,dRF5da,dRF7da,dRF9da,dRF11da)
double z,a;
double *RF5,*RF7,*RF9,*dRF5dz,*dRF7dz,*dRF9dz,*dRF3da,*dRF5da,*dRF7da,*dRF9da,*dRF11da;
{

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Real part of Shkarovsky functions F_q(z,a)
%% for q = 1.5 2.5 3.5, along with their partial derivatives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/

    double S0, S1, S2, S3, S4, S5, S6;
    double dS1dz, dS2dz, dS3dz, dS4dz, dS5dz, dS6dz; 
    double dS1da, dS2da, dS3da, dS4da, dS5da;
    double F1, F2, F3, F4, F5, F6, dF1, dF2, dF3, dF4, dF5, dF6;
    double d2F1, d2F2, d2F3, d2F4, d2F5;
    double qmax, limit, expo, oldcoeff, az1, terme, terme1, nmax, z_a, coeff;
    double phi2, phi, psi, rZ1, rZ2;
    double Cqj[1000];
    double daw;
    
    int nb, n, compteur;
    static double sqrttwoe_6 = 1.414e-6;
/* LC 08/10/2006 : Zfried replaced with ZfriedConte */
    double complex Z1, Z2;


/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Asymptotic form
%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
%% formula (35) & (36)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

    qmax = 6.0;
    limit = 10*sqrt(a*a+qmax*qmax);
    nb = (int) limit;
    nb = ((nb) > (1000) ? (1000) : (nb)); /* nb is limited to 1000 */

    if ((fabs(z-a)>10.0*limit)&(a>sqrttwoe_6)) {
		for (n = 0;n<nb;n++) {
			Cqj[n] = 1.0;
		}
	      	oldcoeff = 1.0;     
	      	compteur = 1; /* !! = j+1 in Robinson formula !! */
	      	az1 = 1.0/(a-z);
      		terme = az1;
		/* S1 = 0.0; */
		S2 = 0.0;
		S3 = 0.0; 
		S4 = 0.0; /* S5 = 0.0; S6 = 0.0; */
		/* dS1dz = 0.0 ; */
		dS2dz = 0.0;
		dS3dz = 0.0;
		dS4dz = 0.0; /* dS5dz = 0.0; dS6dz = 0.0; */
		dS1da = 0.0;
		dS2da = 0.0;
		dS3da = 0.0; 
		dS4da = 0.0;
		dS5da = 0.0;
      
		while (((Cqj[0]/oldcoeff)<limit)&(compteur<nb-qmax)& (fabs(terme)>0.0)) {

/* S1- = (Cqj[0]*terme); */
         		S2 -= (Cqj[1]*terme);
         		S3 -= (Cqj[2]*terme);
			    S4 -= (Cqj[3]*terme);
/* S5- = (Cqj[4]*terme); */        
/* S6- = (Cqj[5]*terme); */
        		terme *= az1;
         		terme1 = -compteur*terme;      
/* dS1dz+ = (Cqj[0]*terme1); */
         		dS2dz += (Cqj[1]*terme1);
         		dS3dz += (Cqj[2]*terme1);
         		dS4dz += (Cqj[3]*terme1);
/* dS5dz+ = (Cqj[4]*terme1);*/
/* dS6dz+ = (Cqj[5]*terme1);*/
         		terme1 *= ((compteur+1.0)*az1);        
		        dS1da += (Cqj[1]*terme1);
		        dS2da += (Cqj[2]*terme1);
		        dS3da += (Cqj[3]*terme1);
			    dS4da += (Cqj[4]*terme1);
                dS5da += (Cqj[5]*terme1);
        		oldcoeff = Cqj[0];
	/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% Update coefficients
	%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
	%% formula (36)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
			for (n = 0;n<nb-compteur;n++) {
				Cqj[n] = Cqj[n]*(0.5+compteur+n)+a*Cqj[n+1];
			}
			compteur++;		
	      } /* end while */
   
	}	/* endif */

	/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% value for a = 0
	%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
	%% formula (3)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

	if (a <= sqrttwoe_6) {
                Fdnest(z,5,&S6,&dS6dz);
		Fdnest(z,4,&S5,&dS5dz);
		Fdnest(z,3,&S4,&dS4dz);
		Fdnest(z,2,&S3,&dS3dz);
		Fdnest(z,1,&S2,&dS2dz);
		Fdnest(z,0,&S1,&dS1dz);
		dS1da = dS2dz-dS1dz;
	   	dS2da = dS3dz-dS2dz;
   		dS3da = dS4dz-dS3dz;
		dS4da = dS5dz-dS4dz;
                dS5da = dS6dz-dS5dz;
 	}

	/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%% Series expansion in a
	%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
	%% formula (10)
	%% valid for small a
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

	if ((a>sqrttwoe_6)&(a <= 9.0)&(fabs(z-a)>6.0)&(fabs(z-a)<10*limit)) {
		if (a<=1.0) { /* some optimization for rel. error < 1e-12 */
			nmax = 13;
		} else if (a<=3) {
			nmax = 22;
		} else {
			nmax = 37;
		}
   		z_a = z-a;

                Fdnest(z_a,nmax+5,&F6,&dF6);
		Fdnest(z_a,nmax+4,&F5,&dF5);
		Fdnest(z_a,nmax+3,&F4,&dF4);
		Fdnest(z_a,nmax+2,&F3,&dF3);
		Fdnest(z_a,nmax+1,&F2,&dF2);
		Fdnest(z_a,nmax  ,&F1,&dF1);

		/* S1 = 0.0; */
		S2 = 0.0;
		S3 = 0.0;
		S4 = 0.0; /* S5 = 0.0; S6 = 0.0; */
		/* dS1dz = 0.0; */
		dS2dz = 0.0;
		dS3dz = 0.0;
		dS4dz = 0.0; /* dS5dz = 0.0; dS6dz = 0.0; */ 
		dS1da = 0.0;
		dS2da = 0.0;
		dS3da = 0.0;
		dS4da = 0.0;
		dS5da = 0.0;

		for (n = nmax;n>0;n--) {
			coeff = a/n;
			/* S1 = coeff*(S1+F1); */
			S2 = coeff*(S2+F2);
			S3 = coeff*(S3+F3);
                        S4 = coeff*(S4+F4);
                        /* S5 = coeff*(S5+F5);
                     S6 = coeff*(S6+F6); */
			/* dS1dz = coeff*(dS1dz+dF1) */;
			dS2dz = coeff*(dS2dz+dF2);
			dS3dz = coeff*(dS3dz+dF3);
			dS4dz = coeff*(dS4dz+dF4);
			/* dS5dz = coeff*(dS5dz+dF5);
                           dS6dz = coeff*(dS6dz+dF6); */
			dS1da = coeff*((dF2-dF1)+dS1da);
			dS2da = coeff*((dF3-dF2)+dS2da);
      			dS3da = coeff*((dF4-dF3)+dS3da);
			dS4da = coeff*((dF5-dF4)+dS4da);
                        dS5da = coeff*((dF6-dF5)+dS5da);
			/* F6 = F5;*/
                        F5 = F4;
			F4 = F3;
			F3 = F2;
			F2 = F1;
			dF6 = dF5;
			dF5 = dF4;
			dF4 = dF3;
			dF3 = dF2;
			dF2 = dF1;
			Fdnest(z_a,n-1,&F1,&dF1);
		}   /* end for*/

		expo = exp(-a);
		/* S1 = expo*(S1+F1); */
		S2 = expo*(S2+F2);
		S3 = expo*(S3+F3);
                S4 = expo*(S4+F4);
                /* S5 = expo*(S5+F5);
               S6 = expo*(S6+F6);*/
		/* dS1dz = expo*(dS1dz+dF1); */
		dS2dz = expo*(dS2dz+dF2);
		dS3dz = expo*(dS3dz+dF3);
		dS4dz = expo*(dS4dz+dF4);
		/* dS5dz = expo*(dS5dz+dF5); */
                /* dS6dz = expo*(dS6dz+dF6); */
		dS1da = expo*(dS1da+(dF2-dF1));
		dS2da = expo*(dS2da+(dF3-dF2));
   		dS3da = expo*(dS3da+(dF4-dF3));
   		dS4da = expo*(dS4da+(dF5-dF4));
                dS5da = expo*(dS5da+(dF6-dF5));

	} /* end if ((a>0.0)&(a<=9.0)&(fabs(z-a)>6.0)&(fabs(z-a)<10*limit)) */

	if ((a>0.0)&(a<=9.0)&(fabs(z-a)<=6.0)) {
		if (a<=1.0) {/* some optimization for rel. error < 1e-12 */
			nmax = 13;
		} else if (a<=3) {
			nmax = 22;
		} else {
			nmax = 37;
		}
 		z_a = z-a;
   		coeff = 1.0;
		Fdnest(z_a,0,&F1,&dF1);
		F2 = (1.0-z_a*F1)*0.66666666666666666667; /* use recursion relation */
		F3 = (1.0-z_a*F2)*0.4;
		F4 = (1.0-z_a*F3)*0.2857142857142857176;
		F5 = (1.0-z_a*F4)*0.22222222222222222222;
                F6 = (1.0-z_a*F5)*0.18181818181818181818;

		dF2 = F2-F1; /* use derivation relation */
		dF3 = F3-F2;
		dF4 = F4-F3;
		dF5 = F5-F4;
                dF6 = F6-F5;
		d2F1 = dF2-dF1; /* derivation relation again */
   		d2F2 = dF3-dF2;
   		d2F3 = dF4-dF3;
		d2F4 = dF5-dF4;
                d2F5 = dF6-dF5;
		/* S1 = F1; */
   		S2 = F2; 
		S3 = F3; 
		S4 = F4; 
		/* S5 = F5;
               S6 = F6; */ 
		/* dS1dz = dF1; */
   		dS2dz = dF2;
		dS3dz = dF3; 
		dS4dz = dF4; 
		/* dS5dz = dF5;
               dS6dz = dF6; */
		dS1da = d2F1;
		dS2da = d2F2;
		dS3da = d2F3;
		dS4da = d2F4;
                dS5da = d2F5;
		for (n = 1;n<=nmax;n++) {
		        /* F1 = F2; */ 
			F2 = F3;
			F3 = F4;
			F4 = F5;
			F5 = F6;
		        dF1 = dF2;
			dF2 = dF3;
			dF3 = dF4;
			dF4 = dF5;
			dF5 = dF6;
		        d2F1 = d2F2;
			d2F2 = d2F3;
			d2F3 = d2F4;
			d2F4 = d2F5;
        
        		F6 = (1.0-z_a*F6)/(n+5.5);
		        dF6=F6-F5;
		        d2F5 = dF6-dF5;
		        coeff*=(a/n);
		        /* S1 += (coeff*F1); */
		        S2 += (coeff*F2);
			S3 += (coeff*F3); 
			S4 += (coeff*F4);
			/* S5 += (coeff*F5);
                           S6 += (coeff*F6); */
		        /* dS1dz += (coeff*dF1); */
		        dS2dz += (coeff*dF2);
			dS3dz += (coeff*dF3); 
			dS4dz += (coeff*dF4); 
			/* dS5dz += (coeff*dF5);
                      dS6dz += (coeff*dF6); */
		        dS1da += (coeff*d2F1); 
			dS2da += (coeff*d2F2);
		        dS3da += (coeff*d2F3);
			dS4da += (coeff*d2F4);
                        dS5da += (coeff*d2F5);
		}
		expo = exp(-a);

		/* S1 *= expo; */
   		S2 *= expo;
   		S3 *= expo;
   		S4 = expo;
   		/*S5 *= expo;
               S6 *= expo;
		dS1dz *= expo; */
   		dS2dz *= expo;
   		dS3dz *= expo;
   		dS4dz *= expo;
   		/*   dS5dz *= expo;
                  dS6dz *= expo; */		
		dS1da *= expo;
   		dS2da *= expo;
   		dS3da *= expo;
		dS4da *= expo;
                dS5da *= expo;

	} /* end if ((a>0.0)&(a<=9.0)&(fabs(z-a)<=6.0)) */  


	/* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	   %% Recursion formula
	   %% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
 	   %% formula (10)
	   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */


	if ((a>9.0)&(fabs(z-a)<=(10*limit))) {
   		phi2 = a-z;
   		psi = sqrt(a);
		/*   %%% Sign conventions for phi => 
   		     %%% See Brambilla p. 146 formula (16.51) */
   
		/*phi = conj(sqrt(phi2)); */
		if (phi2>0.0) {
			phi = sqrt(phi2);
			/* Z is real, contains no imaginary part */
			
/*			Z1 = -2.0*dawson(psi-phi);
/*			Z2 = -2.0*dawson(-psi-phi); 
/*                        S0 = -0.5*(Z1+Z2)/phi; /* F1_2 */
/*			S1 = 0.5*(Z2-Z1)/psi; /* F3_2 */
			dawson(psi-phi,&daw);
			rZ1 = -2.0*daw;
			dawson(-psi-phi,&daw);
			rZ2 = -2.0*daw; 
                        S0 = -0.5*(rZ1+rZ2)/phi; /* F1_2 */
			S1 = 0.5*(rZ2-rZ1)/psi; /* F3_2 */

                } else if (phi2 == 0.0) {
                        S0 = 0.0;
			dawson(psi,&daw);
                        S1 = 2.0*daw/psi;
		} else { /* (phi2<0.0) */
			phi = -sqrt(-phi2);
/*			Zfried (psi,-phi,&rZ1,&iZ1);
			Zfried (-psi,-phi,&rZ2,&iZ2); */
			/* only the real part is retained */
/*			S0 = -0.5*(iZ1+iZ2)/phi; /* F1_2 */
/*			S1 = 0.5*(rZ2-rZ1)/psi; /* F3_2 */
			ZFriedConte(psi-I*phi,&Z1);
			ZFriedConte(-psi-I*phi,&Z2);
			S0 = -0.5*(cimag(Z1)+cimag(Z2))/phi; /* F1_2 */
			S1 = 0.5*(creal(Z2)-creal(rZ1))/psi; /* F3_2 */

		}
  
 		S2 = (1.0+phi2*S0-0.5*S1)/a; /* F_5/2 */
 		S3 = (1.0+phi2*S1-1.5*S2)/a; /* F_7/2 */
   		S4 = (1.0+phi2*S2-2.5*S3)/a; /* F_9/2 */
		S5 = (1.0+phi2*S3-3.5*S4)/a; /* F_11/2 */
                S6 = (1.0+phi2*S4-4.5*S5)/a; /* F_13/2 */ 
		dS1dz = S1-S0;
   		dS2dz = S2-S1;
   		dS3dz = S3-S2;
   		dS4dz = S4-S3;
		dS5dz = S5-S4;
                dS6dz = S6-S5;
		dS1da = dS2dz-dS1dz;
   		dS2da = dS3dz-dS2dz;
   		dS3da = dS4dz-dS3dz;
		dS4da = dS5dz-dS4dz;
                dS5da = dS6dz-dS5dz;

	} /* end if ((a>9.0)&(fabs(z-a)<=(10*limit))) */

/* *RF3 = S1; */
	*RF5 = S2;
	*RF7 = S3;
	*RF9 = S4;
/* *RF11 = S5; */
/* *RF13 = S6; */
/* *dRF3dz = dS1dz; */
	*dRF5dz = dS2dz;
	*dRF7dz = dS3dz;
	*dRF9dz = dS4dz;
/* *dRF11dz = dS5dz; */
/* *dRF13dz = dS6dz; */
	*dRF3da  = dS1da;
	*dRF5da  = dS2da;
	*dRF7da  = dS3da;
	*dRF9da  = dS4da;
    *dRF11da = dS5da;

} 







void ImShka(double z, double a, 
             double * IF5, double * IF7, double * IF9,
	     double * dIF5dz, double * dIF7dz, double * dIF9dz,
             double * dIF3da, double * dIF5da, double * dIF7da, 
             double * dIF9da, double * dIF11da) {

double IS1, IS3, IS5, IS7, IS9, IS11, IS13;
double dIS3dz, dIS5dz, dIS7dz, dIS9dz, dIS11dz, dIS13dz;
double dIS3da, dIS5da, dIS7da, dIS9da, dIS11da;
double absz, sqrtone_za, argum, arg1, arg2, bes0, bes1, bes2;
static double twosqrtpi = 3.5449077018110318818;
static double sqrttwoe_6 = 1.414e-6;

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Imaginary part of Shkarovsky function F_q+3/2(z,a)
%% along with its first partial derivatives.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
%% Formula (42) and (43)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

   if (z>=a) {
   /* No absorption */
	/* IS1 = 0.0 ; IS3 = 0.0 */
	IS5 = 0.0; IS7 = 0.0;  IS9 = 0.0; /* IS11 = 0.0; IS13 = 0.0; */
	/* dIS3dz = 0.0 */
   	dIS5dz = 0.0;
	dIS7dz = 0.0; 
	dIS9dz = 0.0; /* dIS11dz = 0.0; dIS13dz = 0.0*/ 
   	dIS3da = 0.0;
	dIS5da = 0.0;
	dIS7da = 0.0;
	dIS9da = 0.0;
	dIS11da = 0.0;
   } else if ((z<a) & (a<=sqrttwoe_6)) {
   /* a==0 Shkarovski function => Dnestrovski function %% */
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
%% Formula (42)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
      absz = -z;
      IS3 = -twosqrtpi*sqrt(absz)*exp(-absz);
      IS1 = IS3 *0.5/absz;
      IS5 = IS3 *absz*0.66666666666666666667;
      IS7 = IS5 *absz*0.4;
      IS9 = IS7 *absz*0.2857142857142857176;
      IS11 = IS9 *absz*0.22222222222222222222;
      IS13 = IS11*absz*0.18181818181818181818;
      dIS3dz = IS3 - IS1; /* P.A. Robinson formula (27) */
      dIS5dz = IS5 - IS3;
      dIS7dz = IS7 - IS5;
      dIS9dz = IS9 - IS7;
      dIS11dz = IS11 - IS9;
      dIS13dz = IS13 - IS11;
      dIS3da = dIS5dz - dIS3dz; /* P.A. Robinson formula (5) and (27) */
      dIS5da = dIS7dz - dIS5dz;
      dIS7da = dIS9dz - dIS7dz;
      dIS9da = dIS11dz - dIS9dz;
      dIS11da = dIS13dz - dIS11dz;
   } else if ((z < a) & (a > sqrttwoe_6)) {
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
%% Formula (43)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
      sqrtone_za = sqrt(1.0-z/a);
      argum = 2.0*a*sqrtone_za; /* Argument of modified Bessel function */
      arg1 = 1.0/argum;
      if (argum<25.0) { /* argum<25.0 => complete formula */
         /* Normalization factor sqrt(2*argum/pi) for modified Bessel
          functions I_n+1/2 is directly incorporated here */
         IS1 = -twosqrtpi*exp(z-2.0*a)*sqrt(a);
         IS3 = IS1 *sqrtone_za;
         IS5 = IS3 *sqrtone_za;
         IS7 = IS5 *sqrtone_za;
         IS9 = IS7 *sqrtone_za;
         IS11 = IS9 *sqrtone_za;
         IS13 = IS11*sqrtone_za;
         bes0 = cosh(argum)*arg1; /* Normalized modified Bessel func. I_-1/2 */
         IS1 *= bes0; 
         bes1 = sinh(argum)*arg1; /* Normalized modified Bessel func. I_+1/2 */
         IS3 *= bes1;
         arg2 = 0.5*argum*argum;
         if (argum>4.0e-2) { /* Normalized modified Bessel func. I_3/2 */
            bes2 = bes0-bes1*arg1; /* Large argument => use recurrence relation */
         } else { 
            /* Small argument => use series expansion */
            /* Precision of 1e-12 on I_3/2 is achieved */
            bes2 = argum*0.33333333333333333*
            (1.0+0.2*arg2*
            (1.0+arg2*0.0714285714285714294));
         }
         IS5 *= bes2;
         bes0 = bes1;
	 bes1 = bes2;
         if (argum>4.0e-1) { /* Normalized modified Bessel function I_5/2 */
            bes2 = bes0-3.0*bes1*arg1;
         } else {
            bes2 = argum*argum*0.06666666666666666*
            (1.0+arg2*0.1428571428571428588*
            (1.0+arg2*0.05555555555555555*
            (1.0+arg2*0.030303030303030303*
            (1.0+arg2*0.0192307692307692322))));
         }
         IS7 *= bes2;
         bes0 = bes1; bes1=bes2;
         if (argum>1.2) { /* Normalized modified Bessel function I_7/2 */
            bes2 = bes0-5.0*bes1*arg1;
         } else {
            bes2 = argum*argum*argum*0.0095238095238095254*
            (1.0+arg2*0.111111111111111111*
            (1.0+arg2*0.045454545454545454*
            (1.0+arg2*0.0256410256410256413*
            (1.0+arg2*0.016666666666666666*
            (1.0+arg2*0.0117647058823529404*
            (1.0+arg2*0.0087719298245614034))))));
         }
         IS9 *= bes2;
         bes0 = bes1;
	 bes1 = bes2;
	 if (argum>1.9) {
            bes2 = bes0-7.0*bes1*arg1;
         } else { /* Normalized modified Bessel function I_9/2 */
            bes2 = argum*argum*argum*argum*0.001058201058201058201*
            (1.0+arg2*0.090909090909090909*
            (1.0+arg2*0.0384615384615384655*
            (1.0+arg2*0.0222222222222222222*
            (1.0+arg2*0.01470588235294117694*
            (1.0+arg2*0.0105263157894736846*
            (1.0+arg2*0.0079365079365079364*
            (1.0+arg2*0.0062111801242236022)))))));
         }
         IS11 *= bes2;
         bes0 = bes1;
	 bes1 = bes2;
	 if (argum>3.4) {
            bes2 = bes0-9.0*bes1*arg1;
         } else { /* Normalized modified Bessel function I_11/2 */
            bes2 = argum*argum*argum*argum*argum*9.62000962000962e-5*
            (1.0+arg2*0.0769230769230769250*
            (1.0+arg2*0.033333333333333333333333*
            (1.0+arg2*0.01960784313725490206*
            (1.0+arg2*0.0131578947368421042*
            (1.0+arg2*0.0095238095238095254*
            (1.0+arg2*0.0072463768115942032*
            (1.0+arg2*0.0057142857142857142*
            (1.0+arg2*0.0046296296296296295*
            (1.0+arg2*0.0038314176245210725)))))))));
         }
         IS13 *= bes2;

      } else { 
/* (argum>=25.0), use asymptotic expression for Shkarovski function */
         arg2 = sqrt(a-z)-sqrt(a);
         IS1 = -0.25*twosqrtpi*exp(-arg2*arg2)/sqrt(a-z);
         IS3 = IS1 *sqrtone_za;
         IS5 = IS3 *sqrtone_za;
         IS7 = IS5 *sqrtone_za;
         IS9 = IS7 *sqrtone_za;
         IS11 = IS9 *sqrtone_za;
         IS13 = IS11*sqrtone_za;
         IS5 *= (1.0-arg1);
         IS7 *= (1.0+3.0*arg1*(-1.0+arg1));
         IS9 *= (1.0+arg1*(-6.0+15.0*arg1*(1.0-arg1)));
         IS11 *= (1.0+arg1*(-10.0+arg1*(45.0+105.0*arg1*(arg1-1.0))));
         IS13 *= (1.0+arg1*(-15.0+arg1*(105.0+arg1*(-420.0+945.0*arg1*(1.0-arg1))))); 
      } /* end if (argum>=25) */
      dIS3dz = IS3 -IS1; /* P.A. Robinson formula (27) */
      dIS5dz = IS5 -IS3;
      dIS7dz = IS7 -IS5;
      dIS9dz = IS9 -IS7;
      dIS11dz = IS11-IS9;
      dIS13dz = IS13-IS11;
      dIS3da = dIS5dz -dIS3dz; /* P.A. Robinson formula (5) and (27) */
      dIS5da = dIS7dz -dIS5dz;
      dIS7da = dIS9dz -dIS7dz;
      dIS9da = dIS11dz-dIS9dz;
      dIS11da = dIS13dz-dIS11dz;
   } /* end if (a>sqrttwoe_6) &(z<a) */

   /* * IF1 = IS1;
   * IF3 = IS3; */   
   * IF5 = IS5;
   * IF7 = IS7;
   * IF9 = IS9;
   /* 
   * IF11 = IS11; 
   * IF13 = IS13;
   * dIF3dz = dIS3dz; */   
   * dIF5dz = dIS5dz;
   * dIF7dz = dIS7dz;
   * dIF9dz = dIS9dz;
   /* * dIF11dz = dIS11dz; 
    * dIF13dz = dIS13dz; */
   * dIF3da = dIS3da;
   * dIF5da = dIS5da;
   * dIF7da = dIS7da;
   * dIF9da = dIS9da;
   * dIF11da = dIS11da;

}


void Fdnest(z,q,F,dFdz)
double z;
int q;
double *F,*dFdz;

{
/* Computes real part of Dnestrovskii's function F_q+3/2(z), for q>=0;
 along with its first derivative for q>=0 */

    double Fr,dFrdz,oldFr,ksi,multi,z_1,expo,lmt1,lmt3,daw;
    int n, nmx,nnmx,nnnmx;
    static double twosqrtpi = 3.54490770181103188818;

    static int taille = 46;
    static double limit1[46] = {-31.5,-34.6,-38.0,-39.7,-42.4,
                                -44.8,-47.3,-49.4,-51.4,-53.4,
                                -55.5,-57.5,-59.5,-61.5,-63.5,-65.5,-67.4,-68.7,-70.5,-72.6,-74.4,
                                -76.3,-77.5,-79.7,-81.8,-82.7,-84.8,-86.4,-87.7,-89.5,-91.6,-92.9,
                                -94.5,-96.6,-97.5,-99.6,-100.5,-102.6,-103.5,-105.5,-107.25,
                                -108.6,-110.7,-111.6,-113.7,-114.6};
    static double limit3[46] = {40.0,14.0,9.0,7.0,6.0,6.0,6.0,6.0,
                                6.2,6.0,7.0,7.0,6.5,7.5,7.5,
                                7.0,8.5,8.5,8.0,8.0,9.5,9.0,9.0,8.5,11.2,11.2,11.0,11.0,10.0,10.0,
                                13.5,13.5,13.2,13.0,13.0,12.5,12.0,12.0,11.5,11.0,10.7,17.0,17.0,16.5,
                                16.0,16.0};
    static double lmt2=0.0;
    static int nmax[46] = {31,33,36,36,38,39,41,42,43,44,45,46,47,48,
                           49,50,51,51,52,53,54,55,55,56,57,57,58,59,59,60,61,61,62,63,63,64,64,65,
                           65,66,67,67,68,68,69,69};
    static int nnmax[46] = {78,83,87,90,95,98,102,105,108,111,114,117,120,
                            123,126,129,132,134, 136,139,142,144,146,149,152,153,156,158,160,162,165,
                            167,169,172,173,176,177,180,181,184,186,188,191,192,195,196};
    static int nnnmax[46] = {4,8,11,14,16,16,16,16,15,15,14,14,14,13,13,13,
                             12,12,12,12,11,11,11,11,10,10,10,10,10,10,9,9,9,9,9,9,9,9,9,9,9,8,8,8,8,8};

    if (q < taille) { /* optimized for relative error < 1e-12 on F */
        lmt1 = limit1[q+1];
        lmt3 = limit3[q+1];
        nmx = nmax[q+1];
        nnmx = nnmax[q+1];
        nnnmx = nnnmax[q+1];
    } else { 
/* not optimized, relative error of 1e-12 garantied for z<0 */
        lmt1 = -43.3891 - 1.5934*q - 5.0; /* apply a margin of 5 */
        lmt3 = limit3[taille];            
        nmx = (int)(22.1786+7.0234*sqrt(q));
        nnmx = (int) (100.0584 + 2.1494*q) + 10; /* apply a margin of 10 */
        nnnmx = nnnmax[taille];
    }

    if (z<lmt1) {
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Asymptotic approximation for |z+q|>>1
%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
%% Formula (32)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/
        z_1=1.0/z;
        Fr=0.0;
        dFrdz=0.0;
        multi=nmx+q-0.5;
        for (n = nmx;n > 1;n--) {
	    Fr = -z_1*multi*(1.0 + Fr);
            dFrdz = z_1*multi*(n*z_1 - dFrdz);
            multi--;
        }
	Fr = z_1*(1.0 + Fr);
	dFrdz = z_1*(dFrdz-z_1);

    } else if ((z >= lmt1) & (z < lmt2)) {
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Series development (unstable for positive z ?)
%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
%% Formula (30) for z<0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/
        z_1 = -z;
        Fr=0.0;
        dFrdz=0.0;
        multi=nnmx-0.5-q;
        for (n=nnmx;n>0;n--) {
            Fr=z_1/n*(1.0/multi+Fr);
            dFrdz=z_1/n*(1.0/multi/(multi+1.0)+dFrdz);
            multi--;
        }
        expo=exp(z);
/* !!!! Formula only valid for z<=0 
   !!!! Extra terms should be added for z>0 !!!! */
	
        Fr=-expo*(Fr+1.0/multi);
        dFrdz=-expo*(dFrdz+1.0/multi/(multi+1.0));

    } else if ((z >= lmt2) & (z < lmt3)) {
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Recurrence relation (unstable for large q and z)
%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
%% Formula (19)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/   
/* First compute F_3/2 */

        if (z = 0.0) {
            ksi = sqrt(z);
            Fr = 2.0-twosqrtpi*ksi*erfc(ksi)*exp(z);
	} else {
            ksi = -sqrt(-z);
	    dawson(ksi,&daw);
            Fr = 2.0 - 4.0*ksi*daw;
        }
        
	/* Then apply recurrence relation F_q+1/2 => F_q+3/2
   ! recurrence relation becomes unstable for large |z| arguments ! */
    	oldFr = (1.0 - 0.5*Fr)/(z + 1.0e-16);
        for (n = 1;n <= q;n++) {
   	    if (n == q) {
	        oldFr=Fr;
            }     
            Fr = (1.0 - z*Fr)/(n + 0.5);
        }
        dFrdz=Fr-oldFr;

    } else { /*if (z>=lmt3) */
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Continued fraction (unstable for negative z)
%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
%% Formula (34)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/
        multi = q + 1.5 + nnnmx;
        Fr = 0.0;
        oldFr = 0.0;
        for (n = nnnmx;n > 0;n--) {
            Fr = n/(z + multi/(1.0 + Fr));
            multi--;
            oldFr = n/(z + multi/(1.0 + oldFr));
        }
        Fr = 1.0/(z + multi/(1.0 + Fr));
        multi--;
        dFrdz = Fr - 1.0/(z + multi/(1.0 + oldFr));  

    } /* end if z */

    *F = Fr;
    *dFdz = dFrdz;   
   
}



void ImFdnest(z,q,ImF,dImF)
double z;
int q; 
double *ImF,*dImF;
{
double IFdnest,dIFdz,absz,oldIF;
int n;
static double twosqrtpi = 3.5449077018110318818;

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [IF,dIFdz]=ImFdnest(z,q);
% Imaginary part of Dnestrovskii's function F_q+3/2(z), 
% for integer q>=0;
% along with its first derivative for q>=1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% P.A. Robinson, J. Math. Phys. vol. 27, N¡5, May 1986
%% Formula (42) for z<0 plus recursion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/

    if (z < 0.0) {
        absz=-z;
        IFdnest = -twosqrtpi*sqrt(absz)*exp(-absz);
        oldIF = IFdnest*0.5/absz;
        for (n = 1;n <= q;n++) {
            if (n == q) {
                oldIF = IFdnest;
            }
            IFdnest *= (absz/(n+0.5));
        }
        dIFdz = IFdnest - oldIF;
    } else {
        IFdnest = 0.0;
        dIFdz = 0.0;
   }
   *ImF = IFdnest;
   *dImF = dIFdz;
} 




