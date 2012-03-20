/*****************************************************************************

   NOM  DU MODULE        :  tscom.c

   DESCRIPTION DU MODULE :  module contenant l'ensemble des fonctions permettant
                            la communication client/serveur depuis le client

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   29/09/92
   Modifications    :
                        	    Debut_communication ajout d'un argument:
                                    se connecte au serveur SUN ou au serveur 
                                    alpha

 *****************************************************************************/

/*****************************************************************************

   Liste des fonctions du module :

        Emission
        Fin_Emission
        Reception
        Debut_Communication
        Fin_Communication

   Toutes les fonctions citees sont appelees par les fonctions du client TSLib

 *****************************************************************************/


#include <stdio.h>		/* bibliotheques standards           */
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/time.h>

#include "tsdef.h"		/* liste des constantes utilisees */
#include "tsconf.h"		/* configuration du client        */
#include "tsext.h"

#if (client==PC)
#define WSOCKETS_DLL
#include <ctype.h>		/* definition des types de base du systeme */
#include <limits.h>
#include <sys/socket.h>		/* definition de types et constantes
				   associees aux sockets                   */
#include <netinet\in.h>		/* definition de constantes et structures
				   pour le systeme internet                */
#include <netdb.h>		/* definition de structures utilisees pour
				   la communication reseau                 */
#include <sock_err.h>
#include <windows.h>
#include <toolhelp.h>

#elif (client==MAC)
#include <CTBUtilities.h>	/* utilitaires de la communication toolbox */
#include <CommResources.h>	/* */
#include <Connections.h>	/* */
#include <unix.h>

#elif (client == INTEL)
#include <rmx_c.h>
#include <rmx_err.h>
#include <rmx_def.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <string.h>
#include <strings.h>

#else

#include <netdb.h>		/* definition de structures utilisees pour
				   la communication reseau                 */
#include <sys/types.h>		/* definition des types de base du systeme */
#include <sys/socket.h>		/* definition de types et constantes
				   associees aux sockets                   */
#include <netinet/in.h>		/* definition de constantes et structures
				   pour le systeme internet                */
#endif

#include "tshote.h"
/*#include "tshote_mizar.h" */
#include "tsmes.h"		/* liste des erreurs              */
#include "tstype.h"		/* liste des types de donnees     */
/* #include "tslib.h"            liste des variables globales   */
#include "functs.h"		/* prototypes fcts TSLib */

void *Memset (void *, int, Longint);
extern void *MemAlloc (Longint);	/* allocation de la memoire */
extern void FreeMem (void *);	/* liberation de la memoire */

#if (client == INTEL)
#define MAX_TRY      4		/* maximum number of socket call     */
#endif

int compress_on;
int Socket_save;

/*----------------------------------------------------------------------------

                        Emission


  But : fonction d'emission d'un parametre vers le serveur

  Arguments :
        nsock      : numero de la socket de communication
        parametre  : parametre a emettre
        longbuffer : longueur en octets du buffer a emettre
        code_param : code du parametre a emettre

  Retour           : compte-rendu d'execution de la fonction

 ----------------------------------------------------------------------------*/

Longint FAR_PASCAL
Emission (
#if (client == MAC)
	   ConnHandle nsock,
#else
	   int nsock,
#endif
	   char *parametre,
	   Longint longbuffer,
	   Longint code_param)

{
#if (client ==MAC)
  Longint longenvoye, i;
  OSErr anErr;

  i = 0;
  while (i < longbuffer)
    {
      longenvoye = longbuffer - i;

      (void) CMIdle (nsock);
      if ((anErr = CMWrite (nsock, parametre + i, &longenvoye, cmData, 0, NULL, 1, 0))
	  != noErr)
	{
	  Fin_Communication (nsock);
	  return (Gestion_Erreur (erreur_emission, code_param));
	}
      i = i + longenvoye;
    }
#elif (client==PC)

  short int longbuff;
  Longint i;

  i = 0;
  while (longbuffer > 0)
    {
      if (longbuffer >= (Longint) SHRT_MAX)
	{
	  longbuff = SHRT_MAX;
	  longbuffer = longbuffer - (Longint) SHRT_MAX;
	}
      else
	{
	  longbuff = (short int) longbuffer;
	  longbuffer = 0;
	}
      if (send (nsock, parametre + i, longbuff, 0) != longbuff)
	{
	  Fin_Communication (nsock);
	  return (Gestion_Erreur (erreur_emission, code_param));
	}
      i = i + longbuff;
    }
#elif (client == INTEL)
  Longint i, j;
  int max_try;

  i = 0;
  while (i < longbuffer)
    {
      max_try = MAX_TRY;
      do
	{
	  j = send (nsock, parametre + i, longbuffer - i, 0);
	  if (j == -1)
	    {
	      max_try--;
	      if ((errno != EWOULDBLOCK) || (max_try < 0))
		{
		  printf ("TSLIB : send errno = %d \n", errno);
		  Fin_Communication (nsock);
		  return (Gestion_Erreur (erreur_emission, code_param));
		}
	    }
	  else
	    {
	      i = i + j;
	      break;
	    }
	}
      while (max_try >= 0);
    }
#else
  if (send (nsock, parametre, longbuffer, 0) != longbuffer)
    {
      Fin_Communication (nsock);
      return (Gestion_Erreur (erreur_emission, code_param));
    }
#endif
  return ok;
}

