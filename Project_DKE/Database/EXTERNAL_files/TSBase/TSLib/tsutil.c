/*****************************************************************************

   NOM  DU MODULE        :  tsutil.c

   DESCRIPTION DU MODULE :  module d'emission et de reception des structures

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   29/09/92
   Modifications    :
   19/10/95 : (YB) Reception_Chaine : change le type de longchaine de short
              a Longint

 *****************************************************************************/

/*****************************************************************************

   Liste des fonctions du module :

	Emission_Entrees
	Reception_DescTrait
	Reception_DescDiag
	Reception_DescDon
	Reception_Donnee
	Reception_DescEntree
	Reception_DescCoord
	Reception_Unite
	Reception_Tableau
	Reception_Tab_Coord
	Reception_Chaine

 *****************************************************************************/

#include <stdio.h>              /* bibliotheques standards           */
#include <stdlib.h>
#include <string.h>
#include "tsdef.h"              /* liste des constantes utilisees */
#include "tsconf.h"             /* configuration du client        */
#if (client == MAC)

#endif
#include "tsmes.h"              /* liste des erreurs              */
#include "tstype.h"             /* liste des types de donnees     */
#include "tsext.h"              /* liste des variables globales   */
#include "functs.h"		/* prototypes fcts TSLib */


void * MemAlloc( Longint );	/* allocation de la memoire */
void FreeMemory( void * );	/* liberation de la memoire */

/**  Compress  **/
#define MIN_SIZE 1024   /* Minimum size for compress (1k) */
void lzrw1_decompress();

/****************************************************************************/


/*----------------------------------------------------------------------------

			Emission_Entrees

  But : fonction envoyant au serveur la structure Entrees

  Arguments :
	nsock      : descripteur de socket
	ptent      : pointeur sur la liste des entrees
	code_param : code du parametre a emettre

  Retour           : compte-rendu d'execution

  Appelee par : TSWrite
		TSWcertif
		TSExist
		TSRSigRg
		TSRSigX
		TSXtrRg
		TSXtrX
		TSGrpRg
		TSGrpX

------------------------------------------------------------------------------*/

Longint FAR_PASCAL
Emission_Entrees (
     				int nsock,
     			pS_Entree ptent,
     			Longint code_param     )
{
  pS_Entree pcent;	/* pointeur courant de la structure entrees */
  short int envoi;	/* indique la fin d'une structure           */
  Longint Resultat;	/* compte-rendu d'execution                 */
  int Rang;		/* rang de l'entree                         */

  Resultat = ok;
  Rang = 0;

  pcent = ptent;
  envoi = SUITE;

  while (pcent != NULL)
    {
      if ((Resultat = Emission (nsock, (char *) &envoi, taille_short, code_param))
	  != ok)
	return Resultat;

      if ((Resultat = Emission (nsock, pcent->union_var.cval,
			  (Longint) sizeof (pcent->union_var), code_param))
	  != ok)
	return Resultat;

      pcent = pcent->ps_suivant;
    }

  envoi = FIN;

  if ((Resultat = Emission (nsock, (char *) &envoi, taille_short, code_param))
      != ok)
    return Resultat;

  return Resultat;
}

/*----------------------------------------------------------------------------

			Reception_Donnee

  But : fonction recevant la structure Donnee emise par le client

  Arguments :
	nsock      : descripteur de socket
	ptdon      : pointeur sur la structure Donnee
	code_param : code du parametre a recevoir

  Retour           : compte-rendu d'execution

  Appelee par : Reception_DescTrait
		Reception_DescDiag
		Reception_DescDon

------------------------------------------------------------------------------*/

Longint FAR_PASCAL
Reception_Donnee (
     				int nsock,
     			pS_Donnee *ptdon,
     			Longint code_param   )
{
  pS_Donnee pcdon;	/* pointeur courant de la structure S_Donnee   */
  short int envoi;	/* indique la fin d'une structure              */
  Longint Resultat;	/* compte-rendu d'execution                    */
  Resultat = ok;

  pcdon = NULL;
  *ptdon = NULL;

  if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
      != ok)
    return Resultat;
  if (envoi == FIN)
    return Resultat;

  while (envoi == SUITE)
    {

      if (pcdon == NULL)
	{
	  pcdon = (pS_Donnee) MemAlloc ( sizeof (struct S_Donnee) );
	  *ptdon = pcdon;
	}
      else
	{
	  pcdon->ps_suivant = (pS_Donnee) MemAlloc (sizeof (struct S_Donnee));
	  pcdon = pcdon->ps_suivant;
	}
      if ((Resultat = Reception (nsock, pcdon->nom, TAILLE_NOM_DONNEE, code_param))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
	  != ok)
	return Resultat;

    }
if(pcdon != NULL)
  pcdon->ps_suivant = NULL;

  return Resultat;
}

/*----------------------------------------------------------------------------

			Reception_DescEntree

  But : fonction recevant la structure DescEntree emise par le client

  Arguments :
	nsock      : descripteur de socket
	ptent      : pointeur sur la structure DescEntree
	code_param : code du parametre a recevoir

  Retour           : compte-rendu d'execution

  Appelee par : Reception_DescTrait
 ------------------------------------------------------------------------------*/

