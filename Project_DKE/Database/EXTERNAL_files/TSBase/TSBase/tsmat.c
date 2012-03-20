/*			...  tsmat.c  ...			*/
/*			....    YB    .....			*/
/*	... from an original work of J.M Moret and B.Saoutic ..	*/
/*	...    version for Matlab 4.0 (July 93)    ...		*/
/*		.....  Interface MATLAB TSLIB Yeah  .....	*/
/* 								*/
/*.....  Modifications :					*/
/*   21/07/94:fixed toupper function for character between	*/
/*            97 and 122 (a-z)  	      			*/
/*   26/04/95 : modif relative_time (version 2.0b.1)		*/
/*   09/05/95 : rajoute extract = 1 dans mexFunction 		*/
/*   09/05/95 : rajoute extract1 dans lit_brut (version 2.0b.2)	*/
/*   16/10/96 : rajoute format TEXTE           (version 2.2)    */
/*   16/10/96 : rajoute format TWIN_REEL32    (version 2.21)    */
/*   16/10/96 : rajoute format TWIN_INT16     (version 2.21)    */
/*   29/10/96 : rajoute format TDECLENC       (version 2.22)    */
/*   12/09/97 : Working for Matlab5                             */
/*   26/09/97 : rajoute format CADRAN         (version 2.23)    */
/*   26/09/97 : rajoute format SERNAM         (version 2.23)    */
/*   26/09/97 : rajoute format CHRONO         (version 2.23)    */
/*								*/
/*   29/02/08 : rajoute format T_DECODE       (version 2.25c)   */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>

#include "mex.h"
#include "tsdef.h"
#include "tsconf.h"
#include "tstype.h"
#include "tsmat.h"
#include "tsbamat.h"
#include "tserreur.h"
#include "functs.h"
#include "newarg.h"

static char     rcsid[] = "$Id$";
static char     banner[] = "tsmat V2.25c";

#if (client != PC)
char        tslib_reel = 'd';
#endif

/* For CTRL C problems */
struct sigaction        newact, oldact;
        sigset_t         newmask, oldmask;
extern int Socket_save;

static void
sig_ctrlc(int signal)
{
  sigaction(SIGINT, &oldact, NULL);         /* reset previous action */
/*  sigprocmask(SIG_SETMASK, &oldmask, NULL);*/ /* reset signal mask */
  shutdown(Socket_save,0);
  close(Socket_save);
  mexErrMsgTxt ("He pourquoi tant d'impatience  !!! ");
  return;
}
/* For CTRL C problems */

#undef toupper
toupper(c)
int c;
{
int adel;
if ((c > 96) && (c < 123))
   adel = c -'a' + 'A';
else
   adel = c;
   return( adel);
}

Longint l_rang ;      /* lecture rang par defaut */         /** +++  **/
Longint nb_extr2; /* nbre mesures quand extract = 2 */  /** +++  **/
Longint extraction,np_specif;
Longint extract ;

/*
 * global variables ****************
 */
int		num = 0;
Longint		absolute, it0;

Longint		mrows, ncols;
Longint		shotNumber ;
Longint		objectNumber;
char		*accessMode = NULL;

Longint		lit_brut(Longint, char *, Longint, mxArray *[],
                Longint [], Double []);
Longint		lit_param(Longint, char *, char *, char *, mxArray *[], int);
Longint		lit_decl(Longint, char *, Longint, mxArray *[]);
Longint		lit_entete(Longint, char *, char *, mxArray *[]);
void		meser(char *, char *, Longint, Longint);
void		FreeMemM(void *F);
void		*MemAllocM(Longint);
void		*Realloc(void *, unsigned int);
extern Longint	tsignitron(Longint *);
extern Longint	tsparse(char *, char *, Longint *, Longint *, Longint *);
char *trim (char *str);

/********* New for ARCAD ************/
#define THE_SIZE                13
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
 typedef struct zs_v_float4_ {
        Longint id_param;
        short   rang;
        float   float4;
  } ts_v_float4;
/********* New for ARCAD ************/


Longint
decodeParam(char *datain, Longint size, Longint format, dataUnion * dataout)
    {
    dataUnion       oldData;
    Register Longint   i;

    oldData.Char = &datain[0];
    switch (format)
        {
    case P_OCTET:
        dataout->Short = (short *) mxCalloc(size, sizeof(short));
        if (dataout->Short == NULL)
            return (1001);
        for (i = 0; i < size; i++)
            dataout->Short[i] = (short) oldData.Uchar[i];
        break;
    case P_CARAC:
        dataout->Short = (short *) mxCalloc(size, sizeof(short));
        if (dataout->Short == NULL)
            return (1001);
        for (i = 0; i < size; i++)
            dataout->Short[i] = (short) oldData.Char[i];
        break;
    case P_SHORT:
        dataout->Short = (short *) mxCalloc(size, sizeof(short));
        if (dataout->Short == NULL)
            return (1001);
        for (i = 0; i < size; i++)
            dataout->Short[i] = oldData.Short[i];
        break;
    case P_LONG:
        dataout->Long = (Longint *) mxCalloc(size, sizeof(Longint));
        if (dataout->Long == NULL)
            return (1001);
        for (i = 0; i < size; i++)
            dataout->Long[i] = oldData.Long[i];
        break;
    case P_FLOAT:
        dataout->Float = (float *) mxCalloc(size, sizeof(float));
        if (dataout->Float == NULL)
            return (1001);
        for (i = 0; i < size; i++)
            dataout->Float[i] = oldData.Float[i];
        break;
    case P_DOUBLE:
        dataout->Ddouble = (Double *) mxCalloc(size, sizeof(Double));
        if (dataout->Ddouble == NULL)
            return (1001);
        for (i = 0; i < size; i++)
            dataout->Ddouble[i] = oldData.Ddouble[i];
        break;
    case TWIN_INT16:
        dataout->Short = (short *) mxCalloc(2 * size, sizeof(short));
        if (dataout->Short == NULL)
            return (1001);
        for (i = 0; i < 2 * size; i++)
            dataout->Short[i] = oldData.Short[i];
        break;
    case TWIN_REEL32:
        dataout->Float = (float *) mxCalloc(2 * size, sizeof(float));
        if (dataout->Float == NULL)
            return (1001);
        for (i = 0; i < 2 * size; i++)
            dataout->Float[i] = oldData.Float[i];
        break;
    default:
        mexPrintf("Format %d not yet supported\n",format);
        mexPrintf("A tout ome sa peno ...\n");
        return (1003);
        }
    return (0);
    }


mxArray *
MATformat(Longint mrows, Longint ncols, Longint format, dataUnion tabl)
    {
    mxArray		*psort;
    Register Longint	i, j;
    Double         *pr;
    char           *chaine;

    if ( (format != F_STRING) && (format != P_TEXTE) )
        {
        psort = mxCreateDoubleMatrix(mrows, ncols, mxREAL);
        pr = mxGetPr(psort);
        }
    else
        chaine = (char *) mxCalloc(mrows * ncols + 1, sizeof(char));

    switch (format)
        {

    case P_OCTET:
        for (i = 0; i < ncols * mrows; i++)
            pr[i] = (Double) tabl.Short[i];
        return psort;

    case P_CARAC:
        for (i = 0; i < ncols * mrows; i++)
            pr[i] = (Double) tabl.Char[i];
        return psort;

    case P_SHORT:
        for (i = 0; i < ncols * mrows; i++)
            pr[i] = (Double) tabl.Short[i];
        return psort;

    case P_LONG:
        for (i = 0; i < ncols * mrows; i++)
            pr[i] = (Double) tabl.Long[i];
        return psort;

    case P_FLOAT:
        for (i = 0; i < ncols * mrows; i++)
            pr[i] = (Double) tabl.Float[i];
        return psort;

    case P_DOUBLE:
        for (i = 0; i < ncols * mrows; i++)
            pr[i] = (Double) tabl.Ddouble[i];
        return psort;

    case TWIN_INT16:
        for (j = 0; j < ncols; j++)
          { 
          for (i = 0; i < mrows; i++)
            pr[i + (j * mrows)] = (Double) tabl.Short[i * ncols + j];
          }
         return psort; 

    case TWIN_REEL32:
        for (j = 0; j < ncols; j++)
          { 
          for (i = 0; i < mrows; i++)
            pr[i + (j * mrows)] = (Double) tabl.Float[i * ncols + j];
          }
         return psort; 
    case F_STRING:
    case P_TEXTE :
/*
 * for (i = 0; i < mrows; i++) { for (j = 0; j < ncols; j++) pr[i + j *
 * mrows] = (Double) tabl.Char[j + i * ncols]; } psort->type = 1;
 */
        for (i = 0; i < mrows; i++)
            {
             j = 0;
             while( (j < ncols) && (tabl.Char[j + i * ncols] != '\0' /*NULL*/)) {
                 chaine[i + j * mrows] = tabl.Char[j + i * ncols]; 
                 j++;
             }
             if( j < ncols)
                 while( j < ncols)  {
                   chaine[i + j * mrows] = ' ';
                   j++;
             }
/*
            for (j = 0; j < ncols; j++)
                chaine[i + j * mrows] = tabl.Char[j + i * ncols];
*/
            }
        chaine[1 + mrows * ncols] = '\0';
        psort = mxCreateString(chaine);
        mxSetM(psort, mrows);
        mxSetN(psort, ncols);
        mxFree(chaine);
        return psort;
    default:
        return NULL;
        }
    }


