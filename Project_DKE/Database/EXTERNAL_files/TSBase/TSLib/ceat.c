
/*  ceat.c: module des fonctions cea    */
/*****************************************
          TSLDiag
          TSLSig
          TSRqdecl
          TSGetinfo
          TSLTrait
          TSRqentete_sig
          TSRqentete_par
          TSRqstop
          TSTData
          TSRqt
          TSLgDiag
          TSwriteParam 
          TSlistObjet
          TSRqParm
          TSdescObjet 
	  TStele
	  TSChargerObjet
	  TSDescDon_choc
	  TSPrepareTele
	  TSArchive
	  TSEnregistrable
          TSrqEtat 
          TSWfile
          TSRfile
          TSListOccTrait
******************************************/

#include <stdio.h> 
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <errno.h>

#include "tsdef.h"              /* liste des constantes utilisees */
#include "tsconf.h"             /* configuration du client        */
#if (client == INTEL)
#include <stdarg.h>
#else
#include <varargs.h>
#endif
#if (client == MAC)

#endif
#include "tsfonc.h"             /* liste des fonctions appelees   */
#include "tsmes.h"              /* liste des erreurs              */
#include "tstype.h"             /* liste des types de donnees     */
#include "tsext.h"              /* liste des variables globales   */
#if (client == INTEL)
#include <rmx_c.h>
#endif
#include "ceat.h"               /* erreurs nouvelles  */
#include "ceaf.h"               /* fonctions nouvelles */
#include "functs.h"		/* prototypes fcts TSLib */
#include "tsarcad.h"		/* types Arcad */
#include "def.h"		/* pour formats Arcad */

#define PREPASIZE       	8
#define TAILLE_TYPE_OBJET	17
#define TAILLE_NOM_FICHIER	256
#define TO_COMMON  		28
#define MTU_SPECIAL		1460
#define TAILLE_DATE_DC          11

int typfor( int );
extern void lzrw1_decompress(); 

/****************************************/
/*  Liste des diagnostics pour un choc  */
/****************************************/
Longint FAR_PASCAL
TSLDiag (	Longint numchoc,
		Longint *nbdiag,
     		char *ListeDiag[]    )

{
  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee         */
  Longint Resultat;            /* compte-rendu d'execution du client        */

  char *pts;
  char *ptd;
  char *ListeD;
  Longint CR;
  int i;
  char bufparam[taille_short+taille_long];


  if (numchoc < 0)
    return numero_choc_invalide;

  if ((numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST) ){
                                 /* Ancienne fonction */
    /* constitution du buffer des parametres */
    if(compress_on)
      CodeFonc = fonc_tsrqldiag;
    else
      CodeFonc = -(fonc_tsrqldiag - MAX_FUNCT_NUMBER);

    memcpy(bufparam, (char *)&CodeFonc, taille_short);
    memcpy(&bufparam[2], (char *)&numchoc, taille_long);

    /* debut de communication */
    if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;

    /* emission du code de la fonction et des parametres */
    if ((Resultat = Emission (NumSocket, bufparam, taille_short+taille_long,
          p_codefonc)) == erreur_emission)
            return Resultat;

    /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
    if ((Resultat = Fin_Emission (NumSocket)) == erreur_fin_emission)
      return Resultat;
#endif

    /* reception des parametres */

    if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
           == erreur_reception)
      return Resultat;

    if (CR == ok)
      {
        if ((Resultat = Reception (NumSocket, (char *) nbdiag, taille_long,
                   p_entrees)) == erreur_reception)
           return Resultat;

        if ((Resultat = Reception_Chaine (NumSocket, &ListeD, p_entrees))
                 == erreur_reception)
	  return Resultat;

        pts = ListeD;

        for (i = 0; i < *nbdiag; i++)
	{
#if (client == PC)
	  (ListeDiag)[i] = (char *) GlobalLock(GlobalAlloc(GMEM_MOVEABLE,
				PREPASIZE + 1));
#else
	  (ListeDiag)[i] = (char *) malloc(PREPASIZE + 1);
#endif 
	  ptd = ListeDiag[i];
	  while (*pts != ':' && *pts != '\0')
	    *ptd++ = *pts++;
	  *ptd++ = '\0';
	  pts++;
	} /* fin nb diag  */
      }
    /* fin de communication */

    Fin_Communication (NumSocket);

  } /* fin ancienne fonction choc < BASE */
  else
  {
    ts_objet *p_ts_obj, *p_tmp;
    char **pt_cmt;

    CR = TSlistObjet (numchoc, "*", "DIAGNOSTIC",
                      &p_ts_obj, &pt_cmt, nbdiag);
    if (CR == 0)
    {
      p_tmp = p_ts_obj;
      for (i = 0; i < *nbdiag; i++)
        {
#if (client == PC)
          (ListeDiag)[i] = (char *) GlobalLock(GlobalAlloc(GMEM_MOVEABLE,
                                L_NOM_PRODUCTEUR ));
#else
          (ListeDiag)[i] = (char *) malloc(L_NOM_PRODUCTEUR);
#endif
          strcpy((ListeDiag)[i],p_tmp->nom_objet);
          free (pt_cmt[i]);
          p_tmp++;
        }
        free (p_ts_obj);
        free(pt_cmt);
     }

   }

  return CR;

}
/************/
Longint FAR_PASCAL
TSLSig (	Longint numchoc,
		char *NomDiag,
		Longint *nbsig,
		char *ListeSig[]      )

{

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee         */
  Longint Resultat, CR;        /* compte-rendu d'execution du client        */

  char *pts;
  char *ptd;
  char *ListeS;

  int i, j;
  char bufparam[taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC];

  if (numchoc < 0)
    return numero_choc_invalide;
  if (Strlen (NomDiag) == 0)
    return nom_diagnostic_invalide;

  if ( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST) ) { /* Ancienne fonction */
    if(compress_on)
      CodeFonc = fonc_tsrqlsig;
    else
      CodeFonc = -(fonc_tsrqlsig - MAX_FUNCT_NUMBER);

    /* constitution du buffer des parametres */
    memcpy(bufparam, (char *)&CodeFonc, taille_short);
    memcpy(&bufparam[2], (char *)&numchoc, taille_long);
    strcpy(&bufparam[6], NomDiag);

    /* debut de communication */
    if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
      return Resultat;

    /* emission du code de la fonction et des parametres */
    if ((Resultat = Emission (NumSocket, bufparam, taille_short +
         taille_long + TAILLE_NOM_DIAGNOSTIC, p_codefonc)) == erreur_emission)
    return Resultat;

    /* fin d'emission */
#if ((client!=PC) && (client !=MAC))
    if ((Resultat = Fin_Emission (NumSocket)) == erreur_fin_emission)
      return Resultat;
#endif

    /* reception des parametres */

    if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
        == erreur_reception)
      return Resultat;

    if (CR == ok)
      {
        if ((Resultat = Reception (NumSocket, (char *) nbsig, taille_long,
                 p_entrees)) == erreur_reception)
           return Resultat;

        if ((Resultat = Reception_Chaine (NumSocket, &ListeS, p_entrees))
              == erreur_reception)
	  return Resultat;

        pts = ListeS;

        for (i = 0; i < *nbsig; i++)
          {
#if (client == PC)
 	  (ListeSig)[i] = (char *) GlobalLock(GlobalAlloc(GMEM_MOVEABLE,
				PREPASIZE + 1));
#else
	  (ListeSig)[i] = (char *) malloc(PREPASIZE + 1);
#endif
	  ptd = ListeSig[i];
	  for (j = 0; j < PREPASIZE; j++)
	    *ptd++ = *pts++;
	  *ptd++ = '\0';
	}
    }
    /* fin de communication */
    Fin_Communication (NumSocket);
  } /* fin ancienne fonction : choc < BASE */

   else
    {
    ts_objet *p_ts_obj, *p_tmp;
    char **pt_cmt;

    CR = TSlistObjet (numchoc, NomDiag, "DONNEE",
                      &p_ts_obj, &pt_cmt, nbsig);
    if (CR == 0)
    {
      p_tmp = p_ts_obj;
      for (i = 0; i < *nbsig; i++)
        {
#if (client == PC)
          (ListeSig)[i] = (char *) GlobalLock(GlobalAlloc(GMEM_MOVEABLE,
                               TAILLE_NOM_DONNEE ));
#else
          (ListeSig)[i] = (char *) malloc(TAILLE_NOM_DONNEE);
#endif
          strcpy((ListeSig)[i],p_tmp->nom_objet);
          free (pt_cmt[i]);
          p_tmp++;
        }
        free (p_ts_obj);
        free(pt_cmt);
      }
    }

  return CR;

}

/************/
Longint FAR_PASCAL
TSRqdecl (	Longint numchoc,
		char *nomdec,
		Longint numoccur,
		float *datedec    )

{
  Longint CR;

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee         */
  Longint Resultat;            /* compte-rendu d'execution du client        */
  char bufparam[taille_short+taille_long+L_NOM_DECLENCHE+taille_long];

  if (numchoc < 0)
    return numero_choc_invalide;

  if (Strlen (nomdec) == 0)
    return nom_declenche_invalide;

  /* constitution du buffer des parametres */
 
 if(compress_on)
    CodeFonc = fonc_tsrqdecl;
  else
    CodeFonc = -(fonc_tsrqdecl - MAX_FUNCT_NUMBER);

  memcpy(bufparam, (char *)&CodeFonc, taille_short);
  memcpy(&bufparam[2], (char *)&numchoc, taille_long);
  strcpy(&bufparam[6], nomdec);
  memcpy(&bufparam[6+L_NOM_DECLENCHE], &numoccur, sizeof(int) );
  
   /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction et des parametres */

  if ((Resultat = Emission (NumSocket, bufparam,
          taille_short+taille_long+L_NOM_DECLENCHE+taille_long, p_codefonc))
      == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long,p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception (NumSocket, (char *) datedec, taille_float, p_date))
	  == erreur_reception)
	return Resultat;
      /* Prise en compte Declenches en ms pour Chocs ARCAD ou chocs de TEST */
      if ((numchoc >= NUM_CHOC_BASE)||(numchoc <=  NUM_CHOC_TEST)) 
          *datedec = *datedec * 1e3; 

    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
