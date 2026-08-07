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
function output = sluke_params_replace(data_in,val0,val1)
%
output = data_in;
%
for ii = 1:length(data_in)
    %
    if ischar(data_in{ii})
        output{ii} = strrep(data_in{ii},val0,val1);
    else
        if data_in{ii} == val0
            output{ii} = val1;
        end
    end
    %
end

    

