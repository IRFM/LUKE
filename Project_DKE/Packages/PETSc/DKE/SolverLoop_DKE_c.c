static char help[] = "Solver loop";
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Fokker-Planck_DKE_loop.h"
#include "petscksp.h"

int main(int argc, char **args){
PetscErrorCode ierr;
 ierr=PetscInitialize(&argc,&args,(char *)0,help);CHKERRQ(ierr);
DOUBLE Pi=4.0*atan(1.0);
int it_f,ir;
int i,j,k;
int sizeZmask;
/*                                     */

/*Intermediate variables*/
struct Tensor A;
int *sdim;
struct Tensor normf0,normf1,curr0,curr1,prec_curr,prec_normf,residu_f,prec_residu_f;
struct Tensor XI;
struct Tensor SXXf0,SXXf02,SXXsinksource2,SXXfM,SXXRlambda_b_p1p1,SXXfinit;
struct Tensor MMXq_t,MMXR_t;
struct Tensor BT,BP,BR;
struct Tensor B,C,D;
double sum1=0.0,sum4=0.0;
int sum2=0,sum3=0;
struct Tensor timescheme;
struct IntTensor *pnr,*psm_f,*pnmhu,*pns_f,*pnpn;
double *xvals;
struct Tensor MMXS_t;
int i0,j0,k0;
/*INPUT FOR LOOP=============================*/
struct Tensor XXsinksource,Xmask_r_edge;
struct Tensor Xmask_r_edge_t; 
struct Tensor Xmhu;
struct Tensor Xpn2;
struct SparseMatrix MMXT_f_t,MMXR_f_t,MMXP_f_t,MMXPC_f_t,MMXPDI_f_t;
struct Tensor MMXf1_t;
struct Tensor Xf1_t;
struct Tensor XXf0,XXI,XXfM,XXRlambda_b_p1p1,XXfinit;
struct IntTensor *Zmask_f0_t;
struct Tensor* Zpn2_t;
struct Tensor dmhu;
struct Tensor dtn;
struct Tensor mhu;
struct IntTensor *pnit_f;
struct IntTensor* pboundary_mode_f;
struct IntTensor* pbounce_mode;
struct IntTensor* pcoll_mode;
struct IntTensor* pnorm_mode_f;
struct Tensor pprec0_f;
struct IntTensor* pdisplay_mode;


/*printf("READING INPUT VARIABLES\n");*/
/*fprintf(stdout,"Read nmhu\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/nmhu",&pnmhu);
int nmhu=(*pnmhu).vals[0];
/*fprintf(stdout,"Read npn\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/npn",&pnpn);
int npn=(*pnpn).vals[0];
/*fprintf(stdout,"Read ns_f\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/ns_f",&(pns_f));
int* ns_f=(*pns_f).vals;
/*fprintf(stdout,"Read nr\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/nr",&(pnr));
int nr=(*pnr).vals[0];
/*fprintf(stdout,"Read sm_f\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/sm_f",&(psm_f));
int* sm_f=(*psm_f).vals;
/*fprintf(stdout,"Read time_scheme\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/time_scheme",&timescheme);
double time_scheme=timescheme.vals[0];
/*fprintf(stdout,"Read dtn\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/dtn",&(dtn));
/*fprintf(stdout,"Read mhu\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/mhu",&mhu);

/*fprintf(stdout,"Read nit_f\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/nit_f",&(pnit_f));
int nit_f=(*pnit_f).vals[0];
/*fprintf(stdout,"Read boundary_mode_f\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/boundary_mode_f",&pboundary_mode_f);
int boundary_mode_f=(*pboundary_mode_f).vals[0];
/*fprintf(stdout,"Read bounce_mode\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/bounce_mode",&pbounce_mode);
int bounce_mode=(*pbounce_mode).vals[0];
/*fprintf(stdout,"Read coll_mode\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/coll_mode",&pcoll_mode);
int coll_mode=(*pcoll_mode).vals[0];
/*fprintf(stdout,"Read norm_mode_f\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/norm_mode_f",&pnorm_mode_f);
int norm_mode_f=(*pnorm_mode_f).vals[0];
/*fprintf(stdout,"Read prec0_f\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/prec0_f",&pprec0_f);
/*printf("prec0=%i\n",(pprec0_f).ndims);*/
double prec0_f=(pprec0_f).vals[0];
/*fprintf(stdout,"Read display_mode\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/display_mode",&pdisplay_mode);
int display_mode=(*pdisplay_mode).vals[0];


/*fprintf(stdout,"Read Xmhu\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/Xmhu",&Xmhu);
/*fprintf(stdout,"Read XXsinksource\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/XXsinksource",&XXsinksource);
/*fprintf(stdout,"Read Xmask_r_edge\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/Xmask_r_edge",&Xmask_r_edge);
/*fprintf(stdout,"Read Xpn2\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/Xpn2",&Xpn2);
/*fprintf(stdout,"Read XXI\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/XXI",&XXI);
/*fprintf(stdout,"Read XXfM\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/XXfM",&XXfM);
/*fprintf(stdout,"Read XXRlambda_b_p1p1\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/XXRlambda_b_p1p1",&XXRlambda_b_p1p1);
/*fprintf(stdout,"Read XXfinit\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/XXfinit",&XXfinit);
 /*MMXT_f_t,MMXR_f_t,MMXP_f_t  must be read from sparse format*/
/*fprintf(stdout,"Read MMXT_f_t\n");*/ReadBinarySparseMatrix_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/MMXT_f_t",&MMXT_f_t);
/*fprintf(stdout,"Read MMXR_f_t\n");*/ReadBinarySparseMatrix_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/MMXR_f_t",&MMXR_f_t);
/*fprintf(stdout,"Read MMXP_f_t\n");*/ReadBinarySparseMatrix_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/MMXP_f_t",&MMXP_f_t);
/*fprintf(stdout,"ReadMMXPC_f_t\n");*/ReadBinarySparseMatrix_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/MMXPC_f_t",&MMXPC_f_t);
/*fprintf(stdout,"ReadMMXPDI_f_t\n");*/ReadBinarySparseMatrix_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/MMXPDI_f_t",&MMXPDI_f_t);

/*fprintf(stdout,"Read Zmask_f0_t\n");*/ReadBinaryIntArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/Zmask_f0_t",&Zmask_f0_t);

/*fprintf(stdout,"ReadZpn2_t\n");*/ReadBinaryArray_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/Zpn2_t",&Zpn2_t);

/*fprintf(stdout,"Read dmhu\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/dmhu",&dmhu);

/*Need to initialize the following variables*/
/*fprintf(stdout,"Read XXf0\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/XXf0",&XXf0);

/*===========================================*/



/*INPUT FOR firstordercoolop_dke_ft============================================*/

struct Tensor f1;
struct Tensor betath_ref;
struct Tensor masku,maskl; 
struct Tensor dpn; 
struct Tensor xpn, xpn2,xpn3,xsigma,xgamma;
struct Tensor xz, xz2;
struct Tensor pn,pn2 ,pn3; 
struct Tensor sigma,gamma;
struct Tensor z,z2;
struct Tensor xJ1,xJ2,xJ3,xJ4;
struct Tensor J1,J2,J3,J4;
struct Tensor xTe_norm,xTe_normir,xne_norm;

/*OUTPUT FOR firstordercollop_dke_ft==============================================*/

struct Tensor I1,I2;

/*=============================================================================*/

/*READING VARIABLES FOR firstordercollop_dke_ft*/

/*fprintf(stdout,"Readf1\n");*//*ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/f1",&f1);*/
/*fprintf(stdout,"Read dpn\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/dpn",&dpn);
/*fprintf(stdout,"Read xpn\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xpn",&xpn);
/*fprintf(stdout,"Read xpn2\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xpn2",&xpn2);
/*fprintf(stdout,"Read xpn3\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xpn3",&xpn3);
/*fprintf(stdout,"Read masku\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/masku",&masku);
/*fprintf(stdout,"Read maskl\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/maskl",&maskl);
/*fprintf(stdout,"Read xgamma\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xgamma",&xgamma);
/*fprintf(stdout,"Read xsigma\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xsigma",&xsigma);
/*fprintf(stdout,"Read xz\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xz",&xz);
/*fprintf(stdout,"Read xz2\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xz2",&xz2);
/*fprintf(stdout,"Read pn\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/pn",&pn);
/*fprintf(stdout,"Read pn2\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/pn2",&pn2);
/*fprintf(stdout,"Read pn3\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/pn3",&pn3);
/*fprintf(stdout,"Read gamma\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/gamma",&gamma);
/*fprintf(stdout,"Read sigma\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/sigma",&sigma);
/*fprintf(stdout,"Read z\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/z",&z);
/*fprintf(stdout,"Read z2\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/z2",&z2);
/*fprintf(stdout,"Read xJ1\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xJ1",&xJ1);
/*fprintf(stdout,"Read xJ2\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xJ2",&xJ2);
/*fprintf(stdout,"Read xJ3\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xJ3",&xJ3);
/*fprintf(stdout,"Read xJ4\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xJ4",&xJ4);
/*fprintf(stdout,"Read J1\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/J1",&J1);
/*fprintf(stdout,"Read J2\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/J2",&J2);
/*fprintf(stdout,"Read J3\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/J3",&J3);
/*fprintf(stdout,"Read J4\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/J4",&J4);
/*fprintf(stdout,"Read xne_norm\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xne_norm",&xne_norm);
/*fprintf(stdout,"Read xTe_norm\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/xTe_norm",&xTe_norm);
/*fprintf(stdout,"Read betath_ref\n");*/ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/betath_ref",&betath_ref);
/*printf("END READ\n");*/
/*END READ*/

sdim=malloc(2*sizeof(int));
/*Intermediate variables*/
struct Tensor XI_t,MMXf0_t,MMXsource_t,MMXIpn2_t,Xf1;
int sizeMMX;
/*                      */

/*printf("INITIALIZING VARIABLES\n");*/
/*Begin Fokker_Planck solver loop*/

sdim[0]=nr;
sdim[1]=nit_f+1;
Tensor_Create(2,sdim,&normf0);
Tensor_Create(2,sdim,&normf1);
Tensor_Create(2,sdim,&curr0);
Tensor_Create(2,sdim,&curr1);
Tensor_Create(2,sdim,&prec_curr);
Tensor_Create(2,sdim,&prec_normf);
Tensor_Create(2,sdim,&residu_f);
Tensor_Create(2,sdim,&prec_residu_f);
Tensor_Fill(&normf0,0.0);
Tensor_Fill(&normf1,0.0);
Tensor_Fill(&curr0,0.0);
Tensor_Fill(&curr1,0.0);
Tensor_Fill(&prec_curr,0.0);
Tensor_Fill(&prec_normf,0.0);
Tensor_Fill(&residu_f,1.0);
Tensor_Fill(&prec_residu_f,1.0);
Tensor_Save("normf1",normf1);
for(ir=0;ir<nr;ir++){
        sdim[0]=XXf0.sizedim[0];
	sdim[1]=XXf0.sizedim[1];
	Tensor_Create(2,sdim,&SXXfinit);
	/*printf("XXfinitsize=%i\n",XXfinit.size);*/
	for(i=0;i<SXXfinit.size;i++){	
	   SXXfinit.vals[i]=XXfinit.vals[i+ir*XXfinit.sizedim[0]*XXfinit.sizedim[1]];
	}
	/*printf("dmhudims=%i %i\n",dmhu.sizedim[0],dmhu.sizedim[1]);	*/
	integral_dke_jd(dmhu,SXXfinit,2,&B);
	/*printf("SXXfinit=%i %i\n",SXXfinit.sizedim[0],SXXf0.sizedim[1]);
	printf("Bdims=%i %i\n",B.sizedim[0],B.sizedim[1]);*/
	/*fprintf(stdout,"Read pn2\n");ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/pn2",&pn2);*/
	/*printf("pn2dims=%i %i\n",pn2.sizedim[0],pn2.sizedim[1]);*/
	product(pn2,B,&B);
	/*printf("Bdims=%i %i\n",B.sizedim[0],B.sizedim[1]);*/
	Tensor_Transpose(&B);
	integral_dke_jd(dpn,B,1,&C);
        normf0.vals[ir+0*normf0.sizedim[0]]=2*Pi*C.vals[0];
	product(Xmhu,SXXfinit,&B);
	integral_dke_jd(dmhu,B,2,&C);
	product(C,pn,&C);
	product(C,pn2,&C);
	division(C,gamma,&C);
	Tensor_Transpose(&C);
	integral_dke_jd(dpn,C,1,&D);	       
        curr0.vals[ir+0*curr0.sizedim[0]]=2.0*Pi*D.vals[0]*xne_norm.vals[ir]/normf0.vals[ir+normf0.sizedim[0]*0];

}
/* printf("END INITIALIZATION\n");*/

/*PETSC variables*/
Vec x,b;
PetscInt low,high;
PetscInt* ix;
DOUBLE * y;
Mat PMMXPC_f_t;
KSP ksp;
PC pc;
PetscTruth flg;
PetscViewer fd;
VecScatter vecscat;
Vec xseq;

/*               */

/*Initialize PETSc environment*/
/*                            */

/* printf("SETTING UP PETSc OBJECTS\n");*/
/*LOAD SYSTEM MATRIX AS PETSC OBJECT MAT*/
ierr=PetscViewerBinaryOpen(PETSC_COMM_WORLD,"/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/PMMXPC_f_t",FILE_MODE_READ,&fd);CHKERRQ(ierr);
ierr = MatLoad(fd,MATAIJ,&PMMXPC_f_t);CHKERRQ(ierr);
if (flg){ierr = PetscViewerDestroy(fd);CHKERRQ(ierr);}
ierr=KSPCreate(PETSC_COMM_WORLD,&ksp);CHKERRQ(ierr);
  ierr=KSPSetOperators(ksp,PMMXPC_f_t,PMMXPC_f_t,SAME_PRECONDITIONER);CHKERRQ(ierr);

  ierr=KSPSetFromOptions(ksp);CHKERRQ(ierr);
  ierr=KSPGetPC(ksp,&pc);CHKERRQ(ierr);
  ierr=PCSetFromOptions(pc);CHKERRQ(ierr);
  ierr=KSPSetOperators(ksp,PMMXPC_f_t,PMMXPC_f_t,SAME_PRECONDITIONER);CHKERRQ(ierr);

/* printf("END SETUP\n");*/

/*nit_f=3;*/
/* printf("BEGIN LOOP\n");*/
for(it_f=1;it_f<=nit_f;it_f++){
    /*Control iterations depending on error. ADD CONDITIONS OVER NORM */
  
  sum3=0;
  sum4=0.0; 
  for(i=0;i<residu_f.sizedim[0];i++){
  sum3+=(residu_f.vals[i+(it_f-1)*residu_f.sizedim[0]]>=prec0_f);
  sum4+=(prec_residu_f.vals[i+(it_f-1)*prec_residu_f.sizedim[0]]);
  }
  
    if(sum3>=1 /*&& sum4 >=1.0*//*convergence condition*/)
{
      /*  printf("RHS COMPUTATION\n");*/
       /*fprintf(stdout,"nrvals=%i\n",nr);*/
       /*Allocation for MMXf0_t,MMXsource_t,MMXIpn2_t*/
       sizeMMX=0;
       for(ir=0;ir<nr;ir++){
       sizeMMX+=(nmhu-ns_f[ir])*npn;
       }
       sdim[0]=1;
       sdim[1]=sizeMMX;
       Tensor_Create(2,sdim,&MMXf0_t);       
       Tensor_Create(2,sdim,&MMXsource_t);       
       Tensor_Create(2,sdim,&MMXIpn2_t);
  
    /*   
                                            */
					    
       i0=0;
       j0=0;	
       k0=0;			    
       for(ir=0;ir<nr-1;ir++){	
          sizeZmask=0;
          for(i=0;i<Zmask_f0_t[ir].size;i++){
	     sizeZmask+=Zmask_f0_t[ir].vals[i]; /*Size of submatrices SXXf0 and SXXsinksource*/
	  }
	  

          /*Computation of XI_t*/
	  sdim[0]=XXI.sizedim[0];
          sdim[1]=sizeZmask;
	  /*sdim[1]=(Zmask_f0_t[ir]).sizedim[1];*/
	  Tensor_Create(2,sdim,&XI_t);	  
	  
	  j=0;
	  for(k=0;k<Zmask_f0_t[ir].size;k++){
	     if(Zmask_f0_t[ir].vals[k]==1){
	        for(i=0;i<XI_t.sizedim[0];i++){                  
XI_t.vals[i+j*XI_t.sizedim[0]]=XXI.vals[i+k*XXI.sizedim[0]+ir*XXI.sizedim[0]*XXI.sizedim[1]];
                }
                j++;
	     }
          } 
          /*for(i=0;i<XI_t.sizedim[0];i++){
              for(j=0;j<XI_t.sizedim[1];j++){k=j;
	         while(Zmask_f0_t[ir].vals[k]==0 && k<Zmask_f0_t[ir].size){ 
		          k++;
		       }		       
                       XI_t.vals[i+j*XI_t.sizedim[0]]=XXI.vals[i+k*XXI.sizedim[0]+ir*XXI.sizedim[0]*XXI.sizedim[1]];
	      }
           }*/
           /*printf("XI_t done\n");*/
	   if(boundary_mode_f>0){
              for(i=0;i<boundary_mode_f;i++){
                 for(j=0;j<XI_t.sizedim[1];j++){
                    XI_t.vals[i+XI_t.sizedim[0]*j]=0.0;
                 }
               }
	    }
    /*Computation of MMXf0_t, MMXq_t,MMXIpn2_t)*/
           /*printf("SXXf02\n");*/
	   sdim[0]=XXf0.sizedim[0];
	   sdim[1]=sizeZmask; /*Zmask_f0_t[ir] are vectors*/
	   Tensor_Create(2,sdim,&SXXf02);
	   j=0;
	   for(k=0;k<Zmask_f0_t[ir].size;k++){
	     if(Zmask_f0_t[ir].vals[k]==1){
	        for(i=0;i<SXXf02.sizedim[0];i++){
                  
SXXf02.vals[i+j*SXXf02.sizedim[0]]=XXf0.vals[i+k*XXf0.sizedim[0]+ir*XXf0.sizedim[0]*XXf0.sizedim[1]];
                }
                j++;
	     }
          }
	   
	   /*printf("SXXf02 done\n");*/
	  
/*Tensor_Save("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_output/SXXf02",SXXf02);*/
	   
           Tensor_Transpose(&SXXf02);
	  
	  for(i=0;i<SXXf02.size;i++){
              MMXf0_t.vals[i+i0]=SXXf02.vals[i];
	  }  
	  
	  
	  free(SXXf02.vals);free(SXXf02.sizedim);
	   i0+=i;  
           
           sdim[0]=XXsinksource.sizedim[0];
	   sdim[1]=sizeZmask; /*Zmask_f0_t[ir] are vectors*/
	   Tensor_Create(2,sdim,&SXXsinksource2);
	   j=0;
	   for(k=0;k<Zmask_f0_t[ir].size;k++){
	     if(Zmask_f0_t[ir].vals[k]==1){
	        for(i=0;i<SXXsinksource2.sizedim[0];i++){
                  
SXXsinksource2.vals[i+j*SXXsinksource2.sizedim[0]]=XXsinksource.vals[i+k*XXsinksource.sizedim[0]+ir*XXsinksource.sizedim[0]*XXsinksource.sizedim[1]];
                }
                j++;
	     }
          }   
          Tensor_Transpose(&SXXsinksource2);
	  
	  for(i=0;i<SXXsinksource2.size;i++){/*printf("i=%i,j=%i\n",i,j0);
	  printf("MMXsize=%i\n", MMXsource_t.size);*/
              MMXsource_t.vals[i+j0]=SXXsinksource2.vals[i];
	  } 
	  
	  free(SXXsinksource2.vals);free(SXXsinksource2.sizedim);
	   
	   j0+=i;  
	   
	  product(XI_t,Zpn2_t[ir],&A);
	  Tensor_Transpose(&A);	
	  /*fprintf(stdout,"MMXIpn2_t\n");  */
	  for(j=0;j<A.size;j++){	          		 
              /*MMXIpn2_t.vals[ir*A.size+j]=A.vals[j];*/
	      MMXIpn2_t.vals[j+k0]=A.vals[j];
	  }
	  
	  k0+=j;
	  
	  free(A.vals);free(A.sizedim);
	  free(XI_t.sizedim);free(XI_t.vals);
	  
	  
       }/*for(ir=0,....)*/    
          
       /*Scalar_Tensor_product(-1.0,XI_t,&XI_t);*/	/*Weird sign problem for XI_t*/
       		    
       if(1){/*isempty(Xmask_r_edge),No anomalous radial transport*/
          /*fprintf(stdout,"================================\n");*/
          sizeZmask=0;
          for(i=0;i<Zmask_f0_t[nr-1].size;i++){
	     sizeZmask+=Zmask_f0_t[nr-1].vals[i]; /*Size of submatrices SXXf0 and SXXsinksource*/
	  }
	  
       /*Computation of XI_t*/
	  sdim[0]=XXI.sizedim[0];
	  sdim[1]=sizeZmask;
	  Tensor_Create(2,sdim,&XI_t);
	   
	        j=0;
	  for(k=0;k<Zmask_f0_t[nr-1].size;k++){
	     if(Zmask_f0_t[nr-1].vals[k]==1){
	        for(i=0;i<XI_t.sizedim[0];i++){
                  
XI_t.vals[i+j*XI_t.sizedim[0]]=XXI.vals[i+k*XXI.sizedim[0]+(nr-1)*XXI.sizedim[0]*XXI.sizedim[1]];
                }
                j++;
	     }
          } 
		
                if(boundary_mode_f >0){
	           for(i=0;i<boundary_mode_f;i++){
	               for(j=0;j<XI_t.sizedim[1];j++){
	                   XI_t.vals[i+XI_t.sizedim[0]*j]=0.0;
	               }  
	           }
                }
	        
		Scalar_Tensor_product(-1.0,XI_t,&XI_t);/*Weird sign problem for XI_t*/
		
	   
	        sdim[0]=XXf0.sizedim[0];
	        sdim[1]=sizeZmask; /*Zmask_f0_t[nr-1] are vectors*/
	        Tensor_Create(2,sdim,&SXXf02);
	        j=0;
	   for(k=0;k<Zmask_f0_t[nr-1].size;k++){
	     if(Zmask_f0_t[nr-1].vals[k]==1){
	        for(i=0;i<SXXf02.sizedim[0];i++){
                  
SXXf02.vals[i+j*SXXf02.sizedim[0]]=XXf0.vals[i+k*XXf0.sizedim[0]+(nr-1)*XXf0.sizedim[0]*XXf0.sizedim[1]];
                }
                j++;
	     }
          }
		
	
                Tensor_Transpose(&SXXf02);
/*Tensor_Save("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_output/SXXf02test3",SXXf02);*/
			        
	        for(i=0;i<SXXf02.size;i++){
                    MMXf0_t.vals[i+i0]=SXXf02.vals[i];
		    
	        }  
	 
	        free(SXXf02.vals);free(SXXf02.sizedim);
	        i0+=i;  
		
               sdim[0]=XXsinksource.sizedim[0];
	       sdim[1]=sizeZmask; /*Zmask_f0_t[(nr-1)] are vectors*/
	       Tensor_Create(2,sdim,&SXXsinksource2);
	   
	     j=0;
	   for(k=0;k<Zmask_f0_t[nr-1].size;k++){
	     if(Zmask_f0_t[nr-1].vals[k]==1){
	        for(i=0;i<SXXsinksource2.sizedim[0];i++){
                  
SXXsinksource2.vals[i+j*SXXsinksource2.sizedim[0]]=XXsinksource.vals[i+k*XXsinksource.sizedim[0]+(nr-1)*XXsinksource.sizedim[0]*XXsinksource.sizedim[1]];
                }
                j++;
	     }
          }
	       /*Tensor_Save("SXXsinksource2test",SXXsinksource2);*/
               Tensor_Transpose(&SXXsinksource2);
	  
	       for(i=0;i<SXXsinksource2.size;i++){
                  MMXsource_t.vals[i+j0]=SXXsinksource2.vals[i];
	       }  
	  
	       free(SXXsinksource2.vals);free(SXXsinksource2.sizedim);
	   
	       j0+=i; 
	       /*Tensor_Save("Zpn2",Zpn2_t[(nr-1)]);*/	       
	       product(XI_t,Zpn2_t[(nr-1)],&A);
	       Tensor_Transpose(&A);	
	       for(j=0;j<A.size;j++){	          		 
                  /*MMXIpn2_t.vals[(nr-1)*A.size+j]=A.vals[j];*/
		  MMXIpn2_t.vals[j+k0]=A.vals[j];
	       } 
	       k0+=j;
	       free(A.vals);free(A.sizedim);

		
      /*printf("done");*/
/* printf("MMXf0.size1=%i =========================================\n",MMXf0_t.size);      
printf("MMXsource.size=%i=========================================\n",MMXsource_t.size);
  */  

  }/*end if(1)*/
       
       else {
      /*    fprintf(stdout,"else\n");*/
       
          /*Declaration and allocation of Xmask_r_edge_t*/      
          sdim[0]=Xmask_r_edge.sizedim[0];
		  /*YP error ?????**********************/
		  /*sdim[1]==Zmask_f0_t[nr-1].size;*/
          sdim[1]=Zmask_f0_t[nr-1].size;
		  /*YP error ?????**********************/
          Tensor_Create(2,sdim,&Xmask_r_edge_t);
       
           sdim[0]=XXf0.sizedim[0];
	   sdim[1]=Zmask_f0_t[nr-1].size; /*Zmask_f0_t[nr-1] are vectors*/
	   Tensor_Create(2,sdim,&SXXf02);
	   for(i=0;i<XXf0.sizedim[0];i++){
               for(j=0;j<Zmask_f0_t[nr-1].size;j++){	                     
                   SXXf02.vals[i+j*SXXf02.sizedim[0]]=XXf0.vals[i+Zmask_f0_t[nr-1].vals[j]*XXf0.sizedim[0]+(nr-1)*XXf0.sizedim[0]*XXf0.sizedim[1]];
	       }
	   }
	   
           Tensor_Transpose(&SXXf02);
	  
	   for(i=0;i<SXXf02.size;i++){
               MMXf0_t.vals[i+i0]=SXXf02.vals[i];
	   }  

	   free(SXXf02.vals);free(SXXf02.sizedim);
	   i0+=i;  
	   
           sdim[0]=XXsinksource.sizedim[0];
	   sdim[1]=Zmask_f0_t[(nr-1)].size; /*Zmask_f0_t[(nr-1)] are vectors*/
	   Tensor_Create(2,sdim,&SXXsinksource2);
	   
	   for(i=0;i<XXsinksource.sizedim[0];i++){
               for(j=0;j<Zmask_f0_t[(nr-1)].size;j++){	     
                   SXXsinksource2.vals[i+j*SXXsinksource2.sizedim[0]]=XXsinksource.vals[i+Zmask_f0_t[(nr-1)].vals[j]*XXsinksource.sizedim[0]+(nr-1)*XXsinksource.sizedim[0]*XXsinksource.sizedim[1]];
	       }
	   }	   
           Tensor_Transpose(&SXXsinksource2);
	  
	   for(i=0;i<SXXsinksource2.size;i++){
               MMXsource_t.vals[i+j0]=SXXsinksource2.vals[i];
	   }  
	  
	   free(SXXsinksource2.vals);free(SXXsinksource2.sizedim);
	   
	   j0+=i;  	   
	   product(XI_t,Zpn2_t[(nr-1)],&A);
	   Tensor_Transpose(&A);	
	   /*fprintf(stdout,"MMXIpn2_t\n");*/  
	   for(j=0;j<A.size;j++){	          		 
               MMXIpn2_t.vals[(nr-1)*A.size+j]=A.vals[j];
	   } 
	   free(A.vals);free(A.sizedim);
	  
           for(i=0;i<Xmask_r_edge.sizedim[0];i++){
               for(j=0;j<Zmask_f0_t[nr-1].size;j++){	       
                   Xmask_r_edge_t.vals[i+j*Xmask_r_edge_t.sizedim[0]]=
		   Xmask_r_edge.vals[i+Xmask_r_edge.sizedim[0]*Zmask_f0_t[nr-1].vals[j]];
	       }
	   }
	}
       
     
 /*SAVES===================================================================*/

/*Tensor_Save("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_output/XI_t_test",XI_t);
Tensor_Save("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_output/MMXf0_t_test",MMXf0_t);
Tensor_Save("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_output/MMXsource_t_test",MMXsource_t);
Tensor_Save("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_output/MMXIpn2_t_test",MMXIpn2_t);*/

 /*Tensor_Save("XI_t_test",XI_t);
 Tensor_Save("MMXf0_t_test",MMXf0_t);
 Tensor_Save("MMXsource_t_test",MMXsource_t);
 Tensor_Save("MMXIpn2_t_test",MMXIpn2_t);*/
 /*=========================================================================*/    
     
     /*printf("Multiplication");*/
	
  /*Computation of MMXq_t*/
	SparseMat_Tensorproduct(MMXT_f_t,MMXf0_t,&BT);
	SparseMat_Tensorproduct(MMXP_f_t,MMXf0_t,&BP);
	SparseMat_Tensorproduct(MMXR_f_t,MMXf0_t,&BR);
	Tensor_Sum(BT,BP,-(time_scheme-1.0)/time_scheme,&MMXq_t);
	Tensor_Sum(MMXq_t,BR,-(time_scheme-1.0)/time_scheme,&MMXq_t);
	Tensor_Sum(MMXIpn2_t,MMXq_t,1.0,&MMXq_t);
	Tensor_Sum(MMXsource_t,MMXq_t,1.0,&MMXq_t);
 /*Computation of MMXR_t*/	
        SparseMat_Tensorproduct(MMXPDI_f_t,MMXq_t,&BT); 
	SparseMat_Tensorproduct(MMXPC_f_t,MMXf0_t,&MMXR_t); 
	Tensor_Sum(BT,MMXR_t,-1.0,&MMXR_t);  
	
        free(BT.sizedim);free(BT.vals);
	free(BP.sizedim);free(BP.vals);
	free(BR.sizedim);free(BR.vals);
	
/* 	printf("RHS COMPUTED\n");*/

/*Tensor_Save("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_output/MMXq_tc",MMXq_t);
Tensor_Save("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_output/MMXR_tc",MMXR_t);*/
	
  /*Solving step.Computation of MMS_t*/
/*   printf("CREATING PETSc PARALLEL OBJECTS\n");*/
  ierr=VecCreate(PETSC_COMM_WORLD,&b);CHKERRQ(ierr);
  ierr=VecSetSizes(b,PETSC_DECIDE,MMXR_t.size);CHKERRQ(ierr);
  ierr=VecSetType(b,VECMPI);CHKERRQ(ierr);
  ierr=VecGetOwnershipRange(b,&low,&high);CHKERRQ(ierr);
  ix=malloc((high-low)*sizeof(int));
  y=malloc((high-low)*sizeof(DOUBLE));
  for(i=low;i<high;i++){
  ix[i-low]=i;
  y[i-low]=MMXR_t.vals[i];}
  ierr=VecSetValues(b,high-low,ix,y,INSERT_VALUES);CHKERRQ(ierr);
  ierr=VecAssemblyBegin(b);VecAssemblyEnd(b);CHKERRQ(ierr);
  ierr=VecDuplicate(b,&x);CHKERRQ(ierr);
  ierr=VecCopy(b,x);CHKERRQ(ierr);
  
/*   printf("SOLVING\n");*/
  ierr=KSPSolve(ksp,b,x);CHKERRQ(ierr);
  
 /*  printf("RETRIEVING SOLUTION\n");*/
  VecScatterCreateToAll(x,&vecscat,&xseq);
  VecScatterBegin(x,xseq,INSERT_VALUES,SCATTER_FORWARD,vecscat);
  VecScatterEnd(x,xseq,INSERT_VALUES,SCATTER_FORWARD,vecscat);
  VecScatterDestroy(vecscat);
  VecGetArray(xseq, &xvals);
  sdim[0]=1;
  sdim[1]=MMXR_t.size;
  Tensor_Create(2,sdim,&MMXS_t);
  for(i=0;i<MMXS_t.size;i++){
  MMXS_t.vals[i]=xvals[i];
  }
  VecRestoreArray(xseq, &xvals);
  VecDestroy(b);VecDestroy(x);VecDestroy(xseq);
  
  free(ix);free(y);
/*Tensor_Save("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_output/MMXS_tc",MMXS_t);*/
  
  
  
  /*Computation of MMXf1_t=MMXf0_t+MMXS_t*/
         Tensor_Sum(MMXf0_t,MMXS_t,1.0,&MMXf1_t);
	 free(MMXS_t.vals);free(MMXS_t.sizedim);
	 
	 /*printf("COMPUTING Xf1_t\n");*/
         for(ir=0;ir<nr;ir++){
	/*Computation of Xf1_t=F(MMXf1_t,sm_f,nmhu,ns_f_npn)*/
	   sdim[0]=nmhu-ns_f[ir];
	   sdim[1]=npn;
	   Tensor_Create(2,sdim,&Xf1_t);
	   
	   for(i=0;i<sm_f[ir+1]-sm_f[ir];i++){	   	   
	   Xf1_t.vals[i]=MMXf1_t.vals[i+sm_f[ir]];
	   }
	   Tensor_Transpose(&Xf1_t);
	  
	/*Computation of Xf1=F(Xf1_t, nmhu, ns_f, ir)*/
	 /*printf("COMPUTING Xf1\n");*/

	   if(bounce_mode==0){
	      Tensor_Create(Xf1_t.ndims,Xf1_t.sizedim,&Xf1);
	      for(i=0;i<Xf1.size;i++){	  
	         Xf1.vals[i]=Xf1_t.vals[i];	
	      }  
	   }
	   else if(bounce_mode==1){
	      sdim[0]=npn;
	      sdim[1]=nmhu;
	      Tensor_Create(2,sdim,&Xf1);
	      for(i=0;i<Xf1.size;i++){
	         Xf1.vals[i]=0.0;
	      }
	      for(i=0;i<Xf1.sizedim[0];i++){
	         for(j=0;j<nmhu/2-ns_f[ir];j++){
	            Xf1.vals[i+Xf1.sizedim[0]*j]=Xf1_t.vals[i+Xf1.sizedim[0]*j];
		 }
	         for(j=nmhu/2;j<nmhu;j++){	                        ;
                    Xf1.vals[i+Xf1.sizedim[0]*j]=Xf1_t.vals[i+Xf1.sizedim[0]*(j-ns_f[ir])];
	         }
	         /*for(j=nmhu/2-ns_f[ir];j<nmhu/2;j++){	*/                         
                  for(j=0;j<ns_f[ir];j++){
Xf1.vals[i+Xf1.sizedim[0]*(j+nmhu/2-ns_f[ir])]=Xf1_t.vals[i+Xf1.sizedim[0]*(nmhu/2-1-j)];
	         }
		 
		 
	      }

	    }  
	    
	 /*printf("COMPUTING NORMS,CURRENTS, ACCURACIES\n");*/

   /*Computation of normf0,normf1,curr0, curr1, prec_curr, prec_norm,
   residu_f_prec_residu_f*/
	sdim[0]=XXf0.sizedim[0];
	sdim[1]=XXf0.sizedim[1];
	Tensor_Create(2,sdim,&SXXf0);
	for(i=0;i<SXXf0.size;i++){	
	   SXXf0.vals[i]=XXf0.vals[i+ir*XXf0.sizedim[0]*XXf0.sizedim[1]];
	}
	
	integral_dke_jd(dmhu,SXXf0,2,&B);
		
	/*printf("SXXF0=%i %i\n",SXXf0.sizedim[0],SXXf0.sizedim[1]);
	printf("Bdims=%i %i\n",B.sizedim[0],B.sizedim[1]);*/
	/*fprintf(stdout,"Read pn2\n");ReadBinary_DKE("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_variables/pn2",&pn2);*/
	product(pn2,B,&B);
	Tensor_Transpose(&B);
	integral_dke_jd(dpn,B,1,&C);	
	normf0.vals[ir+normf0.sizedim[0]*it_f]=2.0*Pi*C.vals[0];
	free(B.vals);free(B.sizedim);
	free(C.vals);free(C.sizedim);
	
	integral_dke_jd(dmhu,Xf1,2,&B);	
	product(pn2,B,&B);
	Tensor_Transpose(&B);
	integral_dke_jd(dpn,B,1,&C);	
	normf1.vals[ir+normf1.sizedim[0]*it_f]=2.0*Pi*C.vals[0];	
	free(B.vals);free(B.sizedim);
	free(C.vals);free(C.sizedim);


	product(Xmhu,SXXf0,&B);
	integral_dke_jd(dmhu,B,2,&C);
	product(C,pn,&C);
	product(C,pn2,&C);
	division(C,gamma,&C);
	Tensor_Transpose(&C);
	integral_dke_jd(dpn,C,1,&D);	      
       curr0.vals[ir+curr0.sizedim[0]*it_f]=2.0*Pi*D.vals[0]*xne_norm.vals[ir]/normf0.vals[ir+normf1.sizedim[0]*it_f];

	free(B.vals);free(B.sizedim);
	free(C.vals);free(C.sizedim);
	free(D.vals);free(D.sizedim);
	
	product(Xmhu,Xf1,&B);
	integral_dke_jd(dmhu,B,2,&C);
	product(C,pn,&C);
	product(C,pn2,&C);
	division(C,gamma,&C);
	Tensor_Transpose(&C);
	integral_dke_jd(dpn,C,1,&D);	
        curr1.vals[ir+curr1.sizedim[0]*it_f]=2.0*Pi*D.vals[0]*xne_norm.vals[ir]/normf1.vals[ir+normf1.sizedim[0]*it_f];

	free(B.vals);free(B.sizedim);
	free(C.vals);free(C.sizedim);
	free(D.vals);free(D.sizedim);
       	
        prec_curr.vals[ir+prec_curr.sizedim[0]*it_f]=(curr1.vals[ir+curr1.sizedim[0]*it_f]-curr0.vals[ir+curr0.sizedim[0]*it_f])/curr0.vals[ir+curr0.sizedim[0]*it_f];


        prec_normf.vals[ir+prec_normf.sizedim[0]*it_f]=(normf1.vals[ir+normf1.sizedim[0]*it_f]-normf0.vals[ir+normf0.sizedim[0]*1])/normf0.vals[ir+0*normf0.sizedim[0]];
	
	Tensor_Sum(Xf1,SXXf0,-1.0,&B);
	product(B,B,&B);
	product(B,SXXf0,&B);
	integral_dke_jd(dmhu,B,2,&C);	
	product(pn2,C,&C);
	Tensor_Transpose(&C);
	integral_dke_jd(dpn,C,1,&D);  	
        residu_f.vals[ir+residu_f.sizedim[0]*it_f]=sqrt(2.0*Pi*D.vals[0]/normf1.vals[ir+normf1.sizedim[0]*it_f]/dtn.vals[0]/dtn.vals[0]);
		
	free(B.vals);free(B.sizedim);
	free(C.vals);free(C.sizedim);
	free(D.vals);free(D.sizedim);
	  
        prec_residu_f.vals[ir+prec_residu_f.sizedim[0]*it_f]=absolute((residu_f.vals[ir+residu_f.sizedim[0]*it_f]-residu_f.vals[ir+residu_f.sizedim[0]*(it_f-1)])/residu_f.vals[ir+residu_f.sizedim[0]*it_f]);

   	 

        if(coll_mode==2){
	   /*Computation of f1,I1,I2,XI=F(I1,I2,f1,ir,XXFM,XXRlambda_b_p1p1,gamma,
   mhu,pn,pn2),XXI=F(X1)*/
   /*printf("COMPUTING f1,I1,I2,XI,XXI\n");*/
           sdim[0]=npn;
           sdim[1]=mhu.sizedim[1];
           Tensor_Create(2,sdim,&B);
	   for(i=0;i<B.sizedim[0];i++){
	       for(j=0;j<B.sizedim[1];j++){
	          B.vals[i+B.sizedim[0]*j]=mhu.vals[j];
	       }
	   }
	   product(B,Xf1,&B);
           integral_dke_jd(dmhu,B,2,&f1);
	   for(i=0;i<f1.size;i++){
	      f1.vals[i]*=1.5;
	   }

	    sdim[0]=1;
	    sdim[1]=1; 
	    Tensor_Create(2,sdim,&xTe_normir);
	    Tensor_Fill(&xTe_normir ,xTe_norm.vals[ir]);
	    firstordercollop_dke_ft_c2(f1,betath_ref,masku,maskl,dpn,xpn,xpn2,xpn3,xsigma,xgamma,xz,xz2,pn,pn2,pn3,sigma,gamma,z,z2,xJ1,xJ2,xJ3,xJ4,J1,J2,J3,J4,xTe_normir,&I1,&I2);

	   sdim[1]=mhu.sizedim[1];
	   sdim[0]=XXfM.sizedim[0];
	   Tensor_Create(2,sdim,&XI);
	   division(I1,pn2,&I1);
	   product(I2,pn,&I2);
	   Tensor_Sum(f1,I1,1.0,&I1);
	   Tensor_Sum(I1,I2,1.0,&I1);
	   division(I1,gamma,&I1);
	    
	   sdim[0]=XXfM.sizedim[0];
	   sdim[1]=1; 	      	      
	   Tensor_Create(2,sdim,&SXXfM);
	   for(i=0;i<SXXfM.size;i++){
	   SXXfM.vals[i]=XXfM.vals[i+XXfM.sizedim[0]*0+ir*XXfM.sizedim[0]*XXfM.sizedim[1]];
	   }
	      
	   sdim[0]=XXRlambda_b_p1p1.sizedim[0];
	   sdim[1]=XXRlambda_b_p1p1.sizedim[1];
	   Tensor_Create(2,sdim,&SXXRlambda_b_p1p1);
	   for(i=0;i<SXXRlambda_b_p1p1.size;i++){	     
              SXXRlambda_b_p1p1.vals[i]=XXRlambda_b_p1p1.vals[i+ir*XXRlambda_b_p1p1.sizedim[0]*XXRlambda_b_p1p1.sizedim[1]];
	   }
	   	      
	   product(I1,SXXfM,&I1);
	      for(i=0;i<I1.size;i++){
	         for(j=0;j<mhu.size;j++){
		    XI.vals[i+j*XI.sizedim[0]]=I1.vals[i]*mhu.vals[j];	 
		 }
	      }
	      	     
	    product(XI,SXXRlambda_b_p1p1,&XI);
	   for(i=0;i<XI.size;i++){
	      XI.vals[i]*=4.0*Pi;
	   }
	   
	   for(j=0;j<XI.sizedim[1];j++){
	      XI.vals[j*XI.sizedim[0]]=0.0;
	   }
 
	   for(i=0;i<XXI.sizedim[0];i++){
	      for(j=0;j<XXI.sizedim[1];j++){
		 
XXI.vals[i+j*XXI.sizedim[0]+ir*XXI.sizedim[0]*XXI.sizedim[1]]=XI.vals[i+j*XI.sizedim[0]];		 
	      }
	   }

	      /*printf("%i!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n",it_f);*/
	      /*free(f1.vals);free(f1.sizedim);*/	      
	      free(B.vals);free(B.sizedim);
	      free(I1.vals);free(I1.sizedim);
	      free(I2.vals);free(I2.sizedim);
	      free(XI.vals);free(XI.sizedim);
	      
	      /*free(C.vals);free(C.sizedim);*/
	      
	}
	   
	else{
	   for(i=0;i<XXI.sizedim[0];i++){
	      for(j=0;j<XXI.sizedim[1];j++){		   
                  XXI.vals[i+XI.sizedim[0]*j+ir*XI.sizedim[0]*XI.sizedim[1]]=0.0;		 
              }
	   }
	}
	 /*printf("COMPUTING XXf0\n");*/
	if(norm_mode_f==1){
	   /*Computation of XXfo=F(X1,xne_norm(ir),normf1*/
	   
	  for(i=0;i<XXf0.sizedim[0];i++){
	      for(j=0;j<XXf0.sizedim[1];j++){		   
                
XXf0.vals[i+j*XXf0.sizedim[0]+ir*XXf0.sizedim[0]*XXf0.sizedim[1]]=Xf1.vals[i+j*XXf0.sizedim[0]]*xne_norm.vals[ir]/normf1.vals[ir+it_f*normf1.sizedim[0]];
              }
	   }	
	}
	
       else{
       
	   for(i=0;i<XXf0.sizedim[0];i++){
	      for(j=0;j<XXf0.sizedim[1];j++){		                      
                 
XXf0.vals[i+j*XXf0.sizedim[0]+ir*XXf0.sizedim[0]*XXf0.sizedim[1]]=Xf1.vals[i+j*XXf0.sizedim[0]];
	     	  
/*printf("%g\n",XXf0.vals[i+j*XXf0.sizedim[0]+ir*XXf0.sizedim[0]*XXf0.sizedim[1]]);*/  }	
/*printf("%g\n",Xf1.vals[i+j*XXf0.sizedim[0]]);*/
	   }	      	   
	}	

   /*Computation of XXfo=F(X1,xne_norm(ir),normf1*/
   /*Computation of normf0,curr0*/
   
      normf0.vals[ir+normf0.sizedim[0]*it_f]=normf1.vals[ir+normf1.sizedim[0]*it_f];
      curr0.vals[ir+curr0.sizedim[0]*it_f]=curr1.vals[ir+curr1.sizedim[0]*it_f];
       
      free(Xf1_t.sizedim);free(Xf1_t.vals);free(Xf1.sizedim);free(Xf1.vals);    
        }
 }
    else{
    sum1=0.0;
       for(i=0;i<prec_residu_f.sizedim[0];i++){
          sum1+=prec_residu_f.vals[i+(it_f-1)*prec_residu_f.sizedim[0]];
       }
       if(sum1<prec0_f){printf("WARNING: stationnary residu but convergence not achieved for f0 after %i iterations\n",it_f);
       }
       sum2=0;
       for(i=0;i<residu_f.sizedim[0];i++){
          sum2+=(residu_f.vals[i+(it_f-1)*residu_f.sizedim[0]]>=prec0_f);
       }
        if(sum2==0 && display_mode>0){
	   printf("Successfull convergence achieved for f0 after %i iterations\n",it_f-2);
	}  
	break;     
    }
    
    if(it_f==nit_f){
       printf("WARNING: convergence not achieved for f0 after %i iterations.Time step too small",nit_f);
    }
   
Tensor_Save("/Users/Yves/CEA/Projets/LUKE/Packages/petsc-2.3.2-p10/DKE/DKESolver_output/XXf0",XXf0);
 
  
/*free(XI_t.sizedim);free(XI_t.vals);
free(MMXf0_t.vals);free(MMXf0_t.sizedim);
free(MMXsource_t.vals);free(MMXsource_t.sizedim);
free(MMXIpn2_t.vals);free(MMXIpn2_t.sizedim);
free(A.vals);free(A.sizedim);
free(f1.vals);free(f1.sizedim);*/


 }	
 
/*free(normf0.sizedim);free(normf0.vals);*/
/*free(normf1.sizedim);free(normf1.vals);*/
/*free(curr0.sizedim);free(curr0.vals);*/
/*free(curr1.sizedim);free(curr1.vals);
free(prec_curr.sizedim);free(prec_curr.vals);
free(prec_normf.sizedim);free(prec_normf.vals);
free(residu_f.sizedim);free(residu_f.vals);
free(prec_residu_f.sizedim);free(prec_residu_f.vals);*/

/*FREE AND SAVES*/
/* printf("FREEING MEMORY\n");*/
KSPDestroy(ksp);

/*free(XXI.vals);free(XXf0.vals);free(XXsinksource.vals);
free(dpn.vals);
 free(xpn.vals);free(xpn2.vals);free(xpn3.vals);
 free(masku.vals);free(maskl.vals);
 free(xsigma.vals);free(xgamma.vals);
 free(xz.vals);free(xz2.vals);
 free(z.vals);free(z2.vals);
 free(pn.vals);free(pn2.vals);free(pn3.vals);
 free(sigma.vals);free(gamma.vals);
 free(xJ1.vals);free(xJ2.vals);free(xJ3.vals);free(xJ4.vals);
 free(J1.vals);free(J2.vals);free(J3.vals);free(J4.vals);
 free(xTe_norm.vals);free(betath_ref.vals);*/
 

/*free(index.vals);free(index.sizedim);*/
/*Tensor_Save("curr0",curr0);
Tensor_Save("curr1",curr1);
Tensor_Save("normf0",normf0);
Tensor_Save("normf1",normf1);
Tensor_Save("prec_normf",prec_normf);
Tensor_Save("prec_curr",prec_curr);
Tensor_Save("residu_f",residu_f);
Tensor_Save("prec_residu_f",prec_residu_f);*/

/*ierr=PetscFinalize();CHKERRQ(ierr);*/

}


    
