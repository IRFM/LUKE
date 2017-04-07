/*
	test_grid_substitution_gb.c	MEX file the mean precision, execution time and dispersion of the (x,y)->(rho,theta)->(x,y) on a chosen grid
 
	test_grid_substitution_gb(equil_IN,rayparam_IN,equilparam_IN,ngrid_IN,length_IN)
 
	INPUT:
 - Magnetic equilibrium                           : equil_IN
 - Ray parameters                                 : rayparam_IN
 - Equilibrium parameters                         : equilparam_IN
 - Number of points on a side of the grid         : ngrid_IN
 - Length of the grid                             : length_IN
 
	OUTPUT:
	
 - Three dimension array : data
 - Mean precision        : data[0]
 - Mean dispersion       : data[1]
 - Mean execution time   : data[2]
 
 By Guillaume Brochard (CEA-DRFC, guillaume.brochard@cea.fr)
 */

#define DUMP(u) mexPrintf("%s = %e\n", #u, u)

#include <math.h>
#include "mex.h"
#include <complex.h>
#include "structures_raytracing_yp.h"
#include <time.h>

/*input arguments*/

#define	equil_IN        prhs[0]
#define rayparam_IN     prhs[1]
#define equilparam_IN   prhs[2]
#define ngrid_IN        prhs[3]
#define length_IN       prhs[4]

#define data_OUT       plhs[0]

void rho1D();
void rho1D_newton();
void substitution();
void substitution_newton();

void rho1D(rayequil_format rayequil,rayparam_format rayparam, equilparam_format equilparam, double *rho,double *theta,double *Y)
{
    double down[2],up[2],res[2];
    down[0]=0;
    up[0]=1;
    double dummy,x,y,dxdrho,dydrho;
    int k = 0;
    res[1]=1;
    int kmax = 60;
    double prec = 1e-10;
    while(k < kmax && fabs(res[1]) > prec)
    {
        k = k +1;
        
        res[0] = (down[0] + up[0])/2;
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],down[0],theta[0],&x,&dxdrho,&dummy,&dummy,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],down[0],theta[0],&y,&dydrho,&dummy,&dummy,&dummy,&dummy,&dummy);
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdrho=dxdrho/equilparam.ap[0];//Mandatory normalization
        dydrho=dydrho/equilparam.ap[0];//Mandatory normalization
        down[1] = dxdrho*(x-Y[0]) + dydrho*(y - Y[1]);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],res[0],theta[0],&x,&dxdrho,&dummy,&dummy,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],res[0],theta[0],&y,&dydrho,&dummy,&dummy,&dummy,&dummy,&dummy);
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdrho=dxdrho/equilparam.ap[0];//Mandatory normalization
        dydrho=dydrho/equilparam.ap[0];//Mandatory normalization
        res[1] = dxdrho*(x-Y[0]) + dydrho*(y - Y[1]);
        
        if(down[1]*res[1]>0)
        {
            down[0]=res[0];
        }
        else
        {
            up[0]=res[0];
        }
    }
    rho[0]=res[0];
}

void substitution(rayequil_format rayequil,rayparam_format rayparam, equilparam_format equilparam, double *rho,double *theta,double *Y)
{
    theta[0] = atan2(Y[1],Y[0]);
    double down_t[2],up_t[2],res_t[2];
    res_t[0] = theta[0];
    down_t[0] = theta[0]*0.9;
    up_t[0] = theta[0]*1.1;
    double dummy,x,y,dxdtheta,dydtheta,rho_d,rho_m;
    int k=0;
    int kmax = 60;
    double prec = 1e-11;
    res_t[1] = 1;
    while(k < kmax && fabs(res_t[1]) > prec)
    {
        k = k + 1;
        res_t[0] = (down_t[0] + up_t[0])/2;
        rho1D(rayequil,rayparam,equilparam,&rho_d,&down_t[0],Y);
        rho1D(rayequil,rayparam,equilparam,&rho_m,&res_t[0],Y);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho_d,down_t[0],&x,&dummy,&dxdtheta,&dummy,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho_d,down_t[0],&y,&dummy,&dydtheta,&dummy,&dummy,&dummy,&dummy);
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdtheta=dxdtheta/equilparam.ap[0];//Mandatory normalization
        dydtheta=dydtheta/equilparam.ap[0];//Mandatory normalization
        down_t[1] = dxdtheta*(x-Y[0]) + dydtheta*(y-Y[1]);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho_m,res_t[0],&x,&dummy,&dxdtheta,&dummy,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho_m,res_t[0],&y,&dummy,&dydtheta,&dummy,&dummy,&dummy,&dummy);
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdtheta=dxdtheta/equilparam.ap[0];//Mandatory normalization
        dydtheta=dydtheta/equilparam.ap[0];//Mandatory normalization
        res_t[1] = dxdtheta*(x-Y[0]) + dydtheta*(y-Y[1]);
        
        if(down_t[1]*res_t[1]>0)
        {
            down_t[0] = res_t[0];
        }
        else
        {
            up_t[0] = res_t[0];
        }
    }
    theta[0] = res_t[0];
    rho1D(rayequil,rayparam,equilparam,rho,theta,Y);
}