/************/
Longint FAR_PASCAL
TSGetinfo ( Longint *numchoc )

{
  Longint CR;

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee         */
  Longint Resultat;            /* compte-rendu d'execution du client        */

  /* constitution du buffer des parametres */

  if(compress_on)
    CodeFonc = fonc_tsgetinfo;
  else
    CodeFonc = -(fonc_tsgetinfo - MAX_FUNCT_NUMBER);

  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short,p_codefonc))
      == erreur_emission)
    return Resultat;

  /* emission des parametres */

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception (NumSocket, (char *) numchoc, taille_long,p_numchoc))
	  == erreur_reception)
	return Resultat;

    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
/***********/
Longint FAR_PASCAL
TSLTrait(	Longint  *nbtrait,
     		char *ListeTrait[]   )

{
  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee         */
  Longint Resultat;            /* compte-rendu d'execution du client        */

  char *pts;
  char *ptd;
  char *ListeT;
  Longint CR;
  int i;

  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsltrait;
  else
    CodeFonc = -(fonc_tsltrait - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception (NumSocket, (char *) nbtrait, taille_long,p_entrees))
	  == erreur_reception)
	return Resultat;

      if ((Resultat = Reception_Chaine (NumSocket, &ListeT, p_entrees))
	  == erreur_reception)
	return Resultat;

      pts = ListeT;

      for (i = 0; i < *nbtrait; i++)
       {
#if ( client == PC )  
	   (ListeTrait)[i] = (char *) GlobalLock( 
			GlobalAlloc(GMEM_MOVEABLE, TAILLE_NOM_TRAITEMENT) ) ;            
#else
	  (ListeTrait)[i] = (char *) malloc (TAILLE_NOM_TRAITEMENT);
#endif
	  ptd = ListeTrait[i];
	  while (*pts != ':' && *pts != '\0')
	    *ptd++ = *pts++;
	  *ptd++ = '\0';
	  pts++;
	}

    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

int typfor (int format)
{
  switch (format)
    {
    case 1:
      return (1);
    case 2:
    case 10:
    case 17:
      return (16);
    case 3:
      return (2);
    case 4:
    case 5:
    case 7:
      return (4);
    case 6:
    case 8:
      return (8);
    case 9:
      return (14);
    case 11:
    case 12:
      return (10);
    case 13:
      return (44);
    case 14:
      return (56);
    case 15:
      return (40);
    case 16:
      return (12);
    }
}


/************/
Longint FAR_PASCAL
TSRqentete_sig (	Longint numchoc,
			char *nomdiag,
			char *nomobj,
			char *unites,
     			float *calibration    )
{
  Longint CR;

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee         */
  Longint Resultat;            /* compte-rendu d'execution du client        */

  char *buffer;
  char bufparam[taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC+L_NOM_OBJET];

  if (numchoc < 0)
    return numero_choc_invalide;

  if (Strlen (nomdiag) == 0)
    return nom_diagnostic_invalide;
  if (Strlen (nomobj) == 0)
    return nom_objet_invalide;

  if(compress_on)
    CodeFonc = fonc_tsrqentete_sig;
  else
    CodeFonc = -(fonc_tsrqentete_sig - MAX_FUNCT_NUMBER);

  /* constitution du buffer des parametres */

  memcpy(bufparam, (char *)&CodeFonc, taille_short);
  memcpy(&bufparam[2], (char *)&numchoc, taille_long);
  strcpy(&bufparam[6], nomdiag);
  strcpy(&bufparam[6+TAILLE_NOM_DIAGNOSTIC], nomobj);

  /* debut de communication */
    if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
      return Resultat;

  /* emission du code de la fonction et des parametres */

  if ((Resultat = Emission (NumSocket, bufparam,
          taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC+L_NOM_OBJET,
          p_codefonc))
      == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long,p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception (NumSocket, (char *) calibration, taille_float, p_entrees))
	  == erreur_reception)
	return Resultat;
/****      ++++++++      *****/
      if ((Resultat = Reception_Chaine (NumSocket, &buffer,p_entrees))
	  == erreur_reception)
	return Resultat;

      Memcpy (unites, buffer, sizeof(buffer));
/****      ++++++++      *****/
    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

/************/
Longint FAR_PASCAL
TSRqentete_par (	Longint numchoc,
			char *nomdiag,
			char *nomobj ,
			char *nompar,
			char *unites       )
{
  Longint CR;

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee         */
  Longint Resultat;            /* compte-rendu d'execution du client        */

  char *buffer;
  char bufparam[taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC+L_NOM_OBJET+L_NOM_PARAM];

  if (numchoc < 0)
    return numero_choc_invalide;

  if (Strlen (nomdiag) == 0)
    return nom_diagnostic_invalide;
  if (Strlen (nomobj) == 0)
    return nom_objet_invalide;

  /* constitution du buffer des parametres */

  if(compress_on)
    CodeFonc = fonc_tsrqentete_par;
  else
    CodeFonc = -(fonc_tsrqentete_par - MAX_FUNCT_NUMBER);

  memcpy(bufparam, (char *)&CodeFonc, taille_short);
  memcpy(&bufparam[2], (char *)&numchoc, taille_long);
  strcpy(&bufparam[6], nomdiag);
  strcpy(&bufparam[6+TAILLE_NOM_DIAGNOSTIC], nomobj);
  strcpy(&bufparam[6+TAILLE_NOM_DIAGNOSTIC+L_NOM_OBJET], nompar);

 
  /* debut de communication */
    if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
      return Resultat;

  /* emission du code de la fonction et des parametres */

  if ((Resultat = Emission (NumSocket, bufparam, taille_short + taille_long +
         TAILLE_NOM_DIAGNOSTIC + L_NOM_OBJET + L_NOM_PARAM, p_codefonc))
      == erreur_emission)
    return Resultat;


  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long,p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {
/****      ++++++++      *****/
      if ((Resultat = Reception_Chaine (NumSocket, &buffer, p_entrees))
	  == erreur_reception)
	return Resultat;

      Memcpy (unites, buffer, 6 * sizeof(char));
/****      ++++++++      *****/
    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

/************/
Longint FAR_PASCAL
TSRqstop ()

{
  Longint CR=0;

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee         */
  Longint Resultat;            /* compte-rendu d'execution du client        */


  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsrqstop;
  else
    CodeFonc = -(fonc_tsrqstop - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short,p_codefonc))
      == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
/************/
Longint FAR_PASCAL
TSTData (	Longint numchoc,
		char * nom_diag,
		Longint * t_choc,
		Longint * t_param )

{
  int NumSocket;		/* descripteur de la socket de communication */
  short int CodeFonc;		/* code de la fonction TSLib appelee         */
  Longint Resultat;		/* compte-rendu d'execution du client        */

  Longint CR;
  char bufparam[taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC];

  if (numchoc < 0)
    return numero_choc_invalide;

  /* constitution du buffer des parametres */

  if(compress_on)
    CodeFonc = fonc_tsrqtdata;
  else
    CodeFonc = -(fonc_tsrqtdata - MAX_FUNCT_NUMBER);
 
  memcpy(bufparam, (char *)&CodeFonc, taille_short);
  memcpy(&bufparam[2], (char *)&numchoc, taille_long);
  strcpy(&bufparam[6], nom_diag);

  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction et des parametres */

  if ((Resultat = Emission (NumSocket, bufparam,
          taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC,
          p_codefonc))
      == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long,p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception (NumSocket, (char *) t_choc, taille_long,p_entrees))
	  == erreur_reception)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) t_param, taille_long,p_entrees))
	  == erreur_reception)
	return Resultat;
    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
/************/
Longint FAR_PASCAL
TSRqt (	char * Requete,
	char ** ShotList,
     	Longint * LShotList )

{
  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee         */
  Longint Resultat;            /* compte-rendu d'execution du client        */

  Longint CR;
  Longint lReq;

  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsrqt;
  else
    CodeFonc = -(fonc_tsrqt - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      == erreur_emission)
    return Resultat;

   lReq =(Longint) Strlen(Requete) + 1 ; /*  for '\0'  */

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, (char *) &lReq, taille_long,p_numchoc))
      == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, Requete, lReq, p_nomdiag ))
      == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception (NumSocket, (char *) LShotList, taille_long, p_entrees))
	  == erreur_reception)
	return Resultat;

      if ((Resultat = Reception_Chaine (NumSocket, ShotList, p_entrees))
	  == erreur_reception)
	return Resultat;

    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
