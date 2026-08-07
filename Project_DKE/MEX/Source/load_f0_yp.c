// /////////////////////////////////////////
//
// Software name : LUKE
//
// Authors : Yves Savoye-Peysson and Joan Decker
//
// Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
//
// CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
//
// The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
//
// /////////////////////////////////////////
//
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
