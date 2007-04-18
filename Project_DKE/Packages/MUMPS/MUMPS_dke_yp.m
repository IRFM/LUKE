function [X,flag,text] = MUMPS_dke_yp(MUMPSparam,A,B,display_mode,dkepath)
%
%Link with the parallel matrix solver package MUMPS written in FORTAN 95. This is a modified package wich is able to 
%read binary files written by MatLab, which needs to be compiled first. 
%Tested on LINUX clusters (parallel) and MAC OS X (sequential)
%
%Solve the linear system of equation AX=B
%
% INPUTS:
%
%   - MUMPSparam: Structure for controling MUMPS program. 
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
%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
if display_mode >= 1,
   info_dke_yp(2,'Matrix inversion by MUMPS solver - parallel or sequential processing -')
end
%
%Write matrix A and vector B in MUMPS_in binary file
%
if nargin < 5,error('Wrong number of input arguments in MUMPS_dke_yp !');end
%
N = size(A,2);
[AI,AJ,AV] = find(A);
NA = length(AI);%number of non-zero elements
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
% Write one file per variable for MatLab <-> FORTRAN in the scratch directory
%
delete MUMPS_*
fid = fopen('MUMPS_N_in.bin','wb');fwrite(fid,N,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS N in the scratch directory');end
fid = fopen('MUMPS_NA_in.bin','wb');fwrite(fid,NA,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS NZ in the scratch directory');end
fid = fopen('MUMPS_AI_in.bin','wb');fwrite(fid,AI,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS AI in the scratch directory');end
fid = fopen('MUMPS_AJ_in.bin','wb');fwrite(fid,AJ,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS AJ in the scratch directory');end
fid = fopen('MUMPS_AV_in.bin','wb');fwrite(fid,AV,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS AV in the scratch directory');end
fid = fopen('MUMPS_B_in.bin','wb');fwrite(fid,B,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS B in the scratch directory');end
%
% Computer management
%
nproc = nproc_dke_yp(display_mode,MUMPSparam);
%
if nproc > 1,%Parallel processing is invoked
   if display_mode >= 1,info_dke_yp(2,'Matrix inversion by MUMPS solver - parallel processing -');end
   [flag,text] = unix(['mpirun -np ',int2str(nproc),' -machinefile .machines',dkepath.MUMPS,'/mumpsdke']);
else,%Sequential processing is invoked
   if display_mode >= 1,info_dke_yp(2,'Matrix inversion by MUMPS solver - sequential processing -');end
   [flag,text] = unix([dkepath.MUMPS,'/mumpsdke']);
end
%
% Read one file per variable for MatLab <-> MUMPS FORTRAN
%
if flag == 0,
   fid=fopen('MUMPS_X_out.bin','rb');X=fread(fid,N,'double');fclose(fid);%solution of the system of equation
   X = X(:);
else
   error(['Error in MUMPS calculation. Flag =',int2str(flag),', Log = ',text]);
end
%
delete('*.bin');%delete all bin files
cd(initial_dir);%return to the initial working directory

  
  
  