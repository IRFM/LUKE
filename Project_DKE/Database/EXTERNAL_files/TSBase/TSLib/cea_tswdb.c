/*****************************************************************************
 
   NOM  DU MODULE        :  cea_tswdb.c

   DESCRIPTION DU MODULE :  module client de la bibliotheque TSLib
                            fonctions d'ecriture de donnees brutes

   Auteur       :       C. ETCHEBER
   Societe      :       CISI
   Projet       :       TRANS-INT

   Date de Creation :   01/04/93
   Modifications    :

 *****************************************************************************/

/*****************************************************************************

   Liste des fonctions du module :

        TSWdb

 *****************************************************************************/

#include <stdio.h>			/* bibliotheques standards           */
#include <stdlib.h>			
#include <string.h>		
#include "tsdef.h"                      /* liste des constantes utilisees    */
#include "tsconf.h"                     /* configuration du client           */
#if (client == MAC)

#endif
#include "tsfonc.h"                     /* liste des fonctions appelees   */
#include "tsmes.h"                      /* liste des erreurs              */
#include "tstype.h"                     /* liste des types de donnees     */
#include "tsext.h"                      /* liste des variables globales   */

#include "ceaf.h"			/* fonctions ajoutees par le CEA  */

/* ajout d'un code erreur (tsmes.h) */
#define erreur_valeur (Longint)113
#define choc_pas_la   (Longint)114

/*----------------------------------------------------------------------------

                        TSWdb

  But : fonction envoyant au serveur la liste des donnees a ecrire ou a
        mettre a jour apres choc en base de donnees et dans les fichiers
        de donnees brutes

  Arguments :
        num_choc        : numero du choc
        nom_diagnostic  : nom du diagnostic
        format          : type de la station d'acquisition des mesures
                          (MAC, PC, SUN, DEC)
        nb_donnees      : nombre de donnees a ajouter ou a mettre a jour
        nom_donnees     : tableau des noms de donnees
        long_coord      : longueur en octets du tableau tab_coord
        tab_coord       : tableau du nombre de mesures de chaque donnee
        long_val        : longueur en octets du tableau tab_val
        tab_val         : tableau des mesures

  Retour          : compte-rendu d'execution

 ------------------------------------------------------------------------------*/


Longint TSWdb(num_choc, nom_diagnostic, format_acq,
               nb_donnees, nom_donnees,
               long_coord, tab_coord,
               long_val, tab_val)

Longint   num_choc;
char      *nom_diagnostic;
char      format_acq;
short     nb_donnees;
char      *nom_donnees[128];
Longint   long_coord;
Longint   *tab_coord;
Longint   long_val; 
char      *tab_val;

{
  Longint  CR = 0; 
  Longint  code_param;
  int i;

  int       NumSocket;  /* descripteur de la socket de communication */
  short int CodeFonc;   /* code de la fonction TSLib appelee         */
  Longint   Resultat;   /* compte-rendu d'execution du client        */ 

   /**   YB 12/01/95 : erreur si on veut ajouter des donnees a un choc qui n'a 
                       pas encore eu lieu
   **/
   pS_Entree ptEntree;   
   char date[TAILLE_DATE], heure[TAILLE_HEURE]; 
   Longint numv, nbcoord[5], certif[64];
   /**   YB 12/01/95  **/

  /* controle des parametres */ 

   if (num_choc < 0) {  
      code_param = p_numchoc;
      return (Gestion_Erreur(erreur_valeur,code_param));
   }
   if (nb_donnees<=0) { 
      code_param = p_longueurs;
      return (Gestion_Erreur(erreur_tableau_vide,code_param));
   }
   if (nb_donnees >128 ) {
      code_param = p_nbmax;
      return (Gestion_Erreur(erreur_valeur,code_param));
   }
   if (long_coord<=0) { 
      code_param = p_longnb;
      return (Gestion_Erreur(erreur_tableau_vide,code_param));
   }
   if (long_val<=0) { 
      code_param = p_valnb;
      return (Gestion_Erreur(erreur_tableau_vide,code_param));
   }
        
   if (nom_diagnostic==NULL) {
      code_param = p_nomdiag;
      return (Gestion_Erreur(erreur_chaine_vide,code_param));
   }

   if (nom_donnees==NULL) { 
      code_param = p_nomdon;
      return (Gestion_Erreur(erreur_tableau_vide,code_param));
   }
   if (tab_coord==NULL) { 
      code_param = p_coord;
      return (Gestion_Erreur(erreur_tableau_vide,code_param));
   }
   if (tab_val==NULL) { 
      code_param = p_tabval;
      return (Gestion_Erreur(erreur_tableau_vide,code_param));
   }

   /**   YB 12/01/95 : erreur si on veut ajouter des donnees a un choc qui n'a 
                       pas encore eu lieu
   **/

  ptEntree = (pS_Entree) malloc (sizeof (struct S_Entree));
  ptEntree->union_var.lval = num_choc;
  ptEntree->ps_suivant = NULL;


  /* debut de communication */

  /* Chocs serveur RHEA */
      if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

  /* emission du code de la fonction */

  CodeFonc = fonc_tswdb;
  if ((Resultat = Emission(NumSocket,(char *)&CodeFonc,taille_short,p_codefonc))
         != ok)
  return Resultat;


  /* emission des parametres */

  if ((Resultat = Emission(NumSocket,(char *)&num_choc,taille_long,p_numchoc))
         != ok)
  return Resultat;

  if ((Resultat = Emission(NumSocket,nom_diagnostic,TAILLE_NOM_DIAGNOSTIC,p_nomdiag))
         != ok)
  return Resultat;

  if ((Resultat = Emission(NumSocket,&format_acq, 1, p_unite))
         != ok)
  return Resultat;

  if (( Resultat = Emission(NumSocket,(char *)&nb_donnees,taille_short,p_longueurs))
         != ok)
  return Resultat;

   for (i=0; i<nb_donnees; i++) {
     if (( Resultat = Emission(NumSocket,nom_donnees[i],TAILLE_NOM_DONNEE,p_nomdon))
         != ok)
        return Resultat;
   }

   if (( Resultat = Emission(NumSocket,(char *)&long_coord,taille_long,p_longnb))
         != ok)
      return Resultat;

   if (( Resultat = Emission(NumSocket,(char *)tab_coord,long_coord,p_coord))
         != ok)
      return Resultat;

   if (( Resultat = Emission(NumSocket,(char *)&long_val,taille_long,p_valnb))
         != ok)
      return Resultat;

   if (( Resultat = Emission(NumSocket,(char *)tab_val,long_val,p_tabval))
         != ok)
      return Resultat;

  /* fin d'emission */
  
#if ((client!=PC) && (client !=MAC))
  if (( Resultat = Fin_Emission(NumSocket)) 
       == erreur_fin_emission)
  return Resultat;
#endif

  /* reception d'un parametre */

  if (( Resultat = Reception(NumSocket,(char *)&CR,taille_long,p_cr))
         != ok)
  return Resultat;

  /* fin de communication */

  Fin_Communication(NumSocket);

  if (CR==305)  printf (" TSWdb : trame de rang 0 interdite en ajout \n");
  else if (CR==307)  printf (" TSWdb : Serveur_Choc n'a pas encore ecrit \n");
  return CR;
}
