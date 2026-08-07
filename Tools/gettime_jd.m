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
function filetime = gettime_jd(filename,filepath,test)
%
% This function returns a comparison-ready modification time for the input
% file in the input directory
%
if nargin < 3,
    test = false;
end
%
if nargin < 2 || isempty(filepath),
    filepath = './';
end
%
files = dir(filepath);
filetime = 0;
%
for ifile = 1:length(files),
    if strcmp(files(ifile).name,filename),
        if isfield(files(ifile),'datenum'),
            filetime = files(ifile).datenum;
        else
            filetime = datenum(files(ifile).date);
        end
        return
    end
end
%
if test,
    error(['The source file ',filename,' was not found in ',filepath])
end
