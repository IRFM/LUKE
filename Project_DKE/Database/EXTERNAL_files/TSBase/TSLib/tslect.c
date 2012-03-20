/*****************************************************************************

   NOM  DU MODULE        :  tslect.c

   DESCRIPTION DU MODULE :  module client de la bibliotheque TSLib
                            ensemble des fonctions de lectures de donnees

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   29/09/92
   Modifications    :

 *****************************************************************************/

/*****************************************************************************

   Liste des fonctions du module :

        TSRSigRg
        TSRSigX
        TSXtrRg
        TSXtrX
        TSGrpRg
        TSGrpX

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

                        TSRSigRg

  But : fonction demandant au serveur de lui renvoyer un signal lu entre 2 rangs

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        Rangs     : tableau contenant le rang initial et le rang final
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/


Longint FAR_PASCAL
TSRSigRg (	char *NomDon,
     		pS_Entree Entrees,
     		Longint *Rangs,
     		Longint NbMax,
     		Longint Extract,
     		pS_Unite *Unite,
     		Longint *NumVer,
     		Longint *Certif,
     		char *Date,
     		char *Heure,
     		Longint *NbMes ,
     		Longint *MaxReel ,
     		char  HUGE *X ,
		char  HUGE *Y        )

{
  Longint CR;
  Longint CertifNb;		/* taille en octets du tableau Certif  */
  Longint XNb;			/* taille en octets du tableau X       */
  Longint YNb;			/* taille en octets du tableau Y       */
  char XType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau X */
  char YType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau Y */
  Longint code_param;
  Longint numchoc;

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
  if (Date == NULL)
    code_param = p_date;
  if (Heure == NULL)
    code_param = p_heure;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* test des pointeurs de tableaux */

  if (Certif == NULL)
    code_param = p_certif;
  if (Rangs == NULL)
    code_param = p_rangs;

  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  /* debut de communication */

  numchoc = Entrees->union_var.lval;
  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

  /* emission du code de la fonction */
  if(compress_on)
    CodeFonc = fonc_tsrsigrg;
  else
    CodeFonc = -(fonc_tsrsigrg - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      != ok)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdon))
      != ok)
    return Resultat;

  if ((Resultat = Emission_Entrees (NumSocket, Entrees, p_entrees))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) Rangs, taille_long * MAX_RANG, p_rangs))
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

      if ((Resultat = Reception (NumSocket, (char *) &CertifNb, taille_long, p_certif))
	  != ok)
	return Resultat;
        if(CertifNb > 256) {
          int i;
          Longint *ptmp_certif=(Longint *)calloc(sizeof(Longint),CertifNb);
          if ((Resultat = Reception (NumSocket, (char *) ptmp_certif, CertifNb,
                          p_certif)) != ok)
            return Resultat;
          for(i=0; i < 64 ; i++) /* Tableau certif Bd =64 max */
            Certif[i]= ptmp_certif[i];
          }
          else
           if ((Resultat = Reception (NumSocket, (char *) Certif, CertifNb,
             p_certif)) != ok)
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

      if ((Resultat = Reception (NumSocket, (char *) &XNb, taille_long, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, XType, TAILLE_FORMAT_SERVEUR, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, X, XNb, XType, p_x))
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

                        TSRSigX

  But : fonction demandant au serveur de lui renvoyer un signal lu entre
        2 valeurs de l'abscisse

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        XI        : valeur initiale de l'abscisse
        XF        : valeur finale de l'abscisse
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/
Longint FAR_PASCAL
TSRSigX (    char *NomDon,
	pS_Entree Entrees,
	Double XI,
	Double XF,
	Longint NbMax,
	Longint Extract,
	pS_Unite *Unite,
	Longint *NumVer,
	Longint *Certif,
	char *Date,
	char *Heure,
	Longint *NbMes,
	Longint *MaxReel,
	char HUGE *X,
	char HUGE *Y    )

{
  Longint CR;
  Longint CertifNb;		/* taille en octets du tableau Certif   */
  Longint XNb;			/* taille en octets du tableau X        */
  Longint YNb;			/* taille en octets du tableau Y        */
  char XType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau X */
  char YType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau Y */
  Longint code_param;
  Longint numchoc;

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
  if (Date == NULL)
    code_param = p_date;
  if (Heure == NULL)
    code_param = p_heure;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* test des pointeurs de tableaux */

  if (Certif == NULL)
    code_param = p_certif;
  if (X == NULL)
    code_param = p_x;

  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  /* debut de communication */

  numchoc = Entrees->union_var.lval;
      if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

  /* emission du code de la fonction */
  if(compress_on)
    CodeFonc = fonc_tsrsigx;
  else
    CodeFonc = -(fonc_tsrsigx - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      != ok)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdon))
      != ok)
    return Resultat;

  if ((Resultat = Emission_Entrees (NumSocket, Entrees, p_entrees))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &XI, taille_double, p_xi))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &XF, taille_double, p_xf))
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

      if ((Resultat = Reception (NumSocket, (char *) &CertifNb, taille_long, p_certif))
	  != ok)
	return Resultat;

       if(CertifNb > 256) {
          int i;
          Longint *ptmp_certif=(Longint *)calloc(sizeof(Longint),CertifNb);
          if ((Resultat = Reception (NumSocket, (char *) ptmp_certif, CertifNb,
                          p_certif)) != ok)
            return Resultat;
          for(i=0; i < 64 ; i++) /* Tableau certif Bd =64 max */
            Certif[i]= ptmp_certif[i];
          }
          else
           if ((Resultat = Reception (NumSocket, (char *) Certif, CertifNb,
             p_certif)) != ok)
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

      if ((Resultat = Reception (NumSocket, (char *) &XNb, taille_long, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, XType, TAILLE_FORMAT_SERVEUR, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, X, XNb, XType, p_x))
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

                        TSXtrRg

  But : fonction demandant au serveur de lui renvoyer un signal d'un groupe lu
        entre 2 rangs

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        Indices   : tableau contenant les indices du signal dans le groupe
        Rangs     : tableau contenant le rang initial et le rang final
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures
        Coord     : tableau des valeurs des autres coordonnees

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/
Longint FAR_PASCAL
TSXtrRg (    char *NomDon,
	pS_Entree Entrees,
	Longint *Indices,
	Longint *Rangs,
	Longint NbMax,
	Longint Extract,
	pS_Unite *Unite,
	Longint *NumVer,
	Longint *Certif,
	char *Date,
	char *Heure,
	Longint *NbMes,
	Longint *MaxReel,
	char HUGE *X,
	char HUGE *Y,
	char *Coord ) 

{
  Longint CR;
  Longint CertifNb;		/* taille en octets du tableau Certif     */
  Longint XNb;			/* taille en octets du tableau X          */
  Longint YNb;			/* taille en octets du tableau Y          */
  Longint CoordNb;		/* taille en octets du tableau   Coord    */
  char XType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau X */
  char YType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau Y */
  char CoordType[MAX_INDICE][TAILLE_FORMAT_SERVEUR];
  Longint code_param;
  Longint numchoc;

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
  if (Date == NULL)
    code_param = p_date;
  if (Heure == NULL)
    code_param = p_heure;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* test des pointeurs de tableaux */

  if (Certif == NULL)
    code_param = p_certif;
  if (Rangs == NULL)
    code_param = p_rangs;
  if (Indices == NULL)
    code_param = p_indices;
  if (X == NULL)
    code_param = p_x;

  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  /* debut de communication */

  numchoc = Entrees->union_var.lval;
      if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsxtrrg;
  else
    CodeFonc = -(fonc_tsxtrrg - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      != ok)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdon))
      != ok)
    return Resultat;

  if ((Resultat = Emission_Entrees (NumSocket, Entrees, p_entrees))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) Indices, MAX_INDICE * taille_long,
			    p_indices))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) Rangs, taille_long * MAX_RANG,
			    p_rangs))
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

      if ((Resultat = Reception (NumSocket, (char *) &CertifNb, taille_long, p_certif))
	  != ok)
	return Resultat;

       if(CertifNb > 256) {
          int i;
          Longint *ptmp_certif=(Longint *)calloc(sizeof(Longint),CertifNb);
          if ((Resultat = Reception (NumSocket, (char *) ptmp_certif, CertifNb,
                          p_certif)) != ok)
            return Resultat;
          for(i=0; i < 64 ; i++) /* Tableau certif Bd =64 max */
            Certif[i]= ptmp_certif[i];
          }
          else
           if ((Resultat = Reception (NumSocket, (char *) Certif, CertifNb,
             p_certif)) != ok)
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

      if ((Resultat = Reception (NumSocket, (char *) &XNb, taille_long, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, XType, TAILLE_FORMAT_SERVEUR, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, X, XNb, XType, p_x))
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

      if ((Resultat = Reception (NumSocket, (char *) &CoordNb, taille_long, p_coord))
	  != ok)
	return Resultat;

      if ((CoordNb != 0) && (Coord == NULL))
	{
	  Fin_Communication (NumSocket);
	  return (Gestion_Erreur (erreur_tableau_vide, p_coord));
	}

      if ((Resultat = Reception (NumSocket, (char *) CoordType,
			       MAX_INDICE * TAILLE_FORMAT_SERVEUR, p_coord))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tab_Coord ( NumSocket, Coord,
	 &CoordNb, (char *) CoordType, UNIQ, p_coord ))!= ok)
	return Resultat;

    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

