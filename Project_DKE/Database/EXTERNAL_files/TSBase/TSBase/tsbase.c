/* 		.....   tsbase.c   .....                	*/
/* 		.....     YB       .....                	*/
/* 	..... from an original work of B.Saoutic  ..... 	*/
/* 	... version for Matlab 4.0 by me (July 93) ....		*/
/*       .....  Interface MATLABV4.0  TSLIB Yeah  .....		*/
/*								*/
/*.....  Modifications :					*/
/*        21/07/94:fixed toupper function for character between	*/
/*                 97 and 122 (a-z)        			*/
/*        26/04/95 : modif charMat version 2.0b.1   (mxSetN)    */
/*        16/10/95 : modif relative_time version 2.0b.2         */
/*                   Extract = 2 quand on met l'option E        */
/*        12/09/97  Working for Matlab5                         */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <ctype.h>
#include <math.h>

#include "mex.h"
#include "tsdef.h"
#include "tsconf.h"
#include "tstype.h"
//#if (client != MAC)
#include "tserreur.h"
//#endif
#include "functs.h"		/* prototype des fonctions de TSLib */
#include "tsbamat.h"
#include "newarg.h"

static char banner[] = "tsbase V2.6";

#if (client != PC )
char tslib_reel = 'd';
#endif

/* For CTRL C problems */
struct sigaction  newact, oldact;
       sigset_t   newmask, oldmask;
extern int Socket_save;

static void
sig_ctrlc(int signal)
{
  sigaction(SIGINT, &oldact, NULL);         /* reset previous action */
/*  sigprocmask(SIG_SETMASK, &oldmask, NULL);*/ /* reset signal mask */
  shutdown(Socket_save,0);
  close(Socket_save);
  mexErrMsgTxt ("He pourquoi tant d'impatience  !!! ");
}
/* For CTRL C problems */

#undef toupper
int 
toupper (c)
     int c;
{
  int adel;
  if ((c > 96) && (c < 123))
    adel = c - 'a' + 'A';
  else
    adel = c;

  return (adel);
}

int l_rang ;	  /* lecture rang par defaut */         /** +++  **/
int nb_extr2; /* nbre mesures quand extract = 2 */  /** +++  **/
int extraction, np_specif ;
int num;
int nouttemp;
Longint extract = 1;
Longint type, it0, absolute ;

Longint lit_traite (char *, Longint, Longint, mxArray *[], int, Longint[], Double[]);  /* +++ */
void meser (char *, char *, Longint, Longint);
void meserRDC (char *, char *, Longint, Longint);
void FreeMemM (void *);
int Strncmp (char *, char *s, int);
extern Longint tsignitron (Longint *);
extern Longint tsparse (char *, char *, Longint *, Longint *, Longint *);

/********* New for ARCAD ************/
#define L_FORMAT                5 
#define L_UNITE                 13 
typedef struct zs_donnee_ {
        Longint id_objet;
        short   numero;
        Longint id_donnee;
        short   confidentialite;
        Longint type_donnee;
        short   nb_composantes;
        short   nb_coordonnees;
        char    formatx[L_FORMAT];
        char    formaty[L_FORMAT];
        char    formati[L_FORMAT];
        char    formatj[L_FORMAT];
        char    unitex[L_UNITE];
        char    unitey[L_UNITE];
        char    unitei[L_UNITE];
        char    unitej[L_UNITE];
        short   structx;
        short   structy;
        short   structi;
        short   structj;
        short   longueuri;
        short   longueurj;
        short   maxtrame;
        short   remdif;
  } ts_donnee;
/********* New for ARCAD ************/


#if (client == MAC )
//extern char *err_tslib[100];
//extern char *err_tsmat[20];
//extern char *err_rqlib[10];
/*
extern void Init_err_tslib(void);
extern void Init_err_tsmat(void);
extern void Init_err_rqlib(void);
#define ERR_MAX 1014L
*/
#endif

mxArray *
emptyMat (void)
{
  mxArray *psort;
  psort = mxCreateDoubleMatrix (0, 0, mxREAL);
  return psort;
}


mxArray *
charMat (Longint m, Longint n, char *liste)
{
  int i, j, gN;
  mxArray *mat;
  char *chaine;
  chaine = (char *) mxCalloc (m * n + 1 , sizeof (char));
  for (i = 0; i < m; i++)
    {
      for (j = 0; j < n; j++) 
	chaine[i + j * m] = liste[i * n + j];
    }
  chaine[m * n] = '\0';
  mat = mxCreateString (chaine);
  gN = mxGetN(mat) ;
  mxSetN (mat, (gN >= n) ? n : gN);
  mxSetM (mat, m);
  mxFree (chaine);
  return (mat);
}

Longint
relative_time ( const mxArray ** pin, int *argin, Longint numchoc, Longint * absolute, Longint rangs[], Double xab[])	/** +++  **/

{
  Longint lg, j;
  char *buf;
/** +++ **/
  short flagTN = 0, flagE = 0, SyntaxeOK = 0;
  int targin;
  char *ptd,*pts, Typ[4];
  char ss[64];
  char rang_d[16] = {0}, rang_f[16] = {0};

  targin = *argin ; /* save input */
  targin--;
  *absolute = 0;
  np_specif = 0;
  extract = 1;

#ifdef DLLMEX
  (Longint) lg = mxGetN (pin[targin]) * mxGetM (pin[targin]) + 1;
#else
  lg = mxGetN (pin[targin]) * mxGetM (pin[targin]) + 1;
#endif
  if ((buf = (char *) mxCalloc (lg, sizeof (char))) == NULL)
      meser ("Alloc4.1 - ", " ", 1001, FATAL);

  mxGetString(pin[targin], buf, lg );
  for (j = 0; j < lg - 1; j++)
        buf[j] =  (char)toupper((int) buf[j]);

#ifdef DEBUG
  mexPrintf ("relative targin %d %s\n", targin, buf);
#endif
/** +++ **/
  pts = buf;
  if ( (*pts == 'G') || (*pts == 'S') || (*pts == 'R') )
         return(0);
  while (*pts != '\0')
    {
      switch (*pts)
	{
	case 'T':
	case 'N': 
	  SyntaxeOK = 1;
	  if (!flagTN)
	    flagTN = 1;
	  else
	    {
	      mexPrintf ("T and N not allowed on the same line skipping T/N argument\n");
	      while (*pts != ' ' && *pts != '\0')
		pts++;
	      break;
	    }
          if(flagE) {   /* YB++***/
              mexPrintf ("T or N and E not allowed on the same line skipping T/N argument\n");
              while (*pts != ' ' && *pts != '\0')
                pts++;
              break;
          }    /****YB++***/

	  strncpy (Typ, pts, 1);
	  pts++;
	  if (*pts == 'I')
	    {
	      if (Typ[0] == 'T')
		strcpy (rang_d, "I");
	      else
		{
		  mexPrintf ("Erreur NI not allowed\n");
		}
	      pts++;
	    }
	  strcpy (ss, pts);
	  extr (ss, &pts, Typ, numchoc, rang_d, rang_f);

          switch (Typ[0]){
          case 'N' :
          l_rang  = 1;   /* lecture par rang */
          np_specif = 1;
	  rangs[0] = atoi (rang_d);
	  rangs[1] = atoi (rang_f);
#ifdef DEBUG
          mexPrintf("rang debut %d  rang fin %d \n",rangs[0],rangs[1]);
#endif
          break;
          case 'T' :
          l_rang  = 0;   /* lecture par temps */
	  xab[0] =1.0E6 * atof (rang_d);
	  xab[1] =1.0E6 * atof (rang_f);
#ifdef DEBUG
          mexPrintf("temps debut %g  temps fin %g \n",xab[0],xab[1]);
#endif
          break;
          }
	  break;

	case ' ':
	  SyntaxeOK = 1;
#ifdef DEBUG
	  mexPrintf ("separateur\n");
#endif
	  pts++;
	  break;

	case '+':
	  SyntaxeOK = 1;
#ifdef DEBUG
	  mexPrintf ("Temps absolu\n");
#endif
	  pts++;
	  *absolute = 1;
	  break;

	case 'E':
	  SyntaxeOK = 1;
#ifdef DEBUG
	  mexPrintf ("Extraction demandee\n");
#endif
	  pts++;

/*YB++ **/
	  flagE = 1;
	  if (flagTN)
	    {
	      mexPrintf ("T or N and E not allowed on the same line skipping E argument\n");
	      while (*pts != ' ' && *pts != '\0')
		pts++;
	      break;
	    }
/**YB++**/
/*YB++       if(*pts != NULL){
            ptd = ss;
            while (*pts != ' ' && *pts != '\0' && *pts != SEPAR_EXTR)
                *ptd++ = *pts++;
            *ptd='\0';
            extract = atoi(ss);
         }
YB++*/
            extract  = 2;  /** YB++**/

/*YB++        if(*pts != NULL)
                if (*pts  == SEPAR_EXTR)
                        pts++;
YB++*/

          if(*pts != NULL){
              ptd = ss;
              while (*pts != ' ' && *pts != '\0')
                *ptd++ = *pts++;
            *ptd='\0';
            nb_extr2 = atoi(ss);
           }
          else  
            nb_extr2 = VAL_DEF_EXTR;

	  break;

/**************************** MAJ 26 mars 2002 MAJ ***************/
       case 'P':
	 SyntaxeOK = 1;
	 pts++;

         if(*pts != NULL){
            ptd = ss;
            while (*pts != ' ' && *pts != '\0')
              *ptd++ = *pts++;
           *ptd='\0';
           extract = ((atoi(ss) > 0) && (atoi(ss) < 10)) ? (atoi(ss) + 3) : 1;
         }
         else  
           extract = 4; 
         break;

/**************************** MAJ 26 mars 2002 MAJ ***************/
	default:
	  SyntaxeOK = 0; /************ MAJ 26 mars 2002 MAJ **************/
	  /*printf ("%c ", *pts);
	  puts ("Argument unknown");
          Ignore arguments  */
	  pts++;
	}
    }
  if (SyntaxeOK) *argin = *argin - 1;
#ifdef DEBUG
	  mexPrintf ("SyntaxeOK %d relative argin %d\n",SyntaxeOK,*argin);
#endif

  mxFree (buf);
  return (0);

}

