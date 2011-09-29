#include <complex.h>
#include <math.h>
#include "mex.h"

struct distriparam {
    double *pn;
    double *ksi0;
    int *rhon;
};

typedef struct distriparam distriparam_format;

distriparam_format load_f0(structure_name) 
mxArray *structure_name;
{
	distriparam_format data;
   /* data.pn = mxGetData(mxGetField(structure_name, 0, "pn"));
    data.ksi0 = mxGetData(mxGetField(structure_name, 0, "ksi0"));
    data.rho = mxGetData(mxGetField(structure_name, 0, "xrho"));*/
    
    
    return(data);
}