void rho1D_newton(rayequil_format rayequil,rayparam_format rayparam, equilparam_format equilparam, double *rho,double *theta,double *Y)
{
    double down[2],res[2];
    down[0]=0.01;
    res[0]=0.01000000000001;
    double dummy,x,y,dxdrho,dydrho;
    int k = 0;
    res[1]=1;
    int kmax = 10;
    double prec = 1e-10;
    double save1,save2;
    while(k < kmax && fabs(res[1]) > prec)
    {
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],down[0],theta[0],&x,&dxdrho,&dummy,&dummy,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],down[0],theta[0],&y,&dydrho,&dummy,&dummy,&dummy,&dummy,&dummy);
        
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdrho=dxdrho/equilparam.ap[0];//Mandatory normalization
        dydrho=dydrho/equilparam.ap[0];//Mandatory normalization
        
        down[1] = dxdrho*(x-Y[0]) + dydrho*(y - Y[1]);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],res[0],theta[0],&x,&dxdrho,&dummy,&dummy,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],res[0],theta[0],&y,&dydrho,&dummy,&dummy,&dummy,&dummy,&dummy);
        
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdrho=dxdrho/equilparam.ap[0];//Mandatory normalization
        dydrho=dydrho/equilparam.ap[0];//Mandatory normalization
        
        res[1] = dxdrho*(x-Y[0]) + dydrho*(y - Y[1]);
        
        save1 = res[0];
        save2 = res[1];
        res[0] = res[0] - res[1]*((res[0] - down[0])/(res[1] - down[1]));
        down[0] = save1;
        down[1] = save2;
        
        k = k +1;
        
    }
    rho[0]=res[0];
}