#if ((client!=PC) && (client !=MAC))
/*----------------------------------------------------------------------------

                        Fin_Emission


  But : fonction de fin d'emission

  Arguments :
        nsock      : numero de la socket de communication

  Retour           : compte-rendu d'execution de la fonction

 ----------------------------------------------------------------------------*/

Longint FAR_PASCAL 
Fin_Emission (int nsock)
{
  if (shutdown (nsock, 1) == -1)
    {
      Fin_Communication (nsock);
      return erreur_fin_emission;
    }

  return ok;
}
#endif


#if (client == PC)

/*----------------------------------------------------------------------------

                        ReceptionHuge


  But : fonction de reception d'un parametre emis par le serveur

  Arguments :
        nsock      : numero de la socket de communication
        parametre  : parametre a recevoir
        longbuffer : longueur en octets du buffer a recevoir
        code_param : code du parametre a emettre

  Retour           : compte-rendu d'execution de la fonction

 ----------------------------------------------------------------------------*/

Longint FAR_PASCAL
ReceptionHuge (
		int nsock,
		char HUGE * parametre,
		Longint longbuffer,
		Longint code_param)
{
  Longint i;
  int j;
  short longbuff;
  char far *para;
  short nbytes = 16384;

  if (longbuffer > 0)
    {
      i = 0;
      para = (char *) MemAlloc (nbytes);
      while (i < longbuffer)
	{

	  if ((longbuffer - i) > nbytes)
	    longbuff = nbytes;
	  else
	    longbuff = (short int) (longbuffer - i);

	  j = recv (nsock, para, longbuff, 0);
	  if ((j == -1) || (j == 0))
	    {
	      Fin_Communication (nsock);
	      return (Gestion_Erreur (erreur_reception, code_param));
	    }
	  hmemcpy (parametre + i, para, longbuff);
	  i += (Longint) j;
	}
      FreeMem (para);
    }

  return ok;
}
#endif
/*----------------------------------------------------------------------------

                        Reception


  But : fonction de reception d'un parametre emis par le serveur

  Arguments :
        nsock      : numero de la socket de communication
        parametre  : parametre a recevoir
        longbuffer : longueur en octets du buffer a recevoir
        code_param : code du parametre a emettre

  Retour           : compte-rendu d'execution de la fonction

 ----------------------------------------------------------------------------*/

