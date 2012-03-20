/*--------------------------------------------------
functs.h:
	prototype des fonctions TSlib ( Norme ANSI ) (toutes ?)
----------------------------------------------------*/
#ifdef HUGE
#undef HUGE
#endif

#ifdef DLLMEX
#include <windows.h>

#define MAXDATAPC	100000L
#define FAR_PASCAL   PASCAL
#define HUGE huge
#define Register
#define Strcpy	     lstrcpy
#define Strcat	     lstrcat
#define Strlen	     lstrlen
#define Memcpy	     _fmemcpy
#else
#define FAR_PASCAL
#define HUGE
#define Register     register
#define Strcpy	     strcpy
#define Strlen	     strlen
#define Strcat	     strcat
#define Memcpy	     memcpy
#endif


/* --- module ceat.c --- */

extern Longint FAR_PASCAL 
TSLDiag (Longint numchoc,
	 Longint *nbdiag,
	 char *ListeDiag[]);

extern Longint FAR_PASCAL 
TSLSig (Longint numchoc,
	char *NomDiag,
	Longint *nbsig,
	char *ListeSig[]);

extern Longint FAR_PASCAL 
TSRqparm (Longint numchoc,
	  char *nomdiag,
	  char *nomobj,
	  char *nomparam,
	  int nbval,
	  char *buff,
	  Longint *nrep,
	  Longint *fparm);

extern Longint FAR_PASCAL 
TSRqdecl (Longint numchoc,
	  char *nomdec,
	  Longint numoccur,
	  float *datedec);

extern Longint FAR_PASCAL TSGetinfo (Longint *numchoc);

extern Longint FAR_PASCAL 
TSLTrait (Longint *nbtrait,
	  char *ListeTrait[]);

extern Longint FAR_PASCAL 
TSRqentete_sig (Longint numchoc,
		char *nomdiag,
		char *nomobj,
		char *unites,
		float *calibration);

extern Longint FAR_PASCAL 
TSRqentete_par (Longint numchoc,
		char *nomdiag,
		char *nomobj,
		char *nompar,
		char *unites);

extern Longint FAR_PASCAL TSRqstop ();	/* aucun parametre */

extern Longint FAR_PASCAL 
TSTData (Longint numchoc,
	 char * nom_diag,
	 Longint *t_choc,
	 Longint *t_param);

extern Longint FAR_PASCAL
TSRqt (	char * Requete,
	char ** ShotList,
     	Longint * LShotList );

/* --- module TSDesc.c --- */

extern Longint FAR_PASCAL 
TSDescTrait (char *NomTrait,
	     Longint NumVer,
	     pS_DescTrait * DescTrait);

extern Longint FAR_PASCAL 
TSDescDiag (char *NomDiag,
	    Longint NumVer,
	    pS_DescDiag * DescDiag);

extern Longint FAR_PASCAL 
TSDescDon (char *NomDon,
	   pS_DescDon * DescDon);

extern Longint FAR_PASCAL 
TSExist (char *NomDon,
	 pS_Entree Entrees,
	 Longint *NbCoord,
	 Longint *NumVer,
	 Longint *Certif,
	 char *Date,
	 char *Heure);

/* --- module TSEcri.c --- */

extern Longint FAR_PASCAL 
TSWrite (char *NomTrait,
	 pS_Entree Entrees,
	 Longint *Longueurs,
	 Longint *Certif,
	 char *TabVal,
	 Longint LongNb,
	 Longint CertifNb,
	 Longint ValNb);

extern Longint FAR_PASCAL 
TSWcertif (char *NomDon,
	   pS_Entree Entrees,
	   Longint *Certif,
	   Longint CertifNb);



/* --- module TSLect.c --- */

