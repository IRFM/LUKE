/*****************************************************************************

   NOM  DU MODULE        :  tserr.c

   DESCRIPTION DU MODULE :  module de gestion des erreurs du client TSLib

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   12/02/93
   Modifications    :

 *****************************************************************************/

/*****************************************************************************

   Liste des fonctions du module :

        Gestion_Erreur

 *****************************************************************************/

#include <stdio.h>
#include "tsdef.h"		/* liste des constantes              */
#include "tsmes.h"		/* liste des erreurs                 */
#include "tstype.h"

/*****************************************************************************/


/*----------------------------------------------------------------------------

                        Gestion_Erreur

  But : fonction concatenant un code d'erreur et un code parametre

  Arguments :
        erreur   : code de l'erreur
        param    : code du parametre concerne

  Retour         : code erreur complet

  Appelee par toutes les fonctions du client TSLib

------------------------------------------------------------------------------*/


Longint
Gestion_Erreur (Longint erreur, Longint param)
{
  Longint Resultat;

  Resultat = erreur * MAX_CODE_PARAM + param;

  return Resultat;
}
