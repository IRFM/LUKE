/*--------------------------------------------------
functs.h:
	prototype des fonctions TSlib ( Norme ANSI ) (toutes ?)
----------------------------------------------------*/
#if(client == PC)
#include <windows.h>

#define MAXDATAPC	100000L
#define FAR_PASCAL   PASCAL
#define HUGE	     huge
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
	  Longint nbval,
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

extern Longint FAR_PASCAL
TSLgDiag (      Longint numchoc,
                char *nomdiag,
                Longint *nbmes   );

extern Longint FAR_PASCAL
TSwriteParam (  Longint numchoc,
                char *nomdiag,
                char *nomobj,
                char *nomparam,
                Longint n,
                Longint nbval[],
                Longint lgval[],
                char *buff);

extern Longint FAR_PASCAL
TSlistObjet ( );
                           
extern Longint FAR_PASCAL
TSrqParm (      Longint numchoc,
                char *nomdiag,
                char *nomobj,
                char *typobj,
                char *nomparam,
                char **buff,
                Longint *nrep,
                Longint *fmt);

extern Longint FAR_PASCAL
TSdescObjet (   Longint numchoc,
                char *nomdiag,
                char *nomobj,
               /* char *typobj,*/
                char **buff,
                char **cmt);

extern Longint FAR_PASCAL
TStele ( char *NomDiag,
         Longint al,
         Longint val,
         char **pt_val,
         Longint *lg_data  );

extern Longint FAR_PASCAL
TSChargerObjet (Longint numchoc,
                char *ensCible,
                char *ensSource,
                char *prodCible,
                char *prodSource,
                char *objSource,
                char *objCible,
                Longint remp,
                Longint dom);


extern Longint FAR_PASCAL
TSPrepareTele ( char *NomDiag);

extern Longint FAR_PASCAL
TSArchive (char *NomDiag);

extern Longint FAR_PASCAL
TSEnregistrable (char *NomDiag, 
                 int val);

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

/* He les loulous faudrait voir de tout mettre
   pour que ca gaze !!!!   YB 12/6/96 14h */
/*extern Longint FAR_PASCAL 
TSDescDon_choc (char *NomDon,
         Longint num_choc,
         ts_donnee **pt_val );
*/

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

	  int nsock,
          	  char *parametre,
	  Longint longbuffer,
	  Longint code_param);

extern Longint FAR_PASCAL Fin_Emission (int nsock);

Longint FAR_PASCAL
Emission_DescDon (

                int nsock,
     		short int code_fonc,
		char *nom_don);

extern Longint FAR_PASCAL
Reception (
	   int nsock,
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

extern Longint FAR_PASCAL
                Debut_Communication (int *NumSocket, int ind_base);

extern void 
Fin_Communication (
		   int nsock
);

/* --- module TSutil.c --- */

extern Longint FAR_PASCAL
Emission_Entrees (
		  int nsock,
		  pS_Entree ptent,
		  Longint code_param);



extern Longint FAR_PASCAL
Reception_Donnee (
		  int nsock,
		  pS_Donnee * ptdon,
		  Longint code_param);


extern Longint FAR_PASCAL
Reception_DescEntree (
	      int nsock,
	      pS_DescEntree * ptent,
	      Longint code_param);


extern Longint FAR_PASCAL
Reception_DescCoord (
	     int nsock,
	     pS_DescCoord * ptcoord,
	     Longint code_param);

extern Longint FAR_PASCAL
Reception_Chaine (
	  int nsock,
	  char **chaine,
	  Longint code_param);



extern Longint FAR_PASCAL
Reception_DescTrait (
	     int nsock,
	     pS_DescTrait * pttrait,
	     Longint code_param);


extern Longint FAR_PASCAL
Reception_DescDiag (
	    int nsock,
	    pS_DescDiag * ptdiag,
	    Longint code_param);


extern Longint FAR_PASCAL
Reception_DescDon (
	   int nsock,
	   pS_DescDon * ptdon,
	   Longint code_param);


extern Longint FAR_PASCAL
Reception_Unite (
	 int nsock,
	 pS_Unite * ptunite,
	 Longint code_param);


extern Longint FAR_PASCAL
Reception_Tableau (
	   int nsock,
	   char HUGE * Tab,
	   Longint Tablg,
	   char *Tabtyp,
	   Longint code_param);


extern Longint FAR_PASCAL
Reception_Tab_Coord (
	     int nsock,
	     char *Tab,
	     Longint *Tablg,
	     char *Tabtyp,
	     Longint Typtab,
	     Longint code_param);

/* --- module TSerr.c --- */

extern Longint			/* C declaration */
Gestion_Erreur (Longint erreur,
		Longint param);


