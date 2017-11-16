/*****************************************************************************
 
   NOM  DU MODULE        : tshote.h

   DESCRIPTION DU MODULE :  fichier d'include contenant l'ensemble des  
                            constantes associees au serveur

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   28/09/92
   Modifications    :

 *****************************************************************************/

#if (client == MAC)

#define glob_config1 "RemoteAddress mira RemoteTCPPort 2010 \0"
#define glob_config2 "RemoteAddress agena RemoteTCPPort 2010 \0"
#define glob_toolname "\pTCPack"

#else


#define hote1           "132.169.8.128" /* adresse de rhea */
#define hote2           "10.8.86.1"     /* adresse de deneb   */
#define nom_service     "tslib"         /* nom du service      */
#define protocole       "tcp"           /* nom du protocole    */

#endif