/*----------------------------------------------------------------------------

                        TSXtrX

  But : fonction demandant au serveur de lui renvoyer un signal d'un groupe lu
        entre 2 valeurs de l'abscisse

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        Indices   : tableau contenant les indices du signal dans le groupe
        XI        : valeur initiale de l'abscisse
        XF        : valeur finale de l'abscisse
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures
        Coord     : tableau des valeurs des autres coordonnees

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

Longint FAR_PASCAL
TSXtrX (     char *NomDon,
	pS_Entree Entrees,
	Longint *Indices,
	Double XI,
	Double XF,
	Longint NbMax,
	Longint Extract,
	pS_Unite *Unite,
	Longint *NumVer,
	Longint *Certif,
	char *Date,
	char *Heure,
	Longint *NbMes,
	Longint *MaxReel,
	char HUGE *X,
	char HUGE *Y,
	char *Coord   )
{
  Longint CR;
  Longint CertifNb;		/* taille en octets du tableau Certif     */
  Longint XNb;			/* taille en octets du tableau X          */
  Longint YNb;			/* taille en octets du tableau Y          */
  Longint CoordNb;		/* taille en octets du tableau   Coord    */
  char XType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau X */
  char YType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau Y */
  char CoordType[MAX_INDICE][TAILLE_FORMAT_SERVEUR];
  Longint code_param;
  Longint numchoc;

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
  if (Date == NULL)
    code_param = p_date;
  if (Heure == NULL)
    code_param = p_heure;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* test des pointeurs de tableaux */

  if (Indices == NULL)
    code_param = p_indices;
  if (Certif == NULL)
    code_param = p_certif;
  if (X == NULL)
    code_param = p_x;

  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  /* debut de communication */

  numchoc = Entrees->union_var.lval;
      if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

  /* emission du code de la fonction */
  if(compress_on)
    CodeFonc = fonc_tsxtrx;
  else
    CodeFonc = -(fonc_tsxtrx - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      != ok)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdon))
      != ok)
    return Resultat;

  if ((Resultat = Emission_Entrees (NumSocket, Entrees, p_entrees))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) Indices, MAX_INDICE * taille_long,
			    p_indices))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &XI, taille_double, p_xi))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &XF, taille_double, p_xf))
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

      if ((Resultat = Reception (NumSocket, (char *) &CertifNb, taille_long, p_certif))
	  != ok)
	return Resultat;

       if(CertifNb > 256) {
          int i;
          Longint *ptmp_certif=(Longint *)calloc(sizeof(Longint),CertifNb);
          if ((Resultat = Reception (NumSocket, (char *) ptmp_certif, CertifNb,
                          p_certif)) != ok)
            return Resultat;
          for(i=0; i < 64 ; i++) /* Tableau certif Bd =64 max */
            Certif[i]= ptmp_certif[i];
          }
          else
           if ((Resultat = Reception (NumSocket, (char *) Certif, CertifNb,
             p_certif)) != ok)
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

      if ((Resultat = Reception (NumSocket, (char *) &XNb, taille_long, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, XType, TAILLE_FORMAT_SERVEUR, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, X, XNb, XType, p_x))
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

      if ((Resultat = Reception (NumSocket, (char *) &CoordNb, taille_long, p_coord))
	  != ok)
	return Resultat;

      if ((CoordNb != 0) && (Coord == NULL))
	{
	  Fin_Communication (NumSocket);
	  return (Gestion_Erreur (erreur_tableau_vide, p_coord));
	}

      if ((Resultat = Reception (NumSocket, (char *) CoordType,
			       MAX_INDICE * TAILLE_FORMAT_SERVEUR, p_coord))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tab_Coord (NumSocket, Coord, &CoordNb,
      		(char *) CoordType, UNIQ, p_coord)) != ok)
	return Resultat;
    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}


