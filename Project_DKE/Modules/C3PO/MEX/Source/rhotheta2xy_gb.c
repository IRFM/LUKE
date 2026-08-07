// /////////////////////////////////////////
//
// Software name : LUKE
//
// Authors : Yves Savoye-Peysson and Joan Decker
//
// Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
//
// CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
//
// The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
//
// /////////////////////////////////////////
//
/*
 rhotheta2xy_gb.c : MEX file giving out the corresponding cartesian couple from an input curvilinear couple
 
 INPUT:
 - Magnetic equilibrium                           : equil_IN
 - Ray parameters                                 : rayparam_IN
 - Equilibrium parameters                         : equilparam_IN
 - Radial coordinate                              : rho_IN
 - Poloidal coordinate                            : theta_IN
 
 OUTPUT:
 - Cartesian coordinate x : x_OUT
 - Cartesian coordinate y : y_OUT
 
 By Guillaume Brochard (CEA-DRFC, guillaume.brochard@cea.fr)
*/
#define DUMP(u) mexPrintf("%s = %e\n", #u, u)

#include <math.h>
#include "mex.h"
#include <complex.h>
#include "structures_raytracing_yp.h"
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
    x[0]=x[0]/equilparam.ap[0];
    y[0]=y[0]/equilparam.ap[0];
    return;
}