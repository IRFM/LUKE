#define DUMP(u) mexPrintf("%s = %e\n", #u, u)

#include <math.h>
#include "mex.h"
#include <complex.h>
#include "structures.h"
#include <time.h>

/*input arguments*/

#define	equil_IN      prhs[0]
#define rayparam_IN   prhs[1]
#define equilparam_IN prhs[2]
#define x_IN       prhs[3]
#define y_IN      prhs[4]

/*output arguments*/

#define rho_OUT       plhs[0]
#define theta_OUT     plhs[1]

void rho1D();
void substitution();

void rho1D(rayequil_format rayequil,rayparam_format rayparam, double *rho,double *theta,double *Y)
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
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],down[0],theta[0],&x,&dxdrho,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],down[0],theta[0],&y,&dydrho,&dummy,&dummy,&dummy);
        down[1] = dxdrho*(x-Y[0]) + dydrho*(y - Y[1]);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],res[0],theta[0],&x,&dxdrho,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],res[0],theta[0],&y,&dydrho,&dummy,&dummy,&dummy);
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

void substitution(rayequil_format rayequil,rayparam_format rayparam, double *rho,double *theta,double *Y)
{
    theta[0] = atan2(Y[1],Y[0]);
    double down_t[2],up_t[2],res_t[2];
    down_t[0] = theta[0]*0.9;
    up_t[0] = theta[0]*1.1;
    double dummy,x,y,dxdtheta,dydtheta,rho_d,rho_m;
    int k=0;
    res_t[1]=1;
    int kmax = 60;
    double prec = 1e-11;
    while(k < kmax && fabs(res_t[1]) > prec)
    {
        k = k + 1;
        res_t[0] = (down_t[0] + up_t[0])/2;
        rho1D(rayequil,rayparam,&rho_d,&down_t[0],Y);
        rho1D(rayequil,rayparam,&rho_m,&res_t[0],Y);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho_d,down_t[0],&x,&dummy,&dxdtheta,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho_d,down_t[0],&y,&dummy,&dydtheta,&dummy,&dummy);
        down_t[1] = dxdtheta*(x-Y[0]) + dydtheta*(y-Y[1]);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho_m,res_t[0],&x,&dummy,&dxdtheta,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho_m,res_t[0],&y,&dummy,&dydtheta,&dummy,&dummy);
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
    rho1D(rayequil,rayparam,rho,theta,Y);
}
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *x,*y,*rho,*theta,*Y;
    
    x = mxCalloc(1,sizeof(double));
    y = mxCalloc(1,sizeof(double));
    Y = mxCalloc(4,sizeof(double));
    
    /*Declaration of the input parameters*/
    
    x       =   mxGetPr(x_IN);
    y       =   mxGetPr(y_IN);
    
    /*Declaration of the output parameters*/
    
    rho_OUT = mxCreateDoubleScalar(mxREAL);
    theta_OUT = mxCreateDoubleScalar(mxREAL);
    rho = mxGetPr(rho_OUT);
    theta = mxGetPr(theta_OUT);
    
    
    // Declaration of the structures
    
    rayparam_format rayparam;
    rayequil_format rayequil;
    equilparam_format equilparam;
    
    // Loading of the magnetic equilibrium
    
    rayequil.x_fit       = load_grid_2D(equil_IN,"x_fit",0);
    rayequil.y_fit       = load_grid_2D(equil_IN,"y_fit",0);
    rayparam             = load_ray_param(rayparam_IN);
    equilparam           = load_equil_param(equilparam_IN);
    
    //Scheme
    Y[0]=x[0];
    Y[1]=y[0];
    substitution(rayequil,rayparam,rho,theta,Y);
    return;
}