/* @(#)ifloor1.c	1.4	J.-M. Moret MatLab Toolbox	8/29/90 */

/*
 * for mex-file ifloor1.mex
 *
 * K = ifloor1(X,X0) will return the indices in vector X of the nearest but
 * smaller value in X0.
 *
 * 16.02.90	creation		JMM
 * Adaptation pour cmex 4.1   R.Masset  le 6/10/93 
 */

#include <mex.h>

/* routine user_fcn obligatoire pour creer le mex-file : nbwrite.mexds.
nin arguments d'entree et nout arguments de sortie.
pin : tableau des nin pointeurs des arguments d'entree.
pout : tableau des nout pointeurs des arguments de sortie. */

void mexFunction(int nout,mxArray *pout[],int nin,const mxArray *pin[])

{
	int		sizeX,sizeX0;
	double		*X = (double*)0; /* will also contain K */
	double		*X0 = (double*)0,*X1;

	register int	i,j;

        if(nin<2)mexErrMsgTxt("ifloor1: il faut 2 arguments d entree!");
        if(nout>1)mexErrMsgTxt("ifloor1: 1 seul argument de sortie!");

	/* load X */

        X=mxGetPr(pin[0]);
        sizeX=mxGetM(pin[0])*mxGetN(pin[0]);
        X0=mxGetPr(pin[1]);
        sizeX0=mxGetM(pin[1])*mxGetN(pin[1]);

        /* Creation de la matrice de sortie */
        pout[0]=mxCreateDoubleMatrix(sizeX0,1,mxREAL);
        X1=mxGetPr(pout[0]);

	/* treatment */

	j=0L;
	for (i=0L;i<sizeX0;i++){
		if(X0[i]<X[0])X1[i]=0;else break;
	}
	for (;i<sizeX0;i++){
		for (;j<sizeX-1;j++){
			if (X0[i] >= X[j] && X0[i] < X[j+1L]) {
				X1[i] = (double)(j+1L);
				break;
			}
		}
                if ( X0[i] >= X[sizeX-1])X1[i]=(double)sizeX;
	}
}
