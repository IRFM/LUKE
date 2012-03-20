/*****************************************************************************
 
   NOM  DU MODULE        : tsmes.h

   DESCRIPTION DU MODULE :  fichier d'include contenant l'ensemble des  
                            messages d'erreur de communication

   Auteur       :       Vita-Maria GUZZI
   Societe      :       CR2A
   Projet       :       TSLib

   Date de Creation :   28/09/92
   Modifications    :

 *****************************************************************************/

#define ok                      (Longint)0

#define erreur_hote             (Longint)100
#define erreur_service          (Longint)101
#define erreur_socket           (Longint)102
#define erreur_connexion        (Longint)103
#define erreur_sock_adr         (Longint)104
#define erreur_emission         (Longint)105
#define erreur_fin_emission     (Longint)106
#define erreur_reception        (Longint)107
#define erreur_chaine_vide	(Longint)108
#define erreur_tableau_vide	(Longint)109
#define erreur_outil_connexion  (Longint)110
#define erreur_cree_enr_conn    (Longint)111
#define erreur_config_conn      (Longint)112

/* chaines de caracteres */

#define p_nomtrait               (Longint)1       /* en entree */
#define p_nomdiag                (Longint)2
#define p_nomdon                 (Longint)3
#define p_nomdec                 (Longint)4
#define p_date                   (Longint)5       /* en sortie */
#define p_heure                  (Longint)6

/* structures et listes chainees */

#define p_entrees                (Longint)7       /* en entree */
#define p_desctrait              (Longint)8       /* en sortie */
#define p_descdiag               (Longint)9
#define p_descdon                (Longint)10
#define p_unite                  (Longint)11

/* tableaux */

#define p_longueurs              (Longint)12       /* en entree */
#define p_tabval                 (Longint)13
#define p_nbcoord                (Longint)14
#define p_rangs                  (Longint)15
#define p_indices                (Longint)16
#define p_x                      (Longint)17
#define p_t                      (Longint)18
#define p_y                      (Longint)19
#define p_coord                  (Longint)20
#define p_certif                 (Longint)21       /* en entree ou en sortie */


/* autres parametres */

#define p_nbmax                  (Longint)22       /* en entree */
#define p_extract                (Longint)23
#define p_numchoc                (Longint)24
#define p_occur                  (Longint)25
#define p_xi                     (Longint)26
#define p_xf                     (Longint)27
#define p_longnb                 (Longint)28
#define p_certifnb               (Longint)29
#define p_valnb                  (Longint)30
#define p_numver                 (Longint)31       /* en sortie */
#define p_nbmes                  (Longint)32
#define p_maxreel                (Longint)33
#define p_cr                     (Longint)34
#define p_codeclient             (Longint)35
#define p_codefonc               (Longint)36
#define p_status		 (Longint)37	/* JS - 10.2004 */
#define p_duree			 (Longint)38	/* JS - 10.2004 */
