% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [] = buildmat(build_mode,dirname,str)
%LUKE - Create binary file (*.mat) from script or mexfile
%
%This script build all *.mat file from an existing script (*.m or mexfile)
%
% by  Yves Peysson <yves.peysson@cea.fr> (CEA/DSM/IRFM) and Joan Decker <joan.decker@cea.fr> (CEA/DSM/IRFM)
%
cd(dirname)
delete('*.mat')
pause(2)
if nargin < 3,
    filelist = dir(['make_',lower(dirname(1:strfind(dirname,'_'))),'*.m']);
else
    filelist = dir(['make_',str,'*.m']);
end    
save temp.mat filelist dirname build_mode
%
for i = 1:length(filelist),
  file = strrep(filelist(i,1).name,'.m','');
  if build_mode,
     eval(file);
  else
     if isempty(strfind(file, '_mex'))
        eval(file);
     end
  end  
  load temp.mat
end
info_dke_yp(2,['All *.mat files done in ',dirname,' directory.'])
delete('temp.mat');
cd ..
   
