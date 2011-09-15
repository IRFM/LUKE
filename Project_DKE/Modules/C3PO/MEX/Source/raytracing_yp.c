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

struct polynomial_piecewise_0D {
    double  *data;
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
    mxChar  *form_d2fdrho2;
    double  *breaks_d2fdrho2;
    double  *coefs_d2fdrho2;
    double  *pieces_d2fdrho2;
    double  *order_d2fdrho2;
    double  *dim_d2fdrho2;
    mxChar  *orient_d2fdrho2;  
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

typedef struct polynomial_piecewise_0D pp_0D_format;
typedef struct polynomial_piecewise_1D pp_1D_format;
typedef struct polynomial_piecewise_2D pp_2D_format;

struct rayprofiles {
    double *Te;
    double *ne;
    double *zTi;
    double *zni;
    double *dTedY;
    double *dnedY;
    double **dzTidY;
    double **dznidY;
    double *d2TedY2;
    double *d2nedY2;
    double **d2zTidY2;
    double **d2znidY2;
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

struct distriparam {
    double *pn;
    int *npn;
    double *mhu;
    int *nmhu;
    double *ne_ref;
    double *betath_ref;
};

struct fluctparam {
	int *ne_nmodel;
    double **ne_model;
    double **ne_sigmar_max;
    double **ne_sigmar_hwhm;
    double **ne_sigmar_rho;
    double **ne_polmode;      
    double **ne_epsi_rho;      
    double **ne_epsi_theta;       
    double **ne_epsi_phi;       
    double **ne_lmin;      
    double **ne_mmin;    
    double **ne_nmin;    
    double **ne_lmax;      
    double **ne_mmax;    
    double **ne_nmax; 
    int **ne_nphase; 
	double **ne_phase;   
    int *B_nmodel;
	double **B_model;
    double **B_sigmar_max;
    double **B_sigmar_hwhm;
    double **B_sigmar_rho;
    double **B_polmode;      
    double **B_epsi_rho;      
    double **B_epsi_theta;       
    double **B_epsi_phi;       
    double **B_lmin;      
    double **B_mmin;    
    double **B_nmin;    
    double **B_lmax;      
    double **B_mmax;    
    double **B_nmax; 
    int **B_nphase;
	double **B_phase;      
};

struct raymagnetic {
    double *rn;
    double *drndY;
    double *Rn;
    double *dRndY;
	double *Zn;
    double *dZndY;
    double *Brhon;
    double *dBrhondY;
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
    double *rhorip;
    double *drhoripdY;        
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

struct raydistri {
    pp_1D_format f0_fit;
    pp_2D_format PSI_fit;
};

struct rayfluctuations {
    pp_0D_format L_rho;
    pp_1D_format xq_fit,xL_theta_fit,xL_perp_fit;
    pp_2D_format XL_phi_fit;
    pp_2D_format *B_sfx_fit,*B_sfy_fit,*B_sfz_fit;
    pp_2D_format Xcm_fit,Xcn_fit;
};

struct rayequil {
    pp_1D_format Te_fit,ne_fit,zTi_fit,zni_fit,dxstardpsin_fit;
    pp_2D_format x_fit,y_fit,Bx_fit,By_fit,BPHI_fit;	
};

typedef struct susceptibilitytensor susceptibilitytensor_format;
typedef struct rayparam rayparam_format;
typedef struct equilparam equilparam_format;
typedef struct fluctparam fluctparam_format;
typedef struct refractiveindex refractiveindex_format;
typedef struct raymagnetic raymagnetic_format;
typedef struct rayprofiles rayprofiles_format;
typedef struct rayfluctuations rayfluctuations_format;
typedef struct rayequil rayequil_format;
typedef struct distriparam distriparam_format;
typedef struct raydistri raydistri_format;

/* subroutines list */

void ppvald_1D();
void ppvald_2D();
void ppvali_2D();
void ray();
void rayindex();
void susceptibility();
void rayprocess();
void metrictensor();
double alphaphi_jd();
void coldtensor();
void dsolve();
void testparam();
void disprel();
void interpequil();
void interpequil_test();
void load_idealequil_test();
equilparam_format load_equil_param();
fluctparam_format load_fluct_param();
rayparam_format load_ray_param();
pp_0D_format load_value_0D();
pp_1D_format load_profile_1D();
pp_2D_format load_grid_2D();
distriparam_format load_distri_param();
double inf_norm();
double sgn();
void halftanh();
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
void polarization();
void build_raymagnetic();
void weakrelativistictensor();
void Shka();
void ImShka();
void Fdnest();
void ImFdnest();
void kperproots();
double complex matdot();


/* Input Arguments */

#define RAYPARAM_IN  prhs[0]
#define EQUIL_IN     prhs[1]
#define Y0_IN    prhs[2]
#define DISTRI_IN prhs[3]
#define FLUCT_IN prhs[4]
#define FLAG_IN prhs[5]


/* Output Arguments */

#define T_OUT   plhs[0]
#define Y_OUT   plhs[1]
#define Y_PROC  plhs[2]

#define MC 8
#define MPROC 25
#define SAFETY 0.8
#define PGROW 0.2
#define PSHRINK 0.25
#define PI 3.14159265358979
#define CLUM 299792458 /*Speed of light (m/s) */

/* Fehlberg coefficients fro the 45 Runge-Kutta integration */

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


void mexFunction(   int     nlhs, mxArray *plhs[], int     nrhs, const mxArray   *prhs[]) {
             
    rayparam_format rayparam;
    equilparam_format equilparam;
    fluctparam_format fluctparam;
    raymagnetic_format raymagnetic;
    rayprofiles_format rayprofiles;
    susceptibilitytensor_format X;
    rayfluctuations_format rayfluctuations;
    rayequil_format rayequil;
    distriparam_format distriparam;
    raydistri_format raydistri;
  
    double flag,flag_proc = 1;
    
    register int i,j;
    int flag_fluct = 1,flag_f0 = 1;
    int fmode,nss,iss;
    
    mxArray *tmp;
   
    double  *tout,*yout,*yproc;
    double  *toutp,*youtp;
    double  *y0,*y1,*yinit,*y0_in,*y0dot;
    double  tau_lim;
 
    register unsigned int  m,kk,ii=0;
    register int k=-1;
 
    int flag1,iimax=200000, kmax;
 
    double *s0,*s1,*s2,*s3,*s4,*s5,*s6;
    double *tempt,*temp0,*temp1,*temp2,*temp3,*temp4,*temp5,*temp6,*temp7;
 
    double ymax,tau,delta,h,hmax,hmin;
    
    double ydel[MC],ys[7];
    
    double t1,t2,ts,rho1,rho2,theta1,theta2,phi1,phi2,krho1,krho2,m1,m2,n1,n2,omega1,omega2;
    
    double rhodot,thetadot,phidot,krhodot,mdot,ndot,omegadot,Sdot;
    
    double S1,S2,S_step,Sdot1,Sdot2,Sdot3,Sdot4,Sdot5,Sdot6;
    
    double *rayproc,**temp_proc;
    double dS,depth=0.0,alpha1=0.0,alpha2,absphi;
    
    double alpha_rho,alpha_theta,alpha_phi,acc,krho1_dsolve;
    
    /* Check out input and output arguments */

    if (nrhs != 6) mexErrMsgTxt("Wrong number of input arguments for raytracing_yp.mex***");/* The number of input arguments is fixed */
    if (!mxIsStruct(prhs[0])) mexErrMsgTxt("1st input argument of raytracing_yp.mex*** must be a structure (rayparam)");
    if (!mxIsStruct(prhs[1])) mexErrMsgTxt("2nd input argument of raytracing_yp.mex*** must be a structure (equil_fit)");
    if (!mxIsStruct(prhs[3])) flag_f0 = 0;/* fourth input argument must be a structure for wave damping on a non-maxwellian distribution */
    if (mxIsEmpty(prhs[3])) flag_f0 = 0;/* if empty, wave damping on maxwellian distribution only */
    if (!mxIsStruct(prhs[4])) flag_fluct = 0;/* fifth input argument must be a structure for plasma fluctuations */
    if (mxIsEmpty(prhs[4])) flag_fluct = 0;/* if empty, no plasma fluctuations */

 
    if (nlhs < 2 || nlhs > 3) mexErrMsgTxt("Wrong number of output arguments for raytracing_yp.mex***");
    if (nlhs == 2) flag_proc = 0;/*flag for calculating additional ray data */

    
/*  
    double complex iBn,iBnp,iBnpp;   
    modBessel(-5.4,(double complex)(3.0 +1.2*I),&iBn,&iBnp,&iBnpp);
    mexPrintf("Bessel(-5.4,3.+1.2*i),Bp,Bpp:%g,%g,%g,%g,%g,%g\n",iBn,iBnp,iBnpp);
*/

    /* Get Input Arguments */
 
    rayparam = load_ray_param(RAYPARAM_IN);
    equilparam = load_equil_param(EQUIL_IN);           

    flag = *(mxGetPr(FLAG_IN));
    
    if ((flag_fluct == 1) && (abs(flag) > 0)) mexErrMsgTxt("Plasma fluctuations are incompatible with the analytical magnetic equilibrium option.");
    
    /*mexPrintf("flag : %g\n",flag);*/
    
    if (isinf(rayparam.tau_lim[0])) {
        tau_lim = -1.0;
    } else {
        tau_lim = rayparam.tau_lim[0];
    }
    kmax = (int)rayparam.kmax[0];  
        
    rayequil.dxstardpsin_fit = load_profile_1D(EQUIL_IN,"dxstardpsin_fit");
        
    if (equilparam.zZi[0] > 0) {/*Vacuum case otherwise (no density, temperature...)*/
        rayequil.Te_fit = load_profile_1D(EQUIL_IN,"Te_fit");
        rayequil.ne_fit = load_profile_1D(EQUIL_IN,"ne_fit");
        rayequil.zTi_fit = load_profile_1D(EQUIL_IN,"zTi_fit"); 
        rayequil.zni_fit = load_profile_1D(EQUIL_IN,"zni_fit");
    }
    
    rayequil.x_fit = load_grid_2D(EQUIL_IN,"x_fit",0);
    rayequil.y_fit = load_grid_2D(EQUIL_IN,"y_fit",0);
    rayequil.Bx_fit = load_grid_2D(EQUIL_IN,"Bx_fit",0);
    rayequil.By_fit = load_grid_2D(EQUIL_IN,"By_fit",0);
    rayequil.BPHI_fit = load_grid_2D(EQUIL_IN,"BPHI_fit",0);
    
    if (flag_f0 == 1) {
        distriparam = load_distri_param(DISTRI_IN);
        raydistri.f0_fit = load_profile_1D(DISTRI_IN,"XXf0_fit");
        raydistri.PSI_fit = load_grid_2D(DISTRI_IN,"PSI_fit",0);
    }
    
   	if (flag_fluct == 1) {
        
        fluctparam = load_fluct_param(FLUCT_IN);
        rayfluctuations.L_rho = load_value_0D(FLUCT_IN,"L_rho");
        rayfluctuations.xq_fit = load_profile_1D(FLUCT_IN,"xq_fit");
        rayfluctuations.xL_theta_fit = load_profile_1D(FLUCT_IN,"xL_theta_fit");
        rayfluctuations.xL_perp_fit = load_profile_1D(FLUCT_IN,"xL_perp_fit");
        rayfluctuations.XL_phi_fit = load_grid_2D(FLUCT_IN,"XL_phi_fit",0);
		rayfluctuations.Xcm_fit = load_grid_2D(FLUCT_IN,"Xcm_fit",0);
        rayfluctuations.Xcn_fit = load_grid_2D(FLUCT_IN,"Xcn_fit",0);
                
         
        if (fluctparam.ne_nmodel[0]) {
            
            tmp = mxGetField(FLUCT_IN, 0,"ne_fit");
            nss = fmax(mxGetDimensions(tmp)[0],mxGetDimensions(tmp)[1]);
                        
        }
        
        if (fluctparam.B_nmodel[0]) {
            
            tmp = mxGetField(FLUCT_IN, 0,"B_fit");
            nss = fmax(mxGetDimensions(tmp)[0],mxGetDimensions(tmp)[1]);
                        
            rayfluctuations.B_sfx_fit = mxCalloc(nss,sizeof(pp_2D_format));
            rayfluctuations.B_sfy_fit = mxCalloc(nss,sizeof(pp_2D_format));
            rayfluctuations.B_sfz_fit = mxCalloc(nss,sizeof(pp_2D_format));/* here z stands for phi, the toroidal direction */
           
            for (iss = 0;iss < nss; iss++) {
                rayfluctuations.B_sfx_fit[iss] = load_grid_2D(tmp,"Xfx_fit",iss);
                rayfluctuations.B_sfy_fit[iss] = load_grid_2D(tmp,"Xfy_fit",iss);
                rayfluctuations.B_sfz_fit[iss] = load_grid_2D(tmp,"Xfz_fit",iss);/* here z stands for phi, the toroidal direction */
            }
        }
        
   	} else {
        
   		fluctparam.ne_nmodel = mxCalloc(1,sizeof(int));/* automatic set to zero by default */
        fluctparam.B_nmodel = mxCalloc(1,sizeof(int));/* automatic set to zero by default */
   	} 

    /* Test Input Arguments */
    if (rayparam.testmode[0] > 0) testparam(rayparam,equilparam,fluctparam,rayequil,rayfluctuations,distriparam,raydistri,flag_fluct,flag_f0);
    
    /* Memory allocation */
 
    raymagnetic.rn = mxCalloc(1,sizeof(double));
    raymagnetic.Rn = mxCalloc(1,sizeof(double));
    raymagnetic.Zn = mxCalloc(1,sizeof(double));
    raymagnetic.Brhon = mxCalloc(1,sizeof(double));
    raymagnetic.Bsn = mxCalloc(1,sizeof(double));
    raymagnetic.B = mxCalloc(1,sizeof(double));
    raymagnetic.BPHIn = mxCalloc(1,sizeof(double));
    raymagnetic.salpha = mxCalloc(1,sizeof(double));
    raymagnetic.calpha = mxCalloc(1,sizeof(double));
    raymagnetic.gradrhon = mxCalloc(1,sizeof(double));
    raymagnetic.rhorip = mxCalloc(1,sizeof(double));  
 
    raymagnetic.drndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dRndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dZndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBrhondY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBsndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBPHIndY = mxCalloc(MC,sizeof(double));
    raymagnetic.dBdY = mxCalloc(MC,sizeof(double));
    raymagnetic.dsalphadY = mxCalloc(MC,sizeof(double));
    raymagnetic.dcalphadY = mxCalloc(MC,sizeof(double));
    raymagnetic.dgradrhondY = mxCalloc(MC,sizeof(double));
    raymagnetic.drhoripdY = mxCalloc(MC,sizeof(double));
 
    for (i = 0;i < MC; i++) {/*initialisation */
        raymagnetic.drndY[i] = 0.0;
        raymagnetic.dRndY[i] = 0.0;
        raymagnetic.dZndY[i] = 0.0;
        raymagnetic.dsalphadY[i] = 0.0;
        raymagnetic.dcalphadY[i] = 0.0;
        raymagnetic.dgradrhondY[i] = 0.0;
        raymagnetic.dBrhondY[i] = 0.0;
        raymagnetic.dBsndY[i] = 0.0;
        raymagnetic.dBPHIndY[i] = 0.0;
        raymagnetic.dBdY[i] = 0.0;
        raymagnetic.drhoripdY[i] = 0.0;
    }
 
    rayprofiles.Te = mxCalloc(1,sizeof(double));
    rayprofiles.ne = mxCalloc(1,sizeof(double));

    rayprofiles.dTedY = mxCalloc(MC,sizeof(double));
    rayprofiles.dnedY = mxCalloc(MC,sizeof(double));
    rayprofiles.d2TedY2 = mxCalloc(MC,sizeof(double));
    rayprofiles.d2nedY2 = mxCalloc(MC,sizeof(double));
    
    rayprofiles.zTi = mxCalloc(equilparam.ns[0],sizeof(double));
    rayprofiles.zni = mxCalloc(equilparam.ns[0],sizeof(double));
 
    rayprofiles.dzTidY = mxCalloc(equilparam.ns[0],sizeof(double *));
    rayprofiles.dznidY = mxCalloc(equilparam.ns[0],sizeof(double *));
    rayprofiles.d2zTidY2 = mxCalloc(equilparam.ns[0],sizeof(double *));
    rayprofiles.d2znidY2 = mxCalloc(equilparam.ns[0],sizeof(double *));
    
    for (i = 0;i < equilparam.ns[0]; i++) {
        rayprofiles.dzTidY[i] = mxCalloc(MC,sizeof(double));       
        rayprofiles.dznidY[i] = mxCalloc(MC,sizeof(double));
        rayprofiles.d2zTidY2[i] = mxCalloc(MC,sizeof(double));       
        rayprofiles.d2znidY2[i] = mxCalloc(MC,sizeof(double));    
    }  
    
    /* Array initialisation */
    
    for (i = 0;i < MC; i++) {
        rayprofiles.dTedY[i] = 0.0;
        rayprofiles.dnedY[i] = 0.0;
        rayprofiles.d2TedY2[i] = 0.0;
        rayprofiles.d2nedY2[i] = 0.0;
    
        for (j=0;j<equilparam.ns[0];j++) {
            rayprofiles.dzTidY[j][i] = 0.0;
            rayprofiles.dznidY[j][i] = 0.0;
            rayprofiles.d2zTidY2[j][i] = 0.0;
            rayprofiles.d2znidY2[j][i] = 0.0;
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
    yinit = mxCalloc(MC,sizeof(double));
    y0dot = mxCalloc(MC,sizeof(double));
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
    
    
    yinit[0] = y0[0];
    yinit[1] = y0[1];
    yinit[2] = y0[2];
    yinit[3] = y0[3];
    yinit[4] = y0[4];
    yinit[5] = y0[5];
    yinit[6] = y0[6];
    
    S1 = 0.0; /* initial value of path length */
    S_step = S1;/* initial path position */
        
/* Solves the dispersion relation internally to remove numerical errors from initial conditions */
    
    if (flag == 0) {
        interpequil(rayparam,raymagnetic,rayprofiles,equilparam,fluctparam,yinit,y0,rayequil,rayfluctuations,flag_fluct);
    } else {
        interpequil_test(raymagnetic,rayprofiles,equilparam,yinit,y0,flag);
    }
    
    alpha_rho = raymagnetic.gradrhon[0]*raymagnetic.drhoripdY[0];
    alpha_theta = raymagnetic.drhoripdY[1]/raymagnetic.rn[0];
    alpha_phi = raymagnetic.drhoripdY[2]/raymagnetic.Rn[0];
    acc = raymagnetic.Brhon[0]*(alpha_rho - alpha_theta*raymagnetic.salpha[0]) + raymagnetic.Bsn[0]*alpha_theta*raymagnetic.calpha[0] + alpha_phi*raymagnetic.BPHIn[0];

    mexPrintf("Initial accuracy :%g\n",acc);
    
    if ((fabs(flag) > 0) || (acc != 0)){
       mexPrintf("krho1:%g\n",krho1);
       dsolve(1,&krho1_dsolve,yinit,y0,raymagnetic,rayprofiles,X,rayparam,equilparam,fluctparam,rayequil,rayfluctuations,flag,flag_fluct);
       
       if (acc != 0) mexPrintf("The dispersion relation is first solved internally to remove numerical errors from initial conditions.\n");
       
       if (fabs((krho1_dsolve - krho1)/krho1) > 1e-3) mexPrintf("WARNING: The relative difference between initial krho and krho after dsolve exceeds 1e-3.\n");
       
       krho1 = krho1_dsolve;
       mexPrintf("krho1:%g\n",krho1);              
    }
    
         
/* Initialization */
    ts = 100.0*rayparam.tfinal[0];
    h = rayparam.dt0[0];
     
/* The main loop */
    while ((t1 < rayparam.tfinal[0]) && (k < kmax)) {
        ii++; 
        /*mexPrintf("ii,k:%d,%d\n",ii,k);*/
        if ((t1 + h) > rayparam.tfinal[0]) {
            h = rayparam.tfinal[0] - t1;
        }
        if (ii > iimax) {
            mexPrintf("iimax is reached");
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
                
                if (equilparam.zZi[0] > 0) {/*no absorption in vacuum*/
                    
                    rayprocess(rayproc,rayparam,raymagnetic,rayprofiles,X,equilparam,fluctparam,yinit,y0,rayequil,rayfluctuations,distriparam,raydistri,flag_f0,flag,flag_fluct);

                    for (i=0;i<MPROC+2*equilparam.ns[0];i++) {
                        temp_proc[i][k] = rayproc[i];
                    }

                    /* absphi = sqrt(fabs(phix2) + fabs(phiy2) + fabs(phiz2)); */
                    absphi = sqrt(fabs(rayproc[9]*rayproc[9]) + fabs(rayproc[10]*rayproc[10]) + fabs(rayproc[11]*rayproc[11]));

                    /* alpha = alphaphi*equilparam.ap[0]*y0[6]/CLUM/absphi; */
                    alpha2 = rayproc[12]*equilparam.ap[0]*y0[6]/CLUM/absphi;

                    /* Optical depth */

                    depth = depth + (alpha1 + alpha2)*dS/2;

                    
                    /*if (fmod(k,200) == 0) {   
                        mexPrintf("t,k,rho,tau:%g,%d,%g,%g\n",t1,k,y0[0],depth);
                    }*/

                    temp_proc[MPROC+2*equilparam.ns[0]][k] = depth;

                    
                    if (tau_lim > 0.0 && depth > tau_lim) { /* The power is fully absorbed. */
                        mexPrintf("The wave is fully linearly damped at k = %i\n",k);

                        kmax = (int)fmin((double)kmax,(double)k + rayparam.kextra[0]);

                        mexPrintf("----> Calculation stopped at k = %i\n",kmax);
                        tau_lim = 0.0;

                    }
                    
                    alpha1 = alpha2;
                }
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

        ray(X,s1,&Sdot1,yinit,y1,raymagnetic,rayprofiles,rayparam,equilparam,fluctparam,rayequil,rayfluctuations,flag,flag_fluct);          
        /* s2 = feval(F, t+h*alpha(1), y1+h*s1*beta(1,1), param); */
        
 
        for  (m = 0; m < MC-2; m++) {/* only the first six coordinates are evolving (rho,theta,phi,krho,m,n) */
            y1[m] = s0[m]+h*s1[m]*beta[0][0];
        }
         
            
        ray(X,s2,&Sdot2,yinit,y1,raymagnetic,rayprofiles,rayparam,equilparam,fluctparam,rayequil,rayfluctuations,flag,flag_fluct);
        /* s3 = feval(F, t+h*alpha(2), y1+h*[s1*beta(2,1)+s2*beta(2,2)], param); */
 
        for  (m = 0; m < MC-2; m++) {
            y1[m] = s0[m]+h*(s1[m]*beta[0][1] + s2[m]*beta[1][1]);
        }
 
        ray(X,s3,&Sdot3,yinit,y1,raymagnetic,rayprofiles,rayparam,equilparam,fluctparam,rayequil,rayfluctuations,flag,flag_fluct);
 
        /* s4 = feval(F, t+h*alpha(3), y1+h*[s1*beta(3,1)+s2*beta(3,2)+...], param); */
 
        for  (m = 0; m < MC-2; m++) {
            y1[m] = s0[m]+h*(s1[m]*beta[0][2] + s2[m]*beta[1][2] + s3[m]*beta[2][2]);
        }
 
        ray(X,s4,&Sdot4,yinit,y1,raymagnetic,rayprofiles,rayparam,equilparam,fluctparam,rayequil,rayfluctuations,flag,flag_fluct);
 
        /* s5 = feval(F, t+h*alpha(4), y1+h*[s1*beta(4,1)+s2*beta(4,2)+...], param); */
 
        for  (m = 0; m < MC-2; m++) {
            y1[m] = s0[m]+h*(s1[m]*beta[0][3] + s2[m]*beta[1][3] + s3[m]*beta[2][3] + s4[m]*beta[3][3]);
        }
 
 
        ray(X,s5,&Sdot5,yinit,y1,raymagnetic,rayprofiles,rayparam,equilparam,fluctparam,rayequil,rayfluctuations,flag,flag_fluct);
 
        /* s6 = feval(F, t+h*alpha(5), y1+h*[s1*beta(5,1)+s2*beta(5,2)+...], param); */
 
        for  (m = 0; m < MC-2; m++) {
            y1[m] = s0[m]+h*(s1[m]*beta[0][4] + s2[m]*beta[1][4] + s3[m]*beta[2][4] + s4[m]*beta[3][4] + s5[m]*beta[4][4]);
        }
        
        ray(X,s6,&Sdot6,yinit,y1,raymagnetic,rayprofiles,rayparam,equilparam,fluctparam,rayequil,rayfluctuations,flag,flag_fluct);
 
/*
Estimate the error and the acceptable error
*/
 
        for  (m = 0; m < MC-2; m++) {
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
            
            /* mexPrintf("ys[0],ys[1],ys[2],ys[3],ys[4],ys[5],ys[6],ymax,ydel[m]:%g,%g,%g,%g,%g,%g,%g,%g,%g\n",ys[0],ys[1],ys[2],ys[3],ys[4],ys[5],ys[6],ymax,ydel[m]); */

        }
 
 
/*       mexPrintf("ydel[0],ydel[1],ydel[2],ydel[3],ydel[4],ydel[5],ydel[6]:%g,%g,%g,%g,%g,%g,%g\n",ydel[0],ydel[1],ydel[2],ydel[3],ydel[4],ydel[5],ydel[6]);*/

        delta = inf_norm(ydel,MC-2);/* only the first six coordinates are evolving (rho,theta,phi,krho,m,n) */
        tau = rayparam.tol[0];
 
/*
Update the solution only if the error is acceptable
*/    
        
/*mexPrintf("t1,delta,tau,ymax,h,rho1,theta1,phi1,krho1,m1,n1:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",t1,delta,tau,ymax,h,rho1,theta1,phi1,krho1,m1,n1);*/
        
 
        if (delta <= tau) {
            
            t2 = t1 + h;
            
            rhodot = s1[0]*gama[0][0] + s2[0]*gama[1][0] + s3[0]*gama[2][0] + s4[0]*gama[3][0] + s5[0]*gama[4][0] + s6[0]*gama[5][0];
            thetadot = s1[1]*gama[0][0] + s2[1]*gama[1][0] + s3[1]*gama[2][0] + s4[1]*gama[3][0] + s5[1]*gama[4][0] + s6[1]*gama[5][0];
            phidot = s1[2]*gama[0][0] + s2[2]*gama[1][0] + s3[2]*gama[2][0] + s4[2]*gama[3][0] + s5[2]*gama[4][0] + s6[2]*gama[5][0];
            krhodot = s1[3]*gama[0][0] + s2[3]*gama[1][0] + s3[3]*gama[2][0] + s4[3]*gama[3][0] + s5[3]*gama[4][0] + s6[3]*gama[5][0];
            mdot = s1[4]*gama[0][0] + s2[4]*gama[1][0] + s3[4]*gama[2][0] + s4[4]*gama[3][0] + s5[4]*gama[4][0] + s6[4]*gama[5][0];
            ndot = s1[5]*gama[0][0] + s2[5]*gama[1][0] + s3[5]*gama[2][0] + s4[5]*gama[3][0] + s5[5]*gama[4][0] + s6[5]*gama[5][0];
            omegadot = 0.0;
            
            Sdot = Sdot1*gama[0][0] + Sdot2*gama[1][0] + Sdot3*gama[2][0] + Sdot4*gama[3][0] + Sdot5*gama[4][0] + Sdot6*gama[5][0];
            
            rho2 = rho1 + h*rhodot;
            theta2 = theta1 + h*thetadot;
            phi2 = phi1 + h*phidot;
            krho2 = krho1 + h*krhodot;
            m2 = m1 + h*mdot;
            n2 = n1 + h*ndot;
            omega2 = omega1 + h*omegadot;
               
            S2 = S1 + h*Sdot;            
 
                        
            if (rho2 > 1.0) {/* Wave reflexion at rho = 1  */ 
                if (rayparam.reflection[0] >=1.0) {/* The reflection is always enforced */
                    mexPrintf("********************************** Wave reflection is enforced at rho = %g**********************************\n",rho1);
                    rho2 = rho1;
                    phi2 = phi1;
                    theta2 = theta1;
                    omega2 = omega1;
                    S2 = S1;    
                         
                    if (reflection(X,rayparam,equilparam,fluctparam,raymagnetic,rayprofiles,&krho2,&m2,&n2,yinit,s0,rayequil,rayfluctuations,flag,flag_fluct) == -1) {goto Endloop;}                                                                    
                } else {/* The code calculates if the reflection must takes place. It calculates kpsi for vacuum (keeping the magnetic field) ray leaves the plasma only if kspi is real.*/             
                    s0[0] = rho1;
                    s0[1] = theta1;
                    s0[2] = phi1;
                    s0[3] = krho1;
                    s0[4] = m1;
                    s0[5] = n1;
                    s0[6] = omega1;             
                    dsolve(0,&krho2,yinit,s0,raymagnetic,rayprofiles,X,rayparam,equilparam,fluctparam,rayequil,rayfluctuations,flag,flag_fluct); 
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
                        if (reflection(X,rayparam,equilparam,fluctparam,raymagnetic,rayprofiles,&krho2,&m2,&n2,yinit,s0,rayequil,rayfluctuations,flag,flag_fluct) == -1) {goto Endloop;}                                            
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
    mxFree(raymagnetic.Brhon);
    mxFree(raymagnetic.Bsn);
    mxFree(raymagnetic.BPHIn);
    mxFree(raymagnetic.B);
    mxFree(raymagnetic.salpha);
    mxFree(raymagnetic.calpha);
    mxFree(raymagnetic.gradrhon);
    mxFree(raymagnetic.rhorip);
    
    mxFree(raymagnetic.drndY);
    mxFree(raymagnetic.dRndY);
    mxFree(raymagnetic.dZndY);
    mxFree(raymagnetic.dBrhondY);
    mxFree(raymagnetic.dBsndY);
    mxFree(raymagnetic.dBPHIndY);
    mxFree(raymagnetic.dBdY);   
    mxFree(raymagnetic.dsalphadY);
    mxFree(raymagnetic.dcalphadY);
    mxFree(raymagnetic.dgradrhondY);
    mxFree(raymagnetic.drhoripdY);
    
    mxFree(rayprofiles.Te);
    mxFree(rayprofiles.ne);
    mxFree(rayprofiles.zTi);
    mxFree(rayprofiles.zni);
 
    mxFree(rayprofiles.dTedY);
    mxFree(rayprofiles.dnedY);

    mxFree(rayprofiles.d2TedY2);
    mxFree(rayprofiles.d2nedY2);

    for (i = 0;i < equilparam.ns[0]; i++) {
        mxFree(rayprofiles.dzTidY[i]);       
        mxFree(rayprofiles.dznidY[i]);       
        mxFree(rayprofiles.d2zTidY2[i]);       
        mxFree(rayprofiles.d2znidY2[i]);       
    }    
    
    mxFree(rayprofiles.dzTidY);
    mxFree(rayprofiles.dznidY);
    mxFree(rayprofiles.d2zTidY2);
    mxFree(rayprofiles.d2znidY2);
 
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
	mxFree(y0dot);
    mxFree(y1);
    mxFree(s0);
    mxFree(s1);
    mxFree(s2);
    mxFree(s3);
    mxFree(s4);
    mxFree(s5);
    mxFree(s6);
    
 
    if (flag_proc == 1) {    
       
        if (equilparam.zZi[0]>0) {
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
        
        } else {
            
        	Y_PROC = mxCreateDoubleMatrix(1,1,mxREAL);
            yproc = mxGetPr(Y_PROC); 
            yproc[1] = 0.0;           
        }
        
    }
    
    if (flag_fluct == 1) {
             
        if (fluctparam.ne_nmodel[0]) {
                        
        }
        
        if (fluctparam.B_nmodel[0]) {
                        
            mxFree(rayfluctuations.B_sfx_fit);
            mxFree(rayfluctuations.B_sfy_fit);
            mxFree(rayfluctuations.B_sfz_fit);
 
        }
        
   	} else {
        
   		mxFree(fluctparam.ne_nmodel);
        mxFree(fluctparam.B_nmodel);
   	}

/* End of C3PO */    
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


void ray(X,Ydot,Sdot,Y0,Y,raymagnetic,rayprofiles,rayparam,equilparam,fluctparam,rayequil,rayfluctuations,flag,flag_fluct)

susceptibilitytensor_format X;
double Y0[],Y[],Ydot[],*Sdot;
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
rayparam_format rayparam;
equilparam_format equilparam;
fluctparam_format fluctparam;
rayequil_format rayequil;
rayfluctuations_format rayfluctuations;
double flag;
int flag_fluct;
{

    register int i,j;

    double Npar,dNpardY[MC];
    double complex Dtot,dDtotdY[MC];
    double complex Nperp,dNperpdY[MC],N2,dN2dY[MC],eikval;
    
    double Sdot2;
    double Gcov[3][3];
    double wcn[equilparam.ns[0]+1],wpn2[equilparam.ns[0]+1],betath[equilparam.ns[0]+1];
    
    
    /* Equilibrium interpolation at ray location */
    if (flag == 0) {
       interpequil(rayparam,raymagnetic,rayprofiles,equilparam,fluctparam,Y0,Y,rayequil,rayfluctuations,flag_fluct);
    } else {
       interpequil_test(raymagnetic,rayprofiles,equilparam,Y0,Y,flag);
    }

    /* Refractive index calculation */
    rayindex(&Nperp,dNperpdY,&N2,dN2dY,1,Y,raymagnetic,equilparam,&Npar,dNpardY,&eikval);
    /* 
    mexPrintf("rn,Rn,Zn,Brhon,Bsn,krho,sina,cosa,B,BPHIn:%g,%g,%g,%g,%g,%g,%g,%g,%g\n",raymagnetic.rn[0],raymagnetic.Rn[0],raymagnetic.Zn[0],raymagnetic.Brhon[0],raymagnetic.Bsn[0],Y[3],raymagnetic.salpha[0],raymagnetic.calpha[0],raymagnetic.B[0],raymagnetic.BPHIn[0]);
    mexPrintf("Npar,w*dNpardw,Nperpr,Nperpi,w*dNperpdwr,w*dNperpdwi:%g,%g,%g,%g,%g,%g\n",Npar,dNpardY[6],Nperp,dNperpdY[6]);
    */ 

    /*mexPrintf("Eikonal validity (<< 1):%g,%g\n",eikval);*/
    
    
    /* Susceptibility tensor  */

    susceptibility(X,Nperp,dNperpdY,wcn,wpn2,betath,rayparam.tensortype[0],(int)rayparam.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Y[6]);
    
    if (flag < 0) {/* dipersion relation */
        disprel(dDtotdY,&Dtot,X,dNperpdY,Nperp,dN2dY,N2,dNpardY,Npar,3);
    } else {
        disprel(dDtotdY,&Dtot,X,dNperpdY,Nperp,dN2dY,N2,dNpardY,Npar,1);
    }
    
    if (equilparam.zZi[0] > 0) {
        Ydot[0] = -creal(dDtotdY[3])/creal(dDtotdY[6]); 
        Ydot[1] = -creal(dDtotdY[4])/creal(dDtotdY[6]); 
        Ydot[2] = -creal(dDtotdY[5])/creal(dDtotdY[6]); 
        Ydot[3] = creal(dDtotdY[0])/creal(dDtotdY[6]); 
        Ydot[4] = creal(dDtotdY[1])/creal(dDtotdY[6]);
        Ydot[5] = creal(dDtotdY[2])/creal(dDtotdY[6]); 
        Ydot[6] = 0.0; 
    } else {/* vacuum case */
        Ydot[0] = -creal(dN2dY[3])/creal(dN2dY[6]); 
        Ydot[1] = -creal(dN2dY[4])/creal(dN2dY[6]); 
        Ydot[2] = -creal(dN2dY[5])/creal(dN2dY[6]); 
        Ydot[3] = creal(dN2dY[0])/creal(dN2dY[6]); 
        Ydot[4] = creal(dN2dY[1])/creal(dN2dY[6]);
        Ydot[5] = creal(dN2dY[2])/creal(dN2dY[6]);
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


void polarization(X,Npar,Nperp,epolx,epoly,epolz,epolp,epolm)
susceptibilitytensor_format X;
double Npar;
double complex Nperp,*epolx,*epoly,*epolz,*epolp,*epolm;
{
    double complex a,b,c;
    double epolnorm;
    
    a = X.Xxz[0] + Npar*Nperp;
    b = Npar*Npar - 1.0 - X.Xxx[0];
    c = Nperp*Nperp - 1.0 - X.Xzz[0];
    
    /* 
    epolx[0] = -I*(X.Xxy[0] - X.Xyz[0]*a/c);
    epoly[0] = -I*(b - a*a/c);
    epolz[0] = (X.Xyz[0]*b - X.Xxy[0]*a)/c;
    */
    
    epolx[0] = I*(X.Xxy[0] - X.Xyz[0]*a/c);
    epoly[0] = -I*(b - a*a/c);
    epolz[0] = -I*(X.Xyz[0]*b - X.Xxy[0]*a)/c;
    
    epolnorm = sqrt(cabs(epolx[0])*cabs(epolx[0]) + cabs(epoly[0])*cabs(epoly[0]) + cabs(epolz[0])*cabs(epolz[0]));
    
    epolx[0] = epolx[0]/epolnorm;
    epoly[0] = epoly[0]/epolnorm;
    epolz[0] = epolz[0]/epolnorm;    
    
    epolp[0] = (epolx[0] + I*epoly[0])/sqrt(2.0);
    epolm[0] = (epolx[0] - I*epoly[0])/sqrt(2.0);
}


void rayprocess(rayproc,rayparam,raymagnetic,rayprofiles,X,equilparam,fluctparam,Y0,Y,rayequil,rayfluctuations,distriparam,raydistri,flag_f0,flag,flag_fluct)
double rayproc[];
rayparam_format rayparam;
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
susceptibilitytensor_format X;
equilparam_format equilparam;
fluctparam_format fluctparam;
double Y0[],Y[];
rayequil_format rayequil;
rayfluctuations_format rayfluctuations;
distriparam_format distriparam;
raydistri_format raydistri;
int flag_f0;
double flag;
int flag_fluct;
{
    double Npar,Npar2,dNpardY[MC];
    double complex Nperp,dNperpdY[MC];
    double complex N2,dN2dY[MC];
    
    double complex Dtot,dDtotdY[MC];
    double complex epolx,epoly,epolz,epolp,epolm;
    double complex d,eikval;
    double alphaphi = 0.0,phix,phiy,phiz,pmin,pmax,yn,yn2;
    int n,nmin,nmax,flagn;
    register int i;
    
    double wcn[equilparam.ns[0]+1],wpn2[equilparam.ns[0]+1],betath[equilparam.ns[0]+1];
    
    double *Xf0,*dXf0drho,*d2Xf0drho2;
    double *PSI;
    double *pn,*mhu;
    int npn,nmhu;
    double dummy1;
    
    double qe = 1.602176462e-19;/*Absolute value of the electron charge (C) */
    double me = 9.10938188e-31;/*Electron rest mass (Kg) */
    double epsi0 = 8.854187818e-12;/*Free space permittivity (F/m) */
    

    /* Equilibrium interpolation at ray location */
    if (flag == 0) {
		interpequil(rayparam,raymagnetic,rayprofiles,equilparam,fluctparam,Y0,Y,rayequil,rayfluctuations,flag_fluct);
    } else {
		interpequil_test(raymagnetic,rayprofiles,equilparam,Y0,Y,flag);
    }

    /* Refractive index calculation */
    rayindex(&Nperp,dNperpdY,&N2,dN2dY,1,Y,raymagnetic,equilparam,&Npar,dNpardY,&eikval);

    /* Susceptibility tensor  */
    susceptibility(X,Nperp,dNperpdY,wcn,wpn2,betath,rayparam.tensortype[0],(int)rayparam.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Y[6]);

    /* dispersion relation */
    disprel(dDtotdY,&Dtot,X,dNperpdY,Nperp,dN2dY,N2,dNpardY,Npar,2);
    
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
    
    polarization(X,Npar,Nperp,&epolx,&epoly,&epolz,&epolp,&epolm);
    
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
    
    /*mexPrintf("wpn2,wcn,betath,Npar,Nperp,epolp,epolm,epolz,n,rel_opt,nperp,pperpmax:%g,%g,%g,%g,%g,%g,%g,%g,%i,%i,%i,%g\n",wpn2[0],wcn[0],betath[0],Npar,creal(Nperp),epolp,epolm,epolz,n,(int)rayparam.rel_opt[0],(int)rayparam.nperp[0],rayparam.pperpmax[0]);*/

    /* harmonics to be considered */
         
    flagn = 0;
    Npar2 = Npar*Npar;
    pmax = rayparam.pperpmax[0];

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
    
    if (flag_f0 == 1) {/* non-Maxwellian electron distribution */
        
        Xf0 = mxCalloc(distriparam.npn[0]*distriparam.nmhu[0],sizeof(double));
        dXf0drho = mxCalloc(distriparam.npn[0]*distriparam.nmhu[0],sizeof(double));
        d2Xf0drho2 = mxCalloc(distriparam.npn[0]*distriparam.nmhu[0],sizeof(double));
        ppvald_1D(raydistri.f0_fit,rayparam.dS[0],Y[0],Xf0,dXf0drho,d2Xf0drho2);
        
        PSI = mxCalloc(1,sizeof(double));
        ppvald_2D(raydistri.PSI_fit,rayparam.dS[0],Y[0],Y[1],PSI,&dummy1,&dummy1,&dummy1,&dummy1);
        
        pn = distriparam.pn;
        npn = distriparam.npn[0];
        
        mhu = distriparam.mhu;
        nmhu = distriparam.nmhu[0];
        
        
        /********** WARNING: alphaphi_jd MUST be modified before using these quantities YP **************/
        
        /*wpn2[0] = qe*qe*distriparam.ne_ref[0]/epsi0/me/Y[6]/Y[6];/*electrons */
        /*betath[0] = distriparam.betath_ref[0];*/
        
        /************************************************************************************************/
        
    } else {/* Maxwellian electron distribution */
          
        Xf0 = mxCalloc(1,sizeof(double));
        dXf0drho = mxCalloc(1,sizeof(double));
        d2Xf0drho2 = mxCalloc(1,sizeof(double));
          
        PSI = mxCalloc(1,sizeof(double));
        
        pn = mxCalloc(1,sizeof(double));
        npn = 1;
        
        mhu = mxCalloc(1,sizeof(double));
        nmhu = 1;  
    }

    for (n=nmin;n<nmax+1;n++) {                    
        alphaphi = alphaphi + alphaphi_jd(epolp,epolm,epolz,wpn2[0],-wcn[0],betath[0],Npar,creal(Nperp),n,(int)rayparam.rel_opt[0],(int)rayparam.nperp[0],pmax,npn,pn,nmhu,mhu,Xf0,PSI);
    }   
    
    if (flag_f0 == 1) {/* non-Maxwellian electron distribution */
        mxFree(Xf0);
        mxFree(dXf0drho);
        mxFree(d2Xf0drho2);
        mxFree(PSI); 
    } else {/* Maxwellian electron distribution */
        mxFree(Xf0);
        mxFree(dXf0drho);
        mxFree(d2Xf0drho2);
        mxFree(PSI);
        mxFree(pn);
        mxFree(mhu);  
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
    rayproc[16] = raymagnetic.Brhon[0];
    rayproc[17] = raymagnetic.Bsn[0];
    rayproc[18] = raymagnetic.BPHIn[0];
    rayproc[19] = raymagnetic.rn[0];
    rayproc[20] = raymagnetic.salpha[0];
    rayproc[21] = raymagnetic.gradrhon[0];
    rayproc[22] = eikval;
        
    rayproc[23] = rayprofiles.Te[0];
    rayproc[24] = rayprofiles.ne[0];

    for (i=0;i<equilparam.ns[0];i++) {
        rayproc[MPROC + i] = rayprofiles.zTi[i];      
        rayproc[MPROC + equilparam.ns[0] + i] = rayprofiles.zni[i];      
    }

}

int reflection(X,rayparam,equilparam,fluctparam,raymagnetic,rayprofiles,krho2,m2,n2,Y0,Y,rayequil,rayfluctuations,flag,flag_fluct)
susceptibilitytensor_format X;
rayparam_format rayparam;
equilparam_format equilparam;
fluctparam_format fluctparam;
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
double *krho2,*m2,*n2;
double Y0[],Y[]; 
rayequil_format rayequil;
rayfluctuations_format rayfluctuations;
double flag;
int flag_fluct;
{
    double complex Dtot,dDtotdY[MC];
    
    double Npar,Npar2,dNpardY[MC];
    double complex Nperp,dNperpdY[MC];
    double complex N2,dN2dY[MC],eikval;
    
    double wcn[equilparam.ns[0]+1],wpn2[equilparam.ns[0]+1],betath[equilparam.ns[0]+1];    
    
    double alpha_rho,alpha_theta,alpha_phi;
    double beta_r,beta_theta,beta_phi;
    double a11,a12,a13,a21,a22,a23,a31,a32,a33,b1,b2,b3,det;
    double acc,krho_dsolve;
    
    double Yguess[MC];


    /* Equilibrium interpolation at ray location */
    if (flag == 0) {
        interpequil(rayparam,raymagnetic,rayprofiles,equilparam,fluctparam,Y0,Y,rayequil,rayfluctuations,flag_fluct);
    } else {
        interpequil_test(raymagnetic,rayprofiles,equilparam,Y0,Y,flag);
    }
    
    /* Refractive index calculation */
    
    rayindex(&Nperp,dNperpdY,&N2,dN2dY,1,Y,raymagnetic,equilparam,&Npar,dNpardY,&eikval);
    
    /* Susceptibility tensor  */

    susceptibility(X,Nperp,dNperpdY,wcn,wpn2,betath,rayparam.tensortype[0],(int)rayparam.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Y[6]);

    /* dispersion relation */
    
    disprel(dDtotdY,&Dtot,X,dNperpdY,Nperp,dN2dY,N2,dNpardY,Npar,3);
    /*mexPrintf("Disprel_in reflection:%g\n",creal(Dtot));*/
    
    /* calculation of the rotation angle beta around Bfield direction with the condition k2.grad(rho) = -k1.grad(rho) where rho is the perturbed magnetic flux surface */
    
    alpha_rho = raymagnetic.gradrhon[0]*raymagnetic.drhoripdY[0];
    alpha_theta = raymagnetic.drhoripdY[1]/raymagnetic.rn[0];
    alpha_phi = raymagnetic.drhoripdY[2]/raymagnetic.Rn[0];
     
    beta_r = -raymagnetic.salpha[0]*raymagnetic.BPHIn[0]*alpha_rho + alpha_theta*raymagnetic.BPHIn[0] + alpha_phi*(raymagnetic.Brhon[0]*raymagnetic.salpha[0] - raymagnetic.Bsn[0]*raymagnetic.calpha[0]);
    beta_theta = -raymagnetic.calpha[0]*raymagnetic.BPHIn[0]*alpha_rho + alpha_phi*(raymagnetic.Brhon[0]*raymagnetic.calpha[0] + raymagnetic.Bsn[0]*raymagnetic.salpha[0]);
    beta_phi = raymagnetic.Bsn[0]*alpha_rho - alpha_theta*(raymagnetic.Brhon[0]*raymagnetic.calpha[0] + raymagnetic.Bsn[0]*raymagnetic.salpha[0]);
            
    a11 = raymagnetic.gradrhon[0]*alpha_rho;
    a12 = (alpha_theta*raymagnetic.calpha[0] - alpha_rho*raymagnetic.salpha[0])/raymagnetic.rn[0];
    a13 = alpha_phi/raymagnetic.Rn[0];
    
    a21 = raymagnetic.gradrhon[0]*raymagnetic.Brhon[0];
    a22 = (raymagnetic.Bsn[0]*raymagnetic.calpha[0] - raymagnetic.Brhon[0]*raymagnetic.salpha[0])/raymagnetic.rn[0];
    a23 = raymagnetic.BPHIn[0]/raymagnetic.Rn[0];
    
    a31 = raymagnetic.gradrhon[0]*(beta_r*raymagnetic.calpha[0] - beta_theta*raymagnetic.salpha[0]);
    a32 = beta_theta/raymagnetic.rn[0];
    a33 = beta_phi/raymagnetic.Rn[0];
    
    b1 = -a11*Y[3] - a12*Y[4] - a13*Y[5];
    b2 = a21*Y[3] + a22*Y[4] + a23*Y[5];
    b3 = a31*Y[3] + a32*Y[4] + a33*Y[5];
            
    det = a11*(a22*a33 - a23*a32) - a21*(a12*a33 - a32*a13) + a31*(a12*a23 - a22*a13);
    
    krho2[0] = (b1*(a22*a33 - a23*a32) - b2*(a12*a33 - a32*a13) + b3*(a12*a23 - a22*a13))/det;
    m2[0] = (a11*(b2*a33 - a23*b3) - a21*(b1*a33 - b3*a13) + a31*(b1*a23 - b2*a13))/det;       
    n2[0] = (a11*(a22*b3 - b2*a32) - a21*(a12*b3 - a32*b1) + a31*(a12*b2 - a22*b1))/det;
    
    /* simple expressions for the axisymmetric case only for benchmarking */
    
    /* mexPrintf("General calculation -> krho2[0],m2[0],n2[0]:%g,%g,%g\n",krho2[0],m2[0],n2[0]);
    
    krho2[0] = 2.0*Y[4]*raymagnetic.salpha[0]/raymagnetic.rn[0]/raymagnetic.gradrhon[0] - Y[3];
	m2[0] = Y[4];
	n2[0] = Y[5] ;
    
    mexPrintf("Axisymmetric case -> krho2[0],m2[0],n2[0]:%g,%g,%g\n",krho2[0],m2[0],n2[0]);
    mexPrintf("Initial values -> krho1[0],m1[0],n1[0]:%g,%g,%g\n",Y[3],Y[4],Y[5]);
    
    mexPrintf("General calculation -> alpha_rho,alpha_theta,alpha_phi:%g,%g,%g\n",alpha_rho,alpha_theta,alpha_phi);
    mexPrintf("General calculation -> raymagnetic.Brhon[0],raymagnetic.Bsn[0],raymagnetic.BPHIn[0]:%g,%g,%g\n",raymagnetic.Brhon[0],raymagnetic.Bsn[0],raymagnetic.BPHIn[0]);
    mexPrintf("General calculation -> raymagnetic.calpha[0],raymagnetic.salpha[0],raymagnetic.gradrhon[0]:%g,%g,%g\n",raymagnetic.calpha[0],raymagnetic.salpha[0],raymagnetic.gradrhon[0]);
    */
    
    /*correct lack of accuracy of the magnetic topology in presence of fluctuation when Brho is not exatly zero */
            
    acc = raymagnetic.Brhon[0]*(alpha_rho - alpha_theta*raymagnetic.salpha[0]) + raymagnetic.Bsn[0]*alpha_theta*raymagnetic.calpha[0] + alpha_phi*raymagnetic.BPHIn[0];
  
    if (acc != 0) {
        
        Yguess[0] = Y[0];
        Yguess[1] = Y[1];
        Yguess[2] = Y[2];
        Yguess[3] = krho2[0];
        Yguess[4] = m2[0];
        Yguess[5] = n2[0];
        Yguess[6] = Y[6];
        dsolve(1,&krho_dsolve,Y0,Yguess,raymagnetic,rayprofiles,X,rayparam,equilparam,fluctparam,rayequil,rayfluctuations,flag,flag_fluct);   
        /* mexPrintf("General calculation -> krho_in,krho_reflection,krho_reflection_dsolve:%g,%g,%g\n",Y[3],krho2[0],krho_dsolve);*/
        krho2[0] = krho_dsolve;
        mexPrintf("The dispersion relation is solved at the reflection point to avoid cumulative propagation of numerical errors.\n");
        if (fabs((krho_dsolve - krho2[0])/krho2[0]) > 1e-3) mexPrintf("WARNING: The relative difference between krho after reflection and krho after dsolve exceeds 1e-3.\n");
        
    }
    
    return(0);    
}


void dsolve(mode,krho,Y0,Y,raymagnetic,rayprofiles,X,rayparam,equilparam,fluctparam,rayequil,rayfluctuations,flag,flag_fluct)
int mode;
double *krho;
double Y0[],Y[];
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
susceptibilitytensor_format X;
rayparam_format rayparam;
equilparam_format equilparam;
fluctparam_format fluctparam;
rayequil_format rayequil;
rayfluctuations_format rayfluctuations;
double flag;
int flag_fluct;
{
    double Npar,dNpardY[MC];
    double complex Nperp,dNperpdY[MC];
    double complex N2,dN2dY[MC],eikval;

    double frac,fracmax,exp,tol;
    double krho0,krho1,krho2,dkrho;
    double complex cD0,cD1,dDtotdY[MC];
    double D0,D1,D2;
    int maxit;

    double wcn[equilparam.ns[0]+1],wpn2[equilparam.ns[0]+1],betath[equilparam.ns[0]+1];
    register int j;
    
    frac = 1 - 1e-4;
    fracmax = 2;
    exp = -1.5;
    tol = 1e-12;
    
    maxit = 50;

    
    if (equilparam.zZi[0] > 0) {
    
        /* Equilibrium interpolation at ray location */
        if (flag == 0) {
            interpequil(rayparam,raymagnetic,rayprofiles,equilparam,fluctparam,Y0,Y,rayequil,rayfluctuations,flag_fluct);
        } else {
            interpequil_test(raymagnetic,rayprofiles,equilparam,Y0,Y,flag);
        }

        krho0 = Y[3];
        krho1 = frac*krho0;

        rayindex(&Nperp,dNperpdY,&N2,dN2dY,1,Y,raymagnetic,equilparam,&Npar,dNpardY,&eikval);
        if (mode > 0) {/* plasma case */
            susceptibility(X,Nperp,dNperpdY,wcn,wpn2,betath,rayparam.tensortype[0],(int)rayparam.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Y[6]);
        }     
        disprel(dDtotdY,&cD0,X,dNperpdY,Nperp,dN2dY,N2,dNpardY,Npar,2);
        D0 = creal(cD0);/* to be changed if non-hermitian susceptibility tensors are used */
        /*mexPrintf("krho0,D0:%g,%g\n",krho0,D0);*/

        Y[3] = krho1;
        rayindex(&Nperp,dNperpdY,&N2,dN2dY,1,Y,raymagnetic,equilparam,&Npar,dNpardY,&eikval);
        if (mode > 0) {/* plasma case */
            susceptibility(X,Nperp,dNperpdY,wcn,wpn2,betath,rayparam.tensortype[0],(int)rayparam.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Y[6]);
        }
        disprel(dDtotdY,&cD1,X,dNperpdY,Nperp,dN2dY,N2,dN2dY,Npar,2);
        D1 = creal(cD1);/* to be changed if non-hermitian susceptibility tensors are used */
        /*mexPrintf("krho1,D1:%g,%g\n",krho1,D1);*/

        /* Search for root bounding interval */

        while ((D1*D0 > 0) && (fracmax < 100)) {

            frac = pow(frac,exp);
            krho1 = frac*krho0;

            Y[3] = krho1;
            rayindex(&Nperp,dNperpdY,&N2,dN2dY,1,Y,raymagnetic,equilparam,&Npar,dNpardY,&eikval);
            if (mode > 0) {/* plasma case */
                susceptibility(X,Nperp,dNperpdY,wcn,wpn2,betath,rayparam.tensortype[0],(int)rayparam.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Y[6]);
            }
            disprel(dDtotdY,&cD1,X,dNperpdY,Nperp,dN2dY,N2,dNpardY,Npar,2);
            D1 = creal(cD1);/* to be changed if non-hermitian susceptibility tensors are used */
            /*mexPrintf("krho1,D1:%g,%g\n",krho1,D1);*/
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
                rayindex(&Nperp,dNperpdY,&N2,dN2dY,1,Y,raymagnetic,equilparam,&Npar,dNpardY,&eikval);
                if (mode > 0) {/* plasma case */
                    susceptibility(X,Nperp,dNperpdY,wcn,wpn2,betath,rayparam.tensortype[0],(int)rayparam.ncyclharm[0],equilparam,raymagnetic,rayprofiles,Npar,dNpardY,Y[6]);
                }
                disprel(dDtotdY,&cD1,X,dNperpdY,Nperp,dN2dY,N2,dNpardY,Npar,2);
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
    } else {
        krho[0] = Y[3];
    }
    
}


void disprel(dDtotdY,Dtot,X,dNperpdY,Nperp,dN2dY,N2,dNpardY,Npar,flag)
double complex dDtotdY[],*Dtot;
susceptibilitytensor_format X;
double complex dNperpdY[],Nperp,dN2dY[],N2;
double dNpardY[],Npar;
int flag;
{
    double complex D[43],dDdY[43][MC],N6,dN6m1;

    double complex Nperp4,Nperp3,Nperp2,Nperp1;
    double Npar4,Npar3,Npar2,Npar1;
    double complex Xxx,Xxy,Xxz,Xyy,Xyz,Xzz;
    double complex Xxx2,Xxy2,Xxz2,Xyy2,Xyz2,Xzz2;
    
    int i,j;

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
    if ((flag == 1) || (flag == 3)) {
    
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
    }
    
    if ((flag == 2) || (flag == 3)) {

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

}

void susceptibility(X,Nperp,dNperpdY,wcn,wpn2,betath,tensortype,ncyclharm,equilparam,raymagnetic,rayprofiles,Npar,dNpardY,omega)
susceptibilitytensor_format X;
double complex Nperp,dNperpdY[];
double wcn[],wpn2[],betath[];
double tensortype,omega;
int ncyclharm;
double Npar,dNpardY[];

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
        dwcndY[0][2] = -qe*raymagnetic.dBdY[2]/me/omega;
        dwcndY[0][6] = -wcn[0];

        wpn2[0] = qe*qe*rayprofiles.ne[0]/epsi0/me/omega/omega;/*electrons */
        dwpn2dY[0][0] = qe*qe*rayprofiles.dnedY[0]/epsi0/me/omega/omega;
        dwpn2dY[0][1] = qe*qe*rayprofiles.dnedY[1]/epsi0/me/omega/omega;
        dwpn2dY[0][2] = qe*qe*rayprofiles.dnedY[2]/epsi0/me/omega/omega;
        dwpn2dY[0][6] = -2.0*wpn2[0];

        betath[0] = sqrt(rayprofiles.Te[0]/mc2);
        dbetathdY[0][0] = rayprofiles.dTedY[0]/betath[0]/2.0;
        dbetathdY[0][1] = rayprofiles.dTedY[1]/betath[0]/2.0;
        dbetathdY[0][2] = rayprofiles.dTedY[2]/betath[0]/2.0;

        for (is = 1;is < equilparam.ns[0]+1; is++) {
            if (rayprofiles.zni[is-1] > 0.0) {/* only when ion density is positive */
                wcn[is] = qe*equilparam.zZi[is-1]*raymagnetic.B[0]/equilparam.zmi[is-1]/mp/omega;/*ions */
                dwcndY[is][0] = qe*equilparam.zZi[is-1]*raymagnetic.dBdY[0]/equilparam.zmi[is-1]/mp/omega;
                dwcndY[is][1] = qe*equilparam.zZi[is-1]*raymagnetic.dBdY[1]/equilparam.zmi[is-1]/mp/omega;
                dwcndY[is][2] = qe*equilparam.zZi[is-1]*raymagnetic.dBdY[2]/equilparam.zmi[is-1]/mp/omega;
                dwcndY[is][6] = -wcn[is]; 

                wpn2[is] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*rayprofiles.zni[is-1]/epsi0/equilparam.zmi[is-1]/mp/omega/omega;/*ions */
                dwpn2dY[is][0] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*rayprofiles.dznidY[is-1][0]/epsi0/equilparam.zmi[is-1]/mp/omega/omega;
                dwpn2dY[is][1] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*rayprofiles.dznidY[is-1][1]/epsi0/equilparam.zmi[is-1]/mp/omega/omega;
                dwpn2dY[is][2] = qe*equilparam.zZi[is-1]*qe*equilparam.zZi[is-1]*rayprofiles.dznidY[is-1][2]/epsi0/equilparam.zmi[is-1]/mp/omega/omega;
                dwpn2dY[is][6] = -2.0*wpn2[is]; 

                betath[is] = sqrt(rayprofiles.zTi[is-1]*me/equilparam.zmi[is-1]/mp/mc2);
                dbetathdY[is][0] = rayprofiles.dzTidY[is-1][0]/betath[is]/2.0;
                dbetathdY[is][1] = rayprofiles.dzTidY[is-1][1]/betath[is]/2.0;
                dbetathdY[is][2] = rayprofiles.dzTidY[is-1][2]/betath[is]/2.0;
            }
        }

        if (tensortype == 0) {
/*        mexPrintf("Cold dielectric tensor\n"); */
            coldtensor(X,Nperp,dNperpdY,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY);
        }
        if (tensortype == 1) {
/*        mexPrintf("Warm dielectric tensor\n");
            warmtensor(X,Nperp,dNperpdY,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY); */
        }
        if (tensortype == 2) {
/*        mexPrintf("Hot dielectric tensor\n");*/
            hottensor(X,Nperp,dNperpdY,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY); 
        }
        if (tensortype == 3) {
/*        mexPrintf("Weak relativistic dielectric tensor\n");*/
            weakrelativistictensor(X,Nperp,dNperpdY,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY);
        }       
        if (tensortype == 4) {
/*        mexPrintf("Full relativistic dielectric tensor\n");
            fullrelativistictensor(X,Nperp,dNperpdY,equilparam.ns[0],ncyclharm,raymagnetic,Npar,dNpardY,wcn,dwcndY,wpn2,dwpn2dY,betath,dbetathdY); */
        }       
        
    } else {
        vacuumtensor(X);
    }
} 


void rayindex(Nperp,dNperpdY,N2,dN2dY,mode,Y,raymagnetic,equilparam,Npar,dNpardY,eikval)
double complex *Nperp,*dNperpdY;
double complex *N2,*dN2dY;
int mode;
double Y[];
double *Npar,*dNpardY;
raymagnetic_format raymagnetic;
equilparam_format equilparam;
double complex *eikval;
{ 
    double dYdY[MC][MC];

    double Npar0,dNpar0dY,dNpar0dY1,dNpar0dY2,dNpar0dY3,dNpar0dY4;
    double Npar1,dNpar1dY,dNpar1dY1,dNpar1dY2,dNpar1dY3,dNpar1dY4,dNpar1dY5;
    double Npar2,dNpar2dY,dNpar2dY1,dNpar2dY2,dNpar2dY3,dNpar2dY4;
      
    double complex N21,dN21dY,dN21dY1,dN21dY2,dN21dY3;
    double complex N22,dN22dY,dN22dY1,dN22dY2,dN22dY3,dN22dY4,dN22dY5,dN22dY6;
    double complex N23,dN23dY,dN23dY1,dN23dY2,dN23dY3;
    double complex N24,dN24dY,dN24dY1,dN24dY2,dN24dY3;
    
    
    double complex divN11,divN12,divN13,divN14,divN15;
    double complex divN21,divN22,divN23,divN24,divN25;
    double complex divN31,divN32;
    double complex divN1,divN2,divN3;
    
    double ap,cnorm;

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
    cnorm = CLUM/ap/Y[6];
    
   /*  mexPrintf("clum_norm,ap,CLUM,Y[6]:%g,%g,%g,%g\n",cnorm,ap,CLUM,Y[6]); */
    
    if (mode == 1) { 
        
        Npar0 = Y[3]*raymagnetic.gradrhon[0]*raymagnetic.Brhon[0];
        Npar1 = Y[4]*(raymagnetic.calpha[0]*raymagnetic.Bsn[0] - raymagnetic.salpha[0]*raymagnetic.Brhon[0])/raymagnetic.rn[0];
        Npar2 = Y[5]*raymagnetic.BPHIn[0]/raymagnetic.Rn[0];
  
        Npar[0] = cnorm*(Npar0 + Npar1 + Npar2);
        
/*
          mexPrintf("Nparth:%g\n",Npar[0]);
          mexPrintf("Y[0],Y[1],Y[2],Y[3],Y[4],Y[5]:%g,%g,%g,%g,%g,%g\n",Y[0],Y[1],Y[2],Y[3],Y[4],Y[5]);
          mexPrintf("Y[4],raymagnetic.calpha[0],raymagnetic.Brhon[0],raymagnetic.Bsn[0],raymagnetic.rn[0],Y[5],raymagnetic.BPHIn[0],raymagnetic.Rn[0]:%g,%g,%g,%g,%g,%g,%g\n",Y[4],raymagnetic.calpha[0],raymagnetic.Brhon[0],raymagnetic.Bsn[0],raymagnetic.rn[0],Y[5],raymagnetic.BPHIn[0],raymagnetic.Rn[0]);
*/        
    
        for (i=0;i<MC;i++) {
            
            dNpar0dY1 = dYdY[3][i]*raymagnetic.gradrhon[0]*raymagnetic.Brhon[0];
            dNpar0dY2 = Y[3]*raymagnetic.dgradrhondY[i]*raymagnetic.Brhon[0];
            dNpar0dY3 = Y[3]*raymagnetic.gradrhon[0]*raymagnetic.dBrhondY[i];
            dNpar0dY4 = -Y[3]*raymagnetic.gradrhon[0]*raymagnetic.Brhon[0]*dYdY[6][i];
            
            dNpar0dY = dNpar0dY1 + dNpar0dY2 + dNpar0dY3 + dNpar0dY4;
    
            dNpar1dY1 = dYdY[4][i]*(raymagnetic.calpha[0]*raymagnetic.Bsn[0] - raymagnetic.salpha[0]*raymagnetic.Brhon[0])/raymagnetic.rn[0];
            dNpar1dY2 = Y[4]*(raymagnetic.dcalphadY[i]*raymagnetic.Bsn[0] - raymagnetic.dsalphadY[i]*raymagnetic.Brhon[0])/raymagnetic.rn[0];
            dNpar1dY3 = Y[4]*(raymagnetic.calpha[0]*raymagnetic.dBsndY[i] - raymagnetic.salpha[0]*raymagnetic.dBrhondY[i])/raymagnetic.rn[0];
            dNpar1dY4 = -Y[4]*(raymagnetic.calpha[0]*raymagnetic.Bsn[0] - raymagnetic.salpha[0]*raymagnetic.Brhon[0])*dYdY[6][i]/raymagnetic.rn[0];
            dNpar1dY5 = -Y[4]*(raymagnetic.calpha[0]*raymagnetic.Bsn[0] - raymagnetic.salpha[0]*raymagnetic.Brhon[0])*raymagnetic.drndY[i]/raymagnetic.rn[0]/raymagnetic.rn[0];


            dNpar1dY = dNpar1dY1 + dNpar1dY2 + dNpar1dY3 + dNpar1dY4 + dNpar1dY5;
 
            dNpar2dY1 = dYdY[5][i]*raymagnetic.BPHIn[0]/raymagnetic.Rn[0];
            dNpar2dY2 = Y[5]*raymagnetic.dBPHIndY[i]/raymagnetic.Rn[0];
            dNpar2dY3 = -Y[5]*raymagnetic.BPHIn[0]*raymagnetic.dRndY[i]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
            dNpar2dY4 = -Y[5]*raymagnetic.BPHIn[0]*dYdY[6][i]/raymagnetic.Rn[0];
    
            dNpar2dY = dNpar2dY1 + dNpar2dY2 + dNpar2dY3 + dNpar2dY4;
        
            dNpardY[i] = cnorm*(dNpar0dY + dNpar1dY + dNpar2dY);
             
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
                    
        divN11 = raymagnetic.dRndY[0]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*Y[3]/raymagnetic.calpha[0];
        divN12 = raymagnetic.Rn[0]*raymagnetic.drndY[0]*raymagnetic.gradrhon[0]*Y[3]/raymagnetic.calpha[0];
        divN13 = raymagnetic.Rn[0]*raymagnetic.rn[0]*raymagnetic.dgradrhondY[0]*Y[3]/raymagnetic.calpha[0];
        divN14 = raymagnetic.Rn[0]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*dYdY[3][0]/raymagnetic.calpha[0];
        divN15 = -raymagnetic.Rn[0]*raymagnetic.rn[0]*raymagnetic.gradrhon[0]*Y[3]*raymagnetic.dcalphadY[0]/raymagnetic.calpha[0]/raymagnetic.calpha[0];

        divN21 = dYdY[4][1]/raymagnetic.rn[0]/raymagnetic.calpha[0]/raymagnetic.Bsn[0]/raymagnetic.B[0];
        divN22 = -Y[4]*raymagnetic.drndY[1]/raymagnetic.rn[0]/raymagnetic.rn[0]/raymagnetic.calpha[0]/raymagnetic.Bsn[0]/raymagnetic.B[0];
        divN23 = -Y[4]*raymagnetic.dcalphadY[1]/raymagnetic.rn[0]/raymagnetic.calpha[0]/raymagnetic.calpha[0]/raymagnetic.Bsn[0]/raymagnetic.B[0];
        divN24 = -Y[4]*raymagnetic.dBsndY[1]/raymagnetic.rn[0]/raymagnetic.calpha[0]/raymagnetic.Bsn[0]/raymagnetic.Bsn[0]/raymagnetic.B[0];
        divN25 = -Y[4]*raymagnetic.dBdY[1]/raymagnetic.rn[0]/raymagnetic.calpha[0]/raymagnetic.Bsn[0]/raymagnetic.B[0]/raymagnetic.B[0];

        divN31 = dYdY[5][2]/raymagnetic.Rn[0];
        divN32 = -Y[5]*raymagnetic.dRndY[2]/raymagnetic.Rn[0]/raymagnetic.Rn[0];
        
        divN1 = (divN11 + divN12 + divN13 + divN14 + divN15)*raymagnetic.gradrhon[0]*raymagnetic.calpha[0]/raymagnetic.Rn[0]/raymagnetic.rn[0];
        divN2 = (divN21 + divN22 + divN23 + divN24 + divN25)*raymagnetic.Bsn[0]*raymagnetic.B[0]*raymagnetic.calpha[0]/raymagnetic.rn[0];
        divN3 = (divN31 + divN32)/raymagnetic.Rn[0];
                        
        eikval[0] = cnorm*fabs(divN1 + divN2 + divN3)/N2[0];        
        
    } else {
        
        
        
        
        
    }
    
}


void buildXstruc(X,dNperpdY,Xxx,Xxy,Xxz,Xyy,Xyz,Xzz,dXxxdNperp,dXxydNperp,dXxzdNperp,dXyydNperp,dXyzdNperp,dXzzdNperp,dXxxdNpar,dXxydNpar,dXxzdNpar,dXyydNpar,dXyzdNpar,dXzzdNpar,dXxxdbetath,dXxydbetath,dXxzdbetath,dXyydbetath,dXyzdbetath,dXzzdbetath,dXxxdwcn,dXxydwcn,dXxzdwcn,dXyydwcn,dXyzdwcn,dXzzdwcn,dXxxdwpn2,dXxydwpn2,dXxzdwpn2,dXyydwpn2,dXyzdwpn2,dXzzdwpn2,ns,dNpardY,dwcndY,dwpn2dY,dbetathdY)
susceptibilitytensor_format X;
double complex dNperpdY[];
double complex Xxx[],Xxy[],Xxz[],Xyy[],Xyz[],Xzz[];
double complex dXxxdNperp[],dXxydNperp[],dXxzdNperp[],dXyydNperp[],dXyzdNperp[],dXzzdNperp[];
double complex dXxxdNpar[],dXxydNpar[],dXxzdNpar[],dXyydNpar[],dXyzdNpar[],dXzzdNpar[];
double complex dXxxdbetath[],dXxydbetath[],dXxzdbetath[],dXyydbetath[],dXyzdbetath[],dXzzdbetath[];
double complex dXxxdwcn[],dXxydwcn[],dXxzdwcn[],dXyydwcn[],dXyzdwcn[],dXzzdwcn[];
double complex dXxxdwpn2[],dXxydwpn2[],dXxzdwpn2[],dXyydwpn2[],dXyzdwpn2[],dXzzdwpn2[];
int ns;
double dwcndY[][MC],dwpn2dY[][MC],dbetathdY[][MC],dNpardY[];
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





void interpequil(rayparam,raymagnetic,rayprofiles,equilparam,fluctparam,Y0,Y,rayequil,rayfluctuations,flag_fluct)
rayparam_format rayparam;
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
equilparam_format equilparam;
fluctparam_format fluctparam;
double Y0[],Y[];
rayequil_format rayequil;
rayfluctuations_format rayfluctuations;
int flag_fluct;
{
/* interpolation from numerical equilibrium data*/
    
    double dTidY[equilparam.ns[0]],dnidY[equilparam.ns[0]];
    double d2TidY2[equilparam.ns[0]],d2nidY2[equilparam.ns[0]];
    double x,R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho;
    double y,Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho;
    double BR=0,dBRdrho=0,dBRdtheta=0,dBRdphi=0;
    double BZ=0,dBZdrho=0,dBZdtheta=0,dBZdphi=0;
    double BPHI=0,dBPHIdrho=0,dBPHIdtheta=0,dBPHIdphi=0;
    double dRstardpsin,ddRstardpsindrho;
   
    double icm,idcmdrho,cm,cn0,dcn0drho;
    
    double phaseB,dphaseBdrho,dphaseBdtheta,dphaseBdphi;
    double phasene,dphasenedrho,dphasenedtheta,dphasenedphi;
        
    double nefsne,dnefsnedrho,dnefsnedtheta,dnefsnedphi;
    double TefsTe,dTefsTedrho,dTefsTedtheta,dTefsTedphi;
    double znifszni[equilparam.ns[0]],dznifsznidrho[equilparam.ns[0]],dznifsznidtheta[equilparam.ns[0]],dznifsznidphi[equilparam.ns[0]];
    double zTifszTi[equilparam.ns[0]],dzTifszTidrho[equilparam.ns[0]],dzTifszTidtheta[equilparam.ns[0]],dzTifszTidphi[equilparam.ns[0]];
    
    double sfBx[fluctparam.B_nmodel[0]],dsfBxdrho[fluctparam.B_nmodel[0]],dsfBxdtheta[fluctparam.B_nmodel[0]],d2sfBxdtheta2[fluctparam.B_nmodel[0]],d2sfBxdthetadrho[fluctparam.B_nmodel[0]];
    double sfBy[fluctparam.B_nmodel[0]],dsfBydrho[fluctparam.B_nmodel[0]],dsfBydtheta[fluctparam.B_nmodel[0]],d2sfBydtheta2[fluctparam.B_nmodel[0]],d2sfBydthetadrho[fluctparam.B_nmodel[0]];
    double sfBz[fluctparam.B_nmodel[0]],dsfBzdrho[fluctparam.B_nmodel[0]],dsfBzdtheta[fluctparam.B_nmodel[0]],d2sfBzdtheta2[fluctparam.B_nmodel[0]],d2sfBzdthetadrho[fluctparam.B_nmodel[0]];
    double BxfsB,dBxfsBdrho,dBxfsBdtheta,dBxfsBdphi;
    double ByfsB,dByfsBdrho,dByfsBdtheta,dByfsBdphi;
    double BzfsB,dBzfsBdrho,dBzfsBdtheta,dBzfsBdphi;
    double BrhofsB,dBrhofsBdrho,dBrhofsBdtheta,dBrhofsBdphi;
    double BsfsB,dBsfsBdrho,dBsfsBdtheta,dBsfsBdphi;
    double BphifsB,dBphifsBdrho,dBphifsBdtheta,dBphifsBdphi;    

    double cta,dctadrho,dctadtheta,dctadphi;
    double sta,dstadrho,dstadtheta,dstadphi;
    
    double Brho,Bs,Bphi,B;
    double Brhon,Bsn,Bphin;       
    double dBrhodrho,dBrhodtheta,dBrhodphi;       
    double dBsdrho,dBsdtheta,dBsdphi;       
    double dBphidrho,dBphidtheta,dBphidphi;       
    double dBdrho,dBdtheta,dBdphi;
    
    double Brho0,dBrho0drho,dBrho0dtheta;    
    double lambda,dlambdadrho,dlambdadtheta;
    double rhorip,drhodrhorip,drhodthetarip,drhodphirip;
    
    double val,dvaldrho,d2valdrho2;
    double zval[equilparam.ns[0]],dzvaldrho[equilparam.ns[0]],d2zvaldrho2[equilparam.ns[0]];
    
    double ne_sep,dnedrho_sep;
    double rho_neeq0;
    double nerip,dnedrhorip,dnedthetarip,dnedphirip;
    double ne_tilde,dnedrho_tilde,dnedtheta_tilde,dnedphi_tilde;
    double ner_tilde,dnerdrho_tilde,dnerdtheta_tilde,dnerdphi_tilde;
    
    double Te_sep,dTedrho_sep;
    double rho_Teeq0;
    double Terip,dTedrhorip,dTedthetarip,dTedphirip;
    double Te_tilde,dTedrho_tilde,dTedtheta_tilde,dTedphi_tilde;
    double Ter_tilde,dTerdrho_tilde,dTerdtheta_tilde,dTerdphi_tilde;
    
    double zni_sep[equilparam.ns[0]],dznidrho_sep[equilparam.ns[0]];
    double rho_znieq0[equilparam.ns[0]];
    double znirip[equilparam.ns[0]],dznidrhorip[equilparam.ns[0]],dznidthetarip[equilparam.ns[0]],dznidphirip[equilparam.ns[0]];
    double zni_tilde[equilparam.ns[0]],dznidrho_tilde[equilparam.ns[0]],dznidtheta_tilde[equilparam.ns[0]],dznidphi_tilde[equilparam.ns[0]];
    double znir_tilde[equilparam.ns[0]],dznirdrho_tilde[equilparam.ns[0]],dznirdtheta_tilde[equilparam.ns[0]],dznirdphi_tilde[equilparam.ns[0]];
    
    double zTi_sep[equilparam.ns[0]],dzTidrho_sep[equilparam.ns[0]];
    double rho_zTieq0[equilparam.ns[0]];
    double zTirip[equilparam.ns[0]],dzTidrhorip[equilparam.ns[0]],dzTidthetarip[equilparam.ns[0]],dzTidphirip[equilparam.ns[0]];
    double zTi_tilde[equilparam.ns[0]],dzTidrho_tilde[equilparam.ns[0]],dzTidtheta_tilde[equilparam.ns[0]],dzTidphi_tilde[equilparam.ns[0]];
    double zTir_tilde[equilparam.ns[0]],dzTirdrho_tilde[equilparam.ns[0]],dzTirdtheta_tilde[equilparam.ns[0]],dzTirdphi_tilde[equilparam.ns[0]];
              
    int il,im,in,iphase;
    
    double dl,dm;
    double phase,dphasedrho,dphasedtheta,dphasedphi;
    double Flambda,dFlambdadrho,dFlambdadtheta,dFlambdadphi;
    double Fdelta,dFdeltadrho,dFdeltadtheta,dFdeltadphi;
    
    double L_rho,dL_rhodrho,dL_rhodtheta,dL_rhodphi;
    double xq,dxqdrho,dxqdtheta,dxqdphi;
    double xL_theta,dxL_thetadrho,dxL_thetadtheta,dxL_thetadphi;
    double xL_perp,dxL_perpdrho,dxL_perpdtheta,dxL_perpdphi;
    double XL_phi,dXL_phidrho,dXL_phidtheta,dXL_phidphi;
   
    double ac,dacdrho,dacdtheta,dacdphi;
    double u_l,du_ldrho,du_ldtheta,du_ldphi,expu_l,dexpu_ldrho,dexpu_ldtheta,dexpu_ldphi;
    double u_m,du_mdrho,du_mdtheta,du_mdphi,expu_m,dexpu_mdrho,dexpu_mdtheta,dexpu_mdphi;
    double u_n,du_ndrho,du_ndtheta,du_ndphi,expu_n,dexpu_ndrho,dexpu_ndtheta,dexpu_ndphi;
    double almn,dalmndrho,dalmndtheta,dalmndphi;
    double alm,dalmdrho,dalmdtheta,dalmdphi;
    double am,damdrho,damdtheta,damdphi;
    double curtheta,dcurthetadrho,dcurthetadtheta,dcurthetadphi;
    
    double kperp,dkperpdrho,dkperpdtheta,dkperpdphi;
    
    double ht=0,dht=0,d2ht=0;
    double xx=0,dxxdrho=0,dxxdtheta=0,dxxdphi=0;
    
    double dummy,dummy1,dummy2;
    
    int i,j,is,imodel;
    
    /* Axisymmetric magnetic field equilibrium interpolation */
    
    ppvald_1D(rayequil.dxstardpsin_fit,rayparam.dS[0],Y[0],&dRstardpsin,&ddRstardpsindrho,&dummy1);
    
    ppvald_2D(rayequil.x_fit,rayparam.dS[0],Y[0],Y[1],&x,&dRdrho,&dRdtheta,&d2Rdtheta2,&d2Rdthetadrho);
    R = x + equilparam.Rp[0];
    ppvald_2D(rayequil.y_fit,rayparam.dS[0],Y[0],Y[1],&y,&dZdrho,&dZdtheta,&d2Zdtheta2,&d2Zdthetadrho);
    Z = y + equilparam.Zp[0];
    ppvald_2D(rayequil.Bx_fit,rayparam.dS[0],Y[0],Y[1],&BR,&dBRdrho,&dBRdtheta,&dummy1,&dummy2);
    ppvald_2D(rayequil.By_fit,rayparam.dS[0],Y[0],Y[1],&BZ,&dBZdrho,&dBZdtheta,&dummy1,&dummy2);
    ppvald_2D(rayequil.BPHI_fit,rayparam.dS[0],Y[0],Y[1],&BPHI,&dBPHIdrho,&dBPHIdtheta,&dummy1,&dummy2);
    
    build_raymagnetic(Y[1],raymagnetic,equilparam,R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho,Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho,BR,dBRdrho,dBRdtheta,dBRdphi,BZ,dBZdrho,dBZdtheta,dBZdphi,BPHI,dBPHIdrho,dBPHIdtheta,dBPHIdphi,dRstardpsin,ddRstardpsindrho);     

    if (equilparam.zZi[0] > 0) { /* Plasma case, otherwise vacuum */
    		        	
        ppvald_1D(rayequil.Te_fit,rayparam.dS[0],Y[0],&rayprofiles.Te[0],&rayprofiles.dTedY[0],&rayprofiles.d2TedY2[0]);
        rayprofiles.dTedY[1] = 0;/*Te is taken constant on a magnetic flux surface */
        rayprofiles.dTedY[2] = 0;/*Te is taken constant on a magnetic flux surface */
                         
        ppvald_1D(rayequil.ne_fit,rayparam.dS[0],Y[0],&rayprofiles.ne[0],&rayprofiles.dnedY[0],&rayprofiles.d2nedY2[0]);
        rayprofiles.dnedY[1] = 0;/*ne is taken constant on a magnetic flux surface */
     	rayprofiles.dnedY[2] = 0;/*ne is taken constant on a magnetic flux surface */
  
        /* mexPrintf("Y[0],Y[1],Y[2],ne[0]:%g,%g,%g,%g\n",Y[0],Y[1],Y[2],rayprofiles.ne[0]); */
        
        ppvald_1D(rayequil.zTi_fit,rayparam.dS[0],Y[0],rayprofiles.zTi,dTidY,d2TidY2);
        ppvald_1D(rayequil.zni_fit,rayparam.dS[0],Y[0],rayprofiles.zni,dnidY,d2nidY2);
        
        for (is=0;is<equilparam.ns[0];is++) {
                
            rayprofiles.dzTidY[is][0] = dTidY[is];
            rayprofiles.dzTidY[is][1] = 0.0;/*ni is taken constant on a magnetic flux surface */
            rayprofiles.dzTidY[is][2] = 0.0;/*ni is taken constant on a magnetic flux surface */
            rayprofiles.d2zTidY2[is][0] = d2TidY2[is];
            rayprofiles.d2zTidY2[is][1] = 0.0;/*ni is taken constant on a magnetic flux surface */
            rayprofiles.d2zTidY2[is][2] = 0.0;/*ni is taken constant on a magnetic flux surface */

            rayprofiles.dznidY[is][0] = dnidY[is];
            rayprofiles.dznidY[is][1] = 0.0;/*ni is taken constant on a magnetic flux surface */
            rayprofiles.dznidY[is][2] = 0.0;/*ni is taken constant on a magnetic flux surface */       
            rayprofiles.d2znidY2[is][0] = d2nidY2[is];
            rayprofiles.d2znidY2[is][1] = 0.0;/*ni is taken constant on a magnetic flux surface */
            rayprofiles.d2znidY2[is][2] = 0.0;/*ni is taken constant on a magnetic flux surface */       
        }

        /*   
        
        for (i=0;i<equilparam.ns[0];i++) {
            mexPrintf("i,Ti,dzTidY[0],dzTidY[1],dzTidY[2],dzTidY[3],dzTidY[4],dzTidY[5],dzTidY[6]:%d,%g,%g,%g,%g,%g,%g,%g,%g\n",i,rayprofiles.zTi[i],rayprofiles.dzTidY[i][0],rayprofiles.dzTidY[i][1],rayprofiles.dzTidY[i][2],rayprofiles.dzTidY[i][3],rayprofiles.dzTidY[i][4],rayprofiles.dzTidY[i][5],rayprofiles.dzTidY[i][6]);
            mexPrintf("i,ni,dznidY[0],dznidY[1],dznidY[2],dznidY[3],dznidY[4],dznidY[5],dznidY[6]:%d,%g,%g,%g,%g,%g,%g,%g,%g\n",i,rayprofiles.zni[i],rayprofiles.dznidY[i][0],rayprofiles.dznidY[i][1],rayprofiles.dznidY[i][2],rayprofiles.dznidY[i][3],rayprofiles.dznidY[i][4],rayprofiles.dznidY[i][5],rayprofiles.dznidY[i][6]);
        }
         
		mexPrintf("rho,theta:%g,%g\n",Y[0],Y[1]);
        mexPrintf("Te[0],dTedY[0],dTedY[1],ne[0],dnedY[0],dnedY[1]:%g,%g,%g,%g,%g,%g\n",rayprofiles.Te[0],rayprofiles.dTedY[0],rayprofiles.dTedY[1],rayprofiles.ne[0],rayprofiles.dnedY[0],rayprofiles.dnedY[1]);
        
        for (is=0;is<equilparam.ns[0];is++) {
           mexPrintf("is,zTi[is],dzTidY[is][0],dzTidY[is][1],zni[is],dznidY[is][0],dznidY[is][1]:%d,%g,%g,%g,%g,%g,%g\n",is,rayprofiles.zTi[is],rayprofiles.dzTidY[is][0],rayprofiles.dzTidY[is][1],rayprofiles.zni[is],rayprofiles.dznidY[is][0],rayprofiles.dznidY[is][1]);
        }
        
        */
                
        /* Contribution of plasma fluctuations or modulations */ 
        
        if (flag_fluct == 1) { /* no fluctuation in vacuum */
            
            /*Initialisation of the perturbations */
            
            rhorip = Y[0]; 
            drhodrhorip = 1.0; 
            drhodthetarip = 0.0;
            drhodphirip = 0.0;
               
	        BrhofsB = 0.0;
	        dBrhofsBdrho = 0.0;
	        dBrhofsBdtheta = 0.0;
	        dBrhofsBdphi = 0.0;
               
            BsfsB = 0.0;
	        dBsfsBdrho = 0.0;
	        dBsfsBdtheta = 0.0;
	        dBsfsBdphi = 0.0;
               	           
            BphifsB = 0.0;
	        dBphifsBdrho = 0.0;
	        dBphifsBdtheta = 0.0;
	        dBphifsBdphi = 0.0;
            
            nefsne = 0.0;
	        dnefsnedrho = 0.0;
	        dnefsnedtheta = 0.0;
	        dnefsnedphi = 0.0;
            
            TefsTe = 0.0;
	        dTefsTedrho = 0.0;
	        dTefsTedtheta = 0.0;
	        dTefsTedphi = 0.0;
            
            for (is=0;is<equilparam.ns[0];is++) {
                
                znifszni[is] = 0.0;
                dznifsznidrho[is] = 0.0;
                dznifsznidtheta[is] = 0.0;
                dznifsznidphi[is] = 0.0;

                zTifszTi[is] = 0.0;
                dzTifszTidrho[is] = 0.0;
                dzTifszTidtheta[is] = 0.0;
                dzTifszTidphi[is] = 0.0;
            }
                       
            ppvald_0D(rayfluctuations.L_rho,&L_rho);
            dL_rhodrho = 0.0;
            dL_rhodtheta = 0.0;
            dL_rhodphi = 0.0;
            
            ppvald_1D(rayfluctuations.xq_fit,rayparam.dS[0],Y[0],&xq,&dxqdrho,&dummy);
            dxqdtheta = 0.0;
            dxqdphi = 0.0;
            
            ppvald_1D(rayfluctuations.xL_theta_fit,rayparam.dS[0],Y[0],&xL_theta,&dxL_thetadrho,&dummy);
            dxL_thetadtheta = 0.0;
            dxL_thetadphi = 0.0;
            
            ppvald_1D(rayfluctuations.xL_perp_fit,rayparam.dS[0],Y[0],&xL_perp,&dxL_perpdrho,&dummy);
            dxL_perpdtheta = 0.0;
            dxL_perpdphi = 0.0;
            
            ppvald_2D(rayfluctuations.XL_phi_fit,rayparam.dS[0],Y[0],Y[1],&XL_phi,&dXL_phidrho,&dXL_phidtheta,&dummy,&dummy);
            dXL_phidphi =0.0;
        
            ppvald_2D(rayfluctuations.Xcn_fit,rayparam.dS[0],Y[0],Y0[1],&cn0,&dcn0drho,&dummy,&dummy,&dummy);/*geometrical factor for fluctuations phase, kpar = 0 drift wave model */
            ppvald_2D(rayfluctuations.Xcm_fit,rayparam.dS[0],Y[0],Y[1],&cm,&dummy,&dummy,&dummy,&dummy);/*geometrical factor for fluctuations phase, kpar = 0 drift wave model */
            ppvali_2D(rayfluctuations.Xcm_fit,rayparam.dS[0],Y[0],Y0[1],Y[1],&icm,&idcmdrho);/*geometrical factor for fluctuations phase, kpar = 0 drift wave model */  
                               
            /*
            mexPrintf("rho,theta,phi,gphase,dgphasedrho,dgphasedtheta,dgphasedphi:%g,%g,%g,%g,%g,%g,%g\n",Y[0],Y[1],Y[2],gphase,dgphasedrho,dgphasedtheta,dgphasedphi);
            mexPrintf("cn0,dcn0drho,icm,idcmdrho,cm:%g,%g,%g,%g,%g\n",cn0,dcn0drho,icm,idcmdrho,cm);
            */
            
            if (fluctparam.ne_nmodel[0] > 0) {/* Electron density statistical fluctuations */
	           
	           for (imodel=0; imodel < fluctparam.ne_nmodel[0]; imodel++) {
                   
                    dl = fluctparam.ne_lmax[imodel][0] - fluctparam.ne_lmin[imodel][0] + 1.0;
                    dm = fluctparam.ne_mmax[imodel][0] - fluctparam.ne_mmin[imodel][0] + 1.0;

                    Flambda = (1.0 + fluctparam.ne_polmode[imodel][0] + (1.0 - fluctparam.ne_polmode[imodel][0])*cos(Y[1]))/2.0;
                    dFlambdadrho = 0.0;
                    dFlambdadtheta = -(1.0 - fluctparam.ne_polmode[imodel][0])*sin(Y[1])/2.0;
                    dFlambdadphi = 0.0;
                    
                    Fdelta = exp(-log(2.0)*pow(Y[0] - fluctparam.ne_sigmar_rho[imodel][0],2.0)/pow(fluctparam.ne_sigmar_hwhm[imodel][0],2));
                    dFdeltadrho = -Fdelta*2.0*log(2.0)*(Y[0] - fluctparam.ne_sigmar_rho[imodel][0])/pow(fluctparam.ne_sigmar_hwhm[imodel][0],2);                   
                    dFdeltadtheta = 0.0;
                    dFdeltadphi = 0.0;
                    
                    xx = 0;
                    dxxdrho = 0;                                                                 
                    dxxdtheta = 0; 
                    dxxdphi = 0; 
                    
                    if (fluctparam.ne_model[imodel][0] == 1) {/* 3-D Gaussian model (rho,theta,phi), relative epsi values (benchmark of C3PO) */ 

                        ac = 4.0*pow(PI,0.75)*fluctparam.ne_sigmar_max[imodel][0]*sqrt(fluctparam.ne_epsi_rho[imodel][0]*fluctparam.ne_epsi_theta[imodel][0]*fluctparam.ne_epsi_phi[imodel][0]);
                        
                        for (il = fluctparam.ne_lmin[imodel][0];il <= fluctparam.ne_lmax[imodel][0];il++) {
                            for (im = fluctparam.ne_mmin[imodel][0];im <= fluctparam.ne_mmax[imodel][0];im++) {
                                for (in = fluctparam.ne_nmin[imodel][0];in <= fluctparam.ne_nmax[imodel][0];in++) {
                                    
                                    iphase = (int)dl*(int)dm*(in-(int)fluctparam.ne_nmin[imodel][0]) + (int)dl*(im-(int)fluctparam.ne_mmin[imodel][0]) + (il-(int)fluctparam.ne_lmin[imodel][0]) + 1;
                                    
                                    phase = 2*PI*il*Y[0] + im*Y[1] + in*Y[2] + fluctparam.ne_phase[imodel][iphase-1];
                                    dphasedrho = 2*PI*il;
                                    dphasedtheta = im;
                                    dphasedphi = in;
                                    
                                    u_l = PI*fluctparam.ne_epsi_rho[imodel][0]*il;
                                    u_m = PI*fluctparam.ne_epsi_theta[imodel][0]*im;
                                    u_n = PI*fluctparam.ne_epsi_phi[imodel][0]*in;
                        
                                    expu_l = exp(-u_l*u_l/2);
                                    expu_m = exp(-u_m*u_m/2);
                                    expu_n = exp(-u_n*u_n/2);
                                                                        
                                    almn = expu_l*expu_m*expu_n;
                                                                         
                                    xx += ac*almn*Flambda*Fdelta*sin(phase);
                                    dxxdrho += ac*almn*Flambda*(Fdelta*cos(phase)*dphasedrho + dFdeltadrho*sin(phase));                                                                 
                                    dxxdtheta += ac*almn*Fdelta*(Flambda*cos(phase)*dphasedtheta + dFlambdadtheta*sin(phase));
                                    dxxdphi += ac*almn*Flambda*Fdelta*cos(phase)*dphasedphi;
                                }
                            }
                        }
                                    
                        /* convolution to avoid negative density values. No restriction on positive values, ht(x) = x */ 

                        halftanh(xx,&ht,&dht,&d2ht);

                        nefsne += ht;
                        dnefsnedrho += dht*dxxdrho;                                                                 
                        dnefsnedtheta += dht*dxxdtheta;
                        dnefsnedphi += dht*dxxdphi;                       
                        
                     }    
                        
                     if (fluctparam.ne_model[imodel][0] == 2) {/* 3-D Gaussian model (rho,theta,phi), absolute epsi values (benchmark of C3PO) */ 
                       
                        ac = 4.0*pow(PI,0.75)*fluctparam.ne_sigmar_max[imodel][0]*sqrt(fluctparam.ne_epsi_rho[imodel][0]*fluctparam.ne_epsi_theta[imodel][0]*fluctparam.ne_epsi_phi[imodel][0]/L_rho/xL_theta/XL_phi);
                        dacdrho = -0.5*ac*(dL_rhodrho/L_rho + dxL_thetadrho/xL_theta +  dXL_phidrho/XL_phi);
                        dacdtheta = -0.5*ac*(dL_rhodtheta/L_rho + dxL_thetadtheta/xL_theta + dXL_phidtheta/XL_phi);
                        dacdphi = -0.5*ac*(dL_rhodphi/L_rho + dxL_thetadphi/xL_theta + dXL_phidphi/XL_phi);
                        
                        for (il = fluctparam.ne_lmin[imodel][0];il <= fluctparam.ne_lmax[imodel][0];il++) {
                            for (im = fluctparam.ne_mmin[imodel][0];im <= fluctparam.ne_mmax[imodel][0];im++) {
                                for (in = fluctparam.ne_nmin[imodel][0];in <= fluctparam.ne_nmax[imodel][0];in++) {
                                    
                                    iphase = (int)dl*(int)dm*(in-(int)fluctparam.ne_nmin[imodel][0]) + (int)dl*(im-(int)fluctparam.ne_mmin[imodel][0]) + (il-(int)fluctparam.ne_lmin[imodel][0]) + 1;
                                    
                                    phase = 2*PI*il*Y[0] + im*Y[1] + in*Y[2] + fluctparam.ne_phase[imodel][iphase-1];
                                    dphasedrho = 2*PI*il;
                                    dphasedtheta = im;
                                    dphasedphi = in;
                                    
                                    u_l = PI*fluctparam.ne_epsi_rho[imodel][0]*il/L_rho;
                                    u_m = PI*fluctparam.ne_epsi_theta[imodel][0]*im/xL_theta;
                                    u_n = PI*fluctparam.ne_epsi_phi[imodel][0]*in/XL_phi;
                                    
                                    du_ldrho = -u_l/L_rho*dL_rhodrho;
                                    du_mdrho = -u_m/xL_theta*dxL_thetadrho;
                                    du_ndrho = -u_n/XL_phi*dXL_phidrho;
                                    
                                    du_ldtheta = -u_l/L_rho*dL_rhodtheta;
                                    du_mdtheta = -u_m/xL_theta*dxL_thetadtheta;
                                    du_ndtheta = -u_n/XL_phi*dXL_phidtheta;
                                    
                                    du_ldphi = -u_l/L_rho*dL_rhodphi;
                                    du_mdphi = -u_m/xL_theta*dxL_thetadphi;
                                    du_ndphi = -u_n/XL_phi*dXL_phidphi;
                                    
                                    expu_l = exp(-u_l*u_l/2);
                                    expu_m = exp(-u_m*u_m/2);
                                    expu_n = exp(-u_n*u_n/2);
                                    almn = expu_l*expu_m*expu_n;
                                    
                                    dexpu_ldrho = -expu_l*u_l*du_ldrho;
                                    dexpu_mdrho = -expu_m*u_m*du_mdrho;
                                    dexpu_ndrho = -expu_n*u_n*du_ndrho;
                                    dalmndrho = dexpu_ldrho*expu_m*expu_n + expu_l*dexpu_mdrho*expu_n + expu_l*expu_m*dexpu_ndrho;
                                    
                                    dexpu_ldtheta = -expu_l*u_l*du_ldtheta;
                                    dexpu_mdtheta = -expu_m*u_m*du_mdtheta;
                                    dexpu_ndtheta = -expu_n*u_n*du_ndtheta; 
                                    dalmndtheta = dexpu_ldtheta*expu_m*expu_n + expu_l*dexpu_mdtheta*expu_n + expu_l*expu_m*dexpu_ndtheta;                        
                                    
                                    dexpu_ldphi = -expu_l*u_l*du_ldphi;
                                    dexpu_mdphi = -expu_m*u_m*du_mdphi;
                                    dexpu_ndphi = -expu_n*u_n*du_ndphi;
                                    dalmndphi = dexpu_ldphi*expu_m*expu_n + expu_l*dexpu_mdphi*expu_n + expu_l*expu_m*dexpu_ndphi;
                                      
                                    xx += ac*Flambda*Fdelta*almn*sin(phase);
                                    dxxdrho += dacdrho*Flambda*Fdelta*almn*sin(phase) + ac*dFlambdadrho*Fdelta*almn*sin(phase) + ac*Flambda*dFdeltadrho*almn*sin(phase) + ac*Flambda*Fdelta*dalmndrho*sin(phase) + ac*Flambda*Fdelta*almn*cos(phase)*dphasedrho;                   
                                    dxxdtheta += dacdtheta*Flambda*Fdelta*almn*sin(phase) + ac*dFlambdadtheta*Fdelta*almn*sin(phase) + ac*Flambda*dFdeltadtheta*almn*sin(phase) + ac*Flambda*Fdelta*dalmndtheta*sin(phase) + ac*Flambda*Fdelta*almn*cos(phase)*dphasedtheta;
                                    dxxdphi += dacdphi*Flambda*Fdelta*almn*sin(phase) + ac*dFlambdadphi*Fdelta*almn*sin(phase) + ac*Flambda*dFdeltadphi*almn*sin(phase) + ac*Flambda*Fdelta*dalmndphi*sin(phase) + ac*Flambda*Fdelta*almn*cos(phase)*dphasedphi;
                                }
                            }
                        } 
                        
                        /* convolution to avoid negative density values. No restriction on positive values, ht(x) = x */ 
                        
                        halftanh(xx,&ht,&dht,&d2ht);

                        nefsne += ht;
                        dnefsnedrho += dht*dxxdrho;                                                                 
                        dnefsnedtheta += dht*dxxdtheta;
                        dnefsnedphi += dht*dxxdphi;   
                     }

                     if (fluctparam.ne_model[imodel][0] == 3) {/* 2-D Gaussian model (rho,curtheta), absolute epsi values (drift wave model, global cylindrical phase approx.) */ 
                        
                        /* Note that epsi_perp = fluctparam.ne_epsi_theta */
                        
                        ac = 2.0*sqrt(2.0*PI)*fluctparam.ne_sigmar_max[imodel][0]*sqrt(fluctparam.ne_epsi_rho[imodel][0]*fluctparam.ne_epsi_theta[imodel][0]/L_rho/xL_perp);
                        dacdrho = -0.5*ac*(dL_rhodrho/L_rho + dxL_perpdrho/xL_perp);
                        dacdtheta = -0.5*ac*(dL_rhodtheta/L_rho + dxL_perpdtheta/xL_perp);
                        dacdphi = -0.5*ac*(dL_rhodphi/L_rho + dxL_perpdphi/xL_perp);
                        
                        for (il = fluctparam.ne_lmin[imodel][0];il <= fluctparam.ne_lmax[imodel][0];il++) {
                            for (im = fluctparam.ne_mmin[imodel][0];im <= fluctparam.ne_mmax[imodel][0];im++) {
                                    
                                iphase = (int)dl*(im-(int)fluctparam.ne_mmin[imodel][0]) + (il-(int)fluctparam.ne_lmin[imodel][0]) + 1;

                                curtheta = xq*Y[1] - Y[2];
                                dcurthetadrho = dxqdrho*Y[1];
                                dcurthetadtheta = dxqdtheta*Y[1] + xq;
                                dcurthetadphi = dxqdphi*Y[1]-1.0;
                                
                                phase = 2*PI*il*Y[0] + im*curtheta + fluctparam.ne_phase[imodel][iphase-1];
                                dphasedrho = 2*PI*il + im*dcurthetadrho;
                                dphasedtheta = im*dcurthetadtheta;
                                dphasedphi = im*dcurthetadphi;

                                u_l = PI*fluctparam.ne_epsi_rho[imodel][0]*il/L_rho;
                                u_m = PI*fluctparam.ne_epsi_theta[imodel][0]*im/xL_perp;

                                du_ldrho = -u_l/L_rho*dL_rhodrho;
                                du_mdrho = -u_m/xL_perp*dxL_perpdrho;

                                du_ldtheta = -u_l/L_rho*dL_rhodtheta;
                                du_mdtheta = -u_m/xL_perp*dxL_perpdtheta;

                                du_ldphi = -u_l/L_rho*dL_rhodphi;
                                du_mdphi = -u_m/xL_perp*dxL_perpdphi;

                                expu_l = exp(-u_l*u_l/2);
                                expu_m = exp(-u_m*u_m/2);
                                alm = expu_l*expu_m;

                                dexpu_ldrho = -expu_l*u_l*du_ldrho;
                                dexpu_mdrho = -expu_m*u_m*du_mdrho;
                                dalmdrho = dexpu_ldrho*expu_m + expu_l*dexpu_mdrho;

                                dexpu_ldtheta = -expu_l*u_l*du_ldtheta;
                                dexpu_mdtheta = -expu_m*u_m*du_mdtheta;
                                dalmdtheta = dexpu_ldtheta*expu_m + expu_l*dexpu_mdtheta;                        

                                dexpu_ldphi = -expu_l*u_l*du_ldphi;
                                dexpu_mdphi = -expu_m*u_m*du_mdphi;
                                dalmdphi = dexpu_ldphi*expu_m + expu_l*dexpu_mdphi;
                                
                                xx += ac*Flambda*Fdelta*alm*sin(phase);
                                dxxdrho += dacdrho*Flambda*Fdelta*alm*sin(phase) + ac*dFlambdadrho*Fdelta*alm*sin(phase) + ac*Flambda*dFdeltadrho*alm*sin(phase) + ac*Flambda*Fdelta*dalmdrho*sin(phase) + ac*Flambda*Fdelta*alm*cos(phase)*dphasedrho;                   
                                dxxdtheta += dacdtheta*Flambda*Fdelta*alm*sin(phase) + ac*dFlambdadtheta*Fdelta*alm*sin(phase) + ac*Flambda*dFdeltadtheta*alm*sin(phase) + ac*Flambda*Fdelta*dalmdtheta*sin(phase) + ac*Flambda*Fdelta*alm*cos(phase)*dphasedtheta;
                                dxxdphi += dacdphi*Flambda*Fdelta*alm*sin(phase) + ac*dFlambdadphi*Fdelta*alm*sin(phase) + ac*Flambda*dFdeltadphi*alm*sin(phase) + ac*Flambda*Fdelta*dalmdphi*sin(phase) + ac*Flambda*Fdelta*alm*cos(phase)*dphasedphi;

                            }
                        }  
                        
                        /* convolution to avoid negative density values. No restriction on positive values, ht(x) = x */ 

                        halftanh(xx,&ht,&dht,&d2ht);

                        nefsne += ht;
                        dnefsnedrho += dht*dxxdrho;                                                                 
                        dnefsnedtheta += dht*dxxdtheta;
                        dnefsnedphi += dht*dxxdphi;      
                     }

                     if (fluctparam.ne_model[imodel][0] == 4) {/* 1-D Gaussian model (rho,curtheta), absolute epsi values (drift wave model, global cylindrical phase approx.) */ 
                        
                        /* Note that epsi_perp = fluctparam.ne_epsi_theta */
                        
                        ac = 2.0*sqrt(sqrt(PI))*fluctparam.ne_sigmar_max[imodel][0]*sqrt(fluctparam.ne_epsi_theta[imodel][0]/xL_perp);
                        dacdrho = -0.5*ac*dxL_perpdrho/xL_perp;
                        dacdtheta = -0.5*ac*dxL_perpdtheta/xL_perp;
                        dacdphi = -0.5*ac*dxL_perpdphi/xL_perp;
                        
                        for (im = fluctparam.ne_mmin[imodel][0];im <= fluctparam.ne_mmax[imodel][0];im++) {
                                    
                            iphase = (im-(int)fluctparam.ne_mmin[imodel][0]) + 1;

                            curtheta = xq*(Y[1] - Y0[1]) - (Y[2] - Y0[2]);
                            dcurthetadrho = dxqdrho*(Y[1] - Y0[1]);
                            dcurthetadtheta = dxqdtheta*Y[1] + xq;
                            dcurthetadphi = dxqdphi*Y[1] - 1.0;

                            phase = im*curtheta + fluctparam.ne_phase[imodel][iphase-1];
                            dphasedrho = im*dcurthetadrho;
                            dphasedtheta = im*dcurthetadtheta;
                            dphasedphi = im*dcurthetadphi;
                            
                            u_m = PI*fluctparam.ne_epsi_theta[imodel][0]*im/xL_perp;

                            du_mdrho = -u_m/xL_perp*dxL_perpdrho;
                            
                            du_mdtheta = -u_m/xL_perp*dxL_perpdtheta;

                            du_mdphi = -u_m/xL_perp*dxL_perpdphi;
                            
                            expu_m = exp(-u_m*u_m/2);
                            am = expu_m;
                            
                            damdrho = -expu_m*u_m*du_mdrho;

                            damdtheta = -expu_m*u_m*du_mdtheta;

                            damdphi = -expu_m*u_m*du_mdphi;

                            xx += ac*Flambda*Fdelta*am*sin(phase);
                            dxxdrho += dacdrho*Flambda*Fdelta*am*sin(phase) + ac*dFlambdadrho*Fdelta*am*sin(phase) + ac*Flambda*dFdeltadrho*am*sin(phase) + ac*Flambda*Fdelta*damdrho*sin(phase) + ac*Flambda*Fdelta*am*cos(phase)*dphasedrho;                   
                            dxxdtheta += dacdtheta*Flambda*Fdelta*am*sin(phase) + ac*dFlambdadtheta*Fdelta*am*sin(phase) + ac*Flambda*dFdeltadtheta*am*sin(phase) + ac*Flambda*Fdelta*damdtheta*sin(phase) + ac*Flambda*Fdelta*am*cos(phase)*dphasedtheta;
                            dxxdphi += dacdphi*Flambda*Fdelta*am*sin(phase) + ac*dFlambdadphi*Fdelta*am*sin(phase) + ac*Flambda*dFdeltadphi*am*sin(phase) + ac*Flambda*Fdelta*damdphi*sin(phase) + ac*Flambda*Fdelta*am*cos(phase)*dphasedphi;
                                    
                        } 
                        
                        /* convolution to avoid negative density values. No restriction on positive values, ht(x) = x */ 


                        halftanh(xx,&ht,&dht,&d2ht);

                        nefsne += ht;
                        dnefsnedrho += dht*dxxdrho;                                                                 
                        dnefsnedtheta += dht*dxxdtheta;
                        dnefsnedphi += dht*dxxdphi;    
                     }

                        
                     if (fluctparam.ne_model[imodel][0] == 5) {/* 1-D Gaussian model (rho,cm,cn), absolute epsi values (drift wave model, local phase approx. ) */ 
                        
                        /* Note that epsi_perp = fluctparam.ne_epsi_theta */
                        
                        ac = 2.0*sqrt(sqrt(PI))*fluctparam.ne_sigmar_max[imodel][0]*sqrt(fluctparam.ne_epsi_theta[imodel][0]/xL_perp);
                        dacdrho = -0.5*ac*dxL_perpdrho/xL_perp;
                        dacdtheta = -0.5*ac*dxL_perpdtheta/xL_perp;
                        dacdphi = -0.5*ac*dxL_perpdphi/xL_perp;
                        
                        for (im = fluctparam.ne_mmin[imodel][0];im <= fluctparam.ne_mmax[imodel][0];im++) {
                                    
                            iphase = (im-(int)fluctparam.ne_mmin[imodel][0]) + 1;

                            kperp = 2*PI*im/xL_perp;
                            dkperpdrho = -kperp/xL_perp*dxL_perpdrho;;
                            dkperpdtheta = 0.0;
                            dkperpdphi = 0.0;

                            phase = (icm + cn0*(Y[2] - Y0[2]))*kperp + fluctparam.ne_phase[imodel][iphase-1];
                            dphasedrho = (idcmdrho + dcn0drho*(Y[2] - Y0[2]))*kperp + (icm + cn0*(Y[2] - Y0[2]))*dkperpdrho;
                            dphasedtheta = cm*kperp + (icm + cn0*(Y[2] - Y0[2]))*dkperpdtheta;
                            dphasedphi = cn0*kperp + (icm + cn0*(Y[2] - Y0[2]))*dkperpdphi;
                            
                            u_m = PI*fluctparam.ne_epsi_theta[imodel][0]*im/xL_perp;

                            du_mdrho = -u_m/xL_perp*dxL_perpdrho;
                            
                            du_mdtheta = -u_m/xL_perp*dxL_perpdtheta;

                            du_mdphi = -u_m/xL_perp*dxL_perpdphi;
                            
                            expu_m = exp(-u_m*u_m/2);
                            am = expu_m;
                            
                            damdrho = -expu_m*u_m*du_mdrho;

                            damdtheta = -expu_m*u_m*du_mdtheta;

                            damdphi = -expu_m*u_m*du_mdphi;

                            xx += ac*Flambda*Fdelta*am*sin(phase);
                            dxxdrho += dacdrho*Flambda*Fdelta*am*sin(phase) + ac*dFlambdadrho*Fdelta*am*sin(phase) + ac*Flambda*dFdeltadrho*am*sin(phase) + ac*Flambda*Fdelta*damdrho*sin(phase) + ac*Flambda*Fdelta*am*cos(phase)*dphasedrho;                   
                            dxxdtheta += dacdtheta*Flambda*Fdelta*am*sin(phase) + ac*dFlambdadtheta*Fdelta*am*sin(phase) + ac*Flambda*dFdeltadtheta*am*sin(phase) + ac*Flambda*Fdelta*damdtheta*sin(phase) + ac*Flambda*Fdelta*am*cos(phase)*dphasedtheta;
                            dxxdphi += dacdphi*Flambda*Fdelta*am*sin(phase) + ac*dFlambdadphi*Fdelta*am*sin(phase) + ac*Flambda*dFdeltadphi*am*sin(phase) + ac*Flambda*Fdelta*damdphi*sin(phase) + ac*Flambda*Fdelta*am*cos(phase)*dphasedphi;

                        }
                        
                        /* convolution to avoid negative density values. No restriction on positive values, ht(x) = x */ 

                        halftanh(xx,&ht,&dht,&d2ht);

                        nefsne += ht;
                        dnefsnedrho += dht*dxxdrho;                                                                 
                        dnefsnedtheta += dht*dxxdtheta;
                        dnefsnedphi += dht*dxxdphi;           
                     }
                    
                     if (fluctparam.ne_model[imodel][0] == 6) {/* 2-D Gaussian model (rho,cm,cn), absolute epsi values (drift wave model, local phase approx. ) */ 
                        
                        /* Note that epsi_perp = fluctparam.ne_epsi_theta */
                        
                        ac = 2.0*sqrt(2.0*PI)*fluctparam.ne_sigmar_max[imodel][0]*sqrt(fluctparam.ne_epsi_rho[imodel][0]*fluctparam.ne_epsi_theta[imodel][0]/L_rho/xL_perp);
                        dacdrho = -0.5*ac*(dL_rhodrho/L_rho + dxL_perpdrho/xL_perp);
                        dacdtheta = -0.5*ac*(dL_rhodtheta/L_rho + dxL_perpdtheta/xL_perp);
                        dacdphi = -0.5*ac*(dL_rhodphi/L_rho + dxL_perpdphi/xL_perp);
                        
                        for (il = fluctparam.ne_lmin[imodel][0];il <= fluctparam.ne_lmax[imodel][0];il++) {
                            for (im = fluctparam.ne_mmin[imodel][0];im <= fluctparam.ne_mmax[imodel][0];im++) {
                                    
                                iphase = (int)dl*(im-(int)fluctparam.ne_mmin[imodel][0]) + (il-(int)fluctparam.ne_lmin[imodel][0]) + 1;                                
                                
                                kperp = 2*PI*im/xL_perp;
                                dkperpdrho = -kperp/xL_perp*dxL_perpdrho;;
                                dkperpdtheta = 0.0;
                                dkperpdphi = 0.0;

                                phase = 2*PI*il*Y[0] + (icm + cn0*(Y[2] - Y0[2]))*kperp + fluctparam.ne_phase[imodel][iphase-1];
                                dphasedrho = 2*PI*il + (idcmdrho + dcn0drho*(Y[2] - Y0[2]))*kperp + (icm + cn0*(Y[2] - Y0[2]))*dkperpdrho;
                                dphasedtheta = cm*kperp + (icm + cn0*(Y[2] - Y0[2]))*dkperpdtheta;
                                dphasedphi = cn0*kperp + (icm + cn0*(Y[2] - Y0[2]))*dkperpdphi;

                                u_l = PI*fluctparam.ne_epsi_rho[imodel][0]*il/L_rho;
                                u_m = PI*fluctparam.ne_epsi_theta[imodel][0]*im/xL_perp;

                                du_ldrho = -u_l/L_rho*dL_rhodrho;
                                du_mdrho = -u_m/xL_perp*dxL_perpdrho;

                                du_ldtheta = -u_l/L_rho*dL_rhodtheta;
                                du_mdtheta = -u_m/xL_perp*dxL_perpdtheta;

                                du_ldphi = -u_l/L_rho*dL_rhodphi;
                                du_mdphi = -u_m/xL_perp*dxL_perpdphi;

                                expu_l = exp(-u_l*u_l/2);
                                expu_m = exp(-u_m*u_m/2);
                                alm = expu_l*expu_m;

                                dexpu_ldrho = -expu_l*u_l*du_ldrho;
                                dexpu_mdrho = -expu_m*u_m*du_mdrho;
                                dalmdrho = dexpu_ldrho*expu_m + expu_l*dexpu_mdrho;

                                dexpu_ldtheta = -expu_l*u_l*du_ldtheta;
                                dexpu_mdtheta = -expu_m*u_m*du_mdtheta;
                                dalmdtheta = dexpu_ldtheta*expu_m + expu_l*dexpu_mdtheta;                        

                                dexpu_ldphi = -expu_l*u_l*du_ldphi;
                                dexpu_mdphi = -expu_m*u_m*du_mdphi;
                                dalmdphi = dexpu_ldphi*expu_m + expu_l*dexpu_mdphi;
                                
                                xx += ac*Flambda*Fdelta*alm*sin(phase);
                                dxxdrho += dacdrho*Flambda*Fdelta*alm*sin(phase) + ac*dFlambdadrho*Fdelta*alm*sin(phase) + ac*Flambda*dFdeltadrho*alm*sin(phase) + ac*Flambda*Fdelta*dalmdrho*sin(phase) + ac*Flambda*Fdelta*alm*cos(phase)*dphasedrho;                   
                                dxxdtheta += dacdtheta*Flambda*Fdelta*alm*sin(phase) + ac*dFlambdadtheta*Fdelta*alm*sin(phase) + ac*Flambda*dFdeltadtheta*alm*sin(phase) + ac*Flambda*Fdelta*dalmdtheta*sin(phase) + ac*Flambda*Fdelta*alm*cos(phase)*dphasedtheta;
                                dxxdphi += dacdphi*Flambda*Fdelta*alm*sin(phase) + ac*dFlambdadphi*Fdelta*alm*sin(phase) + ac*Flambda*dFdeltadphi*alm*sin(phase) + ac*Flambda*Fdelta*dalmdphi*sin(phase) + ac*Flambda*Fdelta*alm*cos(phase)*dphasedphi;

                            }
                        }  
                        
                        /* convolution to avoid negative density values. No restriction on positive values, ht(x) = x */ 

                        halftanh(xx,&ht,&dht,&d2ht);

                        nefsne += ht;
                        dnefsnedrho += dht*dxxdrho;                                                                 
                        dnefsnedtheta += dht*dxxdtheta;
                        dnefsnedphi += dht*dxxdphi;      
                     }                    
	            }
            }
            
            if (fluctparam.B_nmodel[0] > 0) {/* Magnetic field fluctuations or ripple */
                
               cta = cos(Y[1])*raymagnetic.calpha[0] + sin(Y[1])*raymagnetic.salpha[0];
               sta = -cos(Y[1])*raymagnetic.salpha[0] + sin(Y[1])*raymagnetic.calpha[0];
                
               dctadrho = cos(Y[1])*raymagnetic.dcalphadY[0] + sin(Y[1])*raymagnetic.dsalphadY[0];   
               dctadtheta = cos(Y[1])*raymagnetic.dcalphadY[1] + sin(Y[1])*raymagnetic.dsalphadY[1] - sta;
               dctadphi = cos(Y[1])*raymagnetic.dcalphadY[2] + sin(Y[1])*raymagnetic.dsalphadY[2];
               
               dstadrho = - cos(Y[1])*raymagnetic.dsalphadY[0] + sin(Y[1])*raymagnetic.dcalphadY[0];
               dstadtheta = - cos(Y[1])*raymagnetic.dsalphadY[1] + sin(Y[1])*raymagnetic.dcalphadY[1] + cta;
               dstadphi = - cos(Y[1])*raymagnetic.dsalphadY[2] + sin(Y[1])*raymagnetic.dcalphadY[2];
               
	           for (imodel=0; imodel < fluctparam.B_nmodel[0]; imodel++) {
	               
	              if (fluctparam.B_model[imodel][0] == 1) {/* Gaussian fluctuation spectrum */
                       
                    /*   
                    for (ikperp=0; ikperp < fluctparam.B_nkperp[imodel][0]; ikperp++) {
                           
                           phaseB = gphase*fluctparam.B_kperp[imodel][ikperp] + fluctparam.B_phase[imodel][ikperp];
                           dphaseBdrho = dgphasedrho*fluctparam.B_kperp[imodel][ikperp];
	                       dphaseBdtheta = dgphasedtheta*fluctparam.B_kperp[imodel][ikperp];                  
	                       dphaseBdphi = dgphasedphi*fluctparam.B_kperp[imodel][ikperp];                          
	                       
	                       ff0 = sqrt(2*(fluctparam.B_kperp[imodel][1]-fluctparam.B_kperp[imodel][0])/sqrt(2*PI));
	                       
	                       ff1 = exp(-pow(fluctparam.B_kperp[imodel][ikperp]-krB[imodel],2)/pow(kcB[imodel],2)/4);
	                       dff1drho = ff1*(fluctparam.B_kperp[imodel][ikperp]-krB[imodel])*((fluctparam.B_kperp[imodel][ikperp]-krB[imodel])*dkcBdrho[imodel] + kcB[imodel]*dkrBdrho[imodel])/2/pow(kcB[imodel],3);
	                       dff1dtheta = ff1*(fluctparam.B_kperp[imodel][ikperp]-krB[imodel])*((fluctparam.B_kperp[imodel][ikperp]-krB[imodel])*dkcBdtheta[imodel] + kcB[imodel]*dkrBdtheta[imodel])/2/pow(kcB[imodel],3);
	
	                       ff2 = 1./sqrt(kcB[imodel]);
	                       dff2drho = -dkcBdrho[imodel]/sqrt(kcB[imodel])/kcB[imodel]/2.0;
	                       dff2dtheta = -dkcBdtheta[imodel]/sqrt(kcB[imodel])/kcB[imodel]/2.0;	                       
	                       
	                       BxfsB = ff0*sfBx[imodel]*ff1*ff2*cos(phaseB);
	                       dBxfsBdrho = ff0*(dsfBxdrho[imodel]*cos(phaseB)*ff1*ff2 - sfBx[imodel]*sin(phaseB)*dphaseBdrho*ff1*ff2 + sfBx[imodel]*cos(phaseB)*dff1drho*ff2 + sfBx[imodel]*cos(phaseB)*ff1*dff2drho);
	                       dBxfsBdtheta = ff0*(dsfBxdtheta[imodel]*cos(phaseB)*ff1*ff2 - sfBx[imodel]*sin(phaseB)*dphaseBdtheta*ff1*ff2 + sfBx[imodel]*cos(phaseB)*dff1dtheta*ff2 + sfBx[imodel]*cos(phaseB)*ff1*dff2dtheta);
	                       dBxfsBdphi = - ff0*sfBx[imodel]*sin(phaseB)*dphaseBdphi*ff1*ff2;
                           
                           ByfsB = ff0*sfBy[imodel]*ff1*ff2*cos(phaseB);
	                       dByfsBdrho = ff0*(dsfBydrho[imodel]*cos(phaseB)*ff1*ff2 - sfBy[imodel]*sin(phaseB)*dphaseBdrho*ff1*ff2 + sfBy[imodel]*cos(phaseB)*dff1drho*ff2 + sfBy[imodel]*cos(phaseB)*ff1*dff2drho);
	                       dByfsBdtheta = ff0*(dsfBydtheta[imodel]*cos(phaseB)*ff1*ff2 - sfBy[imodel]*sin(phaseB)*dphaseBdtheta*ff1*ff2 + sfBy[imodel]*cos(phaseB)*dff1dtheta*ff2 + sfBy[imodel]*cos(phaseB)*ff1*dff2dtheta);
	                       dByfsBdphi = - ff0*sfBy[imodel]*sin(phaseB)*dphaseBdphi*ff1*ff2;

                           BzfsB = ff0*sfBz[imodel]*ff1*ff2*cos(phaseB);
	                       dBzfsBdrho = ff0*(dsfBzdrho[imodel]*cos(phaseB)*ff1*ff2 - sfBz[imodel]*sin(phaseB)*dphaseBdrho*ff1*ff2 + sfBz[imodel]*cos(phaseB)*dff1drho*ff2 + sfBz[imodel]*cos(phaseB)*ff1*dff2drho);
	                       dBzfsBdtheta = ff0*(dsfBzdtheta[imodel]*cos(phaseB)*ff1*ff2 - sfBz[imodel]*sin(phaseB)*dphaseBdtheta*ff1*ff2 + sfBz[imodel]*cos(phaseB)*dff1dtheta*ff2 + sfBz[imodel]*cos(phaseB)*ff1*dff2dtheta);
	                       dBzfsBdphi = - ff0*sfBz[imodel]*sin(phaseB)*dphaseBdphi*ff1*ff2;
                     */
                    
                           /* mexPrintf("Y[0],Y[1],Y[2],Bfx[0],dBxfdY[0],dBxfdY[1],dBxfdY[2]:%25.15g,%25.15g,%25.15g,%25.15g,%25.15g,%25.15g,%25.15g\n",Y[0],Y[1],Y[2],Bxf,dBxfdrho,dBxfdtheta,dBxfdphi);*/
                           /* mexPrintf("Y[0],Y[1],Y[2],Bfy[0],dByfdY[0],dByfdY[1],dByfdY[2]:%25.15g,%25.15g,%25.15g,%25.15g,%25.15g,%25.15g,%25.15g\n",Y[0],Y[1],Y[2],Byf,dByfdrho,dByfdtheta,dByfdphi);*/
                           /* mexPrintf("Y[0],Y[1],Y[2],Bfz[0],dBzfdY[0],dBzfdY[1],dBzfdY[2]:%25.15g,%25.15g,%25.15g,%25.15g,%25.15g,%25.15g,%25.15g\n",Y[0],Y[1],Y[2],Bzf,dBzfdrho,dBzfdtheta,dBzfdphi);

	                   }
	                   */
                   }
                       
                   if (fluctparam.B_model[imodel][0] == 0) {/* Magnetic ripple modulation */
                   
                       ppvald_2D(rayfluctuations.B_sfx_fit[imodel],rayparam.dS[0],Y[0],Y[1],&sfBx[imodel],&dsfBxdrho[imodel],&dsfBxdtheta[imodel],&d2sfBxdtheta2[imodel],&d2sfBxdthetadrho[imodel]);           
                       ppvald_2D(rayfluctuations.B_sfy_fit[imodel],rayparam.dS[0],Y[0],Y[1],&sfBy[imodel],&dsfBydrho[imodel],&dsfBydtheta[imodel],&d2sfBydtheta2[imodel],&d2sfBydthetadrho[imodel]);           
                       ppvald_2D(rayfluctuations.B_sfz_fit[imodel],rayparam.dS[0],Y[0],Y[1],&sfBz[imodel],&dsfBzdrho[imodel],&dsfBzdtheta[imodel],&d2sfBzdtheta2[imodel],&d2sfBzdthetadrho[imodel]);           
                       
                       phaseB = fluctparam.B_nmax[imodel][0]*Y[2];
                       dphaseBdrho = 0.0;
                       dphaseBdtheta = 0.0;
                       dphaseBdphi = fluctparam.B_nmax[imodel][0];

                       BxfsB = sfBx[imodel]*sin(phaseB);
                       dBxfsBdrho = dsfBxdrho[imodel]*sin(phaseB);
                       dBxfsBdtheta = dsfBxdtheta[imodel]*sin(phaseB);
                       dBxfsBdphi = sfBx[imodel]*cos(phaseB)*dphaseBdphi;

                       ByfsB = sfBy[imodel]*sin(phaseB);
                       dByfsBdrho = dsfBydrho[imodel]*sin(phaseB);
                       dByfsBdtheta = dsfBydtheta[imodel]*sin(phaseB);
                       dByfsBdphi = sfBy[imodel]*cos(phaseB)*dphaseBdphi;

                       BzfsB = sfBz[imodel]*cos(phaseB);
                       dBzfsBdrho = dsfBzdrho[imodel]*cos(phaseB);
                       dBzfsBdtheta = dsfBzdtheta[imodel]*cos(phaseB);
                       dBzfsBdphi = -sfBz[imodel]*sin(phaseB)*dphaseBdphi;

                       /* add ripple effect on densities and temperatures (electron and ion) */

                       Brho0 = raymagnetic.B[0]*(cta*sfBx[imodel] + sta*sfBy[imodel]);
                       dBrho0drho = raymagnetic.dBdY[0]*(cta*sfBx[imodel] + sta*sfBy[imodel]) + raymagnetic.B[0]*(dctadrho*sfBx[imodel] + cta*dsfBxdrho[imodel] + dstadrho*sfBy[imodel] + sta*dsfBydrho[imodel]);
                       dBrho0dtheta = raymagnetic.dBdY[1]*(cta*sfBx[imodel] + sta*sfBy[imodel]) + raymagnetic.B[0]*(dctadtheta*sfBx[imodel] + cta*dsfBxdtheta[imodel] + dstadtheta*sfBy[imodel] + sta*dsfBydtheta[imodel]);                                 

                       lambda = Brho0*raymagnetic.gradrhon[0]*equilparam.Rp[0]/BPHI/fluctparam.B_nmax[imodel][0]/equilparam.ap[0];                           
                       dlambdadrho = (dBrho0drho*raymagnetic.gradrhon[0] + Brho0*raymagnetic.dgradrhondY[0] - Brho0*raymagnetic.gradrhon[0]*dBPHIdrho/BPHI)*equilparam.Rp[0]/BPHI/fluctparam.B_nmax[imodel][0]/equilparam.ap[0];
                       dlambdadtheta = (dBrho0dtheta*raymagnetic.gradrhon[0] + Brho0*raymagnetic.dgradrhondY[1] - Brho0*raymagnetic.gradrhon[0]*dBPHIdtheta/BPHI)*equilparam.Rp[0]/BPHI/fluctparam.B_nmax[imodel][0]/equilparam.ap[0];
                       
                       rhorip = Y[0] + lambda*cos(phaseB); 
                       drhodrhorip = 1.0 + dlambdadrho*cos(phaseB); 
                       drhodthetarip = dlambdadtheta*cos(phaseB);
                       drhodphirip = - dphaseBdphi*lambda*sin(phaseB);

                       /* Electron density */

                       ppvald_1D(rayequil.ne_fit,rayparam.dS[0],1.0,&val,&dvaldrho,&d2valdrho2); /*value at the separatrix */
                       ne_sep = val;
                       dnedrho_sep = dvaldrho;

                       if (dnedrho_sep == 0) {
                           rho_neeq0 = 1.0e20;
                       } else {
                           rho_neeq0 = - ne_sep/dnedrho_sep + 1.0;
                       }

                       if (rhorip <= 1.0) {
                           ppvald_1D(rayequil.ne_fit,rayparam.dS[0],rhorip,&val,&dvaldrho,&d2valdrho2);
                           nerip = val;
                           dnedrhorip = dvaldrho*drhodrhorip;
                           dnedthetarip = dvaldrho*drhodthetarip;
                           dnedphirip = dvaldrho*drhodphirip;
                       }

                       if ((rhorip > 1.0) & (rhorip <= rho_neeq0)) {
                           nerip = ne_sep + dnedrho_sep*(rhorip - 1.0); /* SOL */
                           dnedrhorip = dnedrho_sep*drhodrhorip;
                           dnedthetarip = dnedrho_sep*drhodthetarip;
                           dnedphirip = dnedrho_sep*drhodphirip;
                       }

                       if (rhorip > rho_neeq0) {
                           nerip = 0.0; /*vacuum */
                           dnedrhorip = 0.0;
                           dnedthetarip = 0.0;
                           dnedphirip = 0.0;
                       }

                       ne_tilde = nerip - rayprofiles.ne[0];
                       dnedrho_tilde = dnedrhorip - rayprofiles.dnedY[0];
                       dnedtheta_tilde = dnedthetarip;
                       dnedphi_tilde = dnedphirip;

                       ner_tilde = ne_tilde/rayprofiles.ne[0];
                       dnerdrho_tilde = dnedrho_tilde/rayprofiles.ne[0] - ne_tilde*rayprofiles.dnedY[0]/rayprofiles.ne[0]/rayprofiles.ne[0];
                       dnerdtheta_tilde = dnedtheta_tilde/rayprofiles.ne[0];
                       dnerdphi_tilde = dnedphi_tilde/rayprofiles.ne[0];

                /*     mexPrintf("rho,theta,phi,rhorip,rho_neeq0,ne,dnedrho,nerip,dnedrhorip,dnedthetarip,dnedphirip,ner_tilde,dnerdrho_tilde,dnerdtheta_tilde,dnerdphi_tilde:%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n",Y[0],Y[1],Y[2],rhorip,rho_neeq0,rayprofiles.ne[0],rayprofiles.dnedY[0],nerip,dnedrhorip,dnedthetarip,dnedphirip,ner_tilde,dnerdrho_tilde,dnerdtheta_tilde,dnerdphi_tilde);
                       mexPrintf("Brho0,raymagnetic.gradrhon[0],equilparam.Rp[0],BPHI,fluctparam.B_kperp[imodel][ikperp],lambda:%g,%g,%g,%g,%g,%g\n",Brho0,raymagnetic.gradrhon[0],equilparam.Rp[0],BPHI,fluctparam.B_kperp[imodel][ikperp],lambda);
                */    
                       nefsne += ner_tilde;/* add the relative contribution of magnetic ripple to the density perturbation */
                       dnefsnedrho += dnerdrho_tilde;
                       dnefsnedtheta += dnerdtheta_tilde;
                       dnefsnedphi += dnerdphi_tilde;

                       /* Electron temperature */

                       ppvald_1D(rayequil.Te_fit,rayparam.dS[0],1.0,&val,&dvaldrho,&d2valdrho2); /*value at the separatrix */
                       Te_sep = val;
                       dTedrho_sep = dvaldrho;

                       if (dTedrho_sep == 0) {
                           rho_Teeq0 = 1.0e20;
                       } else {
                           rho_Teeq0 = - Te_sep/dTedrho_sep + 1.0;
                       }

                       if (rhorip <= 1.0) {
                           ppvald_1D(rayequil.Te_fit,rayparam.dS[0],rhorip,&val,&dvaldrho,&d2valdrho2);
                           Terip = val;
                           dTedrhorip = dvaldrho*drhodrhorip;
                           dTedthetarip = dvaldrho*drhodthetarip;
                           dTedphirip = dvaldrho*drhodphirip;
                       }

                       if ((rhorip > 1.0) & (rhorip <= rho_Teeq0)) {
                           Terip = Te_sep + dTedrho_sep*(rhorip - 1.0); /* SOL */
                           dTedrhorip = dTedrho_sep*drhodrhorip;
                           dTedthetarip = dTedrho_sep*drhodthetarip;
                           dTedphirip = dTedrho_sep*drhodphirip;
                       }

                       if (rhorip > rho_Teeq0) {
                           Terip = 0.0; /*vacuum */
                           dTedrhorip = 0.0;
                           dTedthetarip = 0.0;
                           dTedphirip = 0.0;
                       }

                       Te_tilde = Terip - rayprofiles.Te[0];
                       dTedrho_tilde = dTedrhorip - rayprofiles.dTedY[0];
                       dTedtheta_tilde = dTedthetarip;
                       dTedphi_tilde = dTedphirip;

                       Ter_tilde = Te_tilde/rayprofiles.Te[0];
                       dTerdrho_tilde = dTedrho_tilde/rayprofiles.Te[0] - Te_tilde*rayprofiles.dTedY[0]/rayprofiles.Te[0]/rayprofiles.Te[0];
                       dTerdtheta_tilde = dTedtheta_tilde/rayprofiles.Te[0];
                       dTerdphi_tilde = dTedphi_tilde/rayprofiles.Te[0];

                       TefsTe += Ter_tilde;/* add the relative contribution of magnetic ripple to the electron temperature perturbation */
                       dTefsTedrho += dTerdrho_tilde;
                       dTefsTedtheta += dTerdtheta_tilde;
                       dTefsTedphi += dTerdphi_tilde;

                       /* ion densities */

                       for (is=0;is<equilparam.ns[0];is++) {

                           ppvald_1D(rayequil.zni_fit,rayparam.dS[0],1.0,zval,dzvaldrho,d2zvaldrho2); /*value at the separatrix */
                           zni_sep[is] = zval[is];
                           dznidrho_sep[is] = dzvaldrho[is];

                           if (dznidrho_sep[is] == 0) {
                               rho_znieq0[is] = 1.0e20;
                           } else {
                               rho_znieq0[is] = - zni_sep[is]/dznidrho_sep[is] + 1.0;
                           }

                           if (rhorip <= 1.0) {
                               ppvald_1D(rayequil.zni_fit,rayparam.dS[0],rhorip,zval,dzvaldrho,d2zvaldrho2);
                               znirip[is] = zval[is];
                               dznidrhorip[is] = dzvaldrho[is]*drhodrhorip;
                               dznidthetarip[is] = dzvaldrho[is]*drhodthetarip;
                               dznidphirip[is] = dzvaldrho[is]*drhodphirip;
                           }

                           if ((rhorip > 1.0) & (rhorip <= rho_znieq0[is])) {
                               znirip[is] = zni_sep[is] + dznidrho_sep[is]*(rhorip - 1.0); /* SOL */
                               dznidrhorip[is] = dznidrho_sep[is]*drhodrhorip;
                               dznidthetarip[is] = dznidrho_sep[is]*drhodthetarip;
                               dznidphirip[is] = dznidrho_sep[is]*drhodphirip;
                           }

                           if (rhorip > rho_znieq0[is]) {
                               znirip[is] = 0.0; /*vacuum */
                               dznidrhorip[is] = 0.0;
                               dznidthetarip[is] = 0.0;
                               dznidphirip[is] = 0.0;
                           }

                           zni_tilde[is] = znirip[is] - rayprofiles.zni[is];
                           dznidrho_tilde[is] = dznidrhorip[is] - rayprofiles.dznidY[is][0];
                           dznidtheta_tilde[is] = dznidthetarip[is];
                           dznidphi_tilde[is] = dznidphirip[is];

                           /*mexPrintf("is,ns,rayprofiles.zni[is],%d,%d,%g\n",is,equilparam.ns[0],rayprofiles.zni[is]);*/

                           if (rayprofiles.zni[is] > 0.0) {

                               /* mexPrintf("is valide,%d\n",is);*/

                               znir_tilde[is] = zni_tilde[is]/rayprofiles.zni[is];
                               dznirdrho_tilde[is] = dznidrho_tilde[is]/rayprofiles.zni[is] - zni_tilde[is]*rayprofiles.dznidY[is][0]/rayprofiles.zni[is]/rayprofiles.zni[is];
                               dznirdtheta_tilde[is] = dznidtheta_tilde[is]/rayprofiles.zni[is];
                               dznirdphi_tilde[is] = dznidphi_tilde[is]/rayprofiles.zni[is];

                               znifszni[is] += znir_tilde[is];/* add the relative contribution of magnetic ripple to the ion densities perturbations */
                               dznifsznidrho[is] += dznirdrho_tilde[is];
                               dznifsznidtheta[is] += dznirdtheta_tilde[is];
                               dznifsznidphi[is] += dznirdphi_tilde[is];
                           }

                           /* ion temperatures */

                           ppvald_1D(rayequil.zTi_fit,rayparam.dS[0],1.0,zval,dzvaldrho,d2zvaldrho2); /*value at the separatrix */
                           zTi_sep[is] = zval[is];
                           dzTidrho_sep[is] = dzvaldrho[is];

                           if (dzTidrho_sep[is] == 0) {
                               rho_zTieq0[is] = 1.0e20;
                           } else {
                               rho_zTieq0[is] = - zTi_sep[is]/dzTidrho_sep[is] + 1.0;
                           }

                           if (rhorip <= 1.0) {
                               ppvald_1D(rayequil.zTi_fit,rayparam.dS[0],rhorip,zval,dzvaldrho,d2zvaldrho2);
                               zTirip[is] = zval[is];
                               dzTidrhorip[is] = dzvaldrho[is]*drhodrhorip;
                               dzTidthetarip[is] = dzvaldrho[is]*drhodthetarip;
                               dzTidphirip[is] = dzvaldrho[is]*drhodphirip;
                           }

                           if ((rhorip > 1.0) & (rhorip <= rho_zTieq0[is])) {
                               zTirip[is] = zTi_sep[is] + dzTidrho_sep[is]*(rhorip - 1.0); /* SOL */
                               dzTidrhorip[is] = dzTidrho_sep[is]*drhodrhorip;
                               dzTidthetarip[is] = dzTidrho_sep[is]*drhodthetarip;
                               dzTidphirip[is] = dzTidrho_sep[is]*drhodphirip;
                           }

                           if (rhorip > rho_zTieq0[is]) {
                               zTirip[is] = 0.0; /*vacuum */
                               dzTidrhorip[is] = 0.0;
                               dzTidthetarip[is] = 0.0;
                               dzTidphirip[is] = 0.0;
                           }

                           zTi_tilde[is] = zTirip[is] - rayprofiles.zTi[is];
                           dzTidrho_tilde[is] = dzTidrhorip[is] - rayprofiles.dzTidY[is][0];
                           dzTidtheta_tilde[is] = dzTidthetarip[is];
                           dzTidphi_tilde[is] = dzTidphirip[is];

                           zTir_tilde[is] = zTi_tilde[is]/rayprofiles.zTi[is];
                           dzTirdrho_tilde[is] = dzTidrho_tilde[is]/rayprofiles.zTi[is] - zTi_tilde[is]*rayprofiles.dzTidY[is][0]/rayprofiles.zTi[is]/rayprofiles.zTi[is];
                           dzTirdtheta_tilde[is] = dzTidtheta_tilde[is]/rayprofiles.zTi[is];
                           dzTirdphi_tilde[is] = dzTidphi_tilde[is]/rayprofiles.zTi[is];

                           zTifszTi[is] += zTir_tilde[is];/* add the relative contribution of magnetic ripple to the ion temperatures perturbations */
                           dzTifszTidrho[is] += dzTirdrho_tilde[is];
                           dzTifszTidtheta[is] += dzTirdtheta_tilde[is];
                           dzTifszTidphi[is] += dzTirdphi_tilde[is];
                       }

                   }

                   BrhofsB += cta*BxfsB + sta*ByfsB;
                   dBrhofsBdrho += dctadrho*BxfsB + cta*dBxfsBdrho + dstadrho*ByfsB + sta*dByfsBdrho;
                   dBrhofsBdtheta += dctadtheta*BxfsB + cta*dBxfsBdtheta + dstadtheta*ByfsB + sta*dByfsBdtheta;
                   dBrhofsBdphi += dctadphi*BxfsB + cta*dBxfsBdphi + dstadphi*ByfsB + sta*dByfsBdphi;

                   BsfsB += cta*ByfsB - sta*BxfsB;
                   dBsfsBdrho += dctadrho*ByfsB + cta*dByfsBdrho - dstadrho*BxfsB - sta*dBxfsBdrho;
                   dBsfsBdtheta += dctadtheta*ByfsB + cta*dByfsBdtheta - dstadtheta*BxfsB - sta*dBxfsBdtheta;
                   dBsfsBdphi += dctadphi*ByfsB + cta*dByfsBdphi - dstadphi*BxfsB - sta*dBxfsBdphi;

                   BphifsB += BzfsB;
                   dBphifsBdrho += dBzfsBdrho;
                   dBphifsBdtheta += dBzfsBdtheta;
                   dBphifsBdphi += dBzfsBdphi;                       
                
	            }               
            }
            
            /* Calculation of the perturbed magnetic field and it's derivatives */
            
            Brho = (raymagnetic.Brhon[0] + BrhofsB)*raymagnetic.B[0];
            Bs = (raymagnetic.Bsn[0] + BsfsB)*raymagnetic.B[0];
            Bphi = (raymagnetic.BPHIn[0] + BphifsB)*raymagnetic.B[0];
            B = sqrt(Brho*Brho + Bs*Bs + Bphi*Bphi);

            Brhon = Brho/B;/* Normalization to the new local value of B */
            Bsn = Bs/B;
            Bphin = Bphi/B;

            dBrhodrho = (raymagnetic.dBrhondY[0] + dBrhofsBdrho)*raymagnetic.B[0] + (raymagnetic.Brhon[0] + BrhofsB)*raymagnetic.dBdY[0];
            dBrhodtheta = (raymagnetic.dBrhondY[1] + dBrhofsBdtheta)*raymagnetic.B[0] + (raymagnetic.Brhon[0] + BrhofsB)*raymagnetic.dBdY[1];
            dBrhodphi = (raymagnetic.dBrhondY[2] + dBrhofsBdphi)*raymagnetic.B[0] + (raymagnetic.Brhon[0] + BrhofsB)*raymagnetic.dBdY[2];

            dBsdrho = (raymagnetic.dBsndY[0] + dBsfsBdrho)*raymagnetic.B[0] + (raymagnetic.Bsn[0] + BsfsB)*raymagnetic.dBdY[0];
            dBsdtheta = (raymagnetic.dBsndY[1] + dBsfsBdtheta)*raymagnetic.B[0] + (raymagnetic.Bsn[0] + BsfsB)*raymagnetic.dBdY[1];
            dBsdphi = (raymagnetic.dBsndY[2] + dBsfsBdphi)*raymagnetic.B[0] + (raymagnetic.Bsn[0] + BsfsB)*raymagnetic.dBdY[2];

            dBphidrho = (raymagnetic.dBPHIndY[0] + dBphifsBdrho)*raymagnetic.B[0] + (raymagnetic.BPHIn[0] + BphifsB)*raymagnetic.dBdY[0];
            dBphidtheta = (raymagnetic.dBPHIndY[1] + dBphifsBdtheta)*raymagnetic.B[0] + (raymagnetic.BPHIn[0] + BphifsB)*raymagnetic.dBdY[1];
            dBphidphi = (raymagnetic.dBPHIndY[2] + dBphifsBdphi)*raymagnetic.B[0] + (raymagnetic.BPHIn[0] + BphifsB)*raymagnetic.dBdY[2];

            dBdrho = Brhon*dBrhodrho + Bsn*dBsdrho + Bphin*dBphidrho;
            dBdtheta = Brhon*dBrhodtheta + Bsn*dBsdtheta + Bphin*dBphidtheta;
            dBdphi = Brhon*dBrhodphi + Bsn*dBsdphi + Bphin*dBphidphi;

            raymagnetic.Brhon[0] = Brhon;
            raymagnetic.dBrhondY[0] = (dBrhodrho - Brhon*dBdrho)/B;
            raymagnetic.dBrhondY[1] = (dBrhodtheta - Brhon*dBdtheta)/B;
            raymagnetic.dBrhondY[2] = (dBrhodphi - Brhon*dBdphi)/B;         

            raymagnetic.Bsn[0] = Bsn;
            raymagnetic.dBsndY[0] = (dBsdrho - Bsn*dBdrho)/B;;
            raymagnetic.dBsndY[1] = (dBsdtheta - Bsn*dBdtheta)/B;
            raymagnetic.dBsndY[2] = (dBsdphi - Bsn*dBdphi)/B;         

            raymagnetic.BPHIn[0] = Bphin;
            raymagnetic.dBPHIndY[0] = (dBphidrho - Bphin*dBdrho)/B;
            raymagnetic.dBPHIndY[1] = (dBphidtheta - Bphin*dBdtheta)/B;
            raymagnetic.dBPHIndY[2] = (dBphidphi - Bphin*dBdphi)/B;         

            raymagnetic.B[0] = B;
            raymagnetic.dBdY[0] = dBdrho;
            raymagnetic.dBdY[1] = dBdtheta;
            raymagnetic.dBdY[2] = dBdphi;
            
            raymagnetic.rhorip[0] = rhorip; 
            raymagnetic.drhoripdY[0] = drhodrhorip; 
            raymagnetic.drhoripdY[1] = drhodthetarip;
            raymagnetic.drhoripdY[2] = drhodphirip;
                                 
            /* Calculation of the perturbed electron density and it's derivatives */
                
            /* mexPrintf("rho,theta,phi,ner[0],dnerdY[0],dnerdY[1],dnerdY[2]:%25.15g,%25.15g,%25.15g,%25.15g,%25.15g,%25.15g,%25.15g\n",Y[0],Y[1],Y[2],nefsne,dnefsnedrho,dnefsnedtheta,dnefsnedphi);*/
            
            rayprofiles.dnedY[0] = rayprofiles.dnedY[0]*(1.0 + nefsne) + rayprofiles.ne[0]*dnefsnedrho;
	        rayprofiles.dnedY[1] = rayprofiles.dnedY[1]*(1.0 + nefsne) + rayprofiles.ne[0]*dnefsnedtheta;
	        rayprofiles.dnedY[2] = rayprofiles.dnedY[2]*(1.0 + nefsne) + rayprofiles.ne[0]*dnefsnedphi;         
	        rayprofiles.ne[0] = rayprofiles.ne[0]*(1.0 + nefsne);
            
            /* Calculation of the perturbed electron temperature and it's derivatives */
           
            rayprofiles.dTedY[0] = rayprofiles.dTedY[0]*(1.0 + TefsTe) + rayprofiles.Te[0]*dTefsTedrho;
	        rayprofiles.dTedY[1] = rayprofiles.dTedY[1]*(1.0 + TefsTe) + rayprofiles.Te[0]*dTefsTedtheta;
	        rayprofiles.dTedY[2] = rayprofiles.dTedY[2]*(1.0 + TefsTe) + rayprofiles.Te[0]*dTefsTedphi;         
	        rayprofiles.Te[0] = rayprofiles.Te[0]*(1.0 + TefsTe);
            
            for (is=0;is<equilparam.ns[0];is++) {
                
                /* Calculation of the perturbed ion densities and their derivatives */

                rayprofiles.dznidY[is][0] = rayprofiles.dznidY[is][0]*(1.0 + znifszni[is]) + rayprofiles.zni[is]*dznifsznidrho[is];
                rayprofiles.dznidY[is][1] = rayprofiles.dznidY[is][1]*(1.0 + znifszni[is]) + rayprofiles.zni[is]*dznifsznidtheta[is];
                rayprofiles.dznidY[is][2] = rayprofiles.dznidY[is][2]*(1.0 + znifszni[is]) + rayprofiles.zni[is]*dznifsznidphi[is];         
                rayprofiles.zni[is] = rayprofiles.zni[is]*(1.0 + znifszni[is]);

                /* Calculation of the perturbed ion temperatures and their derivatives */

                rayprofiles.dzTidY[is][0] = rayprofiles.dzTidY[is][0]*(1.0 + zTifszTi[is]) + rayprofiles.zTi[is]*dzTifszTidrho[is];
                rayprofiles.dzTidY[is][1] = rayprofiles.dzTidY[is][1]*(1.0 + zTifszTi[is]) + rayprofiles.zTi[is]*dzTifszTidtheta[is];
                rayprofiles.dzTidY[is][2] = rayprofiles.dzTidY[is][2]*(1.0 + zTifszTi[is]) + rayprofiles.zTi[is]*dzTifszTidphi[is];         
                rayprofiles.zTi[is] = rayprofiles.zTi[is]*(1.0 + zTifszTi[is]);
                
            }
        }                
    }
}

void build_raymagnetic(theta,raymagnetic,equilparam,R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho,Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho,BR,dBRdrho,dBRdtheta,dBRdphi,BZ,dBZdrho,dBZdtheta,dBZdphi,BPHI,dBPHIdrho,dBPHIdtheta,dBPHIdphi,dRstardpsin,ddRstardpsindrho) 
raymagnetic_format raymagnetic;
equilparam_format equilparam;

double theta;
double R,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho;
double Z,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho;
double BR,dBRdrho,dBRdtheta,dBRdphi;
double BZ,dBZdrho,dBZdtheta,dBZdphi;
double BPHI,dBPHIdrho,dBPHIdtheta,dBPHIdphi;
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
    
    raymagnetic.Brhon[0] = 0.0;/* Normalized radial magnetic field */
    raymagnetic.dBrhondY[0] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    raymagnetic.dBrhondY[1] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    raymagnetic.dBrhondY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    
    raymagnetic.Bsn[0] = sigmaIp*BP/B;/* Normlaized poloidal magnetic field */
    raymagnetic.dBsndY[0] = sigmaIp*(dBPdrho/B - BP*dBdrho/B/B);
    raymagnetic.dBsndY[1] = sigmaIp*(dBPdtheta/B - BP*dBdtheta/B/B);
    raymagnetic.dBsndY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
   
    raymagnetic.BPHIn[0] = BPHI/B;/* Normlaized toroidal magnetic field */
    raymagnetic.dBPHIndY[0] = dBPHIdrho/B - BPHI*dBdrho/B/B;
    raymagnetic.dBPHIndY[1] = dBPHIdtheta/B - BPHI*dBdtheta/B/B;
    raymagnetic.dBPHIndY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    
    raymagnetic.B[0] = B;/* Total magnetic field */
    raymagnetic.dBdY[0] = dBdrho;
    raymagnetic.dBdY[1] = dBdtheta;
    raymagnetic.dBdY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    
    r = sqrt((R - equilparam.Rp[0])*(R - equilparam.Rp[0])+(Z - equilparam.Zp[0])*(Z - equilparam.Zp[0]));
    drdrho = (dRdrho*(R - equilparam.Rp[0]) + dZdrho*(Z - equilparam.Zp[0]))/r;
    drdtheta = (dRdtheta*(R - equilparam.Rp[0]) + dZdtheta*(Z - equilparam.Zp[0]))/r;
    
    raymagnetic.rn[0] = r/equilparam.ap[0];
    raymagnetic.drndY[0] = drdrho/equilparam.ap[0];
    raymagnetic.drndY[1] = drdtheta/equilparam.ap[0];
    raymagnetic.drndY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    
    raymagnetic.Rn[0] = R/equilparam.ap[0];
    raymagnetic.dRndY[0] = dRdrho/equilparam.ap[0];
    raymagnetic.dRndY[1] = dRdtheta/equilparam.ap[0];
    raymagnetic.dRndY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    
    raymagnetic.Zn[0] = Z/equilparam.ap[0];
    raymagnetic.dZndY[0] = dZdrho/equilparam.ap[0];
    raymagnetic.dZndY[1] = dZdtheta/equilparam.ap[0];
    raymagnetic.dZndY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    
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
    raymagnetic.dsalphadY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
            
    raymagnetic.calpha[0] = sqrt(1.0 - salpha*salpha);
    raymagnetic.dcalphadY[0] = -salpha*dsalphadrho/sqrt(1.0 - salpha*salpha);
    raymagnetic.dcalphadY[1] = -salpha*dsalphadtheta/sqrt(1.0 - salpha*salpha);
    raymagnetic.dcalphadY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */

    raymagnetic.gradrhon[0] = R*BP*dRstardpsin/fabs(equilparam.psia[0]);
    raymagnetic.dgradrhondY[0] = (dRdrho*BP*dRstardpsin + R*dBPdrho*dRstardpsin + R*BP*ddRstardpsindrho)/fabs(equilparam.psia[0]);
    raymagnetic.dgradrhondY[1] = (dRdtheta*BP*dRstardpsin + R*dBPdtheta*dRstardpsin)/fabs(equilparam.psia[0]);
    raymagnetic.dgradrhondY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    
    raymagnetic.rhorip[0] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    raymagnetic.drhoripdY[0] = 1.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    raymagnetic.drhoripdY[1] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    raymagnetic.drhoripdY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    
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

void interpequil_test(raymagnetic,rayprofiles,equilparam,Y0,Y,flag)
raymagnetic_format raymagnetic;
rayprofiles_format rayprofiles;
equilparam_format equilparam;/* is an output in this case, since nothing is used from MatLab */
double Y0[],Y[];
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
    if (equilparam.zZi[0] > 0) {/*Vacuum case otherwise (no density, temperature...)*/
        
    pZeff = Zeff0 + (Zeffa-Zeff0)*pow(rho,eZeff);
    dpZeffdrho = eZeff*(Zeffa-Zeff0)*pow(rho,eZeff-1);
    
    if (ns > 4) {
       mexErrMsgTxt("Only one fully stripped impurity can be used !"); 
    }

    if ((abs(flag) == 1) || (abs(flag) == 2) || (abs(flag) == 5))  {/*Jetlike, RTtest, TORLH*/
    
       rayprofiles.Te[0] = Tea + (Te0 - Tea)*pow(1 - rho*rho,eTe);
       rayprofiles.dTedY[0] = -2*rho*eTe*(Te0 - Tea)*pow(1 - rho*rho,eTe - 1); 
       rayprofiles.dTedY[1] = 0.0;
       rayprofiles.dTedY[2] = 0.0;
    
       rayprofiles.ne[0] = nea + (ne0 - nea)*pow(1 - rho*rho,ene);
       rayprofiles.dnedY[0] = -2*rho*ene*(ne0 - nea)*pow(1 - rho*rho,ene - 1);
       rayprofiles.dnedY[1] = 0.0;
       rayprofiles.dnedY[2] = 0.0;
    
    
       for (is=0;is<ns;is++) {
           rayprofiles.zTi[is] = Tia + (Ti0 - Tia)*pow(1 - rho*rho,eTi);
           rayprofiles.dzTidY[is][0] = -2*rho*eTi*(Ti0 - Tia)*pow(1 - rho*rho,eTi - 1);
           rayprofiles.dzTidY[is][1] = 0.0;
           rayprofiles.dzTidY[is][2] = 0.0;
       }
    } else if ((abs(flag) == 3) || (abs(flag) == 4)) {/*VERSATOR2 and PLT */        
        
       rayprofiles.Te[0] = Tea + (Te0 - Tea)*(exp(-eTe*Y[0]*Y[0]) - exp(-eTe))/(1 - exp(-eTe));
       rayprofiles.dTedY[0] = -2*eTe*Y[0]*(Te0 - Tea)*exp(-eTe*Y[0]*Y[0])/(1 - exp(-eTe));  
       rayprofiles.dTedY[1] = 0.0;
       rayprofiles.dTedY[2] = 0.0;
               
       rayprofiles.ne[0] = nea + (ne0 - nea)*(exp(ene) - exp(ene*Y[0]*Y[0]))/(exp(ene) - 1);
       rayprofiles.dnedY[0] = -2*ene*Y[0]*(ne0 - nea)*exp(ene*Y[0]*Y[0])/(exp(ene) - 1);
       rayprofiles.dnedY[1] = 0.0;
       rayprofiles.dnedY[2] = 0.0;
    
       for (is=0;is<ns;is++) {
           rayprofiles.zTi[is] = Tia + (Ti0 - Tia)*(exp(-eTi*Y[0]*Y[0]) - exp(-eTi))/(1 - exp(-eTi));
           rayprofiles.dzTidY[is][0] = -2*eTi*Y[0]*(Ti0 - Tia)*exp(-eTi*Y[0]*Y[0])/(1 - exp(-eTi));
           rayprofiles.dzTidY[is][1] = 0.0;
           rayprofiles.dzTidY[is][2] = 0.0;
       }
    }
    
    for (is=0;is<3;is++) { /*For a single impurity fully stripped. Only the first is selected after the isotope of hydrogen */
        rayprofiles.zni[is] = fi[is]*rayprofiles.ne[0]*(equilparam.zZi[3] - pZeff)/(equilparam.zZi[3]-1.0);
        rayprofiles.dznidY[is][0] = fi[is]*(rayprofiles.dnedY[0]*(equilparam.zZi[3] - pZeff) - rayprofiles.ne[0]*dpZeffdrho)/(equilparam.zZi[3]-1.0);
        rayprofiles.dznidY[is][1] = 0.0;
        rayprofiles.dznidY[is][2] = 0.0;
    }
    
    for (is=3;is<ns;is++) {/*For a single impurity fully stripped. Only the first is selected after the isotope of hydrogen */
        rayprofiles.zni[is] = rayprofiles.ne[0]*(pZeff - 1.0)/(equilparam.zZi[3]-1)/equilparam.zZi[3];
        rayprofiles.dznidY[is][0] = (rayprofiles.dnedY[0]*(pZeff - 1.0) + rayprofiles.ne[0]*dpZeffdrho)/(equilparam.zZi[3]-1)/equilparam.zZi[3];
        rayprofiles.dznidY[is][1] = 0.0;
        rayprofiles.dznidY[is][2] = 0.0;
    }
    
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
    raymagnetic.drndY[2] = 0.0;
    
    R = Rp + ap*rho*cos(theta);
    dRdrho = ap*cos(theta);
    dRdtheta = -ap*rho*sin(theta);
    
    raymagnetic.Rn[0] = R/ap;
    raymagnetic.dRndY[0] = dRdrho/ap;
    raymagnetic.dRndY[1] = dRdtheta/ap;
    raymagnetic.dRndY[2] = 0.0;
    
    Z = Zp + ap*rho*sin(theta);
    dZdrho = ap*sin(theta);
    dZdtheta = ap*rho*cos(theta);
    
    raymagnetic.Zn[0] = Z/ap;
    raymagnetic.dZndY[0] = dZdrho/ap;
    raymagnetic.dZndY[1] = dZdtheta/ap;
    raymagnetic.dZndY[2] = 0.0;
    
    BPHI = Rp*BPHI0/R;
    dBPHIdrho = -BPHI*dRdrho/R;
    dBPHIdtheta =  -BPHI*dRdtheta/R;
    
    BPa = 0.2*fabs(Ip)/ap;/* MA */
    qmax = ep*cyl*fabs(BPHI0)/BPa;/* cylindrical limit */
    
    if ((abs(flag) == 1) || (abs(flag) == 3) ||(abs(flag) == 4) ||(abs(flag) == 5))  {/*RTtest, VERSATOR2, PLT and TORLH */
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
    
    raymagnetic.Brhon[0] = 0.0;/* Normalized radial magnetic field */
    raymagnetic.dBrhondY[0] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    raymagnetic.dBrhondY[1] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    raymagnetic.dBrhondY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    
    raymagnetic.BPHIn[0] = BPHI/B;
    raymagnetic.dBPHIndY[0] = dBPHIdrho/B - BPHI*dBdrho/B/B;
    raymagnetic.dBPHIndY[1] = dBPHIdtheta/B - BPHI*dBdtheta/B/B;
    raymagnetic.dBPHIndY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    
    raymagnetic.Bsn[0] = sigmaIp*BP/B;
    raymagnetic.dBsndY[0] = sigmaIp*(dBPdrho/B - BP*dBdrho/B/B);
    raymagnetic.dBsndY[1] = sigmaIp*(dBPdtheta/B - BP*dBdtheta/B/B);
    raymagnetic.dBsndY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    
    raymagnetic.B[0] = B;
    raymagnetic.dBdY[0] = dBdrho;
    raymagnetic.dBdY[1] = dBdtheta;
    raymagnetic.dBdY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */

    raymagnetic.calpha[0] = 1.0;
    raymagnetic.dcalphadY[0] = 0.0;
    raymagnetic.dcalphadY[1] = 0.0;
    raymagnetic.dcalphadY[2] = 0.0;
    
    raymagnetic.salpha[0] = 0.0;
    raymagnetic.dsalphadY[0] = 0.0;
    raymagnetic.dsalphadY[1] = 0.0;
    raymagnetic.dsalphadY[2] = 0.0;
    
    raymagnetic.gradrhon[0] = 1.0;
    raymagnetic.dgradrhondY[0] = 0.0;
    raymagnetic.dgradrhondY[1] = 0.0;
    raymagnetic.dgradrhondY[2] = 0.0;
    
    raymagnetic.rhorip[0] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    raymagnetic.drhoripdY[0] = 1.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    raymagnetic.drhoripdY[1] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */
    raymagnetic.drhoripdY[2] = 0.0;/* the unperturbed magnetic equilibrium is axisymmetric */

    
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
   else if (x == 0.0) {return(0.0);}    
   else {return(1.0);}    
    
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
    } else if (fabs(flag) == 5) {/* TORLH comparison */
      cyl[0] = 1.0;/* cylindrical factor */
    
      Rp[0] = 2.96*cyl[0];
      Zp[0] = 0;
      ap[0] = 1.25;
      BPHI0[0] = 3.45;/* Signed toroidal magnetic component (T), see the conventions */
      Ip[0] = 2.276446368308309;/* Signed toroidal component of the plasma current (MA), see the conventions */
      qmin[0] = 1.0;/* Edge safety factor q */
      eq[0] = 2.0;/* q=0 flat q profile */

      Te0[0] = 1.0;
      Tea[0] = 1.0;
      eTe[0] = 0.0;
    
      ne0[0] = 3.0e19;
      nea[0] = 3.0e18;
      ene[0] = 1;
    
      Ti0[0] = Te0[0];
      Tia[0] = Tea[0];
      eTi[0] = eTe[0];
    
      fi[0] = 0.0;
      fi[1] = 1.0;
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
      
      Zeff0[0] = 1.7;/* No impurity case, only hydrogen */
      Zeffa[0] = 1.7;
      eZeff[0] = 0.0;
    } 
}


void testparam(rayparam,equilparam,fluctparam,rayequil,rayfluctuations,distriparam,raydistri,flag_fluct,flag_f0)
rayparam_format rayparam;
equilparam_format equilparam;
fluctparam_format fluctparam;
rayequil_format rayequil;
rayfluctuations_format rayfluctuations;
distriparam_format distriparam;
raydistri_format raydistri;
int flag_fluct,flag_f0;
{
    
    double *Te,*ne,*zTi,*zni;
    double *dTedrho,*dnedrho,*dzTidrho,*dznidrho;
    double *d2Tedrho2,*d2nedrho2,*d2zTidrho2,*d2znidrho2;
    
    double *BR,*dBRdrho,*dBRdtheta;   
    double *BZ,*dBZdrho,*dBZdtheta;    
    double *BPHI,*dBPHIdrho,*dBPHIdtheta;
    
    double *x,*dRdrho,*dRdtheta,*d2Rdtheta2,*d2Rdthetadrho;
    double *y,*dZdrho,*dZdtheta,*d2Zdtheta2,*d2Zdthetadrho;
    
    double *L_rho;
    double *xq,*dxqdrho;
    double *xL_theta,*dxL_thetadrho;
    double *xL_perp,*dxL_perpdrho;
    double *XL_phi,*dXL_phidrho,*dXL_phidtheta;
     
    double *sf,*dsfdrho,*dsfdtheta;
    double *sfx,*dsfxdrho,*dsfxdtheta;
    double *sfy,*dsfydrho,*dsfydtheta;
    double *sfz,*dsfzdrho,*dsfzdtheta;
    
    double *f0_fit,*df0drho_fit,*d2f0drho2_fit;
    double *PSI_fit;
    int ip_ref,jm_ref;
    
    double dummy1,dummy2;
    
    int jf,ip,jm;
    
    double xm=-0.71,xp=0.71,ht,dht,d2ht;

    if (equilparam.zZi[0] > 0) {
        mexPrintf("----------------------------------------\n");
        mexPrintf("Te_fit.coefs_f(1): %g\n",rayequil.Te_fit.coefs_f[0]);
        mexPrintf("Te_fit.coefs_dfdrho(1): %g\n",rayequil.Te_fit.coefs_dfdrho[0]);
        mexPrintf("Te_fit.coefs_d2fdrho2(1): %g\n",rayequil.Te_fit.coefs_d2fdrho2[0]);
    }

    mexPrintf("----------------------------------------\n");
    mexPrintf("BPHI_fit.nfourier: %g\n",rayequil.BPHI_fit.dim_dbndrho[0]);
    mexPrintf("BPHI_fit.coefs_bn(1): %g\n",rayequil.BPHI_fit.coefs_bn[0]);
    mexPrintf("BPHI_fit.coefs_dbndrho(1): %g\n",rayequil.BPHI_fit.coefs_dbndrho[0]);
    

    if (equilparam.zZi[0] > 0) { 
        mexPrintf("----------------------------------------\n");
        Te = mxCalloc(1,sizeof(double));
        dTedrho = mxCalloc(1,sizeof(double));
        d2Tedrho2 = mxCalloc(1,sizeof(double));
        ppvald_1D(rayequil.Te_fit,rayparam.dS[0],0.25,Te,dTedrho,d2Tedrho2);
        mexPrintf("Te(0.25),dTedrho(0.25),d2Tedrho2(0.25) (keV): %g,%g,%g\n",Te[0],dTedrho[0],d2Tedrho2[0]);    
        mxFree(Te);
        mxFree(dTedrho);
        mxFree(d2Tedrho2);

        ne = mxCalloc(1,sizeof(double));
        dnedrho = mxCalloc(1,sizeof(double));
        d2nedrho2 = mxCalloc(1,sizeof(double));
        ppvald_1D(rayequil.ne_fit,rayparam.dS[0],0.25,ne,dnedrho,d2nedrho2);
        mexPrintf("ne(0.25),dnedrho(0.25),d2nedrho2(0.25) (10+19 m-3): %g,%g,%g\n",ne[0]/1e19,dnedrho[0]/1e19,d2nedrho2[0]/1e19);    
        mxFree(ne);
        mxFree(dnedrho);
        mxFree(d2nedrho2);

        zTi = mxCalloc(equilparam.ns[0],sizeof(double));
        dzTidrho = mxCalloc(equilparam.ns[0],sizeof(double));
        d2zTidrho2 = mxCalloc(equilparam.ns[0],sizeof(double));
        ppvald_1D(rayequil.zTi_fit,rayparam.dS[0],0.25,zTi,dzTidrho,d2zTidrho2);
        mexPrintf("zTi(2,0.25),dzTidrho(2,0.25),d2zTidrho2(2,0.25) (keV): %g,%g,%g\n",zTi[1],dzTidrho[1],d2zTidrho2[1]);
        mxFree(zTi);
        mxFree(dzTidrho);
        mxFree(d2zTidrho2);

        zni = mxCalloc(equilparam.ns[0],sizeof(double));
        dznidrho = mxCalloc(equilparam.ns[0],sizeof(double));
        d2znidrho2 = mxCalloc(equilparam.ns[0],sizeof(double));
        ppvald_1D(rayequil.zni_fit,rayparam.dS[0],0.25,zni,dznidrho,d2znidrho2);
        mexPrintf("zni(2,0.25),dznidrho(2,0.25),d2znidrho2(2,0.25) (10+19 m-3): %g,%g,%g\n",zni[1]/1e19,dznidrho[1]/1e19,d2znidrho2[1]/1e19);
        mxFree(zni);
        mxFree(dznidrho);
        mxFree(d2znidrho2);
    }

    mexPrintf("----------------------------------------\n");
    x = mxCalloc(1,sizeof(double));
    dRdrho = mxCalloc(1,sizeof(double));
    dRdtheta = mxCalloc(1,sizeof(double));
    d2Rdtheta2 = mxCalloc(1,sizeof(double));
    d2Rdthetadrho = mxCalloc(1,sizeof(double));
    ppvald_2D(rayequil.x_fit,rayparam.dS[0],0.25,0.2,x,dRdrho,dRdtheta,d2Rdtheta2,d2Rdthetadrho);
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
    ppvald_2D(rayequil.y_fit,rayparam.dS[0],0.25,0.2,y,dZdrho,dZdtheta,d2Zdtheta2,d2Zdthetadrho);
    mexPrintf("Z(0.25,0.2),dZdrho(0.25,0.2),dZdtheta(0.25,0.2) (m): %g,%g,%g\n",y[0]+equilparam.Zp[0],dZdrho[0],dZdtheta[0],d2Zdtheta2[0],d2Zdthetadrho[0]);
    mxFree(y);
    mxFree(dZdrho); 
    mxFree(dZdtheta);
    mxFree(d2Zdtheta2);
    mxFree(d2Zdthetadrho);

    BR = mxCalloc(1,sizeof(double));
    dBRdrho = mxCalloc(1,sizeof(double));
    dBRdtheta = mxCalloc(1,sizeof(double));
    ppvald_2D(rayequil.Bx_fit,rayparam.dS[0],0.25,0.2,BR,dBRdrho,dBRdtheta,&dummy1,&dummy2);
    mexPrintf("BR(0.25,0.2),dBRdrho(0.25,0.2),dBRdtheta(0.25,0.2) (T): %g,%g,%g\n",BR[0],dBRdrho[0],dBRdtheta[0]);
    mxFree(BR);
    mxFree(dBRdrho); 
    mxFree(dBRdtheta); 

    BZ = mxCalloc(1,sizeof(double));
    dBZdrho = mxCalloc(1,sizeof(double));
    dBZdtheta = mxCalloc(1,sizeof(double));
    ppvald_2D(rayequil.By_fit,rayparam.dS[0],0.25,0.2,BZ,dBZdrho,dBZdtheta,&dummy1,&dummy2);
    mexPrintf("BZ(0.25,0.2),dBZdrho(0.25,0.2),dBZdtheta(0.25,0.2) (T): %g,%g,%g\n",BZ[0],dBZdrho[0],dBZdtheta[0]);
    mxFree(BZ);
    mxFree(dBZdrho); 
    mxFree(dBZdtheta);     

    BPHI = mxCalloc(1,sizeof(double));
    dBPHIdrho = mxCalloc(1,sizeof(double));
    dBPHIdtheta = mxCalloc(1,sizeof(double));
    ppvald_2D(rayequil.BPHI_fit,rayparam.dS[0],0.25,0.2,BPHI,dBPHIdrho,dBPHIdtheta,&dummy1,&dummy2);
    mexPrintf("BPHI(0.25,0.2),dBPHIdrho(0.25,0.2),dBPHIdtheta(0.25,0.2) (T): %g,%g,%g\n",BPHI[0],dBPHIdrho[0],dBPHIdtheta[0]);
    mxFree(BPHI);
    mxFree(dBPHIdrho); 
    mxFree(dBPHIdtheta);

    
    if (flag_f0 == 1) {/*Wave aborption is calculated with a non-Maxwellian distribution function */
        
        mexPrintf("----------------------------------------\n");
        mexPrintf("tol : %g\n",rayparam.tol[0]);
        mexPrintf("zZi(2) : %g\n",equilparam.zZi[1]);
                
        mexPrintf("----------------------------------------\n");
        mexPrintf("Wave aborption is calculated with a non-Maxwellian distribution function.\n");
        mexPrintf("----------------------------------------\n");
        mexPrintf("npn, pn(1),pn(end) : %d,%g,%g\n",distriparam.npn[0],distriparam.pn[0],distriparam.pn[distriparam.npn[0]-1]);
        mexPrintf("nmhu, mhu(1),mhu(end) : %d,%g,%g\n",distriparam.nmhu[0],distriparam.mhu[0],distriparam.mhu[distriparam.nmhu[0]-1]);
        mexPrintf("ne_ref, betath_ref : %g,%g\n",distriparam.ne_ref[0],distriparam.betath_ref[0]);
        
        mexPrintf("----------------------------------------\n");
        mexPrintf("f0_fit.coefs_f(1): %g\n",raydistri.f0_fit.coefs_f[0]);
        mexPrintf("f0_fit.coefs_dfdrho(1): %g\n",raydistri.f0_fit.coefs_dfdrho[0]);
        mexPrintf("f0_fit.coefs_d2fdrho2(1): %g\n",raydistri.f0_fit.coefs_d2fdrho2[0]);
        
        mexPrintf("----------------------------------------\n");
        
        for (ip = 0; ip < distriparam.npn[0]; ip++) {
            if (distriparam.pn[ip] < 4.0) ip_ref = ip;/*seek for the index of the closest value of pn less than 4.0 */
        }
        
        for (jm = 0; jm < distriparam.nmhu[0]; jm++) {
            if (distriparam.mhu[jm] < 0.5) jm_ref = jm;/*seek for the index of the closest value of mhu less than 0.5 */
        }
        
        mexPrintf("ip_ref,pn(ip_ref): %d,%g\n",ip_ref,distriparam.pn[ip_ref]);
        mexPrintf("jm_ref,mhu(jm_ref): %d,%g\n",jm_ref,distriparam.mhu[jm_ref]);
        
        f0_fit = mxCalloc(distriparam.npn[0]*distriparam.nmhu[0],sizeof(double));
        df0drho_fit = mxCalloc(distriparam.npn[0]*distriparam.nmhu[0],sizeof(double));
        d2f0drho2_fit = mxCalloc(distriparam.npn[0]*distriparam.nmhu[0],sizeof(double));
        ppvald_1D(raydistri.f0_fit,rayparam.dS[0],0.25,f0_fit,df0drho_fit,d2f0drho2_fit);
        
        mexPrintf("f0_fit(ip_ref,jm_ref,rho=0.25): %g\n",f0_fit[jm_ref*distriparam.npn[0]+ip_ref]);
        mxFree(f0_fit);
        mxFree(df0drho_fit);
        mxFree(d2f0drho2_fit);
        
        mexPrintf("----------------------------------------\n");
        mexPrintf("PSI_fit.nfourier: %g\n",raydistri.PSI_fit.dim_dbndrho[0]);
        mexPrintf("PSI_fit.coefs_bn(1): %g\n",raydistri.PSI_fit.coefs_bn[0]);
        mexPrintf("PSI_fit.coefs_dbndrho(1): %g\n",raydistri.PSI_fit.coefs_dbndrho[0]);
        
        PSI_fit = mxCalloc(1,sizeof(double));
        ppvald_2D(raydistri.PSI_fit,rayparam.dS[0],0.25,0.2,PSI_fit,&dummy1,&dummy1,&dummy1,&dummy1);
        mexPrintf("PSI(0.25,0.2) : %g\n",PSI_fit[0]);
        mxFree(PSI_fit);
    }
    
    
    if (flag_fluct == 1) {
        
        mexPrintf("----------------------------------------\n");
        
        halftanh(xm,&ht,&dht,&d2ht);
        mexPrintf("Fluctuations -> halftanh(x),x,f,df,d2f: %25.15g,%25.15g,%25.15g,%25.15g\n",xm,ht,dht,d2ht);
        halftanh(xp,&ht,&dht,&d2ht);
        mexPrintf("Fluctuations -> halftanh(x),x,f,df,d2f: %25.15g,%25.15g,%25.15g,%25.15g\n",xp,ht,dht,d2ht);        
        
        
        xq = mxCalloc(1,sizeof(double));
        dxqdrho = mxCalloc(1,sizeof(double));
        L_rho = mxCalloc(1,sizeof(double));
        xL_theta = mxCalloc(1,sizeof(double));
        dxL_thetadrho = mxCalloc(1,sizeof(double));
        xL_perp = mxCalloc(1,sizeof(double));
        dxL_perpdrho = mxCalloc(1,sizeof(double));
        XL_phi = mxCalloc(1,sizeof(double));
        dXL_phidrho = mxCalloc(1,sizeof(double));
        dXL_phidtheta = mxCalloc(1,sizeof(double));
        ppvald_0D(rayfluctuations.L_rho,L_rho);
        ppvald_1D(rayfluctuations.xq_fit,rayparam.dS[0],0.25,xq,dxqdrho,&dummy1);
        ppvald_1D(rayfluctuations.xL_theta_fit,rayparam.dS[0],0.25,xL_theta,dxL_thetadrho,&dummy1);
        ppvald_1D(rayfluctuations.xL_perp_fit,rayparam.dS[0],0.25,xL_perp,dxL_perpdrho,&dummy1);
        ppvald_2D(rayfluctuations.XL_phi_fit,rayparam.dS[0],0.25,0.2,XL_phi,dXL_phidrho,dXL_phidtheta,&dummy1,&dummy2);
        mexPrintf("----------------------------------------\n");
        mexPrintf("Fluctuations -> xq(0.25),dxqdrho(0.25): %g,%g\n",xq[0],dxqdrho[0]);
        mexPrintf("Fluctuations -> L_rho: %g\n",L_rho[0]);
        mexPrintf("Fluctuations -> xL_theta(0.25),dxL_thetadrho(0.25): %g,%g\n",xL_theta[0],dxL_thetadrho[0]);
        mexPrintf("Fluctuations -> xL_perp(0.25),dxL_perpdrho(0.25): %g,%g\n",xL_perp[0],dxL_perpdrho[0]);
        mexPrintf("Fluctuations -> XL_phi(0.25,0.2),dXL_phidrho(0.25,0.2),dXL_phidtheta(0.25,0.2): %g,%g,%g\n",XL_phi[0],dXL_phidrho[0],dXL_phidtheta[0]);
        mexPrintf("----------------------------------------\n");   
        mxFree(xq);
        mxFree(dxqdrho);
        mxFree(L_rho);
        mxFree(xL_theta);
        mxFree(dxL_thetadrho);
        mxFree(xL_perp);
        mxFree(dxL_perpdrho);
        mxFree(XL_phi);
        mxFree(dXL_phidrho); 
        mxFree(dXL_phidtheta);

        if (fluctparam.ne_nmodel[0]) {
            mexPrintf("----------------------------------------\n");
            mexPrintf("Fluctuations -> nmodel for ne: %d\n",fluctparam.ne_nmodel[0]);
            for (jf=0; jf < fluctparam.ne_nmodel[0]; jf++) {
                mexPrintf("--------------------------\n");
                mexPrintf("Fluctuations for ne -> model(%d): %g\n",jf,fluctparam.ne_model[jf][0]);
                if (fluctparam.ne_sigmar_max[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_sigmar_max(%d): %g\n",0,fluctparam.ne_sigmar_max[jf][0]);
                if (fluctparam.ne_sigmar_hwhm[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_sigmar_hwhm(%d): %g\n",0,fluctparam.ne_sigmar_hwhm[jf][0]);
                if (fluctparam.ne_sigmar_rho[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_sigmar_rho(%d): %g\n",0,fluctparam.ne_sigmar_rho[jf][0]);
                if (fluctparam.ne_polmode[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_polmode(%d): %g\n",0,fluctparam.ne_polmode[jf][0]);
                if (fluctparam.ne_epsi_rho[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_epsi_rho(%d): %g\n",0,fluctparam.ne_epsi_rho[jf][0]);
                if (fluctparam.ne_epsi_theta[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_epsi_theta(%d): %g\n",0,fluctparam.ne_epsi_theta[jf][0]);
                if (fluctparam.ne_epsi_phi[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_epsi_phi(%d): %g\n",0,fluctparam.ne_epsi_phi[jf][0]);
                if (fluctparam.ne_lmin[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_lmin(%d): %g\n",0,fluctparam.ne_lmin[jf][0]);
                if (fluctparam.ne_mmin[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_mmin(%d): %g\n",0,fluctparam.ne_mmin[jf][0]);
                if (fluctparam.ne_nmin[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_nmin(%d): %g\n",0,fluctparam.ne_nmin[jf][0]);
                if (fluctparam.ne_lmax[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_lmax(%d): %g\n",0,fluctparam.ne_lmax[jf][0]);
                if (fluctparam.ne_mmax[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_mmax(%d): %g\n",0,fluctparam.ne_mmax[jf][0]);
                if (fluctparam.ne_nmax[jf] != NULL) mexPrintf("Fluctuations for ne -> ne_nmax(%d): %g\n",0,fluctparam.ne_nmax[jf][0]);              
                if (fluctparam.ne_phase[jf] != NULL) mexPrintf("Fluctuations for ne -> phase(%d)(end): %g\n",jf,fluctparam.ne_phase[jf][fluctparam.ne_nphase[jf][0]-1]);

            } 
        } else {   
            mexPrintf("Fluctuations -> no model for ne\n");     
        }

        if (fluctparam.B_nmodel[0]) {
            mexPrintf("----------------------------------------\n");
            mexPrintf("Fluctuations -> nmodel for B: %d\n",fluctparam.B_nmodel[0]);
            for (jf=0; jf < fluctparam.B_nmodel[0]; jf++) {
                mexPrintf("--------------------------\n");
                mexPrintf("Fluctuations for B -> model(%d): %g\n",jf,fluctparam.B_model[jf][0]);
                if (fluctparam.B_sigmar_max[jf] != NULL) mexPrintf("Fluctuations for B -> B_sigmar_max(%d): %g\n",0,fluctparam.B_sigmar_max[jf][0]);
                if (fluctparam.B_sigmar_hwhm[jf] != NULL) mexPrintf("Fluctuations for B -> B_sigmar_hwhm(%d): %g\n",0,fluctparam.B_sigmar_hwhm[jf][0]);
                if (fluctparam.B_sigmar_rho[jf] != NULL) mexPrintf("Fluctuations for B -> B_sigmar_rho(%d): %g\n",0,fluctparam.B_sigmar_rho[jf][0]);
                if (fluctparam.B_polmode[jf] != NULL) mexPrintf("Fluctuations for B -> B_polmode(%d): %g\n",0,fluctparam.B_polmode[jf][0]);
                if (fluctparam.B_epsi_rho[jf] != NULL) mexPrintf("Fluctuations for B -> B_epsi_rho(%d): %g\n",0,fluctparam.B_epsi_rho[jf][0]);
                if (fluctparam.B_epsi_theta[jf] != NULL) mexPrintf("Fluctuations for B -> B_epsi_theta(%d): %g\n",0,fluctparam.B_epsi_theta[jf][0]);
                if (fluctparam.B_epsi_phi[jf] != NULL) mexPrintf("Fluctuations for B -> B_epsi_phi(%d): %g\n",0,fluctparam.B_epsi_phi[jf][0]);
                if (fluctparam.B_lmin[jf] != NULL) mexPrintf("Fluctuations for B -> B_lmin(%d): %g\n",0,fluctparam.B_lmin[jf][0]);
                if (fluctparam.B_mmin[jf] != NULL) mexPrintf("Fluctuations for B -> B_mmin(%d): %g\n",0,fluctparam.B_mmin[jf][0]);
                if (fluctparam.B_nmin[jf] != NULL) mexPrintf("Fluctuations for B -> B_nmin(%d): %g\n",0,fluctparam.B_nmin[jf][0]);
                if (fluctparam.B_lmax[jf] != NULL) mexPrintf("Fluctuations for B -> B_lmax(%d): %g\n",0,fluctparam.B_lmax[jf][0]);
                if (fluctparam.B_mmax[jf] != NULL) mexPrintf("Fluctuations for B -> B_mmax(%d): %g\n",0,fluctparam.B_mmax[jf][0]);
                if (fluctparam.B_nmax[jf] != NULL) mexPrintf("Fluctuations for B -> B_nmax(%d): %g\n",0,fluctparam.B_nmax[jf][0]);              
                if (fluctparam.B_phase[jf] != NULL) mexPrintf("Fluctuations for B -> phase(%d)(end): %g\n",jf,fluctparam.B_phase[jf][fluctparam.B_nphase[jf][0]-1]);

                if (rayfluctuations.B_sfx_fit[jf].dim_a0 != NULL) {
                    mexPrintf("--------------------------\n");
                    sfx = mxCalloc(1,sizeof(double));
                    dsfxdrho = mxCalloc(1,sizeof(double));
                    dsfxdtheta = mxCalloc(1,sizeof(double));
                    ppvald_2D(rayfluctuations.B_sfx_fit[jf],rayparam.dS[0],0.25,0.2,sfx,dsfxdrho,dsfxdtheta,&dummy1,&dummy2);
                    mexPrintf("B -> Xfx(0.25,0.2),dXfxdrho(0.25,0.2),dXfxdtheta(0.25,0.2): %g,%g,%g\n",sfx[0],dsfxdrho[0],dsfxdtheta[0]);
                    mxFree(sfx);
                    mxFree(dsfxdrho); 
                    mxFree(dsfxdtheta);
                }
                
                if (rayfluctuations.B_sfy_fit[jf].dim_a0 != NULL) {
                    sfy = mxCalloc(1,sizeof(double));
                    dsfydrho = mxCalloc(1,sizeof(double));
                    dsfydtheta = mxCalloc(1,sizeof(double));
                    ppvald_2D(rayfluctuations.B_sfy_fit[jf],rayparam.dS[0],0.25,0.2,sfy,dsfydrho,dsfydtheta,&dummy1,&dummy2);
                    mexPrintf("B -> Xfy(0.25,0.2),dXfydrho(0.25,0.2),dXfydtheta(0.25,0.2): %g,%g,%g\n",sfy[0],dsfydrho[0],dsfydtheta[0]);
                    mxFree(sfy);
                    mxFree(dsfydrho); 
                    mxFree(dsfydtheta);
                }

                if (rayfluctuations.B_sfz_fit[jf].dim_a0 != NULL) {
                    sfz = mxCalloc(1,sizeof(double));
                    dsfzdrho = mxCalloc(1,sizeof(double));
                    dsfzdtheta = mxCalloc(1,sizeof(double));
                    ppvald_2D(rayfluctuations.B_sfz_fit[jf],rayparam.dS[0],0.25,0.2,sfz,dsfzdrho,dsfzdtheta,&dummy1,&dummy2);
                    mexPrintf("B -> Xfz(0.25,0.2),dXfzdrho(0.25,0.2),dXfzdtheta(0.25,0.2): %g,%g,%g\n",sfz[0],dsfzdrho[0],dsfzdtheta[0]);
                    mxFree(sfz);
                    mxFree(dsfzdrho); 
                    mxFree(dsfzdtheta);
                }

            } 
        } else {   
            mexPrintf("Fluctuations -> no model for B\n");     
        }            
    } 
}

void halftanh(x,f,df,d2f)
double x,*f,*df,*d2f;
{
   if (x >= 0.0) {
        *f = x;
        *df = 1.0;
        *d2f = 0.0;
    } else {
        if (x < -400) {
            *f = -1;
            *df = 0;
            *d2f = 0;
        } else {
            *f = tanh(x);
            *df = 1.0/cosh(x)/cosh(x);
            *d2f = -2.0*df[0]*sinh(x)/cosh(x);            
        }
    }
}