/*----------------------------------------------------------------------------

                        TSGrpRg

  But : fonction demandant au serveur de lui renvoyer un groupe de signaux lu
        entre 2 rangs donnes

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        Rangs     : tableau contenant le rang initial et le rang final
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures
        Coord     : tableau des valeurs des autres coordonnees

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/
Longint FAR_PASCAL
TSGrpRg (	char *NomDon,
     		pS_Entree Entrees,
     		Longint *Rangs,
     		Longint NbMax,
     		Longint Extract ,
     		pS_Unite *Unite,
     		Longint *NumVer,
     		Longint *Certif,
     		char *Date ,
     		char *Heure,
     		Longint *NbMes,
     		Longint *MaxReel,
     		char HUGE *X ,
     		char HUGE *Y,
		char *Coord )
{
  Longint CR;
  Longint CertifNb;		/* taille en octets du tableau Certif     */
  Longint XNb;			/* taille en octets du tableau X          */
  Longint YNb;			/* taille en octets du tableau Y          */
  Longint CoordNb[MAX_INDICE];	/* taille en octets du tableau   Coord    */
  char XType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau X */
  char YType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau Y */
  char CoordType[MAX_INDICE][TAILLE_FORMAT_SERVEUR];
  Longint code_param;
  Longint numchoc;

