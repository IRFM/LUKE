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
 rhotheta2xy_gb.c : MEX file giving out the corresponding curvilinear couple from an input cartesian couple
 
 INPUT:
 - Magnetic equilibrium                           : equil_IN
 - Ray parameters                                 : rayparam_IN
 - Equilibrium parameters                         : equilparam_IN
 - Cartesian coordinate x                         : x_IN
 - Cartesian coordinate y                         : y_IN
 
 OUTPUT:
 - Radial coordinate   : rho_OUT
 - Poloidal coordinate : theta_OUT
 
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
#define x_IN       prhs[3]
#define y_IN      prhs[4]

/*output arguments*/

#define rho_OUT       plhs[0]
#define theta_OUT     plhs[1]

void rho1D_dichotomy();
void rho1D_newton_numeric();
void rho1D_newton_analytic();
void substitution_dichotomy_2D();
void substitution_newton_numeric_2D();
void substitution_newton_analytic_2D();

void rho1D_dichotomy(rayequil_format rayequil,rayparam_format rayparam, equilparam_format equilparam, double *rho,double *theta,double *Y)
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
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],down[0],theta[0],&x,&dxdrho,&dummy,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],down[0],theta[0],&y,&dydrho,&dummy,&dummy,&dummy,&dummy);
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdrho=dxdrho/equilparam.ap[0];//Mandatory normalization
        dydrho=dydrho/equilparam.ap[0];//Mandatory normalization
        down[1] = dxdrho*(x-Y[0]) + dydrho*(y - Y[1]);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],res[0],theta[0],&x,&dxdrho,&dummy,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],res[0],theta[0],&y,&dydrho,&dummy,&dummy,&dummy,&dummy);
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

void rho1D_newton_numeric(rayequil_format rayequil,rayparam_format rayparam, equilparam_format equilparam, double *rho,double *theta,double *Y)
{
    double down[2],res[2];
    down[0]=0.05;
    res[0]=0.050000001;
    double dummy,x,y,dxdrho,dydrho;
    int k = 0;
    res[1]=1;
    int kmax = 10;
    double prec = 1e-9;
    double save;
    while(k < kmax && fabs(res[1]) > prec)
    {
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],down[0],theta[0],&x,&dxdrho,&dummy,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],down[0],theta[0],&y,&dydrho,&dummy,&dummy,&dummy,&dummy);
        
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdrho=dxdrho/equilparam.ap[0];//Mandatory normalization
        dydrho=dydrho/equilparam.ap[0];//Mandatory normalization
        
        down[1] = dxdrho*(x-Y[0]) + dydrho*(y - Y[1]);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],res[0],theta[0],&x,&dxdrho,&dummy,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],res[0],theta[0],&y,&dydrho,&dummy,&dummy,&dummy,&dummy);
        
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdrho=dxdrho/equilparam.ap[0];//Mandatory normalization
        dydrho=dydrho/equilparam.ap[0];//Mandatory normalization
        
        res[1] = dxdrho*(x-Y[0]) + dydrho*(y - Y[1]);
        
        
        save = res[0];
        res[0] = res[0] - res[1]*((res[0] - down[0])/(res[1] - down[1]));
        down[0] = save;
        down[1] = res[1];
        
        k = k +1;
    }
    rho[0]=res[0];
}

void rho1D_newton_analytic(rayequil_format rayequil,rayparam_format rayparam, equilparam_format equilparam, double *rho,double *theta,double *Y)
{
    double res[3];

    res[0]=0.05;/*res[0]=rho, res[1] = d(distance^2/2)/drho, res[2]= d2(distance^2/2)drho2*/
    double dummy,x,y,dxdrho,dydrho,d2xdrho2,d2ydrho2;
    int k = 0;
    res[1]=1;
    int kmax = 10;
    double prec = 1e-9;
    while(k < kmax && fabs(res[1]) > prec)
    {
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],res[0],theta[0],&x,&dxdrho,&dummy,&dummy,&dummy,&d2xdrho2);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],res[0],theta[0],&y,&dydrho,&dummy,&dummy,&dummy,&d2ydrho2);
        
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdrho=dxdrho/equilparam.ap[0];//Mandatory normalization
        dydrho=dydrho/equilparam.ap[0];//Mandatory normalization
        d2xdrho2=d2xdrho2/equilparam.ap[0];//Mandatory normalization
        d2ydrho2=d2ydrho2/equilparam.ap[0];//Mandatory normalization
        
        res[1] = dxdrho*(x-Y[0]) + dydrho*(y - Y[1]);
        
        res[2] = d2xdrho2*(x-Y[0]) + d2ydrho2*(y - Y[1]) + pow(dxdrho,2) + pow(dydrho,2);
        
        res[0] = res[0] - res[1]/res[2];
        
        k = k + 1;
    }
    rho[0]=res[0];
    mexPrintf("%d\n",k);
}

