#include <complex.h>
#include <math.h>
#include "mex.h"

struct polynomial_piecewise_0D {
    double  *data;
};

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
    mxChar  *form_d2fdrho2;
    double  *breaks_d2fdrho2;
    double  *coefs_d2fdrho2;
    double  *pieces_d2fdrho2;
    double  *order_d2fdrho2;
    double  *dim_d2fdrho2;
    mxChar  *orient_d2fdrho2;  
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
    double *d2TedY2;
    double *d2nedY2;
    double **d2zTidY2;
    double **d2znidY2;
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
	int *ne_nmodel;
    double **ne_model;
    double **ne_sigmar_max;
    double **ne_sigmar_hwhm;
    double **ne_sigmar_rho;
    double **ne_polmode;      
    double **ne_epsi_rho;      
    double **ne_epsi_theta;       
    double **ne_epsi_phi;       
    double **ne_lmin;      
    double **ne_mmin;    
    double **ne_nmin;    
    double **ne_lmax;      
    double **ne_mmax;    
    double **ne_nmax; 
    int **ne_nphase; 
	double **ne_phase;   
    int *B_nmodel;
	double **B_model;
    double **B_sigmar_max;
    double **B_sigmar_hwhm;
    double **B_sigmar_rho;
    double **B_polmode;      
    double **B_epsi_rho;      
    double **B_epsi_theta;       
    double **B_epsi_phi;       
    double **B_lmin;      
    double **B_mmin;    
    double **B_nmin;    
    double **B_lmax;      
    double **B_mmax;    
    double **B_nmax; 
    int **B_nphase;
	double **B_phase;    
};

struct distriparam {
    double *pn;
    int *npn;
    double *mhu;
    int *nmhu;
    double *ne_ref;
    double *betath_ref;
};

typedef struct polynomial_piecewise_0D pp_0D_format;
typedef struct polynomial_piecewise_1D pp_1D_format;
typedef struct polynomial_piecewise_2D pp_2D_format;
typedef struct rayparam rayparam_format;
typedef struct equilparam equilparam_format;
typedef struct fluctparam fluctparam_format;
typedef struct rayprofiles rayprofiles_format;
typedef struct distriparam distriparam_format;

int strcmp();

distriparam_format load_distri_param(structure_name)
mxArray *structure_name;
{
    distriparam_format data;
   
    data.pn= mxGetData(mxGetField(structure_name, 0, "pn"));
    data.npn = mxCalloc(1,sizeof(int));
    data.npn[0] = fmax(mxGetM(mxGetField(structure_name, 0, "pn")),mxGetN(mxGetField(structure_name, 0, "pn")));
    data.mhu = mxGetData(mxGetField(structure_name, 0, "mhu"));
    data.nmhu = mxCalloc(1,sizeof(int));
    data.nmhu[0] = fmax(mxGetM(mxGetField(structure_name, 0, "mhu")),mxGetN(mxGetField(structure_name, 0, "mhu")));
    data.ne_ref = mxGetData(mxGetField(structure_name, 0, "ne_ref"));
    data.betath_ref = mxGetData(mxGetField(structure_name, 0, "betath_ref"));    
    return(data);
}



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

equilparam_format load_equil_param(structure_name)
mxArray *structure_name;
{
    equilparam_format data;
   
    data.zZi= mxGetData(mxGetField(structure_name, 0, "zZi"));
    data.zmi = mxGetData(mxGetField(structure_name, 0, "zmi"));
    data.ns = mxCalloc(1,sizeof(int));
    data.ns[0] = fmax(mxGetM(mxGetField(structure_name, 0, "zmi")),mxGetN(mxGetField(structure_name, 0, "zmi")));
    data.ap = mxGetData(mxGetField(structure_name, 0, "ap"));
    data.Rp = mxGetData(mxGetField(structure_name, 0, "Rp"));
    data.Zp = mxGetData(mxGetField(structure_name, 0, "Zp"));
    data.psia = mxGetData(mxGetField(structure_name, 0, "psia"));
    
    return(data);
}

