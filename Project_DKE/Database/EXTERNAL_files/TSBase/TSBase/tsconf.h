/*****************************************************************************
 
   NOM  DU MODULE        : tsconf.h

   DESCRIPTION DU MODULE :  fichier d'include contenant l'ensemble des  
                            constantes associees au client

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   28/09/92
   Modifications    :

 *****************************************************************************/


#define client                  MAC             /* nom de la machine cliente */

#if (client == MAC)
#define delai                   30*60 
#endif

