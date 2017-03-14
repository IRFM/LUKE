
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


void ppvald_0D(pp_0D_format in,double y[])
{
    y[0] = in.data[0];
}


void ppvald_1D(pp_1D_format in,double drho_lim,double x,double y[],double dydY[],double d2ydY2[])
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
    
    for (j = 0;j < (int)in.pieces_d2fdrho2[0];j++) {
        if ((x>=in.breaks_d2fdrho2[j]) && (x<=in.breaks_d2fdrho2[j+1])) {
            for (k = 1;k <= (int)in.dim_d2fdrho2[0]; k++) {
                if ((int)in.order_d2fdrho2[0] == 2) {
                    i0 = k-1+j*(int)in.dim_d2fdrho2[0] + 0*(int)in.pieces_d2fdrho2[0]*(int)in.dim_d2fdrho2[0];
                    i1 = k-1+j*(int)in.dim_d2fdrho2[0] + 1*(int)in.pieces_d2fdrho2[0]*(int)in.dim_d2fdrho2[0];
                    d2ydY2[k-1] = in.coefs_d2fdrho2[i0]*(x - in.breaks_d2fdrho2[j]) + in.coefs_d2fdrho2[i1];
                } else if ((int)in.order_d2fdrho2[0] == 3) {
                    i0 = k-1+j*(int)in.dim_d2fdrho2[0] + 0*(int)in.pieces_d2fdrho2[0]*(int)in.dim_d2fdrho2[0];
                    i1 = k-1+j*(int)in.dim_d2fdrho2[0] + 1*(int)in.pieces_d2fdrho2[0]*(int)in.dim_d2fdrho2[0];
                    i2 = k-1+j*(int)in.dim_d2fdrho2[0] + 2*(int)in.pieces_d2fdrho2[0]*(int)in.dim_d2fdrho2[0];                    
                    d2ydY2[k-1] = in.coefs_d2fdrho2[i0]*pow((x - in.breaks_d2fdrho2[j]),2) + in.coefs_d2fdrho2[i1]*(x - in.breaks_d2fdrho2[j]) + in.coefs_d2fdrho2[i2];
                   /* mexPrintf("k,d2ydY2: %d%g\n",k,d2ydY2[k-1]);*/
                } else if ((int)in.order_d2fdrho2[0] == 4) {
                    i0 = k-1+j*(int)in.dim_d2fdrho2[0] + 0*(int)in.pieces_d2fdrho2[0]*(int)in.dim_d2fdrho2[0];
                    i1 = k-1+j*(int)in.dim_d2fdrho2[0] + 1*(int)in.pieces_d2fdrho2[0]*(int)in.dim_d2fdrho2[0];
                    i2 = k-1+j*(int)in.dim_d2fdrho2[0] + 2*(int)in.pieces_d2fdrho2[0]*(int)in.dim_d2fdrho2[0];
                    i3 = k-1+j*(int)in.dim_d2fdrho2[0] + 3*(int)in.pieces_d2fdrho2[0]*(int)in.dim_d2fdrho2[0];
                    d2ydY2[k-1] = in.coefs_d2fdrho2[i0]*pow((x - in.breaks_d2fdrho2[j]),3) + in.coefs_d2fdrho2[i1]*pow((x - in.breaks_d2fdrho2[j]),2) + in.coefs_d2fdrho2[i2]*(x - in.breaks_d2fdrho2[j]) + in.coefs_d2fdrho2[i3];
                }
            }
        }
    }

}




void ppvald_2D(pp_2D_format in,double drho_lim, double x, double t, double* y, double* dydY, double* dydt, double* d2ydt2, double* d2ydtdY)
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


void ppvali_2D(pp_2D_format in,double drho_lim, double x, double t0, double t, double* iy, double* idydY)
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
    
    iy[0] = 0.0;
    idydY[0] = 0.0;
    
    for (k = 1;k <= (int)in.dim_dbndrho[0]; k++) {
        iy[0] = iy[0] + an[k-1]*(sin(k*t) - sin(k*t0))/k + bn[k-1]*(cos(k*t0) - cos(k*t))/k;
        idydY[0] = idydY[0] + dandY[k-1]*(sin(k*t) - sin(k*t0))/k + dbndY[k-1]*(cos(k*t0) - cos(k*t))/k;
    }
    
    iy[0] = iy[0] + a0[0]*(t - t0);
    idydY[0] = idydY[0] + da0dY[0]*(t - t0);
    
    mxFree(a0);
    mxFree(da0dY);
    mxFree(an);
    mxFree(dandY);
    mxFree(bn);
    mxFree(dbndY);

}

