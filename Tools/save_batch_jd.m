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
function save_batch_jd(lukestructs,dkepath,savestr,savepath)
%
% This function saves the results from run_lukert in a file for laterprocessing
%
if nargin < 4,
    savepath = '.';
end
if nargin < 3,
    savestr = '';
end
%
if ~isempty(savestr),
    savestr = ['_',savestr];
end
%
filename = [savepath,filesep,'LUKE_BATCH',savestr,'.mat'];
%
ifilenum = 0;
while exist(filename,'file'),% to avoid overwriting existing batch file
    ifilenum = ifilenum + 1;
    filename = [savepath,filesep,'LUKE_BATCH',savestr,'_',num2str(ifilenum),'.mat'];
end   
%
save(filename,'lukestructs','dkepath')
%
if isfield(lukestructs{1},'job'),
    disp(['Jobs info saved in ',filename])
else
    disp(['LUKE Results saved in ',filename])
end