Longint
relative_time ( const mxArray ** pin, int *argin, Longint numchoc, Longint *
absolute, Longint rangs[], Double xab[])   /** +++  **/
    {
    Longint	lg, j;
    char	*buf;
    Double	*pr;
/** +++ **/
  short flagTN = 0, SyntaxeOK = 0;
  int targin;
  char *ptd,*pts, *ptst,Typ[4];
  char ss[64];
  char rang_d[16] = {0}, rang_f[16] = {0};

  targin = *argin ; /* save input */
  targin--;
  *absolute = 0;
  extract = 1;
  np_specif = 0;

  lg = mxGetM(pin[targin]) * mxGetN(pin[targin]) + 1;
  if ((buf = (char *) mxCalloc(lg + 1, sizeof(char))) == NULL)
        meser("Alloc4.1 - ", " ", 1001, FATAL);

  mxGetString(pin[targin], buf, lg );
  for (j = 0; j < lg - 1; j++)
        buf[j] =  (char)toupper((int) buf[j]);

#ifdef DEBUG
 mexPrintf ("relative targin %d %s\n", targin, buf);   
#endif
/** +++ **/
  pts = buf;

  if (Strlen(buf) > 1 ) 
     ptst = pts+1;
  else
     ptst = pts;
#ifdef DEBUG
 mexPrintf ("*pts %c *ptst %c\n", *pts,*ptst);   
#endif

  if (  (*pts == 'E') && (*ptst =='X')  )
         return(0);     /* EXP=T=S  special case */

  if ( (*pts != '+') && (*pts != 'N') && (*pts != 'T') && (*pts != 'E') )
          return(0);

  switch (*pts)
     {
        case 'E':
        case 'N':
        case 'T':  if (isalpha((int) *(pts + 1)))
                    return(0);
                    break;

        default :   break;
     }


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
              mexPrintf ("T et N not allowed on the same line\n");
              while (*pts != ' ' && *pts != '\0')
                pts++;
              break;
            }
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
          rangs[0] = atoi (rang_d);
          rangs[1] = atoi (rang_f);
          np_specif = 1;
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
          if(*pts != '\0' /*NULL*/){
            ptd = ss;
            while (*pts != ' ' && *pts != '\0' && *pts != SEPAR_EXTR)
                *ptd++ = *pts++;
            *ptd='\0';
            extract = atoi(ss);
         }
          if(*pts != '\0' /*NULL*/)
                if (*pts  == SEPAR_EXTR)
                        pts++;

          if(*pts != '\0' /*NULL*/){
              ptd = ss;
              while (*pts != ' ' && *pts != '\0')
                *ptd++ = *pts++;
            *ptd='\0';
            nb_extr2 = atoi(ss);
           }
          else
            nb_extr2 = VAL_DEF_EXTR;
          break;

        default:
          /*printf ("%c ", *pts)
          mexPrintf ("Argument unknown");
          Ignore arguments  */
          pts++;
        }
    }
  if (SyntaxeOK) *argin -= 1;

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

  if ((ptss = strchr (tmp, SEPAR_RANG)) != NULL)        /* Rang ? */
    {
      ptss++;                   /* Rang demande */

      ptd = rang_f;             /* Rang fin */
      while (*ptss != '\0' /*NULL*/)
        *ptd++ = *ptss++;
      *ptd = '\0';

      if (rang_f[0] == '\0')    /* Rang fin non specifie */
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

      if (rang_d[0] != 'I')     /* Rang debut si pas ignitron */
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
      if (rang_d[0] == '\0')    /* Rang debut non specifie */
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
          mexPrintf("valeur de fin inferieure a celle de debut,je corrige\n");
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
  else if ((ptss = strchr (tmp, SEPAR_NBRE)) != NULL)   /* Nombre ? */
    {
      ptss++;                   /* Nombre demande  */

      ptd = rang_f;             /* Nombre fin */
      while (*ptss != '\0' /*NULL*/)
        *ptd++ = *ptss++;
      *ptd = '\0';

      if (rang_d[0] != 'I')     /* Nombre debut si pas ingnitron */
        {
          ptd = rang_d;
          ptss = ss;
          while (*ptss != SEPAR_NBRE)
            *ptd++ = *ptss++;
          *ptd = '\0';
        }

      if (rang_d[0] == '\0')    /* Nombre debut non specifie */
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

      if (rang_f[0] == '\0')    /* Nombre fin non specifie */
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
          if (rang_d[0] == 'I') /* Ignitron demande */
            sprintf(rang_d,"%g",(Double)(tsignitron (&numchoc)/1E6) );
            t = atof (rang_d) + atof (rang_f);
            sprintf (rang_f, "%g", t);
        }
    }
  else
    {                           /* pas separateur nbre ni rang  */
      extraction = 1;
      switch (type[0])
        {
        case 'N':
          if (tmp[0] != '\0'){  /* Valeur fin specifie */
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

          if (tmp[0] != '\0')   /* Valeur fin specifiee */
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



mxArray         *
emptyMat(void)
    {
    mxArray         *psort;
    psort = mxCreateDoubleMatrix(0, 0, mxREAL);
    return psort;
    }

char  *
liste( const mxArray *pin)
    {
    Register Longint	i, j;
    Longint	ntot;
    char	*List, *Lt;

    mrows = mxGetM(pin);
    ncols = mxGetN(pin);
    ntot = mrows * TAILLE_NOM_DONNEE;
    List = mxCalloc(ntot, sizeof(char));
    Lt   = mxCalloc(ntot, sizeof(char));
    mxGetString(pin,  Lt, ntot);

    for (i = 0; i < mrows; i++)
        {
        for (j = 0; j < ncols; j++)
            {
            List[i * TAILLE_NOM_DONNEE + j] = (char) Lt[i + j * mrows];
            }
        }
    for (i = 0; i < ntot; i++)
        {
        if (List[i] == ' ')
            List[i] = '\0';
        }
    mxFree(Lt);
    return List;
    }

mxArray         *
charMat(Longint mlig, Longint ncol, char *chartab)
    {
/*
 * mxArray *psort; Register short i, j; Double pr;
 * 
 * psort = mxCreateDoubleMatrix (nlig, mcol, mxREAL); psort->type = 1; for (i = 0; i <
 * mcol; i++) { for (j = 0; j < nlig; j++) psort->pr[i * nlig + j] =
 * (double) chartab[i + j * mcol]; } return psort;
 */
    int             i, j;
    mxArray         *psort;
    char           *chaine;

    chaine = (char *) mxCalloc(mlig * ncol + mlig, sizeof(char));
    for (i = 0; i < mlig; i++)
        {
        for (j = 0; j < ncol; j++)
            chaine[i + j * mlig] = chartab[i * ncol + j];
        }
    chaine[1 + ncol * mlig] = '\0';

    psort = mxCreateString(chaine);

    mxSetM(psort, mlig);
    mxSetN(psort, ncol);
    mxFree(chaine);
    return psort;
    }


/*
 * main program ************
 */

void 
mexFunction(int nout, mxArray * pout[], int nin,const mxArray * pin[])
    {
    char           *diagList = NULL;
    char           *objectList = NULL;
    char           *paramList = NULL;
    Double         *doubleShotNumber;

    Longint	i, j, k;
    Longint	iobj, ntot, i1;
    char	sep, separ[3];
    Longint	cr;
    Longint	ndiag, nsig, more_mem = 0, tot = 0;
    char	*ldiag[MAX_DIAG], *lsig[MAX_SIG], *charcom;
    Double	*pr, *pr_4 ;
    short           ii;
    int nintemp;
    int  n_tmp;
    char *p_tmp;

/*** +++ ***/
  Longint rang[2] = {0, 0};
  Double  xab[2]  = {0,0};

/* For CTRL C problems */
  newact.sa_handler = sig_ctrlc;
  sigemptyset(&newact.sa_mask);
  newact.sa_flags = 0;
  sigaction(SIGINT, &newact, &oldact);

  sigemptyset(&newmask);
  sigaddset(&newmask, SIGINT);
/* For CTRL C problems */

  l_rang = 1;     /* lecture rang par defaut */         /** +++  **/
  nb_extr2 = -1; /* nbre mesures quand extract = 2 */  /** +++  **/
  extraction = 0;
  extract =  1;

  num = 0;
  absolute = 0;
  nintemp =  nin;

#ifdef DEBUG
    mexPrintf("in %d out %d\n", nin, nout);
#endif
    if (nin < 1)
        {
        for (i = 0; i < nout; i++)
            pout[i] = emptyMat();
        mexPrintf("donnez au moins le numero de choc!\n");
        return;
        }
    if ((mxGetM(pin[0]) * mxGetN(pin[0])) != 1)
        {
        for (i = 0; i < nout; i++)
            pout[i] = emptyMat();
        mexPrintf("donnez au moins le numero de choc!\n");
        return;
        }

/* load shot number */
    shotNumber = -1;
    pr = mxGetPr(pin[0]);
    doubleShotNumber = pr;
    shotNumber = (Longint) doubleShotNumber[0];

    objectNumber = 0;
    num = 0;

    if (nin > 1)
        {
        if (mxGetM(pin[1]) > 1)
            {
/* macro call */
            if (nin < 5)
                {
                for (i = 0; i < nout; i++)
                    pout[i] = emptyMat();
                mexPrintf("Il manque des arguments (il en faut 5 au moins) !\n");;
                return;
                }

            objectNumber = mxGetM(pin[1]);      /* nbre diagnostics */
            if ((mxGetM(pin[2]) != objectNumber) | (mxGetM(pin[3]) != objectNumber) |
                (mxGetN(pin[4]) != objectNumber))
                {
                for (i = 0; i < nout; i++)
                    pout[i] = emptyMat();
                mexPrintf("Incoherence du nombre d'objets, de parametres ou de modes d'acces !");
                return;
                }
            diagList = liste(pin[1]);
            objectList = liste(pin[2]);
            paramList = liste(pin[3]);

            mrows = mxGetM(pin[4]);
            ncols = mxGetN(pin[4]);
            ntot = mrows * ncols + 1;
            accessMode = (char *) mxCalloc( ntot, sizeof(char));
            mxGetString(pin[4],  accessMode, ntot);

            if (nin > 2)
            cr = relative_time (pin, &nintemp, shotNumber, &absolute, rang, xab);
            }
        else
            {                   /* pas de macro-call */
            if (nin > 2)  /** ++++   ***/
            {
              cr = relative_time (pin, &nintemp, shotNumber, &absolute, rang, xab);
              nsig = nintemp -1 ; 
            }
          else
            nsig = nintemp -1 ; 
#ifdef DEBUG
          mexPrintf("nbre signaux %d \n",nsig);
#endif
            if (nsig > 0) {
              diagList = (char *) mxCalloc(TAILLE_NOM_DIAGNOSTIC * nsig,
                                         sizeof(char));
              objectList = (char *) mxCalloc(TAILLE_NOM_DONNEE * nsig,
                                           sizeof(char));
              paramList = (char *) mxCalloc(TAILLE_NOM_DONNEE * nsig,
                                          sizeof(char));
              accessMode = (char *) mxCalloc(nsig, sizeof(char));

            }
            for (i = 1; i <= nsig; i++)
                {
                  n_tmp = mxGetN (pin[i]) * mxGetM (pin[i]) + 1;
                  p_tmp = mxCalloc (n_tmp, sizeof (char));
                  mxGetString(pin[i], p_tmp, n_tmp);
                  k = 0;
                  for (j = 0; j < mxGetN(pin[i]); j++)
                    {
                    sep = (char) p_tmp[j];
                    if (sep == '=')
                        p_tmp[j] = '-';
                    if ((sep == '-') | (sep == ':') | (sep == ';') |
                        (sep == '*') | (sep == '|'))
                        {
                        separ[k] = (char) j;
                        k += 1;
                        }
                    if (k >= 2)
                        break;
                    }
                  if ((k == 0) | ((separ[0] == ';') & k < 2))
                    {
                    mxFree(diagList);
                    mxFree(objectList);
                    mxFree(paramList);
                    mxFree(accessMode);
                    for (i1 = 0; i1 < nout; i1++)
                        pout[i1] = emptyMat();
                    mexPrintf("mauvaise syntaxe de ");
                    for (j = 0; j < mxGetN(pin[i]); j++)
                        mexPrintf("%c", (char) p_tmp[j]);
                    mexPrintf("\n");
                    return;
                    }
                  if (p_tmp[separ[0]] != ';')
                    separ[1] = (char) mxGetN(pin[i]);
                  separ[2] = (char) mxGetN(pin[i]);
/* diagnostics */
                  for (j = 0; j < separ[0]; j++)
                    diagList[j + TAILLE_NOM_DIAGNOSTIC * (i - 1)] =
                        toupper((char) p_tmp[j]);
/* signaux */
    if( (shotNumber < NUM_CHOC_BASE) && (shotNumber > NUM_CHOC_TEST) ) {
                  for (j = separ[0] + 1; j < separ[1]; j++)
                    objectList[j - separ[0] - 1 + TAILLE_NOM_DONNEE * (i - 1)] =
                        toupper((char) p_tmp[j]);
    } else
       for (j = separ[0] + 1; j < separ[1]; j++)
          objectList[j - separ[0] - 1 + TAILLE_NOM_DONNEE * (i - 1)] = p_tmp[j];

/* parametres */
    if( (shotNumber < NUM_CHOC_BASE) && (shotNumber > NUM_CHOC_TEST) ) {
               for (j = separ[1] + 1; j < separ[2]; j++)
                  paramList[j - separ[1] - 1 + TAILLE_NOM_DONNEE * (i - 1)] =
                       toupper((char) p_tmp[j]);
      } else
               for (j = separ[1] + 1; j < separ[2]; j++)
               paramList[j - separ[1] - 1 + TAILLE_NOM_DONNEE * (i - 1)] = p_tmp[j];
         
                accessMode[i - 1] = (char) p_tmp[separ[0]];
                }
            objectNumber = nsig;/* nbre de signaux demandes */
            mxFree(p_tmp);
            }
        }
    if (objectNumber == 0)      /* pas de signaux demandes
                                 * (tsmat(ShotNumber)) */
        {
/* Renvoie tous les diagnostics et les signaux du choc  */
/* Rangement NomDiag1 NomSignaux NonDiag2 NomSignaux... */
        cr = TSLDiag(shotNumber, &ndiag, ldiag);
        mexPrintf("Il a %ld diagnostics, patience ... \n", ndiag);
        if (cr != 0)
            meser("TSLDiag - ", " ", cr, FATAL);
   /** MAJ FEV 2002 ****/
   /**     if ((charcom = (char *) MemAllocM(ndiag * (TAILLE_NOM_DIAGNOSTIC+1))) == NULL) **/
        if ((charcom = (char *) mxCalloc(2*ndiag,
                (TAILLE_NOM_DIAGNOSTIC+1+(TAILLE_NOM_DONNEE * 50)))) == NULL)
            meser("Alloc1 - ", " ", 1001, FATAL);
        Strcpy(charcom, "\0");
        for (i = 0; i < ndiag; i++)
            {
            cr = TSLSig(shotNumber, ldiag[i], &nsig, lsig);
#ifdef DEBUG
            mexPrintf("diag %s il a %ld nsig \n", ldiag[i], nsig);
#endif
            if (cr != 0) {
                /** MAJ FEV 2002 ****/
                /* FreeMemM((void *) charcom) ;*/
                mxFree(charcom);
                meser("TSLSig - ", ldiag[i], cr, FATAL);
            }
            Strcat(charcom, ldiag[i]);
            for (ii = 0; ii < (TAILLE_NOM_DIAGNOSTIC - Strlen(ldiag[i])); ii++)
                Strcat(charcom, " ");
            tot += 1;
            /** MAJ FEV 2002 ****/
            /* more_mem += nsig * (TAILLE_NOM_DONNEE+1); */
            /* if ((charcom = (char *) Realloc((void *) charcom, (unsigned int)
                    (ndiag * TAILLE_NOM_DIAGNOSTIC + more_mem))) == NULL)
                meser("Alloc2 - ", " ", 1001, FATAL);
            */
            for (j = 0; j < nsig; j++)
                {
                Strcat(charcom, lsig[j]);
                for (ii = 0; ii < (TAILLE_NOM_DONNEE - Strlen(lsig[j])); ii++)
                    Strcat(charcom, " ");
                tot += 1;
                }
            }
        pout[num] = charMat(tot, TAILLE_NOM_DONNEE, charcom);
        num += 1;
        /* FreeMemM((void *) charcom);  ******/
         mxFree (charcom);
        }

    mexPrintf("%s  Choc : %d \n", banner, shotNumber);
/* loop on the requested signals */
    for (iobj = 0; iobj < objectNumber; iobj++)
        {
        switch (accessMode[iobj])
            {
        case '-':
        case ':':
            cr = lit_brut(shotNumber, objectList + TAILLE_NOM_DONNEE * iobj,
                          (accessMode[iobj] == '-' ? COOKED : RAW), pout,rang,
                          xab);   /** ++++  **/

            if (cr != 0)
                {
                pout[num] = emptyMat();
                num += 1;
                pout[num] = emptyMat();
                num += 1;
                }

            break;
        case '*':
/* entete signal */
            cr = lit_entete(shotNumber, diagList + TAILLE_NOM_DIAGNOSTIC * iobj,
                            objectList + TAILLE_NOM_DONNEE * iobj, pout);
            if (cr != 0)
                {
                pout[num] = emptyMat();
                num += 1;
                }

            break;
        case ';':
/* parametres */
           cr = lit_param(shotNumber, diagList + (TAILLE_NOM_DIAGNOSTIC * iobj),                  objectList + (TAILLE_NOM_DONNEE * iobj),
                  paramList + (TAILLE_NOM_DONNEE * iobj), pout, nout);

#ifdef DEBUG
mexPrintf("Aprs appel lit_param cr = %d num = %d\n",cr,num);
#endif
            if (cr != 0)
                {
                pout[num] = emptyMat();
                num += 1;
                }
            break;
        case '|':
/* declenche */
            cr = lit_decl(shotNumber, diagList + TAILLE_NOM_DIAGNOSTIC * iobj,
                      atol(objectList + TAILLE_NOM_DONNEE * iobj), pout);
            if (cr != 0)
                {
                pout[num] = emptyMat();
                num += 1;
                }
            break;
        default:
            meser(" ", " ", accessMode[iobj], FATAL);
            for (i1 = 0; i1 < nout; i1++)
                pout[i1] = emptyMat();
            }
        }
    if (objectNumber > 0) {
    if(diagList)
        mxFree(diagList);
    if(objectList)
       mxFree(objectList);
    if(paramList)
       mxFree(paramList);
    if(accessMode)
       mxFree(accessMode);
    }
#ifdef DEBUG
mexPrintf("FINIFINI num %d nout %d \n", num, nout);
#endif
    sigaction(SIGINT, &oldact, NULL);         /* reset previous action */
    for (i = num; i < nout; i++)
        pout[i] = emptyMat();
    }


Longint
lit_brut(Longint numchoc, char *nomsigp, Longint extract_type, mxArray * pout[],
         Longint rang[], Double xab[])  /***  ++++  ***/
    {
    Register Longint   i, j;
    Longint	type,nbmes=0,nbmax = 0;
    Longint	nbmesgr[3], lind[5], cr, cr1, numv, certif[MAX_CERTIF], rgrp;
   /* Longint	rang[2], indices[2], maxreel, extract, nbcoord[MAX_COORD];*/
    Longint	indices[2], maxreel, nbcoord[MAX_COORD], extract1; /** +++  **/
    Double HUGE	*X, HUGE * Y, Coord[MAX_SIG];
    char	date[TAILLE_DATE], heure[TAILLE_HEURE];
    char	nomsig[TAILLE_NOM_DONNEE];
/********* New for ARCAD ************/
  /* pS_DescDon ptDescDon; */
   ts_donnee *ptDescDon;
/********* New for ARCAD ************/
    pS_Entree	ptEntree;
    pS_Unite	ptUnite;
    Double HUGE    *pr;
    Longint occur = 0;

    tsparse(nomsigp, nomsig, indices, &rgrp, &occur);
#ifdef DEBUG
    mexPrintf("Dans lit_brut\n");
#endif

    ptEntree = (pS_Entree) mxCalloc(1, sizeof(struct S_Entree));
    ptEntree->union_var.lval = numchoc;
    ptEntree->ps_suivant = NULL;

    for (i = 0; i < MAX_COORD; i++)
        nbcoord[i] = 0;
    cr = TSExist(nomsig, ptEntree, nbcoord, &numv, certif, date, heure);
    if (cr || (nbcoord[0] == 0))/* ncoord[0]= 0 pas de donnees */
        {
/***** NEW      *****/
        if (cr)
            {
            cr1 = TSExist("num_choc", ptEntree, nbcoord, &numv, certif, date, heure);
            if (cr1)
                {               /* le choc n'existe pas */
                mexPrintf("TSExist - %s Choc absent\n", nomsig);
                mxFree(ptEntree);
                return (cr);
                }
            }
/***** NEW      *****/
        meser("TSExist - ", nomsig, ((cr != 0) ? cr : 9), NONFATAL);
        mxFree(ptEntree);
        return (cr);
        }

/* nomsig est une donnee connue ? */
/********* New for ARCAD ************/
    /* cr = TSDescDon(nomsig, &ptDescDon); */
    cr = TSDescDon_choc(nomsig, numchoc, occur, &ptDescDon);
/********* New for ARCAD ************/
    if (cr)
        meser("TSDescDon_Choc - ", nomsig, cr, FATAL);
    if ((ptDescDon->type_donnee >> S_SIMPLE) & 1)      /* signal simple */
        type = sigType;
    else if ((ptDescDon->type_donnee >> D_GHOMO) & 1)  /* groupe homogene */
        type = homoType;
    else
        meser("Who are you ?", nomsig, 1002, FATAL);
    FreeMemM((void *) ptDescDon); 

    if (rgrp)
        type = extgType;

    nbmax = nbcoord[0];
 if (rang[0] == 0)
    rang[0] = 1;  /** ++++ ***/

#if (client == PC )
  if (nbcoord[0] > MAXDATAPC)
    {
      if (rang[1] == 0)
        rang[1] = MAXDATAPC;    /** +++ **/
      mexPrintf ("==> Attention plus de 100000 mesures on ne peut <==\n");
      mexPrintf ("==> lire que 100000 mesures maximum sur les PCs <==\n");
      mexPrintf ("==> pour plus de renseignements Y.Buravand 23.42 <==\n");
    }
  else if ( extraction || rang[1] == 0 || np_specif == 0)
    rang[1] = nbcoord[0];       /** +++ **/
#else
  if ( extraction  || rang[1] == 0 || np_specif == 0)
    rang[1] = nbcoord[0];       /** +++ **/
#endif

    mexPrintf("lisant %s ! \n", nomsig);

    extract1 = extract + extract_type * 10;

    if (type == homoType)
        {

int nbmax_sv;
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
        if ((X = (Double HUGE *) mxCalloc(nbmax, sizeof(Double))) == NULL)
            meser("Alloc3 - ", " ", 1001, FATAL);
        if ((Y = (Double HUGE *) mxCalloc(nbmax, sizeof(Double))) == NULL)
            meser("Alloc4 - ", " ", 1001, FATAL);

/** ++++   **/
  if (l_rang == 1)
   {
#ifdef DEBUG
 mexPrintf ("avant TSGrpRg choc = %d\n", ptEntree->union_var.lval);
 mexPrintf ("avant TSGrpRg rangs %ld %ld nbmax %ld\n", rang[0], rang[1], nbmax);
 mexPrintf ("avant TSGrpRg nbcoord %ld %ld %ld extract1=%d \n", nbcoord[0], nbcoord[1], nbcoord[2],extract1);
#endif
        cr = TSGrpRg(nomsig, ptEntree, rang, nbmax_sv, extract1, &ptUnite,
                &numv, certif, date, heure, nbmesgr, &maxreel, (char *) X,
                     (char *) Y, (char *) Coord);
  }
  else
  {
    cr = TSGrpX (nomsig, ptEntree, xab[0], xab[1], nbmax_sv, extract1, &ptUnite,
            &numv, certif, date, heure, nbmesgr, &maxreel, (char HUGE *)X,
            (char HUGE *) Y,  (char *) Coord);
  }
        if (cr)
            {
          if (l_rang ==1)
            meser ("TSGrpRg - ", nomsig, cr, NONFATAL);
          else
            meser ("TSGrpX - ", nomsig, cr, NONFATAL);
            mxFree(ptEntree);
            mxFree(X);
            mxFree(Y);
            return (cr);
            }
        lind[0] = nbmesgr[0];
        lind[1] = nbcoord[1] * (nbcoord[2] != 0 ? nbcoord[2] : 1);
        }
    else if (type == sigType)
        {
        if (nb_extr2 < 0 )
        nbmax = nbcoord[0];
        else
        nbmax = nb_extr2 ;

       if(nbmax > 100000)
       mexPrintf("What a big signal !! be quiet please data are coming soon ...\n");

        if ((X = (Double HUGE *) mxCalloc(nbmax, sizeof(Double))) == NULL)
            meser("Alloc5 - ", " ", 1001, FATAL);
        if ((Y = (Double HUGE *) mxCalloc(nbmax, sizeof(Double))) == NULL)
            meser("Alloc6 - ", " ", 1001, FATAL);
 if (l_rang == 1)
 {
#ifdef DEBUG
mexPrintf ("avant TSRSIGRg rangs %ld %ld nbmax %ld extract1 %d nb_extr2 %d extraction %d\n", rang[0], rang[1], nbmax,extract1,nb_extr2,extraction);
#endif
        cr = TSRSigRg(nomsig, ptEntree, rang, nbmax, extract1, &ptUnite,
                &numv, certif, date, heure, &nbmes, &maxreel, (char *) X,
                      (char *) Y);
#ifdef DEBUG
mexPrintf ("apres TSRSigRg cr %ld nbmes %d maxreel %d\n", cr,nbmes,maxreel);
#endif
}
else
{
#ifdef DEBUG
mexPrintf ("avant TSRSigX xab %g %g nbmax %ld\n", xab[0], xab[1], nbmax);
#endif
      cr = TSRSigX (nomsig, ptEntree, xab[0], xab[1], nbmax, extract1,
             &ptUnite, &numv, certif, date, heure, &nbmes, &maxreel,
             (char HUGE *) X, (char HUGE *) Y);
 }
        if (cr)
            {
            if(l_rang == 1)
                 meser ("TSRSigRg - ", nomsig, cr, NONFATAL);
              else
                 meser ("TSRSigX - ", nomsig, cr, NONFATAL);
            mxFree(ptEntree);
            mxFree(X);
            mxFree(Y);
            return (cr);
            }
        lind[0] = nbmes;
        lind[1] = 1L;
        }

    else if (type == extgType)
        {
        if (nb_extr2 < 0)
          nbmax = nbcoord[0];
        else
          nbmax = nb_extr2 ;

        if ((X = (Double HUGE *) mxCalloc(nbmax, sizeof(Double))) == NULL)
            meser("Alloc7 - ", " ", 1001, FATAL);
        if ((Y = (Double HUGE *) mxCalloc(nbmax, sizeof(Double))) == NULL)
            meser("Alloc8 - ", " ", 1001, FATAL);
  if (l_rang == 1)
   {
#ifdef DEBUG
      mexPrintf ("aavnt TSRXtrRg ind0 %ld ind1 %ld \n", indices[0], indices[1]);
#endif
        cr = TSXtrRg(nomsig, ptEntree, indices, rang, nbmax, extract1, &ptUnite,
                &numv, certif, date, heure, &nbmes, &maxreel, (char *) X,
                     (char *) Y, (char *) Coord);
  }
  else
  {
#ifdef DEBUG
      mexPrintf ("avant TSRXtrX ind0 %ld ind1 %ld \n", indices[0], indices[1]);
#endif
      cr = TSXtrX (nomsig, ptEntree, indices, xab[0], xab[1], nbmax, extract1,
              &ptUnite, &numv, certif, date, heure, &nbmes, &maxreel,
              (char HUGE *) X, (char HUGE *) Y, (char *) Coord);
  }
        if (cr)
            {
            if (l_rang == 1)
              meser ("TSXtrRg - ", nomsig, cr, NONFATAL);
            else
              meser ("TSXtrX - ", nomsig, cr, NONFATAL);
            mxFree(ptEntree);
            mxFree(X);
            mxFree(Y);
            return (cr);
            }
        lind[0] = nbmes;
        lind[1] = 1L;
        }

    mxFree(ptEntree);
    pout[num] = mxCreateDoubleMatrix(lind[0], lind[1], mxREAL);
    pr = mxGetPr(pout[num]);
    for (j = 0; j < lind[1]; j++)
        {
        for (i = 0; i < lind[0]; i++)
            pr[i + j * lind[0]] = Y[i * lind[1] + j];
        }
    mxFree(Y);
    num += 1;

    pout[num] = mxCreateDoubleMatrix(lind[0], lind[1], mxREAL);
    pr = mxGetPr(pout[num]);
    /*    if (!absolute)
              it0 = tsignitron (&numchoc);
    */
    if (!absolute) {
       if ( (it0 = tsignitron (&numchoc)) < 0) {
          mexPrintf ("Ignitron non disponible => temps en absolu");
          mexPrintf ("Ignitron es beleu escondu\n");
          it0 = 0;
       }
    }

    for (j = 0; j < lind[1]; j++)
        {
        if (absolute)
            {
               for (i = 0; i < lind[0]; i++)
                  pr[i + j * lind[0]] = X[i * lind[1] + j] / CTPS;
            }
        else
            {
              for (i = 0; i < lind[0]; i++) 
                pr[i + j * lind[0]] = (X[i * lind[1] + j] - (double) it0) / CTPS;
            }
        }
    mxFree(X);
    num += 1;
    return (0);

    }

Longint
lit_decl(Longint numchoc, char *nomdec, Longint occur, mxArray * pout[])
    {
    Longint cr;
    float   dt_rendu;
    Double  *pr;

#ifdef DEBUG
    mexPrintf("Dans lit_decl\n");
#endif
    cr = TSRqdecl(numchoc, trim(nomdec), occur, &dt_rendu);
    if (cr)
        {
        meser("TSRqdecl - ", nomdec, cr, NONFATAL);
        return (cr);
        }
    else
        {
        pout[num] = mxCreateDoubleMatrix(1, 1, mxREAL);
        pr = mxGetPr(pout[num]);
          pr[0] = (Double) dt_rendu / (Double) 1.0e6;

        num += 1;
        }
    return (0);
    }

Longint
lit_param(Longint numchoc, char *nomdiag, char *nomobj, char *nomparam,
          mxArray * pout[], int nout)
    {
    Longint	cr;
    Longint	nb_rep, fparm, i;
    Longint	ncol, nlig;
    char	*buffer = NULL;
    char	chocstr[8];
    dataUnion	dataout;

/*    buffer = (char *) mxCalloc((MAX_PARAM * 64), sizeof(char));
    strcpy(buffer,"Pour une meilleure compatibilite");
*/
   
#ifdef DEBUG
mexPrintf("dans lit_param %d %s %s %s\n", numchoc,nomdiag,nomobj,nomparam);
#endif
    cr = TSRqParm(numchoc, nomdiag, nomobj, trim(nomparam),(int) MAX_PARAM,
                   &buffer, &nb_rep, &fparm);
#ifdef DEBUG
mexPrintf("apres lit_param cr = %d format = %d nbrep %d\n", cr,fparm,nb_rep);
mexPrintf ("val = %d \n",*(int *)buffer);
#endif
    if (cr != 0)
        {
        if (cr < 0)
            {
            switch (cr)
                {
            case -1:
                sprintf(chocstr, "%d", numchoc);
                meser("TSRqparm - ", chocstr, cr, NONFATAL);
                break;
            case -2:
                meser("TSRqparm - ", nomdiag, cr, NONFATAL);
                break;
            case -3:
                meser("TSRqparm - ", nomobj, cr, NONFATAL);
                break;
            case -4:
                meser("TSRqparm - ", nomparam, cr, NONFATAL);
                break;
            default:
                meser("TSRqparm - ", "??", cr, NONFATAL);
                }
            } else {
              switch (cr)
                {
                  case 202: 
                       sprintf(chocstr, "%d", numchoc);
                       meser("TSRqparm - ", chocstr, cr, NONFATAL);
                       break;
                  case 203: 
                       sprintf(chocstr, "%d", numchoc);
                       meser("TSRqparm - ", chocstr, cr, NONFATAL);
                       break;
                  case 204: 
                       meser("TSRqparm - ", nomdiag, cr, NONFATAL);
                       break;
                  case 207: 
                       meser("TSRqparm - ", nomobj, cr, NONFATAL);
                       break;
                  case 208: 
                       meser("TSRqparm - ", nomparam, cr, NONFATAL);
                       break;
                  default:
                       meser("TSRqparm - ", "??", cr, NONFATAL);
                }
            }

        return (cr);
        }
   if( nb_rep > MAX_PARAM ){
      mexPrintf("Attention le nombre de valeurs du parametre %s a ete reduit a %d valeurs\n",nomparam, MAX_PARAM);
      mexPrintf("mail buravand please  pour avoir %d valeurs",nb_rep);
      mexPrintf("Sies un boun ome !!!");
   }

/* there is a trick with 7 but all is a trick here 
    if (fparm == 7)
        fparm = 3;  never used ***/
   
    if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
    switch (fparm) { /* chocs Pollux */
       case 10 :  /* STRAT PIL */
                fparm = STRAT_PILOTE;
                break;
       case 16 : /* TDECLENC */
                fparm = T_DECLENC;
                break;
       default : 
                break;
    } else  /* Arcad */
      if (fparm == P_OCTET) /* Needed for decodeParam */
           fparm = P_SHORT;

    if ( (fparm != P_CARAC) && (fparm != P_TEXTE) && (fparm != T_DECLENC) &&
           (fparm != STRAT_PILOTE) && (fparm != CADRAN)  && (fparm != SERNAM) &&
           (fparm != CHRONO) && (fparm != FLOAT4_CHAR64)
        && (fparm != INT2_CHAR64) && (fparm != L_DIAG) && 
           (fparm != VOIE_GAIN) /* 29 fevrier*/ && (fparm != T_DECODE)  )
        {
        cr = decodeParam(buffer, nb_rep, fparm, &dataout);
        if (cr != 0)
            {
            for (i = num; i < nout; i++)
                pout[i] = emptyMat();
            meser("decodeParam - ", nomparam, cr, FATAL);
            }
         switch(fparm) {
          
           case TWIN_INT16:
           case TWIN_REEL32:
                    nlig = nb_rep;
                    ncol = 2;
                    break;
           default: 
                    nlig = 1;
                    ncol = nb_rep;
                    break;
         }  /* end switch */
        }
    else
        {
         switch(fparm) {
          /* 8avril*/
          case VOIE_GAIN: {

          char  *pts, *ptd ;
          float *ptdf;
          int i, j;
          Double   *pr;

          nlig = nb_rep ;
          ncol =  3;

          if ((ptd = (char *) mxCalloc (nb_rep, sizeof (short) * 2 )) == NULL)
             meser ("AllocVG1 - ", " ", 1001, FATAL); 
          if ((ptdf = (float *) mxCalloc (nb_rep, sizeof (float))) == NULL)
             meser ("AllocVG2 - ", " ", 1001, FATAL); 

          pts = buffer;

          for(i = 0, j=0; i < nb_rep * ncol; i+= ncol, j++) {
            memcpy(&ptd[i], pts, sizeof(short)); 
            pts +=  sizeof(short);
            memcpy(&ptd[i + 1], pts, sizeof(short)); 
            pts +=  sizeof(short);
            memcpy(&ptdf[j], pts, sizeof(float)); 
            pts += sizeof(float);
          }

          pout[num] = mxCreateDoubleMatrix( nlig, ncol, mxREAL);
          pr = mxGetPr(pout[num]); 
          if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
          {
              /* Old shots */ 
 
          } else {
          for (j = 0; j < ncol-1; j++)
            {
              for (i = 0; i < nlig; i++)
                pr[i + j * nlig] = (Double) ptd[i * ncol + j];
            }

           for (i = 0; i < nlig; i++)
                pr[i + (ncol -1) * nlig] = (Double) ptdf[i];
          }
          mxFree(ptd);
          num += 1; 
          break;
          }


          case P_CARAC :
          if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
                        ncol = 16;     /* Taille max caracteres PREPA */
          else
                        ncol = THE_SIZE;     /* Taille max caracteres PREPA */

                        nlig = nb_rep ;
                        fparm = F_STRING;
                        dataout.Char = &buffer[0];
                        break;
          case P_TEXTE :
                        ncol = 201;    /* format texte maxi */
                        nlig = nb_rep ;
                        dataout.Char = &buffer[0];
                        break;

          case L_DIAG : {
          char  *Nom_diag, *pts ;
          int i,j, lf = THE_SIZE;

          nlig = nb_rep;
          if ((Nom_diag = (char *) mxCalloc (nb_rep, THE_SIZE)) == NULL)
                            meser ("AllocTdeclM - ", " ", 1001, FATAL);
          /* if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
                   never goes here
          else  */
             ncol =  THE_SIZE;    /* THE_SIZE */
          pts = buffer;

          for (i = 0; i < nlig; i++)
           {
             j = 0;
             while( (j < ncol) && (pts[i * (ncol) + j] != '\0' /*NULL*/)) {
                 Nom_diag[i + j * nlig] = pts[i * (ncol) + j];
                 j++;
             }
             if( j < lf)
                 while( j < lf)  {
                   Nom_diag[i + j * nlig] = ' ';
                   j++;
             }
      /* Thanks to PH Moreau the 1st user of this ceartainly not tested case */
      /*     j = 0;
             while( (j < ncol) && (pts[i * (ncol) + ncol+ j] != NULL)) {
                   Nom_diag[(nlig*lf) +i + j * nlig] =
                                pts[i * (ncol) +ncol + j];
                    j++;
                }

             if( j < lf)
                 while( j < lf)  {
                   Nom_diag[(nlig*lf) + i + j * nlig] = ' ';
                   j++;
                 }
        */
             }
              pout[num] = mxCreateString (Nom_diag);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], lf);
              num += 1;
              mxFree (Nom_diag);
             }
              break;



          case STRAT_PILOTE : {
          char  *Nom_decl, *pts ;
          int i,j, lf = THE_SIZE;

          nlig = nb_rep;
          if ((Nom_decl = (char *) mxCalloc (2 * nb_rep, THE_SIZE)) == NULL)
                            meser ("AllocTdeclM - ", " ", 1001, FATAL);
          if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
             ncol = 8;    /* THE_OLD_SIZE */
          else
             ncol = THE_SIZE;    /* THE_SIZE */
          pts = buffer;

          for (i = 0; i < nlig; i++)
           {
             j = 0;
             while( (j < ncol) && (pts[i * (ncol + ncol) + j] != '\0' /*NULL*/)) {
                 Nom_decl[i + j * nlig] = pts[i * (ncol + ncol) + j]; 
                 j++;
             }
             if( j < lf)
                 while( j < lf)  {
                   Nom_decl[i + j * nlig] = ' ';
                   j++;
             }
             j = 0;
             while( (j < ncol) && (pts[i * (ncol + ncol) + ncol+ j] != '\0' /*NULL*/)) {
                   Nom_decl[(nlig*lf) +i + j * nlig] =
                                pts[i * (ncol + ncol) +ncol + j];
                    j++;
                }
                   
             if( j < lf)
                 while( j < lf)  {
                   Nom_decl[(nlig*lf) + i + j * nlig] = ' ';
                   j++;
                 }

             }
              pout[num] = mxCreateString (Nom_decl);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], 2 * lf);
              num += 1;
              mxFree (Nom_decl);
             }
              break;

          case T_DECLENC : {
             char  *Nom_decl, *pts ;
             float *pt_v;
             int i, j , sZterm, *pt_i;
             Double   *pr;

             nlig = nb_rep ;

             if ((Nom_decl = (char *) mxCalloc (nb_rep, THE_SIZE +1)) == NULL)
                             meser ("AllocTdeclM - ", " ", 1001, FATAL);
             if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
              {
               if ((pt_i = (int *) mxCalloc ( nb_rep, sizeof (int))) == NULL)
                             meser ("AllocTdecli - ", " ", 1001, FATAL); 

               pts = buffer;
               for(i = 0; i < nb_rep; i++) {
                  pts += 8;
                  memcpy(&pt_i[i], pts, sizeof(int));
                  pts += sizeof(int);
               }
               for(nb_rep = 0; i > 0; i--)
                 if(pt_i[i] == 0)
                    nlig--;
               
              }
              else {
               if ((pt_v = (float *) mxCalloc (nb_rep, sizeof (float))) == NULL)
                             meser ("AllocTdeclf - ", " ", 1001, FATAL); 

               pts = buffer;
               for(i = 0; i < nb_rep; i++) {
                  pts += THE_SIZE;
                  memcpy(&pt_v[i], pts, sizeof(float));
                  pts += sizeof(float);
               }
             }


             if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               ncol = 8;    /* THE_OLD_SIZE */
             else
               ncol = THE_SIZE;    /* THE_SIZE */
             pts = buffer;

             for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < ncol; j++) {
                   if( (pts[i * (ncol + 4) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[i * (ncol + sizeof(float)) + j] = ' ';
                          sZterm = 1;
                   }
                  Nom_decl[i + j * nlig] = pts[i * (ncol + sizeof(float)) + j]; 
                }
              }
              Nom_decl[nlig * ncol] = '\0';   
              pout[num] = mxCreateString (Nom_decl);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], ncol);
              num += 1;
              mxFree (Nom_decl);

              ncol =  1;
              pout[num] = mxCreateDoubleMatrix( nlig, ncol, mxREAL);
              pr = mxGetPr(pout[num]); 
              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               {
                 for (j = 0; j < ncol; j++)
                   {
                      for (i = 0; i < nlig; i++)
                         pr[i + j * nlig] = (Double) pt_i[i * ncol + j];
                       mxFree(pt_i);
                   }
 
               } else {
                  for (j = 0; j < ncol; j++)
                    {
                      for (i = 0; i < nlig; i++)
                         pr[i + j * nlig] = (Double) pt_v[i * ncol + j];
                       mxFree(pt_v);
                    }
               }
               num += 1; 
             }
             break; /* end T_DECLENC */

          case T_DECODE: {
             char  *Type, *decl1, *decl2, *Comm, *pts ;
             short *numero, *polar;
             Longint *duree;
             int i, j ,sZterm, *pt_i;
             int ofs = 2 + 2*L_NOM_DECLENCHE+2*sizeof(short)+sizeof(Longint)+L_COMMENTAIRE;
             Double   *pr;

             nlig = nb_rep ;

             if ((Type = (char *) mxCalloc (nb_rep, 3)) == NULL)
                             meser ("AllocTDecode1 - ", " ", 1001, FATAL);
             if ((decl1=(char *) mxCalloc(nb_rep, L_NOM_DECLENCHE+1))==NULL)
                             meser ("AllocTDecode2 - ", " ", 1001, FATAL);
             if ((decl2=(char *) mxCalloc (nb_rep, L_NOM_DECLENCHE+1))==NULL)
                             meser ("AllocTDecode3 - ", " ", 1001, FATAL);
             if ((Comm = (char *) mxCalloc (nb_rep, L_COMMENTAIRE +1)) == NULL)
                             meser ("AllocTDecode4 - ", " ", 1001, FATAL);

             if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
              { /* Old shots */
                /*  TODO  */
                meser ("T_DECODE old shot not yet implemented - ", " ", 1001, FATAL);
              }
              else {
              if ((numero = (short *) mxCalloc (nb_rep, sizeof (short)))==NULL)
                             meser ("AllocTDecode5 - ", " ", 1001, FATAL);
              if ((polar = (short *) mxCalloc (nb_rep, sizeof (short)))==NULL)
                             meser ("AllocTDecode6 - ", " ", 1001, FATAL);
              if ((duree = (Longint *) mxCalloc (nb_rep, sizeof (Longint)))=='\0')
                             meser ("AllocTDecode7 - ", " ", 1001, FATAL);

              /* numero */
              pts = buffer + 2 ;
              for (i = 0; i < nb_rep; i++) {
                  memcpy(&numero[i], pts, sizeof(short));
                  pts += ofs;
              }

              /* polar */
              pts = buffer + 4 ;
              for (i = 0; i < nb_rep; i++) {
                  memcpy(&polar[i], pts, sizeof(short));
                  pts += ofs;
                }

              /* duree */
              pts = buffer + 2 + 2 * sizeof(short) + 2 * L_NOM_DECLENCHE ;
              for (i = 0; i < nb_rep; i++) {
                  memcpy(&duree[i], pts, sizeof(Longint));
                  pts += ofs;
                }
             }

             if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               ncol = 8;    /* THE_OLD_SIZE */
              else
               ncol = THE_SIZE;    /* THE_SIZE */

              /*  Type  */
              pts = buffer;
              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < 2; j++) {
                   if( (pts[(i * ofs) + j] == '\0') || sZterm ) {
                          pts[(i * ofs) + j] = ' ';
                          sZterm = 1;
                   }
                   Type[i + j * nlig] = pts[(i * ofs) + j];
                }
              }
              Type[nlig * 2] = '\0';

              pout[num] = mxCreateString (Type);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], 2);
              mxFree (Type);
              num += 1;

              /* numero */
              pout[num] = mxCreateDoubleMatrix( nlig, 1, mxREAL);
              pr = mxGetPr(pout[num]);
              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               {
                 /* TODO */
                 meser ("T_DECODE : numero for old shot not implemented - ", " "
, 1001, FATAL);
               } else {
                  for (j = 0; j < 1; j++)
                    {
                      for (i = 0; i < nlig; i++)
                         pr[i + j * nlig] = (Double) numero[i + j];
                    }
                  mxFree(numero);
                  num += 1;
              }

              /* polar */
              pout[num] = mxCreateDoubleMatrix( nlig, 1, mxREAL);
              pr = mxGetPr(pout[num]);
              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               {
                 /* TODO */
                 meser ("T_DECODE : polar for old shot not implemented - ", " ",
 1001, FATAL);
               } else {
                  for (j = 0; j < 1; j++)
                    {
                      for (i = 0; i < nlig; i++)
                         pr[i + j * nlig] = (Double) polar[i + j] ;
                    }
                  mxFree(polar);
                  num += 1;
               }

              /* declenche1 */
              pts = buffer + 2 + 2 * sizeof(short);

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < L_NOM_DECLENCHE; j++) {
                   if( (pts[(i * ofs) + j] == '\0') || sZterm ) {
                          pts[(i * ofs) + j] = ' ';
                          sZterm = 1;
                   }
                   decl1[i + j * nlig] = pts[(i * ofs) + j];
                }
              }
              decl1[nlig * L_NOM_DECLENCHE] = '\0';

              pout[num] = mxCreateString (decl1);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], L_NOM_DECLENCHE);
              num += 1;
              mxFree (decl1);

             /* declenche2 */
              pts = buffer + 2 + 2 * sizeof(short) + L_NOM_DECLENCHE;

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < L_NOM_DECLENCHE; j++) {
                   if( (pts[(i * ofs) + j] == '\0') || sZterm ) {
                          pts[(i * ofs) + j] = ' ';
                          sZterm = 1;
                   }
                   decl2[i + j * nlig] = pts[(i * ofs) + j];
                }
              }
              decl2[nlig * L_NOM_DECLENCHE] = '\0';

              pout[num] = mxCreateString (decl2);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], L_NOM_DECLENCHE);
              mxFree (decl2);
              num += 1;

              /* Duree */
              pout[num] = mxCreateDoubleMatrix( nlig, 1, mxREAL);
              pr = mxGetPr(pout[num]);
              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               {
                 /* TODO */
                 meser ("T_DECODE : duree for old shot not implemented - ", " ",
 1001, FATAL);
               } else {
               for (j = 0; j < 1; j++)
                {
                  for (i = 0; i < nlig; i++)
                    pr[i + j * nlig] = (Double) duree[i + j];
                }
                mxFree(duree);
                num += 1;
               }


              /*  Commentaire  */
              pts = buffer+2+2*sizeof(short)+2*L_NOM_DECLENCHE+sizeof(Longint);

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < L_COMMENTAIRE; j++) {
                   if( (pts[(i * ofs) + j] == '\0') || sZterm ) {
                          pts[(i * ofs) + j] = ' ';
                          sZterm = 1;
                   }
                   Comm[i + j * nlig] = pts[(i * ofs) + j];
                }
              }
              Comm[nlig * L_COMMENTAIRE] = '\0';

              pout[num] = mxCreateString (Comm);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], L_COMMENTAIRE);
              num += 1;
              mxFree (Comm);

          } break;

          case CHRONO : {
             char  *Nom_decl, *Valid, *Typ, *Repere, *Ref, *Comm, *pts ;
             float *pt_decal, * pt_duree;
             int i, j , sZterm, *pt_i;
             Double   *pr;
             int ofs = 4+L_NOM_REPERE+L_NOM_DECLENCHE+2*sizeof(float)+9+L_COMMENTAIRE;

             nlig = nb_rep ;

             if ((Nom_decl = (char *) mxCalloc (nb_rep, L_NOM_DECLENCHE+1)) == NULL)
                             meser ("AllocChrono1 - ", " ", 1001, FATAL);
             if ((Valid = (char *) mxCalloc (nb_rep, 3)) == NULL)
                             meser ("AllocChrono2 - ", " ", 1001, FATAL);
             if ((Typ = (char *) mxCalloc (nb_rep, 3)) == NULL)
                             meser ("AllocChrono3 - ", " ", 1001, FATAL);
             if ((Repere = (char *) mxCalloc (nb_rep, L_NOM_REPERE+1)) == NULL)
                             meser ("AllocChrono4 - ", " ", 1001, FATAL);
             if ((Ref = (char *) mxCalloc (nb_rep, 10)) == NULL)
                             meser ("AllocChrono5 - ", " ", 1001, FATAL);
             if ((Comm = (char *) mxCalloc (nb_rep, L_COMMENTAIRE +1)) == NULL)
                             meser ("AllocChrono6 - ", " ", 1001, FATAL);

             if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
              { /* Old shots */
                /*  TODO  */ 
              }
              else {
               if ((pt_decal = (float *) mxCalloc (nb_rep, sizeof (float))) == NULL)
                             meser ("AllocChrono7 - ", " ", 1001, FATAL); 
               if ((pt_duree = (float *) mxCalloc (nb_rep, sizeof (float))) == NULL)
                             meser ("AllocChrono8 - ", " ", 1001, FATAL); 

               pts = buffer + 4 + L_NOM_REPERE + L_NOM_DECLENCHE;
               for(i = 0; i < nb_rep; i++) {
                  memcpy(&pt_decal[i], pts, sizeof(float));
                  pts += ofs;
               }
               pts = buffer + 4 + L_NOM_REPERE + L_NOM_DECLENCHE + sizeof(float) + 9;
               for(i = 0; i < nb_rep; i++) {
                  memcpy(&pt_duree[i], pts, sizeof(float));
                  pts += ofs;
               }
              }

              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               ncol = 8;    /* THE_OLD_SIZE */
              else
               ncol = THE_SIZE;    /* THE_SIZE */

              /*  Valid  */
              pts = buffer;

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < 2; j++) {
                   if( (pts[(i * ofs) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[(i * ofs) + j] = ' ';
                          sZterm = 1;
                   }
                   Valid[i + j * nlig] = pts[(i * ofs) + j]; 
                }
              }
              Valid[nlig * 2] = '\0';   

              pout[num] = mxCreateString (Valid);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], 2);
              num += 1;
              mxFree (Valid);

              /*  Typedecl  */
              pts = buffer + 2 ;

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < 2; j++) {
                   if( (pts[(i * ofs) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[(i * ofs) + j] = ' ';
                          sZterm = 1;
                   }
                   Typ[i + j * nlig] = pts[(i * ofs) + j]; 
                }
              }
              Typ[nlig * 2] = '\0';   

              pout[num] = mxCreateString (Typ);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], 2);
              num += 1;
              mxFree (Typ);

              /*  Repere  */
              pts = buffer + 2 + 2 ;

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < L_NOM_REPERE; j++) {
                   if( (pts[(i * ofs) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[(i * ofs) + j] = ' ';
                          sZterm = 1;
                   }
                   Repere[i + j * nlig] = pts[(i * ofs) + j]; 
                }
              }
              Repere[nlig * L_NOM_REPERE] = '\0';   

              pout[num] = mxCreateString (Repere);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], L_NOM_REPERE);
              num += 1;
              mxFree (Repere);

              /* Nom declenche */
              pts = buffer + 2 + 2 + L_NOM_REPERE;

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < L_NOM_DECLENCHE; j++) {
                   if( (pts[(i * ofs) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[(i * ofs) + j] = ' ';
                          sZterm = 1;
                   }
                   Nom_decl[i + j * nlig] = pts[(i * ofs) + j]; 
                }
              }
              Nom_decl[nlig * L_NOM_DECLENCHE] = '\0';   

              pout[num] = mxCreateString (Nom_decl);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], L_NOM_DECLENCHE);
              num += 1;
              mxFree (Nom_decl);

              /*  decalage */
              pout[num] = mxCreateDoubleMatrix( nlig, 1, mxREAL);
              pr = mxGetPr(pout[num]); 
              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               {
                 /* TODO */
               } else {
                  for (j = 0; j < 1; j++)
                    {
                      for (i = 0; i < nlig; i++)
                         pr[i + j * nlig] = (Double) pt_decal[i + j] / CTPSN;
                    }
                  mxFree(pt_decal);
                  num += 1;
              }

              /*  Ref  */
              pts = buffer + 2 + 2 + L_NOM_REPERE + L_NOM_DECLENCHE + sizeof(float);

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < 9; j++) {
                   if( (pts[(i * ofs) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[(i * ofs) + j] = ' ';
                          sZterm = 1;
                   }
                   Ref[i + j * nlig] = pts[(i * ofs) + j]; 
                }
              }
              Ref[nlig * 9] = '\0';   

              pout[num] = mxCreateString (Ref);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], 9);
              num += 1;
              mxFree (Ref);

              /* Duree */
              pout[num] = mxCreateDoubleMatrix( nlig, 1, mxREAL);
              pr = mxGetPr(pout[num]); 
              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               {
                 /* TODO */
               } else {
               for (j = 0; j < 1; j++)
                {
                  for (i = 0; i < nlig; i++)
                    pr[i + j * nlig] = (Double) pt_duree[i + j] / CTPSN;
                }
                mxFree(pt_duree);
                num += 1; 
               }

              /*  Commentaire  */
              pts = buffer + 2 + 2 + L_NOM_REPERE + L_NOM_DECLENCHE + 2*sizeof(float) + 9;

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < L_COMMENTAIRE; j++) {
                   if( (pts[(i * ofs) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[(i * ofs) + j] = ' ';
                          sZterm = 1;
                   }
                   Comm[i + j * nlig] = pts[(i * ofs) + j]; 
                }
              }
              Comm[nlig * L_COMMENTAIRE] = '\0';   

              pout[num] = mxCreateString (Comm);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], L_COMMENTAIRE);
              num += 1;
              mxFree (Comm);

               }
               break;


          case CADRAN : {
             char  *Nom_decl, *Aff, *Comm, *Strat, *pts ;
             short *pt_code;
             int i, j , sZterm, *pt_i;
             Double   *pr;

             nlig = nb_rep ;

             if ((Nom_decl = (char *) mxCalloc (nb_rep, THE_SIZE +1)) == NULL)
                             meser ("AllocSernam1 - ", " ", 1001, FATAL);
             if ((Aff = (char *) mxCalloc (nb_rep, 3)) == NULL)
                             meser ("AllocSernam2 - ", " ", 1001, FATAL);
             if ((Strat = (char *) mxCalloc (nb_rep, THE_SIZE +1)) == NULL)
                             meser ("AllocSernam3 - ", " ", 1001, FATAL);
             if ((Comm = (char *) mxCalloc (nb_rep, L_COMMENTAIRE +1)) == NULL)
                             meser ("AllocSernam3 - ", " ", 1001, FATAL);

             if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
              { /* Old shots */
                /*  TODO  */ 
              }
              else {
               if ((pt_code = (short *) mxCalloc (nb_rep, sizeof (short))) == NULL)
                             meser ("AllocTdeclf - ", " ", 1001, FATAL); 

               pts = buffer;
               for(i = 0; i < nb_rep; i++) {
                  memcpy(&pt_code[i], pts, sizeof(short));
                  pts += sizeof(short);
                  pts +=  L_NOM_DECLENCHE + 2 + L_NOM_STRATEGIE + L_COMMENTAIRE ;
               }
              }

              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               ncol = 8;    /* THE_OLD_SIZE */
              else
               ncol = THE_SIZE;    /* THE_SIZE */

              /* Nom declenche */
              pts = buffer + sizeof (short);

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < ncol; j++) {
                   if( (pts[i * (sizeof(short) + ncol +  2 + L_NOM_STRATEGIE + L_COMMENTAIRE) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[i * (sizeof(short) + ncol + 2 +  L_NOM_STRATEGIE + L_COMMENTAIRE) + j] = ' ';
                          sZterm = 1;
                   }
                   Nom_decl[i + j * nlig] = pts[i * (sizeof(short) + ncol + 2 + L_NOM_STRATEGIE + L_COMMENTAIRE) + j]; 
                }
              }
              Nom_decl[nlig * ncol] = '\0';   

              pout[num] = mxCreateString (Nom_decl);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], ncol);
              num += 1;
              mxFree (Nom_decl);

              /*  Affich  */
              pts = buffer + sizeof (short) + L_NOM_DECLENCHE;

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < 2; j++) {
                   if( (pts[i * ( 2 + L_NOM_STRATEGIE + L_COMMENTAIRE + sizeof(short) + L_NOM_DECLENCHE) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[i * (2 + L_NOM_STRATEGIE + L_COMMENTAIRE + sizeof(short) + L_NOM_DECLENCHE) + j] = ' ';
                          sZterm = 1;
                   }
                   Aff[i + j * nlig] = pts[i * (2 + L_NOM_STRATEGIE + L_COMMENTAIRE + sizeof(short) + L_NOM_DECLENCHE) + j]; 
                }
              }
              Aff[nlig * 2] = '\0';   

              pout[num] = mxCreateString (Aff);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], 2);
              num += 1;
              mxFree (Aff);

              /*  Stratpil  */
              pts = buffer + sizeof (short) + L_NOM_DECLENCHE + 2;

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < ncol; j++) {
                   if( (pts[i * (L_NOM_STRATEGIE + L_COMMENTAIRE + sizeof(short) + L_NOM_DECLENCHE + 2) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[i * (L_NOM_STRATEGIE + L_COMMENTAIRE + sizeof(short) + L_NOM_DECLENCHE + 2 ) + j] = ' ';
                          sZterm = 1;
                   }
                   Strat[i + j * nlig] = pts[i * (L_NOM_STRATEGIE + L_COMMENTAIRE + sizeof(short) + L_NOM_DECLENCHE + 2) + j]; 
                }
              }
              Strat[nlig * ncol] = '\0';   

              pout[num] = mxCreateString (Strat);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], ncol);
              num += 1;
              mxFree (Strat);

              /*  Commentaire  */
              pts = buffer + sizeof (short) + L_NOM_DECLENCHE + 2 + L_NOM_STRATEGIE;

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < L_COMMENTAIRE; j++) {
                   if( (pts[i * (L_COMMENTAIRE + sizeof(short) + L_NOM_DECLENCHE + 2 + L_NOM_STRATEGIE) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[i * (L_COMMENTAIRE + sizeof(short) + L_NOM_DECLENCHE + 2 + L_NOM_STRATEGIE) + j] = ' ';
                          sZterm = 1;
                   }
                   Comm[i + j * nlig] = pts[i * (L_COMMENTAIRE + sizeof(short) + L_NOM_DECLENCHE + 2 + L_NOM_STRATEGIE) + j]; 
                }
              }
              Comm[nlig * L_COMMENTAIRE] = '\0';   

              pout[num] = mxCreateString (Comm);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], L_COMMENTAIRE);
              num += 1;
              mxFree (Comm);

              /*  Code */
              ncol =  1;
              pout[num] = mxCreateDoubleMatrix( nlig, ncol, mxREAL);
              pr = mxGetPr(pout[num]); 
              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               {
                   /* TODO */
 
               } else {
                  for (j = 0; j < ncol; j++)
                    {
                      for (i = 0; i < nlig; i++)
                         pr[i + j * nlig] = (Double) pt_code[i * ncol + j];
                       mxFree(pt_code);
                    }
               }
               num += 1; 
               }
               break;

          case SERNAM : {
             char  *Nom_decl, *Aff, *Comm, *pts ;
             short *pt_code;
             int i, j , sZterm, *pt_i;
             Double   *pr;

             nlig = nb_rep ;

             if ((Nom_decl = (char *) mxCalloc (nb_rep, THE_SIZE +1)) == NULL)
                             meser ("AllocSernam1 - ", " ", 1001, FATAL);
             if ((Aff = (char *) mxCalloc (nb_rep, 3)) == NULL)
                             meser ("AllocSernam2 - ", " ", 1001, FATAL);
             if ((Comm = (char *) mxCalloc (nb_rep, L_COMMENTAIRE +1)) == NULL)
                             meser ("AllocSernam3 - ", " ", 1001, FATAL);

             if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
              { /* Old shots */
                /*  TODO  */ 
              }
              else {
               if ((pt_code = (short *) mxCalloc (nb_rep, sizeof (short))) == NULL)
                             meser ("AllocTdeclf - ", " ", 1001, FATAL); 

               pts = buffer;
               for(i = 0; i < nb_rep; i++) {
                  memcpy(&pt_code[i], pts, sizeof(short));
                  pts += sizeof(short);
                  pts +=  2 + L_NOM_DECLENCHE + L_COMMENTAIRE ;
               }
              }

              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               ncol = 8;    /* THE_OLD_SIZE */
              else
               ncol = THE_SIZE;    /* THE_SIZE */

              /* Nom declenche */
              pts = buffer + sizeof (short);

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < ncol; j++) {
                   if( (pts[i * (2 + ncol +  2 + L_COMMENTAIRE) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[i * (2 + ncol + 2 + L_COMMENTAIRE) + j] = ' ';
                          sZterm = 1;
                   }
                   Nom_decl[i + j * nlig] = pts[i * (2 + ncol + 2 + L_COMMENTAIRE) + j]; 
                }
              }
              Nom_decl[nlig * ncol] = '\0';   

              pout[num] = mxCreateString (Nom_decl);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], ncol);
              num += 1;
              mxFree (Nom_decl);

              /*  Affich  */
              pts = buffer + sizeof (short) + L_NOM_DECLENCHE;

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < 2; j++) {
                   if( (pts[i * (2 +  sizeof(short) + L_COMMENTAIRE + ncol ) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[i * (2 + 2 + L_COMMENTAIRE + ncol) + j] = ' ';
                          sZterm = 1;
                   }
                   Aff[i + j * nlig] = pts[i * (2 + 2 + L_COMMENTAIRE + ncol ) + j]; 
                }
              }
              Aff[nlig * 2] = '\0';   

              pout[num] = mxCreateString (Aff);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], 2);
              num += 1;
              mxFree (Aff);

              /*  Commentaire  */
              pts = buffer + sizeof (short) + L_NOM_DECLENCHE + 2;

              for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < L_COMMENTAIRE; j++) {
                   if( (pts[i * (L_COMMENTAIRE + sizeof(short) + 2 + L_NOM_DECLENCHE) + j] =='\0' /* NULL*/) || sZterm ) {
                          pts[i * (L_COMMENTAIRE + sizeof(short) + 2 + L_NOM_DECLENCHE) + j] = ' ';
                          sZterm = 1;
                   }
                   Comm[i + j * nlig] = pts[i * (L_COMMENTAIRE + 2 + sizeof(short)+ L_NOM_DECLENCHE) + j]; 
                }
              }
              Comm[nlig * L_COMMENTAIRE] = '\0';   

              pout[num] = mxCreateString (Comm);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], L_COMMENTAIRE);
              num += 1;
              mxFree (Comm);

              /*  Code */
              ncol =  1;
              pout[num] = mxCreateDoubleMatrix( nlig, ncol, mxREAL);
              pr = mxGetPr(pout[num]); 
              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               {
                   /* TODO */
 
               } else {
                  for (j = 0; j < ncol; j++)
                    {
                      for (i = 0; i < nlig; i++)
                         pr[i + j * nlig] = (Double) pt_code[i * ncol + j];
                       mxFree(pt_code);
                    }
               }
               num += 1; 
               }
               break; /* end CADRAN SERNAM */

          case FLOAT4_CHAR64 : {
             char  *Comment, *pts ;
             float *pt_v;
             int i, j , sZterm, *pt_i;
             Double   *pr;

             nlig = nb_rep ;

             if ((Comment = (char *) mxCalloc (nb_rep, 65)) == NULL)
                             meser ("AllocTf4c64 - ", " ", 1001, FATAL);
             if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
              {
              /* Old shots */ 
              }
              else {
               if ((pt_v = (float *) mxCalloc (nb_rep, sizeof (float))) == NULL)
                             meser ("AllocTc64V - ", " ", 1001, FATAL); 

               pts = buffer;
               for(i = 0; i < nb_rep; i++) {
                  memcpy(&pt_v[i], pts, sizeof(float));
                  pts += sizeof(float);
                  pts += 65;
               }
             }


             ncol = 65;
             pts = buffer + sizeof(float);

             for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < ncol; j++) {
                   if( (pts[i * (ncol + 4) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[i * (ncol + sizeof(float) ) + j] = ' ';
                          sZterm = 1;
                   }
                  Comment[i + j * nlig] = pts[i * (ncol + sizeof(float) ) + j]; 
                }
              }
              Comment[nlig * ncol] = '\0';   
              pout[num] = mxCreateString (Comment);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], ncol);
              num += 1;
              mxFree (Comment);

              ncol =  1;
              pout[num] = mxCreateDoubleMatrix( nlig, ncol, mxREAL);
              pr = mxGetPr(pout[num]); 
              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               {
                  /* Old shots */ 
 
               } else {
                  for (j = 0; j < ncol; j++)
                    {
                      for (i = 0; i < nlig; i++)
                         pr[i + j * nlig] = (Double) pt_v[i * ncol + j];
                       mxFree(pt_v);
                    }
               }
               num += 1; 
             }
             break; /* end FLOAT4_CHAR64 */

          case INT2_CHAR64 : {
             char  *Comment, *pts ;
             short *pt_v;
             int i, j , sZterm, *pt_i;
             Double   *pr;

             nlig = nb_rep ;

             if ((Comment = (char *) mxCalloc (nb_rep, 65)) == NULL)
                             meser ("AllocTf4c64 - ", " ", 1001, FATAL);
             if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
              {
              /* Old shots */ 
              }
              else {
               if ((pt_v = (short *) mxCalloc (nb_rep, sizeof (short))) == NULL)
                             meser ("AllocTc64V - ", " ", 1001, FATAL); 

               pts = buffer;
               for(i = 0; i < nb_rep; i++) {
                  memcpy(&pt_v[i], pts, sizeof(short));
                  pts += sizeof(short);
                  pts += 65;
               }
             }


             ncol = 65;
             pts = buffer + sizeof(short);

             for (i = 0; i < nlig; i++)
              {
                sZterm = 0;
                for (j = 0; j < ncol; j++) {
                   if( (pts[i * (ncol + sizeof(short)) + j] == '\0' /*NULL*/) || sZterm ) {
                          pts[i * (ncol + sizeof(short) ) + j] = ' ';
                          sZterm = 1;
                   }
                  Comment[i + j * nlig] = pts[i * (ncol + sizeof(short) ) + j]; 
                }
              }
              Comment[nlig * ncol] = '\0';   
              pout[num] = mxCreateString (Comment);
              mxSetM (pout[num], nlig);
              mxSetN (pout[num], ncol);
              num += 1;
              mxFree (Comment);

              ncol =  1;
              pout[num] = mxCreateDoubleMatrix( nlig, ncol, mxREAL);
              pr = mxGetPr(pout[num]); 
              if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST))
               {
                  /* Old shots */ 
 
               } else {
                  for (j = 0; j < ncol; j++)
                    {
                      for (i = 0; i < nlig; i++)
                         pr[i + j * nlig] = (Double) pt_v[i * ncol + j];
                       mxFree(pt_v);
                    }
               }
               num += 1; 
             }
             break; /* end INT2_CHAR64 */


           }  /* end switch */
        }

    if((fparm != T_DECLENC) && (fparm != STRAT_PILOTE)  && (fparm != SERNAM) 
       && (fparm != CADRAN) && (fparm != CHRONO)  && (fparm != FLOAT4_CHAR64)
       && (fparm != INT2_CHAR64) && (fparm != L_DIAG)  && (fparm != VOIE_GAIN)
       && (fparm != T_DECODE) ) {
       pout[num] = MATformat(nlig, ncol, fparm, dataout);
       if (!pout[num])
         {
          for (i = num; i < nout; i++)
             pout[i] = emptyMat();
          meser("MATformat - ", nomparam, 1003, FATAL);
         }
       num += 1;
    }

    free(buffer);
    return 0;
    }

