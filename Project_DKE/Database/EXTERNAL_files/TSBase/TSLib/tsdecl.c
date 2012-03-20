/*****************************************************************************

   NOM  DU MODULE        :  tsdecl.c

   DESCRIPTION DU MODULE :  module client de la bibliotheque TSLib
                            ensemble des fonctions de lecture de donnees brutes

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   29/09/92
   Modifications    :

 *****************************************************************************/

/*****************************************************************************

   Liste des fonctions du module :

        TSSigDeclenche
        TSXtrDeclenche
        TSGrpDeclenche

 *****************************************************************************/
#include <stdio.h>		/* bibliotheques standards           */
#include <stdlib.h>
#include <string.h>
#include "tsdef.h"		/* liste des constantes utilisees */
#include "tsconf.h"		/* configuration du client        */
#if (client == MAC)

#endif

#include "tsfonc.h"		/* liste des fonctions appelees   */
#include "tsmes.h"		/* liste des erreurs              */
#include "tstype.h"		/* liste des types de donnees     */
#include "tsext.h"		/* liste des variables globales   */
#include "functs.h"		/* prototypes fcts TSLib */
/*----------------------------------------------------------------------------

                        TSSigDeclenche

  But : fonction demandant au serveur de lui renvoyer les valeurs d'un signal
        brut pour une occurrence d'une declenche donnee

  Arguments :
        NomDon    : nom de la donnee
        NumChoc   : numero de choc
        NomDec    : nom d'une declenche
        Occur     : occurrence d'une declenche
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre de valeurs trouvees
        T         : tableau des valeurs des temps
        Y         : tableau des valeurs des mesures

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/
Longint FAR_PASCAL
TSSigDeclenche (	char *NomDon,
			Longint NumChoc,
			char *NomDec,
			Longint Occur,
			Longint NbMax,
			Longint Extract,
			pS_Unite *Unite,
			Longint *NumVer,
			char *Date,
			char *Heure,
			Longint *NbMes,
			Longint *MaxReel,
			char HUGE *T,
			char HUGE *Y )  
{
  Longint CR;
  Longint TNb;			/* taille en octets du tableau T  */
  Longint YNb;			/* taille en octets du tableau Y  */
  char TType[2];		/* type des elements du tableau T  */
  char YType[2];		/* type des elements du tableau Y  */
  Longint code_param;

#if (client == MAC)
  ConnHandle NumSocket;		/* descripteur de la socket de communication */
#else
  int NumSocket;		/* descripteur de la socket de communication */
#endif
  short int CodeFonc;		/* code de la fonction TSLib appelee         */
  Longint Resultat;		/* compte-rendu d'execution du client        */

  /* test des pointeurs de chaines */

  code_param = ok;

  if (NomDon == NULL)
    code_param = p_nomdon;
  if (NomDec == NULL)
    code_param = p_nomdec;
  if (Date == NULL)
    code_param = p_date;
  if (Heure == NULL)
    code_param = p_heure;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* test des pointeurs de tableaux */

  if (T == NULL)
    code_param = p_t;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  /* debut de communication */

      if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

  /* emission du code de la fonction */

  if( compress_on )
    CodeFonc = fonc_tssigdeclenche;
  else
    CodeFonc = fonc_tssigdeclenche - MAX_FUNCT_NUMBER;

  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      != ok)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdon))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &NumChoc, taille_long, p_numchoc))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, NomDec, TAILLE_NOM_DECLENCHE, p_nomdec))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &Occur, taille_long, p_occur))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &NbMax, taille_long, p_nbmax))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &Extract, taille_long, p_extract))
      != ok)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      != ok)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception_Unite (NumSocket, Unite, p_unite))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) NumVer, taille_long, p_numver))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, Date, TAILLE_DATE, p_date))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, Heure, TAILLE_HEURE, p_heure))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) NbMes, taille_long, p_nbmes))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) MaxReel, taille_long, p_maxreel))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) &TNb, taille_long, p_t))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, TType, TAILLE_FORMAT_SERVEUR, p_t))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, T, TNb, TType, p_t))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) &YNb, taille_long, p_y))
	  != ok)
	return Resultat;

      if ((YNb != 0) && (Y == NULL))
	{
	  Fin_Communication (NumSocket);
	  return (Gestion_Erreur (erreur_tableau_vide, p_y));
	}

      if ((Resultat = Reception (NumSocket, YType, TAILLE_FORMAT_SERVEUR, p_y))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, Y, YNb, YType, p_y))
	  != ok)
	return Resultat;
    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

