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
function userid = userid_jd
%
% This function determines and returns the user id
%
str = '';
%
if strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64'), % Windows systems
    [flag,str] = dos('hostname');
	userid = strtrim(str);
else % UNIX based systems
    userid = getenv('USER');
end
