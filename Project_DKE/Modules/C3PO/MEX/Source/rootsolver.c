#include <math.h>
#include "nrutil.h"
#define  MAXIT 100
#define  UNUSED -1.11e-30
#define  xacc=1.0e-8

double rootsolver(cD0,cD1,D0,D1,X,x0,x1,y0,y1,Nperp,N2,param,raymagnetic,Npar)  

susceptibilitytensor_format X;
raymagnetic_format raymagnetic;
rayparam_format param
{
double complex cD0, cD1,
double D0, D1;
double x0,x1,y0,y1;
double complex N2;
double Npar;
double Nperp[];
int nbb, j, n; 
nbb=0;
n=1000;
dx=(xmax-xmin)/n;
  for(j=1 j<=n; j++){
     x0=xmin+(j-1)*dx
     y0=x0*x0 + Npar*Npar;
     disprel(&cD0,X,x0,y0,raymagnetic,Npar);
     D0=creal(cD0);
     x1=xmin+j*dx;
     y1=x1*x1 + Npar*Npar;
     disprel(&cD1,X,x1,y1,raymagnetic,Npar);
     D1=creal(cD1);  
     if (D0*D1 <= 0)
     Nperp[nbb++]=solver(cD0,cD1,D0,D1,X,x0,x1,y0,y1,Npar,raymagnetic,xacc);
  }
return (Nperp[]);
}

  
double solver(cD0,cD1,D0,D1,X,x0,x1,y0,y1,Npar,raymagnetic,xacc)
{
 raymagnetic_format raymagnetic;
 susceptibilitytensor_format X;
 double complex cD0, cD1, cDm, cDnew;
 double D0, D1, Dl, Dh, Dm, Dnew;
 double x0,x1,y0,y1,xl,xh;
 double complex N2;
 double Npar;
 double xm,ym,s,xnew,ynew;
 double ans;
 int i; 

 y0=x0*x0 + Npar*Npar;
 disprel(&cD0,X,x0,y0,raymagnetic,Npar);
 D0=creal(cD0);
 y1=x1*x1 + Npar*Npar;
 disprel(&cD1,X,x1,y1,raymagnetic,Npar);
 D1=creal(cD1);
 Dl=D1;
 Dh=D1;
 if ((Dl > 0.0 && Dh < 0.0) || (Dl < 0.0 && Dh >0.0)){
    xl=x0;
    xh=x1;
    ans=UNUSED;

    for(i+1; i<MAXIT; i++){
       xm=0.5*(xl+xh);
       ym=xm*xm + Npar*Npar;
       disprel(&cDm,X,xm,ym,raymagnetic,Npar);
       Dm=creal(cDm);
       s=sqrt(Dm-Dl*Dh);
       if (s== 0.0) return ans;
       xnew=xm+(xm-xl)*((Dl >= Dh ? 1.0 : -1.0)*Dm/s);
       if (fabs(xnew-ans) <= xacc) return ans;
       ans=xnew;
       Nans=ans*ans+Npar*Npar;
       disprel(&cDnew,X,ans,Nans,raymagnetic,Npar);
       Dnew=creal(cDnew);
       if (Dnew == 0.0) return ans;
       if (SIGN(Dm,Dnew) != Dm){
          xl=xm;
          Dl=Dm;
          xh=ans;
          Dh=Dnew;
       } else if (SIGN(Dl,Dnew) != D1){
          xh=ans;
          Dh=Dnew
       } else if (SIGN(Dh,Dnew) != Dh){
          xl=ans;
          Dl=ans;
       }
       if (fabs(xh-xl) <= xacc) return ans;
    }
 else {
    if(Dl == 0.0) return x0;
    if(Dh == 0.0) return x1;
   }
  return (0);
}

          