Longint FAR_PASCAL
Reception (
#if (client == MAC)
	    ConnHandle nsock,
#else
	    int nsock,
#endif
	    char *parametre,
	    Longint longbuffer,
	    Longint code_param)
{
#if (client ==MAC)
  Longint longenvoye;
  Longint i;
  CMFlags cmflags;
  OSErr anErr;
  CMBufferSizes datasizes;
  CMStatFlags statflags;
  unsigned Longint startticks;

  if (longbuffer > 0)
    {
      i = 0;
      while (i < longbuffer)
	{
	  longenvoye = longbuffer - i;

	  startticks = TickCount ();
	  do
	    {
	      (void) CMIdle (nsock);
	      anErr = CMStatus (nsock, datasizes, &statflags);
	    }
	  while ((anErr == noErr) && (datasizes[cmDataIn] == 0) &&
		 (((unsigned Longint) TickCount () - startticks) < delai));

	  cmflags = 0;
	  if ((anErr == noErr) && (datasizes[cmDataIn] != 0))
	    {
	      anErr = CMRead (nsock, parametre + i, &longenvoye, cmData, 0, NULL, 1, &cmflags);
	      if (anErr != noErr)
		{
		  Fin_Communication (nsock);
		  return (Gestion_Erreur (erreur_reception, code_param));
		}
	      else
		i = i + longenvoye;
	    }
	  else
	    {
	      Fin_Communication (nsock);
	      return (Gestion_Erreur (erreur_reception, code_param));
	    }
	}
    }

#elif (client == PC)
  Longint i;
  int j;
  short longbuff;

  if (longbuffer > 0)
    {
      i = 0;
      while (i < longbuffer)
	{

	  if ((longbuffer - i) > (Longint) SHRT_MAX)
	    longbuff = SHRT_MAX;
	  else
	    longbuff = (short int) (longbuffer - i);

	  j = recv (nsock, (parametre + i), longbuff, 0);
	  if ((j == -1) || (j == 0))
	    {
	      Fin_Communication (nsock);
	      return (Gestion_Erreur (erreur_reception, code_param));
	    }
	  i += (Longint) j;
	}
    }

#elif (client == INTEL)
  Longint i, j;
  int max_try;
  if (longbuffer > 0)
    {
      i = 0;
      while (i < longbuffer)
	{
	  max_try = MAX_TRY;
	  do
	    {
	      j = recv (nsock, parametre + i, longbuffer - i, 0);
	      if (j == -1)
		{
		  max_try--;
		  if ((max_try < 0) || (errno != EWOULDBLOCK))
		    {
		      printf ("TSLIB : receive errno = %d \n", errno);
		      Fin_Communication (nsock);
		      return (Gestion_Erreur (erreur_reception, code_param));
		    }
		}
	      else
		{
		  i = i + j;
		  break;
		}
	    }
	  while (max_try >= 0);
	}
    }
#else
  Longint i, j;
  if (longbuffer > 0)
    {
      i = 0;
      while (i < longbuffer)
	{
	again:
	  j = recv (nsock, parametre + i, longbuffer - i, 0);
	  if ((j == -1) || (j == 0))
	    {
	      if (j < 0)
		printf ("receive errno = %d \n", errno);
	      if (errno == EINTR)
		{
		  errno = 0;
		  goto again;
		}
	      Fin_Communication (nsock);
	      return (erreur_reception);
	    }
	  i += j;
	}
    }
#endif
  return ok;
}

/*----------------------------------------------------------------------------

                        Debut_Communication


  But : fonction d'initialisation de l'environnement de communication et
        de demande de connexion au serveur

  Arguments :
        NumSocket  : numero de la socket de communication
        ind_base   : indice du serveur a connecter (0:hote1,#0:hote2)

  Retour           : compte-rendu d'execution

 ----------------------------------------------------------------------------*/
#if (client != MAC)

Longint FAR_PASCAL
Debut_Communication (int *NumSocket, int ind_serv)
				 /*  NumSocket: descripteur de socket */
       /* ind_base : indice serveur a connecter 1 = rigel
          0 = rhea (IR) */
{
  int LongAdr;			/* longueur de l'adresse de la socket */
  Longint Resultat;		/* compte-rendu d'execution de l'emission */
  char CodeClient;		/* code du client */

  struct hostent *Serveur = NULL;/* informations sur la machine serveur */
  struct servent *Service;	/* informations sur le service */
  /* struct sockaddr_in AdrSockLocale;	 adresse de la socket locale */
  struct sockaddr_in AdrSockDistante;	/* adresse de la socket distante */

  short nb_tent = 0, port;
  int one = 1;
  char *tslib_comp, *tslib_port;
  struct linger l_inger;

  char hostpart[256] = {0};
  char portpart[256] = {0};
  char *host;

  if (ind_serv == 1)  /* donnees "standard" */
    {
      host = getenv ("TSLIB_SERVER");
      if (host)
	{
	  sscanf (host, "%[^:]:%s", hostpart, portpart);
	  if (strlen (portpart) ==  0)
	    strcpy (portpart, "5880");
	  /*  printf(" Warning !! Connecting to %s : %s \n",
                                              hostpart,portpart); */
	}
      else
	{
	  strcpy (hostpart, hote2);  /* rigel */
	  strcpy (portpart, "5880");
	}
    }
  else if (ind_serv == 0)  /* donnees "IR" */
    {
      host = getenv ("TSLIB_SERVER_IR");
      if (host)
	{
	  sscanf (host, "%[^:]:%s", hostpart, portpart);
	  if (strlen (portpart) == 0)
	    strcpy (portpart, "5880");
	  /*  printf(" Warning !! Connecting to %s : %s \n",
                                             hostpart,portpart); */
	}
      else
	{
	  strcpy (hostpart, hote1);  /* rhea */
	  strcpy (portpart, "5880");
	}
    }

  compress_on = 0;
  tslib_comp = getenv ("TSLIB_COMPRESS");
  if (tslib_comp)
    if (!strcmp (tslib_comp, "TRUE"))
      compress_on = 1;

  Serveur = gethostbyname (hostpart);

  if (Serveur == NULL)
    {
      LongAdr = inet_addr (hostpart);
      if (LongAdr != 0xffffffff)
	Serveur = gethostbyaddr ((void *) &LongAdr,
				 (int) sizeof (LongAdr), AF_INET);
    }
  if (Serveur == NULL)
    {
      printf ("Erreur : %s inconnu\n", hostpart);
      return (erreur_hote);
    }

  Resultat = ok;

  tslib_port = getenv ("TSLIB_PORT");
  if (tslib_port)
    {
      sscanf (tslib_port, "%s", portpart);
      printf (" Warning !! Connecting to Tslib port : %s \n", portpart);
    }

try_again:
  *NumSocket = socket (AF_INET, SOCK_STREAM, 0);
  if (*NumSocket == -1)
    return (erreur_socket);

  AdrSockDistante.sin_port = htons ((short) atoi (portpart));
  AdrSockDistante.sin_family = AF_INET;
  memcpy (&AdrSockDistante.sin_addr, Serveur->h_addr_list[0],
	  Serveur->h_length);

  if (connect (*NumSocket, (struct sockaddr *) &AdrSockDistante,
                                       sizeof (AdrSockDistante)) == -1)
    {
#if (client == INTEL)
      shutdown (*NumSocket, 2);
#else
      close (*NumSocket);
#endif
      nb_tent++;
      if (nb_tent > 4)
	return (erreur_connexion);
      sleep (1);
      goto try_again;
    }

  Socket_save = *NumSocket;
  setsockopt (*NumSocket, SOL_SOCKET, SO_KEEPALIVE, (char *) &one,
                                                     (int) sizeof (one));
  /*
if (getsockname (*NumSocket, (struct sockaddr *) &AdrSockLocale,
                                                        &LongAdr) == -1)
    return (erreur_sock_adr);
*/

  /* emission du code client */

  CodeClient = client;
  if ((Resultat = Emission (*NumSocket, &CodeClient, taille_char, p_codeclient))
      != ok)
    return (Resultat);

  return Resultat;
}