extr (char ss[], char **pts, char *type, Longint numchoc, 
      char *rang_d, char *rang_f)
{
  char *ptss, *ptd;
  char tmp[16] = {0};
  Double deb, fin;
  Double t;
  float fdeb, ffin;

  ptd = tmp;
  ptss = ss;
  while (*ptss != ' ' && *ptss != '\0')
    {
      (*pts)++;
      *ptd++ = *ptss++;
    }
  *ptd = '\0';

  if ((ptss = strchr (tmp, SEPAR_RANG)) != NULL)	/* Rang ? */
    {
      ptss++;			/* Rang demande */

      ptd = rang_f;		/* Rang fin */
      while (*ptss != NULL)
	*ptd++ = *ptss++;
      *ptd = '\0';

      if (rang_f[0] == '\0')	/* Rang fin non specifie */
	{
	  switch (type[0])
	    {
	    case 'N':
	      strcpy (rang_f, VAL_DEF_MAXR);
	      break;
	    case 'T':
	      strcpy (rang_f, VAL_DEF_MAXT);
	      break;
	    default:
	      strcpy (rang_f, VAL_DEF_MAXR);
	      break;
	    }
	}

      if (rang_d[0] != 'I')	/* Rang debut si pas ignitron */
	{
	  ptd = rang_d;
	  ptss = ss;
	  while (*ptss != SEPAR_RANG)
	    *ptd++ = *ptss++;
	  *ptd = '\0';
	}
      else
	/* Rang debut ingnitron demande */
	{
	  sprintf(rang_d,"%g",(Double) tsignitron (&numchoc)/1E6 );
	  if (atof (rang_f) < atof (rang_d))
	    {
	     mexPrintf ("valeur de fin inferieure a celle de debut, je corrige\n");
	      t = atof (rang_d) + (Double) VAL_DEF_TMPS;
	      sprintf (rang_f, "%g", t);
	    }
	}
      if (rang_d[0] == '\0')	/* Rang debut non specifie */
	{
	  switch (type[0])
	    {
	    case 'N':
	      strcpy (rang_d, VAL_DEF_MINR);
	      break;
	    case 'T':
	      strcpy (rang_d, VAL_DEF_MINT);
	      if (atof (rang_f) < atof (rang_d))
		{
	          mexPrintf ("valeur de fin inferieure a celle de debut, je corrige\n");
		  t = atof (rang_d) + (Double) VAL_DEF_TMPS;
		  sprintf (rang_f, "%g", t);
		}

	      break;
	    default:
	      strcpy (rang_d, VAL_DEF_MINR);
	      break;
	    }
	}
    }
  else if ((ptss = strchr (tmp, SEPAR_NBRE)) != NULL)	/* Nombre ? */
    {
      ptss++;			/* Nombre demande  */

      ptd = rang_f;		/* Nombre fin */
      while (*ptss != NULL)
	*ptd++ = *ptss++;
      *ptd = '\0';

      if (rang_d[0] != 'I')	/* Nombre debut si pas ingnitron */
	{
	  ptd = rang_d;
	  ptss = ss;
	  while (*ptss != SEPAR_NBRE)
	    *ptd++ = *ptss++;
	  *ptd = '\0';
	}

      if (rang_d[0] == '\0')	/* Nombre debut non specifie */
	{
	  switch (type[0])
	    {
	    case 'N':
	      strcpy (rang_d, VAL_DEF_MINN);
	      break;
	    case 'T':
	      strcpy (rang_d, VAL_DEF_MINT);
	      break;
	    default:
	      strcpy (rang_d, VAL_DEF_MINN);
	      break;
	    }
	}

      if (rang_f[0] == '\0')	/* Nombre fin non specifie */
	{
	  switch (type[0])
	    {
	    case 'N':
	      t = atof (rang_d) + (Double) VAL_DEF_NBRE;
	      break;
	    case 'T':
	      t = atof (rang_d) + (Double) VAL_DEF_TMPS;
	      break;
	    default:
	      t = atof (rang_d) + (Double) VAL_DEF_NBRE;
	    }
	  sprintf (rang_f, "%g", t);
	}
      else
	/* Nombre fin specifie */
	{
	  if (rang_d[0] == 'I')	/* Ignitron demande */
	    sprintf(rang_d,"%g",(Double)(tsignitron (&numchoc)/1E6) );
	    t = atof (rang_d) + atof (rang_f);
	    sprintf (rang_f, "%g", t);
	}
    }
  else
    {				/* pas separateur nbre ni rang  */
      extraction = 1;
      switch (type[0])
	{
	case 'N':
	  if (tmp[0] != '\0'){	/* Valeur fin specifie */
	    strcpy (rang_f, tmp);
            nb_extr2 = atoi(tmp);
          }
	  else{
	    strcpy (rang_f, VAL_DEF_MAXR);
            nb_extr2 = atoi(VAL_DEF_MAXR);
          }

	  if (rang_d[0] == 'I') {
	      sprintf(rang_d,"%g",(Double) (tsignitron (&numchoc)/1E6) );
            }
	  else
	    strcpy (rang_d, VAL_DEF_MINR);
	  break;

	case 'T':
	  if (rang_d[0] == 'I') {
	      sprintf(rang_d,"%g",(Double) (tsignitron (&numchoc)/1E6) );
            }
	  else
	    strcpy (rang_d, VAL_DEF_MINT);

	  if (tmp[0] != '\0')	/* Valeur fin specifiee */
	    {
	      t = atof (rang_d) + atof (tmp);
	      sprintf (rang_f, "%g", t);
	    }
	  else
	    {
	      t = atof (rang_d) + (Double) VAL_DEF_TMPS;
	      sprintf (rang_f, "%g", t);
	    }
	  break;
	}
    }
}
/*
 * ------------------------- main  program ---------------------------
 */

