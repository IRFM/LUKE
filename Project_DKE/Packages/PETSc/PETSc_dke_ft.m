function [X,flag,text] = PETSc_dke_ft(PETScparam,A,B,display_mode,dkepath)
%
%Link with the parallel matrix solver package PETSc written in C. 
%Adapted to the Saturne computers of the CEA-DRFC
%
%Solve the linear system of equation AX=B
%
% INPUTS:
%
%   - PETScparam: Structure for controling PETSc program. 
%	- A: Matrix [n,n]
%   - B: Vector for solving the linear system of equations AX=B [n,1]  
%   - display_mode: display some results [1,1]
%   - dkepath: paths structure
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
    info_dke_yp(2,'Matrix inversion by PETSc solver - parallel or sequential processing -')
end
%
if nargin < 5,error('Wrong number of input arguments in PETSc_dke_ft !');end
%
flag = 0;text = '';
%
initial_dir = cd;
d = dir(dkepath.temppath);
if ~exist(dkepath.temppath);
	mkdir(dkepath.temppath);%Create calculation directory
end
cd(dkepath.temppath);%Move to calculation directory	
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
% Computer management
%
nproc = nproc_dke_yp(display_mode,PETScparam,dkepath);
%
% Run PETSc on N processors (if nproc > 1)
%     - np: specifies number of processors to run on. See mpirun options.
%     - machinefile: specifies a list of available machines to run on. See mpirun options.
%     - f: location of PETSc binary file of the A matrix
%     - rhs: location of PETSc binary file of the b vector
%     - ksp_type: sets KSP method. see PETSc manual
%     - scratchdir: indicates the /scratch directory to the C program.
%
if nproc > 1,%Parallel processing is invoked
	if isfield(dkepath.PETSc,'par'),
        if display_mode >= 1,info_dke_yp(2,'Matrix inversion by PETSc solver - parallel processing -');end
        [flag,text] = unix(['mpirun -np ',int2str(nproc),' -machinefile .machines',dkepath.PETSc.par,'/PETSc_DKE_ft -f PETSc_in_A.bin -rhs PETSc_in_b.bin  -scratchdir ',dkepath.temppath,' ',mattype,' ',kspmethod, ' ', pcmethod]);
    elseif isfield(dkepath.PETSc,'seq'),
        if display_mode >= 1,info_dke_yp(2,'Matrix inversion by PETSc solver - sequential processing enforced, no parallel processing package on this machine ! -');end
        [flag,text] = unix([dkepath.PETSc.seq,'/PETSc_DKE_ft -f PETSc_in_A.bin -rhs PETSc_in_b.bin  -scratchdir ',dkepath.temppath,' ',mattype,' ',kspmethod, ' ', pcmethod]);
    else
        error('PETSc package not correctly named for LUKE: <pakage name+version>_P_<compiler name> or  <pakage name+version>_S_<compiler name>');
    end
elseif nproc == 1,%Sequential processing is invoked
    if isfield(dkepath.PETSc,'seq'),
        if display_mode >= 1,info_dke_yp(2,'Matrix inversion by PETSc solver - sequential processing -');end
        [flag,text] = unix([dkepath.PETSc.seq,'/PETSc_DKE_ft -f PETSc_in_A.bin -rhs PETSc_in_b.bin  -scratchdir ',dkepath.temppath,' ',mattype,' ',kspmethod, ' ', pcmethod]);
    elseif isfield(dkepath.PETSc,'par'),
        if display_mode >= 1,info_dke_yp(2,'Matrix inversion by PETSc solver - parallel processing enforced, no sequential processing package on this machine !  -');end
        [flag,text] = unix(['mpirun -np ',int2str(nproc),' -machinefile .machines',dkepath.PETSc.par,'/PETSc_DKE_ft -f PETSc_in_A.bin -rhs PETSc_in_b.bin  -scratchdir ',dkepath.temppath,' ',mattype,' ',kspmethod, ' ', pcmethod]);
    else
        error('PETSc package not correctly named for LUKE: <pakage name+version>_P_<compiler name> or  <pakage name+version>_S_<compiler name>');
    end
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
delete('*.bin.info');%delete all bin files
cd(initial_dir);%return to the initial working directory

  
  
  
