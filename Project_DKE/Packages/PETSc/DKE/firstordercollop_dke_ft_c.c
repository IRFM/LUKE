#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Fokker-Planck_DKE_loop.h"


int firstordercollop_dke_ft_c2(struct Tensor f1,
struct Tensor betath_ref,
struct Tensor masku,struct Tensor maskl, 
struct Tensor dpn, 
struct Tensor xpn, struct Tensor xpn2, struct Tensor xpn3, struct Tensor xsigma, struct Tensor xgamma,
struct Tensor xz, struct Tensor xz2,
struct Tensor pn, struct Tensor pn2, struct Tensor pn3,  
struct Tensor sigma, struct Tensor gamma,
struct Tensor z, struct Tensor z2, 
struct Tensor xJ1, struct Tensor xJ2, struct Tensor xJ3, struct Tensor xJ4,
struct Tensor J1, struct Tensor J2, struct Tensor J3, struct Tensor J4,struct
Tensor xTe_norm,struct Tensor *I1,struct Tensor *I2)

{
/* printf("FIRSTORDERCOLLOP\n");*/
int i,j,sdim[2];
struct Tensor A;
struct Tensor B1,B2,B3,B5; /*A,B are intermediate tensor variables*/
struct Tensor xf1;


/*Creating xf1*/

if(f1.ndims !=2 && (f1.sizedim[0] !=1 || f1.sizedim[1]!=1)){fprintf(stdout,"error:f1 should be a vector");return -1;}
else if (f1.ndims ==2 && f1.sizedim[0] ==1){i=1;}
else if (f1.ndims ==2 && f1.sizedim[1] ==1){i=0;}


sdim[0]=f1.sizedim[i];
sdim[1]=f1.sizedim[i];
Tensor_Create(2,sdim,&xf1);
for(i=0;i<xf1.sizedim[0];i++){
   for(j=0;j<xf1.sizedim[1];j++){
xf1.vals[i+xf1.sizedim[0]*j]=f1.vals[i];/*ith line of xf1 == f1.vals[i]*/
 }
}

/*               */

/*Computing tensors products for I1*/

/*1st line*/

product(xf1,masku,&A);
product(xpn3,A,&A);/*A=xf1;*masku.*xpn3*/
division(A,xgamma,&B2);
integral_dke_jd(dpn,B2,1,&(*I1));
Scalar_Tensor_product(1/3.0,(*I1),&(*I1));
division((*I1),xTe_norm,&(*I1));/*Could rewrite xTe_norm as scalar and use
Scalar_Tensor_product instead*/

/*2nd line*/

integral_dke_jd(dpn,A,1,&B2);
product(gamma,B2,&B2);
Scalar_Tensor_product(2.0/3.0,B2,&B2);
division(B2,xTe_norm,&B2);
Tensor_Sum((*I1),B2,-1.0,&(*I1));

/*3rd line*/

product(A,xpn2,&B2);
division(B2,xgamma,&B2);
integral_dke_jd(dpn,B2,1,&B3);
product(B3,gamma,&B3);
Scalar_Tensor_product(1.0/5.0,B3,&B3);
division(B3,xTe_norm,&B3);
division(B3,xTe_norm,&B3);
Tensor_Sum((*I1),B3,1.0,&(*I1));

/*5th line*/

product(A,xJ2,&B2);
division(B2,xgamma,&B2);
division(B2,xz2,&B2);
integral_dke_jd(dpn,B2,1,&B3);
product(B3,gamma,&B3);
division(B3,xTe_norm,&B3);
Tensor_Sum((*I1),B3,-1.0,&(*I1));

/*6th line*/

struct Tensor B4;

Tensor_Create(xz2.ndims,xz2.sizedim, &B4);
for(i=0;i<B4.size;i++){B4.vals[i]=1.0+3.0/xz2.vals[i];}
product(xgamma,xsigma,&B3);
division(B3,xz2,&B3);
division(B3,xz,&B3);
Tensor_Sum(B4,B3,-3.0,&B3);
product(A,B3,&B3);
division(B3,xgamma,&B3);
integral_dke_jd(dpn,B3,1,&B2);
product(gamma,pn2,&B4);
for(i=0;i<B4.size;i++){B4.vals[i]=B4.vals[i]-5.0*xTe_norm.vals[0];}
product(B2,B4,&B2);
for(i=0;i<B2.size;i++){B2.vals[i]=B2.vals[i]/6.0;}
division(B2,xTe_norm,&B2);
division(B2,xTe_norm,&B2);
Tensor_Sum((*I1),B2,1.0,&(*I1));


/*7th line*/
/* fprintf(stdout,"line 7=======================\n");*/
product(A,xJ3,&B3);
division(B3,xz,&B3);
division(B3,xgamma,&B3);
integral_dke_jd(dpn,B3,1,&B2);
product(B2,gamma,&B2);
division(B2,betath_ref,&B2);
division(B2,xTe_norm,&B2);
division(B2,betath_ref,&B2);
division(B2,xTe_norm,&B2);
for(i=0;i<B2.size;i++){B2.vals[i]=B2.vals[i]/2.0;}
Tensor_Sum((*I1),B2,1.0,&(*I1));

/*8th line*/
/* fprintf(stdout,"line 8=======================\n");*/
product(A,xJ1,&B3);
division(B3,xz2,&B3);
division(B3,xgamma,&B3);
integral_dke_jd(dpn,B3,1,&B2);
product(B2,gamma,&B2);
division(B2,xTe_norm,&B2);
for(i=0;i<B2.size;i++){B2.vals[i]=B2.vals[i]/2.0;}
Tensor_Sum((*I1),B2,1.0,&(*I1));

/*10th line*/
/* fprintf(stdout,"line 10=======================\n");*/
product(A,xJ4,&B3);
division(B3,xz,&B3);
division(B3,xgamma,&B3);
integral_dke_jd(dpn,B3,1,&B2);
product(B2,gamma,&B2);
division(B2,xTe_norm,&B2);
division(B2,betath_ref,&B2);
division(B2,xTe_norm,&B2);
division(B2,betath_ref,&B2);
for(i=0;i<B2.size;i++){B2.vals[i]=B2.vals[i]/12.0;}
Tensor_Sum((*I1),B2,-1.0,&(*I1));

/*9th line*/

product(xf1,masku,&B3);
product(B3,xpn,&B3);
product(xgamma,xsigma,&B4);
division(B4,xz,&B4);
for(i=0;i<B4.size;i++){B4.vals[i]=B4.vals[i]-1.0;}
product(B3,B4,&B3);
division(B3,xgamma,&B3);
integral_dke_jd(dpn,B3,1,&B2);
product(B2,pn2,&B2);
division(B2,xTe_norm,&B2);
Tensor_Sum((*I1),B2,1.0,&(*I1));

/*4th line*/

division(xsigma,xz,&A);
Tensor_Sum(xgamma,A,-1.0,&A);
product(A,xpn,&A);
division(A,xgamma,&A);
product(A,masku,&A);
product(A,xf1,&A);
integral_dke_jd(dpn,A,1,&B2);
product(gamma,pn2,&B4);

Tensor_Sum((*I1),B2,1.0,&(*I1));

/*=========================================================================*/
/*Computing tensors products for I2*/

product(xf1,maskl,&A);

/*1st line*/

division(A,xgamma,&B3);
integral_dke_jd(dpn,B3,1,&B2);
Tensor_Create(B2.ndims, B2.sizedim, &(*I2));
Tensor_Fill(I2,0.0);
division(B2,xTe_norm,&B2);
for(i=0;i<B2.size;i++){B2.vals[i]=B2.vals[i]*1/3.0;}
Tensor_Sum((*I2),B2,1.0,&(*I2));

/*2nd line*/

integral_dke_jd(dpn,A,1,&B2);
division(gamma,xTe_norm,&B3);
for(i=0;i<B3.size;i++){B3.vals[i]=B3.vals[i]*(-2.0/3.0);}
division(pn2,xTe_norm,&B4);
division(B4,xTe_norm,&B4);
for(i=0;i<B4.size;i++){B4.vals[i]=B4.vals[i]*1/5.0;}
Tensor_Sum(B3,B4,1.0,&B3);
product(B2,B3,&B2);
Tensor_Sum((*I2),B2,1.0,&(*I2));


/*3rd line*/

division(A,xgamma,&B4);
integral_dke_jd(dpn,B4,1,&B3);
division(sigma,z,&B2);
Tensor_Sum(gamma,B2,-1.0,&B2);
division(B2,pn2,&B2);
product(B3,B2,&B2);
Tensor_Sum((*I2),B2,1.0,&(*I2));


/*4th line*/

integral_dke_jd(dpn,A,1,&B2);
product(J2,B2,&B2);
division(B2,z2,&B2);
division(B2,xTe_norm,&B2);
Tensor_Sum((*I2),B2,-1.0,&(*I2));


/*5th line*/

product(xgamma,xpn2,&B4);
for(i=0;i<B4.size;i++){B4.vals[i]=B4.vals[i]-5.0*xTe_norm.vals[0];}
product(A,B4,&B4);
division(B4,xgamma,&B4);
integral_dke_jd(dpn,B4,1,&B3);
product(gamma,sigma,&B2);
division(B2,z2,&B2);
division(B2,z,&B2);
for(i=0;i<B2.size;i++){B2.vals[i]=1.0+3.0/z2.vals[i]-3*B2.vals[i];}
division(B2,xTe_norm,&B2);
division(B2,xTe_norm,&B2);
 for(i=0;i<B2.size;i++){B2.vals[i]=B2.vals[i]/6.0;}
 product(B2,B3,&B2);
 Tensor_Sum((*I2),B2,1.0,&(*I2));


/*6th line*/

division(J3,z,&B4);
division(B4,betath_ref,&B4);division(B4,betath_ref,&B4);
division(B4,xTe_norm,&B4);division(B4,xTe_norm,&B4);
for(i=0;i<B4.size;i++){B4.vals[i]=B4.vals[i]/2.0;}
division(J1,z2,&B3);
division(B3,xTe_norm,&B3);
for(i=0;i<B3.size;i++){B3.vals[i]=B3.vals[i]/2.0;}
Tensor_Sum(B4,B3,1.0,&B3);
division(J4,z,&B4);
division(B4,betath_ref,&B4);division(B4,xTe_norm,&B4);
division(B4,betath_ref,&B4);division(B4,xTe_norm,&B4);
for(i=0;i<B4.size;i++){B4.vals[i]=B4.vals[i]/12.0;}
Tensor_Sum(B4,B3,-1.0,&B3);
integral_dke_jd(dpn,A,1,&B2);
product(B2,B3,&B2);
Tensor_Sum((*I2),B2,-1.0,&(*I2));/*smth wrong with the sign of B2;changed to -1*/

/*7th line*/

product(A,xpn2,&B3);
division(B3,xgamma,&B3);
integral_dke_jd(dpn,B3,1,&B2);
product(gamma,sigma,&B4);
division(B4,z,&B4);
for(i=0;i<B4.size;i++){B4.vals[i]=B4.vals[i]-1.0;}
division(B4,pn2,&B4);
division(B4,xTe_norm,&B4);
product(B2,B4,&B2);
Tensor_Sum((*I2),B2,1.0,&(*I2));

return 0;}
