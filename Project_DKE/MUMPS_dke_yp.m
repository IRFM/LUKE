function [X,flag,text] = MUMPS_dke_yp(MUMPSparam,A,B,temppath)
%
%Link with the parallel matrix solver package MUMPS written in FORTAN 95. This is a modified package wich is able to 
%read binary files written by MatLab, which needs to be compiled first. 
%Adapted to the Saturne computers of the CEA-DRFC
%
%Solve the linear system of equation AX=B
%
% INPUTS:
%
%   - MUMPSparam: Structure for controling MUMPS program. 
%	- A: Matrix [n,n]
%   - B: Vector for solving the linear system of equations AX=B [n,1]  
%   - temppath: absolute path where data file are produced
%     (default: local directory)
%
% OUTPUTS:
%
%   - X: Solution of the linear system of equation [n,1]
%   - flag: execution flag (see the MUMPS documentation) [1,1]
%
%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
info_dke_yp(2,'MUMPS matrix inversion - parallel processing -')
%
%Write matrix A and vector B in MUMPS_in binary file
%
if nargin < 3,error('Wrong number of input arguments in MUMPS_dke_yp !');end
if nargin == 3,temppath='';end
%
N = size(A,2);
[AI,AJ,AV] = find(A);
NA = length(AI);%number of non-zero elements
%
if MUMPSparam.nproc > 15, 
   nproc = 10;
   info_dke_yp(2,'The number of processors has been enforced to 10 !');
else
   nproc = MUMPSparam.nproc;
end
%
if isempty(MUMPSparam.path),%Local saving
   MUMPSpath = MUMPSparam.path;
else
   MUMPSpath = [MUMPSparam.path,filesep];
end
flag = 0;
%
initial_dir = cd;
cd(temppath);%Move to scratch directory
%
% Write one file per variable for MatLab <-> FORTRAN in the scratch directory
%
fid = fopen('MUMPS_N_in.bin','wb');fwrite(fid,N,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS N in the scratch directory');end
fid = fopen('MUMPS_NA_in.bin','wb');fwrite(fid,NA,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS NZ in the scratch directory');end
fid = fopen('MUMPS_AI_in.bin','wb');fwrite(fid,AI,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS AI in the scratch directory');end
fid = fopen('MUMPS_AJ_in.bin','wb');fwrite(fid,AJ,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS AJ in the scratch directory');end
fid = fopen('MUMPS_AV_in.bin','wb');fwrite(fid,AV,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS AV in the scratch directory');end
fid = fopen('MUMPS_B_in.bin','wb');fwrite(fid,B,'double');if (fclose(fid)~=0), error('Impossible to write input file for MUMPS B in the scratch directory');end
%
% Test processor charge to select the first less used regarding the total number of processors needed
%
%
! qstat -f | awk '$2=="BP" {print $0}' | awk '{print $1,$4}' | sed -e 's/all.q@//g' | sed -e 's/.cad.cea.fr./ /g' | sed -e 's/.cad.cea.f./ /g' | grep -v sequenceur | sed -e 's/sequenceur@//g' | awk '{print $2,$1}' | sort | uniq | awk '{print "Charge =",$1,"==>",$2}'
! qstat -f | awk '$2=="BP" {print $0}' | awk '{print $1,$4}' | sed -e 's/all.q@//g' | sed -e 's/.cad.cea.fr./ /g' | sed -e 's/.cad.cea.f./ /g' | grep -v sequenceur | sed -e 's/sequenceur@//g' | awk '{print $2,$1}' | sort | uniq | awk '{print $2}' >! .machines.tmp
unix(['head -',int2str(nproc),' .machines.tmp >! .machines']);%Keeps the first nproc processors who have the less CPU charge
! rm -f .machines.tmp*
%
%Execute MUMPS on N processors in the scratch directory
%
[flag,text]=unix(['/usr/local/pgi/linux86-64/6.0/bin/mpirun -np ',int2str(nproc),' -machinefile .machines ',MUMPSpath,'mumpsdke']);
%
% Read one file per variable for MatLab <-> MUMPS FORTRAN
%
if flag == 0,
   fid=fopen('MUMPS_X_out.bin','rb');X=fread(fid,N,'double');fclose(fid);%solution of the system of equation
   X = X(:);
else
   X = [];
end
%
cd(initial_dir);%return to the initial working directory

  
  
  
  