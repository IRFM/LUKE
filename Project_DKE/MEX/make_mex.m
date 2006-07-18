function [] = make_mex(id_path,filename,opts)
%
% Mex compilation for FORTRAN and C programs.
%
%by J.Decker CEA/DRFC  <joan.decker@cea.fr> and Y.Peysson CEA/DRFC <yves.peysson@cea.fr> 
%
if nargin < 2,
     error('Wrong number of input arguments for make_mex');
end
    
%
[pathstr,name,ext] = fileparts('filename')fileparts(filename)
%
if (nargin == 2) & ~isempty(strfind(ext,'f')),
	error('FORTRAN files require to specify compiling options (f77 or f90) !')
end
%
path_path = '../../../Database/PATH_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
if exist([path_path,'PATH_',id_path,'.mat']) == 0,%Paths
	info_dke_yp(2,[path_path,'PATH_',id_path,'.mat does not exist. Set all paths in the ~/Project_DKE/Database/PATH_files/']);
	break
else
	eval(['load ',path_path,'PATH_',id_path,'.mat']);
	info_dke_yp(2,'Structure ''path'' successfully loaded');
    if ~strcmp(path.computer,computer),error('The path structure is not consistent with the computer !'),end
end
%
if isempty(opts) | ~isempty(strfind(ext,'c')),%C language
   eval(['mex -v -f ',path.mex,'/mexopts_f77.sh ',filename]);
elseif strcmp(opts,'f77') & ~isempty(strfind(ext,'f')),%FORTRAN 77 language
   eval(['mex -v -f ',path.mex,'/mexopts_f90.sh ',filename]);
elseif strcmp(opts,'f90') & ~isempty(strfind(ext,'f')),%FORTRAN 90 language
   eval(['mex -v -f ',path.mex,'/mexopts_f77.sh ',filename]);
else
  	error('The type of file is not recognized by its extension !')
end
   