/*----------------------------------------------------------------------------

                        TSXtrDeclenche

  But : fonction demandant au serveur de lui renvoyer les valeurs d'un signal
        brut extrait d'un groupe pour une occurrence d'une declenche donnee

  Arguments :
        NomDon    : nom de la donnee
        NumChoc   : numero de choc
        Indices   : tableau des indices du signal dans le groupe
        NomDec    : nom d'une declenche
        Occur     : occurrence d'une declenche
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre de valeurs trouvees
        T         : tableau des valeurs des temps
        Y         : tableau des valeurs des mesures

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/
Longint FAR_PASCAL
TSXtrDeclenche (	char *NomDon,
			Longint NumChoc,
			Longint *Indices,
			char *NomDec,
			Longint Occur,
			Longint NbMax,
			Longint Extract,
			pS_Unite *Unite,
			Longint *NumVer,
			char *Date,
			char *Heure,
			Longint *NbMes,
			Longint *MaxReel,
			char HUGE *T,
			char HUGE *Y    )

{
  Longint CR;
  Longint TNb;			/* taille en octets du tableau T  */
  Longint YNb;			/* taille en octets du tableau Y  */
  char TType[2];		/* type des elements du tableau T */
  char YType[2];		/* type des elements du tableau Y */
  Longint code_param;

#if (client == MAC)
  ConnHandle NumSocket;		/* descripteur de la socket de communication */
#else
  int NumSocket;		/* descripteur de la socket de communication */
#endif
  short int CodeFonc;		/* code de la fonction TSLib appelee         */
  Longint Resultat;		/* compte-rendu d'execution du client        */


  /* test des pointeurs de chaines */

  code_param = ok;

  if (NomDon == NULL)
    code_param = p_nomdon;
  if (NomDec == NULL)
    code_param = p_nomdec;
  if (Date == NULL)
    code_param = p_date;
  if (Heure == NULL)
    code_param = p_heure;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* test des pointeurs de tableaux */

  if (T == NULL)
    code_param = p_t;
  if (Indices == NULL)
    code_param = p_indices;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  /* debut de communication */
      if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

  /* emission du code de la fonction */
  if (compress_on)
    CodeFonc = fonc_tsxtrdeclenche;
  else
    CodeFonc = fonc_tsxtrdeclenche - MAX_FUNCT_NUMBER;
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      != ok)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdon))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &NumChoc, taille_long, p_numchoc))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) Indices, MAX_INDICE * taille_long,
			    p_indices))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, NomDec, TAILLE_NOM_DECLENCHE, p_nomdec))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &Occur, taille_long, p_occur))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &NbMax, taille_long, p_nbmax))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &Extract, taille_long, p_extract))
      != ok)
    return Resultat;


  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif


  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      != ok)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception_Unite (NumSocket, Unite, p_unite))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) NumVer, taille_long, p_numver))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, Date, TAILLE_DATE, p_date))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, Heure, TAILLE_HEURE, p_heure))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) NbMes, taille_long, p_nbmes))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) MaxReel, taille_long, p_maxreel))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) &TNb, taille_long, p_t))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, TType, TAILLE_FORMAT_SERVEUR, p_t))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, T, TNb, TType, p_t))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) &YNb, taille_long, p_y))
	  != ok)
	return Resultat;

      if ((YNb != 0) && (Y == NULL))
	{
	  Fin_Communication (NumSocket);
	  return (Gestion_Erreur (erreur_tableau_vide, p_y));
	}

      if ((Resultat = Reception (NumSocket, YType, TAILLE_FORMAT_SERVEUR, p_y))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, Y, YNb, YType, p_y))
	  != ok)
	return Resultat;

    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

