/*****************************************************************************

   NOM  DU MODULE :    tstype.h                                      

   DESCRIPTION DU MODULE :  Fichier Include contenant tous les types 
				utilises par le client TSLib       

   Auteur	:	Vita-Maria GUZZI 
   Societe	:	CR2A
   Projet	:	TSLib

   Date de Creation :	15/09/92
   Modifications    :

 *****************************************************************************/

#if (client==MAC)                             /* definition du type Double */
  typedef short double Double;
#elif (client == INTEL)
#define Double double
#else
  typedef double Double;
#endif

#ifdef __alpha
  typedef int Longint;
#elif (client == INTEL)
#define Longint int
#else
  typedef long Longint;
#endif

typedef	struct S_Unite
{
	char		nom[TAILLE_NOM_UNITE];
	struct S_Unite	*ps_suivant;
}
	*pS_Unite;

typedef	struct S_Donnee
{
	char		nom[TAILLE_NOM_DONNEE];
	struct S_Donnee	*ps_suivant;
}
	*pS_Donnee;

typedef	struct S_Entree
{
	union union_def
	{
		short		sval;
		Longint		lval;
		float		fval;
		Double		dval;
		char		cval[TAILLE_VALEUR_ENTREE];
#ifdef __alpha
		unsigned int	ulval;
#else
		unsigned long	ulval;
#endif
		unsigned short	usval;
	}  union_var;
	struct S_Entree	*ps_suivant;
}
	*pS_Entree;

typedef	struct S_DescEntree
{
	char			nom[TAILLE_NOM_ENTREE];
	char			format[TAILLE_FORMAT];
	struct S_DescEntree	*ps_suivant;
}
	*pS_DescEntree;
/**/
typedef	struct S_DescCoord
{
	char		   nom[TAILLE_NOM_COORDONNEE];
	char		   format[TAILLE_FORMAT];
	char		   unite[TAILLE_NOM_UNITE];
	char		   pretraitement[TAILLE_PRETRAITEMENT];
	short		   indice_max;
	Longint		   struct_fich;
	struct S_DescCoord *ps_suivant;
}
	*pS_DescCoord;

typedef	struct S_DescTrait
{
	char		nom[TAILLE_NOM_TRAITEMENT];
	char		*commentaire;
	char		*auteurs;
	char		date[TAILLE_DATE];
	Longint		type;
	short		num_version;
	short		nb_donnees;
	pS_Donnee	ps_donnee;
	short		nb_entrees;
	pS_DescEntree	ps_entree;
	char		*localisation;
	char		*machine;
}
	*pS_DescTrait;

typedef	struct S_DescDiag
{
	char		nom[TAILLE_NOM_DIAGNOSTIC];
	char		*commentaire;
	char		*auteurs;
	char		date[TAILLE_DATE];
	Longint		type;
	short		num_version;
	short		nb_donnees;
	pS_Donnee	ps_donnee;
}
	*pS_DescDiag;

typedef	struct S_DescDon
{
	char		 nom[TAILLE_NOM_DONNEE];
	char		 nom_producteur[TAILLE_NOM_PRODUCTEUR];
	char		 *commentaire;
	Longint		type;
	short		 nb_comp;
	short		 nb_coord;
	short		 nb_donnees_groupe;
	pS_Donnee	 ps_donnee_groupe;
	pS_DescCoord	 ps_coord;
}
	*pS_DescDon;

typedef struct S_LisCoord
{
        char			*table;
        Longint			nb_octets;
        struct S_LisCoord	*ps_suivant;
}
        *pS_LisCoord; 

