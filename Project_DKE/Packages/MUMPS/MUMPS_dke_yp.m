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
if MUMPSparam.nproc > 15, 
   nproc = 15;
   info_dke_yp(2,'The number of processors has been enforced to 15 !');
else
   nproc = MUMPSparam.nproc;
end
%
if isempty(dkepath.MUMPS),%Local saving
   MUMPSpath = dkepath.MUMPS;
else
   MUMPSpath = [dkepath.MUMPS,filesep];
end
flag = 0;
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
% Test processor charge to select the first less used regarding the total number of processors needed
%
if strcmp(dkepath.computer,'GLNXA64'),%Parallel processing
   if MUMPSparam.nproc > 15, 
      nproc = 15;
      info_dke_yp(2,'The number of processors has been enforced to 15 !');
   else
      nproc = MUMPSparam.nproc;
   end   
%    
   if display_mode >=1,
      unix([MUMPSpath,'mcharge 1']);
   else
      unix([MUMPSpath,'mcharge 0']);
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
%Execute MUMPS on N processors in the scratch directory
%
   [flag,text]=unix(['/usr/local/pgi/linux86-64/6.0/bin/mpirun -np ',int2str(nprocmax),' -machinefile .machines ',MUMPSpath,'mumpsdke']);
%
    delete('.machines');%delete .machines file
elseif strcmp(dkepath.computer,'MAC'),%Parallel or sequential processing
   nproc = 1;% Single processor enforced
   [flag,text]=unix([MUMPSpath,'mumpsdke']);  
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

  
  
  