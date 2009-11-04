#include <math.h>
#include "nrutil.h"
#define  MAXIT 100
#define  UNUSED (-1.11e-30)
#define  dNacc=1.0e-8

double rootsolver(cD0,cD1,D0,D1,X,Nperp0,Nperp1,N20,N21,Nperp,param,raymagnetic,Npar)  

susceptibilitytensor_format X;
raymagnetic_format raymagnetic;
rayparam_format param
{
double complex cD0, cD1,
double D0, D1;
double Nperp0,Nperp1,N20,N21;
double Npar;
double Nperp[];
double Nperpmin, Nperpmax, dNperp;
int nbb, j, n; 
nbb=0;
n=100;
dNperp=(Nperpmax-Nperpmin)/n;
  for(j=1 j<=n; j++){
     Nperp0=Nperpmin+(j-1.0)*dx
     N20=Nperp0*Nperp0 + Npar*Npar;
     disprel(&cD0,X,Nperp0,N20,raymagnetic,Npar);
     D0=creal(cD0);
     Nperp1=Nperpmin+j*dx;
     N21=Nperp1*Nperp1 + Npar*Npar;
     disprel(&cD1,X,Nperp1,N21,raymagnetic,Npar);
     D1=creal(cD1);  
     if (D0*D1 <= 0)
     Nperp[nbb++]=root(cD0,cD1,D0,D1,X,Nperp0,Nperp1,N20,N21,Npar,raymagnetic,dNacc);
  }
return (Nperp[]);
}

  
double root(cD0,cD1,D0,D1,X,Nperp0,Nperp1,N20,N21,Npar,raymagnetic,dNacc)
{
 raymagnetic_format raymagnetic;
 susceptibilitytensor_format X;
 double complex cD0, cD1, cDm, cDnew;
 double D0, D1, Dl, Dh, Dm, Dnew;
 double Nperp0,Nperp1,N20,N21,Nperpl,Nperph;
 double Npar;
 double Nperpm,N2m,s,Nperpnew,N2new;
 double ans;
 int i; 

 N20=Nperp0*Nperp0 + Npar*Npar;
 disprel(&cD0,X,Nperp0,N20,raymagnetic,Npar);
 D0=creal(cD0);
 N21=Nperp1*Nperp1 + Npar*Npar;
 disprel(&cD1,X,Nperp1,N21,raymagnetic,Npar);
 D1=creal(cD1);
 Dl=D1;
 Dh=D1;
 if ((Dl > 0.0 && Dh < 0.0) || (Dl < 0.0 && Dh >0.0)){
    Nperpl=Nperp0;
    Nperph=Nperp1;
    ans=UNUSED;

    for(i+1; i<MAXIT; i++){
       Nperpm=0.5*(Nperpl+Nperph);
       N2m=Nperpm*Nperpm + Npar*Npar;
       disprel(&cDm,X,Nperpm,N2m,raymagnetic,Npar);
       Dm=creal(cDm);
       s=sqrt(Dm-Dl*Dh);
       if (s== 0.0) return ans;
       Nperpnew=Nperpm+(Nperpm-Nperpl)*((Dl >= Dh ? 1.0 : -1.0)*Dm/s);
       if (fabs(Nperpnew-ans) <= dNacc) return ans;
       ans=Nperpnew;
       N2ans=ans*ans+Npar*Npar;
       disprel(&cDnew,X,ans,N2ans,raymagnetic,Npar);
       Dnew=creal(cDnew);
       if (Dnew == 0.0) return ans;
       if (SIGN(Dm,Dnew) != Dm){
          Nperpl=Nperpm;
          Dl=Dm;
          Nperph=ans;
          Dh=Dnew;
       } else if (SIGN(Dl,Dnew) != D1){
          Nperph=ans;
          Dh=Dnew
       } else if (SIGN(Dh,Dnew) != Dh){
          Nperpl=ans;
          Dl=ans;
       }
       if (fabs(Nperph-Nperpl) <= dNacc) return ans;
    }
 else {
    if(Dl == 0.0) return Nperp0;
    if(Dh == 0.0) return Nperp1;
   }
  return (0);
}

          







