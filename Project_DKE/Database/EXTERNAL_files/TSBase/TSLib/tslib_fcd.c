
/*****************************************************************************
		 	.....   "tslib_fcd.c"    .....
		..... Interface C -- Fortran  pour TSLib client .....
			..... Version double .....
			..... YB  Mars 1994 .....
		.....       Life will never be the same      .....
 *****************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include "tsconf.h"
#include "tsdef.h"
#include "tstype.h"
char tslib_reel = 'd';
#define PREPASIZE	8
#define LHEURE		9
#define LDATE		11

/*----------------------------------------------------------------------------
                        TSSigDeclenche

  But : fonction demandant au serveur de lui renvoyer les valeurs d'un signal
        brut pour une occurrence d'une declenche donnee

  Arguments :
        NomDon    : nom de la donnee
        NumChoc   : numero de choc
        NomDec    : nom d'une declenche
        Occur     : occurrence d'une declenche
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre de valeurs trouvees
        T         : tableau des valeurs des temps
        Y         : tableau des valeurs des mesures

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tssigdeclenche_ (NomDon, NumChoc, NomDec, Occur, NbMax, Extract, Unite,
		 NumVer, Date, Heure, NbMes, MaxReel, T, Y,
		 lnd, lndc, lut, ldt, lhr, lT, lY)

     char *NomDon;
     Longint *NumChoc;
     char *NomDec;
     Longint *Occur;
     Longint *NbMax;
     Longint *Extract;
     char *Unite[];
     Longint *NumVer;
     char *Date;
     char *Heure;
     Longint *NbMes;
     Longint *MaxReel;
     char *T;
     char *Y;
     int lnd, lndc, lut, ldt, lhr, lT, lY;
{
  struct S_Unite *ptunite;
  pS_Unite ptu;
  int cr = 0;
  int len;
  char Ndt[TAILLE_NOM_DONNEE], Ndec[PREPASIZE + 1], *ptc;

  if ((cr = check_dateheure (ldt, lhr)) < 0)
    return cr;
  cclean (NomDon, Ndt, lnd);
  cclean (NomDec, Ndec, lndc);

  cr = TSSigDeclenche (Ndt, *NumChoc, Ndec, *Occur, *NbMax, *Extract,
		       &ptunite, NumVer, Date, Heure, NbMes, MaxReel, T, Y);
  if (!cr)
    {
      if (ptunite)
	{
	  ptc = (char *) Unite;
	  ptu = ptunite;
	  do
	    {
	      if (ptu->nom)
		{
		  len = strlen (ptu->nom);
		  memcpy (ptc, ptu->nom, ((lut >= len) ? len : lut));
		  if (lut > len)
		    memset (ptc + len * sizeof (char), ' ', (lut - len));
		}
	      ptc += lut * sizeof (char);
	    }
	  while (ptu = ptu->ps_suivant);
	  free (ptunite);
	}
      clean_dateheure (Date, ldt, Heure, lhr);
    }
  return (cr);
}

/*----------------------------------------------------------------------------
                        TSXtrDeclenche

  But : fonction demandant au serveur de lui renvoyer les valeurs d'un signal
        brut extrait d'un groupe pour une occurrence d'une declenche donnee

  Arguments :
        NomDon    : nom de la donnee
        NumChoc   : numero de choc
        Indices   : tableau des indices du signal dans le groupe
        NomDec    : nom d'une declenche
        Occur     : occurrence d'une declenche
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre de valeurs trouvees
        T         : tableau des valeurs des temps
        Y         : tableau des valeurs des mesures

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsxtrdeclenche_ (NomDon, NumChoc, Indices, NomDec, Occur, NbMax, Extract,
		 Unite, NumVer, Date, Heure, NbMes, MaxReel, T, Y,
		 lnd, lndc, lut, ldt, lhr, lT, lY)

     char *NomDon;
     Longint *NumChoc;
     Longint *Indices;
     char *NomDec;
     Longint *Occur;
     Longint *NbMax;
     Longint *Extract;
     char *Unite[];
     Longint *NumVer;
     char *Date;
     char *Heure;
     Longint *NbMes;
     Longint *MaxReel;
     char *T;
     char *Y;
     int lnd, lndc, lut, ldt, lhr, lT, lY;

{
  struct S_Unite *ptunite;
  pS_Unite ptu;
  int cr = 0;
  int len;
  char Ndt[TAILLE_NOM_DONNEE], Ndec[PREPASIZE + 1], *ptc;

  if ((cr = check_dateheure (ldt, lhr)) < 0)
    return cr;
  cclean (NomDon, Ndt, lnd);
  cclean (NomDec, Ndec, lndc);

  cr = TSXtrDeclenche (Ndt, *NumChoc, Indices, Ndec, *Occur, *NbMax,
	     *Extract, &ptunite, NumVer, Date, Heure, NbMes, MaxReel, T, Y);
  if (!cr)
    {
      if (ptunite)
	{
	  ptc = (char *) Unite;
	  ptu = ptunite;
	  do
	    {
	      if (ptu->nom)
		{
		  len = strlen (ptu->nom);
		  memcpy (ptc, ptu->nom, ((lut >= len) ? len : lut));
		  if (lut > len)
		    memset (ptc + len * sizeof (char), ' ', (lut - len));
		}
	      ptc += lut * sizeof (char);
	    }
	  while (ptu = ptu->ps_suivant);
	  free (ptunite);
	}
      clean_dateheure (Date, ldt, Heure, lhr);
    }
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSGrpDeclenche

  But : fonction demandant au serveur de lui renvoyer les valeurs d'un groupe
        de signaux bruts pour une occurrence d'une declenche donnee

  Arguments :
        NomDon    : nom de la donnee
        NumChoc   : numero de choc
        NomDec    : nom d'une declenche
        Occur     : occurrence d'une declenche
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre de valeurs trouvees
        T         : tableau des valeurs des temps
        Y         : tableau des valeurs des mesures

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsgrpdeclenche_ (NomDon, NumChoc, NomDec, Occur, NbMax, Extract, Unite,
		 NumVer, Date, Heure, NbMes, MaxReel, T, Y,
		 lnd, lndc, lut, ldt, lhr, lT, lY)

     char *NomDon;
     Longint *NumChoc;
     char *NomDec;
     Longint *Occur;
     Longint *NbMax;
     Longint *Extract;
     char *Unite[];
     Longint *NumVer;
     char *Date;
     char *Heure;
     Longint *NbMes;
     Longint *MaxReel;
     char *T;
     char *Y;
     int lnd, lndc, lut, ldt, lhr, lT, lY;

{
  struct S_Unite *ptunite;
  pS_Unite ptu;
  int cr = 0;
  int len;
  char Ndt[TAILLE_NOM_DONNEE], Ndec[PREPASIZE + 1], *ptc;

  if ((cr = check_dateheure (ldt, lhr)) < 0)
    return cr;
  cclean (NomDon, Ndt, lnd);
  cclean (NomDec, Ndec, lndc);

  cr = TSGrpDeclenche (Ndt, *NumChoc, Ndec, *Occur, *NbMax, *Extract,
		       &ptunite, NumVer, Date, Heure, NbMes, MaxReel, T, Y);
  if (!cr)
    {
      if (ptunite)
	{
	  ptc = (char *) Unite;
	  ptu = ptunite;
	  do
	    {
	      if (ptu->nom)
		{
		  len = strlen (ptu->nom);
		  memcpy (ptc, ptu->nom, ((lut >= len) ? len : lut));
		  if (lut > len)
		    memset (ptc + len * sizeof (char), ' ', (lut - len));
		}
	      ptc += lut * sizeof (char);
	    }
	  while (ptu = ptu->ps_suivant);
	  free (ptunite);
	}
      clean_dateheure (Date, ldt, Heure, lhr);
    }
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSDescTrait

  But : fonction demandant au serveur de lui envoyer la description d'un
        traitement

  Arguments :
        NomTrait  : nom du traitement
        NumVer    : numero de version

        DescTrait : description du traitement

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsdesctrait_ (NomTrait, NumVer, DescTrait, ldt)

     char *NomTrait;
     int *NumVer;
     char *DescTrait;
     int ldt;

{
  pS_DescTrait ptdt;
  pS_Donnee ptd;
  int cr = 0, offset = 0;
  int len;
  char *pt = DescTrait;
  char Ndt[TAILLE_NOM_TRAITEMENT];

  cclean (NomTrait, Ndt, ldt);
  cr = TSDescTrait (Ndt, *NumVer, &ptdt);

  if (!cr)
    {
      ptd = ptdt->ps_donnee;
      if (ptdt->nom)
	{
	  len = strlen (ptdt->nom);
	  memcpy (pt, ptdt->nom, len);
	  if (TAILLE_NOM_TRAITEMENT - 1 > len)
	    memset (pt + len , ' ', (TAILLE_NOM_TRAITEMENT - len));
	}
      offset += TAILLE_NOM_TRAITEMENT - 1;

      if (ptdt->commentaire)
	{
	  len = strlen (ptdt->commentaire);
	  memcpy (pt + offset, ptdt->commentaire, len);
	  if (TAILLE_COMMENTAIRE - 1 > len)
	    memset (pt + offset + len , ' ', (TAILLE_COMMENTAIRE - len));
	}
      offset += TAILLE_COMMENTAIRE - 1;

      if (ptdt->auteurs)
	{
	  len = strlen (ptdt->auteurs);
	  memcpy (pt + offset, ptdt->auteurs, len);
	  if (TAILLE_NOM_AUTEURS - 1 > len)
	    memset (pt + offset + len , ' ', (TAILLE_NOM_AUTEURS - len));
	}
      offset += TAILLE_NOM_AUTEURS - 1;

      if (ptdt->date)
	{
	  len = strlen (ptdt->date);
	  memcpy (pt + offset, ptdt->date, len);
	  if (TAILLE_DATE - 1 > len)
	    memset (pt + offset + len , ' ', (TAILLE_DATE - len));
	}
      offset += TAILLE_DATE - 1;

      memcpy (pt + offset, &(ptdt->type), sizeof (Longint));
      offset += sizeof (Longint);

      memcpy (pt + offset, &(ptdt->num_version), sizeof (short));
      offset += sizeof (short);

      if (ptdt->localisation)
	{

	  len = strlen (ptdt->localisation);
	  memcpy (pt + offset, ptdt->localisation, len);
	  if (TAILLE_NOM_LOCALISATION - 1 > len)
	    memset (pt + offset + len , ' ', (TAILLE_NOM_LOCALISATION - len));
	}
      offset += TAILLE_NOM_LOCALISATION - 1;

      if (ptdt->machine)
	{
	  len = strlen (ptdt->machine);
	  memcpy (pt + offset, ptdt->machine, len);
	  if (TAILLE_NOM_MACHINE - 1 > len)
	    memset (pt + offset + len , ' ', (TAILLE_NOM_MACHINE - len));
	}
      offset += TAILLE_NOM_MACHINE - 1;

      memcpy (pt + offset, &(ptdt->nb_donnees), sizeof (short));
      offset += sizeof (short);

      if (ptd)
	{
	  do
	    {
	      if (ptd->nom)
		{
		  len = strlen (ptd->nom);
		  memcpy (pt + offset, ptd->nom, len);
		  if (TAILLE_NOM_DONNEE - 1 > len)
		    memset (pt + offset + len , ' ', (TAILLE_NOM_DONNEE - len));
		}
	      offset += TAILLE_NOM_DONNEE - 1;
	    }
	  while (ptd = ptd->ps_suivant);
	  free (ptd);
	}
      free (ptdt);
    }
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSDescDiag

  But : fonction demandant au serveur de lui envoyer la description d'un
        diagnostic

  Arguments :
        NomDiag   : nom du diagnostic
        NumVer    : numero de version

        DescDiag  : description du diagnostic

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsdescdiag_ (NomDiag, NumVer, DescDiag, ldd)

     char *NomDiag;
     Longint *NumVer;
     char *DescDiag;
     int ldd;

{
  pS_DescDiag ptdd;
  pS_Donnee ptd;
  int cr = 0, offset = 0;
  char *pt = DescDiag;
  int len;
  char Ndt[TAILLE_NOM_DIAGNOSTIC];

  cclean (NomDiag, Ndt, ldd);
  cr = TSDescDiag (Ndt, *NumVer, &ptdd);
  if (!cr)
    {
      ptd = ptdd->ps_donnee;
      if (ptdd->nom)
	{
	  len = strlen (ptdd->nom);
	  memcpy (pt, ptdd->nom, len);
	  if (TAILLE_NOM_DIAGNOSTIC - 1 > len)
	    memset (pt + len , ' ', (TAILLE_NOM_DIAGNOSTIC - len));
	}
      offset += TAILLE_NOM_DIAGNOSTIC - 1;

      if (ptdd->commentaire)
	{
	  len = strlen (ptdd->commentaire);
	  memcpy (pt + offset, ptdd->commentaire, len);
	  if (TAILLE_COMMENTAIRE - 1 > len)
	    memset (pt + offset + len , ' ', (TAILLE_COMMENTAIRE - len));
	}
      offset += TAILLE_COMMENTAIRE - 1;

      if (ptdd->auteurs)
	{
	  len = strlen (ptdd->auteurs);
	  memcpy (pt + offset, ptdd->auteurs, len);
	  if (TAILLE_NOM_AUTEURS - 1 > len)
	    memset (pt + offset + len , ' ', (TAILLE_NOM_AUTEURS - len));
	}
      offset += TAILLE_NOM_AUTEURS - 1;

      if (ptdd->date)
	{
	  len = strlen (ptdd->date);
	  memcpy (pt + offset, ptdd->date, len);
	  if (TAILLE_DATE - 1 > len)
	    memset (pt + offset + len , ' ', (TAILLE_DATE - len));
	}
      offset += TAILLE_DATE - 1;

      memcpy (pt + offset, &(ptdd->type), sizeof (Longint));
      offset += sizeof (Longint);

      memcpy (pt + offset, &(ptdd->num_version), sizeof (short));
      offset += sizeof (short);

      memcpy (pt + offset, &(ptdd->nb_donnees), sizeof (short));
      offset += sizeof (short);
      if (ptd)
	{
	  do
	    {
	      if (ptd->nom)
		{
		  len = strlen (ptd->nom);
		  memcpy (pt + offset, ptd->nom, len);
		  if (TAILLE_NOM_DONNEE - 1 > len)
		    memset (pt + offset + len , ' ', (TAILLE_NOM_DONNEE - len));
		}
	      offset += TAILLE_NOM_DONNEE - 1;
	    }
	  while (ptd = ptd->ps_suivant);
	  free (ptd);
	}
      free (ptdd);
    }
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSDescDon

  But : fonction demandant au serveur de lui envoyer la description d'une
        donnee

  Arguments :
        NomDon    : nom de la donnee

        DescDon   : description de la donnee

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsdescdon_ (NomDon, DescDon, ldd)

     char *NomDon;
     char *DescDon;
     int ldd;

{
  pS_DescDon ptdd;
  pS_DescCoord ptd;
  int cr = 0, offset = 0;
  char *pt = DescDon;
  int len;
  char Ndt[TAILLE_NOM_DONNEE];

  cclean (NomDon, Ndt, ldd);
  cr = TSDescDon (Ndt, &ptdd);

  if (!cr)
    {
      ptd = ptdd->ps_coord;
      if (ptdd->nom)
	{
	  len = strlen (ptdd->nom);
	  memcpy (pt, ptdd->nom, len);
	  if (TAILLE_NOM_DONNEE - 1 > len)
	    memset (pt + len , ' ', (TAILLE_NOM_DONNEE - len));
	}
      offset += TAILLE_NOM_DONNEE - 1;

      if (ptdd->nom_producteur)
	{
	  len = strlen (ptdd->nom_producteur);
	  memcpy (pt + offset, ptdd->nom_producteur, len);
	  if (TAILLE_NOM_PRODUCTEUR - 1 > len)
	    memset (pt + offset + len , ' ', (TAILLE_NOM_PRODUCTEUR - len));
	}
      offset += TAILLE_NOM_PRODUCTEUR - 1;

      if (ptdd->commentaire)
	{
	  len = strlen (ptdd->commentaire);
	  memcpy (pt + offset, ptdd->commentaire, len);
	  if (TAILLE_COMMENTAIRE - 1 > len)
	    memset (pt + offset + len , ' ', (TAILLE_COMMENTAIRE - len));
	}
      offset += TAILLE_COMMENTAIRE - 1;

      offset += 2;

      memcpy (pt + offset, &(ptdd->type), sizeof (Longint));
      offset += sizeof (Longint);

      memcpy (pt + offset, &(ptdd->nb_comp), sizeof (short));
      offset += sizeof (short);

      memcpy (pt + offset, &(ptdd->nb_coord), sizeof (short));
      offset += sizeof (short);

      if (ptd)
	{
	  do
	    {
	      if (ptd->nom)
		{
		  len = strlen (ptd->nom);
		  memcpy (pt + offset, ptd->nom, len);
		  if (TAILLE_NOM_COORDONNEE - 1 > len)
		    memset (pt + offset + len , ' ', (TAILLE_NOM_COORDONNEE - len));
		}
	      offset += TAILLE_NOM_COORDONNEE - 1;
	      if (ptd->format)
		{
		  len = strlen (ptd->format);
		  memcpy (pt + offset, ptd->format, len);
		  if (TAILLE_FORMAT - 1 > len)
		    memset (pt + offset + len , ' ', (TAILLE_FORMAT - len));
		}
	      offset += TAILLE_FORMAT - 1;
	      if (ptd->unite)
		{
		  len = strlen (ptd->unite);
		  memcpy (pt + offset, ptd->unite, len);
		  if (TAILLE_NOM_UNITE - 1 > len)
		    memset (pt + offset + len , ' ', (TAILLE_NOM_UNITE - len));
		}
	      offset += TAILLE_NOM_UNITE - 1;
	      if (ptd->pretraitement)
		{
		  len = strlen (ptd->pretraitement);
		  memcpy (pt + offset, ptd->pretraitement, len);
		  if (TAILLE_PRETRAITEMENT - 1 > len)
		    memset (pt + offset + len , ' ', (TAILLE_PRETRAITEMENT - len));
		}
	      offset += TAILLE_PRETRAITEMENT - 1;
	    }
	  while (ptd = ptd->ps_suivant);
	  free (ptd);
	}
      free (ptdd);
    }
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSExist

  But : fonction demandant au serveur de verifier l'existence d'une donnee
        et de lui envoyer les informations la concernant

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement

        NbCoord   : tableau de valeurs des coordonnees ou nombre de mesures
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/


int
tsexist_ (NomDon, Entrees, NbCoord, NumVer, Certif, Date, Heure,
	  lnd, ldt, lhr)

     char *NomDon;
     Longint *Entrees;
     Longint *NbCoord;
     Longint *NumVer;
     Longint *Certif;
     char *Heure, *Date;
     int lnd, ldt, lhr;
{
  pS_Entree Entreesc;
  int cr = 0, i;
  char Ndt[TAILLE_NOM_DONNEE];

  if ((ldt < LDATE) || (lhr < LHEURE))
    return (-11);

  cclean (NomDon, Ndt, lnd);

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;
  Entreesc->ps_suivant = NULL;

  cr = TSExist (Ndt, Entreesc, NbCoord, NumVer, Certif, Date, Heure);

  clean_dateheure (Date, ldt, Heure, lhr);

  free (Entreesc);
  return (cr);

}

/*----------------------------------------------------------------------------

                        TSWrite

  But : fonction envoyant au serveur la liste des parametres a ecrire en
        base de donnees et dans les fichiers de mesure

  Arguments :
        NomTrait  : nom du traitement
        Entrees   : liste des entrees du traitement
        Longueurs : longueurs des coordonnees
        Certif    : tableau des certifications
        TabVal    : tableau des mesures
        LongNb    : taille en octets du tableau Longueurs
        CertifNb  : taille en octets du tableau Certif
        ValNb     : taille en octets du tableau TabVal

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tswrite_ (NomTrait, Entrees, Longueurs, Certif, TabVal, LongNb, CertifNb, ValNb, lnt)

     char *NomTrait;
     Longint *Entrees;
     Longint *Longueurs;
     Longint *Certif;
     char *TabVal;
     Longint *LongNb, *CertifNb, *ValNb;
     int lnt;			/* longueur  nom traitement  */
{
  pS_Entree Entreesc;
  int cr = 0;
  char Ndt[TAILLE_NOM_TRAITEMENT];

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;
  Entreesc->ps_suivant = NULL;

  cclean (NomTrait, Ndt, lnt);
  cr = TSWrite (Ndt, Entreesc, Longueurs, Certif, TabVal, *LongNb,
		*CertifNb, *ValNb);

  free (Entreesc);
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSWritePlusOc

  But : fonction envoyant au serveur la liste des parametres a ecrire en
        base de donnees et dans les fichiers de mesure

  Arguments :
        NomTrait  : nom du traitement
        Entrees   : numero du choc
        Occ       : numero d'occurence
        Longueurs : longueurs des coordonnees
        Certif    : tableau des certifications
        TabVal    : tableau des mesures
        LongNb    : taille en octets du tableau Longueurs
        CertifNb  : taille en octets du tableau Certif
        ValNb     : taille en octets du tableau TabVal

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tswriteplusoc_ (NomTrait, Entrees, Occ, Longueurs, Certif, TabVal, LongNb, 
          CertifNb, ValNb, lnt)

     char *NomTrait;
     Longint *Entrees;
     Longint *Occ;
     Longint *Longueurs;
     Longint *Certif;
     char *TabVal;
     Longint *LongNb, *CertifNb, *ValNb;
     int lnt;			/* longueur  nom traitement  */
{
  pS_Entree Entreesc;
  int cr = 0;
  char Ndt[TAILLE_NOM_TRAITEMENT];

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;

  if (*Occ > 0) {
    Entreesc->ps_suivant = (pS_Entree) malloc (sizeof (struct S_Entree));
    Entreesc->ps_suivant->union_var.lval = *Occ;
    Entreesc->ps_suivant->ps_suivant = NULL;
  }
  else
    Entreesc->ps_suivant = NULL;

 /* Entreesc->ps_suivant = NULL; */

  cclean (NomTrait, Ndt, lnt);
  cr = TSWrite (Ndt, Entreesc, Longueurs, Certif, TabVal, *LongNb,
		*CertifNb, *ValNb);

  free (Entreesc);
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSWcertif

  But : fonction envoyant au serveur les certifications associees a une donnee

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        Certif    : tableau des certifications
        CertifNb  : taille en octets du tableau Certif

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/


int
tswcertif_ (NomDon, Entrees, Certif, CertifNb, lnd)

     char *NomDon;
     Longint *Entrees;
     Longint *Certif;
     Longint *CertifNb;
     int lnd;

{
  pS_Entree Entreesc;
  int cr = 0;
  char Ndt[TAILLE_NOM_DONNEE];

  cclean (NomDon, Ndt, lnd);

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;
  Entreesc->ps_suivant = NULL;

  cr = TSWcertif (Ndt, Entreesc, Certif, *CertifNb);

  free (Entreesc);
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSRSigRg

  But : fonction demandant au serveur de lui renvoyer un signal lu entre 2 rangs

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        Rangs     : tableau contenant le rang initial et le rang final
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/


int
tsrsigrg_ (NomDon, Entrees, Rangs, NbMax, Extract, Unite, NumVer, Certif,
	   Date, Heure, NbMes, MaxReel, X, Y,
	   lnd, lut, ldt, lhr)

     char *NomDon;
     Longint *Entrees;
     Longint *Rangs;
     Longint *NbMax;
     Longint *Extract;
     char *Unite[];
     Longint *NumVer;
     Longint *Certif;
     char *Date;
     char *Heure;
     Longint *NbMes;
     Longint *MaxReel;
     char *X;
     char *Y;
     int lnd, lut, ldt, lhr;

{
  struct S_Unite *ptunite;
  pS_Unite ptu;
  pS_Entree Entreesc;
  int cr = 0;
  int len;
  char *ptc, Ndt[TAILLE_NOM_DONNEE];

  if ((cr = check_dateheure (ldt, lhr)) < 0)
    return cr;
  cclean (NomDon, Ndt, lnd);

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;
  Entreesc->ps_suivant = NULL;

  cr = TSRSigRg (Ndt, Entreesc, Rangs, *NbMax, *Extract, &ptunite, NumVer,
		 Certif, Date, Heure, NbMes, MaxReel, X, Y);

  if (!cr)
    {
      if (ptunite)
	{
	  ptc = (char *) Unite;
	  ptu = ptunite;

	  do
	    {
	      if (ptu->nom)
		{
		  len = strlen (ptu->nom);
		  memcpy (ptc, ptu->nom, ((lut >= len) ? len : lut));
		  if (lut > len)
		    memset (ptc + sizeof (char) * len, ' ', (lut - len));
		}
	      ptc += sizeof (char) * lut;
	    }
	  while (ptu = ptu->ps_suivant);
	  free (ptunite);
	}
      clean_dateheure (Date, ldt, Heure, lhr);
    }
  free (Entreesc);
  return (cr);

}


int
tsrsigrgplusoc_ (NomDon, Entrees, Occ, Rangs, NbMax, Extract, Unite, NumVer,
                 Certif, Date, Heure, NbMes, MaxReel, X, Y, lnd, lut, ldt, lhr)

     char *NomDon;
     Longint *Entrees;
     Longint *Occ;
     Longint *Rangs;
     Longint *NbMax;
     Longint *Extract;
     char *Unite[];
     Longint *NumVer;
     Longint *Certif;
     char *Date;
     char *Heure;
     Longint *NbMes;
     Longint *MaxReel;
     char *X;
     char *Y;
     int lnd, lut, ldt, lhr;

{
  struct S_Unite *ptunite;
  pS_Unite ptu;
  pS_Entree Entreesc;
  int cr = 0;
  int len;
  char *ptc, Ndt[TAILLE_NOM_DONNEE];

  if ((cr = check_dateheure (ldt, lhr)) < 0)
    return cr;
  cclean (NomDon, Ndt, lnd);

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;
  /*Entreesc->ps_suivant = NULL; */
 
  if (*Occ > 0) {
    Entreesc->ps_suivant = (pS_Entree) malloc (sizeof (struct S_Entree));
    Entreesc->ps_suivant->union_var.lval = *Occ;
    Entreesc->ps_suivant->ps_suivant = NULL;
  }
  else
    Entreesc->ps_suivant = NULL; 

  cr = TSRSigRg (Ndt, Entreesc, Rangs, *NbMax, *Extract, &ptunite, NumVer,
		 Certif, Date, Heure, NbMes, MaxReel, X, Y);

  if (!cr)
    {
      if (ptunite)
	{
	  ptc = (char *) Unite;
	  ptu = ptunite;

	  do
	    {
	      if (ptu->nom)
		{
		  len = strlen (ptu->nom);
		  memcpy (ptc, ptu->nom, ((lut >= len) ? len : lut));
		  if (lut > len)
		    memset (ptc + sizeof (char) * len, ' ', (lut - len));
		}
	      ptc += sizeof (char) * lut;
	    }
	  while (ptu = ptu->ps_suivant);
	  free (ptunite);
	}
      clean_dateheure (Date, ldt, Heure, lhr);
    }
  free (Entreesc);
  return (cr);

}

/*----------------------------------------------------------------------------

                        TSRSigX

  But : fonction demandant au serveur de lui renvoyer un signal lu entre
        2 valeurs de l'abscisse

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        XI        : valeur initiale de l'abscisse
        XF        : valeur finale de l'abscisse
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsrsigx_ (NomDon, Entrees, XI, XF, NbMax, Extract, Unite, NumVer, Certif,
	  Date, Heure, NbMes, MaxReel, X, Y,
	  lnd, lut, ldt, lhr)

     char *NomDon;
     Longint *Entrees;
     Double *XI;
     Double *XF;
     Longint *NbMax;
     Longint *Extract;
     char *Unite[];
     Longint *NumVer;
     Longint *Certif;
     char *Date;
     char *Heure;
     Longint *NbMes;
     Longint *MaxReel;
     char *X;
     char *Y;
     int lnd, lut, ldt, lhr;

{
  struct S_Unite *ptunite;
  pS_Unite ptu;
  pS_Entree Entreesc;
  int cr = 0;
  int len;
  char *ptc, Ndt[TAILLE_NOM_DONNEE];

/**   YB   YB   **/
/**  if(*XI < 1.E-24) return(17);**/
/**  if(*XF < 1.E-24) return(17);**/
/**   YB   YB   **/

  if ((cr = check_dateheure (ldt, lhr)) < 0)
    return cr;
  cclean (NomDon, Ndt, lnd);

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;
  Entreesc->ps_suivant = NULL;

  cr = TSRSigX (Ndt, Entreesc, *XI, *XF, *NbMax, *Extract, &ptunite,
		NumVer, Certif, Date, Heure, NbMes, MaxReel, X, Y);

  if (!cr)
    {
      if (ptunite)
	{
	  ptc = (char *) Unite;
	  ptu = ptunite;

	  do
	    {
	      if (ptu->nom)
		{
		  len = strlen (ptu->nom);
		  memcpy (ptc, ptu->nom, ((lut >= len) ? len : lut));
		  if (lut > len)
		    memset (ptc + sizeof (char) * len, ' ', (lut - len));
		}
	      ptc += sizeof (char) * lut;
	    }
	  while (ptu = ptu->ps_suivant);
	  free (ptunite);
	}
      clean_dateheure (Date, ldt, Heure, lhr);
    }
  free (Entreesc);
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSXtrRg

  But : fonction demandant au serveur de lui renvoyer un signal d'un groupe lu
        entre 2 rangs

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        Indices   : tableau contenant les indices du signal dans le groupe
        Rangs     : tableau contenant le rang initial et le rang final
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures
        Coord     : tableau des valeurs des autres coordonnees

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsxtrrg_ (NomDon, Entrees, Indices, Rangs, NbMax, Extract, Unite, NumVer,
	  Certif, Date, Heure, NbMes, MaxReel, X, Y, Coord,
	  lnd, lut, ldt, lhr, lX, lY, lC)

     char *NomDon;
     Longint *Entrees;
     Longint *Indices;
     Longint *Rangs;
     Longint *NbMax;
     Longint *Extract;
     char *Unite[];
     Longint *NumVer;
     Longint *Certif;
     char *Date;
     char *Heure;
     Longint *NbMes;
     Longint *MaxReel;
     char *X;
     char *Y;
     char *Coord;
     int lnd, lut, ldt, lhr, lX, lY, lC;
{
  struct S_Unite *ptunite;
  pS_Unite ptu;
  pS_Entree Entreesc;
  int cr = 0;
  int len;
  char *ptc, Ndt[TAILLE_NOM_DONNEE];

  if ((cr = check_dateheure (ldt, lhr)) < 0)
    return cr;
  cclean (NomDon, Ndt, lnd);

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;
  Entreesc->ps_suivant = NULL;

  cr = TSXtrRg (Ndt, Entreesc, Indices, Rangs, *NbMax, *Extract, &ptunite,
		NumVer, Certif, Date, Heure, NbMes, MaxReel, X, Y, Coord);

  if (!cr)
    {
      if (ptunite)
	{
	  ptc = (char *) Unite;
	  ptu = ptunite;

	  do
	    {
	      if (ptu->nom)
		{
		  len = strlen (ptu->nom);
		  memcpy (ptc, ptu->nom, ((lut >= len) ? len : lut));
		  if (lut > len)
		    memset (ptc + sizeof (char) * len, ' ', (lut - len));
		}
	      ptc += sizeof (char) * lut;
	    }
	  while (ptu = ptu->ps_suivant);
	  free (ptunite);
	}
      clean_dateheure (Date, ldt, Heure, lhr);
    }
  free (Entreesc);
  return (cr);
}


int
tsxtrrgplusoc_ (NomDon, Entrees, Occ, Indices, Rangs, NbMax, Extract, Unite,
                NumVer, Certif, Date, Heure, NbMes, MaxReel, X, Y, Coord,
	        lnd, lut, ldt, lhr, lX, lY, lC)

     char *NomDon;
     Longint *Entrees;
     Longint *Occ;
     Longint *Indices;
     Longint *Rangs;
     Longint *NbMax;
     Longint *Extract;
     char *Unite[];
     Longint *NumVer;
     Longint *Certif;
     char *Date;
     char *Heure;
     Longint *NbMes;
     Longint *MaxReel;
     char *X;
     char *Y;
     char *Coord;
     int lnd, lut, ldt, lhr, lX, lY, lC;
{
  struct S_Unite *ptunite;
  pS_Unite ptu;
  pS_Entree Entreesc;
  int cr = 0;
  int len;
  char *ptc, Ndt[TAILLE_NOM_DONNEE];

  if ((cr = check_dateheure (ldt, lhr)) < 0)
    return cr;
  cclean (NomDon, Ndt, lnd);

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;

  if (*Occ > 0) {
    Entreesc->ps_suivant = (pS_Entree) malloc (sizeof (struct S_Entree));
    Entreesc->ps_suivant->union_var.lval = *Occ;
    Entreesc->ps_suivant->ps_suivant = NULL;
  }
  else
    Entreesc->ps_suivant = NULL;

  cr = TSXtrRg (Ndt, Entreesc, Indices, Rangs, *NbMax, *Extract, &ptunite,
		NumVer, Certif, Date, Heure, NbMes, MaxReel, X, Y, Coord);

  if (!cr)
    {
      if (ptunite)
	{
	  ptc = (char *) Unite;
	  ptu = ptunite;

	  do
	    {
	      if (ptu->nom)
		{
		  len = strlen (ptu->nom);
		  memcpy (ptc, ptu->nom, ((lut >= len) ? len : lut));
		  if (lut > len)
		    memset (ptc + sizeof (char) * len, ' ', (lut - len));
		}
	      ptc += sizeof (char) * lut;
	    }
	  while (ptu = ptu->ps_suivant);
	  free (ptunite);
	}
      clean_dateheure (Date, ldt, Heure, lhr);
    }
  free (Entreesc);
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSXtrX

  But : fonction demandant au serveur de lui renvoyer un signal d'un groupe lu
        entre 2 valeurs de l'abscisse

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        Indices   : tableau contenant les indices du signal dans le groupe
        XI        : valeur initiale de l'abscisse
        XF        : valeur finale de l'abscisse
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures
        Coord     : tableau des valeurs des autres coordonnees

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsxtrx_ (NomDon, Entrees, Indices, XI, XF, NbMax, Extract, Unite, NumVer,
	 Certif, Date, Heure, NbMes, MaxReel, X, Y, Coord,
	 lnd, lut, ldt, lhr, lX, lY, lC)

     char *NomDon;
     Longint *Entrees;
     Longint *Indices;
     Double *XI;
     Double *XF;
     Longint *NbMax;
     Longint *Extract;
     char *Unite[];
     Longint *NumVer;
     Longint *Certif;
     char *Date;
     char *Heure;
     Longint *NbMes;
     Longint *MaxReel;
     char *X;
     char *Y;
     char *Coord;
     int lnd, lut, ldt, lhr, lX, lY, lC;

{
  struct S_Unite *ptunite;
  pS_Unite ptu;
  pS_Entree Entreesc;
  int cr = 0;
  int len;
  char *ptc, Ndt[TAILLE_NOM_DONNEE];
/**   YB   YB   **/
/**   if(*XI < 1.E-24) return(17); **/
/**   if(*XF < 1.E-24) return(17); **/
/**   YB   YB   **/

  if ((cr = check_dateheure (ldt, lhr)) < 0)
    return cr;
  cclean (NomDon, Ndt, lnd);

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;
  Entreesc->ps_suivant = NULL;

  cr = TSXtrX (Ndt, Entreesc, Indices, *XI, *XF, *NbMax, *Extract,
	&ptunite, NumVer, Certif, Date, Heure, NbMes, MaxReel, X, Y, Coord);

  if (!cr)
    {
      if (ptunite)
	{
	  ptc = (char *) Unite;
	  ptu = ptunite;

	  do
	    {
	      if (ptu->nom)
		{
		  len = strlen (ptu->nom);
		  memcpy (ptc, ptu->nom, ((lut >= len) ? len : lut));
		  if (lut > len)
		    memset (ptc + sizeof (char) * len, ' ', (lut - len));
		}
	      ptc += sizeof (char) * lut;
	    }
	  while (ptu = ptu->ps_suivant);
	  free (ptunite);
	}
      clean_dateheure (Date, ldt, Heure, lhr);
    }
  free (Entreesc);
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSGrpRg

  But : fonction demandant au serveur de lui renvoyer un groupe de signaux lu
        entre 2 rangs donnes

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        Rangs     : tableau contenant le rang initial et le rang final
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures
        Coord     : tableau des valeurs des autres coordonnees

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsgrprg_ (NomDon, Entrees, Rangs, NbMax, Extract, Unite, NumVer, Certif,
	  Date, Heure, NbMes, MaxReel,  X, Y, Coord,
	  lnd, lut, ldt, lhr, lX, lY, lC)

     char *NomDon;
     Longint *Entrees;
     Longint *Rangs;
     Longint *NbMax;
     Longint *Extract;
     char *Unite[];
     Longint *NumVer;
     Longint *Certif;
     char *Date;
     char *Heure;
     Longint *NbMes;
     Longint *MaxReel;
     char *X;
     char *Y;
     char *Coord;
     int lnd, lut, ldt, lhr, lX, lY, lC;

{
  struct S_Unite *ptunite;
  pS_Unite ptu;
  pS_Entree Entreesc;
  int cr = 0;
  int len;
  char *ptc, Ndt[TAILLE_NOM_DONNEE];

  if ((cr = check_dateheure (ldt, lhr)) < 0)
    return cr;
  cclean (NomDon, Ndt, lnd);

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;
  Entreesc->ps_suivant = NULL;

  cr = TSGrpRg (Ndt, Entreesc, Rangs, *NbMax, *Extract, &ptunite, NumVer,
		Certif, Date, Heure, NbMes, MaxReel, X, Y, Coord);

  if (!cr)
    {
      if (ptunite)
	{
	  ptc = (char *) Unite;
	  ptu = ptunite;

	  do
	    {
	      if (ptu->nom)
		{
		  len = strlen (ptu->nom);
		  memcpy (ptc, ptu->nom, ((lut >= len) ? len : lut));
		  if (lut > len)
		    memset (ptc + sizeof (char) * len, ' ', (lut - len));
		}
	      ptc += sizeof (char) * lut;
	    }
	  while (ptu = ptu->ps_suivant);
	  free (ptunite);
	}
      clean_dateheure (Date, ldt, Heure, lhr);
    }
  free (Entreesc);
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSGrpX

  But : fonction demandant au serveur de lui renvoyer un groupe de signaux lu
        entre 2 valeurs de l'abscisse

  Arguments :
        NomDon    : nom de la donnee
        Entrees   : liste des entrees du traitement
        XI        : valeur initiale de l'abscisse
        XF        : valeur finale de l'abscisse
        NbMax     : nombre maximum de mesures souhaitees
        Extract   : type d'extraction souhaitee

        Unite     : liste des unites des mesures rendues
        NumVer    : numero de version du createur
        Certif    : tableau des certifications
        Date      : date d'execution du diagnostic ou du traitement
        Heure     : heure  d'execution du diagnostic ou du traitement
        NbMes     : nombre de valeurs rendues
        MaxReel   : nombre reel de valeurs
        X         : tableau des valeurs des abscisses
        Y         : tableau des valeurs des mesures
        Coord     : tableau des valeurs des autres coordonnees

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsgrpx_ (NomDon, Entrees, XI, XF, NbMax, Extract, Unite, NumVer, Certif,
	 Date, Heure, NbMes, MaxReel, X, Y, Coord,
	 lnd, lut, ldt, lhr, lX, lY, lC)

     char *NomDon;
     Longint *Entrees;
     Double *XI;
     Double *XF;
     Longint *NbMax;
     Longint *Extract;
     char *Unite[];
     Longint *NumVer;
     Longint *Certif;
     char *Date;
     char *Heure;
     Longint *NbMes;
     Longint *MaxReel;
     char *X;
     char *Y;
     char *Coord;
     int lnd, lut, ldt, lhr, lX, lY, lC;

{
  struct S_Unite *ptunite;
  pS_Unite ptu;
  pS_Entree Entreesc;
  int cr = 0;
  int len;
  char *ptc, Ndt[TAILLE_NOM_DONNEE];

/**   YB   YB   **/
/**  if(*XI < 1.E-24) return(17);**/
/**  if(*XF < 1.E-24) return(17);**/
/**   YB   YB   **/
  if ((cr = check_dateheure (ldt, lhr)) < 0)
    return cr;
  cclean (NomDon, Ndt, lnd);

  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Entrees;
  Entreesc->ps_suivant = NULL;

  cr = TSGrpX (Ndt, Entreesc, *XI, *XF, *NbMax, *Extract, &ptunite, NumVer,
	       Certif, Date, Heure, NbMes, MaxReel, X, Y, Coord);

  if (!cr)
    {
      if (ptunite)
	{
	  ptc = (char *) Unite;
	  ptu = ptunite;

	  do
	    {
	      if (ptu->nom)
		{
		  len = strlen (ptu->nom);
		  memcpy (ptc, ptu->nom, ((lut >= len) ? len : lut));
		  if (lut > len)
		    memset (ptc + sizeof (char) * len, ' ', (lut - len));
		}
	      ptc += sizeof (char) * lut;
	    }
	  while (ptu = ptu->ps_suivant);
	  free (ptunite);
	}
      clean_dateheure (Date, ldt, Heure, lhr);
    }
  free (Entreesc);
  return (cr);
}

/*----------------------------------------------------------------------------
                       		 TSLDiag
  But :

  Arguments :

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsldiag_ (NumChoc, NbDiag, Listed, ld)

     Longint *NumChoc, *NbDiag;
     char *Listed[];
     int ld;
{
  Longint cr = 0;
  int len, i;
  char *ptc;

  char *ldiag[50];

  cr = TSLDiag (*NumChoc, NbDiag, ldiag);

  if (cr == 0)
    {
      ptc = (char *) Listed;
      for (i = 0; i < *NbDiag; i++)
	{
	  len = strlen (ldiag[i]);

	  memcpy (ptc, ldiag[i], ((ld >= len) ? len : ld));
	  if (ld > len)
	    memset (ptc + sizeof (char) * len, ' ', (ld - len));
	  ptc += sizeof (char) * ld;
	}

    }
  return ((int) cr);
}

/*----------------------------------------------------------------------------
                       		 TSLTrait
  But :

  Arguments :

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsltrait_ (NbTrait, Listet, ld)

     Longint *NbTrait;
     char *Listet[];
     int ld;
{
  Longint cr = 0;
  int len, i;
  char *ptc;

  char *ltrait[50];

  cr = TSLTrait (NbTrait, ltrait);

  if (cr == 0)
    {
      ptc = (char *) Listet;
      for (i = 0; i < *NbTrait; i++)
	{
	  len = strlen (ltrait[i]);

	  memcpy (ptc, ltrait[i], ((ld >= len) ? len : ld));
	  if (ld > len)
	    memset (ptc + sizeof (char) * len, ' ', (ld - len));
	  ptc += sizeof (char) * ld;
	}

    }
  return ((int) cr);
}

/*----------------------------------------------------------------------------
                       		 TSLSig

  But :

  Arguments :

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tslsig_ (NumChoc, diag_name, NbSig, ListeS, ld, ls)

     Longint *NumChoc, *NbSig;
     char *diag_name, *ListeS[];
     int ld, ls;
{
  Longint cr = 0;
  int len, i;

  char *lsig[95], *ptc;
  char Ndt[PREPASIZE + 1];

  cclean (diag_name, Ndt, ld);

  cr = TSLSig (*NumChoc, Ndt, NbSig, lsig);
  if (cr == 0)
    {
      ptc = (char *) ListeS;
      for (i = 0; i < *NbSig; i++)
	{
	  len = strlen (lsig[i]);
	  memcpy (ptc, lsig[i], ((ld >= len) ? len : ls));
	  if (ls > len)
	    memset (ptc + sizeof (char) * len, ' ', (ls - len));
	  ptc += sizeof (char) * ls;
	}
    }
  return ((int) cr);
}


/*----------------------------------------------------------------------------
                       		 TSRqparm

  But :

  Arguments :

  Retour          : compte-rendu d'execution

------------------------------------------------------------------------------*/

int
tsrqparm_ (NumChoc, diag, obj, param, nval, buff, nrep, ld, lo, lp, lb)

     Longint *NumChoc;
     char *diag, *obj, *param, *buff;
     int *nval, *nrep, ld, lo, lp, lb;
{
  Longint cr = 0, fpar;
  int offset = 0;
  int len, i = 0;
  char Ndiag[PREPASIZE + 1], Nobj[PREPASIZE + 1], Nparam[PREPASIZE + 1];

  cclean (diag, Ndiag, ld);
  cclean (obj, Nobj, lo);
  cclean (param, Nparam, lp);

  strcpy(buff,"a");
  cr = TSRqParm (*NumChoc, Ndiag, Nobj, Nparam, *nval, buff, nrep, &fpar);

  return ((int) cr);
}


/*----------------------------------------------------------------------------
                       		 TSRqdecl
------------------------------------------------------------------------------*/

int
tsrqdecl_ (NumChoc, decl, occur, date, ld)

     Longint *NumChoc;
     char *decl;
     int *occur, ld;
     float *date;
{
  Longint cr = 0;
  int offset = 0;
  int len, i = 0;
  char Ndt[PREPASIZE + 1];

  cclean (decl, Ndt, ld);

  cr = TSRqdecl (*NumChoc, Ndt, *occur, date);

  return ((int) cr);
}

/*----------------------------------------------------------------------------
                       		 TSGetinfo
------------------------------------------------------------------------------*/

int
tsgetinfo_ (NumChoc)

     int *NumChoc;
{
  Longint cr = 0;

  cr = TSGetinfo (NumChoc);

  return ((int) cr);
}
/*----------------------------------------------------------------------------
                       		 TSTData
------------------------------------------------------------------------------*/

int
tstdata_ (NumChoc, ndiag, t_choc, t_param,ld )
     Longint *NumChoc;
     char * ndiag;
     Longint *t_choc, *t_param;
     int ld;

{
  Longint cr = 0;

  cr = TSTData (*NumChoc,ndiag, t_choc, t_param);

  return ((int)cr);
}
/*----------------------------------------------------------------------------
                       		 TSLgDiag
------------------------------------------------------------------------------*/

int
tslgdiag_ (NumChoc, nomdiag, nbmes, ld )
Longint *NumChoc, *nbmes;
char *nomdiag;
int ld;
{
  Longint cr = 0;
  char Ndt[PREPASIZE + 1];

  cclean (nomdiag, Ndt, ld);

  cr = TSLgDiag (*NumChoc, Ndt, nbmes);

  return ((int) cr);
}
/*********** JS - 05.2005 - 
	ajout des 2 fcts tsinitocctrait_ ettsupdateocctrait_  ************/
/*----------------------------------------------------------------------------

                        TSInitOccTrait

But : 	fonction envoyant au serveur les paramètres à écrire 
	dans la base de données au début de l'éxécution du traitement
Arguments :
	NomTrait  : nom du traitement
	Numchoc   : numero du choc
	Occur	  : numero de l'occurrence
	lt        : longueur du nom du traitement
Retour : compte-rendu d'execution

------------------------------------------------------------------------------*/
int 
tsinitocctrait_  (NomTrait, Numchoc, Occur, lt)

     char *NomTrait;
     Longint *Numchoc, *Occur;
     int lt;
{
  pS_Entree Entreesc;
  int cr = 0;
  char Ndt[TAILLE_NOM_TRAITEMENT];
  
  cclean (NomTrait, Ndt, lt);
  
  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Numchoc;
  if (*Occur != 0) {
    Entreesc->ps_suivant = (pS_Entree) malloc (sizeof (struct S_Entree));
    Entreesc->ps_suivant->union_var.lval = *Occur;
    Entreesc->ps_suivant->ps_suivant = NULL;
  } else {
    Entreesc->ps_suivant = NULL;
  }
  
  cr= TSInitOccTrait (Ndt, Entreesc);
  free(Entreesc);
  return (cr);
}

/*----------------------------------------------------------------------------

                        TSUpdateOccTrait

But : 	fonction envoyant au serveur les paramètres écrire 
	dans la base de données a la fin de l'éxécution du traitement
Arguments :
	NomTrait  : nom du traitement
	ENumchoc   : numero du choc
	Occur	  : numero de l'occurrence
	Status    : status de l'execution du traitement
	Dureems   : duree de l'execution du traitement en millisecondes
Retour : compte-rendu d'execution

------------------------------------------------------------------------------*/
int 
tsupdateocctrait_  (NomTrait, Numchoc, Occur, Status, Dureems, lt)
     char *NomTrait;
     Longint *Numchoc, *Occur, *Status, *Dureems;
     int lt;
{
  pS_Entree Entreesc;
  int cr = 0;
  char Ndt[TAILLE_NOM_TRAITEMENT];
  
  cclean (NomTrait, Ndt, lt);
  
  Entreesc = (pS_Entree) malloc (sizeof (struct S_Entree));
  Entreesc->union_var.lval = *Numchoc;
  if (*Occur != 0) {
    Entreesc->ps_suivant = (pS_Entree) malloc (sizeof (struct S_Entree));
    Entreesc->ps_suivant->union_var.lval = *Occur;
    Entreesc->ps_suivant->ps_suivant = NULL;
  } else {
    Entreesc->ps_suivant = NULL;
  }
  
  cr= TSUpdateOccTrait (Ndt, Entreesc, *Status, *Dureems);
  free(Entreesc);
  return (cr);
}

/*---------------------------
  ---------------------------*/
int
cclean (chOld, chNew, Len)

     char *chOld, *chNew;
     Longint Len;
{
  int i = 0;
  char *pts, *ptd;

  pts = chOld;
  ptd = chNew;
  while ((*pts != ' ') && (i < Len))
    {
      *ptd++ = *pts++;
      i++;
    }
  *ptd = '\0';
  return (0);
}

/****
 ****/
int
check_dateheure (ldate, lheure)
     int ldate, lheure;
{
  if ((ldate < LDATE) || (lheure < LHEURE))
    return (-10);

  return (0);
}

/****
 ****/
int
clean_dateheure (date, ldate, heure, lheure)
     char *date, *heure;
     int ldate, lheure;
{
  int i;
  for (i = LDATE; i < ldate; i++)
    date[i] = ' ';
  for (i = LHEURE; i < lheure; i++)
    heure[i] = ' ';
  return (0);
}
