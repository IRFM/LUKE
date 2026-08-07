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
function mex_clean_luke(luke_root)
%
mexpath = [luke_root,'Project_DKE/MEX/Bin/'];
%
foldercontent = dir(mexpath);
%
for icont = 1:length(foldercontent),
    if foldercontent(icont).isdir...
            && ~strcmp(foldercontent(icont).name,'.')...
            && ~strcmp(foldercontent(icont).name,'..')...
            && ~strcmp(foldercontent(icont).name,'CVS'),
        rmdir([mexpath,foldercontent(icont).name],'s');
    elseif ~foldercontent(icont).isdir && ~strcmp(foldercontent(icont).name,'readme.txt'), 
        delete([mexpath,foldercontent(icont).name]);
    end
end
%
disp(['The mexfiles has been removed.'])
%