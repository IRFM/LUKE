/*****************************************************************************
 
   NOM  DU MODULE        :  tslib.h

   DESCRIPTION DU MODULE :  fichier d'include contenant la definition des 
                            variables globales du client

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   28/09/92
   Modifications    :

 *****************************************************************************/

/* taille des elements elementaires transferes */

/*
    modifié pour la version PC; devrait fonctionner sur toutes machines.
	ancienne version: long int taille_char = sizeof(char);
        								*/


#define  taille_char     sizeof(char)
#define  taille_short    sizeof(short int)
#define  taille_long     sizeof(Longint)
#define  taille_float    sizeof(float)
#define  taille_double   sizeof(Double)