fluctparam_format load_fluct_param(structure_name)
mxArray *structure_name;
{
    fluctparam_format data;
    int nss,iss,nfield,ifield;
    const char *fieldname;
    mxArray *tmp,*sub_tmp;	
    
	nfield = mxGetNumberOfFields(structure_name);
	
	if (nfield < 9) {
		mexPrintf("WARNING: There is no model of plasma fluctuations in the fluct_fit matlab structure !\n",nfield);
	} else {
        
        data.ne_nmodel = mxCalloc(1,sizeof(int));/* automatic set to zero by default */
        data.ne_nmodel[0] = 0;
        data.B_nmodel = mxCalloc(1,sizeof(int));/* automatic set to zero by default */
        data.B_nmodel[0] = 0;
        
    	for (ifield = 8; ifield < nfield; ifield++){
			tmp = mxGetFieldByNumber(structure_name, 0,ifield);
			if (mxIsStruct(tmp)) {
				fieldname = mxGetFieldNameByNumber(structure_name,ifield);	
				nss = fmax(mxGetDimensions(tmp)[0],mxGetDimensions(tmp)[1]);
				/*mexPrintf("Number of fieldname %s:%d\n",fieldname,nss);*/
				if (strcmp(fieldname,"ne_fit") == 0) {   
                    
                    data.ne_model = mxCalloc(nss,sizeof(double *));
                    data.ne_sigmar_max = mxCalloc(nss,sizeof(double *));
                    data.ne_sigmar_hwhm = mxCalloc(nss,sizeof(double *));
                    data.ne_sigmar_rho = mxCalloc(nss,sizeof(double *));
                    data.ne_polmode = mxCalloc(nss,sizeof(double *));
                    data.ne_epsi_rho = mxCalloc(nss,sizeof(double *)); 
                    data.ne_epsi_theta = mxCalloc(nss,sizeof(double *));
                    data.ne_epsi_phi = mxCalloc(nss,sizeof(double *));
                    data.ne_lmin = mxCalloc(nss,sizeof(double *));
                    data.ne_mmin = mxCalloc(nss,sizeof(double *));
                    data.ne_nmin = mxCalloc(nss,sizeof(double *));
                    data.ne_lmax = mxCalloc(nss,sizeof(double *));
                    data.ne_mmax = mxCalloc(nss,sizeof(double *));
                    data.ne_nmax = mxCalloc(nss,sizeof(double *));
                    data.ne_nphase = mxCalloc(nss,sizeof(int *));
                    
                    for (iss = 0;iss < nss; iss++) {
                        data.ne_model[iss] = mxCalloc(1,sizeof(double));
                        data.ne_sigmar_max[iss] = mxCalloc(1,sizeof(double));
                        data.ne_sigmar_hwhm[iss] = mxCalloc(1,sizeof(double));
                        data.ne_sigmar_rho[iss] = mxCalloc(1,sizeof(double));
                        data.ne_polmode[iss] = mxCalloc(1,sizeof(double));
                        data.ne_epsi_rho[iss] = mxCalloc(1,sizeof(double)); 
                        data.ne_epsi_theta[iss] = mxCalloc(1,sizeof(double));
                        data.ne_epsi_phi[iss] = mxCalloc(1,sizeof(double));
                        data.ne_lmin[iss] = mxCalloc(1,sizeof(double));
                        data.ne_mmin[iss] = mxCalloc(1,sizeof(double));
                        data.ne_nmin[iss] = mxCalloc(1,sizeof(double));
                        data.ne_lmax[iss] = mxCalloc(1,sizeof(double));
                        data.ne_mmax[iss] = mxCalloc(1,sizeof(double));
                        data.ne_nmax[iss] = mxCalloc(1,sizeof(double));
                        data.ne_nphase[iss] = mxCalloc(1,sizeof(int));        
                    }	                    
                    
                    data.ne_nmodel[0] = nss;
                    
                    for (iss = 0; iss < nss; iss++){
                        data.ne_model[iss] = mxGetData(mxGetField(tmp, iss, "model"));
                        data.ne_sigmar_max[iss] = mxGetData(mxGetField(tmp, iss, "sigmar_max"));
                        data.ne_sigmar_hwhm[iss] = mxGetData(mxGetField(tmp, iss, "sigmar_hwhm"));
                        data.ne_sigmar_rho[iss] = mxGetData(mxGetField(tmp, iss, "sigmar_rho"));
                        data.ne_polmode[iss] = mxGetData(mxGetField(tmp, iss, "polmode"));                        
                        data.ne_epsi_rho[iss] = mxGetData(mxGetField(tmp, iss, "epsi_rho"));  
                        data.ne_epsi_theta[iss] = mxGetData(mxGetField(tmp, iss, "epsi_theta"));  
                        data.ne_epsi_phi[iss] = mxGetData(mxGetField(tmp, iss, "epsi_phi"));  
                        data.ne_lmin[iss] = mxGetData(mxGetField(tmp, iss, "lmin"));
                        data.ne_mmin[iss] = mxGetData(mxGetField(tmp, iss, "mmin"));
                        data.ne_nmin[iss] = mxGetData(mxGetField(tmp, iss, "nmin"));
                        data.ne_lmax[iss] = mxGetData(mxGetField(tmp, iss, "lmax"));
                        data.ne_mmax[iss] = mxGetData(mxGetField(tmp, iss, "mmax"));
                        data.ne_nmax[iss] = mxGetData(mxGetField(tmp, iss, "nmax"));                        
                        
                        sub_tmp = mxGetField(tmp, iss, "phase");
                        data.ne_nphase[iss][0] = fmax(mxGetDimensions(sub_tmp)[0],mxGetDimensions(sub_tmp)[1]);
                        
                    }                    
                    
                    data.ne_phase = mxCalloc(nss,sizeof(double *));
		
                    for (iss = 0;iss < nss; iss++) {
                        data.ne_phase[iss] = mxCalloc(data.ne_nphase[iss][0],sizeof(double));  
                    }	
                    
                    for (iss = 0; iss < nss; iss++){
                        data.ne_phase[iss] = mxGetData(mxGetField(tmp, iss, "phase"));
                    }    
                }
                
                if (strcmp(fieldname,"B_fit") == 0) {     
                    
                    data.B_model = mxCalloc(nss,sizeof(double *));
                    data.B_sigmar_max = mxCalloc(nss,sizeof(double *));
                    data.B_sigmar_hwhm = mxCalloc(nss,sizeof(double *));
                    data.B_sigmar_rho = mxCalloc(nss,sizeof(double *));
                    data.B_polmode = mxCalloc(nss,sizeof(double *));
                    data.B_epsi_rho = mxCalloc(nss,sizeof(double *)); 
                    data.B_epsi_theta = mxCalloc(nss,sizeof(double *));
                    data.B_epsi_phi = mxCalloc(nss,sizeof(double *));
                    data.B_lmin = mxCalloc(nss,sizeof(double *));
                    data.B_mmin = mxCalloc(nss,sizeof(double *));
                    data.B_nmin = mxCalloc(nss,sizeof(double *));
                    data.B_lmax = mxCalloc(nss,sizeof(double *));
                    data.B_mmax = mxCalloc(nss,sizeof(double *));
                    data.B_nmax = mxCalloc(nss,sizeof(double *));
                    data.B_nphase = mxCalloc(nss,sizeof(int *)); 
                    
                    for (iss = 0;iss < nss; iss++) {
                        data.B_model[iss] = mxCalloc(1,sizeof(double));
                        data.B_sigmar_max[iss] = mxCalloc(1,sizeof(double));
                        data.B_sigmar_hwhm[iss] = mxCalloc(1,sizeof(double));
                        data.B_sigmar_rho[iss] = mxCalloc(1,sizeof(double));
                        data.B_polmode[iss] = mxCalloc(1,sizeof(double));
                        data.B_epsi_rho[iss] = mxCalloc(1,sizeof(double)); 
                        data.B_epsi_theta[iss] = mxCalloc(1,sizeof(double));
                        data.B_epsi_phi[iss] = mxCalloc(1,sizeof(double));
                        data.B_lmin[iss] = mxCalloc(1,sizeof(double));
                        data.B_mmin[iss] = mxCalloc(1,sizeof(double));
                        data.B_nmin[iss] = mxCalloc(1,sizeof(double));
                        data.B_lmax[iss] = mxCalloc(1,sizeof(double));
                        data.B_mmax[iss] = mxCalloc(1,sizeof(double));
                        data.B_nmax[iss] = mxCalloc(1,sizeof(double));
                        data.B_nphase[iss] = mxCalloc(1,sizeof(int));
                    }	                    
                    
                    data.B_nmodel[0] = nss;
                    
                    for (iss = 0; iss < nss; iss++){
                        data.B_model[iss] = mxGetData(mxGetField(tmp, iss, "model"));
                        data.B_sigmar_max[iss] = mxGetData(mxGetField(tmp, iss, "sigmar_max"));
                        data.B_sigmar_hwhm[iss] = mxGetData(mxGetField(tmp, iss, "sigmar_hwhm"));
                        data.B_sigmar_rho[iss] = mxGetData(mxGetField(tmp, iss, "sigmar_rho"));
                        data.B_polmode[iss] = mxGetData(mxGetField(tmp, iss, "polmode"));                        
                        data.B_epsi_rho[iss] = mxGetData(mxGetField(tmp, iss, "epsi_rho"));  
                        data.B_epsi_theta[iss] = mxGetData(mxGetField(tmp, iss, "epsi_theta"));  
                        data.B_epsi_phi[iss] = mxGetData(mxGetField(tmp, iss, "epsi_phi"));  
                        data.B_lmin[iss] = mxGetData(mxGetField(tmp, iss, "lmin"));
                        data.B_mmin[iss] = mxGetData(mxGetField(tmp, iss, "mmin"));
                        data.B_nmin[iss] = mxGetData(mxGetField(tmp, iss, "nmin"));
                        data.B_lmax[iss] = mxGetData(mxGetField(tmp, iss, "lmax"));
                        data.B_mmax[iss] = mxGetData(mxGetField(tmp, iss, "mmax"));
                        data.B_nmax[iss] = mxGetData(mxGetField(tmp, iss, "nmax"));
                        
                        sub_tmp = mxGetField(tmp, iss, "phase");
                        data.B_nphase[iss][0] = fmax(mxGetDimensions(sub_tmp)[0],mxGetDimensions(sub_tmp)[1]);
                    }                    
                    
                    data.B_phase = mxCalloc(nss,sizeof(double *));
		
                    for (iss = 0;iss < nss; iss++) {
                        data.B_phase[iss] = mxCalloc(data.B_nphase[iss][0],sizeof(double));  
                    }	
                    
                    for (iss = 0; iss < nss; iss++){
                        data.B_phase[iss] = mxGetData(mxGetField(tmp, iss, "phase"));
                    }    
                }   
                
			} else {
				/*mexPrintf("WARNING: The type of field %d in fluct_fit MatLab structure is inconsistent !\n",ifield);*/
			}
    	}		  	
    }
    
    return(data);
}

