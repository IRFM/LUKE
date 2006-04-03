function [X,flag,L,U,text] = HYPRE_dke_yp(HYPREparam,A,B,droptol,temppath)
%
%Link with the parallel matrix solver package HYPRE written in C. Use the hyprematlab library (see www.mathworks.com) 
%Adapted to the Saturne computers of the CEA-DRFC. Use the SUPERLU package for incomplete LU matrix factorization.
%
%Solve the linear system of equation AX=B or provides L and U incompelete factorization matrices when B is empty only. 
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
%   - flag: execution flag (see the MUMPS documentation) [1,1]
%
%By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
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
cd(temppath);%Move to scratch directory
%
% Write one file per variable for MatLab <-> FORTRAN in the scratch directory
%
 matlab2hypreIJ(A,HYPREparam.nproc,'matrix','15.10e');

%
% Test processor charge to select the first less used regarding the total number of processors needed
%
%
! qstat -f | awk '$2=="BP" {print $0}' | awk '{print $1,$4}' | sed -e 's/all.q@//g' | sed -e 's/.cad.cea.fr./ /g' | sed -e 's/.cad.cea.f./ /g' | grep -v sequenceur | sed -e 's/sequenceur@//g' | awk '{print $2,$1}' | sort | uniq | awk '{print "Charge =",$1,"==>",$2}'
! qstat -f | awk '$2=="BP" {print $0}' | awk '{print $1,$4}' | sed -e 's/all.q@//g' | sed -e 's/.cad.cea.fr./ /g' | sed -e 's/.cad.cea.f./ /g' | grep -v sequenceur | sed -e 's/sequenceur@//g' | awk '{print $2,$1}' | sort | uniq | awk '{print $2}' >! .machines.tmp
unix(['head -',int2str(nproc),' .machines.tmp >! .machines']);%Keeps the first nproc processors who have the less CPU charge
! rm -f .machines.tmp*
%
%Convert MatLab data to HYPRE format for the number of requested processors. Files are  in the scratch directory
%
matlab2hypreIJ(A,nproc,'matrix','15.10e');
matlab2hypreParVectors(B(:),nproc,'vectors');
%
%Execute HYPRE on N processors in the scratch directory
%



mpirun -np 2 ij_es -lobpcg -fromfile matrix


[flag,text]=unix(['/usr/local/pgi/linux86-64/6.0/bin/mpirun -np ',int2str(nproc),' -machinefile .machines ',HYPREpath,'ij_es -lobpcg -fromfile matrix']);
%
% Read one file per variable for MatLab <-> MUMPS FORTRAN
%
if flag == 0,



   X = X(:);
else
   X = [];
end
%
cd(initial_dir);%return to the initial working directory

  
  
  
  