/************/
Longint FAR_PASCAL
TSLgDiag (	Longint numchoc,

		char *nomdiag,
		Longint *nbmes   )
{
  Longint CR;

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee         */
  Longint Resultat;            /* compte-rendu d'execution du client        */
  char bufparam[taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC];


  if (numchoc < 0)
    return numero_choc_invalide;

  if (Strlen (nomdiag) == 0)
    return nom_diagnostic_invalide;

  /* constitution du buffer des parametres */

  if(compress_on)
    CodeFonc = fonc_tslgdiag;
  else
    CodeFonc = -(fonc_tslgdiag - MAX_FUNCT_NUMBER);

  memcpy(bufparam, (char *)&CodeFonc, taille_short);
  memcpy(&bufparam[2], (char *)&numchoc, taille_long);
  strcpy(&bufparam[6], nomdiag);

  /* debut de communication */
  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
          return Resultat;

  /* emission du code de la fonction et des parametres */
  if ((Resultat = Emission (NumSocket, bufparam, taille_short + taille_long +
        TAILLE_NOM_DIAGNOSTIC, p_codefonc)) == erreur_emission)
    return Resultat;

  /* fin d'emission */
#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */
  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long,p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception (NumSocket, (char *) nbmes, taille_long,p_entrees))
	  == erreur_reception)
	return Resultat;

    }
  /* fin de communication */
  Fin_Communication (NumSocket);

  return CR;

}

/*          ++++++++++++++++++++++++++++++++++++++++++++         */

/************/
Longint FAR_PASCAL
TSwriteParam (	Longint numchoc,
                char *nomdiag,
		char *nomobj,
		char *nomparam,
                Longint n,
		Longint nbval[],
		Longint lgval[],
		char *buff)

