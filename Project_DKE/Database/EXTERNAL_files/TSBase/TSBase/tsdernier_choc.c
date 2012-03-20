/* function dernier_choc=tsdernier_choc */
/* retourne le dernier choc si accessible sinon -1 */
/* ordre de compilation = cmex -g tsdernier_choc.c /usr/lib/libTS.a */
/* fonction ecrite par J-F Artaud, poste 4678, version 1, le 30/08/95 */
/* 15 septembre Matlab5 YB */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <signal.h>

#include "mex.h"
#include "tsdef.h"
#include "tsconf.h"
#include "tstype.h"
#if (client != MAC)
#include "tserreur.h"
#endif 

#if (client != PC )
char tslib_reel = 'd';
#endif

extern int Socket_save;

/* For CTRL C problems */
struct sigaction        newact, oldact;
        sigset_t         newmask, oldmask;

static void
sig_ctrlc(int sig)
{
  sigaction(SIGINT, &oldact, NULL);         /* reset previous action */
/*  sigprocmask(SIG_SETMASK, &oldmask, NULL);*/ /* reset signal mask */
  close(Socket_save);
  mexErrMsgTxt ("He pourquoi tant d'impatience  !!! ");
  return;
}
/* For CTRL C problems */


void 
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

	/* variable de la fonction getinfo */
    Longint	cr, num_choc;

   /* mxArray Variables */
   mxArray *dernierchoc;
          
   double  *dernierchoc_Pr;
           
   /* reservation de la memoire des variable de sortie */
 
   dernierchoc = mxCreateDoubleMatrix(1,  1, mxREAL);

	if (!dernierchoc) {
	     mexErrMsgTxt("erreur allocation memoire ");
	}


	/* For CTRL C problems */
	  newact.sa_handler = sig_ctrlc;
	  sigemptyset(&newact.sa_mask);
	  newact.sa_flags = 0;
	  sigaction(SIGINT, &newact, &oldact);
	
	  sigemptyset(&newmask);
	  sigaddset(&newmask, SIGINT);
	/* For CTRL C problems */


   /* Allocate Memory for temps */
   dernierchoc_Pr = mxGetPr(dernierchoc);
  
   cr=TSGetinfo(&num_choc);
   
   if (cr == 0){
   		*dernierchoc_Pr = (double) (num_choc);
   }else{
   		*dernierchoc_Pr = (double) (-1);
   }
   
  plhs[0] = dernierchoc;
   
  sigaction(SIGINT, &oldact, NULL);         /* reset previous action */ 
}
