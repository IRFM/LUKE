function [X,flag,text] = PETSc_dke_ft(PETScparam,A,B,display_mode,path)
%
%Link with the parallel matrix solver package PETSc written in C. 
%Adapted to the Saturne computers of the CEA-DRFC
%
%Solve the linear system of equation AX=B
%
% INPUTS:
%
%   - PETScparam: Structure for controling PETSc program. 
%	 - A: Matrix [n,n]
%   - B: Vector for solving the linear system of equations AX=B [n,1]  
%   - display_mode: display some results [1,1]
%   - path: paths structure
%
% OUTPUTS:
%
%   - X: Solution of the linear system of equation [n,1]
%   - flag: execution flag (see the MUMPS documentation) [1,1]
%   - text: execution documentation (see the HYPRE documentation)
%
%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) ,Yves Peysson (CEA-DRFC,yves.peysson@cea.fr), Frederic Teisseire (CEA-DRFC)
%
if display_mode >= 1,
    %info_dke_yp(2,'Matrix inversion by PETSc solver - parallel or sequential processing -')
end
%
if nargin < 5,error('Wrong number of input arguments in PETSc_dke_ft !');end
%
if PETScparam.nproc > 15, 
   nproc = 15;
   info_dke_yp(2,'The number of processors has been enforced to 15 !');
else
   nproc = PETScparam.nproc;
end
%
if isempty(path.PETSc),%Local saving
   PETScpath = path.PETSc;
else
   PETScpath = [path.PETSc,filesep];
end
flag = 0;
%
initial_dir = cd;
d = dir(path.temppath);
if ~exist(path.temppath);
	mkdir(path.temppath);%Create calculation directory
end
cd(path.temppath);%Move to calculation directory	
%
%Write matrix A and vector B in PETSc binary file
%
MAT_FILE_COOKIE = 1211216;
VEC_FILE_COOKIE = 1211214;
%
%Write matrix A 
%
fid=fopen('PETSc_in_A.bin','w','ieee-be');
[M,N]=size(A);
fwrite(fid,MAT_FILE_COOKIE,'int');
fwrite(fid,M,'int');
fwrite(fid,N,'int');
fwrite(fid,nnz(A),'int');
[ii,jj,aa]=find(A');
nnzrow=zeros(size(A,1), 1);% nonzeros in each row
nnzrow(:)=full(sum(spones(A'))');
fwrite(fid,nnzrow,'int');
fwrite(fid,ii-1,'int');
fwrite(fid,aa,'float64');
%    
%Write vector B
%
fid=fopen('PETSc_in_b.bin','w','ieee-be');  
nv=size(B,2);
for it=1:nv
   fwrite(fid,VEC_FILE_COOKIE,'int');
   fwrite(fid,size(B,1),'int');
   fwrite(fid,full(B(:,it)),'float64');
end
fclose(fid);
%    
mattype = PETScparam.matrixtype;
kspmethod = PETScparam.kspmethod;
pcmethod = PETScparam.pcmethod;
%
%Test processor charge to select the first less used regarding the total number of processors needed
%
if strcmp(path.computer,'GLNXA64'),%Parallel processing
   if PETScparam.nproc > 15, 
      nproc = 15;
      info_dke_yp(2,'The number of processors has been enforced to 15 !');
   else
      nproc = PETScparam.nproc;
   end   
%    
   if display_mode >=1,
      unix([PETScpath,'DKE/mcharge 1']);
   else
      unix([PETScpath,'DKE/mcharge 0']);
   end
%
   fid = fopen('.machines','r');
   listactivenodes = fread(fid,'uint8=>char')';
   fclose(fid);
   proc = listactivenodes(strfind(listactivenodes,':')+1);
   nprocmax = sum(str2num(proc(:)));%Maximum number of available processors (usually nprocmax = nproc, except is nproc is too large or the computing charge is too heavy)
   if nprocmax <= nproc & display_mode >=1,
      info_dke_yp(2,['Number of processors requested : ',int2str(nproc),', number of processors available: ',int2str(nprocmax)]);%less processors are available
   end
%
   if nproc <= nprocmax,nprocmax = nproc;end,%In order to be able to use odd number of processors, while the  
%
% Run PETSc on N processors in the /scratch directory
%     - np: specifies number of processors to run on. See mpirun options.
%     - machinefile: specifies a list of available machines to run on. See mpirun options.
%     - f: location of PETSc binary file of the A matrix
%     - rhs: location of PETSc binary file of the b vector
%     - ksp_type: sets KSP method. see PETSc manual
%     - scratchdir: indicates the /scratch directory to the C program.
   [flag,text] = unix([PETScpath,'bin/petscmpirun -np ',int2str(nprocmax),' -machinefile .machines ',PETScpath,'DKE/PETSc_DKE_ft -f PETSc_in_A.bin -rhs PETSc_in_b.bin  -scratchdir ',path.temppath,' ',mattype,' ',kspmethod, ' ', pcmethod]);
   %
    delete('.machines');%delete .machines file
elseif strcmp(path.computer,'MAC'),%Parallel or sequential processing
   %nproc = 1;% Single processor enforced
   %[flag,text]=unix([MUMPSpath,'mumpsdke']);  
end
%
% Read solution from PETSc binary file
%
if ~flag,
   fid = fopen('PETSc_out_X.bin','r','ieee-be');
   fread(fid,1,'int');
   n = fread(fid,1,'int');
   X = fread(fid,n,'float64');
   fclose(fid);
   X = X(:);
else
   error(['Error in PETSc calculation. Flag =',int2str(flag),', Log = ',text]);
end
%
delete('*.bin');%delete all bin files
cd(initial_dir);%return to the initial working directory

  
  
  