{
  Longint CR;

  int NumSocket;         /* descripteur de la socket de communication */
  short int CodeFonc;    /* code de la fonction TSLib appelee         */
  Longint Resultat, i, lgdata = 0; 

  char *bufparam, *cp = nomparam;

  if( n < 1)
    return nom_parametre_invalide;
  if (Strlen (nomdiag) == 0)
    return nom_diagnostic_invalide;
  if (Strlen (nomobj) == 0)
    return nom_objet_invalide;

  if (lgval[0] <= 0)
    return(p_longueurs);

  if( (bufparam = (char *) malloc( (size_t) (L_NOM_PRODUCTEUR + L_NOM_OBJET +
                                 (n * L_NOM_PARAM) +
                            (n * taille_long) + (n * taille_long)))) == NULL)
       return(-10000);

  /* constitution du buffer des parametres */

  if(compress_on)
    CodeFonc = fonc_tswparm;
  else
    CodeFonc = -(fonc_tswparm - MAX_FUNCT_NUMBER);

  /* memcpy(bufparam, (char *)&CodeFonc, taille_short); */
  strcpy(bufparam, nomdiag);
  strcpy(&bufparam[L_NOM_PRODUCTEUR], nomobj);

  for (i = 0; i < n ; i++)
   {
      memcpy(&bufparam[L_NOM_PRODUCTEUR + L_NOM_OBJET +( L_NOM_PARAM * i)],
              cp, L_NOM_PARAM);
      cp += L_NOM_PARAM;
      lgdata += lgval[i];
   }
  
  memcpy((char *) &bufparam[L_NOM_PRODUCTEUR + L_NOM_OBJET+ (n * L_NOM_PARAM)],
         (int *) nbval, (n * sizeof(int)) );

  memcpy((char *)&bufparam[L_NOM_PRODUCTEUR +L_NOM_OBJET + (n * L_NOM_PARAM) +
        (n * taille_long)], (int *)lgval, (n * sizeof(int)) );

  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction et des parametres */

  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &numchoc, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &n, taille_long, p_codefonc))
           == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, bufparam, L_NOM_PRODUCTEUR +
                  L_NOM_OBJET + (n * L_NOM_PARAM) + (n * taille_long) +
                  (n * taille_long) , p_codefonc)) == erreur_emission)
    return Resultat;

  /* Emission des donnees */

  if ((Resultat = Emission (NumSocket, buff, lgdata, p_nomdiag ))
      == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
/*****************************************************************************/

/************/
Longint FAR_PASCAL
TSlistObjet (	Longint numchoc,
  		char *nomdiag,
		char *typobj,
		ts_objet **pt_obj,
                char ***pt_cmt,
                Longint *nbrep) 

{
  Longint CR;
  int ind_base;

  char bufparam[taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC+TAILLE_TYPE_OBJET];

  int NumSocket;          /* descripteur de la socket de communication */
  short int CodeFonc;     /* code de la fonction TSLib appelee         */
  Longint Resultat;       /* compte-rendu d'execution du client        */

  char *buffer, *buffer_cmt, *pts, *ptd;
  int i;

  if (numchoc < 0)
    return numero_choc_invalide;
  if (Strlen (nomdiag) == 0)
    return nom_diagnostic_invalide;
  if (Strlen (typobj) == 0)
    return nom_objet_invalide;

  /* emission du code de la fonction */
  if(compress_on)
    CodeFonc = fonc_tslistobjet;
  else
    CodeFonc = -(fonc_tslistobjet - MAX_FUNCT_NUMBER);

 /* constitution du buffer des parametres */

  memcpy(bufparam, (char *)&CodeFonc, taille_short);
  memcpy(&bufparam[2], (char *)&numchoc, taille_long);
  strcpy(&bufparam[6], nomdiag);
  strcpy(&bufparam[6+TAILLE_NOM_DIAGNOSTIC], typobj);

  /* debut de communication */
   if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
     return Resultat;

  /* emission du code de la fonction et des parametres */

  if ((Resultat = Emission (NumSocket, bufparam, taille_short + taille_long +
      TAILLE_NOM_DIAGNOSTIC+TAILLE_TYPE_OBJET, p_codefonc)) == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {


      if ((Resultat = Reception (NumSocket, (char *) nbrep, taille_long, p_entrees))
	  == erreur_reception)
	return Resultat;

      if ((Resultat = Reception_Chaine (NumSocket, &buffer,p_entrees))
	  == erreur_reception)
	return Resultat;

      if( *nbrep != 0) {
      if ( (*pt_obj = (ts_objet *)calloc((size_t) *nbrep ,sizeof(ts_objet))) == NULL)
                   return(-50);

        Memcpy(*pt_obj, buffer, *nbrep * sizeof(ts_objet));
      }
      else
       *pt_obj = '\0';

      free(buffer);

      if( *nbrep != 0)  {
      if ((Resultat = Reception_Chaine (NumSocket, &buffer_cmt,p_entrees))
	  == erreur_reception)
	return Resultat;

      pts = buffer_cmt;

      if ( (*pt_cmt = (char **)calloc((size_t) *nbrep ,sizeof(char *))) == NULL)
                   return(-50);

     for (i = 0; i < *nbrep ;i++) {
     if ( ((*pt_cmt)[i] = (char *) calloc((size_t) L_COMMENTAIRE_OBJET, 
                  sizeof( char))) == NULL)
           return (-50);

     ptd = (*pt_cmt)[i];
     while(*pts != '\0')
         *ptd++ = *pts++ ;
         *ptd++ = '\0';
         pts++;
      }

    free(buffer_cmt);
     }
    }

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

/************/
Longint FAR_PASCAL
TSRqParm ( va_alist )
#if (client != INTEL)
va_dcl
#endif
{
  va_list arg;
  Longint numchoc;
  char *nomdiag;
  char *nomobj;
  char *nomparam;

  Longint nbval;
  char **buff;
  Longint *nrep;
  Longint *fmt;

  Longint CR;

  int NumSocket;            /* descripteur de la socket de communication */
  short int CodeFonc;       /* code de la fonction TSLib appelee         */
  Longint Resultat;         /* compte-rendu d'execution du client        */

  char *buffer;
  Longint lg;
  char bufparam[taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC+L_NOM_OBJET+L_NOM_PARAM+taille_long];
  int sz;
  int flag_mem = 0;

  /* recuperation des arguments de la fonction */

#if (client != INTEL)
  va_start(arg);
#else
  va_start(arg,nomparam);
#endif
  numchoc  = va_arg(arg, Longint);
  if (numchoc < 0)
    return numero_choc_invalide;
  nomdiag  = va_arg(arg, char *);
  nomobj   = va_arg(arg, char *);
  nomparam = va_arg(arg, char *);
  nbval    = va_arg(arg, Longint );
  buff     = va_arg(arg, char **);
  nrep     = va_arg(arg, Longint *);
  fmt      = va_arg(arg, Longint *);
  va_end(arg);
 
  if (Strlen (nomdiag) == 0)
    return nom_diagnostic_invalide;
  if (Strlen (nomobj) == 0)
    return nom_objet_invalide;
  if (Strlen (nomparam) == 0)
    return nom_parametre_invalide;

  if ( (numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST) ) {

    /* constitution du buffer des parametres */

    if(compress_on)
      CodeFonc = fonc_tsrqparm;
    else
      CodeFonc = -(fonc_tsrqparm - MAX_FUNCT_NUMBER);

    memcpy(bufparam, (char *)&CodeFonc, taille_short);
    memcpy(&bufparam[2], (char *)&numchoc, taille_long);
    strcpy(&bufparam[6], nomdiag);
    strcpy(&bufparam[6+PREPASIZE+1], nomobj);
    strcpy(&bufparam[6+PREPASIZE+PREPASIZE+2], nomparam);
    memcpy(&bufparam[6+PREPASIZE+PREPASIZE+PREPASIZE+3], (char *)&nbval, taille_long);

    /* debut de communication */
    if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
      return Resultat;

    /* emission du code de la fonction et des parametres */

    if ((Resultat = Emission (NumSocket, bufparam, taille_short + taille_long +
       PREPASIZE+PREPASIZE+PREPASIZE+3+taille_long, p_codefonc))
        == erreur_emission)
      return Resultat;

  } else {
    /* constitution du buffer des parametres */

    if(compress_on)
      CodeFonc = fonc_tsrqParm;
    else
      CodeFonc = -(fonc_tsrqParm - MAX_FUNCT_NUMBER);
    memcpy(bufparam, (char *)&CodeFonc, taille_short);
    memcpy(&bufparam[taille_short], (char *)&numchoc, taille_long);
    strcpy(&bufparam[taille_short+taille_long], nomdiag);
    strcpy(&bufparam[taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC], nomobj);
    strcpy(&bufparam[taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC+
                                      L_NOM_OBJET], nomparam);
  
    /* debut de communication */

    if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
      return Resultat;

    /* emission du code de la fonction et des parametres */

    if ((Resultat = Emission (NumSocket, bufparam, taille_short + taille_long +
       TAILLE_NOM_DIAGNOSTIC+L_NOM_OBJET+L_NOM_PARAM, p_codefonc))
        == erreur_emission)
      return Resultat;

  }

    /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
    if ((Resultat = Fin_Emission (NumSocket))
        == erreur_fin_emission)
      return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

    /* fin d'emission */

  if (CR == ok) {
      if ((Resultat = Reception (NumSocket, (char *) nrep, taille_long, p_entrees))
	  == erreur_reception)
	return Resultat; 

      if ((Resultat = Reception (NumSocket, (char *) fmt, taille_long, p_entrees))
	  == erreur_reception)
	return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) &lg, taille_long, p_entrees))
	     == erreur_reception)
	    return Resultat;

      if ((Resultat = Reception_Chaine (NumSocket, &buffer, p_entrees))
        	  == erreur_reception)
         return Resultat;

      if ( lg ==  0) {  /* pas de valeurs */
         buff = '\0';
         Fin_Communication (NumSocket);
         return (-678);
      }

      if ( *buff == NULL ) {  /* on alloue un peu de memoire */
         flag_mem =  1;
         if ( (*buff =(char *) calloc((size_t)lg, sizeof(char))) == NULL)
            return(-50);
      }
      

      if( (numchoc >= NUM_CHOC_BASE) || (numchoc <= NUM_CHOC_TEST) ){
        char *pt_buff;
        int nb_val = ( (*nrep >= nbval) ? nbval : *nrep);
        if(flag_mem)
          pt_buff = *buff;
        else
          pt_buff = (char *)buff;

        switch (*fmt)
         {
           case OCTET:
                 {
                   ts_v_int1 *pt;
                   int i;
                        
                   pt = (ts_v_int1 *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->integer1), sizeof(short));
                      pt_buff += sizeof(short);
                      pt++;
                    }
                 }
                      break;

           case STRING12:
               {
                   ts_v_char12 *pt;
                   int i;

                   pt = (ts_v_char12 *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->char12, sizeof(char) * THE_SIZE);
                      pt_buff += sizeof(char) * THE_SIZE;
                      pt++;
                    }
                 }
                      break;
           case INT16:
               {
                   ts_v_int2 *pt;
                   int i;


                   pt = (ts_v_int2 *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->integer2), sizeof(short));
                      pt_buff += sizeof(short) ;
                      pt++;
                    }
                 }
                      break;
           case INT32:
               {
                   ts_v_int4 *pt;
                   int i;

                   pt = (ts_v_int4 *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->integer4), sizeof(int));
                      pt_buff += sizeof(int) ;
                      pt++;
                    }
                 }
                      break;
           case REEL16:
               {
                   ts_v_float4 *pt;
                   int i;

                   pt = (ts_v_float4 *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->float4), sizeof(float));
                      pt_buff += sizeof(float) ;
                      pt++;
                    }
                 }
                      break;
           case REEL32:
               {
                   ts_v_float8 *pt;
                   int i;

                   pt = (ts_v_float8 *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->float8), sizeof(double));
                      pt_buff += sizeof(double) ;
                      pt++;
                    }
                 }
                      break;
           case TWIN_INT16:
               {
                   ts_v_int2_int2 *pt;
                   int i;

                   pt = (ts_v_int2_int2 *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->int2_1), sizeof(short));
                      pt_buff +=  sizeof(short) ;
                      memcpy(pt_buff, &(pt->int2_2), sizeof(short));
                      pt_buff +=  sizeof(short) ;
                      pt++;
                    }
                 }
                      break;
           case TWIN_REEL32:
               {
                   ts_v_float4_float4 *pt;
                   int i;

                   pt = (ts_v_float4_float4 *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->float4_1), sizeof(float));
                      pt_buff +=  sizeof(float) ;
                      memcpy(pt_buff, &(pt->float4_2), sizeof(float));
                      pt_buff +=  sizeof(float) ;
                      pt++;
                    }
                 }
                      break;
           case INT_REEL32:
               {
                   ts_v_int4_float4 *pt;
                   int i;

                   pt = (ts_v_int4_float4 *)buffer;

                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->integer4), sizeof(int));
                      pt_buff += sizeof(int) ;
                      memcpy(pt_buff, &(pt->float4), sizeof(float));
                      pt_buff += sizeof(float) ;
                      pt++;
                    }
                 }
                      break;
           case VOIE:
               {
                   ts_v_voie *pt;
                   int i;

                   pt = (ts_v_voie *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->voie), sizeof(short));
                      pt_buff += sizeof(short) ;
                      memcpy(pt_buff, pt->nom_carte, 
                                       sizeof(char) * L_NOM_CARTE);
                      pt_buff += (sizeof(char) * L_NOM_CARTE);
                      pt++;
                    }
                 }
                      break;
           case FONCTION:
               {
                   ts_fonction *pt;
                   int i;

                   pt = (ts_fonction *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->type, sizeof(char) * 3);
                      pt_buff += (sizeof(char) * 3);
                      memcpy(pt_buff, &(pt->amplitude), sizeof(float));
                      pt_buff +=  sizeof(float);
                      memcpy(pt_buff, &(pt->periode), sizeof(float));
                      pt_buff +=  sizeof(float);
                      memcpy(pt_buff, &(pt->ti), sizeof(float));
                      pt_buff +=  sizeof(float);
                      memcpy(pt_buff, &(pt->tf), sizeof(float));
                      pt_buff +=  sizeof(float);
                      memcpy(pt_buff, &(pt->yi), sizeof(float));
                      pt_buff +=  sizeof(float);
                      memcpy(pt_buff, &(pt->yf), sizeof(float));
                      pt_buff +=  sizeof(float);
                      memcpy(pt_buff, &(pt->offset), sizeof(short));
                      pt_buff += sizeof(short) ;
                      pt++;
                    }
                  }
                      break;
           case VOIE_GAIN:
               {
                   ts_v_voie_gain *pt;
                   int i;

                   pt = (ts_v_voie_gain *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->voie), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, &(pt->gainpro), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, &(pt->gainfix), sizeof(float));
                      pt_buff += sizeof(float);
                      pt++;
                    }
                 }
                      break;
           case REGISTRE:
               {
                   ts_v_registres *pt;
                   int i;

                   pt = (ts_v_registres *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->numreg), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, pt->declenche, 
                                          (L_NOM_DECLENCHE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_DECLENCHE;
                      memcpy(pt_buff, pt->comment, 
                                           (L_COMMENTAIRE * sizeof(char)));
                      pt_buff += sizeof(char) * L_COMMENTAIRE;
                      pt++;
                    }
                 }
                      break;
           case F_STRAT_DIAG:
               {
                   ts_v_stratdiag *pt;
                   int i;

                   pt = (ts_v_stratdiag *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->nomdonnee, 
                                          (L_NOM_DONNEE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_DONNEE ;
                      memcpy(pt_buff, &(pt->algo), sizeof(short));
                      pt_buff +=  sizeof(short);
                      memcpy(pt_buff, &(pt->a), sizeof(short));
                      pt_buff +=  sizeof(short);
                      memcpy(pt_buff, &(pt->b), sizeof(short));
                      pt_buff +=  sizeof(short);
                      pt++;
                    }
                 }
                      break;
           case STRAT_PILOTE:
               {
                   ts_v_stratpil *pt;
                   int i;

                   pt = (ts_v_stratpil *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->nom_diag, 
                                          (L_NOM_PRODUCTEUR * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_PRODUCTEUR ;
                      memcpy(pt_buff, pt->nom_strat, 
                                          (L_NOM_STRATEGIE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_STRATEGIE ;
                      pt++;
                    }
                 }
                      break;
           case DECL_COND:
               {
                   ts_v_decl_cond *pt;
                   int i;

                   pt = (ts_v_decl_cond *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->declenche, 
                                          (L_NOM_DECLENCHE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_DECLENCHE ;
                      memcpy(pt_buff, pt->condition, (33 * sizeof(char)));
                      pt_buff += sizeof(char) * 33 ;
                      pt++;
                    }
                 }
                      break;
           case EVT_EXTERNE:
               {
                   ts_v_evtext *pt;
                   int i;

                   pt = (ts_v_evtext *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->valid, (2 * sizeof(char)));
                      pt_buff += (2 * sizeof(char));
                      memcpy(pt_buff, pt->nomref, (L_NOM_REF * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_REF;
                      memcpy(pt_buff, pt->nomevt, (L_NOM_EVENEMENT *
                                                           sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_EVENEMENT;
                      memcpy(pt_buff, &(pt->debvalid), sizeof(float));
                      pt_buff += sizeof(float) ;
                      memcpy(pt_buff, &(pt->finvalid), sizeof(float));
                      pt_buff += sizeof(float) ;
                      memcpy(pt_buff, pt->comment, (L_COMMENTAIRE *
                                                           sizeof(char)));
                      pt_buff += sizeof(char) *  L_COMMENTAIRE ;
                      pt++;
                    }
                 }
                      break;
           case SERNAM:
               {
                   ts_v_sernam *pt;
                   int i;

                   pt = (ts_v_sernam *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->code), sizeof(short));
                      pt_buff += sizeof(short) ;
                      memcpy(pt_buff, pt->nom, (L_NOM_DECLENCHE*sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_DECLENCHE ;
                      memcpy(pt_buff, pt->affich, (2 * sizeof(char)));
                      pt_buff += sizeof(char) *  2 ;
                      memcpy(pt_buff, pt->comment, (L_COMMENTAIRE *
                                                           sizeof(char)));
                      pt_buff += sizeof(char) * L_COMMENTAIRE ;
                      pt++;
                    }
                 }
                      break;
           case CADRAN:
               {
                   ts_v_cadran *pt;
                   int i;

                   pt = (ts_v_cadran *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->code), sizeof(short));
                      pt_buff += sizeof(short) ;
                      memcpy(pt_buff, pt->nom, L_NOM_DECLENCHE * sizeof(char));
                      pt_buff += sizeof(char) *  L_NOM_DECLENCHE ;
                      memcpy(pt_buff, pt->affich, (2 * sizeof(char)));
                      pt_buff += sizeof(char) *  2;
                      memcpy(pt_buff, pt->stratpil, 
                                   (L_NOM_STRATEGIE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_STRATEGIE;
                      memcpy(pt_buff, pt->comment, (L_COMMENTAIRE *
                                                           sizeof(char)));
                      pt_buff += sizeof(char) * L_COMMENTAIRE ;
                      pt++;
                    }
                 }
                      break;
           case LIEN:
               {
                   ts_v_lien *pt;
                   int i;

                   pt = (ts_v_lien *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->declench1,
                                          L_NOM_DECLENCHE * sizeof(char));
                      pt_buff += sizeof(char) * L_NOM_DECLENCHE;
                      memcpy(pt_buff, pt->declench2,
                                          L_NOM_DECLENCHE * sizeof(char));
                      pt_buff += sizeof(char) * L_NOM_DECLENCHE;
                      pt++;
                    }
                 }
                      break;
           case DECL_SEQ:
               {
                   ts_v_decl_seq *pt;
                   int i;

                   pt = (ts_v_decl_seq *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->ctype, L_CTYPE * sizeof(char));
                      pt_buff += sizeof(char) * L_CTYPE ;
                      memcpy(pt_buff, pt->declenche,
                                          L_NOM_DECLENCHE * sizeof(char));
                      pt_buff += sizeof(char) *  L_NOM_DECLENCHE;
                      memcpy(pt_buff, pt->nom_carte,
                                          L_NOM_CARTE * sizeof(char));
                      pt_buff += sizeof(char) * L_NOM_CARTE;
                      pt++;
                    }
                 }
                      break;
           case VOIE_SEQ:
               {
                   ts_v_voie_seq *pt;
                   int i;

                   pt = (ts_v_voie_seq *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->voie), sizeof(short));
                      pt_buff +=  sizeof(short);
                      memcpy(pt_buff, &(pt->polar), sizeof(short));
                      pt_buff +=  sizeof(short);
                      memcpy(pt_buff, &(pt->dureeimp), sizeof(int));
                      pt_buff +=  sizeof(int);
                      memcpy(pt_buff, pt->comment, (L_COMMENTAIRE *
                                                           sizeof(char)));
                      pt_buff +=  sizeof(char) * L_COMMENTAIRE;
                      pt++;
                    }
                 }
                      break;
           case TAB_SEQ:
               {
                   ts_v_tab_seq *pt;
                   int i;

                   pt = (ts_v_tab_seq *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->voie), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, &(pt->temps), sizeof(int));
                      pt_buff += sizeof(int);
                      memcpy(pt_buff, &(pt->cadence), sizeof(int));
                      pt_buff += sizeof(int);
                      memcpy(pt_buff, &(pt->nbimp), sizeof(short));
                      pt_buff += sizeof(short);
                      pt++;
                    }
                 }
                      break;
           case T_DECODE:
               {
                   ts_v_t_decode *pt;
                   int i;

                   pt = (ts_v_t_decode *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->type, (2 * sizeof(char)));
                      pt_buff +=  sizeof(char) * 2;
                      memcpy(pt_buff, &(pt->numero), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, &(pt->polar), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, pt->declench1, 
                                   (L_NOM_DECLENCHE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_DECLENCHE;
                      memcpy(pt_buff, pt->declench2, 
                                   (L_NOM_DECLENCHE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_DECLENCHE;
                      memcpy(pt_buff, &(pt->duree), sizeof(int));
                      pt_buff += sizeof(int);
                      memcpy(pt_buff, pt->comment, (L_COMMENTAIRE *
                                                           sizeof(char)));
                      pt_buff += sizeof(char) * L_COMMENTAIRE;
                      pt++;
                    }
                 }
                      break;
           case T_IT:
               {
                   ts_v_t_it *pt;
                   int i;

                   pt = (ts_v_t_it *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->polar), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, pt->declenche, 
                                   (L_NOM_DECLENCHE * sizeof(char)));
                      pt_buff +=  sizeof(char) * L_NOM_DECLENCHE;
                      pt++;
                    }
                 }
                      break;
           case T_ENCODE:
               {
                   ts_v_t_encode *pt;
                   int i;

                   pt = (ts_v_t_encode *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->type, (2 * sizeof(char)));
                      pt_buff += sizeof(char) * 2;
                      memcpy(pt_buff, &(pt->polar), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, pt->declenche, 
                                   (L_NOM_DECLENCHE * sizeof(char)));
                      pt_buff += sizeof(char) *  L_NOM_DECLENCHE;
                      memcpy(pt_buff, &(pt->nbsaut), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, &(pt->nbmax), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, pt->comment, (L_COMMENTAIRE *
                                                           sizeof(char)));
                      pt_buff += sizeof(char) * L_COMMENTAIRE;
                      pt++;
                    }
                 }
                      break;
           case F_COMMON:
               {
                   ts_v_common *pt;
                   int i;

                   pt = (ts_v_common *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->nom_diag, 
                                   (L_NOM_PRODUCTEUR * sizeof(char)));
                      pt_buff +=  sizeof(char) * L_NOM_PRODUCTEUR;
                      memcpy(pt_buff, pt->nom_objet, 
                                   (L_NOM_OBJET * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_OBJET;
                      memcpy(pt_buff, pt->nom_param, 
                                   (L_NOM_PARAM * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_PARAM;
                      memcpy(pt_buff, pt->colonne, 
                                   (L_NOM_COLONNE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_COLONNE;
                      memcpy(pt_buff, &(pt->indice1), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, &(pt->indice2), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, &(pt->format), L_FORMAT);
                      pt_buff += sizeof(char) * L_FORMAT;
                      pt++;
                    }
                 }
                      break;
           case F_CHRONO:
               {
                   ts_v_chrono *pt;
                   int i;

                   pt = (ts_v_chrono *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->valid, (2 * sizeof(char)));
                      pt_buff += sizeof(char) *  2;
                      memcpy(pt_buff, pt->repere, 
                                   (L_NOM_REPERE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_REPERE;
                      memcpy(pt_buff, pt->declenche, 
                                   (L_NOM_DECLENCHE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_DECLENCHE;
                      memcpy(pt_buff, pt->typedecl, (2 * sizeof(char)));
                      pt_buff += sizeof(char) *  2;
                      memcpy(pt_buff, &(pt->decalage), sizeof(float));
                      pt_buff += sizeof(float);
                      memcpy(pt_buff, pt->ref, (9 * sizeof(char)));
                      pt_buff += sizeof(char) * 9 ;
                      memcpy(pt_buff, &(pt->duree), sizeof(float));
                      pt_buff += sizeof(float);
                      memcpy(pt_buff, pt->comment, (L_COMMENTAIRE *
                                                           sizeof(char)));
                      pt_buff += sizeof(char) * L_COMMENTAIRE;
                      pt++;
                   }
                }
                      break;
           case T_DECLENC:
               {
                   ts_v_declenc *pt;
                   int i;

                   pt = (ts_v_declenc *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->nom, 
                                   (L_NOM_DECLENCHE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_DECLENCHE;
                      memcpy(pt_buff, &(pt->temps), sizeof(float));
                      pt_buff += sizeof(float);
                      pt++;
                   }
                  }
                      break;
           case L_DIAG:
               {
                   ts_v_listdiag *pt;
                   int i;

                   pt = (ts_v_listdiag *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->nomdiag,(L_NOM_OBJET * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_OBJET ;
                      pt++;
                   }
                  }
                      break;
           case T_DECLENCHE:
               {
                   ts_v_declenche *pt;
                   int i;

                   pt = (ts_v_declenche *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->declenche, 
                                   (L_NOM_DECLENCHE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_DECLENCHE;
                      pt++;
                   }
                  }
                      break;
           case TEXTE:
               {
                   ts_v_texte *pt;
                   int i;

                   pt = (ts_v_texte *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->texte, (L_TEXTE * sizeof(char)));
                      pt_buff += sizeof(char) * L_TEXTE;
                      pt++;
                   }
                  }
                      break;
           case F_TOPMSDIV:
               {
                   ts_v_topmsdiv *pt;
                   int i;

                   pt = (ts_v_topmsdiv *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->type), sizeof(short));
                      pt_buff +=  sizeof(short);
		      memcpy(pt_buff, &(pt->autorisation), sizeof(short));
                      pt_buff +=  sizeof(short);
                      memcpy(pt_buff, pt->topms, (L_NOM_DECLENCHE * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_DECLENCHE;
                      memcpy(pt_buff, &(pt->duree), sizeof(short));
                      pt_buff +=  sizeof(short);
                      memcpy(pt_buff, &(pt->sens), sizeof(short));
                      pt_buff += sizeof(short);
                      pt++;
                   }
                  }
                      break;
           case GRAPHE:
               {
                   ts_v_graphe *pt;
                   int i;

                   pt = (ts_v_graphe *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->numero_page), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, &(pt->numero_graphe), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, pt->titre, (L_TITRE * sizeof(char)));
                      pt_buff += sizeof(char) * L_TITRE;
                      memcpy(pt_buff, &(pt->xmin), sizeof(float));
                      pt_buff += sizeof(float);
                      memcpy(pt_buff, &(pt->xmax), sizeof(float));
                      pt_buff += sizeof(float);
                      memcpy(pt_buff, &(pt->ymin), sizeof(float));
                      pt_buff += sizeof(float);
                      memcpy(pt_buff, &(pt->ymax), sizeof(float));
                      pt_buff += sizeof(float);
                      pt++;
                   }
                  }
                      break;
           case SIGNAL:
               {
                   ts_v_signal *pt;
                   int i;

                   pt = (ts_v_signal *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->numero_page), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, &(pt->numero_graphe), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, pt->signal, (L_NOM_OBJET * sizeof(char)));
                      pt_buff += sizeof(char) * L_NOM_OBJET;
                      memcpy(pt_buff, &(pt->indice), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, pt->couleur, 
                                     (L_COULEUR_SIGNAL * sizeof(char)));
                      pt_buff += sizeof(char) * L_COULEUR_SIGNAL;
                      memcpy(pt_buff, &(pt->tri), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, pt->valid, (2 * sizeof(char)));
                      pt_buff += sizeof(char) * 2;
                      pt++;
                   }
                  }
                      break;

           case FLOAT_CHAR64:
               {
                   ts_v_float4_char64 *pt;
                   int i;

                   pt = (ts_v_float4_char64 *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->float4), sizeof(float));
                      pt_buff += sizeof(float);
                      memcpy(pt_buff, pt->comment, 
                                           (65 * sizeof(char)));
                      pt_buff += sizeof(char) * 65;
                      pt++;
                    }
                 }
                      break;

           case INT2_CHAR64:
               {
                   ts_v_int2_char64 *pt;
                   int i;

                   pt = (ts_v_int2_char64 *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, &(pt->int2), sizeof(short));
                      pt_buff += sizeof(short);
                      memcpy(pt_buff, pt->comment, 
                                           (65 * sizeof(char)));
                      pt_buff += sizeof(char) * 65;
                      pt++;
                    }
                 }
                      break;

           case F_ACHRONO:
               {
                   ts_v_achrono *pt;
                   int i;

                   pt = (ts_v_achrono *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
                      memcpy(pt_buff, pt->code, (2 * sizeof(char)));
                      pt_buff += 2 * sizeof(char);
                      memcpy(pt_buff, pt->declenche, (13 * sizeof(char)));
                      pt_buff += 13 * sizeof(char);
                      memcpy(pt_buff, &(pt->decalage), sizeof(float));
                      pt_buff += sizeof(float);
                      memcpy(pt_buff, &(pt->duree), sizeof(float));
                      pt_buff += sizeof(float);
                      memcpy(pt_buff, pt->comment, 
                                           (33 * sizeof(char)));
                      pt_buff += sizeof(char) * 33;
                      pt++;
                    }
                 }
                      break;
	   case F_DESCRIPTEUR:
               {
                   ts_v_descripteur *pt;
                   int i;

                   pt = (ts_v_descripteur *)buffer;
                   for (i = 0 ; i < nb_val; i++) {
		      memcpy(pt_buff, &(pt->num_choc), sizeof(int));
                      pt_buff += sizeof(int) ;
		      memcpy(pt_buff, pt->nom_diag, (13 * sizeof(char)));
                      pt_buff += 13 * sizeof(char);
		      memcpy(pt_buff, pt->donnee_brute, (13 * sizeof(char)));
                      pt_buff += 13 * sizeof(char);
		      memcpy(pt_buff, &(pt->indiceb), sizeof(short));
                      pt_buff += sizeof(short);
		      memcpy(pt_buff, pt->nom_trait, (13 * sizeof(char)));
                      pt_buff += 13 * sizeof(char);
		      memcpy(pt_buff, pt->donnee_traitee, (13 * sizeof(char)));
                      pt_buff += 13 * sizeof(char);
		      memcpy(pt_buff, &(pt->indicet), sizeof(short));
                      pt_buff += sizeof(short);
		      pt++;
                   }
                 }
                      break;

           default :
                      return(-567);
                 break;
         } /*  end switch */

      } else  /* Anciens chocs */
      {
        if(flag_mem)
           Memcpy (*buff, buffer, (size_t) *nrep * typfor(*fmt));
         else
           Memcpy (buff, buffer, (size_t) *nrep * typfor(*fmt));
       }
   }  else {
      buff='\0'; 
  }  /* End CR = 0 */

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
/****
*****
****/
Longint FAR_PASCAL
TSdescObjet (	Longint numchoc,
		char *nomdiag,
		char *nomobj,
		char **buff,
		char **cmt)

{
  Longint CR;

  int NumSocket;           /* descripteur de la socket de communication */
  short int CodeFonc;      /* code de la fonction TSLib appelee         */
  Longint Resultat;        /* compte-rendu d'execution du client        */

  char bufparam[taille_short+taille_long+TAILLE_NOM_DIAGNOSTIC+L_NOM_OBJET+TAILLE_TYPE_OBJET];
  char *buffer;
  Longint lg;

  if ((numchoc < NUM_CHOC_BASE) && (numchoc > NUM_CHOC_TEST) )
    return numero_choc_invalide;
  if (Strlen (nomdiag) == 0)
    return nom_diagnostic_invalide;
  if (Strlen (nomobj) == 0)
    return nom_objet_invalide;

  if(compress_on)
    CodeFonc = fonc_tsdescobjet;
  else
    CodeFonc = -(fonc_tsdescobjet - MAX_FUNCT_NUMBER);

  /* constitution du buffer des parametres */

  memcpy(bufparam, (char *)&CodeFonc, taille_short);
  memcpy(&bufparam[2], (char *)&numchoc, taille_long);
  strcpy(&bufparam[6], nomdiag);
  strcpy(&bufparam[6+TAILLE_NOM_DIAGNOSTIC], nomobj);
  
  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction et des parametres */

  if ((Resultat = Emission (NumSocket, bufparam, taille_short + taille_long +
     TAILLE_NOM_DIAGNOSTIC+L_NOM_OBJET, p_codefonc)) == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception (NumSocket, (char *) &lg, taille_long, p_entrees))
	  == erreur_reception)
	return Resultat;

      if ((Resultat = Reception_Chaine (NumSocket, &buffer,p_entrees))
	  == erreur_reception)
	return Resultat;

      if ( (*buff =(char *) malloc((size_t) lg)) == NULL)
        return(-50);

      Memcpy (*buff, buffer, (size_t) lg);
      free(buffer);

      if ((Resultat = Reception_Chaine (NumSocket, cmt, p_entrees))
	  == erreur_reception)
	return Resultat;
    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
/*****************************************************************************/

Longint FAR_PASCAL
TStele ( char *NomDiag,
         Longint al,
         Longint val,
         char **pt_val,
         Longint *lg_data  )

{

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee
                */
  Longint Resultat, CR = -1;

  char *buffer;
  int lg;

  if (Strlen (NomDiag) == 0)
    return nom_diagnostic_invalide;
  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tstele;
  else
    CodeFonc = -(fonc_tstele - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      == erreur_emission)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDiag, TAILLE_NOM_DIAGNOSTIC, p_nomdiag ))
      == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &al, taille_long, p_numchoc))
      == erreur_emission)
    return Resultat;
                                                                                        
  if ((Resultat = Emission (NumSocket, (char *) &val, taille_long, p_numchoc))
      == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {
     if ((Resultat = Reception (NumSocket, (char *) &lg, taille_long,p_entrees))
          == erreur_reception)
        return Resultat;

     *lg_data = lg;
                    
     if ((Resultat = Reception_Chaine (NumSocket, &buffer,p_entrees))
          == erreur_reception)
        return Resultat;

      *pt_val = buffer;
    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
                      
/************/
Longint FAR_PASCAL
TSChargerObjet (Longint numchoc,
		char *ensCible,
		char *ensSource,
		char *prodCible, 
		char *prodSource,
		char *objSource,
		char *objCible, 
		Longint remp,
                Longint dom)

{
  Longint CR = 0;

  int NumSocket;           /* descripteur de la socket de communication */
  short int CodeFonc;      /* code de la fonction TSLib appelee         */
  Longint Resultat;        /* compte-rendu d'execution du client        */

  char bufparam[taille_short + 3*taille_long + (6 * 13)];

  if (numchoc < 0)
    return numero_choc_invalide;


  if(compress_on)
    CodeFonc = fonc_tscharger;
  else
    CodeFonc = -(fonc_tscharger - MAX_FUNCT_NUMBER);

  /* constitution du buffer des parametres */

  memcpy(bufparam, (char *)&CodeFonc, taille_short);
  memcpy(&bufparam[2], (char *)&numchoc, taille_long);
  strcpy(&bufparam[6], ensCible);
  strcpy(&bufparam[6+13], ensSource);
  strcpy(&bufparam[6 + 13 + 13], prodCible);
  strcpy(&bufparam[6 + 13 + 13 + 13], prodSource);
  strcpy(&bufparam[6 + 13 + 13 + 13 + 13], objSource);
  strcpy(&bufparam[6 + 13 + 13 + 13 + 13 + 13], objCible);
  memcpy(&bufparam[6+13+13+13+13+13+13], (char *)&remp, taille_long);
  memcpy(&bufparam[6+13+13+13+13+13+13+4], (char *)&dom, taille_long);
  
  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction et des parametres */

  if ((Resultat = Emission (NumSocket, bufparam,
          (taille_short + 3*taille_long + (6 * 13)), p_codefonc))
      == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  Fin_Communication (NumSocket);

  return CR;

}


/*****************************************************************************/

Longint FAR_PASCAL
TSDescDon_choc ( char *NomDon,
         Longint num_choc,
         Longint occur,
         ts_donnee **pt_val )

{

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee
                */
  Longint Resultat, CR = -1;

  char *buffer;

  if (Strlen (NomDon) == 0)
    return nom_diagnostic_invalide;
  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsdescdon_choc;
  else
    CodeFonc = -(fonc_tsdescdon_choc - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      == erreur_emission)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdiag ))
      == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &num_choc, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &occur, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if (CR == ok)
    {
     if ((Resultat = Reception_Chaine (NumSocket, &buffer,p_entrees))
          == erreur_reception)
        return Resultat;

      *pt_val = (ts_donnee *) buffer;
    }
  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

/*****************************************************************************/

Longint FAR_PASCAL
TSPrepareTele ( char *NomDiag)

{

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee */
  Longint Resultat, CR = -1;


  if (Strlen (NomDiag) == 0)
    return nom_diagnostic_invalide;
  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tspreparetele;
  else
    CodeFonc = -(fonc_tspreparetele - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short,
                         p_codefonc)) == erreur_emission)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDiag, TAILLE_NOM_DIAGNOSTIC, 
                        p_nomdiag )) == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

