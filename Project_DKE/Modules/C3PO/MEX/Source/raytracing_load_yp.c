#include <complex.h>
#include <math.h>
#include "mex.h"



struct polynomial_piecewise_1D {
    mxChar  *form_f;
    double  *breaks_f;
    double  *coefs_f;
    double  *pieces_f;
    double  *order_f;
    double  *dim_f;
    mxChar  *orient_f;
    mxChar  *form_dfdrho;
    double  *breaks_dfdrho;
    double  *coefs_dfdrho;
    double  *pieces_dfdrho;
    double  *order_dfdrho;
    double  *dim_dfdrho;
    mxChar  *orient_dfdrho;
};

struct polynomial_piecewise_2D {
    double  *n;
    mxChar  *form_a0;
    double  *breaks_a0;
    double  *coefs_a0;
    double  *pieces_a0;
    double  *order_a0;
    double  *dim_a0;
    mxChar  *orient_a0;
    mxChar  *form_da0drho;
    double  *breaks_da0drho;
    double  *coefs_da0drho;
    double  *pieces_da0drho;
    double  *order_da0drho;
    double  *dim_da0drho;
    mxChar  *orient_da0drho;
    mxChar  *form_an;
    double  *breaks_an;
    double  *coefs_an;
    double  *pieces_an;
    double  *order_an;
    double  *dim_an;
    mxChar  *orient_an;
    mxChar  *form_dandrho;
    double  *breaks_dandrho;
    double  *coefs_dandrho;
    double  *pieces_dandrho;
    double  *order_dandrho;
    double  *dim_dandrho;
    mxChar  *orient_dandrho;
    mxChar  *form_bn;
    double  *breaks_bn;
    double  *coefs_bn;
    double  *pieces_bn;
    double  *order_bn;
    double  *dim_bn;
    mxChar  *orient_bn;
    mxChar  *form_dbndrho;
    double  *breaks_dbndrho;
    double  *coefs_dbndrho;
    double  *pieces_dbndrho;
    double  *order_dbndrho;
    double  *dim_dbndrho;
    mxChar  *orient_dbndrho;
};

struct rayprofiles {
    double *Te;
    double *ne;
    double *zTi;
    double *zni;
    double *dTedY;
    double *dnedY;
    double **dzTidY;
    double **dznidY;
};


struct rayparam {
    double *testmode;
    double *tensortype;
    double *t0;
    double *tfinal;
    double *dt0;
    double *dS;
    double *tol;
    double *kmax;
    double *ncyclharm;
    double *reflection;
    double *rel_opt;
    double *nperp;
    double *pperpmax;
    double *tau_lim;
    double *kextra;
};

struct equilparam {
    double *zZi;
    double *zmi;
    int *ns;
    double *Rp;
    double *ap;
    double *Zp;
    double *psia;
};

struct fluctparam {
    double *ns0;
    double *xreset0;
    double *nkperproots;
    double *betagridsize;
    double *dtfac;
};

struct fluctspectrum {
    double *dfcl;
    double *fnkperpspec;
    double *mffcl;
    double *fbkperpspec;
};

typedef struct polynomial_piecewise_1D pp_1D_format;
typedef struct polynomial_piecewise_2D pp_2D_format;
typedef struct rayparam rayparam_format;
typedef struct fluctparam fluctparam_format;
typedef struct fluctspectrum fluctspectrum_format;
typedef struct equilparam equilparam_format;
typedef struct rayprofiles rayprofiles_format;