pp_0D_format load_value_0D(structure_name,field_name)
mxArray *structure_name;
char *field_name;
{
    mxArray *tmp;
    pp_0D_format fit;
 
    fit.data = mxGetData(mxGetField(structure_name, 0, field_name));
 
    return(fit);  
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

    sub_tmp = mxGetField(tmp, 0, mxGetFieldNameByNumber(tmp,2));
    if (mxIsStruct(sub_tmp)) {
        fit.form_d2fdrho2 = mxGetChars(mxGetField(sub_tmp, 0, "form"));  
        fit.breaks_d2fdrho2 = mxGetData(mxGetField(sub_tmp, 0, "breaks"));
        fit.coefs_d2fdrho2 = mxGetData(mxGetField(sub_tmp, 0, "coefs"));
        fit.pieces_d2fdrho2 = mxGetData(mxGetField(sub_tmp, 0, "pieces"));
        fit.order_d2fdrho2 = mxGetData(mxGetField(sub_tmp, 0, "order"));
        fit.dim_d2fdrho2 = mxGetData(mxGetField(sub_tmp, 0, "dim"));
        fit.orient_d2fdrho2 = mxGetChars(mxGetField(sub_tmp, 0, "orient"));
    }
    
    return(fit);  
}

pp_2D_format load_grid_2D(structure_name,field_name,is)
mxArray *structure_name;
char *field_name;
int is;
{
    mxArray *tmp,*sub_tmp;
    pp_2D_format fit;

    tmp = mxGetField(structure_name, is, field_name);  
    
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