#if (client == MAC)
  ConnHandle NumSocket;		/* descripteur de la socket de communication */
#else
  int NumSocket;		/* descripteur de la socket de communication */
#endif
  short int CodeFonc;		/* code de la fonction TSLib appelee         */
  Longint Resultat;		/* compte-rendu d'execution du client        */

  /* test des pointeurs de chaines */

  /* test des pointeurs de chaines */

  code_param = ok;

  if (NomDon == NULL)
    code_param = p_nomdon;
  if (Date == NULL)
    code_param = p_date;
  if (Heure == NULL)
    code_param = p_heure;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* test des pointeurs de tableaux */

  if (Certif == NULL)
    code_param = p_certif;
  if (Rangs == NULL)
    code_param = p_rangs;
  if (X == NULL)
    code_param = p_x;

  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  /* debut de communication */

  numchoc = Entrees->union_var.lval;
      if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

  /* emission du code de la fonction */
  if(compress_on)
    CodeFonc = fonc_tsgrprg;
  else
    CodeFonc = -(fonc_tsgrprg - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      != ok)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdon))
      != ok)
    return Resultat;

  if ((Resultat = Emission_Entrees (NumSocket, Entrees, p_entrees))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) Rangs, MAX_RANG * taille_long,
			    p_rangs))
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

      if ((Resultat = Reception (NumSocket, (char *) &CertifNb, taille_long, p_certif))
	  != ok)
	return Resultat;

       if(CertifNb > 256) {
          int i;
          Longint *ptmp_certif=(Longint *)calloc(sizeof(Longint),CertifNb);
          if ((Resultat = Reception (NumSocket, (char *) ptmp_certif, CertifNb,
                          p_certif)) != ok)
            return Resultat;
          for(i=0; i < 64 ; i++) /* Tableau certif Bd =64 max */
            Certif[i]= ptmp_certif[i];
          }
          else
           if ((Resultat = Reception (NumSocket, (char *) Certif, CertifNb,
             p_certif)) != ok)
           return Resultat;

      if ((Resultat = Reception (NumSocket, Date, TAILLE_DATE, p_date))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, Heure, TAILLE_HEURE, p_heure))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) NbMes, MAX_MESURE * taille_long,
				 p_nbmes))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) MaxReel, taille_long, p_maxreel))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) &XNb, taille_long, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, XType, TAILLE_FORMAT_SERVEUR, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, X, XNb, XType, p_x))
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

      if ((Resultat = Reception (NumSocket, (char *) CoordNb, MAX_INDICE * taille_long,
				 p_coord))
	  != ok)
	return Resultat;

      if ((CoordNb[0] != 0) && (Coord == NULL))
	{
	  Fin_Communication (NumSocket);
	  return (Gestion_Erreur (erreur_tableau_vide, p_coord));
	}

      if ((Resultat = Reception (NumSocket, (char *) CoordType,
			       MAX_INDICE * TAILLE_FORMAT_SERVEUR, p_coord))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tab_Coord (NumSocket, Coord, CoordNb,
      		(char*) CoordType, MULT, p_coord)) != ok)
	return Resultat;
    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

