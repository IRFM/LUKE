
/*
   YB  July 1995
 */

#include <time.h>
#include "tdef.h"

/*  Decodage des types d'objets  */

T_Objet Type_Objets[] =
{
  "ACHRONO",28,
  "ASSERVISSEMENT", 20,
  "CAMAC2162", 5,
  "CAMAC6103", 6,
  "CAMAC6810", 7,
  "CAMAC8818", 8,
  "CHRONO", 9,
  "CHRONOVME", 18,
  "COMMON", 26,
  "CONSIGNE", 21,
  "DATE1", 10,
  "DATE2", 11,
  "DECOD_CHRONO", 14,
  "DIAGNOSTIC", 1,
  "DONGEN", 22,
  "DONNEE", 2,
  "ENCOD_CHRONO", 15,
  "GENE_FONCTION", 13,
  "ICM100", 3,
  "ICM101", 4,
  "ICV101", 27,
  "OBJET_CHRONO", 24,
  "PILOTAGE", 17,
  "SEQ_NUM", 12,
  "STRAT_DIAG", 16,
  "STRAT_PIL", 23,
  "TORE_SUPRA", 25,
  "TOUS", 100,
  "TRAITEMENT", 19,
};

#define NB_OBJETS   (sizeof(Type_Objets) / sizeof(T_Objet))
int nb_objets = NB_OBJETS;

int binary (char *word, int n);

int
fi (char *objet)

{

  register int i;


  if ((i = binary (objet, nb_objets)) < 0)
    return (-1);
  else
    return (Type_Objets[i].code_type);

}

/*
 * Perform a binary search of the object list
 * to see if a given object is known
 */

int
binary (char *word, int n)
{
  register int low, high, mid, cond;

  low = 0;
  high = n - 1;
  while (low <= high)
    {
      mid = (low + high) / 2;
      if ((cond = strcmp (word, Type_Objets[mid].obj_name)) < 0)
	high = mid - 1;
      else if (cond > 0)
	low = mid + 1;
      else
	return (mid);		/* found it, return index in array */
    }
  return (-1);			/* not found */
}


int
date_bd ()
{
  time_t temps_absolu;
  struct tm *temps_systeme;

  temps_absolu = time ((time_t *) 0);

  temps_systeme = localtime (&temps_absolu);

  return (temps_systeme->tm_mday
	  + (temps_systeme->tm_mon + 1) * 100
	  + (temps_systeme->tm_year + 1900) * 10000);
}

void
upper (char *chaine)
{
  char *pt;
  pt = chaine;

  while (*pt)
    {
      *pt = toupper (*pt);
      pt++;
    }
}