Longint FAR_PASCAL
Reception_DescEntree (
    				int nsock,
     			pS_DescEntree *ptent,
     			Longint code_param  )
{
  pS_DescEntree pcent;	/* pointeur courant de la structure S_DescEntree */
  short int envoi;	/* indique la fin d'une structure              */
  Longint Resultat;	/* compte-rendu d'execution                    */

  Resultat = ok;

  pcent = NULL;
  *ptent = NULL;

  if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
      != ok)
    return Resultat;

  if (envoi == FIN)
    return Resultat;

  while (envoi == SUITE)
    {

      if (pcent == NULL)
	{ 
	  pcent = (pS_DescEntree) MemAlloc (sizeof (struct S_DescEntree));
	  *ptent = pcent;
	}
      else
	{
	  pcent->ps_suivant = (pS_DescEntree) MemAlloc (sizeof (struct S_DescEntree));
	  pcent = pcent->ps_suivant;
	}

      if ((Resultat = Reception (nsock, pcent->nom, TAILLE_NOM_ENTREE, code_param))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (nsock, pcent->format, TAILLE_FORMAT, code_param))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
	  != ok)
	return Resultat;

    }
  pcent->ps_suivant = NULL;

  return Resultat;
}

/*----------------------------------------------------------------------------

			Reception_DescCoord

  But : fonction recevant la structure DescCoord emise par le client

  Arguments :
	nsock      : descripteur de socket
	ptcoord    : pointeur sur la structure DescCoord
	code_param : code du parametre a recevoir

  Retour           : compte-rendu d'execution

  Appelee par   : Reception_DescDon

------------------------------------------------------------------------------*/

Longint FAR_PASCAL
Reception_DescCoord (
     				int nsock,
     			pS_DescCoord *ptcoord,
     			Longint code_param      )
{
  pS_DescCoord pccoord;	/* pointeur courant de la structure S_DescCoord */
  short int envoi;	/* indique la fin d'une structure            */
  Longint Resultat;	/* compte-rendu d'execution                  */


  Resultat = ok;

  pccoord = NULL;
  *ptcoord = NULL;

  if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
      != ok)
    return Resultat;

  if (envoi == FIN)
    return Resultat;

  while (envoi == SUITE)
    {
      if (pccoord == NULL)
	{
	   pccoord = (pS_DescCoord) MemAlloc (sizeof (struct S_DescCoord));
	  *ptcoord = pccoord;
	}
      else
	{
	  pccoord->ps_suivant  = (pS_DescCoord) MemAlloc (
					sizeof (struct S_DescCoord));
	  pccoord = pccoord->ps_suivant;
	}

      if ((Resultat = Reception (nsock, pccoord->nom, TAILLE_NOM_COORDONNEE, code_param))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (nsock, pccoord->format, TAILLE_FORMAT, code_param))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (nsock, pccoord->unite, TAILLE_NOM_UNITE, code_param))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (nsock, pccoord->pretraitement,
				 TAILLE_PRETRAITEMENT, code_param))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (nsock, (char *) &pccoord->indice_max, taille_short,
				 code_param))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (nsock, (char *) &pccoord->struct_fich, taille_long,
				 code_param))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
	  != ok)
	return Resultat;

    }
  pccoord->ps_suivant = NULL;

  return Resultat;
}


/*----------------------------------------------------------------------------

			Reception_Chaine

  But : fonction recevant une chaine de longueur inconnue emise par le serveur

  Arguments :
	nsock      : descripteur de socket
	chaine     : pointeur sur la chaine a recevoir
	code_param : code du parametre a recevoir

  Retour           : compte-rendu d'execution

  Appelee par   : Reception_DescTrait
		  Reception_DescDiag
		  Reception_DescDon

------------------------------------------------------------------------------*/
Longint FAR_PASCAL
Reception_Chaine (
     				int nsock,
     			char **chaine,
			Longint code_param     )
{
  short int envoi;    /* indique si le pointeur de la chaine est nul ou pas */
  Longint longchaine; /* longueur reelle des chaines  */
  Longint Resultat;   /* compte-rendu d'execution     */

  Resultat = ok;

  /* reception du code indiquant si le pointeur sur la chaine est nul */

  if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
      != ok)
    return Resultat;


  if (envoi == FIN)
    {
      *chaine = NULL;
      return Resultat;
    }

  /* reception de la longueur et de la chaine */

  if ((Resultat = Reception (nsock, (char *) &longchaine, taille_long, code_param))
      != ok)
    return Resultat;
	*chaine = (char *) MemAlloc (longchaine);
  if ((Resultat = Reception (nsock, *chaine, (Longint) longchaine, code_param))
      != ok)
    return Resultat;

  return Resultat;
}

/*----------------------------------------------------------------------------

			Reception_DescTrait

  But : fonction recevant la structure DescTrait emise par le client

  Arguments :
	nsock      : descripteur de socket
	pttrait    : pointeur sur la structure DescTrait
	code_param : code du parametre a recevoir

  Retour           : compte-rendu d'execution

  Appelee par    : TSDescTrait

------------------------------------------------------------------------------*/