extern Longint FAR_PASCAL 
TSGrpX (char *NomDon,
	pS_Entree Entrees,
	Double XI,
	Double XF,
	Longint NbMax,
	Longint Extract,
	pS_Unite * Unite,
	Longint *NumVer,
	Longint *Certif,
	char *Date,
	char *Heure,
	Longint *NbMes,
	Longint *MaxReel,
	char HUGE * X,
	char HUGE * Y,
	char *Coord);


extern Longint FAR_PASCAL 
TSGrpRg (char *NomDon,
	 pS_Entree Entrees,
	 Longint *Rangs,
	 Longint NbMax,
	 Longint Extract,
	 pS_Unite * Unite,
	 Longint *NumVer,
	 Longint *Certif,
	 char *Date,
	 char *Heure,
	 Longint *NbMes,
	 Longint *MaxReel,
	 char HUGE * X,
	 char HUGE * Y,
	 char *Coord);


extern Longint FAR_PASCAL 
TSRSigRg (char *NomDon,
	  pS_Entree Entrees,
	  Longint *Rangs,
	  Longint NbMax,
	  Longint Extract,
	  pS_Unite * Unite,
	  Longint *NumVer,
	  Longint *Certif,
	  char *Date,
	  char *Heure,
	  Longint *NbMes,
	  Longint *MaxReel,
	  char HUGE * X,
	  char HUGE * Y);


extern Longint FAR_PASCAL 
TSRSigX (char *NomDon,
	 pS_Entree Entrees,
	 Double XI,
	 Double XF,
	 Longint NbMax,
	 Longint Extract,
	 pS_Unite * Unite,
	 Longint *NumVer,
	 Longint *Certif,
	 char *Date,
	 char *Heure,
	 Longint *NbMes,
	 Longint *MaxReel,
	 char HUGE * X,
	 char HUGE * Y);



extern Longint FAR_PASCAL 
TSXtrRg (char *NomDon,
	 pS_Entree Entrees,
	 Longint *Indices,
	 Longint *Rangs,
	 Longint NbMax,
	 Longint Extract,
	 pS_Unite * Unite,
	 Longint *NumVer,
	 Longint *Certif,
	 char *Date,
	 char *Heure,
	 Longint *NbMes,
	 Longint *MaxReel,
	 char HUGE * X,
	 char HUGE * Y,
	 char *Coord);

extern Longint FAR_PASCAL 
TSXtrX (char *NomDon,
	pS_Entree Entrees,
	Longint *Indices,
	Double XI,
	Double XF,
	Longint NbMax,
	Longint Extract,
	pS_Unite * Unite,
	Longint *NumVer,
	Longint *Certif,
	char *Date,
	char *Heure,
	Longint *NbMes,
	Longint *MaxReel,
	char HUGE * X,
	char HUGE * Y,
	char *Coord);


/* --- module TSDecl.c --- */

extern Longint FAR_PASCAL 
TSSigDeclenche (char *NomDon,
		Longint NumChoc,
		char *NomDec,
		Longint Occur,
		Longint NbMax,
		Longint Extract,
		pS_Unite * Unite,
		Longint *NumVer,
		char *Date,
		char *Heure,
		Longint *NbMes,
		Longint *MaxReel,
		char HUGE * T,
		char HUGE * Y);


extern Longint FAR_PASCAL 
TSXtrDeclenche (char *NomDon,
		Longint NumChoc,
		Longint *Indices,
		char *NomDec,
		Longint Occur,
		Longint NbMax,
		Longint Extract,
		pS_Unite * Unite,
		Longint *NumVer,
		char *Date,
		char *Heure,
		Longint *NbMes,
		Longint *MaxReel,
		char HUGE * T,
		char HUGE * Y);


extern Longint FAR_PASCAL 
TSGrpDeclenche (char *NomDon,
		Longint NumChoc,
		char *NomDec,
		Longint Occur,
		Longint NbMax,
		Longint Extract,
		pS_Unite * Unite,
		Longint *NumVer,
		char *Date,
		char *Heure,
		Longint *NbMes,
		Longint *MaxReel,
		char HUGE * T,
		char HUGE * Y);