Longint FAR_PASCAL
TSPtele ( char *NomDiag, int s_tele, char *buff, int nb)

{

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee
                */
  Longint Resultat, CR = -1;


  if (Strlen (NomDiag) == 0)
    return nom_diagnostic_invalide;
  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsptele;
  else
    CodeFonc = -(fonc_tsptele - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short,
                         p_codefonc)) == erreur_emission)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDiag, TAILLE_NOM_DIAGNOSTIC, 
                                          p_nomdiag)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &s_tele, sizeof(int),
                                          p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, buff, (TO_COMMON+1), 
                                    p_nomdiag)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &nb, sizeof(int),
                                    p_numchoc)) == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}


                      
/*****************************************************************************/

Longint FAR_PASCAL
TSArchive (char *NomDiag)

{

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee */
  Longint Resultat, CR = -1;


  if (Strlen (NomDiag) == 0)
    return nom_diagnostic_invalide;
  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsarchive;
  else
    CodeFonc = -(fonc_tsarchive - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, 
                     p_codefonc)) == erreur_emission)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDiag, TAILLE_NOM_DIAGNOSTIC, 
                    p_nomdiag )) == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
/*****************************************************************************/

Longint FAR_PASCAL
TSEnregistrable (char *NomDiag, int val)