void
mexFunction (int nout, mxArray * pout[], int nin,const mxArray * pin[])
{
  short flagmac= 0, nb_don;
  Longint i, j;
  Longint ntrait, nbcar;
  Longint numchoc, cr, msig;
  char *nom_trait, *diag, *ltrait[MAX_TRAIT];
  char *charcom, *charsig;
  pS_DescTrait pt_desctrait;
  pS_DescDon pt_descdon;
  Double *pr;			/* partie reelle de la matrice */
  int nintemp;
  char *dateRDC_deb = NULL, *dateRDC_fin = NULL;
  char *heureRDC_deb = NULL, *heureRDC_fin = NULL;

  /** YB multi_occurrence  **/
  double nchoct, nct;
  int occ = 0;

/* PC   */
#ifdef DLLMEX
  int maxv = 0;
#else
  size_t maxv = 0;
#endif
  short ii, flag;
  Longint ntot;
/*** +++ ***/
  Longint rang[2] = {0, 0};
  Double  xab[2]  = {0,0};

  l_rang = 1;	  /* lecture rang par defaut */         /** +++  **/
  nb_extr2 = -1; /* nbre mesures quand extract = 2 */  /** +++  **/
  extraction = 0;
  extract = 1;

  num = 0;
  absolute = 0;
  nouttemp = nout;
  nintemp = nin;

#if (client == MAC )
  //  Init_err_tslib();
  //  Init_err_tsmat();
  //  Init_err_rqlib();
#endif

/* For CTRL C problems */
  newact.sa_handler = sig_ctrlc;
  sigemptyset(&newact.sa_mask);
  newact.sa_flags = 0;
  sigaction(SIGINT, &newact, &oldact);

  sigemptyset(&newmask);
  sigaddset(&newmask, SIGINT);
/* For CTRL C problems */


#ifdef DEBUG
  mexPrintf ("in %d out %d\n", nin, nout);
#endif
/*MessageBox(hWndMATLABCmd,"IN TSMAT","tsbase",MB_OK);*/
/*
 * Retour de la liste et commentaires des traitements si pas d'arguments
 * d'entree
 */
  if (nin == 0)
    {
      cr = TSLTrait (&ntrait, ltrait);
#ifdef DEBUG
  mexPrintf ("apres TSLTrait cr = %d ntrait = %d\n", cr, ntrait);
#endif
      if (cr)
	meser ("TSLTrait - ", " ", cr, FATAL);
      if ((charcom = (char *) mxCalloc ((unsigned int) (ntrait * TAILLE_NOM_TRAITEMENT) + 1, sizeof (char))) == NULL)
	  meser ("Alloc1 - ", " ", 1001, FATAL);
/* */
      for (i = 0; i < ntrait; i++)
	if (Strlen (ltrait[i]) > maxv)
	  maxv = Strlen (ltrait[i]);

      Strcpy (charcom, ltrait[0]);
      for (i = 0; i < (maxv - Strlen (ltrait[0])); i++)
	Strcat (charcom, " ");

      for (i = 1; i < ntrait; i++)
	{
	  Strcat (charcom, ltrait[i]);
	  for (ii = 0; ii < (maxv - Strlen (ltrait[i])); ii++)
	    Strcat (charcom, " ");
	}
      if (nouttemp > 0)
	{
	  pout[num] = charMat ((Longint) ntrait, (Longint) maxv, charcom);
	  num += 1;
	  nouttemp--;
	}
      mxFree (charcom);

/* commentaire traitements  si besoin est */
      if (nouttemp > 0 ) {
        int l12 = 0;
        if ((charcom = (char *) mxCalloc (
          (unsigned int) (ntrait * (TAILLE_COMMENT + 2)), sizeof (char))) == NULL)
	  meser ("Alloc2 - ", " ", 1001, FATAL);
        for (i = 0; i < ntrait; i++)
  	{
	  cr = TSDescTrait (ltrait[i], 0L, &pt_desctrait);
	  if (cr)
	    meser ("TSDescTrait - ", ltrait[i], cr, FATAL);
	  if (pt_desctrait->commentaire)
	    {
/* */
              l12 = TAILLE_COMMENT - Strlen (pt_desctrait->commentaire);
	      if (i == 0)
	        strncpy (charcom, pt_desctrait->commentaire,TAILLE_COMMENT);
	      else
          	strncat (charcom, pt_desctrait->commentaire,TAILLE_COMMENT);


         if (l12 > 0 ) {
	      for (ii = 0; ii < l12; ii++)
		Strcat (charcom, " ");
            } 
	  }
	  else
	    {
	      if (i == 0)
		Strcpy (charcom, " ");
	      else
		Strcat (charcom, " ");
	      for (ii = 0; ii < TAILLE_COMMENT - 1; ii++)
		Strcat (charcom, " ");
	    }
	  FreeMemM (pt_desctrait);
	}
     /* if (nouttemp > 0)
	{ */
	  pout[num] = charMat ((Longint) ntrait, (Longint) TAILLE_COMMENT,
			       charcom);
	  num += 1;
	  nouttemp--;
	/*}*/
      mxFree (charcom);
      }
    }
  else if (nin == 1)		/* liste diagnostics et signaux */
    {
      if (mxIsChar (pin[0]))
	{
	  ntot = mxGetN (pin[0]) * mxGetM (pin[0]) + 1;
          nom_trait = mxCalloc (ntot + 1, sizeof (char));
          mxGetString(pin[0], nom_trait, ntot);
          for (i = 0; i < ntot - 1; i++)
            nom_trait[i] = (char) toupper ((int) nom_trait[i]);

	  cr = TSDescTrait (nom_trait, 0, &pt_desctrait);
	  if (cr != 0)
	    meser ("TSDescTrait - ", nom_trait, cr, FATAL);
	  nb_don = pt_desctrait->nb_donnees;
	  if ((charsig = (char *) mxCalloc (nb_don + 1, TAILLE_NOM_DONNEE *
					    sizeof (char))) == NULL)
	      meser ("Alloc3 - ", " ", 1001, FATAL);
	  if ((charcom = (char *) mxCalloc (nb_don + 1, TAILLE_COMMENT *
					    sizeof (char))) == NULL)
	      meser ("Alloc4 - ", " ", 1001, FATAL);
	  nbcar = 0;

/* PC   */
	  flag = 0;

	  while (pt_desctrait->ps_donnee != NULL)
	    {
  
              int l12;
	      if (!flag)
		Strcpy (charsig, pt_desctrait->ps_donnee->nom);
	      else
		Strcat (charsig, pt_desctrait->ps_donnee->nom);

	      for (ii = 0; ii < (TAILLE_NOM_DONNEE - Strlen (pt_desctrait->ps_donnee->nom)); ii++)
		Strcat (charsig, " ");

    if (nout > 1 ) {  /*  commentaire si necessaire */
	      cr = TSDescDon (pt_desctrait->ps_donnee->nom, &pt_descdon);
	      if (cr)
		meser ("TSDescDon - ", pt_desctrait->ps_donnee->nom, cr, FATAL);
	      if (pt_descdon->commentaire)
		{
		  l12 = TAILLE_COMMENT - Strlen (pt_descdon->commentaire);
		  if (!flag)
	            strncpy (charcom, pt_descdon->commentaire, TAILLE_COMMENT);
		  else
	            strncat (charcom, pt_descdon->commentaire,TAILLE_COMMENT);
                  if (l12 > 0) {
		    for (ii = 0; ii < l12; ii++)
		             Strcat (charcom, " ");
                  }
		}
	      else
		{
		  if (!flag)
		    Strcpy (charcom, " ");
		  else
		    Strcat (charcom, " ");
                  
		    for (ii = 0; ii < TAILLE_COMMENT - 1; ii++)
		      Strcat (charcom, " ");
		}

	     /* YBYBYBYBYBYB  FreeMemM (pt_descdon); */
       }  /***++++  ***/
	      nbcar++;
	      pt_desctrait->ps_donnee = pt_desctrait->ps_donnee->ps_suivant;
	      flag = 1;
	    }

	  if (nouttemp > 0)
	    {
	      pout[num] = charMat ((Longint) nbcar,
				   (Longint) TAILLE_NOM_DONNEE, charsig);
	      num += 1;
	      nouttemp--;
	    }
	  if (nouttemp > 0)
	    {
	      pout[num] = charMat ((Longint) nbcar, (Longint) TAILLE_COMMENT,
				   charcom);
	      num += 1;
	      nouttemp--;
	    }
	  mxFree (charsig);
	  mxFree (charcom);
	  mxFree (nom_trait);
	/*  FreeMemM (pt_desctrait); */
	}
      else
	mexErrMsgTxt ("Il faut donner un nom de traitement");
    }
  else if (nin > 1)
    {
      if (nout < 1)
	mexErrMsgTxt ("Il faut au moins 1 argument de sortie !");
      
      if (!(mxIsNumeric (pin[0]))) {
/* 	mexErrMsgTxt ("Le 1er argument doit etre un numero de choc!"); */
      
        numchoc = -1;
        /* 1er argument = toujours nom_donnee */
        ntot = mxGetN (pin[0]) * mxGetM (pin[0]) + 1;
        if ((diag = mxCalloc (ntot, sizeof (char))) == NULL)
            meser ("AllocDC1 - ", " ", 1001, FATAL);
            mxGetString(pin[0], diag, ntot );
            for (j = 0; j < ntot - 1; j++)
                diag[j] = (char) toupper ((int) diag[j]);
            diag[j] = '\0';

      switch(nin) {
        case 2: if (!(mxIsNumeric (pin[1]))) {
                   mexErrMsgTxt ("Le 2eme argument doit etre un numero de choc!");
                 }
                  else 
                 {
                   pr = mxGetPr (pin[1]);
                   nchoct = (Double) pr[0];
                   occ = (int) rint( 10 * modf(nchoct, &nct)) ;
                   numchoc = (int) nct;

                  if ((dateRDC_deb = mxCalloc (2, sizeof (char))) == NULL)
                       meser ("AllocDC2 - ", " ", 1001, FATAL);
                  if ((heureRDC_deb = mxCalloc (2, sizeof (char))) == NULL)
                       meser ("AllocDC3 - ", " ", 1001, FATAL);
                  if ((dateRDC_fin = mxCalloc (2, sizeof (char))) == NULL)
                       meser ("AllocDC7 - ", " ", 1001, FATAL);
                  if ((heureRDC_fin = mxCalloc (2, sizeof (char))) == NULL)
                       meser ("AllocDC4 - ", " ", 1001, FATAL);
                  strcpy(dateRDC_deb,"X");
                  strcpy(heureRDC_deb,"X");
                  strcpy(dateRDC_fin,"X");
                  strcpy(heureRDC_fin,"X");
                 }
                 break;

        case 4: if (!(mxIsNumeric (pin[1])) && !(mxIsNumeric (pin[2])) &&
                    !(mxIsNumeric (pin[3])) ) {
                  ntot = mxGetN (pin[1]) * mxGetM (pin[1]) + 1;
                  if ((dateRDC_deb = mxCalloc (ntot, sizeof (char))) == NULL)
                       meser ("AllocDC2 - ", " ", 1001, FATAL);
                  mxGetString(pin[1], dateRDC_deb, ntot );

                  ntot = mxGetN (pin[2]) * mxGetM (pin[2]) + 1;
                  if ((heureRDC_deb = mxCalloc (ntot, sizeof (char))) == NULL)
                       meser ("AllocDC3 - ", " ", 1001, FATAL);
                  mxGetString(pin[2], heureRDC_deb, ntot );

                  ntot = mxGetN (pin[3]) * mxGetM (pin[3]) + 1;
                  if ((heureRDC_fin = mxCalloc (ntot, sizeof (char))) == NULL)
                       meser ("AllocDC4 - ", " ", 1001, FATAL);
                  mxGetString(pin[3], heureRDC_fin, ntot );

                  if ((dateRDC_fin = mxCalloc (2, sizeof (char))) == NULL)
                       meser ("AllocDC7 - ", " ", 1001, FATAL);
                  strcpy(dateRDC_fin,"X");
                } else 
                mexErrMsgTxt ("Les arguments 2, 3 et 4 doivent etre des chaines de carateres : date_debut, heure_debut, heure_fin");
                break;

        case 5: if (!(mxIsNumeric (pin[1])) && !(mxIsNumeric (pin[2])) &&
                    !(mxIsNumeric (pin[3])) && !(mxIsNumeric (pin[4]))) {
                  ntot = mxGetN (pin[1]) * mxGetM (pin[1]) + 1;
                  if ((dateRDC_deb = mxCalloc (ntot, sizeof (char))) == NULL)
                       meser ("AllocDC5 - ", " ", 1001, FATAL);
                  mxGetString(pin[1], dateRDC_deb, ntot );

                  ntot = mxGetN (pin[2]) * mxGetM (pin[2]) + 1;
                  if ((heureRDC_deb = mxCalloc (ntot, sizeof (char))) == NULL)
                       meser ("AllocDC6 - ", " ", 1001, FATAL);
                  mxGetString(pin[2], heureRDC_deb, ntot );

                  ntot = mxGetN (pin[3]) * mxGetM (pin[3]) + 1;
                  if ((dateRDC_fin = mxCalloc (ntot, sizeof (char))) == NULL)
                       meser ("AllocDC7 - ", " ", 1001, FATAL);
                  mxGetString(pin[3], dateRDC_fin, ntot );

                  ntot = mxGetN (pin[4]) * mxGetM (pin[4]) + 1;
                  if ((heureRDC_fin = mxCalloc (ntot, sizeof (char))) == NULL)
                       meser ("AllocDC8 - ", " ", 1001, FATAL);
                  mxGetString(pin[4], heureRDC_fin, ntot );

                } else {
              mexErrMsgTxt ("Les arguments 2, 3 ,4 et 5 doivent etre des chaines de carateres : date_debut, heure_debut, date_fin, heure_fin");

                }
             break;
     
        default: mexErrMsgTxt ("Il faut 2, 4 ou 5 arguments en entree !");


      }

       cr = lit_DC (diag, dateRDC_deb, heureRDC_deb, dateRDC_fin, heureRDC_fin,
                    numchoc, pout, nout);

      }
      else {

      pr = mxGetPr (pin[0]);
     /* numchoc = (Longint) pr[0]; */

      /**  YB multi_occurrence  **/
      nchoct = (Double) pr[0];

     /* if (10 * modf(nchoct, &nct) > 9.1)
         mexErrMsgTxt ("L'occurrence doit etre inferieure a 10 !");
*/
      occ = (int) rint( 10 * modf(nchoct, &nct)) ;
      numchoc = (int) nct;

      if (mxGetM (pin[1]) > 1)
	{			/* matrice plusieurs signaux */
	  msig = mxGetM (pin[1]);
	  flagmac = 1;
	  if (nin > 2)
	    cr = relative_time (pin, &nintemp, numchoc, &absolute, rang, xab);
	}
      else
	{
	  if (nin > 2)
	    {
	      cr = relative_time (pin, &nintemp, numchoc, &absolute, rang, xab);
	      /*msig = nin - 2;*/
	      msig = nintemp -1 ;
	    }
	  else
	    msig = nintemp - 1;
	  flagmac = 0;
	}
/* ----------------------------------------  */
#ifdef DEBUG
	  mexPrintf ("nombre de signaux %d\n", msig);
#endif
      mexPrintf ("%s Choc : %d\n", banner, numchoc);
      for (i = 0; i < msig; i++)
	{
	  if (flagmac)
	    {
              int ntotbis;

	      ntot = mxGetN (pin[1]) * mxGetM (pin[1]) + 1;
	      ntotbis = mxGetN (pin[1]) ;
	      if ((diag = (char *) mxCalloc (ntot, sizeof (char)))
		  == NULL)
		  meser ("Alloc5 - ", " ", 1001, FATAL);
              mxGetString(pin[1], diag, ntot );
	      for (j = 0; j < ntotbis; j++)
		{
		  if ((char) diag[i + j * msig] == ' ')
		    break;
		  diag[j] = (char) toupper ((int) diag[i + j * msig]);
		}
	      diag[j] = '\0'; 
	    }
	  else
	    {
	      ntot = mxGetN (pin[i + 1]) * mxGetM (pin[i + 1]) + 1;
	      if ((diag = mxCalloc (ntot, sizeof (char))) == NULL)
		  meser ("Alloc6 - ", " ", 1001, FATAL);
              mxGetString(pin[i + 1], diag, ntot );
	      for (j = 0; j < ntot - 1; j++)
		{
		  diag[j] = (char) toupper ((int) diag[j]);
		}
	      diag[j] = '\0'; 
	    }
#ifdef DEBUG
	  mexPrintf ("avant lit_traite %s choc %ld occ %d num %ld nouttemp %d\n", diag, numchoc, occ, num, nouttemp);
#endif
	  cr = lit_traite (diag, numchoc, occ, pout, nout, rang, xab);  /** +++ **/
#ifdef DEBUG
	  mexPrintf ("apres lit_traite cr %ld num %d nouttemp %d\n", cr, num, nouttemp);
#endif
	  if (cr != 0)
	    {
/* clear outputs buffers */
	      if (nouttemp > 0)
		{
		  pout[num] = emptyMat ();	/* les valeurs */
		  num += 1;
		  nouttemp--;
		}
#ifdef DEBUG
	      mexPrintf ("nouttemp/1 %d num %d \n", nouttemp, num);
#endif
	      if (nouttemp > 0)
		{
		  pout[num] = emptyMat ();	/* les temps   */
		  num += 1;
		  nouttemp--;
		}
#ifdef DEBUG
	      mexPrintf ("nouttemp/2 %d num %d\n", nouttemp, num);
#endif
	      if (nouttemp > 0)
		{
		  if ((type == homoType) || (type == extgType))
		    {		/* les coordonnees */
		      pout[num] = emptyMat ();
		      num += 1;
		      nouttemp--;
		    }
		}
#ifdef DEBUG
	      mexPrintf ("nouttemp/3 %d num %d\n", nouttemp, num);
#endif
	      if (nouttemp > 0)
		{
		  if (cr != 199)
		    pout[num] = emptyMat ();	/* Certifs , date, .. */
		  num += 1;
		  nouttemp--;
		}
#ifdef DEBUG
	      mexPrintf ("nouttemp/4 %d num %d\n", nouttemp, num);
#endif
	    }
	  mxFree (diag);
	}
    }
}
#ifdef DEBUG
  mexPrintf ("Fin nout = %d num = %d\n", nout, num);
#endif
  sigaction(SIGINT, &oldact, NULL);         /* reset previous action */
  for (i = num; i < nout; i++)
    pout[i] = emptyMat ();
}

