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


#define hote1           "132.169.8.138"  /* adresse de rigel */
#define hote2           "132.169.8.138"  /* adresse de rigel   */
/* #define hote2           "132.169.8.253"  adresse de sturne18  */
#define hote3           "132.169.60.1"  /* adresse du firewall */
#define nom_service     "tslib"         /* nom du service      */
#define protocole       "tcp"           /* nom du protocole    */

#endif
