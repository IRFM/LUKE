/*

YB  Juillet95

*/

typedef struct T_Objet {
  char  *obj_name; 
  int   code_type;   
} T_Objet;

extern T_Objet  Type_Objets[];
extern int      nb_objets;      /* number of elements in array Type_Objets*/

