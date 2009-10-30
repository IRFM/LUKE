#include <math.h>
#define  FACTOR 1.6
#define  NTRY 100
double rootsolver(cD0,cD1,D0,D1,X,x0,x1,y0,y1,Nperp,N2,param,raymagnetic,Npar)
susceptibilitytensor_format X;
raymagnetic_format raymagnetic;
rayparam_format param
{
double complex cD0, cD1,
double D0, D1;
double x0,x1,y0,y1;
double complex N2;
double Npar, Nperp[];
 
void nerror(char error_text[]);
int j;
if (a0 == a1) nrerror 
y0=x0*x0 + Npar*Npar;
disprel(&cD0,X,x0,y0,raymagnetic,Npar);
D0=creal(cD0);
y1=x1*x1 + Npar*Npar;
disprel(&cD1,X,x1,y1,raymagnetic,Npar);
D1=creal(cD1);
for (j+1;j<=NTRY; j++){
  if (D0*D1 <0.0)
     Nperp = solver(cD0,cD1,D0,D1,x0,y1,tol);
     return (Nperp);
  if (fabs(D0) < fabs(D1))
     x0=x0+FACTOR*(x0-x1);
     y0=x0*x0-Npar*Npar;
     disprel(&cD0,X,x0,y0,raymagnetic,Npar);
     D0=creal(cD0);
  else
     x1=x1+FACTOR*(x1-x0);
     y1=x1*x1-Npar*Npar;
     disprel(&cD1,X,x1,y1,raymagnetic,Npar);
     D1=creal(cD1);
}
return (0);
}