Longint
lit_entete(Longint numchoc, char *nomdiag, char *nomobj, mxArray * pout[])
    {
    Longint	cr;
    float	calibration;
    char	unites[UNIT_SIZE];
    Double	*pr;

#ifdef DEBUG
mexPrintf("dans lit_entete\n");
#endif
    if( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST) ) {
      cr = TSRqentete_sig(numchoc, nomdiag, nomobj, unites, &calibration);
    if (cr != 0)
        {
        meser("TSRqentete_sig - ", nomobj, cr, NONFATAL);
        return (cr);
        }
    else
        {
        pout[num] = mxCreateDoubleMatrix(1, 1, mxREAL);
        pr = mxGetPr(pout[num]);
        pr[0] = (Double) calibration;
        num += 1;

        pout[num] = charMat(1, UNIT_SIZE, unites);
        num += 1;
        }
    }
    else
    {
    Longint	cr, nb_val,format;
    ts_donnee   *pt_donnee;
    ts_v_float4 * pt_void;
    char *pt_char, *pt_comment;

    pt_char = NULL;
    cr = TSRqParm (numchoc, nomdiag, nomobj, "CALIB", 1, &pt_char, &nb_val,
                   &format);
    if (cr == 0)
    {
      switch(format){
        case P_FLOAT:
        {
          pt_void = (ts_v_float4 *) pt_char;
         free(pt_char);
         break;
       }
    }
    calibration = pt_void->float4;
   }
    else {
          calibration = 0;
          meser("TSRqentete_sig - ", nomobj, cr, NONFATAL);
          return (cr);
    }

    pout[num] = mxCreateDoubleMatrix(1, 1, mxREAL);
    pr = mxGetPr(pout[num]);
    pr[0] = (Double) calibration;
    num += 1;

    cr = TSdescObjet (numchoc, nomdiag, nomobj, &pt_char, &pt_comment);
#ifdef DEBUG
mexPrintf("apres lit_entete cr = %d\n",cr);
#endif
    if (cr != 0)
        {
        meser("TSRqentete_sig - ", nomobj, cr, NONFATAL);
        return (cr);
        }
    else
        {
        free(pt_comment);
        pt_donnee =  (ts_donnee *)pt_char; 
        pout[num] = charMat(1, UNIT_SIZE, pt_donnee->unitey);
        num += 1;
        }
   
    }
    return (0);

    }

