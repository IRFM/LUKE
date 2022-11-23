function dkepath = path_CEA_INTRA
%
% path definitions for CEA cluster in INTRA zone
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = {'sirrah','talitha','gemma','naos','spica','pollux'};%'pleione' 'nashira'
dkepath.hostname = {'sirrah','talitha','gemma','naos','spica','pollux'};%'pleione' 'nashira'
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'YP105119'; 
%
%-------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%-------------------------------------------------------------------------------------------------------
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.YP105119(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.YP105119(1).luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
dkepath.YP105119(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% ---------------------------- sirrah -------------------------------
%
dkepath.YP105119(1).sirrah.local_root = '/Home/YP105119/Packages/Bin/';
%
dkepath.YP105119(1).sirrah.mex802 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB802/'];
dkepath.YP105119(1).sirrah.mex806 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB806/'];
dkepath.YP105119(1).sirrah.mex903 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB903/'];
dkepath.YP105119(1).sirrah.mex907 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB907/'];
dkepath.YP105119(1).sirrah.mex909 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/MATLAB909/'];
%
dkepath.YP105119(1).sirrah.compiler_opt.copts = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex802 = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex806 = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex903 = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex907 = '';
dkepath.YP105119(1).sirrah.compiler_opt.copts.cpp.mex909 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex802 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex806 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex903 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex907 = '';
dkepath.YP105119(1).sirrah.compiler_opt.fopts.mex909 = '';
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex802 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex806 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex903 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex907 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).sirrah.compiler_opt.helmex.mex909 = ['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).sirrah.local_root,'LAPACK/lapack-3.7.0 -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).sirrah.MUMPS.mex802 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB802'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex806 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB806'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex903 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB903'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex907 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB907'];%MUMPS_5.0.2
dkepath.YP105119(1).sirrah.MUMPS.mex909 = [dkepath.YP105119(1).sirrah.local_root,'MUMPS/MUMPS_5.0.2/MATLAB909'];%MUMPS_5.0.2
%
% LUKE documentation
%
dkepath.YP105119(1).sirrah.graphviz.env = '/usr/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).sirrah.latex.env = '/usr/bin';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).sirrah.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
% ---------------------------- other machine of zone intra -------------------------------
%
dkepath.YP105119(1).gemma = dkepath.YP105119(1).sirrah;
dkepath.YP105119(1).naos = dkepath.YP105119(1).sirrah;
dkepath.YP105119(1).spica = dkepath.YP105119(1).sirrah;
dkepath.YP105119(1).talitha = dkepath.YP105119(1).sirrah;
dkepath.YP105119(1).pollux = dkepath.YP105119(1).sirrah;
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.YP105119(1).remote(1).remoteid = 'CEA_SIRRAH';
dkepath.YP105119(1).remote(1).schedulername = 'pbs';
dkepath.YP105119(1).remote(1).profilename = 'YP105119';
dkepath.YP105119(1).remote(1).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(2).remoteid = 'CEA_TALITHA';
dkepath.YP105119(1).remote(2).schedulername = 'pbs';
dkepath.YP105119(1).remote(2).profilename = 'YP105119';
dkepath.YP105119(1).remote(2).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(3).remoteid = 'CEA_NAOS';
dkepath.YP105119(1).remote(3).schedulername = 'direct';
dkepath.YP105119(1).remote(3).profilename = 'YP105119';
dkepath.YP105119(1).remote(3).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(4).remoteid = 'CEA_GEMMA';
dkepath.YP105119(1).remote(4).schedulername = 'pbs';
dkepath.YP105119(1).remote(4).profilename = 'YP105119';
dkepath.YP105119(1).remote(4).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(5).remoteid = 'CEA_SPICA';
dkepath.YP105119(1).remote(5).schedulername = 'pbs';
dkepath.YP105119(1).remote(5).profilename = 'YP105119';
dkepath.YP105119(1).remote(5).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(6).remoteid = 'CEA_POLLUX';
dkepath.YP105119(1).remote(6).schedulername = 'pbs';
dkepath.YP105119(1).remote(6).profilename = 'YP105119';
dkepath.YP105119(1).remote(6).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
%------------------------------------ Other LUKE users ------------------------------
%
dkepath.JA132999(1) = dkepath.YP105119(1);% Jean-Francois Artaud
dkepath.JA132999(1).luke_root = '/Home/JA132999/luke/LUKE_LHCD/';
dkepath.JA132999(1).remote(1).luke_root = dkepath.JA132999(1).luke_root;
dkepath.JA132999(1).remote(1).profilename = 'JA132999';
dkepath.JA132999(1).remote(2).luke_root = dkepath.JA132999(1).luke_root;
dkepath.JA132999(1).remote(2).profilename = 'JA132999';
dkepath.JA132999(1).remote(3).luke_root = dkepath.JA132999(1).luke_root;
dkepath.JA132999(1).remote(3).profilename = 'JA132999';
dkepath.JA132999(1).remote(4).luke_root = dkepath.JA132999(1).luke_root;
dkepath.JA132999(1).remote(4).profilename = 'JA132999';
dkepath.JA132999(1).remote(5).luke_root = dkepath.JA132999(1).luke_root;
dkepath.JA132999(1).remote(5).profilename = 'JA132999';
dkepath.JA132999(1).remote(6).luke_root = dkepath.JA132999(1).luke_root;
dkepath.JA132999(1).remote(6).profilename = 'JA132999';
%
dkepath.CB165101(1) = dkepath.YP105119(1);%Clarisse Bourdelle
dkepath.CB165101(1).luke_root = '/Home/CB165101/luke/LUKE_LHCD/';
dkepath.CB165101(1).remote(1).luke_root = dkepath.CB165101(1).luke_root;
dkepath.CB165101(1).remote(1).profilename = 'CB165101';
dkepath.CB165101(1).remote(2).luke_root = dkepath.CB165101(1).luke_root;
dkepath.CB165101(1).remote(2).profilename = 'CB165101';
dkepath.CB165101(1).remote(3).luke_root = dkepath.CB165101(1).luke_root;
dkepath.CB165101(1).remote(3).profilename = 'CB165101';
dkepath.CB165101(1).remote(4).luke_root = dkepath.CB165101(1).luke_root;
dkepath.CB165101(1).remote(4).profilename = 'CB165101';
dkepath.CB165101(1).remote(5).luke_root = dkepath.CB165101(1).luke_root;
dkepath.CB165101(1).remote(5).profilename = 'CB165101';
dkepath.CB165101(1).remote(6).luke_root = dkepath.CB165101(1).luke_root;
dkepath.CB165101(1).remote(6).profilename = 'CB165101';
%
dkepath.MG100063(1) = dkepath.YP105119(1);%Marc Goniche
dkepath.MG100063(1).luke_root = '/Home/MG100063/luke/LUKE_LHCD/';
dkepath.MG100063(1).remote(1).luke_root = dkepath.MG100063(1).luke_root;
dkepath.MG100063(1).remote(1).profilename = 'MG100063';
dkepath.MG100063(1).remote(2).luke_root = dkepath.MG100063(1).luke_root;
dkepath.MG100063(1).remote(2).profilename = 'MG100063';
dkepath.MG100063(1).remote(3).luke_root = dkepath.MG100063(1).luke_root;
dkepath.MG100063(1).remote(3).profilename = 'MG100063';
dkepath.MG100063(1).remote(4).luke_root = dkepath.MG100063(1).luke_root;
dkepath.MG100063(1).remote(4).profilename = 'MG100063';
dkepath.MG100063(1).remote(5).luke_root = dkepath.MG100063(1).luke_root;
dkepath.MG100063(1).remote(5).profilename = 'MG100063';
dkepath.MG100063(1).remote(6).luke_root = dkepath.MG100063(1).luke_root;
dkepath.MG100063(1).remote(6).profilename = 'MG100063';
%
dkepath.VO259454(1) = dkepath.YP105119(1);%Valeria Ostuni
dkepath.VO259454(1).luke_root = '/Home/VO259454/luke/LUKE_LHCD/';
dkepath.VO259454(1).remote(1).luke_root = dkepath.VO259454(1).luke_root;
dkepath.VO259454(1).remote(1).profilename = 'VO259454';
dkepath.VO259454(1).remote(2).luke_root = dkepath.VO259454(1).luke_root;
dkepath.VO259454(1).remote(2).profilename = 'VO259454';
dkepath.VO259454(1).remote(3).luke_root = dkepath.VO259454(1).luke_root;
dkepath.VO259454(1).remote(3).profilename = 'VO259454';
dkepath.VO259454(1).remote(4).luke_root = dkepath.VO259454(1).luke_root;
dkepath.VO259454(1).remote(4).profilename = 'VO259454';
dkepath.VO259454(1).remote(5).luke_root = dkepath.VO259454(1).luke_root;
dkepath.VO259454(1).remote(5).profilename = 'VO259454';
%
dkepath.JM240179(1) = dkepath.YP105119(1);%Jorge Morales
dkepath.JM240179(1).luke_root = '/Home/JM240179/luke/LUKE_LHCD/';
dkepath.JM240179(1).remote(1).luke_root = dkepath.JM240179(1).luke_root;
dkepath.JM240179(1).remote(1).profilename = 'JM240179';
dkepath.JM240179(1).remote(2).luke_root = dkepath.JM240179(1).luke_root;
dkepath.JM240179(1).remote(2).profilename = 'JM240179';
dkepath.JM240179(1).remote(3).luke_root = dkepath.JM240179(1).luke_root;
dkepath.JM240179(1).remote(3).profilename = 'JM240179';
dkepath.JM240179(1).remote(4).luke_root = dkepath.JM240179(1).luke_root;
dkepath.JM240179(1).remote(4).profilename = 'JM240179';
dkepath.JM240179(1).remote(5).luke_root = dkepath.JM240179(1).luke_root;
dkepath.JM240179(1).remote(5).profilename = 'JM240179';
dkepath.JM240179(1).remote(6).luke_root = dkepath.JM240179(1).luke_root;
dkepath.JM240179(1).remote(6).profilename = 'JM240179';
%
dkepath.TB263881(1) = dkepath.YP105119(1);%Tullio Barbui
dkepath.TB263881(1).luke_root = '/Home/TB263881/luke/LUKE_LHCD/';
dkepath.TB263881(1).remote(1).luke_root = dkepath.TB263881(1).luke_root;
dkepath.TB263881(1).remote(1).profilename = 'TB263881';
dkepath.TB263881(1).remote(2).luke_root = dkepath.TB263881(1).luke_root;
dkepath.TB263881(1).remote(2).profilename = 'TB263881';
dkepath.TB263881(1).remote(3).luke_root = dkepath.TB263881(1).luke_root;
dkepath.TB263881(1).remote(3).profilename = 'TB263881';
dkepath.TB263881(1).remote(4).luke_root = dkepath.TB263881(1).luke_root;
dkepath.TB263881(1).remote(4).profilename = 'TB263881';
dkepath.TB263881(1).remote(5).luke_root = dkepath.TB263881(1).luke_root;
dkepath.TB263881(1).remote(5).profilename = 'TB263881';
dkepath.TB263881(1).remote(6).luke_root = dkepath.TB263881(1).luke_root;
dkepath.TB263881(1).remote(6).profilename = 'TB263881';
%
dkepath.RS272879(1) = dkepath.YP105119(1);%Riccardo Saura
dkepath.RS272879(1).luke_root = '/Home/RS272879/luke/LUKE_LHCD/';
dkepath.RS272879(1).remote(1).luke_root = dkepath.RS272879(1).luke_root;
dkepath.RS272879(1).remote(1).profilename = 'RS272879';
dkepath.RS272879(1).remote(2).luke_root = dkepath.RS272879(1).luke_root;
dkepath.RS272879(1).remote(2).profilename = 'RS272879';
dkepath.RS272879(1).remote(3).luke_root = dkepath.RS272879(1).luke_root;
dkepath.RS272879(1).remote(3).profilename = 'RS272879';
dkepath.RS272879(1).remote(4).luke_root = dkepath.RS272879(1).luke_root;
dkepath.RS272879(1).remote(4).profilename = 'RS272879';
dkepath.RS272879(1).remote(5).luke_root = dkepath.RS272879(1).luke_root;
dkepath.RS272879(1).remote(5).profilename = 'RS272879';
dkepath.RS272879(1).remote(6).luke_root = dkepath.RS272879(1).luke_root;
dkepath.RS272879(1).remote(6).profilename = 'RS272879';