{

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee */
  Longint Resultat, CR = -1;


  if (Strlen (NomDiag) == 0)
    return nom_diagnostic_invalide;
  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsenregistrable;
  else
    CodeFonc = -(fonc_tsenregistrable - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short,
            p_codefonc)) == erreur_emission)
   return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, NomDiag, TAILLE_NOM_DIAGNOSTIC,
               p_nomdiag )) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &val, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;


  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}

/******** YB YB *****/

Longint FAR_PASCAL
TSrqEtat ( char *machine,
           char **pt_val )

{

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee */
  Longint lg, Resultat;

  char *buffer;

  if (Strlen (machine) == 0)
    return nom_diagnostic_invalide;
  /* debut de communication */

   if (!strcmp(machine,"rhea")) {
      if ((Resultat = Debut_Communication (&NumSocket, 0)) != ok)
         return Resultat;
   }
   else if(!strcmp(machine,"rigel")) {
      if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
        return Resultat;
   }
   else
      if ((Resultat = Debut_Communication (&NumSocket, 2)) != ok)
        return Resultat;
    /*  return nom_diagnostic_invalide;  */

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsrqetat;
  else
    CodeFonc = -(fonc_tsrqetat - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &lg, taille_long, p_entrees))
     == erreur_reception)
   return Resultat;

  if ((Resultat = Reception_Chaine (NumSocket, &buffer,p_entrees))
     == erreur_reception)
     return Resultat;

   *pt_val = buffer;
  
  /* fin de communication */

  Fin_Communication (NumSocket);

  return 0 ;
}