Longint
lit_traite (char *nomsigp, Longint numchoc, Longint occ, mxArray * pout[],
            int nout, Longint rang[], Double xab[])
{
  Register Longint i, j;
  Longint nbmax, nbmes, nbmesgr[3], lind[5], cr, cr1, numv;
  Longint nbcoord[MAX_COORD], nb_certif, rgrp = 0;
  /** +++ **/
  /* Longint	rang[2], maxreel, cooked_d = 0, fcomment = 0;*/
  Longint maxreel, cooked_d = 0, fcomment = 0;

  Longint indices[2], rscalaire = 0, rscaltime = 0, scomment = 0;
  Longint certif[MAX_CERTIF];
  Double HUGE *X;
  Double HUGE *Y;
  Double Coord[10*MAX_SIG], coeff_temps = 1.0;
  char HUGE *Xc, *Yc;
  char date[TAILLE_DATE], heure[TAILLE_HEURE], cmisc[TAILLE_MISC]={'\0'};
  char *ptd, nomsig[TAILLE_NOM_DONNEE], nom_gen[TAILLE_NOM_DONNEE];
  char aff[64], nomsig_misc[TAILLE_NOM_DONNEE + 4], n_temp[TAILLE_NOM_DONNEE];
/********* New for ARCAD ************/
  /* pS_DescDon ptDescDon; */
   ts_donnee *ptDescDon; 
/********* New for ARCAD ************/
  pS_Entree ptEntree;
  pS_Unite ptUnite;
  Double HUGE *pr;
  Longint occur = 0, indg = 0;
  short pansement = 0, generique = 1 ;


  ptEntree = (pS_Entree) mxCalloc (1, sizeof (struct S_Entree));
  ptEntree->union_var.lval = numchoc;

/*****++++++++++++++++++++++++++++++++ MAJ Mars 2002 ****************/
  if( nomsigp[0] == '!') {
    strcpy(nomsigp, &nomsigp[1]);
    generique = 0;
  }
/*****++++++++++++++++++++++++++++++++ MAJ Mars 2002 ****************/

  tsparse (nomsigp, nomsig, indices, &rgrp, &occur);

  if (occ)
   occur = occ;

  if ( occur ) {
    ptEntree->ps_suivant = (pS_Entree) mxCalloc (1, sizeof (struct S_Entree));
    ptEntree->ps_suivant->union_var.lval = occur;
    ptEntree->ps_suivant->ps_suivant = NULL;
  }
   else
      ptEntree->ps_suivant = NULL;

  for (i = 0; i < MAX_CERTIF; i++)
    certif[i] = 0;

  for (i = 0; i < MAX_COORD; i++)
    nbcoord[i] = 0;
#ifdef DEBUG
      mexPrintf ("avant Tsexist signal %s choc %d \n", nomsig, numchoc);
#endif
  cr = TSExist_gen (nomsig, ptEntree, nbcoord, &numv, certif, date, heure,
                    nom_gen, &indg);

  if( (strncmp(nomsig, nom_gen, strlen(nomsig))) && (nom_gen[0] == 'G') )
    pansement = 1;

/*****++++++++++++++++++++++++++++++++ MAJ Mars 2002 ****************/
  if( (extract > 3) && ((nom_gen[0] == 'g') || (nom_gen[0] == 'G')) &&
     (rgrp == 0) )
    extract = 1;



  if ( generique )
     strcpy(nomsig, nom_gen);
  if(indg != 0) {
    rgrp = 1;
    indices[0] = indg;
    sprintf(aff,"lisant %s %d !",nomsig,indg);
  } else
  sprintf(aff,"lisant %s !",nomsig);  

#ifdef DEBUG
      mexPrintf ("Tsexist cr = %ld nbcoord[0] %ld \n", cr, nbcoord[0]);
#endif
  if (cr || (nbcoord[0] == 0))
    {				/* ncoord[0]= 0 si certif <= -2 */
      if (cr)
	{			/* verification de l'existence du choc */
	  cr1 = TSExist ("num_choc", ptEntree, nbcoord, &numv, certif, date, heure);
	  if (cr1)
	    {			/* le choc n'existe pas */

              switch(cr1) {
                case 103 : mexPrintf("Tslib Server down !!! \n");
                           mexPrintf("N'en fau tasta per lou saupre \n");
                           break;
                default: mexPrintf ("TSExist - %s Choc absent cr1 = %d\n",
                                      nomsig, cr1);
              }
	      mxFree (ptEntree);
	      return (cr);
	    }
	}
#ifdef DEBUG
      mexPrintf ("Tsexist cr = %ld nbcoord[0] %ld \n", cr, nbcoord[0]);
#endif
/* Unites , date , heure , certifs ...   quand certif <= -2 */
      if (nbcoord[0] == 0)
	{			/* certif =-2 */
          cr = TSDescDon_choc (nomsig, numchoc, occur, &ptDescDon);
          if (cr)
             meser ("TSDescDon_choc - ", nomsig, cr, FATAL);
          if ((ptDescDon->type_donnee >> S_SIMPLE) & 1) /* signal simple */
                 type = sigType;
          else if ((ptDescDon->type_donnee >> D_GHOMO) & 1) /* groupe */
                 type = homoType;
          else
                 meser ("Who are you ?", nomsig, 1002, FATAL);

          if (ptDescDon->type_donnee & 1 << 1)  /* donnee traitee */
             cooked_d = 1;

	  switch (type)
	    {
	    case homoType:
	    case extgType:
	      if (nout < 4)
		{
		  mexPrintf ("Il faut 4 arguments de sortie\n");
		  return (cr);
		}
	      break;
	    default:
	      if (nout < 3)
		{
		  mexPrintf ("Il faut 3 arguments de sortie\n");
		  return (cr);
		}
	      break;
	    }

	  j = num + 2;		/* on saute Y et T qui sont vides */
	  if ((type == homoType) || (type == extgType))
	    j++;		/* certif = 4eme arg */

	  ptd = cmisc;
#if (client == PC )
	  Strcpy (ptd, " ");
	  for (i = 1; i < 2 * LONG_UNITE; i++)
	    Strcat (ptd, " ");	/* Simule Unites X et Y */
#else
	  for (i = 0; i < 2 * LONG_UNITE; i++)	/* Simule Unites X et Y */
	    *ptd++ = ' ';
	  *ptd = '\0';
#endif
	  Strcat (cmisc, date);
	  Strcat (cmisc, heure);
/*****++++++++++++++++++++++++++++++++ MAJ Mars 2002 ****************/
      ptd = cmisc;
      while (*ptd)
         ptd++;

      if( indg > 0)
       sprintf(nomsig_misc,"%s%d",nomsig,indg);
      else
       strcpy(nomsig_misc,nomsig);

      for (i = 0; i < TAILLE_NOM_DONNEE + 4; i++)
        {
          if (i < Strlen (nomsig_misc))
            *ptd++ = nomsig_misc[i];
          else
            *ptd++ = ' ';
        }
      *ptd = '\0';
      if (cooked_d)
        strcat(cmisc,"T");
      else
        strcat(cmisc,"B");
/*****++++++++++++++++++++++++++++++++ MAJ Mars 2002 ****************/
	  nb_certif = 1;

	  if (type == homoType)
	    nb_certif += nbcoord[1] * (nbcoord[2] > 0 ? nbcoord[2] : 1);
#ifdef DEBUG
	  mexPrintf ("Tsexist cr = %ld misc num = %ld \n", cr, j);
#endif
	  pout[j] = mxCreateDoubleMatrix (Strlen (cmisc) + 1 + nb_certif + 1, 1, mxREAL);
	  pr = mxGetPr (pout[j]);
	  pr[0] = (Double) nb_certif;
	  for (i = 0; i < nb_certif; i++)
	    pr[1 + i] = (Double) certif[i];
	  pr[1 + nb_certif] = (Double) numv;
	  for (i = 0; i < Strlen (cmisc); i++)
	    pr[2 + nb_certif + i] = cmisc[i];
/* Fin  Unites , date , heure , certifs ...   */
	}
      meser ("TSExist - ", nomsig, ((cr != 0) ? cr : 9), NONFATAL);
      if(occur)
        mexPrintf
           ("En fait c'est l'occurrence %d du choc %d qui n'exite pas :-)\n",
           occur,numchoc);
      mxFree (ptEntree);
      return (((cr != 0) ? cr : 199));
    }


/********* New for ARCAD ************/
  cr = TSDescDon_choc (nomsig, numchoc, occur, &ptDescDon);
/********* New for ARCAD ************/
  if (cr)
    meser ("TSDescDon_choc - ", nomsig, cr, FATAL);

  if ((ptDescDon->type_donnee >> D_TRAITEE) & 1) {
    cooked_d = 1;		/* donnee traitee */
  }
  if ((ptDescDon->type_donnee >> S_SIMPLE) & 1)	/* signal simple */
    type = sigType;
  else if ((ptDescDon->type_donnee >> D_GHOMO) & 1)	/* groupe homogene */
    type = homoType;
  else
    meser ("Who are you ?", nomsig, 1002, FATAL);

  if (rgrp)
    type = extgType;		/* extraction d'un signal demandee */

  if (!(ptDescDon->type_donnee >> SG_FTMPS & 1))
    {				/* non fonction du temps */
      if (ptDescDon->nb_coordonnees == 1)
	rscalaire = 1;

      else if (ptDescDon->nb_coordonnees > 1)
	rscalaire = 2;

/*      if (ptDescDon->ps_coord != NULL)
	{*/			/* format caractere ? */
#if (client == PC || client == MAC)
	  if ((!Strncmp (ptDescDon->formaty, "c", 1)) ||
	      (!Strncmp (ptDescDon->formaty, "C", 1)))
#else
	  if (!strncasecmp (ptDescDon->formaty, "c", 1))
#endif
	    {
	      ptd = ptDescDon->formaty;
	      ptd++;
	      scomment = 1;
	      fcomment = atoi (ptd);	/* taille format */
	    }
	/* } */
    }
  /* YBYBYBYBYBYBYB  FreeMemM (ptDescDon); */

#ifdef DEBUG
  mexPrintf ("type %ld scomment %ld rgrp %ld rscalaire %ld absolu %ld\n",
	     type, scomment, rgrp, rscalaire, absolute);
#endif
  /* Read the data */

  nbmax = nbcoord[0];
  if (rang[0] == 0)
    rang[0] = 1;		/** +++  **/
#if (client == PC )
  if (nbcoord[0] > MAXDATAPC)
    {
      if (rang[1] == 0)
	rang[1] = MAXDATAPC;	/** +++ **/
      mexPrintf ("==> Attention plus de 100000 mesures on ne peut  <==\n");
      mexPrintf ("==> lire que 100000 mesures maximum sur les PCs  <==\n");
      mexPrintf ("==> pour plus de renseignements Y.Buravand 23.42 <==\n");
    }
  else if ( extraction || rang[1] == 0 || np_specif == 0)
    rang[1] = nbcoord[0];	/** +++ **/
#else
  if ( extraction  || rang[1] == 0 || np_specif == 0)
    rang[1] = nbcoord[0];	/** +++ **/
#endif

#ifdef DEBUG
  mexPrintf ("extraction %d extr2 %d l_rang %d\n", extraction,nb_extr2,l_rang);
#endif
  mexPrintf ("%s \n",aff);
  if (type == homoType)
    {
int nbmax_sv;
      /*extract = 1;*/  /** ++++ **/
      if (nb_extr2 < 0 ){
        nbmax = nbcoord[0] * nbcoord[1] * (nbcoord[2] > 0 ? nbcoord[2] : 1);
        nbmax_sv = nbmax;
      }
      else{
        nbmax = nb_extr2 * nbcoord[1] * (nbcoord[2] > 0 ? nbcoord[2] : 1);
        nbmax_sv = nb_extr2;
       }

      if(nbmax > 100000)
       mexPrintf("What a big signal !! be quiet please data are coming soon ...\n");
      if ((X = (Double HUGE *) mxCalloc (nbmax, sizeof (Double))) == NULL)
	meser ("Alloc7 -", " ", 1001, FATAL);
      if ((Y = (Double HUGE *) mxCalloc (nbmax, sizeof (Double))) == NULL)
	meser ("Alloc8 -", " ", 1001, FATAL);
/** ++++   **/
  if (l_rang == 1) 
   {
#ifdef DEBUG
      mexPrintf ("avant TSGrpRg rangs %ld %ld nbmax %ld\n", rang[0], rang[1], nbmax);
      mexPrintf ("avant TSGrpRg nbcoord %ld %ld %ld extract=%d \n", nbcoord[0], nbcoord[1], nbcoord[2],extract);
#endif
      cr = TSGrpRg (nomsig, ptEntree, rang, nbmax_sv, extract, &ptUnite,
	            &numv, certif, date, heure, nbmesgr, &maxreel,
                    (char HUGE *) X, (char HUGE *) Y, (char *) Coord);
  }
  else
  {
#ifdef DEBUG
      mexPrintf ("avant TSGrpX abs %g %g nbmax %ld\n", xab[0], xab[1], nbmax);
#endif
     cr = TSGrpX (nomsig, ptEntree, xab[0], xab[1], nbmax_sv, extract, &ptUnite,
            &numv, certif, date, heure, nbmesgr, &maxreel, (char HUGE *)X,
            (char HUGE *) Y,  (char *) Coord);
  }

      if (cr != 0)
	{
	  if (l_rang ==1)
            meser ("TSGrpRg - ", nomsig, cr, NONFATAL);
	  else 
            meser ("TSGrpX - ", nomsig, cr, NONFATAL);
	  mxFree (ptEntree);
	  mxFree (X);
	  mxFree (Y);
	  return (cr);
	}
      lind[0] = nbmesgr[0];
      lind[1] = nbcoord[1] * (nbcoord[2] > 0 ? nbcoord[2] : 1);
      if (cooked_d == 0)
	lind[2] = lind[1];
      else
	lind[2] = 1;
#ifdef DEBUG
 mexPrintf ("apres lecture homotype lind[0] %d, lind[1] %d, lind[2] %d\n", 
      lind[0], lind[1], lind[2]);
#endif
    }
  else if (type == sigType)
    {
      /*extract = 1; */   /*   ++++ **/
 /*     if (nb_extr2 < 0 && !scomment) */
      if (nb_extr2 < 0 )
        nbmax = nbcoord[0];
      else
        nbmax = nb_extr2 ;

      if (scomment)
	{			/* signal commentaire  */
	  nbmax = nbmax * fcomment;
	  if ((Xc = (char *) mxCalloc (nbmax, sizeof (char))) == NULL)
	      meser ("Alloc9 - ", " ", 1001, FATAL);
	  if ((Yc = (char *) mxCalloc (nbmax, sizeof (char))) == NULL)
	      meser ("Alloc10 - ", " ", 1001, FATAL);
#ifdef DEBUG
mexPrintf ("avant TSRSIGRg rangs %ld %ld nbmax %ld\n", rang[0], rang[1], nbmax);
#endif
	  cr = TSRSigRg (nomsig, ptEntree, rang, nbmax, extract, &ptUnite,
		      &numv, certif, date, heure, &nbmes, &maxreel, Xc, Yc);
#ifdef DEBUG
mexPrintf ("apres TSRSigRg cr %ld nbmes %d maxreel %d fcomment %d \n",
cr,nbmes,maxreel,fcomment);
mexPrintf("Xc %s strlen(Xc) %d\n",Xc,strlen(Xc));
#endif
	  if (cr)
	    {
	      meser ("TSRSigRg - ", nomsig, cr, NONFATAL);
	      mxFree (ptEntree);
	      mxFree (Xc);
	      mxFree (Yc);
	      return (cr);
	    }
	  lind[0] = 1;
	  lind[1] = nbmes * fcomment;
	}
      else
/* signal "normal"  */
	{
      if(nbmax > 100000)
       mexPrintf("What a big signal !! be quiet please data are coming soon ...\n");
	  if ((X = (Double HUGE *) mxCalloc (nbmax, sizeof (Double))) == NULL)
	    meser ("Alloc9 - ", " ", 1001, FATAL);
	  if ((Y = (Double HUGE *) mxCalloc (nbmax, sizeof (Double))) == NULL)
	    meser ("Alloc10 - ", " ", 1001, FATAL);

 if (l_rang == 1)
 {
#ifdef DEBUG
mexPrintf ("avant TSRSIGRg rangs %ld %ld nbmax %ld\n", rang[0], rang[1], nbmax);
#endif
	  cr = TSRSigRg (nomsig, ptEntree, rang, nbmax, extract, &ptUnite,
	      &numv, certif, date, heure, &nbmes, &maxreel, (char HUGE *) X,
			 (char HUGE *) Y);
#ifdef DEBUG
mexPrintf ("apres TSRSigRg cr %ld nbmes %d maxreel %d\n",
cr,nbmes,maxreel);
#endif
 }
 else
 {
#ifdef DEBUG
mexPrintf ("avant TSRSigX xab %g %g nbmax %ld\n", xab[0], xab[1], nbmax);
#endif
      cr = TSRSigX (nomsig, ptEntree, xab[0], xab[1], nbmax, extract,
             &ptUnite, &numv, certif, date, heure, &nbmes, &maxreel,
             (char HUGE *) X, (char HUGE *) Y);
 }
	  if (cr)
	    {
	      if(l_rang == 1)
                 meser ("TSRSigRg - ", nomsig, cr, NONFATAL);
	      else 
                 meser ("TSRSigX - ", nomsig, cr, NONFATAL);
	      mxFree (ptEntree);
	      mxFree (X);
	      mxFree (Y);
	      return (cr);
	    }
	  lind[0] = nbmes;
	  lind[1] = 1L;
	  lind[2] = lind[1];
	}
      switch (rscalaire)
	{
	case 0:
	case 2:
	  break;
	case 1:
	  if (scomment == 1)
	    for (i = 0; i < nbmes * fcomment; i++)
	      Yc[i] = Xc[i]; 
	  else
	    for (i = 0; i < nbmes; i++)
	      Y[i] = X[i];
	  break;
	default:
	  break;
	}

    }
  else if (type == extgType)
    {
      /* extract = 1; */    /**  ++++  **/
      if (nb_extr2 < 0)
        nbmax = nbcoord[0];
      else
        nbmax = nb_extr2 ;

      if ((X = (Double HUGE *) mxCalloc (nbmax, sizeof (Double))) == NULL)
	meser ("Alloc9.1 - ", " ", 1001, FATAL);
      if ((Y = (Double HUGE *) mxCalloc (nbmax, sizeof (Double))) == NULL)
	meser ("Alloc10.1 - ", " ", 1001, FATAL);
  if (l_rang == 1)
   {
#ifdef DEBUG
      mexPrintf ("aavnt TSRXtrRg ind0 %ld ind1 %ld \n", indices[0], indices[1]);
#endif
      cr = TSXtrRg (nomsig, ptEntree, indices, rang, nbmax, extract, &ptUnite,
	      &numv, certif, date, heure, &nbmes, &maxreel, (char HUGE *) X,
		    (char HUGE *) Y, (char *) Coord);
  }
  else
  {
#ifdef DEBUG
      mexPrintf ("avant TSRXtrX ind0 %ld ind1 %ld \n", indices[0], indices[1]);
#endif
      cr = TSXtrX (nomsig, ptEntree, indices, xab[0], xab[1], nbmax, extract,
              &ptUnite, &numv, certif, date, heure, &nbmes, &maxreel, 
              (char HUGE *) X, (char HUGE *) Y, (char *) Coord);
  }
      if (cr)
	{
	  if (l_rang == 1)
            meser ("TSXtrRg - ", nomsig, cr, NONFATAL);
	  else 
            meser ("TSXtrX - ", nomsig, cr, NONFATAL);
	  mxFree (ptEntree);
	  mxFree (X);
	  mxFree (Y);
	  return (cr);
	}
      lind[0] = nbmes;
      lind[1] = 1L;
      lind[2] = 1L;
    }
  if ((ptUnite) && (rscalaire != 1))
    {
      rscaltime = 1;
#if (client == PC )		/* scalaire = valeur temporelle ? */
      if ((!Strncmp (ptUnite->nom, "mcs", 3)) ||
	  (!Strncmp (ptUnite->nom, "MCS", 3)))
	coeff_temps = 1.0E6;

      if ((!Strncmp (ptUnite->nom, "ms", 2)) ||
	  (!Strncmp (ptUnite->nom, "MS", 2)))
	coeff_temps = 1.0E3;

      if ((!Strncmp (ptUnite->nom, "s", 1)) ||
	  (!Strncmp (ptUnite->nom, "S", 1)))
	coeff_temps = 1.0;

#else
      if (!strncasecmp (ptUnite->nom, "mcs", 3))
	coeff_temps = 1.0E6;
      if (!strncasecmp (ptUnite->nom, "ms", 2))
	coeff_temps = 1.0E3;
      if (!strncasecmp (ptUnite->nom, "s", 1))
	coeff_temps = 1.0;
#endif
    }
/* les valeurs  */
  if (scomment)
    {
      if (nouttemp > 0)
	{
	  pout[num] = charMat (lind[0], lind[1] , Yc);
	  num += 1;
	  nouttemp--;
	}
      mxFree (Yc);
    }
  else
    {
      if (nouttemp > 0)
	{
#ifdef DEBUG
  mexPrintf ("Trying to create val %ld %ld matrix \n", lind[0], lind[1]);
  mexPrintf ("rscaltime %ld\n", rscaltime);
#endif
	  pout[num] = mxCreateDoubleMatrix (lind[0], lind[1], mxREAL);
	  pr = mxGetPr (pout[num]);
	  for (j = 0; j < lind[1]; j++)
	    {
	      if (rscaltime && rscalaire)
		{
		  for (i = 0; i < lind[0]; i++)
		    pr[i + j * lind[0]] = Y[i * lind[1] + j] / coeff_temps;
		}
	      else
		{
		  for (i = 0; i < lind[0]; i++)
		    pr[i + j * lind[0]] = Y[i * lind[1] + j];
		}
	    }

#ifdef DEBUG
  mexPrintf ("fin Trying to create val %ld %ld matrix \n", lind[0], lind[1]);
#endif
	  num += 1;
	  nouttemp--;
	}
      mxFree (Y);
    }
/* les temps  */
  if (scomment)
    {
      if (nouttemp > 0)
	{
	  pout[num] = emptyMat ();
	  num += 1;
	  nouttemp--;
	}
      mxFree (Xc);
    }
  else
    {
#ifdef DEBUG
      mexPrintf ("Trying to create temps %ld %ld matrix\n", lind[0], lind[2]);
#endif
      if (nouttemp > 0)
	{
	  pout[num] = mxCreateDoubleMatrix (lind[0], lind[2], mxREAL);
	  pr = mxGetPr (pout[num]);
          if (!absolute) {
            if ( (it0 = tsignitron (&numchoc)) < 0) {
               mexPrintf ("Ignitron non disponible => temps en absolu");
               mexPrintf ("  Ignitron es beleu escondu\n");
               it0 = 0;
            }
          }

	  for (j = 0; j < lind[2]; j++)
	    {
	      if (absolute)
		{
		  if (rscalaire == 0)
		    {

		        for (i = 0; i < lind[0]; i++)
                           pr[i + j * lind[0]] = X[i * lind[1] + j] / CTPS;
		    }
		  else
        /*
         * signal scalaire : rendu tel quel si valeur != temps
         */
		    {
		      if (rscaltime)
			{
			  for (i = 0; i < lind[0]; i++)
			    pr[i + j * lind[0]] = X[i * lind[1] + j] / coeff_temps;
			}
		      else
			{
			  for (i = 0; i < lind[0]; i++)
			    pr[i + j * lind[0]] = X[i * lind[1] + j];
			}
		    }
		}
	      else
		{
		  /*    it0 = tsignitron(&numchoc);*/
		  if (rscalaire == 0)
		    {
		        for (i = 0; i < lind[0]; i++)
                           pr[i + j * lind[0]] = (X[i * lind[1] + j] - (Double) it0) / CTPS;
		    }
		  else
		    {
		      if (rscaltime)
			{
			  for (i = 0; i < lind[0]; i++)
			    pr[i + j * lind[0]] = X[i * lind[1] + j] / coeff_temps;
			}
		      else
			{
			  for (i = 0; i < lind[0]; i++)
			    pr[i + j * lind[0]] = X[i * lind[1] + j];
			}
		    }
		}
	    }
	  num += 1;
	  nouttemp--;
	}
      mxFree (X);
    }
#ifdef DEBUG
  mexPrintf ("Fin Trying to create temps %ld %ld matrix\n", lind[0], lind[2]);
#endif

/* les coordonnees si groupe  */
  if (type == homoType)
    {
      if (nouttemp > 0)
	{
#ifdef DEBUG
	  mexPrintf (" Trying to create Coord %ld %ld matrix\n", nbcoord[1], nbcoord[2]);
#endif
	  pout[num] = mxCreateDoubleMatrix (1, (nbcoord[1] /* +*/ *
				  (nbcoord[2] > 0 ? nbcoord[2] : 1)), mxREAL);
	  pr = mxGetPr (pout[num]);
	  for (j = 0; j < lind[1]; j++)
	    {
	      for (i = 0; i < 1; i++)
		pr[i + j * 1] = Coord[i * (nbcoord[1] +
				    (nbcoord[2] > 0 ? nbcoord[2] : 0)) + j];
	    }
	  /*   mxFree((char *) Coord); */
	  num += 1;
	  nouttemp--;
#ifdef DEBUG
      mexPrintf ("Fin Trying to create Coord %ld %ld matrix\n", nbcoord[1], nbcoord[2]);
#endif
	}

    }
  if ((type == extgType) && (!pansement))
    {
      if (nouttemp > 0)
	{
	  pout[num] = mxCreateDoubleMatrix (1, 1 + (indices[1] != 0 ? 1 : 0), mxREAL);
	  pr = mxGetPr (pout[num]);
	  pr[0] = Coord[(int) 0];
	  if (indices[1] != 0)
	    pr[1] = Coord[1];
	  /*    mxFree((char *) Coord); */
	  num += 1;
	  nouttemp--;
	}
    }
/* Unites , date , heure , certifs ...   */
  if (nouttemp > 0)
    {
#ifdef DEBUG
      mexPrintf ("Trying create misc  num %d nouttemp = %d\n", num, nouttemp);
#endif
      ptd = cmisc;
      for (i = 0; i < LONG_UNITE; i++)
	{
	  if (ptUnite)
	    {
	      if (i < Strlen (ptUnite->nom))
		*ptd++ = ptUnite->nom[i];
	      else
		*ptd++ = ' ';
	    }
	  else
	    *ptd++ = ' ';
	}
      ptUnite = ptUnite->ps_suivant;

      if (ptUnite)
	{
	  while (ptUnite != NULL)
	    {
	      for (i = 0; i < LONG_UNITE; i++)
		{
		  if (i < Strlen (ptUnite->nom))
		    *ptd++ = ptUnite->nom[(int) i];
		  else
		    *ptd++ = ' ';
		}
	      ptUnite = ptUnite->ps_suivant;
	    }
	}
      else
	{
	  for (i = 0; i < LONG_UNITE; i++)
	    *ptd++ = ' ';
	}
      *ptd = '\0';

      Strcat (cmisc, date);
      Strcat (cmisc, heure);
/****++++++++++++++++++++++++++++++++ MAJ Mars 2002 ****************/
      ptd = cmisc;
      while (*ptd)
         ptd++;
    
      if( indg > 0)
       sprintf(nomsig_misc,"%s%d",nomsig,indg);
      else
       strcpy(nomsig_misc,nomsig); 

      for (i = 0; i < TAILLE_NOM_DONNEE + 4; i++)
        {
          if (i < Strlen (nomsig_misc))
            *ptd++ = nomsig_misc[i];
          else
            *ptd++ = ' ';
        }
      *ptd = '\0';
      if (cooked_d)
        strcat(cmisc,"T");
      else
        strcat(cmisc,"B");
/****++++++++++++++++++++++++++++++++ MAJ Mars 2002 ****************/
      nb_certif = 1;
      if (type == homoType)
	nb_certif = nbcoord[1] * ((nbcoord[2] > 0) ? nbcoord[2] : 1);
#ifdef DEBUG
      mexPrintf ("Fin ptunite misc %ld nb_certif\n", nb_certif);
#endif

      pout[num] = mxCreateDoubleMatrix (Strlen (cmisc) + 1 + nb_certif + 1, 1, mxREAL);
      pr = mxGetPr (pout[num]);
      pr[0] = (Double) nb_certif;
      for (i = 0; i < nb_certif; i++)
	pr[1 + i] = (Double) certif[i];
      pr[1 + nb_certif] = (Double) numv;
      for (i = 0; i < Strlen (cmisc); i++)
	pr[2 + nb_certif + i] = cmisc[(int) i];

      num += 1;
      nouttemp--;
#ifdef DEBUG
      mexPrintf ("Fin misc nouttemp %d\n", nouttemp);
#endif
    }
  mxFree (ptEntree);
  return (cr);

}


