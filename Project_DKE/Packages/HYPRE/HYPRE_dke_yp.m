function [X,L,U,flag,text] = HYPRE_dke_yp(HYPREparam,A,B,droptol,temppath)
%
%Link with the parallel matrix solver package HYPRE written in C. Use the hyprematlab library (see www.mathworks.com) 
%Adapted to the Saturne computers of the CEA-DRFC.
%
%Solve the linear system of equation AX=B or provides L and U incomplete factorization matrices when B is empty only. 
%
% INPUTS:
%
%   - HYPREparam: Structure for controling HYPRE program. 
%	- A: Matrix [n,n]
%   - B: Vector for solving the linear system of equations AX=B (LU matrix factorization only is B is empty) [n,1]  
%   - droptol: drop tolerance parameter for incomplete LU matrix factorization [1,1]
%   - temppath: absolute path where data file are produced
%     (default: local directory)
%
% OUTPUTS:
%
%   - X: Solution of the linear system of equation [n,1]
%   - L: L sparse matrix (empty in direct inversion is called) [n,n] 
%   - U: U sparse matrix (empty in direct inversion is called) [n,n]
%   - flag: execution flag (see the HYPREs documentation) [1,1]
%   - text: execution comment (see the HYPRE documentation)
%
%By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC,joan.decker@cea.fr)
%
info_dke_yp(2,'HYPRE matrix inversion and incomplete LU factorization (SUPERLU) - parallel processing -')
%
if nargin < 4,error('Wrong number of input arguments in HYPRE_dke_yp !');end
if nargin == 4,temppath='';end
%
if HYPREparam.nproc > 15, 
   nproc = 10;
   info_dke_yp(2,'The number of processors has been enforced to 10 !');
else
   nproc = HYPREparam.nproc;
end
%
if isempty(HYPREparam.path),%Local saving
   HYPREpath = HYPREparam.path;
else
  HYPREpath = [HYPREparam.path,filesep];
end
flag = 0;
%
initial_dir = cd;
if isempty(temppath) == 0,%Loacal saving
   cd(temppath);%Move to scratch directory
end
%
%Convert MatLab data into HYPRE format and fill nproc files in the scratch directory for the number of requested processors (hyprematlab library)
%
tic,matlab2hypreIJ(A,nproc,'matrix');toc
tic,matlab2hypreParVectors(B,nproc,'vectors');toc
%
% Test processor charge to select the first less used regarding the total number of processors needed
%
unix(['qstat -f | awk ''$2=="BP" {print $0}'' | awk ''{print $1,$4}'' | sed -e ''s/all.q@//g'' | sed -e ''s/.cad.cea.fr./ /g'' | sed -e ''s/.cad.cea.f./ /g'' |  grep -v sequenceur | sed -e ''s/sequenceur@//g'' | awk ''{print $2,$1}'' | sort | uniq | awk ''{if (int(2.5-$1)>0) {i=i+int(2.5-$1);if (i<=',int2str(nproc),') {printf "%s%s%s\n" " ",$2,":",int(2.5-$1)}}}''']);
unix(['qstat -f | awk ''$2=="BP" {print $0}'' | awk ''{print $1,$4}'' | sed -e ''s/all.q@//g'' | sed -e ''s/.cad.cea.fr./ /g'' | sed -e ''s/.cad.cea.f./ /g'' |  grep -v sequenceur | sed -e ''s/sequenceur@//g'' | awk ''{print $2,$1}'' | sort | uniq | awk ''{if (int(2.5-$1)>0) {i=i+int(2.5-$1);if (i<=',int2str(nproc),') {printf "%s%s%s\n" " ",$2,":",int(2.5-$1)}}}'' >! .machines']);%Select the nodes (1 or 2 processors per node), and when 0 processor is available, the node is not put in the list
%
fid = fopen('.machines','r');
listactivenodes = fread(fid,'uint8=>char')';
fclose(fid);
proc = listactivenodes(strfind(listactivenodes,':')+1);
nprocmax = sum(str2num(proc(:)));%Maximum number of available processors (usually nprocmax = nproc, except is nproc is too large or the computing charge is too heavy)
if nprocmax ~= nproc,
   info_dke_yp(2,['Number of processors requested : ',int2str(nproc),', number of processors available: ',int2str(nprocmax)])
end
%
%Execute HYPRE on N processors in the scratch directory
%
dbstop 73
nprocmax = 2
[flag,text]=unix('lamboot');
%! /usr/local/pgi/linux86-64/6.0/bin/mpirun -np 2 -machinefile .machines /home/sccp/gsem/peysson/Project_DKE/hypre-1.6.0/src/test/IJ_linear_solvers -- -fromijfile matrix -rhsfromfile vectors 

[flag,text]=unix(['/usr/local/pgi/linux86-64/6.0/bin/mpirun -np ',int2str(nprocmax),' -machinefile .machines ',HYPREpath,'./IJ_linear_solvers -solver 7 -rhsrand']);
%
% Read one file per variable for MatLab <-> HYPRE FORTRAN
%
if flag == 0,



   X = X(:);
else
   X = [];
end
%
cd(initial_dir);%return to the initial working directory

  
  
  
  