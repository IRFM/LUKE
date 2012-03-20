/* @(#)iround.c	 1.4	J.-M. Moret MatLab Toolbox	8/29/90 */

/*
 * for mex-file iround.mex
 *
 * K = iround(X,X0) will return the indices in vector X of the nearest
 * value in X0.
 *
 * 07.03.90	creation		JMM
 * Adaptation pour cmex 4.1   R.Masset  le 6/10/93 
 */

#include <mex.h>
# include <math.h>

/* routine user_fcn obligatoire pour creer le mex-file : nbwrite.mexds.
nin arguments d'entree et nout arguments de sortie.
pin : tableau des nin pointeurs des arguments d'entree.
pout : tableau des nout pointeurs des arguments de sortie. */

void mexFunction(int nout, mxArray *pout[], int nin, const mxArray *pin[])

{
int	sizeX,sizeX0;
double	*X = (double*)0;
double	*X0 = (double*)0;
double	*K = (double*)0;

register int	i,j,ix;
register double	x,y;

if (nin<2)  mexErrMsgTxt("iround: il faut 2 arguments d entree !");
if (nout>1) mexErrMsgTxt("iround: 1 seul argument de sortie !");

/* Rearrangement de X */ 
/*mexCallMATLAB(1,&pin[0],1,&pin[0],"sort");
mexCallMATLAB(1,&pin[1],1,&pin[1],"sort");*/

X=mxGetPr(pin[0]);
sizeX=mxGetM(pin[0])*mxGetN(pin[0]);
X0=mxGetPr(pin[1]);
sizeX0=mxGetM(pin[1])*mxGetN(pin[1]);

/* Creation de la matrice de sortie */
pout[0]=mxCreateDoubleMatrix(sizeX0,1,mxREAL);
K=mxGetPr(pout[0]);

/* traitement */
ix = 0L;
/* Pour chaque valeur de X0 */
for (i=0;i<sizeX0;i++)
 {
  x = fabs(X0[i]-X[ix]);
/* Pour chaque valeur de X */
  for (j=ix+1;j<sizeX;j++)
   {
    y = fabs(X0[i]-X[j]);
    if (y < x)
     {
      x = y;
      ix = j;
     }
    else
     {
      break;
     }
   }
  K[i] = (double)(ix+1L);
 }
}
