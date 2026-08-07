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
function locid_simul = make_aloha_simulid_yp(aloha)
%
% This function creates a standard id string from aloha LH coupling parameters
%
if isstruct(aloha)
    %
    if iscell(aloha.plasma.ne0)
        ne0 = 0;
        for ij = 1:length(aloha.plasma.ne0)
            ne0 = ne0 + aloha.plasma.ne0{ij}/1e17;
        end
        ne0 = ne0/length(aloha.plasma.ne0);%mean value considered
    else
        ne0 = aloha.plasma.ne0/1e17;
    end
    %
    ne0_str = strrep(num2str(ne0),'.','p');
    %
    locid_simul = ['ALOHA_nlh_',ne0_str];
    %
else
    locid_simul = '';
end
