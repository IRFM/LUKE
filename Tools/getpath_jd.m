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
function pathname = getpath_jd(filename);
%
fullpath = which([filename]);
%
ns = length(fullpath);
while ns > 0 & fullpath(ns) ~= '\'  & fullpath(ns) ~= '/' 
    ns = ns - 1;
end

pathname = fullpath(1:ns-1);