/*****************************************************************************/

Longint FAR_PASCAL
TSWfile (Longint num_choc, 
         char *NomDon,
         char *NomFic)
{

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee
                */
  Longint Resultat, CR = -1;

  FILE *fp = NULL ;
  int fd, nBytesRead = 0;
  char szBuffer[MTU_SPECIAL];
  struct stat buf;
  int taille_fic, leftToSend;

  if (num_choc < NUM_CHOC_DEC && num_choc > NUM_CHOC_TEST)
    return numero_choc_invalide;
  if (Strlen (NomDon) == 0)
    return nom_donnee_invalide;
  if (Strlen (NomFic) == 0)
    return nom_fichier_invalide;
  
 /*printf("Av1 %d %s %s\n",num_choc,NomDon,NomFic);*/
  if (! (fp = fopen(NomFic, "rb")))
    return erreur_ouverture_fic;

  fd = fileno(fp);
  
  if (fstat(fd, &buf))
    return erreur_ouverture_fic;  
  else
    taille_fic = buf.st_size;

  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tswfile;
  else
    CodeFonc = -(fonc_tswfile - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      == erreur_emission)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, (char *) &num_choc, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdiag ))
      == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &taille_fic, taille_long,
                                            p_numchoc)) == erreur_emission)
  return Resultat;

  leftToSend = taille_fic;
  while (leftToSend > 0){
     nBytesRead = read(fd, szBuffer, leftToSend < MTU_SPECIAL ? leftToSend : MTU_SPECIAL);
     if ( nBytesRead > 0) {
       if ((Resultat = Emission (NumSocket, szBuffer, nBytesRead, p_nomdiag ))
           == erreur_emission)
       return Resultat;
     } else
       return erreur_emission;
     leftToSend -= nBytesRead;
  }

  fclose(fp);

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
/*
 ****
 ****
 */

Longint FAR_PASCAL
TSRfile (Longint num_choc, 
         char *NomDon,
         char *NomFic)
{

  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee
                */
  Longint Resultat, CR = -1;

  FILE *fp = NULL ;
  int fd, nBytesRead = 0, Size, data_recv = 0;
  char szBuffer[MTU_SPECIAL];

  if (num_choc < NUM_CHOC_DEC && num_choc > NUM_CHOC_TEST)
    return numero_choc_invalide;
  if (Strlen (NomDon) == 0)
    return nom_donnee_invalide;
  if (Strlen (NomFic) == 0)
    return nom_fichier_invalide;
  
  if (! (fp = fopen(NomFic, "w")))
    return erreur_ouverture_fic;

  fd = fileno(fp);
  
  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsrfile;
  else
    CodeFonc = -(fonc_tsrfile - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      == erreur_emission)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, (char *) &num_choc, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdiag ))
      == erreur_emission)
    return Resultat;


  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &Size, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if(CR == 0) {
    while( Size > 0 ) {
       memset(szBuffer, 0, MTU_SPECIAL);
       nBytesRead = ReceptionYB(NumSocket, szBuffer, Size > MTU_SPECIAL ? MTU_SPECIAL : Size);
       write(fd,szBuffer,nBytesRead);
       Size -= nBytesRead;
    }

   close(fd);
  }
   else
     unlink(NomFic);

  /* fin de communication */
  Fin_Communication (NumSocket);
  return CR;

}

/*
 ****
 ****
 */

Longint FAR_PASCAL
TSListOccTrait  (Longint num_choc, 
         char *NomTrait,
         int *nbre,
         char **data)
{

  int NumSocket;                /* descripteur de la socket de communication */

  short int CodeFonc;           /* code de la fonction TSLib appelee */
  Longint Resultat, CR = -1;


  if (num_choc < 0)
    return numero_choc_invalide;
  if (Strlen (NomTrait) == 0)
    return nom_donnee_invalide;
  
  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tslistocctrait;
  else
    CodeFonc = -(fonc_tslistocctrait - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short, p_codefonc))
      == erreur_emission)
    return Resultat;

  /* emission des parametres */

  if ((Resultat = Emission (NumSocket, (char *) &num_choc, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, NomTrait, TAILLE_NOM_TRAITEMENT, p_nomdiag ))
      == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if(CR == 0) {

      if ((Resultat = Reception (NumSocket, (char *) nbre, taille_long, p_entrees))
	  == erreur_reception)
	return Resultat;

      if ((Resultat = Reception_Chaine (NumSocket, data, p_entrees))
	  == erreur_reception)
	return Resultat;
  }

  /* fin de communication */
  Fin_Communication (NumSocket);
  return CR;

}

Longint
TSDateDuChoc ( Longint num_choc,
               Longint date,
               Longint heure )

