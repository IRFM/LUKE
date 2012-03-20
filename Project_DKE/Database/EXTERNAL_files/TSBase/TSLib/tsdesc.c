
/*****************************************************************************

   NOM  DU MODULE        :  tsdesc.c

   DESCRIPTION DU MODULE :  module client de la bibliotheque TSLib
			    ensemble des fonctions de lectures de description

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   29/09/92
   Modifications    :

 *****************************************************************************/

/*****************************************************************************

   Liste des fonctions du module :

	TSDescTrait
	TSDescDiag
	TSDescDon
	TSExist

 *****************************************************************************/
#include <stdio.h>              /* bibliotheques standards           */
#include <stdlib.h>
#include <string.h>
#include "tsdef.h"              /* liste des constantes utilisees */
#include "tsconf.h"             /* configuration du client        */
#if (client == MAC)

#endif
#include "tsfonc.h"             /* liste des fonctions appelees   */
#include "tsmes.h"              /* liste des erreurs              */
#include "tstype.h"             /* liste des types de donnees     */
#include "tsext.h"              /* liste des variables globales   */
#include "functs.h"		/* prototypes fcts TSLib */
#include "tsarcad.h"		/* liste des types de ARCAD */
/*-----------------------------------------------------------------------------
			TSDescTrait

  But : fonction demandant au serveur de lui envoyer la description d'un
	traitement

  Arguments :
	NomTrait  : nom du traitement
	NumVer    : numero de version

	DescTrait : description du traitement

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/


Longint FAR_PASCAL
TSDescTrait (char *NomTrait,
             Longint NumVer,
     	     pS_DescTrait *DescTrait)
{
  Longint CR;
  Longint code_param;

#if (client == MAC)
  ConnHandle NumSocket;         /* descripteur de la socket de communication */
#else
  int NumSocket;                /* descripteur de la socket de communication */
#endif
  short int CodeFonc;           /* code de la fonction TSLib appelee */
  Longint Resultat;            /* compte-rendu d'execution du client */

  /* test des pointeurs de chaines */

  code_param = ok;
 if (NomTrait == NULL)
    code_param = p_nomtrait;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));


  /* debut de communication */
  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if( compress_on)
    CodeFonc = fonc_tsdesctrait;
  else
    CodeFonc = -(fonc_tsdesctrait - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short,
p_codefonc))
      != ok)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, (char *) &NumVer, taille_long, p_numver))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, NomTrait, TAILLE_NOM_TRAITEMENT,
        p_nomtrait)) != ok)
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

    if ((Resultat = Reception_DescTrait (NumSocket, DescTrait, p_desctrait))
        != ok)
      return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

/*----------------------------------------------------------------------------

			TSDescDiag

  But : fonction demandant au serveur de lui envoyer la description d'un
	diagnostic

  Arguments :
	NomDiag   : nom du diagnostic
	NumVer    : numero de version

	DescDiag  : description du diagnostic

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

Longint FAR_PASCAL
TSDescDiag ( char *NomDiag,
             Longint NumVer,
             pS_DescDiag *DescDiag)

{
  Longint CR;
  Longint code_param;

#if (client == MAC)
  ConnHandle NumSocket;         /* descripteur de la socket de communication */
#else
  int NumSocket;                /* descripteur de la socket de communication */
#endif
  short int CodeFonc;           /* code de la fonction TSLib appelee */
  Longint Resultat;            /* compte-rendu d'execution du client */

  char buffer[taille_short+TAILLE_NOM_DIAGNOSTIC+taille_long];

  /* test des pointeurs de chaines */

  code_param = ok;

  if (NomDiag == NULL)
    code_param = p_nomdiag;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));


  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsdescdiag;
  else
    CodeFonc = -(fonc_tsdescdiag - MAX_FUNCT_NUMBER);

  memcpy(buffer, (char *)&CodeFonc, taille_short);
  memcpy(&buffer[taille_short],(char *) &NumVer, taille_long);
  strcpy(&buffer[taille_short+taille_long],NomDiag );

  /* emission */

  if ((Resultat = Emission (NumSocket, buffer,
     (taille_short + TAILLE_NOM_DIAGNOSTIC + taille_long) , p_codefonc)) != ok)
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

    if ((Resultat = Reception_DescDiag (NumSocket, DescDiag, p_descdiag))
        != ok)
      return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}