void
meser (char *mes1, char *mes2, Longint numer, Longint code)
{
  mexPrintf ("tsbase : %s%s :", mes1, mes2);

  numer--;

  if ( (numer >= 0) && (numer < 1000) )
    {
      if (numer > 98)
	numer = numer - 49;
      if (numer > 65)
	numer = numer - 85;
      mexPrintf (" %s\n", err_tslib[numer]);
    }
  else
    {
      if ( (numer > ERR_MAX) || (numer < 0) )
	{
	  mexPrintf (" Erreur TSLIB (bug?) %d\n", (int) numer);
          sigaction(SIGINT, &oldact, NULL);     /* reset previous action */
	  mexErrMsgTxt ("Bad news : Contact your System Manager ");
	}
      mexPrintf (" %s\n", err_tsmat[(int) (numer - 1000)]);
    }
  if (code == FATAL) {
    sigaction(SIGINT, &oldact, NULL);     /* reset previous action */
    mexErrMsgTxt ("Oops Pecaire ... a ben-leu");
  }
}

void
FreeMemM (void *F)
{
#if (client == PC )
  {
    GLOBALHANDLE hMemory;
    if (F == NULL)
      return;
    hMemory = (GLOBALHANDLE) GlobalHandle ((UINT) SELECTOROF (F));
    GlobalUnlock (hMemory);
    GlobalFree (hMemory);
  }
#else
    free (F);
#endif
}