{
  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee */
  Longint Resultat, CR = -1;

  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

  if(compress_on)
    CodeFonc = fonc_tsdateduchoc;
  else
    CodeFonc = -(fonc_tsdateduchoc - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short,
                    p_codefonc)) == erreur_emission)
    return Resultat;

  /* emission des parametres */

   if ((Resultat = Emission (NumSocket, (char *) &num_choc, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &date, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &heure, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  /* fin de communication */

  Fin_Communication (NumSocket);

  return CR;

}
                      
Longint
TSRDC ( char * nom_sig,
        char * date_deb,
        char * heure_deb,
        char * date_fin,
        char * heure_fin,
        int numchoc,
        float ** t,
        float ** y,
        int * nb_s,
        int * tm )

{
  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee */
  Longint Resultat, CR = -1;
  int lc;
  char *Tabc;


  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

 /*  compress_on = 1; */
  if(compress_on)
    CodeFonc = fonc_tsrdc;
  else
    CodeFonc = -(fonc_tsrdc - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short,
                    p_codefonc)) == erreur_emission)
    return Resultat;

  /* emission des parametres */

   if ((Resultat = Emission (NumSocket, nom_sig, L_NOM_OBJET,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, date_deb, TAILLE_DATE_DC,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, heure_deb, TAILLE_DATE_DC,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, date_fin, TAILLE_DATE_DC,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, heure_fin, TAILLE_DATE_DC,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &numchoc, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

 if (CR >= 0) {
  if ((Resultat = Reception (NumSocket, (char *) nb_s, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if ((Resultat = Reception (NumSocket, (char *) tm, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

   *t = (float *) malloc( *tm);
   *y = (float *) malloc( *tm);

  if (*tm > 400000) {
   if ((Resultat = Reception (NumSocket, (char *) &lc, taille_long, p_cr))
      == erreur_reception)
    return Resultat;
   Tabc = (char *) malloc(lc);
   if ((Resultat = Reception (NumSocket,Tabc, lc, p_cr)) != ok) {
      free(Tabc);
      return Resultat;
   }
     lzrw1_decompress (Tabc, lc, *t); 
     free(Tabc);

   if ((Resultat = Reception (NumSocket, (char *) &lc, taille_long, p_cr))
      == erreur_reception)
    return Resultat;
   Tabc = (char *) malloc(lc);
   if ((Resultat = Reception (NumSocket,Tabc, lc, p_cr)) != ok) {
      free(Tabc);
      return Resultat;
   }
     lzrw1_decompress (Tabc, lc, *y); 
     free(Tabc);

  } else {
  if ((Resultat = Reception (NumSocket, (char *) *t, *tm, p_cr))
      == erreur_reception)
    return Resultat;

  if ((Resultat = Reception (NumSocket, (char *) *y, *tm, p_cr))
      == erreur_reception)
    return Resultat;
  }

  } /* fin CR >= 0 */

  Fin_Communication (NumSocket);

  return CR;

}

Longint
TSLTR ( char * nom_sig,
        char * date_deb,
        char * heure_deb,
        char * date_fin,
        char * heure_fin,
        int numchoc,
        float ** t,
        float ** y,
        int * nb_s,
        int * tm,
        int * num_choc,
        int * phase,
        int * der_trame )

{
  int NumSocket;                /* descripteur de la socket de communication */
  short int CodeFonc;           /* code de la fonction TSLib appelee */
  Longint Resultat, CR = -1;
  int lc;
  char *Tabc;


  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;

  /* emission du code de la fonction */

 /*  compress_on = 1; */
  if(compress_on)
    CodeFonc = fonc_tsltr;
  else
    CodeFonc = -(fonc_tsltr - MAX_FUNCT_NUMBER);
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short,
                    p_codefonc)) == erreur_emission)
    return Resultat;

  /* emission des parametres */

   if ((Resultat = Emission (NumSocket, nom_sig, L_NOM_OBJET,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, date_deb, TAILLE_DATE_DC,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, heure_deb, TAILLE_DATE_DC,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, date_fin, TAILLE_DATE_DC,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, heure_fin, TAILLE_DATE_DC,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  if ((Resultat = Emission (NumSocket, (char *) &numchoc, taille_long,
                                            p_numchoc)) == erreur_emission)
    return Resultat;

  /* fin d'emission */

#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif

  /* reception des parametres */

  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

 if (CR >= 0 || CR == -17) {
  if ((Resultat = Reception (NumSocket, (char *) nb_s, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  if ((Resultat = Reception (NumSocket, (char *) tm, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

   *t = (float *) malloc( *tm);
   *y = (float *) malloc( *tm);

  if (*tm > 400000) {
   if ((Resultat = Reception (NumSocket, (char *) &lc, taille_long, p_cr))
      == erreur_reception)
    return Resultat;
   Tabc = (char *) malloc(lc);
   if ((Resultat = Reception (NumSocket,Tabc, lc, p_cr)) != ok) {
      free(Tabc);
      return Resultat;
   }
     lzrw1_decompress (Tabc, lc, *t); 
     free(Tabc);

   if ((Resultat = Reception (NumSocket, (char *) &lc, taille_long, p_cr))
      == erreur_reception)
    return Resultat;
   Tabc = (char *) malloc(lc);
   if ((Resultat = Reception (NumSocket,Tabc, lc, p_cr)) != ok) {
      free(Tabc);
      return Resultat;
   }
     lzrw1_decompress (Tabc, lc, *y); 
     free(Tabc);

  } else {
  if ((Resultat = Reception (NumSocket, (char *) *t, *tm, p_cr))
      == erreur_reception)
    return Resultat;

  if ((Resultat = Reception (NumSocket, (char *) *y, *tm, p_cr))
      == erreur_reception)
    return Resultat;
  }
  if ((Resultat = Reception (NumSocket, (char *) num_choc, taille_long, p_cr))
      == erreur_reception)
    return Resultat;
  if ((Resultat = Reception (NumSocket, (char *) phase, taille_long, p_cr))
      == erreur_reception)
    return Resultat;
  if ((Resultat = Reception (NumSocket, (char *) der_trame, taille_long, p_cr))
      == erreur_reception)
    return Resultat;

  } /* fin CR >= 0 */

  Fin_Communication (NumSocket);

  return CR;

}

int
TSExist_gen (char *NomDon,
         pS_Entree Entrees,
         Longint *NbCoord,
         Longint *NumVer,
         Longint *Certif,
         char *Date,
         char *Heure,
         char *NomGen,
         int *indice
      /**   ,int *typdon **/ )

{
  Longint CR;
  Longint CoordNb;             /* longueur en octets du tableau NbCoord */
  Longint CertifNb;            /* longueur en octets du tableau Certif  */
  Longint code_param;

  int NumSocket;               /* descripteur de la socket de communication */

  short int CodeFonc;          /* code de la fonction TSLib appelee   */
  Longint Resultat;            /* compte-rendu d'execution du client  */

  /* test des pointeurs de chaines */

  code_param = ok;

  if (NomDon == NULL)
    code_param = p_nomdon;
  if (Date == NULL)
    code_param = p_date;
  if (Heure == NULL)
    code_param = p_heure;
  if (Entrees->union_var.lval < 0)
    code_param = p_numchoc;

   if (code_param != ok)
    return (Gestion_Erreur (erreur_chaine_vide, code_param));

  /* test des pointeurs de tableaux */
 if (NbCoord == NULL)
    code_param = p_nbcoord;
  if (Certif == NULL)
    code_param = p_certif;

  if (code_param != ok)
    return (Gestion_Erreur (erreur_tableau_vide, code_param));

  if(compress_on)
    CodeFonc = fonc_tsexist_gen;
  else
    CodeFonc = -(fonc_tsexist_gen - MAX_FUNCT_NUMBER);

  /* debut de communication */

  if ((Resultat = Debut_Communication (&NumSocket, 1)) != ok)
    return Resultat;
 /* emission du code de la fonction et des parametres */
  if ((Resultat = Emission (NumSocket, (char *) &CodeFonc, taille_short,
                                                        p_codefonc)) != ok)
    return Resultat;

  if ((Resultat = Emission (NumSocket, NomDon, TAILLE_NOM_DONNEE, p_nomdon))
                                                                       != ok)
    return Resultat;

  if ((Resultat = Emission_Entrees (NumSocket, Entrees, p_entrees))
      != ok)
    return Resultat;

  /* fin d'emission */
#if ((client!=PC) && (client !=MAC))
  if ((Resultat = Fin_Emission (NumSocket))
      == erreur_fin_emission)
    return Resultat;
#endif
 /* reception des parametres */
  if ((Resultat = Reception (NumSocket, (char *) &CR, taille_long, p_cr)) != ok)
    return Resultat;

  if (CR == ok)
    {
      if ((Resultat = Reception (NumSocket, (char *) &CoordNb, taille_long,
                                                         p_nbcoord)) != ok)
        return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) NbCoord, CoordNb,
                                                          p_nbcoord)) != ok)
        return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) NumVer, taille_long,
                                                          p_numver)) != ok)
        return Resultat;
      if ((Resultat = Reception (NumSocket, (char *) &CertifNb, taille_long,
                                                          p_certif)) != ok)
        return Resultat;
       if(CertifNb > 256) {
          int i;
          Longint *ptmp_certif=(Longint *)calloc(sizeof(Longint),CertifNb);
          if ((Resultat = Reception (NumSocket, (char *) ptmp_certif, CertifNb,
                          p_certif)) != ok)
            return Resultat;
          for(i=0; i < 64 ; i++) /* Tableau certif Bd =64 max */
            Certif[i]= ptmp_certif[i];
          }
          else
           if ((Resultat = Reception (NumSocket, (char *) Certif, CertifNb,
             p_certif)) != ok)
           return Resultat;

      if ((Resultat = Reception (NumSocket, Date, TAILLE_DATE, p_date)) != ok)
        return Resultat;

      if ((Resultat = Reception (NumSocket, Heure,TAILLE_HEURE,p_heure)) != ok)
        return Resultat;

    }
      if ((Resultat = Reception (NumSocket, NomGen, TAILLE_NOM_DONNEE,
                                                           p_heure)) != ok)
        return Resultat;

      if ((Resultat = Reception (NumSocket, (char *) indice, taille_long,
                                                          p_numver)) != ok)
        return Resultat;

/**      if ((Resultat = Reception (NumSocket, (char *) typdon, taille_long,
                                                          p_numver)) != ok)
        return Resultat;
**/

 Fin_Communication (NumSocket);
 return CR;

}
