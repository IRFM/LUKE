/*****************************************************************************
 
   NOM  DU MODULE        :  tsext.h

   DESCRIPTION DU MODULE :  fichier d'include contenant la declaration externe 
                            des variables globales du client

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   28/09/92
   Modifications    :

 *****************************************************************************/

/* taille des elements elementaires transferes */

/* 
	modifi‚ en rapport avec tslib.h pour la version PC;
	devrait fonctionner avec les autres machines 
	ancienne version: extern long int taille_char;	

								*/
#define taille_char     sizeof(char)
#define taille_short    sizeof(short)
#define taille_long     sizeof(Longint)
#define taille_float	sizeof(float)
#define taille_double	sizeof(Double)

/* type de reel utilise par l'utilisateur */

#if (client!=PC)
extern char tslib_reel;
#else
#define tslib_reel 'd'
#endif

extern int compress_on ;
extern int test_on ;
extern int Socket_save;