void substitution_newton(rayequil_format rayequil,rayparam_format rayparam, equilparam_format equilparam, double *rho,double *theta,double *Y)
{
    theta[0] = atan2(Y[1],Y[0]);
    double down_t[2],res_t[2];
    double dummy,x,y,dxdtheta,dydtheta,rho_d,rho_m;
    down_t[0] = theta[0];
    
    rho1D_newton(rayequil,rayparam,equilparam,&rho_d,&down_t[0],Y);
    ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho_d,down_t[0],&x,&dummy,&dxdtheta,&dummy,&dummy,&dummy,&dummy);
    ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho_d,down_t[0],&y,&dummy,&dydtheta,&dummy,&dummy,&dummy,&dummy);
    x=x/equilparam.ap[0];//Mandatory normalization
    y=y/equilparam.ap[0];//Mandatory normalization
    dxdtheta=dxdtheta/equilparam.ap[0];//Mandatory normalization
    dydtheta=dydtheta/equilparam.ap[0];//Mandatory normalization
    down_t[1] = dxdtheta*(x-Y[0]) + dydtheta*(y-Y[1]);
    
    res_t[0] = 1.0000000000001*down_t[0];
    int kt=0;
    int ktmax = 10;
    double prec = 1e-11;
    res_t[1] = 1;
    double save1,save2;
    while(kt < ktmax && fabs(res_t[1]) > prec)
    {
        rho1D_newton(rayequil,rayparam,equilparam,&rho_m,&res_t[0],Y);
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho_m,res_t[0],&x,&dummy,&dxdtheta,&dummy,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho_m,res_t[0],&y,&dummy,&dydtheta,&dummy,&dummy,&dummy,&dummy);
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdtheta=dxdtheta/equilparam.ap[0];//Mandatory normalization
        dydtheta=dydtheta/equilparam.ap[0];//Mandatory normalization
        res_t[1] = dxdtheta*(x-Y[0]) + dydtheta*(y-Y[1]);
        
        save1 = res_t[0];
        save2 = res_t[1];
        res_t[0] = res_t[0] - res_t[1]*((res_t[0] - down_t[0])/(res_t[1] - down_t[1]));
        down_t[0] = save1;
        down_t[1] = save2;
        
        kt = kt + 1;
        
    }
    theta[0] = res_t[0];
    rho1D_newton(rayequil,rayparam,equilparam,rho,theta,Y);
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *data,*Y,*rho,*theta,*ngrid,*length;
    
    rho = mxCalloc(1,sizeof(double));
    theta = mxCalloc(1,sizeof(double));
    Y = mxCalloc(4,sizeof(double));
    ngrid = mxCalloc(1,sizeof(double));
    length = mxCalloc(1,sizeof(double));
    
    
    /*Declaration of the input parameters*/
    
    ngrid          =   mxGetPr(ngrid_IN);
    length         =   mxGetPr(length_IN);
    
    // Check for proper number of arguments
    
    if (!mxIsStruct(prhs[0])) mexErrMsgTxt("1st input argument of call.mex must be a structure (equil_fit)");
    if (nrhs != 5) mexErrMsgTxt("Wrong number of input arguments for raytracing_yp.mex");// The number of input arguments is fixed

    // Declaration of the structures
    
    rayparam_format rayparam;
    rayequil_format rayequil;
    equilparam_format equilparam;

    // Loading of the magnetic equilibrium
    
    rayequil.x_fit       = load_grid_2D(equil_IN,"x_fit",0);
    rayequil.y_fit       = load_grid_2D(equil_IN,"y_fit",0);
    rayparam             = load_ray_param(rayparam_IN);
    equilparam           = load_equil_param(equilparam_IN);

    // Scheme
    
    double dummy;
    int n = (int) ngrid[0];//Number of grid points
    data_OUT = mxCreateDoubleMatrix(1,3,mxREAL);
    data = mxGetPr(data_OUT);
    double *x0;
    double *y0;
    x0 = mxCalloc(1,sizeof(double));
    y0 = mxCalloc(1,sizeof(double));
    x0[0] = -length[0]/2;
    y0[0] = -length[0]/2;
    double N[n][n];
    double meand = 0;
    double dispd = 0;
    double dtd = 0;
    clock_t start,end;
    double cpu;
    int i,j,l;
    double a,b;
    meand = 0;
    dispd = 0;
    dtd = 0;

    for(i=0;i<n;i++)
    {
        for(j=0;j<n;j++)
        {
            a=x0[0];
            b=y0[0];
            Y[0]=x0[0];
            Y[1]=y0[0];
            start=clock();
            substitution_newton(rayequil,rayparam,equilparam,rho,theta,Y);
            end=clock();
            cpu = (end-start);
            cpu = cpu/CLOCKS_PER_SEC;
            ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho[0],theta[0],x0,&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
            ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho[0],theta[0],y0,&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
            x0[0] = x0[0]/equilparam.ap[0];
            y0[0] = y0[0]/equilparam.ap[0];
            N[i][j]=sqrt((a-x0[0])*(a-x0[0]) + (b-y0[0])*(b-y0[0]));
            meand = meand + N[i][j];
            dispd = dispd + N[i][j]*N[i][j];
            dtd = dtd + cpu;
            x0[0] = a + length[0]/(n-1);
            y0[0] = b;
        }
        x0[0] = -length[0]/2;
        y0[0] = b + length[0]/(n-1);
    }
    
    meand = meand/(n*n);
    dispd = dispd/(n*n);
    dtd = dtd/(n*n);
    dispd = sqrt(dispd - meand*meand);
    data[0] = meand;
    data[1] = dispd;
    data[2] = dtd;

    mxFree(Y);
    mxFree(rho);
    mxFree(theta);
    mxFree(x0);
    mxFree(y0);
    return;
}