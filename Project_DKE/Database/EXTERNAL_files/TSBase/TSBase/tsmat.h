/*		.....  tsmat.h	.....		*/
/*		.....	 YB	.....		*/
/*						*/
#define P_OCTET		1
#define P_CARAC		2
#define P_SHORT		3
#define P_LONG		4
#define P_FLOAT		5
#define P_DOUBLE	6
#define TWIN_INT16      7
#define TWIN_REEL32     8
#define INT_REEL32      9
#define STRAT_PILOTE    15
#define SERNAM		18
#define CADRAN		19
#define CHRONO       	28
#define T_DECLENC       29
#define L_DIAG       	30
#define FLOAT4_CHAR64	36
#define INT2_CHAR64	37
#define VOIE_GAIN	12


#define L_NOM_REPERE	9
#define L_NOM_STRATEGIE	13
#define L_NOM_DECLENCHE	13
#define L_COMMENTAIRE	33

/*
#define P_LOGIQUE	7
#define P_COMPLEX	8
*/
#define P_TEXTE		32

#define F_STRING	20
#define UNIT_SIZE	6

typedef union
  {
    unsigned char *Uchar;
    char *Char;
    unsigned short *Ushort;
    short *Short;
#ifdef __alpha
    unsigned int *Ulong;
#else
    unsigned long *Ulong;
#endif
    Longint *Long;
    float *Float;
    double *Ddouble;
  }
dataUnion;