rayparam_format load_ray_param(structure_name)
mxArray *structure_name;
{
    rayparam_format data;
       
    data.testmode = mxGetData(mxGetField(structure_name, 0, "testmode"));
    data.t0 = mxGetData(mxGetField(structure_name, 0, "t0"));
    data.tfinal = mxGetData(mxGetField(structure_name, 0, "tfinal"));
    data.dt0 = mxGetData(mxGetField(structure_name, 0, "dt0"));
    data.dS = mxGetData(mxGetField(structure_name, 0, "dS"));
    data.tol = mxGetData(mxGetField(structure_name, 0, "tol"));   
    data.kmax = mxGetData(mxGetField(structure_name, 0, "kmax"));
    data.tensortype = mxGetData(mxGetField(structure_name, 0, "tensortype")); 
    data.ncyclharm = mxGetData(mxGetField(structure_name, 0, "ncyclharm")); 
    data.reflection = mxGetData(mxGetField(structure_name, 0, "reflection")); 
    data.rel_opt = mxGetData(mxGetField(structure_name, 0, "rel_opt")); 
    data.nperp = mxGetData(mxGetField(structure_name, 0, "nperp")); 
    data.pperpmax = mxGetData(mxGetField(structure_name, 0, "pperpmax")); 
    data.tau_lim = mxGetData(mxGetField(structure_name, 0, "tau_lim")); 
    data.kextra = mxGetData(mxGetField(structure_name, 0, "kextra"));
    
    return(data);
}


fluctparam_format load_fluct_param(structure_name)
mxArray *structure_name;
{
    fluctparam_format data;
       
    data.ns0 = mxGetData(mxGetField(structure_name, 0, "ns0"));
    data.xreset0 = mxGetData(mxGetField(structure_name, 0, "xreset0"));
    data.nkperproots = mxGetData(mxGetField(structure_name, 0, "nkperproots"));
    data.betagridsize = mxGetData(mxGetField(structure_name, 0, "betagridsize"));
    data.dtfac = mxGetData(mxGetField(structure_name, 0, "dtfac"));
    
    return(data);
}


fluctspectrum_format load_fluct_spectrum(structure_name)
mxArray *structure_name;
{
    fluctspectrum_format data;
   
    data.dfcl = mxGetData(mxGetField(structure_name, 0, "dfcl"));
    data.fnkperpspec = mxGetData(mxGetField(structure_name, 0, "fnkperpspec"));
    data.mffcl = mxGetData(mxGetField(structure_name, 0, "mffcl"));
    data.fbkperpspec = mxGetData(mxGetField(structure_name, 0, "fbkperpspec"));
    
    return(data);
} 


pp_1D_format load_profile_1D(structure_name,field_name)
mxArray *structure_name;
char *field_name;
{
    mxArray *tmp,*sub_tmp;
    pp_1D_format fit;
    
    tmp = mxGetField(structure_name, 0, field_name);  
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,0));
    if (mxIsStruct(sub_tmp)) {
        fit.form_f = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_f = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_f = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_f = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_f = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_f = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_f = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }

    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,1));
    if (mxIsStruct(sub_tmp)) {
        fit.form_dfdrho = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dfdrho = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dfdrho = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dfdrho = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dfdrho = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dfdrho = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dfdrho = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }

    return(fit);  
}

pp_2D_format load_grid_2D(structure_name,field_name)
mxArray *structure_name;
char *field_name;
{
    mxArray *tmp,*sub_tmp;
    pp_2D_format fit;

    tmp = mxGetField(structure_name, 0, field_name);  
    
    fit.n = mxGetData(mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,0)));
        
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,1));
    if (mxIsStruct(sub_tmp)) {
        fit.form_a0 = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_a0 = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_a0 = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_a0 = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_a0 = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_a0 = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_a0 = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,4));
    if (mxIsStruct(sub_tmp)) {
        fit.form_da0drho = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_da0drho = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_da0drho = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_da0drho = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_da0drho = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_da0drho = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_da0drho = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,2));
    if (mxIsStruct(sub_tmp)) {
        fit.form_an = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_an = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_an = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_an = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_an = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_an = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_an = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,5));
    if (mxIsStruct(sub_tmp)) {
        fit.form_dandrho = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dandrho = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dandrho = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dandrho = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dandrho = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dandrho = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dandrho = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,3));
    if (mxIsStruct(sub_tmp)) {
        fit.form_bn = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_bn = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_bn = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_bn = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_bn = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_bn = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_bn = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,6));
    if (mxIsStruct(sub_tmp)) {
        fit.form_dbndrho = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_dbndrho = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_dbndrho = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_dbndrho = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_dbndrho = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_dbndrho = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_dbndrho = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    return(fit);  
}
