/*
  
    raytracing.c    MEX file implementation of a universal ray-tracing for electron waves

    call -> [tout, yout] = raytracing_yp(rayparam,equil)

    INPUT: 

    - rayparam: parameters for ray-tracing structure [1,1]
    - equil: numerical equilibrium structure [1,1]

    OUTPUT: 

    - tout: returned integration time points (row-vector).
    - yout: returned solution, one solution column-vector per tout-value.

    WARNING: none

    REFERENCE: none

    LAST UPDATE: 23/07/2006

    by Y.PEYSSON (CEA-DRFC)  <yves.peysson@cea.fr> and Joan Decker (CEA-DRFC) <joan.decker@cea.fr>
*/

#include <math.h>
#include "mex.h"

struct rayparam {
    double  *t0;
    double *tfinal;
    double *dt0;
    double *dpsi;
    double *tol;
    double *kmax;
};

struct equilparam {
    double  *zZi;
    double *zmi;
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

void ppval_1D();
void ppval_2D();
void runge_kutta();
void ray();
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

    if (nrhs != 2) {
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

    
    mexPrintf("tol : %g\n",rayparam.tol[0]);
    mexPrintf("zZi(4) : %g\n",equilparam.zZi[3]);
    
    Te_fit = load_equil_1D(EQUIL_IN,"Te_fit");
    ne_fit = load_equil_1D(EQUIL_IN,"ne_fit");
    zTi_fit = load_equil_1D(EQUIL_IN,"zTi_fit"); 
    zni_fit = load_equil_1D(EQUIL_IN,"zni_fit");
//
    BPHI_fit = load_equil_2D(EQUIL_IN,"BPHI_fit");
    BP_fit = load_equil_2D(EQUIL_IN,"BP_fit");
    R_fit = load_equil_2D(EQUIL_IN,"R_fit");
    Z_fit = load_equil_2D(EQUIL_IN,"Z_fit");
    r_fit = load_equil_2D(EQUIL_IN,"r_fit");
    calpha_fit = load_equil_2D(EQUIL_IN,"calpha_fit");
    
/* keep this section for tests if necessary*/
 

    mexPrintf("Te_fit.coefs_f(1): %g\n",Te_fit.coefs_f[0]);
    mexPrintf("Te_fit.coefs_dfpsi(1): %g\n",Te_fit.coefs_dfdpsi[0]);
    mexPrintf("BPHI_fit.n: %g\n",BPHI_fit.n[0]);
    mexPrintf("BPHI_fit.coefs_bn(1): %g\n",BPHI_fit.coefs_bn[0]);
    mexPrintf("BPHI_fit.coefs_dbndpi(1): %g\n",BPHI_fit.coefs_dbndpsi[0]);

    
    Te = mxCalloc(1,sizeof(double));
    dTedpsi = mxCalloc(1,sizeof(double));
    ppval_1D(Te_fit,0.25,Te,dTedpsi);
    mexPrintf("Te(0.25),dTedpsi(0.25): %g,%g\n",Te[0],dTedpsi[0]);    
    mxFree(Te);
    mxFree(dTedpsi);
 
    zni = mxCalloc(4,sizeof(double));// **************connaitre taille zni
    dznidpsi = mxCalloc(4,sizeof(double));
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

    // Runge-Kutta part


}


rayparam_format load_ray_param(structure_name)
mxArray *structure_name;
{
    rayparam_format data;
       
    data.t0 = mxGetData(mxGetField(structure_name, 0, "t0"));
    data.tfinal = mxGetData(mxGetField(structure_name, 0, "tfinal"));
    data.dt0 = mxGetData(mxGetField(structure_name, 0, "dt0"));
    data.dpsi = mxGetData(mxGetField(structure_name, 0, "dpsi"));
    data.tol = mxGetData(mxGetField(structure_name, 0, "tol"));   
    data.kmax = mxGetData(mxGetField(structure_name, 0, "kmax"));
    
    return(data);
}

equilparam_format load_equil_param(structure_name)
mxArray *structure_name;
{
    equilparam_format data;
       
    data.zZi= mxGetData(mxGetField(structure_name, 0, "zZi"));
    data.zmi = mxGetData(mxGetField(structure_name, 0, "zmi"));
    
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
//                    mexPrintf("kk,y: %d,%g\n",k,y[k-1]); 
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
//                    mexPrintf("k,dydx: %d%g\n",k,dydx[k-1]); 
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
//                    mexPrintf("kk,y: %d,%g\n",k,y[k-1]); 
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
//                    mexPrintf("k,dydx: %d%g\n",k,dydx[k-1]); 
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
//                    mexPrintf("kk,y: %d,%g\n",k,y[k-1]); 
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
//                    mexPrintf("k,dydx: %d%g\n",k,dydx[k-1]); 
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
      y[0] = y[0] + an[k-1]*cos(k*x) + bn[k-1]*sin(k*x);
      dydx[0] = dydx[0] + dandx[k-1]*cos(k*x) + dbndx[k-1]*sin(k*x);
      dydt[0] = dydt[0] - k*an[k-1]*sin(k*x) + k*bn[k-1]*cos(k*x);
    }
    
    y[0] = y[0] + a0[0];
    dydx[0] = y[0] + da0dx[0];
    
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

/*Calcul du vecteur evolution temporel dX/dt avec X=[psi,theta,psi,kpsi,ktheta,kphi]*/


void ray(Xdot,X,param,equilparam,Te_fit,ne_fit,zTi_fit,zni_fit,BPHI_fit,BP_fit,R_fit,Z_fit,r_fit,calpha_fit)
double X[];
double Xdot[];
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

double psi,theta,phi,kpsi,m,n;

psi = X[0];
theta = X[1];
phi = X[2];
kpsi = X[3];
m = X[4];
//n = X[5];


/*  
    dDdw = 
    dDdr = 
    dDdtheta = 
    dDdz = 
    dDdkr = 
    dDdm = 
    dDdkz = 

    Xdot[0] = -dDdkpsi/dDdw;
    Xdot[1] = -dDdm/dDdw;
    Xdot[2] = -dDdn/dDdw;
    Xdot[3] = dDdpsi/dDdw;
    Xdot[4] = dDdtheta/dDdw;
*/
}


