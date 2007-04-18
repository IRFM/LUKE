/*READS MATLAB CELL-ARRAYS OF INTS AS CODED BY writeBinaryIntArray_mex.C ints
are Matlabs int32*/ 

#include <stdlib.h>
#include <stdio.h>
#include "Fokker-Planck_DKE_loop.h"

void ReadBinaryIntArray_DKE(char* file,struct IntTensor **Array)
{
FILE* TENSOR;
int i;
int cookie;
/*fprintf(stdout,"Opening\n");*/
TENSOR=fopen(file,"r");
if(!TENSOR){printf("couldn't open file\n");}
/*fprintf(stdout,"Reading cookie\n");*/
fread(&cookie,sizeof(int),1,TENSOR);
/*fprintf(stdout,"TEST COOKIE\n");
fprintf(stdout,"%i\n",cookie);*/
if(cookie==0){
int j,k;
int mc,*nc;
int pc=1,p=1;
/*File is a CELL ARRAY*/
/* fprintf(stdout,"CELL ARRAY\n");*/
/* fprintf(stdout,"reading m\n");*/
fread(&mc,sizeof(int),1,TENSOR);
if(mc!=2){return;}
nc=malloc(mc*sizeof(int));
fread(nc,sizeof(int),mc,TENSOR);
fread(&pc,sizeof(int),1,TENSOR);

*Array=malloc(sizeof(**Array)*pc);

   for(i=0;i<nc[0];i++){
      for(j=0;j<nc[1];j++){
     
fread(&((*Array)[i+nc[0]*j].ndims),sizeof(int),1,TENSOR);/* fprintf(stdout,"%i\n",(*Array)[i+nc[0]*j].ndims)*/;
      (*Array)[i+nc[0]*j].sizedim=malloc((*Array)[i+nc[0]*j].ndims*sizeof(int));
      fread((*Array)[i+nc[0]*j].sizedim,sizeof(int),(*Array)[i+nc[0]*j].ndims,TENSOR);
     
fread(&((*Array)[i+nc[0]*j].size),sizeof(int),1,TENSOR);/* fprintf(stdout,"%i\n",(*Array)[i+nc[0]*j].size)*/;
      ((*Array)[i+nc[0]*j].vals)=malloc((*Array)[i+nc[0]*j].size*sizeof(INT));
      fread((*Array)[i+nc[0]*j].vals,sizeof(INT),(*Array)[i+nc[0]*j].size,TENSOR);
         for(k=0;k<(*Array)[i+nc[0]*j].size;k++){
	     /*fprintf(stdout,"%i\n",(*Array)[i+nc[0]*j].vals[k]);*/
         }
      }
   }
}

else if(cookie==1){
/*File is a numerical array*/
*Array=malloc(sizeof(**Array)*1);
/*fprintf(stdout,"reading Array ndims\n");*/
fread(&((**Array).ndims),sizeof(int),1,TENSOR);

(**Array).sizedim=malloc((**Array).ndims*sizeof(int));
fread((**Array).sizedim,sizeof(int),(**Array).ndims,TENSOR);

fread(&((**Array).size),sizeof(int),1,TENSOR);

((**Array).vals)=malloc((**Array).size*sizeof(int));
fread((**Array).vals,sizeof(int),(**Array).size,TENSOR);
}


fclose(TENSOR);
/*fprintf(stdout,"end read\n");*/
}
