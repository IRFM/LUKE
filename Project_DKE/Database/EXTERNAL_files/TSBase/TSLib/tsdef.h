/*****************************************************************************

   NOM  DU MODULE        :  tsdef.h

   DESCRIPTION DU MODULE :  Fichier Include contenant toutes les constantes 
                                utilises par le client TSLib       

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   15/09/92
   Modifications    :

 *****************************************************************************/

#define	TAILLE_NOM_DONNEE	(Longint)17	/* taille maxi avec '\0' */
#define	TAILLE_NOM_COORDONNEE	(Longint)17
#define	TAILLE_NOM_DIAGNOSTIC	(Longint)17
#define	TAILLE_NOM_TRAITEMENT	(Longint)17
#define	TAILLE_NOM_PRODUCTEUR	(Longint)17
#define	TAILLE_NOM_UNITE	(Longint)17
#define	TAILLE_NOM_ENTREE	(Longint)17
#define	TAILLE_NOM_DECLENCHE	(Longint)17
#define	TAILLE_NOM_AUTEUR	(Longint)17
#define	TAILLE_PRETRAITEMENT	(Longint)17
#define	TAILLE_COMMENTAIRE	(Longint)1991
#define	TAILLE_NOM_AUTEURS	(Longint)65
#define	TAILLE_NOM_MACHINE	(Longint)65
#define	TAILLE_NOM_LOCALISATION	(Longint)65
#define	TAILLE_NOM_REPERTOIRE	(Longint)65	/* JS was here on Feb 04 2000 */
#define	TAILLE_FORMAT		(Longint)6
#define	TAILLE_FORMAT_SERVEUR	(Longint)2
#define	TAILLE_DATE		11
#define	TAILLE_HEURE		9
#define TAILLE_VALEUR_ENTREE    (Longint)8
#define MAX_INDICE		(Longint)2
#define MAX_RANG                (Longint)2
#define MAX_MESURE              (Longint)3
#define MAX_CODE_PARAM          (Longint)100


#define SUITE                   (Longint)1       /* indiquent la suite ou la */
#define FIN                     (Longint)0        /* fin d'une liste chainee */


#define DEC                     '1'             /* types de machines clientes */
#define PC                      '2'
#define MAC                     '3'
#define SUN                     '4'
#define INTEL                   '5'

#define entier_court            's'           /* types de donnees         */
#define entier_long             'l' 
#define non_signe		'u' 
#define reel_simple             'f'
#define reel_double             'd'
#define caractere               'c'

#define UNIQ			0      /* indiquent si les coordonnees*/
#define MULT			1      /* sont uniques ou multiples*/

#define MAX_FUNCT_NUMBER	1000

#define NUM_CHOC_BASE		20101  /* choc charniere */	
#define NUM_CHOC_TEST		200    /* choc charniere test*/	
#define NUM_CHOC_DEC		20800  /* choc charniere serveur DEC*/	
