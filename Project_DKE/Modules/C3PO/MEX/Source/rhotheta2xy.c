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
#define rho_IN       prhs[3]
#define theta_IN      prhs[4]

/*output arguments*/

#define x_OUT       plhs[0]
#define y_OUT     plhs[1]

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *x,*y,*rho,*theta;
    
    rho = mxCalloc(1,sizeof(double));
    theta = mxCalloc(1,sizeof(double));
    
    /*Declaration of the input parameters*/
    
    rho         =   mxGetPr(rho_IN);
    theta       =   mxGetPr(theta_IN);

    
    /*Declaration of the output parameters*/
    
    x_OUT = mxCreateDoubleScalar(mxREAL);
    y_OUT = mxCreateDoubleScalar(mxREAL);
    x = mxGetPr(x_OUT);
    y = mxGetPr(y_OUT);
    
    
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
    
    double a,b,dummy;
    ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho[0],theta[0],x,&dummy,&dummy,&dummy,&dummy);//Gives out x
    ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho[0],theta[0],y,&dummy,&dummy,&dummy,&dummy);//Gives out y
    return;
}