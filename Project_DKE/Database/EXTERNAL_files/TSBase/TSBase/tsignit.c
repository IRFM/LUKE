/*-----------------------------------*/
/* tsignitron.c                    */
/*-----------------------------------*/

#include <stdio.h>
#include <float.h>
#include "tsdef.h"
#include "tsconf.h"
#include "tstype.h"
#include "functs.h"	/* declaration de toutes les fonctions TSLib */
#include "tsbamat.h"
#include "mex.h"

#define NB_MESURES      2

static char     rcsid[] = "$Id$";


Longint
tsignitron (Longint *numchoc)
    {
    Longint   cr, it0 = 0;
    Longint   extract = 1, nbmes, maxreel, numver;
    Longint   certif[64];
    Double    X[2], Y[2];
    char      date[TAILLE_DATE];
    char      heure[TAILLE_HEURE];
    pS_Entree psentree;
    pS_Unite  psunite;
    Longint   rang[2];
    Longint   ignit = 0;

    rang[0]=1;
    rang[1]=1;

    psentree = (pS_Entree) mxCalloc (1, sizeof (struct S_Entree));
    psentree->union_var.lval = *numchoc;
    psentree->ps_suivant = NULL;

    cr = TSRSigRg ("RIGNITRON", psentree, rang, NB_MESURES, extract, &psunite,
                   &numver, certif, date, heure, &nbmes, &maxreel,
                   (char *) X, (char *) Y);

#ifdef DEBUG
  mexPrintf("tsignit.c : apres lecture RIGNITRON cr = %d %g \n",cr, X[0]);
#endif
    if (!cr){
        ignit = 1.0e6 * X[0];
	return (ignit);
    }
    else
	return (-1);
    }