void
meser(char *mes1, char *mes2, Longint numer, Longint code)
    {
    mexPrintf("tsmat : %s%s :", mes1, mes2);
    numer--;

    if (numer < 0)
        {
        if( ((-numer) - 2) <= 5) {
           mexPrintf(" %s \n", err_rqlib[(-numer) - 2]);
         }
        else
           mexPrintf(" Erreur : %d  Mail buravand please\n", numer);
        }

    else if (numer < 1000)
        {
        if ( numer > 98 )
            numer = numer - 49;
        if ( numer > 65)
            numer = numer - 85;
        mexPrintf(" %s\n", err_tslib[numer]);
        }
    else if (numer > ERR_MAX)
        {
        mexPrintf(" Erreur TSLIB (bug?) %d\n", numer);
        sigaction(SIGINT, &oldact, NULL);         /* reset previous action */  
        mexErrMsgTxt("Bad news : Contact your System Manager ");
        }
    else
        mexPrintf(" %s\n", err_tsmat[numer - 1000]);
    if (code == FATAL) {
        sigaction(SIGINT, &oldact, NULL);         /* reset previous action */  
        mexErrMsgTxt("Oops ");
    }
    }


void 
FreeMemM(void *F)
    {
#if (client == PC )
        {
        GLOBALHANDLE    hMemory;
        if (F == NULL)
            return;
        hMemory = (GLOBALHANDLE) GlobalHandle((UINT) SELECTOROF(F));
        GlobalUnlock(hMemory);
        GlobalFree(hMemory);
        }
#else
        if (F == NULL)
            return;
        free(F);
#endif
    }

