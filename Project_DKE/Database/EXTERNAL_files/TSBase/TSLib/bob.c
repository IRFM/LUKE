/* bob is a dirty test program */

#include <stdio.h>
#include <stdlib.h>
#include<string.h>
#include<ctype.h>
//#include<malloc.h>

#include "tsarcad.h"
#include "def.h"
#include "tdef.h"
#include "erreur.h"
char tslib_reel='f';

typedef struct t_ {
    char nom[8];
    int temps;
}tdecl;

typedef struct v_t_decode_ {
        char    type[2];
        short   numero;
        short   polar;
        char    declench1[L_NOM_DECLENCHE];
        char    declench2[L_NOM_DECLENCHE];
        Longint duree;
        char    comment[L_COMMENTAIRE];
  } v_t_decode;


char gros_buffer[12345]={"AZE"};

int
main ()
{
  char t_objet[16], n_prod[13], n_objet[13], n_param[13];
  register int i;
  int the_size, n_choc, nb_obj,n_val = 0;
  ts_objet *p_ts_obj, *p_tmp;
  int cr;
  int format, nb_val, data_int[32];
  float *pt_flt, data_float[4];
  char *pt_char, *pt_comment;
  char **pt_cmt;
  void *pt_void;
  char *pt__;
  ts_diagnostic *pt_diagnostic;
  ts_donnee     *pt_donnee;
  char        *ldiag[100], *lsig[200];
  tdecl *ptdecl;
  v_t_decode *pp;
  char VAL[123456];
  int L;

  /*  puts (" Test Tstele");

  cr = TStele ("APOLO",1,1,&VAL,&L);
  if (cr == 0)
      printf ("bob tstele OK on a %d long \n",L);
      
    else
      printf ("bob tstele PAS OK %d \n",cr);
     exit(0);
*/

  puts (" Test RqParm");

  printf ("No Choc ? ");
  scanf ("%d", &n_choc);
  printf ("Nom prod ? ");
  scanf ("%s", n_prod);
  printf ("Nom objet ? ");
  scanf ("%s", n_objet);
  printf ("Nom param ? ");
  scanf ("%s", n_param);

  pt_char = NULL;

  n_val = 256;
  cr = TSRqParm (n_choc, n_prod, n_objet, n_param, n_val, &pt_char, &nb_val, &format);
  if (cr == 0)
    {
      printf ("bob tsrqparm OK on a %d valeurs \n",nb_val);
      switch(format){
	case OCTET:
	{
          ts_v_int1 * pt_void;
          pt_void = (ts_v_int1 *) pt_char;
	  for (i = 0; i < nb_val; i++)
	    {
	      printf ("valeur %i : %d\n", i, pt_void->integer1);
	      pt_void += 1;
	    }
         free(pt_char);
         break;
	}
	case INT16:
	{
          short * pt_void;
          pt_void = (short *) gros_buffer;
          pt_void = (short *) pt_char;
	  for (i = 0; i < nb_val; i++)
	    {
	      printf ("valeur %i : %d\n", i, *(pt_void));
	      pt_void += 1;
	    }
         free(pt_char);
         break;
	}
	case INT32:
	{
          int * pt_void;
          pt_void = (int *) pt_char;
	  for (i = 0; i < nb_val; i++)
	    {
	      printf ("valeur %i : %d\n", i, *(pt_void));
	      pt_void += 1;
	    }
         free(pt_char);
         break;
	}
	case REEL16:
	{
          ts_v_float4 * pt_void;
          pt_void = (ts_v_float4 *) pt_char;
	  for (i = 0; i < nb_val; i++)
	    {
	      printf ("valeur %i : %6.3f\n", i, pt_void->float4);
	      pt_void += 1;
	    }
         free(pt_char);
         break;
	}
	case STRING12:
	{
          char * pt_void;
          pt_void = (char *) pt_char;
	  for (i = 0; i < nb_val; i++)
	    {
	      printf ("valeur %d : %s\n", i, pt_void);
	      pt_void += 1;
	    }
         free(pt_char);
         break;
	}
	case T_DECLENC:
	{
          ts_v_declenc * pt_void;
          pt_void = (ts_v_declenc *) pt_char;
	  for (i = 0; i < nb_val; i++)
	    {
	      printf ("nom %s valeur : %f  \n", pt_void->nom,pt_void->temps);
	      pt_void += 1;
	    }
         free(pt_char);
         break;
	}
	case 16:
	{
          tdecl * ptdecl;
          ptdecl = (tdecl *) pt_char;
	  for (i = 0; i < nb_val; i++)
	    {
              int j;
	      printf ("nom[%3d] : ",i);
                   for(j=0;j<8;j++)
	            printf("%c",ptdecl->nom[j]);
	      printf ("  valeur : %d  \n",ptdecl->temps);
	      ptdecl += 1;
	    }
         free(pt_char);
         break;
	}
	case TWIN_REEL32:
	{
          ts_v_float4_float4 * pt_void;
          pt_void = (ts_v_float4_float4 *) pt_char;
	  for (i = 0; i < nb_val; i++)
	    {
	      printf ("valeur %i : %6.3f %6.3f \n", i,
               pt_void->float4_1,pt_void->float4_2);
	      pt_void += 1;
	    }
         free(pt_char);
         break;
	}

	case F_ACHRONO:
	{
          ts_v_achrono * pt_void;
          pt_void = (ts_v_achrono *) pt_char;
	  for (i = 0; i < nb_val; i++)
	    {
	      printf ("valeur %i : %s %s %6.3f %6.3f %s\n", i,
               pt_void->code,pt_void->declenche,
               pt_void->decalage,pt_void->duree,pt_void->comment);
	      pt_void += 1;
	    }
         free(pt_char);
         break;
	}
	
	case F_DESCRIPTEUR:
	{
          ts_v_descripteur * pt_void;
          pt_void = (ts_v_descripteur *) pt_char;
	  for (i = 0; i < nb_val; i++)
	    {
	      printf ("valeur %i : %d  %s  %s  %d  %s  %s  %d\n", i,
               pt_void->num_choc, pt_void->nom_diag, pt_void->donnee_brute,
	       pt_void->indiceb, pt_void->nom_trait, pt_void->donnee_traitee,
	       pt_void->indicet);
	      pt_void += 1;
	    }
         free(pt_char);
         break;

	case 24:
	{
          v_t_decode * pt_void;
	  for (i = 0; i < nb_val; i++)
	    {
          pt_void = (v_t_decode *) pt_char;
	      printf ("valeur %i : %2c  %d  %d  %s  %s  %d  %s\n", i,
               pt_void->type, pt_void->numero, pt_void->polar,
	       pt_void->declench1, pt_void->declench2, pt_void->duree,
	       pt_void->comment);

        pt_char  = pt_char + 2+sizeof(short) *2+ 2*L_NOM_DECLENCHE+
                   sizeof(Longint)+L_COMMENTAIRE;

	    }
         free(pt_char);
         break;
	}
	}
      default:  puts(" Not yet implemented ");
    }
   } 
  else
    {
      printf ("bob : Erreur tsrqparam %d\n",cr);
    }

/*
  puts (" Test TSdescObjet");

  printf ("No Choc ? ");
  scanf ("%d", &n_choc);
  printf ("Nom prod ? ");
  scanf ("%s", n_prod);
  printf ("Nom objet ? ");
  scanf ("%s", n_objet);
  printf ("Nom type objet ? ");
  scanf ("%s", t_objet);
 

  cr = TSdescObjet (n_choc, n_prod, n_objet,
                                         &pt_char, &pt_comment);
  if (cr == 0)
    {
      puts ("bob tsdescobj OK");
      printf("comment %s \n",pt_comment);

      cr = decObjet(t_objet, pt_char);
      switch (fi(t_objet))
	{
	case DIAGNOSTIC:
	      pt_diagnostic =  (ts_diagnostic *)pt_char;
	  break;

	case DONNEE:
	      pt_donnee =  (ts_donnee *)pt_char;
	  break;
	case ICM100:
	  break; 
	case ICM101:
	  break;
	case CAMAC2162:
	  break;
	case CAMAC6103:
	  break;
	case CAMAC6810:
	  break;
	case CAMAC8818:
	  break;
	case CHRONO:
	  break;
	case DATE1:
	  break;
	case DATE2:
	  break;
	case SEQ_NUM:
	  break;
	case GENE_FONCTION:
	  break;
	case DECOD_CHRONO:
	  break;
	case ENCOD_CHRONO:
	  break;
	case STRAT_DIAG:
	  break;
	case PILOTAGE:
	  break;
	case CHRONOVME:

	  break;
	case TRAITEMENT:
	  break;
	case ASSERVISSEMENT:
	  break;
	case CONSIGNE:
	  break;
	case DONGEN:
	  break;
	case STRAT_PIL:
	  break;
	case OBJET_CHRONO:
	  break;
	case TORE_SUPRA:
	  break;
	case COMMON:
	  break;

	}

     free(pt_comment);
     free(pt_char);
     }
     else
     {
      printf ("bob tsdescobj Pb %d\n",cr);

      }

  printf ("TSDescDon_choc \nNo Choc ? ");
  scanf ("%d", &n_choc);
  printf ("Nom donnee ? ");
  scanf ("%s", n_objet);

  cr = TSDescDon_choc (n_objet, n_choc, &pt_donnee);
  if (cr == 0)
    {
      puts ("bob tsdescdon_choc OK");
           printf(" id_objet :\t%d \n",		pt_donnee->id_objet);
           printf(" numero :\t%d \n",	        pt_donnee->numero);
           printf(" id_donnee :\t%d \n",	pt_donnee->id_donnee);
           printf(" condif :\t%d \n",		pt_donnee->confidentialite);
           printf(" type_don :\t%d \n",		pt_donnee->type_donnee);
           printf(" nb_compo :\t%d \n",		pt_donnee->nb_composantes);
           printf(" nb_coord :\t%d \n",		pt_donnee->nb_coordonnees);
           printf(" formatX :\t%s \n",		pt_donnee->formatx);
           printf(" formatY :\t%s \n",		pt_donnee->formaty);
           printf(" formatI :\t%s \n",		pt_donnee->formati);
           printf(" formatJ :\t%s \n",		pt_donnee->formatj);
           printf(" uniteX :\t%s \n",		pt_donnee->unitex);
           printf(" uniteY :\t%s \n",		pt_donnee->unitey);
           printf(" uniteI :\t%s \n",		pt_donnee->unitei);
           printf(" uniteJ :\t%s \n",		pt_donnee->unitej);
           printf(" structX :\t%d \n",		pt_donnee->structx);
           printf(" structY :\t%d \n",		pt_donnee->structy);
           printf(" strucI :\t%d \n",		pt_donnee->structi);
           printf(" strucJ :\t%d \n",		pt_donnee->structj);
           printf(" longi :\t%d \n",		pt_donnee->longueuri);
           printf(" longj :\t%d \n",		pt_donnee->longueurj);
           printf(" maxtrame :\t%d \n",		pt_donnee->maxtrame);
           printf(" remdif :\t%d \n",		pt_donnee->remdif);

   }
     else
      printf ("bob tsdesdon_choc Pb %d\n",cr);

*/
  return (0);
}

decObjet(char *type_objet, char *pt_val )
{

void * result;
switch (  fi(type_objet)) {

   case DONNEE: {
           ts_donnee *pt = (ts_donnee *) pt_val;

           printf(" id_objet :\t%d \n",		pt->id_objet);
           printf(" id_donnee :\t%d \n",	pt->id_donnee);
           printf(" condif :\t%d \n",		pt->confidentialite);
           printf(" type_don :\t%d \n",		pt->type_donnee);
           printf(" nb_compo :\t%d \n",		pt->nb_composantes);
           printf(" nb_coord :\t%d \n",		pt->nb_coordonnees);
           printf(" structX :\t%d \n",		pt->structx);
           printf(" structY :\t%d \n",		pt->structy);
           printf(" strucI :\t%d \n",		pt->structi);
           printf(" strucJ :\t%d \n",		pt->structj);
           printf(" lgi :\t%d \n",		pt->longueuri);
           printf(" lgj :\t%d \n",		pt->longueurj);
           printf(" maxtrame :\t%d \n",		pt->maxtrame);
           printf(" remdif :\t%d \n",		pt->remdif);
         }
          break;
                      

 } /* end switch */


return(0);


}