void substitution_dichotomy_2D(rayequil_format rayequil,rayparam_format rayparam, equilparam_format equilparam, double *rho,double *theta,double *Y)
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
        rho1D_dichotomy(rayequil,rayparam,equilparam,&rho_d,&down_t[0],Y);
        rho1D_dichotomy(rayequil,rayparam,equilparam,&rho_m,&res_t[0],Y);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho_d,down_t[0],&x,&dummy,&dxdtheta,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho_d,down_t[0],&y,&dummy,&dydtheta,&dummy,&dummy,&dummy);
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdtheta=dxdtheta/equilparam.ap[0];//Mandatory normalization
        dydtheta=dydtheta/equilparam.ap[0];//Mandatory normalization
        down_t[1] = dxdtheta*(x-Y[0]) + dydtheta*(y-Y[1]);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho_m,res_t[0],&x,&dummy,&dxdtheta,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho_m,res_t[0],&y,&dummy,&dydtheta,&dummy,&dummy,&dummy);
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
    rho1D_dichotomy(rayequil,rayparam,equilparam,rho,theta,Y);
}

void substitution_newton_numeric_2D(rayequil_format rayequil,rayparam_format rayparam, equilparam_format equilparam, double *rho,double *theta,double *Y)
{
    theta[0] = atan2(Y[1],Y[0]);
    double down_t[2],res_t[2];
    down_t[0] = theta[0];
    res_t[0] = 1.00000001*down_t[0];
    double dummy,x,y,dxdtheta,dydtheta,rho_d,rho_m;
    int kt=0;
    int ktmax = 15;
    double prec = 1e-9;
    res_t[1] = 1;
    double save;
    
    rho1D_newton_analytic(rayequil,rayparam,equilparam,&rho_d,&down_t[0],Y);
    ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho_d,down_t[0],&x,&dummy,&dxdtheta,&dummy,&dummy,&dummy);
    ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho_d,down_t[0],&y,&dummy,&dydtheta,&dummy,&dummy,&dummy);
    x=x/equilparam.ap[0];//Mandatory normalization
    y=y/equilparam.ap[0];//Mandatory normalization
    dxdtheta=dxdtheta/equilparam.ap[0];//Mandatory normalization
    dydtheta=dydtheta/equilparam.ap[0];//Mandatory normalization
    down_t[1] = dxdtheta*(x-Y[0]) + dydtheta*(y-Y[1]);
    
    while(kt < ktmax && fabs(res_t[1]) > prec)
    {
        rho1D_newton_analytic(rayequil,rayparam,equilparam,&rho_m,&res_t[0],Y);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho_m,res_t[0],&x,&dummy,&dxdtheta,&dummy,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho_m,res_t[0],&y,&dummy,&dydtheta,&dummy,&dummy,&dummy);
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdtheta=dxdtheta/equilparam.ap[0];//Mandatory normalization
        dydtheta=dydtheta/equilparam.ap[0];//Mandatory normalization
        
        res_t[1] = dxdtheta*(x-Y[0]) + dydtheta*(y-Y[1]);
        
        save = res_t[0];
        res_t[0] = res_t[0] - res_t[1]*((res_t[0] - down_t[0])/(res_t[1] - down_t[1]));
        down_t[0] = save;
        down_t[1] = res_t[1];
        
        DUMP(res_t[0]);
        
        kt = kt + 1;
        
    }
    theta[0] = res_t[0];
    rho1D_newton_analytic(rayequil,rayparam,equilparam,rho,theta,Y);
}


void substitution_newton_analytic_2D(rayequil_format rayequil,rayparam_format rayparam, equilparam_format equilparam, double *rho,double *theta,double *Y)
{
    theta[0] = atan2(Y[1],Y[0]);
    double res_t[3];//res_t[0]=theta, res_t[1]=d(distance^2/2)dtheta, res_t[2]=d2(distance^2/2)dtheta2
    res_t[0] = theta[0];
    double dummy,x,y,dxdtheta,dydtheta,d2xdtheta2,d2ydtheta2,rho_s;
    int kt=0;
    int ktmax = 15;
    double prec = 1e-9;
    res_t[1] = 1;
    while(kt < ktmax && fabs(res_t[1]) > prec)
    {
        rho1D_newton_analytic(rayequil,rayparam,equilparam,&rho_s,&res_t[0],Y);
        
        ppvald_2D(rayequil.x_fit,rayparam.dS[0],rho_s,res_t[0],&x,&dummy,&dxdtheta,&d2xdtheta2,&dummy,&dummy);
        ppvald_2D(rayequil.y_fit,rayparam.dS[0],rho_s,res_t[0],&y,&dummy,&dydtheta,&d2ydtheta2,&dummy,&dummy);
        
        x=x/equilparam.ap[0];//Mandatory normalization
        y=y/equilparam.ap[0];//Mandatory normalization
        dxdtheta=dxdtheta/equilparam.ap[0];//Mandatory normalization
        dydtheta=dydtheta/equilparam.ap[0];//Mandatory normalization
        d2xdtheta2=d2xdtheta2/equilparam.ap[0];//Mandatory normalization
        d2ydtheta2=d2ydtheta2/equilparam.ap[0];//Mandatory normalization
        
        res_t[1] = dxdtheta*(x-Y[0]) + dydtheta*(y-Y[1]);
        
        res_t[2] = d2xdtheta2*(x-Y[0]) + d2ydtheta2*(y-Y[1]) + pow(dxdtheta,2) + pow(dydtheta,2);
        
        res_t[0] = res_t[0] - res_t[1]/res_t[2];
        
        DUMP(res_t[0]);
        
        kt = kt + 1;
        
    }
    theta[0] = res_t[0];
    rho1D_newton_analytic(rayequil,rayparam,equilparam,rho,theta,Y);
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
    
    substitution_newton_analytic_2D(rayequil,rayparam,equilparam,rho,theta,Y);

    return;
}