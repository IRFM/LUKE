/*		.... erreur.h .....		*/
/*		....    YB    .....		*/
/*						*/

/*  1		NomTrait 	: nom d'un traitement
  2 		Nomdiag 	: nom d'un diagnostic
  3		NomDon 	: nom d'une donnée
  4		NomDec 	: nom d'une déclenche
  5		Date 
  6		Heure
  7		Entrees 	: liste chaînée des entrées
  8		DescTrait 	: structure de description d'un traitement
  9		DescDiag 	: structure de description d'un diagnostic
 10		DescDon 	: structure de description d'une donnée
 11 		Unite 		: liste chaînée des unités
 12 		NbCoord 	: tableau des longueurs des coordonnées
 13		TabVal 	: tableau des mesures
 14		NbCoord 	: tableau de valeurs des coordonnées
 15		Rangs 	: tableau contenant une fourchette de rangs
 16		Incides 	: tableau d'indices d'un signal dans un groupe
 17		X 		: tableau des abscisses
 18		T 		: tableau des temps
 19		Y 		: tableau des mesures
 20		Coord 	: tableau des coordonnées
 21		Certif 		: tableau des certifications
 22		NbMax 	: nombre de mesures demandé
 23		Extract 	: type d'extraction demandé
 24		Numchoc 	: numéro de choc
 25		Occur 	: occurrence d'une déclenche
 26		XI 		: valeur initiale d'abscisse 		
 27		XF 		: valeur finale d'abscisse 
 28		LongNb 	: taille en octets du tableau Longueurs
 29		CertifNb 	: taille en octets du tableau Certif	
 30		ValNb 	: taille en octets du tableau TabVal
 31		NumVer 	: numéro de version
 32		NbMes 	: nombre de mesures rendues
 33		MaxReel 	: nombre de mesures trouvées
 34		CR 		: compte-rendu d'exécution
 35		CodeClient 	: code associé au client
 36		CodeFonc 	: code associé à la fonction

*/

/* messages erreur tslib [0..38]	*/
static char *err_tslib[]={
	"Traitement inconnu",
	"Diagnostic inconnu",
	"Donnee inconnue",
	"Traitement existant mais version inexistante",
	"Diagnostic existant mais version inexistante",
	"Numero de choc incorrect",
	"Traitement absent pour ce choc",
	"Diagnostic absent pour ce choc",
	"Donnee non produite pour ce choc",
	"Nom de donnee incorrect",
	"Fourchette de rang incorrecte",
	"Fonction indisponible pour ce type de donnees (calculee)",
	"Type d'extraction incorrect",
	"Nombre de mesures demande incorrect",
	"Lecture incoherente pour ce type de donnees",
	"Fonction non autorisees pour un groupe heterogene",
	"Abscisses incorrectes",
	"Valeurs des indices incorrectes",
	"Nom de declenche ou occurence non trouve",
	"Valeurs des certifications inferieure ou egale -2",
	"Modifications des certifications en negatif",
	"Valeurs des certifications incorrectes",
	"Nombre de certifications incorrect (Groupe Homogene)",
	"Ecriture en cours pour ce traitement et ce choc",
	"Ecriture en cours delai attente trop long",
	"Lecture en cours delai attente trop long",
	"Disque sature",
	"Probleme a l'ouverture du fichier",
	"Taille des tableaux erronnee",
	"Erreur BD rencontree",
	"Incoherence BD",
	"Donnee non acquise",
	"Erreur lors de la lecture des donnees brutes",
	"Structure de fichier incorrecte en BD",
	"Valeurs de x decroissantes",
	"Pas de mesures dans l'intervalle demande",
	"Puissance de 10 incorrecte",
	"Probleme de verrou",
        "Incoherence dans la definition du type de la donnee",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
"Machine hote absente du fichier /etc/hosts",
"Service absent du fichier /etc/services",
"Creation de socket impossible",
"Probleme de connexion avec le serveur",
"Probleme d'attribution de port de communication",
"Probleme d'emission",
"Probleme de fin d'emission",
"Probleme de reception",
"Chaine non initialisee",
"Tableau non initialise",
"Probleme avec l'outil de connexion TCPack",
"Probleme a la creation de la structure de donnees relative a la connexion",
"Probleme de configuration de la connexion",
"",
"",
"Unexepected error",
"Allocation memoire impossible",
"Probleme a l'ouverture du fichier",
"Repertoire non trouve",
"Producteur non trouve",
"Diagnostic non trouve",
"Traitement non trouve",
"Objet non trouve",
"Parametre non trouve",
"Pas d'objets ....",
"Mauvais numero de choc",
"Mauvais type d'objet",
"Impossible d'ouvrir la BD",
"Unrecoverable error",
"Erreur SQL",
"Mauvais nom de producteur",
"Mauvais nom d'objet",
"Mauvais nom de parametre",
"Mauvais nombre de valeurs",
"Mauvaise longueur",
"Erreur donnee ",
"Mauvais format de parametre",
"numero_choc_invalide",
"nom_declenche_invalide",
"nom_diagnostic_invalide",
"nom_objet_invalide",
"nom_parametre_invalide",
" ",
" ",
};
/* messages erreur tsmat [1001..1014]	*/
static char *err_tsmat[]={
"Allocation memoire impossible",
"La donnee demandee n'est ni un signal simple ni un groupe ",
"Format inconnu ou non supporte actuellement",
" ",
" ",
" ",
" ",
" ",
" ",
"Numero de choc invalide ( <0 )",
"Nom de declenche invalide",
"Nom de diagnostic invalide",
"Nnom d'objet invalide",
"Nom de parametre invalide",
};

static char *err_rqlib[]={
"Ouverture fichier choc impossible (absent ?) ",
"Diagnostic inconnu ou absent ",
"Objet inconnu", 
"Parametre inconnu",
"Nom ou occurrence declenche inconnu",
"Acces au diagnostic pour la declenche demandee impossible",
};
#define ERR_MAX	1014