#else /* version macintosh */
Longint
Debut_Communication (ConnHandle * NumSocket, int ind_base)
{

  ConnHandle sock;
  OSErr anErr;
  short int procID;
  Longint refcon;
  unsigned Longint startticks;
  CMRecFlags recflags;
  CMBufferSizes desiredsizes, datasizes;
  CMStatFlags statflags;
  CMStatFlags prevstatflags = -1;
  CMFlags cmflags;
  Str255 toolname;
  Longint Resultat;
  char CodeClient;		/* code du client */

  Resultat = ok;

  desiredsizes[cmDataIn] = 0;
  desiredsizes[cmCntlIn] = 0;
  desiredsizes[cmAttnIn] = 0;
  desiredsizes[cmRsrvIn] = 0;
  desiredsizes[cmDataOut] = 0;
  desiredsizes[cmCntlOut] = 0;
  desiredsizes[cmAttnOut] = 0;
  desiredsizes[cmRsrvOut] = 0;

  recflags = 0;
  refcon = 0;

  (void) InitCRM ();
  (void) InitCTBUtilities ();
  (void) InitCM ();

  Strcpy (toolname, glob_toolname);
  procID = CMGetProcID (toolname);
  if (procID != -1)
    {
      sock = NULL;
      if ((sock = CMNew (procID, recflags, desiredsizes, refcon, (Longint) NULL))
	  == NULL)
	return erreur_cree_enr_conn;
      *NumSocket = sock;
    }
  else
    return erreur_outil_connexion;

  if ((anErr = CMSetConfig (*NumSocket, glob_config)) != noErr)
    return erreur_config_conn;

  if ((anErr = CMOpen (*NumSocket, 0, NULL, 1)) != noErr)
    return erreur_connexion;

  /* emission du code client */

  CodeClient = client;
  if ((Resultat = Emission (*NumSocket, &CodeClient, taille_char, p_codeclient))
      != ok)
    return (Resultat);

  return Resultat;
}

#endif

/*----------------------------------------------------------------------------

                        Fin_Communication


  But : procedure de fin de communication

  Arguments :
        nsock      : numero de la socket de communication

 ----------------------------------------------------------------------------*/

void 
Fin_Communication (
#if (client == MAC)
		    ConnHandle nsock
#else
		    int nsock
#endif
)
{
#if (client==PC)
  close_socket (nsock);
#elif (client==MAC)
  CMDispose (nsock);
#elif (client == INTEL)
  shutdown (nsock, 2);
#else
  close (nsock);
#endif
}

void *
Memset (void *dst, int c, Longint n)
{
  if (n != 0)
    {
      char *d = dst;
      do
	*d++ = c;
      while (--n != 0);
    }
  return (dst);
}

int 
ReceptionYB (int nsock, char *szBuffer, int len)
{
  int ret;

  if ((ret = recv (nsock, szBuffer, len, 0)) <= 0)
    return 0;

  return ret;
}