/*----------------------------------------------------------------------------

                        TSGrpX

  But : fonction demandant au serveur de lui renvoyer un groupe de signaux lu
        entre 2 valeurs de l'abscisse

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        XI        : valeur initiale de l'abscisse
        XF        : valeur finale de l'abscisse
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures
        Coord     : tableau des valeurs des autres coordonnees

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/
Longint FAR_PASCAL
TSGrpX ( 	char *NomDon,
		pS_Entree Entrees,
		Double XI,
		Double XF,
		Longint NbMax,
		Longint Extract,
		pS_Unite *Unite,
		Longint *NumVer,
		Longint *Certif,
		char *Date,
		char *Heure,
		Longint *NbMes,
		Longint *MaxReel,
		char HUGE *X,
		char HUGE *Y,
		char *Coord  ) 

{
  Longint CR;
  Longint CertifNb;		/* taille en octets du tableau Certif     */
  Longint XNb;			/* taille en octets du tableau X          */
  Longint YNb;			/* taille en octets du tableau Y          */
  Longint CoordNb[MAX_INDICE];	/* taille en octets du tableau   Coord    */
  char XType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau X */
  char YType[TAILLE_FORMAT_SERVEUR];	/* type des elements du tableau Y */
  char CoordType[MAX_INDICE][TAILLE_FORMAT_SERVEUR];
  Longint code_param;
  Longint numchoc;

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
  if (Date == NULL)
    code_param = p_date;
  if (Heure == NULL)
    code_param = p_heure;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* test des pointeurs de tableaux */

  if (Certif == NULL)
    code_param = p_certif;
  if (X == NULL)
    code_param = p_x;

  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  /* debut de communication */

  numchoc = Entrees->union_var.lval;
      if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

  /* emission du code de la fonction */
  if(compress_on)
    CodeFonc = fonc_tsgrpx;
  else
    CodeFonc = -(fonc_tsgrpx - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      != ok)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdon))
      != ok)
    return Resultat;

  if ((Resultat = Emission_Entrees (NumSocket, Entrees, p_entrees))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &XI, taille_double, p_xi))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &XF, taille_double, p_xf))
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

      if ((Resultat = Reception (NumSocket, (char *) &CertifNb, taille_long, p_certif))
	  != ok)
	return Resultat;

       if(CertifNb > 256) {
          int i;
          Longint *ptmp_certif=(Longint *)calloc(sizeof(Longint),CertifNb);
          if ((Resultat = Reception (NumSocket, (char *) ptmp_certif, CertifNb,
                          p_certif)) != ok)
            return Resultat;
          for(i=0; i < 64 ; i++) /* Tableau certif Bd =64 max */
            Certif[i]= ptmp_certif[i];
          }
          else
           if ((Resultat = Reception (NumSocket, (char *) Certif, CertifNb,
             p_certif)) != ok)
           return Resultat;

      if ((Resultat = Reception (NumSocket, Date, TAILLE_DATE, p_date))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, Heure, TAILLE_HEURE, p_heure))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) NbMes, MAX_MESURE * taille_long,
				 p_nbmes))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) MaxReel, taille_long, p_maxreel))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) &XNb, taille_long, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, XType, TAILLE_FORMAT_SERVEUR, p_x))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tableau (NumSocket, X, XNb, XType, p_x))
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

      if ((Resultat = Reception (NumSocket, (char *) CoordNb, MAX_INDICE * taille_long,
				 p_coord))
	  != ok)
	return Resultat;

      if ((CoordNb[0] != 0) && (Coord == NULL))
	{
	  Fin_Communication (NumSocket);
	  return (Gestion_Erreur (erreur_tableau_vide, p_coord));
	}

      if ((Resultat = Reception (NumSocket, (char *) CoordType,
			       MAX_INDICE * TAILLE_FORMAT_SERVEUR, p_coord))
	  != ok)
	return Resultat;

      if ((Resultat = Reception_Tab_Coord (NumSocket, Coord, CoordNb,
		(char *) CoordType, MULT, p_coord)) != ok)
	return Resultat;

    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