/*----------------------------------------------------------------------------

			TSDescDon

  But : fonction demandant au serveur de lui envoyer la description d'une
	donnee

  Arguments :
	NomDon    : nom de la donnee

	DescDon   : description de la donnee

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

Longint FAR_PASCAL
TSDescDon (char *NomDon,
	   pS_DescDon *DescDon)
{
  Longint CR;
  Longint code_param;
#if (client == MAC)
  ConnHandle NumSocket;         /* descripteur de la socket de communication */
#else
  int NumSocket;                /* descripteur de la socket de communication */
#endif
  short int CodeFonc;           /* code de la fonction TSLib appelee         */
  Longint Resultat;            /* compte-rendu d'execution du client        */
  char buffer[TAILLE_NOM_DONNEE+taille_short];
  char *pt_comment;
  char *pt_char;

  /* test des pointeurs de chaines */
  code_param = ok;

  if (NomDon == NULL)
    code_param = p_nomdon;
  if (code_param != ok)
     return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* debut de communication */
  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  if (compress_on)
    CodeFonc = fonc_tsdescdon;
  else
    CodeFonc = -(fonc_tsdescdon - MAX_FUNCT_NUMBER);

  memcpy(buffer, (char *)&CodeFonc, taille_short);
  strcpy(&buffer[taille_short], NomDon);

  /* emission du code de la fonction et d'un parametre */

  if ((Resultat = Emission (NumSocket, buffer, 
        taille_short+TAILLE_NOM_DONNEE, p_codefonc))
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

    if ((Resultat = Reception_DescDon (NumSocket, DescDon, p_descdon))
	!= ok)
      return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

/*----------------------------------------------------------------------------

			TSExist

  But : fonction demandant au serveur de verifier l'existence d'une donnee
	et de lui envoyer les informations la concernant

  Arguments :
	NomDon    : nom de la donnee
	Entrees   : liste des entrees du traitement

	NbCoord   : tableau de valeurs des coordonnees ou nombre de mesures
	NumVer    : numero de version du createur
	Certif    : tableau des certifications
	Date      : date d'execution du diagnostic ou du traitement
	Heure     : heure  d'execution du diagnostic ou du traitement

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/


Longint FAR_PASCAL
TSExist (char *NomDon,
	 pS_Entree Entrees,
	 Longint *NbCoord,
	 Longint *NumVer,
	 Longint *Certif,
	 char *Date,
	 char *Heure)

{
  Longint CR;
  Longint CoordNb;             /* longueur en octets du tableau NbCoord */
  Longint CertifNb;            /* longueur en octets du tableau Certif  */
  Longint code_param;
  char buffer[TAILLE_NOM_DONNEE+taille_long+taille_short];

#if (client == MAC)
  ConnHandle NumSocket;         /* descripteur de la socket de communication */
#else
  int NumSocket;                /* descripteur de la socket de communication */
#endif
  short int CodeFonc;           /* code de la fonction TSLib appelee   */
  Longint Resultat;            /* compte-rendu d'execution du client  */

  /* test des pointeurs de chaines */

  code_param = ok;

  if (NomDon == NULL)
    code_param = p_nomdon;
  if (Date == NULL)
    code_param = p_date;
  if (Heure == NULL)
    code_param = p_heure;
  if (Entrees->union_var.lval < 0)
    code_param = p_numchoc;

   if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* test des pointeurs de tableaux */

  if (NbCoord == NULL)
    code_param = p_nbcoord;
  if (Certif == NULL)
    code_param = p_certif;

  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  if(compress_on)
    CodeFonc = fonc_tsexist;
  else
    CodeFonc = -(fonc_tsexist - MAX_FUNCT_NUMBER);

  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction et des parametres */
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdon))
      != ok)
    return Resultat;

  if ((Resultat = Emission_Entrees (NumSocket, Entrees, p_entrees))
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
      if ((Resultat = Reception (NumSocket, (char *) &CoordNb, taille_long, p_nbcoord))
	  != ok)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) NbCoord, CoordNb, p_nbcoord))
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
    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