/* --- module TScom.c --- */

extern Longint FAR_PASCAL
Emission (
#if (client == MAC)
	  ConnHandle nsock,
#else
	  int nsock,
#endif
	  char *parametre,
	  Longint longbuffer,
	  Longint code_param);

extern Longint FAR_PASCAL Fin_Emission (int nsock);

extern Longint FAR_PASCAL
Reception (
#if (client == MAC)
	   ConnHandle nsock,
#else
	   int nsock,
#endif
	   char * parametre,
	   Longint longbuffer,
	   Longint code_param);

/************************************/
extern Longint FAR_PASCAL
ReceptionHuge (
	   int nsock,
	   char HUGE * parametre,
	   Longint longbuffer,
	   Longint code_param);
/************************************/

#if (client != MAC)
extern Longint FAR_PASCAL
                Debut_Communication (int *NumSocket);

#else				/* version Macintosh */
extern Longint
                Debut_Communication (ConnHandle * NumSocket);
#endif


extern void 
Fin_Communication (
#if (client == MAC)
		   ConnHandle nsock
#else
		   int nsock
#endif
);

/* --- module TSutil.c --- */

extern Longint FAR_PASCAL
Emission_Entrees (
#if (client == MAC)
		  ConnHandle nsock,
#else
		  int nsock,
#endif
		  pS_Entree ptent,
		  Longint code_param);



extern Longint FAR_PASCAL
Reception_Donnee (
#if (client == MAC)
		  ConnHandle nsock,
#else
		  int nsock,
#endif
		  pS_Donnee * ptdon,
		  Longint code_param);


extern Longint FAR_PASCAL
Reception_DescEntree (
#if (client == MAC)
	      ConnHandle nsock,
#else
	      int nsock,
#endif
	      pS_DescEntree * ptent,
	      Longint code_param);


extern Longint FAR_PASCAL
Reception_DescCoord (
#if (client == MAC)
	     ConnHandle nsock,
#else
	     int nsock,
#endif
	     pS_DescCoord * ptcoord,
	     Longint code_param);

extern Longint FAR_PASCAL
Reception_Chaine (
#if (client == MAC)
	  ConnHandle nsock,
#else
	  int nsock,
#endif
	  char **chaine,
	  Longint code_param);



extern Longint FAR_PASCAL
Reception_DescTrait (
#if (client == MAC)
	     ConnHandle nsock,
#else
	     int nsock,
#endif
	     pS_DescTrait * pttrait,
	     Longint code_param);


extern Longint FAR_PASCAL
Reception_DescDiag (
#if (client == MAC)
	    ConnHandle nsock,
#else
	    int nsock,
#endif
	    pS_DescDiag * ptdiag,
	    Longint code_param);


extern Longint FAR_PASCAL
Reception_DescDon (
#if (client == MAC)
	   ConnHandle nsock,
#else
	   int nsock,
#endif
	   pS_DescDon * ptdon,
	   Longint code_param);


extern Longint FAR_PASCAL
Reception_Unite (
#if (client == MAC)
	 ConnHandle nsock,
#else
	 int nsock,
#endif
	 pS_Unite * ptunite,
	 Longint code_param);


extern Longint FAR_PASCAL
Reception_Tableau (
#if (client == MAC)
	   ConnHandle nsock,
#else
	   int nsock,
#endif
	   char HUGE * Tab,
	   Longint Tablg,
	   char *Tabtyp,
	   Longint code_param);


extern Longint FAR_PASCAL
Reception_Tab_Coord (
#if (client == MAC)
	     ConnHandle nsock,
#else
	     int nsock,
#endif
	     char *Tab,
	     Longint *Tablg,
	     char *Tabtyp,
	     Longint Typtab,
	     Longint code_param);

/* --- module TSerr.c --- */

extern Longint			/* C declaration */
Gestion_Erreur (Longint erreur,
		Longint param);