Longint FAR_PASCAL
Reception_DescTrait (
     				int nsock,
     				pS_DescTrait *pttrait,
				Longint code_param    )
{
  short int envoi;	/* indique la fin d'une structure              */
  Longint Resultat;	/* compte-rendu d'execution                    */
  Resultat = ok;

  *pttrait = NULL;

  if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
      != ok)
    return Resultat;

  if (envoi == FIN)
    return Resultat;
  *pttrait = (pS_DescTrait) MemAlloc (sizeof (struct S_DescTrait));
  /* reception des chaines de longueur inferieures a 18 octets */

  if ((Resultat = Reception (nsock, (*pttrait)->nom, TAILLE_NOM_TRAITEMENT, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception (nsock, (*pttrait)->date, TAILLE_DATE, code_param))
      != ok)
    return Resultat;

  /* reception des chaines de longueur superieure a 17 octets */

  if ((Resultat = Reception_Chaine (nsock, &((*pttrait)->commentaire), code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception_Chaine (nsock, &((*pttrait)->machine), code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception_Chaine (nsock, &((*pttrait)->localisation), code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception_Chaine (nsock, &((*pttrait)->auteurs), code_param))
      != ok)
    return Resultat;

  /* reception des champs de type entiers */

  if ((Resultat = Reception (nsock, (char *) &((*pttrait)->type), taille_long, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception (nsock, (char *) &(*pttrait)->num_version,
			     taille_short, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception (nsock, (char *) &(*pttrait)->nb_donnees,
			     taille_short, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception (nsock, (char *) &(*pttrait)->nb_entrees,
			     taille_short, code_param))
      != ok)
    return Resultat;

  /* reception des listes chainees */

  if ((Resultat = Reception_Donnee (nsock, &(*pttrait)->ps_donnee, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception_DescEntree (nsock, &(*pttrait)->ps_entree, code_param))
      != ok)
    return Resultat;

  return Resultat;
}

/*----------------------------------------------------------------------------

			Reception_DescDiag

  But : fonction recevant la structure DescDiag emise par le client

  Arguments :
	nsock      : descripteur de socket
	ptdiag     : pointeur sur la structure DescDiag
	code_param : code du parametre a recevoir

  Retour           : compte-rendu d'execution

  Appelee par  : TSDescDiag

------------------------------------------------------------------------------*/

Longint FAR_PASCAL
Reception_DescDiag (
     			int nsock,
     			pS_DescDiag *ptdiag,
     			Longint code_param       )
{
  short int envoi;	/* indique la fin d'une structure              */
  Longint Resultat;	/* compte-rendu d'execution                    */
  Resultat = ok;

  *ptdiag = NULL;

  if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
      != ok)
    return Resultat;

  if (envoi == FIN)
    return Resultat;
  *ptdiag = (pS_DescDiag) MemAlloc (sizeof (struct S_DescDiag));


  /* reception des chaines de longueur inferieures a 18 octets */

  if ((Resultat = Reception (nsock, (*ptdiag)->nom, TAILLE_NOM_DIAGNOSTIC, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception (nsock, (*ptdiag)->date, TAILLE_DATE, code_param))
      != ok)
    return Resultat;

  /* reception des chaines de longueur superieure a 17 octets */

  if ((Resultat = Reception_Chaine (nsock, &((*ptdiag)->commentaire), code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception_Chaine (nsock, &((*ptdiag)->auteurs), code_param))
      != ok)
    return Resultat;


  /* reception des champs de type entier */

  if ((Resultat = Reception (nsock, (char *) &((*ptdiag)->type), taille_long, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception (nsock, (char *) &(*ptdiag)->num_version,
			     taille_short, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception (nsock, (char *) &(*ptdiag)->nb_donnees, taille_short,
			     code_param))
      != ok)
    return Resultat;

  /* reception de la liste chainee */

  if ((Resultat = Reception_Donnee (nsock, &(*ptdiag)->ps_donnee, code_param))
      != ok)
    return Resultat;

  return Resultat;
}

/*----------------------------------------------------------------------------

			Reception_DescDon

  But : fonction recevant la structure DescDon emise par le client

  Arguments :
	nsock      : descripteur de socket
	ptdon      : pointeur sur la structure DescDon
	code_param : code du parametre a recevoir

  Retour           : compte-rendu d'execution

  Appelee par : TSDescDon

------------------------------------------------------------------------------*/

Longint FAR_PASCAL
Reception_DescDon (
    			int nsock,
     			pS_DescDon *ptdon,
     			Longint code_param    )
{
  short int envoi;	/* indique la fin d'une structure              */
  Longint Resultat;	/* compte-rendu d'execution                    */

  Resultat = ok;

  *ptdon = NULL;

  if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
      != ok)
    return Resultat;

  if (envoi == FIN)
    return Resultat;
  *ptdon = (pS_DescDon) MemAlloc (sizeof (struct S_DescDon));
  /* reception des chaines de longueur inferieures a 18 octets */

  if ((Resultat = Reception (nsock, (*ptdon)->nom, TAILLE_NOM_DONNEE, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception (nsock, (*ptdon)->nom_producteur,
			     TAILLE_NOM_PRODUCTEUR, code_param))
      != ok)
    return Resultat;

  /* reception des chaines de longueur superieure a 17 octets */

  if ((Resultat = Reception_Chaine (nsock, &((*ptdon)->commentaire), code_param))
      != ok)
    return Resultat;

  /* reception des champs de type entier */

  if ((Resultat = Reception (nsock, (char *) &((*ptdon)->type), taille_long, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception (nsock, (char *) &(*ptdon)->nb_comp, taille_short, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception (nsock, (char *) &(*ptdon)->nb_coord, taille_short,
			     code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception (nsock, (char *) &(*ptdon)->nb_donnees_groupe,
			     taille_short, code_param))
      != ok)
    return Resultat;

  /* reception des listes chainees */

  if ((Resultat = Reception_Donnee (nsock, &(*ptdon)->ps_donnee_groupe, code_param))
      != ok)
    return Resultat;

  if ((Resultat = Reception_DescCoord (nsock, &(*ptdon)->ps_coord, code_param))
      != ok)
    return Resultat;

  return Resultat;
}

/*----------------------------------------------------------------------------

			Reception_Unite

  But : fonction recevant la structure Unite emise par le client

  Arguments :
	nsock      : descripteur de socket
	ptunite    : pointeur sur la structure Unite
	code_param : code du parametre a recevoir

  Retour           : compte-rendu d'execution

  Appelee par   : TSRSigRg
		  TSRSigX
		  TSXtrRg
		  TSXtrX
		  TSGrpRg
		  TSGrpX
		  TSSigDeclenche
		  TSXtrDeclenche
		  TSGrpDeclenche

------------------------------------------------------------------------------*/

Longint FAR_PASCAL
Reception_Unite ( 
     			int nsock,
     			pS_Unite *ptunite,
     			Longint code_param    )
{
  pS_Unite pcunite;	/* pointeur courant de la structure S_Unite  */
  short int envoi;	/* indique la fin d'une structure            */
  Longint Resultat;	/* compte-rendu d'execution                  */

  Resultat = ok;

  pcunite = NULL;
  *ptunite = NULL;

  if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
      != ok)
    return Resultat;

  if (envoi == FIN)
    return Resultat;

  while (envoi == SUITE)
    {

      if (pcunite == NULL)
	{
	  pcunite = (pS_Unite) MemAlloc (sizeof (struct S_Unite));
	  *ptunite = pcunite;
	}
      else
	{
	  pcunite->ps_suivant = (pS_Unite) MemAlloc (sizeof (struct S_Unite));
	  pcunite = pcunite->ps_suivant;
	}

      if ((Resultat = Reception (nsock, pcunite->nom, TAILLE_NOM_UNITE, code_param))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (nsock, (char *) &envoi, taille_short, code_param))
	  != ok)
	return Resultat;

    }
  pcunite->ps_suivant = NULL;

  return Resultat;
}

/*----------------------------------------------------------------------------

			Reception_Tableau

  But : fonction recevant un tableau de type inconnu emis par le serveur

  Arguments :
	nsock      : descripteur de socket
	TabN       : nombre d'octets a recevoir
	Tablg      : pointeur sur le tableau a recevoir
	Tabtyp     : type des elements du tableau
	code_param : code du parametre a recevoir

  Retour           : compte-rendu d'execution

  Appelee par    : TSRSigRg
		   TSRSigX
		   TSXtrRg
		   TSXtrX
		   TSGrpRg
		   TSGrpX

------------------------------------------------------------------------------*/
Longint FAR_PASCAL
Reception_Tableau (
     			int nsock,
     			char HUGE *Tab,
     			Longint Tablg,
     			char *Tabtyp,
     			Longint code_param        )
{
  short int  HUGE *S;	/* pointeur sur tableau de short             */
  unsigned short int HUGE *US; /* pointeur sur tableau de short non signes  */
  Longint  HUGE *L;            /* pointeur sur tableau de long              */

#ifdef __alpha
  unsigned int HUGE *UL;   /* pointeur sur longs (32bits) non signes   */
#else
  unsigned long HUGE *UL;   /* pointeur sur tableau de long non signes   */
#endif

  float  HUGE *F;      /* pointeur sur tableau de flottants            */
  Double HUGE *D;      /* pointeur sur tableau de double               */
  char   HUGE *C;      /* pointeur sur tableau de caracteres           */

  Longint i;                   /* indice de boucle          */
  Longint Tablg2;              /* longueur du tableau C     */
  Longint Resultat;            /* compte-rendu d'execution  */

/* COMPRESS */
  Longint lcomp;       /* longueur du tableau comprime  */
  char   HUGE *Cc;     /* pointeur sur tableau de caracteres comprimes */
/* COMPRESS */

  Resultat = ok;

  if (Tablg > 0)
    {
      /* reception dans C ou decompression dans C */
      C = (char HUGE  *) MemAlloc (Tablg);

 if(compress_on) {
/****    Compress    ****/
      if ((Resultat = Reception (nsock,(char *)&lcomp, sizeof(Longint),
           code_param)) != ok)
        return Resultat;

      /* reception des octets du tableau comprime */
      Cc = (char HUGE  *) MemAlloc (lcomp);
#if (client == PC)
      if ((Resultat = ReceptionHuge (nsock,Cc, lcomp, code_param))
          != ok)
#else
      if ((Resultat = Reception (nsock,Cc, lcomp, code_param))
          != ok)
#endif
        return Resultat;


   if(Tablg > MIN_SIZE)
     lzrw1_decompress (Cc, lcomp, C);
   else
     memcpy(C,Cc,Tablg);

   FreeMemory( Cc);

  }
 else  /* pas de mode compression */
  {
#if (client == PC)
      if ((Resultat = ReceptionHuge (nsock,C, Tablg, code_param))
	  != ok)
#else
      if ((Resultat = Reception (nsock,C, Tablg, code_param))
	  != ok)
#endif
	return Resultat;

  }

      /* tests sur le type emis et le type attendu */

      switch (Tabtyp[0])
	{

	case entier_court:
	  S = (short int HUGE *) C;
	  switch (tslib_reel)
	    {
	    case reel_simple:
	      Tablg2 = Tablg * (taille_float / taille_short);
	      F = (float HUGE *) MemAlloc (Tablg2);
	      for (i = 0; i < Tablg / taille_short; i++)
		F[i] = (float) S[i];
	      C = (char HUGE *) F;
	      for (i = 0; i < Tablg2; i++)
		Tab[i] = C[i];
	      FreeMemory( (void HUGE *)F);
	      break;
	    case reel_double:
	      Tablg2 = Tablg *
		(taille_double / taille_short);
	      D = (Double HUGE *) MemAlloc (Tablg2);
	      for (i = 0; i < Tablg / taille_short; i++)
		D[i] = (Double) S[i];
	      C = (char HUGE *) D;
	      for (i = 0; i < Tablg2; i++)
		Tab[i] = C[i];
		FreeMemory( (void HUGE *)D);
	    }
	    FreeMemory( (void HUGE *)S);
	  break;

	case entier_long:
	  L = (Longint HUGE *) C;
	  switch (tslib_reel)
	    {
	    case reel_simple:
	      Tablg2 = Tablg * (taille_float / taille_long);
	      F = (float HUGE *) MemAlloc (Tablg2);
	      for (i = 0; i < Tablg / taille_long; i++)
		F[i] = (float) L[i];
	      C = (char HUGE *) F;
	      for (i = 0; i < Tablg2; i++)
		Tab[i] = C[i];
		FreeMemory( (void HUGE *)F);
	      break;
	    case reel_double:
	      Tablg2 = Tablg * (taille_double / taille_long);
	      D = (Double HUGE *) MemAlloc (Tablg2);
	      for (i = 0; i < Tablg / taille_long; i++)
		D[i] = (Double) L[i];
	      C = (char HUGE *) D;
	      for (i = 0; i < Tablg2; i++)
		Tab[i] = C[i];
		FreeMemory( (void HUGE *)D);
	    }
	    FreeMemory( (void HUGE *)L);

	  break;

	case non_signe:

	  switch (Tabtyp[1])
	    {
	    case entier_court:
	      US = (unsigned short int HUGE *) C;
	      switch (tslib_reel)
		{
		case reel_simple:
		  Tablg2 = Tablg * (taille_float / taille_short);
		  F = (float HUGE *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablg / taille_short; i++)
		    F[i] = (float) US[i];
		  C = (char HUGE *) F;
		  for (i = 0; i < Tablg2; i++)
		    Tab[i] = C[i];
		    FreeMemory( (void HUGE *)F);
		  break;

		case reel_double:
		  Tablg2 = Tablg *
		    (taille_double / taille_short);
		     D = (Double HUGE *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablg / taille_short; i++)
		    D[i] = (Double) US[i];
		  C = (char HUGE *) D;
		  for (i = 0; i < Tablg2; i++)
		    Tab[i] = C[i];
		    FreeMemory( (void HUGE *)D);
		}
		FreeMemory( (void HUGE *)US);

	      break;


	    case entier_long:
#ifdef __alpha
	      UL = (unsigned int HUGE *) C;
#else
	      UL = (unsigned long HUGE *) C;
#endif
	      switch (tslib_reel)
		{
		case reel_simple:
		  Tablg2 = Tablg * (taille_float / taille_long);
		  F = (float HUGE *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablg / taille_long; i++)
		    F[i] = (float) UL[i];
		  C = (char HUGE *) F;
		  for (i = 0; i < Tablg2; i++)
		    Tab[i] = C[i];
		    FreeMemory( (void HUGE *)F);
		  break;

		case reel_double:
		  Tablg2 = Tablg * (taille_double / taille_long);
		  D = (Double HUGE *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablg / taille_long; i++)
		    D[i] = (Double) UL[i];
		  C = (char HUGE *) D;
		  for (i = 0; i < Tablg2; i++)
		    Tab[i] = C[i];
		    FreeMemory( (void HUGE *)D);
		}
		FreeMemory( (void HUGE *)UL);
	    }
	  break;


	case reel_simple:
	  switch (tslib_reel)
	    {
	    case reel_double:
	      F = (float HUGE *) C;
	      Tablg2 = Tablg * (taille_double / taille_float);
	      D = (Double HUGE *) MemAlloc (Tablg2);
	      for (i = 0; i < Tablg / taille_float; i++)
		D[i] = (Double) F[i];
	      C = (char HUGE *) D;
	      for (i = 0; i < Tablg2; i++)
		Tab[i] = C[i];
		FreeMemory( (void HUGE *)F);
		FreeMemory( (void HUGE *)D);
	      break;

	    case reel_simple:
	      for (i = 0; i < Tablg; i++)
		Tab[i] = C[i];
		FreeMemory( (void HUGE *)C);
	    }
	  break;

	case reel_double:
	  switch (tslib_reel)
	    {
	    case reel_simple:
	      D = (Double HUGE *) C;
	      Tablg2 = Tablg / (taille_double / taille_float);
	      F = (float HUGE *) MemAlloc (Tablg2);
	      for (i = 0; i < Tablg / taille_double; i++)
		{
		  F[i] = (float) D[i];
		}
	      C = (char HUGE *) F;
	      for (i = 0; i < Tablg2; i++)
		Tab[i] = C[i];
		FreeMemory( (void HUGE *)F);
		FreeMemory( (void HUGE *)D);
	      break;
	    case reel_double:
	      for (i = 0; i < Tablg; i++)
		Tab[i] = C[i];
		FreeMemory( (void HUGE *)C);
	    }
	  break;
	default:
	  for (i = 0; i < Tablg; i++)
	    Tab[i] = C[i];
	    FreeMemory( (void HUGE *)C);
	}

    }
  return Resultat;
}

/*----------------------------------------------------------------------------

			Reception_Tab_Coord

  But : fonction recevant le tableau de coordonnees emis par le serveur

  Arguments :
	nsock      : descripteur de socket
	TabN       : nombre d'octets a recevoir
	Tablg      : pointeur sur le tableau a recevoir
	Tabtyp     : type des elements du tableau
	Typtab     : type du tableau (i,j,k uniques ou multiples)
	code_param : code du parametre a recevoir

  Retour           : compte-rendu d'execution

  Appelee par    : TSXtrRg
		   TSXtrX
		   TSGrpRg
		   TSGrpX

------------------------------------------------------------------------------*/
Longint FAR_PASCAL
Reception_Tab_Coord (
			int nsock,
			char  *Tab,
     			Longint *Tablg,
    			char *Tabtyp,
     			Longint Typtab,
     			Longint code_param  )
{
  short int *S;              /* pointeur sur tableau de short              */
  unsigned short int *US;    /* pointeur sur tableau de short non signes   */
  Longint *L;                /* pointeur sur tableau de long              */
#ifdef __alpha
  unsigned int *UL;      /* pointeur sur tableau de long non signes   */
#else
  unsigned long *UL;      /* pointeur sur tableau de long non signes   */
#endif
  float *F;                  /* pointeur sur tableau de flottants          */
  Double *D;                 /* pointeur sur tableau de double             */
  char *C;                   /* pointeur sur tableau de caracteres         */
  pS_LisCoord tab_temp;      /* structure de tableaux de coordonnees       */
  pS_LisCoord tab_prec;      /* structure de tableaux de coordonnees       */
  pS_LisCoord tab_deb;       /* structure de tableaux de coordonnees       */
  char *ind_tab;             /* pointeur sur le tableau des coordonnees    */
  char *ctab;                /* pointeur sur le tableau des coordonnees    */
  int i, j;                  /* indice de boucle                           */
  Longint Tablg2;            /* longueur du tableau C                      */
  Longint Tablong[MAX_INDICE]; /* longueur des coordonnees                */
  Longint Resultat;            /* compte-rendu d'execution                   */

  Resultat = ok;

  if (Tablg[0] > 0)
    {

      /* reception des octets du tableau Tab */

      switch (Typtab)
	{
	case UNIQ:
	  Tablg2 = *Tablg;
	  break;
	case MULT:
	  Tablg2 = 0;
	  for (i = 0; i < MAX_INDICE; i++)
	    Tablg2 = Tablg2 + Tablg[i];
	}

      ctab = (char  *) MemAlloc (Tablg2);
      if ((Resultat = Reception (nsock, ctab, Tablg2, code_param))
	  != ok)
	return Resultat;

      /* remplissage du tableau des longueurs par coordonnees */

      switch (Typtab)
	{
	case UNIQ:
	  for (i = 0; i < MAX_INDICE; i++)
	    switch (Tabtyp[i * 2])
	      {
	      case entier_court:
		Tablong[i] = taille_short;
		break;
	      case entier_long:
		Tablong[i] = taille_long;
		break;
	      case reel_simple:
		Tablong[i] = taille_float;
		break;
	      case reel_double:
		Tablong[i] = taille_double;
		break;
	      case non_signe:
		switch (Tabtyp[(i * 2) + 1])
		  {
		  case entier_court:
		    Tablong[i] = taille_short;
		    break;
		  case entier_long:
		    Tablong[i] = taille_long;
		  }
		break;
	      default:
		Tablong[i] = 0;
	      }
	  break;
	case MULT:
	  for (i = 0; i < MAX_INDICE; i++)
	    Tablong[i] = Tablg[i];
	  break;
	}

      /* tests sur le type emis et le type attendu */

      ind_tab = ctab;
      tab_temp = tab_deb = tab_prec = NULL;
      for (j = 0; j < (MAX_INDICE || (Tablg[j] == 0)) ; j++)
	{
		tab_temp = (pS_LisCoord) MemAlloc (
					   sizeof (struct S_LisCoord));
	  if (tab_deb == NULL)
	    tab_deb = tab_temp;
	  if (tab_prec != NULL)
	    tab_prec->ps_suivant = tab_temp;
	  tab_temp->nb_octets = 0;
	  tab_temp->ps_suivant = NULL;
	  switch (Tabtyp[0])
	    {

	    case entier_court:
	      S = (short int  *) ind_tab;
	      switch (tslib_reel)
		{
		case reel_simple:
		  Tablg2 = Tablong[j] *
		    (taille_float / taille_short);
		  F = (float  *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablong[j] / taille_short; i++)
		    F[i] = (float) S[i];
		  C = (char  *) F;
		  break;
		case reel_double:
		  Tablg2 = Tablong[j] *
		    (taille_double / taille_short);
		  D = (Double  *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablong[j] / taille_short; i++)
		    D[i] = (Double) S[i];
		  C = (char  *) D;
		}
	      tab_temp->nb_octets = Tablg2;
	      tab_temp->table = (char  *) MemAlloc (Tablg2);
	      for (i = 0; i < Tablg2; i++)
		tab_temp->table[i] = C[i];
		FreeMemory( (void  *)C);
		FreeMemory( (void  *)S);
	      switch (tslib_reel)
		{
		case reel_simple:
		    FreeMemory( (void  *)F);
		  break;
		case reel_double:
		    FreeMemory( (void  *)D); 
		  break;
		}
	      break;

	    case entier_long:
	      L = (Longint  *) ind_tab;
	      switch (tslib_reel)
		{
		case reel_simple:
		  Tablg2 = Tablong[j] *
		    (taille_float / taille_long);
		  F = (float  *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablong[j] / taille_long; i++)
		    F[i] = (float) L[i];
		  C = (char  *) F;
		  break;
		case reel_double:
		  Tablg2 = Tablong[j] *
		    (taille_double / taille_long);
		  D = (Double  *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablong[j] / taille_long; i++)
		    D[i] = (Double) L[i];
		  C = (char  *) D;
		}
	      tab_temp->nb_octets = Tablg2;
	      tab_temp->table = (char  *) MemAlloc (Tablg2);
	      for (i = 0; i < Tablg2; i++)
		tab_temp->table[i] = C[i];
		FreeMemory( (void  *)C);
		FreeMemory( (void  *)L);
	      switch (tslib_reel)
		{
		case reel_simple:
		    FreeMemory( (void  *)F);
		  break;
		case reel_double:
/* AIE AIE	    FreeMemory( (void  *)D); */
		  break;
		}

	      break;

	    case non_signe:

	      switch (Tabtyp[1])
		{
		case entier_court:
		  US = (unsigned short int  *) ind_tab;
		  switch (tslib_reel)
		    {
		    case reel_simple:
		      Tablg2 = Tablong[j] *
			(taille_float / taille_short);
		      F = (float  *) MemAlloc (Tablg2);
		      for (i = 0; i < Tablong[j] / taille_short; i++)
			F[i] = (float) US[i];
		      C = (char  *) F;
		      break;

		    case reel_double:
		      Tablg2 = Tablong[j] *
			(taille_double / taille_short);
		      D = (Double  *) MemAlloc (Tablg2);
		      for (i = 0; i < Tablong[j] / taille_short; i++)
			D[i] = (Double) US[i];
		      C = (char  *) D;
		    }
		  tab_temp->nb_octets = Tablg2;
		  tab_temp->table = (char  *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablg2; i++)
		    tab_temp->table[i] = C[i];
		    FreeMemory( (void  *)C);
		    FreeMemory( (void  *)US);
		  switch (tslib_reel)
		    {
		    case reel_simple:
			FreeMemory( (void  *)F);
		      break;
		    case reel_double:
			FreeMemory( (void  *)D);
		      break;
		    }

		  break;


		case entier_long:
#ifdef __alpha
		  UL = (unsigned int  *) ind_tab;
#else
		  UL = (unsigned long  *) ind_tab;
#endif
		  switch (tslib_reel)
		    {
		    case reel_simple:
		      Tablg2 = Tablong[j] *
			(taille_float / taille_long);
		      F = (float  *) MemAlloc (Tablg2);
		      for (i = 0; i < Tablong[j] / taille_long; i++)
			F[i] = (float) UL[i];
		      C = (char  *) F;
		      break;

		    case reel_double:
		      Tablg2 = Tablong[j] *
			(taille_double / taille_long);
		      D = (Double  *) MemAlloc (Tablg2);
		      for (i = 0; i < Tablong[j] / taille_long; i++)
			D[i] = (Double) UL[i];
		      C = (char  *) D;
		    }
		  tab_temp->nb_octets = Tablg2;
		  tab_temp->table = (char  *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablg2; i++)
		    tab_temp->table[i] = C[i];
		    FreeMemory( (void  *)C);
		    FreeMemory( (void  *)UL);
		  switch (tslib_reel)
		    {
		    case reel_simple:
			FreeMemory( (void  *)F);
		      break;
		    case reel_double:
			FreeMemory( (void  *)D);
		      break;
		    }
		}
	      break;


	    case reel_simple:
	      switch (tslib_reel)
		{
		case reel_double:
		  F = (float  *) ind_tab;
		  Tablg2 = Tablong[j] * (taille_double / taille_float);
		  D = (Double  *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablong[j] / taille_float; i++)
		    D[i] = (Double) F[i];
		  C = (char  *) D;
		  tab_temp->nb_octets = Tablg2;
		  tab_temp->table = (char  *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablg2; i++)
		    tab_temp->table[i] = C[i];
		 /*   FreeMemory(C); */
		 /* MODIF  AOUT  FreeMemory(F); */
		    FreeMemory(D);
		  break;
		case reel_simple:
		  tab_temp->nb_octets = Tablong[j];
		  Tablg2 = Tablong[j];
		  tab_temp->table = (char  *) MemAlloc (Tablong[j]);
		  for (i = 0; i < Tablong[j]; i++)
		    tab_temp->table[i] = ind_tab[i];
		}

	      break;

	    case reel_double:
	      switch (tslib_reel)
		{
		case reel_simple:
		  D = (Double  *) ind_tab;
		  Tablg2 = Tablong[j] / (taille_double / taille_float);
		  F = (float  *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablong[j] / taille_double; i++)
		    F[i] = (float) D[i];
		  C = (char  *) F;
		  tab_temp->nb_octets = Tablg2;
		  tab_temp->table = (char  *) MemAlloc (Tablg2);
		  for (i = 0; i < Tablg2; i++)
		    tab_temp->table[i] = C[i];
		    FreeMemory( (void  *)C);
		    FreeMemory( (void  *)F);
		    FreeMemory( (void  *)D);
		  break;
		case reel_double:
		  tab_temp->nb_octets = Tablong[j];
		  Tablg2 = Tablong[j];
		  tab_temp->table = (char  *) MemAlloc (Tablong[j]);
		  for (i = 0; i < Tablong[j]; i++)
		    tab_temp->table[i] = ind_tab[i];
		}
	      break;
	    default:
	      tab_temp->nb_octets = Tablong[j];
	      Tablg2 = Tablong[j];
	      tab_temp->table = (char  *) MemAlloc (Tablong[j]);
	      for (i = 0; i < Tablong[j]; i++)
		tab_temp->table[i] = ind_tab[i];
	    }                   /*end switch*/

	  tab_prec = tab_temp;
	  ind_tab = ind_tab + Tablong[j];
	}                       /*end for*/

      /* reconstitution du tableau des coordonnees */

      tab_temp = tab_deb;
      j = 0;
      while (tab_temp != NULL)
	{
	  if (tab_temp->nb_octets > 0)
	    for (i = 0; i < tab_temp->nb_octets; i++, j++)
	      Tab[j] = tab_temp->table[i];
	  tab_deb = tab_temp;
	  tab_temp = tab_deb->ps_suivant;
	  FreeMemory( (void  *)tab_deb);
	}
/* 	FreeMemory( (void  *)ctab); */

    }
  return (Resultat);
}


void * MemAlloc( Longint byte )
{
   void * result;

#if ( client == PC )
   result =  GlobalLock( GlobalAlloc (
		GMEM_MOVEABLE, byte ) );        
#else
   result =  malloc ( byte );        
#endif

   return( result );
}


void FreeMemory( void * F )
{
#if (client == PC )
{
GLOBALHANDLE hMemory;
if( F == NULL)
    return;
hMemory= (GLOBALHANDLE) GlobalHandle( (UINT) SELECTOROF( F ) );
	GlobalUnlock(hMemory);
	GlobalFree(hMemory);
}
#else
	free (F);
#endif
}


#define TRUE 1
#define UBYTE unsigned char   /* Unsigned  byte (1 byte )        */
#define UWORD unsigned short  /* Unsigned  word (2 bytes)        */

#ifdef __alpha
#define ULONG unsigned int    /* Unsigned longword (4 bytes) !!! */
#else
#define ULONG unsigned long   /* Unsigned longword (4 bytes)      */
#endif

#define FLAG_BYTES    4     /* Number of bytes used by copy flag. */
#define FLAG_COMPRESS 0     /* Signals that compression occurred. */
#define FLAG_COPY     1     /* Signals that a copyover occurred.  */

void fast_copy(p_src,p_dst,len) /* Fast copy routine.             */
UBYTE *p_src,*p_dst; 
  {
   while (len--) *p_dst++=*p_src++;
  }


void lzrw1_decompress(p_src_first,src_len,p_dst_first)
/* Input  : Specify input block using p_src_first and src_len.         */
/* Input  : Point p_dst_first to the start of the output zone.         */
/* Input  : Input block and output zone must not overlap. User knows   */
/* Input  : upperbound on output block length from earlier compression */
/* Input  : In any case, maximum expansion possible is eight times.    */
/* Output : Length of output block written to *p_dst_len.              */
/* Output : Output block in Mem[p_dst_first..p_dst_first+*p_dst_len-1] */
/* Output : Writes only  in Mem[p_dst_first..p_dst_first+*p_dst_len-1] */
UBYTE *p_src_first, *p_dst_first; ULONG src_len;
{
UWORD controlbits=0, control;
 UBYTE *p_src=p_src_first+FLAG_BYTES, *p_dst=p_dst_first,
       *p_src_post=p_src_first+src_len;
 if (*p_src_first==FLAG_COPY)
   {fast_copy(p_src_first+FLAG_BYTES,p_dst_first,src_len-FLAG_BYTES);
    return;}
 while (p_src!=p_src_post)
   {if (controlbits==0)
      {control=*p_src++; control|=(*p_src++)<<8; controlbits=16;}
    if (control&1)
      {UWORD offset,len; UBYTE *p;
       offset=(*p_src&0xF0)<<4; len=1+(*p_src++&0xF);
       offset+=*p_src++&0xFF; p=p_dst-offset;
       while (len--) *p_dst++=*p++;}
    else
       *p_dst++=*p_src++;
    control>>=1; controlbits--;
   }
}

