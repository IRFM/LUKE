/*****************************************************************************

   NOM  DU MODULE        :  tsecri.c

   DESCRIPTION DU MODULE :  module client de la bibliotheque TSLib
                            ensemble des fonctions d'ecriture

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   29/09/92
   Modifications    :

 *****************************************************************************/

/*****************************************************************************

   Liste des fonctions du module :

        TSWrite
        TSWcertif

 *****************************************************************************/

#include <stdio.h>		/* bibliotheques standards           */
#include <stdlib.h>
#include <string.h>
#include "tsdef.h"		/* liste des constantes utilisees    */
#include "tsconf.h"		/* configuration du client           */
#if (client == MAC)

#endif
#include "tsfonc.h"		/* liste des fonctions appelees   */
#include "tsmes.h"		/* liste des erreurs              */
#include "tstype.h"		/* liste des types de donnees     */
#include "tsext.h"		/* liste des variables globales   */
#include "functs.h"		/* prototypes fcts TSLib */

/*----------------------------------------------------------------------------

                        TSWrite

  But : fonction envoyant au serveur la liste des parametres a ecrire en
        base de donnees et dans les fichiers de mesure

  Arguments :
        NomTrait  : nom du traitement
        Entrees   : liste des entrees du traitement
        Longueurs : longueurs des coordonnees
        Certif    : tableau des certifications
        TabVal    : tableau des mesures
        LongNb    : taille en octets du tableau Longueurs
        CertifNb  : taille en octets du tableau Certif
        ValNb     : taille en octets du tableau TabVal

  Retour          : compte-rendu d'execution

 ------------------------------------------------------------------------------*/


Longint FAR_PASCAL
TSWrite (	char *NomTrait,
		pS_Entree Entrees,
     		Longint *Longueurs,
     		Longint *Certif,
     		char *TabVal,
		Longint LongNb,
		Longint CertifNb,
		Longint ValNb        )

{
  Longint CR;
  Longint code_param;
  Longint numchoc;

  int NumSocket;		/* descripteur de la socket de communication */
  short int CodeFonc;		/* code de la fonction TSLib appelee         */
  Longint Resultat;		/* compte-rendu d'execution du client        */

  char host[64], *var_env;
  int rejeu_ok = 0, len_host = 63 ;

  numchoc = Entrees->union_var.lval;

  /* modif du 05/08/96 pour devtrait */
  if (!strcmp(getenv("USER"),"devtrait"))
    {
     printf("Developpement traitement : Ecriture Choc # %d sous # 77 \n",numchoc);
     Entrees->union_var.lval=77;
    }

  /* test des parametres de type pointeur */

  code_param = ok;

  if (NomTrait == NULL)
    code_param = p_nomtrait;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  if (Longueurs == NULL)
    code_param = p_longueurs;
  if (Certif == NULL)
    code_param = p_certif;
  if (TabVal == NULL)
    code_param = p_tabval;

  /* YB YB YB for CTD !!!!  YB YB YB */
     if (!gethostname(host, len_host)) {
       if (!strncmp(host,"hercule",7)) {
          var_env = getenv("TOUR");
          if(var_env) {
            if( !strcmp(var_env,"BABEL") )
              rejeu_ok = 1;
          } 
        }
     }
  /* Fin YB YB YB for CTD !!!!  YB YB YB */

  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  /* debut de communication */
      if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

  /* emission du code de la fonction */
  if(compress_on)
    CodeFonc = fonc_tswrite;
  else
    CodeFonc = -(fonc_tswrite - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      != ok)
    return Resultat;



  /* emission des parametres */
  
  /*  YB YB YB for CTD !!!!  YB YB YB */

  if ((Resultat = Emission (NumSocket, (char *) &rejeu_ok, taille_long, p_longnb))
      != ok)
    return Resultat;

  /* Fin YB YB YB for CTD !!!!  YB YB YB */

  if ((Resultat = Emission (NumSocket, NomTrait, TAILLE_NOM_TRAITEMENT, p_nomtrait))
      != ok)
    return Resultat;

  if ((Resultat = Emission_Entrees (NumSocket, Entrees, p_entrees))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &LongNb, taille_long, p_longnb))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) Longueurs, LongNb, p_longueurs))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &CertifNb, taille_long, p_certifnb))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) Certif, CertifNb, p_certif))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &ValNb, taille_long, p_valnb))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) TabVal, ValNb, p_tabval))
      != ok)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception d'un parametre */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      != ok)
    return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;
}

/*----------------------------------------------------------------------------

                        TSWcertif

  But : fonction envoyant au serveur les certifications associees a une donnee

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        Certif    : tableau des certifications
        CertifNb  : taille en octets du tableau Certif

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/


Longint FAR_PASCAL
TSWcertif (	char *NomDon,
     		pS_Entree Entrees,
     		Longint *Certif,
     		Longint CertifNb   )

{
  Longint CR;
  Longint code_param;

  int NumSocket;		/* descripteur de la socket de communication */
  short int CodeFonc;		/* code de la fonction TSLib appelee         */
  Longint Resultat;		/* compte-rendu d'execution du client        */

  /* test des parametres de type pointeur */

  code_param = ok;

  if (NomDon == NULL)
    code_param = p_nomdon;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  if (Certif == NULL)
    code_param = p_certif;
  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tswcertif;
  else
    CodeFonc = -(fonc_tswcertif - MAX_FUNCT_NUMBER);
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

  if ((Resultat = Emission (NumSocket, (char *) &CertifNb, taille_long, p_certifnb))
      != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) Certif, CertifNb, p_certif))
      != ok)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception d'un parametre */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      != ok)
    return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