/*----------------------------------------------------------------------------

                        TSGrpDeclenche

  But : fonction demandant au serveur de lui renvoyer les valeurs d'un groupe
        de signaux bruts pour une occurrence d'une declenche donnee

  Arguments :
        NomDon    : nom de la donnee
        NumChoc   : numero de choc
        NomDec    : nom d'une declenche
        Occur     : occurrence d'une declenche
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre de valeurs trouvees
        T         : tableau des valeurs des temps
        Y         : tableau des valeurs des mesures

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/
Longint FAR_PASCAL
TSGrpDeclenche (	char *NomDon,
			Longint NumChoc,
			char *NomDec,
			Longint Occur,
			Longint NbMax,
			Longint Extract,
			pS_Unite *Unite,
			Longint *NumVer,
			char *Date,
			char *Heure,
			Longint *NbMes,
			Longint *MaxReel,
			char HUGE *T,
			char HUGE *Y    )
{
  Longint CR;
  Longint TNb;			/* taille en octets du tableau T  */
  Longint YNb;			/* taille en octets du tableau Y  */
  char TType[2];		/* type des elements du tableau T */
  char YType[2];		/* type des elements du tableau Y */
  Longint code_param;

#if (client == MAC)
  ConnHandle NumSocket;		/* descripteur de la socket de communication */
#else
  int NumSocket;		/* descripteur de la socket de communication */
#endif
  short int CodeFonc;		/* code de la fonction TSLib appelee         */
  Longint Resultat;		/* compte-rendu d'execution du client        */


  /* test des pointeurs de chaines */

  code_param = ok;

  if (NomDon == NULL)
    code_param = p_nomdon;
  if (NomDec == NULL)
    code_param = p_nomdec;
  if (Date == NULL)
    code_param = p_date;
  if (Heure == NULL)
    code_param = p_heure;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* test des pointeurs de tableaux */

  if (T == NULL)
    code_param = p_t;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));


  /* debut de communication */
      if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

  /* emission du code de la fonction */
  if(compress_on)
    CodeFonc = fonc_tsgrpdeclenche;
  else
    CodeFonc = fonc_tsgrpdeclenche - MAX_FUNCT_NUMBER;
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      != ok)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdon))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &NumChoc, taille_long, p_numchoc))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, NomDec, TAILLE_NOM_DECLENCHE, p_nomdec))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &Occur, taille_long, p_occur))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &NbMax, taille_long, p_nbmax))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &Extract, taille_long, p_extract))
      != ok)
    return Resultat;


  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      != ok)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception_Unite (NumSocket, Unite, p_unite))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) NumVer, taille_long, p_numver))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, Date, TAILLE_DATE, p_date))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, Heure, TAILLE_HEURE, p_heure))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) NbMes, MAX_MESURE * taille_long, p_nbmes))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) MaxReel, taille_long, p_maxreel))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) &TNb, taille_long, p_t))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, TType, TAILLE_FORMAT_SERVEUR, p_t))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, T, TNb, TType, p_t))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) &YNb, taille_long, p_y))
	  != ok)
	return Resultat;

      if ((YNb != 0) && (Y == NULL))
	{
	  Fin_Communication (NumSocket);
	  return (Gestion_Erreur (erreur_tableau_vide, p_y));
	}

      if ((Resultat = Reception (NumSocket, YType, TAILLE_FORMAT_SERVEUR, p_y))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, Y, YNb, YType, p_y))
	  != ok)
	return Resultat;

    }

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