int
Strncmp (char *s1, char *s2, int n)
{

  if (n == 0)
    return (0);
  do
    {
      if (*s1 != *s2++)
	return (*(unsigned char *) s1 - *(unsigned char *) --s2);
      if (*s1++ == 0)
	break;
    }
  while (--n != 0);
  return (0);
}

int
lit_DC (char *nom_sig, char *date_deb, char *heure_deb, char *date_fin,
        char *heure_fin, int numchoc, mxArray * pout[], int nout)
{
  int i, j,cr, nb_s = 0, tm = 0;
  int lind[5];
  double  *X;
  double  *Y;
  float *t = NULL, *y = NULL;
  double *pr, *pr1;

  cr = TSRDC(nom_sig, date_deb, heure_deb, date_fin, heure_fin, numchoc,
              &t, &y, &nb_s, &tm);

  if( (nb_s ==0) || (tm == 0) ) {
    meserRDC  ("TSRDC - ", nom_sig, cr, NONFATAL);
    return (cr);
  }
  if( (cr < 0) ) {
     mexPrintf (" Erreur lit-DC %d\n",cr);
     meserRDC ("TSRDC - ", nom_sig, cr, NONFATAL);
     return (cr);
  }
  lind[0] = cr;/*tm/(nb_s* sizeof(float));*/
  lind[1] = nb_s;
  lind[2] = lind[1];

   pout[0] = mxCreateDoubleMatrix (lind[0], lind[1], mxREAL);
   pr = mxGetPr (pout[0]);
   pout[1] = mxCreateDoubleMatrix (lind[0], lind[2], mxREAL);
   pr1 = mxGetPr (pout[1]);

   for (j = 0; j < lind[1]; j++)
     {
       for (i = 0; i < lind[0]; i++) {
         pr[i + j * lind[0]] = (double) y[i + j* lind[0]];
	 pr1[i + j * lind[0]] = (double) t[i + j* lind[0]];
       }
     }

    num+= 1;


    num+= 1;
	
   free(t); free(y); 

return 0;
}

void
meserRDC (char *mes1, char *mes2, Longint numer, Longint code)
{
  mexPrintf ("tsbase : %s%s :", mes1, mes2);

  numer = -1 * numer;
  if ( (numer > ERR_MAX) )
    {
	mexPrintf (" Erreur TSLIB (bug?) %d\n", (int) numer);
        sigaction(SIGINT, &oldact, NULL);     /* reset previous action */
	mexErrMsgTxt ("Bad news : Contact your System Manager ");
    }
   mexPrintf (" %s\n", err_RDC[numer]);

  if (code == FATAL) {
    sigaction(SIGINT, &oldact, NULL);     /* reset previous action */
    mexErrMsgTxt ("Oops Pecaire ... a ben-leu");
  }
}

