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
function hxrparam_out = sluke_correct_missing_fields(sparams,ii,hxrparam_in)
%



hxrparam_out = hxrparam_in;



%{
    sparams_tmp = sluke_params_defaults;
    %
    hxrparam_tmp = sluke_params_value(sparams_tmp.diags.hxr.hxrparam);
    %
    flag = 0;
    %
    for jj = 1:length(fieldnamesr(hxrparam_tmp))
        %
        if isfield(
        
        
        end
    end
%}