/*------------------------------------------------------------------------*/
/*  bout de code pour Stephane                                            */
/*------------------------------------------------------------------------*/
#include <stdio.h>
#include <sys/types.h>

char  nomdiag[20];
char tslib_reel = 'f';

/*================================================================= */
/*..main --                                                         */
/*------------------------------------------------------------------*/
int main(argc, argv)
int argc;
char **argv;
{
                                                                         

  char  *user_env;  
  int        n;
  char       ligne_cmd[256];
                                                                   
  printf("      performance de TSwrite param       \n");
  strcpy(nomdiag,"DVME1");
  
  printf("-----------------------------------------\n");
   ts_chronochoc();
  printf("-----------------------------------------\n");


} /* main */
/*--------------------------------------------------------*/
int ts_chronochoc ()
{ 
  
  char  nom_prod[64],nom_param[2][13];
  
  int   i,j,cr,lg,taille_max,nbeve;
  int   tab_nbeve[2],tab_lg[2],tab_param[510];
  
  printf("****  ecriture ETATCHRONO ***************\n");
  
  nbeve=255;
  for (i=0;i<510;i++) {tab_param[i]=i;}
  strcpy(nom_prod, nomdiag);      
  strncpy(nom_param[0],"CODECHRO",13); /** YB  **/
  strncpy(nom_param[1],"DATECHRO",13); /** YB  **/
  
  printf("nom du producteur : %s qui a %d codes\n",nom_prod,nbeve);
  printf("---------------------------------\n");
  
  lg = 255 * 4; 
  tab_nbeve[0]=255;
  tab_lg[0]=lg;
  tab_nbeve[1]=255;
  tab_lg[1]=lg;

  printf(" stockage base de la chronometrie du choc\n");

  cr = TSwriteParam(0,nom_prod,"ETATCHRONO",nom_param,2,tab_nbeve,tab_lg,(char *)tab_param); 
  if (cr) 
    { printf("ts_chronochoc: TSwriteParam PB pour ETATCHRONO :%d\n",cr); }

/*
  printf(" archivage de la chronometrie du choc\n");
  cr = TSwriteParam(1,nom_prod,"ETATCHRONO",nom_param,2,tab_nbeve,tab_lg,(char *)tab_param);
  if (cr) 
    { printf("ts_chronochoc: TSwriteParam PB pour ETATCHRONO :%d\n",cr); }
    
*/
  printf(" chronometrie du choc TERMINE\n");
  return(0);
    
}   

