/*		.....	tsdate.c   .....		*/
/*		.....	  YB	   .....		*/
/*	.....  Interface MATLAB TSLIB Yeah  .....	*/
/*	Matlab 4  19 juillet 1994			*/
/*	Matlab 5  15 septembre 1997			*/
/*							*/
#include <stdio.h>
#include <stdlib.h>
#include "mex.h"
#include "tsconf.h"
#include "tsdef.h"
#include "tstype.h"
#include "tsbamat.h"
#include "tserreur.h"

static char rcsid[] = "$Id$";

#if (client != PC )
char            tslib_reel = 'd';
#endif
void meser (char *, char *, Longint, Longint);

mxArray         *
charMat(Longint m, Longint n, char *liste)
    {
    int             i, j;
    mxArray         *mat;
    char           *chaine;

    chaine = (char *) mxCalloc(m * n + 1, sizeof(char));
    for (i = 0; i < m; i++)
        {
        for (j = 0; j < n; j++)
            chaine[i + j * m] = liste[i * n + j];
        }
    chaine[1 + m * n] = '\0';
    mat = mxCreateString(chaine);
    mxSetM(mat, m);
    mxSetN(mat, n - 1);
    mxFree(chaine);
    return (mat);
    }


void
mexFunction(int nout, mxArray * pout[], int nin, const mxArray * pin[])
{

  short i;
  Double *pr;
  Longint numchoc;
  char date[TAILLE_DATE], heure[TAILLE_HEURE];
  Longint cr, numv, certif[MAX_CERTIF];
  Longint nbcoord[MAX_COORD];
  pS_Entree ptEntree;

  if (nin != 1)
    {
      pout[0] = mxCreateDoubleMatrix (0, 0, mxREAL);
      pout[1] = mxCreateDoubleMatrix (0, 0, mxREAL);
      mexPrintf ("SVP donnez un numero de choc\n");
    }
  else
    {
      pr = mxGetPr(pin[0]);
      numchoc = (Longint) pr[0];

      ptEntree = (pS_Entree) malloc (sizeof (struct S_Entree));
      ptEntree->union_var.lval = numchoc;
      ptEntree->ps_suivant = NULL;

      for (i = 0; i < MAX_COORD; i++)
	nbcoord[i] = 0;
      cr = TSExist ("num_choc", ptEntree, nbcoord, &numv, certif, date, heure);
      if (cr)
	{
	  pout[0] = mxCreateDoubleMatrix (0, 0, mxREAL);
	  pout[1] = mxCreateDoubleMatrix (0, 0, mxREAL);
	  meser ("TSExist - ", "num_choc",cr, NONFATAL);
	  free (ptEntree);
	}
      else
	{
         pout[0] = charMat((Longint) 1, (Longint)TAILLE_DATE, date);
         pout[1] = charMat((Longint) 1, (Longint)TAILLE_HEURE, heure);
	 free (ptEntree);
	}
    }
}

void
meser (char *mes1, char *mes2, Longint numer, Longint code)
{
  printf ("tsdate : %s%s :", mes1, mes2);
  numer--;

  if (numer < 1000)
    {
      if (numer > 98)
	numer = numer - 49;
      printf (" %s\n", err_tslib[numer]);
    }
  else
    {
      if (numer > ERR_MAX)
	{
	  printf (" Erreur TSLIB (bug?) %d\n", numer);
            mexErrMsgTxt ("Oops Pecaire ... a ben-leu");
	}
      printf (" %s\n", err_tsmat[numer - 1000]);
    }
  if (code == FATAL)
    mexErrMsgTxt ("Oops Pecaire ... a ben-leu");
}