void           *
Realloc(void *lpMemory, unsigned int cbNewSize)
    {
#if (client == PC )
    GLOBALHANDLE    hMemory, hNewMemory;
    if (lpMemory == NULL)
        return NULL;
    hMemory = (GLOBALHANDLE) GlobalHandle((UINT) SELECTOROF(lpMemory));
    GlobalUnlock(hMemory);
    hNewMemory = GlobalReAlloc(hMemory, cbNewSize, GMEM_MOVEABLE);
    if (hNewMemory == (HGLOBAL) NULL)
        return NULL;
    return (GlobalLock(hNewMemory));
#else
    void           *NewMem;
    NewMem = realloc(lpMemory, cbNewSize);
    if (NewMem == NULL)
        return NULL;
    return (NewMem);
#endif
    }

void *
MemAllocM(Longint byte)
    {
    void	*result;

#if ( client == PC )
    result = GlobalLock(GlobalAlloc( GMEM_MOVEABLE, byte));
#else
    result = malloc(byte);
#endif

    return (result);
    }



char *trim (char *str)
{
      char *ibuf, *obuf;

      if (str)
      {
            for (ibuf = obuf = str; *ibuf; )
            {
                  while (*ibuf && (isspace (*ibuf)))
                        ibuf++;
                  if (*ibuf && (obuf != str))
                        *(obuf++) = ' ';
                  while (*ibuf && (!isspace (*ibuf)))
                        *(obuf++) = *(ibuf++);
            }
            *obuf = '\0' /*NULL*/;
      }
      return (str);
}

